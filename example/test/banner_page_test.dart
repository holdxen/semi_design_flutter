import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

import 'package:example/pages/banner.dart';

void main() {
  testWidgets('BannerPage shows every banner example', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SemiApp(home: BannerPage()));

    expect(tester.takeException(), isNull);
    for (final title in [
      '四种类型',
      '非全屏模式（in-container）',
      '仅标题 / 仅描述',
      '自定义图标与关闭',
      '额外内容',
      '数字 0 内容渲染',
    ]) {
      expect(find.text(title), findsOneWidget);
    }
    final banners = tester.widgetList<SemiBanner>(find.byType(SemiBanner));
    expect(banners.length, 12);
    expect(
      banners.where((b) => b.type == SemiBannerType.danger).length,
      2,
    );
    expect(banners.where((b) => !b.fullMode).length, 3);
    expect(banners.where((b) => b.bordered).length, 1);

    // closable: false 没有关闭按钮。
    expect(
      find.descendant(
        of: find.widgetWithText(SemiBanner, '不可关闭'),
        matching: find.byType(SemiButton),
      ),
      findsNothing,
    );

    // 关闭会隐藏横幅。
    final closable = find.widgetWithText(SemiBanner, '部署完成');
    expect(closable, findsOneWidget);
    await tester.ensureVisible(closable);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: closable, matching: find.byType(SemiButton)),
    );
    await tester.pump();
    expect(find.widgetWithText(SemiBanner, '部署完成'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
