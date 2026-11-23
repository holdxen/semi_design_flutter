// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/typescript/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'typescript.dart' as typescript;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'typescript',
    extensions: <String>['.ts', '.tsx', '.cts', '.mts'],
    aliases: <String>['TypeScript', 'ts', 'typescript'],
    mimetypes: <String>['text/typescript'],
    loader: () async => ILangImpl(typescript.conf, typescript.language),
  ));
}
