// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/viewParts/whitespace/whitespace.ts
// Translated 1:1 from TypeScript.
//
// Adaptations (documented inline):
//  * ViewContext / IEditorConfiguration / RenderingContext are used via
//    file-local narrow carriers so the overlay can be replayed without a real
//    editor; the member surface read here matches the TS source exactly.
//  * `strings.firstNonWhitespaceIndex` / `lastNonWhitespaceIndex`, `CharCode`,
//    `OffsetRange`, `Position`, `HorizontalPosition` and `editorWhitespaces`
//    are reused from the already-ported core.
//  * JS `Number(x.toFixed(2))` strips trailing zeros; `_fixedNum` mirrors it.
//  * JS `String.fromCharCode` maps directly to Dart `String.fromCharCode`.
// ---------------------------------------------------------------------------

import '../../view/dynamicViewOverlay.dart' show DynamicViewOverlay;
import '../../view/renderingContext.dart' show RenderingContext;
import '../../../common/viewEventHandler.dart' show ViewEventHandler;
import '../../../common/config/editorOptions.dart' show EditorOption;
import '../../../common/core/position.dart' show Position;
import '../../../common/core/selection.dart' show Selection;
import '../../../common/core/ranges/offsetRange.dart' show OffsetRange;
import '../../../../base/common/charCode.dart' show CharCode;
import '../../../../base/common/strings.dart'
    show firstNonWhitespaceIndex, lastNonWhitespaceIndex;

/// JS number-to-string (no trailing `.0` for integral doubles).
String _jsNum(num value) {
  if (value is int) return value.toString();
  if (value == value.truncate()) return value.toInt().toString();
  return value.toString();
}

/// JS `Number(x.toFixed(2))`: fixed with trailing zeros removed, no `.0`.
String _fixedNum(num value) {
  final String s = value.toStringAsFixed(2);
  if (!s.contains('.')) return s;
  final String trimmed =
      s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  return trimmed == '-0' ? '0' : trimmed;
}

/// The subset of `IEditorConfiguration.options` read here.
abstract class IWhitespaceEditorOptions {
  Object? get(Object id);
}

/// The subset of `IEditorConfiguration` read here (opaque carrier).
abstract class IWhitespaceConfiguration {
  IWhitespaceEditorOptions get options;
  bool hasChanged(Object id);
}

/// The subset of `ViewContext` used by this overlay (opaque carrier).
abstract class IWhitespaceViewContext {
  IWhitespaceConfiguration get configuration;
  Object get viewModel;
  Object get theme;
  void addEventHandler(ViewEventHandler eventHandler);
  void removeEventHandler(ViewEventHandler eventHandler);
}

/// The whitespace overlay visualizes certain whitespace depending on the
/// current editor configuration (boundary, selection, etc.).
class WhitespaceOverlay extends DynamicViewOverlay {
  final IWhitespaceViewContext _context;
  WhitespaceOptions _options;
  List<Selection> _selection = <Selection>[];
  List<String>? _renderResult;

  WhitespaceOverlay(this._context)
      : _options = WhitespaceOptions(_context.configuration) {
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
    final WhitespaceOptions newOptions =
        WhitespaceOptions(_context.configuration);
    if (_options.equals(newOptions)) {
      return e is Map
          ? (e['hasChanged'] as Function)(EditorOption.layoutInfo) as bool
          : false;
    }
    _options = newOptions;
    return true;
  }

  @override
  bool onCursorStateChanged(Object e) {
    _selection = e is Map
        ? (e['selections'] as List<Selection>)
        : <Selection>[];
    if (_options.renderWhitespace == 'selection') {
      return true;
    }
    return false;
  }

  @override
  bool onDecorationsChanged(Object e) => true;

  @override
  bool onFlushed(Object e) => true;

  @override
  bool onLinesChanged(Object e) => true;

  @override
  bool onLinesDeleted(Object e) => true;

  @override
  bool onLinesInserted(Object e) => true;

  @override
  bool onScrollChanged(Object e) =>
      e is Map && e['scrollTopChanged'] == true;

  @override
  bool onZonesChanged(Object e) => true;

  // --- end event handlers

  @override
  void prepareRender(RenderingContext ctx) {
    if (_options.renderWhitespace == 'none') {
      _renderResult = null;
      return;
    }

    // JS assigns by index (auto-extending); the view loop is contiguous.
    _renderResult = <String>[];
    for (int lineNumber = ctx.viewportData.startLineNumber;
        lineNumber <= ctx.viewportData.endLineNumber;
        lineNumber++) {
      // TS reads only these four fields off ViewLineRenderingData; keep it
      // duck-typed so a narrow replay carrier can stand in for the real one.
      final Object lineData =
          (_context.viewModel as dynamic).getViewLineRenderingData(lineNumber)
              as Object;

      List<OffsetRange>? selectionsOnLine;
      if (_options.renderWhitespace == 'selection') {
        for (final Selection selection in _selection) {
          if (selection.endLineNumber < lineNumber ||
              selection.startLineNumber > lineNumber) {
            continue;
          }
          final int startColumn = selection.startLineNumber == lineNumber
              ? selection.startColumn
              : (lineData as dynamic).minColumn as int;
          final int endColumn = selection.endLineNumber == lineNumber
              ? selection.endColumn
              : (lineData as dynamic).maxColumn as int;
          if (startColumn < endColumn) {
            selectionsOnLine ??= <OffsetRange>[];
            selectionsOnLine
                .add(OffsetRange(startColumn - 1, endColumn - 1));
          }
        }
      }

      _renderResult!.add(_applyRenderWhitespace(
        ctx,
        lineNumber,
        selectionsOnLine,
        lineData,
      ));
    }
  }

  String _applyRenderWhitespace(
    RenderingContext ctx,
    int lineNumber,
    List<OffsetRange>? selections,
    Object lineData,
  ) {
    if (_options.renderWhitespace == 'selection' && selections == null) {
      return '';
    }
    if (_options.renderWhitespace == 'trailing' &&
        (lineData as dynamic).continuesWithWrappedLine as bool) {
      return '';
    }
    final Object? color =
        (_context.theme as dynamic).getColor('editorWhitespaces');
    final bool useSvg = _options.renderWithSvg;

    final String lineContent = (lineData as dynamic).content as String;
    final int stopAfter = _options.stopRenderingLineAfter.toInt();
    final int len = stopAfter == -1
        ? lineContent.length
        : (stopAfter < lineContent.length ? stopAfter : lineContent.length);
    final bool continuesWithWrappedLine =
        (lineData as dynamic).continuesWithWrappedLine as bool;
    final int fauxIndentLength = ((lineData as dynamic).minColumn as int) - 1;
    final bool onlyBoundary = _options.renderWhitespace == 'boundary';
    final bool onlyTrailing = _options.renderWhitespace == 'trailing';
    final num lineHeight = ctx.getLineHeightForLineNumber(lineNumber);
    final num middotWidth = _options.middotWidth;
    final num wsmiddotWidth = _options.wsmiddotWidth;
    final num spaceWidth = _options.spaceWidth;
    final num wsmiddotDiff = (wsmiddotWidth - spaceWidth).abs();
    final num middotDiff = (middotWidth - spaceWidth).abs();

    // U+2E31 - WORD SEPARATOR MIDDLE DOT; U+00B7 - MIDDLE DOT
    final int renderSpaceCharCode =
        wsmiddotDiff < middotDiff ? 0x2E31 : 0xB7;
    final bool canUseHalfwidthRightwardsArrow =
        _options.canUseHalfwidthRightwardsArrow;

    String result = '';

    bool lineIsEmptyOrWhitespace = false;
    int firstNonWhitespaceIndexLocal =
        firstNonWhitespaceIndex(lineContent);
    late final int lastNonWhitespaceIndexLocal;
    if (firstNonWhitespaceIndexLocal == -1) {
      lineIsEmptyOrWhitespace = true;
      firstNonWhitespaceIndexLocal = len;
      lastNonWhitespaceIndexLocal = len;
    } else {
      lastNonWhitespaceIndexLocal = lastNonWhitespaceIndex(lineContent);
    }

    int currentSelectionIndex = 0;
    OffsetRange? currentSelection =
        selections != null && currentSelectionIndex < selections.length
            ? selections[currentSelectionIndex]
            : null;
    num maxLeft = 0;

    for (int charIndex = fauxIndentLength;
        charIndex < len;
        charIndex++) {
      final int chCode = lineContent.codeUnitAt(charIndex);

      if (currentSelection != null &&
          currentSelection.endExclusive <= charIndex) {
        currentSelectionIndex++;
        currentSelection = selections != null &&
                currentSelectionIndex < selections.length
            ? selections[currentSelectionIndex]
            : null;
      }

      if (chCode != CharCode.Tab && chCode != CharCode.Space) {
        continue;
      }

      if (onlyTrailing &&
          !lineIsEmptyOrWhitespace &&
          charIndex <= lastNonWhitespaceIndexLocal) {
        continue;
      }

      if (onlyBoundary &&
          charIndex >= firstNonWhitespaceIndexLocal &&
          charIndex <= lastNonWhitespaceIndexLocal &&
          chCode == CharCode.Space) {
        final int prevChCode = charIndex - 1 >= 0
            ? lineContent.codeUnitAt(charIndex - 1)
            : CharCode.Null;
        final int nextChCode = charIndex + 1 < len
            ? lineContent.codeUnitAt(charIndex + 1)
            : CharCode.Null;
        if (prevChCode != CharCode.Space && nextChCode != CharCode.Space) {
          continue;
        }
      }

      if (onlyBoundary &&
          continuesWithWrappedLine &&
          charIndex == len - 1) {
        final int prevCharCode = charIndex - 1 >= 0
            ? lineContent.codeUnitAt(charIndex - 1)
            : CharCode.Null;
        final bool isSingleTrailingSpace = chCode == CharCode.Space &&
            (prevCharCode != CharCode.Space && prevCharCode != CharCode.Tab);
        if (isSingleTrailingSpace) {
          continue;
        }
      }

      if (selections != null &&
          !(currentSelection != null &&
              currentSelection.start <= charIndex &&
              charIndex < currentSelection.endExclusive)) {
        continue;
      }

      final left = ctx.visibleRangeForPosition(
        Position(lineNumber, charIndex + 1),
      );
      if (left == null) {
        continue;
      }

      if (useSvg) {
        final num leftValue = left.left;
        maxLeft = maxLeft > leftValue ? maxLeft : leftValue;
        if (chCode == CharCode.Tab) {
          result += _renderArrow(lineHeight, spaceWidth, leftValue);
        } else {
          result += _renderCircle(lineHeight, spaceWidth, leftValue);
        }
      } else {
        if (chCode == CharCode.Tab) {
          result += '<div class="mwh" style="left:${_jsNum(left.left)}px;'
              'height:${_jsNum(lineHeight)}px;">'
              '${String.fromCharCode(canUseHalfwidthRightwardsArrow ? 0xFFEB : 0x2192)}</div>';
        } else {
          result += '<div class="mwh" style="left:${_jsNum(left.left)}px;'
              'height:${_jsNum(lineHeight)}px;">'
              '${String.fromCharCode(renderSpaceCharCode)}</div>';
        }
      }
    }

    if (useSvg) {
      maxLeft = _jsRound(maxLeft + spaceWidth);
      final int width = maxLeft.toInt();
      final int height = lineHeight.toInt();
      final StringBuffer sb = StringBuffer(
        '<svg style="bottom:0;position:absolute;width:${width}px;'
        'height:${height}px" viewBox="0 0 $width $height" '
        'xmlns="http://www.w3.org/2000/svg" fill="$color">',
      );
      if (result.isNotEmpty) {
        sb.write('<path d="$result" />');
      }
      sb.write('</svg>');
      return sb.toString();
    }

    return result;
  }

  String _renderCircle(num lineHeight, num spaceWidth, num left) {
    // TS: radius/centerX are `Number(x.toFixed(2))` (JS number, zeros stripped);
    // centerY/diameter are raw `.toFixed(2)` strings (two decimals retained).
    final String radius = _fixedNum(spaceWidth / 7);
    final String centerX = _fixedNum(left + spaceWidth / 2);
    final num radiusNum = num.parse(radius);
    final num centerXNum = num.parse(centerX);
    final String centerY = (lineHeight / 2).toStringAsFixed(2);
    final String diameter = (radiusNum * 2).toStringAsFixed(2);
    return 'M ${(centerXNum - radiusNum).toStringAsFixed(2)} $centerY '
        'a $radius $radius 0 1 0 $diameter 0 '
        'a $radius $radius 0 1 0 -$diameter 0 Z ';
  }

  String _renderArrow(num lineHeight, num spaceWidth, num left) {
    final num strokeWidth = spaceWidth / 7;
    final num width = spaceWidth;
    final num dy = lineHeight / 2;
    final num dx = left;

    final Map<String, num> p1 = <String, num>{'x': 0, 'y': strokeWidth / 2};
    final Map<String, num> p2 = <String, num>{
      'x': 100 / 125 * width,
      'y': p1['y']!,
    };
    final Map<String, num> p3 = <String, num>{
      'x': p2['x']! - 0.2 * p2['x']!,
      'y': p2['y']! + 0.2 * p2['x']!,
    };
    final Map<String, num> p4 = <String, num>{
      'x': p3['x']! + 0.1 * p2['x']!,
      'y': p3['y']! + 0.1 * p2['x']!,
    };
    final Map<String, num> p5 = <String, num>{
      'x': p4['x']! + 0.35 * p2['x']!,
      'y': p4['y']! - 0.35 * p2['x']!,
    };
    final Map<String, num> p6 = <String, num>{'x': p5['x']!, 'y': -p5['y']!};
    final Map<String, num> p7 = <String, num>{'x': p4['x']!, 'y': -p4['y']!};
    final Map<String, num> p8 = <String, num>{'x': p3['x']!, 'y': -p3['y']!};
    final Map<String, num> p9 = <String, num>{'x': p2['x']!, 'y': -p2['y']!};
    final Map<String, num> p10 = <String, num>{'x': p1['x']!, 'y': -p1['y']!};

    final List<Map<String, num>> points = <Map<String, num>>[
      p1, p2, p3, p4, p5, p6, p7, p8, p9, p10,
    ];
    final String parts = points
        .map((Map<String, num> p) =>
            '${(dx + p['x']!).toStringAsFixed(2)} '
            '${(dy + p['y']!).toStringAsFixed(2)}')
        .join(' L ');
    return 'M $parts Z ';
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

/// The subset of the editor configuration the overlay reads, snapshotted.
class WhitespaceOptions {
  late final String renderWhitespace;
  late final bool renderWithSvg;
  late final num spaceWidth;
  late final num middotWidth;
  late final num wsmiddotWidth;
  late final bool canUseHalfwidthRightwardsArrow;
  late final num lineHeight;
  late final num stopRenderingLineAfter;

  WhitespaceOptions(IWhitespaceConfiguration config) {
    final IWhitespaceEditorOptions options = config.options;
    final Object? fontInfo = options.get(EditorOption.fontInfo);
    final Object? experimentalWhitespaceRendering =
        options.get(EditorOption.experimentalWhitespaceRendering);
    if (experimentalWhitespaceRendering == 'off') {
      renderWhitespace = 'none';
      renderWithSvg = false;
    } else if (experimentalWhitespaceRendering == 'svg') {
      renderWhitespace = options.get(EditorOption.renderWhitespace) as String;
      renderWithSvg = true;
    } else {
      renderWhitespace = options.get(EditorOption.renderWhitespace) as String;
      renderWithSvg = false;
    }
    spaceWidth = _spaceWidth(fontInfo);
    middotWidth = _middotWidth(fontInfo);
    wsmiddotWidth = _wsmiddotWidth(fontInfo);
    canUseHalfwidthRightwardsArrow =
        _canUseHalfwidthRightwardsArrow(fontInfo);
    lineHeight = options.get(EditorOption.lineHeight) as num;
    stopRenderingLineAfter =
        options.get(EditorOption.stopRenderingLineAfter) as num;
  }

  bool equals(WhitespaceOptions other) =>
      renderWhitespace == other.renderWhitespace &&
      renderWithSvg == other.renderWithSvg &&
      spaceWidth == other.spaceWidth &&
      middotWidth == other.middotWidth &&
      wsmiddotWidth == other.wsmiddotWidth &&
      canUseHalfwidthRightwardsArrow ==
          other.canUseHalfwidthRightwardsArrow &&
      lineHeight == other.lineHeight &&
      stopRenderingLineAfter == other.stopRenderingLineAfter;
}

/// 1:1: `fontInfo.spaceWidth` (real `FontInfo` has these named fields).
num _spaceWidth(Object? fontInfo) =>
    fontInfo == null ? 0 : (fontInfo as dynamic).spaceWidth as num;

num _middotWidth(Object? fontInfo) =>
    fontInfo == null ? 0 : (fontInfo as dynamic).middotWidth as num;

num _wsmiddotWidth(Object? fontInfo) =>
    fontInfo == null ? 0 : (fontInfo as dynamic).wsmiddotWidth as num;

bool _canUseHalfwidthRightwardsArrow(Object? fontInfo) => fontInfo == null
    ? false
    : (fontInfo as dynamic).canUseHalfwidthRightwardsArrow as bool;

/// JS `Math.round` (floor(x + 0.5)).
num _jsRound(num value) => (value + 0.5).floor();
