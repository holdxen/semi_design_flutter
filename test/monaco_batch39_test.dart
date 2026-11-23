// batch39 regression: 73 strict-ready trivial facade files.
// Verifies (1) all `export { };` .d.ts files became empty libraries,
// (2) re-export facades preserved their specifiers 1:1 (real export when the
//     Dart target exists, commented specifier otherwise),
// (3) the two content-bearing files (metadata const, worker typedef) match.
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

const _root = 'lib/src/monaco';

String _read(String rel) => File('$_root/$rel').readAsStringSync();

void main() {
  group('batch39 facades', () {
    test('all 64 features/*/register.d.ts are empty libraries', () {
      final dir = Directory('$_root/features');
      final dFiles = dir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('/register.d.dart'))
          .toList();
      expect(dFiles.length, 64, reason: 'one register.d.dart per feature');
      for (final f in dFiles) {
        final txt = f.readAsStringSync();
        expect(txt, contains('export { };'),
            reason: '${f.path}: source specifier preserved in header');
        // No real Dart API declarations were added.
        expect(txt.contains('\nclass '), isFalse);
        expect(txt.contains('\ntypedef '), isFalse);
      }
    });

    test('editor.ts facade keeps editor.api specifier 1:1 as comment', () {
      final txt = _read('editor.dart');
      expect(txt,
          contains("// export 'editor/editor.api.dart';  // from 'monaco-editor-core/esm/vs/editor/editor.api'"));
    });

    test('languages/register.all.ts: real definitions export, comment features', () {
      final txt = _read('languages/register.all.dart');
      expect(txt, contains("export './definitions/register.all.dart';"));
      expect(txt,
          contains("// export './features/register.all.dart';  // from './features/register.all'"));
    });

    test('deprecated facades preserve relative specifiers', () {
      final cases = <String, String>{
        'deprecated/basic-languages/monaco.contribution.dart':
            "export '../../languages/definitions/register.all.dart';",
        'deprecated/language/css/css.worker.dart':
            "// export '../../../languages/features/css/css.worker.dart';  // from '../../../languages/features/css/css.worker'",
        'deprecated/language/html/html.worker.dart':
            "// export '../../../languages/features/html/html.worker.dart';  // from '../../../languages/features/html/html.worker'",
        'deprecated/language/json/json.worker.dart':
            "// export '../../../languages/features/json/json.worker.dart';  // from '../../../languages/features/json/json.worker'",
        'deprecated/language/typescript/ts.worker.dart':
            "// export '../../../languages/features/typescript/ts.worker.dart';  // from '../../../languages/features/typescript/ts.worker'",
      };
      cases.forEach((rel, needle) {
        expect(_read(rel), contains(needle), reason: rel);
      });
    });

    test('typescriptServicesMetadata: version const 5.9.3', () {
      expect(
          _read('languages/features/typescript/lib/typescriptServicesMetadata.dart'),
          contains("const String typescriptVersion = '5.9.3';"));
    });

    test('editor.worker.d.ts: start signature mirrored as typedef', () {
      final txt =
          _read('languages/features/typescript/lib/editor.worker.d.dart');
      expect(txt, contains('typedef WorkerContext = Object?;'));
      expect(txt,
          contains('typedef WorkerStartFunction = Object? Function('));
    });
  });
}
