import 'package:flutter/widgets.dart';

import 'semi_theme.dart';
import 'semi_divider_theme_data.dart';

/// A local, non-null patch. Ancestors remain live, including across SemiTheme.
class SemiDividerTheme extends InheritedTheme {
  const SemiDividerTheme({super.key, required this.data, required super.child});
  final SemiDividerThemeData data;

  /// Merged application and local overrides; defaults remain unresolved.
  static SemiDividerThemeData of(BuildContext context) =>
      _overrides(context, SemiTheme.of(context).components.divider);

  /// Like [of], but null when neither an application nor local theme exists.
  static SemiDividerThemeData? maybeOf(BuildContext context) {
    final global = SemiTheme.maybeOf(context);
    final local = context
        .dependOnInheritedWidgetOfExactType<SemiDividerTheme>();
    if (global == null && local == null) return null;
    return _overrides(
      context,
      global?.components.divider ?? const SemiDividerThemeData(),
    );
  }

  static SemiDividerThemeData _overrides(
    BuildContext context,
    SemiDividerThemeData base,
  ) {
    final patches = <SemiDividerThemeData>[];
    context.visitAncestorElements((element) {
      if (element.widget is SemiDividerTheme) {
        context.dependOnInheritedElement(element as InheritedElement);
        patches.add((element.widget as SemiDividerTheme).data);
      }
      return true;
    });
    for (final patch in patches.reversed) {
      base = base.merge(patch);
    }
    return base;
  }

  /// Single component entry point; subscribes to global and all local changes.
  static SemiResolvedDividerThemeData resolve(BuildContext context) =>
      of(context).resolve(SemiTheme.of(context));

  @override
  bool updateShouldNotify(SemiDividerTheme oldWidget) => data != oldWidget.data;
  @override
  Widget wrap(BuildContext context, Widget child) =>
      SemiDividerTheme(data: data, child: child);
}
