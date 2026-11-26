// 1:1 port of vscode/src/vs/editor/browser/viewParts/selections/selections.ts @bfbf12b
// Adaptations (documented inline):
//   - TS interfaces/enums are small Dart classes with int constants
//     (`CornerStyle`, `_IVisibleRangeEndPointStyle`).
//   - `ViewContext` carriers are read via `dynamic`; base handler overrides
//     take `Object` and cast only where the source reads the event.
//   - `output2: [string, string][]` is `List<List<String>>` (inner/outer HTML).
//   - Numeric HTML values use JS `String(number)` semantics (no trailing `.0`).
//   - The top-level theming participant body is exposed for truth replay.
// Runtime truth: tool/ts2dart/_batch343_truth.cjs.

import '../../../../base/common/color.dart' show Color;
import '../../../../base/common/lifecycle.dart' show IDisposable;
import '../../../../platform/theme/common/colors/editorColors.dart'
    show editorSelectionForeground;
import '../../../../platform/theme/common/themeService.dart'
    show ICssStyleCollector, IColorTheme, registerThemingParticipant;
import '../../../common/config/editorOptions.dart' show EditorOption;
import '../../../common/config/fontInfo.dart' show FontInfo;
import '../../../common/core/range.dart' show Range;
import '../../../common/viewEvents.dart' show ViewCursorStateChangedEvent;
import '../../../common/viewModel/viewContext.dart' show ViewContext;
import '../../view/dynamicViewOverlay.dart' show DynamicViewOverlay;
import '../../view/renderingContext.dart'
    show HorizontalRange, LineVisibleRanges, RenderingContext;

/// 1:1: `const enum CornerStyle`.
class CornerStyle {
  static const int EXTERN = 0;
  static const int INTERN = 1;
  static const int FLAT = 2;

  const CornerStyle._();
}

/// 1:1: `interface IVisibleRangeEndPointStyle`.
class _IVisibleRangeEndPointStyle {
  _IVisibleRangeEndPointStyle(this.top, this.bottom);

  int top;
  int bottom;
}

/// 1:1: `class HorizontalRangeWithStyle`.
class HorizontalRangeWithStyle {
  HorizontalRangeWithStyle(HorizontalRange other)
    : left = other.left,
      width = other.width;

  num left;
  num width;
  _IVisibleRangeEndPointStyle? startStyle;
  _IVisibleRangeEndPointStyle? endStyle;
}

/// 1:1: `class LineVisibleRangesWithStyle`.
class LineVisibleRangesWithStyle {
  LineVisibleRangesWithStyle(this.lineNumber, this.ranges);

  final int lineNumber;
  final List<HorizontalRangeWithStyle> ranges;
}

/// 1:1: `function toStyledRange`.
HorizontalRangeWithStyle toStyledRange(HorizontalRange item) =>
    HorizontalRangeWithStyle(item);

/// 1:1: `function toStyled`.
LineVisibleRangesWithStyle toStyled(LineVisibleRanges item) =>
    LineVisibleRangesWithStyle(
      item.lineNumber,
      item.ranges.map(toStyledRange).toList(),
    );

/// JS `String(number)` semantics: integer-valued doubles print without `.0`.
String _jsNum(num value) {
  if (value is int) {
    return value.toString();
  }
  final double asDouble = value.toDouble();
  if (asDouble == asDouble.roundToDouble()) {
    return asDouble.toInt().toString();
  }
  return asDouble.toString();
}

num _abs(num n) => n < 0 ? -n : n;

/// 1:1: `LineVisibleRangesWithStyle[]` stored per selection.
typedef StyledRanges = List<LineVisibleRangesWithStyle>;

void _setStyleAt(List<StyledRanges?> list, int index, StyledRanges? value) {
  while (list.length <= index) {
    list.add(null);
  }
  list[index] = value;
}

StyledRanges? _getStyleAt(List<StyledRanges?> list, int index) =>
    index >= 0 && index < list.length ? list[index] : null;

/// This view part displays selected text to the user. Every line has its own
/// selection overlay.
class SelectionsOverlay extends DynamicViewOverlay {
  static const String SELECTION_CLASS_NAME = 'selected-text';
  static const String SELECTION_TOP_LEFT = 'top-left-radius';
  static const String SELECTION_BOTTOM_LEFT = 'bottom-left-radius';
  static const String SELECTION_TOP_RIGHT = 'top-right-radius';
  static const String SELECTION_BOTTOM_RIGHT = 'bottom-right-radius';
  static const String EDITOR_BACKGROUND_CLASS_NAME = 'monaco-editor-background';
  static const int ROUNDED_PIECE_WIDTH = 10;

  late final ViewContext _context;
  late bool _roundedSelection;
  late num _typicalHalfwidthCharacterWidth;
  List<Range> _selections = <Range>[];
  List<String>? _renderResult;

  SelectionsOverlay(ViewContext context) : super() {
    _context = context;
    final dynamic options = (_context.configuration as dynamic).options;
    _roundedSelection = options.get(EditorOption.roundedSelection) as bool;
    _typicalHalfwidthCharacterWidth =
        (options.get(EditorOption.fontInfo) as FontInfo)
            .typicalHalfwidthCharacterWidth;
    _selections = <Range>[];
    _renderResult = null;
    _context.addEventHandler(this);
  }

  @override
  void dispose() {
    _context.removeEventHandler(this);
    _renderResult = null;
    super.dispose();
  }

  // --- begin event handlers

  @override
  bool onConfigurationChanged(Object e) {
    final dynamic options = (_context.configuration as dynamic).options;
    _roundedSelection = options.get(EditorOption.roundedSelection) as bool;
    _typicalHalfwidthCharacterWidth =
        (options.get(EditorOption.fontInfo) as FontInfo)
            .typicalHalfwidthCharacterWidth;
    return true;
  }

  @override
  bool onCursorStateChanged(Object e) {
    e as ViewCursorStateChangedEvent;
    _selections = List<Range>.from(e.selections);
    return true;
  }

  @override
  bool onDecorationsChanged(Object e) {
    // true for inline decorations that can end up relayouting text
    return true;
  }

  @override
  bool onFlushed(Object e) {
    return true;
  }

  @override
  bool onLinesChanged(Object e) {
    return true;
  }

  @override
  bool onLinesDeleted(Object e) {
    return true;
  }

  @override
  bool onLinesInserted(Object e) {
    return true;
  }

  @override
  bool onScrollChanged(Object e) => (e as dynamic).scrollTopChanged as bool;

  @override
  bool onZonesChanged(Object e) {
    return true;
  }

  // --- end event handlers

  bool _visibleRangesHaveGaps(List<LineVisibleRangesWithStyle> ranges) {
    for (final LineVisibleRangesWithStyle line in ranges) {
      if (line.ranges.length > 1) {
        // There are two ranges on the same line
        return true;
      }
    }
    return false;
  }

  void _enrichVisibleRangesWithStyle(
    Range viewport,
    List<LineVisibleRangesWithStyle> ranges,
    StyledRanges? previousFrame,
  ) {
    final num epsilon = _typicalHalfwidthCharacterWidth / 4;
    HorizontalRangeWithStyle? previousFrameTop;
    HorizontalRangeWithStyle? previousFrameBottom;

    if (previousFrame != null &&
        previousFrame.isNotEmpty &&
        ranges.isNotEmpty) {
      final int topLineNumber = ranges[0].lineNumber;
      if (topLineNumber == viewport.startLineNumber) {
        for (int i = 0;
            previousFrameTop == null && i < previousFrame.length;
            i++) {
          final LineVisibleRangesWithStyle frame = previousFrame[i];
          if (frame.lineNumber == topLineNumber && frame.ranges.isNotEmpty) {
            previousFrameTop = frame.ranges[0];
          }
        }
      }

      final int bottomLineNumber = ranges[ranges.length - 1].lineNumber;
      if (bottomLineNumber == viewport.endLineNumber) {
        for (int i = previousFrame.length - 1;
            previousFrameBottom == null && i >= 0;
            i--) {
          final LineVisibleRangesWithStyle frame = previousFrame[i];
          if (frame.lineNumber == bottomLineNumber && frame.ranges.isNotEmpty) {
            previousFrameBottom = frame.ranges[0];
          }
        }
      }

      if (previousFrameTop != null && previousFrameTop.startStyle == null) {
        previousFrameTop = null;
      }
      if (previousFrameBottom != null &&
          previousFrameBottom.startStyle == null) {
        previousFrameBottom = null;
      }
    }

    for (int i = 0; i < ranges.length; i++) {
      // We know for a fact that there is precisely one range on each line
      final HorizontalRangeWithStyle cur = ranges[i].ranges[0];
      final num curLeft = cur.left;
      final num curRight = cur.left + cur.width;

      final _IVisibleRangeEndPointStyle startStyle =
          _IVisibleRangeEndPointStyle(CornerStyle.EXTERN, CornerStyle.EXTERN);
      final _IVisibleRangeEndPointStyle endStyle =
          _IVisibleRangeEndPointStyle(CornerStyle.EXTERN, CornerStyle.EXTERN);

      if (i > 0) {
        // Look above
        final HorizontalRangeWithStyle prev = ranges[i - 1].ranges[0];
        final num prevLeft = prev.left;
        final num prevRight = prev.left + prev.width;

        if (_abs(curLeft - prevLeft) < epsilon) {
          startStyle.top = CornerStyle.FLAT;
        } else if (curLeft > prevLeft) {
          startStyle.top = CornerStyle.INTERN;
        }

        if (_abs(curRight - prevRight) < epsilon) {
          endStyle.top = CornerStyle.FLAT;
        } else if (prevLeft < curRight && curRight < prevRight) {
          endStyle.top = CornerStyle.INTERN;
        }
      } else if (previousFrameTop != null) {
        // Accept some hiccups near the viewport edges to save on repaints
        startStyle.top = previousFrameTop.startStyle!.top;
        endStyle.top = previousFrameTop.endStyle!.top;
      }

      if (i + 1 < ranges.length) {
        // Look below
        final HorizontalRangeWithStyle next = ranges[i + 1].ranges[0];
        final num nextLeft = next.left;
        final num nextRight = next.left + next.width;

        if (_abs(curLeft - nextLeft) < epsilon) {
          startStyle.bottom = CornerStyle.FLAT;
        } else if (nextLeft < curLeft && curLeft < nextRight) {
          startStyle.bottom = CornerStyle.INTERN;
        }

        if (_abs(curRight - nextRight) < epsilon) {
          endStyle.bottom = CornerStyle.FLAT;
        } else if (curRight < nextRight) {
          endStyle.bottom = CornerStyle.INTERN;
        }
      } else if (previousFrameBottom != null) {
        // Accept some hiccups near the viewport edges to save on repaints
        startStyle.bottom = previousFrameBottom.startStyle!.bottom;
        endStyle.bottom = previousFrameBottom.endStyle!.bottom;
      }

      cur.startStyle = startStyle;
      cur.endStyle = endStyle;
    }
  }

  List<LineVisibleRangesWithStyle> _getVisibleRangesWithStyle(
    Range selection,
    RenderingContext ctx,
    StyledRanges? previousFrame,
  ) {
    final List<LineVisibleRanges> visible =
        ctx.linesVisibleRangesForRange(selection, true) ?? <LineVisibleRanges>[];
    final List<LineVisibleRangesWithStyle> ranges =
        visible.map(toStyled).toList();
    final bool haveGaps = _visibleRangesHaveGaps(ranges);

    if (!haveGaps && _roundedSelection) {
      _enrichVisibleRangesWithStyle(ctx.visibleRange, ranges, previousFrame);
    }

    // The visible ranges are sorted TOP-BOTTOM and LEFT-RIGHT
    return ranges;
  }

  String _createSelectionPiece(
      num top, num bottom, String className, num left, num width) {
    return '<div class="cslr '
        '$className'
        '" style="'
        'top:${_jsNum(top)}px;'
        'bottom:${_jsNum(bottom)}px;'
        'left:${_jsNum(left)}px;'
        'width:${_jsNum(width)}px;'
        '"></div>';
  }

  void _actualRenderOneSelection(
    List<List<String>> output,
    int visibleStartLineNumber,
    bool hasMultipleSelections,
    List<LineVisibleRangesWithStyle> ranges,
  ) {
    if (ranges.isEmpty) {
      return;
    }

    final bool haveStyle = ranges[0].ranges[0].startStyle != null;
    final int firstLineNumber = ranges[0].lineNumber;
    final int lastLineNumber = ranges[ranges.length - 1].lineNumber;

    for (final LineVisibleRangesWithStyle line in ranges) {
      final int lineNumber = line.lineNumber;
      final int lineIndex = lineNumber - visibleStartLineNumber;

      final int top = hasMultipleSelections && lineNumber == firstLineNumber
          ? 1
          : 0;
      final int bottom = hasMultipleSelections &&
              lineNumber != firstLineNumber &&
              lineNumber == lastLineNumber
          ? 1
          : 0;

      String innerCornerOutput = '';
      String restOfSelectionOutput = '';

      for (final HorizontalRangeWithStyle range in line.ranges) {
        if (haveStyle) {
          final _IVisibleRangeEndPointStyle startStyle = range.startStyle!;
          final _IVisibleRangeEndPointStyle endStyle = range.endStyle!;
          if (startStyle.top == CornerStyle.INTERN ||
              startStyle.bottom == CornerStyle.INTERN) {
            // Reverse rounded corner to the left

            // First comes the selection (blue layer)
            innerCornerOutput += _createSelectionPiece(
                top, bottom, SELECTION_CLASS_NAME,
                range.left - ROUNDED_PIECE_WIDTH, ROUNDED_PIECE_WIDTH);

            // Second comes the background (white layer) with inverse border radius
            String className = EDITOR_BACKGROUND_CLASS_NAME;
            if (startStyle.top == CornerStyle.INTERN) {
              className += ' $SELECTION_TOP_RIGHT';
            }
            if (startStyle.bottom == CornerStyle.INTERN) {
              className += ' $SELECTION_BOTTOM_RIGHT';
            }
            innerCornerOutput += _createSelectionPiece(
                top, bottom, className,
                range.left - ROUNDED_PIECE_WIDTH, ROUNDED_PIECE_WIDTH);
          }
          if (endStyle.top == CornerStyle.INTERN ||
              endStyle.bottom == CornerStyle.INTERN) {
            // Reverse rounded corner to the right

            // First comes the selection (blue layer)
            innerCornerOutput += _createSelectionPiece(
                top, bottom, SELECTION_CLASS_NAME,
                range.left + range.width, ROUNDED_PIECE_WIDTH);

            // Second comes the background (white layer) with inverse border radius
            String className = EDITOR_BACKGROUND_CLASS_NAME;
            if (endStyle.top == CornerStyle.INTERN) {
              className += ' $SELECTION_TOP_LEFT';
            }
            if (endStyle.bottom == CornerStyle.INTERN) {
              className += ' $SELECTION_BOTTOM_LEFT';
            }
            innerCornerOutput += _createSelectionPiece(
                top, bottom, className,
                range.left + range.width, ROUNDED_PIECE_WIDTH);
          }
        }

        String className = SELECTION_CLASS_NAME;
        if (haveStyle) {
          final _IVisibleRangeEndPointStyle startStyle = range.startStyle!;
          final _IVisibleRangeEndPointStyle endStyle = range.endStyle!;
          if (startStyle.top == CornerStyle.EXTERN) {
            className += ' $SELECTION_TOP_LEFT';
          }
          if (startStyle.bottom == CornerStyle.EXTERN) {
            className += ' $SELECTION_BOTTOM_LEFT';
          }
          if (endStyle.top == CornerStyle.EXTERN) {
            className += ' $SELECTION_TOP_RIGHT';
          }
          if (endStyle.bottom == CornerStyle.EXTERN) {
            className += ' $SELECTION_BOTTOM_RIGHT';
          }
        }
        restOfSelectionOutput +=
            _createSelectionPiece(top, bottom, className, range.left, range.width);
      }

      if (lineIndex >= 0 && lineIndex < output.length) {
        output[lineIndex][0] += innerCornerOutput;
        output[lineIndex][1] += restOfSelectionOutput;
      }
    }
  }

  List<StyledRanges?> _previousFrameVisibleRangesWithStyle =
      <StyledRanges?>[];

  @override
  void prepareRender(RenderingContext ctx) {
    // Build HTML for inner corners separate from HTML for the rest of selections,
    // as the inner corner HTML can interfere with that of other selections.
    // In final render, make sure to place the inner corner HTML before the rest
    // of selection HTML. See issue #77777.
    final List<List<String>> output = <List<String>>[];
    final int visibleStartLineNumber = ctx.visibleRange.startLineNumber;
    final int visibleEndLineNumber = ctx.visibleRange.endLineNumber;
    for (int lineNumber = visibleStartLineNumber;
        lineNumber <= visibleEndLineNumber;
        lineNumber++) {
      final int lineIndex = lineNumber - visibleStartLineNumber;
      while (output.length <= lineIndex) {
        output.add(<String>['', '']);
      }
      output[lineIndex] = <String>['', ''];
    }

    final List<StyledRanges?> thisFrame = <StyledRanges?>[];
    for (int i = 0; i < _selections.length; i++) {
      final Range selection = _selections[i];
      if (selection.isEmpty()) {
        _setStyleAt(thisFrame, i, null);
        continue;
      }

      final StyledRanges ranges = _getVisibleRangesWithStyle(
        selection,
        ctx,
        _getStyleAt(_previousFrameVisibleRangesWithStyle, i),
      );
      _setStyleAt(thisFrame, i, ranges);
      _actualRenderOneSelection(
        output,
        visibleStartLineNumber,
        _selections.length > 1,
        ranges,
      );
    }

    _previousFrameVisibleRangesWithStyle = thisFrame;
    _renderResult = output
        .map((List<String> pair) => pair[0] + pair[1])
        .toList();
  }

  @override
  String render(int startLineNumber, int lineNumber) {
    final List<String>? result = _renderResult;
    if (result == null) {
      return '';
    }
    final int lineIndex = lineNumber - startLineNumber;
    if (lineIndex < 0 || lineIndex >= result.length) {
      return '';
    }
    return result[lineIndex];
  }
}

/// 1:1: top-level theming participant body (exposed so tests can replay it).
void selectionsTheming(
    IColorTheme theme, ICssStyleCollector collector, dynamic environment) {
  final Color? color = theme.getColor(editorSelectionForeground);
  if (color != null && !color.isTransparent()) {
    collector.addRule(
        '.monaco-editor .view-line span.inline-selected-text { color: $color; }');
  }
}

/// 1:1: `registerThemingParticipant(...)` module side effect.
final IDisposable selectionsThemingParticipant =
    registerThemingParticipant(selectionsTheming);
