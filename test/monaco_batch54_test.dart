import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/languages/features/typescript/lib/typescriptServices.d.dart' as ts;
// ignore: unused_import
import 'package:semi_design_flutter/src/monaco/deprecated/editor/editor.main.dart' as barrel;

/// batch54: 1:1 port of the last two STRICT-READY sources:
///   * languages/features/typescript/lib/typescriptServices.d.ts (11441 lines)
///   * deprecated/editor/editor.main.ts (2-line barrel)
///
/// typescriptServices.d.ts is a pure ambient declaration file (TS 5.9.3);
/// symbol truth (73 enums / 841 interfaces / 270 types / 531 functions /
/// 10 classes / 19 import aliases / 22 consts) is verified against the real
/// TypeScript AST by tool/ts2dart/verify_ts_services.py. These tests import
/// the generated library and assert representative runtime constants match
/// the TS source exactly, plus that the barrel re-export compiles.
void main() {
  group('batch54 / typescriptServices 1:1 declarations', () {
    test('numeric enums keep exact TS values (incl. negative + boundary)', () {
      expect(ts.SyntaxKind.Unknown, 0);
      expect(ts.SyntaxKind.EndOfFileToken, 1);
      expect(ts.SyntaxKind.MultiLineCommentTrivia, 3);
      expect(ts.ModuleKind.None, 0);
      expect(ts.ModuleKind.ES2015, 5);
      expect(ts.ScriptKind.TS, 3);
      expect(ts.ScriptKind.External, 5);
      expect(ts.IndentStyle.Smart, 2);
      expect(ts.DiagnosticCategory.Error, 1);
      expect(ts.DiagnosticCategory.Message, 3);
      // Negative values from PrefixUnaryExpression enum initializers.
      expect(ts.SymbolFlags.All, -1);
    });

    test('string enums keep exact TS values', () {
      expect(ts.ServerProtocolIndentStyle.None, 'None');
      expect(ts.ServerProtocolIndentStyle.Smart, 'Smart');
      expect(ts.ServerProtocolModuleKind.CommonJS, 'commonjs');
      expect(ts.ServerProtocolModuleKind.ES6, 'es6');
      // Dart reserved word -> `_` suffix, value unchanged.
      expect(ts.ClassificationTypeNames.operator_, 'operator');
    });

    test('literal const values match TS source (version + event names)', () {
      expect(ts.versionMajorMinor, '5.9');
      expect(ts.servicesVersion, '0.8');
      expect(ts.ServerProjectsUpdatedInBackgroundEvent$v, 'projectsUpdatedInBackground');
      expect(ts.ServerProjectLoadingStartEvent$v, 'projectLoadingStart');
      // `version`, `sys`, `factory` are type-only `external` consts whose real
      // values live in the TS bundle (reading them at runtime has no impl).
      // Their presence is validated by the compile-time import above.
    });

    test('typedef carriers and abstract types are referencable', () {
      ts.Path? path;
      ts.MapLike<String>? mapLike;
      ts.IScriptSnapshot? snapshot;
      ts.LanguageService? service;
      ts.CompilerOptions? options;
      ts.ServerProtocolCommandTypes? command;
      expect([path, mapLike, snapshot, service, options, command], everyElement(isNull));
    });

    test('external function declarations are referencable', () {
      // Referencing the tear-off compiles and resolves to the ambient decl;
      // it is never invoked (the real implementation lives in the TS bundle).
      final create = ts.createLanguageService;
      final token = ts.tokenToString;
      expect(create, isNotNull);
      expect(token, isNotNull);
    });

    test('deprecated/editor/editor.main.dart barrel re-exports facade', () {
      // Importing the barrel (and touching a re-exported symbol) must compile:
      // `export * from '../../index'` -> export '../../index.dart'.
      expect(barrel.MonacoLspClient, isNotNull);
    });
  });
}
