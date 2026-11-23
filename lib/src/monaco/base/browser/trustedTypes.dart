// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/browser/trustedTypes.ts
// Translated 1:1. `globalThis.trustedTypes?.createPolicy` is surfaced through
// an injectable provider; the two `try/catch` paths call `onUnexpectedError`.
// ---------------------------------------------------------------------------

import '../common/errors.dart' show onUnexpectedError;
import 'browser.dart' show getMonacoEnvironment;

/// 1:1: injectable `globalThis.trustedTypes?.createPolicy(policyName, options)`.
/// Returns `null` when the API is absent (mirrors `undefined` in the source).
Object? Function(String policyName, Object? policyOptions)?
    createTrustedTypesPolicyProvider;

/// 1:1: `export function createTrustedTypesPolicy(policyName, policyOptions?)`
Object? createTrustedTypesPolicy(String policyName, [Object? policyOptions]) {
  final dynamic monacoEnvironment = getMonacoEnvironment();

  if (monacoEnvironment != null &&
      monacoEnvironment.createTrustedTypesPolicy != null) {
    try {
      // 1:1: `monacoEnvironment.createTrustedTypesPolicy(policyName, policyOptions)`
      return (monacoEnvironment.createTrustedTypesPolicy as Function)(
          policyName, policyOptions);
    } catch (err) {
      onUnexpectedError(err);
      return null;
    }
  }
  try {
    // 1:1: `(globalThis as any).trustedTypes?.createPolicy(policyName, policyOptions)`
    final Object? Function(String, Object?)? provider =
        createTrustedTypesPolicyProvider;
    if (provider == null) {
      return null;
    }
    return provider(policyName, policyOptions);
  } catch (err) {
    onUnexpectedError(err);
    return null;
  }
}
