// 1:1 replay of
//   `editor/common/languages/languageConfiguration.ts` (430 lines).
// Truth: `tool/ts2dart/_batch337_truth.cjs` -> `batch337_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/encodedTokenAttributes.dart'
    show StandardTokenType;
import '../lib/src/monaco/editor/common/languages/languageConfiguration.dart';
import '../lib/src/monaco/editor/common/languages/supports.dart'
    show ScopedLineTokens;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(
  jsonDecode(File('tool/ts2dart/batch337_truth.json').readAsStringSync()),
);

class _FakeScoped implements ScopedLineTokens {
  _FakeScoped(this.count, this.index, this.std);

  final int count;
  final int index;
  final int std;

  @override
  int getTokenCount() => count;

  @override
  int findTokenIndexAtOffset(int offset) => index;

  @override
  int getStandardTokenType(int tokenIndex) => std;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

List<List<Object?>> _dumpMap(
  Map<String, List<StandardAutoClosingPairConditional>> map,
) {
  final List<String> keys = map.keys.toList()..sort();
  return keys.map((String k) => <Object?>[k, map[k]!.length]).toList();
}

void main() {
  test(
    'language configuration pairs, token gating and pair maps replay TS',
    () {
      final plain = StandardAutoClosingPairConditional(
        IAutoClosingPairConditional(open: '(', close: ')'),
      );
      final conditional = StandardAutoClosingPairConditional(
        IAutoClosingPairConditional(
          open: '"',
          close: '"',
          notIn: <String>['string', 'regex'],
        ),
      );
      final withBefore = StandardAutoClosingPairConditional(
        IAutoClosingPairConditional(
          open: '(',
          close: ')',
          beforeText: RegExp(r"[)\]}']"),
        ),
      );
      final neutralAllAlnum = StandardAutoClosingPairConditional(
        IAutoClosingPairConditional(
          open:
              '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
          close: '',
        ),
      );

      final pairs = AutoClosingPairs(<StandardAutoClosingPairConditional>[
        StandardAutoClosingPairConditional(
          IAutoClosingPairConditional(open: '(', close: ')'),
        ),
        StandardAutoClosingPairConditional(
          IAutoClosingPairConditional(open: '[', close: ']'),
        ),
        StandardAutoClosingPairConditional(
          IAutoClosingPairConditional(open: '{{', close: '}}'),
        ),
      ]);

      final actual = <String, Object?>{
        'enumValues': <int>[
          IndentAction.None,
          IndentAction.Indent,
          IndentAction.IndentOutdent,
          IndentAction.Outdent,
        ],
        'neutralPlain': plain.findNeutralCharacter(),
        'neutralAllAlnum': neutralAllAlnum.findNeutralCharacter(),
        'isOK': <String, Object?>{
          'other': <bool>[conditional.isOK(StandardTokenType.other)],
          'comment': <bool>[conditional.isOK(StandardTokenType.comment)],
          'string': <bool>[conditional.isOK(StandardTokenType.string)],
          'regEx': <bool>[conditional.isOK(StandardTokenType.regEx)],
        },
        'plainIsOK': <bool>[
          plain.isOK(StandardTokenType.other),
          plain.isOK(StandardTokenType.comment),
          plain.isOK(StandardTokenType.string),
          plain.isOK(StandardTokenType.regEx),
        ],
        'shouldAutoCloseBefore': <String, Object?>{
          'noBeforeText': plain.shouldAutoCloseBefore('anything'),
          'matches': withBefore.shouldAutoCloseBefore(')'),
          'misses': withBefore.shouldAutoCloseBefore('a'),
          'globalRegexReset': withBefore.shouldAutoCloseBefore(']'),
        },
        'shouldAutoClose': <String, Object?>{
          'emptyLine': conditional.shouldAutoClose(
            _FakeScoped(0, 0, StandardTokenType.string),
            5,
          ),
          'commentToken': conditional.shouldAutoClose(
            _FakeScoped(3, 0, StandardTokenType.comment),
            5,
          ),
          'stringToken': conditional.shouldAutoClose(
            _FakeScoped(3, 0, StandardTokenType.string),
            5,
          ),
        },
        'autoClosingPairs': <String, Object?>{
          'openByStart': _dumpMap(pairs.autoClosingPairsOpenByStart),
          'openByEnd': _dumpMap(pairs.autoClosingPairsOpenByEnd),
          'closeByStart': _dumpMap(pairs.autoClosingPairsCloseByStart),
          'closeByEnd': _dumpMap(pairs.autoClosingPairsCloseByEnd),
          'closeSingleChar': _dumpMap(pairs.autoClosingPairsCloseSingleChar),
        },
      };

      expect(actual, _truth());
    },
  );
}
