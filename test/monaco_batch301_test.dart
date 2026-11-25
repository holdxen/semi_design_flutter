// batch301: textModelTokens.ts truth replay.
// Truth from tool/ts2dart/batch301_truth.json (recursive TS transpile + vm,
// real tokenization state stores, priority queue and tokenizer facade).
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/position.dart'
    show Position;
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/lineRange.dart'
    show LineRange;
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/offsetRange.dart'
    show OffsetRange;
import 'package:semi_design_flutter/src/monaco/editor/common/languages.dart'
    show EncodedTokenizationResult;
import 'package:semi_design_flutter/src/monaco/editor/common/model/textModelTokens.dart'
    show
      IStateForTokenization,
      ITokenizationSupportForTokenModel,
      ITextModelForTokenModel,
      RangePriorityQueueImpl,
      TokenizationStateStore,
      TokenizerWithStateStoreAndTextModel,
      TrackingTokenizationStateStore,
      findLikelyRelevantLines;
import 'package:semi_design_flutter/src/monaco/editor/common/tokens/contiguousMultilineTokens.dart'
    show ContiguousMultilineTokens;
import 'package:semi_design_flutter/src/monaco/editor/common/tokens/contiguousMultilineTokensBuilder.dart'
    show ContiguousMultilineTokensBuilder;
import 'package:semi_design_flutter/src/monaco/editor/common/tokens/lineTokens.dart'
    show ILanguageIdCodec;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch301_truth.json').readAsStringSync())
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

class S implements IStateForTokenization {
  S(this.id);

  final int id;

  @override
  IStateForTokenization clone() => S(id);

  @override
  bool equals(Object other) => other is S && other.id == id;

  @override
  String toString() => 'S$id';
}

String? _stateJson(Object? state) => state?.toString();

List<Object?> _rangesJson(Iterable<OffsetRange> ranges) => ranges
    .map((r) => <Object?>[r.start, r.endExclusive])
    .toList();

class _Codec implements ILanguageIdCodec {
  @override
  int encodeLanguageId(String languageId) =>
      languageId == 'typescript' ? 2 : 3;

  @override
  String decodeLanguageId(int languageId) => 'lang$languageId';
}

class _Support implements ITokenizationSupportForTokenModel {
  @override
  IStateForTokenization getInitialState() => S(0);

  @override
  EncodedTokenizationResult tokenizeEncoded(
      String text, bool hasEOL, IStateForTokenization state) {
    final int metadata = ((state as S).id + 1) * 0x10000 + 0x100;
    return EncodedTokenizationResult(
        Uint32List.fromList(<int>[0, metadata, text.length, metadata]),
        <Object?>[],
        S(state.id + 1));
  }
}

class _Model implements ITextModelForTokenModel {
  _Model(this.lines);

  final List<String> lines;

  @override
  String getLanguageId() => 'typescript';

  @override
  String getLineContent(int lineNumber) =>
      lineNumber >= 1 && lineNumber <= lines.length
          ? lines[lineNumber - 1]
          : '';

  @override
  int getLineCount() => lines.length;

  @override
  int getLineLength(int lineNumber) => getLineContent(lineNumber).length;

  @override
  int getLineFirstNonWhitespaceColumn(int lineNumber) {
    final String text = getLineContent(lineNumber);
    final int i = text.indexOf(RegExp(r'\S'));
    return i < 0 ? 0 : i + 1;
  }

  @override
  bool isAttachedToEditor() => true;
}

List<Object?> _builderJson(ContiguousMultilineTokensBuilder builder) => builder
    .finalize()
    .map((piece) {
      final List<Object?> lines = <Object?>[];
      for (int n = piece.startLineNumber; n <= piece.endLineNumber; n++) {
        final Object? tokens = piece.getLineTokens(n);
        lines.add(<Object?>[
          n,
          tokens is Uint32List ? tokens.toList() : null,
        ]);
      }
      return <String, Object?>{
        'start': piece.startLineNumber,
        'end': piece.endLineNumber,
        'lines': lines,
      };
    })
    .toList();

void main() {
  final Map<String, dynamic> truth = _truth();
  final Map<String, Map<String, dynamic>> byName =
      <String, Map<String, dynamic>>{};
  for (final dynamic r in truth['results'] as List<dynamic>) {
    final Map<String, dynamic> m = r as Map<String, dynamic>;
    byName[m['name'] as String] = m;
  }

  group('batch301 textModelTokens truth replay', () {
    test('TokenizationStateStore', () {
      final Map<String, dynamic> e = byName['TokenizationStateStore']!;
      final TokenizationStateStore<S> store = TokenizationStateStore<S>();
      final List<bool> changes = <bool>[
        store.setEndState(1, S(1)),
        store.setEndState(2, S(2)),
        store.setEndState(1, S(1)),
        store.setEndState(1, S(9)),
      ];
      final List<Object?> read = <Object?>[
        _stateJson(store.getEndState(1)),
        _stateJson(store.getEndState(2)),
        _stateJson(store.getEndState(3)),
      ];
      store.acceptChange(LineRange(1, 3), 2);
      final List<Object?> after = <Object?>[
        _stateJson(store.getEndState(1)),
        _stateJson(store.getEndState(2)),
        _stateJson(store.getEndState(3)),
        _stateJson(store.getEndState(4)),
      ];
      expect(
        <String, Object?>{
          'name': 'TokenizationStateStore',
          'states': changes,
          'read': read,
          'afterChange': after,
        },
        _norm(e),
      );
    });

    test('RangePriorityQueueImpl', () {
      final Map<String, dynamic> e = byName['RangePriorityQueueImpl']!;
      final RangePriorityQueueImpl q = RangePriorityQueueImpl();
      final List<Object?> ops = <Object?>[];
      q.addRange(OffsetRange(3, 6));
      ops.add(<Object?>[
        'add-3-6',
        _rangesJson(q.getRanges()),
        q.min,
      ]);
      q.addRange(OffsetRange(1, 2));
      ops.add(<Object?>[
        'add-1-2',
        _rangesJson(q.getRanges()),
        q.min,
      ]);
      q.delete(4);
      ops.add(<Object?>[
        'delete-4',
        _rangesJson(q.getRanges()),
        q.min,
      ]);
      q.addRangeAndResize(OffsetRange(2, 5), 4);
      ops.add(<Object?>[
        'resize-2-5-4',
        _rangesJson(q.getRanges()),
        q.min,
      ]);
      final List<Object?> rangesBefore = _rangesJson(q.getRanges());
      final int? minBefore = q.min;
      q.removeMin();
      ops.add(<Object?>[
        'removeMin',
        rangesBefore,
        minBefore,
        _rangesJson(q.getRanges()),
      ]);
      expect(<String, Object?>{
        'name': 'RangePriorityQueueImpl',
        'ops': ops,
        'str': q.toString(),
      }, _norm(e));
    });

    test('TrackingTokenizationStateStore', () {
      final Map<String, dynamic> e =
          byName['TrackingTokenizationStateStore']!;
      final TrackingTokenizationStateStore<S> store =
          TrackingTokenizationStateStore<S>(10);
      Map<String, Object?> snap(String label) => <String, Object?>{
            'label': label,
            'min': store.getFirstInvalidEndStateLineNumber(),
            'minOrMax': store.getFirstInvalidEndStateLineNumberOrMax(),
            'allValid': store.allStatesValid(),
            'ranges': _rangesJson(store.invalidEndStatesLineNumbers),
          };
      final List<Object?> ops = <Object?>[snap('initial')];
      store.setEndState(1, S(1));
      ops.add(snap('set-1'));
      store.setEndState(2, S(2));
      ops.add(snap('set-2'));
      store.setEndState(2, S(2));
      ops.add(snap('set-2-again'));
      store.setEndState(2, S(20));
      ops.add(snap('set-2-changed'));
      final f = store.getFirstInvalidLine(S(0));
      ops.add(<String, Object?>{
        'label': 'start-states',
        'start1': _stateJson(store.getStartState(1, S(0))),
        'start2': _stateJson(store.getStartState(2, S(0))),
        'start3': _stateJson(store.getStartState(3, S(0))),
        'firstInvalid': f == null
            ? null
            : <Object?>[f.lineNumber, _stateJson(f.startState)],
      });
      store.invalidateEndStateRange(LineRange(5, 8));
      ops.add(snap('invalidate-5-7'));
      store.acceptChange(LineRange(3, 6), 2);
      ops.add(snap('accept-change'));
      expect(<String, Object?>{
        'name': 'TrackingTokenizationStateStore',
        'ops': ops,
      }, _norm(e));
    });

    test('findLikelyRelevantLines', () {
      final Map<String, dynamic> e = byName['findLikelyRelevantLines']!;
      final _Model m = _Model(<String>[
        '    ', '  abc', '    def', 'ghi', '  jkl', '      ', 'mno',
      ]);
      final found = findLikelyRelevantLines(m, 5);
      expect(
        <String, Object?>{
          'name': 'findLikelyRelevantLines',
          'likelyRelevantLines': found.likelyRelevantLines,
          'hasInitialState': found.initialState != null,
        },
        _norm(e),
      );
    });

    test('TokenizerWithStateStoreAndTextModel', () {
      final Map<String, dynamic> e =
          byName['TokenizerWithStateStoreAndTextModel']!;
      final _Model m = _Model(<String>['abc', '  def', 'ghi', 'jkl']);
      final TokenizerWithStateStoreAndTextModel<S> tokenizer =
          TokenizerWithStateStoreAndTextModel<S>(4, _Support(), m, _Codec());
      final List<Object?> ops = <Object?>[];
      Map<String, Object?> snap(String label) => <String, Object?>{
            'label': label,
            'states': <Object?>[
              _stateJson(tokenizer.getStartState(1)),
              _stateJson(tokenizer.getStartState(2)),
              _stateJson(tokenizer.getStartState(3)),
              _stateJson(tokenizer.getStartState(4)),
            ],
            'firstInvalid': (() {
              final f = tokenizer.getFirstInvalidLine();
              return f == null
                  ? null
                  : <Object?>[f.lineNumber, _stateJson(f.startState)];
            })(),
            'accurate': <Object?>[
              tokenizer.hasAccurateTokensForLine(1),
              tokenizer.hasAccurateTokensForLine(2),
              tokenizer.hasAccurateTokensForLine(3),
              tokenizer.hasAccurateTokensForLine(4),
            ],
            'cheap': <Object?>[
              tokenizer.isCheapToTokenize(1),
              tokenizer.isCheapToTokenize(2),
              tokenizer.isCheapToTokenize(3),
              tokenizer.isCheapToTokenize(4),
            ],
          };

      ops.add(snap('initial'));
      final ContiguousMultilineTokensBuilder builder =
          ContiguousMultilineTokensBuilder();
      tokenizer.updateTokensUntilLine(builder, 3);
      ops.add(<String, Object?>{
        ...snap('after-update-3'),
        'builder': _builderJson(builder),
      });
      ops.add(<String, Object?>{
        'label': 'insert-type',
        'type': tokenizer.getTokenTypeIfInsertingCharacter(Position(2, 3), 'X'),
      });
      final List<dynamic>? tokensAt = tokenizer.tokenizeLinesAt(2, <String>[
        '  def', 'ABC',
      ]);
      ops.add(<String, Object?>{
        'label': 'tokenize-lines-at',
        'lines': tokensAt!.map((dynamic lt) {
          final int count = (lt as dynamic).getCount() as int;
          final List<Object?> pairs = <Object?>[];
          for (int i = 0; i < count; i++) {
            pairs.add(lt.getEndOffset(i));
            pairs.add(lt.getMetadata(i));
          }
          return <String, Object?>{'count': count, 'pairs': pairs};
        }).toList(),
      });
      final ContiguousMultilineTokensBuilder heuristicBuilder =
          ContiguousMultilineTokensBuilder();
      final heuristic = tokenizer.tokenizeHeuristically(heuristicBuilder, 1, 4);
      ops.add(<String, Object?>{
        ...snap('after-heuristic'),
        'heuristic': <String, Object?>{'heuristicTokens': heuristic.heuristicTokens},
        'builder': _builderJson(heuristicBuilder),
      });
      expect(<String, Object?>{
        'name': 'TokenizerWithStateStoreAndTextModel',
        'ops': ops,
      }, _norm(e));
    });
  });
}
