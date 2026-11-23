// 1:1 translation of monaco-editor/src/languages/definitions/dockerfile/dockerfile.ts
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
  ],
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'arguments': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IExpandedMonarchLanguageRule(
        include: '@strings',
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@variable)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'variable',
              '@eos': <String, Object?>{
                'next': '@popall',
                'token': 'variable',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': '',
              '@eos': '',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': '',
              '@eos': <String, Object?>{
                'next': '@popall',
                'token': '',
              },
            },
        ),
      ),
      ],
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('(^#.*\$)'),
        IShortActionCarrier('comment'),
        '@popall',
      ),
      ],
    'dblStringBody': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\\\\$"]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'string',
              '@eos': <String, Object?>{
                'next': '@popall',
                'token': 'string',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"\$'),
        IShortActionCarrier('string'),
        '@popall',
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@variable)'),
        IShortActionCarrier('variable'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\\$'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\$'),
        IShortActionCarrier('string'),
        '@popall',
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IExpandedMonarchLanguageRule(
        include: '@comment',
      ),
        IShortMonarchLanguageRule1(
        RegExp('(ONBUILD)(\\s+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('keyword'),
          IShortActionCarrier(''),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(ENV)(\\s+)([\\w]+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('keyword'),
          IShortActionCarrier(''),
          IExpandedMonarchLanguageAction(
            next: '@arguments',
            token: 'variable',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(FROM|MAINTAINER|RUN|EXPOSE|ENV|ADD|ARG|VOLUME|LABEL|USER|WORKDIR|COPY|CMD|STOPSIGNAL|SHELL|HEALTHCHECK|ENTRYPOINT)'),
        IExpandedMonarchLanguageAction(
          next: '@arguments',
          token: 'keyword',
        ),
      ),
      ],
    'stringBody': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\\\\$\']'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'string',
              '@eos': <String, Object?>{
                'next': '@popall',
                'token': 'string',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\'\$'),
        IShortActionCarrier('string'),
        '@popall',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\''),
        IShortActionCarrier('string'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@variable)'),
        IShortActionCarrier('variable'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\\$'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\$'),
        IShortActionCarrier('string'),
        '@popall',
      ),
      ],
    'strings': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('\\\\\'\$'),
        IShortActionCarrier(''),
        '@popall',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\\''),
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\'\$'),
        IShortActionCarrier('string'),
        '@popall',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\''),
        IShortActionCarrier('string'),
        '@stringBody',
      ),
        IShortMonarchLanguageRule2(
        RegExp('"\$'),
        IShortActionCarrier('string'),
        '@popall',
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string'),
        '@dblStringBody',
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\s+'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': '',
              '@eos': <String, Object?>{
                'next': '@popall',
                'token': '',
              },
            },
        ),
      ),
      ],
  },
  defaultToken: '',
  tokenPostfix: '.dockerfile',
  extra: <String, Object?>{
      'variable': RegExp('\\\${?[\\w]+}?'),
    },
);
