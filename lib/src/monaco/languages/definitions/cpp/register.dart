// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/cpp/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'cpp.dart' as cpp;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'c',
    extensions: <String>['.c', '.h'],
    aliases: <String>['C', 'c'],
    loader: () async => ILangImpl(cpp.conf, cpp.language),
  ));
  registerLanguage(ILang(
    id: 'cpp',
    extensions: <String>['.cpp', '.cc', '.cxx', '.hpp', '.hh', '.hxx'],
    aliases: <String>['C++', 'Cpp', 'cpp'],
    loader: () async => ILangImpl(cpp.conf, cpp.language),
  ));
}
