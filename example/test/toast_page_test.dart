import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

import 'package:example/pages/toast.dart';

void main() {
  testWidgets('ToastPage triggers toasts and cleans up', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SemiApp(home: ToastPage()));

    expect(tester.takeException(), isNull);
    for (final title in [
      '四种类型 + 默认',
      'Light 主题',
      '自动关闭时长',
      '堆叠与同 id 更新',
      '自定义与关闭行为',
    ]) {
      expect(find.text(title), findsOneWidget);
    }

    // 类型按钮触发对应提示。
    await tester.ensureVisible(find.text('Success'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Success'));
    await tester.pump();
    expect(find.text('保存成功'), findsOneWidget);

    SemiToast.destroyAll();
    await tester.pump();
    expect(find.text('保存成功'), findsNothing);

    // 同 id 更新：原地替换为第二条。
    await tester.ensureVisible(find.text('同 id 更新'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('同 id 更新'));
    await tester.pump();
    expect(find.text('同 id 更新前的提示'), findsNothing);
    expect(find.text('同 id 更新后的提示'), findsOneWidget);

    // 堆叠：连续三条按序排列。
    await tester.ensureVisible(find.text('连续三条'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('连续三条'));
    await tester.pump();
    expect(find.text('第一条提示'), findsOneWidget);
    expect(find.text('第二条提示'), findsOneWidget);
    expect(find.text('第三条提示'), findsOneWidget);

    SemiToast.destroyAll();
    await tester.pump();
    expect(find.text('第一条提示'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
