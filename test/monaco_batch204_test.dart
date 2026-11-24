// Truth replay for batch204:
//   `editor/common/tokens/contiguousMultilineTokensBuilder.ts`
//   `editor/common/tokens/contiguousTokensStore.ts`
//
// Expectations come from `tool/ts2dart/batch204_truth.json`, produced by
// `tool/ts2dart/_batch204_truth.cjs` (the real transpiled sources; only
// `errors.ts` is stubbed). The `unexpected` entry of the truth captures
// `onUnexpectedError` warnings caused by the harness passing line texts whose
// length differs from the stored token end offsets, so it is not asserted.
//
// NOTE: neither file has an official unit test of its own; truth comes from
// executing the real source.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/tokens/contiguousMultilineTokens.dart'
    show ContiguousMultilineTokens;
import '../lib/src/monaco/editor/common/tokens/contiguousMultilineTokensBuilder.dart'
    show ContiguousMultilineTokensBuilder;
import '../lib/src/monaco/editor/common/tokens/contiguousTokensStore.dart'
    show ContiguousTokensStore;
import '../lib/src/monaco/editor/common/tokens/lineTokens.dart'
    show ILanguageIdCodec, ITextModel, LineTokens, ITokenizationTextModelPart;

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch204_truth.json').readAsStringSync()));

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

class _Decoder implements ILanguageIdCodec {
  @override
  int encodeLanguageId(String languageId) =>
      languageId == 'plaintext' ? 1 : (languageId == 'json' ? 2 : 3);

  @override
  String decodeLanguageId(int languageId) => languageId == 1
      ? 'plaintext'
      : (languageId == 2 ? 'json' : 'lang$languageId');
}

final _Decoder _decoder = _Decoder();

class _FakeTextModel implements ITextModel {
  _FakeTextModel(this.lengths);

  final List<int> lengths;

  @override
  String getLanguageId() => 'json';

  @override
  int getLineLength(int lineNumber) => lengths[lineNumber - 1];

  @override
  ITokenizationTextModelPart get tokenization =>
      throw UnimplementedError('not used by setMultilineTokens');

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Uint32List _tokens(List<int> values) => Uint32List.fromList(values);

void main() {
  final Map<String, dynamic> truth = _truth();

  test('ContiguousMultilineTokensBuilder: add / finalize / round trip', () {
    final ContiguousMultilineTokensBuilder builder =
        ContiguousMultilineTokensBuilder();
    builder.add(1, _tokens(<int>[3, 1, 6, 2]));
    builder.add(2, _tokens(<int>[5, 3]));
    builder.add(4, _tokens(<int>[2, 4]));

    final List<ContiguousMultilineTokens> blocks = builder.finalize();
    expect(
      blocks
          .map((ContiguousMultilineTokens block) => <String, Object?>{
                'startLineNumber': block.startLineNumber,
                'endLineNumber': block.endLineNumber,
                'line1': block
                    .getLineTokens(block.startLineNumber)
                    ?.let((Object? v) => (v as Uint32List).toList()),
                'lineCount':
                    block.endLineNumber - block.startLineNumber + 1,
              })
          .toList(),
      _exp(truth['builderBlocks']),
    );

    final Uint8List serialized = builder.serialize();
    final List<ContiguousMultilineTokens> deserialized =
        ContiguousMultilineTokensBuilder.deserialize(serialized);
    expect(
      <String, Object?>{
        'byteLength': serialized.length,
        'blocks': deserialized
            .map((ContiguousMultilineTokens block) => <String, Object?>{
                  'startLineNumber': block.startLineNumber,
                  'endLineNumber': block.endLineNumber,
                  'line1': (block.getLineTokens(block.startLineNumber)
                          as Uint32List)
                      .toList(),
                  // JS yields `undefined` past the last line of a block and
                  // Dart lists throw, so the guard carries that difference.
                  'line2': block.startLineNumber + 1 <= block.endLineNumber
                      ? (block.getLineTokens(block.startLineNumber + 1)
                              as Uint32List)
                          .toList()
                      : null,
                })
            .toList(),
        'sizeMatches': serialized.length ==
            deserialized.fold<int>(
                    4,
                    (int sum, ContiguousMultilineTokens block) =>
                        sum + block.serializeSize()),
      },
      _exp(truth['builderRoundTrip']),
    );
  });

  test('ContiguousTokensStore: get / set / equality / flush', () {
    final ContiguousTokensStore store = ContiguousTokensStore(_decoder);
    expect(<String, Object?>{'hasTokens': store.hasTokens},
        _exp(truth['storeInitial']));

    final LineTokens beforeSet = store.getTokens('json', 0, 'abcdef');
    final Map<String, dynamic> expectedDefault =
        _map(truth['storeDefaultTokens']);
    expect(
      <String, Object?>{
        'count': beforeSet.getCount(),
        'end': beforeSet.getEndOffset(0),
        'metadata': beforeSet.getMetadata(0),
        'languageId': beforeSet.getLanguageId(0),
        'hasTokensAfterGet': store.hasTokens,
      },
      _exp(expectedDefault),
    );

    final bool changed1 =
        store.setTokens('json', 0, 6, _tokens(<int>[3, 1, 6, 2]), true);
    final LineTokens afterSet = store.getTokens('json', 0, 'abcdef');
    final bool changedSame =
        store.setTokens('json', 0, 6, _tokens(<int>[3, 1, 6, 2]), true);
    final bool changedDifferent =
        store.setTokens('json', 0, 6, _tokens(<int>[6, 2]), true);
    final LineTokens afterDifferent = store.getTokens('json', 0, 'abcdef');

    expect(
      <String, Object?>{
        'changed1': changed1,
        'count': afterSet.getCount(),
        'ends': <int>[afterSet.getEndOffset(0), afterSet.getEndOffset(1)],
        'metas': <int>[afterSet.getMetadata(0), afterSet.getMetadata(1)],
        'changedSame': changedSame,
        'changedDifferent': changedDifferent,
        'afterDifferentCount': afterDifferent.getCount(),
        'afterDifferentEnd': afterDifferent.getEndOffset(0),
        'hasTokens': store.hasTokens,
      },
      _exp(truth['storeSet']),
    );

    // Empty line text with no tokens is stored as EMPTY_LINE_TOKENS.
    store.setTokens('json', 1, 0, null, false);
    final LineTokens emptyLine = store.getTokens('json', 1, '');
    expect(
      <String, Object?>{
        'count': emptyLine.getCount(),
        'end': emptyLine.getEndOffset(0),
        'languageId': emptyLine.getLanguageId(0),
      },
      _exp(truth['storeEmptyLine']),
    );

    store.flush();
    expect(<String, Object?>{'hasTokens': store.hasTokens},
        _exp(truth['storeFlushed']));
  });

  test('ContiguousTokensStore: acceptEdit', () {
    final ContiguousTokensStore store = ContiguousTokensStore(_decoder);
    store.setTokens('json', 0, 6, _tokens(<int>[3, 1, 6, 2]), false);
    store.setTokens('json', 1, 4, _tokens(<int>[4, 3]), false);
    store.setTokens('json', 2, 5, _tokens(<int>[5, 4]), false);

    // single line delete: 'abcdef' delete [2,4)
    store.acceptEdit(Range(1, 3, 1, 5), 0, 0);
    final LineTokens line0 = store.getTokens('json', 0, 'abef');
    expect(
      <String, Object?>{
        'count': line0.getCount(),
        'ends': <int>[line0.getEndOffset(0), line0.getEndOffset(1)],
        'metas': <int>[line0.getMetadata(0), line0.getMetadata(1)],
      },
      _exp(truth['editSingleLine']),
    );

    // cross line delete: line 1 col 2 .. line 2 col 3
    store.acceptEdit(Range(1, 2, 2, 3), 0, 0);
    final LineTokens merged = store.getTokens('json', 0, 'aef');
    expect(
      <String, Object?>{
        'count': merged.getCount(),
        'ends': <int>[merged.getEndOffset(0), merged.getEndOffset(1)],
        'metas': <int>[merged.getMetadata(0), merged.getMetadata(1)],
      },
      _exp(truth['editAcrossLines']),
    );

    // insert a newline into line 1
    final ContiguousTokensStore store2 = ContiguousTokensStore(_decoder);
    store2.setTokens('json', 0, 6, _tokens(<int>[6, 1]), false);
    store2.acceptEdit(Range(1, 4, 1, 4), 1, 5);
    final LineTokens first = store2.getTokens('json', 0, 'abcXYdef');
    final LineTokens second = store2.getTokens('json', 1, 'Ydef');
    expect(
      <String, Object?>{
        'firstCount': first.getCount(),
        'firstEnd': first.getEndOffset(0),
        'secondCount': second.getCount(),
        'secondEnd': second.getEndOffset(second.getCount() - 1),
        'secondLanguage': second.getLanguageId(0),
      },
      _exp(truth['editInsertLines']),
    );
  });

  test('ContiguousTokensStore: setMultilineTokens', () {
    final ContiguousTokensStore store = ContiguousTokensStore(_decoder);
    final _FakeTextModel model =
        _FakeTextModel(<int>[6, 4, 5]);
    final ContiguousMultilineTokensBuilder blocks =
        ContiguousMultilineTokensBuilder();
    blocks.add(1, _tokens(<int>[3, 1, 6, 2]));
    blocks.add(2, _tokens(<int>[4, 3]));
    blocks.add(3, _tokens(<int>[5, 4]));

    final ({List<({int fromLineNumber, int toLineNumber})> changes}) first =
        store.setMultilineTokens(blocks.finalize(), model);
    final ({List<({int fromLineNumber, int toLineNumber})> changes}) second =
        store.setMultilineTokens(blocks.finalize(), model);

    List<Map<String, Object?>> changesToJson(
            List<({int fromLineNumber, int toLineNumber})> changes) =>
        changes
            .map((({int fromLineNumber, int toLineNumber}) change) =>
                <String, Object?>{
                  'fromLineNumber': change.fromLineNumber,
                  'toLineNumber': change.toLineNumber,
                })
            .toList();

    expect(
      <String, Object?>{
        'first': changesToJson(first.changes),
        'second': changesToJson(second.changes),
        'line0Count': store.getTokens('json', 0, 'abcdef').getCount(),
        'line2Count': store.getTokens('json', 2, 'abcde').getCount(),
      },
      _exp(truth['setMultiline']),
    );
  });
}

extension<T> on T {
  R let<R>(R Function(T value) fn) => fn(this);
}