// 1:1 translation of monaco-editor/src/languages/definitions/sb/sb.ts
// Monarch language definition data, evaluated from the TS source via
// the TypeScript compiler (computed template/const values resolved).
// TS object literals -> Dart data; typed rule/action/bracket carriers
// mirror the ported monarchCompile. Regex flags preserved in RegExp.

import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchTypes.dart';

/// 1:1: `export const conf: languages.LanguageConfiguration = {...}`
final Map<String, Object?> conf = <String, Object?>{
  'autoClosingPairs': <Object?>[
    <String, Object?>{
      'close': '"',
      'notIn': <Object?>[
        'string',
        'comment',
      ],
      'open': '"',
    },
    <String, Object?>{
      'close': ')',
      'notIn': <Object?>[
        'string',
        'comment',
      ],
      'open': '(',
    },
    <String, Object?>{
      'close': ']',
      'notIn': <Object?>[
        'string',
        'comment',
      ],
      'open': '[',
    },
  ],
  'brackets': <Object?>[
    <Object?>[
      '(',
      ')',
    ],
    <Object?>[
      '[',
      ']',
    ],
    <Object?>[
      'If',
      'EndIf',
    ],
    <Object?>[
      'While',
      'EndWhile',
    ],
    <Object?>[
      'For',
      'EndFor',
    ],
    <Object?>[
      'Sub',
      'EndSub',
    ],
  ],
  'comments': <String, Object?>{
    'lineComment': '\'',
  },
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'root': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@identifier)(?=[.])'),
        IShortActionCarrier('type'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@identifier'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'variable.name',
              '@keywords': <String, Object?>{
                'token': 'keyword.\$0',
              },
              '@operators': 'operator',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('([.])(@identifier)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$2': <Object?>[
                'delimiter',
                'type.member',
              ],
              '@default': '',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d*\\.\\d+'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d+'),
        IShortActionCarrier('number'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[()\\[\\]]'),
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@symbols'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'delimiter',
              '@operators': 'operator',
            },
        ),
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
        RegExp('"C?'),
        IShortActionCarrier('string'),
        '@pop',
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[ \\t\\r\\n]+'),
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\\').*\$'),
        IShortActionCarrier('comment'),
      ),
      ],
  },
  ignoreCase: true,
  defaultToken: '',
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket('[', ']', 'delimiter.array'),
    IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
    IMonarchLanguageBracket('If', 'EndIf', 'keyword.tag-if'),
    IMonarchLanguageBracket('While', 'EndWhile', 'keyword.tag-while'),
    IMonarchLanguageBracket('For', 'EndFor', 'keyword.tag-for'),
    IMonarchLanguageBracket('Sub', 'EndSub', 'keyword.tag-sub'),
  ],
  tokenPostfix: '.sb',
  extra: <String, Object?>{
      'escapes': RegExp('\\\\(?:[abfnrtv\\\\"\']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})'),
      'identifier': RegExp('[a-zA-Z_][\\w]*'),
      'keywords': <Object?>[
        'Else',
        'ElseIf',
        'EndFor',
        'EndIf',
        'EndSub',
        'EndWhile',
        'For',
        'Goto',
        'If',
        'Step',
        'Sub',
        'Then',
        'To',
        'While',
      ],
      'operators': <Object?>[
        '>',
        '<',
        '<>',
        '<=',
        '>=',
        'And',
        'Or',
        '+',
        '-',
        '*',
        '/',
        '=',
      ],
      'symbols': RegExp('[=><:+\\-*\\/%\\.,]+'),
      'tagwords': <Object?>[
        'If',
        'Sub',
        'While',
        'For',
      ],
    },
);
