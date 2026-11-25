// 1:1 port of
// vscode/src/vs/editor/browser/controller/editContext/textArea/textAreaEditContextRegistry.ts
// @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
//
// Adaptations:
//   - `TextAreaEditContext` is still pending; the registry only stores it
//     opaquely, so the map/parameter/return types are `Object`.
//   - The TS object-literal disposable maps to `toDisposable`, which carries
//     the same `delete(ownerID)` closure.

import '../../../../../base/common/lifecycle.dart'
    show IDisposable, toDisposable;

/// 1:1: `class TextAreaEditContextRegistryImpl`
class TextAreaEditContextRegistryImpl {
  final Map<String, Object> _textAreaEditContextMapping = <String, Object>{};

  IDisposable register(String ownerID, Object textAreaEditContext) {
    _textAreaEditContextMapping[ownerID] = textAreaEditContext;
    return toDisposable(() {
      _textAreaEditContextMapping.remove(ownerID);
    });
  }

  Object? get(String ownerID) {
    return _textAreaEditContextMapping[ownerID];
  }
}

/// 1:1: `export const TextAreaEditContextRegistry`
final TextAreaEditContextRegistryImpl TextAreaEditContextRegistry =
    TextAreaEditContextRegistryImpl();
