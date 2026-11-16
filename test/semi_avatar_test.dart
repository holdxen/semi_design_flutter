// Behavior matrix for SemiAvatar / SemiAvatarGroup plus coverage for the 99
// Sass declarations (89 FIELDS + 10 MOTION + 0 INTERNAL) — the 29 HARDCODES
// provenance anchors live in the widget's file-level note block / call sites,
// and 1 dead variable stays unconsumed. See docs/semi_avatar.md.
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(Widget child) => SemiTheme(
  data: const SemiThemeData.light(),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: 300,
        height: 600,
        child: Align(alignment: Alignment.topLeft, child: child),
      ),
    ),
  ),
);

Future<void> pumpHost(WidgetTester tester, Widget child) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.binding.setSurfaceSize(const Size(800, 800));
  await tester.pumpWidget(host(child));
}

/// 图片加载必然失败的 provider（回落文字契约用）。
class _FailingImage extends ImageProvider<_FailingImage> {
  const _FailingImage();
  @override
  Future<_FailingImage> obtainKey(ImageConfiguration configuration) async =>
      this;
  @override
  ImageStreamCompleter loadImage(
    _FailingImage key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(
    Future<ImageInfo>.error(Exception('image load fail')),
  );
}

BoxDecoration decorationOf(WidgetTester tester, Finder finder) =>
    tester.widget<DecoratedBox>(finder).decoration as BoxDecoration;

/// scope 内带 border 的 DecoratedBox（额外描边环/组描边）。
DecoratedBox borderedBoxOf(WidgetTester tester, Finder scope) => tester
    .widgetList<DecoratedBox>(
      find.descendant(of: scope, matching: find.byType(DecoratedBox)),
    )
    .firstWhere(
      (w) =>
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).border != null,
    );

BoxDecoration bodyColorOf(WidgetTester tester) => decorationOf(
  tester,
  find.descendant(
    of: find.byType(ClipRRect),
    matching: find.byType(DecoratedBox),
  ),
);

/// 圆角在 ClipRRect 上（body DecoratedBox 只有颜色）。
BorderRadius clipRadiusOf(WidgetTester tester) => tester
    .widget<ClipRRect>(
      find.descendant(
        of: find.byType(SemiAvatar),
        matching: find.byType(ClipRRect),
      ),
    )
    .borderRadius! as BorderRadius;

void main() {
  group('geometry', () {
    testWidgets('seven sizes and two shapes take their declared geometry', (
      tester,
    ) async {
      const sizes = {
        SemiAvatarSize.extraExtraSmall: (20.0, 3.0),
        SemiAvatarSize.extraSmall: (24.0, 3.0),
        SemiAvatarSize.small: (32.0, 3.0),
        SemiAvatarSize.normal: (40.0, 3.0),
        SemiAvatarSize.medium: (48.0, 3.0),
        SemiAvatarSize.large: (72.0, 6.0),
        SemiAvatarSize.extraLarge: (128.0, 12.0),
      };
      for (final entry in sizes.entries) {
        await pumpHost(
          tester,
          SemiAvatar(size: entry.key, text: 'x', shape: SemiAvatarShape.square),
        );
        final avatar = find.byType(SemiAvatar);
        expect(tester.getSize(avatar), Size(entry.value.$1, entry.value.$1));
        expect(
          clipRadiusOf(tester),
          BorderRadius.circular(entry.value.$2),
          reason: '${entry.key} square radius',
        );
        await pumpHost(tester, SemiAvatar(size: entry.key, text: 'x'));
        final clip = tester.widget<ClipRRect>(
          find.descendant(
            of: find.byType(SemiAvatar),
            matching: find.byType(ClipRRect),
          ),
        );
        expect(
          clip.borderRadius,
          BorderRadius.circular(entry.value.$1 / 2),
          reason: '${entry.key} circle radius',
        );
      }
    });

    testWidgets('customSize overrides the box and drops the size classes', (
      tester,
    ) async {
      await pumpHost(tester, const SemiAvatar(customSize: 66, text: 'x'));
      expect(tester.getSize(find.byType(SemiAvatar)), const Size(66, 66));
      await pumpHost(
        tester,
        const SemiAvatar(
          customSize: 66,
          shape: SemiAvatarShape.square,
          text: 'x',
        ),
      );
      // 无尺寸类 quirk：square 自由尺寸圆角 0。
      expect(clipRadiusOf(tester), BorderRadius.zero);
    });

    testWidgets('string content auto-scales inside the gap', (tester) async {
      await pumpHost(
        tester,
        const SemiAvatar(size: SemiAvatarSize.extraExtraSmall, text: 'WWWW'),
      );
      // foundation.ts:57 `gap * 2 < nodeWidth`：可用宽 20 - 2*3 = 14。
      expect(tester.getRect(find.text('WWWW')).width, lessThanOrEqualTo(15));
    });
  });

  group('typography and colors', () {
    testWidgets('label font follows the size mixins', (tester) async {
      const expected = {
        SemiAvatarSize.small: (12.0, 16.0),
        SemiAvatarSize.normal: (18.0, 24.0),
        SemiAvatarSize.medium: (20.0, 28.0),
        SemiAvatarSize.large: (32.0, 44.0),
      };
      for (final entry in expected.entries) {
        await pumpHost(tester, SemiAvatar(size: entry.key, text: 'x'));
        final style = tester.widget<Text>(find.text('x')).style!;
        expect(style.fontSize, entry.value.$1, reason: '${entry.key} size');
        expect(
          style.height,
          entry.value.$2 / entry.value.$1,
          reason: '${entry.key} line height',
        );
        expect(style.fontWeight, FontWeight.w600, reason: '${entry.key} bold');
      }
    });

    testWidgets('palette colors use level 3 backgrounds with white text', (
      tester,
    ) async {
      const light = SemiThemeData.light();
      final colors = {
        SemiAvatarColor.amber: light.palette.amber3.toColor(),
        SemiAvatarColor.blue: light.palette.blue3.toColor(),
        SemiAvatarColor.grey: light.palette.grey3.toColor(),
      };
      for (final entry in colors.entries) {
        await pumpHost(tester, SemiAvatar(color: entry.key, text: 'x'));
        expect(
          bodyColorOf(tester).color,
          entry.value,
          reason: '${entry.key} bg',
        );
        expect(
          tester.widget<Text>(find.text('x')).style!.color,
          light.palette.white.toColor(),
        );
      }
      // ★quirk：constants.ts 含 'white' 但 avatar.scss $colors 无 white 样式。
      await pumpHost(
        tester,
        const SemiAvatar(color: SemiAvatarColor.white, text: 'x'),
      );
      expect(bodyColorOf(tester).color, const Color(0x00000000));
    });
  });

  group('image', () {
    testWidgets('load failure falls back to the text content', (tester) async {
      await pumpHost(
        tester,
        const SemiAvatar(src: _FailingImage(), text: 'AB'),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('AB'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('onImageError returning false keeps the image slot', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiAvatar(
          src: const _FailingImage(),
          text: 'AB',
          onImageError: () => false,
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('AB'), findsNothing);
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('interaction', () {
    testWidgets('focus paints the outline; Enter taps, Escape blurs', (
      tester,
    ) async {
      var taps = 0;
      await pumpHost(tester, SemiAvatar(text: 'x', onTap: () => taps++));
      expect(find.byType(CustomPaint), findsNothing);
      final focus = tester.widget<Focus>(find.byType(Focus));
      focus.focusNode!.requestFocus();
      await tester.pump();
      expect(find.byType(CustomPaint), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(taps, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(focus.focusNode!.hasFocus, isFalse);
    });

    testWidgets('hoverMask appears on hover and clears on exit', (tester) async {
      await pumpHost(
        tester,
        const SemiAvatar(text: 'x', hoverMask: Text('mask')),
      );
      expect(find.text('mask'), findsNothing);
      final mouse = tester.widget<MouseRegion>(find.byType(MouseRegion));
      mouse.onEnter!(const PointerEnterEvent());
      await tester.pump();
      expect(find.text('mask'), findsOneWidget);
      mouse.onExit!(const PointerExitEvent());
      await tester.pump();
      expect(find.text('mask'), findsNothing);
    });
  });

  group('additional border and motion', () {
    testWidgets('the ring sits outside the avatar by W + gap', (tester) async {
      await pumpHost(
        tester,
        const SemiAvatar(border: SemiAvatarBorder(), text: 'x'),
      );
      final avatar = tester.getRect(find.byType(SemiAvatar));
      final ringBox = borderedBoxOf(tester, find.byType(SemiAvatar));
      final ring = tester.getRect(find.byWidget(ringBox));
      // 48 + 2*(1.5 + 2) = 55；外扩 3.5。
      expect(ring.width, 55);
      expect(ring.topLeft, avatar.topLeft - const Offset(3.5, 3.5));
      final decoration = ringBox.decoration as BoxDecoration;
      expect(decoration.border!.top.width, 1.5);
      expect(
        decoration.border!.top.color,
        const SemiThemeData.light().colors.colorPrimary,
      );
    });

    testWidgets('border motion drives opacity from the theme duration', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiAvatar(border: SemiAvatarBorder(motion: true), text: 'x'),
      );
      // 800ms 线性 1→0：400ms 时 0.5。
      await tester.pump(const Duration(milliseconds: 400));
      final opacities = tester
          .widgetList<Opacity>(find.byType(Opacity))
          .map((o) => o.opacity)
          .toList();
      expect(opacities.any((o) => (o - 0.5).abs() < 0.01), isTrue);
    });

    testWidgets('contentMotion pulses the avatar scale', (tester) async {
      await pumpHost(tester, const SemiAvatar(text: 'x', contentMotion: true));
      await tester.pump(const Duration(milliseconds: 250));
      // 0%→50%→100% scale 1→0.9→1：250ms（1000ms 的 25%）时 0.95。
      final scales = tester
          .widgetList<Transform>(find.byType(Transform))
          .map((t) => t.transform.storage[0])
          .toList();
      expect(scales.any((s) => (s - 0.95).abs() < 0.01), isTrue);
    });
  });

  group('slots', () {
    testWidgets('top slot renders for circle sizes with the shield painter', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiAvatar(
          size: SemiAvatarSize.medium,
          topSlot: SemiAvatarTopSlot(text: Text('新')),
        ),
      );
      final style = tester.widget<Text>(find.text('新')).style!;
      expect(style.fontSize, 8);
      final painters = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((p) => p.painter.runtimeType.toString())
          .toList();
      expect(painters, contains('_TopSlotShieldPainter'));
    });

    testWidgets('top slot guards: no xxs, no square; extra-small is zero-style', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiAvatar(
          size: SemiAvatarSize.extraExtraSmall,
          topSlot: SemiAvatarTopSlot(text: Text('新')),
        ),
      );
      expect(find.text('新'), findsNothing);
      await pumpHost(
        tester,
        const SemiAvatar(
          shape: SemiAvatarShape.square,
          topSlot: SemiAvatarTopSlot(text: Text('新')),
        ),
      );
      expect(find.text('新'), findsNothing);
      await pumpHost(
        tester,
        const SemiAvatar(
          size: SemiAvatarSize.extraSmall,
          topSlot: SemiAvatarTopSlot(text: Text('新')),
        ),
      );
      // ★零样式 quirk：无 bg/shield，文字回落基础 `font-size-regular`。
      expect(
        tester.widget<Text>(find.text('新')).style!.fontSize,
        const SemiThemeData.light().typography.fontSizeRegular,
      );
      final painters = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((p) => p.painter.runtimeType.toString())
          .toList();
      expect(painters, isNot(contains('_TopSlotShieldPainter')));
    });

    testWidgets('bottom slot circle straddles the bottom edge', (tester) async {
      await pumpHost(
        tester,
        const SemiAvatar(
          size: SemiAvatarSize.medium,
          bottomSlot: SemiAvatarBottomSlot(text: Text('9')),
        ),
      );
      final avatar = tester.getRect(find.byType(SemiAvatar));
      final badge = tester.getRect(find.text('9'));
      // 中心在盒底上方 gap + 环宽 = 3.5（avatar.scss:275-276）。
      expect(avatar.bottom - badge.center.dy, closeTo(3.5, 0.6));
      final badgeBox = find.ancestor(
        of: find.text('9'),
        matching: find.byType(DecoratedBox),
      );
      expect(tester.getSize(badgeBox), const Size(18, 18));
    });

    testWidgets('bottom slot square metrics and the extra-small quirk', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiAvatar(
          size: SemiAvatarSize.medium,
          bottomSlot: SemiAvatarBottomSlot(
            shape: SemiAvatarShape.square,
            text: Text('9'),
          ),
        ),
      );
      final decoration = decorationOf(
        tester,
        find.ancestor(
          of: find.text('9'),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect(decoration.border!.top.width, 2);
      expect(
        decoration.border!.top.color,
        const SemiThemeData.light().colors.colorBg0,
      );
      expect(decoration.borderRadius, BorderRadius.circular(4));
      expect(tester.widget<Text>(find.text('9')).style!.fontSize, 12);
      // ★quirk：`shape_square-extra_small` 类名拼写不匹配 → 规则从不命中，
      // font-size 回落 14、border-width 回落 CSS 初始 medium = 3。
      await pumpHost(
        tester,
        const SemiAvatar(
          size: SemiAvatarSize.extraSmall,
          bottomSlot: SemiAvatarBottomSlot(
            shape: SemiAvatarShape.square,
            text: Text('9'),
          ),
        ),
      );
      final quirk = decorationOf(
        tester,
        find.ancestor(
          of: find.text('9'),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect(quirk.border!.top.width, 3);
      expect(
        tester.widget<Text>(find.text('9')).style!.fontSize,
        const SemiThemeData.light().typography.fontSizeRegular,
      );
    });
  });

  group('group', () {
    testWidgets('items overlap with the size margins and ring', (tester) async {
      await pumpHost(
        tester,
        const SemiAvatarGroup(
          children: [
            SemiAvatar(text: 'A'),
            SemiAvatar(text: 'B'),
            SemiAvatar(text: 'C'),
          ],
        ),
      );
      final a = tester.getRect(find.text('A'));
      final b = tester.getRect(find.text('B'));
      final c = tester.getRect(find.text('C'));
      // medium：盒 48、margin -12 → 步进 36。
      expect(b.left - a.left, 36);
      expect(c.left - b.left, 36);
      final ringBox = borderedBoxOf(tester, find.byType(SemiAvatarGroup));
      final decoration = ringBox.decoration as BoxDecoration;
      expect(
        tester.getRect(find.byWidget(ringBox)).width,
        48,
      );
      expect(decoration.border!.top.width, 2);
      expect(
        decoration.border!.top.color,
        const SemiThemeData.light().colors.colorBg1,
      );
    });

    testWidgets('overlapFrom decides which item is on top', (tester) async {
      Future<void> tapOverlap(
        SemiAvatarOverlapFrom from,
        String expected,
      ) async {
        var tapped = '';
        await pumpHost(
          tester,
          SemiAvatarGroup(
            overlapFrom: from,
            children: [
              SemiAvatar(text: 'A', onTap: () => tapped = 'A'),
              SemiAvatar(text: 'B', onTap: () => tapped = 'B'),
            ],
          ),
        );
        final avatarA = tester.getRect(
          find.ancestor(of: find.text('A'), matching: find.byType(SemiAvatar)),
        );
        // 叠压区中部（B 从 left+36 开始）。
        await tester.tapAt(Offset(avatarA.left + 42, avatarA.center.dy));
        expect(tapped, expected);
      }

      await tapOverlap(SemiAvatarOverlapFrom.start, 'A');
      await tapOverlap(SemiAvatarOverlapFrom.end, 'B');
    });

    testWidgets('maxCount folds the tail into a +N avatar', (tester) async {
      await pumpHost(
        tester,
        const SemiAvatarGroup(
          maxCount: 2,
          children: [
            SemiAvatar(text: 'A', alt: 'a'),
            SemiAvatar(text: 'B', alt: 'b'),
            SemiAvatar(text: 'C', alt: 'c'),
          ],
        ),
      );
      expect(find.text('C'), findsNothing);
      expect(find.text('+1'), findsOneWidget);
      // avatarGroup.tsx:65 语义标签（aria-label 覆盖内容文本）。
      expect(
        find.bySemanticsLabel('Number of remaining Avatars：1,c'),
        findsOneWidget,
      );
      final decoration = decorationOf(
        tester,
        find.ancestor(
          of: find.text('+1'),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect(
        decoration.color,
        const SemiThemeData.light().palette.grey5.toColor(),
      );
    });

    testWidgets('renderMore replaces the +N avatar', (tester) async {
      await pumpHost(
        tester,
        SemiAvatarGroup(
          maxCount: 1,
          renderMore: (restNumber, rest) => Text('more $restNumber'),
          children: const [SemiAvatar(text: 'A'), SemiAvatar(text: 'B')],
        ),
      );
      expect(find.text('A'), findsOneWidget);
      expect(find.text('more 1'), findsOneWidget);
      expect(find.text('+1'), findsNothing);
    });

    testWidgets('group size and shape win over child parameters', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiAvatarGroup(
          size: SemiAvatarSize.large,
          shape: SemiAvatarShape.square,
          children: [SemiAvatar(text: 'A', size: SemiAvatarSize.small)],
        ),
      );
      expect(tester.getSize(find.byType(SemiAvatar)), const Size(72, 72));
      final clip = tester.widget<ClipRRect>(
        find.descendant(
          of: find.byType(SemiAvatar),
          matching: find.byType(ClipRRect),
        ),
      );
      expect(clip.borderRadius, BorderRadius.circular(6));
    });

    testWidgets('an image avatar fills the box with cover', (tester) async {
      await pumpHost(
        tester,
        const SemiAvatar(src: _FailingImage(), size: SemiAvatarSize.small),
      );
      expect(find.byType(Image), findsOneWidget);
      expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.cover);
    });
  });
}
