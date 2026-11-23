// 1:1 translation of monaco-editor/src/languages/definitions/swift/swift.ts
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
    'blockComment': <Object?>[
      '/*',
      '*/',
    ],
    'lineComment': '//',
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
    'attribute': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('@@@identifier'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@attributes': 'keyword.control',
              '@default': '',
            },
        ),
      ),
      ],
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\/\\/\\/.*\$'),
        IShortActionCarrier('comment.doc'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\/\\*\\*'),
        IShortActionCarrier('comment.doc'),
        '@commentdocbody',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\/\\/.*\$'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\/\\*'),
        IShortActionCarrier('comment'),
        '@commentbody',
      ),
      ],
    'commentbody': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('\\/\\*'),
        IShortActionCarrier('comment'),
        '@commentbody',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\*\\/'),
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('comment'),
      ),
      ],
    'commentdocbody': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('\\/\\*'),
        IShortActionCarrier('comment'),
        '@commentbody',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\*\\/'),
        IShortActionCarrier('comment.doc'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\:[a-zA-Z]+\\:'),
        IShortActionCarrier('comment.doc.param'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('comment.doc'),
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
        IShortActionCarrier('string.quote'),
        '@popall',
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IShortActionCarrier('string'),
      ),
      ],
    'escapedkeyword': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('`'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'operator',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('identifier'),
      ),
      ],
    'interpolatedexpression': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\('),
        IExpandedMonarchLanguageAction(
          next: '@interpolatedexpression',
          token: 'operator',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\)'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'operator',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@literal',
      ),
        IExpandedMonarchLanguageRule(
        include: '@keyword',
      ),
        IExpandedMonarchLanguageRule(
        include: '@symbol',
      ),
      ],
    'invokedmethod': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('([.])(@identifier)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$2': <Object?>[
                'delimeter',
                'type.identifier',
              ],
              '@default': '',
            },
        ),
      ),
      ],
    'keyword': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('`'),
        IExpandedMonarchLanguageAction(
          next: '@escapedkeyword',
          token: 'operator',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@identifier'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'identifier',
              '@keywords': 'keyword',
              '[A-Z][a-zA-Z0-9\$]*': 'type.identifier',
            },
        ),
      ),
      ],
    'literal': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@stringlit',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[b]([01]_?)+'),
        IShortActionCarrier('number.binary'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[o]([0-7]_?)+'),
        IShortActionCarrier('number.octal'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[x]([0-9a-fA-F]_?)+([pP][\\-+](\\d_?)+)?'),
        IShortActionCarrier('number.hex'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\d_?)*\\.(\\d_?)+([eE][\\-+]?(\\d_?)+)?'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\d_?)+'),
        IShortActionCarrier('number'),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IExpandedMonarchLanguageRule(
        include: '@comment',
      ),
        IExpandedMonarchLanguageRule(
        include: '@attribute',
      ),
        IExpandedMonarchLanguageRule(
        include: '@literal',
      ),
        IExpandedMonarchLanguageRule(
        include: '@keyword',
      ),
        IExpandedMonarchLanguageRule(
        include: '@invokedmethod',
      ),
        IExpandedMonarchLanguageRule(
        include: '@symbol',
      ),
      ],
    'stringlit': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\\\\\('),
        IExpandedMonarchLanguageAction(
          next: '@interpolatedexpression',
          token: 'operator',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string.escape.invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('string'),
      ),
      ],
    'symbol': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[{}()\\[\\]]'),
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[<>](?!@symbols)'),
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[.]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@operators'),
        IShortActionCarrier('operator'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@symbols'),
        IShortActionCarrier('operator'),
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\s+'),
        IShortActionCarrier('white'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"""'),
        IShortActionCarrier('string.quote'),
        '@endDblDocString',
      ),
      ],
  },
  defaultToken: '',
  tokenPostfix: '.swift',
  extra: <String, Object?>{
      'accessmodifiers': <Object?>[
        'open',
        'public',
        'internal',
        'fileprivate',
        'private',
      ],
      'attributes': <Object?>[
        '@GKInspectable',
        '@IBAction',
        '@IBDesignable',
        '@IBInspectable',
        '@IBOutlet',
        '@IBSegueAction',
        '@NSApplicationMain',
        '@NSCopying',
        '@NSManaged',
        '@Sendable',
        '@UIApplicationMain',
        '@autoclosure',
        '@actorIndependent',
        '@asyncHandler',
        '@available',
        '@convention',
        '@derivative',
        '@differentiable',
        '@discardableResult',
        '@dynamicCallable',
        '@dynamicMemberLookup',
        '@escaping',
        '@frozen',
        '@globalActor',
        '@inlinable',
        '@inline',
        '@main',
        '@noDerivative',
        '@nonobjc',
        '@noreturn',
        '@objc',
        '@objcMembers',
        '@preconcurrency',
        '@propertyWrapper',
        '@requires_stored_property_inits',
        '@resultBuilder',
        '@testable',
        '@unchecked',
        '@unknown',
        '@usableFromInline',
        '@warn_unqualified_access',
      ],
      'escapes': RegExp('\\\\(?:[abfnrtv\\\\"\']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})'),
      'identifier': RegExp('[a-zA-Z_][\\w\$]*'),
      'keywords': <Object?>[
        '#available',
        '#colorLiteral',
        '#column',
        '#dsohandle',
        '#else',
        '#elseif',
        '#endif',
        '#error',
        '#file',
        '#fileID',
        '#fileLiteral',
        '#filePath',
        '#function',
        '#if',
        '#imageLiteral',
        '#keyPath',
        '#line',
        '#selector',
        '#sourceLocation',
        '#warning',
        'Any',
        'Protocol',
        'Self',
        'Type',
        'actor',
        'as',
        'assignment',
        'associatedtype',
        'associativity',
        'async',
        'await',
        'break',
        'case',
        'catch',
        'class',
        'continue',
        'convenience',
        'default',
        'defer',
        'deinit',
        'didSet',
        'do',
        'dynamic',
        'dynamicType',
        'else',
        'enum',
        'extension',
        'fallthrough',
        'false',
        'fileprivate',
        'final',
        'for',
        'func',
        'get',
        'guard',
        'higherThan',
        'if',
        'import',
        'in',
        'indirect',
        'infix',
        'init',
        'inout',
        'internal',
        'is',
        'isolated',
        'lazy',
        'left',
        'let',
        'lowerThan',
        'mutating',
        'nil',
        'none',
        'nonisolated',
        'nonmutating',
        'open',
        'operator',
        'optional',
        'override',
        'postfix',
        'precedence',
        'precedencegroup',
        'prefix',
        'private',
        'protocol',
        'public',
        'repeat',
        'required',
        'rethrows',
        'return',
        'right',
        'safe',
        'self',
        'set',
        'some',
        'static',
        'struct',
        'subscript',
        'super',
        'switch',
        'throw',
        'throws',
        'true',
        'try',
        'typealias',
        'unowned',
        'unsafe',
        'var',
        'weak',
        'where',
        'while',
        'willSet',
        '__consuming',
        '__owned',
      ],
      'operatorend': RegExp('[\\u0300-\\u036F\\u1DC0-\\u1DFF\\u20D0-\\u20FF\\uFE00-\\uFE0F\\uFE20-\\uFE2F\\uE0100-\\uE01EF]'),
      'operators': RegExp('(@operatorstart)((@operatorstart)|(@operatorend))*'),
      'operatorstart': RegExp('[\\/=\\-+!*%<>&|^~?\\u00A1-\\u00A7\\u00A9\\u00AB\\u00AC\\u00AE\\u00B0-\\u00B1\\u00B6\\u00BB\\u00BF\\u00D7\\u00F7\\u2016-\\u2017\\u2020-\\u2027\\u2030-\\u203E\\u2041-\\u2053\\u2055-\\u205E\\u2190-\\u23FF\\u2500-\\u2775\\u2794-\\u2BFF\\u2E00-\\u2E7F\\u3001-\\u3003\\u3008-\\u3030]'),
      'symbols': RegExp('[=(){}\\[\\].,:;@#\\_&\\-<>`?!+*\\\\\\/]'),
    },
);
