// Data-driven verification of batch114 port against real TS runtime truth.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/common/process.dart'
    as process;
import 'package:semi_design_flutter/src/monaco/platform/product/common/product.dart'
    as prod;

final Map<String, dynamic> truth =
    (jsonDecode(File('tool/ts2dart/batch114_truth.json').readAsStringSync())
            as Map)
        .cast<String, dynamic>();

Map<String, dynamic> scenario(String name) =>
    (truth[name] as Map).cast<String, dynamic>();

void main() {
  setUp(() {
    prod.resetProductForTest();
    prod.vscodeContextConfigurationProvider = null;
    prod.vscodeProductJsonProvider = null;
    prod.vscodePackageJsonProvider = null;
    process.env.remove('VSCODE_DEV');
  });

  tearDown(() {
    process.env.remove('VSCODE_DEV');
  });

  group('batch114 product.ts', () {
    test('native sandbox product comes from preload configuration', () {
      final t = scenario('sandbox');
      final p = <String, Object?>{'nameShort': 'Sandboxed'};
      prod.vscodeContextConfigurationProvider = () => <String, Object?>{
            'product': p,
          };
      expect(prod.product, t['product']);
      expect(identical(prod.product, p), t['sameObject']);
      expect(t['error'], isNull);
    });

    test('native sandbox without configuration throws', () {
      final t = scenario('sandboxNoConfig');
      prod.vscodeContextConfigurationProvider = () => null;
      expect(() => prod.product, throwsStateError);
      try {
        // ignore: unused_local_variable
        final _ = prod.product;
        fail('expected throw');
      } on StateError catch (e) {
        expect(e.message, t['error']);
      }
    });

    test('_VSCODE env in DEV applies dev suffixes and package fallbacks', () {
      final t = scenario('vscodeDev');
      process.env['VSCODE_DEV'] = '1';
      prod.vscodeProductJsonProvider = () => <String, Object?>{
        'nameShort': 'VS',
        'nameLong': 'Visual Studio Code',
        'dataFolderName': '.vscode',
        'version': '',
        'serverDataFolderName': '.vs-server',
      };
      prod.vscodePackageJsonProvider = () => <String, Object?>{
        'version': '1.2.3',
        'copilotRuntimeVersion': 'runtime-1',
        'dependencies': <String, Object?>{
          '@microsoft/copilot-sdk': '^0.4.5',
          'other': '~9.9.9',
        },
      };
      expect(prod.product, t['product']);
      expect(t['error'], isNull);
    });

    test('_VSCODE built product keeps existing version and copilotVersions', () {
      final t = scenario('vscodeBuilt');
      prod.vscodeProductJsonProvider = () => <String, Object?>{
        'version': '2.0.0',
        'nameShort': 'Built',
        'nameLong': 'Built Code',
        'copilotVersions': <String, Object?>{'runtime': 'r', 'sdk': 's'},
      };
      prod.vscodePackageJsonProvider = () => <String, Object?>{
        'version': '9.9.9',
        'copilotRuntimeVersion': 'should-not-be-used',
        'dependencies': <String, Object?>{
          '@microsoft/copilot-sdk': '^0.4.5',
        },
      };
      expect(prod.product, t['product']);
      expect(t['error'], isNull);
    });

    test('web / unknown environment uses OSS dev defaults', () {
      final t = scenario('webFallback');
      expect(prod.product, t['product']);
      expect(t['error'], isNull);
    });
  });
}
