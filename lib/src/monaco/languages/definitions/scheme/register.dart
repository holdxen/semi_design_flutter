// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/scheme/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'scheme.dart' as scheme;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'scheme',
    extensions: <String>['.scm', '.ss', '.sch', '.rkt'],
    aliases: <String>['scheme', 'Scheme'],
    loader: () async => ILangImpl(scheme.conf, scheme.language),
  ));
}
