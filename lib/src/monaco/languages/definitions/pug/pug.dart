// 1:1 translation of monaco-editor/src/languages/definitions/pug/pug.ts
// Monarch language definition data, evaluated from the TS source via
// the TypeScript compiler (computed template/const values resolved).
// TS object literals -> Dart data; typed rule/action/bracket carriers
// mirror the ported monarchCompile. Regex flags preserved in RegExp.

import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchTypes.dart';

/// 1:1: `export const conf: languages.LanguageConfiguration = {...}`
final Map<String, Object?> conf = <String, Object?>{
  'autoClosingPairs': <Object?>[
    <String, Object?>{
      'close': '"',
      'notIn': <Object?>[
        'string',
        'comment',
      ],
      'open': '"',
    },
    <String, Object?>{
      'close': '\'',
      'notIn': <Object?>[
        'string',
        'comment',
      ],
      'open': '\'',
    },
    <String, Object?>{
      'close': '}',
      'notIn': <Object?>[
        'string',
        'comment',
      ],
      'open': '{',
    },
    <String, Object?>{
      'close': ']',
      'notIn': <Object?>[
        'string',
        'comment',
      ],
      'open': '[',
    },
    <String, Object?>{
      'close': ')',
      'notIn': <Object?>[
        'string',
        'comment',
      ],
      'open': '(',
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
    'lineComment': '//',
  },
  'folding': <String, Object?>{
    'offSide': true,
  },
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'attributeList': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\s+'),
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\w+)(\\s*=\\s*)("|\')'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('attribute.name'),
          IShortActionCarrier('delimiter'),
          IExpandedMonarchLanguageAction(
            next: '@value.\$3',
            token: 'attribute.value',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\w+'),
        IShortActionCarrier('attribute.name'),
      ),
        IShortMonarchLanguageRule1(
        RegExp(','),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'attribute.delimiter',
              '@eos': <String, Object?>{
                'next': '@popall',
                'token': 'attribute.delimiter',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\)\$'),
        IExpandedMonarchLanguageAction(
          next: '@popall',
          token: 'delimiter.parenthesis',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\)'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'delimiter.parenthesis',
        ),
      ),
      ],
    'blockText': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('^\\s+.*\$'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '(\$S2\\s+.*\$)': <String, Object?>{
                'token': '\$S3',
              },
              '@default': <String, Object?>{
                'next': '@popall',
                'token': '@rematch',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IExpandedMonarchLanguageAction(
          next: '@popall',
          token: '@rematch',
        ),
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
        RegExp('^(\\s*)([a-zA-Z_-][\\w-]*)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$2@keywords': <Object?>[
                '',
                <String, Object?>{
                  'token': 'keyword.\$2',
                },
              ],
              '\$2@tags': <String, Object?>{
                'cases': <String, Object?>{
                  '@default': <Object?>[
                    '',
                    <String, Object?>{
                      'next': '@tag.\$1',
                      'token': 'tag',
                    },
                  ],
                  '@eos': <Object?>[
                    '',
                    'tag',
                  ],
                },
              },
              '@default': <Object?>[
                '',
                '',
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^(\\s*)(#[a-zA-Z_-][\\w-]*)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': <Object?>[
                '',
                <String, Object?>{
                  'next': '@tag.\$1',
                  'token': 'tag.id',
                },
              ],
              '@eos': <Object?>[
                '',
                'tag.id',
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^(\\s*)(\\.[a-zA-Z_-][\\w-]*)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': <Object?>[
                '',
                <String, Object?>{
                  'next': '@tag.\$1',
                  'token': 'tag.class',
                },
              ],
              '@eos': <Object?>[
                '',
                'tag.class',
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^(\\s*)(\\|.*)\$'),
        IShortActionCarrier(''),
      ),
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[a-zA-Z_\$][\\w\$]*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': '',
              '@keywords': <String, Object?>{
                'token': 'keyword.\$0',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[{}()\\[\\]]'),
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@symbols'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d+\\.\\d+([eE][\\-+]?\\d+)?'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d+'),
        IShortActionCarrier('number'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string'),
        '@string."',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\''),
        IShortActionCarrier('string'),
        '@string.\'',
      ),
      ],
    'simpleText': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^#]+\$'),
        IExpandedMonarchLanguageAction(
          next: '@popall',
          token: '',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^#]+'),
        IExpandedMonarchLanguageAction(
          token: '',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(#{)([^}]*)(})'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': <Object?>[
                'interpolation.delimiter',
                'interpolation',
                'interpolation.delimiter',
              ],
              '@eos': <Object?>[
                'interpolation.delimiter',
                'interpolation',
                <String, Object?>{
                  'next': '@popall',
                  'token': 'interpolation.delimiter',
                },
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('#\$'),
        IExpandedMonarchLanguageAction(
          next: '@popall',
          token: '',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('#'),
        IShortActionCarrier(''),
      ),
      ],
    'string': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\"\'#]+'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'string',
              '@eos': <String, Object?>{
                'next': '@popall',
                'token': 'string',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'string.escape',
              '@eos': <String, Object?>{
                'next': '@popall',
                'token': 'string.escape',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'string.escape.invalid',
              '@eos': <String, Object?>{
                'next': '@popall',
                'token': 'string.escape.invalid',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(#{)([^}]*)(})'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('interpolation.delimiter'),
          IShortActionCarrier('interpolation'),
          IShortActionCarrier('interpolation.delimiter'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('#'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('["\']'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$#==\$S2': <String, Object?>{
                'next': '@pop',
                'token': 'string',
              },
              '@default': <String, Object?>{
                'token': 'string',
              },
            },
        ),
      ),
      ],
    'tag': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(\\.)(\\s*\$)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            next: '@blockText.\$S2.',
            token: 'delimiter',
          ),
          IShortActionCarrier(''),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\s+'),
        IExpandedMonarchLanguageAction(
          next: '@simpleText',
          token: '',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('#[a-zA-Z_-][\\w-]*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'tag.id',
              '@eos': <String, Object?>{
                'next': '@pop',
                'token': 'tag.id',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\.[a-zA-Z_-][\\w-]*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'tag.class',
              '@eos': <String, Object?>{
                'next': '@pop',
                'token': 'tag.class',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\('),
        IExpandedMonarchLanguageAction(
          next: '@attributeList',
          token: 'delimiter.parenthesis',
        ),
      ),
      ],
    'value': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\"\']+'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'attribute.value',
              '@eos': <String, Object?>{
                'next': '@popall',
                'token': 'attribute.value',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'attribute.value',
              '@eos': <String, Object?>{
                'next': '@popall',
                'token': 'attribute.value',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('["\']'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$#==\$S2': <String, Object?>{
                'next': '@pop',
                'token': 'attribute.value',
              },
              '@default': <String, Object?>{
                'token': 'attribute.value',
              },
            },
        ),
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('^(\\s*)(\\/\\/.*)\$'),
        IExpandedMonarchLanguageAction(
          next: '@blockText.\$1.comment',
          token: 'comment',
        ),
      ),
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
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
    IMonarchLanguageBracket('[', ']', 'delimiter.array'),
    IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
  ],
  tokenPostfix: '.pug',
  extra: <String, Object?>{
      'escapes': RegExp('\\\\(?:[abfnrtv\\\\"\']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})'),
      'keywords': <Object?>[
        'append',
        'block',
        'case',
        'default',
        'doctype',
        'each',
        'else',
        'extends',
        'for',
        'if',
        'in',
        'include',
        'mixin',
        'typeof',
        'unless',
        'var',
        'when',
      ],
      'symbols': RegExp('[\\+\\-\\*\\%\\&\\|\\!\\=\\/\\.\\,\\:]+'),
      'tags': <Object?>[
        'a',
        'abbr',
        'acronym',
        'address',
        'area',
        'article',
        'aside',
        'audio',
        'b',
        'base',
        'basefont',
        'bdi',
        'bdo',
        'blockquote',
        'body',
        'br',
        'button',
        'canvas',
        'caption',
        'center',
        'cite',
        'code',
        'col',
        'colgroup',
        'command',
        'datalist',
        'dd',
        'del',
        'details',
        'dfn',
        'div',
        'dl',
        'dt',
        'em',
        'embed',
        'fieldset',
        'figcaption',
        'figure',
        'font',
        'footer',
        'form',
        'frame',
        'frameset',
        'h1',
        'h2',
        'h3',
        'h4',
        'h5',
        'h6',
        'head',
        'header',
        'hgroup',
        'hr',
        'html',
        'i',
        'iframe',
        'img',
        'input',
        'ins',
        'keygen',
        'kbd',
        'label',
        'li',
        'link',
        'map',
        'mark',
        'menu',
        'meta',
        'meter',
        'nav',
        'noframes',
        'noscript',
        'object',
        'ol',
        'optgroup',
        'option',
        'output',
        'p',
        'param',
        'pre',
        'progress',
        'q',
        'rp',
        'rt',
        'ruby',
        's',
        'samp',
        'script',
        'section',
        'select',
        'small',
        'source',
        'span',
        'strike',
        'strong',
        'style',
        'sub',
        'summary',
        'sup',
        'table',
        'tbody',
        'td',
        'textarea',
        'tfoot',
        'th',
        'thead',
        'time',
        'title',
        'tr',
        'tracks',
        'tt',
        'u',
        'ul',
        'video',
        'wbr',
      ],
    },
);
