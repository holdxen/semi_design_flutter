// Truth replay for batch217:
//   `editor/browser/controller/editContext/textArea/textAreaEditContextState.ts`.
//
// Expectations come from `tool/ts2dart/batch217_truth.json`, produced by
// `tool/ts2dart/_batch217_truth.cjs` (real transpiled module + real
// `strings`/`Position`/`Range`/`Selection`).
//
// NOTE: the file has no official test of its own; truth comes from executing
// the real source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/browser/controller/editContext/screenReaderUtils.dart'
    show ISimpleScreenReaderContentState;
import '../lib/src/monaco/editor/browser/controller/editContext/textArea/textAreaEditContextState.dart'
    as state;
import '../lib/src/monaco/editor/common/core/position.dart' show Position;
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/core/selection.dart' as selection;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch217_truth.json').readAsStringSync()));

Object? _stateMap(state.TextAreaState? s) => s == null
    ? null
    : <String, Object?>{
        'value': s.value,
        'selectionStart': s.selectionStart,
        'selectionEnd': s.selectionEnd,
        'selection': s.selection == null
            ? null
            : <String, Object?>{
                'startLineNumber': s.selection!.startLineNumber,
                'startColumn': s.selection!.startColumn,
                'endLineNumber': s.selection!.endLineNumber,
                'endColumn': s.selection!.endColumn,
              },
        'newlineCountBeforeSelection': s.newlineCountBeforeSelection,
        'toString': s.toString(),
      };

Object? _typeData(state.ITypeData t) => <String, Object?>{
      'text': t.text,
      'replacePrevCharCnt': t.replacePrevCharCnt,
      'replaceNextCharCnt': t.replaceNextCharCnt,
      'positionDelta': t.positionDelta,
    };

Object? _positionMap(Position? p) => p == null
    ? null
    : <String, Object?>{'lineNumber': p.lineNumber, 'column': p.column};

Object? _deduced(
    ({Position? anchor, int delta, int lineFeedCnt}) deduced) =>
    <Object?>[_positionMap(deduced.anchor), deduced.delta, deduced.lineFeedCnt];

class _FakeTextArea implements state.ITextAreaWrapper {
  _FakeTextArea(this._value, this._selectionStart, this._selectionEnd);

  String _value;
  int _selectionStart;
  int _selectionEnd;
  final List<Object?> calls = <Object?>[];

  @override
  String getValue() => _value;
  @override
  void setValue(String reason, String value) {
    calls.add(<Object?>['setValue', reason, value]);
    _value = value;
  }

  @override
  int getSelectionStart() => _selectionStart;
  @override
  int getSelectionEnd() => _selectionEnd;
  @override
  void setSelectionRange(String reason, int start, int end) {
    calls.add(<Object?>['setSelectionRange', reason, start, end]);
    _selectionStart = start;
    _selectionEnd = end;
  }
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('batch217 the EMPTY state and toString match truth', () {
    expect(_stateMap(state.TextAreaState.EMPTY), truth['empty']);
    expect(state.debugComposition, truth['debugComposition']);
  });

  test('batch217 readFromTextArea inherits the newline count only when the '
      'prefix matches', () {
    final _FakeTextArea textArea = _FakeTextArea('hello\nworld', 6, 11);
    expect(_stateMap(state.TextAreaState.readFromTextArea(textArea, null)),
        truth['readNoPrevious']);

    final state.TextAreaState previous =
        state.TextAreaState('hello\n', 6, 6, Range(1, 1, 1, 6), 1);
    expect(_stateMap(state.TextAreaState.readFromTextArea(textArea, previous)),
        truth['readKeepsNewlineCount']);

    final state.TextAreaState otherPrevious =
        state.TextAreaState('bye\n', 4, 4, Range(1, 1, 1, 4), 2);
    expect(
        _stateMap(
            state.TextAreaState.readFromTextArea(textArea, otherPrevious)),
        truth['readDropsNewlineCount']);
  });

  test('batch217 collapseSelection keeps a collapsed end state as-is', () {
    final state.TextAreaState atEnd =
        state.TextAreaState('abc', 3, 3, null, null);
    expect(identical(atEnd.collapseSelection(), atEnd),
        truth['collapseAtEndIsSelf']);
    expect(identical(state.TextAreaState.EMPTY, state.TextAreaState.EMPTY),
        truth['collapseAtEndSameInstance']);
    expect(
        _stateMap(state.TextAreaState('abc', 1, 2, null, null)
            .collapseSelection()),
        truth['collapseMiddle']);
  });

  test('batch217 isWrittenToTextArea and writeToTextArea', () {
    final state.TextAreaState value =
        state.TextAreaState('abc', 1, 2, Range(1, 1, 1, 2), null);
    expect(value.isWrittenToTextArea(_FakeTextArea('abc', 1, 2), true),
        truth['isWrittenSelectTrue']);
    expect(value.isWrittenToTextArea(_FakeTextArea('abc', 0, 0), false),
        truth['isWrittenSelectFalseDifferentSelection']);
    expect(value.isWrittenToTextArea(_FakeTextArea('abc', 0, 0), true),
        truth['isWrittenSelectTrueDifferentSelection']);

    final _FakeTextArea target = _FakeTextArea('zzz', 0, 0);
    value.writeToTextArea('test', target, true);
    expect(target.calls, truth['writeCalls']);

    final _FakeTextArea targetNoSelect = _FakeTextArea('zzz', 0, 0);
    value.writeToTextArea('test2', targetNoSelect, false);
    expect(targetNoSelect.calls, truth['writeCallsNoSelect']);
  });

  test('batch217 deduceEditorPosition walks the four branches', () {
    final state.TextAreaState value =
        state.TextAreaState('abcdef', 2, 4, Range(2, 3, 2, 5), null);
    expect(_deduced(value.deduceEditorPosition(1)), truth['deduceBefore']);
    expect(_deduced(value.deduceEditorPosition(5)), truth['deduceAfter']);
    expect(_deduced(value.deduceEditorPosition(3)), truth['deduceInside']);

    final state.TextAreaState withEllipsis =
        state.TextAreaState('ab\u2026cd', 2, 5, Range(3, 1, 3, 4), null);
    expect(_deduced(withEllipsis.deduceEditorPosition(3)),
        truth['deduceInsideEllipsis']);

    final state.TextAreaState noRange =
        state.TextAreaState('abcdef', 2, 4, null, null);
    expect(_deduced(noRange.deduceEditorPosition(0)),
        truth['deduceNoRangeBefore']);
  });

  test('batch217 deduceInput diffs consecutive states', () {
    expect(
        _typeData(state.TextAreaState.deduceInput(
            null, state.TextAreaState('abc', 3, 3, null, null), false)),
        truth['deduceInputEmpty']);
    expect(
        _typeData(state.TextAreaState.deduceInput(
            state.TextAreaState('ab', 2, 2, null, null),
            state.TextAreaState('abc', 3, 3, null, null),
            false)),
        truth['deduceInputTyping']);
    expect(
        _typeData(state.TextAreaState.deduceInput(
            state.TextAreaState('abc', 3, 3, null, null),
            state.TextAreaState('ab', 2, 2, null, null),
            false)),
        truth['deduceInputDeletion']);
    expect(
        _typeData(state.TextAreaState.deduceInput(
            state.TextAreaState('hello world', 6, 11, null, null),
            state.TextAreaState('hello there', 11, 11, null, null),
            false)),
        truth['deduceInputReplaceSelection']);
    expect(
        _typeData(state.TextAreaState.deduceInput(
            state.TextAreaState('abc', 1, 2, null, null),
            state.TextAreaState('aXYc', 3, 3, null, null),
            false)),
        truth['deduceInputComposition']);
    expect(
        _typeData(state.TextAreaState.deduceInput(
            state.TextAreaState('ab', 2, 2, null, null),
            state.TextAreaState('ab\ud83d\ude00', 4, 4, null, null),
            true)),
        truth['deduceInputEmoji']);
    expect(
        _typeData(state.TextAreaState.deduceInput(
            state.TextAreaState('a', 1, 1, null, null),
            state.TextAreaState('a\nb\nc', 5, 5, null, null),
            false)),
        truth['deduceInputMultiline']);
  });

  test('batch217 deduceAndroidCompositionInput', () {
    expect(
        _typeData(state.TextAreaState.deduceAndroidCompositionInput(
            state.TextAreaState('abc', 3, 3, null, null),
            state.TextAreaState('abc', 2, 2, null, null))),
        truth['androidEqual']);
    expect(
        _typeData(state.TextAreaState.deduceAndroidCompositionInput(
            state.TextAreaState('ab', 2, 2, null, null),
            state.TextAreaState('abc', 3, 3, null, null))),
        truth['androidInsert']);
    expect(
        _typeData(state.TextAreaState.deduceAndroidCompositionInput(
            state.TextAreaState('abc', 1, 3, null, null),
            state.TextAreaState('aXY', 3, 3, null, null))),
        truth['androidReplace']);
    expect(
        _typeData(state.TextAreaState.deduceAndroidCompositionInput(
            null, state.TextAreaState('abc', 3, 3, null, null))),
        truth['androidEmpty']);
  });

  test('batch217 fromScreenReaderContentState honours the direction', () {
    final Map<String, dynamic> direction = _map(truth['selectionDirection']);
    expect(selection.SelectionDirection.LTR.index, direction['ltr']);
    expect(selection.SelectionDirection.RTL.index, direction['rtl']);

    final ISimpleScreenReaderContentState ltr = ISimpleScreenReaderContentState(
      value: 'ab\ncdef',
      selectionStart: 3,
      selectionEnd: 6,
      selection: selection.Selection(2, 1, 2, 4),
      startPositionWithinEditor: Position(1, 1),
      newlineCountBeforeSelection: 1,
    );
    expect(_stateMap(state.TextAreaState.fromScreenReaderContentState(ltr)),
        truth['fromScreenReaderLtr']);

    final ISimpleScreenReaderContentState rtl = ISimpleScreenReaderContentState(
      value: 'ab\ncdef',
      selectionStart: 6,
      selectionEnd: 3,
      selection: selection.Selection(2, 4, 2, 1),
      startPositionWithinEditor: Position(1, 1),
      newlineCountBeforeSelection: 1,
    );
    expect(_stateMap(state.TextAreaState.fromScreenReaderContentState(rtl)),
        truth['fromScreenReaderRtl']);
  });
}
