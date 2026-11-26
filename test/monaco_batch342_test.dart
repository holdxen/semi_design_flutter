// 1:1 replay of
//   `editor/browser/viewParts/viewCursors/viewCursors.ts` (417 lines).
// Truth: `tool/ts2dart/_batch342_truth.cjs` -> `batch342_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/window.dart'
    show mainWindow;
import 'package:semi_design_flutter/src/monaco/base/common/color.dart'
    show Color;
import 'package:semi_design_flutter/src/monaco/editor/browser/viewParts/viewCursors/viewCursors.dart'
    show ViewCursors, viewCursorsTheming;
import 'package:semi_design_flutter/src/monaco/editor/browser/view/renderingContext.dart'
    show HorizontalPosition, HorizontalRange, IViewLines,
    IViewLayoutForRenderingContext, LineVisibleRanges, RenderingContext;
import 'package:semi_design_flutter/src/monaco/editor/common/config/editorOptions.dart'
    show ConfigurationChangedEvent, EditorOption, IComputedEditorOptions,
    TextEditorCursorBlinkingStyle, TextEditorCursorStyle;
import 'package:semi_design_flutter/src/monaco/editor/common/config/fontInfo.dart'
    show FontInfo, FontInfoOptions;
import 'package:semi_design_flutter/src/monaco/editor/common/core/position.dart'
    show Position;
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart'
    show Range;
import 'package:semi_design_flutter/src/monaco/editor/common/core/selection.dart'
    show Selection;
import 'package:semi_design_flutter/src/monaco/editor/common/cursorEvents.dart'
    show CursorChangeReason;
import 'package:semi_design_flutter/src/monaco/editor/common/viewEvents.dart'
    show ViewCompositionEndEvent, ViewCompositionStartEvent,
    ViewConfigurationChangedEvent, ViewCursorStateChangedEvent,
    ViewFocusChangedEvent, ViewTokensChangedEvent;
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
    show ICssStyleCollector, IColorTheme;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(
      jsonDecode(File('tool/ts2dart/batch342_truth.json').readAsStringSync()),
    );

FontInfo _fontInfo() {
  const double typical = 8.4;
  final FontInfoOptions options = FontInfoOptions(
    pixelRatio: 1,
    fontFamily: 'Arial',
    fontWeight: '400',
    fontSize: 14,
    fontFeatureSettings: '',
    fontVariationSettings: '',
    lineHeight: 19,
    letterSpacing: 0.5,
    isMonospace: true,
    typicalHalfwidthCharacterWidth: typical,
    typicalFullwidthCharacterWidth: typical * 2,
    canUseHalfwidthRightwardsArrow: false,
    spaceWidth: typical,
    middotWidth: typical,
    wsmiddotWidth: typical,
    maxDigitWidth: typical,
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

class _ThemingTheme implements IColorTheme {
  @override
  ColorScheme get type => ColorScheme.highContrastDark;

  @override
  Color? getColor(Object colorId, [bool? useDefault]) =>
      (colorId as String).endsWith('.background')
          ? null
          : Color.fromHex('#ffffff');

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Collector implements ICssStyleCollector {
  final List<String> rules = <String>[];

  @override
  void addRule(String rule) => rules.add(rule);
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
  const _ViewLines({required this.left, required this.rangeLeft,
    required this.rangeWidth, required this.outside});

  final num left;
  final num rangeLeft;
  final num rangeWidth;
  final bool outside;

  @override
  HorizontalPosition? visibleRangeForPosition(Position position) =>
      HorizontalPosition(outside, left);

  @override
  List<LineVisibleRanges>? linesVisibleRangesForRange(
      Range range, bool includeNewLines) {
    if (outside) {
      return <LineVisibleRanges>[];
    }
    return <LineVisibleRanges>[
      LineVisibleRanges(
        false,
        range.startLineNumber,
        <HorizontalRange>[HorizontalRange(rangeLeft, rangeWidth)],
        false,
      ),
    ];
  }
}

RenderingContext _makeCtx() {
  final IPartialViewLinesViewportData partial = IPartialViewLinesViewportData(
    startLineNumber: 1,
    endLineNumber: 1,
    relativeVerticalOffset: <num>[0],
    bigNumbersDelta: 0,
    lineHeight: 20,
  );
  final ViewportData data = ViewportData(
    const <Selection>[],
    partial,
    const <Object>[],
    const _ViewportModel(),
  );
  return RenderingContext(
    const _RenderingLayout(100),
    data,
    const _ViewLines(left: 40, rangeLeft: 50, rangeWidth: 7, outside: false),
  );
}

List<Object?> _describeChildren(ViewCursors part) => part
    .getDomNode()
    .domNode
    .childNodes
    .whereType<DomElement>()
    .map((DomElement child) {
      final List<String> parts = child.className.split(' ');
      return '${child.tagName.toLowerCase()}:${parts.length > 1 ? parts[1] : ''}';
    })
    .toList();

List<Object?> _renderPositions(ViewCursors part, RenderingContext ctx) {
  part.prepareRender(ctx);
  part.render(ctx);
  return part
      .getLastRenderData()
      .map((dynamic r) => <Object?>[r.position.lineNumber, r.position.column])
      .toList();
}

List<Object?> _describeRenderData(ViewCursors part) => part
    .getLastRenderData()
    .map((dynamic r) => <String, Object?>{
          'position': <Object?>[r.position.lineNumber, r.position.column],
          'contentLeft': r.contentLeft,
          'height': r.height,
          'width': r.width,
        })
    .toList();

ViewConfigurationChangedEvent _changed(List<int> ids) {
  final List<bool> flags = List<bool>.filled(200, false);
  for (final int id in ids) {
    flags[id] = true;
  }
  return ViewConfigurationChangedEvent(ConfigurationChangedEvent(flags));
}

Selection _sel(int a, int b, int c, int d) => Selection(a, b, c, d);

void main() {
  setUp(() {
    final DomWindowCarrier carrier = windowCarrier(mainWindow);
    carrier.document = DomDocument()..defaultView = mainWindow;
    carrier.devicePixelRatio = 2;
  });

  test('view cursors replay TS', () {
    final Map<int, Object?> values = <int, Object?>{
      EditorOption.fontInfo: _fontInfo(),
      EditorOption.effectiveCursorStyle: TextEditorCursorStyle.Line,
      EditorOption.cursorWidth: 12,
      EditorOption.cursorHeight: 0,
      EditorOption.readOnly: false,
      EditorOption.cursorBlinking: TextEditorCursorBlinkingStyle.Blink,
      EditorOption.cursorSmoothCaretAnimation: 'off',
      EditorOption.effectiveEditContext: false,
    };
    final _Model model = _Model(const _ViewLayout());
    final ViewContext context =
        ViewContext(_Config(_Options(values)), _Theme(), model);
    final ViewCursors part = ViewCursors(context);
    final DomElement domNode = part.getDomNode().domNode;

    final Map<String, Object?> actual = <String, Object?>{
      'initial': <String, Object?>{
        'className': domNode.className,
        'attrs': <String, Object?>{
          'role': domNode.getAttribute('role'),
          'aria-hidden': domNode.getAttribute('aria-hidden'),
        },
        'children': _describeChildren(part),
        'primaryVisibility': (domNode.childNodes.first as DomElement).style['visibility'],
        'handlers': model.handlers.length,
      },
    };

    actual['focus'] = <String, Object?>{
      'result': part.onFocusChanged(ViewFocusChangedEvent(true)),
      'className': domNode.className,
      'primaryVisibility': (domNode.childNodes.first as DomElement).style['visibility'],
    };
    actual['compositionStart'] = <String, Object?>{
      'result': part.onCompositionStart(ViewCompositionStartEvent()),
      'className': domNode.className,
      'primaryVisibility': (domNode.childNodes.first as DomElement).style['visibility'],
    };
    actual['compositionEnd'] = <String, Object?>{
      'result': part.onCompositionEnd(ViewCompositionEndEvent()),
      'className': domNode.className,
      'primaryVisibility': (domNode.childNodes.first as DomElement).style['visibility'],
    };

    values
      ..[EditorOption.readOnly] = true
      ..[EditorOption.cursorBlinking] = TextEditorCursorBlinkingStyle.Phase
      ..[EditorOption.cursorSmoothCaretAnimation] = 'on'
      ..[EditorOption.effectiveCursorStyle] = TextEditorCursorStyle.Block;
    actual['config'] = <String, Object?>{
      'result': part.onConfigurationChanged(_changed(<int>[])),
      'className': domNode.className,
      'primaryVisibility': (domNode.childNodes.first as DomElement).style['visibility'],
    };
    actual['configWithFlags'] = <String, Object?>{
      'result': part.onConfigurationChanged(_changed(<int>[
        EditorOption.readOnly,
        EditorOption.cursorBlinking,
        EditorOption.cursorSmoothCaretAnimation,
        EditorOption.effectiveCursorStyle,
      ])),
      'className': domNode.className,
    };

    values
      ..[EditorOption.readOnly] = false
      ..[EditorOption.cursorBlinking] = TextEditorCursorBlinkingStyle.Blink
      ..[EditorOption.cursorSmoothCaretAnimation] = 'off'
      ..[EditorOption.effectiveCursorStyle] = TextEditorCursorStyle.Line;
    part.onConfigurationChanged(_changed(<int>[]));

    part.onCursorStateChanged(ViewCursorStateChangedEvent(
      <Selection>[_sel(1, 1, 1, 1)],
      <Selection>[_sel(1, 1, 1, 1)],
      CursorChangeReason.Explicit,
    ));
    final List<Object?> singlePositions =
        _renderPositions(part, _makeCtx());
    actual['cursorSingle'] = <String, Object?>{
      'result': true,
      'children': _describeChildren(part),
      'className': domNode.className,
      'renderPositions': singlePositions,
    };

    part.onCursorStateChanged(ViewCursorStateChangedEvent(
      <Selection>[
        _sel(1, 1, 1, 1),
        _sel(2, 2, 2, 2),
        _sel(3, 2, 3, 2),
      ],
      <Selection>[
        _sel(1, 1, 1, 1),
        _sel(2, 2, 2, 2),
        _sel(3, 2, 3, 2),
      ],
      CursorChangeReason.Explicit,
    ));
    final RenderingContext ctx = _makeCtx();
    final List<Object?> multiPositions = _renderPositions(part, ctx);
    actual['cursorMulti'] = <String, Object?>{
      'result': true,
      'children': _describeChildren(part),
      'className': domNode.className,
      'renderPositions': multiPositions,
    };
    actual['render'] = _describeRenderData(part);

    part.onCursorStateChanged(ViewCursorStateChangedEvent(
      <Selection>[_sel(4, 1, 4, 1)],
      <Selection>[_sel(4, 1, 4, 1)],
      CursorChangeReason.Explicit,
    ));
    final List<Object?> removePositions = _renderPositions(part, _makeCtx());
    actual['cursorRemove'] = <String, Object?>{
      'result': true,
      'children': _describeChildren(part),
      'renderPositions': removePositions,
    };

    actual['selectionNonEmpty'] = <String, Object?>{
      'result': part.onCursorStateChanged(ViewCursorStateChangedEvent(
        <Selection>[_sel(1, 1, 1, 4)],
        <Selection>[_sel(1, 1, 1, 4)],
        CursorChangeReason.Explicit,
      )),
      'className': domNode.className,
    };
    actual['selectionEmptyAgain'] = <String, Object?>{
      'result': part.onCursorStateChanged(ViewCursorStateChangedEvent(
        <Selection>[_sel(1, 1, 1, 1)],
        <Selection>[_sel(1, 1, 1, 1)],
        CursorChangeReason.Explicit,
      )),
      'className': domNode.className,
    };

    actual['tokens'] = <String, Object?>{
      'covering': part.onTokensChanged(ViewTokensChangedEvent(
        <({int fromLineNumber, int toLineNumber})>[
          (fromLineNumber: 1, toLineNumber: 1),
        ],
      )),
      'notCovering': part.onTokensChanged(ViewTokensChangedEvent(
        <({int fromLineNumber, int toLineNumber})>[
          (fromLineNumber: 5, toLineNumber: 6),
        ],
      )),
    };
    actual['otherEvents'] = <String, Object?>{
      'decorations': part.onDecorationsChanged(Object()),
      'flushed': part.onFlushed(Object()),
      'focus': part.onFocusChanged(ViewFocusChangedEvent(false)),
      'linesChanged': part.onLinesChanged(Object()),
      'linesDeleted': part.onLinesDeleted(Object()),
      'linesInserted': part.onLinesInserted(Object()),
      'scroll': part.onScrollChanged(Object()),
      'zones': part.onZonesChanged(Object()),
    };

    final _Collector collector = _Collector();
    viewCursorsTheming(_ThemingTheme(), collector, null);
    actual['theming'] = collector.rules;

    part.dispose();
    actual['handlersAfterDispose'] = model.handlers.length;

    expect(actual, _truth());
  });
}
