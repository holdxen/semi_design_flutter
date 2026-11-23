// 1:1 translation of monaco-editor/src/languages/definitions/postiats/postiats.ts
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
      'notIn': <Object?>[
        'string',
        'comment',
      ],
      'open': '"',
    },
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
      '(*',
      '*)',
    ],
    'lineComment': '//',
  },
};

/// 1:1: `export const language = <languages.IMonarchLanguage>{...}`
final IMonarchLanguage language = IMonarchLanguage(
  tokenizer: <String, List<IMonarchLanguageRule>>{
    'lexing_COMMENT_block_c': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\/*]+'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\*\\/'),
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('[\\/*]'),
        IShortActionCarrier('comment'),
      ),
      ],
    'lexing_COMMENT_block_ml': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule1(
        RegExp('[^\\(\\*]+'),
        IShortActionCarrier('comment'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\(\\*'),
        IShortActionCarrier('comment'),
        '@push',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\(\\*'),
        IShortActionCarrier('comment.invalid'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('\\*\\)'),
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('\\*'),
        IShortActionCarrier('comment'),
      ),
      ],
    'lexing_COMMENT_rest': <IMonarchLanguageRule>[
        IShortMonarchLanguageRule2(
        RegExp('\$'),
        IShortActionCarrier('comment'),
        '@pop',
      ),
        IShortMonarchLanguageRule1(
        RegExp('.*'),
        IShortActionCarrier('comment'),
      ),
      ],
    'lexing_DQUOTE': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            next: '@pop',
            token: 'string.quote',
          ),
        regex: RegExp('"'),
      ),
        IExpandedMonarchLanguageRule(
        action: IActionListCarrier(<IMonarchLanguageAction>[
            IExpandedMonarchLanguageAction(
              token: 'string.escape',
            ),
            IExpandedMonarchLanguageAction(
              token: 'identifier',
            ),
            IExpandedMonarchLanguageAction(
              token: 'string.escape',
            ),
          ]),
        regex: RegExp('(\\{\\\$)(@IDENTFST@IDENTRST*)(\\})'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'string.escape',
          ),
        regex: RegExp('\\\\\$'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'string.escape',
          ),
        regex: RegExp('\\\\(@ESCHAR|[xX]@xdigit+|@digit+)'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'string',
          ),
        regex: RegExp('[^\\\\"]+'),
      ),
      ],
    'lexing_EFFECT_commaseq0': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            cases: <String, Object?>{
                '@default': <String, Object?>{
                  'token': 'identifier',
                },
                '@keywords_effects': <String, Object?>{
                  'token': 'type.effect',
                },
              },
          ),
        regex: RegExp('@IDENTFST@IDENTRST+|@digit+'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'punctuation',
          ),
        regex: RegExp(','),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            next: '@pop',
            token: '@rematch',
          ),
        regex: RegExp('>'),
      ),
      ],
    'lexing_EXTCODE': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            next: '@pop',
            nextEmbedded: '@pop',
            token: '@rematch',
          ),
        regex: RegExp('^%}'),
      ),
        IExpandedMonarchLanguageRule(
        action: IShortActionCarrier(''),
        regex: RegExp('[^%]+'),
      ),
      ],
    'root': <IMonarchLanguageRule>[
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: '',
          ),
        regex: RegExp('[ \\t\\r\\n]+'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'invalid',
          ),
        regex: RegExp('\\(\\*\\)'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            next: 'lexing_COMMENT_block_ml',
            token: 'comment',
          ),
        regex: RegExp('\\(\\*'),
      ),
        IExpandedMonarchLanguageRule(
        action: IShortActionCarrier('@brackets'),
        regex: RegExp('\\('),
      ),
        IExpandedMonarchLanguageRule(
        action: IShortActionCarrier('@brackets'),
        regex: RegExp('\\)'),
      ),
        IExpandedMonarchLanguageRule(
        action: IShortActionCarrier('@brackets'),
        regex: RegExp('\\['),
      ),
        IExpandedMonarchLanguageRule(
        action: IShortActionCarrier('@brackets'),
        regex: RegExp('\\]'),
      ),
        IExpandedMonarchLanguageRule(
        action: IShortActionCarrier('@brackets'),
        regex: RegExp('\\{'),
      ),
        IExpandedMonarchLanguageRule(
        action: IShortActionCarrier('@brackets'),
        regex: RegExp('\\}'),
      ),
        IExpandedMonarchLanguageRule(
        action: IShortActionCarrier('@brackets'),
        regex: RegExp(',\\('),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'delimiter.comma',
          ),
        regex: RegExp(','),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'delimiter.semicolon',
          ),
        regex: RegExp(';'),
      ),
        IExpandedMonarchLanguageRule(
        action: IShortActionCarrier('@brackets'),
        regex: RegExp('@\\('),
      ),
        IExpandedMonarchLanguageRule(
        action: IShortActionCarrier('@brackets'),
        regex: RegExp('@\\['),
      ),
        IExpandedMonarchLanguageRule(
        action: IShortActionCarrier('@brackets'),
        regex: RegExp('@\\{'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            next: '@lexing_EFFECT_commaseq0',
            token: 'keyword',
          ),
        regex: RegExp(':<'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'identifier.sym',
          ),
        regex: RegExp('\\.@symbolic+'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'number.float',
          ),
        regex: RegExp('\\.@digit*@fexponent@FLOATSP*'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'number.float',
          ),
        regex: RegExp('\\.@digit+'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            cases: <String, Object?>{
                '@default': <String, Object?>{
                  'token': 'namespace',
                },
                '@keywords_dlr': <String, Object?>{
                  'token': 'keyword.dlr',
                },
              },
          ),
        regex: RegExp('\\\$@IDENTFST@IDENTRST*'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            cases: <String, Object?>{
                '@default': <String, Object?>{
                  'token': 'identifier',
                },
                '@keywords_srp': <String, Object?>{
                  'token': 'keyword.srp',
                },
              },
          ),
        regex: RegExp('\\#@IDENTFST@IDENTRST*'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'delimiter.parenthesis',
          ),
        regex: RegExp('%\\('),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            next: '@lexing_EXTCODE',
            nextEmbedded: 'text/javascript',
            token: 'keyword',
          ),
        regex: RegExp('^%{(#|\\^|\\\$)?'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'keyword',
          ),
        regex: RegExp('^%}'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'delimiter.parenthesis',
          ),
        regex: RegExp('\'\\('),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'delimiter.bracket',
          ),
        regex: RegExp('\'\\['),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'delimiter.brace',
          ),
        regex: RegExp('\'\\{'),
      ),
        IShortMonarchLanguageRule1(
        RegExp('(\')(\\\\@ESCHAR|\\\\[xX]@xdigit+|\\\\@digit+)(\')'),
        IActionListCarrier(<IMonarchLanguageAction>[
          IShortActionCarrier('string'),
          IShortActionCarrier('string.escape'),
          IShortActionCarrier('string'),
        ]),
      ),
        IShortMonarchLanguageRule1(
        RegExp('\'[^\\\\\']\''),
        IShortActionCarrier('string'),
      ),
        IShortMonarchLanguageRule2(
        RegExp('"'),
        IShortActionCarrier('string.quote'),
        '@lexing_DQUOTE',
      ),
        IExpandedMonarchLanguageRule(
        action: IShortActionCarrier('@brackets'),
        regex: RegExp('`\\('),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'punctuation',
          ),
        regex: RegExp('\\\\'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'keyword',
          ),
        regex: RegExp('@irregular_keywords(?!@IDENTRST)'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            cases: <String, Object?>{
                '@default': <String, Object?>{
                  'token': 'identifier',
                },
                '@keywords': <String, Object?>{
                  'token': 'keyword',
                },
                '@keywords_types': <String, Object?>{
                  'token': 'type',
                },
              },
          ),
        regex: RegExp('@IDENTFST@IDENTRST*[<!\\[]?'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            next: '@lexing_COMMENT_rest',
            token: 'comment',
          ),
        regex: RegExp('\\/\\/\\/\\/'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'comment',
          ),
        regex: RegExp('\\/\\/.*\$'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            next: '@lexing_COMMENT_block_c',
            token: 'comment',
          ),
        regex: RegExp('\\/\\*'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            next: '@lexing_EFFECT_commaseq0',
            token: 'keyword',
          ),
        regex: RegExp('-<|=<'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            cases: <String, Object?>{
                '@default': 'operator',
                '@operators': 'keyword',
              },
          ),
        regex: RegExp('@symbolic+'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'number.float',
          ),
        regex: RegExp('0[xX]@xdigit+(@hexiexp|@fexponent_bin)@FLOATSP*'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'number.hex',
          ),
        regex: RegExp('0[xX]@xdigit+@INTSP*'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'number.octal',
          ),
        regex: RegExp('0[0-7]+(?![0-9])@INTSP*'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'number.float',
          ),
        regex: RegExp('@digit+(@fexponent|@deciexp)@FLOATSP*'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'number.decimal',
          ),
        regex: RegExp('@digit@digitseq0@INTSP*'),
      ),
        IExpandedMonarchLanguageRule(
        action: IExpandedMonarchLanguageAction(
            token: 'number',
          ),
        regex: RegExp('@digit+@INTSP*'),
      ),
      ],
  },
  defaultToken: 'invalid',
  brackets: <IMonarchLanguageBracket>[
    IMonarchLanguageBracket(',(', ')', 'delimiter.parenthesis'),
    IMonarchLanguageBracket('`(', ')', 'delimiter.parenthesis'),
    IMonarchLanguageBracket('%(', ')', 'delimiter.parenthesis'),
    IMonarchLanguageBracket('\'(', ')', 'delimiter.parenthesis'),
    IMonarchLanguageBracket('\'{', '}', 'delimiter.parenthesis'),
    IMonarchLanguageBracket('@(', ')', 'delimiter.parenthesis'),
    IMonarchLanguageBracket('@{', '}', 'delimiter.brace'),
    IMonarchLanguageBracket('@[', ']', 'delimiter.square'),
    IMonarchLanguageBracket('#[', ']', 'delimiter.square'),
    IMonarchLanguageBracket('{', '}', 'delimiter.curly'),
    IMonarchLanguageBracket('[', ']', 'delimiter.square'),
    IMonarchLanguageBracket('(', ')', 'delimiter.parenthesis'),
    IMonarchLanguageBracket('<', '>', 'delimiter.angle'),
  ],
  start: 'root',
  tokenPostfix: '.pats',
  extra: <String, Object?>{
      'ESCHAR': RegExp('[ntvbrfa\\\\\\?\'"\\(\\[\\{]'),
      'FLOATSP': RegExp('[fFlL]'),
      'IDENTFST': RegExp('[a-zA-Z_]'),
      'IDENTRST': RegExp('[a-zA-Z0-9_\'\$]'),
      'INTSP': RegExp('[lLuU]'),
      'deciexp': RegExp('\\.[0-9]*@fexponent?'),
      'digit': RegExp('[0-9]'),
      'digitseq0': RegExp('@digit*'),
      'fexponent': RegExp('[eE][+-]?[0-9]+'),
      'fexponent_bin': RegExp('[pP][+-]?[0-9]+'),
      'hexiexp': RegExp('\\.[0-9a-zA-Z]*@fexponent_bin?'),
      'irregular_keyword_list': <Object?>[
        'val+',
        'val-',
        'val',
        'case+',
        'case-',
        'case',
        'addr@',
        'addr',
        'fold@',
        'free@',
        'fix@',
        'fix',
        'lam@',
        'lam',
        'llam@',
        'llam',
        'viewt@ype+',
        'viewt@ype-',
        'viewt@ype',
        'viewtype+',
        'viewtype-',
        'viewtype',
        'view+',
        'view-',
        'view@',
        'view',
        'type+',
        'type-',
        'type',
        'vtype+',
        'vtype-',
        'vtype',
        'vt@ype+',
        'vt@ype-',
        'vt@ype',
        'viewt@ype+',
        'viewt@ype-',
        'viewt@ype',
        'viewtype+',
        'viewtype-',
        'viewtype',
        'prop+',
        'prop-',
        'prop',
        'type+',
        'type-',
        'type',
        't@ype',
        't@ype+',
        't@ype-',
        'abst@ype',
        'abstype',
        'absviewt@ype',
        'absvt@ype',
        'for*',
        'for',
        'while*',
        'while',
      ],
      'irregular_keywords': RegExp('val[+-]?|case[+-]?|addr\\@?|fold\\@|free\\@|fix\\@?|lam\\@?|llam\\@?|prop[+-]?|type[+-]?|view[+-@]?|viewt@?ype[+-]?|t@?ype[+-]?|v(iew)?t@?ype[+-]?|abst@?ype|absv(iew)?t@?ype|for\\*?|while\\*?'),
      'keywords': <Object?>[
        'abstype',
        'abst0ype',
        'absprop',
        'absview',
        'absvtype',
        'absviewtype',
        'absvt0ype',
        'absviewt0ype',
        'as',
        'and',
        'assume',
        'begin',
        'classdec',
        'datasort',
        'datatype',
        'dataprop',
        'dataview',
        'datavtype',
        'dataviewtype',
        'do',
        'end',
        'extern',
        'extype',
        'extvar',
        'exception',
        'fn',
        'fnx',
        'fun',
        'prfn',
        'prfun',
        'praxi',
        'castfn',
        'if',
        'then',
        'else',
        'ifcase',
        'in',
        'infix',
        'infixl',
        'infixr',
        'prefix',
        'postfix',
        'implmnt',
        'implement',
        'primplmnt',
        'primplement',
        'import',
        'let',
        'local',
        'macdef',
        'macrodef',
        'nonfix',
        'symelim',
        'symintr',
        'overload',
        'of',
        'op',
        'rec',
        'sif',
        'scase',
        'sortdef',
        'sta',
        'stacst',
        'stadef',
        'static',
        'staload',
        'dynload',
        'try',
        'tkindef',
        'typedef',
        'propdef',
        'viewdef',
        'vtypedef',
        'viewtypedef',
        'prval',
        'var',
        'prvar',
        'when',
        'where',
        'with',
        'withtype',
        'withprop',
        'withview',
        'withvtype',
        'withviewtype',
      ],
      'keywords_dlr': <Object?>[
        '\$delay',
        '\$ldelay',
        '\$arrpsz',
        '\$arrptrsize',
        '\$d2ctype',
        '\$effmask',
        '\$effmask_ntm',
        '\$effmask_exn',
        '\$effmask_ref',
        '\$effmask_wrt',
        '\$effmask_all',
        '\$extern',
        '\$extkind',
        '\$extype',
        '\$extype_struct',
        '\$extval',
        '\$extfcall',
        '\$extmcall',
        '\$literal',
        '\$myfilename',
        '\$mylocation',
        '\$myfunction',
        '\$lst',
        '\$lst_t',
        '\$lst_vt',
        '\$list',
        '\$list_t',
        '\$list_vt',
        '\$rec',
        '\$rec_t',
        '\$rec_vt',
        '\$record',
        '\$record_t',
        '\$record_vt',
        '\$tup',
        '\$tup_t',
        '\$tup_vt',
        '\$tuple',
        '\$tuple_t',
        '\$tuple_vt',
        '\$break',
        '\$continue',
        '\$raise',
        '\$showtype',
        '\$vcopyenv_v',
        '\$vcopyenv_vt',
        '\$tempenver',
        '\$solver_assert',
        '\$solver_verify',
      ],
      'keywords_effects': <Object?>[
        '0',
        'fun',
        'clo',
        'prf',
        'funclo',
        'cloptr',
        'cloref',
        'ref',
        'ntm',
        '1',
      ],
      'keywords_srp': <Object?>[
        '#if',
        '#ifdef',
        '#ifndef',
        '#then',
        '#elif',
        '#elifdef',
        '#elifndef',
        '#else',
        '#endif',
        '#error',
        '#prerr',
        '#print',
        '#assert',
        '#undef',
        '#define',
        '#include',
        '#require',
        '#pragma',
        '#codegen2',
        '#codegen3',
      ],
      'keywords_types': <Object?>[
        'bool',
        'double',
        'byte',
        'int',
        'short',
        'char',
        'void',
        'unit',
        'long',
        'float',
        'string',
        'strptr',
      ],
      'operators': <Object?>[
        '@',
        '!',
        '|',
        '`',
        ':',
        '\$',
        '.',
        '=',
        '#',
        '~',
        '..',
        '...',
        '=>',
        '=<>',
        '=/=>',
        '=>>',
        '=/=>>',
        '<',
        '>',
        '><',
        '.<',
        '>.',
        '.<>.',
        '->',
        '-<>',
      ],
      'symbolic': RegExp('[%&+-./:=@~`^|*!\$#?<>]'),
      'symbols': RegExp('[=><!~?:&|+\\-*\\/\\^%]+'),
      'xdigit': RegExp('[0-9A-Za-z]'),
      'xdigitseq0': RegExp('@xdigit*'),
    },
);
