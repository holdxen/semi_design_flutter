// batch292: sparseTokensStore.ts truth replay.
// Truth from tool/ts2dart/batch292_truth.json (recursive TS transpile + vm,
// real SparseTokensStore / SparseMultilineTokens / LineTokens).
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart'
    show Range;
import 'package:semi_design_flutter/src/monaco/editor/common/tokens/lineTokens.dart'
    show ILanguageIdCodec, LineTokens;
import 'package:semi_design_flutter/src/monaco/editor/common/tokens/sparseMultilineTokens.dart'
    show ITextModelForSparseTokens, SparseMultilineTokens;
import 'package:semi_design_flutter/src/monaco/editor/common/tokens/sparseTokensStore.dart'
    show SparseTokensStore;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch292_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Object? _norm(Object? v) {
  if (v == null) return null;
  if (v is Map) {
    return v.map<String, Object?>((k, e) => MapEntry<String, Object?>(k as String, _norm(e)));
  }
  if (v is List) return v.map(_norm).toList();
  return v;
}

int _i(Object? v) => (v as num).toInt();

class _Codec implements ILanguageIdCodec {
  @override
  int encodeLanguageId(String languageId) => 1;

  @override
  String decodeLanguageId(int languageId) => 'plaintext';
}

class _Model implements ITextModelForSparseTokens {
  @override
  int getLineCount() => 40;

  @override
  int getLineLength(int lineNumber) => 200;
}

Range _range(List<dynamic> d) =>
    Range(_i(d[0]), _i(d[1]), _i(d[2]), _i(d[3]));

Map<String, Object?> _rangeJson(Range? r) => r == null
    ? <String, Object?>{}
    : <String, Object?>{
        'startLineNumber': r.startLineNumber,
        'startColumn': r.startColumn,
        'endLineNumber': r.endLineNumber,
        'endColumn': r.endColumn,
      };

SparseMultilineTokens _piece(Map<String, dynamic> d) =>
    SparseMultilineTokens.create(
      _i(d['start']),
      Uint32List.fromList(
          (d['tokens'] as List<dynamic>).map((e) => _i(e)).toList()),
    );

Map<String, Object?> _snapshot(SparseTokensStore store, String label) =>
    <String, Object?>{
      'label': label,
      'isEmpty': store.isEmpty(),
      'isComplete': store.isComplete(),
      'pieces': store.pieces
          .map((p) => <String, Object?>{
                'startLineNumber': p.startLineNumber,
                'endLineNumber': p.endLineNumber,
                'isEmpty': p.isEmpty(),
                'str': p.toString(),
                'range': p.getRange() == null
                    ? null
                    : _rangeJson(p.getRange()),
              })
          .toList(),
    };

Map<String, Object?> _lineTokensJson(LineTokens t, bool identical) {
  final List<Object?> tokens = <Object?>[];
  for (int i = 0; i < t.getCount(); i++) {
    tokens.add(<Object?>[t.getStartOffset(i), t.getEndOffset(i), t.getMetadata(i)]);
  }
  return <String, Object?>{
    'identical': identical,
    'text': t.getLineContent(),
    'count': t.getCount(),
    'tokens': tokens,
  };
}

void main() {
  final Map<String, dynamic> truth = _truth();
  group('batch292 sparseTokensStore truth replay', () {
    for (final dynamic rawCase in truth['cases'] as List<dynamic>) {
      final Map<String, dynamic> c = rawCase as Map<String, dynamic>;
      test(c['name'] as String, () {
        final SparseTokensStore store = SparseTokensStore(_Codec());
        final List<dynamic> ops = c['ops'] as List<dynamic>;
        final List<dynamic> results = c['results'] as List<dynamic>;
        int resultIndex = 0;

        for (final dynamic rawOp in ops) {
          final Map<String, dynamic> op = rawOp as Map<String, dynamic>;
          final String kind = op['kind'] as String;
          final String label = op['label'] as String;
          late Map<String, Object?> snap;
          switch (kind) {
            case 'snapshot':
              snap = _snapshot(store, label);
              break;
            case 'set':
              final List<dynamic>? rawPieces = op['pieces'] as List<dynamic>?;
              store.set(
                rawPieces == null ? null : rawPieces
                    .map((dynamic d) => _piece(d as Map<String, dynamic>))
                    .toList(),
                op['isComplete'] as bool,
                op['withModel'] == true ? _Model() : null,
              );
              snap = _snapshot(store, label);
              break;
            case 'setPartial': {
              final Range returned = store.setPartial(
                _range(op['range'] as List<dynamic>),
                (op['pieces'] as List<dynamic>)
                    .map((dynamic d) => _piece(d as Map<String, dynamic>))
                    .toList(),
              );
              snap = _snapshot(store, label);
              snap['returnedRange'] = _rangeJson(returned);
              break;
            }
            case 'addSparseTokens': {
              final Map<String, dynamic> a = op['a'] as Map<String, dynamic>;
              final List<int> flat = <int>[];
              for (final dynamic pair in a['tokens'] as List<dynamic>) {
                flat.add(_i((pair as List<dynamic>)[0]));
                flat.add(_i(pair[1]));
              }
              final LineTokens input = LineTokens(
                  Uint32List.fromList(flat), a['text'] as String, _Codec());
              final LineTokens out =
                  store.addSparseTokens(_i(op['lineNumber']), input);
              snap = _lineTokensJson(out, identical(out, input));
              snap['label'] = label;
              break;
            }
            case 'acceptEdit':
              store.acceptEdit(
                _range(op['range'] as List<dynamic>),
                _i(op['eolCount']),
                _i(op['firstLineLength']),
                _i(op['lastLineLength']),
                _i(op['firstCharCode']),
              );
              snap = _snapshot(store, label);
              break;
            case 'flush':
              store.flush();
              snap = _snapshot(store, label);
              break;
            default:
              fail('unknown op $kind');
          }
          expect(snap, _norm(results[resultIndex++] as Object?));
        }
        expect(resultIndex, results.length);
      });
    }
  });
}
