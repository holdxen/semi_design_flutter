// 1:1 translation of monaco-editor/src/languages/definitions/scala/scala.ts
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
  'comments': <String, Object?>{
    'blockComment': <Object?>[
      '/*',
      '*/',
    ],
    'lineComment': '//',
  },
  'folding': <String, Object?>{
    'markers': <String, Object?>{
      'end': RegExp('^\\s*\\/\\/\\s*(?:(?:#?endregion\\b)|(?:<\\/editor-fold>))'),
      'start': RegExp('^\\s*\\/\\/\\s*(?:(?:#?region\\b)|(?:<editor-fold\\b))'),
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
      'close': '"',
      'open': '"',
    },
    <String, Object?>{
      'close': '\'',
      'open': '\'',
    },
  ],
  'wordPattern': RegExp('(unary_[@~!#%^&*()\\-=+\\\\|:<>\\/?]+)|([a-zA-Z_\$][\\w\$]*?_=)|(`[^`]+`)|([a-zA-Z_\$][\\w\$]*)'),
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'allowMethod': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('^|\$'),
        IShortActionCarrier(''),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[ \\t]+'),
        IShortActionCarrier('white'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('[\\n\\r]+'),
        IShortActionCarrier('white'),
        '@pop',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\/\\*'),
        IShortActionCarrier('comment'),
        '@comment',
      ),
        IShortMonarchLanguageRule2(
        RegExp('(?==>[\\s\\w([{])'),
        IShortActionCarrier('keyword'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@name|@symbols)(?=[ \\t]*[[({"\'`]|[ \\t]+(?:[+-]?\\.?\\d|\\w))'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '->|<-|>:|<:|<%': <String, Object?>{
                'next': '@pop',
                'token': 'keyword',
              },
              '@default': <String, Object?>{
                'next': '@pop',
                'token': '@rematch',
              },
              '@keywords': <String, Object?>{
                'next': '@pop',
                'token': 'keyword',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule2(
        '',
        IShortActionCarrier(''),
        '@pop',
      ),
      ],
    'case': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\b_\\*'),
        IShortActionCarrier('key'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\b(_|true|false|null|this|super)\\b'),
        IShortActionCarrier('keyword'),
        '@allowMethod',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\bif\\b|=>'),
        IShortActionCarrier('keyword'),
        '@pop',
      ),
        IShortMonarchLanguageRule2(
        RegExp('`[^`]+`'),
        IShortActionCarrier('identifier'),
        '@allowMethod',
      ),
        IShortMonarchLanguageRule2(
        RegExp('@name'),
        IShortActionCarrier('variable'),
        '@allowMethod',
      ),
        IShortMonarchLanguageRule1(
        RegExp(':::?|\\||@(?![a-z_\$])'),
        IShortActionCarrier('keyword'),
      ),
        IExpandedMonarchLanguageRule(
        include: '@root',
      ),
      ],
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\/*]+'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\/\\*'),
        IShortActionCarrier('comment'),
        '@push',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\*\\/'),
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\/*]'),
        IShortActionCarrier('comment'),
      ),
      ],
    'fstring': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          switchTo: '@allowMethod',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$\\\$'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\\$)([a-z_]\\w*)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('operator'),
          IShortActionCarrier('identifier'),
        ]),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\\$\\{'),
        IShortActionCarrier('operator'),
        '@interp',
      ),
        IShortMonarchLanguageRule1(
        RegExp('%%'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(%)([\\-#+ 0,(])(\\d+|\\.\\d+|\\d+\\.\\d+)(@fstring_conv)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('metatag'),
          IShortActionCarrier('keyword.modifier'),
          IShortActionCarrier('number'),
          IShortActionCarrier('metatag'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(%)(\\d+|\\.\\d+|\\d+\\.\\d+)(@fstring_conv)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('metatag'),
          IShortActionCarrier('number'),
          IShortActionCarrier('metatag'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(%)([\\-#+ 0,(])(@fstring_conv)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('metatag'),
          IShortActionCarrier('keyword.modifier'),
          IShortActionCarrier('metatag'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(%)(@fstring_conv)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('metatag'),
          IShortActionCarrier('metatag'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('string'),
      ),
      ],
    'fstringt': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"(?=""")'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"""'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          switchTo: '@allowMethod',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$\\\$'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\\$)([a-z_]\\w*)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('operator'),
          IShortActionCarrier('identifier'),
        ]),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\\$\\{'),
        IShortActionCarrier('operator'),
        '@interp',
      ),
        IShortMonarchLanguageRule1(
        RegExp('%%'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(%)([\\-#+ 0,(])(\\d+|\\.\\d+|\\d+\\.\\d+)(@fstring_conv)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('metatag'),
          IShortActionCarrier('keyword.modifier'),
          IShortActionCarrier('number'),
          IShortActionCarrier('metatag'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(%)(\\d+|\\.\\d+|\\d+\\.\\d+)(@fstring_conv)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('metatag'),
          IShortActionCarrier('number'),
          IShortActionCarrier('metatag'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(%)([\\-#+ 0,(])(@fstring_conv)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('metatag'),
          IShortActionCarrier('keyword.modifier'),
          IShortActionCarrier('metatag'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(%)(@fstring_conv)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('metatag'),
          IShortActionCarrier('metatag'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('string'),
      ),
      ],
    'import': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp(';'),
        IShortActionCarrier('delimiter'),
        '@pop',
      ),
        IShortMonarchLanguageRule2(
        RegExp('^|\$'),
        IShortActionCarrier(''),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[ \\t]+'),
        IShortActionCarrier('white'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('[\\n\\r]+'),
        IShortActionCarrier('white'),
        '@pop',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\/\\*'),
        IShortActionCarrier('comment'),
        '@comment',
      ),
        IShortMonarchLanguageRule1(
        RegExp('@name|@type'),
        IShortActionCarrier('type'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[(){}]'),
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[[\\]]'),
        IShortActionCarrier('operator.square'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\.,]'),
        IShortActionCarrier('delimiter'),
      ),
      ],
    'interp': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('{'),
        IShortActionCarrier('operator'),
        '@push',
      ),
        IShortMonarchLanguageRule2(
        RegExp('}'),
        IShortActionCarrier('operator'),
        '@pop',
      ),
        IExpandedMonarchLanguageRule(
        include: '@root',
      ),
      ],
    'rawstring': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"]'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          switchTo: '@allowMethod',
          token: 'string.quote',
        ),
      ),
      ],
    'rawstringt': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"]'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"(?=""")'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"""'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          switchTo: '@allowMethod',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IShortActionCarrier('string'),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\braw"""'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@rawstringt',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\braw"'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@rawstring',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\bs"""'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@sstringt',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\bs"'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@sstring',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\bf""""'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@fstringt',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\bf"'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@fstring',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"""'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@stringt',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@string',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('(@digits)[eE]([\\-+]?(@digits))?[fFdD]?'),
        IShortActionCarrier('number.float'),
        '@allowMethod',
      ),
        IShortMonarchLanguageRule2(
        RegExp('(@digits)\\.(@digits)([eE][\\-+]?(@digits))?[fFdD]?'),
        IShortActionCarrier('number.float'),
        '@allowMethod',
      ),
        IShortMonarchLanguageRule2(
        RegExp('0[xX](@hexdigits)[Ll]?'),
        IShortActionCarrier('number.hex'),
        '@allowMethod',
      ),
        IShortMonarchLanguageRule2(
        RegExp('(@digits)[fFdD]'),
        IShortActionCarrier('number.float'),
        '@allowMethod',
      ),
        IShortMonarchLanguageRule2(
        RegExp('(@digits)[lL]?'),
        IShortActionCarrier('number'),
        '@allowMethod',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\b_\\*'),
        IShortActionCarrier('key'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\b(_)\\b'),
        IShortActionCarrier('keyword'),
        '@allowMethod',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\bimport\\b'),
        IShortActionCarrier('keyword'),
        '@import',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\b(case)([ \\t]+)(class)\\b'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('keyword.modifier'),
          IShortActionCarrier('white'),
          IShortActionCarrier('keyword'),
        ]),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\bcase\\b'),
        IShortActionCarrier('keyword'),
        '@case',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\bva[lr]\\b'),
        IShortActionCarrier('keyword'),
        '@vardef',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\b(def)([ \\t]+)((?:unary_)?@symbols|@name(?:_=)|@name)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('keyword'),
          IShortActionCarrier('white'),
          IShortActionCarrier('identifier'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@name(?=[ \\t]*:(?!:))'),
        IShortActionCarrier('variable'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\.)(@name|@symbols)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('operator'),
          IExpandedMonarchLanguageAction(
            next: '@allowMethod',
            token: '@rematch',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('([{(])(\\s*)(@name(?=\\s*=>))'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('@brackets'),
          IShortActionCarrier('white'),
          IShortActionCarrier('variable'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@name'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@constants': <String, Object?>{
                'next': '@allowMethod',
                'token': 'constant',
              },
              '@default': <String, Object?>{
                'next': '@allowMethod',
                'token': 'identifier',
              },
              '@keywords': 'keyword',
              '@modifiers': 'keyword.modifier',
              '@softKeywords': 'keyword',
              '@softModifiers': 'keyword.modifier',
            },
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('@type'),
        IShortActionCarrier('type'),
        '@allowMethod',
      ),
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('@[a-zA-Z_\$][\\w\$]*(?:\\.[a-zA-Z_\$][\\w\$]*)*'),
        IShortActionCarrier('annotation'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[{(]'),
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('[})]'),
        IShortActionCarrier('@brackets'),
        '@allowMethod',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\['),
        IShortActionCarrier('operator.square'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('](?!\\s*(?:va[rl]|def|type)\\b)'),
        IShortActionCarrier('operator.square'),
        '@allowMethod',
      ),
        IShortMonarchLanguageRule1(
        RegExp(']'),
        IShortActionCarrier('operator.square'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('([=-]>|<-|>:|<:|:>|<%)(?=[\\s\\w()[\\]{},\\."\'`])'),
        IShortActionCarrier('keyword'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@symbols'),
        IShortActionCarrier('operator'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[;,\\.]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'[a-zA-Z\$][\\w\$]*(?!\')'),
        IShortActionCarrier('attribute.name'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\'[^\\\\\']\''),
        IShortActionCarrier('string'),
        '@allowMethod',
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\')(@escapes)(\')'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('string'),
          IShortActionCarrier('string.escape'),
          IExpandedMonarchLanguageAction(
            next: '@allowMethod',
            token: 'string',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IShortActionCarrier('string.invalid'),
      ),
      ],
    'sstring': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          switchTo: '@allowMethod',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$\\\$'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\\$)([a-z_]\\w*)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('operator'),
          IShortActionCarrier('identifier'),
        ]),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\\$\\{'),
        IShortActionCarrier('operator'),
        '@interp',
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('string'),
      ),
      ],
    'sstringt': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"(?=""")'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"""'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          switchTo: '@allowMethod',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$\\\$'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\\$)([a-z_]\\w*)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('operator'),
          IShortActionCarrier('identifier'),
        ]),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\\$\\{'),
        IShortActionCarrier('operator'),
        '@interp',
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('string'),
      ),
      ],
    'string': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\"\\n\\r]+'),
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
          switchTo: '@allowMethod',
          token: 'string.quote',
        ),
      ),
      ],
    'stringt': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\"\\n\\r]+'),
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
        RegExp('"(?=""")'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"""'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          switchTo: '@allowMethod',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IShortActionCarrier('string'),
      ),
      ],
    'vardef': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\b_\\*'),
        IShortActionCarrier('key'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\b(_|true|false|null|this|super)\\b'),
        IShortActionCarrier('keyword'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@name'),
        IShortActionCarrier('variable'),
      ),
        IShortMonarchLanguageRule1(
        RegExp(':::?|\\||@(?![a-z_\$])'),
        IShortActionCarrier('keyword'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('=|:(?!:)'),
        IShortActionCarrier('operator'),
        '@pop',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\$'),
        IShortActionCarrier('white'),
        '@pop',
      ),
        IExpandedMonarchLanguageRule(
        include: '@root',
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
  tokenPostfix: '.scala',
  extra: <String, Object?>{
      'constants': <Object?>[
        'true',
        'false',
        'null',
        'this',
        'super',
      ],
      'digits': RegExp('\\d+(_+\\d+)*'),
      'escapes': RegExp('\\\\(?:[btnfr\\\\"\']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})'),
      'fstring_conv': RegExp('[bBhHsScCdoxXeEfgGaAt]|[Tn](?:[HIklMSLNpzZsQ]|[BbhAaCYyjmde]|[RTrDFC])'),
      'hexdigits': RegExp('[[0-9a-fA-F]+(_+[0-9a-fA-F]+)*'),
      'keywords': <Object?>[
        'asInstanceOf',
        'catch',
        'class',
        'classOf',
        'def',
        'do',
        'else',
        'extends',
        'finally',
        'for',
        'foreach',
        'forSome',
        'if',
        'import',
        'isInstanceOf',
        'macro',
        'match',
        'new',
        'object',
        'package',
        'return',
        'throw',
        'trait',
        'try',
        'type',
        'until',
        'val',
        'var',
        'while',
        'with',
        'yield',
        'given',
        'enum',
        'then',
      ],
      'modifiers': <Object?>[
        'abstract',
        'final',
        'implicit',
        'lazy',
        'override',
        'private',
        'protected',
        'sealed',
      ],
      'name': RegExp('(?:[a-z_\$][\\w\$]*|`[^`]+`)'),
      'softKeywords': <Object?>[
        'as',
        'export',
        'extension',
        'end',
        'derives',
        'on',
      ],
      'softModifiers': <Object?>[
        'inline',
        'opaque',
        'open',
        'transparent',
        'using',
      ],
      'symbols': RegExp('[=><!~?:&|+\\-*\\/^\\\\%@#]+'),
      'type': RegExp('(?:[A-Z][\\w\$]*)'),
    },
);
