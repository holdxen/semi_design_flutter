// 1:1 port of vscode/src/vs/editor/common/model.ts (1633 lines).
//
// The file is overwhelmingly type-level: all `interface` / `type` declarations
// are erased per the repo's established convention (see `editorCommon.dart`).
// The runtime surface ported here is:
//   - 12 enums: OverviewRulerLane, GlyphMarginLane, MinimapPosition,
//     MinimapSectionHeaderStyle, TextDirection, InjectedTextCursorStops,
//     EndOfLinePreference, DefaultEndOfLine, EndOfLineSequence,
//     TrackedRangeStickiness, PositionAffinity, ModelConstants
//   - 5 classes: TextModelResolvedOptions, FindMatch,
//     ValidAnnotatedEditOperation, SearchData, ApplyEditsResult
//   - 3 functions: isITextSnapshot, isITextModel, shouldSynchronizeModel
//
// Adaptations (documented inline):
//  * erased interfaces used as field/param types are carried as `Object?` and
//    read structurally (`ITextModel`, `IEditorModel`,
//    `ISingleEditOperationIdentifier`, `IModelOptionsChangedEvent`,
//    `BracketPairColorizationOptions`).
//  * `EndOfLinePreference` is declared here too (the source file owns it);
//    `standalone/standaloneEnums.dart` keeps its own copy for the standalone
//    enum facade — separate libraries, same precedent as `ScrollType`.
//  * `number | 'tabSize'` → `Object` (num or the string `'tabSize'`).
//  * `new RegExp(...)` → Dart `RegExp`.
import '../../base/common/objects.dart' as objects show equals;
import './core/range.dart' show Range;
import './core/wordCharacterClassifier.dart' show WordCharacterClassifier;

/// 1:1: `export enum OverviewRulerLane`.
class OverviewRulerLane {
  static const int Left = 1;
  static const int Center = 2;
  static const int Right = 4;
  static const int Full = 7;

  const OverviewRulerLane._();
}

/// Vertical Lane in the glyph margin of the editor.
/// 1:1: `export enum GlyphMarginLane`.
class GlyphMarginLane {
  static const int Left = 1;
  static const int Center = 2;
  static const int Right = 3;

  const GlyphMarginLane._();
}

/// 1:1: `export const enum MinimapPosition`.
class MinimapPosition {
  static const int Inline = 1;
  static const int Gutter = 2;

  const MinimapPosition._();
}

/// Section header style.
/// 1:1: `export const enum MinimapSectionHeaderStyle`.
class MinimapSectionHeaderStyle {
  static const int Normal = 1;
  static const int Underlined = 2;

  const MinimapSectionHeaderStyle._();
}

/// 1:1: `export enum TextDirection`.
class TextDirection {
  static const int LTR = 0;
  static const int RTL = 1;

  const TextDirection._();
}

/// 1:1: `export enum InjectedTextCursorStops`.
class InjectedTextCursorStops {
  static const int Both = 0;
  static const int Right = 1;
  static const int Left = 2;
  static const int None = 3;

  const InjectedTextCursorStops._();
}

/// 1:1: `export const enum EndOfLinePreference`.
class EndOfLinePreference {
  /// Use the end of line character identified in the text buffer.
  static const int TextDefined = 0;

  /// Use line feed (\n) as the end of line character.
  static const int LF = 1;

  /// Use carriage return and line feed (\r\n) as the end of line character.
  static const int CRLF = 2;

  const EndOfLinePreference._();
}

/// The default end of line to use when instantiating models.
/// 1:1: `export const enum DefaultEndOfLine`.
class DefaultEndOfLine {
  /// Use line feed (\n) as the end of line character.
  static const int LF = 1;

  /// Use carriage return and line feed (\r\n) as the end of line character.
  static const int CRLF = 2;

  const DefaultEndOfLine._();
}

/// End of line character preference.
/// 1:1: `export const enum EndOfLineSequence`.
class EndOfLineSequence {
  /// Use line feed (\n) as the end of line character.
  static const int LF = 0;

  /// Use carriage return and line feed (\r\n) as the end of line character.
  static const int CRLF = 1;

  const EndOfLineSequence._();
}

/// Describes the behavior of decorations when typing/editing near their edges.
/// Note: Please do not edit the values, as they very carefully match
/// `DecorationRangeBehavior`.
/// 1:1: `export const enum TrackedRangeStickiness`.
class TrackedRangeStickiness {
  static const int AlwaysGrowsWhenTypingAtEdges = 0;
  static const int NeverGrowsWhenTypingAtEdges = 1;
  static const int GrowsOnlyWhenTypingBefore = 2;
  static const int GrowsOnlyWhenTypingAfter = 3;

  const TrackedRangeStickiness._();
}

/// 1:1: `export const enum PositionAffinity`.
class PositionAffinity {
  /// Prefers the left most position.
  static const int Left = 0;

  /// Prefers the right most position.
  static const int Right = 1;

  /// No preference.
  static const int None = 2;

  /// If the given position is on injected text, prefers the position left of it.
  static const int LeftOfInjectedText = 3;

  /// If the given position is on injected text, prefers the position right of it.
  static const int RightOfInjectedText = 4;

  const PositionAffinity._();
}

/// 1:1: `export const enum ModelConstants`.
class ModelConstants {
  static const int FIRST_LINE_DETECTION_LENGTH_LIMIT = 1000;

  const ModelConstants._();
}

/// 1:1: `export class TextModelResolvedOptions`.
class TextModelResolvedOptions {
  TextModelResolvedOptions(TextModelResolvedOptionsSource src)
      : tabSize = _max1(_toInt32(src.tabSize)),
        indentSize = src.indentSize == 'tabSize'
            ? _max1(_toInt32(src.tabSize))
            : _max1(_toInt32(src.indentSize as num)),
        _indentSizeIsTabSize = src.indentSize == 'tabSize',
        insertSpaces = _truthy(src.insertSpaces),
        defaultEOL = _toInt32(src.defaultEOL),
        trimAutoWhitespace = _truthy(src.trimAutoWhitespace),
        bracketPairColorizationOptions = src.bracketPairColorizationOptions;

  final num tabSize;
  final num indentSize;
  final bool _indentSizeIsTabSize;
  final bool insertSpaces;
  final num defaultEOL;
  final bool trimAutoWhitespace;
  final Object? bracketPairColorizationOptions;

  /// `number | 'tabSize'`
  Object get originalIndentSize =>
      _indentSizeIsTabSize ? 'tabSize' : indentSize;

  /// @internal
  bool equals(TextModelResolvedOptions other) {
    return (tabSize == other.tabSize &&
        _indentSizeIsTabSize == other._indentSizeIsTabSize &&
        indentSize == other.indentSize &&
        insertSpaces == other.insertSpaces &&
        defaultEOL == other.defaultEOL &&
        trimAutoWhitespace == other.trimAutoWhitespace &&
        objects.equals(bracketPairColorizationOptions,
            other.bracketPairColorizationOptions));
  }

  /// @internal
  Map<String, bool> createChangeEvent(TextModelResolvedOptions newOpts) {
    return <String, bool>{
      'tabSize': tabSize != newOpts.tabSize,
      'indentSize': indentSize != newOpts.indentSize,
      'insertSpaces': insertSpaces != newOpts.insertSpaces,
      'trimAutoWhitespace': trimAutoWhitespace != newOpts.trimAutoWhitespace,
    };
  }
}

/// The source object literal accepted by [TextModelResolvedOptions]
/// (`ITextModelCreationOptions` subset; the interface is erased).
class TextModelResolvedOptionsSource {
  TextModelResolvedOptionsSource({
    required this.tabSize,
    required this.indentSize,
    required this.insertSpaces,
    required this.defaultEOL,
    required this.trimAutoWhitespace,
    required this.bracketPairColorizationOptions,
  });

  final num tabSize;

  /// `number | 'tabSize'`
  final Object indentSize;
  final bool insertSpaces;
  final num defaultEOL;
  final bool trimAutoWhitespace;
  final Object? bracketPairColorizationOptions;
}

/// 1:1: `export class FindMatch`.
class FindMatch {
  FindMatch(this.range, this.matches);

  final Range range;
  final List<String>? matches;
}

/// 1:1: `export class ValidAnnotatedEditOperation`.
class ValidAnnotatedEditOperation {
  ValidAnnotatedEditOperation(
    this.identifier,
    this.range,
    this.text,
    this.forceMoveMarkers,
    this.isAutoWhitespaceEdit,
    this._isTracked,
  );

  final Object? identifier;
  final Range range;
  final String? text;
  final bool forceMoveMarkers;
  final bool isAutoWhitespaceEdit;

  // TS `readonly _isTracked` (internal flag kept for parity).
  // ignore: unused_field
  final bool _isTracked;
}

/// 1:1: `export class SearchData`.
class SearchData {
  SearchData(this.regex, this.wordSeparators, this.simpleSearch);

  /// The regex to search for. Always defined.
  final RegExp regex;

  /// The word separator classifier.
  final WordCharacterClassifier? wordSeparators;

  /// The simple string to search for (if possible).
  final String? simpleSearch;
}

/// 1:1: `export class ApplyEditsResult`.
class ApplyEditsResult {
  ApplyEditsResult(
    this.reverseEdits,
    this.changes,
    this.trimAutoWhitespaceLineNumbers,
  );

  final List<Object?>? reverseEdits;
  final List<Object?> changes;
  final List<num>? trimAutoWhitespaceLineNumbers;
}

/// 1:1: `export function isITextSnapshot(obj: unknown): obj is ITextSnapshot`.
bool isITextSnapshot(Object? obj) {
  if (obj == null) {
    return false;
  }
  // TS checks any object; plain JS object literals arrive as `Map`s here.
  return _readMember(obj, 'read') is Function;
}

/// 1:1: `export function isITextModel(obj: IEditorModel): obj is ITextModel`.
bool isITextModel(Object? obj) {
  if (obj == null) {
    return false;
  }
  return _truthy(_readMember(obj, 'uri'));
}

/// 1:1: `export function shouldSynchronizeModel(model: ITextModel): boolean`.
bool shouldSynchronizeModel(Object? model) {
  final dynamic m = model;
  return !(m.isTooLargeForSyncing() as bool) && !(m.isForSimpleWidget as bool);
}

/// Reads `obj[member]` like JS: plain object literals are `Map`s, records are
/// class instances with getters, primitives expose nothing.
Object? _readMember(Object obj, String member) {
  if (obj is Map) {
    return obj[member];
  }
  if (obj is num || obj is String || obj is bool || obj is List) {
    return null;
  }
  return (obj as dynamic).noSuchMethod(Invocation.getter(Symbol(member)));
}

/// JS `| 0` for the non-negative option values used here.
num _toInt32(num value) {
  final int v = value.truncate();
  final int unsigned = v & 0xFFFFFFFF;
  return unsigned < 0x80000000 ? unsigned : unsigned - 0x100000000;
}

num _max1(num value) => value < 1 ? 1 : value;

/// JS truthiness.
bool _truthy(Object? value) {
  if (value == null || value == false) return false;
  if (value is num) return value != 0 && !value.isNaN;
  if (value is String) return value.isNotEmpty;
  return true;
}
