// 1:1 port of monaco-editor/src/languages/definitions/test/testRunner.ts
// Bridges (editor.api.ts / node:test / assert not ported):
//   - `editor.tokenize(text, languageId)` -> `tokenizeProvider` slot.
//   - `test(name, async fn)` -> `testRunnerTest` slot (default runs immediately).
//   - `assert.deepStrictEqual` -> `deepStrictEqual` slot (default throws StateError).
//   - `import '../register.all'` side effect -> `registerAllProvider` slot (no-op default).
import 'dart:async' show Completer, Future, Timer;

import '../../definitions/_.contribution.dart' show loadLanguage;

/// bridge: `loadLanguage(l)` — injectable so tokenization tests can run without
/// the full language registration side effects. Defaults to the real function.
Future<void> Function(String languageId) loadLanguageProvider = loadLanguage;

/// bridge: observability hook invoked at the top of [testTokenization] with the
/// exact `(language, tests)` arguments. Default no-op; used to export the
/// generated test data for byte-comparison against the TS runtime truth.
void Function(Object language, List<List<ITestItem>> tests) testTokenizationHook =
    (Object language, List<List<ITestItem>> tests) {};

/// 1:1: `export interface IRelaxedToken`
class IRelaxedToken {
  final int startIndex;
  final String type;
  IRelaxedToken(this.startIndex, this.type);

  @override
  String toString() => 'IRelaxedToken($startIndex,$type)';

  @override
  bool operator ==(Object other) =>
      other is IRelaxedToken && other.startIndex == startIndex && other.type == type;

  @override
  int get hashCode => Object.hash(startIndex, type);
}

/// 1:1: `export interface ITestItem`
class ITestItem {
  final String line;
  final List<IRelaxedToken> tokens;
  ITestItem(this.line, this.tokens);

  @override
  bool operator ==(Object other) =>
      other is ITestItem && other.line == line && _tokensEq(other.tokens, tokens);

  @override
  int get hashCode => Object.hash(line, Object.hashAll(tokens));

  static bool _tokensEq(List<IRelaxedToken> a, List<IRelaxedToken> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// 1:1: `editor.tokenize` result line token (`{ offset, type }`).
class TokenizeToken {
  final int offset;
  final String type;
  TokenizeToken(this.offset, this.type);
}

/// bridge: `editor.tokenize(text, languageId): TokenizeToken[][]`
List<List<TokenizeToken>> Function(String text, String languageId) tokenizeProvider =
    (String text, String languageId) => <List<TokenizeToken>>[];

/// bridge: `import '../register.all'` side effect.
void Function() registerAllProvider = () {};

/// bridge: node:test `test(name, async fn)`.
void Function(String name, Future<void> Function() fn) testRunnerTest =
    (String name, Future<void> Function() fn) {
  fn();
};

/// bridge: `assert.deepStrictEqual(actual, expected)`.
void Function(Object? actual, Object? expected) deepStrictEqual =
    (Object? actual, Object? expected) {
  if (actual != expected) {
    throw StateError('deepStrictEqual mismatch: $actual != $expected');
  }
};

/// 1:1: `function timeout(ms)`
Future<void> timeout(int ms) {
  final c = Completer<void>();
  Timer(Duration(milliseconds: ms), () => c.complete());
  return c.future;
}

/// 1:1: `export function testTokenization(_language, tests)`
void testTokenization(Object language, List<List<ITestItem>> tests) {
  testTokenizationHook(language, tests);
  final List<String> languages;
  if (language is String) {
    languages = <String>[language];
  } else {
    languages = (language as List).cast<String>();
  }
  final mainLanguage = languages[0];

  testRunnerTest(mainLanguage + ' tokenization', () async {
    await Future.wait(languages.map((l) => loadLanguageProvider(l)));
    await timeout(0);
    runTests(mainLanguage, tests);
  });
}

/// 1:1: `function runTests`
void runTests(String languageId, List<List<ITestItem>> tests) {
  for (final t in tests) {
    runTest(languageId, t);
  }
}

/// 1:1: `function runTest`
void runTest(String languageId, List<ITestItem> test) {
  final text = test.map((t) => t.line).join('\n');
  final actualTokens = tokenizeProvider(text, languageId);
  final actual = actualTokens.asMap().entries.map((entry) {
    final lineTokens = entry.value;
    final idx = entry.key;
    return ITestItem(
      test[idx].line,
      lineTokens.map((t) => IRelaxedToken(t.offset, t.type)).toList(),
    );
  }).toList();
  deepStrictEqual(actual, test);
}
