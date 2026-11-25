// batch311: multiDiffEditor/model.ts truth replay.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/editor/browser/widget/multiDiffEditor/model.dart'
    show DiffItemSource, IDocumentDiffItem, IMultiDiffEditorModel;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch311_truth.json').readAsStringSync())
    as Map<String, dynamic>;

void main() {
  final Map<String, dynamic> truth = _truth();

  test('declaration surface matches truth', () {
    final List<dynamic> decls = truth['declarations'] as List<dynamic>;
    expect(decls.length, 3);
    expect(
      decls.map((d) => (d as Map<String, dynamic>)['name']).toList(),
      <String>['IMultiDiffEditorModel', 'DiffItemSource', 'IDocumentDiffItem'],
    );
    expect(truth['runtimeExports'], <String>['DiffItemSource']);
  });

  test('DiffItemSource retains uri and textModel', () {
    final URI uri = URI.parse('file:///a.ts');
    final Object textModel = Object();
    final DiffItemSource source = DiffItemSource(uri, textModel);
    expect(source.uri, same(uri));
    expect(source.textModel, same(textModel));
    expect((truth['runtime'] as Map<String, dynamic>)['uriRetained'], isTrue);
    expect(isA<IDocumentDiffItem>(), isNotNull);
    expect(isA<IMultiDiffEditorModel>(), isNotNull);
  });
}
