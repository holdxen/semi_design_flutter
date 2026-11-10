import 'package:example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  testWidgets('Divider example starts with readable headings', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(tester.takeException(), isNull);
    expect(find.byType(SemiTitle), findsNWidgets(4));
    final heading = find.text('水平实线');
    expect(Directionality.of(tester.element(heading)), TextDirection.ltr);
    expect(SemiTheme.of(tester.element(heading)).dark, isFalse);
    expect(
      tester.widget<ColoredBox>(find.byType(ColoredBox).first).color,
      const SemiThemeData.light().colors.colorBg0,
    );
    for (final title in ['水平实线', '水平虚线', '垂直实线', '垂直虚线']) {
      expect(find.text(title), findsOneWidget);
    }
  });

  testWidgets('Divider example fits a narrow screen and scrolls', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 240);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());
    expect(tester.takeException(), isNull);

    final lastHeading = find.text('这是居右文字');
    await tester.ensureVisible(lastHeading);
    await tester.pumpAndSettle();

    expect(lastHeading.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
