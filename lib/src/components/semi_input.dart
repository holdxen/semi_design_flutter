import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show SemanticsValidationResult;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/semi_input_theme.dart';
import '../theme/semi_input_theme_data.dart';
import '../theme/semi_theme.dart';
import '../theme/semi_theme_data.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icons.dart';

/// Upstream `InputMode` — only `password` exists upstream; `normal` is the
/// absence of the mode.
enum SemiInputMode { normal, password }

/// Upstream `InputSize` (`small` / `default` / `large`).
enum SemiInputSize { small, normal, large }

/// Upstream `ValidateStatus` (`default` / `error` / `warning` / `success`).
/// `success` carries no dedicated visuals upstream and is semantics-only.
enum SemiInputStatus { normal, error, warning, success }

/// TextArea autosize bounds (upstream `AutosizeRow`). `minRows` falls back to
/// [SemiTextArea.rows]; a null `maxRows` grows unbounded (min stays `rows`).
class SemiTextAreaAutosize {
  const SemiTextAreaAutosize({this.minRows, this.maxRows});

  final int? minRows;
  final int? maxRows;
}

/// Truncates edits to `maxLength` UTF-16 code units (upstream `truncateValue`
/// without `getValueLength` slices UTF-16 the same way). `maxLength: 0`
/// forces the value empty. Custom `getValueLength` counting is not ported —
/// see docs/semi_input.md.
class _CodeUnitTruncateFormatter extends TextInputFormatter {
  const _CodeUnitTruncateFormatter(this.maxLength);

  final int maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length <= maxLength) return newValue;
    return TextEditingValue(
      text: newValue.text.substring(0, maxLength),
      selection: TextSelection.collapsed(offset: maxLength),
      composing: TextRange.empty,
    );
  }
}

/// A source-sized, non-Material single-line input (upstream Semi Input).
///
/// `value != null` makes the input controlled (SemiTag.visible / SemiCheckbox
/// convention): rendering follows [value] and edits only emit [onChanged];
/// releasing control (`value` back to null) retains the last displayed value.
/// Uncontrolled, the text lives in [controller] (or an internal one seeded
/// from [initialValue]) and edits land directly.
///
/// Controlled reconciliation overwrites the editing value only when the
/// external [value] differs from the controller text **and** no IME
/// composition is pending (`controller.composing` is empty), so pinyin input
/// is never clobbered mid-composition.
///
/// With [mode] `password` the eye button is always shown unless [disabled];
/// Enter/Space activate it and toggling preserves the text selection. The
/// clear button shows while hovering or focused with non-empty text (hidden
/// while disabled or readonly — upstream `showClearIgnoreDisabled` is not
/// ported) and fires on pointer-down so the input cannot blur first.
class SemiInput extends StatefulWidget {
  const SemiInput({
    super.key,
    this.value,
    this.initialValue,
    this.mode = SemiInputMode.normal,
    this.size = SemiInputSize.normal,
    this.validateStatus = SemiInputStatus.normal,
    this.disabled = false,
    this.readonly = false,
    this.borderless = false,
    this.bare = false,
    this.placeholder,
    this.prefix,
    this.suffix,
    this.insetLabel,
    this.addonBefore,
    this.addonAfter,
    this.showClear = false,
    this.hideSuffix = false,
    this.clearIcon,
    this.maxLength,
    this.onChanged,
    this.onEnterPress,
    this.onFocusChange,
    this.onBlur,
    this.onClear,
    this.controller,
    this.focusNode,
    this.inputStyle,
    this.semanticsLabel,
  }) : assert(
         controller == null || initialValue == null,
         'Provide either controller or initialValue, not both.',
       );

  /// Key of the bordered wrapper box (state-matrix decoration).
  static const Key wrapperKey = Key('SemiInput.wrapper');

  /// Key of the clear button slot.
  static const Key clearButtonKey = Key('SemiInput.clearButton');

  /// Key of the password visibility button slot.
  static const Key modeButtonKey = Key('SemiInput.modeButton');

  /// Non-null makes the input controlled: rendering follows this value.
  final String? value;

  /// Seed of the uncontrolled internal controller.
  final String? initialValue;

  final SemiInputMode mode;
  final SemiInputSize size;
  final SemiInputStatus validateStatus;
  final bool disabled;
  final bool readonly;
  final bool borderless;

  /// Strips the wrapper decoration entirely — transparent background, no
  /// border in any state, zero horizontal padding (the embedded-search usage,
  /// e.g. Select's inner input: `border: none; background-color: transparent`
  /// including the `-wrapper-focus` override in select.scss). Unlike
  /// [borderless] (input.scss's own borderless mode, which keeps the focus
  /// border), this leaves nothing to draw.
  final bool bare;
  final String? placeholder;

  /// String or Widget. [prefix] wins the shared prefix slot over [insetLabel];
  /// String slots render bold (w600) prefix-colored text, [SemiIcon] slots get
  /// the icon margins, other Widgets render as-is.
  final Object? prefix;

  /// String or Widget; trailing slot after the clear button (upstream order:
  /// input, clear, suffix, mode button).
  final Object? suffix;

  /// String or Widget; shares the prefix slot and renders bold (w600).
  final Object? insetLabel;

  /// String or Widget; independent 1px inner-side bordered block before the
  /// input (upstream `prepend`).
  final Object? addonBefore;

  /// String or Widget; independent 1px inner-side bordered block after the
  /// input (upstream `append`).
  final Object? addonAfter;

  /// Shows the clear button while hovering or focused with non-empty text.
  final bool showClear;

  /// Hides the suffix while the clear button is visible (upstream `hideSuffix`,
  /// simplified: no `__with-suffix-hidden` wrapper variants).
  final bool hideSuffix;

  /// Custom clear icon (defaults to `SemiIcons.clear`).
  final Widget? clearIcon;

  /// Maximum length in UTF-16 code units; `0` forces the value empty.
  final int? maxLength;

  /// Fires on every edit, also during IME composition (the upstream
  /// `composition` switch and the composition callbacks are documented-only
  /// per the port plan — see docs/semi_input.md). A controlled clear emits
  /// `''` here without touching the controller.
  final ValueChanged<String>? onChanged;

  /// Fires when Enter is pressed. For the single-line input this rides the
  /// engine `done` action ([EditableText.onSubmitted], also fed by hardware
  /// Enter and by `TextInputAction` completion buttons); for the textarea it
  /// rides the keydown channel.
  final VoidCallback? onEnterPress;
  final ValueChanged<bool>? onFocusChange;
  final VoidCallback? onBlur;

  /// Fires after a clear tap (following the `onChanged('')` notification).
  final VoidCallback? onClear;

  /// External controller; never disposed by the widget.
  final TextEditingController? controller;

  /// External focus node; never disposed by the widget.
  final FocusNode? focusNode;

  /// Merged over the built-in editable text style (this wins).
  final TextStyle? inputStyle;
  final String? semanticsLabel;

  @override
  State<SemiInput> createState() => _SemiInputState();
}

class _SemiInputState extends State<SemiInput> {
  late TextEditingController _controller;
  late bool _ownsController;
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  bool _hovering = false, _focused = false;
  bool _clearHovered = false, _modeHovered = false, _modeBtnFocused = false;
  bool _eyeClosed = true;

  bool _programmaticUpdate = false;

  @override
  void initState() {
    super.initState();
    _eyeClosed = widget.mode == SemiInputMode.password;
    _initController();
    _initFocusNode();
    _focusNode.addListener(_handleFocusTick);
  }

  void _initController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
      if (widget.value != null && widget.value != _controller.text) {
        _controller.text = widget.value!;
      }
    } else {
      _controller = TextEditingController(
        text: widget.value ?? widget.initialValue ?? '',
      );
      _ownsController = true;
    }
    _controller.addListener(_handleTextTick);
  }

  void _initFocusNode() {
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _ownsFocusNode = false;
    } else {
      _focusNode = FocusNode(debugLabel: 'SemiInput');
      _ownsFocusNode = true;
    }
  }

  @override
  void didUpdateWidget(SemiInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_handleTextTick);
      if (_ownsController) _controller.dispose();
      _initController();
    }
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_handleFocusTick);
      if (_ownsFocusNode) _focusNode.dispose();
      _initFocusNode();
      _focusNode.addListener(_handleFocusTick);
    }
    if (widget.mode != oldWidget.mode &&
        widget.mode != SemiInputMode.password) {
      _eyeClosed = false;
    }
    _syncFromValue();
  }

  /// Controlled reconciliation: only when the external value differs and no
  /// IME composition is pending (the approved composition guard).
  void _syncFromValue() {
    final value = widget.value;
    if (value == null || value == _controller.text) return;
    if (_controller.value.composing != TextRange.empty) return;
    final selection = _controller.selection;
    _programmaticUpdate = true;
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(
        offset: selection.isValid && selection.start >= 0
            ? selection.extentOffset.clamp(0, value.length)
            : value.length,
      ),
    );
    _programmaticUpdate = false;
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextTick);
    _focusNode.removeListener(_handleFocusTick);
    if (_ownsFocusNode) _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _handleTextTick() {
    if (mounted && !_programmaticUpdate) setState(() {});
  }

  void _handleFocusTick() {
    final hasFocus = _focusNode.hasFocus;
    if (hasFocus == _focused) return;
    _focused = hasFocus;
    if (!hasFocus) {
      _truncateResidueOnBlur();
      widget.onBlur?.call();
    }
    widget.onFocusChange?.call(hasFocus);
    setState(() {});
  }

  /// Blur re-check (upstream TextAreaFoundation.handleBlur, issue 2005): a
  /// composition aborted by blur can leave over-length pinyin residue.
  void _truncateResidueOnBlur() {
    final maxLength = widget.maxLength;
    if (maxLength == null || _controller.text.length <= maxLength) return;
    final truncated = _controller.text.substring(0, maxLength);
    if (widget.value == null) {
      _controller.value = TextEditingValue(
        text: truncated,
        selection: TextSelection.collapsed(offset: truncated.length),
      );
    }
    widget.onChanged?.call(truncated);
  }

  void _handleChanged(String value) => widget.onChanged?.call(value);

  void _handleSubmitted(String value) => widget.onEnterPress?.call();

  void _handleClear() {
    if (widget.disabled || widget.readonly) return;
    if (widget.value == null) {
      _controller.value = const TextEditingValue(
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    // Controlled: only notify (upstream handleClear); uncontrolled lands.
    widget.onChanged?.call('');
    widget.onClear?.call();
    _focusNode.requestFocus();
  }

  void _toggleEye() {
    if (widget.disabled) return;
    final selection = _controller.selection;
    setState(() => _eyeClosed = !_eyeClosed);
    // Toggling obscureText drops the selection; restore it afterwards.
    if (selection.isValid && selection.start >= 0) {
      scheduleMicrotask(() {
        if (!mounted) return;
        _controller.selection = TextSelection(
          baseOffset: selection.baseOffset.clamp(0, _controller.text.length),
          extentOffset: selection.extentOffset.clamp(
            0,
            _controller.text.length,
          ),
        );
      });
    }
    _focusNode.requestFocus();
  }

  KeyEventResult _handleModeKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      _toggleEye();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  bool get _clearVisible {
    return widget.showClear &&
        !widget.disabled &&
        !widget.readonly &&
        _controller.text.isNotEmpty &&
        (_hovering || _focused);
  }

  bool get _modeVisible =>
      widget.mode == SemiInputMode.password && !widget.disabled;

  bool get _suffixVisible =>
      widget.suffix != null && !(_clearVisible && widget.hideSuffix);

  (Color, Color) _resolveDecoration(SemiResolvedInputThemeData t) {
    if (widget.bare) {
      return (const Color(0x00000000), const Color(0x00000000));
    }
    if (widget.disabled) {
      return (t.colorInputDisabledBgDefault, t.colorInputDefaultBorderDefault);
    }
    final status = widget.validateStatus;
    Color bg, border;
    if (status == SemiInputStatus.error) {
      if (_focused) {
        bg = t.colorInputDangerBgFocus;
        border = t.colorInputDangerBorderFocus;
      } else if (_hovering) {
        bg = t.colorInputDangerBgHover;
        border = t.colorInputDangerBorderHover;
      } else {
        bg = t.colorInputDangerBgDefault;
        border = t.colorInputDangerBorderDefault;
      }
    } else if (status == SemiInputStatus.warning) {
      if (_focused) {
        bg = t.colorInputWarningBgFocus;
        border = t.colorInputWarningBorderFocus;
      } else if (_hovering) {
        bg = t.colorInputWarningBgHover;
        border = t.colorInputWarningBorderHover;
      } else {
        bg = t.colorInputWarningBgDefault;
        border = t.colorInputWarningBorderDefault;
      }
    } else if (_focused) {
      bg = t.colorInputDefaultBgFocus;
      border = t.colorInputDefaultBorderFocus;
    } else if (_hovering) {
      bg = t.colorInputDefaultBgHover;
      border = t.colorInputDefaultBorderHover;
    } else {
      bg = t.colorInputDefaultBgDefault;
      border = t.colorInputDefaultBorderDefault;
    }
    if (widget.borderless) {
      if (_focused) {
        // `:focus-within:not(:active)` keeps the border, drops the fill.
        bg = const Color(0x00000000);
      } else {
        // Idle borderless is fully transparent, but error/warning keep the
        // focused-status border outside focus (`borderless 非 focus 也保持描边`).
        if (!_hovering) bg = const Color(0x00000000);
        if (status == SemiInputStatus.error) {
          border = t.colorInputDangerBorderFocus;
        } else if (status == SemiInputStatus.warning) {
          border = t.colorInputWarningBorderFocus;
        } else {
          border = const Color(0x00000000);
        }
      }
    }
    return (bg, border);
  }

  double _wrapperHeight(SemiResolvedInputThemeData t) => switch (widget.size) {
    SemiInputSize.small => t.heightInputWrapperSmall,
    SemiInputSize.normal => t.heightInputWrapperDefault,
    SemiInputSize.large => t.heightInputWrapperLarge,
  };

  double _fontSize(SemiThemeData global) => widget.size == SemiInputSize.large
      ? global.typography.fontSizeHeading6
      : global.typography.fontSizeRegular;

  TextStyle _editStyle(SemiThemeData global, SemiResolvedInputThemeData t) {
    final fontSize = _fontSize(global);
    final base = TextStyle(
      fontSize: fontSize,
      height: _InputMetrics.textLineHeight / fontSize,
      color: widget.disabled
          ? t.colorInputDisabledTextDefault
          : t.colorInputDefaultTextDefault,
    );
    return widget.inputStyle == null ? base : base.merge(widget.inputStyle);
  }

  TextStyle _slotStyle(SemiThemeData global, SemiResolvedInputThemeData t) {
    final fontSize = _fontSize(global);
    return TextStyle(
      fontSize: fontSize,
      height: _InputMetrics.textLineHeight / fontSize,
      fontWeight: t.fontInputPrefixSuffixFontWeight,
      color: widget.disabled
          ? t.colorInputDisabledTextDefault
          : t.colorInputPrefixTextDefault,
    );
  }

  TextStyle _addonStyle(SemiThemeData global, SemiResolvedInputThemeData t) {
    final fontSize = global.typography.fontSizeRegular;
    return TextStyle(
      fontSize: fontSize,
      height: _InputMetrics.textLineHeight / fontSize,
      color: widget.disabled
          ? t.colorInputDisabledTextDefault
          : t.colorInputPrefixTextDefault,
    );
  }

  Widget _slot(Object value, TextStyle style, SemiResolvedInputThemeData t) {
    // The surrounding Row stretches slots to the wrapper height; center the
    // slot content on the horizontal axis (upstream flex `align-items:center`).
    final Widget content;
    if (value is String) {
      content = Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: t.spacingInputPrefixSuffixMarginX,
        ),
        child: Text(value, style: style, maxLines: 1),
      );
    } else if (value is SemiIcon) {
      content = Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: t.spacingInputPrefixIconMarginX,
          vertical: t.spacingInputPrefixIconMarginY,
        ),
        child: value,
      );
    } else {
      content = value as Widget;
    }
    return Center(widthFactor: 1, child: content);
  }

  Widget _addon(
    Object value,
    TextStyle style,
    SemiResolvedInputThemeData t, {
    required bool before,
  }) {
    final radius = t.radiusInputWrapper;
    final side = BorderSide(
      width: before ? t.widthInputPrependBorder : t.widthInputAppendBorder,
      color: t.colorInputDefaultBorderDefault,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colorInputDefaultBgDefault,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(before ? radius : 0),
          bottomLeft: Radius.circular(before ? radius : 0),
          topRight: Radius.circular(before ? 0 : radius),
          bottomRight: Radius.circular(before ? 0 : radius),
        ),
        border: before ? Border(right: side) : Border(left: side),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: t.spacingInputPrependPaddingX,
          vertical: t.spacingInputPrependPaddingY,
        ),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: value is String
              ? Text(value, style: style, maxLines: 1)
              : value as Widget,
        ),
      ),
    );
  }

  bool get _suffixIsIcon => widget.suffix is SemiIcon;

  double _clearSlotWidth(SemiResolvedInputThemeData t) {
    // input.scss specificity: `__with-suffix-icon + clearable` beats
    // `modebtn + clearable`; both beat the plain `min-width: $width-input-icon`.
    double width;
    if (_suffixVisible && _suffixIsIcon) {
      width = t.widthInputIconClearBeforeSuffix;
    } else if (_modeVisible) {
      width = t.widthInputIconClearBeforeModebtn;
    } else {
      width = t.widthInputIcon;
    }
    if (_suffixVisible) {
      // `$spacing-input_clearBtn_withSuffix-marginLeft: -$spacing-base-tight`
      // landed as the CSS `margin-left: -12px` semantics: a negative start
      // inset on the clear slot (slot shrinks by 12).
      width += t.spacingInputClearBtnWithSuffixMarginLeft.start;
    }
    return width < 0 ? 0 : width;
  }

  void _focusFromSlot() {
    if (widget.disabled || _focused) return;
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final global = SemiTheme.of(context);
    final t = SemiInputTheme.resolve(context);
    final fontSize = _fontSize(global);
    final editStyle = _editStyle(global, t);
    final slotStyle = _slotStyle(global, t);
    final (bg, borderColor) = _resolveDecoration(t);
    final borderWidth = widget.bare
        ? 0.0
        : _focused
        ? t.widthInputWrapperFocusBorder
        : t.widthInputWrapperBorder;
    final withPrefix = widget.prefix != null || widget.insetLabel != null;
    final suffixVisible = _suffixVisible;
    final clearVisible = _clearVisible;

    final placeholderStyle = TextStyle(
      fontSize: fontSize,
      height: _InputMetrics.textLineHeight / fontSize,
      color: widget.disabled
          ? t.colorInputDisabledTextDefault
          : t.colorInputPlaceholderTextDefault,
    );

    Widget buildEdit(double? forcedWidth) {
      return Listener(
        // Whole-box focus like the textarea's _editArea: the padding strips
        // around the EditableText are part of the field's click area.
        behavior: HitTestBehavior.translucent,
        onPointerDown: widget.disabled
            ? null
            : (_) => _focusNode.requestFocus(),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: widget.bare || withPrefix ? 0 : t.spacingInputPaddingLeft,
            end: widget.bare || suffixVisible ? 0 : t.spacingInputPaddingRight,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final scale = MediaQuery.textScalerOf(context)
                  .scale(_InputMetrics.textLineHeight);
              final innerHeight = constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : _InputMetrics.textLineHeight;
              final slotHeight = math.min(scale, innerHeight);
              return Align(
                alignment: AlignmentDirectional.centerStart,
                child: SizedBox(
                  height: slotHeight,
                  width: forcedWidth,
                  child: ExcludeFocus(
                    excluding: widget.disabled,
                    child: IgnorePointer(
                      ignoring: widget.disabled,
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        // Fill the whole input box so every point is
                        // focusable/tappable (the EditableText shrinks to its
                        // text width and is zero-width when empty).
                        fit: StackFit.expand,
                        children: [
                          EditableText(
                            controller: _controller,
                            focusNode: _focusNode,
                            style: editStyle,
                            cursorColor:
                                editStyle.color ??
                                t.colorInputDefaultTextDefault,
                            backgroundCursorColor:
                                t.colorInputDisabledTextDefault,
                            readOnly: widget.readonly,
                            obscureText:
                                widget.mode == SemiInputMode.password &&
                                _eyeClosed,
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            onChanged: _handleChanged,
                            onSubmitted: _handleSubmitted,
                            inputFormatters: [
                              if (widget.maxLength != null)
                                _CodeUnitTruncateFormatter(widget.maxLength!),
                            ],
                          ),
                          if (_controller.text.isEmpty &&
                              widget.placeholder != null)
                            IgnorePointer(
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  widget.placeholder!,
                                  style: placeholderStyle,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    final clearWidth = _clearSlotWidth(t);
    final clearAlignEnd = suffixVisible && _suffixIsIcon;

    Widget rowMain(bool bounded) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (withPrefix)
            GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              onTap: _focusFromSlot,
              child: _slot(widget.prefix ?? widget.insetLabel!, slotStyle, t),
            ),
          if (bounded)
            Expanded(child: buildEdit(double.infinity))
          else
            buildEdit(null),
          if (clearVisible)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _clearHovered = true),
              onExit: (_) => setState(() => _clearHovered = false),
              child: GestureDetector(
                key: SemiInput.clearButtonKey,
                behavior: HitTestBehavior.opaque,
                // Upstream `onMouseDown`: fire before the input can blur.
                onTapDown: (_) => _handleClear(),
                child: SizedBox(
                  width: clearWidth,
                  height: double.infinity,
                  child: Align(
                    alignment: clearAlignEnd
                        ? AlignmentDirectional.centerEnd
                        : AlignmentDirectional.center,
                    child:
                        widget.clearIcon ??
                        SemiIcon(
                          SemiIcons.clear,
                          customSize: fontSize,
                          color: _clearHovered
                              ? t.colorInputIconHover
                              : t.colorInputIconDefault,
                        ),
                  ),
                ),
              ),
            ),
          if (suffixVisible)
            GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              onTap: _focusFromSlot,
              child: _slot(widget.suffix!, slotStyle, t),
            ),
          if (_modeVisible)
            Focus(
              onKeyEvent: _handleModeKey,
              onFocusChange: (v) => setState(() => _modeBtnFocused = v),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _modeHovered = true),
                onExit: (_) => setState(() => _modeHovered = false),
                child: GestureDetector(
                  key: SemiInput.modeButtonKey,
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggleEye,
                  child: SizedBox(
                    width: t.widthInputIcon,
                    height: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          t.radiusInputWrapper,
                        ),
                        boxShadow: [
                          // `outline: $width-input_icon-outline solid
                          // $color-input_icon-outline` with `outline-offset:
                          // $width-input_icon-outlineOffset` — the -1px inset
                          // is approximated as a net 1px outer ring.
                          if (_modeBtnFocused)
                            BoxShadow(
                              color: t.colorInputIconOutline,
                              spreadRadius:
                                  t.widthInputIconOutline +
                                  t.widthInputIconOutlineOffset,
                            ),
                        ],
                      ),
                      child: Center(
                        child: SemiIcon(
                          _eyeClosed
                              ? SemiIcons.eyeClosedSolid
                              : SemiIcons.eyeOpened,
                          customSize: fontSize,
                          color: _modeHovered
                              ? t.colorInputIconHover
                              : t.colorInputIconDefault,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    Widget body = LayoutBuilder(
      builder: (context, constraints) {
        final bounded = constraints.hasBoundedWidth;
        final mainBox = DecoratedBox(
          key: SemiInput.wrapperKey,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(
                widget.addonBefore != null ? 0 : t.radiusInputWrapper,
              ),
              bottomLeft: Radius.circular(
                widget.addonBefore != null ? 0 : t.radiusInputWrapper,
              ),
              topRight: Radius.circular(
                widget.addonAfter != null ? 0 : t.radiusInputWrapper,
              ),
              bottomRight: Radius.circular(
                widget.addonAfter != null ? 0 : t.radiusInputWrapper,
              ),
            ),
            border: Border.all(width: borderWidth, color: borderColor),
          ),
          child: Padding(
            padding: EdgeInsets.all(borderWidth),
            child: ClipRect(child: rowMain(bounded)),
          ),
        );
        if (widget.addonBefore == null && widget.addonAfter == null) {
          return mainBox;
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.addonBefore != null)
              _addon(
                widget.addonBefore!,
                _addonStyle(global, t),
                t,
                before: true,
              ),
            Expanded(child: mainBox),
            if (widget.addonAfter != null)
              _addon(
                widget.addonAfter!,
                _addonStyle(global, t),
                t,
                before: false,
              ),
          ],
        );
      },
    );

    body = Semantics(
      textField: true,
      enabled: !widget.disabled,
      label: widget.semanticsLabel,
      validationResult: switch (widget.validateStatus) {
        SemiInputStatus.error => SemanticsValidationResult.invalid,
        SemiInputStatus.success => SemanticsValidationResult.valid,
        _ => SemanticsValidationResult.none,
      },
      child: body,
    );

    body = MouseRegion(
      cursor: widget.disabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.text,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: body,
    );

    return SizedBox(height: _wrapperHeight(t), child: body);
  }
}

/// A source-sized, non-Material multi-line text area (upstream Semi TextArea).
///
/// Shares the SemiInput value conventions (`value` non-null = controlled,
/// composition-guarded reconciliation, `maxLength` code-unit truncation with a
/// blur re-check). [autosize] accepts `true` (grow from [rows] unbounded) or a
/// [SemiTextAreaAutosize] with `minRows`/`maxRows` clamps; measurement uses
/// TextPainter over `value || placeholder || 'x'` (upstream `resizeTextarea`).
///
/// The counter shows when [showCounter] or [maxCount] is set (`current/total`,
/// danger-colored past `maxCount`). [disabledEnterStartNewLine] consumes plain
/// Enter at the keydown level (Shift+Enter still propagates) and still fires
/// [onEnterPress] — IME soft-keyboard newlines are text input and cannot be
/// intercepted on all platforms (see docs/semi_input.md).
class SemiTextArea extends StatefulWidget {
  const SemiTextArea({
    super.key,
    this.value,
    this.initialValue,
    this.rows = 4,
    this.autosize,
    this.maxCount,
    this.showCounter = false,
    this.showClear = false,
    this.disabledEnterStartNewLine = false,
    this.validateStatus = SemiInputStatus.normal,
    this.disabled = false,
    this.readonly = false,
    this.borderless = false,
    this.bare = false,
    this.placeholder,
    this.maxLength,
    this.onChanged,
    this.onEnterPress,
    this.onFocusChange,
    this.onBlur,
    this.onClear,
    this.controller,
    this.focusNode,
    this.inputStyle,
    this.semanticsLabel,
  }) : assert(
         controller == null || initialValue == null,
         'Provide either controller or initialValue, not both.',
       );

  /// Key of the bordered wrapper box.
  static const Key wrapperKey = Key('SemiTextArea.wrapper');

  /// Key of the clear button slot.
  static const Key clearButtonKey = Key('SemiTextArea.clearButton');

  /// Key of the counter row.
  static const Key counterKey = Key('SemiTextArea.counter');

  /// Non-null makes the textarea controlled (SemiInput convention).
  final String? value;

  /// Seed of the uncontrolled internal controller.
  final String? initialValue;

  /// Fallback height in rows (upstream `rows`, default 4).
  final int rows;

  /// `true` or [SemiTextAreaAutosize]; measured with TextPainter including
  /// the placeholder (upstream hidden-textarea measurement).
  final Object? autosize;

  /// Counter total; the counter renders `current/total` and turns danger past
  /// the limit. It does not truncate — use [maxLength] for that.
  final int? maxCount;

  /// Shows the counter even without [maxCount] (renders `current` only).
  final bool showCounter;

  /// Shows the clear button while hovering or focused with non-empty text.
  final bool showClear;

  /// Consumes plain Enter (Shift+Enter keeps inserting a newline).
  final bool disabledEnterStartNewLine;

  final SemiInputStatus validateStatus;
  final bool disabled;
  final bool readonly;
  final bool borderless;

  /// See [SemiInput.bare].
  final bool bare;
  final String? placeholder;

  /// Maximum length in UTF-16 code units; `0` forces the value empty.
  final int? maxLength;

  final ValueChanged<String>? onChanged;
  final VoidCallback? onEnterPress;
  final ValueChanged<bool>? onFocusChange;
  final VoidCallback? onBlur;
  final VoidCallback? onClear;

  /// External controller; never disposed by the widget.
  final TextEditingController? controller;

  /// External focus node; never disposed by the widget.
  final FocusNode? focusNode;

  /// Merged over the built-in editable text style (this wins).
  final TextStyle? inputStyle;
  final String? semanticsLabel;

  @override
  State<SemiTextArea> createState() => _SemiTextAreaState();
}

class _SemiTextAreaState extends State<SemiTextArea> {
  late TextEditingController _controller;
  late bool _ownsController;
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  bool _hovering = false, _focused = false;
  bool _clearHovered = false;

  bool _programmaticUpdate = false;

  @override
  void initState() {
    super.initState();
    _initController();
    _initFocusNode();
    _focusNode.addListener(_handleFocusTick);
  }

  void _initController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
      if (widget.value != null && widget.value != _controller.text) {
        _controller.text = widget.value!;
      }
    } else {
      _controller = TextEditingController(
        text: widget.value ?? widget.initialValue ?? '',
      );
      _ownsController = true;
    }
    _controller.addListener(_handleTextTick);
  }

  void _initFocusNode() {
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _ownsFocusNode = false;
    } else {
      _focusNode = FocusNode(debugLabel: 'SemiTextArea');
      _ownsFocusNode = true;
    }
  }

  @override
  void didUpdateWidget(SemiTextArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_handleTextTick);
      if (_ownsController) _controller.dispose();
      _initController();
    }
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_handleFocusTick);
      if (_ownsFocusNode) _focusNode.dispose();
      _initFocusNode();
      _focusNode.addListener(_handleFocusTick);
    }
    _syncFromValue();
  }

  void _syncFromValue() {
    final value = widget.value;
    if (value == null || value == _controller.text) return;
    if (_controller.value.composing != TextRange.empty) return;
    final selection = _controller.selection;
    _programmaticUpdate = true;
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(
        offset: selection.isValid && selection.start >= 0
            ? selection.extentOffset.clamp(0, value.length)
            : value.length,
      ),
    );
    _programmaticUpdate = false;
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextTick);
    _focusNode.removeListener(_handleFocusTick);
    if (_ownsFocusNode) _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _handleTextTick() {
    if (mounted && !_programmaticUpdate) setState(() {});
  }

  void _handleFocusTick() {
    final hasFocus = _focusNode.hasFocus;
    if (hasFocus == _focused) return;
    _focused = hasFocus;
    if (!hasFocus) {
      _truncateResidueOnBlur();
      widget.onBlur?.call();
    }
    widget.onFocusChange?.call(hasFocus);
    setState(() {});
  }

  void _truncateResidueOnBlur() {
    final maxLength = widget.maxLength;
    if (maxLength == null || _controller.text.length <= maxLength) return;
    final truncated = _controller.text.substring(0, maxLength);
    if (widget.value == null) {
      _controller.value = TextEditingValue(
        text: truncated,
        selection: TextSelection.collapsed(offset: truncated.length),
      );
    }
    widget.onChanged?.call(truncated);
  }

  void _handleChanged(String value) => widget.onChanged?.call(value);

  void _handleClear() {
    if (widget.disabled || widget.readonly) return;
    if (widget.value == null) {
      _controller.value = const TextEditingValue(
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    widget.onChanged?.call('');
    widget.onClear?.call();
    _focusNode.requestFocus();
  }

  /// Upstream TextAreaFoundation.handleKeyDown: `disabledEnterStartNewLine`
  /// blocks plain Enter (`e.key === 'Enter' && !e.shiftKey`), and keyCode 13
  /// always notifies `onEnterPress`.
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.enter) {
      return KeyEventResult.ignored;
    }
    widget.onEnterPress?.call();
    if (widget.disabledEnterStartNewLine &&
        !HardwareKeyboard.instance.isShiftPressed) {
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  bool get _clearVisible {
    return widget.showClear &&
        !widget.disabled &&
        !widget.readonly &&
        _controller.text.isNotEmpty &&
        (_hovering || _focused);
  }

  (Color, Color) _resolveDecoration(SemiResolvedInputThemeData t) {
    if (widget.disabled || widget.readonly) {
      // Upstream `-disabled, -readonly` share the disabled fill/text.
      return (t.colorInputDisabledBgDefault, t.colorInputDefaultBorderDefault);
    }
    final status = widget.validateStatus;
    Color bg, border;
    if (status == SemiInputStatus.error) {
      if (_focused) {
        bg = t.colorInputDangerBgFocus;
        border = t.colorInputDangerBorderFocus;
      } else if (_hovering) {
        bg = t.colorInputDangerBgHover;
        border = t.colorInputDangerBorderHover;
      } else {
        bg = t.colorInputDangerBgDefault;
        border = t.colorInputDangerBorderDefault;
      }
    } else if (status == SemiInputStatus.warning) {
      if (_focused) {
        bg = t.colorInputWarningBgFocus;
        border = t.colorInputWarningBorderFocus;
      } else if (_hovering) {
        bg = t.colorInputWarningBgHover;
        border = t.colorInputWarningBorderHover;
      } else {
        bg = t.colorInputWarningBgDefault;
        border = t.colorInputWarningBorderDefault;
      }
    } else if (_focused) {
      bg = t.colorInputDefaultBgFocus;
      border = t.colorInputDefaultBorderFocus;
    } else if (_hovering) {
      bg = t.colorInputDefaultBgHover;
      border = t.colorInputDefaultBorderHover;
    } else {
      bg = t.colorInputDefaultBgDefault;
      border = t.colorInputDefaultBorderDefault;
    }
    if (widget.borderless) {
      if (_focused) {
        bg = const Color(0x00000000);
      } else {
        if (!_hovering) bg = const Color(0x00000000);
        if (status == SemiInputStatus.error) {
          border = t.colorInputDangerBorderFocus;
        } else if (status == SemiInputStatus.warning) {
          border = t.colorInputWarningBorderFocus;
        } else {
          border = const Color(0x00000000);
        }
      }
    }
    return (bg, border);
  }

  TextStyle _editStyle(SemiThemeData global, SemiResolvedInputThemeData t) {
    final fontSize = global.typography.fontSizeRegular;
    final base = TextStyle(
      fontSize: fontSize,
      height: _InputMetrics.textLineHeight / fontSize,
      color: widget.disabled
          ? t.colorInputDisabledTextDefault
          : t.colorInputDefaultTextDefault,
    );
    return widget.inputStyle == null ? base : base.merge(widget.inputStyle);
  }

  double _measure(
    BuildContext context,
    String text,
    TextStyle style,
    double maxWidth,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: maxWidth);
    return painter.height;
  }

  @override
  Widget build(BuildContext context) {
    final global = SemiTheme.of(context);
    final t = SemiInputTheme.resolve(context);
    final editStyle = _editStyle(global, t);
    final (bg, borderColor) = _resolveDecoration(t);
    final borderWidth = widget.bare
        ? 0.0
        : _focused
        ? t.widthInputWrapperFocusBorder
        : t.widthInputWrapperBorder;
    final clearVisible = _clearVisible;

    final padTop = t.spacingTextareaPaddingY;
    final padBottom = t.spacingTextareaPaddingY;
    final padStart = t.spacingTextareaPaddingX;
    final padEnd = widget.showClear
        ? t.spacingTextareaWithShowClearPaddingRight
        : t.spacingTextareaPaddingX;
    final textStyle = editStyle;

    final placeholderStyle = TextStyle(
      fontSize: editStyle.fontSize,
      height: editStyle.height,
      color: widget.disabled
          ? t.colorInputDisabledTextDefault
          : t.colorInputPlaceholderTextDefault,
    );

    Widget body = LayoutBuilder(
      builder: (context, constraints) {
        final innerWidth = math.max(
          0.0,
          constraints.maxWidth -
              2 * borderWidth -
              2 * t.widthTextareaBorder -
              padStart -
              padEnd,
        );
        final rowHeight = _measure(context, 'x', textStyle, innerWidth);
        final padSum = padTop + padBottom + 2 * t.widthTextareaBorder;
        final autosize = widget.autosize;
        final double contentHeight;
        if (autosize == true || autosize is SemiTextAreaAutosize) {
          final minRows = autosize is SemiTextAreaAutosize
              ? (autosize.minRows ?? widget.rows)
              : widget.rows;
          final maxRows = autosize is SemiTextAreaAutosize
              ? autosize.maxRows
              : null;
          final measureText = _controller.text.isNotEmpty
              ? _controller.text
              : (widget.placeholder ??
                    _InputMetrics.placeholderMeasureFallback);
          // Upstream `node.value || node.placeholder || 'x'` measured with the
          // hidden textarea including padding and border.
          final measured =
              _measure(context, measureText, textStyle, innerWidth) + padSum;
          contentHeight = math.max(rowHeight * minRows + padSum, measured);
          final capped = maxRows == null
              ? contentHeight
              : math.min(contentHeight, rowHeight * maxRows + padSum);
          return SizedBox(
            height: capped,
            child: _editArea(
              t,
              textStyle,
              placeholderStyle,
              padStart,
              padEnd,
              padTop,
              padBottom,
            ),
          );
        }
        contentHeight = rowHeight * widget.rows + padSum;
        return SizedBox(
          height: contentHeight,
          child: _editArea(
            t,
            textStyle,
            placeholderStyle,
            padStart,
            padEnd,
            padTop,
            padBottom,
          ),
        );
      },
    );

    final children = <Widget>[
      body,
      if (widget.showCounter || widget.maxCount != null) _counter(global, t),
    ];

    Widget column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );

    column = Stack(
      children: [
        column,
        if (clearVisible)
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                end: t.spacingTextareaIconRight,
              ),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _clearHovered = true),
                onExit: (_) => setState(() => _clearHovered = false),
                child: GestureDetector(
                  key: SemiTextArea.clearButtonKey,
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) => _handleClear(),
                  child: SizedBox(
                    height: t.heightTextareaDefault,
                    width: t.widthTextareaIcon,
                    child: Center(
                      child: SemiIcon(
                        SemiIcons.clear,
                        customSize: editStyle.fontSize,
                        color: _clearHovered
                            ? t.colorTextareaIconHover
                            : t.colorTextareaIconDefault,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    Widget decorated = DecoratedBox(
      key: SemiTextArea.wrapperKey,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(t.radiusInputWrapper),
        border: Border.all(width: borderWidth, color: borderColor),
      ),
      child: Padding(padding: EdgeInsets.all(borderWidth), child: column),
    );

    decorated = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _handleKey,
      child: decorated,
    );

    decorated = Semantics(
      textField: true,
      enabled: !widget.disabled,
      label: widget.semanticsLabel,
      validationResult: switch (widget.validateStatus) {
        SemiInputStatus.error => SemanticsValidationResult.invalid,
        SemiInputStatus.success => SemanticsValidationResult.valid,
        _ => SemanticsValidationResult.none,
      },
      child: decorated,
    );

    return MouseRegion(
      cursor: widget.disabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.text,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: decorated,
    );
  }

  Widget _editArea(
    SemiResolvedInputThemeData t,
    TextStyle textStyle,
    TextStyle placeholderStyle,
    double padStart,
    double padEnd,
    double padTop,
    double padBottom,
  ) {
    return Listener(
      // The whole edit box — padding included — focuses the field, matching
      // web inputs where the padding is part of the input's hit area.
      // EditableText alone only hit-tests its own content box, so without
      // this the padding strips are dead zones (taps there did nothing).
      behavior: HitTestBehavior.translucent,
      onPointerDown: widget.disabled ? null : (_) => _focusNode.requestFocus(),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: padStart,
          top: padTop,
          end: padEnd,
          bottom: padBottom,
        ),
        child: ExcludeFocus(
          excluding: widget.disabled,
          child: IgnorePointer(
            ignoring: widget.disabled,
            child: Stack(
              // Fill the whole edit box so every point is focusable/tappable;
              // a loose-fitting Stack would leave only the (zero-width, empty)
              // EditableText hittable in the top-left corner.
              fit: StackFit.expand,
              children: [
                ClipRect(
                  child: EditableText(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: textStyle,
                    cursorColor:
                        textStyle.color ?? t.colorInputDefaultTextDefault,
                    backgroundCursorColor: t.colorInputDisabledTextDefault,
                    readOnly: widget.readonly,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    onChanged: _handleChanged,
                    inputFormatters: [
                      if (widget.maxLength != null)
                        _CodeUnitTruncateFormatter(widget.maxLength!),
                    ],
                  ),
                ),
                if (_controller.text.isEmpty && widget.placeholder != null)
                  IgnorePointer(
                    child: Text(widget.placeholder!, style: placeholderStyle),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _counter(SemiThemeData global, SemiResolvedInputThemeData t) {
    final current = _controller.text.length;
    final total = widget.maxCount;
    final label = total != null ? '$current/$total' : '$current';
    final exceed = total != null && current > total;
    Color color;
    if (exceed) {
      color = t.colorInputCounterDangerTextDefault;
    } else if (widget.borderless && !_focused) {
      // textarea.scss `borderless + error/warning` recolors the counter.
      if (widget.validateStatus == SemiInputStatus.error) {
        color = t.colorInputDangerBorderFocus;
      } else if (widget.validateStatus == SemiInputStatus.warning) {
        color = t.colorInputWarningBorderFocus;
      } else {
        color = t.colorInputCounterTextDefault;
      }
    } else {
      color = t.colorInputCounterTextDefault;
    }
    final fontSize = global.typography.fontSizeSmall;
    return Container(
      key: SemiTextArea.counterKey,
      constraints: BoxConstraints(minHeight: t.heightTextareaCounter),
      padding: EdgeInsets.fromLTRB(
        t.spacingTextareaCounterPaddingLeft,
        t.spacingTextareaCounterPaddingTop,
        t.spacingTextareaCounterPaddingRight,
        t.spacingTextareaCounterPaddingBottom,
      ),
      alignment: AlignmentDirectional.centerEnd,
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          height: global.typography.lineHeightSmall / fontSize,
          color: widget.disabled ? t.colorInputDisabledTextDefault : color,
        ),
      ),
    );
  }
}

/// Widget-internal metrics and provenance anchors (upstream values kept out of
/// the theme). See tool/generate_input.py for the 97 = 94 themed + 3 INTERNAL
/// accounting; the hardcodes below are the 另列 entries.
abstract final class _InputMetrics {
  /// Upstream `$transform_scale-input: var(--semi-transform_scale-none)`
  /// (packages/semi-foundation/input/animation.scss) is `scale(1)` — no
  /// transform is applied.
  // ignore: unused_field
  static const double transformScaleInput = 1;

  /// Upstream `$spacing-input_group_withTopLabel-marginTop: $spacing-base`
  /// (packages/semi-foundation/input/variables.scss) — InputGroup top-label
  /// margin; InputGroup is deferred (see docs/semi_input.md).
  // ignore: unused_field
  static const double spacingInputGroupWithTopLabelMarginTop = 16;

  /// Upstream `$spacing-input_group_withTopLabel-marginBottom: $spacing-base`
  /// (packages/semi-foundation/input/variables.scss) — InputGroup top-label
  /// margin; InputGroup is deferred (see docs/semi_input.md).
  // ignore: unused_field
  static const double spacingInputGroupWithTopLabelMarginBottom = 16;

  /// textareaFoundation.ts `resizeTextarea` — `node.value || node.placeholder || 'x'`
  /// (packages/semi-foundation/input/textareaFoundation.ts): the autosize
  /// measure falls back to the placeholder and then to `'x'`.
  static const String placeholderMeasureFallback = 'x';

  /// input.scss `.semi-input-clearbtn/.semi-input-modebtn:focus-visible` —
  /// `outline: $width-input_icon-outline solid $color-input_icon-outline`
  /// painted as the keyboard focus ring around the password mode button.
  // ignore: unused_field
  static const String focusRingOutline =
      r'outline: $width-input_icon-outline solid $color-input_icon-outline';

  /// input.scss — `outline-offset: $width-input_icon-outlineOffset` (-1px);
  /// approximated as spreadRadius = outline + offset (net 1px outer ring).
  // ignore: unused_field
  static const String focusRingOutlineOffset =
      r'outline-offset: $width-input_icon-outlineOffset';

  /// textarea.scss `.semi-input-textarea-counter` — `text-align: right`
  /// (RTL flips to left; TextAlign/AlignmentDirectional.centerEnd mirrors).
  // ignore: unused_field
  static const String counterTextAlignRight = 'text-align: right';

  /// textarea.scss `.semi-input-textarea-wrapper .semi-input-clearbtn` —
  /// `position: absolute; top: 0;` (top-end anchored clear button).
  // ignore: unused_field
  static const String textareaClearAnchor = 'position: absolute; top: 0;';

  /// Port-plan text metrics (`字号/行高 14/22、14/22、16/22`): the editable
  /// text line box is 22 logical px at every size. Upstream CSS
  /// `line-height: $height-input_small/$height-input_default/$height-input_large`
  /// (22/30/38) is the browser line-box-centering trick; Flutter centers this
  /// fixed 22px line inside the upstream-precise slots instead.
  static const double textLineHeight = 22;
}
