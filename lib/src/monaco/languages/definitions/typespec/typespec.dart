// 1:1 translation of monaco-editor/src/languages/definitions/typespec/typespec.ts
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
      'close': ' */',
      'notIn': <Object?>[
        'string',
      ],
      'open': '/**',
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
    'lineComment': '//',
  },
  'indentationRules': <String, Object?>{
    'decreaseIndentPattern': RegExp('^((?!.*?\\/\\*).*\\*\\/)?\\s*[\\}\\]].*\$'),
    'increaseIndentPattern': RegExp('^((?!\\/\\/).)*(\\{([^}"\'`/]*|(\\t|[ ])*\\/\\/.*)|\\([^)"\'`/]*|\\[[^\\]"\'`/]*)\$'),
    'unIndentedLinePattern': RegExp('^(\\t|[ ])*[ ]\\*[^/]*\\*\\/\\s*\$|^(\\t|[ ])*[ ]\\*\\/\\s*\$|^(\\t|[ ])*[ ]\\*([ ]([^\\*]|\\*(?!\\/))*)?\$'),
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
    'bracketCounting': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            next: '@bracketCounting',
            token: 'delimiter.bracket',
          ),
        regex: '{',
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            next: '@pop',
            token: 'delimiter.bracket',
          ),
        regex: '}',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression',
      ),
      ],
    'comment': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'comment',
          ),
        regex: '[^\\*]+',
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            next: '@pop',
            token: 'comment',
          ),
        regex: '\\*\\/',
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'comment',
          ),
        regex: '[\\/*]',
      ),
      ],
    'expression': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            next: '@stringVerbatim',
            token: 'string',
          ),
        regex: '"""',
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            next: '@stringLiteral',
            token: 'string',
          ),
        regex: '"(?!"")',
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'number',
          ),
        regex: '[0-9]+',
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            cases: <String, Object?>{
                '@default': <String, Object?>{
                  'token': 'identifier',
                },
                '@keywords': <String, Object?>{
                  'token': 'keyword',
                },
                '@namedLiterals': <String, Object?>{
                  'token': 'keyword',
                },
              },
          ),
        regex: '\\b[_a-zA-Z][_a-zA-Z0-9]*\\b',
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
        regex: '@\\b[_a-zA-Z][_a-zA-Z0-9]*\\b',
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'directive',
          ),
        regex: '#\\b[_a-zA-Z-0-9]+\\b',
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@expression',
      ),
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
      ],
    'stringLiteral': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            next: '@bracketCounting',
            token: 'delimiter.bracket',
          ),
        regex: '\\\${',
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'string',
          ),
        regex: '[^\\\\"\$]+',
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'string.escape',
          ),
        regex: '@escapes',
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'string.escape.invalid',
          ),
        regex: '\\\\.',
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            next: '@pop',
            token: 'string',
          ),
        regex: '"',
      ),
      ],
    'stringVerbatim': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'string',
          ),
        regex: '(|"|"")[^"]',
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            next: '@pop',
            token: 'string',
          ),
        regex: '"""(?!")',
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        regex: '[ \\t\\r\\n]',
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            next: '@comment',
            token: 'comment',
          ),
        regex: '\\/\\*',
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'comment',
          ),
        regex: '\\/\\/.*\$',
      ),
      ],
  },
  defaultToken: '',
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
    IMonarchLanguageBracket('[', ']', 'delimiter.square'),
    IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
  ],
  tokenPostfix: '.tsp',
  extra: <String, Object?>{
      'escapes': '\\\\(u{[0-9A-Fa-f]+}|n|r|t|\\\\|"|\\\${)',
      'keywords': <Object?>[
        'import',
        'model',
        'scalar',
        'namespace',
        'op',
        'interface',
        'union',
        'using',
        'is',
        'extends',
        'enum',
        'alias',
        'return',
        'void',
        'if',
        'else',
        'projection',
        'dec',
        'extern',
        'fn',
      ],
      'namedLiterals': <Object?>[
        'true',
        'false',
        'null',
        'unknown',
        'never',
      ],
      'symbols': RegExp('[=:;<>]+'),
    },
);
