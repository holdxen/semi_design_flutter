// 1:1 replay of the batch254 color subsystem:
//   - editor/common/languages/defaultDocumentColorsComputer.ts
//   - editor/contrib/colorPicker/browser/colorPickerModel.ts
//
// `tool/ts2dart/_batch254_truth.cjs` recursively transpiles and executes the
// real TypeScript modules + Color/HSLA/RGBA/Emitter/Disposable (no stubs) and
// records:
//   * docColors: IColorInformation[] for every upstream source-test content
//     (hex / rgb / rgba / hsl / hsla / CSS4 syntax / edge cases).
//   * picker: ColorPickerModel state trace + Emitter event sequence for a
//     scripted mix of color/presentation/guess/flush operations. Scripts are
//     stored in truth so replay is fully data-driven.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/color.dart';
import '../lib/src/monaco/editor/common/core/position.dart';
import '../lib/src/monaco/editor/contrib/colorPicker/browser/colorPickerModel.dart';
import '../lib/src/monaco/editor/common/languages/defaultDocumentColorsComputer.dart';

Map<String, dynamic> _map(dynamic value) => (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch254_truth.json').readAsStringSync()));

/// Recursive comparison with tolerance for JS/Dart double parity.
bool _same(Object? a, Object? b) {
  if (a == null || b == null) return a == b;
  if (a is num && b is num) return (a - b).abs() < 1e-9;
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

/// Exact copy of upstream TestDocumentModel (source test), Dart edition.
class _TestDocumentModel implements IDocumentColorComputerTarget {
  final String content;
  _TestDocumentModel(this.content);

  @override
  String getValue() => content;

  @override
  IPosition positionAt(int offset) {
    final lines = content.substring(0, offset).split('\n');
    return Position(lines.length, lines.last.length + 1);
  }

  @override
  Iterable<RegExpMatch> findMatches(RegExp regex) => regex.allMatches(content);
}

Map<String, dynamic> _infoOut(IColorInformation info) => {
      'range': [
        info.range.startLineNumber,
        info.range.startColumn,
        info.range.endLineNumber,
        info.range.endColumn,
      ],
      'color': {
        'red': info.color.red,
        'green': info.color.green,
        'blue': info.color.blue,
        'alpha': info.color.alpha,
      },
    };

List<dynamic> _colorOut(Color c) => [c.rgba.r, c.rgba.g, c.rgba.b, c.rgba.a];

Color _colorFrom(dynamic rgba) => Color(RGBA(
      rgba[0], rgba[1], rgba[2], rgba[3],
    ));

/// JS `presentation` getter returns undefined when index is out of range (the
/// constructor does not clamp). Mirror that as null for truth comparison.
String? _presentationOrNull(ColorPickerModel m) {
  final int i = m.presentationIndex;
  if (i < 0 || i >= m.colorPresentations.length) return null;
  return m.presentation.label;
}

void main() {
  final truth = _truth();

  group('batch254 document colors', () {
    for (final raw in (truth['docColors'] as List)) {
      final c = _map(raw);
      test(c['label'] as String, () {
        final model = _TestDocumentModel(c['content'] as String);
        final infos = computeDefaultDocumentColors(model);
        final actual = infos.map(_infoOut).toList();
        expect(_same(actual, c['infos']), isTrue,
            reason: '${c['label']} ${c['content']}');
      });
    }

    test('unknown-caller guard', () {
      final guard = truth['unknownGuard'] as List;
      expect(computeDefaultDocumentColors(null).length, equals(guard[0]));
      expect(computeDefaultDocumentColors(Object()).length, equals(guard[1]));
      expect(
          computeDefaultDocumentColors(<String, dynamic>{
            'getValue': 1,
            'positionAt': 1,
          }).length,
          equals(guard[2]));
    });
  });

  group('batch254 colorPickerModel', () {
    for (final raw in (truth['picker'] as List)) {
      final c = _map(raw);
      test(c['label'] as String, () {
        final init = _map(c['initial']);
        final color = _colorFrom(init['original']);
        final initialLabels = _initialPresentationLabels(c['label'] as String);
        final model = ColorPickerModel(
          color,
          initialLabels.map(IColorPresentation.new).toList(),
          init['index'] as int,
        );
        final events = <List<dynamic>>[];
        final d1 = model.onColorFlushed((col) => events.add(['flushed', _colorOut(col)]));
        final d2 = model.onDidChangeColor((col) => events.add(['color', _colorOut(col)]));
        final d3 = model.onDidChangePresentation((p) => events.add(['presentation', p.label]));

        // initial state (JS constructor does not clamp index; mirror via null)
        expect(_same(_colorOut(model.color), init['color']), isTrue,
            reason: '${c['label']} initial color');
        expect(_presentationOrNull(model), equals(init['presentation']),
            reason: '${c['label']} initial presentation');
        expect(model.presentationIndex, equals(init['index']));

        final trace = <Map<String, dynamic>>[];
        for (final stepRaw in (c['script'] as List)) {
          final step = _map(stepRaw);
          final op = step['op'] as String;
          switch (op) {
            case 'setColor':
            case 'setColorSame':
              model.color = _colorFrom(step['rgba']);
              break;
            case 'setPresentations':
              model.colorPresentations = (step['presentations'] as List)
                  .map((e) => IColorPresentation(e as String))
                  .toList();
              break;
            case 'selectNext':
              model.selectNextColorPresentation();
              break;
            case 'guess':
              model.guessColorPresentation(
                _colorFrom(step['rgba']),
                step['originalText'] as String,
              );
              break;
            case 'flush':
              model.flushColor();
              break;
            default:
              throw StateError('unknown op $op');
          }
          trace.add({
            'op': op,
            'color': _colorOut(model.color),
            'presentation': _presentationOrNull(model),
            'index': model.presentationIndex,
          });
        }

        expect(_same(trace, c['trace']), isTrue,
            reason: '${c['label']} trace');
        expect(_same(events, c['events']), isTrue,
            reason: '${c['label']} events');

        final finalRaw = _map(c['final']);
        expect(_same(_colorOut(model.color), finalRaw['color']), isTrue,
            reason: '${c['label']} final color');
        expect(_presentationOrNull(model), equals(finalRaw['presentation']),
            reason: '${c['label']} final presentation');
        expect(model.presentationIndex, equals(finalRaw['index']));

        d1.dispose();
        d2.dispose();
        d3.dispose();
        model.dispose();
      });
    }
  });
}

/// Initial presentation labels, mirroring the harness pickerCase definitions.
List<String> _initialPresentationLabels(String label) {
  switch (label) {
    case 'basic-state':
      return ['#FF0000', 'rgb(255,0,0)', 'hsl(0,100%,50%)'];
    case 'set-color-change':
    case 'set-color-same-no-event':
    case 'presentation-out-of-range-reset':
      return ['hex', 'rgb'];
    case 'select-next-wrap':
      return ['a', 'b', 'c'];
    case 'guess-exact-label':
      return ['#ff0000', 'rgb(255,0,0)'];
    case 'guess-prefix-fallback':
      return ['rgb(1,2,3)', 'hsl(1,2,3)', 'hex'];
    case 'guess-no-match':
      return ['rgb', 'hsl'];
    case 'flush-only':
      return ['a', 'b'];
    case 'mixed':
      return ['a', 'b', 'c'];
    default:
      throw StateError('unknown picker label $label');
  }
}
