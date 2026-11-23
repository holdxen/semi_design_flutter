// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/protobuf/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'protobuf.dart' as protobuf;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'proto',
    extensions: <String>['.proto'],
    aliases: <String>['protobuf', 'Protocol Buffers'],
    loader: () async => ILangImpl(protobuf.conf, protobuf.language),
  ));
}
