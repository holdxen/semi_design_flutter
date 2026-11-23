import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/languages/definitions/test/testRunner.dart' as TR;
import 'package:semi_design_flutter/src/monaco/languages/definitions/abap/abap.test.dart' as _runLanguagesDefinitionsAbapAbapTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/apex/apex.test.dart' as _runLanguagesDefinitionsApexApexTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/azcli/azcli.test.dart' as _runLanguagesDefinitionsAzcliAzcliTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/bat/bat.test.dart' as _runLanguagesDefinitionsBatBatTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/bicep/bicep.test.dart' as _runLanguagesDefinitionsBicepBicepTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/cameligo/cameligo.test.dart' as _runLanguagesDefinitionsCameligoCameligoTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/clojure/clojure.test.dart' as _runLanguagesDefinitionsClojureClojureTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/coffee/coffee.test.dart' as _runLanguagesDefinitionsCoffeeCoffeeTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/cpp/cpp.test.dart' as _runLanguagesDefinitionsCppCppTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/csharp/csharp.test.dart' as _runLanguagesDefinitionsCsharpCsharpTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/csp/csp.test.dart' as _runLanguagesDefinitionsCspCspTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/css/css.test.dart' as _runLanguagesDefinitionsCssCssTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/cypher/cypher.test.dart' as _runLanguagesDefinitionsCypherCypherTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/dart/dart.test.dart' as _runLanguagesDefinitionsDartDartTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/dockerfile/dockerfile.test.dart' as _runLanguagesDefinitionsDockerfileDockerfileTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/ecl/ecl.test.dart' as _runLanguagesDefinitionsEclEclTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/elixir/elixir.test.dart' as _runLanguagesDefinitionsElixirElixirTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/flow9/flow9.test.dart' as _runLanguagesDefinitionsFlow9Flow9TestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/freemarker2/freemarker2-angle-bracket.test.dart' as _runLanguagesDefinitionsFreemarker2Freemarker2AngleBracketTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/freemarker2/freemarker2-angle-dollar.test.dart' as _runLanguagesDefinitionsFreemarker2Freemarker2AngleDollarTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/freemarker2/freemarker2-auto-bracket.test.dart' as _runLanguagesDefinitionsFreemarker2Freemarker2AutoBracketTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/freemarker2/freemarker2-auto-dollar.test.dart' as _runLanguagesDefinitionsFreemarker2Freemarker2AutoDollarTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/freemarker2/freemarker2-bracket-bracket.test.dart' as _runLanguagesDefinitionsFreemarker2Freemarker2BracketBracketTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/freemarker2/freemarker2-bracket-dollar.test.dart' as _runLanguagesDefinitionsFreemarker2Freemarker2BracketDollarTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/fsharp/fsharp.test.dart' as _runLanguagesDefinitionsFsharpFsharpTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/go/go.test.dart' as _runLanguagesDefinitionsGoGoTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/graphql/graphql.test.dart' as _runLanguagesDefinitionsGraphqlGraphqlTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/handlebars/handlebars.test.dart' as _runLanguagesDefinitionsHandlebarsHandlebarsTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/hcl/hcl.test.dart' as _runLanguagesDefinitionsHclHclTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/html/html.test.dart' as _runLanguagesDefinitionsHtmlHtmlTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/ini/ini.test.dart' as _runLanguagesDefinitionsIniIniTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/java/java.test.dart' as _runLanguagesDefinitionsJavaJavaTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/javascript/javascript.test.dart' as _runLanguagesDefinitionsJavascriptJavascriptTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/julia/julia.test.dart' as _runLanguagesDefinitionsJuliaJuliaTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/kotlin/kotlin.test.dart' as _runLanguagesDefinitionsKotlinKotlinTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/less/less.test.dart' as _runLanguagesDefinitionsLessLessTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/lexon/lexon.test.dart' as _runLanguagesDefinitionsLexonLexonTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/liquid/liquid.test.dart' as _runLanguagesDefinitionsLiquidLiquidTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/lua/lua.test.dart' as _runLanguagesDefinitionsLuaLuaTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/m3/m3.test.dart' as _runLanguagesDefinitionsM3M3TestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/markdown/markdown.test.dart' as _runLanguagesDefinitionsMarkdownMarkdownTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/mdx/mdx.test.dart' as _runLanguagesDefinitionsMdxMdxTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/mips/mips.test.dart' as _runLanguagesDefinitionsMipsMipsTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/msdax/msdax.test.dart' as _runLanguagesDefinitionsMsdaxMsdaxTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/mysql/mysql.test.dart' as _runLanguagesDefinitionsMysqlMysqlTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/objective-c/objective-c.test.dart' as _runLanguagesDefinitionsObjectiveCObjectiveCTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/pascal/pascal.test.dart' as _runLanguagesDefinitionsPascalPascalTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/pascaligo/pascaligo.test.dart' as _runLanguagesDefinitionsPascaligoPascaligoTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/perl/perl.test.dart' as _runLanguagesDefinitionsPerlPerlTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/pgsql/pgsql.test.dart' as _runLanguagesDefinitionsPgsqlPgsqlTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/php/php.test.dart' as _runLanguagesDefinitionsPhpPhpTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/pla/pla.test.dart' as _runLanguagesDefinitionsPlaPlaTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/postiats/postiats.test.dart' as _runLanguagesDefinitionsPostiatsPostiatsTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/powerquery/powerquery.test.dart' as _runLanguagesDefinitionsPowerqueryPowerqueryTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/powershell/powershell.test.dart' as _runLanguagesDefinitionsPowershellPowershellTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/protobuf/protobuf.test.dart' as _runLanguagesDefinitionsProtobufProtobufTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/pug/pug.test.dart' as _runLanguagesDefinitionsPugPugTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/python/python.test.dart' as _runLanguagesDefinitionsPythonPythonTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/qsharp/qsharp.test.dart' as _runLanguagesDefinitionsQsharpQsharpTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/r/r.test.dart' as _runLanguagesDefinitionsRRTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/razor/razor.test.dart' as _runLanguagesDefinitionsRazorRazorTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/redis/redis.test.dart' as _runLanguagesDefinitionsRedisRedisTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/redshift/redshift.test.dart' as _runLanguagesDefinitionsRedshiftRedshiftTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/restructuredtext/restructuredtext.test.dart' as _runLanguagesDefinitionsRestructuredtextRestructuredtextTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/ruby/ruby.test.dart' as _runLanguagesDefinitionsRubyRubyTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/rust/rust.test.dart' as _runLanguagesDefinitionsRustRustTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/sb/sb.test.dart' as _runLanguagesDefinitionsSbSbTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/scala/scala.test.dart' as _runLanguagesDefinitionsScalaScalaTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/scheme/scheme.test.dart' as _runLanguagesDefinitionsSchemeSchemeTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/scss/scss.test.dart' as _runLanguagesDefinitionsScssScssTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/shell/shell.test.dart' as _runLanguagesDefinitionsShellShellTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/solidity/solidity.test.dart' as _runLanguagesDefinitionsSoliditySolidityTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/sophia/sophia.test.dart' as _runLanguagesDefinitionsSophiaSophiaTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/sparql/sparql.test.dart' as _runLanguagesDefinitionsSparqlSparqlTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/sql/sql.test.dart' as _runLanguagesDefinitionsSqlSqlTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/st/st.test.dart' as _runLanguagesDefinitionsStStTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/swift/swift.test.dart' as _runLanguagesDefinitionsSwiftSwiftTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/systemverilog/systemverilog.test.dart' as _runLanguagesDefinitionsSystemverilogSystemverilogTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/tcl/tcl.test.dart' as _runLanguagesDefinitionsTclTclTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/twig/twig.test.dart' as _runLanguagesDefinitionsTwigTwigTestCases1;
import 'package:semi_design_flutter/src/monaco/languages/definitions/twig/twig.test.dart' as _runLanguagesDefinitionsTwigTwigTestCases2;
import 'package:semi_design_flutter/src/monaco/languages/definitions/typescript/typescript.test.dart' as _runLanguagesDefinitionsTypescriptTypescriptTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/typespec/typespec.test.dart' as _runLanguagesDefinitionsTypespecTypespecTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/vb/vb.test.dart' as _runLanguagesDefinitionsVbVbTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/wgsl/wgsl.test.dart' as _runLanguagesDefinitionsWgslWgslTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/xml/xml.test.dart' as _runLanguagesDefinitionsXmlXmlTestCases;
import 'package:semi_design_flutter/src/monaco/languages/definitions/yaml/yaml.test.dart' as _runLanguagesDefinitionsYamlYamlTestCases;

/// batch48: 50 remaining language tokenization datasets (86 language test
/// libraries total, 87 testTokenization calls). Full byte-level truth is
/// verified by tool/ts2dart/verify_toktests.py (87 calls / 7043 items /
/// 33376 tokens). These tests drive every generated dataset through the
/// testRunner bridge to prove structural soundness.
void main() {
  group('batch48 / remaining tokenization datasets 1:1', () {
    setUp(() {
      TR.loadLanguageProvider = (l) async {};
      TR.tokenizeProvider = (text, lang) => <List<TR.TokenizeToken>>[];
      TR.deepStrictEqual = (a, b) {};
      TR.testRunnerTest = (name, fn) {};
    });

    final drivers = <void Function()>[
  _runLanguagesDefinitionsAbapAbapTestCases.runLanguagesDefinitionsAbapAbapTestCases,
  _runLanguagesDefinitionsApexApexTestCases.runLanguagesDefinitionsApexApexTestCases,
  _runLanguagesDefinitionsAzcliAzcliTestCases.runLanguagesDefinitionsAzcliAzcliTestCases,
  _runLanguagesDefinitionsBatBatTestCases.runLanguagesDefinitionsBatBatTestCases,
  _runLanguagesDefinitionsBicepBicepTestCases.runLanguagesDefinitionsBicepBicepTestCases,
  _runLanguagesDefinitionsCameligoCameligoTestCases.runLanguagesDefinitionsCameligoCameligoTestCases,
  _runLanguagesDefinitionsClojureClojureTestCases.runLanguagesDefinitionsClojureClojureTestCases,
  _runLanguagesDefinitionsCoffeeCoffeeTestCases.runLanguagesDefinitionsCoffeeCoffeeTestCases,
  _runLanguagesDefinitionsCppCppTestCases.runLanguagesDefinitionsCppCppTestCases,
  _runLanguagesDefinitionsCsharpCsharpTestCases.runLanguagesDefinitionsCsharpCsharpTestCases,
  _runLanguagesDefinitionsCspCspTestCases.runLanguagesDefinitionsCspCspTestCases,
  _runLanguagesDefinitionsCssCssTestCases.runLanguagesDefinitionsCssCssTestCases,
  _runLanguagesDefinitionsCypherCypherTestCases.runLanguagesDefinitionsCypherCypherTestCases,
  _runLanguagesDefinitionsDartDartTestCases.runLanguagesDefinitionsDartDartTestCases,
  _runLanguagesDefinitionsDockerfileDockerfileTestCases.runLanguagesDefinitionsDockerfileDockerfileTestCases,
  _runLanguagesDefinitionsEclEclTestCases.runLanguagesDefinitionsEclEclTestCases,
  _runLanguagesDefinitionsElixirElixirTestCases.runLanguagesDefinitionsElixirElixirTestCases,
  _runLanguagesDefinitionsFlow9Flow9TestCases.runLanguagesDefinitionsFlow9Flow9TestCases,
  _runLanguagesDefinitionsFreemarker2Freemarker2AngleBracketTestCases.runLanguagesDefinitionsFreemarker2Freemarker2AngleBracketTestCases,
  _runLanguagesDefinitionsFreemarker2Freemarker2AngleDollarTestCases.runLanguagesDefinitionsFreemarker2Freemarker2AngleDollarTestCases,
  _runLanguagesDefinitionsFreemarker2Freemarker2AutoBracketTestCases.runLanguagesDefinitionsFreemarker2Freemarker2AutoBracketTestCases,
  _runLanguagesDefinitionsFreemarker2Freemarker2AutoDollarTestCases.runLanguagesDefinitionsFreemarker2Freemarker2AutoDollarTestCases,
  _runLanguagesDefinitionsFreemarker2Freemarker2BracketBracketTestCases.runLanguagesDefinitionsFreemarker2Freemarker2BracketBracketTestCases,
  _runLanguagesDefinitionsFreemarker2Freemarker2BracketDollarTestCases.runLanguagesDefinitionsFreemarker2Freemarker2BracketDollarTestCases,
  _runLanguagesDefinitionsFsharpFsharpTestCases.runLanguagesDefinitionsFsharpFsharpTestCases,
  _runLanguagesDefinitionsGoGoTestCases.runLanguagesDefinitionsGoGoTestCases,
  _runLanguagesDefinitionsGraphqlGraphqlTestCases.runLanguagesDefinitionsGraphqlGraphqlTestCases,
  _runLanguagesDefinitionsHandlebarsHandlebarsTestCases.runLanguagesDefinitionsHandlebarsHandlebarsTestCases,
  _runLanguagesDefinitionsHclHclTestCases.runLanguagesDefinitionsHclHclTestCases,
  _runLanguagesDefinitionsHtmlHtmlTestCases.runLanguagesDefinitionsHtmlHtmlTestCases,
  _runLanguagesDefinitionsIniIniTestCases.runLanguagesDefinitionsIniIniTestCases,
  _runLanguagesDefinitionsJavaJavaTestCases.runLanguagesDefinitionsJavaJavaTestCases,
  _runLanguagesDefinitionsJavascriptJavascriptTestCases.runLanguagesDefinitionsJavascriptJavascriptTestCases,
  _runLanguagesDefinitionsJuliaJuliaTestCases.runLanguagesDefinitionsJuliaJuliaTestCases,
  _runLanguagesDefinitionsKotlinKotlinTestCases.runLanguagesDefinitionsKotlinKotlinTestCases,
  _runLanguagesDefinitionsLessLessTestCases.runLanguagesDefinitionsLessLessTestCases,
  _runLanguagesDefinitionsLexonLexonTestCases.runLanguagesDefinitionsLexonLexonTestCases,
  _runLanguagesDefinitionsLiquidLiquidTestCases.runLanguagesDefinitionsLiquidLiquidTestCases,
  _runLanguagesDefinitionsLuaLuaTestCases.runLanguagesDefinitionsLuaLuaTestCases,
  _runLanguagesDefinitionsM3M3TestCases.runLanguagesDefinitionsM3M3TestCases,
  _runLanguagesDefinitionsMarkdownMarkdownTestCases.runLanguagesDefinitionsMarkdownMarkdownTestCases,
  _runLanguagesDefinitionsMdxMdxTestCases.runLanguagesDefinitionsMdxMdxTestCases,
  _runLanguagesDefinitionsMipsMipsTestCases.runLanguagesDefinitionsMipsMipsTestCases,
  _runLanguagesDefinitionsMsdaxMsdaxTestCases.runLanguagesDefinitionsMsdaxMsdaxTestCases,
  _runLanguagesDefinitionsMysqlMysqlTestCases.runLanguagesDefinitionsMysqlMysqlTestCases,
  _runLanguagesDefinitionsObjectiveCObjectiveCTestCases.runLanguagesDefinitionsObjectiveCObjectiveCTestCases,
  _runLanguagesDefinitionsPascalPascalTestCases.runLanguagesDefinitionsPascalPascalTestCases,
  _runLanguagesDefinitionsPascaligoPascaligoTestCases.runLanguagesDefinitionsPascaligoPascaligoTestCases,
  _runLanguagesDefinitionsPerlPerlTestCases.runLanguagesDefinitionsPerlPerlTestCases,
  _runLanguagesDefinitionsPgsqlPgsqlTestCases.runLanguagesDefinitionsPgsqlPgsqlTestCases,
  _runLanguagesDefinitionsPhpPhpTestCases.runLanguagesDefinitionsPhpPhpTestCases,
  _runLanguagesDefinitionsPlaPlaTestCases.runLanguagesDefinitionsPlaPlaTestCases,
  _runLanguagesDefinitionsPostiatsPostiatsTestCases.runLanguagesDefinitionsPostiatsPostiatsTestCases,
  _runLanguagesDefinitionsPowerqueryPowerqueryTestCases.runLanguagesDefinitionsPowerqueryPowerqueryTestCases,
  _runLanguagesDefinitionsPowershellPowershellTestCases.runLanguagesDefinitionsPowershellPowershellTestCases,
  _runLanguagesDefinitionsProtobufProtobufTestCases.runLanguagesDefinitionsProtobufProtobufTestCases,
  _runLanguagesDefinitionsPugPugTestCases.runLanguagesDefinitionsPugPugTestCases,
  _runLanguagesDefinitionsPythonPythonTestCases.runLanguagesDefinitionsPythonPythonTestCases,
  _runLanguagesDefinitionsQsharpQsharpTestCases.runLanguagesDefinitionsQsharpQsharpTestCases,
  _runLanguagesDefinitionsRRTestCases.runLanguagesDefinitionsRRTestCases,
  _runLanguagesDefinitionsRazorRazorTestCases.runLanguagesDefinitionsRazorRazorTestCases,
  _runLanguagesDefinitionsRedisRedisTestCases.runLanguagesDefinitionsRedisRedisTestCases,
  _runLanguagesDefinitionsRedshiftRedshiftTestCases.runLanguagesDefinitionsRedshiftRedshiftTestCases,
  _runLanguagesDefinitionsRestructuredtextRestructuredtextTestCases.runLanguagesDefinitionsRestructuredtextRestructuredtextTestCases,
  _runLanguagesDefinitionsRubyRubyTestCases.runLanguagesDefinitionsRubyRubyTestCases,
  _runLanguagesDefinitionsRustRustTestCases.runLanguagesDefinitionsRustRustTestCases,
  _runLanguagesDefinitionsSbSbTestCases.runLanguagesDefinitionsSbSbTestCases,
  _runLanguagesDefinitionsScalaScalaTestCases.runLanguagesDefinitionsScalaScalaTestCases,
  _runLanguagesDefinitionsSchemeSchemeTestCases.runLanguagesDefinitionsSchemeSchemeTestCases,
  _runLanguagesDefinitionsScssScssTestCases.runLanguagesDefinitionsScssScssTestCases,
  _runLanguagesDefinitionsShellShellTestCases.runLanguagesDefinitionsShellShellTestCases,
  _runLanguagesDefinitionsSoliditySolidityTestCases.runLanguagesDefinitionsSoliditySolidityTestCases,
  _runLanguagesDefinitionsSophiaSophiaTestCases.runLanguagesDefinitionsSophiaSophiaTestCases,
  _runLanguagesDefinitionsSparqlSparqlTestCases.runLanguagesDefinitionsSparqlSparqlTestCases,
  _runLanguagesDefinitionsSqlSqlTestCases.runLanguagesDefinitionsSqlSqlTestCases,
  _runLanguagesDefinitionsStStTestCases.runLanguagesDefinitionsStStTestCases,
  _runLanguagesDefinitionsSwiftSwiftTestCases.runLanguagesDefinitionsSwiftSwiftTestCases,
  _runLanguagesDefinitionsSystemverilogSystemverilogTestCases.runLanguagesDefinitionsSystemverilogSystemverilogTestCases,
  _runLanguagesDefinitionsTclTclTestCases.runLanguagesDefinitionsTclTclTestCases,
  _runLanguagesDefinitionsTwigTwigTestCases1.runLanguagesDefinitionsTwigTwigTestCases1,
  _runLanguagesDefinitionsTwigTwigTestCases2.runLanguagesDefinitionsTwigTwigTestCases2,
  _runLanguagesDefinitionsTypescriptTypescriptTestCases.runLanguagesDefinitionsTypescriptTypescriptTestCases,
  _runLanguagesDefinitionsTypespecTypespecTestCases.runLanguagesDefinitionsTypespecTypespecTestCases,
  _runLanguagesDefinitionsVbVbTestCases.runLanguagesDefinitionsVbVbTestCases,
  _runLanguagesDefinitionsWgslWgslTestCases.runLanguagesDefinitionsWgslWgslTestCases,
  _runLanguagesDefinitionsXmlXmlTestCases.runLanguagesDefinitionsXmlXmlTestCases,
  _runLanguagesDefinitionsYamlYamlTestCases.runLanguagesDefinitionsYamlYamlTestCases,
    ];

    test('all 87 generated datasets invoke testTokenization with valid data', () {
      var calls = 0;
      var items = 0;
      TR.testTokenizationHook = (lang, tests) {
        calls++;
        // Some datasets are intentionally empty (csp/ecl: `testTokenization('x', [])`).
        expect(tests, isA<List<List<TR.ITestItem>>>());
        for (final g in tests) {
          expect(g, isNotEmpty);
          for (final it in g) {
            items++;
            expect(it.line, isA<String>());
            expect(it.tokens, isA<List<TR.IRelaxedToken>>());
          }
        }
      };
      for (final fn in drivers) { fn(); }
      expect(drivers.length, 87);
      expect(calls, 87);
      expect(items, 7043);
    });
  });
}
