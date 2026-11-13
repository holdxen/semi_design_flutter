import 'package:flutter/widgets.dart';

import '../theme/semi_theme.dart';
import '../theme/semi_theme_data.dart';

/// Selects the application theme without depending on Material.
enum SemiThemeMode { system, light, dark }

/// A widgets-only application shell with Semi themes and Navigator routing.
class SemiApp extends StatelessWidget {
  const SemiApp({
    super.key,
    this.theme,
    this.darkTheme,
    this.themeMode = SemiThemeMode.system,
    this.home,
    this.title = '',
    this.color,
    this.builder,
    this.routes = const <String, WidgetBuilder>{},
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.initialRoute,
    this.navigatorKey,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.pageRouteBuilder,
    this.locale,
    this.localizationsDelegates,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.debugShowCheckedModeBanner = true,
  });

  final SemiThemeData? theme;
  final SemiThemeData? darkTheme;
  final SemiThemeMode themeMode;
  final Widget? home;
  final String title;
  final Color? color;
  final TransitionBuilder? builder;
  final Map<String, WidgetBuilder> routes;
  final RouteFactory? onGenerateRoute;
  final RouteFactory? onUnknownRoute;
  final String? initialRoute;
  final GlobalKey<NavigatorState>? navigatorKey;
  final List<NavigatorObserver> navigatorObservers;

  /// Defaults to a widgets [PageRouteBuilder] with no transition.
  final PageRouteFactory? pageRouteBuilder;
  final Locale? locale;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final Iterable<Locale> supportedLocales;
  final bool debugShowCheckedModeBanner;

  @override
  Widget build(BuildContext context) {
    // Validate the caller's configuration before installing our own builder.
    assert(home == null || !routes.containsKey(Navigator.defaultRouteName));
    assert(
      builder != null ||
          home != null ||
          routes.containsKey('/') ||
          onGenerateRoute != null ||
          onUnknownRoute != null,
    );
    assert(
      home != null ||
          routes.isNotEmpty ||
          onGenerateRoute != null ||
          onUnknownRoute != null ||
          (builder != null &&
              navigatorKey == null &&
              initialRoute == null &&
              navigatorObservers.isEmpty),
    );
    return WidgetsApp(
      navigatorKey: navigatorKey,
      navigatorObservers: navigatorObservers,
      home: home,
      routes: routes,
      onGenerateRoute: onGenerateRoute,
      onUnknownRoute: onUnknownRoute,
      initialRoute: initialRoute,
      pageRouteBuilder: pageRouteBuilder ?? _pageRoute,
      title: title,
      color: color ?? (theme ?? const SemiThemeData.light()).colors.colorBg0,
      locale: locale,
      localizationsDelegates: localizationsDelegates,
      supportedLocales: supportedLocales,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      builder: (context, child) {
        final dark = switch (themeMode) {
          SemiThemeMode.system =>
            MediaQuery.platformBrightnessOf(context) == Brightness.dark,
          SemiThemeMode.light => false,
          SemiThemeMode.dark => true,
        };
        final data = dark
            ? darkTheme ?? const SemiThemeData.dark()
            : theme ?? const SemiThemeData.light();
        final typography = data.typography;
        return SemiTheme(
          data: data,
          child: DefaultTextStyle(
            style: TextStyle(
              fontFamily: typography.fontFamily,
              fontFamilyFallback: typography.fontFamilyFallback,
              fontSize: typography.fontSizeRegular,
              fontWeight: typography.fontWeightRegular,
              // ★ NO `height` here: Flutter's `TextStyle.height` is not CSS
              // line-height — it scales ascent/descent and drops the
              // baseline (~2px low) while inflating the line box (the
              // recurring "文字偏下/裁剪" family; docs/semi_input.md).
              // Multi-line components carry their own line-height
              // (SemiText/SemiTitle set it explicitly); bare texts lay out
              // at natural metrics and center correctly.
              color: data.colors.colorText0,
            ),
            child: ColoredBox(
              color: data.colors.colorBg0,
              child: Builder(
                builder: (context) => builder != null
                    ? builder!(context, child)
                    : child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }

  static PageRoute<T> _pageRoute<T>(
    RouteSettings settings,
    WidgetBuilder builder,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    );
  }
}
