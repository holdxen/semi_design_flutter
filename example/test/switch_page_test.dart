import 'dart:ui' show Tristate;

import 'package:example/pages/switch.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder status(String text) =>
    find.descendant(of: keyed('switch-status'), matching: find.text(text));

Finder track(String key) =>
    find.descendant(of: keyed(key), matching: find.byKey(SemiSwitch.trackKey));

SemiSwitch sw(WidgetTester tester, String key) =>
    tester.widget<SemiSwitch>(keyed(key));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: SwitchPage()));
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 50));
  // See docs/known_issues.md #1 — one dropped hit test can follow
  // focus-driven rebuilds at a scroll viewport edge.
  await tester.tapAt(const Offset(700, 500));
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

/// Send [key] to the focused switch and settle the toggle rebuild.
Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

Future<TestGesture> mouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
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
    for (final title in ['基本用法', '尺寸', '不可用', '带文本', '受控组件', '加载中', '事件回调']) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('basic switch toggles on tap and Space but not on Enter', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await start(tester);
    await tap(tester, keyed('switch-basic'));
    expect(status('开'), findsOneWidget);
    await tap(tester, keyed('switch-basic'));
    expect(status('关'), findsOneWidget);
    // Space toggles while the tapped switch keeps focus.
    await press(tester, LogicalKeyboardKey.space);
    expect(status('开'), findsOneWidget);
    // ★ Enter does NOT toggle (native checkbox semantics).
    await press(tester, LogicalKeyboardKey.enter);
    expect(status('开'), findsOneWidget);
    expect(status('关'), findsNothing);
    // The uncontrolled demo keeps its landed state.
    expect(
      tester.getSemantics(keyed('switch-basic')).flagsCollection.isToggled,
      Tristate.isTrue,
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets(
    'controlled demos follow the parent value; the button demo is strict',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await start(tester);
      // 受控（官方「受控组件」）：tap 只回调，显示跟随父级 setState 落地的值。
      expect(sw(tester, 'switch-controlled').checked, isTrue);
      await tap(tester, keyed('switch-controlled'));
      expect(status('关'), findsOneWidget);
      expect(sw(tester, 'switch-controlled').checked, isFalse);
      expect(
        tester
            .getSemantics(keyed('switch-controlled'))
            .flagsCollection
            .isToggled,
        Tristate.isFalse,
      );
      await tap(tester, keyed('switch-controlled'));
      expect(status('开'), findsOneWidget);
      expect(sw(tester, 'switch-controlled').checked, isTrue);

      // 严格受控：开关只通知，显示只跟随按钮。
      await tap(tester, keyed('switch-controlled-button'));
      expect(status('严格：开'), findsOneWidget); // onChanged 通知发出
      expect(sw(tester, 'switch-controlled-button').checked, isFalse);
      expect(
        tester
            .getSemantics(keyed('switch-controlled-button'))
            .flagsCollection
            .isToggled,
        Tristate.isFalse,
      );
      await tap(tester, keyed('switch-controlled-bump'));
      expect(sw(tester, 'switch-controlled-button').checked, isTrue);
      expect(
        tester
            .getSemantics(keyed('switch-controlled-button'))
            .flagsCollection
            .isToggled,
        Tristate.isTrue,
      );
      // 再点开关：状态通知变化但显示纹丝不动（父级值未翻转）。
      await tap(tester, keyed('switch-controlled-button'));
      expect(status('严格：关'), findsOneWidget);
      expect(sw(tester, 'switch-controlled-button').checked, isTrue);
      expect(
        tester
            .getSemantics(keyed('switch-controlled-button'))
            .flagsCollection
            .isToggled,
        Tristate.isTrue,
      );
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );

  testWidgets(
    'disabled and loading block taps and Space; loading shows SemiSpin',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await start(tester);
      await tap(tester, keyed('switch-disabled'));
      await tap(tester, keyed('switch-disabled-checked'));
      await tap(tester, keyed('switch-loading'));
      await tap(tester, keyed('switch-loading-checked'));
      await press(tester, LogicalKeyboardKey.space);
      // 状态行仍为占位文案 —— 一切切换被屏蔽。
      expect(status('点击或按空格切换开关查看事件。'), findsOneWidget);
      expect(sw(tester, 'switch-disabled-checked').checked, isTrue);
      expect(
        tester
            .getSemantics(keyed('switch-loading-checked'))
            .flagsCollection
            .isToggled,
        Tristate.isTrue,
      );
      // 加载态：旋钮槽渲染 SemiSpin。
      expect(
        find.descendant(
          of: keyed('switch-loading'),
          matching: find.byType(SemiSpin),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: keyed('switch-loading-checked'),
          matching: find.byType(SemiSpin),
        ),
        findsOneWidget,
      );
      // ★语义 enabled 只看 disabled（loading 不反映）。
      expect(
        tester.getSemantics(keyed('switch-disabled')).flagsCollection.isEnabled,
        Tristate.isFalse,
      );
      expect(
        tester.getSemantics(keyed('switch-loading')).flagsCollection.isEnabled,
        Tristate.isTrue,
      );
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );

  testWidgets('sizes render the documented track geometry', (tester) async {
    await start(tester);
    expect(sw(tester, 'switch-size-small').size, SemiSwitchSize.small);
    expect(sw(tester, 'switch-size-default').size, SemiSwitchSize.normal);
    expect(sw(tester, 'switch-size-large').size, SemiSwitchSize.large);
    final small = tester.getRect(track('switch-size-small'));
    final normal = tester.getRect(track('switch-size-default'));
    final large = tester.getRect(track('switch-size-large'));
    // 26×16 / 40×24 / 54×32（switch.scss 几何）。
    expect(small.width, 26);
    expect(small.height, 16);
    expect(normal.width, 40);
    expect(normal.height, 24);
    expect(large.width, 54);
    expect(large.height, 32);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'checked and unchecked texts are mutually exclusive; small shows neither',
    (tester) async {
      await start(tester);
      // 未选中只显示 uncheckedText。
      expect(
        find.descendant(of: keyed('switch-text'), matching: find.text('关')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: keyed('switch-text'), matching: find.text('开')),
        findsNothing,
      );
      expect(
        find.descendant(of: keyed('switch-text-alt'), matching: find.text('〇')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: keyed('switch-text-alt'), matching: find.text('｜')),
        findsNothing,
      );
      // 选中只显示 checkedText。
      expect(
        find.descendant(
          of: keyed('switch-text-checked'),
          matching: find.text('开'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: keyed('switch-text-checked'),
          matching: find.text('关'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: keyed('switch-text-checked-alt'),
          matching: find.text('｜'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: keyed('switch-text-checked-alt'),
          matching: find.text('〇'),
        ),
        findsNothing,
      );
      // large 同规则。
      expect(
        find.descendant(
          of: keyed('switch-text-large'),
          matching: find.text('关'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: keyed('switch-text-large'),
          matching: find.text('开'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: keyed('switch-text-large-checked'),
          matching: find.text('开'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: keyed('switch-text-large-checked'),
          matching: find.text('关'),
        ),
        findsNothing,
      );
      // ★small 一律不渲染文案。
      for (final key in ['switch-text-small', 'switch-text-small-checked']) {
        expect(
          find.descendant(of: keyed(key), matching: find.text('开')),
          findsNothing,
        );
        expect(
          find.descendant(of: keyed(key), matching: find.text('关')),
          findsNothing,
        );
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('hover reports onMouseEnter and onMouseLeave', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('switch-events'));
    await tester.pump(const Duration(milliseconds: 50));
    final gesture = await mouse(tester);
    await gesture.moveTo(tester.getCenter(keyed('switch-events')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(status('鼠标移入'), findsOneWidget);
    expect(
      find.descendant(
        of: keyed('switch-events-log'),
        matching: find.textContaining('onMouseEnter'),
      ),
      findsOneWidget,
    );
    await gesture.moveTo(const Offset(700, 200));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(status('鼠标移出'), findsOneWidget);
    expect(
      find.descendant(
        of: keyed('switch-events-log'),
        matching: find.textContaining('onMouseLeave'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('losing focus fires onBlur', (tester) async {
    await start(tester);
    await tap(tester, keyed('switch-events'));
    expect(status('开'), findsOneWidget);
    expect(
      find.descendant(
        of: keyed('switch-events-log'),
        matching: find.textContaining('onBlur'),
      ),
      findsNothing,
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(status('失焦'), findsOneWidget);
    expect(
      find.descendant(
        of: keyed('switch-events-log'),
        matching: find.textContaining('onBlur'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
