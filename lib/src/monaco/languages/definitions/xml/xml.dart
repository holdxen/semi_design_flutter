// 1:1 translation of monaco-editor/src/languages/definitions/xml/xml.ts
// Monarch language definition data, evaluated from the TS source via
// the TypeScript compiler (computed template/const values resolved).
// TS object literals -> Dart data; typed rule/action/bracket carriers
// mirror the ported monarchCompile. Regex flags preserved in RegExp.

import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchTypes.dart';

/// 1:1: `export const conf: languages.LanguageConfiguration = {...}`
final Map<String, Object?> conf = <String, Object?>{
  'autoClosingPairs': <Object?>[
    <String, Object?>{
      'close': '>',
      'open': '<',
    },
    <String, Object?>{
      'close': '\'',
      'open': '\'',
    },
    <String, Object?>{
      'close': '"',
      'open': '"',
    },
  ],
  'brackets': <Object?>[
    <Object?>[
      '<',
      '>',
    ],
  ],
  'comments': <String, Object?>{
    'blockComment': <Object?>[
      '<!--',
      '-->',
    ],
  },
  'onEnterRules': <Object?>[
    <String, Object?>{
      'action': <String, Object?>{
        'indentAction': 2,
      },
      'afterText': RegExp('^<\\/([_:\\w][_:\\w-.\\d]*)\\s*>\$', caseSensitive: false),
      'beforeText': RegExp('<([_:\\w][_:\\w-.\\d]*)([^/>]*(?!\\/)>)[^<]*\$', caseSensitive: false),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'indentAction': 1,
      },
      'beforeText': RegExp('<(\\w[\\w\\d]*)([^/>]*(?!\\/)>)[^<]*\$', caseSensitive: false),
    },
  ],
  'surroundingPairs': <Object?>[
    <String, Object?>{
      'close': '>',
      'open': '<',
    },
    <String, Object?>{
      'close': '\'',
      'open': '\'',
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
    'cdata': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\]]+'),
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\]\\]>'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'delimiter.cdata',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\]'),
        IShortActionCarrier(''),
      ),
      ],
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^<\\-]+'),
        IShortActionCarrier('comment.content'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('-->'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'comment',
        ),
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
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^<&]+'),
        IShortActionCarrier(''),
      ),
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<)(@qualifiedName)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter',
          ),
          IExpandedMonarchLanguageAction(
            next: '@tag',
            token: 'tag',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<\\/)(@qualifiedName)(\\s*)(>)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IShortActionCarrier(''),
          IExpandedMonarchLanguageAction(
            token: 'delimiter',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<\\?)(@qualifiedName)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter',
          ),
          IExpandedMonarchLanguageAction(
            next: '@tag',
            token: 'metatag',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<\\!)(@qualifiedName)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter',
          ),
          IExpandedMonarchLanguageAction(
            next: '@tag',
            token: 'metatag',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<\\!\\[CDATA\\['),
        IExpandedMonarchLanguageAction(
          next: '@cdata',
          token: 'delimiter.cdata',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('&\\w+;'),
        IShortActionCarrier('string.escape'),
      ),
      ],
    'tag': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[ \\t\\r\\n]+'),
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@qualifiedName)(\\s*=\\s*)("[^"]*"|\'[^\']*\')'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('attribute.name'),
          IShortActionCarrier(''),
          IShortActionCarrier('attribute.value'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@qualifiedName)(\\s*=\\s*)("[^">?\\/]*|\'[^\'>?\\/]*)(?=[\\?\\/]\\>)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('attribute.name'),
          IShortActionCarrier(''),
          IShortActionCarrier('attribute.value'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@qualifiedName)(\\s*=\\s*)("[^">]*|\'[^\'>]*)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('attribute.name'),
          IShortActionCarrier(''),
          IShortActionCarrier('attribute.value'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@qualifiedName'),
        IShortActionCarrier('attribute.name'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\?>'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'delimiter',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\/)(>)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            next: '@pop',
            token: 'delimiter',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'delimiter',
        ),
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[ \\t\\r\\n]+'),
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<!--'),
        IExpandedMonarchLanguageAction(
          next: '@comment',
          token: 'comment',
        ),
      ),
      ],
  },
  ignoreCase: true,
  defaultToken: '',
  tokenPostfix: '.xml',
  extra: <String, Object?>{
      'qualifiedName': RegExp('(?:[\\w\\.\\-]+:)?[\\w\\.\\-]+'),
    },
);
