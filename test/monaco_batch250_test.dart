// 1:1 replay of `editor/common/viewModel.ts` (448 lines).
//
// `tool/ts2dart/_batch250_truth.cjs` recursively transpiles and executes the
// real TypeScript source (23 modules, no stubs) and records the 6 runtime
// classes:
//  - `Viewport` (| 0 truncation), MinimapLinesRenderingData / ViewLineData /
//    ViewModelDecoration (carriers),
//  - `ViewLineRenderingData` ctor-derived isBasicASCII / containsRTL + statics,
//  - `OverviewRulerDecorationsGroup` compare / equals / equalsArr.
//
// Adaptations replayed: opaque `void = undefined` brand fields omitted; TS
// statics renamed with `static` prefix (Dart forbids static/instance name
// collision); `| 0` -> ToInt32 truncation.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/core/range.dart' as rc;
import '../lib/src/monaco/editor/common/viewModel.dart' as vm;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch250_truth.json').readAsStringSync()));

bool _same(Object? a, Object? b) {
  if (a == null || b == null) return a == b;
  if (a is num && b is num) return a == b;
  if (a is String && b is String) return a == b;
  if (a is bool && b is bool) return a == b;
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      if (!b.containsKey(k) || !_same(a[k], b[k])) return false;
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_same(a[i], b[i])) return false;
    }
    return true;
  }
  return false;
}

Map<String, dynamic> _projViewport(vm.Viewport v) => {
      'top': v.top, 'left': v.left, 'width': v.width, 'height': v.height,
      'brand': null,
    };

Map<String, dynamic> _projMinimap(vm.MinimapLinesRenderingData v) => {
      'tabSize': v.tabSize,
      'data': v.data.map((e) => e).toList(),
    };

Map<String, dynamic> _projViewLineData(vm.ViewLineData v) => {
      'content': v.content,
      'continuesWithWrappedLine': v.continuesWithWrappedLine,
      'minColumn': v.minColumn,
      'maxColumn': v.maxColumn,
      'startVisibleColumn': v.startVisibleColumn,
      'tokens': v.tokens,
      'inlineDecorations': v.inlineDecorations,
      'brand': null,
    };

Map<String, dynamic> _projDecoration(vm.ViewModelDecoration v) => {
      'range': {
        'startLineNumber': v.range.startLineNumber,
        'startColumn': v.range.startColumn,
        'endLineNumber': v.range.endLineNumber,
        'endColumn': v.range.endColumn,
      },
      'options': v.options,
      'brand': null,
    };

vm.OverviewRulerDecorationsGroup _group(dynamic raw) {
  final m = _map(raw);
  return vm.OverviewRulerDecorationsGroup(
      m['color'] as String, m['zIndex'] as int, (m['data'] as List).cast<int>());
}

void main() {
  final truth = _truth();

  group('Viewport', () {
    test('| 0 truncation', () {
      for (final raw in (truth['viewport'] as List)) {
        final c = _map(raw);
        final input = (c['input'] as List).cast<num>();
        final v = vm.Viewport(input[0], input[1], input[2], input[3]);
        expect(_same(_projViewport(v), c['result']), isTrue,
            reason: 'viewport ${c['input']}');
      }
    });
  });

  group('carriers', () {
    test('MinimapLinesRenderingData', () {
      final c = _map(truth['minimapLines']);
      final input = _map(c['input']);
      final v = vm.MinimapLinesRenderingData(
          input['tabSize'] as int, (input['data'] as List).cast<Object?>());
      expect(_same(_projMinimap(v), c['result']), isTrue);
    });

    test('ViewLineData', () {
      final c = _map(truth['viewLineData']);
      final input = _map(c['input']);
      final v = vm.ViewLineData(
        input['content'] as String,
        input['continuesWithWrappedLine'] as bool,
        input['minColumn'] as int,
        input['maxColumn'] as int,
        input['startVisibleColumn'] as int,
        input['tokens'],
        (input['inlineDecorations'] as List).cast<Object?>(),
      );
      expect(_same(_projViewLineData(v), c['result']), isTrue);
    });

    test('ViewModelDecoration', () {
      final c = _map(truth['viewModelDecoration']);
      final input = _map(c['input']);
      final r = (input['range'] as List).cast<int>();
      final v = vm.ViewModelDecoration(
          rc.Range(r[0], r[1], r[2], r[3]), input['options']);
      expect(_same(_projDecoration(v), c['result']), isTrue);
    });
  });

  group('ViewLineRenderingData', () {
    test('ctor derives isBasicASCII / containsRTL', () {
      for (final raw in (truth['viewLineRendering'] as List)) {
        final c = _map(raw);
        final input = _map(c['input']);
        final v = vm.ViewLineRenderingData(
          1, 12, input['content'] as String, false,
          input['mightRTL'] as bool, input['mightASCII'] as bool,
          'TOK', const <Object?>['d1'], 4, 0, 0, true,
        );
        final proj = <String, dynamic>{
          'isBasicASCII': v.isBasicASCII,
          'containsRTL': v.containsRTL,
          'minColumn': v.minColumn,
          'maxColumn': v.maxColumn,
          'content': v.content,
          'continuesWithWrappedLine': v.continuesWithWrappedLine,
          'tokens': v.tokens,
          'inlineDecorations': v.inlineDecorations,
          'tabSize': v.tabSize,
          'startVisibleColumn': v.startVisibleColumn,
          'textDirection': v.textDirection,
          'hasVariableFonts': v.hasVariableFonts,
        };
        expect(_same(proj, c['result']), isTrue, reason: '${c['label']}');
      }
    });

    test('static isBasicASCII / containsRTL', () {
      final statics = _map(truth['viewLineRenderingStatics']);
      for (final raw in (statics['isBasicASCII'] as List)) {
        final c = _map(raw);
        expect(
          vm.ViewLineRenderingData.staticIsBasicASCII(
              c['line'] as String, c['hint'] as bool),
          c['result'],
          reason: 'isBasicASCII ${c['line']} hint=${c['hint']}',
        );
      }
      for (final raw in (statics['containsRTL'] as List)) {
        final c = _map(raw);
        expect(
          vm.ViewLineRenderingData.staticContainsRTL(
              c['line'] as String, c['ascii'] as bool, c['hint'] as bool),
          c['result'],
          reason: 'containsRTL ${c['line']} ascii=${c['ascii']} hint=${c['hint']}',
        );
      }
    });
  });

  group('OverviewRulerDecorationsGroup', () {
    final rg = _map(truth['rulerGroup']);
    final inputs = _map(rg['inputs']);
    vm.OverviewRulerDecorationsGroup byKey(String k) => _group(inputs[k]);

    test('compareByRenderingProps', () {
      for (final raw in (rg['compare'] as List)) {
        final trio = raw as List;
        final result = vm.OverviewRulerDecorationsGroup.compareByRenderingProps(
            byKey(trio[0] as String), byKey(trio[1] as String));
        expect(result, trio[2], reason: 'compare ${trio[0]} vs ${trio[1]}');
      }
    });

    test('equals', () {
      for (final raw in (rg['equals'] as List)) {
        final trio = raw as List;
        final result = vm.OverviewRulerDecorationsGroup.equals(
            byKey(trio[0] as String), byKey(trio[1] as String));
        expect(result, trio[2], reason: 'equals ${trio[0]} vs ${trio[1]}');
      }
    });

    test('equalsArr', () {
      for (final raw in (rg['equalsArr'] as List)) {
        final c = _map(raw);
        final a = (c['a'] as List).map((k) => byKey(k as String)).toList();
        final b = (c['b'] as List).map((k) => byKey(k as String)).toList();
        expect(vm.OverviewRulerDecorationsGroup.equalsArr(a, b), c['result'],
            reason: 'equalsArr ${c['a']} vs ${c['b']}');
      }
    });
  });
}
