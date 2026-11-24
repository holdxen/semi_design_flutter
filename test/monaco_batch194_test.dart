// Truth replay for batch194:
//   platform/quickinput/common/quickAccess.ts
//   platform/quickinput/common/quickInput.ts
//
// Expectations come from `tool/ts2dart/batch194_truth.json`, produced by
// `tool/ts2dart/_batch194_truth.cjs` (real transpiled TypeScript + the real
// arrays/lifecycle/uri/network/registry modules). Both files are `common/`
// layer, so the whole runtime surface is deterministic.
//
// NOTE: neither file has an official test of its own — the stem heuristic of
// `find_ready.py` does not match either. Truth comes from the real source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/network.dart' show Schemas;
import '../lib/src/monaco/base/common/uri.dart' show URI, UriComponents;
import '../lib/src/monaco/platform/contextkey/common/contextkey.dart'
    show ContextKeyExpression, IContextKeyServiceType;
import '../lib/src/monaco/platform/quickinput/common/quickAccess.dart'
    as quickAccess;
import '../lib/src/monaco/platform/quickinput/common/quickInput.dart'
    as quickInput;
import '../lib/src/monaco/platform/registry/common/platform.dart' as registry;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

List<dynamic> _list(dynamic value) => value as List<dynamic>;

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

Map<String, dynamic> _truth() =>
    _map(jsonDecode(File('tool/ts2dart/batch194_truth.json').readAsStringSync()));

/// `when`-clause carrier: identity-compared fake expression.
class _FakeWhen implements ContextKeyExpression {
  _FakeWhen(this.id);

  final String id;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeContextKeyService implements IContextKeyServiceType {
  @override
  bool contextMatchesRules(ContextKeyExpression? rules) =>
      identical(rules, expectedTrue);

  late ContextKeyExpression expectedTrue;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

quickAccess.IQuickAccessProviderDescriptor _descriptor(
  String prefix, {
  ContextKeyExpression? when,
}) =>
    quickAccess.IQuickAccessProviderDescriptor(
      ctor: Object(),
      prefix: prefix,
      helpEntries: <quickAccess.IQuickAccessProviderHelp>[],
      when: when,
    );

void main() {
  final Map<String, dynamic> truth = _truth();

  test('batch194 enums, constants and helpers match truth', () {
    final Map<String, dynamic> enums = _map(truth['enums']);
    final Map<String, dynamic> hideReason =
        _map(enums['QuickInputHideReason']);
    expect(quickInput.QuickInputHideReason.Blur, hideReason['Blur']);
    expect(quickInput.QuickInputHideReason.Gesture, hideReason['Gesture']);
    expect(quickInput.QuickInputHideReason.Other, hideReason['Other']);

    final Map<String, dynamic> type = _map(enums['QuickInputType']);
    expect(quickInput.QuickInputType.QuickPick, type['QuickPick']);
    expect(quickInput.QuickInputType.InputBox, type['InputBox']);
    expect(quickInput.QuickInputType.QuickWidget, type['QuickWidget']);
    expect(quickInput.QuickInputType.QuickTree, type['QuickTree']);

    final Map<String, dynamic> activation = _map(enums['ItemActivation']);
    expect(quickInput.ItemActivation.NONE, activation['NONE']);
    expect(quickInput.ItemActivation.FIRST, activation['FIRST']);
    expect(quickInput.ItemActivation.SECOND, activation['SECOND']);
    expect(quickInput.ItemActivation.LAST, activation['LAST']);

    final Map<String, dynamic> focus = _map(enums['QuickPickFocus']);
    expect(quickInput.QuickPickFocus.First, focus['First']);
    expect(quickInput.QuickPickFocus.Second, focus['Second']);
    expect(quickInput.QuickPickFocus.Last, focus['Last']);
    expect(quickInput.QuickPickFocus.Next, focus['Next']);
    expect(quickInput.QuickPickFocus.Previous, focus['Previous']);
    expect(quickInput.QuickPickFocus.NextPage, focus['NextPage']);
    expect(quickInput.QuickPickFocus.PreviousPage, focus['PreviousPage']);
    expect(quickInput.QuickPickFocus.NextSeparator, focus['NextSeparator']);
    expect(
        quickInput.QuickPickFocus.PreviousSeparator, focus['PreviousSeparator']);

    final Map<String, dynamic> location =
        _map(enums['QuickInputButtonLocation']);
    expect(quickInput.QuickInputButtonLocation.Title, location['Title']);
    expect(quickInput.QuickInputButtonLocation.Inline, location['Inline']);
    expect(quickInput.QuickInputButtonLocation.Input, location['Input']);

    final Map<String, dynamic> filterValue =
        _map(enums['DefaultQuickAccessFilterValue']);
    expect(quickAccess.DefaultQuickAccessFilterValue.PRESERVE,
        filterValue['PRESERVE']);
    expect(quickAccess.DefaultQuickAccessFilterValue.LAST, filterValue['LAST']);

    expect(quickAccess.Extensions.Quickaccess,
        _map(truth['extensions'])['Quickaccess']);

    final Map<String, dynamic> noKeyMods = _map(truth['noKeyMods']);
    expect(quickInput.NO_KEY_MODS.ctrlCmd, noKeyMods['ctrlCmd']);
    expect(quickInput.NO_KEY_MODS.alt, noKeyMods['alt']);
    expect(quickInput.NO_KEY_MODS.shift, noKeyMods['shift']);

    for (final dynamic raw in _list(truth['isKeyModified'])) {
      final List<dynamic> row = _list(raw);
      expect(
        quickInput.isKeyModified(quickInput.IKeyMods(
          ctrlCmd: row[0] == 'ctrlCmd',
          alt: row[0] == 'alt',
          shift: row[0] == 'shift',
        )),
        row[1],
        reason: 'isKeyModified(${row[0]})',
      );
    }

    expect(quickInput.IQuickInputService.toString(), truth['decorator']);
    expect(Schemas.file, _map(truth['schemas'])['file']);
  });

  test('batch194 QuickPickItemScorerAccessor matches truth', () {
    final Map<String, dynamic> expected = _map(truth['scorer']);
    final URI fileUri = URI.file('/abs/dir/name.txt');
    final URI untitledUri = URI.from(UriComponents(scheme: 'untitled', path: 'name.txt'));
    final quickInput.IQuickPickItemWithResource entry =
        quickInput.IQuickPickItemWithResource(
      label: 'name.txt',
      description: 'my description',
      resource: fileUri,
    );
    final quickInput.IQuickPickItemWithResource untitledEntry =
        quickInput.IQuickPickItemWithResource(
      label: 'untitled.txt',
      description: 'd',
      resource: untitledUri,
    );
    final quickInput.IQuickPickItemWithResource bareEntry =
        quickInput.IQuickPickItemWithResource(
      label: 'bare',
      description: 'bare description',
    );

    for (final dynamic raw in _list(expected['cases'])) {
      final Map<String, dynamic> expectedCase = _map(raw);
      final String name = expectedCase['name'] as String;
      final quickInput.QuickPickItemScorerOptions? scorerOptions =
          name == 'default'
              ? null
              : quickInput.QuickPickItemScorerOptions(
                  skipDescription: name == 'skipDescription' ||
                      name == 'skipBoth',
                  skipPath: name == 'skipPath' || name == 'skipBoth',
                );
      final quickInput.QuickPickItemScorerAccessor accessor =
          quickInput.QuickPickItemScorerAccessor(scorerOptions);
      expect(accessor.getItemLabel(entry), expectedCase['label'],
          reason: '$name label');
      expect(accessor.getItemDescription(entry),
          _exp(expectedCase['description']), reason: '$name description');
      expect(accessor.getItemPath(entry), _exp(expectedCase['path']),
          reason: '$name path');
      expect(accessor.getItemPath(untitledEntry),
          _exp(expectedCase['untitledPath']), reason: '$name untitledPath');
      expect(accessor.getItemDescription(bareEntry),
          _exp(expectedCase['bareDescription']), reason: '$name bareDescription');
      expect(accessor.getItemPath(bareEntry), _exp(expectedCase['barePath']),
          reason: '$name barePath');
    }

    final Map<String, dynamic> singleton = _map(truth['scorerSingleton']);
    expect(quickInput.quickPickItemScorerAccessor, isNotNull);
    // `fsPath` follows the host path flavour (posix here), exactly like the
    // TS source's `isWindows ? win32 : posix` switch.
    expect(_map(truth['schemas'])['file'], 'file');
    expect(quickInput.quickPickItemScorerAccessor.getItemPath(entry),
        singleton['path']);
    expect(quickInput.quickPickItemScorerAccessor.getItemDescription(entry),
        singleton['description']);
  });

  test('batch194 QuickAccessRegistry matches truth (incl. splice quirk)', () {
    final Map<String, dynamic> expected = _map(truth['registry']);
    final quickAccess.QuickAccessRegistry accessRegistry =
        quickAccess.QuickAccessRegistry();
    final _FakeContextKeyService contextKeyService =
        _FakeContextKeyService();
    final _FakeWhen whenTrue = _FakeWhen('when-true');
    final _FakeWhen whenFalse = _FakeWhen('when-false');
    contextKeyService.expectedTrue = whenTrue;

    final quickAccess.IQuickAccessProviderDescriptor defaults =
        _descriptor('');
    final quickAccess.IQuickAccessProviderDescriptor ext =
        _descriptor('ext', when: whenTrue);
    final quickAccess.IQuickAccessProviderDescriptor extInstall =
        _descriptor('ext install', when: whenFalse);
    final quickAccess.IQuickAccessProviderDescriptor task = _descriptor('task');

    final dynamic disposables = <String, dynamic>{
      'defaults': accessRegistry.registerQuickAccessProvider(defaults),
      'ext': accessRegistry.registerQuickAccessProvider(ext),
      'extInstall': accessRegistry.registerQuickAccessProvider(extInstall),
      'task': accessRegistry.registerQuickAccessProvider(task),
    };

    expect(
      accessRegistry
          .getQuickAccessProviders(contextKeyService)
          .map((quickAccess.IQuickAccessProviderDescriptor p) => p.prefix)
          .toList(),
      _exp(expected['providerOrder']),
    );

    final Map<String, dynamic> lookup = _map(expected['lookup']);
    for (final String key in <String>[
      'ext install foo',
      'ext foo',
      'task list',
      'nothing',
      '',
    ]) {
      expect(accessRegistry.getQuickAccessProvider(key, contextKeyService)?.prefix,
          _exp(lookup[key]), reason: 'lookup "$key"');
    }
    // `ext install` has a false `when`, so it never wins.
    expect(
        accessRegistry
            .getQuickAccessProvider('ext install foo', contextKeyService)
            ?.prefix,
        _exp(lookup['ext install foo (when false)']));

    expect(
      accessRegistry
          .getQuickAccessProviders(contextKeyService)
          .map((quickAccess.IQuickAccessProviderDescriptor p) =>
              <String, Object?>{'prefix': p.prefix, 'when': p.when == null ? null : (p.when as dynamic).id})
          .toList(),
      _exp(expected['whenFiltered']),
    );

    (disposables['ext'] as dynamic).dispose();
    (disposables['extInstall'] as dynamic).dispose();
    final Map<String, dynamic> afterDispose = _map(expected['afterDispose']);
    expect(
      accessRegistry
          .getQuickAccessProviders(contextKeyService)
          .map((quickAccess.IQuickAccessProviderDescriptor p) => p.prefix)
          .toList(),
      _exp(afterDispose['providerOrder']),
    );
    expect(
        accessRegistry.getQuickAccessProvider('ext foo', contextKeyService)?.prefix,
        _exp(afterDispose['lookupExt']));

    // Disposing the default provider drops `indexOf(default) === -1`, which
    // splices the last prefixed provider — the source quirk.
    (disposables['defaults'] as dynamic).dispose();
    expect(
      accessRegistry
          .getQuickAccessProviders(contextKeyService)
          .map((quickAccess.IQuickAccessProviderDescriptor p) => p.prefix)
          .toList(),
      _exp(_map(expected['afterDefaultDispose'])['providerOrder']),
    );

    final void Function() restore = accessRegistry.clear();
    expect(
      accessRegistry
          .getQuickAccessProviders(contextKeyService)
          .map((quickAccess.IQuickAccessProviderDescriptor p) => p.prefix)
          .toList(),
      _exp(_map(expected['afterClear'])['providerOrder']),
    );
    restore();
    final Map<String, dynamic> afterRestore = _map(expected['afterRestore']);
    expect(
      accessRegistry
          .getQuickAccessProviders(contextKeyService)
          .map((quickAccess.IQuickAccessProviderDescriptor p) => p.prefix)
          .toList(),
      _exp(afterRestore['providerOrder']),
    );
    expect(accessRegistry.getQuickAccessProvider('task x', contextKeyService)?.prefix,
        _exp(afterRestore['lookupTask']));
  });

  test('batch194 module-level registry side effect matches truth', () {
    final Map<String, dynamic> expected = _map(truth['registryExtension']);
    // Touch the lazy registration to mirror the module-load side effect.
    quickAccess.quickAccessRegistryRegistration;
    final Object? registered =
        registry.Registry.as(quickAccess.Extensions.Quickaccess);
    expect(registered != null, expected['registered']);
    expect(registered is quickAccess.QuickAccessRegistry, expected['isRegistry']);
  });
}