// 1:1 translation of monaco-editor/src/languages/definitions/graphql/graphql.ts
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
      'close': '"""',
      'notIn': <Object?>[
        'string',
        'comment',
      ],
      'open': '"""',
    },
    <String, Object?>{
      'close': '"',
      'notIn': <Object?>[
        'string',
        'comment',
      ],
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
    'lineComment': '#',
  },
  'folding': <String, Object?>{
    'offSide': true,
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
      'close': '"""',
      'open': '"""',
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
    'mlstring': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"]+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        '"""',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          nextEmbedded: '@pop',
          token: 'string',
        ),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[a-z_][\\w\$]*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'key.identifier',
              '@keywords': 'keyword',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\$][\\w\$]*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'argument.identifier',
              '@keywords': 'keyword',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[A-Z][\\w\\\$]*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'type.identifier',
              '@typeKeywords': 'keyword',
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
        RegExp('@symbols'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': '',
              '@operators': 'operator',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@\\s*[a-zA-Z_\\\$][\\w\\\$]*'),
        IExpandedMonarchLanguageAction(
          log: 'annotation token: \$0',
          token: 'annotation',
        ),
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
        IShortMonarchLanguageRule1(
        RegExp('"""'),
        IExpandedMonarchLanguageAction(
          next: '@mlstring',
          nextEmbedded: 'markdown',
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"\\\\]|\\\\.)*\$'),
        IShortActionCarrier('string.invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@string',
          token: 'string.quote',
        ),
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
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          next: '@pop',
          token: 'string.quote',
        ),
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[ \\t\\r\\n]+'),
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule1(
        RegExp('#.*\$'),
        IShortActionCarrier('comment'),
      ),
      ],
  },
  defaultToken: 'invalid',
  tokenPostfix: '.gql',
  extra: <String, Object?>{
      'directiveLocations': <Object?>[
        'SCHEMA',
        'SCALAR',
        'OBJECT',
        'FIELD_DEFINITION',
        'ARGUMENT_DEFINITION',
        'INTERFACE',
        'UNION',
        'ENUM',
        'ENUM_VALUE',
        'INPUT_OBJECT',
        'INPUT_FIELD_DEFINITION',
        'QUERY',
        'MUTATION',
        'SUBSCRIPTION',
        'FIELD',
        'FRAGMENT_DEFINITION',
        'FRAGMENT_SPREAD',
        'INLINE_FRAGMENT',
        'VARIABLE_DEFINITION',
      ],
      'escapes': RegExp('\\\\(?:["\\\\\\/bfnrt]|u[0-9A-Fa-f]{4})'),
      'keywords': <Object?>[
        'null',
        'true',
        'false',
        'query',
        'mutation',
        'subscription',
        'extend',
        'schema',
        'directive',
        'scalar',
        'type',
        'interface',
        'union',
        'enum',
        'input',
        'implements',
        'fragment',
        'on',
      ],
      'operators': <Object?>[
        '=',
        '!',
        '?',
        ':',
        '&',
        '|',
      ],
      'symbols': RegExp('[=!?:&|]+'),
      'typeKeywords': <Object?>[
        'Int',
        'Float',
        'String',
        'Boolean',
        'ID',
      ],
    },
);
