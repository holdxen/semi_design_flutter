// 1:1 port of
// vscode/src/vs/editor/standalone/browser/quickAccess/standaloneHelpQuickAccess.ts
// @bfbf12b
//
// Carriers: the batch197 `platform/quickinput/common/quickAccess` registry, the
// batch201 `helpQuickAccess` provider, `Registry` and `QuickHelpNLS` are used
// as-is. Translated 1:1 from TypeScript. Do not refactor.
//
// Adaptations (documented inline):
//  * TS module top-level statement (`Registry.as(...).registerQuickAccessProvider`)
//    → a top-level `final` whose initializer runs the same registration once,
//    like `quickAccessRegistryRegistration` in `common/quickAccess.dart`.
import '../../../../platform/quickinput/browser/helpQuickAccess.dart'
    show HelpQuickAccessProvider;
import '../../../../platform/quickinput/common/quickAccess.dart'
    show
        Extensions,
        IQuickAccessProviderDescriptor,
        IQuickAccessProviderHelp,
        IQuickAccessRegistry,
        quickAccessRegistryRegistration;
import '../../../../base/common/lifecycle.dart' as lifecycle;
import '../../../../platform/registry/common/platform.dart' as registry;
import '../../../common/standaloneStrings.dart' show QuickHelpNLS;

/// The `Registry.as` read needs the lazy module-level registration of
/// `common/quickAccess.dart` to have run (batch194/197 convention).
IQuickAccessRegistry _quickAccessRegistry() {
  final Object? registered = registry.Registry.as(Extensions.Quickaccess) ??
      quickAccessRegistryRegistration;
  return registered as IQuickAccessRegistry;
}

/// 1:1: the module top-level registration (returns the registration disposable).
lifecycle.IDisposable _registerStandaloneHelpQuickAccess() {
  return _quickAccessRegistry().registerQuickAccessProvider(
    IQuickAccessProviderDescriptor(
      ctor: HelpQuickAccessProvider,
      prefix: '',
      helpEntries: <IQuickAccessProviderHelp>[
        IQuickAccessProviderHelp(
            description: QuickHelpNLS.helpQuickAccessActionLabel)
      ],
    ),
  );
}

/// 1:1: the module top-level registration.
// ignore: unused_element
final lifecycle.IDisposable standaloneHelpQuickAccessRegistration =
    _registerStandaloneHelpQuickAccess();