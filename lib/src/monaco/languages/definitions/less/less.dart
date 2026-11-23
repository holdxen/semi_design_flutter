// 1:1 translation of monaco-editor/src/languages/definitions/less/less.ts
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
        'comment',
      ],
      'open': '{',
    },
    <String, Object?>{
      'close': ']',
      'notIn': <Object?>[
        'string',
        'comment',
      ],
      'open': '[',
    },
    <String, Object?>{
      'close': ')',
      'notIn': <Object?>[
        'string',
        'comment',
      ],
      'open': '(',
    },
    <String, Object?>{
      'close': '"',
      'notIn': <Object?>[
        'string',
        'comment',
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
      'end': RegExp('^\\s*\\/\\*\\s*#endregion\\b.*\\*\\/'),
      'start': RegExp('^\\s*\\/\\*\\s*#region\\b\\s*(.*?)\\s*\\*\\/'),
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
  ],
  'wordPattern': RegExp('(#?-?\\d*\\.\\d\\w*%?)|([@#!.:]?[\\w-?]+%?)|[@#!.]'),
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'atRules': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@comments',
      ),
        IExpandedMonarchLanguageRule(
        include: '@strings',
      ),
        IShortMonarchLanguageRule1(
        '[()]',
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule2(
        '[\\{;]',
        IShortActionCarrier('delimiter'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        '.',
        IShortActionCarrier('key'),
      ),
      ],
    'attribute': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@nestedJSBegin',
      ),
        IExpandedMonarchLanguageRule(
        include: '@comments',
      ),
        IExpandedMonarchLanguageRule(
        include: '@strings',
      ),
        IExpandedMonarchLanguageRule(
        include: '@numbers',
      ),
        IExpandedMonarchLanguageRule(
        include: '@keyword',
      ),
        IShortMonarchLanguageRule2(
        '[a-zA-Z\\-]+(?=\\()',
        IShortActionCarrier('attribute.value'),
        '@attribute',
      ),
        IShortMonarchLanguageRule2(
        '>',
        IShortActionCarrier('operator'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        '@identifier',
        IShortActionCarrier('attribute.value'),
      ),
        IExpandedMonarchLanguageRule(
        include: '@operators',
      ),
        IShortMonarchLanguageRule1(
        '@(@identifier)',
        IShortActionCarrier('variable'),
      ),
        IShortMonarchLanguageRule2(
        '[)\\}]',
        IShortActionCarrier('@brackets'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        '[{}()\\[\\]>]',
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule2(
        '[;]',
        IShortActionCarrier('delimiter'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        '[,=:]',
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        '\\s',
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule1(
        '.',
        IShortActionCarrier('attribute.value'),
      ),
      ],
    'comment': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        '\\*\\/',
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        '.',
        IShortActionCarrier('comment'),
      ),
      ],
    'comments': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        '\\/\\*',
        IShortActionCarrier('comment'),
        '@comment',
      ),
        IShortMonarchLanguageRule1(
        '\\/\\/+.*',
        IShortActionCarrier('comment'),
      ),
      ],
    'keyword': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '(@[\\s]*import|![\\s]*important|true|false|when|iscolor|isnumber|isstring|iskeyword|isurl|ispixel|ispercentage|isem|hue|saturation|lightness|alpha|lighten|darken|saturate|desaturate|fadein|fadeout|fade|spin|mix|round|ceil|floor|percentage)\\b',
        IShortActionCarrier('keyword'),
      ),
      ],
    'nestedJSBegin': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '``',
        IShortActionCarrier('delimiter.backtick'),
      ),
        IShortMonarchLanguageRule1(
        '`',
        IExpandedMonarchLanguageAction(
          next: '@nestedJSEnd',
          nextEmbedded: 'text/javascript',
          token: 'delimiter.backtick',
        ),
      ),
      ],
    'nestedJSEnd': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '`',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          nextEmbedded: '@pop',
          token: 'delimiter.backtick',
        ),
      ),
      ],
    'numbers': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '(\\d*\\.)?\\d+([eE][\\-+]?\\d+)?',
        IExpandedMonarchLanguageAction(
          next: '@units',
          token: 'attribute.value.number',
        ),
      ),
        IShortMonarchLanguageRule1(
        '#[0-9a-fA-F_]+(?!\\w)',
        IShortActionCarrier('attribute.value.hex'),
      ),
      ],
    'operators': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '[<>=\\+\\-\\*\\/\\^\\|\\~]',
        IShortActionCarrier('operator'),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@nestedJSBegin',
      ),
        IShortMonarchLanguageRule1(
        '[ \\t\\r\\n]+',
        IShortActionCarrier(''),
      ),
        IExpandedMonarchLanguageRule(
        include: '@comments',
      ),
        IExpandedMonarchLanguageRule(
        include: '@keyword',
      ),
        IExpandedMonarchLanguageRule(
        include: '@strings',
      ),
        IExpandedMonarchLanguageRule(
        include: '@numbers',
      ),
        IShortMonarchLanguageRule2(
        '[*_]?[a-zA-Z\\-\\s]+(?=:.*(;|(\\\\\$)))',
        IShortActionCarrier('attribute.name'),
        '@attribute',
      ),
        IShortMonarchLanguageRule1(
        'url(\\-prefix)?\\(',
        IExpandedMonarchLanguageAction(
          next: '@urldeclaration',
          token: 'tag',
        ),
      ),
        IShortMonarchLanguageRule1(
        '[{}()\\[\\]]',
        IShortActionCarrier('@brackets'),
      ),
        IShortMonarchLanguageRule1(
        '[,:;]',
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        '#@identifierPlus',
        IShortActionCarrier('tag.id'),
      ),
        IShortMonarchLanguageRule1(
        '&',
        IShortActionCarrier('tag'),
      ),
        IShortMonarchLanguageRule2(
        '\\.@identifierPlus(?=\\()',
        IShortActionCarrier('tag.class'),
        '@attribute',
      ),
        IShortMonarchLanguageRule1(
        '\\.@identifierPlus',
        IShortActionCarrier('tag.class'),
      ),
        IShortMonarchLanguageRule1(
        '@identifierPlus',
        IShortActionCarrier('tag'),
      ),
        IExpandedMonarchLanguageRule(
        include: '@operators',
      ),
        IShortMonarchLanguageRule2(
        '@(@identifier(?=[:,\\)]))',
        IShortActionCarrier('variable'),
        '@attribute',
      ),
        IShortMonarchLanguageRule1(
        '@(@identifier)',
        IShortActionCarrier('variable'),
      ),
        IShortMonarchLanguageRule2(
        '@',
        IShortActionCarrier('key'),
        '@atRules',
      ),
      ],
    'strings': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '~?"',
        IExpandedMonarchLanguageAction(
          next: '@stringsEndDoubleQuote',
          token: 'string.delimiter',
        ),
      ),
        IShortMonarchLanguageRule1(
        '~?\'',
        IExpandedMonarchLanguageAction(
          next: '@stringsEndQuote',
          token: 'string.delimiter',
        ),
      ),
      ],
    'stringsEndDoubleQuote': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '\\\\"',
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        '"',
        IExpandedMonarchLanguageAction(
          next: '@popall',
          token: 'string.delimiter',
        ),
      ),
        IShortMonarchLanguageRule1(
        '.',
        IShortActionCarrier('string'),
      ),
      ],
    'stringsEndQuote': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '\\\\\'',
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        '\'',
        IExpandedMonarchLanguageAction(
          next: '@popall',
          token: 'string.delimiter',
        ),
      ),
        IShortMonarchLanguageRule1(
        '.',
        IShortActionCarrier('string'),
      ),
      ],
    'units': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        '(em|ex|ch|rem|fr|vmin|vmax|vw|vh|vm|cm|mm|in|px|pt|pc|deg|grad|rad|turn|s|ms|Hz|kHz|%)?',
        IShortActionCarrier('attribute.value.unit'),
        '@pop',
      ),
      ],
    'urldeclaration': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@strings',
      ),
        IShortMonarchLanguageRule1(
        '[^)\r\n]+',
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        '\\)',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'tag',
        ),
      ),
      ],
  },
  defaultToken: '',
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
    IMonarchLanguageBracket('[', ']', 'delimiter.bracket'),
    IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
    IMonarchLanguageBracket('<', '>', 'delimiter.angle'),
  ],
  tokenPostfix: '.less',
  extra: <String, Object?>{
      'identifier': '-?-?([a-zA-Z]|(\\\\(([0-9a-fA-F]{1,6}\\s?)|[^[0-9a-fA-F])))([\\w\\-]|(\\\\(([0-9a-fA-F]{1,6}\\s?)|[^[0-9a-fA-F])))*',
      'identifierPlus': '-?-?([a-zA-Z:.]|(\\\\(([0-9a-fA-F]{1,6}\\s?)|[^[0-9a-fA-F])))([\\w\\-:.]|(\\\\(([0-9a-fA-F]{1,6}\\s?)|[^[0-9a-fA-F])))*',
    },
);
