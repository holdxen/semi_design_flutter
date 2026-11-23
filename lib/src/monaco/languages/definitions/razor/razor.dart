// 1:1 translation of monaco-editor/src/languages/definitions/razor/razor.ts
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
      'close': '"',
      'open': '"',
    },
    <String, Object?>{
      'close': '\'',
      'open': '\'',
    },
    <String, Object?>{
      'close': '>',
      'open': '<',
    },
  ],
  'wordPattern': RegExp('(-?\\d*\\.\\d\\w*)|([^\\`\\~\\!\\@\\\$\\^\\&\\*\\(\\)\\-\\=\\+\\[\\{\\]\\}\\\\\\|\\;\\:\\\'\\"\\,\\.\\<\\>\\/\\s]+)'),
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('@[^@]'),
        IExpandedMonarchLanguageAction(
          switchTo: '@razorInSimpleState.comment',
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
        RegExp('@[^@]'),
        IExpandedMonarchLanguageAction(
          switchTo: '@razorInSimpleState.comment',
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
    'otherTag': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('@[^@]'),
        IExpandedMonarchLanguageAction(
          switchTo: '@razorInSimpleState.otherTag',
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
    'razorBlockComment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('\\*@'),
        IShortActionCarrier('comment.cs'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^*]+'),
        IShortActionCarrier('comment.cs'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('comment.cs'),
      ),
      ],
    'razorBlockCommentTopLevel': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('\\*@'),
        IShortActionCarrier('@rematch'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^*]+'),
        IShortActionCarrier('comment.cs'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('comment.cs'),
      ),
      ],
    'razorCommon': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[a-zA-Z_]\\w*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'identifier.cs',
              '@razorKeywords': <String, Object?>{
                'token': 'keyword.cs',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\[\\]]'),
        IShortActionCarrier('delimiter.array.cs'),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\/\\/.*\$'),
        IShortActionCarrier('comment.cs'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('@\\*'),
        IShortActionCarrier('comment.cs'),
        '@razorBlockComment',
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"]*)"'),
        IShortActionCarrier('string.cs'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\']*)\''),
        IShortActionCarrier('string.cs'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<)([\\w\\-]+)(\\/>)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter.html'),
          IShortActionCarrier('tag.html'),
          IShortActionCarrier('delimiter.html'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<)([\\w\\-]+)(>)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter.html'),
          IShortActionCarrier('tag.html'),
          IShortActionCarrier('delimiter.html'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<\\/)([\\w\\-]+)(>)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter.html'),
          IShortActionCarrier('tag.html'),
          IShortActionCarrier('delimiter.html'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\+\\-\\*\\%\\&\\|\\^\\~\\!\\=\\<\\>\\/\\?\\;\\:\\.\\,]'),
        IShortActionCarrier('delimiter.cs'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d*\\d+[eE]([\\-+]?\\d+)?'),
        IShortActionCarrier('number.float.cs'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d*\\.\\d+([eE][\\-+]?\\d+)?'),
        IShortActionCarrier('number.float.cs'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[xX][0-9a-fA-F\']*[0-9a-fA-F]'),
        IShortActionCarrier('number.hex.cs'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[0-7\']*[0-7]'),
        IShortActionCarrier('number.octal.cs'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[bB][0-1\']*[0-1]'),
        IShortActionCarrier('number.binary.cs'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d[\\d\']*'),
        IShortActionCarrier('number.cs'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d'),
        IShortActionCarrier('number.cs'),
      ),
      ],
    'razorInEmbeddedState': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('@\\*'),
        IShortActionCarrier('comment.cs'),
        '@razorBlockCommentTopLevel',
      ),
        IShortMonarchLanguageRule2(
        RegExp('@[{(]'),
        IShortActionCarrier('metatag.cs'),
        '@razorRootTopLevel',
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@)(\\s*[\\w]+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('metatag.cs'),
          IExpandedMonarchLanguageAction(
            nextEmbedded: '\$S3',
            switchTo: '@\$S2.\$S3',
            token: 'identifier.cs',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[})]'),
        IExpandedMonarchLanguageAction(
          nextEmbedded: '\$S3',
          switchTo: '@\$S2.\$S3',
          token: 'metatag.cs',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\*@'),
        IExpandedMonarchLanguageAction(
          nextEmbedded: '\$S3',
          switchTo: '@\$S2.\$S3',
          token: 'comment.cs',
        ),
      ),
      ],
    'razorInSimpleState': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('@\\*'),
        IShortActionCarrier('comment.cs'),
        '@razorBlockCommentTopLevel',
      ),
        IShortMonarchLanguageRule2(
        RegExp('@[{(]'),
        IShortActionCarrier('metatag.cs'),
        '@razorRootTopLevel',
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@)(\\s*[\\w]+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('metatag.cs'),
          IExpandedMonarchLanguageAction(
            switchTo: '@\$S2.\$S3',
            token: 'identifier.cs',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[})]'),
        IExpandedMonarchLanguageAction(
          switchTo: '@\$S2.\$S3',
          token: 'metatag.cs',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\*@'),
        IExpandedMonarchLanguageAction(
          switchTo: '@\$S2.\$S3',
          token: 'comment.cs',
        ),
      ),
      ],
    'razorRoot': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('\\{'),
        IShortActionCarrier('delimiter.bracket.cs'),
        '@razorRoot',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\('),
        IShortActionCarrier('delimiter.parenthesis.cs'),
        '@razorRoot',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\}'),
        IShortActionCarrier('delimiter.bracket.cs'),
        '@pop',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\)'),
        IShortActionCarrier('delimiter.parenthesis.cs'),
        '@pop',
      ),
        IExpandedMonarchLanguageRule(
        include: 'razorCommon',
      ),
      ],
    'razorRootTopLevel': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('\\{'),
        IShortActionCarrier('delimiter.bracket.cs'),
        '@razorRoot',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\('),
        IShortActionCarrier('delimiter.parenthesis.cs'),
        '@razorRoot',
      ),
        IShortMonarchLanguageRule2(
        RegExp('[})]'),
        IShortActionCarrier('@rematch'),
        '@pop',
      ),
        IExpandedMonarchLanguageRule(
        include: 'razorCommon',
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
          regex: RegExp('@@@@'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@[^@]'),
        IExpandedMonarchLanguageAction(
          switchTo: '@razorInSimpleState.root',
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
        '@comment',
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<)([\\w\\-]+)(\\/>)'),
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
        RegExp('(<)([:\\w\\-]+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter.html'),
          IExpandedMonarchLanguageAction(
            next: '@otherTag',
            token: 'tag.html',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<\\/)([\\w\\-]+)'),
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
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[^<@]+'),
      ),
      ],
    'script': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('@[^@]'),
        IExpandedMonarchLanguageAction(
          switchTo: '@razorInSimpleState.script',
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
        RegExp('@[^@]'),
        IExpandedMonarchLanguageAction(
          switchTo: '@razorInSimpleState.scriptAfterType',
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
        RegExp('@[^@]'),
        IExpandedMonarchLanguageAction(
          switchTo: '@razorInSimpleState.scriptAfterTypeEquals',
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
        RegExp('@[^@]'),
        IExpandedMonarchLanguageAction(
          nextEmbedded: '@pop',
          switchTo: '@razorInEmbeddedState.scriptEmbedded.\$S2',
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
        RegExp('@[^@]'),
        IExpandedMonarchLanguageAction(
          switchTo: '@razorInSimpleState.scriptWithCustomType.\$S2',
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
        RegExp('@[^@]'),
        IExpandedMonarchLanguageAction(
          switchTo: '@razorInSimpleState.style',
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
        RegExp('@[^@]'),
        IExpandedMonarchLanguageAction(
          switchTo: '@razorInSimpleState.styleAfterType',
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
        RegExp('@[^@]'),
        IExpandedMonarchLanguageAction(
          switchTo: '@razorInSimpleState.styleAfterTypeEquals',
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
        RegExp('@[^@]'),
        IExpandedMonarchLanguageAction(
          nextEmbedded: '@pop',
          switchTo: '@razorInEmbeddedState.styleEmbedded.\$S2',
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
        RegExp('@[^@]'),
        IExpandedMonarchLanguageAction(
          switchTo: '@razorInSimpleState.styleWithCustomType.\$S2',
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
  extra: <String, Object?>{
      'escapes': RegExp('\\\\(?:[abfnrtv\\\\"\']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})'),
      'razorKeywords': <Object?>[
        'abstract',
        'as',
        'async',
        'await',
        'base',
        'bool',
        'break',
        'by',
        'byte',
        'case',
        'catch',
        'char',
        'checked',
        'class',
        'const',
        'continue',
        'decimal',
        'default',
        'delegate',
        'do',
        'double',
        'descending',
        'explicit',
        'event',
        'extern',
        'else',
        'enum',
        'false',
        'finally',
        'fixed',
        'float',
        'for',
        'foreach',
        'from',
        'goto',
        'group',
        'if',
        'implicit',
        'in',
        'int',
        'interface',
        'internal',
        'into',
        'is',
        'lock',
        'long',
        'nameof',
        'new',
        'null',
        'namespace',
        'object',
        'operator',
        'out',
        'override',
        'orderby',
        'params',
        'private',
        'protected',
        'public',
        'readonly',
        'ref',
        'return',
        'switch',
        'struct',
        'sbyte',
        'sealed',
        'short',
        'sizeof',
        'stackalloc',
        'static',
        'string',
        'select',
        'this',
        'throw',
        'true',
        'try',
        'typeof',
        'uint',
        'ulong',
        'unchecked',
        'unsafe',
        'ushort',
        'using',
        'var',
        'virtual',
        'volatile',
        'void',
        'when',
        'while',
        'where',
        'yield',
        'model',
        'inject',
      ],
    },
);
