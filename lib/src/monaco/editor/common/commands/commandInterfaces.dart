// Runtime contracts for the erased TypeScript interfaces consumed by the
// editor command classes (`H.getEditOperations` / `H.computeCursorState`).
//
// In `editorCommon.ts` / `model.ts` these are pure `interface` declarations and
// are erased per this repo's established convention (see `editorCommon.dart`,
// `model.dart`). The command runtime classes below still need callable Dart
// shapes so their 1:1 ported method bodies compile and can be replay-tested
// against TypeScript truth. These abstract classes carry exactly the members
// the 4 ported commands read — no more — mirroring the precedent already set
// by `tokens/lineTokens.dart`'s `ITextModel` / `IViewLineTokens`.

import '../core/range.dart' show IRange;
import '../core/selection.dart' show Selection;

/// 1:1: `IEditOperationBuilder` (`editorCommon.ts`).
abstract class IEditOperationBuilder {
  void addEditOperation(IRange range, String? text, [bool? forceMoveMarkers]);

  void addTrackedEditOperation(IRange range, String? text, [bool? forceMoveMarkers]);

  String trackSelection(Selection selection, [bool? trackPreviousOnEmpty]);
}

/// 1:1: `ICursorStateComputerData` (`editorCommon.ts`).
abstract class ICursorStateComputerData {
  List<Object?> getInverseEditOperations();

  Selection getTrackedSelection(String id);
}

/// Minimal shape of the tokens object read by `trimTrailingWhitespace`.
/// 1:1 subset of `IViewLineTokens` (`tokens/lineTokens.dart`).
abstract class ILineTokensForCommand {
  int getStandardTokenType(int tokenIndex);

  int findTokenIndexAtOffset(int offset);
}

/// Minimal shape of `ITextModel['tokenization']` used by the trim command.
abstract class ITokenizationForCommand {
  bool hasAccurateTokensForLine(int lineNumber);

  ILineTokensForCommand getLineTokens(int lineNumber);
}

/// 1:1 subset of the erased `ITextModel` (`model.ts`) consumed by the 4
/// commands in this batch: line access, range reading and tokenization.
abstract class ITextModelForCommand {
  int getLineCount();

  String getLineContent(int lineNumber);

  int getLineMaxColumn(int lineNumber);

  String getValueInRange(IRange range);

  ITokenizationForCommand get tokenization;
}

/// 1:1: `ICommand` (`editorCommon.ts`).
abstract class ICommand {
  // `readonly insertsAutoWhitespace?: boolean` is optional in TS and unused by
  // the 4 commands ported here; only the members they implement are carried.
  void getEditOperations(ITextModelForCommand model, IEditOperationBuilder builder);

  Selection computeCursorState(ITextModelForCommand model, ICursorStateComputerData helper);
}
