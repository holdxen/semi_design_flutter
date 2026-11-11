import 'package:flutter/widgets.dart';

import 'semi_theme.dart';
import 'semi_empty_theme_data.dart';

/// A live local patch. Capture snapshots local patches, never application data.
class SemiEmptyTheme extends StatelessWidget {
  const SemiEmptyTheme({super.key, required this.data, required this.child});
  final SemiEmptyThemeData data;
  final Widget child;

  static SemiEmptyThemeData of(BuildContext context) =>
      _locals(context, SemiTheme.of(context).components.empty);

  static SemiEmptyThemeData? maybeOf(BuildContext context) {
    final global = SemiTheme.maybeOf(context);
    final local = context.dependOnInheritedWidgetOfExactType<_EmptyTheme>();
    if (global == null && local == null) return null;
    return _locals(
      context,
      global?.components.empty ?? const SemiEmptyThemeData(),
    );
  }

  static SemiEmptyThemeData _locals(
    BuildContext context,
    SemiEmptyThemeData base,
  ) {
    final patches = <SemiEmptyThemeData>[];
    context.visitAncestorElements((element) {
      if (element.widget case final _EmptyTheme theme) {
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

  static SemiResolvedEmptyThemeData resolve(BuildContext context) =>
      of(context).resolve(SemiTheme.of(context));

  @override
  Widget build(BuildContext context) => _EmptyTheme(
    data: data,
    capturedLocals: _locals(context, const SemiEmptyThemeData()).merge(data),
    child: child,
  );
}

/// Flutter capture deduplicates inherited themes by type. Each node therefore
/// carries an unresolved snapshot of every local ancestor, excluding globals.
class _EmptyTheme extends InheritedTheme {
  const _EmptyTheme({
    required this.data,
    required this.capturedLocals,
    required super.child,
  });
  final SemiEmptyThemeData data;
  final SemiEmptyThemeData capturedLocals;

  @override
  bool updateShouldNotify(_EmptyTheme oldWidget) =>
      data != oldWidget.data || capturedLocals != oldWidget.capturedLocals;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      SemiEmptyTheme(data: capturedLocals, child: child);
}
