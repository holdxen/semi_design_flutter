// 1:1 replay of the editor command subsystem (batch251):
//   - MoveCaretCommand    (caretOperations)
//   - CopyLinesCommand    (linesOperations)
//   - SortLinesCommand    (linesOperations)
//   - TrimTrailingWhitespaceCommand + trimTrailingWhitespace
//
// `tool/ts2dart/_batch251_truth.cjs` recursively transpiles and executes the
// real TypeScript command modules and their runtime dependencies (Range,
// Selection, EditOperation, safeIntl.Collator, Lazy, strings, StandardTokenType)
// — no stubs — and records the edit operations + resulting cursor selection
// produced by driving structural mocks for the erased TS interfaces.
//
// Replayed here with equivalent Dart mocks implementing the abstract contracts
// in `editor/common/commands/commandInterfaces.dart`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/date.dart' show IntlCollator;
import '../lib/src/monaco/editor/common/commands/commandInterfaces.dart';
import '../lib/src/monaco/editor/common/commands/trimTrailingWhitespaceCommand.dart';
import '../lib/src/monaco/editor/common/core/editOperation.dart';
import '../lib/src/monaco/editor/common/core/position.dart';
import '../lib/src/monaco/editor/common/core/range.dart';
import '../lib/src/monaco/editor/common/core/selection.dart';
import '../lib/src/monaco/editor/contrib/caretOperations/browser/moveCaretCommand.dart';
import '../lib/src/monaco/editor/contrib/linesOperations/browser/copyLinesCommand.dart';
import '../lib/src/monaco/editor/contrib/linesOperations/browser/sortLinesCommand.dart';

Map<String, dynamic> _map(dynamic value) => (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch251_truth.json').readAsStringSync()));

bool _same(Object? a, Object? b) {
  if (a == null || b == null) return a == b;
  if (a is num && b is num) return a == b;
  if (a is String && b is String) return a == b;
  if (a is bool && b is bool) return a == b;
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      if (!b.containsKey(k) || !_same(a[k], b[k])) return false;
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_same(a[i], b[i])) return false;
    }
    return true;
  }
  return false;
}

Map<String, dynamic> _op(ISingleEditOperation op) => {
      'range': [
        op.range.startLineNumber,
        op.range.startColumn,
        op.range.endLineNumber,
        op.range.endColumn,
      ],
      'text': op.text,
      'forceMoveMarkers': op.forceMoveMarkers,
    };

List<Map<String, dynamic>> _ops(List<ISingleEditOperation> ops) =>
    ops.map(_op).toList();

List<int> _sel(Selection s) => [
      s.startLineNumber, s.startColumn, s.endLineNumber, s.endColumn,
    ];

// ---- mocks for the erased TS interfaces ------------------------------------

class _MockLineTokens implements ILineTokensForCommand {
  _MockLineTokens(this._type);
  final int _type;

  @override
  int findTokenIndexAtOffset(int offset) => 0;

  @override
  int getStandardTokenType(int tokenIndex) => _type;
}

class _MockTokenization implements ITokenizationForCommand {
  _MockTokenization(this._typesByLine);
  final Map<int, int> _typesByLine;

  @override
  bool hasAccurateTokensForLine(int lineNumber) => true;

  @override
  ILineTokensForCommand getLineTokens(int lineNumber) =>
      _MockLineTokens(_typesByLine[lineNumber] ?? 0);
}

/// The mock's `getValueInRange` reproduces JS `String.substring` semantics
/// (clamp + swap) on a single line — matching the truth harness.
class _MockModel implements ITextModelForCommand {
  _MockModel(this._lines, [Map<int, int>? tokenTypes])
      : tokenization = _MockTokenization(tokenTypes ?? {});

  final List<String> _lines;

  @override
  final ITokenizationForCommand tokenization;

  @override
  int getLineCount() => _lines.length;

  @override
  String getLineContent(int lineNumber) => _lines[lineNumber - 1];

  @override
  int getLineMaxColumn(int lineNumber) => _lines[lineNumber - 1].length + 1;

  @override
  String getValueInRange(IRange range) {
    if (range.startLineNumber != range.endLineNumber) {
      return _lines.sublist(range.startLineNumber - 1, range.endLineNumber).join('\n');
    }
    final line = range.startLineNumber >= 1 && range.startLineNumber <= _lines.length
        ? _lines[range.startLineNumber - 1]
        : '';
    // JS substring: clamp to [0, len] and swap if start > end.
    var start = range.startColumn - 1;
    var end = range.endColumn - 1;
    if (start < 0) start = 0;
    if (end < 0) end = 0;
    if (start > line.length) start = line.length;
    if (end > line.length) end = line.length;
    if (start > end) {
      final t = start;
      start = end;
      end = t;
    }
    return line.substring(start, end);
  }
}

class _MockBuilder implements IEditOperationBuilder {
  final ops = <ISingleEditOperation>[];
  Selection? _tracked;
  int _trackedId = 0;

  @override
  void addEditOperation(IRange range, String? text, [bool? forceMoveMarkers]) {
    ops.add(ISingleEditOperation(range, text, forceMoveMarkers: forceMoveMarkers));
  }

  @override
  void addTrackedEditOperation(IRange range, String? text, [bool? forceMoveMarkers]) {
    ops.add(ISingleEditOperation(range, text, forceMoveMarkers: forceMoveMarkers));
  }

  @override
  String trackSelection(Selection selection, [bool? trackPreviousOnEmpty]) {
    _tracked = selection;
    return 'sel-${++_trackedId}';
  }
}

class _MockHelper implements ICursorStateComputerData {
  _MockHelper(this._builder);
  final _MockBuilder _builder;

  @override
  List<Object?> getInverseEditOperations() => [];

  @override
  Selection getTrackedSelection(String id) => _builder._tracked!;
}

/// Drive a command and project its observable output, mirroring `runCommand`
/// in the truth harness.
Map<String, dynamic> _runCommand(
  ICommand cmd,
  ITextModelForCommand model,
  _MockBuilder builder,
) {
  cmd.getEditOperations(model, builder);
  final cursor = cmd.computeCursorState(model, _MockHelper(builder));
  final tracked = builder._tracked;
  return {
    'operations': _ops(builder.ops),
    'trackedSelection': tracked == null ? null : _sel(tracked),
    'cursor': _sel(cursor),
  };
}

Selection _mkSel(List<dynamic> t) =>
    Selection((t[0] as num).toInt(), (t[1] as num).toInt(),
              (t[2] as num).toInt(), (t[3] as num).toInt());

void main() {
  final t = _truth();
  final collator = IntlCollator(null);

  group('batch251: MoveCaretCommand', () {
    for (final raw in (t['moveCaret'] as List)) {
      final c = _map(raw);
      test(c['label'] as String, () {
        final input = _map(c['input']);
        final lines = (input['lines'] as List).cast<String>();
        final model = _MockModel(lines);
        final builder = _MockBuilder();
        final cmd = MoveCaretCommand(_mkSel(input['sel'] as List), input['left'] as bool);
        final actual = _runCommand(cmd, model, builder);
        for (final key in ['operations', 'cursor']) {
          expect(_same(actual[key], c[key]), isTrue,
              reason: '$key: expected ${c[key]}, got ${actual[key]}');
        }
      });
    }
  });

  group('batch251: CopyLinesCommand', () {
    for (final raw in (t['copyLines'] as List)) {
      final c = _map(raw);
      test(c['label'] as String, () {
        final input = _map(c['input']);
        final lines = (input['lines'] as List).cast<String>();
        final model = _MockModel(lines);
        final builder = _MockBuilder();
        final cmd = CopyLinesCommand(
          _mkSel(input['sel'] as List),
          input['down'] as bool,
          input['noop'] as bool,
        );
        final actual = _runCommand(cmd, model, builder);
        for (final key in ['operations', 'trackedSelection', 'cursor']) {
          expect(_same(actual[key], c[key]), isTrue,
              reason: '$key: expected ${c[key]}, got ${actual[key]}');
        }
      });
    }
  });

  group('batch251: SortLinesCommand', () {
    for (final raw in (t['sortLines'] as List)) {
      final c = _map(raw);
      test(c['label'] as String, () {
        final input = _map(c['input']);
        final lines = (input['lines'] as List).cast<String>();
        final model = _MockModel(lines);
        final sel = _mkSel(input['sel'] as List);

        // canRun must be evaluated on a fresh command path; it is static.
        final canRun = SortLinesCommand.canRun(model, sel, input['descending'] as bool);
        expect(canRun, c['canRun'],
            reason: 'canRun: expected ${c['canRun']}, got $canRun');

        final builder = _MockBuilder();
        final cmd = SortLinesCommand(sel, input['descending'] as bool);
        final actual = _runCommand(cmd, model, builder);
        expect(_same(actual['operations'], c['operations']), isTrue,
            reason: 'operations: expected ${c['operations']}, got ${actual['operations']}');
      });
    }
    test('canRun(null, ...) == false', () {
      expect(SortLinesCommand.canRun(null, _mkSel([1, 1, 3, 1]), false), isFalse);
      expect(t['sortLinesCanRunNull'], isFalse);
    });
    test('collator ordering matches TS default Intl.Collator', () {
      // Guard the lexical sort assumption used by the truth harness.
      final sorted = ['10', '2', '1']..sort((a, b) => collator.compare(a, b));
      expect(sorted, ['1', '10', '2']);
    });
  });

  group('batch251: trimTrailingWhitespace (free function)', () {
    for (final raw in (t['trim'] as List)) {
      final c = _map(raw);
      test(c['label'] as String, () {
        final input = _map(c['input']);
        final lines = (input['lines'] as List).cast<String>();
        final tokenTypes = (input['tokenTypes'] as Map).map(
          (k, v) => MapEntry((k as String).isEmpty ? 0 : int.parse(k), (v as num).toInt()),
        );
        final model = _MockModel(lines, tokenTypes);
        final cursors = (input['cursors'] as List)
            .map((p) => Position((p[0] as num).toInt(), (p[1] as num).toInt()))
            .toList();
        final ops = trimTrailingWhitespace(model, cursors, input['flag'] as bool);
        expect(_same(_ops(ops), c['operations']), isTrue,
            reason: 'operations: expected ${c['operations']}, got ${_ops(ops)}');
        final cursorsAfter = cursors.map((p) => [p.lineNumber, p.column]).toList();
        expect(_same(cursorsAfter, c['cursorsAfterSort']), isTrue,
            reason: 'cursorsAfterSort: expected ${c['cursorsAfterSort']}, got $cursorsAfter');
      });
    }
  });

  group('batch251: TrimTrailingWhitespaceCommand', () {
    for (final raw in (t['trimCommand'] as List)) {
      final c = _map(raw);
      test(c['label'] as String, () {
        final input = _map(c['input']);
        final lines = (input['lines'] as List).cast<String>();
        final tokenTypes = (input['tokenTypes'] as Map).map(
          (k, v) => MapEntry((k as String).isEmpty ? 0 : int.parse(k), (v as num).toInt()),
        );
        final model = _MockModel(lines, tokenTypes);
        final builder = _MockBuilder();
        final cmd = TrimTrailingWhitespaceCommand(
          Selection(1, 1, 1, 1), <Position>[], input['flag'] as bool,
        );
        final actual = _runCommand(cmd, model, builder);
        expect(_same(actual['operations'], c['operations']), isTrue,
            reason: 'operations: expected ${c['operations']}, got ${actual['operations']}');
      });
    }
  });
}
