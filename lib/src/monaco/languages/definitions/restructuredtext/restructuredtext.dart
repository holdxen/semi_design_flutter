// 1:1 translation of monaco-editor/src/languages/definitions/restructuredtext/restructuredtext.ts
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
    'blankLineOfLiteralBlocks': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('^\$'),
        IShortActionCarrier(''),
        '@subsequentLinesOfLiteralBlocks',
      ),
        IShortMonarchLanguageRule2(
        RegExp('^.*\$'),
        IShortActionCarrier(''),
        '@pop',
      ),
      ],
    'citations': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('^(\\.\\.\\s+\\[)((?:@citationName))(\\]\\s+)(.*)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            next: '@subsequentLines',
            token: '',
          ),
          IShortActionCarrier('string.link'),
          IShortActionCarrier(''),
          IShortActionCarrier(''),
        ]),
      ),
      ],
    'citationsReference': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(\\[)(@citationName)(\\]_)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier(''),
          IShortActionCarrier('string.link'),
          IShortActionCarrier(''),
        ]),
      ),
      ],
    'comments': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('^[\\s]+.*'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('^(?!\\s)'),
        IShortActionCarrier(''),
        '@pop',
      ),
      ],
    'explicitMarkupBlocks': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@citations',
      ),
        IExpandedMonarchLanguageRule(
        include: '@footnotes',
      ),
        IShortMonarchLanguageRule1(
        RegExp('^(\\.\\.\\s)(@simpleRefName)(::\\s)(.*)\$'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            next: 'subsequentLines',
            token: '',
          ),
          IShortActionCarrier('keyword'),
          IShortActionCarrier(''),
          IShortActionCarrier(''),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^(\\.\\.)(\\s+)(_)(@simpleRefName)(:)(\\s+)(.*)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            next: 'hyperlinks',
            token: '',
          ),
          IShortActionCarrier(''),
          IShortActionCarrier(''),
          IShortActionCarrier('string.link'),
          IShortActionCarrier(''),
          IShortActionCarrier(''),
          IShortActionCarrier('string.link'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^((?:(?:\\.\\.)(?:\\s+))?)(__)(:)(\\s+)(.*)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            next: 'subsequentLines',
            token: '',
          ),
          IShortActionCarrier(''),
          IShortActionCarrier(''),
          IShortActionCarrier(''),
          IShortActionCarrier('string.link'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^(__\\s+)(.+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier(''),
          IShortActionCarrier('string.link'),
        ]),
      ),
        IShortMonarchLanguageRule2(
        RegExp('^(\\.\\.)( \\|)([^| ]+[^|]*[^| ]*)(\\| )(@simpleRefName)(:: .*)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            next: 'subsequentLines',
            token: '',
          ),
          IShortActionCarrier(''),
          IShortActionCarrier('string.link'),
          IShortActionCarrier(''),
          IShortActionCarrier('keyword'),
          IShortActionCarrier(''),
        ]),
        '@rawBlocks',
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\|)([^| ]+[^|]*[^| ]*)(\\|_{0,2})'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier(''),
          IShortActionCarrier('string.link'),
          IShortActionCarrier(''),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^(\\.\\.)([ ].*)\$'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            next: '@comments',
            token: '',
          ),
          IShortActionCarrier('comment'),
        ]),
      ),
      ],
    'footnotes': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('^(\\.\\.\\s+\\[)((?:[0-9]+))(\\]\\s+.*)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            next: '@subsequentLines',
            token: '',
          ),
          IShortActionCarrier('string.link'),
          IShortActionCarrier(''),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^(\\.\\.\\s+\\[)((?:#@simpleRefName?))(\\]\\s+)(.*)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            next: '@subsequentLines',
            token: '',
          ),
          IShortActionCarrier('string.link'),
          IShortActionCarrier(''),
          IShortActionCarrier(''),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^(\\.\\.\\s+\\[)((?:\\*))(\\]\\s+)(.*)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            next: '@subsequentLines',
            token: '',
          ),
          IShortActionCarrier('string.link'),
          IShortActionCarrier(''),
          IShortActionCarrier(''),
        ]),
      ),
      ],
    'footnotesReference': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(\\[)([0-9]+)(\\])(_)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier(''),
          IShortActionCarrier('string.link'),
          IShortActionCarrier(''),
          IShortActionCarrier(''),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\[)(#@simpleRefName?)(\\])(_)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier(''),
          IShortActionCarrier('string.link'),
          IShortActionCarrier(''),
          IShortActionCarrier(''),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\[)(\\*)(\\])(_)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier(''),
          IShortActionCarrier('string.link'),
          IShortActionCarrier(''),
          IShortActionCarrier(''),
        ]),
      ),
      ],
    'hyperlinks': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('^[\\s]+.*'),
        IShortActionCarrier('string.link'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('^(?!\\s)'),
        IShortActionCarrier(''),
        '@pop',
      ),
      ],
    'inlineMarkup': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@citationsReference',
      ),
        IExpandedMonarchLanguageRule(
        include: '@footnotesReference',
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@simpleRefName)(_{1,2})'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('string.link'),
          IShortActionCarrier(''),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(`)([^<`]+\\s+)(<)(.*)(>)(`)(_)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier(''),
          IShortActionCarrier('string.link'),
          IShortActionCarrier(''),
          IShortActionCarrier('string.link'),
          IShortActionCarrier(''),
          IShortActionCarrier(''),
          IShortActionCarrier(''),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\*\\*([^\\\\*]|\\*(?!\\*))+\\*\\*'),
        IShortActionCarrier('strong'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\*[^*]+\\*'),
        IShortActionCarrier('emphasis'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(``)((?:[^`]|\\`(?!`))+)(``)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier(''),
          IShortActionCarrier('keyword'),
          IShortActionCarrier(''),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(__\\s+)(.+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier(''),
          IShortActionCarrier('keyword'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(:)((?:@simpleRefNameWithoutBq)?)(:`)([^`]+)(`)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier(''),
          IShortActionCarrier('keyword'),
          IShortActionCarrier(''),
          IShortActionCarrier(''),
          IShortActionCarrier(''),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(`)([^`]+)(`:)((?:@simpleRefNameWithoutBq)?)(:)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier(''),
          IShortActionCarrier(''),
          IShortActionCarrier(''),
          IShortActionCarrier('keyword'),
          IShortActionCarrier(''),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(`)([^`]+)(`)'),
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(_`)(@phrase)(`)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier(''),
          IShortActionCarrier('string.link'),
          IShortActionCarrier(''),
        ]),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('^(@punctuation{3,}\$){1,1}?'),
        IShortActionCarrier('keyword'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^\\s*([\\*\\-+‣•]|[a-zA-Z0-9]+\\.|\\([a-zA-Z0-9]+\\)|[a-zA-Z0-9]+\\))\\s'),
        IShortActionCarrier('keyword'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('([ ]::)\\s*\$'),
        IShortActionCarrier('keyword'),
        '@blankLineOfLiteralBlocks',
      ),
        IShortMonarchLanguageRule2(
        RegExp('(::)\\s*\$'),
        IShortActionCarrier('keyword'),
        '@blankLineOfLiteralBlocks',
      ),
        IExpandedMonarchLanguageRule(
        include: '@tables',
      ),
        IExpandedMonarchLanguageRule(
        include: '@explicitMarkupBlocks',
      ),
        IExpandedMonarchLanguageRule(
        include: '@inlineMarkup',
      ),
      ],
    'subsequentLines': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('^[\\s]+.*'),
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule2(
        RegExp('^(?!\\s)'),
        IShortActionCarrier(''),
        '@pop',
      ),
      ],
    'subsequentLinesOfLiteralBlocks': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@blockLiteralStart+)(.*)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('keyword'),
          IShortActionCarrier(''),
        ]),
      ),
        IShortMonarchLanguageRule2(
        RegExp('^(?!blockLiteralStart)'),
        IShortActionCarrier(''),
        '@popall',
      ),
      ],
    'tables': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\+-[+-]+'),
        IShortActionCarrier('keyword'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\+=[+=]+'),
        IShortActionCarrier('keyword'),
      ),
      ],
  },
  defaultToken: '',
  tokenPostfix: '.rst',
  extra: <String, Object?>{
      'alphanumerics': RegExp('[A-Za-z0-9]'),
      'blockLiteralStart': RegExp('(?:[!"#\$%&\'()*+,-./:;<=>?@\\[\\]^_`{|}~]|[\\s])'),
      'citationName': RegExp('[A-Za-z][A-Za-z0-9-_.]*'),
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
      'followingChars': RegExp('(?:[ -.,:;!?/\'")\\]}>]|\$)'),
      'phrase': RegExp('@simpleRefNameWithoutBq(?:\\s@simpleRefNameWithoutBq)*'),
      'precedingChars': RegExp('(?:[ -:/\'"<([{])'),
      'punctuation': RegExp('(=|-|~|`|#|"|\\^|\\+|\\*|:|\\.|\'|_|\\+)'),
      'simpleRefName': RegExp('(?:`@phrase`|@simpleRefNameWithoutBq)'),
      'simpleRefNameWithoutBq': RegExp('(?:@alphanumerics[-_+:.]*@alphanumerics)+|(?:@alphanumerics+)'),
    },
);
