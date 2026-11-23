// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/m3/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'm3.dart' as m3;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'm3',
    extensions: <String>['.m3', '.i3', '.mg', '.ig'],
    aliases: <String>['Modula-3', 'Modula3', 'modula3', 'm3'],
    loader: () async => ILangImpl(m3.conf, m3.language),
  ));
}
