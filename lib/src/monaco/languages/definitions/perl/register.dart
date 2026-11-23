// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/perl/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'perl.dart' as perl;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'perl',
    extensions: <String>['.pl', '.pm'],
    aliases: <String>['Perl', 'pl'],
    loader: () async => ILangImpl(perl.conf, perl.language),
  ));
}
