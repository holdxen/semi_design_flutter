// batch154 truth tests: platform/progress/common/progress.dart.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/platform/progress/common/progress.dart' as p;

Map<String, dynamic> _loadTruth() {
  final f = File('tool/ts2dart/batch154_truth.json');
  return jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  final t = _loadTruth();

  test('ProgressLocation enum matches truth', () {
    final m = (t['enums'] as Map<String, dynamic>)['ProgressLocation'] as Map<String, dynamic>;
    expect(p.ProgressLocation.Explorer, m['Explorer']);
    expect(p.ProgressLocation.Scm, m['Scm']);
    expect(p.ProgressLocation.Extensions, m['Extensions']);
    expect(p.ProgressLocation.Window, m['Window']);
    expect(p.ProgressLocation.Notification, m['Notification']);
    expect(p.ProgressLocation.Dialog, m['Dialog']);
  });

  test('service identifiers match truth', () {
    final ids = t['serviceIds'] as Map<String, dynamic>;
    expect(p.IProgressService.serviceId, ids['IProgressService']);
    expect(p.IEditorProgressService.serviceId, ids['IEditorProgressService']);
  });

  test('emptyProgressRunner behavior matches truth', () {
    final e = t['emptyProgressRunner'] as Map<String, dynamic>;
    final r = p.emptyProgressRunner;
    r.total(5);
    r.worked(5);
    r.done();
    expect((e['methods'] as List).length, 3);
    expect(e['totalVoid'], isTrue);
    expect(e['workedVoid'], isTrue);
    expect(e['doneVoid'], isTrue);
  });

  test('Progress value and callback match truth', () {
    final truth = t['progress'] as Map<String, dynamic>;
    final seen = <Object?>[];
    final pr = p.Progress<Object>((d) => seen.add(d));
    expect(pr.value, isNull);
    expect(truth['initialValue'], 'undef');
    pr.report('a');
    pr.report('b');
    expect(seen, truth['reports']);
    expect(pr.value, truth['finalValue']);
    expect(truth['noneHasReport'], isTrue);
    expect(truth['noneReportVoid'], isTrue);
    p.Progress.None.report('x'); // callable
  });
}
