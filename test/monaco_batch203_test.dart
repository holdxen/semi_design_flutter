// Truth replay for batch203:
//   `editor/common/tokens/lineTokens.ts`
//   `editor/common/tokens/contiguousTokensEditing.ts`
//   `editor/common/tokens/contiguousMultilineTokens.ts`
//
// Expectations come from `tool/ts2dart/batch203_truth.json`, produced by
// `tool/ts2dart/_batch203_truth.cjs` (the real transpiled sources executed
// directly; only `errors.ts` is stubbed to observe `onUnexpectedError`).
//
// NOTE: none of the three files has an official unit test of its own; truth
// comes from executing the real source.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/core/ranges/offsetRange.dart'
    show OffsetRange;
import '../lib/src/monaco/editor/common/tokens/contiguousMultilineTokens.dart'
    show ContiguousMultilineTokens;
import '../lib/src/monaco/editor/common/tokens/contiguousTokensEditing.dart'
    show ContiguousTokensEditing, EMPTY_LINE_TOKENS;
import '../lib/src/monaco/editor/common/tokens/lineTokens.dart'
    show ILanguageIdCodec, LineTokens, TokenArray, TokenInfo;

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch203_truth.json').readAsStringSync()));

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

class _Decoder implements ILanguageIdCodec {
  @override
  int encodeLanguageId(String languageId) =>
      languageId == 'plaintext' ? 1 : 2;

  @override
  String decodeLanguageId(int languageId) => languageId == 1
      ? 'plaintext'
      : languageId == 2
          ? 'json'
          : 'lang$languageId';
}

final _Decoder _decoder = _Decoder();

Uint32List _tokens(List<List<int>> pairs) =>
    Uint32List.fromList(<int>[for (final List<int> pair in pairs) ...pair]);

/// Mirrors the harness' `lineOf`: `Uint32Array | ArrayBuffer | null`.
List<int>? _lineOf(Object? value) {
  if (value == null) return null;
  if (value is Uint32List) return value.toList();
  if (value is ByteBuffer) return Uint32List.view(value).toList();
  return null;
}

List<int> _endsOf(LineTokens tokens) =>
    List<int>.generate(tokens.getCount(), tokens.getEndOffset);

List<int> _metasOf(LineTokens tokens) =>
    List<int>.generate(tokens.getCount(), tokens.getMetadata);

List<String> _textsOf(LineTokens tokens) =>
    List<String>.generate(tokens.getCount(), tokens.getTokenText);

void main() {
  final Map<String, dynamic> truth = _truth();

  test('LineTokens: factory, offsets, text, lookup', () {
    final LineTokens tokens = LineTokens.createFromTextAndMetadata(
      <({String text, int metadata})>[
        (text: 'hello', metadata: 0x00000001),
        (text: ' world', metadata: 0x00000002),
      ],
      _decoder,
    );

    final Map<String, dynamic> create = _map(truth['create']);
    expect(
      <String, Object?>{
        'count': tokens.getCount(),
        'textLength': tokens.getTextLength(),
        'ends': <int>[tokens.getEndOffset(0), tokens.getEndOffset(1)],
        'starts': <int>[tokens.getStartOffset(0), tokens.getStartOffset(1)],
        'metas': <int>[tokens.getMetadata(0), tokens.getMetadata(1)],
        'tokenTexts': <String>[tokens.getTokenText(0), tokens.getTokenText(1)],
        'lineContent': tokens.getLineContent(),
        'languageIds': <String>[
          tokens.getLanguageId(0),
          tokens.getLanguageId(1)
        ],
        'standardTypes': <int>[
          tokens.getStandardTokenType(0),
          tokens.getStandardTokenType(1)
        ],
        'foregrounds': <int>[
          tokens.getForeground(0),
          tokens.getForeground(1)
        ],
        'classNames': <String>[tokens.getClassName(0), tokens.getClassName(1)],
        'toString': tokens.toString(),
      },
      _exp(create),
    );

    expect(
      <int>[0, 4, 5, 6, 11].map(tokens.findTokenIndexAtOffset).toList(),
      _exp(truth['findTokenIndexAtOffset']),
    );

    expect(
      <String, Object?>{
        'empty': LineTokens.findIndexInTokensArray(Uint32List(0), 0),
        'oneToken': LineTokens.findIndexInTokensArray(
            Uint32List.fromList(<int>[5, 0]), 3),
        'twoTokens': <int>[0, 3, 5, 6, 11]
            .map((int offset) => LineTokens.findIndexInTokensArray(
                _tokens(<List<int>>[
                  <int>[5, 1],
                  <int>[11, 2]
                ]),
                offset))
            .toList(),
      },
      _exp(truth['findIndexInTokensArray']),
    );

    final Uint32List toConvert = _tokens(<List<int>>[
      <int>[5, 1],
      <int>[11, 2]
    ]);
    LineTokens.convertToEndOffset(toConvert, 20);
    expect(toConvert.toList(), _exp(truth['convertToEndOffset']));

    final LineTokens empty = LineTokens.createEmpty('abc', _decoder);
    expect(
      <String, Object?>{
        'count': empty.getCount(),
        'end': empty.getEndOffset(0),
        'metadata': empty.getMetadata(0),
        'defaultTokenMetadata': LineTokens.defaultTokenMetadata,
        'textLength': empty.getTextLength(),
      },
      _exp(truth['createEmpty']),
    );
  });

  test('LineTokens: slice, withInserted, TokenArray', () {
    final LineTokens tokens = LineTokens.createFromTextAndMetadata(
      <({String text, int metadata})>[
        (text: 'hello', metadata: 0x00000001),
        (text: ' world', metadata: 0x00000002),
      ],
      _decoder,
    );

    final dynamic sliced = tokens.sliceAndInflate(3, 8, 10);
    final Map<String, dynamic> expectedSlice = _map(truth['slice']);
    expect(
      <String, Object?>{
        'count': sliced.getCount(),
        'lineContent': sliced.getLineContent(),
        'ends': <int>[sliced.getEndOffset(0), sliced.getEndOffset(1)],
        'metas': <int>[sliced.getMetadata(0), sliced.getMetadata(1)],
        'tokenTexts': <String>[sliced.getTokenText(0), sliced.getTokenText(1)],
        'findAt': <int>[3, 4, 5, 7, 8]
            .map((int offset) => sliced.findTokenIndexAtOffset(offset))
            .toList(),
        'equalsSelf': sliced.equals(sliced),
        'equalsSource': sliced.equals(tokens),
      },
      _exp(expectedSlice),
    );

    final dynamic zeroCopy = tokens.sliceZeroCopy(OffsetRange(2, 9));
    expect(
      <String, Object?>{
        'lineContent': zeroCopy.getLineContent(),
        'count': zeroCopy.getCount(),
        'ends': zeroCopy.getCount() == 0
            ? <int>[]
            : <int>[zeroCopy.getEndOffset(0), zeroCopy.getEndOffset(1)],
      },
      _exp(truth['sliceZeroCopy']),
    );

    final LineTokens inserted = tokens.withInserted(
      <({int offset, String text, int tokenMetadata})>[
        (offset: 5, text: 'XX', tokenMetadata: 7),
        (offset: 7, text: 'Y', tokenMetadata: 8),
      ],
    );
    expect(
      <String, Object?>{
        'count': inserted.getCount(),
        'lineContent': inserted.getLineContent(),
        'ends': _endsOf(inserted),
        'metas': _metasOf(inserted),
        'texts': _textsOf(inserted),
      },
      _exp(truth['withInserted']),
    );

    final LineTokens noInsert =
        tokens.withInserted(<({int offset, String text, int tokenMetadata})>[]);
    expect(
      <String, Object?>{
        'identity': identical(noInsert, tokens),
        'equalsSource': noInsert.equals(tokens),
      },
      _exp(truth['withInsertedEmpty']),
    );

    final TokenArray tokenArray =
        tokens.getTokensInRange(OffsetRange(2, 9));
    final List<Map<String, Object?>> collected = <Map<String, Object?>>[];
    tokenArray.forEach((OffsetRange range, TokenInfo info) {
      collected.add(<String, Object?>{
        'start': range.start,
        'endExclusive': range.endExclusive,
        'length': info.length,
        'metadata': info.metadata,
      });
    });
    final TokenArray slicedArray = tokenArray.slice(OffsetRange(1, 3));
    final TokenArray appended = tokenArray.append(slicedArray);
    final List<Map<String, Object?>> appendedRanges = <Map<String, Object?>>[];
    appended.forEach((OffsetRange range, TokenInfo info) {
      appendedRanges.add(<String, Object?>{
        'length': info.length,
        'metadata': info.metadata,
      });
    });
    final TokenArray fromLineTokens = TokenArray.fromLineTokens(tokens);
    final List<Map<String, Object?>> fromRanges = <Map<String, Object?>>[];
    fromLineTokens.forEach((OffsetRange range, TokenInfo info) {
      fromRanges.add(<String, Object?>{
        'length': info.length,
        'metadata': info.metadata,
      });
    });

    expect(
      <String, Object?>{
        'collected': collected,
        'sliced': slicedArray
            .map((OffsetRange range, TokenInfo info) => <String, Object?>{
                  'length': info.length,
                  'metadata': info.metadata,
                })
            .toList(),
        'appended': appendedRanges,
        'fromLineTokens': fromRanges,
        'toLineTokensText': appended.toLineTokens('xyz', _decoder).getLineContent(),
      },
      _exp(truth['tokenArray']),
    );
  });

  test('ContiguousTokensEditing: delete / insert / append', () {
    Uint32List base() => _tokens(<List<int>>[
          <int>[3, 1],
          <int>[6, 2]
        ]);

    expect(
      <String, Object?>{
        'insideSingleToken': _lineOf(ContiguousTokensEditing.delete(base(), 1, 2)),
        'acrossTokens': _lineOf(ContiguousTokensEditing.delete(base(), 2, 4)),
        'everything': _lineOf(ContiguousTokensEditing.delete(base(), 0, 6)),
        'noop': _lineOf(ContiguousTokensEditing.delete(base(), 3, 3)),
        'nullInput': _lineOf(ContiguousTokensEditing.delete(null, 0, 2)),
        'fromBeginning': _lineOf(ContiguousTokensEditing.delete(base(), 0, 2)),
        'fromEnd': _lineOf(ContiguousTokensEditing.delete(base(), 4, 6)),
      },
      _exp(truth['editingDelete']),
    );

    expect(
      <String, Object?>{
        'atZero': _lineOf(ContiguousTokensEditing.insert(base(), 0, 2)),
        'atThree': _lineOf(ContiguousTokensEditing.insert(base(), 3, 2)),
        'mid': _lineOf(ContiguousTokensEditing.insert(base(), 4, 2)),
      },
      _exp(truth['editingInsert']),
    );

    expect(
      <String, Object?>{
        'both': _lineOf(ContiguousTokensEditing.append(
          _tokens(<List<int>>[
            <int>[3, 1],
            <int>[5, 2]
          ]),
          _tokens(<List<int>>[
            <int>[2, 3],
            <int>[4, 4]
          ]),
        )),
        'emptyRight': _lineOf(
            ContiguousTokensEditing.append(base(), EMPTY_LINE_TOKENS)),
        'emptyLeft': _lineOf(
            ContiguousTokensEditing.append(EMPTY_LINE_TOKENS, base())),
        'nullLeft': _lineOf(ContiguousTokensEditing.append(null, base())),
        'nullRight': _lineOf(ContiguousTokensEditing.append(base(), null)),
      },
      _exp(truth['editingAppend']),
    );

    expect(
      <String, Object?>{
        'deleteBeginning':
            _lineOf(ContiguousTokensEditing.deleteBeginning(base(), 4)),
        'deleteEnding':
            _lineOf(ContiguousTokensEditing.deleteEnding(base(), 2)),
        'emptyIdentity': identical(
            ContiguousTokensEditing.deleteBeginning(EMPTY_LINE_TOKENS, 1),
            EMPTY_LINE_TOKENS),
      },
      _exp(truth['editingDeleteEnds']),
    );

    expect(EMPTY_LINE_TOKENS.lengthInBytes,
        _exp(truth['emptyLineTokensByteLength']));
  });

  test('ContiguousMultilineTokens: serialize, deserialize, applyEdit', () {
    final ContiguousMultilineTokens block = ContiguousMultilineTokens(
      5,
      <Uint32List>[
        _tokens(<List<int>>[
          <int>[3, 1],
          <int>[6, 2]
        ]),
        _tokens(<List<int>>[
          <int>[4, 3]
        ]),
      ],
    );

    expect(
      <String, Object?>{
        'startLineNumber': block.startLineNumber,
        'endLineNumber': block.endLineNumber,
        'lineRange': <String, Object?>{
          'startLineNumber': block.getLineRange().startLineNumber,
          'endLineNumberExclusive':
              block.getLineRange().endLineNumberExclusive,
        },
        'line1': _lineOf(block.getLineTokens(5)),
        'line2': _lineOf(block.getLineTokens(6)),
        'serializeSize': block.serializeSize(),
      },
      _exp(truth['block']),
    );

    final int size = block.serializeSize();
    final Uint8List destination = Uint8List(size + 8);
    final int endOffset = block.serialize(destination, 0);
    final List<ContiguousMultilineTokens> out = <ContiguousMultilineTokens>[];
    final int next =
        ContiguousMultilineTokens.deserialize(destination, 0, out);
    expect(
      <String, Object?>{
        'endOffset': endOffset,
        'nextOffset': next,
        'count': out.length,
        'startLineNumber': out[0].startLineNumber,
        'line1': _lineOf(out[0].getLineTokens(5)),
        'line2': _lineOf(out[0].getLineTokens(6)),
      },
      _exp(truth['serialize']),
    );

    final ContiguousMultilineTokens edited = ContiguousMultilineTokens(
      5,
      <Uint32List>[
        _tokens(<List<int>>[
          <int>[3, 1],
          <int>[6, 2]
        ]),
        _tokens(<List<int>>[
          <int>[4, 3]
        ]),
        _tokens(<List<int>>[
          <int>[5, 4]
        ]),
      ],
    );
    // delete from line 5 column 2 to line 6 column 2
    edited.applyEdit(Range(5, 2, 6, 2), '');
    expect(
      <String, Object?>{
        'startLineNumber': edited.startLineNumber,
        'endLineNumber': edited.endLineNumber,
        'lines': <Object?>[
          _lineOf(edited.getLineTokens(5)),
          _lineOf(edited.getLineTokens(6)),
        ],
      },
      _exp(truth['applyEditDeleteAcrossLines']),
    );

    final ContiguousMultilineTokens inserted = ContiguousMultilineTokens(
      5,
      <Uint32List>[
        _tokens(<List<int>>[
          <int>[6, 1]
        ]),
      ],
    );
    inserted.applyEdit(Range(5, 4, 5, 5), 'X\nY');
    expect(
      <String, Object?>{
        'startLineNumber': inserted.startLineNumber,
        'endLineNumber': inserted.endLineNumber,
        'lines': <Object?>[
          _lineOf(inserted.getLineTokens(5)),
          _lineOf(inserted.getLineTokens(6)),
        ],
      },
      _exp(truth['applyEditInsertLines']),
    );
  });
}