// batch295: tokenStore.ts truth replay.
// Truth from tool/ts2dart/batch295_truth.json (recursive TS transpile + vm,
// real (2,3)-tree TokenStore with build/update/delete/query sequences).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/model/tokens/treeSitter/tokenStore.dart'
    show
        ITextModelForTokenStore,
        TokenQuality,
        TokenStore,
        TokenUpdate;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch295_truth.json').readAsStringSync())
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

class _Model implements ITextModelForTokenStore {
  _Model(this.length);

  @override
  final int length;

  @override
  int getValueLength() => length;
}

TokenUpdate _update(Map<String, dynamic> d) => TokenUpdate(
      _i(d['startOffsetInclusive']),
      _i(d['length']),
      _i(d['token']),
    );

List<TokenUpdate> _updates(Object? raw) => (raw as List<dynamic>)
    .map((dynamic d) => _update(d as Map<String, dynamic>))
    .toList();

Object? _updateJson(TokenUpdate? t) => t == null
    ? null
    : <String, Object?>{
        'token': t.token,
        'startOffsetInclusive': t.startOffsetInclusive,
        'length': t.length,
      };

void main() {
  final Map<String, dynamic> truth = _truth();
  group('batch295 tokenStore truth replay', () {
    for (final dynamic rawCase in truth['cases'] as List<dynamic>) {
      final Map<String, dynamic> c = rawCase as Map<String, dynamic>;
      test(c['name'] as String, () {
        final TokenStore store = TokenStore(_Model(_i(c['modelLength'])));
        final List<dynamic> ops = c['ops'] as List<dynamic>;
        final List<dynamic> results = c['results'] as List<dynamic>;
        for (int i = 0; i < ops.length; i++) {
          final Map<String, dynamic> op = ops[i] as Map<String, dynamic>;
          final Map<String, dynamic> expected = results[i] as Map<String, dynamic>;
          late Map<String, Object?> actual;
          switch (op['kind'] as String) {
            case 'build':
              store.buildStore(_updates(op['tokens']), _i(op['quality']));
              actual = <String, Object?>{'tree': store.printTree()};
              break;
            case 'update':
              store.update(_i(op['length']), _updates(op['tokens']),
                  _i(op['quality']));
              actual = <String, Object?>{'tree': store.printTree()};
              break;
            case 'delete':
              store.delete(_i(op['length']), _i(op['offset']));
              actual = <String, Object?>{'tree': store.printTree()};
              break;
            case 'getTokenAt':
              actual = <String, Object?>{
                'result': _updateJson(store.getTokenAt(_i(op['offset']))),
              };
              break;
            case 'getTokensInRange':
              actual = <String, Object?>{
                'result': store
                    .getTokensInRange(_i(op['start']), _i(op['end']))
                    .map((t) => _updateJson(t))
                    .toList(),
              };
              break;
            case 'markForRefresh':
              store.markForRefresh(_i(op['start']), _i(op['end']));
              actual = <String, Object?>{'tree': store.printTree()};
              break;
            case 'rangeHasTokens':
              actual = <String, Object?>{
                'result': store.rangeHasTokens(
                    _i(op['start']), _i(op['end']), _i(op['quality'])),
              };
              break;
            case 'rangeNeedsRefresh':
              actual = <String, Object?>{
                'result':
                    store.rangeNeedsRefresh(_i(op['start']), _i(op['end'])),
              };
              break;
            case 'getNeedsRefresh':
              actual = <String, Object?>{
                'result': store.getNeedsRefresh(),
              };
              break;
            case 'deepCopy':
              actual = <String, Object?>{
                'tree': store.printTree(),
                'copy': store.deepCopy().printTree(),
              };
              break;
            case 'snapshot':
              actual = <String, Object?>{
                'tree': store.printTree(),
                'rootLength': store.root.length,
              };
              break;
            default:
              fail('unknown op ${op['kind']}');
          }
          actual['label'] = op['label'];
          expect(actual, _norm(expected));
        }
        store.dispose();
      });
    }
  });
}
