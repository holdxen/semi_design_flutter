import 'package:example/pages/skeleton.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.binding.setSurfaceSize(const Size(1200, 2400));
  await tester.pumpWidget(const SemiApp(home: SkeletonPage()));
  await tester.pump(const Duration(milliseconds: 50));
}

BoxDecoration decorationOf(WidgetTester tester, Finder shape) =>
    tester
            .widget<DecoratedBox>(
              find
                  .descendant(of: shape, matching: find.byType(DecoratedBox))
                  .first,
            )
            .decoration
        as BoxDecoration;

void main() {
  testWidgets('page renders every demo section', (tester) async {
    await start(tester);
    for (final title in ['基础骨架屏', '段落行数', '头像尺寸与形状', '图片占位', 'RTL']) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    expect(find.byType(SemiSkeletonAvatar), findsWidgets);
    expect(find.byType(SemiSkeletonParagraph), findsWidgets);
    expect(find.byType(SemiSkeletonButton), findsNWidgets(2));
    expect(find.byType(SemiSkeletonImage), findsOneWidget);
  });

  testWidgets('toggle switches placeholder and real content', (tester) async {
    await start(tester);
    final card = find.byType(SemiSkeleton).first;
    expect(
      find.descendant(of: card, matching: find.byType(SemiSkeletonAvatar)),
      findsOneWidget,
    );
    expect(find.text('真实内容标题'), findsNothing);

    await tester.ensureVisible(keyed('skeleton-toggle'));
    await tester.tap(keyed('skeleton-toggle'));
    await tester.pump();
    expect(find.text('真实内容标题'), findsOneWidget);
    expect(
      find.descendant(of: card, matching: find.byType(SemiSkeletonAvatar)),
      findsNothing,
    );

    await tester.tap(keyed('skeleton-toggle'));
    await tester.pump();
    expect(find.text('真实内容标题'), findsNothing);
    expect(
      find.descendant(of: card, matching: find.byType(SemiSkeletonAvatar)),
      findsOneWidget,
    );
  });

  testWidgets('active toggle adds and removes the shimmer gradient', (
    tester,
  ) async {
    await start(tester);
    final title = find.byType(SemiSkeletonTitle).first;
    expect(decorationOf(tester, title).gradient, isNotNull);

    await tester.ensureVisible(keyed('skeleton-active-toggle'));
    await tester.tap(keyed('skeleton-active-toggle'));
    await tester.pump();
    expect(decorationOf(tester, title).gradient, isNull);
    expect(decorationOf(tester, title).color, isNotNull);
  });

  testWidgets('avatar variants render at their Sass sizes', (tester) async {
    await start(tester);
    await tester.ensureVisible(find.text('头像尺寸与形状'));
    await tester.pump(const Duration(milliseconds: 100));
    final avatars = find.descendant(
      of: keyed('skeleton-avatars'),
      matching: find.byType(SemiSkeletonAvatar),
    );
    expect(avatars, findsNWidgets(7));
    final sizes = [
      for (var i = 0; i < 5; i++) tester.getSize(avatars.at(i)).width,
    ];
    expect(sizes, [20.0, 24.0, 32.0, 48.0, 72.0]);
    final square = avatars.at(6);
    expect(tester.getSize(square), const Size(72, 72));
    expect(
      decorationOf(tester, square).borderRadius,
      BorderRadius.circular(
        const SemiThemeData.light().radius.borderRadiusSmall.value,
      ),
    );
  });

  testWidgets('RTL section renders in right-to-left direction', (tester) async {
    await start(tester);
    final rtlTitle = find.text('段落 + 头像（末行靠右）');
    await tester.ensureVisible(rtlTitle);
    await tester.pump(const Duration(milliseconds: 100));
    expect(Directionality.of(tester.element(rtlTitle)), TextDirection.rtl);
    expect(
      Directionality.of(tester.element(find.text('基础骨架屏'))),
      TextDirection.ltr,
    );
  });
}
