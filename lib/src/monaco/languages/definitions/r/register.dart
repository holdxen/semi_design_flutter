// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/r/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'r.dart' as r;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'r',
    extensions: <String>['.r', '.rhistory', '.rmd', '.rprofile', '.rt'],
    aliases: <String>['R', 'r'],
    loader: () async => ILangImpl(r.conf, r.language),
  ));
}
