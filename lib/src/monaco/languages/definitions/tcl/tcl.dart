// 1:1 translation of monaco-editor/src/languages/definitions/tcl/tcl.ts
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
    'dstring': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\['),
        IExpandedMonarchLanguageAction(
          next: '@nestedCall',
          token: '@brackets',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$+(?:\\:\\:)?\\{'),
        IExpandedMonarchLanguageAction(
          next: '@nestedVariable',
          token: 'identifier',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@variables'),
        IShortActionCarrier('type.identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\\$\\[\\]"]+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IShortActionCarrier('string.escape'),
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
    'nestedCall': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\['),
        IExpandedMonarchLanguageAction(
          next: '@nestedCall',
          token: '@brackets',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\]'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: '@brackets',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: 'root',
      ),
      ],
    'nestedVariable': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\{\\}\\\$]+'),
        IShortActionCarrier('type.identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\}'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'identifier',
        ),
      ),
      ],
    'newlineComment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('.*\\\\\$'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.*(?!\\\\)\$'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'comment',
        ),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[a-zA-Z_]\\w*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@builtinFunctions': 'variable',
              '@default': 'operator.scss',
              '@mainFunctions': 'keyword',
              '@specialFunctions': <String, Object?>{
                'next': '@specialFunc',
                'token': 'keyword.flow',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\s+\\-+(?!\\d|\\.)\\w*|{\\*}'),
        IShortActionCarrier('metatag'),
      ),
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[{}()\\[\\]]'),
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@symbols'),
        IShortActionCarrier('operator'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$+(?:\\:\\:)?\\{'),
        IExpandedMonarchLanguageAction(
          next: '@nestedVariable',
          token: 'identifier',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@variables'),
        IShortActionCarrier('type.identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\.(?!\\d|\\.)[\\w\\-]*'),
        IShortActionCarrier('operator.sql'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d+(\\.\\d+)?'),
        IShortActionCarrier('number'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d+'),
        IShortActionCarrier('number'),
      ),
        IShortMonarchLanguageRule1(
        RegExp(';'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@dstring',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@sstring',
          token: 'string.quote',
        ),
      ),
      ],
    'specialFunc': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@dstring',
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@sstring',
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\S+'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'type',
        ),
      ),
      ],
    'sstring': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\['),
        IExpandedMonarchLanguageAction(
          next: '@nestedCall',
          token: '@brackets',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$+(?:\\:\\:)?\\{'),
        IExpandedMonarchLanguageAction(
          next: '@nestedVariable',
          token: 'identifier',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@variables'),
        IShortActionCarrier('type.identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\\$\\[\\]\']+'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IShortActionCarrier('string.escape'),
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
        RegExp('#.*\\\\\$'),
        IExpandedMonarchLanguageAction(
          next: '@newlineComment',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('#.*(?!\\\\)\$'),
        IShortActionCarrier('comment'),
      ),
      ],
  },
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
    IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
    IMonarchLanguageBracket('[', ']', 'delimiter.square'),
  ],
  tokenPostfix: '.tcl',
  extra: <String, Object?>{
      'builtinFunctions': <Object?>[
        'file',
        'info',
        'concat',
        'join',
        'lindex',
        'list',
        'llength',
        'lrange',
        'lsearch',
        'lsort',
        'split',
        'array',
        'parray',
        'binary',
        'format',
        'regexp',
        'regsub',
        'scan',
        'string',
        'subst',
        'dict',
        'cd',
        'clock',
        'exec',
        'glob',
        'pid',
        'pwd',
        'close',
        'eof',
        'fblocked',
        'fconfigure',
        'fcopy',
        'fileevent',
        'flush',
        'gets',
        'open',
        'puts',
        'read',
        'seek',
        'socket',
        'tell',
        'interp',
        'after',
        'auto_execok',
        'auto_load',
        'auto_mkindex',
        'auto_reset',
        'bgerror',
        'error',
        'global',
        'history',
        'load',
        'source',
        'time',
        'trace',
        'unknown',
        'unset',
        'update',
        'vwait',
        'winfo',
        'wm',
        'bind',
        'event',
        'pack',
        'place',
        'grid',
        'font',
        'bell',
        'clipboard',
        'destroy',
        'focus',
        'grab',
        'lower',
        'option',
        'raise',
        'selection',
        'send',
        'tk',
        'tkwait',
        'tk_bisque',
        'tk_focusNext',
        'tk_focusPrev',
        'tk_focusFollowsMouse',
        'tk_popup',
        'tk_setPalette',
      ],
      'escapes': RegExp('\\\\(?:[abfnrtv\\\\"\'\\[\\]\\{\\};\\\$]|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})'),
      'mainFunctions': <Object?>[
        'if',
        'then',
        'elseif',
        'else',
        'case',
        'switch',
        'while',
        'for',
        'break',
        'continue',
        'return',
        'package',
        'namespace',
        'catch',
        'exit',
        'eval',
        'expr',
        'uplevel',
        'upvar',
      ],
      'specialFunctions': <Object?>[
        'set',
        'unset',
        'rename',
        'variable',
        'proc',
        'coroutine',
        'foreach',
        'incr',
        'append',
        'lappend',
        'linsert',
        'lreplace',
      ],
      'symbols': RegExp('[=><!~?:&|+\\-*\\/\\^%]+'),
      'variables': RegExp('(?:\\\$+(?:(?:\\:\\:?)?[a-zA-Z_]\\w*)+)'),
    },
);
