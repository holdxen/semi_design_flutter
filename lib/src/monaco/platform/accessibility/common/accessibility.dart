// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/accessibility/common/accessibility.ts
// Translated 1:1 from TypeScript. TS `const enum AccessibilitySupport` ->
// class of int consts; the `IAccessibilityService` value/type namespace clash
// is resolved by keeping the const name and renaming the interface to
// `IAccessibilityServiceType` (same convention as IContextKeyService).
// ---------------------------------------------------------------------------

import '../../../base/common/event.dart' show Event;
import '../../contextkey/common/contextkey.dart' show RawContextKey;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;

/// 1:1: `export const IAccessibilityService = createDecorator<IAccessibilityService>('accessibilityService')`
final ServiceIdentifier<IAccessibilityServiceType> IAccessibilityService =
    createDecorator<IAccessibilityServiceType>('accessibilityService');

/// 1:1: `export interface IAccessibilityService`
abstract class IAccessibilityServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  Event<void> get onDidChangeScreenReaderOptimized;
  Event<void> get onDidChangeReducedMotion;
  Event<void> get onDidChangeReducedTransparency;

  Future<bool> alwaysUnderlineAccessKeys();
  bool isScreenReaderOptimized();
  bool isMotionReduced();
  bool isTransparencyReduced();
  int getAccessibilitySupport();
  void setAccessibilitySupport(int accessibilitySupport);
  void alert(String message);
  void status(String message);
}

/// 1:1: `export const enum AccessibilitySupport`
class AccessibilitySupport {
  /// This should be the browser case where it is not known if a screen reader is attached or no.
  static const int Unknown = 0;
  static const int Disabled = 1;
  static const int Enabled = 2;
  const AccessibilitySupport._();
}

/// 1:1: `export const CONTEXT_ACCESSIBILITY_MODE_ENABLED = new RawContextKey<boolean>('accessibilityModeEnabled', false)`
final RawContextKey<bool> CONTEXT_ACCESSIBILITY_MODE_ENABLED =
    RawContextKey<bool>('accessibilityModeEnabled', false);

/// 1:1: `export interface IAccessibilityInformation`
abstract class IAccessibilityInformation {
  String get label;
  String? get role;
}

/// 1:1: `export function isAccessibilityInformation(obj: unknown): obj is IAccessibilityInformation`
bool isAccessibilityInformation(Object? obj) {
  // TS: `if (!obj || typeof obj !== 'object')`. JS `!obj` covers null/undefined;
  // the remaining non-object primitives fail the `typeof` check. A JS object
  // (plain or array) is modelled by a Dart Map carrier.
  if (obj == null || obj is! Map) return false;
  final candidate = obj;
  final label = candidate['label'];
  final role = candidate['role'];
  // TS: `typeof candidate.label === 'string' && (typeof candidate.role === 'undefined' || typeof candidate.role === 'string')`
  // Dart `null` carries both JS `undefined` and `null`.
  return label is String && (role == null || role is String);
}

/// 1:1: `export const ACCESSIBLE_VIEW_SHOWN_STORAGE_PREFIX = 'ACCESSIBLE_VIEW_SHOWN_'`
const String ACCESSIBLE_VIEW_SHOWN_STORAGE_PREFIX = 'ACCESSIBLE_VIEW_SHOWN_';
