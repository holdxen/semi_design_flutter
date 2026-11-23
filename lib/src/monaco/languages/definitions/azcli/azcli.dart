// 1:1 translation of monaco-editor/src/languages/definitions/azcli/azcli.ts
// Monarch language definition data, evaluated from the TS source via
// the TypeScript compiler (computed template/const values resolved).
// TS object literals -> Dart data; typed rule/action/bracket carriers
// mirror the ported monarchCompile. Regex flags preserved in RegExp.

import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchTypes.dart';

/// 1:1: `export const conf: languages.LanguageConfiguration = {...}`
final Map<String, Object?> conf = <String, Object?>{
  'comments': <String, Object?>{
    'lineComment': '#',
  },
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('#.*\$'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@eos': <String, Object?>{
                'next': '@popall',
                'token': 'comment',
              },
            },
        ),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@comment',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\s-+@str*\\s*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': <String, Object?>{
                'next': '@type',
                'token': 'key.identifier',
              },
              '@eos': <String, Object?>{
                'next': '@popall',
                'token': 'key.identifier',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^-+@str*\\s*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': <String, Object?>{
                'next': '@type',
                'token': 'key.identifier',
              },
              '@eos': <String, Object?>{
                'next': '@popall',
                'token': 'key.identifier',
              },
            },
        ),
      ),
      ],
    'type': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@comment',
      ),
        IShortMonarchLanguageRule1(
        RegExp('-+@str*\\s*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'key.identifier',
              '@eos': <String, Object?>{
                'next': '@popall',
                'token': 'key.identifier',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@str+\\s*'),
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
      ],
  },
  ignoreCase: true,
  defaultToken: 'keyword',
  tokenPostfix: '.azcli',
  extra: <String, Object?>{
      'str': RegExp('[^#\\s]'),
    },
);
