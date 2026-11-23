// 1:1 translation of monaco-editor/src/languages/definitions/handlebars/handlebars.ts
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
      '{{',
      '}}',
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
      '{{!--',
      '--}}',
    ],
  },
  'onEnterRules': <Object?>[
    <String, Object?>{
      'action': <String, Object?>{
        'indentAction': 2,
      },
      'afterText': RegExp('^<\\/(\\w[\\w\\d]*)\\s*>\$', caseSensitive: false),
      'beforeText': RegExp('<(?!(?:area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr))(\\w[\\w\\d]*)([^/>]*(?!\\/)>)[^<]*\$', caseSensitive: false),
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
      'close': '>',
      'open': '<',
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
  'wordPattern': RegExp('(-?\\d*\\.\\d\\w*)|([^\\`\\~\\!\\@\\\$\\^\\&\\*\\(\\)\\=\\+\\[\\{\\]\\}\\\\\\|\\;\\:\\\'\\"\\,\\.\\<\\>\\/\\s]+)'),
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('\\}\\}'),
        IShortActionCarrier('comment.end.handlebars'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('comment.content.handlebars'),
      ),
      ],
    'commentBlock': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('--\\}\\}'),
        IShortActionCarrier('comment.block.end.handlebars'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('comment.content.handlebars'),
      ),
      ],
    'commentHtml': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\{\\{'),
        IExpandedMonarchLanguageAction(
          switchTo: '@handlebarsInSimpleState.comment',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('-->'),
        IShortActionCarrier('comment.html'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^-]+'),
        IShortActionCarrier('comment.content.html'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('comment.content.html'),
      ),
      ],
    'doctype': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\{\\{'),
        IExpandedMonarchLanguageAction(
          switchTo: '@handlebarsInSimpleState.comment',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^>]+'),
        IShortActionCarrier('metatag.content.html'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('>'),
        IShortActionCarrier('metatag.html'),
        '@pop',
      ),
      ],
    'handlebarsInEmbeddedState': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\{\\{\\{?'),
        IShortActionCarrier('delimiter.handlebars'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\}\\}\\}?'),
        IExpandedMonarchLanguageAction(
          nextEmbedded: '\$S3',
          switchTo: '@\$S2.\$S3',
          token: 'delimiter.handlebars',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: 'handlebarsRoot',
      ),
      ],
    'handlebarsInSimpleState': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\{\\{\\{?'),
        IShortActionCarrier('delimiter.handlebars'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\}\\}\\}?'),
        IExpandedMonarchLanguageAction(
          switchTo: '@\$S2.\$S3',
          token: 'delimiter.handlebars',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: 'handlebarsRoot',
      ),
      ],
    'handlebarsRoot': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('"[^"]*"'),
        IShortActionCarrier('string.handlebars'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[#/][^\\s}]+'),
        IShortActionCarrier('keyword.helper.handlebars'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('else\\b'),
        IShortActionCarrier('keyword.helper.handlebars'),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[\\s]+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^}]'),
        IShortActionCarrier('variable.parameter.handlebars'),
      ),
      ],
    'otherTag': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\{\\{'),
        IExpandedMonarchLanguageAction(
          switchTo: '@handlebarsInSimpleState.otherTag',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\/?>'),
        IShortActionCarrier('delimiter.html'),
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
        RegExp('\\{\\{!--'),
        IShortActionCarrier('comment.block.start.handlebars'),
        '@commentBlock',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\{\\{!'),
        IShortActionCarrier('comment.start.handlebars'),
        '@comment',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\{\\{'),
        IExpandedMonarchLanguageAction(
          switchTo: '@handlebarsInSimpleState.root',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('<!DOCTYPE'),
        IShortActionCarrier('metatag.html'),
        '@doctype',
      ),
        IShortMonarchLanguageRule2(
        RegExp('<!--'),
        IShortActionCarrier('comment.html'),
        '@commentHtml',
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<)(\\w+)(\\/>)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter.html'),
          IShortActionCarrier('tag.html'),
          IShortActionCarrier('delimiter.html'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<)(script)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter.html'),
          IExpandedMonarchLanguageAction(
            next: '@script',
            token: 'tag.html',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<)(style)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter.html'),
          IExpandedMonarchLanguageAction(
            next: '@style',
            token: 'tag.html',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<)([:\\w]+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter.html'),
          IExpandedMonarchLanguageAction(
            next: '@otherTag',
            token: 'tag.html',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<\\/)(\\w+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter.html'),
          IExpandedMonarchLanguageAction(
            next: '@otherTag',
            token: 'tag.html',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<'),
        IShortActionCarrier('delimiter.html'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\{'),
        IShortActionCarrier('delimiter.html'),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[^<{]+'),
      ),
      ],
    'script': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\{\\{'),
        IExpandedMonarchLanguageAction(
          switchTo: '@handlebarsInSimpleState.script',
          token: '@rematch',
        ),
      ),
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
          next: '@scriptEmbedded.text/javascript',
          nextEmbedded: 'text/javascript',
          token: 'delimiter.html',
        ),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<\\/)(script\\s*)(>)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter.html'),
          IShortActionCarrier('tag.html'),
          IExpandedMonarchLanguageAction(
            next: '@pop',
            token: 'delimiter.html',
          ),
        ]),
      ),
      ],
    'scriptAfterType': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\{\\{'),
        IExpandedMonarchLanguageAction(
          switchTo: '@handlebarsInSimpleState.scriptAfterType',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('='),
        IShortActionCarrier('delimiter'),
        '@scriptAfterTypeEquals',
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@scriptEmbedded.text/javascript',
          nextEmbedded: 'text/javascript',
          token: 'delimiter.html',
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
        RegExp('\\{\\{'),
        IExpandedMonarchLanguageAction(
          switchTo: '@handlebarsInSimpleState.scriptAfterTypeEquals',
          token: '@rematch',
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
          next: '@scriptEmbedded.text/javascript',
          nextEmbedded: 'text/javascript',
          token: 'delimiter.html',
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
        RegExp('\\{\\{'),
        IExpandedMonarchLanguageAction(
          nextEmbedded: '@pop',
          switchTo: '@handlebarsInEmbeddedState.scriptEmbedded.\$S2',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<\\/script'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          nextEmbedded: '@pop',
          token: '@rematch',
        ),
      ),
      ],
    'scriptWithCustomType': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\{\\{'),
        IExpandedMonarchLanguageAction(
          switchTo: '@handlebarsInSimpleState.scriptWithCustomType.\$S2',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@scriptEmbedded.\$S2',
          nextEmbedded: '\$S2',
          token: 'delimiter.html',
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
        IShortMonarchLanguageRule1(
        RegExp('\\{\\{'),
        IExpandedMonarchLanguageAction(
          switchTo: '@handlebarsInSimpleState.style',
          token: '@rematch',
        ),
      ),
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
          next: '@styleEmbedded.text/css',
          nextEmbedded: 'text/css',
          token: 'delimiter.html',
        ),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<\\/)(style\\s*)(>)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter.html'),
          IShortActionCarrier('tag.html'),
          IExpandedMonarchLanguageAction(
            next: '@pop',
            token: 'delimiter.html',
          ),
        ]),
      ),
      ],
    'styleAfterType': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\{\\{'),
        IExpandedMonarchLanguageAction(
          switchTo: '@handlebarsInSimpleState.styleAfterType',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('='),
        IShortActionCarrier('delimiter'),
        '@styleAfterTypeEquals',
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@styleEmbedded.text/css',
          nextEmbedded: 'text/css',
          token: 'delimiter.html',
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
        RegExp('\\{\\{'),
        IExpandedMonarchLanguageAction(
          switchTo: '@handlebarsInSimpleState.styleAfterTypeEquals',
          token: '@rematch',
        ),
      ),
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
          next: '@styleEmbedded.text/css',
          nextEmbedded: 'text/css',
          token: 'delimiter.html',
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
        RegExp('\\{\\{'),
        IExpandedMonarchLanguageAction(
          nextEmbedded: '@pop',
          switchTo: '@handlebarsInEmbeddedState.styleEmbedded.\$S2',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<\\/style'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          nextEmbedded: '@pop',
          token: '@rematch',
        ),
      ),
      ],
    'styleWithCustomType': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\{\\{'),
        IExpandedMonarchLanguageAction(
          switchTo: '@handlebarsInSimpleState.styleWithCustomType.\$S2',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@styleEmbedded.\$S2',
          nextEmbedded: '\$S2',
          token: 'delimiter.html',
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
  defaultToken: '',
  tokenPostfix: '',
);
