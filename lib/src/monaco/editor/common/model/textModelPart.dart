// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/model/textModelPart.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
// ---------------------------------------------------------------------------

import '../../../base/common/lifecycle.dart' show Disposable;

/// 1:1: `export class TextModelPart extends Disposable`
class TextModelPart extends Disposable {
  bool _isDisposed = false;

  @override
  void dispose() {
    super.dispose();
    _isDisposed = true;
  }

  /// 1:1: `protected assertNotDisposed(): void`
  void assertNotDisposed() {
    if (_isDisposed) {
      throw StateError('TextModelPart is disposed!');
    }
  }
}
