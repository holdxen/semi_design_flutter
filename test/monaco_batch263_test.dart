// batch263: bracketSelections.ts truth replay.
// Truth from tool/ts2dart/batch263_truth.json (recursive TS transpile+vm with
// real BracketSelectionRangeProvider and fake bracket-pair models).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/position.dart'
    show Position;
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart'
    show Range;
import 'package:semi_design_flutter/src/monaco/editor/contrib/smartSelect/browser/bracketSelections.dart'
    show
        BracketSelectionRangeProvider,
        IBracketInfo,
        IBracketPairs,
        IBracketSelectionModel,
        IFoundBracket;
import 'package:semi_design_flutter/src/monaco/editor/contrib/smartSelect/browser/wordSelections.dart'
    show SelectionRange;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch263_truth.json').readAsStringSync())
    as Map<String, dynamic>;

int _posKey(dynamic p) => p.lineNumber * 100000 + p.column;

List<int> _rangeOut(dynamic r) => <int>[
  r.startLineNumber as int,
  r.startColumn as int,
  r.endLineNumber as int,
  r.endColumn as int,
];

class _BracketInfo implements IBracketInfo {
  final bool opening;
  final String text;
  final String openingText;

  _BracketInfo(this.opening, this.text, this.openingText);

  @override
  bool get isOpeningBracket => opening;

  @override
  String get bracketText => text;

  @override
  List<IBracketInfo> getOpeningBrackets() => <IBracketInfo>[
        _BracketInfo(true, openingText, openingText),
      ];
}

class _Found implements IFoundBracket {
  @override
  final IBracketInfo bracketInfo;
  @override
  final Range range;

  _Found(this.bracketInfo, this.range);
}

class _Bracket {
  final bool opening;
  final String text;
  final String openingText;
  final Range range;

  _Bracket(this.opening, this.text, this.openingText, this.range);

  _Found found() => _Found(_BracketInfo(opening, text, openingText), range);
}

class _Pairs implements IBracketPairs {
  final List<_Bracket> tokens;

  _Pairs(this.tokens) {
    tokens.sort((a, b) {
      final int ka = _posKey(a.range.getStartPosition());
      final int kb = _posKey(b.range.getStartPosition());
      return ka.compareTo(kb);
    });
  }

  @override
  IFoundBracket? findNextBracket(Position pos) {
    final int k = _posKey(pos);
    for (final _Bracket t in tokens) {
      if (_posKey(t.range.getStartPosition()) >= k) return t.found();
    }
    return null;
  }

  @override
  IFoundBracket? findPrevBracket(Position pos) {
    final int k = _posKey(pos);
    for (int i = tokens.length - 1; i >= 0; i--) {
      if (_posKey(tokens[i].range.getStartPosition()) < k) {
        return tokens[i].found();
      }
    }
    return null;
  }
}

class _Model implements IBracketSelectionModel {
  final List<String> lines;
  @override
  final IBracketPairs bracketPairs;

  _Model(this.lines, List<_Bracket> tokens) : bracketPairs = _Pairs(tokens);

  @override
  int getLineFirstNonWhitespaceColumn(int lineNumber) {
    final String line = lineNumber >= 1 && lineNumber <= lines.length
        ? lines[lineNumber - 1]
        : '';
    final Match? m = RegExp(r'\S').firstMatch(line);
    return m == null ? 0 : m.start + 1;
  }

  @override
  int getLineLastNonWhitespaceColumn(int lineNumber) {
    final String line = lineNumber >= 1 && lineNumber <= lines.length
        ? lines[lineNumber - 1]
        : '';
    final Match? m = RegExp(r'\S.*\S|\S').firstMatch(line);
    return m == null ? 0 : m.start + m.group(0)!.length;
  }
}

void main() {
  final t = _truth();

  test('b263 static round/duration values match truth', () {
    final statics =
        (t['cases'] as List).first['statics'] as Map<String, dynamic>;
    expect(statics['maxDuration'], 30);
    expect(statics['maxRounds'], 2);
    final src = File(
      'lib/src/monaco/editor/contrib/smartSelect/browser/bracketSelections.dart',
    ).readAsStringSync();
    expect(src, contains('static int _maxDuration = 30'));
    expect(src, contains('static const int _maxRounds = 2'));
  });

  for (final raw in t['cases'] as List<dynamic>) {
    final c = raw as Map<String, dynamic>;
    test('b263 ${c['name']}: selection ranges match TS truth', () async {
      final tokens = <_Bracket>[];
      for (final rawToken in c['tokens'] as List<dynamic>) {
        final tk = rawToken as Map<String, dynamic>;
        final r = tk['range'] as List<dynamic>;
        tokens.add(_Bracket(
          tk['opening'] as bool,
          tk['text'] as String,
          tk['openingText'] as String,
          Range(r[0] as int, r[1] as int, r[2] as int, r[3] as int),
        ));
      }
      final model = _Model(
        (c['lines'] as List<dynamic>).cast<String>(),
        tokens,
      );
      final positions = (c['positions'] as List<dynamic>)
          .map((p) => Position(p[0] as int, p[1] as int))
          .toList();

      final buckets =
          await BracketSelectionRangeProvider().provideSelectionRanges(
        model,
        positions,
      );
      final actual = buckets
          .map((bucket) => bucket
              .map((SelectionRange sr) => _rangeOut(sr.range))
              .toList())
          .toList();
      expect(actual, c['output']);
    });
  }
}
