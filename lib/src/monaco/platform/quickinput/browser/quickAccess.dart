// 1:1 port of vscode/src/vs/platform/quickinput/browser/quickAccess.ts
//
// Carriers: `DeferredPromise`/`CancellationTokenSource`, `Disposable`/
// `DisposableStore`/`toDisposable`/`isDisposable`, `eventOnce`, the
// batch194 `platform/quickinput/common` ports and `Registry` are used as-is.
//
// Adaptations (documented inline):
//  * TS `const [provider, descriptor] = ...` → Dart record destructuring.
//  * TS `createQuickPick({ useSeparators: true })` object literal → the same
//    shape as a `const Map<String, Object?>`.
//  * `Promise<IQuickPickItem[] | undefined>` → `Future<List<IQuickPickItem>?>`;
//    the `pick`/`show` overload pair collapses into one private method that
//    returns the promise only in pick mode.
import 'dart:math' show min;

import '../../../base/common/async.dart' show DeferredPromise;
import '../../../base/common/cancellation.dart' show CancellationTokenSource;
import '../../../base/common/event.dart' show eventOnce;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../contextkey/common/contextkey.dart' show IContextKeyServiceType;
import '../../instantiation/common/instantiation.dart'
    show IInstantiationServiceType;
import '../../registry/common/platform.dart' as registry;
import '../common/quickAccess.dart'
    show
        DefaultQuickAccessFilterValue,
        Extensions,
        IQuickAccessController,
        IQuickAccessOptions,
        IQuickAccessProvider,
        IQuickAccessProviderDescriptor,
        IQuickAccessRegistry,
        quickAccessRegistryRegistration;
import '../common/quickInput.dart'
    show
        IQuickInputServiceType,
        IQuickPick,
        IQuickPickDidAcceptEvent,
        IQuickPickItem,
        IQuickPickWillAcceptEvent,
        ItemActivation;

/// TS registers the quick access registry through the import side effect of
/// `platform/quickinput/common/quickAccess.ts`; the Dart port keeps that as a
/// lazy final, so reading it back also triggers the registration.
IQuickAccessRegistry _quickAccessRegistry() {
  final Object? registered = registry.Registry.as(Extensions.Quickaccess) ??
      quickAccessRegistryRegistration;
  return registered as IQuickAccessRegistry;
}

/// TS: anonymous type of `this.visibleQuickAccess`; `value` is reassigned as
/// the user types while `picker`/`descriptor` stay fixed for that showing.
class _VisibleQuickAccess {
  _VisibleQuickAccess(this.picker, this.descriptor, this.value);

  final IQuickPick<IQuickPickItem> picker;
  final IQuickAccessProviderDescriptor? descriptor;
  String value;
}

/// 1:1: `export class QuickAccessController extends Disposable implements
/// IQuickAccessController`.
class QuickAccessController extends lifecycle.Disposable
    implements IQuickAccessController {
  QuickAccessController(
    this.quickInputService,
    this.instantiationService,
    this.contextKeyService,
  ) : super() {
    // 1:1: `private readonly registry =
    // Registry.as<IQuickAccessRegistry>(Extensions.Quickaccess)`.
    register(lifecycle.toDisposable(() {
      for (final IQuickAccessProvider provider
          in _mapProviderToDescriptor.values) {
        if (lifecycle.isDisposable(provider)) {
          (provider as lifecycle.IDisposable).dispose();
        }
      }

      _visibleQuickAccess?.picker.dispose();
    }));
  }

  final IQuickInputServiceType quickInputService;
  final IInstantiationServiceType instantiationService;
  final IContextKeyServiceType contextKeyService;

  final IQuickAccessRegistry _registry = _quickAccessRegistry();

  final Map<IQuickAccessProviderDescriptor, IQuickAccessProvider>
      _mapProviderToDescriptor =
      <IQuickAccessProviderDescriptor, IQuickAccessProvider>{};

  final Map<IQuickAccessProviderDescriptor, String> _lastAcceptedPickerValues =
      <IQuickAccessProviderDescriptor, String>{};

  _VisibleQuickAccess? _visibleQuickAccess;

  @override
  Future<List<IQuickPickItem>?> pick(
      [String? value, IQuickAccessOptions? options]) {
    final Object? result = _doShowOrPick(value ?? '', true, options);
    // TS annotates the method as returning a promise while the shared
    // implementation returns `undefined` for the "same prefix is already
    // showing" early exit; Dart resolves `null` instead of surfacing a type
    // error to the caller.
    return result is Future<List<IQuickPickItem>?>
        ? result
        : Future<List<IQuickPickItem>?>.value(null);
  }

  @override
  void show([String? value, IQuickAccessOptions? options]) {
    _doShowOrPick(value ?? '', false, options);
  }

  /// TS overloads: `doShowOrPick(value, true, options)` returns the promise,
  /// `doShowOrPick(value, false, options)` returns `void`.
  Object? _doShowOrPick(
    String value,
    bool pick, [
    IQuickAccessOptions? options,
  ]) {
    // Find provider for the value to show
    final (
      IQuickAccessProvider? provider,
      IQuickAccessProviderDescriptor? descriptor,
    ) = _getOrInstantiateProvider(
      value,
      options?.enabledProviderPrefixes,
      options?.providerPrefix,
    );

    // Return early if quick access is already showing on that same prefix
    final _VisibleQuickAccess? visibleQuickAccess = _visibleQuickAccess;
    final IQuickAccessProviderDescriptor? visibleDescriptor =
        visibleQuickAccess?.descriptor;
    if (visibleQuickAccess != null &&
        descriptor != null &&
        identical(visibleDescriptor, descriptor)) {
      // Apply value only if it is more specific than the prefix
      // from the provider and we are not instructed to preserve
      if (value != descriptor.prefix && options?.preserveValue != true) {
        visibleQuickAccess.picker.value = value;
      }

      // Always adjust selection
      _adjustValueSelection(visibleQuickAccess.picker, descriptor, options);

      return null;
    }

    // Rewrite the filter value based on certain rules unless disabled
    if (descriptor != null && options?.preserveValue != true) {
      String? newValue;

      // If we have a visible provider with a value, take it's filter value but
      // rewrite to new provider prefix in case they differ
      if (visibleQuickAccess != null &&
          visibleDescriptor != null &&
          !identical(visibleDescriptor, descriptor)) {
        // TS `substr(prefix.length)` clamps at the end of the string.
        final int from = min(
            visibleQuickAccess.value.length, visibleDescriptor.prefix.length);
        final String newValueCandidateWithoutPrefix =
            visibleQuickAccess.value.substring(from);
        if (newValueCandidateWithoutPrefix.isNotEmpty) {
          newValue = '${descriptor.prefix}$newValueCandidateWithoutPrefix';
        }
      }

      // Otherwise, take a default value as instructed
      if (newValue == null) {
        final Object? defaultFilterValue = provider?.defaultFilterValue;
        if (defaultFilterValue == DefaultQuickAccessFilterValue.LAST) {
          newValue = _lastAcceptedPickerValues[descriptor];
        } else if (defaultFilterValue is String) {
          newValue = '${descriptor.prefix}$defaultFilterValue';
        }
      }

      if (newValue is String) {
        value = newValue;
      }
    }

    // Store the existing selection if there was one.
    final List<num>? visibleSelection =
        visibleQuickAccess?.picker.valueSelection;
    final String? visibleValue = visibleQuickAccess?.picker.value;

    // Create a picker for the provider to use with the initial value
    // and adjust the filtering to exclude the prefix from filtering
    final lifecycle.DisposableStore disposables = lifecycle.DisposableStore();
    final IQuickPick<IQuickPickItem> picker = disposables.add(
      quickInputService.createQuickPick(
        const <String, Object?>{'useSeparators': true},
      ),
    );
    picker.value = value;
    _adjustValueSelection(picker, descriptor, options);
    picker.placeholder = options?.placeholder ?? descriptor?.placeholder;
    picker.anchor = options?.anchor;
    picker.anchorPosition = options?.anchorPosition;
    picker.quickNavigate = options?.quickNavigateConfiguration;
    // only hide input if there was no picker opened already
    picker.hideInput =
        picker.quickNavigate != null && visibleQuickAccess == null;
    if (options?.itemActivation != null ||
        options?.quickNavigateConfiguration != null) {
      picker.itemActivation =
          options?.itemActivation ?? ItemActivation.SECOND; // quick nav is always second
    }
    picker.contextKey = descriptor?.contextKey;
    picker.filterValue = (String value) {
      final int from = descriptor == null
          ? 0
          : min(value.length, descriptor.prefix.length);
      return value.substring(from);
    };

    // Pick mode: setup a promise that can be resolved
    // with the selected items and prevent execution
    DeferredPromise<List<IQuickPickItem>>? pickPromise;
    if (pick) {
      pickPromise = DeferredPromise<List<IQuickPickItem>>();
      disposables.add(eventOnce(picker.onWillAccept)(
          (IQuickPickWillAcceptEvent e) {
        e.veto();
        picker.hide();
      }));
    }

    // Register listeners
    disposables.add(
        _registerPickerListeners(picker, provider, descriptor, value, options));

    // Ask provider to fill the picker as needed if we have one
    // and pass over a cancellation token that will indicate when
    // the picker is hiding without a pick being made.
    final CancellationTokenSource cts =
        disposables.add(CancellationTokenSource());
    if (provider != null) {
      disposables.add(
          provider.provide(picker, cts.token, options?.providerOptions));
    }

    // Finally, trigger disposal and cancellation when the picker
    // hides depending on items selected or not.
    eventOnce(picker.onDidHide)((dynamic _) {
      if (picker.selectedItems.isEmpty) {
        cts.cancel();
      }

      // Start to dispose once picker hides
      disposables.dispose();

      // Resolve pick promise with selected items
      pickPromise?.complete(picker.selectedItems.toList());
    });

    // Finally, show the picker. This is important because a provider
    // may not call this and then our disposables would leak that rely
    // on the onDidHide event.
    picker.show();

    // If the previous picker had a selection and the value is unchanged, we
    // should set that in the new picker.
    if (visibleSelection != null && visibleValue == value) {
      picker.valueSelection = visibleSelection;
    }

    // Pick mode: return with promise
    if (pick) {
      return pickPromise?.p;
    }
    return null;
  }

  void _adjustValueSelection(
    IQuickPick<IQuickPickItem> picker, [
    IQuickAccessProviderDescriptor? descriptor,
    IQuickAccessOptions? options,
  ]) {
    // `[number, number]` in TS; Dart keeps the same `List<num>` carrier.
    final List<num> valueSelection;

    // Preserve: just always put the cursor at the end
    if (options?.preserveValue == true) {
      valueSelection = <num>[picker.value.length, picker.value.length];
    }

    // Otherwise: select the value up until the prefix
    else {
      valueSelection = <num>[
        descriptor?.prefix.length ?? 0,
        picker.value.length
      ];
    }

    picker.valueSelection = valueSelection;
  }

  lifecycle.IDisposable _registerPickerListeners(
    IQuickPick<IQuickPickItem> picker,
    IQuickAccessProvider? provider,
    IQuickAccessProviderDescriptor? descriptor,
    String value, [
    IQuickAccessOptions? options,
  ]) {
    final lifecycle.DisposableStore disposables = lifecycle.DisposableStore();

    // Remember as last visible picker and clean up once picker get's disposed
    final _VisibleQuickAccess visibleQuickAccess =
        _visibleQuickAccess = _VisibleQuickAccess(picker, descriptor, value);
    disposables.add(lifecycle.toDisposable(() {
      if (identical(visibleQuickAccess, _visibleQuickAccess)) {
        _visibleQuickAccess = null;
      }
    }));

    // Whenever the value changes, check if the provider has
    // changed and if so - re-create the picker from the beginning
    disposables.add(picker.onDidChangeValue((String value) {
      final (IQuickAccessProvider? providerForValue, _) =
          _getOrInstantiateProvider(
        value,
        options?.enabledProviderPrefixes,
        options?.providerPrefix,
      );
      if (!identical(providerForValue, provider)) {
        show(
          value,
          IQuickAccessOptions(
            enabledProviderPrefixes: options?.enabledProviderPrefixes,
            providerPrefix: options?.providerPrefix,
            // do not rewrite value from user typing!
            preserveValue: true,
            // persist the value of the providerOptions from the original showing
            providerOptions: options?.providerOptions,
          ),
        );
      } else {
        visibleQuickAccess.value = value; // remember the value in our visible one
      }
    }));

    // Remember picker input for future use when accepting
    if (descriptor != null) {
      disposables.add(picker.onDidAccept((IQuickPickDidAcceptEvent _) {
        _lastAcceptedPickerValues[descriptor] = picker.value;
      }));
    }

    return disposables;
  }

  (IQuickAccessProvider?, IQuickAccessProviderDescriptor?)
      _getOrInstantiateProvider(
    String value, [
    List<String>? enabledProviderPrefixes,
    String? providerPrefix,
  ]) {
    final IQuickAccessProviderDescriptor? providerDescriptor =
        _registry.getQuickAccessProvider(
      providerPrefix ?? value,
      contextKeyService,
    );
    if (providerDescriptor == null ||
        (enabledProviderPrefixes != null &&
            !enabledProviderPrefixes.contains(providerDescriptor.prefix))) {
      return (null, null);
    }

    IQuickAccessProvider? provider =
        _mapProviderToDescriptor[providerDescriptor];
    if (provider == null) {
      provider = instantiationService.createInstance(
        providerDescriptor.ctor,
        const <Object?>[],
      ) as IQuickAccessProvider;
      _mapProviderToDescriptor[providerDescriptor] = provider;
    }

    return (provider, providerDescriptor);
  }
}
