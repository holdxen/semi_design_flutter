// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/action/common/actionCommonCategories.ts
// Translated 1:1 from TypeScript.
// ---------------------------------------------------------------------------

import '../../../nls.dart' show ILocalizedString, localize2;

/// 1:1: `export const Categories = Object.freeze({ ... })`
///
/// Dart has no `Object.freeze`; a class with `static final` fields is the
/// closest immutable-namespace carrier (each field assigned once at load).
class Categories {
  Categories._();

  static final ILocalizedString View = localize2('view', 'View');
  static final ILocalizedString Help = localize2('help', 'Help');
  static final ILocalizedString Test = localize2('test', 'Test');
  static final ILocalizedString File = localize2('file', 'File');
  static final ILocalizedString Preferences = localize2('preferences', 'Preferences');
  static final ILocalizedString Developer = localize2(
    <String, Object?>{
      'key': 'developer',
      'comment': <String>['A developer on Code itself or someone diagnosing issues in Code']
    },
    'Developer',
  );
}
