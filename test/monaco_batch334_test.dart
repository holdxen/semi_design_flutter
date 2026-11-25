// 1:1 replay of
//   `editor/browser/view/renderingContext.ts` (217 lines),
//   `editor/browser/view/viewPart.ts` (82 lines).
// Truth: `tool/ts2dart/_batch334_truth.cjs` -> `batch334_truth.json`.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data' show Uint8List;

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/browser/view/renderingContext.dart';
import '../lib/src/monaco/editor/browser/view/viewPart.dart';
import '../lib/src/monaco/editor/common/core/position.dart' show Position;
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/core/selection.dart' show Selection;
import '../lib/src/monaco/editor/common/viewEventHandler.dart'
    show ViewEventHandler;
import '../lib/src/monaco/editor/common/viewLayout/viewLinesViewportData.dart';
import '../lib/src/monaco/editor/common/viewModel.dart'
    show ViewModelDecoration, Viewport;
import '../lib/src/monaco/editor/common/viewModel/viewContext.dart';
import '../lib/src/monaco/platform/theme/common/themeService.dart'
    show IColorTheme;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(
  jsonDecode(File('tool/ts2dart/batch334_truth.json').readAsStringSync()),
);

class _Model implements IViewModelForViewportData {
  _Model(this.decorations);

  final List<Object> decorations;

  @override
  int getLineMinColumn(int lineNumber) => 1;

  @override
  int getLineMaxColumn(int lineNumber) => 10;

  @override
  Object getViewportViewLineRenderingData(Range visibleRange, int lineNumber) =>
      Object();

  @override
  bool getViewLineContinuesWithWrappedLine(int lineNumber) => false;

  @override
  List<Object> getDecorationsInViewport(Range visibleRange) => decorations;
}

ViewportData _viewportData(List<Object> decorations) => ViewportData(
  <Selection>[],
  IPartialViewLinesViewportData(
    startLineNumber: 3,
    endLineNumber: 40,
    relativeVerticalOffset: <num>[0],
    bigNumbersDelta: 7,
    lineHeight: 19,
  ),
  <Object>[],
  _Model(decorations),
);

class _Layout implements IViewLayoutForRenderingContext {
  @override
  num getScrollWidth() => 1234;

  @override
  num getScrollHeight() => 5678;

  @override
  Viewport getCurrentViewport() => Viewport(100, 20, 800, 600);

  @override
  num getVerticalOffsetForLineNumber(
    int lineNumber, [
    bool? includeViewZones,
  ]) => lineNumber * 10 + ((includeViewZones ?? false) ? 1 : 0);

  @override
  num getVerticalOffsetAfterLineNumber(
    int lineNumber, [
    bool? includeViewZones,
  ]) => lineNumber * 10 + 5 + ((includeViewZones ?? false) ? 1 : 0);

  @override
  num getLineHeightForLineNumber(int lineNumber) => 19;
}

class _FakeViewLines implements IViewLines {
  _FakeViewLines(this.ranges, this.position);

  final List<LineVisibleRanges>? ranges;
  final HorizontalPosition? position;

  @override
  List<LineVisibleRanges>? linesVisibleRangesForRange(
    Range range,
    bool includeNewLines,
  ) => ranges;

  @override
  HorizontalPosition? visibleRangeForPosition(Position position) =>
      this.position;
}

LineVisibleRanges _lineRange(
  bool outside,
  int lineNumber,
  List<num> lefts,
  bool continues,
) => LineVisibleRanges(
  outside,
  lineNumber,
  lefts.map((num l) => HorizontalRange(l, l + 1)).toList(),
  continues,
);

List<List<Object?>>? _serializeRanges(List<LineVisibleRanges>? ranges) {
  if (ranges == null) return null;
  return ranges
      .map(
        (LineVisibleRanges r) => <Object?>[
          r.outsideRenderedLine,
          r.lineNumber,
          r.ranges.map((HorizontalRange h) => h.toString()).toList(),
          r.continuesOnNextLine,
        ],
      )
      .toList();
}

class _Doc {
  _Element? body;
}

class _Element {
  _Element(this.parentElement, this.ownerDocument);

  static const int elementNode = 1;

  final _Element? parentElement;
  final _Doc ownerDocument;
  final Map<String, String> _attrs = <String, String>{};

  int get nodeType => elementNode;
  int get ELEMENT_NODE => elementNode;

  void setAttribute(String name, String value) => _attrs[name] = value;

  String? getAttribute(String name) => _attrs[name];
}

class _VM implements IViewModelForViewContext {
  _VM(this.log);

  final List<String> log;

  @override
  IViewLayoutForViewContext get viewLayout => _LayoutForContext();

  @override
  void addViewEventHandler(ViewEventHandler eventHandler) {
    log.add('add');
    this._handler = eventHandler;
  }

  @override
  void removeViewEventHandler(ViewEventHandler eventHandler) {
    log.add('remove:${identical(eventHandler, _handler)}');
  }

  ViewEventHandler? _handler;
}

class _LayoutForContext implements IViewLayoutForViewContext {}

class _Conf implements IEditorConfigurationForViewContext {}

class _Theme implements IColorTheme {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _TestPart extends ViewPart {
  _TestPart(super.context);

  int prepared = 0;
  int rendered = 0;
  int before = 0;
  Object? preparedCtx;
  Object? renderedCtx;

  @override
  void prepareRender(RenderingContext ctx) {
    prepared++;
    preparedCtx = ctx;
  }

  @override
  void render(RestrictedRenderingContext ctx) {
    rendered++;
    renderedCtx = ctx;
  }

  @override
  void onBeforeRender(ViewportData viewportData) {
    before++;
  }
}

void main() {
  final truth = _truth();

  test('RestrictedRenderingContext pulls layout + viewport data', () {
    final ctx = RestrictedRenderingContext(
      _Layout(),
      _viewportData(<Object>[
        ViewModelDecoration(Range(1, 1, 1, 2), 'd1'),
        ViewModelDecoration(Range(1, 1, 1, 2), 'd2'),
      ]),
    );
    final actual = <String, Object?>{
      'scrollWidth': ctx.scrollWidth,
      'scrollHeight': ctx.scrollHeight,
      'visibleRange': <int>[
        ctx.visibleRange.startLineNumber,
        ctx.visibleRange.startColumn,
        ctx.visibleRange.endLineNumber,
        ctx.visibleRange.endColumn,
      ],
      'bigNumbersDelta': ctx.bigNumbersDelta,
      'scrollTop': ctx.scrollTop,
      'scrollLeft': ctx.scrollLeft,
      'viewportWidth': ctx.viewportWidth,
      'viewportHeight': ctx.viewportHeight,
      'scrolledTop': ctx.getScrolledTopFromAbsoluteTop(250),
      'verticalOffset': ctx.getVerticalOffsetForLineNumber(4, false),
      'verticalOffsetZones': ctx.getVerticalOffsetForLineNumber(4, true),
      'verticalOffsetAfter': ctx.getVerticalOffsetAfterLineNumber(6, false),
      'verticalOffsetAfterZones': ctx.getVerticalOffsetAfterLineNumber(6, true),
      'lineHeight': ctx.getLineHeightForLineNumber(9),
      'decorations': ctx
          .getDecorationsInViewport()
          .map((ViewModelDecoration d) => d.options)
          .toList(),
    };
    expect(actual, _map(truth['restricted']));
  });

  test('RenderingContext merges/sorts DOM+GPU ranges and falls back', () {
    final domRanges = <LineVisibleRanges>[
      _lineRange(true, 5, <num>[10], false),
      _lineRange(true, 2, <num>[5], true),
    ];
    final gpuRanges = <LineVisibleRanges>[
      _lineRange(false, 2, <num>[30], false),
      _lineRange(false, 9, <num>[40], false),
    ];
    final merged = RenderingContext(
      _Layout(),
      _viewportData(<Object>[]),
      _FakeViewLines(domRanges, HorizontalPosition(true, 10.6)),
      _FakeViewLines(gpuRanges, HorizontalPosition(false, 3.2)),
    );
    final domNull = RenderingContext(
      _Layout(),
      _viewportData(<Object>[]),
      _FakeViewLines(null, null),
      _FakeViewLines(gpuRanges, null),
    );
    final gpuNull = RenderingContext(
      _Layout(),
      _viewportData(<Object>[]),
      _FakeViewLines(domRanges, null),
      _FakeViewLines(null, null),
    );
    final bothNull = RenderingContext(
      _Layout(),
      _viewportData(<Object>[]),
      _FakeViewLines(null, null),
      _FakeViewLines(null, null),
    );
    final noGpu = RenderingContext(
      _Layout(),
      _viewportData(<Object>[]),
      _FakeViewLines(domRanges, HorizontalPosition(true, 8.4)),
    );
    final domOnlyPosition = RenderingContext(
      _Layout(),
      _viewportData(<Object>[]),
      _FakeViewLines(domRanges, null),
      _FakeViewLines(gpuRanges, HorizontalPosition(false, 3.2)),
    );

    final actual = <String, Object?>{
      'merged': _serializeRanges(
        merged.linesVisibleRangesForRange(Range(2, 1, 9, 1), true),
      ),
      'mergedPosition': <Object?>[
        merged.visibleRangeForPosition(Position(2, 3))!.outsideRenderedLine,
        merged.visibleRangeForPosition(Position(2, 3))!.left,
      ],
      'domOnlyPosition': <Object?>[
        domOnlyPosition.visibleRangeForPosition(Position(2, 3))!.left,
      ],
      'bothNullPosition': null,
      'domNull': _serializeRanges(
        domNull.linesVisibleRangesForRange(Range(1, 1, 2, 1), false),
      ),
      'gpuNull': _serializeRanges(
        gpuNull.linesVisibleRangesForRange(Range(1, 1, 2, 1), false),
      ),
      'bothNull': _serializeRanges(
        bothNull.linesVisibleRangesForRange(Range(1, 1, 2, 1), false),
      ),
      'noGpu': _serializeRanges(
        noGpu.linesVisibleRangesForRange(Range(1, 1, 2, 1), false),
      ),
      'noGpuPosition': noGpu.visibleRangeForPosition(Position(2, 3))!.left,
    };
    expect(actual, _map(truth['context']));

    expect(
      RenderingContext(
        _Layout(),
        _viewportData(<Object>[]),
        _FakeViewLines(domRanges, null),
      ).visibleRangeForPosition(Position(2, 3)),
      isNull,
    );
    expect(
      RenderingContext(
        _Layout(),
        _viewportData(<Object>[]),
        _FakeViewLines(null, null),
        _FakeViewLines(null, null),
      ).visibleRangeForPosition(Position(2, 3)),
      isNull,
    );
    expect(bothNull.visibleRangeForPosition(Position(2, 3)), isNull);
  });

  test('range carriers mirror JS rounding, compare and first/last helpers', () {
    final actual = <String, Object?>{
      'firstLine': LineVisibleRanges.firstLine(<LineVisibleRanges>[
        _lineRange(true, 5, <num>[], false),
        _lineRange(true, 2, <num>[], false),
        _lineRange(true, 7, <num>[], false),
      ])!.lineNumber,
      'firstLineNull': LineVisibleRanges.firstLine(null),
      'firstLineEmpty': LineVisibleRanges.firstLine(<LineVisibleRanges>[]),
      'lastLine': LineVisibleRanges.lastLine(<LineVisibleRanges>[
        _lineRange(true, 5, <num>[], false),
        _lineRange(true, 9, <num>[], false),
        _lineRange(true, 7, <num>[], false),
      ])!.lineNumber,
      'lastLineNull': LineVisibleRanges.lastLine(null),
      'horizontalRounding': <String>[
        HorizontalRange(2.5, 2.4).toString(),
        HorizontalRange(-2.5, -2.6).toString(),
        HorizontalRange(0.5, 0.499).toString(),
      ],
      'horizontalFrom': HorizontalRange.from(<FloatHorizontalRange>[
        FloatHorizontalRange(1.4, 2.5),
        FloatHorizontalRange(-1.5, 0.5),
      ]).map((HorizontalRange h) => <num>[h.left, h.width]).toList(),
      'floatCompare': <int>[
        FloatHorizontalRange.compare(
          FloatHorizontalRange(1, 0),
          FloatHorizontalRange(2, 0),
        ),
        FloatHorizontalRange.compare(
          FloatHorizontalRange(2, 0),
          FloatHorizontalRange(1, 0),
        ),
        FloatHorizontalRange.compare(
          FloatHorizontalRange(1, 0),
          FloatHorizontalRange(1, 0),
        ),
      ],
      'floatToString': FloatHorizontalRange(1.25, 3.5).toString(),
      'positionRounding': <int>[
        HorizontalPosition(true, 10.6).left,
        HorizontalPosition(false, -2.5).left,
        HorizontalPosition(false, 2.5).left,
      ],
      'visibleRanges': <Object?>[
        VisibleRanges(true, <FloatHorizontalRange>[
          FloatHorizontalRange(1, 2),
        ]).outsideRenderedLine,
        VisibleRanges(true, <FloatHorizontalRange>[
          FloatHorizontalRange(1, 2),
        ]).ranges.length,
      ],
    };
    expect(actual, _map(truth['ranges']));
  });

  test('PartFingerprints writes, reads, parses and collects in reverse', () {
    final doc = _Doc();
    final body = _Element(null, doc);
    doc.body = body;
    final a = _Element(body, doc);
    final b = _Element(a, doc);
    final c = _Element(b, doc);
    final d = _Element(body, doc);

    PartFingerprints.write(a, PartFingerprint.OverflowGuard);
    PartFingerprints.write(b, PartFingerprint.OverflowingOverlayWidgets);
    PartFingerprints.write(c, PartFingerprint.TextArea);
    PartFingerprints.write(d, 9);

    List<int> bytes(Uint8List value) => value.toList();

    final actual = <String, Object?>{
      'readWritten': <int>[
        PartFingerprints.read(a),
        PartFingerprints.read(b),
        PartFingerprints.read(c),
        PartFingerprints.read(d),
      ],
      'collectAll': bytes(PartFingerprints.collect(c, body)),
      'collectToStop': bytes(PartFingerprints.collect(b, a)),
      'collectBody': bytes(PartFingerprints.collect(body, body)),
      'readMissing': PartFingerprints.read(_Element(body, doc)),
      'parseIntPrefix': <String>['9abc', ' 12px', '+4x'].map((String value) {
        final node = _Element(body, doc);
        node.setAttribute('data-mprt', value);
        return PartFingerprints.read(node);
      }).toList(),
    };
    expect(actual, _map(truth['fingerprints']));
  });

  test('ViewPart registers, hooks and unregisters exactly once', () {
    final log = <String>[];
    final context = ViewContext(_Conf(), _Theme(), _VM(log));
    final part = _TestPart(context);
    final afterConstruct = log.toList();

    part.onBeforeRender(_viewportData(<Object>[]));
    part.prepareRender(
      RenderingContext(
        _Layout(),
        _viewportData(<Object>[]),
        _FakeViewLines(null, null),
      ),
    );
    part.render(
      RestrictedRenderingContext(_Layout(), _viewportData(<Object>[])),
    );
    part.dispose();

    final actual = <String, Object?>{
      'afterConstruct': afterConstruct,
      'afterDispose': log,
      'counts': <int>[part.prepared, part.rendered, part.before],
      'preparedMarker':
          (part.preparedCtx as RenderingContext).viewportData.bigNumbersDelta,
      'renderedMarker': (part.renderedCtx as RestrictedRenderingContext)
          .viewportData
          .bigNumbersDelta,
      'shouldRender': part.shouldRender(),
    };
    final expected = _map(truth['viewPart']);
    // The truth used synthetic contexts tagged 'prepare'/'render'; the
    // observable contract (one hook call each, registration log, shouldRender)
    // is compared directly.
    expect(actual['afterConstruct'], expected['afterConstruct']);
    expect(actual['afterDispose'], expected['afterDispose']);
    expect(actual['counts'], expected['counts']);
    expect(actual['preparedMarker'], 7);
    expect(actual['renderedMarker'], 7);
    expect(actual['shouldRender'], expected['shouldRender']);
  });
}
