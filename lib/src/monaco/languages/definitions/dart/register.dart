// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/dart/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'dart.dart' as dart;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'dart',
    extensions: <String>['.dart'],
    aliases: <String>['Dart', 'dart'],
    mimetypes: <String>['text/x-dart-source', 'text/x-dart'],
    loader: () async => ILangImpl(dart.conf, dart.language),
  ));
}
