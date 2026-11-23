// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/systemverilog/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'systemverilog.dart' as systemverilog;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'systemverilog',
    extensions: <String>['.sv', '.svh'],
    aliases: <String>['SV', 'sv', 'SystemVerilog', 'systemverilog'],
    loader: () async => ILangImpl(systemverilog.conf, systemverilog.language),
  ));
  registerLanguage(ILang(
    id: 'verilog',
    extensions: <String>['.v', '.vh'],
    aliases: <String>['V', 'v', 'Verilog', 'verilog'],
    loader: () async => ILangImpl(systemverilog.conf, systemverilog.language),
  ));
}
