// 1:1 replay of `editor/common/model/indentationGuesser.ts` (221 lines).
//
// Truth: `tool/ts2dart/_batch325_truth.cjs` -> `batch325_truth.json`, produced
// by running the real function against a line-array buffer (including a line
// longer than 65536 chars to exercise the `getLineCharCode` path and a 10001-line
// buffer to exercise the 10k cap).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/model/indentationGuesser.dart' as guesser;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch325_truth.json').readAsStringSync()));

class _Buffer {
  _Buffer(this.lines);

  final List<String> lines;

  int charCodeCalls = 0;

  int getLineCount() => lines.length;

  int getLineLength(int n) => lines[n - 1].length;

  String getLineContent(int n) => lines[n - 1];

  int getLineCharCode(int n, int i) {
    charCodeCalls++;
    return lines[n - 1].codeUnitAt(i);
  }
}

String _sp(int n) => ' ' * n;

void main() {
  final truth = _truth();

  Map<String, List<Object>> cases() => <String, List<Object>>{
        'empty': <Object>[[], 4, true],
        'blankLines': <Object>[
          <String>['', '   ', '\t'],
          4,
          true
        ],
        'singleLine': <Object>[
          <String>['foo'],
          4,
          true
        ],
        'twoSpaces': <Object>[
          <String>[
            'def f():',
            _sp(2) + 'return 1',
            _sp(4) + 'x = 2',
            _sp(2) + 'y = 3',
            _sp(6) + 'z = 4',
          ],
          4,
          true
        ],
        'twoSpacesWithDeeper4': <Object>[
          <String>['a:', _sp(2) + 'b:', _sp(4) + 'c', _sp(2) + 'd'],
          4,
          true
        ],
        'fourSpaces': <Object>[
          <String>[
            'if (x) {',
            _sp(4) + 'y();',
            _sp(8) + 'z();',
            _sp(4) + 'w();',
          ],
          2,
          true
        ],
        'tabs': <Object>[
          <String>['if (x) {', '\ty();', '\t\tz();', '\tw();'],
          4,
          false
        ],
        'mixedSpacesWin': <Object>[
          <String>['a', _sp(2) + 'b', _sp(2) + 'c', '\td', _sp(2) + 'e'],
          4,
          true
        ],
        'mixedTabsWin': <Object>[
          <String>['a', '\tb', '\tc', _sp(2) + 'd'],
          4,
          false
        ],
        'alignmentSkipped': <Object>[
          <String>['const a = 1,', _sp(6) + 'b = 2;', _sp(2) + 'c;'],
          4,
          true
        ],
        'alignmentCountedWhenDefaultMatches': <Object>[
          <String>['const a = 1,', _sp(6) + 'b = 2;'],
          6,
          true
        ],
        'oddTabSizes': <Object>[
          <String>['a', _sp(3) + 'b', _sp(6) + 'c', _sp(3) + 'd'],
          8,
          true
        ],
        'testGuesses': <Object>[
          <String>['a', _sp(5) + 'b', _sp(10) + 'c', _sp(5) + 'd'],
          4,
          true
        ],
        'sixAndEight': <Object>[
          <String>[
            'a',
            _sp(6) + 'b',
            _sp(12) + 'c',
            _sp(6) + 'd',
            _sp(8) + 'e',
          ],
          2,
          true
        ],
        'longLine': <Object>[
          <String>['a', _sp(4) + ('x' * 70000), 'b'],
          4,
          true
        ],
      };

  test('all buffered cases match the real implementation', () {
    final expected = _map(truth['cases']);
    for (final entry in cases().entries) {
      final input = entry.value;
      final buffer = _Buffer((input[0] as List).cast<String>());
      final result = guesser.guessIndentation(
          buffer, input[1] as int, input[2] as bool);
      expect(<String, Object?>{
        'insertSpaces': result.insertSpaces,
        'tabSize': result.tabSize,
      }, _map(expected[entry.key]), reason: entry.key);
      if (entry.key == 'longLine') {
        expect(buffer.charCodeCalls, greaterThan(0),
            reason: 'long lines must go through getLineCharCode');
      } else {
        expect(buffer.charCodeCalls, 0,
            reason: 'short lines use getLineContent().charCodeAt');
      }
    }
  });

  test('only the first 10000 lines are inspected', () {
    final many = <String>['first'];
    for (var i = 0; i < 9999; i++) {
      many.add(_sp(3) + 'x');
    }
    many.add(_sp(7) + 'ignored');
    final result = guesser.guessIndentation(_Buffer(many), 4, true);
    final expected = _map(truth['lineLimit']);
    expect(result.insertSpaces, expected['insertSpaces']);
    expect(result.tabSize, expected['tabSize']);
  });
}
