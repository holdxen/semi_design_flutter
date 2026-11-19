import 'semi_dropdown_theme_data.dart';

/// Theme overrides for the `SemiContextMenu` menu surface.
///
/// Semi upstream has no ContextMenu (the behavior is ported from Radix
/// primitives `context-menu`/`menu`); the visuals are the SemiDropdown menu
/// token set, so the override type *is* [SemiDropdownThemeData] — every field
/// falls back to `SemiThemeData.components.dropdown` through
/// `SemiContextMenuTheme.resolve`, and `components.contextMenu` holds only the
/// non-null overrides. See docs/semi_context_menu.md.
typedef SemiContextMenuThemeData = SemiDropdownThemeData;
