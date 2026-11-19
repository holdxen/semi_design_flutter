import 'package:flutter/widgets.dart';

import 'semi_context_menu_theme_data.dart';
import 'semi_dropdown_theme_data.dart';
import 'semi_theme.dart';

/// A live local patch on the context-menu channel. Capture snapshots local
/// patches, never application data.
///
/// The channel is independent of [SemiDropdownTheme]: local dropdown patches
/// do not leak into context menus and vice versa; only the global
/// `components.dropdown` tokens backstop `components.contextMenu` overrides.
class SemiContextMenuTheme extends StatelessWidget {
  const SemiContextMenuTheme({
    super.key,
    required this.data,
    required this.child,
  });
  final SemiContextMenuThemeData data;
  final Widget child;

  /// Effective unresolved overrides: local patches (outer→inner merge) over
  /// `components.contextMenu` over `components.dropdown`.
  static SemiContextMenuThemeData of(BuildContext context) =>
      _locals(
        context,
        SemiTheme.of(context).components.dropdown.merge(
          SemiTheme.of(context).components.contextMenu,
        ),
      );

  static SemiContextMenuThemeData? maybeOf(BuildContext context) {
    final global = SemiTheme.maybeOf(context);
    final local = context.dependOnInheritedWidgetOfExactType<_ContextMenuTheme>();
    if (global == null && local == null) return null;
    return _locals(
      context,
      (global?.components.dropdown ?? const SemiDropdownThemeData()).merge(
        global?.components.contextMenu ?? const SemiContextMenuThemeData(),
      ),
    );
  }

  static SemiContextMenuThemeData _locals(
    BuildContext context,
    SemiContextMenuThemeData base,
  ) {
    final patches = <SemiContextMenuThemeData>[];
    context.visitAncestorElements((element) {
      if (element.widget case final _ContextMenuTheme theme) {
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

  static SemiResolvedDropdownThemeData resolve(BuildContext context) =>
      of(context).resolve(SemiTheme.of(context));

  @override
  Widget build(BuildContext context) => _ContextMenuTheme(
    data: data,
    capturedLocals: _locals(
      context,
      const SemiContextMenuThemeData(),
    ).merge(data),
    child: child,
  );
}

/// Flutter capture deduplicates inherited themes by type. Each node therefore
/// carries an unresolved snapshot of every local ancestor, excluding globals.
class _ContextMenuTheme extends InheritedTheme {
  const _ContextMenuTheme({
    required this.data,
    required this.capturedLocals,
    required super.child,
  });
  final SemiContextMenuThemeData data;
  final SemiContextMenuThemeData capturedLocals;

  @override
  bool updateShouldNotify(_ContextMenuTheme oldWidget) =>
      data != oldWidget.data || capturedLocals != oldWidget.capturedLocals;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      SemiContextMenuTheme(data: capturedLocals, child: child);
}
