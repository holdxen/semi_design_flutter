// 1:1 replay of `editor/common/languages/supports.ts`.
// Truth: `tool/ts2dart/_batch418_truth.cjs` -> `batch418_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/encodedTokenAttributes.dart'
    show MetadataConsts, StandardTokenType;
import '../lib/src/monaco/editor/common/languages/supports.dart';
import '../lib/src/monaco/editor/common/tokens/lineTokens.dart'
    show ILanguageIdCodec, LineTokens;

Map<String, dynamic> _map(dynamic v) => (v as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root = _map(
    jsonDecode(File('tool/ts2dart/batch418_truth.json').readAsStringSync()),
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
  final Map<String, int> _ids;
  _Codec(List<String> ids)
      : _ids = <String, int>{for (int i = 0; i < ids.length; i++) ids[i]: i + 1};

  @override
  int encodeLanguageId(String languageId) => _ids[languageId] ?? 0;

  @override
  String decodeLanguageId(int languageId) =>
      _ids.entries.firstWhere((MapEntry<String, int> e) => e.value == languageId,
          orElse: () => const MapEntry<String, int>('', 0)).key;
}

int _metadata(int languageId, int tokenType) =>
    (languageId & MetadataConsts.languageIdMask) |
    ((tokenType << 8) & MetadataConsts.tokenTypeMask);

LineTokens _tokens(
  String content,
  List<({String text, String languageId, int type})> specs,
  _Codec codec,
) =>
    LineTokens.createFromTextAndMetadata(
      specs
          .map((({String text, String languageId, int type}) s) => (
                text: s.text,
                metadata: _metadata(codec.encodeLanguageId(s.languageId), s.type),
              ))
          .toList(),
      codec,
    );

Map<String, Object?> _scopedJson(ScopedLineTokens s) => <String, Object?>{
      'languageId': s.languageId,
      'firstCharOffset': s.firstCharOffset,
      'lineContent': s.getLineContent(),
      'lineLength': s.getLineLength(),
      'tokenCount': s.getTokenCount(),
      'find': s.findTokenIndexAtOffset(4),
      'types': List<int>.generate(
        s.getTokenCount(),
        (int i) => s.getStandardTokenType(i),
      ),
      // TS truth's fake sliceAndInflate records the three call arguments;
      // the real port uses exactly these to build its slice.
      'slice': <String, Object?>{
        'start': s.firstCharOffset,
        'end': s.firstCharOffset + s.getLineLength(),
        'delta': 0,
      },
    };

void main() {
  final Map<String, dynamic> truth = _truth();

  test('supports scoped line tokens replay TS truth', () {
    final Map<String, Object?> actual = <String, Object?>{};

    actual['ignore-brackets'] = <String, Object?>{
      'values': <Object?>[
        ignoreBracketsInToken(StandardTokenType.other),
        ignoreBracketsInToken(StandardTokenType.comment),
        ignoreBracketsInToken(StandardTokenType.string),
        ignoreBracketsInToken(StandardTokenType.regEx),
      ],
    };

    // middle-b: tokens [0-5 a, 5-8 b, 8-12 a], offset 6.
    {
      final _Codec codec = _Codec(<String>['a', 'b']);
      final LineTokens tokens = _tokens(
        'hello world!',
        <({String text, String languageId, int type})>[
          (text: 'hello', languageId: 'a', type: StandardTokenType.other),
          (text: ' wo', languageId: 'b', type: StandardTokenType.comment),
          (text: 'rld!', languageId: 'a', type: StandardTokenType.string),
        ],
        codec,
      );
      actual['middle-b'] = <String, Object?>{
        'scoped': _scopedJson(createScopedLineTokens(tokens, 6)),
      };
    }

    // first-group: tokens [0-3 x, 3-6 x, 6-10 y], offset 1.
    {
      final _Codec codec = _Codec(<String>['x', 'y']);
      final LineTokens tokens = _tokens(
        'abcdefghij',
        <({String text, String languageId, int type})>[
          (text: 'abc', languageId: 'x', type: StandardTokenType.other),
          (text: 'def', languageId: 'x', type: StandardTokenType.regEx),
          (text: 'ghij', languageId: 'y', type: StandardTokenType.other),
        ],
        codec,
      );
      actual['first-group'] = <String, Object?>{
        'scoped': _scopedJson(createScopedLineTokens(tokens, 1)),
      };
    }

    // last-group: tokens [0-1 p, 1-3 q], offset 2.
    {
      final _Codec codec = _Codec(<String>['p', 'q']);
      final LineTokens tokens = _tokens(
        'abc',
        <({String text, String languageId, int type})>[
          (text: 'a', languageId: 'p', type: StandardTokenType.other),
          (text: 'bc', languageId: 'q', type: StandardTokenType.string),
        ],
        codec,
      );
      actual['last-group'] = <String, Object?>{
        'scoped': _scopedJson(createScopedLineTokens(tokens, 2)),
      };
    }

    for (final String key in truth.keys) {
      expect(
        jsonEncode(actual[key]),
        jsonEncode(truth[key]),
        reason: 'mismatch at $key',
      );
    }
  });
}
