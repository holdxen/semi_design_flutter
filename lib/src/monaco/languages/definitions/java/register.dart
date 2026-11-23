// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/java/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'java.dart' as java;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'java',
    extensions: <String>['.java', '.jav'],
    aliases: <String>['Java', 'java'],
    mimetypes: <String>['text/x-java-source', 'text/x-java'],
    loader: () async => ILangImpl(java.conf, java.language),
  ));
}
