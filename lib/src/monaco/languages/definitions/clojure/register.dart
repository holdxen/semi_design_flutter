// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/clojure/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'clojure.dart' as clojure;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'clojure',
    extensions: <String>['.clj', '.cljs', '.cljc', '.edn'],
    aliases: <String>['clojure', 'Clojure'],
    loader: () async => ILangImpl(clojure.conf, clojure.language),
  ));
}
