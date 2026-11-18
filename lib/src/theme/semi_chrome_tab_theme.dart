import 'package:flutter/widgets.dart';

import 'semi_chrome_tab_theme_data.dart';
import 'semi_theme.dart';

/// A live local patch for [SemiChromeTab]. Nested patches merge in order.
class SemiChromeTabTheme extends StatelessWidget {
  const SemiChromeTabTheme({
    super.key,
    required this.data,
    required this.child,
  });

  final SemiChromeTabThemeData data;
  final Widget child;

  static SemiChromeTabThemeData of(BuildContext context) =>
      _locals(context, SemiTheme.of(context).components.chromeTab);

  static SemiChromeTabThemeData? maybeOf(BuildContext context) {
    final global = SemiTheme.maybeOf(context);
    final local = context
        .dependOnInheritedWidgetOfExactType<_SemiChromeTabTheme>();
    if (global == null && local == null) return null;
    return _locals(
      context,
      global?.components.chromeTab ?? const SemiChromeTabThemeData(),
    );
  }

  static SemiChromeTabThemeData _locals(
    BuildContext context,
    SemiChromeTabThemeData base,
  ) {
    final patches = <SemiChromeTabThemeData>[];
    context.visitAncestorElements((element) {
      if (element.widget case final _SemiChromeTabTheme theme) {
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
  Widget build(BuildContext context) => _SemiChromeTabTheme(
    data: data,
    capturedLocals: _locals(
      context,
      const SemiChromeTabThemeData(),
    ).merge(data),
    child: child,
  );
}

/// Each node carries a local unresolved snapshot so Flutter's inherited theme
/// capture can safely deduplicate nested SemiChromeTab themes.
class _SemiChromeTabTheme extends InheritedTheme {
  const _SemiChromeTabTheme({
    required this.data,
    required this.capturedLocals,
    required super.child,
  });

  final SemiChromeTabThemeData data;
  final SemiChromeTabThemeData capturedLocals;

  @override
  bool updateShouldNotify(_SemiChromeTabTheme oldWidget) =>
      data != oldWidget.data || capturedLocals != oldWidget.capturedLocals;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      SemiChromeTabTheme(data: capturedLocals, child: child);
}
