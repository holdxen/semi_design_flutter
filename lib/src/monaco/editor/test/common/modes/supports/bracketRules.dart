// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/modes/supports/bracketRules.ts
// Translated 1:1. `CharacterPair` is a `[string, string]` tuple carried as
// `List<String>`; the standard table is one shared constant, as in the source.
// ---------------------------------------------------------------------------

/// 1:1: `const standardBracketRules`.
const List<List<String>> standardBracketRules = <List<String>>[
  <String>['{', '}'],
  <String>['[', ']'],
  <String>['(', ')'],
];

/// 1:1: `export const rubyBracketRules = standardBracketRules`.
const List<List<String>> rubyBracketRules = standardBracketRules;

/// 1:1: `export const cppBracketRules = standardBracketRules`.
const List<List<String>> cppBracketRules = standardBracketRules;

/// 1:1: `export const goBracketRules = standardBracketRules`.
const List<List<String>> goBracketRules = standardBracketRules;

/// 1:1: `export const phpBracketRules = standardBracketRules`.
const List<List<String>> phpBracketRules = standardBracketRules;

/// 1:1: `export const vbBracketRules = standardBracketRules`.
const List<List<String>> vbBracketRules = standardBracketRules;

/// 1:1: `export const luaBracketRules = standardBracketRules`.
const List<List<String>> luaBracketRules = standardBracketRules;

/// 1:1: `export const htmlBracketRules`.
const List<List<String>> htmlBracketRules = <List<String>>[
  <String>['<!--', '-->'],
  <String>['{', '}'],
  <String>['(', ')'],
];

/// 1:1: `export const typescriptBracketRules`.
const List<List<String>> typescriptBracketRules = <List<String>>[
  <String>[r'${', '}'],
  <String>['{', '}'],
  <String>['[', ']'],
  <String>['(', ')'],
];

/// 1:1: `export const latexBracketRules`.
const List<List<String>> latexBracketRules = <List<String>>[
  <String>['{', '}'],
  <String>['[', ']'],
  <String>['(', ')'],
  <String>['[', ')'],
  <String>['(', ']'],
  <String>[r'\left(', r'\right)'],
  <String>[r'\left(', r'\right.'],
  <String>[r'\left.', r'\right)'],
  <String>[r'\left[', r'\right]'],
  <String>[r'\left[', r'\right.'],
  <String>[r'\left.', r'\right]'],
  <String>[r'\left\{', r'\right\}'],
  <String>[r'\left\{', r'\right.'],
  <String>[r'\left.', r'\right\}'],
  <String>[r'\left<', r'\right>'],
  <String>[r'\bigl(', r'\bigr)'],
  <String>[r'\bigl[', r'\bigr]'],
  <String>[r'\bigl\{', r'\bigr\}'],
  <String>[r'\Bigl(', r'\Bigr)'],
  <String>[r'\Bigl[', r'\Bigr]'],
  <String>[r'\Bigl\{', r'\Bigr\}'],
  <String>[r'\biggl(', r'\biggr)'],
  <String>[r'\biggl[', r'\biggr]'],
  <String>[r'\biggl\{', r'\biggr\}'],
  <String>[r'\Biggl(', r'\Biggr)'],
  <String>[r'\Biggl[', r'\Biggr]'],
  <String>[r'\Biggl\{', r'\Biggr\}'],
  <String>[r'\langle', r'\rangle'],
  <String>[r'\lvert', r'\rvert'],
  <String>[r'\lVert', r'\rVert'],
  <String>[r'\left|', r'\right|'],
  <String>[r'\left\vert', r'\right\vert'],
  <String>[r'\left\|', r'\right\|'],
  <String>[r'\left\Vert', r'\right\Vert'],
  <String>[r'\left\langle', r'\right\rangle'],
  <String>[r'\left\lvert', r'\right\rvert'],
  <String>[r'\left\lVert', r'\right\rVert'],
  <String>[r'\bigl\langle', r'\bigr\rangle'],
  <String>[r'\bigl|', r'\bigr|'],
  <String>[r'\bigl\vert', r'\bigr\vert'],
  <String>[r'\bigl\lvert', r'\bigr\rvert'],
  <String>[r'\bigl\|', r'\bigr\|'],
  <String>[r'\bigl\lVert', r'\bigr\rVert'],
  <String>[r'\bigl\Vert', r'\bigr\Vert'],
  <String>[r'\Bigl\langle', r'\Bigr\rangle'],
  <String>[r'\Bigl|', r'\Bigr|'],
  <String>[r'\Bigl\lvert', r'\Bigr\rvert'],
  <String>[r'\Bigl\vert', r'\Bigr\vert'],
  <String>[r'\Bigl\|', r'\Bigr\|'],
  <String>[r'\Bigl\lVert', r'\Bigr\rVert'],
  <String>[r'\Bigl\Vert', r'\Bigr\Vert'],
  <String>[r'\biggl\langle', r'\biggr\rangle'],
  <String>[r'\biggl|', r'\biggr|'],
  <String>[r'\biggl\lvert', r'\biggr\rvert'],
  <String>[r'\biggl\vert', r'\biggr\vert'],
  <String>[r'\biggl\|', r'\biggr\|'],
  <String>[r'\biggl\lVert', r'\biggr\rVert'],
  <String>[r'\biggl\Vert', r'\biggr\Vert'],
  <String>[r'\Biggl\langle', r'\Biggr\rangle'],
  <String>[r'\Biggl|', r'\Biggr|'],
  <String>[r'\Biggl\lvert', r'\Biggr\rvert'],
  <String>[r'\Biggl\vert', r'\Biggr\vert'],
  <String>[r'\Biggl\|', r'\Biggr\|'],
  <String>[r'\Biggl\lVert', r'\Biggr\rVert'],
  <String>[r'\Biggl\Vert', r'\Biggr\Vert'],
];
