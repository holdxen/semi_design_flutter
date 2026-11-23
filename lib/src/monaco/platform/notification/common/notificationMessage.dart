// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/notification/common/notificationMessage.ts
// Translated 1:1 from TypeScript.
//   - `Object.freeze(array)` -> `List.unmodifiable(...)`; `Object.freeze({label,
//     href, title})` -> the `Link` carrier from linkedText.dart (final fields).
//   - `template.matchAll(regex)` -> `RegExp.allMatches`; `match.index` -> `m.start`;
//     `match.groups!.index` -> `m.namedGroup('index')`.
// ---------------------------------------------------------------------------

import '../../../base/common/linkedText.dart';

/// Source regex: `/\{(?<index>\d+)\}/g`
final RegExp _placeholderRegex = RegExp(r'\{(?<index>\d+)\}');

/// Notification content constructed from literal text and explicitly authored links, never parsed markup.
/// 1:1: `export class NotificationText`
class NotificationText {
  final List<LinkedTextNode> _nodes;

  /// 1:1: `private constructor(private readonly _nodes: readonly LinkedTextNode[]) { Object.freeze(this._nodes); }`
  NotificationText._(List<LinkedTextNode> nodes)
      : _nodes = List<LinkedTextNode>.unmodifiable(nodes);

  /// 1:1: `get nodes(): readonly LinkedTextNode[]`
  List<LinkedTextNode> get nodes => _nodes;

  /// 1:1: `static link(label, href, title?): NotificationText`
  static NotificationText link(String label, String href, [String? title]) {
    if (title == null) {
      return NotificationText._(<LinkedTextNode>[
        Link(label, href),
      ]);
    }
    return NotificationText._(<LinkedTextNode>[
      Link(label, href, title),
    ]);
  }

  /// 1:1: `static concat(...parts: (string | NotificationText)[]): NotificationText`
  static NotificationText concat(List<Object> parts) {
    final List<LinkedTextNode> flatMap = <LinkedTextNode>[];
    for (final Object part in parts) {
      if (part is String) {
        flatMap.add(part);
      } else {
        flatMap.addAll((part as NotificationText)._nodes);
      }
    }
    return NotificationText._(flatMap);
  }

  /// Substitutes literal strings and explicit links into a localized template without parsing markup.
  /// 1:1: `static format(template, ...args): NotificationText`
  static NotificationText format(String template, List<Object> args) {
    final List<Object> parts = <Object>[];
    int index = 0;
    for (final RegExpMatch match in _placeholderRegex.allMatches(template)) {
      final int matchIndex = match.start;
      if (matchIndex > index) {
        parts.add(template.substring(index, matchIndex));
      }
      final int argIndex = int.parse(match.namedGroup('index')!);
      // 1:1: `args[Number(match.groups!.index)] ?? match[0]`
      parts.add(argIndex < args.length ? args[argIndex] : match.group(0)!);
      index = matchIndex + match.group(0)!.length;
    }
    if (index < template.length) {
      parts.add(template.substring(index));
    }
    return NotificationText.concat(parts);
  }

  /// Transforms displayed text without changing link targets or interpreting the result as markup.
  /// 1:1: `mapText(map: (text: string) => string): NotificationText`
  NotificationText mapText(String Function(String) map) {
    final List<LinkedTextNode> mapped = <LinkedTextNode>[];
    for (final LinkedTextNode node in _nodes) {
      if (node is String) {
        mapped.add(map(node));
      } else {
        final ILink link = node as ILink;
        mapped.add(Link(map(link.label), link.href, link.title));
      }
    }
    return NotificationText._(mapped);
  }

  /// 1:1: `toString(): string`
  @override
  String toString() {
    final List<String> result = <String>[];
    for (final LinkedTextNode node in _nodes) {
      result.add(node is String ? node : (node as ILink).label);
    }
    return result.join('');
  }
}
