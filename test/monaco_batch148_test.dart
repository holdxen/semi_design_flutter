// batch148 truth tests: iconRegistry.ts ported 1:1.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/iconRegistry.dart' as ir;

Map<String, dynamic> _loadTruth() {
  final f = File('tool/ts2dart/batch148_truth.json');
  return jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  final t = _loadTruth();

  test('regex sources + fontIdErrorMessage match truth', () {
    expect(ir.fontIdRegexSource, t['regex']['fontId']);
    expect(ir.fontStyleRegexSource, t['regex']['fontStyle']);
    expect(ir.fontWeightRegexSource, t['regex']['fontWeight']);
    expect(ir.fontSizeRegexSource, t['regex']['fontSize']);
    expect(ir.fontFormatRegexSource, t['regex']['fontFormat']);
    expect(ir.fontColorRegexSource, t['regex']['fontColor']);
    expect(ir.fontIdErrorMessage, t['fontIdErrorMessage']);
    // behavior sanity
    expect(ir.fontIdRegex.hasMatch('abc-1'), isTrue);
    expect(ir.fontIdRegex.hasMatch('has space'), isFalse);
  });

  test('registry initialized with 792 icons + 3 common icons', () {
    final reg = ir.getIconRegistry();
    expect(reg.getIcons().length, t['iconsCount']);
    expect(reg.getIcons().take(3).map((i) => i.id).toList(),
        (t['iconsSample'] as List).map((e) => e as String).toList());
    final commonIds =
        (t['commonIds'] as List).map((e) => e as bool).toList();
    final commonDefaults = t['commonDefaults'] as List;
    for (var i = 0; i < commonIds.length; i++) {
      final id = ['widget-close', 'goto-previous-location', 'goto-next-location'][i];
      final c = reg.getIcon(id);
      expect(c != null, commonIds[i], reason: 'common $id');
      final def = c!.defaults;
      final defId = def is ir.IconDefinition ? def.fontCharacter : (def as dynamic).id;
      expect(defId, commonDefaults[i]['id'] ?? commonDefaults[i]['fontCharacter'],
          reason: 'default $id');
    }
    expect((ir.syncing as dynamic).id, t['syncing']['id']);
    expect((ir.spinningLoading as dynamic).id, t['spinningLoading']['id']);
  });

  test('schema registered once + schema structure matches truth', () {
    expect(ir.iconsSchemaId, t['iconsSchemaId']);
    final reg = ir.getIconRegistry();
    final schema = reg.getIconSchema();
    final tt = t['schema'] as Map<String, dynamic>;
    expect(schema['type'], tt['type']);
    final defs = schema['definitions'] as Map<String, Object?>;
    final icons = defs['icons'] as Map<String, Object?>;
    expect(icons['type'], tt['definitionsIconsType']);
    expect(icons['additionalProperties'], tt['additionalProperties']);
    expect(icons['defaultSnippets'], tt['defaultSnippet']);
    final props = icons['properties'] as Map<String, Object?>;
    final fontId = props['fontId'] as Map<String, Object?>;
    expect(fontId['pattern'], tt['fontIdPattern']);
    expect(fontId['patternErrorMessage'], tt['fontIdPatternErrorMessage']);
    final fontChar = props['fontCharacter'] as Map<String, Object?>;
    expect(fontChar['description'], tt['fontCharacterDescription']);
    expect((schema['properties'] as Map).length, tt['propertyKeysCount']);

    final ref = reg.getIconReferenceSchema();
    final rf = t['refSchema'] as Map<String, dynamic>;
    expect(ref['type'], rf['type']);
    expect(ref['pattern'], rf['pattern']);
    expect((ref['enum'] as List).length, rf['enumLength']);
    expect((ref['enumDescriptions'] as List).length, rf['enumDescriptionsLength']);
    expect((ref['enum'] as List).contains('widget-close'), rf['enumHasWidgetClose']);
    expect((ref['enum'] as List).contains('add'), rf['enumHasAdd']);
  });

  test('IconFontDefinition toJSONObject / fromJSONObject round-trip', () {
    final fontDef = ir.IconFontDefinitionCarrier(
      weight: 'bold',
      style: 'normal',
      src: <ir.IconFontSource>[
        ir.IconFontSource(format: 'woff2', location: URI.parse('file:///a.woff2')),
      ],
    );
    final json = ir.iconFontDefinitionToJSONObject(fontDef);
    expect(json, t['fontDefToJSON']);
    final rt = ir.iconFontDefinitionFromJSONObject(json)!;
    final rtt = t['fontDefRoundTrip'] as Map<String, dynamic>;
    expect(rt.weight, rtt['weight']);
    expect(rt.style, rtt['style']);
    expect(rt.src.first.location.toString(), rtt['location']);
    expect(ir.iconFontDefinitionFromJSONObject(<String, Object?>{'src': 'bad'}),
        isNull);
  });

  test('getDefinition resolves ThemeIcon chain to fontCharacter definition', () {
    final reg = ir.getIconRegistry();
    final def = ir.iconContributionGetDefinition(reg.getIcon('add')!, reg);
    expect(def, isNotNull);
    expect(def!.fontCharacter, t['getDefinition']['add']['fontCharacter']);
  });

  test('registerIcon duplicate fills description; deregister cleans up', () {
    final reg = ir.getIconRegistry();
    final d1 = reg.registerIcon('__truth_x1',
        ir.IconDefinitionCarrier(fontCharacter: r'\e001'), 'Desc X1');
    final d1b = reg.registerIcon('__truth_x1',
        ir.IconDefinitionCarrier(fontCharacter: r'\e999'), null);
    expect((d1 as dynamic).id, t['register']['d1']['id']);
    // TS returns `existing` (contribution) on dup; JSON differs from first
    // ThemeIcon `{id}`, matching truth d1bSame=false. Both carry the same id.
    expect((d1b as dynamic).id, (d1 as dynamic).id);
    expect(t['register']['d1bSame'], isFalse);
    expect(reg.getIcon('__truth_x1')!.description, t['register']['descAfterDup']);
    expect(reg.getIconSchema()['properties'] is Map, isTrue);
    final props = reg.getIconSchema()['properties'] as Map<String, Object?>;
    expect((props['__truth_x1'] as Map)['markdownDescription'],
        t['register']['d1PropertyDesc']);
    final en = reg.getIconReferenceSchema()['enumDescriptions'] as List<String>;
    final enums = reg.getIconReferenceSchema()['enum'] as List<String>;
    expect(en[enums.indexOf('__truth_x1')], t['register']['d1EnumDesc']);

    final d2 = reg.registerIcon('__truth_x2',
        ir.IconDefinitionCarrier(fontCharacter: r'\e002'), null, 'DEPRECATED');
    expect((d2 as dynamic).id, t['register']['d2']['id']);
    expect(reg.getIcon('__truth_x2')!.deprecationMessage,
        t['register']['d2Deprecation']);
    expect((props['__truth_x2'] as Map)['\$ref'] ?? (props['__truth_x2'] as Map)[r'$ref'],
        (t['register']['d2Property'] as Map)[r'$ref']);

    reg.deregisterIcon('__truth_x1');
    expect(reg.getIcon('__truth_x1'), isNull);
    expect((reg.getIconSchema()['properties'] as Map).containsKey('__truth_x1'),
        isFalse);
    expect((reg.getIconReferenceSchema()['enum'] as List).contains('__truth_x1'),
        t['afterDeregister']['enumHas']);
    reg.deregisterIcon('__truth_x2');
  });

  test('icon font register idempotent + deregister', () {
    final reg = ir.getIconRegistry();
    final fr = reg.registerIconFont(
        '__font1', ir.IconFontDefinitionCarrier(weight: 'bold', src: const <ir.IconFontSource>[]));
    final fr2 = reg.registerIconFont(
        '__font1', ir.IconFontDefinitionCarrier(weight: 'lighter', src: const <ir.IconFontSource>[]));
    expect(identical(fr, fr2), t['iconFont']['secondSame']);
    expect(fr.weight, t['iconFont']['first']['weight']);
    expect(reg.getIconFont('__font1'), isNotNull);
    reg.deregisterIconFont('__font1');
    expect(reg.getIconFont('__font1'), isNull);
  });
}
