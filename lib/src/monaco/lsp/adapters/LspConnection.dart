// 1:1 port of monaco-lsp-client/src/adapters/LspConnection.ts
// Pure data container. `api.TServerInterface` / TypedChannel are unported
// external types bridged by IServerInterface / TypedChannel carriers.
import '../types.dart' as T;
import 'ITextModelBridge.dart';
import 'LspCapabilitiesRegistry.dart';
import 'LspCommands.dart';
import 'monacoEditorApi.dart';
import 'typedChannel.dart';

/// 1:1: `export class LspConnection`
class LspConnection {
  /// 1:1: `public readonly server`
  final IServerInterface server;

  /// 1:1: `public readonly bridge`
  final ITextModelBridge bridge;

  /// 1:1: `public readonly capabilities`
  final LspCapabilitiesRegistry capabilities;

  /// 1:1: `public readonly connection`
  final TypedChannel connection;

  /// 1:1: `public readonly commands`
  final LspCommands commands;

  LspConnection({
    required this.server,
    required this.bridge,
    required this.capabilities,
    required this.connection,
    required this.commands,
  });
}

/// 1:1 value carrier of a LSP `Command` coming from a decoded JSON Map.
/// Lets language features feed Map-shaped server results into
/// [LspCommands.toMonacoCommand] without changing its typed signature.
class CommandCarrier implements T.Command {
  final Map<String, Object?> _map;
  CommandCarrier(this._map);

  @override
  String get title => _map['title'] as String;

  @override
  String get command => _map['command'] as String;

  @override
  List<T.LSPAny>? get arguments => (_map['arguments'] as List?)?.cast<T.LSPAny>();
}
