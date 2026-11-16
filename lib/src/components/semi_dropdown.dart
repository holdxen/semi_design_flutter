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
import 'semi_tooltip.dart';
import 'typography/semi_text.dart';

/// Upstream `strings.ITEM_TYPE` (`packages/semi-foundation/dropdown/constants.ts`).
/// There is no default tier upstream: a null [SemiDropdownItemData.type] uses
/// `colorDropdownItemTextDefault` (see docs/semi_dropdown.md).
enum SemiDropdownItemType { primary, secondary, tertiary, warning, danger }

/// One entry of a [SemiDropdown.menu] (upstream `DropDownMenuItem`).
sealed class SemiDropdownNode {
  const SemiDropdownNode();
}

/// A menu row (upstream `Dropdown.Item`/`dropdownItem.tsx`).
class SemiDropdownItemData extends SemiDropdownNode {
  const SemiDropdownItemData({
    this.name,
    this.icon,
    this.active = false,
    this.disabled = false,
    this.type,
    this.onTap,
    this.showTick,
  }) : assert(
         name == null || name is String || name is Widget,
         'name must be a String or a Widget',
       );

  /// Label: [String] (rendered as [SemiText]) or [Widget] placed as-is.
  final Object? name;

  /// Leading icon content; laid out at `sizeDropdownIconWidth`×
  /// `sizeDropdownIconHeight` with `spacingDropdownIconMarginRight` gap.
  final Widget? icon;

  /// Bold checked row (upstream `active`): weight
  /// `fontDropdownItemActiveFontWeight`; only `active` rows render the tick
  /// and skip the hover/pressed fills (upstream `:not(.item-active)` rules).
  final bool active;

  /// No interaction, disabled colors (upstream `disabled`).
  final bool disabled;

  /// Text color tier; null keeps `colorDropdownItemTextDefault`.
  final SemiDropdownItemType? type;

  /// Row activation (upstream `onClick`).
  final VoidCallback? onTap;

  /// Per-item tick override; the group-level [SemiDropdown.showTick] wins when
  /// non-null (upstream `contextShowTick ?? showTick`).
  final bool? showTick;
}

/// A group heading (upstream `Dropdown.Title`/`dropdownTitle.tsx`).
class SemiDropdownTitleData extends SemiDropdownNode {
  const SemiDropdownTitleData(this.name)
    : assert(
        name == null || name is String || name is Widget,
        'name must be a String or a Widget',
      );

  /// Heading label: [String] (rendered as [SemiText]) or [Widget] as-is.
  final Object? name;
}

/// A 1px separator (upstream `Dropdown.Divider`/`dropdownDivider.tsx`).
class SemiDropdownDividerData extends SemiDropdownNode {
  const SemiDropdownDividerData();
}

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
          _DropdownMetrics.shadowElevatedBlur,
          _DropdownMetrics.shadowElevatedDrop,
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
    final String? text = switch (item.name) {
      String s => s,
      Text t => t.data,
      SemiText t => t.data,
      _ => null,
    };
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
        switch (node) {
          SemiDropdownItemData() => _buildItem(index, node),
          SemiDropdownTitleData(:final name) => _buildTitle(
            theme,
            scope?.showTick ?? false,
            name,
          ),
          SemiDropdownDividerData() => _buildDivider(theme),
        },
    ];
    // Upstream `&-menu`: `padding: $spacing-dropdown_menu-paddingY $spacing-dropdown_menu-paddingX`.
    final menu = Padding(
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorDropdownBgDefault,
        borderRadius: BorderRadius.circular(theme.radiusDropdown),
        boxShadow: const [
          _DropdownMetrics.shadowElevatedBlur,
          _DropdownMetrics.shadowElevatedDrop,
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.radiusDropdown),
        // `overflow-y: auto` on the upstream wrapper.
        child: SingleChildScrollView(
          child: Focus(
            focusNode: _menuFocus,
            onKeyEvent: _handleKey,
            child: Semantics(
              container: true,
              explicitChildNodes: true,
              // `role="menu"` cannot be empty (Flutter semantics validation).
              role: widget.nodes.isEmpty ? null : SemanticsRole.menu,
              child: menu,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int index, SemiDropdownItemData item) {
    // Upstream `contextShowTick ?? showTick`: the group flag wins.
    final showTick =
        (_DropdownScope.maybeOf(context)?.showTick ?? item.showTick) ?? false;
    return KeyedSubtree(
      key: _itemKeys.putIfAbsent(index, () => GlobalKey()),
      child: _DropdownItemView(
        item: item,
        showTick: showTick,
        highlighted: _keyboardUsed && _highlight == index,
        onTap: item.disabled ? null : item.onTap,
      ),
    );
  }

  Widget _buildTitle(
    SemiResolvedDropdownThemeData theme,
    bool showTick,
    Object? name,
  ) {
    // Upstream `dropdownTitle.tsx` reads only the context `showTick`.
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
        start: showTick
            ? theme.spacingDropdownTitleWithTickPaddingLeft
            : theme.spacingDropdownTitlePaddingLeft,
        end: theme.spacingDropdownTitlePaddingRight,
      ),
      child: label,
    );
  }

  Widget _buildDivider(SemiResolvedDropdownThemeData theme) {
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

/// One menu row: tick column, optional icon and the label (upstream
/// `dropdownItem.tsx` + the `&-item` rules of dropdown.scss).
class _DropdownItemView extends StatefulWidget {
  const _DropdownItemView({
    required this.item,
    required this.showTick,
    required this.highlighted,
    required this.onTap,
  });

  final SemiDropdownItemData item;

  /// Resolved tick flag: the group-level `showTick` wins over the item's own
  /// (upstream `contextShowTick ?? showTick`).
  final bool showTick;

  final bool highlighted;

  /// Null when disabled (upstream drops all events on disabled rows).
  final VoidCallback? onTap;

  @override
  State<_DropdownItemView> createState() => _DropdownItemViewState();
}

class _DropdownItemViewState extends State<_DropdownItemView> {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = SemiDropdownTheme.resolve(context);
    final item = widget.item;
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
    } else if (_hovering || widget.highlighted) {
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
    Widget box = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.showTick)
          _iconSlot(
            theme,
            SemiIconTheme(
              data: SemiIconThemeData(
                color: item.active ? textColor : const Color(0x00000000),
                customSize: theme.sizeDropdownIconWidth,
              ),
              child: const ExcludeSemantics(
                child: SemiIcon(SemiIcons.tick, excludeFromSemantics: true),
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
      ],
    );
    box = Padding(
      padding: EdgeInsetsDirectional.only(
        top: theme.spacingDropdownItemPaddingY,
        bottom: theme.spacingDropdownItemPaddingY,
        start: widget.showTick
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
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
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
      role: SemanticsRole.menuItem,
      enabled: !item.disabled,
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
