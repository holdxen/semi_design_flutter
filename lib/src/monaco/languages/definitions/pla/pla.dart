// 1:1 translation of monaco-editor/src/languages/definitions/pla/pla.ts
// Monarch language definition data, evaluated from the TS source via
// the TypeScript compiler (computed template/const values resolved).
// TS object literals -> Dart data; typed rule/action/bracket carriers
// mirror the ported monarchCompile. Regex flags preserved in RegExp.

import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchTypes.dart';

/// 1:1: `export const conf: languages.LanguageConfiguration = {...}`
final Map<String, Object?> conf = <String, Object?>{
  'autoClosingPairs': <Object?>[
    <String, Object?>{
      'close': ']',
      'open': '[',
    },
    <String, Object?>{
      'close': '>',
      'open': '<',
    },
    <String, Object?>{
      'close': ')',
      'open': '(',
    },
  ],
  'brackets': <Object?>[
    <Object?>[
      '[',
      ']',
    ],
    <Object?>[
      '<',
      '>',
    ],
    <Object?>[
      '(',
      ')',
    ],
  ],
  'comments': <String, Object?>{
    'lineComment': '#',
  },
  'surroundingPairs': <Object?>[
    <String, Object?>{
      'close': ']',
      'open': '[',
    },
    <String, Object?>{
      'close': '>',
      'open': '<',
    },
    <String, Object?>{
      'close': ')',
      'open': '(',
    },
  ],
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'keywordArg': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[ \\t\\r\\n]+'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': '',
              '@eos': <String, Object?>{
                'next': '@pop',
                'token': '',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('@comment'),
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[<>()\\[\\]]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': '@brackets',
              '@eos': <String, Object?>{
                'next': '@pop',
                'token': '@brackets',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\-?\\d+'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'number',
              '@eos': <String, Object?>{
                'next': '@pop',
                'token': 'number',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@identifier'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'identifier',
              '@eos': <String, Object?>{
                'next': '@pop',
                'token': 'identifier',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[;=]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'delimiter',
              '@eos': <String, Object?>{
                'next': '@pop',
                'token': 'delimiter',
              },
            },
        ),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('@comment'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\.([a-zA-Z_\\-]+)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': <String, Object?>{
                'token': 'keyword.\$1',
              },
              '@eos': <String, Object?>{
                'token': 'keyword.\$1',
              },
              '@keywords': <String, Object?>{
                'cases': <String, Object?>{
                  '.type': <String, Object?>{
                    'next': '@type',
                    'token': 'keyword.\$1',
                  },
                  '@default': <String, Object?>{
                    'next': '@keywordArg',
                    'token': 'keyword.\$1',
                  },
                },
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@identifier'),
        IShortActionCarrier('identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@plaContent'),
        IShortActionCarrier('string'),
      ),
      ],
    'type': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\w+'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'type',
        ),
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[ \\t\\r\\n]+'),
        IShortActionCarrier(''),
      ),
      ],
  },
  defaultToken: '',
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket('[', ']', 'delimiter.square'),
    IMonarchLanguageBracket('<', '>', 'delimiter.angle'),
    IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
  ],
  tokenPostfix: '.pla',
  extra: <String, Object?>{
      'comment': RegExp('#.*\$'),
      'identifier': RegExp('[a-zA-Z]+[a-zA-Z0-9_\\-]*'),
      'keywords': <Object?>[
        '.i',
        '.o',
        '.mv',
        '.ilb',
        '.ob',
        '.label',
        '.type',
        '.phase',
        '.pair',
        '.symbolic',
        '.symbolic-output',
        '.kiss',
        '.p',
        '.e',
        '.end',
      ],
      'plaContent': RegExp('[01\\-~\\|]+'),
    },
);
