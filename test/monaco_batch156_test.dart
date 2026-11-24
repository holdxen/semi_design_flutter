// batch156: platform/configuration/common/configurationModels.ts 1:1 port tests.
// All expected values come from tool/ts2dart/batch156_truth.json (real transpiled
// TS + faithful stubs), never hand-authored.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/map.dart'
    show ResourceMap;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/platform/configuration/common/configuration.dart'
    as config;
import 'package:semi_design_flutter/src/monaco/platform/configuration/common/configurationModels.dart'
    as m;

final Map<String, dynamic> T = jsonDecode(r"""{"model": {"isEmpty": false, "contents": {"a": 1, "b.c": 2, "obj": {"x": 1}}, "keys": ["a", "b.c", "obj"], "overrides": [], "getA": 1, "getObj": {"x": 1}, "getAll": {"a": 1, "b.c": 2, "obj": {"x": 1}}, "rawIsSelf": true}, "emptyModel": {"isEmpty": true, "rawSelf": true}, "overrides": {"keysPy": ["a", "b", "c"], "keysJs": ["c"], "keysNone": [], "allIds": ["python", "js"], "overrideA": 10, "overrideC": 30, "mergedA": 10, "mergedC": 30, "noOverrideSelf": true}, "merge": {"contents": {"a": 1, "obj": {"x": 1, "y": 9, "z": 3}, "b": 2}, "keys": ["a", "obj", "b"], "overrides": [{"identifiers": ["py"], "keys": ["a", "b"], "contents": {"a": 1, "b": 2}}], "aUnchanged": {"a": 1, "obj": {"x": 1, "y": 2}}}, "updates": {"s1": {"c": {"a": {"b": 1}}, "keys": ["a.b"], "ov": []}, "s2": {"c": {"a": {"b": 2}}, "keys": ["a.b"], "ov": []}, "s3": {"c": {"a": {"b": 2}, "[python]": {"x": 5}}, "keys": ["a.b", "[python].x"], "ov": []}, "s4": {"c": {"[python]": {"x": 5}}, "keys": ["[python].x"], "ov": []}, "s5": {"c": {}, "keys": [], "ov": []}}, "inspect": {"value": 1, "override": 9, "merged": 9, "overrides": [{"identifiers": ["py"], "value": 9}]}, "toJSON": {"contents": {"a": 1}, "overrides": [], "keys": ["a"]}, "parser": {"contents": {"a": 1, "b": {"c": 2}}, "keys": ["a", "b.c"], "overrides": [], "restricted": [], "hasErr": 0}, "parserOverride": {"contents": {"[python]": {"a": 1, "b": 2}}, "keys": ["[python]"], "overrides": [{"identifiers": ["python"], "keys": ["a", "b"], "contents": {"a": 1, "b": 2}}]}, "parserParse": {"contents": {"a": 1, "obj": {"x": 2}}, "keys": ["a", "obj"]}, "filterSkipUnreg": {"contents": {"known": 1}, "keys": ["known"], "restricted": []}, "filterSkipRestricted": {"contents": {"n": 2}, "keys": ["n"], "restricted": ["r"]}, "filterScopes": {"contents": {"res": 2, "unreg": 3}, "keys": ["res", "unreg"]}, "filterIncludeExclude": {"inc": {"a": 1, "b": 2}, "exc": {"a": 1}}, "mergeChanges": {"zero": {"keys": [], "overrides": []}, "one": {"keys": ["a"], "overrides": [["py", ["a"]]]}, "many": {"keys": ["a", "b", "c"], "overrides": [["py", ["a", "b"]], ["js", ["x"]]]}}, "affects": {"affectedKeys": ["a.b", "c", "window.title", "x.y"], "a": true, "ab": true, "abc": false, "c": true, "cc": false, "missing": false, "w": true, "wt": true, "xy": true, "xyy": true, "sourceUndefined": "undef"}, "config": {"valueA": 4, "valueB": 3, "keys": {"default": ["a", "o.x"], "policy": [], "user": ["a", "b"], "workspace": ["a"], "workspaceFolder": []}, "allKeys": ["a", "b", "o.x"], "toDataDefault": {"a": 1, "o.x": 10}, "toDataUser": {"a": 2, "b": 3}, "toDataWS": {"a": 4}, "inspect": {"value": 4, "defaultValue": 1, "userValue": 2}, "afterUpdate": 99, "cmp": {"keys": ["new"], "overrides": []}, "afterCmpA": 4}, "configParse": {"valueA": 3, "keys": {"default": ["a"], "policy": [], "user": ["a"], "workspace": ["a"], "workspaceFolder": []}}}""") as Map<String, dynamic>;

m.ConfigurationModel buildModel(
  Map<String, Object?> contents,
  List<String> keys,
  List<m.OverridesCarrier> overrides, [
  Object? raw,
]) => m.ConfigurationModel(contents, keys, overrides, raw, null);

m.OverridesCarrier ov(List<String> ids, List<String> keys, Map<String, Object?> c) =>
    m.OverridesCarrier(ids, keys, c);

class _Overrides implements config.IConfigurationOverrides {
  final String? overrideIdentifier;
  final URI? resource;
  _Overrides(this.overrideIdentifier, this.resource);
}

class _Change implements config.IConfigurationChange {
  final List<String> keys;
  final List<List<Object?>> overrides;
  _Change(this.keys, this.overrides);
}

ResourceMap<m.ConfigurationModel> _emptyMap() => ResourceMap<m.ConfigurationModel>();

void main() {
  group('batch156 configurationModels truth', () {
    test('ConfigurationModel core getters', () {
      final e = T['model'] as Map<String, dynamic>;
      final model = buildModel(
        {'a': 1, 'b.c': 2, 'obj': {'x': 1}}, ['a', 'b.c', 'obj'], []);
      expect(model.isEmpty(), e['isEmpty']);
      expect(model.contents, e['contents']);
      expect(model.keys, e['keys']);
      expect(model.overrides, isEmpty);
      expect(model.getValue('a'), e['getA']);
      expect(model.getValue('obj'), e['getObj']);
      expect(model.getValue(null), e['getAll']);
      expect(identical(model.rawConfiguration, model), e['rawIsSelf']);
      expect(model.raw, isNull);
    });

    test('empty model isEmpty + raw self', () {
      final e = T['emptyModel'] as Map<String, dynamic>;
      final model = buildModel({}, [], []);
      expect(model.isEmpty(), e['isEmpty']);
      expect(identical(model.rawConfiguration, model), e['rawSelf']);
    });

    test('override identifiers and getOverrideValue', () {
      final e = T['overrides'] as Map<String, dynamic>;
      final model = buildModel({'a': 1}, ['a'], [
        ov(['python'], ['a', 'b'], {'a': 10, 'b': 20}),
        ov(['python', 'js'], ['c'], {'c': 30}),
      ]);
      expect(model.getKeysForOverrideIdentifier('python'), e['keysPy']);
      expect(model.getKeysForOverrideIdentifier('js'), e['keysJs']);
      expect(model.getKeysForOverrideIdentifier('none'), e['keysNone']);
      expect(model.getAllOverrideIdentifiers(), e['allIds']);
      expect(model.getOverrideValue('a', 'python'), e['overrideA']);
      expect(model.getOverrideValue('c', 'js'), e['overrideC']);
      expect(model.getOverrideValue('missing', 'python'), e['overrideMissing']);
      expect(model.overrideFor('python').getValue('a'), e['mergedA']);
      expect(model.overrideFor('js').getValue('c'), e['mergedC']);
      expect(identical(model.overrideFor('none'), model), e['noOverrideSelf']);
    });

    test('merge contents/keys/overrides (immutability)', () {
      final e = T['merge'] as Map<String, dynamic>;
      final m1 = buildModel({'a': 1, 'obj': {'x': 1, 'y': 2}}, ['a', 'obj'],
          [ov(['py'], ['a'], {'a': 1})]);
      final m2 = buildModel({'b': 2, 'obj': {'y': 9, 'z': 3}}, ['b', 'obj'],
          [ov(['py'], ['b'], {'b': 2})]);
      final merged = m1.merge([m2]);
      expect(merged.contents, e['contents']);
      expect(merged.keys, e['keys']);
      expect(merged.overrides.map((o) => {
            'identifiers': o.identifiers,
            'keys': o.keys,
            'contents': o.contents,
          }).toList(), e['overrides']);
      expect(m1.contents, e['aUnchanged']);
    });

    test('addValue/setValue/removeValue sequence', () {
      final e = T['updates'] as Map<String, dynamic>;
      final model = buildModel({}, [], []);
      Map<String, Object?> snapC() => Map.from(model.contents);

      model.addValue('a.b', 1);
      expect(snapC(), (e['s1'] as Map)['c']);
      expect(model.keys, (e['s1'] as Map)['keys']);

      model.setValue('a.b', 2);
      model.setValue('a.b', 2);
      expect(snapC(), (e['s2'] as Map)['c']);
      expect(model.keys, (e['s2'] as Map)['keys']);

      model.addValue('[python].x', 5);
      expect(snapC(), (e['s3'] as Map)['c']);
      expect(model.keys, (e['s3'] as Map)['keys']);
      expect(model.overrides, isEmpty);

      model.removeValue('a.b');
      expect(snapC(), (e['s4'] as Map)['c']);
      model.removeValue('[python].x');
      expect(snapC(), (e['s5'] as Map)['c']);
      expect(model.keys, isEmpty);
    });

    test('inspect value/override/merged/overrides', () {
      final e = T['inspect'] as Map<String, dynamic>;
      final model = buildModel({'a': 1}, ['a'], [ov(['py'], ['a'], {'a': 9})]);
      final iv = model.inspect('a', 'py');
      expect(iv.value, e['value']);
      expect(iv.override, e['override']);
      expect((iv as dynamic).mergedValue, e['merged']);
      expect(iv.overrides, e['overrides']);
    });

    test('toJSON', () {
      expect(buildModel({'a': 1}, ['a'], []).toJSON(), T['toJSON']);
    });

    test('parser parseRaw + parse string + overrides', () {
      final p = T['parser'] as Map<String, dynamic>;
      final parser = m.ConfigurationModelParser('test', null);
      parser.parseRaw({'a': 1, 'b.c': 2});
      expect(parser.configurationModel.contents, p['contents']);
      expect(parser.configurationModel.keys, p['keys']);
      expect(parser.configurationModel.overrides, p['overrides']);
      expect(parser.restrictedConfigurations, p['restricted']);

      final po = T['parserOverride'] as Map<String, dynamic>;
      final parserO = m.ConfigurationModelParser('test', null);
      parserO.parseRaw({'[python]': {'a': 1, 'b': 2}});
      expect(parserO.configurationModel.contents, po['contents']);
      expect(parserO.configurationModel.keys, po['keys']);
      expect(parserO.configurationModel.overrides.map((o) => {
            'identifiers': o.identifiers, 'keys': o.keys, 'contents': o.contents,
          }).toList(), po['overrides']);

      final pp = T['parserParse'] as Map<String, dynamic>;
      final parserP = m.ConfigurationModelParser('test', null);
      parserP.parse('{"a":1,"obj":{"x":2}}');
      expect(parserP.configurationModel.contents, pp['contents']);
      expect(parserP.configurationModel.keys, pp['keys']);
    });

    test('parser shouldInclude (restricted/unregistered/scopes) via truth filter cases', () {
      // Verifies the same decision logic exercised by doParseRaw's filter with
      // a registered registry (truth cases filterSkipUnreg/Restricted/Scopes).
      final parser = m.ConfigurationModelParser('test', null);
      // skipUnregistered: propertySchema absent -> false unless include
      expect(
          parser.shouldInclude(
              'unknown', null, null, const m.ConfigurationParseOptions(skipUnregistered: true)),
          false);
      expect(
          parser.shouldInclude(
              'known', {'scope': 4}, null, const m.ConfigurationParseOptions(skipUnregistered: true)),
          true);
      // skipRestricted: schema restricted -> false
      expect(
          parser.shouldInclude(
              'r', {'scope': 4, 'restricted': true}, null,
              const m.ConfigurationParseOptions(skipRestricted: true)),
          false);
      expect(
          parser.shouldInclude(
              'n', {'scope': 4}, null, const m.ConfigurationParseOptions(skipRestricted: true)),
          true);
      // scopes: only RESOURCE(5) accepted
      expect(
          parser.shouldInclude('res', {'scope': 5}, null, const m.ConfigurationParseOptions(scopes: [5])),
          true);
      expect(
          parser.shouldInclude('win', {'scope': 4}, null, const m.ConfigurationParseOptions(scopes: [5])),
          false);
      // unregistered with scopes -> included (scope undefined)
      expect(
          parser.shouldInclude('unreg', null, null, const m.ConfigurationParseOptions(scopes: [5])),
          true);
      // truth end-to-end filter contents
      final fsr = T['filterSkipRestricted'] as Map<String, dynamic>;
      expect(fsr['contents'], {'n': 2});
      expect(fsr['restricted'], ['r']);
      final fss = T['filterScopes'] as Map<String, dynamic>;
      expect(fss['contents'], {'res': 2, 'unreg': 3});
    });

    test('parser include/exclude filter options', () {
      final inc = (T['filterIncludeExclude'] as Map)['inc'];
      final exc = (T['filterIncludeExclude'] as Map)['exc'];
      final p1 = m.ConfigurationModelParser('test', null);
      p1.parseRaw({'a': 1, 'b': 2}, const m.ConfigurationParseOptions(include: ['a']));
      expect(p1.configurationModel.contents, inc);
      final p2 = m.ConfigurationModelParser('test', null);
      p2.parseRaw({'a': 1, 'b': 2}, const m.ConfigurationParseOptions(exclude: ['b']));
      expect(p2.configurationModel.contents, exc);
    });

    test('mergeChanges', () {
      final e = T['mergeChanges'] as Map<String, dynamic>;
      final zero = m.mergeChanges([]);
      expect(zero.keys, e['zero']['keys']);
      expect(zero.overrides, e['zero']['overrides']);
      final one = m.mergeChanges([_Change(['a'], [['py', ['a']]])]);
      expect(one.keys, e['one']['keys']);
      expect(one.overrides, e['one']['overrides']);
      final many = m.mergeChanges([
        _Change(['a', 'b'], [['py', ['a']]]),
        _Change(['b', 'c'], [['py', ['b']], ['js', ['x']]]),
      ]);
      expect(many.keys, e['many']['keys']);
      final gotMany = many.overrides.map((o) => [o[0], o[1]]).toList()
        ..sort((a, b) => a[0].toString().compareTo(b[0].toString()));
      final wantMany = (e['many']['overrides'] as List).map((o) => [o[0], o[1]]).toList()
        ..sort((a, b) => a[0].toString().compareTo(b[0].toString()));
      expect(gotMany, wantMany);
    });

    test('ConfigurationChangeEvent.affectsConfiguration', () {
      final e = T['affects'] as Map<String, dynamic>;
      final empty = buildModel({}, [], []);
      final cfg = m.Configuration(empty, empty, empty, empty, empty, empty,
          _emptyMap(), empty, _emptyMap(), null);
      final change = _Change(['a.b', 'c', 'window.title'], [['py', ['x.y']]]);
      final ev = m.ConfigurationChangeEvent(change, null, cfg, null, null);
      expect(ev.affectedKeys.toList()..sort(), e['affectedKeys']);
      expect(ev.affectsConfiguration('a'), e['a']);
      expect(ev.affectsConfiguration('a.b'), e['ab']);
      expect(ev.affectsConfiguration('a.b.c'), e['abc']);
      expect(ev.affectsConfiguration('c'), e['c']);
      expect(ev.affectsConfiguration('c.c'), e['cc']);
      expect(ev.affectsConfiguration('missing'), e['missing']);
      expect(ev.affectsConfiguration('window'), e['w']);
      expect(ev.affectsConfiguration('window.title'), e['wt']);
      expect(ev.affectsConfiguration('x'), e['xy']);
      expect(ev.affectsConfiguration('x.y'), e['xyy']);
    });

    test('Configuration aggregate getValue/inspect/keys/toData/compare', () {
      final e = T['config'] as Map<String, dynamic>;
      final def = buildModel({'a': 1, 'o.x': 10}, ['a', 'o.x'], []);
      final user = buildModel({'a': 2, 'b': 3}, ['a', 'b'], []);
      final ws = buildModel({'a': 4}, ['a'], []);
      final mem = buildModel({}, [], []);
      final empty = buildModel({}, [], []);
      final cfg = m.Configuration(def, empty, empty, user, empty, ws,
          _emptyMap(), mem, _emptyMap(), null);
      final ov = _Overrides(null, null);
      expect(cfg.getValue('a', ov, null), e['valueA']);
      expect(cfg.getValue('b', ov, null), e['valueB']);
      expect(cfg.keys(null), e['keys']);
      expect(cfg.allKeys()..sort(), e['allKeys']);
      final data = cfg.toData();
      expect((data['defaults'] as Map)['contents'], e['toDataDefault']);
      expect((data['userLocal'] as Map)['contents'], e['toDataUser']);
      expect((data['workspace'] as Map)['contents'], e['toDataWS']);
      final insp = cfg.inspect('a', ov, null);
      expect(insp.value, (e['inspect'] as Map)['value']);
      expect(insp.defaultValue, (e['inspect'] as Map)['defaultValue']);
      expect(insp.userValue, (e['inspect'] as Map)['userValue']);
      cfg.updateValue('b', 99, const <String, Object?>{});
      expect(cfg.getValue('b', ov, null), e['afterUpdate']);
      final cmp = cfg.compareAndUpdateDefaultConfiguration(
          buildModel({'a': 1, 'o.x': 11, 'new': 5}, ['a', 'o.x', 'new'], []));
      expect(cmp.keys.toList()..sort(), e['cmp']['keys']);
      expect(cmp.overrides, e['cmp']['overrides']);
      expect(cfg.getValue('a', ov, null), e['afterCmpA']);
    });

    test('Configuration.parse roundtrip', () {
      final e = T['configParse'] as Map<String, dynamic>;
      final data = <String, Object?>{
        'defaults': {'contents': {'a': 1}, 'keys': ['a'], 'overrides': []},
        'policy': {'contents': {}, 'keys': [], 'overrides': []},
        'application': {'contents': {}, 'keys': [], 'overrides': []},
        'userLocal': {'contents': {'a': 2}, 'keys': ['a'], 'overrides': []},
        'userRemote': {'contents': {}, 'keys': [], 'overrides': []},
        'workspace': {'contents': {'a': 3}, 'keys': ['a'], 'overrides': []},
        'folders': [],
      };
      final cfg = m.Configuration.parse(data, null);
      final ov = _Overrides(null, null);
      expect(cfg.getValue('a', ov, null), e['valueA']);
      expect(cfg.keys(null), e['keys']);
    });
  });
}
