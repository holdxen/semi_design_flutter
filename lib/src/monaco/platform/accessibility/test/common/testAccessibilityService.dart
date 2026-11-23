// 1:1 port of vs/platform/accessibility/test/common/testAccessibilityService.ts
import '../../../../base/common/event.dart' show Event, eventNone;
import '../../common/accessibility.dart'
    show AccessibilitySupport, IAccessibilityServiceType;

/// 1:1: `export class TestAccessibilityService implements IAccessibilityService`
class TestAccessibilityService implements IAccessibilityServiceType {
  // ignore: unused_element
  Object? get _serviceBrand => null;

  @override
  Event<void> get onDidChangeScreenReaderOptimized => eventNone;

  @override
  Event<void> get onDidChangeReducedMotion => eventNone;

  @override
  Event<void> get onDidChangeReducedTransparency => eventNone;

  @override
  bool isScreenReaderOptimized() => false;

  @override
  bool isMotionReduced() => true;

  @override
  bool isTransparencyReduced() => false;

  @override
  Future<bool> alwaysUnderlineAccessKeys() => Future.value(false);

  @override
  void setAccessibilitySupport(int accessibilitySupport) {}

  @override
  int getAccessibilitySupport() => AccessibilitySupport.Unknown;

  @override
  void alert(String message) {}

  @override
  void status(String message) {}
}
