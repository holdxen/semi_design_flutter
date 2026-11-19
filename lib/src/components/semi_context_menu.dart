import 'dart:async';
import 'dart:ui' show SemanticsRole;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../overlay/semi_anchor_popup.dart';
import '../theme/semi_context_menu_theme.dart';
import '../theme/semi_dropdown_theme_data.dart';
import '../theme/semi_tooltip_theme.dart';
import 'icon/semi_icons.dart';
import 'semi_menu_nodes.dart';
import 'semi_menu_surface.dart';

/// Radix `ContextMenuTrigger` touch/pen long-press timeout
/// (`context-menu.tsx`, `LONG_PRESS`).
const Duration kSemiContextMenuLongPressDelay = Duration(milliseconds: 700);

/// Radix `MenuSub` hover-open delay (`menu.tsx`, `openTimerRef`).
const Duration kSemiContextMenuSubmenuOpenDelay = Duration(milliseconds: 100);

/// Radix submenu grace-area validity (`menu.tsx`, grace timer). The polygon
/// grace is approximated by "submenus stay open while any menu row is hovered
/// or for this delay after the pointer left every row".
const Duration kSemiContextMenuSubmenuCloseDelay = Duration(milliseconds: 300);

/// Radix typeahead search-buffer reset (`menu.tsx`, `searchRef`).
const Duration kSemiContextMenuTypeaheadReset = Duration(milliseconds: 1000);

/// Radix `ContextMenuContent` default `sideOffset: 2`: the menu's preferred
/// corner sits 2px off the pointer point.
const double kSemiContextMenuAnchorGap = 2;

/// A right-click menu anchored at the pointer (Radix `@radix-ui/react-context-menu`).
///
/// Wraps [child] as the trigger area: a secondary tap (or a
/// [kSemiContextMenuLongPressDelay] long-press on touch/pen) opens the menu at
/// the pointer position. The [nodes] model is shared with [SemiDropdown]
/// (item/title/divider + checkbox/radio/submenu rows); visuals come from the
/// SemiDropdown menu tokens. See docs/semi_context_menu.md for the behavior
/// map and the difference list.
class SemiContextMenu extends StatefulWidget {
  const SemiContextMenu({
    super.key,
    required this.nodes,
    required this.child,
    this.enabled = true,
    this.showTick,
    this.closeOnEsc = true,
    this.motion = true,
    this.longPressEnabled = true,
    this.visible,
    this.onVisibleChange,
    this.onClickOutSide,
    this.onEscKeyDown,
  });

  /// Menu nodes (the [SemiDropdown] menu model, including
  /// [SemiDropdownCheckboxItemData]/[SemiDropdownRadioGroupData]/
  /// [SemiDropdownSubmenuItemData]).
  final List<SemiDropdownNode> nodes;

  /// The trigger subtree; the whole area is the context-menu target.
  final Widget child;

  /// When false the trigger never opens the menu (Radix
  /// `ContextMenuTrigger.disabled`).
  final bool enabled;

  /// Group-level tick column for plain rows; non-null wins over the row's own
  /// `showTick`. Checkable rows always reserve the column.
  final bool? showTick;

  /// Consume Escape and close while visible (Radix closes on Escape).
  final bool closeOnEsc;

  /// Whether the show/hide motion plays.
  final bool motion;

  /// Whether the touch/pen long-press gesture opens the menu.
  final bool longPressEnabled;

  /// Controlled visibility; non-null is fully controlled (interactions only
  /// report through [onVisibleChange]).
  final bool? visible;

  /// Reports visibility changes.
  final ValueChanged<bool>? onVisibleChange;

  /// Called before closing because of a press outside the menu tree.
  final VoidCallback? onClickOutSide;

  /// Called when Escape is consumed.
  final VoidCallback? onEscKeyDown;

  @override
  State<SemiContextMenu> createState() => _SemiContextMenuState();
}

class _SemiContextMenuState extends State<SemiContextMenu>
    with SingleTickerProviderStateMixin {
  /// Radix `claimedLongPressEvents` equivalent: the trigger claims its
  /// pointer-downs so the barrier's outside-press dismissal can never race the
  /// trigger's own open/re-anchor (order-independent, see
  /// [_handleBarrierDown]). Keyed by (pointer, timeStamp) because hit-test
  /// entry transforms copy the event per listener — object identity is not
  /// shared across the same physical press.
  Duration? _claimedDownTime;
  int _claimedDownPointer = -1;

  bool _claimed(PointerDownEvent event) =>
      _claimedDownTime == event.timeStamp &&
      _claimedDownPointer == event.pointer;

  void _claim(PointerDownEvent event) {
    _claimedDownTime = event.timeStamp;
    _claimedDownPointer = event.pointer;
  }

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
    value: 1,
  );
  CurvedAnimation? _fade;
  final GlobalKey _triggerKey = GlobalKey();

  bool _visible = false;
  bool _showScheduled = false;
  OverlayEntry? _entry;
  CapturedThemes? _captured;
  final GlobalKey _stackKey = GlobalKey();

  /// Global pointer anchor of the root menu.
  Offset _anchor = Offset.zero;

  /// Whether [_anchor] came from a real pointer interaction. Controlled
  /// `visible: true` without one falls back to the trigger center (Radix
  /// dev-warns and anchors at the viewport origin).
  bool _anchorSet = false;

  /// Overlay-local origin of the entry stack (global → local conversion).
  Offset _entryOrigin = Offset.zero;

  Size _viewport = Size.zero;

  /// Open menu chain: root at 0, one entry per open submenu level.
  final List<_MenuLevel> _levels = <_MenuLevel>[];

  /// Mirrors Radix `isUsingKeyboardRef`: keyboard highlight visuals only
  /// appear after real keyboard use (the `:focus-visible` rule).
  bool _keyboardUsed = false;

  String _typeaheadBuffer = '';
  Timer? _typeaheadTimer;
  Timer? _longPressTimer;
  Timer? _subOpenTimer;
  Timer? _subCloseTimer;
  int _hoveredRowCount = 0;

  bool get _isControlled => widget.visible != null;

  bool get _effectiveVisible => widget.visible ?? _visible;

  /// Rebuilds the trigger and the overlay entry. The entry is built by the
  /// [OverlayEntry] builder, not by this State's [build], so a plain
  /// [setState] alone never repaints the menu tree.
  void _refresh() {
    setState(() {});
    _entry?.markNeedsBuild();
  }

  @override
  void initState() {
    super.initState();
    if (_effectiveVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_effectiveVisible) return;
        if (_entry == null && !_showScheduled) _show();
      });
    }
  }

  @override
  void didUpdateWidget(covariant SemiContextMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible != widget.visible) {
      if (_effectiveVisible) {
        if (_entry == null && !_showScheduled) {
          _show();
        } else {
          // May still be animating out; play back in.
          _controller.forward();
        }
      } else if (_entry != null || _showScheduled) {
        _hide();
      }
    }
  }

  @override
  void dispose() {
    _cancelTimers();
    _entry?.remove();
    _entry = null;
    _disposeLevels();
    _controller.dispose();
    super.dispose();
  }

  void _cancelTimers() {
    _typeaheadTimer?.cancel();
    _longPressTimer?.cancel();
    _subOpenTimer?.cancel();
    _subCloseTimer?.cancel();
    _typeaheadTimer = null;
    _longPressTimer = null;
    _subOpenTimer = null;
    _subCloseTimer = null;
  }

  void _disposeLevels() {
    for (final level in _levels) {
      level.focus.dispose();
    }
    _levels.clear();
  }

  // -- visibility -----------------------------------------------------------

  void _show() {
    if (_entry != null) {
      // Re-shown during the hide animation: keep the entry, play in again.
      _controller.forward();
      return;
    }
    if (_showScheduled) return;
    _showScheduled = true;
    // Deferred like SemiTooltip: prop-driven shows must not mutate the
    // overlay during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showScheduled = false;
      if (!mounted || _entry != null || !_effectiveVisible) return;
      _insertOverlay();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _insertOverlay() {
    _captured = InheritedTheme.capture(
      from: context,
      to: Overlay.of(context).context,
    );
    if (!_anchorSet) {
      final box =
          _triggerKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        _anchor = (box.localToGlobal(Offset.zero) & box.size).center;
      }
    }
    _disposeLevels();
    _levels.add(_MenuLevel(widget.nodes));
    _keyboardUsed = false;
    _typeaheadBuffer = '';
    final tooltipTheme = SemiTooltipTheme.resolve(context);
    _controller.duration = tooltipTheme.animationDurationIn;
    _fade = CurvedAnimation(
      parent: _controller,
      curve: tooltipTheme.animationFunctionIn,
      reverseCurve: tooltipTheme.animationFunctionOut,
    );
    _controller.forward(from: 0);
    _entry = OverlayEntry(builder: _buildEntry);
    Overlay.of(context).insert(_entry!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _measure();
      // Radix focuses the content on open; keyboard events route to the
      // deepest open level from then on.
      if (_levels.isNotEmpty) _levels.first.focus.requestFocus();
    });
  }

  void _hide() {
    _cancelTimers();
    if (_entry == null) return;
    if (!widget.motion) {
      _removeOverlay();
      return;
    }
    final tooltipTheme = SemiTooltipTheme.resolve(context);
    _controller.duration = tooltipTheme.animationDurationOut;
    _controller.reverse(from: _controller.value).whenCompleteOrCancel(() {
      if (_entry != null && !_effectiveVisible) _removeOverlay();
    });
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
    _fade?.dispose();
    _fade = null;
    _disposeLevels();
    _hoveredRowCount = 0;
  }

  void _requestShow(Offset point) {
    _anchor = point;
    _anchorSet = true;
    if (_isControlled) {
      if (widget.visible != true) {
        widget.onVisibleChange?.call(true);
      } else {
        // Controlled and visible: re-anchor and collapse submenus.
        _refresh();
        _closeLevelsFrom(1);
      }
      return;
    }
    if (_effectiveVisible) {
      // Re-anchor while open (Radix issue #2611 behavior).
      _refresh();
      _closeLevelsFrom(1);
      return;
    }
    _visible = true;
    widget.onVisibleChange?.call(true);
    _show();
  }

  void _requestHide({bool outside = false}) {
    _cancelTimers();
    if (outside) widget.onClickOutSide?.call();
    if (_isControlled) {
      if (widget.visible != false) widget.onVisibleChange?.call(false);
      return;
    }
    if (!_effectiveVisible && _entry == null) return;
    _visible = false;
    widget.onVisibleChange?.call(false);
    _hide();
  }

  // -- trigger gestures -----------------------------------------------------

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.enabled) return;
    final secondary = event.buttons & kSecondaryMouseButton != 0;
    final touchLike =
        event.kind == PointerDeviceKind.touch ||
        event.kind == PointerDeviceKind.stylus;
    if (secondary) {
      _claim(event);
      _longPressTimer?.cancel();
      _requestShow(event.position);
      return;
    }
    if (touchLike && widget.longPressEnabled) {
      _longPressTimer?.cancel();
      final start = event.position;
      _longPressTimer = Timer(kSemiContextMenuLongPressDelay, () {
        if (!mounted) return;
        _requestShow(start);
      });
    }
  }

  void _handleBarrierDown(PointerDownEvent event) {
    if (_claimed(event)) return;
    // Deferred one microtask: a trigger claiming this press may run after us
    // in the same dispatch; the microtask sees the final claim state, so
    // open/re-anchor always wins over dismissal regardless of hit-test order.
    scheduleMicrotask(() {
      if (!mounted) return;
      if (_claimed(event)) return;
      _requestHide(outside: true);
    });
  }

  // -- level helpers --------------------------------------------------------

  bool _rowDisabled(_MenuLevel level, int rowIndex) {
    final ref = level.rows[rowIndex];
    return switch (level.nodes[ref.nodeIndex]) {
      SemiDropdownItemData(:final disabled) => disabled,
      SemiDropdownCheckboxItemData(:final disabled) => disabled,
      SemiDropdownSubmenuItemData(:final disabled) => disabled,
      SemiDropdownRadioGroupData(:final children) =>
        children[ref.radioIndex!].disabled,
      _ => true,
    };
  }

  bool _rowIsSubmenu(_MenuLevel level, int rowIndex) =>
      level.nodes[level.rows[rowIndex].nodeIndex] is SemiDropdownSubmenuItemData;

  String? _rowText(_MenuLevel level, int rowIndex) {
    final ref = level.rows[rowIndex];
    return switch (level.nodes[ref.nodeIndex]) {
      SemiDropdownItemData(:final name) => semiMenuRowText(name),
      SemiDropdownCheckboxItemData(:final name) => semiMenuRowText(name),
      SemiDropdownSubmenuItemData(:final name) => semiMenuRowText(name),
      SemiDropdownRadioGroupData(:final children) =>
        semiMenuRowText(children[ref.radioIndex!].name),
      _ => null,
    };
  }

  List<int> _enabledRowIndexes(_MenuLevel level) => [
    for (var i = 0; i < level.rows.length; i++)
      if (!_rowDisabled(level, i)) i,
  ];

  Rect? _rowRect(_MenuLevel level, int rowIndex) {
    final box =
        level.rowKeys[rowIndex]?.currentContext?.findRenderObject()
            as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  List<Rect> _exemptRects() {
    final rects = <Rect>[];
    for (final level in _levels) {
      final box =
          level.surfaceKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        rects.add(box.localToGlobal(Offset.zero) & box.size);
      }
    }
    return rects;
  }

  // -- submenu orchestration ------------------------------------------------

  void _onRowEnter(_MenuLevel level, int rowIndex) {
    _hoveredRowCount += 1;
    _subCloseTimer?.cancel();
    final levelIndex = _levels.indexOf(level);
    if (levelIndex < 0) return;
    if (level.highlight != rowIndex) {
      // Focus-follows-pointer: highlight tracks hover (drawn only after
      // keyboard use).
      level.highlight = rowIndex;
      _refresh();
    }
    // Hovering a different row closes the open child immediately (Radix).
    if (levelIndex + 1 < _levels.length) {
      final child = _levels[levelIndex + 1];
      if (!(identical(child.parent, level) && child.parentRow == rowIndex)) {
        _closeLevelsFrom(levelIndex + 1);
      }
    }
    if (_rowIsSubmenu(level, rowIndex) && !_rowDisabled(level, rowIndex)) {
      _subOpenTimer?.cancel();
      _subOpenTimer = Timer(kSemiContextMenuSubmenuOpenDelay, () {
        if (!mounted) return;
        _openSubmenu(level, rowIndex, viaKeyboard: false);
      });
    }
  }

  void _onRowExit(_MenuLevel level, int rowIndex) {
    _hoveredRowCount = _hoveredRowCount > 0 ? _hoveredRowCount - 1 : 0;
    _subOpenTimer?.cancel();
    if (_hoveredRowCount == 0) {
      // Grace period: keep submenus open while the pointer travels toward
      // them (Radix grace-area equivalent).
      _subCloseTimer?.cancel();
      _subCloseTimer = Timer(kSemiContextMenuSubmenuCloseDelay, () {
        if (!mounted) return;
        _closeLevelsFrom(1);
      });
    }
  }

  void _openSubmenu(_MenuLevel level, int rowIndex, {required bool viaKeyboard}) {
    final levelIndex = _levels.indexOf(level);
    if (levelIndex < 0) return;
    _closeLevelsFrom(levelIndex + 1);
    final ref = level.rows[rowIndex];
    final node = level.nodes[ref.nodeIndex];
    if (node is! SemiDropdownSubmenuItemData || node.disabled) return;
    final rowRect = _rowRect(level, rowIndex);
    if (rowRect == null) return;
    final child = _MenuLevel(node.children, parent: level, parentRow: rowIndex)
      ..rowAnchor = rowRect;
    _levels.add(child);
    _refresh();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _measure();
      child.focus.requestFocus();
      if (viaKeyboard && _keyboardUsed) {
        final first = _enabledRowIndexes(child);
        if (first.isNotEmpty) _moveHighlight(child, first.first);
      }
    });
  }

  void _toggleSubmenu(_MenuLevel level, int rowIndex, {required bool viaKeyboard}) {
    final levelIndex = _levels.indexOf(level);
    if (levelIndex < 0) return;
    final openChild = levelIndex + 1 < _levels.length
        ? _levels[levelIndex + 1]
        : null;
    if (openChild != null &&
        identical(openChild.parent, level) &&
        openChild.parentRow == rowIndex) {
      _closeLevelsFrom(levelIndex + 1);
      return;
    }
    _openSubmenu(level, rowIndex, viaKeyboard: viaKeyboard);
  }

  void _closeLevelsFrom(int index) {
    if (index < 0 || index >= _levels.length) return;
    for (var i = index; i < _levels.length; i++) {
      _levels[i].focus.dispose();
    }
    _levels.removeRange(index, _levels.length);
    _refresh();
  }

  // -- keyboard model -------------------------------------------------------

  void _moveHighlight(_MenuLevel level, int rowIndex) {
    _keyboardUsed = true;
    level.highlight = rowIndex;
    _refresh();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = level.rowKeys[rowIndex]?.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(context, alignment: 0.5);
      }
    });
  }

  void _activateRow(
    _MenuLevel level,
    int rowIndex, {
    required bool viaKeyboard,
  }) {
    final ref = level.rows[rowIndex];
    switch (level.nodes[ref.nodeIndex]) {
      case SemiDropdownItemData(:final onTap):
        onTap?.call();
        _requestHide();
      case SemiDropdownCheckboxItemData(
        :final indeterminate,
        :final checked,
        :final onCheckedChange,
      ):
        // Radix: `indeterminate` activates to `true`; `onCheckedChange`
        // never receives `indeterminate`.
        onCheckedChange?.call(indeterminate ? true : !checked);
        _requestHide();
      case SemiDropdownRadioGroupData(:final children, :final onValueChange):
        onValueChange?.call(children[ref.radioIndex!].value);
        _requestHide();
      case SemiDropdownSubmenuItemData():
        _toggleSubmenu(level, rowIndex, viaKeyboard: viaKeyboard);
      default:
        _requestHide();
    }
  }

  void _activateHighlighted(_MenuLevel level) {
    final highlight = level.highlight;
    if (highlight == null || _rowDisabled(level, highlight)) return;
    _activateRow(level, highlight, viaKeyboard: true);
  }

  int? _findTypeaheadMatch(_MenuLevel level) {
    final enabled = _enabledRowIndexes(level);
    if (_typeaheadBuffer.isEmpty || enabled.isEmpty) return null;
    // Radix `getNextMatch` nuance: a buffer of one repeated character keeps
    // matching that single character (cycles through its rows).
    final buffer = _typeaheadBuffer.runes.toSet().length == 1
        ? _typeaheadBuffer.substring(0, 1)
        : _typeaheadBuffer;
    final current = level.highlight == null
        ? -1
        : enabled.indexOf(level.highlight!);
    // Radix `getNextMatch`: the current row keeps focus while it still
    // matches the typed search (so 'b' then 'r' stays on 'Bravo').
    if (current >= 0) {
      final currentText = _rowText(level, enabled[current])?.toLowerCase();
      if (currentText != null && currentText.startsWith(buffer)) {
        return enabled[current];
      }
    }
    for (var step = 1; step <= enabled.length; step++) {
      final rowIndex = enabled[(current + step) % enabled.length];
      final text = _rowText(level, rowIndex)?.toLowerCase();
      if (text != null && text.startsWith(buffer)) return rowIndex;
    }
    return null;
  }

  KeyEventResult _handleKey(_MenuLevel level, FocusNode node, KeyEvent event) {
    final isDown = event is KeyDownEvent;
    if (!isDown && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    // Escape closes the whole tree (Radix closes the root menu, not just the
    // focused sub) and keeps propagating when `closeOnEsc` is off.
    if (key == LogicalKeyboardKey.escape) {
      if (!isDown) return KeyEventResult.handled;
      if (widget.closeOnEsc) {
        widget.onEscKeyDown?.call();
        _requestHide();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    // Menus are not tab-navigated (Radix prevents Tab).
    if (key == LogicalKeyboardKey.tab) {
      return KeyEventResult.handled;
    }
    final enabled = _enabledRowIndexes(level);
    if (enabled.isEmpty) return KeyEventResult.ignored;
    final highlight = level.highlight;
    final position = highlight == null ? -1 : enabled.indexOf(highlight);
    final isSpace = key == LogicalKeyboardKey.space;
    if (key == LogicalKeyboardKey.enter ||
        (isSpace && _typeaheadBuffer.isEmpty)) {
      if (!isDown) return KeyEventResult.handled;
      _activateHighlighted(level);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _moveHighlight(
        level,
        enabled[position == -1 ? 0 : (position + 1) % enabled.length],
      );
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _moveHighlight(
        level,
        enabled[position == -1 ? enabled.length - 1 : (position - 1 + enabled.length) % enabled.length],
      );
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home && enabled.isNotEmpty) {
      _moveHighlight(level, enabled.first);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end && enabled.isNotEmpty) {
      _moveHighlight(level, enabled.last);
      return KeyEventResult.handled;
    }
    // Submenu keys are direction-aware (Radix SUB_OPEN_KEYS/SUB_CLOSE_KEYS).
    final openKey = rtl ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowRight;
    final closeKey = rtl ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft;
    if (key == openKey) {
      if (highlight != null &&
          _rowIsSubmenu(level, highlight) &&
          !_rowDisabled(level, highlight)) {
        _toggleSubmenu(level, highlight, viaKeyboard: true);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    if (key == closeKey) {
      final levelIndex = _levels.indexOf(level);
      if (level.parent == null || levelIndex <= 0) {
        return KeyEventResult.ignored;
      }
      final parent = level.parent!;
      final parentRow = level.parentRow!;
      _closeLevelsFrom(levelIndex);
      parent.highlight = parentRow;
      parent.focus.requestFocus();
      return KeyEventResult.handled;
    }
    // Typeahead (Radix printable-character search, 1000ms buffer).
    if (isDown && event.character != null) {
      final character = event.character!;
      if (character.length == 1 &&
          (character.trim().isNotEmpty || _typeaheadBuffer.isNotEmpty)) {
        _typeaheadBuffer += character.toLowerCase();
        _typeaheadTimer?.cancel();
        _typeaheadTimer = Timer(kSemiContextMenuTypeaheadReset, () {
          _typeaheadBuffer = '';
        });
        final match = _findTypeaheadMatch(level);
        if (match != null) _moveHighlight(level, match);
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // -- entry rendering ------------------------------------------------------

  Widget _buildEntry(BuildContext entryContext) {
    final theme = SemiContextMenuTheme.resolve(entryContext);
    return _captured!.wrap(
      LayoutBuilder(
        builder: (context, constraints) {
          _viewport = constraints.biggest;
          WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
          return Stack(
            key: _stackKey,
            clipBehavior: Clip.none,
            children: [
              SemiMenuBarrier(
                onDismiss: _handleBarrierDown,
                exemptRects: _exemptRects,
              ),
              for (final level in _levels) _buildLevel(theme, level),
            ],
          );
        },
      ),
    );
  }

  Offset _positionFor(_MenuLevel level, Size size) {
    if (level.parent == null) {
      return semiPositionAtPoint(
        popupSize: size,
        point: _anchor - _entryOrigin,
        viewport: _viewport,
        gap: kSemiContextMenuAnchorGap,
      );
    }
    return semiPositionAtRect(
      popupSize: size,
      anchorRect: (level.rowAnchor ?? Rect.zero).shift(-_entryOrigin),
      viewport: _viewport,
      rtl: Directionality.maybeOf(context) == TextDirection.rtl,
      gap: kSemiContextMenuAnchorGap,
    );
  }

  void _measure() {
    if (!mounted) return;
    var changed = false;
    final stackBox =
        _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox != null && stackBox.hasSize) {
      final origin = stackBox.localToGlobal(Offset.zero);
      if (origin != _entryOrigin) {
        _entryOrigin = origin;
        changed = true;
      }
      if (stackBox.size != _viewport) {
        _viewport = stackBox.size;
        changed = true;
      }
    }
    for (final level in _levels) {
      final box =
          level.surfaceKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;
      final size = box.size;
      if (size != level.measured) {
        level.measured = size;
        changed = true;
      }
      final topLeft = _positionFor(level, size);
      if (topLeft != level.topLeft) {
        level.topLeft = topLeft;
        changed = true;
      }
    }
    if (changed) _refresh();
  }

  Widget _buildLevel(SemiResolvedDropdownThemeData theme, _MenuLevel level) {
    // Render every node in order; only interactive nodes occupy a row index
    // of [level.rows] (titles and dividers are layout-only).
    final children = <Widget>[];
    var rowCursor = 0;
    for (final node in level.nodes) {
      switch (node) {
        case SemiDropdownTitleData(:final name):
          children.add(
            SemiMenuTitleRow(
              theme: theme,
              name: name,
              showTickColumn: widget.showTick ?? level.hasCheckable,
            ),
          );
        case SemiDropdownDividerData():
          children.add(SemiMenuDivider(theme: theme));
        case SemiDropdownRadioGroupData(children: final radioChildren):
          for (var i = 0; i < radioChildren.length; i++) {
            children.add(_buildRow(theme, level, rowCursor + i));
          }
          rowCursor += radioChildren.length;
        default:
          children.add(_buildRow(theme, level, rowCursor));
          rowCursor += 1;
      }
    }
    Widget content = Focus(
      focusNode: level.focus,
      onKeyEvent: (node, event) => _handleKey(level, node, event),
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        // `role="menu"` cannot be empty (Flutter semantics validation).
        role: level.rows.isEmpty ? null : SemanticsRole.menu,
        child: SemiMenuSurface(theme: theme, children: children),
      ),
    );
    content = KeyedSubtree(key: level.surfaceKey, child: content);
    // Hidden until measured (chrome-tab popup idiom: no first-frame flicker).
    if (level.measured == null) {
      content = IgnorePointer(child: Opacity(opacity: 0, child: content));
    }
    if (widget.motion) {
      final fade = _fade;
      if (fade != null) {
        content = FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: SemiTooltipTheme.resolve(context).zoomScaleFrom,
              end: 1,
            ).animate(fade),
            alignment: Alignment.topLeft,
            child: content,
          ),
        );
      }
    }
    final topLeft = level.measured == null ? Offset.zero : level.topLeft;
    return Positioned(left: topLeft.dx, top: topLeft.dy, child: content);
  }

  Widget _buildRow(
    SemiResolvedDropdownThemeData theme,
    _MenuLevel level,
    int rowIndex,
  ) {
    final ref = level.rows[rowIndex];
    final node = level.nodes[ref.nodeIndex];
    final disabled = _rowDisabled(level, rowIndex);
    final highlighted = _keyboardUsed && level.highlight == rowIndex;
    final rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    void onTap() => _activateRow(level, rowIndex, viaKeyboard: false);
    void onEnter() => _onRowEnter(level, rowIndex);
    void onExit() => _onRowExit(level, rowIndex);
    return KeyedSubtree(
      key: level.rowKeys.putIfAbsent(rowIndex, () => GlobalKey()),
      child: switch (node) {
        SemiDropdownItemData(:final name, :final icon, :final active, :final type, :final showTick) =>
          SemiMenuRow(
            theme: theme,
            name: name,
            icon: icon,
            showTickColumn: widget.showTick ?? showTick ?? level.hasCheckable,
            active: active,
            disabled: disabled,
            type: type,
            role: SemanticsRole.menuItem,
            highlighted: highlighted,
            onTap: disabled ? null : onTap,
            onHoverEnter: onEnter,
            onHoverExit: onExit,
          ),
        SemiDropdownCheckboxItemData(
          :final name,
          :final icon,
          :final checked,
          :final indeterminate,
          :final type,
        ) =>
          SemiMenuRow(
            theme: theme,
            name: name,
            icon: icon,
            showTickColumn: true,
            indicator: indeterminate
                ? SemiMenuIndicator.indeterminate
                : checked
                ? SemiMenuIndicator.tick
                : SemiMenuIndicator.none,
            disabled: disabled,
            type: type,
            role: SemanticsRole.menuItemCheckbox,
            checked: indeterminate ? null : checked,
            mixed: indeterminate ? true : null,
            highlighted: highlighted,
            onTap: disabled ? null : onTap,
            onHoverEnter: onEnter,
            onHoverExit: onExit,
          ),
        SemiDropdownRadioGroupData() => () {
          final radio = node.children[ref.radioIndex!];
          final checked = radio.value == node.value;
          return SemiMenuRow(
            theme: theme,
            name: radio.name,
            icon: radio.icon,
            showTickColumn: true,
            indicator: checked ? SemiMenuIndicator.tick : SemiMenuIndicator.none,
            disabled: disabled,
            type: radio.type,
            role: SemanticsRole.menuItemRadio,
            checked: checked,
            highlighted: highlighted,
            onTap: disabled ? null : onTap,
            onHoverEnter: onEnter,
            onHoverExit: onExit,
          );
        }(),
        SemiDropdownSubmenuItemData(:final name, :final icon, :final type, :final showTick) =>
          SemiMenuRow(
            theme: theme,
            name: name,
            icon: icon,
            showTickColumn: widget.showTick ?? showTick ?? level.hasCheckable,
            disabled: disabled,
            type: type,
            role: SemanticsRole.menuItem,
            highlighted: highlighted,
            trailingIcon: rtl ? SemiIcons.chevronLeft : SemiIcons.chevronRight,
            onTap: disabled ? null : onTap,
            onHoverEnter: onEnter,
            onHoverExit: onExit,
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _handlePointerDown,
      onPointerMove: (_) => _longPressTimer?.cancel(),
      onPointerUp: (_) => _longPressTimer?.cancel(),
      onPointerCancel: (_) => _longPressTimer?.cancel(),
      child: KeyedSubtree(key: _triggerKey, child: widget.child),
    );
  }
}

/// One open menu level (root or submenu).
class _MenuLevel {
  _MenuLevel(this.nodes, {this.parent, this.parentRow})
    : rows = _flattenRows(nodes);

  final List<SemiDropdownNode> nodes;
  final List<_MenuRowRef> rows;
  final _MenuLevel? parent;
  final int? parentRow;

  final GlobalKey surfaceKey = GlobalKey();
  final FocusNode focus = FocusNode();
  final Map<int, GlobalKey> rowKeys = <int, GlobalKey>{};

  /// Global rect of the parent row (submenu anchor).
  Rect? rowAnchor;

  Size? measured;
  Offset topLeft = Offset.zero;
  int? highlight;

  /// Whether any checkbox/radio row lives on this level (tick column rule).
  late final bool hasCheckable = nodes.any(
    (node) =>
        node is SemiDropdownCheckboxItemData ||
        node is SemiDropdownRadioGroupData,
  );

  static List<_MenuRowRef> _flattenRows(List<SemiDropdownNode> nodes) {
    final rows = <_MenuRowRef>[];
    for (var i = 0; i < nodes.length; i++) {
      switch (nodes[i]) {
        case SemiDropdownRadioGroupData(:final children):
          for (var r = 0; r < children.length; r++) {
            rows.add(_MenuRowRef(i, radioIndex: r));
          }
        case SemiDropdownItemData():
        case SemiDropdownCheckboxItemData():
        case SemiDropdownSubmenuItemData():
          rows.add(_MenuRowRef(i));
        case SemiDropdownTitleData():
        case SemiDropdownDividerData():
          break;
      }
    }
    return rows;
  }
}

/// A keyboard-navigable row: node index plus the radio child index when the
/// node is a [SemiDropdownRadioGroupData].
class _MenuRowRef {
  const _MenuRowRef(this.nodeIndex, {this.radioIndex});

  final int nodeIndex;
  final int? radioIndex;
}
