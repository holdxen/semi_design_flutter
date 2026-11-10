import 'dart:ui' show PointerDeviceKind;
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  test('catalog and all 523 SVGs decode with metadata', () async {
    final manifest =
        jsonDecode(File('tool/icon_manifest.json').readAsStringSync()) as List;
    expect(SemiIcons.values.length, 523);
    expect(SemiIcons.values.map((e) => e.name).toSet().length, 523);
    expect(SemiIcons.values.map((e) => e.name), manifest.map((e) => e['name']));
    for (final entry in manifest) {
      final source = File(entry['asset'] as String).readAsStringSync();
      expect(
        source.contains('currentColor'),
        entry['currentColor'],
        reason: entry['name'],
      );
      expect(source.contains('Gradient'), entry['gradient']);
      expect(source.contains('stroke='), entry['stroke']);
      expect(source.contains('clip'), entry['clip']);
      final picture = await vg.loadPicture(SvgStringLoader(source), null);
      expect(picture.size.isEmpty, false, reason: entry['name']);
      picture.picture.dispose();
    }
    expect(
      File('assets/icons/ai_edit_level_2.svg').readAsStringSync(),
      contains('rgb(166,71,255)'),
    );
    expect(
      File('assets/icons/ai_edit_level_3.svg').readAsStringSync(),
      contains('rgb(233,69,255)'),
    );
  });
  const source =
      '<svg viewBox="0 0 24 24"><path fill="currentColor" d="M0 0h24v24H0z"/></svg>';
  Widget host(Widget child) =>
      Directionality(textDirection: TextDirection.ltr, child: child);
  testWidgets('all sizes, custom and inherited theme', (tester) async {
    for (final (size, pixels) in [
      (SemiIconSize.extraSmall, 8.0),
      (SemiIconSize.small, 12.0),
      (SemiIconSize.normal, 16.0),
      (SemiIconSize.large, 20.0),
      (SemiIconSize.extraLarge, 24.0),
      (SemiIconSize.inherit, 31.0),
    ]) {
      await tester.pumpWidget(
        host(
          DefaultTextStyle(
            style: const TextStyle(fontSize: 31),
            child: SemiIcon.svg(source, size: size),
          ),
        ),
      );
      expect(tester.widget<SvgPicture>(find.byType(SvgPicture)).width, pixels);
    }
    await tester.pumpWidget(
      host(
        const SemiIconTheme(
          data: SemiIconThemeData(
            color: Color(0xff123456),
            size: SemiIconSize.large,
          ),
          child: SemiIconTheme(
            data: SemiIconThemeData(customSize: 27),
            child: SemiIcon.svg(source),
          ),
        ),
      ),
    );
    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(svg.width, 27);
    expect(
      (svg.bytesLoader as SvgLoader).theme!.currentColor,
      const Color(0xff123456),
    );
  });
  testWidgets('spin rotation reduced motion and lifecycle', (tester) async {
    await tester.pumpWidget(
      host(const SemiIcon.svg(source, rotate: 45, spin: true)),
    );
    await tester.pump(const Duration(milliseconds: 150));
    final matrix = tester.widget<Transform>(find.byType(Transform)).transform;
    expect(matrix.storage[0].abs(), closeTo(0.707, .01));
    await tester.pumpWidget(
      host(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: SemiIcon.svg(source, spin: true),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(tester.hasRunningAnimations, false);
    await tester.pumpWidget(host(const SizedBox()));
    expect(tester.takeException(), null);
  });
  testWidgets('single label and excluded semantics', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(const SemiIcon.svg(source, semanticsLabel: 'Custom icon')),
    );
    expect(find.bySemanticsLabel('Custom icon'), findsOneWidget);
    await tester.pumpWidget(
      host(
        const SemiIcon.svg(
          source,
          semanticsLabel: 'Custom icon',
          excludeFromSemantics: true,
        ),
      ),
    );
    expect(find.bySemanticsLabel('Custom icon'), findsNothing);
    handle.dispose();
  });
  testWidgets('text warning disabled and link prefix resolved color', (
    tester,
  ) async {
    for (final text in [
      const SemiText(
        'Warning',
        type: SemiTextType.warning,
        icon: SemiIcon.svg(source),
      ),
      const SemiText('Disabled', disabled: true, icon: SemiIcon.svg(source)),
      SemiText(
        'Link',
        link: SemiTextLink(onTap: () {}),
        icon: const SemiIcon.svg(source),
      ),
    ]) {
      await tester.pumpWidget(host(text));
      final color = tester.widget<Text>(find.byType(Text)).style!.color;
      expect(
        (tester.widget<SvgPicture>(find.byType(SvgPicture)).bytesLoader
                as SvgLoader)
            .theme!
            .currentColor,
        color,
      );
      expect(tester.widget<SvgPicture>(find.byType(SvgPicture)).width, 16);
    }
  });
  test('theme value behavior and validation', () {
    const theme = SemiIconThemeData(size: SemiIconSize.small);
    expect(theme.copyWith(), theme);
    expect(
      theme.merge(const SemiIconThemeData(color: Color(0xff000001))).size,
      SemiIconSize.small,
    );
    expect(
      () => SemiIcon.svg(source, rotate: double.nan),
      throwsAssertionError,
    );
    expect(() => SemiIcon.svg(source, customSize: 0), throwsAssertionError);
  });
  testWidgets('dark fallback explicit colors asset and ticker mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const SemiTheme(
          data: SemiThemeData.dark(),
          child: SemiIcon.svg(source),
        ),
      ),
    );
    var picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(
      (picture.bytesLoader as SvgLoader).theme!.currentColor,
      const SemiThemeData.dark().colors.colorText0,
    );
    await tester.pumpWidget(
      host(
        const SemiIconTheme(
          data: SemiIconThemeData(color: Color(0xff112233)),
          child: SemiIcon(
            SemiIcons.plus,
            color: Color(0xffabcdef),
            size: SemiIconSize.small,
          ),
        ),
      ),
    );
    picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(
      (picture.bytesLoader as SvgLoader).theme!.currentColor,
      const Color(0xffabcdef),
    );
    expect(picture.bytesLoader, isA<SvgAssetLoader>());
    await tester.pumpWidget(
      host(
        const TickerMode(
          enabled: false,
          child: SemiIcon.svg(source, spin: true),
        ),
      ),
    );
    expect(tester.hasRunningAnimations, false);
  });
  testWidgets(
    'link hover prefix follows resolved text and explicit icon wins',
    (tester) async {
      await tester.pumpWidget(
        host(
          SemiText(
            'Link',
            link: SemiTextLink(onTap: () {}),
            icon: const SemiIcon.svg(source),
          ),
        ),
      );
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: const Offset(500, 500));
      await gesture.moveTo(tester.getCenter(find.byType(Text)));
      await tester.pump();
      expect(
        (tester.widget<SvgPicture>(find.byType(SvgPicture)).bytesLoader
                as SvgLoader)
            .theme!
            .currentColor,
        tester.widget<Text>(find.byType(Text)).style!.color,
      );
      await gesture.removePointer();
      await tester.pumpWidget(
        host(
          const SemiText(
            'Warning',
            type: SemiTextType.warning,
            icon: SemiIcon.svg(source, color: Color(0xff123456)),
          ),
        ),
      );
      expect(
        (tester.widget<SvgPicture>(find.byType(SvgPicture)).bytesLoader
                as SvgLoader)
            .theme!
            .currentColor,
        const Color(0xff123456),
      );
    },
  );
}
