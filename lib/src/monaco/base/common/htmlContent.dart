// 1:1 port of vs/base/common/htmlContent.ts
import 'errors.dart' as errors;
import 'iconLabels.dart' as iconLabels;
import 'network.dart' as network;
import 'resources.dart' as resources;
import 'uri.dart' as uri;

/// 1:1: `MarkdownStringTrustedOptions`
class MarkdownStringTrustedOptions {
  MarkdownStringTrustedOptions({required this.enabledCommands});

  final List<String> enabledCommands;
}

/// 1:1: `IMarkdownString`
abstract class IMarkdownString {
  String get value;
  Object? get isTrusted; // bool | MarkdownStringTrustedOptions | null
  bool? get supportThemeIcons;
  bool? get supportHtml;
  bool? get supportAlertSyntax;
  Object? get baseUri; // UriComponents | null
  Map<String, Object?>? get uris;
}

/// 1:1: `MarkdownStringTextNewlineStyle`
class MarkdownStringTextNewlineStyle {
  static const int paragraph = 0;
  static const int break_ = 1;
}

/// 1:1: `MarkdownString`
class MarkdownString implements IMarkdownString {
  MarkdownString([
    Object? value = '',
    Object? isTrustedOrOptions = false,
  ]) {
    if (value is! String) {
      throw errors.illegalArgument('value');
    }
    this.value = value;

    if (isTrustedOrOptions is bool) {
      isTrusted = isTrustedOrOptions;
      supportThemeIcons = false;
      supportHtml = false;
      supportAlertSyntax = false;
    } else {
      final Map<String, Object?> opts = isTrustedOrOptions is IMarkdownString
          ? <String, Object?>{
              'isTrusted': isTrustedOrOptions.isTrusted,
              'supportThemeIcons': isTrustedOrOptions.supportThemeIcons,
              'supportHtml': isTrustedOrOptions.supportHtml,
              'supportAlertSyntax': isTrustedOrOptions.supportAlertSyntax,
            }
          : (isTrustedOrOptions as Map?)?.cast<String, Object?>() ??
              <String, Object?>{};
      isTrusted = opts['isTrusted'];
      supportThemeIcons = opts['supportThemeIcons'] as bool? ?? false;
      supportHtml = opts['supportHtml'] as bool? ?? false;
      supportAlertSyntax = opts['supportAlertSyntax'] as bool? ?? false;
    }
  }

  /// 1:1: `MarkdownString.lift`
  static MarkdownString lift(IMarkdownString dto) {
    final MarkdownString markdownString = MarkdownString(dto.value, dto);
    markdownString.uris = dto.uris;
    markdownString.baseUri = dto.baseUri != null
        ? uri.URI.revive(dto.baseUri)
        : null;
    return markdownString;
  }

  @override
  String value = '';
  @override
  Object? isTrusted;
  @override
  bool? supportThemeIcons;
  @override
  bool? supportHtml;
  @override
  bool? supportAlertSyntax;
  @override
  Object? baseUri;
  @override
  Map<String, Object?>? uris;

  /// 1:1: `appendText`
  MarkdownString appendText(String value, [
    int newlineStyle = MarkdownStringTextNewlineStyle.paragraph,
  ]) {
    this.value += escapeMarkdownSyntaxTokens(
          supportThemeIcons == true ? iconLabels.escapeIcons(value) : value,
        ).replaceAllMapped(
          RegExp(r'([ \t]+)'),
          (Match m) => '&nbsp;' * m.group(1)!.length,
        ).replaceAllMapped(
          RegExp(r'\>'),
          (_) => r'\>',
        ).replaceAllMapped(
          RegExp(r'\n'),
          (_) => newlineStyle == MarkdownStringTextNewlineStyle.break_
              ? '\\\n'
              : '\n\n',
        );
    return this;
  }

  /// 1:1: `appendMarkdown`
  MarkdownString appendMarkdown(String value) {
    this.value += value;
    return this;
  }

  /// 1:1: `appendCodeblock`
  MarkdownString appendCodeblock(String langId, String code) {
    value += '\n${appendEscapedMarkdownCodeBlockFence(code, langId)}\n';
    return this;
  }

  /// 1:1: `appendLink`
  MarkdownString appendLink(Object target, String label, [String? title]) {
    value += '[';
    value += _escape(label, ']');
    value += '](';
    value += escapeMarkdownLinkDestination(target.toString());
    if (title != null && title.isNotEmpty) {
      value += ' "${escapeMarkdownLinkTitle(title)}"';
    }
    value += ')';
    return this;
  }

  /// 1:1: `_escape`
  String _escape(String value, String ch) {
    String result = '';
    int backslashes = 0;
    for (final int c in value.runes) {
      final String s = String.fromCharCode(c);
      if (s == ch && backslashes % 2 == 0) {
        result += '\\';
      }
      backslashes = s == '\\' ? backslashes + 1 : 0;
      result += s;
    }
    return backslashes % 2 == 1 ? result + '\\' : result;
  }
}

/// 1:1: `escapeMarkdownLinkDestination`
String escapeMarkdownLinkDestination(String target) => target
    .replaceAllMapped(
      RegExp(r'[\s\x00-\x1f\x7f]'),
      (Match m) => Uri.encodeComponent(m.group(0)!),
    )
    .replaceAllMapped(RegExp(r'[\\()<>]'), (Match m) => '\\${m.group(0)}');

/// 1:1: `escapeMarkdownLinkTitle`
String escapeMarkdownLinkTitle(String title) => title
    .replaceAllMapped(RegExp(r'\r\n|[\r\n]'), (_) => ' ')
    .replaceAll('\u0000', '\uFFFD')
    .replaceAllMapped(
      RegExp(r'[&\\"()\t]'),
      (Match m) => '&#${m.group(0)!.codeUnitAt(0)};',
    );

/// 1:1: `isEmptyMarkdownString`
bool isEmptyMarkdownString(Object? oneOrMany) {
  if (isMarkdownString(oneOrMany)) {
    return (oneOrMany as IMarkdownString).value.isEmpty;
  } else if (oneOrMany is List) {
    return oneOrMany.every(isEmptyMarkdownString);
  } else {
    return true;
  }
}

/// 1:1: `isMarkdownString`
bool isMarkdownString(Object? thing) {
  if (thing is MarkdownString) {
    return true;
  } else if (thing is Map) {
    return thing['value'] is String &&
        (thing['isTrusted'] is bool ||
            thing['isTrusted'] is Map ||
            thing['isTrusted'] == null) &&
        (thing['supportThemeIcons'] is bool ||
            thing['supportThemeIcons'] == null) &&
        (thing['supportAlertSyntax'] is bool ||
            thing['supportAlertSyntax'] == null);
  }
  return false;
}

/// 1:1: `markdownStringEqual`
bool markdownStringEqual(Object? a, Object? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  final IMarkdownString aa = a as IMarkdownString;
  final IMarkdownString bb = b as IMarkdownString;
  return aa.value == bb.value &&
      aa.isTrusted == bb.isTrusted &&
      aa.supportThemeIcons == bb.supportThemeIcons &&
      aa.supportHtml == bb.supportHtml &&
      aa.supportAlertSyntax == bb.supportAlertSyntax &&
      (identical(_baseUriOf(aa), _baseUriOf(bb)) ||
          (_baseUriOf(aa) != null &&
              _baseUriOf(bb) != null &&
              resources.isEqual(
                  _asUri(_baseUriOf(aa)),
                  _asUri(_baseUriOf(bb)))));
}

Object? _baseUriOf(IMarkdownString m) => m.baseUri;

uri.URI _asUri(Object? v) => v is uri.URI
    ? v
    : uri.URI.from(v as uri.UriComponents);

/// 1:1: `escapeMarkdownSyntaxTokens`
String escapeMarkdownSyntaxTokens(String text) => text
    .replaceAllMapped(
      RegExp(r'[\\`*_{}[\]()#+!~]'),
      (Match m) => '\\${m.group(0)}',
    )
    .replaceAllMapped(RegExp(r'^([ \t]*)-', multiLine: true),
        (Match m) => '${m.group(1)}\\-');

/// 1:1: `escapeUntrustedMarkdown`
String escapeUntrustedMarkdown(String text) => escapeMarkdownSyntaxTokens(
      iconLabels.escapeIcons(text.replaceAllMapped(
        RegExp(r'\s+'),
        (_) => ' ',
      )),
    ).replaceAllMapped(RegExp(r'[<>:.@]'), (Match m) => '\\${m.group(0)}');

/// 1:1: `escapeMarkdownLinkLabel`
String escapeMarkdownLinkLabel(String text) =>
    text.replaceAllMapped(RegExp(r'[\\\]]'), (Match m) => '\\${m.group(0)}');

/// 1:1: `escapeMarkdownLinkText`
String escapeMarkdownLinkText(String text) => text
    .replaceAllMapped(RegExp(r'\r\n|[\r\n]'), (_) => ' ')
    .replaceAllMapped(RegExp(r'[!-/:-@[-`{-~]'),
        (Match m) => '\\${m.group(0)}');

/// 1:1: `appendEscapedMarkdownCodeBlockFence`
String appendEscapedMarkdownCodeBlockFence(String code, String langId) {
  int longestFenceLength = 0;
  for (final Match fence in RegExp(r'^ {0,3}`+', multiLine: true).allMatches(code)) {
    final int len = fence.group(0)!.replaceAll(RegExp(r'^ +'), '').length;
    if (len > longestFenceLength) longestFenceLength = len;
  }
  final int desiredFenceLength =
      longestFenceLength >= 3 ? longestFenceLength + 1 : 3;
  final String fence = '`' * desiredFenceLength;
  return <String>[
    '$fence$langId',
    code,
    fence,
  ].join('\n');
}

/// 1:1: `appendEscapedMarkdownInlineCode`
String appendEscapedMarkdownInlineCode(String text) {
  int longestBacktickRun = 0;
  for (final Match m in RegExp(r'`+').allMatches(text)) {
    final int len = m.group(0)!.length;
    if (len > longestBacktickRun) longestBacktickRun = len;
  }
  final String fence = '`' * (longestBacktickRun + 1);
  final bool needsSpace = text.startsWith('`') || text.endsWith('`');
  final String content = needsSpace ? ' $text ' : text;
  return '$fence$content$fence';
}

/// 1:1: `escapeDoubleQuotes`
String escapeDoubleQuotes(String input) => input.replaceAll('"', '&quot;');

/// 1:1: `removeMarkdownEscapes`
String removeMarkdownEscapes(String text) {
  if (text.isEmpty) return text;
  return text.replaceAllMapped(
    RegExp(r'\\([\\`*_{}[\]()#+\-.!~])'),
    (Match m) => m.group(1)!,
  );
}

/// 1:1: `parseHrefAndDimensions`
Map<String, Object> parseHrefAndDimensions(String href) {
  final List<String> dimensions = <String>[];
  final List<String> splitted =
      href.split('|').map((String s) => s.trim()).toList();
  href = splitted[0];
  final String parameters = splitted.length > 1 ? splitted[1] : '';
  if (parameters.isNotEmpty) {
    final RegExpMatch? heightFromParams = RegExp(r'height=(\d+)').firstMatch(parameters);
    final RegExpMatch? widthFromParams = RegExp(r'width=(\d+)').firstMatch(parameters);
    final String height = heightFromParams?.group(1) ?? '';
    final String width = widthFromParams?.group(1) ?? '';
    final bool widthIsFinite = _parseIntFinite(width);
    final bool heightIsFinite = _parseIntFinite(height);
    if (widthIsFinite) dimensions.add('width="$width"');
    if (heightIsFinite) dimensions.add('height="$height"');
  }
  return <String, Object>{'href': href, 'dimensions': dimensions};
}

/// JS: isFinite(parseInt(width)) — parseInt('') => NaN => false.
bool _parseIntFinite(String s) {
  if (s.isEmpty) return false;
  return int.tryParse(s) != null;
}

/// 1:1: `resolveWithBaseUri`
String resolveWithBaseUri(uri.URI baseUri, String href) {
  final bool hasScheme = RegExp(r'^\w[\w\d+.-]*:').hasMatch(href);
  if (hasScheme) return href;

  if (baseUri.path.endsWith('/')) {
    return resources.resolvePath(baseUri, href).toString();
  } else {
    return resources.resolvePath(resources.dirname(baseUri), href).toString();
  }
}

/// 1:1: `createMarkdownLink`
String createMarkdownLink(String text, String href, [String? title, bool escapeTokens = true]) =>
    '[${escapeTokens ? escapeMarkdownSyntaxTokens(text) : text}]($href'
    '${title != null ? ' "${escapeMarkdownSyntaxTokens(title)}"' : ''})';

/// 1:1: `createMarkdownCommandLink`
String createMarkdownCommandLink(Map<String, Object> command,
        [bool escapeTokens = true]) =>
    createMarkdownLink(
      command['text'] as String,
      createCommandUri(
        command['id'] as String,
        List<Object>.from((command['arguments'] as List?) ?? const <Object>[]),
      ).toString(),
      command['tooltip'] as String?,
      escapeTokens,
    );

/// 1:1: `createCommandUri`
uri.URI createCommandUri(String commandId, [List<Object?> commandArgs = const <Object?>[]]) =>
    uri.URI.from(uri.UriComponents(
      scheme: network.Schemas.command,
      path: commandId,
      query: commandArgs.isNotEmpty
          ? Uri.encodeComponent(_jsJsonStringify(commandArgs))
          : null,
    ));

/// Minimal JS JSON.stringify for argument arrays (no pretty print, JS escaping).
String _jsJsonStringify(List<Object?> args) {
  final List<String> parts = <String>[];
  for (final Object? a in args) {
    if (a is String) {
      parts.add('"${_escapeJson(a)}"');
    } else if (a is num) {
      parts.add(a.toString());
    } else if (a is bool) {
      parts.add(a ? 'true' : 'false');
    } else if (a == null) {
      parts.add('null');
    } else {
      parts.add('"${_escapeJson(a.toString())}"');
    }
  }
  return '[${parts.join(',')}]';
}

String _escapeJson(String s) => s
    .replaceAll('\\', '\\\\')
    .replaceAll('"', '\\"')
    .replaceAll('\n', '\\n')
    .replaceAll('\r', '\\r')
    .replaceAll('\t', '\\t');

/// 1:1: `placeholderAuthority`
final RegExp _placeholderAuthority =
    RegExp(r'^https?:\/\/_[^/?#]*_(?:[/?#]|$)', caseSensitive: false);

/// 1:1: `absolutePath`
final RegExp _absolutePath = RegExp(r'^(?:[/\\]|[a-z]:[/\\])', caseSensitive: false);

/// 1:1: `isPortableLinkTarget`
bool isPortableLinkTarget(String target) {
  final String trimmed = target.trim();
  return network.matchesSomeScheme(trimmed, <String>[
        network.Schemas.http,
        network.Schemas.https,
        network.Schemas.mailto,
      ]) &&
      !_placeholderAuthority.hasMatch(trimmed);
}

/// 1:1: `isPortableMarkdownTarget`
bool isPortableMarkdownTarget(String target) {
  final String trimmed = target.trim();
  return isPortableLinkTarget(trimmed) ||
      (trimmed.isNotEmpty &&
          !RegExp(r'^[a-z][a-z0-9.+-]*:', caseSensitive: false)
              .hasMatch(trimmed) &&
          !_absolutePath.hasMatch(trimmed));
}
