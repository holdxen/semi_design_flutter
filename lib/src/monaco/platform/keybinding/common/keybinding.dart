// 1:1 port of vs/platform/keybinding/common/keybinding.ts
// Truth: tool/ts2dart/batch127_truth.json (runtime decorator + TS AST interfaces).
// The TS interfaces are erased at runtime; every member below is driven by the
// AST-extracted member names/types in that truth file.
// ---------------------------------------------------------------------------

import '../../../base/common/event.dart' show Event;
import '../../../base/common/jsonSchema.dart' show IJSONSchema;
import '../../../base/common/keybindings.dart'
    show Keybinding, ResolvedKeybinding;
import '../../../base/common/lifecycle.dart' show IDisposable;
import '../../contextkey/common/contextkey.dart'
    show IContextKeyServiceTarget, IContextKeyServiceType;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import 'keybindingResolver.dart' show ResolutionResult;
import 'resolvedKeybindingItem.dart' show ResolvedKeybindingItem;

/// 1:1: `export interface IUserFriendlyKeybinding`
class IUserFriendlyKeybinding {
  IUserFriendlyKeybinding({
    required this.key,
    required this.command,
    this.args,
    this.when,
    this.systemWide,
  });

  final String key;
  final String command;
  final Object? args;
  final String? when;
  final bool? systemWide;
}

/// 1:1: `export interface IKeyboardEvent`
abstract class IKeyboardEvent {
  /// 1:1: `readonly _standardKeyboardEventBrand: true`
  bool get standardKeyboardEventBrand;

  bool get ctrlKey;
  bool get shiftKey;
  bool get altKey;
  bool get metaKey;
  bool get altGraphKey;

  /// TS `KeyCode` is a numeric enum; the port stores its int value.
  int get keyCode;
  String get code;
}

/// 1:1: `export interface KeybindingsSchemaContribution`
abstract class KeybindingsSchemaContribution {
  Event<void>? get onDidChange;

  List<IJSONSchema> getSchemaAdditions();
}

/// 1:1: `export const IKeybindingService = createDecorator<IKeybindingService>('keybindingService')`
final ServiceIdentifier<IKeybindingServiceType> IKeybindingService =
    createDecorator<IKeybindingServiceType>('keybindingService');

/// 1:1: `export interface IKeybindingService`
abstract class IKeybindingServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  bool get inChordMode;

  Event<void> get onDidUpdateKeybindings;

  /// Returns none, one or many (depending on keyboard layout)!
  List<ResolvedKeybinding> resolveKeybinding(Keybinding keybinding);

  ResolvedKeybinding resolveKeyboardEvent(IKeyboardEvent keyboardEvent);

  List<ResolvedKeybinding> resolveUserBinding(String userBinding);

  /// Resolve and dispatch `keyboardEvent` and invoke the command.
  bool dispatchEvent(IKeyboardEvent e, IContextKeyServiceTarget target);

  /// Resolve and dispatch `keyboardEvent`, but do not invoke the command or change inner state.
  ResolutionResult softDispatch(
      IKeyboardEvent keyboardEvent, IContextKeyServiceTarget target);

  /// Enable hold mode for this command; `undefined` when hold mode cannot be enabled.
  Future<void>? enableKeybindingHoldMode(String commandId);

  void dispatchByUserSettingsLabel(
      String userSettingsLabel, IContextKeyServiceTarget target);

  /// Look up keybindings for a command.
  List<ResolvedKeybinding> lookupKeybindings(String commandId);

  /// Preferred (last defined) keybinding, or `null` when unbound.
  ResolvedKeybinding? lookupKeybinding(
    String commandId, [
    IContextKeyServiceType? context,
    bool enforceContextCheck = false,
  ]);

  String getDefaultKeybindingsContent();

  List<ResolvedKeybindingItem> getDefaultKeybindings();

  List<ResolvedKeybindingItem> getKeybindings();

  int customKeybindingsCount();

  /// Whether the event may produce a character rendered on screen.
  bool mightProducePrintableCharacter(IKeyboardEvent event);

  IDisposable registerSchemaContribution(
      KeybindingsSchemaContribution contribution);

  bool toggleLogging();

  /// `${label} (keybinding label)` when bound, otherwise `label`.
  String appendKeybinding(
    String label,
    String? commandId, [
    IContextKeyServiceType? context,
    bool enforceContextCheck = false,
  ]);

  // ignore: unused_element
  String _dumpDebugInfo();

  // ignore: unused_element
  String _dumpDebugInfoJSON();
}
