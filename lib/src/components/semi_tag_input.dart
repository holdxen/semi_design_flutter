import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../overlay/tooltip_positioning.dart';
import '../theme/semi_tag_input_theme.dart';
import '../theme/semi_tag_input_theme_data.dart';
import '../theme/semi_theme.dart';
import '../theme/semi_theme_data.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icons.dart';
import 'semi_input.dart';
import 'semi_tag.dart';
import 'semi_tooltip.dart';

/// Imperative handle for the tag input (upstream ref methods `focus`/`blur` in
/// packages/semi-ui/tagInput/index.tsx). Attach/detach is maintained by the
/// [SemiTagInput] state; both methods are no-ops while detached (the
/// SemiPinCodeController pattern).
class SemiTagInputController {
  _SemiTagInputState? _state;

  /// Focuses the inner input (upstream `focus`: `inputRef.focus()`).
  void focus() {
    _state?._focusInput();
  }

  /// Blurs the inner input (upstream `blur`).
  void blur() {
    _state?._blurInput();
  }

  void _attach(_SemiTagInputState state) {
    _state = state;
  }

  void _detach(_SemiTagInputState state) {
    if (identical(_state, state)) _state = null;
  }
}

/// A source-sized, non-Material tag input (upstream Semi TagInput): a wrapping
/// tag list plus a bare inline input, driven by
/// packages/semi-foundation/tagInput/foundation.ts.
///
/// `value != null` makes the tags controlled (the project-wide convention):
/// the display follows [value] and edits only emit callbacks. Releasing
/// control retains the last controlled value; entering control preserves the
/// local buffer. [inputValue] is semi-controlled the same way for the input
/// line. Uncontrolled tags seed from [defaultValue]; the input seeds empty.
///
/// Port notes (see docs/semi_tag_input.md for the full difference list):
/// ★ Upstream GDSFP treats a falsy-but-present `value` key as `[]` — not
/// ported (Dart has no present-but-null; 差异清单). ★ Upstream `active`
/// (click inside the root / cleared by click-outside) is approximated by
/// subtree FOCUS (差异清单). ★ The `+N` chip color is hardcoded
/// `var(--semi-color-text-0)` upstream and stays hardcoded here.
class SemiTagInput extends StatefulWidget {
  const SemiTagInput({
    super.key,
    this.value,
    this.defaultValue,
    this.inputValue,
    this.onChanged,
    this.onAdd,
    this.onRemove,
    this.onInputChange,
    this.onExceed,
    this.onInputExceed,
    this.separator = ',',
    this.split,
    this.allowDuplicates = true,
    this.max,
    this.maxLength,
    this.disabled = false,
    this.showClear = false,
    this.clearIcon,
    this.placeholder,
    this.maxTagCount,
    this.showRestTagsPopover = true,
    this.showContentTooltip = true,
    this.addOnBlur = false,
    this.renderTagItem,
    this.expandRestTagsOnClick = true,
    this.draggable = false,
    this.prefix,
    this.suffix,
    this.insetLabel,
    this.validateStatus = SemiInputStatus.normal,
    this.size = SemiInputSize.normal,
    this.onBlur,
    this.onFocusChange,
    this.autofocus = false,
    this.semanticsLabel,
    this.controller,
  }) : assert(
         separator == null ||
             separator is String ||
             separator is num ||
             separator is List<String>,
         'separator must be a String, a num, a List<String> or null.',
       );

  /// Key of the outermost box.
  static const Key rootKey = ValueKey('SemiTagInput.root');

  /// Key of the clear button slot.
  static const Key clearButtonKey = ValueKey('SemiTagInput.clearButton');

  /// Key of the "+N" fold chip.
  static const Key nTagKey = ValueKey('SemiTagInput.nTag');

  /// Key of the rendered tag slot at [index].
  static Key tagKey(int index) => Key('SemiTagInput.tag$index');

  /// Key of the drag handle at [index].
  static Key dragHandleKey(int index) => Key('SemiTagInput.handle$index');

  /// Non-null makes the tags controlled (the project-wide convention).
  final List<String>? value;

  /// Seed of the uncontrolled tags state (upstream `defaultValue`).
  final List<String>? defaultValue;

  /// Non-null makes the input line controlled the same way (upstream
  /// `inputValue`).
  final String? inputValue;

  /// Reports every tag-list change with the FULL new array (no diff gating,
  /// no onSort — a drag reorder fires exactly one call at drop).
  final ValueChanged<List<String>>? onChanged;

  /// Reports the batch of tags added (upstream `onAdd`).
  final ValueChanged<List<String>>? onAdd;

  /// Reports `(value, index)` per removed tag (upstream `onRemove`).
  final void Function(String value, int index)? onRemove;

  /// Reports every input-line edit (upstream `onInputChange`; ★ the IME
  /// composition-end write skips it — the Firefox workaround).
  final ValueChanged<String>? onInputChange;

  /// Reports the full attempted tag list when [max] truncates it.
  final ValueChanged<List<String>>? onExceed;

  /// Reports the full attempted input string when [maxLength] rejects or
  /// truncates a segment.
  final ValueChanged<String>? onInputExceed;

  /// Segment separator: a String or num (split on its string form), a
  /// `List<String>` (separators[1..] folded into separators[0], then split
  /// once — getSplitedArray) or null (single item).
  final Object? separator;

  /// Custom splitter overriding [separator] (upstream `split`).
  final List<String> Function(String text, Object? separator)? split;

  /// ★ Defaults to true upstream: duplicates are only dropped when false
  /// (existing tags AND repeats within the same batch — keep first).
  final bool allowDuplicates;

  /// Tag cap: over-cap adds fire [onExceed] with the full attempted list and
  /// truncate the tail silently.
  final int? max;

  /// Per-segment length cap: growing segments past it are rejected (editing)
  /// or truncated (IME composition end); see [onInputExceed].
  final int? maxLength;

  final bool disabled;

  /// Shows the 32px clear slot (visible only while hovering, non-empty and
  /// enabled).
  final bool showClear;

  /// Custom clear icon rendered as-is (defaults to `SemiIcons.clear`).
  final Widget? clearIcon;

  /// Shown only while there are NO tags (upstream swaps it for `''`).
  final String? placeholder;

  /// Visible-tag cap with a `+N` fold chip (upstream `maxTagCount`; null/0
  /// disable folding like upstream's truthiness check).
  final int? maxTagCount;

  /// Wraps the `+N` chip in a hover tooltip listing the folded tags.
  final bool showRestTagsPopover;

  /// Upstream `showContentTooltip` — an ellipsis tooltip on the default tag
  /// label; approximated as a hover tooltip carrying the full value
  /// (differences list).
  final bool showContentTooltip;

  /// Upstream `addOnBlur` — blurring the input line commits the pending text
  /// through the full add flow (foundation.ts:213-220), including the
  /// empty-input `onInputChange('')` side effect.
  final bool addOnBlur;

  /// Upstream `renderTagItem(value, index, onClose)` — replaces the default
  /// tag render (drag-handle slot still wraps it when [draggable]).
  final Widget Function(String value, int index, VoidCallback onClose)?
  renderTagItem;

  /// Releases the fold while focused (upstream `expandRestTagsOnClick`; the
  /// upstream `active` gate is approximated by focus).
  final bool expandRestTagsOnClick;

  /// Shows a per-tag drag handle while focused (upstream `draggable`).
  final bool draggable;

  /// Start-side slot; wins over [insetLabel] (upstream `prefix || insetLabel`).
  final Object? prefix;

  /// End-side slot.
  final Object? suffix;

  /// Start-side slot (when [prefix] is null); strings render bold.
  final Object? insetLabel;

  /// Upstream `validateStatus` — warning/danger rows have visuals; success has
  /// none upstream (rendered as normal).
  final SemiInputStatus validateStatus;

  /// Small / normal / large (upstream `'small' | 'default' | 'large'`).
  final SemiInputSize size;

  /// Fired when the input loses focus (upstream passes the event — clipped).
  final VoidCallback? onBlur;

  final ValueChanged<bool>? onFocusChange;
  final bool autofocus;

  /// Input semantics label (upstream `aria-label`).
  final String? semanticsLabel;

  /// Imperative focus handle; never disposed by the widget.
  final SemiTagInputController? controller;

  @override
  State<SemiTagInput> createState() => _SemiTagInputState();
}

class _SemiTagInputState extends State<SemiTagInput> {
  late final TextEditingController _textController;
  late final FocusNode _inputFocusNode = FocusNode(
    debugLabel: 'SemiTagInput',
    onKeyEvent: _handleInputKey,
  );
  final FocusNode _rootFocusNode = FocusNode(debugLabel: 'SemiTagInput.root');
  final GlobalKey _stackKey = GlobalKey();
  final Map<int, GlobalKey> _tagKeys = {};

  List<String> _tagsBuffer = const [];
  String _inputBuffer = '';

  /// Upstream `hovering` (root mouse hover).
  bool _hovering = false;
  bool _clearHovered = false;

  /// ★ Upstream `active`/`focusing` (`-focus` class = focusing || active) —
  /// approximated by subtree focus (差异清单).
  bool _active = false;

  /// Upstream `entering` — IME composition session; only tracked while
  /// [SemiTagInput.maxLength] is set (foundation.ts handleInputComposition*).
  bool _entering = false;
  bool _composing = false;
  bool _programmatic = false;

  // Drag session (upstream dnd-kit Sortable).
  int? _dragIndex;
  int _dropIndex = -1;
  Offset _grabDelta = Offset.zero;
  Offset? _overlayOffset;

  @override
  void initState() {
    super.initState();
    _tagsBuffer = widget.defaultValue ?? const [];
    _textController = TextEditingController(text: widget.inputValue ?? '');
    _textController.addListener(_handleTextTick);
    widget.controller?._attach(this);
    if (widget.autofocus && !widget.disabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusInput();
      });
    }
  }

  @override
  void didUpdateWidget(SemiTagInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
    // SemiRating convention (semi_rating.dart:122-129): releasing control
    // retains the last controlled value instead of resetting.
    if (oldWidget.value != null && widget.value == null) {
      _tagsBuffer = oldWidget.value!;
    }
    if (oldWidget.inputValue != null && widget.inputValue == null) {
      _inputBuffer = oldWidget.inputValue!;
    }
    _syncText();
  }

  @override
  void dispose() {
    _textController.removeListener(_handleTextTick);
    _textController.dispose();
    _inputFocusNode.dispose();
    _rootFocusNode.dispose();
    widget.controller?._detach(this);
    super.dispose();
  }

  // -- value model -----------------------------------------------------------

  List<String> get _tags => widget.value ?? _tagsBuffer;
  String get _input => widget.inputValue ?? _inputBuffer;

  void _focusInput() {
    if (widget.disabled) return;
    _inputFocusNode.requestFocus();
  }

  void _blurInput() {
    _inputFocusNode.unfocus();
  }

  /// Reconciles the editor text with the value model (a controlled input line
  /// always renders [SemiTagInput.inputValue] — upstream GDSFP). Skipped while
  /// an IME composition is pending (the approved composition guard).
  void _syncText() {
    final desired = _input;
    if (_textController.text == desired) return;
    if (_composing) return;
    _programmatic = true;
    _textController.value = TextEditingValue(
      text: desired,
      selection: TextSelection.collapsed(offset: desired.length),
    );
    _programmatic = false;
  }

  /// Lands + notifies an input-line value (foundation `_onInputChange`:
  /// `setInputValue` + `notifyInputChange`); [notify] false reproduces the
  /// composition-end `setInputValue`-only writes.
  void _applyInput(String value, {required bool notify}) {
    if (widget.inputValue == null) {
      setState(() => _inputBuffer = value);
    }
    if (notify) widget.onInputChange?.call(value);
    _syncText();
  }

  // -- input editing (foundation handleInputChange / composition) ------------

  void _handleTextTick() {
    if (_programmatic) return;
    final value = _textController.value;
    final composing = value.composing.isValid;
    final composingEnded = !composing && _composing;
    if (composing && !_composing) {
      _composing = true;
      // ★ upstream `entering` exists only while maxLength is set
      // (handleInputCompositionStart early-returns otherwise).
      if (widget.maxLength != null) _entering = true;
    }
    if (composingEnded) {
      _composing = false;
      if (_entering) {
        _entering = false;
        _handleCompositionEnd(_textController.text);
        return;
      }
    }
    if (widget.disabled) {
      _syncText();
      return;
    }
    final text = _textController.text;
    // Selection/composing-only notifications (e.g. focus caret moves) are not
    // edits — upstream `input` events only fire on text changes.
    if (text == _input) return;
    if (_entering) {
      // Composing (with maxLength): editing is untracked — accept and report
      // (the `entering` branch of foundation handleInputChange).
      _applyInput(text, notify: true);
      return;
    }
    if (_checkInputChangeValid(text)) {
      _applyInput(text, notify: true);
    } else {
      // Rejected keystroke: the display keeps the model value.
      _syncText();
    }
  }

  /// foundation `_checkInputChangeValid`: reject when any separator segment
  /// GROWS past maxLength (new or longer segments only — deletions pass).
  bool _checkInputChangeValid(String value) {
    final maxLength = widget.maxLength;
    if (maxLength == null) return true;
    final valueArr = _splitArray(value);
    final inputArr = _splitArray(_input);
    final maxLen = math.max(valueArr.length, inputArr.length);
    for (var i = 0; i < maxLen; i++) {
      final next = i < valueArr.length ? valueArr[i] : null;
      final prev = i < inputArr.length ? inputArr[i] : null;
      if (next != null && (prev == null || next.length > prev.length)) {
        if (next.length > maxLength) {
          widget.onInputExceed?.call(value);
          return false;
        }
      }
    }
    return true;
  }

  /// foundation `handleInputCompositionEnd`: truncate the offending segment
  /// in place, fire onInputExceed(value) and write WITHOUT onInputChange
  /// (★ the Firefox workaround). The rejoin uses the JS `join(separator)`
  /// stringification (★ an array separator coerces to its elements joined by
  /// `,`).
  void _handleCompositionEnd(String value) {
    final maxLength = widget.maxLength;
    if (maxLength == null) return;
    final inputArr = _splitArray(value);
    var allowChange = true;
    var index = 0;
    for (; index < inputArr.length; index++) {
      if (inputArr[index].length > maxLength) {
        allowChange = false;
        widget.onInputExceed?.call(value);
        break;
      }
    }
    if (!allowChange) {
      final newInputArr = inputArr.sublist(0, index);
      if (index < inputArr.length) {
        newInputArr.add(inputArr[index].substring(0, maxLength));
      }
      _applyInput(newInputArr.join(_joinSeparator()), notify: false);
    } else {
      _applyInput(value, notify: false);
    }
  }

  /// ★ JS `Array.prototype.join(separator)` stringifies the separator: an
  /// array coerces to its elements joined by `,` (null to `'null'`).
  String _joinSeparator() {
    final separator = widget.separator;
    if (separator is String) return separator;
    if (separator is List<String>) return separator.join(',');
    return '$separator';
  }

  // -- splitting (foundation _splitArray / utils/getSplitedArray) ------------

  List<String> _splitArray(String originString) {
    final split = widget.split;
    if (split != null) return split(originString, widget.separator);
    final separator = widget.separator;
    if (separator is String) return originString.split(separator).toList();
    if (separator is num) {
      return originString.split(separator.toString()).toList();
    }
    if (separator is List<String>) {
      // separators[1..] folded into separators[0], then split once.
      final tempChar = separator[0];
      var splited = originString;
      for (var i = 1; i < separator.length; i++) {
        splited = splited.split(separator[i]).join(tempChar);
      }
      return splited.split(tempChar).toList();
    }
    // null / other -> single item.
    return [originString];
  }

  // -- tag mutation (foundation _handleAddTags / _onAdd / _onRemove) ---------

  void _handleAddTags() {
    final tagsArray = _tags;
    final original = _splitArray(_input);
    final addTags = <String>[];
    for (var idx = 0; idx < original.length; idx++) {
      final item = original[idx];
      if (!widget.allowDuplicates) {
        // Duplicates within the batch keep the first (indexOf over the
        // unfiltered array — the upstream filter closure).
        if (tagsArray.contains(item) || original.indexOf(item) != idx) {
          continue;
        }
      }
      // ★ empty / whitespace-only segments dropped (trim-tested) — kept
      // values are NOT trimmed.
      if (item.trim().isEmpty) continue;
      addTags.add(item);
    }
    var newTagList = <String>[...tagsArray, ...addTags];
    final max = widget.max;
    if (max != null && newTagList.length > max) {
      widget.onExceed?.call(newTagList);
      newTagList = newTagList.sublist(0, max);
      // JS `addTags.slice(0, max - tagsArray.length)` — a negative end counts
      // from the tail (upstream quirk, kept).
      var end = max - tagsArray.length;
      if (end < 0) end = addTags.length + end;
      addTags.removeRange(end.clamp(0, addTags.length), addTags.length);
    }
    if (addTags.isNotEmpty) {
      _onAdd(newTagList, addTags);
    }
    // ★ after an add the input is always cleared and reports ''.
    _applyInput('', notify: true);
  }

  void _onAdd(List<String> newTagList, List<String> addTags) {
    setState(() {
      if (widget.value == null) _tagsBuffer = newTagList;
    });
    widget.onChanged?.call(newTagList);
    widget.onAdd?.call(addTags);
  }

  void _onRemove(List<String> newTagList, String removedTag, int index) {
    setState(() {
      if (widget.value == null) _tagsBuffer = newTagList;
    });
    widget.onChanged?.call(newTagList);
    widget.onRemove?.call(removedTag, index);
  }

  void _handleTagClose(int index) {
    final tags = _tags;
    final newList = [...tags]..removeAt(index);
    _onRemove(newList, tags[index], index);
  }

  /// ★ Backspace on empty input removes the LAST tag (no multi-step
  /// select-then-delete); empty tags are a no-op.
  void _removeLast() {
    final tags = _tags;
    if (tags.isEmpty) return;
    final newList = tags.sublist(0, tags.length - 1);
    _onRemove(newList, tags[tags.length - 1], tags.length - 1);
  }

  /// Clear button (foundation handleClearBtn): clears tags + input, no
  /// onRemove; ★ always notifies AND lands in the uncontrolled buffer — for
  /// controlled values the render keeps `value` (差异清单).
  void _handleClear() {
    if (widget.disabled) return;
    if (_tags.isNotEmpty) {
      setState(() {
        if (widget.value == null) _tagsBuffer = const [];
      });
      widget.onChanged?.call(const []);
    }
    if (_input.isNotEmpty) {
      _applyInput('', notify: true);
    }
  }

  /// Enter is always consumed (upstream `preventDefault`); adds only when the
  /// input is non-empty.
  void _handleEnter() {
    if (_input.isNotEmpty) _handleAddTags();
  }

  // -- keyboard (foundation handleKeyDown) -----------------------------------

  /// Keys on the input's own node run before EditableText's delete shortcuts:
  /// ★ Backspace on empty input removes the LAST tag and is consumed here.
  KeyEventResult _handleInputKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (widget.disabled) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        _input.isEmpty &&
        _tags.isNotEmpty) {
      _removeLast();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handleRootKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (widget.disabled) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      // A focused input rides the SemiInput `onEnterPress` channel (the
      // select precedent) — never double-handle Enter here.
      if (_inputFocusNode.hasPrimaryFocus) return KeyEventResult.ignored;
      _handleEnter();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_input.isNotEmpty || _tags.isEmpty) return KeyEventResult.ignored;
      _removeLast();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // -- drag reorder (upstream _sortable Sortable / foundation handleSortEnd) --

  void _startDrag(int index, Offset globalPos) {
    if (!widget.draggable || widget.disabled || !_active) return;
    final box =
        _tagKeys[index]?.currentContext?.findRenderObject() as RenderBox?;
    _grabDelta = box != null && box.attached
        ? box.globalToLocal(globalPos)
        : Offset.zero;
    setState(() {
      _dragIndex = index;
      _dropIndex = index;
      _updateOverlay(globalPos);
    });
  }

  void _moveDrag(Offset globalPos) {
    if (_dragIndex == null) return;
    setState(() {
      _updateOverlay(globalPos);
      var best = -1;
      var bestDist = double.infinity;
      for (final entry in _tagKeys.entries) {
        final box =
            entry.value.currentContext?.findRenderObject() as RenderBox?;
        if (box == null || !box.attached) continue;
        final rect = box.localToGlobal(Offset.zero) & box.size;
        if (rect.inflate(_TagInputMetrics.dropSlop).contains(globalPos)) {
          best = entry.key;
          break;
        }
        final dist = (rect.center - globalPos).distance;
        if (dist < bestDist) {
          bestDist = dist;
          best = entry.key;
        }
      }
      if (best >= 0) _dropIndex = best;
    });
  }

  void _updateOverlay(Offset globalPos) {
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null || !stackBox.attached) return;
    _overlayOffset = stackBox.globalToLocal(globalPos) - _grabDelta;
  }

  void _endDrag() {
    final from = _dragIndex;
    final to = _dropIndex;
    // ★ upstream `_sortable.onDragEnd`: onSortEnd only when the index changed
    // — exactly ONE onChanged at drop, no onSort callback, no onAdd/onRemove.
    final reorder = from != null && to >= 0 && to != from;
    final reordered = reorder ? _arrayMove(_tags, from, to) : null;
    setState(() {
      _dragIndex = null;
      _dropIndex = -1;
      _overlayOffset = null;
      if (reordered != null && widget.value == null) {
        _tagsBuffer = reordered;
      }
    });
    if (reordered != null) {
      widget.onChanged?.call(reordered);
    }
  }

  void _cancelDrag() {
    setState(() {
      _dragIndex = null;
      _dropIndex = -1;
      _overlayOffset = null;
    });
  }

  /// Upstream utils/arrayMove: splice out of `from`, insert at `to` in the
  /// reduced array.
  static List<String> _arrayMove(List<String> array, int from, int to) {
    final copy = [...array];
    final insertAt = to < 0 ? copy.length + to : to;
    copy.insert(insertAt.clamp(0, copy.length), copy.removeAt(from));
    return copy;
  }

  // -- build -----------------------------------------------------------------

  double _tagMarginY(SemiResolvedTagInputThemeData t) => switch (widget.size) {
    SemiInputSize.small => t.spacingTagInputSmallY,
    SemiInputSize.normal => t.spacingTagInputDefaultY,
    SemiInputSize.large => t.spacingTagInputLargeY,
  };

  @override
  Widget build(BuildContext context) {
    final global = SemiTheme.of(context);
    final t = SemiTagInputTheme.resolve(context);
    final disabled = widget.disabled;
    final tags = _tags;
    final geometry = _TagInputGeometry.of(t, widget.size);

    // tagInput.scss state machine (disabled > focus > hover > rest; warning /
    // danger rows per validateStatus — success has no visuals upstream).
    final warn = widget.validateStatus == SemiInputStatus.warning;
    final danger = widget.validateStatus == SemiInputStatus.error;
    final Color bgColor;
    final Color borderColor;
    final double borderWidth;
    if (disabled) {
      bgColor = t.colorTagInputDisabledBg;
      borderColor = danger
          ? t.colorTagInputDangerBorderDefault
          : warn
          ? t.colorTagInputWarningBorderDefault
          : t.colorTagInputBorderDefault;
      borderWidth = t.widthTagInputBorderDefault;
    } else if (_active) {
      bgColor = danger
          ? t.colorTagInputDangerBgFocus
          : warn
          ? t.colorTagInputWarningBgFocus
          : t.colorTagInputDefaultBgFocus;
      borderColor = danger
          ? t.colorTagInputDangerBorderFocus
          : warn
          ? t.colorTagInputWarningBorderFocus
          : t.colorTagInputBorderFocus;
      borderWidth = t.widthTagInputBorderFocus;
    } else if (_hovering) {
      bgColor = danger
          ? t.colorTagInputDangerBgHover
          : warn
          ? t.colorTagInputWarningBgHover
          : t.colorTagInputDefaultBgHover;
      borderColor = danger
          ? t.colorTagInputDangerBorderHover
          : warn
          ? t.colorTagInputWarningBorderHover
          : t.colorTagInputBorderHover;
      borderWidth = t.widthTagInputBorderHover;
    } else {
      bgColor = danger
          ? t.colorTagInputDangerBgDefault
          : warn
          ? t.colorTagInputWarningBgDefault
          : t.colorTagInputDefaultBgDefault;
      borderColor = danger
          ? t.colorTagInputDangerBorderDefault
          : warn
          ? t.colorTagInputWarningBorderDefault
          : t.colorTagInputBorderDefault;
      borderWidth = t.widthTagInputBorderDefault;
    }

    // maxTagCount folding (upstream renderTags): the +N collapse releases
    // while focused when expandRestTagsOnClick; the sortable (draggable)
    // layout always shows every tag.
    final sortable = _active && widget.draggable && tags.isNotEmpty;
    final fold =
        !sortable &&
        (!_active || !widget.expandRestTagsOnClick) &&
        widget.maxTagCount != null &&
        widget.maxTagCount! > 0 &&
        widget.maxTagCount! < tags.length;

    final children = <Widget>[
      for (final (index, tag) in tags.indexed)
        if (!fold || index < widget.maxTagCount!) _buildTagSlot(t, index, tag),
      if (fold) _buildNTag(global, t, tags.length - widget.maxTagCount!),
      _buildInputSlot(global, t, geometry),
    ];

    final prefixSlot = _buildLabelSlot(
      global,
      t,
      widget.prefix,
      insetLabel: widget.insetLabel,
      isSuffix: false,
    );
    final suffixSlot = _buildLabelSlot(
      global,
      t,
      widget.suffix,
      insetLabel: null,
      isSuffix: true,
    );
    final clearSlot = _buildClearSlot(t);

    final box = AnimatedContainer(
      key: SemiTagInput.rootKey,
      // `transition: background-color …, border …` (tagInput.scss:16-17) —
      // the border triple rides its own container. The frame paints as a
      // FOREGROUND decoration so the border does not inset the content
      // (switch.scss-style border-box: the `$width-tagInput-border-*` border
      // lives inside the `height-tagInput-*` box).
      duration: t.transitionDurationTagInputBorder,
      curve: t.transitionFunctionTagInputBorder,
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(t.radiusTagInput),
        border: Border.all(width: borderWidth, color: borderColor),
      ),
      child: AnimatedContainer(
        duration: t.transitionDurationTagInputBg,
        curve: t.transitionFunctionTagInputBg,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(t.radiusTagInput),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: geometry.rootMinHeight),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              prefixSlot,
              Expanded(
                child: Padding(
                  // `padding-left/right: $spacing-extra-tight` (wrapper).
                  padding: const EdgeInsets.symmetric(
                    horizontal: _TagInputMetrics.extraTight,
                  ),
                  child: Wrap(
                    runAlignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: children,
                  ),
                ),
              ),
              clearSlot,
              suffixSlot,
            ],
          ),
        ),
      ),
    );

    final stackChildren = <Widget>[
      box,
      if (_dragIndex != null && _overlayOffset != null)
        // `-drag-item-move` — `z-index: $z-tagInput_drag_item_move` (the CSS
        // z-order has no Flutter counterpart: the overlay rides the tail Stack
        // slot, which paints on top — the field is documented, not consumed).
        Positioned(
          left: _overlayOffset!.dx,
          top: _overlayOffset!.dy,
          child: IgnorePointer(
            child: Opacity(
              opacity: _TagInputMetrics.dragOverlayOpacity,
              child: _buildTagWidget(
                t,
                _dragIndex!,
                tags[_dragIndex!],
                overlay: true,
              ),
            ),
          ),
        ),
    ];

    return Semantics(
      container: true,
      enabled: !disabled,
      // ★ upstream `aria-invalid={validateStatus === 'error'}` (index.tsx:692)
      // — only error is invalid; success/warning map to none.
      validationResult: danger
          ? SemanticsValidationResult.invalid
          : SemanticsValidationResult.none,
      child: MouseRegion(
        // The whole field reads as one input: I-beam everywhere except the
        // tag chips (upstream `.semi-input` `cursor: text`, input.scss:47 —
        // its flex-grown box carries the text cursor across the row) and the
        // interactive bits below (close=pointer tag.scss:85, +N/clear=pointer
        // tagInput.scss:178/270, drag handle=move :41). Disabled is
        // `not-allowed` (tagInput.scss:109).
        cursor: disabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.text,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() {
          _hovering = false;
          _clearHovered = false;
        }),
        child: Focus(
          focusNode: _rootFocusNode,
          onKeyEvent: _handleRootKey,
          onFocusChange: (focused) => setState(() => _active = focused),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // ★ root click sets upstream `active`; approximated by focusing
            // the input (差异清单).
            onTap: disabled ? null : _focusInput,
            child: Stack(key: _stackKey, children: stackChildren),
          ),
        ),
      ),
    );
  }

  Widget _buildTagSlot(SemiResolvedTagInputThemeData t, int index, String tag) {
    Widget item = _buildTagWidget(t, index, tag);
    if (_dragIndex == index) {
      // `-sortable-item-active` — `opacity: 0.5`.
      item = Opacity(opacity: _TagInputMetrics.draggedItemOpacity, child: item);
    }
    if (_dragIndex != null && _dropIndex == index && _dropIndex != _dragIndex) {
      // `-sortable-item-over::before` — a `width-tagInput_sortable_item_over`
      // `color-tagInput_sortable_item_over-bg` bar before the item.
      item = Stack(
        clipBehavior: Clip.none,
        children: [
          item,
          PositionedDirectional(
            start: -t.widthTagInputSortableItemOver,
            top: 0,
            bottom: 0,
            width: t.widthTagInputSortableItemOver,
            child: ColoredBox(color: t.colorTagInputSortableItemOverBg),
          ),
        ],
      );
    }
    return KeyedSubtree(
      key: SemiTagInput.tagKey(index),
      child: Padding(
        key: _tagKeys.putIfAbsent(index, () => GlobalKey()),
        // `margin-right: $spacing-extra-tight` (RTL flips to margin-left 4 /
        // margin-right 0 — rtl.scss:12-15) and `margin-top/bottom:
        // $spacing-tagInput_{small,default,large}-Y`.
        padding: EdgeInsetsDirectional.only(
          end: _TagInputMetrics.extraTight,
          top: _tagMarginY(t),
          bottom: _tagMarginY(t),
        ),
        child: MouseRegion(
          // Tag chips show the plain arrow — the field's I-beam stops at the
          // chips; inner slots override (close=pointer tag.scss:85,
          // drag handle=move). Disabled defers to the root's not-allowed.
          cursor: widget.disabled
              ? MouseCursor.defer
              : SystemMouseCursors.basic,
          child: item,
        ),
      ),
    );
  }

  /// The default tag render (index.tsx renderTag): white/light SemiTag,
  /// ★ size small iff upstream size is `'small'` — the default maps to
  /// Tag.large. The drag overlay ([overlay]) drops the handle so its keys
  /// stay unique in the tree.
  Widget _buildTagWidget(
    SemiResolvedTagInputThemeData t,
    int index,
    String tag, {
    bool overlay = false,
  }) {
    final showHandle =
        !overlay && widget.draggable && _active && !widget.disabled;
    final custom = widget.renderTagItem;
    if (custom != null) {
      // Upstream `renderTagItem(value, index, onClose)`; the drag handle
      // wraps the custom render too (the `-drag-item` wrapper).
      final Widget item = custom(tag, index, () {
        if (!widget.disabled) _handleTagClose(index);
      });
      if (!showHandle) return item;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: t.spacingTagInputTagIconPaddingLeft,
              end: t.spacingTagInputDragHandlerMarginRight,
            ),
            child: _buildDragHandle(t, index),
          ),
          item,
        ],
      );
    }
    final result = SemiTag(
      tag,
      key: ValueKey(
        overlay
            ? 'SemiTagInput.overlay<$index>:$tag'
            : 'SemiTagInput.tag<$index>:$tag',
      ),
      size: widget.size == SemiInputSize.small
          ? SemiTagSize.small
          : SemiTagSize.large,
      color: SemiTagColor.white,
      type: SemiTagType.light,
      closable: !widget.disabled,
      textColor: widget.disabled ? t.colorTagInputDisabledTextDefault : null,
      backgroundColor: widget.disabled ? const Color(0x00000000) : null,
      prefixIcon: showHandle
          ? Padding(
              // `padding-left: $spacing-tagInput_tag_icon_paddingLeft` and the
              // handler's `margin-right:
              // $spacing-tagInput_drag_handler-marginRight`.
              padding: EdgeInsetsDirectional.only(
                start: t.spacingTagInputTagIconPaddingLeft,
                end: t.spacingTagInputDragHandlerMarginRight,
              ),
              child: _buildDragHandle(t, index),
            )
          : null,
      onClose: (event) {
        // ★ upstream preventDefaults Tag's internal hide — visibility is
        // value-driven here (index.tsx renderTag onClose).
        event.preventDefault();
        if (!widget.disabled) _handleTagClose(index);
      },
    );
    if (!overlay && widget.showContentTooltip) {
      // Upstream `showContentTooltip` gates an ellipsis tooltip on the
      // default label (Paragraph) — approximated as a hover tooltip carrying
      // the full value (differences list).
      return SemiTooltip(content: Text(tag), child: result);
    }
    return result;
  }

  Widget _buildDragHandle(SemiResolvedTagInputThemeData t, int index) {
    return MouseRegion(
      cursor: _dragIndex == index
          ? SystemMouseCursors.grabbing
          : SystemMouseCursors.move,
      child: Listener(
        key: SemiTagInput.dragHandleKey(index),
        behavior: HitTestBehavior.opaque,
        onPointerDown: (e) => _startDrag(index, e.position),
        onPointerMove: (e) {
          if (e.down) _moveDrag(e.position);
        },
        onPointerUp: (_) => _endDrag(),
        onPointerCancel: (_) => _cancelDrag(),
        child: Semantics(
          button: true,
          label: 'Reorder',
          child: ExcludeSemantics(
            child: SemiIcon(
              SemiIcons.handle,
              color: t.colorTagInputHandlerIconDefault,
            ),
          ),
        ),
      ),
    );
  }

  /// The `+N` fold chip (`&-wrapper-n`); [SemiTagInput.showRestTagsPopover]
  /// wraps it in a hover tooltip listing the folded-away tags (the select
  /// `_buildNTag` precedent).
  Widget _buildNTag(
    SemiThemeData global,
    SemiResolvedTagInputThemeData t,
    int restCount,
  ) {
    Widget nTag = Padding(
      // `margin-right: $spacing-extra-tight` (+ the tag-row vertical margins).
      padding: EdgeInsetsDirectional.only(
        end: _TagInputMetrics.extraTight,
        top: _tagMarginY(t),
        bottom: _tagMarginY(t),
      ),
      child: Padding(
        // `padding-left/right: $spacing-tagInput_wrapper_n_paddingX`.
        padding: EdgeInsets.symmetric(
          horizontal: t.spacingTagInputWrapperNPaddingX,
        ),
        child: Text(
          key: SemiTagInput.nTagKey,
          '+$restCount',
          style: TextStyle(
            // `font-size: $font-size-small` (12px).
            fontSize: _TagInputMetrics.fontSizeSmall,
            color: widget.disabled
                ? t.colorTagInputDisabledTextDefault
                : // ★ `color: var(--semi-color-text-0);` hardcoded
                  // (tagInput.scss:181) — resolved live from the global token.
                  global.colors.colorText0,
          ),
        ),
      ),
    );
    if (!widget.showRestTagsPopover || restCount <= 0) return nTag;
    final tags = _tags;
    final rest = tags.sublist(tags.length - restCount);
    return SemiTooltip(
      content: Padding(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 4,
          runSpacing: 2,
          children: [
            for (final value in rest)
              SemiTag(
                value,
                closable: false,
                size: widget.size == SemiInputSize.small
                    ? SemiTagSize.small
                    : SemiTagSize.large,
                color: SemiTagColor.white,
                type: SemiTagType.light,
              ),
          ],
        ),
      ),
      trigger: SemiTooltipTrigger.hover,
      position: SemiTooltipPosition.top,
      showArrow: true,
      child: nTag,
    );
  }

  Widget _buildInputSlot(
    SemiThemeData global,
    SemiResolvedTagInputThemeData t,
    _TagInputGeometry geometry,
  ) {
    return Padding(
      // `margin-top/bottom: $spacing-tagInput_{small,default,large}-Y`.
      padding: EdgeInsetsDirectional.only(
        top: _tagMarginY(t),
        bottom: _tagMarginY(t),
      ),
      child: SizedBox(
        width: _measureInputWidth(global),
        height: geometry.inputLineHeight,
        child: SemiInput(
          controller: _textController,
          focusNode: _inputFocusNode,
          // select trigger precedent: `border: none; background-color:
          // transparent` (tagInput.scss:191-199 `&-wrapper-input`).
          bare: true,
          size: widget.size,
          disabled: widget.disabled,
          // ★ placeholder shows only when there are NO tags.
          placeholder: _tags.isEmpty ? widget.placeholder : '',
          semanticsLabel: widget.semanticsLabel,
          inputStyle: TextStyle(
            // `font-size: $font-size-regular` (the CSS `line-height:
            // $height-tagInput_input_*` pairing is carried by the SizedBox
            // box height + SemiInput's centering — a `TextStyle.height` here
            // would scale ascent/descent and drop the glyphs ~2px low, see
            // docs/semi_input.md).
            fontSize: global.typography.fontSizeRegular,
          ),
          onEnterPress: _handleEnter,
          onBlur: () {
            // ★ addOnBlur (foundation.ts:213-220): blur runs the full add
            // flow first (including the empty-input `onInputChange('')`
            // side effect of `_handleAddTags`), then the user callback.
            if (widget.addOnBlur && !widget.disabled) _handleAddTags();
            widget.onBlur?.call();
          },
          onFocusChange: widget.onFocusChange,
        ),
      ),
    );
  }

  /// The mirror measurement (index.tsx updateInputWidth): the current input
  /// text, or the placeholder when there are no tags, else `' '`; width =
  /// `scrollWidth + 2` (mirrored here by a TextPainter — the `+ 2` fudge is
  /// kept), clamped to `min-width: 2px`.
  double _measureInputWidth(SemiThemeData global) {
    final text = _input.isNotEmpty
        ? _input
        : (_tags.isEmpty ? (widget.placeholder ?? '') : '');
    final mirror = text.isEmpty ? ' ' : text;
    final painter = TextPainter(
      text: TextSpan(
        text: mirror,
        style: TextStyle(
          fontSize: global.typography.fontSizeRegular,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout();
    final width =
        painter.width.ceilToDouble() + _TagInputMetrics.inputWidthFudge;
    painter.dispose();
    return math.max(_TagInputMetrics.inputMinWidth, width);
  }

  /// Prefix slot (`prefix || insetLabel`) or suffix slot. Strings render
  /// `-prefix-text` / `-suffix-text` styling (★ the prefix text color rides
  /// the `-prefix-default` channel — the `-prefix-text-default` var is dead
  /// upstream); SemiIcon slots get the icon margins; other Widgets render
  /// as-is. Tapping focuses the input (upstream mousedown preventDefault +
  /// `handleClickPrefixOrSuffix`).
  Widget _buildLabelSlot(
    SemiThemeData global,
    SemiResolvedTagInputThemeData t,
    Object? value, {
    required Object? insetLabel,
    required bool isSuffix,
  }) {
    final label = value ?? insetLabel;
    if (label == null) return const SizedBox.shrink();
    final Widget content;
    if (label is SemiIcon && label.data != null) {
      // `&-prefix-icon, &-suffix-icon` — `margin: 0 $spacing-tight`, icon
      // color `color-tagInput-icon-default`.
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: _TagInputMetrics.tight),
        child: SemiIcon(
          label.data,
          size: label.size,
          customSize: label.customSize,
          color: widget.disabled
              ? t.colorTagInputDisabledTextDefault
              : t.colorTagInputIconDefault,
          semanticsLabel: label.semanticsLabel,
          excludeFromSemantics: label.excludeFromSemantics,
        ),
      );
    } else if (label is Widget) {
      content = label;
    } else {
      // `&-prefix-text`, `&-suffix-text`, `&-inset-label` — `margin: 0
      // $spacing-tagInput_prefix_suffix-marginX`,
      // `font-weight: $font-tagInput_prefix_suffix-fontWeight`,
      // `@include font-size-regular` (its `line-height: 20px` pairing).
      content = Padding(
        padding: EdgeInsets.symmetric(
          horizontal: t.spacingTagInputPrefixSuffixMarginX,
        ),
        child: Text(
          '$label',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: global.typography.fontSizeRegular,
            fontWeight: t.fontTagInputPrefixSuffixFontWeight,
            color: widget.disabled
                ? t.colorTagInputDisabledTextDefault
                : isSuffix
                ? t.colorTagInputSuffixDefault
                : t.colorTagInputPrefixDefault,
          ),
        ),
      );
    }
    // `@include all-center` on the slot; the tap focuses the input.
    return Center(
      child: MouseRegion(
        // The prefix/suffix rides the field's I-beam (the user-calibrated map:
        // everything except tags shows the text cursor).
        cursor: MouseCursor.defer,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.disabled ? null : _focusInput,
          child: content,
        ),
      ),
    );
  }

  Widget _buildClearSlot(SemiResolvedTagInputThemeData t) {
    if (!widget.showClear) return const SizedBox.shrink();
    // Upstream `clearBtn-invisible` — hidden (the 32px slot stays) unless
    // hovering with non-empty tags/input and enabled.
    final visible =
        _hovering &&
        !widget.disabled &&
        (_tags.isNotEmpty || _input.isNotEmpty);
    final Widget icon =
        widget.clearIcon ??
        SemiIcon(
          SemiIcons.clear,
          color: widget.disabled
              ? t.colorTagInputDisabledTextDefault
              : _clearHovered
              ? t.colorTagInputIconHover
              : t.colorTagInputIconDefault,
        );
    return SizedBox(
      // `width: $width-tagInput-clear-medium`.
      width: t.widthTagInputClearMedium,
      child: Center(
        child: Visibility(
          visible: visible,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: MouseRegion(
            cursor: widget.disabled
                ? MouseCursor.defer
                : SystemMouseCursors.click,
            onEnter: (_) => setState(() => _clearHovered = true),
            onExit: (_) => setState(() => _clearHovered = false),
            child: GestureDetector(
              key: SemiTagInput.clearButtonKey,
              behavior: HitTestBehavior.opaque,
              onTap: widget.disabled ? null : _handleClear,
              child: Semantics(
                button: true,
                label: 'Clear TagInput value',
                child: ExcludeSemantics(child: icon),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Per-size geometry derived from tagInput.scss (`&-small` / `&-large` /
/// `&-wrapper-input-*` blocks).
class _TagInputGeometry {
  const _TagInputGeometry({
    required this.rootMinHeight,
    required this.inputLineHeight,
    required this.tagMarginY,
  });

  factory _TagInputGeometry.of(
    SemiResolvedTagInputThemeData t,
    SemiInputSize size,
  ) {
    return switch (size) {
      SemiInputSize.small => _TagInputGeometry(
        rootMinHeight: t.heightTagInputSmall,
        inputLineHeight: t.heightTagInputInputSmall,
        tagMarginY: t.spacingTagInputSmallY,
      ),
      SemiInputSize.normal => _TagInputGeometry(
        rootMinHeight: t.heightTagInputDefault,
        inputLineHeight: t.heightTagInputInputDefault,
        tagMarginY: t.spacingTagInputDefaultY,
      ),
      SemiInputSize.large => _TagInputGeometry(
        rootMinHeight: t.heightTagInputLarge,
        inputLineHeight: t.heightTagInputInputLarge,
        tagMarginY: t.spacingTagInputLargeY,
      ),
    };
  }

  final double rootMinHeight, inputLineHeight, tagMarginY;
}

/// Widget-internal metrics and provenance anchors (upstream values kept out of
/// the theme). See tool/generate_tag_input.py for the
/// 55 = 49 FIELDS + 6 MOTION + 0 INTERNAL accounting.
///
/// Hardcode provenance (另列, each snippet must appear in this source):
///
/// * `all-center` mixin (packages/semi-theme-default/scss/mixin.scss:22,
///   clearBtn tagInput.scss:264 / prefix-suffix :290) —
///   `display: flex; justify-content: center; align-items: center;`
///   (mirrored by the `Center` slots).
/// * `font-size-regular` mixin (packages/semi-theme-default/scss/_font.scss:8,
///   inset-label tagInput.scss:282 / prefix-suffix text :295) —
///   `line-height: 20px` pairs `$font-size-regular` (fonts resolve through
///   theme.typography here).
/// * index.tsx:342 mirror input width — `scrollWidth + 2` (the mirror DOM
///   node is replaced by a TextPainter; the `+ 2` fudge is kept).
/// * _sortable/index.tsx:210 drag-handle span — `lineHeight: 0` (the handle
///   hug is intrinsic here).
/// * tagInput.scss:194 `&-wrapper-input` — `min-width: 2px`.
/// * tagInput.scss:181 `&-wrapper-n` — `color: var(--semi-color-text-0);`
///   (★ hardcoded upstream — the same-channel `-maxTagCount-default` var is
///   dead, 上游未消费) resolved live from the global token in `_buildNTag`.
abstract final class _TagInputMetrics {
  /// index.tsx:342 `Math.ceil(mirrorEl.scrollWidth + 2)` — mirror-width fudge.
  static const double inputWidthFudge = 2;

  /// tagInput.scss:194 — `min-width: 2px`.
  static const double inputMinWidth = 2;

  /// packages/semi-theme-default/scss/variables.scss:20 —
  /// `$spacing-extra-tight: 4px` (wrapper `padding-left/right`
  /// tagInput.scss:137 and `margin-right` on wrapper-tag :143 / wrapper-n
  /// :180; RTL flips the tag margin to margin-left 4 / margin-right 0).
  static const double extraTight = 4;

  /// packages/semi-theme-default/scss/variables.scss:21 —
  /// `$spacing-tight: 8px` (prefix/suffix icon `margin: 0 …`
  /// tagInput.scss:299).
  static const double tight = 8;

  /// packages/semi-theme-default/scss/variables.scss:58 —
  /// `$font-size-small: 12px` (typo tagInput.scss:170 / wrapper-n :179; the
  /// tag text itself rides SemiTag's typography).
  static const double fontSizeSmall = 12;

  /// Drag visuals (upstream dnd-kit DragOverlay keeps the floating clone
  /// opaque; `-sortable-item-active` dims the in-place item to 0.5).
  static const double dragOverlayOpacity = 1;
  static const double draggedItemOpacity = 0.5;

  /// Pointer-to-slot proximity slack for drop-index computation (not an
  /// upstream token).
  static const double dropSlop = 2;
}
