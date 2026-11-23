// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/actionWidget/common/actionWidget.ts
// Translated 1:1 from TypeScript.
// ---------------------------------------------------------------------------

import '../../../base/common/lifecycle.dart' show IDisposable;

/// 1:1: `export interface ActionSet<T> extends IDisposable`
abstract class ActionSet<T> implements IDisposable {
  List<T> get validActions;
  List<T> get allActions;
  bool get hasAutoFix;
  bool get hasAIFix;
  bool get allAIFixes;
}
