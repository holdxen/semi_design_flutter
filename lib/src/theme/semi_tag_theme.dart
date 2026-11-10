import 'package:flutter/widgets.dart';

import 'semi_theme.dart';
import 'semi_tag_theme_data.dart';

/// A live local patch. Capture snapshots local patches, never application data.
class SemiTagTheme extends StatelessWidget {
  const SemiTagTheme({super.key, required this.data, required this.child});
  final SemiTagThemeData data;
  final Widget child;

  static SemiTagThemeData of(BuildContext context) =>
      _locals(context, SemiTheme.of(context).components.tag);

  static SemiTagThemeData? maybeOf(BuildContext context) {
    final global = SemiTheme.maybeOf(context);
    final local = context.dependOnInheritedWidgetOfExactType<_TagTheme>();
    if (global == null && local == null) return null;
    return _locals(context, global?.components.tag ?? const SemiTagThemeData());
  }

  static SemiTagThemeData _locals(BuildContext context, SemiTagThemeData base) {
    final patches = <SemiTagThemeData>[];
    context.visitAncestorElements((element) {
      if (element.widget case final _TagTheme theme) {
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

  static SemiResolvedTagThemeData resolve(BuildContext context) =>
      of(context).resolve(SemiTheme.of(context));

  @override
  Widget build(BuildContext context) => _TagTheme(
    data: data,
    capturedLocals: _locals(context, const SemiTagThemeData()).merge(data),
    child: child,
  );
}

/// Flutter capture deduplicates inherited themes by type. Each node therefore
/// carries an unresolved snapshot of every local ancestor, excluding globals.
class _TagTheme extends InheritedTheme {
  const _TagTheme({
    required this.data,
    required this.capturedLocals,
    required super.child,
  });
  final SemiTagThemeData data;
  final SemiTagThemeData capturedLocals;

  @override
  bool updateShouldNotify(_TagTheme oldWidget) =>
      data != oldWidget.data || capturedLocals != oldWidget.capturedLocals;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      SemiTagTheme(data: capturedLocals, child: child);
}
