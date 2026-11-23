// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/accessibilitySignal/browser/accessibilitySignalService.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// JS carriers:
//   - `HTMLAudioElement` -> `AudioElementLike` + injectable `audioFactoryProvider`.
//   - `FileAccess.asBrowserUri(...).toString(true)` -> `audioUrlProvider`.
//   - `setTimeout` -> `dart:async.Timer`.
//   - `Symbol('AcknowledgeDocCommentsToken')` -> identity `Object()` token.
//   - `Math.random()` -> `randomProvider`.
// ---------------------------------------------------------------------------

import 'dart:async';
import 'dart:math' as math;

import '../../../base/common/cache.dart' show CachedFunction, ICacheOptions;
import '../../../base/common/equals.dart' show getStructuralKey;
import '../../../base/common/event.dart'
    show Event, IValueWithChangeEvent;
import '../../../base/common/lifecycle.dart'
    show Disposable, DisposableStore, IDisposable, toDisposable;
import '../../../base/common/network.dart' show FileAccess;
import '../../../base/common/observable.dart'
    show
        IObservable,
        derived,
        observableFromEvent,
        recomputeInitiallyAndOnChange,
        ValueWithChangeEventFromObservable;
import '../../../nls.dart' show localize;
import '../../accessibility/common/accessibility.dart'
    show IAccessibilityServiceType;
import '../../configuration/common/configuration.dart'
    show IConfigurationServiceType;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../../observable/common/platformObservableUtils.dart'
    show observableConfigValue;
import '../../telemetry/common/telemetry.dart'
    show ITelemetryServiceType;

/// 1:1: `export const IAccessibilitySignalService = createDecorator<...>`.
final ServiceIdentifier<IAccessibilitySignalServiceType>
    IAccessibilitySignalService =
    createDecorator<IAccessibilitySignalServiceType>('accessibilitySignalService');

/// 1:1: `export interface IAccessibilitySignalService`.
abstract class IAccessibilitySignalServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  Future<void> playSignal(AccessibilitySignal signal,
      [IAccessbilitySignalOptions? options]);
  Future<void> playSignals(List<Object> signals);
  IDisposable playSignalLoop(AccessibilitySignal signal, num milliseconds);
  IValueWithChangeEvent<bool> getEnabledState(
      AccessibilitySignal signal, bool userGesture,
      [String? modality]);
  num getDelayMs(
      AccessibilitySignal signal, String modality, String mode);
  Future<void> playSound(
      Sound sound, bool allowManyInParallel, Object token);
  bool isSoundEnabled(AccessibilitySignal signal, [bool? userGesture]);
  bool isAnnouncementEnabled(AccessibilitySignal signal, [bool? userGesture]);
  Event<void> onSoundEnabledChanged(AccessibilitySignal signal);
}

/// 1:1: `export const AcknowledgeDocCommentsToken = Symbol(...)`.
final Object AcknowledgeDocCommentsToken = Object();

/// 1:1: `export type AccessibilityModality = 'sound' | 'announcement'`.
class AccessibilityModality {
  static const String sound = 'sound';
  static const String announcement = 'announcement';
}

/// 1:1: `export interface IAccessbilitySignalOptions`.
class IAccessbilitySignalOptions {
  IAccessbilitySignalOptions({
    this.allowManyInParallel,
    this.modality,
    this.source,
    this.userGesture,
    this.customAlertMessage,
  });

  final bool? allowManyInParallel;
  final String? modality;
  final String? source;
  final bool? userGesture;
  final String? customAlertMessage;
}

/// 1:1: `type EnabledState`.
class EnabledState {
  static const String on = 'on';
  static const String off = 'off';
  static const String auto = 'auto';
  static const String userGesture = 'userGesture';
  static const String always = 'always';
  static const String never = 'never';
}

/// 1:1: `checkEnabledState(state, getScreenReaderAttached, isTriggeredByUserGesture)`.
bool checkEnabledState(String state, bool Function() getScreenReaderAttached,
        bool isTriggeredByUserGesture) =>
    state == EnabledState.on ||
    state == EnabledState.always ||
    (state == EnabledState.auto && getScreenReaderAttached()) ||
    (state == EnabledState.userGesture && isTriggeredByUserGesture);

/// 1:1: injectable `new Audio(url)`.
abstract class AudioElementLike {
  double get volume;
  set volume(double value);
  num get currentTime;
  set currentTime(num value);
  void setOnEnded(void Function() callback);
  void setOnError(void Function(Object error) callback);
  Future<void> play();
}

AudioElementLike Function(String url)? audioFactoryProvider;

/// 1:1: `FileAccess.asBrowserUri(...).toString(true)`.
String Function(String fileName)? audioUrlProvider;

String _audioUrl(Sound sound) {
  final String Function(String)? provider = audioUrlProvider;
  if (provider != null) return provider(sound.fileName);
  return FileAccess.asBrowserUri(
          'vs/platform/accessibilitySignal/browser/media/${sound.fileName}')
      .toString(true);
}

/// 1:1: `Math.random()`.
double Function() randomProvider = () => math.Random().nextDouble();

/// 1:1: `export class Sound`.
class Sound {
  Sound._(this.fileName);

  static Sound register(String fileName) => Sound._(fileName);

  final String fileName;

  static final Sound error = register('error.mp3');
  static final Sound warning = register('warning.mp3');
  static final Sound success = register('success.mp3');
  static final Sound foldedArea = register('foldedAreas.mp3');
  static final Sound break_ = register('break.mp3');
  static final Sound quickFixes = register('quickFixes.mp3');
  static final Sound taskCompleted = register('taskCompleted.mp3');
  static final Sound taskFailed = register('taskFailed.mp3');
  static final Sound terminalBell = register('terminalBell.mp3');
  static final Sound diffLineInserted = register('diffLineInserted.mp3');
  static final Sound diffLineDeleted = register('diffLineDeleted.mp3');
  static final Sound diffLineModified = register('diffLineModified.mp3');
  static final Sound requestSent = register('requestSent.mp3');
  static final Sound responseReceived1 = register('responseReceived1.mp3');
  static final Sound responseReceived2 = register('responseReceived2.mp3');
  static final Sound responseReceived3 = register('responseReceived3.mp3');
  static final Sound responseReceived4 = register('responseReceived4.mp3');
  static final Sound clear = register('clear.mp3');
  static final Sound save = register('save.mp3');
  static final Sound format = register('format.mp3');
  static final Sound voiceRecordingStarted =
      register('voiceRecordingStarted.mp3');
  static final Sound voiceRecordingStopped = register('voiceRecordingStopped.mp3');
  static final Sound progress = register('progress.mp3');
  static final Sound chatEditModifiedFile =
      register('chatEditModifiedFile.mp3');
  static final Sound editsKept = register('editsKept.mp3');
  static final Sound editsUndone = register('editsUndone.mp3');
  static final Sound nextEditSuggestion = register('nextEditSuggestion.mp3');
  static final Sound terminalCommandSucceeded =
      register('terminalCommandSucceeded.mp3');
  static final Sound chatUserActionRequired =
      register('chatUserActionRequired.mp3');
  static final Sound codeActionTriggered = register('codeActionTriggered.mp3');
  static final Sound codeActionApplied = register('codeActionApplied.mp3');
  static final Sound confetti = register('confetti.mp3');
}

/// 1:1: `export class SoundSource`.
class SoundSource {
  SoundSource(this.randomOneOf);

  final List<Sound> randomOneOf;

  Sound getSound([bool deterministic = false]) {
    if (deterministic || randomOneOf.length == 1) return randomOneOf.first;
    final int index =
        (randomProvider() * randomOneOf.length).floor();
    return randomOneOf[index];
  }
}

/// 1:1: `export class AccessibilitySignal`.
class AccessibilitySignal {
  AccessibilitySignal._(
    this.sound,
    this.name,
    this.legacySoundSettingsKey,
    this.settingsKey,
    this.legacyAnnouncementSettingsKey,
    this.announcementMessage, [
    this.managesOwnEnablement = false,
  ]);

  final SoundSource sound;
  final String name;
  final String? legacySoundSettingsKey;
  final String settingsKey;
  final String? legacyAnnouncementSettingsKey;
  final String? announcementMessage;
  final bool managesOwnEnablement;

  static final Set<AccessibilitySignal> _signals =
      <AccessibilitySignal>{};

  static AccessibilitySignal register({
    required String name,
    required Object sound,
    String? legacySoundSettingsKey,
    required String settingsKey,
    String? legacyAnnouncementSettingsKey,
    String? announcementMessage,
    String? delaySettingsKey,
    bool managesOwnEnablement = false,
  }) {
    final SoundSource source = sound is SoundSource
        ? sound
        : SoundSource(<Sound>[sound as Sound]);
    final AccessibilitySignal signal = AccessibilitySignal._(
      source,
      name,
      legacySoundSettingsKey,
      settingsKey,
      legacyAnnouncementSettingsKey,
      announcementMessage,
      managesOwnEnablement,
    );
    _signals.add(signal);
    return signal;
  }

  static List<AccessibilitySignal> get allAccessibilitySignals =>
      _signals.toList();

  static final AccessibilitySignal errorAtPosition = register(
    name: localize('accessibilitySignals.positionHasError.name', 'Error at Position'),
    sound: Sound.error,
    announcementMessage: localize('accessibility.signals.positionHasError', 'Error'),
    settingsKey: 'accessibility.signals.positionHasError',
    delaySettingsKey: 'accessibility.signalOptions.delays.errorAtPosition',
  );
  static final AccessibilitySignal warningAtPosition = register(
    name: localize('accessibilitySignals.positionHasWarning.name', 'Warning at Position'),
    sound: Sound.warning,
    announcementMessage: localize('accessibility.signals.positionHasWarning', 'Warning'),
    settingsKey: 'accessibility.signals.positionHasWarning',
    delaySettingsKey: 'accessibility.signalOptions.delays.warningAtPosition',
  );
  static final AccessibilitySignal errorOnLine = register(
    name: localize('accessibilitySignals.lineHasError.name', 'Error on Line'),
    sound: Sound.error,
    legacySoundSettingsKey: 'audioCues.lineHasError',
    legacyAnnouncementSettingsKey: 'accessibility.alert.error',
    announcementMessage: localize('accessibility.signals.lineHasError', 'Error on Line'),
    settingsKey: 'accessibility.signals.lineHasError',
  );
  static final AccessibilitySignal warningOnLine = register(
    name: localize('accessibilitySignals.lineHasWarning.name', 'Warning on Line'),
    sound: Sound.warning,
    legacySoundSettingsKey: 'audioCues.lineHasWarning',
    legacyAnnouncementSettingsKey: 'accessibility.alert.warning',
    announcementMessage: localize('accessibility.signals.lineHasWarning', 'Warning on Line'),
    settingsKey: 'accessibility.signals.lineHasWarning',
  );
  static final AccessibilitySignal foldedArea = register(
    name: localize('accessibilitySignals.lineHasFoldedArea.name', 'Folded Area on Line'),
    sound: Sound.foldedArea,
    legacySoundSettingsKey: 'audioCues.lineHasFoldedArea',
    legacyAnnouncementSettingsKey: 'accessibility.alert.foldedArea',
    announcementMessage: localize('accessibility.signals.lineHasFoldedArea', 'Folded'),
    settingsKey: 'accessibility.signals.lineHasFoldedArea',
  );
  static final AccessibilitySignal break_ = register(
    name: localize('accessibilitySignals.lineHasBreakpoint.name', 'Breakpoint on Line'),
    sound: Sound.break_,
    legacySoundSettingsKey: 'audioCues.lineHasBreakpoint',
    legacyAnnouncementSettingsKey: 'accessibility.alert.breakpoint',
    announcementMessage: localize('accessibility.signals.lineHasBreakpoint', 'Breakpoint'),
    settingsKey: 'accessibility.signals.lineHasBreakpoint',
  );
  static final AccessibilitySignal inlineSuggestion = register(
    name: localize('accessibilitySignals.lineHasInlineSuggestion.name', 'Inline Suggestion on Line'),
    sound: Sound.quickFixes,
    legacySoundSettingsKey: 'audioCues.lineHasInlineSuggestion',
    settingsKey: 'accessibility.signals.lineHasInlineSuggestion',
  );
  static final AccessibilitySignal nextEditSuggestion = register(
    name: localize('accessibilitySignals.nextEditSuggestion.name', 'Next Edit Suggestion on Line'),
    sound: Sound.nextEditSuggestion,
    legacySoundSettingsKey: 'audioCues.nextEditSuggestion',
    announcementMessage: localize('accessibility.signals.nextEditSuggestion', 'Next Edit Suggestion'),
    settingsKey: 'accessibility.signals.nextEditSuggestion',
  );
  static final AccessibilitySignal terminalQuickFix = register(
    name: localize('accessibilitySignals.terminalQuickFix.name', 'Terminal Quick Fix'),
    sound: Sound.quickFixes,
    legacySoundSettingsKey: 'audioCues.terminalQuickFix',
    legacyAnnouncementSettingsKey: 'accessibility.alert.terminalQuickFix',
    announcementMessage: localize('accessibility.signals.terminalQuickFix', 'Quick Fix'),
    settingsKey: 'accessibility.signals.terminalQuickFix',
  );
  static final AccessibilitySignal onDebugBreak = register(
    name: localize('accessibilitySignals.onDebugBreak.name', 'Debugger Stopped on Breakpoint'),
    sound: Sound.break_,
    legacySoundSettingsKey: 'audioCues.onDebugBreak',
    legacyAnnouncementSettingsKey: 'accessibility.alert.onDebugBreak',
    announcementMessage: localize('accessibility.signals.onDebugBreak', 'Breakpoint'),
    settingsKey: 'accessibility.signals.onDebugBreak',
  );
  static final AccessibilitySignal noInlayHints = register(
    name: localize('accessibilitySignals.noInlayHints', 'No Inlay Hints on Line'),
    sound: Sound.error,
    legacySoundSettingsKey: 'audioCues.noInlayHints',
    legacyAnnouncementSettingsKey: 'accessibility.alert.noInlayHints',
    announcementMessage: localize('accessibility.signals.noInlayHints', 'No Inlay Hints'),
    settingsKey: 'accessibility.signals.noInlayHints',
  );
  static final AccessibilitySignal taskCompleted = register(
    name: localize('accessibilitySignals.taskCompleted', 'Task Completed'),
    sound: Sound.taskCompleted,
    legacySoundSettingsKey: 'audioCues.taskCompleted',
    legacyAnnouncementSettingsKey: 'accessibility.alert.taskCompleted',
    announcementMessage: localize('accessibility.signals.taskCompleted', 'Task Completed'),
    settingsKey: 'accessibility.signals.taskCompleted',
  );
  static final AccessibilitySignal taskFailed = register(
    name: localize('accessibilitySignals.taskFailed', 'Task Failed'),
    sound: Sound.taskFailed,
    legacySoundSettingsKey: 'audioCues.taskFailed',
    legacyAnnouncementSettingsKey: 'accessibility.alert.taskFailed',
    announcementMessage: localize('accessibility.signals.taskFailed', 'Task Failed'),
    settingsKey: 'accessibility.signals.taskFailed',
  );
  static final AccessibilitySignal terminalCommandFailed = register(
    name: localize('accessibilitySignals.terminalCommandFailed', 'Terminal Command Failed'),
    sound: Sound.error,
    legacySoundSettingsKey: 'audioCues.terminalCommandFailed',
    legacyAnnouncementSettingsKey: 'accessibility.alert.terminalCommandFailed',
    announcementMessage: localize('accessibility.signals.terminalCommandFailed', 'Command Failed'),
    settingsKey: 'accessibility.signals.terminalCommandFailed',
  );
  static final AccessibilitySignal terminalCommandSucceeded = register(
    name: localize('accessibilitySignals.terminalCommandSucceeded', 'Terminal Command Succeeded'),
    sound: Sound.terminalCommandSucceeded,
    announcementMessage: localize('accessibility.signals.terminalCommandSucceeded', 'Command Succeeded'),
    settingsKey: 'accessibility.signals.terminalCommandSucceeded',
  );
  static final AccessibilitySignal terminalBell = register(
    name: localize('accessibilitySignals.terminalBell', 'Terminal Bell'),
    sound: Sound.terminalBell,
    legacySoundSettingsKey: 'audioCues.terminalBell',
    legacyAnnouncementSettingsKey: 'accessibility.alert.terminalBell',
    announcementMessage: localize('accessibility.signals.terminalBell', 'Terminal Bell'),
    settingsKey: 'accessibility.signals.terminalBell',
  );
  static final AccessibilitySignal notebookCellCompleted = register(
    name: localize('accessibilitySignals.notebookCellCompleted', 'Notebook Cell Completed'),
    sound: Sound.taskCompleted,
    legacySoundSettingsKey: 'audioCues.notebookCellCompleted',
    legacyAnnouncementSettingsKey: 'accessibility.alert.notebookCellCompleted',
    announcementMessage: localize('accessibility.signals.notebookCellCompleted', 'Notebook Cell Completed'),
    settingsKey: 'accessibility.signals.notebookCellCompleted',
  );
  static final AccessibilitySignal notebookCellFailed = register(
    name: localize('accessibilitySignals.notebookCellFailed', 'Notebook Cell Failed'),
    sound: Sound.taskFailed,
    legacySoundSettingsKey: 'audioCues.notebookCellFailed',
    legacyAnnouncementSettingsKey: 'accessibility.alert.notebookCellFailed',
    announcementMessage: localize('accessibility.signals.notebookCellFailed', 'Notebook Cell Failed'),
    settingsKey: 'accessibility.signals.notebookCellFailed',
  );
  static final AccessibilitySignal diffLineInserted = register(
    name: localize('accessibilitySignals.diffLineInserted', 'Diff Line Inserted'),
    sound: Sound.diffLineInserted,
    legacySoundSettingsKey: 'audioCues.diffLineInserted',
    settingsKey: 'accessibility.signals.diffLineInserted',
  );
  static final AccessibilitySignal diffLineDeleted = register(
    name: localize('accessibilitySignals.diffLineDeleted', 'Diff Line Deleted'),
    sound: Sound.diffLineDeleted,
    legacySoundSettingsKey: 'audioCues.diffLineDeleted',
    settingsKey: 'accessibility.signals.diffLineDeleted',
  );
  static final AccessibilitySignal diffLineModified = register(
    name: localize('accessibilitySignals.diffLineModified', 'Diff Line Modified'),
    sound: Sound.diffLineModified,
    legacySoundSettingsKey: 'audioCues.diffLineModified',
    settingsKey: 'accessibility.signals.diffLineModified',
  );
  static final AccessibilitySignal chatEditModifiedFile = register(
    name: localize('accessibilitySignals.chatEditModifiedFile', 'Chat Edit Modified File'),
    sound: Sound.chatEditModifiedFile,
    announcementMessage: localize('accessibility.signals.chatEditModifiedFile', 'File Modified from Chat Edits'),
    settingsKey: 'accessibility.signals.chatEditModifiedFile',
  );
  static final AccessibilitySignal chatRequestSent = register(
    name: localize('accessibilitySignals.chatRequestSent', 'Chat Request Sent'),
    sound: Sound.requestSent,
    legacySoundSettingsKey: 'audioCues.chatRequestSent',
    legacyAnnouncementSettingsKey: 'accessibility.alert.chatRequestSent',
    announcementMessage: localize('accessibility.signals.chatRequestSent', 'Chat Request Sent'),
    settingsKey: 'accessibility.signals.chatRequestSent',
  );
  static final AccessibilitySignal chatResponseReceived = register(
    name: localize('accessibilitySignals.chatResponseReceived', 'Chat Response Received'),
    sound: SoundSource(<Sound>[
      Sound.responseReceived1,
      Sound.responseReceived2,
      Sound.responseReceived3,
      Sound.responseReceived4,
    ]),
    legacySoundSettingsKey: 'audioCues.chatResponseReceived',
    settingsKey: 'accessibility.signals.chatResponseReceived',
  );
  static final AccessibilitySignal confetti = register(
    name: localize('accessibilitySignals.confetti', 'Confetti'),
    sound: Sound.confetti,
    settingsKey: 'accessibility.signals.confetti',
  );
  static final AccessibilitySignal codeActionTriggered = register(
    name: localize('accessibilitySignals.codeActionRequestTriggered', 'Code Action Request Triggered'),
    sound: Sound.codeActionTriggered,
    legacySoundSettingsKey: 'audioCues.codeActionRequestTriggered',
    legacyAnnouncementSettingsKey: 'accessibility.alert.codeActionRequestTriggered',
    announcementMessage: localize('accessibility.signals.codeActionRequestTriggered', 'Code Action Request Triggered'),
    settingsKey: 'accessibility.signals.codeActionTriggered',
  );
  static final AccessibilitySignal codeActionApplied = register(
    name: localize('accessibilitySignals.codeActionApplied', 'Code Action Applied'),
    sound: Sound.codeActionApplied,
    legacySoundSettingsKey: 'audioCues.codeActionApplied',
    settingsKey: 'accessibility.signals.codeActionApplied',
  );
  static final AccessibilitySignal progress = register(
    name: localize('accessibilitySignals.progress', 'Progress'),
    sound: Sound.progress,
    legacySoundSettingsKey: 'audioCues.chatResponsePending',
    legacyAnnouncementSettingsKey: 'accessibility.alert.progress',
    announcementMessage: localize('accessibility.signals.progress', 'Progress'),
    settingsKey: 'accessibility.signals.progress',
  );
  static final AccessibilitySignal clear = register(
    name: localize('accessibilitySignals.clear', 'Clear'),
    sound: Sound.clear,
    legacySoundSettingsKey: 'audioCues.clear',
    legacyAnnouncementSettingsKey: 'accessibility.alert.clear',
    announcementMessage: localize('accessibility.signals.clear', 'Clear'),
    settingsKey: 'accessibility.signals.clear',
  );
  static final AccessibilitySignal save = register(
    name: localize('accessibilitySignals.save', 'Save'),
    sound: Sound.save,
    legacySoundSettingsKey: 'audioCues.save',
    legacyAnnouncementSettingsKey: 'accessibility.alert.save',
    announcementMessage: localize('accessibility.signals.save', 'Save'),
    settingsKey: 'accessibility.signals.save',
  );
  static final AccessibilitySignal format = register(
    name: localize('accessibilitySignals.format', 'Format'),
    sound: Sound.format,
    legacySoundSettingsKey: 'audioCues.format',
    legacyAnnouncementSettingsKey: 'accessibility.alert.format',
    announcementMessage: localize('accessibility.signals.format', 'Format'),
    settingsKey: 'accessibility.signals.format',
  );
  static final AccessibilitySignal voiceRecordingStarted = register(
    name: localize('accessibilitySignals.voiceRecordingStarted', 'Voice Recording Started'),
    sound: Sound.voiceRecordingStarted,
    legacySoundSettingsKey: 'audioCues.voiceRecordingStarted',
    settingsKey: 'accessibility.signals.voiceRecordingStarted',
  );
  static final AccessibilitySignal voiceModeStarted = register(
    name: localize('accessibilitySignals.voiceModeStarted', 'Voice Mode Started'),
    sound: Sound.voiceRecordingStarted,
    announcementMessage: localize('accessibility.signals.voiceModeStarted', 'Voice Mode Started'),
    settingsKey: 'accessibility.signals.voiceModeStarted',
  );
  static final AccessibilitySignal voiceRecordingStopped = register(
    name: localize('accessibilitySignals.voiceRecordingStopped', 'Voice Recording Stopped'),
    sound: Sound.voiceRecordingStopped,
    legacySoundSettingsKey: 'audioCues.voiceRecordingStopped',
    settingsKey: 'accessibility.signals.voiceRecordingStopped',
  );
  static final AccessibilitySignal voiceModeStopped = register(
    name: localize('accessibilitySignals.voiceModeStopped', 'Voice Mode Stopped'),
    sound: Sound.voiceRecordingStopped,
    announcementMessage: localize('accessibility.signals.voiceModeStopped', 'Voice Mode Stopped'),
    settingsKey: 'accessibility.signals.voiceModeStopped',
  );
  static final AccessibilitySignal dictationDisconnected = register(
    name: localize('accessibilitySignals.dictationDisconnected', 'Dictation Disconnected'),
    sound: Sound.error,
    settingsKey: 'accessibility.signals.dictationDisconnected',
  );
  static final AccessibilitySignal editsKept = register(
    name: localize('accessibilitySignals.editsKept', 'Edits Kept'),
    sound: Sound.editsKept,
    announcementMessage: localize('accessibility.signals.editsKept', 'Edits Kept'),
    settingsKey: 'accessibility.signals.editsKept',
  );
  static final AccessibilitySignal editsUndone = register(
    name: localize('accessibilitySignals.editsUndone', 'Undo Edits'),
    sound: Sound.editsUndone,
    announcementMessage: localize('accessibility.signals.editsUndone', 'Edits Undone'),
    settingsKey: 'accessibility.signals.editsUndone',
  );
  static final AccessibilitySignal chatUserActionRequired = register(
    name: localize('accessibilitySignals.chatUserActionRequired', 'Chat User Action Required'),
    sound: Sound.chatUserActionRequired,
    announcementMessage: localize('accessibility.signals.chatUserActionRequired', 'Chat User Action Required'),
    settingsKey: 'accessibility.signals.chatUserActionRequired',
  );
}

/// 1:1: `export class AccessibilitySignalService extends Disposable`.
class AccessibilitySignalService extends Disposable
    implements IAccessibilitySignalServiceType {
  @override
  // ignore: unused_element
  Object? get _serviceBrand => null;

  AccessibilitySignalService(
    this._configurationService,
    this._accessibilityService,
    this._telemetryService,
  ) : super() {
    _sounds = <String, AudioElementLike>{};
    _screenReaderAttached = observableFromEvent<bool, void>(
      this,
      _accessibilityService.onDidChangeScreenReaderOptimized,
      (Object? _) => _accessibilityService.isScreenReaderOptimized(),
    );
    _sentTelemetry = <String>{};
    _playingSounds = <Sound>{};
    _signalConfigValue = CachedFunction<AccessibilitySignal, IObservable<Map<String, Object?>>>(
      (AccessibilitySignal signal) => observableConfigValue<Map<String, Object?>>(
        signal.settingsKey,
        <String, Object?>{'sound': 'off', 'announcement': 'off'},
        _configurationService,
      ),
    );
    _signalEnabledState = CachedFunction<_SignalEnabledArgs,
        IObservable<bool>>.withOptions(
        ICacheOptions<_SignalEnabledArgs>(getCacheKey: getStructuralKey),
        (_SignalEnabledArgs arg) {
      final IObservable<bool> observable = derived<bool, void>((dynamic reader) {
        final Map<String, Object?> setting =
            _signalConfigValue.get(arg.signal).read(reader as dynamic);
        if (arg.modality == AccessibilityModality.sound ||
            arg.modality == null) {
          if (arg.signal.managesOwnEnablement ||
              checkEnabledState(
                  (setting['sound'] as String?) ?? 'off',
                  () => _screenReaderAttached.read(reader as dynamic),
                  arg.userGesture)) {
            return true;
          }
        }
        if (arg.modality == AccessibilityModality.announcement ||
            arg.modality == null) {
          if (checkEnabledState(
              (setting['announcement'] as String?) ?? 'off',
              () => _screenReaderAttached.read(reader as dynamic),
              arg.userGesture)) {
            return true;
          }
        }
        return false;
      });
      register(recomputeInitiallyAndOnChange(observable));
      return observable;
    });
  }

  final IConfigurationServiceType _configurationService;
  final IAccessibilityServiceType _accessibilityService;
  final ITelemetryServiceType _telemetryService;

  late final Map<String, AudioElementLike> _sounds;
  late final IObservable<bool> _screenReaderAttached;
  late final Set<String> _sentTelemetry;
  late final Set<Sound> _playingSounds;
  late final CachedFunction<AccessibilitySignal, IObservable<Map<String, Object?>>>
      _signalConfigValue;
  late final CachedFunction<_SignalEnabledArgs, IObservable<bool>>
      _signalEnabledState;

  @override
  IValueWithChangeEvent<bool> getEnabledState(AccessibilitySignal signal,
      bool userGesture, [String? modality]) {
    return ValueWithChangeEventFromObservable<bool>(_signalEnabledState.get(
        _SignalEnabledArgs(signal, userGesture, modality)));
  }

  IObservable<bool> _enabledState(AccessibilitySignal signal, bool userGesture,
      [String? modality]) {
    return _signalEnabledState
        .get(_SignalEnabledArgs(signal, userGesture, modality));
  }

  @override
  Future<void> playSignal(
    AccessibilitySignal signal, [
    IAccessbilitySignalOptions? options,
  ]) async {
    final IAccessbilitySignalOptions opts = options ?? IAccessbilitySignalOptions();
    final bool shouldPlayAnnouncement =
        opts.modality == AccessibilityModality.announcement ||
            opts.modality == null;
    final String? announcementMessage =
        opts.customAlertMessage ?? signal.announcementMessage;
    if (shouldPlayAnnouncement &&
        isAnnouncementEnabled(signal, opts.userGesture) &&
        announcementMessage != null) {
      _accessibilityService.status(announcementMessage);
    }

    final bool shouldPlaySound =
        opts.modality == AccessibilityModality.sound || opts.modality == null;
    if (shouldPlaySound && isSoundEnabled(signal, opts.userGesture)) {
      _sendSignalTelemetry(signal, opts.source);
      await playSound(signal.sound.getSound(), opts.allowManyInParallel ?? false,
          AcknowledgeDocCommentsToken);
    }
  }

  @override
  Future<void> playSignals(List<Object> signals) async {
    for (final Object signal in signals) {
      if (signal is SignalWithSource) {
        _sendSignalTelemetry(signal.signal, signal.source);
      } else {
        _sendSignalTelemetry(signal as AccessibilitySignal, null);
      }
    }
    final List<AccessibilitySignal> signalArray = signals
        .map((Object s) =>
            s is SignalWithSource ? s.signal : s as AccessibilitySignal)
        .toList();
    final List<String> announcements = signalArray
        .where(isAnnouncementEnabled)
        .map((AccessibilitySignal s) => s.announcementMessage!)
        .toList();
    if (announcements.isNotEmpty) {
      _accessibilityService.status(announcements.join(', '));
    }

    final Set<Sound> sounds = <Sound>{
      for (final AccessibilitySignal signal in signalArray)
        if (isSoundEnabled(signal)) signal.sound.getSound(),
    };
    await Future.wait<void>(
        sounds.map((Sound s) => playSound(s, true, AcknowledgeDocCommentsToken)));
  }

  void _sendSignalTelemetry(AccessibilitySignal signal, String? source) {
    final bool sr = _accessibilityService.isScreenReaderOptimized();
    final String key = signal.name +
        (source != null ? '::$source' : '') +
        (sr ? '{screenReaderOptimized}' : '');
    if (_sentTelemetry.contains(key) || _getVolumeInPercent() == 0) return;
    _sentTelemetry.add(key);
    _telemetryService.publicLog2('signal.played', <String, Object?>{
      'signal': signal.name,
      'source': source ?? '',
      'isScreenReaderOptimized': sr,
    });
  }

  num _getVolumeInPercent() {
    final Object? volume =
        _configurationService.getValue$1('accessibility.signalOptions.volume');
    if (volume is! num) return 50;
    return volume > 100 ? 100 : (volume < 0 ? 0 : volume);
  }

  @override
  Future<void> playSound(
    Sound sound,
    bool allowManyInParallel,
    Object token,
  ) async {
    if (!allowManyInParallel && _playingSounds.contains(sound)) return;
    _playingSounds.add(sound);
    final String url = _audioUrl(sound);
    try {
      final AudioElementLike? existing = _sounds[url];
      if (existing != null) {
        existing.volume = _getVolumeInPercent() / 100;
        existing.currentTime = 0;
        await existing.play();
      } else {
        final AudioElementLike played =
            await _playAudio(url, _getVolumeInPercent() / 100);
        _sounds[url] = played;
      }
    } catch (e) {
      final String message = e.toString();
      if (!message.contains('play() can only be initiated by a user gesture')) {
        // ignore: avoid_print
        print('Error while playing sound $e');
      }
    } finally {
      _playingSounds.remove(sound);
    }
  }

  Future<AudioElementLike> _playAudio(String url, double volume) async {
    final DisposableStore disposables = DisposableStore();
    try {
      final AudioElementLike audio = _createAudio(url);
      audio.volume = volume;
      final Completer<AudioElementLike> completer = Completer<AudioElementLike>();
      audio.setOnEnded(() {
        if (!completer.isCompleted) completer.complete(audio);
      });
      audio.setOnError((Object error) {
        if (!completer.isCompleted) completer.completeError(error);
      });
      audio.play().catchError((Object error) {
        if (!completer.isCompleted) completer.completeError(error);
      });
      return await completer.future;
    } finally {
      disposables.dispose();
    }
  }

  AudioElementLike _createAudio(String url) {
    final AudioElementLike Function(String)? factory = audioFactoryProvider;
    if (factory == null) {
      throw StateError('audioFactoryProvider must be set to play sounds');
    }
    return factory(url);
  }

  @override
  IDisposable playSignalLoop(AccessibilitySignal signal, num milliseconds) {
    bool playing = true;
    void playSoundLoop() {
      if (!playing) return;
      playSignal(signal,
              IAccessbilitySignalOptions(allowManyInParallel: true))
          .whenComplete(() {
        Timer(Duration(milliseconds: milliseconds.round()), () {
          if (playing) playSoundLoop();
        });
      });
    }

    playSoundLoop();
    return toDisposable(() => playing = false);
  }

  @override
  bool isAnnouncementEnabled(AccessibilitySignal signal, [bool? userGesture]) {
    if (signal.announcementMessage == null) return false;
    return _enabledState(signal, userGesture ?? false,
            AccessibilityModality.announcement)
        .get();
  }

  @override
  bool isSoundEnabled(AccessibilitySignal signal, [bool? userGesture]) {
    return _enabledState(signal, userGesture ?? false, AccessibilityModality.sound)
        .get();
  }

  @override
  Event<void> onSoundEnabledChanged(AccessibilitySignal signal) {
    // ValueWithChangeEventFromObservable exposes onDidChange via Emitter;
    // the TS code uses `.onDidChange` on the returned wrapper.
    final dynamic wrapper = getEnabledState(signal, false);
    return wrapper.onDidChange as Event<void>;
  }

  @override
  num getDelayMs(AccessibilitySignal signal, String modality, String mode) {
    if (_configurationService.getValue$1(
            'accessibility.signalOptions.debouncePositionChanges') !=
        true) {
      return 0;
    }
    String key;
    if (signal.name == AccessibilitySignal.errorAtPosition.name &&
        mode == 'positional') {
      key = 'accessibility.signalOptions.experimental.delays.errorAtPosition';
    } else if (signal.name == AccessibilitySignal.warningAtPosition.name &&
        mode == 'positional') {
      key = 'accessibility.signalOptions.experimental.delays.warningAtPosition';
    } else {
      key = 'accessibility.signalOptions.experimental.delays.general';
    }
    final Object? value = _configurationService.getValue$1(key);
    final Map<String, Object?> map =
        value is Map ? value.cast<String, Object?>() : <String, Object?>{};
    final Object? v = modality == AccessibilityModality.sound
        ? map['sound']
        : map['announcement'];
    return v is num ? v : 0;
  }
}

/// Carrier for `{ signal, source }` entries in `playSignals`.
// ignore: unused_element
class SignalWithSource {
  SignalWithSource(this.signal, this.source);
  final AccessibilitySignal signal;
  final String source;
}

class _SignalEnabledArgs {
  _SignalEnabledArgs(this.signal, this.userGesture, this.modality);

  final AccessibilitySignal signal;
  final bool userGesture;
  final String? modality;
}
