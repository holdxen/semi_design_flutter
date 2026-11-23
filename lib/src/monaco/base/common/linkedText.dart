// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/linkedText.ts
// Translated 1:1 from TypeScript.
//   - `@memoize toString()` -> memoize wrapper factory stored per instance.
//   - Global regex `LINK_REGEX.exec` loop -> `RegExp.allMatches`.
// ---------------------------------------------------------------------------

/// 1:1: `export interface ILink`
abstract class ILink {
  String get label;
  String get href;
  String? get title;
}

/// 1:1: `export interface ILink` concrete carrier.
class Link implements ILink {
  @override
  final String label;
  @override
  final String href;
  @override
  final String? title;

  Link(this.label, this.href, [this.title]);

  @override
  String toString() => 'Link(label: $label, href: $href, title: $title)';
}

/// 1:1: `export type LinkedTextNode = string | ILink`
typedef LinkedTextNode = Object; // String | ILink

/// 1:1: `export class LinkedText`
class LinkedText {
  final List<LinkedTextNode> nodes;

  /// Source `@memoize toString()`: cache the computed string per instance.
  String? _toStringCache;

  LinkedText(this.nodes);

  /// 1:1: `toString()` (decorated with @memoize in source).
  @override
  String toString() {
    final String? cached = _toStringCache;
    if (cached != null) {
      return cached;
    }
    final String result = nodes
        .map((LinkedTextNode node) =>
            node is String ? node : (node as ILink).label)
        .join();
    _toStringCache = result;
    return result;
  }
}

/// Source: `/\[([^\]]+)\]\(((?:https?:\/\/|command:|file:)[^\)\s]+)(?: (["'])(.+?)(\3))?\)/gi`
/// Dart RegExp has no `g` flag; `allMatches` iterates all matches. The `\3`
/// backreference and case-insensitive flag are preserved.
final RegExp _linkRegex = RegExp(
    r'''\[([^\]]+)\]\(((?:https?:\/\/|command:|file:)[^\)\s]+)(?: (["'])(.+?)(\3))?\)''',
    caseSensitive: false);

/// 1:1: `export function parseLinkedText`
LinkedText parseLinkedText(String text) {
  final List<LinkedTextNode> result = <LinkedTextNode>[];

  int index = 0;
  for (final RegExpMatch match in _linkRegex.allMatches(text)) {
    final int matchIndex = match.start;
    if (matchIndex - index > 0) {
      result.add(text.substring(index, matchIndex));
    }

    final String label = match.group(1)!;
    final String href = match.group(2)!;
    final String? title = match.group(4);

    if (title != null) {
      result.add(Link(label, href, title));
    } else {
      result.add(Link(label, href));
    }

    index = matchIndex + match.group(0)!.length;
  }

  if (index < text.length) {
    result.add(text.substring(index));
  }

  return LinkedText(result);
}
