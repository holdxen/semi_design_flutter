// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/browser/markdownRenderer.ts
// Strict 1:1 translation. The vendored `marked` engine is a runtime dependency
// that has no Dart port (only `marked.d.dart` type carriers exist); all calls
// into it go through the injectable [MarkedEngine] hook so logic here stays
// byte-for-byte faithful to the source while remaining testable via truth data.
// ---------------------------------------------------------------------------

import 'dart:collection' as collection;
import 'dart:convert' as convert;

import '../common/errors.dart' as errors;
import '../common/extpath.dart' as extpath;
import '../common/htmlContent.dart' as htmlContent;
import '../common/iconLabels.dart' as iconLabels;
import '../common/idGenerator.dart' as idGenerator;
import '../common/keyCodes.dart' as keyCodes;
import '../common/lifecycle.dart' as lifecycle;
import '../common/marshalling.dart' as marshalling;
import '../common/network.dart' as network;
import '../common/objects.dart' as objects;
import '../common/path.dart' as pathLib;
import '../common/resources.dart' as resources;
import '../common/strings.dart' as strings;
import '../common/uri.dart' as uri;

// ---------------------------------------------------------------------------
// Injectable marked engine boundary. See `setMarkedEngine` for truth tests.
// ---------------------------------------------------------------------------

/// The subset of the vendored `marked` runtime this file depends on.
abstract class MarkedEngine {
  /// `marked.lexer(src, options?)` -> TokensList (a token `List` with `.links`).
  List<Object?> lexer(String src, [Object? options]);

  /// `marked.parse(src, { renderer, async: false })`.
  String parse(String src, {Object? renderer, bool async = false});

  /// `new marked.Renderer(options?)`. The returned object must expose the
  /// renderer method fields used by [createPlainTextRenderer] et al.
  Object createRenderer([Object? options]);

  /// `new marked.Lexer()` with an assignable `tokens.links`.
  Object createLexer();

  /// `lexer.lex(src)` on an instance created by [createLexer].
  List<Object?> lexInstance(Object lexer, String src);

  /// `new marked.Marked(...extensions)` instance factory.
  Object createMarkedInstance([List<Object?> extensions = const <Object?>[]]);

  /// `instance.lexer(src, opts)`.
  List<Object?> instanceLexer(Object instance, String src, [Object? options]);

  /// `instance.parser(tokens, opts)`.
  String instanceParser(Object instance, List<Object?> tokens, [Object? options]);

  /// `instance.parse(src, opts)`.
  String instanceParse(Object instance, String src, [Object? options]);

  /// `instance.defaults`.
  Object? instanceDefaults(Object instance);

  /// `instance.walkTokens(tokens, cb)`.
  void instanceWalkTokens(Object instance, List<Object?> tokens, Object? callback);

  /// `instance.Renderer` constructor (options).
  Object instanceRenderer(Object instance, [Object? options]);
}

MarkedEngine? _markedEngine;

/// Replace the marked runtime (used by truth tests).
void setMarkedEngine(MarkedEngine engine) => _markedEngine = engine;

MarkedEngine get _marked {
  final MarkedEngine? engine = _markedEngine;
  if (engine == null) {
    throw StateError(
        'MarkedEngine not initialized: call setMarkedEngine() before using markdownRenderer.');
  }
  return engine;
}

// ---------------------------------------------------------------------------
// Dynamic carrier: Dart has no JS-style expando object, so renderer/parser/
// lexer objects supplied by [MarkedEngine] use this field bag. It also gives
// the renderer methods a uniform 1:1 call surface used above.
// ---------------------------------------------------------------------------
class RendererCarrier {
  RendererCarrier([Object? parser]) : parser = parser;
  Object? parser;
  final Map<String, Object?> fields = <String, Object?>{};

  Object? get(String name) => fields[name];
  void put(String name, Object? value) => fields[name] = value;

  String callRenderer(String name, Map<String, Object?> token) {
    final Object? fn = fields[name];
    if (fn == null) return '';
    if (fn is String Function(Map<String, Object?>)) return fn(token);
    try {
      return (fn as dynamic)(token) as String;
    } catch (_) {
      return '';
    }
  }
}

// ---------------------------------------------------------------------------
// Injectable document/sanitizer boundary (DOM APIs have no Node parity).
// ---------------------------------------------------------------------------

abstract class MarkdownDomAdapter {
  Object createElement(String tag);
  void setInnerHtml(Object element, String html, Object? config);
  Object? querySelector(Object element, String selector);
  List<Object> querySelectorAll(Object element, String selector);
  List<Object> getChildNodes(Object element);
  void reset(Object element, List<Object> nodes);
  bool hasAttribute(Object element, String name);
  String? getAttribute(Object element, String name);
  void setAttribute(Object element, String name, String value);
  void removeAttribute(Object element, String name);
  String? getDataset(Object element, String key);
  void setDataset(Object element, String key, String value);
  String getTagName(Object element);
  Object? getParent(Object element);
  void replaceWith(Object element, List<Object> nodes);
  void removeChild(Object parent, Object child);
  void insertBefore(Object parent, Object node, Object? ref);
  Object? getFirstChild(Object parent);
  Object? getNextSibling(Object node);
  bool isHTMLElement(Object node);
  void addDisposableListener(Object element, String type, void Function(Object) handler);
  Object getWindow(Object element);
  Object? getTarget(Object event);
  void preventDefault(Object event);
  void stopPropagation(Object event);
  bool getLeftButton(Object event);
  bool getMiddleButton(Object event);
  bool keyEquals(Object event, Object keyCode);
  Object? dispatchErrorEvent(String message, Object error);
  void copyAttributes(Object from, Object to);
  List<String> getAttributeNames(Object element);
  void dispatchEvent(Object element, Object event);
  Object? convertTagToPlaintext(Object node);
  List<Object> getElementsByTagName(Object element, String tag);
  Object createMouseEvent(Object window, Object event);
  Object createKeyboardEvent(Object event);
  Object? closest(Object element, String selector);
}

MarkdownDomAdapter? _domAdapter;
void setMarkdownDomAdapter(MarkdownDomAdapter adapter) => _domAdapter = adapter;

MarkdownDomAdapter get _dom {
  final MarkdownDomAdapter? adapter = _domAdapter;
  if (adapter == null) {
    throw StateError(
        'MarkdownDomAdapter not initialized: call setMarkdownDomAdapter() before renderMarkdown.');
  }
  return adapter;
}

/// Injectable sanitizer: mirrors `domSanitize.sanitizeHtml(...).toString()`.
typedef SanitizeHtml = String Function(String html, Object? config);
SanitizeHtml? _sanitizeHtml;
void setSanitizeHtml(SanitizeHtml fn) => _sanitizeHtml = fn;

String _sanitize(String html, Object? config) {
  final SanitizeHtml? fn = _sanitizeHtml;
  return fn != null ? fn(html, config) : html;
}

/// Injectable `domSanitize.safeSetInnerHtml`.
typedef SafeSetInnerHtml = void Function(Object element, String html, Object? config);
SafeSetInnerHtml? _safeSetInnerHtml;
void setSafeSetInnerHtml(SafeSetInnerHtml fn) => _safeSetInnerHtml = fn;

/// Injectable `renderLabelWithIcons` -> List<Object> (String or element).
typedef RenderLabelWithIcons = List<Object> Function(String text);
RenderLabelWithIcons? _renderLabelWithIcons;
void setRenderLabelWithIcons(RenderLabelWithIcons fn) => _renderLabelWithIcons = fn;

/// Injectable `renderIcon({id}).outerHTML`.
typedef RenderIcon = String Function(String id);
RenderIcon? _renderIcon;
void setRenderIcon(RenderIcon fn) => _renderIcon = fn;

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

typedef MarkdownActionHandler = void Function(String linkContent, Object mdStr);

class MarkdownRenderOptions {
  MarkdownRenderOptions({
    this.codeBlockRenderer,
    this.codeBlockRendererSync,
    this.asyncRenderCallback,
    this.actionHandler,
    this.transformUri,
    this.fillInIncompleteTokens,
    this.sanitizerConfig,
    this.markedOptions,
    this.markedExtensions,
  });

  final Future<Object> Function(String languageId, String value)? codeBlockRenderer;
  final Object Function(String languageId, String value, [String? raw])? codeBlockRendererSync;
  final void Function()? asyncRenderCallback;
  final MarkdownActionHandler? actionHandler;
  final String Function(String href, String kind)? transformUri;
  final bool? fillInIncompleteTokens;
  final MarkdownSanitizerConfig? sanitizerConfig;
  final Object? markedOptions;
  final List<Object?>? markedExtensions;
}

class MarkdownRendererMarkedOptions {
  MarkdownRendererMarkedOptions({this.gfm, this.breaks});
  final bool? gfm;
  final bool? breaks;
}

typedef RemoteImageIsAllowed = bool Function(uri.URI u);

class MarkdownSanitizerConfig {
  MarkdownSanitizerConfig({
    this.replaceWithPlaintext,
    this.allowedTags,
    this.allowedAttributes,
    this.allowedLinkSchemes,
    this.allowedMediaSchemes,
    this.remoteImageIsAllowed,
  });

  final bool? replaceWithPlaintext;
  final List<String> Function()? allowedTags;
  final List<Object?> Function()? allowedAttributes;
  final List<String>? allowedLinkSchemes;
  final List<String>? allowedMediaSchemes;
  final RemoteImageIsAllowed? remoteImageIsAllowed;
}

class MdStrConfig {
  MdStrConfig({this.isTrusted, this.baseUri, this.uris});
  final bool? isTrusted;
  final Object? baseUri;
  final Map<String, Object?>? uris;
}

// ---------------------------------------------------------------------------
// 1:1 helpers
// ---------------------------------------------------------------------------

/// 1:1: `function getLinkTitle(href)`.
String getLinkTitle(String href) {
  try {
    final uri.URI parsed = uri.URI.parse(href);
    if (parsed.scheme == network.Schemas.file) {
      final String path = parsed.fsPath;
      final String fragment = parsed.fragment;
      return htmlContent.escapeDoubleQuotes(
          fragment.isNotEmpty ? '$path#$fragment' : path);
    }
  } catch (_) {
    // fall through
  }
  return '';
}

/// 1:1: `function renderImage({ href, title, text }, transformUri?)`.
String renderImage(Map<String, Object?> token,
    [String Function(String href)? transformUri]) {
  String href = (token['href'] as String?) ?? '';
  String title = (token['title'] as String?) ?? '';
  final String text = (token['text'] as String?) ?? '';
  List<String> dimensions = <String>[];
  List<String> attributes = <String>[];
  if (href.isNotEmpty) {
    final Map<String, Object> parsed = htmlContent.parseHrefAndDimensions(href);
    href = parsed['href'] as String? ?? href;
    final Object? d = parsed['dimensions'];
    dimensions = d is List ? d.cast<String>() : <String>[];
    if (transformUri != null) href = transformUri(href);
    attributes.add('src="${htmlContent.escapeDoubleQuotes(href)}"');
  }
  if (text.isNotEmpty) {
    attributes.add('alt="${htmlContent.escapeDoubleQuotes(text)}"');
  }
  if (title.isNotEmpty) {
    attributes.add('title="${htmlContent.escapeDoubleQuotes(title)}"');
  }
  if (dimensions.isNotEmpty) {
    attributes = List<String>.from(attributes)..addAll(dimensions);
  }
  return '<img ${attributes.join(' ')}>';
}

String _htmlEncodeHref(String href) => href
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');

/// 1:1: `defaultMarkedRenderers.link`.
String defaultRenderLink(
  Object renderer,
  Map<String, Object?> token, [
  String Function(String href)? transformUri,
]) {
  final Object parser = _field(renderer, 'parser') ?? Object();
  String href = (token['href'] as String?) ?? '';
  if (transformUri != null) href = transformUri(href);
  final List<Object?> tokens = (token['tokens'] as List<Object?>?) ?? <Object?>[];
  String text = _parseInline(parser, tokens);
  if (href.isEmpty && token['href'] is! String) return '';

  if (href == text) {
    text = htmlContent.removeMarkdownEscapes(text);
  }
  String title = token['title'] is String
      ? htmlContent.escapeDoubleQuotes(
          htmlContent.removeMarkdownEscapes(token['title'] as String))
      : '';
  href = htmlContent.removeMarkdownEscapes(href);

  if (title.isEmpty && href.startsWith('${network.Schemas.file}:')) {
    title = getLinkTitle(href);
  }
  final bool isCommandUri = href.startsWith('${network.Schemas.command}:');
  href = _htmlEncodeHref(href);
  final String effectiveTitle = title.isNotEmpty ? title : (isCommandUri ? '' : href);
  return '<a href="$href" title="$effectiveTitle" draggable="false">$text</a>';
}

/// 1:1: `defaultMarkedRenderers.paragraph`.
String defaultRenderParagraph(Object parser, Map<String, Object?> token) {
  final List<Object?> tokens = (token['tokens'] as List<Object?>?) ?? <Object?>[];
  return '<p>${_parseInline(parser, tokens)}</p>';
}

Object? _field(Object obj, String name) {
  if (obj is Map) return obj[name];
  try {
    switch (name) {
      case 'value': return (obj as dynamic).value;
      case 'parser':
        if (obj is RendererCarrier) {
          return obj.get('parser') ?? obj.parser;
        }
        return (obj as dynamic).parser;
      case 'uris': return (obj as dynamic).uris;
      case 'isTrusted': return (obj as dynamic).isTrusted;
      case 'baseUri': return (obj as dynamic).baseUri;
      case 'supportThemeIcons': return (obj as dynamic).supportThemeIcons;
      case 'supportAlertSyntax': return (obj as dynamic).supportAlertSyntax;
      case 'supportHtml': return (obj as dynamic).supportHtml;
      case 'outerHTML': return (obj as dynamic).outerHTML;
      default: return null;
    }
  } catch (_) {
    return null;
  }
}

String _parseInline(Object parser, List<Object?> tokens) {
  try {
    return (parser as dynamic).parseInlineTokens(tokens) as String;
  } catch (_) {
    return '';
  }
}

String _parseTokens(Object parser, List<Object?> tokens, [bool top = false]) {
  try {
    return (parser as dynamic).parseTokens(tokens, top) as String;
  } catch (_) {
    return '';
  }
}

/// 1:1: `createAlertBlockquoteRenderer(fallbackRenderer)`.
Object Function(Map<String, Object?> token) createAlertBlockquoteRenderer(
  Object fallback,
  Object renderer,
) {
  return (Map<String, Object?> token) {
    final List<Object?> tokens = (token['tokens'] as List<Object?>?) ?? <Object?>[];
    if (tokens.isEmpty) return _callFallback(fallback, renderer, token);
    final Object? first = tokens[0];
    if (first is! Map || first['type'] != 'paragraph') {
      return _callFallback(fallback, renderer, token);
    }
    final List<Object?>? paragraphTokens = first['tokens'] as List<Object?>?;
    if (paragraphTokens == null || paragraphTokens.isEmpty) {
      return _callFallback(fallback, renderer, token);
    }
    final Object? firstText = paragraphTokens[0];
    if (firstText is! Map || firstText['type'] != 'text') {
      return _callFallback(fallback, renderer, token);
    }
    final RegExp pattern = RegExp(
        r'^\s*\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]\s*?\n*',
        caseSensitive: false);
    final String raw = (firstText['raw'] as String?) ?? '';
    final RegExpMatch? match = pattern.firstMatch(raw);
    if (match == null) return _callFallback(fallback, renderer, token);

    firstText['raw'] = raw.replaceFirst(pattern, '');
    firstText['text'] = ((firstText['text'] as String?) ?? '')
        .replaceFirst(pattern, '');

    const Map<String, String> alertIcons = <String, String>{
      'note': 'info',
      'tip': 'light-bulb',
      'important': 'comment',
      'warning': 'alert',
      'caution': 'stop',
    };
    final String type = match.group(1)!;
    final String typeCapitalized =
        type[0].toUpperCase() + type.substring(1).toLowerCase();
    final String severity = type.toLowerCase();
    final String iconHtml = (_renderIcon != null)
        ? _renderIcon!(alertIcons[severity] ?? 'info')
        : '';
    final Object parser = _field(renderer, 'parser') ?? Object();
    final String content = _parseTokens(parser, tokens);
    final String body = content.length >= 3 ? content.substring(3) : '';
    return '<blockquote data-severity="$severity"><p><span>$iconHtml'
        '$typeCapitalized</span>$body</blockquote>\n';
  };
}

String _callFallback(Object fallback, Object renderer, Map<String, Object?> token) {
  try {
    if (fallback is String Function(Map<String, Object?>)) {
      return fallback(token);
    }
    return (fallback as dynamic)(token) as String;
  } catch (_) {
    return '';
  }
}

/// 1:1: `preprocessMarkdownString(markdown)`.
String preprocessMarkdownString(Object markdown) {
  String value = (_field(markdown, 'value') as String?) ?? '';
  if (value.length > 100000) {
    value = '${value.substring(0, 100000)}…';
  }
  if (_readBool(markdown, 'supportThemeIcons')) {
    value = iconLabels.markdownEscapeEscapedIcons(value);
  }
  return value;
}

/// 1:1: `postProcessCodeBlockLanguageId(lang)`.
String postProcessCodeBlockLanguageId(String? lang) {
  if (lang == null || lang.isEmpty) return '';
  final List<String> parts = lang.split(RegExp(r'[\s+|:|,|\{|\?]'));
  if (parts.isNotEmpty) return parts[0];
  return lang;
}

bool _readBool(Object obj, String name) =>
    _field(obj, name) == true;

/// 1:1: `isLocalFileUri(uri)`.
bool isLocalFileUri(uri.URI u) =>
    u.scheme == network.Schemas.file &&
    u.authority.isEmpty &&
    !extpath.isUNC(u.fsPath);

/// 1:1: `isMediaSourceAllowed(...)`.
bool isMediaSourceAllowed(MdStrConfig config, String source,
    RemoteImageIsAllowed remoteImageIsAllowed, List<String> customSchemes) {
  late uri.URI u;
  uri.URI? mappedUri;
  try {
    final Object? baseRaw = config.baseUri;
    final uri.URI? baseUri = baseRaw != null ? uri.URI.from(baseRaw as dynamic) : null;
    final bool hasScheme = RegExp(r'^\w[\w\d+.-]*:/').hasMatch(source);
    if (!hasScheme &&
        baseUri != null &&
        baseUri.scheme == network.Schemas.file &&
        !isLocalFileUri(baseUri)) {
      return false;
    }
    final String href = baseUri != null
        ? htmlContent.resolveWithBaseUri(baseUri, source)
        : source;
    u = uri.URI.parse(href);
    mappedUri = href.startsWith('${network.Schemas.data}:')
        ? null
        : _reviveUri(_readMap(config.uris, href));
    if (customSchemes.contains(u.scheme)) {
      return remoteImageIsAllowed(mappedUri ?? u);
    }
  } catch (_) {
    return false;
  }

  bool allowed(uri.URI x) =>
      isLocalFileUri(x) ||
      x.scheme == network.Schemas.data ||
      remoteImageIsAllowed(x);
  final bool isRemoteFileMapping = isLocalFileUri(u) &&
      mappedUri?.scheme == network.Schemas.vscodeRemote &&
      mappedUri?.path == u.path &&
      mappedUri?.query == u.query &&
      mappedUri?.fragment == u.fragment;
  return allowed(u) &&
      (mappedUri == null || isRemoteFileMapping || allowed(mappedUri));
}

Object? _readMap(Map<String, Object?>? map, String key) => map == null ? null : map[key];

uri.URI? _reviveUri(Object? data) {
  if (data == null) return null;
  if (data is uri.URI) return data;
  if (data is Map) return uri.URI.revive(data);
  return null;
}

/// 1:1: `uriMassage(markdown, part)`.
String uriMassage(Object markdown, String part) {
  Object? data;
  try {
    data = marshalling.parse(convert.utf8.decode(convertUriComponent(part)));
  } catch (_) {
    // ignore
  }
  if (data == null) return part;
  data = objects.cloneAndChange(data, (Object? value) {
    final Object? uris = _field(markdown, 'uris');
    if (uris is Map && uris[value] != null) {
      return _reviveUri(uris[value]);
    }
    return null;
  });
  return encodeUriComponent(convert.utf8.encode(convert.jsonEncode(data)));
}

// URI component helpers (JS decodeURIComponent/encodeURIComponent parity).
List<int> convertUriComponent(String part) => _decodeUriComponent(part);
String encodeUriComponent(List<int> bytes) => _encodeUriComponent(bytes);

List<int> _decodeUriComponent(String s) {
  final List<int> out = <int>[];
  for (int i = 0; i < s.length; i++) {
    final int c = s.codeUnitAt(i);
    if (c == 37 && i + 2 < s.length) {
      final int hi = _hex(s.codeUnitAt(i + 1));
      final int lo = _hex(s.codeUnitAt(i + 2));
      if (hi >= 0 && lo >= 0) {
        out.add((hi << 4) | lo);
        i += 2;
        continue;
      }
    }
    out.addAll(convert.utf8.encode(s[i]));
  }
  return out;
}

int _hex(int c) {
  if (c >= 48 && c <= 57) return c - 48;
  if (c >= 65 && c <= 70) return c - 55;
  if (c >= 97 && c <= 102) return c - 87;
  return -1;
}

const String _hexChars = '0123456789ABCDEF';
String _encodeUriComponent(List<int> bytes) {
  const String unreserved =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.!~*\'()';
  final StringBuffer sb = StringBuffer();
  for (final int b in bytes) {
    final String ch = String.fromCharCode(b);
    if (unreserved.contains(ch)) {
      sb.write(ch);
    } else {
      sb.write('%');
      sb.write(_hexChars[(b >> 4) & 0xF]);
      sb.write(_hexChars[b & 0xF]);
    }
  }
  return sb.toString();
}

/// 1:1: `massageHref(markdown, href, isDomUri)`.
String massageHref(Object markdown, String href, bool isDomUri) {
  final Object? uris = _field(markdown, 'uris');
  uri.URI? u = isDomUri
      ? _reviveUri(uris is Map ? uris[href] : null)
      : _reviveUri(uris is Map ? uris[href] : null);
  if (isDomUri) {
    if (href.startsWith('${network.Schemas.data}:')) return href;
    u ??= uri.URI.parse(href);
    return network.FileAccess.uriToBrowserUri(u).toString(true);
  }
  if (u == null) return href;
  if (uri.URI.parse(href).toString() == u.toString()) return href;
  if (u.query.isNotEmpty) {
    u = u.withChanges(uri.UriChange(query: uriMassage(markdown, u.query)));
  }
  return u.toString();
}

/// 1:1: constants.
final List<String> allowedMarkdownHtmlTags = List<String>.unmodifiable(
    <String>[...domSanitizeBasicTags, 'input']);

final List<Object?> allowedMarkdownHtmlAttributes = List<Object?>.unmodifiable(
    <Object?>[
  'align', 'autoplay', 'alt', 'colspan', 'controls', 'draggable', 'height',
  'href', 'loop', 'muted', 'playsinline', 'poster', 'rowspan', 'src', 'target',
  'title', 'type', 'width', 'start', 'checked', 'disabled', 'value',
  'data-code', 'data-href', 'data-severity',
  <String, Object?>{
    'attributeName': 'style',
    'shouldKeep': (Object element, Object data) {
      if (_domTagName(element) == 'SPAN' && _attrName(data) == 'style') {
        return RegExp(
                r'^(color\:(#[0-9a-fA-F]+|var\(--vscode(-[a-zA-Z0-9]+)+\));)?(background-color\:(#[0-9a-fA-F]+|var\(--vscode(-[a-zA-Z0-9]+)+\));)?(display\:inline-block;)?(border-radius:[0-9]+px;)?$')
            .hasMatch(_attrValue(data));
      }
      return false;
    },
  },
  <String, Object?>{
    'attributeName': 'class',
    'shouldKeep': (Object element, Object data) {
      if (_domTagName(element) == 'SPAN' && _attrName(data) == 'class') {
        return RegExp(r'^codicon codicon-[a-z\-]+( codicon-modifier-[a-z\-]+)?$')
            .hasMatch(_attrValue(data));
      }
      if (_domTagName(element) == 'DIV' && _dom.hasAttribute(element, 'data-code')) {
        return _attrValue(data) == 'code';
      }
      return false;
    },
  },
]);

String _domTagName(Object e) => _dom.getTagName(e).toUpperCase();
String _attrName(Object data) => (_field(data, 'attrName') as String?) ?? '';
String _attrValue(Object data) => (_field(data, 'attrValue') as String?) ?? '';

// Basic tags mirror (injected from domSanitize; kept as a mutable hook so tests
// can supply the exact source list).
List<String> domSanitizeBasicTags = <String>[
  'div', 'span', 'p', 'a', 'b', 'i', 'code', 'pre', 'ul', 'ol', 'li', 'table',
  'thead', 'tbody', 'tr', 'th', 'td', 'br', 'hr', 'blockquote', 'h1', 'h2',
  'h3', 'h4', 'h5', 'h6', 'strong', 'em', 'del', 'img',
];

/// 1:1: `getDomSanitizerConfig(mdStrConfig, options)`.
Object getDomSanitizerConfig(MdStrConfig config, MarkdownSanitizerConfig options) {
  final bool isTrusted = config.isTrusted ?? false;
  final RemoteImageIsAllowed? remoteImageIsAllowed = options.remoteImageIsAllowed;
  final List<String> allowedLinkSchemes = <String>[
    network.Schemas.http,
    network.Schemas.https,
    network.Schemas.mailto,
    network.Schemas.file,
    network.Schemas.vscodeFileResource,
    network.Schemas.vscodeRemote,
    network.Schemas.vscodeRemoteResource,
    network.Schemas.vscodeNotebookCell,
    network.Schemas.internal,
  ];
  if (isTrusted) allowedLinkSchemes.add(network.Schemas.command);
  if (options.allowedLinkSchemes != null) {
    allowedLinkSchemes.addAll(options.allowedLinkSchemes!);
  }

  return <String, Object?>{
    'allowedTags': <String, Object?>{
      'override': options.allowedTags != null
          ? options.allowedTags!()
          : allowedMarkdownHtmlTags,
    },
    'allowedAttributes': <String, Object?>{
      'override': options.allowedAttributes != null
          ? options.allowedAttributes!()
          : allowedMarkdownHtmlAttributes,
    },
    'allowedLinkProtocols': <String, Object?>{'override': allowedLinkSchemes},
    'allowRelativeLinkPaths': config.baseUri != null,
    'allowedMediaProtocols': <String, Object?>{
      'override': <String>[
        network.Schemas.http,
        network.Schemas.https,
        network.Schemas.data,
        network.Schemas.file,
        network.Schemas.vscodeFileResource,
        network.Schemas.vscodeRemote,
        network.Schemas.vscodeRemoteResource,
        ...(options.allowedMediaSchemes ?? <String>[]),
      ],
    },
    'allowRelativeMediaPaths': config.baseUri != null,
    'mediaSourceIsAllowed': remoteImageIsAllowed == null
        ? null
        : (String source) => isMediaSourceAllowed(
            config,
            source,
            remoteImageIsAllowed,
            options.allowedMediaSchemes ?? <String>[]),
    'replaceWithPlaintext': options.replaceWithPlaintext,
  };
}

/// 1:1: `sanitizeRenderedMarkdown(...)`.
String sanitizeRenderedMarkdown(
  String renderedMarkdown,
  MdStrConfig originalMdStrConfig, [
  MarkdownSanitizerConfig? options,
]) {
  final Object config = getDomSanitizerConfig(
      originalMdStrConfig, options ?? MarkdownSanitizerConfig());
  return _sanitize(renderedMarkdown, config);
}

// ---------------------------------------------------------------------------
// renderAsPlaintext
// ---------------------------------------------------------------------------

final Map<String, String> unescapeInfo = Map<String, String>.unmodifiable(
    <String, String>{
  '&quot;': '"',
  '&nbsp;': ' ',
  '&amp;': '&',
  '&#39;': "'",
  '&lt;': '<',
  '&gt;': '>',
});

/// 1:1: `createPlainTextRenderer()`. Configures a marked Renderer object via
/// dynamic field assignment (the injected engine supplies the object).
Object createPlainTextRenderer() {
  final Object renderer = _marked.createRenderer();
  _setFn(renderer, 'code', plainCodeBlock);
  _setFn(renderer, 'blockquote', (Map<String, Object?> t) =>
      ((t['text'] as String?) ?? '') + '\n');
  _setFn(renderer, 'html', (Object t) => '');
  _setFn(renderer, 'heading', (Map<String, Object?> t) {
    final Object parser = _field(renderer, 'parser') ?? Object();
    return _parseInline(parser,
            (t['tokens'] as List<Object?>?) ?? <Object?>[]) +
        '\n';
  });
  _setFn(renderer, 'hr', () => '');
  _setFn(renderer, 'list', (Map<String, Object?> t) {
    final List<Object?> items = (t['items'] as List<Object?>?) ?? <Object?>[];
    return items
            .map((Object? x) =>
                _callRenderListitem(renderer, x as Map<String, Object?>))
            .join('\n') +
        '\n';
  });
  _setFn(renderer, 'listitem', (Map<String, Object?> t) =>
      ((t['text'] as String?) ?? '') + '\n');
  _setFn(renderer, 'paragraph', (Map<String, Object?> t) {
    final Object parser = _field(renderer, 'parser') ?? Object();
    return _parseInline(parser,
            (t['tokens'] as List<Object?>?) ?? <Object?>[]) +
        '\n';
  });
  _setFn(renderer, 'table', (Map<String, Object?> t) {
    final List<Object?> header = (t['header'] as List<Object?>?) ?? <Object?>[];
    final List<Object?> rows = (t['rows'] as List<Object?>?) ?? <Object?>[];
    final String head = header
        .map((Object? c) => _callRenderTablecell(renderer, c as Map<String, Object?>))
        .join(' ');
    final String body = rows
        .map((Object? row) => (row as List<Object?>)
            .map((Object? c) =>
                _callRenderTablecell(renderer, c as Map<String, Object?>))
            .join(' '))
        .join('\n');
    return '$head\n$body\n';
  });
  _setFn(renderer, 'tablerow', (Map<String, Object?> t) =>
      (t['text'] as String?) ?? '');
  _setFn(renderer, 'tablecell', (Map<String, Object?> t) {
    final Object parser = _field(renderer, 'parser') ?? Object();
    return _parseInline(parser,
        (t['tokens'] as List<Object?>?) ?? <Object?>[]);
  });
  _setFn(renderer, 'strong', (Map<String, Object?> t) =>
      (t['text'] as String?) ?? '');
  _setFn(renderer, 'em', (Map<String, Object?> t) =>
      (t['text'] as String?) ?? '');
  _setFn(renderer, 'codespan', (Map<String, Object?> t) =>
      (t['text'] as String?) ?? '');
  _setFn(renderer, 'br', (Object t) => '\n');
  _setFn(renderer, 'del', (Map<String, Object?> t) =>
      (t['text'] as String?) ?? '');
  _setFn(renderer, 'image', (Object t) => '');
  _setFn(renderer, 'text', (Map<String, Object?> t) =>
      (t['text'] as String?) ?? '');
  _setFn(renderer, 'link', (Map<String, Object?> t) =>
      (t['text'] as String?) ?? '');
  return renderer;
}

void _setFn(Object obj, String name, Object fn) {
  if (obj is RendererCarrier) {
    obj.put(name, fn);
  }
}

String _callRenderListitem(Object renderer, Map<String, Object?> token) {
  if (renderer is RendererCarrier) return renderer.callRenderer('listitem', token);
  return ((token['text'] as String?) ?? '') + '\n';
}

String _callRenderTablecell(Object renderer, Map<String, Object?> token) {
  if (renderer is RendererCarrier) return renderer.callRenderer('tablecell', token);
  return '';
}

String plainCodeBlock(Map<String, Object?> token) =>
    strings.escape((token['text'] as String?) ?? '');

String codeBlockFences(Map<String, Object?> token) =>
    '\n\`\`\`\n${strings.escape((token['text'] as String?) ?? '')}\n\`\`\`\n';

String linkFormatter(Map<String, Object?> token) {
  final String text = (token['text'] as String?) ?? '';
  final String href = (token['href'] as String?) ?? '';
  try {
    if (href.isNotEmpty) {
      final uri.URI u = uri.URI.parse(href);
      return text.trim().isNotEmpty ? text.trim() : resources.basename(u);
    }
  } catch (_) {
    return text.trim().isNotEmpty ? text.trim() : pathLib.basename(href);
  }
  return text;
}

/// 1:1: `describedSource(tokens, describe)`.
String? describedSource(
  List<Object?> tokens,
  String? Function(Map<String, Object?> token) describe,
) {
  bool isDescribed = false;
  final String source = tokens.map((Object? obj) {
    final Map<String, Object?> token = obj as Map<String, Object?>;
    String? described;
    final String type = (token['type'] as String?) ?? '';
    if (type == 'code') {
      described = describe(token);
    } else if (type == 'blockquote') {
      described = describedSource(
          (token['tokens'] as List<Object?>?) ?? <Object?>[], describe);
    } else if (type == 'list') {
      final List<Object?> items = (token['items'] as List<Object?>?) ?? <Object?>[];
      final List<Map<String, Object?>> mapped = items
          .map((Object? i) => <String, Object?>{
                'text': (i as Map)['text'],
                'described': describedSource(
                    (i['tokens'] as List<Object?>?) ?? <Object?>[], describe),
              })
          .toList();
      described = mapped.any((Map<String, Object?> i) => i['described'] != null)
          ? mapped
              .map((Map<String, Object?> i) =>
                  '${i['described'] ?? i['text']}\n')
              .join()
          : null;
    }
    isDescribed = isDescribed || described != null;
    return described ?? (token['raw'] as String?) ?? '';
  }).join();
  return isDescribed ? source : null;
}

String parsedListItem(Object parser, Map<String, Object?> token) =>
    _parseTokens(parser, (token['tokens'] as List<Object?>?) ?? <Object?>[], true);

String parsedText(Object parser, Map<String, Object?> token) {
  final Object? toks = token['tokens'];
  if (toks is List<Object?>) return _parseInline(parser, toks);
  return (token['text'] as String?) ?? '';
}

/// 1:1: `mergeRawTokenText(tokens)`.
String mergeRawTokenText(List<Object?> tokens) {
  final StringBuffer sb = StringBuffer();
  for (final Object? t in tokens) {
    if (t is Map && t['raw'] is String) sb.write(t['raw'] as String);
  }
  return sb.toString();
}

// ---------------------------------------------------------------------------
// fillInIncompleteTokens
// ---------------------------------------------------------------------------

bool hasLinkTextAndStartOfLinkTarget(String str) =>
    RegExp(r'(?:^|[\s(*_~])\[.*\]\(\w*').hasMatch(str);

bool hasStartOfLinkTargetAndNoLinkText(String str) =>
    RegExp(r'^[^\[]*\]\([^\)]*$').hasMatch(str);

Map<String, Object?>? completeSingleLinePattern(Map<String, Object?> token) {
  final Object? rawTokens = token['tokens'];
  if (rawTokens is! List<Object?>) return null;
  final List<Object?> tokens = rawTokens;
  for (int i = tokens.length - 1; i >= 0; i--) {
    final Object? obj = tokens[i];
    if (obj is! Map) continue;
    final Map<String, Object?> subtoken = obj.cast<String, Object?>();
    if (subtoken['type'] != 'text') continue;
    final String raw = (subtoken['raw'] as String?) ?? '';
    final List<String> lines = raw.split('\n');
    final String lastLine = lines.last;

    if (hasLinkTextAndStartOfLinkTarget(lastLine) ||
        (hasStartOfLinkTargetAndNoLinkText(lastLine) &&
            tokens.sublist(0, i).any((Object? t) =>
                t is Map &&
                t['type'] == 'text' &&
                RegExp(r'\[[^\]]*$').hasMatch((t['raw'] as String?) ?? '')))) {
      final List<Object?> nextTwo = tokens.sublist(i + 1);
      final bool linkQuoteCase = nextTwo.length >= 2 &&
          nextTwo[0] is Map &&
          (nextTwo[0] as Map)['type'] == 'link' &&
          nextTwo[1] is Map &&
          (nextTwo[1] as Map)['type'] == 'text' &&
          RegExp(r'^ *"[^"]*$')
              .hasMatch(((nextTwo[1] as Map)['raw'] as String?) ?? '');
      final bool loneQuoteCase =
          RegExp(r'^[^"]* +"[^"]*$').hasMatch(lastLine);
      if (linkQuoteCase || loneQuoteCase) {
        return completeLinkTargetArg(token);
      }
      return completeLinkTarget(token);
    } else if (lastLine.contains('`')) {
      return completeCodespan(token);
    } else if (lastLine.contains('**')) {
      return completeDoublestar(token);
    } else if (RegExp(r'\*\w').hasMatch(lastLine)) {
      return completeStar(token);
    } else if (RegExp(r'(^|\s)__\w').hasMatch(lastLine)) {
      return completeDoubleUnderscore(token);
    } else if (RegExp(r'(^|\s)_\w').hasMatch(lastLine)) {
      return completeUnderscore(token);
    } else if (RegExp(r'(^|\s)\[\w*[^\]]*$').hasMatch(lastLine)) {
      return completeLinkText(token);
    }
  }
  return null;
}

Map<String, Object?> completeCodespan(Map<String, Object?> tokens) =>
    completeWithString(tokens, '`');
Map<String, Object?> completeStar(Map<String, Object?> tokens) =>
    completeWithString(tokens, '*');
Map<String, Object?> completeUnderscore(Map<String, Object?> tokens) =>
    completeWithString(tokens, '_');
Map<String, Object?> completeLinkTarget(Map<String, Object?> tokens) =>
    completeWithString(tokens, ')', false);
Map<String, Object?> completeLinkTargetArg(Map<String, Object?> tokens) =>
    completeWithString(tokens, '")', false);
Map<String, Object?> completeLinkText(Map<String, Object?> tokens) =>
    completeWithString(tokens, '](https://microsoft.com)', false);
Map<String, Object?> completeDoublestar(Map<String, Object?> tokens) =>
    completeWithString(tokens, '**');
Map<String, Object?> completeDoubleUnderscore(Map<String, Object?> tokens) =>
    completeWithString(tokens, '__');

Map<String, Object?> completeWithString(
  Object tokens,
  String closingString, [
  bool shouldTrim = true,
]) {
  final List<Object?> list = tokens is List ? tokens : <Object?>[tokens];
  final String merged = mergeRawTokenText(list);
  final String trimmed = shouldTrim ? merged.trimRight() : merged;
  final List<Object?> result = _marked.lexer(trimmed + closingString);
  return result.isNotEmpty
      ? (result[0] as Map).cast<String, Object?>()
      : <String, Object?>{};
}

Map<String, Object?>? completeBlockquotePattern(
  Map<String, Object?> blockquote,
  Map<String, Object?> links,
) {
  final List<Object?> tokens =
      (blockquote['tokens'] as List<Object?>?) ?? <Object?>[];
  int lastInteresting = tokens.length - 1;
  while (lastInteresting >= 0 &&
      (tokens[lastInteresting] is Map &&
          (tokens[lastInteresting] as Map)['type'] == 'space')) {
    lastInteresting--;
  }
  if (lastInteresting < 0) return null;
  final Object? obj = tokens[lastInteresting];
  if (obj is! Map || obj['type'] != 'paragraph') return null;
  final Map<String, Object?> lastToken = obj.cast<String, Object?>();

  final Map<String, Object?>? completed =
      completeSingleLinePattern(lastToken);
  if (completed == null) return null;

  final String completedRaw = (completed['raw'] as String?) ?? '';
  final String lastRaw = (lastToken['raw'] as String?) ?? '';
  final String trimmedLast = lastRaw.trimRight();
  final String completion = completedRaw.length >= trimmedLast.length
      ? completedRaw.substring(trimmedLast.length)
      : '';
  final String bqRaw = (blockquote['raw'] as String?) ?? '';
  final RegExp trailingRe = RegExp(r'(?:\n[ \t]*>[ \t]*(?=\n|$))+\n?$');
  final String trailing = trailingRe.firstMatch(bqRaw)?.group(0) ?? '';
  final int insertion = bqRaw.length - trailing.length;
  final String completedBq = bqRaw.substring(0, insertion) + completion + trailing;

  final Object lexer = _marked.createLexer();
  _setLinksOnLexer(lexer, links);
  final List<Object?> result = _marked.lexInstance(lexer, completedBq);
  if (result.isNotEmpty &&
      (result[0] as Map)['type'] == 'blockquote') {
    return (result[0] as Map).cast<String, Object?>();
  }
  return null;
}

void _setLinksOnLexer(Object lexer, Map<String, Object?> links) {
  try {
    final Object tokens = (lexer as dynamic).tokens;
    (tokens as dynamic).links = links;
  } catch (_) {
    // The injected lexer must expose a mutable `tokens.links`.
  }
}

bool _listEndsInHeading(Map<String, Object?> list) {
  final List<Object?> items = (list['items'] as List<Object?>?) ?? <Object?>[];
  final Object? lastToken = items.isEmpty
      ? null
      : (((items.last as Map)['tokens'] as List<Object?>?) ?? <Object?>[]) ;
  if (lastToken is List<Object?> && lastToken.isNotEmpty) {
    final Object? t = lastToken.last;
    if (t is Map && t['type'] == 'heading') return true;
    if (t is Map && t['type'] == 'list') {
      return _listEndsInHeading(t.cast<String, Object?>());
    }
  }
  return false;
}

Map<String, Object?>? completeListItemPattern(Map<String, Object?> list) {
  final List<Object?> items = (list['items'] as List<Object?>?) ?? <Object?>[];
  if (items.isEmpty) return null;
  final Map<String, Object?> lastItem = (items.last as Map).cast<String, Object?>();
  final Object? sub = lastItem['tokens'];
  final Object? lastSub = sub is List<Object?> && sub.isNotEmpty ? sub.last : null;

  Map<String, Object?>? newToken;
  if (lastSub is Map &&
      lastSub['type'] == 'text' &&
      !lastItem.containsKey('inRawBlock')) {
    newToken = completeSingleLinePattern(lastSub.cast<String, Object?>());
  } else if (_listEndsInHeading(list)) {
    final String raw = (list['raw'] as String?) ?? '';
    final List<Object?> newList = _marked.lexer('${raw.trim()} &nbsp;');
    if (newList.isEmpty || (newList[0] as Map)['type'] != 'list') return null;
    return (newList[0] as Map).cast<String, Object?>();
  }
  if (newToken == null || newToken['type'] != 'paragraph') return null;

  final String previous = mergeRawTokenText(items.sublist(0, items.length - 1));
  final String lastRaw = (lastItem['raw'] as String?) ?? '';
  final String? lead = RegExp(r'^(\s*(-|\d+\.|\*) +)').firstMatch(lastRaw)?.group(1);
  if (lead == null) return null;

  final Object? subTokens = lastItem['tokens'];
  final String before = subTokens is List<Object?>
      ? mergeRawTokenText(subTokens.sublist(0, subTokens.length - 1))
      : '';
  final String newItemText = lead + before + (newToken['raw'] as String? ?? '');
  final List<Object?> newList = _marked.lexer(previous + newItemText);
  if (newList.isEmpty || (newList[0] as Map)['type'] != 'list') return null;
  return (newList[0] as Map).cast<String, Object?>();
}

List<Object?>? completeHeading(
  Map<String, Object?> token,
  String fullRawText,
) {
  final String raw = (token['raw'] as String?) ?? '';
  if (RegExp(r'-\s*$').hasMatch(raw)) {
    return _marked.lexer('$fullRawText &nbsp;');
  }
  return null;
}

const int maxIncompleteTokensFixRounds = 3;

/// 1:1: `fillInIncompleteTokens(tokens)`.
List<Object?> fillInIncompleteTokens(List<Object?> tokens) {
  for (int i = 0; i < maxIncompleteTokensFixRounds; i++) {
    final List<Object?>? next = fillInIncompleteTokensOnce(tokens);
    if (next != null) {
      tokens = next;
    } else {
      break;
    }
  }
  return tokens;
}

List<Object?>? fillInIncompleteTokensOnce(List<Object?> tokens) {
  int i = 0;
  List<Object?>? newTokens;

  final Map<String, Object?> links = _linksOf(tokens);
  for (i = 0; i < tokens.length; i++) {
    final Object? obj = tokens[i];
    if (obj is Map &&
        obj['type'] == 'paragraph' &&
        RegExp(r'(\n|^)\|').hasMatch((obj['raw'] as String?) ?? '')) {
      newTokens = completeTable(tokens.sublist(i));
      break;
    }
  }

  int lastInteresting = tokens.length - 1;
  while (lastInteresting >= 0) {
    final Object? t = tokens[lastInteresting];
    if (t is Map && (t['type'] == 'space' || t['type'] == 'html')) {
      lastInteresting--;
    } else {
      break;
    }
  }
  final Object? interestingObj =
      lastInteresting >= 0 ? tokens[lastInteresting] : null;
  final Map<String, Object?>? interesting =
      interestingObj is Map ? interestingObj.cast<String, Object?>() : null;
  final List<Object?> trailing = tokens.sublist(lastInteresting + 1);

  if (newTokens == null && interesting != null && interesting['type'] == 'list') {
    final Map<String, Object?>? newList = completeListItemPattern(interesting);
    if (newList != null) {
      newTokens = <Object?>[newList, ...trailing];
      i = lastInteresting;
    }
  }
  if (newTokens == null &&
      interesting != null &&
      interesting['type'] == 'blockquote') {
    final Map<String, Object?>? newBq =
        completeBlockquotePattern(interesting, links);
    if (newBq != null) {
      newTokens = <Object?>[newBq, ...trailing];
      i = lastInteresting;
    }
  }
  if (newTokens == null &&
      interesting != null &&
      interesting['type'] == 'paragraph') {
    final Map<String, Object?>? newToken =
        completeSingleLinePattern(interesting);
    if (newToken != null) {
      newTokens = <Object?>[newToken, ...trailing];
      i = lastInteresting;
    }
  }

  if (newTokens != null) {
    final List<Object?> result = <Object?>[...tokens.sublist(0, i), ...newTokens];
    _setLinksOnList(result, links);
    return result;
  }

  final Object? last = tokens.isEmpty ? null : tokens.last;
  if (last is Map && last['type'] == 'heading') {
    final List<Object?>? complete =
        completeHeading(last.cast<String, Object?>(), mergeRawTokenText(tokens));
    if (complete != null) return complete;
  }
  return null;
}

Map<String, Object?> _linksOf(List<Object?> tokens) {
  try {
    final dynamic d = tokens;
    final Object? links = d.links;
    if (links is Map) return links.cast<String, Object?>();
  } catch (_) {}
  return <String, Object?>{};
}

void _setLinksOnList(List<Object?> tokens, Map<String, Object?> links) {
  try {
    (tokens as dynamic).links = links;
  } catch (_) {}
}

List<Object?>? completeTable(List<Object?> tokens) {
  final String merged = mergeRawTokenText(tokens);
  final List<String> lines = merged.split('\n');
  int? numCols;
  bool hasSeparator = false;
  for (int i = 0; i < lines.length; i++) {
    final String line = lines[i].trim();
    if (numCols == null && RegExp(r'^\s*\|').hasMatch(line)) {
      final Iterable<RegExpMatch> matches =
          RegExp(r'(\|[^\|]+)(?=\||$)').allMatches(line);
      if (matches.isNotEmpty) numCols = matches.length;
    } else if (numCols != null) {
      if (RegExp(r'^\s*\|').hasMatch(line)) {
        if (i != lines.length - 1) return null;
        hasSeparator = true;
      } else {
        return null;
      }
    }
  }
  if (numCols != null && numCols > 0) {
    final String prefix = hasSeparator ? lines.sublist(0, lines.length - 1).join('\n') : merged;
    final bool endsInPipe = RegExp(r'\|\s*$').hasMatch(prefix);
    final String newRaw = prefix +
        (endsInPipe ? '' : '|') +
        '\n|${' --- |' * numCols}';
    return _marked.lexer(newRaw);
  }
  return null;
}

// ---------------------------------------------------------------------------
// renderAsPlaintext
// ---------------------------------------------------------------------------

class PlainTextRenderOptions {
  PlainTextRenderOptions({
    this.includeCodeBlocksFences,
    this.useLinkFormatter,
    this.omitMarkdownSyntax,
    this.codeBlockText,
  });
  final bool? includeCodeBlocksFences;
  final bool? useLinkFormatter;
  final bool? omitMarkdownSyntax;
  final String? Function(String languageId, String text, String raw)? codeBlockText;
}

/// 1:1: `renderAsPlaintext(str, options?)`.
String renderAsPlaintext(Object str, [PlainTextRenderOptions? options]) {
  if (str is String) return str;

  String value = (_field(str, 'value') as String?) ?? '';
  if (value.length > 100000) value = '${value.substring(0, 100000)}…';

  final Object renderer = createPlainTextRenderer();
  if (options?.includeCodeBlocksFences == true) {
    _setFn(renderer, 'code', codeBlockFences);
  }
  final String? Function(String, String, String)? codeBlockText =
      options?.codeBlockText;
  if (codeBlockText != null) {
    final Object Function(Map<String, Object?> token) renderCode =
        options?.includeCodeBlocksFences == true
            ? (t) => codeBlockFences(t)
            : (t) => plainCodeBlock(t);
    String? describe(Map<String, Object?> token) {
      final String? text = codeBlockText(
        postProcessCodeBlockLanguageId(token['lang'] as String?),
        (token['text'] as String?) ?? '',
        (token['raw'] as String?) ?? '',
      );
      return text == null || text.isEmpty
          ? null
          : '\n${strings.escape(text)}\n';
    }
    _setFn(renderer, 'code', (Map<String, Object?> t) {
      final String? d = describe(t);
      return d ?? renderCode(t);
    });
    _setFn(renderer, 'listitem', (Map<String, Object?> t) {
      final String? d = describedSource(
          (t['tokens'] as List<Object?>?) ?? <Object?>[], describe);
      return '${d ?? (t['text'] as String? ?? '')}\n';
    });
    _setFn(renderer, 'blockquote', (Map<String, Object?> t) {
      final String? d = describedSource(
          (t['tokens'] as List<Object?>?) ?? <Object?>[], describe);
      return '${d ?? (t['text'] as String? ?? '')}\n';
    });
  }
  if (options?.useLinkFormatter == true) {
    _setFn(renderer, 'link', linkFormatter);
  }
  if (options?.omitMarkdownSyntax == true) {
    final Object parser = _field(renderer, 'parser') ?? Object();
    _setFn(renderer, 'listitem', (Map<String, Object?> t) =>
        parsedListItem(parser, t));
    _setFn(renderer, 'text', (Map<String, Object?> t) => parsedText(parser, t));
  }

  final String html = _marked.parse(value, renderer: renderer, async: false);
  final String sanitized = sanitizeRenderedMarkdown(
      html, MdStrConfig(isTrusted: false), MarkdownSanitizerConfig());
  return sanitized
      .replaceAllMapped(RegExp(r'&(#\d+|[a-zA-Z]+);'),
          (Match m) => unescapeInfo[m.group(0)] ?? m.group(0)!)
      .trim();
}

// ---------------------------------------------------------------------------
// renderMarkdown (DOM orchestration)
// ---------------------------------------------------------------------------

class RenderedMarkdown implements lifecycle.IDisposable {
  RenderedMarkdown(this.element, this._disposeFn);
  final Object element;
  final void Function() _disposeFn;
  bool _disposed = false;
  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _disposeFn();
  }
}

/// 1:1: `renderMarkdown(markdown, options?, target?)`.
RenderedMarkdown renderMarkdown(
  Object markdown, [
  MarkdownRenderOptions? optionsRaw,
  Object? target,
]) {
  final MarkdownRenderOptions options = optionsRaw ?? MarkdownRenderOptions();
  final lifecycle.DisposableStore disposables = lifecycle.DisposableStore();
  bool isDisposed = false;

  final List<Object?> extensions = options.markedExtensions ?? <Object?>[];
  final Object instance = _marked.createMarkedInstance(extensions);
  final Map<String, Object?> ctx = createMarkdownRenderer(instance, options, markdown);
  final Object renderer = ctx['renderer']!;
  final List<Map<String, Object?>> codeBlocks =
      (ctx['codeBlocks'] as List?)?.cast<Map<String, Object?>>() ?? <Map<String, Object?>>[];
  final List<Map<String, Object?>> syncCodeBlocks =
      (ctx['syncCodeBlocks'] as List?)?.cast<Map<String, Object?>>() ?? <Map<String, Object?>>[];
  final String value = preprocessMarkdownString(markdown);

  late String renderedMarkdown;
  if (options.fillInIncompleteTokens == true) {
    final Object defaults = _marked.instanceDefaults(instance) ?? <String, Object?>{};
    final Object opts = <String, Object?>{
      ..._asMap(defaults),
      ...?_asMapOrNull(options.markedOptions),
      'renderer': renderer,
    };
    final List<Object?> tokens = _marked.instanceLexer(instance, value, opts);
    final List<Object?> newTokens = fillInIncompleteTokens(tokens);
    final Object? walk = _asMap(opts)['walkTokens'];
    if (walk != null) {
      _marked.instanceWalkTokens(instance, newTokens, walk);
    }
    renderedMarkdown = _marked.instanceParser(instance, newTokens, opts);
  } else {
    final Object opts = <String, Object?>{
      ...?_asMapOrNull(options.markedOptions),
      'renderer': renderer,
      'async': false,
    };
    renderedMarkdown = _marked.instanceParse(instance, value, opts);
  }

  if (_readBool(markdown, 'supportThemeIcons')) {
    final RenderLabelWithIcons? fn = _renderLabelWithIcons;
    if (fn != null) {
      renderedMarkdown = fn(renderedMarkdown)
          .map((Object e) => e is String ? e : (_field(e, 'outerHTML') as String? ?? ''))
          .join();
    }
  }

  final Object content = _dom.createElement('div');
  final Object config = getDomSanitizerConfig(
      MdStrConfig(
        isTrusted: _field(markdown, 'isTrusted') as bool?,
        baseUri: _field(markdown, 'baseUri'),
        uris: (_field(markdown, 'uris') as Map?)?.cast<String, Object?>(),
      ),
      options.sanitizerConfig ?? MarkdownSanitizerConfig());
  final SafeSetInnerHtml? safe = _safeSetInnerHtml;
  if (safe != null) {
    safe(content, renderedMarkdown, config);
  }

  rewriteRenderedLinks(markdown, options, content, disposables);

  late Object outElement;
  if (target != null) {
    outElement = target;
    final bool containsSync = syncCodeBlocks.any((Map<String, Object?> pair) =>
        _domContains(target, pair['element']!));
    if (containsSync) {
      replaceChildrenPreservingCodeBlocks(
          target, content, syncCodeBlocks.cast<Map<String, Object?>>());
    } else {
      _dom.reset(target, _dom.getChildNodes(content));
    }
  } else {
    outElement = content;
  }

  if (codeBlocks.isNotEmpty) {
    // Async code blocks: mirror source with a Future chain.
    Future<List<Map<String, Object?>>>.value(codeBlocks).then((List<Map<String, Object?>> tuples) {
      if (isDisposed) return;
      final Map<String, Object?> rendered = <String, Object?>{
        for (final Map<String, Object?> t in tuples) t['id'] as String: t['element']
      };
      for (final Object placeholder in _dom.querySelectorAll(outElement, 'div[data-code]')) {
        final Object? el = rendered[_dom.getDataset(placeholder, 'code') ?? ''];
        if (el != null) _dom.reset(placeholder, <Object>[el]);
      }
      options.asyncRenderCallback?.call();
    });
  } else if (syncCodeBlocks.isNotEmpty) {
    final Map<String, Object?> rendered = <String, Object?>{
      for (final Map<String, Object?> t in syncCodeBlocks) t['id'] as String: t['element']
    };
    for (final Object placeholder in _dom.querySelectorAll(outElement, 'div[data-code]')) {
      final Object? el = rendered[_dom.getDataset(placeholder, 'code') ?? ''];
      if (el != null) _dom.reset(placeholder, <Object>[el]);
    }
  }

  if (options.asyncRenderCallback != null) {
    for (final Object img in _dom.getElementsByTagName(outElement, 'img')) {
      final _DisposeWrapper listener = disposables.add<_DisposeWrapper>(_DisposeWrapper(() {}));
      _dom.addDisposableListener(img, 'load', (Object e) {
        listener.disposeSafe();
        options.asyncRenderCallback!();
      });
    }
  }

  if (options.actionHandler != null) {
    void clickCb(Object e) {
      final Object mouse = _dom.createMouseEvent(_dom.getWindow(outElement), e);
      if (!_dom.getLeftButton(mouse) && !_dom.getMiddleButton(mouse)) return;
      activateLink(markdown, options, mouse);
    }
    _dom.addDisposableListener(outElement, 'click', clickCb);
    _dom.addDisposableListener(outElement, 'auxclick', clickCb);
    _dom.addDisposableListener(outElement, 'keydown', (Object e) {
      final Object keyboard = _dom.createKeyboardEvent(e);
      if (!_dom.keyEquals(keyboard, keyCodes.KeyCode.Space) &&
          !_dom.keyEquals(keyboard, keyCodes.KeyCode.Enter)) {
        return;
      }
      activateLink(markdown, options, keyboard);
    });
  }

  for (final Object input in _dom.getElementsByTagName(outElement, 'input')) {
    if (_dom.getAttribute(input, 'type') == 'checkbox') {
      _dom.setAttribute(input, 'disabled', '');
    } else {
      final Object? replacement =
          options.sanitizerConfig?.replaceWithPlaintext == true
              ? _dom.convertTagToPlaintext(input)
              : null;
      if (replacement != null) {
        final Object? parent = _dom.getParent(input);
        if (parent != null) _dom.replaceWith(replacement, <Object>[input]);
      } else {
        final Object? parent = _dom.getParent(input);
        if (parent != null) _dom.removeChild(parent, input);
      }
    }
  }

  return RenderedMarkdown(outElement, () {
    isDisposed = true;
    disposables.dispose();
  });
}

bool _domContains(Object parent, Object child) {
  Object? cur = child;
  while (cur != null) {
    if (identical(cur, parent)) return true;
    cur = _dom.getParent(cur);
  }
  return false;
}

Map<String, Object?> _asMap(Object? o) =>
    o is Map ? o.cast<String, Object?>() : <String, Object?>{};
Map<String, Object?>? _asMapOrNull(Object? o) =>
    o is Map ? o.cast<String, Object?>() : null;

class _DisposeWrapper implements lifecycle.IDisposable {
  _DisposeWrapper(this._fn);
  final void Function() _fn;
  bool _done = false;
  @override
  void dispose() => disposeSafe();
  void disposeSafe() {
    if (_done) return;
    _done = true;
    _fn();
  }
}

/// 1:1: `createMarkdownRenderer(marked, options, markdown)`.
Map<String, Object?> createMarkdownRenderer(
  Object instance,
  MarkdownRenderOptions options,
  Object markdown,
) {
  final Object renderer = _marked.instanceRenderer(instance, options.markedOptions);
  _setFn(renderer, 'image', (Map<String, Object?> t) =>
      renderImage(t, (String href) => options.transformUri != null
          ? options.transformUri!(href, 'image')
          : href));
  _setFn(renderer, 'link', (Map<String, Object?> t) {
    final Map<String, Object?> next = Map<String, Object?>.from(t);
    next['href'] = options.transformUri != null
        ? options.transformUri!(t['href'] as String? ?? '', 'link')
        : (t['href'] as String? ?? '');
    return defaultRenderLink(renderer, next);
  });
  _setFn(renderer, 'paragraph', (Map<String, Object?> t) =>
      defaultRenderParagraph(_field(renderer, 'parser') ?? Object(), t));

  if (_readBool(markdown, 'supportAlertSyntax')) {
    final Object? current = _getFn(renderer, 'blockquote');
    _setFn(renderer, 'blockquote',
        createAlertBlockquoteRenderer(current ?? Object(), renderer));
  }

  final List<Map<String, Object?>> codeBlocks = <Map<String, Object?>>[];
  final List<Map<String, Object?>> syncCodeBlocks = <Map<String, Object?>>[];

  final Object Function(String, String, [String?])? syncRenderer =
      options.codeBlockRendererSync;
  if (syncRenderer != null) {
    _setFn(renderer, 'code', (Map<String, Object?> t) {
      final String id = idGenerator.defaultGenerator.nextId();
      final Object value = syncRenderer(
        postProcessCodeBlockLanguageId(t['lang'] as String?),
        (t['text'] as String?) ?? '',
        t['raw'] as String?,
      );
      syncCodeBlocks.add(<String, Object?>{'id': id, 'element': value});
      return '<div class="code" data-code="$id">${strings.escape((t['text'] as String?) ?? '')}</div>';
    });
  } else if (options.codeBlockRenderer != null) {
    _setFn(renderer, 'code', (Map<String, Object?> t) {
      final String id = idGenerator.defaultGenerator.nextId();
      final Future<Object> value = options.codeBlockRenderer!(
        postProcessCodeBlockLanguageId(t['lang'] as String?),
        (t['text'] as String?) ?? '',
      );
      codeBlocks.add(<String, Object?>{
        'id': id,
        'future': value.then((Object el) => <String, Object?>{'id': id, 'element': el}),
      });
      return '<div class="code" data-code="$id">${strings.escape((t['text'] as String?) ?? '')}</div>';
    });
  }

  if (!_readBool(markdown, 'supportHtml')) {
    _setFn(renderer, 'html', (Map<String, Object?> t) {
      final String text = (t['text'] as String?) ?? '';
      if (options.sanitizerConfig?.replaceWithPlaintext == true) {
        return strings.escape(text);
      }
      if (_readBool(markdown, 'isTrusted')) {
        final RegExp m = RegExp(r'^(<span[^>]+>)|(<\/\s*span>)$');
        return m.hasMatch(text) ? text : '';
      }
      return '';
    });
  }

  return <String, Object?>{
    'renderer': renderer,
    'codeBlocks': codeBlocks,
    'syncCodeBlocks': syncCodeBlocks,
  };
}

Object? _getFn(Object obj, String name) {
  if (obj is RendererCarrier) return obj.get(name);
  return null;
}

/// 1:1: `rewriteRenderedLinks(markdown, options, root, disposables)`.
void rewriteRenderedLinks(
  Object markdown,
  MarkdownRenderOptions options,
  Object root,
  lifecycle.DisposableStore disposables,
) {
  for (final Object el in _dom.querySelectorAll(root, 'img, audio, video, source')) {
    final String? src = _dom.getAttribute(el, 'src');
    if (src == null || src.isEmpty) continue;
    String href = src;
    try {
      final Object? baseUri = _field(markdown, 'baseUri');
      if (baseUri != null) {
        href = htmlContent.resolveWithBaseUri(
            uri.URI.from(baseUri as dynamic), href);
      }
    } catch (_) {}
    final uri.URI? revived = _reviveUri(
        _readMap((_field(markdown, 'uris') as Map?)?.cast<String, Object?>(), href));
    final uri.URI u = revived ?? uri.URI.parse(href);
    if (!network.matchesSomeScheme(u, <String>[network.Schemas.http,
        network.Schemas.https, network.Schemas.data])) {
      _dom.setAttribute(el, 'data-src', u.toString());
    }
    final Object? resolved = network.FileAccess.resolveBrowserUri(u);
    if (resolved == null) {
      _dom.setAttribute(el, 'src', massageHref(markdown, href, true));
    }
  }

  for (final Object el in _dom.querySelectorAll(root, 'a')) {
    final String? href = _dom.getAttribute(el, 'href');
    _dom.setAttribute(el, 'href', '');
    if (href == null ||
        RegExp(r'^data:|javascript:', caseSensitive: false).hasMatch(href) ||
        (RegExp(r'^command:', caseSensitive: false).hasMatch(href) &&
            _readBool(markdown, 'isTrusted') != true) ||
        RegExp(r'^command:(\/\/\/)?_workbench\.downloadResource',
                caseSensitive: false)
            .hasMatch(href)) {
      _dom.replaceWith(el, _dom.getChildNodes(el));
    } else {
      String resolved = massageHref(markdown, href, false);
      final Object? baseUri = _field(markdown, 'baseUri');
      if (baseUri != null) {
        resolved = htmlContent.resolveWithBaseUri(uri.URI.from(baseUri as dynamic), href);
      }
      _dom.setDataset(el, 'href', resolved);
      if (options.actionHandler != null && htmlContent.isPortableLinkTarget(resolved)) {
        _dom.setAttribute(el, 'href', resolved);
      }
    }
  }
}

/// 1:1: `replaceChildrenPreservingCodeBlocks(...)`.
void replaceChildrenPreservingCodeBlocks(
  Object target,
  Object source,
  List<Map<String, Object?>> codeBlocks,
) {
  final Map<String, Object?> rendered = <String, Object?>{
    for (final Map<String, Object?> p in codeBlocks) p['id'] as String: p['element']
  };
  final Map<Object, Object> replacements = collection.HashMap<Object, Object>.identity();
  final Map<Object, Object> existingToNew = collection.HashMap<Object, Object>.identity();
  final Set<Object> preserved = collection.HashSet<Object>.identity();

  for (final Object placeholder in _dom.querySelectorAll(source, 'div[data-code]')) {
    final Object? el = rendered[_dom.getDataset(placeholder, 'code') ?? ''];
    if (el == null || !_domContains(target, el)) continue;
    Object? existing = _dom.getParent(el);
    if (existing == null ||
        !_dom.hasAttribute(existing, 'data-code') ||
        _dom.getChildNodes(existing).length != 1) {
      continue;
    }
    Object? incoming = placeholder;
    final List<List<Object>> ancestors = <List<Object>>[];
    while (existing != null &&
        incoming != null &&
        !identical(existing, target) &&
        !identical(incoming, source) &&
        _dom.getTagName(existing) == _dom.getTagName(incoming) &&
        (!replacements.containsKey(incoming) ||
            identical(replacements[incoming], existing)) &&
        (!existingToNew.containsKey(existing) ||
            identical(existingToNew[existing], incoming))) {
      ancestors.add(<Object>[incoming, existing]);
      existing = _dom.getParent(existing);
      incoming = _dom.getParent(incoming);
    }
    if (identical(existing, target) && identical(incoming, source)) {
      for (final List<Object> pair in ancestors) {
        replacements[pair[0]] = pair[1];
        existingToNew[pair[1]] = pair[0];
      }
      preserved.add(placeholder);
    }
  }

  if (replacements.isEmpty) {
    _dom.reset(target, _dom.getChildNodes(source));
    return;
  }

  void updateChildren(Object parent, Object newParent) {
    final List<Object> children = _dom.getChildNodes(newParent).map((Object child) {
      if (!_dom.isHTMLElement(child)) return child;
      final Object? replacement = replacements[child];
      if (replacement == null) return child;
      for (final String name in _dom.getAttributeNames(replacement)) {
        if (!_dom.hasAttribute(child, name)) _dom.removeAttribute(replacement, name);
      }
      _dom.copyAttributes(child, replacement);
      if (!preserved.contains(child)) updateChildren(replacement, child);
      return replacement;
    }).toList();
    final Set<Object> retained = collection.HashSet<Object>.identity()..addAll(children);
    for (final Object child in _dom.getChildNodes(parent).toList()) {
      if (!retained.contains(child)) _dom.removeChild(parent, child);
    }
    Object? cursor = _dom.getFirstChild(parent);
    for (final Object child in children) {
      if (identical(cursor, child)) {
        cursor = _dom.getNextSibling(cursor!);
      } else {
        _dom.insertBefore(parent, child, cursor);
      }
    }
  }

  updateChildren(target, source);
}

/// 1:1: `activateLink(mdStr, options, event)`.
void activateLink(Object mdStr, MarkdownRenderOptions options, Object event) {
  final Object? rawTarget = _dom.getTarget(event);
  Object? target = rawTarget != null ? _dom.closest(rawTarget, 'a[data-href]') : null;
  if (target == null || !_dom.isHTMLElement(target)) return;
  try {
    String? href = _dom.getDataset(target, 'href');
    if (href != null && href.isNotEmpty) {
      final Object? baseUri = _field(mdStr, 'baseUri');
      if (baseUri != null) {
        href = htmlContent.resolveWithBaseUri(uri.URI.from(baseUri as dynamic), href);
      }
      options.actionHandler?.call(href, mdStr);
    }
  } catch (err) {
    errors.onUnexpectedError(err);
  } finally {
    _dom.preventDefault(event);
    _dom.stopPropagation(event);
  }
}
