// 1:1 translation of monaco-editor/src/languages/definitions/bat/bat.ts
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
    'lineComment': 'REM',
  },
  'folding': <String, Object?>{
    'markers': <String, Object?>{
      'end': RegExp('^\\s*(::\\s*|REM\\s+)#endregion'),
      'start': RegExp('^\\s*(::\\s*|REM\\s+)#region'),
    },
  },
  'surroundingPairs': <Object?>[
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
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('^(\\s*)(rem(?:\\s.*|))\$'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier(''),
          IShortActionCarrier('comment'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\@?)(@keywords)(?!\\w)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'keyword',
          ),
          IExpandedMonarchLanguageAction(
            token: 'keyword.\$2',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[ \\t\\r\\n]+'),
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule1(
        RegExp('setlocal(?!\\w)'),
        IShortActionCarrier('keyword.tag-setlocal'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('endlocal(?!\\w)'),
        IShortActionCarrier('keyword.tag-setlocal'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[a-zA-Z_]\\w*'),
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule1(
        RegExp(':\\w*'),
        IShortActionCarrier('metatag'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('%[^%]+%'),
        IShortActionCarrier('variable'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('%%[\\w]+(?!\\w)'),
        IShortActionCarrier('variable'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[{}()\\[\\]]'),
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@symbols'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d*\\.\\d+([eE][\\-+]?\\d+)?'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[xX][0-9a-fA-F_]*[0-9a-fA-F]'),
        IShortActionCarrier('number.hex'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d+'),
        IShortActionCarrier('number'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[;,.]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string'),
        '@string."',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\''),
        IShortActionCarrier('string'),
        '@string.\'',
      ),
      ],
    'string': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\"\'%]+'),
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
        RegExp('@escapes'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string.escape.invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('%[\\w ]+%'),
        IShortActionCarrier('variable'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('%%[\\w]+(?!\\w)'),
        IShortActionCarrier('variable'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('["\']'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$#==\$S2': <String, Object?>{
                'next': '@pop',
                'token': 'string',
              },
              '@default': 'string',
            },
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\$'),
        IShortActionCarrier('string'),
        '@popall',
      ),
      ],
  },
  ignoreCase: true,
  defaultToken: '',
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket('{', '}', 'delimiter.bracket'),
    IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
    IMonarchLanguageBracket('[', ']', 'delimiter.square'),
  ],
  tokenPostfix: '.bat',
  extra: <String, Object?>{
      'escapes': RegExp('\\\\(?:[abfnrtv\\\\"\']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})'),
      'keywords': RegExp('call|defined|echo|errorlevel|exist|for|goto|if|pause|set|shift|start|title|not|pushd|popd'),
      'symbols': RegExp('[=><!~?&|+\\-*\\/\\^;\\.,]+'),
    },
);
