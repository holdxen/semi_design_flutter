// 1:1 translation of monaco-editor/src/languages/definitions/objective-c/objective-c.ts
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
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        '\\*\\/',
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        '.',
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
    'dblStringBody': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('[^\\\\"]+\$'),
        IShortActionCarrier('string'),
        '@popall',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\"]+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string.escape'),
        '@popall',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\\$'),
        IShortActionCarrier('string'),
      ),
      ],
    'numbers': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('0[xX][0-9a-fA-F]*(_?[0-9a-fA-F])*'),
        IShortActionCarrier('number.hex'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@decimal((\\.@decpart)?([eE][\\-+]?@decpart)?)[fF]*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$0': 'number.float',
              '(\\d)*': 'number',
            },
        ),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@comments',
      ),
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
        RegExp('[,:;]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[{}\\[\\]()<>]'),
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[a-zA-Z@#]\\w*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'identifier',
              '@keywords': 'keyword',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[<>=\\\\+\\\\-\\\\*\\\\/\\\\^\\\\|\\\\~,]|and\\\\b|or\\\\b|not\\\\b]'),
        IShortActionCarrier('operator'),
      ),
      ],
    'stringBody': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('[^\\\\\']+\$'),
        IShortActionCarrier('string'),
        '@popall',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\\']+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\''),
        IShortActionCarrier('string.escape'),
        '@popall',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\\$'),
        IShortActionCarrier('string'),
      ),
      ],
    'strings': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('\'\$'),
        IShortActionCarrier('string.escape'),
        '@popall',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\''),
        IShortActionCarrier('string.escape'),
        '@stringBody',
      ),
        IShortMonarchLanguageRule2(
        RegExp('"\$'),
        IShortActionCarrier('string.escape'),
        '@popall',
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string.escape'),
        '@dblStringBody',
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\s+'),
        IShortActionCarrier('white'),
      ),
      ],
  },
  defaultToken: '',
  tokenPostfix: '.objective-c',
  extra: <String, Object?>{
      'decimal': RegExp('0|@decpart'),
      'decpart': RegExp('\\d(_?\\d)*'),
      'keywords': <Object?>[
        '#import',
        '#include',
        '#define',
        '#else',
        '#endif',
        '#if',
        '#ifdef',
        '#ifndef',
        '#ident',
        '#undef',
        '@class',
        '@defs',
        '@dynamic',
        '@encode',
        '@end',
        '@implementation',
        '@interface',
        '@package',
        '@private',
        '@protected',
        '@property',
        '@protocol',
        '@public',
        '@selector',
        '@synthesize',
        '__declspec',
        'assign',
        'auto',
        'BOOL',
        'break',
        'bycopy',
        'byref',
        'case',
        'char',
        'Class',
        'const',
        'copy',
        'continue',
        'default',
        'do',
        'double',
        'else',
        'enum',
        'extern',
        'FALSE',
        'false',
        'float',
        'for',
        'goto',
        'if',
        'in',
        'int',
        'id',
        'inout',
        'IMP',
        'long',
        'nil',
        'nonatomic',
        'NULL',
        'oneway',
        'out',
        'private',
        'public',
        'protected',
        'readwrite',
        'readonly',
        'register',
        'return',
        'SEL',
        'self',
        'short',
        'signed',
        'sizeof',
        'static',
        'struct',
        'super',
        'switch',
        'typedef',
        'TRUE',
        'true',
        'union',
        'unsigned',
        'volatile',
        'void',
        'while',
      ],
    },
);
