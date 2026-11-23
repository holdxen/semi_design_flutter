// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/dockerfile/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'dockerfile.dart' as dockerfile;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'dockerfile',
    extensions: <String>['.dockerfile'],
    filenames: <String>['Dockerfile'],
    aliases: <String>['Dockerfile'],
    loader: () async => ILangImpl(dockerfile.conf, dockerfile.language),
  ));
}
