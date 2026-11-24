// 1:1 port of
// vscode/src/vs/editor/browser/controller/editContext/screenReaderUtils.ts
//
// The paged screen reader strategy plus the localized aria-label helper.
//
// Adaptations (documented inline):
//  * `EndOfLinePreference` comes from `standalone/standaloneEnums.dart` (see
//    `screenReaderSimpleModel.dart`).
//  * `Math.floor(a / b)` on positive integers -> `a ~/ b`.
//  * `String.fromCharCode(8230)` kept verbatim (U+2026 horizontal ellipsis).
import '../../../../nls.dart' show localize;
import '../../../../platform/accessibility/common/accessibility.dart'
    show AccessibilitySupport;
import '../../../../platform/keybinding/common/keybinding.dart'
    show IKeybindingServiceType;
import '../../../common/config/editorOptions.dart'
    show EditorOption, IComputedEditorOptions;
import '../../../common/core/position.dart' show Position;
import '../../../common/core/range.dart' show Range;
import '../../../common/core/selection.dart' show Selection, SelectionDirection;
import '../../../common/standalone/standaloneEnums.dart'
    show EndOfLinePreference;
import '../../../common/viewModel/screenReaderSimpleModel.dart'
    show ISimpleModel;

/// 1:1: `export interface IPagedScreenReaderStrategy<T>`.
abstract class IPagedScreenReaderStrategy<T> {
  T fromEditorSelection(
    ISimpleModel model,
    Selection selection,
    int linesPerPage,
    bool trimLongText,
  );
}

/// 1:1: `export interface ISimpleScreenReaderContentState`.
class ISimpleScreenReaderContentState {
  ISimpleScreenReaderContentState({
    required this.value,
    required this.selectionStart,
    required this.selectionEnd,
    required this.selection,
    required this.startPositionWithinEditor,
    required this.newlineCountBeforeSelection,
  });

  String value;

  /// the offset where selection starts inside `value`
  int selectionStart;

  /// the offset where selection ends inside `value`
  int selectionEnd;

  /// the editor range in the view coordinate system that matches the selection
  /// inside `value`
  Selection selection;

  /// the position of the start of the `value` in the editor
  Position startPositionWithinEditor;

  /// the visible line count (wrapped, not necessarily matching \n characters)
  /// for the text in `value` before `selectionStart`
  int newlineCountBeforeSelection;
}

/// 1:1: `export class SimplePagedScreenReaderStrategy`.
class SimplePagedScreenReaderStrategy
    implements IPagedScreenReaderStrategy<ISimpleScreenReaderContentState> {
  int _getPageOfLine(int lineNumber, int linesPerPage) {
    return (lineNumber - 1) ~/ linesPerPage;
  }

  Range _getRangeForPage(int page, int linesPerPage) {
    final int offset = page * linesPerPage;
    final int startLineNumber = offset + 1;
    final int endLineNumber = offset + linesPerPage;
    return Range(startLineNumber, 1, endLineNumber + 1, 1);
  }

  @override
  ISimpleScreenReaderContentState fromEditorSelection(
    ISimpleModel model,
    Selection selection,
    int linesPerPage,
    bool trimLongText,
  ) {
    // Chromium handles very poorly text even of a few thousand chars
    // Cut text to avoid stalling the entire UI
    const int LIMIT_CHARS = 500;

    final int selectionStartPage =
        _getPageOfLine(selection.startLineNumber, linesPerPage);
    final Range selectionStartPageRange =
        _getRangeForPage(selectionStartPage, linesPerPage);

    final int selectionEndPage =
        _getPageOfLine(selection.endLineNumber, linesPerPage);
    final Range selectionEndPageRange =
        _getRangeForPage(selectionEndPage, linesPerPage);

    Range pretextRange = selectionStartPageRange.intersectRanges(
        Range(1, 1, selection.startLineNumber, selection.startColumn))!;
    if (trimLongText &&
        model.getValueLengthInRange(
                pretextRange, EndOfLinePreference.LF) >
            LIMIT_CHARS) {
      final Position pretextStart = model.modifyPosition(
          pretextRange.getEndPosition(), -LIMIT_CHARS);
      pretextRange = Range.fromPositions(
          pretextStart,
          end: pretextRange.getEndPosition());
    }
    final String pretext =
        model.getValueInRange(pretextRange, EndOfLinePreference.LF);

    final int lastLine = model.getLineCount();
    final int lastLineMaxColumn = model.getLineMaxColumn(lastLine);
    Range posttextRange = selectionEndPageRange.intersectRanges(
        Range(selection.endLineNumber, selection.endColumn, lastLine,
            lastLineMaxColumn))!;
    if (trimLongText &&
        model.getValueLengthInRange(
                posttextRange, EndOfLinePreference.LF) >
            LIMIT_CHARS) {
      final Position posttextEnd =
          model.modifyPosition(posttextRange.getStartPosition(), LIMIT_CHARS);
      posttextRange = Range.fromPositions(posttextRange.getStartPosition(),
          end: posttextEnd);
    }
    final String posttext =
        model.getValueInRange(posttextRange, EndOfLinePreference.LF);

    final String text;
    if (selectionStartPage == selectionEndPage ||
        selectionStartPage + 1 == selectionEndPage) {
      // take full selection
      text = model.getValueInRange(selection, EndOfLinePreference.LF);
    } else {
      final Range selectionRange1 =
          selectionStartPageRange.intersectRanges(selection)!;
      final Range selectionRange2 =
          selectionEndPageRange.intersectRanges(selection)!;
      text = model.getValueInRange(selectionRange1, EndOfLinePreference.LF) +
          String.fromCharCode(8230) +
          model.getValueInRange(selectionRange2, EndOfLinePreference.LF);
    }
    String trimmedText = text;
    if (trimLongText && trimmedText.length > 2 * LIMIT_CHARS) {
      trimmedText = trimmedText.substring(0, LIMIT_CHARS) +
          String.fromCharCode(8230) +
          trimmedText.substring(trimmedText.length - LIMIT_CHARS);
    }

    final int selectionStart;
    final int selectionEnd;
    if (selection.getDirection() == SelectionDirection.LTR) {
      selectionStart = pretext.length;
      selectionEnd = pretext.length + trimmedText.length;
    } else {
      selectionEnd = pretext.length;
      selectionStart = pretext.length + trimmedText.length;
    }
    return ISimpleScreenReaderContentState(
      value: pretext + trimmedText + posttext,
      selection: selection,
      selectionStart: selectionStart,
      selectionEnd: selectionEnd,
      startPositionWithinEditor: pretextRange.getStartPosition(),
      newlineCountBeforeSelection:
          pretextRange.endLineNumber - pretextRange.startLineNumber,
    );
  }
}

/// 1:1: `export function ariaLabelForScreenReaderContent(options,
/// keybindingService)`.
String? ariaLabelForScreenReaderContent(
  IComputedEditorOptions options,
  IKeybindingServiceType keybindingService,
) {
  final int accessibilitySupport =
      (options.get(EditorOption.accessibilitySupport) as num).toInt();
  if (accessibilitySupport == AccessibilitySupport.Disabled) {
    final String? toggleKeybindingLabel = keybindingService
        .lookupKeybinding('editor.action.toggleScreenReaderAccessibilityMode')
        ?.getAriaLabel();
    final String? runCommandKeybindingLabel = keybindingService
        .lookupKeybinding('workbench.action.showCommands')
        ?.getAriaLabel();
    final String? keybindingEditorKeybindingLabel = keybindingService
        .lookupKeybinding('workbench.action.openGlobalKeybindings')
        ?.getAriaLabel();
    final String editorNotAccessibleMessage = localize('accessibilityModeOff',
        'The editor is not accessible at this time.');
    if (toggleKeybindingLabel != null) {
      return localize(
          'accessibilityOffAriaLabel',
          '{0} To enable screen reader optimized mode, use {1}',
          <Object?>[editorNotAccessibleMessage, toggleKeybindingLabel]);
    } else if (runCommandKeybindingLabel != null) {
      return localize(
          'accessibilityOffAriaLabelNoKb',
          '{0} To enable screen reader optimized mode, open the quick pick with {1} and run the command Toggle Screen Reader Accessibility Mode, which is currently not triggerable via keyboard.',
          <Object?>[editorNotAccessibleMessage, runCommandKeybindingLabel]);
    } else if (keybindingEditorKeybindingLabel != null) {
      return localize(
          'accessibilityOffAriaLabelNoKbs',
          '{0} Please assign a keybinding for the command Toggle Screen Reader Accessibility Mode by accessing the keybindings editor with {1} and run it.',
          <Object?>[editorNotAccessibleMessage, keybindingEditorKeybindingLabel]);
    } else {
      // SOS
      return editorNotAccessibleMessage;
    }
  }
  return options.get(EditorOption.ariaLabel) as String?;
}

/// 1:1: `export function newlinecount(text)`.
int newlinecount(String text) {
  int result = 0;
  int startIndex = -1;
  do {
    startIndex = text.indexOf('\n', startIndex + 1);
    if (startIndex == -1) {
      break;
    }
    result++;
  } while (true);
  return result;
}
