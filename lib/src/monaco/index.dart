// 1:1 translation of monaco-editor/src/index.ts
// Source:
//   import * as lsp from '@vscode/monaco-lsp-client';
//   import { css, html, json, typescript } from './languages/register.all';
//   import './features/register.all';
//   import 'monaco-editor-core';
//   export * from './editor';
//   export { css, html, json, typescript, lsp };
//
// Pure facade. Re-exports whose Dart target exists become real `export`
// directives; side-effect imports are preserved as real imports so their
// registration runs; external/unported symbols keep an opaque carrier per the
// established convention (same as editor.dart / register.all.dart).

// 1:1: import * as lsp from '@vscode/monaco-lsp-client';
//      (ported at lib/src/monaco/lsp/index.dart)
import 'lsp/index.dart' show MonacoLspClient, MonacoLspClientOptions;

// 1:1: import './features/register.all'; (side-effect registration)
import 'features/register.all.dart';

// 1:1: export * from './editor';
export 'editor.dart';

// 1:1: re-export the LSP client facade symbols.
export 'lsp/index.dart' show MonacoLspClient, MonacoLspClientOptions;

/// 1:1 namespace carrier for the `@vscode/monaco-lsp-client` import.
/// Points at the ported LSP client facade symbols.
final Map<String, Object?> lsp = <String, Object?>{
  'MonacoLspClient': MonacoLspClient,
};

// 1:1: `import { css, html, json, typescript } from './languages/register.all';`
//      `export { css, html, json, typescript };`
// In the TS source these are Monaco language contribution objects. Their
// concrete definitions live in unported `languages/*/register` factories; per
// the facade convention they are opaque carriers here.
Object? css;
Object? html;
Object? json;
Object? typescript;
