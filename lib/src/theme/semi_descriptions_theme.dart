import 'package:flutter/widgets.dart';

import 'semi_theme.dart';
import 'semi_descriptions_theme_data.dart';

/// A live local patch. Capture snapshots local patches, never application data.
class SemiDescriptionsTheme extends StatelessWidget {
  const SemiDescriptionsTheme({
    super.key,
    required this.data,
    required this.child,
  });
  final SemiDescriptionsThemeData data;
  final Widget child;

  static SemiDescriptionsThemeData of(BuildContext context) =>
      _locals(context, SemiTheme.of(context).components.descriptions);

  static SemiDescriptionsThemeData? maybeOf(BuildContext context) {
    final global = SemiTheme.maybeOf(context);
    final local = context
        .dependOnInheritedWidgetOfExactType<_DescriptionsTheme>();
    if (global == null && local == null) return null;
    return _locals(
      context,
      global?.components.descriptions ?? const SemiDescriptionsThemeData(),
    );
  }

  static SemiDescriptionsThemeData _locals(
    BuildContext context,
    SemiDescriptionsThemeData base,
  ) {
    final patches = <SemiDescriptionsThemeData>[];
    context.visitAncestorElements((element) {
      if (element.widget case final _DescriptionsTheme theme) {
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

  static SemiResolvedDescriptionsThemeData resolve(BuildContext context) =>
      of(context).resolve(SemiTheme.of(context));

  @override
  Widget build(BuildContext context) => _DescriptionsTheme(
    data: data,
    capturedLocals: _locals(
      context,
      const SemiDescriptionsThemeData(),
    ).merge(data),
    child: child,
  );
}

/// Flutter capture deduplicates inherited themes by type. Each node therefore
/// carries an unresolved snapshot of every local ancestor, excluding globals.
class _DescriptionsTheme extends InheritedTheme {
  const _DescriptionsTheme({
    required this.data,
    required this.capturedLocals,
    required super.child,
  });
  final SemiDescriptionsThemeData data;
  final SemiDescriptionsThemeData capturedLocals;

  @override
  bool updateShouldNotify(_DescriptionsTheme oldWidget) =>
      data != oldWidget.data || capturedLocals != oldWidget.capturedLocals;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      SemiDescriptionsTheme(data: capturedLocals, child: child);
}
