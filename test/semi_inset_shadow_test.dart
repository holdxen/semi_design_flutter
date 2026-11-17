// SemiInsetShadow 画师测试：内环几何（像素采样）、显式合同（blur/offset
// 抛错、无 inset 直通）与 8 个消费组件 dark 渲染冒烟——dark 默认
// `--semi-shadow-elevated` 首层 `inset 0 0 0 1px` 曾令这些组件深色下抛
// UnsupportedError（unsupported operation）。
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/helper/dialog_proxy.dart';

/// 带 Overlay 的宿主（popover/userGuide 弹层、toast/notification 走
/// DialogProxy 都需要）。
Widget host(
  Widget child, {
  SemiThemeData? theme,
  TextDirection direction = TextDirection.ltr,
}) {
  _hostBody.value = KeyedSubtree(key: UniqueKey(), child: child);
  return SemiTheme(
    data: theme ?? const SemiThemeData.light(),
    child: Directionality(
      textDirection: direction,
      child: Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (context) => ValueListenableBuilder<Widget>(
              valueListenable: _hostBody,
              builder: (context, child, _) => Center(child: child),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Overlay.initialEntries 是 initState-only——宿主内容经 notifier 重建
/// （semi_tag_input_test.dart host 先例）。
final _hostBody = ValueNotifier<Widget>(const SizedBox.shrink());

/// 抓取 [RepaintBoundary] 图像并按像素读色（semi_tabs_test.dart:1625 先例：
/// runAsync + toImage、整数坐标避开 AA 半像素）。
Future<ByteData> _snapshot(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byType(RepaintBoundary),
  );
  ByteData? data;
  await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage();
    data = await image.toByteData();
  });
  return data!;
}

Color _at(ByteData data, int width, int x, int y) {
  final o = (y * width + x) * 4;
  return Color.fromARGB(
    data.getUint8(o + 3),
    data.getUint8(o),
    data.getUint8(o + 1),
    data.getUint8(o + 2),
  );
}

void main() {
  group('内环几何（像素采样）', () {
    testWidgets('spread 内环带贴 padding-box 边缘（零偏移零模糊精确）', (
      tester,
    ) async {
      const bg = Color(0xFFFFFFFF);
      const ring = Color(0xFFFF0000);
      await tester.pumpWidget(
        host(
          RepaintBoundary(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SemiInsetShadow(
                shadows: SemiShadows(const [
                  SemiShadowLayer(true, 0, 0, 0, 4, ring),
                ]),
                borderRadius: BorderRadius.circular(8),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final data = await _snapshot(tester);
      // 环带 [0, 4)：x=1、x=2 取样在带内；(50,50) 盒内为底色。
      expect(_at(data, 100, 1, 50), ring);
      expect(_at(data, 100, 2, 50), ring);
      expect(_at(data, 100, 50, 50), bg);
      // 上下边缘同环（贴边一周）。
      expect(_at(data, 100, 50, 1), ring);
      expect(_at(data, 100, 50, 98), ring);
    });

    testWidgets('borderWidth 把内环推到边框内侧（CSS padding-box 口径）', (
      tester,
    ) async {
      const bg = Color(0xFFFFFFFF);
      const ring = Color(0xFFFF0000);
      await tester.pumpWidget(
        host(
          RepaintBoundary(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SemiInsetShadow(
                shadows: SemiShadows(const [
                  SemiShadowLayer(true, 0, 0, 0, 2, ring),
                ]),
                borderRadius: BorderRadius.circular(8),
                borderWidth: 3,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final data = await _snapshot(tester);
      // 环带 [3, 5)：x=1（边框带，测试盒无真边框 → 露底色）/ x=4（环）/
      // x=8（盒内底色）。
      expect(_at(data, 100, 1, 50), bg);
      expect(_at(data, 100, 4, 50), ring);
      expect(_at(data, 100, 8, 50), bg);
    });
  });

  group('显式合同', () {
    test('toDropBoxShadows 显式转换 drop 层（toBoxShadows 仍拒绝 inset）', () {
      const dark = SemiThemeData.dark();
      final drops = dark.shadows.shadowElevated.toDropBoxShadows();
      expect(drops, hasLength(1), reason: 'dark elevated = 1 inset + 1 drop');
      expect(
        () => dark.shadows.shadowElevated.toBoxShadows(),
        throwsUnsupportedError,
      );
      const light = SemiThemeData.light();
      expect(
        light.shadows.shadowElevated.toDropBoxShadows(),
        light.shadows.shadowElevated.toBoxShadows(),
        reason: 'light 无 inset 层——两口径一致',
      );
    });

    testWidgets('blur/offset inset 层构造即抛（不静默近似）', (tester) async {
      await tester.pumpWidget(
        host(
          SemiInsetShadow(
            shadows: SemiShadows(const [
              SemiShadowLayer(true, 0, 0, 2, 1, Color(0xFFFFFFFF)),
            ]),
            borderRadius: BorderRadius.zero,
            child: const SizedBox(width: 10, height: 10),
          ),
        ),
      );
      expect(tester.takeException(), isA<UnsupportedError>());
    });

    testWidgets('无 inset 层直通 child（零开销）', (tester) async {
      await tester.pumpWidget(
        host(
          SemiInsetShadow(
            shadows: SemiShadows(const [
              SemiShadowLayer(false, 0, 4, 14, 0, Color(0x40000000)),
            ]),
            borderRadius: BorderRadius.zero,
            child: const SizedBox(width: 10, height: 10),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        find.descendant(
          of: find.byType(SemiInsetShadow),
          matching: find.byType(CustomPaint),
        ),
        findsNothing,
      );
    });
  });

  group('dark 模式消费组件冒烟（inset 阴影曾致崩溃）', () {
    // Modal/SideSheet/Feedback/UserGuide/Toast/Notification 走弹层引擎——
    // 先泵空宿主绑定 DialogProxy，再经 notifier 注入被测内容（引擎 show
    // 需要已绑定的 Overlay，semi_toast_test 同口径）。
    Future<void> pumpDark(WidgetTester tester, Widget child) async {
      addTearDown(() async => DialogProxy.instance.resetForTest());
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        host(const SizedBox.shrink(), theme: const SemiThemeData.dark()),
      );
      await tester.pump();
      DialogProxy.instance.bind(
        tester.state<OverlayState>(find.byType(Overlay)),
      );
      _hostBody.value = KeyedSubtree(key: UniqueKey(), child: child);
      // 小步 pump（toast 测试口径）：弹层入场动画/排布回调需要逐帧推进。
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 60));
      }
    }

    void expectSound(WidgetTester tester) {
      expect(tester.takeException(), isNull);
      expect(find.byType(SemiInsetShadow), findsWidgets);
    }

    /// 用例体内收尾：清 toast/notification 计时器 + 卸载宿主（引擎 dismiss
    /// 退场 120ms 计时器在此泵完——`!timersPending` 不变量）。
    Future<void> finish(WidgetTester tester) async {
      SemiToast.reset();
      SemiNotification.resetForTest();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('SemiPopover', (tester) async {
      await pumpDark(
        tester,
        SemiPopover(
          visible: true,
          motion: false,
          content: const Text('c'),
          child: const Text('t'),
        ),
      );
      expectSound(tester);
      await finish(tester);
    });

    testWidgets('SemiPopconfirm', (tester) async {
      await pumpDark(
        tester,
        SemiPopconfirm(
          visible: true,
          motion: false,
          title: const Text('t'),
          child: const Text('t'),
        ),
      );
      expect(find.byType(SemiPopconfirm), findsOneWidget);
      expect(find.text('t'), findsNWidgets(2), reason: '触发器 + 弹层标题');
      expectSound(tester);
      await finish(tester);
    });

    testWidgets('SemiModal', (tester) async {
      await pumpDark(
        tester,
        const SemiModal(visible: true, title: 't', content: Text('b')),
      );
      expectSound(tester);
      await finish(tester);
    });

    testWidgets('SemiSideSheet（fixed 模式 = mask false）', (tester) async {
      await pumpDark(
        tester,
        const SemiSideSheet(
          visible: true,
          motion: false,
          mask: false,
          content: Text('c'),
        ),
      );
      expectSound(tester);
      await finish(tester);
    });

    testWidgets('SemiFeedback（fixed 模式 = mask false）', (tester) async {
      await pumpDark(
        tester,
        const SemiFeedback(
          visible: true,
          motion: false,
          mask: false,
          title: Text('t'),
          content: Text('c'),
        ),
      );
      expectSound(tester);
      await finish(tester);
    });

    testWidgets('SemiUserGuide', (tester) async {
      await pumpDark(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SemiUserGuideTarget(
              id: 'a',
              child: SizedBox(width: 100, height: 50),
            ),
            const SemiUserGuide(
              visible: true,
              steps: [
                SemiUserGuideStep(target: 'a', title: 't', description: 'd'),
              ],
            ),
          ],
        ),
      );
      expectSound(tester);
      await finish(tester);
    });

    testWidgets('SemiToast', (tester) async {
      await pumpDark(tester, const SizedBox.shrink());
      SemiToast.success(content: 's');
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 60));
      }
      expectSound(tester);
      await finish(tester);
    });

    testWidgets('SemiNotification', (tester) async {
      await pumpDark(tester, const SizedBox.shrink());
      SemiNotification.info(title: 'i', content: 'c');
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 60));
      }
      expectSound(tester);
      await finish(tester);
    });
  });
}
