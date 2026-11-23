// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/text/positionToOffsetImpl.ts
// Translated 1:1 from TypeScript.
//   - The `Deps` injection mechanism is preserved verbatim: Dart circular
//     imports are allowed, but keeping the injection honours the source's
//     dependency-breaking design and avoids initialization order issues.
//   - `_lineStartOffsetByLineIdx[...]` returns [] on OOB in JS; `_at` helper.
// ---------------------------------------------------------------------------

import '../../../../base/common/arraysFind.dart' as arraysFind;
import '../edits/stringEdit.dart';
import '../edits/textEdit.dart';
import '../position.dart';
import '../ranges/offsetRange.dart';
import '../range.dart';
import 'textLength.dart';

/// 1:1: `IDeps`
class IDeps {
  final StringEdit Function(List<StringReplacement>) stringEditCtor;
  final StringReplacement Function(OffsetRange, String) stringReplacementCtor;
  final TextReplacement Function(Range, String) textReplacementCtor;
  final TextEdit Function(List<TextReplacement>) textEditCtor;
  final TextLength Function(int, int) textLengthCtor;
  final Range Function(Position, Position) rangeFromPositions;

  IDeps({
    required this.stringEditCtor,
    required this.stringReplacementCtor,
    required this.textReplacementCtor,
    required this.textEditCtor,
    required this.textLengthCtor,
    required this.rangeFromPositions,
  });
}

/// 1:1: `Deps`
/// Dart has no TS top-level module side effects, so [deps] lazily installs the
/// real constructors (all are imported here) on first access. This mirrors the
/// source's `positionToOffset.ts` initialization while staying safe on any path.
class _Deps {
  static IDeps? _deps;
  static IDeps get deps {
    IDeps? d = _deps;
    if (d == null) {
      d = IDeps(
        stringEditCtor: (List<StringReplacement> replacements) => StringEdit(replacements),
        stringReplacementCtor: (OffsetRange range, String text) => StringReplacement(range, text),
        textReplacementCtor: (Range range, String text) => TextReplacement(range, text),
        textEditCtor: (List<TextReplacement> replacements) => TextEdit(replacements),
        textLengthCtor: (int lineCount, int columnCount) => TextLength(lineCount, columnCount),
        rangeFromPositions: (Position start, Position end) => Range.fromPositions(start, end: end),
      );
      _deps = d;
    }
    return d;
  }

  static void set(IDeps deps) => _deps = deps;
}

/// 1:1: `_setPositionOffsetTransformerDependencies`
void setPositionOffsetTransformerDependencies(IDeps deps) => _Deps.set(deps);

/// 1:1: `PositionOffsetTransformerBase`
abstract class PositionOffsetTransformerBase {
  int getOffset(Position position);

  /// 1:1: `getOffsetRange`
  OffsetRange getOffsetRange(Range range) => OffsetRange(
    this.getOffset(range.getStartPosition()),
    this.getOffset(range.getEndPosition()),
  );

  Position getPosition(int offset);

  /// 1:1: `getRange`
  Range getRange(OffsetRange offsetRange) => _Deps.deps.rangeFromPositions(
    this.getPosition(offsetRange.start),
    this.getPosition(offsetRange.endExclusive),
  );

  /// 1:1: `getStringEdit`
  StringEdit getStringEdit(TextEdit edit) =>
      _Deps.deps.stringEditCtor(edit.replacements.map((TextReplacement e) => this.getStringReplacement(e)).toList());

  /// 1:1: `getStringReplacement`
  StringReplacement getStringReplacement(TextReplacement edit) =>
      _Deps.deps.stringReplacementCtor(this.getOffsetRange(edit.range), edit.text);

  /// 1:1: `getTextReplacement`
  TextReplacement getTextReplacement(StringReplacement edit) =>
      _Deps.deps.textReplacementCtor(this.getRange(edit.replaceRange), edit.newText);

  /// 1:1: `getTextEdit`
  TextEdit getTextEdit(StringEdit edit) =>
      _Deps.deps.textEditCtor(edit.replacements.map((StringReplacement e) => this.getTextReplacement(e)).toList());
}

/// 1:1: `PositionOffsetTransformer`
class PositionOffsetTransformer extends PositionOffsetTransformerBase {
  List<int>? _lineStartOffsetByLineIdx;
  List<int>? _lineEndOffsetByLineIdx;

  final String text;

  PositionOffsetTransformer(this.text);

  List<int> get lineStartOffsetByLineIdx {
    final List<int>? v = _lineStartOffsetByLineIdx;
    if (v == null) {
      _computeLineOffsets();
    }
    return _lineStartOffsetByLineIdx!;
  }

  List<int> get lineEndOffsetByLineIdx {
    final List<int>? v = _lineEndOffsetByLineIdx;
    if (v == null) {
      _computeLineOffsets();
    }
    return _lineEndOffsetByLineIdx!;
  }

  /// 1:1: `_computeLineOffsets`
  void _computeLineOffsets() {
    _lineStartOffsetByLineIdx = <int>[];
    _lineEndOffsetByLineIdx = <int>[];

    _lineStartOffsetByLineIdx!.add(0);
    for (int i = 0; i < text.length; i++) {
      if (text.codeUnitAt(i) == 0x0a) {
        _lineStartOffsetByLineIdx!.add(i + 1);
        if (i > 0 && text.codeUnitAt(i - 1) == 0x0d) {
          _lineEndOffsetByLineIdx!.add(i - 1);
        } else {
          _lineEndOffsetByLineIdx!.add(i);
        }
      }
    }
    _lineEndOffsetByLineIdx!.add(text.length);
  }

  @override
  int getOffset(Position position) {
    final Position valPos = _validatePosition(position);
    return lineStartOffsetByLineIdx[valPos.lineNumber - 1] + valPos.column - 1;
  }

  /// 1:1: `_validatePosition`
  Position _validatePosition(Position position) {
    if (position.lineNumber < 1) {
      return Position(1, 1);
    }
    final int lineCount = this.textLength.lineCount + 1;
    if (position.lineNumber > lineCount) {
      final int lineLength = this.getLineLength(lineCount);
      return Position(lineCount, lineLength + 1);
    }
    if (position.column < 1) {
      return Position(position.lineNumber, 1);
    }
    final int lineLength = this.getLineLength(position.lineNumber);
    if (position.column - 1 > lineLength) {
      return Position(position.lineNumber, lineLength + 1);
    }
    return position;
  }

  @override
  Position getPosition(int offset) {
    final int idx = arraysFind.findLastIdxMonotonous(
      lineStartOffsetByLineIdx,
      (int i) => i <= offset,
    );
    final int lineNumber = idx + 1;
    final int column = offset - lineStartOffsetByLineIdx[idx] + 1;
    return Position(lineNumber, column);
  }

  /// 1:1: `getTextLength`
  TextLength getTextLength(OffsetRange offsetRange) => TextLength.ofRange(this.getRange(offsetRange));

  /// 1:1: `textLength`
  TextLength get textLength {
    final int lineIdx = lineStartOffsetByLineIdx.length - 1;
    return _Deps.deps.textLengthCtor(lineIdx, text.length - lineStartOffsetByLineIdx[lineIdx]);
  }

  /// 1:1: `getLineLength`
  int getLineLength(int lineNumber) =>
      lineEndOffsetByLineIdx[lineNumber - 1] - lineStartOffsetByLineIdx[lineNumber - 1];
}
