import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
  double? width,
}) => Directionality(
  textDirection: direction,
  child: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
    child: Center(
      child: width == null ? child : SizedBox(width: width, child: child),
    ),
  ),
);

const hostWidth = 300.0;

const items = [
  SemiDescriptionsItemData(label: '用户名', value: '张三'),
  SemiDescriptionsItemData(label: '电子邮箱', value: 'zhangsan@example.com'),
];

void main() {
  test('theme defaults merge equality and live resolve', () {
    const base = SemiDescriptionsThemeData();
    const lightTheme = SemiThemeData.light();
    final light = base.resolve(lightTheme);
    expect(light.colorDescriptionsKeyTextDefault, lightTheme.colors.colorText2);
    expect(
      light.colorDescriptionsValueTextDefault,
      lightTheme.colors.colorText0,
    );
    expect(light.fontDescriptionsLineHeight, 20);
    expect(
      light.fontDescriptionsValueFontWeight,
      lightTheme.typography.fontWeightBold,
    );
    expect(
      light.fontDescriptionsKeySmallFontSize,
      lightTheme.typography.fontSizeSmall,
    );
    expect(light.fontDescriptionsKeySmallFontSize, 12);
    expect(
      light.fontDescriptionsValueSmallFontSize,
      lightTheme.typography.fontSizeHeading6,
    );
    expect(light.fontDescriptionsValueSmallFontSize, 16);
    expect(
      light.fontDescriptionsKeyMediumFontSize,
      lightTheme.typography.fontSizeRegular,
    );
    expect(light.fontDescriptionsKeyMediumFontSize, 14);
    expect(
      light.fontDescriptionsValueMediumFontSize,
      lightTheme.typography.fontSizeHeading4,
    );
    expect(light.fontDescriptionsValueMediumFontSize, 20);
    expect(
      light.fontDescriptionsKeyLargeFontSize,
      lightTheme.typography.fontSizeRegular,
    );
    expect(light.fontDescriptionsKeyLargeFontSize, 14);
    expect(
      light.fontDescriptionsValueLargeFontSize,
      lightTheme.typography.fontSizeHeading2,
    );
    expect(light.fontDescriptionsValueLargeFontSize, 28);
    expect(light.spacingDescriptionsThPaddingRight, 24);
    expect(light.spacingDescriptionsItemPaddingBottom, 12);
    expect(light.spacingDescriptionsItemSmallPaddingRight, 48);
    expect(light.spacingDescriptionsItemMediumPaddingRight, 60);
    expect(light.spacingDescriptionsItemLargePaddingRight, 80);
    expect(light.spacingDescriptionsKeyMediumPaddingBottom, 4);
    expect(light.spacingDescriptionsKeyLargePaddingBottom, 4);
    expect(light.spacingDescriptionsValuePlainPaddingLeft, 8);
    expect(light.spacingDescriptionsItemDoublePadding, 0);
    const darkTheme = SemiThemeData.dark();
    final dark = base.resolve(darkTheme);
    expect(dark.colorDescriptionsKeyTextDefault, darkTheme.colors.colorText2);
    expect(
      dark.colorDescriptionsKeyTextDefault,
      isNot(light.colorDescriptionsKeyTextDefault),
    );
    expect(dark.colorDescriptionsValueTextDefault, darkTheme.colors.colorText0);
    expect(dark.fontDescriptionsLineHeight, 20);
    const patch = SemiDescriptionsThemeData(
      spacingDescriptionsThPaddingRight: 40,
      fontDescriptionsLineHeight: 24,
      colorDescriptionsKeyTextDefault: Color(0xff010203),
    );
    expect(base.merge(null), base);
    expect(base.merge(patch), patch);
    expect(patch.merge(base), patch);
    expect(
      patch.merge(
        const SemiDescriptionsThemeData(
          spacingDescriptionsItemPaddingBottom: 30,
        ),
      ),
      const SemiDescriptionsThemeData(
        spacingDescriptionsThPaddingRight: 40,
        spacingDescriptionsItemPaddingBottom: 30,
        fontDescriptionsLineHeight: 24,
        colorDescriptionsKeyTextDefault: Color(0xff010203),
      ),
    );
    expect(patch.copyWith(), patch);
    expect(
      patch,
      const SemiDescriptionsThemeData(
        colorDescriptionsKeyTextDefault: Color(0xff010203),
        spacingDescriptionsThPaddingRight: 40,
        fontDescriptionsLineHeight: 24,
      ),
    );
    expect(
      patch.hashCode,
      const SemiDescriptionsThemeData(
        colorDescriptionsKeyTextDefault: Color(0xff010203),
        spacingDescriptionsThPaddingRight: 40,
        fontDescriptionsLineHeight: 24,
      ).hashCode,
    );
    expect(patch == base, isFalse);
    final resolved = patch.resolve(darkTheme);
    expect(resolved.spacingDescriptionsThPaddingRight, 40);
    expect(resolved.fontDescriptionsLineHeight, 24);
    expect(resolved.colorDescriptionsKeyTextDefault, const Color(0xff010203));
    expect(resolved.spacingDescriptionsItemPaddingBottom, 12);
    expect(
      resolved.fontDescriptionsValueFontWeight,
      darkTheme.typography.fontWeightBold,
    );
    expect(resolved.fontDescriptionsValueSmallFontSize, 16);
    const themes = SemiComponentThemes(
      descriptions: SemiDescriptionsThemeData(
        spacingDescriptionsItemDoublePadding: 3,
      ),
    );
    expect(
      const SemiComponentThemes().descriptions,
      const SemiDescriptionsThemeData(),
    );
    expect(themes.copyWith().descriptions, themes.descriptions);
    expect(
      themes
          .copyWith(descriptions: const SemiDescriptionsThemeData())
          .descriptions,
      const SemiDescriptionsThemeData(),
    );
    expect(themes == const SemiComponentThemes(), isFalse);
    expect(
      themes.hashCode,
      const SemiComponentThemes(
        descriptions: SemiDescriptionsThemeData(
          spacingDescriptionsItemDoublePadding: 3,
        ),
      ).hashCode,
    );
    // CopyWith/merge keep the other fields: a patch on one field preserves the
    // rest of the resolution.
    final partial = patch.resolve(darkTheme);
    expect(partial.spacingDescriptionsItemSmallPaddingRight, 48);
    expect(partial.spacingDescriptionsValuePlainPaddingLeft, 8);
    expect(partial.fontDescriptionsValueLargeFontSize, 28);
    expect(partial.fontDescriptionsKeyMediumFontSize, 14);
  });

  test('theme field provenance comments', () {
    final theme = File('lib/src/theme/semi_descriptions_theme_data.dart')
        .readAsStringSync();
    final widget = File('lib/src/components/semi_descriptions.dart')
        .readAsStringSync();
    const declarations = [
      r'$color-descriptions_key-text-default: var(--semi-color-text-2)',
      r'$color-descriptions_value-text-default: var(--semi-color-text-0)',
      r'$font-descriptions-lineHeight: 20px',
      r'$font-descriptions_value-fontWeight: $font-weight-bold',
      r'$font-descriptions_key_small-fontSize: $font-size-small',
      r'$font-descriptions_value_small-fontSize: $font-size-header-6',
      r'$font-descriptions_key_medium-fontSize: $font-size-regular',
      r'$font-descriptions_value_medium-fontSize: $font-size-header-4',
      r'$font-descriptions_key_large-fontSize: $font-size-regular',
      r'$font-descriptions_value_large-fontSize: $font-size-header-2',
      r'$spacing-descriptions_th-paddingRight: $spacing-loose',
      r'$spacing-descriptions_item-paddingBottom: $spacing-base-tight',
      r'$spacing-descriptions_item_small-paddingRight: 48px',
      r'$spacing-descriptions_item_medium-paddingRight: 60px',
      r'$spacing-descriptions_item_large-paddingRight: 80px',
      r'$spacing-descriptions_key_medium-paddingBottom: $spacing-extra-tight',
      r'$spacing-descriptions_key_large-paddingBottom: $spacing-extra-tight',
      r'$spacing-descriptions_value_plain-paddingLeft: 8px',
      r'$spacing-descriptions_item_double-padding: 0',
    ];
    // 9 _DescriptionsMetrics constants (see tool/generate_descriptions.py
    // INTERNAL): the two `font-weight`/`@include` snippets back two constants.
    const internals = [
      r'min-height: $font-size-regular', // keyMinHeight
      r'white-space: nowrap', // keyMaxLines
      r'font-weight: normal', // keyBaseFontWeight
      r'font-weight: normal', // valueBaseFontWeight
      r'@include font-size-regular', // keyBaseFontSize
      r'@include font-size-regular', // valueBaseFontSize
      r'padding-bottom: 0', // keyPaddingBottomSmall
      r'{itemKey}:', // plainColon
      r'colSpan={span ? ((span * 2) - 1) : 1}', // valueColSpanFactor
    ];
    expect(declarations.length, 19);
    for (final declaration in declarations) {
      expect(theme, contains(declaration));
    }
    for (final internal in internals) {
      expect(widget, contains(internal));
    }
    // 28 = 19 themed fields + 9 widget-internal constants.
    expect(declarations.length + internals.length, 28);
    expect(
      theme,
      contains('packages/semi-foundation/descriptions/variables.scss'),
    );
    expect(
      widget,
      contains('packages/semi-foundation/descriptions/descriptions.scss'),
    );
    expect(widget, contains('packages/semi-ui/descriptions/item.tsx'));
    expect(theme, contains('Generated by tool/generate_descriptions.py'));
  });

  testWidgets('application level and nested local patches merge', (
    tester,
  ) async {
    Widget build() => host(
      width: hostWidth,
      SemiTheme(
        data: const SemiThemeData.light(
          components: SemiComponentThemes(
            descriptions: SemiDescriptionsThemeData(
              spacingDescriptionsThPaddingRight: 40,
              spacingDescriptionsItemPaddingBottom: 30,
            ),
          ),
        ),
        child: SemiDescriptionsTheme(
          data: const SemiDescriptionsThemeData(
            spacingDescriptionsThPaddingRight: 50,
            spacingDescriptionsValuePlainPaddingLeft: 12,
          ),
          child: SemiDescriptionsTheme(
            data: const SemiDescriptionsThemeData(
              spacingDescriptionsValuePlainPaddingLeft: 20,
            ),
            child: const SemiDescriptions(items: items),
          ),
        ),
      ),
    );
    await tester.pumpWidget(build());
    final root = tester.getRect(find.byType(SemiDescriptions));
    // Center align: widest key ends 50 (innermost surviving th gap) before the
    // value column.
    final key = tester.getRect(find.text('电子邮箱'));
    final value = tester.getRect(find.text('zhangsan@example.com'));
    expect(value.left - key.right, 50);
    // Application level spacingDescriptionsItemPaddingBottom survives.
    final firstKey = tester.getRect(find.text('用户名'));
    expect(key.top - firstKey.bottom, 30);
    expect(root.height, greaterThan(50));
    final context = tester.element(find.byType(SemiDescriptions));
    expect(
      SemiDescriptionsTheme.resolve(context).spacingDescriptionsThPaddingRight,
      50,
    );
    expect(
      SemiDescriptionsTheme.resolve(context)
          .spacingDescriptionsValuePlainPaddingLeft,
      20,
    );
    expect(
      SemiDescriptionsTheme.resolve(context)
          .spacingDescriptionsItemPaddingBottom,
      30,
    );
    expect(SemiDescriptionsTheme.maybeOf(context), isNotNull);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('local patches survive capture and globals re-resolve', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        width: hostWidth,
        SemiDescriptionsTheme(
          data: const SemiDescriptionsThemeData(
            spacingDescriptionsThPaddingRight: 33,
            spacingDescriptionsValuePlainPaddingLeft: 15,
          ),
          child: const SemiDescriptions(items: items),
        ),
      ),
    );
    final context = tester.element(find.byType(SemiDescriptions));
    expect(SemiDescriptionsTheme.maybeOf(context), isNotNull);
    final captured = InheritedTheme.captureAll(
      context,
      const SemiDescriptions(items: items),
    );
    await tester.pumpWidget(
      host(
        width: hostWidth,
        SemiTheme(
          data: const SemiThemeData.light(
            components: SemiComponentThemes(
              descriptions: SemiDescriptionsThemeData(
                spacingDescriptionsThPaddingRight: 44,
                spacingDescriptionsItemPaddingBottom: 30,
              ),
            ),
          ),
          child: captured,
        ),
      ),
    );
    // Captured local patches survive; application data re-resolves.
    final key = tester.getRect(find.text('电子邮箱'));
    final value = tester.getRect(find.text('zhangsan@example.com'));
    expect(value.left - key.right, 33);
    final context2 = tester.element(find.byType(SemiDescriptions));
    expect(
      SemiDescriptionsTheme.resolve(context2)
          .spacingDescriptionsValuePlainPaddingLeft,
      15,
    );
    expect(
      SemiDescriptionsTheme.resolve(context2)
          .spacingDescriptionsItemPaddingBottom,
      30,
    );
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('patches cross SemiTheme boundary and update in same mode', (
    tester,
  ) async {
    Widget build(double gap) => host(
      width: hostWidth,
      SemiDescriptionsTheme(
        data: SemiDescriptionsThemeData(spacingDescriptionsThPaddingRight: gap),
        child: SemiTheme(
          data: const SemiThemeData.light(),
          child: const SemiDescriptionsTheme(
            data: SemiDescriptionsThemeData(
              spacingDescriptionsValuePlainPaddingLeft: 15,
            ),
            child: SemiDescriptions(items: items),
          ),
        ),
      ),
    );
    await tester.pumpWidget(build(30));
    var key = tester.getRect(find.text('电子邮箱'));
    var value = tester.getRect(find.text('zhangsan@example.com'));
    expect(value.left - key.right, 30);
    await tester.pumpWidget(build(30));
    key = tester.getRect(find.text('电子邮箱'));
    value = tester.getRect(find.text('zhangsan@example.com'));
    expect(value.left - key.right, 30);
    await tester.pumpWidget(build(36));
    key = tester.getRect(find.text('电子邮箱'));
    value = tester.getRect(find.text('zhangsan@example.com'));
    expect(value.left - key.right, 36);
    final context = tester.element(find.byType(SemiDescriptions));
    final captured = InheritedTheme.captureAll(
      context,
      const SemiDescriptions(items: items),
    );
    await tester.pumpWidget(host(width: hostWidth, captured));
    key = tester.getRect(find.text('电子邮箱'));
    value = tester.getRect(find.text('zhangsan@example.com'));
    expect(value.left - key.right, 36);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('theme metrics drive the rendered geometry', (tester) async {
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiTheme(
          data: SemiThemeData.light(
            components: SemiComponentThemes(
              descriptions: SemiDescriptionsThemeData(
                spacingDescriptionsThPaddingRight: 30,
                spacingDescriptionsItemPaddingBottom: 30,
                spacingDescriptionsValuePlainPaddingLeft: 16,
                fontDescriptionsLineHeight: 30,
              ),
            ),
          ),
          child: SemiDescriptions(
            align: SemiDescriptionsAlign.center,
            items: items,
          ),
        ),
      ),
    );
    var key = tester.getRect(find.text('电子邮箱'));
    var value = tester.getRect(find.text('zhangsan@example.com'));
    expect(value.left - key.right, 30);
    // fontDescriptionsLineHeight 30 drives the base line height.
    final text = tester.widget<Text>(find.text('张三'));
    expect(text.style!.fontSize, 14);
    expect(text.style!.height, 30 / 14);
    expect(key.height, 30);
    // spacingDescriptionsItemPaddingBottom 30 between rows.
    final key2 = tester.getRect(find.text('用户名'));
    expect(key.top - key2.bottom, 30);
    await tester.pumpWidget(host(const SizedBox()));
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiTheme(
          data: SemiThemeData.light(
            components: SemiComponentThemes(
              descriptions: SemiDescriptionsThemeData(
                spacingDescriptionsValuePlainPaddingLeft: 16,
              ),
            ),
          ),
          child: SemiDescriptions(
            align: SemiDescriptionsAlign.plain,
            items: [SemiDescriptionsItemData(label: '标签', value: '值')],
          ),
        ),
      ),
    );
    final plainKey = tester.getRect(find.text('标签:'));
    final plainValue = tester.getRect(find.text('值'));
    expect(plainValue.left - plainKey.right, 16);
    await tester.pumpWidget(host(const SizedBox()));
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiTheme(
          data: SemiThemeData.light(
            components: SemiComponentThemes(
              descriptions: SemiDescriptionsThemeData(
                spacingDescriptionsItemSmallPaddingRight: 33,
                spacingDescriptionsKeyMediumPaddingBottom: 9,
                fontDescriptionsValueSmallFontSize: 18,
              ),
            ),
          ),
          child: SemiDescriptions(
            row: true,
            size: SemiDescriptionsSize.small,
            items: [
              SemiDescriptionsItemData(label: '键一', value: '值一'),
              SemiDescriptionsItemData(label: '键二', value: '值二'),
            ],
          ),
        ),
      ),
    );
    final k1 = tester.getRect(find.text('键一'));
    final k2 = tester.getRect(find.text('键二'));
    // spacingDescriptionsItemSmallPaddingRight 33 between items in a run.
    final v1 = tester.getRect(find.text('值一'));
    expect(k2.left - math.max(k1.right, v1.right), 33);
    // fontDescriptionsValueSmallFontSize override 18.
    expect(tester.widget<Text>(find.text('值一')).style!.fontSize, 18);
    await tester.pumpWidget(host(const SizedBox()));
  });
}
