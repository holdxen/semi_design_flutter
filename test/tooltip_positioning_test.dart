import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  const trigger = TooltipRect(left: 100, top: 100, width: 20, height: 20);
  const container = TooltipRect(left: 0, top: 0, width: 800, height: 600);

  TooltipPositionResult run({
    TooltipRect triggerRect = trigger,
    double popupWidth = 200,
    double popupHeight = 50,
    TooltipRect containerRect = container,
    double viewportWidth = 800,
    double viewportHeight = 600,
    SemiTooltipPosition position = SemiTooltipPosition.top,
    double spacing = 8,
    bool autoAdjustOverflow = false,
    bool showArrow = true,
    bool arrowPointAtCenter = true,
  }) => positionTooltip(
    triggerRect: triggerRect,
    popupWidth: popupWidth,
    popupHeight: popupHeight,
    containerRect: containerRect,
    viewportWidth: viewportWidth,
    viewportHeight: viewportHeight,
    position: position,
    spacing: spacing,
    autoAdjustOverflow: autoAdjustOverflow,
    showArrow: showArrow,
    arrowPointAtCenter: arrowPointAtCenter,
  );

  group('12 public placements', () {
    // trigger 100,100 20x20; popup 200x50; spacing 8; no arrow.
    final expected = <SemiTooltipPosition, (double, double, double, double)>{
      SemiTooltipPosition.top: (110, 92, -0.5, -1),
      SemiTooltipPosition.topLeft: (100, 92, 0, -1),
      SemiTooltipPosition.topRight: (120, 92, -1, -1),
      SemiTooltipPosition.bottom: (110, 128, -0.5, 0),
      SemiTooltipPosition.bottomLeft: (100, 128, 0, 0),
      SemiTooltipPosition.bottomRight: (120, 128, -1, 0),
      SemiTooltipPosition.left: (92, 110, -1, -0.5),
      SemiTooltipPosition.leftTop: (92, 100, -1, 0),
      SemiTooltipPosition.leftBottom: (92, 120, -1, -1),
      SemiTooltipPosition.right: (128, 110, 0, -0.5),
      SemiTooltipPosition.rightTop: (128, 100, 0, 0),
      SemiTooltipPosition.rightBottom: (128, 120, 0, -1),
    };

    for (final entry in expected.entries) {
      test('${entry.key} anchors and translate', () {
        final r = run(position: entry.key, showArrow: false);
        final (left, top, tx, ty) = entry.value;
        expect(r.left, left);
        expect(r.top, top);
        expect(r.translateX, tx);
        expect(r.translateY, ty);
        expect(r.placement, tooltipPlacementOf(entry.key));
      });
    }

    test('spacing shifts the popup along the main axis', () {
      expect(run(showArrow: false, spacing: 20).top, 80);
      expect(
        run(
          position: SemiTooltipPosition.right,
          showArrow: false,
          spacing: 20,
        ).left,
        140,
      );
    });

    test('arrowPointAtCenter pulls corner anchors to the trigger center', () {
      final topLeft = run(position: SemiTooltipPosition.topLeft);
      expect(topLeft.left, 110 - 18); // middleX - (6 + 24 / 2)
      final leftTop = run(position: SemiTooltipPosition.leftTop);
      expect(leftTop.top, 110 - 18);
    });

    test('transform origin follows the anchor for center placements', () {
      expect(run().transformOrigin.dx, 0.5);
      expect(run().transformOrigin.dy, 1.0);
      final corner = run(position: SemiTooltipPosition.topLeft);
      expect(corner.transformOrigin.dx, 10 / 200); // round(20 / 2) / width
      expect(corner.transformOrigin.dy, 1.0);
    });
  });

  group('small trigger correction', () {
    // showArrow && !arrowPointAtCenter && triggerHeight <= (12 + 2) * 2.
    const small = TooltipRect(left: 100, top: 100, width: 20, height: 10);

    test('shifts vertical corner placements toward the trigger', () {
      // offsetY = 10 / 2 - (2 + 12) = -9.
      final leftTop = run(
        triggerRect: small,
        position: SemiTooltipPosition.leftTop,
        arrowPointAtCenter: false,
      );
      expect(leftTop.top, 100 - 9);
      final leftBottom = run(
        triggerRect: small,
        position: SemiTooltipPosition.leftBottom,
        arrowPointAtCenter: false,
      );
      expect(leftBottom.top, 110 + 9);
    });

    test('leaves center and top/bottom placements alone', () {
      expect(
        run(
          triggerRect: small,
          position: SemiTooltipPosition.top,
          arrowPointAtCenter: false,
        ).top,
        92,
      );
    });

    test('does not apply when arrowPointAtCenter is true', () {
      // middleY of the small trigger is 105.
      expect(
        run(
          triggerRect: small,
          position: SemiTooltipPosition.leftTop,
          arrowPointAtCenter: true,
        ).top,
        105 - 18,
      );
    });

    test('does not apply above the trigger height threshold', () {
      const tall = TooltipRect(left: 100, top: 100, width: 20, height: 29);
      expect(
        run(
          triggerRect: tall,
          position: SemiTooltipPosition.leftBottom,
          arrowPointAtCenter: false,
        ).top,
        129,
      );
    });
  });

  group('placement adjustment helpers', () {
    test('reverse swaps top/bottom and left/right', () {
      expect(
        reversePlacement(TooltipPlacement.top, vertical: true),
        TooltipPlacement.bottom,
      );
      expect(
        reversePlacement(TooltipPlacement.topLeft, vertical: true),
        TooltipPlacement.bottomLeft,
      );
      expect(
        reversePlacement(TooltipPlacement.leftTop, vertical: true),
        TooltipPlacement.leftBottom,
      );
      expect(
        reversePlacement(TooltipPlacement.left, vertical: false),
        TooltipPlacement.right,
      );
      expect(
        reversePlacement(TooltipPlacement.leftTopOver, vertical: false),
        TooltipPlacement.rightTopOver,
      );
      expect(
        reversePlacement(TooltipPlacement.top, vertical: false),
        TooltipPlacement.top,
      );
    });

    test('expand grows a center placement into a corner', () {
      expect(
        expandPlacement(TooltipPlacement.top, TooltipExpandDirection.left),
        TooltipPlacement.topLeft,
      );
      expect(
        expandPlacement(TooltipPlacement.bottom, TooltipExpandDirection.right),
        TooltipPlacement.bottomRight,
      );
      expect(
        expandPlacement(TooltipPlacement.left, TooltipExpandDirection.top),
        TooltipPlacement.leftTop,
      );
      expect(
        expandPlacement(TooltipPlacement.topLeft, TooltipExpandDirection.left),
        TooltipPlacement.topLeft,
      );
    });

    test('reduce converges a corner placement to its center', () {
      expect(reducePlacement(TooltipPlacement.topLeft), TooltipPlacement.top);
      expect(
        reducePlacement(TooltipPlacement.bottomRight),
        TooltipPlacement.bottom,
      );
      expect(reducePlacement(TooltipPlacement.leftTop), TooltipPlacement.left);
      expect(
        reducePlacement(TooltipPlacement.rightBottom),
        TooltipPlacement.right,
      );
      expect(reducePlacement(TooltipPlacement.top), TooltipPlacement.top);
    });
  });

  group('adjustPositionIfNeeded', () {
    test('reverse: top flips to bottom near the screen top', () {
      const nearTop = TooltipRect(left: 400, top: 20, width: 20, height: 20);
      final r = adjustPositionIfNeeded(
        position: TooltipPlacement.top,
        triggerRect: nearTop,
        popupWidth: 200,
        popupHeight: 100,
        containerRect: container,
        viewportWidth: 800,
        viewportHeight: 600,
      );
      expect(r.placement, TooltipPlacement.bottom);
    });

    test('reverse: left flips to right near the screen left', () {
      const nearLeft = TooltipRect(left: 20, top: 300, width: 20, height: 20);
      final r = adjustPositionIfNeeded(
        position: TooltipPlacement.left,
        triggerRect: nearLeft,
        popupWidth: 200,
        popupHeight: 50,
        containerRect: container,
        viewportWidth: 800,
        viewportHeight: 600,
      );
      expect(r.placement, TooltipPlacement.right);
    });

    test('expand: top grows to topLeft when the left side is blocked', () {
      const narrow = TooltipRect(left: 0, top: 0, width: 300, height: 600);
      const nearLeft = TooltipRect(left: 10, top: 290, width: 20, height: 20);
      final r = adjustPositionIfNeeded(
        position: TooltipPlacement.top,
        triggerRect: nearLeft,
        popupWidth: 260,
        popupHeight: 50,
        containerRect: narrow,
        viewportWidth: 300,
        viewportHeight: 600,
      );
      expect(r.placement, TooltipPlacement.topLeft);
    });

    test('reduce: topLeft converges to top when half spaces suffice', () {
      const narrow = TooltipRect(left: 0, top: 0, width: 300, height: 600);
      const centered = TooltipRect(left: 140, top: 290, width: 20, height: 20);
      final r = adjustPositionIfNeeded(
        position: TooltipPlacement.topLeft,
        triggerRect: centered,
        popupWidth: 260,
        popupHeight: 50,
        containerRect: narrow,
        viewportWidth: 300,
        viewportHeight: 600,
      );
      expect(r.placement, TooltipPlacement.top);
    });

    test('pin: width overflow keeps top and pins the anchor', () {
      const small = TooltipRect(left: 0, top: 0, width: 200, height: 400);
      const nearLeft = TooltipRect(left: 10, top: 180, width: 20, height: 20);
      final r = positionTooltip(
        triggerRect: nearLeft,
        popupWidth: 240,
        popupHeight: 56,
        containerRect: small,
        viewportWidth: 200,
        viewportHeight: 400,
        position: SemiTooltipPosition.top,
        autoAdjustOverflow: true,
      );
      expect(r.placement, TooltipPlacement.top);
      // isTriggerNearLeft -> container.left + popupWidth / 2.
      expect(r.left, 120);
    });

    test('Over states reverse vertically when both sides block', () {
      const nearBottom = TooltipRect(
        left: 400,
        top: 580,
        width: 20,
        height: 20,
      );
      final r = adjustPositionIfNeeded(
        position: TooltipPlacement.leftTopOver,
        triggerRect: nearBottom,
        popupWidth: 100,
        popupHeight: 200,
        containerRect: container,
        viewportWidth: 800,
        viewportHeight: 600,
      );
      expect(r.placement, TooltipPlacement.leftBottomOver);
    });

    test('Over states reverse horizontally when both sides block', () {
      const nearRight = TooltipRect(left: 780, top: 300, width: 20, height: 20);
      final r = adjustPositionIfNeeded(
        position: TooltipPlacement.leftTopOver,
        triggerRect: nearRight,
        popupWidth: 100,
        popupHeight: 200,
        containerRect: container,
        viewportWidth: 800,
        viewportHeight: 600,
      );
      expect(r.placement, TooltipPlacement.rightTopOver);
    });
  });

  group('arrow offset', () {
    TooltipArrowOffset offset({
      double anchorLeft = 110,
      double anchorTop = 110,
      TooltipPlacement placement = TooltipPlacement.top,
      bool showArrow = true,
      bool arrowPointAtCenter = true,
      double popupWidth = 240,
      double popupHeight = 50,
    }) => computeArrowOffset(
      placement: placement,
      showArrow: showArrow,
      arrowPointAtCenter: arrowPointAtCenter,
      triggerRect: trigger,
      popupWidth: popupWidth,
      popupHeight: popupHeight,
      anchorLeft: anchorLeft,
      anchorTop: anchorTop,
      containerRect: container,
    );

    test('center placement at the trigger center falls back to 50%', () {
      expect(offset().fraction, isNull);
    });

    test('fractions within 1% of the center fall back to 50%', () {
      // raw = (110 - 107.61) / 240 + 0.5 ~ 0.50996, inside the 1% band.
      expect(offset(anchorLeft: 107.61).fraction, isNull);
      // raw = (110 - 107.5) / 240 + 0.5 ~ 0.5104, kept.
      expect(offset(anchorLeft: 107.5).fraction, closeTo(0.5104, 0.0001));
    });

    test('clamps to the arrow half span plus position offset', () {
      // min = (12 + 6) / 240 = 0.075, max = 0.925.
      expect(offset(anchorLeft: 250).fraction, 0.075);
      expect(offset(anchorLeft: -100).fraction, 0.925);
    });

    test('hugs the popup edge when arrowPointAtCenter is false', () {
      // Trigger near the container left -> offset 18 / 240 from the left.
      expect(
        offset(arrowPointAtCenter: false).fraction,
        closeTo(18 / 240, 0.0001),
      );
      const nearRight = TooltipRect(left: 710, top: 100, width: 20, height: 20);
      expect(
        computeArrowOffset(
          placement: TooltipPlacement.top,
          showArrow: true,
          arrowPointAtCenter: false,
          triggerRect: nearRight,
          popupWidth: 240,
          popupHeight: 50,
          anchorLeft: 710,
          anchorTop: 110,
          containerRect: container,
        ).fraction,
        closeTo((240 - 18) / 240, 0.0001),
      );
    });

    test('corner placements use the 5.76 / 5 constants', () {
      expect(offset(placement: TooltipPlacement.topLeft).cornerInset, 5.76);
      expect(offset(placement: TooltipPlacement.bottomRight).cornerInset, 5.76);
      expect(offset(placement: TooltipPlacement.leftTop).cornerInset, 5);
      expect(
        offset(placement: TooltipPlacement.rightBottomOver).cornerInset,
        5,
      );
    });

    test('vertical center placements clamp against the popup height', () {
      final r = computeArrowOffset(
        placement: TooltipPlacement.left,
        showArrow: true,
        arrowPointAtCenter: true,
        triggerRect: trigger,
        popupWidth: 50,
        popupHeight: 240,
        anchorLeft: 110,
        anchorTop: -100,
        containerRect: container,
      );
      expect(r.fraction, 0.925);
    });

    test('hidden arrow reports no offset', () {
      final r = offset(showArrow: false);
      expect(r.fraction, isNull);
      expect(r.cornerInset, isNull);
    });
  });
}
