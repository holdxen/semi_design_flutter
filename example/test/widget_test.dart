import 'package:example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  testWidgets('Spin example starts in the light theme', (tester) async {
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    expect(find.byType(SemiTitle), findsNWidgets(5));
    final heading = find.text('尺寸');
    expect(Directionality.of(tester.element(heading)), TextDirection.ltr);
    expect(SemiTheme.of(tester.element(heading)).dark, isFalse);
    expect(
      tester.widget<ColoredBox>(find.byType(ColoredBox).first).color,
      const SemiThemeData.light().colors.colorBg0,
    );
    expect(find.byType(SemiSpin), findsNWidgets(7));
  });
}
