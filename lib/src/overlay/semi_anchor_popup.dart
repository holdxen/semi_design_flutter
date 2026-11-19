import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Positioning helpers for cursor/menu anchored popups (`SemiContextMenu`).
///
/// The chrome-tab popup clamping (`_FixedPopup`/`_AnchoredPopup` in
/// semi_chrome_tab.dart) is the visual precedent; these helpers are the pure
/// geometry so the menu engine (and future anchored popups) share one
/// flip-then-clamp rule. All offsets are global (screen) coordinates.

/// Top-left for a popup of [popupSize] whose preferred corner sits on [point]
/// (the pointer position). Radix places the context menu with its top-left
/// ≈ pointer + 2px (`side: right, sideOffset: 2`); when the preferred corner
/// overflows the [viewport] the popup flips to the opposite side of the point
/// and finally clamps inside [margin].
Offset semiPositionAtPoint({
  required Size popupSize,
  required Offset point,
  required Size viewport,
  double margin = 8,
  double gap = 2,
}) {
  var left = point.dx + gap;
  if (left + popupSize.width > viewport.width - margin) {
    left = point.dx - popupSize.width - gap;
  }
  var top = point.dy + gap;
  if (top + popupSize.height > viewport.height - margin) {
    top = point.dy - popupSize.height - gap;
  }
  return Offset(
    left.clamp(margin, math.max(margin, viewport.width - popupSize.width - margin)),
    top.clamp(margin, math.max(margin, viewport.height - popupSize.height - margin)),
  );
}

/// Top-left for a submenu popup of [popupSize] anchored to [anchorRect] (a
/// menu row): the popup hugs the row's trailing edge (right in LTR, left in
/// RTL), top-aligned like Radix `SubContent align: start`; it flips to the
/// leading edge when the trailing side is blocked and clamps vertically.
Offset semiPositionAtRect({
  required Size popupSize,
  required Rect anchorRect,
  required Size viewport,
  bool rtl = false,
  double margin = 8,
  double gap = 2,
}) {
  final double left;
  final double preferred = rtl
      ? anchorRect.left - popupSize.width - gap
      : anchorRect.right + gap;
  final double opposite = rtl
      ? anchorRect.right + gap
      : anchorRect.left - popupSize.width - gap;
  final fitsPreferred =
      preferred >= margin &&
      preferred + popupSize.width <= viewport.width - margin;
  if (fitsPreferred || opposite < margin) {
    left = preferred;
  } else {
    left = opposite;
  }
  final top = anchorRect.top
      .clamp(margin, math.max(margin, viewport.height - popupSize.height - margin))
      .toDouble();
  return Offset(
    left.clamp(margin, math.max(margin, viewport.width - popupSize.width - margin)),
    top,
  );
}

/// Full-screen outside-press barrier for menu overlays. Pointer-downs inside
/// any rect reported by [exemptRects] pass through (they belong to the open
/// menu tree or its trigger); everything else calls [onDismiss].
///
/// [exemptRects] is queried per event (not snapshotted) so levels that mount
/// later — submenus — are covered automatically.
class SemiMenuBarrier extends StatelessWidget {
  const SemiMenuBarrier({
    super.key,
    required this.onDismiss,
    required this.exemptRects,
  });

  /// Called for every outside pointer-down.
  final ValueChanged<PointerDownEvent> onDismiss;

  /// Global rects that count as "inside" (every open menu level, the trigger).
  final List<Rect> Function() exemptRects;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          final hit = event.position;
          for (final rect in exemptRects()) {
            if (rect.contains(hit)) return;
          }
          onDismiss(event);
        },
      ),
    );
  }
}
