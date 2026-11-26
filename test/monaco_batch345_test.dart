// 1:1 replay of
//   `editor/browser/viewParts/viewLines/viewLines.ts` (875 lines).
// Truth: `tool/ts2dart/_batch345_truth.cjs` -> `batch345_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/browser/view/renderingContext.dart'
    show
        FloatHorizontalRange,
        HorizontalPosition,
        LineVisibleRanges,
        VisibleRanges;
import 'package:semi_design_flutter/src/monaco/editor/browser/viewParts/viewLines/domReadingContext.dart'
    show DomReadElement, DomReadingContext;
import 'package:semi_design_flutter/src/monaco/editor/browser/viewParts/viewLines/viewLine.dart'
    show IViewLineOptionsForLine;
import 'package:semi_design_flutter/src/monaco/editor/browser/viewParts/viewLines/viewLines.dart'
    show
        IConfigurationForViewLines,
        IOptionsForViewLines,
        IViewLayoutForViewLines,
        IViewLineForViewLines,
        IViewModelForViewLines,
        IViewLinesFastDomNode,
        IViewLinesScheduler,
        IVisibleLinesForViewLines,
        ViewLines,
        configureViewLinesCollectionFactoryForReplay,
        configureViewLinesRestingSpotFactoryForReplay,
        configureViewLinesSchedulerFactoryForReplay,
        setIsLinuxForViewLinesReplay;
import 'package:semi_design_flutter/src/monaco/editor/common/config/editorOptions.dart'
    show EditorOption;
import 'package:semi_design_flutter/src/monaco/editor/common/config/fontInfo.dart'
    show FontInfo, FontInfoOptions;
import 'package:semi_design_flutter/src/monaco/editor/common/core/position.dart'
    show Position;
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart'
    show Range;
import 'package:semi_design_flutter/src/monaco/editor/common/core/selection.dart'
    show Selection;
import 'package:semi_design_flutter/src/monaco/editor/common/viewEvents.dart'
    show VerticalRevealType;
import 'package:semi_design_flutter/src/monaco/editor/common/viewLayout/viewLinesViewportData.dart'
    show
        IPartialViewLinesViewportData,
        IViewModelForViewportData,
        ViewportData;
import 'package:semi_design_flutter/src/monaco/editor/common/viewEventHandler.dart'
    show ViewEventHandler;
import 'package:semi_design_flutter/src/monaco/editor/common/viewModel.dart'
    show Viewport;
import 'package:semi_design_flutter/src/monaco/editor/common/viewModel/viewContext.dart'
    show
        IEditorConfigurationForViewContext,
        IViewLayoutForViewContext,
        IViewModelForViewContext,
        ViewContext;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/theme.dart'
    show ColorScheme;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/themeService.dart'
    show IColorTheme;

const String _macFontFamily = "Menlo, Monaco, 'Courier New', monospace";

num _jsNum(num value) =>
    value == value.truncateToDouble() ? value.toInt() : value;

Map<String, dynamic> _truth() => (jsonDecode(
      File('tool/ts2dart/batch345_truth.json').readAsStringSync(),
    ) as Map)
    .cast<String, dynamic>();

Map<String, dynamic> _truthMap(Object value) => (value as Map).cast<String, dynamic>();

List<Object?> _truthList(Object value) => (value as List).cast<Object?>();

class _Options implements IOptionsForViewLines {
  _Options(this.values);
  final Map<int, Object?> values;

  @override
  Object? get(Object id) => values[id as int];
}

class _Config implements IEditorConfigurationForViewContext, IConfigurationForViewLines {
  _Config(this.options);
  @override
  final IOptionsForViewLines options;
}

class _Theme implements IColorTheme {
  @override
  ColorScheme get type => ColorScheme.dark;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _WrappingInfo {
  const _WrappingInfo(this.isViewportWrapping);
  final bool isViewportWrapping;
}

class _StickyScroll {
  const _StickyScroll(this.enabled, this.maxLineCount);
  final bool enabled;
  final int maxLineCount;
}

class _Scrollbar {
  const _Scrollbar(this.verticalScrollbarSize);
  final int verticalScrollbarSize;
}

class _LayoutInfo {
  const _LayoutInfo(this.verticalScrollbarWidth);
  final int verticalScrollbarWidth;
}

class _ConfigEvent {
  _ConfigEvent(Iterable<int> changed) : _changed = changed.toSet();
  final Set<int> _changed;
  bool hasChanged(Object id) => _changed.contains(id as int);
}

class _RevealEvent {
  _RevealEvent({
    this.source,
    required this.minimalReveal,
    this.range,
    this.selections,
    required this.verticalType,
    required this.revealHorizontal,
    required this.scrollType,
  });

  final String? source;
  final bool minimalReveal;
  final Range? range;
  final List<Selection>? selections;
  final int verticalType;
  final bool revealHorizontal;
  final int scrollType;
}

class _ScrollEvent {
  const _ScrollEvent({
    required this.scrollWidth,
    required this.scrollLeft,
    required this.scrollHeight,
    required this.scrollTop,
    required this.scrollTopChanged,
    required this.scrollLeftChanged,
  });

  final num scrollWidth;
  final num scrollLeft;
  final num scrollHeight;
  final num scrollTop;
  final bool scrollTopChanged;
  final bool scrollLeftChanged;
}

class _LinesChangedEvent {
  const _LinesChangedEvent(this.fromLineNumber, this.count);
  final int fromLineNumber;
  final int count;
}

class _LinesDeletedEvent {
  const _LinesDeletedEvent(this.fromLineNumber, this.toLineNumber);
  final int fromLineNumber;
  final int toLineNumber;
}

class _LinesInsertedEvent {
  const _LinesInsertedEvent(this.fromLineNumber, this.toLineNumber);
  final int fromLineNumber;
  final int toLineNumber;
}

class _CoordinatesConverter {
  _CoordinatesConverter(this.modelDelta);
  final int modelDelta;

  Position convertViewPositionToModelPosition(Position position) =>
      Position(position.lineNumber + modelDelta, position.column);
}

class _ViewportModel implements IViewModelForViewportData {
  const _ViewportModel();

  @override
  int getLineMinColumn(int lineNumber) => 1;

  @override
  int getLineMaxColumn(int lineNumber) => 20;

  @override
  Object getViewportViewLineRenderingData(Range visibleRange, int lineNumber) =>
      throw StateError('unused');

  @override
  bool getViewLineContinuesWithWrappedLine(int lineNumber) =>
      throw StateError('unused');

  @override
  List<Object> getDecorationsInViewport(Range visibleRange) =>
      throw StateError('unused');
}

ViewportData _viewportData() => ViewportData(
      <Selection>[],
      IPartialViewLinesViewportData(
        startLineNumber: 1,
        endLineNumber: 2,
        relativeVerticalOffset: const <num>[0, 20],
        bigNumbersDelta: 5,
        lineHeight: 20,
      ),
      const <Object>[],
      const _ViewportModel(),
    );

FontInfo _fontInfo() => FontInfo(
      FontInfoOptions(
        pixelRatio: 1,
        fontFamily: _macFontFamily,
        fontWeight: '400',
        fontSize: 14,
        fontFeatureSettings: '',
        fontVariationSettings: '',
        lineHeight: 20,
        letterSpacing: 0,
        isMonospace: true,
        typicalHalfwidthCharacterWidth: 8,
        typicalFullwidthCharacterWidth: 16,
        canUseHalfwidthRightwardsArrow: false,
        spaceWidth: 8,
        middotWidth: 8,
        wsmiddotWidth: 8,
        maxDigitWidth: 8,
      ),
      true,
    );

Map<int, Object?> _baseValues([Map<int, Object?> overrides = const <int, Object?>{}]) =>
    <int, Object?>{
      EditorOption.fontInfo: _fontInfo(),
      EditorOption.wrappingInfo: const _WrappingInfo(false),
      EditorOption.lineHeight: 20,
      EditorOption.revealHorizontalRightPadding: 20,
      EditorOption.cursorSurroundingLines: 0,
      EditorOption.cursorSurroundingLinesStyle: 'default',
      EditorOption.disableLayerHinting: false,
      EditorOption.stickyScroll: const _StickyScroll(false, 5),
      EditorOption.layoutInfo: const _LayoutInfo(10),
      EditorOption.renderWhitespace: 'none',
      EditorOption.experimentalWhitespaceRendering: 'off',
      EditorOption.renderControlCharacters: false,
      EditorOption.disableMonospaceOptimizations: false,
      EditorOption.stopRenderingLineAfter: -1,
      EditorOption.fontLigatures: 'off',
      EditorOption.scrollbar: const _Scrollbar(10),
      EditorOption.experimentalGpuAcceleration: 'off',
      EditorOption.effectiveFullwidthCharacterWidth: 'standard',
    }..addAll(overrides);

class _FakeDomNode implements IViewLinesFastDomNode {
  _FakeDomNode(this._harness);

  final _Harness _harness;
  final Map<String, String> attributes = <String, String>{};
  final Map<String, Object?> style = <String, Object?>{};
  String? className;

  @override
  Object get domNode => this;

  @override
  void setClassName(String value) {
    className = value;
    _harness.domWrites.add(<Object?>['className', value]);
  }

  @override
  void setWidth(num width) => _harness.domWrites.add(<Object?>['width', width]);

  @override
  void setHeight(num height) => _harness.domWrites.add(<Object?>['height', height]);

  @override
  void setTop(num top) => _harness.domWrites.add(<Object?>['top', top]);

  @override
  void setLeft(num left) => _harness.domWrites.add(<Object?>['left', left]);

  @override
  void setLayerHinting(bool enabled) =>
      _harness.domWrites.add(<Object?>['layerHinting', enabled]);

  @override
  void setContain(String value) =>
      _harness.domWrites.add(<Object?>['contain', value]);

  @override
  void setAttribute(String name, String value) {
    attributes[name] = value;
    _harness.domWrites.add(<Object?>['attr', name, value]);
  }

  String? getAttribute(String name) => attributes[name];
}

class _Scheduler implements IViewLinesScheduler {
  _Scheduler(this.runner, this.delay, this._harness);
  final void Function() runner;
  final int delay;
  final _Harness _harness;
  bool _scheduled = false;

  @override
  bool isScheduled() => _scheduled;

  @override
  void schedule() {
    _scheduled = true;
    _harness.schedulerEvents.add(<Object?>['schedule', delay]);
  }

  @override
  void cancel() {
    if (_scheduled) {
      _harness.schedulerEvents.add(<Object?>['cancel', delay]);
    }
    _scheduled = false;
  }

  @override
  void dispose() {
    _harness.schedulerEvents.add(<Object?>['dispose', delay]);
    _scheduled = false;
  }

  @override
  void flush() => runner();
}

class _FakeLine implements IViewLineForViewLines {
  _FakeLine(this._harness);

  final _Harness _harness;
  late int lineNumber;
  Object? domNode;

  @override
  Object? getDomNode() => domNode;

  @override
  void onOptionsChanged(IViewLineOptionsForLine options) =>
      _harness.lineEvents.add(<Object?>['options', lineNumber]);

  @override
  bool onSelectionChanged() {
    _harness.lineEvents.add(<Object?>['selection', lineNumber]);
    return _harness.selectionChanged;
  }

  @override
  void onDecorationsChanged() =>
      _harness.lineEvents.add(<Object?>['decorations', lineNumber]);

  @override
  int getColumnOfNodeOffset(Object spanNode, int offset) =>
      _harness.columnForOffset[offset] ?? offset;

  @override
  num getWidth(DomReadingContext? context) => _harness.lineWidths[lineNumber - 1];

  @override
  bool getWidthIsFast() => _harness.lineWidthFast[lineNumber - 1];

  @override
  void resetCachedWidth() =>
      _harness.lineEvents.add(<Object?>['reset', lineNumber]);

  @override
  VisibleRanges? getVisibleRangesForRange(
    int lineNumber,
    int startColumn,
    int endColumn,
    DomReadingContext context,
  ) {
    _harness.lineEvents.add(<Object?>['ranges', lineNumber, startColumn, endColumn]);
    if (_harness.rangeMarksLayout) context.markDidDomLayout();
    return _harness.lineRanges[lineNumber];
  }

  @override
  bool isRenderedRTL() => _harness.rtlLines.contains(lineNumber);

  @override
  bool needsMonospaceFontCheck() => _harness.monospaceLines.contains(lineNumber);

  @override
  bool monospaceAssumptionsAreValid() => _harness.monospaceValid;

  @override
  void onMonospaceAssumptionsInvalidated() =>
      _harness.lineEvents.add(<Object?>['invalidate', lineNumber]);
}

class _FakeCollection implements IVisibleLinesForViewLines {
  _FakeCollection(this._harness, this.domNode);

  final _Harness _harness;
  @override
  final IViewLinesFastDomNode domNode;

  @override
  void onConfigurationChanged(Object e) =>
      _harness.collectionEvents.add(<Object?>['config']);

  @override
  bool onFlushed(Object e, bool useGpu) {
    _harness.collectionEvents.add(<Object?>['flush', useGpu]);
    return _harness.flushResult;
  }

  @override
  bool onLinesChanged(Object e) {
    final dynamic event = e;
    _harness.collectionEvents.add(<Object?>[
      'changed',
      event.fromLineNumber,
      event.count,
    ]);
    return true;
  }

  @override
  bool onLinesDeleted(Object e) {
    final dynamic event = e;
    _harness.collectionEvents.add(<Object?>[
      'deleted',
      event.fromLineNumber,
      event.toLineNumber,
    ]);
    return true;
  }

  @override
  bool onLinesInserted(Object e) {
    final dynamic event = e;
    _harness.collectionEvents.add(<Object?>[
      'inserted',
      event.fromLineNumber,
      event.toLineNumber,
    ]);
    return true;
  }

  @override
  bool onScrollChanged(Object e) {
    final dynamic event = e;
    _harness.collectionEvents.add(<Object?>[
      'scroll',
      event.scrollTopChanged,
      event.scrollLeftChanged,
    ]);
    return _harness.scrollResult;
  }

  @override
  bool onTokensChanged(Object e) {
    _harness.collectionEvents.add(<Object?>['tokens']);
    return true;
  }

  @override
  bool onZonesChanged(Object e) {
    _harness.collectionEvents.add(<Object?>['zones']);
    return true;
  }

  @override
  int getStartLineNumber() => _harness.startLine;

  @override
  int getEndLineNumber() => _harness.endLine;

  @override
  IViewLineForViewLines getVisibleLine(int lineNumber) =>
      _harness.lines[lineNumber - _harness.startLine];

  @override
  void renderLines(ViewportData viewportData) => _harness.collectionEvents.add(
        <Object?>['render', viewportData.startLineNumber, viewportData.endLineNumber],
      );
}

class _Layout implements IViewLayoutForViewContext, IViewLayoutForViewLines {
  _Layout(this._harness);

  final _Harness _harness;

  Viewport get _viewport => Viewport(0, 0, 200, 100);

  Viewport getFutureViewport() => _viewport;
  Viewport getCurrentViewport() => _viewport;

  Map<String, num> validateScrollPosition(Map<String, num> position) =>
      <String, num>{
        'scrollTop': position['scrollTop'] ?? 0,
        'scrollLeft': _harness.validatedScrollLeft,
      };

  num getCurrentScrollTop() => _harness.scrollTop;
  num getCurrentScrollLeft() => _harness.scrollLeft;
  num getScrollWidth() => _harness.scrollWidth;
  num getScrollHeight() => _harness.scrollHeight;

  num getVerticalOffsetForLineNumber(int lineNumber) =>
      _harness.lineOffsets[lineNumber - 1];

  void setMaxLineWidth(num maxLineWidth) =>
      _harness.maxLineWidthCalls.add(maxLineWidth);

  void setScrollPosition(Map<String, num> position, int scrollType) =>
      _harness.scrollCalls.add(<Object?>[
        position.map<String, num>((String k, num v) => MapEntry<String, num>(k, _jsNum(v))),
        scrollType,
      ]);

  void setScrollTop(num value) => _harness.scrollTop = value;
  void setScrollLeft(num value) => _harness.scrollLeft = value;
}

class _Model implements IViewModelForViewContext, IViewModelForViewLines {
  _Model(this._harness, this.viewLayout);

  final _Harness _harness;
  @override
  final _Layout viewLayout;
  final List<Object> handlers = <Object>[];

  int getLineCount() => _harness.lineCount;
  int getLineMinColumn(int lineNumber) => 1;
  int getLineMaxColumn(int lineNumber) => _harness.lineMax[lineNumber - 1];
  int getTextDirection(int lineNumber) => _harness.textDirections[lineNumber - 1];

  Object get coordinatesConverter => _CoordinatesConverter(_harness.modelDelta);

  @override
  void addViewEventHandler(ViewEventHandler eventHandler) =>
      handlers.add(eventHandler);

  @override
  void removeViewEventHandler(ViewEventHandler eventHandler) =>
      handlers.remove(eventHandler);
}

class _Harness {
  _Harness({Map<int, Object?>? values, bool isLinux = false}) {
    setIsLinuxForViewLinesReplay(isLinux);
    options = _Options(values ?? _baseValues());
    config = _Config(options);
    layout = _Layout(this);
    model = _Model(this, layout);
    context = ViewContext(config, _Theme(), model);
    contentNode = _FakeDomNode(this);
    collectionNode = _FakeDomNode(this);
    restingSpot = DomReadElement(
      rectProvider: () => <String, num>{'left': 0, 'width': 8},
      offsetWidth: 8,
    );

    configureViewLinesSchedulerFactoryForReplay(
      (void Function() runner, int delay) => _Scheduler(runner, delay, this),
    );
    configureViewLinesRestingSpotFactoryForReplay(() => restingSpot);
    configureViewLinesCollectionFactoryForReplay((
      ViewContext context,
      IViewLineForViewLines Function() createLine,
    ) {
      lines.clear();
      for (int i = 0; i < 2; i++) {
        final _FakeLine line = _FakeLine(this)..lineNumber = i + 1;
        lines.add(line);
      }
      return _FakeCollection(this, collectionNode);
    });
    viewLines = ViewLines(context, null, contentNode);
  }

  late final _Options options;
  late final _Config config;
  late final _Layout layout;
  late final _Model model;
  late final ViewContext context;
  late final _FakeDomNode contentNode;
  late final _FakeDomNode collectionNode;
  late final DomReadElement restingSpot;
  late final ViewLines viewLines;

  final List<List<Object?>> domWrites = <List<Object?>>[];
  final List<List<Object?>> schedulerEvents = <List<Object?>>[];
  final List<List<Object?>> collectionEvents = <List<Object?>>[];
  final List<List<Object?>> lineEvents = <List<Object?>>[];
  final List<num> maxLineWidthCalls = <num>[];
  final List<List<Object?>> scrollCalls = <List<Object?>>[];
  final List<_FakeLine> lines = <_FakeLine>[];

  bool domDidLayout = false;
  bool rangeMarksLayout = false;
  bool selectionChanged = false;
  bool flushResult = true;
  bool scrollResult = true;
  List<num> lineWidths = <num>[40, 60];
  List<bool> lineWidthFast = <bool>[true, true];
  Map<int, VisibleRanges> lineRanges = <int, VisibleRanges>{};
  Map<int, int> columnForOffset = <int, int>{3: 7};
  Set<int> rtlLines = <int>{};
  Set<int> monospaceLines = <int>{};
  bool monospaceValid = true;
  int startLine = 1;
  int endLine = 2;
  int lineCount = 2;
  int modelDelta = 0;
  List<int> lineMax = <int>[20, 20];
  List<int> textDirections = <int>[0, 0];
  List<num> lineOffsets = <num>[0, 20];
  num scrollTop = 0;
  num scrollLeft = 0;
  num scrollWidth = 300;
  num scrollHeight = 200;
  num validatedScrollLeft = 0;

  Map<String, Object?> snapshot() => <String, Object?>{
        'domWrites': domWrites,
        'schedulerEvents': schedulerEvents,
        'collectionEvents': collectionEvents,
        'lineEvents': lineEvents,
        'maxLineWidthCalls': maxLineWidthCalls,
        'scrollCalls': scrollCalls,
        'handlers': model.handlers.length,
      };
}

List<Object?> _serializeLines(List<LineVisibleRanges>? ranges) {
  if (ranges == null) return const <Object?>[];
  return ranges
      .map((LineVisibleRanges r) => <String, Object?>{
            'outsideRenderedLine': r.outsideRenderedLine,
            'lineNumber': r.lineNumber,
            'ranges': r.ranges
                .map((dynamic h) => <Object?>[h.left, h.width])
                .toList(),
            'continuesOnNextLine': r.continuesOnNextLine,
          })
      .toList();
}

void main() {
  final Map<String, dynamic> truth = _truth();

  group('viewLines.ts events', () {
    final Map<String, dynamic> events = _truthMap(truth['events']!);

    test('constructor, configuration and all view handlers', () {
      final _Harness h = _Harness();
      h.options.values[EditorOption.lineHeight] = 22;
      h.options.values[EditorOption.renderWhitespace] = 'selection';
      final bool configuration = h.viewLines.onConfigurationChanged(
        _ConfigEvent(<int>[EditorOption.wrappingInfo, EditorOption.layoutInfo]),
      );

      h.selectionChanged = true;
      expect(configuration, isTrue);
      expect(h.viewLines.onCursorStateChanged(Object()), isTrue);
      expect(h.viewLines.onDecorationsChanged(Object()), isTrue);
      expect(h.viewLines.onFlushed(Object()), isTrue);
      expect(
        h.viewLines.onLinesChanged(const _LinesChangedEvent(1, 1)),
        isTrue,
      );
      expect(
        h.viewLines.onLinesDeleted(const _LinesDeletedEvent(1, 2)),
        isTrue,
      );
      expect(
        h.viewLines.onLinesInserted(const _LinesInsertedEvent(1, 2)),
        isTrue,
      );
      expect(
        h.viewLines.onScrollChanged(const _ScrollEvent(
          scrollWidth: 400,
          scrollLeft: 5,
          scrollHeight: 0,
          scrollTop: 10,
          scrollTopChanged: true,
          scrollLeftChanged: true,
        )),
        isTrue,
      );
      expect(h.viewLines.onTokensChanged(Object()), isTrue);
      expect(h.viewLines.onZonesChanged(Object()), isTrue);
      expect(h.viewLines.onThemeChanged(Object()), isFalse);

      final Map<String, Object?> snap = h.snapshot();
      for (final String key in <String>[
        'constructor',
        'configurationSnapshot',
        'snapshotAfterEvents',
      ]) {
        expect(snap, equals(_truthMap(events[key]!)), reason: key);
      }
      expect(
        h.viewLines.getDomNode().domNode,
        isA<_FakeDomNode>().having((_FakeDomNode n) => n.className, 'className',
            events['domNodeClassName']),
      );
      expect(
        (h.viewLines.getDomNode().domNode as _FakeDomNode).attributes['data-mprt'],
        events['domNodeFingerprint'],
      );
      expect(
        (h.viewLines.getDomNode().domNode as _FakeDomNode).style,
        equals(_truthMap(events['domNodeStyle']!)),
      );
      expect(h.model.handlers.length, events['handlers']);
      expect(configuration, events['configuration']);
    });
  });

  group('viewLines.ts helpers', () {
    final Map<String, dynamic> helpers = _truthMap(truth['helpers']!);

    test('DOM info, widths and visible ranges', () {
      final _Harness h = _Harness();
      h.viewLines
          .setCurrentVisibleRangeForReplay(Range(1, 1, 2, 20));
      h.lineRanges[1] = VisibleRanges(
        false,
        <FloatHorizontalRange>[FloatHorizontalRange(10, 20)],
      );
      h.lineRanges[2] = VisibleRanges(
        false,
        <FloatHorizontalRange>[FloatHorizontalRange(12, 8)],
      );

      final _DomNode lineNode = _DomNode('view-line');
      h.lines[0].domNode = lineNode;
      final Position? position = h.viewLines.getPositionFromDOMInfo(
        _DomNode('span', lineNode),
        3,
      );
      expect(
        position == null ? null : <Object?>[position.lineNumber, position.column],
        equals(_truthList(helpers['position']!)),
      );
      expect(h.viewLines.getLineWidth(1), helpers['lineWidth']);
      expect(h.viewLines.getLineWidth(9), helpers['lineWidthOutside']);
      expect(
        _serializeLines(
          h.viewLines.linesVisibleRangesForRange(Range(1, 2, 2, 5), false),
        ),
        equals(_truthList(helpers['ranges']!)),
      );
      expect(
        _serializeLines(
          h.viewLines.linesVisibleRangesForRange(Range(1, 2, 2, 5), true),
        ),
        equals(_truthList(helpers['rangesWithNewLines']!)),
      );
      final Position probe = Position(2, 4);
      final HorizontalPosition? visible = h.viewLines.visibleRangeForPosition(probe);
      expect(
        visible == null ? null : <Object?>[false, visible.left],
        equals(_truthList(helpers['visiblePosition']!)),
      );
      h.viewLines.resetLineWidthCaches();
      expect(h.snapshot(), equals(_truthMap(helpers['snapshot']!)));
    });
  });

  group('viewLines.ts render + reveal', () {
    final Map<String, dynamic> render = _truthMap(truth['render']!);

    test('renderText, reveal request and scheduler flushes', () {
      final _Harness h = _Harness(
        values: _baseValues(<int, Object?>{
          EditorOption.cursorSurroundingLines: 2,
          EditorOption.stickyScroll: const _StickyScroll(true, 3),
        }),
        isLinux: true,
      );
      h.lineWidthFast = <bool>[true, false];
      h.monospaceLines.add(1);

      final ViewportData vpData = _viewportData();
      h.viewLines.renderText(vpData);
      final Map<String, Object?> afterRender = h.snapshot();

      expect(
        h.viewLines.onRevealRangeRequest(_RevealEvent(
          source: null,
          minimalReveal: false,
          range: Range(2, 4, 2, 8),
          selections: null,
          verticalType: VerticalRevealType.Simple,
          revealHorizontal: true,
          scrollType: 1,
        )),
        isTrue,
      );
      h.lineRanges[2] = VisibleRanges(
        false,
        <FloatHorizontalRange>[FloatHorizontalRange(100, 50)],
      );
      h.viewLines.renderText(vpData);
      final Map<String, Object?> afterHorizontal = h.snapshot();

      h.viewLines.flushUpdateLineWidthsForReplay();
      final Map<String, Object?> afterWidthFlush = h.snapshot();
      h.viewLines.flushMonospaceCheckForReplay();
      final Map<String, Object?> afterMonospaceFlush = h.snapshot();

      expect(afterRender, equals(_truthMap(render['afterRender']!)));
      expect(afterHorizontal, equals(_truthMap(render['afterHorizontal']!)));
      expect(afterWidthFlush, equals(_truthMap(render['afterWidthFlush']!)));
      expect(
        afterMonospaceFlush,
        equals(_truthMap(render['afterMonospaceFlush']!)),
      );
    });
  });
}

class _DomNode {
  const _DomNode(this.className, [this.parentElement]);

  final String className;
  final int nodeType = 1;
  final Object? parentElement;
}
