// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/mips/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'mips.dart' as mips;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'mips',
    extensions: <String>['.s'],
    aliases: <String>['MIPS', 'MIPS-V'],
    mimetypes: <String>['text/x-mips', 'text/mips', 'text/plaintext'],
    loader: () async => ILangImpl(mips.conf, mips.language),
  ));
}
