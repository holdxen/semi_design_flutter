// batch273: modesRegistry.ts truth replay.
// Truth from tool/ts2dart/batch273_truth.json (recursive TS transpile+vm,
// real Registry / configurationRegistry side effects captured).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/languages/language.dart'
    show ILanguageExtensionPoint;
import 'package:semi_design_flutter/src/monaco/editor/common/languages/modesRegistry.dart'
    show
        EditorModesRegistry,
        Extensions,
        ModesRegistry,
        PLAINTEXT_EXTENSION,
        PLAINTEXT_LANGUAGE_ID;
import 'package:semi_design_flutter/src/monaco/platform/configuration/common/configurationRegistry.dart'
    as config show Extensions, IConfigurationRegistry;
import 'package:semi_design_flutter/src/monaco/platform/registry/common/platform.dart'
    show Registry;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch273_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Map<String, Object?> _lang(ILanguageExtensionPoint d) {
  final Map<String, Object?> out = <String, Object?>{'id': d.id};
  if (d.extensions != null) out['extensions'] = d.extensions;
  if (d.filenames != null) out['filenames'] = d.filenames;
  if (d.filenamePatterns != null) out['filenamePatterns'] = d.filenamePatterns;
  if (d.firstLine != null) out['firstLine'] = d.firstLine;
  if (d.aliases != null) out['aliases'] = d.aliases;
  if (d.mimetypes != null) out['mimetypes'] = d.mimetypes;
  if (d.configuration != null) out['configuration'] = d.configuration.toString();
  return out;
}

void main() {
  final t = _truth();

  test('b273 runtime export keys and constants match truth', () {
    expect(t['exportKeys'], <String>[
      'EditorModesRegistry',
      'Extensions',
      'ModesRegistry',
      'PLAINTEXT_EXTENSION',
      'PLAINTEXT_LANGUAGE_ID',
    ]);
    final c = t['constants'] as Map<String, dynamic>;
    expect(Extensions.ModesRegistry, c['modesRegistryId']);
    expect(PLAINTEXT_LANGUAGE_ID, c['plaintextLanguageId']);
    expect(PLAINTEXT_EXTENSION, c['plaintextExtension']);
  });

  test('b273 global registry side effects match truth', () {
    final r = t['registry'] as Map<String, dynamic>;
    expect(r['knowsModesRegistry'], isTrue);
    // Dart initializes top-level finals lazily; touching ModesRegistry plays
    // the TS module-load side effects (Registry.add / language / defaults).
    final modes = ModesRegistry;
    expect(modes, isNotNull);
    expect(Registry.knows(Extensions.ModesRegistry), isTrue);
    expect(r['sameInstance'], isTrue);
    expect(identical(Registry.as(Extensions.ModesRegistry), ModesRegistry), isTrue);

    expect(
      ModesRegistry.getLanguages().map(_lang).toList(),
      t['initialLanguages'],
    );

    final configRegistry = Registry.as(config.Extensions.Configuration)
        as config.IConfigurationRegistry;
    final plaintextDefaults = configRegistry
        .getRegisteredDefaultConfigurations()
        .where((d) => d.overrides.containsKey('[plaintext]'))
        .map((d) => <String, Object?>{'overrides': d.overrides})
        .toList();
    expect(plaintextDefaults, t['configDefaults']);
  });

  test('b273 register/dispose behaviour matches truth', () {
    final local = EditorModesRegistry();
    int changes = 0;
    local.onDidChangeLanguages((_) => changes++);

    final d1 = ILanguageExtensionPoint(
      id: 'one',
      extensions: <String>['.one'],
      aliases: <String>['One'],
    );
    final d2 = ILanguageExtensionPoint(
      id: 'two',
      extensions: <String>['.two'],
      aliases: <String>['Two'],
    );
    final h1 = local.registerLanguage(d1);
    final h2 = local.registerLanguage(d2);
    final afterRegister = local.getLanguages().map(_lang).toList();

    h1.dispose();
    final afterDisposeOne = local.getLanguages().map(_lang).toList();
    h1.dispose();
    final afterDoubleDispose = local.getLanguages().map(_lang).toList();
    h2.dispose();
    final afterDisposeAll = local.getLanguages().map(_lang).toList();

    final ops = t['ops'] as Map<String, dynamic>;
    expect(changes, ops['changeCount']);
    expect(afterRegister, ops['afterRegister']);
    expect(afterDisposeOne, ops['afterDisposeOne']);
    expect(afterDoubleDispose, ops['afterDoubleDispose']);
    expect(afterDisposeAll, ops['afterDisposeAll']);
  });
}
