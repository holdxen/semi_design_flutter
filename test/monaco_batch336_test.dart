// 1:1 replay of
//   `editor/browser/view/dynamicViewOverlay.ts` (15 lines),
//   `editor/common/cursor/cursorContext.ts` (24 lines),
//   `editor/contrib/inlineCompletions/browser/controller/common.ts` (17 lines).
// Truth: `tool/ts2dart/_batch336_truth.cjs` -> `batch336_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/browser/view/dynamicViewOverlay.dart';
import '../lib/src/monaco/editor/browser/view/renderingContext.dart'
    show RenderingContext;
import '../lib/src/monaco/editor/common/coordinatesConverter.dart'
    show ICoordinatesConverter;
import '../lib/src/monaco/editor/common/cursor/cursorContext.dart';
import '../lib/src/monaco/editor/contrib/inlineCompletions/browser/controller/common.dart'
    as inline_common;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(
  jsonDecode(File('tool/ts2dart/batch336_truth.json').readAsStringSync()),
);

class _Overlay extends DynamicViewOverlay {
  int prepared = 0;
  final List<List<int>> rendered = <List<int>>[];

  @override
  void prepareRender(RenderingContext ctx) => prepared++;

  @override
  String render(int startLineNumber, int lineNumber) {
    rendered.add(<int>[startLineNumber, lineNumber]);
    return 'x$lineNumber';
  }
}

class _Model implements ITextModelForCursorContext {}

class _ViewModel implements ICursorSimpleModelForCursorContext {}

class _Config implements CursorConfigurationForCursorContext {}

class _Converter implements ICoordinatesConverter {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  test(
    'dynamic overlay, inline-completions getter and cursor context replay TS',
    () {
      final overlay = _Overlay();
      overlay.prepareRender(_NullRenderingContext());
      overlay.render(1, 2);
      overlay.render(3, 4);

      final beforeGetter = inline_common.getInlineCompletionsController(
        <String, Object?>{},
      );
      inline_common.setInlineCompletionsControllerGetter((Object editor) {
        return editor == 'ed' ? <String, Object?>{'tag': 'ctl'} : null;
      });
      final hit = inline_common.getInlineCompletionsController('ed') as Map?;
      final miss = inline_common.getInlineCompletionsController('other');
      inline_common.setInlineCompletionsControllerGetter(
        (Object editor) => <String, Object?>{'tag': 'replaced'},
      );
      final replaced =
          inline_common.getInlineCompletionsController('anything') as Map?;
      inline_common.setInlineCompletionsControllerGetter(
        (Object editor) => null,
      );
      final nullGetter = inline_common.getInlineCompletionsController('ed');

      final model = _Model();
      final viewModel = _ViewModel();
      final converter = _Converter();
      final config = _Config();
      final context = CursorContext(model, viewModel, converter, config);

      final actual = <String, Object?>{
        'overlay': <String, Object?>{
          'prepared': overlay.prepared,
          'rendered': overlay.rendered,
        },
        'common': <String, Object?>{
          'beforeGetter': beforeGetter,
          'hit': hit?['tag'],
          'miss': miss,
          'replaced': replaced?['tag'],
          'nullGetter': nullGetter,
        },
        'cursorContext': <String, Object?>{
          'modelSame': identical(context.model, model),
          'viewModelSame': identical(context.viewModel, viewModel),
          'converterSame': identical(context.coordinatesConverter, converter),
          'configSame': identical(context.cursorConfig, config),
        },
      };

      expect(actual, _truth());
    },
  );
}

class _NullRenderingContext implements RenderingContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
