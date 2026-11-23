// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/notification/common/notificationLegacy.ts
// Translated 1:1 from TypeScript. `Symbol('legacyExtensionLinkParsing')` ->
// a unique object instance (Dart `Object()` has reference identity, matching
// the nominal, unforgeable identity of a JS Symbol). The branded type alias
// -> the concrete marker class type.
// ---------------------------------------------------------------------------

/// 1:1: the value `Symbol('legacyExtensionLinkParsing')`.
/// A JS Symbol is compared by identity, never by shape — a plain [Object]
/// instance reproduces that identity semantics in Dart.
final Object legacyExtensionLinkParsing = Object();

/// 1:1: `export type LegacyExtensionLinkParsing = typeof legacyExtensionLinkParsing`
/// The nominal type of the marker value.
typedef LegacyExtensionLinkParsing = Object;

/// Compatibility capability restricted to the extension notification and progress bridges.
/// 1:1: `export function isLegacyExtensionLinkParsing(value): value is LegacyExtensionLinkParsing`
bool isLegacyExtensionLinkParsing(Object? value) {
  return identical(value, legacyExtensionLinkParsing);
}
