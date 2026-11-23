// 1:1 translation of monaco-editor/src/languages/definitions/java/java.ts
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
      'open': '"',
    },
    <String, Object?>{
      'close': '\'',
      'open': '\'',
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
      'end': RegExp('^\\s*\\/\\/\\s*(?:(?:#?endregion\\b)|(?:<\\/editor-fold>))'),
      'start': RegExp('^\\s*\\/\\/\\s*(?:(?:#?region\\b)|(?:<editor-fold\\b))'),
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
      'close': '"',
      'open': '"',
    },
    <String, Object?>{
      'close': '\'',
      'open': '\'',
    },
    <String, Object?>{
      'close': '>',
      'open': '<',
    },
  ],
  'wordPattern': RegExp('(-?\\d*\\.\\d\\w*)|([^\\`\\~\\!\\#\\%\\^\\&\\*\\(\\)\\-\\=\\+\\[\\{\\]\\}\\\\\\|\\;\\:\\\'\\"\\,\\.\\<\\>\\/\\?\\s]+)'),
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
    'javadoc': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\/*]+'),
        IShortActionCarrier('comment.doc'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\/\\*'),
        IShortActionCarrier('comment.doc.invalid'),
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
    'multistring': <IMonarchLanguageRule>[
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
        RegExp('"""'),
        IShortActionCarrier('string'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('string'),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        'non-sealed',
        IShortActionCarrier('keyword.non-sealed'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[a-zA-Z_\$][\\w\$]*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'identifier',
              '@keywords': <String, Object?>{
                'token': 'keyword.\$0',
              },
            },
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
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
        RegExp('@\\s*[a-zA-Z_\\\$][\\w\\\$]*'),
        IShortActionCarrier('annotation'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@digits)[eE]([\\-+]?(@digits))?[fFdD]?'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@digits)\\.(@digits)([eE][\\-+]?(@digits))?[fFdD]?'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[xX](@hexdigits)[Ll]?'),
        IShortActionCarrier('number.hex'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0(@octaldigits)[Ll]?'),
        IShortActionCarrier('number.octal'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[bB](@binarydigits)[Ll]?'),
        IShortActionCarrier('number.binary'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@digits)[fFdD]'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@digits)[lL]?'),
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
        IShortMonarchLanguageRule2(
        RegExp('"""'),
        IShortActionCarrier('string'),
        '@multistring',
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string'),
        '@string',
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
        IShortMonarchLanguageRule2(
        RegExp('"'),
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
        '@javadoc',
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
  tokenPostfix: '.java',
  extra: <String, Object?>{
      'binarydigits': RegExp('[0-1]+(_+[0-1]+)*'),
      'digits': RegExp('\\d+(_+\\d+)*'),
      'escapes': RegExp('\\\\(?:[abfnrtv\\\\"\']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})'),
      'hexdigits': RegExp('[[0-9a-fA-F]+(_+[0-9a-fA-F]+)*'),
      'keywords': <Object?>[
        'abstract',
        'continue',
        'for',
        'new',
        'switch',
        'assert',
        'default',
        'goto',
        'package',
        'synchronized',
        'boolean',
        'do',
        'if',
        'private',
        'this',
        'break',
        'double',
        'implements',
        'protected',
        'throw',
        'byte',
        'else',
        'import',
        'public',
        'throws',
        'case',
        'enum',
        'instanceof',
        'return',
        'transient',
        'catch',
        'extends',
        'int',
        'short',
        'try',
        'char',
        'final',
        'interface',
        'static',
        'void',
        'class',
        'finally',
        'long',
        'strictfp',
        'volatile',
        'const',
        'float',
        'native',
        'super',
        'while',
        'true',
        'false',
        'yield',
        'record',
        'sealed',
        'non-sealed',
        'permits',
      ],
      'octaldigits': RegExp('[0-7]+(_+[0-7]+)*'),
      'operators': <Object?>[
        '=',
        '>',
        '<',
        '!',
        '~',
        '?',
        ':',
        '==',
        '<=',
        '>=',
        '!=',
        '&&',
        '||',
        '++',
        '--',
        '+',
        '-',
        '*',
        '/',
        '&',
        '|',
        '^',
        '%',
        '<<',
        '>>',
        '>>>',
        '+=',
        '-=',
        '*=',
        '/=',
        '&=',
        '|=',
        '^=',
        '%=',
        '<<=',
        '>>=',
        '>>>=',
      ],
      'symbols': RegExp('[=><!~?:&|+\\-*\\/\\^%]+'),
    },
);
