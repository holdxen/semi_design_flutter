import 'package:flutter/widgets.dart';

import 'semi_theme.dart';
import 'semi_progress_theme_data.dart';

/// A live local patch. Capture snapshots local patches, never application data.
class SemiProgressTheme extends StatelessWidget {
  const SemiProgressTheme({super.key, required this.data, required this.child});
  final SemiProgressThemeData data;
  final Widget child;

  static SemiProgressThemeData of(BuildContext context) =>
      _locals(context, SemiTheme.of(context).components.progress);

  static SemiProgressThemeData? maybeOf(BuildContext context) {
    final global = SemiTheme.maybeOf(context);
    final local = context.dependOnInheritedWidgetOfExactType<_ProgressTheme>();
    if (global == null && local == null) return null;
    return _locals(
      context,
      global?.components.progress ?? const SemiProgressThemeData(),
    );
  }

  static SemiProgressThemeData _locals(
    BuildContext context,
    SemiProgressThemeData base,
  ) {
    final patches = <SemiProgressThemeData>[];
    context.visitAncestorElements((element) {
      if (element.widget case final _ProgressTheme theme) {
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

  static SemiResolvedProgressThemeData resolve(BuildContext context) =>
      of(context).resolve(SemiTheme.of(context));

  @override
  Widget build(BuildContext context) => _ProgressTheme(
    data: data,
    capturedLocals: _locals(context, const SemiProgressThemeData()).merge(data),
    child: child,
  );
}

/// Flutter capture deduplicates inherited themes by type. Each node therefore
/// carries an unresolved snapshot of every local ancestor, excluding globals.
class _ProgressTheme extends InheritedTheme {
  const _ProgressTheme({
    required this.data,
    required this.capturedLocals,
    required super.child,
  });
  final SemiProgressThemeData data;
  final SemiProgressThemeData capturedLocals;

  @override
  bool updateShouldNotify(_ProgressTheme oldWidget) =>
      data != oldWidget.data || capturedLocals != oldWidget.capturedLocals;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      SemiProgressTheme(data: capturedLocals, child: child);
}
