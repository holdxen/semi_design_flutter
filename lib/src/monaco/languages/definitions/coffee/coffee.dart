// 1:1 translation of monaco-editor/src/languages/definitions/coffee/coffee.ts
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
      '###',
      '###',
    ],
    'lineComment': '#',
  },
  'folding': <String, Object?>{
    'markers': <String, Object?>{
      'end': RegExp('^\\s*#endregion\\b'),
      'start': RegExp('^\\s*#region\\b'),
    },
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
  'wordPattern': RegExp('(-?\\d*\\.\\d\\w*)|([^\\`\\~\\!\\@\\#%\\^\\&\\*\\(\\)\\=\\\$\\-\\+\\[\\{\\]\\}\\\\\\|\\;\\:\\\'\\"\\,\\.\\<\\>\\/\\?\\s]+)'),
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^#]+'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('###'),
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('#'),
        IShortActionCarrier('comment'),
      ),
      ],
    'hereregexp': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\\\/#]+'),
        IShortActionCarrier('regexp'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('regexp'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('#.*\$'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule1(
        '///[igm]*',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'regexp',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\/'),
        IShortActionCarrier('regexp'),
      ),
      ],
    'herestring': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('("""|\'\'\')'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==\$S2': <String, Object?>{
                'next': '@pop',
                'token': 'string',
              },
              '@default': 'string',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^#\\\\\'"]+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\'"]+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\.'),
        IShortActionCarrier('string.escape.invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('#{'),
        IExpandedMonarchLanguageAction(
          next: 'root.interpolatedstring',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('#'),
        IShortActionCarrier('string'),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\@[a-zA-Z_]\\w*'),
        IShortActionCarrier('variable.predefined'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[a-zA-Z_]\\w*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': '',
              '@keywords': <String, Object?>{
                'token': 'keyword.\$0',
              },
              'this': 'variable.predefined',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[ \\t\\r\\n]+'),
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule2(
        RegExp('###'),
        IShortActionCarrier('comment'),
        '@comment',
      ),
        IShortMonarchLanguageRule1(
        RegExp('#.*\$'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule1(
        '///',
        IExpandedMonarchLanguageAction(
          next: '@hereregexp',
          token: 'regexp',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^(\\s*)(@regEx)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier(''),
          IShortActionCarrier('regexp'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\()(\\s*)(@regEx)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('@brackets'),
          IShortActionCarrier(''),
          IShortActionCarrier('regexp'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\,)(\\s*)(@regEx)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter'),
          IShortActionCarrier(''),
          IShortActionCarrier('regexp'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\=)(\\s*)(@regEx)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter'),
          IShortActionCarrier(''),
          IShortActionCarrier('regexp'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\:)(\\s*)(@regEx)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter'),
          IShortActionCarrier(''),
          IShortActionCarrier('regexp'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\[)(\\s*)(@regEx)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('@brackets'),
          IShortActionCarrier(''),
          IShortActionCarrier('regexp'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\!)(\\s*)(@regEx)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter'),
          IShortActionCarrier(''),
          IShortActionCarrier('regexp'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\&)(\\s*)(@regEx)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter'),
          IShortActionCarrier(''),
          IShortActionCarrier('regexp'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\|)(\\s*)(@regEx)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter'),
          IShortActionCarrier(''),
          IShortActionCarrier('regexp'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\?)(\\s*)(@regEx)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter'),
          IShortActionCarrier(''),
          IShortActionCarrier('regexp'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\{)(\\s*)(@regEx)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('@brackets'),
          IShortActionCarrier(''),
          IShortActionCarrier('regexp'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\;)(\\s*)(@regEx)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier(''),
          IShortActionCarrier(''),
          IShortActionCarrier('regexp'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('}'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==interpolatedstring': <String, Object?>{
                'next': '@pop',
                'token': 'string',
              },
              '@default': '@brackets',
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
        RegExp('\\d+[eE]([\\-+]?\\d+)?'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d+\\.\\d+([eE][\\-+]?\\d+)?'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[xX][0-9a-fA-F]+'),
        IShortActionCarrier('number.hex'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[0-7]+(?!\\d)'),
        IShortActionCarrier('number.octal'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d+'),
        IShortActionCarrier('number'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[,.]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"""'),
        IShortActionCarrier('string'),
        '@herestring."""',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\'\'\''),
        IShortActionCarrier('string'),
        '@herestring.\'\'\'',
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': <String, Object?>{
                'next': '@string."',
                'token': 'string',
              },
              '@eos': 'string',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': <String, Object?>{
                'next': '@string.\'',
                'token': 'string',
              },
              '@eos': 'string',
            },
        ),
      ),
      ],
    'string': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"\'\\#\\\\]+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\.'),
        IShortActionCarrier('string.escape.invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\.'),
        IShortActionCarrier('string.escape.invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('#{'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2=="': <String, Object?>{
                'next': 'root.interpolatedstring',
                'token': 'string',
              },
              '@default': 'string',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('["\']'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$#==\$S2': <String, Object?>{
                'next': '@pop',
                'token': 'string',
              },
              '@default': 'string',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('#'),
        IShortActionCarrier('string'),
      ),
      ],
  },
  ignoreCase: true,
  defaultToken: '',
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
    IMonarchLanguageBracket('[', ']', 'delimiter.square'),
    IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
  ],
  tokenPostfix: '.coffee',
  extra: <String, Object?>{
      'escapes': RegExp('\\\\(?:[abfnrtv\\\\"\'\$]|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})'),
      'keywords': <Object?>[
        'and',
        'or',
        'is',
        'isnt',
        'not',
        'on',
        'yes',
        '@',
        'no',
        'off',
        'true',
        'false',
        'null',
        'this',
        'new',
        'delete',
        'typeof',
        'in',
        'instanceof',
        'return',
        'throw',
        'break',
        'continue',
        'debugger',
        'if',
        'else',
        'switch',
        'for',
        'while',
        'do',
        'try',
        'catch',
        'finally',
        'class',
        'extends',
        'super',
        'undefined',
        'then',
        'unless',
        'until',
        'loop',
        'of',
        'by',
        'when',
      ],
      'regEx': RegExp('\\/(?!\\/\\/)(?:[^\\/\\\\]|\\\\.)*\\/[igm]*'),
      'symbols': RegExp('[=><!~?&%|+\\-*\\/\\^\\.,\\:]+'),
    },
);
