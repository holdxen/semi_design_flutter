// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/model/textModelTokens.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Adaptations (documented inline):
//  * Erased interfaces (`IState`, `ITextModel`, `ITokenizationSupport`,
//    `IBackgroundTokenizationStore`) are local minimal contracts.
//  * TS generic `TState extends IState` -> Dart bounded generic.
//  * `Number.MAX_SAFE_INTEGER` -> 0x1FFFFFFFFFFFFF.
//  * `LineRange` / `OffsetRange` / `FixedArray` are the existing ported types.
// ---------------------------------------------------------------------------
import '../../../base/common/async.dart' show IdleDeadline, runWhenGlobalIdle;
import '../../../base/common/errors.dart' show BugIndicatingError, onUnexpectedError;
import '../../../base/common/platform.dart' show setTimeout0;
import '../../../base/common/stopwatch.dart' show StopWatch;
import '../core/misc/eolCounter.dart' show countEOL;
import '../core/position.dart' show Position;
import '../core/ranges/lineRange.dart' show LineRange;
import '../core/ranges/offsetRange.dart' show OffsetRange;
import '../encodedTokenAttributes.dart' show StandardTokenType;
import '../languages.dart' show EncodedTokenizationResult;
import '../languages/nullTokenize.dart' show nullTokenizeEncoded;
import '../tokens/contiguousMultilineTokens.dart' show ContiguousMultilineTokens;
import '../tokens/contiguousMultilineTokensBuilder.dart'
    show ContiguousMultilineTokensBuilder;
import '../tokens/lineTokens.dart' show ILanguageIdCodec, LineTokens;
import 'fixedArray.dart' show FixedArray;
import 'mirrorTextModel.dart' show IModelContentChange;

/// 1:1: `const enum Constants`.
class Constants {
  const Constants._();
  static const int CHEAP_TOKENIZATION_LENGTH_LIMIT = 2048;
}

/// 1:1: `IState` (erased interface).
abstract class IStateForTokenization {
  IStateForTokenization clone();
  bool equals(Object other);
}

/// 1:1: `ITokenizationSupport.tokenizeEncoded` member.
abstract class ITokenizationSupportForTokenModel {
  IStateForTokenization getInitialState();

  EncodedTokenizationResult tokenizeEncoded(
      String text, bool hasEOL, IStateForTokenization state);
}

/// 1:1: `ITextModel` members read here.
abstract class ITextModelForTokenModel {
  String getLanguageId();
  String getLineContent(int lineNumber);
  int getLineCount();
  int getLineLength(int lineNumber);
  int getLineFirstNonWhitespaceColumn(int lineNumber);
  bool isAttachedToEditor();
}

/// 1:1: `IBackgroundTokenizationStore` members read here.
abstract class IBackgroundTokenizationStoreForTokenModel {
  void setTokens(List<ContiguousMultilineTokens> tokens);
  void backgroundTokenizationFinished();
}

/// 1:1: `export class TokenizerWithStateStore<TState extends IState>`.
class TokenizerWithStateStore<TState extends IStateForTokenization> {
  late final TState initialState;
  late final TrackingTokenizationStateStore<TState> store;

  final ITokenizationSupportForTokenModel tokenizationSupport;

  TokenizerWithStateStore(
      int lineCount, this.tokenizationSupport)
      : assert(lineCount >= 0) {
    initialState = tokenizationSupport.getInitialState() as TState;
    store = TrackingTokenizationStateStore<TState>(lineCount);
  }

  TState? getStartState(int lineNumber) =>
      store.getStartState(lineNumber, initialState);

  ({int lineNumber, TState startState})? getFirstInvalidLine() =>
      store.getFirstInvalidLine(initialState);
}

/// 1:1: `export class TokenizerWithStateStoreAndTextModel`.
class TokenizerWithStateStoreAndTextModel<TState extends IStateForTokenization>
    extends TokenizerWithStateStore<TState> {
  final ITextModelForTokenModel _textModel;
  final ILanguageIdCodec _languageIdCodec;

  TokenizerWithStateStoreAndTextModel(
    int lineCount,
    ITokenizationSupportForTokenModel tokenizationSupport,
    this._textModel,
    this._languageIdCodec,
  ) : super(lineCount, tokenizationSupport);

  ITextModelForTokenModel get textModel => _textModel;

  void updateTokensUntilLine(
      ContiguousMultilineTokensBuilder builder, int lineNumber) {
    final String languageId = _textModel.getLanguageId();
    while (true) {
      final ({int lineNumber, TState startState})? lineToTokenize =
          getFirstInvalidLine();
      if (lineToTokenize == null ||
          lineToTokenize.lineNumber > lineNumber) {
        break;
      }
      final String text = _textModel.getLineContent(lineToTokenize.lineNumber);
      final EncodedTokenizationResult r = safeTokenize(
          _languageIdCodec,
          languageId,
          tokenizationSupport,
          text,
          true,
          lineToTokenize.startState);
      builder.add(lineToTokenize.lineNumber, r.tokens);
      store.setEndState(lineToTokenize.lineNumber, r.endState as TState);
    }
  }

  /// assumes state is up to date
  int getTokenTypeIfInsertingCharacter(Position position, String character) {
    final TState? lineStartState = getStartState(position.lineNumber);
    if (lineStartState == null) {
      return StandardTokenType.other;
    }
    final String languageId = _textModel.getLanguageId();
    final String lineContent = _textModel.getLineContent(position.lineNumber);
    final String text = lineContent.substring(0, position.column - 1) +
        character +
        lineContent.substring(position.column - 1);
    final EncodedTokenizationResult r = safeTokenize(
        _languageIdCodec,
        languageId,
        tokenizationSupport,
        text,
        true,
        lineStartState);
    final LineTokens lineTokens =
        LineTokens(r.tokens, text, _languageIdCodec);
    if (lineTokens.getCount() == 0) {
      return StandardTokenType.other;
    }
    final int tokenIndex =
        lineTokens.findTokenIndexAtOffset(position.column - 1);
    return lineTokens.getStandardTokenType(tokenIndex);
  }

  /// assumes state is up to date
  List<LineTokens>? tokenizeLinesAt(int lineNumber, List<String> lines) {
    final TState? lineStartState = getStartState(lineNumber);
    if (lineStartState == null) {
      return null;
    }
    final String languageId = _textModel.getLanguageId();
    final List<LineTokens> result = <LineTokens>[];
    IStateForTokenization state = lineStartState;
    for (final String line in lines) {
      final EncodedTokenizationResult r = safeTokenize(
          _languageIdCodec, languageId, tokenizationSupport, line, true, state);
      result.add(LineTokens(r.tokens, line, _languageIdCodec));
      state = r.endState as IStateForTokenization;
    }
    return result;
  }

  bool hasAccurateTokensForLine(int lineNumber) =>
      lineNumber < store.getFirstInvalidEndStateLineNumberOrMax();

  bool isCheapToTokenize(int lineNumber) {
    final int firstInvalidLineNumber =
        store.getFirstInvalidEndStateLineNumberOrMax();
    if (lineNumber < firstInvalidLineNumber) {
      return true;
    }
    if (lineNumber == firstInvalidLineNumber &&
        _textModel.getLineLength(lineNumber) <
            Constants.CHEAP_TOKENIZATION_LENGTH_LIMIT) {
      return true;
    }
    return false;
  }

  /// The result is not cached.
  ({bool heuristicTokens}) tokenizeHeuristically(
      ContiguousMultilineTokensBuilder builder,
      int startLineNumber,
      int endLineNumber) {
    if (endLineNumber <= store.getFirstInvalidEndStateLineNumberOrMax()) {
      return (heuristicTokens: false);
    }
    if (startLineNumber <= store.getFirstInvalidEndStateLineNumberOrMax()) {
      updateTokensUntilLine(builder, endLineNumber);
      return (heuristicTokens: false);
    }
    IStateForTokenization state = guessStartState(startLineNumber);
    final String languageId = _textModel.getLanguageId();
    for (int lineNumber = startLineNumber;
        lineNumber <= endLineNumber;
        lineNumber++) {
      final String text = _textModel.getLineContent(lineNumber);
      final EncodedTokenizationResult r = safeTokenize(
          _languageIdCodec, languageId, tokenizationSupport, text, true, state);
      builder.add(lineNumber, r.tokens);
      state = r.endState as IStateForTokenization;
    }
    return (heuristicTokens: true);
  }

  IStateForTokenization guessStartState(int lineNumber) {
    final ({List<String> likelyRelevantLines, Object? initialState}) found =
        findLikelyRelevantLines(_textModel, lineNumber, this);
    IStateForTokenization state = found.initialState as IStateForTokenization? ??
        tokenizationSupport.getInitialState();
    final String languageId = _textModel.getLanguageId();
    for (final String line in found.likelyRelevantLines) {
      final EncodedTokenizationResult r = safeTokenize(
          _languageIdCodec, languageId, tokenizationSupport, line, false, state);
      state = r.endState as IStateForTokenization;
    }
    return state;
  }
}

/// 1:1: `export function findLikelyRelevantLines`.
({List<String> likelyRelevantLines, Object? initialState})
    findLikelyRelevantLines(
  ITextModelForTokenModel model,
  int lineNumber, [
  TokenizerWithStateStore? store,
]) {
  int nonWhitespaceColumn =
      model.getLineFirstNonWhitespaceColumn(lineNumber);
  final List<String> likelyRelevantLines = <String>[];
  Object? initialState;
  for (int i = lineNumber - 1; nonWhitespaceColumn > 1 && i >= 1; i--) {
    final int newNonWhitespaceIndex =
        model.getLineFirstNonWhitespaceColumn(i);
    if (newNonWhitespaceIndex == 0) {
      continue;
    }
    if (newNonWhitespaceIndex < nonWhitespaceColumn) {
      likelyRelevantLines.add(model.getLineContent(i));
      nonWhitespaceColumn = newNonWhitespaceIndex;
      initialState = store?.getStartState(i);
      if (initialState != null) {
        break;
      }
    }
  }
  return (
    likelyRelevantLines: likelyRelevantLines.reversed.toList(),
    initialState: initialState,
  );
}

/// 1:1: `export class TrackingTokenizationStateStore`.
class TrackingTokenizationStateStore<TState extends IStateForTokenization> {
  final TokenizationStateStore<TState> _tokenizationStateStore =
      TokenizationStateStore<TState>();
  final RangePriorityQueueImpl _invalidEndStatesLineNumbers =
      RangePriorityQueueImpl();

  int lineCount;

  TrackingTokenizationStateStore(this.lineCount) {
    _invalidEndStatesLineNumbers.addRange(OffsetRange(1, lineCount + 1));
  }

  TState? getEndState(int lineNumber) =>
      _tokenizationStateStore.getEndState(lineNumber);

  /// @returns if the end state has changed.
  bool setEndState(int lineNumber, TState state) {
    _invalidEndStatesLineNumbers.delete(lineNumber);
    final bool r = _tokenizationStateStore.setEndState(lineNumber, state);
    if (r && lineNumber < lineCount) {
      _invalidEndStatesLineNumbers
          .addRange(OffsetRange(lineNumber + 1, lineNumber + 2));
    }
    return r;
  }

  void acceptChange(LineRange range, int newLineCount) {
    lineCount += newLineCount - range.length;
    _tokenizationStateStore.acceptChange(range, newLineCount);
    _invalidEndStatesLineNumbers.addRangeAndResize(
        OffsetRange(range.startLineNumber, range.endLineNumberExclusive),
        newLineCount);
  }

  void acceptChanges(List<IModelContentChange> changes) {
    for (final IModelContentChange c in changes) {
      final (int eolCount, int _, int _, int _) = countEOL(c.text);
      acceptChange(
          LineRange(c.range.startLineNumber, c.range.endLineNumber + 1),
          eolCount + 1);
    }
  }

  void invalidateEndStateRange(LineRange range) {
    _invalidEndStatesLineNumbers
        .addRange(OffsetRange(range.startLineNumber, range.endLineNumberExclusive));
  }

  /// Replay-only view of the TS private `_invalidEndStatesLineNumbers`.
  List<OffsetRange> get invalidEndStatesLineNumbers =>
      _invalidEndStatesLineNumbers.getRanges();

  int? getFirstInvalidEndStateLineNumber() =>
      _invalidEndStatesLineNumbers.min;

  int getFirstInvalidEndStateLineNumberOrMax() =>
      getFirstInvalidEndStateLineNumber() ?? 0x1FFFFFFFFFFFFF;

  bool allStatesValid() => _invalidEndStatesLineNumbers.min == null;

  TState? getStartState(int lineNumber, TState initialState) {
    if (lineNumber == 1) {
      return initialState;
    }
    return getEndState(lineNumber - 1);
  }

  ({int lineNumber, TState startState})? getFirstInvalidLine(
      TState initialState) {
    final int? lineNumber = getFirstInvalidEndStateLineNumber();
    if (lineNumber == null) {
      return null;
    }
    final TState? startState = getStartState(lineNumber, initialState);
    if (startState == null) {
      throw BugIndicatingError('Start state must be defined');
    }
    return (lineNumber: lineNumber, startState: startState);
  }
}

/// 1:1: `export class TokenizationStateStore`.
class TokenizationStateStore<TState extends IStateForTokenization> {
  final FixedArray<TState?> _lineEndStates = FixedArray<TState?>(null);

  TState? getEndState(int lineNumber) => _lineEndStates.get(lineNumber);

  bool setEndState(int lineNumber, TState state) {
    final TState? oldState = _lineEndStates.get(lineNumber);
    if (oldState != null && oldState.equals(state)) {
      return false;
    }
    _lineEndStates.set(lineNumber, state);
    return true;
  }

  void acceptChange(LineRange range, int newLineCount) {
    int length = range.length;
    if (newLineCount > 0 && length > 0) {
      // Keep the last state, even though it is unrelated.
      length--;
      newLineCount--;
    }
    _lineEndStates.replace(range.startLineNumber, length, newLineCount);
  }

  void acceptChanges(List<IModelContentChange> changes) {
    for (final IModelContentChange c in changes) {
      final (int eolCount, int _, int _, int _) = countEOL(c.text);
      acceptChange(
          LineRange(c.range.startLineNumber, c.range.endLineNumber + 1),
          eolCount + 1);
    }
  }
}

/// 1:1: `interface RangePriorityQueue`.
abstract class RangePriorityQueue {
  int? get min;
  int? removeMin();
  void addRange(OffsetRange range);
  void addRangeAndResize(OffsetRange range, int newLength);
}

/// 1:1: `export class RangePriorityQueueImpl`.
class RangePriorityQueueImpl implements RangePriorityQueue {
  final List<OffsetRange> _ranges = <OffsetRange>[];

  List<OffsetRange> getRanges() => _ranges;

  @override
  int? get min {
    if (_ranges.isEmpty) {
      return null;
    }
    return _ranges[0].start;
  }

  @override
  int? removeMin() {
    if (_ranges.isEmpty) {
      return null;
    }
    final OffsetRange range = _ranges[0];
    if (range.start + 1 == range.endExclusive) {
      _ranges.removeAt(0);
    } else {
      _ranges[0] = OffsetRange(range.start + 1, range.endExclusive);
    }
    return range.start;
  }

  void delete(int value) {
    final int idx = _ranges.indexWhere((r) => r.contains(value));
    if (idx != -1) {
      final OffsetRange range = _ranges[idx];
      if (range.start == value) {
        if (range.endExclusive == value + 1) {
          _ranges.removeAt(idx);
        } else {
          _ranges[idx] = OffsetRange(value + 1, range.endExclusive);
        }
      } else {
        if (range.endExclusive == value + 1) {
          _ranges[idx] = OffsetRange(range.start, value);
        } else {
          _ranges.removeRange(idx, idx + 1);
          _ranges.insertAll(idx, <OffsetRange>[
            OffsetRange(range.start, value),
            OffsetRange(value + 1, range.endExclusive),
          ]);
        }
      }
    }
  }

  @override
  void addRange(OffsetRange range) {
    OffsetRange.addRange(range, _ranges);
  }

  @override
  void addRangeAndResize(OffsetRange range, int newLength) {
    int idxFirstMightBeIntersecting = 0;
    while (!(idxFirstMightBeIntersecting >= _ranges.length ||
        range.start <= _ranges[idxFirstMightBeIntersecting].endExclusive)) {
      idxFirstMightBeIntersecting++;
    }
    int idxFirstIsAfter = idxFirstMightBeIntersecting;
    while (!(idxFirstIsAfter >= _ranges.length ||
        range.endExclusive < _ranges[idxFirstIsAfter].start)) {
      idxFirstIsAfter++;
    }
    final int delta = newLength - range.length;

    for (int i = idxFirstIsAfter; i < _ranges.length; i++) {
      _ranges[i] = _ranges[i].delta(delta);
    }

    if (idxFirstMightBeIntersecting == idxFirstIsAfter) {
      final OffsetRange newRange =
          OffsetRange(range.start, range.start + newLength);
      if (!newRange.isEmpty) {
        _ranges.insert(idxFirstMightBeIntersecting, newRange);
      }
    } else {
      final int start = range.start <
              _ranges[idxFirstMightBeIntersecting].start
          ? range.start
          : _ranges[idxFirstMightBeIntersecting].start;
      final int endEx = range.endExclusive >
              _ranges[idxFirstIsAfter - 1].endExclusive
          ? range.endExclusive
          : _ranges[idxFirstIsAfter - 1].endExclusive;
      final OffsetRange newRange = OffsetRange(start, endEx + delta);
      final int removeCount =
          idxFirstIsAfter - idxFirstMightBeIntersecting;
      if (!newRange.isEmpty) {
        _ranges.replaceRange(idxFirstMightBeIntersecting,
            idxFirstMightBeIntersecting + removeCount, <OffsetRange>[newRange]);
      } else {
        _ranges.removeRange(idxFirstMightBeIntersecting,
            idxFirstMightBeIntersecting + removeCount);
      }
    }
  }

  @override
  String toString() =>
      _ranges.map((r) => r.toString()).join(' + ');
}

/// 1:1: `function safeTokenize(...)`.
EncodedTokenizationResult safeTokenize(
    ILanguageIdCodec languageIdCodec,
    String languageId,
    ITokenizationSupportForTokenModel? tokenizationSupport,
    String text,
    bool hasEOL,
    IStateForTokenization state) {
  EncodedTokenizationResult? r;
  if (tokenizationSupport != null) {
    try {
      r = tokenizationSupport.tokenizeEncoded(
          text, hasEOL, state.clone());
    } catch (e) {
      onUnexpectedError(e);
    }
  }
  r ??= nullTokenizeEncoded(languageIdCodec.encodeLanguageId(languageId), state);
  LineTokens.convertToEndOffset(r.tokens, text.length);
  return r;
}

/// 1:1: `export class DefaultBackgroundTokenizer`.
class DefaultBackgroundTokenizer {
  bool _isDisposed = false;
  bool _isScheduled = false;

  final TokenizerWithStateStoreAndTextModel _tokenizerWithStateStore;
  final IBackgroundTokenizationStoreForTokenModel _backgroundTokenStore;

  DefaultBackgroundTokenizer(
    this._tokenizerWithStateStore,
    this._backgroundTokenStore,
  );

  void dispose() {
    _isDisposed = true;
  }

  void handleChanges() {
    _beginBackgroundTokenization();
  }

  void _beginBackgroundTokenization() {
    if (_isScheduled ||
        !_tokenizerWithStateStore._textModel.isAttachedToEditor() ||
        !_hasLinesToTokenize()) {
      return;
    }
    _isScheduled = true;
    runWhenGlobalIdle((deadline) {
      _isScheduled = false;
      _backgroundTokenizeWithDeadline(deadline);
    });
  }

  void _backgroundTokenizeWithDeadline(IdleDeadline deadline) {
    final int endTime =
        DateTime.now().millisecondsSinceEpoch + deadline.timeRemaining();
    void execute() {
      if (_isDisposed ||
          !_tokenizerWithStateStore._textModel.isAttachedToEditor() ||
          !_hasLinesToTokenize()) {
        return;
      }
      _backgroundTokenizeForAtLeast1ms();
      if (DateTime.now().millisecondsSinceEpoch < endTime) {
        setTimeout0(execute);
      } else {
        _beginBackgroundTokenization();
      }
    }
    execute();
  }

  void _backgroundTokenizeForAtLeast1ms() {
    final int lineCount = _tokenizerWithStateStore._textModel.getLineCount();
    final ContiguousMultilineTokensBuilder builder =
        ContiguousMultilineTokensBuilder();
    final StopWatch sw = StopWatch.create(false);
    do {
      if (sw.elapsed() > 1) {
        break;
      }
      final int tokenizedLineNumber = _tokenizeOneInvalidLine(builder);
      if (tokenizedLineNumber >= lineCount) {
        break;
      }
    } while (_hasLinesToTokenize());
    _backgroundTokenStore.setTokens(builder.finalize());
    checkFinished();
  }

  bool _hasLinesToTokenize() =>
      !_tokenizerWithStateStore.store.allStatesValid();

  int _tokenizeOneInvalidLine(ContiguousMultilineTokensBuilder builder) {
    final ({int lineNumber, IStateForTokenization startState})? firstInvalidLine =
        _tokenizerWithStateStore.getFirstInvalidLine();
    if (firstInvalidLine == null) {
      return _tokenizerWithStateStore._textModel.getLineCount() + 1;
    }
    _tokenizerWithStateStore.updateTokensUntilLine(
        builder, firstInvalidLine.lineNumber);
    return firstInvalidLine.lineNumber;
  }

  void checkFinished() {
    if (_isDisposed) {
      return;
    }
    if (_tokenizerWithStateStore.store.allStatesValid()) {
      _backgroundTokenStore.backgroundTokenizationFinished();
    }
  }

  void requestTokens(int startLineNumber, int endLineNumberExclusive) {
    _tokenizerWithStateStore.store.invalidateEndStateRange(
        LineRange(startLineNumber, endLineNumberExclusive));
  }
}
