// Behavior matrix for SemiBackTop plus coverage for the 3 Sass declarations
// (3 FIELDS + 0 MOTION + 0 INTERNAL) — the 16 HARDCODES provenance anchors
// live in the widget's `_BackTopMetrics` / call sites, and no dead FIELDS
// exist (all three declarations are consumed upstream).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

/// The host body is served through a notifier: `Overlay.initialEntries` is
/// initState-only, so the entry must rebuild its child from outside (the
/// semi_tag_input_test.dart host precedent).
final _hostBody = ValueNotifier<Widget>(const SizedBox.shrink());

Widget host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 900,
  double height = 900,
}) {
  _hostBody.value = KeyedSubtree(key: UniqueKey(), child: child);
  return SemiTheme(
    data: const SemiThemeData.light(),
    child: Directionality(
      textDirection: direction,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(1200, 900)),
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => ValueListenableBuilder<Widget>(
                valueListenable: _hostBody,
                builder: (context, child, _) => Center(
                  child: SizedBox(width: width, height: height, child: child),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<TestGesture> startMouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

/// Pump [host] on a tall test surface.
Future<void> pumpHost(
  WidgetTester tester,
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 900,
  double height = 900,
}) async {
  await tester.binding.setSurfaceSize(const Size(1200, 1200));
  await tester.pumpWidget(
    host(child, direction: direction, width: width, height: height),
  );
}

// -- fixtures ----------------------------------------------------------------

/// 宿主页面：Stack（★SemiBackTop 是 PositionedDirectional——需 Stack 直接
/// 子节点位）+ 可滚内容。[stackKey] 供定位度量。
Widget backTopPage({
  required Widget backTop,
  required ScrollController controller,
  Key stackKey = const ValueKey('SemiBackTopHostStack'),
  double height = 300,
  int sections = 8,
}) => Stack(
  key: stackKey,
  children: [
    SingleChildScrollView(
      controller: controller,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 1; i <= sections; i++)
            SizedBox(height: height, child: Text('content $i')),
        ],
      ),
    ),
    backTop,
  ],
);

Widget backTop({
  ScrollController? scrollController,
  double visibilityHeight = 400,
  Duration duration = const Duration(milliseconds: 450),
  VoidCallback? onClick,
  Widget? child,
  String? semanticsLabel,
}) => SemiBackTop(
  scrollController: scrollController,
  visibilityHeight: visibilityHeight,
  duration: duration,
  onClick: onClick,
  semanticsLabel: semanticsLabel,
  child: child,
);

const _stackKey = ValueKey('SemiBackTopHostStack');

Offset stackTopLeft(WidgetTester tester) =>
    tester.getTopLeft(find.byKey(_stackKey));

Rect contentRect(WidgetTester tester) =>
    tester.getRect(find.byKey(SemiBackTop.contentKey));

// -- theme field table -------------------------------------------------------

typedef _Patch = SemiBackTopThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedBackTopThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$z-backtop: 10',
    42,
    (v) => SemiBackTopThemeData(zBacktop: v as int),
    (d) => d.zBacktop,
    (t) => 10,
  ),
  (
    r'$spacing-backtop-right: 100px',
    111.0,
    (v) => SemiBackTopThemeData(spacingBacktopRight: v as double),
    (d) => d.spacingBacktopRight,
    (t) => 100.0,
  ),
  (
    r'$spacing-backtop-bottom: 50px',
    112.0,
    (v) => SemiBackTopThemeData(spacingBacktopBottom: v as double),
    (d) => d.spacingBacktopBottom,
    (t) => 50.0,
  ),
];

void main() {
  group('theme fields (3 = 3 FIELDS + 0 MOTION + 0 INTERNAL)', () {
    test('3 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(3));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(const SemiBackTopThemeData().merge(patch), patch, reason: sass);
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
          read(const SemiBackTopThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiBackTopThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_backtop_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(3));
    });

    test('the 16 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_backtop.dart')
          .readAsStringSync();
      final anchors = <String>[
        'position: fixed',
        'box-sizing: border-box',
        r'z-index: $z-backtop',
        'cursor: pointer',
        'text-align: center',
        'overflow: hidden',
        'direction: rtl',
        'right: auto',
        r'left: $spacing-backtop-right',
        'visibilityHeight: 400',
        'target: getDefaultTarget',
        'duration: 450',
        'throttle(this.handleClick, this.props.duration ?? '
            'BackTop.defaultProps.duration)',
        'theme="light"',
        'icon={<IconChevronUp />}',
        "easing: 'easeInOutCubic'",
      ];
      expect(anchors, hasLength(16));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 1 int + 2 double', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        counts.update(
          value.runtimeType.toString(),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      expect(counts['int'], 1);
      expect(counts['double'], 2);
    });

    test('no dead FIELDS: all three consumed upstream', () {
      // backtop.scss:8-10 consume `right: $spacing-backtop-right` /
      // `bottom: $spacing-backtop-bottom` / `z-index: $z-backtop` —— the
      // dead-variable marker must not exist in the generated artifact.
      final source = File('lib/src/theme/semi_backtop_theme_data.dart')
          .readAsStringSync();
      expect(source, isNot(contains('dead variable')));
      final widgetSource = File('lib/src/components/semi_backtop.dart')
          .readAsStringSync();
      // ★zBacktop 无 Flutter z-index 槽——注释引用（transitionDelay 先例）。
      expect(widgetSource, contains('zBacktop'));
    });

    test('SemiComponentThemes wiring', () {
      expect(const SemiComponentThemes().backTop, const SemiBackTopThemeData());
      const patch = SemiBackTopThemeData(spacingBacktopRight: 32);
      const themes = SemiComponentThemes(backTop: patch);
      expect(const SemiComponentThemes().copyWith(backTop: patch), themes);
      expect(themes == const SemiComponentThemes(), isFalse);
      expect(themes.backTop, patch);
    });

    testWidgets('SemiBackTopTheme local patch applies (nested merge, '
        'inner wins its own field)', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpHost(
        tester,
        SemiTheme(
          data: const SemiThemeData.light(),
          child: SemiBackTopTheme(
            data: const SemiBackTopThemeData(spacingBacktopRight: 64),
            child: SemiBackTopTheme(
              data: const SemiBackTopThemeData(spacingBacktopBottom: 16),
              child: backTopPage(
                controller: controller,
                backTop: backTop(
                  scrollController: controller,
                  visibilityHeight: -1,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final stack = stackTopLeft(tester);
      final rect = contentRect(tester);
      // Outer patch field (right 64) + inner patch field (bottom 16)——
      // 内层只赢自己的字段。
      expect(rect.right, stack.dx + 900 - 64);
      expect(rect.bottom, stack.dy + 900 - 16);
    });
  });

  group('显示与隐藏', () {
    testWidgets('scrollTop > visibilityHeight 显示，否则隐藏（阈值边界含）', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpHost(
        tester,
        backTopPage(
          controller: controller,
          backTop: backTop(scrollController: controller),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(SemiBackTop.contentKey), findsNothing);
      controller.jumpTo(400);
      await tester.pump();
      expect(find.byKey(SemiBackTop.contentKey), findsNothing); // 400 > 400 假
      controller.jumpTo(401);
      await tester.pump();
      expect(find.byKey(SemiBackTop.contentKey), findsOneWidget);
      controller.jumpTo(0);
      await tester.pump();
      expect(find.byKey(SemiBackTop.contentKey), findsNothing);
    });

    testWidgets('visibilityHeight: -1 恒显（scrollTop 0 亦显）', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpHost(
        tester,
        backTopPage(
          controller: controller,
          backTop: backTop(scrollController: controller, visibilityHeight: -1),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(SemiBackTop.contentKey), findsOneWidget);
    });

    testWidgets('visibilityHeight 变化不滚动即重估（propUpdates 口径）', (tester) async {
      final controller = ScrollController();
      final visibilityHeight = ValueNotifier<double>(1000);
      addTearDown(controller.dispose);
      addTearDown(visibilityHeight.dispose);
      // ★notifier 驱动重建（元素复用、滚动位置保留）——pumpHost 整树重挂会把
      // 滚动位置重置为 initialScrollOffset，无法验证“不滚动即重估”。
      await pumpHost(
        tester,
        ValueListenableBuilder<double>(
          valueListenable: visibilityHeight,
          builder: (context, value, _) => backTopPage(
            controller: controller,
            backTop: backTop(
              scrollController: controller,
              visibilityHeight: value,
            ),
          ),
        ),
      );
      controller.jumpTo(200);
      await tester.pump();
      expect(find.byKey(SemiBackTop.contentKey), findsNothing);
      visibilityHeight.value = 100;
      await tester.pump();
      expect(find.byKey(SemiBackTop.contentKey), findsOneWidget);
      visibilityHeight.value = 1000;
      await tester.pump();
      expect(find.byKey(SemiBackTop.contentKey), findsNothing);
    });

    testWidgets('scrollController 换绑立即重估 + 新容器滚动生效（propUpdates '
        '口径）', (tester) async {
      final first = ScrollController();
      final second = ScrollController();
      final current = ValueNotifier<ScrollController>(first);
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      addTearDown(current.dispose);
      // 双滚动区：换绑 = SemiBackTop 目标从 first 切到 second（updateTarget
      // destroy+init 同口径；ScrollController 身份即绑定——差异清单 11）。
      await pumpHost(
        tester,
        Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 400,
              child: SingleChildScrollView(
                controller: first,
                child: Column(
                  children: [
                    for (var i = 0; i < 8; i++)
                      SizedBox(height: 300, child: Text('first $i')),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 400,
              top: 0,
              bottom: 0,
              width: 400,
              child: SingleChildScrollView(
                controller: second,
                child: Column(
                  children: [
                    for (var i = 0; i < 8; i++)
                      SizedBox(height: 300, child: Text('second $i')),
                  ],
                ),
              ),
            ),
            ValueListenableBuilder<ScrollController>(
              valueListenable: current,
              builder: (context, controller, _) =>
                  backTop(scrollController: controller, visibilityHeight: 100),
            ),
          ],
        ),
      );
      first.jumpTo(200);
      await tester.pump();
      expect(find.byKey(SemiBackTop.contentKey), findsOneWidget);
      // 换绑新目标（scrollTop 0）→ 立即隐藏。
      current.value = second;
      await tester.pump();
      expect(find.byKey(SemiBackTop.contentKey), findsNothing);
      // 新容器的滚动事件生效。
      second.jumpTo(200);
      await tester.pump();
      expect(find.byKey(SemiBackTop.contentKey), findsOneWidget);
    });

    testWidgets('目标缺失（scrollController 空）隐藏不抛出', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpHost(
        tester,
        backTopPage(
          controller: controller,
          backTop: backTop(
            scrollController: null,
            visibilityHeight: -1, // 阈值恒显，但目标缺失即隐藏。
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(SemiBackTop.contentKey), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('点击滚动', () {
    testWidgets('点击 animateTo 滚回顶部（easing: easeInOutCubic）', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpHost(
        tester,
        backTopPage(
          controller: controller,
          backTop: backTop(
            scrollController: controller,
            duration: const Duration(milliseconds: 300),
          ),
        ),
      );
      controller.jumpTo(1000);
      await tester.pump();
      expect(find.byKey(SemiBackTop.contentKey), findsOneWidget);
      await tester.tap(find.byKey(SemiBackTop.contentKey));
      await tester.pump();
      // 中途：0 < pixels < 1000（渐进滚动）。
      await tester.pump(const Duration(milliseconds: 150));
      final mid = controller.position.pixels;
      expect(mid, greaterThan(0));
      expect(mid, lessThan(1000));
      await tester.pumpAndSettle();
      expect(controller.position.pixels, 0);
    });

    testWidgets('onClick 每次节流触发回传（leading + trailing 均滚顶 + 发）', (tester) async {
      var clicks = 0;
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpHost(
        tester,
        backTopPage(
          controller: controller,
          backTop: backTop(
            scrollController: controller,
            visibilityHeight: -1,
            duration: const Duration(milliseconds: 100),
            onClick: () => clicks++,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SemiBackTop.contentKey));
      await tester.pump();
      expect(clicks, 1);
      await tester.pumpAndSettle();
    });
  });

  group('节流', () {
    testWidgets('leading 即发 + trailing 窗口末补发（pendingClick.test.jsx '
        'keeps the trailing click while mounted）', (tester) async {
      var clicks = 0;
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpHost(
        tester,
        backTopPage(
          controller: controller,
          backTop: backTop(
            scrollController: controller,
            visibilityHeight: -1,
            duration: const Duration(milliseconds: 100),
            onClick: () => clicks++,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SemiBackTop.contentKey));
      await tester.pump();
      await tester.tap(find.byKey(SemiBackTop.contentKey));
      await tester.pump();
      // leading 即发 1 次；trailing 挂账。
      expect(clicks, 1);
      await tester.pump(const Duration(milliseconds: 100));
      expect(clicks, 2); // 窗口末补发。
    });

    testWidgets('三次连点恰 2 次（leading + 单次 trailing）', (tester) async {
      var clicks = 0;
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpHost(
        tester,
        backTopPage(
          controller: controller,
          backTop: backTop(
            scrollController: controller,
            visibilityHeight: -1,
            duration: const Duration(milliseconds: 100),
            onClick: () => clicks++,
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(SemiBackTop.contentKey));
        await tester.pump();
      }
      expect(clicks, 1);
      await tester.pump(const Duration(milliseconds: 100));
      expect(clicks, 2);
    });

    testWidgets('unmount 后 pending trailing 不达（pendingClick.test.jsx '
        'does not deliver a throttled click after unmount）', (tester) async {
      var clicks = 0;
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpHost(
        tester,
        backTopPage(
          controller: controller,
          backTop: backTop(
            scrollController: controller,
            visibilityHeight: -1,
            duration: const Duration(milliseconds: 100),
            onClick: () => clicks++,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SemiBackTop.contentKey));
      await tester.pump();
      await tester.tap(find.byKey(SemiBackTop.contentKey));
      await tester.pump();
      expect(clicks, 1);
      // 卸载（componentWillUnmount `this.handler.cancel()`）。
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
      expect(clicks, 1);
    });
  });

  group('定位与 RTL', () {
    testWidgets('LTR：end 100 / bottom 50（backtop.scss:8-9）', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpHost(
        tester,
        backTopPage(
          controller: controller,
          backTop: backTop(scrollController: controller, visibilityHeight: -1),
        ),
      );
      await tester.pumpAndSettle();
      final stack = stackTopLeft(tester);
      final rect = contentRect(tester);
      expect(rect.right, stack.dx + 900 - 100);
      expect(rect.bottom, stack.dy + 900 - 50);
    });

    testWidgets('RTL：翻左下（rtl.scss:7-8 `right: auto; left: '
        r'$spacing-backtop-right`）', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpHost(
        tester,
        backTopPage(
          controller: controller,
          backTop: backTop(scrollController: controller, visibilityHeight: -1),
        ),
        direction: TextDirection.rtl,
      );
      await tester.pumpAndSettle();
      final stack = stackTopLeft(tester);
      final rect = contentRect(tester);
      expect(rect.left, stack.dx + 100);
      expect(rect.bottom, stack.dy + 900 - 50);
    });

    testWidgets('主题覆盖 spacing 生效（全局 SemiComponentThemes）', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpHost(
        tester,
        SemiTheme(
          data: const SemiThemeData.light().copyWith(
            components: const SemiComponentThemes(
              backTop: SemiBackTopThemeData(
                spacingBacktopRight: 32,
                spacingBacktopBottom: 24,
              ),
            ),
          ),
          child: backTopPage(
            controller: controller,
            backTop: backTop(
              scrollController: controller,
              visibilityHeight: -1,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final stack = stackTopLeft(tester);
      final rect = contentRect(tester);
      expect(rect.right, stack.dx + 900 - 32);
      expect(rect.bottom, stack.dy + 900 - 24);
    });
  });

  group('默认内容与自定义', () {
    testWidgets('缺省 renderDefault：IconButton theme="light" + '
        'IconChevronUp', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpHost(
        tester,
        backTopPage(
          controller: controller,
          backTop: backTop(scrollController: controller, visibilityHeight: -1),
        ),
      );
      await tester.pumpAndSettle();
      final button = tester.widget<SemiButton>(find.byType(SemiButton));
      expect(button.variant, SemiButtonVariant.light);
      expect(button.child, isNull); // icon-only（IconButton 口径）。
      final icon = tester.widget<SemiIcon>(
        find.descendant(
          of: find.byType(SemiButton),
          matching: find.byType(SemiIcon),
        ),
      );
      expect(icon.data, SemiIcons.chevronUp);
    });

    testWidgets('child 自定义替换默认按钮', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpHost(
        tester,
        backTopPage(
          controller: controller,
          backTop: backTop(
            scrollController: controller,
            visibilityHeight: -1,
            child: const Text('TOP'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('TOP'), findsOneWidget);
      expect(find.byType(SemiButton), findsNothing);
    });

    testWidgets('semanticsLabel 上达 Semantics（★上游无 aria-label 补强）', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpHost(
        tester,
        backTopPage(
          controller: controller,
          backTop: backTop(
            scrollController: controller,
            visibilityHeight: -1,
            semanticsLabel: '回到顶部',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('回到顶部'), findsOneWidget);
    });

    testWidgets('Enter 键盘激活（★上游无键盘激活补强）', (tester) async {
      var clicks = 0;
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpHost(
        tester,
        backTopPage(
          controller: controller,
          backTop: backTop(
            scrollController: controller,
            visibilityHeight: -1,
            onClick: () => clicks++,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final focus = tester
          .widget<Focus>(
            find.byWidgetPredicate(
              (w) => w is Focus && w.focusNode?.debugLabel == 'SemiBackTop',
            ),
          )
          .focusNode!;
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(clicks, 1);
    });
  });

  group('quirks', () {
    testWidgets('★节流窗口 mount 时捕获：duration 后改不换窗（index.tsx:64 '
        'quirk）', (tester) async {
      var clicks = 0;
      final controller = ScrollController();
      final duration = ValueNotifier<Duration>(
        const Duration(milliseconds: 100),
      );
      addTearDown(controller.dispose);
      addTearDown(duration.dispose);
      // ★notifier 驱动重建（元素复用）——只改 duration，不换 State。
      await pumpHost(
        tester,
        ValueListenableBuilder<Duration>(
          valueListenable: duration,
          builder: (context, value, _) => backTopPage(
            controller: controller,
            backTop: backTop(
              scrollController: controller,
              visibilityHeight: -1,
              duration: value,
              onClick: () => clicks++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // duration 改为 500ms——窗口仍为 mount 时的 100ms（动画时长读新值）。
      duration.value = const Duration(milliseconds: 500);
      await tester.pump();
      await tester.tap(find.byKey(SemiBackTop.contentKey));
      await tester.pump();
      await tester.tap(find.byKey(SemiBackTop.contentKey));
      await tester.pump();
      expect(clicks, 1);
      await tester.pump(const Duration(milliseconds: 100));
      expect(clicks, 2); // 旧窗口（100ms）末补发，而非 500ms。
    });

    testWidgets('鼠标光标 click（backtop.scss:11 `cursor: pointer`）', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpHost(
        tester,
        backTopPage(
          controller: controller,
          backTop: backTop(scrollController: controller, visibilityHeight: -1),
        ),
      );
      await tester.pumpAndSettle();
      final mouse = await startMouse(tester);
      final rect = contentRect(tester);
      await mouse.moveTo(rect.center);
      await tester.pump();
      final region = tester.widget<MouseRegion>(
        find.ancestor(
          of: find.byKey(SemiBackTop.contentKey),
          matching: find.byType(MouseRegion),
        ),
      );
      expect(region.cursor, SystemMouseCursors.click);
    });
  });
}
