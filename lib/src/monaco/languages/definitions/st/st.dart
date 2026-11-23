// 1:1 translation of monaco-editor/src/languages/definitions/st/st.ts
// Monarch language definition data, evaluated from the TS source via
// the TypeScript compiler (computed template/const values resolved).
// TS object literals -> Dart data; typed rule/action/bracket carriers
// mirror the ported monarchCompile. Regex flags preserved in RegExp.

import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchTypes.dart';

/// 1:1: `export const conf: languages.LanguageConfiguration = {...}`
final Map<String, Object?> conf = <String, Object?>{
  'autoClosingPairs': <Object?>[
    <String, Object?>{
      'close': ']',
      'open': '[',
    },
    <String, Object?>{
      'close': '}',
      'open': '{',
    },
    <String, Object?>{
      'close': ')',
      'open': '(',
    },
    <String, Object?>{
      'close': '*/',
      'open': '/*',
    },
    <String, Object?>{
      'close': '\'',
      'notIn': <Object?>[
        'string_sq',
      ],
      'open': '\'',
    },
    <String, Object?>{
      'close': '"',
      'notIn': <Object?>[
        'string_dq',
      ],
      'open': '"',
    },
    <String, Object?>{
      'close': 'end_var',
      'open': 'var_input',
    },
    <String, Object?>{
      'close': 'end_var',
      'open': 'var_output',
    },
    <String, Object?>{
      'close': 'end_var',
      'open': 'var_in_out',
    },
    <String, Object?>{
      'close': 'end_var',
      'open': 'var_temp',
    },
    <String, Object?>{
      'close': 'end_var',
      'open': 'var_global',
    },
    <String, Object?>{
      'close': 'end_var',
      'open': 'var_access',
    },
    <String, Object?>{
      'close': 'end_var',
      'open': 'var_external',
    },
    <String, Object?>{
      'close': 'end_type',
      'open': 'type',
    },
    <String, Object?>{
      'close': 'end_struct',
      'open': 'struct',
    },
    <String, Object?>{
      'close': 'end_program',
      'open': 'program',
    },
    <String, Object?>{
      'close': 'end_function',
      'open': 'function',
    },
    <String, Object?>{
      'close': 'end_function_block',
      'open': 'function_block',
    },
    <String, Object?>{
      'close': 'end_action',
      'open': 'action',
    },
    <String, Object?>{
      'close': 'end_step',
      'open': 'step',
    },
    <String, Object?>{
      'close': 'end_step',
      'open': 'initial_step',
    },
    <String, Object?>{
      'close': 'end_transaction',
      'open': 'transaction',
    },
    <String, Object?>{
      'close': 'end_configuration',
      'open': 'configuration',
    },
    <String, Object?>{
      'close': 'end_tcp',
      'open': 'tcp',
    },
    <String, Object?>{
      'close': 'end_recource',
      'open': 'recource',
    },
    <String, Object?>{
      'close': 'end_channel',
      'open': 'channel',
    },
    <String, Object?>{
      'close': 'end_library',
      'open': 'library',
    },
    <String, Object?>{
      'close': 'end_folder',
      'open': 'folder',
    },
    <String, Object?>{
      'close': 'end_binaries',
      'open': 'binaries',
    },
    <String, Object?>{
      'close': 'end_includes',
      'open': 'includes',
    },
    <String, Object?>{
      'close': 'end_sources',
      'open': 'sources',
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
    <Object?>[
      'var',
      'end_var',
    ],
    <Object?>[
      'var_input',
      'end_var',
    ],
    <Object?>[
      'var_output',
      'end_var',
    ],
    <Object?>[
      'var_in_out',
      'end_var',
    ],
    <Object?>[
      'var_temp',
      'end_var',
    ],
    <Object?>[
      'var_global',
      'end_var',
    ],
    <Object?>[
      'var_access',
      'end_var',
    ],
    <Object?>[
      'var_external',
      'end_var',
    ],
    <Object?>[
      'type',
      'end_type',
    ],
    <Object?>[
      'struct',
      'end_struct',
    ],
    <Object?>[
      'program',
      'end_program',
    ],
    <Object?>[
      'function',
      'end_function',
    ],
    <Object?>[
      'function_block',
      'end_function_block',
    ],
    <Object?>[
      'action',
      'end_action',
    ],
    <Object?>[
      'step',
      'end_step',
    ],
    <Object?>[
      'initial_step',
      'end_step',
    ],
    <Object?>[
      'transaction',
      'end_transaction',
    ],
    <Object?>[
      'configuration',
      'end_configuration',
    ],
    <Object?>[
      'tcp',
      'end_tcp',
    ],
    <Object?>[
      'recource',
      'end_recource',
    ],
    <Object?>[
      'channel',
      'end_channel',
    ],
    <Object?>[
      'library',
      'end_library',
    ],
    <Object?>[
      'folder',
      'end_folder',
    ],
    <Object?>[
      'binaries',
      'end_binaries',
    ],
    <Object?>[
      'includes',
      'end_includes',
    ],
    <Object?>[
      'sources',
      'end_sources',
    ],
  ],
  'comments': <String, Object?>{
    'blockComment': <Object?>[
      '(*',
      '*)',
    ],
    'lineComment': '//',
  },
  'folding': <String, Object?>{
    'markers': <String, Object?>{
      'end': RegExp('^\\s*#pragma\\s+endregion\\b'),
      'start': RegExp('^\\s*#pragma\\s+region\\b'),
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
    <String, Object?>{
      'close': 'end_var',
      'open': 'var',
    },
    <String, Object?>{
      'close': 'end_var',
      'open': 'var_input',
    },
    <String, Object?>{
      'close': 'end_var',
      'open': 'var_output',
    },
    <String, Object?>{
      'close': 'end_var',
      'open': 'var_in_out',
    },
    <String, Object?>{
      'close': 'end_var',
      'open': 'var_temp',
    },
    <String, Object?>{
      'close': 'end_var',
      'open': 'var_global',
    },
    <String, Object?>{
      'close': 'end_var',
      'open': 'var_access',
    },
    <String, Object?>{
      'close': 'end_var',
      'open': 'var_external',
    },
    <String, Object?>{
      'close': 'end_type',
      'open': 'type',
    },
    <String, Object?>{
      'close': 'end_struct',
      'open': 'struct',
    },
    <String, Object?>{
      'close': 'end_program',
      'open': 'program',
    },
    <String, Object?>{
      'close': 'end_function',
      'open': 'function',
    },
    <String, Object?>{
      'close': 'end_function_block',
      'open': 'function_block',
    },
    <String, Object?>{
      'close': 'end_action',
      'open': 'action',
    },
    <String, Object?>{
      'close': 'end_step',
      'open': 'step',
    },
    <String, Object?>{
      'close': 'end_step',
      'open': 'initial_step',
    },
    <String, Object?>{
      'close': 'end_transaction',
      'open': 'transaction',
    },
    <String, Object?>{
      'close': 'end_configuration',
      'open': 'configuration',
    },
    <String, Object?>{
      'close': 'end_tcp',
      'open': 'tcp',
    },
    <String, Object?>{
      'close': 'end_recource',
      'open': 'recource',
    },
    <String, Object?>{
      'close': 'end_channel',
      'open': 'channel',
    },
    <String, Object?>{
      'close': 'end_library',
      'open': 'library',
    },
    <String, Object?>{
      'close': 'end_folder',
      'open': 'folder',
    },
    <String, Object?>{
      'close': 'end_binaries',
      'open': 'binaries',
    },
    <String, Object?>{
      'close': 'end_includes',
      'open': 'includes',
    },
    <String, Object?>{
      'close': 'end_sources',
      'open': 'sources',
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
        RegExp('\\/\\*'),
        IShortActionCarrier('comment'),
        '@push',
      ),
        IShortMonarchLanguageRule2(
        '\\*/',
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\/*]'),
        IShortActionCarrier('comment'),
      ),
      ],
    'comment2': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\(*]+'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\(\\*'),
        IShortActionCarrier('comment'),
        '@push',
      ),
        IShortMonarchLanguageRule2(
        '\\*\\)',
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\(*]'),
        IShortActionCarrier('comment'),
      ),
      ],
    'params': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\b[A-Za-z0-9_]+\\b(?=\\()'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'identifier',
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\b[A-Za-z0-9_]+\\b'),
        IShortActionCarrier('variable.name'),
        '@pop',
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(\\.\\.)'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\b(16#[0-9A-Fa-f\\_]*)+\\b'),
        IShortActionCarrier('number.hex'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\b(2#[01\\_]+)+\\b'),
        IShortActionCarrier('number.binary'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\b(8#[0-9\\_]*)+\\b'),
        IShortActionCarrier('number.octal'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\b\\d*\\.\\d+([eE][\\-+]?\\d+)?\\b'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\b(L?REAL)#[0-9\\_\\.e]+\\b'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\b(BYTE|(?:D|L)?WORD|U?(?:S|D|L)?INT)#[0-9\\_]+\\b'),
        IShortActionCarrier('number'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d+'),
        IShortActionCarrier('number'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\b(T|DT|TOD)#[0-9:-_shmyd]+\\b'),
        IShortActionCarrier('tag'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\%(I|Q|M)(X|B|W|D|L)[0-9\\.]+'),
        IShortActionCarrier('tag'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\%(I|Q|M)[0-9\\.]*'),
        IShortActionCarrier('tag'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\b[A-Za-z]{1,6}#[0-9]+\\b'),
        IShortActionCarrier('tag'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\b(TO_|CTU_|CTD_|CTUD_|MUX_|SEL_)[A_Za-z]+\\b'),
        IShortActionCarrier('predefined'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\b[A_Za-z]+(_TO_)[A_Za-z]+\\b'),
        IShortActionCarrier('predefined'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[;]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[.]'),
        IExpandedMonarchLanguageAction(
          next: '@params',
          token: 'delimiter',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[a-zA-Z_]\\w*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@builtinFunctions': 'predefined',
              '@builtinVariables': 'predefined',
              '@constant': 'constant',
              '@default': 'identifier',
              '@defineKeywords': 'variable',
              '@keywords': 'keyword',
              '@operators': 'operators',
              '@typeKeywords': 'type',
            },
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[{}()\\[\\]]'),
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"\\\\]|\\\\.)*\$'),
        IShortActionCarrier('string.invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@string_dq',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@string_sq',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'[^\\\\\']\''),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\')(@escapes)(\')'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('string'),
          IShortActionCarrier('string.escape'),
          IShortActionCarrier('string'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IShortActionCarrier('string.invalid'),
      ),
      ],
    'string_dq': <IMonarchLanguageRule>[
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
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          next: '@pop',
          token: 'string.quote',
        ),
      ),
      ],
    'string_sq': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\\']+'),
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
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          next: '@pop',
          token: 'string.quote',
        ),
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[ \\t\\r\\n]+'),
        IShortActionCarrier('white'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\/\\/.*\$'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\/\\*'),
        IShortActionCarrier('comment'),
        '@comment',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\(\\*'),
        IShortActionCarrier('comment'),
        '@comment2',
      ),
      ],
  },
  ignoreCase: true,
  defaultToken: '',
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
    IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
    IMonarchLanguageBracket('[', ']', 'delimiter.square'),
  ],
  tokenPostfix: '.st',
  extra: <String, Object?>{
      'builtinFunctions': <Object?>[
        'sr',
        'rs',
        'tp',
        'ton',
        'tof',
        'eq',
        'ge',
        'le',
        'lt',
        'ne',
        'round',
        'trunc',
        'ctd',
        'сtu',
        'ctud',
        'r_trig',
        'f_trig',
        'move',
        'concat',
        'delete',
        'find',
        'insert',
        'left',
        'len',
        'replace',
        'right',
        'rtc',
      ],
      'builtinVariables': <Object?>[],
      'constant': <Object?>[
        'false',
        'true',
        'null',
      ],
      'defineKeywords': <Object?>[
        'var',
        'var_input',
        'var_output',
        'var_in_out',
        'var_temp',
        'var_global',
        'var_access',
        'var_external',
        'end_var',
        'type',
        'end_type',
        'struct',
        'end_struct',
        'program',
        'end_program',
        'function',
        'end_function',
        'function_block',
        'end_function_block',
        'interface',
        'end_interface',
        'method',
        'end_method',
        'property',
        'end_property',
        'namespace',
        'end_namespace',
        'configuration',
        'end_configuration',
        'tcp',
        'end_tcp',
        'resource',
        'end_resource',
        'channel',
        'end_channel',
        'library',
        'end_library',
        'folder',
        'end_folder',
        'binaries',
        'end_binaries',
        'includes',
        'end_includes',
        'sources',
        'end_sources',
        'action',
        'end_action',
        'step',
        'initial_step',
        'end_step',
        'transaction',
        'end_transaction',
      ],
      'escapes': RegExp('\\\\(?:[abfnrtv\\\\"\']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})'),
      'keywords': <Object?>[
        'if',
        'end_if',
        'elsif',
        'else',
        'case',
        'of',
        'to',
        '__try',
        '__catch',
        '__finally',
        'do',
        'with',
        'by',
        'while',
        'repeat',
        'end_while',
        'end_repeat',
        'end_case',
        'for',
        'end_for',
        'task',
        'retain',
        'non_retain',
        'constant',
        'with',
        'at',
        'exit',
        'return',
        'interval',
        'priority',
        'address',
        'port',
        'on_channel',
        'then',
        'iec',
        'file',
        'uses',
        'version',
        'packagetype',
        'displayname',
        'copyright',
        'summary',
        'vendor',
        'common_source',
        'from',
        'extends',
        'implements',
      ],
      'operators': <Object?>[
        '=',
        '>',
        '<',
        ':',
        ':=',
        '<=',
        '>=',
        '<>',
        '&',
        '+',
        '-',
        '*',
        '**',
        'MOD',
        '^',
        'or',
        'and',
        'not',
        'xor',
        'abs',
        'acos',
        'asin',
        'atan',
        'cos',
        'exp',
        'expt',
        'ln',
        'log',
        'sin',
        'sqrt',
        'tan',
        'sel',
        'max',
        'min',
        'limit',
        'mux',
        'shl',
        'shr',
        'rol',
        'ror',
        'indexof',
        'sizeof',
        'adr',
        'adrinst',
        'bitadr',
        'is_valid',
        'ref',
        'ref_to',
      ],
      'symbols': RegExp('[=><!~?:&|+\\-*\\/\\^%]+'),
      'typeKeywords': <Object?>[
        'int',
        'sint',
        'dint',
        'lint',
        'usint',
        'uint',
        'udint',
        'ulint',
        'real',
        'lreal',
        'time',
        'date',
        'time_of_day',
        'date_and_time',
        'string',
        'bool',
        'byte',
        'word',
        'dword',
        'array',
        'pointer',
        'lword',
      ],
    },
);
