import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  for (final direction in TextDirection.values) {
    for (final mode in ['small', 'large', 'close', 'square', 'circle']) {
      testWidgets('$direction $mode independent four edges reach layout', (
        tester,
      ) async {
        const data = SemiTagThemeData(
          heightTagSmall: 80,
          heightTagLarge: 90,
          spacingTagSmallPaddingX: 3,
          spacingTagSmallPaddingY: 5,
          spacingTagLargePaddingX: 7,
          spacingTagLargePaddingY: 9,
          spacingTagClosablePaddingLeft: 11,
          spacingTagClosablePaddingTop: 12,
          spacingTagClosablePaddingRight: 13,
          spacingTagClosablePaddingBottom: 14,
          spacingTagAvatarSquarePaddingLeft: 15,
          spacingTagAvatarSquarePaddingTop: 16,
          spacingTagAvatarSquarePaddingRight: 17,
          spacingTagAvatarSquarePaddingBottom: 18,
          spacingTagAvatarCirclePaddingLeft: 19,
          spacingTagAvatarCirclePaddingTop: 20,
          spacingTagAvatarCirclePaddingRight: 21,
          spacingTagAvatarCirclePaddingBottom: 22,
        );
        final edges = switch (mode) {
          'small' => const EdgeInsetsDirectional.fromSTEB(3, 5, 3, 5),
          'large' => const EdgeInsetsDirectional.fromSTEB(7, 9, 7, 9),
          'close' => const EdgeInsetsDirectional.fromSTEB(11, 12, 13, 14),
          'square' => const EdgeInsetsDirectional.fromSTEB(15, 16, 17, 18),
          _ => const EdgeInsetsDirectional.fromSTEB(19, 20, 21, 22),
        };
        await tester.pumpWidget(
          SemiTheme(
            data: const SemiThemeData.light(),
            child: SemiTagTheme(
              data: data,
              child: Directionality(
                textDirection: direction,
                child: Center(
                  child: SemiTag(
                    'edges',
                    size: mode == 'large'
                        ? SemiTagSize.large
                        : SemiTagSize.small,
                    closable: mode != 'small' && mode != 'large',
                    avatar: mode == 'square' || mode == 'circle'
                        ? const SizedBox()
                        : null,
                    avatarShape: mode == 'circle'
                        ? SemiTagShape.circle
                        : SemiTagShape.square,
                  ),
                ),
              ),
            ),
          ),
        );
        final pads = tester.widgetList<Padding>(
          find.descendant(
            of: find.byType(SemiTag),
            matching: find.byType(Padding),
          ),
        );
        final padding = pads.first;
        expect(padding.padding.resolve(direction), edges.resolve(direction));
        final finder = find.byWidget(padding);
        final outer = tester.getRect(finder);
        final child = tester.getRect(find.byWidget(padding.child!));
        final actual = edges.resolve(direction);
        expect(child.left - outer.left, actual.left);
        expect(child.top - outer.top, actual.top);
        expect(outer.right - child.right, actual.right);
        expect(outer.bottom - child.bottom, actual.bottom);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets(
    'prefix avatar suffix close gaps use independent source variables',
    (tester) async {
      const prefix = SizedBox(key: ValueKey('prefix'), width: 10, height: 10);
      const suffix = SizedBox(key: ValueKey('suffix'), width: 10, height: 10);
      await tester.pumpWidget(
        SemiTheme(
          data: const SemiThemeData.light(),
          child: const SemiTagTheme(
            data: SemiTagThemeData(
              spacingTagPrefixIconPaddingRight: 3,
              spacingTagSuffixIconPaddingLeft: 5,
              spacingTagAvatarMarginRight: 7,
              spacingTagClosePaddingLeft: 9,
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Center(
                child: SemiTag(
                  'gaps',
                  prefixIcon: prefix,
                  suffixIcon: suffix,
                  closable: true,
                  avatar: SizedBox(),
                ),
              ),
            ),
          ),
        ),
      );
      final paddings = tester
          .widgetList<Padding>(
            find.descendant(
              of: find.byType(SemiTag),
              matching: find.byType(Padding),
            ),
          )
          .map((w) => w.padding.resolve(TextDirection.ltr))
          .toList();
      for (final edge in [
        const EdgeInsets.only(right: 3),
        const EdgeInsets.only(right: 7),
        const EdgeInsets.only(left: 5),
        const EdgeInsets.only(left: 9),
      ]) {
        expect(paddings, contains(edge));
      }
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('font globals and AI specificity beat later white/avatar rules', (
    tester,
  ) async {
    final theme = SemiThemeData.light(
      typography: SemiTypographyTokens(
        fontWeightBold: FontWeight.w800,
        fontSizeSmall: 15,
      ),
    );
    await tester.pumpWidget(
      SemiTheme(
        data: theme,
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SemiTag(
              'AI',
              colorful: true,
              color: SemiTagColor.white,
              avatar: SizedBox(),
            ),
          ),
        ),
      ),
    );
    final text = tester.widget<Text>(find.text('AI'));
    expect(text.style!.fontWeight, FontWeight.w800);
    expect(text.style!.fontSize, 15);
    expect(text.style!.color, theme.colors.colorAiPurple);
    expect(
      const SemiTagThemeData()
          .resolve(const SemiThemeData.light())
          .fontTagColorfulFontWeight,
      FontWeight.w600,
    );
  });
}
