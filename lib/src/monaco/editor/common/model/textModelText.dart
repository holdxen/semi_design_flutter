// ---------------------------------------------------------------------------
// 1:1 port of vscode/src/vs/editor/common/model/textModelText.ts (29 lines).
//
// Adaptations:
//   - `ITextModel` is an erased interface; the model is `Object?` and its three
//     members (`getValueInRange`, `getLineLength`, `getLineCount`) are read
//     dynamically.
//   - `length` is a getter returning the ported `TextLength`.
// ---------------------------------------------------------------------------

import '../core/range.dart' show Range;
import '../core/text/abstractText.dart' show AbstractText;
import '../core/text/textLength.dart' show TextLength;

class TextModelText extends AbstractText {
  TextModelText(this._textModel);

  final Object? _textModel;

  @override
  String getValueOfRange(Range range) {
    final dynamic model = _textModel;
    return model.getValueInRange(range) as String;
  }

  @override
  int getLineLength(int lineNumber) {
    final dynamic model = _textModel;
    return model.getLineLength(lineNumber) as int;
  }

  @override
  TextLength get length {
    final dynamic model = _textModel;
    final int lastLineNumber = model.getLineCount() as int;
    final int lastLineLen = model.getLineLength(lastLineNumber) as int;
    return TextLength(lastLineNumber - 1, lastLineLen);
  }
}
