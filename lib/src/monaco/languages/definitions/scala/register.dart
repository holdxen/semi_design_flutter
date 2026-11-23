// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/scala/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'scala.dart' as scala;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'scala',
    extensions: <String>['.scala', '.sc', '.sbt'],
    aliases: <String>['Scala', 'scala', 'SBT', 'Sbt', 'sbt', 'Dotty', 'dotty'],
    mimetypes: <String>['text/x-scala-source', 'text/x-scala', 'text/x-sbt', 'text/x-dotty'],
    loader: () async => ILangImpl(scala.conf, scala.language),
  ));
}
