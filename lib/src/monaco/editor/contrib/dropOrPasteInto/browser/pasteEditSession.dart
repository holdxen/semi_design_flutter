// ---------------------------------------------------------------------------
// 1:1 port of
// vscode/src/vs/editor/contrib/dropOrPasteInto/browser/pasteEditSession.ts
// (22 lines).
//
// Adaptations:
//   - `DocumentPasteEdit` is an erased interface, hence the unconstrained type
//     parameter `T`.
//   - `this._register(new MutableDisposable())` is a field initializer in TS;
//     Dart forbids `this` in initializers, so it becomes a `late final` with the
//     same one-shot evaluation.
// ---------------------------------------------------------------------------

import '../../../../base/common/lifecycle.dart'
    show Disposable, IDisposable, MutableDisposable;

/// Owns cached paste edits until they are disposed or transferred to another
/// session.
class PasteEditSession<T> extends Disposable {
  PasteEditSession(this.edits, IDisposable? disposables) {
    _disposables.value = disposables;
  }

  final List<T> edits;

  late final MutableDisposable<IDisposable> _disposables =
      register(MutableDisposable<IDisposable>());

  /// Transfers the edits to a new owner. Disposing this session will no longer
  /// release them.
  PasteEditSession<T> take() {
    return PasteEditSession<T>(edits, _disposables.clearAndLeak());
  }
}
