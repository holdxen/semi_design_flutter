// 1:1 port of vs/platform/actionWidget/browser/actionWidgetMotion.ts
import '../../../base/browser/dom.dart'
    show DomAnimation, DomElement, DomWindowCarrier, getWindow, windowCarrier;

const String ACTION_WIDGET_ANIMATED_CLASS = 'action-widget-animated';
const String ACTION_WIDGET_DROPDOWN_MOTION_CLASS = 'action-widget-dropdown';
const String ACTION_WIDGET_DROPDOWN_MOTION_CLOSING_CLASS =
    'action-widget-dropdown-closing';

/// Completes the scale entrance before measuring or positioning dependent UI.
void finishActionWidgetOpeningAnimation(DomElement widget) {
  final DomWindowCarrier targetWindow = windowCarrier(getWindow(widget));
  for (final DomAnimation animation in widget.getAnimations()) {
    if (animation.runtimeType == targetWindow.cssAnimation &&
        animation.animationName == 'action-widget-scale-open') {
      animation.finish();
    }
  }
}
