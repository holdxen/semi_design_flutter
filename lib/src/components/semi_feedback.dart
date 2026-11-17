// SemiFeedback — 上游 packages/semi-ui/feedback/index.tsx 与
// packages/semi-foundation/feedback/{feedback.scss,variables.scss,foundation.ts,
// constants.ts} 的移植；popup 模式弹层与 SemiSideSheet 同底座（vendored
// flutter_smart_dialog 引擎，lib/src/overlay/dialog_engine，PROVENANCE.md）。
//
// 主题对账 **16 = 16 FIELDS + 0 MOTION + 0 INTERNAL**（variables.scss 16
// 声明：color 1、width 2、spacing 8、font 4、radius 1；无 animation.scss——
// feedback.scss 重定义 sidesheet keyframes 计 HARDCODES；`$module` 胶水与
// 空 rtl.scss 不计，banner `22 = 22 FIELDS + 0 MOTION + 0 INTERNAL` 先例）。
// 0 死变量（16 声明全部被 feedback.scss 逐条消费）；其中 6 条 thank_text
// 声明仅被 `&-thank-text` 公共样式钩子消费（上游 JSX 从不渲染该类）——
// 「字段留档不消费」，字段名不落本文件（test_generate_feedback.py 断言）。
//
// HARDCODES（另列，生成器锚点逐字留档）：
// - constants.ts `MODE: ['modal', 'popup']` /
//   `TYPE: ['text', 'emoji', 'radio', 'checkbox', 'custom']`
// - constants.ts Emoji `bad: '😞'` / `normal: '😐'` / `good: '😃'`
// - index.tsx defaultProps `mode: 'popup'` / `type: 'emoji'`
// - emojiNode：条目 `role="button"` `tabIndex={0}`
//   `aria-pressed={item === emoji}`；键盘 `e.key === 'Enter' || e.key === ' '`
//   选中；feedback.scss `filter: grayscale(100%)`，`&:hover, &-selected`
//   `filter: none;`；`font-family: Inter`；`user-select: none`
// - emojiNode：`emoji === Emoji.bad && <TextArea` 追问输入
//   `placeholder={locale.optionalPlaceholder}`；textNode
//   `placeholder={locale.placeholder}`
// - radioNode/checkboxNode：`direction='vertical'`
// - renderFooter：按钮 `type='primary'`，提交钮 `theme='solid'` +
//   `disabled={this.disableSubmitButton()}`
// - render modal 分支：`okText={locale.submit}` / `cancelText={locale.cancel}`
//   / `okButtonProps={{ disabled: disabledOkButton, ...this.props.okButtonProps }}`
//   （`handleModalOk`/`handleModalCancel` 返回 promise 交 Modal 计 loading）
// - render popup 分支（SideSheet）：`mask={false}` `disableScroll={false}`
//   `canVerticalSetWidth={true}` `placement="bottom"` `height="auto"`；
//   afterVisibleChange wrapper `this.props.afterClose()`
// - getRestProps 省略表：`'textAreaProps', 'radioGroupProps', 'checkboxGroupProps', 'renderContent', 'onCancel', 'onOk'`
//   ；popup 追加 `['okButtonProps', 'cancelButtonProps']`
// - foundation：`!Boolean(value) || (Array.isArray(value) && value.length === 0)`
//   提交钮门槛；promise 状态机 `onOKReturnPromiseStatus` /
//   `onCancelReturnPromiseStatus`，成功复位 `value: null` / `setValue(null)`
// - locale zh_CN：`请提供更多反馈` / `请提供更多反馈（选填）` / `提交` / `取消`
// - feedback.scss：`&-thank-text` 钩子（字段留档不消费）；`&-footer`
//   `justify-content: flex-end`；`.#{$prefix}-modal` 宽度覆写族（`&.#{$module}-text`
//   文本模式仍取 `$width-feedback` 的注释矛盾 quirk）；
//   `.#{$prefix}-sidesheet-inner` 圆角；`.#{$prefix}-checkboxGroup-vertical`
//   row-gap 覆写；`&-bottom` 锚定 `right: $spacing-feedback_sidesheet_bottom-right`
//   / `left: auto` 与 `.#{$prefix}-sidesheet-inner-wrap` 底距（重复两块
//   `&-bottom` 声明 quirk）；`@keyframes #{$prefix}-sidesheet-slideShow_bottom`
//   / `@keyframes #{$prefix}-sidesheet-slideHide_bottom` 起点
//   `translateY(calc(100% + $spacing-feedback_sidesheet_bottom_inner_wrap-bottom))`；
//   `.#{$prefix}-sidesheet-fixed` `top: auto`（fixed 模式）
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../overlay/dialog_engine/flutter_smart_dialog.dart';
import '../theme/semi_checkbox_theme.dart';
import '../theme/semi_checkbox_theme_data.dart';
import '../theme/semi_feedback_theme.dart';
import '../theme/semi_feedback_theme_data.dart';
import '../theme/semi_modal_theme.dart';
import '../theme/semi_side_sheet_theme.dart';
import '../theme/semi_side_sheet_theme_data.dart';
import '../theme/semi_theme.dart';
import '../tokens/token_types.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icons.dart';
import 'semi_button.dart';
import 'semi_checkbox.dart';
import 'semi_input.dart';
import 'semi_inset_shadow.dart';
import 'semi_modal.dart';
import 'semi_radio.dart';

/// 展示容器（上游 `strings.MODE`，缺省 `popup`）。
enum SemiFeedbackMode { modal, popup }

/// 反馈内容类型（上游 `strings.TYPE`，缺省 `emoji`）。
enum SemiFeedbackType { text, emoji, radio, checkbox, custom }

/// emoji 类型的值载荷（上游 `EmojiResult { emoji?, text? }`）。
@immutable
class SemiFeedbackEmojiResult {
  const SemiFeedbackEmojiResult({this.emoji, this.text});

  /// 选中的 emoji（constants.ts `strings.Emoji` 之一）。
  final String? emoji;

  /// `emoji === Emoji.bad` 追问 TextArea 的补充说明。
  final String? text;

  SemiFeedbackEmojiResult copyWith({String? emoji, String? text}) =>
      SemiFeedbackEmojiResult(
        emoji: emoji ?? this.emoji,
        text: text ?? this.text,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiFeedbackEmojiResult &&
          emoji == other.emoji &&
          text == other.text;

  @override
  int get hashCode => Object.hash(emoji, text);

  @override
  String toString() => 'SemiFeedbackEmojiResult(emoji: $emoji, text: $text)';
}

/// TextArea 透传配置（上游 `textAreaProps`，省略 `onChange`——由组件内接后
/// 转发 [onChange]）。
@immutable
class SemiFeedbackTextAreaProps {
  const SemiFeedbackTextAreaProps({
    this.placeholder,
    this.rows = 4,
    this.autosize,
    this.maxCount,
    this.showCounter = false,
    this.showClear = false,
    this.maxLength,
    this.disabled = false,
    this.readonly = false,
    this.onChange,
  });

  /// 覆盖 locale 占位文案（text 与 emoji 追问两处共用）。
  final String? placeholder;
  final int rows;
  final Object? autosize;
  final int? maxCount;
  final bool showCounter;
  final bool showClear;
  final int? maxLength;
  final bool disabled;
  final bool readonly;

  /// 输入通知（上游 `textAreaProps.onChange`）。
  final ValueChanged<String>? onChange;
}

/// RadioGroup 透传配置（上游 `radioGroupProps`，省略 `onChange`——由组件内接
/// 后转发 [onChanged]；`direction='vertical'` 固定）。
@immutable
class SemiFeedbackRadioGroupProps {
  const SemiFeedbackRadioGroupProps({
    this.options,
    this.defaultValue,
    this.disabled = false,
    this.type = SemiRadioType.normal,
    this.buttonSize = SemiRadioButtonSize.middle,
    this.mode = SemiRadioMode.normal,
    this.onChanged,
  });

  final List<SemiRadioOption>? options;
  final Object? defaultValue;
  final bool disabled;
  final SemiRadioType type;
  final SemiRadioButtonSize buttonSize;
  final SemiRadioMode mode;

  /// 选择通知（上游 `radioGroupProps.onChange`）。
  final ValueChanged<SemiRadioChangeEvent>? onChanged;
}

/// CheckboxGroup 透传配置（上游 `checkboxGroupProps`，省略 `onChange`——由
/// 组件内接后转发 [onChanged]；`direction='vertical'` 固定）。
@immutable
class SemiFeedbackCheckboxGroupProps {
  const SemiFeedbackCheckboxGroupProps({
    this.options,
    this.defaultValue,
    this.disabled = false,
    this.type = SemiCheckboxType.normal,
    this.onChanged,
  });

  final List<SemiCheckboxOption>? options;
  final List<Object>? defaultValue;
  final bool disabled;
  final SemiCheckboxType type;

  /// 勾选通知（上游 `checkboxGroupProps.onChange`）。
  final ValueChanged<List<Object>>? onChanged;
}

/// 反馈收集弹层（Semi Feedback）。
///
/// 两种展示容器：`mode: 'modal'`（[SemiModal]）与 `mode: 'popup'`（默认，
/// 底部浮动弹层——上游 SideSheet 组合 + feedback.scss 几何覆写，等价内建，
/// 见 docs/semi_feedback.md 差异清单）。五种内容 [type]（缺省 emoji）：
/// text（TextArea）、emoji（三档表情 + bad 追问）、radio / checkbox
/// （vertical 组）、custom（[content]）。
///
/// 值模型（上游 `FeedbackValue = string | string[] | EmojiResult`）由
/// [onValueChange] 报告：text → String、emoji → [SemiFeedbackEmojiResult]、
/// radio → 选项值、checkbox → `List<Object>`；提交成功复位 null（不回调
/// [onValueChange]）。提交钮门槛 `!Boolean(value) || (Array.isArray(value)
/// && value.length === 0)`：null / 空串 / 空列表禁用，[okDisabled] 可覆写。
/// [onOk]/[onCancel] 返回 `Future` 时对应按钮 loading，resolve 后复位值，
/// reject 仅去 loading 并保持打开（foundation promise 状态机）。
class SemiFeedback extends StatefulWidget {
  const SemiFeedback({
    super.key,
    this.visible = false,
    this.mode = SemiFeedbackMode.popup,
    this.type = SemiFeedbackType.emoji,
    this.title,
    this.content,
    this.renderContent,
    this.onValueChange,
    this.textAreaProps,
    this.radioGroupProps,
    this.checkboxGroupProps,
    this.footer,
    this.okText,
    this.cancelText,
    this.okDisabled,
    this.okLoading,
    this.cancelLoading,
    this.onOk,
    this.onCancel,
    this.afterClose,
    this.afterVisibleChange,
    this.mask,
    this.maskClosable,
    this.closable = true,
    this.closeIcon,
    this.closeOnEsc,
    this.motion = true,
    this.width,
  });

  /// 显隐（声明式）；关闭权在使用方（onOk/onCancel/关闭钮只通知）。
  final bool visible;

  /// 展示容器（缺省 `popup`）。
  final SemiFeedbackMode mode;

  /// 内容类型（缺省 `emoji`）。
  final SemiFeedbackType type;

  /// 标题：String | Widget（popup 为 SideSheet 头部标题；modal 为 Modal 标题）。
  final Object? title;

  /// `type: 'custom'` 的内容（上游 `children`）。
  final Widget? content;

  /// 内容包装（上游 `renderContent`，仅包装非空内容）。
  final Widget Function(Widget content)? renderContent;

  /// 值变化通知（上游 `onValueChange`，每次值变更回调）。
  final ValueChanged<Object?>? onValueChange;

  /// TextArea 配置（text / emoji 追问共用）。
  final SemiFeedbackTextAreaProps? textAreaProps;

  /// RadioGroup 配置（type: 'radio'）。
  final SemiFeedbackRadioGroupProps? radioGroupProps;

  /// CheckboxGroup 配置（type: 'checkbox'）。
  final SemiFeedbackCheckboxGroupProps? checkboxGroupProps;

  /// 自定义 footer（整体替换按钮行，两模式皆生效）。
  final Widget? footer;

  /// 提交按钮文案（缺省「提交」，上游 locale `submit`）。
  final String? okText;

  /// 取消按钮文案（缺省「取消」，上游 locale `cancel`）。
  final String? cancelText;

  /// 提交钮禁用覆写（null 门槛自动：`!Boolean(value) || …`）。
  final bool? okDisabled;

  /// 提交钮 loading 覆写（null 时跟随 [onOk] 返回的 `Future`）。
  final bool? okLoading;

  /// 取消钮 loading 覆写（null 时跟随 [onCancel] 返回的 `Future`）。
  final bool? cancelLoading;

  /// 提交回调；返回 `Future` 时按钮 loading，resolve 后复位值。
  final FutureOr<void> Function()? onOk;

  /// 取消回调（关闭钮/蒙层点击/Esc 也走这里）；返回 `Future` 时按钮 loading。
  final FutureOr<void> Function()? onCancel;

  /// 弹层关闭后的通知（modal 交 SemiModal；popup 在出场动画完成后补发）。
  final VoidCallback? afterClose;

  /// 动画完成回调（popup：入场 `true` / 出场 `false`，上游 `afterVisibleChange`）。
  final void Function(bool isVisible)? afterVisibleChange;

  /// 蒙层显隐（缺省 modal: true、popup: false——`mask={false}` fixed 模式
  /// 投影 + 点击穿透）。
  final bool? mask;

  /// 蒙层点击触发 [onCancel]（缺省 true）。
  final bool? maskClosable;

  /// 关闭按钮（缺省 true）。
  final bool closable;

  /// 关闭按钮图标（缺省 IconClose）。
  final Widget? closeIcon;

  /// Esc 触发 [onCancel]（缺省 modal: true、popup: false）。
  final bool? closeOnEsc;

  /// 弹层切换动效（缺省 true）。
  final bool motion;

  /// 宽度覆写（缺省 modal: `$width-feedback` 400；popup: text 600 / 其余 400
  /// ——feedback.scss `.semi-modal` 与 `.-text` sidesheet 覆写）。
  final double? width;

  @override
  State<SemiFeedback> createState() => _SemiFeedbackState();
}

class _SemiFeedbackState extends State<SemiFeedback> {
  /// foundation state `value`（FeedbackValue 联合）。
  Object? _value;

  /// promise 状态机 `onOKReturnPromiseStatus` / `onCancelReturnPromiseStatus`。
  bool _okPending = false;
  bool _cancelPending = false;

  /// emoji 条目 hover（`&:hover` 还原灰度）。
  String? _hoveredEmoji;

  /// foundation handleEmojiClick：`notifyValueChange({ emoji: value })`。
  void _onEmojiSelected(String emoji) {
    _setValue(SemiFeedbackEmojiResult(emoji: emoji));
  }

  /// foundation handleTextChange：`notifyTextAreaChange` + `notifyValueChange(value)`。
  void _onTextChanged(String text) {
    widget.textAreaProps?.onChange?.call(text);
    _setValue(text);
  }

  /// foundation handleEmojiReasonChange：合并 `{ ...oldValue, text: value }`。
  void _onEmojiReasonChanged(String text) {
    widget.textAreaProps?.onChange?.call(text);
    final old = _value;
    _setValue(
      (old is SemiFeedbackEmojiResult
          ? old.copyWith(text: text)
          : SemiFeedbackEmojiResult(text: text)),
    );
  }

  /// foundation handleRadioChange：`notifyRadioChange(e)` + `notifyValueChange(value)`。
  void _onRadioChanged(SemiRadioChangeEvent event) {
    widget.radioGroupProps?.onChanged?.call(event);
    _setValue(event.value);
  }

  /// foundation handleCheckboxChange：`notifyCheckBoxChange` + `notifyValueChange`。
  void _onCheckboxChanged(List<Object> values) {
    widget.checkboxGroupProps?.onChanged?.call(values);
    _setValue(values);
  }

  /// adapter notifyValueChange：setState + `props.onValueChange`。
  void _setValue(Object? value) {
    setState(() => _value = value);
    widget.onValueChange?.call(value);
  }

  /// foundation handleSubmit / handleModalOk 统一：notifyOk 后 promise 状态机
  /// （pending → `value: null` 复位 / rejected 保持打开）；非 promise 立即
  /// `setValue(null)`。
  Future<void> _handleSubmit() async {
    final result = widget.onOk?.call();
    if (result is Future<void>) {
      setState(() => _okPending = true);
      try {
        await result;
        if (mounted) {
          setState(() {
            _okPending = false;
            _value = null;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() => _okPending = false);
        }
      }
    } else {
      setState(() => _value = null);
    }
  }

  /// foundation handleCancel / handleModalCancel 统一（同 handleSubmit 状态机）。
  Future<void> _handleCancel() async {
    final result = widget.onCancel?.call();
    if (result is Future<void>) {
      setState(() => _cancelPending = true);
      try {
        await result;
        if (mounted) {
          setState(() {
            _cancelPending = false;
            _value = null;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() => _cancelPending = false);
        }
      }
    } else {
      setState(() => _value = null);
    }
  }

  /// foundation disableSubmitButton：`!Boolean(value) || (Array.isArray(value)
  /// && value.length === 0)`——null / 空串 / 空列表禁用（JS falsy 约定；
  /// EmojiResult 对象恒 truthy）。
  bool get _submitDisabled {
    final v = _value;
    return v == null || (v is String && v.isEmpty) || (v is List && v.isEmpty);
  }

  /// textNode：TextArea（locale `placeholder`，textAreaProps 透传）。
  Widget _textArea() {
    final p = widget.textAreaProps;
    return SemiTextArea(
      placeholder: p?.placeholder ?? '请提供更多反馈',
      rows: p?.rows ?? 4,
      autosize: p?.autosize,
      maxCount: p?.maxCount,
      showCounter: p?.showCounter ?? false,
      showClear: p?.showClear ?? false,
      maxLength: p?.maxLength,
      disabled: p?.disabled ?? false,
      readonly: p?.readonly ?? false,
      onChanged: _onTextChanged,
    );
  }

  /// emoji 追问 TextArea（`emoji === Emoji.bad && <TextArea`）。
  Widget _emojiReasonArea() {
    final p = widget.textAreaProps;
    return SemiTextArea(
      placeholder: p?.placeholder ?? '请提供更多反馈（选填）',
      rows: p?.rows ?? 4,
      autosize: p?.autosize,
      maxCount: p?.maxCount,
      showCounter: p?.showCounter ?? false,
      showClear: p?.showClear ?? false,
      maxLength: p?.maxLength,
      disabled: p?.disabled ?? false,
      readonly: p?.readonly ?? false,
      onChanged: _onEmojiReasonChanged,
    );
  }

  /// emojiNode：`-emoji-container`（居中 + column-gap + marginY）+ 三档表情。
  Widget _emojiColumn() {
    final t = SemiFeedbackTheme.resolve(context);
    final selected = switch (_value) {
      final SemiFeedbackEmojiResult e => e.emoji,
      _ => null,
    };
    const emojis = [_emojiBad, _emojiNormal, _emojiGood];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          // `-emoji-container` `margin-top`/`margin-bottom` 消费 marginY。
          padding: EdgeInsets.symmetric(
            vertical: t.spacingFeedbackEmojiContainerMarginY,
          ),
          child: Row(
            // `-emoji-container`（`display: flex` 居中 + `column-gap`）。
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < emojis.length; i++) ...[
                if (i > 0)
                  SizedBox(width: t.spacingFeedbackEmojiContainerColumnGap),
                _emojiItem(t, emojis[i], selected == emojis[i]),
              ],
            ],
          ),
        ),
        if (selected == _emojiBad) _emojiReasonArea(),
      ],
    );
  }

  Widget _emojiItem(
    SemiResolvedFeedbackThemeData t,
    String emoji,
    bool selected,
  ) {
    // `&:hover, &-selected` → `filter: none;`。
    final active = selected || _hoveredEmoji == emoji;
    final text = Text(
      emoji,
      style: TextStyle(
        fontSize: t.fontFeedbackEmojiFontSize,
        // `font-family: Inter`（emoji 字形走系统 emoji 字体回退）。
        fontFamily: 'Inter',
        height: 1,
      ),
    );
    return Semantics(
      button: true, // `role="button"` `tabIndex={0}`
      selected: selected, // `aria-pressed={item === emoji}`
      child: MouseRegion(
        cursor: SystemMouseCursors.click, // `cursor: pointer`
        onEnter: (_) => setState(() => _hoveredEmoji = emoji),
        onExit: (_) => setState(() => _hoveredEmoji = null),
        child: GestureDetector(
          // `user-select: none`（GestureDetector 文本不可选中）。
          behavior: HitTestBehavior.opaque,
          onTap: () => _onEmojiSelected(emoji),
          child: Focus(
            onKeyEvent: (node, event) {
              // 键盘 `e.key === 'Enter' || e.key === ' '` 选中。
              if (event is KeyDownEvent &&
                  (event.logicalKey == LogicalKeyboardKey.enter ||
                      event.logicalKey == LogicalKeyboardKey.space)) {
                _onEmojiSelected(emoji);
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: active
                ? text
                // feedback.scss：`filter: grayscale(100%)`。
                : ColorFiltered(
                    colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
                    child: text,
                  ),
          ),
        ),
      ),
    );
  }

  /// radioNode：`direction='vertical'` RadioGroup（radioGroupProps 透传）。
  Widget _radioGroup() {
    final p = widget.radioGroupProps;
    return SemiRadioGroup(
      direction: SemiRadioDirection.vertical,
      options: p?.options,
      defaultValue: p?.defaultValue,
      disabled: p?.disabled ?? false,
      type: p?.type ?? SemiRadioType.normal,
      buttonSize: p?.buttonSize ?? SemiRadioButtonSize.middle,
      mode: p?.mode ?? SemiRadioMode.normal,
      onChanged: _onRadioChanged,
    );
  }

  /// checkboxNode：`direction='vertical'` CheckboxGroup + row-gap 覆写
  /// （`.#{$prefix}-checkboxGroup-vertical`）。
  Widget _checkboxGroup() {
    final p = widget.checkboxGroupProps;
    final t = SemiFeedbackTheme.resolve(context);
    return SemiCheckboxTheme(
      data: SemiCheckboxThemeData(
        spacingCheckboxGroupVerticalItemMarginBottom:
            t.spacingFeedbackCheckboxGroupVerticalRowGap,
      ),
      child: SemiCheckboxGroup(
        direction: SemiCheckboxDirection.vertical,
        options: p?.options,
        defaultValue: p?.defaultValue,
        disabled: p?.disabled ?? false,
        type: p?.type ?? SemiCheckboxType.normal,
        onChanged: _onCheckboxChanged,
      ),
    );
  }

  /// getRealChildren：按 type 选内容 + `renderContent` 包装。
  Widget? _realContent() {
    Widget? result = switch (widget.type) {
      SemiFeedbackType.custom => widget.content,
      SemiFeedbackType.text => _textArea(),
      SemiFeedbackType.emoji => _emojiColumn(),
      SemiFeedbackType.radio => _radioGroup(),
      SemiFeedbackType.checkbox => _checkboxGroup(),
    };
    if (result != null && widget.renderContent != null) {
      result = widget.renderContent!(result);
    }
    return result;
  }

  /// renderFooter（popup）：`&-footer`（`justify-content: flex-end` +
  /// `column-gap`）+ `type='primary'` / `theme='solid'` /
  /// `disabled={this.disableSubmitButton()}`。
  Widget _popupFooter() {
    final t = SemiFeedbackTheme.resolve(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SemiButton(
          widget.cancelText ?? '取消',
          type: SemiButtonType.primary,
          loading: widget.cancelLoading ?? _cancelPending,
          onPressed: _handleCancel,
        ),
        SizedBox(width: t.spacingFeedbackFooterColumnGap),
        SemiButton(
          widget.okText ?? '提交',
          type: SemiButtonType.primary,
          variant: SemiButtonVariant.solid,
          disabled: widget.okDisabled ?? _submitDisabled,
          loading: widget.okLoading ?? _okPending,
          onPressed: _handleSubmit,
        ),
      ],
    );
  }

  /// modal 模式按钮行（照抄 Modal 缺省 footer：cancel `type="tertiary"` +
  /// ok `theme="solid"`；`okButtonProps={{ disabled: disabledOkButton, ... }}`
  /// → disabled/loading 槽）。
  Widget _modalFooter() {
    final m = SemiModalTheme.resolve(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SemiButton(
          widget.cancelText ?? '取消',
          type: SemiButtonType.tertiary,
          loading: widget.cancelLoading ?? _cancelPending,
          onPressed: _handleCancel,
        ),
        // Modal footer 按钮 `margin-left: 12`。
        SizedBox(width: m.spacingModalFooterButtonMarginLeft),
        SemiButton(
          widget.okText ?? '提交',
          type: SemiButtonType.primary,
          variant: SemiButtonVariant.solid,
          disabled: widget.okDisabled ?? _submitDisabled,
          loading: widget.okLoading ?? _okPending,
          onPressed: _handleSubmit,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = SemiFeedbackTheme.resolve(context);
    final content = _realContent();
    if (widget.mode == SemiFeedbackMode.modal) {
      // modal 分支（`okText={locale.submit}` / `cancelText={locale.cancel}` /
      // `okButtonProps={{ disabled: disabledOkButton, ...this.props.okButtonProps }}`）
      // ——footer 自建按钮行（disabled/loading 槽），壳体走 SemiModal。
      return SemiModal(
        visible: widget.visible,
        title: widget.title,
        content: content,
        footer: widget.footer ?? _modalFooter(),
        // `.#{$prefix}-modal { width: $width-feedback }`（`&.#{$module}-text`
        // 文本模式仍取 `$width-feedback`——注释矛盾 quirk）。
        width: widget.width ?? t.widthFeedback,
        mask: widget.mask ?? true,
        maskClosable: widget.maskClosable ?? true,
        closable: widget.closable,
        closeIcon: widget.closeIcon,
        closeOnEsc: widget.closeOnEsc ?? true,
        motion: widget.motion,
        onCancel: _handleCancel,
        afterClose: widget.afterClose,
      );
    }
    // popup 分支（SideSheet：`mask={false}` `disableScroll={false}`
    // `canVerticalSetWidth={true}` `placement="bottom"` `height="auto"`）——
    // 几何由 feedback.scss 覆写（`&-bottom` 锚定 + keyframes），内建弹层等价。
    return _FeedbackSheet(
      visible: widget.visible,
      title: widget.title,
      content: content,
      footer: widget.footer ?? _popupFooter(),
      width:
          widget.width ??
          (widget.type == SemiFeedbackType.text
              ? t.widthFeedbackText
              : t.widthFeedback),
      mask: widget.mask ?? false,
      maskClosable: widget.maskClosable ?? true,
      closable: widget.closable,
      closeIcon: widget.closeIcon,
      closeOnEsc: widget.closeOnEsc ?? false,
      motion: widget.motion,
      onCancel: _handleCancel,
      afterVisibleChange: (isVisible) {
        widget.afterVisibleChange?.call(isVisible);
        // afterVisibleChange wrapper：出场完成后 `this.props.afterClose()`。
        if (!isVisible) widget.afterClose?.call();
      },
    );
  }
}

/// popup 弹层（上游 SideSheet 组合 + feedback.scss 几何覆写的等价实现）。
///
/// chrome（bg / header / body / footer 边距 / 标题字）消费 SemiSideSheetTheme
/// （上游 feedback popup 即 SideSheet inner）；几何消费 SemiFeedbackTheme：
/// 宽 400/600（`canVerticalSetWidth` + `.-text` 覆写）、`&-bottom`
/// `right: …` / `left: auto`（物理右边，rtl.scss 空文件不镜像）+ inner-wrap
/// 底距 50、`.#{$prefix}-sidesheet-inner` 圆角 12、fixed 模式投影、
/// `@keyframes` 起点 `translateY(calc(100% + 50px))` 滑入。
class _FeedbackSheet extends StatefulWidget {
  const _FeedbackSheet({
    required this.visible,
    required this.title,
    required this.content,
    required this.footer,
    required this.width,
    required this.mask,
    required this.maskClosable,
    required this.closable,
    required this.closeIcon,
    required this.closeOnEsc,
    required this.motion,
    required this.onCancel,
    required this.afterVisibleChange,
  });

  final bool visible;
  final Object? title;
  final Widget? content;
  final Widget? footer;
  final double width;
  final bool mask;
  final bool maskClosable;
  final bool closable;
  final Widget? closeIcon;
  final bool closeOnEsc;
  final bool motion;
  final VoidCallback? onCancel;
  final void Function(bool isVisible)? afterVisibleChange;

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  static int _seq = 0;
  late final String _tag = 'semi-feedback-sheet-${_seq++}';
  final SmartDialogController _controller = SmartDialogController();
  bool _open = false;

  /// 引擎 body 动画 controller（animationBuilder 回写——keyframes 滑移驱动源）。
  AnimationController? _slide;

  /// 上游 componentWillUnmount 不通知 afterVisibleChange——dispose 强关时
  /// 置 false，show Future 完成后据此判是否补发 `(false)`。
  bool _notifyClose = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // initState 里不能 dependOnInheritedWidget（主题解析）——首同步放这里。
    _sync();
  }

  @override
  void didUpdateWidget(_FeedbackSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
    if (_open) _controller.refresh();
  }

  void _sync() {
    // 引擎 show/dismiss 走 post-frame（build 相位 dismiss 会 markNeedsBuild
    // during build，触发生命周期竞态）。
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncNow());
  }

  void _syncNow() {
    if (!mounted) return;
    if (widget.visible && !_open) {
      _open = true;
      _notifyClose = true;
      final s = SemiSideSheetTheme.resolve(context);
      unawaited(() async {
        await SmartDialog.show<void>(
          tag: _tag,
          controller: _controller,
          alignment: Alignment.center,
          // 遮罩点击只走 onMask，关闭权在使用方——`clickMaskDismiss` 恒 false。
          clickMaskDismiss: false,
          onMask: !widget.mask
              ? null
              : () {
                  if (widget.maskClosable) widget.onCancel?.call();
                },
          maskColor: widget.mask
              ? s.colorSideSheetMaskBg
              : const Color(0x00000000),
          // `mask={false}` fixed 模式无蒙层：点击穿透（`usePenetrate`）。
          usePenetrate: !widget.mask,
          useAnimation: widget.motion,
          animationTime: s.animationDurationSideSheetInnerShow,
          // 回写 body controller 后原样返回——滑移在内容层驱动。
          animationBuilder: (controller, child, param) {
            _slide = widget.motion ? controller : null;
            return child;
          },
          builder: (_) => _buildContent(),
        );
        _slide = null;
        // show Future 在关闭动画完成后返回——补发 `(false)`。
        if (_notifyClose) {
          _notifyClose = false;
          widget.afterVisibleChange?.call(false);
        }
      }());
      _notifyVisible(s);
    } else if (!widget.visible && _open) {
      _open = false;
      unawaited(SmartDialog.dismiss<void>(tag: _tag));
    }
  }

  /// 入场动画完成后通知 `(true)`（上游 onAnimationEnd → notifyVisibleChange）。
  void _notifyVisible(SemiResolvedSideSheetThemeData s) {
    if (!widget.motion) {
      widget.afterVisibleChange?.call(true);
      return;
    }
    unawaited(
      Future<void>.delayed(s.animationDurationSideSheetInnerShow, () {
        if (mounted && _open) widget.afterVisibleChange?.call(true);
      }),
    );
  }

  @override
  void dispose() {
    if (_open) {
      _open = false;
      _notifyClose = false;
      unawaited(SmartDialog.dismiss<void>(tag: _tag, force: true));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  Widget _buildContent() {
    final f = SemiFeedbackTheme.resolve(context);
    final s = SemiSideSheetTheme.resolve(context);
    final screen = MediaQuery.sizeOf(context);
    // `height="auto"`：内容 hugging；溢出保护（上游 auto 纯 hugging）。
    final maxBody =
        screen.height - f.spacingFeedbackSidesheetBottomInnerWrapBottom * 2;

    final closer = SemiButton(
      null,
      icon: widget.closeIcon ?? const SemiIcon(SemiIcons.close),
      type: SemiButtonType.tertiary,
      variant: SemiButtonVariant.borderless,
      size: SemiButtonSize.small,
      semanticsLabel: '关闭',
      onPressed: widget.onCancel,
    );

    // SideSheet header 族（`padding: 24` / `padding-bottom: 20` / 0px 占位边）。
    final header = Container(
      padding: EdgeInsetsDirectional.only(
        top: s.spacingSideSheetHeaderPadding,
        bottom: s.spacingSideSheetHeaderPaddingBottom,
        start: s.spacingSideSheetHeaderPadding,
        end: s.spacingSideSheetHeaderPadding,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: s.colorSideSheetHeaderBorderBottom,
            width: s.widthSideSheetHeaderBorderBottom,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(s.spacingSideSheetTitleMargin),
              child: switch (widget.title) {
                null => const SizedBox.shrink(),
                final Widget w => w,
                final o => Text(
                  o.toString(),
                  style: TextStyle(
                    fontSize: s.fontSideSheetTitleFontSize,
                    fontWeight: s.fontSideSheetTitleFontWeight,
                    color: s.colorSideSheetMainText,
                  ),
                ),
              },
            ),
          ),
          if (widget.closable) closer,
        ],
      ),
    );

    final body = Padding(
      padding: EdgeInsets.symmetric(
        vertical: s.spacingSideSheetBodyPaddingY,
        horizontal: s.spacingSideSheetBodyPaddingX,
      ),
      child: widget.content ?? const SizedBox.shrink(),
    );

    final footerArea = widget.footer == null
        ? null
        : Padding(
            padding: EdgeInsets.all(s.spacingSideSheetFooterPadding),
            child: widget.footer,
          );

    Widget card = Container(
      key: const ValueKey('semi-feedback-sheet-box'),
      width: widget.width,
      // `.#{$prefix}-sidesheet-inner` 圆角 + bg；fixed 模式（`mask={false}`）
      // 投影（sideSheet.scss 硬编码 `box-shadow: var(--semi-shadow-elevated)`）
      // ——inset 层走 SemiInsetShadow 画师（见差异清单）。
      decoration: BoxDecoration(
        color: s.colorSideSheetBg,
        borderRadius: BorderRadius.circular(f.radiusFeedbackSidesheetInner),
        boxShadow: widget.mask
            ? null
            : SemiTheme.of(context).shadows.shadowElevated.toDropBoxShadows(),
      ),
      clipBehavior: Clip.antiAlias,
      child: SemiInsetShadow(
        shadows: widget.mask
            ? SemiShadows(const [])
            : SemiTheme.of(context).shadows.shadowElevated,
        borderRadius: BorderRadius.circular(f.radiusFeedbackSidesheetInner),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxBody),
              child: SingleChildScrollView(child: body),
            ),
            ?footerArea,
          ],
        ),
      ),
    );

    // `@keyframes #{$prefix}-sidesheet-slideShow_bottom`（`-Hide` 反放）起点
    // `translateY(calc(100% + $spacing-feedback_sidesheet_bottom_inner_wrap-bottom))`
    // ——SlideTransition 按自身尺寸换算 100%，+50px 由 Transform 补足。
    if (_slide != null) {
      final curved = _slide!.drive(
        CurveTween(curve: s.animationFunctionSideSheetInnerShow),
      );
      card = SlideTransition(
        position: curved.drive(
          Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero),
        ),
        child: AnimatedBuilder(
          animation: curved,
          builder: (context, child) => Transform.translate(
            offset: Offset(
              0,
              f.spacingFeedbackSidesheetBottomInnerWrapBottom *
                  (1 - curved.value),
            ),
            child: child,
          ),
          child: card,
        ),
      );
    }

    return Align(
      // `&-bottom`：`right: …` / `left: auto`（物理右）+ inner-wrap 底距。
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.only(
          right: f.spacingFeedbackSidesheetBottomRight,
          bottom: f.spacingFeedbackSidesheetBottomInnerWrapBottom,
        ),
        child: Semantics(
          // 上游 `role="dialog"`（inner-wrap）。
          container: true,
          child: _SheetFocus(
            closeOnEsc: widget.closeOnEsc,
            onClose: () => widget.onCancel?.call(),
            child: card,
          ),
        ),
      ),
    );
  }
}

/// 弹层焦点槽（上游 inner-wrap `tabIndex={-1}` 聚焦语义，SemiSideSheet 同款）。
class _SheetFocus extends StatefulWidget {
  const _SheetFocus({
    required this.closeOnEsc,
    required this.onClose,
    required this.child,
  });

  final bool closeOnEsc;
  final VoidCallback onClose;
  final Widget child;

  @override
  State<_SheetFocus> createState() => _SheetFocusState();
}

class _SheetFocusState extends State<_SheetFocus> {
  final FocusNode _node = FocusNode(debugLabel: 'SemiFeedback');

  @override
  void initState() {
    super.initState();
    // 首帧后抢焦（build 相位不做焦点迁移）。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _node.requestFocus();
    });
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Focus(
    focusNode: _node,
    autofocus: true,
    onKeyEvent: (node, event) {
      if (event is KeyDownEvent &&
          widget.closeOnEsc &&
          event.logicalKey == LogicalKeyboardKey.escape) {
        widget.onClose();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    },
    child: widget.child,
  );
}

// constants.ts Emoji：`bad: '😞'` / `normal: '😐'` / `good: '😃'`。
const String _emojiBad = '😞';
const String _emojiNormal = '😐';
const String _emojiGood = '😃';

/// `filter: grayscale(100%)`——亮度保留灰度矩阵（RGB 同值、A 透传）。
const List<double> _grayscaleMatrix = <double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
];
