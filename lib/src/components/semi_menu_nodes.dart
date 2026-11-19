import 'package:flutter/widgets.dart';

/// Upstream `strings.ITEM_TYPE` (`packages/semi-foundation/dropdown/constants.ts`).
/// There is no default tier upstream: a null [SemiDropdownItemData.type] uses
/// `colorDropdownItemTextDefault` (see docs/semi_dropdown.md).
enum SemiDropdownItemType { primary, secondary, tertiary, warning, danger }

/// One entry of a [SemiDropdown.menu] / `SemiContextMenu.nodes`
/// (upstream `DropDownMenuItem`).
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

/// A checkable menu row (Radix `ContextmenuCheckboxItem`, ported for
/// `SemiContextMenu`; Semi upstream has no checkable dropdown rows).
class SemiDropdownCheckboxItemData extends SemiDropdownNode {
  const SemiDropdownCheckboxItemData({
    this.name,
    this.icon,
    this.checked = false,
    this.indeterminate = false,
    this.disabled = false,
    this.type,
    this.onCheckedChange,
  }) : assert(
         name == null || name is String || name is Widget,
         'name must be a String or a Widget',
       );

  /// Label: [String] (rendered as [SemiText]) or [Widget] placed as-is.
  final Object? name;

  /// Leading icon content (same slot as [SemiDropdownItemData.icon]).
  final Widget? icon;

  /// Checked state; the tick column renders when true
  /// (or when [indeterminate] is true).
  final bool checked;

  /// Indeterminate mark (Radix `checked="indeterminate"`); renders the minus
  /// glyph instead of the tick. Activation always reports `true`
  /// (Radix never passes `indeterminate` to `onCheckedChange`).
  final bool indeterminate;

  /// No interaction, disabled colors.
  final bool disabled;

  /// Text color tier; null keeps `colorDropdownItemTextDefault`.
  final SemiDropdownItemType? type;

  /// Toggled on activation (Radix `onCheckedChange`).
  final ValueChanged<bool>? onCheckedChange;
}

/// A radio group wrapper (Radix `ContextMenuRadioGroup`): supplies the
/// selection value to its [SemiDropdownRadioItemData] children.
class SemiDropdownRadioGroupData extends SemiDropdownNode {
  const SemiDropdownRadioGroupData({
    required this.children,
    this.value,
    this.onValueChange,
  });

  /// The radio rows of this group.
  final List<SemiDropdownRadioItemData> children;

  /// Selected value; the child whose [SemiDropdownRadioItemData.value]
  /// matches renders its tick.
  final String? value;

  /// Reports the newly selected value (Radix `onValueChange`).
  final ValueChanged<String>? onValueChange;
}

/// A radio row inside a [SemiDropdownRadioGroupData]
/// (Radix `ContextMenuRadioItem`).
class SemiDropdownRadioItemData {
  const SemiDropdownRadioItemData({
    required this.value,
    this.name,
    this.icon,
    this.disabled = false,
    this.type,
  }) : assert(
         name == null || name is String || name is Widget,
         'name must be a String or a Widget',
       );

  /// The value reported to [SemiDropdownRadioGroupData.onValueChange].
  final String value;

  /// Label: [String] (rendered as [SemiText]) or [Widget] placed as-is.
  final Object? name;

  /// Leading icon content (same slot as [SemiDropdownItemData.icon]).
  final Widget? icon;

  /// No interaction, disabled colors.
  final bool disabled;

  /// Text color tier; null keeps `colorDropdownItemTextDefault`.
  final SemiDropdownItemType? type;
}

/// A submenu trigger row (Radix `ContextMenuSubTrigger` + `SubContent`):
/// hovering or activating opens the nested [children] menu beside the row.
class SemiDropdownSubmenuItemData extends SemiDropdownNode {
  const SemiDropdownSubmenuItemData({
    required this.children,
    this.name,
    this.icon,
    this.disabled = false,
    this.type,
    this.showTick,
  }) : assert(
         name == null || name is String || name is Widget,
         'name must be a String or a Widget',
       );

  /// Nested menu nodes (items/titles/dividers/checkboxes/radio
  /// groups/submenus).
  final List<SemiDropdownNode> children;

  /// Label: [String] (rendered as [SemiText]) or [Widget] placed as-is.
  final Object? name;

  /// Leading icon content (same slot as [SemiDropdownItemData.icon]).
  final Widget? icon;

  /// No interaction, disabled colors.
  final bool disabled;

  /// Text color tier; null keeps `colorDropdownItemTextDefault`.
  final SemiDropdownItemType? type;

  /// Per-item tick override (same resolution as
  /// [SemiDropdownItemData.showTick]).
  final bool? showTick;
}
