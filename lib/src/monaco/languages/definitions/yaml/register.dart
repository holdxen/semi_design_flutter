// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/yaml/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'yaml.dart' as yaml;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'yaml',
    extensions: <String>['.yaml', '.yml'],
    aliases: <String>['YAML', 'yaml', 'YML', 'yml'],
    mimetypes: <String>['application/x-yaml', 'text/x-yaml'],
    loader: () async => ILangImpl(yaml.conf, yaml.language),
  ));
}
