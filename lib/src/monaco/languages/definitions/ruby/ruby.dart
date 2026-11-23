// 1:1 translation of monaco-editor/src/languages/definitions/ruby/ruby.ts
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
      '(',
      ')',
    ],
    <Object?>[
      '{',
      '}',
    ],
    <Object?>[
      '[',
      ']',
    ],
  ],
  'comments': <String, Object?>{
    'blockComment': <Object?>[
      '=begin',
      '=end',
    ],
    'lineComment': '#',
  },
  'indentationRules': <String, Object?>{
    'decreaseIndentPattern': RegExp('^\\s*([}\\]]([,)]?\\s*(#|\$)|\\.[a-zA-Z_]\\w*\\b)|(end|rescue|ensure|else|elsif|when)\\b)'),
    'increaseIndentPattern': RegExp('^\\s*((begin|class|(private|protected)\\s+def|def|else|elsif|ensure|for|if|module|rescue|unless|until|when|while|case)|([^#]*\\sdo\\b)|([^#]*=\\s*(case|if|unless)))\\b([^#\\{;]|("|\'|\\/).*\\4)*(#.*)?\$'),
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
        RegExp('[^=]+'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^\\s*=begin\\b'),
        IShortActionCarrier('comment.invalid'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('^\\s*=end\\b.*'),
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[=]'),
        IShortActionCarrier('comment'),
      ),
      ],
    'dodecl': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('^'),
        IExpandedMonarchLanguageAction(
          switchTo: '@root.\$S2',
          token: '',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[a-z_]\\w*[!?=]?'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@builtins': 'predefined',
              '@default': 'identifier',
              '@keywords': 'keyword',
              '@linedecls': <String, Object?>{
                'switchTo': '@root.\$S2',
                'token': '@rematch',
              },
              'do': <String, Object?>{
                'switchTo': '@root.\$S2',
                'token': 'keyword',
              },
              'end': <String, Object?>{
                'next': '@pop',
                'token': 'keyword.\$S2',
              },
            },
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@root',
      ),
      ],
    'dstring': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\`"#]+'),
        IShortActionCarrier('string.\$S2'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('#'),
        IShortActionCarrier('string.\$S2.escape'),
        '@interpolated',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\\$'),
        IShortActionCarrier('string.\$S2.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IShortActionCarrier('string.\$S2.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string.\$S2.escape.invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[`"]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$#==\$S3': <String, Object?>{
                'next': '@pop',
                'token': 'string.\$S2.delim',
              },
              '@default': 'string.\$S2',
            },
        ),
      ),
      ],
    'heredoc': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('^(\\s*)(@heredelim)\$'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$2==\$S2': <Object?>[
                'string.heredoc',
                <String, Object?>{
                  'next': '@pop',
                  'token': 'string.heredoc.delimiter',
                },
              ],
              '@default': <Object?>[
                'string.heredoc',
                'string.heredoc',
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.*'),
        IShortActionCarrier('string.heredoc'),
      ),
      ],
    'interpolated': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('\\\$\\w*'),
        IShortActionCarrier('global.constant'),
        '@pop',
      ),
        IShortMonarchLanguageRule2(
        RegExp('@\\w*'),
        IShortActionCarrier('namespace.class.identifier'),
        '@pop',
      ),
        IShortMonarchLanguageRule2(
        RegExp('@@@\\w*'),
        IShortActionCarrier('namespace.instance.identifier'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[{]'),
        IExpandedMonarchLanguageAction(
          switchTo: '@interpolated_compound',
          token: 'string.escape.curly',
        ),
      ),
        IShortMonarchLanguageRule2(
        '',
        IShortActionCarrier(''),
        '@pop',
      ),
      ],
    'interpolated_compound': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[}]'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.escape.curly',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@root',
      ),
      ],
    'modifier': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('^'),
        IShortActionCarrier(''),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[a-z_]\\w*[!?=]?'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@builtins': 'predefined',
              '@default': 'identifier',
              '@keywords': 'keyword',
              '@linedecls': <String, Object?>{
                'switchTo': '@root.\$S2',
                'token': '@rematch',
              },
              'end': <String, Object?>{
                'next': '@pop',
                'token': 'keyword.\$S2',
              },
              'then|else|elsif|do': <String, Object?>{
                'switchTo': '@root.\$S2',
                'token': 'keyword',
              },
            },
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@root',
      ),
      ],
    'pregexp': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\(\\{\\[\\\\]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$#==\$S2': <String, Object?>{
                'next': '@push',
                'token': 'regexp.delim',
              },
              '\$#==\$S3': <String, Object?>{
                'next': '@pop',
                'token': 'regexp.delim',
              },
              '@default': 'regexp',
              '~@regexpctl': 'regexp.escape.control',
              '~[)}\\]]': '@brackets.regexp.escape.control',
            },
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@regexcontrol',
      ),
      ],
    'pstring': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('%([qws])\\('),
        IExpandedMonarchLanguageAction(
          switchTo: '@qstring.\$1.(.)',
          token: 'string.\$1.delim',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('%([qws])\\['),
        IExpandedMonarchLanguageAction(
          switchTo: '@qstring.\$1.[.]',
          token: 'string.\$1.delim',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('%([qws])\\{'),
        IExpandedMonarchLanguageAction(
          switchTo: '@qstring.\$1.{.}',
          token: 'string.\$1.delim',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('%([qws])<'),
        IExpandedMonarchLanguageAction(
          switchTo: '@qstring.\$1.<.>',
          token: 'string.\$1.delim',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('%([qws])(@delim)'),
        IExpandedMonarchLanguageAction(
          switchTo: '@qstring.\$1.\$2.\$2',
          token: 'string.\$1.delim',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('%r\\('),
        IExpandedMonarchLanguageAction(
          switchTo: '@pregexp.(.)',
          token: 'regexp.delim',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('%r\\['),
        IExpandedMonarchLanguageAction(
          switchTo: '@pregexp.[.]',
          token: 'regexp.delim',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('%r\\{'),
        IExpandedMonarchLanguageAction(
          switchTo: '@pregexp.{.}',
          token: 'regexp.delim',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('%r<'),
        IExpandedMonarchLanguageAction(
          switchTo: '@pregexp.<.>',
          token: 'regexp.delim',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('%r(@delim)'),
        IExpandedMonarchLanguageAction(
          switchTo: '@pregexp.\$1.\$1',
          token: 'regexp.delim',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('%(x|W|Q?)\\('),
        IExpandedMonarchLanguageAction(
          switchTo: '@qqstring.\$1.(.)',
          token: 'string.\$1.delim',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('%(x|W|Q?)\\['),
        IExpandedMonarchLanguageAction(
          switchTo: '@qqstring.\$1.[.]',
          token: 'string.\$1.delim',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('%(x|W|Q?)\\{'),
        IExpandedMonarchLanguageAction(
          switchTo: '@qqstring.\$1.{.}',
          token: 'string.\$1.delim',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('%(x|W|Q?)<'),
        IExpandedMonarchLanguageAction(
          switchTo: '@qqstring.\$1.<.>',
          token: 'string.\$1.delim',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('%(x|W|Q?)(@delim)'),
        IExpandedMonarchLanguageAction(
          switchTo: '@qqstring.\$1.\$2.\$2',
          token: 'string.\$1.delim',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('%([rqwsxW]|Q?).'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'invalid',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'invalid',
        ),
      ),
      ],
    'qqstring': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('#'),
        IShortActionCarrier('string.\$S2.escape'),
        '@interpolated',
      ),
        IExpandedMonarchLanguageRule(
        include: '@qstring',
      ),
      ],
    'qstring': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\\\\$'),
        IShortActionCarrier('string.\$S2.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string.\$S2.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$#==\$S3': <String, Object?>{
                'next': '@push',
                'token': 'string.\$S2.delim',
              },
              '\$#==\$S4': <String, Object?>{
                'next': '@pop',
                'token': 'string.\$S2.delim',
              },
              '@default': 'string.\$S2',
            },
        ),
      ),
      ],
    'regexcontrol': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(\\{)(\\d+(?:,\\d*)?)(\\})'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('@brackets.regexp.escape.control'),
          IShortActionCarrier('regexp.escape.control'),
          IShortActionCarrier('@brackets.regexp.escape.control'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\[)(\\^?)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('@brackets.regexp.escape.control'),
          IExpandedMonarchLanguageAction(
            next: '@regexrange',
            token: 'regexp.escape.control',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\()(\\?[:=!])'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('@brackets.regexp.escape.control'),
          IShortActionCarrier('regexp.escape.control'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\(\\?#'),
        IExpandedMonarchLanguageAction(
          next: '@regexpcomment',
          token: 'regexp.escape.control',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[()]'),
        IShortActionCarrier('@brackets.regexp.escape.control'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@regexpctl'),
        IShortActionCarrier('regexp.escape.control'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\\$'),
        IShortActionCarrier('regexp.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@regexpesc'),
        IShortActionCarrier('regexp.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\\\.'),
        IShortActionCarrier('regexp.invalid'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('#'),
        IShortActionCarrier('regexp.escape'),
        '@interpolated',
      ),
      ],
    'regexp': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@regexcontrol',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\\\/]'),
        IShortActionCarrier('regexp'),
      ),
        IShortMonarchLanguageRule2(
        '/[ixmp]*',
        IExpandedMonarchLanguageAction(
          token: 'regexp.delim',
        ),
        '@pop',
      ),
      ],
    'regexpcomment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^)]+'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\)'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'regexp.escape.control',
        ),
      ),
      ],
    'regexrange': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('-'),
        IShortActionCarrier('regexp.escape.control'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\^'),
        IShortActionCarrier('regexp.invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\\$'),
        IShortActionCarrier('regexp.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@regexpesc'),
        IShortActionCarrier('regexp.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\]]'),
        IShortActionCarrier('regexp'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\]'),
        IShortActionCarrier('@brackets.regexp.escape.control'),
        '@pop',
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('^(\\s*)([a-z_]\\w*[!?=]?)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('white'),
          IExpandedMonarchLanguageAction(
            cases: <String, Object?>{
                '@builtins': 'predefined',
                '@declarations': <String, Object?>{
                  'next': '@root.\$2',
                  'token': 'keyword.\$2',
                },
                '@default': 'identifier',
                '@keywords': 'keyword',
                'end': <String, Object?>{
                  'next': '@pop',
                  'token': 'keyword.\$S2',
                },
                'for|until|while': <String, Object?>{
                  'next': '@dodecl.\$2',
                  'token': 'keyword.\$2',
                },
              },
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[a-z_]\\w*[!?=]?'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@builtins': 'predefined',
              '@default': 'identifier',
              '@keywords': 'keyword',
              '@linedecls': <String, Object?>{
                'next': '@root.\$0',
                'token': 'keyword.\$0',
              },
              'end': <String, Object?>{
                'next': '@pop',
                'token': 'keyword.\$S2',
              },
              'for': <String, Object?>{
                'next': '@dodecl.\$2',
                'token': 'keyword.\$2',
              },
              'if|unless|while|until': <String, Object?>{
                'next': '@modifier.\$0x',
                'token': 'keyword.\$0x',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[A-Z][\\w]*[!?=]?'),
        IShortActionCarrier('constructor.identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$[\\w]*'),
        IShortActionCarrier('global.constant'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@[\\w]*'),
        IShortActionCarrier('namespace.instance.identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@@@[\\w]*'),
        IShortActionCarrier('namespace.class.identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<<[-~](@heredelim).*'),
        IExpandedMonarchLanguageAction(
          next: '@heredoc.\$1',
          token: 'string.heredoc.delimiter',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[ \\t\\r\\n]+<<(@heredelim).*'),
        IExpandedMonarchLanguageAction(
          next: '@heredoc.\$1',
          token: 'string.heredoc.delimiter',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^<<(@heredelim).*'),
        IExpandedMonarchLanguageAction(
          next: '@heredoc.\$1',
          token: 'string.heredoc.delimiter',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@dstring.d."',
          token: 'string.d.delim',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@sstring.sq',
          token: 'string.sq.delim',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('%([rsqxwW]|Q?)'),
        IExpandedMonarchLanguageAction(
          next: 'pstring',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('`'),
        IExpandedMonarchLanguageAction(
          next: '@dstring.x.`',
          token: 'string.x.delim',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp(':(\\w|[\$@])\\w*[!?=]?'),
        IShortActionCarrier('string.s'),
      ),
        IShortMonarchLanguageRule1(
        RegExp(':"'),
        IExpandedMonarchLanguageAction(
          next: '@dstring.s."',
          token: 'string.s.delim',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp(':\''),
        IExpandedMonarchLanguageAction(
          next: '@sstring.s',
          token: 'string.s.delim',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\/(?=(\\\\\\/|[^\\/\\n])+\\/)'),
        IExpandedMonarchLanguageAction(
          next: '@regexp',
          token: 'regexp.delim',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[{}()\\[\\]]'),
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@symbols'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': '',
              '@keywordops': 'keyword',
              '@operators': 'operator',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[;,]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[xX][0-9a-fA-F](_?[0-9a-fA-F])*'),
        IShortActionCarrier('number.hex'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[_oO][0-7](_?[0-7])*'),
        IShortActionCarrier('number.octal'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[bB][01](_?[01])*'),
        IShortActionCarrier('number.binary'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[dD]@decpart'),
        IShortActionCarrier('number'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@decimal((\\.@decpart)?([eE][\\-+]?@decpart)?)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1': 'number.float',
              '@default': 'number',
            },
        ),
      ),
      ],
    'sstring': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\\']+'),
        IShortActionCarrier('string.\$S2'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\\\\\|\\\\\'|\\\\\$'),
        IShortActionCarrier('string.\$S2.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string.\$S2.invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.\$S2.delim',
        ),
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[ \\t\\r\\n]+'),
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule2(
        RegExp('^\\s*=begin\\b'),
        IShortActionCarrier('comment'),
        '@comment',
      ),
        IShortMonarchLanguageRule1(
        RegExp('#.*\$'),
        IShortActionCarrier('comment'),
      ),
      ],
  },
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
    IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
    IMonarchLanguageBracket('[', ']', 'delimiter.square'),
  ],
  tokenPostfix: '.ruby',
  extra: <String, Object?>{
      'builtins': <Object?>[
        'require',
        'public',
        'private',
        'include',
        'extend',
        'attr_reader',
        'protected',
        'private_class_method',
        'protected_class_method',
        'new',
      ],
      'decimal': RegExp('0|@decpart'),
      'declarations': <Object?>[
        'module',
        'class',
        'def',
        'case',
        'do',
        'begin',
        'for',
        'if',
        'while',
        'until',
        'unless',
      ],
      'decpart': RegExp('\\d(_?\\d)*'),
      'delim': RegExp('[^a-zA-Z0-9\\s\\n\\r]'),
      'escape': RegExp('(?:[abefnrstv\\\\"\'\\n\\r]|[0-7]{1,3}|x[0-9A-Fa-f]{1,2}|u[0-9A-Fa-f]{4})'),
      'escapes': RegExp('\\\\(?:C\\-(@escape|.)|c(@escape|.)|@escape)'),
      'heredelim': RegExp('(?:\\w+|\'[^\']*\'|"[^"]*"|`[^`]*`)'),
      'keywordops': <Object?>[
        '::',
        '..',
        '...',
        '?',
        ':',
        '=>',
      ],
      'keywords': <Object?>[
        '__LINE__',
        '__ENCODING__',
        '__FILE__',
        'BEGIN',
        'END',
        'alias',
        'and',
        'begin',
        'break',
        'case',
        'class',
        'def',
        'defined?',
        'do',
        'else',
        'elsif',
        'end',
        'ensure',
        'for',
        'false',
        'if',
        'in',
        'module',
        'next',
        'nil',
        'not',
        'or',
        'redo',
        'rescue',
        'retry',
        'return',
        'self',
        'super',
        'then',
        'true',
        'undef',
        'unless',
        'until',
        'when',
        'while',
        'yield',
      ],
      'linedecls': <Object?>[
        'def',
        'case',
        'do',
        'begin',
        'for',
        'if',
        'while',
        'until',
        'unless',
      ],
      'operators': <Object?>[
        '^',
        '&',
        '|',
        '<=>',
        '==',
        '===',
        '!~',
        '=~',
        '>',
        '>=',
        '<',
        '<=',
        '<<',
        '>>',
        '+',
        '-',
        '*',
        '/',
        '%',
        '**',
        '~',
        '+@',
        '-@',
        '[]',
        '[]=',
        '`',
        '+=',
        '-=',
        '*=',
        '**=',
        '/=',
        '^=',
        '%=',
        '<<=',
        '>>=',
        '&=',
        '&&=',
        '||=',
        '|=',
      ],
      'regexpctl': RegExp('[(){}\\[\\]\\\$\\^|\\-*+?\\.]'),
      'regexpesc': RegExp('\\\\(?:[AzZbBdDfnrstvwWn0\\\\\\/]|@regexpctl|c[A-Z]|x[0-9a-fA-F]{2}|u[0-9a-fA-F]{4})?'),
      'symbols': RegExp('[=><!~?:&|+\\-*\\/\\^%\\.]+'),
    },
);
