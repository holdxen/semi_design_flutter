// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/qsharp/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'qsharp.dart' as qsharp;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'qsharp',
    extensions: <String>['.qs'],
    aliases: <String>['Q#', 'qsharp'],
    loader: () async => ILangImpl(qsharp.conf, qsharp.language),
  ));
}
