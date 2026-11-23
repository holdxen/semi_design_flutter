// 1:1 port of monaco-lsp-client/src/adapters/LspCommands.ts
// Bridges: monaco.editor.registerCommand -> registerCommandProvider;
// api.TServerInterface -> IServerInterface carrier; Disposable -> ../utils.dart;
// LspCommandPolicy -> LspCommandPolicy.dart (ported).
import '../types.dart' as T;
import '../utils.dart';
import 'LspCapabilitiesRegistry.dart';
import 'LspCommandPolicy.dart';
import 'monacoEditorApi.dart';

/// 1:1: module-level `let instanceCounter = 0`
int _instanceCounter = 0;

/// 1:1: `export class LspCommands extends Disposable`
class LspCommands extends Disposable {
  late final LspCommandPolicy _policy;
  late final String _executeServerCommandId;
  final IServerInterface _server;

  LspCommands(
    this._server,
    LspCapabilitiesRegistry capabilitiesRegistry,
    List<String>? allowedLocalCommands,
  ) : super() {
    _policy = LspCommandPolicy(allowedLocalCommands ?? const <String>[]);
    _executeServerCommandId =
        '_monacoLspClient.executeServerCommand.${_instanceCounter++}';

    register(capabilitiesRegistry.addStaticClientCapabilities(<String, dynamic>{
      'workspace': <String, dynamic>{
        'executeCommand': <String, dynamic>{'dynamicRegistration': true},
      },
    }));

    register(capabilitiesRegistry.registerCapabilityHandler<dynamic>(
      T.capabilities['workspaceExecuteCommand']!,
      true,
      (capability) {
        final commands = (capability as Map<String, dynamic>)['commands'] as List<Object?>?;
        return _policy.addServerCommands(commands);
      },
    ));

    register(registerCommandProvider(_executeServerCommandId, (accessor, command, args) {
      return _executeServerCommand(command, args);
    }));
  }

  /// reset the module-level instance counter (test hook, mirrors fresh module load).
  static void resetInstanceCounterForTest() => _instanceCounter = 0;

  /// the generated command id (exposed for tests; TS keeps it private).
  String get executeServerCommandId => _executeServerCommandId;

  /// 1:1: `private async _executeServerCommand(command, args)`
  Future<void> _executeServerCommand(Object? command, Object? args) async {
    if (!_policy.isServerCommand(command)) {
      return;
    }
    await _server.workspaceExecuteCommand(<String, Object?>{
      'command': command as Object?,
      'arguments': args is List ? args : null,
    });
  }

  /// 1:1: `toMonacoCommand(command): monaco.languages.Command | undefined`
  /// Returns a `Map<String,Object?>` carrier `{id, title, arguments}`.
  Map<String, Object?>? toMonacoCommand(T.Command? command) {
    final resolved = _policy.resolve(
      command == null ? null : LspCommand(command.command, command.arguments),
    );
    if (command == null || resolved == null) {
      return null;
    }
    if (resolved is ResolvedServerCommand) {
      return <String, Object?>{
        'id': _executeServerCommandId,
        'title': command.title,
        'arguments': <Object?>[resolved.command, resolved.arguments],
      };
    }
    final local = resolved as ResolvedLocalCommand;
    return <String, Object?>{
      'id': local.id,
      'title': command.title,
      'arguments': local.arguments ?? const <Object?>[],
    };
  }
}
