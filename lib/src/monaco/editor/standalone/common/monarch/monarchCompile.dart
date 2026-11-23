// 1:1 translation of
// vscode/src/vs/editor/standalone/common/monarch/monarchCompile.ts
//
// This module only exports 'compile' which compiles a JSON language definition
// into a typed and checked ILexer definition.
import '../../../../base/common/types.dart' show isString;
import 'monarchCommon.dart' as monarchCommon;
import 'monarchCommon.dart'
    show
        FuzzyAction,
        IAction,
        IBranch,
        ILexer,
        ILexerMin,
        IBracket,
        IRule,
        MonarchBracket;
import 'monarchTypes.dart'
    show
        IMonarchLanguage,
        IMonarchLanguageBracket,
        IShortActionCarrier,
        IActionListCarrier,
        IExpandedMonarchLanguageAction,
        IShortMonarchLanguageRule1,
        IShortMonarchLanguageRule2,
        IExpandedMonarchLanguageRule;

// ============================================================================
// Concrete carriers for the abstract interfaces in monarchCommon.dart
// ============================================================================

class _Action implements IAction {
  @override
  List<FuzzyAction>? group;
  @override
  bool hasEmbeddedEndInCases = false;
  @override
  Object? Function(String id, List<String> matches, String state, bool eos)?
      test;
  @override
  String? token;
  @override
  bool tokenSubst = false;
  @override
  String? next;
  @override
  String? nextEmbedded;
  @override
  int? bracket;
  @override
  String? log;
  @override
  String? switchTo;
  @override
  int? goBack;
  @override
  List<String>? Function(List<String> states)? transform;

  _Action({
    this.token,
    this.group,
    this.hasEmbeddedEndInCases = false,
    this.test,
  });
}

class _Branch implements IBranch {
  @override
  final String name;
  @override
  final FuzzyAction value;
  @override
  final bool Function(String id, List<String> matches, String state, bool eos)?
      test;

  _Branch({required this.name, required this.value, this.test});
}

class _Bracket implements IBracket {
  @override
  final String token;
  @override
  final String open;
  @override
  final String close;

  _Bracket({required this.token, required this.open, required this.close});
}

/// 1:1: `type DynamicRegExp = (state: string) => RegExp`
class DynamicRegExp {
  final RegExp Function(String state) fn;
  DynamicRegExp(this.fn);

  RegExp call(String state) => fn(state);
}

/// A compiled rule. `IRule.resolveRegex` returns `Object`: either a [RegExp] or
/// a [DynamicRegExp].
class _Rule implements IRule {
  Object _regex = RegExp('');
  @override
  FuzzyAction action = '';
  @override
  bool matchOnlyAtLineStart = false;
  @override
  String name;

  _Rule(this.name);

  @override
  Object resolveRegex(String state) {
    final Object r = _regex;
    if (r is RegExp) {
      return r;
    }
    return (r as DynamicRegExp)(state);
  }

  void setRegex(ILexerMin lexer, Object re) {
    String sregex;
    if (re is String) {
      sregex = re;
    } else if (re is RegExp) {
      sregex = re.pattern;
    } else {
      throw monarchCommon.createMonarchError(
        lexer,
        'rules must start with a match string or regular expression: $name',
      );
    }

    matchOnlyAtLineStart = (sregex.isNotEmpty && sregex[0] == '^');
    name = '$name: $sregex';
    _regex = compileRegExp(
      lexer,
      '^(?:${(matchOnlyAtLineStart ? sregex.substring(1) : sregex)})',
      true,
    );
  }

  void setAction(_LexerMin lexer, Object? act) {
    action = compileAction(lexer, name, act);
  }
}

/// Mutable compiled lexer (source builds an `ILexer` object literal).
class _CompiledLexer implements ILexer {
  @override
  String languageId;
  @override
  bool includeLF;
  @override
  bool noThrow;
  @override
  bool ignoreCase;
  @override
  bool unicode;
  @override
  bool usesEmbedded;
  @override
  String defaultToken;
  @override
  Map<String, Object?> stateNames;
  @override
  Map<String, Object?> attrs;
  @override
  int maxStack;
  @override
  String? start;
  @override
  String tokenPostfix;
  @override
  Map<String, List<IRule>> tokenizer;
  @override
  List<IBracket> brackets;

  _CompiledLexer({
    required this.languageId,
    required this.includeLF,
    required this.noThrow,
    required this.ignoreCase,
    required this.unicode,
    required this.usesEmbedded,
    required this.defaultToken,
    required this.stateNames,
    required this.attrs,
    required this.maxStack,
    required this.start,
    required this.tokenPostfix,
    required this.tokenizer,
    required this.brackets,
  });
}

/// View of the JSON definition as an `ILexerMin`. The source does
/// `const lexerMin: ILexerMin = <any>json` and then mutates several fields;
/// the JSON's arbitrary top-level keys are carried by [attrs].
class _LexerMin implements ILexerMin {
  final IMonarchLanguage json;
  @override
  Map<String, Object?> attrs;

  String _languageId = '';
  bool _includeLF = false;
  bool _noThrow = false;
  bool _ignoreCase = false;
  bool _unicode = false;
  bool _usesEmbedded = false;
  String _defaultToken = 'source';
  Map<String, Object?> _stateNames = <String, Object?>{};

  _LexerMin(this.json) : attrs = json.extra;

  @override
  String get languageId => _languageId;
  set languageId(String value) => _languageId = value;

  @override
  bool get includeLF => _includeLF;
  set includeLF(bool value) => _includeLF = value;

  @override
  bool get noThrow => _noThrow;
  set noThrow(bool value) => _noThrow = value;

  @override
  bool get ignoreCase => _ignoreCase;
  set ignoreCase(bool value) => _ignoreCase = value;

  @override
  bool get unicode => _unicode;
  set unicode(bool value) => _unicode = value;

  @override
  bool get usesEmbedded => _usesEmbedded;
  set usesEmbedded(bool value) => _usesEmbedded = value;

  @override
  String get defaultToken => _defaultToken;
  set defaultToken(String value) => _defaultToken = value;

  @override
  Map<String, Object?> get stateNames => _stateNames;
  set stateNames(Map<String, Object?> value) => _stateNames = value;
}

// ============================================================================
// Type helpers
// ============================================================================

/// 1:1: `function isArrayOf(elemType, obj): boolean`
bool isArrayOf(bool Function(Object? item) elemType, Object? obj) {
  if (obj == null) {
    return false;
  }
  if (obj is! List) {
    return false;
  }
  for (final Object? el in obj) {
    if (!elemType(el)) {
      return false;
    }
  }
  return true;
}

/// 1:1: `function bool(prop, defValue): boolean`
bool _bool(Object? prop, bool defValue) {
  if (prop is bool) {
    return prop;
  }
  return defValue;
}

/// 1:1: `function string(prop, defValue): string`
String _string(Object? prop, String defValue) {
  if (prop is String) {
    return prop;
  }
  return defValue;
}

/// 1:1: `function arrayToHash(array): { [name: string]: true }`
Map<String, bool> _arrayToHash(List<String> array) {
  final Map<String, bool> result = <String, bool>{};
  for (final String e in array) {
    result[e] = true;
  }
  return result;
}

/// 1:1: `function createKeywordMatcher(arr, caseInsensitive = false)`
bool Function(String) _createKeywordMatcher(
  List<String> arr, [
  bool caseInsensitive = false,
]) {
  List<String> words = arr;
  if (caseInsensitive) {
    words = words.map((String x) => x.toLowerCase()).toList();
  }
  final Map<String, bool> hash = _arrayToHash(words);
  if (caseInsensitive) {
    return (String word) {
      final String w = word.toLowerCase();
      return hash[w] != null && hash.containsKey(w);
    };
  } else {
    return (String word) {
      return hash[word] != null && hash.containsKey(word);
    };
  }
}

// ============================================================================
// Lexer helpers
// ============================================================================

RegExp _makeRegExp(String source, String flags) {
  return RegExp(
    source,
    caseSensitive: !flags.contains('i'),
    unicode: flags.contains('u'),
  );
}

/// 1:1: `function compileRegExp(lexer, str, handleSn): RegExp | DynamicRegExp`
Object compileRegExp(
  ILexerMin lexer,
  String str,
  bool handleSn,
) {
  // @@ must be interpreted as a literal @, so replace all occurrences of @@
  // with a placeholder character.
  str = str.replaceAll('@@', '\u0001');

  int n = 0;
  bool hadExpansion;
  do {
    hadExpansion = false;
    str = str.replaceAllMapped(RegExp(r'@(\w+)'), (Match m) {
      hadExpansion = true;
      final String attr = m.group(1)!;
      String sub = '';
      final Object? v = lexer.attrs[attr];
      if (v is String) {
        sub = v;
      } else if (v is RegExp) {
        sub = v.pattern;
      } else {
        if (v == null) {
          throw monarchCommon.createMonarchError(
            lexer,
            "language definition does not contain attribute '$attr', used at: $str",
          );
        } else {
          throw monarchCommon.createMonarchError(
            lexer,
            "attribute reference '$attr' must be a string, used at: $str",
          );
        }
      }
      return monarchCommon.empty(sub) ? '' : '(?:' + sub + ')';
    });
    n++;
  } while (hadExpansion && n < 5);

  // handle escaped @@
  str = str.replaceAll('\u0001', '@');

  final String flags =
      (lexer.ignoreCase ? 'i' : '') + (lexer.unicode ? 'u' : '');

  // handle $Sn
  if (handleSn) {
    if (RegExp(r'\$[sS](\d\d?)').hasMatch(str)) {
      String? lastState;
      RegExp? lastRegEx;
      return DynamicRegExp((String state) {
        if (lastRegEx != null && lastState == state) {
          return lastRegEx!;
        }
        lastState = state;
        lastRegEx = _makeRegExp(
          monarchCommon.substituteMatchesRe(lexer, str, state),
          flags,
        );
        return lastRegEx!;
      });
    }
  }

  return _makeRegExp(str, flags);
}

typedef _Tester = bool Function(
  String s,
  String id,
  List<String> matches,
  String state,
  bool eos,
);

/// 1:1: `function selectScrutinee(id, matches, state, num): string | null`
String? selectScrutinee(
  String id,
  List<String> matches,
  String state,
  int num,
) {
  if (num < 0) {
    return id;
  }
  if (num < matches.length) {
    return matches[num];
  }
  if (num >= 100) {
    num = num - 100;
    final List<String> parts = state.split('.');
    parts.insert(0, state);
    if (num < parts.length) {
      return parts[num];
    }
  }
  return null;
}

/// 1:1: `function createGuard(lexer, ruleName, tkey, val): IBranch`
_Branch createGuard(
  ILexerMin lexer,
  String ruleName,
  String tkey,
  FuzzyAction val,
) {
  // get the scrutinee and pattern
  int scrut = -1; // -1: $!, 0-99: $n, 100+n: $Sn
  String oppat = tkey;
  Match? matches = RegExp(r'^\$(([sS]?)(\d\d?)|#)(.*)$').firstMatch(tkey);
  if (matches != null) {
    final String? digits = matches.group(3);
    if (digits != null && digits.isNotEmpty) {
      scrut = int.parse(digits);
      final String? s = matches.group(2);
      if (s != null && s.isNotEmpty) {
        scrut = scrut + 100; // if [sS] present
      }
    }
    oppat = matches.group(4) ?? '';
  }

  // get operator
  String op = '~';
  String pat = oppat;
  if (oppat.isEmpty) {
    op = '!=';
    pat = '';
  } else if (RegExp(r'^\w*$').hasMatch(pat)) {
    // just a word
    op = '==';
  } else {
    matches = RegExp(r'^(@|!@|~|!~|==|!=)(.*)$').firstMatch(oppat);
    if (matches != null) {
      op = matches.group(1)!;
      pat = matches.group(2) ?? '';
    }
  }

  // set the tester function
  late final _Tester tester;

  // special case a regexp that matches just words
  if ((op == '~' || op == '!~') && RegExp(r'^(\w|\|)*$').hasMatch(pat)) {
    final bool Function(String) inWords =
        _createKeywordMatcher(pat.split('|'), lexer.ignoreCase);
    tester = (String s, String id, List<String> matches, String state, bool eos) {
      return (op == '~' ? inWords(s) : !inWords(s));
    };
  } else if (op == '@' || op == '!@') {
    final Object? words = lexer.attrs[pat];
    if (words == null) {
      throw monarchCommon.createMonarchError(
        lexer,
        "the @ match target '$pat' is not defined, in rule: $ruleName",
      );
    }
    if (!isArrayOf((Object? elem) => elem is String, words)) {
      throw monarchCommon.createMonarchError(
        lexer,
        "the @ match target '$pat' must be an array of strings, in rule: $ruleName",
      );
    }
    final bool Function(String) inWords =
        _createKeywordMatcher((words as List).cast<String>(), lexer.ignoreCase);
    tester = (String s, String id, List<String> matches, String state, bool eos) {
      return (op == '@' ? inWords(s) : !inWords(s));
    };
  } else if (op == '~' || op == '!~') {
    if (!pat.contains(r'$')) {
      // precompile regular expression
      final Object compiled = compileRegExp(lexer, '^$pat\$', false);
      tester = (String s, String id, List<String> matches, String state, bool eos) {
        final bool hit = (compiled as RegExp).hasMatch(s);
        return (op == '~' ? hit : !hit);
      };
    } else {
      tester = (String s, String id, List<String> matches, String state, bool eos) {
        final Object compiled = compileRegExp(
          lexer,
          '^${monarchCommon.substituteMatches(lexer, pat, id, matches, state)}\$',
          false,
        );
        return (compiled as RegExp).hasMatch(s);
      };
    }
  } else {
    // if (op === '==' || op === '!=')
    if (!pat.contains(r'$')) {
      final String patx = monarchCommon.fixCase(lexer, pat);
      tester = (String s, String id, List<String> matches, String state, bool eos) {
        return (op == '==' ? s == patx : s != patx);
      };
    } else {
      final String patx = monarchCommon.fixCase(lexer, pat);
      tester = (String s, String id, List<String> matches, String state, bool eos) {
        final String patexp =
            monarchCommon.substituteMatches(lexer, patx, id, matches, state);
        return (op == '==' ? s == patexp : s != patexp);
      };
    }
  }

  // return the branch object
  if (scrut == -1) {
    return _Branch(
      name: tkey,
      value: val,
      test: (String id, List<String> matches, String state, bool eos) {
        return tester(id, id, matches, state, eos);
      },
    );
  } else {
    return _Branch(
      name: tkey,
      value: val,
      test: (String id, List<String> matches, String state, bool eos) {
        final String? scrutinee = selectScrutinee(id, matches, state, scrut);
        final String s = (scrutinee == null || scrutinee.isEmpty) ? '' : scrutinee;
        return tester(s, id, matches, state, eos);
      },
    );
  }
}

/// JS truthiness for the dynamic values used in actions.
bool _truthy(Object? v) {
  if (v == null) {
    return false;
  }
  if (v is bool) {
    return v;
  }
  if (v is String) {
    return v.isNotEmpty;
  }
  if (v is num) {
    return v != 0;
  }
  // JS objects and arrays are always truthy, including empty ones.
  if (v is Map || v is List) {
    return true;
  }
  return true;
}

/// View an action value as its own field map (source uses `any` + property
/// access). Only non-null fields are included so `containsKey('token')`
/// mirrors `action.token !== undefined`.
Map<String, Object?> _actionFields(Object? a) {
  if (a == null) {
    return <String, Object?>{};
  }
  if (a is Map) {
    return Map<String, Object?>.from(a);
  }
  if (a is IShortActionCarrier) {
    return <String, Object?>{'token': a.value};
  }
  if (a is IExpandedMonarchLanguageAction) {
    final Map<String, Object?> r = <String, Object?>{};
    if (a.group != null) r['group'] = a.group;
    if (a.cases != null) r['cases'] = a.cases;
    if (a.token != null) r['token'] = a.token;
    if (a.next != null) r['next'] = a.next;
    if (a.switchTo != null) r['switchTo'] = a.switchTo;
    if (a.goBack != null) r['goBack'] = a.goBack;
    if (a.bracket != null) r['bracket'] = a.bracket;
    if (a.nextEmbedded != null) r['nextEmbedded'] = a.nextEmbedded;
    if (a.log != null) r['log'] = a.log;
    return r;
  }
  return <String, Object?>{};
}

/// 1:1: `function compileAction(lexer, ruleName, action): FuzzyAction`
FuzzyAction compileAction(
  _LexerMin lexer,
  String ruleName,
  Object? action,
) {
  if (!_truthy(action)) {
    return _Action(token: '');
  } else if (action is String) {
    return action; // { token: action }
  }

  final Map<String, Object?> fields = _actionFields(action);

  if (fields.containsKey('token')) {
    final Object? tokenVal = fields['token'];
    if (tokenVal is! String) {
      throw monarchCommon.createMonarchError(
        lexer,
        "a 'token' attribute must be of type string, in rule: $ruleName",
      );
    }
    // only copy specific typed fields (only happens once during compile Lexer)
    final _Action newAction = _Action(token: tokenVal);
    if (tokenVal.contains(r'$')) {
      newAction.tokenSubst = true;
    }
    final Object? bracketVal = fields['bracket'];
    if (bracketVal is String) {
      if (bracketVal == '@open') {
        newAction.bracket = MonarchBracket.Open;
      } else if (bracketVal == '@close') {
        newAction.bracket = MonarchBracket.Close;
      } else {
        throw monarchCommon.createMonarchError(
          lexer,
          "a 'bracket' attribute must be either '@open' or '@close', in rule: $ruleName",
        );
      }
    }
    final Object? nextVal = fields['next'];
    if (_truthy(nextVal)) {
      if (nextVal is! String) {
        throw monarchCommon.createMonarchError(
          lexer,
          'the next state must be a string value in rule: $ruleName',
        );
      }
      String next = nextVal;
      if (!RegExp(r'^(@pop|@push|@popall)$').hasMatch(next)) {
        if (next.startsWith('@')) {
          next = next.substring(1); // peel off starting @ sign
        }
        if (!next.contains(r'$')) {
          // no dollar substitution, we can check if the state exists
          if (!monarchCommon.stateExists(
            lexer,
            monarchCommon.substituteMatches(lexer, next, '', const <String>[], ''),
          )) {
            throw monarchCommon.createMonarchError(
              lexer,
              "the next state '$nextVal' is not defined in rule: $ruleName",
            );
          }
        }
      }
      newAction.next = next;
    }
    final Object? goBackVal = fields['goBack'];
    if (goBackVal is num) {
      newAction.goBack = goBackVal.toInt();
    }
    final Object? switchToVal = fields['switchTo'];
    if (switchToVal is String) {
      newAction.switchTo = switchToVal;
    }
    final Object? logVal = fields['log'];
    if (logVal is String) {
      newAction.log = logVal;
    }
    final Object? nextEmbeddedVal = fields['nextEmbedded'];
    if (nextEmbeddedVal is String) {
      newAction.nextEmbedded = nextEmbeddedVal;
      lexer.usesEmbedded = true;
    }
    return newAction;
  } else if (action is List || action is IActionListCarrier) {
    final List<FuzzyAction> results = <FuzzyAction>[];
    final List<Object?> source = action is IActionListCarrier
        ? action.list.cast<Object?>()
        : (action as List).cast<Object?>();
    for (final Object? item in source) {
      results.add(compileAction(lexer, ruleName, item));
    }
    return _Action(group: results);
  } else if (fields.containsKey('cases')) {
    // build an array of test cases
    final List<IBranch> cases = <IBranch>[];
    bool hasEmbeddedEndInCases = false;
    final Object? casesRaw = fields['cases'];
    final Map casesMap = casesRaw is Map ? casesRaw : <Object?, Object?>{};

    // for each case, push a test function and result value
    for (final Object? tkeyObj in casesMap.keys) {
      final String tkey = '$tkeyObj';
      final FuzzyAction val = compileAction(lexer, ruleName, casesMap[tkeyObj]);

      // what kind of case
      if (tkey == '@default' || tkey == '@' || tkey.isEmpty) {
        cases.add(_Branch(test: null, value: val, name: tkey));
      } else if (tkey == '@eos') {
        cases.add(_Branch(
          name: tkey,
          value: val,
          test: (String id, List<String> matches, String state, bool eos) => eos,
        ));
      } else {
        cases.add(createGuard(lexer, ruleName, tkey, val)); // separate function to avoid local variable capture
      }

      if (!hasEmbeddedEndInCases) {
        final IAction? valAction = val is IAction ? val : null;
        final String nextEmbedded = valAction?.nextEmbedded ?? '';
        hasEmbeddedEndInCases = !isString(val) &&
            ((valAction?.hasEmbeddedEndInCases ?? false) ||
                nextEmbedded == '@pop' ||
                nextEmbedded == '@popall');
      }
    }

    // create a matching function
    final String def = lexer.defaultToken;
    return _Action(
      hasEmbeddedEndInCases: hasEmbeddedEndInCases,
      test: (String id, List<String> matches, String state, bool eos) {
        for (final IBranch _case in cases) {
          final bool didmatch =
              (_case.test == null ||
                  _case.test!(id, matches, state, eos));
          if (didmatch) {
            return _case.value;
          }
        }
        return def;
      },
    );
  } else {
    throw monarchCommon.createMonarchError(
      lexer,
      "an action must be a string, an object with a 'token' or 'cases' attribute, or an array of actions; in rule: $ruleName",
    );
  }
}

// ============================================================================
// compile
// ============================================================================

/// Compiles a json description function into json where all regular expressions,
/// case matches etc, are compiled and all include rules are expanded.
/// 1:1: `export function compile(languageId, json): ILexer`
ILexer compile(String languageId, IMonarchLanguage json) {
  // The source guards `!json || typeof json !== 'object'`; through this typed
  // API a non-object cannot reach here, so the guard is structurally absent.

  // Create our lexer
  final _CompiledLexer lexer = _CompiledLexer(
    languageId: languageId,
    includeLF: _bool(json.includeLF, false),
    noThrow: false, // raise exceptions during compilation
    maxStack: 100,
    start: json.start is String ? json.start as String : null,
    ignoreCase: _bool(json.ignoreCase, false),
    unicode: _bool(json.unicode, false),
    tokenPostfix: _string(json.tokenPostfix, '.$languageId'),
    defaultToken: _string(json.defaultToken, 'source'),
    usesEmbedded: false, // becomes true if we find a nextEmbedded action
    stateNames: <String, Object?>{},
    attrs: <String, Object?>{},
    tokenizer: <String, List<IRule>>{},
    brackets: <IBracket>[],
  );

  // For calling compileAction later on
  final _LexerMin lexerMin = _LexerMin(json);
  lexerMin.languageId = languageId;
  lexerMin.includeLF = lexer.includeLF;
  lexerMin.ignoreCase = lexer.ignoreCase;
  lexerMin.unicode = lexer.unicode;
  lexerMin.noThrow = lexer.noThrow;
  lexerMin.usesEmbedded = lexer.usesEmbedded;
  lexerMin.stateNames = json.tokenizer as Map<String, Object?>;
  lexerMin.defaultToken = lexer.defaultToken;

  /// Compile an array of rules into newrules where RegExp objects are created.
  void addRules(
    String state,
    List<IRule> newrules,
    List<Object?> rules,
  ) {
    for (final Object? rule in rules) {
      Object? include;
      bool isArrayShape = false;
      List<Object?> arrayParts = const <Object?>[];
      Map<String, Object?> objFields = const <String, Object?>{};

      if (rule is IShortMonarchLanguageRule1) {
        isArrayShape = true;
        arrayParts = <Object?>[rule.regex, rule.action];
      } else if (rule is IShortMonarchLanguageRule2) {
        isArrayShape = true;
        arrayParts = <Object?>[rule.regex, rule.action, rule.next];
      } else if (rule is IExpandedMonarchLanguageRule) {
        objFields = <String, Object?>{
          if (rule.regex != null) 'regex': rule.regex,
          if (rule.action != null) 'action': rule.action,
          if (rule.include != null) 'include': rule.include,
        };
        include = rule.include;
      } else if (rule is List) {
        isArrayShape = true;
        arrayParts = rule;
      } else if (rule is Map) {
        objFields = Map<String, Object?>.from(rule);
        include = objFields['include'];
      }

      if (_truthy(include)) {
        if (include is! String) {
          throw monarchCommon.createMonarchError(
            lexer,
            "an 'include' attribute must be a string at: $state",
          );
        }
        String inc = include;
        if (inc.startsWith('@')) {
          inc = inc.substring(1); // peel off starting @
        }
        if (json.tokenizer[inc] == null) {
          throw monarchCommon.createMonarchError(
            lexer,
            "include target '$inc' is not defined at: $state",
          );
        }
        addRules('$state.$inc', newrules, json.tokenizer[inc]!);
      } else {
        final _Rule newrule = _Rule(state);

        // Set up new rule attributes
        if (isArrayShape && arrayParts.length >= 1 && arrayParts.length <= 3) {
          newrule.setRegex(lexerMin, arrayParts[0] as Object);
          if (arrayParts.length >= 3) {
            final Object? part1 = arrayParts[1];
            if (part1 is String) {
              newrule.setAction(lexerMin, <String, Object?>{
                'token': part1,
                'next': arrayParts[2],
              });
            } else if (part1 is IExpandedMonarchLanguageAction ||
                part1 is Map) {
              // source: rule1.next = rule[2]
              if (part1 is IExpandedMonarchLanguageAction) {
                // Rebuild the action with `next` overridden.
                newrule.setAction(
                  lexerMin,
                  <String, Object?>{
                    if (part1.token != null) 'token': part1.token,
                    if (part1.group != null) 'group': part1.group,
                    if (part1.cases != null) 'cases': part1.cases,
                    if (part1.switchTo != null) 'switchTo': part1.switchTo,
                    if (part1.goBack != null) 'goBack': part1.goBack,
                    if (part1.bracket != null) 'bracket': part1.bracket,
                    if (part1.nextEmbedded != null)
                      'nextEmbedded': part1.nextEmbedded,
                    if (part1.log != null) 'log': part1.log,
                    'next': arrayParts[2] ?? '',
                  },
                );
              } else {
                final Map<String, Object?> m = Map<String, Object?>.from(
                  part1 as Map,
                );
                m['next'] = arrayParts[2];
                newrule.setAction(lexerMin, m);
              }
            } else {
              throw monarchCommon.createMonarchError(
                lexer,
                'a next state as the last element of a rule can only be given if the action is either an object or a string, at: $state',
              );
            }
          } else {
            newrule.setAction(
              lexerMin,
              arrayParts.length >= 2 ? arrayParts[1] : null,
            );
          }
        } else {
          final Object? regex = objFields['regex'];
          if (regex == null) {
            throw monarchCommon.createMonarchError(
              lexer,
              "a rule must either be an array, or an object with a 'regex' or 'include' field at: $state",
            );
          }
          final Object? name = objFields['name'];
          if (name is String) {
            newrule.name = name;
          }
          final Object? mol = objFields['matchOnlyAtStart'];
          if (mol != null) {
            newrule.matchOnlyAtLineStart = _bool(mol, false);
          }
          newrule.setRegex(lexerMin, regex);
          newrule.setAction(lexerMin, objFields['action']);
        }

        newrules.add(newrule);
      }
    }
  }

  // compile the tokenizer rules
  // Source: `if (!json.tokenizer || typeof json.tokenizer !== 'object') throw`.
  // [IMonarchLanguage.tokenizer] is non-nullable here, so only the empty-object
  // case can occur; the source permits it (the loop simply runs zero times).

  lexer.tokenizer = <String, List<IRule>>{};
  for (final String key in json.tokenizer.keys) {
    if (lexer.start == null || lexer.start!.isEmpty) {
      lexer.start = key;
    }

    final List<Object?> rules = json.tokenizer[key]!;
    lexer.tokenizer[key] = <IRule>[];
    addRules('tokenizer.$key', lexer.tokenizer[key]!, rules);
  }
  lexer.usesEmbedded = lexerMin.usesEmbedded; // can be set during compileAction

  // Set simple brackets
  List<Object?>? bracketsJson = json.brackets;
  if (bracketsJson == null) {
    bracketsJson = <Object?>[
      <String, Object?>{'open': '{', 'close': '}', 'token': 'delimiter.curly'},
      <String, Object?>{'open': '[', 'close': ']', 'token': 'delimiter.square'},
      <String, Object?>{
        'open': '(',
        'close': ')',
        'token': 'delimiter.parenthesis',
      },
      <String, Object?>{'open': '<', 'close': '>', 'token': 'delimiter.angle'},
    ];
  }
  final List<IBracket> brackets = <IBracket>[];
  for (final Object? el in bracketsJson) {
    Object? desc = el;
    if (desc is List && desc.length == 3) {
      desc = <String, Object?>{
        'token': desc[2],
        'open': desc[0],
        'close': desc[1],
      };
    }
    Map<String, Object?> dm;
    if (desc is IMonarchLanguageBracket) {
      dm = <String, Object?>{
        'open': desc.open,
        'close': desc.close,
        'token': desc.token,
      };
    } else if (desc is Map) {
      dm = Map<String, Object?>.from(desc);
    } else {
      dm = <String, Object?>{};
    }
    if (dm['open'] == dm['close']) {
      throw monarchCommon.createMonarchError(
        lexer,
        "open and close brackets in a 'brackets' attribute must be different: ${dm['open']}"
        "\n hint: use the 'bracket' attribute if matching on equal brackets is required.",
      );
    }
    if (dm['open'] is String &&
        dm['token'] is String &&
        dm['close'] is String) {
      brackets.add(_Bracket(
        token: (dm['token'] as String) + lexer.tokenPostfix,
        open: monarchCommon.fixCase(lexer, dm['open'] as String),
        close: monarchCommon.fixCase(lexer, dm['close'] as String),
      ));
    } else {
      throw monarchCommon.createMonarchError(
        lexer,
        "every element in the 'brackets' array must be a '{open,close,token}' object or array",
      );
    }
  }
  lexer.brackets = brackets;

  // Disable throw so the syntax highlighter goes, no matter what
  lexer.noThrow = true;
  return lexer;
}
