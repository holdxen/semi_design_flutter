// 1:1 translation of monaco-editor/src/languages/definitions/scheme/scheme.ts
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
  ],
  'brackets': <Object?>[
    <Object?>[
      '(',
      ')',
    ],
    <Object?>[
      '{',
      '}',
    ],
    <Object?>[
      '[',
      ']',
    ],
  ],
  'comments': <String, Object?>{
    'blockComment': <Object?>[
      '#|',
      '|#',
    ],
    'lineComment': ';',
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
  ],
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\|#]+'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('#\\|'),
        IShortActionCarrier('comment'),
        '@push',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\|#'),
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\|#]'),
        IShortActionCarrier('comment'),
      ),
      ],
    'multiLineString': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('[^\\\\"]+\$'),
        IShortActionCarrier('string'),
        '@popall',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\"]+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string'),
        '@popall',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\\$'),
        IShortActionCarrier('string'),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('#[xXoObB][0-9a-fA-F]+'),
        IShortActionCarrier('number.hex'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[+-]?\\d+(?:(?:\\.\\d*)?(?:[eE][+-]?\\d+)?)?'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:\\b(?:(define|define-syntax|define-macro))\\b)(\\s+)((?:\\w|\\-|\\!|\\?)*)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('keyword'),
          IShortActionCarrier('white'),
          IShortActionCarrier('variable'),
        ]),
      ),
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IExpandedMonarchLanguageRule(
        include: '@strings',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[a-zA-Z_#][a-zA-Z0-9_\\-\\?\\!\\*]*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@constants': 'constant',
              '@default': 'identifier',
              '@keywords': 'keyword',
              '@operators': 'operators',
            },
        ),
      ),
      ],
    'strings': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('"\$'),
        IShortActionCarrier('string'),
        '@popall',
      ),
        IShortMonarchLanguageRule2(
        RegExp('"(?=.)'),
        IShortActionCarrier('string'),
        '@multiLineString',
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[ \\t\\r\\n]+'),
        IShortActionCarrier('white'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('#\\|'),
        IShortActionCarrier('comment'),
        '@comment',
      ),
        IShortMonarchLanguageRule1(
        RegExp(';.*\$'),
        IShortActionCarrier('comment'),
      ),
      ],
  },
  ignoreCase: true,
  defaultToken: '',
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
    IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
    IMonarchLanguageBracket('[', ']', 'delimiter.square'),
  ],
  tokenPostfix: '.scheme',
  extra: <String, Object?>{
      'constants': <Object?>[
        '#t',
        '#f',
      ],
      'keywords': <Object?>[
        'case',
        'do',
        'let',
        'loop',
        'if',
        'else',
        'when',
        'cons',
        'car',
        'cdr',
        'cond',
        'lambda',
        'lambda*',
        'syntax-rules',
        'format',
        'set!',
        'quote',
        'eval',
        'append',
        'list',
        'list?',
        'member?',
        'load',
      ],
      'operators': <Object?>[
        'eq?',
        'eqv?',
        'equal?',
        'and',
        'or',
        'not',
        'null?',
      ],
    },
);
