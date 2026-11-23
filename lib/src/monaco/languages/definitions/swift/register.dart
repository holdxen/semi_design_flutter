// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/swift/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'swift.dart' as swift;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'swift',
    extensions: <String>['.swift'],
    aliases: <String>['Swift', 'swift'],
    mimetypes: <String>['text/swift'],
    loader: () async => ILangImpl(swift.conf, swift.language),
  ));
}
