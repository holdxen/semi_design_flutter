// Truth replay for batch216:
//   `editor/common/viewModel/screenReaderSimpleModel.ts`
//   `editor/browser/controller/editContext/screenReaderUtils.ts`.
//
// Expectations come from `tool/ts2dart/batch216_truth.json`, produced by
// `tool/ts2dart/_batch216_truth.cjs` (real transpiled strategy + a
// deterministic in-memory `ISimpleModel`; `model.ts`, `accessibility.ts`,
// `editorOptions.ts` and `keybinding.ts` are stubs).
//
// NOTE: `screenReaderUtils.ts` has no official test of its own; truth comes
// from executing the real source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/keybindings.dart'
    show ResolvedKeybinding;
import '../lib/src/monaco/editor/browser/controller/editContext/screenReaderUtils.dart'
    as utils;
import '../lib/src/monaco/editor/common/config/editorOptions.dart'
    show EditorOption, IComputedEditorOptions;
import '../lib/src/monaco/editor/common/core/position.dart' show Position;
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/core/selection.dart'
    show Selection, SelectionDirection;
import '../lib/src/monaco/editor/common/standalone/standaloneEnums.dart'
    show EndOfLinePreference;
import '../lib/src/monaco/editor/common/viewModel/screenReaderSimpleModel.dart'
    show ISimpleModel;
import '../lib/src/monaco/platform/accessibility/common/accessibility.dart'
    show AccessibilitySupport;
import '../lib/src/monaco/platform/keybinding/common/keybinding.dart'
    show IKeybindingServiceType;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch216_truth.json').readAsStringSync()));

/// Mirrors the harness fixture: one 600-char line, eight 50-char lines, one
/// 600-char line, then 100 plain lines (110 lines total).
class _FakeSimpleModel implements ISimpleModel {
  _FakeSimpleModel() {
    _lines.add('A' * 600);
    for (int i = 0; i < 8; i++) {
      _lines.add('B' * 50);
    }
    _lines.add('C' * 600);
    for (int i = 0; i < 100; i++) {
      _lines.add('plain line ${i + 1}');
    }
  }

  final List<String> _lines = <String>[];

  String _joined(int startLine, int startColumn, int endLine, int endColumn) {
    final List<String> parts = <String>[];
    for (int line = startLine; line <= endLine; line++) {
      final String content = _lines[line - 1];
      final int from = line == startLine ? startColumn - 1 : 0;
      final int to = line == endLine ? endColumn - 1 : content.length;
      parts.add(content.substring(from.clamp(0, content.length),
          to.clamp(from.clamp(0, content.length), content.length)));
    }
    return parts.join('\n');
  }

  int _indexOfPosition(int lineNumber, int column) {
    int index = 0;
    for (int i = 0; i < lineNumber - 1; i++) {
      index += _lines[i].length + 1;
    }
    return index + (column - 1);
  }

  Position _positionOfIndex(int index) {
    int remaining = index;
    for (int i = 0; i < _lines.length; i++) {
      if (remaining <= _lines[i].length) return Position(i + 1, remaining + 1);
      remaining -= _lines[i].length + 1;
    }
    return Position(_lines.length, _lines[_lines.length - 1].length + 1);
  }

  @override
  String getLineContent(int lineNumber) => _lines[lineNumber - 1];
  @override
  int getLineCount() => _lines.length;
  @override
  int getLineMaxColumn(int lineNumber) => _lines[lineNumber - 1].length + 1;
  @override
  String getValueInRange(Range range, int eol) => _joined(range.startLineNumber,
      range.startColumn, range.endLineNumber, range.endColumn);
  @override
  int getValueLengthInRange(Range range, int eol) =>
      getValueInRange(range, eol).length;
  @override
  Position modifyPosition(Position position, int offset) => _positionOfIndex(
      _indexOfPosition(position.lineNumber, position.column) + offset);
}

class _FakeComputedOptions implements IComputedEditorOptions {
  _FakeComputedOptions(this.accessibilitySupport, this.ariaLabel);

  final int accessibilitySupport;
  final String? ariaLabel;

  @override
  Object? get(Object id) {
    if (id == EditorOption.accessibilitySupport) return accessibilitySupport;
    if (id == EditorOption.ariaLabel) return ariaLabel;
    return null;
  }
}

class _FakeKeybinding implements ResolvedKeybinding {
  _FakeKeybinding(this._label);

  final String _label;

  @override
  String? getAriaLabel() => _label;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeKeybindingService implements IKeybindingServiceType {
  _FakeKeybindingService(this._available);

  final Map<String, String> _available;

  @override
  ResolvedKeybinding? lookupKeybinding(
    String commandId, [
    Object? context,
    bool enforceContextCheck = false,
  ]) {
    final String? label = _available[commandId];
    return label == null ? null : _FakeKeybinding(label);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Map<String, Object?> _project(utils.ISimpleScreenReaderContentState state) =>
    <String, Object?>{
      'value': state.value,
      'valueLength': state.value.length,
      'selectionStart': state.selectionStart,
      'selectionEnd': state.selectionEnd,
      'startPosition': <int>[
        state.startPositionWithinEditor.lineNumber,
        state.startPositionWithinEditor.column,
      ],
      'newlineCountBeforeSelection': state.newlineCountBeforeSelection,
      'selectionDirection':
          state.selection.getDirection() == SelectionDirection.LTR ? 0 : 1,
      // JS `substring` swaps its arguments when start > end (RTL selections).
      'selectionText': state.value
          .substring(
              state.selectionStart < state.selectionEnd
                  ? state.selectionStart
                  : state.selectionEnd,
              state.selectionStart < state.selectionEnd
                  ? state.selectionEnd
                  : state.selectionStart)
          .length,
    };

void main() {
  final Map<String, dynamic> truth = _truth();
  final _FakeSimpleModel model = _FakeSimpleModel();
  final utils.SimplePagedScreenReaderStrategy strategy =
      utils.SimplePagedScreenReaderStrategy();

  test('batch216 single page keeps the full page around the selection', () {
    expect(_project(strategy.fromEditorSelection(
            model, Selection(5, 3, 5, 12), 10, false)),
        truth['singlePage']);
  });

  test('batch216 adjacent pages concatenate the whole selection', () {
    expect(_project(strategy.fromEditorSelection(
            model, Selection(9, 5, 11, 7), 10, false)),
        truth['adjacentPages']);
  });

  test('batch216 distant pages are joined with an ellipsis', () {
    expect(_project(strategy.fromEditorSelection(
            model, Selection(2, 30, 50, 4), 10, false)),
        truth['multiPages']);
  });

  test('batch216 trimLongText clamps pretext and posttext', () {
    expect(
        _project(strategy.fromEditorSelection(
            model, Selection(1, 600, 1, 600), 10, true)),
        truth['trimPretext']);
    expect(
        _project(strategy.fromEditorSelection(
            model, Selection(10, 1, 10, 1), 10, true)),
        truth['trimPosttext']);
  });

  test('batch216 reversed selections swap the content offsets', () {
    expect(_project(strategy.fromEditorSelection(
            model, Selection(5, 12, 5, 3), 10, false)),
        truth['rtl']);
    expect(_project(strategy.fromEditorSelection(
            model, Selection(110, 1, 110, 6), 10, false)),
        truth['shortNoTrim']);
  });

  test('batch216 aria label falls back through the keybinding branches', () {
    final Map<String, String> all = <String, String>{
      'editor.action.toggleScreenReaderAccessibilityMode': 'Toggle: Ctrl+M',
      'workbench.action.showCommands': 'Commands: Ctrl+Shift+P',
      'workbench.action.openGlobalKeybindings':
          'Keybindings: Ctrl+K Ctrl+S',
    };
    expect(
        utils.ariaLabelForScreenReaderContent(
            _FakeComputedOptions(AccessibilitySupport.Disabled, 'editor label'),
            _FakeKeybindingService(all)),
        truth['ariaToggle']);
    expect(
        utils.ariaLabelForScreenReaderContent(
            _FakeComputedOptions(AccessibilitySupport.Disabled, 'editor label'),
            _FakeKeybindingService(<String, String>{
              'workbench.action.showCommands': 'Commands: Ctrl+Shift+P',
            })),
        truth['ariaCommands']);
    expect(
        utils.ariaLabelForScreenReaderContent(
            _FakeComputedOptions(AccessibilitySupport.Disabled, 'editor label'),
            _FakeKeybindingService(<String, String>{
              'workbench.action.openGlobalKeybindings':
                  'Keybindings: Ctrl+K Ctrl+S',
            })),
        truth['ariaKeybindings']);
    expect(
        utils.ariaLabelForScreenReaderContent(
            _FakeComputedOptions(AccessibilitySupport.Disabled, 'editor label'),
            _FakeKeybindingService(<String, String>{})),
        truth['ariaNone']);
    expect(
        utils.ariaLabelForScreenReaderContent(
            _FakeComputedOptions(AccessibilitySupport.Enabled, 'editor label'),
            _FakeKeybindingService(<String, String>{})),
        truth['ariaEnabled']);
  });

  test('batch216 newlinecount counts line feeds', () {
    final Map<String, dynamic> expected = _map(truth['newlinecount']);
    expect(utils.newlinecount(''), expected['empty']);
    expect(utils.newlinecount('abc'), expected['single']);
    expect(utils.newlinecount('a\nb\n'), expected['trailing']);
    expect(utils.newlinecount('a\nb\nc\n\nd'), expected['multiple']);
    expect(EndOfLinePreference.LF, isNotNull);
  });
}
