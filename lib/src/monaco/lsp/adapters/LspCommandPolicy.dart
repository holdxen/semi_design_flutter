// ---------------------------------------------------------------------------
// Port of monaco-editor/monaco-lsp-client/src/adapters/LspCommandPolicy.ts
// Translated 1:1 from TypeScript.
//   - `readonly string[]` -> unmodifiable `List<String>`.
//   - `LspCommand` interface -> class.
//   - `ResolvedLspCommand` discriminated union -> abstract base + two carriers.
//   - `IDisposable` from the LSP client's own `../utils` copy.
// ---------------------------------------------------------------------------

import '../utils.dart' show IDisposable;

/// 1:1: `export const defaultAllowedLocalCommands: readonly string[]`
final List<String> defaultAllowedLocalCommands = List<String>.unmodifiable(
  <String>[
    'editor.action.triggerSuggest',
    'editor.action.triggerParameterHints',
  ],
);

/// 1:1: `export interface LspCommand`
class LspCommand {
  LspCommand([this.command, this.arguments]);

  final Object? command;
  final Object? arguments;
}

/// 1:1: `export type ResolvedLspCommand` (abstract base)
abstract class ResolvedLspCommand {
  Object? get arguments;
}

/// 1:1: `{ kind: 'server'; command: string; arguments }`
class ResolvedServerCommand extends ResolvedLspCommand {
  ResolvedServerCommand(this.command, this.arguments);

  final String command;
  @override
  final List<Object?>? arguments;
}

/// 1:1: `{ kind: 'local'; id: string; arguments }`
class ResolvedLocalCommand extends ResolvedLspCommand {
  ResolvedLocalCommand(this.id, this.arguments);

  final String id;
  @override
  final List<Object?>? arguments;
}

/// 1:1: `export class LspCommandPolicy`
class LspCommandPolicy {
  LspCommandPolicy([List<String> allowedLocalCommands = const <String>[]])
      : _allowedLocalCommands = <String>{
          ...defaultAllowedLocalCommands,
          ...allowedLocalCommands,
        };

  final Set<String> _allowedLocalCommands;
  final Map<String, int> _serverCommands = <String, int>{};

  /// 1:1: `addServerCommands(commands): IDisposable`
  IDisposable addServerCommands(List<Object?>? commands) {
    final List<String> added = (commands ?? <Object?>[])
        .where((Object? c) => c is String)
        .cast<String>()
        .toList();
    for (final String c in added) {
      _serverCommands[c] = (_serverCommands[c] ?? 0) + 1;
    }
    bool disposed = false;
    return _CommandRegistration(
      onDispose: () {
        if (disposed) {
          return;
        }
        disposed = true;
        for (final String c in added) {
          final int count = (_serverCommands[c] ?? 0) - 1;
          if (count > 0) {
            _serverCommands[c] = count;
          } else {
            _serverCommands.remove(c);
          }
        }
      },
    );
  }

  /// 1:1: `isServerCommand(command): command is string`
  bool isServerCommand(Object? command) =>
      command is String && _serverCommands.containsKey(command);

  /// 1:1: `resolve(command): ResolvedLspCommand | undefined`
  ResolvedLspCommand? resolve(LspCommand? command) {
    if (command == null ||
        command.command is! String ||
        (command.command as String).isEmpty) {
      return null;
    }
    final Object? args = command.arguments;
    final List<Object?>? resolvedArgs =
        args is List ? List<Object?>.from(args) : null;
    final String name = command.command as String;
    if (isServerCommand(name)) {
      return ResolvedServerCommand(name, resolvedArgs);
    }
    if (_allowedLocalCommands.contains(name)) {
      return ResolvedLocalCommand(name, resolvedArgs);
    }
    return null;
  }
}

/// 1:1: the disposable returned by `addServerCommands`.
class _CommandRegistration implements IDisposable {
  _CommandRegistration({required this.onDispose});
  final void Function() onDispose;
  @override
  void dispose() => onDispose();
}

/// 1:1: `export function isCommandUri(target): boolean`
bool isCommandUri(String target) => RegExp(r'^\s*command:', caseSensitive: false).hasMatch(target);
