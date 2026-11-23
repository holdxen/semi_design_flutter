// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/elixir/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'elixir.dart' as elixir;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'elixir',
    extensions: <String>['.ex', '.exs'],
    aliases: <String>['Elixir', 'elixir', 'ex'],
    loader: () async => ILangImpl(elixir.conf, elixir.language),
  ));
}
