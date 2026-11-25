// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/modes/supports/autoClosingPairsRules.ts
// Translated 1:1. `IAutoClosingPair` interfaces are carried locally because
// common/languages/languageConfiguration.ts is not ported yet (same erased-
// interface convention used elsewhere in this tree).
// ---------------------------------------------------------------------------

/// 1:1: `IAutoClosingPair` carrier.
class IAutoClosingPair {
  final String open;
  final String close;

  const IAutoClosingPair(this.open, this.close);

  Map<String, Object?> toJson() => <String, Object?>{
        'open': open,
        'close': close,
      };
}

/// 1:1: `IAutoClosingPairConditional` carrier.
class IAutoClosingPairConditional extends IAutoClosingPair {
  final List<String>? notIn;

  const IAutoClosingPairConditional(
    String open,
    String close, [
    this.notIn,
  ]) : super(open, close);

  @override
  Map<String, Object?> toJson() {
    final Map<String, Object?> json = super.toJson();
    if (notIn != null) {
      json['notIn'] = notIn;
    }
    return json;
  }
}

/// 1:1: `export const javascriptAutoClosingPairsRules`.
const List<IAutoClosingPairConditional> javascriptAutoClosingPairsRules =
    <IAutoClosingPairConditional>[
  IAutoClosingPairConditional('{', '}'),
  IAutoClosingPairConditional('[', ']'),
  IAutoClosingPairConditional('(', ')'),
  IAutoClosingPairConditional("'", "'", <String>['string', 'comment']),
  IAutoClosingPairConditional('"', '"', <String>['string']),
  IAutoClosingPairConditional('`', '`', <String>['string', 'comment']),
  IAutoClosingPairConditional('/**', ' */', <String>['string']),
];

/// 1:1: `export const latexAutoClosingPairsRules`.
const List<IAutoClosingPair> latexAutoClosingPairsRules = <IAutoClosingPair>[
  IAutoClosingPair(r'\left(', r'\right)'),
  IAutoClosingPair(r'\left[', r'\right]'),
  IAutoClosingPair(r'\left\{', r'\right\}'),
  IAutoClosingPair(r'\bigl(', r'\bigr)'),
  IAutoClosingPair(r'\bigl[', r'\bigr]'),
  IAutoClosingPair(r'\bigl\{', r'\bigr\}'),
  IAutoClosingPair(r'\Bigl(', r'\Bigr)'),
  IAutoClosingPair(r'\Bigl[', r'\Bigr]'),
  IAutoClosingPair(r'\Bigl\{', r'\Bigr\}'),
  IAutoClosingPair(r'\biggl(', r'\biggr)'),
  IAutoClosingPair(r'\biggl[', r'\biggr]'),
  IAutoClosingPair(r'\biggl\{', r'\biggr\}'),
  IAutoClosingPair(r'\Biggl(', r'\Biggr)'),
  IAutoClosingPair(r'\Biggl[', r'\Biggr]'),
  IAutoClosingPair(r'\Biggl\{', r'\Biggr\}'),
  IAutoClosingPair(r'\(', r'\)'),
  IAutoClosingPair(r'\[', r'\]'),
  IAutoClosingPair(r'\{', r'\}'),
  IAutoClosingPair('{', '}'),
  IAutoClosingPair('[', ']'),
  IAutoClosingPair('(', ')'),
  IAutoClosingPair('`', "'"),
];
