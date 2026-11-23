// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/rust/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'rust.dart' as rust;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'rust',
    extensions: <String>['.rs', '.rlib'],
    aliases: <String>['Rust', 'rust'],
    loader: () async => ILangImpl(rust.conf, rust.language),
  ));
}
