import 'package:flutter/widgets.dart';

import 'semi_theme.dart';
import 'semi_highlight_theme_data.dart';

/// A live local patch. Capture snapshots local patches, never application data.
class SemiHighlightTheme extends StatelessWidget {
  const SemiHighlightTheme({
    super.key,
    required this.data,
    required this.child,
  });
  final SemiHighlightThemeData data;
  final Widget child;

  static SemiHighlightThemeData of(BuildContext context) =>
      _locals(context, SemiTheme.of(context).components.highlight);

  static SemiHighlightThemeData? maybeOf(BuildContext context) {
    final global = SemiTheme.maybeOf(context);
    final local = context.dependOnInheritedWidgetOfExactType<_HighlightTheme>();
    if (global == null && local == null) return null;
    return _locals(
      context,
      global?.components.highlight ?? const SemiHighlightThemeData(),
    );
  }

  static SemiHighlightThemeData _locals(
    BuildContext context,
    SemiHighlightThemeData base,
  ) {
    final patches = <SemiHighlightThemeData>[];
    context.visitAncestorElements((element) {
      if (element.widget case final _HighlightTheme theme) {
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

  static SemiResolvedHighlightThemeData resolve(BuildContext context) =>
      of(context).resolve(SemiTheme.of(context));

  @override
  Widget build(BuildContext context) => _HighlightTheme(
    data: data,
    capturedLocals: _locals(
      context,
      const SemiHighlightThemeData(),
    ).merge(data),
    child: child,
  );
}

/// Flutter capture deduplicates inherited themes by type. Each node therefore
/// carries an unresolved snapshot of every local ancestor, excluding globals.
class _HighlightTheme extends InheritedTheme {
  const _HighlightTheme({
    required this.data,
    required this.capturedLocals,
    required super.child,
  });
  final SemiHighlightThemeData data;
  final SemiHighlightThemeData capturedLocals;

  @override
  bool updateShouldNotify(_HighlightTheme oldWidget) =>
      data != oldWidget.data || capturedLocals != oldWidget.capturedLocals;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      SemiHighlightTheme(data: capturedLocals, child: child);
}
