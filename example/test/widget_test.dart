import 'package:example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  testWidgets('Steps example starts in the light theme', (tester) async {
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    expect(find.text('basic 简版'), findsOneWidget);
    final heading = find.text('nav 导航式');
    expect(Directionality.of(tester.element(heading)), TextDirection.ltr);
    expect(SemiTheme.of(tester.element(heading)).dark, isFalse);
    expect(find.byType(SemiSteps), findsWidgets);
  });
}
