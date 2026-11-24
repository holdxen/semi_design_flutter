// ---------------------------------------------------------------------------
// 1:1 port of vscode/src/vs/platform/keybinding/common/abstractKeybindingService.ts
// Truth: tool/ts2dart/batch158_truth.json (real transpiled TypeScript runtime).
// Adaptations (documented inline):
//   - TypeScript `protected abstract` methods are exposed without the leading
//     `_` so subclasses in other Dart libraries can implement them.
//   - `console.warn` stays a no-op, matching the rest of this port.
//   - JS `undefined` is carried by [jsUndefined] where `typeof x === 'undefined'`
//     is observable; JS `null` remains Dart `null`.
// ---------------------------------------------------------------------------

import '../../../base/common/arrays.dart' as arrays;
import '../../../base/common/async.dart' as async;
import '../../../base/common/errors.dart' as errors;
import '../../../base/common/event.dart' as event;
import '../../../base/common/ime.dart' as ime;
import '../../../base/common/keyCodes.dart' as keyCodes;
import '../../../base/common/keybindings.dart' as keybindings;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../nls.dart' as nls;
import '../../commands/common/commands.dart' as commands;
import '../../contextkey/common/contextkey.dart' as contextkey;
import '../../log/common/log.dart' as log;
import '../../notification/common/notification.dart' as notification;
import '../../telemetry/common/telemetry.dart' as telemetry;
import 'keybinding.dart' as keybinding;
import 'keybindingResolver.dart' as resolver;
import 'resolvedKeybindingItem.dart' as resolved;

/// 1:1: `interface CurrentChord { keypress: string; label: string | null; }`
class CurrentChord {
  final String keypress;
  final String? label;

  CurrentChord(this.keypress, this.label);
}

/// 1:1: `/^(cursor|delete|undo|redo|tab|editor\.action\.clipboard)/`
final RegExp HIGH_FREQ_COMMANDS =
    RegExp(r'^(cursor|delete|undo|redo|tab|editor\.action\.clipboard)');

/// JS `undefined` carrier. Only used where TypeScript checks
/// `typeof value === 'undefined'` or emits `?? undefined`.
final Object jsUndefined = Object();

/// 1:1: `function isKeyInComposition(e: IKeyboardEvent): boolean`
bool isKeyInComposition(keybinding.IKeyboardEvent e) =>
    e.keyCode == keyCodes.KeyCode.KEY_IN_COMPOSITION;

/// JS array destructuring (`const [first] = arr`) yields `undefined` for an
/// empty array; Dart indexing would throw, so this carrier preserves that.
T? _firstOrNull<T>(List<T> values) => values.isEmpty ? null : values[0];

/// Same carrier for `List<String?>`, where Dart's generic inference would
/// otherwise hoist the nullable element type into the wrong parameterization.
String? _firstStringOrNull(List<String?> values) =>
    values.isEmpty ? null : values[0];

/// 1:1: `class KeybindingModifierSet`
class KeybindingModifierSet {
  static final KeybindingModifierSet EMPTY = KeybindingModifierSet(null);

  final bool _ctrlKey;
  final bool _shiftKey;
  final bool _altKey;
  final bool _metaKey;

  KeybindingModifierSet(keybindings.ResolvedChord? source)
      : _ctrlKey = source?.ctrlKey ?? false,
        _shiftKey = source?.shiftKey ?? false,
        _altKey = source?.altKey ?? false,
        _metaKey = source?.metaKey ?? false;

  /// 1:1: `has(modifier: SingleModifierChord)`
  bool has(String modifier) {
    switch (modifier) {
      case 'ctrl':
        return _ctrlKey;
      case 'shift':
        return _shiftKey;
      case 'alt':
        return _altKey;
      case 'meta':
        return _metaKey;
      default:
        return false;
    }
  }
}

/// 1:1: `export abstract class AbstractKeybindingService extends Disposable
/// implements IKeybindingService`
abstract class AbstractKeybindingService extends lifecycle.Disposable
    implements keybinding.IKeybindingServiceType {
  final event.Emitter<void> _onDidUpdateKeybindings;

  final contextkey.IContextKeyServiceType _contextKeyService;
  final commands.ICommandServiceType _commandService;
  final telemetry.ITelemetryServiceType _telemetryService;
  final notification.INotificationServiceType _notificationService;
  final log.ILogServiceType _logService;

  late List<CurrentChord> _currentChords;
  late final async.IntervalTimer _currentChordChecker;
  late notification.IStatusHandle? _currentChordStatusMessage;
  late KeybindingModifierSet _ignoreSingleModifiers;
  late String? _currentSingleModifier;
  late final async.TimeoutTimer _currentSingleModifierClearTimeout;

  // 1:1: `protected _currentlyDispatchingCommandId: string | null`
  String? _currentlyDispatchingCommandId;

  bool _logging = false;

  AbstractKeybindingService(
    this._contextKeyService,
    this._commandService,
    this._telemetryService,
    this._notificationService,
    this._logService,
  )   : _onDidUpdateKeybindings = event.Emitter<void>() {
    // TS: this._register(new Emitter<void>())
    register(_onDidUpdateKeybindings);

    _currentChords = <CurrentChord>[];
    _currentChordChecker = async.IntervalTimer();
    _currentChordStatusMessage = null;
    _ignoreSingleModifiers = KeybindingModifierSet.EMPTY;
    _currentSingleModifier = null;
    _currentSingleModifierClearTimeout = async.TimeoutTimer();
    _currentlyDispatchingCommandId = null;
    _logging = false;
  }

  // 1:1: `public _serviceBrand: undefined`
  Object? get _serviceBrand => null;

  @override
  event.Event<void> get onDidUpdateKeybindings {
    // TS falls back to Event.None for Sinon prototype stubbing. Dart emitters
    // are always constructed, so the same observable value is returned.
    return _onDidUpdateKeybindings.event;
  }

  /// 1:1: `protected abstract _getResolver(): KeybindingResolver`
  resolver.KeybindingResolver getResolver();

  /// 1:1: `protected abstract _documentHasFocus(): boolean`
  bool documentHasFocus();

  /// Test carrier for `this._onDidUpdateKeybindings.fire()`; the TypeScript
  /// emitter is private but observable by listeners in the truth harness.
  void fireUpdateKeybindings() => _onDidUpdateKeybindings.fire(null);

  @override
  List<keybindings.ResolvedKeybinding> resolveKeybinding(
      keybindings.Keybinding keybinding);

  @override
  keybindings.ResolvedKeybinding resolveKeyboardEvent(
      keybinding.IKeyboardEvent keyboardEvent);

  @override
  List<keybindings.ResolvedKeybinding> resolveUserBinding(String userBinding);

  @override
  lifecycle.IDisposable registerSchemaContribution(
      keybinding.KeybindingsSchemaContribution contribution);

  // 1:1: `public abstract _dumpDebugInfo(): string`
  String _dumpDebugInfo();

  // 1:1: `public abstract _dumpDebugInfoJSON(): string`
  String _dumpDebugInfoJSON();

  @override
  bool get inChordMode => _currentChords.isNotEmpty;

  @override
  String getDefaultKeybindingsContent() => '';

  @override
  bool toggleLogging() {
    _logging = !_logging;
    return _logging;
  }

  /// 1:1: `protected _log(str: string): void`
  void _log(String str) {
    if (_logging) {
      _logService.info('[KeybindingService]: $str');
    }
  }

  @override
  List<resolved.ResolvedKeybindingItem> getDefaultKeybindings() =>
      getResolver().getDefaultKeybindings();

  @override
  List<resolved.ResolvedKeybindingItem> getKeybindings() =>
      getResolver().getKeybindings();

  @override
  int customKeybindingsCount() => 0;

  @override
  List<keybindings.ResolvedKeybinding> lookupKeybindings(String commandId) {
    return arrays.coalesce(getResolver()
        .lookupKeybindings(commandId)
        .map((item) => item.resolvedKeybinding)
        .toList());
  }

  @override
  keybindings.ResolvedKeybinding? lookupKeybinding(
    String commandId, [
    contextkey.IContextKeyServiceType? context,
    bool enforceContextCheck = false,
  ]) {
    final result = getResolver().lookupPrimaryKeybinding(
        commandId, context ?? _contextKeyService, enforceContextCheck);
    if (result == null) {
      return null;
    }
    return result.resolvedKeybinding;
  }

  @override
  bool dispatchEvent(
      keybinding.IKeyboardEvent e, contextkey.IContextKeyServiceTarget target) {
    return _dispatch(e, target);
  }

  @override
  resolver.ResolutionResult softDispatch(
    keybinding.IKeyboardEvent e,
    contextkey.IContextKeyServiceTarget target,
  ) {
    _log('/ Soft dispatching keyboard event');
    if (isKeyInComposition(e)) {
      _log('\\ Keyboard event is part of an IME composition');
      return resolver.NoMatchingKb;
    }
    final kb = resolveKeyboardEvent(e);
    if (kb.hasMultipleChords()) {
      // console.warn('keyboard event should not be mapped to multiple chords');
      return resolver.NoMatchingKb;
    }
    final firstChord = _firstStringOrNull(kb.getDispatchChords());
    if (firstChord == null) {
      _log('\\ Keyboard event cannot be dispatched');
      return resolver.NoMatchingKb;
    }

    final contextValue = _contextKeyService.getContext(target);
    final currentChords = _currentChords.map((c) => c.keypress).toList();
    return getResolver().resolve(contextValue!, currentChords, firstChord);
  }

  /// 1:1: `private _scheduleLeaveChordMode(): void`
  void _scheduleLeaveChordMode() {
    final chordLastInteractedTime = DateTime.now().millisecondsSinceEpoch;
    _currentChordChecker.cancelAndSet(() {
      if (!documentHasFocus()) {
        _leaveChordMode();
        return;
      }
      if (DateTime.now().millisecondsSinceEpoch - chordLastInteractedTime >
          5000) {
        _leaveChordMode();
      }
    }, 500);
  }

  /// 1:1: `private _expectAnotherChord(firstChord, keypressLabel)`
  void _expectAnotherChord(String firstChord, String? keypressLabel) {
    _currentChords.add(CurrentChord(firstChord, keypressLabel));

    switch (_currentChords.length) {
      case 0:
        throw errors.illegalState('impossible');
      case 1:
        _currentChordStatusMessage = _notificationService.status(nls.localize(
            'first.chord',
            '({0}) was pressed. Waiting for second key of chord...',
            <Object?>[keypressLabel]));
        break;
      default:
        final fullKeypressLabel =
            _currentChords.map((c) => c.label).join(', ');
        _currentChordStatusMessage = _notificationService.status(nls.localize(
            'next.chord',
            '({0}) was pressed. Waiting for next key of chord...',
            <Object?>[fullKeypressLabel]));
        break;
    }

    _scheduleLeaveChordMode();

    if (ime.IME.enabled) {
      ime.IME.disable();
    }
  }

  /// 1:1: `private _leaveChordMode(): void`
  void _leaveChordMode() {
    final statusMessage = _currentChordStatusMessage;
    if (statusMessage != null) {
      statusMessage.close();
      _currentChordStatusMessage = null;
    }
    _currentChordChecker.cancel();
    _currentChords = <CurrentChord>[];
    ime.IME.enable();
  }

  @override
  void dispatchByUserSettingsLabel(
      String userSettingsLabel, contextkey.IContextKeyServiceTarget target) {
    _log(
        '/ Dispatching keybinding triggered via menu entry accelerator - $userSettingsLabel');
    final keybindings = resolveUserBinding(userSettingsLabel);
    if (keybindings.isEmpty) {
      _log('\\ Could not resolve - $userSettingsLabel');
    } else {
      _doDispatch(keybindings[0], target, false);
    }
  }

  /// 1:1: `protected _dispatch(e, target)`
  bool _dispatch(
      keybinding.IKeyboardEvent e, contextkey.IContextKeyServiceTarget target) {
    if (isKeyInComposition(e)) {
      _log(
          '+ Ignoring keybinding dispatch because an IME composition is in progress.');
      return false;
    }
    return _doDispatch(resolveKeyboardEvent(e), target, false);
  }

  /// 1:1: `protected _singleModifierDispatch(e, target)`
  bool singleModifierDispatch(
      keybinding.IKeyboardEvent e, contextkey.IContextKeyServiceTarget target) {
    if (isKeyInComposition(e)) {
      return false;
    }
    final kb = resolveKeyboardEvent(e);
    final singleModifier = _firstStringOrNull(kb.getSingleModifierDispatchChords());

    if (singleModifier != null) {
      if (_ignoreSingleModifiers.has(singleModifier)) {
        _log(
            '+ Ignoring single modifier $singleModifier due to it being pressed together with other keys.');
        _ignoreSingleModifiers = KeybindingModifierSet.EMPTY;
        _currentSingleModifierClearTimeout.cancel();
        _currentSingleModifier = null;
        return false;
      }

      _ignoreSingleModifiers = KeybindingModifierSet.EMPTY;

      if (_currentSingleModifier == null) {
        _log('+ Storing single modifier for possible chord $singleModifier.');
        _currentSingleModifier = singleModifier;
        _currentSingleModifierClearTimeout.cancelAndSet(() {
          _log('+ Clearing single modifier due to 300ms elapsed.');
          _currentSingleModifier = null;
        }, 300);
        return false;
      }

      if (singleModifier == _currentSingleModifier) {
        _log('/ Dispatching single modifier chord $singleModifier $singleModifier');
        _currentSingleModifierClearTimeout.cancel();
        _currentSingleModifier = null;
        return _doDispatch(kb, target, true);
      }

      _log(
          '+ Clearing single modifier due to modifier mismatch: $_currentSingleModifier $singleModifier');
      _currentSingleModifierClearTimeout.cancel();
      _currentSingleModifier = null;
      return false;
    }

    final firstChord = _firstOrNull(kb.getChords());
    _ignoreSingleModifiers = KeybindingModifierSet(firstChord);

    if (_currentSingleModifier != null) {
      _log('+ Clearing single modifier due to other key up.');
    }
    _currentSingleModifierClearTimeout.cancel();
    _currentSingleModifier = null;
    return false;
  }

  /// 1:1: `private _doDispatch(userKeypress, target, isSingleModiferChord)`
  bool _doDispatch(
    keybindings.ResolvedKeybinding userKeypress,
    contextkey.IContextKeyServiceTarget target, [
    bool isSingleModiferChord = false,
  ]) {
    var shouldPreventDefault = false;

    if (userKeypress.hasMultipleChords()) {
      // console.warn('Unexpected keyboard event mapped to multiple chords');
      return false;
    }

    String? userPressedChord;
    List<String>? currentChords;

    if (isSingleModiferChord) {
      final dispatchKeyname =
          _firstStringOrNull(userKeypress.getSingleModifierDispatchChords());
      userPressedChord = dispatchKeyname;
      currentChords = dispatchKeyname != null ? <String>[dispatchKeyname] : <String>[];
    } else {
      userPressedChord = _firstStringOrNull(userKeypress.getDispatchChords());
      currentChords = _currentChords.map((c) => c.keypress).toList();
    }

    if (userPressedChord == null) {
      _log('\\ Keyboard event cannot be dispatched in keydown phase.');
      return shouldPreventDefault;
    }

    final contextValue = _contextKeyService.getContext(target);
    final keypressLabel = userKeypress.getLabel();
    final resolveResult =
        getResolver().resolve(contextValue!, currentChords, userPressedChord);

    switch (resolveResult.kind) {
      case resolver.ResultKind.NoMatchingKb:
        _logService.trace('KeybindingService#dispatch', <Object?>[
          keypressLabel,
          '[ No matching keybinding ]',
        ]);

        if (inChordMode) {
          final currentChordsLabel =
              _currentChords.map((c) => c.label).join(', ');
          _log(
              '+ Leaving multi-chord mode: Nothing bound to "$currentChordsLabel, $keypressLabel".');
          _notificationService.status(
            nls.localize(
              'missing.chord',
              'The key combination ({0}, {1}) is not a command.',
              <Object?>[currentChordsLabel, keypressLabel],
            ),
            notification.IStatusMessageOptions(hideAfter: 10 * 1000),
          );
          _leaveChordMode();
          shouldPreventDefault = true;
        }
        return shouldPreventDefault;

      case resolver.ResultKind.MoreChordsNeeded:
        _logService.trace('KeybindingService#dispatch', <Object?>[
          keypressLabel,
          '[ Several keybindings match - more chords needed ]',
        ]);
        shouldPreventDefault = true;
        _expectAnotherChord(userPressedChord, keypressLabel);
        _log(_currentChords.length == 1
            ? '+ Entering multi-chord mode...'
            : '+ Continuing multi-chord mode...');
        return shouldPreventDefault;

      case resolver.ResultKind.KbFound:
        _logService.trace('KeybindingService#dispatch', <Object?>[
          keypressLabel,
          '[ Will dispatch command ${resolveResult.commandId} ]',
        ]);

        final commandId = resolveResult.commandId;
        if (commandId == null || commandId.isEmpty) {
          if (inChordMode) {
            final currentChordsLabel =
                _currentChords.map((c) => c.label).join(', ');
            _log(
                '+ Leaving chord mode: Nothing bound to "$currentChordsLabel, $keypressLabel".');
            _notificationService.status(
              nls.localize(
                'missing.chord',
                'The key combination ({0}, {1}) is not a command.',
                <Object?>[currentChordsLabel, keypressLabel],
              ),
              notification.IStatusMessageOptions(hideAfter: 10 * 1000),
            );
            _leaveChordMode();
            shouldPreventDefault = true;
          }
        } else {
          if (inChordMode) {
            _leaveChordMode();
          }
          if (resolveResult.isBubble != true) {
            shouldPreventDefault = true;
          }

          _log('+ Invoking command $commandId.');
          _currentlyDispatchingCommandId = commandId;
          try {
            final Future<Object?> future;
            if (identical(resolveResult.commandArgs, jsUndefined)) {
              future = _commandService.executeCommand(
                  commandId, const <Object?>[]);
            } else {
              future = _commandService
                  .executeCommand(commandId, <Object?>[resolveResult.commandArgs]);
            }
            // TS: `.then(undefined, err => this._notificationService.warn(err))`
            future.then((_) {}, onError: (Object error) {
              _notificationService.warn(error);
            });
          } finally {
            _currentlyDispatchingCommandId = null;
          }

          if (!HIGH_FREQ_COMMANDS.hasMatch(commandId)) {
            _telemetryService.publicLog2(
              'workbenchActionExecuted',
              <String, Object?>{
                'id': commandId,
                'from': 'keybinding',
                'detail': userKeypress.getUserSettingsLabel() ?? jsUndefined,
              },
            );
          }
        }
        return shouldPreventDefault;

      default:
        return shouldPreventDefault;
    }
  }

  @override
  Future<void>? enableKeybindingHoldMode(String commandId) => null;

  @override
  bool mightProducePrintableCharacter(keybinding.IKeyboardEvent event) {
    if (event.ctrlKey || event.metaKey) {
      return false;
    }
    if ((event.keyCode >= keyCodes.KeyCode.KeyA &&
            event.keyCode <= keyCodes.KeyCode.KeyZ) ||
        (event.keyCode >= keyCodes.KeyCode.Digit0 &&
            event.keyCode <= keyCodes.KeyCode.Digit9)) {
      return true;
    }
    return false;
  }

  @override
  String appendKeybinding(
    String label,
    String? commandId, [
    contextkey.IContextKeyServiceType? context,
    bool enforceContextCheck = false,
  ]) {
    if (commandId != null && commandId.isNotEmpty) {
      final keybindingLabel =
          lookupKeybinding(commandId, context, enforceContextCheck)?.getLabel();
      if (keybindingLabel != null && keybindingLabel.isNotEmpty) {
        return nls.localize(
          <String, Object?>{
            'key': 'keybindingLabel',
            'comment': <String>['UI element label', 'A keybinding label'],
          },
          '{0} ({1})',
          <Object?>[label, keybindingLabel],
        );
      }
    }
    return label;
  }
}
