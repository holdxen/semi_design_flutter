// Behavior matrix for SemiPopover plus coverage for the 26 Sass
// declarations (26 = 20 FIELDS + 4 MOTION + 2 INTERNAL; 37 HARDCODES anchors,
// 63 = 20 + 4 + 2 + 37 provenance entries). docs/semi_popover.md carries the
// full mapping.

import 'dart:io';
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

const _kTrigger = Key('trigger');

/// Opaque box so taps and hovers always hit the trigger subtree.
Widget _trigger() => Listener(
  behavior: HitTestBehavior.translucent,
  onPointerDown: (_) {},
  child: const SizedBox(key: _kTrigger, width: 40, height: 20),
);

Widget _app(
  Widget body, {
  SemiPopoverThemeData popoverTheme = const SemiPopoverThemeData(),
  TextDirection textDirection = TextDirection.ltr,
}) => SemiTheme(
  data: const SemiThemeData.light(),
  child: SemiPopoverTheme(
    data: popoverTheme,
    child: Directionality(
      textDirection: textDirection,
      child: Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (context) => Align(alignment: Alignment.center, child: body),
          ),
        ],
      ),
    ),
  ),
);

/// Frame 1 rebuilds, frame 2 inserts the overlay entry, frame 3 measures it,
/// frame 4 computes the position and frame 5 renders it in place. Pump
/// generously: both the uncontrolled shell path and the hover timer deferral
/// land within these frames.
Future<void> _settleOpen(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump();
  }
}

Future<void> _hover(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  await gesture.moveTo(tester.getCenter(find.byKey(_kTrigger)));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await _settleOpen(tester);
}

void main() {
  group('theme fields (26 = 20 FIELDS + 4 MOTION + 2 INTERNAL)', () {
    test('resolve falls back to the Sass defaults', () {
      final theme = SemiThemeData.light();
      final r = const SemiPopoverThemeData().resolve(theme);
      expect(r.colorTooltipArrowIconDefault, 'unset');
      expect(r.colorPopoverBgDefault, theme.colors.colorBg3);
      expect(r.colorPopoverBorderDefault, theme.colors.colorBorder);
      expect(r.colorPopoverArrowBorder, theme.colors.colorBorder);
      expect(r.colorPopoverArrowBg, theme.colors.colorBg3);
      expect(r.widthPopoverArrow, 24);
      expect(r.heightPopoverArrow, 8);
      expect(r.heightPopoverArrowVertical, 24);
      expect(r.widthPopoverArrowVertical, 8);
      // Alias shadowing: `$height-tooltip_arrow: $height-popover_arrow` 等。
      expect(r.heightTooltipArrow, 8);
      expect(r.widthTooltipArrow, 24);
      expect(r.widthTooltipArrowVertical, 8);
      expect(r.heightTooltipArrowVertical, 24);
      expect(r.widthPopoverTitleBorder, 1);
      expect(r.spacingPopoverTitlePadding, 8);
      expect(r.spacingPopoverWithArrowPadding, 12);
      expect(r.spacingPopoverArrowAdjustedOffsetY, 6);
      expect(r.spacingTooltipArrowAdjustedOffsetY, 6);
      // round($horizontal-rate * $width-tooltip_arrow) — 保留未取整值 5.76。
      expect(r.spacingTooltipArrowAdjustedOffsetX, 5.76);
      expect(r.radiusPopover, theme.radius.borderRadiusMedium.value);
      expect(r.animationDurationPopoverIn, const Duration(milliseconds: 100));
      expect(r.animationDurationPopoverOut, const Duration(milliseconds: 100));
      expect(
        semiCurveEquals(
          r.animationFunctionPopoverIn,
          const Cubic(0.215, 0.61, 0.355, 1),
        ),
        isTrue,
      );
      expect(
        semiCurveEquals(
          r.animationFunctionPopoverOut,
          const Cubic(0.215, 0.61, 0.355, 1),
        ),
        isTrue,
      );
    });

    test('alias declarations chain through the popover geometry', () {
      final r = const SemiPopoverThemeData(
        heightPopoverArrow: 10,
        widthPopoverArrow: 30,
        widthPopoverArrowVertical: 9,
        heightPopoverArrowVertical: 26,
        spacingPopoverArrowAdjustedOffsetY: 7,
      ).resolve(SemiThemeData.light());
      expect(r.heightTooltipArrow, 10);
      expect(r.widthTooltipArrow, 30);
      expect(r.widthTooltipArrowVertical, 9);
      expect(r.heightTooltipArrowVertical, 26);
      expect(r.spacingTooltipArrowAdjustedOffsetY, 7);
      // Direct alias override wins over the chained popover geometry.
      final direct = const SemiPopoverThemeData(
        heightTooltipArrow: 3,
        heightPopoverArrow: 10,
      ).resolve(SemiThemeData.light());
      expect(direct.heightTooltipArrow, 3);
    });

    test('copyWith/merge/equality keep every field', () {
      const full = SemiPopoverThemeData(
        colorTooltipArrowIconDefault: 'none',
        colorPopoverBgDefault: Color(0xff000001),
        colorPopoverBorderDefault: Color(0xff000002),
        colorPopoverArrowBorder: Color(0xff000003),
        colorPopoverArrowBg: Color(0xff000004),
        widthPopoverArrow: 1.5,
        heightPopoverArrow: 2.5,
        heightPopoverArrowVertical: 3.5,
        widthPopoverArrowVertical: 4.5,
        heightTooltipArrow: 5.5,
        widthTooltipArrow: 6.5,
        widthTooltipArrowVertical: 7.5,
        heightTooltipArrowVertical: 8.5,
        widthPopoverTitleBorder: 9.5,
        spacingPopoverTitlePadding: 10.5,
        spacingPopoverWithArrowPadding: 11.5,
        spacingPopoverArrowAdjustedOffsetY: 12.5,
        spacingTooltipArrowAdjustedOffsetY: 13.5,
        spacingTooltipArrowAdjustedOffsetX: 14.5,
        radiusPopover: 15.5,
        animationDurationPopoverIn: Duration(milliseconds: 1),
        animationDurationPopoverOut: Duration(milliseconds: 2),
        animationFunctionPopoverIn: Cubic(0.1, 0.2, 0.3, 0.4),
        animationFunctionPopoverOut: Cubic(0.5, 0.6, 0.7, 0.8),
      );
      expect(full.copyWith(), full);
      expect(full.merge(null), full);
      expect(const SemiPopoverThemeData().merge(full), full);
      expect(full == full.copyWith(), isTrue);
      expect(full.merge(const SemiPopoverThemeData(radiusPopover: 1)).radiusPopover, 1);
    });

    test('SemiComponentThemes wires the popover slot', () {
      const patch = SemiPopoverThemeData(radiusPopover: 3);
      const themes = SemiComponentThemes(popover: patch);
      expect(themes.copyWith().popover, patch);
      expect(const SemiComponentThemes().copyWith(popover: patch).popover, patch);
      expect(themes == themes.copyWith(), isTrue);
    });

    test('widget source keeps the provenance anchors', () {
      final widget = File(
        'lib/src/components/semi_popover.dart',
      ).readAsStringSync();
      // INTERNAL snippets (`_PopoverMetrics`).
      expect(widget, contains('\$horizontal-rate: 0.24'));
      expect(widget, contains('\$filter-popover-bg: none'));
      // The no-renderer `&-title` hook and the `unset` quirk stay as comments.
      expect(widget, contains('padding: \$spacing-popover_title-padding;'));
      expect(
        widget,
        contains(
          'border-bottom: \$width-popover_title-border solid '
          '\$color-popover-border-default;',
        ),
      );
      expect(
        widget,
        contains('showArrow ? <Arrow {...arrowProps} /> : false'),
      );
    });
  });

  group('widget behavior', () {
    testWidgets('hover shows the card; spacing defaults to 4 without the arrow', (
      tester,
    ) async {
      final log = <bool>[];
      await tester.pumpWidget(
        _app(
          SemiPopover(
            content: const Text('气泡内容'),
            onVisibleChange: log.add,
            child: _trigger(),
          ),
        ),
      );
      await _hover(tester);
      expect(find.text('气泡内容'), findsOneWidget);
      expect(log, [true]);
      final shell = tester.widget<SemiTooltip>(find.byType(SemiTooltip));
      expect(shell.trigger, SemiTooltipTrigger.hover);
      expect(shell.position, SemiTooltipPosition.bottom);
      expect(shell.showArrow, isFalse);
      expect(shell.popupBare, isTrue);
      expect(shell.spacing, 4);
      expect(shell.closeOnEsc, isTrue);
      expect(shell.zIndex, 1030);
      expect(shell.arrowBoundingOffsetY, 6);
      // No arrow: the wrapper carries no padding upstream.
      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(SemiTooltipPopup),
          matching: find.byType(Padding),
        ),
      );
      expect(padding.padding, EdgeInsets.zero);
    });

    testWidgets('showArrow paints the 24x8 popover wing with the 12px padding', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiPopover(
            content: const Text('气泡内容'),
            showArrow: true,
            child: _trigger(),
          ),
        ),
      );
      await _hover(tester);
      expect(find.text('气泡内容'), findsOneWidget);
      final shell = tester.widget<SemiTooltip>(find.byType(SemiTooltip));
      expect(shell.spacing, 10);
      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(SemiTooltipPopup),
          matching: find.byType(Padding),
        ),
      );
      expect(padding.padding, const EdgeInsets.all(12));
      final popup = tester.widget<SemiTooltipPopup>(
        find.byType(SemiTooltipPopup),
      );
      expect(popup.showArrow, isTrue);
      expect(popup.placement, isNotNull);
      // `numbers.ARROW_BOUNDING` box: thickness is the icon box height (8 —
      // the fringe pass overhangs the 7px wing), span the 24px width.
      final painter =
          tester
                  .widget<CustomPaint>(
                    find.descendant(
                      of: find.byType(SemiTooltipPopup),
                      matching: find.byType(CustomPaint),
                    ),
                  )
                  .painter
              as dynamic;
      expect(painter.thickness, 8);
      expect(painter.verticalThickness, 8);
      expect(painter.span, 24);
      expect(painter.verticalSpan, 24);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the shell patch carries the popover arrow box and motion', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiPopover(
            content: const Text('气泡内容'),
            showArrow: true,
            child: _trigger(),
          ),
        ),
      );
      await _hover(tester);
      // The popover-scope variable shadowing lands as a SemiTooltipTheme
      // patch around the shell.
      final context = tester.element(find.text('气泡内容'));
      final resolved = SemiTooltipTheme.of(context);
      expect(resolved.heightTooltipArrow, 8);
      expect(resolved.widthTooltipArrow, 24);
      expect(resolved.heightTooltipArrowVertical, 24);
      expect(resolved.widthTooltipArrowVertical, 8);
      expect(resolved.arrowAdjustedOffsetY, 6);
      expect(resolved.arrowAdjustedOffsetX, 5.76);
      expect(resolved.animationDurationIn, const Duration(milliseconds: 100));
      expect(resolved.animationDurationOut, const Duration(milliseconds: 100));
    });

    testWidgets('local SemiPopoverTheme patches reach the card', (tester) async {
      const patch = SemiPopoverThemeData(
        radiusPopover: 3,
        spacingPopoverWithArrowPadding: 20,
      );
      await tester.pumpWidget(
        _app(
          SemiPopover(
            content: const Text('气泡内容'),
            showArrow: true,
            child: _trigger(),
          ),
          popoverTheme: patch,
        ),
      );
      await _hover(tester);
      final context = tester.element(find.text('气泡内容'));
      final resolved = SemiPopoverTheme.resolve(context);
      expect(resolved.radiusPopover, 3);
      expect(resolved.spacingPopoverWithArrowPadding, 20);
      expect(resolved.spacingPopoverTitlePadding, 8, reason: '其余字段回退 Sass 默认');
      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(SemiTooltipPopup),
          matching: find.byType(Padding),
        ),
      );
      expect(padding.padding, const EdgeInsets.all(20));
    });

    testWidgets('arrowStyle overrides the two path tints and fringe opacity', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiPopover(
            content: const Text('气泡内容'),
            showArrow: true,
            arrowStyle: const SemiPopoverArrowStyle(
              borderColor: Color(0xff112233),
              backgroundColor: Color(0xff445566),
              borderOpacity: 0.5,
            ),
            child: _trigger(),
          ),
        ),
      );
      await _hover(tester);
      final popup = tester.widget<SemiTooltipPopup>(
        find.byType(SemiTooltipPopup),
      );
      expect(popup.arrowColor, const Color(0xff445566));
      expect(popup.arrowFringeColor?.r, (const Color(0xff112233)).r);
      expect(popup.arrowFringeColor?.g, (const Color(0xff112233)).g);
      expect(popup.arrowFringeColor?.b, (const Color(0xff112233)).b);
      expect(popup.arrowFringeColor?.a, moreOrLessEquals(0.5));
    });

    testWidgets('controlled visible only reports requests', (tester) async {
      final log = <bool>[];
      await tester.pumpWidget(
        _app(
          SemiPopover(
            content: const Text('气泡内容'),
            visible: true,
            onVisibleChange: log.add,
            child: _trigger(),
          ),
        ),
      );
      await _settleOpen(tester);
      expect(find.text('气泡内容'), findsOneWidget);
      expect(log, isEmpty);

      await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
      await _settleOpen(tester);
      expect(find.text('气泡内容'), findsOneWidget);
      expect(log, [false], reason: '受控只回调请求，关闭权在使用方');
    });

    testWidgets('Escape and outside click close; onClickOutSide reports', (
      tester,
    ) async {
      var outside = 0;
      await tester.pumpWidget(
        _app(
          SemiPopover(
            content: const Text('气泡内容'),
            trigger: SemiTooltipTrigger.click,
            onClickOutSide: () => outside++,
            child: _trigger(),
          ),
        ),
      );
      await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
      await _settleOpen(tester);
      expect(find.text('气泡内容'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await _settleOpen(tester);
      expect(find.text('气泡内容'), findsNothing);

      await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
      await _settleOpen(tester);
      await tester.tapAt(const Offset(5, 5));
      await _settleOpen(tester);
      expect(find.text('气泡内容'), findsNothing);
      expect(outside, 1);
    });
  });
}
