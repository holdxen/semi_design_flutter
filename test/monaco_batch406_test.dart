// 1:1 replay of
//   `editor/browser/viewParts/linesDecorations/linesDecorations.ts`.
// Truth: `tool/ts2dart/_batch406_truth.cjs` -> `batch406_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/browser/view/renderingContext.dart'
    show RenderingContext;
import '../lib/src/monaco/editor/browser/viewParts/linesDecorations/linesDecorations.dart';
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
    jsonDecode(File('tool/ts2dart/batch406_truth.json').readAsStringSync()),
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

class _LayoutInfo {
  final int decorationsLeft, decorationsWidth;
  _LayoutInfo(this.decorationsLeft, this.decorationsWidth);
}

class _Config implements ILinesDecorationsConfiguration {
  _LayoutInfo layoutInfo;
  _Config(this.layoutInfo);

  @override
  ILinesDecorationsEditorOptions get options => _Options(this);
}

class _Options implements ILinesDecorationsEditorOptions {
  final _Config config;
  _Options(this.config);

  @override
  Object? get(Object id) => id == EditorOption.layoutInfo
      ? config.layoutInfo
      : null;
}

class _Context implements ILinesDecorationsViewContext {
  @override
  _Config configuration;
  final List<ViewEventHandler> handlers = <ViewEventHandler>[];

  _Context(int left, int width)
      : configuration = _Config(_LayoutInfo(left, width));

  @override
  void addEventHandler(ViewEventHandler h) => handlers.add(h);

  @override
  void removeEventHandler(ViewEventHandler h) => handlers.remove(h);
}

class _DecorationOptions {
  final String? linesDecorationsClassName;
  final String? firstLineDecorationClassName;
  final String? linesDecorationsTooltip;
  final int? zIndex;
  _DecorationOptions(this.linesDecorationsClassName,
      this.firstLineDecorationClassName, this.linesDecorationsTooltip,
      this.zIndex);
}

ViewModelDecoration decoration(int start, int end, String? cls, String? tip,
        [int? zIndex]) =>
    ViewModelDecoration(
      Range(start, 1, end, 1),
      _DecorationOptions(cls, null, tip, zIndex),
    );

ViewModelDecoration firstLineDecoration(
        int start, int end, String? cls, String? tip, [int? zIndex]) =>
    ViewModelDecoration(
      Range(start, 1, end, 1),
      _DecorationOptions(null, cls, tip, zIndex),
    );

class _RenderCtx implements RenderingContext {
  final List<ViewModelDecoration> decorations;
  final int start, end;
  _RenderCtx(this.decorations, this.start, this.end);

  @override
  List<ViewModelDecoration> getDecorationsInViewport() => decorations;

  @override
  Range get visibleRange => Range(start, 1, end, 1);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Object? _renderCase(
  Map<String, dynamic> raw, {
  required List<ViewModelDecoration> decorations,
}) {
  final _Context ctx =
      _Context(raw['left'] as int? ?? 0, raw['width'] as int? ?? 0);
  final LinesDecorationsOverlay overlay = LinesDecorationsOverlay(ctx);
  final int start = raw['start'] as int? ?? 1;
  final int end = raw['end'] as int? ?? 1;
  overlay.prepareRender(_RenderCtx(decorations, start, end));
  final List<Object?> rendered = <Object?>[];
  for (int ln = start; ln <= end; ln++) {
    rendered.add(overlay.render(start, ln));
  }
  overlay.dispose();
  return <String, Object?>{'rendered': rendered};
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('lines decorations overlay replay TS truth', () {
    final Map<String, Object?> actual = <String, Object?>{};

    actual['none'] = _renderCase(<String, dynamic>{
      'start': 1,
      'end': 3,
    }, decorations: <ViewModelDecoration>[]);

    actual['dedup'] = _renderCase(<String, dynamic>{
      'left': 100,
      'width': 20,
      'start': 1,
      'end': 6,
    }, decorations: <ViewModelDecoration>[
      decoration(1, 4, 'foo', null, 0),
      decoration(2, 5, 'foo', null, 0),
    ]);

    actual['mixed'] = _renderCase(<String, dynamic>{
      'left': 120,
      'width': 30,
      'start': 1,
      'end': 4,
    }, decorations: <ViewModelDecoration>[
      decoration(2, 3, 'zeta', 'Z tip', 5),
      firstLineDecoration(1, 4, 'first', 'F tip', 2),
      decoration(1, 1, 'alpha', null),
    ]);

    actual['clip'] = _renderCase(<String, dynamic>{
      'left': 0,
      'width': 10,
      'start': 1,
      'end': 3,
    }, decorations: <ViewModelDecoration>[
      decoration(-2, 2, 'clip', null, 0),
      decoration(3, 99, 'clip2', null, 0),
    ]);

    // events + config change
    final _Context ectx = _Context(10, 5);
    final LinesDecorationsOverlay overlay = LinesDecorationsOverlay(ectx);
    final Map<String, Object?> events = <String, Object?>{
      'configuration': overlay.onConfigurationChanged(<Object, Object?>{}),
      'decorations': overlay.onDecorationsChanged(<Object, Object?>{}),
      'flushed': overlay.onFlushed(<Object, Object?>{}),
      'linesChanged': overlay.onLinesChanged(<Object, Object?>{}),
      'linesDeleted': overlay.onLinesDeleted(<Object, Object?>{}),
      'linesInserted': overlay.onLinesInserted(<Object, Object?>{}),
      'scrollTop': overlay.onScrollChanged(<Object, Object?>{
        'scrollTopChanged': true,
      }),
      'scrollOther': overlay.onScrollChanged(<Object, Object?>{
        'scrollTopChanged': false,
      }),
      'zones': overlay.onZonesChanged(<Object, Object?>{}),
    };
    ectx.configuration.layoutInfo = _LayoutInfo(77, 33);
    overlay.onConfigurationChanged(<Object, Object?>{});
    overlay.prepareRender(_RenderCtx(<ViewModelDecoration>[
      decoration(1, 1, 'x', null, 0),
    ], 1, 1));
    final String afterConfig = overlay.render(1, 1);
    overlay.dispose();
    actual['events'] = <String, Object?>{
      'data': events,
      'afterConfig': afterConfig,
      'handlers': ectx.handlers.length,
    };

    // before prepare
    final _Context bctx = _Context(1, 1);
    final LinesDecorationsOverlay before = LinesDecorationsOverlay(bctx);
    final String beforeValue = before.render(1, 1);
    before.dispose();
    actual['before-prepare'] = <String, Object?>{
      'value': beforeValue,
      'handlers': bctx.handlers.length,
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
