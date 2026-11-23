// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/python/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'python.dart' as python;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'python',
    extensions: <String>['.py', '.rpy', '.pyw', '.cpy', '.gyp', '.gypi'],
    firstLine: '^#!/.*\\bpython[0-9.-]*\\b',
    aliases: <String>['Python', 'py'],
    loader: () async => ILangImpl(python.conf, python.language),
  ));
}
