// 1:1 port of
// vscode/src/vs/editor/browser/controller/editContext/native/nativeEditContextRegistry.ts
// @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
//
// Adaptations:
//   - `NativeEditContext` is still pending; the registry only stores it
//     opaquely, so the map/parameter/return types are `Object`.
//   - The TS object-literal disposable maps to `toDisposable`, which carries
//     the same `delete(ownerID)` closure.

import '../../../../../base/common/lifecycle.dart'
    show IDisposable, toDisposable;

/// 1:1: `class NativeEditContextRegistryImpl`
class NativeEditContextRegistryImpl {
  final Map<String, Object> _nativeEditContextMapping = <String, Object>{};

  IDisposable register(String ownerID, Object nativeEditContext) {
    _nativeEditContextMapping[ownerID] = nativeEditContext;
    return toDisposable(() {
      _nativeEditContextMapping.remove(ownerID);
    });
  }

  Object? get(String ownerID) {
    return _nativeEditContextMapping[ownerID];
  }
}

/// 1:1: `export const NativeEditContextRegistry`
final NativeEditContextRegistryImpl NativeEditContextRegistry =
    NativeEditContextRegistryImpl();
