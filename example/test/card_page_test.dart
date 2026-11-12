import 'package:example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

SemiCard card(WidgetTester tester, String key) =>
    tester.widget<SemiCard>(keyed(key));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const MyApp());
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
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
    for (final title in ['基础用法', '阴影', '边框与分隔线', '封面与 Meta', '加载状态', '局部主题']) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    await tester.ensureVisible(keyed('theme-card'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(keyed('theme-card').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('basic card exposes title actions and footer', (tester) async {
    await start(tester);
    final basic = card(tester, 'basic-card');
    expect(basic.title, '卡片标题');
    expect(basic.actions, hasLength(2));
    expect(basic.footer, isNotNull);
    expect(basic.footerLine, isTrue);
    expect(basic.headerExtraContent, isNotNull);
    expect(find.text('卡片标题'), findsOneWidget);
    expect(find.text('卡片脚注'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shadow border and separator flags match the demos', (
    tester,
  ) async {
    await start(tester);
    expect(card(tester, 'shadow-none').shadows, isNull);
    expect(card(tester, 'shadow-hover').shadows, SemiCardShadows.hover);
    expect(card(tester, 'shadow-always').shadows, SemiCardShadows.always);
    expect(card(tester, 'borderless-card').bordered, isFalse);
    expect(card(tester, 'lines-card').footerLine, isTrue);
    expect(card(tester, 'no-header-line-card').headerLine, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cover and meta render with avatar and descriptions', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('cover-card'));
    await tester.pump(const Duration(milliseconds: 100));
    final cover = card(tester, 'cover-card');
    expect(cover.cover, isNotNull);
    expect(cover.body, isA<SemiCardMeta>());
    final meta = cover.body! as SemiCardMeta;
    expect(meta.title, 'Meta 标题');
    expect(meta.description, 'Meta 描述文字');
    expect(meta.avatar, isNotNull);
    expect(find.text('Meta 描述文字'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('loading toggle swaps body with the skeleton placeholder', (
    tester,
  ) async {
    await start(tester);
    expect(card(tester, 'loading-card').loading, isTrue);
    expect(find.text('这段内容在 loading 时被骨架占位替换。'), findsNothing);
    await tap(tester, keyed('toggle-loading'));
    expect(card(tester, 'loading-card').loading, isFalse);
    expect(find.text('这段内容在 loading 时被骨架占位替换。'), findsOneWidget);
    expect(find.textContaining('loading: false'), findsOneWidget);
    await tap(tester, keyed('toggle-loading'));
    expect(card(tester, 'loading-card').loading, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('local theme values resolve on the theme card', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('theme-card'));
    await tester.pump(const Duration(milliseconds: 100));
    final theme = SemiCardTheme.resolve(tester.element(keyed('theme-card')));
    expect(theme.radiusCard, 16);
    expect(theme.colorCardTitleText, const Color(0xff7b61ff));
    expect(theme.spacingCardPadding, 28);
    expect(tester.takeException(), isNull);
  });
}
