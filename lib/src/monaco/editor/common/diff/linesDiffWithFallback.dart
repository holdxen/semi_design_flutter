// 1:1 port of vscode/src/vs/editor/common/diff/linesDiffWithFallback.ts
// Adaptations:
//   - `DiffAlgorithmName` (string literal union) -> `typedef ... = String`.
//   - `ILinesDiffComputer | Promise<...>` -> `FutureOr<...>`.
// Runtime truth: tool/ts2dart/_batch338_truth.cjs.

import 'dart:async' show FutureOr;

import '../../../base/common/errors.dart' show onUnexpectedError;
import 'documentDiffProvider.dart' show DiffFallbackReason;
import 'linesDiffComputer.dart' show ILinesDiffComputer, ILinesDiffComputerOptions, LinesDiff;
import 'linesDiffComputers.dart' show linesDiffComputers;
import 'verifyLinesDiff.dart' show LinesDiffValidity, verifyLinesDiff;

/// 1:1: `DiffAlgorithmName` (erased string union).
typedef DiffAlgorithmName = String;

/// 1:1: `export interface ILinesDiffWithFallback`.
class ILinesDiffWithFallback {
  final LinesDiff result;
  final String? validity;
  final DiffFallbackReason? fallback;

  ILinesDiffWithFallback({
    required this.result,
    required this.validity,
    required this.fallback,
  });
}

/// 1:1: `export type LinesDiffWithFallbackComputer`.
typedef LinesDiffWithFallbackComputer = ILinesDiffWithFallback Function(
  List<String> originalLines,
  List<String> modifiedLines,
  ILinesDiffComputerOptions options,
  bool verify,
);

/// 1:1: `export async function resolveLinesDiffComputerWithFallback`.
Future<LinesDiffWithFallbackComputer> resolveLinesDiffComputerWithFallback(
  DiffAlgorithmName algorithm,
  FutureOr<ILinesDiffComputer> Function(DiffAlgorithmName algorithm) resolve,
) async {
  final bool isPackage =
      algorithm == 'advanced-external' || algorithm == 'advanced-wasm';
  ILinesDiffComputer? computer;
  try {
    computer = await resolve(algorithm);
  } catch (e) {
    if (!isPackage) {
      rethrow;
    }
    onUnexpectedError(e);
  }

  return (
    List<String> originalLines,
    List<String> modifiedLines,
    ILinesDiffComputerOptions options,
    bool verify,
  ) {
    String? verifyDiff(LinesDiff diff) => verify
        ? verifyLinesDiff(
            diff, originalLines, modifiedLines, options.ignoreTrimWhitespace)
        : null;

    ILinesDiffWithFallback computeBuiltin(DiffFallbackReason fallback) {
      final LinesDiff result = linesDiffComputers
          .getDefault()
          .computeDiff(originalLines, modifiedLines, options);
      return ILinesDiffWithFallback(
        result: result,
        validity: verifyDiff(result),
        fallback: fallback,
      );
    }

    if (computer == null) {
      return computeBuiltin('error');
    }

    late final LinesDiff result;
    try {
      result = computer.computeDiff(originalLines, modifiedLines, options);
    } catch (e) {
      if (!isPackage) {
        rethrow;
      }
      onUnexpectedError(e);
      return computeBuiltin('error');
    }

    final String? validity = verifyDiff(result);
    if (isPackage && validity == LinesDiffValidity.invalid) {
      return computeBuiltin('invalid');
    }
    return ILinesDiffWithFallback(
      result: result,
      validity: validity,
      fallback: null,
    );
  };
}
