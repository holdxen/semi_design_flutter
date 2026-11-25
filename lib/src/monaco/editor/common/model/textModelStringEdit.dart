// ---------------------------------------------------------------------------
// 1:1 port of vscode/src/vs/editor/common/model/textModelStringEdit.ts (61 lines).
//
// Four conversion helpers between offset-based edits and the model's
// line/column world.
//
// Adaptations:
//   - `ITextModel` / `IIdentifiedSingleEditOperation` stay erased: the model is
//     `Object?` and the three members used (`getPositionAt`, `getOffsetAt`,
//     `getValueInRange`) are read dynamically, matching the structural typing
//     of the TS interface.
//   - `IModelContentChange` keeps its ported abstract carrier from
//     `mirrorTextModel.dart`.
//   - `LengthEdit.compose` is `composeStatic` in the port (static name clash
//     with the instance method); same semantics.
//   - `countEOL(...)` returns a Dart record, hence `.$1`.
// ---------------------------------------------------------------------------

import '../core/editOperation.dart' show EditOperation, ISingleEditOperation;
import '../core/edits/lengthEdit.dart' show LengthEdit;
import '../core/edits/stringEdit.dart' show StringEdit, StringReplacement;
import '../core/misc/eolCounter.dart' show countEOL;
import '../core/range.dart' show Range;
import '../core/ranges/offsetRange.dart' show OffsetRange;
import '../diff/rangeMapping.dart' show DetailedLineRangeMapping;
import 'mirrorTextModel.dart' show IModelContentChange;


/// 1:1: `export function offsetEditToEditOperations(offsetEdit, doc)`
List<ISingleEditOperation> offsetEditToEditOperations(
    StringEdit offsetEdit, Object? doc) {
  final dynamic model = doc;
  final List<ISingleEditOperation> edits = <ISingleEditOperation>[];
  for (final StringReplacement singleEdit in offsetEdit.replacements) {
    final Range range = Range.fromPositions(
      model.getPositionAt(singleEdit.replaceRange.start) as dynamic,
      end: model.getPositionAt(
          singleEdit.replaceRange.start + singleEdit.replaceRange.length) as dynamic,
    );
    edits.add(EditOperation.replace(range, singleEdit.newText));
  }
  return edits;
}

/// 1:1: `export function offsetEditFromContentChanges(contentChanges)`
///
/// `IModelContentChange[]` arrives in descending offset order; the `reverse()`
/// below restores the ascending order required by [StringEdit].
StringEdit offsetEditFromContentChanges(
    List<IModelContentChange> contentChanges) {
  final List<StringReplacement> editsArr = contentChanges
      .map((IModelContentChange c) => StringReplacement(
            OffsetRange.ofStartAndLength(c.rangeOffset, c.rangeLength),
            c.text,
          ))
      .toList();
  final List<StringReplacement> reversed =
      editsArr.reversed.toList(growable: false);
  return StringEdit(reversed);
}

/// 1:1: `export function offsetEditFromLineRangeMapping(original, modified, changes)`
StringEdit offsetEditFromLineRangeMapping(Object? original, Object? modified,
    List<DetailedLineRangeMapping> changes) {
  final dynamic originalModel = original;
  final dynamic modifiedModel = modified;
  final List<StringReplacement> edits = <StringReplacement>[];
  for (final DetailedLineRangeMapping c in changes) {
    for (final inner in c.innerChanges ?? const <Object?>[]) {
      final dynamic i = inner;
      final String newText =
          modifiedModel.getValueInRange(i.modifiedRange) as String;

      final int startOrig =
          originalModel.getOffsetAt(i.originalRange.getStartPosition()) as int;
      final int endExOrig =
          originalModel.getOffsetAt(i.originalRange.getEndPosition()) as int;
      final OffsetRange origRange = OffsetRange(startOrig, endExOrig);

      edits.add(StringReplacement(origRange, newText));
    }
  }

  return StringEdit(edits);
}

/// 1:1: `export function linesLengthEditFromModelContentChange(c)`
LengthEdit linesLengthEditFromModelContentChange(
    List<IModelContentChange> c) {
  final List<IModelContentChange> contentChanges =
      c.reversed.toList(growable: false);
  final List<LengthEdit> lengthEdits = contentChanges
      .map((IModelContentChange change) => LengthEdit.replace(
            // Expand the edit range to include the entire line
            OffsetRange(change.range.startLineNumber - 1,
                change.range.endLineNumber),
            countEOL(change.text).$1 + 1,
          ))
      .toList();
  final LengthEdit lengthEdit = LengthEdit.composeStatic(lengthEdits);
  return lengthEdit;
}
