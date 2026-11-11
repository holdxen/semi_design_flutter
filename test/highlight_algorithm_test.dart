import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

List<(int, int, bool)> shape(List<HighlightChunk<TextStyle>> chunks) => [
  for (final chunk in chunks) (chunk.start, chunk.end, chunk.highlight),
];

List<String> slices(String source, List<HighlightChunk<TextStyle>> chunks) => [
  for (final chunk in chunks) source.substring(chunk.start, chunk.end),
];

void main() {
  test('upstream baseline covers the whole source in order', () {
    const source = 'aaa do dollar aaa';
    final chunks = findAll<TextStyle>(
      sourceString: source,
      searchWords: const [SemiHighlightWord('do'), SemiHighlightWord('dollar')],
    );
    expect(shape(chunks), [
      (0, 4, false),
      (4, 6, true),
      (6, 7, false),
      (7, 13, true),
      (13, 17, false),
    ]);
    expect(slices(source, chunks), ['aaa ', 'do', ' ', 'dollar', ' aaa']);
  });
  test('no match yields a single non-highlighted chunk', () {
    final chunks = findAll<TextStyle>(
      sourceString: 'aaa',
      searchWords: const [SemiHighlightWord('z')],
    );
    expect(shape(chunks), [(0, 3, false)]);
    expect(
      findAll<TextStyle>(sourceString: '', searchWords: const []),
      isEmpty,
    );
  });
  test('overlapping words merge into one chunk with the widest end', () {
    final chunks = findAll<TextStyle>(
      sourceString: 'aaa do dollar aaa',
      searchWords: const [SemiHighlightWord('do'), SemiHighlightWord('dollar')],
    );
    // 'do' inside 'dollar' overlaps; no nested highlight survives.
    expect(shape(chunks).where((c) => c.$3), [(4, 6, true), (7, 13, true)]);
  });
  test('nested containment merges and keeps the maximum end', () {
    final chunks = findAll<TextStyle>(
      sourceString: 'doing',
      searchWords: const [SemiHighlightWord('doing'), SemiHighlightWord('do')],
    );
    expect(shape(chunks), [(0, 5, true)]);
    final reversed = findAll<TextStyle>(
      sourceString: 'doing',
      searchWords: const [SemiHighlightWord('do'), SemiHighlightWord('doing')],
    );
    expect(shape(reversed), [(0, 5, true)]);
  });
  test(
    'merged styles keep earlier keys and later words override shared keys',
    () {
      final chunks = findAll<TextStyle>(
        sourceString: 'do dollar',
        searchWords: const [
          SemiHighlightWord(
            'do',
            style: TextStyle(color: Color(0xffff0000), height: 3),
          ),
          SemiHighlightWord(
            'dollar',
            style: TextStyle(fontWeight: FontWeight.w200, height: 1),
          ),
        ],
      );
      final highlights = chunks.where((c) => c.highlight).toList();
      expect(shape(highlights), [(0, 2, true), (3, 9, true)]);
      // Unmerged word keeps its own style.
      expect(highlights.first.style!.color, const Color(0xffff0000));
      expect(highlights.first.style!.height, 3);
      // Overlap: prev key (color) survives, shared key (height) goes to the
      // later word, new key (fontWeight) joins.
      final merged = highlights.last.style!;
      expect(merged.color, const Color(0xffff0000));
      expect(merged.height, 1);
      expect(merged.fontWeight, FontWeight.w200);
    },
  );
  test(
    'equal starts merge stably with the later word overriding shared keys',
    () {
      final chunks = findAll<TextStyle>(
        sourceString: 'ab',
        searchWords: const [
          SemiHighlightWord(
            'ab',
            style: TextStyle(color: Color(0xff111111), height: 2),
          ),
          SemiHighlightWord('ab', style: TextStyle(color: Color(0xff222222))),
        ],
      );
      expect(shape(chunks), [(0, 2, true)]);
      expect(chunks.single.style!.color, const Color(0xff222222));
      expect(chunks.single.style!.height, 2);
    },
  );
  test('zero-length matches never produce chunks', () {
    final star = findAll<TextStyle>(
      sourceString: 'aaa',
      searchWords: const [SemiHighlightWord('a*')],
      autoEscape: false,
    );
    expect(shape(star), [(0, 3, true)]);
    final lookahead = findAll<TextStyle>(
      sourceString: 'aa',
      searchWords: const [SemiHighlightWord('(?=a)')],
      autoEscape: false,
    );
    expect(shape(lookahead), [(0, 2, false)]);
    final empty = findAll<TextStyle>(
      sourceString: 'abc',
      searchWords: const [SemiHighlightWord('')],
    );
    expect(shape(empty), [(0, 3, false)]);
  });
  test(
    'caseSensitive switches between global and case-insensitive matching',
    () {
      expect(
        shape(
          findAll<TextStyle>(
            sourceString: 'Semi semi',
            searchWords: const [SemiHighlightWord('semi')],
          ),
        ),
        [(0, 4, true), (4, 5, false), (5, 9, true)],
      );
      expect(
        shape(
          findAll<TextStyle>(
            sourceString: 'Semi semi',
            searchWords: const [SemiHighlightWord('semi')],
            caseSensitive: true,
          ),
        ),
        [(0, 5, false), (5, 9, true)],
      );
    },
  );
  test('autoEscape toggles literal and regex modes', () {
    // Escaped 'do.' matches only the literal 'do.'.
    expect(
      shape(
        findAll<TextStyle>(
          sourceString: 'dox do.',
          searchWords: const [SemiHighlightWord('do.')],
        ),
      ),
      [(0, 4, false), (4, 7, true)],
    );
    // Unescaped 'do.' is a regex and also matches 'dox'.
    expect(
      shape(
        findAll<TextStyle>(
          sourceString: 'dox do.',
          searchWords: const [SemiHighlightWord('do.')],
          autoEscape: false,
        ),
      ),
      [(0, 3, true), (3, 4, false), (4, 7, true)],
    );
  });
  test('empty words are filtered out', () {
    expect(
      shape(
        findAll<TextStyle>(
          sourceString: 'Semi Design',
          searchWords: const [
            SemiHighlightWord(''),
            SemiHighlightWord('Semi'),
            SemiHighlightWord(''),
          ],
        ),
      ),
      [(0, 4, true), (4, 11, false)],
    );
    expect(
      shape(
        findAll<TextStyle>(
          sourceString: 'ab',
          searchWords: const [SemiHighlightWord(''), SemiHighlightWord('')],
        ),
      ),
      [(0, 2, false)],
    );
  });
  test('unicode and emoji offsets slice by UTF-16 code units', () {
    const emoji = 'ab👍cd';
    expect(emoji.length, 6);
    final chunks = findAll<TextStyle>(
      sourceString: emoji,
      searchWords: const [SemiHighlightWord('👍')],
    );
    expect(shape(chunks), [(0, 2, false), (2, 4, true), (4, 6, false)]);
    expect(slices(emoji, chunks)[1], '👍');
    const cjk = '你好世界';
    final cjkChunks = findAll<TextStyle>(
      sourceString: cjk,
      searchWords: const [SemiHighlightWord('好世')],
    );
    expect(shape(cjkChunks), [(0, 1, false), (1, 3, true), (3, 4, false)]);
    expect(slices(cjk, cjkChunks), ['你', '好世', '界']);
    final pair = findAll<TextStyle>(
      sourceString: '😀!😀',
      searchWords: const [SemiHighlightWord('😀')],
    );
    expect(shape(pair), [(0, 2, true), (2, 3, false), (3, 5, true)]);
    // Adjacent matches merge like upstream (next.start <= prev.end).
    final adjacent = findAll<TextStyle>(
      sourceString: '😀😀',
      searchWords: const [SemiHighlightWord('😀')],
    );
    expect(shape(adjacent), [(0, 4, true)]);
    expect(slices('😀😀', adjacent), ['😀😀']);
  });
}
