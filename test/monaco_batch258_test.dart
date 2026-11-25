/// Replay test for batch258 — modelLineProjectionData.ts.
///
/// All inputs and expected values come from `batch258_truth.json`, produced by
/// the real TypeScript module via recursive transpile (zero stubs).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/modelLineProjectionData.dart';

Map<String, dynamic> _loadTruth() {
  final f = File('tool/ts2dart/batch258_truth.json');
  return jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
}

Map<String, dynamic> _inject(String content, int? cursorStops) {
  final m = <String, dynamic>{'content': content};
  if (cursorStops != null) m['cursorStops'] = cursorStops;
  return m;
}

void main() {
  final truth = _loadTruth();

  group('monaco batch258 — modelLineProjectionData replay', () {
    for (final caseData in (truth['cases'] as List)) {
      final c = caseData as Map<String, dynamic>;
      final label = c['label'] as String;

      test(label, () {
        final injectionOffsets = (c['injectionOffsets'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList();
        final injectionsRaw = c['injections'] as List?;
        final injectionOptions = injectionsRaw == null
            ? null
            : injectionsRaw.map((e) {
                final m = e as Map<String, dynamic>;
                return _inject(
                  m['content'] as String,
                  m['cursorStops'] == null
                      ? null
                      : (m['cursorStops'] as num).toInt(),
                );
              }).toList();
        final breakOffsets =
            (c['breakOffsets'] as List).map((e) => (e as num).toInt()).toList();
        final visible = (c['breakOffsetsVisibleColumn'] as List)
            .map((e) => (e as num).toInt())
            .toList();
        final indent = c['wrappedTextIndentLength'] as num;

        final data = ModelLineProjectionData(
          injectionOffsets,
          injectionOptions,
          breakOffsets,
          visible,
          indent,
        );

        for (final raw in (c['checks'] as List)) {
          final check = raw as Map<String, dynamic>;
          final op = check['op'] as String;
          final args = (check['args'] as List)
              .map((e) => (e as num).toInt())
              .toList();
          final expected = check['expected'];

          switch (op) {
            case 'olc':
              expect(data.getOutputLineCount(), expected,
                  reason: '[$label] getOutputLineCount');
              break;
            case 'min':
              expect(data.getMinOutputOffset(args[0]), expected,
                  reason: '[$label] getMinOutputOffset(${args[0]})');
              break;
            case 'len':
              expect(data.getLineLength(args[0]), expected,
                  reason: '[$label] getLineLength(${args[0]})');
              break;
            case 'max':
              expect(data.getMaxOutputOffset(args[0]), expected,
                  reason: '[$label] getMaxOutputOffset(${args[0]})');
              break;
            case 'ti':
              expect(data.translateToInputOffset(args[0], args[1]), expected,
                  reason: '[$label] translateToInputOffset(${args[0]},${args[1]})');
              break;
            case 'to':
              expect(
                  data.translateToOutputPosition(args[0], args[1]).toString(),
                  expected,
                  reason:
                      '[$label] translateToOutputPosition(${args[0]},${args[1]})');
              break;
            case 'norm':
              expect(
                  data
                      .normalizeOutputPosition(args[0], args[1], args[2])
                      .toString(),
                  expected,
                  reason:
                      '[$label] normalizeOutputPosition(${args[0]},${args[1]},${args[2]})');
              break;
            case 'git':
              final it = data.getInjectedText(args[0], args[1]);
              expect(it?.options['content'], expected,
                  reason: '[$label] getInjectedText(${args[0]},${args[1]})');
              break;
            case 'pos':
              final p = OutputPosition(args[0], args[1]).toPosition(args[2]);
              final em = expected as Map<String, dynamic>;
              expect(
                  [p.lineNumber, p.column],
                  [(em['lineNumber'] as num).toInt(), (em['column'] as num).toInt()],
                  reason: '[$label] toPosition(${args[0]},${args[1]},${args[2]})');
              break;
            default:
              fail('[$label] unknown op: $op');
          }
        }
      });
    }
  });
}
