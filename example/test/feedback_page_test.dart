import 'package:example/pages/feedback.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';
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
  await tester.pumpWidget(const SemiApp(home: FeedbackPage()));
  await tester.pump(const Duration(milliseconds: 60));
}

String statusText(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(
        of: find.byKey(const ValueKey('feedback-status')),
        matching: find.byType(Text),
      ),
    )
    .map((t) => t.data ?? '')
    .join();

/// 入场落定（引擎入库帧 + 内容首建帧 + 180ms 滑入动画）。
Future<void> openSettled(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(const Duration(milliseconds: 250));
}

void main() {
  testWidgets('FeedbackPage shows every feedback example', (tester) async {
    await start(tester);
    expect(tester.takeException(), isNull);
    expect(statusText(tester), '点击按钮查看交互。');
    for (final title in [
      '表情（emoji，缺省类型）',
      '文本（text）',
      '单选（radio）',
      '多选（checkbox）',
      '自定义内容（custom）',
      'Modal 模式',
      '异步提交（onOk 返回 Future）',
    ]) {
      expect(find.text(title), findsOneWidget);
    }
    final feedbacks = tester
        .widgetList<SemiFeedback>(find.byType(SemiFeedback))
        .toList();
    expect(feedbacks, hasLength(7));
    expect(feedbacks[0].type, SemiFeedbackType.emoji);
    expect(feedbacks[1].type, SemiFeedbackType.text);
    expect(feedbacks[5].mode, SemiFeedbackMode.modal);
  });

  testWidgets('emoji popup opens, bad reveals the optional textarea and ok '
      'reports', (tester) async {
    await start(tester);
    await tester.tap(find.text('打开反馈弹层'));
    await openSettled(tester);
    expect(find.text('为什么给出这个评分？'), findsOneWidget);
    expect(find.text('😞'), findsOneWidget);
    expect(find.text('😐'), findsOneWidget);
    expect(find.text('😃'), findsOneWidget);
    // bad 选中 → 追问 TextArea（`optionalPlaceholder`）。
    await tester.tap(find.text('😞'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byType(SemiTextArea), findsOneWidget);
    await tester.tap(find.text('提交'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(statusText(tester), '感谢您的反馈！');
    expect(find.text('为什么给出这个评分？'), findsNothing);
  });

  testWidgets('text popup types a value and modal mode opens/closes', (
    tester,
  ) async {
    await start(tester);
    await tester.tap(find.text('打开文本反馈'));
    await openSettled(tester);
    await tester.enterText(find.byType(SemiTextArea), '有个小问题');
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('提交'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(statusText(tester), '已提交文本反馈。');

    await tester.tap(find.text('打开 Modal 反馈'));
    await openSettled(tester);
    expect(find.text('为什么给出这个评分？'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('为什么给出这个评分？'), findsNothing);
    // 取消只关闭（demo 的 onCancel 翻 visible），状态行保持上一条。
    expect(statusText(tester), '已提交文本反馈。');
  });
}
