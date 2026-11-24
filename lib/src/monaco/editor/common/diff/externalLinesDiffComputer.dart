// 1:1 port of vscode/src/vs/editor/common/diff/externalLinesDiffComputer.ts
// 严格 1:1 翻译；`@vscode/diff` 通过 ExternalDiffModule seam 注入。

import '../core/ranges/lineRange.dart' show LineRange;
import '../core/ranges/offsetRange.dart' show OffsetRange;
import '../core/text/abstractText.dart' show StringText;
import '../core/text/positionToOffset.dart' show ensureDependenciesAreSet;
import '../core/text/positionToOffsetImpl.dart'
    show PositionOffsetTransformerBase;
import 'linesDiffComputer.dart'
    show
      ILinesDiffComputer,
      ILinesDiffComputerOptions,
      LinesDiff,
      MovedText;
import 'rangeMapping.dart'
    show
      DetailedLineRangeMapping,
      LineRangeMapping,
      RangeMapping,
      lineRangeMappingFromRangeMappings;

/// 1:1: structural mirror of `@vscode/diff`'s `IExternalDiffComputer`.
abstract class IExternalDiffComputer {
  ExternalDiffResult computeDiff(String original, String modified,
      ExternalDiffComputeOptions options);
}

class ExternalDiffUseWasm {
  final bool value;

  const ExternalDiffUseWasm(this.value);
}

class ExternalDiffComputeOptions {
  final int maxComputationTimeMs;
  final bool computeMoves;
  final bool? extendToSubwords;

  const ExternalDiffComputeOptions({
    required this.maxComputationTimeMs,
    required this.computeMoves,
    this.extendToSubwords,
  });
}

class ExternalOffsetRange {
  final int start;
  final int endExclusive;

  const ExternalOffsetRange(this.start, this.endExclusive);
}

class ExternalReplacementData {
  final bool isTrimWhitespaceChange;

  const ExternalReplacementData(this.isTrimWhitespaceChange);
}

class ExternalReplacement {
  final ExternalOffsetRange range;
  final String newText;
  final ExternalReplacementData data;

  const ExternalReplacement(this.range, this.newText, this.data);
}

class ExternalEditResult {
  final List<ExternalReplacement> replacements;

  const ExternalEditResult(this.replacements);
}

class ExternalMoveRange {
  final ExternalOffsetRange original;
  final ExternalOffsetRange modified;

  const ExternalMoveRange(this.original, this.modified);
}

class ExternalInnerEdit {
  final List<ExternalReplacement> replacements;

  const ExternalInnerEdit(this.replacements);
}

class ExternalMove {
  final ExternalMoveRange range;
  final ExternalInnerEdit innerEdit;

  const ExternalMove(this.range, this.innerEdit);
}

class ExternalDiffResult {
  final ExternalEditResult edits;
  final List<ExternalMove> moves;
  final bool hitTimeout;

  const ExternalDiffResult(this.edits, this.moves, this.hitTimeout);
}

/// 1:1: `type ExternalDiffModule = { createDiffComputer: ... }`
abstract class ExternalDiffModule {
  Future<IExternalDiffComputer> createDiffComputer({
    required bool useWasm,
  });
}

/// Mirrors `import(...)` of the AMD node module path. Tests replace this seam
/// instead of shipping the JS `@vscode/diff` package inside Flutter.
Future<ExternalDiffModule> Function() externalDiffModuleProvider =
    _missingExternalDiffModule;

Future<ExternalDiffModule> _missingExternalDiffModule() {
  throw StateError('externalDiffModuleProvider has not been configured');
}

Future<ExternalDiffModule>? _externalModulePromise;
final Map<bool, Future<ILinesDiffComputer>> _externalComputers =
    <bool, Future<ILinesDiffComputer>>{};

/// 1:1: `function loadExternalModule`
Future<ExternalDiffModule> _loadExternalModule() {
  final Future<ExternalDiffModule>? existing = _externalModulePromise;
  if (existing != null) {
    return existing;
  }
  final Future<ExternalDiffModule> created = externalDiffModuleProvider();
  _externalModulePromise = created;
  return created;
}

/// 1:1: `export function getExternalLinesDiffComputer`
Future<ILinesDiffComputer> getExternalLinesDiffComputer(bool useWasm) {
  final Future<ILinesDiffComputer>? existing = _externalComputers[useWasm];
  if (existing != null) {
    return existing;
  }
  final Future<ILinesDiffComputer> created = _loadExternalModule()
      .then((ExternalDiffModule m) => createExternalLinesDiffComputer(m, useWasm));
  _externalComputers[useWasm] = created;
  return created;
}

/// 1:1: `export async function createExternalLinesDiffComputer`
Future<ILinesDiffComputer> createExternalLinesDiffComputer(
  ExternalDiffModule externalModule,
  bool useWasm,
) async {
  final IExternalDiffComputer computer = await externalModule.createDiffComputer(
      useWasm: useWasm);
  return ExternalLinesDiffComputer(computer);
}

/// 1:1: `class ExternalLinesDiffComputer implements ILinesDiffComputer`
class ExternalLinesDiffComputer implements ILinesDiffComputer {
  ExternalLinesDiffComputer(this._computer);

  final IExternalDiffComputer _computer;

  @override
  LinesDiff computeDiff(
    List<String> originalLines,
    List<String> modifiedLines,
    ILinesDiffComputerOptions options,
  ) {
    ensureDependenciesAreSet();

    final StringText originalText = StringText(originalLines.join('\n'));
    final StringText modifiedText = StringText(modifiedLines.join('\n'));

    // The edit always contains whitespace changes, so it reproduces the modified text.
    // Ignoring trim whitespace only hides the replacements annotated as such.
    final ExternalDiffResult result = _computer.computeDiff(
      originalText.value,
      modifiedText.value,
      ExternalDiffComputeOptions(
        maxComputationTimeMs: options.maxComputationTimeMs,
        computeMoves: options.computeMoves,
        extendToSubwords: options.extendToSubwords,
      ),
    );

    final PositionOffsetTransformerBase originalTransformer =
        originalText.getTransformer();
    final PositionOffsetTransformerBase modifiedTransformer =
        modifiedText.getTransformer();

    final List<RangeMapping> rangeMappings = <RangeMapping>[];
    int delta = 0;
    for (final ExternalReplacement r in result.edits.replacements) {
      final OffsetRange originalRange =
          OffsetRange(r.range.start, r.range.endExclusive);
      final OffsetRange modifiedRange = OffsetRange(
        r.range.start + delta,
        r.range.start + delta + r.newText.length,
      );
      delta += r.newText.length - originalRange.length;

      if (options.ignoreTrimWhitespace && r.data.isTrimWhitespaceChange) {
        continue;
      }
      rangeMappings.add(RangeMapping(
        originalTransformer.getRange(originalRange),
        modifiedTransformer.getRange(modifiedRange),
      ));
    }

    final List<DetailedLineRangeMapping> changes =
        lineRangeMappingFromRangeMappings(
            rangeMappings, originalText, modifiedText);

    final List<MovedText> moves = <MovedText>[];
    if (options.computeMoves) {
      for (final ExternalMove move in result.moves) {
        final ExternalOffsetRange original = move.range.original;
        final ExternalOffsetRange modified = move.range.modified;

        // The inner edit is relative to the moved text.
        final List<RangeMapping> innerMappings = <RangeMapping>[];
        int innerDelta = 0;
        for (final ExternalReplacement r in move.innerEdit.replacements) {
          final OffsetRange innerOriginal = OffsetRange(
            original.start + r.range.start,
            original.start + r.range.endExclusive,
          );
          final OffsetRange innerModified = OffsetRange(
            modified.start + r.range.start + innerDelta,
            modified.start + r.range.start + innerDelta + r.newText.length,
          );
          innerDelta += r.newText.length - innerOriginal.length;
          innerMappings.add(RangeMapping(
            originalTransformer.getRange(innerOriginal),
            modifiedTransformer.getRange(innerModified),
          ));
        }

        moves.add(MovedText(
          LineRangeMapping(
            _toLineRange(originalTransformer, original),
            _toLineRange(modifiedTransformer, modified),
          ),
          lineRangeMappingFromRangeMappings(
              innerMappings, originalText, modifiedText, true),
        ));
      }
    }

    return LinesDiff(changes, moves, result.hitTimeout);
  }
}

/// 1:1: `function toLineRange`
LineRange _toLineRange(
  PositionOffsetTransformerBase transformer,
  ExternalOffsetRange range,
) {
  final start = transformer.getPosition(range.start);
  final end = transformer.getPosition(range.endExclusive);
  return LineRange(
    start.lineNumber,
    end.column == 1 ? end.lineNumber : end.lineNumber + 1,
  );
}
