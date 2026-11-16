# SemiFloatButton

悬浮按钮（上游 Semi FloatButton 全件移植）：固定在视口角落的可点按钮（index.tsx:49-75），默认右下角（floatButton.scss:8-10 `position: fixed` + `bottom`/`right` 主题间距），支持 shape（round/square）、size（small/default/large）、colorful（AI 多彩）、disabled、badge（徽章骑圆角）与点击回传（index.tsx:27-47 `handleClick`：disabled 即断，`onClick(e)` 回传；★href 跳转不移植——href/target 仅元数据）。另有悬浮按钮组 `SemiFloatButtonGroup`（floatButtonGroup.tsx）：容器内横排图标+文字子项（floatButton.scss:124-157 inline-flex + gap），子项点击先走 `handleItemClick`（:53-66）再冒泡组回调 `onClick(value, e)`（:41-51 委托读 `data-value`），子项回调可 `stopPropagation()` 断组（itemProps.test.jsx 口径）。定位：上游 `position: fixed` → 本移植为宿主 Stack 直接子节点 `PositionedDirectional`（见差异清单）。主题对账 **39 = 39 FIELDS + 0 MOTION + 0 INTERNAL**（39 = variables.scss 全部声明——spacing 9、width 3、color 16、z 2、radius 4、font 3、shadow 2；本模块无 animation.scss；`$module: #{$prefix}-floatButton` / `$moduleGroup` 类名胶水不计，backtop `3 = 3 + 0 + 0`、badge `37 = 37 + 0 + 0` 先例）。

## API

`SemiFloatButton({shape: SemiFloatButtonShape.round, size: SemiFloatButtonSize.defaultSize, colorful: false, disabled: false, icon, badge, onClick, href, target, semanticsLabel})`。

shape `SemiFloatButtonShape`（square/round，缺省 round——index.tsx:18 `shape: 'round'`）。size `SemiFloatButtonSize`（small/defaultSize/large，缺省 defaultSize ↔ 上游 `'default'`，anchor `defaultSize` 先例；index.tsx:20）。colorful `bool`（多彩，缺省 false——index.tsx:19）。disabled `bool`（禁用：断点击 + 禁用配色 + `cursor: not-allowed`）。icon `Widget?`（上游 `icon: ReactNode`，经 DefaultTextStyle 注入状态文字色）。badge `SemiFloatButtonBadge?`（徽章参数，上游 `badge: BadgeProps`；★`position` 未移植——badge 被钉在圆角对角线点）。onClick `VoidCallback?`（点击回传；上游 `(e: MouseEvent) => void`——e 无对应）。href/target `String?`（★元数据——Flutter 不导航，照 breadcrumb 口径应用自理）。semanticsLabel `String?`（★上游无 aria-label——本移植补 Semantics button，见差异清单）。

`SemiFloatButtonGroup({items, disabled: false, onClick, semanticsLabel})`。items `List<SemiFloatButtonGroupItem>`（子项）。disabled `bool`（★仅断回调、无视觉差）。onClick `void Function(String? value, SemiFloatButtonGroupClickEvent event)?`（组点击回传，上游 `(value: string, e: MouseEvent)`；`value` 无值即 null——`item.dataset.value` 口径；事件即子项派发的同一实例）。semanticsLabel `String?`（补 Semantics）。

`SemiFloatButtonGroupItem({value, content, icon, badge, disabled: false, href, target, onClick})`。value `String?`（标识，组回调回传）。content `Object?`（String 或 Widget，上游 `string | ReactNode`）。icon `Widget?`。badge `SemiFloatButtonBadge?`（★组内 badge 走标准 Badge 四角锚定）。disabled `bool`（仅断回调）。href/target `String?`（元数据）。onClick `void Function(SemiFloatButtonGroupClickEvent event)?`（子项点击；事件内 `stopPropagation()` 断组回调）。

`SemiFloatButtonBadge({count, dot: false, type: SemiBadgeType.primary, variant: SemiBadgeVariant.solid, overflowCount})`——`BadgeProps` 的视觉字段子集（count num/String/Widget、dot、type、theme→variant、overflowCount）；`position` 未移植（见差异清单）。

`SemiFloatButtonGroupClickEvent{propagationStopped, stopPropagation()}`——组派发事件（MouseEvent 的 stopPropagation 对应物；同步可取消，派发完成后封印，SemiCheckboxChangeEvent 惯例）。

## 行为

### 点击与禁用

点击 → index.tsx:27-47 `handleClick`：`if (disabled) { return; }`（:30）断路 → href 跳转（:35-41 `window.open(href, '_blank')` / `window.location.href = href`，★不移植）→ `onClick(e)` 回传。disabled 光标 `cursor: not-allowed`（floatButton.scss:34 → SystemMouseCursors.forbidden），非禁用 `cursor: pointer`（:12 → click）。★键盘补强（统一交互约定）：上游静态 div 无键盘激活（index.tsx:63 jsx-a11y 禁用注释）→ 本移植 Focus + Enter。

### 状态配色（hover/active/disabled/colorful）

body 配色四态（floatButton.scss:14-53）：缺省 `$color-floatButton-bg`（:15）+ 字色 `$color-floatButton-text`（:17）；hover `$color-floatButton-bg-hover`（:22-24）、active `$color-floatButton-bg-active`（:26-28）；disabled `$color-floatButton-disabled-bg/-text`（:31-33）；colorful `$color-floatButton-colorful-*`（:41-53，渐变 bg + 白字）。★类级联 quirk：`-disabled`（:31）在 `-colorful`（:41）之前、同特异性后者胜——colorful + disabled 时多彩视觉（含 hover/active 渐变）胜出，仅 `cursor: not-allowed` 残留（照搬留档）。多彩 bg 为渐变 token（`var(--semi-color-ai-general)` → `SemiGradient`，button colorful 先例）——body 为固定 width×width 盒，按已知边长 `forSize` 预解析。

### 徽章骑圆角

badge 包裹 body（index.tsx:72 `<Badge {...badge}>{body}</Badge>`），且被 floatButton.scss:55-113 挪位八条钉在圆角对角线上（`top: calc(0.29 * R)` / `inset-inline-end: calc(0.29 * R)`，`(√2 - 1)/√2 * R = 0.29 * R`）：方形 R = `$radius-floatButton_square`（:64-65，与尺寸无关）、圆形 R = 0.5 × 边长（:82-83/:96-97/:109-110 按 size）。本移植 `PositionedDirectional(top: inset, end: inset) + FractionalTranslation` 复刻（badge 默认角 translate 同款；RTL 翻 -0.5）。组子项 badge 不挪位（标准 Badge 四角锚定）。

### 悬浮按钮组（子项派发）

组容器（floatButton.scss:124-134）：`display: inline-flex` + `padding: $spacing-floatButton_group-padding` + `gap: $spacing-floatButton_group-columnGap`，子项行（:136-156）：`padding: $spacing-floatButton_group_item-paddingY/X` + `column-gap: $spacing-floatButton_group_item-columnGap` + `border-radius` + 文字样式四件（color/fontSize/fontWeight/lineHeight，:143-147）+ hover/active 底色（:149-155）。点击派发（floatButtonGroup.tsx:41-66）：★容器 DOM 委托（:45 `e.target.closest` + :49 `item.dataset.value`）不移植——逐项 GestureDetector 直调 `_dispatch`；disabled 组/子项断路（:54-57 `e.stopPropagation()`——子项与组回调均不达）；子项回调先于组回调（itemProps.test.jsx `['item', 'group']`），回调内 `stopPropagation()` 断组（`respects stopPropagation`）；子项 href 跳转先于 `item.onClick`（:57-64，★不移植）。

### 定位与 RTL

`position: fixed` + `bottom`/`right`（floatButton.scss:8-10 / :125-128）→ 宿主 Stack 直接子节点 `PositionedDirectional(end: spacingFloatButtonRight/GroupRight, bottom: spacingFloatButtonBottom/GroupBottom)`（★需 Stack 直接子节点位——组件包装不影响、render-object 包装断 ParentData，backtop 先例）。`z-index: $z-floatButton` / `$z-floatButton_group`（:11/:129）→ ★无 Flutter 槽，叠放由宿主 Stack 子序决定（字段注释引用，见主题表）。RTL：rtl.scss 为空，`inset-inline-end`/PositionedDirectional 自然翻边。

## 主题（39 对账）

来源 packages/semi-foundation/floatButton/variables.scss（39 声明行 / 39 唯一名——spacing 9、width 3、color 16、z 2、radius 4、font 3、shadow 2；无 animation.scss）。对账 **39 = 39 FIELDS + 0 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表；类名胶水不计）。2 条死变量（上游零消费——group 无 `-disabled` 样式规则，死变量留档不消费，widget 不得读）+ 2 条 z 字段留档不消费（CSS z-index 无 Flutter 槽——widget 注释引用）。`var(--semi-color-ai-general*)` 为渐变 token → `SemiGradient`（button 先例）；`var(--semi-shadow-elevated)` → `SemiShadows`（card 先例）；`var(--semi-border-radius-full)` → `theme.radius.borderRadiusFull.value`（= 9999）。解析列即 `SemiFloatButtonThemeData.resolve` 默认表达式。类型覆盖：**13 Color + 3 SemiGradient + 2 SemiShadows + 1 FontWeight + 18 double + 2 int**。

### A. Sass 声明映射（39 FIELDS）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$spacing-floatButton-bottom: 24px` | `spacingFloatButtonBottom` | `24`（距底侧距离） |
| `$spacing-floatButton-right: 24px` | `spacingFloatButtonRight` | `24`（距右侧距离；RTL 自动翻边） |
| `$spacing-floatButton_group-bottom: 24px` | `spacingFloatButtonGroupBottom` | `24`（组距底侧距离） |
| `$spacing-floatButton_group-right: 24px` | `spacingFloatButtonGroupRight` | `24`（组距右侧距离） |
| `$spacing-floatButton_group-padding: 6px` | `spacingFloatButtonGroupPadding` | `6`（组内边距） |
| `$spacing-floatButton_group-columnGap: 4px` | `spacingFloatButtonGroupColumnGap` | `4`（子项水平间距——`gap`） |
| `$spacing-floatButton_group_item-paddingX: 12px` | `spacingFloatButtonGroupItemPaddingX` | `12`（子项水平内边距） |
| `$spacing-floatButton_group_item-paddingY: 6px` | `spacingFloatButtonGroupItemPaddingY` | `6`（子项垂直内边距） |
| `$spacing-floatButton_group_item-columnGap: 8px` | `spacingFloatButtonGroupItemColumnGap` | `8`（子项内容水平间距） |
| `$width-floatButton_small: 24px` | `widthFloatButtonSmall` | `24`（small 边长；兼作圆形 badge R = 0.5×24） |
| `$width-floatButton: 32px` | `widthFloatButton` | `32`（defaultSize 边长） |
| `$width-floatButton_large: 40px` | `widthFloatButtonLarge` | `40`（large 边长） |
| `$color-floatButton-bg:  var(--semi-color-fill-0)` | `colorFloatButtonBg` | `theme.colors.colorFill0`（背景色） |
| `$color-floatButton-text:  var(--semi-color-primary)` | `colorFloatButtonText` | `theme.colors.colorPrimary`（文字/图标色） |
| `$color-floatButton-bg-hover:  var(--semi-color-fill-1)` | `colorFloatButtonBgHover` | `theme.colors.colorFill1`（悬浮态） |
| `$color-floatButton-bg-active:  var(--semi-color-fill-2)` | `colorFloatButtonBgActive` | `theme.colors.colorFill2`（按下态） |
| `$color-floatButton-disabled-bg:  var(--semi-color-disabled-bg)` | `colorFloatButtonDisabledBg` | `theme.colors.colorDisabledBg`（禁用态） |
| `$color-floatButton-disabled-text:  var(--semi-color-disabled-text)` | `colorFloatButtonDisabledText` | `theme.colors.colorDisabledText`（禁用字色） |
| `$color-floatButton-colorful-bg:  var(--semi-color-ai-general)` | `colorFloatButtonColorfulBg` | `theme.colors.colorAiGeneral`（★渐变 token → SemiGradient） |
| `$color-floatButton-colorful-text:  var(--semi-color-white)` | `colorFloatButtonColorfulText` | `theme.colors.colorWhite`（多彩字色） |
| `$color-floatButton-colorful-bg-hover:  var(--semi-color-ai-general-hover)` | `colorFloatButtonColorfulBgHover` | `theme.colors.colorAiGeneralHover`（渐变） |
| `$color-floatButton-colorful-bg-active:  var(--semi-color-ai-general-active)` | `colorFloatButtonColorfulBgActive` | `theme.colors.colorAiGeneralActive`（渐变） |
| `$color-floatButton_group-bg:  var(--semi-color-bg-0)` | `colorFloatButtonGroupBg` | `theme.colors.colorBg0`（组背景色） |
| `$color-floatButton_group_item-text:  var(--semi-color-text-0)` | `colorFloatButtonGroupItemText` | `theme.colors.colorText0`（子项文字色） |
| `$color-floatButton_group_item-bg-hover:  var(--semi-color-fill-1)` | `colorFloatButtonGroupItemBgHover` | `theme.colors.colorFill1`（子项悬浮态） |
| `$color-floatButton_group_item-bg-active:  var(--semi-color-fill-2)` | `colorFloatButtonGroupItemBgActive` | `theme.colors.colorFill2`（子项按下态） |
| `$color-floatButton_group-disabled-bg:  var(--semi-color-disabled-bg)` | `colorFloatButtonGroupDisabledBg` | （上游未消费）死变量留档不消费——group 无 `-disabled` 样式规则，禁用仅断回调 |
| `$color-floatButton_group-disabled-text:  var(--semi-color-disabled-text)` | `colorFloatButtonGroupDisabledText` | （上游未消费）死变量留档不消费——同上 |
| `$z-floatButton: 1000` | `zFloatButton` | `1000`（留档不消费——★无 Flutter z-index 槽，叠放由宿主 Stack 子序决定；widget 注释引用） |
| `$z-floatButton_group: 1000` | `zFloatButtonGroup` | `1000`（留档不消费——同上） |
| `$radius-floatButton_square: 8px` | `radiusFloatButtonSquare` | `8`（方形圆角；兼作方形 badge R） |
| `$radius-floatButton_round: var(--semi-border-radius-full)` | `radiusFloatButtonRound` | `theme.radius.borderRadiusFull.value`（= 9999，全圆） |
| `$radius-floatButton_group-border-radius: 8px` | `radiusFloatButtonGroupBorderRadius` | `8`（组圆角） |
| `$radius-floatButton_group_item-border-radius: 4px` | `radiusFloatButtonGroupItemBorderRadius` | `4`（子项圆角） |
| `$font-floatButton_group_item-fontWeight: 400` | `fontFloatButtonGroupItemFontWeight` | `FontWeight.w400`（子项字重） |
| `$font-floatButton_group_item-lineHeight: 20px` | `fontFloatButtonGroupItemLineHeight` | `20`（子项行高） |
| `$font-floatButton_group_item-fontSize: 14px` | `fontFloatButtonGroupItemFontSize` | `14`（子项字号） |
| `$shadow-floatButton_group: var(--semi-shadow-elevated)` | `shadowFloatButtonGroup` | `theme.shadows.shadowElevated`（SemiShadows——`toBoxShadows()`） |
| `$shadow-floatButton: var(--semi-shadow-elevated)` | `shadowFloatButton` | `theme.shadows.shadowElevated`（同上） |

### B. HARDCODES 另列（`_FloatButtonMetrics` / 调用点，widget 源内含原始片段）

| 上游片段 | 落点 |
|---|---|
| `SHAPE: ['square', 'round']` | 形状枚举（constants.ts:16 → `SemiFloatButtonShape`） |
| `SIZE: ['small', 'default', 'large']` | 尺寸枚举（constants.ts:17 → `SemiFloatButtonSize`） |
| `shape: 'round'` | 缺省形状（index.tsx:18；floatButtonGroup.tsx:32 死 defaultProps 同字面量） |
| `colorful: false` | 缺省非多彩（index.tsx:19） |
| `size: 'default'` | 缺省尺寸（index.tsx:20） |
| `window.open(href, '_blank')` | href 新窗跳转（index.tsx:36 → 不移植，href/target 元数据） |
| `window.location.href = href` | 同窗跳转（index.tsx:38 → 同上不移植） |
| `position: fixed` | 视口固定（floatButton.scss:8/125 → PositionedDirectional 宿主 Stack 子节点） |
| `cursor: pointer` | 可点光标（floatButton.scss:12/137 → MouseRegion click） |
| `cursor: not-allowed` | 禁用光标（floatButton.scss:34 → forbidden） |
| `display: flex` | body 居中盒（floatButton.scss:18 → Flex 恒等） |
| `align-items: center` | 垂直居中（floatButton.scss:19 → Alignment.center） |
| `justify-content: center` | 水平居中（floatButton.scss:20 → Alignment.center） |
| `top: calc(0.29 * $radius-floatButton_square)` | 方形 badge 挪位（floatButton.scss:64 → inset 计算） |
| `inset-inline-end: calc(0.29 * $radius-floatButton_square)` | 同上 end 向（:65） |
| `top: calc(0.29 * 0.5 * $width-floatButton)` | 默认尺寸圆形 badge 挪位（:82） |
| `inset-inline-end: calc(0.29 * 0.5 * $width-floatButton)` | 同上 end 向（:83） |
| `top: calc(0.29 * 0.5 * $width-floatButton_small)` | 小尺寸圆形 badge 挪位（:96） |
| `inset-inline-end: calc(0.29 * 0.5 *$width-floatButton_small)` | 同上（:97；★上游 `*$width` 少一空格 quirk 逐字照抄） |
| `top: calc(0.29 * 0.5 * $width-floatButton_large)` | 大尺寸圆形 badge 挪位（:109） |
| `inset-inline-end: calc(0.29 * 0.5 * $width-floatButton_large)` | 同上（:110） |
| `display: inline-flex` | 组容器布局（floatButton.scss:132 → Row shrink-wrap） |
| `font-style: normal` | 子项文字样式恒等（:145 → 注释留档） |
| `type: 'default'` | 死 defaultProps（floatButtonGroup.tsx:33——`type` 非组 props） |
| `size: 'medium'` | 死 defaultProps（:34——`size` 非组 props） |
| `e.target.closest` | DOM 委托定项（:45 → 不移植，逐项 GestureDetector） |
| `item.dataset.value` | DOM 读值（:49 → `item.value` 直读） |
| `e.stopPropagation()` | 禁用断路（:55 → 子项与组回调均不达） |
| `window.open(item.href, '_blank')` | 子项新窗跳转（:58 → 不移植） |
| `window.location.href = item.href` | 子项同窗跳转（:60 → 不移植） |
| `this.props.onClick?.(value, e)` | 组回调派发（:50 → `_dispatch`） |

## 差异清单

★照搬留档（quirk 原样）：
1. **colorful + disabled 类级联**：`-disabled`（floatButton.scss:31）在 `-colorful`（:41）前、同特异性后者胜——多彩视觉（含 hover/active 渐变）胜出，仅 `cursor: not-allowed` 残留（index.tsx:52-59 两 class 同挂 body）。
2. **组禁用无视觉差**：floatButtonGroup.tsx:72-74 挂 `-disabled` 类但 floatButton.scss 无对应规则（2 条死变量为证）——禁用仅断回调，外观不变。
3. **子项禁用无视觉差**：子项 disabled 仅断回调（handleItemClick :54-57），hover/active 底色照常、`cursor: pointer` 照常（:137 无禁用覆盖）。
4. **组子项死接口面**：`FloatButtonGroupItem extends FloatButtonProps` 但渲染只消费 icon/content/badge/disabled/href/target/onClick/value——shape/colorful/size 不参与子项渲染。
5. **组死 defaultProps**：floatButtonGroup.tsx:32-35 `shape: 'round'` / `type: 'default'` / `size: 'medium'` 均非组 props（接口死面）。
6. **组 `children` 从不渲染**：`FloatButtonGroupProps.children` 在 render 中不消费（:68-105 只 map items）。
7. **badge 挪位钉死四角语义**：floatButton.scss:55-113 对任意 position 类的 badge dot/count 强行覆盖 `top`/`inset-inline-end`（CSS 过约束，transform 随类残留）——本移植固定钉在对角线点 + 默认角 translate，`badge.position` 未移植。
8. **badge 挪位小尺寸 `*$width` 少空格**：floatButton.scss:97 上游字面量 quirk——HARDCODES 锚点逐字照抄。
9. **disabled item `e.stopPropagation()` 全断**：itemProps.test.jsx `does not activate a disabled item`——禁用子项连组回调一并切断（非仅子项回调）。

偏差/裁剪：
10. **href/target 不导航**：index.tsx:35-41 / floatButtonGroup.tsx:57-63 的 `window.open`/`location.href` 跳转 → href/target 仅元数据、应用在 onClick 自理（breadcrumb/navigation 先例）；「跳转先于回调」的顺序语义随之裁剪（itemProps.test.jsx `navigates to the item href before invoking its callback`）。
11. **position: fixed → 宿主 Stack 子节点**：`PositionedDirectional`（宿主 Stack 铺满视口即视口固定；★需 Stack 直接子节点位）。★`z-index` 无槽：叠放由宿主 Stack 子序决定（SemiTooltip.zIndex / zBacktop 同口径）。
12. **DOM 委托不移植**：:45 `e.target.closest` / :49 `item.dataset.value` / `!e.currentTarget.contains(item)` → 逐项 GestureDetector 直调 `_dispatch`（值直接来自 `item.value`）。
13. **事件对象**：独立按钮 `onClick(e)` → `VoidCallback`（MouseEvent 无对应，anchor 偏差同口径）；组 `onClick(value, e)` → `(String? value, SemiFloatButtonGroupClickEvent)`——事件仅承载 `stopPropagation()`（`e.currentTarget` 等 DOM 面不移植），封印口径 SemiCheckboxChangeEvent 先例。
14. **className/style 裁剪**：Flutter 无 CSS 类（anchor 偏差 18 同口径）。
15. **键盘激活补强**：上游静态 div 无键盘激活（index.tsx:63 jsx-a11y 禁用注释）→ Focus + Enter（统一交互约定；Space/可打印键忽略）。
16. **Semantics 补强**：上游无 aria-label → `Semantics(button: true)` + `semanticsLabel`。
17. **多彩渐变解析口径**：fluid 盒的 `_SemiGradientBox` 涂装 → body 固定 width×width 盒按已知边长 `forSize` 预解析（同角等价）。

## 用法

```dart
Stack(
  children: [
    content,
    SemiFloatButton(
      shape: SemiFloatButtonShape.round,
      size: SemiFloatButtonSize.defaultSize,
      colorful: true,
      icon: const SemiIcon(SemiIcons.edit),
      badge: const SemiFloatButtonBadge(count: 1000, overflowCount: 999),
      onClick: () {},
    ),
    SemiFloatButtonGroup(
      onClick: (value, event) {},
      items: [
        SemiFloatButtonGroupItem(
          value: 'editor',
          icon: const SemiIcon(SemiIcons.edit),
          content: '编辑',
          onClick: (event) {},
        ),
        SemiFloatButtonGroupItem(
          value: 'search',
          icon: const SemiIcon(SemiIcons.search),
          content: '搜索',
          badge: const SemiFloatButtonBadge(count: 3),
        ),
      ],
    ),
  ],
)
```
