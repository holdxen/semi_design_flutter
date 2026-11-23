// 1:1 port of vs/platform/keybinding/test/common/mockKeybindingService.ts
// Truth: tool/ts2dart/batch128_truth.json (real transpiled TypeScript module).
// ---------------------------------------------------------------------------

import '../../../../base/common/event.dart' as events;
import '../../../../base/common/keybindings.dart' as kb;
import '../../../../base/common/lifecycle.dart' as lifecycle;
import '../../../../base/common/platform.dart' as platform;
import '../../../contextkey/common/contextkey.dart' as contextkey;
import '../../common/keybinding.dart' as keybinding;
import '../../common/keybindingResolver.dart' as resolver;
import '../../common/resolvedKeybindingItem.dart' as resolved;
import '../../common/usLayoutResolvedKeybinding.dart' as uslayout;

/// 1:1: `class MockKeybindingContextKey<T> implements IContextKey<T>`
class MockKeybindingContextKey<T extends Object?> implements contextkey.IContextKey<T> {
  MockKeybindingContextKey(this._defaultValue) : _value = _defaultValue;

  final T? _defaultValue;
  T? _value;

  @override
  void set(T? value) {
    _value = value;
  }

  @override
  void reset() {
    _value = _defaultValue;
  }

  @override
  T? get_() => _value;
}

/// 1:1: `export class MockContextKeyService implements IContextKeyService`
class MockContextKeyService implements contextkey.IScopedContextKeyService {
  // ignore: unused_field
  final Object? _serviceBrand = null;

  final Map<String, contextkey.IContextKey<Object?>> _keys =
      <String, contextkey.IContextKey<Object?>>{};

  @override
  void dispose() {
    //
  }

  @override
  contextkey.IContextKey<T> createKey<T extends Object?>(
      String key, T? defaultValue) {
    final contextkey.IContextKey<T> ret =
        MockKeybindingContextKey<T>(defaultValue);
    _keys[key] = ret as contextkey.IContextKey<Object?>;
    return ret;
  }

  @override
  bool contextMatchesRules(contextkey.ContextKeyExpression? rules) => false;

  @override
  Object get onDidChangeContext => events.eventNone;

  @override
  void bufferChangeEvents(void Function() callback) {
    callback();
  }

  @override
  T? getContextKeyValue<T extends Object?>(String key) {
    final contextkey.IContextKey<Object?>? value = _keys[key];
    if (value != null) {
      return value.get_() as T?;
    }
    return null;
  }

  @override
  contextkey.IContext? getContext(contextkey.IContextKeyServiceTarget? target) =>
      null;

  @override
  contextkey.IScopedContextKeyService createScoped(
          contextkey.IContextKeyServiceTarget target) =>
      this;

  @override
  contextkey.IContextKeyServiceType createOverlay(
          [Iterable<List<Object?>>? overlay]) =>
      this;

  @override
  void updateParent(contextkey.IContextKeyServiceType parentContextKeyService) {
    // no-op
  }
}

/// 1:1: `export class MockScopableContextKeyService extends MockContextKeyService`
class MockScopableContextKeyService extends MockContextKeyService {
  /// Don't implement this for all tests since we rarely depend on this behavior
  /// and it isn't implemented fully.
  @override
  contextkey.IScopedContextKeyService createScoped(
          contextkey.IContextKeyServiceTarget target) =>
      MockScopableContextKeyService();
}

/// 1:1: `export class MockKeybindingService implements IKeybindingService`
class MockKeybindingService implements keybinding.IKeybindingServiceType {
  // ignore: unused_field
  final Object? _serviceBrand = null;

  @override
  final bool inChordMode = false;

  @override
  events.Event<void> get onDidUpdateKeybindings =>
      events.eventNone;

  @override
  String getDefaultKeybindingsContent() => '';

  @override
  List<resolved.ResolvedKeybindingItem> getDefaultKeybindings() =>
      <resolved.ResolvedKeybindingItem>[];

  @override
  List<resolved.ResolvedKeybindingItem> getKeybindings() =>
      <resolved.ResolvedKeybindingItem>[];

  @override
  List<kb.ResolvedKeybinding> resolveKeybinding(kb.Keybinding keybinding) =>
      uslayout.USLayoutResolvedKeybinding.resolveKeybinding(
          keybinding, platform.OS);

  @override
  kb.ResolvedKeybinding resolveKeyboardEvent(
      keybinding.IKeyboardEvent keyboardEvent) {
    final kb.KeyCodeChord chord = kb.KeyCodeChord(
      keyboardEvent.ctrlKey,
      keyboardEvent.shiftKey,
      keyboardEvent.altKey,
      keyboardEvent.metaKey,
      keyboardEvent.keyCode,
    );
    return resolveKeybinding(chord.toKeybinding())[0];
  }

  @override
  List<kb.ResolvedKeybinding> resolveUserBinding(String userBinding) =>
      <kb.ResolvedKeybinding>[];

  @override
  List<kb.ResolvedKeybinding> lookupKeybindings(String commandId) =>
      <kb.ResolvedKeybinding>[];

  @override
  kb.ResolvedKeybinding? lookupKeybinding(
    String commandId, [
    contextkey.IContextKeyServiceType? context,
    bool enforceContextCheck = false,
  ]) =>
      null;

  @override
  int customKeybindingsCount() => 0;

  @override
  resolver.ResolutionResult softDispatch(
    keybinding.IKeyboardEvent keybinding,
    contextkey.IContextKeyServiceTarget target,
  ) =>
      resolver.NoMatchingKb;

  @override
  void dispatchByUserSettingsLabel(
    String userSettingsLabel,
    contextkey.IContextKeyServiceTarget target,
  ) {
    // no-op
  }

  @override
  bool dispatchEvent(
    keybinding.IKeyboardEvent e,
    contextkey.IContextKeyServiceTarget target,
  ) =>
      false;

  @override
  Future<void>? enableKeybindingHoldMode(String commandId) => null;

  @override
  bool mightProducePrintableCharacter(keybinding.IKeyboardEvent e) => false;

  @override
  bool toggleLogging() => false;

  // ignore: unused_element
  String _dumpDebugInfo() => '';

  // ignore: unused_element
  String _dumpDebugInfoJSON() => '';

  @override
  lifecycle.IDisposable registerSchemaContribution(
      [keybinding.KeybindingsSchemaContribution? contribution]) =>
      lifecycle.Disposable.none;

  @override
  String appendKeybinding(
    String label,
    String? commandId, [
    contextkey.IContextKeyServiceType? context,
    bool enforceContextCheck = false,
  ]) =>
      label;
}
