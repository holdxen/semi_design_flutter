// 1:1 translation of monaco-editor/src/languages/definitions/python/python.ts
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
      '\'\'\'',
      '\'\'\'',
    ],
    'lineComment': '#',
  },
  'folding': <String, Object?>{
    'markers': <String, Object?>{
      'end': RegExp('^\\s*#endregion\\b'),
      'start': RegExp('^\\s*#region\\b'),
    },
    'offSide': true,
  },
  'onEnterRules': <Object?>[
    <String, Object?>{
      'action': <String, Object?>{
        'indentAction': 1,
      },
      'beforeText': RegExp('^\\s*(?:def|class|for|if|elif|else|while|try|with|finally|except|async|match|case).*?:\\s*\$'),
    },
  ],
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
    'dblStringBody': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('[^\\\\"]+\$'),
        IShortActionCarrier('string'),
        '@popall',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\"]+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string.escape'),
        '@popall',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\\$'),
        IShortActionCarrier('string'),
      ),
      ],
    'endDblDocString': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"]+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\"'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"""'),
        IShortActionCarrier('string'),
        '@popall',
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IShortActionCarrier('string'),
      ),
      ],
    'endDocString': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\']+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\\''),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\'\'\''),
        IShortActionCarrier('string'),
        '@popall',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IShortActionCarrier('string'),
      ),
      ],
    'fDblStringBody': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('[^\\\\"\\{\\}]+\$'),
        IShortActionCarrier('string'),
        '@popall',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\"\\{\\}]+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\{[^\\}\':!=]+'),
        IShortActionCarrier('identifier'),
        '@fStringDetail',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string.escape'),
        '@popall',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\\$'),
        IShortActionCarrier('string'),
      ),
      ],
    'fStringBody': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('[^\\\\\'\\{\\}]+\$'),
        IShortActionCarrier('string'),
        '@popall',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\\'\\{\\}]+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\{[^\\}\':!=]+'),
        IShortActionCarrier('identifier'),
        '@fStringDetail',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\''),
        IShortActionCarrier('string.escape'),
        '@popall',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\\$'),
        IShortActionCarrier('string'),
      ),
      ],
    'fStringDetail': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[:][^}]+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[!][ars]'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\}'),
        IShortActionCarrier('identifier'),
        '@pop',
      ),
      ],
    'numbers': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('-?0x([abcdef]|[ABCDEF]|\\d)+[lL]?'),
        IShortActionCarrier('number.hex'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('-?(\\d*\\.)?\\d+([eE][+\\-]?\\d+)?[jJ]?[lL]?'),
        IShortActionCarrier('number'),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IExpandedMonarchLanguageRule(
        include: '@numbers',
      ),
        IExpandedMonarchLanguageRule(
        include: '@strings',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[,:;]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[{}\\[\\]()]'),
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@[a-zA-Z_]\\w*'),
        IShortActionCarrier('tag'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[a-zA-Z_]\\w*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'identifier',
              '@keywords': 'keyword',
            },
        ),
      ),
      ],
    'stringBody': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('[^\\\\\']+\$'),
        IShortActionCarrier('string'),
        '@popall',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\\']+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\''),
        IShortActionCarrier('string.escape'),
        '@popall',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\\$'),
        IShortActionCarrier('string'),
      ),
      ],
    'strings': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('\'\$'),
        IShortActionCarrier('string.escape'),
        '@popall',
      ),
        IShortMonarchLanguageRule2(
        RegExp('f\'{1,3}'),
        IShortActionCarrier('string.escape'),
        '@fStringBody',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\''),
        IShortActionCarrier('string.escape'),
        '@stringBody',
      ),
        IShortMonarchLanguageRule2(
        RegExp('"\$'),
        IShortActionCarrier('string.escape'),
        '@popall',
      ),
        IShortMonarchLanguageRule2(
        RegExp('f"{1,3}'),
        IShortActionCarrier('string.escape'),
        '@fDblStringBody',
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string.escape'),
        '@dblStringBody',
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\s+'),
        IShortActionCarrier('white'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(^#.*\$)'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\'\'\''),
        IShortActionCarrier('string'),
        '@endDocString',
      ),
        IShortMonarchLanguageRule2(
        RegExp('"""'),
        IShortActionCarrier('string'),
        '@endDblDocString',
      ),
      ],
  },
  defaultToken: '',
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
    IMonarchLanguageBracket('[', ']', 'delimiter.bracket'),
    IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
  ],
  tokenPostfix: '.python',
  extra: <String, Object?>{
      'keywords': <Object?>[
        'False',
        'None',
        'True',
        '_',
        'and',
        'as',
        'assert',
        'async',
        'await',
        'break',
        'case',
        'class',
        'continue',
        'def',
        'del',
        'elif',
        'else',
        'except',
        'exec',
        'finally',
        'for',
        'from',
        'global',
        'if',
        'import',
        'in',
        'is',
        'lambda',
        'match',
        'nonlocal',
        'not',
        'or',
        'pass',
        'print',
        'raise',
        'return',
        'try',
        'type',
        'while',
        'with',
        'yield',
        'int',
        'float',
        'long',
        'complex',
        'hex',
        'abs',
        'all',
        'any',
        'apply',
        'basestring',
        'bin',
        'bool',
        'buffer',
        'bytearray',
        'callable',
        'chr',
        'classmethod',
        'cmp',
        'coerce',
        'compile',
        'complex',
        'delattr',
        'dict',
        'dir',
        'divmod',
        'enumerate',
        'eval',
        'execfile',
        'file',
        'filter',
        'format',
        'frozenset',
        'getattr',
        'globals',
        'hasattr',
        'hash',
        'help',
        'id',
        'input',
        'intern',
        'isinstance',
        'issubclass',
        'iter',
        'len',
        'locals',
        'list',
        'map',
        'max',
        'memoryview',
        'min',
        'next',
        'object',
        'oct',
        'open',
        'ord',
        'pow',
        'print',
        'property',
        'reversed',
        'range',
        'raw_input',
        'reduce',
        'reload',
        'repr',
        'reversed',
        'round',
        'self',
        'set',
        'setattr',
        'slice',
        'sorted',
        'staticmethod',
        'str',
        'sum',
        'super',
        'tuple',
        'type',
        'unichr',
        'unicode',
        'vars',
        'xrange',
        'zip',
        '__dict__',
        '__methods__',
        '__members__',
        '__class__',
        '__bases__',
        '__name__',
        '__mro__',
        '__subclasses__',
        '__init__',
        '__import__',
      ],
    },
);
