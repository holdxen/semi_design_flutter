// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/commands/test/common/nullCommandService.ts
// Translated 1:1 from TypeScript.
// ---------------------------------------------------------------------------

import '../../../../base/common/event.dart' as event;
import '../../../../base/common/lifecycle.dart' as lifecycle;
import '../../common/commands.dart' as commands;

/// 1:1: `export const NullCommandService: ICommandService = { ... }`.
final commands.ICommandServiceType NullCommandService = _NullCommandService();

class _NullCommandService implements commands.ICommandServiceType {
  @override
  event.Event<commands.ICommandEvent> get onWillExecuteCommand =>
      (dynamic listener, [dynamic thisArgs, dynamic disposables]) =>
          lifecycle.Disposable.none;

  @override
  event.Event<commands.ICommandEvent> get onDidExecuteCommand =>
      (dynamic listener, [dynamic thisArgs, dynamic disposables]) =>
          lifecycle.Disposable.none;

  @override
  Future<Object?> executeCommand(String commandId, List<Object?> args) async =>
      null;
}
