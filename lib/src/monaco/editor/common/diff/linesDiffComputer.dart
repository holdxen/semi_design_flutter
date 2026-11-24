// 1:1 port of vscode/src/vs/editor/common/diff/linesDiffComputer.ts
// The only dependency (./rangeMapping.js) is type-only in the source, so this
// Dart file imports it normally without creating a runtime cycle.

import 'rangeMapping.dart' show DetailedLineRangeMapping, LineRangeMapping;

/// 1:1: `export interface ILinesDiffComputer`
abstract class ILinesDiffComputer {
  LinesDiff computeDiff(List<String> originalLines, List<String> modifiedLines,
      ILinesDiffComputerOptions options);
}

/// 1:1: `export interface ILinesDiffComputerOptions`
class ILinesDiffComputerOptions {
  final bool ignoreTrimWhitespace;
  final int maxComputationTimeMs;
  final bool computeMoves;
  final bool? extendToSubwords;

  const ILinesDiffComputerOptions({
    required this.ignoreTrimWhitespace,
    required this.maxComputationTimeMs,
    required this.computeMoves,
    this.extendToSubwords,
  });
}

/// 1:1: `export class LinesDiff`
class LinesDiff {
  final List<DetailedLineRangeMapping> changes;

  /// Sorted by original line ranges. The original line ranges and the modified
  /// line ranges must be disjoint (but can be touching).
  final List<MovedText> moves;

  /// Indicates if the time out was reached.
  final bool hitTimeout;

  LinesDiff(this.changes, this.moves, this.hitTimeout);
}

/// 1:1: `export class MovedText`
class MovedText {
  final LineRangeMapping lineRangeMapping;

  /// The diff from the original text to the moved text.
  final List<DetailedLineRangeMapping> changes;

  MovedText(this.lineRangeMapping, this.changes);

  MovedText flip() => MovedText(
        lineRangeMapping.flip(),
        changes.map((DetailedLineRangeMapping c) => c.flip()).toList(),
      );
}
