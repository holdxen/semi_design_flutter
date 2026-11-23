// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/commands/common/commands.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Carriers:
//   - `Event<T>` -> `event.Event<T>` callable typedef.
//   - `ICommandHandler` rest args -> explicit `List<Object?> args`.
//   - `Promise<R | undefined>` -> `Future<Object?>`.
//   - `export const ICommandService` keeps the bare name; the interface gets
//     the `Type` suffix, following the project's service-port convention.
// ---------------------------------------------------------------------------

import '../../../base/common/event.dart' as event;
import '../../../base/common/iterator.dart' as iterable;
import '../../../base/common/jsonSchema.dart' show IJSONSchema;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../base/common/linkedList.dart' as linkedList;
import '../../../base/common/types.dart' as types;
// `ICommandMetadata.description` is `ILocalizedString | string` in TS;
// Dart carries that union as `Object` (action.ILocalizedString or String).
import '../../instantiation/common/instantiation.dart' as instantiation;

/// 1:1: `export const ICommandService = createDecorator<ICommandService>('commandService')`.
final instantiation.ServiceIdentifier<ICommandServiceType> ICommandService =
    instantiation.createDecorator<ICommandServiceType>('commandService');

/// 1:1: `export interface ICommandEvent`.
class ICommandEvent {
  ICommandEvent({required this.commandId, required this.args});

  final String commandId;
  final List<Object?> args;
}

/// 1:1: `export interface ICommandService` (const keeps the bare name).
abstract class ICommandServiceType {
  event.Event<ICommandEvent> get onWillExecuteCommand;
  event.Event<ICommandEvent> get onDidExecuteCommand;
  Future<Object?> executeCommand(String commandId, List<Object?> args);
}

/// 1:1: `export type ICommandsMap = Map<string, ICommand>`.
typedef ICommandsMap = Map<String, ICommand>;

/// 1:1: `export type ICommandHandler<Args extends unknown[], R> = (accessor, ...args) => R`.
/// Dart has no rest parameters in typedefs; the args list is the carrier.
typedef ICommandHandler = Object? Function(
    instantiation.ServicesAccessor accessor, List<Object?> args);

/// 1:1: `export interface ICommand<Args, R>`.
class ICommand {
  ICommand({required this.id, required this.handler, this.metadata});

  String id;
  ICommandHandler handler;
  ICommandMetadata? metadata;
}

/// 1:1 descriptor inside `ICommandMetadata.args`.
class ICommandMetadataArg {
  ICommandMetadataArg({
    required this.name,
    this.isOptional,
    this.description,
    this.constraint,
    this.schema,
  });

  final String name;
  final bool? isOptional;
  final String? description;
  final types.TypeConstraint? constraint;
  final IJSONSchema? schema;
}

/// 1:1: `export interface ICommandMetadata`.
class ICommandMetadata {
  ICommandMetadata({
    required this.description,
    this.args,
    this.returns,
  });

  final Object description;
  final List<ICommandMetadataArg>? args;
  final String? returns;
}

/// 1:1: `export interface ICommandRegistry`.
abstract class ICommandRegistry {
  event.Event<String> get onDidRegisterCommand;

  lifecycle.IDisposable registerCommand(Object idOrCommand, [Object? handler]);
  lifecycle.IDisposable registerCommandAlias(String oldId, String newId);
  ICommand? getCommand(String id);
  ICommandsMap getCommands();
}

/// 1:1: `export const CommandsRegistry: ICommandRegistry = new class ...`.
class _CommandsRegistryImpl implements ICommandRegistry {
  final Map<String, linkedList.LinkedList<ICommand>> _commands =
      <String, linkedList.LinkedList<ICommand>>{};

  final event.Emitter<String> _onDidRegisterCommand = event.Emitter<String>();

  @override
  event.Event<String> get onDidRegisterCommand => _onDidRegisterCommand.event;

  @override
  lifecycle.IDisposable registerCommand(Object idOrCommand, [Object? handler]) {
    if (idOrCommand is String) {
      if (idOrCommand.isEmpty || handler == null) {
        throw StateError('invalid command');
      }
      return registerCommand(ICommand(
          id: idOrCommand, handler: handler as ICommandHandler));
    }
    if (idOrCommand is! ICommand) {
      throw StateError('invalid command');
    }

    // add argument validation if rich command metadata is provided
    final ICommandMetadata? metadata = idOrCommand.metadata;
    if (metadata != null && metadata.args != null) {
      final List<types.TypeConstraint?> constraints =
          metadata.args!.map((ICommandMetadataArg arg) => arg.constraint).toList();
      final ICommandHandler actualHandler = idOrCommand.handler;
      idOrCommand.handler = (instantiation.ServicesAccessor accessor,
              List<Object?> args) {
        types.validateConstraints(args, constraints);
        return actualHandler(accessor, args);
      };
    }

    final String id = idOrCommand.id;
    linkedList.LinkedList<ICommand>? commands = _commands[id];
    if (commands == null) {
      commands = linkedList.LinkedList<ICommand>();
      _commands[id] = commands;
    }

    final void Function() removeFn = commands.unshift(idOrCommand);
    final lifecycle.IDisposable ret = lifecycle.toDisposable(() {
      removeFn();
      final linkedList.LinkedList<ICommand>? command = _commands[id];
      if (command != null && command.isEmpty()) {
        _commands.remove(id);
      }
    });

    _onDidRegisterCommand.fire(id);
    return lifecycle.markAsSingleton(ret);
  }

  @override
  lifecycle.IDisposable registerCommandAlias(String oldId, String newId) =>
      registerCommand(oldId, (instantiation.ServicesAccessor accessor,
              List<Object?> args) {
        final ICommandServiceType service =
            accessor.get(ICommandService) as ICommandServiceType;
        return service.executeCommand(newId, args);
      });

  @override
  ICommand? getCommand(String id) {
    final linkedList.LinkedList<ICommand>? list = _commands[id];
    if (list == null || list.isEmpty()) return null;
    return iterable.IterableX.first<ICommand>(list.iterable);
  }

  @override
  ICommandsMap getCommands() {
    final ICommandsMap result = <String, ICommand>{};
    for (final String key in _commands.keys) {
      final ICommand? command = getCommand(key);
      if (command != null) result[key] = command;
    }
    return result;
  }
}

ICommandRegistry _bootstrapRegistry() {
  final ICommandRegistry registry = _CommandsRegistryImpl();
  registry.registerCommand('noop', (accessor, args) {});
  return registry;
}

/// 1:1: module-load side effect + exported registry singleton.
final ICommandRegistry CommandsRegistry = _bootstrapRegistry();
