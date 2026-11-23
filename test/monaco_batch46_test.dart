import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/languages/definitions/test/testRunner.dart' as TR;
import 'package:semi_design_flutter/src/monaco/languages/definitions/abap/abap.test.dart' as _runLanguagesDefinitionsAbapAbapTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/azcli/azcli.test.dart' as _runLanguagesDefinitionsAzcliAzcliTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/bat/bat.test.dart' as _runLanguagesDefinitionsBatBatTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/cameligo/cameligo.test.dart' as _runLanguagesDefinitionsCameligoCameligoTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/cypher/cypher.test.dart' as _runLanguagesDefinitionsCypherCypherTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/dockerfile/dockerfile.test.dart' as _runLanguagesDefinitionsDockerfileDockerfileTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/flow9/flow9.test.dart' as _runLanguagesDefinitionsFlow9Flow9TestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/graphql/graphql.test.dart' as _runLanguagesDefinitionsGraphqlGraphqlTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/handlebars/handlebars.test.dart' as _runLanguagesDefinitionsHandlebarsHandlebarsTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/mdx/mdx.test.dart' as _runLanguagesDefinitionsMdxMdxTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/julia/julia.test.dart' as _runLanguagesDefinitionsJuliaJuliaTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/lexon/lexon.test.dart' as _runLanguagesDefinitionsLexonLexonTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/liquid/liquid.test.dart' as _runLanguagesDefinitionsLiquidLiquidTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/lua/lua.test.dart' as _runLanguagesDefinitionsLuaLuaTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/m3/m3.test.dart' as _runLanguagesDefinitionsM3M3TestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/markdown/markdown.test.dart' as _runLanguagesDefinitionsMarkdownMarkdownTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/mdx/mdx.test.dart' as _runLanguagesDefinitionsMdxMdxTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/mips/mips.test.dart' as _runLanguagesDefinitionsMipsMipsTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/objective-c/objective-c.test.dart' as _runLanguagesDefinitionsObjectiveCObjectiveCTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/pascal/pascal.test.dart' as _runLanguagesDefinitionsPascalPascalTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/pascaligo/pascaligo.test.dart' as _runLanguagesDefinitionsPascaligoPascaligoTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/python/python.test.dart' as _runLanguagesDefinitionsPythonPythonTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/qsharp/qsharp.test.dart' as _runLanguagesDefinitionsQsharpQsharpTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/razor/razor.test.dart' as _runLanguagesDefinitionsRazorRazorTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/redis/redis.test.dart' as _runLanguagesDefinitionsRedisRedisTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/ruby/ruby.test.dart' as _runLanguagesDefinitionsRubyRubyTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/rust/rust.test.dart' as _runLanguagesDefinitionsRustRustTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/sb/sb.test.dart' as _runLanguagesDefinitionsSbSbTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/scheme/scheme.test.dart' as _runLanguagesDefinitionsSchemeSchemeTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/shell/shell.test.dart' as _runLanguagesDefinitionsShellShellTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/sparql/sparql.test.dart' as _runLanguagesDefinitionsSparqlSparqlTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/mdx/mdx.test.dart' as _runLanguagesDefinitionsMdxMdxTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/swift/swift.test.dart' as _runLanguagesDefinitionsSwiftSwiftTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/tcl/tcl.test.dart' as _runLanguagesDefinitionsTclTclTestCases;

/// batch46: 36 language tokenization test files (first wave). Regenerated after
/// batch48 unified the generated driver function names. Full byte-level truth
/// is in tool/ts2dart/verify_toktests.py.
void main() {
  group('batch46 / 36 tokenization test datasets 1:1', () {
    setUp(() {
      TR.loadLanguageProvider = (l) async {};
      TR.tokenizeProvider = (text, lang) => <List<TR.TokenizeToken>>[];
      TR.deepStrictEqual = (a, b) {};
      TR.testRunnerTest = (name, fn) {};
    });

    final drivers = <String, void Function()>{
        'abap': _runLanguagesDefinitionsAbapAbapTestCases.runLanguagesDefinitionsAbapAbapTestCases,
        'azcli': _runLanguagesDefinitionsAzcliAzcliTestCases.runLanguagesDefinitionsAzcliAzcliTestCases,
        'bat': _runLanguagesDefinitionsBatBatTestCases.runLanguagesDefinitionsBatBatTestCases,
        'cameligo': _runLanguagesDefinitionsCameligoCameligoTestCases.runLanguagesDefinitionsCameligoCameligoTestCases,
        'cypher': _runLanguagesDefinitionsCypherCypherTestCases.runLanguagesDefinitionsCypherCypherTestCases,
        'dockerfile': _runLanguagesDefinitionsDockerfileDockerfileTestCases.runLanguagesDefinitionsDockerfileDockerfileTestCases,
        'flow9': _runLanguagesDefinitionsFlow9Flow9TestCases.runLanguagesDefinitionsFlow9Flow9TestCases,
        'graphql': _runLanguagesDefinitionsGraphqlGraphqlTestCases.runLanguagesDefinitionsGraphqlGraphqlTestCases,
        'handlebars': _runLanguagesDefinitionsHandlebarsHandlebarsTestCases.runLanguagesDefinitionsHandlebarsHandlebarsTestCases,
        'ini': _runLanguagesDefinitionsMdxMdxTestCases.runLanguagesDefinitionsMdxMdxTestCases,
        'julia': _runLanguagesDefinitionsJuliaJuliaTestCases.runLanguagesDefinitionsJuliaJuliaTestCases,
        'lexon': _runLanguagesDefinitionsLexonLexonTestCases.runLanguagesDefinitionsLexonLexonTestCases,
        'liquid': _runLanguagesDefinitionsLiquidLiquidTestCases.runLanguagesDefinitionsLiquidLiquidTestCases,
        'lua': _runLanguagesDefinitionsLuaLuaTestCases.runLanguagesDefinitionsLuaLuaTestCases,
        'm3': _runLanguagesDefinitionsM3M3TestCases.runLanguagesDefinitionsM3M3TestCases,
        'markdown': _runLanguagesDefinitionsMarkdownMarkdownTestCases.runLanguagesDefinitionsMarkdownMarkdownTestCases,
        'mdx': _runLanguagesDefinitionsMdxMdxTestCases.runLanguagesDefinitionsMdxMdxTestCases,
        'mips': _runLanguagesDefinitionsMipsMipsTestCases.runLanguagesDefinitionsMipsMipsTestCases,
        'objective-c': _runLanguagesDefinitionsObjectiveCObjectiveCTestCases.runLanguagesDefinitionsObjectiveCObjectiveCTestCases,
        'pascal': _runLanguagesDefinitionsPascalPascalTestCases.runLanguagesDefinitionsPascalPascalTestCases,
        'pascaligo': _runLanguagesDefinitionsPascaligoPascaligoTestCases.runLanguagesDefinitionsPascaligoPascaligoTestCases,
        'python': _runLanguagesDefinitionsPythonPythonTestCases.runLanguagesDefinitionsPythonPythonTestCases,
        'qsharp': _runLanguagesDefinitionsQsharpQsharpTestCases.runLanguagesDefinitionsQsharpQsharpTestCases,
        'razor': _runLanguagesDefinitionsRazorRazorTestCases.runLanguagesDefinitionsRazorRazorTestCases,
        'redis': _runLanguagesDefinitionsRedisRedisTestCases.runLanguagesDefinitionsRedisRedisTestCases,
        'ruby': _runLanguagesDefinitionsRubyRubyTestCases.runLanguagesDefinitionsRubyRubyTestCases,
        'rust': _runLanguagesDefinitionsRustRustTestCases.runLanguagesDefinitionsRustRustTestCases,
        'sb': _runLanguagesDefinitionsSbSbTestCases.runLanguagesDefinitionsSbSbTestCases,
        'scheme': _runLanguagesDefinitionsSchemeSchemeTestCases.runLanguagesDefinitionsSchemeSchemeTestCases,
        'shell': _runLanguagesDefinitionsShellShellTestCases.runLanguagesDefinitionsShellShellTestCases,
        'sparql': _runLanguagesDefinitionsSparqlSparqlTestCases.runLanguagesDefinitionsSparqlSparqlTestCases,
        'st': _runLanguagesDefinitionsMdxMdxTestCases.runLanguagesDefinitionsMdxMdxTestCases,
        'swift': _runLanguagesDefinitionsSwiftSwiftTestCases.runLanguagesDefinitionsSwiftSwiftTestCases,
        'tcl': _runLanguagesDefinitionsTclTclTestCases.runLanguagesDefinitionsTclTclTestCases,
    };

    test('all first-wave datasets are well-formed', () {
      final seen = <Object>[];
      TR.testTokenizationHook = (lang, tests) {
        seen.add(lang);
        expect(tests, isA<List<List<TR.ITestItem>>>());
      };
      drivers.forEach((k, fn) => fn());
      expect(seen.length, drivers.length);
    });

    test('sample: julia first-line tokens', () {
      TR.testTokenizationHook = (lang, tests) {
        if (lang != 'julia') return;
        expect(tests.first.first.line, 'a = 1');
        expect(tests.first.first.tokens.length, 5);
      };
      drivers['julia']!();
    });
  });
}
