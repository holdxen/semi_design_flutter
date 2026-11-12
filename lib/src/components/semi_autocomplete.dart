import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../overlay/tooltip_positioning.dart';
import '../theme/semi_autocomplete_theme.dart';
import '../theme/semi_autocomplete_theme_data.dart';
import '../theme/semi_theme.dart';
import '../theme/semi_theme_data.dart';
import 'highlight_algorithm.dart';
import 'semi_highlight.dart';
import 'semi_input.dart';
import 'semi_spin.dart';
import 'semi_tooltip.dart';

/// One candidate of a [SemiAutoComplete] (upstream `AutoCompleteItems`:
/// `BaseDataItem | string | number`; the port normalizes all three to this
/// class).
class SemiAutoCompleteOption {
  const SemiAutoCompleteOption({
    required this.value,
    this.label,
    this.text,
    this.show = true,
    this.disabled = false,
  });

  /// The candidate identity: [String] or [num] (upstream `string | number`).
  /// The controlled [SemiAutoComplete.value] matches on `value.toString()`.
  final Object value;

  /// Panel content; null renders [text] with keyword highlighting
  /// (upstream `label`, rendered as the option children).
  final Widget? label;

  /// Plain text used for keyword highlighting and matching; null falls back
  /// to `value.toString()` (upstream string children).
  final String? text;

  /// Upstream `item.show` forces the row hidden; defaults to true.
  final bool show;

  /// No interaction and disabled colors (upstream `disabled`).
  final bool disabled;

  /// The plain text of this option ([text] ?? `value.toString()`).
  String get plainText => text ?? value.toString();
}

/// A source-sized, non-Material auto-completing input (upstream Semi
/// AutoComplete) built on [SemiInput] + [SemiTooltip].
///
/// Port notes (see docs/semi_autocomplete.md for the full difference list):
/// * No built-in filtering: [onSearch]/[onChanged] only notify and the caller
///   narrows [data] (upstream core convention).
/// * [value] non-null is controlled (the SemiInput convention): rendering
///   follows [value] resolved through [data] and edits/selections only emit
///   callbacks. Uncontrolled, the text lives in [controller].
/// * [onSelect] always reports the whole [SemiAutoCompleteOption]
///   (deliberate deviation from the upstream `onSelectWithObject` switch).
/// * Enter rides [SemiInput.onEnterPress] only; arrows/Escape/Tab are
///   consumed by the outer key handler (no Home/End).
class SemiAutoComplete extends StatefulWidget {
  const SemiAutoComplete({
    super.key,
    this.data = const [],
    this.value,
    this.initialValue,
    this.onChanged,
    this.onSearch,
    this.onSelect,
    this.onClear,
    this.onDropdownVisibleChange,
    this.onFocusChange,
    this.onBlur,
    this.renderSelectedItem,
    this.renderItem,
    this.showClear = false,
    this.clearIcon,
    this.size = SemiInputSize.normal,
    this.disabled = false,
    this.placeholder,
    this.prefix,
    this.suffix,
    this.insetLabel,
    this.loading = false,
    this.emptyContent,
    this.dropdownMatchSelectWidth = true,
    this.maxHeight = _AutoCompleteMetrics.maxHeightDefault,
    this.position = SemiTooltipPosition.bottomLeft,
    this.defaultOpen = false,
    this.defaultActiveFirstOption = false,
    this.autoFocus = false,
    this.validateStatus = SemiInputStatus.normal,
    this.motion = true,
    this.controller,
    this.focusNode,
    this.semanticsLabel,
  }) : assert(
         controller == null || initialValue == null,
         'Provide either controller or initialValue, not both.',
       );

  /// Candidates; `show: false` rows are not rendered (upstream `item.show`).
  final List<SemiAutoCompleteOption> data;

  /// Non-null makes the auto-complete controlled (SemiInput convention): the
  /// displayed text follows this value resolved through [data] and edits only
  /// emit [onChanged]/[onSearch].
  final String? value;

  /// Seed of the uncontrolled display text; resolved through [data] like the
  /// controlled [value] (upstream `defaultValue`).
  final String? initialValue;

  /// Fires on every edit and after a selection (the new display text) —
  /// upstream `onChange`. No built-in filtering.
  final ValueChanged<String>? onChanged;

  /// Fires on every edit with the raw input text (upstream `onSearch`); the
  /// caller filters [data] here.
  final ValueChanged<String>? onSearch;

  /// Reports the whole option on activation (upstream `onSelect` with
  /// `onSelectWithObject: true`).
  final ValueChanged<SemiAutoCompleteOption>? onSelect;

  /// Fires after a clear tap (following `onChanged('')`/`onSearch('')`).
  final VoidCallback? onClear;

  /// Reports panel open/close changes (upstream `onDropdownVisibleChange`).
  final ValueChanged<bool>? onDropdownVisibleChange;

  final ValueChanged<bool>? onFocusChange;

  /// Blur never closes the panel (upstream `handleBlur` only notifies).
  final VoidCallback? onBlur;

  /// Display text of a selected option; defaults to `option.value.toString()`
  /// (upstream `_getRenderSelectedItem` — the default is `value`, not label).
  final String Function(SemiAutoCompleteOption)? renderSelectedItem;

  /// Replaces the panel content of an option (upstream `renderItem`); the
  /// keyword highlight only applies to the built-in text rendering.
  final Widget Function(SemiAutoCompleteOption)? renderItem;

  /// Shows the clear button while hovering or focused with non-empty text.
  final bool showClear;

  /// Custom clear icon (defaults to `SemiIcons.clear`).
  final Widget? clearIcon;

  final SemiInputSize size;
  final bool disabled;
  final String? placeholder;

  /// String or Widget, passed through to [SemiInput] (upstream `prefix`).
  final Object? prefix;

  /// String or Widget, passed through to [SemiInput] (upstream `suffix`).
  final Object? suffix;

  /// String or Widget, passed through to [SemiInput] (upstream `insetLabel`).
  final Object? insetLabel;

  /// Replaces the option list with a [SemiSpin] loading row (upstream
  /// `loading`).
  final bool loading;

  /// Body when [data] is empty; null renders an empty panel (upstream
  /// `emptyContent`).
  final Widget? emptyContent;

  /// Panel `minWidth` equals the measured input width when true (upstream
  /// `dropdownMatchSelectWidth`; the upstream `style.width` override branch is
  /// not ported).
  final bool dropdownMatchSelectWidth;

  /// Panel height cap in logical pixels
  /// (upstream `maxHeight: 300` in packages/semi-ui/autocomplete/index.tsx).
  final double maxHeight;

  /// Preferred placement (upstream `position`, default `bottomLeft`).
  final SemiTooltipPosition position;

  /// Opens the panel on mount (upstream `defaultOpen`).
  final bool defaultOpen;

  /// Highlights (and Enter-selects) the first enabled option whenever the
  /// panel opens or [data]/the input change (upstream
  /// `defaultActiveFirstOption`).
  final bool defaultActiveFirstOption;

  /// Focuses the input on mount (upstream `autoFocus`).
  final bool autoFocus;

  final SemiInputStatus validateStatus;

  /// Whether the show/hide motion plays (upstream `motion`).
  final bool motion;

  /// External controller; never disposed by the widget.
  final TextEditingController? controller;

  /// External focus node; never disposed by the widget.
  final FocusNode? focusNode;

  final String? semanticsLabel;

  @override
  State<SemiAutoComplete> createState() => _SemiAutoCompleteState();
}

class _SemiAutoCompleteState extends State<SemiAutoComplete> {
  late TextEditingController _controller;
  late bool _ownsController;
  late FocusNode _focusNode;
  late bool _ownsFocusNode;

  /// Panel visibility (upstream `visible`).
  bool _open = false;

  /// Index into [_visibleOptions] of the keyboard/hover-highlighted row;
  /// -1 when nothing is highlighted (upstream `focusIndex`).
  int _focusIndex = -1;

  /// Sticky selected option of the uncontrolled mode (upstream `selection`);
  /// the controlled mode derives it from [SemiAutoComplete.value].
  SemiAutoCompleteOption? _selected;

  /// Bumped when [SemiAutoComplete.data] changes so the panel repositions
  /// (upstream `rePosKey`).
  int _repositionKey = 0;

  final GlobalKey _triggerKey = GlobalKey();

  /// Input width recorded when the panel opens (upstream
  /// `setOptionWrapperWidth`/`dropdownMinWidth`).
  double? _panelMinWidth;

  final Map<int, GlobalKey> _optionKeys = {};

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = TextEditingController(
        text: widget.value != null
            ? _resolveDisplay(widget.value!)
            : (widget.initialValue == null
                  ? ''
                  : _resolveDisplay(widget.initialValue!)),
      );
      _ownsController = true;
      // Upstream init() runs handleValueChange on defaultValue: the seed is
      // resolved through data and records the selected option.
      if (widget.value == null && widget.initialValue != null) {
        _selected = _matchByValue(widget.initialValue!);
      }
    }
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _ownsFocusNode = false;
    } else {
      _focusNode = FocusNode(debugLabel: 'SemiAutoComplete');
      _ownsFocusNode = true;
    }
    if (widget.defaultOpen) {
      _open = true;
      _resetFocusIndex();
      _recordPanelWidth();
      // Upstream init() notifies through openDropdown(); deferred past the
      // first build so a notifying parent cannot setState during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(_recordPanelWidth);
        if (_open) widget.onDropdownVisibleChange?.call(true);
      });
    }
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(SemiAutoComplete oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_ownsController) _controller.dispose();
      if (widget.controller != null) {
        _controller = widget.controller!;
        _ownsController = false;
      } else {
        _controller = TextEditingController(text: widget.value ?? '');
        _ownsController = true;
      }
    }
    if (widget.focusNode != oldWidget.focusNode) {
      if (_ownsFocusNode) _focusNode.dispose();
      if (widget.focusNode != null) {
        _focusNode = widget.focusNode!;
        _ownsFocusNode = false;
      } else {
        _focusNode = FocusNode(debugLabel: 'SemiAutoComplete');
        _ownsFocusNode = true;
      }
    }
    if (!listEquals(oldWidget.data, widget.data)) {
      // Upstream handleDataChange: regenerate + reposition + re-run the
      // focus-index rule.
      _repositionKey += 1;
      setState(_resetFocusIndex);
    }
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  // -- display text / selection (upstream handleValueChange) -----------------

  SemiAutoCompleteOption? _matchByValue(String value) {
    for (final option in widget.data) {
      if (option.value.toString() == value) return option;
    }
    return null;
  }

  String _renderSelected(SemiAutoCompleteOption option) =>
      widget.renderSelectedItem?.call(option) ?? option.value.toString();

  /// Controlled display text: the matched option renders through
  /// [renderSelectedItem], an unmatched value shows verbatim.
  String _resolveDisplay(String value) {
    final matched = _matchByValue(value);
    return matched == null ? value : _renderSelected(matched);
  }

  /// The text currently shown in the input (the controller mirrors it).
  String get _inputText => _controller.text;

  /// Controlled mode derives the selected row from [SemiAutoComplete.value];
  /// uncontrolled keeps the sticky [SemiAutoComplete.onSelect] result.
  SemiAutoCompleteOption? get _selectedOption {
    final value = widget.value;
    if (value == null) return _selected;
    return _matchByValue(value);
  }

  bool _isSelected(SemiAutoCompleteOption option) {
    final selected = _selectedOption;
    return identical(selected, option) ||
        (selected != null && selected.value == option.value);
  }

  List<SemiAutoCompleteOption> get _visibleOptions => [
    for (final option in widget.data)
      if (option.show) option,
  ];

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
    widget.onDropdownVisibleChange?.call(true);
  }

  void _closePanel() {
    if (!_open) return;
    setState(() => _open = false);
    widget.onDropdownVisibleChange?.call(false);
  }

  void _togglePanel() => _open ? _closePanel() : _openPanel();

  /// SemiTooltip `onVisibleChange`: outside-barrier hits report `false` and
  /// sync the internal state (interaction events never flip a controlled
  /// [SemiTooltip.visible] themselves).
  void _handleTooltipVisibleChange(bool visible) {
    if (visible == _open) return;
    setState(() {
      _open = visible;
      if (visible) {
        _resetFocusIndex();
      }
    });
    if (visible) _recordPanelWidth();
    widget.onDropdownVisibleChange?.call(visible);
  }

  /// The render box of the widget carrying [key] anywhere below this state.
  RenderBox? _renderBoxBelow(Key key) {
    Element? target;
    void visit(Element element) {
      if (target != null) return;
      if (element.widget.key == key) {
        target = element;
        return;
      }
      element.visitChildren(visit);
    }

    context.visitChildElements(visit);
    return target?.findRenderObject() as RenderBox?;
  }

  static bool _covers(RenderBox? box, Offset global) =>
      box != null &&
      box.hasSize &&
      (box.localToGlobal(Offset.zero) & box.size).contains(global);

  /// Upstream toggles the panel on the input click (`handleInputClick`).
  /// A [GestureDetector] would lose the arena to the editable text's own tap
  /// recognizers, so the toggle rides raw pointer-ups with two geometry
  /// checks: releases outside the trigger do not toggle (drag-out), and the
  /// clear button tap is left to the clear chain alone (it runs later in the
  /// arena sweep and reports `onChanged('')`/`onSearch('')`/`onClear()`).
  void _handlePointerUp(PointerUpEvent event) {
    if (widget.disabled) return;
    if (!_covers(
      _triggerKey.currentContext?.findRenderObject() as RenderBox?,
      event.position,
    )) {
      return;
    }
    if (_covers(_renderBoxBelow(SemiInput.clearButtonKey), event.position)) {
      return;
    }
    _togglePanel();
  }

  // -- focus index (upstream _modifyFocusIndex) ------------------------------

  void _resetFocusIndex() {
    var next = -1;
    if (widget.defaultActiveFirstOption) {
      final visible = _visibleOptions;
      for (var i = 0; i < visible.length; i++) {
        if (!visible[i].disabled) {
          next = i;
          break;
        }
      }
    }
    _focusIndex = next;
  }

  /// Arrows cycle the highlight through the enabled rows only (wrap around,
  /// skip disabled) and scroll it into view (upstream `_getEnableFocusIndex`).
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = _optionKeys[next]?.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(context, alignment: 0.5);
      }
    });
  }

  void _handleOptionHover(int index) {
    // Upstream handleOptionMouseEnter: hover IS the `-focused` state.
    if (_focusIndex == index) return;
    setState(() => _focusIndex = index);
  }

  // -- text edits / selection / clear ----------------------------------------

  /// Upstream handleSearch: notify both channels and open the panel. No
  /// filtering happens here (the caller narrows `data`).
  void _handleTextChanged(String text) {
    widget.onSearch?.call(text);
    widget.onChanged?.call(text);
    if (!_open) {
      _openPanel();
    } else {
      setState(_resetFocusIndex);
    }
  }

  /// Upstream handleSelect: land the display text (uncontrolled only), notify
  /// `onSelect`/`onChanged` and close the panel.
  void _handleSelect(SemiAutoCompleteOption option) {
    if (option.disabled) return;
    final text = _renderSelected(option);
    setState(() {
      _selected = option;
      if (widget.value == null) {
        _controller.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });
    widget.onSelect?.call(option);
    widget.onChanged?.call(text);
    _closePanel();
  }

  /// Upstream `_handleEnterKeyDown` through the SemiInput `onEnterPress`
  /// channel (never handled in the key handler): closed opens; open with a
  /// focused enabled option selects it; open without focus closes. The `done`
  /// action unfocuses the field before `onSubmitted` (EditableText default),
  /// so the handler re-requests focus to keep typing going (upstream Enter
  /// keeps focus; the re-focus restarts the connection per the issue-84240
  /// pattern in `EditableText._finalizeEditing`).
  void _handleEnterPress() {
    if (widget.disabled) return;
    if (!_open) {
      _openPanel();
    } else {
      final visible = _visibleOptions;
      if (_focusIndex >= 0 &&
          _focusIndex < visible.length &&
          !visible[_focusIndex].disabled) {
        _handleSelect(visible[_focusIndex]);
      } else {
        _closePanel();
      }
    }
    _focusNode.requestFocus();
  }

  // -- keyboard --------------------------------------------------------------

  /// Arrows open/move, Escape closes (consumed), Tab closes without consuming
  /// (focus traversal keeps running). Left/Right always propagate (cursor
  /// movement) and there is no Home/End (upstream parity).
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowUp) {
      if (widget.disabled) return KeyEventResult.ignored;
      if (!_open) {
        _openPanel();
      } else {
        _moveFocus(key == LogicalKeyboardKey.arrowDown ? 1 : -1);
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      if (!_open) return KeyEventResult.ignored;
      _closePanel();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.tab) {
      // Not consumed: default focus traversal continues.
      if (_open) _closePanel();
    }
    return KeyEventResult.ignored;
  }

  // -- build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final global = SemiTheme.of(context);
    final theme = SemiAutoCompleteTheme.resolve(context);
    return SemiTooltip(
      content: _buildPanel(global, theme),
      trigger: SemiTooltipTrigger.custom,
      visible: _open,
      onVisibleChange: _handleTooltipVisibleChange,
      showArrow: false,
      popupBare: true,
      position: widget.position,
      motion: widget.motion,
      // Upstream Popover defaults (no public AutoComplete params).
      autoAdjustOverflow: true,
      zIndex: _AutoCompleteMetrics.popoverZIndex,
      repositionKey: _repositionKey,
      child: Listener(
        key: _triggerKey,
        behavior: HitTestBehavior.translucent,
        onPointerUp: _handlePointerUp,
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: _handleKey,
          child: SemiInput(
            value: widget.value != null ? _resolveDisplay(widget.value!) : null,
            controller: _controller,
            focusNode: _focusNode,
            size: widget.size,
            validateStatus: widget.validateStatus,
            disabled: widget.disabled,
            placeholder: widget.placeholder,
            prefix: widget.prefix,
            suffix: widget.suffix,
            insetLabel: widget.insetLabel,
            showClear: widget.showClear,
            clearIcon: widget.clearIcon,
            onChanged: _handleTextChanged,
            onEnterPress: _handleEnterPress,
            onClear: widget.onClear,
            onFocusChange: widget.onFocusChange,
            onBlur: widget.onBlur,
            semanticsLabel: widget.semanticsLabel,
          ),
        ),
      ),
    );
  }

  /// The dropdown panel paints the Popover surface itself (HARDCODES
  /// `_AutoCompleteMetrics` #1-3/6-9): bg-3 + 1px border + radius-medium +
  /// shadow-elevated.
  Widget _buildPanel(
    SemiThemeData global,
    SemiResolvedAutoCompleteThemeData theme,
  ) {
    Widget body;
    if (widget.loading) {
      body = Padding(
        padding: EdgeInsetsDirectional.only(
          top: theme.spacingAutoCompleteLoadingWrapperPaddingTop,
          bottom: theme.spacingAutoCompleteLoadingWrapperPaddingBottom,
        ),
        child: const Align(
          alignment: AlignmentDirectional.center,
          child: SizedBox(
            height: _AutoCompleteMetrics.loadingWrapperHeight,
            child: SemiSpin(),
          ),
        ),
      );
    } else if (widget.data.isEmpty) {
      body = widget.emptyContent ?? const SizedBox.shrink();
    } else {
      final visible = _visibleOptions;
      body = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Invisible width floor: rows fill the recorded input width even
          // when the option texts are narrower (upstream block rows).
          if (_panelMinWidth != null)
            SizedBox(width: _panelMinWidth, height: 0),
          for (final (index, option) in visible.indexed)
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: index == 0
                    ? theme.spacingAutoCompleteOptionFirstMarginTop
                    : 0,
                bottom: index == visible.length - 1
                    ? theme.spacingAutoCompleteOptionLastMarginBottom
                    : 0,
              ),
              child: KeyedSubtree(
                key: _optionKeys.putIfAbsent(index, () => GlobalKey()),
                child: _AutoCompleteOptionView(
                  option: option,
                  focused: _focusIndex == index,
                  selected: _isSelected(option),
                  inputText: _inputText,
                  renderItem: widget.renderItem,
                  theme: theme,
                  onTap: option.disabled ? null : () => _handleSelect(option),
                  onHover: () => _handleOptionHover(index),
                ),
              ),
            ),
        ],
      );
    }
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
            _AutoCompleteMetrics.shadowElevatedBlur,
            _AutoCompleteMetrics.shadowElevatedDrop,
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            global.radius.borderRadiusMedium.value,
          ),
          // `overflow-x: hidden; overflow-y: auto` on the upstream
          // `&-option-list`.
          child: SingleChildScrollView(
            // The overlay hands the panel unbounded width (the popover sizes
            // to its content): IntrinsicWidth bounds the stretched rows to
            // the widest child.
            child: IntrinsicWidth(
              child: DefaultTextStyle.merge(
                style: TextStyle(fontSize: global.typography.fontSizeRegular),
                child: body,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One option row (upstream `Option`/option.tsx + the `&-option` rules of
/// option.scss). Hover and keyboard highlight share the `-focused` fill
/// (there is no separate hover style upstream); the selected row is bold.
class _AutoCompleteOptionView extends StatefulWidget {
  const _AutoCompleteOptionView({
    required this.option,
    required this.focused,
    required this.selected,
    required this.inputText,
    required this.renderItem,
    required this.theme,
    required this.onTap,
    required this.onHover,
  });

  final SemiAutoCompleteOption option;
  final bool focused;
  final bool selected;
  final String inputText;
  final Widget Function(SemiAutoCompleteOption)? renderItem;
  final SemiResolvedAutoCompleteThemeData theme;

  /// Null when disabled (upstream drops the click on disabled rows).
  final VoidCallback? onTap;
  final VoidCallback onHover;

  @override
  State<_AutoCompleteOptionView> createState() =>
      _AutoCompleteOptionViewState();
}

class _AutoCompleteOptionViewState extends State<_AutoCompleteOptionView> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final global = SemiTheme.of(context);
    final option = widget.option;
    final fontSize = global.typography.fontSizeRegular;
    final Color bg;
    if (_pressed && widget.onTap != null) {
      // `&:active`.
      bg = theme.colorAutoCompleteOptionBgActive;
    } else if (widget.focused) {
      // `&-focused` (hover and keyboard highlight share this fill).
      bg = theme.colorAutoCompleteOptionBgHover;
    } else {
      bg = const Color(0x00000000);
    }
    final Color textColor = option.disabled
        ? theme.colorAutoCompleteOptionDisabledText
        : theme.colorAutoCompleteOptionMainText;

    final Widget content;
    if (widget.renderItem != null) {
      content = widget.renderItem!(option);
    } else if (option.label != null) {
      content = option.label!;
    } else {
      // Keyword highlight of the built-in text (upstream `-keyword`).
      final inputText = widget.inputText;
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
                    color: theme.colorAutoCompleteOptionKeywordText,
                    fontWeight: theme.fontAutoCompleteKeywordFontWeight,
                  ),
                ),
              ],
      );
    }

    Widget box = Padding(
      padding: EdgeInsetsDirectional.only(
        start: theme.spacingAutoCompleteOptionPaddingLeft,
        top: theme.spacingAutoCompleteOptionPaddingTop,
        end: theme.spacingAutoCompleteOptionPaddingRight,
        bottom: theme.spacingAutoCompleteOptionPaddingBottom,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            // `&-selected`: `font-weight: $font-weight-bold`.
            fontWeight: widget.selected
                ? global.typography.fontWeightBold
                : null,
          ),
          child: content,
        ),
      ),
    );
    box = AnimatedContainer(
      duration: theme.transitionDurationAutoCompleteOptionBg,
      curve: theme.transitionFunctionAutoCompleteOptionBg,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(theme.radiusAutoCompleteOption),
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
/// the theme). See tool/generate_autocomplete.py for the 31 = 28 themed + 3
/// motion + 0 INTERNAL accounting; the hardcodes below are the 另列 entries.
abstract final class _AutoCompleteMetrics {
  /// `$color-popover-bg-default: var(--semi-color-bg-3)` in
  /// packages/semi-foundation/popover/variables.scss. The panel paints the
  /// Popover surface itself (upstream wraps the option list in `Popover`); the
  /// port resolves the background live from `theme.colors.colorBg3` instead.
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

  /// `$filter-popover-bg: none` in packages/semi-foundation/popover/variables.scss.
  /// Upstream `backdrop-filter` value is `none`, so no filter is applied.
  // ignore: unused_field
  static const String popoverFilterBg = 'none';

  /// `z-index: $z-popover` in packages/semi-foundation/popover/popover.scss,
  /// with `$z-popover: 1030` in packages/semi-theme-default/scss/variables.scss.
  /// Passed to [SemiTooltip.zIndex]; overlay insertion order decides stacking.
  static const int popoverZIndex = 1030;

  /// `opacity: 0` in packages/semi-foundation/popover/popover.scss
  /// (`&-wrapper`). Hidden until positioned; the port animates opacity
  /// through SemiTooltip's FadeTransition instead.
  // ignore: unused_field
  static const double popoverOpacityHidden = 0;

  /// `opacity: 1` in packages/semi-foundation/popover/popover.scss
  /// (`&-wrapper-show`). Shown state of the same rule.
  // ignore: unused_field
  static const double popoverOpacityShown = 1;

  /// `0 0 1px rgba(0, 0, 0, .3)` — first box-shadow layer of the
  /// `@include shadow-elevated` mixin
  /// (packages/semi-theme-default/scss/global.scss). Hardcoded to the light
  /// token values (see docs/semi_autocomplete.md).
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

  /// `height: 20px` in packages/semi-foundation/autoComplete/autoComplete.scss
  /// (`&-loading-wrapper`, "make sure that spin align vertical, no need to
  /// make 20px as a spacing token here").
  static const double loadingWrapperHeight = 20;

  /// `@include font-size-regular` in
  /// packages/semi-foundation/autoComplete/option.scss. The port reads the
  /// live `typography.fontSizeRegular` token (14 by default); the mixin
  /// provenance is recorded here.
  // ignore: unused_field
  static const double optionBaseFontSize = 14;

  /// `font-weight: $font-weight-bold` in
  /// packages/semi-foundation/autoComplete/option.scss (`&-selected`). The
  /// port reads the live `typography.fontWeightBold` (w600 by default).
  // ignore: unused_field
  static const String optionSelectedFontWeight =
      r'font-weight: $font-weight-bold';

  /// `overflow-x: hidden` in packages/semi-foundation/autoComplete/autoComplete.scss
  /// (`&-option-list`). Rendered by the panel `SingleChildScrollView`.
  // ignore: unused_field
  static const String optionListOverflowX = 'overflow-x: hidden';

  /// `overflow-y: auto` in packages/semi-foundation/autoComplete/autoComplete.scss
  /// (`&-option-list`). Rendered by the panel `SingleChildScrollView`.
  // ignore: unused_field
  static const String optionListOverflowY = 'overflow-y: auto';

  /// `maxHeight: 300` in packages/semi-ui/autocomplete/index.tsx
  /// (`defaultProps`). Default of [SemiAutoComplete.maxHeight].
  static const double maxHeightDefault = 300;
}
