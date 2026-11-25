import 'package:flutter/widgets.dart';

import 'semi_scroll_bar_theme_data.dart';
import 'semi_theme.dart';

/// A local, non-null patch. Ancestors remain live, including across SemiTheme.
class SemiScrollBarTheme extends InheritedTheme {
  const SemiScrollBarTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final SemiScrollBarThemeData data;

  /// Merged application and local overrides; defaults remain unresolved.
  static SemiScrollBarThemeData of(BuildContext context) =>
      _overrides(context, SemiTheme.of(context).components.scrollBar);

  /// Like [of], but null when neither an application nor local theme exists.
  static SemiScrollBarThemeData? maybeOf(BuildContext context) {
    final global = SemiTheme.maybeOf(context);
    final local = context
        .dependOnInheritedWidgetOfExactType<SemiScrollBarTheme>();
    if (global == null && local == null) return null;
    return _overrides(
      context,
      global?.components.scrollBar ?? const SemiScrollBarThemeData(),
    );
  }

  static SemiScrollBarThemeData _overrides(
    BuildContext context,
    SemiScrollBarThemeData base,
  ) {
    final patches = <SemiScrollBarThemeData>[];
    context.visitAncestorElements((element) {
      if (element.widget is SemiScrollBarTheme) {
        context.dependOnInheritedElement(element as InheritedElement);
        patches.add((element.widget as SemiScrollBarTheme).data);
      }
      return true;
    });
    for (final patch in patches.reversed) {
      base = base.merge(patch);
    }
    return base;
  }

  /// Single component entry point; subscribes to global and all local changes.
  static SemiResolvedScrollBarThemeData resolve(BuildContext context) =>
      of(context).resolve(SemiTheme.of(context));

  @override
  bool updateShouldNotify(SemiScrollBarTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      SemiScrollBarTheme(data: data, child: child);
}
