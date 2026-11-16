import 'package:example/main.dart';
import 'package:example/pages/modal.dart';
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
  await tester.pumpWidget(const SemiApp(home: ModalPage()));
  await tester.pump(const Duration(milliseconds: 60));
}

String statusText(WidgetTester tester) =>
    tester
            .widgetList<Text>(
              find.descendant(
                of: find.byKey(const ValueKey('modal-status')),
                matching: find.byType(Text),
              ),
            )
            .map((t) => t.data ?? '')
            .join();

void main() {
  testWidgets('declarative modal opens and reports ok', (tester) async {
    await start(tester);
    expect(statusText(tester), '点击按钮查看交互。');
    await tester.tap(find.text('打开对话框'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text('这是一段对话框内容。'), findsOneWidget);
    await tester.tap(find.text('确定'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(statusText(tester), '点击了确定。');
    expect(find.text('这是一段对话框内容。'), findsNothing);
  });

  testWidgets('confirm family dialogs open and dismiss', (tester) async {
    await start(tester);
    await tester.tap(find.text('confirm'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text('确定执行该操作吗？'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(statusText(tester), 'confirm 取消。');

    await tester.tap(find.text('error'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text('操作失败，请重试。'), findsOneWidget);
    await tester.tap(find.text('确定'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('操作失败，请重试。'), findsNothing);
  });

  testWidgets('size buttons carry the four size labels', (tester) async {
    await start(tester);
    for (final name in const ['small', 'medium', 'large', 'fullWidth']) {
      expect(find.text(name), findsOneWidget);
    }
  });

  testWidgets('real shell zero-init: engine binds through SemiApp observer '
      'and modal opens', (tester) async {
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
    await tester.tap(find.text('Modal 模态对话框'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('打开对话框'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text('这是一段对话框内容。'), findsOneWidget);
    expect(DialogProxy.instance.isBound, isTrue);
    // 引擎计时器在 _verifyInvariants（teardown 前）之前清理——体内收尾。
    SmartDialogTestState.reset();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });
}
