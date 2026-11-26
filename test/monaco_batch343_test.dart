// 1:1 replay of
//   `editor/browser/viewParts/selections/selections.ts` (409 lines).
// Truth: `tool/ts2dart/_batch343_truth.cjs` -> `batch343_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/color.dart'
    show Color;
import 'package:semi_design_flutter/src/monaco/editor/browser/viewParts/selections/selections.dart'
    show SelectionsOverlay, selectionsTheming;
import 'package:semi_design_flutter/src/monaco/editor/browser/view/renderingContext.dart'
    show HorizontalPosition, HorizontalRange, IViewLines,
    IViewLayoutForRenderingContext, LineVisibleRanges, RenderingContext;
import 'package:semi_design_flutter/src/monaco/editor/common/config/editorOptions.dart'
    show EditorOption, IComputedEditorOptions;
import 'package:semi_design_flutter/src/monaco/editor/common/config/fontInfo.dart'
    show FontInfo, FontInfoOptions;
import 'package:semi_design_flutter/src/monaco/editor/common/core/position.dart'
    show Position;
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart'
    show Range;
import 'package:semi_design_flutter/src/monaco/editor/common/core/selection.dart'
    show Selection;
import 'package:semi_design_flutter/src/monaco/editor/common/viewEvents.dart'
    show ViewCursorStateChangedEvent;
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
      jsonDecode(File('tool/ts2dart/batch343_truth.json').readAsStringSync()),
    );

FontInfo _fontInfo() {
  const double typical = 8.4;
  return FontInfo(
    FontInfoOptions(
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
    ),
    true,
  );
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
  _ThemingTheme(this.color);
  final Object? color;

  @override
  ColorScheme get type => ColorScheme.dark;

  @override
  Color? getColor(Object colorId, [bool? useDefault]) => color as Color?;

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

class _Model implements IViewModelForViewContext {
  _Model(this.viewLayout);

  @override
  final IViewLayoutForViewContext viewLayout;
  final List<ViewEventHandler> handlers = <ViewEventHandler>[];

  @override
  void addViewEventHandler(ViewEventHandler handler) => handlers.add(handler);

  @override
  void removeViewEventHandler(ViewEventHandler handler) =>
      handlers.remove(handler);
}

class _RenderingLayout implements IViewLayoutForRenderingContext {
  const _RenderingLayout();

  @override
  num getScrollWidth() => 0;

  @override
  num getScrollHeight() => 0;

  @override
  Viewport getCurrentViewport() => Viewport(0, 0, 0, 0);

  @override
  num getVerticalOffsetForLineNumber(int lineNumber, [bool? includeViewZones]) =>
      0;

  @override
  num getVerticalOffsetAfterLineNumber(int lineNumber,
          [bool? includeViewZones]) =>
      0;

  @override
  num getLineHeightForLineNumber(int lineNumber) => 20;
}

class _ViewportModel implements IViewModelForViewportData {
  const _ViewportModel();

  @override
  int getLineMinColumn(int lineNumber) => 1;

  @override
  int getLineMaxColumn(int lineNumber) => 20;

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
  const _ViewLines(this.lines);
  final List<LineVisibleRanges> lines;

  @override
  List<LineVisibleRanges>? linesVisibleRangesForRange(
          Range range, bool includeNewLines) =>
      lines;

  @override
  HorizontalPosition? visibleRangeForPosition(Position position) => null;
}

LineVisibleRanges _line(int lineNumber, List<List<num>> ranges) =>
    LineVisibleRanges(
      false,
      lineNumber,
      ranges
          .map((List<num> r) => HorizontalRange(r[0], r[1]))
          .toList(),
      false,
    );

RenderingContext _makeCtx(List<LineVisibleRanges> lines) {
  final IPartialViewLinesViewportData partial = IPartialViewLinesViewportData(
    startLineNumber: 1,
    endLineNumber: 3,
    relativeVerticalOffset: <num>[0, 20, 40],
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
    const _RenderingLayout(),
    data,
    _ViewLines(lines),
  );
}

List<String> _renderLines(SelectionsOverlay overlay) =>
    <String>[overlay.render(1, 1), overlay.render(1, 2), overlay.render(1, 3)];

Selection _sel(int a, int b, int c, int d) => Selection(a, b, c, d);

void main() {
  test('selections replay TS', () {
    final Map<int, Object?> values = <int, Object?>{
      EditorOption.roundedSelection: true,
      EditorOption.fontInfo: _fontInfo(),
    };
    final _Model model = _Model(const _ViewLayout());
    final ViewContext context =
        ViewContext(_Config(_Options(values)), _Theme(), model);
    final SelectionsOverlay overlay = SelectionsOverlay(context);

    final Map<String, Object?> actual = <String, Object?>{
      'initial': <String, Object?>{
        'renderBeforePrepare': overlay.render(1, 1),
        'handlers': model.handlers.length,
      },
    };

    final Map<String, Object?> single = <String, Object?>{
      'scrollFalse': overlay.onScrollChanged(
          _ScrollEvent(false)),
      'scrollTrue': overlay.onScrollChanged(_ScrollEvent(true)),
      'decorations': overlay.onDecorationsChanged(Object()),
      'flushed': overlay.onFlushed(Object()),
      'linesChanged': overlay.onLinesChanged(Object()),
      'linesDeleted': overlay.onLinesDeleted(Object()),
      'linesInserted': overlay.onLinesInserted(Object()),
      'zones': overlay.onZonesChanged(Object()),
      'config': overlay.onConfigurationChanged(Object()),
    };
    actual['single'] = single;

    overlay.onCursorStateChanged(ViewCursorStateChangedEvent(
      <Selection>[_sel(1, 1, 3, 4)],
      <Selection>[_sel(1, 1, 3, 4)],
      0,
    ));
    overlay.prepareRender(_makeCtx(<LineVisibleRanges>[
      _line(1, <List<num>>[<num>[10, 5]]),
      _line(2, <List<num>>[<num>[10, 5]]),
      _line(3, <List<num>>[<num>[10, 5]]),
    ]));
    single['render'] = _renderLines(overlay);

    overlay.prepareRender(_makeCtx(<LineVisibleRanges>[
      _line(1, <List<num>>[<num>[10, 5]]),
      _line(2, <List<num>>[<num>[15, 5]]),
      _line(3, <List<num>>[<num>[10, 5]]),
    ]));
    actual['roundedIntern'] = _renderLines(overlay);

    values[EditorOption.roundedSelection] = false;
    overlay.onConfigurationChanged(Object());
    overlay.prepareRender(_makeCtx(<LineVisibleRanges>[
      _line(1, <List<num>>[<num>[10, 5]]),
      _line(2, <List<num>>[<num>[15, 5]]),
      _line(3, <List<num>>[<num>[10, 5]]),
    ]));
    actual['noRounded'] = _renderLines(overlay);
    values[EditorOption.roundedSelection] = true;
    overlay.onConfigurationChanged(Object());

    overlay.prepareRender(_makeCtx(<LineVisibleRanges>[
      _line(1, <List<num>>[<num>[10, 5], <num>[30, 5]]),
      _line(2, <List<num>>[<num>[15, 5]]),
      _line(3, <List<num>>[<num>[10, 5]]),
    ]));
    actual['gaps'] = _renderLines(overlay);

    overlay.onCursorStateChanged(ViewCursorStateChangedEvent(
      <Selection>[_sel(1, 1, 1, 4), _sel(2, 1, 2, 4)],
      <Selection>[_sel(1, 1, 1, 4), _sel(2, 1, 2, 4)],
      0,
    ));
    overlay.prepareRender(_makeCtx(<LineVisibleRanges>[
      _line(1, <List<num>>[<num>[10, 5]]),
      _line(2, <List<num>>[<num>[15, 5]]),
    ]));
    actual['multiple'] = _renderLines(overlay);

    overlay.onCursorStateChanged(ViewCursorStateChangedEvent(
      <Selection>[_sel(1, 1, 1, 4)],
      <Selection>[_sel(1, 1, 1, 4)],
      0,
    ));
    overlay.prepareRender(_makeCtx(<LineVisibleRanges>[
      _line(1, <List<num>>[<num>[10, 5]]),
      _line(2, <List<num>>[<num>[10, 5]]),
    ]));
    overlay.prepareRender(_makeCtx(<LineVisibleRanges>[
      _line(1, <List<num>>[<num>[15, 5]]),
      _line(2, <List<num>>[<num>[15, 5]]),
    ]));
    actual['previousFrame'] = _renderLines(overlay);

    overlay.onCursorStateChanged(ViewCursorStateChangedEvent(
      <Selection>[_sel(1, 1, 1, 1)],
      <Selection>[_sel(1, 1, 1, 1)],
      0,
    ));
    overlay.prepareRender(_makeCtx(<LineVisibleRanges>[
      _line(1, <List<num>>[<num>[10, 5]]),
      _line(2, <List<num>>[<num>[10, 5]]),
      _line(3, <List<num>>[<num>[10, 5]]),
    ]));
    actual['emptySelection'] = _renderLines(overlay);

    final _Collector collector = _Collector();
    final Color yellow = Color.fromHex('#ffff00');
    selectionsTheming(_ThemingTheme(yellow), collector, null);
    selectionsTheming(_ThemingTheme(null), collector, null);
    selectionsTheming(_ThemingTheme(yellow.transparent(0)), collector, null);
    actual['theming'] = collector.rules;

    overlay.dispose();
    actual['handlersAfterDispose'] = model.handlers.length;

    expect(actual, _truth());
  });
}

class _ScrollEvent {
  const _ScrollEvent(this.scrollTopChanged);
  final bool scrollTopChanged;
}
