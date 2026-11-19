import 'dart:ui' show SemanticsRole;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../overlay/tooltip_positioning.dart';
import '../theme/semi_dropdown_theme.dart';
import '../theme/semi_dropdown_theme_data.dart';
import '../theme/semi_icon_theme.dart';
import '../theme/semi_theme.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icons.dart';
import 'semi_menu_surface.dart';
import 'semi_tooltip.dart';
import 'typography/semi_text.dart';

import 'semi_menu_nodes.dart';

export 'semi_menu_nodes.dart';

/// A dropdown menu built on [SemiTooltip] (upstream `Dropdown`/index.tsx).
///
/// Port notes (see docs/semi_dropdown.md for the full difference list):
/// * [visible] non-null is fully controlled (web is semi-controlled).
/// * [menu] and [content] are mutually exclusive (web `menu` falls back to
///   `render` when it is a valid element).
/// * Nested dropdowns inside [content] register their popups on the parent's
///   pointer-exemption scope, so clicking a child menu never closes the
///   parent while sibling popups do (web closes the parent and works around
///   it with `onMouseDown` item callbacks).
class SemiDropdown extends StatefulWidget {
  const SemiDropdown({
    super.key,
    required this.child,
    this.menu,
    this.content,
    this.showTick,
    this.trigger = SemiTooltipTrigger.hover,
    this.position = SemiTooltipPosition.bottom,
    this.spacing,
    this.mouseEnterDelay = const Duration(milliseconds: 50),
    this.mouseLeaveDelay = const Duration(milliseconds: 100),
    this.closeOnEsc = true,
    this.clickToHide = false,
    this.motion = true,
    this.visible,
    this.onVisibleChange,
    this.onClickOutSide,
    this.onEscKeyDown,
    this.repositionKey,
    this.zIndex = _DropdownMetrics.zIndex,
  }) : assert(
         menu == null || content == null,
         'SemiDropdown takes either menu or content, not both.',
       );

  /// The trigger subtree.
  final Widget child;

  /// Declarative menu nodes (upstream `menu`). An empty list renders an empty
  /// menu, like upstream.
  final List<SemiDropdownNode>? menu;

  /// Custom popup body (upstream `render`).
  final Widget? content;

  /// Group-level tick column. Non-null wins over
  /// [SemiDropdownItemData.showTick] (upstream `contextShowTick ?? showTick`).
  final bool? showTick;

  /// Interaction mode (the same five triggers as [SemiTooltip]).
  final SemiTooltipTrigger trigger;

  /// Preferred placement (upstream `position`, default `bottom`).
  final SemiTooltipPosition position;

  /// Gap between trigger and popup; defaults to 4, or 2 inside another
  /// dropdown (upstream `numbers.SPACING`/`NESTED_SPACING`).
  final double? spacing;

  /// Hover/focus show delay (upstream `mouseEnterDelay`).
  final Duration mouseEnterDelay;

  /// Hover/focus hide delay (upstream `mouseLeaveDelay`, 100ms).
  final Duration mouseLeaveDelay;

  /// Consume Escape and close while visible (upstream `closeOnEsc`, true).
  final bool closeOnEsc;

  /// Hide when the popup itself is tapped (upstream `clickToHide`).
  final bool clickToHide;

  /// Whether the show/hide motion plays (upstream `motion`).
  final bool motion;

  /// Controlled visibility; non-null is fully controlled (upstream `visible`
  /// is semi-controlled).
  final bool? visible;

  /// Reports visibility changes (upstream `onVisibleChange`).
  final ValueChanged<bool>? onVisibleChange;

  /// Called before closing because of a tap outside trigger and popup.
  final VoidCallback? onClickOutSide;

  /// Called when Escape is consumed.
  final VoidCallback? onEscKeyDown;

  /// Changing this value forces a reposition (upstream `rePosKey`).
  final Object? repositionKey;

  /// Parity with [SemiTooltip.zIndex] (unused; overlay insertion order rules).
  /// Defaults to `$z-dropdown` (1050); the upstream JS prop defaults to the
  /// tooltip's 1060.
  final int zIndex;

  @override
  State<SemiDropdown> createState() => _SemiDropdownState();
}

class _SemiDropdownState extends State<SemiDropdown> {
  /// Mirrors upstream `popVisible` (aria-expanded state).
  bool _popVisible = false;

  void _handleVisibleChange(bool visible) {
    if (visible != _popVisible) {
      setState(() => _popVisible = visible);
    }
    widget.onVisibleChange?.call(visible);
  }

  @override
  Widget build(BuildContext context) {
    final scope = _DropdownScope.maybeOf(context);
    final level = scope?.level ?? 0;
    // Upstream index.tsx: nested dropdowns default to NESTED_SPACING (2) and
    // top-level ones to SPACING (4); an explicit numeric spacing always wins.
    final spacing = widget.spacing ?? (level > 0 ? _kNestedSpacing : _kSpacing);
    final body = widget.menu != null
        ? _SemiDropdownMenu(
            nodes: widget.menu!,
            focusOnShow: widget.trigger == SemiTooltipTrigger.click,
          )
        // Custom `content` renders (SemiNavigation's Sub list, SemiBreadcrumb's
        // overflow panel) live in the same upstream `-wrapper` as the menu, so
        // they paint the wrapper surface too (bg3 / medium radius / elevated
        // shadow); otherwise the render floats without a popup card.
        : _DropdownWrapperSurface(
            child: widget.content ?? const SizedBox.shrink(),
          );
    return SemiTooltip(
      content: _DropdownScope(
        level: level + 1,
        showTick: widget.showTick,
        // `@include font-size-regular` on the upstream content wrapper.
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: SemiTheme.of(context).typography.fontSizeRegular,
          ),
          child: body,
        ),
      ),
      trigger: widget.trigger,
      position: widget.position,
      spacing: spacing,
      mouseEnterDelay: widget.mouseEnterDelay,
      mouseLeaveDelay: widget.mouseLeaveDelay,
      closeOnEsc: widget.closeOnEsc,
      clickToHide: widget.clickToHide,
      motion: widget.motion,
      visible: widget.visible,
      onVisibleChange: _handleVisibleChange,
      onClickOutSide: widget.onClickOutSide,
      onEscKeyDown: widget.onEscKeyDown,
      repositionKey: widget.repositionKey,
      zIndex: widget.zIndex,
      showArrow: false,
      popupBare: true,
      child: Semantics(
        button: true,
        expanded: _popVisible,
        child: widget.child,
      ),
    );
  }
}

/// Upstream `numbers.SPACING: 4` in packages/semi-foundation/dropdown/constants.ts.
const double _kSpacing = 4;

/// Upstream `numbers.NESTED_SPACING: 2` (same file).
const double _kNestedSpacing = 2;

/// The `-wrapper` popup surface of `dropdown.scss` (background `bg3`, medium
/// radius and the two `shadow-elevated` layers). Menu mode carries the same
/// decoration inside [_SemiDropdownMenu]; this wrapper serves the custom
/// `content` path, which upstream portals into the same `-wrapper`.
class _DropdownWrapperSurface extends StatelessWidget {
  const _DropdownWrapperSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = SemiDropdownTheme.resolve(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorDropdownBgDefault,
        borderRadius: BorderRadius.circular(theme.radiusDropdown),
        boxShadow: const [
          SemiMenuSurface.shadowElevatedBlur,
          SemiMenuSurface.shadowElevatedDrop,
        ],
      ),
      child: child,
    );
  }
}

/// Mirrors upstream `DropdownContext` (`packages/semi-ui/dropdown/context.ts`):
/// the menu level and the group-level `showTick` are provided around the
/// dropdown's popup body.
class _DropdownScope extends InheritedWidget {
  const _DropdownScope({
    required this.level,
    required this.showTick,
    required super.child,
  });

  /// Nesting level of the content (0 outside a dropdown popup).
  final int level;

  /// Group-level tick flag; null falls back to the item's own `showTick`.
  final bool? showTick;

  static _DropdownScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_DropdownScope>();

  @override
  bool updateShouldNotify(_DropdownScope oldWidget) =>
      level != oldWidget.level || showTick != oldWidget.showTick;
}

/// The menu column (upstream `Dropdown.Menu`/`dropdownMenu.tsx`) with the
/// upstream popup wrapper surface and the single-layer keyboard model.
class _SemiDropdownMenu extends StatefulWidget {
  const _SemiDropdownMenu({required this.nodes, required this.focusOnShow});

  final List<SemiDropdownNode> nodes;

  /// Request focus and highlight the first enabled item on show — upstream
  /// `DropdownFoundation.handleVisibleChange` focuses the first menu item for
  /// the click trigger only.
  final bool focusOnShow;

  @override
  State<_SemiDropdownMenu> createState() => _SemiDropdownMenuState();
}

class _SemiDropdownMenuState extends State<_SemiDropdownMenu> {
  final FocusNode _menuFocus = FocusNode();

  /// Node index of the keyboard-highlighted item (null = nothing highlighted).
  int? _highlight;

  /// Mirrors the browser `:focus-visible` heuristic: the cursor may sit on the
  /// first row after a mouse-opened menu (upstream focuses it), but the
  /// highlight background only becomes visible once the keyboard actually
  /// navigates — so mouse hover feedback is never masked by a permanent fill.
  bool _keyboardUsed = false;

  final Map<int, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    if (widget.focusOnShow) {
      // Upstream `setFocusToFirstMenuItem`: the first enabled row.
      final enabled = _enabledIndices;
      if (enabled.isNotEmpty) _highlight = enabled.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _menuFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _menuFocus.dispose();
    super.dispose();
  }

  /// Enabled item node indices in menu order; disabled rows are skipped by
  /// keyboard navigation (upstream filters `ariaDisabled` `li` nodes).
  List<int> get _enabledIndices => [
    for (var i = 0; i < widget.nodes.length; i++)
      if (widget.nodes[i] case SemiDropdownItemData(disabled: false)) i,
  ];

  /// Position of [_highlight] inside [enabled], or null when nothing usable.
  int? _highlightPosition(List<int> enabled) {
    final highlight = _highlight;
    if (highlight == null) return null;
    final index = enabled.indexOf(highlight);
    return index < 0 ? null : index;
  }

  String? _firstCharOf(SemiDropdownItemData item) {
    final text = semiMenuRowText(item.name);
    if (text == null) return null;
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed[0].toLowerCase();
  }

  /// Upstream `findIndexByCharacter` (`packages/semi-foundation/utils/a11y.ts`):
  /// search after the current item first, then wrap around from the start.
  int? _findByFirstCharacter(List<int> enabled, String char) {
    if (char.length > 1) return null;
    final lower = char.toLowerCase();
    final chars = [
      for (final index in enabled)
        _firstCharOf(widget.nodes[index] as SemiDropdownItemData),
    ];
    var start = (_highlightPosition(enabled) ?? -1) + 1;
    if (start >= enabled.length) start = 0;
    var index = chars.indexOf(lower, start);
    if (index < 0) index = chars.indexOf(lower, 0);
    return index < 0 ? null : index;
  }

  void _moveHighlight(List<int> enabled, int position) {
    setState(() {
      _keyboardUsed = true;
      _highlight = enabled[position];
    });
    _ensureHighlightVisible();
  }

  /// Keyboard highlight scrolls the row into view (upstream `element.focus()`).
  void _ensureHighlightVisible() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = _itemKeys[_highlight]?.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(context, alignment: 0.5);
      }
    });
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    final isDown = event is KeyDownEvent;
    if (!isDown && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final enabled = _enabledIndices;
    if (enabled.isEmpty) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      if (!isDown) return KeyEventResult.handled;
      final position = _highlightPosition(enabled);
      if (position != null) {
        final item = widget.nodes[enabled[position]] as SemiDropdownItemData;
        item.onTap?.call();
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      final position = _highlightPosition(enabled);
      _moveHighlight(
        enabled,
        position == null ? 0 : (position + 1) % enabled.length,
      );
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      final position = _highlightPosition(enabled);
      _moveHighlight(
        enabled,
        position == null
            ? enabled.length - 1
            : (position - 1 + enabled.length) % enabled.length,
      );
      return KeyEventResult.handled;
    }
    // Upstream `isPrintableCharacter` typeahead; Escape is left to the
    // SemiTooltip closeOnEsc handling and keeps propagating.
    if (isDown && event.character != null) {
      final character = event.character!;
      if (character.length == 1 && character.trim().isNotEmpty) {
        final index = _findByFirstCharacter(enabled, character);
        if (index != null) _moveHighlight(enabled, index);
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = SemiDropdownTheme.resolve(context);
    final scope = _DropdownScope.maybeOf(context);
    final children = <Widget>[
      for (final (index, node) in widget.nodes.indexed)
        ...switch (node) {
          SemiDropdownItemData() => [_buildItem(theme, index, node)],
          SemiDropdownTitleData(:final name) => [
            SemiMenuTitleRow(
              theme: theme,
              name: name,
              showTickColumn: scope?.showTick ?? false,
            ),
          ],
          SemiDropdownDividerData() => [SemiMenuDivider(theme: theme)],
          SemiDropdownCheckboxItemData() => [
            _buildCheckboxItem(theme, node),
          ],
          SemiDropdownRadioGroupData() => [
            for (final radio in node.children)
              _buildRadioItem(theme, node, radio),
          ],
          SemiDropdownSubmenuItemData() => [_buildSubmenuItem(theme, node)],
        },
    ];
    return Focus(
      focusNode: _menuFocus,
      onKeyEvent: _handleKey,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        // `role="menu"` cannot be empty (Flutter semantics validation).
        role: widget.nodes.isEmpty ? null : SemanticsRole.menu,
        child: SemiMenuSurface(theme: theme, children: children),
      ),
    );
  }

  Widget _buildItem(
    SemiResolvedDropdownThemeData theme,
    int index,
    SemiDropdownItemData item,
  ) {
    // Upstream `contextShowTick ?? showTick`: the group flag wins.
    final showTick =
        (_DropdownScope.maybeOf(context)?.showTick ?? item.showTick) ?? false;
    return KeyedSubtree(
      key: _itemKeys.putIfAbsent(index, () => GlobalKey()),
      child: SemiMenuRow(
        theme: theme,
        name: item.name,
        icon: item.icon,
        showTickColumn: showTick,
        active: item.active,
        disabled: item.disabled,
        type: item.type,
        role: SemanticsRole.menuItem,
        highlighted: _keyboardUsed && _highlight == index,
        onTap: item.disabled ? null : item.onTap,
      ),
    );
  }

  Widget _buildCheckboxItem(
    SemiResolvedDropdownThemeData theme,
    SemiDropdownCheckboxItemData item,
  ) {
    // Checkable rows always own the tick column (their indicator lives there).
    return SemiMenuRow(
      theme: theme,
      name: item.name,
      icon: item.icon,
      showTickColumn: true,
      indicator: item.indeterminate
          ? SemiMenuIndicator.indeterminate
          : item.checked
          ? SemiMenuIndicator.tick
          : SemiMenuIndicator.none,
      disabled: item.disabled,
      type: item.type,
      role: SemanticsRole.menuItemCheckbox,
      checked: item.indeterminate ? null : item.checked,
      mixed: item.indeterminate ? true : null,
      onTap: item.disabled
          ? null
          : () => item.onCheckedChange?.call(
              item.indeterminate ? true : !item.checked,
            ),
    );
  }

  Widget _buildRadioItem(
    SemiResolvedDropdownThemeData theme,
    SemiDropdownRadioGroupData group,
    SemiDropdownRadioItemData radio,
  ) {
    final checked = radio.value == group.value;
    return SemiMenuRow(
      theme: theme,
      name: radio.name,
      icon: radio.icon,
      showTickColumn: true,
      indicator: checked ? SemiMenuIndicator.tick : SemiMenuIndicator.none,
      disabled: radio.disabled,
      type: radio.type,
      role: SemanticsRole.menuItemRadio,
      checked: checked,
      onTap: radio.disabled
          ? null
          : () => group.onValueChange?.call(radio.value),
    );
  }

  /// Submenu rows open a nested [SemiDropdown] beside the row (composition of
  /// the existing nested-dropdown machinery; the full keyboard model lives in
  /// `SemiContextMenu`).
  Widget _buildSubmenuItem(
    SemiResolvedDropdownThemeData theme,
    SemiDropdownSubmenuItemData item,
  ) {
    final scope = _DropdownScope.maybeOf(context);
    final showTick = (scope?.showTick ?? item.showTick) ?? false;
    final rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    return SemiDropdown(
      trigger: SemiTooltipTrigger.hover,
      position: rtl ? SemiTooltipPosition.leftTop : SemiTooltipPosition.rightTop,
      showTick: scope?.showTick,
      menu: item.children,
      child: SemiMenuRow(
        theme: theme,
        name: item.name,
        icon: item.icon,
        showTickColumn: showTick,
        disabled: item.disabled,
        type: item.type,
        role: SemanticsRole.menuItem,
        trailingIcon: rtl ? SemiIcons.chevronLeft : SemiIcons.chevronRight,
      ),
    );
  }
}

/// The 10 hardcoded Sass values kept out of the theme: the `backdrop-filter`
/// declaration, the wrapper opacity states, the two shadow-elevated layers,
/// the `$z-dropdown` usage, the type-size mixins, the icon wrapper gap and
/// the wrapper scroll. See docs/semi_dropdown.md for the full mapping.
// ignore: unused_element
abstract final class _DropdownMetrics {
  /// `$filter-dropdown-bg: none` in packages/semi-foundation/dropdown/variables.scss.
  /// Upstream `backdrop-filter` value is `none`, so no filter is applied.
  // ignore: unused_field
  static const String filterBg = 'none';

  /// `opacity: 0` in packages/semi-foundation/dropdown/dropdown.scss
  /// (`&-wrapper`). Hidden until positioned; the port animates opacity
  /// through SemiTooltip's FadeTransition instead.
  // ignore: unused_field
  static const double wrapperOpacityHidden = 0;

  /// `opacity: 1` in packages/semi-foundation/dropdown/dropdown.scss
  /// (`&-wrapper-show`). Shown state of the same rule.
  // ignore: unused_field
  static const double wrapperOpacityShown = 1;

  /// `0 0 1px rgba(0, 0, 0, .3)` — first box-shadow layer of the
  /// `@include shadow-elevated` mixin
  /// (packages/semi-theme-default/scss/global.scss). Hardcoded to the light
  /// token values (see docs/semi_dropdown.md). Lives in [SemiMenuSurface] as
  /// the shared menu surface constant.
  static const BoxShadow shadowElevatedBlur = SemiMenuSurface.shadowElevatedBlur;

  /// `0 4px 14px rgba(0, 0, 0, .1)` — second box-shadow layer of the same
  /// `@include shadow-elevated` mixin (see [SemiMenuSurface]).
  static const BoxShadow shadowElevatedDrop =
      SemiMenuSurface.shadowElevatedDrop;

  /// `z-index: $z-dropdown` in packages/semi-foundation/dropdown/dropdown.scss,
  /// with `$z-dropdown: 1050` in packages/semi-theme-default/scss/variables.scss.
  /// Used as [SemiDropdown.zIndex] default; overlay insertion order decides
  /// stacking at runtime.
  static const int zIndex = 1050;

  /// `@include font-size-regular` in packages/semi-foundation/dropdown/dropdown.scss
  /// (`.#{$module}`). The port reads the live `typography.fontSizeRegular`
  /// token (14 by default); the mixin provenance is recorded here.
  // ignore: unused_field
  static const double menuBaseFontSize = 14;

  /// `@include font-size-small` in packages/semi-foundation/dropdown/dropdown.scss
  /// (`&-title`). The port reads the live `typography.fontSizeSmall` token
  /// (12 by default); the mixin provenance is recorded here.
  // ignore: unused_field
  static const double titleBaseFontSize = 12;

  /// `margin-right: $spacing-tight` in packages/semi-foundation/dropdown/dropdown.scss
  /// (`&-item-icon`, the icon prop wrapper). The port routes every icon gap
  /// through `spacingDropdownIconMarginRight` (9) instead (see docs).
  // ignore: unused_field
  static const double iconWrapperMarginRight = 8;

  /// `overflow-y: auto` in packages/semi-foundation/dropdown/dropdown.scss
  /// (`&-wrapper`, "prevent flow out of the radius limit area"). Rendered as
  /// the menu `SingleChildScrollView`.
  // ignore: unused_field
  static const String overflowY = 'auto';
}
