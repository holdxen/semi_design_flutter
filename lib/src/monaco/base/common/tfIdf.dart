// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/tfIdf.ts
// Translated 1:1 from TypeScript.
//
// Platform adaptations:
//   - SparseEmbedding (Record<string,number>) -> Map<String, num>
//   - `Object.entries(map)` -> map.entries (insertion order preserved)
//   - `Object.create(null)` -> LinkedHashMap
//   - `input.matchAll(/\b\p{Letter}.../gu)` -> RegExp.allMatches (unicode: true)
//   - `word.replace(/([a-z])([A-Z])/g, '$1 $2')` -> replaceAllMapped
//   - `Math.log` -> dart:math log
// ---------------------------------------------------------------------------

import 'dart:collection';
import 'dart:math' as math;

import 'cancellation.dart' as cancellation;

/// 1:1: `type SparseEmbedding = Record<word, weight>`
typedef SparseEmbedding = Map<String, num>;
/// 1:1: `type TermFrequencies = Map<word, occurrences>`
typedef TermFrequencies = Map<String, int>;
/// 1:1: `type DocumentOccurrences = Map<word, documentOccurrences>`
typedef DocumentOccurrences = Map<String, int>;

/// 1:1: `countMapFrom<K>(values)`
Map<K, int> countMapFrom<K>(Iterable<K> values) {
  final Map<K, int> map = <K, int>{};
  for (final K value in values) {
    map[value] = (map[value] ?? 0) + 1;
  }
  return map;
}

/// 1:1: `interface DocumentChunkEntry`
class DocumentChunkEntry {
  final String text;
  final TermFrequencies tf;
  DocumentChunkEntry({required this.text, required this.tf});
}

/// 1:1: `export interface TfIdfDocument`
class TfIdfDocument {
  final String key;
  final List<String> textChunks;
  TfIdfDocument({required this.key, required this.textChunks});
}

/// 1:1: `export interface TfIdfScore`
class TfIdfScore {
  final String key;
  final num score;
  TfIdfScore({required this.key, required this.score});
}

/// 1:1: `export interface NormalizedTfIdfScore`
class NormalizedTfIdfScore {
  final String key;
  final num score;
  NormalizedTfIdfScore({required this.key, required this.score});
}

/// 1:1: `export class TfIdfCalculator`
class TfIdfCalculator {
  /// 1:1: `calculateScores(query, token)`
  List<TfIdfScore> calculateScores(String query, cancellation.CancellationToken token) {
    final SparseEmbedding embedding = computeEmbedding(query);
    final Map<String, num> idfCache = <String, num>{};
    final List<TfIdfScore> scores = <TfIdfScore>[];
    for (final MapEntry<String, _DocumentEntry> entry in documents.entries) {
      if (token.isCancellationRequested) {
        return <TfIdfScore>[];
      }
      final String key = entry.key;
      final _DocumentEntry doc = entry.value;
      for (final DocumentChunkEntry chunk in doc.chunks) {
        final num score = computeSimilarityScore(chunk, embedding, idfCache);
        if (score > 0) {
          scores.add(TfIdfScore(key: key, score: score));
        }
      }
    }
    return scores;
  }

  /// 1:1: `termFrequencies(input)`
  static TermFrequencies termFrequencies(String input) =>
      countMapFrom<String>(splitTerms(input));

  /// 1:1: `splitTerms(input)` generator
  static Iterable<String> splitTerms(String input) sync* {
    String normalize(String word) => word.toLowerCase();

    // Only match on words that are at least 3 characters long and start with a letter
    final RegExp wordRe = RegExp(r'\b\p{Letter}[\p{Letter}\d]{2,}\b', unicode: true);
    for (final RegExpMatch match in wordRe.allMatches(input)) {
      final String word = match.group(0)!;
      yield normalize(word);

      final String spaced = word.replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'), (Match m) => '${m.group(1)} ${m.group(2)}');
      final List<String> camelParts = spaced.split(RegExp(r'\s+'));
      if (camelParts.length > 1) {
        for (final String part in camelParts) {
          if (part.length > 2 && RegExp(r'\p{Letter}{3,}', unicode: true).hasMatch(part)) {
            yield normalize(part);
          }
        }
      }
    }
  }

  int chunkCount = 0;
  final DocumentOccurrences chunkOccurrences = <String, int>{};
  final Map<String, _DocumentEntry> documents = <String, _DocumentEntry>{};

  /// 1:1: `updateDocuments(documents)`
  TfIdfCalculator updateDocuments(List<TfIdfDocument> documents) {
    for (final TfIdfDocument doc in documents) {
      deleteDocument(doc.key);
    }
    for (final TfIdfDocument doc in documents) {
      final List<DocumentChunkEntry> chunks = <DocumentChunkEntry>[];
      for (final String text in doc.textChunks) {
        final TermFrequencies tf = TfIdfCalculator.termFrequencies(text);
        for (final String term in tf.keys) {
          chunkOccurrences[term] = (chunkOccurrences[term] ?? 0) + 1;
        }
        chunks.add(DocumentChunkEntry(text: text, tf: tf));
      }
      chunkCount += chunks.length;
      this.documents[doc.key] = _DocumentEntry(chunks);
    }
    return this;
  }

  /// 1:1: `deleteDocument(key)`
  void deleteDocument(String key) {
    final _DocumentEntry? doc = documents[key];
    if (doc == null) {
      return;
    }
    documents.remove(key);
    chunkCount -= doc.chunks.length;
    for (final DocumentChunkEntry chunk in doc.chunks) {
      for (final String term in chunk.tf.keys) {
        final int? currentOccurrences = chunkOccurrences[term];
        if (currentOccurrences != null) {
          final int newOccurrences = currentOccurrences - 1;
          if (newOccurrences <= 0) {
            chunkOccurrences.remove(term);
          } else {
            chunkOccurrences[term] = newOccurrences;
          }
        }
      }
    }
  }

  /// 1:1: `computeSimilarityScore(chunk, queryEmbedding, idfCache)`
  num computeSimilarityScore(
    DocumentChunkEntry chunk,
    SparseEmbedding queryEmbedding,
    Map<String, num> idfCache,
  ) {
    num sum = 0;
    for (final MapEntry<String, num> entry in queryEmbedding.entries) {
      final String term = entry.key;
      final num termTfidf = entry.value;
      final int? chunkTf = chunk.tf[term];
      if (chunkTf == null) {
        continue;
      }
      num? chunkIdf = idfCache[term];
      if (chunkIdf == null) {
        chunkIdf = computeIdf(term);
        idfCache[term] = chunkIdf;
      }
      final num chunkTfidf = chunkTf * chunkIdf;
      sum += chunkTfidf * termTfidf;
    }
    return sum;
  }

  /// 1:1: `computeEmbedding(input)`
  SparseEmbedding computeEmbedding(String input) => computeTfidf(termFrequencies(input));

  /// 1:1: `computeIdf(term)`
  num computeIdf(String term) {
    final int chunkOccurrences = this.chunkOccurrences[term] ?? 0;
    return chunkOccurrences > 0
        ? math.log((chunkCount + 1) / chunkOccurrences)
        : 0;
  }

  /// 1:1: `computeTfidf(termFrequencies)`
  SparseEmbedding computeTfidf(TermFrequencies termFrequencies) {
    final SparseEmbedding embedding = LinkedHashMap<String, num>();
    for (final MapEntry<String, int> entry in termFrequencies.entries) {
      final String word = entry.key;
      final int occurrences = entry.value;
      final num idf = computeIdf(word);
      if (idf > 0) {
        embedding[word] = occurrences * idf;
      }
    }
    return embedding;
  }
}

class _DocumentEntry {
  final List<DocumentChunkEntry> chunks;
  _DocumentEntry(this.chunks);
}

/// 1:1: `export function normalizeTfIdfScores(scores)`
List<NormalizedTfIdfScore> normalizeTfIdfScores(List<TfIdfScore> scores) {
  final List<TfIdfScore> result = List<TfIdfScore>.from(scores);
  result.sort((TfIdfScore a, TfIdfScore b) => b.score.compareTo(a.score));
  final num max = result.isEmpty ? 0 : result.first.score;
  // Source mutates score.score in place; here scores are immutable carriers,
  // so the normalization is applied when building the result below.
  return result
      .map((TfIdfScore s) => NormalizedTfIdfScore(
          key: s.key, score: max > 0 ? s.score / max : s.score))
      .toList();
}
