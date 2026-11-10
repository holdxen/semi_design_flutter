import 'package:example/main.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));
SemiProgress progress(WidgetTester tester, String key) =>
    tester.widget<SemiProgress>(keyed(key));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const MyApp());
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(keyed(key));
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(keyed(key));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  testWidgets('actual large circle keeps complete centered percentage', (
    tester,
  ) async {
    await start(tester);
    final large = find.byWidgetPredicate(
      (widget) =>
          widget is SemiProgress &&
          widget.type == SemiProgressType.circle &&
          widget.size == SemiProgressSize.large,
    );
    await tester.ensureVisible(large);
    await tester.pump();
    final text = find.descendant(of: large, matching: find.text('60%'));
    final paragraph = tester.renderObject<RenderParagraph>(text);
    expect(
      paragraph.getBoxesForSelection(
        const TextSelection(baseOffset: 0, extentOffset: 3),
      ),
      hasLength(1),
    );
    final circle = tester.getRect(
      find.descendant(of: large, matching: find.byType(CustomPaint)),
    );
    expect(circle.size, const Size(24, 24));
    final bounds = MatrixUtils.transformRect(
      paragraph.getTransformTo(null),
      paragraph.paintBounds,
    );
    expect(bounds.center.dx, closeTo(circle.center.dx, .01));
    expect(bounds.center.dy, closeTo(circle.center.dy, .01));
    expect(bounds.width, greaterThan(24));
    expect(paragraph.text.style!.fontSize, 14);
    expect(paragraph.getTransformTo(null).entry(0, 0), 1);
    expect(paragraph.getTransformTo(null).entry(1, 1), 1);
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(tester.takeException(), isNull);
  });
  testWidgets('sections fit a narrow scaled screen and scroll to the bottom', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await start(tester);
    for (final title in [
      '水平进度',
      '尺寸',
      '垂直进度',
      '环形进度',
      '阈值颜色',
      '不确定进度',
      '局部主题',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    await tester.ensureVisible(keyed('theme-progress'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(keyed('theme-progress').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('percent controls increment decrement reset and clamp', (
    tester,
  ) async {
    await start(tester);
    expect(progress(tester, 'main-progress').percent, 60);
    await tap(tester, 'increase-progress');
    expect(progress(tester, 'main-progress').percent, 70);
    await tap(tester, 'decrease-progress');
    expect(progress(tester, 'main-progress').percent, 60);
    for (var i = 0; i < 6; i++) {
      await tap(tester, 'increase-progress');
    }
    expect(progress(tester, 'main-progress').percent, 100);
    for (var i = 0; i < 12; i++) {
      await tap(tester, 'decrease-progress');
    }
    expect(progress(tester, 'main-progress').percent, 0);
    await tap(tester, 'reset-progress');
    expect(progress(tester, 'main-progress').percent, 60);
    expect(find.text('完成 60'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('indeterminate examples can be paused and restarted', (
    tester,
  ) async {
    await start(tester);
    for (final key in ['indeterminate-line', 'indeterminate-circle']) {
      expect(progress(tester, key).indeterminate, isTrue);
    }
    await tap(tester, 'toggle-indeterminate');
    for (final key in ['indeterminate-line', 'indeterminate-circle']) {
      expect(progress(tester, key).indeterminate, isFalse);
    }
    await tap(tester, 'toggle-indeterminate');
    expect(progress(tester, 'indeterminate-circle').indeterminate, isTrue);
    expect(progress(tester, 'indeterminate-line').indeterminate, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'threshold colors formatter sizes and local theme match examples',
    (tester) async {
      await start(tester);
      final colors = SemiTheme.of(tester.element(keyed('main-progress')))
          .colors;
      final threshold = progress(tester, 'threshold-progress');
      expect(threshold.strokeGradient, isFalse);
      expect(threshold.stroke!.stops.map((stop) => stop.percent), [0, 50, 100]);
      expect(threshold.stroke!.stops.map((stop) => stop.color), [
        colors.colorDanger,
        colors.colorWarning,
        colors.colorSuccess,
      ]);
      expect(find.text('完成 60'), findsOneWidget);
      await tap(tester, 'toggle-gradient');
      final interpolated = progress(tester, 'threshold-progress');
      expect(interpolated.strokeGradient, isTrue);
      expect(
        interpolated.stroke!.resolve(75, colors.colorPrimary, gradient: true),
        Color.lerp(colors.colorWarning, colors.colorSuccess, .5),
      );
      await tap(tester, 'toggle-gradient');
      expect(progress(tester, 'threshold-progress').strokeGradient, isFalse);
      final vertical = tester
          .widgetList<SemiProgress>(find.byType(SemiProgress))
          .where(
            (widget) => widget.direction == SemiProgressDirection.vertical,
          );
      expect(vertical, isNotEmpty);
      expect(vertical.every((widget) => widget.height == 160), isTrue);
      final circles = tester
          .widgetList<SemiProgress>(find.byType(SemiProgress))
          .where(
            (widget) =>
                widget.type == SemiProgressType.circle && widget.showInfo,
          );
      expect(
        circles.map((widget) => widget.size).toSet(),
        SemiProgressSize.values.toSet(),
      );
      await tester.ensureVisible(keyed('theme-progress'));
      await tester.pump(const Duration(milliseconds: 100));
      final theme = SemiProgressTheme.resolve(
        tester.element(keyed('theme-progress')),
      );
      expect(theme.horizontalHeight, 8);
      expect(theme.strokeColor, colors.colorPrimary);
      expect(theme.transitionDuration, const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    },
  );
}
