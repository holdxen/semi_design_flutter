// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/kotlin/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'kotlin.dart' as kotlin;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'kotlin',
    extensions: <String>['.kt', '.kts'],
    aliases: <String>['Kotlin', 'kotlin'],
    mimetypes: <String>['text/x-kotlin-source', 'text/x-kotlin'],
    loader: () async => ILangImpl(kotlin.conf, kotlin.language),
  ));
}
