// 1:1 translation of monaco-editor/src/languages/definitions/yaml/yaml.ts
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
    'lineComment': '#',
  },
  'folding': <String, Object?>{
    'offSide': true,
  },
  'onEnterRules': <Object?>[
    <String, Object?>{
      'action': <String, Object?>{
        'indentAction': 1,
      },
      'beforeText': RegExp(':\\s*\$'),
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
    'anchor': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[&*][^ ]+'),
        IShortActionCarrier('namespace'),
      ),
      ],
    'array': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IExpandedMonarchLanguageRule(
        include: '@comment',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\]'),
        IShortActionCarrier('@brackets'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp(','),
        IShortActionCarrier('delimiter.comma'),
      ),
        IExpandedMonarchLanguageRule(
        include: '@flowCollections',
      ),
        IExpandedMonarchLanguageRule(
        include: '@flowScalars',
      ),
        IExpandedMonarchLanguageRule(
        include: '@tagHandle',
      ),
        IExpandedMonarchLanguageRule(
        include: '@anchor',
      ),
        IExpandedMonarchLanguageRule(
        include: '@flowNumber',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\],]+'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'string',
              '@keywords': 'keyword',
            },
        ),
      ),
      ],
    'blockStyle': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('[>|][0-9]*[+-]?\$'),
        IShortActionCarrier('operators'),
        '@multiString',
      ),
      ],
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('#.*\$'),
        IShortActionCarrier('comment'),
      ),
      ],
    'doubleQuotedString': <IMonarchLanguageRule>[
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
    'flowCollections': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('\\['),
        IShortActionCarrier('@brackets'),
        '@array',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\{'),
        IShortActionCarrier('@brackets'),
        '@object',
      ),
      ],
    'flowNumber': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('@numberInteger(?=[ \\t]*[,\\]\\}])'),
        IShortActionCarrier('number'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@numberFloat(?=[ \\t]*[,\\]\\}])'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@numberOctal(?=[ \\t]*[,\\]\\}])'),
        IShortActionCarrier('number.octal'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@numberHex(?=[ \\t]*[,\\]\\}])'),
        IShortActionCarrier('number.hex'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@numberInfinity(?=[ \\t]*[,\\]\\}])'),
        IShortActionCarrier('number.infinity'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@numberNaN(?=[ \\t]*[,\\]\\}])'),
        IShortActionCarrier('number.nan'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@numberDate(?=[ \\t]*[,\\]\\}])'),
        IShortActionCarrier('number.date'),
      ),
      ],
    'flowScalars': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('"([^"\\\\]|\\\\.)*\$'),
        IShortActionCarrier('string.invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\'\\\\]|\\\\.)*\$'),
        IShortActionCarrier('string.invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'[^\']*\''),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string'),
        '@doubleQuotedString',
      ),
      ],
    'multiString': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('^( +).+\$'),
        IShortActionCarrier('string'),
        '@multiStringContinued.\$1',
      ),
      ],
    'multiStringContinued': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('^( *).+\$'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==\$S2': 'string',
              '@default': <String, Object?>{
                'next': '@popall',
                'token': '@rematch',
              },
            },
        ),
      ),
      ],
    'object': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IExpandedMonarchLanguageRule(
        include: '@comment',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\}'),
        IShortActionCarrier('@brackets'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp(','),
        IShortActionCarrier('delimiter.comma'),
      ),
        IShortMonarchLanguageRule1(
        RegExp(':(?= )'),
        IShortActionCarrier('operators'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:".*?"|\'.*?\'|[^,\\{\\[]+?)(?=: )'),
        IShortActionCarrier('type'),
      ),
        IExpandedMonarchLanguageRule(
        include: '@flowCollections',
      ),
        IExpandedMonarchLanguageRule(
        include: '@flowScalars',
      ),
        IExpandedMonarchLanguageRule(
        include: '@tagHandle',
      ),
        IExpandedMonarchLanguageRule(
        include: '@anchor',
      ),
        IExpandedMonarchLanguageRule(
        include: '@flowNumber',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\},]+'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'string',
              '@keywords': 'keyword',
            },
        ),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IExpandedMonarchLanguageRule(
        include: '@comment',
      ),
        IShortMonarchLanguageRule1(
        RegExp('%[^ ]+.*\$'),
        IShortActionCarrier('meta.directive'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('---'),
        IShortActionCarrier('operators.directivesEnd'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\.{3}'),
        IShortActionCarrier('operators.documentEnd'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[-?:](?= )'),
        IShortActionCarrier('operators'),
      ),
        IExpandedMonarchLanguageRule(
        include: '@anchor',
      ),
        IExpandedMonarchLanguageRule(
        include: '@tagHandle',
      ),
        IExpandedMonarchLanguageRule(
        include: '@flowCollections',
      ),
        IExpandedMonarchLanguageRule(
        include: '@blockStyle',
      ),
        IShortMonarchLanguageRule1(
        RegExp('@numberInteger(?![ \\t]*\\S+)'),
        IShortActionCarrier('number'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@numberFloat(?![ \\t]*\\S+)'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@numberOctal(?![ \\t]*\\S+)'),
        IShortActionCarrier('number.octal'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@numberHex(?![ \\t]*\\S+)'),
        IShortActionCarrier('number.hex'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@numberInfinity(?![ \\t]*\\S+)'),
        IShortActionCarrier('number.infinity'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@numberNaN(?![ \\t]*\\S+)'),
        IShortActionCarrier('number.nan'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@numberDate(?![ \\t]*\\S+)'),
        IShortActionCarrier('number.date'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(".*?"|\'.*?\'|[^#\'"]*?)([ \\t]*)(:)( |\$)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('type'),
          IShortActionCarrier('white'),
          IShortActionCarrier('operators'),
          IShortActionCarrier('white'),
        ]),
      ),
        IExpandedMonarchLanguageRule(
        include: '@flowScalars',
      ),
        IShortMonarchLanguageRule1(
        RegExp('.+?(?=(\\s+#|\$))'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'string',
              '@keywords': 'keyword',
            },
        ),
      ),
      ],
    'tagHandle': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\![^ ]*'),
        IShortActionCarrier('tag'),
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[ \\t\\r\\n]+'),
        IShortActionCarrier('white'),
      ),
      ],
  },
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket('{', '}', 'delimiter.bracket'),
    IMonarchLanguageBracket('[', ']', 'delimiter.square'),
  ],
  tokenPostfix: '.yaml',
  extra: <String, Object?>{
      'escapes': RegExp('\\\\(?:[btnfr\\\\"\']|[0-7][0-7]?|[0-3][0-7]{2})'),
      'keywords': <Object?>[
        'true',
        'True',
        'TRUE',
        'false',
        'False',
        'FALSE',
        'null',
        'Null',
        'Null',
        '~',
      ],
      'numberDate': RegExp('\\d{4}-\\d\\d-\\d\\d([Tt ]\\d\\d:\\d\\d:\\d\\d(\\.\\d+)?(( ?[+-]\\d\\d?(:\\d\\d)?)|Z)?)?'),
      'numberFloat': RegExp('(?:0|[+-]?[0-9]+)(?:\\.[0-9]+)?(?:e[-+][1-9][0-9]*)?'),
      'numberHex': RegExp('0x[0-9a-fA-F]+'),
      'numberInfinity': RegExp('[+-]?\\.(?:inf|Inf|INF)'),
      'numberInteger': RegExp('(?:0|[+-]?[0-9]+)'),
      'numberNaN': RegExp('\\.(?:nan|Nan|NAN)'),
      'numberOctal': RegExp('0o[0-7]+'),
    },
);
