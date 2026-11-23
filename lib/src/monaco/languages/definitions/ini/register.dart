// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/ini/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'ini.dart' as ini;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'ini',
    extensions: <String>['.ini', '.properties', '.gitconfig'],
    filenames: <String>['config', '.gitattributes', '.gitconfig', '.editorconfig'],
    aliases: <String>['Ini', 'ini'],
    loader: () async => ILangImpl(ini.conf, ini.language),
  ));
}
