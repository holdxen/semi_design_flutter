// 1:1 port of vscode/src/vs/platform/quickinput/common/quickAccess.ts
//
// Runtime surface: `DefaultQuickAccessFilterValue`, `Extensions`,
// `QuickAccessRegistry` and the module-level `Registry.add(...)` side effect.
// Everything else is type surface.
//
// Adaptations (documented inline):
//  * TS unions (`string | DefaultQuickAccessFilterValue`, `HTMLElement |
//    {x, y}`) → `Object` carriers.
//  * `Function` return of `clear()` → `void Function()`.
//  * Module-level `Registry.add(...)` → lazy final (port-wide convention).
import '../../../base/common/arrays.dart' show coalesce;
import '../../../base/common/cancellation.dart' show CancellationToken;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../contextkey/common/contextkey.dart'
    show ContextKeyExpression, IContextKeyServiceType;
import '../../registry/common/platform.dart' as registry;
import './quickInput.dart'
    show
        IQuickNavigateConfiguration,
        IQuickPick,
        IQuickPickItem,
        QuickPickItem;

/// Provider specific options for this particular showing of the quick access.
///
/// 1:1: `export interface IQuickAccessProviderRunOptions`.
class IQuickAccessProviderRunOptions {
  IQuickAccessProviderRunOptions({
    this.from,
    this.placeholder,
    this.handleAccept,
  });

  final String? from;
  final String? placeholder;

  /// A handler to invoke when an item is accepted for this particular showing
  /// of the quick access.
  ///
  /// TS declares `item: IQuickPickItem`, but the single call site
  /// (`pickerQuickAccess.ts`) passes `picker.activeItems[0]`, which is
  /// `undefined` for an empty list; the port keeps that possibility.
  final void Function(IQuickPickItem? item, bool isBackgroundAccept)?
      handleAccept;
}

/// 1:1: `export interface AnythingQuickAccessProviderRunOptions extends
/// IQuickAccessProviderRunOptions`.
class AnythingQuickAccessProviderRunOptions
    extends IQuickAccessProviderRunOptions {
  AnythingQuickAccessProviderRunOptions({
    super.from,
    super.placeholder,
    super.handleAccept,
    this.includeHelp,
    this.filter,
    this.additionPicks,
  });

  final bool? includeHelp;
  final bool Function(Object item)? filter;
  final List<QuickPickItem>? additionPicks;
}

/// 1:1: `export interface IQuickAccessOptions`.
class IQuickAccessOptions {
  IQuickAccessOptions({
    this.providerPrefix,
    this.anchor,
    this.anchorPosition,
    this.quickNavigateConfiguration,
    this.itemActivation,
    this.preserveValue,
    this.providerOptions,
    this.enabledProviderPrefixes,
    this.placeholder,
  });

  final String? providerPrefix;

  /// `HTMLElement | { x: number; y: number }`.
  final Object? anchor;

  /// `'above' | 'below' | 'overlay'`.
  final String? anchorPosition;
  final IQuickNavigateConfiguration? quickNavigateConfiguration;
  final int? itemActivation;
  final bool? preserveValue;
  final IQuickAccessProviderRunOptions? providerOptions;
  final List<String>? enabledProviderPrefixes;
  final String? placeholder;
}

/// 1:1: `export interface IQuickAccessController`.
abstract class IQuickAccessController {
  void show([String? value, IQuickAccessOptions? options]);

  /// Same as `show()` but instead of executing the selected pick item, it will
  /// be returned. May return `undefined` in case no item was picked by the
  /// user.
  Future<List<IQuickPickItem>?> pick(
      [String? value, IQuickAccessOptions? options]);
}

/// 1:1: `export enum DefaultQuickAccessFilterValue`.
class DefaultQuickAccessFilterValue {
  /// Keep the value as it is given to quick access.
  static const int PRESERVE = 0;

  /// Use the value that was used last time something was accepted from the
  /// picker.
  static const int LAST = 1;

  const DefaultQuickAccessFilterValue._();
}

/// 1:1: `export interface IQuickAccessProvider`.
abstract class IQuickAccessProvider {
  /// Allows to set a default filter value when the provider opens. This can be:
  /// - `undefined` to not specify any default value
  /// - `DefaultFilterValues.PRESERVE` to use the value that was last typed
  /// - `string` for the actual value to use
  ///
  /// Note: the default filter will only be used if quick access was opened with
  /// the exact prefix of the provider. Otherwise the filter value is preserved.
  Object? get defaultFilterValue;

  /// Called whenever a prefix was typed into quick pick that matches the
  /// provider.
  lifecycle.IDisposable provide(
    IQuickPick<IQuickPickItem> picker,
    CancellationToken token, [
    IQuickAccessProviderRunOptions? options,
  ]);
}

/// 1:1: `export interface IQuickAccessProviderHelp`.
class IQuickAccessProviderHelp {
  IQuickAccessProviderHelp({
    this.prefix,
    required this.description,
    this.commandId,
    this.commandCenterOrder,
    this.commandCenterLabel,
  });

  /// The prefix to show for the help entry. If not provided, the prefix used
  /// for registration will be taken.
  final String? prefix;

  /// A description text to help understand the intent of the provider.
  final String description;

  /// The command to bring up this quick access provider.
  final String? commandId;

  /// The order of help entries in the Command Center.
  final int? commandCenterOrder;

  /// An optional label to use for the Command Center entry.
  final String? commandCenterLabel;
}

/// 1:1: `export interface IQuickAccessProviderDescriptor`.
class IQuickAccessProviderDescriptor {
  IQuickAccessProviderDescriptor({
    required this.ctor,
    required this.prefix,
    this.placeholder,
    required this.helpEntries,
    this.contextKey,
    this.when,
  });

  /// The actual provider that will be instantiated as needed.
  final Object ctor;

  /// The prefix for quick access picker to use the provider for.
  final String prefix;

  /// A placeholder to use for the input field when the provider is active.
  final String? placeholder;

  /// Documentation for the provider in the quick access help.
  final List<IQuickAccessProviderHelp> helpEntries;

  /// A context key that will be set automatically when the picker for the
  /// provider is showing.
  final String? contextKey;

  /// A context key expression that must evaluate to true for the provider to
  /// be considered in the registry.
  final ContextKeyExpression? when;
}

/// 1:1: `export const Extensions`.
class Extensions {
  static const String Quickaccess = 'workbench.contributions.quickaccess';

  const Extensions._();
}

/// 1:1: `export interface IQuickAccessRegistry`.
abstract class IQuickAccessRegistry {
  /// Registers a quick access provider to the platform.
  lifecycle.IDisposable registerQuickAccessProvider(
      IQuickAccessProviderDescriptor provider);

  /// Get all registered quick access providers.
  List<IQuickAccessProviderDescriptor> getQuickAccessProviders(
      IContextKeyServiceType contextKeyService);

  /// Get a specific quick access provider for a given prefix.
  IQuickAccessProviderDescriptor? getQuickAccessProvider(
      String prefix, IContextKeyServiceType contextKeyService);
}

/// 1:1: `export class QuickAccessRegistry implements IQuickAccessRegistry`.
class QuickAccessRegistry implements IQuickAccessRegistry {
  List<IQuickAccessProviderDescriptor> _providers =
      <IQuickAccessProviderDescriptor>[];
  IQuickAccessProviderDescriptor? _defaultProvider;

  @override
  lifecycle.IDisposable registerQuickAccessProvider(
      IQuickAccessProviderDescriptor provider) {
    // Extract the default provider when no prefix is present
    if (provider.prefix.isEmpty) {
      _defaultProvider = provider;
    } else {
      _providers.add(provider);
    }

    // sort the providers by decreasing prefix length, such that longer
    // prefixes take priority: 'ext' vs 'ext install' - the latter should win
    _providers.sort((IQuickAccessProviderDescriptor providerA,
            IQuickAccessProviderDescriptor providerB) =>
        providerB.prefix.length - providerA.prefix.length);

    return lifecycle.toDisposable(() {
      // TS uses `splice(indexOf(provider), 1)`: `indexOf` is -1 for the
      // default provider, which makes `splice(-1, 1)` drop the LAST prefixed
      // provider. The quirk is preserved (see batch194 truth).
      final int index = _providers.indexOf(provider);
      if (index >= 0) {
        _providers.removeAt(index);
      } else if (_providers.isNotEmpty) {
        _providers.removeLast();
      }

      if (identical(_defaultProvider, provider)) {
        _defaultProvider = null;
      }
    });
  }

  @override
  List<IQuickAccessProviderDescriptor> getQuickAccessProviders(
      IContextKeyServiceType contextKeyService) {
    return coalesce<IQuickAccessProviderDescriptor>(
            <IQuickAccessProviderDescriptor?>[_defaultProvider, ..._providers])
        .where((IQuickAccessProviderDescriptor provider) =>
            provider.when == null ||
            contextKeyService.contextMatchesRules(provider.when))
        .toList();
  }

  @override
  IQuickAccessProviderDescriptor? getQuickAccessProvider(
      String prefix, IContextKeyServiceType contextKeyService) {
    final IQuickAccessProviderDescriptor? result = prefix.isNotEmpty
        ? _providers
            .where((IQuickAccessProviderDescriptor provider) =>
                prefix.startsWith(provider.prefix) &&
                (provider.when == null ||
                    contextKeyService.contextMatchesRules(provider.when)))
            .cast<IQuickAccessProviderDescriptor?>()
            .firstOrNull
        : null;

    return result ?? _defaultProvider;
  }

  void Function() clear() {
    final List<IQuickAccessProviderDescriptor> providers = _providers.toList();
    final IQuickAccessProviderDescriptor? defaultProvider = _defaultProvider;

    _providers = <IQuickAccessProviderDescriptor>[];
    _defaultProvider = null;

    return () {
      _providers = providers;
      _defaultProvider = defaultProvider;
    };
  }
}

/// 1:1: module-level
/// `Registry.add(Extensions.Quickaccess, new QuickAccessRegistry());`
/// side effect (lazy final per the port-wide convention).
final QuickAccessRegistry quickAccessRegistryRegistration =
    _registerQuickAccessRegistry();

QuickAccessRegistry _registerQuickAccessRegistry() {
  final QuickAccessRegistry quickAccessRegistry = QuickAccessRegistry();
  registry.Registry.add(Extensions.Quickaccess, quickAccessRegistry);
  return quickAccessRegistry;
}