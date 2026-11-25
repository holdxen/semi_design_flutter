// 1:1 replay of `editor/common/tokens/tokenWithTextArray.ts`.
// Truth: `tool/ts2dart/_batch419_truth.cjs` -> `batch419_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/core/ranges/offsetRange.dart'
    show OffsetRange;
import '../lib/src/monaco/editor/common/tokens/lineTokens.dart'
    show ILanguageIdCodec, LineTokens;
import '../lib/src/monaco/editor/common/tokens/tokenWithTextArray.dart';

Map<String, dynamic> _map(dynamic v) => (v as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root = _map(
    jsonDecode(File('tool/ts2dart/batch419_truth.json').readAsStringSync()),
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

class _Codec implements ILanguageIdCodec {
  @override
  int encodeLanguageId(String languageId) => 0;

  @override
  String decodeLanguageId(int languageId) => '';
}

List<Object?> _dump(TokenWithTextArray arr) {
  final List<Object?> out = <Object?>[];
  arr.forEach((OffsetRange r, TokenWithTextInfo t) {
    out.add(<String, Object?>{
      'text': t.text,
      'metadata': t.metadata,
      'range': <Object?>[r.start, r.endExclusive],
    });
  });
  return out;
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('token with text array replay TS truth', () {
    final Map<String, Object?> actual = <String, Object?>{};

    final TokenWithTextArrayBuilder builder = TokenWithTextArrayBuilder();
    builder.add('hello', 1);
    builder.add(' ', 2);
    builder.add('world', 3);
    final TokenWithTextArray arr = builder.build();

    actual['builder-forEach'] = <String, Object?>{'items': _dump(arr)};
    actual['map'] = <String, Object?>{
      'items': arr.map((OffsetRange r, TokenWithTextInfo t) =>
          '${r.start}-${r.endExclusive}:${t.text}'),
    };
    actual['slice-middle'] = <String, Object?>{
      'items': _dump(arr.slice(OffsetRange(3, 9))),
    };
    actual['slice-head'] = <String, Object?>{
      'items': _dump(arr.slice(OffsetRange(0, 4))),
    };
    actual['slice-tail'] = <String, Object?>{
      'items': _dump(arr.slice(OffsetRange(7, 11))),
    };
    actual['slice-empty'] = <String, Object?>{
      'items': _dump(arr.slice(OffsetRange(4, 4))),
    };
    actual['slice-outside'] = <String, Object?>{
      'items': _dump(arr.slice(OffsetRange(20, 30))),
    };

    final TokenWithTextArray a = TokenWithTextArray.create(
      <TokenWithTextInfo>[
        TokenWithTextInfo('ab', 10),
        TokenWithTextInfo('c', 11),
      ],
    );
    final TokenWithTextArray b = TokenWithTextArray.create(
      <TokenWithTextInfo>[TokenWithTextInfo('de', 20)],
    );
    actual['append'] = <String, Object?>{'items': _dump(a.append(b))};

    final LineTokens lt = LineTokens.createFromTextAndMetadata(
      <({String text, int metadata})>[
        (text: 'foo', metadata: 5),
        (text: 'bar', metadata: 6),
      ],
      _Codec(),
    );
    final TokenWithTextArray from = TokenWithTextArray.fromLineTokens(lt);
    final LineTokens back = from.toLineTokens(_Codec());
    final List<Object?> backItems = <Object?>[];
    for (int i = 0; i < back.getCount(); i++) {
      backItems.add(<String, Object?>{
        'text': back.getTokenText(i),
        'metadata': back.getMetadata(i),
      });
    }
    actual['roundtrip'] = <String, Object?>{
      'items': _dump(from),
      'back': backItems,
      'text': back.getLineContent(),
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
