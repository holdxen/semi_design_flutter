// 1:1 translation of monaco-editor/src/languages/definitions/markdown/markdown.ts
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
      'close': '>',
      'notIn': <Object?>[
        'string',
      ],
      'open': '<',
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
      '<!--',
      '-->',
    ],
  },
  'folding': <String, Object?>{
    'markers': <String, Object?>{
      'end': RegExp('^\\s*<!--\\s*#?endregion\\b.*-->'),
      'start': RegExp('^\\s*<!--\\s*#?region\\b.*-->'),
    },
  },
  'surroundingPairs': <Object?>[
    <String, Object?>{
      'close': ')',
      'open': '(',
    },
    <String, Object?>{
      'close': ']',
      'open': '[',
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
    'codeblock': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('^\\s*~~~\\s*\$'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^\\s*```\\s*\$'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.*\$'),
        IShortActionCarrier('variable.source'),
      ),
      ],
    'codeblockgh': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('```\\s*\$'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          nextEmbedded: '@pop',
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^`]+'),
        IShortActionCarrier('variable.source'),
      ),
      ],
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^<\\-]+'),
        IShortActionCarrier('comment.content'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('-->'),
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('<!--'),
        IShortActionCarrier('comment.content.invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[<\\-]'),
        IShortActionCarrier('comment.content'),
      ),
      ],
    'embeddedScript': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^<]+'),
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<\\/script\\s*>'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          nextEmbedded: '@pop',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<'),
        IShortActionCarrier(''),
      ),
      ],
    'embeddedStyle': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^<]+'),
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<\\/style\\s*>'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          nextEmbedded: '@pop',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<'),
        IShortActionCarrier(''),
      ),
      ],
    'html': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('<(\\w+)\\/>'),
        IShortActionCarrier('tag'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<(\\w+)(\\-|\\w)*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': <String, Object?>{
                'next': '@tag.\$1',
                'token': 'tag',
              },
              '@empty': <String, Object?>{
                'next': '@tag.\$1',
                'token': 'tag',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<\\/(\\w+)(\\-|\\w)*\\s*>'),
        IExpandedMonarchLanguageAction(
          token: 'tag',
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('<!--'),
        IShortActionCarrier('comment'),
        '@comment',
      ),
      ],
    'linecontent': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('&\\w+;'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IShortActionCarrier('escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\b__([^\\\\_]|@escapes|_(?!_))+__\\b'),
        IShortActionCarrier('strong'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\*\\*([^\\\\*]|@escapes|\\*(?!\\*))+\\*\\*'),
        IShortActionCarrier('strong'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\b_[^_]+_\\b'),
        IShortActionCarrier('emphasis'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\*([^\\\\*]|@escapes)+\\*'),
        IShortActionCarrier('emphasis'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('`([^\\\\`]|@escapes)+`'),
        IShortActionCarrier('variable'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\{+[^}]+\\}+'),
        IShortActionCarrier('string.target'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(!?\\[)((?:[^\\]\\\\]|@escapes)*)(\\]\\([^\\)]+\\))'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('string.link'),
          IShortActionCarrier(''),
          IShortActionCarrier('string.link'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(!?\\[)((?:[^\\]\\\\]|@escapes)*)(\\])'),
        IShortActionCarrier('string.link'),
      ),
        IExpandedMonarchLanguageRule(
        include: 'html',
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('^\\s*\\|'),
        IShortActionCarrier('@rematch'),
        '@table_header',
      ),
        IShortMonarchLanguageRule1(
        RegExp('^(\\s{0,3})(#+)((?:[^\\\\#]|@escapes)+)((?:#+)?)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('white'),
          IShortActionCarrier('keyword'),
          IShortActionCarrier('keyword'),
          IShortActionCarrier('keyword'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^\\s*(=+|\\-+)\\s*\$'),
        IShortActionCarrier('keyword'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^\\s*((\\*[ ]?)+)\\s*\$'),
        IShortActionCarrier('meta.separator'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^\\s*>+'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^\\s*([\\*\\-+:]|\\d+\\.)\\s'),
        IShortActionCarrier('keyword'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^(\\t|[ ]{4})[^ ].*\$'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^\\s*~~~\\s*((?:\\w|[\\/\\-#])+)?\\s*\$'),
        IExpandedMonarchLanguageAction(
          next: '@codeblock',
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^\\s*```\\s*((?:\\w|[\\/\\-#])+).*\$'),
        IExpandedMonarchLanguageAction(
          next: '@codeblockgh',
          nextEmbedded: '\$1',
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^\\s*```\\s*\$'),
        IExpandedMonarchLanguageAction(
          next: '@codeblock',
          token: 'string',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@linecontent',
      ),
      ],
    'table_body': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@table_common',
      ),
        IExpandedMonarchLanguageRule(
        include: '@linecontent',
      ),
      ],
    'table_common': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\s*[\\-:]+\\s*'),
        IExpandedMonarchLanguageAction(
          switchTo: 'table_body',
          token: 'keyword',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^\\s*\\|'),
        IShortActionCarrier('keyword.table.left'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('^\\s*[^\\|]'),
        IShortActionCarrier('@rematch'),
        '@pop',
      ),
        IShortMonarchLanguageRule2(
        RegExp('^\\s*\$'),
        IShortActionCarrier('@rematch'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\|'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'keyword.table.middle',
              '@eos': 'keyword.table.right',
            },
        ),
      ),
      ],
    'table_header': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@table_common',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\|]+'),
        IShortActionCarrier('keyword.table.header'),
      ),
      ],
    'tag': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[ \\t\\r\\n]+'),
        IShortActionCarrier('white'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(type)(\\s*=\\s*)(")([^"]+)(")'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('attribute.name.html'),
          IShortActionCarrier('delimiter.html'),
          IShortActionCarrier('string.html'),
          IExpandedMonarchLanguageAction(
            switchTo: '@tag.\$S2.\$4',
            token: 'string.html',
          ),
          IShortActionCarrier('string.html'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(type)(\\s*=\\s*)(\')([^\']+)(\')'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('attribute.name.html'),
          IShortActionCarrier('delimiter.html'),
          IShortActionCarrier('string.html'),
          IExpandedMonarchLanguageAction(
            switchTo: '@tag.\$S2.\$4',
            token: 'string.html',
          ),
          IShortActionCarrier('string.html'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\w+)(\\s*=\\s*)("[^"]*"|\'[^\']*\')'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('attribute.name.html'),
          IShortActionCarrier('delimiter.html'),
          IShortActionCarrier('string.html'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\w+'),
        IShortActionCarrier('attribute.name.html'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\/>'),
        IShortActionCarrier('tag'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==script': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S3': <String, Object?>{
                    'nextEmbedded': '\$S3',
                    'switchTo': 'embeddedScript',
                    'token': 'tag',
                  },
                  '@default': <String, Object?>{
                    'nextEmbedded': 'text/javascript',
                    'switchTo': 'embeddedScript',
                    'token': 'tag',
                  },
                },
              },
              '\$S2==style': <String, Object?>{
                'nextEmbedded': 'text/css',
                'switchTo': 'embeddedStyle',
                'token': 'tag',
              },
              '@default': <String, Object?>{
                'next': '@pop',
                'token': 'tag',
              },
            },
        ),
      ),
      ],
  },
  defaultToken: '',
  tokenPostfix: '.md',
  extra: <String, Object?>{
      'control': RegExp('[\\\\`*_\\[\\]{}()#+\\-\\.!]'),
      'empty': <Object?>[
        'area',
        'base',
        'basefont',
        'br',
        'col',
        'frame',
        'hr',
        'img',
        'input',
        'isindex',
        'link',
        'meta',
        'param',
      ],
      'escapes': RegExp('\\\\(?:@control)'),
      'jsescapes': RegExp('\\\\(?:[btnfr\\\\"\']|[0-7][0-7]?|[0-3][0-7]{2})'),
      'noncontrol': RegExp('[^\\\\`*_\\[\\]{}()#+\\-\\.!]'),
    },
);
