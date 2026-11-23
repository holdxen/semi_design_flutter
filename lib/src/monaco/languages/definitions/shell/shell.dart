// 1:1 translation of monaco-editor/src/languages/definitions/shell/shell.ts
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
    <String, Object?>{
      'close': '`',
      'open': '`',
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
    <String, Object?>{
      'close': '\'',
      'open': '\'',
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
    'dblStringBody': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string'),
        '@popall',
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('string'),
      ),
      ],
    'heredoc': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(<<[-<]?)(\\s*)([\'"`]?)([\\w\\-]+)([\'"`]?)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('constants'),
          IShortActionCarrier('white'),
          IShortActionCarrier('string.heredoc.delimiter'),
          IShortActionCarrier('string.heredoc'),
          IShortActionCarrier('string.heredoc.delimiter'),
        ]),
      ),
      ],
    'numbers': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\d*\\.\\d+([eE][\\-+]?\\d+)?'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[xX][0-9a-fA-F_]*[0-9a-fA-F]'),
        IShortActionCarrier('number.hex'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d+'),
        IShortActionCarrier('number'),
      ),
      ],
    'parameterBodyCurlyBrace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^#:%*@\\-!_}]+'),
        IShortActionCarrier('variable'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[#:%*@\\-!_]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('[}]'),
        IShortActionCarrier('variable'),
        '@pop',
      ),
      ],
    'parameterBodyDoubleQuote': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^#:%*@\\-!_"]+'),
        IShortActionCarrier('variable'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[#:%*@\\-!_]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('["]'),
        IShortActionCarrier('variable'),
        '@pop',
      ),
      ],
    'parameterBodyParen': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^#:%*@\\-!_)]+'),
        IShortActionCarrier('variable'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[#:%*@\\-!_]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('[)]'),
        IShortActionCarrier('variable'),
        '@pop',
      ),
      ],
    'parameterBodyQuote': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^#:%*@\\-!_\']+'),
        IShortActionCarrier('variable'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[#:%*@\\-!_]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('[\']'),
        IShortActionCarrier('variable'),
        '@pop',
      ),
      ],
    'parameters': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\\$\\d+'),
        IShortActionCarrier('variable.predefined'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$\\w+'),
        IShortActionCarrier('variable'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$[*@#?\\-\$!0_]'),
        IShortActionCarrier('variable'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\\$\''),
        IShortActionCarrier('variable'),
        '@parameterBodyQuote',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\\$"'),
        IShortActionCarrier('variable'),
        '@parameterBodyDoubleQuote',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\\$\\('),
        IShortActionCarrier('variable'),
        '@parameterBodyParen',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\\$\\{'),
        IShortActionCarrier('variable'),
        '@parameterBodyCurlyBrace',
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('@identifiersWithDashes'),
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\s)((?:@startingWithDash)+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('white'),
          IShortActionCarrier('attribute.name'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[a-zA-Z]\\w*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@builtins': 'type.identifier',
              '@default': '',
              '@keywords': 'keyword',
            },
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IExpandedMonarchLanguageRule(
        include: '@strings',
      ),
        IExpandedMonarchLanguageRule(
        include: '@parameters',
      ),
        IExpandedMonarchLanguageRule(
        include: '@heredoc',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[{}\\[\\]()]'),
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@symbols'),
        IShortActionCarrier('delimiter'),
      ),
        IExpandedMonarchLanguageRule(
        include: '@numbers',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[,;]'),
        IShortActionCarrier('delimiter'),
      ),
      ],
    'stringBody': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('\''),
        IShortActionCarrier('string'),
        '@popall',
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('string'),
      ),
      ],
    'strings': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('\''),
        IShortActionCarrier('string'),
        '@stringBody',
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string'),
        '@dblStringBody',
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\s+'),
        IShortActionCarrier('white'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(^#!.*\$)'),
        IShortActionCarrier('metatag'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(^#.*\$)'),
        IShortActionCarrier('comment'),
      ),
      ],
  },
  ignoreCase: true,
  defaultToken: '',
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket('{', '}', 'delimiter.bracket'),
    IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
    IMonarchLanguageBracket('[', ']', 'delimiter.square'),
  ],
  tokenPostfix: '.shell',
  extra: <String, Object?>{
      'builtins': <Object?>[
        'ab',
        'awk',
        'bash',
        'beep',
        'cat',
        'cc',
        'cd',
        'chown',
        'chmod',
        'chroot',
        'clear',
        'cp',
        'curl',
        'cut',
        'diff',
        'echo',
        'find',
        'gawk',
        'gcc',
        'get',
        'git',
        'grep',
        'hg',
        'kill',
        'killall',
        'ln',
        'ls',
        'make',
        'mkdir',
        'openssl',
        'mv',
        'nc',
        'node',
        'npm',
        'ping',
        'ps',
        'restart',
        'rm',
        'rmdir',
        'sed',
        'service',
        'sh',
        'shopt',
        'shred',
        'source',
        'sort',
        'sleep',
        'ssh',
        'start',
        'stop',
        'su',
        'sudo',
        'svn',
        'tee',
        'telnet',
        'top',
        'touch',
        'vi',
        'vim',
        'wall',
        'wc',
        'wget',
        'who',
        'write',
        'yes',
        'zsh',
      ],
      'identifiersWithDashes': RegExp('[a-zA-Z]\\w+(?:@startingWithDash)+'),
      'keywords': <Object?>[
        'if',
        'then',
        'do',
        'else',
        'elif',
        'while',
        'until',
        'for',
        'in',
        'esac',
        'fi',
        'fin',
        'fil',
        'done',
        'exit',
        'set',
        'unset',
        'export',
        'function',
      ],
      'startingWithDash': RegExp('\\-+\\w+'),
      'symbols': RegExp('[=><!~?&|+\\-*\\/\\^;\\.,]+'),
    },
);
