// 1:1 translation of monaco-editor/src/languages/definitions/css/css.ts
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
      'notIn': <Object?>[
        'string',
        'comment',
      ],
      'open': '{',
    },
    <String, Object?>{
      'close': ']',
      'notIn': <Object?>[
        'string',
        'comment',
      ],
      'open': '[',
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
      'close': '"',
      'notIn': <Object?>[
        'string',
        'comment',
      ],
      'open': '"',
    },
    <String, Object?>{
      'close': '\'',
      'notIn': <Object?>[
        'string',
        'comment',
      ],
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
  },
  'folding': <String, Object?>{
    'markers': <String, Object?>{
      'end': RegExp('^\\s*\\/\\*\\s*#endregion\\b.*\\*\\/'),
      'start': RegExp('^\\s*\\/\\*\\s*#region\\b\\s*(.*?)\\s*\\*\\/'),
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
  'wordPattern': RegExp('(#?-?\\d*\\.\\d\\w*%?)|((::|[@#.!:])?[\\w-?]+%?)|::|[@#.!:]'),
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        '\\*\\/',
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^*/]+'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('comment'),
      ),
      ],
    'comments': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        '\\/\\*',
        IShortActionCarrier('comment'),
        '@comment',
      ),
        IShortMonarchLanguageRule1(
        '\\/\\/+.*',
        IShortActionCarrier('comment'),
      ),
      ],
    'declarationbody': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@term',
      ),
        IShortMonarchLanguageRule2(
        ';',
        IShortActionCarrier('delimiter'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        '(?=})',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: '',
        ),
      ),
      ],
    'functionarguments': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '\\\$@identifier@ws:',
        IShortActionCarrier('attribute.name'),
      ),
        IShortMonarchLanguageRule1(
        '[,]',
        IShortActionCarrier('delimiter'),
      ),
        IExpandedMonarchLanguageRule(
        include: '@term',
      ),
        IShortMonarchLanguageRule1(
        '\\)',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'attribute.value',
        ),
      ),
      ],
    'functioninvocation': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '@identifier\\(',
        IExpandedMonarchLanguageAction(
          next: '@functionarguments',
          token: 'attribute.value',
        ),
      ),
      ],
    'import': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '[@](import)',
        IExpandedMonarchLanguageAction(
          next: '@declarationbody',
          token: 'keyword',
        ),
      ),
      ],
    'keyframebody': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@term',
      ),
        IShortMonarchLanguageRule1(
        '{',
        IExpandedMonarchLanguageAction(
          next: '@selectorbody',
          token: 'delimiter.bracket',
        ),
      ),
        IShortMonarchLanguageRule1(
        '}',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'delimiter.bracket',
        ),
      ),
      ],
    'keyframedeclaration': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '@identifier',
        IShortActionCarrier('attribute.value'),
      ),
        IShortMonarchLanguageRule1(
        '{',
        IExpandedMonarchLanguageAction(
          switchTo: '@keyframebody',
          token: 'delimiter.bracket',
        ),
      ),
      ],
    'name': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '@identifier',
        IShortActionCarrier('attribute.value'),
      ),
      ],
    'numbers': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '-?(\\d*\\.)?\\d+([eE][\\-+]?\\d+)?',
        IExpandedMonarchLanguageAction(
          next: '@units',
          token: 'attribute.value.number',
        ),
      ),
        IShortMonarchLanguageRule1(
        '#[0-9a-fA-F_]+(?!\\w)',
        IShortActionCarrier('attribute.value.hex'),
      ),
      ],
    'parenthizedterm': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@term',
      ),
        IShortMonarchLanguageRule1(
        '\\)',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'delimiter.parenthesis',
        ),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@selector',
      ),
      ],
    'rulevalue': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@comments',
      ),
        IExpandedMonarchLanguageRule(
        include: '@strings',
      ),
        IExpandedMonarchLanguageRule(
        include: '@term',
      ),
        IShortMonarchLanguageRule1(
        '!important',
        IShortActionCarrier('keyword'),
      ),
        IShortMonarchLanguageRule2(
        ';',
        IShortActionCarrier('delimiter'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        '(?=})',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: '',
        ),
      ),
      ],
    'selector': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@comments',
      ),
        IExpandedMonarchLanguageRule(
        include: '@import',
      ),
        IExpandedMonarchLanguageRule(
        include: '@strings',
      ),
        IShortMonarchLanguageRule1(
        '[@](keyframes|-webkit-keyframes|-moz-keyframes|-o-keyframes)',
        IExpandedMonarchLanguageAction(
          next: '@keyframedeclaration',
          token: 'keyword',
        ),
      ),
        IShortMonarchLanguageRule1(
        '[@](page|content|font-face|-moz-document)',
        IExpandedMonarchLanguageAction(
          token: 'keyword',
        ),
      ),
        IShortMonarchLanguageRule1(
        '[@](charset|namespace)',
        IExpandedMonarchLanguageAction(
          next: '@declarationbody',
          token: 'keyword',
        ),
      ),
        IShortMonarchLanguageRule1(
        '(url-prefix)(\\()',
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('attribute.value'),
          IExpandedMonarchLanguageAction(
            next: '@urldeclaration',
            token: 'delimiter.parenthesis',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        '(url)(\\()',
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('attribute.value'),
          IExpandedMonarchLanguageAction(
            next: '@urldeclaration',
            token: 'delimiter.parenthesis',
          ),
        ]),
      ),
        IExpandedMonarchLanguageRule(
        include: '@selectorname',
      ),
        IShortMonarchLanguageRule1(
        '[\\*]',
        IShortActionCarrier('tag'),
      ),
        IShortMonarchLanguageRule1(
        '[>\\+,]',
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        '\\[',
        IExpandedMonarchLanguageAction(
          next: '@selectorattribute',
          token: 'delimiter.bracket',
        ),
      ),
        IShortMonarchLanguageRule1(
        '{',
        IExpandedMonarchLanguageAction(
          next: '@selectorbody',
          token: 'delimiter.bracket',
        ),
      ),
      ],
    'selectorattribute': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@term',
      ),
        IShortMonarchLanguageRule1(
        ']',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'delimiter.bracket',
        ),
      ),
      ],
    'selectorbody': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@comments',
      ),
        IShortMonarchLanguageRule2(
        '[*_]?@identifier@ws:(?=(\\s|\\d|[^{;}]*[;}]))',
        IShortActionCarrier('attribute.name'),
        '@rulevalue',
      ),
        IShortMonarchLanguageRule1(
        '}',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'delimiter.bracket',
        ),
      ),
      ],
    'selectorname': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '(\\.|#(?=[^{])|%|(@identifier)|:)+',
        IShortActionCarrier('tag'),
      ),
      ],
    'stringenddoublequote': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '\\\\.',
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        '"',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\"]+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        '.',
        IShortActionCarrier('string'),
      ),
      ],
    'stringendquote': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '\\\\.',
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        '\'',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\\']+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        '.',
        IShortActionCarrier('string'),
      ),
      ],
    'strings': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '~?"',
        IExpandedMonarchLanguageAction(
          next: '@stringenddoublequote',
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        '~?\'',
        IExpandedMonarchLanguageAction(
          next: '@stringendquote',
          token: 'string',
        ),
      ),
      ],
    'term': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@comments',
      ),
        IShortMonarchLanguageRule1(
        '(url-prefix)(\\()',
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('attribute.value'),
          IExpandedMonarchLanguageAction(
            next: '@urldeclaration',
            token: 'delimiter.parenthesis',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        '(url)(\\()',
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('attribute.value'),
          IExpandedMonarchLanguageAction(
            next: '@urldeclaration',
            token: 'delimiter.parenthesis',
          ),
        ]),
      ),
        IExpandedMonarchLanguageRule(
        include: '@functioninvocation',
      ),
        IExpandedMonarchLanguageRule(
        include: '@numbers',
      ),
        IExpandedMonarchLanguageRule(
        include: '@name',
      ),
        IExpandedMonarchLanguageRule(
        include: '@strings',
      ),
        IShortMonarchLanguageRule1(
        '([<>=\\+\\-\\*\\/\\^\\|\\~,])',
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        ',',
        IShortActionCarrier('delimiter'),
      ),
      ],
    'units': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        '(em|ex|ch|rem|fr|vmin|vmax|vw|vh|vm|cm|mm|in|px|pt|pc|deg|grad|rad|turn|s|ms|Hz|kHz|%)?',
        IShortActionCarrier('attribute.value.unit'),
        '@pop',
      ),
      ],
    'urldeclaration': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@strings',
      ),
        IShortMonarchLanguageRule1(
        '[^)\r\n]+',
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        '\\)',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'delimiter.parenthesis',
        ),
      ),
      ],
    'warndebug': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '[@](warn|debug)',
        IExpandedMonarchLanguageAction(
          next: '@declarationbody',
          token: 'keyword',
        ),
      ),
      ],
  },
  defaultToken: '',
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket('{', '}', 'delimiter.bracket'),
    IMonarchLanguageBracket('[', ']', 'delimiter.bracket'),
    IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
    IMonarchLanguageBracket('<', '>', 'delimiter.angle'),
  ],
  tokenPostfix: '.css',
  extra: <String, Object?>{
      'identifier': '-?-?([a-zA-Z]|(\\\\(([0-9a-fA-F]{1,6}\\s?)|[^[0-9a-fA-F])))([\\w\\-]|(\\\\(([0-9a-fA-F]{1,6}\\s?)|[^[0-9a-fA-F])))*',
      'ws': '[ \t\n\r\f]*',
    },
);
