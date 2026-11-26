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
import '../lib/src/monaco/editor/common/commands/surroundSelectionCommand.dart'
    show CompositionSurroundSelectionCommand, SurroundSelectionCommand;
import '../lib/src/monaco/editor/common/core/position.dart' show Position;
import '../lib/src/monaco/editor/common/core/range.dart' show IRange, Range;
import '../lib/src/monaco/editor/common/core/selection.dart' show Selection;

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root =
      jsonDecode(File('tool/ts2dart/batch425_truth.json').readAsStringSync())
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

List<Object?> _rangeJson(IRange r) =>
    <Object?>[r.startLineNumber, r.startColumn, r.endLineNumber, r.endColumn];

class _Op {
  final IRange range;
  _Op(this.range);
}

class _Builder implements IEditOperationBuilder {
  final List<Map<String, Object?>> ops = <Map<String, Object?>>[];

  @override
  void addTrackedEditOperation(IRange range, String? text, [bool? forceMoveMarkers]) {
    ops.add(<String, Object?>{'range': _rangeJson(range), 'text': text});
  }

  @override
  void addEditOperation(IRange range, String? text, [bool? forceMoveMarkers]) =>
      addTrackedEditOperation(range, text, forceMoveMarkers);

  @override
  String trackSelection(Selection selection, [bool? trackPreviousOnEmpty]) => 'id';
}

class _Helper implements ICursorStateComputerData {
  final List<Range> inverseRanges;
  _Helper(this.inverseRanges);

  @override
  List<Object?> getInverseEditOperations() =>
      inverseRanges.map((Range r) => _Op(r)).toList();

  @override
  Selection getTrackedSelection(String id) => Selection(1, 1, 1, 1);
}

// A minimal model carrier (the commands never read it).
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
  String getValueInRange(IRange range) => '';
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

Object _resultJson(_Builder b, Selection cursor) => <String, Object?>{
  'ops': b.ops,
  'cursor': _rangeJson(cursor),
};

void main() {
  final Map<String, dynamic> truth = _truth();
  final _Model model = _Model();

  test('surround selection command truth replay', () {
    final Map<String, Object?> actual = <String, Object?>{};

    // SurroundSelectionCommand cases.
    SurroundSelectionCommand surround(
      Selection sel,
      String before,
      String after,
    ) =>
        SurroundSelectionCommand(sel, before, after);

    Selection cursorFor(
      SurroundSelectionCommand cmd,
      List<List<int>> inverse,
    ) {
      final List<Range> ranges = inverse
          .map((List<int> r) => Range(r[0], r[1], r[2], r[3]))
          .toList();
      return cmd.computeCursorState(model, _Helper(ranges));
    }

    {
      final SurroundSelectionCommand cmd = surround(Selection(1, 5, 1, 10), '(', ')');
      final _Builder b = _Builder();
      cmd.getEditOperations(model, b);
      actual['single-line'] = _resultJson(
        b,
        cursorFor(cmd, <List<int>>[
          <int>[1, 5, 1, 6],
          <int>[1, 11, 1, 12],
        ]),
      );
    }
    {
      final SurroundSelectionCommand cmd = surround(Selection(2, 3, 2, 3), '"', '');
      final _Builder b = _Builder();
      cmd.getEditOperations(model, b);
      actual['empty-after'] = _resultJson(
        b,
        cursorFor(cmd, <List<int>>[
          <int>[2, 3, 2, 4],
          <int>[2, 3, 2, 3],
        ]),
      );
    }
    {
      final SurroundSelectionCommand cmd = surround(Selection(3, 2, 5, 8), '[', ']');
      final _Builder b = _Builder();
      cmd.getEditOperations(model, b);
      actual['multi-line'] = _resultJson(
        b,
        cursorFor(cmd, <List<int>>[
          <int>[3, 2, 3, 3],
          <int>[5, 9, 5, 10],
        ]),
      );
    }

    // CompositionSurroundSelectionCommand cases.
    Selection compCursor(
      CompositionSurroundSelectionCommand cmd,
      List<List<int>> inverse,
    ) {
      final List<Range> ranges = inverse
          .map((List<int> r) => Range(r[0], r[1], r[2], r[3]))
          .toList();
      return cmd.computeCursorState(model, _Helper(ranges));
    }

    {
      final CompositionSurroundSelectionCommand cmd =
          CompositionSurroundSelectionCommand(Position(1, 4), '"hello"', '"');
      final _Builder b = _Builder();
      cmd.getEditOperations(model, b);
      actual['composition-basic'] = _resultJson(
        b,
        compCursor(cmd, <List<int>>[<int>[1, 4, 1, 12]]),
      );
    }
    {
      final CompositionSurroundSelectionCommand cmd =
          CompositionSurroundSelectionCommand(Position(3, 1), '()', '');
      final _Builder b = _Builder();
      cmd.getEditOperations(model, b);
      actual['composition-empty-after'] = _resultJson(
        b,
        compCursor(cmd, <List<int>>[<int>[3, 1, 3, 3]]),
      );
    }

    expect(jsonEncode(actual), jsonEncode(truth));
  });
}
