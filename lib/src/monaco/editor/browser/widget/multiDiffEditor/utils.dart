// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/widget/multiDiffEditor/utils.ts
// Translated 1:1 from TypeScript. `ActionRunnerWithContext extends ActionRunner`
// overrides the protected `runAction` to inject a context from a callback.
// ---------------------------------------------------------------------------

import '../../../../base/common/actions.dart';

/// 1:1: `export class ActionRunnerWithContext extends ActionRunner`
class ActionRunnerWithContext extends ActionRunner {
  final Object? Function() _getContext;

  /// 1:1: `constructor(private readonly _getContext: () => unknown) { super(); }`
  ActionRunnerWithContext(this._getContext) : super();

  /// 1:1: `protected override runAction(action, _context?): Promise<void>`
  @override
  Future<void> runAction(IAction action, [Object? context]) async {
    final Object? ctx = _getContext();
    return super.runAction(action, ctx);
  }
}
