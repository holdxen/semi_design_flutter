// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/javascript/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'javascript.dart' as javascript;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'javascript',
    extensions: <String>['.js', '.es6', '.jsx', '.mjs', '.cjs'],
    filenames: <String>['jakefile'],
    firstLine: '^#!.*\\bnode',
    aliases: <String>['JavaScript', 'javascript', 'js'],
    mimetypes: <String>['text/javascript'],
    loader: () async => ILangImpl(javascript.conf, javascript.language),
  ));
}
