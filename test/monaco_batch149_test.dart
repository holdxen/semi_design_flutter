// batch149 truth tests: severityIcon.ts ported 1:1.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/ui/severityIcon/severityIcon.dart' as si;
import 'package:semi_design_flutter/src/monaco/base/common/severity.dart' show Severity;

Map<String, dynamic> _loadTruth() {
  final f = File('tool/ts2dart/batch149_truth.json');
  return jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  final t = _loadTruth();
  final classes = t['classes'] as Map<String, dynamic>;

  test('Severity enum values match truth', () {
    final sv = t['severityValues'] as Map<String, dynamic>;
    expect(Severity.Ignore, sv['Ignore']);
    expect(Severity.Info, sv['Info']);
    expect(Severity.Warning, sv['Warning']);
    expect(Severity.Error, sv['Error']);
  });

  test('SeverityIcon.className matches truth for all severities', () {
    expect(si.SeverityIcon.className(Severity.Ignore), classes['ignore']);
    expect(si.SeverityIcon.className(Severity.Info), classes['info']);
    expect(si.SeverityIcon.className(Severity.Warning), classes['warning']);
    expect(si.SeverityIcon.className(Severity.Error), classes['error']);
    expect(si.SeverityIcon.className(999), classes['invalid']);
  });
}
