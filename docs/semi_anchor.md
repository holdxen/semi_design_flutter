# SemiAnchor

锚点（上游 Semi Anchor 全件移植）：左侧固定导航 + scroll-spy 联动页面滚动——链接树（`SemiAnchorLink` 无限层级）渲染标题行，滚动时按「目标 top 对容器顶的最大负值」迁升高亮（foundation.ts:97-114 `handleScroll`），点击 title 立即高亮并把页面滚到目标（foundation.ts:116-126 `handleClick` + :157-208 `_scrollIntoView`）。值模型：`activeLink`（String，spy/点击共同驱动）+ `links` 可见注册表（DFS 序，autoCollapse 隐藏分支不注册——上游 unmount 即 removeLink 同口径）+ `childMap`（parent href → 后代 href 集合，foundation.ts:133-155）。回调：`onChanged(current, previous)` 仅 activeLink 变化时发（foundation.ts:45-54；★current 可为 null——首项以上 quirk）、`onClick(href)` 点击即发（foundation.ts:125；`defaultAnchor` 路径 `shouldNotify=false` 两者都不发——index.tsx:279）。scroll-spy 机制：目标 top = `RenderBox.localToGlobal` 全局顶 - 滚动容器顶 - `offsetTop`，逐项取**最大负值**（`elTop[i] < 0 && elTop[i] > lastNegative`）为 active；★全 ≥0 → `links[-1] = undefined` → active = null quirk（滑杆隐藏、`onChanged(null, prev)` 照发）；★`'#'`/非法 id/缺目标 → `-Infinity` 永不激活（index.tsx:172-176 try/catch quirk）。主题对账 **30 = 26 FIELDS + 4 MOTION + 0 INTERNAL**（26 = variables.scss 全部声明、4 = animation.scss 全部声明——**活文件**（anchor.scss:1 `@import "./animation.scss"` + :76-77 消费，0ms/ease-in/0ms/scale(1,1) 恒等）；`$module: #{$prefix}-anchor` 类名胶水不计，datePicker `223 = 220 + 3 + 0`、timePicker `20 = 14 + 6 + 0`、transfer `50 = 47 + 3 + 0` 先例）。

## API

`SemiAnchor({children, scrollController, defaultAnchor, targetOffset: 0, offsetTop: 0, scrollMotion: false, railTheme: SemiAnchorRailTheme.primary, size: SemiAnchorSize.defaultSize, autoCollapse: false, showTooltip: false, position, maxWidth: 200, maxHeight: 750, onChanged, onClick, semanticsLabel})`。

children `List<Widget>` 缺省 `const []`（`SemiAnchorLink` 树，层级无限）。scrollController `ScrollController?`（页面滚动容器；★上游 `getContainer` 的 window 无对应——见差异清单，缺省不接 spy/不滚动）。defaultAnchor `String?`（mount 时高亮+滚动，不发 onChanged/onClick）。targetOffset `double`（点击落点补偿：落点 = 目标顶 - targetOffset）；offsetTop `double`（spy 阈值补偿）。scrollMotion `false`（点击滚动 animateTo/jumpTo）。railTheme `SemiAnchorRailTheme.primary`（| tertiary | muted；muted 轨道 `display: none` quirk）。size `SemiAnchorSize.defaultSize`（| small——`default` 是保留字；字号 14/12、滑杆高 28/24）。autoCollapse `false`（仅展开 active 所在分支）。showTooltip `false`（title 悬停出 tooltip）。position `SemiTooltipPosition?`（tooltip 位置，缺省 top）。maxWidth/maxHeight `200/750`（constants.ts:10-11 `MAX_WIDTH: '200px'`/`MAX_HEIGHT: '750px'`）。onChanged `void Function(String? current, String? previous)?`（★current 可为 null）；onClick `ValueChanged<String>?`。semanticsLabel `String?`（缺省 `'Side navigation'`，index.tsx:368）。

`SemiAnchorLink({key, required href, title, children: const [], disabled: false})`：href `String`（`'#id'`；★`'#'` 点击惰性、spy 恒 -Infinity）；title `Object?`（String | Widget）；children `List<Widget>`（子链接树）；disabled `false`（不可点/Enter 无效但滚动到时照高亮）。

`SemiAnchorTarget({key, required id, required child})`：内容区块目标注册（★上游 `document.querySelector(link)` DOM id 查找——Flutter 无 DOM，本移植新增显式注册，见差异清单）；id 与 href 对齐（`'#sec1'`/`'sec1'` 均可，内部归一化）。

## 行为

### scroll-spy 与高亮

监听 `scrollController`（foundation.ts:97-114）：每 link 目标的全局顶对容器顶（`RenderBox.localToGlobal`）减 `offsetTop`，取最大负值项为 active；★全 ≥0 → active = null quirk（滑杆隐藏、`onChanged(null, prev)` 照发——`links[-1]` = undefined 口径）；★disabled 项照常参与高亮（linkFoundation.ts:21-24 注册不受 disabled 影响）；★重复 href 双高亮（addLink 允许重复、active 按 href 匹配 → 同 href 各行同时高亮）；★`'#'`/非法 id/缺目标 → -Infinity 永不激活（index.tsx:172-176 try/catch quirk）。onChanged(current, previous) 仅 activeLink 变化时发（:45-54）。

### 点击滚动

点击 title → 立即 setActiveLink + 自算 `targetScroll = pixels + linkTop - containerTop - targetOffset` → `scrollMotion ? animateTo(…, 300ms/easeOutCubic) : jumpTo`（★上游 `scroll-into-view-if-needed` 第三方 + smooth/auto 条件——差异清单）；点击置抑制旗标（foundation.ts:122 `setClickLinkWithCallBack`），滚动 listener 跳过高亮（:100-102），**滚动静止后复位**（上游 debounce 100ms——Flutter 100ms Timer 无滚动事件即复位，点击亦起计时——差异清单）；`onClick(href)` 发事件（:125）。`defaultAnchor`：mount 时高亮+滚动但**不发 onChanged/onClick**（`shouldNotify=false`，foundation.ts:50/:125 + index.tsx:279）。★缺目标的合法 id 点击仍高亮 + 发 onClick、不滚动（current-location.test.js 口径）；`'#'` 点击惰性（上游 `document.querySelector('#')` 在 foundation.ts:117 先抛出 → setActiveLink 不达 → 永不激活）。

### 滑杆

top = 激活 title 的 offsetTop（foundation.ts:210-217 `_setActiveSlide`，内容坐标）；高 = 28（default）/24（small）= `heightAnchorSlideDefault + 2 * spacingAnchorSlideDefaultY` 计算式（anchor.scss:38/:42 HARDCODE 锚点）；宽 `widthAnchorSlideDefault`（2）、圆角 `radiusAnchorSlide`（1）；`railTheme` 选色（primary → `colorAnchorSlidePrimaryBgActive`、tertiary → `colorAnchorSlideTertiaryBgActive`）；★muted：轨道 `display: none`（anchor.scss:22-24）+ bar 无背景规则→透明 quirk（:45-51 只给 -primary/-tertiary 背景）。滑轨（`::before` 伪元素 `content: ' '` → 真实 DecoratedBox）：宽 2、圆角 1、色 `colorAnchorSlideDefaultBgDefault`、left/top = `spacingAnchorSlideLeft`/`spacingAnchorSlideTop`。

### 标题行

色态默认 `colorAnchorTitleTextDefault` / hover `colorAnchorTitleTextHover` / active `colorAnchorTitleTextActive`（hover 时 `colorAnchorTitleActiveTextHover`）/ disabled `colorAnchorTitleTextDisabled`（★-disabled 后声明覆盖 -active 色 quirk，anchor.scss:98-101——disabled 高亮行仍显 disabled 色）；bg 默认/active 均 transparent 字段（`colorAnchorTitleBgDefault`/`colorAnchorTitleBgActive`）；padding 上下 `spacingAnchorLinkTitlePaddingTop`/`Bottom`（4）；ellipsis（`overflow: hidden; text-overflow: ellipsis; white-space: nowrap;` anchor.scss:72-74 锚点；Text overflow + ClipRect + OverflowBox deferToChild——semi_tag.dart:350-363 先例）；圆角 `widthAnchorOutlineBorderRadius`（3）；★缩进 `8 * level`（link.tsx:150 HARDCODE；RTL 用 paddingRight——EdgeInsetsDirectional 翻边，rtl.scss:13-15 其中 `padding-left: auto` 无效 CSS 死声明 note-only）；focus outline `widthAnchorOutline`（2）solid `colorAnchorTitleOutlineFocus` + offset `widthAnchorOutlineOffset`（-2）（anchor.scss:92-95，style 固定 `solid` 锚点；-2px 内偏移以 Border 内描边近似）；Enter 激活（link.tsx:168-172，Space/可打印键忽略——keyboardActivation 测试）；`cursor: pointer`（:68）/`cursor: not-allowed`（:99）。

### autoCollapse

childMap（parent href → 后代 href 集合，foundation.ts:74-93/:133-155）；仅 `activeLink == href || childMap[href] 含 activeLink` 时渲染子级（link.tsx:126-135）；隐藏分支整棵不渲染（含其 href 注册——上游 unmount 即 removeLink 同口径）。

### showTooltip

title 包 `SemiTooltip(trigger: hover, showArrow: 默认, position, content: titleText)`（link.tsx renderTitle 的 Typography.Text ellipsis tooltip 语义 + anchor.scss:108-126 `!important` 覆色——Flutter 侧 tooltip 内容色直接用 `colorAnchorTitleTextDefault` 等字段，`!important` 片段作 HARDCODE 锚点留档）。

### size 与几何

size 两档：`font-size-regular`（14，anchor.scss:7）/`font-size-small`（12，:13）+ 滑杆高 28/24；根 = `ConstrainedBox(maxWidth: 200, maxHeight: 750)`（constants.ts:10-11 常量锚点）+ overflow-y auto（内层可滚动——超高内容在 maxHeight 内滚动照 CSS）+ position relative 语义（滑轨绝对定位在内容坐标系）。

## 主题（30 对账）

来源 packages/semi-foundation/anchor/variables.scss（26 声明行 / 26 唯一名——color 12、spacing 7、width 4、height 2、radius 1）+ packages/semi-foundation/anchor/animation.scss（4 声明行——**活文件**：anchor.scss:1 `@import "./animation.scss"` + :76-77 消费，token 解析 0ms/ease-in/0ms/scale(1,1) 恒等）。对账 **30 = 26 FIELDS + 4 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表；`$module: #{$prefix}-anchor` 类名胶水不计）。其中 **2 条死 FIELDS**（死变量留档不消费：落 theme + `# dead variable (上游未消费)` + 本表「（上游未消费）」+ widget assertNotIn）：`$color-anchor_slide_muted-bg-active`（全仓零消费——muted 轨道 `display: none`、bar 无背景规则）、`$spacing-anchor_link-paddingLeft`（scss 零消费——JS 硬编码 `8 * level` 顶替，link.tsx:150；★widget 按 HARDCODE `8 * level` 实消费缩进但**不得**引用该字段名）。全局 token 解析：`var(--semi-color-border)` → `theme.colors.colorBorder`、`var(--semi-color-primary)` → `theme.colors.colorPrimary`、`var(--semi-color-tertiary)` → `theme.colors.colorTertiary`、`var(--semi-color-white)` → `theme.colors.colorWhite`、`var(--semi-color-text-2)` → `theme.colors.colorText2`、`var(--semi-color-tertiary-hover)` → `theme.colors.colorTertiaryHover`、`var(--semi-color-text-0)` → `theme.colors.colorText0`、`var(--semi-color-disabled-text)` → `theme.colors.colorDisabledText`、`var(--semi-color-primary-light-active)` → `theme.colors.colorPrimaryLightActive`；引用 token：`$spacing-none` → 0、`$spacing-extra-tight` → 4、`$spacing-tight` → 8；`transparent` → `const Color(0x00000000)`；★变量引用变量：`$color-anchor_title_active-text-hover: $color-anchor_title-text-hover`（provenance 保留引用原文、resolve 写 `theme.colors.colorTertiaryHover` 同值）；motion 四元组照 generate_transfer.py 先例：`var(--semi-transition_duration-none)`/`var(--semi-transition_delay-none)` → `Duration.zero`、`var(--semi-transition_function-easeIn)` → `Curves.easeIn`、★`var(--semi-transform_scale-none)`（= `scale(1,1)`，semi-theme-default/scss/animation.scss:28）→ **`SemiTransform`（生成域首例！）** → `const SemiTransform.scale(1, 1)`。解析列即 `SemiAnchorThemeData.resolve` 默认表达式。类型覆盖：**12 Color + 14 double + 2 Duration + 1 Curve + 1 SemiTransform**（SemiTransform 值相等走 token_types.dart 自带 `==`/`hashCode`——照 Curve helper 形制评估后无需新增 helper）。

### A. Sass 声明映射（26 FIELDS + 4 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-anchor_slide_default-bg-default: var(--semi-color-border)` | `colorAnchorSlideDefaultBgDefault` | `theme.colors.colorBorder`（滑轨背景色） |
| `$color-anchor_slide_primary-bg-active: var(--semi-color-primary)` | `colorAnchorSlidePrimaryBgActive` | `theme.colors.colorPrimary`（bar primary 色） |
| `$color-anchor_slide_tertiary-bg-active: var(--semi-color-tertiary)` | `colorAnchorSlideTertiaryBgActive` | `theme.colors.colorTertiary`（bar tertiary 色；★上游注释拼写 quirk 照抄 `// 选中颜色 - Tietrary`（variables.scss:4）） |
| `$color-anchor_slide_muted-bg-active: var(--semi-color-white)` | `colorAnchorSlideMutedBgActive` | `theme.colors.colorWhite`（上游未消费）——死变量留档：全仓零消费（muted 轨道 `display: none`、bar 无背景规则） |
| `$color-anchor_title-text-default: var(--semi-color-text-2)` | `colorAnchorTitleTextDefault` | `theme.colors.colorText2`（title 未选中色 + tooltip 覆色 anchor.scss:108） |
| `$color-anchor_title-text-hover: var(--semi-color-tertiary-hover)` | `colorAnchorTitleTextHover` | `theme.colors.colorTertiaryHover`（title 未选中悬浮色） |
| `$color-anchor_title_active-text-hover: $color-anchor_title-text-hover` | `colorAnchorTitleActiveTextHover` | `theme.colors.colorTertiaryHover`（★变量引用变量——provenance 保留引用原文、resolve 同值） |
| `$color-anchor_title-text-active: var(--semi-color-text-0)` | `colorAnchorTitleTextActive` | `theme.colors.colorText0`（title 选中色） |
| `$color-anchor_title-text-disabled: var(--semi-color-disabled-text)` | `colorAnchorTitleTextDisabled` | `theme.colors.colorDisabledText`（title 禁用色；★覆盖 -active 色 quirk） |
| `$color-anchor_title-bg-default: transparent` | `colorAnchorTitleBgDefault` | `const Color(0x00000000)`（title 背景） |
| `$color-anchor_title-bg-active: transparent` | `colorAnchorTitleBgActive` | `const Color(0x00000000)`（title 选中背景） |
| `$color-anchor_title-outline-focus: var(--semi-color-primary-light-active)` | `colorAnchorTitleOutlineFocus` | `theme.colors.colorPrimaryLightActive`（focus 轮廓色） |
| `$spacing-anchor_slide-left: $spacing-none` | `spacingAnchorSlideLeft` | `0`（滑轨左侧位置；RTL 翻右边） |
| `$spacing-anchor_slide-top: $spacing-none` | `spacingAnchorSlideTop` | `0`（滑轨顶部位置） |
| `$spacing-anchor_slide_default-Y: $spacing-extra-tight` | `spacingAnchorSlideDefaultY` | `4`（选项间距 - 默认；滑杆高计算式因子） |
| `$spacing-anchor_slide_small-Y: $spacing-extra-tight` | `spacingAnchorSlideSmallY` | `4`（选项间距 - 紧凑；滑杆高计算式因子） |
| `$spacing-anchor_link-paddingLeft: $spacing-tight` | `spacingAnchorLinkPaddingLeft` | `8`（上游未消费）——死变量留档：scss 零消费（JS 硬编码 `8 * level` 顶替，link.tsx:150）；★widget 按 HARDCODE `8 * level` 实消费缩进但不得引用该字段名 |
| `$spacing-anchor_link_title-paddingTop: $spacing-extra-tight` | `spacingAnchorLinkTitlePaddingTop` | `4`（title 顶部内边距） |
| `$spacing-anchor_link_title-paddingBottom: $spacing-extra-tight` | `spacingAnchorLinkTitlePaddingBottom` | `4`（title 底部内边距） |
| `$width-anchor_slide_default: 2px` | `widthAnchorSlideDefault` | `2`（滑轨/bar 宽度） |
| `$height-anchor_slide_default: 20px` | `heightAnchorSlideDefault` | `20`（选项高度 - 默认；滑杆高 28 = 20 + 2×4 计算式因子） |
| `$height-anchor_slide_small: 16px` | `heightAnchorSlideSmall` | `16`（选项高度 - 小尺寸；滑杆高 24 = 16 + 2×4 计算式因子） |
| `$radius-anchor_slide: 1px` | `radiusAnchorSlide` | `1`（滑轨/bar 圆角） |
| `$width-anchor-outline: 2px` | `widthAnchorOutline` | `2`（focus 轮廓宽；★上游分节注释拼写 quirk 照抄 `// Witdh`（variables.scss:35）） |
| `$width-anchor-outlineOffset: -2px` | `widthAnchorOutlineOffset` | `-2`（focus 轮廓内偏移） |
| `$width-anchor-outline_border_radius: 3px` | `widthAnchorOutlineBorderRadius` | `3`（title 圆角） |
| `$transition_duration-anchor_title-text: var(--semi-transition_duration-none)` | `transitionDurationAnchorTitleText` | `Duration.zero`（活字段——anchor.scss:1 `@import` + :76 消费；AnimatedContainer duration，0ms 恒等） |
| `$transition_function-anchor_title-text: var(--semi-transition_function-easeIn)` | `transitionFunctionAnchorTitleText` | `Curves.easeIn`（活字段；AnimatedContainer curve） |
| `$transition_delay-anchor_title-text: var(--semi-transition_delay-none)` | `transitionDelayAnchorTitleText` | `Duration.zero`（活字段；delay 槽 AnimatedContainer 无对应——注释引用 + 本表注明） |
| `$transform_scale-anchor_title-text: var(--semi-transform_scale-none)` | `transformScaleAnchorTitleText` | `const SemiTransform.scale(1, 1)`（活字段——:77 `transform: scale(...)` 消费；★**生成域首例 SemiTransform**；Transform.scale 恒等消费） |

### B. HARDCODES 另列（`_AnchorMetrics` / 调用点，widget 源内含原始片段）

| 上游片段 | 落点 |
|---|---|
| `8 * level` | title 缩进（link.tsx:150 JS 硬编码；★顶替 `$spacing-anchor_link-paddingLeft` 死变量但不引用字段名；RTL 翻 paddingRight） |
| `overflow: hidden; text-overflow: ellipsis; white-space: nowrap;` | title 单行省略（anchor.scss:72-74 → Text overflow/maxLines + ClipRect + OverflowBox deferToChild） |
| `cursor: pointer` | title 可点光标（anchor.scss:68/:107 → MouseRegion click） |
| `cursor: not-allowed` | disabled 光标（anchor.scss:99/:124 → MouseRegion forbidden） |
| `outline: $width-anchor-outline solid $color-anchor_title-outline-focus` | focus 轮廓（anchor.scss:93；style 固定 `solid` → Border 内描边近似） |
| `outline-offset: $width-anchor-outlineOffset` | focus 轮廓 -2px 内偏移（anchor.scss:94） |
| `content: ' '` | 滑轨伪元素（anchor.scss:54-61 `::before` → 真实 DecoratedBox + SizedBox.expand） |
| `display: none` | muted 轨道（anchor.scss:22-24）+ bar 默认隐藏（:27 `display: none` / :34 `-active` 显）→ 整棵滑轨子树条件渲染 |
| `height: $height-anchor_slide_default + 2 * $spacing-anchor_slide_default-Y` | 滑杆高 28 计算式（anchor.scss:38 → `heightAnchorSlideDefault + 2 * spacingAnchorSlideDefaultY`） |
| `height: $height-anchor_slide_small + 2 * $spacing-anchor_slide_small-Y` | 滑杆高 24 计算式（anchor.scss:42 → `heightAnchorSlideSmall + 2 * spacingAnchorSlideSmallY`） |
| `transform: scale($transform_scale-anchor_title-text)` | title 变形（anchor.scss:77 → Transform.scale 消费 SemiTransform 字段，恒等 scale(1,1)） |
| `transition: color $transition_duration-anchor_title-text $transition_function-anchor_title-text $transition_delay-anchor_title-text` | title 色过渡（anchor.scss:76 → AnimatedContainer duration/curve；delay 无槽注释引用） |
| `color: $color-anchor_title-text-default !important` | tooltip 未选中覆色（anchor.scss:108 → tooltip 内容色用同名主题字段） |
| `color: $color-anchor_title-text-hover !important` | tooltip 悬浮覆色（anchor.scss:115） |
| `color: $color-anchor_title-text-active !important` | tooltip 选中覆色（anchor.scss:119） |
| `color: $color-anchor_title-text-disabled !important` | tooltip 禁用覆色（anchor.scss:123/:126 两处） |
| `$font-size-small: 12px` | small 字号（mixin.scss `font-size-small`；anchor.scss:13/:111） |
| `$font-size-regular: 14px` | 默认字号（mixin.scss `font-size-regular`；anchor.scss:7） |
| `'Side navigation'` | 根语义缺省名（index.tsx:368 → Semantics label） |
| `MAX_WIDTH: '200px'` | 根最大宽常量（constants.ts:10 → `maxWidth` 缺省 200） |
| `MAX_HEIGHT: '750px'` | 根最大高常量（constants.ts:11 → `maxHeight` 缺省 750） |
| `padding-left: auto` | note-only——rtl.scss:14 无效 CSS 死声明（方向互换由 EdgeInsetsDirectional 承担） |

## 差异清单

★照搬留档（quirk 原样）：
1. **首项以上 active=null quirk**：spy 全 ≥0 → `links[-1]` = undefined → active = null（滑杆隐藏、`onChanged(null, prev)` 照发）。
2. **disabled 参与高亮**：disabled 项照常注册/高亮（linkFoundation.ts:21-24），只是不可点、Enter 无效（link.tsx:78 `!disabled && onClick`）。
3. **重复 href 双高亮 / 删除不对称**：addLink 允许重复（同 href 多行同时高亮）、removeLink 只删首处（index.tsx:122-129；本移植注册表按可见树派生=终态等价，remove-first 的瞬态序差异不复现——见偏差 16）。
4. **`'#'`/非法 id 永不激活**：spy 恒 -Infinity（index.tsx:172-176 try/catch quirk）；`'#'` 点击惰性（foundation.ts:117 `document.querySelector('#')` 先抛出 → setActiveLink 不达）。★缺目标的合法 id 点击仍高亮+onClick 不滚动（current-location.test.js 口径照搬）。
5. **muted 轨道 `display: none` + bar 透明**：muted 整棵滑轨不渲染（anchor.scss:22-24），bar 无背景规则（:45-51 只给 -primary/-tertiary）。
6. **transition/transform 恒等**：MOTION 4 字段解析 0ms/ease-in/0ms/scale(1,1)——视觉无动画/无变形（活字段照消费）。
7. **defaultAnchor 不发回调**：mount 时高亮+滚动，`shouldNotify=false`（foundation.ts:50/:125 + index.tsx:279）。
8. **点击抑制旗标 + 静止复位**：点击置 `clickLink`（foundation.ts:122），spy 跳过高亮（:100-102），滚动静止后复位（上游 debounce 100ms）。
9. **缩进 `8 * level` 死变量顶替**：link.tsx:150 JS 硬编码顶替 `$spacing-anchor_link-paddingLeft`（scss 零消费）。
10. **-disabled 覆盖 -active 色**：anchor.scss:98-101 后声明覆盖——disabled 高亮行显 disabled 色（active 类仍在、滑杆照移）。
11. **Tietrary/Witdh 拼写 quirk**：variables.scss:4 `// 选中颜色 - Tietrary`、:35 `// Witdh` 上游错拼原文照抄（PROVENANCE_NOTES 留档）。
12. **rtl `padding-left: auto` 死声明**：rtl.scss:14 无效 CSS（note-only）；方向互换（滑轨翻边、缩进翻 paddingRight）照 rtl.scss:8-15 语义。

偏差/裁剪：
13. **getContainer → scrollController**：上游 `getContainer: () => HTMLElement | Window`（缺省 window）；Flutter window 无对应滚动语义 → `scrollController: ScrollController?`，缺省不接 spy/不滚动。
14. **showTooltip 对象形态裁剪**：上游 `showTooltip: boolean | ShowTooltip`（对象含 `opts` 共享防变异——link.tsx:105-110 `Object.assign({ opts: {} }, showTooltip)`）拆为 `showTooltip: bool` + `position: SemiTooltipPosition?`（对象形态/共享 opts 防变异不移植）。
15. **React Fragment 同级 → children 列表天然**：`renderChildren` 的 Fragment 扁平化（index.tsx:250-252）由 `List<Widget>` 天然承担；非 `SemiAnchorLink` 条目跳过。
16. **scroll throttle/debounce 100ms → 每事件 + 100ms 静止 Timer**：上游 `throttle(handleScroll, 100)` + `debounce(handleClickLink, 100)`（index.tsx:274-275）→ 本移植 spy 每滚动事件即跑、旗标复位为「点击即起 + 滚动事件续期」的 100ms 静止 Timer（★上游 debounce 仅滚动事件触发——零滚动事件时旗标滞留的场景本移植 100ms 即复位）。
17. **scroll-into-view-if-needed → 自算 offset**：上游第三方 `scroll-into-view-if-needed` + `behavior: smooth/auto`（`canSmoothScroll` 探测，foundation.ts:157-208）→ 自算 `targetScroll = pixels + linkTop - containerTop - targetOffset` + clamp 到滚动范围；`scrollMotion` animateTo 300ms/easeOutCubic（★自决点——浏览器原生 smooth 无时长参数），否则 jumpTo。
18. **className/style 裁剪**：`className`/`style`/`getDataAttr` 不移植（Flutter 无 CSS 类）。
19. **direction → Directionality**：上游 `direction: 'ltr' | 'rtl'` prop + rtl.scss → Flutter `Directionality` 自然镜像（EdgeInsetsDirectional/PositionedDirectional 翻边）。
20. **SemiAnchorTarget 目标注册（必要新增）**：上游 `document.querySelector(link)` DOM id 查找（index.tsx:174）无 Flutter 对应 → 新增 `SemiAnchorTarget(id, child)` 显式注册目标 RenderBox；重复 id 后注册覆盖。★ListView 惰性卸载 caveat：目标被 sliver 卸载（超出 cacheExtent）时 spy 视其 -Infinity、点击不滚动——建议 `Column + SingleChildScrollView` 或足量 `cacheExtent` 宿主。
21. **position 枚举 12 向**：上游 `strings.POSITION_SET` 14 含 `leftTopOver`/`rightTopOver`（内部 straddle 态，tooltip_positioning.dart:36-40）→ 公共 `SemiTooltipPosition` 12 向。
22. **`$color-anchor_title_active-text-hover` resolve 同值直写**：变量引用变量的 provenance 保留 `$color-anchor_title-text-hover` 原文，resolve 直写 `theme.colors.colorTertiaryHover`（同值）。
23. **focus outline 近似**：CSS `outline` + `outline-offset: -2px`（不占布局）→ `Border.all` 内描边 + 圆角 3 近似（视觉等价，布局含边框）。
24. **bar top 度量**：`offsetTop`（CSS 定位祖先）→ `RenderBox.localToGlobal` 差值（内容坐标，postFrame 度量）。
25. **tooltip 触发域**：上游 Typography.Text ellipsis tooltip（溢出才出/`showTooltip` 对象配置）→ 简化为 title 悬停即出（trigger: hover、showArrow 缺省、content: titleText）。
26. **mouseup/click 语义**：上游 `onKeyPress`/`onClick` DOM 事件 → GestureDetector tap + `Focus.onKeyEvent` Enter（Space/可打印键忽略照 keyboardActivation 测试）。

## 用法

```dart
final controller = ScrollController();

Row(
  children: [
    SemiAnchor(
      scrollController: controller,
      defaultAnchor: '#sec2',
      onChanged: (current, previous) {
        // ★current 可为 null（首项以上 quirk）
      },
      onClick: (href) {},
      children: const [
        SemiAnchorLink(href: '#sec1', title: '第一节'),
        SemiAnchorLink(href: '#sec2', title: '第二节', children: [
          SemiAnchorLink(href: '#sec2-1', title: '子节'),
        ]),
        SemiAnchorLink(href: '#sec3', title: '禁用节', disabled: true),
      ],
    ),
    Expanded(
      child: SingleChildScrollView(
        controller: controller,
        child: Column(children: const [
          SemiAnchorTarget(id: '#sec1', child: SizedBox(height: 500)),
          SemiAnchorTarget(id: '#sec2', child: SizedBox(height: 500)),
          SemiAnchorTarget(id: '#sec2-1', child: SizedBox(height: 300)),
          SemiAnchorTarget(id: '#sec3', child: SizedBox(height: 500)),
        ]),
      ),
    ),
  ],
)
```
