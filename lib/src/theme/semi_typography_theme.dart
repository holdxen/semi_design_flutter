import 'package:flutter/widgets.dart';

import 'semi_theme.dart';
import 'semi_typography_theme_data.dart';

/// A local, non-null patch. Ancestors remain live, including across SemiTheme.
class SemiTypographyTheme extends InheritedTheme {
  const SemiTypographyTheme({
    super.key,
    required this.data,
    required super.child,
  });
  final SemiTypographyThemeData data;

  /// Merged application and local overrides; defaults remain unresolved.
  static SemiTypographyThemeData of(BuildContext context) =>
      _overrides(context, SemiTheme.of(context).components.typography);

  /// Like [of], but null when neither an application nor local theme exists.
  static SemiTypographyThemeData? maybeOf(BuildContext context) {
    final global = SemiTheme.maybeOf(context);
    final local = context
        .dependOnInheritedWidgetOfExactType<SemiTypographyTheme>();
    if (global == null && local == null) return null;
    return _overrides(
      context,
      global?.components.typography ?? const SemiTypographyThemeData(),
    );
  }

  static SemiTypographyThemeData _overrides(
    BuildContext context,
    SemiTypographyThemeData base,
  ) {
    final patches = <SemiTypographyThemeData>[];
    context.visitAncestorElements((element) {
      if (element.widget is SemiTypographyTheme) {
        context.dependOnInheritedElement(element as InheritedElement);
        patches.add((element.widget as SemiTypographyTheme).data);
      }
      return true;
    });
    for (final patch in patches.reversed) {
      base = base.merge(patch);
    }
    return base;
  }

  /// Single component entry point; subscribes to global and all local changes.
  static SemiResolvedTypographyThemeData resolve(BuildContext context) =>
      of(context).resolve(SemiTheme.of(context));

  @override
  bool updateShouldNotify(SemiTypographyTheme oldWidget) =>
      data != oldWidget.data;
  @override
  Widget wrap(BuildContext context, Widget child) =>
      SemiTypographyTheme(data: data, child: child);
}
