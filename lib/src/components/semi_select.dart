import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart' show RenderProxyBox;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../overlay/tooltip_positioning.dart';
import '../theme/semi_icon_theme.dart';
import '../theme/semi_select_theme.dart';
import '../theme/semi_select_theme_data.dart';
import '../theme/semi_theme.dart';
import '../theme/semi_theme_data.dart';
import 'highlight_algorithm.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icons.dart';
import 'semi_highlight.dart';
import 'semi_input.dart';
import 'semi_spin.dart';
import 'semi_tag.dart';
import 'semi_tooltip.dart';

/// Where the search input lives (upstream `searchPosition`: `trigger` renders
/// it inside the trigger, `dropdown` inside the panel).
enum SemiSelectSearchPosition { trigger, dropdown }

/// One candidate of a [SemiSelect] (upstream `OptionProps`).
///
/// Port difference: the upstream selects are keyed by `label`; this port keys
/// by [value] (see docs/semi_select.md).
class SemiSelectOption {
  const SemiSelectOption({
    required this.value,
    this.label,
    this.disabled = false,
    this.showTick = true,
  });

  /// Selection key (upstream `value`; the upstream selection map keys on
  /// `label` instead — see the difference list).
  final Object value;

  /// Panel/tag content: [String] or [Widget]; null renders `value.toString()`
  /// (upstream `label`).
  final Object? label;

  /// No interaction and disabled colors (upstream `disabled`).
  final bool disabled;

  /// Whether the selected-state tick column renders for this row (the port's
  /// per-option `showTick`; upstream `Option` always renders its tick slot).
  final bool showTick;

  /// The plain text of this option ([label] when it is a [String], otherwise
  /// `value.toString()`), used for filtering and keyword highlighting
  /// (upstream `option.label.toString()`).
  String get plainText => label is String ? label as String : value.toString();
}

/// A labeled run of options (upstream `OptionGroup`/`optionGroup.tsx`).
class SemiSelectGroup {
  const SemiSelectGroup({this.label, required this.options});

  /// Group heading: [String] or [Widget]; participates in the default filter
  /// when it is a [String] (upstream `_filterOption` group matching).
  final Object? label;

  final List<SemiSelectOption> options;
}

/// The `allowCreate` pseudo option appended while the search input has no
/// exact label match (upstream `{_inputCreateOnly: true}` option).
class _CreateOption extends SemiSelectOption {
  _CreateOption(String input) : super(value: input);
}

/// Imperative handle for a [SemiSelect] (upstream ref methods; the attach
/// pattern mirrors [SemiPinCodeController]).
class SemiSelectController {
  _SemiSelectState? _state;

  /// Opens the panel (upstream `open()`).
  void open() => _state?._openPanel();

  /// Closes the panel (upstream `close()`).
  void close() => _state?._closePanel();

  /// Focuses the select: the search input when filtering, the trigger
  /// otherwise (upstream `focus()` without the open-dropdown side effect —
  /// see docs/semi_select.md).
  void focus() => _state?._focusTrigger();

  /// Clears the search input text (upstream `clearInput()`).
  void clearInput() => _state?._clearInput();

  /// Selects every option (multiple mode only; upstream `selectAll()`).
  void selectAll() => _state?._selectAll();

  /// Deselects every selection (multiple mode; the single mode clears its one
  /// selection like the clear button).
  void deselectAll() => _state?._deselectAll();

  /// Types into the search input programmatically (upstream `handleInputChange`
  /// through the ref surface).
  void search(String value) => _state?._searchFromController(value);

  void _attach(_SemiSelectState state) {
    _state = state;
  }

  void _detach(_SemiSelectState state) {
    if (identical(_state, state)) _state = null;
  }
}

/// A source-sized, non-Material select (upstream Semi Select) built on
/// [SemiInput], [SemiTag] and [SemiTooltip].
///
/// Port notes (see docs/semi_select.md for the full difference list):
/// * [value]/[defaultValue] carry the selection itself: `Object?` for the
///   single mode and `List<Object>` for the multiple mode ([multiple]); a
///   non-null [value] is controlled (the SemiInput convention) and releases
///   keep the last value.
/// * Selections key on [SemiSelectOption.value] (upstream keys on `label`) and
///   [onChanged] carries the plain value (or the value list) — the upstream
///   `onChangeWithObject` switch is not ported.
/// * The panel skeleton, the pointer-based trigger toggle and the keyboard
///   model follow semi_autocomplete.dart; the option rows follow
///   semi_dropdown.dart.
class SemiSelect extends StatefulWidget {
  const SemiSelect({
    super.key,
    this.value,
    this.defaultValue,
    this.multiple = false,
    this.max,
    this.allowCreate = false,
    this.options = const [],
    this.groups = const [],
    this.filter = false,
    this.remote = false,
    this.autoClearSearchValue = true,
    this.searchPosition = SemiSelectSearchPosition.trigger,
    this.searchPlaceholder,
    this.placeholder,
    this.size = SemiInputSize.normal,
    this.disabled = false,
    this.showClear = false,
    this.showArrow = true,
    this.clearIcon,
    this.arrowIcon,
    this.borderless = false,
    this.validateStatus = SemiInputStatus.normal,
    this.prefix,
    this.insetLabel,
    this.suffix,
    this.renderSelectedItem,
    this.renderOptionItem,
    this.renderCreateItem,
    this.maxTagCount,
    this.showRestTagsPopover = false,
    this.restTagsPopoverPosition = SemiTooltipPosition.top,
    this.expandRestTagsOnClick = false,
    this.loading = false,
    this.emptyContent,
    this.maxHeight = _SelectMetrics.listHeight,
    this.dropdownMatchSelectWidth = true,
    this.position = SemiTooltipPosition.bottomLeft,
    this.defaultOpen = false,
    this.clickToHide = false,
    this.defaultActiveFirstOption = true,
    this.outerTopSlot,
    this.innerTopSlot,
    this.outerBottomSlot,
    this.innerBottomSlot,
    this.onChanged,
    this.onSelect,
    this.onDeselect,
    this.onSearch,
    this.onDropdownVisibleChange,
    this.onClear,
    this.onExceed,
    this.onCreate,
    this.onFocusChange,
    this.onBlur,
    this.autofocus = false,
    this.controller,
  }) : assert(
         filter == true ||
             filter == false ||
             filter is bool Function(String, SemiSelectOption),
         'filter must be a bool or bool Function(String, SemiSelectOption)',
       );

  /// Key of the clear button slot.
  static const Key clearButtonKey = Key('SemiSelect.clearButton');

  /// Non-null makes the select controlled (the SemiInput convention): the
  /// displayed selection follows this value and interactions only emit
  /// callbacks. `Object?` in the single mode, `List<Object>` in the multiple
  /// mode (upstream `value`).
  final Object? value;

  /// Seed of the uncontrolled selection; same shape as [value] (upstream
  /// `defaultValue`).
  final Object? defaultValue;

  /// Multiple selection: toggle semantics, tags and no auto-close (upstream
  /// `multiple`).
  final bool multiple;

  /// Maximum number of selections in the multiple mode; exceeding calls
  /// [onExceed] and refuses the pick (upstream `max`).
  final int? max;

  /// Appends a "create" row while the search input has no exact label match;
  /// selecting it fires [onCreate]. Upstream `allowCreate`: while enabled the
  /// port stops re-reading [options]/[groups] on updates, mirroring the
  /// upstream option caching.
  final bool allowCreate;

  /// Flat candidates (upstream `options`/`optionList`); rendered before
  /// [groups] — a port difference from the upstream JSX child order.
  final List<SemiSelectOption> options;

  /// Grouped candidates (upstream `OptionGroup` children).
  final List<SemiSelectGroup> groups;

  /// `false` (default) — no filtering; `true` — case-insensitive label and
  /// group-label substring match (upstream `_filterOption`); a
  /// `bool Function(String, SemiSelectOption)` predicate for custom filtering
  /// (upstream `filter`).
  final Object filter;

  /// Never filter locally; [onSearch] fires and the caller refreshes [options]
  /// (upstream `remote`).
  final bool remote;

  /// Clears the search input after a multiple-mode pick restores the full
  /// list (upstream `autoClearSearchValue`, default true).
  final bool autoClearSearchValue;

  /// Search input placement (upstream `searchPosition`).
  final SemiSelectSearchPosition searchPosition;

  /// Placeholder of the [SemiSelectSearchPosition.dropdown] search input
  /// (upstream `searchPlaceholder`).
  final String? searchPlaceholder;

  /// Placeholder text with no selection and no search text (upstream
  /// `placeholder`).
  final String? placeholder;

  final SemiInputSize size;
  final bool disabled;

  /// Shows the clear button when there is a selection or search text (upstream
  /// `showClear`).
  final bool showClear;

  /// Renders the arrow slot (upstream `showArrow`).
  final bool showArrow;

  /// Custom clear icon (defaults to `SemiIcons.clear`).
  final Widget? clearIcon;

  /// Custom arrow icon (defaults to `SemiIcons.chevronDown`).
  final Widget? arrowIcon;

  /// Resting state paints no background and no border (upstream `borderless`).
  final bool borderless;

  final SemiInputStatus validateStatus;

  /// String or Widget before the selection area (upstream `prefix`).
  final Object? prefix;

  /// String or Widget between prefix and selection (upstream `insetLabel`).
  final Object? insetLabel;

  /// String or Widget after the selection area (upstream `suffix`).
  final Object? suffix;

  /// Custom selection renderer. Single mode: `Widget Function(SemiSelectOption)`;
  /// multiple mode: `Widget Function(SemiSelectOption, {int index, bool
  /// disabled, VoidCallback onClose})`. Null renders the label text (single)
  /// or closable [SemiTag]s (multiple). Port difference: the upstream
  /// `isRenderInTag` switch is flattened — multiple-mode results render
  /// as-is (outside a [SemiTag]) and wire [onClose] themselves.
  final Object? renderSelectedItem;

  /// Replaces the panel content of an option
  /// (`Widget Function(SemiSelectOption, {bool selected, bool focused, String
  /// inputValue, VoidCallback onHover, VoidCallback onTap})`; upstream
  /// `renderOptionItem`).
  final Object? renderOptionItem;

  /// Replaces the "create" row content (`Widget Function(String inputValue)`;
  /// upstream `renderCreateItem`).
  final Object? renderCreateItem;

  /// Folds the multiple-mode tags to the first [maxTagCount] plus a grey
  /// "+N" tag while collapsed (upstream `maxTagCount`).
  final int? maxTagCount;

  /// Shows the folded-away tags in a hovering tooltip on the "+N" tag
  /// (upstream `showRestTagsPopover`).
  final bool showRestTagsPopover;

  /// Placement of the rest-tags tooltip (upstream `restTagsPopoverPosition`).
  final SemiTooltipPosition restTagsPopoverPosition;

  /// Expands the folded tags whenever the panel opens (upstream
  /// `expandRestTagsOnClick`).
  final bool expandRestTagsOnClick;

  /// Replaces the option list with a [SemiSpin] loading row (upstream
  /// `loading`).
  final bool loading;

  /// Body when no option is visible; null renders an empty panel (upstream
  /// `emptyContent`).
  final Widget? emptyContent;

  /// Panel height cap in logical pixels (upstream `numbers.LIST_HEIGHT`,
  /// 270).
  final double maxHeight;

  /// Panel `minWidth` equals the measured trigger width when true (upstream
  /// `dropdownMatchSelectWidth`).
  final bool dropdownMatchSelectWidth;

  /// Preferred placement (upstream `position`, default `bottomLeft`).
  final SemiTooltipPosition position;

  /// Opens the panel on mount (upstream `defaultOpen`).
  final bool defaultOpen;

  /// Tapping the open trigger closes it (upstream `clickToHide`).
  final bool clickToHide;

  /// Focuses the first row whenever the panel opens (upstream
  /// `defaultActiveFirstOption`, default true).
  final bool defaultActiveFirstOption;

  /// Panel slots, top to bottom: [outerTopSlot] above the dropdown search
  /// input, then the scrollable list ([innerTopSlot], options,
  /// [innerBottomSlot]), then [outerBottomSlot] (upstream `outerTopSlot` /
  /// `innerTopSlot` / `outerBottomSlot` / `innerBottomSlot`).
  final Widget? outerTopSlot;
  final Widget? innerTopSlot;
  final Widget? outerBottomSlot;
  final Widget? innerBottomSlot;

  /// Reports the new selection after a diff gate (same value never fires):
  /// `Object?` in the single mode (null after a clear) and `List<Object>` in
  /// the multiple mode (upstream `onChange`).
  final ValueChanged<Object?>? onChanged;

  /// Fires before [onChanged] with `(value, option)` on a pick (upstream
  /// `onSelect`).
  final void Function(Object value, SemiSelectOption option)? onSelect;

  /// Fires before [onChanged] with `(value, option)` on a removal (upstream
  /// `onDeselect`).
  final void Function(Object value, SemiSelectOption option)? onDeselect;

  /// Fires on every search edit (and with `''` when the search resets)
  /// (upstream `onSearch`).
  final ValueChanged<String>? onSearch;

  /// Reports panel open/close changes (upstream `onDropdownVisibleChange`).
  final ValueChanged<bool>? onDropdownVisibleChange;

  /// Fires after the clear button clears the selection (upstream `onClear`).
  final VoidCallback? onClear;

  /// Fires when a pick exceeds [max] (upstream `onExceed`).
  final ValueChanged<SemiSelectOption>? onExceed;

  /// Fires when the `allowCreate` row is picked (upstream `onCreate`).
  final ValueChanged<SemiSelectOption>? onCreate;

  final ValueChanged<bool>? onFocusChange;

  /// Fires when focus leaves the select (upstream `onBlur`; the port reports
  /// real focus loss only — see docs/semi_select.md).
  final VoidCallback? onBlur;

  /// Focuses the select on mount; the filterable mode also opens the panel
  /// (upstream `autoFocus` -> `focus()` opens).
  final bool autofocus;

  /// External controller; never disposed by the widget.
  final SemiSelectController? controller;

  @override
  State<SemiSelect> createState() => _SemiSelectState();
}

class _SemiSelectState extends State<SemiSelect> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode(debugLabel: 'SemiSelect.input');
  final FocusNode _triggerFocusNode = FocusNode(debugLabel: 'SemiSelect');

  /// Panel visibility (upstream `isOpen`).
  bool _open = false;

  /// Index into the visible option rows of the keyboard/hover highlight;
  /// -1 when nothing is highlighted (upstream `focusIndex`).
  int _focusIndex = -1;

  /// The selection display in the upstream insertion order (upstream
  /// `selections` Map keyed by label; the port keys by value).
  List<SemiSelectOption> _selections = [];

  /// The search input text (upstream `inputValue`).
  String _inputValue = '';

  /// Single + filterable trigger: the search input replaces the label
  /// (upstream `showInput`).
  bool _showInput = false;

  /// Snapshot of [SemiSelect.options] + [SemiSelect.groups]; never refreshed
  /// while [SemiSelect.allowCreate] is on (upstream option caching).
  List<SemiSelectOption> _allOptions = [];
  final List<SemiSelectGroup> _groups = [];
  final Map<SemiSelectOption, SemiSelectGroup?> _optionGroup = {};

  /// Trigger width recorded when the panel opens (upstream
  /// `setOptionWrapperWidth`/`dropdownMinWidth`).
  double? _panelMinWidth;

  /// Bumped when the data changes so the panel repositions (upstream
  /// `rePosKey`).
  int _repositionKey = 0;

  bool _hovering = false;
  bool _pressed = false;

  final GlobalKey _triggerKey = GlobalKey();
  final Map<int, GlobalKey> _optionKeys = {};

  bool get _isControlled => widget.value != null;
  bool get _isFilterable =>
      widget.filter != false || (widget.filter is Function);
  bool get _isSearchInDropdown =>
      _isFilterable &&
      widget.searchPosition == SemiSelectSearchPosition.dropdown;

  @override
  void initState() {
    super.initState();
    _collectOptions();
    _syncSelections();
    widget.controller?._attach(this);
    if (widget.defaultOpen) {
      _open = true;
      _resetFocusIndex();
      // Upstream `open()` with `filter` shows the trigger search input.
      if (_isFilterable && !_isSearchInDropdown && !widget.multiple) {
        _showInput = true;
      }
      // Upstream init() notifies through open(); deferred past the first
      // build so a notifying parent cannot setState during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(_recordPanelWidth);
        if (_open) widget.onDropdownVisibleChange?.call(true);
        if (_isFilterable && !_isSearchInDropdown) _focusInput();
      });
    }
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_isFilterable) {
          _openPanel();
        } else {
          _triggerFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void didUpdateWidget(SemiSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
    if (!widget.allowCreate &&
        (!listEquals(oldWidget.options, widget.options) ||
            !listEquals(oldWidget.groups, widget.groups))) {
      _collectOptions();
      _syncSelections(previous: _selections);
      _repositionKey += 1;
      setState(_resetFocusIndex);
    }
    if (_isControlled && widget.value != oldWidget.value) {
      setState(() => _syncSelections(previous: _selections));
      _repositionKey += 1;
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _triggerFocusNode.dispose();
    _inputFocusNode.dispose();
    _inputController.dispose();
    super.dispose();
  }

  // -- options / selections (upstream _collectOptions / _update) --------------

  void _collectOptions() {
    _allOptions = [
      ...widget.options,
      for (final group in widget.groups) ...group.options,
    ];
    _optionGroup.clear();
    for (final option in widget.options) {
      _optionGroup[option] = null;
    }
    for (final group in widget.groups) {
      for (final option in group.options) {
        _optionGroup[option] = group;
      }
    }
    if (!listEquals(_groups, widget.groups)) {
      _groups
        ..clear()
        ..addAll(widget.groups);
    }
  }

  /// Resolves one value into a selection entry: the matching option, the
  /// previous entry, or a placeholder (`{_notExist}` upstream) that only lives
  /// in the selection, never in the list.
  SemiSelectOption _entryFor(Object value, List<SemiSelectOption>? previous) {
    for (final option in _allOptions) {
      if (option.value == value) return option;
    }
    if (previous != null) {
      for (final option in previous) {
        if (option.value == value) return option;
      }
    }
    return SemiSelectOption(value: value);
  }

  /// Upstream `_update`/`_updateSingle`/`_updateMultiple`: rebuild the
  /// selection from the value (controlled) or the default (uncontrolled);
  /// releases keep the sticky entries.
  void _syncSelections({List<SemiSelectOption>? previous}) {
    final Object? raw = _isControlled ? widget.value : widget.defaultValue;
    if (widget.multiple) {
      final List<Object> values;
      if (raw == null) {
        values = const [];
      } else if (raw is List) {
        values = [for (final value in raw) value as Object];
      } else {
        values = [raw];
      }
      _selections = [for (final value in values) _entryFor(value, previous)];
    } else {
      _selections = raw == null ? [] : [_entryFor(raw, previous)];
    }
  }

  List<Object> _valuesOf(List<SemiSelectOption> selections) => [
    for (final selection in selections) selection.value,
  ];

  /// Upstream `_diffSelections`: same value (and label, single mode) never
  /// notifies.
  bool _diffSingle(SemiSelectOption? next) {
    final current = _selections.isEmpty ? null : _selections.first;
    if (current == null || next == null) {
      return current != next;
    }
    return current.value != next.value || current.plainText != next.plainText;
  }

  bool _diffMultiple(List<SemiSelectOption> next) =>
      !listEquals(_valuesOf(_selections), _valuesOf(next));

  void _notifySingle(SemiSelectOption? next) {
    if (!_diffSingle(next)) return;
    widget.onChanged?.call(next?.value);
  }

  // -- visible rows (upstream _filterOption / _createOptionByInput) ----------

  bool _matches(SemiSelectOption option) {
    if (widget.remote) return true;
    final filter = widget.filter;
    if (filter == false) return true;
    if (filter == true) {
      final input = _inputValue.toLowerCase();
      if (option.plainText.toLowerCase().contains(input)) return true;
      final groupLabel = _optionGroup[option]?.label;
      return groupLabel is String && groupLabel.toLowerCase().contains(input);
    }
    return (filter as bool Function(String, SemiSelectOption))(
      _inputValue,
      option,
    );
  }

  /// Visible options in list order (upstream `options.filter(_show)`; group
  /// headers follow their first visible member).
  List<SemiSelectOption> get _visibleOptions {
    final visible = [
      for (final option in _allOptions)
        if (_matches(option)) option,
    ];
    if (widget.allowCreate && _inputValue.isNotEmpty) {
      // Upstream `_createOptionByInput`: an exact label match suppresses the
      // create row (matching only considers visible options).
      final exact = visible.any((option) => option.plainText == _inputValue);
      if (!exact) return [...visible, _CreateOption(_inputValue)];
    }
    return visible;
  }

  bool _isCreateOption(SemiSelectOption option) => option is _CreateOption;

  // -- panel open/close ------------------------------------------------------

  void _recordPanelWidth() {
    if (!widget.dropdownMatchSelectWidth) return;
    final box = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) _panelMinWidth = box.size.width;
  }

  void _openPanel() {
    if (_open || widget.disabled) return;
    setState(() {
      _open = true;
      _resetFocusIndex();
    });
    _recordPanelWidth();
    if (_isFilterable && !_isSearchInDropdown) {
      // Upstream `toggle2SearchInput(true)`: show and focus the trigger
      // search input (the multiple mode keeps it inline permanently).
      if (!widget.multiple) _showInput = true;
      _focusInput();
    } else {
      // Upstream `handleClick` focuses the trigger so the keyboard works.
      _triggerFocusNode.requestFocus();
    }
    widget.onDropdownVisibleChange?.call(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToFirstSelected();
    });
  }

  /// [refocus] keeps the trigger focused after closing (upstream `close()`
  /// refocuses while the select owns focus — issue-2465); outside clicks pass
  /// false so focus follows the pointer.
  void _closePanel({bool refocus = false}) {
    if (!_open) return;
    setState(() {
      _open = false;
      // Upstream `close()` -> `toggle2SearchInput(false)`.
      _showInput = false;
    });
    // Upstream `close()` -> `popoverClose` -> `clearInput`.
    if (_isFilterable) _clearInput();
    if (refocus) _triggerFocusNode.requestFocus();
    widget.onDropdownVisibleChange?.call(false);
  }

  /// SemiTooltip `onVisibleChange`: outside-barrier hits report `false` and
  /// sync the internal state (interaction events never flip a controlled
  /// [SemiTooltip.visible] themselves).
  void _handleTooltipVisibleChange(bool visible) {
    // The tooltip barrier can dispatch one pointer event after the select
    // unmounts (replaced hosts).
    if (!mounted) return;
    if (visible == _open) return;
    setState(() {
      _open = visible;
      if (visible) {
        _resetFocusIndex();
      } else {
        _showInput = false;
      }
    });
    if (visible) {
      _recordPanelWidth();
    } else if (_isFilterable) {
      _clearInput();
    }
    widget.onDropdownVisibleChange?.call(visible);
  }

  /// Upstream `handleClick`: tap the trigger to open; [SemiSelect.clickToHide]
  /// closes an open panel; otherwise refocus the search input. Interactive
  /// children (clear button, tag close, the search input itself) win the
  /// gesture arena and never reach here.
  void _handleTriggerTap() {
    if (widget.disabled) return;
    if (!_open) {
      _openPanel();
      _notifyFocusTick();
    } else if (widget.clickToHide) {
      _closePanel();
    } else {
      if (_isFilterable) {
        if (!widget.multiple && !_isSearchInDropdown && !_showInput) {
          setState(() => _showInput = true);
        }
        _focusInput();
      } else {
        _triggerFocusNode.requestFocus();
      }
    }
  }

  void _notifyFocusTick() {
    if (!_triggerFocusNode.hasFocus && !_inputFocusNode.hasFocus) {
      widget.onFocusChange?.call(true);
    }
  }

  // -- focus helpers ---------------------------------------------------------

  void _focusInput() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _inputFocusNode.requestFocus();
    });
  }

  void _focusTrigger() {
    if (_isFilterable && !_isSearchInDropdown && !widget.multiple) {
      setState(() => _showInput = true);
    }
    _triggerFocusNode.requestFocus();
  }

  // -- focus index (upstream _modifyFocusIndex / _getEnableFocusIndex) -------

  void _resetFocusIndex() {
    var next = -1;
    if (widget.defaultActiveFirstOption && _visibleOptions.isNotEmpty) {
      next = 0;
    }
    _focusIndex = next;
  }

  /// Arrows cycle the highlight through the enabled rows only (wrap around,
  /// skip disabled) and scroll it into view.
  void _moveFocus(int delta) {
    final visible = _visibleOptions;
    final enabled = <int>[
      for (var i = 0; i < visible.length; i++)
        if (!visible[i].disabled) i,
    ];
    if (enabled.isEmpty) return;
    final int next;
    final position = enabled.indexOf(_focusIndex);
    if (position < 0) {
      next = delta > 0 ? enabled.first : enabled.last;
    } else {
      next = enabled[(position + delta) % enabled.length];
    }
    setState(() => _focusIndex = next);
    _ensureOptionVisible(next);
  }

  void _ensureOptionVisible(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = _optionKeys[index]?.currentContext;
      if (context != null) Scrollable.ensureVisible(context, alignment: 0.5);
    });
  }

  /// Upstream `updateScrollTop` on open: center the first selected row.
  void _scrollToFirstSelected() {
    final visible = _visibleOptions;
    for (var i = 0; i < visible.length; i++) {
      if (_isSelected(visible[i])) {
        _ensureOptionVisible(i);
        return;
      }
    }
  }

  void _handleOptionHover(int index) {
    if (!mounted) return;
    // Upstream handleOptionMouseEnter: hover IS the `-focused` state.
    if (_focusIndex == index) return;
    setState(() => _focusIndex = index);
  }

  /// Upstream handleSlotMouseEnter: hovering a slot drops the highlight.
  void _handleSlotHover() {
    if (!mounted) return;
    if (_focusIndex == -1) return;
    setState(() => _focusIndex = -1);
  }

  // -- search input ----------------------------------------------------------

  /// Upstream handleInputChange: refilter (unless remote), notify [onSearch].
  /// Opening on the first keystroke is a port extension (the trigger input can
  /// win the gesture arena before the toggle runs) — see docs/semi_select.md.
  void _handleTextChanged(String text) {
    if (widget.disabled) return;
    setState(() => _inputValue = text);
    widget.onSearch?.call(text);
    if (!_open) {
      _openPanel();
    }
  }

  /// Upstream clearInput: only notifies when the input had text.
  void _clearInput() {
    if (_inputValue.isEmpty) return;
    setState(() => _inputValue = '');
    _inputController.clear();
    widget.onSearch?.call('');
  }

  void _searchFromController(String value) {
    _inputController.text = value;
    _handleTextChanged(value);
  }

  // -- selection actions (upstream onSelect / _handleSingleSelect / ...) ------

  bool _isSelected(SemiSelectOption option) =>
      _selections.any((selection) => selection.value == option.value);

  void _handleSelect(SemiSelectOption option, int index) {
    if (widget.disabled) return;
    if (option.disabled) return;
    // Upstream `onSelect` -> `notifyCreate` first for created rows.
    if (_isCreateOption(option)) widget.onCreate?.call(option);
    if (!widget.multiple) {
      _handleSingleSelect(option);
    } else {
      _handleMultipleSelect(option);
    }
    setState(() => _focusIndex = index);
  }

  /// Upstream _handleSingleSelect: onSelect -> onChange -> close (the task
  /// contract order; upstream defers onChange to the close callback in the
  /// controlled mode).
  void _handleSingleSelect(SemiSelectOption option) {
    widget.onSelect?.call(option.value, option);
    _notifySingle(option);
    if (!_isControlled) _selections = [option];
    _closePanel(refocus: true);
  }

  /// Upstream _handleMultipleSelect: toggle, `max` refuses with [onExceed],
  /// the panel stays open and [autoClearSearchValue] resets the search.
  void _handleMultipleSelect(SemiSelectOption option) {
    final index = _selections.indexWhere(
      (selection) => selection.value == option.value,
    );
    if (index >= 0) {
      widget.onDeselect?.call(option.value, option);
      _commitMultiple([..._selections]..removeAt(index));
    } else if (widget.max != null && _selections.length >= widget.max!) {
      widget.onExceed?.call(option);
      return;
    } else {
      widget.onSelect?.call(option.value, option);
      _commitMultiple([..._selections, option]);
    }
    if (_isFilterable) {
      if (widget.autoClearSearchValue) _clearInput();
      _focusInput();
    }
  }

  void _commitMultiple(List<SemiSelectOption> next) {
    final changed = _diffMultiple(next);
    if (!_isControlled) {
      setState(() => _selections = next);
      _repositionKey += 1;
    }
    if (changed) widget.onChanged?.call(_valuesOf(next));
  }

  /// Upstream removeTag (tag close and Backspace share it).
  void _handleTagClose(SemiSelectOption option) {
    if (widget.disabled) return;
    widget.onDeselect?.call(option.value, option);
    _commitMultiple([
      for (final selection in _selections)
        if (selection.value != option.value) selection,
    ]);
  }

  /// Upstream handleClearClick -> clearSelected: diff-gated [onChanged] then
  /// [onClear].
  void _clearSelected() {
    if (widget.multiple) {
      _commitMultiple(const []);
    } else {
      final changed = _diffSingle(null);
      if (!_isControlled) _selections = [];
      if (changed) widget.onChanged?.call(null);
    }
    widget.onClear?.call();
    if (_isFilterable) _clearInput();
    if (_open) _repositionKey += 1;
  }

  void _selectAll() {
    if (!widget.multiple) return;
    _commitMultiple([..._allOptions]);
  }

  void _deselectAll() {
    if (widget.multiple) {
      _commitMultiple(const []);
    } else {
      final changed = _diffSingle(null);
      if (!_isControlled) _selections = [];
      if (changed) widget.onChanged?.call(null);
    }
    if (_open) _repositionKey += 1;
  }

  // -- keyboard (upstream _handleKeyDown) ------------------------------------

  /// Loading and disabled swallow every key (upstream `_handleKeyDown`).
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (widget.loading || widget.disabled) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowUp) {
      if (!_open) {
        _openPanel();
      } else {
        _moveFocus(key == LogicalKeyboardKey.arrowDown ? 1 : -1);
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter) {
      // A focused search input rides the SemiInput `onEnterPress` channel
      // (the autocomplete precedent) — never double-handle Enter here.
      if (_inputFocusNode.hasPrimaryFocus) return KeyEventResult.ignored;
      _handleEnterPress();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      if (!_open) return KeyEventResult.ignored;
      // Upstream `ESC`: keep the trigger focused (issue-2465 refocus).
      _closePanel(refocus: true);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.backspace) {
      // Upstream _handleBackspaceKeyDown: empty input, multiple mode, drop the
      // last non-disabled tag.
      if (!widget.multiple || _inputValue.isNotEmpty) {
        return KeyEventResult.ignored;
      }
      for (var i = _selections.length - 1; i >= 0; i--) {
        final selection = _selections[i];
        if (!selection.disabled) {
          _handleTagClose(selection);
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    }
    if (key == LogicalKeyboardKey.tab) {
      // Not consumed: default focus traversal continues (the upstream slot
      // focus-cycle chain is not ported — see docs/semi_select.md).
      if (_open) _closePanel();
    }
    return KeyEventResult.ignored;
  }

  /// Upstream _handleEnterKeyDown through the SemiInput `onEnterPress` channel
  /// (or the key handler when no input is mounted): closed opens; open with a
  /// focused enabled option selects it; open without focus closes.
  void _handleEnterPress() {
    if (widget.loading || widget.disabled) return;
    if (!_open) {
      _openPanel();
      return;
    }
    final visible = _visibleOptions;
    if (_focusIndex >= 0 && _focusIndex < visible.length) {
      final option = visible[_focusIndex];
      if (option.disabled) return;
      _handleSelect(option, _focusIndex);
    } else {
      _closePanel();
    }
  }

  // -- build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final global = SemiTheme.of(context);
    final theme = SemiSelectTheme.resolve(context);
    return SemiTooltip(
      content: _buildPanel(global, theme),
      trigger: SemiTooltipTrigger.custom,
      visible: _open,
      onVisibleChange: _handleTooltipVisibleChange,
      showArrow: false,
      popupBare: true,
      position: widget.position,
      // Upstream Popover defaults (no public Select popup params).
      autoAdjustOverflow: true,
      zIndex: _SelectMetrics.popoverZIndex,
      repositionKey: _repositionKey,
      child: Focus(
        focusNode: _triggerFocusNode,
        onKeyEvent: _handleKey,
        onFocusChange: (focused) {
          if (!focused) {
            widget.onFocusChange?.call(false);
            widget.onBlur?.call();
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTriggerTap,
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            child: Listener(
              key: _triggerKey,
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) => setState(() => _pressed = true),
              onPointerUp: (_) => setState(() => _pressed = false),
              onPointerCancel: (_) => setState(() => _pressed = false),
              child: _buildTrigger(global, theme),
            ),
          ),
        ),
      ),
    );
  }

  double _triggerHeight(SemiResolvedSelectThemeData theme) =>
      switch (widget.size) {
        SemiInputSize.small => theme.heightSelectSmall,
        SemiInputSize.normal => theme.heightSelectDefault,
        SemiInputSize.large => theme.heightSelectLarge,
      };

  double _multipleInputHeight(SemiResolvedSelectThemeData theme) =>
      switch (widget.size) {
        SemiInputSize.small => theme.heightSelectMultipleInputSmall,
        SemiInputSize.normal => theme.heightSelectMultipleInputDefault,
        SemiInputSize.large => theme.heightSelectMultipleInputLarge,
      };

  /// Upstream select.scss state matrix (`&`, `&:hover`, `&:active`, `&:focus`,
  /// `&-open`, `&-warning`, `&-error`, `&-disabled`, `&-borderless`).
  (Color, Color, double) _triggerDecoration(
    SemiThemeData global,
    SemiResolvedSelectThemeData theme,
  ) {
    const transparent = Color(0x00000000);
    if (widget.disabled) {
      final bg = _hovering
          ? theme.colorSelectInputDisabledBgHover
          : theme.colorSelectInputDisabledBg;
      // `&-disabled`: `border: ... $color-select_input_disabled-border-focus`
      // (transparent); the resting border uses the commented-out disabled
      // border line (see the dead variable).
      return (
        bg,
        theme.colorSelectInputDisabledBorderFocus,
        theme.widthSelectBorderFocus,
      );
    }
    final Color bg;
    final Color border;
    final double borderWidth;
    switch (widget.validateStatus) {
      case SemiInputStatus.warning:
        bg = _pressed
            ? theme.colorSelectWarningBgActive
            : _hovering
            ? theme.colorSelectWarningBgHover
            : (_open || _triggerFocusNode.hasFocus || _inputFocusNode.hasFocus)
            ? theme.colorSelectWarningBgFocus
            : theme.colorSelectWarningBgDefault;
        border = _pressed
            ? theme.colorSelectWarningBorderActive
            : _hovering
            ? theme.colorSelectWarningBorderHover
            : (_open || _triggerFocusNode.hasFocus || _inputFocusNode.hasFocus)
            ? theme.colorSelectWarningBorderFocus
            : theme.colorSelectWarningBorderDefault;
        borderWidth = theme.widthSelectBorder;
      case SemiInputStatus.error:
        bg = _pressed
            ? theme.colorSelectDangerBgActive
            : _hovering
            ? theme.colorSelectDangerBgHover
            : (_open || _triggerFocusNode.hasFocus || _inputFocusNode.hasFocus)
            ? theme.colorSelectDangerBgFocus
            : theme.colorSelectDangerBgDefault;
        border = _pressed
            ? theme.colorSelectDangerBorderActive
            : _hovering
            ? theme.colorSelectDangerBorderHover
            : (_open || _triggerFocusNode.hasFocus || _inputFocusNode.hasFocus)
            ? theme.colorSelectDangerBorderFocus
            : theme.colorSelectDangerBorderDefault;
        borderWidth = theme.widthSelectBorder;
      default:
        final focused = _triggerFocusNode.hasFocus || _inputFocusNode.hasFocus;
        bg = _pressed
            ? theme.colorSelectBgActive
            : _open || focused
            ? (_hovering
                  ? theme.colorSelectBgDefault
                  : theme.colorSelectBgFocus)
            : _hovering
            ? theme.colorSelectBgHover
            : theme.colorSelectBgDefault;
        if (_pressed && (_open || focused)) {
          border = theme.colorSelectBorderActive;
          borderWidth = theme.widthSelectBorderActive;
        } else if (_open) {
          border = theme.colorSelectDefaultBorderFocus;
          borderWidth = theme.widthSelectBorderFocus;
        } else if (focused) {
          border = theme.colorSelectBorderFocus;
          borderWidth = theme.widthSelectBorderFocus;
        } else if (_hovering) {
          border = theme.colorSelectBorderHover;
          borderWidth = theme.widthSelectBorderHover;
        } else {
          border = theme.colorSelectBorderDefault;
          borderWidth = theme.widthSelectBorder;
        }
    }
    // `&-borderless`: `&:not(:focus-within):not(:hover)` paints nothing.
    if (widget.borderless &&
        !_hovering &&
        !_pressed &&
        !_open &&
        !_triggerFocusNode.hasFocus &&
        !_inputFocusNode.hasFocus) {
      return (transparent, transparent, borderWidth);
    }
    return (bg, border, borderWidth);
  }

  Widget _buildTrigger(
    SemiThemeData global,
    SemiResolvedSelectThemeData theme,
  ) {
    final (bg, border, borderWidth) = _triggerDecoration(global, theme);
    final fontSize = widget.size == SemiInputSize.large
        ? _SelectMetrics.selectionLargeFontSize
        : global.typography.fontSizeRegular;
    final textColor = widget.disabled
        ? theme.colorSelectInputDisabledText
        : theme.colorSelectMainTextDefault;
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.prefix != null)
          _slotText(
            global,
            theme,
            widget.prefix!,
            isIcon: widget.prefix is Widget,
          ),
        if (widget.insetLabel != null)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacingSelectPrefixSuffixTextMarginX,
              vertical: theme.spacingSelectPrefixSuffixTextMarginY,
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: theme.colorSelectPrefixSuffixTextDefault,
                fontSize: global.typography.fontSizeRegular,
                fontWeight: theme.fontSelectPrefixSuffixFontWeight,
              ),
              child: _asWidget(widget.insetLabel!),
            ),
          ),
        Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              // The 12px `-selection` inset belongs to the single-selection
              // area only (select.scss:161); multiple mode manages its own
              // insets (4px tags / 8px empty wrapper) and stacking both made
              // the tags sit ~16px off the border.
              start:
                  !widget.multiple &&
                      widget.prefix == null &&
                      widget.insetLabel == null
                  ? theme.spacingSelectSelectionMarginLeft
                  : 0,
              end: 0,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: widget.multiple
                  ? _buildMultipleSelection(global, theme, textColor, fontSize)
                  : _buildSingleSelection(global, theme, textColor, fontSize),
            ),
          ),
        ),
        if (widget.showClear &&
            (_selections.isNotEmpty || _inputValue.isNotEmpty))
          GestureDetector(
            key: SemiSelect.clearButtonKey,
            behavior: HitTestBehavior.opaque,
            onTap: widget.disabled ? null : _clearSelected,
            child: MouseRegion(
              cursor: widget.disabled
                  ? SystemMouseCursors.forbidden
                  : SystemMouseCursors.click,
              child: SizedBox(
                width: theme.widthSelectClearIcon,
                child: Center(
                  child: SemiIconTheme(
                    data: SemiIconThemeData(
                      color: theme.colorSelectClearBtnTextDefault,
                      customSize: _SelectMetrics.clearIconSize,
                    ),
                    child: widget.clearIcon ?? const SemiIcon(SemiIcons.clear),
                  ),
                ),
              ),
            ),
          ),
        if (widget.suffix != null)
          _slotText(
            global,
            theme,
            widget.suffix!,
            isIcon: widget.suffix is Widget,
          ),
        // `&-arrow` (32) or `&-arrow-empty` (12) when hidden.
        SizedBox(
          width: widget.showArrow
              ? theme.widthSelectArrow
              : theme.widthSelectArrowEmpty,
          child: widget.showArrow
              ? Center(
                  child: SemiIconTheme(
                    data: SemiIconThemeData(
                      color: widget.disabled
                          ? theme.colorSelectInputDisabledText
                          : theme.colorSelectIconDefault,
                      // Upstream renders the bare `IconChevronDown` at
                      // `1em` — the trigger's font size (14 regular/small,
                      // 16 large via `font-size-header-6`).
                      customSize: fontSize + 2,
                    ),
                    child:
                        widget.arrowIcon ??
                        const SemiIcon(SemiIcons.chevronDown),
                  ),
                )
              : null,
        ),
      ],
    );
    // The multiple mode grows with its tags (`min-height` upstream); the
    // single mode keeps the fixed tier height.
    final body = widget.multiple
        ? ConstrainedBox(
            constraints: BoxConstraints(minHeight: _triggerHeight(theme)),
            child: row,
          )
        : SizedBox(height: _triggerHeight(theme), child: row);
    return Semantics(
      button: true,
      enabled: !widget.disabled,
      expanded: _open,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(width: borderWidth, color: border),
          borderRadius: BorderRadius.circular(theme.radiusSelect),
        ),
        child: body,
      ),
    );
  }

  Widget _asWidget(Object value) => value is Widget
      ? value
      : Text(value as String, maxLines: 1, overflow: TextOverflow.ellipsis);

  /// `&-prefix` / `&-suffix` slots: text gets the prefix text margins and the
  /// bold prefix font weight, icons get the icon margins.
  Widget _slotText(
    SemiThemeData global,
    SemiResolvedSelectThemeData theme,
    Object value, {
    required bool isIcon,
  }) {
    final color = widget.disabled
        ? theme.colorSelectInputDisabledText
        : isIcon
        ? theme.colorSelectIconDefault
        : theme.colorSelectPrefixSuffixTextDefault;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isIcon
            ? theme.spacingSelectPrefixSuffixIconMarginX
            : theme.spacingSelectPrefixSuffixTextMarginX,
        vertical: isIcon
            ? theme.spacingSelectPrefixSuffixIconMarginY
            : theme.spacingSelectPrefixSuffixTextMarginY,
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: color,
          fontSize: global.typography.fontSizeRegular,
          fontWeight: isIcon ? null : theme.fontSelectPrefixSuffixFontWeight,
        ),
        child: _asWidget(value),
      ),
    );
  }

  // -- selection area --------------------------------------------------------

  Widget _buildSingleSelection(
    SemiThemeData global,
    SemiResolvedSelectThemeData theme,
    Color textColor,
    double fontSize,
  ) {
    final option = _selections.isEmpty ? null : _selections.first;
    final Widget label;
    if (option == null) {
      label = Text(
        widget.placeholder ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: widget.disabled
              ? theme.colorSelectInputDisabledText
              : theme.colorSelectInputPlaceholderText,
          fontSize: fontSize,
        ),
      );
    } else if (widget.renderSelectedItem != null) {
      label = (widget.renderSelectedItem! as Widget Function(SemiSelectOption))(
        option,
      );
    } else {
      label = Text(
        option.plainText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: textColor, fontSize: fontSize),
      );
    }
    if (!_isFilterable || !_showInput) return label;
    // Single + filterable: the search input stacks over the label; the label
    // dims (`&-selection-text-inactive`, opacity 0.4) while the input is empty
    // and hides once typing starts (`&-selection-text-hide`).
    final hide = _inputValue.isNotEmpty;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        if (!hide)
          Opacity(
            opacity: option == null
                ? 1
                : _SelectMetrics.selectionTextInactiveOpacity,
            child: label,
          ),
        Positioned.fill(
          child: _buildSearchInput(global, theme, inTrigger: true),
        ),
      ],
    );
  }

  Widget _buildMultipleSelection(
    SemiThemeData global,
    SemiResolvedSelectThemeData theme,
    Color textColor,
    double fontSize,
  ) {
    final fold =
        widget.maxTagCount != null && !(widget.expandRestTagsOnClick && _open);
    final visibleTags = fold && _selections.length > widget.maxTagCount!
        ? _selections.take(widget.maxTagCount!).toList()
        : _selections;
    final restCount = _selections.length - visibleTags.length;
    final children = <Widget>[
      if (_selections.isEmpty)
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: theme.spacingSelectMultipleContentWrapperEmptyMarginLeft,
          ),
          child: Text(
            widget.placeholder ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: widget.disabled
                  ? theme.colorSelectInputDisabledText
                  : theme.colorSelectInputPlaceholderText,
              fontSize: fontSize,
            ),
          ),
        )
      else ...[
        for (final (index, option) in visibleTags.indexed)
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: index == 0
                  ? theme.spacingSelectMultipleSelectionMarginLeft
                  : 0,
              top: theme.spacingSelectTagMarginTop,
              bottom: theme.spacingSelectTagMarginBottom,
              end: index == visibleTags.length - 1 && restCount <= 0
                  ? 0
                  : theme.spacingSelectTagMarginRight,
            ),
            child: _buildTag(option, index),
          ),
        if (restCount > 0)
          Padding(
            padding: EdgeInsetsDirectional.only(
              top: theme.spacingSelectTagMarginTop,
              bottom: theme.spacingSelectTagMarginBottom,
            ),
            child: _buildNTag(theme, restCount),
          ),
      ],
      if (_isFilterable && !_isSearchInDropdown)
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: _multipleInputHeight(theme),
            maxHeight: _multipleInputHeight(theme),
            minWidth: _SelectMetrics.multipleInputMinWidth,
          ),
          child: _buildSearchInput(global, theme, inTrigger: true),
        ),
    ];
    // `&-content-wrapper-one-line` folds to a nowrap row; the expanded form
    // wraps (`flex-wrap: wrap`) and the trigger grows with it.
    if (fold) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      );
    }
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }

  Widget _buildTag(SemiSelectOption option, int index) {
    final disabled = option.disabled || widget.disabled;
    void close() => _handleTagClose(option);
    if (widget.renderSelectedItem != null) {
      return (widget.renderSelectedItem!
          as Widget Function(
            SemiSelectOption, {
            int index,
            bool disabled,
            VoidCallback onClose,
          }))(option, index: index, disabled: disabled, onClose: close);
    }
    return SemiTag(
      option.plainText,
      size: SemiTagSize.large,
      color: SemiTagColor.white,
      backgroundColor: const Color(0x00000000),
      closable: !disabled,
      onClose: (_) => close(),
    );
  }

  /// The grey "+N" fold tag (upstream `renderNTag`); [showRestTagsPopover]
  /// wraps it in a hover tooltip listing the folded-away tags.
  Widget _buildNTag(SemiResolvedSelectThemeData theme, int restCount) {
    Widget nTag = Padding(
      // `&-N`: `padding: 4px`.
      padding: const EdgeInsets.all(_SelectMetrics.nTagPadding),
      child: SemiTag(
        '+$restCount',
        key: const ValueKey('_+n'),
        closable: false,
        size: SemiTagSize.large,
        color: SemiTagColor.grey,
        backgroundColor: const Color(0x00000000),
        style: TextStyle(
          // `&-N`: `font-size: 12px`.
          fontSize: _SelectMetrics.nTagFontSize,
          // `&-N`: `color: var(--semi-color-text-0)` — resolved live from the
          // global token instead of a theme field.
          color: SemiTheme.of(context).colors.colorText0,
        ),
      ),
    );
    if (!widget.showRestTagsPopover) return nTag;
    final rest = _selections.sublist(_selections.length - restCount);
    return SemiTooltip(
      content: Padding(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 4,
          runSpacing: 2,
          children: [
            for (final (index, option) in rest.indexed)
              _buildTag(option, index),
          ],
        ),
      ),
      trigger: SemiTooltipTrigger.hover,
      position: widget.restTagsPopoverPosition,
      showArrow: true,
      child: nTag,
    );
  }

  /// `&-selection` search input (upstream `renderTriggerInput`): borderless,
  /// transparent, zero horizontal padding.
  Widget _buildSearchInput(
    SemiThemeData global,
    SemiResolvedSelectThemeData theme, {
    required bool inTrigger,
  }) {
    return SemiInput(
      controller: _inputController,
      focusNode: _inputFocusNode,
      size: widget.size,
      disabled: widget.disabled,
      borderless: true,
      placeholder: inTrigger ? null : widget.searchPlaceholder,
      onChanged: widget.disabled ? null : _handleTextChanged,
      onEnterPress: _handleEnterPress,
    );
  }

  // -- panel (upstream renderDropdown) ---------------------------------------

  /// The dropdown panel paints the Popover surface itself (the
  /// `_SelectMetrics` popover constants): bg-3 + 1px border + radius-medium +
  /// shadow-elevated.
  Widget _buildPanel(SemiThemeData global, SemiResolvedSelectThemeData theme) {
    final visible = _visibleOptions;
    final rows = <Widget>[
      // Invisible width floor: rows fill the recorded trigger width even
      // when the option texts are narrower (upstream block rows).
      if (_panelMinWidth != null) SizedBox(width: _panelMinWidth, height: 0),
      if (widget.innerTopSlot != null)
        MouseRegion(
          onEnter: (_) => _handleSlotHover(),
          child: widget.innerTopSlot!,
        ),
      if (widget.loading)
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: theme.spacingSelectLoadingWrapperPaddingLeft,
            end: theme.spacingSelectLoadingWrapperPaddingRight,
            top: theme.spacingSelectLoadingWrapperPaddingTop,
            bottom: theme.spacingSelectLoadingWrapperPaddingBottom,
          ),
          child: const Align(
            alignment: AlignmentDirectional.centerStart,
            child: SizedBox(
              // `&-loading-wrapper`: `height: 20px` ("make sure that
              // spin align vertical, no need to make 20px as a spacing
              // token here").
              height: _SelectMetrics.loadingWrapperHeight,
              child: SemiSpin(),
            ),
          ),
        )
      else if (visible.isEmpty)
        widget.emptyContent ?? const SizedBox.shrink()
      else
        ..._buildOptionRows(theme, visible),
      if (widget.innerBottomSlot != null)
        MouseRegion(
          onEnter: (_) => _handleSlotHover(),
          child: widget.innerBottomSlot!,
        ),
    ];
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight,
        minWidth: _panelMinWidth ?? 0,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          // `$color-popover-bg-default: var(--semi-color-bg-3)`.
          color: global.colors.colorBg3,
          // `$color-popover-border-default: var(--semi-color-border)`, 1px.
          border: Border.all(width: 1, color: global.colors.colorBorder),
          // `$radius-popover: var(--semi-border-radius-medium)`.
          borderRadius: BorderRadius.circular(
            global.radius.borderRadiusMedium.value,
          ),
          boxShadow: const [
            _SelectMetrics.shadowElevatedBlur,
            _SelectMetrics.shadowElevatedDrop,
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            global.radius.borderRadiusMedium.value,
          ),
          // The overlay hands the panel unbounded width: IntrinsicWidth bounds
          // the stretched column to its widest child (the option rows).
          child: IntrinsicWidth(
            // Outer slots and the dropdown search box sit above/below the
            // scrollable list (upstream `outerTopSlot` /
            // `&-dropdown-search-wrapper` / `outerBottomSlot`); only the list
            // scrolls.
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.outerTopSlot != null)
                  MouseRegion(
                    onEnter: (_) => _handleSlotHover(),
                    child: widget.outerTopSlot!,
                  ),
                if (_isSearchInDropdown)
                  _IntrinsicWidthBlocker(
                    // The search box stretches to the panel width at layout
                    // time but must not contribute intrinsics (SemiInput wraps
                    // its body in a LayoutBuilder).
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        // `&-dropdown-search-wrapper`: `border-bottom: 1px
                        // solid` + the dropdown_input padding fields.
                        border: Border(
                          bottom: BorderSide(
                            width: _SelectMetrics.dropdownSearchBorderWidth,
                            color: theme.colorSelectDropdownInputBorder,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          top: theme.spacingSelectDropdownInputPaddingTop,
                          bottom: theme.spacingSelectDropdownInputPaddingBottom,
                          start: theme.spacingSelectDropdownInputPaddingLeft,
                          end: theme.spacingSelectDropdownInputPaddingRight,
                        ),
                        child: _buildSearchInput(
                          global,
                          theme,
                          inTrigger: false,
                        ),
                      ),
                    ),
                  ),
                Flexible(
                  // `overflow-x: hidden; overflow-y: auto` on the upstream
                  // `&-option-list`; the IntrinsicWidth bounds the stretched
                  // rows to the widest child (the panel hands it unbounded
                  // width).
                  child: SingleChildScrollView(
                    child: IntrinsicWidth(
                      child: DefaultTextStyle.merge(
                        style: TextStyle(
                          fontSize: global.typography.fontSizeRegular,
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(
                            top: theme.spacingSelectOptionListPaddingTop,
                            bottom: theme.spacingSelectOptionListPaddingBottom,
                            start: theme.spacingSelectOptionListPaddingLeft,
                            end: theme.spacingSelectOptionListPaddingRight,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: rows,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.outerBottomSlot != null)
                  MouseRegion(
                    onEnter: (_) => _handleSlotHover(),
                    child: widget.outerBottomSlot!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Group headers follow their first visible member (upstream `renderWithGroup`);
  /// only non-first headers draw the top separator.
  List<Widget> _buildOptionRows(
    SemiResolvedSelectThemeData theme,
    List<SemiSelectOption> visible,
  ) {
    final rows = <Widget>[];
    SemiSelectGroup? lastGroup;
    var headerSeen = false;
    for (final (index, option) in visible.indexed) {
      final group = _isCreateOption(option) ? null : _optionGroup[option];
      if (group != null && !identical(group, lastGroup)) {
        rows.add(_buildGroupHeader(theme, group, headerSeen));
        headerSeen = true;
      }
      lastGroup = group;
      rows.add(
        KeyedSubtree(
          key: _optionKeys.putIfAbsent(index, () => GlobalKey()),
          child: _SelectOptionRow(
            option: option,
            selected: _isSelected(option),
            focused: _focusIndex == index,
            inputValue: _inputValue,
            theme: theme,
            renderOptionItem: widget.renderOptionItem,
            renderCreateItem: widget.renderCreateItem,
            onTap: option.disabled || widget.disabled
                ? null
                : () => _handleSelect(option, index),
            onHover: () => _handleOptionHover(index),
          ),
        ),
      );
    }
    return rows;
  }

  Widget _buildGroupHeader(
    SemiResolvedSelectThemeData theme,
    SemiSelectGroup group,
    bool notFirst,
  ) {
    // `&-group`: text-2, font-size-small, 12/16/4/32 padding and (non-first)
    // the 1px top separator (`color-select_option-border-default`).
    final label = switch (group.label) {
      String s => Text(
        s,
        style: TextStyle(
          color: theme.colorSelectGroupText,
          fontSize: _SelectMetrics.groupFontSize,
        ),
      ),
      Widget w => w,
      _ => const SizedBox.shrink(),
    };
    return Container(
      margin: EdgeInsetsDirectional.only(
        top: theme.spacingSelectGroupMarginTop,
      ),
      padding: EdgeInsetsDirectional.only(
        top: theme.spacingSelectGroupPaddingTop,
        bottom: theme.spacingSelectGroupPaddingBottom,
        start: theme.spacingSelectGroupPaddingLeft,
        end: theme.spacingSelectGroupPaddingRight,
      ),
      decoration: BoxDecoration(
        border: notFirst
            ? Border(
                top: BorderSide(
                  width: theme.widthSelectGroupTopBorder,
                  color: theme.colorSelectOptionBorderDefault,
                ),
              )
            : null,
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: theme.colorSelectGroupText,
          fontSize: _SelectMetrics.groupFontSize,
        ),
        child: label,
      ),
    );
  }
}

/// Shields a subtree from intrinsic-size queries: [SemiInput] wraps its body
/// in a `LayoutBuilder`, which cannot answer intrinsics, while the panel's
/// [IntrinsicWidth] computes exactly those. Layout constraints pass through
/// untouched, so the child still stretches at layout time.
class _IntrinsicWidthBlocker extends SingleChildRenderObjectWidget {
  const _IntrinsicWidthBlocker({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderIntrinsicWidthBlocker();
}

class _RenderIntrinsicWidthBlocker extends RenderProxyBox {
  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) => 0;

  @override
  double computeMinIntrinsicHeight(double width) => 0;

  @override
  double computeMaxIntrinsicHeight(double width) => 0;
}

/// One option row (upstream `Option`/option.tsx + the `&-option` rules of
/// option.scss). Hover and keyboard highlight share the `-focused` fill; the
/// selected row is bold with the tick visible.
class _SelectOptionRow extends StatefulWidget {
  const _SelectOptionRow({
    required this.option,
    required this.selected,
    required this.focused,
    required this.inputValue,
    required this.theme,
    required this.renderOptionItem,
    required this.renderCreateItem,
    required this.onTap,
    required this.onHover,
  });

  final SemiSelectOption option;
  final bool selected;
  final bool focused;
  final String inputValue;
  final SemiResolvedSelectThemeData theme;
  final Object? renderOptionItem;
  final Object? renderCreateItem;

  /// Null when disabled (upstream drops the click on disabled rows).
  final VoidCallback? onTap;
  final VoidCallback onHover;

  @override
  State<_SelectOptionRow> createState() => _SelectOptionRowState();
}

class _SelectOptionRowState extends State<_SelectOptionRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final global = SemiTheme.of(context);
    final option = widget.option;
    final createOnly = option is _CreateOption;
    final Color bg;
    if (_pressed && widget.onTap != null) {
      // `&:active`.
      bg = theme.colorSelectOptionBgActive;
    } else if (widget.focused) {
      // `&-focused` (hover and keyboard highlight share this fill).
      bg = theme.colorSelectOptionBgHover;
    } else {
      bg = const Color(0x00000000);
    }
    final Color textColor = option.disabled
        ? theme.colorSelectOptionDisabledText
        : theme.colorSelectOptionMainText;

    final Widget content;
    if (createOnly && widget.renderCreateItem != null) {
      content = (widget.renderCreateItem! as Widget Function(String))(
        option.value as String,
      );
    } else if (createOnly) {
      // Default create row: `&-create-tips` label then the typed text.
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(
              end: theme.spacingSelectCreateTipsMarginRight,
            ),
            child: Text(
              '创建',
              style: TextStyle(
                color: theme.colorSelectCreateTipsText,
                fontSize: global.typography.fontSizeRegular,
              ),
            ),
          ),
          Flexible(
            child: Text(
              option.plainText,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: global.typography.fontSizeRegular,
              ),
            ),
          ),
        ],
      );
    } else if (widget.renderOptionItem != null) {
      content =
          (widget.renderOptionItem!
              as Widget Function(
                SemiSelectOption, {
                bool selected,
                bool focused,
                String inputValue,
                VoidCallback onHover,
                VoidCallback onTap,
              }))(
            option,
            selected: widget.selected,
            focused: widget.focused,
            inputValue: widget.inputValue,
            onHover: widget.onHover,
            onTap: widget.onTap ?? () {},
          );
    } else if (option.label is Widget) {
      content = option.label! as Widget;
    } else {
      // Keyword highlight of the built-in text (upstream `&-option-keyword`).
      final inputText = widget.inputValue;
      content = SemiHighlight(
        option.plainText,
        searchWords: inputText.isEmpty
            ? const <SemiHighlightWord<TextStyle>>[]
            : [
                SemiHighlightWord<TextStyle>(
                  inputText,
                  style: TextStyle(
                    // `background-color: inherit` — no highlight fill.
                    backgroundColor: const Color(0x00000000),
                    color: theme.colorSelectOptionKeywordText,
                    fontWeight: theme.fontSelectKeywordFontWeight,
                  ),
                ),
              ],
      );
    }

    Widget box = Row(
      children: [
        if (option.showTick)
          Padding(
            padding: EdgeInsetsDirectional.only(
              end: theme.spacingSelectOptionTickMarginRight,
            ),
            child: SizedBox(
              width: theme.widthSelectOptionTick,
              height: theme.widthSelectOptionTick,
              // Upstream always renders the tick and hides it with a
              // transparent `&-option-icon` colour; an unselected row keeps
              // the slot but drops the icon so the tick can never ghost
              // through a renderer that ignores transparent currentColor.
              child: widget.selected
                  ? IconTheme(
                      data: IconThemeData(
                        color: theme.colorSelectOptionIconActive,
                        size: theme.widthSelectOptionTick,
                      ),
                      child: const ExcludeSemantics(
                        child: SemiIcon(
                          SemiIcons.tick,
                          excludeFromSemantics: true,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        Flexible(child: content),
      ],
    );
    box = Padding(
      padding: EdgeInsetsDirectional.only(
        start: theme.spacingSelectOptionPaddingLeft,
        top: theme.spacingSelectOptionPaddingTop,
        end: theme.spacingSelectOptionPaddingRight,
        bottom: theme.spacingSelectOptionPaddingBottom,
      ),
      child: box,
    );
    box = DefaultTextStyle.merge(
      style: TextStyle(
        color: textColor,
        fontSize: global.typography.fontSizeRegular,
        // `&-selected`: `font-weight: $font-weight-bold`.
        fontWeight: widget.selected
            ? global.typography.fontWeightBold
            : theme.fontSelectFontWeight,
      ),
      child: box,
    );
    box = AnimatedContainer(
      duration: theme.transitionDurationSelectOptionBg,
      curve: theme.transitionFunctionSelectOptionBg,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(theme.radiusSelectOption),
      ),
      child: box,
    );
    if (widget.onTap != null) {
      box = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: box,
      );
    }
    box = Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: box,
    );
    box = MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      onEnter: (_) => widget.onHover(),
      child: box,
    );
    return Semantics(
      container: true,
      enabled: !option.disabled,
      selected: widget.selected,
      child: box,
    );
  }
}

/// Widget-internal metrics and provenance anchors (upstream values kept out of
/// the theme). See tool/generate_select.py for the 115 = 104 themed + 9
/// motion + 2 INTERNAL accounting; the constants below are the INTERNAL and
/// 另列 HARDCODES entries.
abstract final class _SelectMetrics {
  /// `$transform_scale-select: var(--semi-transform_scale-none)` in
  /// packages/semi-foundation/select/animation.scss. Identity scale — no
  /// transform is applied (INTERNAL).
  // ignore: unused_field
  static const String transformScaleSelect =
      r'$transform_scale-select: var(--semi-transform_scale-none)';

  /// `$transform_rotate-select-arrow: var(--semi-transform-rotate-none)` in
  /// packages/semi-foundation/select/animation.scss. Identity rotate — the
  /// arrow does not spin (INTERNAL).
  // ignore: unused_field
  static const String transformRotateSelectArrow =
      r'$transform_rotate-select-arrow: var(--semi-transform-rotate-none)';

  /// `max-height: 300px` in packages/semi-foundation/select/select.scss
  /// (`&`, the trigger scroll region).
  // ignore: unused_field
  static const double triggerMaxHeight = 300;

  /// `height: 20px` in packages/semi-foundation/select/select.scss
  /// (`&-loading-wrapper`, "make sure that spin align vertical, no need to
  /// make 20px as a spacing token here").
  static const double loadingWrapperHeight = 20;

  /// `padding: 4px` in packages/semi-foundation/select/select.scss (`&-N`,
  /// the "+N" fold tag).
  static const double nTagPadding = 4;

  /// `font-size: 12px` in packages/semi-foundation/select/select.scss (`&-N`).
  static const double nTagFontSize = 12;

  /// `min-width: 50px` in packages/semi-foundation/select/select.scss
  /// (`.#{$overflowList}-overflow`, the width-based overflow list — not
  /// ported; see docs/semi_select.md).
  // ignore: unused_field
  static const double overflowMinWidth = 50;

  /// `border-bottom: 1px solid` in
  /// packages/semi-foundation/select/select.scss (`&-dropdown-search-wrapper`).
  static const double dropdownSearchBorderWidth = 1;

  /// `LIST_HEIGHT: 270` in packages/semi-foundation/select/constants.ts
  /// (`numbers`). Default of [SemiSelect.maxHeight].
  static const double listHeight = 270;

  /// `opacity: $opacity-select_selection_text_inactive` (0.4) on the upstream
  /// `&-selection-text-inactive` rule: the label dims behind the stacked
  /// single-mode search input. The opacity value itself is the themed
  /// `opacitySelectSelectionTextInactive`; the structural mapping is recorded
  /// here.
  // ignore: unused_field
  static const String selectionTextInactiveRule =
      r'&-selection-text-inactive { opacity: $opacity-select_selection_text_inactive }';

  /// Same default as the themed `opacitySelectSelectionTextInactive`
  /// (`0.4`) — kept for the dimmed label call site.
  static const double selectionTextInactiveOpacity = 0.4;

  /// Upstream sizes the multiple-mode inline search input by its content
  /// (`width: auto` measured in JS); the port gives it a small floor instead
  /// (see docs/semi_select.md).
  static const double multipleInputMinWidth = 8;

  /// `font-size: 12px` on the "+N" tag already covers the fold; the tag
  /// close icon size of SemiTag (`customSize: 12`) is the tag component's.
  static const double clearIconSize = 12;

  /// `@include font-size-small` in packages/semi-foundation/select/select.scss
  /// (`&-group`). The port reads the live `typography.fontSizeSmall` token
  /// (12 by default); the mixin provenance is recorded here.
  static const double groupFontSize = 12;

  /// `@include font-size-header-6` in
  /// packages/semi-foundation/select/select.scss (`&-large .&-selection`).
  /// `$font-size-header-6: 16px` in
  /// packages/semi-theme-default/scss/variables.scss.
  static const double selectionLargeFontSize = 16;

  /// `color: var(--semi-color-text-0)` in
  /// packages/semi-foundation/select/select.scss (`&-N`). The port resolves
  /// the live `theme.colors.colorText0` at the call site instead (see the
  /// inline hardcode there).
  // ignore: unused_field
  static const String nTagTextColor = 'colorText0';

  /// `$color-popover-bg-default: var(--semi-color-bg-3)` in
  /// packages/semi-foundation/popover/variables.scss. The panel paints the
  /// Popover surface itself (upstream wraps the list in `Popover`); the port
  /// resolves the background live from `theme.colors.colorBg3` instead.
  // ignore: unused_field
  static const String popoverSurfaceBg = 'colorBg3';

  /// `$color-popover-border-default: var(--semi-color-border)` in
  /// packages/semi-foundation/popover/variables.scss. The 1px panel border
  /// resolves live from `theme.colors.colorBorder`.
  // ignore: unused_field
  static const String popoverSurfaceBorder = 'colorBorder';

  /// `$radius-popover: var(--semi-border-radius-medium)` in
  /// packages/semi-foundation/popover/variables.scss. Resolves live from
  /// `theme.radius.borderRadiusMedium.value` (6 by default).
  // ignore: unused_field
  static const String popoverSurfaceRadius = 'borderRadiusMedium';

  /// `z-index: $z-popover` in packages/semi-foundation/popover/popover.scss,
  /// with `$z-popover: 1030` in packages/semi-theme-default/scss/variables.scss.
  /// Passed to [SemiTooltip.zIndex]; overlay insertion order decides stacking.
  static const int popoverZIndex = 1030;

  /// `0 0 1px rgba(0, 0, 0, .3)` — first box-shadow layer of the
  /// `@include shadow-elevated` mixin
  /// (packages/semi-theme-default/scss/global.scss). Hardcoded to the light
  /// token values (see docs/semi_select.md).
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
}
