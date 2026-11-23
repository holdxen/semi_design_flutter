// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/powershell/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'powershell.dart' as powershell;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'powershell',
    extensions: <String>['.ps1', '.psm1', '.psd1'],
    aliases: <String>['PowerShell', 'powershell', 'ps', 'ps1'],
    loader: () async => ILangImpl(powershell.conf, powershell.language),
  ));
}
