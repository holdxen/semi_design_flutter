// 1:1 translation of monaco-editor/src/languages/definitions/protobuf/protobuf.ts
// Monarch language definition data, evaluated from the TS source via
// the TypeScript compiler (computed template/const values resolved).
// TS object literals -> Dart data; typed rule/action/bracket carriers
// mirror the ported monarchCompile. Regex flags preserved in RegExp.

import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchTypes.dart';

/// 1:1: `export const conf: languages.LanguageConfiguration = {...}`
final Map<String, Object?> conf = <String, Object?>{
  'autoCloseBefore': '.,=}])>\' \n\t',
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
      'close': '>',
      'open': '<',
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
    <Object?>[
      '<',
      '>',
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
    'increaseIndentPattern': RegExp('^((?!\\/\\/).)*(\\{[^}"\'`]*|\\([^)"\'`]*|\\[[^\\]"\'`]*)\$'),
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
      'close': '>',
      'open': '<',
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
    'constant': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '@boolLit',
        IShortActionCarrier('keyword.constant'),
      ),
        IShortMonarchLanguageRule1(
        '@hexLit',
        IShortActionCarrier('number.hex'),
      ),
        IShortMonarchLanguageRule1(
        '@octalLit',
        IShortActionCarrier('number.octal'),
      ),
        IShortMonarchLanguageRule1(
        '@decimalLit',
        IShortActionCarrier('number'),
      ),
        IShortMonarchLanguageRule1(
        '@floatLit',
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('("([^"\\\\]|\\\\.)*|\'([^\'\\\\]|\\\\.)*)\$'),
        IShortActionCarrier('string.invalid'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@string',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@stringSingle',
          token: 'string.quote',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('{'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@prototext',
          token: '@brackets',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('identifier'),
        IShortActionCarrier('identifier'),
      ),
      ],
    'enumBody': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IExpandedMonarchLanguageRule(
        include: '@constant',
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('operators'),
      ),
        IShortMonarchLanguageRule1(
        RegExp(';'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('option\\b'),
        IShortActionCarrier('keyword'),
        '@option.\$S2',
      ),
        IShortMonarchLanguageRule1(
        RegExp('@identifier'),
        IShortActionCarrier('identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\['),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@options.\$S2',
          token: '@brackets',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('}'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          next: '@pop',
          token: '@brackets',
        ),
      ),
      ],
    'enumDecl': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('@identifier'),
        IShortActionCarrier('type.identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('{'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          switchTo: '@enumBody.\$S2',
          token: '@brackets',
        ),
      ),
      ],
    'extendBody': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IExpandedMonarchLanguageRule(
        include: '@constant',
      ),
        IShortMonarchLanguageRule1(
        RegExp(';'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('(?:repeated|optional|required)'),
        IShortActionCarrier('keyword'),
        '@field.\$S2',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\['),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@options.\$S2',
          token: '@brackets',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('}'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          next: '@pop',
          token: '@brackets',
        ),
      ),
      ],
    'extendDecl': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('@identifier'),
        IShortActionCarrier('type.identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('{'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          switchTo: '@extendBody.\$S2',
          token: '@brackets',
        ),
      ),
      ],
    'field': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        'group',
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==proto2': <String, Object?>{
                'switchTo': '@groupDecl.\$S2',
                'token': 'keyword',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@identifier)(\\s*)(=)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('identifier'),
          IShortActionCarrier('white'),
          IExpandedMonarchLanguageAction(
            next: '@pop',
            token: 'delimiter',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@fullIdentifier|\\.'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@builtinTypes': 'keyword',
              '@default': 'type.identifier',
            },
        ),
      ),
      ],
    'groupDecl': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('@identifier'),
        IShortActionCarrier('identifier'),
      ),
        IShortMonarchLanguageRule1(
        '=',
        IShortActionCarrier('operator'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('{'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          switchTo: '@messageBody.\$S2',
          token: '@brackets',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@constant',
      ),
      ],
    'identifier': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule2(
        RegExp('@identifier'),
        IShortActionCarrier('identifier'),
        '@pop',
      ),
      ],
    'map': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('@fullIdentifier|\\.'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@builtinTypes': 'keyword',
              '@default': 'type.identifier',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp(','),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          switchTo: 'identifier',
          token: '@brackets',
        ),
      ),
      ],
    'messageBody': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IExpandedMonarchLanguageRule(
        include: '@constant',
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('operators'),
      ),
        IShortMonarchLanguageRule1(
        RegExp(';'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        '(map)(s*)(<)',
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('keyword'),
          IShortActionCarrier('white'),
          IExpandedMonarchLanguageAction(
            bracket: '@open',
            next: '@map.\$S2',
            token: '@brackets',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@identifier'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==proto3': <String, Object?>{
                'next': '@field.\$S2',
                'token': '@rematch',
              },
              '(?:repeated|optional)': <String, Object?>{
                'next': '@field.\$S2',
                'token': 'keyword',
              },
              'enum': <String, Object?>{
                'next': '@enumDecl.\$S2',
                'token': 'keyword',
              },
              'extensions': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==proto2': <String, Object?>{
                    'next': '@reserved.\$S2',
                    'token': 'keyword',
                  },
                },
              },
              'message': <String, Object?>{
                'next': '@messageDecl.\$S2',
                'token': 'keyword',
              },
              'oneof': <String, Object?>{
                'next': '@oneofDecl.\$S2',
                'token': 'keyword',
              },
              'option': <String, Object?>{
                'next': '@option.\$S2',
                'token': 'keyword',
              },
              'required': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==proto2': <String, Object?>{
                    'next': '@field.\$S2',
                    'token': 'keyword',
                  },
                },
              },
              'reserved': <String, Object?>{
                'next': '@reserved.\$S2',
                'token': 'keyword',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\['),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@options.\$S2',
          token: '@brackets',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('}'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          next: '@pop',
          token: '@brackets',
        ),
      ),
      ],
    'messageDecl': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('@identifier'),
        IShortActionCarrier('type.identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('{'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          switchTo: '@messageBody.\$S2',
          token: '@brackets',
        ),
      ),
      ],
    'methodOptions': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IExpandedMonarchLanguageRule(
        include: '@constant',
      ),
        IShortMonarchLanguageRule1(
        RegExp(';'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        'option',
        IShortActionCarrier('keyword'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@optionName'),
        IShortActionCarrier('annotation'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[()]'),
        IShortActionCarrier('annotation.brackets'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('operator'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('}'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          next: '@pop',
          token: '@brackets',
        ),
      ),
      ],
    'oneofBody': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IExpandedMonarchLanguageRule(
        include: '@constant',
      ),
        IShortMonarchLanguageRule1(
        RegExp(';'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@identifier)(\\s*)(=)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('identifier'),
          IShortActionCarrier('white'),
          IShortActionCarrier('delimiter'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@fullIdentifier|\\.'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@builtinTypes': 'keyword',
              '@default': 'type.identifier',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\['),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@options.\$S2',
          token: '@brackets',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('}'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          next: '@pop',
          token: '@brackets',
        ),
      ),
      ],
    'oneofDecl': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('@identifier'),
        IShortActionCarrier('identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('{'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          switchTo: '@oneofBody.\$S2',
          token: '@brackets',
        ),
      ),
      ],
    'option': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('@optionName'),
        IShortActionCarrier('annotation'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[()]'),
        IShortActionCarrier('annotation.brackets'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('='),
        IShortActionCarrier('operator'),
        '@pop',
      ),
      ],
    'options': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IExpandedMonarchLanguageRule(
        include: '@constant',
      ),
        IShortMonarchLanguageRule1(
        RegExp(';'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@optionName'),
        IShortActionCarrier('annotation'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[()]'),
        IShortActionCarrier('annotation.brackets'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('operator'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\]'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          next: '@pop',
          token: '@brackets',
        ),
      ),
      ],
    'prototext': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IExpandedMonarchLanguageRule(
        include: '@constant',
      ),
        IShortMonarchLanguageRule1(
        RegExp('@identifier'),
        IShortActionCarrier('identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[:;]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('}'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          next: '@pop',
          token: '@brackets',
        ),
      ),
      ],
    'request': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('@messageType'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'type.identifier',
              'stream': <String, Object?>{
                'next': '@type.\$S2',
                'token': 'keyword',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\)'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          switchTo: '@returns.\$S2',
          token: '@brackets',
        ),
      ),
      ],
    'reserved': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp(','),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule2(
        RegExp(';'),
        IShortActionCarrier('delimiter'),
        '@pop',
      ),
        IExpandedMonarchLanguageRule(
        include: '@constant',
      ),
        IShortMonarchLanguageRule1(
        RegExp('to\\b|max\\b'),
        IShortActionCarrier('keyword'),
      ),
      ],
    'response': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('@messageType'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'type.identifier',
              'stream': <String, Object?>{
                'next': '@type.\$S2',
                'token': 'keyword',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\)'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          switchTo: '@rpc.\$S2',
          token: '@brackets',
        ),
      ),
      ],
    'returns': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('returns\\b'),
        IShortActionCarrier('keyword'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\('),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          switchTo: '@response.\$S2',
          token: '@brackets',
        ),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('syntax'),
        IShortActionCarrier('keyword'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('operators'),
      ),
        IShortMonarchLanguageRule1(
        RegExp(';'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(")(proto3)(")'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('string.quote'),
          IShortActionCarrier('string'),
          IExpandedMonarchLanguageAction(
            switchTo: '@topLevel.proto3',
            token: 'string.quote',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(")(proto2)(")'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('string.quote'),
          IShortActionCarrier('string'),
          IExpandedMonarchLanguageAction(
            switchTo: '@topLevel.proto2',
            token: 'string.quote',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.*?'),
        IExpandedMonarchLanguageAction(
          switchTo: '@topLevel.proto2',
          token: '',
        ),
      ),
      ],
    'rpc': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('@identifier'),
        IShortActionCarrier('identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\('),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          switchTo: '@request.\$S2',
          token: '@brackets',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('{'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@methodOptions.\$S2',
          token: '@brackets',
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp(';'),
        IShortActionCarrier('delimiter'),
        '@pop',
      ),
      ],
    'serviceBody': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IExpandedMonarchLanguageRule(
        include: '@constant',
      ),
        IShortMonarchLanguageRule1(
        RegExp(';'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('option\\b'),
        IShortActionCarrier('keyword'),
        '@option.\$S2',
      ),
        IShortMonarchLanguageRule2(
        RegExp('rpc\\b'),
        IShortActionCarrier('keyword'),
        '@rpc.\$S2',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\['),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          next: '@options.\$S2',
          token: '@brackets',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('}'),
        IExpandedMonarchLanguageAction(
          bracket: '@close',
          next: '@pop',
          token: '@brackets',
        ),
      ),
      ],
    'serviceDecl': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule1(
        RegExp('@identifier'),
        IShortActionCarrier('identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('{'),
        IExpandedMonarchLanguageAction(
          bracket: '@open',
          switchTo: '@serviceBody.\$S2',
          token: '@brackets',
        ),
      ),
      ],
    'string': <IMonarchLanguageRule>[
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
    'stringSingle': <IMonarchLanguageRule>[
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
    'topLevel': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IExpandedMonarchLanguageRule(
        include: '@constant',
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('operators'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[;.]'),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@fullIdentifier'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'identifier',
              '@keywords': 'keyword',
              'enum': <String, Object?>{
                'next': '@enumDecl.\$S2',
                'token': 'keyword',
              },
              'extend': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==proto2': <String, Object?>{
                    'next': '@extendDecl.\$S2',
                    'token': 'keyword',
                  },
                },
              },
              'message': <String, Object?>{
                'next': '@messageDecl.\$S2',
                'token': 'keyword',
              },
              'option': <String, Object?>{
                'next': '@option.\$S2',
                'token': 'keyword',
              },
              'service': <String, Object?>{
                'next': '@serviceDecl.\$S2',
                'token': 'keyword',
              },
            },
        ),
      ),
      ],
    'type': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IShortMonarchLanguageRule2(
        RegExp('@identifier'),
        IShortActionCarrier('type.identifier'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('delimiter'),
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[ \\t\\r\\n]+'),
        IShortActionCarrier('white'),
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
      ],
  },
  defaultToken: '',
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
    IMonarchLanguageBracket('[', ']', 'delimiter.square'),
    IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
    IMonarchLanguageBracket('<', '>', 'delimiter.angle'),
  ],
  tokenPostfix: '.proto',
  extra: <String, Object?>{
      'boolLit': RegExp('true\\b|false\\b'),
      'builtinTypes': <Object?>[
        'double',
        'float',
        'int32',
        'int64',
        'uint32',
        'uint64',
        'sint32',
        'sint64',
        'fixed32',
        'fixed64',
        'sfixed32',
        'sfixed64',
        'bool',
        'string',
        'bytes',
      ],
      'decimalLit': RegExp('[1-9][0-9]*'),
      'enumName': RegExp('@identifier'),
      'enumType': RegExp('\\.?\\s*(?:@identifier\\s*\\.\\s*)*@enumName'),
      'escapes': '\\\\(u{[0-9A-Fa-f]+}|n|r|t|\\\\|\'|\\\${)',
      'exponent': RegExp('[eE]\\s*[+-]?\\s*[0-9]+'),
      'floatLit': RegExp('[0-9]+\\s*\\.\\s*[0-9]*(?:@exponent)?|[0-9]+@exponent|\\.[0-9]+(?:@exponent)?'),
      'fullIdentifier': RegExp('@identifier(?:\\s*\\.\\s*@identifier)*'),
      'hexLit': RegExp('0[xX][0-9a-fA-F]+'),
      'identifier': RegExp('[a-zA-Z]\\w*'),
      'keyType': RegExp('int32|int64|uint32|uint64|sint32|sint64|fixed32|fixed64|sfixed32|sfixed64|bool|string'),
      'keywords': <Object?>[
        'syntax',
        'import',
        'weak',
        'public',
        'package',
        'option',
        'repeated',
        'oneof',
        'map',
        'reserved',
        'to',
        'max',
        'enum',
        'message',
        'service',
        'rpc',
        'stream',
        'returns',
        'package',
        'optional',
        'true',
        'false',
      ],
      'messageName': RegExp('@identifier'),
      'messageType': RegExp('\\.?\\s*(?:@identifier\\s*\\.\\s*)*@messageName'),
      'namedLiterals': <Object?>[
        'true',
        'false',
      ],
      'octalLit': RegExp('0[0-7]*'),
      'operators': <Object?>[
        '=',
        '+',
        '-',
      ],
      'optionName': RegExp('(?:@identifier|\\(\\s*@fullIdentifier\\s*\\))(?:\\s*\\.\\s*@identifier)*'),
      'symbols': RegExp('[=><!~?:&|+\\-*/^%]+'),
      'type': RegExp('double|float|int32|int64|uint32|uint64|sint32|sint64|fixed32|fixed64|sfixed32|sfixed64|bool|string|bytes|@messageType|@enumType'),
    },
);
