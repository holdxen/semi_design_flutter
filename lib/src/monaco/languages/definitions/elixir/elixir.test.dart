// Generated 1:1 from languages/definitions/elixir/elixir.test.ts
// Data-only tokenization test (TS runtime truth via _node_toktest_extract.cjs).
library;
import '../test/testRunner.dart' as TR;

/// testTokenization('elixir')
void runLanguagesDefinitionsElixirElixirTestCases() {
  TR.testTokenization('elixir', <List<TR.ITestItem>>[
    <TR.ITestItem>[
      TR.ITestItem(
        'defmodule Foo do end',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.declaration.elixir'),
          TR.IRelaxedToken(9, 'white.elixir'),
          TR.IRelaxedToken(10, 'type.identifier.elixir'),
          TR.IRelaxedToken(13, 'white.elixir'),
          TR.IRelaxedToken(14, 'keyword.elixir'),
          TR.IRelaxedToken(16, 'white.elixir'),
          TR.IRelaxedToken(17, 'keyword.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'def foo(x) do end',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.declaration.elixir'),
          TR.IRelaxedToken(3, 'white.elixir'),
          TR.IRelaxedToken(4, 'function.elixir'),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.elixir'),
          TR.IRelaxedToken(8, 'identifier.elixir'),
          TR.IRelaxedToken(9, 'delimiter.parenthesis.elixir'),
          TR.IRelaxedToken(10, 'white.elixir'),
          TR.IRelaxedToken(11, 'keyword.elixir'),
          TR.IRelaxedToken(13, 'white.elixir'),
          TR.IRelaxedToken(14, 'keyword.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'defmacro mac(name) do quote do def unquote(name)() do nil end end end',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.declaration.elixir'),
          TR.IRelaxedToken(8, 'white.elixir'),
          TR.IRelaxedToken(9, 'function.elixir'),
          TR.IRelaxedToken(12, 'delimiter.parenthesis.elixir'),
          TR.IRelaxedToken(13, 'identifier.elixir'),
          TR.IRelaxedToken(17, 'delimiter.parenthesis.elixir'),
          TR.IRelaxedToken(18, 'white.elixir'),
          TR.IRelaxedToken(19, 'keyword.elixir'),
          TR.IRelaxedToken(21, 'white.elixir'),
          TR.IRelaxedToken(22, 'keyword.elixir'),
          TR.IRelaxedToken(27, 'white.elixir'),
          TR.IRelaxedToken(28, 'keyword.elixir'),
          TR.IRelaxedToken(30, 'white.elixir'),
          TR.IRelaxedToken(31, 'keyword.declaration.elixir'),
          TR.IRelaxedToken(34, 'white.elixir'),
          TR.IRelaxedToken(35, 'keyword.elixir'),
          TR.IRelaxedToken(42, 'delimiter.parenthesis.elixir'),
          TR.IRelaxedToken(43, 'identifier.elixir'),
          TR.IRelaxedToken(47, 'delimiter.parenthesis.elixir'),
          TR.IRelaxedToken(50, 'white.elixir'),
          TR.IRelaxedToken(51, 'keyword.elixir'),
          TR.IRelaxedToken(53, 'white.elixir'),
          TR.IRelaxedToken(54, 'constant.language.elixir'),
          TR.IRelaxedToken(57, 'white.elixir'),
          TR.IRelaxedToken(58, 'keyword.elixir'),
          TR.IRelaxedToken(61, 'white.elixir'),
          TR.IRelaxedToken(62, 'keyword.elixir'),
          TR.IRelaxedToken(65, 'white.elixir'),
          TR.IRelaxedToken(66, 'keyword.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'nil # comment',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'constant.language.elixir'),
          TR.IRelaxedToken(3, 'white.elixir'),
          TR.IRelaxedToken(4, 'comment.punctuation.elixir'),
          TR.IRelaxedToken(5, 'comment.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '["key": value]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.square.elixir'),
          TR.IRelaxedToken(1, 'constant.delimiter.elixir'),
          TR.IRelaxedToken(2, 'constant.elixir'),
          TR.IRelaxedToken(5, 'constant.delimiter.elixir'),
          TR.IRelaxedToken(7, 'white.elixir'),
          TR.IRelaxedToken(8, 'identifier.elixir'),
          TR.IRelaxedToken(13, 'delimiter.square.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '["a#{"b"}c": 1, \'k#{x}\': 2]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.square.elixir'),
          TR.IRelaxedToken(1, 'constant.delimiter.elixir'),
          TR.IRelaxedToken(2, 'constant.elixir'),
          TR.IRelaxedToken(3, 'delimiter.bracket.embed.elixir'),
          TR.IRelaxedToken(5, 'string.delimiter.elixir'),
          TR.IRelaxedToken(6, 'string.elixir'),
          TR.IRelaxedToken(7, 'string.delimiter.elixir'),
          TR.IRelaxedToken(8, 'delimiter.bracket.embed.elixir'),
          TR.IRelaxedToken(9, 'constant.elixir'),
          TR.IRelaxedToken(10, 'constant.delimiter.elixir'),
          TR.IRelaxedToken(12, 'white.elixir'),
          TR.IRelaxedToken(13, 'number.elixir'),
          TR.IRelaxedToken(14, 'punctuation.elixir'),
          TR.IRelaxedToken(15, 'white.elixir'),
          TR.IRelaxedToken(16, 'constant.delimiter.elixir'),
          TR.IRelaxedToken(17, 'constant.elixir'),
          TR.IRelaxedToken(18, 'delimiter.bracket.embed.elixir'),
          TR.IRelaxedToken(20, 'identifier.elixir'),
          TR.IRelaxedToken(21, 'delimiter.bracket.embed.elixir'),
          TR.IRelaxedToken(22, 'constant.delimiter.elixir'),
          TR.IRelaxedToken(24, 'white.elixir'),
          TR.IRelaxedToken(25, 'number.elixir'),
          TR.IRelaxedToken(26, 'delimiter.square.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"#{a}#{a}#{a}:',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.delimiter.elixir'),
          TR.IRelaxedToken(1, 'delimiter.bracket.embed.elixir'),
          TR.IRelaxedToken(3, 'identifier.elixir'),
          TR.IRelaxedToken(4, 'delimiter.bracket.embed.elixir'),
          TR.IRelaxedToken(7, 'identifier.elixir'),
          TR.IRelaxedToken(8, 'delimiter.bracket.embed.elixir'),
          TR.IRelaxedToken(11, 'identifier.elixir'),
          TR.IRelaxedToken(12, 'delimiter.bracket.embed.elixir'),
          TR.IRelaxedToken(13, 'string.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '[1,1.23,1.23e-10,0xab,0o171,0b01001]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.square.elixir'),
          TR.IRelaxedToken(1, 'number.elixir'),
          TR.IRelaxedToken(2, 'punctuation.elixir'),
          TR.IRelaxedToken(3, 'number.float.elixir'),
          TR.IRelaxedToken(7, 'punctuation.elixir'),
          TR.IRelaxedToken(8, 'number.float.elixir'),
          TR.IRelaxedToken(16, 'punctuation.elixir'),
          TR.IRelaxedToken(17, 'number.hex.elixir'),
          TR.IRelaxedToken(21, 'punctuation.elixir'),
          TR.IRelaxedToken(22, 'number.octal.elixir'),
          TR.IRelaxedToken(27, 'punctuation.elixir'),
          TR.IRelaxedToken(28, 'number.binary.elixir'),
          TR.IRelaxedToken(35, 'delimiter.square.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'def foo(_x) do _y = 1 end',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.declaration.elixir'),
          TR.IRelaxedToken(3, 'white.elixir'),
          TR.IRelaxedToken(4, 'function.elixir'),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.elixir'),
          TR.IRelaxedToken(8, 'comment.unused.elixir'),
          TR.IRelaxedToken(10, 'delimiter.parenthesis.elixir'),
          TR.IRelaxedToken(11, 'white.elixir'),
          TR.IRelaxedToken(12, 'keyword.elixir'),
          TR.IRelaxedToken(14, 'white.elixir'),
          TR.IRelaxedToken(15, 'comment.unused.elixir'),
          TR.IRelaxedToken(17, 'white.elixir'),
          TR.IRelaxedToken(18, 'operator.elixir'),
          TR.IRelaxedToken(19, 'white.elixir'),
          TR.IRelaxedToken(20, 'number.elixir'),
          TR.IRelaxedToken(21, 'white.elixir'),
          TR.IRelaxedToken(22, 'keyword.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo(x)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'function.call.elixir'),
          TR.IRelaxedToken(3, 'delimiter.parenthesis.elixir'),
          TR.IRelaxedToken(4, 'identifier.elixir'),
          TR.IRelaxedToken(5, 'delimiter.parenthesis.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'foo.()',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'function.call.elixir'),
          TR.IRelaxedToken(3, 'operator.elixir'),
          TR.IRelaxedToken(4, 'delimiter.parenthesis.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'Mod.foo()',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'type.identifier.elixir'),
          TR.IRelaxedToken(3, 'operator.elixir'),
          TR.IRelaxedToken(4, 'function.call.elixir'),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ':mo.foo()',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'constant.punctuation.elixir'),
          TR.IRelaxedToken(1, 'constant.elixir'),
          TR.IRelaxedToken(3, 'operator.elixir'),
          TR.IRelaxedToken(4, 'function.call.elixir'),
          TR.IRelaxedToken(7, 'delimiter.parenthesis.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '1 |> abs()',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'number.elixir'),
          TR.IRelaxedToken(1, 'white.elixir'),
          TR.IRelaxedToken(2, 'operator.elixir'),
          TR.IRelaxedToken(4, 'white.elixir'),
          TR.IRelaxedToken(5, 'function.call.elixir'),
          TR.IRelaxedToken(8, 'delimiter.parenthesis.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '&max(&1,&2)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'operator.elixir'),
          TR.IRelaxedToken(1, 'function.call.elixir'),
          TR.IRelaxedToken(4, 'delimiter.parenthesis.elixir'),
          TR.IRelaxedToken(5, 'operator.elixir'),
          TR.IRelaxedToken(7, 'punctuation.elixir'),
          TR.IRelaxedToken(8, 'operator.elixir'),
          TR.IRelaxedToken(10, 'delimiter.parenthesis.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"foo"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.delimiter.elixir'),
          TR.IRelaxedToken(1, 'string.elixir'),
          TR.IRelaxedToken(4, 'string.delimiter.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"foo \\u0065\\u0301 #{1}"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.delimiter.elixir'),
          TR.IRelaxedToken(1, 'string.elixir'),
          TR.IRelaxedToken(5, 'constant.character.escape.elixir'),
          TR.IRelaxedToken(17, 'string.elixir'),
          TR.IRelaxedToken(18, 'delimiter.bracket.embed.elixir'),
          TR.IRelaxedToken(20, 'number.elixir'),
          TR.IRelaxedToken(21, 'delimiter.bracket.embed.elixir'),
          TR.IRelaxedToken(22, 'string.delimiter.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '"""heredoc"""',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.delimiter.elixir'),
          TR.IRelaxedToken(3, 'string.elixir'),
          TR.IRelaxedToken(10, 'string.delimiter.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        ':"atom"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'constant.delimiter.elixir'),
          TR.IRelaxedToken(2, 'constant.elixir'),
          TR.IRelaxedToken(6, 'constant.delimiter.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '~s{foo}',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'string.delimiter.elixir'),
          TR.IRelaxedToken(3, 'string.elixir'),
          TR.IRelaxedToken(6, 'string.delimiter.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '~r/foo/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'regexp.delimiter.elixir'),
          TR.IRelaxedToken(3, 'regexp.elixir'),
          TR.IRelaxedToken(6, 'regexp.delimiter.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '~D/foo/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'sigil.delimiter.elixir'),
          TR.IRelaxedToken(3, 'sigil.elixir'),
          TR.IRelaxedToken(6, 'sigil.delimiter.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '~DX/foo/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'sigil.delimiter.elixir'),
          TR.IRelaxedToken(4, 'sigil.elixir'),
          TR.IRelaxedToken(7, 'sigil.delimiter.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '~W/foo#{1}/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'sigil.delimiter.elixir'),
          TR.IRelaxedToken(3, 'sigil.elixir'),
          TR.IRelaxedToken(10, 'sigil.delimiter.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '~WW/foo#{1}/',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'sigil.delimiter.elixir'),
          TR.IRelaxedToken(4, 'sigil.elixir'),
          TR.IRelaxedToken(11, 'sigil.delimiter.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '~X/custom/az09',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'sigil.delimiter.elixir'),
          TR.IRelaxedToken(3, 'sigil.elixir'),
          TR.IRelaxedToken(9, 'sigil.delimiter.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '~DX/custom/az09',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'sigil.delimiter.elixir'),
          TR.IRelaxedToken(4, 'sigil.elixir'),
          TR.IRelaxedToken(10, 'sigil.delimiter.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@attr 1',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'variable.elixir'),
          TR.IRelaxedToken(5, 'white.elixir'),
          TR.IRelaxedToken(6, 'number.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '@doc "foo"',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'comment.block.documentation.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        'def a ~> b, do: max(a,b)',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'keyword.declaration.elixir'),
          TR.IRelaxedToken(3, 'white.elixir'),
          TR.IRelaxedToken(4, 'identifier.elixir'),
          TR.IRelaxedToken(5, 'white.elixir'),
          TR.IRelaxedToken(6, 'operator.elixir'),
          TR.IRelaxedToken(8, 'white.elixir'),
          TR.IRelaxedToken(9, 'identifier.elixir'),
          TR.IRelaxedToken(10, 'punctuation.elixir'),
          TR.IRelaxedToken(11, 'white.elixir'),
          TR.IRelaxedToken(12, 'constant.elixir'),
          TR.IRelaxedToken(14, 'constant.punctuation.elixir'),
          TR.IRelaxedToken(15, 'white.elixir'),
          TR.IRelaxedToken(16, 'function.call.elixir'),
          TR.IRelaxedToken(19, 'delimiter.parenthesis.elixir'),
          TR.IRelaxedToken(20, 'identifier.elixir'),
          TR.IRelaxedToken(21, 'punctuation.elixir'),
          TR.IRelaxedToken(22, 'identifier.elixir'),
          TR.IRelaxedToken(23, 'delimiter.parenthesis.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '[true,false,nil]',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.square.elixir'),
          TR.IRelaxedToken(1, 'constant.language.elixir'),
          TR.IRelaxedToken(5, 'punctuation.elixir'),
          TR.IRelaxedToken(6, 'constant.language.elixir'),
          TR.IRelaxedToken(11, 'punctuation.elixir'),
          TR.IRelaxedToken(12, 'constant.language.elixir'),
          TR.IRelaxedToken(15, 'delimiter.square.elixir'),
        ],
      ),
    ],
    <TR.ITestItem>[
      TR.ITestItem(
        '<<height::32-integer, width::32-integer, data::binary>>',
        <TR.IRelaxedToken>[
          TR.IRelaxedToken(0, 'delimiter.angle.special.elixir'),
          TR.IRelaxedToken(2, 'identifier.elixir'),
          TR.IRelaxedToken(8, 'operator.elixir'),
          TR.IRelaxedToken(10, 'number.elixir'),
          TR.IRelaxedToken(12, 'operator.elixir'),
          TR.IRelaxedToken(13, 'identifier.elixir'),
          TR.IRelaxedToken(20, 'punctuation.elixir'),
          TR.IRelaxedToken(21, 'white.elixir'),
          TR.IRelaxedToken(22, 'identifier.elixir'),
          TR.IRelaxedToken(27, 'operator.elixir'),
          TR.IRelaxedToken(29, 'number.elixir'),
          TR.IRelaxedToken(31, 'operator.elixir'),
          TR.IRelaxedToken(32, 'identifier.elixir'),
          TR.IRelaxedToken(39, 'punctuation.elixir'),
          TR.IRelaxedToken(40, 'white.elixir'),
          TR.IRelaxedToken(41, 'identifier.elixir'),
          TR.IRelaxedToken(45, 'operator.elixir'),
          TR.IRelaxedToken(47, 'identifier.elixir'),
          TR.IRelaxedToken(53, 'delimiter.angle.special.elixir'),
        ],
      ),
    ],
  ]);
}

