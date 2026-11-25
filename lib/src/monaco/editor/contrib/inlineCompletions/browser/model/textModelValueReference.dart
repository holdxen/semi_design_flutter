// 1:1 port of
// vscode/src/vs/editor/contrib/inlineCompletions/browser/model/textModelValueReference.ts
//
// Adaptations:
//   - `ITextModel` (from ../../../../../common/model.ts, pending) is an opaque
//     local carrier exposing only the members this class actually reads.
//   - `new Error(message)` passed to onUnexpectedError becomes `StateError`,
//     matching the repository's existing error-port convention.
// Runtime truth: tool/ts2dart/_batch261_truth.cjs (recursive TS transpile+vm).

import '../../../../../base/common/errors.dart' as errors;
import '../../../../../base/common/uri.dart' show URI;
import '../../../../common/core/position.dart' show Position;
import '../../../../common/core/range.dart' show Range;
import '../../../../common/core/text/abstractText.dart' show AbstractText;
import '../../../../common/core/text/textLength.dart' show TextLength;

/// 1:1: `ITextModel` (from `../../../../../common/model.ts`, pending) — opaque
/// carrier for the members read by [TextModelValueReference].
abstract class ITextModelForValueReference {
  URI get uri;
  int getVersionId();
  String getValueInRange(Range range);
  int getLineLength(int lineNumber);
  int getLineCount();
  String getEOL();
  Position getPositionAt(int offset);
}

/// 1:1: `TextModelValueReference`
class TextModelValueReference extends AbstractText {
  final int _version;
  final ITextModelForValueReference _textModel;

  /// 1:1: `static snapshot(textModel: ITextModel): TextModelValueReference`
  static TextModelValueReference snapshot(
          ITextModelForValueReference textModel) =>
      TextModelValueReference._(textModel);

  TextModelValueReference._(this._textModel)
      : _version = _textModel.getVersionId();

  URI get uri => _textModel.uri;

  int get version => _version;

  void _assertValid() {
    if (_textModel.getVersionId() != _version) {
      errors.onUnexpectedError(StateError(
          'TextModel has changed: expected version $_version, got ${_textModel.getVersionId()}'));
      // TODO: throw here! (mirrors the upstream comment)
    }
  }

  /// 1:1: `targets(textModel: ITextModel): boolean`
  bool targets(ITextModelForValueReference textModel) =>
      _textModel.uri.toString() == textModel.uri.toString();

  @override
  String getValueOfRange(Range range) {
    _assertValid();
    return _textModel.getValueInRange(range);
  }

  @override
  int getLineLength(int lineNumber) {
    _assertValid();
    return _textModel.getLineLength(lineNumber);
  }

  @override
  TextLength get length {
    _assertValid();
    final int lastLineNumber = _textModel.getLineCount();
    final int lastLineLen = _textModel.getLineLength(lastLineNumber);
    return TextLength(lastLineNumber - 1, lastLineLen);
  }

  String getEOL() {
    _assertValid();
    return _textModel.getEOL();
  }

  Position getPositionAt(int offset) {
    _assertValid();
    return _textModel.getPositionAt(offset);
  }

  String getValueInRange(Range range) {
    _assertValid();
    return _textModel.getValueInRange(range);
  }

  int getVersionId() => _version;

  ITextModelForValueReference dangerouslyGetUnderlyingModel() => _textModel;
}
