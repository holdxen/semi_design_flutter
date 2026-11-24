// 1:1 port of vscode/src/vs/editor/browser/services/inlineCompletionsService.ts
//
// Carriers: `TimeoutTimer`, `BugIndicatingError`, `Emitter`/`Event`,
// `Disposable`, `RawContextKey`, `Action2`/`registerAction2`,
// `registerSingleton`, `localize`/`localize2`, `IQuickInputService` and
// `IStorageService` are used as-is.
//
// Adaptations (documented inline):
//  * `IInlineCompletionsService` (interface) → `IInlineCompletionsServiceType`,
//    the service identifier keeps the original name (port-wide convention).
//  * `Date.now()` is read through an injectable clock (`dateNowOverride`) so
//    snooze math is replayable in tests; `null` restores the system clock.
//  * `(IQuickPickItem & { value: number })[]` → a private item subclass
//    carrying `value`.
//  * `Number(...)` / `Math.round` / `Date.now()` number semantics are mirrored
//    by `double.tryParse`, `.round()` and `_jsNum`.
import 'dart:math' show max;

import '../../../base/common/async.dart' show TimeoutTimer;
import '../../../base/common/errors.dart' show BugIndicatingError;
import '../../../base/common/event.dart' show Emitter, Event;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../nls.dart' show ILocalizedString, localize, localize2;
import '../../../platform/action/common/action.dart' as action;
import '../../../platform/actions/common/actions.dart'
    show Action2, registerAction2;
import '../../../platform/contextkey/common/contextkey.dart' as contextkey;
import '../../../platform/instantiation/common/extensions.dart'
    show InstantiationType, registerSingleton;
import '../../../platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier, ServicesAccessor, createDecorator;
import '../../../platform/quickinput/common/quickInput.dart'
    show
        IInputOptions,
        IPickOptions,
        IQuickInputService,
        IQuickInputServiceType,
        IQuickPickItem;
import '../../../platform/storage/common/storage.dart'
    show
        IStorageService,
        IStorageServiceType,
        StorageScope,
        StorageTarget;
import '../../../platform/telemetry/common/telemetry.dart'
    show ITelemetryServiceType;

/// 1:1: `export const IInlineCompletionsService =
/// createDecorator<IInlineCompletionsService>('IInlineCompletionsService')`.
final ServiceIdentifier<IInlineCompletionsServiceType> IInlineCompletionsService =
    createDecorator<IInlineCompletionsServiceType>('IInlineCompletionsService');

/// 1:1: `export interface IInlineCompletionsService`.
abstract class IInlineCompletionsServiceType {
  /// 1:1: `readonly _serviceBrand: undefined`.
  Object? get serviceBrand;

  Event<bool> get onDidChangeIsSnoozing;

  /// Get the remaining time (in ms) for which inline completions should be
  /// snoozed, or 0 if not snoozed.
  int get snoozeTimeLeft;

  /// Snooze inline completions for the specified duration. If already snoozed,
  /// extend the snooze time.
  void snooze([int? durationMs]);

  /// Snooze inline completions for the specified duration. If already snoozed,
  /// overwrite the existing snooze time.
  void setSnoozeDuration(int durationMs);

  /// Check if inline completions are currently snoozed.
  bool isSnoozing();

  /// Cancel the current snooze.
  void cancelSnooze();

  /// Report an inline completion.
  void reportNewCompletion(String requestUuid);
}

/// TS `Date.now()`; the port keeps an injectable clock (test seam) so the
/// snooze math is deterministic. `null` restores the system clock.
int Function()? _dateNowOverride;
int _dateNow() =>
    (_dateNowOverride ?? _systemNow)();
int _systemNow() => DateTime.now().millisecondsSinceEpoch;

/// Test seam for [InlineCompletionsService]'s `Date.now()` reads.
set dateNowOverride(int Function()? value) {
  _dateNowOverride = value;
}

final contextkey.RawContextKey<bool> InlineCompletionsSnoozing =
    contextkey.RawContextKey<bool>(
  'inlineCompletions.snoozed',
  false,
  localize('inlineCompletions.snoozed',
      'Whether inline completions are currently snoozed'),
);

/// 1:1: `export class InlineCompletionsService extends Disposable implements
/// IInlineCompletionsService`.
class InlineCompletionsService extends lifecycle.Disposable
    implements IInlineCompletionsServiceType {
  InlineCompletionsService(
    this._contextKeyService,
    this._telemetryService,
  ) : super() {
    register(_onDidChangeIsSnoozing);
    _timer = register(TimeoutTimer());

    final contextkey.IContextKey<bool> inlineCompletionsSnoozing =
        InlineCompletionsSnoozing.bindTo(_contextKeyService);
    register(onDidChangeIsSnoozing((bool _) {
      inlineCompletionsSnoozing.set(isSnoozing());
    }));
  }

  @override
  Object? get serviceBrand => null;

  final contextkey.IContextKeyServiceType _contextKeyService;
  final ITelemetryServiceType _telemetryService;

  final Emitter<bool> _onDidChangeIsSnoozing = Emitter<bool>();
  @override
  late final Event<bool> onDidChangeIsSnoozing =
      _onDidChangeIsSnoozing.event;

  // 5 minutes
  static const int _SNOOZE_DURATION = 300000;

  int? _snoozeTimeEnd;
  @override
  int get snoozeTimeLeft {
    if (_snoozeTimeEnd == null) {
      return 0;
    }
    return max(0, _snoozeTimeEnd! - _dateNow());
  }

  late final TimeoutTimer _timer;

  @override
  void snooze([int? durationMs]) {
    setSnoozeDuration((durationMs ?? _SNOOZE_DURATION) + snoozeTimeLeft);
  }

  @override
  void setSnoozeDuration(int durationMs) {
    if (durationMs < 0) {
      throw BugIndicatingError(
          'Invalid snooze duration: $durationMs. Duration must be non-negative.');
    }
    if (durationMs == 0) {
      cancelSnooze();
      return;
    }

    final bool wasSnoozing = isSnoozing();
    final int timeLeft = snoozeTimeLeft;

    _snoozeTimeEnd = _dateNow() + durationMs;

    if (!wasSnoozing) {
      _onDidChangeIsSnoozing.fire(true);
    }

    _timer.cancelAndSet(
      () {
        if (!isSnoozing()) {
          _onDidChangeIsSnoozing.fire(false);
        } else {
          throw BugIndicatingError('Snooze timer did not fire as expected');
        }
      },
      snoozeTimeLeft + 1,
    );

    _reportSnooze(durationMs - timeLeft, durationMs);
  }

  @override
  bool isSnoozing() {
    return snoozeTimeLeft > 0;
  }

  @override
  void cancelSnooze() {
    if (isSnoozing()) {
      _reportSnooze(-snoozeTimeLeft, 0);
      _snoozeTimeEnd = null;
      _timer.cancel();
      _onDidChangeIsSnoozing.fire(false);
    }
  }

  String? _lastCompletionId;
  final List<String> _recentCompletionIds = <String>[];
  @override
  void reportNewCompletion(String requestUuid) {
    _lastCompletionId = requestUuid;

    _recentCompletionIds.insert(0, requestUuid);
    if (_recentCompletionIds.length > 5) {
      _recentCompletionIds.removeLast();
    }
  }

  void _reportSnooze(int deltaMs, int totalMs) {
    final int deltaSeconds = (deltaMs / 1000).round();
    final int totalSeconds = (totalMs / 1000).round();
    _telemetryService.publicLog2('inlineCompletions.snooze', <String, Object?>{
      'deltaSeconds': deltaSeconds,
      'totalSeconds': totalSeconds,
      'lastCompletionId': _lastCompletionId,
      'recentCompletionIds': _recentCompletionIds,
    });
  }
}

/// 1:1: `registerSingleton(IInlineCompletionsService, InlineCompletionsService,
/// InstantiationType.Delayed)` — Dart has no top-level statements, so a
/// lazy-initialized `final` reproduces the module-load registration.
final ServiceIdentifier<IInlineCompletionsServiceType>
    inlineCompletionsServiceRegistration = () {
  registerSingleton<IInlineCompletionsServiceType>(
      IInlineCompletionsService, InlineCompletionsService.new,
      InstantiationType.Delayed);
  return IInlineCompletionsService;
}();

const String _snoozeInlineSuggestId = 'editor.action.inlineSuggest.snooze';
const String _cancelSnoozeInlineSuggestId =
    'editor.action.inlineSuggest.cancelSnooze';
const String _LAST_SNOOZE_DURATION_KEY =
    'inlineCompletions.lastSnoozeDuration';

/// Descriptor object literal passed to `super({...})`. Extends
/// [action.ICommandAction] so `registerAction2`'s `f1` path can register it.
class _SnoozeInlineCompletionDesc extends action.ICommandAction {
  _SnoozeInlineCompletionDesc()
      : super(
          id: SnoozeInlineCompletion.ID,
          title: _buildTitle(),
          precondition: contextkey.ContextKeyExpr.true_(),
        );

  static action.ICommandActionTitle _buildTitle() {
    final ILocalizedString nls = localize2(
        'action.inlineSuggest.snooze', 'Snooze Inline Suggestions');
    return action.ICommandActionTitle(value: nls.value, original: nls.original);
  }

  // Extra `IAction2Options` fields read by `registerAction2` dynamically.
  final bool f1 = true;
  Object? get menu => null;
  Object? get keybinding => null;
}

/// Descriptor for the cancel action (`precondition: InlineCompletionsSnoozing`).
class _CancelSnoozeInlineCompletionDesc extends action.ICommandAction {
  _CancelSnoozeInlineCompletionDesc()
      : super(
          id: CancelSnoozeInlineCompletion.ID,
          title: _buildTitle(),
          precondition: InlineCompletionsSnoozing,
        );

  static action.ICommandActionTitle _buildTitle() {
    final ILocalizedString nls = localize2('action.inlineSuggest.cancelSnooze',
        'Cancel Snooze Inline Suggestions');
    return action.ICommandActionTitle(value: nls.value, original: nls.original);
  }

  final bool f1 = true;
  Object? get menu => null;
  Object? get keybinding => null;
}

/// 1:1: JS `${number}` stringification (integral doubles print without `.0`).
String _jsNum(Object? v) {
  if (v is int) return v.toString();
  if (v is double) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toString();
  }
  return v.toString();
}

/// `IQuickPickItem & { value: number }` items offered by the snooze picker.
class _SnoozeQuickPickItem extends IQuickPickItem {
  _SnoozeQuickPickItem({
    required super.label,
    super.id,
    super.description,
    required this.value,
  });

  final int value;
}

/// 1:1: `export class SnoozeInlineCompletion extends Action2`.
class SnoozeInlineCompletion extends Action2 {
  SnoozeInlineCompletion() : super(_SnoozeInlineCompletionDesc());

  static const String ID = _snoozeInlineSuggestId;

  @override
  Future<void> run(
    ServicesAccessor accessor, [
    List<Object?> args = const <Object?>[],
  ]) async {
    final IQuickInputServiceType quickInputService =
        accessor.get(IQuickInputService) as IQuickInputServiceType;
    final IInlineCompletionsServiceType inlineCompletionsService =
        accessor.get(IInlineCompletionsService)
            as IInlineCompletionsServiceType;
    final IStorageServiceType storageService =
        accessor.get(IStorageService) as IStorageServiceType;

    int? durationMs;
    if (args.isNotEmpty && args[0] is num) {
      durationMs = ((args[0] as num) * 60000).toInt();
    }

    if (durationMs == null || durationMs == 0) {
      durationMs = await _getDurationFromUser(quickInputService, storageService);
    }

    if (durationMs != null && durationMs != 0) {
      inlineCompletionsService.setSnoozeDuration(durationMs);
    }
  }

  Future<int?> _getDurationFromUser(
    IQuickInputServiceType quickInputService,
    IStorageServiceType storageService,
  ) async {
    final num lastSelectedDuration = (storageService.getNumber(
            _LAST_SNOOZE_DURATION_KEY, StorageScope.PROFILE, 300000)) ??
        300000;

    List<_SnoozeQuickPickItem> items = <_SnoozeQuickPickItem>[
      _SnoozeQuickPickItem(
          label: localize('snooze.1minute', '1 minute'),
          id: '1',
          value: 60000),
      _SnoozeQuickPickItem(
          label: localize('snooze.5minutes', '5 minutes'),
          id: '5',
          value: 300000),
      _SnoozeQuickPickItem(
          label: localize('snooze.10minutes', '10 minutes'),
          id: '10',
          value: 600000),
      _SnoozeQuickPickItem(
          label: localize('snooze.15minutes', '15 minutes'),
          id: '15',
          value: 900000),
      _SnoozeQuickPickItem(
          label: localize('snooze.30minutes', '30 minutes'),
          id: '30',
          value: 1800000),
      _SnoozeQuickPickItem(
          label: localize('snooze.60minutes', '60 minutes'),
          id: '60',
          value: 3600000),
    ];
    if (lastSelectedDuration > 0 &&
        !items
            .any((_SnoozeQuickPickItem item) => item.value == lastSelectedDuration)) {
      final num minutes = lastSelectedDuration / 60000;
      final _SnoozeQuickPickItem customItem = _SnoozeQuickPickItem(
        label: localize('snooze.lastCustom', '{0} minutes (Last used)',
            <Object?>[_jsNum(minutes)]),
        id: 'last-custom',
        value: lastSelectedDuration.toInt(),
        description: localize('snooze.lastUsed', 'Last used custom duration'),
      );
      final int index = items.indexWhere(
          (_SnoozeQuickPickItem item) => item.value > lastSelectedDuration);
      if (index == -1) {
        items = <_SnoozeQuickPickItem>[...items, customItem];
      } else {
        items = <_SnoozeQuickPickItem>[
          ...items.sublist(0, index),
          customItem,
          ...items.sublist(index),
        ];
      }
    }

    items.add(_SnoozeQuickPickItem(
        label: localize('snooze.custom', 'Custom...'),
        id: 'custom',
        value: -1));

    _SnoozeQuickPickItem? activeItem;
    for (final _SnoozeQuickPickItem item in items) {
      if (item.value == lastSelectedDuration) {
        activeItem = item;
        break;
      }
    }

    final Object? picked = await quickInputService.pick(
      items,
      IPickOptions<_SnoozeQuickPickItem>(
        placeHolder: localize('snooze.placeholder',
            'Select snooze duration for Inline Suggestions'),
        activeItem: activeItem,
      ),
    );

    if (picked != null) {
      final dynamic pickedItem = picked;
      if (pickedItem.id == 'custom') {
        return _getCustomDurationFromUser(quickInputService, storageService);
      }
      final int value = pickedItem.value as int;
      storageService.store(_LAST_SNOOZE_DURATION_KEY, value,
          StorageScope.PROFILE, StorageTarget.USER);
      return value;
    }

    return null;
  }

  Future<int?> _getCustomDurationFromUser(
    IQuickInputServiceType quickInputService,
    IStorageServiceType storageService,
  ) async {
    final String? customMinutes = await quickInputService.input(
      IInputOptions(
        placeHolder: localize('snooze.customPlaceholder',
            'Duration in minutes (e.g. 90)'),
        prompt: localize(
            'snooze.customPrompt', 'Enter snooze duration in minutes'),
        validateInput: (String value) async {
          final double? n = double.tryParse(value);
          if (n == null || n <= 0 || !n.isFinite) {
            return localize(
                'snooze.invalidInput', 'Please enter a positive number');
          }
          return null;
        },
      ),
    );

    if (customMinutes != null && customMinutes.isNotEmpty) {
      final num ms = (double.parse(customMinutes) * 60000);
      storageService.store(_LAST_SNOOZE_DURATION_KEY, ms,
          StorageScope.PROFILE, StorageTarget.USER);
      return ms.toInt();
    }

    return null;
  }
}

/// 1:1: `export class CancelSnoozeInlineCompletion extends Action2`.
class CancelSnoozeInlineCompletion extends Action2 {
  CancelSnoozeInlineCompletion() : super(_CancelSnoozeInlineCompletionDesc());

  static const String ID = _cancelSnoozeInlineSuggestId;

  @override
  Future<void> run(
    ServicesAccessor accessor, [
    List<Object?> args = const <Object?>[],
  ]) async {
    final IInlineCompletionsServiceType inlineCompletionsService =
        accessor.get(IInlineCompletionsService)
            as IInlineCompletionsServiceType;
    inlineCompletionsService.cancelSnooze();
  }
}

/// 1:1 top-level side effect: `registerAction2(SnoozeInlineCompletion)` and
/// `registerAction2(CancelSnoozeInlineCompletion)`. Dart has no top-level
/// statements, so registration is exposed via an idempotent gate.
bool _registered = false;

void ensureRegistered() {
  if (_registered) return;
  _registered = true;
  registerAction2(() => SnoozeInlineCompletion());
  registerAction2(() => CancelSnoozeInlineCompletion());
}