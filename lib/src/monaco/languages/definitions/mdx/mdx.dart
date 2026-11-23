// 1:1 translation of monaco-editor/src/languages/definitions/mdx/mdx.ts
// Monarch language definition data, evaluated from the TS source via
// the TypeScript compiler (computed template/const values resolved).
// TS object literals -> Dart data; typed rule/action/bracket carriers
// mirror the ported monarchCompile. Regex flags preserved in RegExp.

import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchTypes.dart';

/// 1:1: `export const conf: languages.LanguageConfiguration = {...}`
final Map<String, Object?> conf = <String, Object?>{
  'autoClosingPairs': <Object?>[
    <String, Object?>{
      'close': '"',
      'open': '"',
    },
    <String, Object?>{
      'close': '\'',
      'open': '\'',
    },
    <String, Object?>{
      'close': '”',
      'open': '“',
    },
    <String, Object?>{
      'close': '’',
      'open': '‘',
    },
    <String, Object?>{
      'close': '`',
      'open': '`',
    },
    <String, Object?>{
      'close': '}',
      'open': '{',
    },
    <String, Object?>{
      'close': ')',
      'open': '(',
    },
    <String, Object?>{
      'close': '_',
      'open': '_',
    },
    <String, Object?>{
      'close': '**',
      'open': '**',
    },
    <String, Object?>{
      'close': '>',
      'open': '<',
    },
  ],
  'brackets': <Object?>[
    <Object?>[
      '{',
      '}',
    ],
  ],
  'comments': <String, Object?>{
    'blockComment': <Object?>[
      '{/*',
      '*/}',
    ],
  },
  'onEnterRules': <Object?>[
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '- ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^\\s*- .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '+ ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^\\s*\\+ .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '* ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^\\s*\\* .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '> ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^> '),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'indentAction': 1,
      },
      'beforeText': RegExp('<\\w+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'indentAction': 1,
      },
      'beforeText': RegExp('\\s+>\\s*\$'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'indentAction': 3,
      },
      'beforeText': RegExp('<\\/\\w+>'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '1. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^0\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '2. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^1\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '3. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^2\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '4. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^3\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '5. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^4\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '6. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^5\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '7. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^6\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '8. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^7\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '9. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^8\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '10. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^9\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '11. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^10\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '12. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^11\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '13. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^12\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '14. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^13\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '15. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^14\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '16. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^15\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '17. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^16\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '18. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^17\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '19. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^18\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '20. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^19\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '21. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^20\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '22. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^21\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '23. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^22\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '24. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^23\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '25. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^24\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '26. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^25\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '27. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^26\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '28. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^27\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '29. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^28\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '30. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^29\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '31. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^30\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '32. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^31\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '33. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^32\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '34. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^33\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '35. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^34\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '36. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^35\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '37. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^36\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '38. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^37\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '39. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^38\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '40. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^39\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '41. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^40\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '42. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^41\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '43. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^42\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '44. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^43\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '45. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^44\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '46. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^45\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '47. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^46\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '48. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^47\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '49. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^48\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '50. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^49\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '51. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^50\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '52. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^51\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '53. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^52\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '54. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^53\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '55. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^54\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '56. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^55\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '57. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^56\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '58. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^57\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '59. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^58\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '60. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^59\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '61. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^60\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '62. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^61\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '63. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^62\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '64. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^63\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '65. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^64\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '66. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^65\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '67. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^66\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '68. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^67\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '69. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^68\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '70. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^69\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '71. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^70\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '72. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^71\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '73. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^72\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '74. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^73\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '75. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^74\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '76. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^75\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '77. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^76\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '78. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^77\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '79. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^78\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '80. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^79\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '81. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^80\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '82. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^81\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '83. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^82\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '84. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^83\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '85. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^84\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '86. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^85\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '87. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^86\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '88. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^87\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '89. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^88\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '90. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^89\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '91. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^90\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '92. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^91\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '93. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^92\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '94. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^93\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '95. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^94\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '96. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^95\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '97. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^96\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '98. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^97\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '99. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^98\\. .+'),
    },
    <String, Object?>{
      'action': <String, Object?>{
        'appendText': '100. ',
        'indentAction': 0,
      },
      'beforeText': RegExp('^99\\. .+'),
    },
  ],
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'codeblock_backtick': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\s*`{3,}\\s*\$'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.*\$'),
        IShortActionCarrier('variable.source'),
      ),
      ],
    'codeblock_highlight_backtick': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\s*`{3,}\\s*\$'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          nextEmbedded: '@pop',
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.*\$'),
        IShortActionCarrier('variable.source'),
      ),
      ],
    'codeblock_highlight_tilde': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\s*~{3,}\\s*\$'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          nextEmbedded: '@pop',
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.*\$'),
        IShortActionCarrier('variable.source'),
      ),
      ],
    'codeblock_tilde': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\s*~{3,}\\s*\$'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('.*\$'),
        IShortActionCarrier('variable.source'),
      ),
      ],
    'content': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('(\\[)(.+)(]\\()(.+)(\\s+".*")(\\))'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier(''),
          IShortActionCarrier('string.link'),
          IShortActionCarrier(''),
          IShortActionCarrier('type.identifier'),
          IShortActionCarrier('string.link'),
          IShortActionCarrier(''),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\[)(.+)(]\\()(.+)(\\))'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier(''),
          IShortActionCarrier('type.identifier'),
          IShortActionCarrier(''),
          IShortActionCarrier('string.link'),
          IShortActionCarrier(''),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\[)(.+)(]\\[)(.+)(])'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier(''),
          IShortActionCarrier('type.identifier'),
          IShortActionCarrier(''),
          IShortActionCarrier('type.identifier'),
          IShortActionCarrier(''),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\[)(.+)(]:\\s+)(\\S*)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier(''),
          IShortActionCarrier('type.identifier'),
          IShortActionCarrier(''),
          IShortActionCarrier('string.link'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\[)(.+)(])'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier(''),
          IShortActionCarrier('type.identifier'),
          IShortActionCarrier(''),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('`.*`'),
        IShortActionCarrier('variable.source'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('_'),
        IExpandedMonarchLanguageAction(
          next: '@emphasis_underscore',
          token: 'emphasis',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\*(?!\\*)'),
        IExpandedMonarchLanguageAction(
          next: '@emphasis_asterisk',
          token: 'emphasis',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\*\\*'),
        IExpandedMonarchLanguageAction(
          next: '@strong',
          token: 'strong',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('{'),
        IExpandedMonarchLanguageAction(
          next: '@expression',
          nextEmbedded: 'js',
          token: 'delimiter.bracket',
        ),
      ),
      ],
    'emphasis_asterisk': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\*(?!\\*)'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'emphasis',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: 'content',
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IExpandedMonarchLanguageAction(
          token: 'emphasis',
        ),
      ),
      ],
    'emphasis_underscore': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('_'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'emphasis',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: 'content',
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IExpandedMonarchLanguageAction(
          token: 'emphasis',
        ),
      ),
      ],
    'export': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('^\\s*\$'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          nextEmbedded: '@pop',
          token: 'delimiter.bracket',
        ),
      ),
      ],
    'expression': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('{'),
        IExpandedMonarchLanguageAction(
          next: '@expression',
          token: 'delimiter.bracket',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('}'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          nextEmbedded: '@pop',
          token: 'delimiter.bracket',
        ),
      ),
      ],
    'frontmatter': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('^---\$'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          nextEmbedded: '@pop',
          token: 'meta.content',
        ),
      ),
      ],
    'header': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('.\$'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'keyword',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: 'content',
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IExpandedMonarchLanguageAction(
          token: 'keyword',
        ),
      ),
      ],
    'import': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\'\\s*(;|\$)'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          nextEmbedded: '@pop',
          token: 'string',
        ),
      ),
      ],
    'jsx': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\s+'),
        IShortActionCarrier(''),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\w+)(=)("(?:[^"\\\\]|\\\\.)*")'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('attribute.name'),
          IShortActionCarrier('operator'),
          IShortActionCarrier('string'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\w+)(=)(\'(?:[^\'\\\\]|\\\\.)*\')'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('attribute.name'),
          IShortActionCarrier('operator'),
          IShortActionCarrier('string'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\\w+(?=\\s|>|={|\$))'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('attribute.name'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('={'),
        IExpandedMonarchLanguageAction(
          next: '@expression',
          nextEmbedded: 'js',
          token: 'delimiter.bracket',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('>'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'type.identifier',
        ),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('^---\$'),
        IExpandedMonarchLanguageAction(
          next: '@frontmatter',
          nextEmbedded: 'yaml',
          token: 'meta.content',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^\\s*import'),
        IExpandedMonarchLanguageAction(
          next: '@import',
          nextEmbedded: 'js',
          token: 'keyword',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^\\s*export'),
        IExpandedMonarchLanguageAction(
          next: '@export',
          nextEmbedded: 'js',
          token: 'keyword',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<\\w+'),
        IExpandedMonarchLanguageAction(
          next: '@jsx',
          token: 'type.identifier',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('<\\/?\\w+>'),
        IShortActionCarrier('type.identifier'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^(\\s*)(>*\\s*)(#{1,6}\\s)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IExpandedMonarchLanguageAction(
            token: 'white',
          ),
          IExpandedMonarchLanguageAction(
            token: 'comment',
          ),
          IExpandedMonarchLanguageAction(
            next: '@header',
            token: 'keyword',
          ),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^(\\s*)(>*\\s*)([*+-])(\\s+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('white'),
          IShortActionCarrier('comment'),
          IShortActionCarrier('keyword'),
          IShortActionCarrier('white'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^(\\s*)(>*\\s*)(\\d{1,9}\\.)(\\s+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('white'),
          IShortActionCarrier('comment'),
          IShortActionCarrier('number'),
          IShortActionCarrier('white'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^(\\s*)(>*\\s*)(\\d{1,9}\\.)(\\s+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('white'),
          IShortActionCarrier('comment'),
          IShortActionCarrier('number'),
          IShortActionCarrier('white'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^(\\s*)(>*\\s*)(-{3,}|\\*{3,}|_{3,})\$'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('white'),
          IShortActionCarrier('comment'),
          IShortActionCarrier('keyword'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('`{3,}(\\s.*)?\$'),
        IExpandedMonarchLanguageAction(
          next: '@codeblock_backtick',
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('~{3,}(\\s.*)?\$'),
        IExpandedMonarchLanguageAction(
          next: '@codeblock_tilde',
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('`{3,}(\\S+).*\$'),
        IExpandedMonarchLanguageAction(
          next: '@codeblock_highlight_backtick',
          nextEmbedded: '\$1',
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('~{3,}(\\S+).*\$'),
        IExpandedMonarchLanguageAction(
          next: '@codeblock_highlight_tilde',
          nextEmbedded: '\$1',
          token: 'string',
        ),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^(\\s*)(-{4,})\$'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('white'),
          IShortActionCarrier('comment'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('^(\\s*)(>+)'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('white'),
          IShortActionCarrier('comment'),
        ]),
      ),
        IExpandedMonarchLanguageRule(
        include: 'content',
      ),
      ],
    'strong': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('\\*\\*'),
        IExpandedMonarchLanguageAction(
          next: '@pop',
          token: 'strong',
        ),
      ),
        IExpandedMonarchLanguageRule(
        include: 'content',
      ),
        IShortMonarchLanguageRule1(
        RegExp('.'),
        IExpandedMonarchLanguageAction(
          token: 'strong',
        ),
      ),
      ],
  },
  defaultToken: '',
  tokenPostfix: '.mdx',
  extra: <String, Object?>{
      'control': RegExp('[!#()*+.[\\\\\\]_`{}\\-]'),
      'escapes': RegExp('\\\\@control'),
    },
);
