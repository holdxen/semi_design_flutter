// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/find/test/browser/replacePattern.test.ts
// Translated 1:1. The 7 mocha cases become Dart functions carrying the exact
// `deepStrictEqual` / `strictEqual` assertions.
//   - JS `search.exec(target)` -> `_exec` helper converting a Dart `RegExpMatch`
//     into `List<String>?` (group(0)=full match, unmatched groups -> '' to
//     mirror JS `RegExpExecArray` slots used by `buildReplaceString`).
//   - `deepStrictEqual(parseReplaceString(x), new ReplacePattern(pieces))`:
//     `ReplacePattern._state` is private in the port, so equivalence is checked
//     by comparing `hasReplacementPatterns` + `buildReplaceString` output over
//     several probe match arrays that distinguish static/dynamic pieces.
// `ensureNoDisposablesAreLeakedInTestSuite()` is a suite-level harness hook and
// is intentionally omitted here.
// ---------------------------------------------------------------------------

import '../../../../../base/common/search.dart'
    show buildReplaceStringWithCasePreserved;
import '../../browser/replacePattern.dart'
    show
        ReplacePattern,
        ReplacePiece,
        parseReplaceString;

/// 1:1: `search.exec(target)` -> the `RegExpExecArray` consumed by
/// `buildReplaceString` (a list where index 0 is the full match).
List<String>? _exec(RegExp search, String target) {
  final RegExpMatch? m = search.firstMatch(target);
  if (m == null) return null;
  final List<String> groups = <String>[m.group(0) ?? ''];
  for (int i = 1; i <= m.groupCount; i++) {
    groups.add(m.group(i) ?? '');
  }
  return groups;
}

/// Probe match arrays that expose static values, group indices and case ops.
final List<List<String>?> _parseProbes = <List<String>?>[
  null,
  <String>['hello'],
  <String>['func privateFunc(', 'privateFunc'],
  <String>['X', 'aBcDeF', 'gHiJkL', 'mNoPqR', 'sTuVwX'],
];

/// Reproduce `deepStrictEqual(actual, expected)` for `ReplacePattern` via
/// observable behaviour (private `_state` cannot be read directly).
void _assertPatternEq(ReplacePattern actual, ReplacePattern expected, String input) {
  assert(actual.hasReplacementPatterns == expected.hasReplacementPatterns,
      'hasReplacementPatterns for $input');
  for (final List<String>? probe in _parseProbes) {
    assert(actual.buildReplaceString(probe) == expected.buildReplaceString(probe),
        'buildReplaceString($probe) for $input');
  }
}

void _testParse(String input, List<ReplacePiece> expectedPieces) {
  _assertPatternEq(parseReplaceString(input), ReplacePattern(expectedPieces),
      'Parsing $input');
}

void _assertReplace(
    String target, RegExp search, String replaceString, String expected) {
  final ReplacePattern replacePattern = parseReplaceString(replaceString);
  final String actual = replacePattern.buildReplaceString(_exec(search, target));
  assert(actual == expected,
      '$target.replace($search, $replaceString) === $expected (got $actual)');
}

/// 1:1: `test('parse replace string')`
void testParseReplaceString() {
  _testParse('hello', <ReplacePiece>[ReplacePiece.staticValue('hello')]);

  // \t => TAB
  _testParse(r'\thello', <ReplacePiece>[ReplacePiece.staticValue('\thello')]);
  _testParse(r'h\tello', <ReplacePiece>[ReplacePiece.staticValue('h\tello')]);
  _testParse(r'hello\t', <ReplacePiece>[ReplacePiece.staticValue('hello\t')]);

  // \n => LF
  _testParse(r'\nhello', <ReplacePiece>[ReplacePiece.staticValue('\nhello')]);

  // \\t => \t
  _testParse(r'\\thello', <ReplacePiece>[ReplacePiece.staticValue('\\thello')]);
  _testParse(r'h\\tello', <ReplacePiece>[ReplacePiece.staticValue('h\\tello')]);
  _testParse(r'hello\\t', <ReplacePiece>[ReplacePiece.staticValue('hello\\t')]);

  // \\\t => \TAB
  _testParse(r'\\\thello', <ReplacePiece>[ReplacePiece.staticValue('\\\thello')]);

  // \\\\t => \\t
  _testParse(r'\\\\thello', <ReplacePiece>[ReplacePiece.staticValue('\\\\thello')]);

  // \ at the end => no treatment
  _testParse('hello\\', <ReplacePiece>[ReplacePiece.staticValue('hello\\')]);

  // \ with unknown char => no treatment
  _testParse(r'hello\x', <ReplacePiece>[ReplacePiece.staticValue(r'hello\x')]);

  // \ with back reference => no treatment
  _testParse(r'hello\0', <ReplacePiece>[ReplacePiece.staticValue(r'hello\0')]);

  _testParse(r'hello$&', <ReplacePiece>[
    ReplacePiece.staticValue('hello'), ReplacePiece.matchIndex(0)
  ]);
  _testParse(r'hello$0', <ReplacePiece>[
    ReplacePiece.staticValue('hello'), ReplacePiece.matchIndex(0)
  ]);
  _testParse(r'hello$02', <ReplacePiece>[
    ReplacePiece.staticValue('hello'), ReplacePiece.matchIndex(0),
    ReplacePiece.staticValue('2')
  ]);
  _testParse(r'hello$1', <ReplacePiece>[
    ReplacePiece.staticValue('hello'), ReplacePiece.matchIndex(1)
  ]);
  _testParse(r'hello$2', <ReplacePiece>[
    ReplacePiece.staticValue('hello'), ReplacePiece.matchIndex(2)
  ]);
  _testParse(r'hello$9', <ReplacePiece>[
    ReplacePiece.staticValue('hello'), ReplacePiece.matchIndex(9)
  ]);
  _testParse(r'$9hello', <ReplacePiece>[
    ReplacePiece.matchIndex(9), ReplacePiece.staticValue('hello')
  ]);
  _testParse(r'hello$12', <ReplacePiece>[
    ReplacePiece.staticValue('hello'), ReplacePiece.matchIndex(12)
  ]);
  _testParse(r'hello$99', <ReplacePiece>[
    ReplacePiece.staticValue('hello'), ReplacePiece.matchIndex(99)
  ]);
  _testParse(r'hello$99a', <ReplacePiece>[
    ReplacePiece.staticValue('hello'), ReplacePiece.matchIndex(99),
    ReplacePiece.staticValue('a')
  ]);
  _testParse(r'hello$1a', <ReplacePiece>[
    ReplacePiece.staticValue('hello'), ReplacePiece.matchIndex(1),
    ReplacePiece.staticValue('a')
  ]);
  _testParse(r'hello$100', <ReplacePiece>[
    ReplacePiece.staticValue('hello'), ReplacePiece.matchIndex(10),
    ReplacePiece.staticValue('0')
  ]);
  _testParse(r'hello$100a', <ReplacePiece>[
    ReplacePiece.staticValue('hello'), ReplacePiece.matchIndex(10),
    ReplacePiece.staticValue('0a')
  ]);
  _testParse(r'hello$10a0', <ReplacePiece>[
    ReplacePiece.staticValue('hello'), ReplacePiece.matchIndex(10),
    ReplacePiece.staticValue('a0')
  ]);
  _testParse(r'hello$$', <ReplacePiece>[ReplacePiece.staticValue(r'hello$')]);
  _testParse(r'hello$$0', <ReplacePiece>[ReplacePiece.staticValue(r'hello$0')]);
  _testParse(r'hello$`', <ReplacePiece>[ReplacePiece.staticValue(r'hello$`')]);
  _testParse(r"hello$'", <ReplacePiece>[ReplacePiece.staticValue(r"hello$'")]);
}

/// 1:1: `test('parse replace string with case modifiers')`
void testParseReplaceStringWithCaseModifiers() {
  _testParse(r'hello\U$1', <ReplacePiece>[
    ReplacePiece.staticValue('hello'), ReplacePiece.caseOps(1, <String>['U'])
  ]);
  _assertReplace('func privateFunc(', RegExp(r'func (\w+)\('), r'func \U$1(',
      'func PRIVATEFUNC(');

  _testParse(r'hello\u$1', <ReplacePiece>[
    ReplacePiece.staticValue('hello'), ReplacePiece.caseOps(1, <String>['u'])
  ]);
  _assertReplace('func privateFunc(', RegExp(r'func (\w+)\('), r'func \u$1(',
      'func PrivateFunc(');

  _testParse(r'hello\L$1', <ReplacePiece>[
    ReplacePiece.staticValue('hello'), ReplacePiece.caseOps(1, <String>['L'])
  ]);
  _assertReplace('func privateFunc(', RegExp(r'func (\w+)\('), r'func \L$1(',
      'func privatefunc(');

  _testParse(r'hello\l$1', <ReplacePiece>[
    ReplacePiece.staticValue('hello'), ReplacePiece.caseOps(1, <String>['l'])
  ]);
  _assertReplace('func PrivateFunc(', RegExp(r'func (\w+)\('), r'func \l$1(',
      'func privateFunc(');

  _testParse(r'hello$1\u\u\U$4goodbye', <ReplacePiece>[
    ReplacePiece.staticValue('hello'), ReplacePiece.matchIndex(1),
    ReplacePiece.caseOps(4, <String>['u', 'u', 'U']),
    ReplacePiece.staticValue('goodbye')
  ]);
  _assertReplace('hellogooDbye', RegExp(r'hello(\w+)'),
      r'hello\u\u\l\l\U$1', 'helloGOodBYE');
}

/// 1:1: `test('replace has JavaScript semantics')`
void testReplaceHasJavaScriptSemantics() {
  _assertReplace('hi', RegExp(r'hi'), 'hello', 'hello');
  _assertReplace('hi', RegExp(r'hi'), r'\t', '\t');
  _assertReplace('hi', RegExp(r'hi'), r'\n', '\n');
  _assertReplace('hi', RegExp(r'hi'), r'\\t', '\\t');
  _assertReplace('hi', RegExp(r'hi'), r'\\n', '\\n');

  // implicit capture group 0
  _assertReplace('hi', RegExp(r'hi'), r'hello$&', 'hellohi');
  _assertReplace('hi', RegExp(r'hi'), r'hello$0', 'hellohi');
  _assertReplace('hi', RegExp(r'hi'), r'hello$&1', 'hellohi1');
  _assertReplace('hi', RegExp(r'hi'), r'hello$01', 'hellohi1');

  // capture groups have funny semantics in replace strings
  _assertReplace('hi', RegExp(r'(hi)'), r'hello$10', 'hellohi0');
  _assertReplace('hi', RegExp(r'(hi)()()()()()()()()()'), r'hello$10', 'hello');
  _assertReplace('hi', RegExp(r'(hi)'), r'hello$100', 'hellohi00');
  _assertReplace('hi', RegExp(r'(hi)'), r'hello$20', r'hello$20');
}

/// 1:1: `test('get replace string if given text is a complete match')`
void testGetReplaceStringCompleteMatch() {
  _assertReplace('bla', RegExp(r'bla'), 'hello', 'hello');
  _assertReplace('bla', RegExp(r'(bla)'), 'hello', 'hello');
  _assertReplace('bla', RegExp(r'(bla)'), r'hello$0', 'hellobla');

  final RegExp searchRegex = RegExp(
      "let\\s+(\\w+)\\s*=\\s*require\\s*\\(\\s*['\"]([\\w\\.\\-/]+)\\s*['\"]\\s*\\)\\s*");
  _assertReplace("let fs = require('fs')", searchRegex,
      r"import * as $1 from '$2';", "import * as fs from 'fs';");
  _assertReplace("let something = require('fs')", searchRegex,
      r"import * as $1 from '$2';", "import * as something from 'fs';");
  _assertReplace("let something = require('fs')", searchRegex,
      r"import * as $1 from '$1';", "import * as something from 'something';");
  _assertReplace("let something = require('fs')", searchRegex,
      r"import * as $2 from '$1';", "import * as fs from 'something';");
  _assertReplace("let something = require('fs')", searchRegex,
      r"import * as $0 from '$0';",
      "import * as let something = require('fs') from 'let something = require('fs')';");
  _assertReplace("let fs = require('fs')", searchRegex,
      r"import * as $1 from '$2';", "import * as fs from 'fs';");
  _assertReplace('for ()', RegExp(r'for(.*)'), r'cat$1', 'cat ()');

  // issue #18111
  _assertReplace('HRESULT OnAmbientPropertyChange(DISPID   dispid);',
      RegExp(r'\b\s{3}\b'), ' ', ' ');
}

/// 1:1: `test('get replace string if match is sub-string of the text')`
void testGetReplaceStringSubstringMatch() {
  _assertReplace('this is a bla text', RegExp(r'bla'), 'hello', 'hello');
  _assertReplace('this is a bla text', RegExp(r'this(?=.*bla)'), 'that', 'that');
  _assertReplace('this is a bla text', RegExp(r'(th)is(?=.*bla)'), r'$1at', 'that');
  _assertReplace('this is a bla text', RegExp(r'(th)is(?=.*bla)'), r'$1e', 'the');
  _assertReplace('this is a bla text', RegExp(r'(th)is(?=.*bla)'), r'$1ere', 'there');
  _assertReplace('this is a bla text', RegExp(r'(th)is(?=.*bla)'), r'$1', 'th');
  _assertReplace('this is a bla text', RegExp(r'(th)is(?=.*bla)'), r'ma$1', 'math');
  _assertReplace('this is a bla text', RegExp(r'(th)is(?=.*bla)'), r'ma$1s', 'maths');
  _assertReplace('this is a bla text', RegExp(r'(th)is(?=.*bla)'), r'$0', 'this');
  _assertReplace('this is a bla text', RegExp(r'(th)is(?=.*bla)'), r'$0$1', 'thisth');
  _assertReplace('this is a bla text', RegExp(r'bla(?=\stext$)'), 'foo', 'foo');
  _assertReplace('this is a bla text', RegExp(r'b(la)(?=\stext$)'), r'f$1', 'fla');
  _assertReplace('this is a bla text', RegExp(r'b(la)(?=\stext$)'), r'f$0', 'fbla');
  _assertReplace('this is a bla text', RegExp(r'b(la)(?=\stext$)'), r'$0ah', 'blaah');
}

/// 1:1: `test('issue #19740 ... inserts undefined instead of empty string')`
void testIssue19740CaptureGroupUndefined() {
  final ReplacePattern replacePattern = parseReplaceString(r'a{$1}');
  final List<String>? matches = _exec(RegExp(r'a(z)?'), 'abcd');
  assert(replacePattern.buildReplaceString(matches) == 'a{}');
}

void _assertCasePreserved(List<String> target, String replaceString, String expected) {
  assert(buildReplaceStringWithCasePreserved(target, replaceString) == expected,
      'buildReplaceStringWithCasePreserved($target, $replaceString)');
}

/// 1:1: `test('buildReplaceStringWithCasePreserved test')`
void testBuildReplaceStringWithCasePreserved() {
  _assertCasePreserved(<String>['abc'], 'Def', 'def');
  _assertCasePreserved(<String>['Abc'], 'Def', 'Def');
  _assertCasePreserved(<String>['ABC'], 'Def', 'DEF');
  _assertCasePreserved(<String>['abc', 'Abc'], 'Def', 'def');
  _assertCasePreserved(<String>['Abc', 'abc'], 'Def', 'Def');
  _assertCasePreserved(<String>['ABC', 'abc'], 'Def', 'DEF');
  _assertCasePreserved(<String>['aBc', 'abc'], 'Def', 'def');
  _assertCasePreserved(<String>['AbC'], 'Def', 'Def');
  _assertCasePreserved(<String>['aBC'], 'Def', 'def');
  _assertCasePreserved(<String>['aBc'], 'DeF', 'deF');
  _assertCasePreserved(<String>['Foo-Bar'], 'newfoo-newbar', 'Newfoo-Newbar');
  _assertCasePreserved(<String>['Foo-Bar-Abc'], 'newfoo-newbar-newabc', 'Newfoo-Newbar-Newabc');
  _assertCasePreserved(<String>['Foo-Bar-abc'], 'newfoo-newbar', 'Newfoo-newbar');
  _assertCasePreserved(<String>['foo-Bar'], 'newfoo-newbar', 'newfoo-Newbar');
  _assertCasePreserved(<String>['foo-BAR'], 'newfoo-newbar', 'newfoo-NEWBAR');
  _assertCasePreserved(<String>['foO-BAR'], 'NewFoo-NewBar', 'newFoo-NEWBAR');
  _assertCasePreserved(<String>['Foo_Bar'], 'newfoo_newbar', 'Newfoo_Newbar');
  _assertCasePreserved(<String>['Foo_Bar_Abc'], 'newfoo_newbar_newabc', 'Newfoo_Newbar_Newabc');
  _assertCasePreserved(<String>['Foo_Bar_abc'], 'newfoo_newbar', 'Newfoo_newbar');
  _assertCasePreserved(<String>['Foo_Bar-abc'], 'newfoo_newbar-abc', 'Newfoo_newbar-abc');
  _assertCasePreserved(<String>['foo_Bar'], 'newfoo_newbar', 'newfoo_Newbar');
  _assertCasePreserved(<String>['Foo_BAR'], 'newfoo_newbar', 'Newfoo_NEWBAR');
}

void _assertPreserveCase(List<String> target, String replaceString, String expected) {
  final ReplacePattern replacePattern = parseReplaceString(replaceString);
  assert(replacePattern.buildReplaceString(target, true) == expected,
      'preserveCase($target, $replaceString)');
}

/// 1:1: `test('preserve case')`
void testPreserveCase() {
  _assertPreserveCase(<String>['abc'], 'Def', 'def');
  _assertPreserveCase(<String>['Abc'], 'Def', 'Def');
  _assertPreserveCase(<String>['ABC'], 'Def', 'DEF');
  _assertPreserveCase(<String>['abc', 'Abc'], 'Def', 'def');
  _assertPreserveCase(<String>['Abc', 'abc'], 'Def', 'Def');
  _assertPreserveCase(<String>['ABC', 'abc'], 'Def', 'DEF');
  _assertPreserveCase(<String>['aBc', 'abc'], 'Def', 'def');
  _assertPreserveCase(<String>['AbC'], 'Def', 'Def');
  _assertPreserveCase(<String>['aBC'], 'Def', 'def');
  _assertPreserveCase(<String>['aBc'], 'DeF', 'deF');
  _assertPreserveCase(<String>['Foo-Bar'], 'newfoo-newbar', 'Newfoo-Newbar');
  _assertPreserveCase(<String>['Foo-Bar-Abc'], 'newfoo-newbar-newabc', 'Newfoo-Newbar-Newabc');
  _assertPreserveCase(<String>['Foo-Bar-abc'], 'newfoo-newbar', 'Newfoo-newbar');
  _assertPreserveCase(<String>['foo-Bar'], 'newfoo-newbar', 'newfoo-Newbar');
  _assertPreserveCase(<String>['foo-BAR'], 'newfoo-newbar', 'newfoo-NEWBAR');
  _assertPreserveCase(<String>['foO-BAR'], 'NewFoo-NewBar', 'newFoo-NEWBAR');
  _assertPreserveCase(<String>['Foo_Bar'], 'newfoo_newbar', 'Newfoo_Newbar');
  _assertPreserveCase(<String>['Foo_Bar_Abc'], 'newfoo_newbar_newabc', 'Newfoo_Newbar_Newabc');
  _assertPreserveCase(<String>['Foo_Bar_abc'], 'newfoo_newbar', 'Newfoo_newbar');
  _assertPreserveCase(<String>['Foo_Bar-abc'], 'newfoo_newbar-abc', 'Newfoo_newbar-abc');
  _assertPreserveCase(<String>['foo_Bar'], 'newfoo_newbar', 'newfoo_Newbar');
  _assertPreserveCase(<String>['Foo_BAR'], 'newfoo_newbar', 'Newfoo_NEWBAR');
}

void runAll() {
  testParseReplaceString();
  testParseReplaceStringWithCaseModifiers();
  testReplaceHasJavaScriptSemantics();
  testGetReplaceStringCompleteMatch();
  testGetReplaceStringSubstringMatch();
  testIssue19740CaptureGroupUndefined();
  testBuildReplaceStringWithCasePreserved();
  testPreserveCase();
}
