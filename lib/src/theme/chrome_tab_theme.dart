import 'package:flutter/widgets.dart';

import 'chrome_tab_theme_data.dart';
import 'semi_theme.dart';

/// Provides a live, nestable local ChromeTab theme patch.
class ChromeTabTheme extends StatelessWidget {
  const ChromeTabTheme({super.key, required this.data, required this.child});

  final ChromeTabThemeData data;
  final Widget child;

  static ChromeTabThemeData of(BuildContext context) =>
      _locals(context, SemiTheme.of(context).components.chromeTab);

  static ChromeTabThemeData? maybeOf(BuildContext context) {
    final global = SemiTheme.maybeOf(context);
    final local = context.dependOnInheritedWidgetOfExactType<_ChromeTabTheme>();
    if (global == null && local == null) return null;
    return _locals(
      context,
      global?.components.chromeTab ?? const ChromeTabThemeData(),
    );
  }

  static ChromeTabThemeData _locals(
    BuildContext context,
    ChromeTabThemeData base,
  ) {
    final patches = <ChromeTabThemeData>[];
    context.visitAncestorElements((element) {
      if (element.widget case final _ChromeTabTheme theme) {
        context.dependOnInheritedElement(element as InheritedElement);
        patches.add(theme.data);
      }
      return true;
    });
    for (final patch in patches.reversed) {
      base = base.merge(patch);
    }
    return base;
  }

  static SemiResolvedChromeTabThemeData resolve(BuildContext context) =>
      of(context).resolve(SemiTheme.of(context));

  @override
  Widget build(BuildContext context) => _ChromeTabTheme(
    data: data,
    capturedLocals: _locals(context, const ChromeTabThemeData()).merge(data),
    child: child,
  );
}

/// Each node carries a local unresolved snapshot so Flutter's inherited theme
/// capture can safely deduplicate nested ChromeTab themes.
class _ChromeTabTheme extends InheritedTheme {
  const _ChromeTabTheme({
    required this.data,
    required this.capturedLocals,
    required super.child,
  });

  final ChromeTabThemeData data;
  final ChromeTabThemeData capturedLocals;

  @override
  bool updateShouldNotify(_ChromeTabTheme oldWidget) =>
      data != oldWidget.data || capturedLocals != oldWidget.capturedLocals;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      ChromeTabTheme(data: capturedLocals, child: child);
}
