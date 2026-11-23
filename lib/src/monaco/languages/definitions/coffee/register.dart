// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/coffee/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'coffee.dart' as coffee;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'coffeescript',
    extensions: <String>['.coffee'],
    aliases: <String>['CoffeeScript', 'coffeescript', 'coffee'],
    mimetypes: <String>['text/x-coffeescript', 'text/coffeescript'],
    loader: () async => ILangImpl(coffee.conf, coffee.language),
  ));
}
