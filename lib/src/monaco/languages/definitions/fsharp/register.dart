// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/fsharp/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'fsharp.dart' as fsharp;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'fsharp',
    extensions: <String>['.fs', '.fsi', '.ml', '.mli', '.fsx', '.fsscript'],
    aliases: <String>['F#', 'FSharp', 'fsharp'],
    loader: () async => ILangImpl(fsharp.conf, fsharp.language),
  ));
}
