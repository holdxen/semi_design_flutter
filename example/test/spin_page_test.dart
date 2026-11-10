import 'package:example/pages/spin.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  Future<void> mount(WidgetTester tester) async {
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpWidget(const SemiApp(home: SpinPage()));
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('sections, three sizes, custom indicator and local theme', (
    tester,
  ) async {
    await mount(tester);
    for (final title in ['尺寸', '提示文案', '包裹内容', '自定义指示器', '局部主题']) {
      expect(find.text(title), findsOneWidget);
    }
    for (final size in SemiSpinSize.values) {
      expect(find.text(size.name), findsOneWidget);
      expect(
        tester
            .widgetList<SemiSpin>(find.byType(SemiSpin))
            .where((spin) => spin.size == size),
        isNotEmpty,
      );
    }
    final custom = tester.widget<SemiSpin>(
      find.byKey(const ValueKey('custom-spin')),
    );
    expect(custom.indicator, isA<SemiIcon>());
    final theme = SemiSpinTheme.resolve(
      tester.element(find.byKey(const ValueKey('theme-spin'))),
    );
    expect(theme.rotationDuration, const Duration(milliseconds: 1200));
    expect(
      theme.color,
      SemiTheme.of(tester.element(find.byType(SpinPage))).colors.colorSuccess,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('content stops, resumes and delays its overlay by 300ms', (
    tester,
  ) async {
    await mount(tester);
    final spin = find.byKey(const ValueKey('content-spin'));
    final toggle = find.byKey(const ValueKey('toggle-loading'));
    final delay = find.byKey(const ValueKey('toggle-delay'));
    final opacity = find.descendant(of: spin, matching: find.byType(Opacity));
    double alpha() => tester.widget<Opacity>(opacity.first).opacity;
    await tester.ensureVisible(toggle);
    await tester.pump();
    expect(alpha(), 0.5);
    await tester.tap(toggle);
    await tester.pump();
    expect(alpha(), 1);
    await tester.tap(find.byKey(const ValueKey('content-action')));
    await tester.pump();
    expect(find.text('点击次数：1'), findsOneWidget);
    await tester.tap(delay);
    await tester.pump();
    await tester.tap(toggle);
    await tester.pump();
    expect(alpha(), 1);
    await tester.pump(const Duration(milliseconds: 299));
    expect(alpha(), 1);
    await tester.pump(const Duration(milliseconds: 1));
    expect(alpha(), 0.5);
    await tester.tap(toggle);
    await tester.pump();
    expect(alpha(), 1);
    await tester.tap(toggle);
    await tester.pump();
    await tester.tap(toggle);
    await tester.pump(const Duration(milliseconds: 300));
    expect(alpha(), 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow layout wraps sizes and scrolls to the final section', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(240, 320);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await mount(tester);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byKey(const ValueKey('theme-spin')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.byKey(const ValueKey('theme-spin')).hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
