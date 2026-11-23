// Data-driven verification of batch115 port against real TS runtime truth.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/editor/common/services/completionsEnablement.dart'
    as ce;
import 'package:semi_design_flutter/src/monaco/editor/common/services/textResourceConfiguration.dart'
    show ITextResourceConfigurationServiceType;
import 'package:semi_design_flutter/src/monaco/platform/configuration/common/configuration.dart'
    show IConfigurationServiceType;
import 'package:semi_design_flutter/src/monaco/platform/product/common/product.dart'
    as prod;

final Map<String, dynamic> truth =
    (jsonDecode(File('tool/ts2dart/batch115_truth.json').readAsStringSync())
            as Map)
        .cast<String, dynamic>();

class _ConfigService implements IConfigurationServiceType {
  final Object? value;
  final List<List<Object?>> calls = <List<Object?>>[];
  _ConfigService(this.value);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getValue$1) {
      calls.add(invocation.positionalArguments.cast<Object?>());
      return value;
    }
    return super.noSuchMethod(invocation);
  }
}

class _ResourceConfigService implements ITextResourceConfigurationServiceType {
  final Object? value;
  final List<List<Object?>> calls = <List<Object?>>[];
  _ResourceConfigService(this.value);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getValue$1) {
      calls.add(invocation.positionalArguments.cast<Object?>());
      return value;
    }
    return super.noSuchMethod(invocation);
  }
}

void _setProduct(Map<String, Object?> value) {
  prod.resetProductForTest();
  prod.vscodeContextConfigurationProvider = null;
  prod.vscodeProductJsonProvider = null;
  prod.vscodePackageJsonProvider = null;
  prod.vscodeContextConfigurationProvider = () => <String, Object?>{
        'product': value,
      };
}

List<List<Object?>> _normCalls(List<dynamic> src) => src
    .map((dynamic e) => (e as List<dynamic>).cast<Object?>())
    .toList();

void main() {
  group('batch115 completionsEnablement.ts', () {
    test('missing product setting short-circuits without config reads', () {
      final t = (truth['noSetting'] as Map).cast<String, dynamic>();
      _setProduct(<String, Object?>{'nameShort': 'no-agent'});
      final config = _ConfigService(<String, Object?>{'*': true});
      final resourceConfig =
          _ResourceConfigService(<String, Object?>{'*': true});
      expect(ce.isCompletionsEnabled(config, 'ts'), t['withConfig']);
      expect(
          ce.isCompletionsEnabledWithTextResourceConfig(
              resourceConfig, URI.parse('file:///a.ts'), 'ts'),
          t['withResource']);
      expect(config.calls, isEmpty);
      expect(resourceConfig.calls, isEmpty);
      expect(t['calls'], isEmpty);
    });

    test('setting name is read from product and config calls match TS', () {
      final t = (truth['withSetting'] as Map).cast<String, dynamic>();
      _setProduct(<String, Object?>{
        'defaultChatAgent': <String, Object?>{
          'completionsEnablementSetting': 'chat.enable',
        },
      });
      final config = _ConfigService(<String, Object?>{
        '*': true,
        'ts': false,
        'py': true,
      });
      final resourceConfig = _ResourceConfigService(<String, Object?>{
        '*': true,
        'ts': false,
        'py': true,
      });
      final resource = URI.parse('file:///a.ts');
      expect(ce.isCompletionsEnabled(config, 'ts'), t['withConfig']);
      expect(ce.isCompletionsEnabledWithTextResourceConfig(
          resourceConfig, resource, 'ts'), t['withResource']);

      final expectedCalls = _normCalls(t['calls'] as List<dynamic>);
      expect(config.calls, <List<Object?>>[<Object?>['chat.enable']]);
      expect(config.calls, expectedCalls.sublist(0, 1));
      expect(resourceConfig.calls.length, 1);
      expect(resourceConfig.calls.first[0], same(resource));
      expect(resourceConfig.calls.first[1], 'chat.enable');
      expect(expectedCalls[1][1], 'chat.enable');

      final cases = (t['fromObjectCases'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      for (final Map<String, dynamic> c in cases) {
        final Object? input = c['input'] == '__undefined__' ? null : c['input'];
        expect(ce.isCompletionsEnabledFromObject(input), c['defaultMode'],
            reason: 'default mode for $input');
        expect(ce.isCompletionsEnabledFromObject(input, 'ts'), c['tsMode'],
            reason: 'ts mode for $input');
      }
    });

    test('modeId defaults to "*"', () {
      final t = (truth['defaultMode'] as Map).cast<String, dynamic>();
      _setProduct(<String, Object?>{
        'defaultChatAgent': <String, Object?>{
          'completionsEnablementSetting': 'chat.enable',
        },
      });
      final config = _ConfigService(<String, Object?>{'*': true});
      final resourceConfig =
          _ResourceConfigService(<String, Object?>{'*': true});
      expect(ce.isCompletionsEnabled(config), t['withConfig']);
      expect(ce.isCompletionsEnabledWithTextResourceConfig(
          resourceConfig, URI.parse('file:///a.ts')), t['withResource']);
    });
  });
}
