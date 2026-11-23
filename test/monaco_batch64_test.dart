// batch64: high-leverage declaration files — clipboardService / label /
// textResourceConfiguration. Truth from tool/ts2dart/batch64_truth.json
// (recursive TS transpile+vm loader + AST const-enum extraction).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/platform/clipboard/common/clipboardService.dart'
    show IClipboardService;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/instantiation.dart'
    show createDecorator;
import 'package:semi_design_flutter/src/monaco/platform/label/common/label.dart'
    show ILabelService, Verbosity;
import 'package:semi_design_flutter/src/monaco/editor/common/services/textResourceConfiguration.dart'
    show ITextResourceConfigurationService, ITextResourcePropertiesService;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch64_truth.json').readAsStringSync()) as Map<String, dynamic>;

void main() {
  final t = _truth();

  test('b64 clipboardService: decorator id + memoize match truth', () {
    final d = (t['decorators'] as List)
        .firstWhere((x) => x['exportedName'] == 'IClipboardService');
    expect(IClipboardService.toString(), d['id']);
    expect(identical(createDecorator(d['serviceId'] as String), IClipboardService), isTrue);
    expect(d['memoized'], isTrue);
    expect(d['typeOf'], 'function');
  });

  test('b64 label: decorator id + memoize match truth', () {
    final d = (t['decorators'] as List)
        .firstWhere((x) => x['exportedName'] == 'ILabelService');
    expect(ILabelService.toString(), d['id']);
    expect(identical(createDecorator(d['serviceId'] as String), ILabelService), isTrue);
    expect(d['memoized'], isTrue);
  });

  test('b64 textResourceConfiguration: both decorator ids + memoize match truth', () {
    final ds = (t['decorators'] as List)
        .where((x) => (x['exportedName'] as String).startsWith('ITextResource'))
        .toList();
    final svc = ds.firstWhere((x) => x['exportedName'] == 'ITextResourceConfigurationService');
    final props = ds.firstWhere((x) => x['exportedName'] == 'ITextResourcePropertiesService');
    expect(ITextResourceConfigurationService.toString(), svc['id']);
    expect(ITextResourcePropertiesService.toString(), props['id']);
    expect(identical(createDecorator(svc['serviceId'] as String),
        ITextResourceConfigurationService), isTrue);
    expect(identical(createDecorator(props['serviceId'] as String),
        ITextResourcePropertiesService), isTrue);
  });

  test('b64 decorator identity: distinct serviceIds are distinct objects', () {
    final distinct = t['distinct'] as Map<String, dynamic>;
    expect(identical(IClipboardService, ILabelService), isFalse);
    expect(identical(ITextResourceConfigurationService, ITextResourcePropertiesService), isFalse);
    expect(distinct['clipboardVsLabel'], isTrue);
    expect(distinct['trcVsProps'], isTrue);
  });

  test('b64 Verbosity const enum values match AST truth', () {
    final v = t['verbosity'] as Map<String, dynamic>;
    expect(Verbosity.SHORT, v['SHORT']);
    expect(Verbosity.MEDIUM, v['MEDIUM']);
    expect(Verbosity.LONG, v['LONG']);
    expect([Verbosity.SHORT, Verbosity.MEDIUM, Verbosity.LONG], [0, 1, 2]);
  });

  test('b64 export keys: all runtime-exported symbols present', () {
    final keys = t['exportKeys'] as Map<String, dynamic>;
    // The TS runtime only exports decorator values (+ Verbosity const enum is
    // inlined for label.ts, so it is AST-extracted, not a runtime key here).
    expect(keys['clipboard'], ['IClipboardService']);
    expect((keys['label'] as List).contains('ILabelService'), isTrue);
    expect(keys['textResourceConfiguration'], [
      'ITextResourceConfigurationService',
      'ITextResourcePropertiesService',
    ]);
    // Dart side: every value symbol exists and stringifies to its serviceId.
    expect(IClipboardService.toString(), 'clipboardService');
    expect(ILabelService.toString(), 'labelService');
    expect(ITextResourceConfigurationService.toString(), 'textResourceConfigurationService');
    expect(ITextResourcePropertiesService.toString(), 'textResourcePropertiesService');
  });
}
