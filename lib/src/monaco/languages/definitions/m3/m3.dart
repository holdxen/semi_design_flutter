// 1:1 translation of monaco-editor/src/languages/definitions/m3/m3.ts
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
      'close': '}',
      'open': '{',
    },
    <String, Object?>{
      'close': ')',
      'open': '(',
    },
    <String, Object?>{
      'close': '*)',
      'open': '(*',
    },
    <String, Object?>{
      'close': '*>',
      'open': '<*',
    },
    <String, Object?>{
      'close': '\'',
      'notIn': <Object?>[
        'string',
        'comment',
      ],
      'open': '\'',
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
    'blockComment': <Object?>[
      '(*',
      '*)',
    ],
  },
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('\\(\\*'),
        IShortActionCarrier('comment'),
        '@push',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\*\\)'),
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('comment'),
      ),
      ],
    'pragma': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('<\\*'),
        IShortActionCarrier('keyword.pragma'),
        '@push',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\*>'),
        IShortActionCarrier('keyword.pragma'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('keyword.pragma'),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('_\\w*'),
        IShortActionCarrier('invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[a-zA-Z][a-zA-Z0-9_]*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'identifier',
              '@keywords': <String, Object?>{
                'token': 'keyword.\$0',
              },
              '@reservedConstNames': <String, Object?>{
                'token': 'constant.reserved.\$0',
              },
              '@reservedTypeNames': <String, Object?>{
                'token': 'type.reserved.\$0',
              },
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
        RegExp('[0-9]+\\.[0-9]+(?:[DdEeXx][\\+\\-]?[0-9]+)?'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[0-9]+(?:\\_[0-9a-fA-F]+)?L?'),
        IShortActionCarrier('number'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@symbols'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'invalid',
              '@delimiters': 'delimiter',
              '@operators': 'operators',
              '@relations': 'operators',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'[^\\\\\']\''),
        IShortActionCarrier('string.char'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\')(@escapes)(\')'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('string.char'),
          IShortActionCarrier('string.escape'),
          IShortActionCarrier('string.char'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IShortActionCarrier('invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"\\\\]|\\\\.)*\$'),
        IShortActionCarrier('invalid'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string.text'),
        '@text',
      ),
      ],
    'text': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\"]+'),
        IShortActionCarrier('string.text'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('invalid'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string.text'),
        '@pop',
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[ \\t\\r\\n]+'),
        IShortActionCarrier('white'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\(\\*'),
        IShortActionCarrier('comment'),
        '@comment',
      ),
        IShortMonarchLanguageRule2(
        RegExp('<\\*'),
        IShortActionCarrier('keyword.pragma'),
        '@pragma',
      ),
      ],
  },
  defaultToken: '',
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
    IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
    IMonarchLanguageBracket('[', ']', 'delimiter.square'),
  ],
  tokenPostfix: '.m3',
  extra: <String, Object?>{
      'delimiters': <Object?>[
        '|',
        '..',
        '=>',
        ',',
        ';',
        ':=',
      ],
      'escapes': RegExp('\\\\(?:[\\\\fnrt"\']|[0-7]{3})'),
      'keywords': <Object?>[
        'AND',
        'ANY',
        'ARRAY',
        'AS',
        'BEGIN',
        'BITS',
        'BRANDED',
        'BY',
        'CASE',
        'CONST',
        'DIV',
        'DO',
        'ELSE',
        'ELSIF',
        'END',
        'EVAL',
        'EXCEPT',
        'EXCEPTION',
        'EXIT',
        'EXPORTS',
        'FINALLY',
        'FOR',
        'FROM',
        'GENERIC',
        'IF',
        'IMPORT',
        'IN',
        'INTERFACE',
        'LOCK',
        'LOOP',
        'METHODS',
        'MOD',
        'MODULE',
        'NOT',
        'OBJECT',
        'OF',
        'OR',
        'OVERRIDES',
        'PROCEDURE',
        'RAISE',
        'RAISES',
        'READONLY',
        'RECORD',
        'REF',
        'REPEAT',
        'RETURN',
        'REVEAL',
        'SET',
        'THEN',
        'TO',
        'TRY',
        'TYPE',
        'TYPECASE',
        'UNSAFE',
        'UNTIL',
        'UNTRACED',
        'VALUE',
        'VAR',
        'WHILE',
        'WITH',
      ],
      'operators': <Object?>[
        '+',
        '-',
        '*',
        '/',
        '&',
        '^',
        '.',
      ],
      'relations': <Object?>[
        '=',
        '#',
        '<',
        '<=',
        '>',
        '>=',
        '<:',
        ':',
      ],
      'reservedConstNames': <Object?>[
        'ABS',
        'ADR',
        'ADRSIZE',
        'BITSIZE',
        'BYTESIZE',
        'CEILING',
        'DEC',
        'DISPOSE',
        'FALSE',
        'FIRST',
        'FLOAT',
        'FLOOR',
        'INC',
        'ISTYPE',
        'LAST',
        'LOOPHOLE',
        'MAX',
        'MIN',
        'NARROW',
        'NEW',
        'NIL',
        'NUMBER',
        'ORD',
        'ROUND',
        'SUBARRAY',
        'TRUE',
        'TRUNC',
        'TYPECODE',
        'VAL',
      ],
      'reservedTypeNames': <Object?>[
        'ADDRESS',
        'ANY',
        'BOOLEAN',
        'CARDINAL',
        'CHAR',
        'EXTENDED',
        'INTEGER',
        'LONGCARD',
        'LONGINT',
        'LONGREAL',
        'MUTEX',
        'NULL',
        'REAL',
        'REFANY',
        'ROOT',
        'TEXT',
      ],
      'symbols': RegExp('[>=<#.,:;+\\-*/&^]+'),
    },
);
