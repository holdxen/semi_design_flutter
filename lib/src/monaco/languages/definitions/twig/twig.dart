// 1:1 translation of monaco-editor/src/languages/definitions/twig/twig.ts
// Monarch language definition data, evaluated from the TS source via
// the TypeScript compiler (computed template/const values resolved).
// TS object literals -> Dart data; typed rule/action/bracket carriers
// mirror the ported monarchCompile. Regex flags preserved in RegExp.

import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchTypes.dart';

/// 1:1: `export const conf: languages.LanguageConfiguration = {...}`
final Map<String, Object?> conf = <String, Object?>{
  'autoClosingPairs': <Object?>[
    <String, Object?>{
      'close': ' #}',
      'open': '{# ',
    },
    <String, Object?>{
      'close': ' %}',
      'open': '{% ',
    },
    <String, Object?>{
      'close': ' }}',
      'open': '{{ ',
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
      '{#',
      '#}',
    ],
    <Object?>[
      '{%',
      '%}',
    ],
    <Object?>[
      '{{',
      '}}',
    ],
    <Object?>[
      '(',
      ')',
    ],
    <Object?>[
      '[',
      ']',
    ],
    <Object?>[
      '<!--',
      '-->',
    ],
    <Object?>[
      '<',
      '>',
    ],
  ],
  'comments': <String, Object?>{
    'blockComment': <Object?>[
      '{#',
      '#}',
    ],
  },
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
      'close': '>',
      'open': '<',
    },
  ],
  'wordPattern': RegExp('(-?\\d*\\.\\d\\w*)|([^\\`\\~\\!\\@\\\$\\^\\&\\*\\(\\)\\=\\+\\[\\{\\]\\}\\\\\\|\\;\\:\\\'\\"\\,\\.\\<\\>\\/\\s]+)'),
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'blockState': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('[-~]?%}'),
        IShortActionCarrier('delimiter.twig'),
        '@pop',
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('\\s+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(verbatim)(\\s*)([-~]?%})'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('keyword.twig'),
          IShortActionCarrier(''),
          IExpandedMonarchLanguageAction(
            next: '@rawDataState',
            token: 'delimiter.twig',
          ),
        ]),
      ),
        IExpandedMonarchLanguageRule(
        include: 'expression',
      ),
      ],
    'comment': <IMonarchLanguageRule>[
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
    'commentState': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('#}'),
        IShortActionCarrier('comment.twig'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('comment.twig'),
      ),
      ],
    'doctype': <IMonarchLanguageRule>[
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
    'expression': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
          regex: RegExp('\\s+'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\+|-|\\/{1,2}|%|\\*{1,2}'),
        IShortActionCarrier('operators.twig'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(and|or|not|b-and|b-xor|b-or)(\\s+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('operators.twig'),
          IShortActionCarrier(''),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('==|!=|<|>|>=|<='),
        IShortActionCarrier('operators.twig'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(starts with|ends with|matches)(\\s+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('operators.twig'),
          IShortActionCarrier(''),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(in)(\\s+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('operators.twig'),
          IShortActionCarrier(''),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(is)(\\s+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('operators.twig'),
          IShortActionCarrier(''),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\||~|:|\\.{1,2}|\\?{1,2}'),
        IShortActionCarrier('operators.twig'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^\\W\\d][\\w]*'),
        IExpandedMonarchLanguageAction(
          cases: <String, Object?>{
              '@default': 'variable.twig',
              '@keywords': 'keyword.twig',
            },
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\d+(\\.\\d+)?'),
        IShortActionCarrier('number.twig'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\(|\\)|\\[|\\]|{|}|,'),
        IShortActionCarrier('delimiter.twig'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^#"\\\\]*(?:\\\\.[^#"\\\\]*)*)"|\\\'([^\\\'\\\\]*(?:\\\\.[^\\\'\\\\]*)*)\\\''),
        IShortActionCarrier('string.twig'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string.twig'),
        '@stringState',
      ),
        IShortMonarchLanguageRule1(
        RegExp('=>'),
        IShortActionCarrier('operators.twig'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('operators.twig'),
      ),
      ],
    'interpolationState': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('}'),
        IShortActionCarrier('string.twig'),
        '@pop',
      ),
        IExpandedMonarchLanguageRule(
        include: 'expression',
      ),
      ],
    'otherTag': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('\\/?>'),
        IShortActionCarrier('delimiter.html'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"]*)"'),
        IShortActionCarrier('attribute.value.html'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\']*)\''),
        IShortActionCarrier('attribute.value.html'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\w\\-]+'),
        IShortActionCarrier('attribute.name.html'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('delimiter.html'),
      ),
        IExpandedMonarchLanguageRule(
          regex: RegExp('[ \\t\\r\\n]+'),
      ),
      ],
    'rawDataState': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('({%[-~]?)(\\s*)(endverbatim)(\\s*)([-~]?%})'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter.twig'),
          IShortActionCarrier(''),
          IShortActionCarrier('keyword.twig'),
          IShortActionCarrier(''),
          IExpandedMonarchLanguageAction(
            next: '@popall',
            token: 'delimiter.twig',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IShortActionCarrier('string.twig'),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
          regex: RegExp('\\s+'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('{#'),
        IShortActionCarrier('comment.twig'),
        '@commentState',
      ),
        IShortMonarchLanguageRule2(
        RegExp('{%[-~]?'),
        IShortActionCarrier('delimiter.twig'),
        '@blockState',
      ),
        IShortMonarchLanguageRule2(
        RegExp('{{[-~]?'),
        IShortActionCarrier('delimiter.twig'),
        '@variableState',
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
        RegExp('(<)((?:[\\w\\-]+:)?[\\w\\-]+)(\\s*)(\\/>)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter.html'),
          IShortActionCarrier('tag.html'),
          IShortActionCarrier(''),
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
        RegExp('(<)((?:[\\w\\-]+:)?[\\w\\-]+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('delimiter.html'),
          IExpandedMonarchLanguageAction(
            next: '@otherTag',
            token: 'tag.html',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(<\\/)((?:[\\w\\-]+:)?[\\w\\-]+)'),
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
          regex: RegExp('[^<{]+'),
      ),
      ],
    'script': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('type'),
        IShortActionCarrier('attribute.name.html'),
        '@scriptAfterType',
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"]*)"'),
        IShortActionCarrier('attribute.value.html'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\']*)\''),
        IShortActionCarrier('attribute.value.html'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\w\\-]+'),
        IShortActionCarrier('attribute.name.html'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('delimiter.html'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@scriptEmbedded',
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
        IShortMonarchLanguageRule2(
        RegExp('='),
        IShortActionCarrier('delimiter.html'),
        '@scriptAfterTypeEquals',
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@scriptEmbedded',
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
        RegExp('"([^"]*)"'),
        IExpandedMonarchLanguageAction(
          switchTo: '@scriptWithCustomType.\$1',
          token: 'attribute.value.html',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\']*)\''),
        IExpandedMonarchLanguageAction(
          switchTo: '@scriptWithCustomType.\$1',
          token: 'attribute.value.html',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@scriptEmbedded',
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
        RegExp('<\\/script'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          nextEmbedded: '@pop',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<]+'),
        IShortActionCarrier(''),
      ),
      ],
    'scriptWithCustomType': <IMonarchLanguageRule>[
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
        IShortActionCarrier('attribute.value.html'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\']*)\''),
        IShortActionCarrier('attribute.value.html'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\w\\-]+'),
        IShortActionCarrier('attribute.name.html'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('delimiter.html'),
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
    'stringState': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string.twig'),
        '@pop',
      ),
        IShortMonarchLanguageRule2(
        RegExp('#{\\s*'),
        IShortActionCarrier('string.twig'),
        '@interpolationState',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^#"\\\\]*(?:(?:\\\\.|#(?!\\{))[^#"\\\\]*)*'),
        IShortActionCarrier('string.twig'),
      ),
      ],
    'style': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('type'),
        IShortActionCarrier('attribute.name.html'),
        '@styleAfterType',
      ),
        IShortMonarchLanguageRule1(
        RegExp('"([^"]*)"'),
        IShortActionCarrier('attribute.value.html'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\']*)\''),
        IShortActionCarrier('attribute.value.html'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\w\\-]+'),
        IShortActionCarrier('attribute.name.html'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('delimiter.html'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@styleEmbedded',
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
        IShortMonarchLanguageRule2(
        RegExp('='),
        IShortActionCarrier('delimiter.html'),
        '@styleAfterTypeEquals',
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@styleEmbedded',
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
        RegExp('"([^"]*)"'),
        IExpandedMonarchLanguageAction(
          switchTo: '@styleWithCustomType.\$1',
          token: 'attribute.value.html',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\']*)\''),
        IExpandedMonarchLanguageAction(
          switchTo: '@styleWithCustomType.\$1',
          token: 'attribute.value.html',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@styleEmbedded',
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
        RegExp('<\\/style'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          nextEmbedded: '@pop',
          token: '@rematch',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[^<]+'),
        IShortActionCarrier(''),
      ),
      ],
    'styleWithCustomType': <IMonarchLanguageRule>[
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
        IShortActionCarrier('attribute.value.html'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'([^\']*)\''),
        IShortActionCarrier('attribute.value.html'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\w\\-]+'),
        IShortActionCarrier('attribute.name.html'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('='),
        IShortActionCarrier('delimiter.html'),
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
    'variableState': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('[-~]?}}'),
        IShortActionCarrier('delimiter.twig'),
        '@pop',
      ),
        IExpandedMonarchLanguageRule(
        include: 'expression',
      ),
      ],
  },
  ignoreCase: true,
  defaultToken: '',
  tokenPostfix: '',
  extra: <String, Object?>{
      'keywords': <Object?>[
        'apply',
        'autoescape',
        'block',
        'deprecated',
        'do',
        'embed',
        'extends',
        'flush',
        'for',
        'from',
        'if',
        'import',
        'include',
        'macro',
        'sandbox',
        'set',
        'use',
        'verbatim',
        'with',
        'endapply',
        'endautoescape',
        'endblock',
        'endembed',
        'endfor',
        'endif',
        'endmacro',
        'endsandbox',
        'endset',
        'endwith',
        'true',
        'false',
      ],
    },
);
