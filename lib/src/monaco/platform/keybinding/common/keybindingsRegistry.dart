// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/keybinding/common/keybindingsRegistry.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Carriers:
//   - `ContextKeyExpression` -> `Object?` (type-only in this module).
//   - `Keybinding` -> `keybindings.Keybinding`; `OS` -> `platform.OS` (int).
//   - `any` args / when clauses -> `Object?`.
// ---------------------------------------------------------------------------

import '../../../base/common/keybindings.dart' as keybindings;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../base/common/linkedList.dart' as linkedList;
import '../../../base/common/platform.dart' as platform;
import '../../commands/common/commands.dart' as commands;
import '../../registry/common/platform.dart' as registry;

/// 1:1: `export interface IKeybindingItem`.
class IKeybindingItem {
  IKeybindingItem({
    required this.keybinding,
    required this.command,
    this.commandArgs,
    required this.when,
    required this.weight1,
    required this.weight2,
    required this.extensionId,
    required this.isBuiltinExtension,
    this.systemWide,
  });

  keybindings.Keybinding? keybinding;
  String? command;
  Object? commandArgs;
  Object? when;
  int weight1;
  int weight2;
  String? extensionId;
  bool isBuiltinExtension;
  bool? systemWide;
}

/// Per-platform arm of `IKeybindings` (`win` / `linux` / `mac`).
class IKeybindingsPlatform {
  IKeybindingsPlatform({required this.primary, this.secondary});

  final int primary;
  final List<int>? secondary;
}

/// 1:1: `export interface IKeybindings`.
class IKeybindings {
  IKeybindings({
    this.primary,
    this.secondary,
    this.win,
    this.linux,
    this.mac,
  });

  int? primary;
  List<int>? secondary;
  IKeybindingsPlatform? win;
  IKeybindingsPlatform? linux;
  IKeybindingsPlatform? mac;
}

/// 1:1: `export interface IKeybindingRule extends IKeybindings`.
class IKeybindingRule extends IKeybindings {
  IKeybindingRule({
    required this.id,
    required this.weight,
    this.args,
    this.when,
    this.systemWide,
    super.primary,
    super.secondary,
    super.win,
    super.linux,
    super.mac,
  });

  String id;
  int weight;
  Object? args;
  Object? when;
  bool? systemWide;
}

/// 1:1: `export interface IExtensionKeybindingRule`.
class IExtensionKeybindingRule {
  IExtensionKeybindingRule({
    required this.keybinding,
    required this.id,
    this.args,
    required this.weight,
    required this.when,
    this.extensionId,
    this.isBuiltinExtension,
  });

  keybindings.Keybinding? keybinding;
  String id;
  Object? args;
  int weight;
  Object? when;
  String? extensionId;
  bool? isBuiltinExtension;
}

/// 1:1: `export const enum KeybindingWeight`.
class KeybindingWeight {
  static const int EditorCore = 0;
  static const int EditorContrib = 100;
  static const int WorkbenchContrib = 200;
  static const int SessionsContrib = 250;
  static const int BuiltinExtension = 300;
  static const int ExternalExtension = 400;
}

/// 1:1: `export interface ICommandAndKeybindingRule`.
class ICommandAndKeybindingRule extends IKeybindingRule {
  ICommandAndKeybindingRule({
    required super.id,
    required super.weight,
    required this.handler,
    this.metadata,
    super.args,
    super.when,
    super.systemWide,
    super.primary,
    super.secondary,
    super.win,
    super.linux,
    super.mac,
  });

  commands.ICommandHandler handler;
  commands.ICommandMetadata? metadata;
}

/// 1:1: `export interface IKeybindingAlias`.
class IKeybindingAlias {
  IKeybindingAlias({
    required this.command,
    required this.source,
    required this.when,
  });

  final String command;
  final String source;
  final Object? when;
}

/// 1:1: `export interface IKeybindingsRegistry`.
abstract class IKeybindingsRegistry {
  lifecycle.IDisposable registerKeybindingRule(IKeybindingRule rule);
  void setExtensionKeybindings(List<IExtensionKeybindingRule> rules);
  lifecycle.IDisposable registerCommandAndKeybindingRule(
      ICommandAndKeybindingRule desc);
  lifecycle.IDisposable registerKeybindingAlias(IKeybindingAlias alias);
  List<IKeybindingItem> getDefaultKeybindings();
  List<IKeybindingItem> getDefaultKeybindingsForOS(int os);
  List<IKeybindingAlias> getKeybindingAliases();
}

/// 1:1: `class KeybindingsRegistryImpl implements IKeybindingsRegistry`.
class KeybindingsRegistryImpl implements IKeybindingsRegistry {
  late final linkedList.LinkedList<IKeybindingItem> _coreKeybindings;
  late final linkedList.LinkedList<IKeybindingRule> _coreKeybindingRules;
  late List<IKeybindingItem> _extensionKeybindings;
  List<IKeybindingItem>? _cachedMergedKeybindings;

  final linkedList.LinkedList<IKeybindingAlias> _keybindingAliases =
      linkedList.LinkedList<IKeybindingAlias>();

  KeybindingsRegistryImpl() {
    _coreKeybindings = linkedList.LinkedList<IKeybindingItem>();
    _coreKeybindingRules = linkedList.LinkedList<IKeybindingRule>();
    _extensionKeybindings = <IKeybindingItem>[];
    _cachedMergedKeybindings = null;
  }

  /// 1:1: `private static bindToPlatform(kb, os)`.
  static IKeybindings _bindToPlatform(IKeybindings kb, int os) {
    if (os == platform.OperatingSystem.Windows) {
      final IKeybindingsPlatform? arm = kb.win;
      if (arm != null) {
        return IKeybindings(primary: arm.primary, secondary: arm.secondary);
      }
    } else if (os == platform.OperatingSystem.Macintosh) {
      final IKeybindingsPlatform? arm = kb.mac;
      if (arm != null) {
        return IKeybindings(primary: arm.primary, secondary: arm.secondary);
      }
    } else {
      final IKeybindingsPlatform? arm = kb.linux;
      if (arm != null) {
        return IKeybindings(primary: arm.primary, secondary: arm.secondary);
      }
    }
    return kb;
  }

  /// 1:1: `private static bindToCurrentPlatform(kb)`.
  static IKeybindings _bindToCurrentPlatform(IKeybindings kb) =>
      _bindToPlatform(kb, platform.OS);

  @override
  lifecycle.IDisposable registerKeybindingRule(IKeybindingRule rule) {
    final IKeybindings actualKb = _bindToCurrentPlatform(rule);
    final lifecycle.DisposableStore result = lifecycle.DisposableStore();

    if (actualKb.primary != null && actualKb.primary != 0) {
      final keybindings.Keybinding? kk =
          keybindings.decodeKeybinding(actualKb.primary!, platform.OS);
      if (kk != null) {
        result.add(_registerDefaultKeybinding(
            kk, rule.id, rule.args, rule.weight, 0, rule.when, rule.systemWide));
      }
    }

    final List<int>? secondary = actualKb.secondary;
    if (secondary != null) {
      for (int i = 0; i < secondary.length; i++) {
        final keybindings.Keybinding? kk =
            keybindings.decodeKeybinding(secondary[i], platform.OS);
        if (kk != null) {
          result.add(_registerDefaultKeybinding(kk, rule.id, rule.args,
              rule.weight, -i - 1, rule.when, rule.systemWide));
        }
      }
    }

    final void Function() removeRule = _coreKeybindingRules.push(rule);
    result.add(lifecycle.toDisposable(() => removeRule()));
    return result;
  }

  @override
  void setExtensionKeybindings(List<IExtensionKeybindingRule> rules) {
    final List<IKeybindingItem> result = <IKeybindingItem>[];
    for (final IExtensionKeybindingRule rule in rules) {
      if (rule.keybinding != null) {
        result.add(IKeybindingItem(
          keybinding: rule.keybinding,
          command: rule.id,
          commandArgs: rule.args,
          when: rule.when,
          weight1: rule.weight,
          weight2: 0,
          extensionId: rule.extensionId,
          isBuiltinExtension: rule.isBuiltinExtension ?? false,
        ));
      }
    }
    _extensionKeybindings = result;
    _cachedMergedKeybindings = null;
  }

  @override
  lifecycle.IDisposable registerCommandAndKeybindingRule(
          ICommandAndKeybindingRule desc) =>
      lifecycle.combinedDisposable(<lifecycle.IDisposable>[
        registerKeybindingRule(desc),
        commands.CommandsRegistry.registerCommand(commands.ICommand(
          id: desc.id,
          handler: desc.handler,
          metadata: desc.metadata,
        )),
      ]);

  @override
  lifecycle.IDisposable registerKeybindingAlias(IKeybindingAlias alias) =>
      lifecycle.toDisposable(_keybindingAliases.push(alias));

  @override
  List<IKeybindingAlias> getKeybindingAliases() =>
      List<IKeybindingAlias>.from(_keybindingAliases.iterable);

  lifecycle.IDisposable _registerDefaultKeybinding(
    keybindings.Keybinding keybinding,
    String commandId,
    Object? commandArgs,
    int weight1,
    int weight2,
    Object? when,
    bool? systemWide,
  ) {
    final void Function() remove = _coreKeybindings.push(IKeybindingItem(
      keybinding: keybinding,
      command: commandId,
      commandArgs: commandArgs,
      when: when,
      weight1: weight1,
      weight2: weight2,
      extensionId: null,
      isBuiltinExtension: false,
      systemWide: systemWide,
    ));
    _cachedMergedKeybindings = null;
    return lifecycle.toDisposable(() {
      remove();
      _cachedMergedKeybindings = null;
    });
  }

  @override
  List<IKeybindingItem> getDefaultKeybindings() {
    if (_cachedMergedKeybindings == null) {
      final List<IKeybindingItem> merged =
          List<IKeybindingItem>.from(_coreKeybindings.iterable)
            ..addAll(_extensionKeybindings);
      merged.sort(sorter);
      _cachedMergedKeybindings = merged;
    }
    return List<IKeybindingItem>.from(_cachedMergedKeybindings!);
  }

  @override
  List<IKeybindingItem> getDefaultKeybindingsForOS(int os) {
    final List<IKeybindingItem> result = <IKeybindingItem>[];
    for (final IKeybindingRule rule in _coreKeybindingRules.iterable) {
      final IKeybindings actualKb = _bindToPlatform(rule, os);

      if (actualKb.primary != null && actualKb.primary != 0) {
        final keybindings.Keybinding? kk =
            keybindings.decodeKeybinding(actualKb.primary!, os);
        if (kk != null) {
          result.add(IKeybindingItem(
            keybinding: kk,
            command: rule.id,
            commandArgs: rule.args,
            when: rule.when,
            weight1: rule.weight,
            weight2: 0,
            extensionId: null,
            isBuiltinExtension: false,
          ));
        }
      }

      final List<int>? secondary = actualKb.secondary;
      if (secondary != null) {
        for (int i = 0; i < secondary.length; i++) {
          final keybindings.Keybinding? kk =
              keybindings.decodeKeybinding(secondary[i], os);
          if (kk != null) {
            result.add(IKeybindingItem(
              keybinding: kk,
              command: rule.id,
              commandArgs: rule.args,
              when: rule.when,
              weight1: rule.weight,
              weight2: -i - 1,
              extensionId: null,
              isBuiltinExtension: false,
            ));
          }
        }
      }
    }
    result.sort(sorter);
    return result;
  }
}

/// 1:1: `function sorter(a, b)`.
int sorter(IKeybindingItem a, IKeybindingItem b) {
  if (a.weight1 != b.weight1) return a.weight1 - b.weight1;
  if (a.command != null && b.command != null) {
    if (a.command!.compareTo(b.command!) < 0) return -1;
    if (a.command!.compareTo(b.command!) > 0) return 1;
  }
  return a.weight2 - b.weight2;
}

/// 1:1: `export const KeybindingsRegistry: IKeybindingsRegistry = new ...`.
final IKeybindingsRegistry KeybindingsRegistry = _bootstrapRegistry();

/// 1:1: Define extension point ids + `Registry.add(...)` module side effect.
class Extensions {
  static const String EditorModes = 'platform.keybindingsRegistry';
}

IKeybindingsRegistry _bootstrapRegistry() {
  final IKeybindingsRegistry instance = KeybindingsRegistryImpl();
  registry.Registry.add(Extensions.EditorModes, instance);
  return instance;
}
