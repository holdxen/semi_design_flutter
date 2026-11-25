// batch290: sparseMultilineTokens.ts truth replay.
// Truth from tool/ts2dart/batch290_truth.json (recursive TS transpile + vm,
// real SparseMultilineTokens with curated + deterministic random edits).
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart'
    show Range;
import 'package:semi_design_flutter/src/monaco/editor/common/tokens/sparseMultilineTokens.dart'
    show
        ITextModelForSparseTokens,
        SparseLineTokens,
        SparseMultilineTokens;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch290_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Object? _norm(Object? v) {
  if (v == null) return null;
  if (v is Map) {
    return v.map<String, Object?>((k, e) => MapEntry<String, Object?>(k as String, _norm(e)));
  }
  if (v is List) return v.map(_norm).toList();
  return v;
}

Range _range(List<dynamic> d) => Range(
      (d[0] as num).toInt(),
      (d[1] as num).toInt(),
      (d[2] as num).toInt(),
      (d[3] as num).toInt(),
    );

Map<String, Object?> _snapshot(SparseMultilineTokens tokens, String label) {
  final List<Object?> probes = <Object?>[];
  for (int line = tokens.startLineNumber - 1;
      line <= tokens.endLineNumber + 1;
      line++) {
    final SparseLineTokens? slt = tokens.getLineTokens(line);
    Object? lines;
    if (slt != null) {
      final List<Object?> arr = <Object?>[];
      for (int i = 0; i < slt.getCount(); i++) {
        arr.add(<Object?>[
          slt.getStartCharacter(i),
          slt.getEndCharacter(i),
          slt.getMetadata(i),
        ]);
      }
      lines = arr;
    }
    probes.add(<String, Object?>{'line': line, 'tokens': lines});
  }
  final Range? range = tokens.getRange();
  return <String, Object?>{
    'label': label,
    'startLineNumber': tokens.startLineNumber,
    'endLineNumber': tokens.endLineNumber,
    'isEmpty': tokens.isEmpty(),
    'str': tokens.toString(),
    'range': range == null
        ? null
        : <String, Object?>{
            'startLineNumber': range.startLineNumber,
            'startColumn': range.startColumn,
            'endLineNumber': range.endLineNumber,
            'endColumn': range.endColumn,
          },
    'probes': probes,
  };
}

class _Model implements ITextModelForSparseTokens {
  @override
  int getLineCount() => 10;

  @override
  int getLineLength(int lineNumber) => 80;
}

void main() {
  final Map<String, dynamic> truth = _truth();
  group('batch290 sparseMultilineTokens truth replay', () {
    for (final dynamic rawCase in truth['cases'] as List<dynamic>) {
      final Map<String, dynamic> c = rawCase as Map<String, dynamic>;
      test(c['name'] as String, () {
        final List<int> initial = (c['tokens'] as List<dynamic>)
            .map((dynamic e) => (e as num).toInt())
            .toList();
        SparseMultilineTokens tokens = SparseMultilineTokens.create(
            (c['startLineNumber'] as num).toInt(),
            Uint32List.fromList(initial));
        final List<dynamic> ops = c['ops'] as List<dynamic>;
        final List<dynamic> results = c['results'] as List<dynamic>;
        int resultIndex = 0;

        for (final dynamic rawOp in ops) {
          final Map<String, dynamic> op = rawOp as Map<String, dynamic>;
          final String kind = op['kind'] as String;
          final String label = op['label'] as String;
          switch (kind) {
            case 'snapshot':
              expect(_snapshot(tokens, label),
                  _norm(results[resultIndex++] as Object?));
              break;
            case 'removeTokens':
              tokens.removeTokens(_range(op['range'] as List<dynamic>));
              expect(_snapshot(tokens, label),
                  _norm(results[resultIndex++] as Object?));
              break;
            case 'applyEdit':
              tokens.applyEdit(_range(op['range'] as List<dynamic>),
                  op['text'] as String);
              expect(_snapshot(tokens, label),
                  _norm(results[resultIndex++] as Object?));
              break;
            case 'acceptEdit':
              tokens.acceptEdit(
                _range(op['range'] as List<dynamic>),
                (op['eolCount'] as num).toInt(),
                (op['firstLineLength'] as num).toInt(),
                (op['lastLineLength'] as num).toInt(),
                (op['firstCharCode'] as num).toInt(),
              );
              expect(_snapshot(tokens, label),
                  _norm(results[resultIndex++] as Object?));
              break;
            case 'split':
              final List<SparseMultilineTokens> parts =
                  tokens.split(_range(op['range'] as List<dynamic>));
              final List<dynamic> expected =
                  (results[resultIndex++] as Map<String, dynamic>)['parts']
                      as List<dynamic>;
              expect(parts.length, expected.length);
              for (int i = 0; i < parts.length; i++) {
                expect(_snapshot(parts[i], '$label#$i'),
                    _norm(expected[i] as Object?));
              }
              break;
            default:
              fail('unknown op $kind');
          }
        }
        expect(resultIndex, results.length);
        // reportIfInvalid must stay side-effect free for in-range data.
        tokens.reportIfInvalid(_Model());
      });
    }
  });
}
