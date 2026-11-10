import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  test('color override merge resolve equality hash default', () {
    const base = SemiProgressThemeData();
    const theme = SemiThemeData.light();
    final patch = base.copyWith(color: const Color(0xff123456));
    final same = SemiProgressThemeData(color: const Color(0xff123456));
    expect(patch, same);
    expect(patch.hashCode, same.hashCode);
    expect(patch == base, isFalse);
    expect(base.merge(patch), same);
    expect(patch.merge(base), same);
    expect(patch.resolve(theme).color, const Color(0xff123456));
    expect(base.resolve(theme).color, theme.colors.colorFill0);
  });
  test('strokeColor override merge resolve equality hash default', () {
    const base = SemiProgressThemeData();
    const theme = SemiThemeData.light();
    final patch = base.copyWith(strokeColor: const Color(0xff123456));
    final same = SemiProgressThemeData(strokeColor: const Color(0xff123456));
    expect(patch, same);
    expect(patch.hashCode, same.hashCode);
    expect(patch == base, isFalse);
    expect(base.merge(patch), same);
    expect(patch.merge(base), same);
    expect(patch.resolve(theme).strokeColor, const Color(0xff123456));
    expect(base.resolve(theme).strokeColor, theme.colors.colorSuccess);
  });
  test('lineTextColor override merge resolve equality hash default', () {
    const base = SemiProgressThemeData();
    const theme = SemiThemeData.light();
    final patch = base.copyWith(lineTextColor: const Color(0xff123456));
    final same = SemiProgressThemeData(lineTextColor: const Color(0xff123456));
    expect(patch, same);
    expect(patch.hashCode, same.hashCode);
    expect(patch == base, isFalse);
    expect(base.merge(patch), same);
    expect(patch.merge(base), same);
    expect(patch.resolve(theme).lineTextColor, const Color(0xff123456));
    expect(base.resolve(theme).lineTextColor, theme.colors.colorText0);
  });
  test('circleTextColor override merge resolve equality hash default', () {
    const base = SemiProgressThemeData();
    const theme = SemiThemeData.light();
    final patch = base.copyWith(circleTextColor: const Color(0xff123456));
    final same = SemiProgressThemeData(
      circleTextColor: const Color(0xff123456),
    );
    expect(patch, same);
    expect(patch.hashCode, same.hashCode);
    expect(patch == base, isFalse);
    expect(base.merge(patch), same);
    expect(patch.merge(base), same);
    expect(patch.resolve(theme).circleTextColor, const Color(0xff123456));
    expect(base.resolve(theme).circleTextColor, theme.colors.colorText0);
  });
  test('transitionDuration override merge resolve equality hash default', () {
    const base = SemiProgressThemeData();
    const theme = SemiThemeData.light();
    final patch = base.copyWith(
      transitionDuration: const Duration(milliseconds: 731),
    );
    final same = SemiProgressThemeData(
      transitionDuration: const Duration(milliseconds: 731),
    );
    expect(patch, same);
    expect(patch.hashCode, same.hashCode);
    expect(patch == base, isFalse);
    expect(base.merge(patch), same);
    expect(patch.merge(base), same);
    expect(
      patch.resolve(theme).transitionDuration,
      const Duration(milliseconds: 731),
    );
    expect(
      base.resolve(theme).transitionDuration,
      const Duration(milliseconds: 300),
    );
  });
  test('transitionCurve override merge resolve equality hash default', () {
    const base = SemiProgressThemeData();
    const theme = SemiThemeData.light();
    final patch = base.copyWith(transitionCurve: Curves.linear);
    final same = SemiProgressThemeData(transitionCurve: Curves.linear);
    expect(patch, same);
    expect(patch.hashCode, same.hashCode);
    expect(patch == base, isFalse);
    expect(base.merge(patch), same);
    expect(patch.merge(base), same);
    expect(patch.resolve(theme).transitionCurve, Curves.linear);
    expect(
      base.resolve(theme).transitionCurve,
      const Cubic(.62, .05, .36, .95),
    );
  });
  test('horizontalHeight override merge resolve equality hash default', () {
    const base = SemiProgressThemeData();
    const theme = SemiThemeData.light();
    final patch = base.copyWith(horizontalHeight: 23.0);
    final same = SemiProgressThemeData(horizontalHeight: 23.0);
    expect(patch, same);
    expect(patch.hashCode, same.hashCode);
    expect(patch == base, isFalse);
    expect(base.merge(patch), same);
    expect(patch.merge(base), same);
    expect(patch.resolve(theme).horizontalHeight, 23.0);
    expect(base.resolve(theme).horizontalHeight, 4);
  });
  test(
    'horizontalLargeHeight override merge resolve equality hash default',
    () {
      const base = SemiProgressThemeData();
      const theme = SemiThemeData.light();
      final patch = base.copyWith(horizontalLargeHeight: 23.0);
      final same = SemiProgressThemeData(horizontalLargeHeight: 23.0);
      expect(patch, same);
      expect(patch.hashCode, same.hashCode);
      expect(patch == base, isFalse);
      expect(base.merge(patch), same);
      expect(patch.merge(base), same);
      expect(patch.resolve(theme).horizontalLargeHeight, 23.0);
      expect(base.resolve(theme).horizontalLargeHeight, 6);
    },
  );
  test('lineTextMarginLeft override merge resolve equality hash default', () {
    const base = SemiProgressThemeData();
    const theme = SemiThemeData.light();
    final patch = base.copyWith(lineTextMarginLeft: 23.0);
    final same = SemiProgressThemeData(lineTextMarginLeft: 23.0);
    expect(patch, same);
    expect(patch.hashCode, same.hashCode);
    expect(patch == base, isFalse);
    expect(base.merge(patch), same);
    expect(patch.merge(base), same);
    expect(patch.resolve(theme).lineTextMarginLeft, 23.0);
    expect(base.resolve(theme).lineTextMarginLeft, 16);
  });
  test('lineTextMarginRight override merge resolve equality hash default', () {
    const base = SemiProgressThemeData();
    const theme = SemiThemeData.light();
    final patch = base.copyWith(lineTextMarginRight: 23.0);
    final same = SemiProgressThemeData(lineTextMarginRight: 23.0);
    expect(patch, same);
    expect(patch.hashCode, same.hashCode);
    expect(patch == base, isFalse);
    expect(base.merge(patch), same);
    expect(patch.merge(base), same);
    expect(patch.resolve(theme).lineTextMarginRight, 23.0);
    expect(base.resolve(theme).lineTextMarginRight, 16);
  });
  test('verticalMarginX override merge resolve equality hash default', () {
    const base = SemiProgressThemeData();
    const theme = SemiThemeData.light();
    final patch = base.copyWith(verticalMarginX: 23.0);
    final same = SemiProgressThemeData(verticalMarginX: 23.0);
    expect(patch, same);
    expect(patch.hashCode, same.hashCode);
    expect(patch == base, isFalse);
    expect(base.merge(patch), same);
    expect(patch.merge(base), same);
    expect(patch.resolve(theme).verticalMarginX, 23.0);
    expect(base.resolve(theme).verticalMarginX, 4);
  });
  test('horizontalMarginY override merge resolve equality hash default', () {
    const base = SemiProgressThemeData();
    const theme = SemiThemeData.light();
    final patch = base.copyWith(horizontalMarginY: 23.0);
    final same = SemiProgressThemeData(horizontalMarginY: 23.0);
    expect(patch, same);
    expect(patch.hashCode, same.hashCode);
    expect(patch == base, isFalse);
    expect(base.merge(patch), same);
    expect(patch.merge(base), same);
    expect(patch.resolve(theme).horizontalMarginY, 23.0);
    expect(base.resolve(theme).horizontalMarginY, 4);
  });
  test(
    'verticalTextMarginTop override merge resolve equality hash default',
    () {
      const base = SemiProgressThemeData();
      const theme = SemiThemeData.light();
      final patch = base.copyWith(verticalTextMarginTop: 23.0);
      final same = SemiProgressThemeData(verticalTextMarginTop: 23.0);
      expect(patch, same);
      expect(patch.hashCode, same.hashCode);
      expect(patch == base, isFalse);
      expect(base.merge(patch), same);
      expect(patch.merge(base), same);
      expect(patch.resolve(theme).verticalTextMarginTop, 23.0);
      expect(base.resolve(theme).verticalTextMarginTop, 8);
    },
  );
  test('lineTextFontWeight override merge resolve equality hash default', () {
    const base = SemiProgressThemeData();
    const theme = SemiThemeData.light();
    final patch = base.copyWith(lineTextFontWeight: FontWeight.w300);
    final same = SemiProgressThemeData(lineTextFontWeight: FontWeight.w300);
    expect(patch, same);
    expect(patch.hashCode, same.hashCode);
    expect(patch == base, isFalse);
    expect(base.merge(patch), same);
    expect(patch.merge(base), same);
    expect(patch.resolve(theme).lineTextFontWeight, FontWeight.w300);
    expect(base.resolve(theme).lineTextFontWeight, FontWeight.w600);
  });
  test('lineTextMinWidth override merge resolve equality hash default', () {
    const base = SemiProgressThemeData();
    const theme = SemiThemeData.light();
    final patch = base.copyWith(lineTextMinWidth: 23.0);
    final same = SemiProgressThemeData(lineTextMinWidth: 23.0);
    expect(patch, same);
    expect(patch.hashCode, same.hashCode);
    expect(patch == base, isFalse);
    expect(base.merge(patch), same);
    expect(patch.merge(base), same);
    expect(patch.resolve(theme).lineTextMinWidth, 23.0);
    expect(base.resolve(theme).lineTextMinWidth, 45);
  });
  test('verticalWidth override merge resolve equality hash default', () {
    const base = SemiProgressThemeData();
    const theme = SemiThemeData.light();
    final patch = base.copyWith(verticalWidth: 23.0);
    final same = SemiProgressThemeData(verticalWidth: 23.0);
    expect(patch, same);
    expect(patch.hashCode, same.hashCode);
    expect(patch == base, isFalse);
    expect(base.merge(patch), same);
    expect(patch.merge(base), same);
    expect(patch.resolve(theme).verticalWidth, 23.0);
    expect(base.resolve(theme).verticalWidth, 4);
  });
  test('verticalLargeWidth override merge resolve equality hash default', () {
    const base = SemiProgressThemeData();
    const theme = SemiThemeData.light();
    final patch = base.copyWith(verticalLargeWidth: 23.0);
    final same = SemiProgressThemeData(verticalLargeWidth: 23.0);
    expect(patch, same);
    expect(patch.hashCode, same.hashCode);
    expect(patch == base, isFalse);
    expect(base.merge(patch), same);
    expect(patch.merge(base), same);
    expect(patch.resolve(theme).verticalLargeWidth, 23.0);
    expect(base.resolve(theme).verticalLargeWidth, 6);
  });
  test('trackRadius override merge resolve equality hash default', () {
    const base = SemiProgressThemeData();
    const theme = SemiThemeData.light();
    final patch = base.copyWith(trackRadius: 23.0);
    final same = SemiProgressThemeData(trackRadius: 23.0);
    expect(patch, same);
    expect(patch.hashCode, same.hashCode);
    expect(patch == base, isFalse);
    expect(base.merge(patch), same);
    expect(patch.merge(base), same);
    expect(patch.resolve(theme).trackRadius, 23.0);
    expect(
      base.resolve(theme).trackRadius,
      theme.radius.borderRadiusSmall.value,
    );
  });
  test('innerRadius override merge resolve equality hash default', () {
    const base = SemiProgressThemeData();
    const theme = SemiThemeData.light();
    final patch = base.copyWith(innerRadius: 23.0);
    final same = SemiProgressThemeData(innerRadius: 23.0);
    expect(patch, same);
    expect(patch.hashCode, same.hashCode);
    expect(patch == base, isFalse);
    expect(base.merge(patch), same);
    expect(patch.merge(base), same);
    expect(patch.resolve(theme).innerRadius, 23.0);
    expect(
      base.resolve(theme).innerRadius,
      theme.radius.borderRadiusSmall.value,
    );
  });
}
