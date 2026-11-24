// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/dialogs/test/common/testDialogService.ts
// Translated 1:1. `implements IDialogService` -> implements IDialogServiceType
// (Dart const/interface name clash convention from dialogs.dart). Structural
// result objects ({confirmed}, {result}, {confirmed, values}) and inline prompt
// literals -> concrete carrier classes implementing the real dialogs.dart
// interfaces. `Event.None` -> `eventNone`. `declare _serviceBrand` ->
// `Object? get _serviceBrand => null`.
// Runtime truth: tool/ts2dart/_batch145_truth.cjs (real testDialogService.ts
// + recursive real deps event/severity).
// ---------------------------------------------------------------------------

import 'dart:async' show Future;

import '../../../../base/common/cancellation.dart' show CancellationToken;
import '../../../../base/common/event.dart' show Event, eventNone;
import '../../../../base/common/severity.dart' show Severity;
import '../../common/dialogs.dart'
    show
        ICheckbox,
        ICheckboxResult,
        IConfirmation,
        IConfirmationResult,
        IDialogServiceType,
        IInput,
        IInputResult,
        IPrompt,
        IPromptBaseButton,
        IPromptButton,
        IPromptCancelButton,
        IPromptResult,
        IPromptResultWithCancel,
        IPromptWithCustomCancel,
        IPromptWithDefaultCancel;

/// 1:1: `class TestDialogService implements IDialogService`
class TestDialogService implements IDialogServiceType {
  TestDialogService([
    this._defaultConfirmResult,
    this._defaultPromptResult,
  ]);

  final IConfirmationResult? _defaultConfirmResult;
  final IPromptResult<Object?>? _defaultPromptResult;

  // `_serviceBrand` is library-private in dialogs.dart (TS `declare` only, no
  // runtime member); it is intentionally not re-declared here.
  @override
  bool get hasDialog => false;

  @override
  Event<void> get onWillShowDialog => eventNone;

  @override
  Event<void> get onDidShowDialog => eventNone;

  IConfirmationResult? _confirmResult;

  /// 1:1: `setConfirmResult(result)`
  void setConfirmResult(IConfirmationResult result) {
    _confirmResult = result;
  }

  @override
  Future<IConfirmationResult> confirm(IConfirmation confirmation) async {
    final IConfirmationResult? preset = _confirmResult;
    if (preset != null) {
      _confirmResult = null;
      return preset;
    }
    return _defaultConfirmResult ?? _ConfirmationResult(false);
  }

  @override
  Future<IPromptResult<T>> prompt<T>(IPrompt<T> prompt) async {
    final Object? preset = _defaultPromptResult;
    if (preset != null) {
      return preset as IPromptResult<T>;
    }
    final List<IPromptBaseButton<T>> promptButtons =
        <IPromptBaseButton<T>>[...(prompt.buttons ?? <IPromptButton<T>>[])];
    final Object? cb = prompt.cancelButton;
    if (cb != null && cb is! String && cb is! bool) {
      promptButtons.add(cb as IPromptCancelButton<T>);
    }
    final Object? result = promptButtons.isNotEmpty
        ? await promptButtons.first.run(_CheckboxResult(false))
        : null;
    return _PromptResult<T>(result as T?);
  }

  @override
  Future<IPromptResultWithCancel<T>> promptWithCancel<T>(
      IPromptWithCustomCancel<T> request) async {
    final IPromptResult<T> res = await prompt(request as IPrompt<T>);
    return _PromptResultWithCancel<T>(res.result as T);
  }

  @override
  Future<IPromptResult<T>> promptWithDefaultCancel<T>(
      IPromptWithDefaultCancel<T> request) async {
    return prompt(request as IPrompt<T>);
  }

  @override
  Future<void> info(String message, [String? detail]) async {
    await prompt(_PromptCarrier<Object?>(
      type: Severity.Info,
      message: message,
      detail: detail,
    ));
  }

  @override
  Future<void> warn(String message, [String? detail]) async {
    await prompt(_PromptCarrier<Object?>(
      type: Severity.Warning,
      message: message,
      detail: detail,
    ));
  }

  @override
  Future<void> error(String message, [String? detail]) async {
    await prompt(_PromptCarrier<Object?>(
      type: Severity.Error,
      message: message,
      detail: detail,
    ));
  }

  @override
  Future<IInputResult> input(IInput input) async =>
      _InputResult(true, <String>[]);

  @override
  Future<void> about() async {}
}

// ---- structural carriers (JS object literals / inline prompt options) ----

class _CheckboxResult implements ICheckboxResult {
  _CheckboxResult(this.checkboxChecked);
  @override
  final bool? checkboxChecked;
}

class _ConfirmationResult implements IConfirmationResult {
  _ConfirmationResult(this.confirmed, [this.checkboxChecked]);
  @override
  final bool confirmed;
  @override
  final bool? checkboxChecked;
}

class _InputResult implements IInputResult {
  _InputResult(this.confirmed, this.values, [this.checkboxChecked]);
  @override
  final bool confirmed;
  @override
  final List<String> values;
  @override
  final bool? checkboxChecked;
}

class _PromptResult<T> implements IPromptResult<T> {
  _PromptResult(this.result, [this.checkboxChecked]);
  @override
  final T? result;
  @override
  final bool? checkboxChecked;
}

class _PromptResultWithCancel<T> implements IPromptResultWithCancel<T> {
  _PromptResultWithCancel(this.result, [this.checkboxChecked]);
  @override
  final T result;
  @override
  final bool? checkboxChecked;
}

/// 1:1: inline `{ type, message, detail }` passed by info/warn/error.
class _PromptCarrier<T> implements IPrompt<T> {
  _PromptCarrier({this.type, required this.message, this.detail});

  @override
  final Object? type;
  @override
  final String message;
  @override
  final Object? detail;
  @override
  String? get title => null;
  @override
  ICheckbox? get checkbox => null;
  @override
  Object? get custom => null;
  @override
  CancellationToken? get token => null;
  @override
  List<IPromptButton<T>>? get buttons => null;
  @override
  Object? get cancelButton => null;
}
