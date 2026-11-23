// 1:1 translation of monaco-editor/src/languages/definitions/powershell/powershell.ts
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
      'notIn': <Object?>[
        'string',
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
      '<#',
      '#>',
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
  'wordPattern': RegExp('(-?\\d*\\.\\d\\w*)|([^\\`\\~\\!\\@\\#%\\^\\&\\*\\(\\)\\=\\+\\[\\{\\]\\}\\\\\\|\\;\\:\\\'\\"\\,\\.\\<\\>\\/\\?\\s]+)'),
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^#\\.]+'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('#>'),
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\.)(@helpKeywords)(?!\\w)'),
        IExpandedMonarchLanguageAction(
          token: 'comment.keyword.\$2',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\.#]'),
        IShortActionCarrier('comment'),
      ),
      ],
    'herestring': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('^\\s*(["\'])@'),
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
        RegExp('[^\\\$`]+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('`.'),
        IShortActionCarrier('string.escape.invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$[\\w]+'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2=="': 'variable',
              '@default': 'string',
            },
        ),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[a-zA-Z_][\\w-]*'),
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
        RegExp('[ \\t\\r\\n]+'),
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^:\\w*'),
        IShortActionCarrier('metatag'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$(\\{((global|local|private|script|using):)?[\\w]+\\}|((global|local|private|script|using):)?[\\w]+)'),
        IShortActionCarrier('variable'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('<#'),
        IShortActionCarrier('comment'),
        '@comment',
      ),
        IShortMonarchLanguageRule1(
        RegExp('#.*\$'),
        IShortActionCarrier('comment'),
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
        RegExp('\\d*\\.\\d+([eE][\\-+]?\\d+)?'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[xX][0-9a-fA-F_]*[0-9a-fA-F]'),
        IShortActionCarrier('number.hex'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d+?'),
        IShortActionCarrier('number'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[;,.]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\@"'),
        IShortActionCarrier('string'),
        '@herestring."',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\@\''),
        IShortActionCarrier('string'),
        '@herestring.\'',
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
        RegExp('[^"\'\\\$`]+'),
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
        RegExp('`.'),
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
        RegExp('\\\$[\\w]+\$'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2=="': <String, Object?>{
                'next': '@popall',
                'token': 'variable',
              },
              '@default': <String, Object?>{
                'next': '@popall',
                'token': 'string',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$[\\w]+'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2=="': 'variable',
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
              '@default': <String, Object?>{
                'cases': <String, Object?>{
                  '@default': 'string',
                  '@eos': <String, Object?>{
                    'next': '@popall',
                    'token': 'string',
                  },
                },
              },
            },
        ),
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
  tokenPostfix: '.ps1',
  extra: <String, Object?>{
      'escapes': RegExp('`(?:[abfnrtv\\\\"\'\$]|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})'),
      'helpKeywords': RegExp('SYNOPSIS|DESCRIPTION|PARAMETER|EXAMPLE|INPUTS|OUTPUTS|NOTES|LINK|COMPONENT|ROLE|FUNCTIONALITY|FORWARDHELPTARGETNAME|FORWARDHELPCATEGORY|REMOTEHELPRUNSPACE|EXTERNALHELP'),
      'keywords': <Object?>[
        'begin',
        'break',
        'catch',
        'class',
        'continue',
        'data',
        'define',
        'do',
        'dynamicparam',
        'else',
        'elseif',
        'end',
        'exit',
        'filter',
        'finally',
        'for',
        'foreach',
        'from',
        'function',
        'if',
        'in',
        'param',
        'process',
        'return',
        'switch',
        'throw',
        'trap',
        'try',
        'until',
        'using',
        'var',
        'while',
        'workflow',
        'parallel',
        'sequence',
        'inlinescript',
        'configuration',
      ],
      'symbols': RegExp('[=><!~?&%|+\\-*\\/\\^;\\.,]+'),
    },
);
