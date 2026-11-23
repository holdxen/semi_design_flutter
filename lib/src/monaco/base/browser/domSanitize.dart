// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/browser/domSanitize.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// JS carriers:
//   - DOMPurify (third-party JS) -> injectable `dompurifyProvider` /
//     `DomPurifyApi` with config carried as `Map<String, Object?>`.
//   - `TrustedHTML` -> `Object?` carrier.
//   - `Node` -> `dom.DomNode`; `Element` -> `dom.DomElement`.
//   - `DocumentFragment` -> `dom.DomNode` with `DOCUMENT_FRAGMENT_NODE`.
//   - `new URL(value, base)` -> `_urlProtocol` via `Uri.parse`.
//   - `Object.freeze([...])` -> `List.unmodifiable([...])`.
//   - `dom.reset` -> injectable `resetProvider` (defaults to `dom.reset`).
// ---------------------------------------------------------------------------

import '../common/network.dart' as network;
import 'dom.dart' as dom;
import 'trustedTypes.dart' as trustedTypes;

/// 1:1: `export const basicMarkupHtmlTags = Object.freeze([...])`.
final List<String> basicMarkupHtmlTags = List<String>.unmodifiable(<String>[
  'a', 'abbr', 'b', 'bdo', 'blockquote', 'br', 'caption', 'cite', 'code',
  'col', 'colgroup', 'dd', 'del', 'details', 'dfn', 'div', 'dl', 'dt', 'em',
  'figcaption', 'figure', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'hr', 'i',
  'img', 'ins', 'kbd', 'label', 'li', 'mark', 'ol', 'p', 'pre', 'q', 'rp',
  'rt', 'ruby', 's', 'samp', 'small', 'small', 'source', 'span', 'strike',
  'strong', 'sub', 'summary', 'sup', 'table', 'tbody', 'td', 'tfoot', 'th',
  'thead', 'time', 'tr', 'tt', 'u', 'ul', 'var', 'video', 'wbr',
]);

/// 1:1: `export const defaultAllowedAttrs = Object.freeze([...])`.
final List<String> defaultAllowedAttrs = List<String>.unmodifiable(<String>[
  'href', 'target', 'src', 'alt', 'title', 'for', 'name', 'role', 'tabindex',
  'x-dispatch', 'required', 'checked', 'placeholder', 'type', 'start', 'width',
  'height', 'align',
]);

const String _fakeRelativeUrlProtocol = 'vscode-relative-path';

/// 1:1: `interface AllowedLinksConfig`.
class AllowedLinksConfig {
  AllowedLinksConfig({required this.override, required this.allowRelativePaths});

  /// `'*'` or a list of protocols.
  final Object override;
  final bool allowRelativePaths;
}

/// 1:1: `new URL(value, fakeRelativeUrlProtocol + '://').protocol`.
String _urlProtocol(String value) {
  try {
    final Uri url = Uri.parse(value);
    final String scheme = url.scheme;
    return scheme.isEmpty ? '$_fakeRelativeUrlProtocol:' : '$scheme:';
  } catch (_) {
    throw const FormatException('Invalid URL');
  }
}

/// 1:1: `validateLink(value, allowedProtocols)`.
bool validateLink(String value, AllowedLinksConfig allowedProtocols) {
  if (allowedProtocols.override == '*') return true;

  try {
    final String protocol = _urlProtocol(value);
    final String bare = protocol.replaceFirst(RegExp(r':$'), '');
    final Object override = allowedProtocols.override;
    if (override is List && override.contains(bare)) return true;

    if (allowedProtocols.allowRelativePaths &&
        protocol == '$_fakeRelativeUrlProtocol:' &&
        !value.trim().toLowerCase().startsWith(_fakeRelativeUrlProtocol)) {
      return true;
    }
    return false;
  } catch (_) {
    return false;
  }
}

/// 1:1: DOMPurify hook signature (args mirror the JS hook argument list).
typedef DomPurifyHook = void Function(List<Object?> args);

/// 1:1: injectable DOMPurify module carrier.
class DomPurifyApi {
  DomPurifyApi({
    required this.addHook,
    required this.removeAllHooks,
    required this.sanitize,
  });

  final void Function(String name, DomPurifyHook hook) addHook;
  final void Function() removeAllHooks;
  final Object Function(String html, Map<String, Object?> config) sanitize;
}

/// Injection hook for the third-party DOMPurify module (no Dart equivalent).
DomPurifyApi? dompurifyProvider;

DomPurifyApi _purify() {
  final DomPurifyApi? api = dompurifyProvider;
  if (api == null) {
    throw StateError('dompurifyProvider must be set before sanitizing HTML');
  }
  return api;
}

/// Injection hook for `reset` (defaults to `dom.reset`).
void Function(dom.DomElement parent, List<Object> children)? resetProvider;

void _reset(dom.DomElement parent, List<Object> children) {
  final void Function(dom.DomElement, List<Object>)? provider = resetProvider;
  if (provider != null) {
    provider(parent, children);
    return;
  }
  dom.reset(parent, children);
}

/// 1:1: `export type SanitizeAttributePredicate`.
typedef SanitizeAttributePredicate = Object Function(
    dom.DomElement node, Map<String, Object?> data);

/// 1:1: `export interface SanitizeAttributeRule`.
class SanitizeAttributeRule {
  SanitizeAttributeRule({
    required this.attributeName,
    required this.shouldKeep,
  });

  final String attributeName;
  final SanitizeAttributePredicate shouldKeep;
}

/// 1:1: `export interface DomSanitizerConfig`.
class DomSanitizerConfig {
  DomSanitizerConfig({
    this.allowedTags,
    this.allowedAttributes,
    this.allowedLinkProtocols,
    this.allowRelativeLinkPaths,
    this.allowedMediaProtocols,
    this.allowRelativeMediaPaths,
    this.mediaSourceIsAllowed,
    this.replaceWithPlaintext,
  });

  final Map<String, Object?>? allowedTags;
  final Map<String, Object?>? allowedAttributes;
  final Map<String, Object?>? allowedLinkProtocols;
  final bool? allowRelativeLinkPaths;
  final Map<String, Object?>? allowedMediaProtocols;
  final bool? allowRelativeMediaPaths;
  final bool Function(String source)? mediaSourceIsAllowed;
  final bool? replaceWithPlaintext;
}

final Map<String, Object?> _defaultDomPurifyConfig =
    Map<String, Object?>.unmodifiable(<String, Object?>{
  'ALLOWED_TAGS': List<String>.from(basicMarkupHtmlTags),
  'ALLOWED_ATTR': List<String>.from(defaultAllowedAttrs),
  'ALLOW_UNKNOWN_PROTOCOLS': true,
});

/// 1:1: `sanitizeHtml(untrusted, config?)`.
Object sanitizeHtml(String untrusted, [DomSanitizerConfig? config]) =>
    _doSanitizeHtml(untrusted, config, 'trusted');

/// 1:1: `sanitizeSurvivingStalePolicy` sanitize callback.
typedef SanitizeCall = Object Function(String html, Map<String, Object?> config);

int _stalePolicyReplacementCount = 0;

/// 1:1: `export function sanitizeSurvivingStalePolicy(...)`.
Object sanitizeSurvivingStalePolicy(
  String untrusted,
  Map<String, Object?> config, [
  SanitizeCall? sanitize,
]) {
  final SanitizeCall call = sanitize ??
      ((String html, Map<String, Object?> cfg) =>
          _purify().sanitize(html, cfg));
  try {
    return call(untrusted, config);
  } catch (error) {
    if (!_isStaleTrustedTypesPolicy(error)) rethrow;
    final Object? replacement = trustedTypes.createTrustedTypesPolicy(
      'domSanitize${_stalePolicyReplacementCount++}',
      <String, Object?>{
        'createHTML': (String value) => value,
        'createScriptURL': (String value) => value,
      },
    );
    if (replacement == null) rethrow;
    final Map<String, Object?> next = Map<String, Object?>.from(config)
      ..['TRUSTED_TYPES_POLICY'] = replacement;
    return call(untrusted, next);
  }
}

/// 1:1: `isStaleTrustedTypesPolicy(error)`.
bool _isStaleTrustedTypesPolicy(Object error) =>
    error is Error &&
    RegExp(r'no longer runnable', caseSensitive: false)
        .hasMatch(error.toString());

const int _commentNode = 8;

/// 1:1: `export function convertTagToPlaintext(node)`.
dom.DomNode? convertTagToPlaintext(Object? node) {
  final dom.DomNode? n = node is dom.DomNode ? node : null;
  if (n == null || n.ownerDocument == null) return null;
  final dom.DomDocument doc = n.ownerDocument!;

  late String startTagText;
  String? endTagText;
  if (n.nodeType == _commentNode) {
    startTagText = '<!--${(n as dynamic).textContent as String}-->';
  } else if (n is dom.DomElement) {
    final String tagName = n.localName.toLowerCase();
    final bool isSelfClosing = _selfClosingTags.contains(tagName);
    final List<MapEntry<String, String>> attrs = n.attributes;
    final String attrString = attrs.isEmpty
        ? ''
        : ' ' + attrs.map((e) => '${e.key}="${e.value}"').join(' ');
    startTagText = '<$tagName$attrString>';
    if (!isSelfClosing) endTagText = '</$tagName>';
  } else {
    return null;
  }

  final dom.DomNode fragment =
      dom.DomNode(dom.DomNode.DOCUMENT_FRAGMENT_NODE)..ownerDocument = doc;
  fragment.appendChild(doc.createTextNode(startTagText));
  while (n.firstChild != null) {
    fragment.appendChild(n.firstChild!);
  }
  if (endTagText != null) {
    fragment.appendChild(doc.createTextNode(endTagText));
  }
  return fragment;
}

const List<String> _selfClosingTags = <String>[
  'area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'input',
  'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr',
];

/// 1:1: `replaceWithPlainTextHook`.
void _replaceWithPlainTextHook(List<Object?> args) {
  final dom.DomNode node = args[0] as dom.DomNode;
  final Map<String, Object?> data = args[1] as Map<String, Object?>;
  final Map<String, Object?> allowedTags =
      (data['allowedTags'] as Map?)?.cast<String, Object?>() ?? <String, Object?>{};
  final String tagName = data['tagName'] as String;
  if (allowedTags[tagName] == null && tagName != 'body') {
    final dom.DomNode? replacement = convertTagToPlaintext(node);
    if (replacement != null) {
      final dom.DomElement? parent = node.parentElement;
      if (parent == null) return;
      if (node.nodeType == _commentNode) {
        _insertBefore(parent, replacement, node);
      } else {
        _replaceChild(parent, node, replacement);
      }
    }
  }
}

/// DOM `insertBefore` semantics: a DocumentFragment inserts its children.
void _insertBefore(
  dom.DomNode parent,
  dom.DomNode node,
  dom.DomNode reference,
) {
  if (node.nodeType == dom.DomNode.DOCUMENT_FRAGMENT_NODE) {
    for (final dom.DomNode child in List<dom.DomNode>.from(node.childNodes)) {
      parent.insertBefore(child, reference);
    }
  } else {
    parent.insertBefore(node, reference);
  }
}

void _replaceChild(dom.DomElement parent, dom.DomNode oldNode, dom.DomNode replacement) {
  _insertBefore(parent, replacement, oldNode);
  parent.removeChild(oldNode);
}

void _hookDomPurifyHrefAndSrcSanitizer(
  AllowedLinksConfig allowedLinkProtocols,
  AllowedLinksConfig allowedMediaProtocols,
  bool Function(String source)? mediaSourceIsAllowed,
  bool replaceWithPlaintext,
) {
  _purify().addHook('afterSanitizeAttributes', (List<Object?> args) {
    final dom.DomElement node = args[0] as dom.DomElement;
    for (final String attr in const <String>['href', 'src', 'poster']) {
      if (!node.hasAttribute(attr)) continue;
      final String attrValue = node.getAttribute(attr)!;
      if (attr == 'href' && node.localName.toLowerCase() == 'a') {
        if (!attrValue.startsWith('#') &&
            !validateLink(attrValue, allowedLinkProtocols)) {
          node.removeAttribute(attr);
        }
      } else if (attr == 'href' && attrValue.startsWith('#')) {
        continue;
      } else {
        if (!validateLink(attrValue, allowedMediaProtocols)) {
          node.removeAttribute(attr);
        } else if (mediaSourceIsAllowed != null &&
            !mediaSourceIsAllowed(attrValue)) {
          final dom.DomNode? replacement =
              replaceWithPlaintext ? convertTagToPlaintext(node) : null;
          final dom.DomElement? parent = node.parentElement;
          if (replacement != null && parent != null) {
            _replaceChild(parent, node, replacement);
            return;
          } else {
            node.removeAttribute(attr);
          }
        }
      }
    }
  });
}

/// 1:1: `doSanitizeHtml(untrusted, config, outputType)`.
Object _doSanitizeHtml(
  String untrusted,
  DomSanitizerConfig? config,
  String outputType,
) {
  try {
    final Map<String, Object?> resolvedConfig =
        Map<String, Object?>.from(_defaultDomPurifyConfig);

    if (config?.allowedTags != null) {
      final Map<String, Object?> tags = config!.allowedTags!;
      final Object? override = tags['override'];
      if (override != null) {
        resolvedConfig['ALLOWED_TAGS'] =
            List<String>.from((override as List).cast<String>());
      }
      final Object? augment = tags['augment'];
      if (augment != null) {
        final List<String> current =
            (resolvedConfig['ALLOWED_TAGS'] as List?)?.cast<String>() ?? <String>[];
        resolvedConfig['ALLOWED_TAGS'] =
            <String>[...current, ...(augment as List).cast<String>()];
      }
    }

    List<Object> resolvedAttributes = List<Object>.from(defaultAllowedAttrs);
    if (config?.allowedAttributes != null) {
      final Map<String, Object?> attrs = config!.allowedAttributes!;
      final Object? override = attrs['override'];
      if (override != null) {
        resolvedAttributes = List<Object>.from(override as List);
      }
      final Object? augment = attrs['augment'];
      if (augment != null) {
        resolvedAttributes.addAll((augment as List).cast<Object>());
      }
    }

    resolvedAttributes = resolvedAttributes.map<Object>((Object attr) {
      if (attr is String) return attr.toLowerCase();
      final SanitizeAttributeRule rule = attr as SanitizeAttributeRule;
      return SanitizeAttributeRule(
        attributeName: rule.attributeName.toLowerCase(),
        shouldKeep: rule.shouldKeep,
      );
    }).toList();

    final Set<String> allowedAttrNames = <String>{
      for (final Object attr in resolvedAttributes)
        attr is String ? attr : (attr as SanitizeAttributeRule).attributeName,
    };
    final Map<String, SanitizeAttributeRule> allowedAttrPredicates =
        <String, SanitizeAttributeRule>{};
    for (final Object attr in resolvedAttributes) {
      if (attr is String) {
        allowedAttrPredicates.remove(attr);
      } else {
        final SanitizeAttributeRule rule = attr as SanitizeAttributeRule;
        allowedAttrPredicates[rule.attributeName] = rule;
      }
    }
    resolvedConfig['ALLOWED_ATTR'] = allowedAttrNames.toList();

    _hookDomPurifyHrefAndSrcSanitizer(
      AllowedLinksConfig(
        override: config?.allowedLinkProtocols?['override'] ??
            <String>[network.Schemas.http, network.Schemas.https],
        allowRelativePaths: config?.allowRelativeLinkPaths ?? false,
      ),
      AllowedLinksConfig(
        override: config?.allowedMediaProtocols?['override'] ??
            <String>[network.Schemas.http, network.Schemas.https],
        allowRelativePaths: config?.allowRelativeMediaPaths ?? false,
      ),
      config?.mediaSourceIsAllowed,
      config?.replaceWithPlaintext ?? false,
    );

    final DomPurifyApi purify = _purify();
    if (config?.replaceWithPlaintext ?? false) {
      purify.addHook('uponSanitizeElement', _replaceWithPlainTextHook);
    }

    if (allowedAttrPredicates.isNotEmpty) {
      purify.addHook('uponSanitizeAttribute', (List<Object?> args) {
        final Map<String, Object?> e = args[1] as Map<String, Object?>;
        final String attrName = e['attrName'] as String;
        final SanitizeAttributeRule? predicate = allowedAttrPredicates[attrName];
        if (predicate != null) {
          final Object result = predicate.shouldKeep(
            args[0] as dom.DomElement,
            e,
          );
          if (result is String) {
            e['keepAttr'] = true;
            e['attrValue'] = result;
          } else {
            e['keepAttr'] = result;
          }
        } else {
          e['keepAttr'] = allowedAttrNames.contains(attrName);
        }
      });
    }

    if (outputType == 'dom') {
      return sanitizeSurvivingStalePolicy(untrusted, <String, Object?>{
        ...resolvedConfig,
        'RETURN_DOM_FRAGMENT': true,
      });
    }
    return sanitizeSurvivingStalePolicy(untrusted, <String, Object?>{
      ...resolvedConfig,
      'RETURN_TRUSTED_TYPE': true,
    });
  } finally {
    _purify().removeAllHooks();
  }
}

/// 1:1: `safeSetInnerHtml(node, untrusted, config?)`.
void safeSetInnerHtml(
  dom.DomElement node,
  String untrusted, [
  DomSanitizerConfig? config,
]) {
  final Object fragment = _doSanitizeHtml(untrusted, config, 'dom');
  _reset(node, <Object>[fragment]);
}
