// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/misc/textModelDefaults.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
// ---------------------------------------------------------------------------

/// Source: `export const EDITOR_MODEL_DEFAULTS = { ... }`.
///
/// The TS object literal is carried by a `const` map so it can be shared the
/// same way the source constant is shared.
const Map<String, Object> EDITOR_MODEL_DEFAULTS = <String, Object>{
  'tabSize': 4,
  'indentSize': 4,
  'insertSpaces': true,
  'detectIndentation': true,
  'trimAutoWhitespace': true,
  'largeFileOptimizations': true,
  'bracketPairColorizationOptions': <String, Object>{
    'enabled': true,
    'independentColorPoolPerBracketType': false,
  },
};
