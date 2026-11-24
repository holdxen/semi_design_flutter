// 1:1 port of vscode/src/vs/editor/common/viewModel/screenReaderSimpleModel.ts
//
// A single interface over the subset of the text model the paged screen reader
// strategy needs.
//
// Adaptation: TS imports `EndOfLinePreference` from `editor/common/model.ts`;
// the Dart port keeps the enum in `standalone/standaloneEnums.dart` (the same
// place the rest of the port imports standalone enums from).
import '../../common/standalone/standaloneEnums.dart'
    show EndOfLinePreference;
import '../core/position.dart' show Position;
import '../core/range.dart' show Range;

/// 1:1: `export interface ISimpleModel`.
abstract class ISimpleModel {
  String getLineContent(int lineNumber);
  int getLineCount();
  int getLineMaxColumn(int lineNumber);
  String getValueInRange(Range range, int eol);
  int getValueLengthInRange(Range range, int eol);
  Position modifyPosition(Position position, int offset);
}

/// Exposes the `EndOfLinePreference` constants used by [ISimpleModel] callers.
typedef SimpleModelEndOfLinePreference = EndOfLinePreference;
