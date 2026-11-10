import 'package:flutter/widgets.dart';

import 'semi_theme.dart';
import 'semi_spin_theme_data.dart';

/// A local, non-null patch. Ancestors remain live, including across SemiTheme.
class SemiSpinTheme extends InheritedTheme {
  const SemiSpinTheme({super.key, required this.data, required super.child});
  final SemiSpinThemeData data;

  /// Merged application and local overrides; defaults remain unresolved.
  static SemiSpinThemeData of(BuildContext context) =>
      _overrides(context, SemiTheme.of(context).components.spin);

  /// Like [of], but null when neither an application nor local theme exists.
  static SemiSpinThemeData? maybeOf(BuildContext context) {
    final global = SemiTheme.maybeOf(context);
    final local = context.dependOnInheritedWidgetOfExactType<SemiSpinTheme>();
    if (global == null && local == null) return null;
    return _overrides(
      context,
      global?.components.spin ?? const SemiSpinThemeData(),
    );
  }

  static SemiSpinThemeData _overrides(
    BuildContext context,
    SemiSpinThemeData base,
  ) {
    final patches = <SemiSpinThemeData>[];
    context.visitAncestorElements((element) {
      if (element.widget is SemiSpinTheme) {
        context.dependOnInheritedElement(element as InheritedElement);
        patches.add((element.widget as SemiSpinTheme).data);
      }
      return true;
    });
    for (final patch in patches.reversed) {
      base = base.merge(patch);
    }
    return base;
  }

  /// Single component entry point; subscribes to global and all local changes.
  static SemiResolvedSpinThemeData resolve(BuildContext context) =>
      of(context).resolve(SemiTheme.of(context));

  @override
  bool updateShouldNotify(SemiSpinTheme oldWidget) => data != oldWidget.data;
  @override
  Widget wrap(BuildContext context, Widget child) =>
      SemiSpinTheme(data: data, child: child);
}
