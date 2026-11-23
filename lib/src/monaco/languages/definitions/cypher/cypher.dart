// 1:1 translation of monaco-editor/src/languages/definitions/cypher/cypher.ts
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
    <String, Object?>{
      'close': '`',
      'open': '`',
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
      'close': '`',
      'open': '`',
    },
  ],
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\/\\/.*'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^/*]+'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\*\\/'),
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[/*]'),
        IShortActionCarrier('comment'),
      ),
      ],
    'common': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IExpandedMonarchLanguageRule(
        include: '@numbers',
      ),
        IExpandedMonarchLanguageRule(
        include: '@strings',
      ),
        IShortMonarchLanguageRule1(
        RegExp(':[a-zA-Z_][\\w]*'),
        IShortActionCarrier('type.identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[a-zA-Z_][\\w]*(?=\\()'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@builtinFunctions': 'predefined.function',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[a-zA-Z_\$][\\w\$]*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@builtinLiterals': 'predefined.literal',
              '@default': 'identifier',
              '@keywords': 'keyword',
            },
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('`'),
        IShortActionCarrier('identifier.escape'),
        '@identifierBacktick',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[;,.:|]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[<>=%+\\-*/^]+'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': '',
              '@operators': 'delimiter',
            },
        ),
      ),
      ],
    'identifierBacktick': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\`]+'),
        IShortActionCarrier('identifier.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IShortActionCarrier('identifier.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('identifier.escape.invalid'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('`'),
        IShortActionCarrier('identifier.escape'),
        '@pop',
      ),
      ],
    'numbers': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('-?(@digits)[eE](-?(@digits))?'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('-?(@digits)?\\.(@digits)([eE]-?(@digits))?'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('-?0x(@hexdigits)'),
        IShortActionCarrier('number.hex'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('-?0(@octaldigits)'),
        IShortActionCarrier('number.octal'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('-?(@digits)'),
        IShortActionCarrier('number'),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[{}[\\]()]'),
        IShortActionCarrier('@brackets'),
      ),
        IExpandedMonarchLanguageRule(
        include: 'common',
      ),
      ],
    'stringDouble': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\"]+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string.invalid'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string'),
        '@pop',
      ),
      ],
    'stringSingle': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\\']+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string.invalid'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\''),
        IShortActionCarrier('string'),
        '@pop',
      ),
      ],
    'strings': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('"([^"\\\\]|\\\\.)*\$'),
        IShortActionCarrier('string.invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\'\\\\]|\\\\.)*\$'),
        IShortActionCarrier('string.invalid'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string'),
        '@stringDouble',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\''),
        IShortActionCarrier('string'),
        '@stringSingle',
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[ \\t\\r\\n]+'),
        IShortActionCarrier('white'),
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
  ignoreCase: true,
  defaultToken: '',
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
    IMonarchLanguageBracket('[', ']', 'delimiter.bracket'),
    IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
  ],
  tokenPostfix: '.cypher',
  extra: <String, Object?>{
      'builtinFunctions': <Object?>[
        'abs',
        'acos',
        'asin',
        'atan',
        'atan2',
        'avg',
        'ceil',
        'coalesce',
        'collect',
        'cos',
        'cot',
        'count',
        'degrees',
        'e',
        'endNode',
        'exists',
        'exp',
        'floor',
        'head',
        'id',
        'keys',
        'labels',
        'last',
        'left',
        'length',
        'log',
        'log10',
        'lTrim',
        'max',
        'min',
        'nodes',
        'percentileCont',
        'percentileDisc',
        'pi',
        'properties',
        'radians',
        'rand',
        'range',
        'relationships',
        'replace',
        'reverse',
        'right',
        'round',
        'rTrim',
        'sign',
        'sin',
        'size',
        'split',
        'sqrt',
        'startNode',
        'stDev',
        'stDevP',
        'substring',
        'sum',
        'tail',
        'tan',
        'timestamp',
        'toBoolean',
        'toFloat',
        'toInteger',
        'toLower',
        'toString',
        'toUpper',
        'trim',
        'type',
      ],
      'builtinLiterals': <Object?>[
        'true',
        'TRUE',
        'false',
        'FALSE',
        'null',
        'NULL',
      ],
      'digits': RegExp('\\d+'),
      'escapes': RegExp('\\\\(?:[tbnrf\\\\"\'`]|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})'),
      'hexdigits': RegExp('[0-9a-fA-F]+'),
      'keywords': <Object?>[
        'ALL',
        'AND',
        'AS',
        'ASC',
        'ASCENDING',
        'BY',
        'CALL',
        'CASE',
        'CONTAINS',
        'CREATE',
        'DELETE',
        'DESC',
        'DESCENDING',
        'DETACH',
        'DISTINCT',
        'ELSE',
        'END',
        'ENDS',
        'EXISTS',
        'IN',
        'IS',
        'LIMIT',
        'MANDATORY',
        'MATCH',
        'MERGE',
        'NOT',
        'ON',
        'ON',
        'OPTIONAL',
        'OR',
        'ORDER',
        'REMOVE',
        'RETURN',
        'SET',
        'SKIP',
        'STARTS',
        'THEN',
        'UNION',
        'UNWIND',
        'WHEN',
        'WHERE',
        'WITH',
        'XOR',
        'YIELD',
      ],
      'octaldigits': RegExp('[0-7]+'),
      'operators': <Object?>[
        '+',
        '-',
        '*',
        '/',
        '%',
        '^',
        '=',
        '<>',
        '<',
        '>',
        '<=',
        '>=',
        '->',
        '<-',
        '-->',
        '<--',
      ],
    },
);
