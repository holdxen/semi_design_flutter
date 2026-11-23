// 1:1 translation of monaco-editor/src/languages/definitions/flow9/flow9.ts
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
      'notIn': <Object?>[
        'string',
      ],
      'open': '{',
    },
    <String, Object?>{
      'close': ']',
      'notIn': <Object?>[
        'string',
      ],
      'open': '[',
    },
    <String, Object?>{
      'close': ')',
      'notIn': <Object?>[
        'string',
      ],
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
      ],
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
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[a-zA-Z_]\\w*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'identifier',
              '@keywords': 'keyword',
              '@types': 'type',
            },
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[{}()\\[\\]]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[<>](?!@symbols)'),
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
        RegExp('((0(x|X)[0-9a-fA-F]*)|(([0-9]+\\.?[0-9]*)|(\\.[0-9]+))((e|E)(\\+|-)?[0-9]+)?)'),
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
        RegExp('"'),
        IShortActionCarrier('string'),
        '@string',
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
  tokenPostfix: '.flow',
  extra: <String, Object?>{
      'escapes': RegExp('\\\\(?:[abfnrtv\\\\"\']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})'),
      'keywords': <Object?>[
        'import',
        'require',
        'export',
        'forbid',
        'native',
        'if',
        'else',
        'cast',
        'unsafe',
        'switch',
        'default',
      ],
      'operators': <Object?>[
        '=',
        '>',
        '<',
        '<=',
        '>=',
        '==',
        '!',
        '!=',
        ':=',
        '::=',
        '&&',
        '||',
        '+',
        '-',
        '*',
        '/',
        '@',
        '&',
        '%',
        ':',
        '->',
        '\\',
        '\$',
        '??',
        '^',
      ],
      'symbols': RegExp('[@\$=><!~?:&|+\\-*\\\\\\/\\^%]+'),
      'types': <Object?>[
        'io',
        'mutable',
        'bool',
        'int',
        'double',
        'string',
        'flow',
        'void',
        'ref',
        'true',
        'false',
        'with',
      ],
    },
);
