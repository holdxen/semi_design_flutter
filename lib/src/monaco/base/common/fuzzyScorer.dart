// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/fuzzyScorer.ts
// Translated 1:1 from TypeScript.
//
// TS tuple aliases are carried by small classes because Dart has no tuples:
//   FuzzyScore  = [number, number[]]          -> FuzzyScore(score, positions)
//   FuzzyScore2 = [number | undefined, IMatch[]] -> FuzzyScore2(score, matches)
// ---------------------------------------------------------------------------

import 'charCode.dart' show CharCode;
import 'comparers.dart' show compareAnything;
import 'filters.dart' show IMatch, fuzzyScore, isUpper, matchesPrefix;
import 'filters.dart' as filters show createMatches;
import 'hash.dart'
    show
        ARRAY_HASH_SEED,
        OBJECT_HASH_SEED,
        ConstantStringHash,
        doHash,
        numberHash,
        stringHash;
import 'path.dart' show sep;
import 'platform.dart' show isLinux, isWindows;
import 'strings.dart' show equalsIgnoreCase;

/// 1:1: `export type FuzzyScore = [number, number[]]`
class FuzzyScore {
  final int score;
  final List<int> positions;

  const FuzzyScore(this.score, this.positions);

  int operator [](int index) => index == 0 ? score : positions[index - 1];
}

/// 1:1: `export type FuzzyScorerCache = { [key: string]: IItemScore }`
/// TS object keys are coerced to strings; Dart uses the numeric hash directly.
typedef FuzzyScorerCache = Map<Object, IItemScore>;

const int NO_MATCH = 0;
final FuzzyScore NO_SCORE = FuzzyScore(NO_MATCH, <int>[]);

/// 1:1: `export function scoreFuzzy`
FuzzyScore scoreFuzzy(String target, String query, String queryLower, bool allowNonContiguousMatches) {
  if (target.isEmpty || query.isEmpty) {
    return NO_SCORE;
  }

  final int targetLength = target.length;
  final int queryLength = query.length;

  if (targetLength < queryLength) {
    return NO_SCORE;
  }

  final String targetLower = target.toLowerCase();
  return _doScoreFuzzy(query, queryLower, queryLength, target, targetLower, targetLength, allowNonContiguousMatches);
}

FuzzyScore _doScoreFuzzy(String query, String queryLower, int queryLength, String target, String targetLower, int targetLength, bool allowNonContiguousMatches) {
  final List<int> scores = List<int>.filled(queryLength * targetLength, 0);
  final List<int> matches = List<int>.filled(queryLength * targetLength, 0);

  for (int queryIndex = 0; queryIndex < queryLength; queryIndex++) {
    final int queryIndexOffset = queryIndex * targetLength;
    final int queryIndexPreviousOffset = queryIndexOffset - targetLength;

    final bool queryIndexGtNull = queryIndex > 0;

    final String queryCharAtIndex = query[queryIndex];
    final String queryLowerCharAtIndex = queryLower[queryIndex];

    for (int targetIndex = 0; targetIndex < targetLength; targetIndex++) {
      final bool targetIndexGtNull = targetIndex > 0;

      final int currentIndex = queryIndexOffset + targetIndex;
      final int leftIndex = currentIndex - 1;
      final int diagIndex = queryIndexPreviousOffset + targetIndex - 1;

      final int leftScore = targetIndexGtNull ? scores[leftIndex] : 0;
      final int diagScore = queryIndexGtNull && targetIndexGtNull ? scores[diagIndex] : 0;

      final int matchesSequenceLength = queryIndexGtNull && targetIndexGtNull ? matches[diagIndex] : 0;

      final int score;
      if (diagScore == 0 && queryIndexGtNull) {
        score = 0;
      } else {
        score = _computeCharScore(queryCharAtIndex, queryLowerCharAtIndex, target, targetLower, targetIndex, matchesSequenceLength);
      }

      final bool isValidScore = score != 0 && diagScore + score >= leftScore;
      if (isValidScore && (allowNonContiguousMatches || queryIndexGtNull || targetLower.startsWith(queryLower, targetIndex))) {
        matches[currentIndex] = matchesSequenceLength + 1;
        scores[currentIndex] = diagScore + score;
      } else {
        matches[currentIndex] = NO_MATCH;
        scores[currentIndex] = leftScore;
      }
    }
  }

  final List<int> positions = <int>[];
  int queryIndex = queryLength - 1;
  int targetIndex = targetLength - 1;
  while (queryIndex >= 0 && targetIndex >= 0) {
    final int currentIndex = queryIndex * targetLength + targetIndex;
    final int match = matches[currentIndex];
    if (match == NO_MATCH) {
      targetIndex--;
    } else {
      positions.add(targetIndex);
      queryIndex--;
      targetIndex--;
    }
  }

  return FuzzyScore(scores[queryLength * targetLength - 1], positions.reversed.toList());
}

int _computeCharScore(String queryCharAtIndex, String queryLowerCharAtIndex, String target, String targetLower, int targetIndex, int matchesSequenceLength) {
  int score = 0;

  if (!_considerAsEqual(queryLowerCharAtIndex, targetLower[targetIndex])) {
    return score;
  }

  score += 1;

  if (matchesSequenceLength > 0) {
    score += (_min(matchesSequenceLength, 3) * 6) + (_max(0, matchesSequenceLength - 3) * 3);
  }

  if (queryCharAtIndex == target[targetIndex]) {
    score += 1;
  }

  if (targetIndex == 0) {
    score += 8;
  } else {
    final int separatorBonus = _scoreSeparatorAtPos(target.codeUnitAt(targetIndex - 1));
    if (separatorBonus != 0) {
      score += separatorBonus;
    } else if (isUpper(target.codeUnitAt(targetIndex)) && matchesSequenceLength == 0) {
      score += 2;
    }
  }

  return score;
}

bool _considerAsEqual(String a, String b) {
  if (a == b) {
    return true;
  }
  if (a == '/' || a == '\\') {
    return b == '/' || b == '\\';
  }
  return false;
}

int _scoreSeparatorAtPos(int charCode) {
  switch (charCode) {
    case CharCode.Slash:
    case CharCode.Backslash:
      return 5;
    case CharCode.Underline:
    case CharCode.Dash:
    case CharCode.Period:
    case CharCode.Space:
    case CharCode.SingleQuote:
    case CharCode.DoubleQuote:
    case CharCode.Colon:
      return 4;
    default:
      return 0;
  }
}

int _min(int a, int b) => a < b ? a : b;
int _max(int a, int b) => a > b ? a : b;

// #region Alternate fuzzy scorer implementation that is e.g. used for symbols

/// 1:1: `export type FuzzyScore2 = [number | undefined, IMatch[]]`
class FuzzyScore2 {
  final int? score;
  final List<IMatch> matches;

  const FuzzyScore2(this.score, this.matches);
}

final FuzzyScore2 NO_SCORE2 = FuzzyScore2(null, <IMatch>[]);

/// 1:1: `export function scoreFuzzy2`
FuzzyScore2 scoreFuzzy2(String target, Object query, [int patternStart = 0, int wordStart = 0]) {
  final IPreparedQuery preparedQuery = query as IPreparedQuery;
  if (preparedQuery.values != null && preparedQuery.values!.length > 1) {
    return _doScoreFuzzy2Multiple(target, preparedQuery.values!, patternStart, wordStart);
  }
  return _doScoreFuzzy2Single(target, query as IPreparedQueryPiece, patternStart, wordStart);
}

FuzzyScore2 _doScoreFuzzy2Multiple(String target, List<IPreparedQueryPiece> query, int patternStart, int wordStart) {
  int totalScore = 0;
  final List<IMatch> totalMatches = <IMatch>[];

  for (final IPreparedQueryPiece queryPiece in query) {
    final FuzzyScore2 result = _doScoreFuzzy2Single(target, queryPiece, patternStart, wordStart);
    if (result.score == null) {
      return NO_SCORE2;
    }
    totalScore += result.score!;
    totalMatches.addAll(result.matches);
  }

  return FuzzyScore2(totalScore, _normalizeMatches(totalMatches));
}

FuzzyScore2 _doScoreFuzzy2Single(String target, IPreparedQueryPiece query, int patternStart, int wordStart) {
  final List<int>? score = fuzzyScore(
    query.normalized,
    query.normalizedLowercase,
    patternStart,
    target,
    target.toLowerCase(),
    wordStart,
  );
  if (score == null) {
    return NO_SCORE2;
  }
  return FuzzyScore2(score[0], filters.createMatches(score));
}

// #endregion

// #region Item (label, description, path) scorer

/// 1:1: `export interface IItemScore`
class IItemScore {
  int score;
  List<IMatch>? labelMatch;
  List<IMatch>? descriptionMatch;

  IItemScore(this.score, [this.labelMatch, this.descriptionMatch]);
}

final IItemScore NO_ITEM_SCORE = IItemScore(0);

/// 1:1: `export interface IItemAccessor<T>`
abstract class IItemAccessor<T> {
  String? getItemLabel(T item);
  String? getItemDescription(T item);
  String? getItemPath(T item);
}

const int PATH_IDENTITY_SCORE = 1 << 18;
const int LABEL_PREFIX_SCORE_THRESHOLD = 1 << 17;
const int LABEL_SCORE_THRESHOLD = 1 << 16;

final ConstantStringHash ALLOW_NON_CONTIGUOUS_MATCHES_KEY_HASH = ConstantStringHash('allowNonContiguousMatches');
final ConstantStringHash DESCRIPTION_KEY_HASH = ConstantStringHash('description');
final ConstantStringHash LABEL_KEY_HASH = ConstantStringHash('label');
final ConstantStringHash VALUES_KEY_HASH = ConstantStringHash('values');
final ConstantStringHash EXPECT_CONTIGUOUS_MATCH_KEY_HASH = ConstantStringHash('expectContiguousMatch');
final ConstantStringHash VALUE_KEY_HASH = ConstantStringHash('value');

/// Reproduces the generic cache-key hash without constructing its nested object shape.
int _getCacheHash(String label, String? description, bool allowNonContiguousMatches, IPreparedQuery query) {
  int hashVal = numberHash(OBJECT_HASH_SEED, 0);
  hashVal = stringHash(query.normalized, hashVal);

  hashVal = numberHash(OBJECT_HASH_SEED, hashVal);

  hashVal = ALLOW_NON_CONTIGUOUS_MATCHES_KEY_HASH.apply(hashVal);
  hashVal = doHash(allowNonContiguousMatches, hashVal);

  hashVal = DESCRIPTION_KEY_HASH.apply(hashVal);
  hashVal = doHash(description, hashVal);

  hashVal = LABEL_KEY_HASH.apply(hashVal);
  hashVal = doHash(label, hashVal);

  hashVal = VALUES_KEY_HASH.apply(hashVal);
  hashVal = numberHash(ARRAY_HASH_SEED, hashVal);
  final List<IPreparedQueryPiece> values = query.values != null ? query.values! : <IPreparedQueryPiece>[query];
  for (final IPreparedQueryPiece value in values) {
    hashVal = numberHash(OBJECT_HASH_SEED, hashVal);
    hashVal = EXPECT_CONTIGUOUS_MATCH_KEY_HASH.apply(hashVal);
    hashVal = doHash(value.expectContiguousMatch, hashVal);
    hashVal = VALUE_KEY_HASH.apply(hashVal);
    hashVal = doHash(value.normalized, hashVal);
  }

  return hashVal;
}

/// 1:1: `export function scoreItemFuzzy`
IItemScore scoreItemFuzzy<T>(T item, IPreparedQuery query, bool allowNonContiguousMatches, IItemAccessor<T> accessor, FuzzyScorerCache cache) {
  // 1:1: `if (!item || !query.normalized)` — JS falsy item also covers null.
  if (item == null || query.normalized.isEmpty) {
    return NO_ITEM_SCORE;
  }

  final String? label = accessor.getItemLabel(item);
  if (label == null || label.isEmpty) {
    return NO_ITEM_SCORE;
  }

  final String? description = accessor.getItemDescription(item);

  final int cacheHash = _getCacheHash(label, description, allowNonContiguousMatches, query);
  final IItemScore? cached = cache[cacheHash];
  if (cached != null) {
    return cached;
  }

  final IItemScore itemScore = _doScoreItemFuzzy(label, description, accessor.getItemPath(item), query, allowNonContiguousMatches);
  cache[cacheHash] = itemScore;

  return itemScore;
}

IItemScore _doScoreItemFuzzy(String label, String? description, String? path, IPreparedQuery query, bool allowNonContiguousMatches) {
  final bool preferLabelMatches = path == null || path.isEmpty || !query.containsPathSeparator;

  if (path != null && path.isNotEmpty && (isLinux ? query.pathNormalized == path : equalsIgnoreCase(query.pathNormalized, path))) {
    return IItemScore(
      PATH_IDENTITY_SCORE,
      <IMatch>[IMatch(0, label.length)],
      description != null ? <IMatch>[IMatch(0, description.length)] : null,
    );
  }

  if (query.values != null && query.values!.length > 1) {
    return _doScoreItemFuzzyMultiple(label, description, path, query.values!, preferLabelMatches, allowNonContiguousMatches);
  }

  return _doScoreItemFuzzySingle(label, description, path, query, preferLabelMatches, allowNonContiguousMatches);
}

IItemScore _doScoreItemFuzzyMultiple(String label, String? description, String? path, List<IPreparedQueryPiece> query, bool preferLabelMatches, bool allowNonContiguousMatches) {
  int totalScore = 0;
  final List<IMatch> totalLabelMatches = <IMatch>[];
  final List<IMatch> totalDescriptionMatches = <IMatch>[];

  for (final IPreparedQueryPiece queryPiece in query) {
    final IItemScore pieceScore = _doScoreItemFuzzySingle(label, description, path, queryPiece, preferLabelMatches, allowNonContiguousMatches);
    if (pieceScore.score == NO_MATCH) {
      return NO_ITEM_SCORE;
    }
    totalScore += pieceScore.score;
    if (pieceScore.labelMatch != null) {
      totalLabelMatches.addAll(pieceScore.labelMatch!);
    }
    if (pieceScore.descriptionMatch != null) {
      totalDescriptionMatches.addAll(pieceScore.descriptionMatch!);
    }
  }

  return IItemScore(totalScore, _normalizeMatches(totalLabelMatches), _normalizeMatches(totalDescriptionMatches));
}

IItemScore _doScoreItemFuzzySingle(String label, String? description, String? path, IPreparedQueryPiece query, bool preferLabelMatches, bool allowNonContiguousMatches) {
  if (preferLabelMatches || description == null || description.isEmpty) {
    final FuzzyScore labelResult = scoreFuzzy(
      label,
      query.normalized,
      query.normalizedLowercase,
      allowNonContiguousMatches && !query.expectContiguousMatch,
    );
    if (labelResult.score != 0) {
      final List<IMatch>? prefixMatches = matchesPrefix(query.normalized, label);
      final int baseScore;
      if (prefixMatches != null) {
        baseScore = LABEL_PREFIX_SCORE_THRESHOLD;
        final int prefixLengthBoost = (query.normalized.length / label.length * 100).round();
        return IItemScore(baseScore + prefixLengthBoost + labelResult.score, prefixMatches);
      } else {
        baseScore = LABEL_SCORE_THRESHOLD;
      }
      return IItemScore(baseScore + labelResult.score, _createMatches(labelResult.positions));
    }
  }

  if (description != null && description.isNotEmpty) {
    String descriptionPrefix = description;
    if (path != null && path.isNotEmpty) {
      descriptionPrefix = '$description$sep';
    }

    final int descriptionPrefixLength = descriptionPrefix.length;
    final String descriptionAndLabel = '$descriptionPrefix$label';

    final FuzzyScore result = scoreFuzzy(
      descriptionAndLabel,
      query.normalized,
      query.normalizedLowercase,
      allowNonContiguousMatches && !query.expectContiguousMatch,
    );
    if (result.score != 0) {
      final List<IMatch> labelDescriptionMatches = _createMatches(result.positions);
      final List<IMatch> labelMatch = <IMatch>[];
      final List<IMatch> descriptionMatch = <IMatch>[];

      for (final IMatch h in labelDescriptionMatches) {
        if (h.start < descriptionPrefixLength && h.end > descriptionPrefixLength) {
          labelMatch.add(IMatch(0, h.end - descriptionPrefixLength));
          descriptionMatch.add(IMatch(h.start, descriptionPrefixLength));
        } else if (h.start >= descriptionPrefixLength) {
          labelMatch.add(IMatch(h.start - descriptionPrefixLength, h.end - descriptionPrefixLength));
        } else {
          descriptionMatch.add(IMatch(h.start, h.end));
        }
      }

      return IItemScore(result.score, labelMatch, descriptionMatch);
    }
  }

  return NO_ITEM_SCORE;
}

List<IMatch> _createMatches(List<int>? offsets) {
  final List<IMatch> ret = <IMatch>[];
  if (offsets == null) {
    return ret;
  }

  IMatch? last;
  for (final int pos in offsets) {
    if (last != null && last.end == pos) {
      last.end += 1;
    } else {
      last = IMatch(pos, pos + 1);
      ret.add(last);
    }
  }

  return ret;
}

List<IMatch> _normalizeMatches(List<IMatch> matches) {
  final List<IMatch> sortedMatches = List<IMatch>.from(matches)..sort((IMatch a, IMatch b) => a.start - b.start);

  final List<IMatch> normalizedMatches = <IMatch>[];
  IMatch? currentMatch;
  for (final IMatch match in sortedMatches) {
    if (currentMatch == null || !_matchOverlaps(currentMatch, match)) {
      currentMatch = match;
      normalizedMatches.add(match);
    } else {
      currentMatch.start = _min(currentMatch.start, match.start);
      currentMatch.end = _max(currentMatch.end, match.end);
    }
  }

  return normalizedMatches;
}

bool _matchOverlaps(IMatch matchA, IMatch matchB) {
  if (matchA.end < matchB.start) {
    return false;
  }
  if (matchB.end < matchA.start) {
    return false;
  }
  return true;
}

// #endregion

// #region Comparers

/// 1:1: `export function compareItemsByFuzzyScore`
int compareItemsByFuzzyScore<T>(T itemA, T itemB, IPreparedQuery query, bool allowNonContiguousMatches, IItemAccessor<T> accessor, FuzzyScorerCache cache) {
  final IItemScore itemScoreA = scoreItemFuzzy(itemA, query, allowNonContiguousMatches, accessor, cache);
  final IItemScore itemScoreB = scoreItemFuzzy(itemB, query, allowNonContiguousMatches, accessor, cache);

  final int scoreA = itemScoreA.score;
  final int scoreB = itemScoreB.score;

  if (scoreA == PATH_IDENTITY_SCORE || scoreB == PATH_IDENTITY_SCORE) {
    if (scoreA != scoreB) {
      return scoreA == PATH_IDENTITY_SCORE ? -1 : 1;
    }
  }

  if (scoreA > LABEL_SCORE_THRESHOLD || scoreB > LABEL_SCORE_THRESHOLD) {
    if (scoreA != scoreB) {
      return scoreA > scoreB ? -1 : 1;
    }

    if (scoreA < LABEL_PREFIX_SCORE_THRESHOLD && scoreB < LABEL_PREFIX_SCORE_THRESHOLD) {
      final int comparedByMatchLength = _compareByMatchLength(itemScoreA.labelMatch, itemScoreB.labelMatch);
      if (comparedByMatchLength != 0) {
        return comparedByMatchLength;
      }
    }

    final String labelA = accessor.getItemLabel(itemA) ?? '';
    final String labelB = accessor.getItemLabel(itemB) ?? '';
    if (labelA.length != labelB.length) {
      return labelA.length - labelB.length;
    }
  }

  if (scoreA != scoreB) {
    return scoreA > scoreB ? -1 : 1;
  }

  final bool itemAHasLabelMatches = itemScoreA.labelMatch != null && itemScoreA.labelMatch!.isNotEmpty;
  final bool itemBHasLabelMatches = itemScoreB.labelMatch != null && itemScoreB.labelMatch!.isNotEmpty;
  if (itemAHasLabelMatches && !itemBHasLabelMatches) {
    return -1;
  } else if (itemBHasLabelMatches && !itemAHasLabelMatches) {
    return 1;
  }

  final int itemAMatchDistance = _computeLabelAndDescriptionMatchDistance(itemA, itemScoreA, accessor);
  final int itemBMatchDistance = _computeLabelAndDescriptionMatchDistance(itemB, itemScoreB, accessor);
  if (itemAMatchDistance != 0 && itemBMatchDistance != 0 && itemAMatchDistance != itemBMatchDistance) {
    return itemBMatchDistance > itemAMatchDistance ? -1 : 1;
  }

  return _fallbackCompare(itemA, itemB, query, accessor);
}

int _computeLabelAndDescriptionMatchDistance<T>(T item, IItemScore score, IItemAccessor<T> accessor) {
  int matchStart = -1;
  int matchEnd = -1;

  if (score.descriptionMatch != null && score.descriptionMatch!.isNotEmpty) {
    matchStart = score.descriptionMatch![0].start;
  } else if (score.labelMatch != null && score.labelMatch!.isNotEmpty) {
    matchStart = score.labelMatch![0].start;
  }

  if (score.labelMatch != null && score.labelMatch!.isNotEmpty) {
    matchEnd = score.labelMatch![score.labelMatch!.length - 1].end;
    if (score.descriptionMatch != null && score.descriptionMatch!.isNotEmpty) {
      final String? itemDescription = accessor.getItemDescription(item);
      if (itemDescription != null) {
        matchEnd += itemDescription.length;
      }
    }
  } else if (score.descriptionMatch != null && score.descriptionMatch!.isNotEmpty) {
    matchEnd = score.descriptionMatch![score.descriptionMatch!.length - 1].end;
  }

  return matchEnd - matchStart;
}

int _compareByMatchLength(List<IMatch>? matchesA, List<IMatch>? matchesB) {
  if ((matchesA == null && matchesB == null) || ((matchesA == null || matchesA.isEmpty) && (matchesB == null || matchesB.isEmpty))) {
    return 0;
  }
  if (matchesB == null || matchesB.isEmpty) {
    return -1;
  }
  if (matchesA == null || matchesA.isEmpty) {
    return 1;
  }

  final int matchStartA = matchesA[0].start;
  final int matchEndA = matchesA[matchesA.length - 1].end;
  final int matchLengthA = matchEndA - matchStartA;

  final int matchStartB = matchesB[0].start;
  final int matchEndB = matchesB[matchesB.length - 1].end;
  final int matchLengthB = matchEndB - matchStartB;

  return matchLengthA == matchLengthB ? 0 : (matchLengthB < matchLengthA ? 1 : -1);
}

int _fallbackCompare<T>(T itemA, T itemB, IPreparedQuery query, IItemAccessor<T> accessor) {
  final String labelA = accessor.getItemLabel(itemA) ?? '';
  final String labelB = accessor.getItemLabel(itemB) ?? '';

  final String? descriptionA = accessor.getItemDescription(itemA);
  final String? descriptionB = accessor.getItemDescription(itemB);

  final int labelDescriptionALength = labelA.length + (descriptionA != null ? descriptionA.length : 0);
  final int labelDescriptionBLength = labelB.length + (descriptionB != null ? descriptionB.length : 0);

  if (labelDescriptionALength != labelDescriptionBLength) {
    return labelDescriptionALength - labelDescriptionBLength;
  }

  final String? pathA = accessor.getItemPath(itemA);
  final String? pathB = accessor.getItemPath(itemB);

  if (pathA != null && pathB != null && pathA.length != pathB.length) {
    return pathA.length - pathB.length;
  }

  if (labelA != labelB) {
    return compareAnything(labelA, labelB, query.normalized);
  }

  if (descriptionA != null && descriptionB != null && descriptionA != descriptionB) {
    return compareAnything(descriptionA, descriptionB, query.normalized);
  }

  if (pathA != null && pathB != null && pathA != pathB) {
    return compareAnything(pathA, pathB, query.normalized);
  }

  return 0;
}

// #endregion

// #region Query Normalizer

/// 1:1: `export interface IPreparedQueryPiece`
class IPreparedQueryPiece {
  String original;
  String originalLowercase;
  String pathNormalized;
  String normalized;
  String normalizedLowercase;
  bool expectContiguousMatch;

  IPreparedQueryPiece(this.original, this.originalLowercase, this.pathNormalized, this.normalized, this.normalizedLowercase, this.expectContiguousMatch);
}

/// 1:1: `export interface IPreparedQuery extends IPreparedQueryPiece`
class IPreparedQuery extends IPreparedQueryPiece {
  List<IPreparedQueryPiece>? values;
  bool containsPathSeparator;

  IPreparedQuery(
    String original,
    String originalLowercase,
    String pathNormalized,
    String normalized,
    String normalizedLowercase,
    bool expectContiguousMatch,
    this.values,
    this.containsPathSeparator,
  ) : super(original, originalLowercase, pathNormalized, normalized, normalizedLowercase, expectContiguousMatch);
}

bool _queryExpectsExactMatch(String query) => query.startsWith('"') && query.endsWith('"');

const String MULTIPLE_QUERY_VALUES_SEPARATOR = ' ';

/// 1:1: `export function prepareQuery`
IPreparedQuery prepareQuery(String original) {
  final String originalLowercase = original.toLowerCase();
  final _NormalizedQuery normalized = _normalizeQuery(original);
  final bool containsPathSeparator = normalized.pathNormalized.indexOf(sep) >= 0;
  final bool expectExactMatch = _queryExpectsExactMatch(original);

  List<IPreparedQueryPiece>? values;

  final List<String> originalSplit = original.split(MULTIPLE_QUERY_VALUES_SEPARATOR);
  if (originalSplit.length > 1) {
    for (final String originalPiece in originalSplit) {
      final bool expectExactMatchPiece = _queryExpectsExactMatch(originalPiece);
      final _NormalizedQuery piece = _normalizeQuery(originalPiece);

      if (piece.normalized.isNotEmpty) {
        values ??= <IPreparedQueryPiece>[];
        values.add(IPreparedQueryPiece(
          originalPiece,
          originalPiece.toLowerCase(),
          piece.pathNormalized,
          piece.normalized,
          piece.normalizedLowercase,
          expectExactMatchPiece,
        ));
      }
    }
  }

  return IPreparedQuery(
    original,
    originalLowercase,
    normalized.pathNormalized,
    normalized.normalized,
    normalized.normalizedLowercase,
    expectExactMatch,
    values,
    containsPathSeparator,
  );
}

class _NormalizedQuery {
  final String pathNormalized;
  final String normalized;
  final String normalizedLowercase;

  _NormalizedQuery(this.pathNormalized, this.normalized, this.normalizedLowercase);
}

_NormalizedQuery _normalizeQuery(String original) {
  late final String pathNormalized;
  if (isWindows) {
    pathNormalized = original.replaceAll('/', sep);
  } else {
    pathNormalized = original.replaceAll('\\', sep);
  }

  // remove: quotes, wildcards, whitespace, ellipsis, trailing hash
  // Dart RegExp has no lookbehind; `(?<=.)#$` == "ends with # and length > 1".
  String stripped = pathNormalized.replaceAll(RegExp(r'[\*\u2026\s"]'), '');
  if (stripped.length > 1 && stripped.endsWith('#')) {
    stripped = stripped.substring(0, stripped.length - 1);
  }
  final String normalized = stripped;

  return _NormalizedQuery(pathNormalized, normalized, normalized.toLowerCase());
}

/// 1:1: `export function pieceToQuery` (both overloads)
IPreparedQuery pieceToQuery(Object arg) {
  if (arg is List) {
    final List<String> originals = arg.map((Object? piece) => (piece as IPreparedQueryPiece).original).toList();
    return prepareQuery(originals.join(MULTIPLE_QUERY_VALUES_SEPARATOR));
  }
  return prepareQuery((arg as IPreparedQueryPiece).original);
}

// #endregion
