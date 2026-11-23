// 1:1 translation of monaco-editor/src/languages/definitions/typescript/typescript.ts
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
      'close': '"',
      'notIn': <Object?>[
        'string',
      ],
      'open': '"',
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
      'close': '`',
      'notIn': <Object?>[
        'string',
        'comment',
      ],
      'open': '`',
    },
    <String, Object?>{
      'close': ' */',
      'notIn': <Object?>[
        'string',
      ],
      'open': '/**',
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
      'end': RegExp('^\\s*\\/\\/\\s*#?endregion\\b'),
      'start': RegExp('^\\s*\\/\\/\\s*#?region\\b'),
    },
  },
  'onEnterRules': <Object?>[
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': ' * ',
        'indentAction': 2,
      },
      'afterText': RegExp('^\\s*\\*\\/\$'),
      'beforeText': RegExp('^\\s*\\/\\*\\*(?!\\/)([^\\*]|\\*(?!\\/))*\$'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': ' * ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^\\s*\\/\\*\\*(?!\\/)([^\\*]|\\*(?!\\/))*\$'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '* ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^(\\t|(\\ \\ ))*\\ \\*(\\ ([^\\*]|\\*(?!\\/))*)?\$'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'indentAction': 0,
        'removeText': 1,
      },
      'beforeText': RegExp('^(\\t|(\\ \\ ))*\\ \\*\\/\\s*\$'),
    },
  ],
  'wordPattern': RegExp('(-?\\d*\\.\\d\\w*)|([^\\`\\~\\!\\@\\#\\%\\^\\&\\*\\(\\)\\-\\=\\+\\[\\{\\]\\}\\\\\\|\\;\\:\\\'\\"\\,\\.\\<\\>\\/\\?\\s]+)'),
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'bracketCounting': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('\\{'),
        IShortActionCarrier('delimiter.bracket'),
        '@bracketCounting',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\}'),
        IShortActionCarrier('delimiter.bracket'),
        '@pop',
      ),
        IExpandedMonarchLanguageRule(
        include: 'common',
      ),
      ],
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\/*]+'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\*\\/'),
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\/*]'),
        IShortActionCarrier('comment'),
      ),
      ],
    'common': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('#?[a-z_\$][\\w\$]*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'identifier',
              '@keywords': 'keyword',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[A-Z][\\w\\\$]*'),
        IShortActionCarrier('type.identifier'),
      ),
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\/(?=([^\\\\\\/]|\\\\.)+\\/([dgimsuy]*)(\\s*)(\\.|;|,|\\)|\\]|\\}|\$))'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@regexp',
          token: 'regexp',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[()\\[\\]]'),
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[<>](?!@symbols)'),
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('!(?=([^=]|\$))'),
        IShortActionCarrier('delimiter'),
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
        RegExp('(@digits)[eE]([\\-+]?(@digits))?'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@digits)\\.(@digits)([eE][\\-+]?(@digits))?'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[xX](@hexdigits)n?'),
        IShortActionCarrier('number.hex'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[oO]?(@octaldigits)n?'),
        IShortActionCarrier('number.octal'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[bB](@binarydigits)n?'),
        IShortActionCarrier('number.binary'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@digits)n?'),
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
        RegExp('\'([^\'\\\\]|\\\\.)*\$'),
        IShortActionCarrier('string.invalid'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string'),
        '@string_double',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\''),
        IShortActionCarrier('string'),
        '@string_single',
      ),
        IShortMonarchLanguageRule2(
        RegExp('`'),
        IShortActionCarrier('string'),
        '@string_backtick',
      ),
      ],
    'jsdoc': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\/*]+'),
        IShortActionCarrier('comment.doc'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\*\\/'),
        IShortActionCarrier('comment.doc'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\/*]'),
        IShortActionCarrier('comment.doc'),
      ),
      ],
    'regexp': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(\\{)(\\d+(?:,\\d*)?)(\\})'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('regexp.escape.control'),
          IShortActionCarrier('regexp.escape.control'),
          IShortActionCarrier('regexp.escape.control'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\[)(\\^?)(?=(?:[^\\]\\\\\\/]|\\\\.)+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('regexp.escape.control'),
          IExpandedMonarchLanguageAction(
            next: '@regexrange',
            token: 'regexp.escape.control',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\()(\\?:|\\?=|\\?!)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('regexp.escape.control'),
          IShortActionCarrier('regexp.escape.control'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[()]'),
        IShortActionCarrier('regexp.escape.control'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@regexpctl'),
        IShortActionCarrier('regexp.escape.control'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\\\/]'),
        IShortActionCarrier('regexp'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@regexpesc'),
        IShortActionCarrier('regexp.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\\\.'),
        IShortActionCarrier('regexp.invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\/)([dgimsuy]*)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            bracket: '@close',
            next: '@pop',
            token: 'regexp',
          ),
          IShortActionCarrier('keyword.other'),
        ]),
      ),
      ],
    'regexrange': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('-'),
        IShortActionCarrier('regexp.escape.control'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\^'),
        IShortActionCarrier('regexp.invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@regexpesc'),
        IShortActionCarrier('regexp.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\]]'),
        IShortActionCarrier('regexp'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\]'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          next: '@pop',
          token: 'regexp.escape.control',
        ),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[{}]'),
        IShortActionCarrier('delimiter.bracket'),
      ),
        IExpandedMonarchLanguageRule(
        include: 'common',
      ),
      ],
    'string_backtick': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\\$\\{'),
        IExpandedMonarchLanguageAction(
          next: '@bracketCounting',
          token: 'delimiter.bracket',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\`\$]+'),
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
        IShortMonarchLanguageRule2(
        RegExp('`'),
        IShortActionCarrier('string'),
        '@pop',
      ),
      ],
    'string_double': <IMonarchLanguageRule>[
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
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string'),
        '@pop',
      ),
      ],
    'string_single': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\\']+'),
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
        IShortMonarchLanguageRule2(
        RegExp('\''),
        IShortActionCarrier('string'),
        '@pop',
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[ \\t\\r\\n]+'),
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\/\\*\\*(?!\\/)'),
        IShortActionCarrier('comment.doc'),
        '@jsdoc',
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
  defaultToken: 'invalid',
  tokenPostfix: '.ts',
  extra: <String, Object?>{
      'binarydigits': RegExp('[0-1]+(_+[0-1]+)*'),
      'digits': RegExp('\\d+(_+\\d+)*'),
      'escapes': RegExp('\\\\(?:[abfnrtv\\\\"\']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})'),
      'hexdigits': RegExp('[[0-9a-fA-F]+(_+[0-9a-fA-F]+)*'),
      'keywords': <Object?>[
        'abstract',
        'any',
        'as',
        'asserts',
        'bigint',
        'boolean',
        'break',
        'case',
        'catch',
        'class',
        'continue',
        'const',
        'constructor',
        'debugger',
        'declare',
        'default',
        'delete',
        'do',
        'else',
        'enum',
        'export',
        'extends',
        'false',
        'finally',
        'for',
        'from',
        'function',
        'get',
        'if',
        'implements',
        'import',
        'in',
        'infer',
        'instanceof',
        'interface',
        'is',
        'keyof',
        'let',
        'module',
        'namespace',
        'never',
        'new',
        'null',
        'number',
        'object',
        'out',
        'package',
        'private',
        'protected',
        'public',
        'override',
        'readonly',
        'require',
        'global',
        'return',
        'satisfies',
        'set',
        'static',
        'string',
        'super',
        'switch',
        'symbol',
        'this',
        'throw',
        'true',
        'try',
        'type',
        'typeof',
        'undefined',
        'unique',
        'unknown',
        'var',
        'void',
        'while',
        'with',
        'yield',
        'async',
        'await',
        'of',
      ],
      'octaldigits': RegExp('[0-7]+(_+[0-7]+)*'),
      'operators': <Object?>[
        '<=',
        '>=',
        '==',
        '!=',
        '===',
        '!==',
        '=>',
        '+',
        '-',
        '**',
        '*',
        '/',
        '%',
        '++',
        '--',
        '<<',
        '</',
        '>>',
        '>>>',
        '&',
        '|',
        '^',
        '!',
        '~',
        '&&',
        '||',
        '??',
        '?',
        ':',
        '=',
        '+=',
        '-=',
        '*=',
        '**=',
        '/=',
        '%=',
        '<<=',
        '>>=',
        '>>>=',
        '&=',
        '|=',
        '^=',
        '@',
      ],
      'regexpctl': RegExp('[(){}\\[\\]\\\$\\^|\\-*+?\\.]'),
      'regexpesc': RegExp('\\\\(?:[bBdDfnrstvwWn0\\\\\\/]|@regexpctl|c[A-Z]|x[0-9a-fA-F]{2}|u[0-9a-fA-F]{4})'),
      'symbols': RegExp('[=><!~?:&|+\\-*\\/\\^%]+'),
    },
);
