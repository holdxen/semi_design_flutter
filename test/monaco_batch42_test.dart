import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/languages/features/json/tokenization.dart';

/// Token summary helper: (startIndex, scopes) pairs.
List<List<Object>> toks(ILineTokens lt) =>
    lt.tokens.map((t) => <Object>[t.startIndex, t.scopes]).toList();

List<int> parents(JSONState st) {
  final out = <int>[];
  ParentsStack? p = st.parents;
  while (p != null) {
    out.add(p.type);
    p = p.parent;
  }
  return out;
}

void main() {
  group('batch42 / json tokenization 1:1', () {
    test('exported TOKEN_* constants match monaco.d.ts 1:1', () {
      expect(TOKEN_DELIM_OBJECT, 'delimiter.bracket.json');
      expect(TOKEN_DELIM_ARRAY, 'delimiter.array.json');
      expect(TOKEN_DELIM_COLON, 'delimiter.colon.json');
      expect(TOKEN_DELIM_COMMA, 'delimiter.comma.json');
      expect(TOKEN_VALUE_BOOLEAN, 'keyword.json');
      expect(TOKEN_VALUE_NULL, 'keyword.json');
      expect(TOKEN_VALUE_STRING, 'string.value.json');
      expect(TOKEN_VALUE_NUMBER, 'number.json');
      expect(TOKEN_PROPERTY_NAME, 'string.key.json');
      expect(TOKEN_COMMENT_BLOCK, 'comment.block.json');
      expect(TOKEN_COMMENT_LINE, 'comment.line.json');
    });

    test('object_basic: property name vs value + colon/number tokens', () {
      final support = createTokenizationSupport(false);
      final lt = support.tokenize('{"name": "value", "n": 42}',
          support.getInitialState());
      final t = toks(lt);
      expect(t.length, 12);
      expect(t[0], <Object>[0, TOKEN_DELIM_OBJECT]);
      expect(t[1], <Object>[1, TOKEN_PROPERTY_NAME]);
      expect(t[2], <Object>[7, TOKEN_DELIM_COLON]);
      expect(t[4], <Object>[9, TOKEN_VALUE_STRING]);
      expect(t.last, <Object>[25, TOKEN_DELIM_OBJECT]);
      final st = lt.endState as JSONState;
      expect(st.scanError, ScanError.none);
      expect(parents(st), isEmpty);
    });

    test('nested: parents stack carried across lines', () {
      final support = createTokenizationSupport(false);
      IState st = support.getInitialState();
      st = support.tokenize('{', st).endState;
      expect(parents(st as JSONState), <int>[JSONParent.object]);
      st = support.tokenize('  "a": [1, true, null, "x"],', st).endState;
      expect(parents(st as JSONState), <int>[JSONParent.object]);
      st = support.tokenize('  "b": {"c": 3.14e-2}', st).endState;
      expect(parents(st as JSONState), <int>[JSONParent.object]);
      st = support.tokenize('}', st).endState;
      expect(parents(st as JSONState), isEmpty);
    });

    test('array parent makes bare strings value tokens', () {
      final support = createTokenizationSupport(false);
      final lt = support.tokenize('[1, 2, 3]', support.getInitialState());
      expect(toks(lt).length, 9);
      expect(toks(lt)[1], <Object>[1, TOKEN_VALUE_NUMBER]);
      expect(lt.endState, isA<JSONState>());
    });

    test('comments on: line + block comment tokens produced', () {
      final support = createTokenizationSupport(true);
      final lt = support.tokenize('{ // line comment', support.getInitialState());
      final t = toks(lt);
      expect(t.length, 3);
      // index 1 is the space trivia (empty scope); index 2 is the comment.
      expect(t[1], <Object>[1, '']);
      expect(t[2], <Object>[2, TOKEN_COMMENT_LINE]);
      final lt2 = support.tokenize('  /* block */ "a": 1,', lt.endState);
      expect(toks(lt2).any((x) => x[1] == TOKEN_COMMENT_BLOCK), isTrue);
    });

    test('comments off: comment text yields no comment token', () {
      final support = createTokenizationSupport(false);
      final lt = support.tokenize('{ // line comment', support.getInitialState());
      expect(toks(lt).any((x) => x[1] == TOKEN_COMMENT_LINE), isFalse);
    });

    test('multiline string: UnexpectedEndOfString (2) then recovery', () {
      final support = createTokenizationSupport(false);
      final first = support.tokenize('{"a": "line one', support.getInitialState());
      final st = first.endState as JSONState;
      expect(st.scanError, ScanError.unexpectedEndOfString);
      expect(parents(st), <int>[JSONParent.object]);
      final second = support.tokenize('line two"}', st);
      expect((second.endState as JSONState).scanError, ScanError.none);
      expect(second.tokens.isNotEmpty, isTrue);
    });

    test('multiline block comment: UnexpectedEndOfComment (1) then recovery', () {
      final support = createTokenizationSupport(true);
      final first = support.tokenize('/* start comment', support.getInitialState());
      expect((first.endState as JSONState).scanError,
          ScanError.unexpectedEndOfComment);
      final second = support.tokenize(' continued */ {"a":1}', first.endState);
      expect((second.endState as JSONState).scanError, ScanError.none);
    });

    test('keywords case-sensitive: true/false/null share keyword.json', () {
      final support = createTokenizationSupport(false);
      final t = toks(support.tokenize('[true, false, null, TRUE, False]',
          support.getInitialState()));
      // TOKEN_VALUE_BOOLEAN == TOKEN_VALUE_NULL == 'keyword.json', so
      // true/false/null all yield keyword.json (3); TRUE/False are unknown
      // tokens with empty scope (case-sensitive, faithful to TS).
      final keywordCount = t.where((x) => x[1] == 'keyword.json').length;
      expect(keywordCount, 3);
      expect(t[10], <Object>[20, '']); // TRUE
      expect(t[13], <Object>[26, '']); // False
    });

    test('JSONState clone/equals/getStateData/setStateData 1:1', () {
      final s = JSONState(null, ScanError.none, true,
          ParentsStack.push(null, JSONParent.array));
      final c = s.clone();
      expect(c.equals(s), isTrue);
      expect(identical(c, s), isFalse);
      expect(c.lastWasColon, isTrue);
      expect(parents(c), <int>[JSONParent.array]);
      expect(s.getStateData(), isNull);
      final data = JSONState(null, null, false, null);
      s.setStateData(data);
      expect(s.getStateData(), same(data));
      // Different scanError -> not equal.
      final d = JSONState(null, ScanError.invalidCharacter, true, s.parents);
      expect(c.equals(d), isFalse);
      // Non-JSONState -> not equal.
      expect(c.equals(_ForeignState()), isFalse);
    });

    test('ParentsStack.pop/equals semantics 1:1', () {
      expect(ParentsStack.pop(null), isNull);
      final a = ParentsStack.push(null, JSONParent.object);
      expect(ParentsStack.pop(a), isNull);
      expect(ParentsStack.equals(null, null), isTrue);
      expect(ParentsStack.equals(a, null), isFalse);
      expect(ParentsStack.equals(a, ParentsStack.push(null, JSONParent.object)),
          isTrue);
      expect(ParentsStack.equals(a, ParentsStack.push(null, JSONParent.array)),
          isFalse);
    });

    test('empty initial state has null scanError (faithful to TS clone)', () {
      final support = createTokenizationSupport(false);
      final lt = support.tokenize('', support.getInitialState());
      expect(lt.tokens, isEmpty);
      expect((lt.endState as JSONState).scanError, isNull);
    });

    test('offsetDelta shifts all token startIndex 1:1', () {
      final support = createTokenizationSupport(false);
      final a = tokenizeImpl(false, '[1]', JSONState(null, null, false, null));
      final b = tokenizeImpl(false, '[1]', JSONState(null, null, false, null), 100);
      expect(toks(b).map((x) => x[0]).toList(),
          toks(a).map((x) => (x[0] as int) + 100).toList());
    });
  });
}

class _ForeignState implements IState {
  @override
  IState clone() => this;
  @override
  bool equals(IState other) => false;
}
