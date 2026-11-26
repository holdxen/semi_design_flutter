import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/encodedTokenAttributes.dart'
    show StandardTokenType;
import '../lib/src/monaco/editor/common/languages/supports.dart'
    show ScopedLineTokens;
import '../lib/src/monaco/editor/test/common/modesTestUtils.dart'
    show TokenText, createFakeScopedLineTokens;

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root =
      jsonDecode(File('tool/ts2dart/batch426_truth.json').readAsStringSync())
          as Map<String, dynamic>;
  return <String, dynamic>{
    for (final dynamic r in root['results'] as List<dynamic>)
      (r as Map)['label'] as String: <String, dynamic>{
        for (final MapEntry<Object?, Object?> e
            in (r as Map).cast<Object?, Object?>().entries)
          if (e.key != 'label') e.key as String: e.value,
      },
  };
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('createFakeScopedLineTokens truth replay', () {
    final Map<String, List<TokenText>> cases = <String, List<TokenText>>{
      'single': <TokenText>[
        TokenText('hello', StandardTokenType.other),
      ],
      'mixed': <TokenText>[
        TokenText('const ', StandardTokenType.other),
        TokenText('foo', StandardTokenType.other),
        TokenText(' = ', StandardTokenType.other),
        TokenText('"bar"', StandardTokenType.string),
        TokenText('; // hi', StandardTokenType.comment),
      ],
      'all-types': <TokenText>[
        TokenText('A', StandardTokenType.other),
        TokenText('B', StandardTokenType.comment),
        TokenText('C', StandardTokenType.string),
        TokenText('D', StandardTokenType.regEx),
      ],
      'empty-text': <TokenText>[
        TokenText('', StandardTokenType.other),
        TokenText('x', StandardTokenType.other),
      ],
    };

    final Map<String, Object?> actual = <String, Object?>{};
    for (final MapEntry<String, List<TokenText>> e in cases.entries) {
      final ScopedLineTokens scoped = createFakeScopedLineTokens(e.value);
      final List<Object?> tokens = <Object?>[];
      for (int i = 0; i < scoped.getTokenCount(); i++) {
        tokens.add(<String, Object?>{
          'tokenIndex': i,
          'tokenType': scoped.getStandardTokenType(i),
        });
      }
      actual[e.key] = <String, Object?>{
        'lineContent': scoped.getLineContent(),
        'lineLength': scoped.getLineLength(),
        'languageId': scoped.languageId,
        'tokenCount': scoped.getTokenCount(),
        'tokens': tokens,
      };
    }

    // Compare field-by-field for precise failure reasons.
    for (final String key in cases.keys) {
      final Map<String, dynamic> got = (actual[key] as Map).cast<String, dynamic>();
      final Map<String, dynamic> exp = truth[key]!;
      for (final String field in exp.keys) {
        expect(jsonEncode(got[field]), jsonEncode(exp[field]),
            reason: '$key.$field');
      }
    }
  });
}

