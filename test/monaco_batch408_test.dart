// 1:1 replay of `editor/browser/viewParts/decorations/decorations.ts`.
// Truth: `tool/ts2dart/_batch408_truth.cjs` -> `batch408_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/browser/view/renderingContext.dart'
    show HorizontalRange, LineVisibleRanges, RenderingContext;
import '../lib/src/monaco/editor/browser/viewParts/decorations/decorations.dart';
import '../lib/src/monaco/editor/common/config/editorOptions.dart'
    show EditorOption;
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/viewEventHandler.dart'
    show ViewEventHandler;
import '../lib/src/monaco/editor/common/viewModel.dart'
    show ViewModelDecoration;

Map<String, dynamic> _map(dynamic v) => (v as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root = _map(
    jsonDecode(File('tool/ts2dart/batch408_truth.json').readAsStringSync()),
  );
  return <String, dynamic>{
    for (final dynamic r in root['results'] as List<dynamic>)
      (r as Map)['label'] as String: <String, dynamic>{
        for (final MapEntry<Object?, Object?> e
            in (r as Map).cast<Object?, Object?>().entries)
          if (e.key != 'label') e.key as String: e.value,
      },
  };
}

class _FontInfo {
  final num typicalHalfwidthCharacterWidth;
  _FontInfo(this.typicalHalfwidthCharacterWidth);
}

class _Config implements IDecorationsConfiguration {
  final num halfWidth;
  _Config(this.halfWidth);
  @override
  IDecorationsEditorOptions get options => _Options(this);
}

class _Options implements IDecorationsEditorOptions {
  final _Config config;
  _Options(this.config);
  @override
  Object? get(Object id) =>
      id == EditorOption.fontInfo ? _FontInfo(config.halfWidth) : null;
}

class _ViewModel {
  final int Function(int) maxColumn;
  _ViewModel(this.maxColumn);
  int getLineMaxColumn(int lineNumber) => maxColumn(lineNumber);
}

class _Context implements IDecorationsViewContext {
  @override
  _Config configuration;
  @override
  final Object viewModel;
  final List<ViewEventHandler> handlers = <ViewEventHandler>[];

  _Context(num halfWidth, int Function(int) maxColumn)
      : configuration = _Config(halfWidth),
        viewModel = _ViewModel(maxColumn);

  @override
  void addEventHandler(ViewEventHandler h) => handlers.add(h);
  @override
  void removeEventHandler(ViewEventHandler h) => handlers.remove(h);
}

class _DecorationOptions {
  final String? className;
  final bool? isWholeLine;
  final bool? showIfCollapsed;
  final bool? shouldFillLineOnLineBreak;
  final num? zIndex;
  _DecorationOptions({
    this.className,
    this.isWholeLine,
    this.showIfCollapsed,
    this.shouldFillLineOnLineBreak,
    this.zIndex,
  });
}

ViewModelDecoration deco(int sl, int sc, int el, int ec,
        _DecorationOptions opts) =>
    ViewModelDecoration(Range(sl, sc, el, ec), opts);

List<HorizontalRange> _ranges(List<dynamic> raw) => raw
    .map((dynamic r) => HorizontalRange(
          (r as Map)['left'] as num,
          r['width'] as num,
        ))
    .toList();

class _RenderCtx implements RenderingContext {
  final List<ViewModelDecoration> decorations;
  final List<LineVisibleRanges> Function(Range range, bool includeNewLines)
      visibleRangesFor;
  final int start, end;

  _RenderCtx(this.decorations, this.visibleRangesFor, this.start, this.end);

  @override
  List<ViewModelDecoration> getDecorationsInViewport() => decorations;

  @override
  Range get visibleRange => Range(start, 1, end, 1);

  @override
  List<LineVisibleRanges>? linesVisibleRangesForRange(
    Range range,
    bool includeNewLines,
  ) =>
      visibleRangesFor(range, includeNewLines);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Object? _renderCase(
  Map<String, dynamic> raw, {
  required List<ViewModelDecoration> decorations,
  Function(Range, bool)? visibleRangesFor,
}) {
  final _Context ctx = _Context(
    raw['halfWidth'] as int? ?? 10,
    raw['maxColumn'] as int Function(int)? ?? ((int _) => 100),
  );
  final DecorationsOverlay overlay = DecorationsOverlay(ctx);
  final int start = raw['start'] as int? ?? 1;
  final int end = raw['end'] as int? ?? 1;
  overlay.prepareRender(_RenderCtx(
    decorations,
    (Range range, bool include) =>
        (visibleRangesFor == null ? <LineVisibleRanges>[] : visibleRangesFor(range, include))
            as List<LineVisibleRanges>,
    start,
    end,
  ));
  final List<Object?> rendered = <Object?>[];
  for (int ln = start; ln <= end; ln++) {
    rendered.add(overlay.render(start, ln));
  }
  overlay.dispose();
  return <String, Object?>{
    'rendered': rendered,
    'handlers': ctx.handlers.length,
  };
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('decorations overlay replay TS truth', () {
    final Map<String, Object?> actual = <String, Object?>{};

    actual['whole-line'] = _renderCase(<String, dynamic>{
      'halfWidth': 10,
      'start': 1,
      'end': 4,
    }, decorations: <ViewModelDecoration>[
      deco(1, 1, 3, 1, _DecorationOptions(className: 'whole', isWholeLine: true, zIndex: 0)),
      deco(2, 1, 5, 1, _DecorationOptions(className: 'whole', isWholeLine: true, zIndex: 0)),
    ]);

    actual['normal-sort-merge'] =
        _renderCase(<String, dynamic>{'start': 1, 'end': 1}, decorations: <
            ViewModelDecoration>[
      deco(1, 1, 1, 5, _DecorationOptions(className: 'b', zIndex: 1)),
      deco(1, 1, 1, 3, _DecorationOptions(className: 'a', zIndex: 2)),
      deco(1, 4, 1, 6, _DecorationOptions(className: 'b', zIndex: 1)),
    ], visibleRangesFor: (Range range, bool include) {
      final int left = (range.startColumn - 1) * 10;
      final int width = (range.endColumn - range.startColumn) * 10;
      return <LineVisibleRanges>[
        LineVisibleRanges(false, range.startLineNumber,
            <HorizontalRange>[HorizontalRange(left, width)], false),
      ];
    });

    actual['collapsed-expand'] = _renderCase(<String, dynamic>{
      'halfWidth': 12,
      'maxColumn': (int _) => 20,
      'start': 1,
      'end': 3,
    }, decorations: <ViewModelDecoration>[
      deco(1, 2, 3, 1, _DecorationOptions(className: 'collapsed', showIfCollapsed: true, zIndex: 0)),
    ], visibleRangesFor: (Range range, bool include) {
      return <LineVisibleRanges>[
        LineVisibleRanges(false, range.startLineNumber,
            <HorizontalRange>[HorizontalRange(5, 3)], false),
      ];
    });

    actual['fill-line-break'] =
        _renderCase(<String, dynamic>{'start': 1, 'end': 1}, decorations: <
            ViewModelDecoration>[
      deco(1, 2, 1, 4, _DecorationOptions(
        className: 'fill', zIndex: 0, shouldFillLineOnLineBreak: true,
      )),
    ], visibleRangesFor: (Range range, bool include) {
      return <LineVisibleRanges>[
        LineVisibleRanges(false, range.startLineNumber,
            <HorizontalRange>[HorizontalRange(10, 20)], true),
      ];
    });

    actual['outside'] =
        _renderCase(<String, dynamic>{'start': 1, 'end': 1}, decorations: <
            ViewModelDecoration>[
      deco(1, 1, 1, 3, _DecorationOptions(className: 'x', zIndex: 0)),
    ], visibleRangesFor: (Range range, bool include) {
      return <LineVisibleRanges>[
        LineVisibleRanges(true, 1,
            <HorizontalRange>[HorizontalRange(0, 20)], false),
      ];
    });

    // events
    final _Context ectx = _Context(10, (int _) => 100);
    final DecorationsOverlay overlay = DecorationsOverlay(ectx);
    final Map<String, Object?> events = <String, Object?>{
      'configuration': overlay.onConfigurationChanged(<Object, Object?>{}),
      'decorations': overlay.onDecorationsChanged(<Object, Object?>{}),
      'flushed': overlay.onFlushed(<Object, Object?>{}),
      'linesChanged': overlay.onLinesChanged(<Object, Object?>{}),
      'linesDeleted': overlay.onLinesDeleted(<Object, Object?>{}),
      'linesInserted': overlay.onLinesInserted(<Object, Object?>{}),
      'scrollTop': overlay.onScrollChanged(<Object, Object?>{
        'scrollTopChanged': true, 'scrollWidthChanged': false,
      }),
      'scrollWidth': overlay.onScrollChanged(<Object, Object?>{
        'scrollTopChanged': false, 'scrollWidthChanged': true,
      }),
      'scrollOther': overlay.onScrollChanged(<Object, Object?>{
        'scrollTopChanged': false, 'scrollWidthChanged': false,
      }),
      'zones': overlay.onZonesChanged(<Object, Object?>{}),
    };
    final String before = overlay.render(1, 1);
    overlay.dispose();
    actual['events'] = <String, Object?>{
      'data': events,
      'before': before,
      'handlers': ectx.handlers.length,
    };

    for (final String key in truth.keys) {
      expect(
        jsonEncode(actual[key]),
        jsonEncode(truth[key]),
        reason: 'mismatch at $key',
      );
    }
  });
}
