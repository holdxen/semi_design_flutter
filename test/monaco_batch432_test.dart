import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/commands/commandInterfaces.dart'
    show
        ICursorStateComputerData,
        IEditOperationBuilder,
        ILineTokensForCommand,
        ITokenizationForCommand,
        ITextModelForCommand;
import '../lib/src/monaco/editor/common/core/position.dart' show Position;
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/core/selection.dart' show Selection;
import '../lib/src/monaco/editor/contrib/dnd/browser/dragAndDropCommand.dart'
    show DragAndDropCommand;

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root =
      jsonDecode(File('tool/ts2dart/batch432_truth.json').readAsStringSync())
          as Map<String, dynamic>;
  return <String, dynamic>{
    for (final dynamic r in root['results'] as List<dynamic>)
      (r as Map)['label'] as String: <String, dynamic>{
        for (final MapEntry<Object?, Object?> e
            in (r as Map).cast<Object?, Object?>().entries)
          if (e.key != 'label') e.key as String: e.value,
      },
  };
}

List<Object?> _rangeJson(Object r) {
  final dynamic x = r;
  return <Object?>[x.startLineNumber, x.startColumn, x.endLineNumber, x.endColumn];
}

class _Model implements ITextModelForCommand {
  @override
  int getLineCount() => 10;
  @override
  String getLineContent(int lineNumber) => 'line';
  @override
  int getLineMaxColumn(int lineNumber) => 5;
  @override
  String getEOL() => '\n';
  @override
  String getValueInRange(Object range) => 'TEXT';
  @override
  ITokenizationForCommand get tokenization => _Tokenization();
}

class _Tokenization implements ITokenizationForCommand {
  @override
  bool hasAccurateTokensForLine(int lineNumber) => false;
  @override
  ILineTokensForCommand getLineTokens(int lineNumber) => _LineTokens();
}

class _LineTokens implements ILineTokensForCommand {
  @override
  int getStandardTokenType(int tokenIndex) => 0;
  @override
  int findTokenIndexAtOffset(int offset) => 0;
}

class _Builder implements IEditOperationBuilder {
  final List<Map<String, Object?>> ops = <Map<String, Object?>>[];
  @override
  void addEditOperation(Object range, String? text, [bool? force]) {
    ops.add(<String, Object?>{'range': _rangeJson(range), 'text': text});
  }

  @override
  void addTrackedEditOperation(Object range, String? text, [bool? force]) =>
      addEditOperation(range, text, force);

  @override
  String trackSelection(Selection selection, [bool? trackPreviousOnEmpty]) => 'id';
}

class _Helper implements ICursorStateComputerData {
  @override
  List<Object?> getInverseEditOperations() => <Object?>[];
  @override
  Selection getTrackedSelection(String id) => Selection(1, 1, 1, 1);
}

void main() {
  final Map<String, dynamic> truth = _truth();
  final _Model model = _Model();

  test('drag and drop command truth replay', () {
    final Map<String, Object?> actual = <String, Object?>{};

    void run(
      String label,
      Selection selection,
      Position target,
      bool copy,
    ) {
      final DragAndDropCommand cmd =
          DragAndDropCommand(selection, target, copy);
      final _Builder b = _Builder();
      cmd.getEditOperations(model, b);
      final Selection cursor = cmd.computeCursorState(model, _Helper());
      actual[label] = <String, Object?>{
        'ops': b.ops,
        'targetSelection': _rangeJson(cursor),
      };
    }

    run('move-down', Selection(2, 3, 2, 8), Position(5, 1), false);
    run('move-up', Selection(5, 3, 5, 8), Position(2, 1), false);
    run('move-same-after', Selection(2, 3, 2, 8), Position(2, 12), false);
    run('move-same-before', Selection(2, 5, 2, 8), Position(2, 2), false);
    run('copy-down', Selection(2, 3, 2, 8), Position(5, 1), true);
    run('copy-beside', Selection(2, 3, 2, 8), Position(2, 8), true);
    run('move-inside', Selection(2, 3, 4, 8), Position(3, 5), false);
    run('copy-multiline', Selection(2, 3, 4, 8), Position(7, 2), true);

    expect(jsonEncode(actual), jsonEncode(truth));
  });
}
