import 'package:example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

SemiTag tag(WidgetTester tester, String key) =>
    tester.widget<SemiTag>(keyed(key));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const MyApp());
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(keyed(key));
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(keyed(key));
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> tapClose(WidgetTester tester, String key) async {
  await tester.ensureVisible(keyed(key));
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(
    find.descendant(of: keyed(key), matching: find.byType(SemiIcon)),
  );
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
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
    for (final title in ['颜色', '尺寸与形状', '可关闭', '图标与头像', 'AI 色彩', '局部主题']) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    await tester.ensureVisible(keyed('theme-tag'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(keyed('theme-tag').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('palette covers all colors and type toggle applies to all', (
    tester,
  ) async {
    await start(tester);
    final colors = SemiTagColor.values;
    for (final color in colors) {
      final t = tag(tester, 'palette-${color.name}');
      expect(t.color, color);
      expect(t.type, SemiTagType.light);
    }
    await tap(tester, 'toggle-type-solid');
    for (final color in colors) {
      expect(tag(tester, 'palette-${color.name}').type, SemiTagType.solid);
    }
    await tap(tester, 'toggle-type-ghost');
    for (final color in colors) {
      expect(tag(tester, 'palette-${color.name}').type, SemiTagType.ghost);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('size and shape toggles update the demo tag', (tester) async {
    await start(tester);
    final demo = tag(tester, 'shape-demo');
    expect(demo.size, SemiTagSize.normal);
    expect(demo.shape, SemiTagShape.square);
    await tap(tester, 'toggle-size-large');
    expect(tag(tester, 'shape-demo').size, SemiTagSize.large);
    await tap(tester, 'toggle-shape-circle');
    expect(tag(tester, 'shape-demo').shape, SemiTagShape.circle);
    await tap(tester, 'toggle-size-small');
    expect(tag(tester, 'shape-demo').size, SemiTagSize.small);
    expect(tester.takeException(), isNull);
  });

  testWidgets('close interactions support default controlled and prevented', (
    tester,
  ) async {
    await start(tester);
    expect(find.text('默认关闭'), findsOneWidget);
    await tapClose(tester, 'closable-default');
    expect(find.text('默认关闭'), findsNothing);
    expect(find.textContaining('默认关闭已触发'), findsOneWidget);
    expect(tag(tester, 'closable-controlled').visible, isTrue);
    await tapClose(tester, 'closable-controlled');
    expect(tag(tester, 'closable-controlled').visible, isFalse);
    expect(find.textContaining('受控标签已隐藏'), findsOneWidget);
    await tap(tester, 'reset-controlled');
    expect(tag(tester, 'closable-controlled').visible, isTrue);
    expect(find.text('阻止关闭'), findsOneWidget);
    await tapClose(tester, 'closable-prevented');
    expect(find.text('阻止关闭'), findsOneWidget);
    expect(find.textContaining('已调用 preventDefault()'), findsOneWidget);
    await tap(tester, 'add-close-count');
    expect(find.textContaining('计数已增加到 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('icon avatar colorful gradient and theme sections render', (
    tester,
  ) async {
    await start(tester);
    expect(tag(tester, 'prefix-icon').prefixIcon, isNotNull);
    expect(tag(tester, 'suffix-icon').suffixIcon, isNotNull);
    expect(tag(tester, 'both-icons').prefixIcon, isNotNull);
    expect(tag(tester, 'both-icons').suffixIcon, isNotNull);
    expect(tag(tester, 'avatar-square').avatar, isNotNull);
    expect(tag(tester, 'avatar-circle').avatar, isNotNull);
    expect(tag(tester, 'avatar-square').avatarShape, SemiTagShape.square);
    expect(tag(tester, 'avatar-circle').avatarShape, SemiTagShape.circle);
    for (final type in SemiTagType.values) {
      final colorful = tag(tester, 'colorful-${type.name}');
      expect(colorful.colorful, isTrue);
      expect(colorful.gradient, isFalse);
      expect(colorful.type, type);
      final gradient = tag(tester, 'gradient-${type.name}');
      expect(gradient.colorful, isTrue);
      expect(gradient.gradient, isTrue);
      expect(gradient.type, type);
    }
    await tester.ensureVisible(keyed('theme-tag'));
    await tester.pump(const Duration(milliseconds: 100));
    final theme = SemiTagTheme.resolve(tester.element(keyed('theme-tag')));
    expect(theme.radiusTag, 6);
    expect(theme.heightTagLarge, 28);
    expect(theme.spacingTagLargePaddingX, 12);
    expect(tester.takeException(), isNull);
  });
}
