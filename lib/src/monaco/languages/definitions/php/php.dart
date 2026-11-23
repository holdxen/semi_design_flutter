// 1:1 translation of monaco-editor/src/languages/definitions/php/php.ts
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
      'notIn': <Object?>[
        'string',
      ],
      'open': '{',
    },
    <String, Object?>{
      'close': ']',
      'notIn': <Object?>[
        'string',
      ],
      'open': '[',
    },
    <String, Object?>{
      'close': ')',
      'notIn': <Object?>[
        'string',
      ],
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
      '/*',
      '*/',
    ],
    'lineComment': '//',
  },
  'folding': <String, Object?>{
    'markers': <String, Object?>{
      'end': RegExp('^\\s*(#|\\/\\/)endregion\\b'),
      'start': RegExp('^\\s*(#|\\/\\/)region\\b'),
    },
  },
  'wordPattern': RegExp('(-?\\d*\\.\\d\\w*)|([^\\`\\~\\!\\@\\#\\%\\^\\&\\*\\(\\)\\-\\=\\+\\[\\{\\]\\}\\\\\\|\\;\\:\\\'\\"\\,\\.\\<\\>\\/\\?\\s]+)'),
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('<\\?((php)|=)?'),
        IExpandedMonarchLanguageAction(
          switchTo: '@phpInSimpleState.comment',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('-->'),
        IShortActionCarrier('comment.html'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^-]+'),
        IShortActionCarrier('comment.content.html'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('comment.content.html'),
      ),
      ],
    'doctype': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('<\\?((php)|=)?'),
        IExpandedMonarchLanguageAction(
          switchTo: '@phpInSimpleState.comment',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^>]+'),
        IShortActionCarrier('metatag.content.html'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('>'),
        IShortActionCarrier('metatag.html'),
        '@pop',
      ),
      ],
    'otherTag': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('<\\?((php)|=)?'),
        IExpandedMonarchLanguageAction(
          switchTo: '@phpInSimpleState.otherTag',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\/?>'),
        IShortActionCarrier('delimiter.html'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"]*)"'),
        IShortActionCarrier('attribute.value'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\']*)\''),
        IShortActionCarrier('attribute.value'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\w\\-]+'),
        IShortActionCarrier('attribute.name'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('delimiter'),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
      ],
    'phpComment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('\\*\\/'),
        IShortActionCarrier('comment.php'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^*]+'),
        IShortActionCarrier('comment.php'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('comment.php'),
      ),
      ],
    'phpDoubleQuoteString': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\"]+'),
        IShortActionCarrier('string.php'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IShortActionCarrier('string.escape.php'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string.escape.invalid.php'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string.php'),
        '@pop',
      ),
      ],
    'phpInEmbeddedState': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('<\\?((php)|=)?'),
        IShortActionCarrier('metatag.php'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\?>'),
        IExpandedMonarchLanguageAction(
          nextEmbedded: '\$S3',
          switchTo: '@\$S2.\$S3',
          token: 'metatag.php',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: 'phpRoot',
      ),
      ],
    'phpInSimpleState': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('<\\?((php)|=)?'),
        IShortActionCarrier('metatag.php'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\?>'),
        IExpandedMonarchLanguageAction(
          switchTo: '@\$S2.\$S3',
          token: 'metatag.php',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: 'phpRoot',
      ),
      ],
    'phpLineComment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\?>'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('.\$'),
        IShortActionCarrier('comment.php'),
        '@pop',
      ),
        IShortMonarchLanguageRule2(
        RegExp('[^?]+\$'),
        IShortActionCarrier('comment.php'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^?]+'),
        IShortActionCarrier('comment.php'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('comment.php'),
      ),
      ],
    'phpRoot': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[a-zA-Z_]\\w*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'identifier.php',
              '@phpCompileTimeConstants': <String, Object?>{
                'token': 'constant.php',
              },
              '@phpKeywords': <String, Object?>{
                'token': 'keyword.php',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\$a-zA-Z_]\\w*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'variable.php',
              '@phpPreDefinedVariables': <String, Object?>{
                'token': 'variable.predefined.php',
              },
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[{}]'),
        IShortActionCarrier('delimiter.bracket.php'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\[\\]]'),
        IShortActionCarrier('delimiter.array.php'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[()]'),
        IShortActionCarrier('delimiter.parenthesis.php'),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(#|\\/\\/)\$'),
        IShortActionCarrier('comment.php'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('(#|\\/\\/)'),
        IShortActionCarrier('comment.php'),
        '@phpLineComment',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\/\\*'),
        IShortActionCarrier('comment.php'),
        '@phpComment',
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string.php'),
        '@phpDoubleQuoteString',
      ),
        IShortMonarchLanguageRule2(
        RegExp('\''),
        IShortActionCarrier('string.php'),
        '@phpSingleQuoteString',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\+\\-\\*\\%\\&\\|\\^\\~\\!\\=\\<\\>\\/\\?\\;\\:\\.\\,\\@]'),
        IShortActionCarrier('delimiter.php'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d*\\d+[eE]([\\-+]?\\d+)?'),
        IShortActionCarrier('number.float.php'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d*\\.\\d+([eE][\\-+]?\\d+)?'),
        IShortActionCarrier('number.float.php'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[xX][0-9a-fA-F\']*[0-9a-fA-F]'),
        IShortActionCarrier('number.hex.php'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[0-7\']*[0-7]'),
        IShortActionCarrier('number.octal.php'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('0[bB][0-1\']*[0-1]'),
        IShortActionCarrier('number.binary.php'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d[\\d\']*'),
        IShortActionCarrier('number.php'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d'),
        IShortActionCarrier('number.php'),
      ),
      ],
    'phpSingleQuoteString': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\\\\']+'),
        IShortActionCarrier('string.php'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('@escapes'),
        IShortActionCarrier('string.escape.php'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\\\.'),
        IShortActionCarrier('string.escape.invalid.php'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\''),
        IShortActionCarrier('string.php'),
        '@pop',
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('<\\?((php)|=)?'),
        IExpandedMonarchLanguageAction(
          switchTo: '@phpInSimpleState.root',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('<!DOCTYPE'),
        IShortActionCarrier('metatag.html'),
        '@doctype',
      ),
        IShortMonarchLanguageRule2(
        RegExp('<!--'),
        IShortActionCarrier('comment.html'),
        '@comment',
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<)(\\w+)(\\/>)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter.html'),
          IShortActionCarrier('tag.html'),
          IShortActionCarrier('delimiter.html'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<)(script)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter.html'),
          IExpandedMonarchLanguageAction(
            next: '@script',
            token: 'tag.html',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<)(style)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter.html'),
          IExpandedMonarchLanguageAction(
            next: '@style',
            token: 'tag.html',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<)([:\\w]+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter.html'),
          IExpandedMonarchLanguageAction(
            next: '@otherTag',
            token: 'tag.html',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<\\/)(\\w+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter.html'),
          IExpandedMonarchLanguageAction(
            next: '@otherTag',
            token: 'tag.html',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<'),
        IShortActionCarrier('delimiter.html'),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[^<]+'),
      ),
      ],
    'script': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('<\\?((php)|=)?'),
        IExpandedMonarchLanguageAction(
          switchTo: '@phpInSimpleState.script',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('type'),
        IShortActionCarrier('attribute.name'),
        '@scriptAfterType',
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"]*)"'),
        IShortActionCarrier('attribute.value'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\']*)\''),
        IShortActionCarrier('attribute.value'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\w\\-]+'),
        IShortActionCarrier('attribute.name'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@scriptEmbedded.text/javascript',
          nextEmbedded: 'text/javascript',
          token: 'delimiter.html',
        ),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<\\/)(script\\s*)(>)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter.html'),
          IShortActionCarrier('tag.html'),
          IExpandedMonarchLanguageAction(
            next: '@pop',
            token: 'delimiter.html',
          ),
        ]),
      ),
      ],
    'scriptAfterType': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('<\\?((php)|=)?'),
        IExpandedMonarchLanguageAction(
          switchTo: '@phpInSimpleState.scriptAfterType',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('='),
        IShortActionCarrier('delimiter'),
        '@scriptAfterTypeEquals',
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@scriptEmbedded.text/javascript',
          nextEmbedded: 'text/javascript',
          token: 'delimiter.html',
        ),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<\\/script\\s*>'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: '@rematch',
        ),
      ),
      ],
    'scriptAfterTypeEquals': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('<\\?((php)|=)?'),
        IExpandedMonarchLanguageAction(
          switchTo: '@phpInSimpleState.scriptAfterTypeEquals',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"]*)"'),
        IExpandedMonarchLanguageAction(
          switchTo: '@scriptWithCustomType.\$1',
          token: 'attribute.value',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\']*)\''),
        IExpandedMonarchLanguageAction(
          switchTo: '@scriptWithCustomType.\$1',
          token: 'attribute.value',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@scriptEmbedded.text/javascript',
          nextEmbedded: 'text/javascript',
          token: 'delimiter.html',
        ),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<\\/script\\s*>'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: '@rematch',
        ),
      ),
      ],
    'scriptEmbedded': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('<\\?((php)|=)?'),
        IExpandedMonarchLanguageAction(
          nextEmbedded: '@pop',
          switchTo: '@phpInEmbeddedState.scriptEmbedded.\$S2',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<\\/script'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          nextEmbedded: '@pop',
          token: '@rematch',
        ),
      ),
      ],
    'scriptWithCustomType': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('<\\?((php)|=)?'),
        IExpandedMonarchLanguageAction(
          switchTo: '@phpInSimpleState.scriptWithCustomType.\$S2',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@scriptEmbedded.\$S2',
          nextEmbedded: '\$S2',
          token: 'delimiter.html',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"]*)"'),
        IShortActionCarrier('attribute.value'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\']*)\''),
        IShortActionCarrier('attribute.value'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\w\\-]+'),
        IShortActionCarrier('attribute.name'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('delimiter'),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<\\/script\\s*>'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: '@rematch',
        ),
      ),
      ],
    'style': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('<\\?((php)|=)?'),
        IExpandedMonarchLanguageAction(
          switchTo: '@phpInSimpleState.style',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('type'),
        IShortActionCarrier('attribute.name'),
        '@styleAfterType',
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"]*)"'),
        IShortActionCarrier('attribute.value'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\']*)\''),
        IShortActionCarrier('attribute.value'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\w\\-]+'),
        IShortActionCarrier('attribute.name'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@styleEmbedded.text/css',
          nextEmbedded: 'text/css',
          token: 'delimiter.html',
        ),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<\\/)(style\\s*)(>)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter.html'),
          IShortActionCarrier('tag.html'),
          IExpandedMonarchLanguageAction(
            next: '@pop',
            token: 'delimiter.html',
          ),
        ]),
      ),
      ],
    'styleAfterType': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('<\\?((php)|=)?'),
        IExpandedMonarchLanguageAction(
          switchTo: '@phpInSimpleState.styleAfterType',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule2(
        RegExp('='),
        IShortActionCarrier('delimiter'),
        '@styleAfterTypeEquals',
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@styleEmbedded.text/css',
          nextEmbedded: 'text/css',
          token: 'delimiter.html',
        ),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<\\/style\\s*>'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: '@rematch',
        ),
      ),
      ],
    'styleAfterTypeEquals': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('<\\?((php)|=)?'),
        IExpandedMonarchLanguageAction(
          switchTo: '@phpInSimpleState.styleAfterTypeEquals',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"]*)"'),
        IExpandedMonarchLanguageAction(
          switchTo: '@styleWithCustomType.\$1',
          token: 'attribute.value',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\']*)\''),
        IExpandedMonarchLanguageAction(
          switchTo: '@styleWithCustomType.\$1',
          token: 'attribute.value',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@styleEmbedded.text/css',
          nextEmbedded: 'text/css',
          token: 'delimiter.html',
        ),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<\\/style\\s*>'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: '@rematch',
        ),
      ),
      ],
    'styleEmbedded': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('<\\?((php)|=)?'),
        IExpandedMonarchLanguageAction(
          nextEmbedded: '@pop',
          switchTo: '@phpInEmbeddedState.styleEmbedded.\$S2',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<\\/style'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          nextEmbedded: '@pop',
          token: '@rematch',
        ),
      ),
      ],
    'styleWithCustomType': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('<\\?((php)|=)?'),
        IExpandedMonarchLanguageAction(
          switchTo: '@phpInSimpleState.styleWithCustomType.\$S2',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@styleEmbedded.\$S2',
          nextEmbedded: '\$S2',
          token: 'delimiter.html',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"]*)"'),
        IShortActionCarrier('attribute.value'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\']*)\''),
        IShortActionCarrier('attribute.value'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\w\\-]+'),
        IShortActionCarrier('attribute.name'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('delimiter'),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<\\/style\\s*>'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: '@rematch',
        ),
      ),
      ],
  },
  defaultToken: '',
  tokenPostfix: '',
  extra: <String, Object?>{
      'escapes': RegExp('\\\\(?:[abfnrtv\\\\"\']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})'),
      'phpCompileTimeConstants': <Object?>[
        '__CLASS__',
        '__DIR__',
        '__FILE__',
        '__LINE__',
        '__NAMESPACE__',
        '__METHOD__',
        '__FUNCTION__',
        '__TRAIT__',
      ],
      'phpKeywords': <Object?>[
        'abstract',
        'and',
        'array',
        'as',
        'break',
        'callable',
        'case',
        'catch',
        'cfunction',
        'class',
        'clone',
        'const',
        'continue',
        'declare',
        'default',
        'do',
        'else',
        'elseif',
        'enddeclare',
        'endfor',
        'endforeach',
        'endif',
        'endswitch',
        'endwhile',
        'extends',
        'false',
        'final',
        'for',
        'foreach',
        'function',
        'global',
        'goto',
        'if',
        'implements',
        'interface',
        'instanceof',
        'insteadof',
        'namespace',
        'new',
        'null',
        'object',
        'old_function',
        'or',
        'private',
        'protected',
        'public',
        'resource',
        'static',
        'switch',
        'throw',
        'trait',
        'try',
        'true',
        'use',
        'var',
        'while',
        'xor',
        'die',
        'echo',
        'empty',
        'exit',
        'eval',
        'include',
        'include_once',
        'isset',
        'list',
        'require',
        'require_once',
        'return',
        'print',
        'unset',
        'yield',
        '__construct',
      ],
      'phpPreDefinedVariables': <Object?>[
        '\$GLOBALS',
        '\$_SERVER',
        '\$_GET',
        '\$_POST',
        '\$_FILES',
        '\$_REQUEST',
        '\$_SESSION',
        '\$_ENV',
        '\$_COOKIE',
        '\$php_errormsg',
        '\$HTTP_RAW_POST_DATA',
        '\$http_response_header',
        '\$argc',
        '\$argv',
      ],
    },
);
