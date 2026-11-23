// 1:1 translation of monaco-editor/src/languages/definitions/lexon/lexon.ts
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
      'close': '.',
      'open': ':',
    },
  ],
  'brackets': <Object?>[
    <Object?>[
      '(',
      ')',
    ],
  ],
  'comments': <String, Object?>{
    'lineComment': 'COMMENT',
  },
  'folding': <String, Object?>{
    'markers': <String, Object?>{
      'end': RegExp('^\\s*(::\\s*|COMMENT\\s+)#endregion'),
      'start': RegExp('^\\s*(::\\s*|COMMENT\\s+)#region'),
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
      'close': '`',
      'open': '`',
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
      'close': '.',
      'open': ':',
    },
  ],
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'identifier_rest': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\.]+'),
        IShortActionCarrier('identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\.'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          next: '@pop',
          token: 'delimiter',
        ),
      ),
      ],
    'identifier_until_period': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        ':',
        IExpandedMonarchLanguageAction(
          next: '@identifier_rest',
          token: 'delimiter',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\.]+'),
        IShortActionCarrier('identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\.'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          next: '@pop',
          token: 'delimiter',
        ),
      ),
      ],
    'quoted_identifier': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\"]+'),
        IShortActionCarrier('identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          next: '@pop',
          token: 'identifier.quote',
        ),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('^(\\s*)(comment:?(?:\\s.*|))\$'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier(''),
          IShortActionCarrier('comment'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@quoted_identifier',
          token: 'identifier.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        'LEX\$',
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@identifier_until_period',
          token: 'keyword',
        ),
      ),
        IShortMonarchLanguageRule1(
        'LEXON',
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@semver',
          token: 'keyword',
        ),
      ),
        IShortMonarchLanguageRule1(
        ':',
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@identifier_until_period',
          token: 'delimiter',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[a-z_\$][\\w\$]*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'identifier',
              '@keywords': 'keyword',
              '@operators': 'operator',
              '@typeKeywords': 'keyword.type',
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
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d*\\.\\d*\\.\\d*'),
        IShortActionCarrier('number.semver'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d*\\.\\d+([eE][\\-+]?\\d+)?'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[xX][0-9a-fA-F]+'),
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
      ],
    'semver': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        ':',
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d*\\.\\d*\\.\\d*'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          next: '@pop',
          token: 'number.semver',
        ),
      ),
      ],
    'space_identifier_until_period': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        ':',
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        ' ',
        IExpandedMonarchLanguageAction(
          next: '@identifier_rest',
          token: 'white',
        ),
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[ \\t\\r\\n]+'),
        IShortActionCarrier('white'),
      ),
      ],
  },
  ignoreCase: true,
  tokenPostfix: '.lexon',
  extra: <String, Object?>{
      'keywords': <Object?>[
        'lexon',
        'lex',
        'clause',
        'terms',
        'contracts',
        'may',
        'pay',
        'pays',
        'appoints',
        'into',
        'to',
      ],
      'operators': <Object?>[
        'less',
        'greater',
        'equal',
        'le',
        'gt',
        'or',
        'and',
        'add',
        'added',
        'subtract',
        'subtracted',
        'multiply',
        'multiplied',
        'times',
        'divide',
        'divided',
        'is',
        'be',
        'certified',
      ],
      'symbols': RegExp('[=><!~?:&|+\\-*\\/\\^%]+'),
      'typeKeywords': <Object?>[
        'amount',
        'person',
        'key',
        'time',
        'date',
        'asset',
        'text',
      ],
    },
);
