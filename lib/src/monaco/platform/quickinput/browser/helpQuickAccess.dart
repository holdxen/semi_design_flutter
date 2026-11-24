// 1:1 port of vscode/src/vs/platform/quickinput/browser/helpQuickAccess.ts
//
// Carriers: the batch194 `platform/quickinput/common` ports, `Registry`,
// `DisposableStore` and `localize` are used as-is.
//
// Adaptations (documented inline):
//  * `interface IHelpQuickAccessPickItem extends IQuickPickItem { prefix }` →
//    a private `IQuickPickItem` subclass carrying `prefix`.
//  * `provide(picker)` only takes the picker in TS; Dart overrides must match
//    the interface arity, so the (unused) cancellation token and run options
//    are accepted.
//  * `value.substr(PREFIX.length)` clamps like JS `substr`.
import 'dart:math' show min;

import '../../../base/common/cancellation.dart' show CancellationToken;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../nls.dart' show localize;
import '../../contextkey/common/contextkey.dart' show IContextKeyServiceType;
import '../../keybinding/common/keybinding.dart' show IKeybindingServiceType;
import '../../registry/common/platform.dart' as registry;
import '../common/quickAccess.dart'
    show
        Extensions,
        IQuickAccessOptions,
        IQuickAccessProvider,
        IQuickAccessProviderDescriptor,
        IQuickAccessProviderHelp,
        IQuickAccessProviderRunOptions,
        IQuickAccessRegistry,
        quickAccessRegistryRegistration;
import '../common/quickInput.dart'
    show
        IQuickInputServiceType,
        IQuickPick,
        IQuickPickDidAcceptEvent,
        IQuickPickItem;

/// 1:1: `interface IHelpQuickAccessPickItem extends IQuickPickItem {
/// readonly prefix: string }`.
class _HelpQuickAccessPickItem extends IQuickPickItem {
  _HelpQuickAccessPickItem({
    required super.label,
    super.ariaLabel,
    super.description,
    super.keybinding,
    required this.prefix,
  });

  final String prefix;
}

/// 1:1: `const helpPickAriaLabel` NLS key: `'{0}, {1}'`.
const String _helpPickAriaLabelKey = 'helpPickAriaLabel';
const String _helpPickAriaLabelMessage = '{0}, {1}';

/// The `Registry.as` read needs the lazy module-level registration of
/// `common/quickAccess.ts` to have run (batch194 convention).
IQuickAccessRegistry _quickAccessRegistry() {
  final Object? registered = registry.Registry.as(Extensions.Quickaccess) ??
      quickAccessRegistryRegistration;
  return registered as IQuickAccessRegistry;
}

/// 1:1: `export class HelpQuickAccessProvider implements
/// IQuickAccessProvider`.
class HelpQuickAccessProvider implements IQuickAccessProvider {
  HelpQuickAccessProvider(
    this._quickInputService,
    this._keybindingService,
    this._contextKeyService,
  );

  static const String PREFIX = '?';

  final IQuickInputServiceType _quickInputService;
  final IKeybindingServiceType _keybindingService;
  final IContextKeyServiceType _contextKeyService;

  final IQuickAccessRegistry _registry = _quickAccessRegistry();

  @override
  Object? get defaultFilterValue => null;

  @override
  lifecycle.IDisposable provide(
    IQuickPick<IQuickPickItem> picker,
    CancellationToken token, [
    IQuickAccessProviderRunOptions? options,
  ]) {
    final lifecycle.DisposableStore disposables = lifecycle.DisposableStore();

    // Open a picker with the selected value if picked
    disposables.add(picker.onDidAccept((IQuickPickDidAcceptEvent _) {
      final List<IQuickPickItem> selectedItems = picker.selectedItems;
      final IQuickPickItem? item =
          selectedItems.isEmpty ? null : selectedItems.first;
      if (item != null) {
        _quickInputService.quickAccess.show(
          (item as dynamic).prefix as String,
          IQuickAccessOptions(preserveValue: true),
        );
      }
    }));

    // Also open a picker when we detect the user typed the exact
    // name of a provider (e.g. `?term` for terminals)
    disposables.add(picker.onDidChangeValue((String value) {
      final int from = min(value.length, HelpQuickAccessProvider.PREFIX.length);
      final IQuickAccessProviderDescriptor? providerDescriptor =
          _registry.getQuickAccessProvider(
        value.substring(from),
        _contextKeyService,
      );
      if (providerDescriptor != null &&
          providerDescriptor.prefix.isNotEmpty &&
          providerDescriptor.prefix != HelpQuickAccessProvider.PREFIX) {
        _quickInputService.quickAccess.show(
          providerDescriptor.prefix,
          IQuickAccessOptions(preserveValue: true),
        );
      }
    }));

    // Fill in all providers
    picker.items = getQuickAccessProviders()
        .where((_HelpQuickAccessPickItem provider) =>
            provider.prefix != HelpQuickAccessProvider.PREFIX)
        .cast<Object>()
        .toList();

    return disposables;
  }

  List<_HelpQuickAccessPickItem> getQuickAccessProviders() {
    final List<IQuickAccessProviderDescriptor> providers =
        _registry.getQuickAccessProviders(_contextKeyService)
            // TS `localeCompare` on the prefix; the registered prefixes are
            // plain ASCII in practice, so `compareTo` is equivalent here.
            .toList()
          ..sort((IQuickAccessProviderDescriptor providerA,
                  IQuickAccessProviderDescriptor providerB) =>
              providerA.prefix.compareTo(providerB.prefix));

    final List<_HelpQuickAccessPickItem> picks = <_HelpQuickAccessPickItem>[];
    for (final IQuickAccessProviderDescriptor provider in providers) {
      picks.addAll(_createPicks(provider));
    }
    return picks;
  }

  List<_HelpQuickAccessPickItem> _createPicks(
      IQuickAccessProviderDescriptor provider) {
    final List<_HelpQuickAccessPickItem> picks = <_HelpQuickAccessPickItem>[];
    for (final IQuickAccessProviderHelp helpEntry in provider.helpEntries) {
      // TS `helpEntry.prefix || provider.prefix` — an empty explicit prefix
      // falls back to the provider prefix (JS truthiness).
      final String prefix = (helpEntry.prefix != null &&
              helpEntry.prefix!.isNotEmpty)
          ? helpEntry.prefix!
          : provider.prefix;
      final String label = prefix.isNotEmpty ? prefix : '\u2026' /* ... */;

      picks.add(_HelpQuickAccessPickItem(
        prefix: prefix,
        label: label,
        keybinding: helpEntry.commandId != null
            ? _keybindingService.lookupKeybinding(helpEntry.commandId!)
            : null,
        ariaLabel: localize(_helpPickAriaLabelKey, _helpPickAriaLabelMessage,
            <Object?>[label, helpEntry.description]),
        description: helpEntry.description,
      ));
    }
    return picks;
  }
}
