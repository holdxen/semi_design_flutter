// 1:1 translation of monaco-editor/src/languages/definitions/r/r.ts
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
    'lineComment': '#',
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
  ],
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'dblStringBody': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'error-token',
              '@special': 'string',
            },
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string.escape'),
        '@popall',
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('string'),
      ),
      ],
    'numbers': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('0[xX][0-9a-fA-F]+'),
        IShortActionCarrier('number.hex'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('-?(\\d*\\.)?\\d+([eE][+\\-]?\\d+)?'),
        IShortActionCarrier('number'),
      ),
      ],
    'operators': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('<{1,2}-'),
        IShortActionCarrier('operator'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('->{1,2}'),
        IShortActionCarrier('operator'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('%[^%\\s]+%'),
        IShortActionCarrier('operator'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\*\\*'),
        IShortActionCarrier('operator'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('%%'),
        IShortActionCarrier('operator'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('&&'),
        IShortActionCarrier('operator'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\|\\|'),
        IShortActionCarrier('operator'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<<'),
        IShortActionCarrier('operator'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>>'),
        IShortActionCarrier('operator'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[-+=&|!<>^~*/:\$]'),
        IShortActionCarrier('operator'),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@numbers',
      ),
        IExpandedMonarchLanguageRule(
        include: '@strings',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[{}\\[\\]()]'),
        IShortActionCarrier('@brackets'),
      ),
        IExpandedMonarchLanguageRule(
        include: '@operators',
      ),
        IShortMonarchLanguageRule1(
        RegExp('#\'\$'),
        IShortActionCarrier('comment.doc'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('#\''),
        IShortActionCarrier('comment.doc'),
        '@roxygen',
      ),
        IShortMonarchLanguageRule1(
        RegExp('(^#.*\$)'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\s+'),
        IShortActionCarrier('white'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[,:;]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@[a-zA-Z]\\w*'),
        IShortActionCarrier('tag'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[a-zA-Z]\\w*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@constants': 'constant',
              '@default': 'identifier',
              '@keywords': 'keyword',
            },
        ),
      ),
      ],
    'roxygen': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('@\\w+'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'comment.doc',
              '@eos': <String, Object?>{
                'next': '@pop',
                'token': 'comment.doc',
              },
              '@roxygen': 'tag',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\s+'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'comment.doc',
              '@eos': <String, Object?>{
                'next': '@pop',
                'token': 'comment.doc',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.*'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'comment.doc',
        ),
      ),
      ],
    'stringBody': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'error-token',
              '@special': 'string',
            },
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\''),
        IShortActionCarrier('string.escape'),
        '@popall',
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('string'),
      ),
      ],
    'strings': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('\''),
        IShortActionCarrier('string.escape'),
        '@stringBody',
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string.escape'),
        '@dblStringBody',
      ),
      ],
  },
  defaultToken: '',
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
    IMonarchLanguageBracket('[', ']', 'delimiter.bracket'),
    IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
  ],
  tokenPostfix: '.r',
  extra: <String, Object?>{
      'constants': <Object?>[
        'NULL',
        'FALSE',
        'TRUE',
        'NA',
        'Inf',
        'NaN',
        'NA_integer_',
        'NA_real_',
        'NA_complex_',
        'NA_character_',
        'T',
        'F',
        'LETTERS',
        'letters',
        'month.abb',
        'month.name',
        'pi',
        'R.version.string',
      ],
      'keywords': <Object?>[
        'break',
        'next',
        'return',
        'if',
        'else',
        'for',
        'in',
        'repeat',
        'while',
        'array',
        'category',
        'character',
        'complex',
        'double',
        'function',
        'integer',
        'list',
        'logical',
        'matrix',
        'numeric',
        'vector',
        'data.frame',
        'factor',
        'library',
        'require',
        'attach',
        'detach',
        'source',
      ],
      'roxygen': <Object?>[
        '@alias',
        '@aliases',
        '@assignee',
        '@author',
        '@backref',
        '@callGraph',
        '@callGraphDepth',
        '@callGraphPrimitives',
        '@concept',
        '@describeIn',
        '@description',
        '@details',
        '@docType',
        '@encoding',
        '@evalNamespace',
        '@evalRd',
        '@example',
        '@examples',
        '@export',
        '@exportClass',
        '@exportMethod',
        '@exportPattern',
        '@family',
        '@field',
        '@formals',
        '@format',
        '@import',
        '@importClassesFrom',
        '@importFrom',
        '@importMethodsFrom',
        '@include',
        '@inherit',
        '@inheritDotParams',
        '@inheritParams',
        '@inheritSection',
        '@keywords',
        '@md',
        '@method',
        '@name',
        '@noMd',
        '@noRd',
        '@note',
        '@param',
        '@rawNamespace',
        '@rawRd',
        '@rdname',
        '@references',
        '@return',
        '@S3method',
        '@section',
        '@seealso',
        '@setClass',
        '@slot',
        '@source',
        '@template',
        '@templateVar',
        '@title',
        '@TODO',
        '@usage',
        '@useDynLib',
      ],
      'special': <Object?>[
        '\\n',
        '\\r',
        '\\t',
        '\\b',
        '\\a',
        '\\f',
        '\\v',
        '\\\'',
        '\\"',
        '\\\\',
      ],
    },
);
