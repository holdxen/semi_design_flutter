import 'package:example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  testWidgets('Typography example starts with readable headings', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(tester.takeException(), isNull);
    expect(find.byType(SemiTitle), findsNWidgets(6));
    final heading = find.text('h1. Semi Design');
    expect(Directionality.of(tester.element(heading)), TextDirection.ltr);
    expect(SemiTheme.of(tester.element(heading)).dark, isFalse);
    expect(
      tester.widget<ColoredBox>(find.byType(ColoredBox).first).color,
      const SemiThemeData.light().colors.colorBg0,
    );
    for (var level = 1; level <= 6; level++) {
      expect(find.text('h$level. Semi Design'), findsOneWidget);
    }
  });

  testWidgets('Typography example fits a narrow screen and scrolls', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 240);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());
    expect(tester.takeException(), isNull);

    final lastHeading = find.text('h6. Semi Design');
    await tester.ensureVisible(lastHeading);
    await tester.pumpAndSettle();

    expect(lastHeading.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
