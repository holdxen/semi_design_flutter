// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/pgsql/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'pgsql.dart' as pgsql;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'pgsql',
    extensions: <String>[],
    aliases: <String>['PostgreSQL', 'postgres', 'pg', 'postgre'],
    loader: () async => ILangImpl(pgsql.conf, pgsql.language),
  ));
}
