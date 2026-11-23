// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/scss/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'scss.dart' as scss;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'scss',
    extensions: <String>['.scss'],
    aliases: <String>['Sass', 'sass', 'scss'],
    mimetypes: <String>['text/x-scss', 'text/scss'],
    loader: () async => ILangImpl(scss.conf, scss.language),
  ));
}
