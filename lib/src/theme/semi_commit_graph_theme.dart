import 'package:flutter/widgets.dart';

import 'semi_commit_graph_theme_data.dart';
import 'semi_theme.dart';

/// Live local theme patch for [SemiCommitGraph]. Mirrors the Semi local-theme
/// pattern: unresolved patches are captured from every ancestor and merged,
/// then resolved against the global [SemiTheme].
class SemiCommitGraphTheme extends StatelessWidget {
  const SemiCommitGraphTheme({
    super.key,
    required this.data,
    required this.child,
  });

  final SemiCommitGraphThemeData data;
  final Widget child;

  static SemiCommitGraphThemeData of(BuildContext context) =>
      _locals(context, const SemiCommitGraphThemeData());

  static SemiCommitGraphThemeData? maybeOf(BuildContext context) {
    final local = context.dependOnInheritedWidgetOfExactType<_CommitGraphTheme>();
    return local?.data;
  }

  static SemiCommitGraphThemeData _locals(
    BuildContext context,
    SemiCommitGraphThemeData base,
  ) {
    final patches = <SemiCommitGraphThemeData>[];
    context.visitAncestorElements((element) {
      if (element.widget case final _CommitGraphTheme theme) {
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

  static SemiResolvedCommitGraphThemeData resolve(BuildContext context) =>
      of(context).resolve(SemiTheme.of(context));

  @override
  Widget build(BuildContext context) => _CommitGraphTheme(
        data: data,
        child: child,
      );
}

class _CommitGraphTheme extends InheritedTheme {
  const _CommitGraphTheme({required this.data, required super.child});

  final SemiCommitGraphThemeData data;

  @override
  bool updateShouldNotify(_CommitGraphTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      SemiCommitGraphTheme(data: data, child: child);
}
