// 1:1 translation of monaco-editor/src/languages/definitions/csharp/csharp.ts
// Monarch language definition data, evaluated from the TS source via
// the TypeScript compiler (computed template/const values resolved).
// TS object literals -> Dart data; typed rule/action/bracket carriers
// mirror the ported monarchCompile. Regex flags preserved in RegExp.

import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchTypes.dart';

/// 1:1: `export const conf: languages.LanguageConfiguration = {...}`
final Map<String, Object?> conf = <String, Object?>{
  'autoClosingPairs': <Object?>[
    <String, Object?>{
      'close': '}',
      'open': '{',
    },
    <String, Object?>{
      'close': ']',
      'open': '[',
    },
    <String, Object?>{
      'close': ')',
      'open': '(',
    },
    <String, Object?>{
      'close': '\'',
      'notIn': <Object?>[
        'string',
        'comment',
      ],
      'open': '\'',
    },
    <String, Object?>{
      'close': '"',
      'notIn': <Object?>[
        'string',
        'comment',
      ],
      'open': '"',
    },
  ],
  'brackets': <Object?>[
    <Object?>[
      '{',
      '}',
    ],
    <Object?>[
      '[',
      ']',
    ],
    <Object?>[
      '(',
      ')',
    ],
  ],
  'comments': <String, Object?>{
    'blockComment': <Object?>[
      '/*',
      '*/',
    ],
    'lineComment': '//',
  },
  'folding': <String, Object?>{
    'markers': <String, Object?>{
      'end': RegExp('^\\s*#endregion\\b'),
      'start': RegExp('^\\s*#region\\b'),
    },
  },
  'surroundingPairs': <Object?>[
    <String, Object?>{
      'close': '}',
      'open': '{',
    },
    <String, Object?>{
      'close': ']',
      'open': '[',
    },
    <String, Object?>{
      'close': ')',
      'open': '(',
    },
    <String, Object?>{
      'close': '>',
      'open': '<',
    },
    <String, Object?>{
      'close': '\'',
      'open': '\'',
    },
    <String, Object?>{
      'close': '"',
      'open': '"',
    },
  ],
  'wordPattern': RegExp('(-?\\d*\\.\\d\\w*)|([^\\`\\~\\!\\#\\\$\\%\\^\\&\\*\\(\\)\\-\\=\\+\\[\\{\\]\\}\\\\\\|\\;\\:\\\'\\"\\,\\.\\<\\>\\/\\?\\s]+)'),
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\/*]+'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule2(
        '\\*/',
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\/*]'),
        IShortActionCarrier('comment'),
      ),
      ],
    'interpolatedstring': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\"{]+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string.escape.invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('{{'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('}}'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('{'),
        IExpandedMonarchLanguageAction(
          next: 'root.interpolatedstring',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.quote',
        ),
      ),
      ],
    'litinterpstring': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"{]+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('""'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('{{'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('}}'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('{'),
        IExpandedMonarchLanguageAction(
          next: 'root.litinterpstring',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.quote',
        ),
      ),
      ],
    'litstring': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"]+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('""'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.quote',
        ),
      ),
      ],
    'namespace': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[A-Z]\\w*'),
        IShortActionCarrier('namespace'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\.=]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule2(
        '',
        IShortActionCarrier(''),
        '@pop',
      ),
      ],
    'qualified': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[a-zA-Z_][\\w]*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'identifier',
              '@keywords': <String, Object?>{
                'token': 'keyword.\$0',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\.'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule2(
        '',
        IShortActionCarrier(''),
        '@pop',
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\@?[a-zA-Z_]\\w*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': <String, Object?>{
                'next': '@qualified',
                'token': 'identifier',
              },
              '@keywords': <String, Object?>{
                'next': '@qualified',
                'token': 'keyword.\$0',
              },
              '@namespaceFollows': <String, Object?>{
                'next': '@namespace',
                'token': 'keyword.\$0',
              },
            },
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('}'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==interpolatedstring': <String, Object?>{
                'next': '@pop',
                'token': 'string.quote',
              },
              '\$S2==litinterpstring': <String, Object?>{
                'next': '@pop',
                'token': 'string.quote',
              },
              '@default': '@brackets',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[{}()\\[\\]]'),
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[<>](?!@symbols)'),
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@symbols'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': '',
              '@operators': 'delimiter',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[0-9_]*\\.[0-9_]+([eE][\\-+]?\\d+)?[fFdD]?'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[xX][0-9a-fA-F_]+'),
        IShortActionCarrier('number.hex'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[bB][01_]+'),
        IShortActionCarrier('number.hex'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[0-9_]+'),
        IShortActionCarrier('number'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[;,.]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"\\\\]|\\\\.)*\$'),
        IShortActionCarrier('string.invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@string',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$\\@"'),
        IExpandedMonarchLanguageAction(
          next: '@litinterpstring',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\@"'),
        IExpandedMonarchLanguageAction(
          next: '@litstring',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$"'),
        IExpandedMonarchLanguageAction(
          next: '@interpolatedstring',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'[^\\\\\']\''),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\')(@escapes)(\')'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('string'),
          IShortActionCarrier('string.escape'),
          IShortActionCarrier('string'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IShortActionCarrier('string.invalid'),
      ),
      ],
    'string': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\"]+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string.escape.invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.quote',
        ),
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('^[ \\t\\v\\f]*#((r)|(load))(?=\\s)'),
        IShortActionCarrier('directive.csx'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^[ \\t\\v\\f]*#\\w.*\$'),
        IShortActionCarrier('namespace.cpp'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[ \\t\\v\\f\\r\\n]+'),
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\/\\*'),
        IShortActionCarrier('comment'),
        '@comment',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\/\\/.*\$'),
        IShortActionCarrier('comment'),
      ),
      ],
  },
  defaultToken: '',
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
    IMonarchLanguageBracket('[', ']', 'delimiter.square'),
    IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
    IMonarchLanguageBracket('<', '>', 'delimiter.angle'),
  ],
  tokenPostfix: '.cs',
  extra: <String, Object?>{
      'escapes': RegExp('\\\\(?:[abfnrtv\\\\"\']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})'),
      'keywords': <Object?>[
        'extern',
        'alias',
        'using',
        'bool',
        'decimal',
        'sbyte',
        'byte',
        'short',
        'ushort',
        'int',
        'uint',
        'long',
        'ulong',
        'char',
        'float',
        'double',
        'object',
        'dynamic',
        'string',
        'assembly',
        'is',
        'as',
        'ref',
        'out',
        'this',
        'base',
        'new',
        'typeof',
        'void',
        'checked',
        'unchecked',
        'default',
        'delegate',
        'var',
        'const',
        'if',
        'else',
        'switch',
        'case',
        'while',
        'do',
        'for',
        'foreach',
        'in',
        'break',
        'continue',
        'goto',
        'return',
        'throw',
        'try',
        'catch',
        'finally',
        'lock',
        'yield',
        'from',
        'let',
        'where',
        'join',
        'on',
        'equals',
        'into',
        'orderby',
        'ascending',
        'descending',
        'select',
        'group',
        'by',
        'namespace',
        'partial',
        'class',
        'field',
        'event',
        'method',
        'param',
        'public',
        'protected',
        'internal',
        'private',
        'abstract',
        'sealed',
        'static',
        'struct',
        'readonly',
        'volatile',
        'virtual',
        'override',
        'params',
        'get',
        'set',
        'add',
        'remove',
        'operator',
        'true',
        'false',
        'implicit',
        'explicit',
        'interface',
        'enum',
        'null',
        'async',
        'await',
        'fixed',
        'sizeof',
        'stackalloc',
        'unsafe',
        'nameof',
        'when',
      ],
      'namespaceFollows': <Object?>[
        'namespace',
        'using',
      ],
      'operators': <Object?>[
        '=',
        '??',
        '||',
        '&&',
        '|',
        '^',
        '&',
        '==',
        '!=',
        '<=',
        '>=',
        '<<',
        '+',
        '-',
        '*',
        '/',
        '%',
        '!',
        '~',
        '++',
        '--',
        '+=',
        '-=',
        '*=',
        '/=',
        '%=',
        '&=',
        '|=',
        '^=',
        '<<=',
        '>>=',
        '>>',
        '=>',
      ],
      'parenFollows': <Object?>[
        'if',
        'for',
        'while',
        'switch',
        'foreach',
        'using',
        'catch',
        'when',
      ],
      'symbols': RegExp('[=><!~?:&|+\\-*\\/\\^%]+'),
    },
);
