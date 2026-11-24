// 1:1 port of
// vscode/src/vs/editor/browser/controller/editContext/textArea/textAreaEditContextState.ts
//
// The text area's shadow state: reading it back, comparing it, writing it and
// diffing consecutive states into an input/type event.
//
// Adaptations (documented inline):
//  * `export const _debugComposition` -> public `debugComposition` (Dart cannot
//    export library-private names).
//  * `[Position | null, number, number]` tuple -> a named record.
//  * `switch (direction)` on the `SelectionDirection` enum is exhaustive.
import '../../../../../base/common/strings.dart'
    show commonPrefixLength, commonSuffixLength;
import '../../../../common/core/position.dart' show Position;
import '../../../../common/core/range.dart' show Range;
import '../../../../common/core/selection.dart' show SelectionDirection;
import '../screenReaderUtils.dart' show ISimpleScreenReaderContentState;

/// 1:1: `export const _debugComposition = false`
/// (renamed: Dart cannot export a private top-level constant).
const bool debugComposition = false;

/// 1:1: `export interface ITextAreaWrapper`.
abstract class ITextAreaWrapper {
  String getValue();
  void setValue(String reason, String value);

  int getSelectionStart();
  int getSelectionEnd();
  void setSelectionRange(String reason, int selectionStart, int selectionEnd);
}

/// 1:1: `export interface ITypeData`.
class ITypeData {
  ITypeData({
    required this.text,
    required this.replacePrevCharCnt,
    required this.replaceNextCharCnt,
    required this.positionDelta,
  });

  String text;
  int replacePrevCharCnt;
  int replaceNextCharCnt;
  int positionDelta;
}

/// 1:1: `export class TextAreaState`.
class TextAreaState {
  TextAreaState(
    this.value,
    this.selectionStart,
    this.selectionEnd,
    this.selection,
    this.newlineCountBeforeSelection,
  );

  static final TextAreaState EMPTY =
      TextAreaState('', 0, 0, null, null);

  final String value;

  /// the offset where selection starts inside `value`
  final int selectionStart;

  /// the offset where selection ends inside `value`
  final int selectionEnd;

  /// the editor range in the view coordinate system that matches the selection
  /// inside `value`
  final Range? selection;

  /// the visible line count (wrapped, not necessarily matching \n characters)
  /// for the text in `value` before `selectionStart`
  final int? newlineCountBeforeSelection;

  @override
  String toString() {
    return '[ <$value>, selectionStart: $selectionStart, selectionEnd: $selectionEnd]';
  }

  static TextAreaState readFromTextArea(
    ITextAreaWrapper textArea,
    TextAreaState? previousState,
  ) {
    final String value = textArea.getValue();
    final int selectionStart = textArea.getSelectionStart();
    final int selectionEnd = textArea.getSelectionEnd();
    int? newlineCountBeforeSelection;
    if (previousState != null) {
      final String valueBeforeSelectionStart =
          value.substring(0, selectionStart);
      final String previousValueBeforeSelectionStart = previousState.value
          .substring(0, previousState.selectionStart);
      if (valueBeforeSelectionStart == previousValueBeforeSelectionStart) {
        newlineCountBeforeSelection = previousState.newlineCountBeforeSelection;
      }
    }
    return TextAreaState(
        value, selectionStart, selectionEnd, null, newlineCountBeforeSelection);
  }

  TextAreaState collapseSelection() {
    if (selectionStart == value.length) {
      return this;
    }
    return TextAreaState(value, value.length, value.length, null, null);
  }

  bool isWrittenToTextArea(ITextAreaWrapper textArea, bool select) {
    final bool valuesEqual = value == textArea.getValue();
    if (!select) {
      return valuesEqual;
    }
    final bool selectionsEqual = selectionStart == textArea.getSelectionStart() &&
        selectionEnd == textArea.getSelectionEnd();
    return selectionsEqual && valuesEqual;
  }

  void writeToTextArea(
      String reason, ITextAreaWrapper textArea, bool select) {
    textArea.setValue(reason, value);
    if (select) {
      textArea.setSelectionRange(reason, selectionStart, selectionEnd);
    }
  }

  ({Position? anchor, int delta, int lineFeedCnt}) deduceEditorPosition(
      int offset) {
    if (offset <= selectionStart) {
      final String str = value.substring(offset, selectionStart);
      return _finishDeduceEditorPosition(
          selection?.getStartPosition(), str, -1);
    }
    if (offset >= selectionEnd) {
      final String str = value.substring(selectionEnd, offset);
      return _finishDeduceEditorPosition(selection?.getEndPosition(), str, 1);
    }
    final String str1 = value.substring(selectionStart, offset);
    if (!str1.contains(String.fromCharCode(8230))) {
      return _finishDeduceEditorPosition(selection?.getStartPosition(), str1, 1);
    }
    final String str2 = value.substring(offset, selectionEnd);
    return _finishDeduceEditorPosition(selection?.getEndPosition(), str2, -1);
  }

  ({Position? anchor, int delta, int lineFeedCnt}) _finishDeduceEditorPosition(
      Position? anchor, String deltaText, int signum) {
    int lineFeedCnt = 0;
    int lastLineFeedIndex = -1;
    while ((lastLineFeedIndex = deltaText.indexOf('\n', lastLineFeedIndex + 1)) !=
        -1) {
      lineFeedCnt++;
    }
    return (
      anchor: anchor,
      delta: signum * deltaText.length,
      lineFeedCnt: lineFeedCnt
    );
  }

  static ITypeData deduceInput(
    TextAreaState? previousState,
    TextAreaState currentState,
    bool couldBeEmojiInput,
  ) {
    if (previousState == null) {
      // This is the EMPTY state
      return ITypeData(
        text: '',
        replacePrevCharCnt: 0,
        replaceNextCharCnt: 0,
        positionDelta: 0,
      );
    }

    final int prefixLength = _min3(
      commonPrefixLength(previousState.value, currentState.value),
      previousState.selectionStart,
      currentState.selectionStart,
    );
    final int suffixLength = _min3(
      commonSuffixLength(previousState.value, currentState.value),
      previousState.value.length - previousState.selectionEnd,
      currentState.value.length - currentState.selectionEnd,
    );
    final String currentValue = currentState.value.substring(
        prefixLength, currentState.value.length - suffixLength);
    final int previousSelectionStart =
        previousState.selectionStart - prefixLength;
    final int previousSelectionEnd = previousState.selectionEnd - prefixLength;
    final int currentSelectionStart =
        currentState.selectionStart - prefixLength;
    final int currentSelectionEnd = currentState.selectionEnd - prefixLength;

    if (currentSelectionStart == currentSelectionEnd) {
      // no current selection
      final int replacePreviousCharacters =
          (previousState.selectionStart - prefixLength);
      return ITypeData(
        text: currentValue,
        replacePrevCharCnt: replacePreviousCharacters,
        replaceNextCharCnt: 0,
        positionDelta: 0,
      );
    }

    // there is a current selection => composition case
    final int replacePreviousCharacters =
        previousSelectionEnd - previousSelectionStart;
    return ITypeData(
      text: currentValue,
      replacePrevCharCnt: replacePreviousCharacters,
      replaceNextCharCnt: 0,
      positionDelta: 0,
    );
  }

  static ITypeData deduceAndroidCompositionInput(
    TextAreaState? previousState,
    TextAreaState currentState,
  ) {
    if (previousState == null) {
      // This is the EMPTY state
      return ITypeData(
        text: '',
        replacePrevCharCnt: 0,
        replaceNextCharCnt: 0,
        positionDelta: 0,
      );
    }

    if (previousState.value == currentState.value) {
      return ITypeData(
        text: '',
        replacePrevCharCnt: 0,
        replaceNextCharCnt: 0,
        positionDelta:
            currentState.selectionEnd - previousState.selectionEnd,
      );
    }

    final int prefixLength = _min2(
      commonPrefixLength(previousState.value, currentState.value),
      previousState.selectionEnd,
    );
    final int suffixLength = _min2(
      commonSuffixLength(previousState.value, currentState.value),
      previousState.value.length - previousState.selectionEnd,
    );
    final String previousValue = previousState.value.substring(
        prefixLength, previousState.value.length - suffixLength);
    final String currentValue = currentState.value.substring(
        prefixLength, currentState.value.length - suffixLength);
    final int previousSelectionEnd = previousState.selectionEnd - prefixLength;
    final int currentSelectionEnd = currentState.selectionEnd - prefixLength;

    return ITypeData(
      text: currentValue,
      replacePrevCharCnt: previousSelectionEnd,
      replaceNextCharCnt: previousValue.length - previousSelectionEnd,
      positionDelta: currentSelectionEnd - currentValue.length,
    );
  }

  static TextAreaState fromScreenReaderContentState(
      ISimpleScreenReaderContentState screenReaderContentState) {
    final int selectionStart;
    final int selectionEnd;
    final SelectionDirection direction =
        screenReaderContentState.selection.getDirection();
    switch (direction) {
      case SelectionDirection.LTR:
        selectionStart = screenReaderContentState.selectionStart;
        selectionEnd = screenReaderContentState.selectionEnd;
        break;
      case SelectionDirection.RTL:
        selectionStart = screenReaderContentState.selectionEnd;
        selectionEnd = screenReaderContentState.selectionStart;
        break;
    }
    return TextAreaState(
      screenReaderContentState.value,
      selectionStart,
      selectionEnd,
      screenReaderContentState.selection,
      screenReaderContentState.newlineCountBeforeSelection,
    );
  }
}

int _min2(int a, int b) => a < b ? a : b;
int _min3(int a, int b, int c) => _min2(_min2(a, b), c);
