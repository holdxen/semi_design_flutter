// 1:1 replay of
//   `editor/contrib/insertFinalNewLine/browser/insertFinalNewLineCommand.ts` (46 lines),
//   `editor/contrib/inPlaceReplace/browser/inPlaceReplaceCommand.ts` (48 lines).
// Truth: `tool/ts2dart/_batch332_truth.cjs` -> `batch332_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/commands/commandInterfaces.dart';
import '../lib/src/monaco/editor/common/core/editOperation.dart'
    show ISingleEditOperation;
import '../lib/src/monaco/editor/common/core/range.dart' show IRange, Range;
import '../lib/src/monaco/editor/common/core/selection.dart' show Selection;
import '../lib/src/monaco/editor/contrib/inPlaceReplace/browser/inPlaceReplaceCommand.dart'
    show InPlaceReplaceCommand;
import '../lib/src/monaco/editor/contrib/insertFinalNewLine/browser/insertFinalNewLineCommand.dart'
    show InsertFinalNewLineCommand, insertFinalNewLine;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(
  jsonDecode(File('tool/ts2dart/batch332_truth.json').readAsStringSync()),
);

class _Tokenization implements ITokenizationForCommand {
  @override
  bool hasAccurateTokensForLine(int lineNumber) => true;

  @override
  ILineTokensForCommand getLineTokens(int lineNumber) => _LineTokens();
}

class _LineTokens implements ILineTokensForCommand {
  @override
  int getStandardTokenType(int tokenIndex) => 0;

  @override
  int findTokenIndexAtOffset(int offset) => 0;
}

class _Model implements ITextModelForCommand {
  _Model(this.lines, this.eol);

  final List<String> lines;
  final String eol;

  @override
  ITokenizationForCommand get tokenization => _Tokenization();

  @override
  int getLineCount() => lines.length;

  @override
  String getLineContent(int lineNumber) => lines[lineNumber - 1];

  @override
  int getLineMaxColumn(int lineNumber) => lines[lineNumber - 1].length + 1;

  @override
  String getEOL() => eol;

  @override
  String getValueInRange(IRange range) {
    final String line = lines[range.startLineNumber - 1];
    return line.substring(range.startColumn - 1, range.endColumn - 1);
  }
}

class _Builder implements IEditOperationBuilder {
  final List<ISingleEditOperation> ops = <ISingleEditOperation>[];
  Selection? tracked;
  int _id = 0;

  void _push(IRange range, String? text, bool? forceMoveMarkers) {
    ops.add(
      ISingleEditOperation(range, text, forceMoveMarkers: forceMoveMarkers),
    );
  }

  @override
  void addEditOperation(IRange range, String? text, [bool? forceMoveMarkers]) =>
      _push(range, text, forceMoveMarkers);

  @override
  void addTrackedEditOperation(
    IRange range,
    String? text, [
    bool? forceMoveMarkers,
  ]) => _push(range, text, forceMoveMarkers);

  @override
  String trackSelection(Selection selection, [bool? trackPreviousOnEmpty]) {
    tracked = selection;
    return 'sel-${++_id}';
  }
}

class _Helper implements ICursorStateComputerData {
  _Helper(this.builder, this.inverse);

  final _Builder builder;
  final List<Object?> inverse;

  @override
  List<Object?> getInverseEditOperations() => inverse;

  @override
  Selection getTrackedSelection(String id) => builder.tracked!;
}

List<int> _rangeOf(IRange r) => <int>[
  r.startLineNumber,
  r.startColumn,
  r.endLineNumber,
  r.endColumn,
];

List<int> _selectionOf(Selection s) => <int>[
  s.selectionStartLineNumber,
  s.selectionStartColumn,
  s.positionLineNumber,
  s.positionColumn,
];

Map<String, Object?> _opJson(ISingleEditOperation op) => <String, Object?>{
  'range': _rangeOf(op.range),
  'text': op.text,
  'forceMoveMarkers': op.forceMoveMarkers,
};

Map<String, Object?> _runCommand(
  ICommand cmd,
  _Model model, [
  List<Object?>? inverse,
]) {
  final builder = _Builder();
  cmd.getEditOperations(model, builder);
  final helper = _Helper(builder, inverse ?? <Object?>[]);
  final Selection cursor = cmd.computeCursorState(model, helper);
  return <String, Object?>{
    'ops': builder.ops.map(_opJson).toList(),
    'tracked': builder.tracked == null ? null : _selectionOf(builder.tracked!),
    'cursor': _selectionOf(cursor),
  };
}

Selection _selection(List<dynamic> raw) =>
    Selection(raw[0] as int, raw[1] as int, raw[2] as int, raw[3] as int);

Range _range(List<dynamic> raw) =>
    Range(raw[0] as int, raw[1] as int, raw[2] as int, raw[3] as int);

void main() {
  final truth = _truth();

  group('batch332: InsertFinalNewLineCommand', () {
    for (final dynamic raw in truth['insertFinalNewLine'] as List) {
      final Map<String, dynamic> c = _map(raw);
      test(c['label'] as String, () {
        final model = _Model(
          (c['lines'] as List).cast<String>(),
          c['eol'] as String,
        );
        final selection = _selection((c['selection'] as List).cast<dynamic>());

        expect(_opJson(insertFinalNewLine(model)!), _map(c['direct']));

        final Map<String, dynamic> expected = _map(c['run']);
        final Map<String, Object?> actual = _runCommand(
          InsertFinalNewLineCommand(selection),
          model,
        );
        expect(actual['ops'], expected['ops']);
        expect(actual['tracked'], expected['tracked']);
        expect(actual['cursor'], expected['cursor']);
      });
    }
  });

  group('batch332: InPlaceReplaceCommand', () {
    for (final dynamic raw in truth['inPlaceReplace'] as List) {
      final Map<String, dynamic> c = _map(raw);
      test(c['label'] as String, () {
        final model = _Model(<String>['x'], '\n');
        final command = InPlaceReplaceCommand(
          _range((c['editRange'] as List).cast<dynamic>()),
          _selection((c['selection'] as List).cast<dynamic>()),
          c['text'] as String,
        );
        final List<int> inv = (c['inverseRange'] as List).cast<int>().toList();
        final inverse = <Object?>[
          ISingleEditOperation(Range(inv[0], inv[1], inv[0], inv[2]), null),
        ];

        final Map<String, dynamic> expected = _map(c['run']);
        final Map<String, Object?> actual = _runCommand(
          command,
          model,
          inverse,
        );
        expect(actual['ops'], expected['ops']);
        expect(actual['tracked'], expected['tracked']);
        expect(actual['cursor'], expected['cursor']);
      });
    }
  });
}
