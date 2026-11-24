// 1:1 port of vscode/src/vs/platform/quickinput/browser/pickerQuickAccess.ts
//
// Carriers: `CancellationToken`/`CancellationTokenSource`, `Disposable`/
// `DisposableStore`/`MutableDisposable`, `timeout`, `isFunction` and the
// batch194 quickInput/quickAccess ports are used as-is.
//
// Adaptations (documented inline):
//  * TS unions `TriggerAction | Promise<TriggerAction>` → `Object?` awaited
//    through `dynamic`.
//  * `Picks<T> | Promise<Picks<T> | FastAndSlowPicks<T>> | FastAndSlowPicks<T>
//    | null` → `Object?`; `Future` detection replaces `instanceof Promise`.
//  * `type Pick<T> = T | IQuickPickSeparator` → `Object`.
//  * `picker.items.indexOf(item)` → identity search (`_indexOfIdentical`).
import '../../../base/common/async.dart' show timeout;
import '../../../base/common/cancellation.dart'
    show CancellationToken, CancellationTokenSource;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../base/common/types.dart' show isFunction;
import '../common/quickAccess.dart'
    show IQuickAccessProvider, IQuickAccessProviderRunOptions;
import '../common/quickInput.dart'
    show
        IKeyMods,
        IQuickInputButton,
        IQuickPick,
        IQuickPickDidAcceptEvent,
        IQuickPickItem,
        IQuickPickSeparator,
        isKeyModified;

/// 1:1: `export enum TriggerAction`.
class TriggerAction {
  /// Do nothing after the button was clicked.
  static const int NO_ACTION = 0;

  /// Close the picker.
  static const int CLOSE_PICKER = 1;

  /// Update the results of the picker.
  static const int REFRESH_PICKER = 2;

  /// Remove the item from the picker.
  static const int REMOVE_ITEM = 3;

  const TriggerAction._();
}

/// 1:1: `export interface IPickerQuickAccessItem extends IQuickPickItem`.
class IPickerQuickAccessItem extends IQuickPickItem {
  IPickerQuickAccessItem({
    super.id,
    required super.label,
    super.ariaLabel,
    super.description,
    super.italic,
    super.strikethrough,
    super.iconClasses,
    super.iconPath,
    super.iconClass,
    super.iconColor,
    super.highlights,
    super.buttons,
    super.disabled,
    super.type,
    super.detail,
    super.tooltip,
    super.keybinding,
    super.picked,
    super.alwaysShow,
    super.pickable,
    this.accept,
    this.trigger,
    this.attach,
  });

  /// A method that will be executed when the pick item is accepted from the
  /// picker. The picker will close automatically before running this.
  void Function(IKeyMods keyMods, IQuickPickDidAcceptEvent event)? accept;

  /// A method that will be executed when a button of the pick item was clicked
  /// on.
  ///
  /// Returns `TriggerAction | Promise<TriggerAction>`.
  Object? Function(int buttonIndex, IKeyMods keyMods)? trigger;

  /// When set, this will be invoked instead of `accept` if modifier keys are
  /// held down.
  void Function(IKeyMods keyMods, IQuickPickDidAcceptEvent event)? attach;
}

/// 1:1: `export interface IPickerQuickAccessSeparator extends
/// IQuickPickSeparator`.
class IPickerQuickAccessSeparator extends IQuickPickSeparator {
  IPickerQuickAccessSeparator({
    super.type,
    super.id,
    super.label,
    super.description,
    super.ariaLabel,
    super.buttons,
    super.tooltip,
    this.trigger,
  });

  Object? Function(int buttonIndex, IKeyMods keyMods)? trigger;
}

/// 1:1: `export interface IPickerQuickAccessProviderOptions<T extends
/// IPickerQuickAccessItem>`.
class IPickerQuickAccessProviderOptions<T extends IPickerQuickAccessItem> {
  IPickerQuickAccessProviderOptions({
    this.canAcceptInBackground,
    this.noResultsPick,
    this.shouldSkipTrimPickFilter,
  });

  /// Enables support for opening picks in the background via gesture.
  final bool? canAcceptInBackground;

  /// Enables to show a pick entry when no results are returned from a search.
  ///
  /// TS: `T | ((filter: string) => T)`.
  final Object? noResultsPick;

  /// Whether to skip trimming the pick filter string.
  final bool? shouldSkipTrimPickFilter;
}

/// 1:1: `export type Pick<T> = T | IQuickPickSeparator`.
typedef Pick<T> = Object;

/// 1:1: `export type PicksWithActive<T> = { items: readonly Pick<T>[];
/// active?: T }`.
class PicksWithActive<T> {
  PicksWithActive({required this.items, this.active});

  final List<Pick<T>> items;
  final T? active;
}

/// 1:1: `export type Picks<T> = readonly Pick<T>[] | PicksWithActive<T>`.
typedef Picks<T> = Object;

/// 1:1: `export type FastAndSlowPicks<T> = { picks; additionalPicks;
/// mergeDelay? }`.
class FastAndSlowPicks<T> {
  FastAndSlowPicks({
    required this.picks,
    required this.additionalPicks,
    this.mergeDelay,
  });

  /// Picks that will show instantly or after a short delay based on the
  /// `mergeDelay` property to reduce flicker.
  final Picks<T> picks;

  /// Picks that will show after they have been resolved.
  final Future<Picks<T>> additionalPicks;

  /// A delay in milliseconds to wait before showing the `picks` to give a
  /// chance to merge with `additionalPicks` for reduced flicker.
  final int? mergeDelay;
}

// TS uses structural checks (`instanceof` on plain object shapes). Dart's
// reified generics would make `obj is PicksWithActive<T>` fail whenever the
// caller built the value with a different type argument (e.g. `dynamic`), so
// the checks are done against `Object?` — every type argument satisfies it.
bool _isPicksWithActive(Object? obj) {
  return obj is PicksWithActive<Object?>;
}

bool _isFastAndSlowPicks(Object? obj) {
  return obj is FastAndSlowPicks<Object?>;
}

/// TS `array.indexOf(item)` — identity-based here (objects are compared by
/// reference in both languages).
int _indexOfIdentical<T>(List<Pick<T>> items, Object? item) {
  for (int i = 0; i < items.length; i++) {
    if (identical(items[i], item)) {
      return i;
    }
  }
  return -1;
}

/// 1:1: `export abstract class PickerQuickAccessProvider<T extends
/// IPickerQuickAccessItem> extends Disposable implements IQuickAccessProvider`.
abstract class PickerQuickAccessProvider<T extends IPickerQuickAccessItem>
    extends lifecycle.Disposable implements IQuickAccessProvider {
  PickerQuickAccessProvider(this.prefix, [this.options]);

  final String prefix;
  final IPickerQuickAccessProviderOptions<T>? options;

  @override
  Object? get defaultFilterValue => null;

  @override
  lifecycle.IDisposable provide(
    IQuickPick<IQuickPickItem> picker,
    CancellationToken token, [
    IQuickAccessProviderRunOptions? runOptions,
  ]) {
    final lifecycle.DisposableStore disposables = lifecycle.DisposableStore();

    // Apply options if any
    picker.canAcceptInBackground = options?.canAcceptInBackground == true;

    // Disable filtering & sorting, we control the results
    picker.matchOnLabel = false;
    picker.matchOnDescription = false;
    picker.matchOnDetail = false;
    picker.sortByLabel = false;

    // Set initial picks and update on type
    CancellationTokenSource? picksCts;
    final lifecycle.MutableDisposable<lifecycle.DisposableStore>
        picksDisposable =
        disposables.add(lifecycle.MutableDisposable<lifecycle.DisposableStore>());
    Future<void> updatePickerItems() async {
      // Cancel any previous ask for picks and busy
      picksCts?.dispose(true);
      picker.busy = false;

      // Setting the .value will call dispose() on the previous value, so we
      // need to do this AFTER cancelling with dispose(true).
      final lifecycle.DisposableStore picksDisposables =
          picksDisposable.value = lifecycle.DisposableStore();

      // Create new cancellation source for this run
      picksCts = picksDisposables.add(CancellationTokenSource(token));

      // Collect picks and support both long running and short or combined
      final CancellationToken picksToken = picksCts!.token;
      String picksFilter = picker.value.substring(prefix.length);

      if (options?.shouldSkipTrimPickFilter != true) {
        picksFilter = picksFilter.trim();
      }

      final Object? providedPicks =
          getPicks(picksFilter, picksDisposables, picksToken, runOptions);

      // 1:1: `const applyPicks = (picks: Picks<T>, skipEmpty?: boolean)`.
      // `Picks<T>` erases to `Object` here (see the `Pick` typedef).
      bool applyPicks(Object? picks, [bool? skipEmpty]) {
        List<Pick<T>> items;
        Object? activeItem;

        if (_isPicksWithActive(picks)) {
          final PicksWithActive<Object?> withActive =
              picks as PicksWithActive<Object?>;
          items = withActive.items;
          activeItem = withActive.active;
        } else {
          items = (picks as List).cast<Pick<T>>();
        }

        if (items.isEmpty) {
          if (skipEmpty == true) {
            return false;
          }

          // We show the no results pick if we have no input to prevent
          // completely empty pickers #172613
          final Object? noResultsPick = options?.noResultsPick;
          if ((picksFilter.isNotEmpty || picker.hideInput) &&
              noResultsPick != null) {
            if (isFunction(noResultsPick)) {
              items = <Pick<T>>[
                (noResultsPick as dynamic)(picksFilter) as Pick<T>,
              ];
            } else {
              items = <Pick<T>>[noResultsPick];
            }
          }
        }

        picker.items = items;
        if (activeItem != null) {
          picker.activeItems = <IQuickPickItem>[activeItem as IQuickPickItem];
        }

        return true;
      }

      // 1:1: `const applyFastAndSlowPicks = async (fastAndSlowPicks:
      // FastAndSlowPicks<T>)`; erased to `Object?` for the same reason as
      // [PicksWithActive].
      Future<void> applyFastAndSlowPicks(
          FastAndSlowPicks<Object?> fastAndSlowPicks) async {
        bool fastPicksApplied = false;
        bool slowPicksApplied = false;

        await Future.wait<void>(<Future<void>>[
          // Fast Picks: if `mergeDelay` is configured, in order to reduce
          // amount of flicker, we race against the slow picks over some delay
          // and then set the fast picks. If the slow picks are faster, we
          // reduce the flicker by only setting the items once.
          (() async {
            final int? mergeDelay = fastAndSlowPicks.mergeDelay;
            if (mergeDelay != null) {
              await (timeout(mergeDelay) as Future<void>);
              if (picksToken.isCancellationRequested) {
                return;
              }
            }

            if (!slowPicksApplied) {
              fastPicksApplied = applyPicks(
                  fastAndSlowPicks.picks, true /* skip over empty to reduce flicker */);
            }
          })(),

          // Slow Picks: we await the slow picks and then set them at once
          // together with the fast picks, but only if we actually have
          // additional results.
          (() async {
            picker.busy = true;
            try {
              final Picks<T> awaitedAdditionalPicks =
                  await fastAndSlowPicks.additionalPicks;
              if (picksToken.isCancellationRequested) {
                return;
              }

              List<Pick<T>> picks;
              Object? activePick;
              if (_isPicksWithActive(fastAndSlowPicks.picks)) {
                final PicksWithActive<Object?> fastWithActive =
                    fastAndSlowPicks.picks as PicksWithActive<Object?>;
                picks = fastWithActive.items;
                activePick = fastWithActive.active;
              } else {
                picks = (fastAndSlowPicks.picks as List).cast<Pick<T>>();
              }

              List<Pick<T>> additionalPicks;
              Object? additionalActivePick;
              if (_isPicksWithActive(awaitedAdditionalPicks)) {
                final PicksWithActive<Object?> slowWithActive =
                    awaitedAdditionalPicks as PicksWithActive<Object?>;
                additionalPicks = slowWithActive.items;
                additionalActivePick = slowWithActive.active;
              } else {
                additionalPicks =
                    (awaitedAdditionalPicks as List).cast<Pick<T>>();
              }

              if (additionalPicks.isNotEmpty || !fastPicksApplied) {
                // If we do not have any activePick or additionalActivePick we
                // try to preserve the currently active pick from the fast
                // results. This fixes an issue where the user might have made
                // a pick active before the additional results kick in.
                // See https://github.com/microsoft/vscode/issues/102480
                Object? fallbackActivePick;
                if (activePick == null && additionalActivePick == null) {
                  final IQuickPickItem? fallbackActivePickCandidate =
                      picker.activeItems.isNotEmpty
                          ? picker.activeItems[0]
                          : null;
                  if (fallbackActivePickCandidate != null &&
                      _indexOfIdentical<T>(
                              picks, fallbackActivePickCandidate) !=
                          -1) {
                    fallbackActivePick = fallbackActivePickCandidate;
                  }
                }

                applyPicks(PicksWithActive<Object?>(
                  items: <Pick<T>>[...picks, ...additionalPicks],
                  active: activePick ?? additionalActivePick ??
                      fallbackActivePick,
                ));
              }
            } finally {
              if (!picksToken.isCancellationRequested) {
                picker.busy = false;
              }

              slowPicksApplied = true;
            }
          })(),
        ]);
      }

      // No Picks
      if (providedPicks == null) {
        // Ignore
      }

      // Fast and Slow Picks
      else if (_isFastAndSlowPicks(providedPicks)) {
        await applyFastAndSlowPicks(
            providedPicks as FastAndSlowPicks<Object?>);
      }

      // Fast Picks
      else if (providedPicks is! Future) {
        applyPicks(providedPicks);
      }

      // Slow Picks
      else {
        picker.busy = true;
        try {
          final Object? awaitedPicks = await (providedPicks as dynamic);

          if (picksToken.isCancellationRequested) {
            return;
          }

          if (_isFastAndSlowPicks(awaitedPicks)) {
            await applyFastAndSlowPicks(awaitedPicks as FastAndSlowPicks<Object?>);
          } else {
            applyPicks(awaitedPicks as Picks<T>);
          }
        } finally {
          if (!picksToken.isCancellationRequested) {
            picker.busy = false;
          }
        }
      }
    }

    disposables.add(picker.onDidChangeValue((String _) {
      updatePickerItems();
    }));
    updatePickerItems();

    // Accept the pick on accept and hide picker
    disposables.add(picker.onDidAccept((IQuickPickDidAcceptEvent event) {
      final void Function(IQuickPickItem?, bool)? handleAccept =
          runOptions?.handleAccept;
      if (handleAccept != null) {
        if (!event.inBackground) {
          picker.hide(); // hide picker unless we accept in background
        }
        // TS passes `activeItems[0]`, which is `undefined` for an empty list.
        handleAccept(
          picker.activeItems.isNotEmpty ? picker.activeItems[0] : null,
          event.inBackground,
        );
        return;
      }

      final IQuickPickItem? item = picker.selectedItems.isNotEmpty
          ? picker.selectedItems[0]
          : null;
      final Object? acceptFn = (item as dynamic)?.accept;
      if (isFunction(acceptFn)) {
        final bool isAttachAction = isKeyModified(picker.keyMods) &&
            (item as dynamic).attach != null;
        if (isAttachAction) {
          (item as dynamic).attach(picker.keyMods, event);
          return;
        }
        if (!event.inBackground) {
          picker.hide(); // hide picker unless we accept in background
        }

        (item as dynamic).accept(picker.keyMods, event);
      }
    }));

    Future<void> buttonTrigger(
      IQuickInputButton button,
      Object? item,
    ) async {
      final Object? triggerFn = (item as dynamic)?.trigger;
      if (!isFunction(triggerFn)) {
        return;
      }

      final List<IQuickInputButton>? buttons = (item as dynamic).buttons;
      final int buttonIndex =
          buttons == null ? -1 : buttons.indexOf(button);
      if (buttonIndex >= 0) {
        final Object? result =
            (item as dynamic).trigger(buttonIndex, picker.keyMods);
        final Object? action =
            result is int ? result : await (result as dynamic);

        if (token.isCancellationRequested) {
          return;
        }

        switch (action) {
          case TriggerAction.NO_ACTION:
            break;
          case TriggerAction.CLOSE_PICKER:
            picker.hide();
            break;
          case TriggerAction.REFRESH_PICKER:
            updatePickerItems();
            break;
          case TriggerAction.REMOVE_ITEM:
            final List<Pick<T>> items =
                picker.items.cast<Pick<T>>();
            final int index = _indexOfIdentical<T>(items, item);
            if (index != -1) {
              final List<Pick<T>> spliced = items.toList();
              final List<Pick<T>> removed = spliced.sublist(index, index + 1);
              spliced.removeRange(index, index + 1);
              final List<IQuickPickItem> activeItems = picker.activeItems
                  .where((IQuickPickItem activeItem) =>
                      !identical(activeItem, removed[0]))
                  .toList();
              final bool keepScrollPositionBefore =
                  picker.keepScrollPosition;
              picker.keepScrollPosition = true;
              picker.items = spliced;
              picker.activeItems = activeItems;
              picker.keepScrollPosition = keepScrollPositionBefore;
            }
            break;
        }
      }
    }

    // Trigger the pick with button index if button triggered
    // 1:1: `event.button` / `event.item` are read structurally, exactly like
    // the TS interface shapes; Dart reads them dynamically since the public
    // carrier event classes are distinct types.
    disposables.add(picker.onDidTriggerItemButton((dynamic e) {
      buttonTrigger(e.button as IQuickInputButton, e.item);
    }));
    disposables.add(picker.onDidTriggerSeparatorButton((dynamic e) {
      buttonTrigger(e.button as IQuickInputButton, e.separator);
    }));

    return disposables;
  }

  /// Returns an array of picks and separators as needed. If the picks are
  /// resolved long running, the provided cancellation token should be used to
  /// cancel the operation when the token signals this.
  ///
  /// The implementor is responsible for filtering and sorting the picks given
  /// the provided `filter`.
  ///
  /// @param filter a filter to apply to the picks.
  /// @param disposables can be used to register disposables that should be
  /// cleaned up when the picker closes.
  /// @param token for long running tasks, implementors need to check on
  /// cancellation through this token.
  /// @returns the picks either directly, as promise or combined fast and slow
  /// results. Pickers can return `null` to signal that no change in picks is
  /// needed.
  /// TS: `protected abstract _getPicks(...)`. Dart library-private members
  /// cannot be overridden from other libraries, so the hook is public here.
  Object? getPicks(
    String filter,
    lifecycle.DisposableStore disposables,
    CancellationToken token, [
    IQuickAccessProviderRunOptions? runOptions,
  ]);
}
