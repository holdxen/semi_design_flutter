import 'package:flutter/widgets.dart';

import 'semi_theme.dart';
import 'semi_timeline_theme_data.dart';

/// A live local patch. Capture snapshots local patches, never application data.
class SemiTimelineTheme extends StatelessWidget {
  const SemiTimelineTheme({super.key, required this.data, required this.child});
  final SemiTimelineThemeData data;
  final Widget child;

  static SemiTimelineThemeData of(BuildContext context) =>
      _locals(context, SemiTheme.of(context).components.timeline);

  static SemiTimelineThemeData? maybeOf(BuildContext context) {
    final global = SemiTheme.maybeOf(context);
    final local = context.dependOnInheritedWidgetOfExactType<_TimelineTheme>();
    if (global == null && local == null) return null;
    return _locals(
      context,
      global?.components.timeline ?? const SemiTimelineThemeData(),
    );
  }

  static SemiTimelineThemeData _locals(
    BuildContext context,
    SemiTimelineThemeData base,
  ) {
    final patches = <SemiTimelineThemeData>[];
    context.visitAncestorElements((element) {
      if (element.widget case final _TimelineTheme theme) {
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

  static SemiResolvedTimelineThemeData resolve(BuildContext context) =>
      of(context).resolve(SemiTheme.of(context));

  @override
  Widget build(BuildContext context) => _TimelineTheme(
    data: data,
    capturedLocals: _locals(context, const SemiTimelineThemeData()).merge(data),
    child: child,
  );
}

/// Flutter capture deduplicates inherited themes by type. Each node therefore
/// carries an unresolved snapshot of every local ancestor, excluding globals.
class _TimelineTheme extends InheritedTheme {
  const _TimelineTheme({
    required this.data,
    required this.capturedLocals,
    required super.child,
  });
  final SemiTimelineThemeData data;
  final SemiTimelineThemeData capturedLocals;

  @override
  bool updateShouldNotify(_TimelineTheme oldWidget) =>
      data != oldWidget.data || capturedLocals != oldWidget.capturedLocals;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      SemiTimelineTheme(data: capturedLocals, child: child);
}
