// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/modes/languageSelector.test.ts
// Translated 1:1. The 11 mocha cases become Dart functions carrying the exact
// `strictEqual` / `deepStrictEqual` assertions.
// `LanguageSelector` = `Object?`; TS object literals -> Dart `Map<String, Object?>`.
// `ensureNoDisposablesAreLeakedInTestSuite()` is a suite-level harness hook and
// is intentionally omitted here.
// ---------------------------------------------------------------------------

import '../../../../base/common/uri.dart' show URI;
import '../../../common/languageSelector.dart' show score, selectLanguageIds;

final URI _modelUri = URI.parse('file:///testbed/file.fb');
const String _modelLanguage = 'farboo';

int _s(Object? selector, [URI? uri, String? language, bool? sync, URI? nbUri, String? nbType]) =>
    score(selector, uri ?? _modelUri, language ?? _modelLanguage, sync ?? true,
        nbUri, nbType);

void _assertListEquals(List<String> actual, List<String> expected, String label) {
  assert(actual.length == expected.length, '$label length');
  for (int i = 0; i < expected.length; i++) {
    assert(actual[i] == expected[i], '$label[$i]');
  }
}

/// 1:1: `test('score, invalid selector')`
void testScoreInvalidSelector() {
  assert(_s(<String, Object?>{}) == 0);
  assert(_s(null) == 0);
  assert(_s('') == 0);
}

/// 1:1: `test('score, any language')`
void testScoreAnyLanguage() {
  assert(_s(<String, Object?>{'language': '*'}) == 5);
  assert(_s('*') == 5);
  assert(_s('*', URI.parse('foo:bar')) == 5);
  assert(_s('farboo', URI.parse('foo:bar')) == 10);
}

/// 1:1: `test('score, default schemes')`
void testScoreDefaultSchemes() {
  final URI uri = URI.parse('git:foo/file.txt');
  const String language = 'farboo';
  assert(score('*', uri, language, true, null, null) == 5);
  assert(score('farboo', uri, language, true, null, null) == 10);
  assert(score(<String, Object?>{'language': 'farboo', 'scheme': ''}, uri, language, true, null, null) == 10);
  assert(score(<String, Object?>{'language': 'farboo', 'scheme': 'git'}, uri, language, true, null, null) == 10);
  assert(score(<String, Object?>{'language': 'farboo', 'scheme': '*'}, uri, language, true, null, null) == 10);
  assert(score(<String, Object?>{'language': 'farboo'}, uri, language, true, null, null) == 10);
  assert(score(<String, Object?>{'language': '*'}, uri, language, true, null, null) == 5);
  assert(score(<String, Object?>{'scheme': '*'}, uri, language, true, null, null) == 5);
  assert(score(<String, Object?>{'scheme': 'git'}, uri, language, true, null, null) == 10);
}

/// 1:1: `test('score, filter')`
void testScoreFilter() {
  assert(_s('farboo') == 10);
  assert(_s(<String, Object?>{'language': 'farboo'}) == 10);
  assert(_s(<String, Object?>{'language': 'farboo', 'scheme': 'file'}) == 10);
  assert(_s(<String, Object?>{'language': 'farboo', 'scheme': 'http'}) == 0);
  assert(_s(<String, Object?>{'pattern': '**/*.fb'}) == 10);
  assert(_s(<String, Object?>{'pattern': '**/*.fb', 'scheme': 'file'}) == 10);
  assert(_s(<String, Object?>{'pattern': '**/*.fb'}, URI.parse('foo:bar')) == 0);
  assert(_s(<String, Object?>{'pattern': '**/*.fb', 'scheme': 'foo'}, URI.parse('foo:bar')) == 0);

  final URI docUri = URI.parse('git:/my/file.js');
  const String langId = 'javascript';
  assert(score('javascript', docUri, langId, true, null, null) == 10);
  assert(score(<String, Object?>{'language': 'javascript', 'scheme': 'git'}, docUri, langId, true, null, null) == 10);
  assert(score('*', docUri, langId, true, null, null) == 5);
  assert(score('fooLang', docUri, langId, true, null, null) == 0);
  assert(score(<Object?>[
    'fooLang', '*'
  ], docUri, langId, true, null, null) == 5);
}

/// 1:1: `test('score, max(filters)')`
void testScoreMaxFilters() {
  final Map<String, Object?> match = <String, Object?>{'language': 'farboo', 'scheme': 'file'};
  final Map<String, Object?> fail = <String, Object?>{'language': 'farboo', 'scheme': 'http'};
  assert(_s(match) == 10);
  assert(_s(fail) == 0);
  assert(_s(<Object?>[match, fail]) == 10);
  assert(_s(<Object?>[fail, fail]) == 0);
  assert(_s(<Object?>['farboo', '*']) == 10);
  assert(_s(<Object?>['*', 'farboo']) == 10);
}

/// 1:1: `test('score hasAccessToAllModels')`
void testScoreHasAccessToAllModels() {
  final URI docUri = URI.parse('file:/my/file.js');
  const String langId = 'javascript';
  assert(score('javascript', docUri, langId, false, null, null) == 0);
  assert(score(<String, Object?>{'language': 'javascript', 'scheme': 'file'}, docUri, langId, false, null, null) == 0);
  assert(score('*', docUri, langId, false, null, null) == 0);
  assert(score('fooLang', docUri, langId, false, null, null) == 0);
  assert(score(<Object?>['fooLang', '*'], docUri, langId, false, null, null) == 0);
  assert(score(<String, Object?>{'language': 'javascript', 'scheme': 'file', 'hasAccessToAllModels': true}, docUri, langId, false, null, null) == 10);
  assert(score(<Object?>['fooLang', '*', <String, Object?>{'language': '*', 'hasAccessToAllModels': true}], docUri, langId, false, null, null) == 5);
}

/// 1:1: `test('score, notebookType')`
void testScoreNotebookType() {
  final URI uri = URI.parse('vscode-notebook-cell:///my/file.js#blabla');
  final URI nbUri = URI.parse('file:///my/file.js');
  const String langId = 'javascript';
  assert(score('javascript', uri, langId, true, null, null) == 10);
  assert(score('javascript', uri, langId, true, nbUri, 'fooBook') == 10);
  assert(score(<String, Object?>{'notebookType': 'fooBook'}, uri, langId, true, nbUri, 'fooBook') == 10);
  assert(score(<String, Object?>{'notebookType': 'fooBook', 'language': 'javascript', 'scheme': 'file'}, uri, langId, true, nbUri, 'fooBook') == 10);
  assert(score(<String, Object?>{'notebookType': 'fooBook', 'language': '*'}, uri, langId, true, nbUri, 'fooBook') == 10);
  assert(score(<String, Object?>{'notebookType': '*', 'language': '*'}, uri, langId, true, nbUri, 'fooBook') == 5);
  assert(score(<String, Object?>{'notebookType': '*', 'language': 'javascript'}, uri, langId, true, nbUri, 'fooBook') == 10);
}

/// 1:1: `test('Snippet choices lost #149363')`
void testSnippetChoicesLost149363() {
  final Map<String, Object?> selector = <String, Object?>{
    'scheme': 'vscode-notebook-cell',
    'pattern': '/some/path/file.py',
    'language': 'python',
  };
  final URI modelUri = URI.parse('vscode-notebook-cell:///some/path/file.py');
  final URI nbUri = URI.parse('file:///some/path/file.py');
  assert(score(selector, modelUri, 'python', true, nbUri, 'jupyter') == 10);
  final Map<String, Object?> selector2 = <String, Object?>{
    ...selector,
    'notebookType': 'jupyter',
  };
  assert(score(selector2, modelUri, 'python', true, nbUri, 'jupyter') == 0);
}

/// 1:1: `test('Document selector match - unexpected result value #60232')`
void testDocumentSelectorUnexpected60232() {
  final Map<String, Object?> selector = <String, Object?>{
    'language': 'json',
    'scheme': 'file',
    'pattern': '**/*.interface.json',
  };
  assert(score(selector, URI.parse('file:///C:/Users/zlhe/Desktop/test.interface.json'), 'json', true, null, null) == 10);
}

/// 1:1: `test('Document selector match - platform paths #99938')`
void testDocumentSelectorPlatformPaths99938() {
  final Map<String, Object?> selector = <String, Object?>{
    'pattern': <String, Object?>{'base': '/home/user/Desktop', 'pattern': '*.json'},
  };
  assert(score(selector, URI.file('/home/user/Desktop/test.json'), 'json', true, null, null) == 10);
}

/// 1:1: `test('NotebookType without notebook')`
void testNotebookTypeWithoutNotebook() {
  final URI uri = URI.parse('file:///my/file.bat');
  assert(score(<String, Object?>{'language': 'bat', 'notebookType': 'xxx'}, uri, 'bat', true, null, null) == 0);
  assert(score(<String, Object?>{'language': 'bat', 'notebookType': '*'}, uri, 'bat', true, null, null) == 0);
}

/// 1:1: `test('selectLanguageIds')`
void testSelectLanguageIds() {
  final Set<String> result = <String>{};
  selectLanguageIds('typescript', result);
  _assertListEquals(result.toList(), <String>['typescript'], 'select 1');

  result.clear();
  selectLanguageIds(<String, Object?>{'language': 'python', 'scheme': 'file'}, result);
  _assertListEquals(result.toList(), <String>['python'], 'select 2');

  result.clear();
  selectLanguageIds(<String, Object?>{'scheme': 'file'}, result);
  _assertListEquals(result.toList(), <String>[], 'select 3');

  result.clear();
  selectLanguageIds(<Object?>['javascript', <String, Object?>{'language': 'css'}, <String, Object?>{'scheme': 'untitled'}], result);
  final List<String> sorted = result.toList()..sort();
  _assertListEquals(sorted, <String>['css', 'javascript'], 'select 4');

  result.clear();
  selectLanguageIds('*', result);
  _assertListEquals(result.toList(), <String>['*'], 'select 5');
}

void runAll() {
  testScoreInvalidSelector();
  testScoreAnyLanguage();
  testScoreDefaultSchemes();
  testScoreFilter();
  testScoreMaxFilters();
  testScoreHasAccessToAllModels();
  testScoreNotebookType();
  testSnippetChoicesLost149363();
  testDocumentSelectorUnexpected60232();
  testDocumentSelectorPlatformPaths99938();
  testNotebookTypeWithoutNotebook();
  testSelectLanguageIds();
}
