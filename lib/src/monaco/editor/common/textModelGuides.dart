// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/textModelGuides.ts
// Translated 1:1 from TypeScript.
// ---------------------------------------------------------------------------

import 'core/position.dart' show IPosition;

/// 1:1: `export interface IGuidesTextModelPart`
abstract class IGuidesTextModelPart {
  IActiveIndentGuideInfo getActiveIndentGuide(
      int lineNumber, int minLineNumber, int maxLineNumber);

  List<int> getLinesIndentGuides(int startLineNumber, int endLineNumber);

  /// `result[i]` will contain the indent guides of the `startLineNumber + i`th line.
  List<List<IndentGuide>> getLinesBracketGuides(int startLineNumber, int endLineNumber,
      IPosition? activePosition, BracketGuideOptions options);
}

/// 1:1: `export interface IActiveIndentGuideInfo`
class IActiveIndentGuideInfo {
  final int startLineNumber;
  final int endLineNumber;
  final int indent;

  IActiveIndentGuideInfo({
    required this.startLineNumber,
    required this.endLineNumber,
    required this.indent,
  });
}

/// 1:1: `export enum HorizontalGuidesState`
enum HorizontalGuidesState {
  Disabled,
  EnabledForActive,
  Enabled,
}

/// 1:1: `export interface BracketGuideOptions`
class BracketGuideOptions {
  final bool includeInactive;
  final HorizontalGuidesState horizontalGuides;
  final bool highlightActive;

  BracketGuideOptions({
    required this.includeInactive,
    required this.horizontalGuides,
    required this.highlightActive,
  });
}

/// 1:1: `export class IndentGuide`
class IndentGuide {
  final int visibleColumn;
  final int column;
  final String className;

  /// If set, this indent guide is a horizontal guide (no vertical part).
  /// It starts at visibleColumn and continues until endColumn.
  final IndentGuideHorizontalLine? horizontalLine;

  /// If set (!= -1), only show this guide for wrapped lines that don't contain
  /// this model column, but are after it.
  final int forWrappedLinesAfterColumn;

  /// If set (!= -1), only show this guide for wrapped lines that don't contain
  /// this model column, but are before or at it.
  final int forWrappedLinesBeforeOrAtColumn;

  IndentGuide(
    this.visibleColumn,
    this.column,
    this.className,
    this.horizontalLine,
    this.forWrappedLinesAfterColumn,
    this.forWrappedLinesBeforeOrAtColumn,
  ) {
    if ((visibleColumn != -1) == (column != -1)) {
      throw StateError('IndentGuide requires exactly one of visibleColumn/column to be -1');
    }
  }
}

/// 1:1: `export class IndentGuideHorizontalLine`
class IndentGuideHorizontalLine {
  final bool top;
  final int endColumn;

  IndentGuideHorizontalLine(this.top, this.endColumn);
}
