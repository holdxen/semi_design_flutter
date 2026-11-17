import 'dart:io';
import 'dart:ui' show SemanticsRole;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show Material;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
  double? width,
  bool overlay = false,
}) {
  final body = Center(
    child: width == null ? child : SizedBox(width: width, child: child),
  );
  return Directionality(
    textDirection: direction,
    child: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      // Only the tooltip test needs an overlay (OverlayEntry does not rebuild
      // on pumpWidget, so tests that re-pump keep the tree outside one).
      child: overlay
          ? Overlay(initialEntries: [OverlayEntry(builder: (context) => body)])
          : body,
    ),
  );
}

const hostWidth = 300.0;

/// Long enough to fill the title row and ellipsize at every tested width.
const longTitle = '这是一个非常长的卡片标题用来触发单行省略行为一二三四五六七八九十';

const _kCover = Key('cover');
const _kAvatar = Key('avatar');
const _kA1 = Key('a1');
const _kA2 = Key('a2');

final lightTheme = const SemiThemeData.light();

SemiResolvedCardThemeData resolve() =>
    const SemiCardThemeData().resolve(lightTheme);

AnimatedContainer shell(WidgetTester tester) =>
    tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));

BoxDecoration shellBox(WidgetTester tester) =>
    shell(tester).decoration! as BoxDecoration;

/// The painted shell decoration — unlike [shellBox] this reflects the running
/// AnimatedContainer interpolation, i.e. the mid-transition value.
BoxDecoration paintedShell(WidgetTester tester) {
  for (final box in tester.widgetList<DecoratedBox>(
    find.byType(DecoratedBox),
  )) {
    final decoration = box.decoration;
    if (decoration is BoxDecoration &&
        decoration.color == resolve().colorCardBgDefault) {
      return decoration;
    }
  }
  fail('shell DecoratedBox not found');
}

List<Container> decoratedContainers(WidgetTester tester) => tester
    .widgetList<Container>(find.byType(Container))
    .where((container) => container.decoration is BoxDecoration)
    .toList();

Border? borderOf(Container container) =>
    (container.decoration as BoxDecoration).border as Border?;

bool hasOnlyBottomBorder(Container container) {
  final border = borderOf(container);
  return border != null &&
      border.bottom != BorderSide.none &&
      border.top == BorderSide.none &&
      border.left == BorderSide.none &&
      border.right == BorderSide.none;
}

bool hasOnlyTopBorder(Container container) {
  final border = borderOf(container);
  return border != null &&
      border.top != BorderSide.none &&
      border.bottom == BorderSide.none &&
      border.left == BorderSide.none &&
      border.right == BorderSide.none;
}

/// The style the card wired into the [SemiText] wrapping [text]; `find.text`
/// matches SemiText's inner Text, so look it up through its ancestor.
TextStyle semiTextStyleOf(WidgetTester tester, String text) => tester
    .widget<SemiText>(
      find.ancestor(of: find.text(text), matching: find.byType(SemiText)),
    )
    .style!;

Future<TestGesture> mouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

void main() {
  test('theme defaults merge equality and live resolve', () {
    const base = SemiCardThemeData();
    final light = base.resolve(lightTheme);
    // color (6)
    expect(light.colorCardBgDefault, lightTheme.colors.colorBg0);
    expect(light.colorCardBorder, lightTheme.colors.colorBorder);
    expect(light.colorCardTitleText, lightTheme.colors.colorText0);
    expect(light.colorCardDescriptionText, lightTheme.colors.colorText2);
    expect(light.colorCardExtraText, lightTheme.colors.colorText0);
    expect(light.colorCardBodyText, lightTheme.colors.colorText1);
    // font (8)
    expect(
      light.fontCardDefaultFontWeight,
      lightTheme.typography.fontWeightRegular,
    );
    expect(light.fontCardExtraFontWeight, FontWeight.w700);
    expect(light.fontCardTitleFontWeight, FontWeight.w700);
    expect(light.fontCardDefaultLineHeight, 20);
    expect(light.fontCardTitleLineHeight, 22);
    expect(
      light.fontCardDefaultFontSize,
      lightTheme.typography.fontSizeRegular,
    );
    expect(light.fontCardDefaultFontSize, 14);
    expect(light.fontCardExtraFontSize, lightTheme.typography.fontSizeHeading6);
    expect(light.fontCardExtraFontSize, 16);
    expect(light.fontCardTitleFontSize, lightTheme.typography.fontSizeHeading6);
    expect(light.fontCardTitleFontSize, 16);
    // spacing (4)
    expect(light.spacingCardPadding, 20);
    expect(light.spacingCardMargin, 20);
    expect(light.spacingCardAvatarMarginRight, 12);
    expect(light.spacingCardGroupCardMargin, -1);
    // width / radius / shadow / motion (1 each)
    expect(light.widthCardBorder, 1);
    expect(light.radiusCard, lightTheme.radius.borderRadiusMedium.value);
    expect(light.shadowCard, lightTheme.shadows.shadowElevated);
    expect(
      light.motionCardTransitionDuration,
      const Duration(milliseconds: 300),
    );
    // dark mode re-resolves through the dark tokens
    const darkTheme = SemiThemeData.dark();
    final dark = base.resolve(darkTheme);
    expect(dark.colorCardBgDefault, darkTheme.colors.colorBg0);
    expect(dark.colorCardBgDefault, isNot(light.colorCardBgDefault));
    expect(dark.colorCardBodyText, darkTheme.colors.colorText1);
    expect(dark.shadowCard, darkTheme.shadows.shadowElevated);
    expect(dark.shadowCard, isNot(light.shadowCard));
    expect(dark.fontCardDefaultLineHeight, 20);
    expect(dark.radiusCard, darkTheme.radius.borderRadiusMedium.value);
    // merge / copyWith / equality
    const patch = SemiCardThemeData(
      spacingCardPadding: 40,
      fontCardDefaultLineHeight: 24,
      colorCardBgDefault: Color(0xff010203),
    );
    expect(base.merge(null), base);
    expect(base.merge(patch), patch);
    expect(patch.merge(base), patch);
    expect(
      patch.merge(const SemiCardThemeData(spacingCardMargin: 30)),
      const SemiCardThemeData(
        spacingCardPadding: 40,
        spacingCardMargin: 30,
        fontCardDefaultLineHeight: 24,
        colorCardBgDefault: Color(0xff010203),
      ),
    );
    expect(patch.copyWith(), patch);
    expect(
      patch,
      const SemiCardThemeData(
        colorCardBgDefault: Color(0xff010203),
        spacingCardPadding: 40,
        fontCardDefaultLineHeight: 24,
      ),
    );
    expect(
      patch.hashCode,
      const SemiCardThemeData(
        colorCardBgDefault: Color(0xff010203),
        spacingCardPadding: 40,
        fontCardDefaultLineHeight: 24,
      ).hashCode,
    );
    expect(patch == base, isFalse);
    // resolve keeps the untouched fields on defaults
    final resolved = patch.resolve(darkTheme);
    expect(resolved.spacingCardPadding, 40);
    expect(resolved.fontCardDefaultLineHeight, 24);
    expect(resolved.colorCardBgDefault, const Color(0xff010203));
    expect(resolved.spacingCardMargin, 20);
    expect(resolved.widthCardBorder, 1);
    expect(resolved.radiusCard, darkTheme.radius.borderRadiusMedium.value);
    expect(resolved.shadowCard, darkTheme.shadows.shadowElevated);
    expect(
      resolved.motionCardTransitionDuration,
      const Duration(milliseconds: 300),
    );
    // SemiComponentThemes wiring
    const themes = SemiComponentThemes(
      card: SemiCardThemeData(spacingCardGroupCardMargin: 3),
    );
    expect(const SemiComponentThemes().card, const SemiCardThemeData());
    expect(themes.copyWith().card, themes.card);
    expect(
      themes.copyWith(card: const SemiCardThemeData()).card,
      const SemiCardThemeData(),
    );
    expect(themes == const SemiComponentThemes(), isFalse);
    expect(
      themes.hashCode,
      const SemiComponentThemes(
        card: SemiCardThemeData(spacingCardGroupCardMargin: 3),
      ).hashCode,
    );
  });

  test('theme field provenance comments', () {
    final theme = File('lib/src/theme/semi_card_theme_data.dart')
        .readAsStringSync();
    final widget = File('lib/src/components/semi_card.dart').readAsStringSync();
    const declarations = [
      r'$color-card-bg-default: var(--semi-color-bg-0)',
      r'$color-card-border: var(--semi-color-border)',
      r'$color-card_title-text: var(--semi-color-text-0)',
      r'$color-card_description-text: var(--semi-color-text-2)',
      r'$color-card_extra-text: var(--semi-color-text-0)',
      r'$color-card_body-text: var(--semi-color-text-1)',
      r'$font-card_default-fontWeight: $font-weight-regular',
      r'$font-card_extra-fontWeight: 700',
      r'$font-card_title-fontWeight: 700',
      r'$font-card_default-lineHeight: 20px',
      r'$font-card_title-lineHeight: 22px',
      r'$font-card_default-fontSize: $font-size-regular',
      r'$font-card_extra-fontSize: $font-size-header-6',
      r'$font-card_title-fontSize: $font-size-header-6',
      r'$radius-card: var(--semi-border-radius-medium)',
      r'$motion-card-transition_duration: 300ms',
      r'$width-card-border: $border-thickness-control',
      r'$shadow-card: var(--semi-shadow-elevated)',
      r'$spacing-card-padding: $spacing-base-loose',
      r'$spacing-card-margin: $spacing-base-loose',
      r'$spacing-card_avatar-marginRight: $spacing-base-tight',
      r'$spacing-cardGroup_card-margin: -1px',
    ];
    // 1 INTERNAL plus the 另列 hardcode INTERNAL entries of
    // tool/generate_card.py (HARDCODES), each documented in the widget.
    const internals = [
      r'$z-card_hover: 1', // zCardHover
      r'spacing={12}', // actionsGap
      r'width: 100%', // coverFullWidth
      r'letter-spacing: 0em', // letterSpacing
      r'height: $height-skeleton_title', // loadingTitleHeight
      r'height: $height-skeleton_li', // loadingRowHeight
      r'margin-bottom: $spacing-skeleton_li-marginBottom', // loadingRowGap
      r'width: 60%', // loadingLastRowWidthFactor
      r'background: $color-skeleton_default-bg-default', // loadingFill
      r'border-radius: $radius-skeleton_item', // loadingRadius
      r'cursor: pointer', // shadowsCursor
    ];
    // 23 = 22 FIELDS + 1 INTERNAL(zCardHover).
    expect(declarations.length, 22);
    expect(internals.first, r'$z-card_hover: 1');
    expect(declarations.length + 1, 23);
    for (final declaration in declarations) {
      expect(theme, contains(declaration));
    }
    for (final internal in internals) {
      expect(widget, contains(internal));
    }
    expect(theme, contains('packages/semi-foundation/card/variables.scss'));
    expect(widget, contains('packages/semi-ui/card/index.tsx'));
    expect(widget, contains('packages/semi-ui/card/meta.tsx'));
    expect(widget, contains('packages/semi-foundation/card/{card,rtl}.scss'));
    expect(widget, contains('packages/semi-foundation/skeleton/skeleton.scss'));
    expect(theme, contains('Generated by tool/generate_card.py'));
  });

  testWidgets('application level and nested local patches merge', (
    tester,
  ) async {
    Widget build() => host(
      width: hostWidth,
      SemiTheme(
        data: const SemiThemeData.light(
          components: SemiComponentThemes(
            card: SemiCardThemeData(
              spacingCardPadding: 30,
              colorCardBgDefault: Color(0xff111111),
            ),
          ),
        ),
        child: SemiCardTheme(
          data: const SemiCardThemeData(
            spacingCardPadding: 50,
            spacingCardMargin: 40,
          ),
          child: SemiCardTheme(
            data: const SemiCardThemeData(spacingCardMargin: 25),
            child: const SemiCard(
              bordered: false,
              title: longTitle,
              headerExtraContent: Text('E'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(build());
    final card = tester.getRect(find.byType(SemiCard));
    final title = tester.getRect(find.text(longTitle));
    final extra = tester.getRect(find.text('E'));
    // Innermost spacingCardPadding 50 wins the header padding.
    expect(title.top - card.top, 50);
    // Innermost spacingCardMargin 25 wins the title-extra gap.
    expect(extra.left - title.right, 25);
    // Application level colorCardBgDefault survives un-patched locals.
    expect(shellBox(tester).color, const Color(0xff111111));
    final context = tester.element(find.byType(SemiCard));
    expect(SemiCardTheme.resolve(context).spacingCardPadding, 50);
    expect(SemiCardTheme.resolve(context).spacingCardMargin, 25);
    expect(
      SemiCardTheme.resolve(context).colorCardBgDefault,
      const Color(0xff111111),
    );
    expect(SemiCardTheme.maybeOf(context), isNotNull);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('local patches survive capture and globals re-resolve', (
    tester,
  ) async {
    const card = SemiCard(
      bordered: false,
      title: longTitle,
      headerExtraContent: Text('E'),
    );
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCardTheme(
          data: SemiCardThemeData(
            spacingCardPadding: 33,
            spacingCardMargin: 15,
          ),
          child: card,
        ),
      ),
    );
    final context = tester.element(find.byType(SemiCard));
    expect(SemiCardTheme.maybeOf(context), isNotNull);
    final captured = InheritedTheme.captureAll(context, card);
    await tester.pumpWidget(
      host(
        width: hostWidth,
        SemiTheme(
          data: const SemiThemeData.light(
            components: SemiComponentThemes(
              card: SemiCardThemeData(
                spacingCardPadding: 44,
                colorCardBgDefault: Color(0xff222222),
              ),
            ),
          ),
          child: captured,
        ),
      ),
    );
    // Captured local patches survive; application data re-resolves.
    final rect = tester.getRect(find.byType(SemiCard));
    final title = tester.getRect(find.text(longTitle));
    final extra = tester.getRect(find.text('E'));
    expect(title.top - rect.top, 33);
    expect(extra.left - title.right, 15);
    expect(shellBox(tester).color, const Color(0xff222222));
    final context2 = tester.element(find.byType(SemiCard));
    expect(SemiCardTheme.resolve(context2).spacingCardPadding, 33);
    expect(SemiCardTheme.resolve(context2).spacingCardMargin, 15);
    expect(
      SemiCardTheme.resolve(context2).colorCardBgDefault,
      const Color(0xff222222),
    );
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('patches cross SemiTheme boundary and update in same mode', (
    tester,
  ) async {
    Widget build(double padding) => host(
      width: hostWidth,
      SemiCardTheme(
        data: SemiCardThemeData(spacingCardPadding: padding),
        child: const SemiTheme(
          data: SemiThemeData.light(),
          child: SemiCardTheme(
            data: SemiCardThemeData(spacingCardMargin: 15),
            child: SemiCard(
              bordered: false,
              title: longTitle,
              headerExtraContent: Text('E'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(build(30));
    var rect = tester.getRect(find.byType(SemiCard));
    var title = tester.getRect(find.text(longTitle));
    var extra = tester.getRect(find.text('E'));
    expect(title.top - rect.top, 30);
    expect(extra.left - title.right, 15);
    // Rebuild with the same values: geometry is stable.
    await tester.pumpWidget(build(30));
    rect = tester.getRect(find.byType(SemiCard));
    title = tester.getRect(find.text(longTitle));
    expect(title.top - rect.top, 30);
    // Same-mode update re-resolves the new value.
    await tester.pumpWidget(build(36));
    rect = tester.getRect(find.byType(SemiCard));
    title = tester.getRect(find.text(longTitle));
    extra = tester.getRect(find.text('E'));
    expect(title.top - rect.top, 36);
    expect(extra.left - title.right, 15);
    // Capture keeps the rendered result out of the tree.
    final context = tester.element(find.byType(SemiCard));
    final captured = InheritedTheme.captureAll(
      context,
      const SemiCard(
        bordered: false,
        title: longTitle,
        headerExtraContent: Text('E'),
      ),
    );
    await tester.pumpWidget(host(width: hostWidth, captured));
    rect = tester.getRect(find.byType(SemiCard));
    title = tester.getRect(find.text(longTitle));
    expect(title.top - rect.top, 36);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('theme metrics drive the rendered geometry', (tester) async {
    final theme = resolve();
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCard(
          title: 'T',
          headerExtraContent: Text('E'),
          cover: SizedBox(height: 30, key: _kCover),
          body: SemiCardMeta(
            avatar: SizedBox(width: 10, height: 10, key: _kAvatar),
            title: 'M',
            description: 'D',
          ),
          actions: [
            Text('A1', key: _kA1),
            Text('A2', key: _kA2),
          ],
          footer: Text('F'),
          footerLine: true,
        ),
      ),
    );
    // Root decoration: color, radius, border, 300ms motion.
    final box = shellBox(tester);
    expect(box.color, theme.colorCardBgDefault);
    expect(box.borderRadius, BorderRadius.circular(theme.radiusCard));
    expect(shell(tester).duration, theme.motionCardTransitionDuration);
    final border = box.border! as Border;
    expect(border.top.width, theme.widthCardBorder);
    expect(border.top.color, theme.colorCardBorder);
    // Clip radius: CSS `overflow: hidden` clips at the padding-box curve.
    final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
    expect(
      clip.borderRadius,
      BorderRadius.circular(theme.radiusCard - theme.widthCardBorder),
    );
    // Border-box: content is inset by the border width.
    final card = tester.getRect(find.byType(SemiCard));
    final title = tester.getRect(find.text('T'));
    expect(
      title.top - card.top,
      theme.widthCardBorder + theme.spacingCardPadding,
    );
    // Header title-extra gap drives from spacingCardMargin.
    final extra = tester.getRect(find.text('E'));
    expect(extra.left - title.right, theme.spacingCardMargin);
    // Meta avatar gap from spacingCardAvatarMarginRight.
    final avatar = tester.getRect(find.byKey(_kAvatar));
    final metaTitle = tester.getRect(find.text('M'));
    expect(metaTitle.left - avatar.right, theme.spacingCardAvatarMarginRight);
    // Meta title metrics: fontCardTitleFontSize/Weight/LineHeight.
    final metaStyle = semiTextStyleOf(tester, 'M');
    expect(metaStyle.fontSize, theme.fontCardTitleFontSize);
    expect(metaStyle.fontWeight, theme.fontCardTitleFontWeight);
    expect(
      metaStyle.height,
      theme.fontCardTitleLineHeight / theme.fontCardTitleFontSize,
    );
    expect(metaStyle.color, theme.colorCardTitleText);
    // Meta description metrics: fontCardDefault* + colorCardDescriptionText.
    final descriptionStyle = semiTextStyleOf(tester, 'D');
    expect(descriptionStyle.fontSize, theme.fontCardDefaultFontSize);
    expect(descriptionStyle.fontWeight, theme.fontCardDefaultFontWeight);
    expect(
      descriptionStyle.height,
      theme.fontCardDefaultLineHeight / theme.fontCardDefaultFontSize,
    );
    expect(descriptionStyle.color, theme.colorCardDescriptionText);
    // Body default text style merges the root metrics and body color.
    final bodyStyle = DefaultTextStyle.of(tester.element(find.text('D'))).style;
    expect(bodyStyle.fontSize, theme.fontCardDefaultFontSize);
    expect(bodyStyle.fontWeight, theme.fontCardDefaultFontWeight);
    expect(
      bodyStyle.height,
      theme.fontCardDefaultLineHeight / theme.fontCardDefaultFontSize,
    );
    expect(bodyStyle.color, theme.colorCardBodyText);
    // Extra text metrics through the header DefaultTextStyle.
    final extraStyle = DefaultTextStyle.of(tester.element(find.text('E')))
        .style;
    expect(extraStyle.fontSize, theme.fontCardExtraFontSize);
    expect(extraStyle.fontWeight, theme.fontCardExtraFontWeight);
    expect(
      extraStyle.height,
      theme.fontCardDefaultLineHeight / theme.fontCardExtraFontSize,
    );
    expect(extraStyle.color, theme.colorCardExtraText);
    // Actions: Wrap gap 12 (硬编码 INTERNAL) and the block offsets.
    final wrap = tester.widget<Wrap>(find.byType(Wrap));
    expect(wrap.spacing, 12);
    expect(wrap.runSpacing, 12);
    final a1 = tester.getRect(find.byKey(_kA1));
    final a2 = tester.getRect(find.byKey(_kA2));
    expect(a2.left - a1.right, 12);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('sections render in header cover body footer order', (
    tester,
  ) async {
    final theme = resolve();
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCard(
          bordered: false,
          title: 'T',
          cover: SizedBox(height: 30, key: _kCover),
          body: Text('B'),
          footer: Text('F'),
        ),
      ),
    );
    final card = tester.getRect(find.byType(SemiCard));
    final title = tester.getRect(find.text('T'));
    final cover = tester.getRect(find.byKey(_kCover));
    final body = tester.getRect(find.text('B'));
    final footer = tester.getRect(find.text('F'));
    // Layout order: header, cover, body, footer.
    expect(title.top, lessThan(cover.top));
    expect(cover.bottom, lessThan(body.top));
    expect(body.bottom, lessThan(footer.top));
    // Default section paddings (bordered false, headerLine true).
    expect(title.top - card.top, theme.spacingCardPadding);
    // `> * { display: block; width: 100% }`: the cover fills the card.
    expect(cover.left, card.left);
    expect(cover.width, card.width);
    // Body opens one body padding after the cover.
    expect(body.top - cover.bottom, theme.spacingCardPadding);
    // Footer opens after the body padding and its own (footerLine false).
    expect(footer.top - body.bottom, 2 * theme.spacingCardPadding);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('headerLine footerLine and actions borders', (tester) async {
    final theme = resolve();
    // headerLine true (default): a bottom border on the header container.
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCard(title: 'T', body: Text('B')),
      ),
    );
    final headers = decoratedContainers(tester).where(hasOnlyBottomBorder);
    expect(headers, hasLength(1));
    final headerBorder = borderOf(headers.single)!;
    expect(headerBorder.bottom.width, theme.widthCardBorder);
    expect(headerBorder.bottom.color, theme.colorCardBorder);
    // headerLine false: the divider disappears.
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCard(title: 'T', body: Text('B'), headerLine: false),
      ),
    );
    expect(decoratedContainers(tester).where(hasOnlyBottomBorder), isEmpty);
    // footerLine true: a top border on the footer container (no margin).
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCard(body: Text('B'), footer: Text('F'), footerLine: true),
      ),
    );
    final footers = decoratedContainers(tester).where(
      (container) => hasOnlyTopBorder(container) && container.margin == null,
    );
    expect(footers, hasLength(1));
    expect(borderOf(footers.single)!.top.width, theme.widthCardBorder);
    expect(borderOf(footers.single)!.top.color, theme.colorCardBorder);
    // footerLine false (default): no footer divider.
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCard(body: Text('B'), footer: Text('F')),
      ),
    );
    expect(
      decoratedContainers(tester).where(
        (container) => hasOnlyTopBorder(container) && container.margin == null,
      ),
      isEmpty,
    );
    // Actions block: top border on the margined container.
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCard(body: Text('B'), actions: [Text('A')]),
      ),
    );
    final actions = decoratedContainers(tester).where(
      (container) => hasOnlyTopBorder(container) && container.margin != null,
    );
    expect(actions, hasLength(1));
    expect(borderOf(actions.single)!.top.width, theme.widthCardBorder);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('bordered toggle and border-box content inset', (tester) async {
    final theme = resolve();
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCard(title: 'T', body: Text('B')),
      ),
    );
    final border = shellBox(tester).border! as Border;
    expect(border.top.width, theme.widthCardBorder);
    expect(border.top.color, theme.colorCardBorder);
    final card = tester.getRect(find.byType(SemiCard));
    final title = tester.getRect(find.text('T'));
    expect(
      title.top - card.top,
      theme.widthCardBorder + theme.spacingCardPadding,
    );
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCard(title: 'T', body: Text('B'), bordered: false),
      ),
    );
    // The AnimatedContainer animates the decoration (and its border inset)
    // over motionCardTransitionDuration.
    await tester.pump(const Duration(milliseconds: 300));
    expect(shellBox(tester).border, isNull);
    final card2 = tester.getRect(find.byType(SemiCard));
    final title2 = tester.getRect(find.text('T'));
    expect(title2.top - card2.top, theme.spacingCardPadding);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('cover is full width and corner clipped', (tester) async {
    final theme = resolve();
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCard(
          cover: SizedBox(height: 30, key: _kCover),
          body: Text('B'),
        ),
      ),
    );
    final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
    expect(
      clip.borderRadius,
      BorderRadius.circular(theme.radiusCard - theme.widthCardBorder),
    );
    expect(
      find.descendant(
        of: find.byType(ClipRRect),
        matching: find.byKey(_kCover),
      ),
      findsOneWidget,
    );
    // Full width inside the border (CSS border-box).
    final card = tester.getRect(find.byType(SemiCard));
    final cover = tester.getRect(find.byKey(_kCover));
    expect(cover.left, card.left + theme.widthCardBorder);
    expect(cover.width, card.width - 2 * theme.widthCardBorder);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('string title is heading 6 single line ellipsis', (tester) async {
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCard(title: 'T', body: Text('B')),
      ),
    );
    final title = tester.widget<SemiTitle>(find.byType(SemiTitle));
    expect(title.data, 'T');
    expect(title.heading, 6);
    expect(title.maxLines, 1);
    expect(title.overflow, TextOverflow.ellipsis);
    // A Widget title is placed as-is.
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCard(
          title: Text('W', key: Key('w')),
          body: Text('B'),
        ),
      ),
    );
    expect(find.byType(SemiTitle), findsNothing);
    expect(find.byKey(const Key('w')), findsOneWidget);
    // Only String and Widget titles are accepted.
    expect(() => SemiCard(title: 5), throwsAssertionError);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('string title shows the full text tooltip on hover', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        width: hostWidth,
        overlay: true,
        const SemiCard(title: longTitle, body: Text('B')),
      ),
    );
    final gesture = await mouse(tester);
    await gesture.moveTo(tester.getCenter(find.byType(SemiTitle)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 49));
    expect(find.byType(SemiTooltipPopup), findsNothing);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    await tester.pump();
    expect(find.byType(SemiTooltipPopup), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SemiTooltipPopup),
        matching: find.text(longTitle),
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('header covers the title row and slots keep their order', (
    tester,
  ) async {
    // `header` replaces the whole title row (title + headerExtraContent).
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCard(
          title: 'T',
          headerExtraContent: Text('E'),
          header: Text('H'),
        ),
      ),
    );
    expect(find.text('H'), findsOneWidget);
    expect(find.text('T'), findsNothing);
    expect(find.text('E'), findsNothing);
    // The extra sits at the row tail after the title with the margin gap.
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCard(
          bordered: false,
          title: longTitle,
          headerExtraContent: Text('E'),
        ),
      ),
    );
    final title = tester.getRect(find.text(longTitle));
    final extra = tester.getRect(find.text('E'));
    expect(extra.left - title.right, resolve().spacingCardMargin);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('section paddings override and add up', (tester) async {
    final theme = resolve();
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCard(
          bordered: false,
          headerPadding: EdgeInsets.all(5),
          bodyPadding: EdgeInsets.all(6),
          footerPadding: EdgeInsets.all(7),
          title: 'T',
          body: Text('B'),
          footer: Text('F'),
        ),
      ),
    );
    final card = tester.getRect(find.byType(SemiCard));
    final title = tester.getRect(find.text('T'));
    final body = tester.getRect(find.text('B'));
    final footer = tester.getRect(find.text('F'));
    expect(title.top - card.top, 5);
    // Header padding bottom + headerLine border + body padding top.
    expect(body.top - title.bottom, 5 + theme.widthCardBorder + 6);
    expect(footer.top - body.bottom, 6 + 7);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('actions group is a 12-gap bordered row under the body', (
    tester,
  ) async {
    final theme = resolve();
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCard(
          bordered: false,
          body: Text('B'),
          actions: [
            Text('A1', key: _kA1),
            Text('A2', key: _kA2),
          ],
        ),
      ),
    );
    final wrap = tester.widget<Wrap>(find.byType(Wrap));
    expect(wrap.spacing, 12);
    expect(wrap.runSpacing, 12);
    final a1 = tester.getRect(find.byKey(_kA1));
    final a2 = tester.getRect(find.byKey(_kA2));
    expect(a2.left - a1.right, 12);
    final body = tester.getRect(find.text('B'));
    // `margin-top: $spacing-card-margin` + `border-top` + `padding-top`.
    expect(
      a1.top - body.bottom,
      theme.spacingCardMargin +
          theme.widthCardBorder +
          theme.spacingCardPadding,
    );
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('meta layout and dual state', (tester) async {
    final theme = resolve();
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCard(
          body: SemiCardMeta(
            avatar: SizedBox(width: 10, height: 10, key: _kAvatar),
            title: 'M',
            description: 'D',
          ),
        ),
      ),
    );
    final avatar = tester.getRect(find.byKey(_kAvatar));
    final title = tester.getRect(find.text('M'));
    final description = tester.getRect(find.text('D'));
    // `.semi-card-meta { align-items: center }`.
    expect(
      avatar.center.dy,
      moreOrLessEquals((title.top + description.bottom) / 2, epsilon: 0.01),
    );
    // `margin-right: $spacing-card_avatar-marginRight` on the avatar.
    expect(title.left - avatar.right, theme.spacingCardAvatarMarginRight);
    // Dual state: String slots render through SemiText with the meta metrics.
    final titleStyle = semiTextStyleOf(tester, 'M');
    expect(titleStyle.fontSize, theme.fontCardTitleFontSize);
    expect(titleStyle.fontWeight, theme.fontCardTitleFontWeight);
    expect(
      titleStyle.height,
      theme.fontCardTitleLineHeight / theme.fontCardTitleFontSize,
    );
    expect(titleStyle.color, theme.colorCardTitleText);
    final descriptionStyle = semiTextStyleOf(tester, 'D');
    expect(descriptionStyle.fontSize, theme.fontCardDefaultFontSize);
    expect(descriptionStyle.fontWeight, theme.fontCardDefaultFontWeight);
    expect(
      descriptionStyle.height,
      theme.fontCardDefaultLineHeight / theme.fontCardDefaultFontSize,
    );
    expect(descriptionStyle.color, theme.colorCardDescriptionText);
    // Widget slots are placed as-is.
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCard(
          body: SemiCardMeta(
            title: SizedBox(key: Key('t')),
            description: SizedBox(key: Key('d')),
          ),
        ),
      ),
    );
    expect(find.byType(SemiText), findsNothing);
    expect(find.byKey(const Key('t')), findsOneWidget);
    expect(find.byKey(const Key('d')), findsOneWidget);
    // Only String and Widget slots are accepted.
    expect(() => SemiCardMeta(title: 5), throwsAssertionError);
    expect(() => SemiCardMeta(description: 5), throwsAssertionError);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('shadows null hover always drive boxShadow over 300ms', (
    tester,
  ) async {
    final theme = resolve();
    // drop 层进 BoxDecoration；inset 层（dark elevated）由 SemiInsetShadow
    // 画师渲染（见差异清单）。
    final expected = theme.shadowCard.toDropBoxShadows();
    // null (default): no shadow and the deferred cursor.
    await tester.pumpWidget(
      host(width: hostWidth, const SemiCard(body: Text('B'))),
    );
    expect(shellBox(tester).boxShadow, isNull);
    expect(
      tester
          .widget<MouseRegion>(
            find.descendant(
              of: find.byType(SemiCard),
              matching: find.byType(MouseRegion),
            ),
          )
          .cursor,
      MouseCursor.defer,
    );
    // always: the shadow is applied over the 300ms decoration transition,
    // with the click cursor quirk.
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCard(body: Text('B'), shadows: SemiCardShadows.always),
      ),
    );
    expect(shellBox(tester).boxShadow, expected);
    await tester.pump(const Duration(milliseconds: 300));
    expect(paintedShell(tester).boxShadow, expected);
    expect(
      tester
          .widget<MouseRegion>(
            find.descendant(
              of: find.byType(SemiCard),
              matching: find.byType(MouseRegion),
            ),
          )
          .cursor,
      SystemMouseCursors.click,
    );
    // hover: nothing painted until pointer enter, then the 300ms transition.
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCard(body: Text('B'), shadows: SemiCardShadows.hover),
      ),
    );
    expect(shellBox(tester).boxShadow, isNull);
    await tester.pump(const Duration(milliseconds: 300));
    expect(paintedShell(tester).boxShadow, isNull);
    expect(shell(tester).duration, const Duration(milliseconds: 300));
    final gesture = await mouse(tester);
    await gesture.moveTo(tester.getCenter(find.byType(SemiCard)));
    await tester.pump();
    // Frame 0 of the transition: the target is set but nothing painted yet.
    expect(shellBox(tester).boxShadow, expected);
    expect(paintedShell(tester).boxShadow, isNull);
    await tester.pump(const Duration(milliseconds: 150));
    // Mid-flight: partially applied shadow.
    final mid = paintedShell(tester).boxShadow;
    expect(mid, isNotNull);
    expect(mid, isNot(expected));
    await tester.pump(const Duration(milliseconds: 150));
    expect(paintedShell(tester).boxShadow, expected);
    // Leave: the shadow transitions back out.
    await gesture.moveTo(const Offset(5, 5));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 150));
    expect(paintedShell(tester).boxShadow, isNull);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('loading swaps the body for the skeleton placeholder', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCard(
          title: 'T',
          cover: SizedBox(height: 30, key: _kCover),
          body: Text('B'),
          footer: Text('F'),
          loading: true,
        ),
      ),
    );
    // Body content is replaced by the placeholder.
    expect(find.text('B'), findsNothing);
    // Header, cover and footer stay untouched.
    expect(find.text('T'), findsOneWidget);
    expect(find.byKey(_kCover), findsOneWidget);
    expect(find.text('F'), findsOneWidget);
    // `<Skeleton.Title /><br /><Skeleton.Paragraph rows={3} />`: one title
    // bar and three paragraph rows.
    final blocks = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .where(
          (box) =>
              box.decoration is BoxDecoration &&
              (box.decoration as BoxDecoration).color ==
                  lightTheme.colors.colorFill0,
        );
    expect(blocks, hasLength(4));
    // Root marks the updating region (`aria-busy={loading}`).
    expect(
      tester.getSemantics(find.byType(SemiCard)).role,
      SemanticsRole.status,
    );
    // Loading false: content returns and the region is not marked.
    await tester.pumpWidget(
      host(width: hostWidth, const SemiCard(body: Text('B'))),
    );
    expect(find.text('B'), findsOneWidget);
    expect(tester.getSemantics(find.byType(SemiCard)).role, SemanticsRole.none);
    // The placeholder also shows without a body (documented deviation: the
    // upstream `children &&` gate is dropped).
    await tester.pumpWidget(
      host(width: hostWidth, const SemiCard(loading: true)),
    );
    expect(find.text('B'), findsNothing);
    final blocks2 = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .where(
          (box) =>
              box.decoration is BoxDecoration &&
              (box.decoration as BoxDecoration).color ==
                  lightTheme.colors.colorFill0,
        );
    expect(blocks2, hasLength(4));
    handle.dispose();
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('rtl mirrors the title gap and avatar gap', (tester) async {
    final theme = resolve();
    await tester.pumpWidget(
      host(
        width: hostWidth,
        direction: TextDirection.rtl,
        const SemiCard(
          bordered: false,
          title: longTitle,
          headerExtraContent: Text('E'),
          body: SemiCardMeta(
            avatar: SizedBox(width: 10, height: 10, key: _kAvatar),
            title: 'M',
          ),
        ),
      ),
    );
    final title = tester.getRect(find.text(longTitle));
    final extra = tester.getRect(find.text('E'));
    // The extra sits at the logical tail (the left in RTL) and the
    // `EdgeInsetsDirectional` title gap mirrors with it.
    expect(extra.right, title.left - theme.spacingCardMargin);
    expect(extra.left, lessThan(title.left));
    final avatar = tester.getRect(find.byKey(_kAvatar));
    final metaTitle = tester.getRect(find.text('M'));
    // Avatar at the logical start (the right in RTL), gap on its end side.
    expect(avatar.left, greaterThan(metaTitle.right));
    expect(avatar.left - metaTitle.right, theme.spacingCardAvatarMarginRight);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('text scaling keeps the height ratio line boxes', (tester) async {
    final theme = resolve();
    await tester.pumpWidget(
      host(
        width: hostWidth,
        textScale: 2,
        const SemiCard(
          bordered: false,
          title: 'T',
          body: SemiCardMeta(title: 'M', description: 'D'),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    // `height: lineHeight/fontSize` scales the line box instead of clipping.
    final description = tester.getRect(find.text('D'));
    expect(
      description.height,
      moreOrLessEquals(2 * theme.fontCardDefaultLineHeight, epsilon: 0.5),
    );
    final metaTitle = tester.getRect(find.text('M'));
    expect(
      metaTitle.height,
      moreOrLessEquals(2 * theme.fontCardTitleLineHeight, epsilon: 0.5),
    );
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('narrow and unbounded widths lay out without overflow', (
    tester,
  ) async {
    Widget card() => const SemiCard(
      title: longTitle,
      headerExtraContent: Text('E'),
      cover: SizedBox(height: 30, key: _kCover),
      body: SemiCardMeta(
        avatar: SizedBox(width: 10, height: 10, key: _kAvatar),
        title: 'M',
        description: 'D',
      ),
      actions: [
        Text('A1', key: _kA1),
        Text('A2', key: _kA2),
      ],
      footer: Text('F'),
    );
    // Narrow bounded width: ellipsis and wrapping instead of overflow.
    await tester.pumpWidget(host(width: 80, card()));
    expect(tester.takeException(), isNull);
    // Unbounded width: shrink-wrapped without RenderFlex overflow.
    await tester.pumpWidget(host(UnconstrainedBox(child: card())));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('renders without Material widgets', (tester) async {
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiCard(
          title: 'T',
          cover: SizedBox(height: 30, key: _kCover),
          body: SemiCardMeta(title: 'M', description: 'D'),
          actions: [Text('A')],
          footer: Text('F'),
          shadows: SemiCardShadows.hover,
          loading: false,
        ),
      ),
    );
    expect(find.byType(Material), findsNothing);
    expect(find.text('T'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(host(const SizedBox()));
  });
}
