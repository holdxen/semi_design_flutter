import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

import 'semi_text_test.dart' show host, textStyle;

void main() {
  typographyMetricTests();
  typographyAcceptanceTests();
  const value = Color(0xff123456);
  testWidgets('all type colors and custom link interaction states', (t) async {
    const colors = [
      Color(0xff000011),
      Color(0xff000012),
      Color(0xff000013),
      Color(0xff000014),
      Color(0xff000015),
      Color(0xff000016),
      Color(0xff000017),
    ];
    const config = SemiTypographyThemeData(
      defaultTextColor: Color(0xff000011),
      secondaryTextColor: Color(0xff000012),
      tertiaryTextColor: Color(0xff000013),
      quaternaryTextColor: Color(0xff000014),
      warningTextColor: Color(0xff000015),
      dangerTextColor: Color(0xff000016),
      successTextColor: Color(0xff000017),
      linkTextColor: Color(0xff000021),
      linkVisitedColor: Color(0xff000022),
      linkHoverColor: Color(0xff000023),
      linkActiveColor: Color(0xff000024),
    );
    Widget themed(Widget child) =>
        host(SemiTypographyTheme(data: config, child: child));
    for (final type in SemiTextType.values) {
      await t.pumpWidget(themed(SemiText('type', type: type)));
      expect(textStyle(t).color, colors[type.index]);
      await t.pumpWidget(themed(SemiTitle('type', type: type)));
      expect(textStyle(t).color, colors[type.index]);
    }
    await t.pumpWidget(
      themed(SemiText('link', link: SemiTextLink(onTap: () {}))),
    );
    expect(textStyle(t).color, config.linkTextColor);
    await t.pumpWidget(
      themed(SemiText('link', link: SemiTextLink(onTap: () {}, visited: true))),
    );
    expect(textStyle(t).color, config.linkVisitedColor);
    final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(t.getCenter(find.text('link')));
    await t.pump();
    expect(textStyle(t).color, config.linkHoverColor);
    await mouse.down(t.getCenter(find.text('link')));
    await t.pump();
    expect(textStyle(t).color, config.linkActiveColor);
    await mouse.up();
    await mouse.removePointer();
  });
  test(
    'defaultTextColor defaults, global override, patch and value semantics',
    () {
      const empty = SemiTypographyThemeData();
      expect(empty.defaultTextColor, isNull);
      for (final theme in [
        const SemiThemeData.light(),
        const SemiThemeData.dark(),
      ]) {
        expect(empty.resolve(theme).defaultTextColor, theme.colors.colorText0);
        final custom = theme.copyWith(
          colors: theme.colors.copyWith(colorText0: value),
        );
        expect(empty.resolve(custom).defaultTextColor, value);
      }
      const direct = SemiTypographyThemeData(defaultTextColor: value);
      final copied = empty.copyWith(defaultTextColor: value);
      expect(copied, direct);
      expect(copied.hashCode, direct.hashCode);
      expect(copied.copyWith(defaultTextColor: null), direct);
      expect(copied.merge(empty), direct);
      expect(empty.merge(direct), direct);
      expect(
        direct.resolve(const SemiThemeData.dark()).defaultTextColor,
        value,
      );
      expect(direct, isNot(empty));
      const app = SemiThemeData.light(
        components: SemiComponentThemes(typography: direct),
      );
      expect(app.copyWith(dark: true).copyWith(dark: false), app);
      expect(app.copyWith().hashCode, app.hashCode);
      expect(app, isNot(const SemiThemeData.light()));
    },
  );
  test(
    'secondaryTextColor defaults, global override, patch and value semantics',
    () {
      const empty = SemiTypographyThemeData();
      expect(empty.secondaryTextColor, isNull);
      for (final theme in [
        const SemiThemeData.light(),
        const SemiThemeData.dark(),
      ]) {
        expect(
          empty.resolve(theme).secondaryTextColor,
          theme.colors.colorText1,
        );
        final custom = theme.copyWith(
          colors: theme.colors.copyWith(colorText1: value),
        );
        expect(empty.resolve(custom).secondaryTextColor, value);
      }
      const direct = SemiTypographyThemeData(secondaryTextColor: value);
      final copied = empty.copyWith(secondaryTextColor: value);
      expect(copied, direct);
      expect(copied.hashCode, direct.hashCode);
      expect(copied.copyWith(secondaryTextColor: null), direct);
      expect(copied.merge(empty), direct);
      expect(empty.merge(direct), direct);
      expect(
        direct.resolve(const SemiThemeData.dark()).secondaryTextColor,
        value,
      );
      expect(direct, isNot(empty));
      const app = SemiThemeData.light(
        components: SemiComponentThemes(typography: direct),
      );
      expect(app.copyWith(dark: true).copyWith(dark: false), app);
      expect(app.copyWith().hashCode, app.hashCode);
      expect(app, isNot(const SemiThemeData.light()));
    },
  );
  test(
    'tertiaryTextColor defaults, global override, patch and value semantics',
    () {
      const empty = SemiTypographyThemeData();
      expect(empty.tertiaryTextColor, isNull);
      for (final theme in [
        const SemiThemeData.light(),
        const SemiThemeData.dark(),
      ]) {
        expect(empty.resolve(theme).tertiaryTextColor, theme.colors.colorText2);
        final custom = theme.copyWith(
          colors: theme.colors.copyWith(colorText2: value),
        );
        expect(empty.resolve(custom).tertiaryTextColor, value);
      }
      const direct = SemiTypographyThemeData(tertiaryTextColor: value);
      final copied = empty.copyWith(tertiaryTextColor: value);
      expect(copied, direct);
      expect(copied.hashCode, direct.hashCode);
      expect(copied.copyWith(tertiaryTextColor: null), direct);
      expect(copied.merge(empty), direct);
      expect(empty.merge(direct), direct);
      expect(
        direct.resolve(const SemiThemeData.dark()).tertiaryTextColor,
        value,
      );
      expect(direct, isNot(empty));
      const app = SemiThemeData.light(
        components: SemiComponentThemes(typography: direct),
      );
      expect(app.copyWith(dark: true).copyWith(dark: false), app);
      expect(app.copyWith().hashCode, app.hashCode);
      expect(app, isNot(const SemiThemeData.light()));
    },
  );
  test(
    'quaternaryTextColor defaults, global override, patch and value semantics',
    () {
      const empty = SemiTypographyThemeData();
      expect(empty.quaternaryTextColor, isNull);
      for (final theme in [
        const SemiThemeData.light(),
        const SemiThemeData.dark(),
      ]) {
        expect(
          empty.resolve(theme).quaternaryTextColor,
          theme.colors.colorText3,
        );
        final custom = theme.copyWith(
          colors: theme.colors.copyWith(colorText3: value),
        );
        expect(empty.resolve(custom).quaternaryTextColor, value);
      }
      const direct = SemiTypographyThemeData(quaternaryTextColor: value);
      final copied = empty.copyWith(quaternaryTextColor: value);
      expect(copied, direct);
      expect(copied.hashCode, direct.hashCode);
      expect(copied.copyWith(quaternaryTextColor: null), direct);
      expect(copied.merge(empty), direct);
      expect(empty.merge(direct), direct);
      expect(
        direct.resolve(const SemiThemeData.dark()).quaternaryTextColor,
        value,
      );
      expect(direct, isNot(empty));
      const app = SemiThemeData.light(
        components: SemiComponentThemes(typography: direct),
      );
      expect(app.copyWith(dark: true).copyWith(dark: false), app);
      expect(app.copyWith().hashCode, app.hashCode);
      expect(app, isNot(const SemiThemeData.light()));
    },
  );
  test(
    'warningTextColor defaults, global override, patch and value semantics',
    () {
      const empty = SemiTypographyThemeData();
      expect(empty.warningTextColor, isNull);
      for (final theme in [
        const SemiThemeData.light(),
        const SemiThemeData.dark(),
      ]) {
        expect(
          empty.resolve(theme).warningTextColor,
          theme.colors.colorWarning,
        );
        final custom = theme.copyWith(
          colors: theme.colors.copyWith(colorWarning: value),
        );
        expect(empty.resolve(custom).warningTextColor, value);
      }
      const direct = SemiTypographyThemeData(warningTextColor: value);
      final copied = empty.copyWith(warningTextColor: value);
      expect(copied, direct);
      expect(copied.hashCode, direct.hashCode);
      expect(copied.copyWith(warningTextColor: null), direct);
      expect(copied.merge(empty), direct);
      expect(empty.merge(direct), direct);
      expect(
        direct.resolve(const SemiThemeData.dark()).warningTextColor,
        value,
      );
      expect(direct, isNot(empty));
      const app = SemiThemeData.light(
        components: SemiComponentThemes(typography: direct),
      );
      expect(app.copyWith(dark: true).copyWith(dark: false), app);
      expect(app.copyWith().hashCode, app.hashCode);
      expect(app, isNot(const SemiThemeData.light()));
    },
  );
  test(
    'dangerTextColor defaults, global override, patch and value semantics',
    () {
      const empty = SemiTypographyThemeData();
      expect(empty.dangerTextColor, isNull);
      for (final theme in [
        const SemiThemeData.light(),
        const SemiThemeData.dark(),
      ]) {
        expect(empty.resolve(theme).dangerTextColor, theme.colors.colorDanger);
        final custom = theme.copyWith(
          colors: theme.colors.copyWith(colorDanger: value),
        );
        expect(empty.resolve(custom).dangerTextColor, value);
      }
      const direct = SemiTypographyThemeData(dangerTextColor: value);
      final copied = empty.copyWith(dangerTextColor: value);
      expect(copied, direct);
      expect(copied.hashCode, direct.hashCode);
      expect(copied.copyWith(dangerTextColor: null), direct);
      expect(copied.merge(empty), direct);
      expect(empty.merge(direct), direct);
      expect(direct.resolve(const SemiThemeData.dark()).dangerTextColor, value);
      expect(direct, isNot(empty));
      const app = SemiThemeData.light(
        components: SemiComponentThemes(typography: direct),
      );
      expect(app.copyWith(dark: true).copyWith(dark: false), app);
      expect(app.copyWith().hashCode, app.hashCode);
      expect(app, isNot(const SemiThemeData.light()));
    },
  );
  test(
    'successTextColor defaults, global override, patch and value semantics',
    () {
      const empty = SemiTypographyThemeData();
      expect(empty.successTextColor, isNull);
      for (final theme in [
        const SemiThemeData.light(),
        const SemiThemeData.dark(),
      ]) {
        expect(
          empty.resolve(theme).successTextColor,
          theme.colors.colorSuccess,
        );
        final custom = theme.copyWith(
          colors: theme.colors.copyWith(colorSuccess: value),
        );
        expect(empty.resolve(custom).successTextColor, value);
      }
      const direct = SemiTypographyThemeData(successTextColor: value);
      final copied = empty.copyWith(successTextColor: value);
      expect(copied, direct);
      expect(copied.hashCode, direct.hashCode);
      expect(copied.copyWith(successTextColor: null), direct);
      expect(copied.merge(empty), direct);
      expect(empty.merge(direct), direct);
      expect(
        direct.resolve(const SemiThemeData.dark()).successTextColor,
        value,
      );
      expect(direct, isNot(empty));
      const app = SemiThemeData.light(
        components: SemiComponentThemes(typography: direct),
      );
      expect(app.copyWith(dark: true).copyWith(dark: false), app);
      expect(app.copyWith().hashCode, app.hashCode);
      expect(app, isNot(const SemiThemeData.light()));
    },
  );
  test(
    'disabledTextColor defaults, global override, patch and value semantics',
    () {
      const empty = SemiTypographyThemeData();
      expect(empty.disabledTextColor, isNull);
      for (final theme in [
        const SemiThemeData.light(),
        const SemiThemeData.dark(),
      ]) {
        expect(
          empty.resolve(theme).disabledTextColor,
          theme.colors.colorDisabledText,
        );
        final custom = theme.copyWith(
          colors: theme.colors.copyWith(colorDisabledText: value),
        );
        expect(empty.resolve(custom).disabledTextColor, value);
      }
      const direct = SemiTypographyThemeData(disabledTextColor: value);
      final copied = empty.copyWith(disabledTextColor: value);
      expect(copied, direct);
      expect(copied.hashCode, direct.hashCode);
      expect(copied.copyWith(disabledTextColor: null), direct);
      expect(copied.merge(empty), direct);
      expect(empty.merge(direct), direct);
      expect(
        direct.resolve(const SemiThemeData.dark()).disabledTextColor,
        value,
      );
      expect(direct, isNot(empty));
      const app = SemiThemeData.light(
        components: SemiComponentThemes(typography: direct),
      );
      expect(app.copyWith(dark: true).copyWith(dark: false), app);
      expect(app.copyWith().hashCode, app.hashCode);
      expect(app, isNot(const SemiThemeData.light()));
    },
  );
  test(
    'markBackgroundColor defaults, global override, patch and value semantics',
    () {
      const empty = SemiTypographyThemeData();
      expect(empty.markBackgroundColor, isNull);
      for (final theme in [
        const SemiThemeData.light(),
        const SemiThemeData.dark(),
      ]) {
        expect(
          empty.resolve(theme).markBackgroundColor,
          theme.colors.colorPrimaryLightDefault,
        );
        final custom = theme.copyWith(
          colors: theme.colors.copyWith(colorPrimaryLightDefault: value),
        );
        expect(empty.resolve(custom).markBackgroundColor, value);
      }
      const direct = SemiTypographyThemeData(markBackgroundColor: value);
      final copied = empty.copyWith(markBackgroundColor: value);
      expect(copied, direct);
      expect(copied.hashCode, direct.hashCode);
      expect(copied.copyWith(markBackgroundColor: null), direct);
      expect(copied.merge(empty), direct);
      expect(empty.merge(direct), direct);
      expect(
        direct.resolve(const SemiThemeData.dark()).markBackgroundColor,
        value,
      );
      expect(direct, isNot(empty));
      const app = SemiThemeData.light(
        components: SemiComponentThemes(typography: direct),
      );
      expect(app.copyWith(dark: true).copyWith(dark: false), app);
      expect(app.copyWith().hashCode, app.hashCode);
      expect(app, isNot(const SemiThemeData.light()));
    },
  );
  test(
    'codeBackgroundColor defaults, global override, patch and value semantics',
    () {
      const empty = SemiTypographyThemeData();
      expect(empty.codeBackgroundColor, isNull);
      for (final theme in [
        const SemiThemeData.light(),
        const SemiThemeData.dark(),
      ]) {
        expect(
          empty.resolve(theme).codeBackgroundColor,
          theme.colors.colorFill1,
        );
        final custom = theme.copyWith(
          colors: theme.colors.copyWith(colorFill1: value),
        );
        expect(empty.resolve(custom).codeBackgroundColor, value);
      }
      const direct = SemiTypographyThemeData(codeBackgroundColor: value);
      final copied = empty.copyWith(codeBackgroundColor: value);
      expect(copied, direct);
      expect(copied.hashCode, direct.hashCode);
      expect(copied.copyWith(codeBackgroundColor: null), direct);
      expect(copied.merge(empty), direct);
      expect(empty.merge(direct), direct);
      expect(
        direct.resolve(const SemiThemeData.dark()).codeBackgroundColor,
        value,
      );
      expect(direct, isNot(empty));
      const app = SemiThemeData.light(
        components: SemiComponentThemes(typography: direct),
      );
      expect(app.copyWith(dark: true).copyWith(dark: false), app);
      expect(app.copyWith().hashCode, app.hashCode);
      expect(app, isNot(const SemiThemeData.light()));
    },
  );
  test(
    'codeTextColor defaults, global override, patch and value semantics',
    () {
      const empty = SemiTypographyThemeData();
      expect(empty.codeTextColor, isNull);
      for (final theme in [
        const SemiThemeData.light(),
        const SemiThemeData.dark(),
      ]) {
        expect(empty.resolve(theme).codeTextColor, theme.colors.colorText2);
        final custom = theme.copyWith(
          colors: theme.colors.copyWith(colorText2: value),
        );
        expect(empty.resolve(custom).codeTextColor, value);
      }
      const direct = SemiTypographyThemeData(codeTextColor: value);
      final copied = empty.copyWith(codeTextColor: value);
      expect(copied, direct);
      expect(copied.hashCode, direct.hashCode);
      expect(copied.copyWith(codeTextColor: null), direct);
      expect(copied.merge(empty), direct);
      expect(empty.merge(direct), direct);
      expect(direct.resolve(const SemiThemeData.dark()).codeTextColor, value);
      expect(direct, isNot(empty));
      const app = SemiThemeData.light(
        components: SemiComponentThemes(typography: direct),
      );
      expect(app.copyWith(dark: true).copyWith(dark: false), app);
      expect(app.copyWith().hashCode, app.hashCode);
      expect(app, isNot(const SemiThemeData.light()));
    },
  );
  test(
    'linkTextColor defaults, global override, patch and value semantics',
    () {
      const empty = SemiTypographyThemeData();
      expect(empty.linkTextColor, isNull);
      for (final theme in [
        const SemiThemeData.light(),
        const SemiThemeData.dark(),
      ]) {
        expect(empty.resolve(theme).linkTextColor, theme.colors.colorLink);
        final custom = theme.copyWith(
          colors: theme.colors.copyWith(colorLink: value),
        );
        expect(empty.resolve(custom).linkTextColor, value);
      }
      const direct = SemiTypographyThemeData(linkTextColor: value);
      final copied = empty.copyWith(linkTextColor: value);
      expect(copied, direct);
      expect(copied.hashCode, direct.hashCode);
      expect(copied.copyWith(linkTextColor: null), direct);
      expect(copied.merge(empty), direct);
      expect(empty.merge(direct), direct);
      expect(direct.resolve(const SemiThemeData.dark()).linkTextColor, value);
      expect(direct, isNot(empty));
      const app = SemiThemeData.light(
        components: SemiComponentThemes(typography: direct),
      );
      expect(app.copyWith(dark: true).copyWith(dark: false), app);
      expect(app.copyWith().hashCode, app.hashCode);
      expect(app, isNot(const SemiThemeData.light()));
    },
  );
  test(
    'linkVisitedColor defaults, global override, patch and value semantics',
    () {
      const empty = SemiTypographyThemeData();
      expect(empty.linkVisitedColor, isNull);
      for (final theme in [
        const SemiThemeData.light(),
        const SemiThemeData.dark(),
      ]) {
        expect(
          empty.resolve(theme).linkVisitedColor,
          theme.colors.colorLinkVisited,
        );
        final custom = theme.copyWith(
          colors: theme.colors.copyWith(colorLinkVisited: value),
        );
        expect(empty.resolve(custom).linkVisitedColor, value);
      }
      const direct = SemiTypographyThemeData(linkVisitedColor: value);
      final copied = empty.copyWith(linkVisitedColor: value);
      expect(copied, direct);
      expect(copied.hashCode, direct.hashCode);
      expect(copied.copyWith(linkVisitedColor: null), direct);
      expect(copied.merge(empty), direct);
      expect(empty.merge(direct), direct);
      expect(
        direct.resolve(const SemiThemeData.dark()).linkVisitedColor,
        value,
      );
      expect(direct, isNot(empty));
      const app = SemiThemeData.light(
        components: SemiComponentThemes(typography: direct),
      );
      expect(app.copyWith(dark: true).copyWith(dark: false), app);
      expect(app.copyWith().hashCode, app.hashCode);
      expect(app, isNot(const SemiThemeData.light()));
    },
  );
  test(
    'linkHoverColor defaults, global override, patch and value semantics',
    () {
      const empty = SemiTypographyThemeData();
      expect(empty.linkHoverColor, isNull);
      for (final theme in [
        const SemiThemeData.light(),
        const SemiThemeData.dark(),
      ]) {
        expect(
          empty.resolve(theme).linkHoverColor,
          theme.colors.colorLinkHover,
        );
        final custom = theme.copyWith(
          colors: theme.colors.copyWith(colorLinkHover: value),
        );
        expect(empty.resolve(custom).linkHoverColor, value);
      }
      const direct = SemiTypographyThemeData(linkHoverColor: value);
      final copied = empty.copyWith(linkHoverColor: value);
      expect(copied, direct);
      expect(copied.hashCode, direct.hashCode);
      expect(copied.copyWith(linkHoverColor: null), direct);
      expect(copied.merge(empty), direct);
      expect(empty.merge(direct), direct);
      expect(direct.resolve(const SemiThemeData.dark()).linkHoverColor, value);
      expect(direct, isNot(empty));
      const app = SemiThemeData.light(
        components: SemiComponentThemes(typography: direct),
      );
      expect(app.copyWith(dark: true).copyWith(dark: false), app);
      expect(app.copyWith().hashCode, app.hashCode);
      expect(app, isNot(const SemiThemeData.light()));
    },
  );
  test(
    'linkActiveColor defaults, global override, patch and value semantics',
    () {
      const empty = SemiTypographyThemeData();
      expect(empty.linkActiveColor, isNull);
      for (final theme in [
        const SemiThemeData.light(),
        const SemiThemeData.dark(),
      ]) {
        expect(
          empty.resolve(theme).linkActiveColor,
          theme.colors.colorLinkActive,
        );
        final custom = theme.copyWith(
          colors: theme.colors.copyWith(colorLinkActive: value),
        );
        expect(empty.resolve(custom).linkActiveColor, value);
      }
      const direct = SemiTypographyThemeData(linkActiveColor: value);
      final copied = empty.copyWith(linkActiveColor: value);
      expect(copied, direct);
      expect(copied.hashCode, direct.hashCode);
      expect(copied.copyWith(linkActiveColor: null), direct);
      expect(copied.merge(empty), direct);
      expect(empty.merge(direct), direct);
      expect(direct.resolve(const SemiThemeData.dark()).linkActiveColor, value);
      expect(direct, isNot(empty));
      const app = SemiThemeData.light(
        components: SemiComponentThemes(typography: direct),
      );
      expect(app.copyWith(dark: true).copyWith(dark: false), app);
      expect(app.copyWith().hashCode, app.hashCode);
      expect(app, isNot(const SemiThemeData.light()));
    },
  );
  test(
    'linkDisabledColor defaults, global override, patch and value semantics',
    () {
      const empty = SemiTypographyThemeData();
      expect(empty.linkDisabledColor, isNull);
      for (final theme in [
        const SemiThemeData.light(),
        const SemiThemeData.dark(),
      ]) {
        expect(empty.resolve(theme).linkDisabledColor, theme.colors.colorLink);
        final custom = theme.copyWith(
          colors: theme.colors.copyWith(colorLink: value),
        );
        expect(empty.resolve(custom).linkDisabledColor, value);
      }
      const direct = SemiTypographyThemeData(linkDisabledColor: value);
      final copied = empty.copyWith(linkDisabledColor: value);
      expect(copied, direct);
      expect(copied.hashCode, direct.hashCode);
      expect(copied.copyWith(linkDisabledColor: null), direct);
      expect(copied.merge(empty), direct);
      expect(empty.merge(direct), direct);
      expect(
        direct.resolve(const SemiThemeData.dark()).linkDisabledColor,
        value,
      );
      expect(direct, isNot(empty));
      const app = SemiThemeData.light(
        components: SemiComponentThemes(typography: direct),
      );
      expect(app.copyWith(dark: true).copyWith(dark: false), app);
      expect(app.copyWith().hashCode, app.hashCode);
      expect(app, isNot(const SemiThemeData.light()));
    },
  );
  test(
    'copiedTextColor defaults, global override, patch and value semantics',
    () {
      const empty = SemiTypographyThemeData();
      expect(empty.copiedTextColor, isNull);
      for (final theme in [
        const SemiThemeData.light(),
        const SemiThemeData.dark(),
      ]) {
        expect(empty.resolve(theme).copiedTextColor, theme.colors.colorText2);
        final custom = theme.copyWith(
          colors: theme.colors.copyWith(colorText2: value),
        );
        expect(empty.resolve(custom).copiedTextColor, value);
      }
      const direct = SemiTypographyThemeData(copiedTextColor: value);
      final copied = empty.copyWith(copiedTextColor: value);
      expect(copied, direct);
      expect(copied.hashCode, direct.hashCode);
      expect(copied.copyWith(copiedTextColor: null), direct);
      expect(copied.merge(empty), direct);
      expect(empty.merge(direct), direct);
      expect(direct.resolve(const SemiThemeData.dark()).copiedTextColor, value);
      expect(direct, isNot(empty));
      const app = SemiThemeData.light(
        components: SemiComponentThemes(typography: direct),
      );
      expect(app.copyWith(dark: true).copyWith(dark: false), app);
      expect(app.copyWith().hashCode, app.hashCode);
      expect(app, isNot(const SemiThemeData.light()));
    },
  );
  test(
    'copiedIconColor defaults, global override, patch and value semantics',
    () {
      const empty = SemiTypographyThemeData();
      expect(empty.copiedIconColor, isNull);
      for (final theme in [
        const SemiThemeData.light(),
        const SemiThemeData.dark(),
      ]) {
        expect(empty.resolve(theme).copiedIconColor, theme.colors.colorSuccess);
        final custom = theme.copyWith(
          colors: theme.colors.copyWith(colorSuccess: value),
        );
        expect(empty.resolve(custom).copiedIconColor, value);
      }
      const direct = SemiTypographyThemeData(copiedIconColor: value);
      final copied = empty.copyWith(copiedIconColor: value);
      expect(copied, direct);
      expect(copied.hashCode, direct.hashCode);
      expect(copied.copyWith(copiedIconColor: null), direct);
      expect(copied.merge(empty), direct);
      expect(empty.merge(direct), direct);
      expect(direct.resolve(const SemiThemeData.dark()).copiedIconColor, value);
      expect(direct, isNot(empty));
      const app = SemiThemeData.light(
        components: SemiComponentThemes(typography: direct),
      );
      expect(app.copyWith(dark: true).copyWith(dark: false), app);
      expect(app.copyWith().hashCode, app.hashCode);
      expect(app, isNot(const SemiThemeData.light()));
    },
  );
  test(
    'codeBorderColor defaults, global override, patch and value semantics',
    () {
      const empty = SemiTypographyThemeData();
      expect(empty.codeBorderColor, isNull);
      for (final theme in [
        const SemiThemeData.light(),
        const SemiThemeData.dark(),
      ]) {
        expect(empty.resolve(theme).codeBorderColor, theme.colors.colorBorder);
        final custom = theme.copyWith(
          colors: theme.colors.copyWith(colorBorder: value),
        );
        expect(empty.resolve(custom).codeBorderColor, value);
      }
      const direct = SemiTypographyThemeData(codeBorderColor: value);
      final copied = empty.copyWith(codeBorderColor: value);
      expect(copied, direct);
      expect(copied.hashCode, direct.hashCode);
      expect(copied.copyWith(codeBorderColor: null), direct);
      expect(copied.merge(empty), direct);
      expect(empty.merge(direct), direct);
      expect(direct.resolve(const SemiThemeData.dark()).codeBorderColor, value);
      expect(direct, isNot(empty));
      const app = SemiThemeData.light(
        components: SemiComponentThemes(typography: direct),
      );
      expect(app.copyWith(dark: true).copyWith(dark: false), app);
      expect(app.copyWith().hashCode, app.hashCode);
      expect(app, isNot(const SemiThemeData.light()));
    },
  );

  testWidgets(
    'nested patches follow parent and current application across theme boundaries',
    (t) async {
      const leaf = SemiTypographyTheme(
        data: SemiTypographyThemeData(markBackgroundColor: Color(0xff000003)),
        child: SemiText('nested', mark: true),
      );
      Widget tree(Color parent, Color application) => host(
        SemiTypographyTheme(
          data: SemiTypographyThemeData(defaultTextColor: parent),
          child: SemiTheme(
            data: SemiThemeData.light(
              components: SemiComponentThemes(
                typography: SemiTypographyThemeData(
                  secondaryTextColor: application,
                ),
              ),
            ),
            child: Column(
              children: [
                leaf,
                Builder(
                  builder: (context) {
                    final overrides = SemiTypographyTheme.of(context);
                    expect(overrides.secondaryTextColor, application);
                    expect(overrides.defaultTextColor, parent);
                    return const SemiTitle(
                      'title',
                      type: SemiTextType.secondary,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
      await t.pumpWidget(tree(value, const Color(0xff000004)));
      expect(textStyle(t).color, value);
      expect(textStyle(t).backgroundColor, const Color(0xff000003));
      await t.pumpWidget(
        tree(const Color(0xff000005), const Color(0xff000006)),
      );
      expect(textStyle(t).color, const Color(0xff000005));
      expect(
        t.widget<Text>(find.text('title')).style!.color,
        const Color(0xff000006),
      );
    },
  );
  testWidgets(
    'global tokens and same-brightness component changes refresh const descendants',
    (t) async {
      const child = SemiTypographyTheme(
        data: SemiTypographyThemeData(markBackgroundColor: value),
        child: SemiText('live', mark: true),
      );
      await t.pumpWidget(host(child));
      await t.pumpWidget(
        host(
          child,
          theme: const SemiThemeData.light(
            colors: SemiColors(colorText0: value),
          ),
        ),
      );
      expect(textStyle(t).color, value);
      await t.pumpWidget(
        host(
          child,
          theme: const SemiThemeData.light(
            components: SemiComponentThemes(
              typography: SemiTypographyThemeData(
                defaultTextColor: Color(0xff000007),
              ),
            ),
          ),
        ),
      );
      expect(textStyle(t).color, const Color(0xff000007));
      expect(textStyle(t).backgroundColor, value);
    },
  );
  testWidgets(
    'nullable lookup and inherited theme capture retain unresolved patches',
    (t) async {
      CapturedThemes? captured;
      await t.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              expect(SemiTypographyTheme.maybeOf(context), isNull);
              return SemiTypographyTheme(
                data: const SemiTypographyThemeData(markBackgroundColor: value),
                child: Builder(
                  builder: (inner) {
                    captured = InheritedTheme.capture(from: inner, to: context);
                    return const SizedBox();
                  },
                ),
              );
            },
          ),
        ),
      );
      await t.pumpWidget(
        host(
          captured!.wrap(const SemiText('captured', mark: true)),
          theme: const SemiThemeData.dark(
            colors: SemiColors(colorText0: value),
          ),
        ),
      );
      expect(textStyle(t).color, value);
      expect(textStyle(t).backgroundColor, value);
    },
  );
  testWidgets('component code, mark, disabled link and explicit styles', (
    t,
  ) async {
    const config = SemiTypographyThemeData(
      codeBackgroundColor: Color(0xff000001),
      codeBorderColor: Color(0xff000002),
      codeTextColor: Color(0xff000003),
      markBackgroundColor: Color(0xff000004),
      disabledTextColor: Color(0xff000005),
      linkDisabledColor: Color(0xff000006),
    );
    Widget themed(Widget child) =>
        host(SemiTypographyTheme(data: config, child: child));
    await t.pumpWidget(themed(const SemiText('code', code: true)));
    expect(textStyle(t).color, config.codeTextColor);
    final box =
        t.widget<DecoratedBox>(find.byType(DecoratedBox)).decoration
            as BoxDecoration;
    expect(box.color, config.codeBackgroundColor);
    expect(box.border, Border.all(color: config.codeBorderColor!));
    await t.pumpWidget(
      themed(const SemiTitle('mark', mark: true, disabled: true)),
    );
    expect(textStyle(t).color, config.disabledTextColor);
    expect(textStyle(t).backgroundColor, config.markBackgroundColor);
    var taps = 0;
    await t.pumpWidget(
      themed(
        SemiText(
          'disabled',
          disabled: true,
          link: SemiTextLink(onTap: () => taps++),
        ),
      ),
    );
    expect(textStyle(t).color, config.linkDisabledColor);
    await t.tap(find.text('disabled'));
    expect(taps, 0);
    await t.pumpWidget(
      themed(
        const SemiText('style', disabled: true, style: TextStyle(color: value)),
      ),
    );
    expect(textStyle(t).color, value);
  });
}

void typographyMetricTests() {
  test('titleFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(titleFontWeight: FontWeight.w900);
    expect(empty.copyWith(titleFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(titleFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).titleFontWeight,
      FontWeight.w900,
    );
  });
  test('linkFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(linkFontWeight: FontWeight.w900);
    expect(empty.copyWith(linkFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(linkFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).linkFontWeight,
      FontWeight.w900,
    );
  });
  test('strongFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(strongFontWeight: FontWeight.w900);
    expect(empty.copyWith(strongFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(strongFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).strongFontWeight,
      FontWeight.w900,
    );
  });
  test(
    'paragraphExtendedLineHeight nullable copy merge equality hash resolve',
    () {
      const empty = SemiTypographyThemeData();
      const patch = SemiTypographyThemeData(paragraphExtendedLineHeight: 37.0);
      expect(empty.copyWith(paragraphExtendedLineHeight: 37.0), patch);
      expect(patch.copyWith(), patch);
      expect(patch.merge(empty), patch);
      expect(empty.merge(patch), patch);
      expect(
        patch.hashCode,
        empty.copyWith(paragraphExtendedLineHeight: 37.0).hashCode,
      );
      expect(patch, isNot(empty));
      expect(
        patch.resolve(const SemiThemeData.light()).paragraphExtendedLineHeight,
        37.0,
      );
    },
  );
  test(
    'normalTextRegularFontWeight nullable copy merge equality hash resolve',
    () {
      const empty = SemiTypographyThemeData();
      const patch = SemiTypographyThemeData(
        normalTextRegularFontWeight: FontWeight.w900,
      );
      expect(
        empty.copyWith(normalTextRegularFontWeight: FontWeight.w900),
        patch,
      );
      expect(patch.copyWith(), patch);
      expect(patch.merge(empty), patch);
      expect(empty.merge(patch), patch);
      expect(
        patch.hashCode,
        empty.copyWith(normalTextRegularFontWeight: FontWeight.w900).hashCode,
      );
      expect(patch, isNot(empty));
      expect(
        patch.resolve(const SemiThemeData.light()).normalTextRegularFontWeight,
        FontWeight.w900,
      );
    },
  );
  test(
    'smallTextRegularFontWeight nullable copy merge equality hash resolve',
    () {
      const empty = SemiTypographyThemeData();
      const patch = SemiTypographyThemeData(
        smallTextRegularFontWeight: FontWeight.w900,
      );
      expect(
        empty.copyWith(smallTextRegularFontWeight: FontWeight.w900),
        patch,
      );
      expect(patch.copyWith(), patch);
      expect(patch.merge(empty), patch);
      expect(empty.merge(patch), patch);
      expect(
        patch.hashCode,
        empty.copyWith(smallTextRegularFontWeight: FontWeight.w900).hashCode,
      );
      expect(patch, isNot(empty));
      expect(
        patch.resolve(const SemiThemeData.light()).smallTextRegularFontWeight,
        FontWeight.w900,
      );
    },
  );
  test('normalParagraphRegularFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      normalParagraphRegularFontWeight: FontWeight.w900,
    );
    expect(
      empty.copyWith(normalParagraphRegularFontWeight: FontWeight.w900),
      patch,
    );
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty
          .copyWith(normalParagraphRegularFontWeight: FontWeight.w900)
          .hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch
          .resolve(const SemiThemeData.light())
          .normalParagraphRegularFontWeight,
      FontWeight.w900,
    );
  });
  test(
    'smallParagraphRegularFontWeight nullable copy merge equality hash resolve',
    () {
      const empty = SemiTypographyThemeData();
      const patch = SemiTypographyThemeData(
        smallParagraphRegularFontWeight: FontWeight.w900,
      );
      expect(
        empty.copyWith(smallParagraphRegularFontWeight: FontWeight.w900),
        patch,
      );
      expect(patch.copyWith(), patch);
      expect(patch.merge(empty), patch);
      expect(empty.merge(patch), patch);
      expect(
        patch.hashCode,
        empty
            .copyWith(smallParagraphRegularFontWeight: FontWeight.w900)
            .hashCode,
      );
      expect(patch, isNot(empty));
      expect(
        patch
            .resolve(const SemiThemeData.light())
            .smallParagraphRegularFontWeight,
        FontWeight.w900,
      );
    },
  );
  test('title1FontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(title1FontWeight: FontWeight.w900);
    expect(empty.copyWith(title1FontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title1FontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title1FontWeight,
      FontWeight.w900,
    );
  });
  test('title2FontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(title2FontWeight: FontWeight.w900);
    expect(empty.copyWith(title2FontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title2FontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title2FontWeight,
      FontWeight.w900,
    );
  });
  test('title3FontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(title3FontWeight: FontWeight.w900);
    expect(empty.copyWith(title3FontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title3FontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title3FontWeight,
      FontWeight.w900,
    );
  });
  test('title4FontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(title4FontWeight: FontWeight.w900);
    expect(empty.copyWith(title4FontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title4FontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title4FontWeight,
      FontWeight.w900,
    );
  });
  test('title5FontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(title5FontWeight: FontWeight.w900);
    expect(empty.copyWith(title5FontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title5FontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title5FontWeight,
      FontWeight.w900,
    );
  });
  test('title6FontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(title6FontWeight: FontWeight.w900);
    expect(empty.copyWith(title6FontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title6FontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title6FontWeight,
      FontWeight.w900,
    );
  });
  test('title1LightFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title1LightFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title1LightFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title1LightFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title1LightFontWeight,
      FontWeight.w900,
    );
  });
  test('title2LightFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title2LightFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title2LightFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title2LightFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title2LightFontWeight,
      FontWeight.w900,
    );
  });
  test('title3LightFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title3LightFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title3LightFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title3LightFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title3LightFontWeight,
      FontWeight.w900,
    );
  });
  test('title4LightFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title4LightFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title4LightFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title4LightFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title4LightFontWeight,
      FontWeight.w900,
    );
  });
  test('title5LightFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title5LightFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title5LightFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title5LightFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title5LightFontWeight,
      FontWeight.w900,
    );
  });
  test('title6LightFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title6LightFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title6LightFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title6LightFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title6LightFontWeight,
      FontWeight.w900,
    );
  });
  test('title1RegularFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title1RegularFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title1RegularFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title1RegularFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title1RegularFontWeight,
      FontWeight.w900,
    );
  });
  test('title2RegularFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title2RegularFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title2RegularFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title2RegularFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title2RegularFontWeight,
      FontWeight.w900,
    );
  });
  test('title3RegularFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title3RegularFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title3RegularFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title3RegularFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title3RegularFontWeight,
      FontWeight.w900,
    );
  });
  test('title4RegularFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title4RegularFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title4RegularFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title4RegularFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title4RegularFontWeight,
      FontWeight.w900,
    );
  });
  test('title5RegularFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title5RegularFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title5RegularFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title5RegularFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title5RegularFontWeight,
      FontWeight.w900,
    );
  });
  test('title6RegularFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title6RegularFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title6RegularFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title6RegularFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title6RegularFontWeight,
      FontWeight.w900,
    );
  });
  test('title1MediumFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title1MediumFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title1MediumFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title1MediumFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title1MediumFontWeight,
      FontWeight.w900,
    );
  });
  test('title2MediumFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title2MediumFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title2MediumFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title2MediumFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title2MediumFontWeight,
      FontWeight.w900,
    );
  });
  test('title3MediumFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title3MediumFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title3MediumFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title3MediumFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title3MediumFontWeight,
      FontWeight.w900,
    );
  });
  test('title4MediumFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title4MediumFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title4MediumFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title4MediumFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title4MediumFontWeight,
      FontWeight.w900,
    );
  });
  test('title5MediumFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title5MediumFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title5MediumFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title5MediumFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title5MediumFontWeight,
      FontWeight.w900,
    );
  });
  test('title6MediumFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title6MediumFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title6MediumFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title6MediumFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title6MediumFontWeight,
      FontWeight.w900,
    );
  });
  test(
    'title1SemiboldFontWeight nullable copy merge equality hash resolve',
    () {
      const empty = SemiTypographyThemeData();
      const patch = SemiTypographyThemeData(
        title1SemiboldFontWeight: FontWeight.w900,
      );
      expect(empty.copyWith(title1SemiboldFontWeight: FontWeight.w900), patch);
      expect(patch.copyWith(), patch);
      expect(patch.merge(empty), patch);
      expect(empty.merge(patch), patch);
      expect(
        patch.hashCode,
        empty.copyWith(title1SemiboldFontWeight: FontWeight.w900).hashCode,
      );
      expect(patch, isNot(empty));
      expect(
        patch.resolve(const SemiThemeData.light()).title1SemiboldFontWeight,
        FontWeight.w900,
      );
    },
  );
  test(
    'title2SemiboldFontWeight nullable copy merge equality hash resolve',
    () {
      const empty = SemiTypographyThemeData();
      const patch = SemiTypographyThemeData(
        title2SemiboldFontWeight: FontWeight.w900,
      );
      expect(empty.copyWith(title2SemiboldFontWeight: FontWeight.w900), patch);
      expect(patch.copyWith(), patch);
      expect(patch.merge(empty), patch);
      expect(empty.merge(patch), patch);
      expect(
        patch.hashCode,
        empty.copyWith(title2SemiboldFontWeight: FontWeight.w900).hashCode,
      );
      expect(patch, isNot(empty));
      expect(
        patch.resolve(const SemiThemeData.light()).title2SemiboldFontWeight,
        FontWeight.w900,
      );
    },
  );
  test(
    'title3SemiboldFontWeight nullable copy merge equality hash resolve',
    () {
      const empty = SemiTypographyThemeData();
      const patch = SemiTypographyThemeData(
        title3SemiboldFontWeight: FontWeight.w900,
      );
      expect(empty.copyWith(title3SemiboldFontWeight: FontWeight.w900), patch);
      expect(patch.copyWith(), patch);
      expect(patch.merge(empty), patch);
      expect(empty.merge(patch), patch);
      expect(
        patch.hashCode,
        empty.copyWith(title3SemiboldFontWeight: FontWeight.w900).hashCode,
      );
      expect(patch, isNot(empty));
      expect(
        patch.resolve(const SemiThemeData.light()).title3SemiboldFontWeight,
        FontWeight.w900,
      );
    },
  );
  test(
    'title4SemiboldFontWeight nullable copy merge equality hash resolve',
    () {
      const empty = SemiTypographyThemeData();
      const patch = SemiTypographyThemeData(
        title4SemiboldFontWeight: FontWeight.w900,
      );
      expect(empty.copyWith(title4SemiboldFontWeight: FontWeight.w900), patch);
      expect(patch.copyWith(), patch);
      expect(patch.merge(empty), patch);
      expect(empty.merge(patch), patch);
      expect(
        patch.hashCode,
        empty.copyWith(title4SemiboldFontWeight: FontWeight.w900).hashCode,
      );
      expect(patch, isNot(empty));
      expect(
        patch.resolve(const SemiThemeData.light()).title4SemiboldFontWeight,
        FontWeight.w900,
      );
    },
  );
  test(
    'title5SemiboldFontWeight nullable copy merge equality hash resolve',
    () {
      const empty = SemiTypographyThemeData();
      const patch = SemiTypographyThemeData(
        title5SemiboldFontWeight: FontWeight.w900,
      );
      expect(empty.copyWith(title5SemiboldFontWeight: FontWeight.w900), patch);
      expect(patch.copyWith(), patch);
      expect(patch.merge(empty), patch);
      expect(empty.merge(patch), patch);
      expect(
        patch.hashCode,
        empty.copyWith(title5SemiboldFontWeight: FontWeight.w900).hashCode,
      );
      expect(patch, isNot(empty));
      expect(
        patch.resolve(const SemiThemeData.light()).title5SemiboldFontWeight,
        FontWeight.w900,
      );
    },
  );
  test(
    'title6SemiboldFontWeight nullable copy merge equality hash resolve',
    () {
      const empty = SemiTypographyThemeData();
      const patch = SemiTypographyThemeData(
        title6SemiboldFontWeight: FontWeight.w900,
      );
      expect(empty.copyWith(title6SemiboldFontWeight: FontWeight.w900), patch);
      expect(patch.copyWith(), patch);
      expect(patch.merge(empty), patch);
      expect(empty.merge(patch), patch);
      expect(
        patch.hashCode,
        empty.copyWith(title6SemiboldFontWeight: FontWeight.w900).hashCode,
      );
      expect(patch, isNot(empty));
      expect(
        patch.resolve(const SemiThemeData.light()).title6SemiboldFontWeight,
        FontWeight.w900,
      );
    },
  );
  test('title1BoldFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title1BoldFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title1BoldFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title1BoldFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title1BoldFontWeight,
      FontWeight.w900,
    );
  });
  test('title2BoldFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title2BoldFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title2BoldFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title2BoldFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title2BoldFontWeight,
      FontWeight.w900,
    );
  });
  test('title3BoldFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title3BoldFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title3BoldFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title3BoldFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title3BoldFontWeight,
      FontWeight.w900,
    );
  });
  test('title4BoldFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title4BoldFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title4BoldFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title4BoldFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title4BoldFontWeight,
      FontWeight.w900,
    );
  });
  test('title5BoldFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title5BoldFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title5BoldFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title5BoldFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title5BoldFontWeight,
      FontWeight.w900,
    );
  });
  test('title6BoldFontWeight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      title6BoldFontWeight: FontWeight.w900,
    );
    expect(empty.copyWith(title6BoldFontWeight: FontWeight.w900), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(title6BoldFontWeight: FontWeight.w900).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).title6BoldFontWeight,
      FontWeight.w900,
    );
  });
  test('iconPrefixMarginRight nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(iconPrefixMarginRight: 37.0);
    expect(empty.copyWith(iconPrefixMarginRight: 37.0), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(iconPrefixMarginRight: 37.0).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).iconPrefixMarginRight,
      37.0,
    );
  });
  test('expandTextMarginLeft nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(expandTextMarginLeft: 37.0);
    expect(empty.copyWith(expandTextMarginLeft: 37.0), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(patch.hashCode, empty.copyWith(expandTextMarginLeft: 37.0).hashCode);
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).expandTextMarginLeft,
      37.0,
    );
  });
  test('copyIconMarginLeft nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(copyIconMarginLeft: 37.0);
    expect(empty.copyWith(copyIconMarginLeft: 37.0), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(patch.hashCode, empty.copyWith(copyIconMarginLeft: 37.0).hashCode);
    expect(patch, isNot(empty));
    expect(patch.resolve(const SemiThemeData.light()).copyIconMarginLeft, 37.0);
  });
  test('copyIconPadding nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(copyIconPadding: EdgeInsets.all(7));
    expect(empty.copyWith(copyIconPadding: EdgeInsets.all(7)), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(copyIconPadding: EdgeInsets.all(7)).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).copyIconPadding,
      EdgeInsets.all(7),
    );
  });
  test('titleH1Margin nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(titleH1Margin: EdgeInsets.all(7));
    expect(empty.copyWith(titleH1Margin: EdgeInsets.all(7)), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(titleH1Margin: EdgeInsets.all(7)).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).titleH1Margin,
      EdgeInsets.all(7),
    );
  });
  test('titleH2Margin nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(titleH2Margin: EdgeInsets.all(7));
    expect(empty.copyWith(titleH2Margin: EdgeInsets.all(7)), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(titleH2Margin: EdgeInsets.all(7)).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).titleH2Margin,
      EdgeInsets.all(7),
    );
  });
  test('titleH3Margin nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(titleH3Margin: EdgeInsets.all(7));
    expect(empty.copyWith(titleH3Margin: EdgeInsets.all(7)), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(titleH3Margin: EdgeInsets.all(7)).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).titleH3Margin,
      EdgeInsets.all(7),
    );
  });
  test('titleH4Margin nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(titleH4Margin: EdgeInsets.all(7));
    expect(empty.copyWith(titleH4Margin: EdgeInsets.all(7)), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(titleH4Margin: EdgeInsets.all(7)).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).titleH4Margin,
      EdgeInsets.all(7),
    );
  });
  test('titleH5Margin nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(titleH5Margin: EdgeInsets.all(7));
    expect(empty.copyWith(titleH5Margin: EdgeInsets.all(7)), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(titleH5Margin: EdgeInsets.all(7)).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).titleH5Margin,
      EdgeInsets.all(7),
    );
  });
  test('titleH6Margin nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(titleH6Margin: EdgeInsets.all(7));
    expect(empty.copyWith(titleH6Margin: EdgeInsets.all(7)), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(titleH6Margin: EdgeInsets.all(7)).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).titleH6Margin,
      EdgeInsets.all(7),
    );
  });
  test('titleParagraphMargin nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(
      titleParagraphMargin: EdgeInsets.all(7),
    );
    expect(empty.copyWith(titleParagraphMargin: EdgeInsets.all(7)), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(titleParagraphMargin: EdgeInsets.all(7)).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).titleParagraphMargin,
      EdgeInsets.all(7),
    );
  });
  test('codeBorderWidth nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(codeBorderWidth: 37.0);
    expect(empty.copyWith(codeBorderWidth: 37.0), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(patch.hashCode, empty.copyWith(codeBorderWidth: 37.0).hashCode);
    expect(patch, isNot(empty));
    expect(patch.resolve(const SemiThemeData.light()).codeBorderWidth, 37.0);
  });
  test('linkBorderWidth nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(linkBorderWidth: 37.0);
    expect(empty.copyWith(linkBorderWidth: 37.0), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(patch.hashCode, empty.copyWith(linkBorderWidth: 37.0).hashCode);
    expect(patch, isNot(empty));
    expect(patch.resolve(const SemiThemeData.light()).linkBorderWidth, 37.0);
  });
  test('codeBorderRadius nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(codeBorderRadius: 37.0);
    expect(empty.copyWith(codeBorderRadius: 37.0), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(patch.hashCode, empty.copyWith(codeBorderRadius: 37.0).hashCode);
    expect(patch, isNot(empty));
    expect(patch.resolve(const SemiThemeData.light()).codeBorderRadius, 37.0);
  });
  test('fontSizeRegular nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(fontSizeRegular: 37.0);
    expect(empty.copyWith(fontSizeRegular: 37.0), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(patch.hashCode, empty.copyWith(fontSizeRegular: 37.0).hashCode);
    expect(patch, isNot(empty));
    expect(patch.resolve(const SemiThemeData.light()).fontSizeRegular, 37.0);
  });
  test('fontSizeSmall nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(fontSizeSmall: 37.0);
    expect(empty.copyWith(fontSizeSmall: 37.0), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(patch.hashCode, empty.copyWith(fontSizeSmall: 37.0).hashCode);
    expect(patch, isNot(empty));
    expect(patch.resolve(const SemiThemeData.light()).fontSizeSmall, 37.0);
  });
  test('lineHeightRegular nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(lineHeightRegular: 37.0);
    expect(empty.copyWith(lineHeightRegular: 37.0), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(patch.hashCode, empty.copyWith(lineHeightRegular: 37.0).hashCode);
    expect(patch, isNot(empty));
    expect(patch.resolve(const SemiThemeData.light()).lineHeightRegular, 37.0);
  });
  test('lineHeightSmall nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(lineHeightSmall: 37.0);
    expect(empty.copyWith(lineHeightSmall: 37.0), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(patch.hashCode, empty.copyWith(lineHeightSmall: 37.0).hashCode);
    expect(patch, isNot(empty));
    expect(patch.resolve(const SemiThemeData.light()).lineHeightSmall, 37.0);
  });
  test('fontSizeHeading1 nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(fontSizeHeading1: 37.0);
    expect(empty.copyWith(fontSizeHeading1: 37.0), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(patch.hashCode, empty.copyWith(fontSizeHeading1: 37.0).hashCode);
    expect(patch, isNot(empty));
    expect(patch.resolve(const SemiThemeData.light()).fontSizeHeading1, 37.0);
  });
  test('lineHeightHeading1 nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(lineHeightHeading1: 37.0);
    expect(empty.copyWith(lineHeightHeading1: 37.0), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(patch.hashCode, empty.copyWith(lineHeightHeading1: 37.0).hashCode);
    expect(patch, isNot(empty));
    expect(patch.resolve(const SemiThemeData.light()).lineHeightHeading1, 37.0);
  });
  test('fontSizeHeading2 nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(fontSizeHeading2: 37.0);
    expect(empty.copyWith(fontSizeHeading2: 37.0), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(patch.hashCode, empty.copyWith(fontSizeHeading2: 37.0).hashCode);
    expect(patch, isNot(empty));
    expect(patch.resolve(const SemiThemeData.light()).fontSizeHeading2, 37.0);
  });
  test('lineHeightHeading2 nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(lineHeightHeading2: 37.0);
    expect(empty.copyWith(lineHeightHeading2: 37.0), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(patch.hashCode, empty.copyWith(lineHeightHeading2: 37.0).hashCode);
    expect(patch, isNot(empty));
    expect(patch.resolve(const SemiThemeData.light()).lineHeightHeading2, 37.0);
  });
  test('fontSizeHeading3 nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(fontSizeHeading3: 37.0);
    expect(empty.copyWith(fontSizeHeading3: 37.0), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(patch.hashCode, empty.copyWith(fontSizeHeading3: 37.0).hashCode);
    expect(patch, isNot(empty));
    expect(patch.resolve(const SemiThemeData.light()).fontSizeHeading3, 37.0);
  });
  test('lineHeightHeading3 nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(lineHeightHeading3: 37.0);
    expect(empty.copyWith(lineHeightHeading3: 37.0), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(patch.hashCode, empty.copyWith(lineHeightHeading3: 37.0).hashCode);
    expect(patch, isNot(empty));
    expect(patch.resolve(const SemiThemeData.light()).lineHeightHeading3, 37.0);
  });
  test('fontSizeHeading4 nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(fontSizeHeading4: 37.0);
    expect(empty.copyWith(fontSizeHeading4: 37.0), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(patch.hashCode, empty.copyWith(fontSizeHeading4: 37.0).hashCode);
    expect(patch, isNot(empty));
    expect(patch.resolve(const SemiThemeData.light()).fontSizeHeading4, 37.0);
  });
  test('lineHeightHeading4 nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(lineHeightHeading4: 37.0);
    expect(empty.copyWith(lineHeightHeading4: 37.0), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(patch.hashCode, empty.copyWith(lineHeightHeading4: 37.0).hashCode);
    expect(patch, isNot(empty));
    expect(patch.resolve(const SemiThemeData.light()).lineHeightHeading4, 37.0);
  });
  test('fontSizeHeading5 nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(fontSizeHeading5: 37.0);
    expect(empty.copyWith(fontSizeHeading5: 37.0), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(patch.hashCode, empty.copyWith(fontSizeHeading5: 37.0).hashCode);
    expect(patch, isNot(empty));
    expect(patch.resolve(const SemiThemeData.light()).fontSizeHeading5, 37.0);
  });
  test('lineHeightHeading5 nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(lineHeightHeading5: 37.0);
    expect(empty.copyWith(lineHeightHeading5: 37.0), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(patch.hashCode, empty.copyWith(lineHeightHeading5: 37.0).hashCode);
    expect(patch, isNot(empty));
    expect(patch.resolve(const SemiThemeData.light()).lineHeightHeading5, 37.0);
  });
  test('fontSizeHeading6 nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(fontSizeHeading6: 37.0);
    expect(empty.copyWith(fontSizeHeading6: 37.0), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(patch.hashCode, empty.copyWith(fontSizeHeading6: 37.0).hashCode);
    expect(patch, isNot(empty));
    expect(patch.resolve(const SemiThemeData.light()).fontSizeHeading6, 37.0);
  });
  test('lineHeightHeading6 nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(lineHeightHeading6: 37.0);
    expect(empty.copyWith(lineHeightHeading6: 37.0), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(patch.hashCode, empty.copyWith(lineHeightHeading6: 37.0).hashCode);
    expect(patch, isNot(empty));
    expect(patch.resolve(const SemiThemeData.light()).lineHeightHeading6, 37.0);
  });
  test('codePadding nullable copy merge equality hash resolve', () {
    const empty = SemiTypographyThemeData();
    const patch = SemiTypographyThemeData(codePadding: EdgeInsets.all(7));
    expect(empty.copyWith(codePadding: EdgeInsets.all(7)), patch);
    expect(patch.copyWith(), patch);
    expect(patch.merge(empty), patch);
    expect(empty.merge(patch), patch);
    expect(
      patch.hashCode,
      empty.copyWith(codePadding: EdgeInsets.all(7)).hashCode,
    );
    expect(patch, isNot(empty));
    expect(
      patch.resolve(const SemiThemeData.light()).codePadding,
      EdgeInsets.all(7),
    );
  });
}

void typographyAcceptanceTests() {
  test(
    'all 58 real upstream declarations match documented defaults and sources',
    () {
      final root = Directory.current;
      final upstream =
          Platform.environment['SEMI_DESIGN_SOURCE'] ??
          '${root.parent.parent.path}/Html/semi-design';
      const source = 'packages/semi-foundation/typography/variables.scss';
      final text = File('$upstream/$source').readAsStringSync();
      var block = false;
      final declarations = <String>[];
      for (final line in text.split(String.fromCharCode(10))) {
        var active = line;
        if (active.contains('/*')) {
          block = true;
        }
        if (block) {
          if (active.contains('*/')) {
            block = false;
          }
          continue;
        }
        active = active.split('//').first.trim();
        if (active.startsWith(r'$font-typography_') ||
            active.startsWith(r'$spacing-typography_') ||
            active.startsWith(r'$radius-typography_') ||
            active.startsWith(r'$width-typography_')) {
          declarations.add(active);
        }
      }
      expect(declarations.length, 58);
      expect(declarations.toSet().length, 58);
      final fonts = declarations
          .where((v) => v.startsWith(r'$font-typography_'))
          .toList();
      expect(fonts.length, 44);
      expect(
        fonts.where((v) => v.split(':').first.endsWith('fontWeight')).length,
        43,
      );
      final code = File('lib/src/theme/semi_typography_theme_data.dart')
          .readAsStringSync();
      for (final declaration in declarations) {
        final parts = declaration.split(':');
        final name = parts.first;
        final value = parts.last.replaceAll(';', '').trim();
        final newline = String.fromCharCode(10);
        final expected =
            '/// `$name` defaults to `$value`.$newline  /// Source: `$source`.';
        expect(code.contains(expected), isTrue, reason: name);
      }
    },
  );

  test(
    'live global references and title dependency chain retain literal variants',
    () {
      final theme = SemiThemeData.light(
        typography: SemiTypographyTokens(
          fontWeightBold: FontWeight.w800,
          fontWeightRegular: FontWeight.w300,
          fontSizeSmall: 15,
          lineHeightSmall: 23,
          fontSizeRegular: 21,
          lineHeightRegular: 31,
          fontSizeHeading1: 41,
          lineHeightHeading1: 51,
          fontSizeHeading2: 42,
          lineHeightHeading2: 52,
          fontSizeHeading3: 43,
          lineHeightHeading3: 53,
          fontSizeHeading4: 44,
          lineHeightHeading4: 54,
          fontSizeHeading5: 45,
          lineHeightHeading5: 55,
          fontSizeHeading6: 46,
          lineHeightHeading6: 56,
        ),
      );
      final d = const SemiTypographyThemeData().resolve(theme);
      expect([
        d.titleFontWeight,
        d.linkFontWeight,
        d.strongFontWeight,
        d.title1FontWeight,
        d.title2FontWeight,
        d.title3FontWeight,
        d.title4FontWeight,
        d.title5FontWeight,
        d.title6FontWeight,
      ], everyElement(FontWeight.w800));
      expect([
        d.normalTextRegularFontWeight,
        d.smallTextRegularFontWeight,
        d.normalParagraphRegularFontWeight,
        d.smallParagraphRegularFontWeight,
      ], everyElement(FontWeight.w300));
      expect(
        [
          d.fontSizeRegular,
          d.lineHeightRegular,
          d.fontSizeSmall,
          d.lineHeightSmall,
        ],
        [21, 31, 15, 23],
      );
      expect(
        [
          d.fontSizeHeading1,
          d.fontSizeHeading2,
          d.fontSizeHeading3,
          d.fontSizeHeading4,
          d.fontSizeHeading5,
          d.fontSizeHeading6,
        ],
        [41, 42, 43, 44, 45, 46],
      );
      expect(
        [
          d.lineHeightHeading1,
          d.lineHeightHeading2,
          d.lineHeightHeading3,
          d.lineHeightHeading4,
          d.lineHeightHeading5,
          d.lineHeightHeading6,
        ],
        [51, 52, 53, 54, 55, 56],
      );
      final patch = const SemiTypographyThemeData(
        titleFontWeight: FontWeight.w100,
        title2FontWeight: FontWeight.w500,
        fontSizeRegular: 19,
      ).resolve(theme);
      expect(patch.title1FontWeight, FontWeight.w100);
      expect(patch.title2FontWeight, FontWeight.w500);
      expect(patch.title6FontWeight, FontWeight.w100);
      expect(patch.fontSizeRegular, 19);
      expect(patch.lineHeightRegular, 31);
      expect([
        patch.title1BoldFontWeight,
        patch.title2BoldFontWeight,
        patch.title3BoldFontWeight,
        patch.title4BoldFontWeight,
        patch.title5BoldFontWeight,
        patch.title6BoldFontWeight,
      ], everyElement(FontWeight.w700));
    },
  );
  testWidgets(
    'nested component patches inherit application and parent fields',
    (t) async {
      const leaf = SemiTypographyTheme(
        data: SemiTypographyThemeData(fontSizeSmall: 17),
        child: SemiText('nested-small', size: SemiTextSize.small),
      );
      Widget tree(double height) => host(
        SemiTypographyTheme(
          data: SemiTypographyThemeData(lineHeightSmall: height),
          child: leaf,
        ),
        theme: const SemiThemeData.light(
          components: SemiComponentThemes(
            typography: SemiTypographyThemeData(
              smallTextRegularFontWeight: FontWeight.w800,
              fontSizeSmall: 13,
            ),
          ),
        ),
      );
      await t.pumpWidget(tree(25));
      expect(textStyle(t).fontSize, 17);
      expect(textStyle(t).fontWeight, FontWeight.w800);
      expect(textStyle(t).height, 25 / 17);
      await t.pumpWidget(tree(29));
      expect(textStyle(t).height, 29 / 17);
      expect(textStyle(t).fontSize, 17);
      await t.pumpWidget(
        host(
          const SemiTypographyTheme(
            data: SemiTypographyThemeData(
              fontSizeRegular: 99,
              lineHeightRegular: 100,
            ),
            child: SemiText('inherit-metrics', size: SemiTextSize.inherit),
          ),
          style: const TextStyle(fontSize: 27, height: 1.8, fontFamily: 'host'),
        ),
      );
      expect(textStyle(t).fontSize, 27);
      expect(textStyle(t).height, 1.8);
      expect(textStyle(t).fontFamily, 'host');
    },
  );

  test("all 58 Sass defaults match declarations", () {
    final defaults = const SemiTypographyThemeData().resolve(
      const SemiThemeData.light(),
    );
    expect(
      defaults.titleFontWeight,
      FontWeight.w600,
      reason: r"$font-typography_title-fontWeight",
    );
    expect(
      defaults.linkFontWeight,
      FontWeight.w600,
      reason: r"$font-typography_link-fontWeight",
    );
    expect(
      defaults.strongFontWeight,
      FontWeight.w600,
      reason: r"$font-typography_strong-fontWeight",
    );
    expect(
      defaults.paragraphExtendedLineHeight,
      24.0,
      reason: r"$font-typography_paragraph_extended-lineHeight",
    );
    expect(
      defaults.normalTextRegularFontWeight,
      FontWeight.w400,
      reason: r"$font-typography_normalText-regular-fontWeight",
    );
    expect(
      defaults.smallTextRegularFontWeight,
      FontWeight.w400,
      reason: r"$font-typography_smallText-regular-fontWeight",
    );
    expect(
      defaults.normalParagraphRegularFontWeight,
      FontWeight.w400,
      reason: r"$font-typography_normalParagraph-regular-fontWeight",
    );
    expect(
      defaults.smallParagraphRegularFontWeight,
      FontWeight.w400,
      reason: r"$font-typography_smallParagraph-regular-fontWeight",
    );
    expect(
      defaults.title1FontWeight,
      FontWeight.w600,
      reason: r"$font-typography_title1-fontWeight",
    );
    expect(
      defaults.title2FontWeight,
      FontWeight.w600,
      reason: r"$font-typography_title2-fontWeight",
    );
    expect(
      defaults.title3FontWeight,
      FontWeight.w600,
      reason: r"$font-typography_title3-fontWeight",
    );
    expect(
      defaults.title4FontWeight,
      FontWeight.w600,
      reason: r"$font-typography_title4-fontWeight",
    );
    expect(
      defaults.title5FontWeight,
      FontWeight.w600,
      reason: r"$font-typography_title5-fontWeight",
    );
    expect(
      defaults.title6FontWeight,
      FontWeight.w600,
      reason: r"$font-typography_title6-fontWeight",
    );
    expect(
      defaults.title1LightFontWeight,
      FontWeight.w200,
      reason: r"$font-typography_title1-light-fontWeight",
    );
    expect(
      defaults.title2LightFontWeight,
      FontWeight.w200,
      reason: r"$font-typography_title2-light-fontWeight",
    );
    expect(
      defaults.title3LightFontWeight,
      FontWeight.w200,
      reason: r"$font-typography_title3-light-fontWeight",
    );
    expect(
      defaults.title4LightFontWeight,
      FontWeight.w200,
      reason: r"$font-typography_title4-light-fontWeight",
    );
    expect(
      defaults.title5LightFontWeight,
      FontWeight.w200,
      reason: r"$font-typography_title5-light-fontWeight",
    );
    expect(
      defaults.title6LightFontWeight,
      FontWeight.w200,
      reason: r"$font-typography_title6-light-fontWeight",
    );
    expect(
      defaults.title1RegularFontWeight,
      FontWeight.w400,
      reason: r"$font-typography_title1-regular-fontWeight",
    );
    expect(
      defaults.title2RegularFontWeight,
      FontWeight.w400,
      reason: r"$font-typography_title2-regular-fontWeight",
    );
    expect(
      defaults.title3RegularFontWeight,
      FontWeight.w400,
      reason: r"$font-typography_title3-regular-fontWeight",
    );
    expect(
      defaults.title4RegularFontWeight,
      FontWeight.w400,
      reason: r"$font-typography_title4-regular-fontWeight",
    );
    expect(
      defaults.title5RegularFontWeight,
      FontWeight.w400,
      reason: r"$font-typography_title5-regular-fontWeight",
    );
    expect(
      defaults.title6RegularFontWeight,
      FontWeight.w400,
      reason: r"$font-typography_title6-regular-fontWeight",
    );
    expect(
      defaults.title1MediumFontWeight,
      FontWeight.w500,
      reason: r"$font-typography_title1-medium-fontWeight",
    );
    expect(
      defaults.title2MediumFontWeight,
      FontWeight.w500,
      reason: r"$font-typography_title2-medium-fontWeight",
    );
    expect(
      defaults.title3MediumFontWeight,
      FontWeight.w500,
      reason: r"$font-typography_title3-medium-fontWeight",
    );
    expect(
      defaults.title4MediumFontWeight,
      FontWeight.w500,
      reason: r"$font-typography_title4-medium-fontWeight",
    );
    expect(
      defaults.title5MediumFontWeight,
      FontWeight.w500,
      reason: r"$font-typography_title5-medium-fontWeight",
    );
    expect(
      defaults.title6MediumFontWeight,
      FontWeight.w500,
      reason: r"$font-typography_title6-medium-fontWeight",
    );
    expect(
      defaults.title1SemiboldFontWeight,
      FontWeight.w600,
      reason: r"$font-typography_title1-semibold-fontWeight",
    );
    expect(
      defaults.title2SemiboldFontWeight,
      FontWeight.w600,
      reason: r"$font-typography_title2-semibold-fontWeight",
    );
    expect(
      defaults.title3SemiboldFontWeight,
      FontWeight.w600,
      reason: r"$font-typography_title3-semibold-fontWeight",
    );
    expect(
      defaults.title4SemiboldFontWeight,
      FontWeight.w600,
      reason: r"$font-typography_title4-semibold-fontWeight",
    );
    expect(
      defaults.title5SemiboldFontWeight,
      FontWeight.w600,
      reason: r"$font-typography_title5-semibold-fontWeight",
    );
    expect(
      defaults.title6SemiboldFontWeight,
      FontWeight.w600,
      reason: r"$font-typography_title6-semibold-fontWeight",
    );
    expect(
      defaults.title1BoldFontWeight,
      FontWeight.w700,
      reason: r"$font-typography_title1-bold-fontWeight",
    );
    expect(
      defaults.title2BoldFontWeight,
      FontWeight.w700,
      reason: r"$font-typography_title2-bold-fontWeight",
    );
    expect(
      defaults.title3BoldFontWeight,
      FontWeight.w700,
      reason: r"$font-typography_title3-bold-fontWeight",
    );
    expect(
      defaults.title4BoldFontWeight,
      FontWeight.w700,
      reason: r"$font-typography_title4-bold-fontWeight",
    );
    expect(
      defaults.title5BoldFontWeight,
      FontWeight.w700,
      reason: r"$font-typography_title5-bold-fontWeight",
    );
    expect(
      defaults.title6BoldFontWeight,
      FontWeight.w700,
      reason: r"$font-typography_title6-bold-fontWeight",
    );
    expect(
      defaults.iconPrefixMarginRight,
      4.0,
      reason: r"$spacing-typography_iconPrefix-marginRight",
    );
    expect(
      defaults.expandTextMarginLeft,
      8.0,
      reason: r"$spacing-typography_expandText-marginLeft",
    );
    expect(
      defaults.copyIconMarginLeft,
      4.0,
      reason: r"$spacing-typography_copyIcon-marginLeft",
    );
    expect(
      defaults.copyIconPadding,
      EdgeInsets.zero,
      reason: r"$spacing-typography_copyIcon-padding",
    );
    expect(
      defaults.titleH1Margin,
      EdgeInsets.zero,
      reason: r"$spacing-typography_title_h1-margin",
    );
    expect(
      defaults.titleH2Margin,
      EdgeInsets.zero,
      reason: r"$spacing-typography_title_h2-margin",
    );
    expect(
      defaults.titleH3Margin,
      EdgeInsets.zero,
      reason: r"$spacing-typography_title_h3-margin",
    );
    expect(
      defaults.titleH4Margin,
      EdgeInsets.zero,
      reason: r"$spacing-typography_title_h4-margin",
    );
    expect(
      defaults.titleH5Margin,
      EdgeInsets.zero,
      reason: r"$spacing-typography_title_h5-margin",
    );
    expect(
      defaults.titleH6Margin,
      EdgeInsets.zero,
      reason: r"$spacing-typography_title_h6-margin",
    );
    expect(
      defaults.titleParagraphMargin,
      EdgeInsets.zero,
      reason: r"$spacing-typography_title_paragraph-margin",
    );
    expect(
      defaults.codeBorderWidth,
      1.0,
      reason: r"$width-typography_code-border",
    );
    expect(
      defaults.linkBorderWidth,
      1.0,
      reason: r"$width-typography_link-border",
    );
    expect(defaults.codeBorderRadius, 2.0, reason: r"$radius-typography_code");
  });
  testWidgets('same brightness metrics notify const leaves and local patches', (
    t,
  ) async {
    const leaf = SemiTypographyTheme(
      data: SemiTypographyThemeData(codeBorderRadius: 9),
      child: SemiText('live', code: true),
    );
    Widget tree(double size, double line, FontWeight weight, double? local) =>
        host(
          SemiTypographyTheme(
            data: SemiTypographyThemeData(fontSizeRegular: local),
            child: leaf,
          ),
          theme: SemiThemeData.light(
            typography: SemiTypographyTokens(
              fontSizeRegular: size,
              lineHeightRegular: line,
              fontWeightRegular: weight,
            ),
            components: const SemiComponentThemes(
              typography: SemiTypographyThemeData(codeBorderWidth: 3),
            ),
          ),
        );
    await t.pumpWidget(tree(14, 20, FontWeight.w400, null));
    await t.pumpWidget(tree(18, 27, FontWeight.w300, null));
    expect(textStyle(t).fontSize, 18);
    expect(textStyle(t).height, 1.5);
    expect(textStyle(t).fontWeight, FontWeight.w300);
    await t.pumpWidget(tree(22, 33, FontWeight.w500, 16));
    expect(textStyle(t).fontSize, 16);
    expect(textStyle(t).height, 33 / 16);
    expect(textStyle(t).fontWeight, FontWeight.w500);
    await t.pumpWidget(tree(22, 33, FontWeight.w500, 19));
    expect(textStyle(t).fontSize, 19);
    final box =
        t.widget<DecoratedBox>(find.byType(DecoratedBox)).decoration
            as BoxDecoration;
    expect(box.borderRadius, BorderRadius.circular(9));
    expect((box.border as Border).top.width, 3);
  });
  testWidgets('code and icon configured metrics affect actual layout', (
    t,
  ) async {
    const iconKey = ValueKey('metric-icon');
    await t.pumpWidget(
      host(
        const SemiTypographyTheme(
          data: SemiTypographyThemeData(
            codePadding: EdgeInsets.fromLTRB(11, 7, 13, 9),
            codeBorderRadius: 6,
            codeBorderWidth: 3,
            iconPrefixMarginRight: 17,
          ),
          child: SemiText(
            'code-metrics',
            code: true,
            icon: SizedBox(key: iconKey, width: 10, height: 10),
          ),
        ),
      ),
    );
    final text = t.getRect(find.text('code-metrics'));
    final icon = t.getRect(find.byKey(iconKey));
    final outer = t.getRect(find.byType(DecoratedBox));
    final row = t.getRect(find.byType(Row));
    expect(text.left - icon.right, 17);
    expect(row.left - outer.left, 11);
    expect(outer.right - row.right, 13);
    expect(row.top - outer.top, 7);
    expect(outer.bottom - row.bottom, 9);
    final box =
        t.widget<DecoratedBox>(find.byType(DecoratedBox)).decoration
            as BoxDecoration;
    expect(box.borderRadius, BorderRadius.circular(6));
    expect((box.border as Border).top.width, 3);
  });
  testWidgets('link configured underline width and weight preserve geometry', (
    t,
  ) async {
    await t.pumpWidget(
      host(
        SemiTypographyTheme(
          data: const SemiTypographyThemeData(
            linkBorderWidth: 3,
            linkFontWeight: FontWeight.w800,
          ),
          child: SemiText(
            'link-metrics',
            underline: true,
            link: SemiTextLink(onTap: () {}),
          ),
        ),
      ),
    );
    final before = t.getRect(find.text('link-metrics'));
    expect(textStyle(t).fontWeight, FontWeight.w800);
    expect(textStyle(t).decoration, TextDecoration.none);
    final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(t.getCenter(find.text('link-metrics')));
    await t.pump();
    expect(textStyle(t).decoration, TextDecoration.underline);
    expect(textStyle(t).decorationThickness, 3);
    expect(t.getRect(find.text('link-metrics')), before);
    await mouse.removePointer();
  });
  testWidgets('all heading margins weights and explicit priorities apply', (
    t,
  ) async {
    const patch = SemiTypographyThemeData(
      titleFontWeight: FontWeight.w300,
      title1FontWeight: FontWeight.w100,
      title2FontWeight: FontWeight.w200,
      title3FontWeight: FontWeight.w400,
      title4FontWeight: FontWeight.w500,
      title5FontWeight: FontWeight.w700,
      title6FontWeight: FontWeight.w800,
      titleH1Margin: EdgeInsets.all(1),
      titleH2Margin: EdgeInsets.all(2),
      titleH3Margin: EdgeInsets.all(3),
      titleH4Margin: EdgeInsets.all(4),
      titleH5Margin: EdgeInsets.all(5),
      titleH6Margin: EdgeInsets.all(6),
      strongFontWeight: FontWeight.w900,
    );
    final weights = [
      FontWeight.w100,
      FontWeight.w200,
      FontWeight.w400,
      FontWeight.w500,
      FontWeight.w700,
      FontWeight.w800,
    ];
    for (var h = 1; h <= 6; h++) {
      await t.pumpWidget(
        host(
          SemiTypographyTheme(
            data: patch,
            child: SemiTitle('title-metrics', heading: h),
          ),
        ),
      );
      expect(textStyle(t).fontWeight, weights[h - 1]);
      final padding = find.byType(Padding);
      expect(t.widget<Padding>(padding).padding, EdgeInsets.all(h.toDouble()));
      expect(
        t.getRect(find.text('title-metrics')).left - t.getRect(padding).left,
        h,
      );
    }
    await t.pumpWidget(
      host(
        const SemiTypographyTheme(
          data: patch,
          child: SemiTitle('title-metrics', strong: true),
        ),
      ),
    );
    expect(textStyle(t).fontWeight, FontWeight.w900);
    await t.pumpWidget(
      host(
        const SemiTypographyTheme(
          data: patch,
          child: SemiTitle(
            'title-metrics',
            strong: true,
            weight: FontWeight.w600,
          ),
        ),
      ),
    );
    expect(textStyle(t).fontWeight, FontWeight.w600);
    await t.pumpWidget(
      host(
        const SemiTypographyTheme(
          data: patch,
          child: SemiTitle(
            'title-metrics',
            weight: FontWeight.w600,
            style: TextStyle(
              fontSize: 37,
              height: 2,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
    expect(textStyle(t).fontSize, 37);
    expect(textStyle(t).height, 2);
    expect(textStyle(t).fontWeight, FontWeight.w400);
  });
}
