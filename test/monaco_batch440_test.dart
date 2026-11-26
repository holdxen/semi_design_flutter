// 1:1 replay of
//   `editor/browser/viewParts/marginDecorations/marginDecorations.ts`.
// Truth: `tool/ts2dart/_batch440_truth.cjs` -> `batch440_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/browser/view/renderingContext.dart'
    show RenderingContext;
import '../lib/src/monaco/editor/browser/viewParts/marginDecorations/marginDecorations.dart';
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/viewEventHandler.dart'
    show ViewEventHandler;
import '../lib/src/monaco/editor/common/viewModel.dart'
    show ViewModelDecoration;

Map<String, dynamic> _map(dynamic v) => (v as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root = _map(
    jsonDecode(File('tool/ts2dart/batch440_truth.json').readAsStringSync()),
  );
  final Map<String, dynamic> out = <String, dynamic>{};
  for (final dynamic r in root['results'] as List<dynamic>) {
    final Map raw = r as Map;
    final Map<String, dynamic> value = <String, dynamic>{};
    raw.forEach((Object? k, Object? v) {
      if (k != 'label') value[k as String] = v;
    });
    out[raw['label'] as String] = value;
  }
  return out;
}

class _Context implements IMarginDecorationsViewContext {
  final List<ViewEventHandler> handlers = <ViewEventHandler>[];

  @override
  void addEventHandler(ViewEventHandler h) => handlers.add(h);

  @override
  void removeEventHandler(ViewEventHandler h) => handlers.remove(h);
}

class _DecorationOptions {
  final String? marginClassName;
  final int? zIndex;
  _DecorationOptions(this.marginClassName, this.zIndex);
}

ViewModelDecoration dec(int start, int end, String? cls, int? zIndex) =>
    ViewModelDecoration(
      Range(start, 1, end, 1),
      _DecorationOptions(cls, zIndex),
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

Object _renderCase(
  int start,
  int end,
  List<ViewModelDecoration> decorations,
) {
  final _Context ctx = _Context();
  final MarginViewLineDecorationsOverlay overlay =
      MarginViewLineDecorationsOverlay(ctx);
  final int added = ctx.handlers.length;
  final String before = overlay.render(start, start);
  overlay.prepareRender(_RenderCtx(decorations, start, end));
  final List<String> rendered = <String>[];
  for (int ln = start; ln <= end; ln++) {
    rendered.add(overlay.render(start, ln));
  }
  overlay.dispose();
  return <String, Object>{
    'value': <String, Object>{
      'added': added,
      'before': before,
      'rendered': rendered,
      'removed': ctx.handlers.length,
      'afterDispose': overlay.render(start, start),
    },
  };
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('margin decorations overlay replay TS truth', () {
    final Map<String, Object?> actual = <String, Object?>{};

    actual['construct'] = _renderCase(1, 1, <ViewModelDecoration>[]);
    actual['none'] = _renderCase(1, 3, <ViewModelDecoration>[]);
    actual['single'] = _renderCase(1, 5, <ViewModelDecoration>[
      dec(2, 4, 'foo', null),
    ]);
    actual['dedup'] = _renderCase(1, 6, <ViewModelDecoration>[
      dec(1, 4, 'foo', 0),
      dec(2, 5, 'foo', 1),
    ]);
    actual['classes'] = _renderCase(1, 4, <ViewModelDecoration>[
      dec(1, 2, 'alpha', 2),
      dec(2, 3, 'beta', 3),
    ]);
    actual['no-margin'] = _renderCase(1, 3, <ViewModelDecoration>[
      dec(1, 3, null, 5),
    ]);
    actual['clip'] = _renderCase(1, 3, <ViewModelDecoration>[
      dec(-2, 2, 'clip', 0),
      dec(3, 99, 'clip2', 0),
    ]);
    actual['zindex-order'] = _renderCase(1, 2, <ViewModelDecoration>[
      dec(1, 2, 'zeta', 0),
      dec(1, 2, 'alpha', 9),
    ]);

    {
      final _Context ctx = _Context();
      final MarginViewLineDecorationsOverlay overlay =
          MarginViewLineDecorationsOverlay(ctx);
      actual['events'] = <String, Object?>{
        'value': <String, Object?>{
          'configuration': overlay.onConfigurationChanged(<Object, Object?>{}),
          'decorations': overlay.onDecorationsChanged(<Object, Object?>{}),
          'flushed': overlay.onFlushed(<Object, Object?>{}),
          'linesChanged': overlay.onLinesChanged(<Object, Object?>{}),
          'linesDeleted': overlay.onLinesDeleted(<Object, Object?>{}),
          'linesInserted': overlay.onLinesInserted(<Object, Object?>{}),
          'scrollTrue': overlay.onScrollChanged(<String, Object?>{
            'scrollTopChanged': true,
          }),
          'scrollFalse': overlay.onScrollChanged(<String, Object?>{
            'scrollTopChanged': false,
          }),
          'zones': overlay.onZonesChanged(<Object, Object?>{}),
        },
      };
      overlay.dispose();
    }

    expect(jsonEncode(actual), jsonEncode(truth));
  });
}
