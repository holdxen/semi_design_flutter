// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/hcl/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'hcl.dart' as hcl;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'hcl',
    extensions: <String>['.tf', '.tfvars', '.hcl'],
    aliases: <String>['Terraform', 'tf', 'HCL', 'hcl'],
    loader: () async => ILangImpl(hcl.conf, hcl.language),
  ));
}
