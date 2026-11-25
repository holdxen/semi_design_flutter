import 'dart:ui' show Tristate;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';
import 'package:semi_design_flutter/src/components/typography.dart' as facade;

import 'semi_text_test.dart' show host, textStyle;

void main() {
  test('public facade and defaults', () {
    const p = facade.SemiParagraph('x');
    expect(p.spacing, SemiParagraphSpacing.normal);
    expect(p.size, SemiTextSize.normal);
    expect(() => SemiParagraph('x', maxLines: 0), throwsAssertionError);
  });

  for (final size in SemiTextSize.values) {
    for (final spacing in SemiParagraphSpacing.values) {
      testWidgets('$size $spacing metrics without Material', (t) async {
        await t.pumpWidget(
          host(SemiParagraph('段落', size: size, spacing: spacing)),
        );
        final s = textStyle(t);
        final font = size == SemiTextSize.normal
            ? 14.0
            : size == SemiTextSize.small
            ? 12.0
            : 23.0;
        expect(s.fontSize, font);
        // No fixed line-height: inherit the host DefaultTextStyle height.
        expect(s.height, 1.7);
        expect(s.fontWeight, FontWeight.w400);
        expect(t.getSize(find.byType(SemiParagraph)).width, 800);
        expect(t.takeException(), isNull);
      });
    }
  }

  testWidgets('inherit font families and null inherited size', (t) async {
    await t.pumpWidget(
      host(
        const SemiParagraph('x', size: SemiTextSize.inherit),
        style: const TextStyle(
          fontSize: 30,
          height: 2,
          fontFamily: 'Custom',
          fontFamilyFallback: ['Fallback'],
        ),
      ),
    );
    expect(textStyle(t).fontFamily, 'Custom');
    expect(textStyle(t).fontFamilyFallback, ['Fallback']);
    await t.pumpWidget(
      host(
        const SemiParagraph(
          'x',
          size: SemiTextSize.inherit,
          spacing: SemiParagraphSpacing.extended,
        ),
        style: const TextStyle(),
      ),
    );
    // host style is an empty TextStyle (no height) -> inherits null.
    expect(textStyle(t).height, isNull);
    expect(t.takeException(), isNull);
  });

  testWidgets('all types and disabled colors in light and dark', (t) async {
    for (final theme in [
      const SemiThemeData.light(),
      const SemiThemeData.dark(),
    ]) {
      final c = theme.colors;
      final colors = [
        c.colorText0,
        c.colorText1,
        c.colorText2,
        c.colorText3,
        c.colorWarning,
        c.colorDanger,
        c.colorSuccess,
      ];
      for (final type in SemiTextType.values) {
        await t.pumpWidget(host(SemiParagraph('x', type: type), theme: theme));
        expect(textStyle(t).color, colors[type.index]);
        await t.pumpWidget(
          host(SemiParagraph('x', type: type, disabled: true), theme: theme),
        );
        expect(textStyle(t).color, c.colorDisabledText);
      }
    }
  });

  testWidgets('paragraph weights strong link and decoration combinations', (
    t,
  ) async {
    for (final small in [false, true]) {
      for (final strong in [false, true]) {
        for (final linked in [false, true]) {
          await t.pumpWidget(
            host(
              SemiTypographyTheme(
                data: const SemiTypographyThemeData(
                  normalParagraphRegularFontWeight: FontWeight.w200,
                  smallParagraphRegularFontWeight: FontWeight.w300,
                  strongFontWeight: FontWeight.w800,
                  linkFontWeight: FontWeight.w700,
                ),
                child: SemiParagraph(
                  'x',
                  size: small ? SemiTextSize.small : SemiTextSize.normal,
                  strong: strong,
                  link: linked ? SemiTextLink(onTap: () {}) : null,
                  mark: true,
                  underline: true,
                  delete: true,
                ),
              ),
            ),
          );
          final s = textStyle(t);
          expect(
            s.fontWeight,
            strong
                ? FontWeight.w800
                : linked
                ? FontWeight.w700
                : small
                ? FontWeight.w300
                : FontWeight.w200,
          );
          expect(s.decoration!.contains(TextDecoration.lineThrough), isTrue);
          expect(s.decoration!.contains(TextDecoration.underline), !linked);
          expect(
            s.backgroundColor,
            const SemiThemeData.light().colors.colorPrimaryLightDefault,
          );
        }
      }
    }
  });

  testWidgets('style last including size ratio and replacement semantics', (
    t,
  ) async {
    await t.pumpWidget(
      host(
        const SemiParagraph(
          'x',
          disabled: true,
          strong: true,
          spacing: SemiParagraphSpacing.extended,
          mark: true,
          underline: true,
          delete: true,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xff123456),
            backgroundColor: Color(0xffabcdef),
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
    final s = textStyle(t);
    expect(s.fontSize, 28);
    // No fixed line-height: inherit the host DefaultTextStyle height.
    expect(s.height, 1.7);
    expect(s.fontWeight, FontWeight.w900);
    expect(s.color, const Color(0xff123456));
    expect(s.backgroundColor, const Color(0xffabcdef));
    expect(s.decoration, TextDecoration.none);
    await t.pumpWidget(
      host(
        const SemiParagraph(
          'x',
          spacing: SemiParagraphSpacing.extended,
          style: TextStyle(inherit: false, fontSize: 19, height: 3),
        ),
      ),
    );
    expect(textStyle(t).height, 3);
    expect(textStyle(t).color, isNull);
  });

  testWidgets('application and local paragraph metrics update dynamically', (
    t,
  ) async {
    for (final local in [false, true]) {
      for (var step = 0; step < 2; step++) {
        final patch = SemiTypographyThemeData(
          normalParagraphRegularFontWeight: step == 0
              ? FontWeight.w200
              : FontWeight.w500,
          smallParagraphRegularFontWeight: step == 0
              ? FontWeight.w300
              : FontWeight.w700,
          paragraphExtendedLineHeight: 30.0 + step,
          titleParagraphMargin: EdgeInsets.all(4.0 + step),
          fontSizeRegular: 15.0 + step,
          fontSizeSmall: 11.0 + step,
          lineHeightRegular: 21.0 + step,
          lineHeightSmall: 17.0 + step,
        );
        for (final size in [SemiTextSize.normal, SemiTextSize.small]) {
          for (final extended in [false, true]) {
            Widget child = SemiParagraph(
              'x',
              size: size,
              spacing: extended
                  ? SemiParagraphSpacing.extended
                  : SemiParagraphSpacing.normal,
            );
            if (local) child = SemiTypographyTheme(data: patch, child: child);
            await t.pumpWidget(
              host(
                child,
                theme: SemiThemeData.light(
                  components: SemiComponentThemes(
                    typography: local ? const SemiTypographyThemeData() : patch,
                  ),
                ),
              ),
            );
            final small = size == SemiTextSize.small;
            expect(
              textStyle(t).fontWeight,
              small
                  ? patch.smallParagraphRegularFontWeight
                  : patch.normalParagraphRegularFontWeight,
            );
            final font = small ? patch.fontSizeSmall! : patch.fontSizeRegular!;
            expect(textStyle(t).fontSize, font);
            // No fixed line-height: inherit the host DefaultTextStyle height.
            expect(textStyle(t).height, 1.7);
            final padding = t.widget<Padding>(
              find
                  .descendant(
                    of: find.byType(SemiParagraph),
                    matching: find.byType(Padding),
                  )
                  .first,
            );
            expect(padding.padding, patch.titleParagraphMargin);
          }
        }
      }
    }
  });

  testWidgets('global token references remain live with a constant child', (
    t,
  ) async {
    const child = SemiParagraph('x');
    for (var step = 0; step < 2; step++) {
      final tokens = SemiTypographyTokens(
        fontSizeRegular: 18.0 + step,
        lineHeightRegular: 28.0 + step,
        fontWeightRegular: step == 0 ? FontWeight.w300 : FontWeight.w500,
        fontFamily: 'Family$step',
      );
      await t.pumpWidget(
        host(child, theme: SemiThemeData.light(typography: tokens)),
      );
      expect(textStyle(t).fontSize, tokens.fontSizeRegular);
      // No fixed line-height: inherit the host DefaultTextStyle height.
      expect(textStyle(t).height, 1.7);
      expect(textStyle(t).fontWeight, tokens.fontWeightRegular);
      expect(textStyle(t).fontFamily, tokens.fontFamily);
    }
  });

  testWidgets(
    'link mouse keyboard disabled and semantic actions share text state',
    (t) async {
      var taps = 0;
      Widget widget(bool disabled) => host(
        SemiParagraph(
          '链接',
          disabled: disabled,
          underline: true,
          link: SemiTextLink(onTap: () => taps++, visited: true),
        ),
      );
      final semantics = t.ensureSemantics();
      await t.pumpWidget(widget(false));
      final colors = const SemiThemeData.light().colors;
      expect(textStyle(t).color, colors.colorLinkVisited);
      final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(t.getCenter(find.byType(Text)));
      await t.pump();
      expect(textStyle(t).color, colors.colorLinkHover);
      expect(
        textStyle(t).decoration!.contains(TextDecoration.underline),
        isTrue,
      );
      await mouse.down(t.getCenter(find.byType(Text)));
      await t.pump();
      expect(textStyle(t).color, colors.colorLinkActive);
      await mouse.up();
      Focus.of(t.element(find.byType(GestureDetector))).requestFocus();
      await t.pump();
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.sendKeyEvent(LogicalKeyboardKey.space);
      expect(taps, 3);
      await t.pumpWidget(widget(true));
      await t.tap(find.byType(Text));
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(taps, 3);
      final node = t.getSemantics(find.byType(SemiParagraph));
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
      expect(node.flagsCollection.isEnabled, Tristate.isFalse);
      expect(textStyle(t).color, colors.colorLink);
      await mouse.removePointer();
      semantics.dispose();
    },
  );

  testWidgets(
    'single nonheader semantic label for plain and linked paragraphs',
    (t) async {
      final semantics = t.ensureSemantics();
      for (final linked in [false, true]) {
        await t.pumpWidget(
          host(
            SemiParagraph(
              '显示文本',
              semanticsLabel: '朗读文本',
              link: linked ? SemiTextLink(onTap: () {}) : null,
            ),
          ),
        );
        final node = t.getSemantics(find.byType(SemiParagraph));
        expect(node.label, '朗读文本');
        expect(node.flagsCollection.isHeader, isFalse);
        expect(node.flagsCollection.isLink, linked);
        expect(node.childrenCount, 0);
      }
      semantics.dispose();
    },
  );

  testWidgets('Chinese emoji RTL scale bounded single and multiline ellipsis', (
    t,
  ) async {
    for (final lines in [1, 2]) {
      await t.pumpWidget(
        host(
          SizedBox(
            width: 100,
            child: SemiParagraph(
              '中文👨‍👩‍👧‍👦 مرحبا بالعالم ' * 12,
              textAlign: TextAlign.end,
              textDirection: TextDirection.rtl,
              softWrap: lines > 1,
              maxLines: lines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          scale: 1.6,
        ),
      );
      final text = t.widget<Text>(find.byType(Text));
      final render = t.renderObject<RenderParagraph>(find.byType(RichText));
      expect(text.textAlign, TextAlign.end);
      expect(render.textDirection, TextDirection.rtl);
      expect(render.textScaler.scale(10), 16);
      expect(render.didExceedMaxLines, isTrue);
      expect(render.size.width, 100);
      expect(t.takeException(), isNull);
    }
  });

  testWidgets('unbounded width shrinks without infinite dimensions', (t) async {
    await t.pumpWidget(
      host(
        const UnconstrainedBox(
          constrainedAxis: Axis.vertical,
          child: SemiParagraph('短段落'),
        ),
      ),
    );
    expect(t.getSize(find.byType(SemiParagraph)).width.isFinite, isTrue);
    expect(t.getSize(find.byType(SemiParagraph)).width, lessThan(800));
    expect(t.takeException(), isNull);
  });
}
