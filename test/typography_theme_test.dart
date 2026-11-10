import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

import 'semi_text_test.dart' show host, textStyle;

void main() {
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
