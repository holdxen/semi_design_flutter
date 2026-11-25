// 1:1 replay of `editor/contrib/editorState/browser/editorState.ts`.
// Truth: `tool/ts2dart/_batch414_truth.cjs` -> `batch414_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/cancellation.dart'
    show CancellationTokenSource;
import '../lib/src/monaco/base/common/lifecycle.dart' show IDisposable;
import '../lib/src/monaco/editor/common/core/position.dart' show Position;
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/contrib/editorState/browser/editorState.dart';

Map<String, dynamic> _map(dynamic v) => (v as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root = _map(
    jsonDecode(File('tool/ts2dart/batch414_truth.json').readAsStringSync()),
  );
  return <String, dynamic>{
    for (final dynamic r in root['results'] as List<dynamic>)
      (r as Map)['label'] as String: <String, dynamic>{
        for (final MapEntry<Object?, Object?> e
            in (r as Map).cast<Object?, Object?>().entries)
          if (e.key != 'label') e.key as String: e.value,
      },
  };
}

class _Disposable implements IDisposable {
  @override
  void dispose() {}
}

class _Event {
  final List<void Function(Object)> listeners = <void Function(Object)>[];
  Object call(void Function(Object) handler) {
    listeners.add(handler);
    return _Disposable();
  }
  void fire(Object e) {
    for (final void Function(Object) l in listeners.toList()) l(e);
  }
}

class _Editor implements IEditorStateCodeEditor {
  final bool noModel;
  final String uri;
  final int version;
  final Position position;
  final Range selection;
  final num scrollLeft;
  final num scrollTop;

  final _Event cursorPos = _Event();
  final _Event cursorSel = _Event();
  final _Event scroll = _Event();
  final _Event modelChanged = _Event();
  final _Event contentChanged = _Event();

  _Editor({
    this.noModel = false,
    this.uri = 'file:///a.ts',
    this.version = 3,
    Position? position,
    Range? selection,
    this.scrollLeft = 0,
    this.scrollTop = 0,
  })  : position = position ?? Position(1, 2),
        selection = selection ?? Range(1, 1, 1, 5);

  @override
  Object? getModel() => noModel ? null : _ModelWrapper(uri, version);
  @override
  Position? getPosition() => position;
  @override
  Range? getSelection() => selection;
  @override
  num getScrollLeft() => scrollLeft;
  @override
  num getScrollTop() => scrollTop;
  @override
  Object get onDidChangeCursorPosition => cursorPos;
  @override
  Object get onDidChangeCursorSelection => cursorSel;
  @override
  Object get onDidScrollChange => scroll;
  @override
  Object get onDidChangeModel => modelChanged;
  @override
  Object get onDidChangeModelContent => contentChanged;
}

/// Wrapper exposing uri as an Object whose toString() gives the path.
class _ModelWrapper implements IEditorStateTextModel {
  final String _uri;
  final int version;
  _ModelWrapper(this._uri, this.version);

  @override
  Object get uri => _Uri(_uri);
  @override
  int getVersionId() => version;
  @override
  Object get onDidChangeContent => _Event();
}

class _Uri {
  final String value;
  _Uri(this.value);
  @override
  String toString() => value;
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('editor state replay TS truth', () {
    final Map<String, Object?> actual = <String, Object?>{};

    actual['flags'] = <String, Object?>{
      'Value': CodeEditorStateFlag.Value,
      'Selection': CodeEditorStateFlag.Selection,
      'Position': CodeEditorStateFlag.Position,
      'Scroll': CodeEditorStateFlag.Scroll,
    };

    const int all = CodeEditorStateFlag.Value |
        CodeEditorStateFlag.Selection |
        CodeEditorStateFlag.Position |
        CodeEditorStateFlag.Scroll;
    final EditorState state = EditorState(_Editor(), all);
    actual['validate'] = <String, Object?>{
      'same': state.validate(_Editor()),
      'diffPos': state.validate(_Editor(position: Position(2, 1))),
      'diffSel': state.validate(_Editor(selection: Range(1, 1, 1, 9))),
      'diffVer': state.validate(_Editor(version: 4)),
      'diffScroll': state.validate(_Editor(scrollTop: 5)),
    };

    final EditorState valueState =
        EditorState(_Editor(), CodeEditorStateFlag.Value);
    actual['flag-mask'] = <String, Object?>{
      'posChange': valueState.validate(_Editor(position: Position(9, 9))),
      'selChange': valueState.validate(_Editor(selection: Range(9, 9, 9, 9))),
      'scrollChange': valueState.validate(_Editor(scrollTop: 99)),
      'verChange': valueState.validate(_Editor(version: 8)),
    };

    final EditorState noModelState =
        EditorState(_Editor(noModel: true), CodeEditorStateFlag.Value);
    actual['no-model'] = <String, Object?>{
      'equal': noModelState.validate(_Editor(noModel: true)),
      'all': noModelState.validate(_Editor()) && noModelState.validate(_Editor()),
    };

    // CTS construct/cancel.
    final _Editor ctsEditor = _Editor();
    final List<Object> registered = <Object>[];
    final EditorStateCancellationTokenSource cts =
        EditorStateCancellationTokenSource(
      ctsEditor,
      CodeEditorStateFlag.Position |
          CodeEditorStateFlag.Selection |
          CodeEditorStateFlag.Scroll |
          CodeEditorStateFlag.Value,
      Range(2, 1, 4, 1),
      null,
      (CancellationTokenSource source) => registered.add(source),
    );
    actual['cts-construct'] = <String, Object?>{
      'registered': registered.length,
      'cancelled': cts.token.isCancellationRequested,
    };
    cts.cancel();
    actual['cts-cancel'] = <String, Object?>{
      'cancelled': cts.token.isCancellationRequested,
    };
    cts.dispose();

    for (final String key in truth.keys) {
      expect(
        jsonEncode(actual[key]),
        jsonEncode(truth[key]),
        reason: 'mismatch at $key',
      );
    }
  });
}
