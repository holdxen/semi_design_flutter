import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
}) => Directionality(
  textDirection: direction,
  child: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
    child: Center(child: child),
  ),
);

const image = SizedBox(key: ValueKey('image'), width: 50, height: 30);
const titleSlot = SizedBox(key: ValueKey('title'), width: 40, height: 20);
const descSlot = SizedBox(key: ValueKey('desc'), width: 30, height: 10);
const footerSlot = SizedBox(key: ValueKey('footer'), width: 20, height: 5);

double gap(WidgetTester tester, String above, String below) =>
    tester.getRect(find.byKey(ValueKey(below))).top -
    tester.getRect(find.byKey(ValueKey(above))).bottom;

double sideGap(WidgetTester tester, String leading, String trailing) =>
    (tester.getRect(find.byKey(ValueKey(trailing))).left -
    tester.getRect(find.byKey(ValueKey(leading))).right);

void main() {
  test('theme defaults merge equality and live resolve', () {
    const base = SemiEmptyThemeData();
    final light = base.resolve(const SemiThemeData.light());
    expect(light.spacingEmptyContentVerticalMarginTop, 24);
    expect(light.spacingEmptyContentHorizontalMarginLeft, 32);
    expect(light.spacingEmptyTitleMarginTop, 16);
    expect(light.spacingEmptyFooterMarginTop, 24);
    expect(
      light.fontEmptyTitleFontWeight,
      const SemiThemeData.light().typography.fontWeightBold,
    );
    expect(
      light.colorEmptyDescriptionTextDefault,
      const SemiThemeData.light().colors.colorText1,
    );
    final dark = base.resolve(const SemiThemeData.dark());
    expect(
      dark.colorEmptyDescriptionTextDefault,
      const SemiThemeData.dark().colors.colorText1,
    );
    expect(
      dark.colorEmptyDescriptionTextDefault,
      isNot(light.colorEmptyDescriptionTextDefault),
    );
    const patch = SemiEmptyThemeData(
      spacingEmptyTitleMarginTop: 5,
      fontEmptyTitleFontWeight: FontWeight.w300,
      colorEmptyDescriptionTextDefault: Color(0xff010203),
    );
    expect(base.merge(null), base);
    expect(base.merge(patch), patch);
    expect(patch.merge(base), patch);
    expect(
      patch.merge(const SemiEmptyThemeData(spacingEmptyFooterMarginTop: 9)),
      const SemiEmptyThemeData(
        spacingEmptyTitleMarginTop: 5,
        spacingEmptyFooterMarginTop: 9,
        fontEmptyTitleFontWeight: FontWeight.w300,
        colorEmptyDescriptionTextDefault: Color(0xff010203),
      ),
    );
    expect(patch.copyWith(), patch);
    expect(
      patch,
      const SemiEmptyThemeData(
        spacingEmptyTitleMarginTop: 5,
        fontEmptyTitleFontWeight: FontWeight.w300,
        colorEmptyDescriptionTextDefault: Color(0xff010203),
      ),
    );
    expect(
      patch.hashCode,
      const SemiEmptyThemeData(
        spacingEmptyTitleMarginTop: 5,
        fontEmptyTitleFontWeight: FontWeight.w300,
        colorEmptyDescriptionTextDefault: Color(0xff010203),
      ).hashCode,
    );
    expect(patch == base, isFalse);
    final resolved = patch.resolve(const SemiThemeData.dark());
    expect(resolved.spacingEmptyContentVerticalMarginTop, 24);
    expect(resolved.spacingEmptyFooterMarginTop, 24);
    expect(resolved.fontEmptyTitleFontWeight, FontWeight.w300);
    expect(resolved.colorEmptyDescriptionTextDefault, const Color(0xff010203));
    const themes = SemiComponentThemes(
      empty: SemiEmptyThemeData(spacingEmptyTitleMarginTop: 3),
    );
    expect(const SemiComponentThemes().empty, const SemiEmptyThemeData());
    expect(themes.copyWith().empty, themes.empty);
    expect(
      themes.copyWith(empty: const SemiEmptyThemeData()).empty,
      const SemiEmptyThemeData(),
    );
  });
  test('theme field provenance comments', () {
    final source = File('lib/src/theme/semi_empty_theme_data.dart')
        .readAsStringSync();
    for (final declaration in [
      r'$spacing-empty_content_vertical-marginTop: 24px',
      r'$spacing-empty_content_horizontal-marginLeft: 32px',
      r'$spacing-empty_title-marginTop: 16px',
      r'$spacing-empty_footer-marginTop: 24px',
      r'$font-empty_title-fontWeight: 600',
      r'$color-empty_description-text-default: var(--semi-color-text-1)',
    ]) {
      expect(source, contains(declaration));
    }
    expect(source, contains('packages/semi-foundation/empty/variables.scss'));
  });
  testWidgets('vertical gaps 24 16 24', (tester) async {
    await tester.pumpWidget(
      host(
        const SemiEmpty(
          image: image,
          title: titleSlot,
          description: descSlot,
          footer: footerSlot,
        ),
      ),
    );
    expect(gap(tester, 'image', 'title'), 24);
    expect(gap(tester, 'title', 'desc'), 16);
    expect(gap(tester, 'desc', 'footer'), 24);
    final gaps = tester
        .widgetList<SizedBox>(
          find.descendant(
            of: find.byType(SemiEmpty),
            matching: find.byWidgetPredicate(
              (w) => w is SizedBox && w.width == null,
            ),
          ),
        )
        .map((w) => w.height)
        .toList();
    expect(gaps, [24, 16, 24]);
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('horizontal gaps 32 and RTL mirror', (tester) async {
    Widget build(TextDirection direction) => host(
      const SemiEmpty(
        layout: SemiEmptyLayout.horizontal,
        image: image,
        title: titleSlot,
        description: descSlot,
        footer: footerSlot,
      ),
      direction: direction,
    );
    await tester.pumpWidget(build(TextDirection.ltr));
    expect(sideGap(tester, 'image', 'title'), 32);
    expect(gap(tester, 'title', 'desc'), 16);
    expect(gap(tester, 'desc', 'footer'), 24);
    final padding = tester.widget<Padding>(
      find.descendant(
        of: find.byType(SemiEmpty),
        matching: find.byType(Padding),
      ),
    );
    expect(
      padding.padding.resolve(TextDirection.ltr),
      const EdgeInsets.only(left: 32),
    );
    expect(
      padding.padding.resolve(TextDirection.rtl),
      const EdgeInsets.only(right: 32),
    );
    await tester.pumpWidget(build(TextDirection.rtl));
    expect(
      tester.getRect(find.byKey(const ValueKey('image'))).left -
          tester.getRect(find.byKey(const ValueKey('title'))).right,
      32,
    );
    expect(gap(tester, 'title', 'desc'), 16);
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('adjacent sibling and footer gaps', (tester) async {
    await tester.pumpWidget(
      host(const SemiEmpty(image: image, description: descSlot)),
    );
    expect(gap(tester, 'image', 'desc'), 24);
    await tester.pumpWidget(
      host(const SemiEmpty(image: image, footer: footerSlot)),
    );
    expect(gap(tester, 'image', 'footer'), 48);
    await tester.pumpWidget(host(const SemiEmpty(title: titleSlot)));
    expect(find.byKey(const ValueKey('title')), findsOneWidget);
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('application level and nested local patches merge', (
    tester,
  ) async {
    Widget build() => host(
      SemiTheme(
        data: const SemiThemeData.light(
          components: SemiComponentThemes(
            empty: SemiEmptyThemeData(
              spacingEmptyContentVerticalMarginTop: 10,
              spacingEmptyFooterMarginTop: 30,
            ),
          ),
        ),
        child: SemiEmptyTheme(
          data: const SemiEmptyThemeData(
            spacingEmptyContentVerticalMarginTop: 12,
            spacingEmptyTitleMarginTop: 7,
          ),
          child: SemiEmptyTheme(
            data: const SemiEmptyThemeData(spacingEmptyTitleMarginTop: 9),
            child: const SemiEmpty(
              image: image,
              title: titleSlot,
              description: descSlot,
              footer: footerSlot,
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(build());
    expect(gap(tester, 'image', 'title'), 12);
    expect(gap(tester, 'title', 'desc'), 9);
    expect(gap(tester, 'desc', 'footer'), 30);
    final context = tester.element(find.byType(SemiEmpty));
    expect(
      SemiEmptyTheme.resolve(context).spacingEmptyContentVerticalMarginTop,
      12,
    );
    expect(SemiEmptyTheme.resolve(context).spacingEmptyTitleMarginTop, 9);
    expect(SemiEmptyTheme.resolve(context).spacingEmptyFooterMarginTop, 30);
    expect(SemiEmptyTheme.maybeOf(context), isNotNull);
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('local patches survive capture and globals re-resolve', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        SemiEmptyTheme(
          data: const SemiEmptyThemeData(
            spacingEmptyTitleMarginTop: 8,
            spacingEmptyFooterMarginTop: 16,
          ),
          child: const SemiEmpty(
            image: image,
            title: titleSlot,
            description: descSlot,
            footer: footerSlot,
          ),
        ),
      ),
    );
    final context = tester.element(find.byType(SemiEmpty));
    expect(SemiEmptyTheme.maybeOf(context), isNotNull);
    final captured = InheritedTheme.captureAll(
      context,
      const SemiEmpty(
        image: image,
        title: titleSlot,
        description: descSlot,
        footer: footerSlot,
      ),
    );
    await tester.pumpWidget(
      host(
        SemiTheme(
          data: const SemiThemeData.light(
            components: SemiComponentThemes(
              empty: SemiEmptyThemeData(
                spacingEmptyContentVerticalMarginTop: 11,
                spacingEmptyFooterMarginTop: 30,
              ),
            ),
          ),
          child: captured,
        ),
      ),
    );
    // Captured local patches survive; target application data re-resolves.
    expect(gap(tester, 'image', 'title'), 11);
    expect(gap(tester, 'title', 'desc'), 8);
    expect(gap(tester, 'desc', 'footer'), 16);
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('patches cross SemiTheme boundary and update in same mode', (
    tester,
  ) async {
    Widget build(double footerGap) => host(
      SemiEmptyTheme(
        data: SemiEmptyThemeData(spacingEmptyFooterMarginTop: footerGap),
        child: SemiTheme(
          data: const SemiThemeData.light(),
          child: const SemiEmptyTheme(
            data: SemiEmptyThemeData(spacingEmptyTitleMarginTop: 8),
            child: SemiEmpty(
              image: image,
              title: titleSlot,
              description: descSlot,
              footer: footerSlot,
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(build(16));
    expect(gap(tester, 'title', 'desc'), 8);
    expect(gap(tester, 'desc', 'footer'), 16);
    await tester.pumpWidget(build(16));
    expect(gap(tester, 'desc', 'footer'), 16);
    await tester.pumpWidget(build(20));
    expect(gap(tester, 'title', 'desc'), 8);
    expect(gap(tester, 'desc', 'footer'), 20);
    final context = tester.element(find.byType(SemiEmpty));
    final captured = InheritedTheme.captureAll(
      context,
      const SemiEmpty(
        image: image,
        title: titleSlot,
        description: descSlot,
        footer: footerSlot,
      ),
    );
    await tester.pumpWidget(host(captured));
    expect(gap(tester, 'image', 'title'), 24);
    expect(gap(tester, 'title', 'desc'), 8);
    expect(gap(tester, 'desc', 'footer'), 20);
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('theme spacing overrides drive the gaps', (tester) async {
    await tester.pumpWidget(
      host(
        const SemiTheme(
          data: SemiThemeData.light(
            components: SemiComponentThemes(
              empty: SemiEmptyThemeData(
                spacingEmptyContentVerticalMarginTop: 5,
                spacingEmptyContentHorizontalMarginLeft: 6,
                spacingEmptyTitleMarginTop: 7,
                spacingEmptyFooterMarginTop: 8,
              ),
            ),
          ),
          child: SemiEmpty(
            image: image,
            title: titleSlot,
            description: descSlot,
            footer: footerSlot,
          ),
        ),
      ),
    );
    expect(gap(tester, 'image', 'title'), 5);
    expect(gap(tester, 'title', 'desc'), 7);
    expect(gap(tester, 'desc', 'footer'), 8);
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('title weight with and without image', (tester) async {
    final bold = const SemiThemeData.light().typography.fontWeightBold;
    await tester.pumpWidget(
      host(const SemiEmpty(image: image, title: '暂无内容', description: '换个关键词')),
    );
    var title = tester.widget<SemiTitle>(find.byType(SemiTitle));
    expect(title.heading, 4);
    expect(title.weight, bold);
    expect(title.textAlign, TextAlign.center);
    expect(tester.widget<Text>(find.text('暂无内容')).style!.fontWeight, bold);
    final description = tester
        .widgetList<SemiText>(find.byType(SemiText))
        .firstWhere((w) => w.data == '换个关键词');
    expect(
      description.style!.color,
      const SemiThemeData.light().colors.colorText1,
    );
    expect(description.textAlign, TextAlign.center);
    await tester.pumpWidget(host(const SemiEmpty(title: '暂无内容')));
    title = tester.widget<SemiTitle>(find.byType(SemiTitle));
    expect(title.heading, 6);
    expect(title.weight, FontWeight.w400);
    expect(
      tester.widget<Text>(find.text('暂无内容')).style!.fontWeight,
      FontWeight.w400,
    );
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('dark theme description color and horizontal alignment', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const SemiTheme(
          data: SemiThemeData.dark(),
          child: SemiEmpty(
            layout: SemiEmptyLayout.horizontal,
            title: '暂无内容',
            description: '换个关键词',
          ),
        ),
      ),
    );
    final description = tester
        .widgetList<SemiText>(find.byType(SemiText))
        .firstWhere((w) => w.data == '换个关键词');
    expect(
      description.style!.color,
      const SemiThemeData.dark().colors.colorText1,
    );
    expect(description.textAlign, isNull);
    expect(tester.widget<SemiTitle>(find.byType(SemiTitle)).textAlign, isNull);
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('string and widget content mix and invalid types', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const SemiEmpty(
          title: '字符串标题',
          description: descSlot,
          footer: Text('刷新'),
        ),
      ),
    );
    expect(find.text('字符串标题'), findsOneWidget);
    expect(find.byKey(const ValueKey('desc')), findsOneWidget);
    expect(find.text('刷新'), findsOneWidget);
    expect(find.byType(SemiText), findsOneWidget);
    await tester.pumpWidget(
      host(const SemiEmpty(title: titleSlot, description: '字符串描述')),
    );
    expect(find.byKey(const ValueKey('title')), findsOneWidget);
    expect(find.text('字符串描述'), findsOneWidget);
    expect(find.byType(SemiTitle), findsNothing);
    await tester.pumpWidget(host(const SemiEmpty(title: Text('任意 Widget'))));
    expect(find.text('任意 Widget'), findsOneWidget);
    expect(find.byType(SemiTitle), findsNothing);
    expect(() => SemiEmpty(title: 42), throwsAssertionError);
    expect(() => SemiEmpty(description: 42), throwsAssertionError);
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('darkModeImage selection fallback and title sizing', (
    tester,
  ) async {
    const light = SizedBox(key: ValueKey('light'), width: 10, height: 10);
    const dark = SizedBox(key: ValueKey('dark'), width: 10, height: 10);
    await tester.pumpWidget(
      host(
        const SemiTheme(
          data: SemiThemeData.dark(),
          child: SemiEmpty(image: light, darkModeImage: dark, title: '暂无内容'),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('dark')), findsOneWidget);
    expect(find.byKey(const ValueKey('light')), findsNothing);
    expect(tester.widget<SemiTitle>(find.byType(SemiTitle)).heading, 4);
    await tester.pumpWidget(
      host(
        const SemiTheme(
          data: SemiThemeData.dark(),
          child: SemiEmpty(image: light),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('light')), findsOneWidget);
    await tester.pumpWidget(
      host(const SemiEmpty(darkModeImage: dark, title: '暂无内容')),
    );
    expect(find.byKey(const ValueKey('dark')), findsNothing);
    expect(tester.widget<SemiTitle>(find.byType(SemiTitle)).heading, 6);
    await tester.pumpWidget(
      host(
        const SemiTheme(
          data: SemiThemeData.dark(),
          child: SemiEmpty(darkModeImage: dark, title: '暂无内容'),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('dark')), findsOneWidget);
    expect(tester.widget<SemiTitle>(find.byType(SemiTitle)).heading, 4);
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('narrow and unbounded constraints and text scaling', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 80,
          child: SingleChildScrollView(
            child: const SemiEmpty(
              image: SizedBox(width: 10, height: 10),
              title: '很长很长很长的标题文字很长很长很长的标题文字',
              description: '很长很长很长的描述文字很长很长很长的描述文字',
              footer: footerSlot,
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 80,
          child: SingleChildScrollView(
            child: const SemiEmpty(
              layout: SemiEmptyLayout.horizontal,
              image: SizedBox(width: 10, height: 10),
              title: '很长很长很长的标题文字很长很长很长的标题文字',
              description: '很长很长很长的描述文字很长很长很长的描述文字',
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(
      host(
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: const SemiEmpty(
            layout: SemiEmptyLayout.horizontal,
            image: SizedBox(width: 10, height: 10),
            title: '无界宽度',
            description: descSlot,
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(
      host(
        ListView(
          children: const [
            SemiEmpty(
              layout: SemiEmptyLayout.horizontal,
              image: SizedBox(width: 10, height: 10),
              title: titleSlot,
              footer: footerSlot,
            ),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(
      host(
        const SemiEmpty(
          image: image,
          title: '暂无内容',
          description: '换个关键词',
          footer: footerSlot,
        ),
        textScale: 3,
      ),
    );
    expect(
      tester.renderObject<RenderParagraph>(find.text('暂无内容')).textScaler,
      const TextScaler.linear(3),
    );
    expect(gap(tester, 'image', 'footer') > 24, isTrue);
    final gaps = tester
        .widgetList<SizedBox>(
          find.descendant(
            of: find.byType(SemiEmpty),
            matching: find.byWidgetPredicate(
              (w) => w is SizedBox && w.width == null,
            ),
          ),
        )
        .map((w) => w.height)
        .toList();
    expect(gaps, [24, 16, 24]);
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('image semantics hidden and text kept without Material', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        SemiEmpty(
          image: Semantics(
            label: '插图',
            child: const SizedBox(width: 10, height: 10),
          ),
          title: '暂无内容',
          description: '换个关键词',
          footer: Text('刷新'),
          semanticsLabel: '空状态',
        ),
      ),
    );
    expect(find.bySemanticsLabel('插图'), findsNothing);
    final label = tester.getSemantics(find.text('暂无内容')).label;
    expect(label, startsWith('空状态'));
    expect(label, contains('暂无内容'));
    expect(label, contains('换个关键词'));
    expect(label, contains('刷新'));
    expect(find.bySemanticsLabel(RegExp('空状态')), findsOneWidget);
    handle.dispose();
    await tester.pumpWidget(host(const SizedBox()));
  });
}
