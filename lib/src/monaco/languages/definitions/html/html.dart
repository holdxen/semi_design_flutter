// 1:1 translation of monaco-editor/src/languages/definitions/html/html.ts
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
      '<!--',
      '-->',
    ],
    <Object?>[
      '<',
      '>',
    ],
    <Object?>[
      '{',
      '}',
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
      'end': RegExp('^\\s*<!--\\s*#endregion\\b.*-->'),
      'start': RegExp('^\\s*<!--\\s*#region\\b.*-->'),
    },
  },
  'onEnterRules': <Object?>[
    <String, Object?>{
      'action': <String, Object?>{
        'indentAction': 2,
      },
      'afterText': RegExp('^<\\/([_:\\w][_:\\w-.\\d]*)\\s*>\$', caseSensitive: false),
      'beforeText': RegExp('<(?!(?:area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr))([_:\\w][_:\\w-.\\d]*)([^/>]*(?!\\/)>)[^<]*\$', caseSensitive: false),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'indentAction': 1,
      },
      'beforeText': RegExp('<(?!(?:area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr))(\\w[\\w\\d]*)([^/>]*(?!\\/)>)[^<]*\$', caseSensitive: false),
    },
  ],
  'surroundingPairs': <Object?>[
    <String, Object?>{
      'close': '"',
      'open': '"',
    },
    <String, Object?>{
      'close': '\'',
      'open': '\'',
    },
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
      'open': '<',
    },
  ],
  'wordPattern': RegExp('(-?\\d*\\.\\d\\w*)|([^\\`\\~\\!\\@\\\$\\^\\&\\*\\(\\)\\=\\+\\[\\{\\]\\}\\\\\\|\\;\\:\\\'\\"\\,\\.\\<\\>\\/\\s]+)'),
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('-->'),
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^-]+'),
        IShortActionCarrier('comment.content'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('comment.content'),
      ),
      ],
    'doctype': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^>]+'),
        IShortActionCarrier('metatag.content'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('>'),
        IShortActionCarrier('metatag'),
        '@pop',
      ),
      ],
    'otherTag': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('\\/?>'),
        IShortActionCarrier('delimiter'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"]*)"'),
        IShortActionCarrier('attribute.value'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\']*)\''),
        IShortActionCarrier('attribute.value'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\w\\-]+'),
        IShortActionCarrier('attribute.name'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('delimiter'),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('<!DOCTYPE'),
        IShortActionCarrier('metatag'),
        '@doctype',
      ),
        IShortMonarchLanguageRule2(
        RegExp('<!--'),
        IShortActionCarrier('comment'),
        '@comment',
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<)((?:[\\w\\-]+:)?[\\w\\-]+)(\\s*)(\\/>)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter'),
          IShortActionCarrier('tag'),
          IShortActionCarrier(''),
          IShortActionCarrier('delimiter'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<)(script)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter'),
          IExpandedMonarchLanguageAction(
            next: '@script',
            token: 'tag',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<)(style)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter'),
          IExpandedMonarchLanguageAction(
            next: '@style',
            token: 'tag',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<)((?:[\\w\\-]+:)?[\\w\\-]+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter'),
          IExpandedMonarchLanguageAction(
            next: '@otherTag',
            token: 'tag',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<\\/)((?:[\\w\\-]+:)?[\\w\\-]+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter'),
          IExpandedMonarchLanguageAction(
            next: '@otherTag',
            token: 'tag',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<'),
        IShortActionCarrier('delimiter'),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[^<]+'),
      ),
      ],
    'script': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('type'),
        IShortActionCarrier('attribute.name'),
        '@scriptAfterType',
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"]*)"'),
        IShortActionCarrier('attribute.value'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\']*)\''),
        IShortActionCarrier('attribute.value'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\w\\-]+'),
        IShortActionCarrier('attribute.name'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@scriptEmbedded',
          nextEmbedded: 'text/javascript',
          token: 'delimiter',
        ),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<\\/)(script\\s*)(>)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter'),
          IShortActionCarrier('tag'),
          IExpandedMonarchLanguageAction(
            next: '@pop',
            token: 'delimiter',
          ),
        ]),
      ),
      ],
    'scriptAfterType': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('='),
        IShortActionCarrier('delimiter'),
        '@scriptAfterTypeEquals',
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@scriptEmbedded',
          nextEmbedded: 'text/javascript',
          token: 'delimiter',
        ),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<\\/script\\s*>'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: '@rematch',
        ),
      ),
      ],
    'scriptAfterTypeEquals': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('"module"'),
        IExpandedMonarchLanguageAction(
          switchTo: '@scriptWithCustomType.text/javascript',
          token: 'attribute.value',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'module\''),
        IExpandedMonarchLanguageAction(
          switchTo: '@scriptWithCustomType.text/javascript',
          token: 'attribute.value',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"]*)"'),
        IExpandedMonarchLanguageAction(
          switchTo: '@scriptWithCustomType.\$1',
          token: 'attribute.value',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\']*)\''),
        IExpandedMonarchLanguageAction(
          switchTo: '@scriptWithCustomType.\$1',
          token: 'attribute.value',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@scriptEmbedded',
          nextEmbedded: 'text/javascript',
          token: 'delimiter',
        ),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<\\/script\\s*>'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: '@rematch',
        ),
      ),
      ],
    'scriptEmbedded': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('<\\/script'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          nextEmbedded: '@pop',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<]+'),
        IShortActionCarrier(''),
      ),
      ],
    'scriptWithCustomType': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@scriptEmbedded.\$S2',
          nextEmbedded: '\$S2',
          token: 'delimiter',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"]*)"'),
        IShortActionCarrier('attribute.value'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\']*)\''),
        IShortActionCarrier('attribute.value'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\w\\-]+'),
        IShortActionCarrier('attribute.name'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('delimiter'),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<\\/script\\s*>'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: '@rematch',
        ),
      ),
      ],
    'style': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('type'),
        IShortActionCarrier('attribute.name'),
        '@styleAfterType',
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"]*)"'),
        IShortActionCarrier('attribute.value'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\']*)\''),
        IShortActionCarrier('attribute.value'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\w\\-]+'),
        IShortActionCarrier('attribute.name'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@styleEmbedded',
          nextEmbedded: 'text/css',
          token: 'delimiter',
        ),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<\\/)(style\\s*)(>)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter'),
          IShortActionCarrier('tag'),
          IExpandedMonarchLanguageAction(
            next: '@pop',
            token: 'delimiter',
          ),
        ]),
      ),
      ],
    'styleAfterType': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('='),
        IShortActionCarrier('delimiter'),
        '@styleAfterTypeEquals',
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@styleEmbedded',
          nextEmbedded: 'text/css',
          token: 'delimiter',
        ),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<\\/style\\s*>'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: '@rematch',
        ),
      ),
      ],
    'styleAfterTypeEquals': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('"([^"]*)"'),
        IExpandedMonarchLanguageAction(
          switchTo: '@styleWithCustomType.\$1',
          token: 'attribute.value',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\']*)\''),
        IExpandedMonarchLanguageAction(
          switchTo: '@styleWithCustomType.\$1',
          token: 'attribute.value',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@styleEmbedded',
          nextEmbedded: 'text/css',
          token: 'delimiter',
        ),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<\\/style\\s*>'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: '@rematch',
        ),
      ),
      ],
    'styleEmbedded': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('<\\/style'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          nextEmbedded: '@pop',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<]+'),
        IShortActionCarrier(''),
      ),
      ],
    'styleWithCustomType': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@styleEmbedded.\$S2',
          nextEmbedded: '\$S2',
          token: 'delimiter',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"]*)"'),
        IShortActionCarrier('attribute.value'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\']*)\''),
        IShortActionCarrier('attribute.value'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\w\\-]+'),
        IShortActionCarrier('attribute.name'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('delimiter'),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<\\/style\\s*>'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: '@rematch',
        ),
      ),
      ],
  },
  ignoreCase: true,
  defaultToken: '',
  tokenPostfix: '.html',
);
