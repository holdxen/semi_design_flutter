// SemiSteps — 步骤条（Semi Design 组件移植）。
//
// 上游：packages/semi-foundation/steps/{variables.scss, animation.scss,
// steps.scss, bacisSteps.scss, fillSteps.scss, navSteps.scss, rtl.scss,
// constants.ts}、packages/semi-ui/steps/{index.tsx, step.tsx, basicSteps.tsx,
// basicStep.tsx, fillSteps.tsx, fillStep.tsx, navSteps.tsx, navStep.tsx}。
// 主题对账 104 = 94 FIELDS + 10 MOTION + 0 INTERNAL
// （tool/generate_steps.py）——★5 死变量（真死零引用：`$height-steps_basic_item`、
// `$width-steps_item_left_icon`、`$spacing-steps_basic_item-marginRight`、
// `$font-steps_item_title-fontWeight`、`$font-steps_item_left-fontWeight`），
// 留档不消费（落 theme + docs「（上游未消费）」；本文件不得出现这些字段名，
// 生成器 assertNotIn 断言）。
// 10 条 MOTION 是活字段（steps.scss:4 `@import "./animation.scss"` +
// bacisSteps.scss:181-182 / fillSteps.scss:42-44 消费，0ms/ease-in/0ms/scale(1,1)
// 恒等）。
//
// HARDCODES（另列）上游片段以注释逐字留档在 `_StepsMetrics` / 调用点，
// 生成器 HARDCODES 锚点断言这些片段出现在本文件。
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/semi_steps_theme.dart';
import '../theme/semi_steps_theme_data.dart';
import '../theme/semi_theme.dart';
import '../theme/semi_theme_data.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icon_data.dart';
import 'icon/semi_icons.dart';

/// 步骤状态（上游 `Status: 'wait' | 'process' | 'finish' | 'error' | 'warning'`）。
enum SemiStepStatus { wait, process, finish, error, warning }

/// 步骤条形态（上游 `type: 'fill' | 'basic' | 'nav'`，缺省 fill）。
enum SemiStepsType { fill, basic, nav }

/// 方向（上游 `direction: 'horizontal' | 'vertical'`；nav 只有水平）。
enum SemiStepsDirection { horizontal, vertical }

/// 尺寸（上游 `size: 'default' | 'small'`；`default` 是保留字照先例命名）。
enum SemiStepSize { defaultSize, small }

/// 单步数据（上游 `<Steps.Step>` 子节点 props：title/description/icon/status/onClick）。
class SemiStepData {
  const SemiStepData({
    this.title,
    this.description,
    this.icon,
    this.status,
    this.onClick,
  });

  /// 标题：String | Widget。
  final Object? title;

  /// 辅助描述：String | Widget（缺省不渲染；fill 带标题下说明，basic 小字描述）。
  final Object? description;

  /// 自定义图标（fill/basic：覆盖状态图标；basic 无 `-number-icon` 序号）。
  final Widget? icon;

  /// 强制状态（缺省按 current/status 推导）。
  final SemiStepStatus? status;

  /// 点击回调（先于步骤条 onChange；clickable 判定含它）。
  final VoidCallback? onClick;
}

/// 步骤条。
///
/// 三形态（index.tsx `type`）：`fill` 卡片式分栏（每步 flex 1，左序号/图标 +
/// 标题 + 描述；状态底色 + 可点击 hover/active）、`basic` 简版（标题 + 连接线，
/// `direction` 水平/垂直、`hasLine` 连接线、小尺寸）、`nav` 导航式（标题 +
/// 右侧 chevron，当前项加重）。状态推导（basicSteps.tsx:43-64 / fillSteps.tsx:
/// 39-58）：`step.status` 优先，否则 `stepNumber == current → status`、
/// `< current → finish`、其余 `wait`；`active = stepNumber == current`；
/// `done = stepNumber < current`（basic 连接线着色）。点击包壳：先
/// `step.onClick` 后 `onChange(stepNumber)`（当前步不回调——上游
/// `index + initial !== current` 守卫）；无 onChange/onClick 时不可点击。
/// ★basic 在 `status: error && index == current - 1` 时给前一步加
/// `-next-error` 类——上游无对应 CSS 规则（className 观察用），本移植 note-only。
/// ★nav 点击无光标/hover 视觉（上游 navStep 无 clickable 类）。
class SemiSteps extends StatelessWidget {
  const SemiSteps({
    super.key,
    this.type = SemiStepsType.fill,
    this.steps = const <SemiStepData>[],
    this.current = 0,
    this.initial = 0,
    this.status = SemiStepStatus.process,
    this.direction = SemiStepsDirection.horizontal,
    this.size = SemiStepSize.defaultSize,
    this.hasLine = true,
    this.onChange,
    this.semanticsLabel,
  });

  /// Root key.
  static const Key rootKey = Key('SemiSteps.root');

  /// Step row key（index 为步骤序号）。
  static Key stepKey(int index) => ValueKey('SemiSteps.step.$index');

  /// 形态（fill | basic | nav）。
  final SemiStepsType type;

  /// 步骤列表。
  final List<SemiStepData> steps;

  /// 当前步骤（含 `initial` 偏移比较）。
  final int current;

  /// 起始序号（`stepNumber = initial + index`）。
  final int initial;

  /// 步骤条级状态（当前步缺省状态）。
  final SemiStepStatus status;

  /// 方向（basic/fill；nav 忽略）。
  final SemiStepsDirection direction;

  /// 尺寸（basic/nav；fill 忽略——上游 FillSteps 无 size）。
  final SemiStepSize size;

  /// basic 连接线（`hasLine = true` 上游 BasicSteps 缺省）。
  final bool hasLine;

  /// 步骤切换回调（点击非当前步时触发）。
  final ValueChanged<int>? onChange;

  /// 根语义标签（上游 `aria-label`）。
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final t = SemiStepsTheme.resolve(context);
    final global = SemiTheme.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final resolved = <_ResolvedStep>[
      for (var i = 0; i < steps.length; i++) _resolve(i, t),
    ];
    final body = switch (type) {
      SemiStepsType.fill => _FillSteps(
        steps: resolved,
        direction: direction,
        t: t,
        global: global,
        rtl: rtl,
      ),
      SemiStepsType.basic => _BasicSteps(
        steps: resolved,
        direction: direction,
        size: size,
        hasLine: hasLine,
        t: t,
        global: global,
        rtl: rtl,
      ),
      SemiStepsType.nav => _NavSteps(
        steps: resolved,
        size: size,
        t: t,
        global: global,
        rtl: rtl,
      ),
    };
    return Semantics(
      container: true,
      label: semanticsLabel,
      child: KeyedSubtree(key: SemiSteps.rootKey, child: body),
    );
  }

  _ResolvedStep _resolve(int index, SemiResolvedStepsThemeData t) {
    final data = steps[index];
    final stepNumber = initial + index;
    final SemiStepStatus stepStatus;
    if (data.status != null) {
      stepStatus = data.status!;
    } else if (stepNumber == current) {
      stepStatus = status;
    } else if (stepNumber < current) {
      stepStatus = SemiStepStatus.finish;
    } else {
      stepStatus = SemiStepStatus.wait;
    }
    final clickable = onChange != null || data.onClick != null;
    return _ResolvedStep(
      data: data,
      index: index,
      stepNumber: stepNumber,
      status: stepStatus,
      active: stepNumber == current,
      done: stepNumber < current,
      last: index == steps.length - 1,
      clickable: clickable,
      onTap: !clickable
          ? null
          : () {
              data.onClick?.call();
              // basicSteps.tsx:66-70：当前步不回调（同上拉守卫）。
              if (stepNumber != current) {
                onChange?.call(stepNumber);
              }
            },
    );
  }
}

/// 解析后的单步（状态推导 + 点击包壳）。
class _ResolvedStep {
  const _ResolvedStep({
    required this.data,
    required this.index,
    required this.stepNumber,
    required this.status,
    required this.active,
    required this.done,
    required this.last,
    required this.clickable,
    required this.onTap,
  });

  final SemiStepData data;
  final int index;
  final int stepNumber;
  final SemiStepStatus status;
  final bool active;
  final bool done;
  final bool last;
  final bool clickable;
  final VoidCallback? onTap;
}

Widget _content(Object? value, {TextStyle? style, int maxLines = 1}) {
  if (value is Widget) {
    return value;
  }
  return Text(
    value?.toString() ?? '',
    maxLines: maxLines,
    // `@include text-overflow-hidden`：nowrap + overflow hidden + ellipsis。
    overflow: maxLines == 1 ? TextOverflow.ellipsis : null,
    softWrap: maxLines != 1,
    style: style,
  );
}

/// Focus + Enter 激活（上游 `tabIndex={0}` + `e.key === 'Enter'`）。
Widget _enterActivatable(VoidCallback? onTap, Widget child) {
  if (onTap == null) {
    return child;
  }
  return Focus(
    canRequestFocus: true,
    onKeyEvent: (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.enter) {
        onTap();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    },
    child: child,
  );
}

// -- fill ---------------------------------------------------------------------

class _FillSteps extends StatelessWidget {
  const _FillSteps({
    required this.steps,
    required this.direction,
    required this.t,
    required this.global,
    required this.rtl,
  });

  final List<_ResolvedStep> steps;
  final SemiStepsDirection direction;
  final SemiResolvedStepsThemeData t;
  final SemiThemeData global;
  final bool rtl;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      for (final step in steps)
        _FillStep(step: step, t: t, global: global, rtl: rtl),
    ];
    if (direction == SemiStepsDirection.vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: items,
      );
    }
    // fillSteps.tsx:28-31：水平每步等宽（Col flex 1 / 100%）。
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final item in items) Expanded(child: item)],
    );
  }
}

class _FillStep extends StatefulWidget {
  const _FillStep({
    required this.step,
    required this.t,
    required this.global,
    required this.rtl,
  });

  final _ResolvedStep step;
  final SemiResolvedStepsThemeData t;
  final SemiThemeData global;
  final bool rtl;

  @override
  State<_FillStep> createState() => _FillStepState();
}

class _FillStepState extends State<_FillStep> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final step = widget.step;
    final status = step.status;
    // 可点击的 finish/error/warning 才有 hover/active 底色（fillSteps.scss:76-135）。
    final interactive =
        step.clickable &&
        (status == SemiStepStatus.finish ||
            status == SemiStepStatus.error ||
            status == SemiStepStatus.warning);

    final Color iconColor;
    final Color titleColor;
    switch (status) {
      case SemiStepStatus.process:
        iconColor = t.colorStepsPrimaryIconDefault;
        titleColor = t.colorStepsPrimaryIconDefault;
      case SemiStepStatus.wait:
        iconColor = t.colorStepsIconDefault;
        titleColor = t.colorStepsMainTextDefault;
      case SemiStepStatus.finish:
        iconColor = _hover
            ? t.colorStepsSuccessTextHover
            : _pressed
            ? t.colorStepsSuccessTextActive
            : t.colorStepsSuccessTextDefault;
        titleColor = iconColor;
      case SemiStepStatus.error:
        iconColor = _hover
            ? t.colorStepsDangerTextHover
            : _pressed
            ? t.colorStepsDangerTextActive
            : t.colorStepsDangerTextDefault;
        titleColor = iconColor;
      case SemiStepStatus.warning:
        iconColor = _hover
            ? t.colorStepsWarningTextHover
            : _pressed
            ? t.colorStepsWarningTextActive
            : t.colorStepsWarningTextDefault;
        titleColor = iconColor;
    }

    final Color bg;
    if (status == SemiStepStatus.process) {
      bg = t.colorStepsProcessBgDefault;
    } else if (interactive && _hover) {
      bg = t.colorStepsBgHover;
    } else if (interactive && _pressed) {
      bg = t.colorStepsBgActive;
    } else {
      bg = const Color(0x00000000);
    }

    final item = AnimatedContainer(
      // backgroundColor 三元组（0ms/ease-in/0ms 恒等）；delay 槽
      // transitionDelayStepsItemBackgroundColor 在 AnimatedContainer 无对应
      // ——注释引用。
      duration: t.transitionDurationStepsItemBackgroundColor,
      curve: t.transitionFunctionStepsItemBackgroundColor,
      height: t.heightStepsItem,
      // fillSteps.scss:34-37 item margin-right 16 + border 1 + 圆角 medium +
      // paddingY 12 / paddingX 16。
      margin: EdgeInsetsDirectional.only(end: t.spacingStepsItemMarginRight),
      padding: EdgeInsets.symmetric(
        vertical: t.spacingStepsItemPaddingY,
        horizontal: t.spacingStepsItemPaddingX,
      ),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(
          width: t.widthStepsItemBorder,
          color: t.colorStepsBorderDefault,
        ),
        borderRadius: BorderRadius.circular(t.radiusStepsItem),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLeft(t, step, status, iconColor, interactive),
          SizedBox(width: t.spacingStepsItemContentMarginLeft),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDefaultTextStyle(
                  // 标题色三元组；delay 槽 transitionDelayStepsItemTitleText
                  // 无对应——注释引用。
                  duration: t.transitionDurationStepsItemTitleText,
                  curve: t.transitionFunctionStepsItemTitleText,
                  style: TextStyle(
                    // fillSteps.scss:49 `@include font-size-header-5` = 18 +
                    // `font-weight: $font-weight-bold`。
                    fontSize: _StepsMetrics.fillTitleFontSize,
                    fontWeight: widget.global.typography.fontWeightBold,
                    color: titleColor,
                  ),
                  // `width: $width-steps_item_title: 100%`（widthStepsItemTitle）。
                  child: SizedBox(
                    width: double.infinity,
                    child: _content(step.data.title),
                  ),
                ),
                if (step.data.description != null)
                  // `width: $width-steps_item_description: 100%`
                  //（widthStepsItemDescription）。
                  SizedBox(
                    width: double.infinity,
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        // `@include font-size-regular` = 14。
                        fontSize: _StepsMetrics.fillDescriptionFontSize,
                        color: _hover && step.clickable
                            ? t.colorStepsItemDescriptionTextHover
                            : t.colorStepsMinorTextDefault,
                      ),
                      child: _content(step.data.description),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    final scaled = Transform.scale(
      // steps.scss/animation.scss: transform: scale($transform_scale-step-item)
      // （token = scale(1,1) 恒等；★上游编译产物 transform: scale(scale(1,1))
      // 无效 CSS bug 留档）。
      scaleX: t.transformScaleStepItem.scaleX,
      scaleY: t.transformScaleStepItem.scaleY,
      child: item,
    );
    final target = _enterActivatable(step.onTap, scaled);
    return MouseRegion(
      // `-clickable { cursor: pointer }`。
      cursor: step.clickable ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: step.clickable ? (_) => setState(() => _hover = true) : null,
      onExit: step.clickable ? (_) => setState(() => _hover = false) : null,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: step.clickable
            ? (_) => setState(() => _pressed = true)
            : null,
        onPointerUp: step.clickable
            ? (_) => setState(() => _pressed = false)
            : null,
        onPointerCancel: step.clickable
            ? (_) => setState(() => _pressed = false)
            : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: step.onTap,
          child: target,
        ),
      ),
    );
  }

  Widget _buildLeft(
    SemiResolvedStepsThemeData t,
    _ResolvedStep step,
    SemiStepStatus status,
    Color iconColor,
    bool interactive,
  ) {
    final customIcon = step.data.icon != null;
    final Color? leftBg = customIcon
        ? null
        : status == SemiStepStatus.wait
        // `.item-wait .item-left:not(.item-icon) { background: $color-steps-bg-default }`。
        ? t.colorStepsBgDefault
        : status == SemiStepStatus.process
        // `-left-process { background: $color-steps_primary-bg-default }`。
        ? t.colorStepsPrimaryBgDefault
        : null;
    // `-left.plain { color: $color-steps-text-default }`（白色——
    // ★`rgba(var(--semi-white), 1)` 写法照抄留档）。
    final Color numberColor = t.colorStepsTextDefault;

    final Widget inner;
    if (customIcon) {
      inner = step.data.icon!;
    } else {
      switch (status) {
        case SemiStepStatus.wait:
        case SemiStepStatus.process:
          inner = AnimatedDefaultTextStyle(
            // 图标色三元组；delay 槽 transitionDelayStepsItemTitleIcon
            // 无对应——注释引用。
            duration: t.transitionDurationStepsItemTitleIcon,
            curve: t.transitionFunctionStepsItemTitleIcon,
            style: TextStyle(
              // fillSteps.scss:175 `@include font-size-header-4` = 20 +
              // `font-weight: $font-weight-bold`；`line-height: 32px`
              //（fontStepsItemLeftLineHeight，行盒 32 在 24 盒内居中）。
              fontSize: _StepsMetrics.fillLeftFontSize,
              fontWeight: _StepsMetrics.fillLeftFontWeight,
              height:
                  t.fontStepsItemLeftLineHeight /
                  _StepsMetrics.fillLeftFontSize,
              // CSS `line-height` 半行距上下均分；Flutter 默认 proportional
              // 会把数字压低溢出圆圈——even 对齐 CSS。
              leadingDistribution: TextLeadingDistribution.even,
              color: numberColor,
            ),
            // 上游 `stepNumber: `${stepNumber + 1}``（0-based → 显示 1-based）。
            // 行盒 32 高于 24 圆盒：CSS flex 居中让行盒上下溢出 4px 居中，
            // Flutter 的 Align 会把文本钳回 24 顶对齐——OverflowBox 强制
            // 行盒 32 后居中溢出（对齐 CSS）。
            child: OverflowBox(
              minHeight: t.fontStepsItemLeftLineHeight,
              maxHeight: t.fontStepsItemLeftLineHeight,
              child: Text('${step.stepNumber + 1}'),
            ),
          );
        case SemiStepStatus.finish:
          inner = SemiIcon(SemiIcons.tickCircle, size: SemiIconSize.extraLarge);
        case SemiStepStatus.error:
          inner = SemiIcon(
            SemiIcons.alertCircle,
            size: SemiIconSize.extraLarge,
          );
        case SemiStepStatus.warning:
          inner = SemiIcon(
            SemiIcons.alertTriangle,
            size: SemiIconSize.extraLarge,
          );
      }
    }

    return DefaultTextStyle.merge(
      style: TextStyle(color: iconColor),
      child: Container(
        // fillSteps.scss:150-171 `-left`：24×24、圆角 32（radiusStepsItemLeft）。
        width: t.widthStepsItemLeft,
        height: t.heightStepsItemLeft,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: leftBg ?? const Color(0x00000000),
          borderRadius: BorderRadius.circular(t.radiusStepsItemLeft),
        ),
        child: inner,
      ),
    );
  }
}

// -- basic --------------------------------------------------------------------

class _BasicSteps extends StatelessWidget {
  const _BasicSteps({
    required this.steps,
    required this.direction,
    required this.size,
    required this.hasLine,
    required this.t,
    required this.global,
    required this.rtl,
  });

  final List<_ResolvedStep> steps;
  final SemiStepsDirection direction;
  final SemiStepSize size;
  final bool hasLine;
  final SemiResolvedStepsThemeData t;
  final SemiThemeData global;
  final bool rtl;

  @override
  Widget build(BuildContext context) {
    if (direction == SemiStepsDirection.vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final step in steps)
            _BasicStep(
              step: step,
              direction: direction,
              size: size,
              hasLine: hasLine,
              t: t,
              global: global,
              rtl: rtl,
            ),
        ],
      );
    }
    final items = <Widget>[
      for (final step in steps)
        _BasicStep(
          step: step,
          direction: direction,
          size: size,
          hasLine: hasLine,
          t: t,
          global: global,
          rtl: rtl,
        ),
    ];
    // basicSteps.tsx:75-78：水平每步 flex 1，末项 flex none。
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          i == items.length - 1
              ? Flexible(fit: FlexFit.loose, child: items[i])
              : Expanded(child: items[i]),
      ],
    );
  }
}

class _BasicStep extends StatefulWidget {
  const _BasicStep({
    required this.step,
    required this.direction,
    required this.size,
    required this.hasLine,
    required this.t,
    required this.global,
    required this.rtl,
  });

  final _ResolvedStep step;
  final SemiStepsDirection direction;
  final SemiStepSize size;
  final bool hasLine;
  final SemiResolvedStepsThemeData t;
  final SemiThemeData global;
  final bool rtl;

  @override
  State<_BasicStep> createState() => _BasicStepState();
}

class _BasicStepState extends State<_BasicStep> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final step = widget.step;
    final status = step.status;
    final small = widget.size == SemiStepSize.small;
    final vertical = widget.direction == SemiStepsDirection.vertical;
    final clickable = step.clickable;

    final iconSize = small
        ? t.heightStepsBasicSmallItemLeftIcon
        : t.heightStepsBasicItemLeftIcon;
    final numberBox = small
        ? t.widthStepsBasicSmallItemLeftNumberIcon
        : t.widthStepsBasicItemLeftNumberIcon;

    // bacisSteps.scss 状态色（wait/process/finish/error/warning）。
    final Color iconColor;
    final Color numberBg;
    final Color numberColor;
    switch (status) {
      case SemiStepStatus.wait:
        iconColor = t.colorStepsItemWaitLeftIconIcon;
        numberBg = _hover && clickable
            ? t.colorStepsItemWaitLeftNumberIconBgHover
            : t.colorStepsItemWaitLeftNumberIconBg;
        numberColor = _hover && clickable
            ? t.colorStepsItemWaitLeftNumberIconIconHover
            : t.colorStepsItemWaitLeftNumberIconIcon;
      case SemiStepStatus.process:
        iconColor = t.colorStepsItemProcessLeftIcon;
        numberBg = t.colorStepsItemLeftNumberIconBg;
        numberColor = t.colorStepsItemProcessLeftNumberIcon;
      case SemiStepStatus.finish:
        iconColor = t.colorStepsItemFinishIcon;
        numberBg = t.colorStepsItemLeftNumberIconBg;
        numberColor = t.colorStepsItemFinishNumberIcon;
      case SemiStepStatus.error:
        iconColor = t.colorStepsItemErrorLeftIcon;
        numberBg = t.colorStepsItemLeftNumberIconBg;
        numberColor = t.colorStepsItemErrorLeftNumberIcon;
      case SemiStepStatus.warning:
        iconColor = t.colorStepsItemWarningLeftIcon;
        numberBg = t.colorStepsItemLeftNumberIconBg;
        numberColor = t.colorStepsItemWarningLeftNumberIcon;
    }

    final titleColor = _hover && clickable
        ? t.colorStepsItemTitleTextHover
        : status == SemiStepStatus.wait
        ? t.colorStepsItemWaitTitleText
        : t.colorStepsMainTextDefault;
    final descriptionColor = _hover && clickable
        ? t.colorStepsItemDescriptionTextHover
        : t.colorStepsMinorTextDefault;

    final titleStyle = TextStyle(
      // basic 标题 `@include font-size-header-6` = 16；small → regular 14。
      fontSize: small
          ? widget.global.typography.fontSizeRegular
          : _StepsMetrics.basicTitleFontSize,
      fontWeight: t.fontStepsBasicItemTitleFontWeight,
      height:
          t.fontStepsBasicItemTitleLineHeight /
          _StepsMetrics.basicTitleFontSize,
      color: titleColor,
    );
    final descriptionStyle = TextStyle(
      // `@include font-size-small` = 12。
      fontSize: _StepsMetrics.basicDescriptionFontSize,
      color: descriptionColor,
    );

    final icon = _buildBasicIcon(
      t: t,
      step: step,
      status: status,
      iconSize: iconSize,
      numberBox: numberBox,
      numberBg: numberBg,
      numberColor: numberColor,
      iconColor: iconColor,
      small: small,
    );

    final Widget body;
    if (vertical) {
      final lineColor = step.done
          ? t.colorStepsItemDoneIconAfterBg
          : t.colorStepsIconAfterBg;
      final paddingTop = widget.step.index == 0
          ? 0.0
          : t.spacingStepsBasicVerticalItemPaddingTop;
      // 垂直连接线画在整行盒上（避免 Row(stretch) 在无界高度下失效）：
      // 从图标底（含 padding-bottom 9）画到行底，长度上限
      // heightStepsVerticalIconAfter（9999px），宽度 widthStepsVerticalIconAfter。
      body = CustomPaint(
        painter: _BasicVerticalLinePainter(
          iconWidth: numberBox,
          paddingTop: paddingTop,
          lineTop:
              paddingTop +
              iconSize +
              t.spacingStepsBasicVerticalItemIconPaddingBottom,
          lineWidth: t.widthStepsVerticalIconAfter,
          maxLength: t.heightStepsVerticalIconAfter,
          color: lineColor,
          rtl: widget.rtl,
          visible: widget.hasLine && !step.last,
        ),
        child: Padding(
          // bacisSteps.scss:112-119：垂直步骤 padding-top 9（首项 0）。
          padding: EdgeInsets.only(top: paddingTop),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: numberBox,
                child: Padding(
                  // `-icon { padding-bottom: 9 }`。
                  padding: EdgeInsets.only(
                    bottom: t.spacingStepsBasicVerticalItemIconPaddingBottom,
                  ),
                  child: SizedBox(
                    height: iconSize,
                    child: Center(child: icon),
                  ),
                ),
              ),
              SizedBox(width: t.spacingStepsBasicItemLeftMarginRight),
              Expanded(
                child: Padding(
                  // `-content { min-height: 42; padding-bottom: 22 }`（small 40）。
                  padding: EdgeInsets.only(
                    bottom: t.spacingStepsBasicVerticalItemContentPaddingBottom,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: small
                          ? t.heightStepsBasicVerticalSmallItemContentMinHeight
                          : t.heightStepsBasicVerticalIconContentMinHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DefaultTextStyle.merge(
                          style: titleStyle,
                          child: _content(step.data.title),
                        ),
                        if (step.data.description != null)
                          // `width: $width-steps_basic_vertical_item_description: 100%`
                          //（widthStepsBasicVerticalItemDescription）——Column
                          // stretch 下即全宽。
                          Padding(
                            padding: EdgeInsets.only(
                              top: t.spacingStepsBasicItemTitlePaddingBottom,
                            ),
                            child: DefaultTextStyle.merge(
                              style: descriptionStyle,
                              child: _content(step.data.description),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final lineColor = step.done
          ? t.colorStepsItemDoneAfterBg
          : t.colorStepsTitleAfterBg;
      body = Padding(
        // `li padding-left 16`（首项 0）；标题 80% + 右 padding 16 + 连接线
        // （`width: 9999px` 省略/裁剪的口径）。
        padding: EdgeInsetsDirectional.only(
          start: widget.step.index == 0
              ? 0
              : t.spacingStepsBasicItemPaddingLeft,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(
                end: t.spacingStepsBasicItemLeftMarginRight,
              ),
              child: SizedBox(
                height: iconSize,
                child: Center(child: icon),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final titleMax =
                          constraints.maxWidth *
                          (step.last
                              ? t.widthStepsBasicVerticalItemTitleMaxWidth / 100
                              : t.widthStepsBasicItemTitleMaxWidth / 100);
                      return Row(
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: titleMax),
                            child: Padding(
                              padding: EdgeInsetsDirectional.only(
                                end: step.last
                                    ? 0
                                    : t.spacingStepsBasicItemTitlePaddingRight,
                              ),
                              child: DefaultTextStyle.merge(
                                style: titleStyle,
                                child: _content(step.data.title),
                              ),
                            ),
                          ),
                          if (widget.hasLine && !step.last)
                            Expanded(
                              child: ClipRect(
                                child: Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: SizedBox(
                                    // `width: $width-steps_title_after: 9999px`
                                    //（widthStepsTitleAfter）——超长连线由
                                    // item overflow 裁剪（ClipRect 同口径）。
                                    width: t.widthStepsTitleAfter,
                                    height: t.heightStepsTitleAfter,
                                    child: ColoredBox(color: lineColor),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  if (step.data.description != null)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: t.widthStepsBasicItemDescriptionMaxWidth,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: t.spacingStepsBasicItemTitlePaddingBottom,
                        ),
                        child: DefaultTextStyle.merge(
                          style: descriptionStyle,
                          child: _content(step.data.description),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return MouseRegion(
      cursor: clickable ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: clickable ? (_) => setState(() => _hover = true) : null,
      onExit: clickable ? (_) => setState(() => _hover = false) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: step.onTap,
        child: _enterActivatable(step.onTap, body),
      ),
    );
  }

  Widget _buildBasicIcon({
    required SemiResolvedStepsThemeData t,
    required _ResolvedStep step,
    required SemiStepStatus status,
    required double iconSize,
    required double numberBox,
    required Color numberBg,
    required Color numberColor,
    required Color iconColor,
    required bool small,
  }) {
    if (step.data.icon != null) {
      return DefaultTextStyle.merge(
        style: TextStyle(color: iconColor),
        child: step.data.icon!,
      );
    }
    if (status == SemiStepStatus.wait || status == SemiStepStatus.process) {
      return Container(
        width: numberBox,
        // 默认档高走 `$height-steps_basic_item_left_number-icon`（24）；
        // small 档宽高同走 small-minWidth 20（上游 quirk）。
        height: small ? numberBox : t.heightStepsBasicItemLeftNumberIcon,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: numberBg,
          // `var(--semi-border-radius-circle)`（= 50%，按尺寸取圆）。
          borderRadius: BorderRadius.circular(
            numberBox * t.radiusStepsBasicItemLeftNumberIcon / 100,
          ),
        ),
        child: Text(
          // 上游 `stepNumber: `${stepNumber + 1}``（0-based → 显示 1-based）。
          '${step.stepNumber + 1}',
          style: TextStyle(
            // 基准色 colorStepsItemLeftNumberIconIcon（白）被各状态覆盖
            //（bacisSteps.scss:171 基准 → 状态规则覆盖）。
            fontSize: small
                ? _StepsMetrics.basicSmallNumberFontSize
                : _StepsMetrics.basicNumberFontSize,
            fontWeight: t.fontStepsBasicItemLeftNumberIconFontWeight,
            color: numberColor,
          ),
        ),
      );
    }
    final icon = switch (status) {
      SemiStepStatus.finish => SemiIcons.tickCircle,
      SemiStepStatus.error => SemiIcons.alertCircle,
      SemiStepStatus.warning => SemiIcons.alertTriangle,
      _ => SemiIcons.tickCircle,
    };
    // stepSizeMapIconSize：`small = 'large'`（20）/ default extra-large（24）。
    return DefaultTextStyle.merge(
      style: TextStyle(color: iconColor),
      child: SemiIcon(
        icon,
        size: small ? SemiIconSize.large : SemiIconSize.extraLarge,
      ),
    );
  }
}

// -- nav ----------------------------------------------------------------------

class _NavSteps extends StatelessWidget {
  const _NavSteps({
    required this.steps,
    required this.size,
    required this.t,
    required this.global,
    required this.rtl,
  });

  final List<_ResolvedStep> steps;
  final SemiStepSize size;
  final SemiResolvedStepsThemeData t;
  final SemiThemeData global;
  final bool rtl;

  @override
  Widget build(BuildContext context) {
    final small = size == SemiStepSize.small;
    final fontSize = small
        ? global.typography.fontSizeRegular
        : _StepsMetrics.navTitleFontSize;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (final step in steps)
          Flexible(
            fit: FlexFit.loose,
            child: _NavStep(
              step: step,
              fontSize: fontSize,
              // `max-width: 17em`（em 相对标题字号 → 字号 × 17）。
              maxTitleWidth: t.widthStepsNavItemTitleMaxWidth * fontSize,
              iconMinWidth: t.widthStepsNavItemIconMinWidth,
              t: t,
              rtl: rtl,
            ),
          ),
      ],
    );
  }
}

class _NavStep extends StatelessWidget {
  const _NavStep({
    required this.step,
    required this.fontSize,
    required this.maxTitleWidth,
    required this.iconMinWidth,
    required this.t,
    required this.rtl,
  });

  final _ResolvedStep step;
  final double fontSize;
  final double maxTitleWidth;
  final double iconMinWidth;
  final SemiResolvedStepsThemeData t;
  final bool rtl;

  @override
  Widget build(BuildContext context) {
    final active = step.active;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxTitleWidth),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: active
                  ? t.fontStepsNavItemTitleActiveFontWeight
                  : t.fontStepsNavItemTitleFontWeight,
              color: active
                  ? t.colorStepsNavItemTitleTextActive
                  : t.colorStepsNavItemContainerText,
            ),
            child: _content(step.data.title, maxLines: 1),
          ),
        ),
        if (!step.last)
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: iconMinWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: t.spacingStepsBasicItemPaddingLeft / 2,
              ),
              child: Center(
                // navStep.tsx:49-53 `IconChevronRight size="small"`（20）。
                child: SemiIcon(
                  SemiIcons.chevronRight,
                  size: SemiIconSize.large,
                  color: t.colorStepsNavItemIcon,
                ),
              ),
            ),
          ),
      ],
    );
    final target = _enterActivatable(step.onTap, content);
    // nav 无 clickable 光标/hover 视觉（上游 navStep 不挂 clickable 类）。
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: step.onTap,
      child: Semantics(
        // aria-current（`aria-current` 语义近似）。
        selected: active,
        button: step.onTap != null,
        child: target,
      ),
    );
  }
}

/// basic 垂直连接线（tree 先例的行级 painter 方案：避免 Row(stretch) 在无界
/// 高度（页面滚动）下失效）。
class _BasicVerticalLinePainter extends CustomPainter {
  _BasicVerticalLinePainter({
    required this.iconWidth,
    required this.paddingTop,
    required this.lineTop,
    required this.lineWidth,
    required this.maxLength,
    required this.color,
    required this.rtl,
    required this.visible,
  });

  final double iconWidth;
  final double paddingTop;
  final double lineTop;
  final double lineWidth;
  final double maxLength;
  final Color color;
  final bool rtl;
  final bool visible;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible) {
      return;
    }
    final x = rtl ? size.width - iconWidth / 2 : iconWidth / 2;
    final end = lineTop + maxLength > size.height
        ? size.height
        : lineTop + maxLength;
    if (end <= lineTop) {
      return;
    }
    canvas.drawRect(
      Rect.fromLTRB(x - lineWidth / 2, lineTop, x + lineWidth / 2, end),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_BasicVerticalLinePainter oldDelegate) =>
      iconWidth != oldDelegate.iconWidth ||
      paddingTop != oldDelegate.paddingTop ||
      lineTop != oldDelegate.lineTop ||
      lineWidth != oldDelegate.lineWidth ||
      maxLength != oldDelegate.maxLength ||
      color != oldDelegate.color ||
      rtl != oldDelegate.rtl ||
      visible != oldDelegate.visible;
}

/// HARDCODES（另列）上游片段逐字留档（生成器 assertIn 锚点）。
abstract final class _StepsMetrics {
  /// fillSteps.scss:49 `@include font-size-header-5` = 18（fill 标题）。
  static const double fillTitleFontSize = 18;

  /// fillSteps.scss:175 `@include font-size-header-4` = 20（fill 左序号）。
  static const double fillLeftFontSize = 20;

  /// fillSteps.scss:176 `font-weight: $font-weight-bold`（= 600）。
  static const FontWeight fillLeftFontWeight = FontWeight.w600;

  /// fillSteps.scss:57 `@include font-size-regular` = 14（fill 描述）。
  static const double fillDescriptionFontSize = 14;

  /// bacisSteps.scss:34 `@include font-size-header-6` = 16（basic 标题）。
  static const double basicTitleFontSize = 16;

  /// bacisSteps.scss:24 `@include font-size-small` = 12（basic 描述）。
  static const double basicDescriptionFontSize = 12;

  /// bacisSteps.scss:170 `@include font-size-header-6` = 16（basic 序号）。
  static const double basicNumberFontSize = 16;

  /// bacisSteps.scss:214 `@include font-size-small` = 12（small 序号）。
  static const double basicSmallNumberFontSize = 12;

  /// navSteps.scss:39 `@include font-size-header-6` = 16（nav 标题）。
  static const double navTitleFontSize = 16;

  // note-only 上游片段（生成器锚点逐字留档）：
  // basicSteps.tsx:54 `${prefixCls}-next-error`（error 前一步类名——无对应 CSS）
  // ；`tabIndex={0}`；basicStep.tsx:111 `e.key === 'Enter'`；
  // basicStep.tsx:19 `stepSizeMapIconSize` 的 `small = 'large'`；
  // navStep.tsx:49 `IconChevronRight size="small"`；
  // fillStep.tsx:90 `title={typeof title === 'string' ? title : null}`（原生
  // title 属性，Flutter 无对应——note-only）；
  // `text-overflow-hidden` / `@include font-size-header-6/5/4` mixin 来源；
  // fillSteps.tsx:30 `width: `${100 / filteredChildren.length}%``（等宽列）；
  // `aria-current` 语义；nav `17em`；连线长度 `9999px` 由 overflow 裁剪；
  // ★无效 transform 编译 bug `transform: scale(scale(1,1))`；
  // ★`rgba(var(--semi-white), 1)` 白色写法 quirk；
  // ★transition 名混写 `$transition_duration-steps_item-backgroundColor`；
  // BasicSteps `hasLine = true` 缺省。
}
