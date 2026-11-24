// 1:1 port of
// vscode/src/vs/platform/accessibility/browser/accessibleViewRegistry.ts
//
// A process-wide list of accessible-view implementations plus the disposable
// returned by `register`.
//
// Adaptations (documented inline):
//  * TS `AccessibleContentProvider | ExtensionContentProvider | undefined` →
//    `Object?` (Dart has no unions).
//  * The TS `new class { ... }` anonymous instance is a private class behind a
//    final so the exported name stays `AccessibleViewRegistry`.
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../contextkey/common/contextkey.dart' as contextkey;
import '../../instantiation/common/instantiation.dart' show ServicesAccessor;

/// 1:1: `export interface IAccessibleViewImplementation`.
class IAccessibleViewImplementation {
  IAccessibleViewImplementation({
    required this.type,
    required this.priority,
    required this.name,
    required this.getProvider,
    this.when,
  });

  /// `AccessibleViewType` (a `String` const carrier in this port).
  String type;
  int priority;
  String name;

  /// Returns the provider or `null` if the view should not be shown.
  ///
  /// TS: `AccessibleContentProvider | ExtensionContentProvider | undefined`.
  Object? Function(ServicesAccessor accessor) getProvider;

  contextkey.ContextKeyExpression? when;
}

/// 1:1: the anonymous `new class AccessibleViewRegistry { ... }` behind the
/// exported instance. The port gives it a name (`Impl`) because the exported
/// constant already owns `AccessibleViewRegistry`.
class AccessibleViewRegistryImpl {
  final List<IAccessibleViewImplementation> _implementations =
      <IAccessibleViewImplementation>[];

  lifecycle.IDisposable register(IAccessibleViewImplementation implementation) {
    _implementations.add(implementation);
    // TS returns an object literal with a `dispose` method that splices the
    // first occurrence (`indexOf` is -1 once it was removed, so a second
    // dispose is a no-op).
    return lifecycle.toDisposable(() {
      final int idx = _implementations.indexOf(implementation);
      if (idx != -1) {
        _implementations.removeAt(idx);
      }
    });
  }

  /// Returns the live list (TS hands back `this._implementations`, not a copy).
  List<IAccessibleViewImplementation> getImplementations() {
    return _implementations;
  }
}

/// 1:1: `export const AccessibleViewRegistry`.
final AccessibleViewRegistryImpl AccessibleViewRegistry =
    AccessibleViewRegistryImpl();
