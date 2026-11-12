// Behavior matrix for SemiRating plus coverage for the 15 generated theme
// fields (12 FIELDS + 3 MOTION) and the 1 INTERNAL accounting (the identity
// transform scale kept in the widget's `_RatingMetrics`).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    SemiTheme(
      data: const SemiThemeData.light(),
      child: Directionality(
        textDirection: direction,
        child: Center(child: child),
      ),
    );

Finder iconFinder(SemiIconData data) =>
    find.byWidgetPredicate((w) => w is SemiIcon && w.data == data);

/// The per-star cell (the hover `AnimatedScale` wraps each star box; it is the
/// only AnimatedScale in the library).
Finder stars() => find.descendant(
  of: find.byType(SemiRating),
  matching: find.byType(AnimatedScale),
);

Finder starBox(int index) => stars().at(index);

/// The clipped overlay layer's width factor (the fill fraction).
double clipFactor(WidgetTester tester, int index) => tester
    .widget<Align>(
      find.descendant(
        of: starBox(index),
        matching: find.byWidgetPredicate(
          (w) => w is Align && w.widthFactor != null,
        ),
      ),
    )
    .widthFactor!;

BoxDecoration starDecoration(WidgetTester tester, int index) =>
    tester
            .widget<DecoratedBox>(
              find.descendant(
                of: starBox(index),
                matching: find.byType(DecoratedBox),
              ),
            )
            .decoration
        as BoxDecoration;

/// The root frame decoration (the only DecoratedBox above the star cells).
BoxDecoration rootDecoration(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(
              find.ancestor(
                of: starBox(0),
                matching: find.byType(DecoratedBox),
              ),
            )
            .decoration
        as BoxDecoration;

bool tooltipVisible(WidgetTester tester, int index) => tester
    .widget<SemiTooltip>(
      find.ancestor(of: starBox(index), matching: find.byType(SemiTooltip)),
    )
    .visible!;

SemiResolvedRatingThemeData resolved() =>
    const SemiRatingThemeData().resolve(const SemiThemeData.light());

Future<TestGesture> startMouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

typedef _Patch = SemiRatingThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedRatingThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$color-rating-icon-default: rgba(var(--semi-yellow-5), 1)',
    const Color(0xff123456),
    (Object v) => SemiRatingThemeData(colorRatingIconDefault: v as Color),
    (SemiResolvedRatingThemeData d) => d.colorRatingIconDefault,
    (SemiThemeData theme) => theme.palette.yellow5.toColor(1.0),
  ),
  (
    r'$color-rating-bg-default: var(--semi-color-fill-0)',
    const Color(0xff123456),
    (Object v) => SemiRatingThemeData(colorRatingBgDefault: v as Color),
    (SemiResolvedRatingThemeData d) => d.colorRatingBgDefault,
    (SemiThemeData theme) => theme.colors.colorFill0,
  ),
  (
    r'$color-rating-outline-focus: var(--semi-color-primary-light-active)',
    const Color(0xff123456),
    (Object v) => SemiRatingThemeData(colorRatingOutlineFocus: v as Color),
    (SemiResolvedRatingThemeData d) => d.colorRatingOutlineFocus,
    (SemiThemeData theme) => theme.colors.colorPrimaryLightActive,
  ),
  (
    r'$font-rating-fontSize: 20px',
    4.5,
    (Object v) => SemiRatingThemeData(fontRatingFontSize: v as double),
    (SemiResolvedRatingThemeData d) => d.fontRatingFontSize,
    (SemiThemeData theme) => 20.0,
  ),
  (
    r'$font-rating_item_small-fontSize: $width-rating_item_small',
    4.5,
    (Object v) => SemiRatingThemeData(fontRatingItemSmallFontSize: v as double),
    (SemiResolvedRatingThemeData d) => d.fontRatingItemSmallFontSize,
    (SemiThemeData theme) => 16.0,
  ),
  (
    r'$font-rating_item_default-fontSize: $width-rating_item_default',
    4.5,
    (Object v) =>
        SemiRatingThemeData(fontRatingItemDefaultFontSize: v as double),
    (SemiResolvedRatingThemeData d) => d.fontRatingItemDefaultFontSize,
    (SemiThemeData theme) => 24.0,
  ),
  (
    r'$spacing-rating-margin: 0px',
    4.5,
    (Object v) => SemiRatingThemeData(spacingRatingMargin: v as double),
    (SemiResolvedRatingThemeData d) => d.spacingRatingMargin,
    (SemiThemeData theme) => 0.0,
  ),
  (
    r'$spacing-rating-padding: 0px',
    4.5,
    (Object v) => SemiRatingThemeData(spacingRatingPadding: v as double),
    (SemiResolvedRatingThemeData d) => d.spacingRatingPadding,
    (SemiThemeData theme) => 0.0,
  ),
  (
    r'$spacing-rating_item-marginRight: 6px',
    4.5,
    (Object v) =>
        SemiRatingThemeData(spacingRatingItemMarginRight: v as double),
    (SemiResolvedRatingThemeData d) => d.spacingRatingItemMarginRight,
    (SemiThemeData theme) => 6.0,
  ),
  (
    r'$width-rating_item_small: 16px',
    4.5,
    (Object v) => SemiRatingThemeData(widthRatingItemSmall: v as double),
    (SemiResolvedRatingThemeData d) => d.widthRatingItemSmall,
    (SemiThemeData theme) => 16.0,
  ),
  (
    r'$width-rating_item_default: 24px',
    4.5,
    (Object v) => SemiRatingThemeData(widthRatingItemDefault: v as double),
    (SemiResolvedRatingThemeData d) => d.widthRatingItemDefault,
    (SemiThemeData theme) => 24.0,
  ),
  (
    r'$width-rating-outline-focus: 2px',
    4.5,
    (Object v) => SemiRatingThemeData(widthRatingOutlineFocus: v as double),
    (SemiResolvedRatingThemeData d) => d.widthRatingOutlineFocus,
    (SemiThemeData theme) => 2.0,
  ),
  (
    r'$transition_duration-rating-color: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 7),
    (Object v) =>
        SemiRatingThemeData(transitionDurationRatingColor: v as Duration),
    (SemiResolvedRatingThemeData d) => d.transitionDurationRatingColor,
    (SemiThemeData theme) => Duration.zero,
  ),
  (
    r'$transition_function-rating-color: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) =>
        SemiRatingThemeData(transitionFunctionRatingColor: v as Curve),
    (SemiResolvedRatingThemeData d) => d.transitionFunctionRatingColor,
    (SemiThemeData theme) => Curves.easeIn,
  ),
  (
    r'$transition_delay-rating-color: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 7),
    (Object v) =>
        SemiRatingThemeData(transitionDelayRatingColor: v as Duration),
    (SemiResolvedRatingThemeData d) => d.transitionDelayRatingColor,
    (SemiThemeData theme) => Duration.zero,
  ),
];

void main() {
  group('rendering and geometry', () {
    testWidgets('count stars render', (tester) async {
      await tester.pumpWidget(host(const SemiRating(count: 3)));
      expect(stars(), findsNWidgets(3));
      await tester.pumpWidget(host(const SemiRating(count: 7)));
      expect(stars(), findsNWidgets(7));
    });

    testWidgets('small 16x16, normal 24x24, custom N box and icon', (
      tester,
    ) async {
      await tester.pumpWidget(host(const SemiRating()));
      expect(tester.getSize(starBox(0)), const Size(24, 24));
      // The `default` tier icon is `extra-large` (24).
      expect(
        tester.getSize(iconFinder(SemiIcons.star).first),
        const Size(24, 24),
      );
      await tester.pumpWidget(
        host(const SemiRating(size: SemiRatingSize.small)),
      );
      expect(tester.getSize(starBox(0)), const Size(16, 16));
      // The `small` tier icon is `default` (16).
      expect(
        tester.getSize(iconFinder(SemiIcons.star).first),
        const Size(16, 16),
      );
      await tester.pumpWidget(host(const SemiRating(size: 30.0)));
      expect(tester.getSize(starBox(0)), const Size(30, 30));
      // The numeric tier icon is `inherit` -> customSize 30.
      expect(
        tester.getSize(iconFinder(SemiIcons.star).first),
        const Size(30, 30),
      );
    });

    testWidgets('star gap is 6 (margin-right; RTL mirrors)', (tester) async {
      await tester.pumpWidget(host(const SemiRating()));
      final a = tester.getRect(starBox(0));
      final b = tester.getRect(starBox(1));
      expect(b.left - a.right, 6);
      await tester.pumpWidget(
        host(const SemiRating(), direction: TextDirection.rtl),
      );
      final c = tester.getRect(starBox(0));
      final d = tester.getRect(starBox(1));
      expect(c.left - d.right, 6);
    });

    testWidgets('fill fraction clips 3.5 -> 0.5 and 3.65 -> 0.65', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const SemiRating(
            key: ValueKey('half'),
            allowHalf: true,
            defaultValue: 3.5,
          ),
        ),
      );
      expect(clipFactor(tester, 2), 1.0);
      expect(clipFactor(tester, 3), moreOrLessEquals(0.5, epsilon: 1e-9));
      expect(clipFactor(tester, 4), 0.0);
      await tester.pumpWidget(
        host(const SemiRating(key: ValueKey('frac'), defaultValue: 3.65)),
      );
      expect(clipFactor(tester, 2), 1.0);
      expect(clipFactor(tester, 3), moreOrLessEquals(0.65, epsilon: 1e-9));
    });
  });

  group('hover', () {
    testWidgets('hover previews the value and reports onHoverChange', (
      tester,
    ) async {
      final hoverLog = <double?>[];
      await tester.pumpWidget(
        host(SemiRating(defaultValue: 4, onHoverChange: hoverLog.add)),
      );
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(starBox(2)));
      await tester.pump();
      expect(hoverLog, [3.0]);
      // The preview overrides the displayed fill: star 4 empties.
      expect(clipFactor(tester, 3), 0.0);
      expect(clipFactor(tester, 2), 1.0);
      // The hovered star scales 1.1, its neighbours do not.
      expect(tester.widget<AnimatedScale>(starBox(2)).scale, 1.1);
      expect(tester.widget<AnimatedScale>(starBox(3)).scale, 1.0);
      // Same-value hovers are not re-reported.
      await gesture.moveTo(tester.getCenter(starBox(2)) + const Offset(1, 0));
      await tester.pump();
      expect(hoverLog, [3.0]);
    });

    testWidgets('mouseleave reports null and drops the preview', (
      tester,
    ) async {
      final hoverLog = <double?>[];
      await tester.pumpWidget(
        host(SemiRating(defaultValue: 4, onHoverChange: hoverLog.add)),
      );
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(starBox(2)));
      await tester.pump();
      await gesture.moveTo(Offset.zero);
      await tester.pump();
      expect(hoverLog, [3.0, null]);
      expect(clipFactor(tester, 3), 1.0);
    });

    testWidgets('clearedValue debounce: the cleared value does not preview', (
      tester,
    ) async {
      final hoverLog = <double?>[];
      final log = <double>[];
      await tester.pumpWidget(
        host(
          SemiRating(
            defaultValue: 4,
            onChanged: log.add,
            onHoverChange: hoverLog.add,
          ),
        ),
      );
      final gesture = await startMouse(tester);
      final r = tester.getRect(starBox(3));
      await gesture.moveTo(Offset(r.left + r.width / 2, r.center.dy));
      await tester.pump();
      expect(hoverLog, [4.0]);
      // Clicking the current value clears to 0 (allowClear) and resets the
      // preview.
      await tester.tapAt(Offset(r.left + r.width / 2, r.center.dy));
      await tester.pump();
      expect(log, [0.0]);
      expect(hoverLog, [4.0, null]);
      expect(clipFactor(tester, 3), 0.0);
      // Hovering the just-cleared value stays suppressed.
      await gesture.moveTo(Offset(r.left + r.width / 2 + 1, r.center.dy));
      await tester.pump();
      expect(hoverLog, [4.0, null]);
      expect(clipFactor(tester, 3), 0.0);
      // Hovering another value previews it again (debounce released).
      await gesture.moveTo(tester.getCenter(starBox(2)));
      await tester.pump();
      expect(hoverLog, [4.0, null, 3.0]);
      expect(clipFactor(tester, 2), 1.0);
    });

    testWidgets('half hit: LTR left half is x.5, right half x+1', (
      tester,
    ) async {
      final hoverLog = <double?>[];
      await tester.pumpWidget(
        host(SemiRating(allowHalf: true, onHoverChange: hoverLog.add)),
      );
      final gesture = await startMouse(tester);
      final r = tester.getRect(starBox(2));
      await gesture.moveTo(Offset(r.left + r.width * 0.25, r.center.dy));
      await tester.pump();
      expect(hoverLog, [2.5]);
      await gesture.moveTo(Offset(r.left + r.width * 0.75, r.center.dy));
      await tester.pump();
      expect(hoverLog, [2.5, 3.0]);
    });

    testWidgets('half hit mirrors in RTL: right half is x.5', (tester) async {
      final hoverLog = <double?>[];
      await tester.pumpWidget(
        host(
          SemiRating(allowHalf: true, onHoverChange: hoverLog.add),
          direction: TextDirection.rtl,
        ),
      );
      final gesture = await startMouse(tester);
      final r = tester.getRect(starBox(2));
      await gesture.moveTo(Offset(r.left + r.width * 0.75, r.center.dy));
      await tester.pump();
      expect(hoverLog, [2.5]);
      await gesture.moveTo(Offset(r.left + r.width * 0.25, r.center.dy));
      await tester.pump();
      expect(hoverLog, [2.5, 3.0]);
    });
  });

  group('click', () {
    testWidgets('tap selects and same-value tap clears to 0', (tester) async {
      final log = <double>[];
      await tester.pumpWidget(
        host(SemiRating(defaultValue: 3, onChanged: log.add)),
      );
      await tester.tap(starBox(4));
      await tester.pump();
      expect(log, [5.0]);
      expect(clipFactor(tester, 4), 1.0);
      await tester.tap(starBox(4));
      await tester.pump();
      expect(log, [5.0, 0.0]);
      expect(clipFactor(tester, 4), 0.0);
    });

    testWidgets('allowClear false never clears on same-value tap', (
      tester,
    ) async {
      final log = <double>[];
      await tester.pumpWidget(
        host(
          SemiRating(defaultValue: 3, allowClear: false, onChanged: log.add),
        ),
      );
      await tester.tap(starBox(4));
      await tester.pump();
      await tester.tap(starBox(4));
      await tester.pump();
      expect(log, [5.0, 5.0]);
      expect(clipFactor(tester, 4), 1.0);
    });

    testWidgets('half click selects x.5 and clears at the same value', (
      tester,
    ) async {
      final log = <double>[];
      await tester.pumpWidget(
        host(SemiRating(allowHalf: true, onChanged: log.add)),
      );
      var r = tester.getRect(starBox(2));
      await tester.tapAt(Offset(r.left + r.width * 0.25, r.center.dy));
      await tester.pump();
      expect(log, [2.5]);
      r = tester.getRect(starBox(2));
      await tester.tapAt(Offset(r.left + r.width * 0.25, r.center.dy));
      await tester.pump();
      expect(log, [2.5, 0.0]);
    });

    testWidgets('controlled rating only notifies, never lands', (tester) async {
      final log = <double>[];
      await tester.pumpWidget(host(SemiRating(value: 3, onChanged: log.add)));
      await tester.tap(starBox(4));
      await tester.pump();
      expect(log, [5.0]);
      // The rendered value stays 3.
      expect(clipFactor(tester, 2), 1.0);
      expect(clipFactor(tester, 4), 0.0);
    });

    testWidgets('releasing control keeps the last controlled value', (
      tester,
    ) async {
      Widget build(double? value) => host(SemiRating(value: value));
      await tester.pumpWidget(build(3));
      expect(clipFactor(tester, 2), 1.0);
      await tester.pumpWidget(build(null));
      expect(clipFactor(tester, 2), 1.0);
    });

    testWidgets('onClick reports the tapped star index', (tester) async {
      final clicks = <int>[];
      await tester.pumpWidget(host(SemiRating(onClick: clicks.add)));
      await tester.tap(starBox(1));
      await tester.pump();
      await tester.tap(starBox(3));
      await tester.pump();
      expect(clicks, [1, 3]);
    });
  });

  group('keyboard', () {
    testWidgets('four arrows step and wrap 0<->count', (tester) async {
      final log = <double>[];
      final hoverLog = <double?>[];
      await tester.pumpWidget(
        host(
          SemiRating(
            autofocus: true,
            defaultValue: 1,
            onChanged: log.add,
            onHoverChange: hoverLog.add,
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(log, [2.0, 3.0, 2.0, 1.0]);
      // 0 <-> count wrap: left at 0 jumps to count, right at count wraps 0.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(log, [2.0, 3.0, 2.0, 1.0, 0.0, 5.0, 0.0]);
      // Stepping clears the hover preview and reports null.
      expect(hoverLog, [null, null, null, null, null, null, null]);
    });

    testWidgets('allowHalf steps 0.5', (tester) async {
      final log = <double>[];
      await tester.pumpWidget(
        host(
          SemiRating(
            autofocus: true,
            allowHalf: true,
            defaultValue: 2.5,
            onChanged: log.add,
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(log, [2.0, 2.5, 3.0]);
    });

    testWidgets('RTL swaps increase and decrease', (tester) async {
      final log = <double>[];
      await tester.pumpWidget(
        host(
          SemiRating(autofocus: true, defaultValue: 2, onChanged: log.add),
          direction: TextDirection.rtl,
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(log, [3.0, 2.0]);
    });

    testWidgets('KeyRepeat repeats the step', (tester) async {
      final log = <double>[];
      await tester.pumpWidget(
        host(SemiRating(autofocus: true, defaultValue: 1, onChanged: log.add)),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(log, [2.0, 3.0, 4.0]);
    });

    testWidgets('Enter applies the click semantics (same value clears)', (
      tester,
    ) async {
      final log = <double>[];
      final hoverLog = <double?>[];
      await tester.pumpWidget(
        host(
          SemiRating(
            autofocus: true,
            defaultValue: 3,
            onChanged: log.add,
            onHoverChange: hoverLog.add,
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(log, [0.0]);
      expect(hoverLog, [null]);
      expect(clipFactor(tester, 2), 0.0);
    });

    testWidgets('Enter without allowClear reports the same value', (
      tester,
    ) async {
      final log = <double>[];
      await tester.pumpWidget(
        host(
          SemiRating(
            autofocus: true,
            allowClear: false,
            defaultValue: 3,
            onChanged: log.add,
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(log, [3.0]);
    });

    testWidgets('Enter on a half value clears it (same value)', (tester) async {
      final log = <double>[];
      await tester.pumpWidget(
        host(
          SemiRating(
            autofocus: true,
            allowHalf: true,
            defaultValue: 3.5,
            onChanged: log.add,
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(log, [0.0]);
    });
  });

  group('focus ring, disabled, character, tooltips', () {
    testWidgets('focus ring is keyboard-gated and taps clear it', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const SemiRating(autofocus: true, defaultValue: 3)),
      );
      await tester.pump();
      // Mouse/focus-without-keys paints no ring.
      expect(starDecoration(tester, 2).boxShadow, isNull);
      expect(rootDecoration(tester).boxShadow, isNull);
      await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      // The ring lands on the current focus star (ceil(3) - 1 == 2).
      expect(starDecoration(tester, 2).boxShadow, hasLength(1));
      expect(
        starDecoration(tester, 2).boxShadow!.single.color,
        resolved().colorRatingOutlineFocus,
      );
      expect(
        starDecoration(tester, 2).boxShadow!.single.spreadRadius,
        resolved().widthRatingOutlineFocus,
      );
      expect(starDecoration(tester, 0).boxShadow, isNull);
      expect(rootDecoration(tester).boxShadow, isNull);
      await tester.tap(starBox(0));
      await tester.pump();
      expect(starDecoration(tester, 0).boxShadow, isNull);
      expect(starDecoration(tester, 2).boxShadow, isNull);
    });

    testWidgets('value 0 paints the ring on the container', (tester) async {
      await tester.pumpWidget(
        host(const SemiRating(autofocus: true, defaultValue: 0)),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(rootDecoration(tester).boxShadow, hasLength(1));
      expect(
        rootDecoration(tester).boxShadow!.single.color,
        resolved().colorRatingOutlineFocus,
      );
      expect(starDecoration(tester, 0).boxShadow, isNull);
    });

    testWidgets('disabled intercepts click, hover, keyboard, semantics', (
      tester,
    ) async {
      final log = <double>[];
      final hoverLog = <double?>[];
      await tester.pumpWidget(
        host(
          SemiRating(
            disabled: true,
            autofocus: true,
            defaultValue: 2,
            onChanged: log.add,
            onHoverChange: hoverLog.add,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(starBox(0));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(starBox(0)));
      await tester.pump();
      expect(log, isEmpty);
      expect(hoverLog, isEmpty);
      // The value stays 2 and the hovered star never scales.
      expect(clipFactor(tester, 1), 1.0);
      expect(tester.widget<AnimatedScale>(starBox(0)).scale, 1.0);
      final node = tester.getSemantics(find.byType(SemiRating));
      expect(node.flagsCollection.isEnabled, ui.Tristate.isFalse);
    });

    testWidgets('custom character replaces the star icon', (tester) async {
      await tester.pumpWidget(host(const SemiRating(character: Text('X'))));
      // Both stack layers render the character (base + clipped overlay).
      expect(
        find.descendant(of: starBox(0), matching: find.text('X')),
        findsNWidgets(2),
      );
      expect(find.text('X'), findsNWidgets(10));
      expect(iconFinder(SemiIcons.star), findsNothing);
    });

    testWidgets('tooltips show on integer hover only (not on halves)', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const SemiRating(
            allowHalf: true,
            tooltips: ['a', 'b', 'c', 'd', 'e'],
          ),
        ),
      );
      final gesture = await startMouse(tester);
      final r = tester.getRect(starBox(2));
      // Hovering the left half (2.5) must not show the tooltip.
      await gesture.moveTo(Offset(r.left + r.width * 0.25, r.center.dy));
      await tester.pump();
      expect(tooltipVisible(tester, 2), isFalse);
      // Hovering the right half hits 3.0 (integer) and shows it.
      await gesture.moveTo(Offset(r.left + r.width * 0.75, r.center.dy));
      await tester.pump();
      expect(tooltipVisible(tester, 2), isTrue);
      expect(tooltipVisible(tester, 1), isFalse);
    });
  });

  group('theme fields (12 + 3 + 1)', () {
    test('15 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(15));
      expect(
        fields.where((f) => f.$1.startsWith(r'$transition_')),
        hasLength(3),
      );
      expect(
        fields.where((f) => !f.$1.startsWith(r'$transition_')),
        hasLength(12),
      );
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(const SemiRatingThemeData().merge(patch), patch, reason: sass);
        expect(patch.copyWith(), patch, reason: sass);
        expect(patch.copyWith().hashCode, patch.hashCode, reason: sass);
        expect(patch.merge(null), patch, reason: sass);
        expect(
          read(patch.resolve(const SemiThemeData.dark())),
          value,
          reason: sass,
        );
        final light = const SemiThemeData.light();
        expect(
          read(const SemiRatingThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiRatingThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_rating_theme_data.dart')
          .readAsStringSync();
      final widgetSource = File('lib/src/components/semi_rating.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(15));
      // The 16th declaration stays widget-internal.
      expect(
        widgetSource,
        contains(r'$transform_scale-rating: var(--semi-transform_scale-none)'),
      );
    });

    test('type coverage: 3 Color + 9 double + 2 Duration + 1 Curve', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        counts.update(
          value.runtimeType.toString(),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      expect(counts['Color'], 3);
      expect(counts['double'], 9);
      expect(counts['Duration'], 2);
      // Curves.bounceIn is a ParametricCurve.
      expect(fields.where((f) => f.$2 is Curve), hasLength(1));
    });

    test('SemiComponentThemes wiring', () {
      expect(const SemiComponentThemes().rating, const SemiRatingThemeData());
      const patch = SemiRatingThemeData(
        colorRatingIconDefault: Color(0xff123456),
      );
      const themes = SemiComponentThemes(rating: patch);
      expect(const SemiComponentThemes().copyWith(rating: patch), themes);
      expect(themes == const SemiComponentThemes(), isFalse);
      expect(themes.rating, patch);
    });

    testWidgets('SemiRatingTheme local patch applies to the rating', (
      tester,
    ) async {
      await tester.pumpWidget(
        SemiTheme(
          data: const SemiThemeData.light(),
          child: SemiRatingTheme(
            data: const SemiRatingThemeData(
              colorRatingIconDefault: Color(0xff00ff00),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Center(
                child: SemiRatingTheme(
                  data: const SemiRatingThemeData(widthRatingItemSmall: 20),
                  child: const SemiRating(size: SemiRatingSize.small),
                ),
              ),
            ),
          ),
        ),
      );
      // Nested local patches merge; the inner patch wins its own field only.
      expect(tester.getSize(starBox(0)), const Size(20, 20));
      expect(
        tester.widget<SemiIcon>(iconFinder(SemiIcons.star).last).color,
        const Color(0xff00ff00),
      );
    });
  });
}
