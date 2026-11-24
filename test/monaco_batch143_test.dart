import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/cancellation.dart'
    show CancellationToken;
import 'package:semi_design_flutter/src/monaco/base/common/severity.dart' show Severity;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/platform/dialogs/common/dialogs.dart' as d;

final Map<String, Object?> _truth =
    json.decode(File('tool/ts2dart/batch143_truth.json').readAsStringSync())
        as Map<String, Object?>;

List<Object?> _list(Object? v) => (v as List).cast<Object?>();
Map<String, Object?> _map(Object? v) => (v as Map).cast<String, Object?>();

// ---------- carriers ----------
class _Checkbox implements d.ICheckbox {
  _Checkbox(this.label, [this.checked]);
  @override
  final String label;
  @override
  final bool? checked;
}

class _CheckboxResult implements d.ICheckboxResult {
  _CheckboxResult(this.checkboxChecked);
  @override
  final bool? checkboxChecked;
}

class _Confirmation implements d.IConfirmation {
  _Confirmation({this.primaryButton, this.cancelButton});
  @override
  Object? get type => null;
  @override
  String? get title => null;
  @override
  String get message => 'm';
  @override
  Object? get detail => null;
  @override
  d.ICheckbox? get checkbox => null;
  @override
  Object? get custom => null;
  @override
  CancellationToken? get token => null;
  @override
  final String? primaryButton;
  @override
  final String? cancelButton;
}

class _Input implements d.IInput {
  _Input({String? primaryButton, String? cancelButton})
      : _primaryButton = primaryButton,
        _cancelButton = cancelButton;
  final String? _primaryButton;
  final String? _cancelButton;
  @override
  Object? get type => null;
  @override
  String? get title => null;
  @override
  String get message => 'm';
  @override
  Object? get detail => null;
  @override
  d.ICheckbox? get checkbox => null;
  @override
  Object? get custom => null;
  @override
  CancellationToken? get token => null;
  @override
  String? get primaryButton => _primaryButton;
  @override
  String? get cancelButton => _cancelButton;
  @override
  List<d.IInputElement> get inputs => <d.IInputElement>[];
}

class _PromptButton implements d.IPromptButton<Object?> {
  _PromptButton(this.label, this._run);
  @override
  final String label;
  final Object? Function(d.ICheckboxResult) _run;
  @override
  Object? run(d.ICheckboxResult checkbox) => _run(checkbox);
}

class _CancelButton implements d.IPromptCancelButton<Object?> {
  _CancelButton(this.label, this._run);
  @override
  final String? label;
  final Object? Function(d.ICheckboxResult) _run;
  @override
  Object? run(d.ICheckboxResult checkbox) => _run(checkbox);
}

class _Prompt implements d.IPrompt<Object?> {
  _Prompt({List<d.IPromptButton<Object?>>? buttons, this.cancelButton})
      : buttons = buttons;
  @override
  Object? get type => null;
  @override
  String? get title => null;
  @override
  String get message => 'm';
  @override
  Object? get detail => null;
  @override
  d.ICheckbox? get checkbox => null;
  @override
  Object? get custom => null;
  @override
  CancellationToken? get token => null;
  @override
  final List<d.IPromptButton<Object?>>? buttons;
  @override
  final Object? cancelButton;
}

class _Handler extends d.AbstractDialogHandler {
  @override
  Future<d.IConfirmationResult> confirm(d.IConfirmation confirmation) async =>
      throw UnimplementedError();
  @override
  Future<d.IInputResult> input(d.IInput input) async => throw UnimplementedError();
  @override
  Future<d.IAsyncPromptResult<T>> prompt<T>(d.IPrompt<T> prompt) async =>
      throw UnimplementedError();
  @override
  Future<void> about(String title, String details, String detailsToCopy) async {}
}

void main() {
  final h = _Handler();
  List<String> strList(Object? v) => _list(v).cast<String>();

  test('confirmation buttons 1:1 truth', () {
    expect(h.getConfirmationButtons(_Confirmation()),
        strList(_truth['conf_default']));
    expect(
        h.getConfirmationButtons(
            _Confirmation(primaryButton: 'Go', cancelButton: 'Nope')),
        strList(_truth['conf_custom']));
    expect(h.getConfirmationButtons(_Confirmation(primaryButton: 'Go')),
        strList(_truth['conf_primaryOnly']));
    expect(h.getConfirmationButtons(_Confirmation(cancelButton: 'Nope')),
        strList(_truth['conf_cancelOnly']));
  });

  test('input buttons 1:1 truth', () {
    expect(h.getInputButtons(_Input()), strList(_truth['input_default']));
    expect(
        h.getInputButtons(_Input(primaryButton: 'Save', cancelButton: 'Exit')),
        strList(_truth['input_custom']));
  });

  test('prompt buttons 1:1 truth', () {
    expect(h.getPromptButtons(_Prompt()), strList(_truth['prompt_default']));
    expect(
        h.getPromptButtons(_Prompt(buttons: <d.IPromptButton<Object?>>[
          _PromptButton('A', (_) => null),
          _PromptButton('B', (_) => null),
        ])),
        strList(_truth['prompt_buttons']));
    expect(
        h.getPromptButtons(_Prompt(
            buttons: <d.IPromptButton<Object?>>[_PromptButton('A', (_) => null)],
            cancelButton: true)),
        strList(_truth['prompt_buttonsCancelTrue']));
    expect(
        h.getPromptButtons(_Prompt(
            buttons: <d.IPromptButton<Object?>>[_PromptButton('A', (_) => null)],
            cancelButton: 'Later')),
        strList(_truth['prompt_buttonsCancelStr']));
    expect(
        h.getPromptButtons(_Prompt(
            buttons: <d.IPromptButton<Object?>>[_PromptButton('A', (_) => null)],
            cancelButton: _CancelButton('Dismiss', (_) => null))),
        strList(_truth['prompt_buttonsCancelObjLabel']));
    expect(
        h.getPromptButtons(_Prompt(
            buttons: <d.IPromptButton<Object?>>[_PromptButton('A', (_) => null)],
            cancelButton: _CancelButton(null, (_) => null))),
        strList(_truth['prompt_buttonsCancelObjNoLabel']));
    expect(
        h.getPromptButtons(
            _Prompt(cancelButton: _CancelButton('Only', (_) => null))),
        strList(_truth['prompt_cancelOnlyObj']));
    expect(h.getPromptButtons(_Prompt(buttons: <d.IPromptButton<Object?>>[])),
        strList(_truth['prompt_buttonsEmpty']));
  });

  test('getDialogType 1:1 truth', () {
    expect(h.getDialogType('question'), _truth['dtype_string']);
    // dtype_undefined omitted from JSON by JSON.stringify(undefined).
    expect(h.getDialogType(null), isNull);
    expect(h.getDialogType(Severity.Info), _truth['dtype_info']);
    expect(h.getDialogType(Severity.Warning), _truth['dtype_warning']);
    expect(h.getDialogType(Severity.Error), _truth['dtype_error']);
    expect(h.getDialogType(Severity.Ignore), _truth['dtype_ignore']);
    expect(h.getDialogType(99), _truth['dtype_otherNum']);
  });

  test('getPromptResult 1:1 truth', () async {
    final List<Object?> tr = _list(_truth['promptResults']);

    // buttons only, index 0
    var p0 = _Prompt(buttons: <d.IPromptButton<Object?>>[
      _PromptButton('b0', (cb) => 'v0:${cb.checkboxChecked}')
    ]);
    var r0 = h.getPromptResult<Object?>(p0, 0, false);
    expect(await r0.result, _map(tr[0])['result']);
    expect(r0.checkboxChecked, _map(tr[0])['checkboxChecked']);

    // buttons + cancel object, index 1
    var p1 = _Prompt(
        buttons: <d.IPromptButton<Object?>>[
          _PromptButton('b0', (cb) => 'v0:${cb.checkboxChecked}')
        ],
        cancelButton: _CancelButton('C', (cb) => 'vCANCEL:${cb.checkboxChecked}'));
    var r1 = h.getPromptResult<Object?>(p1, 1, true);
    expect(await r1.result, _map(tr[1])['result']);
    expect(r1.checkboxChecked, _map(tr[1])['checkboxChecked']);

    // buttons + cancel str, index out of range -> undefined result
    var p2 = _Prompt(
        buttons: <d.IPromptButton<Object?>>[
          _PromptButton('b0', (cb) => 'v0:${cb.checkboxChecked}')
        ],
        cancelButton: 'str');
    var r2 = h.getPromptResult<Object?>(p2, 5, null);
    expect(await r2.result, _map(tr[2])['result']);

    // buttons + cancel true, index 0
    var p3 = _Prompt(
        buttons: <d.IPromptButton<Object?>>[
          _PromptButton('b0', (cb) => 'v0:${cb.checkboxChecked}')
        ],
        cancelButton: true);
    var r3 = h.getPromptResult<Object?>(p3, 0, false);
    expect(await r3.result, _map(tr[3])['result']);
  });

  test('getFileNamesMessage 1:1 truth', () {
    expect(d.getFileNamesMessage(<Object>[]), _truth['msg_empty']);
    expect(d.getFileNamesMessage(<Object>['a.ts', 'b.ts', 'c.ts']),
        _truth['msg_strings']);
    expect(
        d.getFileNamesMessage(<Object>[
          URI.parse('file:///home/user/a.ts'),
          URI.parse('file:///tmp/b.ts')
        ]),
        _truth['msg_uris']);
    expect(
        d.getFileNamesMessage(
            <Object>['a.ts', URI.parse('file:///home/user/b.ts')]),
        _truth['msg_mixed']);
    List<Object> many(int n) =>
        List<Object>.generate(n, (i) => 'f$i.ts', growable: false);
    expect(d.getFileNamesMessage(many(11)), _truth['msg_11']);
    expect(d.getFileNamesMessage(many(12)), _truth['msg_12']);
    expect(d.getFileNamesMessage(many(15)), _truth['msg_15']);
  });
}
