// 1:1 replay of `editor/contrib/parameterHints/browser/parameterHintsModel.ts`.
// Truth: `tool/ts2dart/_batch413_truth.cjs` -> `batch413_truth.json`.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/async.dart' show Delayer;
import '../lib/src/monaco/base/common/event.dart' show Emitter, Event;
import '../lib/src/monaco/base/common/lifecycle.dart' show IDisposable;
import '../lib/src/monaco/editor/common/config/editorOptions.dart'
    show EditorOption;
import '../lib/src/monaco/editor/common/languages.dart'
    show SignatureHelpTriggerKind;
import '../lib/src/monaco/editor/contrib/parameterHints/browser/parameterHintsModel.dart';

Map<String, dynamic> _map(dynamic v) => (v as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root = _map(
    jsonDecode(File('tool/ts2dart/batch413_truth.json').readAsStringSync()),
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

class _FakeDelayer extends Delayer<bool> implements IDisposable {
  final List<_Task> tasks = <_Task>[];
  int cancels = 0;
  bool _triggered = false;

  _FakeDelayer(super.defaultDelay);

  @override
  Future<bool> trigger(Object task, [dynamic delay]) {
    tasks.add(_Task(task, (delay as int?) ?? (defaultDelay as int)));
    _triggered = true;
    return Future<bool>.value(true);
  }

  @override
  void cancel() {
    cancels++;
    _triggered = false;
    tasks.clear();
  }

  @override
  bool isTriggered() => _triggered;

  Future<bool> fire() async {
    if (tasks.isEmpty) return false;
    final _Task t = tasks.removeAt(0);
    return await (t.task as Future<bool> Function())();
  }

  @override
  void dispose() {}
}

class _Task {
  final Object task;
  final int delay;
  _Task(this.task, this.delay);
}

class _Options {
  final bool enabled;
  final bool cycle;
  _Options(this.enabled, this.cycle);
}

class _Editor implements IParameterHintsEditor {
  final Emitter<Object> _blur = Emitter<Object>();
  final Emitter<Object> _config = Emitter<Object>();
  final Emitter<Object> _model = Emitter<Object>();
  final Emitter<Object> _lang = Emitter<Object>();
  final Emitter<Object> _cursor = Emitter<Object>();
  final Emitter<Object> _content = Emitter<Object>();
  final Emitter<Object> _type = Emitter<Object>();

  bool hasModelFlag;
  _Options options;

  _Editor({bool hasModel = true, bool enabled = true, bool cycle = false})
      : hasModelFlag = hasModel,
        options = _Options(enabled, cycle);

  @override
  Event<Object> get onDidBlurEditorWidget => _blur.event;
  @override
  Event<Object> get onDidChangeConfiguration => _config.event;
  @override
  Event<Object> get onDidChangeModel => _model.event;
  @override
  Event<Object> get onDidChangeModelLanguage => _lang.event;
  @override
  Event<Object> get onDidChangeCursorSelection => _cursor.event;
  @override
  Event<Object> get onDidChangeModelContent => _content.event;
  @override
  Event<Object> get onDidType => _type.event;

  @override
  bool hasModel() => hasModelFlag;
  @override
  Object? getModel() => hasModelFlag ? <String, Object>{'id': 'm'} : null;
  @override
  Object getPosition() => <String, Object>{'lineNumber': 1, 'column': 2};
  @override
  Object getOption(Object id) =>
      id == EditorOption.parameterHints ? options : Object();
}

class _Providers implements IParameterHintsProviders {
  final Emitter<Object> _change = Emitter<Object>();
  final List<Object> supports;

  _Providers(this.supports);

  @override
  bool has(Object model) => true;
  @override
  Event<Object> get onDidChange => _change.event;
  @override
  List<Object> ordered(Object model) => supports;
}

class _Support {
  final List<String> signatureHelpTriggerCharacters;
  final List<String> signatureHelpRetriggerCharacters;
  _Support(this.signatureHelpTriggerCharacters,
      this.signatureHelpRetriggerCharacters);
}

Object _hints(List<String> labels, int active) => <String, Object?>{
      'signatures': labels.map((String l) => <String, Object?>{'label': l}).toList(),
      'activeSignature': active,
    };

class _Result implements IDisposable {
  final Map<String, Object?> value;
  _Result(this.value);
  @override
  void dispose() {}
}

_Result _result(List<String> labels, int active) =>
    _Result(_hints(labels, active) as Map<String, Object?>);

Future<void> _flush() async {
  for (int i = 0; i < 20; i++) await Future<void>.value();
  await Future<void>.delayed(Duration.zero);
}

Map<String, Object?> _stateJson(ParameterHintsModel m) {
  final ParameterHintState s = m.state;
  if (s.type == ParameterHintStateType.Active) {
    final Map<String, dynamic> hints =
        (s as ParameterHintStateActive).hints as Map<String, dynamic>;
    return <String, Object?>{
      'type': s.type,
      'activeSignature': hints['activeSignature'],
      'signatures': (hints['signatures'] as List<dynamic>)
          .map((dynamic x) => (x as Map)['label'])
          .toList(),
    };
  }
  return <String, Object?>{'type': s.type};
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('parameter hints model replay TS truth', () async {
    final Map<String, Object?> actual = <String, Object?>{};
    final List<_FakeDelayer> delayers = <_FakeDelayer>[];
    Delayer<bool> factory(int delay) {
      final _FakeDelayer d = _FakeDelayer(delay);
      delayers.add(d);
      return d;
    }

    Object? signatureResult;
    final List<Map<String, Object?>> provideCalls = <Map<String, Object?>>[];
    Future<Object?> provide(Object model, Object position, Object context) async {
      final Map<String, Object?> ctx = context as Map<String, Object?>;
      final Map<String, Object?> call = <String, Object?>{
        'triggerKind': ctx['triggerKind'],
      };
      if (ctx['triggerCharacter'] != null) {
        call['triggerCharacter'] = ctx['triggerCharacter'];
      }
      call['isRetrigger'] = ctx['isRetrigger'];
      provideCalls.add(call);
      return signatureResult;
    }

    ParameterHintsModel makeModel(
      _Editor editor, {
      bool cycle = false,
      int delay = 120,
    }) =>
        ParameterHintsModel(
      editor,
      _Providers(<Object>[_Support(<String>['(', ','], <String>[')'])]),
      delay,
      provide,
      factory,
    );

    // Case 1: construct + config disable.
    {
      delayers.clear();
      final _Editor editor = _Editor(enabled: true);
      final ParameterHintsModel model = makeModel(editor);
      actual['construct'] = <String, Object?>{
        'state': _stateJson(model),
        'delayerDelay': delayers[0].defaultDelay,
      };
      editor.options = _Options(false, false);
      editor._config.fire(<Object, Object>{});
      actual['config-disable'] = <String, Object?>{
        'state': _stateJson(model),
        'cancels': delayers[0].cancels,
      };
      model.dispose();
    }

    // Case 2: trigger -> Active.
    {
      delayers.clear();
      provideCalls.clear();
      signatureResult = _result(<String>['f(a)', 'f(b)'], 0);
      final _Editor editor = _Editor(enabled: true);
      final ParameterHintsModel model = makeModel(editor);
      final List<Object?> events = <Object?>[];
      model.onChangedHints((h) => events.add(h == null ? null : (h as Map)['activeSignature']));
      model.trigger(const TriggerContext(SignatureHelpTriggerKind.Invoke));
      final int queued = delayers[0].tasks.length;
      await delayers[0].fire();
      await _flush();
      actual['trigger-active'] = <String, Object?>{
        'queued': queued,
        'state': _stateJson(model),
        'events': events,
        'provideCalls': List<Map<String, Object?>>.from(provideCalls),
        'delayerDelay': delayers[0].defaultDelay,
      };
      model.dispose();
    }

    // Case 3: next/previous with cycle.
    {
      delayers.clear();
      provideCalls.clear();
      signatureResult = _result(<String>['a', 'b'], 0);
      final _Editor editor = _Editor(enabled: true, cycle: true);
      final ParameterHintsModel model = makeModel(editor, cycle: true);
      final List<Object?> events = <Object?>[];
      model.onChangedHints((h) => events.add(h == null ? null : (h as Map)['activeSignature']));
      model.trigger(const TriggerContext(SignatureHelpTriggerKind.Invoke));
      await delayers[0].fire();
      await _flush();
      final List<Object?> afterTrigger = events.toList();
      model.next();
      final List<Object?> afterNext = events.toList();
      model.next();
      final List<Object?> afterNext2 = events.toList();
      model.previous();
      final List<Object?> afterPrev = events.toList();
      actual['next-prev'] = <String, Object?>{
        'afterTrigger': afterTrigger,
        'afterNext': afterNext,
        'afterNext2': afterNext2,
        'afterPrev': afterPrev,
        'state': _stateJson(model),
      };
      model.dispose();
    }

    // Case 4: next without cycle cancels at last.
    {
      delayers.clear();
      provideCalls.clear();
      signatureResult = _result(<String>['a', 'b'], 1);
      final _Editor editor = _Editor(enabled: true, cycle: false);
      final ParameterHintsModel model = makeModel(editor);
      final List<Object?> events = <Object?>[];
      model.onChangedHints((h) => events.add(h == null ? null : (h as Map)['activeSignature']));
      model.trigger(const TriggerContext(SignatureHelpTriggerKind.Invoke));
      await delayers[0].fire();
      await _flush();
      model.next();
      actual['next-no-cycle'] = <String, Object?>{
        'events': events,
        'state': _stateJson(model),
      };
      model.dispose();
    }

    // Case 5: cancel fires undefined.
    {
      delayers.clear();
      provideCalls.clear();
      signatureResult = _result(<String>['a'], 0);
      final _Editor editor = _Editor(enabled: true);
      final ParameterHintsModel model = makeModel(editor);
      final List<Object?> events = <Object?>[];
      model.onChangedHints((h) => events.add(h == null ? 'undef' : h));
      model.trigger(const TriggerContext(SignatureHelpTriggerKind.Invoke));
      await delayers[0].fire();
      await _flush();
      model.cancel();
      actual['cancel'] = <String, Object?>{
        'events': events,
        'state': _stateJson(model),
      };
      model.dispose();
    }

    // Case 6: empty result -> cancel.
    {
      delayers.clear();
      provideCalls.clear();
      signatureResult = _result(<String>[], 0);
      final _Editor editor = _Editor(enabled: true);
      final ParameterHintsModel model = makeModel(editor);
      final List<String> events = <String>[];
      model.onChangedHints((h) => events.add(h == null ? 'undef' : 'hints'));
      model.trigger(const TriggerContext(SignatureHelpTriggerKind.Invoke));
      await delayers[0].fire();
      await _flush();
      actual['empty-result'] = <String, Object?>{
        'events': events,
        'state': _stateJson(model),
      };
      model.dispose();
    }

    // Case 7: onDidType trigger chars.
    {
      delayers.clear();
      provideCalls.clear();
      signatureResult = _result(<String>['a'], 0);
      final _Editor editor = _Editor(enabled: true);
      final ParameterHintsModel model = makeModel(editor);
      editor._type.fire('x');
      final int q1 = delayers[0].tasks.length;
      editor._type.fire('f(');
      final int q2 = delayers[0].tasks.length;
      editor._type.fire('f,');
      final int q3 = delayers[0].tasks.length;
      actual['on-did-type'] = <String, Object?>{'q1': q1, 'q2': q2, 'q3': q3};
      model.dispose();
    }

    for (final String key in truth.keys) {
      expect(
        jsonEncode(actual[key]),
        jsonEncode(truth[key]),
        reason: 'mismatch at $key',
      );
    }
  });
}
