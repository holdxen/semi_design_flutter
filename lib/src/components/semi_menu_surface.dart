import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart';

import '../theme/semi_dropdown_theme_data.dart';
import '../theme/semi_icon_theme.dart';
import '../theme/semi_theme.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icon_data.dart';
import 'icon/semi_icons.dart';
import 'semi_menu_nodes.dart';
import 'typography/semi_text.dart';

/// Shared menu surface and row visuals for [SemiDropdown] and
/// `SemiContextMenu` (both paint the upstream `Dropdown.Menu` look).
///
/// The rows carry only visuals + semantics; keyboard navigation, submenu
/// orchestration and item semantics (what activation does) stay with the
/// owning component. Provenance comments point at the upstream dropdown
/// files because Semi has no standalone menu primitive.
class SemiMenuSurface extends StatelessWidget {
  const SemiMenuSurface({
    super.key,
    required this.theme,
    required this.children,
    this.scrollable = true,
  });

  /// Resolved dropdown-family tokens (the menu surface has no token set of
  /// its own).
  final SemiResolvedDropdownThemeData theme;

  /// Menu rows in order.
  final List<Widget> children;

  /// Upstream `overflow-y: auto` on the wrapper; submenus and dropdowns
  /// scroll, short menus can opt out.
  final bool scrollable;

  /// `0 0 1px rgba(0, 0, 0, .3)` — first box-shadow layer of the
  /// `@include shadow-elevated` mixin
  /// (packages/semi-theme-default/scss/global.scss). Hardcoded to the light
  /// token values (see docs/semi_dropdown.md).
  static const BoxShadow shadowElevatedBlur = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.3),
    blurRadius: 1,
  );

  /// `0 4px 14px rgba(0, 0, 0, .1)` — second box-shadow layer of the same
  /// `@include shadow-elevated` mixin.
  static const BoxShadow shadowElevatedDrop = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.1),
    offset: Offset(0, 4),
    blurRadius: 14,
  );

  @override
  Widget build(BuildContext context) {
    // Upstream `&-menu`: `padding: $spacing-dropdown_menu-paddingY $spacing-dropdown_menu-paddingX`.
    Widget menu = Padding(
      padding: EdgeInsets.symmetric(
        vertical: theme.spacingDropdownMenuPaddingY,
        horizontal: theme.spacingDropdownMenuPaddingX,
      ),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
    if (scrollable) {
      menu = SingleChildScrollView(child: menu);
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorDropdownBgDefault,
        borderRadius: BorderRadius.circular(theme.radiusDropdown),
        boxShadow: const [shadowElevatedBlur, shadowElevatedDrop],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.radiusDropdown),
        child: menu,
      ),
    );
  }
}

/// Plain text of a row label ([String]/[Text]/[SemiText]) for typeahead and
/// semantics labels; null for custom [Widget] labels.
String? semiMenuRowText(Object? name) => switch (name) {
  String s => s,
  Text t => t.data,
  SemiText t => t.data,
  _ => null,
};

/// A group heading (upstream `dropdownTitle.tsx` + `&-title` rules).
class SemiMenuTitleRow extends StatelessWidget {
  const SemiMenuTitleRow({
    super.key,
    required this.theme,
    required this.name,
    this.showTickColumn = false,
  });

  final SemiResolvedDropdownThemeData theme;
  final Object? name;

  /// Upstream `dropdownTitle.tsx` reads only the context `showTick`.
  final bool showTickColumn;

  @override
  Widget build(BuildContext context) {
    final fontSize = SemiTheme.of(context).typography.fontSizeSmall;
    final Widget label = switch (name) {
      String s => SemiText(
        s,
        style: TextStyle(
          color: theme.colorDropdownTitleTextDefault,
          fontSize: fontSize,
        ),
      ),
      Widget w => w,
      _ => const SizedBox.shrink(),
    };
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: theme.spacingDropdownTitlePaddingTop,
        bottom: theme.spacingDropdownTitlePaddingBottom,
        start: showTickColumn
            ? theme.spacingDropdownTitleWithTickPaddingLeft
            : theme.spacingDropdownTitlePaddingLeft,
        end: theme.spacingDropdownTitlePaddingRight,
      ),
      child: label,
    );
  }
}

/// A 1px separator (`&-seperator` rules; upstream spelling kept).
class SemiMenuDivider extends StatelessWidget {
  const SemiMenuDivider({super.key, required this.theme});

  final SemiResolvedDropdownThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: theme.spacingDropdownSeperatorMarginY,
        bottom: theme.spacingDropdownSeperatorMarginY,
        start: theme.spacingDropdownSeperatorMarginX,
        end: theme.spacingDropdownSeperatorMarginX,
      ),
      child: SizedBox(
        height: theme.heightDropdownSeperator,
        child: ColoredBox(color: theme.colorDropdownSeperatorBgDefault),
      ),
    );
  }
}

/// Which indicator sits in the leading tick column of a row.
enum SemiMenuIndicator { none, tick, indeterminate }

/// One interactive menu row: leading tick column, optional icon, label and an
/// optional trailing widget (submenu chevron), with the shared hover/pressed/
/// highlighted background trio (upstream `&-item` rules of dropdown.scss).
///
/// [role] selects the semantics role and whether `checked` is announced; the
/// slot geometry is identical across item/checkbox/radio/submenu rows so the
/// tick column stays aligned.
class SemiMenuRow extends StatefulWidget {
  const SemiMenuRow({
    super.key,
    required this.theme,
    required this.name,
    required this.role,
    this.icon,
    this.trailingIcon,
    this.indicator = SemiMenuIndicator.none,
    this.showTickColumn = false,
    this.active = false,
    this.disabled = false,
    this.type,
    this.highlighted = false,
    this.checked,
    this.mixed,
    this.onTap,
    this.onHoverEnter,
    this.onHoverExit,
  });

  final SemiResolvedDropdownThemeData theme;

  /// Label: [String] (rendered as [SemiText]) or [Widget] placed as-is.
  final Object? name;

  /// Leading icon content; laid out at `sizeDropdownIconWidth`×
  /// `sizeDropdownIconHeight` with `spacingDropdownIconMarginRight` gap.
  final Widget? icon;

  /// Right-aligned trailing glyph (submenu chevron), tinted like the label.
  final SemiIconData? trailingIcon;

  /// Tick-column glyph; [SemiMenuIndicator.none] renders the transparent
  /// placeholder (upstream `IconTick color: transparent`).
  final SemiMenuIndicator indicator;

  /// Whether the leading tick column is reserved (group-level
  /// `contextShowTick ?? showTick` for plain rows; always on for checkable
  /// rows).
  final bool showTickColumn;

  /// Bold checked row (upstream `active`): weight
  /// `fontDropdownItemActiveFontWeight`, tick glyph and no hover/pressed fills.
  final bool active;

  /// No interaction, disabled colors (upstream `disabled`).
  final bool disabled;

  /// Text color tier; null keeps `colorDropdownItemTextDefault`.
  final SemiDropdownItemType? type;

  /// Keyboard highlight fill (`:focus-visible` equivalent).
  final bool highlighted;

  /// Announced check state for checkbox/radio roles.
  final bool? checked;

  /// Indeterminate announcement (Radix `aria-checked="mixed"`); menu item
  /// checkables must expose a check state, so indeterminate rows set `mixed`
  /// and leave [checked] null.
  final bool? mixed;

  /// Row activation; null when [disabled].
  final VoidCallback? onTap;

  /// Pointer entered/left the row (submenu hover orchestration).
  final VoidCallback? onHoverEnter;

  /// See [onHoverEnter].
  final VoidCallback? onHoverExit;

  /// `menuitem` / `menuitemcheckbox` / `menuitemradio`.
  final SemanticsRole role;

  @override
  State<SemiMenuRow> createState() => _SemiMenuRowState();
}

class _SemiMenuRowState extends State<SemiMenuRow> {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final item = widget;
    final fontSize = SemiTheme.of(context).typography.fontSizeRegular;
    final Color color = switch (item.type) {
      SemiDropdownItemType.primary => theme.colorDropdownItemPrimaryTextDefault,
      SemiDropdownItemType.secondary =>
        theme.colorDropdownItemSecondaryTextDefault,
      SemiDropdownItemType.tertiary =>
        theme.colorDropdownItemTertiaryTextDefault,
      SemiDropdownItemType.warning => theme.colorDropdownItemWarningTextDefault,
      SemiDropdownItemType.danger => theme.colorDropdownItemDangerTextDefault,
      null => theme.colorDropdownItemTextDefault,
    };
    final textColor = item.disabled
        ? theme.colorDropdownItemDisabledTextDefault
        : color;
    // Upstream `:not(.item-active):hover/:active` — active rows skip the
    // hover/pressed fills; the keyboard highlight (`:focus-visible`) does not.
    final Color bg;
    if (item.disabled) {
      bg = theme.colorDropdownItemDisabledBgDefault;
    } else if (_pressed && !item.active) {
      bg = theme.colorDropdownItemBgActive;
    } else if (_hovering || item.highlighted) {
      bg = theme.colorDropdownItemBgHover;
    } else {
      bg = const Color(0x00000000);
    }

    final Widget label = switch (item.name) {
      String s => SemiText(
        s,
        weight: item.active ? theme.fontDropdownItemActiveFontWeight : null,
        style: TextStyle(color: textColor, fontSize: fontSize),
      ),
      Widget w => w,
      _ => const SizedBox.shrink(),
    };
    // `active` rows always render the tick glyph (upstream `IconTick` inside
    // `item-active`); checkable rows pass their own indicator.
    final indicator = item.active ? SemiMenuIndicator.tick : item.indicator;
    final indicatorVisible = indicator != SemiMenuIndicator.none;
    Widget box = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (item.showTickColumn)
          _iconSlot(
            theme,
            SemiIconTheme(
              data: SemiIconThemeData(
                color: indicatorVisible ? textColor : const Color(0x00000000),
                customSize: theme.sizeDropdownIconWidth,
              ),
              child: ExcludeSemantics(
                // Upstream `IconTick color: transparent`: the placeholder is
                // the same tick glyph tinted transparent when not shown.
                child: switch (indicator) {
                  SemiMenuIndicator.tick => const SemiIcon(
                    SemiIcons.tick,
                    excludeFromSemantics: true,
                  ),
                  SemiMenuIndicator.indeterminate => const SemiIcon(
                    SemiIcons.minus,
                    excludeFromSemantics: true,
                  ),
                  SemiMenuIndicator.none => const SemiIcon(
                    SemiIcons.tick,
                    excludeFromSemantics: true,
                  ),
                },
              ),
            ),
          ),
        if (item.icon != null)
          _iconSlot(
            theme,
            SemiIconTheme(
              data: SemiIconThemeData(
                color: textColor,
                customSize: theme.sizeDropdownIconWidth,
              ),
              child: item.icon!,
            ),
          ),
        Flexible(
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: item.active
                  ? theme.fontDropdownItemActiveFontWeight
                  : null,
            ),
            child: label,
          ),
        ),
        if (item.trailingIcon != null)
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: theme.spacingDropdownIconMarginRight,
            ),
            child: SizedBox(
              width: theme.sizeDropdownIconWidth,
              height: theme.sizeDropdownIconHeight,
              child: SemiIconTheme(
                data: SemiIconThemeData(
                  color: textColor,
                  customSize: theme.sizeDropdownIconWidth,
                ),
                child: SemiIcon(
                  item.trailingIcon!,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
      ],
    );
    box = Padding(
      padding: EdgeInsetsDirectional.only(
        top: theme.spacingDropdownItemPaddingY,
        bottom: theme.spacingDropdownItemPaddingY,
        start: item.showTickColumn
            ? theme.spacingDropdownItemWithTickPaddingLeft
            : theme.spacingDropdownItemPaddingX,
        end: theme.spacingDropdownItemPaddingX,
      ),
      child: box,
    );
    // The item background transition trio. `animationDelay` (upstream's 0ms
    // literal) has no AnimatedContainer counterpart and stays documentation.
    box = AnimatedContainer(
      duration: theme.animationDuration,
      curve: theme.animationCurve,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(theme.radiusDropdownItem),
      ),
      child: box,
    );
    box = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: theme.widthDropdown),
      child: box,
    );
    if (widget.onTap != null) {
      box = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: box,
      );
    }
    box = MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) {
        setState(() => _hovering = true);
        widget.onHoverEnter?.call();
      },
      onExit: (_) {
        setState(() => _hovering = false);
        widget.onHoverExit?.call();
      },
      child: box,
    );
    box = Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = true),
      onPointerUp: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = false),
      onPointerCancel: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = false),
      child: box,
    );
    return Semantics(
      container: true,
      role: widget.role,
      enabled: !widget.disabled,
      checked: widget.checked,
      mixed: widget.mixed,
      child: box,
    );
  }

  /// 12×12 icon slot with the shared right gap (RTL-safe), sized by
  /// `sizeDropdownIconWidth/Height` and `spacingDropdownIconMarginRight`.
  Widget _iconSlot(SemiResolvedDropdownThemeData theme, Widget child) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        end: theme.spacingDropdownIconMarginRight,
      ),
      child: SizedBox(
        width: theme.sizeDropdownIconWidth,
        height: theme.sizeDropdownIconHeight,
        child: child,
      ),
    );
  }
}
