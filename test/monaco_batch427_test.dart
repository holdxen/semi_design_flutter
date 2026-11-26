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
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/core/selection.dart' show Selection;
import '../lib/src/monaco/editor/contrib/find/browser/replaceAllCommand.dart'
    show ReplaceAllCommand;

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root =
      jsonDecode(File('tool/ts2dart/batch427_truth.json').readAsStringSync())
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
  return <Object?>[
    x.startLineNumber,
    x.startColumn,
    x.endLineNumber,
    x.endColumn,
  ];
}

class _Builder implements IEditOperationBuilder {
  final List<Map<String, Object?>> ops = <Map<String, Object?>>[];
  Selection? tracked;

  @override
  void addEditOperation(Object range, String? text, [bool? forceMoveMarkers]) {
    ops.add(<String, Object?>{'range': _rangeJson(range), 'text': text});
  }

  @override
  void addTrackedEditOperation(Object range, String? text, [bool? forceMoveMarkers]) =>
      addEditOperation(range, text, forceMoveMarkers);

  @override
  String trackSelection(Selection selection, [bool? trackPreviousOnEmpty]) {
    tracked = selection;
    return 'sel-id';
  }
}

class _Helper implements ICursorStateComputerData {
  final Selection tracked;
  _Helper(this.tracked);
  @override
  List<Object?> getInverseEditOperations() => <Object?>[];
  @override
  Selection getTrackedSelection(String id) => tracked;
}

class _Model implements ITextModelForCommand {
  @override
  int getLineCount() => 10;
  @override
  String getLineContent(int lineNumber) => '';
  @override
  int getLineMaxColumn(int lineNumber) => 1;
  @override
  String getEOL() => '\n';
  @override
  String getValueInRange(Object range) => '';
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

void main() {
  final Map<String, dynamic> truth = _truth();
  final _Model model = _Model();

  test('replace all command truth replay', () {
    final Map<String, Object?> actual = <String, Object?>{};

    void run(
      String label,
      Selection editorSel,
      List<Range> ranges,
      List<String> texts,
    ) {
      final ReplaceAllCommand cmd =
          ReplaceAllCommand(editorSel, ranges, texts);
      final _Builder b = _Builder();
      cmd.getEditOperations(model, b);
      final Selection cursor = cmd.computeCursorState(model, _Helper(b.tracked!));
      actual[label] = <String, Object?>{
        'ops': b.ops,
        'cursor': _rangeJson(cursor),
      };
    }

    run('empty', Selection(1, 1, 1, 1), <Range>[], <String>[]);
    run('single', Selection(2, 3, 2, 8), <Range>[Range(2, 3, 2, 8)], <String>['X']);
    run('adjacent', Selection(1, 1, 1, 9),
        <Range>[Range(1, 1, 1, 4), Range(1, 4, 1, 9)], <String>['abc', 'def']);
    run('sort-merge', Selection(1, 1, 3, 5),
        <Range>[Range(3, 2, 3, 5), Range(1, 1, 1, 4), Range(1, 4, 1, 8)],
        <String>['c', 'a', 'b']);
    run('separate', Selection(1, 1, 2, 5),
        <Range>[Range(1, 1, 1, 4), Range(2, 2, 2, 5)], <String>['a', 'b']);
    run('cross-line', Selection(1, 1, 2, 3),
        <Range>[Range(1, 1, 2, 1), Range(2, 1, 2, 3)], <String>['x', 'y']);

    expect(jsonEncode(actual), jsonEncode(truth));
  });
}
