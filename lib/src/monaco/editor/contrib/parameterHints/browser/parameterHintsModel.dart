// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/parameterHints/browser/parameterHintsModel.ts
// Translated 1:1 from TypeScript.
//
// Adaptations (documented inline):
//  * `ICodeEditor` / `LanguageFeatureRegistry` / signature-help types are erased
//    carriers; the member surface read here matches the TS source.
//  * `provideSignatureHelp` and `Delayer` are injectable so the state machine
//    can be replayed deterministically (production uses the real ones).
//  * `ParameterHintState` namespace maps to a State base class + three nested
//    variants.
// ---------------------------------------------------------------------------

import '../../../../base/common/async.dart'
    show CancelablePromise, Delayer, createCancelablePromise;
import '../../../../base/common/cancellation.dart' show CancellationToken;
import '../../../../base/common/errors.dart' show onUnexpectedError;
import '../../../../base/common/event.dart' show Emitter, Event;
import '../../../../base/common/lifecycle.dart'
    show Disposable, IDisposable, MutableDisposable;
import '../../../common/config/editorOptions.dart' show EditorOption;
import '../../../common/core/characterClassifier.dart' show CharacterSet;
import '../../../common/languages.dart' show SignatureHelpTriggerKind;

/// 1:1: `TriggerContext`.
class TriggerContext {
  final int triggerKind;
  final String? triggerCharacter;

  const TriggerContext(this.triggerKind, [this.triggerCharacter]);
}

/// 1:1: `ParameterHintState.Type`.
class ParameterHintStateType {
  const ParameterHintStateType._();
  static const int Default = 0;
  static const int Active = 1;
  static const int Pending = 2;
}

/// 1:1: `ParameterHintState.State`.
abstract class ParameterHintState {
  int get type;
}

/// 1:1: `ParameterHintState.Default`.
class ParameterHintStateDefault implements ParameterHintState {
  @override
  int get type => ParameterHintStateType.Default;
}

/// 1:1: `ParameterHintState.Pending`.
class ParameterHintStatePending implements ParameterHintState {
  @override
  final int type = ParameterHintStateType.Pending;
  final CancelablePromise<dynamic> request;
  final Object? previouslyActiveHints;

  ParameterHintStatePending(this.request, this.previouslyActiveHints);
}

/// 1:1: `ParameterHintState.Active`.
class ParameterHintStateActive implements ParameterHintState {
  @override
  final int type = ParameterHintStateType.Active;
  final Object hints;

  ParameterHintStateActive(this.hints);
}

/// 1:1: the `ICodeEditor` surface used here (opaque carrier).
abstract class IParameterHintsEditor {
  Event<Object> get onDidBlurEditorWidget;
  Event<Object> get onDidChangeConfiguration;
  Event<Object> get onDidChangeModel;
  Event<Object> get onDidChangeModelLanguage;
  Event<Object> get onDidChangeCursorSelection;
  Event<Object> get onDidChangeModelContent;
  Event<Object> get onDidType;
  bool hasModel();
  Object? getModel();
  Object getPosition();
  Object getOption(Object id);
}

/// 1:1: the `LanguageFeatureRegistry` surface used here (opaque carrier).
abstract class IParameterHintsProviders {
  bool has(Object model);
  Event<Object> get onDidChange;
  List<Object> ordered(Object model);
}

/// 1:1: provider hook (ts `provideSignatureHelp`).
typedef SignatureHelpProviderFn = Future<Object?> Function(
  Object model,
  Object position,
  Object context,
);

/// 1:1: read `hints.signatures` (supports the erased Map carrier).
List<dynamic> _signaturesOf(Object hints) {
  if (hints is Map) return (hints['signatures'] as List?) ?? <dynamic>[];
  return (hints as dynamic).signatures as List<dynamic>;
}

int _activeSignatureOf(Object hints) {
  if (hints is Map) return (hints['activeSignature'] as int?) ?? 0;
  return (hints as dynamic).activeSignature as int;
}

/// 1:1: copy `hints` with a new activeSignature (Map carrier).
Object _withActiveSignature(Object hints, int activeSignature) {
  if (hints is Map) {
    final Map<String, dynamic> copy = Map<String, dynamic>.from(hints);
    copy['activeSignature'] = activeSignature;
    return copy;
  }
  // The TS source uses object spread; other carriers can override as needed.
  return <String, dynamic>{
    'signatures': _signaturesOf(hints),
    'activeSignature': activeSignature,
  };
}

/// 1:1: `ParameterHintsModel`.
class ParameterHintsModel extends Disposable {
  static const int DEFAULT_DELAY = 120;

  final Emitter<Object?> _onChangedHints = Emitter<Object?>();
  late final Event<Object?> onChangedHints;

  final IParameterHintsEditor editor;
  final IParameterHintsProviders providers;
  final SignatureHelpProviderFn provideHelp;
  final Delayer<bool> Function(int delay) delayerFactory;

  bool triggerOnType = false;
  ParameterHintState _state = ParameterHintStateDefault();
  final List<TriggerContext> _pendingTriggers = <TriggerContext>[];

  late final MutableDisposable<IDisposable> _lastSignatureHelpResult;
  final CharacterSet triggerChars = CharacterSet();
  final CharacterSet retriggerChars = CharacterSet();

  late final Delayer<bool> throttledDelayer;
  int triggerId = 0;

  ParameterHintsModel(
    this.editor,
    this.providers, [
    int delay = DEFAULT_DELAY,
    SignatureHelpProviderFn? provideHelp,
    Delayer<bool> Function(int delay)? delayerFactory,
  ])   : provideHelp = provideHelp ?? _defaultProvideHelp,
        delayerFactory = delayerFactory ?? ((int d) => Delayer<bool>(d)) {
    onChangedHints = _onChangedHints.event;
    _lastSignatureHelpResult = register(MutableDisposable<IDisposable>());

    throttledDelayer = register(this.delayerFactory(delay));

    register(editor.onDidBlurEditorWidget((_) => cancel()));
    register(editor.onDidChangeConfiguration((_) => onEditorConfigurationChange()));
    register(editor.onDidChangeModel((_) => onModelChanged()));
    register(editor.onDidChangeModelLanguage((_) => onModelChanged()));
    register(editor.onDidChangeCursorSelection((e) => onCursorChange(e)));
    register(editor.onDidChangeModelContent((_) => onModelContentChange()));
    register(providers.onDidChange((_) => onModelChanged()));
    register(editor.onDidType((text) => onDidType(text as String)));

    onEditorConfigurationChange();
    onModelChanged();
  }

  static Future<Object?> _defaultProvideHelp(
    Object model,
    Object position,
    Object context,
  ) async =>
      null;

  ParameterHintState get state => _state;
  set state(ParameterHintState value) {
    if (_state.type == ParameterHintStateType.Pending) {
      (_state as ParameterHintStatePending).request.cancel();
    }
    _state = value;
  }

  void cancel([bool silent = false]) {
    state = ParameterHintStateDefault();
    throttledDelayer.cancel();
    if (!silent) {
      _onChangedHints.fire(null);
    }
  }

  void trigger(TriggerContext context, [int? delay]) {
    final Object? model = editor.getModel();
    if (model == null || !providers.has(model)) return;

    final int id = ++triggerId;
    _pendingTriggers.add(context);
    throttledDelayer
        .trigger(() => doTrigger(id), delay)
        .catchError((Object e) {
          onUnexpectedError(e);
          return false;
        });
  }

  void next() {
    if (state.type != ParameterHintStateType.Active) return;
    final Object hints = (state as ParameterHintStateActive).hints;
    final List<dynamic> signatures = _signaturesOf(hints);
    final int activeSignature = _activeSignatureOf(hints);
    final bool last = (activeSignature % signatures.length) == (signatures.length - 1);
    final bool cycle = (editor.getOption(EditorOption.parameterHints) as dynamic).cycle as bool;

    if ((signatures.length < 2 || last) && !cycle) {
      cancel();
      return;
    }
    updateActiveSignature(last && cycle ? 0 : activeSignature + 1);
  }

  void previous() {
    if (state.type != ParameterHintStateType.Active) return;
    final Object hints = (state as ParameterHintStateActive).hints;
    final List<dynamic> signatures = _signaturesOf(hints);
    final int activeSignature = _activeSignatureOf(hints);
    final bool first = activeSignature == 0;
    final bool cycle = (editor.getOption(EditorOption.parameterHints) as dynamic).cycle as bool;

    if ((signatures.length < 2 || first) && !cycle) {
      cancel();
      return;
    }
    updateActiveSignature(first && cycle ? signatures.length - 1 : activeSignature - 1);
  }

  void updateActiveSignature(int activeSignature) {
    if (state.type != ParameterHintStateType.Active) return;
    final Object hints = _withActiveSignature(
      (state as ParameterHintStateActive).hints,
      activeSignature,
    );
    state = ParameterHintStateActive(hints);
    _onChangedHints.fire(hints);
  }

  Future<bool> doTrigger(int id) async {
    final bool isRetrigger = state.type == ParameterHintStateType.Active ||
        state.type == ParameterHintStateType.Pending;
    final Object? activeSignatureHelp = getLastActiveHints();
    cancel(true);

    if (_pendingTriggers.isEmpty) return false;

    TriggerContext context = _pendingTriggers.first;
    for (int i = 1; i < _pendingTriggers.length; i++) {
      context = mergeTriggerContexts(context, _pendingTriggers[i]);
    }
    _pendingTriggers.clear();

    final Map<String, Object?> triggerContext = <String, Object?>{
      'triggerKind': context.triggerKind,
      'triggerCharacter': context.triggerCharacter,
      'isRetrigger': isRetrigger,
      'activeSignatureHelp': activeSignatureHelp,
    };

    if (!editor.hasModel()) return false;
    final Object model = editor.getModel() as Object;
    final Object position = editor.getPosition();

    state = ParameterHintStatePending(
      createCancelablePromise<dynamic>(
        (CancellationToken token) => provideHelp(model, position, triggerContext),
      ),
      activeSignatureHelp,
    );

    try {
      final Object? result = await (state as ParameterHintStatePending).request;
      if (id != triggerId) {
        (result as dynamic)?.dispose();
        return false;
      }
      if (result == null ||
          ((result as dynamic).value == null) ||
          (((result as dynamic).value as Map)['signatures'] as List?)?.isEmpty != false) {
        (result as dynamic)?.dispose();
        _lastSignatureHelpResult.clear();
        cancel();
        return false;
      } else {
        state = ParameterHintStateActive((result as dynamic).value as Object);
        _lastSignatureHelpResult.value = result as IDisposable;
        _onChangedHints.fire((state as ParameterHintStateActive).hints);
        return true;
      }
    } catch (error) {
      if (id == triggerId) {
        state = ParameterHintStateDefault();
      }
      onUnexpectedError(error);
      return false;
    }
  }

  Object? getLastActiveHints() {
    switch (state.type) {
      case ParameterHintStateType.Active:
        return (state as ParameterHintStateActive).hints;
      case ParameterHintStateType.Pending:
        return (state as ParameterHintStatePending).previouslyActiveHints;
      default:
        return null;
    }
  }

  bool get isTriggered =>
      state.type == ParameterHintStateType.Active ||
      state.type == ParameterHintStateType.Pending ||
      throttledDelayer.isTriggered();

  void onModelChanged() {
    cancel();
    triggerChars.clear();
    retriggerChars.clear();
    final Object? model = editor.getModel();
    if (model == null) return;
    for (final Object support in providers.ordered(model)) {
      final dynamic s = support;
      for (final String ch in (s.signatureHelpTriggerCharacters as List<String>?) ?? <String>[]) {
        if (ch.isNotEmpty) {
          final int charCode = ch.codeUnitAt(0);
          triggerChars.add(charCode);
          retriggerChars.add(charCode);
        }
      }
      for (final String ch in (s.signatureHelpRetriggerCharacters as List<String>?) ?? <String>[]) {
        if (ch.isNotEmpty) retriggerChars.add(ch.codeUnitAt(0));
      }
    }
  }

  void onDidType(String text) {
    if (!triggerOnType) return;
    final int lastCharIndex = text.length - 1;
    final int triggerCharCode = text.codeUnitAt(lastCharIndex);
    if (triggerChars.has(triggerCharCode) ||
        (isTriggered && retriggerChars.has(triggerCharCode))) {
      trigger(TriggerContext(
        SignatureHelpTriggerKind.TriggerCharacter,
        text.substring(lastCharIndex, lastCharIndex + 1),
      ));
    }
  }

  void onCursorChange(Object e) {
    final dynamic event = e;
    if (event.source == 'mouse') {
      cancel();
    } else if (isTriggered) {
      trigger(const TriggerContext(SignatureHelpTriggerKind.ContentChange));
    }
  }

  void onModelContentChange() {
    if (isTriggered) {
      trigger(const TriggerContext(SignatureHelpTriggerKind.ContentChange));
    }
  }

  void onEditorConfigurationChange() {
    final dynamic opts = editor.getOption(EditorOption.parameterHints);
    triggerOnType = opts.enabled as bool;
    if (!triggerOnType) cancel();
  }

  @override
  void dispose() {
    cancel(true);
    super.dispose();
  }
}

/// 1:1: `mergeTriggerContexts`.
TriggerContext mergeTriggerContexts(TriggerContext previous, TriggerContext current) {
  switch (current.triggerKind) {
    case SignatureHelpTriggerKind.Invoke:
      return current;
    case SignatureHelpTriggerKind.ContentChange:
      return previous;
    case SignatureHelpTriggerKind.TriggerCharacter:
    default:
      return current;
  }
}
