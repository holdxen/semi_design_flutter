// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/flow9/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'flow9.dart' as flow9;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'flow9',
    extensions: <String>['.flow'],
    aliases: <String>['Flow9', 'Flow', 'flow9', 'flow'],
    loader: () async => ILangImpl(flow9.conf, flow9.language),
  ));
}
