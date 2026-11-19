import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(Widget child, {bool dark = false}) => Directionality(
  textDirection: TextDirection.ltr,
  child: MediaQuery(
    data: const MediaQueryData(),
    child: Center(
      child: SemiTheme(
        data: dark ? const SemiThemeData.dark() : const SemiThemeData.light(),
        child: child,
      ),
    ),
  ),
);

void main() {
  test('catalog matches generated assets and replaces css variables', () {
    const expected = {
      'construction',
      'constructionDark',
      'failure',
      'failureDark',
      'idle',
      'idleDark',
      'noAccess',
      'noAccessDark',
      'noContent',
      'noContentDark',
      'noResult',
      'noResultDark',
      'notFound',
      'notFoundDark',
      'success',
      'successDark',
    };
    expect(SemiIllustrations.values, hasLength(16));
    expect(SemiIllustrations.values.map((d) => d.name).toSet(), expected);
    final files = Directory('assets/illustrations')
        .listSync()
        .map((e) => e.uri.pathSegments.last)
        .toSet();
    expect(files, hasLength(16));
    for (final descriptor in SemiIllustrations.values) {
      expect(descriptor.asset, startsWith('assets/illustrations/'));
      expect(descriptor.package, 'semi_design_flutter');
      expect(files.contains(descriptor.asset.split('/').last), isTrue);
      final source = File(descriptor.asset).readAsStringSync();
      expect(source, isNot(contains('var(')), reason: descriptor.name);
      expect(source, contains('currentColor'), reason: descriptor.name);
      expect(
        source,
        contains('viewBox="0 0 200 200"'),
        reason: descriptor.name,
      );
    }
  });
  testWidgets('all sixteen assets decode', (tester) async {
    for (final descriptor in SemiIllustrations.values) {
      final loader = SvgAssetLoader(
        descriptor.asset,
        packageName: descriptor.package,
      );
      final bytes = await tester.runAsync(() => loader.loadBytes(null));
      expect(bytes, isNotNull, reason: descriptor.name);
      expect(bytes!.lengthInBytes, greaterThan(0), reason: descriptor.name);
      await tester.pumpWidget(host(SemiIllustration(descriptor)));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: descriptor.name);
    }
    await tester.pumpWidget(host(const SizedBox()));
    expect(tester.takeException(), isNull);
  });
  testWidgets('theme picks light or dark artwork', (tester) async {
    Future<void> pumpWith({
      required bool dark,
      SemiIllustrationDescriptor? darkAsset,
    }) async {
      await tester.pumpWidget(
        host(
          SemiIllustration(SemiIllustrations.noContent, dark: darkAsset),
          dark: dark,
        ),
      );
    }

    SvgAssetLoader loaderOf(WidgetTester tester) =>
        tester.widget<SvgPicture>(find.byType(SvgPicture)).bytesLoader
            as SvgAssetLoader;
    await pumpWith(dark: false, darkAsset: SemiIllustrations.noContentDark);
    expect(loaderOf(tester).assetName, 'assets/illustrations/noContent.svg');
    expect(loaderOf(tester).packageName, 'semi_design_flutter');
    await pumpWith(dark: true, darkAsset: SemiIllustrations.noContentDark);
    expect(
      loaderOf(tester).assetName,
      'assets/illustrations/noContent-dark.svg',
    );
    await pumpWith(dark: true);
    expect(loaderOf(tester).assetName, 'assets/illustrations/noContent.svg');
    await tester.pumpWidget(
      host(const SemiIllustration(SemiIllustrations.notFoundDark), dark: false),
    );
    expect(
      loaderOf(tester).assetName,
      'assets/illustrations/notFound-dark.svg',
    );
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('svg theme injects primary currentColor', (tester) async {
    await tester.pumpWidget(
      host(const SemiIllustration(SemiIllustrations.idle)),
    );
    SvgPicture picture() => tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(
      (picture().bytesLoader as SvgLoader).theme!.currentColor,
      const SemiThemeData.light().colors.colorPrimary,
    );
    await tester.pumpWidget(
      host(const SemiIllustration(SemiIllustrations.idle), dark: true),
    );
    expect(
      (picture().bytesLoader as SvgLoader).theme!.currentColor,
      const SemiThemeData.dark().colors.colorPrimary,
    );
    await tester.pumpWidget(
      host(
        SemiTheme(
          data: const SemiThemeData.light(
            colors: SemiColors(colorPrimary: Color(0xff00ff00)),
          ),
          child: const SemiIllustration(SemiIllustrations.idle),
        ),
      ),
    );
    expect(
      (picture().bytesLoader as SvgLoader).theme!.currentColor,
      const Color(0xff00ff00),
    );
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('fixed size independent of text scaling', (tester) async {
    await tester.pumpWidget(
      host(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(3)),
          child: const SemiIllustration(SemiIllustrations.success),
        ),
      ),
    );
    expect(tester.getSize(find.byType(SvgPicture)), const Size(200, 200));
    await tester.pumpWidget(
      host(const SemiIllustration(SemiIllustrations.success, size: 64)),
    );
    expect(tester.getSize(find.byType(SvgPicture)), const Size(64, 64));
    expect(
      () => SemiIllustration(SemiIllustrations.success, size: 0),
      throwsAssertionError,
    );
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('adaptive size follows constraints when size is null', (
    tester,
  ) async {
    Size pictureSize() => tester.getSize(find.byType(SvgPicture));

    // Fully bounded box: fill it and keep the aspect ratio.
    await tester.pumpWidget(
      host(
        const SizedBox(
          width: 120,
          height: 80,
          child: SemiIllustration(SemiIllustrations.success, size: null),
        ),
      ),
    );
    expect(pictureSize(), const Size(120, 80));
    expect(tester.takeException(), isNull);

    // Only a bounded width (vertical flow): square on that axis.
    await tester.pumpWidget(
      host(
        const SizedBox(
          width: 90,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [SemiIllustration(SemiIllustrations.success, size: null)],
          ),
        ),
      ),
    );
    expect(pictureSize(), const Size(90, 90));

    // Only a bounded height (horizontal flow): square on that axis.
    await tester.pumpWidget(
      host(
        const SizedBox(
          height: 70,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [SemiIllustration(SemiIllustrations.success, size: null)],
          ),
        ),
      ),
    );
    expect(pictureSize(), const Size(70, 70));

    // Both axes unbounded: native 200x200.
    await tester.pumpWidget(
      host(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SemiIllustration(SemiIllustrations.success, size: null),
              ],
            ),
          ],
        ),
      ),
    );
    expect(pictureSize(), const Size(200, 200));

    await tester.pumpWidget(
      host(
        const SizedBox(
          width: 50,
          child: SemiIllustration(SemiIllustrations.success, size: null),
        ),
      ),
    );
    expect(pictureSize(), const Size(50, 50));

    expect(
      () => SemiIllustration(SemiIllustrations.success, size: -1),
      throwsAssertionError,
    );
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('decorative semantics excluded', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        Semantics(
          label: 'holder',
          container: true,
          child: const SemiIllustration(SemiIllustrations.success),
        ),
      ),
    );
    expect(find.bySemanticsLabel('holder'), findsOneWidget);
    expect(find.bySemanticsLabel('success'), findsNothing);
    expect(tester.getSemantics(find.byType(SvgPicture)).label, 'holder');
    expect(
      find.descendant(
        of: find.byType(SemiIllustration),
        matching: find.byType(ExcludeSemantics),
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(host(const SizedBox()));
    handle.dispose();
  });
}
