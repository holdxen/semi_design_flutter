// 1:1 translation of monaco-editor/src/languages/definitions/hcl/hcl.ts
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
      '/*',
      '*/',
    ],
    'lineComment': '#',
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
  ],
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\/*]+'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\*\\/'),
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\/*]'),
        IShortActionCarrier('comment'),
      ),
      ],
    'heredoc': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('<<[-]*\\s*["]?([\\w\\-]+)["]?'),
        IExpandedMonarchLanguageAction(
          next: '@heredocBody.\$1',
          token: 'string.heredoc.delimiter',
        ),
      ),
      ],
    'heredocBody': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('([\\w\\-]+)\$'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==\$S2': <Object?>[
                <String, Object?>{
                  'next': '@popall',
                  'token': 'string.heredoc.delimiter',
                },
              ],
              '@default': 'string.heredoc',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('string.heredoc'),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('^@terraformMainBlocks([ \\t]*)([\\w-]+|"[\\w-]+"|)([ \\t]*)([\\w-]+|"[\\w-]+"|)([ \\t]*)(\\{)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('type'),
          IShortActionCarrier(''),
          IShortActionCarrier('string'),
          IShortActionCarrier(''),
          IShortActionCarrier('string'),
          IShortActionCarrier(''),
          IShortActionCarrier('@brackets'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\w+[ \\t]+)([ \\t]*)([\\w-]+|"[\\w-]+"|)([ \\t]*)([\\w-]+|"[\\w-]+"|)([ \\t]*)(\\{)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('identifier'),
          IShortActionCarrier(''),
          IShortActionCarrier('string'),
          IShortActionCarrier(''),
          IShortActionCarrier('string'),
          IShortActionCarrier(''),
          IShortActionCarrier('@brackets'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\w+[ \\t]+)([ \\t]*)([\\w-]+|"[\\w-]+"|)([ \\t]*)([\\w-]+|"[\\w-]+"|)(=)(\\{)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('identifier'),
          IShortActionCarrier(''),
          IShortActionCarrier('string'),
          IShortActionCarrier(''),
          IShortActionCarrier('operator'),
          IShortActionCarrier(''),
          IShortActionCarrier('@brackets'),
        ]),
      ),
        IExpandedMonarchLanguageRule(
        include: '@terraform',
      ),
      ],
    'string': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\\$\\{'),
        IExpandedMonarchLanguageAction(
          next: '@stringExpression',
          token: 'delimiter',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\"\\\$]+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string.escape.invalid'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string'),
        '@popall',
      ),
      ],
    'stringExpression': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\}'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'delimiter',
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string'),
        '@stringInsideExpression',
      ),
        IExpandedMonarchLanguageRule(
        include: '@terraform',
      ),
      ],
    'stringInsideExpression': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\"]+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string.escape.invalid'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string'),
        '@pop',
      ),
      ],
    'terraform': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('@terraformFunctions(\\()'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('type'),
          IShortActionCarrier('@brackets'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[a-zA-Z_]\\w*-*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'variable',
              '@keywords': <String, Object?>{
                'token': 'keyword.\$0',
              },
            },
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IExpandedMonarchLanguageRule(
        include: '@heredoc',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[{}()\\[\\]]'),
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[<>](?!@symbols)'),
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@symbols'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': '',
              '@operators': 'operator',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d*\\d+[eE]([\\-+]?\\d+)?'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d*\\.\\d+([eE][\\-+]?\\d+)?'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d[\\d\']*'),
        IShortActionCarrier('number'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d'),
        IShortActionCarrier('number'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[;,.]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string'),
        '@string',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IShortActionCarrier('invalid'),
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[ \\t\\r\\n]+'),
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\/\\*'),
        IShortActionCarrier('comment'),
        '@comment',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\/\\/.*\$'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('#.*\$'),
        IShortActionCarrier('comment'),
      ),
      ],
  },
  defaultToken: '',
  tokenPostfix: '.hcl',
  extra: <String, Object?>{
      'escapes': RegExp('\\\\(?:[abfnrtv\\\\"\']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})'),
      'keywords': <Object?>[
        'var',
        'local',
        'path',
        'for_each',
        'any',
        'string',
        'number',
        'bool',
        'true',
        'false',
        'null',
        'if ',
        'else ',
        'endif ',
        'for ',
        'in',
        'endfor',
      ],
      'operators': <Object?>[
        '=',
        '>=',
        '<=',
        '==',
        '!=',
        '+',
        '-',
        '*',
        '/',
        '%',
        '&&',
        '||',
        '!',
        '<',
        '>',
        '?',
        '...',
        ':',
      ],
      'symbols': RegExp('[=><!~?:&|+\\-*\\/\\^%]+'),
      'terraformFunctions': RegExp('(abs|ceil|floor|log|max|min|pow|signum|chomp|format|formatlist|indent|join|lower|regex|regexall|replace|split|strrev|substr|title|trimspace|upper|chunklist|coalesce|coalescelist|compact|concat|contains|distinct|element|flatten|index|keys|length|list|lookup|map|matchkeys|merge|range|reverse|setintersection|setproduct|setunion|slice|sort|transpose|values|zipmap|base64decode|base64encode|base64gzip|csvdecode|jsondecode|jsonencode|urlencode|yamldecode|yamlencode|abspath|dirname|pathexpand|basename|file|fileexists|fileset|filebase64|templatefile|formatdate|timeadd|timestamp|base64sha256|base64sha512|bcrypt|filebase64sha256|filebase64sha512|filemd5|filemd1|filesha256|filesha512|md5|rsadecrypt|sha1|sha256|sha512|uuid|uuidv5|cidrhost|cidrnetmask|cidrsubnet|tobool|tolist|tomap|tonumber|toset|tostring)'),
      'terraformMainBlocks': RegExp('(module|data|terraform|resource|provider|variable|output|locals)'),
    },
);
