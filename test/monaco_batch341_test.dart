// 1:1 replay of
//   `editor/browser/viewParts/viewCursors/viewCursor.ts` (283 lines).
// Truth: `tool/ts2dart/_batch341_truth.cjs` -> `batch341_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/window.dart'
    show mainWindow;
import 'package:semi_design_flutter/src/monaco/editor/browser/viewParts/viewCursors/viewCursor.dart'
    show CursorPlurality, ViewCursor;
import 'package:semi_design_flutter/src/monaco/editor/browser/view/renderingContext.dart'
    show HorizontalPosition, HorizontalRange, IViewLines,
    IViewLayoutForRenderingContext, LineVisibleRanges, RenderingContext;
import 'package:semi_design_flutter/src/monaco/editor/common/config/editorOptions.dart'
    show ConfigurationChangedEvent, EditorOption, IComputedEditorOptions,
    TextEditorCursorStyle;
import 'package:semi_design_flutter/src/monaco/editor/common/config/fontInfo.dart'
    show FontInfo, FontInfoOptions;
import 'package:semi_design_flutter/src/monaco/editor/common/core/position.dart'
    show Position;
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart'
    show Range;
import 'package:semi_design_flutter/src/monaco/editor/common/core/selection.dart'
    show Selection;
import 'package:semi_design_flutter/src/monaco/editor/common/viewEvents.dart'
    show ViewConfigurationChangedEvent;
import 'package:semi_design_flutter/src/monaco/editor/common/viewLayout/viewLinesViewportData.dart'
    show IPartialViewLinesViewportData, IViewModelForViewportData, ViewportData;
import 'package:semi_design_flutter/src/monaco/editor/common/viewModel.dart'
    show Viewport;
import 'package:semi_design_flutter/src/monaco/editor/common/viewModel/viewContext.dart'
    show IEditorConfigurationForViewContext, IViewLayoutForViewContext,
    IViewModelForViewContext, ViewContext;
import 'package:semi_design_flutter/src/monaco/editor/common/viewEventHandler.dart'
    show ViewEventHandler;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/theme.dart'
    show ColorScheme;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/themeService.dart'
    show IColorTheme;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(
      jsonDecode(File('tool/ts2dart/batch341_truth.json').readAsStringSync()),
    );

FontInfo _fontInfo({
  required double fontSize,
  required double lineHeight,
  required double letterSpacing,
  required double typicalHalfwidthCharacterWidth,
}) {
  final FontInfoOptions options = FontInfoOptions(
    pixelRatio: 1,
    fontFamily: 'Arial',
    fontWeight: '400',
    fontSize: fontSize,
    fontFeatureSettings: '',
    fontVariationSettings: '',
    lineHeight: lineHeight,
    letterSpacing: letterSpacing,
    isMonospace: true,
    typicalHalfwidthCharacterWidth: typicalHalfwidthCharacterWidth,
    typicalFullwidthCharacterWidth: typicalHalfwidthCharacterWidth * 2,
    canUseHalfwidthRightwardsArrow: false,
    spaceWidth: typicalHalfwidthCharacterWidth,
    middotWidth: typicalHalfwidthCharacterWidth,
    wsmiddotWidth: typicalHalfwidthCharacterWidth,
    maxDigitWidth: typicalHalfwidthCharacterWidth,
  );
  return FontInfo(options, true);
}

class _Options implements IComputedEditorOptions {
  const _Options(this.values);
  final Map<int, Object?> values;

  @override
  Object? get(Object id) => values[id as int];
}

class _Config implements IEditorConfigurationForViewContext {
  const _Config(this.options);
  final IComputedEditorOptions options;
}

class _Theme implements IColorTheme {
  @override
  ColorScheme get type => ColorScheme.dark;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _ViewLayout implements IViewLayoutForViewContext {
  const _ViewLayout();

  num getLineHeightForLineNumber(int lineNumber) => 20;
}

class _Tokens {
  int findTokenIndexAtOffset(int offset) => offset >= 2 ? 1 : 0;
  String getClassName(int index) => index == 1 ? 'tok-b' : 'tok-a';
}

class _ViewLineData {
  const _ViewLineData(this.tokens);
  final _Tokens tokens;
}

class _Model implements IViewModelForViewContext {
  _Model(this.viewLayout);

  @override
  final IViewLayoutForViewContext viewLayout;
  final _Tokens tokens = _Tokens();
  final List<ViewEventHandler> handlers = <ViewEventHandler>[];
  String lineContent = 'hello world';

  @override
  void addViewEventHandler(ViewEventHandler handler) => handlers.add(handler);

  @override
  void removeViewEventHandler(ViewEventHandler handler) =>
      handlers.remove(handler);

  String getLineContent(int lineNumber) => lineContent;

  _ViewLineData getViewLineData(int lineNumber) => _ViewLineData(tokens);
}

class _RenderingLayout implements IViewLayoutForRenderingContext {
  const _RenderingLayout(this.vertical);
  final num vertical;

  @override
  num getScrollWidth() => 0;

  @override
  num getScrollHeight() => 0;

  @override
  Viewport getCurrentViewport() => Viewport(0, 0, 0, 0);

  @override
  num getVerticalOffsetForLineNumber(int lineNumber, [bool? includeViewZones]) =>
      vertical;

  @override
  num getVerticalOffsetAfterLineNumber(int lineNumber,
          [bool? includeViewZones]) =>
      vertical;

  @override
  num getLineHeightForLineNumber(int lineNumber) => 20;
}

class _ViewportModel implements IViewModelForViewportData {
  const _ViewportModel();

  @override
  int getLineMinColumn(int lineNumber) => 1;

  @override
  int getLineMaxColumn(int lineNumber) => 12;

  @override
  Object getViewportViewLineRenderingData(Range visibleRange, int lineNumber) =>
      Object();

  @override
  bool getViewLineContinuesWithWrappedLine(int lineNumber) => false;

  @override
  List<Object> getDecorationsInViewport(Range visibleRange) =>
      const <Object>[];
}

class _ViewLines implements IViewLines {
  const _ViewLines({
    required this.left,
    required this.outside,
    required this.lines,
    required this.rangeLeft,
    required this.rangeWidth,
  });

  final num left;
  final bool outside;
  final List<LineVisibleRanges>? lines;
  final num rangeLeft;
  final num rangeWidth;

  @override
  HorizontalPosition? visibleRangeForPosition(Position position) =>
      HorizontalPosition(outside, left);

  @override
  List<LineVisibleRanges>? linesVisibleRangesForRange(
      Range range, bool includeNewLines) {
    final List<LineVisibleRanges>? override = lines;
    if (override != null) {
      return override;
    }
    if (outside) {
      return <LineVisibleRanges>[];
    }
    return <LineVisibleRanges>[
      LineVisibleRanges(
        false,
        range.startLineNumber,
        <HorizontalRange>[
          HorizontalRange(rangeLeft, rangeWidth),
        ],
        false,
      ),
    ];
  }
}

RenderingContext _makeCtx({
  num left = 40,
  num rangeLeft = 50,
  num rangeWidth = 7,
  num vertical = 100,
  int big = 0,
  bool outside = false,
  List<LineVisibleRanges>? lines,
}) {
  final IPartialViewLinesViewportData partial = IPartialViewLinesViewportData(
    startLineNumber: 1,
    endLineNumber: 1,
    relativeVerticalOffset: <num>[0],
    bigNumbersDelta: big,
    lineHeight: 20,
  );
  final ViewportData data = ViewportData(
    const <Selection>[],
    partial,
    const <Object>[],
    const _ViewportModel(),
  );
  return RenderingContext(
    _RenderingLayout(vertical),
    data,
    _ViewLines(
      left: left,
      outside: outside,
      lines: lines,
      rangeLeft: rangeLeft,
      rangeWidth: rangeWidth,
    ),
  );
}

const List<String> _styleKeys = <String>[
  'height',
  'top',
  'left',
  'paddingLeft',
  'width',
  'lineHeight',
  'display',
  'visibility',
  'transitionProperty',
  'fontSize',
  'fontWeight',
  'fontFeatureSettings',
  'fontVariationSettings',
  'letterSpacing',
];

Map<String, Object?> _pickStyle(DomElement node) {
  final Map<String, String> style = Map<String, String>.from(node.style);
  return <String, Object?>{
    for (final String key in _styleKeys)
      if (style.containsKey(key)) key: style[key],
  };
}

Map<String, Object?>? _describeRender(
    dynamic render, DomElement domNode) {
  if (render == null) {
    return null;
  }
  return <String, Object?>{
    'domNodeIsSelf': identical(render.domNode, domNode),
    'position': <Object?>[
      render.position.lineNumber,
      render.position.column,
    ],
    'contentLeft': render.contentLeft,
    'height': render.height,
    'width': render.width,
  };
}

ViewConfigurationChangedEvent _changed() => ViewConfigurationChangedEvent(
      ConfigurationChangedEvent(List<bool>.filled(200, false)),
    );

void main() {
  setUp(() {
    final DomWindowCarrier carrier = windowCarrier(mainWindow);
    carrier.document = DomDocument()..defaultView = mainWindow;
    carrier.devicePixelRatio = 2;
  });

  test('view cursor replay TS', () {
    final Map<int, Object?> values = <int, Object?>{
      EditorOption.fontInfo: _fontInfo(
        fontSize: 14,
        lineHeight: 19,
        letterSpacing: 0.5,
        typicalHalfwidthCharacterWidth: 8.4,
      ),
      EditorOption.effectiveCursorStyle: TextEditorCursorStyle.Line,
      EditorOption.cursorWidth: 12,
      EditorOption.cursorHeight: 0,
    };
    final _Model model = _Model(const _ViewLayout());
    final ViewContext context =
        ViewContext(_Config(_Options(values)), _Theme(), model);
    final ViewCursor cursor = ViewCursor(context, CursorPlurality.MultiPrimary);
    final DomElement domNode = cursor.getDomNode().domNode;

    final Map<String, Object?> actual = <String, Object?>{
      'initial': <String, Object?>{
        'style': _pickStyle(domNode),
        'className': domNode.className,
        'textContent': domNode.textContent,
        'position': <Object?>[
          cursor.getPosition().lineNumber,
          cursor.getPosition().column,
        ],
      },
    };

    final ViewCursor pluralityProbe =
        ViewCursor(context, CursorPlurality.Single);
    final List<Object?> pluralities = <Object?>[];
    for (final int p in <int>[
      CursorPlurality.Single,
      CursorPlurality.MultiPrimary,
      CursorPlurality.MultiSecondary,
      CursorPlurality.Single,
    ]) {
      pluralityProbe.setPlurality(p);
      pluralityProbe.prepareRender(_makeCtx());
      pluralityProbe.render(_makeCtx());
      pluralities.add(pluralityProbe.getDomNode().domNode.className.split(' ')[1]);
    }
    actual['pluralities'] = pluralities;

    cursor.hide();
    final Object? hiddenStyle = _pickStyle(domNode)['visibility'];
    cursor.hide();
    final Object? hiddenAgain = _pickStyle(domNode)['visibility'];
    cursor.show();
    final Object? shownStyle = _pickStyle(domNode)['visibility'];
    cursor.show();
    actual['visibility'] = <String, Object?>{
      'hide': hiddenStyle,
      'hideAgain': hiddenAgain,
      'show': shownStyle,
      'showAgain': _pickStyle(domNode)['visibility'],
    };

    values[EditorOption.fontInfo] = _fontInfo(
      fontSize: 16,
      lineHeight: 24,
      letterSpacing: 1,
      typicalHalfwidthCharacterWidth: 9.6,
    );
    values[EditorOption.effectiveCursorStyle] = TextEditorCursorStyle.Line;
    values[EditorOption.cursorWidth] = 12;
    values[EditorOption.cursorHeight] = 0;
    actual['configChanged'] = <String, Object?>{
      'result': cursor.onConfigurationChanged(_changed()),
      'style': _pickStyle(domNode),
      'lineCursorWidth': 9.6,
      'lineCursorHeight': 0,
      'typicalHalfwidthCharacterWidth': 9.6,
    };

    model.lineContent = 'hello world';
    final List<Object?> pauseAnimation = <Object?>[];
    for (final bool pause in <bool>[true, false]) {
      final bool result =
          cursor.onCursorPositionChanged(Position(1, 3), pause);
      pauseAnimation.add(<String, Object?>{
        'result': result,
        'transition': domNode.style['transitionProperty'],
        'position': <Object?>[
          cursor.getPosition().lineNumber,
          cursor.getPosition().column,
        ],
      });
    }
    actual['pauseAnimation'] = pauseAnimation;

    RenderingContext ctx = _makeCtx(left: 40, vertical: 100, big: 5);
    cursor.prepareRender(ctx);
    dynamic r = cursor.render(ctx);
    actual['line'] = <String, Object?>{
      'render': _describeRender(r, domNode),
      'style': _pickStyle(domNode),
      'className': domNode.className,
      'textContent': domNode.textContent,
    };

    values[EditorOption.effectiveCursorStyle] = TextEditorCursorStyle.LineThin;
    cursor.onConfigurationChanged(_changed());
    ctx = _makeCtx(left: 40, vertical: 100, big: 5);
    cursor.prepareRender(ctx);
    r = cursor.render(ctx);
    actual['lineThin'] = <String, Object?>{
      'render': _describeRender(r, domNode),
      'style': _pickStyle(domNode),
      'className': domNode.className,
      'textContent': domNode.textContent,
    };

    values[EditorOption.effectiveCursorStyle] = TextEditorCursorStyle.Block;
    cursor.onConfigurationChanged(_changed());
    ctx = _makeCtx(rangeLeft: 50, rangeWidth: 7, vertical: 100, big: 5);
    cursor.prepareRender(ctx);
    r = cursor.render(ctx);
    actual['block'] = <String, Object?>{
      'render': _describeRender(r, domNode),
      'style': _pickStyle(domNode),
      'className': domNode.className,
      'textContent': domNode.textContent,
    };

    values[EditorOption.effectiveCursorStyle] = TextEditorCursorStyle.Underline;
    cursor.onConfigurationChanged(_changed());
    ctx = _makeCtx(rangeLeft: 50, rangeWidth: 7, vertical: 100, big: 5);
    cursor.prepareRender(ctx);
    r = cursor.render(ctx);
    actual['underline'] = <String, Object?>{
      'render': _describeRender(r, domNode),
      'style': _pickStyle(domNode),
      'className': domNode.className,
      'textContent': domNode.textContent,
    };

    values[EditorOption.effectiveCursorStyle] = TextEditorCursorStyle.Line;
    cursor.onConfigurationChanged(_changed());
    ctx = _makeCtx(outside: true);
    cursor.prepareRender(ctx);
    r = cursor.render(ctx);
    actual['outsideLine'] = <String, Object?>{
      'render': _describeRender(r, domNode),
      'style': _pickStyle(domNode),
    };

    values[EditorOption.effectiveCursorStyle] = TextEditorCursorStyle.Block;
    cursor.onConfigurationChanged(_changed());
    ctx = _makeCtx(outside: true);
    cursor.prepareRender(ctx);
    r = cursor.render(ctx);
    actual['outsideBlock'] = <String, Object?>{
      'render': _describeRender(r, domNode),
      'style': _pickStyle(domNode),
    };

    model.lineContent = '\tx';
    cursor.onCursorPositionChanged(Position(1, 1), false);
    ctx = _makeCtx(rangeLeft: 50, rangeWidth: 0, vertical: 100, big: 0);
    cursor.prepareRender(ctx);
    r = cursor.render(ctx);
    actual['tabFallback'] = <String, Object?>{
      'render': _describeRender(r, domNode),
      'style': _pickStyle(domNode),
      'textContent': domNode.textContent,
    };

    model.lineContent = '😀x';
    cursor.onCursorPositionChanged(Position(1, 2), false);
    ctx = _makeCtx(rangeLeft: 50, rangeWidth: 10, vertical: 100, big: 0);
    cursor.prepareRender(ctx);
    r = cursor.render(ctx);
    actual['grapheme'] = <String, Object?>{
      'render': _describeRender(r, domNode),
      'textContent': domNode.textContent,
    };

    expect(actual, _truth());
  });
}
