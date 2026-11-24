// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/dialogs/common/dialogs.ts
// Translated 1:1. Interfaces -> abstract classes; `IDialogService` /
// `IFileDialogService` decorators keep the const name and their interface gets
// a `Type` suffix (const/interface name clash). `const enum ConfirmResult` and
// private `enum DialogKind` -> classes of static const ints. `DialogType` union
// -> String. Promise<T>|T carrier -> FutureOr<T>; `instanceof Promise` ->
// `is Future`. JS truthiness of `if (x)` -> `_jsTruthy`. Runtime truth:
// tool/ts2dart/_batch143_truth.cjs (real dialogs/severity/nls/uri/resources).
// ---------------------------------------------------------------------------

import 'dart:async' show Future, FutureOr;

import '../../../base/common/cancellation.dart' show CancellationToken;
import '../../../base/common/event.dart' show Event;
import '../../../base/common/htmlContent.dart' show IMarkdownString;
import '../../../base/common/resources.dart' show basename;
import '../../../base/common/severity.dart' show Severity;
import '../../../base/common/themables.dart' show ThemeIcon;
import '../../../base/common/uri.dart' show URI;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../../telemetry/common/telemetry.dart' show ITelemetryData;
import '../../../nls.dart' show ILocalizeInfo, localize;

/// 1:1 JS truthiness — `if (x)` for the `unknown`-ish operands below.
bool _jsTruthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// 1:1: `export interface IDialogArgs`
abstract class IDialogArgs {
  IConfirmDialogArgs? get confirmArgs;
  IInputDialogArgs? get inputArgs;
  IPromptDialogArgs? get promptArgs;
}

/// 1:1: `export interface IBaseDialogOptions`
abstract class IBaseDialogOptions {
  Object? get type; // Severity (num) | DialogType (String)
  String? get title;
  String get message;
  Object? get detail; // String | IMarkdownString
  ICheckbox? get checkbox;
  Object? get custom; // bool | ICustomDialogOptions
  CancellationToken? get token;
}

/// 1:1: `export interface IConfirmDialogArgs`
abstract class IConfirmDialogArgs {
  IConfirmation get confirmation;
}

/// 1:1: `export interface IConfirmation extends IBaseDialogOptions`
abstract class IConfirmation implements IBaseDialogOptions {
  String? get primaryButton;
  String? get cancelButton;
}

/// 1:1: `export interface IConfirmationResult extends ICheckboxResult`
abstract class IConfirmationResult implements ICheckboxResult {
  bool get confirmed;
}

/// 1:1: `export interface IInputDialogArgs`
abstract class IInputDialogArgs {
  IInput get input;
}

/// 1:1: `export interface IInput extends IConfirmation`
abstract class IInput implements IConfirmation {
  List<IInputElement> get inputs;
}

/// 1:1: `export interface IInputElement`
abstract class IInputElement {
  String? get type; // 'text' | 'password'
  String? get value;
  String? get placeholder;
}

/// 1:1: `export interface IInputResult extends IConfirmationResult`
abstract class IInputResult implements IConfirmationResult {
  List<String>? get values;
}

/// 1:1: `export interface IPromptDialogArgs`
abstract class IPromptDialogArgs {
  IPrompt<Object?> get prompt;
}

/// 1:1: `export interface IPromptBaseButton<T>`
abstract class IPromptBaseButton<T> {
  FutureOr<T> run(ICheckboxResult checkbox);
}

/// 1:1: `export interface IPromptButton<T> extends IPromptBaseButton<T>`
abstract class IPromptButton<T> implements IPromptBaseButton<T> {
  String get label;
}

/// 1:1: `export interface IPromptCancelButton<T> extends IPromptBaseButton<T>`
abstract class IPromptCancelButton<T> implements IPromptBaseButton<T> {
  String? get label;
}

/// 1:1: `export interface IPrompt<T> extends IBaseDialogOptions`
abstract class IPrompt<T> implements IBaseDialogOptions {
  List<IPromptButton<T>>? get buttons;

  /// true | String | IPromptCancelButton<T>
  Object? get cancelButton;
}

/// 1:1: `export interface IPromptWithCustomCancel<T> extends IPrompt<T>`
abstract class IPromptWithCustomCancel<T> implements IPrompt<T> {
  @override
  IPromptCancelButton<T> get cancelButton;
}

/// 1:1: `export interface IPromptWithDefaultCancel<T> extends IPrompt<T>`
abstract class IPromptWithDefaultCancel<T> implements IPrompt<T> {
  @override
  Object get cancelButton; // true | String
}

/// 1:1: `export interface IPromptResult<T> extends ICheckboxResult`
abstract class IPromptResult<T> implements ICheckboxResult {
  T? get result;
}

/// 1:1: `export interface IPromptResultWithCancel<T> extends IPromptResult<T>`
abstract class IPromptResultWithCancel<T> implements IPromptResult<T> {
  @override
  T get result;
}

/// 1:1: `export interface IAsyncPromptResult<T> extends ICheckboxResult`
abstract class IAsyncPromptResult<T> implements ICheckboxResult {
  Future<T>? get result;
}

/// 1:1: `export interface IAsyncPromptResultWithCancel<T> extends IAsyncPromptResult<T>`
abstract class IAsyncPromptResultWithCancel<T> implements IAsyncPromptResult<T> {
  @override
  Future<T> get result;
}

/// 1:1: `export type IDialogResult = ...`
typedef IDialogResult = Object;
// 1:1: `export type DialogType = 'none' | 'info' | 'error' | 'question' | 'warning'`
typedef DialogType = String;

/// 1:1: `export interface ICheckbox`
abstract class ICheckbox {
  String get label;
  bool? get checked;
}

/// 1:1: `export interface ICheckboxResult`
abstract class ICheckboxResult {
  bool? get checkboxChecked;
}

/// 1:1: `export interface IPickAndOpenOptions`
abstract class IPickAndOpenOptions {
  bool? get forceNewWindow;
  URI? get defaultUri;
  ITelemetryData? get telemetryExtraData;
  List<String>? get availableFileSystems;
  String? get remoteAuthority; // String | null
}

/// 1:1: `export interface FileFilter`
abstract class FileFilter {
  List<String> get extensions;
  String get name;
}

/// 1:1: `export interface ISaveDialogOptions`
abstract class ISaveDialogOptions {
  String? get title;
  URI? get defaultUri;
  List<FileFilter>? get filters;

  /// { withMnemonic, withoutMnemonic } | String
  Object? get saveLabel;
  List<String>? get availableFileSystems;
}

/// 1:1: `export interface IOpenDialogOptions`
abstract class IOpenDialogOptions {
  String? get title;
  URI? get defaultUri;

  /// { withMnemonic, withoutMnemonic } | String
  Object? get openLabel;
  bool? get canSelectFiles;
  bool? get canSelectFolders;
  bool? get canSelectMany;
  List<FileFilter>? get filters;
  List<String>? get availableFileSystems;
}

/// 1:1: `export const IDialogService = createDecorator<IDialogService>('dialogService')`
final ServiceIdentifier<IDialogServiceType> IDialogService =
    createDecorator<IDialogServiceType>('dialogService');

/// 1:1: `export interface ICustomDialogOptions`
abstract class ICustomDialogOptions {
  List<String>? get buttonDetails;
  List<ICustomDialogMarkdown>? get markdownDetails;
  List<String>? get classes;
  ThemeIcon? get icon;
  bool? get disableCloseAction;
  String? get alignment; // 'horizontal' | 'vertical'
}

/// 1:1: `export interface ICustomDialogMarkdown`
abstract class ICustomDialogMarkdown {
  IMarkdownString get markdown;
  List<String>? get classes;
  Future<bool> Function(String link)? get actionHandler;
}

/// 1:1: `export interface IDialogHandler`
abstract class IDialogHandler {
  Future<IConfirmationResult> confirm(IConfirmation confirmation);
  Future<IAsyncPromptResult<T>> prompt<T>(IPrompt<T> prompt);
  Future<IInputResult> input(IInput input);
  Future<void> about(String title, String details, String detailsToCopy);
}

/// 1:1: `enum DialogKind { Confirmation = 1, Prompt, Input }`
class DialogKind {
  static const int Confirmation = 1;
  static const int Prompt = 2;
  static const int Input = 3;
}

/// 1:1: `export abstract class AbstractDialogHandler implements IDialogHandler`
abstract class AbstractDialogHandler implements IDialogHandler {
  List<String> getConfirmationButtons(IConfirmation dialog) =>
      _getButtons(dialog, DialogKind.Confirmation);

  List<String> getPromptButtons(IPrompt<Object?> dialog) =>
      _getButtons(dialog, DialogKind.Prompt);

  List<String> getInputButtons(IInput dialog) =>
      _getButtons(dialog, DialogKind.Input);

  List<String> _getButtons(Object dialog, int kind) {
    // We put buttons in the order of "default" button first and "cancel"
    // button last.
    final List<String> buttons = <String>[];

    switch (kind) {
      case DialogKind.Confirmation: {
        final IConfirmation confirmationDialog = dialog as IConfirmation;
        final String? primary = confirmationDialog.primaryButton;
        if (_jsTruthy(primary)) {
          buttons.add(primary!);
        } else {
          buttons.add(localize(
              ILocalizeInfo('yesButton', <String>['&& denotes a mnemonic']),
              '&&Yes'));
        }
        final String? cancel = confirmationDialog.cancelButton;
        if (_jsTruthy(cancel)) {
          buttons.add(cancel!);
        } else {
          buttons.add(localize('cancelButton', 'Cancel'));
        }
        break;
      }
      case DialogKind.Prompt: {
        final IPrompt<Object?> promptDialog = dialog as IPrompt<Object?>;
        final List<IPromptButton<Object?>>? pbs = promptDialog.buttons;
        if (pbs != null && pbs.length > 0) {
          buttons.addAll(pbs.map((button) => button.label));
        }
        final Object? cb = promptDialog.cancelButton;
        if (_jsTruthy(cb)) {
          if (identical(cb, true)) {
            buttons.add(localize('cancelButton', 'Cancel'));
          } else if (cb is String) {
            buttons.add(cb);
          } else {
            final String? label = (cb as IPromptCancelButton<Object?>).label;
            if (_jsTruthy(label)) {
              buttons.add(label!);
            } else {
              buttons.add(localize('cancelButton', 'Cancel'));
            }
          }
        }
        if (buttons.isEmpty) {
          buttons.add(localize(
              ILocalizeInfo('okButton', <String>['&& denotes a mnemonic']),
              '&&OK'));
        }
        break;
      }
      case DialogKind.Input: {
        final IInput inputDialog = dialog as IInput;
        final String? primary = inputDialog.primaryButton;
        if (_jsTruthy(primary)) {
          buttons.add(primary!);
        } else {
          buttons.add(localize(
              ILocalizeInfo('okButton', <String>['&& denotes a mnemonic']),
              '&&OK'));
        }
        final String? cancel = inputDialog.cancelButton;
        if (_jsTruthy(cancel)) {
          buttons.add(cancel!);
        } else {
          buttons.add(localize('cancelButton', 'Cancel'));
        }
        break;
      }
    }
    return buttons;
  }

  /// 1:1: `protected getDialogType(type: Severity | DialogType | undefined)`
  String? getDialogType(Object? type) {
    if (type is String) {
      return type;
    }
    if (type is num) {
      return type == Severity.Info
          ? 'info'
          : type == Severity.Error
              ? 'error'
              : type == Severity.Warning
                  ? 'warning'
                  : 'none';
    }
    return null;
  }

  /// 1:1: `protected getPromptResult<T>(prompt, buttonIndex, checkboxChecked)`
  IAsyncPromptResult<T> getPromptResult<T>(
      IPrompt<T> prompt, int buttonIndex, bool? checkboxChecked) {
    final List<IPromptBaseButton<T>> promptButtons =
        <IPromptBaseButton<T>>[...(prompt.buttons ?? <IPromptButton<T>>[])];
    final Object? cb = prompt.cancelButton;
    if (_jsTruthy(cb) && cb is! String && cb is! bool) {
      promptButtons.add(cb as IPromptCancelButton<T>);
    }

    final ICheckboxResult checkbox = _CheckboxResult(checkboxChecked);
    Object? result;
    if (buttonIndex >= 0 && buttonIndex < promptButtons.length) {
      result = promptButtons[buttonIndex].run(checkbox);
    }
    final Future<T> future = result is Future<T>
        ? result
        : Future<T>.value(result as T?);
    return _AsyncPromptResult<T>(future, checkboxChecked);
  }

  @override
  Future<IConfirmationResult> confirm(IConfirmation confirmation);

  @override
  Future<IInputResult> input(IInput input);

  @override
  Future<IAsyncPromptResult<T>> prompt<T>(IPrompt<T> prompt);

  @override
  Future<void> about(String title, String details, String detailsToCopy);
}

class _CheckboxResult implements ICheckboxResult {
  _CheckboxResult(this.checkboxChecked);
  @override
  final bool? checkboxChecked;
}

class _AsyncPromptResult<T> implements IAsyncPromptResult<T> {
  _AsyncPromptResult(this.result, this.checkboxChecked);
  @override
  final Future<T> result;
  @override
  final bool? checkboxChecked;
}

/// 1:1: `export interface IDialogService`
abstract class IDialogServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;
  bool get hasDialog;
  Event<void> get onWillShowDialog;
  Event<void> get onDidShowDialog;
  Future<IConfirmationResult> confirm(IConfirmation confirmation);

  Future<IPromptResult<T>> prompt<T>(IPrompt<T> prompt);
  Future<IPromptResultWithCancel<T>> promptWithCancel<T>(
      IPromptWithCustomCancel<T> prompt);
  Future<IPromptResult<T>> promptWithDefaultCancel<T>(
      IPromptWithDefaultCancel<T> prompt);

  Future<IInputResult> input(IInput input);
  Future<void> info(String message, [String? detail]);
  Future<void> warn(String message, [String? detail]);
  Future<void> error(String message, [String? detail]);
  Future<void> about();
}

/// 1:1: `export const IFileDialogService = createDecorator(...)`
final ServiceIdentifier<IFileDialogServiceType> IFileDialogService =
    createDecorator<IFileDialogServiceType>('fileDialogService');

/// 1:1: `export interface IFileDialogService`
abstract class IFileDialogServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;
  Future<URI> defaultFilePath([String? schemeFilter]);
  Future<URI> defaultFolderPath([String? schemeFilter]);
  Future<URI> defaultWorkspacePath([String? schemeFilter]);
  Future<void> pickFileFolderAndOpen(IPickAndOpenOptions options);
  Future<void> pickFileAndOpen(IPickAndOpenOptions options);
  Future<void> pickFolderAndOpen(IPickAndOpenOptions options);
  Future<void> pickWorkspaceAndOpen(IPickAndOpenOptions options);
  Future<URI?> pickFileToSave(URI defaultUri, [List<String>? availableFileSystems]);
  Future<URI> preferredHome([String? schemeFilter]);
  Future<URI?> showSaveDialog(ISaveDialogOptions options);
  Future<ConfirmResult> showSaveConfirm(List<Object> fileNamesOrResources); // String | URI
  Future<List<URI>?> showOpenDialog(IOpenDialogOptions options);
}

/// 1:1: `export const enum ConfirmResult { SAVE, DONT_SAVE, CANCEL }`
class ConfirmResult {
  static const int SAVE = 0;
  static const int DONT_SAVE = 1;
  static const int CANCEL = 2;
}

const int MAX_CONFIRM_FILES = 10;

/// 1:1: `export function getFileNamesMessage(fileNamesOrResources)`
String getFileNamesMessage(List<Object> fileNamesOrResources) {
  final List<String> message = <String>[];
  final int limit = fileNamesOrResources.length < MAX_CONFIRM_FILES
      ? fileNamesOrResources.length
      : MAX_CONFIRM_FILES;
  for (int i = 0; i < limit; i++) {
    final Object fileNameOrResource = fileNamesOrResources[i];
    message.add(fileNameOrResource is String
        ? fileNameOrResource
        : basename(fileNameOrResource as URI));
  }

  if (fileNamesOrResources.length > MAX_CONFIRM_FILES) {
    final int extra = fileNamesOrResources.length - MAX_CONFIRM_FILES;
    if (extra == 1) {
      message.add(localize('moreFile', '...1 additional file not shown'));
    } else {
      message.add(localize(
          'moreFiles', '...{0} additional files not shown', <Object?>[extra]));
    }
  }

  message.add('');
  return message.join('\n');
}

/// 1:1: `export interface INativeOpenDialogOptions`
abstract class INativeOpenDialogOptions {
  bool? get forceNewWindow;
  String? get defaultPath;
  String? get telemetryEventName;
  ITelemetryData? get telemetryExtraData;
}
