// 1:1 port of vs/editor/common/diff/documentDiffProvider.ts
// Declaration-only module plus the exported frozen `nullDocumentDiff`.
// Adaptations (same pattern as markerDecorations.dart):
//   - interfaces become phantom/type carriers; `DiffFallbackReason` string
//     literal union is erased to `typedef ... = String`.
//   - `ITextModel` (from ../model.ts, pending) is an opaque local carrier.
//   - TS `Object.freeze` is represented by const getters + const empty lists.
// Runtime truth: tool/ts2dart/_batch262_truth.cjs (recursive TS transpile+vm).

import '../../../base/common/cancellation.dart' show CancellationToken;
import '../../../base/common/event.dart' show Event;
import './linesDiffComputer.dart' show MovedText;
import './rangeMapping.dart' show DetailedLineRangeMapping;
import './verifyLinesDiff.dart' show LinesDiffValidity;

/// 1:1: `DiffFallbackReason = 'error' | 'invalid'` (erased string union)
typedef DiffFallbackReason = String;

/// 1:1: `ITextModel` (from `../model.ts`, pending) — opaque carrier.
abstract class ITextModelForDocumentDiff {}

/// 1:1: `IDocumentDiffProvider`
abstract class IDocumentDiffProvider {
  /// Computes the diff between the text models `original` and `modified`.
  Future<IDocumentDiff> computeDiff(
    ITextModelForDocumentDiff original,
    ITextModelForDocumentDiff modified,
    IDocumentDiffProviderOptions options,
    CancellationToken cancellationToken,
  );

  /// Fired when settings of the diff algorithm change.
  Event<void> get onDidChange;
}

/// 1:1: `IDocumentDiffProviderOptions`
class IDocumentDiffProviderOptions {
  bool ignoreTrimWhitespace;
  int maxComputationTimeMs;
  bool computeMoves;
  bool? extendToSubwords;

  IDocumentDiffProviderOptions({
    required this.ignoreTrimWhitespace,
    required this.maxComputationTimeMs,
    required this.computeMoves,
    this.extendToSubwords,
  });
}

/// 1:1: `IDocumentDiff`
abstract class IDocumentDiff {
  bool get identical;
  bool get quitEarly;
  List<DetailedLineRangeMapping> get changes;
  List<MovedText> get moves;
  LinesDiffValidity? get validity;
  DiffFallbackReason? get fallback;
}

/// 1:1: `Object.freeze({ identical: true, quitEarly: false, changes: Object.freeze([]), moves: Object.freeze([]) })`
class _NullDocumentDiff implements IDocumentDiff {
  const _NullDocumentDiff();

  @override
  bool get identical => true;

  @override
  bool get quitEarly => false;

  @override
  List<DetailedLineRangeMapping> get changes =>
      const <DetailedLineRangeMapping>[];

  @override
  List<MovedText> get moves => const <MovedText>[];

  @override
  LinesDiffValidity? get validity => null;

  @override
  DiffFallbackReason? get fallback => null;
}

/// 1:1: `export const nullDocumentDiff: IDocumentDiff = Object.freeze({...})`
final IDocumentDiff nullDocumentDiff = _NullDocumentDiff();
