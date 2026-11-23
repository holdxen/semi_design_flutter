// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/text/positionToOffset.ts
// Translated 1:1 from TypeScript.
// ---------------------------------------------------------------------------

import '../position.dart';
import '../ranges/offsetRange.dart';
import '../range.dart';
import '../edits/stringEdit.dart';
import '../edits/textEdit.dart';
import 'positionToOffsetImpl.dart';
import 'textLength.dart';

export 'positionToOffsetImpl.dart' show PositionOffsetTransformerBase, PositionOffsetTransformer;

/// 1:1: module-init side effect `_setPositionOffsetTransformerDependencies({...})`.
/// Called lazily from [ensureDependenciesAreSet], which every entry point must invoke.
void _initializeDeps() {
  setPositionOffsetTransformerDependencies(IDeps(
    stringEditCtor: (List<StringReplacement> replacements) => StringEdit(replacements),
    stringReplacementCtor: (OffsetRange range, String text) => StringReplacement(range, text),
    textReplacementCtor: (Range range, String text) => TextReplacement(range, text),
    textEditCtor: (List<TextReplacement> replacements) => TextEdit(replacements),
    textLengthCtor: (int lineCount, int columnCount) => TextLength(lineCount, columnCount),
    rangeFromPositions: (Position start, Position end) => Range.fromPositions(start, end: end),
  ));
}

bool _depsSet = false;

/// 1:1: `ensureDependenciesAreSet`
void ensureDependenciesAreSet() {
  if (!_depsSet) {
    _initializeDeps();
    _depsSet = true;
  }
}
