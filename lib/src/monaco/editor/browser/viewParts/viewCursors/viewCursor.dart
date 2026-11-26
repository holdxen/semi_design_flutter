// 1:1 port of vscode/src/vs/editor/browser/viewParts/viewCursors/viewCursor.ts @bfbf12b
// Adaptations (documented inline):
//   - TS tuples/interfaces are replayed as small Dart classes (`_GraphemePosition`,
//     `IViewCursorRenderData`) with the same field names.
//   - `ViewContext.viewModel` / `.viewLayout` carriers are read via `dynamic`
//     because their ported interfaces do not expose the members used here.
//   - `TextEditorCursorStyle` and `CursorPlurality` are int constant classes;
//     default is grouped with Single (Dart requires `default` last).
//   - `FastDomNode<HTMLElement>` is a narrow carrier (IFastDomNode) with a
//     dom.dart DomElement underneath, following editorScrollbar.dart's pattern;
//     `applyFontInfo` is handed the raw DomElement (its dynamic style branch).
//   - Numeric CSS values use JS `String(number)` semantics (no trailing `.0`
//     for integral doubles), matching `numberAsPixels` in the TS fast path.
// Runtime truth: tool/ts2dart/_batch341_truth.cjs.

import 'dart:math' as math show min;

import '../../../../base/browser/dom.dart'
    show DomElement, computeScreenAwareSize, document, getWindow;
import '../../../../base/browser/ui/mouseCursor/mouseCursor.dart'
    show MOUSE_CURSOR_TEXT_CSS_CLASS_NAME;
import '../../../../base/common/strings.dart' show getCharContainingOffset;
import '../../../common/config/editorOptions.dart'
    show EditorOption, TextEditorCursorStyle;
import '../../../common/config/fontInfo.dart' show FontInfo;
import '../../../common/core/position.dart' show Position;
import '../../../common/core/range.dart' show Range;
import '../../../common/viewEvents.dart' show ViewConfigurationChangedEvent;
import '../../../common/viewModel/viewContext.dart' show ViewContext;
import '../../config/domFontInfo.dart' show applyFontInfo;
import '../../view/renderingContext.dart'
    show HorizontalPosition, LineVisibleRanges, RenderingContext,
    RestrictedRenderingContext;

/// 1:1: `FastDomNode<HTMLElement>` subset used here (opaque carrier).
abstract class IFastDomNode {
  DomElement get domNode;
  void setClassName(String className);
  void setHeight(Object height);
  void setTop(Object top);
  void setLeft(Object left);
  void setDisplay(String display);
  void setVisibility(String visibility);
  void setPaddingLeft(Object paddingLeft);
  void setWidth(Object width);
  void setLineHeight(Object lineHeight);
}

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

String _jsPixels(Object value) =>
    value is num ? '${_jsNum(value)}px' : value as String;

/// 1:1: `createFastDomNode(document.createElement('div'))`.
class _FastDomNodeCarrier implements IFastDomNode {
  _FastDomNodeCarrier(this.domNode);

  @override
  final DomElement domNode;

  String _className = '';
  String _height = '';
  String _top = '';
  String _left = '';
  String _display = '';
  String _visibility = '';
  String _paddingLeft = '';
  String _width = '';
  String _lineHeight = '';

  void _setStyle(String key, Object raw, String field, void Function(String) write) {
    final String value = _jsPixels(raw);
    if (field == value) {
      return;
    }
    write(value);
    domNode.style[key] = value;
  }

  @override
  void setClassName(String className) {
    if (_className == className) {
      return;
    }
    _className = className;
    domNode.className = className;
  }

  @override
  void setHeight(Object height) =>
      _setStyle('height', height, _height, (String v) => _height = v);

  @override
  void setTop(Object top) =>
      _setStyle('top', top, _top, (String v) => _top = v);

  @override
  void setLeft(Object left) =>
      _setStyle('left', left, _left, (String v) => _left = v);

  @override
  void setDisplay(String display) {
    if (_display == display) {
      return;
    }
    _display = display;
    domNode.style['display'] = display;
  }

  @override
  void setVisibility(String visibility) {
    if (_visibility == visibility) {
      return;
    }
    _visibility = visibility;
    domNode.style['visibility'] = visibility;
  }

  @override
  void setPaddingLeft(Object paddingLeft) => _setStyle(
      'paddingLeft', paddingLeft, _paddingLeft, (String v) => _paddingLeft = v);

  @override
  void setWidth(Object width) =>
      _setStyle('width', width, _width, (String v) => _width = v);

  @override
  void setLineHeight(Object lineHeight) => _setStyle(
      'lineHeight', lineHeight, _lineHeight, (String v) => _lineHeight = v);
}

/// 1:1: `export interface IViewCursorRenderData`.
class IViewCursorRenderData {
  IViewCursorRenderData(
    this.domNode,
    this.position,
    this.contentLeft,
    this.width,
    this.height,
  );

  final DomElement domNode;
  final Position position;
  final num contentLeft;
  final num width;
  final num height;
}

/// 1:1: `class ViewCursorRenderData`.
class ViewCursorRenderData {
  ViewCursorRenderData(
    this.top,
    this.left,
    this.paddingLeft,
    this.width,
    this.height,
    this.textContent,
    this.textContentClassName,
  );

  final num top;
  final num left;
  final num paddingLeft;
  final num width;
  final num height;
  final String textContent;
  final String textContentClassName;
}

/// 1:1: `export enum CursorPlurality`.
class CursorPlurality {
  static const int Single = 0;
  static const int MultiPrimary = 1;
  static const int MultiSecondary = 2;

  const CursorPlurality._();
}

/// 1:1: `[Position, string]` returned by `_getGraphemeAwarePosition`.
class _GraphemePosition {
  const _GraphemePosition(this.position, this.grapheme);

  final Position position;
  final String grapheme;
}

/// 1:1: `export class ViewCursor`.
class ViewCursor {
  late final ViewContext _context;
  late final IFastDomNode _domNode;

  late int _cursorStyle;
  late num _lineCursorWidth;
  late num _lineCursorHeight;
  late num _typicalHalfwidthCharacterWidth;

  bool _isVisible = true;

  Position _position = Position(1, 1);
  String _pluralityClass = '';

  String _lastRenderedContent = '';
  ViewCursorRenderData? _renderData;

  ViewCursor(ViewContext context, int plurality) {
    _context = context;
    final dynamic options = (context.configuration as dynamic).options;
    final FontInfo fontInfo = options.get(EditorOption.fontInfo) as FontInfo;

    _cursorStyle = options.get(EditorOption.effectiveCursorStyle) as int;
    _typicalHalfwidthCharacterWidth = fontInfo.typicalHalfwidthCharacterWidth;
    _lineCursorWidth = math.min(
      options.get(EditorOption.cursorWidth) as num,
      _typicalHalfwidthCharacterWidth,
    );
    _lineCursorHeight = options.get(EditorOption.cursorHeight) as num;

    // Create the dom node
    _domNode = _FastDomNodeCarrier(document.createElement('div'));
    _domNode.setClassName('cursor $MOUSE_CURSOR_TEXT_CSS_CLASS_NAME');
    _domNode.setHeight(
      (context.viewLayout as dynamic).getLineHeightForLineNumber(1) as num,
    );
    _domNode.setTop(0);
    _domNode.setLeft(0);
    applyFontInfo(_domNode.domNode, fontInfo);
    _domNode.setDisplay('none');

    setPlurality(plurality);

    _lastRenderedContent = '';
    _renderData = null;
  }

  /// 1:1: `public getDomNode()`.
  IFastDomNode getDomNode() => _domNode;

  /// 1:1: `public getPosition()`.
  Position getPosition() => _position;

  /// 1:1: `public setPlurality(plurality)`.
  void setPlurality(int plurality) {
    switch (plurality) {
      case CursorPlurality.MultiPrimary:
        _pluralityClass = 'cursor-primary';
        break;

      case CursorPlurality.MultiSecondary:
        _pluralityClass = 'cursor-secondary';
        break;

      case CursorPlurality.Single:
      default:
        _pluralityClass = '';
        break;
    }
  }

  /// 1:1: `public show()`.
  void show() {
    if (!_isVisible) {
      _domNode.setVisibility('inherit');
      _isVisible = true;
    }
  }

  /// 1:1: `public hide()`.
  void hide() {
    if (_isVisible) {
      _domNode.setVisibility('hidden');
      _isVisible = false;
    }
  }

  /// 1:1: `public onConfigurationChanged(e)`.
  bool onConfigurationChanged(ViewConfigurationChangedEvent e) {
    final dynamic options = (_context.configuration as dynamic).options;
    final FontInfo fontInfo = options.get(EditorOption.fontInfo) as FontInfo;

    _cursorStyle = options.get(EditorOption.effectiveCursorStyle) as int;
    _typicalHalfwidthCharacterWidth = fontInfo.typicalHalfwidthCharacterWidth;
    _lineCursorWidth = math.min(
      options.get(EditorOption.cursorWidth) as num,
      _typicalHalfwidthCharacterWidth,
    );
    _lineCursorHeight = options.get(EditorOption.cursorHeight) as num;
    applyFontInfo(_domNode.domNode, fontInfo);

    return true;
  }

  /// 1:1: `public onCursorPositionChanged(position, pauseAnimation)`.
  bool onCursorPositionChanged(Position position, bool pauseAnimation) {
    if (pauseAnimation) {
      _domNode.domNode.style['transitionProperty'] = 'none';
    } else {
      _domNode.domNode.style['transitionProperty'] = '';
    }
    _position = position;
    return true;
  }

  /// 1:1: `private _getGraphemeAwarePosition()`.
  _GraphemePosition _getGraphemeAwarePosition() {
    final int lineNumber = _position.lineNumber;
    final int column = _position.column;
    final String lineContent =
        (_context.viewModel as dynamic).getLineContent(lineNumber) as String;
    final List<int> offsets =
        getCharContainingOffset(lineContent, column - 1);
    return _GraphemePosition(
      Position(lineNumber, offsets[0] + 1),
      lineContent.substring(offsets[0], offsets[1]),
    );
  }

  /// 1:1: `private _prepareRender(ctx)`.
  ViewCursorRenderData? _prepareRender(RenderingContext ctx) {
    String textContent = '';
    String textContentClassName = '';
    final _GraphemePosition grapheme = _getGraphemeAwarePosition();
    final Position position = grapheme.position;
    final String nextGrapheme = grapheme.grapheme;
    final num lineHeight =
        (_context.viewLayout as dynamic).getLineHeightForLineNumber(
                position.lineNumber) as num;
    final num lineCursorHeight = _lineCursorHeight == 0
        ? lineHeight
        : math.min(lineHeight, _lineCursorHeight);
    final num lineHeightAdjustment = (lineHeight - lineCursorHeight) / 2;

    if (_cursorStyle == TextEditorCursorStyle.Line ||
        _cursorStyle == TextEditorCursorStyle.LineThin) {
      final HorizontalPosition? visibleRange =
          ctx.visibleRangeForPosition(position);
      if (visibleRange == null || visibleRange.outsideRenderedLine) {
        return null;
      }

      late final num width;
      if (_cursorStyle == TextEditorCursorStyle.Line) {
        width = computeScreenAwareSize(
          getWindow(_domNode.domNode),
          _lineCursorWidth > 0 ? _lineCursorWidth : 2,
        );
        if (width > 2) {
          textContent = nextGrapheme;
          textContentClassName = _getTokenClassName(position);
        }
      } else {
        width = computeScreenAwareSize(getWindow(_domNode.domNode), 1);
      }

      num left = visibleRange.left;
      num paddingLeft = 0;
      if (width >= 2 && left >= 1) {
        // shift the cursor a bit between the characters
        paddingLeft = 1;
        left -= paddingLeft;
      }

      final num top = ctx.getVerticalOffsetForLineNumber(position.lineNumber) -
          ctx.bigNumbersDelta +
          lineHeightAdjustment;
      return ViewCursorRenderData(top, left, paddingLeft, width,
          lineCursorHeight, textContent, textContentClassName);
    }

    final List<LineVisibleRanges>? visibleRangeForCharacter =
        ctx.linesVisibleRangesForRange(
      Range(position.lineNumber, position.column, position.lineNumber,
          position.column + nextGrapheme.length),
      false,
    );
    if (visibleRangeForCharacter == null ||
        visibleRangeForCharacter.isEmpty) {
      return null;
    }

    final LineVisibleRanges firstVisibleRangeForCharacter =
        visibleRangeForCharacter[0];
    if (firstVisibleRangeForCharacter.outsideRenderedLine ||
        firstVisibleRangeForCharacter.ranges.isEmpty) {
      return null;
    }

    final dynamic range = firstVisibleRangeForCharacter.ranges[0];
    final num width = nextGrapheme == '\t'
        ? _typicalHalfwidthCharacterWidth
        : (range.width < 1 ? _typicalHalfwidthCharacterWidth : range.width as num);

    if (_cursorStyle == TextEditorCursorStyle.Block) {
      textContent = nextGrapheme;
      textContentClassName = _getTokenClassName(position);
    }

    num top =
        ctx.getVerticalOffsetForLineNumber(position.lineNumber) -
            ctx.bigNumbersDelta;
    num height = lineHeight;

    // Underline might interfere with clicking
    if (_cursorStyle == TextEditorCursorStyle.Underline ||
        _cursorStyle == TextEditorCursorStyle.UnderlineThin) {
      top += lineHeight - 2;
      height = 2;
    }

    return ViewCursorRenderData(
        top, range.left as num, 0, width, height, textContent,
        textContentClassName);
  }

  /// 1:1: `private _getTokenClassName(position)`.
  String _getTokenClassName(Position position) {
    final dynamic lineData =
        (_context.viewModel as dynamic).getViewLineData(position.lineNumber);
    final dynamic tokens = lineData.tokens;
    final int tokenIndex =
        tokens.findTokenIndexAtOffset(position.column - 1) as int;
    return tokens.getClassName(tokenIndex) as String;
  }

  /// 1:1: `public prepareRender(ctx)`.
  void prepareRender(RenderingContext ctx) {
    _renderData = _prepareRender(ctx);
  }

  /// 1:1: `public render(ctx)`.
  IViewCursorRenderData? render(RestrictedRenderingContext ctx) {
    final ViewCursorRenderData? renderData = _renderData;
    if (renderData == null) {
      _domNode.setDisplay('none');
      return null;
    }

    if (_lastRenderedContent != renderData.textContent) {
      _lastRenderedContent = renderData.textContent;
      _domNode.domNode.textContent = _lastRenderedContent;
    }

    _domNode.setClassName(
        'cursor $_pluralityClass $MOUSE_CURSOR_TEXT_CSS_CLASS_NAME ${renderData.textContentClassName}');

    _domNode.setDisplay('block');
    _domNode.setTop(renderData.top);
    _domNode.setLeft(renderData.left);
    _domNode.setPaddingLeft(renderData.paddingLeft);
    _domNode.setWidth(renderData.width);
    _domNode.setLineHeight(renderData.height);
    _domNode.setHeight(renderData.height);

    return IViewCursorRenderData(
      _domNode.domNode,
      _position,
      renderData.left,
      2,
      renderData.height,
    );
  }
}
