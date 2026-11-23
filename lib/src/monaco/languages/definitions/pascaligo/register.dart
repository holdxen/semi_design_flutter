// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/pascaligo/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'pascaligo.dart' as pascaligo;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'pascaligo',
    extensions: <String>['.ligo'],
    aliases: <String>['Pascaligo', 'ligo'],
    loader: () async => ILangImpl(pascaligo.conf, pascaligo.language),
  ));
}
