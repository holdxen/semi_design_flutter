import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/cancellation.dart'
    show CancellationToken;
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' as ev;
import 'package:semi_design_flutter/src/monaco/base/common/severity.dart'
    show Severity;
import 'package:semi_design_flutter/src/monaco/platform/dialogs/common/dialogs.dart'
    as d;
import 'package:semi_design_flutter/src/monaco/platform/dialogs/test/common/testDialogService.dart'
    as t;

final Map<String, Object?> _truth =
    json.decode(File('tool/ts2dart/batch145_truth.json').readAsStringSync())
        as Map<String, Object?>;

Map<String, Object?> _map(Object? v) => (v as Map).cast<String, Object?>();
List<Object?> _list(Object? v) => (v as List).cast<Object>();

// ---------- carriers implementing the real dialogs.dart interfaces ----------
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

class _ConfirmationResult implements d.IConfirmationResult {
  _ConfirmationResult({this.confirmed = false, this.checkboxChecked});
  @override
  final bool confirmed;
  @override
  final bool? checkboxChecked;
}

class _InputResult implements d.IInputResult {
  _InputResult({this.confirmed = false, this.values, this.checkboxChecked});
  @override
  final bool confirmed;
  @override
  final List<String>? values;
  @override
  final bool? checkboxChecked;
}

class _Button implements d.IPromptButton<Object?> {
  _Button(this.label, this.fn);
  @override
  final String label;
  final Object? Function(d.ICheckboxResult) fn;
  @override
  Object? run(d.ICheckboxResult checkbox) => fn(checkbox);
}

class _CancelButton implements d.IPromptCancelButton<Object?> {
  _CancelButton(this.label, this.fn);
  @override
  final String? label;
  final Object? Function(d.ICheckboxResult) fn;
  @override
  Object? run(d.ICheckboxResult checkbox) => fn(checkbox);
}

class _Prompt implements d.IPrompt<Object?> {
  _Prompt({
    this.type,
    required this.message,
    this.detail,
    this.buttons,
    this.cancelButton,
  });
  @override
  final Object? type;
  @override
  final String message;
  @override
  final Object? detail;
  @override
  String? get title => null;
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

class _PresetResult implements d.IPromptResult<Object?> {
  _PresetResult(this.result, [this.checkboxChecked]);
  @override
  final Object? result;
  @override
  final bool? checkboxChecked;
}

class _Input implements d.IInput {
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
  String? get primaryButton => null;
  @override
  String? get cancelButton => null;
  @override
  List<d.IInputElement> get inputs => <d.IInputElement>[];
}

class _RecordingService extends t.TestDialogService {
  final List<Object?> types = <Object?>[];
  final List<String> messages = <String>[];

  @override
  Future<d.IPromptResult<T>> prompt<T>(d.IPrompt<T> prompt) async {
    types.add(prompt.type);
    messages.add(prompt.message);
    return _RecPromptResult<T>();
  }
}

class _RecPromptResult<T> implements d.IPromptResult<T> {
  @override
  T? get result => null;
  @override
  bool? get checkboxChecked => null;
}

void main() {
  test('confirm default / ctor default 1:1 truth', () async {
    final s0 = t.TestDialogService();
    final c0 = await s0.confirm(_Confirmation());
    expect(c0.confirmed, _map(_truth['confirm_default'])['confirmed']);

    final s1 = t.TestDialogService(_ConfirmationResult(confirmed: true));
    final c1 = await s1.confirm(_Confirmation());
    expect(c1.confirmed, _map(_truth['confirm_ctorDefault'])['confirmed']);
  });

  test('confirm setConfirmResult one-shot 1:1 truth', () async {
    final s = t.TestDialogService();
    s.setConfirmResult(_ConfirmationResult(
        confirmed: true, checkboxChecked: true));
    final r1 = await s.confirm(_Confirmation());
    final r2 = await s.confirm(_Confirmation());
    expect(r1.confirmed, _map(_truth['confirm_oneshot_1'])['confirmed']);
    expect(r1.checkboxChecked,
        _map(_truth['confirm_oneshot_1'])['checkboxChecked']);
    expect(r2.confirmed, _map(_truth['confirm_oneshot_2'])['confirmed']);
  });

  test('prompt empty / button / cancel 1:1 truth', () async {
    final s0 = t.TestDialogService();
    final r0 = await s0.prompt(_Prompt(message: 'm'));
    // JSON omits `result: undefined`, i.e. {} -> null.
    expect(r0.result, _map(_truth['prompt_empty'])['result']);

    final s1 = t.TestDialogService();
    final r1 = await s1.prompt(_Prompt(
      message: 'm',
      buttons: <d.IPromptButton<Object?>>[
        _Button('A', (_) => 'valueA'),
      ],
    ));
    expect(r1.result, _map(_truth['prompt_button'])['result']);

    final s2 = t.TestDialogService();
    final r2 = await s2.prompt(_Prompt(
      message: 'm',
      cancelButton: _CancelButton('C', (_) => 'valueC'),
    ));
    expect(r2.result, _map(_truth['prompt_cancelOnly'])['result']);

    final s3 = t.TestDialogService();
    final r3 = await s3.prompt(_Prompt(message: 'm', cancelButton: 'Cancel'));
    expect(r3.result, _map(_truth['prompt_cancelString'])['result']);
  });

  test('prompt defaultPromptResult short-circuit 1:1 truth', () async {
    bool ran = false;
    final s = t.TestDialogService(null, _PresetResult('preset'));
    final r = await s.prompt(_Prompt(
      message: 'm',
      buttons: <d.IPromptButton<Object?>>[
        _Button('A', (_) {
          ran = true;
          return 'valueA';
        }),
      ],
    ));
    expect(r.result, _map(_truth['prompt_preset'])['result']);
    expect(ran, _truth['prompt_preset_buttonRan']);
  });

  test('info/warn/error route through prompt with Severity 1:1 truth',
      () async {
    final rec = _RecordingService();
    await rec.info('i-msg', 'detail');
    await rec.warn('w-msg');
    await rec.error('e-msg');
    expect(rec.types, _list(_truth['route_types']));
    expect(rec.messages, _list(_truth['route_messages']));
    final sev = _map(_truth['severity_values']);
    expect(sev['Info'], Severity.Info);
    expect(sev['Warning'], Severity.Warning);
    expect(sev['Error'], Severity.Error);
  });

  test('input / about / flags / Event.None 1:1 truth', () async {
    final s = t.TestDialogService();
    final input = await s.input(_Input());
    expect(input.confirmed, _map(_truth['input'])['confirmed']);
    expect(input.values, _list(_map(_truth['input'])['values']));
    await s.about();
    expect(s.hasDialog, _truth['hasDialog']);
    expect(identical(s.onWillShowDialog, ev.eventNone),
        _truth['onWillShow_isEventNone']);
    expect(identical(s.onDidShowDialog, ev.eventNone),
        _truth['onDidShow_isEventNone']);
  });
}
