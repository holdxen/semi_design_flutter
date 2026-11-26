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
import '../lib/src/monaco/editor/common/commands/columnSelectionPasteCommand.dart'
    show ColumnSelectionPasteCommand;
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/core/selection.dart' show Selection;

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root =
      jsonDecode(File('tool/ts2dart/batch429_truth.json').readAsStringSync())
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
  final List<String> lines;
  _Model(this.lines);
  @override
  int getLineCount() => lines.length;
  @override
  String getLineContent(int lineNumber) =>
      (lineNumber >= 1 && lineNumber <= lines.length) ? lines[lineNumber - 1] : '';
  @override
  int getLineMaxColumn(int lineNumber) => getLineContent(lineNumber).length + 1;
  @override
  String getEOL() => '\n';
  @override
  String getValueInRange(Object range) {
    final dynamic r = range;
    if (r.startLineNumber == r.endLineNumber) {
      return getLineContent(r.startLineNumber).substring(
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
  @override
  void addTrackedEditOperation(Object range, String? text, [bool? force]) {
    ops.add(<String, Object?>{'range': _rangeJson(range), 'text': text, 'force': force});
  }

  @override
  void addEditOperation(Object range, String? text, [bool? force]) =>
      addTrackedEditOperation(range, text, force);

  @override
  String trackSelection(Selection selection, [bool? trackPreviousOnEmpty]) => 'sel';
}

class _Helper implements ICursorStateComputerData {
  final List<List<int>> inverse;
  _Helper(this.inverse);
  @override
  List<Object?> getInverseEditOperations() => inverse
      .map((List<int> x) => <Object?, Object?>{
            'range': Range(x[0], x[1], x[2], x[3]),
          })
      .toList();
  @override
  Selection getTrackedSelection(String id) => Selection(1, 1, 1, 1);
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('column selection paste command truth replay', () {
    final Map<String, Object?> actual = <String, Object?>{};

    void run(
      String label,
      List<String> lines,
      Selection sel,
      List<String> text,
      int tabSize,
      bool overtype,
      List<List<int>> inverse,
    ) {
      final ColumnSelectionPasteCommand cmd =
          ColumnSelectionPasteCommand(sel, text, tabSize, overtype);
      final _Builder b = _Builder();
      cmd.getEditOperations(_Model(lines), b);
      final Selection cursor =
          cmd.computeCursorState(_Model(lines), _Helper(inverse));
      actual[label] = <String, Object?>{
        'ops': b.ops,
        'cursor': _rangeJson(cursor),
      };
    }

    run('single-line', <String>['abcdef', 'ghijkl'],
        Selection(1, 3, 1, 3), <String>['XYZ'], 4, false,
        <List<int>>[<int>[1, 3, 1, 6]]);
    run('multi-line', <String>['abcdef', 'ghijkl', 'mnopqr'],
        Selection(1, 3, 1, 3), <String>['XY', 'Z'], 4, false,
        <List<int>>[<int>[1, 3, 1, 5], <int>[2, 3, 2, 4]]);
    run('ragged', <String>['abcdef', 'ghijkl'],
        Selection(1, 1, 1, 1), <String>['A', 'LONGER'], 4, false,
        <List<int>>[<int>[1, 1, 1, 7], <int>[2, 1, 2, 2]]);
    run('overtype', <String>['abcdef', 'ghijkl'],
        Selection(1, 3, 1, 3), <String>['XY'], 4, true,
        <List<int>>[<int>[1, 3, 1, 5]]);
    run('append', <String>['abc'],
        Selection(1, 2, 1, 2), <String>['X', 'Y'], 4, false,
        <List<int>>[<int>[1, 2, 1, 3], <int>[2, 2, 2, 3]]);
    run('tabs', <String>['\tabc', 'xy'],
        Selection(1, 2, 1, 2), <String>['P', 'Q'], 4, false,
        <List<int>>[<int>[1, 2, 1, 3], <int>[2, 1, 2, 2]]);

    expect(jsonEncode(actual), jsonEncode(truth));
  });
}
