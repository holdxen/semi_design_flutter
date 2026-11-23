// 1:1 translation of monaco-editor/src/languages/definitions/sparql/sparql.ts
// Monarch language definition data, evaluated from the TS source via
// the TypeScript compiler (computed template/const values resolved).
// TS object literals -> Dart data; typed rule/action/bracket carriers
// mirror the ported monarchCompile. Regex flags preserved in RegExp.

import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchTypes.dart';

/// 1:1: `export const conf: languages.LanguageConfiguration = {...}`
final Map<String, Object?> conf = <String, Object?>{
  'autoClosingPairs': <Object?>[
    <String, Object?>{
      'close': '\'',
      'notIn': <Object?>[
        'string',
      ],
      'open': '\'',
    },
    <String, Object?>{
      'close': '"',
      'notIn': <Object?>[
        'string',
      ],
      'open': '"',
    },
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
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'dblStringBody': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\"]+'),
        IShortActionCarrier('string.sql'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string.sql'),
        '@pop',
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('<[^\\s\\u00a0>]*>?'),
        IShortActionCarrier('tag'),
      ),
        IExpandedMonarchLanguageRule(
        include: '@strings',
      ),
        IShortMonarchLanguageRule1(
        RegExp('#.*'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[{}()\\[\\]]'),
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[;,.]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[_\\w\\d]+:(\\.(?=[\\w_\\-\\\\%])|[:\\w_-]|\\\\[-\\\\_~.!\$&\'()*+,;=/?#@%]|%[a-f\\d][a-f\\d])*'),
        IShortActionCarrier('tag'),
      ),
        IShortMonarchLanguageRule1(
        RegExp(':(\\.(?=[\\w_\\-\\\\%])|[:\\w_-]|\\\\[-\\\\_~.!\$&\'()*+,;=/?#@%]|%[a-f\\d][a-f\\d])+'),
        IShortActionCarrier('tag'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\$?]?[_\\w\\d]+'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@builtinFunctions': <String, Object?>{
                'token': 'predefined.sql',
              },
              '@default': 'identifier',
              '@keywords': <String, Object?>{
                'token': 'keyword',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\^\\^'),
        IShortActionCarrier('operator.sql'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\^[*+\\-<>=&|^\\/!?]*'),
        IShortActionCarrier('operator.sql'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[*+\\-<>=&|\\/!?]'),
        IShortActionCarrier('operator.sql'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@[a-z\\d\\-]*'),
        IShortActionCarrier('metatag.html'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\s+'),
        IShortActionCarrier('white'),
      ),
      ],
    'stringBody': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\\']+'),
        IShortActionCarrier('string.sql'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string.escape'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\''),
        IShortActionCarrier('string.sql'),
        '@pop',
      ),
      ],
    'strings': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\'([^\'\\\\]|\\\\.)*\$'),
        IShortActionCarrier('string.invalid'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\'\$'),
        IShortActionCarrier('string.sql'),
        '@pop',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\''),
        IShortActionCarrier('string.sql'),
        '@stringBody',
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"\\\\]|\\\\.)*\$'),
        IShortActionCarrier('string.invalid'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"\$'),
        IShortActionCarrier('string.sql'),
        '@pop',
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string.sql'),
        '@dblStringBody',
      ),
      ],
  },
  ignoreCase: true,
  defaultToken: '',
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
    IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
    IMonarchLanguageBracket('[', ']', 'delimiter.square'),
    IMonarchLanguageBracket('<', '>', 'delimiter.angle'),
  ],
  tokenPostfix: '.rq',
  extra: <String, Object?>{
      'builtinFunctions': <Object?>[
        'a',
        'abs',
        'avg',
        'bind',
        'bnode',
        'bound',
        'ceil',
        'coalesce',
        'concat',
        'contains',
        'count',
        'datatype',
        'day',
        'encode_for_uri',
        'exists',
        'floor',
        'group_concat',
        'hours',
        'if',
        'iri',
        'isblank',
        'isiri',
        'isliteral',
        'isnumeric',
        'isuri',
        'lang',
        'langmatches',
        'lcase',
        'max',
        'md5',
        'min',
        'minutes',
        'month',
        'now',
        'rand',
        'regex',
        'replace',
        'round',
        'sameterm',
        'sample',
        'seconds',
        'sha1',
        'sha256',
        'sha384',
        'sha512',
        'str',
        'strafter',
        'strbefore',
        'strdt',
        'strends',
        'strlang',
        'strlen',
        'strstarts',
        'struuid',
        'substr',
        'sum',
        'timezone',
        'tz',
        'ucase',
        'uri',
        'uuid',
        'year',
      ],
      'keywords': <Object?>[
        'add',
        'as',
        'asc',
        'ask',
        'base',
        'by',
        'clear',
        'construct',
        'copy',
        'create',
        'data',
        'delete',
        'desc',
        'describe',
        'distinct',
        'drop',
        'false',
        'filter',
        'from',
        'graph',
        'group',
        'having',
        'in',
        'insert',
        'limit',
        'load',
        'minus',
        'move',
        'named',
        'not',
        'offset',
        'optional',
        'order',
        'prefix',
        'reduced',
        'select',
        'service',
        'silent',
        'to',
        'true',
        'undef',
        'union',
        'using',
        'values',
        'where',
        'with',
      ],
    },
);
