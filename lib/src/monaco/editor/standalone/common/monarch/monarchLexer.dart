// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/standalone/common/monarch/monarchLexer.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Adaptations (documented inline):
//  * Erased interfaces (`IThemeService`, `ILanguageService`,
//    `IConfigurationService`, `ITokenizationSupport`) are reduced to the
//    members actually read, per repo convention.
//  * `IState` -> local [IStateForMonarch] contract (clone/equals).
//  * JS `String.match(regex)` -> `RegExp.firstMatch` + explicit group list.
//  * `Uint32Array` -> `Uint32List`; `Object.create(null)` -> Dart `Map`.
//  * `console.log` from monarchCommon is already injectable in that port.
// ---------------------------------------------------------------------------
import 'dart:typed_data';

import '../../../../base/common/lifecycle.dart' show Disposable, IDisposable;
import '../../../common/encodedTokenAttributes.dart'
    show LanguageId, MetadataConsts;
import '../../../common/languages.dart'
    show
      EncodedTokenizationResult,
      Token,
      TokenizationResult,
      TokenizationRegistry;
import '../../../common/languages/nullTokenize.dart'
    show NullState, nullTokenize, nullTokenizeEncoded;
import 'monarchCommon.dart'
    show
      FuzzyAction,
      IAction,
      IBracket,
      ILexer,
      IRule,
      MonarchBracket,
      createMonarchError,
      findRules,
      fixCase,
      isFuzzyAction,
      isFuzzyActionArr,
      isIAction,
      monarchLog,
      sanitize,
      substituteMatches;

/// 1:1: `const enum CACHE_STACK_DEPTH`.
const int _cacheStackDepth = 5;

/// 1:1: `IState` (erased interface).
abstract class IStateForMonarch {
  Object clone();
  bool equals(Object other);
}

/// 1:1: `IThemeService` members read here.
abstract class IStandaloneThemeForMonarch {
  Object getColorTheme();
}

/// 1:1: `IColorTheme.tokenTheme` carrier.
abstract class IColorThemeForMonarch {
  /// 1:1: `IColorTheme.tokenTheme.match(languageId, type)`.
  int matchToken(int languageId, String type);
}

/// 1:1: `ILanguageService` members read here.
abstract class ILanguageServiceForMonarch {
  int encodeLanguageId(String languageId);
  String? getLanguageIdByLanguageName(String languageName);
  String? getLanguageIdByMimeType(String? mimeType);
  bool isRegisteredLanguageId(String? languageId);
  void requestBasicLanguageFeatures(String languageId);
}

/// 1:1: `IConfigurationService` member read here (overloads collapsed).
abstract class IConfigurationForMonarch {
  int getMaxTokenizationLineLength(String languageId);
}

class MonarchStackElementFactory {
  static final MonarchStackElementFactory _instance =
      MonarchStackElementFactory(_cacheStackDepth);

  static MonarchStackElement create(
          MonarchStackElement? parent, String state) =>
      _instance._create(parent, state);

  final int _maxCacheDepth;
  final Map<String, MonarchStackElement> _entries =
      <String, MonarchStackElement>{};

  MonarchStackElementFactory(this._maxCacheDepth);

  MonarchStackElement _create(MonarchStackElement? parent, String state) {
    if (parent != null && parent.depth >= _maxCacheDepth) {
      return MonarchStackElement(parent, state);
    }
    String stackElementId = MonarchStackElement.getStackElementId(parent);
    if (stackElementId.isNotEmpty) {
      stackElementId += '|';
    }
    stackElementId += state;

    final MonarchStackElement? result = _entries[stackElementId];
    if (result != null) {
      return result;
    }
    final MonarchStackElement created = MonarchStackElement(parent, state);
    _entries[stackElementId] = created;
    return created;
  }
}

class MonarchStackElement {
  final MonarchStackElement? parent;
  final String state;
  final int depth;

  MonarchStackElement(this.parent, this.state)
      : depth = (parent != null ? parent.depth : 0) + 1;

  static String getStackElementId(MonarchStackElement? element) {
    String result = '';
    while (element != null) {
      if (result.isNotEmpty) {
        result += '|';
      }
      result += element.state;
      element = element.parent;
    }
    return result;
  }

  static bool _equals(MonarchStackElement? a, MonarchStackElement? b) {
    while (a != null && b != null) {
      if (identical(a, b)) {
        return true;
      }
      if (a.state != b.state) {
        return false;
      }
      a = a.parent;
      b = b.parent;
    }
    return a == null && b == null;
  }

  bool equals(MonarchStackElement other) => _equals(this, other);

  MonarchStackElement push(String state) =>
      MonarchStackElementFactory.create(this, state);

  MonarchStackElement? pop() => parent;

  MonarchStackElement popall() {
    MonarchStackElement result = this;
    while (result.parent != null) {
      result = result.parent!;
    }
    return result;
  }

  MonarchStackElement switchTo(String state) =>
      MonarchStackElementFactory.create(parent, state);
}

class EmbeddedLanguageData {
  final String languageId;
  final Object state;

  EmbeddedLanguageData(this.languageId, this.state);

  bool equals(EmbeddedLanguageData other) =>
      languageId == other.languageId &&
      state is IStateForMonarch &&
      other.state is IStateForMonarch &&
      (state as IStateForMonarch).equals(other.state);
}

class MonarchLineStateFactory {
  static final MonarchLineStateFactory _instance =
      MonarchLineStateFactory(_cacheStackDepth);

  static MonarchLineState create(MonarchStackElement stack,
          EmbeddedLanguageData? embeddedLanguageData) =>
      _instance._create(stack, embeddedLanguageData);

  final int _maxCacheDepth;
  final Map<String, MonarchLineState> _entries =
      <String, MonarchLineState>{};

  MonarchLineStateFactory(this._maxCacheDepth);

  MonarchLineState _create(MonarchStackElement stack,
      EmbeddedLanguageData? embeddedLanguageData) {
    if (embeddedLanguageData != null) {
      return MonarchLineState(stack, embeddedLanguageData);
    }
    if (stack.depth >= _maxCacheDepth) {
      return MonarchLineState(stack, embeddedLanguageData);
    }
    final String stackElementId =
        MonarchStackElement.getStackElementId(stack);
    final MonarchLineState? result = _entries[stackElementId];
    if (result != null) {
      return result;
    }
    final MonarchLineState created = MonarchLineState(stack, null);
    _entries[stackElementId] = created;
    return created;
  }
}

class MonarchLineState implements IStateForMonarch {
  final MonarchStackElement stack;
  final EmbeddedLanguageData? embeddedLanguageData;

  MonarchLineState(this.stack, this.embeddedLanguageData);

  @override
  Object clone() {
    return this;
  }

  @override
  bool equals(Object other) {
    if (other is! MonarchLineState) {
      return false;
    }
    if (!stack.equals(other.stack)) {
      return false;
    }
    if (embeddedLanguageData == null && other.embeddedLanguageData == null) {
      return true;
    }
    if (embeddedLanguageData == null || other.embeddedLanguageData == null) {
      return false;
    }
    return embeddedLanguageData!.equals(other.embeddedLanguageData!);
  }
}

/// 1:1: `IMonarchTokensCollector` (erased interface).
abstract class IMonarchTokensCollector {
  void enterLanguage(String languageId);
  void emit(int startOffset, String type);
  Object nestedLanguageTokenize(String embeddedLanguageLine, bool hasEOL,
      EmbeddedLanguageData embeddedLanguageData, int offsetDelta);
  Object finalize(MonarchLineState endState);
}

class MonarchClassicTokensCollector implements IMonarchTokensCollector {
  List<Token> _tokens;
  String? _languageId;
  String? _lastTokenType;
  String? _lastTokenLanguage;

  MonarchClassicTokensCollector()
      : _tokens = <Token>[],
        _languageId = null,
        _lastTokenType = null,
        _lastTokenLanguage = null;

  @override
  void enterLanguage(String languageId) {
    _languageId = languageId;
  }

  @override
  void emit(int startOffset, String type) {
    if (_lastTokenType == type && _lastTokenLanguage == _languageId) {
      return;
    }
    _lastTokenType = type;
    _lastTokenLanguage = _languageId;
    _tokens.add(Token(startOffset, type, _languageId!));
  }

  @override
  Object nestedLanguageTokenize(String embeddedLanguageLine, bool hasEOL,
      EmbeddedLanguageData embeddedLanguageData, int offsetDelta) {
    final String nestedLanguageId = embeddedLanguageData.languageId;
    final Object embeddedModeState = embeddedLanguageData.state;
    final Object? nestedSupport = TokenizationRegistry.get(nestedLanguageId);
    if (nestedSupport == null) {
      enterLanguage(nestedLanguageId);
      emit(offsetDelta, '');
      return embeddedModeState;
    }
    final dynamic support = nestedSupport;
    final TokenizationResult nestedResult = support.tokenize(
        embeddedLanguageLine, hasEOL, embeddedModeState) as TokenizationResult;
    if (offsetDelta != 0) {
      for (final Token token in nestedResult.tokens) {
        _tokens.add(Token(token.offset + offsetDelta, token.type, token.language));
      }
    } else {
      _tokens = <Token>[..._tokens, ...nestedResult.tokens];
    }
    _lastTokenType = null;
    _lastTokenLanguage = null;
    _languageId = null;
    return nestedResult.endState!;
  }

  @override
  TokenizationResult finalize(MonarchLineState endState) =>
      TokenizationResult(_tokens, endState);
}

class MonarchModernTokensCollector implements IMonarchTokensCollector {
  final ILanguageServiceForMonarch _languageService;
  final IColorThemeForMonarch _theme;
  Uint32List? _prependTokens;
  List<int> _tokens;
  int _currentLanguageId;
  int _lastTokenMetadata;

  MonarchModernTokensCollector(this._languageService, this._theme)
      : _prependTokens = null,
        _tokens = <int>[],
        _currentLanguageId = LanguageId.nullId,
        _lastTokenMetadata = 0;

  @override
  void enterLanguage(String languageId) {
    _currentLanguageId = _languageService.encodeLanguageId(languageId);
  }

  @override
  void emit(int startOffset, String type) {
    final int metadata = (_theme.matchToken(_currentLanguageId, type) |
            MetadataConsts.balancedBracketsMask) &
        0xFFFFFFFF;
    if (_lastTokenMetadata == metadata) {
      return;
    }
    _lastTokenMetadata = metadata;
    _tokens.add(startOffset);
    _tokens.add(metadata);
  }

  static Uint32List _merge(
      Uint32List? a, List<int> b, Uint32List? c) {
    final int aLen = a?.length ?? 0;
    final int bLen = b.length;
    final int cLen = c?.length ?? 0;

    if (aLen == 0 && bLen == 0 && cLen == 0) {
      return Uint32List(0);
    }
    if (aLen == 0 && bLen == 0) {
      return c!;
    }
    if (bLen == 0 && cLen == 0) {
      return a!;
    }

    final Uint32List result = Uint32List(aLen + bLen + cLen);
    if (a != null) {
      result.setRange(0, aLen, a);
    }
    for (int i = 0; i < bLen; i++) {
      result[aLen + i] = b[i];
    }
    if (c != null) {
      result.setRange(aLen + bLen, aLen + bLen + cLen, c);
    }
    return result;
  }

  @override
  Object nestedLanguageTokenize(String embeddedLanguageLine, bool hasEOL,
      EmbeddedLanguageData embeddedLanguageData, int offsetDelta) {
    final String nestedLanguageId = embeddedLanguageData.languageId;
    final Object embeddedModeState = embeddedLanguageData.state;
    final Object? nestedSupport = TokenizationRegistry.get(nestedLanguageId);
    if (nestedSupport == null) {
      enterLanguage(nestedLanguageId);
      emit(offsetDelta, '');
      return embeddedModeState;
    }
    final dynamic support = nestedSupport;
    final EncodedTokenizationResult nestedResult =
        support.tokenizeEncoded(embeddedLanguageLine, hasEOL, embeddedModeState)
            as EncodedTokenizationResult;
    if (offsetDelta != 0) {
      for (int i = 0; i < nestedResult.tokens.length; i += 2) {
        nestedResult.tokens[i] += offsetDelta;
      }
    }
    _prependTokens = _merge(_prependTokens, _tokens, nestedResult.tokens);
    _tokens = <int>[];
    _currentLanguageId = 0;
    _lastTokenMetadata = 0;
    return nestedResult.endState!;
  }

  @override
  EncodedTokenizationResult finalize(MonarchLineState endState) =>
      EncodedTokenizationResult(
          _merge(_prependTokens, _tokens, null), <Object?>[], endState);
}

/// 1:1: `export type ILoadStatus`.
class ILoadStatus {
  final bool loaded;
  final Future<void>? promise;

  ILoadStatus.loaded()
      : loaded = true,
        promise = null;

  ILoadStatus.notLoaded(this.promise) : loaded = false;
}

/// 1:1: `export class MonarchTokenizer extends Disposable`.
class MonarchTokenizer extends Disposable implements IDisposable {
  final ILanguageServiceForMonarch _languageService;
  final IStandaloneThemeForMonarch _standaloneThemeService;
  final String _languageId;
  final ILexer _lexer;
  final Map<String, bool> _embeddedLanguages;
  late Future<void> embeddedLoaded;
  int _maxTokenizationLineLength;

  MonarchTokenizer(
    this._languageService,
    this._standaloneThemeService,
    this._languageId,
    this._lexer,
    IConfigurationForMonarch configurationService,
  )   : _embeddedLanguages = <String, bool>{},
        _maxTokenizationLineLength = 0 {
    embeddedLoaded = Future<void>.value();
    bool emitting = false;
    register(TokenizationRegistry.onDidChange((e) {
      if (emitting) {
        return;
      }
      bool isOneOfMyEmbeddedModes = false;
      for (final String language in e.changedLanguages) {
        if (_embeddedLanguages[language] == true) {
          isOneOfMyEmbeddedModes = true;
          break;
        }
      }
      if (isOneOfMyEmbeddedModes) {
        emitting = true;
        TokenizationRegistry.handleChange(<String>[_languageId]);
        emitting = false;
      }
    }));
    _maxTokenizationLineLength = configurationService
        .getMaxTokenizationLineLength(_languageId);
  }

  ILoadStatus getLoadStatus() {
    final List<Future<void>> promises = <Future<void>>[];
    for (final String nestedLanguageId in _embeddedLanguages.keys) {
      final Object? support = TokenizationRegistry.get(nestedLanguageId);
      if (support != null) {
        if (support is MonarchTokenizer) {
          final ILoadStatus nested = support.getLoadStatus();
          if (!nested.loaded) {
            promises.add(nested.promise!);
          }
        }
        continue;
      }
      if (!TokenizationRegistry.isResolved(nestedLanguageId)) {
        promises.add(TokenizationRegistry.getOrCreate(nestedLanguageId));
      }
    }
    if (promises.isEmpty) {
      return ILoadStatus.loaded();
    }
    return ILoadStatus.notLoaded(Future.wait<void>(promises).then((_) {}));
  }

  MonarchLineState getInitialState() {
    final MonarchStackElement rootState =
        MonarchStackElementFactory.create(null, _lexer.start!);
    return MonarchLineStateFactory.create(rootState, null);
  }

  TokenizationResult tokenize(String line, bool hasEOL, Object? lineState) {
    if (line.length >= _maxTokenizationLineLength) {
      return nullTokenize(_languageId, lineState);
    }
    final MonarchClassicTokensCollector tokensCollector =
        MonarchClassicTokensCollector();
    final MonarchLineState endLineState = _tokenize(
        line, hasEOL, lineState as MonarchLineState, tokensCollector);
    return tokensCollector.finalize(endLineState);
  }

  EncodedTokenizationResult tokenizeEncoded(
      String line, bool hasEOL, Object? lineState) {
    if (line.length >= _maxTokenizationLineLength) {
      return nullTokenizeEncoded(
          _languageService.encodeLanguageId(_languageId), lineState);
    }
    final MonarchModernTokensCollector tokensCollector =
        MonarchModernTokensCollector(
            _languageService,
            _standaloneThemeService.getColorTheme() as IColorThemeForMonarch);
    final MonarchLineState endLineState = _tokenize(
        line, hasEOL, lineState as MonarchLineState, tokensCollector);
    return tokensCollector.finalize(endLineState);
  }

  MonarchLineState _tokenize(String line, bool hasEOL,
          MonarchLineState lineState, IMonarchTokensCollector collector) =>
      lineState.embeddedLanguageData != null
          ? _nestedTokenize(line, hasEOL, lineState, 0, collector)
          : _myTokenize(line, hasEOL, lineState, 0, collector);

  int _findLeavingNestedLanguageOffset(String line, MonarchLineState state) {
    List<IRule>? rules = _lexer.tokenizer[state.stack.state];
    if (rules == null) {
      rules = findRules(_lexer, state.stack.state);
      if (rules == null) {
        throw createMonarchError(
            _lexer, 'tokenizer state is not defined: ${state.stack.state}');
      }
    }

    int popOffset = -1;
    bool hasEmbeddedPopRule = false;

    for (final IRule rule in rules) {
      final Object? action = rule.action;
      if (!isIAction(action) ||
          !((action as IAction).nextEmbedded == '@pop' ||
              action.hasEmbeddedEndInCases)) {
        continue;
      }
      hasEmbeddedPopRule = true;

      Object regex = rule.resolveRegex(state.stack.state);
      if (regex is RegExp) {
        final String source = regex.pattern;
        if (source.startsWith('^(?:') && source.endsWith(')')) {
          regex = RegExp(source.substring(4, source.length - 1),
              caseSensitive: !regex.isCaseSensitive,
              unicode: regex.isUnicode);
        }
      }
      final Match? result = (regex as RegExp).firstMatch(line);
      final int matchIndex = result?.start ?? -1;
      if (matchIndex == -1 ||
          (matchIndex != 0 && rule.matchOnlyAtLineStart)) {
        continue;
      }
      if (popOffset == -1 || matchIndex < popOffset) {
        popOffset = matchIndex;
      }
    }

    if (!hasEmbeddedPopRule) {
      throw createMonarchError(
          _lexer,
          'no rule containing nextEmbedded: "@pop" in tokenizer embedded state: ${state.stack.state}');
    }
    return popOffset;
  }

  MonarchLineState _nestedTokenize(String line, bool hasEOL,
      MonarchLineState lineState, int offsetDelta,
      IMonarchTokensCollector tokensCollector) {
    final int popOffset = _findLeavingNestedLanguageOffset(line, lineState);
    if (popOffset == -1) {
      final Object nestedEndState = tokensCollector.nestedLanguageTokenize(
          line, hasEOL, lineState.embeddedLanguageData!, offsetDelta);
      return MonarchLineStateFactory.create(
          lineState.stack,
          EmbeddedLanguageData(
              lineState.embeddedLanguageData!.languageId, nestedEndState));
    }
    final String nestedLanguageLine = line.substring(0, popOffset);
    if (nestedLanguageLine.isNotEmpty) {
      tokensCollector.nestedLanguageTokenize(nestedLanguageLine, false,
          lineState.embeddedLanguageData!, offsetDelta);
    }
    final String restOfTheLine = line.substring(popOffset);
    return _myTokenize(restOfTheLine, hasEOL, lineState,
        offsetDelta + popOffset, tokensCollector);
  }

  String _safeRuleName(IRule? rule) => rule?.name ?? '(unknown)';

  MonarchLineState _myTokenize(String lineWithoutLF, bool hasEOL,
      MonarchLineState lineState, int offsetDelta,
      IMonarchTokensCollector tokensCollector) {
    tokensCollector.enterLanguage(_languageId);

    final int lineWithoutLFLength = lineWithoutLF.length;
    final String line = (hasEOL && _lexer.includeLF)
        ? lineWithoutLF + '\n'
        : lineWithoutLF;
    final int lineLength = line.length;

    EmbeddedLanguageData? embeddedLanguageData =
        lineState.embeddedLanguageData;
    MonarchStackElement stack = lineState.stack;
    int pos = 0;

    List<String>? groupMatches;
    IRule? groupRule;
    List<_GroupEntry>? groupGroups;

    bool forceEvaluation = true;

    while (forceEvaluation || pos < lineLength) {
      final int pos0 = pos;
      final int stackLen0 = stack.depth;
      final int groupLen0 = groupGroups?.length ?? 0;
      final String state = stack.state;

      List<String>? matches;
      String? matched;
      Object? action;
      IRule? rule;
      String? enteringEmbeddedLanguage;

      if (groupGroups != null) {
        matches = groupMatches;
        final _GroupEntry groupEntry = groupGroups.removeAt(0);
        matched = groupEntry.matched;
        action = groupEntry.action;
        rule = groupRule;
        if (groupGroups.isEmpty) {
          groupGroups = null;
          groupMatches = null;
          groupRule = null;
        }
      } else {
        if (!forceEvaluation && pos >= lineLength) {
          break;
        }
        forceEvaluation = false;

        List<IRule>? rules = _lexer.tokenizer[state];
        if (rules == null) {
          rules = findRules(_lexer, state);
          if (rules == null) {
            throw createMonarchError(_lexer,
                'tokenizer state is not defined: $state');
          }
        }

        final String restOfLine = line.substring(pos);
        for (final IRule candidate in rules) {
          if (pos == 0 || !candidate.matchOnlyAtLineStart) {
            final Object regexObject = candidate.resolveRegex(state);
            final RegExp regex = regexObject as RegExp;
            final Match? m = regex.firstMatch(restOfLine);
            if (m != null) {
              matches = <String>[];
              for (int i = 0; i <= m.groupCount; i++) {
                matches.add(m.group(i) ?? '');
              }
              matched = m.group(0);
              action = candidate.action;
              rule = candidate;
              break;
            }
          }
        }
      }

      if (matches == null) {
        matches = <String>[''];
        matched = '';
      }
      if (action == null) {
        if (pos < lineLength) {
          matches = <String>[line[pos]];
          matched = matches[0];
        }
        action = _lexer.defaultToken;
      }
      if (matched == null) {
        break;
      }

      pos += matched.length;

      while (isFuzzyAction(action) &&
          isIAction(action) &&
          (action as IAction).test != null) {
        action = action.test!(matched, matches, state, pos == lineLength);
      }

      Object? result;
      if (action is String || isFuzzyActionArr(action)) {
        result = action;
      } else if (action is IAction) {
        if (action.group != null) {
          result = action.group;
        } else if (action.token != null) {
          result = action.tokenSubst
              ? substituteMatches(_lexer, action.token!, matched, matches, state)
              : action.token;

          if (action.nextEmbedded != null) {
            if (action.nextEmbedded == '@pop') {
              if (embeddedLanguageData == null) {
                throw createMonarchError(_lexer,
                    'cannot pop embedded language if not inside one');
              }
              embeddedLanguageData = null;
            } else if (embeddedLanguageData != null) {
              throw createMonarchError(_lexer,
                  'cannot enter embedded language from within an embedded language');
            } else {
              enteringEmbeddedLanguage = substituteMatches(
                  _lexer, action.nextEmbedded!, matched, matches, state);
            }
          }

          if (action.goBack != null) {
            pos = pos - action.goBack! < 0 ? 0 : pos - action.goBack!;
          }

          if (action.switchTo != null) {
            String nextState = substituteMatches(
                _lexer, action.switchTo!, matched, matches, state);
            if (nextState.startsWith('@')) {
              nextState = nextState.substring(1);
            }
            if (findRules(_lexer, nextState) == null) {
              throw createMonarchError(
                  _lexer,
                  "trying to switch to a state '$nextState' that is undefined in rule: ${_safeRuleName(rule)}");
            } else {
              stack = stack.switchTo(nextState);
            }
          } else if (action.transform != null) {
            throw createMonarchError(_lexer, 'action.transform not supported');
          } else if (action.next != null) {
            if (action.next == '@push') {
              if (stack.depth >= _lexer.maxStack) {
                throw createMonarchError(
                    _lexer,
                    'maximum tokenizer stack size reached: [${stack.state},${stack.parent!.state},...]');
              } else {
                stack = stack.push(state);
              }
            } else if (action.next == '@pop') {
              if (stack.depth <= 1) {
                throw createMonarchError(_lexer,
                    'trying to pop an empty stack in rule: ${_safeRuleName(rule)}');
              } else {
                stack = stack.pop()!;
              }
            } else if (action.next == '@popall') {
              stack = stack.popall();
            } else {
              String nextState = substituteMatches(
                  _lexer, action.next!, matched, matches, state);
              if (nextState.startsWith('@')) {
                nextState = nextState.substring(1);
              }
              if (findRules(_lexer, nextState) == null) {
                throw createMonarchError(
                    _lexer,
                    "trying to set a next state '$nextState' that is undefined in rule: ${_safeRuleName(rule)}");
              } else {
                stack = stack.push(nextState);
              }
            }
          }

          if (action.log != null) {
            monarchLog(_lexer,
                '${_lexer.languageId}: ${substituteMatches(_lexer, action.log!, matched, matches, state)}');
          }
        }
      }

      if (result == null) {
        throw createMonarchError(_lexer,
            'lexer rule has no well-defined action in rule: ${_safeRuleName(rule)}');
      }

      MonarchLineState computeNewStateForEmbeddedLanguage(
          String enteringLanguage) {
        final String languageId =
            _languageService.getLanguageIdByLanguageName(enteringLanguage) ??
                _languageService.getLanguageIdByMimeType(enteringLanguage) ??
                enteringLanguage;
        final EmbeddedLanguageData embedded =
            _getNestedEmbeddedLanguageData(languageId);
        if (pos < lineLength) {
          final String restOfLine = lineWithoutLF.substring(pos);
          return _nestedTokenize(
              restOfLine,
              hasEOL,
              MonarchLineStateFactory.create(stack, embedded),
              offsetDelta + pos,
              tokensCollector);
        }
        return MonarchLineStateFactory.create(stack, embedded);
      }

      if (result is List) {
        if ((groupGroups?.length ?? 0) > 0) {
          throw createMonarchError(
              _lexer, 'groups cannot be nested: ${_safeRuleName(rule)}');
        }
        if (matches.length != result.length + 1) {
          throw createMonarchError(
              _lexer,
              'matched number of groups does not match the number of actions in rule: ${_safeRuleName(rule)}');
        }
        int totalLen = 0;
        for (int i = 1; i < matches.length; i++) {
          totalLen += matches[i].length;
        }
        if (totalLen != matched.length) {
          throw createMonarchError(
              _lexer,
              'with groups, all characters should be matched in consecutive groups in rule: ${_safeRuleName(rule)}');
        }
        groupMatches = matches;
        groupRule = rule;
        groupGroups = <_GroupEntry>[];
        for (int i = 0; i < result.length; i++) {
          groupGroups.add(_GroupEntry(
              result[i] as FuzzyAction, matches[i + 1]));
        }
        pos -= matched.length;
        continue;
      } else {
        if (result == '@rematch') {
          pos -= matched.length;
          matched = '';
          matches = <String>[];
          result = '';
          if (enteringEmbeddedLanguage != null) {
            return computeNewStateForEmbeddedLanguage(enteringEmbeddedLanguage);
          }
        }

        if (matched.isEmpty) {
          if (lineLength == 0 ||
              stackLen0 != stack.depth ||
              state != stack.state ||
              (groupGroups?.length ?? 0) != groupLen0) {
            continue;
          } else {
            throw createMonarchError(_lexer,
                'no progress in tokenizer in rule: ${_safeRuleName(rule)}');
          }
        }

        String tokenType;
        final String resultString = result as String;
        if (resultString.startsWith('@brackets')) {
          final String rest = resultString.substring('@brackets'.length);
          final BracketMatch? bracket = findBracket(_lexer, matched);
          if (bracket == null) {
            throw createMonarchError(_lexer,
                '@brackets token returned but no bracket defined as: $matched');
          }
          tokenType = sanitize(bracket.token + rest);
        } else {
          final String token =
              resultString.isEmpty ? '' : resultString + _lexer.tokenPostfix;
          tokenType = sanitize(token);
        }

        if (pos0 < lineWithoutLFLength) {
          tokensCollector.emit(pos0 + offsetDelta, tokenType);
        }
      }

      if (enteringEmbeddedLanguage != null) {
        return computeNewStateForEmbeddedLanguage(enteringEmbeddedLanguage);
      }
    }

    return MonarchLineStateFactory.create(stack, embeddedLanguageData);
  }

  EmbeddedLanguageData _getNestedEmbeddedLanguageData(String languageId) {
    if (!_languageService.isRegisteredLanguageId(languageId)) {
      return EmbeddedLanguageData(languageId, NullState.instance);
    }
    if (languageId != _languageId) {
      _languageService.requestBasicLanguageFeatures(languageId);
      TokenizationRegistry.getOrCreate(languageId);
      _embeddedLanguages[languageId] = true;
    }
    final Object? support = TokenizationRegistry.get(languageId);
    if (support != null) {
      final dynamic s = support;
      return EmbeddedLanguageData(languageId, s.getInitialState());
    }
    return EmbeddedLanguageData(languageId, NullState.instance);
  }
}

class _GroupEntry {
  final FuzzyAction action;
  final String matched;

  _GroupEntry(this.action, this.matched);
}

class BracketMatch {
  final String token;
  final int bracketType;

  BracketMatch(this.token, this.bracketType);
}

/// Searches for a bracket in the `brackets` attribute that matches the input.
BracketMatch? findBracket(ILexer lexer, String matched) {
  if (matched.isEmpty) {
    return null;
  }
  matched = fixCase(lexer, matched);
  for (final IBracket carrier in lexer.brackets) {
    if (carrier.open == matched) {
      return BracketMatch(carrier.token, MonarchBracket.Open);
    } else if (carrier.close == matched) {
      return BracketMatch(carrier.token, MonarchBracket.Close);
    }
  }
  return null;
}
