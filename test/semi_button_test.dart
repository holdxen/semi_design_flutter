import 'dart:ui' show Tristate;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show Material;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';
import 'package:semi_design_flutter/src/components/spin_svg.dart';

/// Docs/semi_button.md derivation table: expected state colors read from the
/// theme fields (the widget wiring is what these tests pin down).
SemiResolvedButtonThemeData resolve() =>
    const SemiButtonThemeData().resolve(const SemiThemeData.light());

Widget host(Widget child, {bool rtl = false, double textScale = 1.0}) =>
    SemiTheme(
      data: const SemiThemeData.light(),
      child: Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Center(child: child),
        ),
      ),
    );

BoxDecoration box(WidgetTester tester, {Finder? of}) {
  final match = find.descendant(
    of: of ?? find.byType(SemiButton),
    matching: find.byType(AnimatedContainer),
  );
  return tester.widget<AnimatedContainer>(match.first).decoration!
      as BoxDecoration;
}

Border borderOf(BoxDecoration d) => d.border! as Border;

Color? labelColor(WidgetTester tester) =>
    tester.widget<SemiText>(find.byType(SemiText)).style?.color;

SemiIcon svgSpinner(WidgetTester tester) => tester.widget<SemiIcon>(
  find.byWidgetPredicate((w) => w is SemiIcon && w.svgSource == semiSpinSvg),
);

double buttonHeight(WidgetTester tester, {Finder? of}) =>
    tester.getSize(of ?? find.byType(SemiButton)).height;

Color defaultBg(
  SemiResolvedButtonThemeData t,
  SemiButtonType type,
  SemiButtonVariant variant,
) {
  if (variant == SemiButtonVariant.light) return t.colorButtonLightBgDefault;
  if (variant == SemiButtonVariant.borderless ||
      variant == SemiButtonVariant.outline) {
    return const Color(0x00000000);
  }
  return switch (type) {
    SemiButtonType.primary => t.colorButtonPrimaryBgDefault,
    SemiButtonType.secondary => t.colorButtonSecondaryBgDefault,
    SemiButtonType.tertiary => t.colorButtonTertiaryBgDefault,
    SemiButtonType.warning => t.colorButtonWarningBgDefault,
    SemiButtonType.danger => t.colorButtonDangerBgDefault,
  };
}

Color defaultBorder(
  SemiResolvedButtonThemeData t,
  SemiButtonType type,
  SemiButtonVariant variant,
) {
  switch (variant) {
    case SemiButtonVariant.outline:
      return switch (type) {
        SemiButtonType.primary => t.colorButtonPrimaryOutlineBorderDefault,
        SemiButtonType.secondary => t.colorButtonSecondaryOutlineBorderDefault,
        SemiButtonType.tertiary => t.colorButtonTertiaryOutlineBorderDefault,
        SemiButtonType.warning => t.colorButtonWarningOutlineBorderDefault,
        SemiButtonType.danger => t.colorButtonDangerOutlineBorderDefault,
      };
    case SemiButtonVariant.light:
      return t.colorButtonLightBorderDefault;
    case SemiButtonVariant.borderless:
      return t.colorButtonBorderlessBorderDefault;
    case SemiButtonVariant.solid:
      return switch (type) {
        SemiButtonType.primary => t.colorButtonPrimaryBorderDefault,
        SemiButtonType.secondary => t.colorButtonSecondaryBorderDefault,
        SemiButtonType.tertiary => t.colorButtonTertiaryBorderDefault,
        SemiButtonType.warning => t.colorButtonWarningBorderDefault,
        SemiButtonType.danger => t.colorButtonDangerBorderDefault,
      };
  }
}

double borderWidthFor(
  SemiResolvedButtonThemeData t,
  SemiButtonVariant variant,
) => switch (variant) {
  SemiButtonVariant.outline => t.widthButtonOutlineBorder,
  SemiButtonVariant.light => t.widthButtonLightBorder,
  SemiButtonVariant.borderless => t.widthButtonBorderlessBorder,
  SemiButtonVariant.solid => t.widthButtonBorder,
};

Color defaultText(
  SemiResolvedButtonThemeData t,
  SemiButtonType type,
  SemiButtonVariant variant,
) {
  if (variant == SemiButtonVariant.solid) {
    return switch (type) {
      SemiButtonType.primary => t.colorButtonPrimaryTextDefault,
      SemiButtonType.secondary => t.colorButtonSecondaryTextDefault,
      SemiButtonType.tertiary => t.colorButtonTertiaryTextDefault,
      SemiButtonType.warning => t.colorButtonWarningTextDefault,
      SemiButtonType.danger => t.colorButtonDangerTextDefault,
    };
  }
  if (type == SemiButtonType.tertiary) {
    return t.colorButtonTertiarySolidTextDefault;
  }
  return switch (type) {
    SemiButtonType.primary => t.colorButtonPrimaryBorderlessTextDefault,
    SemiButtonType.secondary => t.colorButtonSecondaryBorderlessTextDefault,
    SemiButtonType.warning => t.colorButtonWarningBorderlessTextDefault,
    SemiButtonType.danger => t.colorButtonDangerBorderlessTextDefault,
    SemiButtonType.tertiary => throw StateError('unreachable'),
  };
}

Color disabledBg(
  SemiResolvedButtonThemeData t,
  SemiButtonType type,
  SemiButtonVariant variant,
) {
  switch (variant) {
    case SemiButtonVariant.solid:
      return switch (type) {
        SemiButtonType.primary => t.colorButtonDisabledPrimaryBgDefault,
        SemiButtonType.secondary => t.colorButtonDisabledSecondaryBgDefault,
        SemiButtonType.tertiary => t.colorButtonDisabledTertiaryBgDefault,
        SemiButtonType.warning => t.colorButtonDisabledWarningBgDefault,
        SemiButtonType.danger => t.colorButtonDisabledDangerBgDefault,
      };
    case SemiButtonVariant.light:
      return switch (type) {
        SemiButtonType.primary => t.colorButtonDisabledLightPrimaryBgDefault,
        SemiButtonType.secondary =>
          t.colorButtonDisabledLightSecondaryBgDefault,
        SemiButtonType.tertiary => t.colorButtonDisabledLightTertiaryBgDefault,
        SemiButtonType.warning => t.colorButtonDisabledLightWarningBgDefault,
        SemiButtonType.danger => t.colorButtonDisabledLightDangerBgDefault,
      };
    case SemiButtonVariant.borderless || SemiButtonVariant.outline:
      return const Color(0x00000000);
  }
}

Color disabledBorder(
  SemiResolvedButtonThemeData t,
  SemiButtonType type,
  SemiButtonVariant variant,
) {
  switch (variant) {
    case SemiButtonVariant.outline:
      return t.colorButtonDisabledOutlineBorderDefault;
    case SemiButtonVariant.light:
      return t.colorButtonLightBorderDefault;
    case SemiButtonVariant.borderless:
      return t.colorButtonBorderlessBorderDefault;
    case SemiButtonVariant.solid:
      return defaultBorder(t, type, variant);
  }
}

Color disabledText(SemiResolvedButtonThemeData t, SemiButtonVariant variant) =>
    switch (variant) {
      SemiButtonVariant.solid => t.colorButtonDisabledSolidTextDefault,
      SemiButtonVariant.light ||
      SemiButtonVariant.borderless => t.colorButtonDisabledTextDefault,
      SemiButtonVariant.outline => t.colorButtonDisabledOutlineTextDefault,
    };

Finder iconFinder(SemiIconData data) =>
    find.byWidgetPredicate((w) => w is SemiIcon && w.data == data);

Future<TestGesture> mouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

void main() {
  testWidgets('renders without Material widgets', (tester) async {
    await tester.pumpWidget(
      host(SemiButton('按钮', onPressed: () {}, icon: const SizedBox())),
    );
    expect(find.byType(Material), findsNothing);
    expect(find.text('按钮'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('state matrix default and disabled: 5 types x 4 variants', (
    tester,
  ) async {
    final t = resolve();
    for (final type in SemiButtonType.values) {
      for (final variant in SemiButtonVariant.values) {
        final slot = '$type/$variant';
        await tester.pumpWidget(
          host(SemiButton('x', type: type, variant: variant, onPressed: () {})),
        );
        final d = box(tester);
        expect(d.gradient, isNull, reason: slot);
        expect(d.color, defaultBg(t, type, variant), reason: '$slot bg');
        expect(
          borderOf(d).top.color,
          defaultBorder(t, type, variant),
          reason: '$slot border',
        );
        expect(
          borderOf(d).top.width,
          borderWidthFor(t, variant),
          reason: '$slot border width',
        );
        expect(
          labelColor(tester),
          defaultText(t, type, variant),
          reason: '$slot text',
        );
        await tester.pumpWidget(
          host(
            SemiButton(
              'x',
              type: type,
              variant: variant,
              disabled: true,
              onPressed: () {},
            ),
          ),
        );
        final off = box(tester);
        expect(
          off.color,
          disabledBg(t, type, variant),
          reason: '$slot disabled bg',
        );
        expect(
          borderOf(off).top.color,
          disabledBorder(t, type, variant),
          reason: '$slot disabled border',
        );
        expect(
          labelColor(tester),
          disabledText(t, variant),
          reason: '$slot disabled text',
        );
      }
    }
  });

  testWidgets('hover and pressed states use the per-state fields', (
    tester,
  ) async {
    final t = resolve();
    final gesture = await mouse(tester);
    Future<void> cycle(
      String slot,
      SemiButton button, {
      required Color hoverBg,
      required Color activeBg,
      Color? hoverBorder,
      Color? activeBorder,
    }) async {
      await tester.pumpWidget(host(button));
      await gesture.moveTo(tester.getCenter(find.byType(SemiButton)));
      await tester.pump();
      expect(box(tester).color, hoverBg, reason: '$slot hover bg');
      if (hoverBorder != null) {
        expect(
          borderOf(box(tester)).top.color,
          hoverBorder,
          reason: '$slot hover border',
        );
      }
      await gesture.down(tester.getCenter(find.byType(SemiButton)));
      await tester.pump();
      expect(box(tester).color, activeBg, reason: '$slot pressed bg');
      if (activeBorder != null) {
        expect(
          borderOf(box(tester)).top.color,
          activeBorder,
          reason: '$slot pressed border',
        );
      }
      await gesture.up();
      await tester.pump();
    }

    await cycle(
      'primary solid',
      SemiButton('x', variant: SemiButtonVariant.solid, onPressed: () {}),
      hoverBg: t.colorButtonPrimaryBgHover,
      activeBg: t.colorButtonPrimaryBgActive,
      hoverBorder: t.colorButtonPrimaryBorderHover,
      activeBorder: t.colorButtonPrimaryBorderActive,
    );
    await cycle(
      'primary light',
      SemiButton('x', variant: SemiButtonVariant.light, onPressed: () {}),
      hoverBg: t.colorButtonLightBgHover,
      activeBg: t.colorButtonLightBgActive,
      hoverBorder: t.colorButtonLightBorderHover,
      activeBorder: t.colorButtonLightBorderActive,
    );
    await cycle(
      'primary borderless',
      SemiButton('x', variant: SemiButtonVariant.borderless, onPressed: () {}),
      hoverBg: t.colorButtonBorderlessBgHover,
      activeBg: t.colorButtonBorderlessBgActive,
      hoverBorder: t.colorButtonBorderlessBorderHover,
      activeBorder: t.colorButtonBorderlessBorderActive,
    );
    await cycle(
      'primary outline',
      SemiButton('x', variant: SemiButtonVariant.outline, onPressed: () {}),
      hoverBg: t.colorButtonOutlineBgHover,
      activeBg: t.colorButtonOutlineBgActive,
    );
    // Quirk: `$color-button_danger-border-hover: var(--semi-color-danger)` —
    // the danger border hover keeps the base danger color while warning and
    // secondary follow their hover tokens.
    await cycle(
      'danger solid',
      SemiButton(
        'x',
        type: SemiButtonType.danger,
        variant: SemiButtonVariant.solid,
        onPressed: () {},
      ),
      hoverBg: t.colorButtonDangerBgHover,
      activeBg: t.colorButtonDangerBgActive,
      hoverBorder: t.colorButtonDangerBorderHover,
      activeBorder: t.colorButtonDangerBorderActive,
    );
    expect(
      t.colorButtonDangerBorderHover,
      const SemiThemeData.light().colors.colorDanger,
    );
    await cycle(
      'secondary solid',
      SemiButton(
        'x',
        type: SemiButtonType.secondary,
        variant: SemiButtonVariant.solid,
        onPressed: () {},
      ),
      hoverBg: t.colorButtonSecondaryBgHover,
      activeBg: t.colorButtonSecondaryBgActive,
      hoverBorder: t.colorButtonSecondaryBorderHover,
      activeBorder: t.colorButtonSecondaryBorderActive,
    );
    expect(
      t.colorButtonSecondaryBorderHover,
      const SemiThemeData.light().colors.colorSecondaryHover,
    );
    await cycle(
      'tertiary outline',
      SemiButton(
        'x',
        type: SemiButtonType.tertiary,
        variant: SemiButtonVariant.outline,
        onPressed: () {},
      ),
      hoverBg: t.colorButtonOutlineBgHover,
      activeBg: t.colorButtonOutlineBgActive,
    );
  });

  testWidgets('disabled wins over loading and hover', (tester) async {
    final t = resolve();
    await tester.pumpWidget(
      host(
        SemiButton(
          'x',
          disabled: true,
          loading: true,
          icon: const SizedBox(key: Key('icon')),
          onPressed: () {},
        ),
      ),
    );
    final gesture = await mouse(tester);
    await gesture.moveTo(tester.getCenter(find.byType(SemiButton)));
    await tester.pump();
    final d = box(tester);
    expect(
      d.color,
      disabledBg(t, SemiButtonType.primary, SemiButtonVariant.light),
    );
    expect(find.byKey(const Key('icon')), findsOneWidget);
    expect(iconFinder(SemiIcons.spin), findsNothing);
    expect(iconFinder(SemiIcons.aiLoading), findsNothing);
    final semantics = tester.getSemantics(find.byType(SemiButton));
    expect(semantics.flagsCollection.isEnabled, Tristate.isFalse);
  });

  testWidgets('colorful slots: primary and tertiary only', (tester) async {
    final t = resolve();
    // primary + solid: gradient background, white label, no text mask.
    await tester.pumpWidget(
      host(
        SemiButton(
          'AI',
          variant: SemiButtonVariant.solid,
          colorful: true,
          onPressed: () {},
        ),
      ),
    );
    var d = box(tester);
    expect(d.color, isNull);
    expect(d.gradient, isNotNull);
    expect(labelColor(tester), t.colorButtonPrimaryTextDefault);
    expect(find.byType(ShaderMask), findsNothing);

    // primary + light: gradient text, plain fill background.
    await tester.pumpWidget(
      host(SemiButton('AI', colorful: true, onPressed: () {})),
    );
    d = box(tester);
    expect(d.gradient, isNull);
    expect(d.color, t.colorButtonLightBgDefault);
    expect(find.byType(ShaderMask), findsOneWidget);

    // primary + borderless: gradient text.
    await tester.pumpWidget(
      host(
        SemiButton(
          'AI',
          colorful: true,
          variant: SemiButtonVariant.borderless,
          onPressed: () {},
        ),
      ),
    );
    expect(find.byType(ShaderMask), findsOneWidget);

    // primary + outline: ai-purple text and border, no text mask.
    await tester.pumpWidget(
      host(
        SemiButton(
          'AI',
          colorful: true,
          variant: SemiButtonVariant.outline,
          onPressed: () {},
        ),
      ),
    );
    d = box(tester);
    expect(find.byType(ShaderMask), findsNothing);
    expect(labelColor(tester), t.colorButtonPrimaryLightOutlineTextDefault);
    expect(borderOf(d).top.color, t.colorButtonPrimaryLightOutlineBorder);

    // tertiary + solid: gradient background and gradient text.
    await tester.pumpWidget(
      host(
        SemiButton(
          'AI',
          colorful: true,
          type: SemiButtonType.tertiary,
          variant: SemiButtonVariant.solid,
          onPressed: () {},
        ),
      ),
    );
    d = box(tester);
    expect(d.gradient, isNotNull);
    expect(find.byType(ShaderMask), findsOneWidget);
    expect(labelColor(tester), t.colorButtonTertiaryTextDefault);

    // tertiary + light/outline/borderless: text-1 label, no gradient.
    for (final variant in [
      SemiButtonVariant.light,
      SemiButtonVariant.outline,
      SemiButtonVariant.borderless,
    ]) {
      await tester.pumpWidget(
        host(
          SemiButton(
            'AI',
            colorful: true,
            type: SemiButtonType.tertiary,
            variant: variant,
            onPressed: () {},
          ),
        ),
      );
      expect(find.byType(ShaderMask), findsNothing, reason: '$variant');
      expect(
        labelColor(tester),
        t.colorButtonTertiarySolidTextDefault,
        reason: '$variant',
      );
    }

    // colorful is ignored outside primary/tertiary.
    await tester.pumpWidget(
      host(
        SemiButton(
          'AI',
          colorful: true,
          type: SemiButtonType.danger,
          variant: SemiButtonVariant.solid,
          onPressed: () {},
        ),
      ),
    );
    d = box(tester);
    expect(d.gradient, isNull);
    expect(d.color, t.colorButtonDangerBgDefault);
    expect(find.byType(ShaderMask), findsNothing);
  });

  testWidgets('loading replaces the icon, keeps the label and blocks taps', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      host(
        SemiButton(
          '保存',
          icon: const SizedBox(key: Key('icon')),
          loading: true,
          onPressed: () => taps++,
        ),
      ),
    );
    expect(find.byKey(const Key('icon')), findsNothing);
    expect(find.text('保存'), findsOneWidget);
    final spinner = find.byWidgetPredicate(
      (w) => w.runtimeType.toString() == '_ButtonSpinner',
    );
    expect(spinner, findsOneWidget);
    expect(svgSpinner(tester).color, isNotNull);
    await tester.tap(find.byType(SemiButton));
    await tester.pump();
    expect(taps, 0);
  });

  testWidgets('loading widens a text-only button (upstream behavior)', (
    tester,
  ) async {
    await tester.pumpWidget(host(SemiButton('保存', onPressed: () {})));
    final before = tester.getSize(find.byType(SemiButton)).width;
    await tester.pumpWidget(
      host(SemiButton('保存', loading: true, onPressed: () {})),
    );
    final after = tester.getSize(find.byType(SemiButton)).width;
    expect(after, greaterThan(before));
  });

  testWidgets('spinner selection: 600ms spin vs 1600ms ai loading', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(SemiButton('x', loading: true, onPressed: () {})),
    );
    var spinner = tester.widget(
      find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == '_ButtonSpinner',
      ),
    );
    expect((spinner as dynamic).duration, const Duration(milliseconds: 600));
    expect(svgSpinner(tester).color, isNotNull);
    await tester.pumpWidget(
      host(
        SemiButton(
          'x',
          loading: true,
          colorful: true,
          variant: SemiButtonVariant.light,
          onPressed: () {},
        ),
      ),
    );
    spinner = tester.widget(
      find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == '_ButtonSpinner',
      ),
    );
    expect((spinner as dynamic).duration, const Duration(milliseconds: 1600));
    expect(iconFinder(SemiIcons.aiLoading), findsOneWidget);
    // Upstream iconButton/index.tsx picks IconAILoading for every solid
    // tertiary loading button, colorful or not (kept as-is).
    await tester.pumpWidget(
      host(
        SemiButton(
          'x',
          loading: true,
          type: SemiButtonType.tertiary,
          variant: SemiButtonVariant.solid,
          onPressed: () {},
        ),
      ),
    );
    expect(iconFinder(SemiIcons.aiLoading), findsOneWidget);
  });

  testWidgets('block stretches, sizes map to 24/32/40, iconOnly is square', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 300,
          child: SemiButton('x', block: true, onPressed: () {}),
        ),
      ),
    );
    expect(tester.getSize(find.byType(SemiButton)).width, 300);
    for (final (size, height) in [
      (SemiButtonSize.small, 24.0),
      (SemiButtonSize.normal, 32.0),
      (SemiButtonSize.large, 40.0),
    ]) {
      await tester.pumpWidget(
        host(SemiButton('x', size: size, onPressed: () {})),
      );
      expect(buttonHeight(tester), height, reason: '$size');
      await tester.pumpWidget(
        host(
          SemiButton(null, size: size, icon: const Iconish(), onPressed: () {}),
        ),
      );
      final iconOnly = tester.getSize(find.byType(SemiButton));
      expect(iconOnly.width, height, reason: '$size iconOnly');
      expect(iconOnly.height, height, reason: '$size iconOnly');
    }
  });

  testWidgets('icon position and noHorizontalPadding', (tester) async {
    await tester.pumpWidget(
      host(
        SemiButton(
          'x',
          icon: const Iconish(key: Key('icon')),
          onPressed: () {},
        ),
      ),
    );
    final icon = tester.getCenter(find.byKey(const Key('icon')));
    final text = tester.getCenter(find.byType(SemiText));
    expect(icon.dx, lessThan(text.dx));
    await tester.pumpWidget(
      host(
        SemiButton(
          'x',
          icon: const Iconish(key: Key('icon')),
          iconPosition: SemiButtonIconPosition.right,
          onPressed: () {},
        ),
      ),
    );
    expect(
      tester.getCenter(find.byKey(const Key('icon'))).dx,
      greaterThan(tester.getCenter(find.byType(SemiText)).dx),
    );
    await tester.pumpWidget(
      host(
        SemiButton(
          'x',
          icon: const Iconish(key: Key('icon')),
          noHorizontalPadding: SemiButtonNoPadding.both,
          onPressed: () {},
        ),
      ),
    );
    var padding = tester
        .widget<AnimatedContainer>(find.byType(AnimatedContainer))
        .padding!
        .resolve(TextDirection.ltr);
    expect(padding.left, 0);
    expect(padding.right, 0);
    await tester.pumpWidget(
      host(
        SemiButton(
          'x',
          icon: const Iconish(key: Key('icon')),
          noHorizontalPadding: SemiButtonNoPadding.left,
          onPressed: () {},
        ),
      ),
    );
    padding = tester
        .widget<AnimatedContainer>(find.byType(AnimatedContainer))
        .padding!
        .resolve(TextDirection.ltr);
    expect(padding.left, 0);
    expect(padding.right, 12);
  });

  testWidgets('onPressed null keeps the enabled look but is not pressable', (
    tester,
  ) async {
    await tester.pumpWidget(host(const SemiButton('x')));
    final d = box(tester);
    expect(
      d.color,
      defaultBg(resolve(), SemiButtonType.primary, SemiButtonVariant.light),
    );
    await tester.tap(find.byType(SemiButton));
    await tester.pump();
    expect(tester.takeException(), isNull);
    final semantics = tester.getSemantics(find.byType(SemiButton));
    expect(semantics.flagsCollection.isEnabled, Tristate.isTrue);
  });

  testWidgets('onHoverChange reports hover transitions', (tester) async {
    final events = <bool>[];
    await tester.pumpWidget(
      host(SemiButton('x', onPressed: () {}, onHoverChange: events.add)),
    );
    final gesture = await mouse(tester);
    await gesture.moveTo(tester.getCenter(find.byType(SemiButton)));
    await tester.pump();
    await gesture.moveTo(Offset.zero);
    await tester.pump();
    expect(events, [true, false]);
  });

  testWidgets('group inserts dividers with the line color and rounds ends', (
    tester,
  ) async {
    final t = resolve();
    await tester.pumpWidget(
      host(
        SemiButtonGroup(
          children: [
            SemiButton('一', onPressed: () {}),
            SemiButton('二', onPressed: () {}),
            SemiButton('三', onPressed: () {}),
          ],
        ),
      ),
    );
    final lines = find.descendant(
      of: find.byType(SemiButtonGroup),
      matching: find.byType(ColoredBox),
    );
    // Two dividers × (full-height strip + centered grey tick).
    expect(lines, findsNWidgets(4));
    final strip = tester.widget<ColoredBox>(lines.at(0));
    final tick = tester.widget<ColoredBox>(lines.at(1));
    expect(strip.color, t.colorButtonLightBgDefault);
    expect(tick.color, t.colorButtonGroupBorderDefault);
    expect(
      tester.getSize(lines.at(0)),
      Size(t.widthButtonGroupBorder, t.heightButtonDefault),
    );
    expect(
      tester.getSize(lines.at(1)),
      Size(t.widthButtonGroupBorder, t.heightButtonGroupLineDefault),
    );
    final firstBox = box(tester, of: find.byType(SemiButton).at(0));
    final lastBox = box(tester, of: find.byType(SemiButton).at(2));
    final firstRadius = (firstBox.borderRadius! as BorderRadiusDirectional)
        .resolve(TextDirection.ltr);
    final lastRadius = (lastBox.borderRadius! as BorderRadiusDirectional)
        .resolve(TextDirection.ltr);
    final r = Radius.circular(t.radiusButtonGroup);
    expect(firstRadius.topLeft, r);
    expect(firstRadius.bottomLeft, r);
    expect(firstRadius.topRight, Radius.zero);
    expect(lastRadius.topRight, r);
    expect(lastRadius.bottomRight, r);
    expect(lastRadius.topLeft, Radius.zero);
  });

  testWidgets('group line colors follow type, disabled and theme', (
    tester,
  ) async {
    final t = resolve();
    Future<void> lines(
      String slot, {
      SemiButtonVariant? groupVariant,
      bool? groupDisabled,
      SemiButtonVariant? childVariant,
      bool? childDisabled,
      SemiButtonType? childType,
      required Color expected,
    }) async {
      await tester.pumpWidget(
        host(
          SemiButtonGroup(
            variant: groupVariant,
            disabled: groupDisabled,
            children: [
              SemiButton(
                '一',
                type: childType,
                variant: childVariant,
                disabled: childDisabled,
                onPressed: () {},
              ),
              SemiButton('二', onPressed: () {}),
            ],
          ),
        ),
      );
      final finder = find.descendant(
        of: find.byType(SemiButtonGroup),
        matching: find.byType(ColoredBox),
      );
      if (finder.evaluate().isEmpty) {
        fail('$slot: expected a divider');
      }
      expect(
        tester.widget<ColoredBox>(finder.first).color,
        expected,
        reason: slot,
      );
    }

    await lines(
      'solid danger',
      groupVariant: SemiButtonVariant.solid,
      childType: SemiButtonType.danger,
      expected: t.colorButtonDangerBgDefault,
    );
    await lines(
      'disabled',
      groupVariant: SemiButtonVariant.solid,
      groupDisabled: true,
      expected: t.colorButtonDisabledBgDefault,
    );
    await lines(
      'light theme',
      groupVariant: SemiButtonVariant.light,
      groupDisabled: true,
      expected: t.colorButtonLightBgDefault,
    );
    // borderless lines are transparent, so there is still a divider widget.
    await lines(
      'borderless',
      groupVariant: SemiButtonVariant.borderless,
      expected: const Color(0x00000000),
    );
  });

  testWidgets('group skips dividers for outline buttons', (tester) async {
    await tester.pumpWidget(
      host(
        SemiButtonGroup(
          variant: SemiButtonVariant.outline,
          children: [
            SemiButton('一', onPressed: () {}),
            SemiButton('一', onPressed: () {}),
          ],
        ),
      ),
    );
    expect(
      find.descendant(
        of: find.byType(SemiButtonGroup),
        matching: find.byType(ColoredBox),
      ),
      findsNothing,
    );
  });

  testWidgets('group merge order: child wins for disabled/size/type, group '
      'wins for variant/colorful', (tester) async {
    final t = resolve();
    // child size overrides the group size.
    await tester.pumpWidget(
      host(
        SemiButtonGroup(
          size: SemiButtonSize.large,
          children: [
            SemiButton('x', size: SemiButtonSize.small, onPressed: () {}),
          ],
        ),
      ),
    );
    expect(buttonHeight(tester), 24);
    // group size applies when the child is silent.
    await tester.pumpWidget(
      host(
        SemiButtonGroup(
          size: SemiButtonSize.large,
          children: [SemiButton('x', onPressed: () {})],
        ),
      ),
    );
    expect(buttonHeight(tester), 40);
    // explicit child disabled:false survives a disabled group.
    await tester.pumpWidget(
      host(
        SemiButtonGroup(
          disabled: true,
          variant: SemiButtonVariant.solid,
          children: [
            SemiButton('x', disabled: false, onPressed: () {}),
            SemiButton('y', onPressed: () {}),
          ],
        ),
      ),
    );
    final enabledBox = box(tester, of: find.byType(SemiButton).at(0));
    final disabledBox = box(tester, of: find.byType(SemiButton).at(1));
    expect(
      enabledBox.color,
      defaultBg(t, SemiButtonType.primary, SemiButtonVariant.solid),
    );
    expect(
      disabledBox.color,
      disabledBg(t, SemiButtonType.primary, SemiButtonVariant.solid),
    );
    // group type applies when the child is silent, child type wins otherwise.
    await tester.pumpWidget(
      host(
        SemiButtonGroup(
          type: SemiButtonType.danger,
          variant: SemiButtonVariant.solid,
          children: [
            SemiButton('x', onPressed: () {}),
            SemiButton('y', type: SemiButtonType.secondary, onPressed: () {}),
          ],
        ),
      ),
    );
    expect(
      box(tester, of: find.byType(SemiButton).at(0)).color,
      defaultBg(t, SemiButtonType.danger, SemiButtonVariant.solid),
    );
    expect(
      box(tester, of: find.byType(SemiButton).at(1)).color,
      defaultBg(t, SemiButtonType.secondary, SemiButtonVariant.solid),
    );
    // group variant/colorful override the child.
    await tester.pumpWidget(
      host(
        SemiButtonGroup(
          variant: SemiButtonVariant.solid,
          colorful: true,
          children: [
            SemiButton(
              'x',
              variant: SemiButtonVariant.light,
              colorful: false,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
    final colorfulBox = box(tester);
    expect(colorfulBox.gradient, isNotNull);
  });

  testWidgets('group outline buttons overlap by 1px with a transparent edge', (
    tester,
  ) async {
    final t = resolve();
    await tester.pumpWidget(
      host(
        SemiButtonGroup(
          variant: SemiButtonVariant.outline,
          children: [
            SemiButton('一', onPressed: () {}),
            SemiButton('一', onPressed: () {}),
          ],
        ),
      ),
    );
    final firstBox = box(tester, of: find.byType(SemiButton).at(0));
    AnimatedContainer marginOf(Finder button) =>
        tester.widget<AnimatedContainer>(
          find.descendant(of: button, matching: find.byType(AnimatedContainer)),
        );
    expect(marginOf(find.byType(SemiButton).at(0)).margin, isNull);
    // The negative end margin shrinks the reported width by the border width
    // so the next button overlaps the shared seam by 1px.
    final firstWidth = tester.getSize(find.byType(SemiButton).at(0)).width;
    final lastWidth = tester.getSize(find.byType(SemiButton).at(1)).width;
    expect(lastWidth - firstWidth, t.widthButtonOutlineBorder);
    final firstBorder = borderOf(firstBox);
    expect(firstBorder.isUniform, isTrue);
    expect(firstBorder.top.color, t.colorButtonPrimaryOutlineBorderDefault);
    expect(firstBorder.top.width, t.widthButtonOutlineBorder);
  });

  testWidgets('keyboard Enter and Space activate; focus ring is gated', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      host(SemiButton('x', autofocus: true, onPressed: () => taps++)),
    );
    await tester.pump();
    // Focused via autofocus but no keyboard input yet: no ring.
    expect(box(tester).boxShadow, isNull);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(taps, 1);
    final ring = box(tester).boxShadow;
    expect(ring, hasLength(1));
    expect(ring!.single.spreadRadius, resolve().widthButtonOutline);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(taps, 2);
    // Mouse contact drops the keyboard modality: ring hidden again.
    final gesture = await mouse(tester);
    await gesture.down(tester.getCenter(find.byType(SemiButton)));
    await tester.pump();
    expect(box(tester).boxShadow, isNull);
    await gesture.up();
  });

  testWidgets('focus ring color keeps the upstream per-type quirk', (
    tester,
  ) async {
    final t = resolve();
    Future<void> ringColor(
      String slot, {
      required SemiButtonType type,
      required SemiButtonVariant variant,
      required Color expected,
    }) async {
      await tester.pumpWidget(
        host(
          SemiButton(
            'x',
            type: type,
            variant: variant,
            autofocus: true,
            onPressed: () {},
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(box(tester).boxShadow!.single.color, expected, reason: slot);
    }

    // danger/warning keep the primary focus color in light/borderless.
    await ringColor(
      'danger light',
      type: SemiButtonType.danger,
      variant: SemiButtonVariant.light,
      expected: t.colorButtonPrimaryOutlineFocus,
    );
    await ringColor(
      'warning borderless',
      type: SemiButtonType.warning,
      variant: SemiButtonVariant.borderless,
      expected: t.colorButtonPrimaryOutlineFocus,
    );
    await ringColor(
      'danger outline',
      type: SemiButtonType.danger,
      variant: SemiButtonVariant.outline,
      expected: t.colorButtonDangerOutlineFocus,
    );
    await ringColor(
      'warning solid',
      type: SemiButtonType.warning,
      variant: SemiButtonVariant.solid,
      expected: t.colorButtonWarningOutlineFocus,
    );
    await ringColor(
      'secondary solid',
      type: SemiButtonType.secondary,
      variant: SemiButtonVariant.solid,
      expected: t.colorButtonPrimaryOutlineFocus,
    );
  });

  testWidgets('disabled buttons refuse focus', (tester) async {
    await tester.pumpWidget(
      host(SemiButton('x', disabled: true, autofocus: true, onPressed: () {})),
    );
    await tester.pump();
    expect(box(tester).boxShadow, isNull);
    final focus = tester.widget<Focus>(
      find
          .ancestor(
            of: find.byType(AnimatedContainer),
            matching: find.byType(Focus),
          )
          .first,
    );
    expect(focus.canRequestFocus, isFalse);
  });

  testWidgets('RTL mirrors icon order and first/last radii', (tester) async {
    final t = resolve();
    await tester.pumpWidget(
      host(
        SemiButton(
          'x',
          icon: const Iconish(key: Key('icon')),
          onPressed: () {},
        ),
        rtl: true,
      ),
    );
    // Upstream renders icon first in DOM order; RTL shows it at the right.
    expect(
      tester.getCenter(find.byKey(const Key('icon'))).dx,
      greaterThan(tester.getCenter(find.byType(SemiText)).dx),
    );
    await tester.pumpWidget(
      host(
        SemiButtonGroup(
          children: [
            SemiButton('一', onPressed: () {}),
            SemiButton('二', onPressed: () {}),
          ],
        ),
        rtl: true,
      ),
    );
    final firstRadius =
        (box(tester, of: find.byType(SemiButton).at(0)).borderRadius!
                as BorderRadiusDirectional)
            .resolve(TextDirection.rtl);
    final r = Radius.circular(t.radiusButtonGroup);
    expect(firstRadius.topRight, r);
    expect(firstRadius.bottomRight, r);
    expect(firstRadius.topLeft, Radius.zero);
  });

  testWidgets('narrow group wraps and text scaling renders', (tester) async {
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 120,
          child: SemiButtonGroup(
            children: [
              SemiButton('很长的按钮文本', onPressed: () {}),
              SemiButton('第二个按钮', onPressed: () {}),
              SemiButton('三', onPressed: () {}),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(
      host(SemiButton('文字缩放', onPressed: () {}), textScale: 2.0),
    );
    expect(find.text('文字缩放'), findsOneWidget);
    expect(tester.takeException(), isNull);
    // The fixed upstream heights stay authoritative.
    expect(buttonHeight(tester), 32);
  });
}

/// Marker widget standing in for an icon slot child.
class Iconish extends StatelessWidget {
  const Iconish({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(width: 16, height: 16);
}
