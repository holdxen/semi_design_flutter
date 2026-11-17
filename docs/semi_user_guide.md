# SemiUserGuide

用户引导（上游 Semi UserGuide 全件移植）：分步引导——`mode: 'popup'`（缺省）为当前步气泡卡锚定聚光灯挖洞蒙层（目标外扩 `spotlightPadding` 的 padded 矩形，洞口点击穿透到目标、蒙层区吞点击），`mode: 'modal'` 为居中弹窗卡（cover + 指示点 + 正文 + 按钮行，壳体走 SemiModal）。值模型：`current`（非 null 即受控）+ `steps` 步进列表（`target` 引用 `SemiUserGuideTarget` 注册目标）。回调：`onChange(current)` 仅值变化时发（foundation.ts:23-28 `_notifyChange`）、`onPrev/onNext(current)` 步进即发（:56-78；★prev 不 clamp、next 末步只发 onFinish）、`onSkip` 仅通知（:80-82 不关显隐）、`onFinish` 末步 next 发（:68-70）。开档归零（index.tsx:181-184 `setState({ current: 0 })`，不发 onChange）。蒙层优先序 `step.mask ?? mask`（:440/:543）；聚光灯内边距 `step.spotlightPadding ?? spotlightPadding ?? DEFAULT_SPOTLIGHT_PADDING`（foundation.ts:47-55 `getFinalPaading`——★方法名拼写 quirk 原文照抄；★0 照消费）。主题对账 **37 = 35 FIELDS + 2 MOTION + 0 INTERNAL**（35 = variables.scss 全部声明、2 = animation.scss 全部声明——**活文件**（userGuide.scss:2 `@import "./animation.scss"` + :22 消费，洞口 200ms/cubic-bezier(0.4,0,0.2,1) 补间）；`$module: #{$prefix}-userGuide` 类名胶水不计，anchor `30 = 26 + 4 + 0`、datePicker `223 = 220 + 3 + 0`、timePicker `20 = 14 + 6 + 0`、transfer `50 = 47 + 3 + 0` 先例）。

## API

`SemiUserGuide({current, finishText, skipText, prevText, nextText, mask: true, mode: SemiUserGuideMode.popup, nextButtonProps, onChange, onFinish, onNext, onPrev, onSkip, position: SemiTooltipPosition.bottom, prevButtonProps, showPrevButton: true, showSkipButton: true, spotlightPadding, steps: const [], theme: SemiUserGuideThemeMode.defaultTheme, visible: false, zIndex: 1030})`。

current `int?`（非 null 即受控——上游 `_isInProps('current')` 的显式 null 受控无对应）。finishText `String?`（末步按钮文案，缺省「完成」）。skipText/prevText/nextText `String?`（缺省「跳过/上一步/下一步」；上游 locale 无 Flutter 对应——必要新增，popconfirm `okText` 先例；prev/next 文案被 `*.child` 顶替）。mask `true`（蒙层；`step.mask` 优先）。mode `popup`（| modal）。position `SemiTooltipPosition.bottom`（卡片位置；`step.position` 优先）。showPrevButton/showSkipButton `true`（首步恒不显 prev、末步恒不显 skip）。spotlightPadding `double?`（聚光灯内边距；`step.spotlightPadding` 优先、缺省 5）。steps `List<SemiUserGuideStep>`（缺省空——空/不可见时整棵不渲染，index.tsx:583-585）。theme `defaultTheme`（| primary——★modal 模式不消费）。visible `false`。zIndex `1030`（parity 参数——overlay 插入序即层序）。回调见概述。

`SemiUserGuideStep({target, cover, title, description, mask, showArrow, spotlightPadding, theme, position})`：target `String?`（`SemiUserGuideTarget` 注册 id——上游 `(() => Element) | Element`，见差异清单；popup 无 target 步整棵不出）。cover `Widget?`（popup 定高 200 + top 圆角、modal 定高 300）。title/description `Object?`（String | Widget）。mask `bool?`、showArrow `bool?`（缺省 true）、spotlightPadding `double?`（★0 照消费）、theme `SemiUserGuideThemeMode?`、position `SemiTooltipPosition?`。

`SemiUserGuideButtonProps({child, onPressed})`：上游 `nextButtonProps`/`prevButtonProps`（ButtonProps）的局部展开——`children`/`onClick` 两槽（`onPressed` 顶替内置步进）；child `Object?`（String | Widget——String 走按钮文字色/字号通道，Widget 自带样式）。

`SemiUserGuideTarget({key, required id, required child})`：目标注册（★上游 DOM 元素引用无对应——anchor `SemiAnchorTarget` 先例）；重复 id 取首注册。

## 行为

### popup 聚光灯与卡片

`updateSpotlightRect`（index.tsx:224-273）：visible + popup 模式才度量（★hidden/unmounted 不再读取目标——scroll-ownership 测试口径）；目标矩形外扩 padding（x/y −p、w/h +2p）；新开档/current 变化时先 `scrollTargetIntoViewIfNeeded`（:187-216：目标整体在视口内不滚，否则 `scrollIntoView({ behavior: 'auto', block: 'center' })`）。蒙层 = SVG mask 挖洞（:437-459：`fill="white"` 显、`fill="black"` 圆角 4 洞）→ Path 差值涂 `var(--semi-color-overlay-bg)`（实时引用 `theme.colors.colorOverlayBg`）；四条透明捕获条（:461-488 `pointer-events: auto`）环绕洞口吞点击、洞口穿透（userGuide.scss:15/18）。★洞口矩形带 `transition: all 200ms cubic-bezier(0.4,0,0.2,1)` 补间（userGuide.scss:22）——捕获条/锚 div/卡片按未补间矩形即时落位（仅 `-spotlight-rect` 带 transition 类）。卡片 = popover 表面（bg-3 + shadow-elevated + radius-medium 借 popover/variables.scss 实时引用）+ `padding: 0` + width 400（`max-width: fit-content` hug-to-fit）；primary 主题卡底 `var(--semi-color-primary)` 覆色、正文色 `colorUserGuidePopupTextPrimary`。卡片经 SemiTooltip（popupBare + custom trigger）锚定 padded 矩形，`rePosKey = spotlightRect`、`showArrow = step.showArrow !== false`、间距 10/4（popover 常量）。

### popup 卡内容

cover（定高 `heightUserGuidePopupContentCoverDefault` 200 + `radiusUserGuidePopupContentCover` top 圆角 + `display: block`）→ body（padding `spacingUserGuidePopupContentBodyPadding` 24）→ title（18/w600/行高 24 + margin-bottom 8）→ description（14/行高 20 + margin-bottom 48）→ footer（space-between）：indicator `"N/M"`（仅 steps.length > 1；★字号直写 `font-size: $font-size-regular` 顶替死变量字段、行高 `fontUserGuidePopupContentIndicatorLineHeight`）+ 按钮组（gap 12 + `margin-left: 120`）。按钮：skip（showSkipButton && !末步）、prev（showPrevButton && !首步）、next（恒有；末步显 finishText）。default 主题：skip/prev = light tertiary、next = solid primary；primary 主题：skip/prev = solid primary + 底色 `var(--semi-color-fill-2)` 覆写、next = borderless primary + 底色 `'#FFF'` 覆写（★内联覆色恒定——压过 :hover/:active）。

### modal 卡

壳体走 SemiModal（feedback 先例）：`header={null}`/`footer={null}` 显式空槽（`SemiModalEmptySlot`——无 header 行、body 直通、无 closer、无 footer 节点）、`contentPadding: 0`（userGuide.scss:90 覆写）、width 600（★`$width-userGuide_modal_content_cover-default` 由 modal-content 消费——命名错位）、small + centered、maskClosable false。内容列：cover（定高 300）+ 指示点行（仅 cover 存在时出——`{cover && <>{cover}{indicator}</>}`；高 30、点 6×6 圆角 large、gap 8（★`popup_content_indicator-gap` 命名错位消费）、未选 `colorUserGuideModalContentIndicatorBg` / 选中 `colorUserGuideModalContentIndicatorBgActive`、不可点）→ body（仅 title/description 存在；column 居中、padding `24px 48px` 两值简写、title 18/w600/行高 24 + margin-bottom 8、description 14/行高 20）→ 按钮行（padding 24、居中、gap 12）：skip/prev = tertiary、next = solid（★theme 不消费——modal 按钮固定样式）。

### 值模型与步进

受控（current 非 null）：步进只发回调不改内部值（`getDerivedStateFromProps` 同步——index.tsx:141-147）；非受控自管。`handlePrev`（foundation.ts:56-65）：`newCurrent = current - 1`（★不 clamp）、受控判断后 setCurrent、`_notifyChange`、`onPrev`；`handleNext`（:58-78）：末步只 `onFinish`，否则 `_notifyChange`、`onNext`、受控判断后 setCurrent（★与 prev 相反的通知次序照录）；`handleSkip`（:80-82）仅 `onSkip`。开档（index.tsx:181-184）：`Boolean(visible && steps.length)` 翻真时 `setState({ current: 0 })`（受控由 derived 覆写 = `current ?? 0`）+ beforeShow。

## 主题（37 对账）

来源 packages/semi-foundation/userGuide/variables.scss（35 声明行 / 35 唯一名——font 12、spacing 10、color 4、height 4、width 3、radius 2）+ packages/semi-foundation/userGuide/animation.scss（2 声明行——**活文件**：userGuide.scss:2 `@import "./animation.scss"` + :22 消费，200ms/cubic-bezier(0.4,0,0.2,1)）。对账 **37 = 35 FIELDS + 2 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表；`$module: #{$prefix}-userGuide` 类名胶水不计）。其中 **1 条死 FIELDS**（死变量留档不消费：落 theme + `# dead variable (上游未消费)` + 本表「（上游未消费）」+ widget assertNotIn）：`$font-userGuide_popup_content_indicator-fontSize`（userGuide.scss:77 直写 `font-size: $font-size-regular` 顶替——全仓零消费；★widget 按 HARDCODE 实消费字号但**不得**引用该字段名）。全局 token 解析：`var(--semi-color-text-0)` → `theme.colors.colorText0`、`var(--semi-color-tertiary-light-default)` → `theme.colors.colorTertiaryLightDefault`、`var(--semi-color-primary-light-active)` → `theme.colors.colorPrimaryLightActive`、`var(--semi-color-primary)` → `theme.colors.colorPrimary`、`var(--semi-border-radius-medium)` → `theme.radius.borderRadiusMedium.value`、`var(--semi-border-radius-large)` → `theme.radius.borderRadiusLarge.value`；引用 token：`$font-size-header-5` → 18、`$font-size-regular` → 14、`$font-weight-bold` → 600（FontWeight → `theme.typography.fontWeightBold` == FontWeight.w600，generate_tag.py:31 先例）；多值默认：`24px 48px` → `const EdgeInsets.symmetric(vertical: 24, horizontal: 48)`（**生成域首例 EdgeInsets**）、`var(--semi-border-radius-medium) var(--semi-border-radius-medium) 0 0` → `BorderRadius.vertical(top: Radius.circular(theme.radius.borderRadiusMedium.value))`（generate_modal.py 四值圆角先例）；motion 对照 generate_collapsible.py：`200ms` → `const Duration(milliseconds: 200)`、`cubic-bezier(0.4, 0, 0.2, 1)` → `const Cubic(0.4, 0, 0.2, 1)`（Curve 值相等走 semiCurveEquals/semiCurveHash helper；FontWeight/EdgeInsets/BorderRadius 自带值相等——generate_breadcrumb.py 先例）。★provenance 拼写/错位 quirk 照抄：variables.scss:30 注释 `// 弹窗式片指示器间距`（缺「卡」字）、:36 注释 `// 气泡卡片指示器圆角` 挂在 modal 变量上（错位）、:45 注释 `// 弹窗式卡详情字体大小`（缺「片」字）。解析列即 `SemiUserGuideThemeData.resolve` 默认表达式。类型覆盖：**4 Color + 27 double + 2 FontWeight + 1 EdgeInsets + 1 BorderRadius + 1 Duration + 1 Curve = 37**。

### A. Sass 声明映射（35 FIELDS + 2 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-userGuide_popup-text-default: var(--semi-color-text-0)` | `colorUserGuidePopupTextDefault` | `theme.colors.colorText0`（popup 卡正文色） |
| `$color-userGuide_popup-text-primary: var(--semi-color-tertiary-light-default)` | `colorUserGuidePopupTextPrimary` | `theme.colors.colorTertiaryLightDefault`（primary 主题正文色） |
| `$color-userGuide_modal_content_indicator-bg: var(--semi-color-primary-light-active)` | `colorUserGuideModalContentIndicatorBg` | `theme.colors.colorPrimaryLightActive`（modal 指示点未选色） |
| `$color-userGuide_modal_content_indicator-bg-active: var(--semi-color-primary)` | `colorUserGuideModalContentIndicatorBgActive` | `theme.colors.colorPrimary`（modal 指示点选中色） |
| `$width-userGuide_popover-default: 400px` | `widthUserGuidePopoverDefault` | `400`（popup 卡宽 + `max-width: fit-content`） |
| `$height-userGuide_popup_content_cover-default: 200px` | `heightUserGuidePopupContentCoverDefault` | `200`（popup 封面高） |
| `$width-userGuide_modal_content_cover-default: 600px` | `widthUserGuideModalContentCoverDefault` | `600`（★命名错位——userGuide.scss:91 由 modal-content 宽消费） |
| `$height-userGuide_modal_content_cover-default: 300px` | `heightUserGuideModalContentCoverDefault` | `300`（modal 封面高） |
| `$height-userGuide_modal_content_indicator-default: 30px` | `heightUserGuideModalContentIndicatorDefault` | `30`（modal 指示点行高） |
| `$width-userGuide_modal_content_indicator_item-default: 6px` | `widthUserGuideModalContentIndicatorItemDefault` | `6`（指示点宽） |
| `$height-userGuide_modal_content_indicator_item-default: 6px` | `heightUserGuideModalContentIndicatorItemDefault` | `6`（指示点高） |
| `$font-userGuide_popup_content_title-lineHeight: 24px` | `fontUserGuidePopupContentTitleLineHeight` | `24`（popup title 行高；`TextStyle.height = 行高/字号`） |
| `$font-userGuide_popup_content_description-lineHeight: 20px` | `fontUserGuidePopupContentDescriptionLineHeight` | `20`（popup description 行高） |
| `$font-userGuide_popup_content_indicator-lineHeight: 20px` | `fontUserGuidePopupContentIndicatorLineHeight` | `20`（popup 指示器行高） |
| `$font-userGuide_modal_content_title-lineHeight: 24px` | `fontUserGuideModalContentTitleLineHeight` | `24`（modal title 行高） |
| `$font-userGuide_modal_content_description-lineHeight: 20px` | `fontUserGuideModalContentDescriptionLineHeight` | `20`（modal description 行高） |
| `$spacing-userGuide_popup_content_body-padding: 24px` | `spacingUserGuidePopupContentBodyPadding` | `24`（popup body 内边距） |
| `$spacing-userGuide_popup_content_title-marginBottom: 8px` | `spacingUserGuidePopupContentTitleMarginBottom` | `8`（popup title 底距） |
| `$spacing-userGuide_popup_content_description-marginBottom: 48px` | `spacingUserGuidePopupContentDescriptionMarginBottom` | `48`（popup description 底距） |
| `$spacing-userGuide_popup_content_button-gap: 12px` | `spacingUserGuidePopupContentButtonGap` | `12`（popup 按钮间距） |
| `$spacing-userGuide_popup_content_button-marginLeft: 120px` | `spacingUserGuidePopupContentButtonMarginLeft` | `120`（popup 按钮组左距） |
| `$spacing-userGuide_modal_content_title-marginBottom: 8px` | `spacingUserGuideModalContentTitleMarginBottom` | `8`（modal title 底距） |
| `$spacing-userGuide_modal_content_body-padding: 24px 48px` | `spacingUserGuideModalContentBodyPadding` | `const EdgeInsets.symmetric(vertical: 24, horizontal: 48)`（★生成域首例 EdgeInsets——两值 padding 简写） |
| `$spacing-userGuide_modal_content_footer-padding: 24px` | `spacingUserGuideModalContentFooterPadding` | `24`（modal 按钮行内边距） |
| `$spacing-userGuide_popup_content_indicator-gap: 8px` | `spacingUserGuidePopupContentIndicatorGap` | `8`（★命名错位——userGuide.scss:104 由 **modal** 指示点 column-gap 消费；★注释缺字 `// 弹窗式片指示器间距` 照抄） |
| `$spacing-userGuide_modal_content_button-gap: 12px` | `spacingUserGuideModalContentButtonGap` | `12`（modal 按钮间距） |
| `$radius-userGuide_popup_content_cover: var(--semi-border-radius-medium) var(--semi-border-radius-medium) 0 0` | `radiusUserGuidePopupContentCover` | `BorderRadius.vertical(top: Radius.circular(theme.radius.borderRadiusMedium.value))`（★四值圆角简写） |
| `$radius-userGuide_modal_content_indicator: var(--semi-border-radius-large)` | `radiusUserGuideModalContentIndicator` | `theme.radius.borderRadiusLarge.value`（指示点圆角；★注释错位 `// 气泡卡片指示器圆角` 照抄） |
| `$font-userGuide_popup_content_title-fontSize: $font-size-header-5` | `fontUserGuidePopupContentTitleFontSize` | `18`（popup title 字号） |
| `$font-userGuide_popup_content_description-fontSize: $font-size-regular` | `fontUserGuidePopupContentDescriptionFontSize` | `14`（popup description 字号） |
| `$font-userGuide_popup_content_indicator-fontSize: $font-size-regular` | `fontUserGuidePopupContentIndicatorFontSize` | `14`（上游未消费）——死变量留档：userGuide.scss:77 直写 `font-size: $font-size-regular` 顶替（全仓零消费）；★widget 按 HARDCODE 实消费字号但不得引用该字段名 |
| `$font-userGuide_popup_content_title-fontWeight: $font-weight-bold` | `fontUserGuidePopupContentTitleFontWeight` | `theme.typography.fontWeightBold`（popup title 字重 w600） |
| `$font-userGuide_modal_content_title-fontSize: $font-size-header-5` | `fontUserGuideModalContentTitleFontSize` | `18`（modal title 字号） |
| `$font-userGuide_modal_content_description-fontSize: $font-size-regular` | `fontUserGuideModalContentDescriptionFontSize` | `14`（modal description 字号；★注释缺字 `// 弹窗式卡详情字体大小` 照抄） |
| `$font-userGuide_modal_content_title-fontWeight: $font-weight-bold` | `fontUserGuideModalContentTitleFontWeight` | `theme.typography.fontWeightBold`（modal title 字重 w600） |
| `$transition_duration-userGuide_spotLight: 200ms` | `transitionDurationUserGuideSpotLight` | `const Duration(milliseconds: 200)`（活字段——userGuide.scss:2 `@import` + :22 消费；洞口补间时长） |
| `$transition_function-userGuide_spotLight: cubic-bezier(0.4, 0, 0.2, 1)` | `transitionFunctionUserGuideSpotLight` | `const Cubic(0.4, 0, 0.2, 1)`（活字段；TweenAnimationBuilder curve） |

### B. HARDCODES 另列（`_UserGuideMetrics` / 调用点，widget 源内含原始片段）

| 上游片段 | 落点 |
|---|---|
| `rx={4}` | 聚光灯洞口圆角（index.tsx:446 → `_SpotlightMaskPainter.holeRadius`） |
| `fill="var(--semi-color-overlay-bg)"` | 蒙层填色（index.tsx:457 → 实时引用 `theme.colors.colorOverlayBg`，generate_cropper.py 先例） |
| `fill="white"` / `fill="black"` | SVG mask 白显黑挖机制（index.tsx:439/:447 → Path.combine difference） |
| `pointer-events: none` | svg 根不接指针（userGuide.scss:15 → 洞口穿透） |
| `pointer-events: auto` | 透明捕获条吞点击（userGuide.scss:18 → Listener opaque） |
| `transition: all $transition_duration-userGuide_spotLight $transition_function-userGuide_spotLight` | MOTION 消费行（userGuide.scss:22 → TweenAnimationBuilder 洞口补间） |
| `max-width: fit-content` | popover 卡宽上限（userGuide.scss:27 → ConstrainedBox + IntrinsicWidth） |
| `width: fit-content` | `.semi-modal-small` 覆写（userGuide.scss:85 → 壳宽由 SemiModal.width 承担，差异清单注明收窄不复现） |
| `display: block` | 封面 img 块级（userGuide.scss:40 → 定高盒） |
| `padding: 0` | basePopoverStyle（index.tsx:350）+ bodyStyle（:529）+ `.semi-modal-content` 覆写（userGuide.scss:90 → contentPadding 槽） |
| `font-size: $font-size-regular` | popup 指示器字号（userGuide.scss:77 → `_UserGuideMetrics.fontSizeRegular`；顶替死变量） |
| `backgroundColor: 'var(--semi-color-primary)'` | primary 卡底（index.tsx:355 → 实时引用 `theme.colors.colorPrimary`） |
| `backgroundColor: 'var(--semi-color-fill-2)'` | primary 主题 skip/prev 底（index.tsx:301/:311 → 实时引用 `theme.colors.colorFill2` + SemiButtonTheme 三态覆写） |
| `backgroundColor: '#FFF'` | primary 主题 next 底（index.tsx:321 → DecoratedBox 白盒底衬 + borderless hover/active 覆白） |
| `showArrow={step.showArrow !== false}` | 箭头缺省开（index.tsx:370） |
| `zIndex: zIndex - 1` | 蒙层在卡之下（index.tsx:397/:436 → overlay 插入序承担） |
| `SPACING: 4` / `SPACING_WITH_ARROW: 10` | 锚-卡间距（popover/constants.ts:42-43 → SemiTooltip.spacing 槽） |
| `offsetY: 6` | popover 族箭头校正（popover/constants.ts:36-39 `ARROW_BOUNDING` → arrowBoundingOffsetY） |
| `DEFAULT_CURRENT: 0` | current 缺省/开档归零（constants.ts:30） |
| `DEFAULT_SPOTLIGHT_PADDING: 5` | 聚光灯内边距缺省（constants.ts:31） |
| `DEFAULT_Z_INDEX: 1030` | zIndex 缺省（constants.ts:32） |
| `getFinalPaading` | ★foundation.ts:47 方法名拼写 quirk（`Paading` 多一个 a——原文留档，调用点 `_finalPadding`） |

## 差异清单

★照搬留档（quirk 原样）：
1. **`getFinalPaading` 拼写 quirk**：foundation.ts:47 方法名 `Paading` 照抄留档（调用点 `_finalPadding`）。
2. **handlePrev 不 clamp**：`newCurrent = current - 1` 可为负（foundation.ts:56-65；prev 按钮首步隐藏使 UI 不可达——越界渲染见偏差）。
3. **prev/next 通知次序相反（React setState 异步 quirk）**：handlePrev 是 setCurrent→notify（:56-65）、handleNext 是 notify→setCurrent（:58-78）——React setState 异步下 `_notifyChange` 两者均观察旧值（「值变化才发」恒真）。★Flutter setState 同步执行：本移植把 handlePrev 也改为先 notify 后 setState（否则 set 后 `_current == newCurrent` 会吞掉 onChange）——外部回调序 onChange→onPrev/onChange→onNext 与语义均不变。
4. **handleNext 末步只发 onFinish**：不发 onChange/onNext、不推进（:68-70）。
5. **handleSkip 仅通知**：不关显隐（visible 受控在使用方，:80-82）。
6. **onChange 仅值变化时发**：`_notifyChange` 值等即静默（:23-28）。
7. **开档归零不发回调**：`Boolean(visible && steps.length)` 翻真时 `setState({ current: 0 })`（受控由 derived 覆写；index.tsx:181-184）。
8. **zero-padding 照消费**：`step.spotlightPadding: 0` 不回落默认 5（`typeof stepPadding === 'number'` 口径，foundation.ts:47-55；zero-padding 测试）。
9. **步蒙层优先**：`step.mask ?? mask` 对 popup 蒙层/捕获条与 modal mask 同口径（index.tsx:440/:543；step-options 测试）。
10. **showArrow 缺省开**：`showArrow={step.showArrow !== false}`（index.tsx:370）。
11. **popup 无 target 步整棵不出**：renderStep/renderSpotlight `if (!step.target) return null`（:344/:427）；旧矩形留 state 但不出图。
12. **指示器条件渲染**：popup `"N/M"` 仅 steps.length > 1（:294）；modal 指示点仅 cover 存在时出（`{cover && <>{cover}{indicator}</>}`，:552-567）。
13. **modal 不消费 theme**：renderModal 按钮固定样式（skip/prev tertiary、next solid）、无 primary 分支（:569-585）。
14. **modal 指示点不可点**：renderIndicator 无 onClick（:488-500）。
15. **蒙层捕获条吞点击/洞口穿透**：四条 `pointer-events: auto` + 根 `pointer-events: none`（userGuide.scss:15/18 + index.tsx:461-488）。
16. **洞口补间、余者即时**：仅 `-spotlight-rect` 带 `transition: all 200ms`（userGuide.scss:22）——捕获条/锚 div/卡片按未补间矩形落位。★补间以 `Rect.lerp` 承担（`_RectTween`）——泛型 `Tween<Rect>` 以 `Rect ± Rect` 算术求值、矩形一变每帧抛 "Cannot lerp between Rect..."；SDK `RectTween` 是 `Tween<Rect?>` 不可赋 `TweenAnimationBuilder<Rect>`。
17. **按钮内联覆色恒定**：`backgroundColor` 内联压过 :hover/:active（fill-2/#FFF 各态不变）——SemiButtonTheme 三态覆写/白盒底衬承担。
18. **prevButtonProps/nextButtonProps 的 onClick 顶替**：`{...prevButtonProps}` 在 onClick 之后展开（index.tsx:307/:317）→ `onPressed` 顶替内置步进。
19. **命名错位/注释错字 quirk 照抄**：`$spacing-userGuide_popup_content_indicator-gap` 由 modal 指示点消费（userGuide.scss:104）；variables.scss:30 `// 弹窗式片指示器间距`（缺字）、:36 `// 气泡卡片指示器圆角`（错位）、:45 `// 弹窗式卡详情字体大小`（缺字）原文进 PROVENANCE_NOTES。
20. **死变量**：`$font-userGuide_popup_content_indicator-fontSize` 全仓零消费（userGuide.scss:77 直写 `$font-size-regular` 顶替）——留档不消费。

偏差/裁剪：
21. **target → SemiUserGuideTarget 注册**：上游 `target?: (() => Element) | Element` DOM 引用无 Flutter 对应 → `SemiUserGuideTarget(id, child)` 显式注册 + `target: String`（anchor 先例）；getter 形态「hidden/unmounted 不再读取」契约（scroll-ownership 测试）落为可见性门控度量（hidden 时不查注册表/不度量）。
22. **getPopupContainer 裁剪**：无 portal 容器选择（popover/select 先例）——蒙层与卡片统一入根 Overlay，蒙层条目先插（卡之上/下的 `zIndex: zIndex - 1` 语义以插入序承担）；ConfigProvider 容器同步裁剪。
23. **body scroll lock 裁剪**：`document.body.style.overflow` 锁（index.tsx:118-136 disabledBodyScroll/enabledBodyScroll + scrollbar 宽补偿）无 Flutter 对应——empty-steps/scroll-ownership 的锁语义不复现；宿主可自行监听 `visible` 锁滚动。
24. **syncSpotlightOrigin 不适用**：fixed 含块偏移补偿（index.tsx:408-422，transformed ancestor）——本移植 overlay 直接视口坐标落位。
25. **触发面对应**：window `resize`（:152）→ `didChangeMetrics`、window `scroll` capture（:153）→ 目标全部祖先 ScrollPosition 监听、rerender（:190）→ didUpdateWidget/didChangeDependencies——逐事件重测同口径。
26. **scrollIntoViewIfNeeded → ensureVisible**：`scrollIntoView({ behavior: 'auto', block: 'center' })` → `Scrollable.ensureVisible(alignment: 0.5)`（仅最近滚动容器——多层嵌套滚动不逐层保证 centered；behavior auto = 无动画）。
27. **ButtonProps 局部展开**：`nextButtonProps`/`prevButtonProps` 完整 ButtonProps（type/theme/style 等任意覆写）不移植 → `SemiUserGuideButtonProps(child, onPressed)` 两槽（child `Object?`：String | Widget）。★按钮文案一律走 String 通道取按钮文字色/字号（SemiButton 仅对 String child 套按钮样式、Widget child 原样透传——上游按钮 CSS `color` 对 children 为继承语义，此处以 String 通道承担；Widget child 自带样式不继承按钮色）。
28. **skipText/prevText/nextText 参数新增**：上游 locale skip/prev/next 无 Flutter locale 对应（popconfirm `okText` 先例）；缺省中文文案照 zh_CN.ts:197-202。
29. **current 非 null 即受控**：上游 `_isInProps('current')` 的显式 `current: null` 受控无对应（treeSelect 先例）。
30. **越界 current 防御**：上游 `steps[current]` 越界 TypeError（renderSpotlight/renderModal 解构 undefined）→ 本移植跳过渲染。
31. **modal 盒宽定 600**：`max-width: fit-content` 短内容收窄不复现（SemiModal.width 定宽槽）；`width: fit-content`（modal-small 覆写）同由壳宽承担。
32. **modal 壳体复用 SemiModal + 增量扩展**：`SemiModalEmptySlot`（`header={null}`/`footer={null}` 显式空槽——JS `'x' in props` 语义）+ `contentPadding`（userGuide.scss:90 `padding: 0` 覆写）为本移植给 semi_modal.dart 的只加不改增量。
33. **卡宽 fit-content → ConstrainedBox + IntrinsicWidth**：`width: 400px; max-width: fit-content`（hug-to-fit）以 IntrinsicWidth max-content 语义近似。
34. **封面圆角落包装**：popup 封面 `img` 本体圆角（userGuide.scss:42）→ ClipRRect 包装近似。
35. **className/style/getDataAttr 裁剪**：Flutter 无 CSS 类（anchor 先例）。
36. **zIndex parity**：插入序层叠（SemiPopover.zIndex 同口径）。
37. **rePosKey → repositionKey**：`JSON.stringify(spotlightRect)` → Rect 值比较触发重定位（等价）。
38. **锚 div 矩形取 state**：上游 renderStep 每渲染即时取 `target.getBoundingClientRect()` 外扩 padding → 统一用 state spotlightRect（稳态等价；瞬态差一帧）。
39. **inset 阴影层由专用画师渲染**：Flutter 无 CSS inset box-shadow 对应物——drop 层进 BoxDecoration（`toDropBoxShadows()`）、inset 层（dark `--semi-shadow-elevated` 首层 `inset 0 0 0 1px`）由 `SemiInsetShadow` 画师精确绘制（贴 padding-box 的内环、零布局影响）；`toBoxShadows()` 对 inset 抛错的显式合同保留，带 blur/offset 的 inset 层构造即抛。

## 用法

```dart
SemiUserGuide(
  visible: _visible,
  mode: SemiUserGuideMode.popup,
  steps: const [
    SemiUserGuideStep(
      target: 'step1',
      title: '第一步',
      description: '这是第一步的说明',
      position: SemiTooltipPosition.bottom,
    ),
    SemiUserGuideStep(
      target: 'step2',
      title: '第二步',
      description: '这是第二步的说明',
      spotlightPadding: 0, // ★0 照消费
    ),
  ],
  onFinish: () => setState(() => _visible = false),
  onSkip: () => setState(() => _visible = false),
  onChange: (current) {},
)

// 目标注册（popup 模式按 target id 对齐）
Column(children: const [
  SemiUserGuideTarget(id: 'step1', child: Text('第一步目标')),
  SemiUserGuideTarget(id: 'step2', child: Text('第二步目标')),
])
```
