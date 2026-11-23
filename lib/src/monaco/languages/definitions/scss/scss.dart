// 1:1 translation of monaco-editor/src/languages/definitions/scss/scss.ts
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
  'wordPattern': RegExp('(#?-?\\d*\\.\\d\\w*%?)|([@\$#!.:]?[\\w-?]+%?)|[@#!.]'),
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
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
    'controlstatement': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '[@](if|else|for|while|each|media)',
        IExpandedMonarchLanguageAction(
          next: '@controlstatementdeclaration',
          token: 'keyword.flow',
        ),
      ),
      ],
    'controlstatementdeclaration': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '(in|from|through|if|to)\\b',
        IExpandedMonarchLanguageAction(
          token: 'keyword.flow',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@term',
      ),
        IShortMonarchLanguageRule1(
        '{',
        IExpandedMonarchLanguageAction(
          switchTo: '@selectorbody',
          token: 'delimiter.curly',
        ),
      ),
      ],
    'declarationbody': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@term',
      ),
        IShortMonarchLanguageRule2(
        ';',
        IShortActionCarrier('delimiter'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        '(?=})',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: '',
        ),
      ),
      ],
    'extendbody': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@selectorname',
      ),
        IShortMonarchLanguageRule1(
        '!optional',
        IShortActionCarrier('literal'),
      ),
        IShortMonarchLanguageRule2(
        ';',
        IShortActionCarrier('delimiter'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        '(?=})',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: '',
        ),
      ),
      ],
    'functionarguments': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '\\\$@identifier@ws:',
        IShortActionCarrier('attribute.name'),
      ),
        IShortMonarchLanguageRule1(
        '[,]',
        IShortActionCarrier('delimiter'),
      ),
        IExpandedMonarchLanguageRule(
        include: '@term',
      ),
        IShortMonarchLanguageRule1(
        '\\)',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'meta',
        ),
      ),
      ],
    'functionbody': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '[@](return)',
        IExpandedMonarchLanguageAction(
          token: 'keyword',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@variabledeclaration',
      ),
        IExpandedMonarchLanguageRule(
        include: '@term',
      ),
        IExpandedMonarchLanguageRule(
        include: '@controlstatement',
      ),
        IShortMonarchLanguageRule1(
        ';',
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        '}',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'delimiter.curly',
        ),
      ),
      ],
    'functiondeclaration': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '@identifier@ws\\(',
        IExpandedMonarchLanguageAction(
          next: '@parameterdeclaration',
          token: 'meta',
        ),
      ),
        IShortMonarchLanguageRule1(
        '{',
        IExpandedMonarchLanguageAction(
          switchTo: '@functionbody',
          token: 'delimiter.curly',
        ),
      ),
      ],
    'functioninvocation': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '@identifier\\(',
        IExpandedMonarchLanguageAction(
          next: '@functionarguments',
          token: 'meta',
        ),
      ),
      ],
    'import': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '[@](import)',
        IExpandedMonarchLanguageAction(
          next: '@declarationbody',
          token: 'keyword',
        ),
      ),
      ],
    'includedeclaration': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@functioninvocation',
      ),
        IShortMonarchLanguageRule1(
        '@identifier',
        IShortActionCarrier('meta'),
      ),
        IShortMonarchLanguageRule2(
        ';',
        IShortActionCarrier('delimiter'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        '(?=})',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: '',
        ),
      ),
        IShortMonarchLanguageRule1(
        '{',
        IExpandedMonarchLanguageAction(
          switchTo: '@selectorbody',
          token: 'delimiter.curly',
        ),
      ),
      ],
    'keyframebody': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@term',
      ),
        IShortMonarchLanguageRule1(
        '{',
        IExpandedMonarchLanguageAction(
          next: '@selectorbody',
          token: 'delimiter.curly',
        ),
      ),
        IShortMonarchLanguageRule1(
        '}',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'delimiter.curly',
        ),
      ),
      ],
    'keyframedeclaration': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '@identifier',
        IShortActionCarrier('meta'),
      ),
        IShortMonarchLanguageRule1(
        '{',
        IExpandedMonarchLanguageAction(
          switchTo: '@keyframebody',
          token: 'delimiter.curly',
        ),
      ),
      ],
    'mixindeclaration': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '@identifier@ws\\(',
        IExpandedMonarchLanguageAction(
          next: '@parameterdeclaration',
          token: 'meta',
        ),
      ),
        IShortMonarchLanguageRule1(
        '@identifier',
        IShortActionCarrier('meta'),
      ),
        IShortMonarchLanguageRule1(
        '{',
        IExpandedMonarchLanguageAction(
          switchTo: '@selectorbody',
          token: 'delimiter.curly',
        ),
      ),
      ],
    'name': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '@identifier',
        IShortActionCarrier('attribute.value'),
      ),
      ],
    'nestedproperty': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        '[*_]?@identifier@ws:',
        IShortActionCarrier('attribute.name'),
        '@rulevalue',
      ),
        IExpandedMonarchLanguageRule(
        include: '@comments',
      ),
        IShortMonarchLanguageRule1(
        '}',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'delimiter.curly',
        ),
      ),
      ],
    'numbers': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '(\\d*\\.)?\\d+([eE][\\-+]?\\d+)?',
        IExpandedMonarchLanguageAction(
          next: '@units',
          token: 'number',
        ),
      ),
        IShortMonarchLanguageRule1(
        '#[0-9a-fA-F_]+(?!\\w)',
        IShortActionCarrier('number.hex'),
      ),
      ],
    'parameterdeclaration': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '\\\$@identifier@ws:',
        IShortActionCarrier('variable.decl'),
      ),
        IShortMonarchLanguageRule1(
        '\\.\\.\\.',
        IShortActionCarrier('operator'),
      ),
        IShortMonarchLanguageRule1(
        ',',
        IShortActionCarrier('delimiter'),
      ),
        IExpandedMonarchLanguageRule(
        include: '@term',
      ),
        IShortMonarchLanguageRule1(
        '\\)',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'meta',
        ),
      ),
      ],
    'parenthizedterm': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@term',
      ),
        IShortMonarchLanguageRule1(
        '\\)',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'delimiter.parenthesis',
        ),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@selector',
      ),
      ],
    'rulevalue': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@term',
      ),
        IShortMonarchLanguageRule1(
        '!important',
        IShortActionCarrier('literal'),
      ),
        IShortMonarchLanguageRule2(
        ';',
        IShortActionCarrier('delimiter'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        '{',
        IExpandedMonarchLanguageAction(
          switchTo: '@nestedproperty',
          token: 'delimiter.curly',
        ),
      ),
        IShortMonarchLanguageRule1(
        '(?=})',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: '',
        ),
      ),
      ],
    'selector': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@comments',
      ),
        IExpandedMonarchLanguageRule(
        include: '@import',
      ),
        IExpandedMonarchLanguageRule(
        include: '@variabledeclaration',
      ),
        IExpandedMonarchLanguageRule(
        include: '@warndebug',
      ),
        IShortMonarchLanguageRule1(
        '[@](include)',
        IExpandedMonarchLanguageAction(
          next: '@includedeclaration',
          token: 'keyword',
        ),
      ),
        IShortMonarchLanguageRule1(
        '[@](keyframes|-webkit-keyframes|-moz-keyframes|-o-keyframes)',
        IExpandedMonarchLanguageAction(
          next: '@keyframedeclaration',
          token: 'keyword',
        ),
      ),
        IShortMonarchLanguageRule1(
        '[@](page|content|font-face|-moz-document)',
        IExpandedMonarchLanguageAction(
          token: 'keyword',
        ),
      ),
        IShortMonarchLanguageRule1(
        '[@](charset|namespace)',
        IExpandedMonarchLanguageAction(
          next: '@declarationbody',
          token: 'keyword',
        ),
      ),
        IShortMonarchLanguageRule1(
        '[@](function)',
        IExpandedMonarchLanguageAction(
          next: '@functiondeclaration',
          token: 'keyword',
        ),
      ),
        IShortMonarchLanguageRule1(
        '[@](mixin)',
        IExpandedMonarchLanguageAction(
          next: '@mixindeclaration',
          token: 'keyword',
        ),
      ),
        IShortMonarchLanguageRule1(
        'url(\\-prefix)?\\(',
        IExpandedMonarchLanguageAction(
          next: '@urldeclaration',
          token: 'meta',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@controlstatement',
      ),
        IExpandedMonarchLanguageRule(
        include: '@selectorname',
      ),
        IShortMonarchLanguageRule1(
        '[&\\*]',
        IShortActionCarrier('tag'),
      ),
        IShortMonarchLanguageRule1(
        '[>\\+,]',
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        '\\[',
        IExpandedMonarchLanguageAction(
          next: '@selectorattribute',
          token: 'delimiter.bracket',
        ),
      ),
        IShortMonarchLanguageRule1(
        '{',
        IExpandedMonarchLanguageAction(
          next: '@selectorbody',
          token: 'delimiter.curly',
        ),
      ),
      ],
    'selectorattribute': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@term',
      ),
        IShortMonarchLanguageRule1(
        ']',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'delimiter.bracket',
        ),
      ),
      ],
    'selectorbody': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        '[*_]?@identifier@ws:(?=(\\s|\\d|[^{;}]*[;}]))',
        IShortActionCarrier('attribute.name'),
        '@rulevalue',
      ),
        IExpandedMonarchLanguageRule(
        include: '@selector',
      ),
        IShortMonarchLanguageRule1(
        '[@](extend)',
        IExpandedMonarchLanguageAction(
          next: '@extendbody',
          token: 'keyword',
        ),
      ),
        IShortMonarchLanguageRule1(
        '[@](return)',
        IExpandedMonarchLanguageAction(
          next: '@declarationbody',
          token: 'keyword',
        ),
      ),
        IShortMonarchLanguageRule1(
        '}',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'delimiter.curly',
        ),
      ),
      ],
    'selectorname': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '#{',
        IExpandedMonarchLanguageAction(
          next: '@variableinterpolation',
          token: 'meta',
        ),
      ),
        IShortMonarchLanguageRule1(
        '(\\.|#(?=[^{])|%|(@identifier)|:)+',
        IShortActionCarrier('tag'),
      ),
      ],
    'stringenddoublequote': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '\\\\.',
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        '"',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.delimiter',
        ),
      ),
        IShortMonarchLanguageRule1(
        '.',
        IShortActionCarrier('string'),
      ),
      ],
    'stringendquote': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '\\\\.',
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule1(
        '\'',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string.delimiter',
        ),
      ),
        IShortMonarchLanguageRule1(
        '.',
        IShortActionCarrier('string'),
      ),
      ],
    'strings': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '~?"',
        IExpandedMonarchLanguageAction(
          next: '@stringenddoublequote',
          token: 'string.delimiter',
        ),
      ),
        IShortMonarchLanguageRule1(
        '~?\'',
        IExpandedMonarchLanguageAction(
          next: '@stringendquote',
          token: 'string.delimiter',
        ),
      ),
      ],
    'term': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@comments',
      ),
        IShortMonarchLanguageRule1(
        'url(\\-prefix)?\\(',
        IExpandedMonarchLanguageAction(
          next: '@urldeclaration',
          token: 'meta',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: '@functioninvocation',
      ),
        IExpandedMonarchLanguageRule(
        include: '@numbers',
      ),
        IExpandedMonarchLanguageRule(
        include: '@strings',
      ),
        IExpandedMonarchLanguageRule(
        include: '@variablereference',
      ),
        IShortMonarchLanguageRule1(
        '(and\\b|or\\b|not\\b)',
        IShortActionCarrier('operator'),
      ),
        IExpandedMonarchLanguageRule(
        include: '@name',
      ),
        IShortMonarchLanguageRule1(
        '([<>=\\+\\-\\*\\/\\^\\|\\~,])',
        IShortActionCarrier('operator'),
      ),
        IShortMonarchLanguageRule1(
        ',',
        IShortActionCarrier('delimiter'),
      ),
        IShortMonarchLanguageRule1(
        '!default',
        IShortActionCarrier('literal'),
      ),
        IShortMonarchLanguageRule1(
        '\\(',
        IExpandedMonarchLanguageAction(
          next: '@parenthizedterm',
          token: 'delimiter.parenthesis',
        ),
      ),
      ],
    'units': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        '(em|ex|ch|rem|fr|vmin|vmax|vw|vh|vm|cm|mm|in|px|pt|pc|deg|grad|rad|turn|s|ms|Hz|kHz|%)?',
        IShortActionCarrier('number'),
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
          token: 'meta',
        ),
      ),
      ],
    'variabledeclaration': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        '\\\$@identifier@ws:',
        IShortActionCarrier('variable.decl'),
        '@declarationbody',
      ),
      ],
    'variableinterpolation': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        include: '@variablereference',
      ),
        IShortMonarchLanguageRule1(
        '}',
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'meta',
        ),
      ),
      ],
    'variablereference': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '\\\$@identifier',
        IShortActionCarrier('variable.ref'),
      ),
        IShortMonarchLanguageRule1(
        '\\.\\.\\.',
        IShortActionCarrier('operator'),
      ),
        IShortMonarchLanguageRule1(
        '#{',
        IExpandedMonarchLanguageAction(
          next: '@variableinterpolation',
          token: 'meta',
        ),
      ),
      ],
    'warndebug': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        '[@](warn|debug)',
        IExpandedMonarchLanguageAction(
          next: '@declarationbody',
          token: 'keyword',
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
  tokenPostfix: '.scss',
  extra: <String, Object?>{
      'identifier': '-?-?([a-zA-Z]|(\\\\(([0-9a-fA-F]{1,6}\\s?)|[^[0-9a-fA-F])))([\\w\\-]|(\\\\(([0-9a-fA-F]{1,6}\\s?)|[^[0-9a-fA-F])))*',
      'ws': '[ \t\n\r\f]*',
    },
);
