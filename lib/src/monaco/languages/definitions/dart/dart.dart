// 1:1 translation of monaco-editor/src/languages/definitions/dart/dart.ts
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
      ],
      'open': '"',
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
      'end': RegExp('^\\s*\\s*#?endregion\\b'),
      'start': RegExp('^\\s*\\s*#?region\\b'),
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
      'close': ')',
      'open': '(',
    },
    <String, Object?>{
      'close': '"',
      'open': '"',
    },
    <String, Object?>{
      'close': '`',
      'open': '`',
    },
  ],
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
        RegExp('[a-z_\$][\\w\$]*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'identifier',
              '@keywords': 'keyword',
              '@typeKeywords': 'type.identifier',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[A-Z_\$][\\w\\\$]*'),
        IShortActionCarrier('type.identifier'),
      ),
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\/(?=([^\\\\\\/]|\\\\.)+\\/([gimsuy]*)(\\s*)(\\.|;|,|\\)|\\]|\\}|\$))'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@regexp',
          token: 'regexp',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@[a-zA-Z]+'),
        IShortActionCarrier('annotation'),
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
        RegExp('(\\/)([gimsuy]*)'),
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
    'string_double': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\"\\\$]+'),
        IShortActionCarrier('string'),
      ),
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
        IShortMonarchLanguageRule1(
        RegExp('\\\$\\w+'),
        IShortActionCarrier('identifier'),
      ),
      ],
    'string_single': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\\'\\\$]+'),
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
        IShortMonarchLanguageRule1(
        RegExp('\\\$\\w+'),
        IShortActionCarrier('identifier'),
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
        RegExp('\\/\\/\\/.*\$'),
        IShortActionCarrier('comment.doc'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\/\\/.*\$'),
        IShortActionCarrier('comment'),
      ),
      ],
  },
  defaultToken: 'invalid',
  tokenPostfix: '.dart',
  extra: <String, Object?>{
      'binarydigits': RegExp('[0-1]+(_+[0-1]+)*'),
      'digits': RegExp('\\d+(_+\\d+)*'),
      'escapes': RegExp('\\\\(?:[abfnrtv\\\\"\']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})'),
      'hexdigits': RegExp('[[0-9a-fA-F]+(_+[0-9a-fA-F]+)*'),
      'keywords': <Object?>[
        'abstract',
        'dynamic',
        'implements',
        'show',
        'as',
        'else',
        'import',
        'static',
        'assert',
        'enum',
        'in',
        'super',
        'async',
        'export',
        'interface',
        'switch',
        'await',
        'extends',
        'is',
        'sync',
        'break',
        'external',
        'library',
        'this',
        'case',
        'factory',
        'mixin',
        'throw',
        'catch',
        'false',
        'new',
        'true',
        'class',
        'final',
        'null',
        'try',
        'const',
        'finally',
        'on',
        'typedef',
        'continue',
        'for',
        'operator',
        'var',
        'covariant',
        'Function',
        'part',
        'void',
        'default',
        'get',
        'rethrow',
        'while',
        'deferred',
        'hide',
        'return',
        'with',
        'do',
        'if',
        'set',
        'yield',
      ],
      'octaldigits': RegExp('[0-7]+(_+[0-7]+)*'),
      'operators': <Object?>[
        '+',
        '-',
        '*',
        '/',
        '~/',
        '%',
        '++',
        '--',
        '==',
        '!=',
        '>',
        '<',
        '>=',
        '<=',
        '=',
        '-=',
        '/=',
        '%=',
        '>>=',
        '^=',
        '+=',
        '*=',
        '~/=',
        '<<=',
        '&=',
        '!=',
        '||',
        '&&',
        '&',
        '|',
        '^',
        '~',
        '<<',
        '>>',
        '!',
        '>>>',
        '??',
        '?',
        ':',
        '|=',
      ],
      'regexpctl': RegExp('[(){}\\[\\]\\\$\\^|\\-*+?\\.]'),
      'regexpesc': RegExp('\\\\(?:[bBdDfnrstvwWn0\\\\\\/]|@regexpctl|c[A-Z]|x[0-9a-fA-F]{2}|u[0-9a-fA-F]{4})'),
      'symbols': RegExp('[=><!~?:&|+\\-*\\/\\^%]+'),
      'typeKeywords': <Object?>[
        'int',
        'double',
        'String',
        'bool',
      ],
    },
);
