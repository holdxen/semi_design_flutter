// 1:1 translation of monaco-editor/src/languages/definitions/freemarker2/freemarker2.ts
// FreeMarker2 exports 6 variants, each `{conf, language}` built by factory
// functions (createLangConfiguration/createMonarchLanguage[Auto]). The values
// below are evaluated from the real TS source via the TypeScript compiler.
import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchTypes.dart';

/// 1:1: `export const TagAngleInterpolationDollar = { conf, language }`
final class TagAngleInterpolationDollarDef {
  final Map<String, Object?> conf;
  final IMonarchLanguage language;
  TagAngleInterpolationDollarDef(this.conf, this.language);
}

final TagAngleInterpolationDollarDef TagAngleInterpolationDollar = TagAngleInterpolationDollarDef(
  <String, Object?>{
      'autoCloseBefore': '\n\r\t }]),.:;=',
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
          ],
          'open': '\'',
        },
      ],
      'brackets': <Object?>[
        <Object?>[
          '<',
          '>',
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
          '{',
          '}',
        ],
      ],
      'comments': <String, Object?>{
        'blockComment': <Object?>[
          '<--',
          '-->',
        ],
      },
      'folding': <String, Object?>{
        'markers': <String, Object?>{
          'end': RegExp('<\\/#(?:attempt|autoesc|autoEsc|compress|comment|escape|noescape|function|if|list|items|sep|macro|noparse|noParse|noautoesc|noAutoEsc|outputformat|switch|visit|recurse)[\\r\\n\\t ]*>'),
          'start': RegExp('<#(?:attempt|autoesc|autoEsc|compress|comment|escape|noescape|function|if|list|items|sep|macro|noparse|noParse|noautoesc|noAutoEsc|outputformat|switch|visit|recurse)([^/>]*(?!\\/)>)[^<]*\$'),
        },
      },
      'onEnterRules': <Object?>[
        <String, Object?>{
          'action': <String, Object?>{
            'indentAction': 2,
          },
          'afterText': RegExp('^<\\/#([a-zA-Z_]+)[\\r\\n\\t ]*>\$'),
          'beforeText': RegExp('<#(?!(?:assign|flush|ftl|return|global|import|include|break|continue|local|nested|nt|setting|stop|t|lt|rt|fallback))([a-zA-Z_]+)([^/>]*(?!\\/)>)[^<]*\$'),
        },
        <String, Object?>{
          'action': <String, Object?>{
            'indentAction': 1,
          },
          'beforeText': RegExp('<#(?!(?:assign|flush|ftl|return|global|import|include|break|continue|local|nested|nt|setting|stop|t|lt|rt|fallback))([a-zA-Z_]+)([^/>]*(?!\\/)>)[^<]*\$'),
        },
      ],
      'surroundingPairs': <Object?>[
        <String, Object?>{
          'close': '"',
          'open': '"',
        },
        <String, Object?>{
          'close': '\'',
          'open': '\'',
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
        <String, Object?>{
          'close': '>',
          'open': '<',
        },
      ],
    },
  IMonarchLanguage(tokenizer: <String, List<IMonarchLanguageRule>>{
    'blank_and_expression_comment_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@blank)+'),
        IExpandedMonarchLanguageAction(
          token: '',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[<\\[][#!]--'),
        IExpandedMonarchLanguageAction(
          next: '@expressionComment_angle_dollar',
          token: 'comment',
        ),
      ),
      ],
    'default_angle_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@directive_token_angle_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@interpolation_and_text_token_angle_dollar',
      ),
      ],
    'directive_end_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@popall',
          token: '@brackets.directive',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\/)(@close_angle_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@popall',
            token: '@brackets.directive',
          ),
        ]),
      ),
      ],
    'directive_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_angle_dollar)(@directiveStartCloseTag1)(?:@closeTag1_angle_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            cases: <String, Object?>{
                '@default': <String, Object?>{
                  'token': 'tag',
                },
                '@noParseTags': <String, Object?>{
                  'next': '@noParse_angle_dollar.\$3',
                  'token': 'tag',
                },
              },
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_angle_dollar)(@directiveStartCloseTag2)(?:@closeTag2_angle_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_angle_dollar)(@directiveStartBlank)(@blank)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_angle_dollar.directive',
            token: '',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@endTag_angle_dollar)(@directiveEndCloseTag1)(?:@closeTag1_angle_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_angle_dollar)(@)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@unifiedCall_angle_dollar',
            token: 'delimiter.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_angle_dollar)(\\/@)((?:(?:@id)(?:\\.(?:@id))*)?)(?:@closeTag1_angle_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_angle_dollar)#--'),
        IExpandedMonarchLanguageAction(
          next: '@terseComment_angle_dollar',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startOrEndTag_angle_dollar)([a-zA-Z_]+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_angle_dollar.directive',
            token: 'tag.invalid',
          ),
        ]),
      ),
      ],
    'doubleString_angle_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_double_token_angle_dollar',
      ),
      ],
    'expressionComment_angle_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@expression_comment_token_angle_dollar',
      ),
      ],
    'expression_comment_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('--[>\\]]'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\->\\]]+|[>\\]\\-]'),
        IExpandedMonarchLanguageAction(
          token: 'comment',
        ),
      ),
      ],
    'expression_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(r?)([\'"])'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '"': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'next': '@doubleString_angle_dollar',
                  'token': 'string',
                },
              ],
              '\'': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'next': '@singleString_angle_dollar',
                  'token': 'string',
                },
              ],
              'r"': <Object?>[
                <String, Object?>{
                  'token': 'keyword',
                },
                <String, Object?>{
                  'next': '@rawDoubleString_angle_dollar',
                  'token': 'string.raw',
                },
              ],
              'r\'': <Object?>[
                <String, Object?>{
                  'token': 'keyword',
                },
                <String, Object?>{
                  'next': '@rawSingleString_angle_dollar',
                  'token': 'string.raw',
                },
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@integer)(?:\\.(?:@integer))?'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '(?:@integer)': <String, Object?>{
                'token': 'number',
              },
              '@default': <String, Object?>{
                'token': 'number.float',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\.)(@blank*)(@specialHashKeys)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter',
          ),
          IExpandedMonarchLanguageAction(
            token: '',
          ),
          IExpandedMonarchLanguageAction(
            token: 'identifier',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@namedSymbols)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@arrows': <String, Object?>{
                'token': 'meta.arrow',
              },
              '@default': <String, Object?>{
                'token': 'operators',
              },
              '@delimiters': <String, Object?>{
                'token': 'delimiter',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@id'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': <String, Object?>{
                'token': 'identifier',
              },
              '@keywords': <String, Object?>{
                'token': 'keyword.\$0',
              },
              '@stringOperators': <String, Object?>{
                'token': 'operators',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\[\\]\\(\\)\\{\\}]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\\(': <String, Object?>{
                'next': '@inParen_angle_dollar.gt',
                'token': '@brackets',
              },
              '\\)': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_angle_dollar': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
              '\\[': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==gt': <String, Object?>{
                    'next': '@inParen_angle_dollar.gt',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'next': '@inParen_angle_dollar.plain',
                    'token': '@brackets',
                  },
                },
              },
              '\\]': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_angle_dollar': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
              '\\{': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==gt': <String, Object?>{
                    'next': '@inParen_angle_dollar.gt',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'next': '@inParen_angle_dollar.plain',
                    'token': '@brackets',
                  },
                },
              },
              '\\}': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_angle_dollar': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '\$S2==interpolation': <String, Object?>{
                    'next': '@popall',
                    'token': '@brackets.interpolation',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$\\{'),
        IExpandedMonarchLanguageAction(
          token: 'delimiter.invalid',
        ),
      ),
      ],
    'fmExpression_angle_dollar.directive': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_angle_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_angle_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_angle_dollar',
      ),
      ],
    'fmExpression_angle_dollar.interpolation': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_angle_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_angle_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@greater_operators_token_angle_dollar',
      ),
      ],
    'greater_operators_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>='),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
      ],
    'inParen_angle_dollar.gt': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_angle_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_angle_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@greater_operators_token_angle_dollar',
      ),
      ],
    'inParen_angle_dollar.plain': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_angle_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_angle_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_angle_dollar',
      ),
      ],
    'interpolation_and_text_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@iOpen1_angle_dollar)(@iOpen2_angle_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter.interpolation',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_angle_dollar.interpolation',
            token: '@brackets.interpolation',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\\$#<\\[\\{]|(?:@blank)+|[^\\\$<#\\[\\{\\n\\r\\t ]+'),
        IExpandedMonarchLanguageAction(
          token: 'source',
        ),
      ),
      ],
    'noParse_angle_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@no_parse_token_angle_dollar',
      ),
      ],
    'noSpaceExpression_angle_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@no_space_expression_end_token_angle_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_angle_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_angle_dollar',
      ),
      ],
    'no_parse_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@open_angle_dollar)(\\/#?)([a-zA-Z]+)((?:@blank)*)(@close_angle_dollar)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==\$3': <Object?>[
                <String, Object?>{
                  'token': '@brackets.directive',
                },
                <String, Object?>{
                  'token': 'delimiter.directive',
                },
                <String, Object?>{
                  'token': 'tag',
                },
                <String, Object?>{
                  'token': '',
                },
                <String, Object?>{
                  'next': '@popall',
                  'token': '@brackets.directive',
                },
              ],
              '\$S2==comment': <Object?>[
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
              ],
              '@default': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<\\[\\-]+|[<\\[\\-]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==comment': <String, Object?>{
                'token': 'comment',
              },
              '@default': <String, Object?>{
                'token': 'source',
              },
            },
        ),
      ),
      ],
    'no_space_expression_end_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@blank)+'),
        IExpandedMonarchLanguageAction(
          switchTo: '@fmExpression_angle_dollar.directive',
          token: '',
        ),
      ),
      ],
    'rawDoubleString_angle_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_double_raw_token_angle_dollar',
      ),
      ],
    'rawSingleString_angle_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_single_raw_token_angle_dollar',
      ),
      ],
    'singleString_angle_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_single_token_angle_dollar',
      ),
      ],
    'string_double_raw_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"]+'),
        IExpandedMonarchLanguageAction(
          token: 'string.raw',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.raw',
        ),
      ),
      ],
    'string_double_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"\\\\]'),
        IExpandedMonarchLanguageAction(
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapedChar'),
        IExpandedMonarchLanguageAction(
          token: 'string.escape',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
      ],
    'string_single_raw_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\']+'),
        IExpandedMonarchLanguageAction(
          token: 'string.raw',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.raw',
        ),
      ),
      ],
    'string_single_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\'\\\\]'),
        IExpandedMonarchLanguageAction(
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapedChar'),
        IExpandedMonarchLanguageAction(
          token: 'string.escape',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
      ],
    'terseComment_angle_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@terse_comment_token_angle_dollar',
      ),
      ],
    'terse_comment_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('--(?:@close_angle_dollar)'),
        IExpandedMonarchLanguageAction(
          next: '@popall',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<\\[\\-]+|[<\\[\\-]'),
        IExpandedMonarchLanguageAction(
          token: 'comment',
        ),
      ),
      ],
    'unifiedCall_angle_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@unified_call_token_angle_dollar',
      ),
      ],
    'unified_call_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@id)((?:@blank)+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_angle_dollar.directive',
            token: '',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@id)(\\/?)(@close_angle_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@popall',
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IExpandedMonarchLanguageAction(
          next: '@noSpaceExpression_angle_dollar',
          token: '@rematch',
        ),
      ),
      ],
  },
    ignoreCase: false,
    unicode: true,
    defaultToken: 'invalid',
    brackets: <IMonarchLanguageBracket>[
      IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
      IMonarchLanguageBracket('[', ']', 'delimiter.square'),
      IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
      IMonarchLanguageBracket('<', '>', 'delimiter.angle'),
    ],
    start: 'default_angle_dollar',
    tokenPostfix: '.freemarker2',
    includeLF: false,
    extra: <String, Object?>{
          'arrows': <Object?>[
            '->',
            '-&gt;',
          ],
          'asciiDigit': RegExp('[0-9]'),
          'blank': RegExp('[ \\t\\n\\r]'),
          'closeTag1_angle_dollar': RegExp('((?:@blank)*)(@close_angle_dollar)'),
          'closeTag2_angle_dollar': RegExp('((?:@blank)*\\/?)(@close_angle_dollar)'),
          'close_angle_dollar': RegExp('>'),
          'delimiters': <Object?>[
            ';',
            ':',
            ',',
            '.',
          ],
          'directiveEndCloseTag1': RegExp('if|list|items|sep|recover|attempt|for[eE]ach|local|global|assign|function|macro|output[fF]ormat|auto[eE]sc|no(?:autoe|AutoE)sc|compress|transform|switch|escape|no[eE]scape'),
          'directiveStartBlank': RegExp('if|else[iI]f|list|for[eE]ach|switch|case|assign|global|local|include|import|function|macro|transform|visit|stop|return|call|setting|output[fF]ormat|nested|recurse|escape|ftl|items'),
          'directiveStartCloseTag1': RegExp('attempt|recover|sep|auto[eE]sc|no(?:autoe|AutoE)sc|compress|default|no[eE]scape|comment|no[pP]arse'),
          'directiveStartCloseTag2': RegExp('else|break|continue|return|stop|flush|t|lt|rt|nt|nested|recurse|fallback|ftl'),
          'endTag_angle_dollar': RegExp('(@open_angle_dollar)(\\/#)'),
          'escapedChar': RegExp('\\\\(?:[ntrfbgla\\\\\'"\\{=]|(?:x[0-9A-Fa-f]{1,4}))'),
          'escapedIdChar': RegExp('\\\\[\\-\\.:#]'),
          'iClose_angle_dollar': RegExp('\\}'),
          'iOpen1_angle_dollar': RegExp('\\\$'),
          'iOpen2_angle_dollar': RegExp('\\{'),
          'id': RegExp('(?:@idStartChar)(?:(?:@idStartChar)|(?:@asciiDigit))*'),
          'idStartChar': RegExp('(?:@nonEscapedIdStartChar)|(?:@escapedIdChar)'),
          'integer': RegExp('[0-9]+'),
          'keywords': <Object?>[
            'false',
            'true',
            'in',
            'as',
            'using',
          ],
          'namedSymbols': RegExp('&lt;=|&gt;=|\\\\lte|\\\\lt|&lt;|\\\\gte|\\\\gt|&gt;|&amp;&amp;|\\\\and|-&gt;|->|==|!=|\\+=|-=|\\*=|\\/=|%=|\\+\\+|--|<=|&&|\\|\\||:|\\.\\.\\.|\\.\\.\\*|\\.\\.<|\\.\\.!|\\?\\?|=|<|\\+|-|\\*|\\/|%|\\||\\.\\.|\\?|!|&|\\.|,|;'),
          'noParseTags': <Object?>[
            'noparse',
            'noParse',
            'comment',
          ],
          'nonEscapedIdStartChar': RegExp('[\\\$@-Z_a-z\\u00AA\\u00B5\\u00BA\\u00C0-\\u00D6\\u00D8-\\u00F6\\u00F8-\\u1FFF\\u2071\\u207F\\u2090-\\u209C\\u2102\\u2107\\u210A-\\u2113\\u2115\\u2119-\\u211D\\u2124\\u2126\\u2128\\u212A-\\u212D\\u212F-\\u2139\\u213C-\\u213F\\u2145-\\u2149\\u214E\\u2183-\\u2184\\u2C00-\\u2C2E\\u2C30-\\u2C5E\\u2C60-\\u2CE4\\u2CEB-\\u2CEE\\u2CF2-\\u2CF3\\u2D00-\\u2D25\\u2D27\\u2D2D\\u2D30-\\u2D67\\u2D6F\\u2D80-\\u2D96\\u2DA0-\\u2DA6\\u2DA8-\\u2DAE\\u2DB0-\\u2DB6\\u2DB8-\\u2DBE\\u2DC0-\\u2DC6\\u2DC8-\\u2DCE\\u2DD0-\\u2DD6\\u2DD8-\\u2DDE\\u2E2F\\u3005-\\u3006\\u3031-\\u3035\\u303B-\\u303C\\u3040-\\u318F\\u31A0-\\u31BA\\u31F0-\\u31FF\\u3300-\\u337F\\u3400-\\u4DB5\\u4E00-\\uA48C\\uA4D0-\\uA4FD\\uA500-\\uA60C\\uA610-\\uA62B\\uA640-\\uA66E\\uA67F-\\uA697\\uA6A0-\\uA6E5\\uA717-\\uA71F\\uA722-\\uA788\\uA78B-\\uA78E\\uA790-\\uA793\\uA7A0-\\uA7AA\\uA7F8-\\uA801\\uA803-\\uA805\\uA807-\\uA80A\\uA80C-\\uA822\\uA840-\\uA873\\uA882-\\uA8B3\\uA8D0-\\uA8D9\\uA8F2-\\uA8F7\\uA8FB\\uA900-\\uA925\\uA930-\\uA946\\uA960-\\uA97C\\uA984-\\uA9B2\\uA9CF-\\uA9D9\\uAA00-\\uAA28\\uAA40-\\uAA42\\uAA44-\\uAA4B\\uAA50-\\uAA59\\uAA60-\\uAA76\\uAA7A\\uAA80-\\uAAAF\\uAAB1\\uAAB5-\\uAAB6\\uAAB9-\\uAABD\\uAAC0\\uAAC2\\uAADB-\\uAADD\\uAAE0-\\uAAEA\\uAAF2-\\uAAF4\\uAB01-\\uAB06\\uAB09-\\uAB0E\\uAB11-\\uAB16\\uAB20-\\uAB26\\uAB28-\\uAB2E\\uABC0-\\uABE2\\uABF0-\\uABF9\\uAC00-\\uD7A3\\uD7B0-\\uD7C6\\uD7CB-\\uD7FB\\uF900-\\uFB06\\uFB13-\\uFB17\\uFB1D\\uFB1F-\\uFB28\\uFB2A-\\uFB36\\uFB38-\\uFB3C\\uFB3E\\uFB40-\\uFB41\\uFB43-\\uFB44\\uFB46-\\uFBB1\\uFBD3-\\uFD3D\\uFD50-\\uFD8F\\uFD92-\\uFDC7\\uFDF0-\\uFDFB\\uFE70-\\uFE74\\uFE76-\\uFEFC\\uFF10-\\uFF19\\uFF21-\\uFF3A\\uFF41-\\uFF5A\\uFF66-\\uFFBE\\uFFC2-\\uFFC7\\uFFCA-\\uFFCF\\uFFD2-\\uFFD7\\uFFDA-\\uFFDC]'),
          'open_angle_dollar': RegExp('<'),
          'specialHashKeys': RegExp('\\*\\*|\\*|false|true|in|as|using'),
          'startOrEndTag_angle_dollar': RegExp('(@open_angle_dollar)(\\/?#)'),
          'startTag_angle_dollar': RegExp('(@open_angle_dollar)(#)'),
          'stringOperators': <Object?>[
            'lte',
            'lt',
            'gte',
            'gt',
          ],
        },
  ),
);

/// 1:1: `export const TagBracketInterpolationDollar = { conf, language }`
final class TagBracketInterpolationDollarDef {
  final Map<String, Object?> conf;
  final IMonarchLanguage language;
  TagBracketInterpolationDollarDef(this.conf, this.language);
}

final TagBracketInterpolationDollarDef TagBracketInterpolationDollar = TagBracketInterpolationDollarDef(
  <String, Object?>{
      'autoCloseBefore': '\n\r\t }]),.:;=',
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
          ],
          'open': '\'',
        },
      ],
      'brackets': <Object?>[
        <Object?>[
          '<',
          '>',
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
          '{',
          '}',
        ],
      ],
      'comments': <String, Object?>{
        'blockComment': <Object?>[
          '\\[--',
          '--\\]',
        ],
      },
      'folding': <String, Object?>{
        'markers': <String, Object?>{
          'end': RegExp('\\[\\/#(?:attempt|autoesc|autoEsc|compress|comment|escape|noescape|function|if|list|items|sep|macro|noparse|noParse|noautoesc|noAutoEsc|outputformat|switch|visit|recurse)[\\r\\n\\t ]*>'),
          'start': RegExp('\\[#(?:attempt|autoesc|autoEsc|compress|comment|escape|noescape|function|if|list|items|sep|macro|noparse|noParse|noautoesc|noAutoEsc|outputformat|switch|visit|recurse)([^/\\]]*(?!\\/)\\])[^\\[]*\$'),
        },
      },
      'onEnterRules': <Object?>[
        <String, Object?>{
          'action': <String, Object?>{
            'indentAction': 2,
          },
          'afterText': RegExp('^\\[\\/#([a-zA-Z_]+)[\\r\\n\\t ]*\\]\$'),
          'beforeText': RegExp('\\[#(?!(?:assign|flush|ftl|return|global|import|include|break|continue|local|nested|nt|setting|stop|t|lt|rt|fallback))([a-zA-Z_]+)([^/\\]]*(?!\\/)\\])[^\\[]*\$'),
        },
        <String, Object?>{
          'action': <String, Object?>{
            'indentAction': 1,
          },
          'beforeText': RegExp('\\[#(?!(?:assign|flush|ftl|return|global|import|include|break|continue|local|nested|nt|setting|stop|t|lt|rt|fallback))([a-zA-Z_]+)([^/\\]]*(?!\\/)\\])[^\\[]*\$'),
        },
      ],
      'surroundingPairs': <Object?>[
        <String, Object?>{
          'close': '"',
          'open': '"',
        },
        <String, Object?>{
          'close': '\'',
          'open': '\'',
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
        <String, Object?>{
          'close': '>',
          'open': '<',
        },
      ],
    },
  IMonarchLanguage(tokenizer: <String, List<IMonarchLanguageRule>>{
    'blank_and_expression_comment_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@blank)+'),
        IExpandedMonarchLanguageAction(
          token: '',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[<\\[][#!]--'),
        IExpandedMonarchLanguageAction(
          next: '@expressionComment_bracket_dollar',
          token: 'comment',
        ),
      ),
      ],
    'default_bracket_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@directive_token_bracket_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@interpolation_and_text_token_bracket_dollar',
      ),
      ],
    'directive_end_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\/)(@close_bracket_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@popall',
            token: '@brackets.directive',
          ),
        ]),
      ),
      ],
    'directive_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_bracket_dollar)(@directiveStartCloseTag1)(?:@closeTag1_bracket_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            cases: <String, Object?>{
                '@default': <String, Object?>{
                  'token': 'tag',
                },
                '@noParseTags': <String, Object?>{
                  'next': '@noParse_bracket_dollar.\$3',
                  'token': 'tag',
                },
              },
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_bracket_dollar)(@directiveStartCloseTag2)(?:@closeTag2_bracket_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_bracket_dollar)(@directiveStartBlank)(@blank)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_bracket_dollar.directive',
            token: '',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@endTag_bracket_dollar)(@directiveEndCloseTag1)(?:@closeTag1_bracket_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_bracket_dollar)(@)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@unifiedCall_bracket_dollar',
            token: 'delimiter.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_bracket_dollar)(\\/@)((?:(?:@id)(?:\\.(?:@id))*)?)(?:@closeTag1_bracket_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_bracket_dollar)#--'),
        IExpandedMonarchLanguageAction(
          next: '@terseComment_bracket_dollar',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startOrEndTag_bracket_dollar)([a-zA-Z_]+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_bracket_dollar.directive',
            token: 'tag.invalid',
          ),
        ]),
      ),
      ],
    'doubleString_bracket_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_double_token_bracket_dollar',
      ),
      ],
    'expressionComment_bracket_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@expression_comment_token_bracket_dollar',
      ),
      ],
    'expression_comment_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('--[>\\]]'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\->\\]]+|[>\\]\\-]'),
        IExpandedMonarchLanguageAction(
          token: 'comment',
        ),
      ),
      ],
    'expression_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(r?)([\'"])'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '"': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'next': '@doubleString_bracket_dollar',
                  'token': 'string',
                },
              ],
              '\'': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'next': '@singleString_bracket_dollar',
                  'token': 'string',
                },
              ],
              'r"': <Object?>[
                <String, Object?>{
                  'token': 'keyword',
                },
                <String, Object?>{
                  'next': '@rawDoubleString_bracket_dollar',
                  'token': 'string.raw',
                },
              ],
              'r\'': <Object?>[
                <String, Object?>{
                  'token': 'keyword',
                },
                <String, Object?>{
                  'next': '@rawSingleString_bracket_dollar',
                  'token': 'string.raw',
                },
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@integer)(?:\\.(?:@integer))?'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '(?:@integer)': <String, Object?>{
                'token': 'number',
              },
              '@default': <String, Object?>{
                'token': 'number.float',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\.)(@blank*)(@specialHashKeys)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter',
          ),
          IExpandedMonarchLanguageAction(
            token: '',
          ),
          IExpandedMonarchLanguageAction(
            token: 'identifier',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@namedSymbols)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@arrows': <String, Object?>{
                'token': 'meta.arrow',
              },
              '@default': <String, Object?>{
                'token': 'operators',
              },
              '@delimiters': <String, Object?>{
                'token': 'delimiter',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@id'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': <String, Object?>{
                'token': 'identifier',
              },
              '@keywords': <String, Object?>{
                'token': 'keyword.\$0',
              },
              '@stringOperators': <String, Object?>{
                'token': 'operators',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\[\\]\\(\\)\\{\\}]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\\(': <String, Object?>{
                'next': '@inParen_bracket_dollar.gt',
                'token': '@brackets',
              },
              '\\)': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_bracket_dollar': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
              '\\[': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==gt': <String, Object?>{
                    'next': '@inParen_bracket_dollar.gt',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'next': '@inParen_bracket_dollar.plain',
                    'token': '@brackets',
                  },
                },
              },
              '\\]': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_bracket_dollar': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '\$S2==directive': <String, Object?>{
                    'next': '@popall',
                    'token': '@brackets.directive',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
              '\\{': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==gt': <String, Object?>{
                    'next': '@inParen_bracket_dollar.gt',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'next': '@inParen_bracket_dollar.plain',
                    'token': '@brackets',
                  },
                },
              },
              '\\}': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_bracket_dollar': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '\$S2==interpolation': <String, Object?>{
                    'next': '@popall',
                    'token': '@brackets.interpolation',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$\\{'),
        IExpandedMonarchLanguageAction(
          token: 'delimiter.invalid',
        ),
      ),
      ],
    'fmExpression_bracket_dollar.directive': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_bracket_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_bracket_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_bracket_dollar',
      ),
      ],
    'fmExpression_bracket_dollar.interpolation': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_bracket_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_bracket_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@greater_operators_token_bracket_dollar',
      ),
      ],
    'greater_operators_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>='),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
      ],
    'inParen_bracket_dollar.gt': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_bracket_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_bracket_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@greater_operators_token_bracket_dollar',
      ),
      ],
    'inParen_bracket_dollar.plain': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_bracket_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_bracket_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_bracket_dollar',
      ),
      ],
    'interpolation_and_text_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@iOpen1_bracket_dollar)(@iOpen2_bracket_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter.interpolation',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_bracket_dollar.interpolation',
            token: '@brackets.interpolation',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\\$#<\\[\\{]|(?:@blank)+|[^\\\$<#\\[\\{\\n\\r\\t ]+'),
        IExpandedMonarchLanguageAction(
          token: 'source',
        ),
      ),
      ],
    'noParse_bracket_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@no_parse_token_bracket_dollar',
      ),
      ],
    'noSpaceExpression_bracket_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@no_space_expression_end_token_bracket_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_bracket_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_bracket_dollar',
      ),
      ],
    'no_parse_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@open_bracket_dollar)(\\/#?)([a-zA-Z]+)((?:@blank)*)(@close_bracket_dollar)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==\$3': <Object?>[
                <String, Object?>{
                  'token': '@brackets.directive',
                },
                <String, Object?>{
                  'token': 'delimiter.directive',
                },
                <String, Object?>{
                  'token': 'tag',
                },
                <String, Object?>{
                  'token': '',
                },
                <String, Object?>{
                  'next': '@popall',
                  'token': '@brackets.directive',
                },
              ],
              '\$S2==comment': <Object?>[
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
              ],
              '@default': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<\\[\\-]+|[<\\[\\-]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==comment': <String, Object?>{
                'token': 'comment',
              },
              '@default': <String, Object?>{
                'token': 'source',
              },
            },
        ),
      ),
      ],
    'no_space_expression_end_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@blank)+'),
        IExpandedMonarchLanguageAction(
          switchTo: '@fmExpression_bracket_dollar.directive',
          token: '',
        ),
      ),
      ],
    'rawDoubleString_bracket_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_double_raw_token_bracket_dollar',
      ),
      ],
    'rawSingleString_bracket_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_single_raw_token_bracket_dollar',
      ),
      ],
    'singleString_bracket_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_single_token_bracket_dollar',
      ),
      ],
    'string_double_raw_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"]+'),
        IExpandedMonarchLanguageAction(
          token: 'string.raw',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.raw',
        ),
      ),
      ],
    'string_double_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"\\\\]'),
        IExpandedMonarchLanguageAction(
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapedChar'),
        IExpandedMonarchLanguageAction(
          token: 'string.escape',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
      ],
    'string_single_raw_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\']+'),
        IExpandedMonarchLanguageAction(
          token: 'string.raw',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.raw',
        ),
      ),
      ],
    'string_single_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\'\\\\]'),
        IExpandedMonarchLanguageAction(
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapedChar'),
        IExpandedMonarchLanguageAction(
          token: 'string.escape',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
      ],
    'terseComment_bracket_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@terse_comment_token_bracket_dollar',
      ),
      ],
    'terse_comment_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('--(?:@close_bracket_dollar)'),
        IExpandedMonarchLanguageAction(
          next: '@popall',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<\\[\\-]+|[<\\[\\-]'),
        IExpandedMonarchLanguageAction(
          token: 'comment',
        ),
      ),
      ],
    'unifiedCall_bracket_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@unified_call_token_bracket_dollar',
      ),
      ],
    'unified_call_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@id)((?:@blank)+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_bracket_dollar.directive',
            token: '',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@id)(\\/?)(@close_bracket_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@popall',
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IExpandedMonarchLanguageAction(
          next: '@noSpaceExpression_bracket_dollar',
          token: '@rematch',
        ),
      ),
      ],
  },
    ignoreCase: false,
    unicode: true,
    defaultToken: 'invalid',
    brackets: <IMonarchLanguageBracket>[
      IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
      IMonarchLanguageBracket('[', ']', 'delimiter.square'),
      IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
      IMonarchLanguageBracket('<', '>', 'delimiter.angle'),
    ],
    start: 'default_bracket_dollar',
    tokenPostfix: '.freemarker2',
    includeLF: false,
    extra: <String, Object?>{
          'arrows': <Object?>[
            '->',
            '-&gt;',
          ],
          'asciiDigit': RegExp('[0-9]'),
          'blank': RegExp('[ \\t\\n\\r]'),
          'closeTag1_bracket_dollar': RegExp('((?:@blank)*)(@close_bracket_dollar)'),
          'closeTag2_bracket_dollar': RegExp('((?:@blank)*\\/?)(@close_bracket_dollar)'),
          'close_bracket_dollar': RegExp('\\]'),
          'delimiters': <Object?>[
            ';',
            ':',
            ',',
            '.',
          ],
          'directiveEndCloseTag1': RegExp('if|list|items|sep|recover|attempt|for[eE]ach|local|global|assign|function|macro|output[fF]ormat|auto[eE]sc|no(?:autoe|AutoE)sc|compress|transform|switch|escape|no[eE]scape'),
          'directiveStartBlank': RegExp('if|else[iI]f|list|for[eE]ach|switch|case|assign|global|local|include|import|function|macro|transform|visit|stop|return|call|setting|output[fF]ormat|nested|recurse|escape|ftl|items'),
          'directiveStartCloseTag1': RegExp('attempt|recover|sep|auto[eE]sc|no(?:autoe|AutoE)sc|compress|default|no[eE]scape|comment|no[pP]arse'),
          'directiveStartCloseTag2': RegExp('else|break|continue|return|stop|flush|t|lt|rt|nt|nested|recurse|fallback|ftl'),
          'endTag_bracket_dollar': RegExp('(@open_bracket_dollar)(\\/#)'),
          'escapedChar': RegExp('\\\\(?:[ntrfbgla\\\\\'"\\{=]|(?:x[0-9A-Fa-f]{1,4}))'),
          'escapedIdChar': RegExp('\\\\[\\-\\.:#]'),
          'iClose_bracket_dollar': RegExp('\\}'),
          'iOpen1_bracket_dollar': RegExp('\\\$'),
          'iOpen2_bracket_dollar': RegExp('\\{'),
          'id': RegExp('(?:@idStartChar)(?:(?:@idStartChar)|(?:@asciiDigit))*'),
          'idStartChar': RegExp('(?:@nonEscapedIdStartChar)|(?:@escapedIdChar)'),
          'integer': RegExp('[0-9]+'),
          'keywords': <Object?>[
            'false',
            'true',
            'in',
            'as',
            'using',
          ],
          'namedSymbols': RegExp('&lt;=|&gt;=|\\\\lte|\\\\lt|&lt;|\\\\gte|\\\\gt|&gt;|&amp;&amp;|\\\\and|-&gt;|->|==|!=|\\+=|-=|\\*=|\\/=|%=|\\+\\+|--|<=|&&|\\|\\||:|\\.\\.\\.|\\.\\.\\*|\\.\\.<|\\.\\.!|\\?\\?|=|<|\\+|-|\\*|\\/|%|\\||\\.\\.|\\?|!|&|\\.|,|;'),
          'noParseTags': <Object?>[
            'noparse',
            'noParse',
            'comment',
          ],
          'nonEscapedIdStartChar': RegExp('[\\\$@-Z_a-z\\u00AA\\u00B5\\u00BA\\u00C0-\\u00D6\\u00D8-\\u00F6\\u00F8-\\u1FFF\\u2071\\u207F\\u2090-\\u209C\\u2102\\u2107\\u210A-\\u2113\\u2115\\u2119-\\u211D\\u2124\\u2126\\u2128\\u212A-\\u212D\\u212F-\\u2139\\u213C-\\u213F\\u2145-\\u2149\\u214E\\u2183-\\u2184\\u2C00-\\u2C2E\\u2C30-\\u2C5E\\u2C60-\\u2CE4\\u2CEB-\\u2CEE\\u2CF2-\\u2CF3\\u2D00-\\u2D25\\u2D27\\u2D2D\\u2D30-\\u2D67\\u2D6F\\u2D80-\\u2D96\\u2DA0-\\u2DA6\\u2DA8-\\u2DAE\\u2DB0-\\u2DB6\\u2DB8-\\u2DBE\\u2DC0-\\u2DC6\\u2DC8-\\u2DCE\\u2DD0-\\u2DD6\\u2DD8-\\u2DDE\\u2E2F\\u3005-\\u3006\\u3031-\\u3035\\u303B-\\u303C\\u3040-\\u318F\\u31A0-\\u31BA\\u31F0-\\u31FF\\u3300-\\u337F\\u3400-\\u4DB5\\u4E00-\\uA48C\\uA4D0-\\uA4FD\\uA500-\\uA60C\\uA610-\\uA62B\\uA640-\\uA66E\\uA67F-\\uA697\\uA6A0-\\uA6E5\\uA717-\\uA71F\\uA722-\\uA788\\uA78B-\\uA78E\\uA790-\\uA793\\uA7A0-\\uA7AA\\uA7F8-\\uA801\\uA803-\\uA805\\uA807-\\uA80A\\uA80C-\\uA822\\uA840-\\uA873\\uA882-\\uA8B3\\uA8D0-\\uA8D9\\uA8F2-\\uA8F7\\uA8FB\\uA900-\\uA925\\uA930-\\uA946\\uA960-\\uA97C\\uA984-\\uA9B2\\uA9CF-\\uA9D9\\uAA00-\\uAA28\\uAA40-\\uAA42\\uAA44-\\uAA4B\\uAA50-\\uAA59\\uAA60-\\uAA76\\uAA7A\\uAA80-\\uAAAF\\uAAB1\\uAAB5-\\uAAB6\\uAAB9-\\uAABD\\uAAC0\\uAAC2\\uAADB-\\uAADD\\uAAE0-\\uAAEA\\uAAF2-\\uAAF4\\uAB01-\\uAB06\\uAB09-\\uAB0E\\uAB11-\\uAB16\\uAB20-\\uAB26\\uAB28-\\uAB2E\\uABC0-\\uABE2\\uABF0-\\uABF9\\uAC00-\\uD7A3\\uD7B0-\\uD7C6\\uD7CB-\\uD7FB\\uF900-\\uFB06\\uFB13-\\uFB17\\uFB1D\\uFB1F-\\uFB28\\uFB2A-\\uFB36\\uFB38-\\uFB3C\\uFB3E\\uFB40-\\uFB41\\uFB43-\\uFB44\\uFB46-\\uFBB1\\uFBD3-\\uFD3D\\uFD50-\\uFD8F\\uFD92-\\uFDC7\\uFDF0-\\uFDFB\\uFE70-\\uFE74\\uFE76-\\uFEFC\\uFF10-\\uFF19\\uFF21-\\uFF3A\\uFF41-\\uFF5A\\uFF66-\\uFFBE\\uFFC2-\\uFFC7\\uFFCA-\\uFFCF\\uFFD2-\\uFFD7\\uFFDA-\\uFFDC]'),
          'open_bracket_dollar': RegExp('\\['),
          'specialHashKeys': RegExp('\\*\\*|\\*|false|true|in|as|using'),
          'startOrEndTag_bracket_dollar': RegExp('(@open_bracket_dollar)(\\/?#)'),
          'startTag_bracket_dollar': RegExp('(@open_bracket_dollar)(#)'),
          'stringOperators': <Object?>[
            'lte',
            'lt',
            'gte',
            'gt',
          ],
        },
  ),
);

/// 1:1: `export const TagAngleInterpolationBracket = { conf, language }`
final class TagAngleInterpolationBracketDef {
  final Map<String, Object?> conf;
  final IMonarchLanguage language;
  TagAngleInterpolationBracketDef(this.conf, this.language);
}

final TagAngleInterpolationBracketDef TagAngleInterpolationBracket = TagAngleInterpolationBracketDef(
  <String, Object?>{
      'autoCloseBefore': '\n\r\t }]),.:;=',
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
          ],
          'open': '\'',
        },
      ],
      'brackets': <Object?>[
        <Object?>[
          '<',
          '>',
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
          '{',
          '}',
        ],
      ],
      'comments': <String, Object?>{
        'blockComment': <Object?>[
          '<--',
          '-->',
        ],
      },
      'folding': <String, Object?>{
        'markers': <String, Object?>{
          'end': RegExp('<\\/#(?:attempt|autoesc|autoEsc|compress|comment|escape|noescape|function|if|list|items|sep|macro|noparse|noParse|noautoesc|noAutoEsc|outputformat|switch|visit|recurse)[\\r\\n\\t ]*>'),
          'start': RegExp('<#(?:attempt|autoesc|autoEsc|compress|comment|escape|noescape|function|if|list|items|sep|macro|noparse|noParse|noautoesc|noAutoEsc|outputformat|switch|visit|recurse)([^/>]*(?!\\/)>)[^<]*\$'),
        },
      },
      'onEnterRules': <Object?>[
        <String, Object?>{
          'action': <String, Object?>{
            'indentAction': 2,
          },
          'afterText': RegExp('^<\\/#([a-zA-Z_]+)[\\r\\n\\t ]*>\$'),
          'beforeText': RegExp('<#(?!(?:assign|flush|ftl|return|global|import|include|break|continue|local|nested|nt|setting|stop|t|lt|rt|fallback))([a-zA-Z_]+)([^/>]*(?!\\/)>)[^<]*\$'),
        },
        <String, Object?>{
          'action': <String, Object?>{
            'indentAction': 1,
          },
          'beforeText': RegExp('<#(?!(?:assign|flush|ftl|return|global|import|include|break|continue|local|nested|nt|setting|stop|t|lt|rt|fallback))([a-zA-Z_]+)([^/>]*(?!\\/)>)[^<]*\$'),
        },
      ],
      'surroundingPairs': <Object?>[
        <String, Object?>{
          'close': '"',
          'open': '"',
        },
        <String, Object?>{
          'close': '\'',
          'open': '\'',
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
        <String, Object?>{
          'close': '>',
          'open': '<',
        },
      ],
    },
  IMonarchLanguage(tokenizer: <String, List<IMonarchLanguageRule>>{
    'blank_and_expression_comment_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@blank)+'),
        IExpandedMonarchLanguageAction(
          token: '',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[<\\[][#!]--'),
        IExpandedMonarchLanguageAction(
          next: '@expressionComment_angle_bracket',
          token: 'comment',
        ),
      ),
      ],
    'default_angle_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@directive_token_angle_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@interpolation_and_text_token_angle_bracket',
      ),
      ],
    'directive_end_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@popall',
          token: '@brackets.directive',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\/)(@close_angle_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@popall',
            token: '@brackets.directive',
          ),
        ]),
      ),
      ],
    'directive_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_angle_bracket)(@directiveStartCloseTag1)(?:@closeTag1_angle_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            cases: <String, Object?>{
                '@default': <String, Object?>{
                  'token': 'tag',
                },
                '@noParseTags': <String, Object?>{
                  'next': '@noParse_angle_bracket.\$3',
                  'token': 'tag',
                },
              },
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_angle_bracket)(@directiveStartCloseTag2)(?:@closeTag2_angle_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_angle_bracket)(@directiveStartBlank)(@blank)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_angle_bracket.directive',
            token: '',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@endTag_angle_bracket)(@directiveEndCloseTag1)(?:@closeTag1_angle_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_angle_bracket)(@)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@unifiedCall_angle_bracket',
            token: 'delimiter.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_angle_bracket)(\\/@)((?:(?:@id)(?:\\.(?:@id))*)?)(?:@closeTag1_angle_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_angle_bracket)#--'),
        IExpandedMonarchLanguageAction(
          next: '@terseComment_angle_bracket',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startOrEndTag_angle_bracket)([a-zA-Z_]+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_angle_bracket.directive',
            token: 'tag.invalid',
          ),
        ]),
      ),
      ],
    'doubleString_angle_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_double_token_angle_bracket',
      ),
      ],
    'expressionComment_angle_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@expression_comment_token_angle_bracket',
      ),
      ],
    'expression_comment_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('--[>\\]]'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\->\\]]+|[>\\]\\-]'),
        IExpandedMonarchLanguageAction(
          token: 'comment',
        ),
      ),
      ],
    'expression_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(r?)([\'"])'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '"': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'next': '@doubleString_angle_bracket',
                  'token': 'string',
                },
              ],
              '\'': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'next': '@singleString_angle_bracket',
                  'token': 'string',
                },
              ],
              'r"': <Object?>[
                <String, Object?>{
                  'token': 'keyword',
                },
                <String, Object?>{
                  'next': '@rawDoubleString_angle_bracket',
                  'token': 'string.raw',
                },
              ],
              'r\'': <Object?>[
                <String, Object?>{
                  'token': 'keyword',
                },
                <String, Object?>{
                  'next': '@rawSingleString_angle_bracket',
                  'token': 'string.raw',
                },
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@integer)(?:\\.(?:@integer))?'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '(?:@integer)': <String, Object?>{
                'token': 'number',
              },
              '@default': <String, Object?>{
                'token': 'number.float',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\.)(@blank*)(@specialHashKeys)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter',
          ),
          IExpandedMonarchLanguageAction(
            token: '',
          ),
          IExpandedMonarchLanguageAction(
            token: 'identifier',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@namedSymbols)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@arrows': <String, Object?>{
                'token': 'meta.arrow',
              },
              '@default': <String, Object?>{
                'token': 'operators',
              },
              '@delimiters': <String, Object?>{
                'token': 'delimiter',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@id'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': <String, Object?>{
                'token': 'identifier',
              },
              '@keywords': <String, Object?>{
                'token': 'keyword.\$0',
              },
              '@stringOperators': <String, Object?>{
                'token': 'operators',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\[\\]\\(\\)\\{\\}]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\\(': <String, Object?>{
                'next': '@inParen_angle_bracket.gt',
                'token': '@brackets',
              },
              '\\)': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_angle_bracket': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
              '\\[': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==gt': <String, Object?>{
                    'next': '@inParen_angle_bracket.gt',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'next': '@inParen_angle_bracket.plain',
                    'token': '@brackets',
                  },
                },
              },
              '\\]': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_angle_bracket': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '\$S2==interpolation': <String, Object?>{
                    'next': '@popall',
                    'token': '@brackets.interpolation',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
              '\\{': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==gt': <String, Object?>{
                    'next': '@inParen_angle_bracket.gt',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'next': '@inParen_angle_bracket.plain',
                    'token': '@brackets',
                  },
                },
              },
              '\\}': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_angle_bracket': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$\\{'),
        IExpandedMonarchLanguageAction(
          token: 'delimiter.invalid',
        ),
      ),
      ],
    'fmExpression_angle_bracket.directive': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_angle_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_angle_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_angle_bracket',
      ),
      ],
    'fmExpression_angle_bracket.interpolation': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_angle_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_angle_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@greater_operators_token_angle_bracket',
      ),
      ],
    'greater_operators_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>='),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
      ],
    'inParen_angle_bracket.gt': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_angle_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_angle_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@greater_operators_token_angle_bracket',
      ),
      ],
    'inParen_angle_bracket.plain': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_angle_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_angle_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_angle_bracket',
      ),
      ],
    'interpolation_and_text_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@iOpen1_angle_bracket)(@iOpen2_angle_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.interpolation',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_angle_bracket.interpolation',
            token: 'delimiter.interpolation',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\\$#<\\[\\{]|(?:@blank)+|[^\\\$<#\\[\\{\\n\\r\\t ]+'),
        IExpandedMonarchLanguageAction(
          token: 'source',
        ),
      ),
      ],
    'noParse_angle_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@no_parse_token_angle_bracket',
      ),
      ],
    'noSpaceExpression_angle_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@no_space_expression_end_token_angle_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_angle_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_angle_bracket',
      ),
      ],
    'no_parse_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@open_angle_bracket)(\\/#?)([a-zA-Z]+)((?:@blank)*)(@close_angle_bracket)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==\$3': <Object?>[
                <String, Object?>{
                  'token': '@brackets.directive',
                },
                <String, Object?>{
                  'token': 'delimiter.directive',
                },
                <String, Object?>{
                  'token': 'tag',
                },
                <String, Object?>{
                  'token': '',
                },
                <String, Object?>{
                  'next': '@popall',
                  'token': '@brackets.directive',
                },
              ],
              '\$S2==comment': <Object?>[
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
              ],
              '@default': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<\\[\\-]+|[<\\[\\-]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==comment': <String, Object?>{
                'token': 'comment',
              },
              '@default': <String, Object?>{
                'token': 'source',
              },
            },
        ),
      ),
      ],
    'no_space_expression_end_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@blank)+'),
        IExpandedMonarchLanguageAction(
          switchTo: '@fmExpression_angle_bracket.directive',
          token: '',
        ),
      ),
      ],
    'rawDoubleString_angle_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_double_raw_token_angle_bracket',
      ),
      ],
    'rawSingleString_angle_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_single_raw_token_angle_bracket',
      ),
      ],
    'singleString_angle_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_single_token_angle_bracket',
      ),
      ],
    'string_double_raw_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"]+'),
        IExpandedMonarchLanguageAction(
          token: 'string.raw',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.raw',
        ),
      ),
      ],
    'string_double_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"\\\\]'),
        IExpandedMonarchLanguageAction(
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapedChar'),
        IExpandedMonarchLanguageAction(
          token: 'string.escape',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
      ],
    'string_single_raw_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\']+'),
        IExpandedMonarchLanguageAction(
          token: 'string.raw',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.raw',
        ),
      ),
      ],
    'string_single_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\'\\\\]'),
        IExpandedMonarchLanguageAction(
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapedChar'),
        IExpandedMonarchLanguageAction(
          token: 'string.escape',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
      ],
    'terseComment_angle_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@terse_comment_token_angle_bracket',
      ),
      ],
    'terse_comment_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('--(?:@close_angle_bracket)'),
        IExpandedMonarchLanguageAction(
          next: '@popall',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<\\[\\-]+|[<\\[\\-]'),
        IExpandedMonarchLanguageAction(
          token: 'comment',
        ),
      ),
      ],
    'unifiedCall_angle_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@unified_call_token_angle_bracket',
      ),
      ],
    'unified_call_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@id)((?:@blank)+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_angle_bracket.directive',
            token: '',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@id)(\\/?)(@close_angle_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@popall',
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IExpandedMonarchLanguageAction(
          next: '@noSpaceExpression_angle_bracket',
          token: '@rematch',
        ),
      ),
      ],
  },
    ignoreCase: false,
    unicode: true,
    defaultToken: 'invalid',
    brackets: <IMonarchLanguageBracket>[
      IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
      IMonarchLanguageBracket('[', ']', 'delimiter.square'),
      IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
      IMonarchLanguageBracket('<', '>', 'delimiter.angle'),
    ],
    start: 'default_angle_bracket',
    tokenPostfix: '.freemarker2',
    includeLF: false,
    extra: <String, Object?>{
          'arrows': <Object?>[
            '->',
            '-&gt;',
          ],
          'asciiDigit': RegExp('[0-9]'),
          'blank': RegExp('[ \\t\\n\\r]'),
          'closeTag1_angle_bracket': RegExp('((?:@blank)*)(@close_angle_bracket)'),
          'closeTag2_angle_bracket': RegExp('((?:@blank)*\\/?)(@close_angle_bracket)'),
          'close_angle_bracket': RegExp('>'),
          'delimiters': <Object?>[
            ';',
            ':',
            ',',
            '.',
          ],
          'directiveEndCloseTag1': RegExp('if|list|items|sep|recover|attempt|for[eE]ach|local|global|assign|function|macro|output[fF]ormat|auto[eE]sc|no(?:autoe|AutoE)sc|compress|transform|switch|escape|no[eE]scape'),
          'directiveStartBlank': RegExp('if|else[iI]f|list|for[eE]ach|switch|case|assign|global|local|include|import|function|macro|transform|visit|stop|return|call|setting|output[fF]ormat|nested|recurse|escape|ftl|items'),
          'directiveStartCloseTag1': RegExp('attempt|recover|sep|auto[eE]sc|no(?:autoe|AutoE)sc|compress|default|no[eE]scape|comment|no[pP]arse'),
          'directiveStartCloseTag2': RegExp('else|break|continue|return|stop|flush|t|lt|rt|nt|nested|recurse|fallback|ftl'),
          'endTag_angle_bracket': RegExp('(@open_angle_bracket)(\\/#)'),
          'escapedChar': RegExp('\\\\(?:[ntrfbgla\\\\\'"\\{=]|(?:x[0-9A-Fa-f]{1,4}))'),
          'escapedIdChar': RegExp('\\\\[\\-\\.:#]'),
          'iClose_angle_bracket': RegExp('\\]'),
          'iOpen1_angle_bracket': RegExp('\\['),
          'iOpen2_angle_bracket': RegExp('='),
          'id': RegExp('(?:@idStartChar)(?:(?:@idStartChar)|(?:@asciiDigit))*'),
          'idStartChar': RegExp('(?:@nonEscapedIdStartChar)|(?:@escapedIdChar)'),
          'integer': RegExp('[0-9]+'),
          'keywords': <Object?>[
            'false',
            'true',
            'in',
            'as',
            'using',
          ],
          'namedSymbols': RegExp('&lt;=|&gt;=|\\\\lte|\\\\lt|&lt;|\\\\gte|\\\\gt|&gt;|&amp;&amp;|\\\\and|-&gt;|->|==|!=|\\+=|-=|\\*=|\\/=|%=|\\+\\+|--|<=|&&|\\|\\||:|\\.\\.\\.|\\.\\.\\*|\\.\\.<|\\.\\.!|\\?\\?|=|<|\\+|-|\\*|\\/|%|\\||\\.\\.|\\?|!|&|\\.|,|;'),
          'noParseTags': <Object?>[
            'noparse',
            'noParse',
            'comment',
          ],
          'nonEscapedIdStartChar': RegExp('[\\\$@-Z_a-z\\u00AA\\u00B5\\u00BA\\u00C0-\\u00D6\\u00D8-\\u00F6\\u00F8-\\u1FFF\\u2071\\u207F\\u2090-\\u209C\\u2102\\u2107\\u210A-\\u2113\\u2115\\u2119-\\u211D\\u2124\\u2126\\u2128\\u212A-\\u212D\\u212F-\\u2139\\u213C-\\u213F\\u2145-\\u2149\\u214E\\u2183-\\u2184\\u2C00-\\u2C2E\\u2C30-\\u2C5E\\u2C60-\\u2CE4\\u2CEB-\\u2CEE\\u2CF2-\\u2CF3\\u2D00-\\u2D25\\u2D27\\u2D2D\\u2D30-\\u2D67\\u2D6F\\u2D80-\\u2D96\\u2DA0-\\u2DA6\\u2DA8-\\u2DAE\\u2DB0-\\u2DB6\\u2DB8-\\u2DBE\\u2DC0-\\u2DC6\\u2DC8-\\u2DCE\\u2DD0-\\u2DD6\\u2DD8-\\u2DDE\\u2E2F\\u3005-\\u3006\\u3031-\\u3035\\u303B-\\u303C\\u3040-\\u318F\\u31A0-\\u31BA\\u31F0-\\u31FF\\u3300-\\u337F\\u3400-\\u4DB5\\u4E00-\\uA48C\\uA4D0-\\uA4FD\\uA500-\\uA60C\\uA610-\\uA62B\\uA640-\\uA66E\\uA67F-\\uA697\\uA6A0-\\uA6E5\\uA717-\\uA71F\\uA722-\\uA788\\uA78B-\\uA78E\\uA790-\\uA793\\uA7A0-\\uA7AA\\uA7F8-\\uA801\\uA803-\\uA805\\uA807-\\uA80A\\uA80C-\\uA822\\uA840-\\uA873\\uA882-\\uA8B3\\uA8D0-\\uA8D9\\uA8F2-\\uA8F7\\uA8FB\\uA900-\\uA925\\uA930-\\uA946\\uA960-\\uA97C\\uA984-\\uA9B2\\uA9CF-\\uA9D9\\uAA00-\\uAA28\\uAA40-\\uAA42\\uAA44-\\uAA4B\\uAA50-\\uAA59\\uAA60-\\uAA76\\uAA7A\\uAA80-\\uAAAF\\uAAB1\\uAAB5-\\uAAB6\\uAAB9-\\uAABD\\uAAC0\\uAAC2\\uAADB-\\uAADD\\uAAE0-\\uAAEA\\uAAF2-\\uAAF4\\uAB01-\\uAB06\\uAB09-\\uAB0E\\uAB11-\\uAB16\\uAB20-\\uAB26\\uAB28-\\uAB2E\\uABC0-\\uABE2\\uABF0-\\uABF9\\uAC00-\\uD7A3\\uD7B0-\\uD7C6\\uD7CB-\\uD7FB\\uF900-\\uFB06\\uFB13-\\uFB17\\uFB1D\\uFB1F-\\uFB28\\uFB2A-\\uFB36\\uFB38-\\uFB3C\\uFB3E\\uFB40-\\uFB41\\uFB43-\\uFB44\\uFB46-\\uFBB1\\uFBD3-\\uFD3D\\uFD50-\\uFD8F\\uFD92-\\uFDC7\\uFDF0-\\uFDFB\\uFE70-\\uFE74\\uFE76-\\uFEFC\\uFF10-\\uFF19\\uFF21-\\uFF3A\\uFF41-\\uFF5A\\uFF66-\\uFFBE\\uFFC2-\\uFFC7\\uFFCA-\\uFFCF\\uFFD2-\\uFFD7\\uFFDA-\\uFFDC]'),
          'open_angle_bracket': RegExp('<'),
          'specialHashKeys': RegExp('\\*\\*|\\*|false|true|in|as|using'),
          'startOrEndTag_angle_bracket': RegExp('(@open_angle_bracket)(\\/?#)'),
          'startTag_angle_bracket': RegExp('(@open_angle_bracket)(#)'),
          'stringOperators': <Object?>[
            'lte',
            'lt',
            'gte',
            'gt',
          ],
        },
  ),
);

/// 1:1: `export const TagBracketInterpolationBracket = { conf, language }`
final class TagBracketInterpolationBracketDef {
  final Map<String, Object?> conf;
  final IMonarchLanguage language;
  TagBracketInterpolationBracketDef(this.conf, this.language);
}

final TagBracketInterpolationBracketDef TagBracketInterpolationBracket = TagBracketInterpolationBracketDef(
  <String, Object?>{
      'autoCloseBefore': '\n\r\t }]),.:;=',
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
          ],
          'open': '\'',
        },
      ],
      'brackets': <Object?>[
        <Object?>[
          '<',
          '>',
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
          '{',
          '}',
        ],
      ],
      'comments': <String, Object?>{
        'blockComment': <Object?>[
          '\\[--',
          '--\\]',
        ],
      },
      'folding': <String, Object?>{
        'markers': <String, Object?>{
          'end': RegExp('\\[\\/#(?:attempt|autoesc|autoEsc|compress|comment|escape|noescape|function|if|list|items|sep|macro|noparse|noParse|noautoesc|noAutoEsc|outputformat|switch|visit|recurse)[\\r\\n\\t ]*>'),
          'start': RegExp('\\[#(?:attempt|autoesc|autoEsc|compress|comment|escape|noescape|function|if|list|items|sep|macro|noparse|noParse|noautoesc|noAutoEsc|outputformat|switch|visit|recurse)([^/\\]]*(?!\\/)\\])[^\\[]*\$'),
        },
      },
      'onEnterRules': <Object?>[
        <String, Object?>{
          'action': <String, Object?>{
            'indentAction': 2,
          },
          'afterText': RegExp('^\\[\\/#([a-zA-Z_]+)[\\r\\n\\t ]*\\]\$'),
          'beforeText': RegExp('\\[#(?!(?:assign|flush|ftl|return|global|import|include|break|continue|local|nested|nt|setting|stop|t|lt|rt|fallback))([a-zA-Z_]+)([^/\\]]*(?!\\/)\\])[^\\[]*\$'),
        },
        <String, Object?>{
          'action': <String, Object?>{
            'indentAction': 1,
          },
          'beforeText': RegExp('\\[#(?!(?:assign|flush|ftl|return|global|import|include|break|continue|local|nested|nt|setting|stop|t|lt|rt|fallback))([a-zA-Z_]+)([^/\\]]*(?!\\/)\\])[^\\[]*\$'),
        },
      ],
      'surroundingPairs': <Object?>[
        <String, Object?>{
          'close': '"',
          'open': '"',
        },
        <String, Object?>{
          'close': '\'',
          'open': '\'',
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
        <String, Object?>{
          'close': '>',
          'open': '<',
        },
      ],
    },
  IMonarchLanguage(tokenizer: <String, List<IMonarchLanguageRule>>{
    'blank_and_expression_comment_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@blank)+'),
        IExpandedMonarchLanguageAction(
          token: '',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[<\\[][#!]--'),
        IExpandedMonarchLanguageAction(
          next: '@expressionComment_bracket_bracket',
          token: 'comment',
        ),
      ),
      ],
    'default_bracket_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@directive_token_bracket_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@interpolation_and_text_token_bracket_bracket',
      ),
      ],
    'directive_end_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\/)(@close_bracket_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@popall',
            token: '@brackets.directive',
          ),
        ]),
      ),
      ],
    'directive_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_bracket_bracket)(@directiveStartCloseTag1)(?:@closeTag1_bracket_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            cases: <String, Object?>{
                '@default': <String, Object?>{
                  'token': 'tag',
                },
                '@noParseTags': <String, Object?>{
                  'next': '@noParse_bracket_bracket.\$3',
                  'token': 'tag',
                },
              },
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_bracket_bracket)(@directiveStartCloseTag2)(?:@closeTag2_bracket_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_bracket_bracket)(@directiveStartBlank)(@blank)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_bracket_bracket.directive',
            token: '',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@endTag_bracket_bracket)(@directiveEndCloseTag1)(?:@closeTag1_bracket_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_bracket_bracket)(@)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@unifiedCall_bracket_bracket',
            token: 'delimiter.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_bracket_bracket)(\\/@)((?:(?:@id)(?:\\.(?:@id))*)?)(?:@closeTag1_bracket_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_bracket_bracket)#--'),
        IExpandedMonarchLanguageAction(
          next: '@terseComment_bracket_bracket',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startOrEndTag_bracket_bracket)([a-zA-Z_]+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_bracket_bracket.directive',
            token: 'tag.invalid',
          ),
        ]),
      ),
      ],
    'doubleString_bracket_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_double_token_bracket_bracket',
      ),
      ],
    'expressionComment_bracket_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@expression_comment_token_bracket_bracket',
      ),
      ],
    'expression_comment_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('--[>\\]]'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\->\\]]+|[>\\]\\-]'),
        IExpandedMonarchLanguageAction(
          token: 'comment',
        ),
      ),
      ],
    'expression_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(r?)([\'"])'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '"': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'next': '@doubleString_bracket_bracket',
                  'token': 'string',
                },
              ],
              '\'': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'next': '@singleString_bracket_bracket',
                  'token': 'string',
                },
              ],
              'r"': <Object?>[
                <String, Object?>{
                  'token': 'keyword',
                },
                <String, Object?>{
                  'next': '@rawDoubleString_bracket_bracket',
                  'token': 'string.raw',
                },
              ],
              'r\'': <Object?>[
                <String, Object?>{
                  'token': 'keyword',
                },
                <String, Object?>{
                  'next': '@rawSingleString_bracket_bracket',
                  'token': 'string.raw',
                },
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@integer)(?:\\.(?:@integer))?'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '(?:@integer)': <String, Object?>{
                'token': 'number',
              },
              '@default': <String, Object?>{
                'token': 'number.float',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\.)(@blank*)(@specialHashKeys)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter',
          ),
          IExpandedMonarchLanguageAction(
            token: '',
          ),
          IExpandedMonarchLanguageAction(
            token: 'identifier',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@namedSymbols)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@arrows': <String, Object?>{
                'token': 'meta.arrow',
              },
              '@default': <String, Object?>{
                'token': 'operators',
              },
              '@delimiters': <String, Object?>{
                'token': 'delimiter',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@id'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': <String, Object?>{
                'token': 'identifier',
              },
              '@keywords': <String, Object?>{
                'token': 'keyword.\$0',
              },
              '@stringOperators': <String, Object?>{
                'token': 'operators',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\[\\]\\(\\)\\{\\}]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\\(': <String, Object?>{
                'next': '@inParen_bracket_bracket.gt',
                'token': '@brackets',
              },
              '\\)': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_bracket_bracket': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
              '\\[': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==gt': <String, Object?>{
                    'next': '@inParen_bracket_bracket.gt',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'next': '@inParen_bracket_bracket.plain',
                    'token': '@brackets',
                  },
                },
              },
              '\\]': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_bracket_bracket': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '\$S2==directive': <String, Object?>{
                    'next': '@popall',
                    'token': '@brackets.directive',
                  },
                  '\$S2==interpolation': <String, Object?>{
                    'next': '@popall',
                    'token': '@brackets.interpolation',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
              '\\{': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==gt': <String, Object?>{
                    'next': '@inParen_bracket_bracket.gt',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'next': '@inParen_bracket_bracket.plain',
                    'token': '@brackets',
                  },
                },
              },
              '\\}': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_bracket_bracket': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$\\{'),
        IExpandedMonarchLanguageAction(
          token: 'delimiter.invalid',
        ),
      ),
      ],
    'fmExpression_bracket_bracket.directive': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_bracket_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_bracket_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_bracket_bracket',
      ),
      ],
    'fmExpression_bracket_bracket.interpolation': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_bracket_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_bracket_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@greater_operators_token_bracket_bracket',
      ),
      ],
    'greater_operators_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>='),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
      ],
    'inParen_bracket_bracket.gt': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_bracket_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_bracket_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@greater_operators_token_bracket_bracket',
      ),
      ],
    'inParen_bracket_bracket.plain': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_bracket_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_bracket_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_bracket_bracket',
      ),
      ],
    'interpolation_and_text_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@iOpen1_bracket_bracket)(@iOpen2_bracket_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.interpolation',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_bracket_bracket.interpolation',
            token: 'delimiter.interpolation',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\\$#<\\[\\{]|(?:@blank)+|[^\\\$<#\\[\\{\\n\\r\\t ]+'),
        IExpandedMonarchLanguageAction(
          token: 'source',
        ),
      ),
      ],
    'noParse_bracket_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@no_parse_token_bracket_bracket',
      ),
      ],
    'noSpaceExpression_bracket_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@no_space_expression_end_token_bracket_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_bracket_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_bracket_bracket',
      ),
      ],
    'no_parse_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@open_bracket_bracket)(\\/#?)([a-zA-Z]+)((?:@blank)*)(@close_bracket_bracket)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==\$3': <Object?>[
                <String, Object?>{
                  'token': '@brackets.directive',
                },
                <String, Object?>{
                  'token': 'delimiter.directive',
                },
                <String, Object?>{
                  'token': 'tag',
                },
                <String, Object?>{
                  'token': '',
                },
                <String, Object?>{
                  'next': '@popall',
                  'token': '@brackets.directive',
                },
              ],
              '\$S2==comment': <Object?>[
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
              ],
              '@default': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<\\[\\-]+|[<\\[\\-]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==comment': <String, Object?>{
                'token': 'comment',
              },
              '@default': <String, Object?>{
                'token': 'source',
              },
            },
        ),
      ),
      ],
    'no_space_expression_end_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@blank)+'),
        IExpandedMonarchLanguageAction(
          switchTo: '@fmExpression_bracket_bracket.directive',
          token: '',
        ),
      ),
      ],
    'rawDoubleString_bracket_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_double_raw_token_bracket_bracket',
      ),
      ],
    'rawSingleString_bracket_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_single_raw_token_bracket_bracket',
      ),
      ],
    'singleString_bracket_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_single_token_bracket_bracket',
      ),
      ],
    'string_double_raw_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"]+'),
        IExpandedMonarchLanguageAction(
          token: 'string.raw',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.raw',
        ),
      ),
      ],
    'string_double_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"\\\\]'),
        IExpandedMonarchLanguageAction(
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapedChar'),
        IExpandedMonarchLanguageAction(
          token: 'string.escape',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
      ],
    'string_single_raw_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\']+'),
        IExpandedMonarchLanguageAction(
          token: 'string.raw',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.raw',
        ),
      ),
      ],
    'string_single_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\'\\\\]'),
        IExpandedMonarchLanguageAction(
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapedChar'),
        IExpandedMonarchLanguageAction(
          token: 'string.escape',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
      ],
    'terseComment_bracket_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@terse_comment_token_bracket_bracket',
      ),
      ],
    'terse_comment_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('--(?:@close_bracket_bracket)'),
        IExpandedMonarchLanguageAction(
          next: '@popall',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<\\[\\-]+|[<\\[\\-]'),
        IExpandedMonarchLanguageAction(
          token: 'comment',
        ),
      ),
      ],
    'unifiedCall_bracket_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@unified_call_token_bracket_bracket',
      ),
      ],
    'unified_call_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@id)((?:@blank)+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_bracket_bracket.directive',
            token: '',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@id)(\\/?)(@close_bracket_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@popall',
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IExpandedMonarchLanguageAction(
          next: '@noSpaceExpression_bracket_bracket',
          token: '@rematch',
        ),
      ),
      ],
  },
    ignoreCase: false,
    unicode: true,
    defaultToken: 'invalid',
    brackets: <IMonarchLanguageBracket>[
      IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
      IMonarchLanguageBracket('[', ']', 'delimiter.square'),
      IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
      IMonarchLanguageBracket('<', '>', 'delimiter.angle'),
    ],
    start: 'default_bracket_bracket',
    tokenPostfix: '.freemarker2',
    includeLF: false,
    extra: <String, Object?>{
          'arrows': <Object?>[
            '->',
            '-&gt;',
          ],
          'asciiDigit': RegExp('[0-9]'),
          'blank': RegExp('[ \\t\\n\\r]'),
          'closeTag1_bracket_bracket': RegExp('((?:@blank)*)(@close_bracket_bracket)'),
          'closeTag2_bracket_bracket': RegExp('((?:@blank)*\\/?)(@close_bracket_bracket)'),
          'close_bracket_bracket': RegExp('\\]'),
          'delimiters': <Object?>[
            ';',
            ':',
            ',',
            '.',
          ],
          'directiveEndCloseTag1': RegExp('if|list|items|sep|recover|attempt|for[eE]ach|local|global|assign|function|macro|output[fF]ormat|auto[eE]sc|no(?:autoe|AutoE)sc|compress|transform|switch|escape|no[eE]scape'),
          'directiveStartBlank': RegExp('if|else[iI]f|list|for[eE]ach|switch|case|assign|global|local|include|import|function|macro|transform|visit|stop|return|call|setting|output[fF]ormat|nested|recurse|escape|ftl|items'),
          'directiveStartCloseTag1': RegExp('attempt|recover|sep|auto[eE]sc|no(?:autoe|AutoE)sc|compress|default|no[eE]scape|comment|no[pP]arse'),
          'directiveStartCloseTag2': RegExp('else|break|continue|return|stop|flush|t|lt|rt|nt|nested|recurse|fallback|ftl'),
          'endTag_bracket_bracket': RegExp('(@open_bracket_bracket)(\\/#)'),
          'escapedChar': RegExp('\\\\(?:[ntrfbgla\\\\\'"\\{=]|(?:x[0-9A-Fa-f]{1,4}))'),
          'escapedIdChar': RegExp('\\\\[\\-\\.:#]'),
          'iClose_bracket_bracket': RegExp('\\]'),
          'iOpen1_bracket_bracket': RegExp('\\['),
          'iOpen2_bracket_bracket': RegExp('='),
          'id': RegExp('(?:@idStartChar)(?:(?:@idStartChar)|(?:@asciiDigit))*'),
          'idStartChar': RegExp('(?:@nonEscapedIdStartChar)|(?:@escapedIdChar)'),
          'integer': RegExp('[0-9]+'),
          'keywords': <Object?>[
            'false',
            'true',
            'in',
            'as',
            'using',
          ],
          'namedSymbols': RegExp('&lt;=|&gt;=|\\\\lte|\\\\lt|&lt;|\\\\gte|\\\\gt|&gt;|&amp;&amp;|\\\\and|-&gt;|->|==|!=|\\+=|-=|\\*=|\\/=|%=|\\+\\+|--|<=|&&|\\|\\||:|\\.\\.\\.|\\.\\.\\*|\\.\\.<|\\.\\.!|\\?\\?|=|<|\\+|-|\\*|\\/|%|\\||\\.\\.|\\?|!|&|\\.|,|;'),
          'noParseTags': <Object?>[
            'noparse',
            'noParse',
            'comment',
          ],
          'nonEscapedIdStartChar': RegExp('[\\\$@-Z_a-z\\u00AA\\u00B5\\u00BA\\u00C0-\\u00D6\\u00D8-\\u00F6\\u00F8-\\u1FFF\\u2071\\u207F\\u2090-\\u209C\\u2102\\u2107\\u210A-\\u2113\\u2115\\u2119-\\u211D\\u2124\\u2126\\u2128\\u212A-\\u212D\\u212F-\\u2139\\u213C-\\u213F\\u2145-\\u2149\\u214E\\u2183-\\u2184\\u2C00-\\u2C2E\\u2C30-\\u2C5E\\u2C60-\\u2CE4\\u2CEB-\\u2CEE\\u2CF2-\\u2CF3\\u2D00-\\u2D25\\u2D27\\u2D2D\\u2D30-\\u2D67\\u2D6F\\u2D80-\\u2D96\\u2DA0-\\u2DA6\\u2DA8-\\u2DAE\\u2DB0-\\u2DB6\\u2DB8-\\u2DBE\\u2DC0-\\u2DC6\\u2DC8-\\u2DCE\\u2DD0-\\u2DD6\\u2DD8-\\u2DDE\\u2E2F\\u3005-\\u3006\\u3031-\\u3035\\u303B-\\u303C\\u3040-\\u318F\\u31A0-\\u31BA\\u31F0-\\u31FF\\u3300-\\u337F\\u3400-\\u4DB5\\u4E00-\\uA48C\\uA4D0-\\uA4FD\\uA500-\\uA60C\\uA610-\\uA62B\\uA640-\\uA66E\\uA67F-\\uA697\\uA6A0-\\uA6E5\\uA717-\\uA71F\\uA722-\\uA788\\uA78B-\\uA78E\\uA790-\\uA793\\uA7A0-\\uA7AA\\uA7F8-\\uA801\\uA803-\\uA805\\uA807-\\uA80A\\uA80C-\\uA822\\uA840-\\uA873\\uA882-\\uA8B3\\uA8D0-\\uA8D9\\uA8F2-\\uA8F7\\uA8FB\\uA900-\\uA925\\uA930-\\uA946\\uA960-\\uA97C\\uA984-\\uA9B2\\uA9CF-\\uA9D9\\uAA00-\\uAA28\\uAA40-\\uAA42\\uAA44-\\uAA4B\\uAA50-\\uAA59\\uAA60-\\uAA76\\uAA7A\\uAA80-\\uAAAF\\uAAB1\\uAAB5-\\uAAB6\\uAAB9-\\uAABD\\uAAC0\\uAAC2\\uAADB-\\uAADD\\uAAE0-\\uAAEA\\uAAF2-\\uAAF4\\uAB01-\\uAB06\\uAB09-\\uAB0E\\uAB11-\\uAB16\\uAB20-\\uAB26\\uAB28-\\uAB2E\\uABC0-\\uABE2\\uABF0-\\uABF9\\uAC00-\\uD7A3\\uD7B0-\\uD7C6\\uD7CB-\\uD7FB\\uF900-\\uFB06\\uFB13-\\uFB17\\uFB1D\\uFB1F-\\uFB28\\uFB2A-\\uFB36\\uFB38-\\uFB3C\\uFB3E\\uFB40-\\uFB41\\uFB43-\\uFB44\\uFB46-\\uFBB1\\uFBD3-\\uFD3D\\uFD50-\\uFD8F\\uFD92-\\uFDC7\\uFDF0-\\uFDFB\\uFE70-\\uFE74\\uFE76-\\uFEFC\\uFF10-\\uFF19\\uFF21-\\uFF3A\\uFF41-\\uFF5A\\uFF66-\\uFFBE\\uFFC2-\\uFFC7\\uFFCA-\\uFFCF\\uFFD2-\\uFFD7\\uFFDA-\\uFFDC]'),
          'open_bracket_bracket': RegExp('\\['),
          'specialHashKeys': RegExp('\\*\\*|\\*|false|true|in|as|using'),
          'startOrEndTag_bracket_bracket': RegExp('(@open_bracket_bracket)(\\/?#)'),
          'startTag_bracket_bracket': RegExp('(@open_bracket_bracket)(#)'),
          'stringOperators': <Object?>[
            'lte',
            'lt',
            'gte',
            'gt',
          ],
        },
  ),
);

/// 1:1: `export const TagAutoInterpolationDollar = { conf, language }`
final class TagAutoInterpolationDollarDef {
  final Map<String, Object?> conf;
  final IMonarchLanguage language;
  TagAutoInterpolationDollarDef(this.conf, this.language);
}

final TagAutoInterpolationDollarDef TagAutoInterpolationDollar = TagAutoInterpolationDollarDef(
  <String, Object?>{
      'autoCloseBefore': '\n\r\t }]),.:;=',
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
          ],
          'open': '\'',
        },
      ],
      'brackets': <Object?>[
        <Object?>[
          '<',
          '>',
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
          '{',
          '}',
        ],
      ],
      'folding': <String, Object?>{
        'markers': <String, Object?>{
          'end': RegExp('[<\\[]\\/#(?:attempt|autoesc|autoEsc|compress|comment|escape|noescape|function|if|list|items|sep|macro|noparse|noParse|noautoesc|noAutoEsc|outputformat|switch|visit|recurse)[\\r\\n\\t ]*>'),
          'start': RegExp('[<\\[]#(?:attempt|autoesc|autoEsc|compress|comment|escape|noescape|function|if|list|items|sep|macro|noparse|noParse|noautoesc|noAutoEsc|outputformat|switch|visit|recurse)([^/>\\]]*(?!\\/)[>\\]])[^<\\[]*\$'),
        },
      },
      'onEnterRules': <Object?>[
        <String, Object?>{
          'action': <String, Object?>{
            'indentAction': 2,
          },
          'afterText': RegExp('^[<\\[]\\/#([a-zA-Z_]+)[\\r\\n\\t ]*[>\\]]\$'),
          'beforeText': RegExp('[<\\[]#(?!(?:assign|flush|ftl|return|global|import|include|break|continue|local|nested|nt|setting|stop|t|lt|rt|fallback))([a-zA-Z_]+)([^/>\\]]*(?!\\/)[>\\]])[^[<\\[]]*\$'),
        },
        <String, Object?>{
          'action': <String, Object?>{
            'indentAction': 1,
          },
          'beforeText': RegExp('[<\\[]#(?!(?:assign|flush|ftl|return|global|import|include|break|continue|local|nested|nt|setting|stop|t|lt|rt|fallback))([a-zA-Z_]+)([^/>\\]]*(?!\\/)[>\\]])[^[<\\[]]*\$'),
        },
      ],
      'surroundingPairs': <Object?>[
        <String, Object?>{
          'close': '"',
          'open': '"',
        },
        <String, Object?>{
          'close': '\'',
          'open': '\'',
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
        <String, Object?>{
          'close': '>',
          'open': '<',
        },
      ],
    },
  IMonarchLanguage(tokenizer: <String, List<IMonarchLanguageRule>>{
    'blank_and_expression_comment_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@blank)+'),
        IExpandedMonarchLanguageAction(
          token: '',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[<\\[][#!]--'),
        IExpandedMonarchLanguageAction(
          next: '@expressionComment_angle_dollar',
          token: 'comment',
        ),
      ),
      ],
    'blank_and_expression_comment_token_auto_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@blank)+'),
        IExpandedMonarchLanguageAction(
          token: '',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[<\\[][#!]--'),
        IExpandedMonarchLanguageAction(
          next: '@expressionComment_auto_dollar',
          token: 'comment',
        ),
      ),
      ],
    'blank_and_expression_comment_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@blank)+'),
        IExpandedMonarchLanguageAction(
          token: '',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[<\\[][#!]--'),
        IExpandedMonarchLanguageAction(
          next: '@expressionComment_bracket_dollar',
          token: 'comment',
        ),
      ),
      ],
    'default_angle_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@directive_token_angle_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@interpolation_and_text_token_angle_dollar',
      ),
      ],
    'default_auto_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@directive_token_auto_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@interpolation_and_text_token_auto_dollar',
      ),
      ],
    'default_bracket_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@directive_token_bracket_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@interpolation_and_text_token_bracket_dollar',
      ),
      ],
    'directive_end_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@popall',
          token: '@brackets.directive',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\/)(@close_angle_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@popall',
            token: '@brackets.directive',
          ),
        ]),
      ),
      ],
    'directive_end_token_auto_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@popall',
          token: '@brackets.directive',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\/)(@close_auto_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@popall',
            token: '@brackets.directive',
          ),
        ]),
      ),
      ],
    'directive_end_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\/)(@close_bracket_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@popall',
            token: '@brackets.directive',
          ),
        ]),
      ),
      ],
    'directive_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_angle_dollar)(@directiveStartCloseTag1)(?:@closeTag1_angle_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            cases: <String, Object?>{
                '@default': <String, Object?>{
                  'token': 'tag',
                },
                '@noParseTags': <String, Object?>{
                  'next': '@noParse_angle_dollar.\$3',
                  'token': 'tag',
                },
              },
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_angle_dollar)(@directiveStartCloseTag2)(?:@closeTag2_angle_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_angle_dollar)(@directiveStartBlank)(@blank)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_angle_dollar.directive',
            token: '',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@endTag_angle_dollar)(@directiveEndCloseTag1)(?:@closeTag1_angle_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_angle_dollar)(@)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@unifiedCall_angle_dollar',
            token: 'delimiter.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_angle_dollar)(\\/@)((?:(?:@id)(?:\\.(?:@id))*)?)(?:@closeTag1_angle_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_angle_dollar)#--'),
        IExpandedMonarchLanguageAction(
          next: '@terseComment_angle_dollar',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startOrEndTag_angle_dollar)([a-zA-Z_]+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_angle_dollar.directive',
            token: 'tag.invalid',
          ),
        ]),
      ),
      ],
    'directive_token_auto_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_auto_dollar)(@directiveStartCloseTag1)(?:@closeTag1_auto_dollar)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==<': <String, Object?>{
                'switchTo': '@default_angle_dollar',
                'token': '@rematch',
              },
              '\$1==[': <String, Object?>{
                'switchTo': '@default_bracket_dollar',
                'token': '@rematch',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_auto_dollar)(@directiveStartCloseTag2)(?:@closeTag2_auto_dollar)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==<': <String, Object?>{
                'switchTo': '@default_angle_dollar',
                'token': '@rematch',
              },
              '\$1==[': <String, Object?>{
                'switchTo': '@default_bracket_dollar',
                'token': '@rematch',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_auto_dollar)(@directiveStartBlank)(@blank)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==<': <String, Object?>{
                'switchTo': '@default_angle_dollar',
                'token': '@rematch',
              },
              '\$1==[': <String, Object?>{
                'switchTo': '@default_bracket_dollar',
                'token': '@rematch',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@endTag_auto_dollar)(@directiveEndCloseTag1)(?:@closeTag1_auto_dollar)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==<': <String, Object?>{
                'switchTo': '@default_angle_dollar',
                'token': '@rematch',
              },
              '\$1==[': <String, Object?>{
                'switchTo': '@default_bracket_dollar',
                'token': '@rematch',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_auto_dollar)(@)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==<': <String, Object?>{
                'switchTo': '@default_angle_dollar',
                'token': '@rematch',
              },
              '\$1==[': <String, Object?>{
                'switchTo': '@default_bracket_dollar',
                'token': '@rematch',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_auto_dollar)(\\/@)((?:(?:@id)(?:\\.(?:@id))*)?)(?:@closeTag1_auto_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_auto_dollar)#--'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==<': <String, Object?>{
                'switchTo': '@default_angle_dollar',
                'token': '@rematch',
              },
              '\$1==[': <String, Object?>{
                'switchTo': '@default_bracket_dollar',
                'token': '@rematch',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startOrEndTag_auto_dollar)([a-zA-Z_]+)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==<': <String, Object?>{
                'switchTo': '@default_angle_dollar',
                'token': '@rematch',
              },
              '\$1==[': <String, Object?>{
                'switchTo': '@default_bracket_dollar',
                'token': '@rematch',
              },
            },
        ),
      ),
      ],
    'directive_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_bracket_dollar)(@directiveStartCloseTag1)(?:@closeTag1_bracket_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            cases: <String, Object?>{
                '@default': <String, Object?>{
                  'token': 'tag',
                },
                '@noParseTags': <String, Object?>{
                  'next': '@noParse_bracket_dollar.\$3',
                  'token': 'tag',
                },
              },
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_bracket_dollar)(@directiveStartCloseTag2)(?:@closeTag2_bracket_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_bracket_dollar)(@directiveStartBlank)(@blank)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_bracket_dollar.directive',
            token: '',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@endTag_bracket_dollar)(@directiveEndCloseTag1)(?:@closeTag1_bracket_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_bracket_dollar)(@)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@unifiedCall_bracket_dollar',
            token: 'delimiter.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_bracket_dollar)(\\/@)((?:(?:@id)(?:\\.(?:@id))*)?)(?:@closeTag1_bracket_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_bracket_dollar)#--'),
        IExpandedMonarchLanguageAction(
          next: '@terseComment_bracket_dollar',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startOrEndTag_bracket_dollar)([a-zA-Z_]+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_bracket_dollar.directive',
            token: 'tag.invalid',
          ),
        ]),
      ),
      ],
    'doubleString_angle_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_double_token_angle_dollar',
      ),
      ],
    'doubleString_auto_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_double_token_auto_dollar',
      ),
      ],
    'doubleString_bracket_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_double_token_bracket_dollar',
      ),
      ],
    'expressionComment_angle_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@expression_comment_token_angle_dollar',
      ),
      ],
    'expressionComment_auto_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@expression_comment_token_auto_dollar',
      ),
      ],
    'expressionComment_bracket_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@expression_comment_token_bracket_dollar',
      ),
      ],
    'expression_comment_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('--[>\\]]'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\->\\]]+|[>\\]\\-]'),
        IExpandedMonarchLanguageAction(
          token: 'comment',
        ),
      ),
      ],
    'expression_comment_token_auto_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('--[>\\]]'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\->\\]]+|[>\\]\\-]'),
        IExpandedMonarchLanguageAction(
          token: 'comment',
        ),
      ),
      ],
    'expression_comment_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('--[>\\]]'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\->\\]]+|[>\\]\\-]'),
        IExpandedMonarchLanguageAction(
          token: 'comment',
        ),
      ),
      ],
    'expression_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(r?)([\'"])'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '"': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'next': '@doubleString_angle_dollar',
                  'token': 'string',
                },
              ],
              '\'': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'next': '@singleString_angle_dollar',
                  'token': 'string',
                },
              ],
              'r"': <Object?>[
                <String, Object?>{
                  'token': 'keyword',
                },
                <String, Object?>{
                  'next': '@rawDoubleString_angle_dollar',
                  'token': 'string.raw',
                },
              ],
              'r\'': <Object?>[
                <String, Object?>{
                  'token': 'keyword',
                },
                <String, Object?>{
                  'next': '@rawSingleString_angle_dollar',
                  'token': 'string.raw',
                },
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@integer)(?:\\.(?:@integer))?'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '(?:@integer)': <String, Object?>{
                'token': 'number',
              },
              '@default': <String, Object?>{
                'token': 'number.float',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\.)(@blank*)(@specialHashKeys)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter',
          ),
          IExpandedMonarchLanguageAction(
            token: '',
          ),
          IExpandedMonarchLanguageAction(
            token: 'identifier',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@namedSymbols)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@arrows': <String, Object?>{
                'token': 'meta.arrow',
              },
              '@default': <String, Object?>{
                'token': 'operators',
              },
              '@delimiters': <String, Object?>{
                'token': 'delimiter',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@id'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': <String, Object?>{
                'token': 'identifier',
              },
              '@keywords': <String, Object?>{
                'token': 'keyword.\$0',
              },
              '@stringOperators': <String, Object?>{
                'token': 'operators',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\[\\]\\(\\)\\{\\}]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\\(': <String, Object?>{
                'next': '@inParen_angle_dollar.gt',
                'token': '@brackets',
              },
              '\\)': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_angle_dollar': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
              '\\[': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==gt': <String, Object?>{
                    'next': '@inParen_angle_dollar.gt',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'next': '@inParen_angle_dollar.plain',
                    'token': '@brackets',
                  },
                },
              },
              '\\]': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_angle_dollar': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
              '\\{': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==gt': <String, Object?>{
                    'next': '@inParen_angle_dollar.gt',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'next': '@inParen_angle_dollar.plain',
                    'token': '@brackets',
                  },
                },
              },
              '\\}': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_angle_dollar': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '\$S2==interpolation': <String, Object?>{
                    'next': '@popall',
                    'token': '@brackets.interpolation',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$\\{'),
        IExpandedMonarchLanguageAction(
          token: 'delimiter.invalid',
        ),
      ),
      ],
    'expression_token_auto_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(r?)([\'"])'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '"': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'next': '@doubleString_auto_dollar',
                  'token': 'string',
                },
              ],
              '\'': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'next': '@singleString_auto_dollar',
                  'token': 'string',
                },
              ],
              'r"': <Object?>[
                <String, Object?>{
                  'token': 'keyword',
                },
                <String, Object?>{
                  'next': '@rawDoubleString_auto_dollar',
                  'token': 'string.raw',
                },
              ],
              'r\'': <Object?>[
                <String, Object?>{
                  'token': 'keyword',
                },
                <String, Object?>{
                  'next': '@rawSingleString_auto_dollar',
                  'token': 'string.raw',
                },
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@integer)(?:\\.(?:@integer))?'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '(?:@integer)': <String, Object?>{
                'token': 'number',
              },
              '@default': <String, Object?>{
                'token': 'number.float',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\.)(@blank*)(@specialHashKeys)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter',
          ),
          IExpandedMonarchLanguageAction(
            token: '',
          ),
          IExpandedMonarchLanguageAction(
            token: 'identifier',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@namedSymbols)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@arrows': <String, Object?>{
                'token': 'meta.arrow',
              },
              '@default': <String, Object?>{
                'token': 'operators',
              },
              '@delimiters': <String, Object?>{
                'token': 'delimiter',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@id'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': <String, Object?>{
                'token': 'identifier',
              },
              '@keywords': <String, Object?>{
                'token': 'keyword.\$0',
              },
              '@stringOperators': <String, Object?>{
                'token': 'operators',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\[\\]\\(\\)\\{\\}]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\\(': <String, Object?>{
                'next': '@inParen_auto_dollar.gt',
                'token': '@brackets',
              },
              '\\)': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_auto_dollar': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
              '\\[': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==gt': <String, Object?>{
                    'next': '@inParen_auto_dollar.gt',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'next': '@inParen_auto_dollar.plain',
                    'token': '@brackets',
                  },
                },
              },
              '\\]': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_auto_dollar': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
              '\\{': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==gt': <String, Object?>{
                    'next': '@inParen_auto_dollar.gt',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'next': '@inParen_auto_dollar.plain',
                    'token': '@brackets',
                  },
                },
              },
              '\\}': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_auto_dollar': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '\$S2==interpolation': <String, Object?>{
                    'next': '@popall',
                    'token': '@brackets.interpolation',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$\\{'),
        IExpandedMonarchLanguageAction(
          token: 'delimiter.invalid',
        ),
      ),
      ],
    'expression_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(r?)([\'"])'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '"': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'next': '@doubleString_bracket_dollar',
                  'token': 'string',
                },
              ],
              '\'': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'next': '@singleString_bracket_dollar',
                  'token': 'string',
                },
              ],
              'r"': <Object?>[
                <String, Object?>{
                  'token': 'keyword',
                },
                <String, Object?>{
                  'next': '@rawDoubleString_bracket_dollar',
                  'token': 'string.raw',
                },
              ],
              'r\'': <Object?>[
                <String, Object?>{
                  'token': 'keyword',
                },
                <String, Object?>{
                  'next': '@rawSingleString_bracket_dollar',
                  'token': 'string.raw',
                },
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@integer)(?:\\.(?:@integer))?'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '(?:@integer)': <String, Object?>{
                'token': 'number',
              },
              '@default': <String, Object?>{
                'token': 'number.float',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\.)(@blank*)(@specialHashKeys)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter',
          ),
          IExpandedMonarchLanguageAction(
            token: '',
          ),
          IExpandedMonarchLanguageAction(
            token: 'identifier',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@namedSymbols)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@arrows': <String, Object?>{
                'token': 'meta.arrow',
              },
              '@default': <String, Object?>{
                'token': 'operators',
              },
              '@delimiters': <String, Object?>{
                'token': 'delimiter',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@id'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': <String, Object?>{
                'token': 'identifier',
              },
              '@keywords': <String, Object?>{
                'token': 'keyword.\$0',
              },
              '@stringOperators': <String, Object?>{
                'token': 'operators',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\[\\]\\(\\)\\{\\}]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\\(': <String, Object?>{
                'next': '@inParen_bracket_dollar.gt',
                'token': '@brackets',
              },
              '\\)': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_bracket_dollar': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
              '\\[': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==gt': <String, Object?>{
                    'next': '@inParen_bracket_dollar.gt',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'next': '@inParen_bracket_dollar.plain',
                    'token': '@brackets',
                  },
                },
              },
              '\\]': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_bracket_dollar': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '\$S2==directive': <String, Object?>{
                    'next': '@popall',
                    'token': '@brackets.directive',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
              '\\{': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==gt': <String, Object?>{
                    'next': '@inParen_bracket_dollar.gt',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'next': '@inParen_bracket_dollar.plain',
                    'token': '@brackets',
                  },
                },
              },
              '\\}': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_bracket_dollar': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '\$S2==interpolation': <String, Object?>{
                    'next': '@popall',
                    'token': '@brackets.interpolation',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$\\{'),
        IExpandedMonarchLanguageAction(
          token: 'delimiter.invalid',
        ),
      ),
      ],
    'fmExpression_angle_dollar.directive': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_angle_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_angle_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_angle_dollar',
      ),
      ],
    'fmExpression_angle_dollar.interpolation': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_angle_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_angle_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@greater_operators_token_angle_dollar',
      ),
      ],
    'fmExpression_auto_dollar.directive': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_auto_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_auto_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_auto_dollar',
      ),
      ],
    'fmExpression_auto_dollar.interpolation': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_auto_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_auto_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@greater_operators_token_auto_dollar',
      ),
      ],
    'fmExpression_bracket_dollar.directive': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_bracket_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_bracket_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_bracket_dollar',
      ),
      ],
    'fmExpression_bracket_dollar.interpolation': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_bracket_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_bracket_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@greater_operators_token_bracket_dollar',
      ),
      ],
    'greater_operators_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>='),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
      ],
    'greater_operators_token_auto_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>='),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
      ],
    'greater_operators_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>='),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
      ],
    'inParen_angle_dollar.gt': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_angle_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_angle_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@greater_operators_token_angle_dollar',
      ),
      ],
    'inParen_angle_dollar.plain': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_angle_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_angle_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_angle_dollar',
      ),
      ],
    'inParen_auto_dollar.gt': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_auto_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_auto_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@greater_operators_token_auto_dollar',
      ),
      ],
    'inParen_auto_dollar.plain': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_auto_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_auto_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_auto_dollar',
      ),
      ],
    'inParen_bracket_dollar.gt': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_bracket_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_bracket_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@greater_operators_token_bracket_dollar',
      ),
      ],
    'inParen_bracket_dollar.plain': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_bracket_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_bracket_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_bracket_dollar',
      ),
      ],
    'interpolation_and_text_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@iOpen1_angle_dollar)(@iOpen2_angle_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter.interpolation',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_angle_dollar.interpolation',
            token: '@brackets.interpolation',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\\$#<\\[\\{]|(?:@blank)+|[^\\\$<#\\[\\{\\n\\r\\t ]+'),
        IExpandedMonarchLanguageAction(
          token: 'source',
        ),
      ),
      ],
    'interpolation_and_text_token_auto_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@iOpen1_auto_dollar)(@iOpen2_auto_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter.interpolation',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_auto_dollar.interpolation',
            token: '@brackets.interpolation',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\\$#<\\[\\{]|(?:@blank)+|[^\\\$<#\\[\\{\\n\\r\\t ]+'),
        IExpandedMonarchLanguageAction(
          token: 'source',
        ),
      ),
      ],
    'interpolation_and_text_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@iOpen1_bracket_dollar)(@iOpen2_bracket_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter.interpolation',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_bracket_dollar.interpolation',
            token: '@brackets.interpolation',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\\$#<\\[\\{]|(?:@blank)+|[^\\\$<#\\[\\{\\n\\r\\t ]+'),
        IExpandedMonarchLanguageAction(
          token: 'source',
        ),
      ),
      ],
    'noParse_angle_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@no_parse_token_angle_dollar',
      ),
      ],
    'noParse_auto_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@no_parse_token_auto_dollar',
      ),
      ],
    'noParse_bracket_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@no_parse_token_bracket_dollar',
      ),
      ],
    'noSpaceExpression_angle_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@no_space_expression_end_token_angle_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_angle_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_angle_dollar',
      ),
      ],
    'noSpaceExpression_auto_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@no_space_expression_end_token_auto_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_auto_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_auto_dollar',
      ),
      ],
    'noSpaceExpression_bracket_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@no_space_expression_end_token_bracket_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_bracket_dollar',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_bracket_dollar',
      ),
      ],
    'no_parse_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@open_angle_dollar)(\\/#?)([a-zA-Z]+)((?:@blank)*)(@close_angle_dollar)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==\$3': <Object?>[
                <String, Object?>{
                  'token': '@brackets.directive',
                },
                <String, Object?>{
                  'token': 'delimiter.directive',
                },
                <String, Object?>{
                  'token': 'tag',
                },
                <String, Object?>{
                  'token': '',
                },
                <String, Object?>{
                  'next': '@popall',
                  'token': '@brackets.directive',
                },
              ],
              '\$S2==comment': <Object?>[
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
              ],
              '@default': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<\\[\\-]+|[<\\[\\-]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==comment': <String, Object?>{
                'token': 'comment',
              },
              '@default': <String, Object?>{
                'token': 'source',
              },
            },
        ),
      ),
      ],
    'no_parse_token_auto_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@open_auto_dollar)(\\/#?)([a-zA-Z]+)((?:@blank)*)(@close_auto_dollar)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==\$3': <Object?>[
                <String, Object?>{
                  'token': '@brackets.directive',
                },
                <String, Object?>{
                  'token': 'delimiter.directive',
                },
                <String, Object?>{
                  'token': 'tag',
                },
                <String, Object?>{
                  'token': '',
                },
                <String, Object?>{
                  'next': '@popall',
                  'token': '@brackets.directive',
                },
              ],
              '\$S2==comment': <Object?>[
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
              ],
              '@default': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<\\[\\-]+|[<\\[\\-]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==comment': <String, Object?>{
                'token': 'comment',
              },
              '@default': <String, Object?>{
                'token': 'source',
              },
            },
        ),
      ),
      ],
    'no_parse_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@open_bracket_dollar)(\\/#?)([a-zA-Z]+)((?:@blank)*)(@close_bracket_dollar)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==\$3': <Object?>[
                <String, Object?>{
                  'token': '@brackets.directive',
                },
                <String, Object?>{
                  'token': 'delimiter.directive',
                },
                <String, Object?>{
                  'token': 'tag',
                },
                <String, Object?>{
                  'token': '',
                },
                <String, Object?>{
                  'next': '@popall',
                  'token': '@brackets.directive',
                },
              ],
              '\$S2==comment': <Object?>[
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
              ],
              '@default': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<\\[\\-]+|[<\\[\\-]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==comment': <String, Object?>{
                'token': 'comment',
              },
              '@default': <String, Object?>{
                'token': 'source',
              },
            },
        ),
      ),
      ],
    'no_space_expression_end_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@blank)+'),
        IExpandedMonarchLanguageAction(
          switchTo: '@fmExpression_angle_dollar.directive',
          token: '',
        ),
      ),
      ],
    'no_space_expression_end_token_auto_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@blank)+'),
        IExpandedMonarchLanguageAction(
          switchTo: '@fmExpression_auto_dollar.directive',
          token: '',
        ),
      ),
      ],
    'no_space_expression_end_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@blank)+'),
        IExpandedMonarchLanguageAction(
          switchTo: '@fmExpression_bracket_dollar.directive',
          token: '',
        ),
      ),
      ],
    'rawDoubleString_angle_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_double_raw_token_angle_dollar',
      ),
      ],
    'rawDoubleString_auto_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_double_raw_token_auto_dollar',
      ),
      ],
    'rawDoubleString_bracket_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_double_raw_token_bracket_dollar',
      ),
      ],
    'rawSingleString_angle_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_single_raw_token_angle_dollar',
      ),
      ],
    'rawSingleString_auto_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_single_raw_token_auto_dollar',
      ),
      ],
    'rawSingleString_bracket_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_single_raw_token_bracket_dollar',
      ),
      ],
    'singleString_angle_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_single_token_angle_dollar',
      ),
      ],
    'singleString_auto_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_single_token_auto_dollar',
      ),
      ],
    'singleString_bracket_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_single_token_bracket_dollar',
      ),
      ],
    'string_double_raw_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"]+'),
        IExpandedMonarchLanguageAction(
          token: 'string.raw',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.raw',
        ),
      ),
      ],
    'string_double_raw_token_auto_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"]+'),
        IExpandedMonarchLanguageAction(
          token: 'string.raw',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.raw',
        ),
      ),
      ],
    'string_double_raw_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"]+'),
        IExpandedMonarchLanguageAction(
          token: 'string.raw',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.raw',
        ),
      ),
      ],
    'string_double_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"\\\\]'),
        IExpandedMonarchLanguageAction(
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapedChar'),
        IExpandedMonarchLanguageAction(
          token: 'string.escape',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
      ],
    'string_double_token_auto_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"\\\\]'),
        IExpandedMonarchLanguageAction(
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapedChar'),
        IExpandedMonarchLanguageAction(
          token: 'string.escape',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
      ],
    'string_double_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"\\\\]'),
        IExpandedMonarchLanguageAction(
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapedChar'),
        IExpandedMonarchLanguageAction(
          token: 'string.escape',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
      ],
    'string_single_raw_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\']+'),
        IExpandedMonarchLanguageAction(
          token: 'string.raw',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.raw',
        ),
      ),
      ],
    'string_single_raw_token_auto_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\']+'),
        IExpandedMonarchLanguageAction(
          token: 'string.raw',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.raw',
        ),
      ),
      ],
    'string_single_raw_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\']+'),
        IExpandedMonarchLanguageAction(
          token: 'string.raw',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.raw',
        ),
      ),
      ],
    'string_single_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\'\\\\]'),
        IExpandedMonarchLanguageAction(
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapedChar'),
        IExpandedMonarchLanguageAction(
          token: 'string.escape',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
      ],
    'string_single_token_auto_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\'\\\\]'),
        IExpandedMonarchLanguageAction(
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapedChar'),
        IExpandedMonarchLanguageAction(
          token: 'string.escape',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
      ],
    'string_single_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\'\\\\]'),
        IExpandedMonarchLanguageAction(
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapedChar'),
        IExpandedMonarchLanguageAction(
          token: 'string.escape',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
      ],
    'terseComment_angle_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@terse_comment_token_angle_dollar',
      ),
      ],
    'terseComment_auto_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@terse_comment_token_auto_dollar',
      ),
      ],
    'terseComment_bracket_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@terse_comment_token_bracket_dollar',
      ),
      ],
    'terse_comment_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('--(?:@close_angle_dollar)'),
        IExpandedMonarchLanguageAction(
          next: '@popall',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<\\[\\-]+|[<\\[\\-]'),
        IExpandedMonarchLanguageAction(
          token: 'comment',
        ),
      ),
      ],
    'terse_comment_token_auto_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('--(?:@close_auto_dollar)'),
        IExpandedMonarchLanguageAction(
          next: '@popall',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<\\[\\-]+|[<\\[\\-]'),
        IExpandedMonarchLanguageAction(
          token: 'comment',
        ),
      ),
      ],
    'terse_comment_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('--(?:@close_bracket_dollar)'),
        IExpandedMonarchLanguageAction(
          next: '@popall',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<\\[\\-]+|[<\\[\\-]'),
        IExpandedMonarchLanguageAction(
          token: 'comment',
        ),
      ),
      ],
    'unifiedCall_angle_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@unified_call_token_angle_dollar',
      ),
      ],
    'unifiedCall_auto_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@unified_call_token_auto_dollar',
      ),
      ],
    'unifiedCall_bracket_dollar': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@unified_call_token_bracket_dollar',
      ),
      ],
    'unified_call_token_angle_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@id)((?:@blank)+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_angle_dollar.directive',
            token: '',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@id)(\\/?)(@close_angle_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@popall',
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IExpandedMonarchLanguageAction(
          next: '@noSpaceExpression_angle_dollar',
          token: '@rematch',
        ),
      ),
      ],
    'unified_call_token_auto_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@id)((?:@blank)+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_auto_dollar.directive',
            token: '',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@id)(\\/?)(@close_auto_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@popall',
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IExpandedMonarchLanguageAction(
          next: '@noSpaceExpression_auto_dollar',
          token: '@rematch',
        ),
      ),
      ],
    'unified_call_token_bracket_dollar': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@id)((?:@blank)+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_bracket_dollar.directive',
            token: '',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@id)(\\/?)(@close_bracket_dollar)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@popall',
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IExpandedMonarchLanguageAction(
          next: '@noSpaceExpression_bracket_dollar',
          token: '@rematch',
        ),
      ),
      ],
  },
    ignoreCase: false,
    unicode: true,
    defaultToken: 'invalid',
    brackets: <IMonarchLanguageBracket>[
      IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
      IMonarchLanguageBracket('[', ']', 'delimiter.square'),
      IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
      IMonarchLanguageBracket('<', '>', 'delimiter.angle'),
    ],
    start: 'default_auto_dollar',
    tokenPostfix: '.freemarker2',
    includeLF: false,
    extra: <String, Object?>{
          'arrows': <Object?>[
            '->',
            '-&gt;',
          ],
          'asciiDigit': RegExp('[0-9]'),
          'blank': RegExp('[ \\t\\n\\r]'),
          'closeTag1_angle_dollar': RegExp('((?:@blank)*)(@close_angle_dollar)'),
          'closeTag1_auto_dollar': RegExp('((?:@blank)*)(@close_auto_dollar)'),
          'closeTag1_bracket_dollar': RegExp('((?:@blank)*)(@close_bracket_dollar)'),
          'closeTag2_angle_dollar': RegExp('((?:@blank)*\\/?)(@close_angle_dollar)'),
          'closeTag2_auto_dollar': RegExp('((?:@blank)*\\/?)(@close_auto_dollar)'),
          'closeTag2_bracket_dollar': RegExp('((?:@blank)*\\/?)(@close_bracket_dollar)'),
          'close_angle_dollar': RegExp('>'),
          'close_auto_dollar': RegExp('[>\\]]'),
          'close_bracket_dollar': RegExp('\\]'),
          'delimiters': <Object?>[
            ';',
            ':',
            ',',
            '.',
          ],
          'directiveEndCloseTag1': RegExp('if|list|items|sep|recover|attempt|for[eE]ach|local|global|assign|function|macro|output[fF]ormat|auto[eE]sc|no(?:autoe|AutoE)sc|compress|transform|switch|escape|no[eE]scape'),
          'directiveStartBlank': RegExp('if|else[iI]f|list|for[eE]ach|switch|case|assign|global|local|include|import|function|macro|transform|visit|stop|return|call|setting|output[fF]ormat|nested|recurse|escape|ftl|items'),
          'directiveStartCloseTag1': RegExp('attempt|recover|sep|auto[eE]sc|no(?:autoe|AutoE)sc|compress|default|no[eE]scape|comment|no[pP]arse'),
          'directiveStartCloseTag2': RegExp('else|break|continue|return|stop|flush|t|lt|rt|nt|nested|recurse|fallback|ftl'),
          'endTag_angle_dollar': RegExp('(@open_angle_dollar)(\\/#)'),
          'endTag_auto_dollar': RegExp('(@open_auto_dollar)(\\/#)'),
          'endTag_bracket_dollar': RegExp('(@open_bracket_dollar)(\\/#)'),
          'escapedChar': RegExp('\\\\(?:[ntrfbgla\\\\\'"\\{=]|(?:x[0-9A-Fa-f]{1,4}))'),
          'escapedIdChar': RegExp('\\\\[\\-\\.:#]'),
          'iClose_angle_dollar': RegExp('\\}'),
          'iClose_auto_dollar': RegExp('\\}'),
          'iClose_bracket_dollar': RegExp('\\}'),
          'iOpen1_angle_dollar': RegExp('\\\$'),
          'iOpen1_auto_dollar': RegExp('\\\$'),
          'iOpen1_bracket_dollar': RegExp('\\\$'),
          'iOpen2_angle_dollar': RegExp('\\{'),
          'iOpen2_auto_dollar': RegExp('\\{'),
          'iOpen2_bracket_dollar': RegExp('\\{'),
          'id': RegExp('(?:@idStartChar)(?:(?:@idStartChar)|(?:@asciiDigit))*'),
          'idStartChar': RegExp('(?:@nonEscapedIdStartChar)|(?:@escapedIdChar)'),
          'integer': RegExp('[0-9]+'),
          'keywords': <Object?>[
            'false',
            'true',
            'in',
            'as',
            'using',
          ],
          'namedSymbols': RegExp('&lt;=|&gt;=|\\\\lte|\\\\lt|&lt;|\\\\gte|\\\\gt|&gt;|&amp;&amp;|\\\\and|-&gt;|->|==|!=|\\+=|-=|\\*=|\\/=|%=|\\+\\+|--|<=|&&|\\|\\||:|\\.\\.\\.|\\.\\.\\*|\\.\\.<|\\.\\.!|\\?\\?|=|<|\\+|-|\\*|\\/|%|\\||\\.\\.|\\?|!|&|\\.|,|;'),
          'noParseTags': <Object?>[
            'noparse',
            'noParse',
            'comment',
          ],
          'nonEscapedIdStartChar': RegExp('[\\\$@-Z_a-z\\u00AA\\u00B5\\u00BA\\u00C0-\\u00D6\\u00D8-\\u00F6\\u00F8-\\u1FFF\\u2071\\u207F\\u2090-\\u209C\\u2102\\u2107\\u210A-\\u2113\\u2115\\u2119-\\u211D\\u2124\\u2126\\u2128\\u212A-\\u212D\\u212F-\\u2139\\u213C-\\u213F\\u2145-\\u2149\\u214E\\u2183-\\u2184\\u2C00-\\u2C2E\\u2C30-\\u2C5E\\u2C60-\\u2CE4\\u2CEB-\\u2CEE\\u2CF2-\\u2CF3\\u2D00-\\u2D25\\u2D27\\u2D2D\\u2D30-\\u2D67\\u2D6F\\u2D80-\\u2D96\\u2DA0-\\u2DA6\\u2DA8-\\u2DAE\\u2DB0-\\u2DB6\\u2DB8-\\u2DBE\\u2DC0-\\u2DC6\\u2DC8-\\u2DCE\\u2DD0-\\u2DD6\\u2DD8-\\u2DDE\\u2E2F\\u3005-\\u3006\\u3031-\\u3035\\u303B-\\u303C\\u3040-\\u318F\\u31A0-\\u31BA\\u31F0-\\u31FF\\u3300-\\u337F\\u3400-\\u4DB5\\u4E00-\\uA48C\\uA4D0-\\uA4FD\\uA500-\\uA60C\\uA610-\\uA62B\\uA640-\\uA66E\\uA67F-\\uA697\\uA6A0-\\uA6E5\\uA717-\\uA71F\\uA722-\\uA788\\uA78B-\\uA78E\\uA790-\\uA793\\uA7A0-\\uA7AA\\uA7F8-\\uA801\\uA803-\\uA805\\uA807-\\uA80A\\uA80C-\\uA822\\uA840-\\uA873\\uA882-\\uA8B3\\uA8D0-\\uA8D9\\uA8F2-\\uA8F7\\uA8FB\\uA900-\\uA925\\uA930-\\uA946\\uA960-\\uA97C\\uA984-\\uA9B2\\uA9CF-\\uA9D9\\uAA00-\\uAA28\\uAA40-\\uAA42\\uAA44-\\uAA4B\\uAA50-\\uAA59\\uAA60-\\uAA76\\uAA7A\\uAA80-\\uAAAF\\uAAB1\\uAAB5-\\uAAB6\\uAAB9-\\uAABD\\uAAC0\\uAAC2\\uAADB-\\uAADD\\uAAE0-\\uAAEA\\uAAF2-\\uAAF4\\uAB01-\\uAB06\\uAB09-\\uAB0E\\uAB11-\\uAB16\\uAB20-\\uAB26\\uAB28-\\uAB2E\\uABC0-\\uABE2\\uABF0-\\uABF9\\uAC00-\\uD7A3\\uD7B0-\\uD7C6\\uD7CB-\\uD7FB\\uF900-\\uFB06\\uFB13-\\uFB17\\uFB1D\\uFB1F-\\uFB28\\uFB2A-\\uFB36\\uFB38-\\uFB3C\\uFB3E\\uFB40-\\uFB41\\uFB43-\\uFB44\\uFB46-\\uFBB1\\uFBD3-\\uFD3D\\uFD50-\\uFD8F\\uFD92-\\uFDC7\\uFDF0-\\uFDFB\\uFE70-\\uFE74\\uFE76-\\uFEFC\\uFF10-\\uFF19\\uFF21-\\uFF3A\\uFF41-\\uFF5A\\uFF66-\\uFFBE\\uFFC2-\\uFFC7\\uFFCA-\\uFFCF\\uFFD2-\\uFFD7\\uFFDA-\\uFFDC]'),
          'open_angle_dollar': RegExp('<'),
          'open_auto_dollar': RegExp('[<\\[]'),
          'open_bracket_dollar': RegExp('\\['),
          'specialHashKeys': RegExp('\\*\\*|\\*|false|true|in|as|using'),
          'startOrEndTag_angle_dollar': RegExp('(@open_angle_dollar)(\\/?#)'),
          'startOrEndTag_auto_dollar': RegExp('(@open_auto_dollar)(\\/?#)'),
          'startOrEndTag_bracket_dollar': RegExp('(@open_bracket_dollar)(\\/?#)'),
          'startTag_angle_dollar': RegExp('(@open_angle_dollar)(#)'),
          'startTag_auto_dollar': RegExp('(@open_auto_dollar)(#)'),
          'startTag_bracket_dollar': RegExp('(@open_bracket_dollar)(#)'),
          'stringOperators': <Object?>[
            'lte',
            'lt',
            'gte',
            'gt',
          ],
        },
  ),
);

/// 1:1: `export const TagAutoInterpolationBracket = { conf, language }`
final class TagAutoInterpolationBracketDef {
  final Map<String, Object?> conf;
  final IMonarchLanguage language;
  TagAutoInterpolationBracketDef(this.conf, this.language);
}

final TagAutoInterpolationBracketDef TagAutoInterpolationBracket = TagAutoInterpolationBracketDef(
  <String, Object?>{
      'autoCloseBefore': '\n\r\t }]),.:;=',
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
          ],
          'open': '\'',
        },
      ],
      'brackets': <Object?>[
        <Object?>[
          '<',
          '>',
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
          '{',
          '}',
        ],
      ],
      'folding': <String, Object?>{
        'markers': <String, Object?>{
          'end': RegExp('[<\\[]\\/#(?:attempt|autoesc|autoEsc|compress|comment|escape|noescape|function|if|list|items|sep|macro|noparse|noParse|noautoesc|noAutoEsc|outputformat|switch|visit|recurse)[\\r\\n\\t ]*>'),
          'start': RegExp('[<\\[]#(?:attempt|autoesc|autoEsc|compress|comment|escape|noescape|function|if|list|items|sep|macro|noparse|noParse|noautoesc|noAutoEsc|outputformat|switch|visit|recurse)([^/>\\]]*(?!\\/)[>\\]])[^<\\[]*\$'),
        },
      },
      'onEnterRules': <Object?>[
        <String, Object?>{
          'action': <String, Object?>{
            'indentAction': 2,
          },
          'afterText': RegExp('^[<\\[]\\/#([a-zA-Z_]+)[\\r\\n\\t ]*[>\\]]\$'),
          'beforeText': RegExp('[<\\[]#(?!(?:assign|flush|ftl|return|global|import|include|break|continue|local|nested|nt|setting|stop|t|lt|rt|fallback))([a-zA-Z_]+)([^/>\\]]*(?!\\/)[>\\]])[^[<\\[]]*\$'),
        },
        <String, Object?>{
          'action': <String, Object?>{
            'indentAction': 1,
          },
          'beforeText': RegExp('[<\\[]#(?!(?:assign|flush|ftl|return|global|import|include|break|continue|local|nested|nt|setting|stop|t|lt|rt|fallback))([a-zA-Z_]+)([^/>\\]]*(?!\\/)[>\\]])[^[<\\[]]*\$'),
        },
      ],
      'surroundingPairs': <Object?>[
        <String, Object?>{
          'close': '"',
          'open': '"',
        },
        <String, Object?>{
          'close': '\'',
          'open': '\'',
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
        <String, Object?>{
          'close': '>',
          'open': '<',
        },
      ],
    },
  IMonarchLanguage(tokenizer: <String, List<IMonarchLanguageRule>>{
    'blank_and_expression_comment_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@blank)+'),
        IExpandedMonarchLanguageAction(
          token: '',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[<\\[][#!]--'),
        IExpandedMonarchLanguageAction(
          next: '@expressionComment_angle_bracket',
          token: 'comment',
        ),
      ),
      ],
    'blank_and_expression_comment_token_auto_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@blank)+'),
        IExpandedMonarchLanguageAction(
          token: '',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[<\\[][#!]--'),
        IExpandedMonarchLanguageAction(
          next: '@expressionComment_auto_bracket',
          token: 'comment',
        ),
      ),
      ],
    'blank_and_expression_comment_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@blank)+'),
        IExpandedMonarchLanguageAction(
          token: '',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[<\\[][#!]--'),
        IExpandedMonarchLanguageAction(
          next: '@expressionComment_bracket_bracket',
          token: 'comment',
        ),
      ),
      ],
    'default_angle_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@directive_token_angle_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@interpolation_and_text_token_angle_bracket',
      ),
      ],
    'default_auto_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@directive_token_auto_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@interpolation_and_text_token_auto_bracket',
      ),
      ],
    'default_bracket_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@directive_token_bracket_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@interpolation_and_text_token_bracket_bracket',
      ),
      ],
    'directive_end_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@popall',
          token: '@brackets.directive',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\/)(@close_angle_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@popall',
            token: '@brackets.directive',
          ),
        ]),
      ),
      ],
    'directive_end_token_auto_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@popall',
          token: '@brackets.directive',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\/)(@close_auto_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@popall',
            token: '@brackets.directive',
          ),
        ]),
      ),
      ],
    'directive_end_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\/)(@close_bracket_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@popall',
            token: '@brackets.directive',
          ),
        ]),
      ),
      ],
    'directive_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_angle_bracket)(@directiveStartCloseTag1)(?:@closeTag1_angle_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            cases: <String, Object?>{
                '@default': <String, Object?>{
                  'token': 'tag',
                },
                '@noParseTags': <String, Object?>{
                  'next': '@noParse_angle_bracket.\$3',
                  'token': 'tag',
                },
              },
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_angle_bracket)(@directiveStartCloseTag2)(?:@closeTag2_angle_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_angle_bracket)(@directiveStartBlank)(@blank)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_angle_bracket.directive',
            token: '',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@endTag_angle_bracket)(@directiveEndCloseTag1)(?:@closeTag1_angle_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_angle_bracket)(@)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@unifiedCall_angle_bracket',
            token: 'delimiter.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_angle_bracket)(\\/@)((?:(?:@id)(?:\\.(?:@id))*)?)(?:@closeTag1_angle_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_angle_bracket)#--'),
        IExpandedMonarchLanguageAction(
          next: '@terseComment_angle_bracket',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startOrEndTag_angle_bracket)([a-zA-Z_]+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_angle_bracket.directive',
            token: 'tag.invalid',
          ),
        ]),
      ),
      ],
    'directive_token_auto_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_auto_bracket)(@directiveStartCloseTag1)(?:@closeTag1_auto_bracket)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==<': <String, Object?>{
                'switchTo': '@default_angle_bracket',
                'token': '@rematch',
              },
              '\$1==[': <String, Object?>{
                'switchTo': '@default_bracket_bracket',
                'token': '@rematch',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_auto_bracket)(@directiveStartCloseTag2)(?:@closeTag2_auto_bracket)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==<': <String, Object?>{
                'switchTo': '@default_angle_bracket',
                'token': '@rematch',
              },
              '\$1==[': <String, Object?>{
                'switchTo': '@default_bracket_bracket',
                'token': '@rematch',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_auto_bracket)(@directiveStartBlank)(@blank)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==<': <String, Object?>{
                'switchTo': '@default_angle_bracket',
                'token': '@rematch',
              },
              '\$1==[': <String, Object?>{
                'switchTo': '@default_bracket_bracket',
                'token': '@rematch',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@endTag_auto_bracket)(@directiveEndCloseTag1)(?:@closeTag1_auto_bracket)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==<': <String, Object?>{
                'switchTo': '@default_angle_bracket',
                'token': '@rematch',
              },
              '\$1==[': <String, Object?>{
                'switchTo': '@default_bracket_bracket',
                'token': '@rematch',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_auto_bracket)(@)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==<': <String, Object?>{
                'switchTo': '@default_angle_bracket',
                'token': '@rematch',
              },
              '\$1==[': <String, Object?>{
                'switchTo': '@default_bracket_bracket',
                'token': '@rematch',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_auto_bracket)(\\/@)((?:(?:@id)(?:\\.(?:@id))*)?)(?:@closeTag1_auto_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_auto_bracket)#--'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==<': <String, Object?>{
                'switchTo': '@default_angle_bracket',
                'token': '@rematch',
              },
              '\$1==[': <String, Object?>{
                'switchTo': '@default_bracket_bracket',
                'token': '@rematch',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startOrEndTag_auto_bracket)([a-zA-Z_]+)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$1==<': <String, Object?>{
                'switchTo': '@default_angle_bracket',
                'token': '@rematch',
              },
              '\$1==[': <String, Object?>{
                'switchTo': '@default_bracket_bracket',
                'token': '@rematch',
              },
            },
        ),
      ),
      ],
    'directive_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_bracket_bracket)(@directiveStartCloseTag1)(?:@closeTag1_bracket_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            cases: <String, Object?>{
                '@default': <String, Object?>{
                  'token': 'tag',
                },
                '@noParseTags': <String, Object?>{
                  'next': '@noParse_bracket_bracket.\$3',
                  'token': 'tag',
                },
              },
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_bracket_bracket)(@directiveStartCloseTag2)(?:@closeTag2_bracket_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startTag_bracket_bracket)(@directiveStartBlank)(@blank)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_bracket_bracket.directive',
            token: '',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@endTag_bracket_bracket)(@directiveEndCloseTag1)(?:@closeTag1_bracket_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_bracket_bracket)(@)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@unifiedCall_bracket_bracket',
            token: 'delimiter.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_bracket_bracket)(\\/@)((?:(?:@id)(?:\\.(?:@id))*)?)(?:@closeTag1_bracket_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@open_bracket_bracket)#--'),
        IExpandedMonarchLanguageAction(
          next: '@terseComment_bracket_bracket',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@startOrEndTag_bracket_bracket)([a-zA-Z_]+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.directive',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_bracket_bracket.directive',
            token: 'tag.invalid',
          ),
        ]),
      ),
      ],
    'doubleString_angle_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_double_token_angle_bracket',
      ),
      ],
    'doubleString_auto_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_double_token_auto_bracket',
      ),
      ],
    'doubleString_bracket_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_double_token_bracket_bracket',
      ),
      ],
    'expressionComment_angle_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@expression_comment_token_angle_bracket',
      ),
      ],
    'expressionComment_auto_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@expression_comment_token_auto_bracket',
      ),
      ],
    'expressionComment_bracket_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@expression_comment_token_bracket_bracket',
      ),
      ],
    'expression_comment_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('--[>\\]]'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\->\\]]+|[>\\]\\-]'),
        IExpandedMonarchLanguageAction(
          token: 'comment',
        ),
      ),
      ],
    'expression_comment_token_auto_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('--[>\\]]'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\->\\]]+|[>\\]\\-]'),
        IExpandedMonarchLanguageAction(
          token: 'comment',
        ),
      ),
      ],
    'expression_comment_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('--[>\\]]'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\->\\]]+|[>\\]\\-]'),
        IExpandedMonarchLanguageAction(
          token: 'comment',
        ),
      ),
      ],
    'expression_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(r?)([\'"])'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '"': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'next': '@doubleString_angle_bracket',
                  'token': 'string',
                },
              ],
              '\'': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'next': '@singleString_angle_bracket',
                  'token': 'string',
                },
              ],
              'r"': <Object?>[
                <String, Object?>{
                  'token': 'keyword',
                },
                <String, Object?>{
                  'next': '@rawDoubleString_angle_bracket',
                  'token': 'string.raw',
                },
              ],
              'r\'': <Object?>[
                <String, Object?>{
                  'token': 'keyword',
                },
                <String, Object?>{
                  'next': '@rawSingleString_angle_bracket',
                  'token': 'string.raw',
                },
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@integer)(?:\\.(?:@integer))?'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '(?:@integer)': <String, Object?>{
                'token': 'number',
              },
              '@default': <String, Object?>{
                'token': 'number.float',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\.)(@blank*)(@specialHashKeys)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter',
          ),
          IExpandedMonarchLanguageAction(
            token: '',
          ),
          IExpandedMonarchLanguageAction(
            token: 'identifier',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@namedSymbols)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@arrows': <String, Object?>{
                'token': 'meta.arrow',
              },
              '@default': <String, Object?>{
                'token': 'operators',
              },
              '@delimiters': <String, Object?>{
                'token': 'delimiter',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@id'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': <String, Object?>{
                'token': 'identifier',
              },
              '@keywords': <String, Object?>{
                'token': 'keyword.\$0',
              },
              '@stringOperators': <String, Object?>{
                'token': 'operators',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\[\\]\\(\\)\\{\\}]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\\(': <String, Object?>{
                'next': '@inParen_angle_bracket.gt',
                'token': '@brackets',
              },
              '\\)': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_angle_bracket': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
              '\\[': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==gt': <String, Object?>{
                    'next': '@inParen_angle_bracket.gt',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'next': '@inParen_angle_bracket.plain',
                    'token': '@brackets',
                  },
                },
              },
              '\\]': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_angle_bracket': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '\$S2==interpolation': <String, Object?>{
                    'next': '@popall',
                    'token': '@brackets.interpolation',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
              '\\{': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==gt': <String, Object?>{
                    'next': '@inParen_angle_bracket.gt',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'next': '@inParen_angle_bracket.plain',
                    'token': '@brackets',
                  },
                },
              },
              '\\}': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_angle_bracket': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$\\{'),
        IExpandedMonarchLanguageAction(
          token: 'delimiter.invalid',
        ),
      ),
      ],
    'expression_token_auto_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(r?)([\'"])'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '"': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'next': '@doubleString_auto_bracket',
                  'token': 'string',
                },
              ],
              '\'': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'next': '@singleString_auto_bracket',
                  'token': 'string',
                },
              ],
              'r"': <Object?>[
                <String, Object?>{
                  'token': 'keyword',
                },
                <String, Object?>{
                  'next': '@rawDoubleString_auto_bracket',
                  'token': 'string.raw',
                },
              ],
              'r\'': <Object?>[
                <String, Object?>{
                  'token': 'keyword',
                },
                <String, Object?>{
                  'next': '@rawSingleString_auto_bracket',
                  'token': 'string.raw',
                },
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@integer)(?:\\.(?:@integer))?'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '(?:@integer)': <String, Object?>{
                'token': 'number',
              },
              '@default': <String, Object?>{
                'token': 'number.float',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\.)(@blank*)(@specialHashKeys)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter',
          ),
          IExpandedMonarchLanguageAction(
            token: '',
          ),
          IExpandedMonarchLanguageAction(
            token: 'identifier',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@namedSymbols)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@arrows': <String, Object?>{
                'token': 'meta.arrow',
              },
              '@default': <String, Object?>{
                'token': 'operators',
              },
              '@delimiters': <String, Object?>{
                'token': 'delimiter',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@id'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': <String, Object?>{
                'token': 'identifier',
              },
              '@keywords': <String, Object?>{
                'token': 'keyword.\$0',
              },
              '@stringOperators': <String, Object?>{
                'token': 'operators',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\[\\]\\(\\)\\{\\}]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\\(': <String, Object?>{
                'next': '@inParen_auto_bracket.gt',
                'token': '@brackets',
              },
              '\\)': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_auto_bracket': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
              '\\[': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==gt': <String, Object?>{
                    'next': '@inParen_auto_bracket.gt',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'next': '@inParen_auto_bracket.plain',
                    'token': '@brackets',
                  },
                },
              },
              '\\]': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_auto_bracket': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '\$S2==interpolation': <String, Object?>{
                    'next': '@popall',
                    'token': '@brackets.interpolation',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
              '\\{': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==gt': <String, Object?>{
                    'next': '@inParen_auto_bracket.gt',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'next': '@inParen_auto_bracket.plain',
                    'token': '@brackets',
                  },
                },
              },
              '\\}': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_auto_bracket': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$\\{'),
        IExpandedMonarchLanguageAction(
          token: 'delimiter.invalid',
        ),
      ),
      ],
    'expression_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(r?)([\'"])'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '"': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'next': '@doubleString_bracket_bracket',
                  'token': 'string',
                },
              ],
              '\'': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'next': '@singleString_bracket_bracket',
                  'token': 'string',
                },
              ],
              'r"': <Object?>[
                <String, Object?>{
                  'token': 'keyword',
                },
                <String, Object?>{
                  'next': '@rawDoubleString_bracket_bracket',
                  'token': 'string.raw',
                },
              ],
              'r\'': <Object?>[
                <String, Object?>{
                  'token': 'keyword',
                },
                <String, Object?>{
                  'next': '@rawSingleString_bracket_bracket',
                  'token': 'string.raw',
                },
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@integer)(?:\\.(?:@integer))?'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '(?:@integer)': <String, Object?>{
                'token': 'number',
              },
              '@default': <String, Object?>{
                'token': 'number.float',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\.)(@blank*)(@specialHashKeys)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'delimiter',
          ),
          IExpandedMonarchLanguageAction(
            token: '',
          ),
          IExpandedMonarchLanguageAction(
            token: 'identifier',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(?:@namedSymbols)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@arrows': <String, Object?>{
                'token': 'meta.arrow',
              },
              '@default': <String, Object?>{
                'token': 'operators',
              },
              '@delimiters': <String, Object?>{
                'token': 'delimiter',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@id'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': <String, Object?>{
                'token': 'identifier',
              },
              '@keywords': <String, Object?>{
                'token': 'keyword.\$0',
              },
              '@stringOperators': <String, Object?>{
                'token': 'operators',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\[\\]\\(\\)\\{\\}]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\\(': <String, Object?>{
                'next': '@inParen_bracket_bracket.gt',
                'token': '@brackets',
              },
              '\\)': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_bracket_bracket': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
              '\\[': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==gt': <String, Object?>{
                    'next': '@inParen_bracket_bracket.gt',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'next': '@inParen_bracket_bracket.plain',
                    'token': '@brackets',
                  },
                },
              },
              '\\]': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_bracket_bracket': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '\$S2==directive': <String, Object?>{
                    'next': '@popall',
                    'token': '@brackets.directive',
                  },
                  '\$S2==interpolation': <String, Object?>{
                    'next': '@popall',
                    'token': '@brackets.interpolation',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
              '\\{': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S2==gt': <String, Object?>{
                    'next': '@inParen_bracket_bracket.gt',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'next': '@inParen_bracket_bracket.plain',
                    'token': '@brackets',
                  },
                },
              },
              '\\}': <String, Object?>{
                'cases': <String, Object?>{
                  '\$S1==inParen_bracket_bracket': <String, Object?>{
                    'next': '@pop',
                    'token': '@brackets',
                  },
                  '@default': <String, Object?>{
                    'token': '@brackets',
                  },
                },
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\$\\{'),
        IExpandedMonarchLanguageAction(
          token: 'delimiter.invalid',
        ),
      ),
      ],
    'fmExpression_angle_bracket.directive': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_angle_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_angle_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_angle_bracket',
      ),
      ],
    'fmExpression_angle_bracket.interpolation': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_angle_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_angle_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@greater_operators_token_angle_bracket',
      ),
      ],
    'fmExpression_auto_bracket.directive': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_auto_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_auto_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_auto_bracket',
      ),
      ],
    'fmExpression_auto_bracket.interpolation': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_auto_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_auto_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@greater_operators_token_auto_bracket',
      ),
      ],
    'fmExpression_bracket_bracket.directive': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_bracket_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_bracket_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_bracket_bracket',
      ),
      ],
    'fmExpression_bracket_bracket.interpolation': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_bracket_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_bracket_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@greater_operators_token_bracket_bracket',
      ),
      ],
    'greater_operators_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>='),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
      ],
    'greater_operators_token_auto_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>='),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
      ],
    'greater_operators_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>='),
        IExpandedMonarchLanguageAction(
          token: 'operators',
        ),
      ),
      ],
    'inParen_angle_bracket.gt': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_angle_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_angle_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@greater_operators_token_angle_bracket',
      ),
      ],
    'inParen_angle_bracket.plain': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_angle_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_angle_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_angle_bracket',
      ),
      ],
    'inParen_auto_bracket.gt': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_auto_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_auto_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@greater_operators_token_auto_bracket',
      ),
      ],
    'inParen_auto_bracket.plain': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_auto_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_auto_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_auto_bracket',
      ),
      ],
    'inParen_bracket_bracket.gt': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_bracket_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_bracket_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@greater_operators_token_bracket_bracket',
      ),
      ],
    'inParen_bracket_bracket.plain': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@blank_and_expression_comment_token_bracket_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_bracket_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_bracket_bracket',
      ),
      ],
    'interpolation_and_text_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@iOpen1_angle_bracket)(@iOpen2_angle_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.interpolation',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_angle_bracket.interpolation',
            token: 'delimiter.interpolation',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\\$#<\\[\\{]|(?:@blank)+|[^\\\$<#\\[\\{\\n\\r\\t ]+'),
        IExpandedMonarchLanguageAction(
          token: 'source',
        ),
      ),
      ],
    'interpolation_and_text_token_auto_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@iOpen1_auto_bracket)(@iOpen2_auto_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.interpolation',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_auto_bracket.interpolation',
            token: 'delimiter.interpolation',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\\$#<\\[\\{]|(?:@blank)+|[^\\\$<#\\[\\{\\n\\r\\t ]+'),
        IExpandedMonarchLanguageAction(
          token: 'source',
        ),
      ),
      ],
    'interpolation_and_text_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@iOpen1_bracket_bracket)(@iOpen2_bracket_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: '@brackets.interpolation',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_bracket_bracket.interpolation',
            token: 'delimiter.interpolation',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\\$#<\\[\\{]|(?:@blank)+|[^\\\$<#\\[\\{\\n\\r\\t ]+'),
        IExpandedMonarchLanguageAction(
          token: 'source',
        ),
      ),
      ],
    'noParse_angle_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@no_parse_token_angle_bracket',
      ),
      ],
    'noParse_auto_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@no_parse_token_auto_bracket',
      ),
      ],
    'noParse_bracket_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@no_parse_token_bracket_bracket',
      ),
      ],
    'noSpaceExpression_angle_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@no_space_expression_end_token_angle_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_angle_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_angle_bracket',
      ),
      ],
    'noSpaceExpression_auto_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@no_space_expression_end_token_auto_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_auto_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_auto_bracket',
      ),
      ],
    'noSpaceExpression_bracket_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@no_space_expression_end_token_bracket_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@directive_end_token_bracket_bracket',
      ),
        IExpandedMonarchLanguageRule(
        include: '@expression_token_bracket_bracket',
      ),
      ],
    'no_parse_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@open_angle_bracket)(\\/#?)([a-zA-Z]+)((?:@blank)*)(@close_angle_bracket)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==\$3': <Object?>[
                <String, Object?>{
                  'token': '@brackets.directive',
                },
                <String, Object?>{
                  'token': 'delimiter.directive',
                },
                <String, Object?>{
                  'token': 'tag',
                },
                <String, Object?>{
                  'token': '',
                },
                <String, Object?>{
                  'next': '@popall',
                  'token': '@brackets.directive',
                },
              ],
              '\$S2==comment': <Object?>[
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
              ],
              '@default': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<\\[\\-]+|[<\\[\\-]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==comment': <String, Object?>{
                'token': 'comment',
              },
              '@default': <String, Object?>{
                'token': 'source',
              },
            },
        ),
      ),
      ],
    'no_parse_token_auto_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@open_auto_bracket)(\\/#?)([a-zA-Z]+)((?:@blank)*)(@close_auto_bracket)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==\$3': <Object?>[
                <String, Object?>{
                  'token': '@brackets.directive',
                },
                <String, Object?>{
                  'token': 'delimiter.directive',
                },
                <String, Object?>{
                  'token': 'tag',
                },
                <String, Object?>{
                  'token': '',
                },
                <String, Object?>{
                  'next': '@popall',
                  'token': '@brackets.directive',
                },
              ],
              '\$S2==comment': <Object?>[
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
              ],
              '@default': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<\\[\\-]+|[<\\[\\-]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==comment': <String, Object?>{
                'token': 'comment',
              },
              '@default': <String, Object?>{
                'token': 'source',
              },
            },
        ),
      ),
      ],
    'no_parse_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@open_bracket_bracket)(\\/#?)([a-zA-Z]+)((?:@blank)*)(@close_bracket_bracket)'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==\$3': <Object?>[
                <String, Object?>{
                  'token': '@brackets.directive',
                },
                <String, Object?>{
                  'token': 'delimiter.directive',
                },
                <String, Object?>{
                  'token': 'tag',
                },
                <String, Object?>{
                  'token': '',
                },
                <String, Object?>{
                  'next': '@popall',
                  'token': '@brackets.directive',
                },
              ],
              '\$S2==comment': <Object?>[
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
                <String, Object?>{
                  'token': 'comment',
                },
              ],
              '@default': <Object?>[
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
                <String, Object?>{
                  'token': 'source',
                },
              ],
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<\\[\\-]+|[<\\[\\-]'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '\$S2==comment': <String, Object?>{
                'token': 'comment',
              },
              '@default': <String, Object?>{
                'token': 'source',
              },
            },
        ),
      ),
      ],
    'no_space_expression_end_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@blank)+'),
        IExpandedMonarchLanguageAction(
          switchTo: '@fmExpression_angle_bracket.directive',
          token: '',
        ),
      ),
      ],
    'no_space_expression_end_token_auto_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@blank)+'),
        IExpandedMonarchLanguageAction(
          switchTo: '@fmExpression_auto_bracket.directive',
          token: '',
        ),
      ),
      ],
    'no_space_expression_end_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(?:@blank)+'),
        IExpandedMonarchLanguageAction(
          switchTo: '@fmExpression_bracket_bracket.directive',
          token: '',
        ),
      ),
      ],
    'rawDoubleString_angle_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_double_raw_token_angle_bracket',
      ),
      ],
    'rawDoubleString_auto_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_double_raw_token_auto_bracket',
      ),
      ],
    'rawDoubleString_bracket_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_double_raw_token_bracket_bracket',
      ),
      ],
    'rawSingleString_angle_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_single_raw_token_angle_bracket',
      ),
      ],
    'rawSingleString_auto_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_single_raw_token_auto_bracket',
      ),
      ],
    'rawSingleString_bracket_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_single_raw_token_bracket_bracket',
      ),
      ],
    'singleString_angle_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_single_token_angle_bracket',
      ),
      ],
    'singleString_auto_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_single_token_auto_bracket',
      ),
      ],
    'singleString_bracket_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@string_single_token_bracket_bracket',
      ),
      ],
    'string_double_raw_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"]+'),
        IExpandedMonarchLanguageAction(
          token: 'string.raw',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.raw',
        ),
      ),
      ],
    'string_double_raw_token_auto_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"]+'),
        IExpandedMonarchLanguageAction(
          token: 'string.raw',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.raw',
        ),
      ),
      ],
    'string_double_raw_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"]+'),
        IExpandedMonarchLanguageAction(
          token: 'string.raw',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.raw',
        ),
      ),
      ],
    'string_double_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"\\\\]'),
        IExpandedMonarchLanguageAction(
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapedChar'),
        IExpandedMonarchLanguageAction(
          token: 'string.escape',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
      ],
    'string_double_token_auto_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"\\\\]'),
        IExpandedMonarchLanguageAction(
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapedChar'),
        IExpandedMonarchLanguageAction(
          token: 'string.escape',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
      ],
    'string_double_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^"\\\\]'),
        IExpandedMonarchLanguageAction(
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapedChar'),
        IExpandedMonarchLanguageAction(
          token: 'string.escape',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
      ],
    'string_single_raw_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\']+'),
        IExpandedMonarchLanguageAction(
          token: 'string.raw',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.raw',
        ),
      ),
      ],
    'string_single_raw_token_auto_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\']+'),
        IExpandedMonarchLanguageAction(
          token: 'string.raw',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.raw',
        ),
      ),
      ],
    'string_single_raw_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\']+'),
        IExpandedMonarchLanguageAction(
          token: 'string.raw',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.raw',
        ),
      ),
      ],
    'string_single_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\'\\\\]'),
        IExpandedMonarchLanguageAction(
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapedChar'),
        IExpandedMonarchLanguageAction(
          token: 'string.escape',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
      ],
    'string_single_token_auto_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\'\\\\]'),
        IExpandedMonarchLanguageAction(
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapedChar'),
        IExpandedMonarchLanguageAction(
          token: 'string.escape',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
      ],
    'string_single_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\'\\\\]'),
        IExpandedMonarchLanguageAction(
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapedChar'),
        IExpandedMonarchLanguageAction(
          token: 'string.escape',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\''),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
      ],
    'terseComment_angle_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@terse_comment_token_angle_bracket',
      ),
      ],
    'terseComment_auto_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@terse_comment_token_auto_bracket',
      ),
      ],
    'terseComment_bracket_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@terse_comment_token_bracket_bracket',
      ),
      ],
    'terse_comment_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('--(?:@close_angle_bracket)'),
        IExpandedMonarchLanguageAction(
          next: '@popall',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<\\[\\-]+|[<\\[\\-]'),
        IExpandedMonarchLanguageAction(
          token: 'comment',
        ),
      ),
      ],
    'terse_comment_token_auto_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('--(?:@close_auto_bracket)'),
        IExpandedMonarchLanguageAction(
          next: '@popall',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<\\[\\-]+|[<\\[\\-]'),
        IExpandedMonarchLanguageAction(
          token: 'comment',
        ),
      ),
      ],
    'terse_comment_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('--(?:@close_bracket_bracket)'),
        IExpandedMonarchLanguageAction(
          next: '@popall',
          token: 'comment',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<\\[\\-]+|[<\\[\\-]'),
        IExpandedMonarchLanguageAction(
          token: 'comment',
        ),
      ),
      ],
    'unifiedCall_angle_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@unified_call_token_angle_bracket',
      ),
      ],
    'unifiedCall_auto_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@unified_call_token_auto_bracket',
      ),
      ],
    'unifiedCall_bracket_bracket': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@unified_call_token_bracket_bracket',
      ),
      ],
    'unified_call_token_angle_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@id)((?:@blank)+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_angle_bracket.directive',
            token: '',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@id)(\\/?)(@close_angle_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@popall',
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IExpandedMonarchLanguageAction(
          next: '@noSpaceExpression_angle_bracket',
          token: '@rematch',
        ),
      ),
      ],
    'unified_call_token_auto_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@id)((?:@blank)+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_auto_bracket.directive',
            token: '',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@id)(\\/?)(@close_auto_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@popall',
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IExpandedMonarchLanguageAction(
          next: '@noSpaceExpression_auto_bracket',
          token: '@rematch',
        ),
      ),
      ],
    'unified_call_token_bracket_bracket': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(@id)((?:@blank)+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            next: '@fmExpression_bracket_bracket.directive',
            token: '',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(@id)(\\/?)(@close_bracket_bracket)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'tag',
          ),
          IExpandedMonarchLanguageAction(
            token: 'delimiter.directive',
          ),
          IExpandedMonarchLanguageAction(
            next: '@popall',
            token: '@brackets.directive',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IExpandedMonarchLanguageAction(
          next: '@noSpaceExpression_bracket_bracket',
          token: '@rematch',
        ),
      ),
      ],
  },
    ignoreCase: false,
    unicode: true,
    defaultToken: 'invalid',
    brackets: <IMonarchLanguageBracket>[
      IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
      IMonarchLanguageBracket('[', ']', 'delimiter.square'),
      IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
      IMonarchLanguageBracket('<', '>', 'delimiter.angle'),
    ],
    start: 'default_auto_bracket',
    tokenPostfix: '.freemarker2',
    includeLF: false,
    extra: <String, Object?>{
          'arrows': <Object?>[
            '->',
            '-&gt;',
          ],
          'asciiDigit': RegExp('[0-9]'),
          'blank': RegExp('[ \\t\\n\\r]'),
          'closeTag1_angle_bracket': RegExp('((?:@blank)*)(@close_angle_bracket)'),
          'closeTag1_auto_bracket': RegExp('((?:@blank)*)(@close_auto_bracket)'),
          'closeTag1_bracket_bracket': RegExp('((?:@blank)*)(@close_bracket_bracket)'),
          'closeTag2_angle_bracket': RegExp('((?:@blank)*\\/?)(@close_angle_bracket)'),
          'closeTag2_auto_bracket': RegExp('((?:@blank)*\\/?)(@close_auto_bracket)'),
          'closeTag2_bracket_bracket': RegExp('((?:@blank)*\\/?)(@close_bracket_bracket)'),
          'close_angle_bracket': RegExp('>'),
          'close_auto_bracket': RegExp('[>\\]]'),
          'close_bracket_bracket': RegExp('\\]'),
          'delimiters': <Object?>[
            ';',
            ':',
            ',',
            '.',
          ],
          'directiveEndCloseTag1': RegExp('if|list|items|sep|recover|attempt|for[eE]ach|local|global|assign|function|macro|output[fF]ormat|auto[eE]sc|no(?:autoe|AutoE)sc|compress|transform|switch|escape|no[eE]scape'),
          'directiveStartBlank': RegExp('if|else[iI]f|list|for[eE]ach|switch|case|assign|global|local|include|import|function|macro|transform|visit|stop|return|call|setting|output[fF]ormat|nested|recurse|escape|ftl|items'),
          'directiveStartCloseTag1': RegExp('attempt|recover|sep|auto[eE]sc|no(?:autoe|AutoE)sc|compress|default|no[eE]scape|comment|no[pP]arse'),
          'directiveStartCloseTag2': RegExp('else|break|continue|return|stop|flush|t|lt|rt|nt|nested|recurse|fallback|ftl'),
          'endTag_angle_bracket': RegExp('(@open_angle_bracket)(\\/#)'),
          'endTag_auto_bracket': RegExp('(@open_auto_bracket)(\\/#)'),
          'endTag_bracket_bracket': RegExp('(@open_bracket_bracket)(\\/#)'),
          'escapedChar': RegExp('\\\\(?:[ntrfbgla\\\\\'"\\{=]|(?:x[0-9A-Fa-f]{1,4}))'),
          'escapedIdChar': RegExp('\\\\[\\-\\.:#]'),
          'iClose_angle_bracket': RegExp('\\]'),
          'iClose_auto_bracket': RegExp('\\]'),
          'iClose_bracket_bracket': RegExp('\\]'),
          'iOpen1_angle_bracket': RegExp('\\['),
          'iOpen1_auto_bracket': RegExp('\\['),
          'iOpen1_bracket_bracket': RegExp('\\['),
          'iOpen2_angle_bracket': RegExp('='),
          'iOpen2_auto_bracket': RegExp('='),
          'iOpen2_bracket_bracket': RegExp('='),
          'id': RegExp('(?:@idStartChar)(?:(?:@idStartChar)|(?:@asciiDigit))*'),
          'idStartChar': RegExp('(?:@nonEscapedIdStartChar)|(?:@escapedIdChar)'),
          'integer': RegExp('[0-9]+'),
          'keywords': <Object?>[
            'false',
            'true',
            'in',
            'as',
            'using',
          ],
          'namedSymbols': RegExp('&lt;=|&gt;=|\\\\lte|\\\\lt|&lt;|\\\\gte|\\\\gt|&gt;|&amp;&amp;|\\\\and|-&gt;|->|==|!=|\\+=|-=|\\*=|\\/=|%=|\\+\\+|--|<=|&&|\\|\\||:|\\.\\.\\.|\\.\\.\\*|\\.\\.<|\\.\\.!|\\?\\?|=|<|\\+|-|\\*|\\/|%|\\||\\.\\.|\\?|!|&|\\.|,|;'),
          'noParseTags': <Object?>[
            'noparse',
            'noParse',
            'comment',
          ],
          'nonEscapedIdStartChar': RegExp('[\\\$@-Z_a-z\\u00AA\\u00B5\\u00BA\\u00C0-\\u00D6\\u00D8-\\u00F6\\u00F8-\\u1FFF\\u2071\\u207F\\u2090-\\u209C\\u2102\\u2107\\u210A-\\u2113\\u2115\\u2119-\\u211D\\u2124\\u2126\\u2128\\u212A-\\u212D\\u212F-\\u2139\\u213C-\\u213F\\u2145-\\u2149\\u214E\\u2183-\\u2184\\u2C00-\\u2C2E\\u2C30-\\u2C5E\\u2C60-\\u2CE4\\u2CEB-\\u2CEE\\u2CF2-\\u2CF3\\u2D00-\\u2D25\\u2D27\\u2D2D\\u2D30-\\u2D67\\u2D6F\\u2D80-\\u2D96\\u2DA0-\\u2DA6\\u2DA8-\\u2DAE\\u2DB0-\\u2DB6\\u2DB8-\\u2DBE\\u2DC0-\\u2DC6\\u2DC8-\\u2DCE\\u2DD0-\\u2DD6\\u2DD8-\\u2DDE\\u2E2F\\u3005-\\u3006\\u3031-\\u3035\\u303B-\\u303C\\u3040-\\u318F\\u31A0-\\u31BA\\u31F0-\\u31FF\\u3300-\\u337F\\u3400-\\u4DB5\\u4E00-\\uA48C\\uA4D0-\\uA4FD\\uA500-\\uA60C\\uA610-\\uA62B\\uA640-\\uA66E\\uA67F-\\uA697\\uA6A0-\\uA6E5\\uA717-\\uA71F\\uA722-\\uA788\\uA78B-\\uA78E\\uA790-\\uA793\\uA7A0-\\uA7AA\\uA7F8-\\uA801\\uA803-\\uA805\\uA807-\\uA80A\\uA80C-\\uA822\\uA840-\\uA873\\uA882-\\uA8B3\\uA8D0-\\uA8D9\\uA8F2-\\uA8F7\\uA8FB\\uA900-\\uA925\\uA930-\\uA946\\uA960-\\uA97C\\uA984-\\uA9B2\\uA9CF-\\uA9D9\\uAA00-\\uAA28\\uAA40-\\uAA42\\uAA44-\\uAA4B\\uAA50-\\uAA59\\uAA60-\\uAA76\\uAA7A\\uAA80-\\uAAAF\\uAAB1\\uAAB5-\\uAAB6\\uAAB9-\\uAABD\\uAAC0\\uAAC2\\uAADB-\\uAADD\\uAAE0-\\uAAEA\\uAAF2-\\uAAF4\\uAB01-\\uAB06\\uAB09-\\uAB0E\\uAB11-\\uAB16\\uAB20-\\uAB26\\uAB28-\\uAB2E\\uABC0-\\uABE2\\uABF0-\\uABF9\\uAC00-\\uD7A3\\uD7B0-\\uD7C6\\uD7CB-\\uD7FB\\uF900-\\uFB06\\uFB13-\\uFB17\\uFB1D\\uFB1F-\\uFB28\\uFB2A-\\uFB36\\uFB38-\\uFB3C\\uFB3E\\uFB40-\\uFB41\\uFB43-\\uFB44\\uFB46-\\uFBB1\\uFBD3-\\uFD3D\\uFD50-\\uFD8F\\uFD92-\\uFDC7\\uFDF0-\\uFDFB\\uFE70-\\uFE74\\uFE76-\\uFEFC\\uFF10-\\uFF19\\uFF21-\\uFF3A\\uFF41-\\uFF5A\\uFF66-\\uFFBE\\uFFC2-\\uFFC7\\uFFCA-\\uFFCF\\uFFD2-\\uFFD7\\uFFDA-\\uFFDC]'),
          'open_angle_bracket': RegExp('<'),
          'open_auto_bracket': RegExp('[<\\[]'),
          'open_bracket_bracket': RegExp('\\['),
          'specialHashKeys': RegExp('\\*\\*|\\*|false|true|in|as|using'),
          'startOrEndTag_angle_bracket': RegExp('(@open_angle_bracket)(\\/?#)'),
          'startOrEndTag_auto_bracket': RegExp('(@open_auto_bracket)(\\/?#)'),
          'startOrEndTag_bracket_bracket': RegExp('(@open_bracket_bracket)(\\/?#)'),
          'startTag_angle_bracket': RegExp('(@open_angle_bracket)(#)'),
          'startTag_auto_bracket': RegExp('(@open_auto_bracket)(#)'),
          'startTag_bracket_bracket': RegExp('(@open_bracket_bracket)(#)'),
          'stringOperators': <Object?>[
            'lte',
            'lt',
            'gte',
            'gt',
          ],
        },
  ),
);
