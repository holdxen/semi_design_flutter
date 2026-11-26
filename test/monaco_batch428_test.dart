import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/commands/commandInterfaces.dart'
    show
        ICommand,
        ICursorStateComputerData,
        IEditOperationBuilder,
        ILineTokensForCommand,
        ITokenizationForCommand,
        ITextModelForCommand;
import '../lib/src/monaco/editor/common/commands/replaceCommand.dart'
    show
        ReplaceCommand,
        ReplaceCommandThatPreservesSelection,
        ReplaceCommandThatSelectsText,
        ReplaceCommandWithOffsetCursorState,
        ReplaceCommandWithoutChangingPosition,
        ReplaceOvertypeCommand,
        ReplaceOvertypeCommandOnCompositionEnd;
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/core/selection.dart' show Selection;

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root =
      jsonDecode(File('tool/ts2dart/batch428_truth.json').readAsStringSync())
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

class _Model implements ITextModelForCommand {
  final List<String> lines;
  _Model(this.lines);
  @override
  int getLineCount() => lines.length;
  @override
  String getLineContent(int lineNumber) => lines[lineNumber - 1];
  @override
  int getLineMaxColumn(int lineNumber) =>
      (lineNumber >= 1 && lineNumber <= lines.length)
          ? lines[lineNumber - 1].length + 1
          : 1;
  @override
  String getEOL() => '\n';
  @override
  String getValueInRange(Object range) {
    final dynamic r = range;
    if (r.startLineNumber == r.endLineNumber) {
      return lines[r.startLineNumber - 1].substring(
        r.startColumn - 1,
        r.endColumn - 1,
      );
    }
    return '';
  }

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
  final List<List<Object?>> tracked = <List<Object?>>[];

  @override
  void addTrackedEditOperation(Object range, String? text, [bool? force]) {
    ops.add(<String, Object?>{
      'range': _rangeJson(range),
      'text': text,
      'force': force,
    });
  }

  @override
  void addEditOperation(Object range, String? text, [bool? force]) =>
      addTrackedEditOperation(range, text, force);

  @override
  String trackSelection(Selection selection, [bool? trackPreviousOnEmpty]) {
    tracked.add(_rangeJson(selection));
    return 'sel-${tracked.length}';
  }
}

class _Helper implements ICursorStateComputerData {
  final List<List<int>> inverse;
  final Map<String, List<int>> tracked;
  _Helper(this.inverse, this.tracked);

  @override
  List<Object?> getInverseEditOperations() => inverse
      .map((List<int> x) => <Object?, Object?>{
            'range': Range(x[0], x[1], x[2], x[3]),
          })
      .toList();

  @override
  Selection getTrackedSelection(String id) {
    final List<int> a = tracked[id]!;
    return Selection(a[0], a[1], a[2], a[3]);
  }
}

void main() {
  final Map<String, dynamic> truth = _truth();
  final _Model model = _Model(<String>['hello world', 'abcdef', 'xyz']);

  test('replace command truth replay', () {
    final Map<String, Object?> actual = <String, Object?>{};

    void run(
      String label,
      ICommand cmd,
      List<List<int>> inverse, [
      Map<String, List<int>> tracked = const <String, List<int>>{},
    ]) {
      final _Builder b = _Builder();
      cmd.getEditOperations(model, b);
      final Selection cursor = cmd.computeCursorState(model, _Helper(inverse, tracked));
      actual[label] = <String, Object?>{
        'ops': b.ops,
        'tracked': b.tracked,
        'cursor': _rangeJson(cursor),
      };
    }

    run('replace', ReplaceCommand(Range(1, 1, 1, 6), 'Hi'),
        <List<int>>[<int>[2, 3, 2, 8]]);
    run('selects-text', ReplaceCommandThatSelectsText(Range(1, 1, 1, 6), 'Hi'),
        <List<int>>[<int>[2, 3, 2, 8]]);
    run('no-change-pos', ReplaceCommandWithoutChangingPosition(Range(1, 1, 1, 6), 'Hi'),
        <List<int>>[<int>[2, 3, 2, 8]]);
    run('offset-cursor', ReplaceCommandWithOffsetCursorState(Range(1, 1, 1, 6), 'Hi', 1, -2),
        <List<int>>[<int>[2, 3, 2, 8]]);
    run('preserves-selection',
        ReplaceCommandThatPreservesSelection(Range(1, 1, 1, 6), 'Hi', Selection(3, 1, 3, 3), true),
        <List<int>>[<int>[2, 3, 2, 8]],
        <String, List<int>>{'sel-1': <int>[3, 1, 3, 3]});
    run('overtype', ReplaceOvertypeCommand(Range(1, 2, 1, 5), 'XYZ'),
        <List<int>>[<int>[1, 2, 1, 5]]);
    run('overtype-empty', ReplaceOvertypeCommand(Range(1, 2, 1, 2), 'Z'),
        <List<int>>[<int>[1, 2, 1, 2]]);
    run('overtype-composition', ReplaceOvertypeCommandOnCompositionEnd(Range(2, 2, 2, 5)),
        <List<int>>[<int>[2, 2, 2, 5]]);

    expect(jsonEncode(actual), jsonEncode(truth));
  });
}
