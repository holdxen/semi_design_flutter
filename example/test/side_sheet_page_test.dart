import 'package:example/main.dart';
import 'package:example/pages/side_sheet.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/helper/dialog_proxy.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/helper/smart_dialog_test_state.dart';

Future<void> start(WidgetTester tester) async {
  addTearDown(() async {
    await tester.pump(const Duration(seconds: 3));
    SmartDialogTestState.reset();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });
  await tester.binding.setSurfaceSize(const Size(1200, 3000));
  await tester.pumpWidget(const SemiApp(home: SideSheetPage()));
  await tester.pump(const Duration(milliseconds: 60));
}

String statusText(WidgetTester tester) =>
    tester
            .widgetList<Text>(
              find.descendant(
                of: find.byKey(const ValueKey('side-sheet-status')),
                matching: find.byType(Text),
              ),
            )
            .map((t) => t.data ?? '')
            .join();

/// 入场落定（引擎入库帧 + 内容首建帧后 180ms 滑入动画才起步——需补拍
/// 完成滑移，否则内容盒平移出屏，tap 会 warnIfMissed）。
Future<void> openSettled(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(const Duration(milliseconds: 250));
}

void main() {
  testWidgets('declarative sheet opens and reports ok', (tester) async {
    await start(tester);
    expect(statusText(tester), '点击按钮查看交互。');
    await tester.tap(find.text('打开侧边栏'));
    await openSettled(tester);
    expect(find.text('这是一段侧边栏内容。'), findsOneWidget);
    await tester.tap(find.text('确定'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(statusText(tester), '点击了确定。');
    expect(find.text('这是一段侧边栏内容。'), findsNothing);
  });

  testWidgets('placement buttons slide the sheet from all four edges', (
    tester,
  ) async {
    await start(tester);
    for (final name in const ['top', 'right', 'bottom', 'left']) {
      await tester.tap(find.text(name));
      await openSettled(tester);
      expect(find.text('这是一段 placement: $name 的内容。'), findsOneWidget);
      // 中带 (600, 2000)：四向 sheet 都不覆盖（left/right 全高但宽 448，
      // top/bottom 全宽但高 448）——点蒙层关闭。
      await tester.tapAt(const Offset(600, 2000));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('这是一段 placement: $name 的内容。'), findsNothing);
    }
  });

  testWidgets('size buttons carry the three size labels', (tester) async {
    await start(tester);
    for (final name in const ['small', 'medium', 'large']) {
      expect(find.text(name), findsOneWidget);
    }
    await tester.tap(find.text('large'));
    await openSettled(tester);
    expect(find.text('尺寸 large'), findsOneWidget);
    await tester.tapAt(const Offset(600, 2000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
  });

  testWidgets('custom title/footer and fixed (mask: false) demos render', (
    tester,
  ) async {
    await start(tester);
    await tester.tap(find.text('自定义 title/footer'));
    await openSettled(tester);
    expect(find.text('自定义 title'), findsOneWidget);
    expect(find.text('知道了'), findsOneWidget);
    await tester.tap(find.text('知道了'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(statusText(tester), '自定义 footer 点击。');

    await tester.tap(find.text('无蒙层 fixed（mask: false）'));
    await openSettled(tester);
    expect(find.text('无蒙层：投影 + 点击穿透。'), findsOneWidget);

    // 体内收尾：关 fixed sheet + 冲引擎计时器（_verifyInvariants 在 teardown
    // 前——上游 SmartDialogTestState.reset 先例）。
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is SemiButton && w.child == null && w.icon != null,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    SmartDialogTestState.reset();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });

  testWidgets('closeOnEsc sheet reports afterVisibleChange true and false', (
    tester,
  ) async {
    await start(tester);
    await tester.tap(find.text('closeOnEsc（Esc 关闭）'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(statusText(tester), 'afterVisibleChange: true。');

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    // `(false)` 在 show Future 完成链（出场动画 + 引擎收尾帧）后补发。
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 250));
    expect(statusText(tester), 'afterVisibleChange: false。');
  });

  testWidgets('real shell zero-init: engine binds through SemiApp observer '
      'and side sheet opens', (tester) async {
    // 回归：web 上初始 didPush 时 Overlay 未挂载，绑定需逐帧重试
    // （SmartNavigatorObserver._tryBind）——否则弹层静默入库不渲染。
    addTearDown(() async {
      await tester.pump(const Duration(seconds: 3));
      SmartDialogTestState.reset();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
    });
    await tester.binding.setSurfaceSize(const Size(1200, 3000));
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('SideSheet 侧边栏'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('打开侧边栏'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text('这是一段侧边栏内容。'), findsOneWidget);
    expect(DialogProxy.instance.isBound, isTrue);
    // 引擎计时器在 _verifyInvariants（teardown 前）之前清理——体内收尾。
    SmartDialogTestState.reset();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });
}
