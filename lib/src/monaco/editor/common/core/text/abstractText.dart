// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/text/abstractText.ts
// Translated 1:1 from TypeScript.
//   - `Number.MAX_SAFE_INTEGER` -> 0x1FFFFFFFFFFFFF (Dart int is arbitrary precision).
// ---------------------------------------------------------------------------

import '../../../../base/common/assert.dart' as asserts;
import '../../../../base/common/strings.dart' as strings;
import '../position.dart';
import '../ranges/lineRange.dart';
import '../ranges/offsetRange.dart';
import '../range.dart';
import 'positionToOffsetImpl.dart';
import 'textLength.dart';

const int _maxSafeInteger = 0x1FFFFFFFFFFFFF;

/// 1:1: `AbstractText`
abstract class AbstractText {
  String getValueOfRange(Range range);
  TextLength get length;

  Position get endPositionExclusive => this.length.addToPosition(Position(1, 1));

  LineRange get lineRange => this.length.toLineRange();

  String getValue() => this.getValueOfRange(this.length.toRange());

  String getValueOfOffsetRange(OffsetRange range) =>
      this.getValueOfRange(this.getTransformer().getRange(range));

  int getLineLength(int lineNumber) =>
      this.getValueOfRange(Range(lineNumber, 1, lineNumber, _maxSafeInteger)).length;

  PositionOffsetTransformer? _transformer;

  PositionOffsetTransformer getTransformer() {
    PositionOffsetTransformer? t = _transformer;
    if (t == null) {
      t = PositionOffsetTransformer(this.getValue());
      _transformer = t;
    }
    return t;
  }

  String getLineAt(int lineNumber) =>
      this.getValueOfRange(Range(lineNumber, 1, lineNumber, _maxSafeInteger));

  List<String> getLines() => strings.splitLines(this.getValue());

  List<String> getLinesOfRange(LineRange range) =>
      range.mapToLineArray((int lineNumber) => this.getLineAt(lineNumber));

  bool equals(AbstractText other) {
    if (identical(this, other)) {
      return true;
    }
    return this.getValue() == other.getValue();
  }
}

/// 1:1: `LineBasedText`
class LineBasedText extends AbstractText {
  final String Function(int lineNumber) _getLineContent;
  final int _lineCount;

  LineBasedText(this._getLineContent, this._lineCount) {
    asserts.assertCondition(_lineCount >= 1);
  }

  @override
  String getValueOfRange(Range range) {
    if (range.startLineNumber == range.endLineNumber) {
      return this._getLineContent(range.startLineNumber)
          .substring(range.startColumn - 1, range.endColumn - 1);
    }
    String result = this._getLineContent(range.startLineNumber).substring(range.startColumn - 1);
    for (int i = range.startLineNumber + 1; i < range.endLineNumber; i++) {
      result += '\n' + this._getLineContent(i);
    }
    result += '\n' + this._getLineContent(range.endLineNumber).substring(0, range.endColumn - 1);
    return result;
  }

  @override
  int getLineLength(int lineNumber) => this._getLineContent(lineNumber).length;

  @override
  TextLength get length {
    final String lastLine = this._getLineContent(this._lineCount);
    return TextLength(this._lineCount - 1, lastLine.length);
  }
}

/// 1:1: `ArrayText`
class ArrayText extends LineBasedText {
  ArrayText(List<String> lines)
      : super((int lineNumber) => lines[lineNumber - 1], lines.length);
}

/// 1:1: `StringText`
class StringText extends AbstractText {
  late final PositionOffsetTransformer _t;

  final String value;

  StringText(this.value) {
    _t = PositionOffsetTransformer(this.value);
  }

  @override
  String getValueOfRange(Range range) => this._t.getOffsetRange(range).substring(this.value);

  @override
  TextLength get length => this._t.textLength;

  @override
  PositionOffsetTransformer getTransformer() => this._t;
}
