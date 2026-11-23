import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/keyCodes.dart' as keyCodes;
import 'package:semi_design_flutter/src/monaco/base/common/platform.dart' as platform;
import 'package:semi_design_flutter/src/monaco/platform/commands/common/commands.dart'
    as commands;
import 'package:semi_design_flutter/src/monaco/platform/commands/test/common/nullCommandService.dart'
    as nullCommand;
import 'package:semi_design_flutter/src/monaco/platform/keybinding/common/keybindingsRegistry.dart'
    as kb;
import 'package:semi_design_flutter/src/monaco/platform/registry/common/platform.dart'
    as registry;

final Map<String, dynamic> _truth =
    jsonDecode(File('tool/ts2dart/batch125_truth.json').readAsStringSync())
        as Map<String, dynamic>;

Map<String, dynamic> _section(String name) =>
    (_truth[name] as Map).cast<String, dynamic>();

List<dynamic> _listSection(String name) => _truth[name] as List<dynamic>;

void _expectDeep(Object? actual, Object? expected, [String label = 'value']) {
  if (expected is Map) {
    expect(actual, isA<Map>(), reason: label);
    final Map act = actual as Map;
    for (final Object? key in expected.keys) {
      _expectDeep(act[key], expected[key], '$label.$key');
    }
  } else if (expected is List) {
    expect(actual, isA<List>(), reason: label);
    final List act = actual as List;
    expect(act.length, expected.length, reason: '$label.length');
    for (int i = 0; i < expected.length; i++) {
      _expectDeep(act[i], expected[i], '$label[$i]');
    }
  } else {
    expect(actual, expected, reason: label);
  }
}

Map<String, Object?> _itemView(kb.IKeybindingItem item) =>
    <String, Object?>{
      'command': item.command,
      'keybinding': item.keybinding?.getHashCode(),
      'weight1': item.weight1,
      'weight2': item.weight2,
      'extensionId': item.extensionId,
      'isBuiltinExtension': item.isBuiltinExtension,
      'systemWide': item.systemWide ?? 'undefined',
    };

List<Map<String, Object?>> _items(List<kb.IKeybindingItem> items) =>
    items.map(_itemView).toList();

Map<String, Object?> _aliasView(kb.IKeybindingAlias alias) =>
    <String, Object?>{
      'command': alias.command,
      'source': alias.source,
      'when': alias.when,
    };

void main() {
  test('truth OS matches host carrier', () {
    expect(platform.OS, _truth['os']);
  });

  test('NullCommandService', () async {
    final expected = _section('nullCommandService');
    final will = nullCommand.NullCommandService.onWillExecuteCommand(
        (dynamic e) {}, null, null);
    final did = nullCommand.NullCommandService.onDidExecuteCommand(
        (dynamic e) {}, null, null);
    final Object? result = await nullCommand.NullCommandService.executeCommand(
        'any', <Object?>[]);
    bool willDisposed = false;
    bool didDisposed = false;
    try {
      will.dispose();
      willDisposed = true;
    } catch (_) {}
    try {
      did.dispose();
      didDisposed = true;
    } catch (_) {}
    expect(willDisposed, expected['willDisposed']);
    expect(didDisposed, expected['didDisposed']);
    expect(result == null ? 'undefined' : 'defined', expected['result']);
  });

  test('initial registry state and extension point', () {
    final expected = _section('initial');
    expect(kb.Extensions.EditorModes, expected['extensionPoint']);
    final List<Object?> adds = (expected['registryAdds'] as List)
        .map((dynamic e) => (e as Map)['id'])
        .toList();
    expect(<Object?>[kb.Extensions.EditorModes], adds);
    final Object registryInstance = kb.KeybindingsRegistry;
    expect(registry.Registry.as(kb.Extensions.EditorModes),
        same(registryInstance));
    expect(kb.KeybindingsRegistry.getKeybindingAliases(), isEmpty);
    expect(_items(kb.KeybindingsRegistry.getDefaultKeybindings()), isEmpty);
  });

  test('bindToPlatform primary/secondary per OS', () {
    final expected = _section('platform');
    const int ka = keyCodes.KeyCode.KeyA;
    const int kbCode = keyCodes.KeyCode.KeyB;
    const int kc = keyCodes.KeyCode.KeyC;
    final rule = kb.IKeybindingRule(
      id: 'truth.platformRule',
      weight: 200,
      args: <String, Object?>{'a': 1},
      primary: ka,
      secondary: <int>[kbCode],
      win: kb.IKeybindingsPlatform(
          primary: kbCode, secondary: <int>[kc]),
      linux: kb.IKeybindingsPlatform(primary: kc, secondary: <int>[]),
      mac: kb.IKeybindingsPlatform(primary: ka, secondary: <int>[kc]),
      systemWide: true,
    );
    final d = kb.KeybindingsRegistry.registerKeybindingRule(rule);
    _expectDeep(
        _items(kb.KeybindingsRegistry.getDefaultKeybindings()),
        expected['current'],
        'current');
    _expectDeep(
        _items(kb.KeybindingsRegistry.getDefaultKeybindingsForOS(1)),
        expected['windows'],
        'windows');
    _expectDeep(
        _items(kb.KeybindingsRegistry.getDefaultKeybindingsForOS(3)),
        expected['linux'],
        'linux');
    _expectDeep(
        _items(kb.KeybindingsRegistry.getDefaultKeybindingsForOS(2)),
        expected['mac'],
        'mac');
    d.dispose();
    expect(_items(kb.KeybindingsRegistry.getDefaultKeybindings()),
        expected['afterDispose']);
  });

  test('extension keybindings filter null keybinding', () {
    final expected = _section('extension');
    final List<kb.IKeybindingItem> linux =
        kb.KeybindingsRegistry.getDefaultKeybindingsForOS(3);
    // No rules registered at this point; use a fresh rule for its keybinding.
    final d = kb.KeybindingsRegistry.registerKeybindingRule(
        kb.IKeybindingRule(id: 'truth.tmp', weight: 300, primary: 33));
    final keybinding =
        kb.KeybindingsRegistry.getDefaultKeybindingsForOS(3).first.keybinding;
    d.dispose();
    expect(linux, isEmpty);

    kb.KeybindingsRegistry.setExtensionKeybindings(<kb.IExtensionKeybindingRule>[
      kb.IExtensionKeybindingRule(
          keybinding: null, id: 'truth.skipped', weight: 1, when: null),
      kb.IExtensionKeybindingRule(
        keybinding: keybinding,
        id: 'truth.ext',
        weight: 50,
        when: null,
        extensionId: 'ext.id',
        isBuiltinExtension: true,
      ),
    ]);
    _expectDeep(_items(kb.KeybindingsRegistry.getDefaultKeybindings()),
        expected['items'], 'extension');
    kb.KeybindingsRegistry.setExtensionKeybindings(
        <kb.IExtensionKeybindingRule>[]);
    expect(_items(kb.KeybindingsRegistry.getDefaultKeybindings()),
        expected['afterClear']);
  });

  test('registerCommandAndKeybindingRule delegates to CommandsRegistry', () {
    final expected = _section('commandRule');
    final desc = kb.ICommandAndKeybindingRule(
      id: 'truth.commandRule',
      weight: 100,
      primary: 31,
      handler: (accessor, args) => null,
    );
    final d = kb.KeybindingsRegistry.registerCommandAndKeybindingRule(desc);
    _expectDeep(
        _items(kb.KeybindingsRegistry.getDefaultKeybindings()),
        expected['defaults'],
        'defaults');
    expect(commands.CommandsRegistry.getCommands()
        .containsKey('truth.commandRule'), isTrue);
    d.dispose();
    final after = _section('commandRule')['afterDispose'] as Map;
    expect(_items(kb.KeybindingsRegistry.getDefaultKeybindings()),
        after['defaults']);
    expect(commands.CommandsRegistry.getCommands()
        .containsKey('truth.commandRule'), isFalse);
  });

  test('keybinding aliases', () {
    final expected = _listSection('aliases');
    final alias = kb.IKeybindingAlias(
        command: 'truth.alias', source: 'truth.source', when: 'cond');
    final d = kb.KeybindingsRegistry.registerKeybindingAlias(alias);
    expect(
      kb.KeybindingsRegistry.getKeybindingAliases().map(_aliasView).toList(),
      expected,
    );
    d.dispose();
    expect(kb.KeybindingsRegistry.getKeybindingAliases(),
        _truth['aliasesAfterDispose']);
  });

  test('default keybindings sort order', () {
    final expected = _listSection('sorted');
    final rules = <kb.IKeybindingRule>[
      kb.IKeybindingRule(id: 'z.cmd', weight: 200, primary: 31),
      kb.IKeybindingRule(id: 'a.cmd', weight: 200, primary: 31),
      kb.IKeybindingRule(id: 'm.cmd', weight: 100, primary: 31),
    ];
    final ds = rules
        .map(kb.KeybindingsRegistry.registerKeybindingRule)
        .toList();
    final actual = kb.KeybindingsRegistry.getDefaultKeybindings()
        .map((kb.IKeybindingItem item) => <String, Object?>{
              'command': item.command,
              'weight1': item.weight1,
            })
        .toList();
    expect(actual, expected);
    for (final d in ds) {
      d.dispose();
    }
  });
}
