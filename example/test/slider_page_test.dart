import 'package:example/pages/slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder handle(String key, int index) => find.descendant(
  of: keyed(key),
  matching: find.byKey(SemiSlider.handleKey(index)),
);

Finder rail(String key) =>
    find.descendant(of: keyed(key), matching: find.byKey(SemiSlider.railKey));

double valueToX(
  WidgetTester tester,
  String key,
  double value, {
  double min = 0,
  double max = 100,
}) {
  final r = tester.getRect(rail(key));
  return r.left + (value - min) / (max - min) * r.width;
}

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: SliderPage()));
  await tester.pump(const Duration(milliseconds: 50));
}

/// Absorb the one dropped hit test (docs/known_issues.md #1) at a neutral
/// spot: (4, 4) sits in the page padding, away from every slider rail.
Future<void> warmup(WidgetTester tester) async {
  await tester.tapAt(const Offset(4, 4));
  await tester.pump();
}

Future<TestGesture> mouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

/// Pump past a controlled `value` change: its onAfterChange is deferred to
/// post-frame (library contract), and the status setState needs one more
/// build.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.pump();
  }
}

/// Tooltip overlays mount a few frames after `visible` flips.
Future<void> settleTip(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await tester.pump();
}

/// Click a mark label. The label overflows the 32px slider wrapper, so with
/// the app's text metrics its box center can fall outside the hit-testable
/// stack; press on the label inside the wrapper's last rows instead.
Future<void> tapMarkLabel(WidgetTester tester, String key, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.pump(const Duration(milliseconds: 50));
  await warmup(tester);
  final text = tester.getRect(find.text(label));
  final slider = tester.getRect(keyed(key));
  await tester.tapAt(Offset(text.center.dx, slider.bottom - 2));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

/// Focus a handle without pointer interaction (no session side effects).
Future<void> focusHandle(WidgetTester tester, String key, int index) async {
  final focus = tester.widget<Focus>(
    find.descendant(
      of: handle(key, index),
      matching: find.byWidgetPredicate(
        (w) => w is Focus && w.onKeyEvent != null && w.onFocusChange != null,
      ),
    ),
  );
  focus.focusNode!.requestFocus();
  await tester.pump();
}

/// Press handle [index] of the slider named by [key] and drag it to [toValue]
/// with a single move event; returns the gesture so tests can assert the
/// mid-drag state before `up()`.
Future<TestGesture> startDrag(
  WidgetTester tester,
  String key,
  int index,
  double toValue, {
  double min = 0,
  double max = 100,
}) async {
  await tester.ensureVisible(keyed(key));
  await tester.pump(const Duration(milliseconds: 50));
  await warmup(tester);
  final gesture = await mouse(tester);
  final c = tester.getCenter(handle(key, index));
  await gesture.moveTo(c);
  await gesture.down(c);
  await gesture.moveTo(
    Offset(valueToX(tester, key, toValue, min: min, max: max), c.dy),
  );
  await tester.pump();
  return gesture;
}

void main() {
  testWidgets('sections fit a narrow scaled screen and scroll to the bottom', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await start(tester);
    for (final title in [
      '基本用法',
      '受控',
      '范围选择',
      '步长',
      '刻度 marks',
      '禁用',
      '垂直',
      '垂直反转',
      '显示边界',
      '自定义 handleDot',
      'tooltip/formatter',
      '事件回调',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('basic drag moves the uncontrolled handle and reports values', (
    tester,
  ) async {
    await start(tester);
    final gesture = await startDrag(tester, 'slider-basic', 0, 60);
    expect(find.text('变更：60'), findsOneWidget);
    await gesture.up();
    await tester.pump();
    expect(find.text('提交：60'), findsOneWidget);
    expect(
      tester.getCenter(handle('slider-basic', 0)).dx,
      moreOrLessEquals(valueToX(tester, 'slider-basic', 60), epsilon: 0.01),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'controlled slider lands values via setState and keyboard works',
    (tester) async {
      await start(tester);
      final gesture = await startDrag(tester, 'slider-controlled', 0, 60);
      expect(find.text('变更：60'), findsOneWidget);
      await gesture.up();
      await settle(tester);
      // 值仅经 setState 落地：松手后手柄停在 60。
      expect(find.text('提交：60'), findsOneWidget);
      expect(
        tester.getCenter(handle('slider-controlled', 0)).dx,
        moreOrLessEquals(
          valueToX(tester, 'slider-controlled', 60),
          epsilon: 0.01,
        ),
      );
      // Keyboard case: arrow keys step by one and land via setState.
      await focusHandle(tester, 'slider-controlled', 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await settle(tester);
      expect(find.text('提交：61'), findsOneWidget);
      expect(
        tester.getCenter(handle('slider-controlled', 0)).dx,
        moreOrLessEquals(
          valueToX(tester, 'slider-controlled', 61),
          epsilon: 0.01,
        ),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('range reports sorted pairs and End collapses the min handle', (
    tester,
  ) async {
    await start(tester);
    final gesture = await startDrag(tester, 'slider-range', 0, 40);
    expect(find.text('变更：[40, 60]'), findsOneWidget);
    await gesture.up();
    await tester.pump();
    expect(find.text('提交：[40, 60]'), findsOneWidget);
    // Click jumps the nearest handle (max at 60 is nearer to 80).
    await warmup(tester);
    final r = tester.getRect(rail('slider-range'));
    await tester.tapAt(Offset(r.left + 0.8 * r.width, r.center.dy));
    await tester.pump();
    expect(find.text('提交：[40, 80]'), findsOneWidget);
    // End on the 'min' handle collapses both onto [v1, v1].
    await focusHandle(tester, 'slider-range', 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await settle(tester);
    expect(find.text('提交：[80, 80]'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('click snaps to the step grid relative to 0', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('slider-step'));
    await tester.pump(const Duration(milliseconds: 50));
    await warmup(tester);
    final r = tester.getRect(rail('slider-step'));
    // Raw click value 17 on the min=5/step=10 grid: the 0-relative snap
    // lands on 20 (a min-relative grid would have kept 15).
    await tester.tapAt(Offset(r.left + (17 - 5) / 95 * r.width, r.center.dy));
    await tester.pump();
    expect(find.text('提交：20'), findsOneWidget);
    expect(
      tester.getCenter(handle('slider-step', 0)).dx,
      moreOrLessEquals(r.left + (20 - 5) / 95 * r.width, epsilon: 0.01),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'marks show labels, clicks jump handles and tooltipOnMark hovers',
    (tester) async {
      await start(tester);
      await tester.ensureVisible(keyed('slider-marks'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('0'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      await tester.ensureVisible(keyed('slider-marks-decimal'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('0.5'), findsOneWidget);
      // Clicking a mark label jumps the nearest handle ([10, 100] → [50, 100]).
      await tapMarkLabel(tester, 'slider-marks', '50');
      expect(find.text('提交：[50, 100]'), findsOneWidget);
      // tooltipOnMark wraps each dot in a hover tooltip.
      await tester.ensureVisible(keyed('slider-marks-tooltip'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(SemiTooltipPopup), findsNothing);
      await warmup(tester);
      final gesture = await mouse(tester);
      final r = tester.getRect(rail('slider-marks-tooltip'));
      await gesture.moveTo(Offset(r.left + 0.2 * r.width, r.center.dy));
      await settleTip(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SemiTooltipPopup),
          matching: find.text('20 分'),
        ),
        findsOneWidget,
      );
      await gesture.moveTo(Offset.zero);
      await settleTip(tester);
      expect(find.byType(SemiTooltipPopup), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('disabled slider ignores taps and drags', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('slider-disabled'));
    await tester.pump(const Duration(milliseconds: 50));
    await warmup(tester);
    final r = tester.getRect(rail('slider-disabled'));
    await tester.tapAt(Offset(r.left + 0.8 * r.width, r.center.dy));
    await tester.pump();
    final gesture = await startDrag(tester, 'slider-disabled', 0, 80);
    await gesture.up();
    await settle(tester);
    expect(find.textContaining('变更：'), findsNothing);
    expect(find.textContaining('提交：'), findsNothing);
    expect(find.text('拖动或点击滑块查看事件。'), findsOneWidget);
    expect(
      tester.getCenter(handle('slider-disabled', 0)).dx,
      moreOrLessEquals(valueToX(tester, 'slider-disabled', 40), epsilon: 0.01),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('vertical and verticalReverse map click direction correctly', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('slider-vertical'));
    await tester.pump(const Duration(milliseconds: 50));
    await warmup(tester);
    final rv = tester.getRect(rail('slider-vertical'));
    await tester.tapAt(Offset(rv.center.dx, rv.top + 0.8 * rv.height));
    await tester.pump();
    // Plain vertical: value grows downward (80% down = 80).
    expect(find.text('提交：80'), findsOneWidget);

    await tester.ensureVisible(keyed('slider-reverse'));
    await tester.pump(const Duration(milliseconds: 50));
    await warmup(tester);
    final rr = tester.getRect(rail('slider-reverse'));
    await tester.tapAt(Offset(rr.center.dx, rr.top + 0.8 * rr.height));
    await tester.pump();
    // verticalReverse: min sits at the visual bottom (80% down = 20).
    expect(find.text('提交：20'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('boundary labels show only while the wrapper is hovered', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('slider-boundary'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('5.0'), findsNothing);
    expect(find.text('50.0'), findsNothing);
    await warmup(tester);
    final gesture = await mouse(tester);
    final r = tester.getRect(rail('slider-boundary'));
    await gesture.moveTo(r.center);
    await tester.pump();
    expect(find.text('5.0'), findsOneWidget);
    expect(find.text('50.0'), findsOneWidget);
    await gesture.moveTo(Offset.zero);
    await tester.pump();
    expect(find.text('5.0'), findsNothing);
    expect(find.text('50.0'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tooltip formats its content and showTooltip=false hides it', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('slider-tooltip'));
    await tester.pump(const Duration(milliseconds: 50));
    await warmup(tester);
    final gesture = await mouse(tester);
    await gesture.moveTo(tester.getCenter(handle('slider-tooltip', 0)));
    await settleTip(tester);
    expect(find.byType(SemiTooltipPopup), findsOneWidget);
    expect(find.text('30%'), findsOneWidget);
    await gesture.moveTo(Offset.zero);
    await settleTip(tester);
    expect(find.byType(SemiTooltipPopup), findsNothing);

    await tester.ensureVisible(keyed('slider-tooltip-hidden'));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveTo(tester.getCenter(handle('slider-tooltip-hidden', 0)));
    await settleTip(tester);
    expect(find.byType(SemiTooltipPopup), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('events demo reports onChanged, onMouseUp and onAfterChange', (
    tester,
  ) async {
    await start(tester);
    final gesture = await startDrag(tester, 'slider-events', 0, 55);
    await gesture.up();
    await settle(tester);
    expect(
      find.text('onChanged 55 → onMouseUp → onAfterChange 55'),
      findsOneWidget,
    );
    expect(find.text('提交：55'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
