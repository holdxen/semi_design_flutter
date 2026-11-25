// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/languages/supports/characterPair.ts
// Translated 1:1. Carrier interfaces for languageConfiguration.ts are local
// because that file is not ported yet (erased-interface convention).
// ---------------------------------------------------------------------------

/// 1:1: `IAutoClosingPair`.
class IAutoClosingPair {
  final String open;
  final String close;

  IAutoClosingPair(this.open, this.close);
}

/// 1:1: `IAutoClosingPairConditional`.
class IAutoClosingPairConditional extends IAutoClosingPair {
  final List<String>? notIn;
  final Object? beforeText;

  bool inString = true;
  bool inComment = true;
  bool inRegEx = true;

  IAutoClosingPairConditional({
    required String open,
    required String close,
    this.notIn,
    this.beforeText,
  }) : super(open, close) {
    if (notIn != null) {
      for (final String item in notIn!) {
        switch (item) {
          case 'string':
            inString = false;
            break;
          case 'comment':
            inComment = false;
            break;
          case 'regex':
            inRegEx = false;
            break;
        }
      }
    }
  }
}

/// 1:1: `StandardAutoClosingPairConditional` (constructor logic folded into
/// the carrier above; the source only stores open/close/beforeText plus flags).
class StandardAutoClosingPairConditional extends IAutoClosingPairConditional {
  StandardAutoClosingPairConditional(IAutoClosingPairConditional source)
      : super(
          open: source.open,
          close: source.close,
          notIn: source.notIn,
          beforeText: source.beforeText,
        );
}

/// 1:1: `IDocComment` (legacy, partially supported).
class IDocComment {
  final String open;
  final String close;

  IDocComment(this.open, this.close);
}

/// 1:1: `__electricCharacterSupport` carrier.
class ElectricCharacterSupport {
  final IDocComment? docComment;

  ElectricCharacterSupport({this.docComment});
}

/// 1:1: `LanguageConfiguration` carrier (fields read here).
class LanguageConfiguration {
  final List<IAutoClosingPairConditional>? autoClosingPairs;
  final List<List<String>>? brackets;
  final ElectricCharacterSupport? electricCharacterSupport;
  final String? autoCloseBefore;
  final List<IAutoClosingPair>? surroundingPairs;

  LanguageConfiguration({
    this.autoClosingPairs,
    this.brackets,
    this.electricCharacterSupport,
    this.autoCloseBefore,
    this.surroundingPairs,
  });
}

/// 1:1: `export class CharacterPairSupport`.
class CharacterPairSupport {
  static const String
      DEFAULT_AUTOCLOSE_BEFORE_LANGUAGE_DEFINED_QUOTES = ';:.,=}])> \n\t';
  static const String
      DEFAULT_AUTOCLOSE_BEFORE_LANGUAGE_DEFINED_BRACKETS = '\'"`;:.,=}])> \n\t';
  static const String DEFAULT_AUTOCLOSE_BEFORE_WHITESPACE = ' \n\t';

  late final List<StandardAutoClosingPairConditional> _autoClosingPairs;
  late final List<IAutoClosingPair> _surroundingPairs;
  late final String _autoCloseBeforeForQuotes;
  late final String _autoCloseBeforeForBrackets;

  CharacterPairSupport(LanguageConfiguration config) {
    _autoClosingPairs = _buildAutoClosingPairs(config);
    _autoCloseBeforeForQuotes = config.autoCloseBefore ??
        DEFAULT_AUTOCLOSE_BEFORE_LANGUAGE_DEFINED_QUOTES;
    _autoCloseBeforeForBrackets = config.autoCloseBefore ??
        DEFAULT_AUTOCLOSE_BEFORE_LANGUAGE_DEFINED_BRACKETS;
    // TS `config.surroundingPairs || this._autoClosingPairs`: share the exact
    // list instance when the config does not provide its own.
    _surroundingPairs = config.surroundingPairs ?? _autoClosingPairs;
  }

  static List<StandardAutoClosingPairConditional> _buildAutoClosingPairs(
      LanguageConfiguration config) {
    late List<StandardAutoClosingPairConditional> pairs;
    if (config.autoClosingPairs != null) {
      pairs = config.autoClosingPairs!
          .map((el) => StandardAutoClosingPairConditional(el))
          .toList();
    } else if (config.brackets != null) {
      pairs = config.brackets!
          .map((b) => StandardAutoClosingPairConditional(
              IAutoClosingPairConditional(open: b[0], close: b[1])))
          .toList();
    } else {
      pairs = <StandardAutoClosingPairConditional>[];
    }

    final IDocComment? docComment =
        config.electricCharacterSupport?.docComment;
    if (docComment != null) {
      pairs.add(StandardAutoClosingPairConditional(
          IAutoClosingPairConditional(
              open: docComment.open, close: docComment.close)));
    }
    return pairs;
  }

  List<StandardAutoClosingPairConditional> getAutoClosingPairs() =>
      _autoClosingPairs;

  String getAutoCloseBeforeSet(bool forQuotes) =>
      forQuotes ? _autoCloseBeforeForQuotes : _autoCloseBeforeForBrackets;

  List<IAutoClosingPair> getSurroundingPairs() => _surroundingPairs;
}
