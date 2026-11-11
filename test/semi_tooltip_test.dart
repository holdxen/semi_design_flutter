import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

const _kTrigger = Key('trigger');

/// Opaque box so taps and hovers always hit the trigger subtree.
Widget _trigger() => Listener(
  behavior: HitTestBehavior.opaque,
  onPointerDown: (_) {},
  child: const SizedBox(key: _kTrigger, width: 40, height: 20),
);

Widget _app(
  Widget body, {
  SemiTooltipThemeData tooltipTheme = const SemiTooltipThemeData(),
  TextDirection textDirection = TextDirection.ltr,
  Alignment alignment = Alignment.center,
  Key? overlayKey,
}) => SemiTheme(
  data: const SemiThemeData.light(),
  child: SemiTooltipTheme(
    data: tooltipTheme,
    child: Directionality(
      textDirection: textDirection,
      child: Overlay(
        key: overlayKey,
        initialEntries: [
          OverlayEntry(
            builder: (context) => Align(alignment: alignment, child: body),
          ),
        ],
      ),
    ),
  ),
);

/// Frame 1 inserts the overlay entry, frame 2 measures and positions it,
/// frame 3 renders it in place.
Future<void> _settleOpen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pump();
}

SemiTooltipPopup _popup(WidgetTester tester) =>
    tester.widget<SemiTooltipPopup>(find.byType(SemiTooltipPopup));

void main() {
  testWidgets('click shows the popup and clickToHide hides it', (tester) async {
    final log = <bool>[];
    await tester.pumpWidget(
      _app(
        SemiTooltip(
          trigger: SemiTooltipTrigger.click,
          clickToHide: true,
          motion: false,
          onVisibleChange: log.add,
          content: const Text('Hint'),
          child: _trigger(),
        ),
      ),
    );
    await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
    await _settleOpen(tester);
    expect(find.byType(SemiTooltipPopup), findsOneWidget);
    expect(log, [true]);

    await tester.tap(find.byType(SemiTooltipPopup), warnIfMissed: false);
    await tester.pump();
    expect(find.byType(SemiTooltipPopup), findsNothing);
    expect(log, [true, false]);
  });

  testWidgets('click outside closes and reports onClickOutSide', (
    tester,
  ) async {
    var outside = 0;
    await tester.pumpWidget(
      _app(
        SemiTooltip(
          trigger: SemiTooltipTrigger.click,
          motion: false,
          onClickOutSide: () => outside++,
          content: const Text('Hint'),
          child: _trigger(),
        ),
      ),
    );
    await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
    await _settleOpen(tester);
    expect(find.byType(SemiTooltipPopup), findsOneWidget);

    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    expect(find.byType(SemiTooltipPopup), findsNothing);
    expect(outside, 1);
  });

  testWidgets('hover delays 50/50 and survives the trigger-popup gap', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        SemiTooltip(
          trigger: SemiTooltipTrigger.hover,
          motion: false,
          content: const Text('Hint'),
          child: _trigger(),
        ),
      ),
    );
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    final triggerCenter = tester.getCenter(find.byKey(_kTrigger));
    await gesture.moveTo(triggerCenter);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 49));
    expect(find.byType(SemiTooltipPopup), findsNothing);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    await tester.pump();
    expect(find.byType(SemiTooltipPopup), findsOneWidget);

    // Exit the trigger into the gap: the 50ms hide timer starts.
    final gap = Offset(triggerCenter.dx, triggerCenter.dy - 14);
    await gesture.moveTo(gap);
    await tester.pump(const Duration(milliseconds: 30));
    // Enter the popup before the timer elapses: the shared timer is cleared.
    await gesture.moveTo(tester.getRect(find.byType(SemiTooltipPopup)).center);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(SemiTooltipPopup), findsOneWidget);

    // Leave both regions: the 50ms hide delay closes it.
    await gesture.moveTo(const Offset(5, 395));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    expect(find.byType(SemiTooltipPopup), findsNothing);
  });

  testWidgets('focus shows and blur hides', (tester) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    await tester.pumpWidget(
      _app(
        SemiTooltip(
          trigger: SemiTooltipTrigger.focus,
          motion: false,
          content: const Text('Hint'),
          child: Focus(focusNode: node, child: _trigger()),
        ),
      ),
    );
    node.requestFocus();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    await tester.pump();
    expect(find.byType(SemiTooltipPopup), findsOneWidget);

    node.unfocus();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    expect(find.byType(SemiTooltipPopup), findsNothing);
  });

  testWidgets('visible non-null controls visibility; events only notify', (
    tester,
  ) async {
    final log = <bool>[];
    final visible = ValueNotifier<bool>(false);
    await tester.pumpWidget(
      _app(
        ValueListenableBuilder<bool>(
          valueListenable: visible,
          builder: (context, value, _) => SemiTooltip(
            trigger: SemiTooltipTrigger.click,
            visible: value,
            motion: false,
            onVisibleChange: log.add,
            content: const Text('Hint'),
            child: _trigger(),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
    await _settleOpen(tester);
    expect(find.byType(SemiTooltipPopup), findsNothing);
    expect(log, [true]);

    visible.value = true;
    await _settleOpen(tester);
    expect(find.byType(SemiTooltipPopup), findsOneWidget);

    visible.value = false;
    await tester.pump();
    await tester.pump();
    expect(find.byType(SemiTooltipPopup), findsNothing);
  });

  testWidgets('custom shows only from visible', (tester) async {
    await tester.pumpWidget(
      _app(
        SemiTooltip(
          trigger: SemiTooltipTrigger.custom,
          visible: true,
          motion: false,
          content: const Text('Hint'),
          child: _trigger(),
        ),
      ),
    );
    await _settleOpen(tester);
    expect(find.byType(SemiTooltipPopup), findsOneWidget);
  });

  testWidgets('contextMenu opens on secondary tap; outside tap closes', (
    tester,
  ) async {
    var outside = 0;
    await tester.pumpWidget(
      _app(
        SemiTooltip(
          trigger: SemiTooltipTrigger.contextMenu,
          motion: false,
          onClickOutSide: () => outside++,
          content: const Text('Hint'),
          child: _trigger(),
        ),
      ),
    );
    await tester.tap(
      find.byKey(_kTrigger),
      buttons: kSecondaryMouseButton,
      warnIfMissed: false,
    );
    await _settleOpen(tester);
    expect(find.byType(SemiTooltipPopup), findsOneWidget);

    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    expect(find.byType(SemiTooltipPopup), findsNothing);
    expect(outside, 1);
  });

  testWidgets('Escape is consumed only when it can close', (tester) async {
    for (final c in [
      (visible: false, closeOnEsc: true, parent: 1, esc: 0),
      (visible: true, closeOnEsc: false, parent: 1, esc: 0),
      (visible: true, closeOnEsc: true, parent: 0, esc: 1),
    ]) {
      var parent = 0;
      var esc = 0;
      // A fresh overlay per case: OverlayEntry does not rebuild on pumpWidget.
      await tester.pumpWidget(
        KeyedSubtree(
          key: UniqueKey(),
          child: _app(
            Focus(
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent) parent++;
                return KeyEventResult.ignored;
              },
              child: SemiTooltip(
                trigger: SemiTooltipTrigger.custom,
                visible: c.visible,
                closeOnEsc: c.closeOnEsc,
                motion: false,
                onEscKeyDown: () => esc++,
                content: const Text('Hint'),
                child: Focus(autofocus: true, child: _trigger()),
              ),
            ),
          ),
        ),
      );
      await _settleOpen(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      expect(
        parent,
        c.parent,
        reason: 'visible=${c.visible} closeOnEsc=${c.closeOnEsc}',
      );
      expect(
        esc,
        c.esc,
        reason: 'visible=${c.visible} closeOnEsc=${c.closeOnEsc}',
      );
    }
  });

  testWidgets('show requested during the hide animation is replayed', (
    tester,
  ) async {
    final visible = ValueNotifier<bool>(true);
    await tester.pumpWidget(
      _app(
        ValueListenableBuilder<bool>(
          valueListenable: visible,
          builder: (context, value, _) => SemiTooltip(
            trigger: SemiTooltipTrigger.custom,
            visible: value,
            content: const Text('tip'),
            child: _trigger(),
          ),
        ),
      ),
    );
    await _settleOpen(tester);
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(SemiTooltipPopup), findsOneWidget);

    visible.value = false;
    await tester.pump(); // hide animation starts
    visible.value = true;
    await tester.pump(); // parked as pending show
    await tester.pump(const Duration(milliseconds: 150)); // replay
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(SemiTooltipPopup), findsOneWidget);
  });

  testWidgets('a later hide stays the final request', (tester) async {
    final visible = ValueNotifier<bool>(true);
    await tester.pumpWidget(
      _app(
        ValueListenableBuilder<bool>(
          valueListenable: visible,
          builder: (context, value, _) => SemiTooltip(
            trigger: SemiTooltipTrigger.custom,
            visible: value,
            content: const Text('tip'),
            child: _trigger(),
          ),
        ),
      ),
    );
    await _settleOpen(tester);
    await tester.pump(const Duration(milliseconds: 150));

    visible.value = false;
    await tester.pump();
    visible.value = true;
    await tester.pump();
    visible.value = false;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump();
    expect(find.byType(SemiTooltipPopup), findsNothing);
  });

  testWidgets('motion disabled reopens immediately', (tester) async {
    final visible = ValueNotifier<bool>(true);
    await tester.pumpWidget(
      _app(
        ValueListenableBuilder<bool>(
          valueListenable: visible,
          builder: (context, value, _) => SemiTooltip(
            trigger: SemiTooltipTrigger.custom,
            visible: value,
            motion: false,
            content: const Text('tip'),
            child: _trigger(),
          ),
        ),
      ),
    );
    await _settleOpen(tester);
    expect(find.byType(SemiTooltipPopup), findsOneWidget);

    visible.value = false;
    await tester.pump();
    await tester.pump();
    expect(find.byType(SemiTooltipPopup), findsNothing);

    visible.value = true;
    await _settleOpen(tester);
    expect(find.byType(SemiTooltipPopup), findsOneWidget);
  });

  testWidgets('MediaQuery.disableAnimations skips the motion', (tester) async {
    final visible = ValueNotifier<bool>(true);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: _app(
          ValueListenableBuilder<bool>(
            valueListenable: visible,
            builder: (context, value, _) => SemiTooltip(
              trigger: SemiTooltipTrigger.custom,
              visible: value,
              content: const Text('tip'),
              child: _trigger(),
            ),
          ),
        ),
      ),
    );
    await _settleOpen(tester);
    expect(find.byType(SemiTooltipPopup), findsOneWidget);

    visible.value = false;
    await tester.pump();
    await tester.pump();
    expect(find.byType(SemiTooltipPopup), findsNothing);
  });

  testWidgets('TickerMode disabled skips the motion', (tester) async {
    final visible = ValueNotifier<bool>(true);
    await tester.pumpWidget(
      TickerMode(
        enabled: false,
        child: _app(
          ValueListenableBuilder<bool>(
            valueListenable: visible,
            builder: (context, value, _) => SemiTooltip(
              trigger: SemiTooltipTrigger.custom,
              visible: value,
              content: const Text('tip'),
              child: _trigger(),
            ),
          ),
        ),
      ),
    );
    await _settleOpen(tester);
    expect(find.byType(SemiTooltipPopup), findsOneWidget);

    visible.value = false;
    await tester.pump();
    await tester.pump();
    expect(find.byType(SemiTooltipPopup), findsNothing);
  });

  testWidgets('small surface flips the placement and reports it', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(300, 300);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      _app(
        SemiTooltip(
          trigger: SemiTooltipTrigger.click,
          motion: false,
          content: const SizedBox(width: 120, height: 80),
          child: _trigger(),
        ),
        alignment: const Alignment(0, -0.8),
      ),
    );
    await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
    await _settleOpen(tester);
    expect(find.byType(SemiTooltipPopup), findsOneWidget);
    expect(_popup(tester).placement, TooltipPlacement.bottom);
  });

  testWidgets('arrow offset stays clamped on a narrow surface', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(200, 400);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      _app(
        SemiTooltip(
          trigger: SemiTooltipTrigger.click,
          motion: false,
          content: const SizedBox(width: 300, height: 40),
          child: _trigger(),
        ),
        alignment: const Alignment(-0.8, 0),
      ),
    );
    await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
    await _settleOpen(tester);
    expect(find.byType(SemiTooltipPopup), findsOneWidget);
    final popup = _popup(tester);
    expect(popup.placement, TooltipPlacement.top);
    final fraction = popup.arrowOffset!.fraction!;
    expect(fraction, greaterThanOrEqualTo(0.075 - 1e-9));
    expect(fraction, lessThanOrEqualTo(0.925 + 1e-9));
    expect(fraction, isNot(0.5));
  });

  testWidgets('RTL mirrors the content padding', (tester) async {
    const theme = SemiTooltipThemeData(
      spacingTooltipContentPaddingLeft: 30,
      spacingTooltipContentPaddingRight: 5,
    );
    const contentKey = Key('content');
    Future<void> pumpWith(TextDirection direction) async {
      await tester.pumpWidget(
        _app(
          SemiTooltip(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            content: const SizedBox(key: contentKey, width: 40, height: 20),
            child: _trigger(),
          ),
          tooltipTheme: theme,
          textDirection: direction,
          overlayKey: UniqueKey(),
        ),
      );
      await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
      await _settleOpen(tester);
    }

    await pumpWith(TextDirection.ltr);
    final ltrDx =
        tester.getTopLeft(find.byKey(contentKey)).dx -
        tester.getTopLeft(find.byType(SemiTooltipPopup)).dx;
    expect(ltrDx, closeTo(30, 0.01));

    await pumpWith(TextDirection.rtl);
    final rtlDx =
        tester.getTopLeft(find.byKey(contentKey)).dx -
        tester.getTopLeft(find.byType(SemiTooltipPopup)).dx;
    expect(rtlDx, closeTo(5, 0.01));
  });

  testWidgets('tooltip renders without Material', (tester) async {
    await tester.pumpWidget(
      _app(
        SemiTooltip(
          trigger: SemiTooltipTrigger.click,
          motion: false,
          content: const Text('Hint'),
          child: _trigger(),
        ),
      ),
    );
    await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
    await _settleOpen(tester);
    expect(find.byType(SemiTooltipPopup), findsOneWidget);
    expect(
      find.byWidgetPredicate((w) => w.runtimeType.toString() == 'Material'),
      findsNothing,
    );
  });

  testWidgets('unload removes the entry and cancels pending timers', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        SemiTooltip(
          trigger: SemiTooltipTrigger.click,
          motion: false,
          content: const Text('Hint'),
          child: _trigger(),
        ),
      ),
    );
    await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
    await _settleOpen(tester);
    expect(find.byType(SemiTooltipPopup), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    expect(find.byType(SemiTooltipPopup), findsNothing);
    await tester.pump(const Duration(milliseconds: 500));

    // A pending hover show timer must not fire after unmount.
    await tester.pumpWidget(
      _app(
        SemiTooltip(
          trigger: SemiTooltipTrigger.hover,
          motion: false,
          content: const Text('Hint'),
          child: _trigger(),
        ),
      ),
    );
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(tester.getCenter(find.byKey(_kTrigger)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(SemiTooltipPopup), findsNothing);
  });

  group('theme', () {
    test('all 26 fields resolve with the documented defaults', () {
      const theme = SemiThemeData.light();
      final r = const SemiTooltipThemeData().resolve(theme);
      expect(r.colorTooltipBgDefault, theme.palette.grey7.toColor(1));
      expect(r.colorTooltipTextDefault, theme.colors.colorBg0);
      expect(r.colorTooltipIconDefault, theme.palette.grey7.toColor(1));
      expect(r.colorTooltipArrowIconDefault, theme.palette.grey7.toColor(1));
      expect(r.radiusTooltip, theme.radius.borderRadiusMedium.value);
      expect(r.spacingTooltipContentPaddingLeft, 12);
      expect(r.spacingTooltipContentPaddingRight, 12);
      expect(r.spacingTooltipContentPaddingTop, 8);
      expect(r.spacingTooltipContentPaddingBottom, 8);
      expect(r.fontSize, theme.typography.fontSizeRegular);
      expect(r.widthTooltip, 240);
      expect(r.widthTooltipArrow, 24);
      expect(r.heightTooltipArrow, 7);
      expect(r.heightTooltipArrowVertical, 24);
      expect(r.widthTooltipArrowVertical, 7);
      expect(r.arrowOffsetX, 1);
      expect(r.arrowOffsetY, 1);
      expect(r.arrowAdjustedOffsetY, 5);
      expect(r.arrowAdjustedOffsetX, 5.76);
      expect(r.zoomScaleFrom, 0.8);
      expect(r.zoomOpacityFrom, 0);
      expect(r.zoomOpacityTo, 1);
      expect(r.animationDurationIn, const Duration(milliseconds: 100));
      expect(r.animationDurationOut, const Duration(milliseconds: 100));
      expect(
        semiCurveEquals(
          r.animationFunctionIn,
          const Cubic(0.215, 0.61, 0.355, 1),
        ),
        isTrue,
      );
      expect(
        semiCurveEquals(
          r.animationFunctionOut,
          const Cubic(0.215, 0.61, 0.355, 1),
        ),
        isTrue,
      );
    });

    test('overrides survive copyWith/merge and live references follow', () {
      const base = SemiTooltipThemeData();
      final override = base.copyWith(
        colorTooltipIconDefault: const Color(0xff123456),
        fontSize: 20,
      );
      expect(override.copyWith().fontSize, 20);
      final merged = override.merge(
        const SemiTooltipThemeData(widthTooltip: 300),
      );
      expect(merged.fontSize, 20);
      expect(merged.widthTooltip, 300);
      final r = merged.resolve(const SemiThemeData.light());
      expect(r.fontSize, 20);
      expect(r.widthTooltip, 300);
      // Live reference: the arrow icon default follows the icon override.
      expect(r.colorTooltipArrowIconDefault, const Color(0xff123456));
      expect(
        r.colorTooltipBgDefault,
        const SemiThemeData.light().palette.grey7.toColor(1),
      );
    });

    test('curve fields compare by value, not identity', () {
      final a = SemiTooltipThemeData(
        animationFunctionIn: Cubic(0.215, 0.61, 0.355, 1),
      );
      final b = SemiTooltipThemeData(
        animationFunctionIn: Cubic(0.215, 0.61, 0.355, 1),
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    testWidgets(
      'nested capture keeps patches and rebinds destination globals',
      (tester) async {
        late CapturedThemes captured;
        late Widget Function(Widget) wrap;
        await tester.pumpWidget(
          SemiTheme(
            data: const SemiThemeData.light(),
            child: Builder(
              builder: (outer) => SemiTooltipTheme(
                data: const SemiTooltipThemeData(widthTooltip: 333),
                child: SemiTooltipTheme(
                  data: const SemiTooltipThemeData(fontSize: 19),
                  child: Builder(
                    builder: (inner) {
                      captured = InheritedTheme.capture(from: inner, to: outer);
                      wrap = captured.wrap;
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ),
          ),
        );
        for (final color in [
          const Color(0xff112233),
          const Color(0xff556677),
        ]) {
          await tester.pumpWidget(
            SemiTheme(
              data: SemiThemeData.light(colors: SemiColors(colorBg0: color)),
              child: wrap(
                Builder(
                  builder: (context) {
                    final t = SemiTooltipTheme.resolve(context);
                    expect(t.widthTooltip, 333);
                    expect(t.fontSize, 19);
                    expect(t.colorTooltipTextDefault, color);
                    return const SizedBox();
                  },
                ),
              ),
            ),
          );
        }
      },
    );
  });
}
