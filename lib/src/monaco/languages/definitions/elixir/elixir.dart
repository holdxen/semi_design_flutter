// 1:1 translation of monaco-editor/src/languages/definitions/elixir/elixir.ts
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
        'comment',
      ],
      'open': '\'',
    },
    <String, Object?>{
      'close': '"',
      'notIn': <Object?>[
        'comment',
      ],
      'open': '"',
    },
    <String, Object?>{
      'close': '"""',
      'open': '"""',
    },
    <String, Object?>{
      'close': '`',
      'notIn': <Object?>[
        'string',
        'comment',
      ],
      'open': '`',
    },
    <String, Object?>{
      'close': ')',
      'open': '(',
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
      'close': '>>',
      'open': '<<',
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
  'indentationRules': <String, Object?>{
    'decreaseIndentPattern': RegExp('^\\s*((\\}|\\])\\s*\$|(after|else|catch|rescue|end)\\b)'),
    'increaseIndentPattern': RegExp('^\\s*(after|else|catch|rescue|fn|[^#]*(do|<\\-|\\->|\\{|\\[|\\=))\\s*\$'),
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
      'close': '\'',
      'open': '\'',
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
    'atoms': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(:)(@atomName)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('constant.punctuation'),
          IShortActionCarrier('constant'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp(':"'),
        IExpandedMonarchLanguageAction(
          next: '@doubleQuotedStringAtom',
          token: 'constant.delimiter',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp(':\''),
        IExpandedMonarchLanguageAction(
          next: '@singleQuotedStringAtom',
          token: 'constant.delimiter',
        ),
      ),
      ],
    'attributes': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\@(module|type)?doc (~[sS])?"""'),
        IExpandedMonarchLanguageAction(
          next: '@doubleQuotedHeredocDocstring',
          token: 'comment.block.documentation',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\@(module|type)?doc (~[sS])?\'\'\''),
        IExpandedMonarchLanguageAction(
          next: '@singleQuotedHeredocDocstring',
          token: 'comment.block.documentation',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\@(module|type)?doc (~[sS])?"'),
        IExpandedMonarchLanguageAction(
          next: '@doubleQuotedStringDocstring',
          token: 'comment.block.documentation',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\@(module|type)?doc (~[sS])?\''),
        IExpandedMonarchLanguageAction(
          next: '@singleQuotedStringDocstring',
          token: 'comment.block.documentation',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\@(module|type)?doc false'),
        IShortActionCarrier('comment.block.documentation'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\@(@variableName)'),
        IShortActionCarrier('variable'),
      ),
      ],
    'comments': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(#)(.*)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('comment.punctuation'),
          IShortActionCarrier('comment'),
        ]),
      ),
      ],
    'docstringContent': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('comment.block.documentation'),
      ),
      ],
    'doubleQuotedHeredoc': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('"""'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.delimiter',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@stringContentInterpol',
      ),
      ],
    'doubleQuotedHeredocDocstring': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('"""'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'comment.block.documentation',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@docstringContent',
      ),
      ],
    'doubleQuotedString': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.delimiter',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@stringContentInterpol',
      ),
      ],
    'doubleQuotedStringAtom': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'constant.delimiter',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@stringConstantContentInterpol',
      ),
      ],
    'doubleQuotedStringDocstring': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'comment.block.documentation',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@docstringContent',
      ),
      ],
    'doubleQuotedStringKeyword': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('":'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'constant.delimiter',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@stringConstantContentInterpol',
      ),
      ],
    'escapeChar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('@escape'),
        IShortActionCarrier('constant.character.escape'),
      ),
      ],
    'identifiers': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\b(defp?|defnp?|defmacrop?|defguardp?|defdelegate)(\\s+)(@variableName)(?!\\s+@operator)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('keyword.declaration'),
          IShortActionCarrier('white'),
          IExpandedMonarchLanguageAction(
            cases: <String, Object?>{
                '@default': 'function',
                'unquote': 'keyword',
              },
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@variableName)(?=\\s*\\.?\\s*\\()'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@declarationKeywords': 'keyword.declaration',
              '@default': 'function.call',
              '@namespaceKeywords': 'keyword',
              '@otherKeywords': 'keyword',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@moduleName)(\\s*)(\\.)(\\s*)(@variableName)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('type.identifier'),
          IShortActionCarrier('white'),
          IShortActionCarrier('operator'),
          IShortActionCarrier('white'),
          IShortActionCarrier('function.call'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(:)(@atomName)(\\s*)(\\.)(\\s*)(@variableName)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('constant.punctuation'),
          IShortActionCarrier('constant'),
          IShortActionCarrier('white'),
          IShortActionCarrier('operator'),
          IShortActionCarrier('white'),
          IShortActionCarrier('function.call'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\|>)(\\s*)(@variableName)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('operator'),
          IShortActionCarrier('white'),
          IExpandedMonarchLanguageAction(
            cases: <String, Object?>{
                '@default': 'function.call',
                '@otherKeywords': 'keyword',
              },
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(&)(\\s*)(@variableName)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('operator'),
          IShortActionCarrier('white'),
          IShortActionCarrier('function.call'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@variableName'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@constants': 'constant.language',
              '@declarationKeywords': 'keyword.declaration',
              '@default': 'identifier',
              '@nameBuiltin': 'variable.language',
              '@namespaceKeywords': 'keyword',
              '@operatorKeywords': 'keyword.operator',
              '@otherKeywords': 'keyword',
              '_.*': 'comment.unused',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@moduleName'),
        IShortActionCarrier('type.identifier'),
      ),
      ],
    'interpolation': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('#{'),
        IExpandedMonarchLanguageAction(
          next: '@interpolationContinue',
          token: 'delimiter.bracket.embed',
        ),
      ),
      ],
    'interpolationContinue': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('}'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'delimiter.bracket.embed',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@root',
      ),
      ],
    'keywordsShorthand': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@atomName)(:)(\\s+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('constant'),
          IShortActionCarrier('constant.punctuation'),
          IShortActionCarrier('white'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"(?=(?:[^"\\\\]|\\\\"?)*":|(?:[^"\\\\#]|\\\\"?|#(?!\\{))*#\\{.*\\}(?:[^"\\\\}]|\\\\"?)*":)'),
        IExpandedMonarchLanguageAction(
          next: '@doubleQuotedStringKeyword',
          token: 'constant.delimiter',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'(?=(?:[^\'\\\\]|\\\\\'?)*\':|(?:[^\'\\\\#]|\\\\\'?|#(?!\\{))*#\\{.*\\}(?:[^\'\\\\}]|\\\\\'?)*\':)'),
        IExpandedMonarchLanguageAction(
          next: '@singleQuotedStringKeyword',
          token: 'constant.delimiter',
        ),
      ),
      ],
    'numbers': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('0b@binary'),
        IShortActionCarrier('number.binary'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0o@octal'),
        IShortActionCarrier('number.octal'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0x@hex'),
        IShortActionCarrier('number.hex'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@decimal\\.@decimal([eE]-?@decimal)?'),
        IShortActionCarrier('number.float'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@decimal'),
        IShortActionCarrier('number'),
      ),
      ],
    'regexpContent': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(\\s)(#)(\\s.*)\$'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('white'),
          IShortActionCarrier('comment.punctuation'),
          IShortActionCarrier('comment'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('regexp'),
      ),
      ],
    'regexpContentInterpol': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@interpolation',
      ),
        IExpandedMonarchLanguageRule(
        include: '@escapeChar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@regexpContent',
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@whitespace',
      ),
        IExpandedMonarchLanguageRule(
        include: '@comments',
      ),
        IExpandedMonarchLanguageRule(
        include: '@keywordsShorthand',
      ),
        IExpandedMonarchLanguageRule(
        include: '@numbers',
      ),
        IExpandedMonarchLanguageRule(
        include: '@identifiers',
      ),
        IExpandedMonarchLanguageRule(
        include: '@strings',
      ),
        IExpandedMonarchLanguageRule(
        include: '@atoms',
      ),
        IExpandedMonarchLanguageRule(
        include: '@sigils',
      ),
        IExpandedMonarchLanguageRule(
        include: '@attributes',
      ),
        IExpandedMonarchLanguageRule(
        include: '@symbols',
      ),
      ],
    'sigil': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('~([a-z]|[A-Z]+)\\{'),
        IExpandedMonarchLanguageAction(
          switchTo: '@sigilStart.\$S2.\$1.{.}',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('~([a-z]|[A-Z]+)\\['),
        IExpandedMonarchLanguageAction(
          switchTo: '@sigilStart.\$S2.\$1.[.]',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('~([a-z]|[A-Z]+)\\('),
        IExpandedMonarchLanguageAction(
          switchTo: '@sigilStart.\$S2.\$1.(.)',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('~([a-z]|[A-Z]+)\\<'),
        IExpandedMonarchLanguageAction(
          switchTo: '@sigilStart.\$S2.\$1.<.>',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('~([a-z]|[A-Z]+)(@sigilSymmetricDelimiter)'),
        IExpandedMonarchLanguageAction(
          switchTo: '@sigilStart.\$S2.\$1.\$2.\$2',
          token: '@rematch',
        ),
      ),
      ],
    'sigilContent': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('sigil'),
      ),
      ],
    'sigilContentInterpol': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@interpolation',
      ),
        IExpandedMonarchLanguageRule(
        include: '@escapeChar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@sigilContent',
      ),
      ],
    'sigilContinue.interpol': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@sigilEndDelimiter)@sigilModifiers'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==\$S5': <String, Object?>{
                'next': '@pop',
                'token': 'sigil.delimiter',
              },
              '@default': 'sigil',
            },
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@sigilContentInterpol',
      ),
      ],
    'sigilContinue.interpol.r': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@sigilEndDelimiter)@sigilModifiers'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==\$S5': <String, Object?>{
                'next': '@pop',
                'token': 'regexp.delimiter',
              },
              '@default': 'regexp',
            },
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@regexpContentInterpol',
      ),
      ],
    'sigilContinue.interpol.s': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@sigilEndDelimiter)@sigilModifiers'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==\$S5': <String, Object?>{
                'next': '@pop',
                'token': 'string.delimiter',
              },
              '@default': 'string',
            },
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@stringContentInterpol',
      ),
      ],
    'sigilContinue.noInterpol': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(^|[^\\\\])\\\\@sigilEndDelimiter'),
        IShortActionCarrier('sigil'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@sigilEndDelimiter)@sigilModifiers'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==\$S5': <String, Object?>{
                'next': '@pop',
                'token': 'sigil.delimiter',
              },
              '@default': 'sigil',
            },
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@sigilContent',
      ),
      ],
    'sigilContinue.noInterpol.R': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(^|[^\\\\])\\\\@sigilEndDelimiter'),
        IShortActionCarrier('regexp'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@sigilEndDelimiter)@sigilModifiers'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==\$S5': <String, Object?>{
                'next': '@pop',
                'token': 'regexp.delimiter',
              },
              '@default': 'regexp',
            },
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@regexpContent',
      ),
      ],
    'sigilContinue.noInterpol.S': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(^|[^\\\\])\\\\@sigilEndDelimiter'),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@sigilEndDelimiter)@sigilModifiers'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==\$S5': <String, Object?>{
                'next': '@pop',
                'token': 'string.delimiter',
              },
              '@default': 'string',
            },
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@stringContent',
      ),
      ],
    'sigilStart.interpol': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('~([a-z]|[A-Z]+)@sigilStartDelimiter'),
        IExpandedMonarchLanguageAction(
          switchTo: '@sigilContinue.\$S2.\$S3.\$S4.\$S5',
          token: 'sigil.delimiter',
        ),
      ),
      ],
    'sigilStart.interpol.r': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('~r@sigilStartDelimiter'),
        IExpandedMonarchLanguageAction(
          switchTo: '@sigilContinue.\$S2.\$S3.\$S4.\$S5',
          token: 'regexp.delimiter',
        ),
      ),
      ],
    'sigilStart.interpol.s': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('~s@sigilStartDelimiter'),
        IExpandedMonarchLanguageAction(
          switchTo: '@sigilContinue.\$S2.\$S3.\$S4.\$S5',
          token: 'string.delimiter',
        ),
      ),
      ],
    'sigilStart.noInterpol': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('~([a-z]|[A-Z]+)@sigilStartDelimiter'),
        IExpandedMonarchLanguageAction(
          switchTo: '@sigilContinue.\$S2.\$S3.\$S4.\$S5',
          token: 'sigil.delimiter',
        ),
      ),
      ],
    'sigilStart.noInterpol.R': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('~R@sigilStartDelimiter'),
        IExpandedMonarchLanguageAction(
          switchTo: '@sigilContinue.\$S2.\$S3.\$S4.\$S5',
          token: 'regexp.delimiter',
        ),
      ),
      ],
    'sigilStart.noInterpol.S': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('~S@sigilStartDelimiter'),
        IExpandedMonarchLanguageAction(
          switchTo: '@sigilContinue.\$S2.\$S3.\$S4.\$S5',
          token: 'string.delimiter',
        ),
      ),
      ],
    'sigils': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('~[a-z]@sigilStartDelimiter'),
        IExpandedMonarchLanguageAction(
          next: '@sigil.interpol',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('~([A-Z]+)@sigilStartDelimiter'),
        IExpandedMonarchLanguageAction(
          next: '@sigil.noInterpol',
          token: '@rematch',
        ),
      ),
      ],
    'singleQuotedHeredoc': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\'\'\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.delimiter',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@stringContentInterpol',
      ),
      ],
    'singleQuotedHeredocDocstring': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\'\'\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'comment.block.documentation',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@docstringContent',
      ),
      ],
    'singleQuotedString': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.delimiter',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@stringContentInterpol',
      ),
      ],
    'singleQuotedStringAtom': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'constant.delimiter',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@stringConstantContentInterpol',
      ),
      ],
    'singleQuotedStringDocstring': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'comment.block.documentation',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@docstringContent',
      ),
      ],
    'singleQuotedStringKeyword': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\':'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'constant.delimiter',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@stringConstantContentInterpol',
      ),
      ],
    'stringConstantContent': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('constant'),
      ),
      ],
    'stringConstantContentInterpol': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@interpolation',
      ),
        IExpandedMonarchLanguageRule(
        include: '@escapeChar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@stringConstantContent',
      ),
      ],
    'stringContent': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('string'),
      ),
      ],
    'stringContentInterpol': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@interpolation',
      ),
        IExpandedMonarchLanguageRule(
        include: '@escapeChar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@stringContent',
      ),
      ],
    'strings': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('"""'),
        IExpandedMonarchLanguageAction(
          next: '@doubleQuotedHeredoc',
          token: 'string.delimiter',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'\'\''),
        IExpandedMonarchLanguageAction(
          next: '@singleQuotedHeredoc',
          token: 'string.delimiter',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@doubleQuotedString',
          token: 'string.delimiter',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@singleQuotedString',
          token: 'string.delimiter',
        ),
      ),
      ],
    'symbols': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\?(\\\\.|[^\\\\\\s])'),
        IShortActionCarrier('number.constant'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('&\\d+'),
        IShortActionCarrier('operator'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<<<|>>>'),
        IShortActionCarrier('operator'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[()\\[\\]\\{\\}]|<<|>>'),
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\.\\.\\.'),
        IShortActionCarrier('identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('=>'),
        IShortActionCarrier('punctuation'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@operator'),
        IShortActionCarrier('operator'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[:;,.%]'),
        IShortActionCarrier('punctuation'),
      ),
      ],
    'whitespace': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\s+'),
        IShortActionCarrier('white'),
      ),
      ],
  },
  defaultToken: 'source',
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket('[', ']', 'delimiter.square'),
    IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
    IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
    IMonarchLanguageBracket('<<', '>>', 'delimiter.angle.special'),
  ],
  tokenPostfix: '.elixir',
  extra: <String, Object?>{
      'aliasPart': RegExp('[A-Z][a-zA-Z0-9_]*'),
      'atomName': RegExp('[a-zA-Z_][a-zA-Z0-9_@]*[?!]?|@specialAtomName|@operator'),
      'binary': RegExp('[01](_?[01])*'),
      'constants': <Object?>[
        'true',
        'false',
        'nil',
      ],
      'decimal': RegExp('\\d(?:_?\\d)*'),
      'declarationKeywords': <Object?>[
        'def',
        'defp',
        'defn',
        'defnp',
        'defguard',
        'defguardp',
        'defmacro',
        'defmacrop',
        'defdelegate',
        'defcallback',
        'defmacrocallback',
        'defmodule',
        'defprotocol',
        'defexception',
        'defimpl',
        'defstruct',
      ],
      'escape': RegExp('\\\\u[0-9a-fA-F]{4}|\\\\x[0-9a-fA-F]{2}|\\\\.'),
      'hex': RegExp('[0-9a-fA-F](_?[0-9a-fA-F])*'),
      'moduleName': RegExp('@aliasPart(?:\\.@aliasPart)*'),
      'nameBuiltin': <Object?>[
        '__MODULE__',
        '__DIR__',
        '__ENV__',
        '__CALLER__',
        '__STACKTRACE__',
      ],
      'namespaceKeywords': <Object?>[
        'alias',
        'import',
        'require',
        'use',
      ],
      'octal': RegExp('[0-7](_?[0-7])*'),
      'operator': RegExp('-[->]?|!={0,2}|\\*{1,2}|\\/|\\\\\\\\|&{1,3}|\\.\\.?|\\^(?:\\^\\^)?|\\+\\+?|<(?:-|<<|=|>|\\|>|~>?)?|=~|={1,3}|>(?:=|>>)?|\\|~>|\\|>|\\|{1,3}|~>>?|~~~|::'),
      'operatorKeywords': <Object?>[
        'and',
        'in',
        'not',
        'or',
        'when',
      ],
      'otherKeywords': <Object?>[
        'after',
        'case',
        'catch',
        'cond',
        'do',
        'else',
        'end',
        'fn',
        'for',
        'if',
        'quote',
        'raise',
        'receive',
        'rescue',
        'super',
        'throw',
        'try',
        'unless',
        'unquote_splicing',
        'unquote',
        'with',
      ],
      'sigilEndDelimiter': RegExp('@sigilSymmetricDelimiter|>|\\}|\\]|\\)'),
      'sigilModifiers': RegExp('[a-zA-Z0-9]*'),
      'sigilStartDelimiter': RegExp('@sigilSymmetricDelimiter|<|\\{|\\[|\\('),
      'sigilSymmetricDelimiter': RegExp('"""|\'\'\'|"|\'|\\/|\\|'),
      'specialAtomName': RegExp('\\.\\.\\.|<<>>|%\\{\\}|%|\\{\\}'),
      'variableName': RegExp('[a-z_][a-zA-Z0-9_]*[?!]?'),
    },
);
