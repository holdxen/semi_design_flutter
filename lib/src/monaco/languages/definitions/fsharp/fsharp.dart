// 1:1 translation of monaco-editor/src/languages/definitions/fsharp/fsharp.ts
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
    'blockComment': <Object?>[
      '(*',
      '*)',
    ],
    'lineComment': '//',
  },
  'folding': <String, Object?>{
    'markers': <String, Object?>{
      'end': RegExp('^\\s*\\/\\/\\s*#endregion\\b|^\\s*\\(\\*\\s*#endregion\\s*\\*\\)'),
      'start': RegExp('^\\s*\\/\\/\\s*#region\\b|^\\s*\\(\\*\\s*#region(.*)\\*\\)'),
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
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^*(]+'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\*\\)'),
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\*'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\(\\*\\)'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\('),
        IShortActionCarrier('comment'),
      ),
      ],
    'litstring': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"]+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('""'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.quote',
        ),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[a-zA-Z_]\\w*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'identifier',
              '@keywords': <String, Object?>{
                'token': 'keyword.\$0',
              },
            },
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\[<.*>\\]'),
        IShortActionCarrier('annotation'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^#(if|else|endif)'),
        IShortActionCarrier('keyword'),
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
        RegExp('\\d*\\d+[eE]([\\-+]?\\d+)?(@floatsuffix)'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d*\\.\\d+([eE][\\-+]?\\d+)?(@floatsuffix)'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0x[0-9a-fA-F]+LF'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0x[0-9a-fA-F]+(@integersuffix)'),
        IShortActionCarrier('number.hex'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0b[0-1]+(@integersuffix)'),
        IShortActionCarrier('number.bin'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d+(@integersuffix)'),
        IShortActionCarrier('number'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[;,.]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"\\\\]|\\\\.)*\$'),
        IShortActionCarrier('string.invalid'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"""'),
        IShortActionCarrier('string'),
        '@string."""',
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string'),
        '@string."',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\@"'),
        IExpandedMonarchLanguageAction(
          next: '@litstring',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'[^\\\\\']\'B?'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\')(@escapes)(\')'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('string'),
          IShortActionCarrier('string.escape'),
          IShortActionCarrier('string'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IShortActionCarrier('string.invalid'),
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
        RegExp('("""|"B?)'),
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
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[ \\t\\r\\n]+'),
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\(\\*(?!\\))'),
        IShortActionCarrier('comment'),
        '@comment',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\/\\/.*\$'),
        IShortActionCarrier('comment'),
      ),
      ],
  },
  defaultToken: '',
  tokenPostfix: '.fs',
  extra: <String, Object?>{
      'escapes': RegExp('\\\\(?:[abfnrtv\\\\"\']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})'),
      'floatsuffix': RegExp('[fFmM]?'),
      'integersuffix': RegExp('[uU]?[yslnLI]?'),
      'keywords': <Object?>[
        'abstract',
        'and',
        'atomic',
        'as',
        'assert',
        'asr',
        'base',
        'begin',
        'break',
        'checked',
        'component',
        'const',
        'constraint',
        'constructor',
        'continue',
        'class',
        'default',
        'delegate',
        'do',
        'done',
        'downcast',
        'downto',
        'elif',
        'else',
        'end',
        'exception',
        'eager',
        'event',
        'external',
        'extern',
        'false',
        'finally',
        'for',
        'fun',
        'function',
        'fixed',
        'functor',
        'global',
        'if',
        'in',
        'include',
        'inherit',
        'inline',
        'interface',
        'internal',
        'land',
        'lor',
        'lsl',
        'lsr',
        'lxor',
        'lazy',
        'let',
        'match',
        'member',
        'mod',
        'module',
        'mutable',
        'namespace',
        'method',
        'mixin',
        'new',
        'not',
        'null',
        'of',
        'open',
        'or',
        'object',
        'override',
        'private',
        'parallel',
        'process',
        'protected',
        'pure',
        'public',
        'rec',
        'return',
        'static',
        'sealed',
        'struct',
        'sig',
        'then',
        'to',
        'true',
        'tailcall',
        'trait',
        'try',
        'type',
        'upcast',
        'use',
        'val',
        'void',
        'virtual',
        'volatile',
        'when',
        'while',
        'with',
        'yield',
      ],
      'symbols': RegExp('[=><!~?:&|+\\-*\\^%;\\.,\\/]+'),
    },
);
