// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/snippet/test/browser/snippetParser.test.ts
// Translated 1:1. The mocha suite's 54 cases become Dart functions invoked by
// `runAll()`. `ensureNoDisposablesAreLeakedInTestSuite()` is a suite-level
// harness hook and is intentionally omitted.
//
// Translation notes:
//   - TypeScript `<T>expr` / `expr as T` casts -> Dart `as T` (or implicit).
//   - `instanceof` -> `is`; `assert.ok(x)` -> `assert(x)`.
//   - `RegExp` literals / `new RegExp(src, flags)` -> `JsRegExp.compile(src, flags)`
//     (the published carrier from snippetParser.dart).
//   - anonymous `class implements VariableResolver` -> named private class.
//   - `.walk(cb)` -> `walkMine(cb)`; `walk(list, cb)` stays top-level `walk`.
//   - `undefined` -> `null`; `=== undefined` -> `== null`.
// ---------------------------------------------------------------------------

import 'dart:collection' show HashSet;

import '../../browser/snippetParser.dart';

void assertText(String value, String expected) {
  final String actual = SnippetParser.asInsertText(value);
  assert(actual == expected);
}

void assertMarker(Object input, List<Type> ctors) {
  // input: TextmateSnippet | List<Marker> | String
  List<Marker> marker;
  if (input is TextmateSnippet) {
    marker = List<Marker>.from(input.children);
  } else if (input is String) {
    final SnippetParser p = SnippetParser();
    marker = p.parse(input).children;
  } else {
    marker = List<Marker>.from(input as List<Marker>);
  }
  final List<Type> cs = List<Type>.from(ctors);
  while (marker.isNotEmpty) {
    final Marker m = marker.removeLast();
    final Type ctor = cs.removeLast();
    assert(m.runtimeType == ctor || _isSubtypeOf(m, ctor));
  }
  assert(cs.isEmpty);
  assert(marker.isEmpty);
}

bool _isSubtypeOf(Object obj, Type t) {
  // Dart `is` needs a static Type; use runtimeType checks for the known
  // marker hierarchy. This mirrors TS `instanceof ctor`.
  if (t == Marker) return obj is Marker;
  if (t == Text) return obj is Text;
  if (t == Placeholder) return obj is Placeholder;
  if (t == Choice) return obj is Choice;
  if (t == Variable) return obj is Variable;
  if (t == Transform) return obj is Transform;
  if (t == FormatString) return obj is FormatString;
  if (t == TextmateSnippet) return obj is TextmateSnippet;
  return false;
}

void assertTextAndMarker(String value, String escaped, List<Type> ctors) {
  assertText(value, escaped);
  assertMarker(value, ctors);
}

void assertEscaped(String value, String expected) {
  final String actual = SnippetParser.escape(value);
  assert(actual == expected);
}

void test01_Scanner() {
  final Scanner scanner = Scanner();
  assert(scanner.next().type == TokenType.EOF);

  scanner.text('abc');
  assert(scanner.next().type == TokenType.VariableName);
  assert(scanner.next().type == TokenType.EOF);

  scanner.text('{{abc}}');
  assert(scanner.next().type == TokenType.CurlyOpen);
  assert(scanner.next().type == TokenType.CurlyOpen);
  assert(scanner.next().type == TokenType.VariableName);
  assert(scanner.next().type == TokenType.CurlyClose);
  assert(scanner.next().type == TokenType.CurlyClose);
  assert(scanner.next().type == TokenType.EOF);

  scanner.text('abc() ');
  assert(scanner.next().type == TokenType.VariableName);
  assert(scanner.next().type == TokenType.Format);
  assert(scanner.next().type == TokenType.EOF);

  scanner.text('abc 123');
  assert(scanner.next().type == TokenType.VariableName);
  assert(scanner.next().type == TokenType.Format);
  assert(scanner.next().type == TokenType.Int);
  assert(scanner.next().type == TokenType.EOF);

  scanner.text(r'$foo');
  assert(scanner.next().type == TokenType.Dollar);
  assert(scanner.next().type == TokenType.VariableName);
  assert(scanner.next().type == TokenType.EOF);

  scanner.text(r'$foo_bar');
  assert(scanner.next().type == TokenType.Dollar);
  assert(scanner.next().type == TokenType.VariableName);
  assert(scanner.next().type == TokenType.EOF);

  scanner.text(r'$foo-bar');
  assert(scanner.next().type == TokenType.Dollar);
  assert(scanner.next().type == TokenType.VariableName);
  assert(scanner.next().type == TokenType.Dash);
  assert(scanner.next().type == TokenType.VariableName);
  assert(scanner.next().type == TokenType.EOF);

  scanner.text(r'${foo}');
  assert(scanner.next().type == TokenType.Dollar);
  assert(scanner.next().type == TokenType.CurlyOpen);
  assert(scanner.next().type == TokenType.VariableName);
  assert(scanner.next().type == TokenType.CurlyClose);
  assert(scanner.next().type == TokenType.EOF);

  scanner.text(r'${1223:foo}');
  assert(scanner.next().type == TokenType.Dollar);
  assert(scanner.next().type == TokenType.CurlyOpen);
  assert(scanner.next().type == TokenType.Int);
  assert(scanner.next().type == TokenType.Colon);
  assert(scanner.next().type == TokenType.VariableName);
  assert(scanner.next().type == TokenType.CurlyClose);
  assert(scanner.next().type == TokenType.EOF);

  scanner.text(r'\${}');
  assert(scanner.next().type == TokenType.Backslash);
  assert(scanner.next().type == TokenType.Dollar);
  assert(scanner.next().type == TokenType.CurlyOpen);
  assert(scanner.next().type == TokenType.CurlyClose);

  scanner.text(r'${foo/regex/format/option}');
  assert(scanner.next().type == TokenType.Dollar);
  assert(scanner.next().type == TokenType.CurlyOpen);
  assert(scanner.next().type == TokenType.VariableName);
  assert(scanner.next().type == TokenType.Forwardslash);
  assert(scanner.next().type == TokenType.VariableName);
  assert(scanner.next().type == TokenType.Forwardslash);
  assert(scanner.next().type == TokenType.VariableName);
  assert(scanner.next().type == TokenType.Forwardslash);
  assert(scanner.next().type == TokenType.VariableName);
  assert(scanner.next().type == TokenType.CurlyClose);
  assert(scanner.next().type == TokenType.EOF);
}

void test02_Parser_escaped() {
  assertEscaped(r'foo$0', r'foo\$0');
  assertEscaped(r'foo\$0', r'foo\\\$0');
  assertEscaped(r'f$1oo$0', r'f\$1oo\$0');
  assertEscaped(r'${1:foo}$0', r'\${1:foo\}\$0');
  assertEscaped(r'$', r'\$');
}

void test03_Parser_text() {
  assertText(r'$', r'$');
  assertText(r'\\$', r'\$');
  assertText('{', '{');
  assertText(r'\}', '}');
  assertText(r'\abc', r'\abc');
  assertText(r'foo${f:\}}bar', 'foo}bar');
  assertText(r'\{', r'\{');
  assertText(r'I need \\\$', r'I need \$');
  assertText(r'\', r'\');
  assertText(r'\{{', r'\{{');
  assertText('{{', '{{');
  assertText('{{dd', '{{dd');
  assertText('}}', '}}');
  assertText('ff}}', 'ff}}');

  assertText('farboo', 'farboo');
  assertText('far{{}}boo', 'far{{}}boo');
  assertText('far{{123}}boo', 'far{{123}}boo');
  assertText(r'far\{{123}}boo', r'far\{{123}}boo');
  assertText('far{{id:bern}}boo', 'far{{id:bern}}boo');
  assertText('far{{id:bern {{basel}}}}boo', 'far{{id:bern {{basel}}}}boo');
  assertText('far{{id:bern {{id:basel}}}}boo', 'far{{id:bern {{id:basel}}}}boo');
  assertText('far{{id:bern {{id2:basel}}}}boo', 'far{{id:bern {{id2:basel}}}}boo');
}

void test04_Parser_TM_text() {
  assertTextAndMarker(r'foo${1:bar}}', 'foobar}', <Type>[Text, Placeholder, Text]);
  assertTextAndMarker(r'foo${1:bar}${2:foo}}', 'foobarfoo}', <Type>[Text, Placeholder, Placeholder, Text]);

  assertTextAndMarker(r'foo${1:bar\}${2:foo}}', 'foobar}foo', <Type>[Text, Placeholder]);

  final List<Marker> children = SnippetParser().parse(r'foo${1:bar\}${2:foo}}').children;
  final Placeholder placeholder = children[1] as Placeholder;
  final List<Marker> pc = placeholder.children;

  assert(placeholder.index == 1);
  assert(pc[0] is Text);
  assert(pc[0].toString() == 'bar}');
  assert(pc[1] is Placeholder);
  assert(pc[1].toString() == 'foo');
}

void test05_Parser_placeholder() {
  assertTextAndMarker('farboo', 'farboo', <Type>[Text]);
  assertTextAndMarker('far{{}}boo', 'far{{}}boo', <Type>[Text]);
  assertTextAndMarker('far{{123}}boo', 'far{{123}}boo', <Type>[Text]);
  assertTextAndMarker(r'far\{{123}}boo', r'far\{{123}}boo', <Type>[Text]);
}

void test06_Parser_literal_code() {
  assertTextAndMarker('far`123`boo', 'far`123`boo', <Type>[Text]);
  assertTextAndMarker(r'far\`123\`boo', r'far\`123\`boo', <Type>[Text]);
}

void test07_Parser_variables_tabstop() {
  assertTextAndMarker(r'$far-boo', '-boo', <Type>[Variable, Text]);
  assertTextAndMarker(r'\$far-boo', r'$far-boo', <Type>[Text]);
  assertTextAndMarker(r'far$farboo', 'far', <Type>[Text, Variable]);
  assertTextAndMarker('far\${farboo}', 'far', <Type>[Text, Variable]);
  assertTextAndMarker(r'$123', '', <Type>[Placeholder]);
  assertTextAndMarker(r'$farboo', '', <Type>[Variable]);
  assertTextAndMarker(r'$far12boo', '', <Type>[Variable]);
  assertTextAndMarker(r'000_${far}_000', '000__000', <Type>[Text, Variable, Text]);
  assertTextAndMarker(r'FFF_${TM_SELECTED_TEXT}_FFF$0', 'FFF__FFF', <Type>[Text, Variable, Text, Placeholder]);
}

void test08_Parser_variables_placeholder_defaults() {
  assertTextAndMarker(r'${name:value}', 'value', <Type>[Variable]);
  assertTextAndMarker(r'${1:value}', 'value', <Type>[Placeholder]);
  assertTextAndMarker(r'${1:bar${2:foo}bar}', 'barfoobar', <Type>[Placeholder]);
  assertTextAndMarker(r'${name:value', r'${name:value', <Type>[Text]);
  assertTextAndMarker(r'${1:bar${2:foobar}', r'${1:barfoobar', <Type>[Text, Placeholder]);
}

void test09_Parser_variable_transforms() {
  assertTextAndMarker(r'${foo///}', '', <Type>[Variable]);
  assertTextAndMarker(r'${foo/regex/format/gmi}', '', <Type>[Variable]);
  assertTextAndMarker(r'${foo/([A-Z][a-z])/format/}', '', <Type>[Variable]);

  // invalid regex
  assertTextAndMarker(r'${foo/([A-Z][a-z])/format/GMI}', r'${foo/([A-Z][a-z])/format/GMI}', <Type>[Text]);
  assertTextAndMarker(r'${foo/([A-Z][a-z])/format/funky}', r'${foo/([A-Z][a-z])/format/funky}', <Type>[Text]);
  assertTextAndMarker(r'${foo/([A-Z][a-z]/format/}', r'${foo/([A-Z][a-z]/format/}', <Type>[Text]);

  // tricky regex
  assertTextAndMarker(r'${foo/m\/atch/$1/i}', '', <Type>[Variable]);
  assertMarker(r'${foo/regex\/format/options}', <Type>[Text]);

  // incomplete
  assertTextAndMarker(r'${foo///', r'${foo///', <Type>[Text]);
  assertTextAndMarker(r'${foo/regex/format/options', r'${foo/regex/format/options', <Type>[Text]);

  // format string
  assertMarker(r'${foo/.*/${0:fooo}/i}', <Type>[Variable]);
  assertMarker(r'${foo/.*/${1}/i}', <Type>[Variable]);
  assertMarker(r'${foo/.*/$1/i}', <Type>[Variable]);
  assertMarker(r'${foo/.*/This-$1-encloses/i}', <Type>[Variable]);
  assertMarker(r'${foo/.*/complex${1:else}/i}', <Type>[Variable]);
  assertMarker(r'${foo/.*/complex${1:-else}/i}', <Type>[Variable]);
  assertMarker(r'${foo/.*/complex${1:+if}/i}', <Type>[Variable]);
  assertMarker(r'${foo/.*/complex${1:?if:else}/i}', <Type>[Variable]);
  assertMarker(r'${foo/.*/complex${1:/upcase}/i}', <Type>[Variable]);
}

void test10_Parser_placeholder_transforms() {
  assertTextAndMarker(r'${1///}', '', <Type>[Placeholder]);
  assertTextAndMarker(r'${1/regex/format/gmi}', '', <Type>[Placeholder]);
  assertTextAndMarker(r'${1/([A-Z][a-z])/format/}', '', <Type>[Placeholder]);

  assertTextAndMarker(r'${1/m\/atch/$1/i}', '', <Type>[Placeholder]);
  assertMarker(r'${1/regex\/format/options}', <Type>[Text]);

  assertTextAndMarker(r'${1///', r'${1///', <Type>[Text]);
  assertTextAndMarker(r'${1/regex/format/options', r'${1/regex/format/options', <Type>[Text]);
}

void test11_no_escape_forward_slash_regex() {
  assertMarker(r'${TM_DIRECTORY/src\//$1/}', <Type>[Variable]);
}

void test12_no_escape_forward_slash_format() {
  assertMarker(r'${TM_SELECTED_TEXT/a/\/$1/g}', <Type>[Variable]);
  assertMarker(r'${TM_SELECTED_TEXT/a/in\/$1ner/g}', <Type>[Variable]);
  assertMarker(r'${TM_SELECTED_TEXT/a/end\//g}', <Type>[Variable]);
}

void test13_Parser_placeholder_choice() {
  assertTextAndMarker(r'${1|one,two,three|}', 'one', <Type>[Placeholder]);
  assertTextAndMarker(r'${1|one|}', 'one', <Type>[Placeholder]);
  assertTextAndMarker(r'${1|one1,two2|}', 'one1', <Type>[Placeholder]);
  assertTextAndMarker(r'${1|one1\,two2|}', 'one1,two2', <Type>[Placeholder]);
  assertTextAndMarker(r'${1|one1\|two2|}', 'one1|two2', <Type>[Placeholder]);
  assertTextAndMarker(r'${1|one1\atwo2|}', r'one1\atwo2', <Type>[Placeholder]);
  assertTextAndMarker(r'${1|one,two,three,|}', r'${1|one,two,three,|}', <Type>[Text]);
  assertTextAndMarker(r'${1|one,', r'${1|one,', <Type>[Text]);

  final TextmateSnippet snippet = SnippetParser().parse(r'${1|one,two,three|}');
  final List<bool Function(Marker)> expected = <bool Function(Marker)>[
    (m) => m is Placeholder,
    (m) => m is Choice && m.options.length == 3 && m.options.every((x) => x is Text),
  ];
  snippet.walkMine((Marker marker) {
    assert(expected.removeAt(0)(marker));
    return true;
  });
}

void test14_choices_escape_comma_pipe() {
  assertTextAndMarker(r'console.log(${1|not\, not, five, 5, 1   23|});', 'console.log(not, not);', <Type>[Text, Placeholder, Text]);
}

void test15_toTextmateString() {
  void assertTextsnippetString(String input, String expected) {
    final TextmateSnippet snippet = SnippetParser().parse(input);
    final String actual = snippet.toTextmateString();
    assert(actual == expected);
  }

  assertTextsnippetString(r'$1', r'$1');
  assertTextsnippetString(r'\$1', r'\$1');
  assertTextsnippetString(r'console.log(${1|not\, not, five, 5, 1   23|});', r'console.log(${1|not\, not, five, 5, 1   23|});');
  assertTextsnippetString(r'console.log(${1|not\, not, \| five, 5, 1   23|});', r'console.log(${1|not\, not, \| five, 5, 1   23|});');
  assertTextsnippetString(r'${1|cho\,ices,wi\|th,esc\\aping,chall\\\,enges|}', r'${1|cho\,ices,wi\|th,esc\\aping,chall\\\,enges|}');
  assertTextsnippetString('this is text', 'this is text');
  assertTextsnippetString(r'this ${1:is ${2:nested with $var}}', r'this ${1:is ${2:nested with ${var}}}');
  assertTextsnippetString(r'this ${1:is ${2:nested with $var}}}', r'this ${1:is ${2:nested with ${var}}}\}');
}

void test16_toTextmateString_identity() {
  void assertIdent(String input) {
    final TextmateSnippet snippet = SnippetParser().parse(input);
    final String input2 = snippet.toTextmateString();
    final TextmateSnippet snippet2 = SnippetParser().parse(input2);

    void checkCheckChildren(Marker marker1, Marker marker2) {
      assert(marker1.runtimeType == marker2.runtimeType);
      assert(marker1.children.length == marker2.children.length);
      assert(marker1.toString() == marker2.toString());
      for (int i = 0; i < marker1.children.length; i++) {
        checkCheckChildren(marker1.children[i], marker2.children[i]);
      }
    }

    checkCheckChildren(snippet, snippet2);
  }

  assertIdent(r'$1');
  assertIdent(r'\$1');
  assertIdent(r'console.log(${1|not\, not, five, 5, 1   23|});');
  assertIdent(r'console.log(${1|not\, not, \| five, 5, 1   23|});');
  assertIdent('this is text');
  assertIdent(r'this ${1:is ${2:nested with $var}}');
  assertIdent(r'this ${1:is ${2:nested with $var}}}');
  assertIdent(r'this ${1:is ${2:nested with $var}} and repeating $1');
}

void test17_choice_marker() {
  final TextmateSnippet snippet = SnippetParser().parse(r'${1|one,two,three|}');
  final List<Placeholder> placeholders = snippet.placeholders;
  assert(placeholders.length == 1);
  assert(placeholders[0].choice is Choice);
  assert(placeholders[0].children[0] is Choice);
  assert((placeholders[0].children[0] as Choice).options.length == 3);

  assertText(r'${1|one,two,three|}', 'one');
  assertText(r'\${1|one,two,three|}', r'${1|one,two,three|}');
  assertText(r'${1\|one,two,three|}', r'${1\|one,two,three|}');
  assertText(r'${1||}', r'${1||}');
}

void test18_backslash_escape_choice() {
  final List<Placeholder> placeholders = SnippetParser().parse(r'${1|\,,},$,\|,\\|}').placeholders;
  assert(placeholders.length == 1);
  assert(placeholders[0].choice is Choice);
}

void test19_only_textmate() {
  final SnippetParser p = SnippetParser();
  assertMarker(p.parse('far{{}}boo'), <Type>[Text]);
  assertMarker(p.parse('far{{123}}boo'), <Type>[Text]);
  assertMarker(p.parse(r'far\{{123}}boo'), <Type>[Text]);
  assertMarker(p.parse(r'far$0boo'), <Type>[Text, Placeholder, Text]);
  assertMarker(p.parse(r'far${123}boo'), <Type>[Text, Placeholder, Text]);
  assertMarker(p.parse(r'far\${123}boo'), <Type>[Text]);
}

void test20_real_world() {
  List<Marker> marker = SnippetParser().parse(r'console.warn(${1: $TM_SELECTED_TEXT })').children;
  assert(marker[0].toString() == 'console.warn(');
  assert(marker[1] is Placeholder);
  assert(marker[2].toString() == ')');

  final Placeholder placeholder = marker[1] as Placeholder;
  assert(placeholder.index == 1);
  assert(placeholder.children.length == 3);
  assert(placeholder.children[0] is Text);
  assert(placeholder.children[1] is Variable);
  assert(placeholder.children[2] is Text);
  assert(placeholder.children[0].toString() == ' ');
  assert(placeholder.children[1].toString() == '');
  assert(placeholder.children[2].toString() == ' ');

  final Variable nestedVariable = placeholder.children[1] as Variable;
  assert(nestedVariable.name == 'TM_SELECTED_TEXT');
  assert(nestedVariable.children.length == 0);

  marker = SnippetParser().parse(r'$TM_SELECTED_TEXT').children;
  assert(marker.length == 1);
  assert(marker[0] is Variable);
}

void test21_transform_example() {
  final TextmateSnippet snippet = SnippetParser().parse('\${1:name} : \${2:type}\${3/\\s:=(.*)/\${1:+ :=}\${1}/};\n\$0');
  final List<Marker> children = snippet.children;

  assert(children[0] is Placeholder);
  assert(children[0].children.length == 1);
  assert(children[0].children[0].toString() == 'name');
  assert((children[0] as Placeholder).transform == null);

  assert(children[1] is Text);
  assert(children[1].toString() == ' : ');

  assert(children[2] is Placeholder);
  assert(children[2].children.length == 1);
  assert(children[2].children[0].toString() == 'type');

  assert(children[3] is Placeholder);
  assert(children[3].children.length == 0);
  assert((children[3] as Placeholder).transform != null);
  final Transform transform = (children[3] as Placeholder).transform!;
  assert(transform.regexp.source == r'\s:=(.*)');
  assert(transform.children.length == 2);
  assert(transform.children[0] is FormatString);
  assert((transform.children[0] as FormatString).index == 1);
  assert((transform.children[0] as FormatString).ifValue == ' :=');
  assert(transform.children[1] is FormatString);
  assert((transform.children[1] as FormatString).index == 1);
  assert(children[4] is Text);
  assert(children[4].toString() == ';\n');
}

void test22_default_placeholder_values() {
  assertMarker(r'errorContext: `${1:err}`, error: $1', <Type>[Text, Placeholder, Text, Placeholder]);

  final List<Marker> children = SnippetParser().parse(r'errorContext: `${1:err}`, error:$1').children;
  final Placeholder p1 = children[1] as Placeholder;
  final Placeholder p2 = children[3] as Placeholder;

  assert(p1.index == 1);
  assert(p1.children.length == 1);
  assert((p1.children[0] as Text).toString() == 'err');

  assert(p2.index == 1);
  assert(p2.children.length == 1);
  assert((p2.children[0] as Text).toString() == 'err');
}

void test23_default_placeholder_one_transform() {
  assertMarker(r'errorContext: `${1:err}`, error: ${1/err/ok/}', <Type>[Text, Placeholder, Text, Placeholder]);

  final List<Marker> children = SnippetParser().parse(r'errorContext: `${1:err}`, error:${1/err/ok/}').children;
  final Placeholder p3 = children[1] as Placeholder;
  final Placeholder p4 = children[3] as Placeholder;

  assert(p3.index == 1);
  assert(p3.children.length == 1);
  assert((p3.children[0] as Text).toString() == 'err');
  assert(p3.transform == null);

  assert(p4.index == 1);
  assert(p4.children.length == 1);
  assert((p4.children[0] as Text).toString() == 'err');
  assert(p4.transform != null);
}

void test24_repeated_placeholder_inherit() {
  assertText(r'${1:foo}-abc-$1', 'foo-abc-foo');
  assertText(r'${1:foo}-abc-${1}', 'foo-abc-foo');
  assertText(r'${1:foo}-abc-${1:bar}', 'foo-abc-foo');
  assertText(r'${1}-abc-${1:foo}', 'foo-abc-foo');
}

void test25_backspace_escape_tm_only() {
  final String actual = SnippetParser.asInsertText(r'Foo \\${abc}bar');
  assert(actual == r'Foo \bar');
}

void test26_colon_as_variable_value() {
  String actual = SnippetParser.asInsertText(r'${TM_SELECTED_TEXT:foo:bar}');
  assert(actual == 'foo:bar');
  actual = SnippetParser.asInsertText(r'${1:foo:bar}');
  assert(actual == 'foo:bar');
}

void test27_incomplete_placeholder() {
  assertTextAndMarker(r'${1:}', '', <Type>[Placeholder]);
}

void test28_marker_len() {
  void assertLen(String template, List<int> lengths) {
    final List<int> l = List<int>.from(lengths);
    final TextmateSnippet snippet = SnippetParser().parse(template, true);
    snippet.walkMine((Marker m) {
      final int expected = l.removeAt(0);
      assert(m.len() == expected);
      return true;
    });
    assert(l.isEmpty);
  }

  assertLen(r'text$0', <int>[4, 0]);
  assertLen(r'$1text$0', <int>[0, 4, 0]);
  assertLen(r'te$1xt$0', <int>[2, 0, 2, 0]);
  assertLen(r'errorContext: `${1:err}`, error: $0', <int>[15, 0, 3, 10, 0]);
  assertLen(r'errorContext: `${1:err}`, error: $1$0', <int>[15, 0, 3, 10, 0, 3, 0]);
  assertLen(r'$TM_SELECTED_TEXT$0', <int>[0, 0]);
  assertLen(r'${TM_SELECTED_TEXT:def}$0', <int>[0, 3, 0]);
}

void test29_parent_node() {
  TextmateSnippet snippet = SnippetParser().parse(r'This ${1:is ${2:nested}}$0', true);
  assert(snippet.placeholders.length == 3);
  Placeholder first = snippet.placeholders[0];
  Placeholder second = snippet.placeholders[1];
  assert(first.index == 1);
  assert(second.index == 2);
  assert(second.parent == first);
  assert(first.parent == snippet);

  snippet = SnippetParser().parse(r'${VAR:default${1:value}}$0', true);
  assert(snippet.placeholders.length == 2);
  first = snippet.placeholders[0];
  assert(first.index == 1);
  assert(snippet.children[0] is Variable);
  assert(first.parent == snippet.children[0]);
}

void test30_enclosing_placeholders() {
  final TextmateSnippet snippet = SnippetParser().parse(r'This ${1:is ${2:nested}}$0', true);
  final Placeholder first = snippet.placeholders[0];
  final Placeholder second = snippet.placeholders[1];
  assert(snippet.enclosingPlaceholders(first).isEmpty);
  final List<Placeholder> e = snippet.enclosingPlaceholders(second);
  assert(e.length == 1 && e[0] == first);
}

void test31_offset() {
  TextmateSnippet snippet = SnippetParser().parse(r'te$1xt', true);
  assert(snippet.offset(snippet.children[0]) == 0);
  assert(snippet.offset(snippet.children[1]) == 2);
  assert(snippet.offset(snippet.children[2]) == 2);

  snippet = SnippetParser().parse(r'${TM_SELECTED_TEXT:def}', true);
  assert(snippet.offset(snippet.children[0]) == 0);
  assert(snippet.offset((snippet.children[0] as Variable).children[0]) == 0);

  // foreign marker
  assert(snippet.offset(Text('foo')) == -1);
}

void test32_placeholder_list() {
  TextmateSnippet snippet = SnippetParser().parse(r'te$1xt$0', true);
  assert(snippet.placeholders.length == 2);
  snippet = SnippetParser().parse(r'te$1xt$1$0', true);
  assert(snippet.placeholders.length == 3);
  snippet = SnippetParser().parse(r'te$1xt$2$0', true);
  assert(snippet.placeholders.length == 3);
  snippet = SnippetParser().parse(r'${1:bar${2:foo}bar}$0', true);
  assert(snippet.placeholders.length == 3);
}

void test33_replace_1() {
  final TextmateSnippet snippet = SnippetParser().parse(r'aaa${1:bbb${2:ccc}}$0', true);
  assert(snippet.placeholders.length == 3);
  final Placeholder second = snippet.placeholders[1];
  assert(second.index == 2);

  final List<Placeholder> enclosing = snippet.enclosingPlaceholders(second);
  assert(enclosing.length == 1);
  assert(enclosing[0].index == 1);

  final TextmateSnippet nested = SnippetParser().parse(r'ddd$1eee$0', true);
  snippet.replace(second, nested.children);

  assert(snippet.toString() == 'aaabbbdddeee');
  assert(snippet.placeholders.length == 4);
  assert(snippet.placeholders[0].index == 1);
  assert(snippet.placeholders[1].index == 1);
  assert(snippet.placeholders[2].index == 0);
  assert(snippet.placeholders[3].index == 0);

  final List<Placeholder> newEnclosing = snippet.enclosingPlaceholders(snippet.placeholders[1]);
  assert(newEnclosing[0] == snippet.placeholders[0]);
  assert(newEnclosing.length == 1);
  assert(newEnclosing[0].index == 1);
}

void test34_replace_2() {
  final TextmateSnippet snippet = SnippetParser().parse(r'aaa${1:bbb${2:ccc}}$0', true);
  assert(snippet.placeholders.length == 3);
  final Placeholder second = snippet.placeholders[1];
  assert(second.index == 2);

  final TextmateSnippet nested = SnippetParser().parse(r'dddeee$0', true);
  snippet.replace(second, nested.children);

  assert(snippet.toString() == 'aaabbbdddeee');
  assert(snippet.placeholders.length == 3);
}

void test35_snippet_order() {
  final Placeholder p10 = Placeholder(10);
  final Placeholder p2 = Placeholder(2);
  assert(Placeholder.compareByIndex(p10, p2) == 1);
}

void test36_max_call_stack() {
  SnippetParser().parse(r'${1:${foo:${1}}}');
}

void test37_snippet_freeze() {
  final HashSet<Marker> seen = HashSet<Marker>();

  seen.clear();
  SnippetParser().parse(r'class ${1:${TM_FILENAME/(?:\A|_)([A-Za-z0-9]+)(?:\.rb)?/(?2::\u$1)/g}} < ${2:Application}Controller\n  $3\nend').walkMine((Marker marker) {
    assert(!seen.contains(marker));
    seen.add(marker);
    return true;
  });

  seen.clear();
  SnippetParser().parse(r'${1:${FOO:abc$1def}}').walkMine((Marker marker) {
    assert(!seen.contains(marker));
    seen.add(marker);
    return true;
  });
}

void test38_ignore_zero_choice() {
  assertTextAndMarker(r'${0|foo,bar|}', r'${0|foo,bar|}', <Type>[Text]);
  assertTextAndMarker(r'${1|foo,bar|}', 'foo', <Type>[Placeholder]);
}

void test39_format_string_resolve() {
  // shorthand functions
  assert(FormatString(1, 'upcase').resolve('foo') == 'FOO');
  assert(FormatString(1, 'downcase').resolve('FOO') == 'foo');
  assert(FormatString(1, 'capitalize').resolve('bar') == 'Bar');
  assert(FormatString(1, 'capitalize').resolve('bar no repeat') == 'Bar no repeat');
  assert(FormatString(1, 'pascalcase').resolve('bar-foo') == 'BarFoo');
  assert(FormatString(1, 'pascalcase').resolve('bar-42-foo') == 'Bar42Foo');
  assert(FormatString(1, 'pascalcase').resolve('snake_AndPascalCase') == 'SnakeAndPascalCase');
  assert(FormatString(1, 'pascalcase').resolve('kebab-AndPascalCase') == 'KebabAndPascalCase');
  assert(FormatString(1, 'pascalcase').resolve('_justPascalCase') == 'JustPascalCase');
  assert(FormatString(1, 'camelcase').resolve('bar-foo') == 'barFoo');
  assert(FormatString(1, 'camelcase').resolve('bar-42-foo') == 'bar42Foo');
  assert(FormatString(1, 'camelcase').resolve('snake_AndCamelCase') == 'snakeAndCamelCase');
  assert(FormatString(1, 'camelcase').resolve('kebab-AndCamelCase') == 'kebabAndCamelCase');
  assert(FormatString(1, 'camelcase').resolve('_JustCamelCase') == 'justCamelCase');
  assert(FormatString(1, 'kebabcase').resolve('barFoo') == 'bar-foo');
  assert(FormatString(1, 'kebabcase').resolve('BarFoo') == 'bar-foo');
  assert(FormatString(1, 'kebabcase').resolve('ABarFoo') == 'a-bar-foo');
  assert(FormatString(1, 'kebabcase').resolve('bar42Foo') == 'bar42-foo');
  assert(FormatString(1, 'kebabcase').resolve('snake_AndPascalCase') == 'snake-and-pascal-case');
  assert(FormatString(1, 'kebabcase').resolve('kebab-AndCamelCase') == 'kebab-and-camel-case');
  assert(FormatString(1, 'kebabcase').resolve('_justPascalCase') == 'just-pascal-case');
  assert(FormatString(1, 'kebabcase').resolve('__UPCASE__') == 'upcase');
  assert(FormatString(1, 'kebabcase').resolve('__BAR_FOO__') == 'bar-foo');
  assert(FormatString(1, 'snakecase').resolve('bar-foo') == 'bar_foo');
  assert(FormatString(1, 'snakecase').resolve('bar-42-foo') == 'bar_42_foo');
  assert(FormatString(1, 'snakecase').resolve('snake_AndPascalCase') == 'snake_and_pascal_case');
  assert(FormatString(1, 'snakecase').resolve('kebab-AndPascalCase') == 'kebab_and_pascal_case');
  assert(FormatString(1, 'snakecase').resolve('_justPascalCase') == '_just_pascal_case');
  assert(FormatString(1, 'notKnown').resolve('input') == 'input');

  // if
  assert(FormatString(1, null, 'foo', null).resolve() == '');
  assert(FormatString(1, null, 'foo', null).resolve('') == '');
  assert(FormatString(1, null, 'foo', null).resolve('bar') == 'foo');

  // else
  assert(FormatString(1, null, null, 'foo').resolve() == 'foo');
  assert(FormatString(1, null, null, 'foo').resolve('') == 'foo');
  assert(FormatString(1, null, null, 'foo').resolve('bar') == 'bar');

  // if-else
  assert(FormatString(1, null, 'bar', 'foo').resolve() == 'foo');
  assert(FormatString(1, null, 'bar', 'foo').resolve('') == 'foo');
  assert(FormatString(1, null, 'bar', 'foo').resolve('baz') == 'bar');
}

class _UnicodeResolver implements VariableResolver {
  static const Map<String, String> _values = <String, String>{
    'RUSSIAN': 'одинДва',
    'GREEK': 'έναςΔύο',
    'TURKISH': 'istanbulLı',
    'JAPANESE': 'こんにちは',
  };
  @override
  String? resolve(Variable variable) => _values[variable.name];
}

void test40_unicode_transformations() {
  final VariableResolver resolver = _UnicodeResolver();

  void assertTransform(String transformName, String varName, String expected) {
    final SnippetParser p = SnippetParser();
    final TextmateSnippet snippet = p.parse(r'${' + varName + r'/(.*)/${1:/' + transformName + r'}/}');
    final Variable variable = snippet.children[0] as Variable;
    variable.resolve(resolver);
    final String resolved = variable.toString();
    assert(resolved == expected);
  }

  assertTransform('kebabcase', 'RUSSIAN', 'один-два');
  assertTransform('kebabcase', 'GREEK', 'ένας-δύο');
  assertTransform('snakecase', 'RUSSIAN', 'один_два');
  assertTransform('snakecase', 'GREEK', 'ένας_δύο');
  assertTransform('camelcase', 'RUSSIAN', 'одинДва');
  assertTransform('camelcase', 'GREEK', 'έναςΔύο');
  assertTransform('pascalcase', 'RUSSIAN', 'ОдинДва');
  assertTransform('pascalcase', 'GREEK', 'ΈναςΔύο');
  assertTransform('upcase', 'RUSSIAN', 'ОДИНДВА');
  assertTransform('downcase', 'RUSSIAN', 'одиндва');
  assertTransform('kebabcase', 'TURKISH', 'istanbul-lı');
  assertTransform('pascalcase', 'TURKISH', 'IstanbulLı');
  assertTransform('upcase', 'JAPANESE', 'こんにちは');
  assertTransform('kebabcase', 'JAPANESE', 'こんにちは');
}

void test41_complex_regex_dollar() {
  final TextmateSnippet snippet = SnippetParser().parse(r'const fileName = "${TM_FILENAME/(.*)\..+$/$1/}"');
  assert(snippet.toTextmateString() == r'const fileName = "${TM_FILENAME/(.*)\..+$/${1}/}"');
}

void test42_html_attribute_end_position() {
  final TextmateSnippet snippet = SnippetParser().parse(r'src="$1"', true);
  final List<Placeholder> placeholders = snippet.placeholders;
  assert(placeholders.length == 2);
  assert(placeholders[0].index == 1);
  assert(placeholders[1].index == 0);
}

void test43_optional_transform_reuse() {
  final Transform transform = Transform();
  transform.appendChild(FormatString(1, 'upcase'));
  transform.appendChild(FormatString(2, 'upcase'));
  transform.regexp = JsRegExp.compile(r'^(.)|-(.)', 'g')!;

  assert(transform.resolve('my-file-name') == 'MyFileName');

  final Transform clone = transform.clone();
  assert(clone.resolve('my-file-name') == 'MyFileName');
}

void test44_problem_regex_40570() {
  final TextmateSnippet snippet = SnippetParser().parse(r'${TM_DIRECTORY/.*src[\/](.*)/$1/}');
  assertMarker(snippet, <Type>[Variable]);
}

void test45_undefined_var_transform() {
  final Transform transform = Transform();
  transform.appendChild(Text('bar'));
  transform.regexp = JsRegExp.compile('foo', 'gi')!;
  assert(transform.toTextmateString() == '/foo/bar/ig');
}

void test46_transform_serialization_no_comma() {
  final Transform transformWithFormatString = Transform();
  transformWithFormatString.appendChild(FormatString(1, 'upcase'));
  transformWithFormatString.appendChild(Text('_'));
  transformWithFormatString.regexp = JsRegExp.compile('foo', 'g')!;
  final String serialized = transformWithFormatString.toTextmateString();
  assert(serialized == r'/foo/${1:/upcase}_/g');

  final TextmateSnippet snippet = SnippetParser().parse(r'${TM_FILENAME' + serialized + r'}');
  assert(snippet.toTextmateString() == r'${TM_FILENAME' + serialized + r'}');
}

void test47_parser_freeze_53144() {
  final TextmateSnippet snippet = SnippetParser().parse(r'${1/(void$)|(.+)/${1:?-\treturn nil;}/}');
  assertMarker(snippet, <Type>[Placeholder]);
}

void test48_variable_json_proposal() {
  assertTextAndMarker(r'FOO${1:/bin/bash}', 'FOO/bin/bash', <Type>[Text, Placeholder]);
}

void test49_nested_placeholder_backjump() {
  final TextmateSnippet snippet = SnippetParser().parse(r'${3:nest1 ${1:nest2 ${2:nest3}}} $3');
  assert(snippet.children.length == 3);
  assert(snippet.children[0] is Placeholder);
  assert(snippet.children[1] is Text);
  assert(snippet.children[2] is Placeholder);

  void assertParent(Marker marker) {
    for (final Marker c in marker.children) {
      assertParent(c);
    }
    if (marker is! Placeholder) {
      return;
    }
    bool found = false;
    Marker m = marker;
    while (!found) {
      if (m.parent == snippet) {
        found = true;
      }
      final Marker? p = m.parent;
      if (p == null) break;
      m = p;
    }
    assert(found);
  }

  assertParent(snippet.children[2]);
}

void test50_backspace_cant_escape() {
  final TextmateSnippet snippet = SnippetParser().parse(r'namespace ${TM_DIRECTORY/[\/]/\\/g};');
  assertMarker(snippet, <Type>[Text, Variable, Text]);
}

void test51_escape_closing_bracket() {
  final TextmateSnippet snippet = SnippetParser().parse(r'${TM_DIRECTORY/(.+)/${1:+import { hello \} from world}/}');
  final Variable variable = snippet.children[0] as Variable;
  assert(snippet.children.length == 1);
  assert(variable is Variable);
  assert(variable.transform != null);
  assert(variable.transform!.children.length == 1);
  assert(variable.transform!.children[0] is FormatString);
  assert((variable.transform!.children[0] as FormatString).ifValue == 'import { hello } from world');
  assert((variable.transform!.children[0] as FormatString).elseValue == null);
}

void test52_escape_backslashes_conditional() {
  final TextmateSnippet snippet = SnippetParser().parse(r'${CURRENT_YEAR/(.+)/${1:+\\}/}');
  final Variable variable = snippet.children[0] as Variable;
  assert(snippet.children.length == 1);
  assert(variable is Variable);
  assert(variable.transform != null);
  assert(variable.transform!.children.length == 1);
  assert(variable.transform!.children[0] is FormatString);
  assert((variable.transform!.children[0] as FormatString).ifValue == '\\');
  assert((variable.transform!.children[0] as FormatString).elseValue == null);
}

void test53_placeholder_empty_after_expansion() {
  TextmateSnippet snippet = SnippetParser().parse(r'${1:prog}: ${2:$1.cc} - $2');
  assert(snippet.toString() == 'prog: prog.cc - prog.cc');

  snippet = SnippetParser().parse(r'${1:prog}: ${3:${2:$1.cc}.33} - $2 $3');
  assert(snippet.toString() == 'prog: prog.cc.33 - prog.cc prog.cc.33');

  // cyclic references of placeholders
  snippet = SnippetParser().parse(r'${1:$2.one} <> ${2:$1.two}');
  assert(snippet.toString() == '.two.one.two.one <> .one.two.one.two');
}

void test54_choices_escaped() {
  assertTextAndMarker(r'${1|aaa$aaa|}bbb\$bbb', r'aaa$aaabbb$bbb', <Type>[Placeholder, Text]);
}

void runAll() {
  test01_Scanner();
  test02_Parser_escaped();
  test03_Parser_text();
  test04_Parser_TM_text();
  test05_Parser_placeholder();
  test06_Parser_literal_code();
  test07_Parser_variables_tabstop();
  test08_Parser_variables_placeholder_defaults();
  test09_Parser_variable_transforms();
  test10_Parser_placeholder_transforms();
  test11_no_escape_forward_slash_regex();
  test12_no_escape_forward_slash_format();
  test13_Parser_placeholder_choice();
  test14_choices_escape_comma_pipe();
  test15_toTextmateString();
  test16_toTextmateString_identity();
  test17_choice_marker();
  test18_backslash_escape_choice();
  test19_only_textmate();
  test20_real_world();
  test21_transform_example();
  test22_default_placeholder_values();
  test23_default_placeholder_one_transform();
  test24_repeated_placeholder_inherit();
  test25_backspace_escape_tm_only();
  test26_colon_as_variable_value();
  test27_incomplete_placeholder();
  test28_marker_len();
  test29_parent_node();
  test30_enclosing_placeholders();
  test31_offset();
  test32_placeholder_list();
  test33_replace_1();
  test34_replace_2();
  test35_snippet_order();
  test36_max_call_stack();
  test37_snippet_freeze();
  test38_ignore_zero_choice();
  test39_format_string_resolve();
  test40_unicode_transformations();
  test41_complex_regex_dollar();
  test42_html_attribute_end_position();
  test43_optional_transform_reuse();
  test44_problem_regex_40570();
  test45_undefined_var_transform();
  test46_transform_serialization_no_comma();
  test47_parser_freeze_53144();
  test48_variable_json_proposal();
  test49_nested_placeholder_backjump();
  test50_backspace_cant_escape();
  test51_escape_closing_bracket();
  test52_escape_backslashes_conditional();
  test53_placeholder_empty_after_expansion();
  test54_choices_escaped();
}
