import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  testWidgets('defaults and explicit modes provide widgets infrastructure', (
    tester,
  ) async {
    for (final mode in SemiThemeMode.values) {
      await tester.pumpWidget(
        SemiApp(themeMode: mode, home: const Text('home')),
      );
      final context = tester.element(find.text('home'));
      expect(SemiTheme.of(context).dark, mode == SemiThemeMode.dark);
      expect(Directionality.of(context), TextDirection.ltr);
      expect(
        Localizations.of<WidgetsLocalizations>(context, WidgetsLocalizations),
        isNotNull,
      );
      expect(Overlay.of(context), isNotNull);
      expect(DefaultTextStyle.of(context).style.fontFamily, 'Inter');
      expect(find.byType(WidgetsApp), findsOneWidget);
      expect(
        tester.widget<ColoredBox>(find.byType(ColoredBox).first).color,
        SemiTheme.of(context).colors.colorBg0,
      );
    }
  });

  testWidgets('system brightness updates theme and explicit light ignores it', (
    tester,
  ) async {
    final platform = tester.binding.platformDispatcher;
    addTearDown(platform.clearPlatformBrightnessTestValue);
    platform.platformBrightnessTestValue = Brightness.light;
    await tester.pumpWidget(const SemiApp(home: Text('home')));
    expect(SemiTheme.of(tester.element(find.text('home'))).dark, isFalse);
    platform.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(SemiTheme.of(tester.element(find.text('home'))).dark, isTrue);
    await tester.pumpWidget(
      const SemiApp(themeMode: SemiThemeMode.light, home: Text('home')),
    );
    expect(SemiTheme.of(tester.element(find.text('home'))).dark, isFalse);
  });

  testWidgets('builder and routes share dynamic theme and font', (
    tester,
  ) async {
    final key = GlobalKey<NavigatorState>();
    SemiThemeData? observed;
    Widget app(SemiThemeData theme) => SemiApp(
      themeMode: SemiThemeMode.light,
      theme: theme,
      navigatorKey: key,
      home: const Column(children: [Text('home'), SemiText('component')]),
      builder: (context, child) {
        observed = SemiTheme.of(context);
        expect(child, isNotNull);
        expect(
          DefaultTextStyle.of(context).style.fontFamily,
          theme.typography.fontFamily,
        );
        return child!;
      },
      routes: {'/next': (_) => const Text('next')},
      onUnknownRoute: (settings) => PageRouteBuilder<void>(
        settings: settings,
        pageBuilder: (_, _, _) => const Text('unknown'),
      ),
    );
    final custom = SemiThemeData.light(
      components: const SemiComponentThemes(
        typography: SemiTypographyThemeData(
          defaultTextColor: Color(0xff123456),
        ),
      ),
      typography: SemiTypographyTokens(fontFamily: 'Custom'),
    );
    await tester.pumpWidget(app(custom));
    expect(observed, custom);
    expect(
      tester.widget<Text>(find.text('component')).style!.color,
      const Color(0xff123456),
    );
    expect(
      SemiTheme.of(tester.element(find.text('home'))).components,
      custom.components,
    );
    final overlayEntry = OverlayEntry(
      builder: (context) {
        expect(SemiTheme.of(context), custom);
        return const Positioned(top: 0, left: 0, child: Text('overlay'));
      },
    );
    key.currentState!.overlay!.insert(overlayEntry);
    await tester.pump();
    expect(find.text('overlay'), findsOneWidget);
    overlayEntry.remove();
    overlayEntry.dispose();
    key.currentState!.push<void>(
      PageRouteBuilder<void>(pageBuilder: (_, _, _) => const Text('pushed')),
    );
    await tester.pumpAndSettle();
    expect(find.text('pushed'), findsOneWidget);
    key.currentState!.pop();
    await tester.pumpAndSettle();
    key.currentState!.pushNamed('/next');
    await tester.pumpAndSettle();
    expect(find.text('next'), findsOneWidget);
    expect(
      DefaultTextStyle.of(tester.element(find.text('next'))).style.fontFamily,
      'Custom',
    );
    key.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    key.currentState!.pushNamed('/missing');
    await tester.pumpAndSettle();
    expect(find.text('unknown'), findsOneWidget);
    final updated = custom.copyWith(
      typography: SemiTypographyTokens(fontFamily: 'Updated'),
    );
    await tester.pumpWidget(app(updated));
    expect(observed, updated);
    expect(
      DefaultTextStyle.of(tester.element(find.text('unknown')))
          .style
          .fontFamily,
      'Updated',
    );
  });

  testWidgets('builder-only app receives null child and explicit dark data', (
    tester,
  ) async {
    final data = SemiThemeData.dark(
      typography: SemiTypographyTokens(fontFamily: 'Night'),
    );
    await tester.pumpWidget(
      SemiApp(
        themeMode: SemiThemeMode.dark,
        darkTheme: data,
        builder: (context, child) {
          expect(child, isNull);
          expect(SemiTheme.of(context), data);
          return const Text('builder');
        },
      ),
    );
    expect(find.text('builder'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
