# SemiSteps

步骤条（上游 Semi Steps 全件移植）：三形态 `type`——`fill`（卡片分栏：左序号/状态图标 + 标题 + 描述，状态底色与可点击 hover/active）、`basic`（简版：标题 + 连接线，`direction` 水平/垂直、`hasLine` 连接线、小尺寸、可点击标题/描述变色）、`nav`（导航式：标题 + chevron，当前项 text-0 + 600）。状态推导（basicSteps.tsx:43-64 / fillSteps.tsx:39-58）：`step.status` 优先，否则 `stepNumber == current → status`、`< current → finish`、其余 `wait`；`active = stepNumber == current`；`done = stepNumber < current`（basic 连接线着色）。点击包壳先 `step.onClick` 后 `onChange(stepNumber)`（当前步不回调），无 onChange/onClick 不可点击；键盘 Enter 激活（`tabIndex={0}`）。主题对账 **104 = 94 FIELDS + 10 MOTION + 0 INTERNAL**（variables.scss 94 + animation.scss 10 亲验——steps.scss:4 `@import "./animation.scss"` + bacisSteps.scss:181-182 / fillSteps.scss:42-44 消费，0ms/ease-in/0ms/scale(1,1) 恒等；`$module: #{$prefix}-steps` 类名胶水不计，datePicker `223 = 220 + 3 + 0`、timePicker `20 = 14 + 6 + 0`、transfer `50 = 47 + 3 + 0`、anchor `30 = 26 + 4 + 0`、breadcrumb `20 = 16 + 4 + 0`、pagination `48 = 41 + 7 + 0`、tree `33 = 29 + 4 + 0` 先例）；★**5 死变量**（真死零引用：`$height-steps_basic_item`、`$width-steps_item_left_icon`、`$spacing-steps_basic_item-marginRight`、`$font-steps_item_title-fontWeight`、`$font-steps_item_left-fontWeight`——留档不消费，docs 行标注「（上游未消费）」）。

## API

`SemiSteps({type: SemiStepsType.fill, steps: const [], current: 0, initial: 0, status: SemiStepStatus.process, direction: SemiStepsDirection.horizontal, size: SemiStepSize.defaultSize, hasLine: true, onChange, semanticsLabel})`。

type `fill`（| basic | nav）。steps `List<SemiStepData>`（上游 `<Steps.Step>` 子节点）。current `0`（当前步骤，含 initial 偏移）。initial `0`（起始序号）。status `process`（步骤条级状态——当前步缺省状态）。direction `horizontal`（| vertical；basic/fill）。size `defaultSize`（| small；basic/nav——fill 无 size，上游 FillSteps 忽略）。hasLine `true`（basic 连接线——上游 BasicSteps 缺省 `hasLine = true`）。onChange `ValueChanged<int>?`（点击非当前步触发）。semanticsLabel `String?`（aria-label）。

`SemiStepData({title, description, icon, status, onClick})`：title `Object?`（String | Widget）、description `Object?`（fill/basic 描述）、icon `Widget?`（自定义图标覆盖状态图标；basic 不再渲染序号圆）、status `SemiStepStatus?`（覆盖推导）、onClick `VoidCallback?`（先于 onChange）。

`SemiStepStatus { wait, process, finish, error, warning }`、`SemiStepsType { fill, basic, nav }`、`SemiStepsDirection { horizontal, vertical }`、`SemiStepSize { defaultSize, small }`。

## 行为

### 状态推导与点击

`stepNumber = initial + index`；`step.status` 优先；否则当前步用步骤条 `status`、小于 current 用 `finish`、其余 `wait`；`active`/`done` 同上。点击（basicStep.tsx:77-93 / fillStep.tsx:64-80 / navStep.tsx:33-44）：先 `step.onClick` 后 `onChange(stepNumber)`，★当前步不回调（`index + initial !== current` 守卫）；有 onChange 或 onClick 才挂点击（fill/basic 光标 pointer + hover 态；nav 无光标/hover 视觉 quirk）。Enter 激活（basic/fill/nav 均 `tabIndex={0}` + `e.key === 'Enter'`）。

### fill

卡片等宽分栏（水平 `Row` + `Expanded`；垂直 `Column`）：item 高 72、右 margin 16、边框 1（透明）+ 圆角 medium(6)、paddingY 12 / paddingX 16、bg 过渡三元组 + `transform: scale(...)`（scale(1,1) 恒等）。左槽 24×24 圆角 32：wait 序号（底 text-2、字白）、process 序号（底 primary、字白——★`-left-process` 用 `primary-bg-default`，浅底白字 quirk 照抄）、finish/error/warning 状态图标 24（tick/alert-circle/alert-triangle），可点击 finish/error/warning hover/active 底色与字色（success/danger/warning 系）。序号行盒 32（`font-steps_item_left-lineHeight`）溢出 24 圆盒居中——`leadingDistribution: even` + `OverflowBox` 对齐 CSS「半行距上下均分、行盒溢出居中」（默认 proportional + Align 钳高会把数字压低溢出圆圈）。标题 header-5(18) bold，状态色（process primary / finish success / error danger / warning warning / wait text-0）；描述 regular(14) text-2；可点击 hover 时描述 focus-border。自定义 icon 走左槽图标（不渲染序号，wait/process 底色不生效——`:not(.item-icon)`）。

### basic

水平：每步 flex 1（末项 flex none），标题 + 连接线（`width: $width-steps_title_after: 9999px` 由 item 裁剪；`hasLine` 才画），done 连接线 primary、否则 fill-2；标题 max-width 80%（末项 100%）、右 padding 16、margin-bottom 4、maxLines 1 ellipsis；描述 small(12) text-2、max-width 268。垂直：每步 padding-top 9（首项 0），icon 列（宽 = 序号盒）下接垂直连接线（1×9999 裁剪；done → primary）；content min-height 42（small 40）、padding-bottom 22；标题 100%。图标：wait/process 序号圆（24 / small 20；radius = `size * radiusStepsBasicItemLeftNumberIcon%`），wait 底 fill-0 字 text-2、process 底 primary 字白；finish/error/warning 图标（small large(20) / default extra-large(24)）；★`stepSizeMapIconSize`：`small = 'large'`。可点击时标题/描述 hover focus-border；wait 序号 hover 底 secondary-light-default、字 focus-border。

### nav

inline-flex 行：每步标题（header-6(16)；small regular(14)；`max-width: 17em`——em 相对字号，按 `17 × fontSize` 计算；maxLines 1 ellipsis）+ 非末项右侧 chevron 区（min-width 60、图标 `IconChevronRight size="small"`、色 grey-3）；标题默认 text-2，当前项 text-0 + 600（`fontStepsNavItemTitleActiveFontWeight`）。

### 视觉与 RTL

行内边距/外距全部 EdgeInsetsDirectional（RTL 自动翻边）；basic 水平连接线随标题尾部方向（RTL 由 Row 方向镜像）；fill/nav 无 RTL 专属规则（rtl.scss 只做 direction/margin 互换）。aria：根 `aria-label`；步骤 `aria-current` → Semantics selected 近似。

## 主题（104 对账）

来源 packages/semi-foundation/steps/variables.scss（94 声明行——color 45、width/height 26、spacing 12、radius 3、font 8）+ packages/semi-foundation/steps/animation.scss（10 声明行——title-text / title-icon / backgroundColor 三个 transition 三元组 + transform scale）。对账 **104 = 94 FIELDS + 10 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表；`$module` 类名胶水不计）。★**5 死变量**（真死）。全局 token 解析：`var(--semi-color-*)` → `theme.colors.*`（text-0/2、fill-0/1/2、primary、primary-light-default、white、success/danger/warning 各 hover/active、focus-border、secondary-light-default）、`var(--semi-grey-3)` → `theme.palette.grey3.toColor(1)`、`transparent` → `const Color(0x00000000)`、★`rgba(var(--semi-white), 1)` → `theme.colors.colorWhite`（写法照抄）；引用 token：`$spacing-base-tight` → 12、`$spacing-base` → 16、`$font-weight-regular/bold` → `theme.typography.fontWeightRegular/Bold`、`var(--semi-border-radius-medium/circle)` → `theme.radius.borderRadiusMedium/Circle.value`（= 6 / 50——circle 是百分比值，消费按 `size * value / 100`）；字面 600 → `FontWeight.w600`（progress/select 先例）；motion 十元组：`Duration.zero` / `Curves.easeIn` / `const SemiTransform.scale(1, 1)`（`--semi-transform_scale-small` = scale(1,1)）。百分比/em 默认值按数值存档（`100%` → 100、`80%` → 80、`17em` → 17，datePicker 先例）。类型覆盖：**45 Color + 43 double + 6 FontWeight + 6 Duration + 3 Curve + 1 SemiTransform = 104**。解析列即 `SemiStepsThemeData.resolve` 默认表达式。

### A. Sass 声明映射（94 FIELDS + 10 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-steps-bg-active: var(--semi-color-fill-1)` | `colorStepsBgActive` | `theme.colors.colorFill1` |
| `$color-steps-bg-default: var(--semi-color-text-2)` | `colorStepsBgDefault` | `theme.colors.colorText2` |
| `$color-steps-bg-hover: var(--semi-color-fill-0)` | `colorStepsBgHover` | `theme.colors.colorFill0` |
| `$color-steps-border-default: transparent` | `colorStepsBorderDefault` | `const Color(0x00000000)` |
| `$color-steps-icon-default: var(--semi-color-text-2)` | `colorStepsIconDefault` | `theme.colors.colorText2` |
| `$color-steps-text-default: rgba(var(--semi-white), 1)` | `colorStepsTextDefault` | `theme.colors.colorWhite` |
| `$color-steps_danger-text-active: var(--semi-color-danger-active)` | `colorStepsDangerTextActive` | `theme.colors.colorDangerActive` |
| `$color-steps_danger-text-default: var(--semi-color-danger)` | `colorStepsDangerTextDefault` | `theme.colors.colorDanger` |
| `$color-steps_danger-text-hover: var(--semi-color-danger-hover)` | `colorStepsDangerTextHover` | `theme.colors.colorDangerHover` |
| `$color-steps_icon_after-bg: var(--semi-color-fill-2)` | `colorStepsIconAfterBg` | `theme.colors.colorFill2` |
| `$color-steps_item_description-text-hover: var(--semi-color-focus-border)` | `colorStepsItemDescriptionTextHover` | `theme.colors.colorFocusBorder` |
| `$color-steps_item_done_after-bg: var(--semi-color-primary)` | `colorStepsItemDoneAfterBg` | `theme.colors.colorPrimary` |
| `$color-steps_item_done_icon_after-bg: var(--semi-color-primary)` | `colorStepsItemDoneIconAfterBg` | `theme.colors.colorPrimary` |
| `$color-steps_item_error_left-icon: var(--semi-color-danger)` | `colorStepsItemErrorLeftIcon` | `theme.colors.colorDanger` |
| `$color-steps_item_error_left_number-icon: var(--semi-color-primary)` | `colorStepsItemErrorLeftNumberIcon` | `theme.colors.colorPrimary` |
| `$color-steps_item_finish-icon: var(--semi-color-primary)` | `colorStepsItemFinishIcon` | `theme.colors.colorPrimary` |
| `$color-steps_item_finish_number-icon: var(--semi-color-white)` | `colorStepsItemFinishNumberIcon` | `theme.colors.colorWhite` |
| `$color-steps_item_left_number_icon-bg: var(--semi-color-primary)` | `colorStepsItemLeftNumberIconBg` | `theme.colors.colorPrimary` |
| `$color-steps_item_left_number_icon-icon: var(--semi-color-white)` | `colorStepsItemLeftNumberIconIcon` | `theme.colors.colorWhite` |
| `$color-steps_item_process_left-icon: var(--semi-color-primary)` | `colorStepsItemProcessLeftIcon` | `theme.colors.colorPrimary` |
| `$color-steps_item_process_left_number-icon: var(--semi-color-white)` | `colorStepsItemProcessLeftNumberIcon` | `theme.colors.colorWhite` |
| `$color-steps_item_title-text-hover: var(--semi-color-focus-border)` | `colorStepsItemTitleTextHover` | `theme.colors.colorFocusBorder` |
| `$color-steps_item_wait_left_icon-icon: var(--semi-color-text-2)` | `colorStepsItemWaitLeftIconIcon` | `theme.colors.colorText2` |
| `$color-steps_item_wait_left_number_icon-bg-hover: var(--semi-color-secondary-light-default)` | `colorStepsItemWaitLeftNumberIconBgHover` | `theme.colors.colorSecondaryLightDefault` |
| `$color-steps_item_wait_left_number_icon-bg: var(--semi-color-fill-0)` | `colorStepsItemWaitLeftNumberIconBg` | `theme.colors.colorFill0` |
| `$color-steps_item_wait_left_number_icon-icon-hover: var(--semi-color-focus-border)` | `colorStepsItemWaitLeftNumberIconIconHover` | `theme.colors.colorFocusBorder` |
| `$color-steps_item_wait_left_number_icon-icon: var(--semi-color-text-2)` | `colorStepsItemWaitLeftNumberIconIcon` | `theme.colors.colorText2` |
| `$color-steps_item_wait_title-text: var(--semi-color-text-2)` | `colorStepsItemWaitTitleText` | `theme.colors.colorText2` |
| `$color-steps_item_warning_left-icon: var(--semi-color-warning)` | `colorStepsItemWarningLeftIcon` | `theme.colors.colorWarning` |
| `$color-steps_item_warning_left_number-icon: var(--semi-color-white)` | `colorStepsItemWarningLeftNumberIcon` | `theme.colors.colorWhite` |
| `$color-steps_main-text-default: var(--semi-color-text-0)` | `colorStepsMainTextDefault` | `theme.colors.colorText0` |
| `$color-steps_minor-text-default: var(--semi-color-text-2)` | `colorStepsMinorTextDefault` | `theme.colors.colorText2` |
| `$color-steps_nav_item_container-text: var(--semi-color-text-2)` | `colorStepsNavItemContainerText` | `theme.colors.colorText2` |
| `$color-steps_nav_item-icon: var(--semi-grey-3)` | `colorStepsNavItemIcon` | `theme.palette.grey3.toColor(1)` |
| `$color-steps_nav_item_title-text-active: var(--semi-color-text-0)` | `colorStepsNavItemTitleTextActive` | `theme.colors.colorText0` |
| `$color-steps_primary-bg-default: var(--semi-color-primary)` | `colorStepsPrimaryBgDefault` | `theme.colors.colorPrimary` |
| `$color-steps_primary-icon-default: var(--semi-color-primary)` | `colorStepsPrimaryIconDefault` | `theme.colors.colorPrimary` |
| `$color-steps_process-bg-default: var(--semi-color-primary-light-default)` | `colorStepsProcessBgDefault` | `theme.colors.colorPrimaryLightDefault` |
| `$color-steps_success-text-active: var(--semi-color-success-active)` | `colorStepsSuccessTextActive` | `theme.colors.colorSuccessActive` |
| `$color-steps_success-text-default: var(--semi-color-success)` | `colorStepsSuccessTextDefault` | `theme.colors.colorSuccess` |
| `$color-steps_success-text-hover: var(--semi-color-success-hover)` | `colorStepsSuccessTextHover` | `theme.colors.colorSuccessHover` |
| `$color-steps_title_after-bg: var(--semi-color-fill-2)` | `colorStepsTitleAfterBg` | `theme.colors.colorFill2` |
| `$color-steps_warning-text-active: var(--semi-color-warning-active)` | `colorStepsWarningTextActive` | `theme.colors.colorWarningActive` |
| `$color-steps_warning-text-default: var(--semi-color-warning)` | `colorStepsWarningTextDefault` | `theme.colors.colorWarning` |
| `$color-steps_warning-text-hover: var(--semi-color-warning-hover)` | `colorStepsWarningTextHover` | `theme.colors.colorWarningHover` |
| `$width-steps_basic_item_description: 100%` | `widthStepsBasicItemDescription` | `100` |
| `$width-steps_basic_item_description-maxWidth: 268px` | `widthStepsBasicItemDescriptionMaxWidth` | `268` |
| `$width-steps_basic_item_title-maxWidth: 80%` | `widthStepsBasicItemTitleMaxWidth` | `80` |
| `$height-steps_basic_vertical_icon_content-minHeight: 42px` | `heightStepsBasicVerticalIconContentMinHeight` | `42` |
| `$width-steps_basic_vertical_item_title-maxWidth: 100%` | `widthStepsBasicVerticalItemTitleMaxWidth` | `100` |
| `$width-steps_basic_vertical_item_description: 100%` | `widthStepsBasicVerticalItemDescription` | `100` |
| `$height-steps_basic_vertical_small_item_content-minHeight: 40px` | `heightStepsBasicVerticalSmallItemContentMinHeight` | `40` |
| `$height-steps_basic_item_left-icon: 24px` | `heightStepsBasicItemLeftIcon` | `24` |
| `$width-steps_basic_item_left_number-icon: 24px` | `widthStepsBasicItemLeftNumberIcon` | `24` |
| `$height-steps_basic_item_left_number-icon: 24px` | `heightStepsBasicItemLeftNumberIcon` | `24` |
| `$height-steps_basic_small_item_left-icon: 20px` | `heightStepsBasicSmallItemLeftIcon` | `20` |
| `$width-steps_basic_small_item_left_number-icon: 20px` | `widthStepsBasicSmallItemLeftNumberIcon` | `20` |
| `$height-steps_basic_item: 72px` | `heightStepsBasicItem` | `72（**上游未消费**）` |
| `$height-steps_item: 72px` | `heightStepsItem` | `72` |
| `$width-steps_item-border: 1px` | `widthStepsItemBorder` | `1` |
| `$width-steps_item_title: 100%` | `widthStepsItemTitle` | `100` |
| `$width-steps_item_description: 100%` | `widthStepsItemDescription` | `100` |
| `$width-steps_item_left_icon: 24px` | `widthStepsItemLeftIcon` | `24（**上游未消费**）` |
| `$width-steps_item_left: 24px` | `widthStepsItemLeft` | `24` |
| `$height-steps_item_left: 24px` | `heightStepsItemLeft` | `24` |
| `$width-steps_title_after: 9999px` | `widthStepsTitleAfter` | `9999` |
| `$height-steps_title_after: 1px` | `heightStepsTitleAfter` | `1` |
| `$width-steps_vertical_icon_after: 1px` | `widthStepsVerticalIconAfter` | `1` |
| `$height-steps_vertical_icon_after: 9999px` | `heightStepsVerticalIconAfter` | `9999` |
| `$width-steps_nav_item_icon-minWidth: 60px` | `widthStepsNavItemIconMinWidth` | `60` |
| `$width-steps_nav_item_title-maxWidth: 17em` | `widthStepsNavItemTitleMaxWidth` | `17` |
| `$spacing-steps_basic_item-paddingLeft: 16px` | `spacingStepsBasicItemPaddingLeft` | `16` |
| `$spacing-steps_basic_vertical_item-paddingTop: 9px` | `spacingStepsBasicVerticalItemPaddingTop` | `9` |
| `$spacing-steps_basic_vertical_item_content-paddingBottom: 22px` | `spacingStepsBasicVerticalItemContentPaddingBottom` | `22` |
| `$spacing-steps_basic_vertical_item_icon-paddingBottom: 9px` | `spacingStepsBasicVerticalItemIconPaddingBottom` | `9` |
| `$spacing-steps_basic_item_left-marginRight: 8px` | `spacingStepsBasicItemLeftMarginRight` | `8` |
| `$spacing-steps_basic_item_title-paddingRight: 16px` | `spacingStepsBasicItemTitlePaddingRight` | `16` |
| `$spacing-steps_basic_item_title-paddingBottom: 4px` | `spacingStepsBasicItemTitlePaddingBottom` | `4` |
| `$spacing-steps_basic_item-marginRight: 16px` | `spacingStepsBasicItemMarginRight` | `16（**上游未消费**）` |
| `$spacing-steps_item-marginRight: 16px` | `spacingStepsItemMarginRight` | `16` |
| `$spacing-steps_item-paddingY: $spacing-base-tight` | `spacingStepsItemPaddingY` | `12` |
| `$spacing-steps_item-paddingX: $spacing-base` | `spacingStepsItemPaddingX` | `16` |
| `$spacing-steps_item_content-marginLeft: $spacing-base` | `spacingStepsItemContentMarginLeft` | `16` |
| `$radius-steps_basic_item_left_number_icon: var(--semi-border-radius-circle)` | `radiusStepsBasicItemLeftNumberIcon` | `theme.radius.borderRadiusCircle.value` |
| `$radius-steps_item: var(--semi-border-radius-medium)` | `radiusStepsItem` | `theme.radius.borderRadiusMedium.value` |
| `$radius-steps_item_left: 32px` | `radiusStepsItemLeft` | `32` |
| `$font-steps_basic_item_left_number_icon-fontWeight: 600` | `fontStepsBasicItemLeftNumberIconFontWeight` | `FontWeight.w600` |
| `$font-steps_basic_item_title-fontWeight: 600` | `fontStepsBasicItemTitleFontWeight` | `FontWeight.w600` |
| `$font-steps_basic_item_title-lineHeight: 24px` | `fontStepsBasicItemTitleLineHeight` | `24` |
| `$font-steps_item_title-fontWeight: $font-weight-bold` | `fontStepsItemTitleFontWeight` | `theme.typography.fontWeightBold（**上游未消费**）` |
| `$font-steps_item_left-fontWeight: $font-weight-bold` | `fontStepsItemLeftFontWeight` | `theme.typography.fontWeightBold（**上游未消费**）` |
| `$font-steps_item_left-lineHeight: 32px` | `fontStepsItemLeftLineHeight` | `32` |
| `$font-steps_nav_item_title-fontWeight: $font-weight-regular` | `fontStepsNavItemTitleFontWeight` | `theme.typography.fontWeightRegular` |
| `$font-steps_nav_item_title_active-fontWeight: 600` | `fontStepsNavItemTitleActiveFontWeight` | `FontWeight.w600` |
| `$transition_duration-steps_item_title-text: var(--semi-transition_duration-none)` | `transitionDurationStepsItemTitleText` | `Duration.zero` |
| `$transition_function-steps_item_title-text: var(--semi-transition_function-easeIn)` | `transitionFunctionStepsItemTitleText` | `Curves.easeIn` |
| `$transition_delay-steps_item_title-text: var(--semi-transition_delay-none)` | `transitionDelayStepsItemTitleText` | `Duration.zero` |
| `$transition_duration-steps_item_title-icon: var(--semi-transition_duration-none)` | `transitionDurationStepsItemTitleIcon` | `Duration.zero` |
| `$transition_function-steps_item_title-icon: var(--semi-transition_function-easeIn)` | `transitionFunctionStepsItemTitleIcon` | `Curves.easeIn` |
| `$transition_delay-steps_item_title-icon: var(--semi-transition_delay-none)` | `transitionDelayStepsItemTitleIcon` | `Duration.zero` |
| `$transition_duration-steps_item_backgroundColor: var(--semi-transition_duration-none)` | `transitionDurationStepsItemBackgroundColor` | `Duration.zero` |
| `$transition_function-steps_item_backgroundColor: var(--semi-transition_function-easeIn)` | `transitionFunctionStepsItemBackgroundColor` | `Curves.easeIn` |
| `$transition_delay-steps_item_backgroundColor: var(--semi-transition_delay-none)` | `transitionDelayStepsItemBackgroundColor` | `Duration.zero` |
| `$transform_scale-step-item: var(--semi-transform_scale-small)` | `transformScaleStepItem` | `const SemiTransform.scale(1, 1)` |

### B. HARDCODES 另列（`_StepsMetrics` / 调用点，widget 源内含原始片段）

| 上游片段 | 落点 |
|---|---|
| `-next-error` | basic error 前一步类名（basicSteps.tsx:54；无对应 CSS 规则——note-only） |
| `tabIndex={0}` | 步骤可聚焦（basicStep/fillStep/navStep） |
| `e.key === 'Enter'` | Enter 激活（同上） |
| `small = 'large'` | `stepSizeMapIconSize`（basic 图标 small 20 / default 24） |
| `IconChevronRight size="small"` | nav 分隔 chevron（navStep.tsx:49 → SemiIcons.chevronRight size large） |
| `title={typeof title === 'string' ? title : null}` | fill 原生 title 属性（Flutter 无对应——note-only） |
| `text-overflow-hidden` | 标题/描述省略 mixin 来源 |
| `@include font-size-header-6` / `header-5` / `header-4` | 标题 16 / fill 标题 18 / fill 序号 20（mixin 来源） |
| `width: ${100 / filteredChildren.length}%` | fill 等宽列（fillSteps.tsx:30 → Expanded） |
| `aria-current` | 当前步语义（Semantics selected 近似） |
| `17em` | nav 标题 max-width（em → `17 × fontSize`） |
| `9999px` | basic 连接线长度（裁剪兜底） |
| `transform: scale(scale(1,1))` | note-only——无效编译 bug（token 自带 scale(1,1) 再包 scale(...)） |
| `rgba(var(--semi-white), 1)` | 白色写法 quirk（`$color-steps-text-default`） |
| `$transition_duration-steps_item-backgroundColor` | note-only——使用处 `-` vs 声明 `_` 混写（Sass 等价） |
| `hasLine = true` | basic 连接线缺省（basicSteps.tsx:26） |

## 差异清单

★照搬留档（quirk 原样）：

1. **当前步不回调**：点击当前步只发 `step.onClick`，`onChange` 不触发（`index + initial !== current` 守卫）。
2. **nav 无 hover/光标**：navStep 不挂 clickable 类——点击可切换但无视觉反馈。
3. **fill process 浅底白字**：`-left-process` 底色 `primary-bg-default`（primary），序号字色 `$color-steps-text-default`（白）——对比度低 quirk 照抄；wait 序号底 text-2 同字白。
4. **basic 状态序号色混搭**：error 序号字 primary（底仍 primary 基准）等零散规则照抄。
5. **白色写法 / 命名混写**：★`rgba(var(--semi-white), 1)`、`-`/`_` transition 名混写、无效 `scale(scale(1,1))` 编译产物。
6. **`-next-error` 无 CSS**：basicSteps 仅加类名（供自定义样式/测试观察），上游无内置规则——note-only。
7. **占比/em token**：`100%`/`80%`/`17em` 数值存档（100/80/17），widget 按布局/字号换算。

偏差/裁剪：

8. **children → steps 数据**：上游 `Steps.Step` React 子节点（cloneElement 注入 status/active/onChange）→ `List<SemiStepData>` 强类型列表（同 navigation/tree 先例）。
9. **grid → Row/Expanded**：fill 用 `Row/Column + Expanded` 代替 Semi Grid（等分语义等价）。
10. **原生 title 属性不移植**：fill 标题/描述的 `title=...`（浏览器悬停原生提示）无 Flutter 对应（note-only）。
11. **className/style/getDataAttr/prefixCls 裁剪**：Flutter 无 CSS 类；`-next-error` 类名无落点（note-only）。
12. **aria 近似**：`aria-current` → Semantics(selected)；根 `aria-label` → Semantics label。
13. **nav 布局近似**：上游 content flex 1 + icon min-width 60；本移植标题内容宽 + 60 宽 chevron 槽（视觉一致）。
14. **fill 自定义 icon 尺寸**：上游自定义图标按传入尺寸渲染（不套 `stepSizeMapIconSize`）；本移植同。

## 用法

```dart
SemiSteps(
  steps: const [
    SemiStepData(title: '已完成', description: '这是描述'),
    SemiStepData(title: '进行中', description: '这是描述'),
    SemiStepData(title: '等待中', description: '这是描述'),
  ],
  current: 1,
  onChange: (current) {},
)

// basic + 垂直 + 小尺寸
SemiSteps(
  type: SemiStepsType.basic,
  direction: SemiStepsDirection.vertical,
  size: SemiStepSize.small,
  hasLine: true,
  current: 0,
  status: SemiStepStatus.error,
  steps: [
    SemiStepData(title: '填写信息', description: '基础信息'),
    const SemiStepData(title: '验证', status: SemiStepStatus.error),
  ],
)

// nav
SemiSteps(
  type: SemiStepsType.nav,
  current: 1,
  steps: const [
    SemiStepData(title: '第一步'),
    SemiStepData(title: '第二步'),
    SemiStepData(title: '第三步'),
  ],
)
```
