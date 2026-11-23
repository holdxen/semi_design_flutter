// 1:1 translation of monaco-editor/src/languages/definitions/liquid/liquid.ts
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
      'close': '%',
      'open': '%',
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
      '{%',
      '%}',
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
        RegExp('\\{\\%\\s*endcomment\\s*\\%\\}'),
        IShortActionCarrier('comment.end.liquid'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('comment.content.liquid'),
      ),
      ],
    'liquidRaw': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
          regex: RegExp('^(?!\\{\\%\\s*endraw\\s*\\%\\}).+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\{\\%'),
        IShortActionCarrier('delimiter.tag.liquid'),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('@identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\%\\}'),
        IExpandedMonarchLanguageAction(
          next: '@root',
          token: 'delimiter.tag.liquid',
        ),
      ),
      ],
    'liquidRoot': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\d+(\\.\\d+)?'),
        IShortActionCarrier('number.liquid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"[^"]*"'),
        IShortActionCarrier('string.liquid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'[^\']*\''),
        IShortActionCarrier('string.liquid'),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('\\s+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@symbol'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': '',
              '@operators': 'operator.liquid',
            },
        ),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('\\.'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@identifier'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@builtinFilters': 'predefined.liquid',
              '@builtinTags': 'predefined.liquid',
              '@constants': 'keyword.liquid',
              '@default': 'variable.liquid',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^}|%]'),
        IShortActionCarrier('variable.liquid'),
      ),
      ],
    'liquidState': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\{\\{'),
        IShortActionCarrier('delimiter.output.liquid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\}\\}'),
        IExpandedMonarchLanguageAction(
          switchTo: '@\$S2.\$S3',
          token: 'delimiter.output.liquid',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\{\\%'),
        IShortActionCarrier('delimiter.tag.liquid'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('raw\\s*\\%\\}'),
        IShortActionCarrier('delimiter.tag.liquid'),
        '@liquidRaw',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\%\\}'),
        IExpandedMonarchLanguageAction(
          switchTo: '@\$S2.\$S3',
          token: 'delimiter.tag.liquid',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: 'liquidRoot',
      ),
      ],
    'otherTag': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\{\\{'),
        IExpandedMonarchLanguageAction(
          switchTo: '@liquidState.otherTag',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\{\\%'),
        IExpandedMonarchLanguageAction(
          switchTo: '@liquidState.otherTag',
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
        RegExp('\\{\\%\\s*comment\\s*\\%\\}'),
        IShortActionCarrier('comment.start.liquid'),
        '@comment',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\{\\{'),
        IExpandedMonarchLanguageAction(
          switchTo: '@liquidState.root',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\{\\%'),
        IExpandedMonarchLanguageAction(
          switchTo: '@liquidState.root',
          token: '@rematch',
        ),
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
        IShortMonarchLanguageRule1(
        RegExp('\\{'),
        IShortActionCarrier('delimiter.html'),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[^<{]+'),
      ),
      ],
  },
  defaultToken: '',
  tokenPostfix: '',
  extra: <String, Object?>{
      'builtinFilters': <Object?>[
        'abs',
        'append',
        'at_least',
        'at_most',
        'capitalize',
        'ceil',
        'compact',
        'date',
        'default',
        'divided_by',
        'downcase',
        'escape',
        'escape_once',
        'first',
        'floor',
        'join',
        'json',
        'last',
        'lstrip',
        'map',
        'minus',
        'modulo',
        'newline_to_br',
        'plus',
        'prepend',
        'remove',
        'remove_first',
        'replace',
        'replace_first',
        'reverse',
        'round',
        'rstrip',
        'size',
        'slice',
        'sort',
        'sort_natural',
        'split',
        'strip',
        'strip_html',
        'strip_newlines',
        'times',
        'truncate',
        'truncatewords',
        'uniq',
        'upcase',
        'url_decode',
        'url_encode',
        'where',
      ],
      'builtinTags': <Object?>[
        'if',
        'else',
        'elseif',
        'endif',
        'render',
        'assign',
        'capture',
        'endcapture',
        'case',
        'endcase',
        'comment',
        'endcomment',
        'cycle',
        'decrement',
        'for',
        'endfor',
        'include',
        'increment',
        'layout',
        'raw',
        'endraw',
        'render',
        'tablerow',
        'endtablerow',
        'unless',
        'endunless',
      ],
      'constants': <Object?>[
        'true',
        'false',
      ],
      'identifier': RegExp('[a-zA-Z_][\\w]*'),
      'operators': <Object?>[
        '==',
        '!=',
        '>',
        '<',
        '>=',
        '<=',
      ],
      'symbol': RegExp('[=><!]+'),
    },
);
