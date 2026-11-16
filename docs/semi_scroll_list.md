# SemiScrollList

滚动列表（上游 Semi ScrollList 全件移植）：header/body/footer 三段容器（`-header` 居中标题 + `-line` 分隔线、`-body` 横排 flex 列、`-footer` 顶描边 + padding）+ 滚动列 `SemiScrollItem`——normal（普通点选列表）与 wheel（滚轮，缺省）两模式。body 子项 flex: 1 均分、非末列出分隔描边（`&:not(:last-child)`，rtl 翻侧）。normal：行高 36 居中文案、`ul:before` 顶留白 + `padding-bottom` 底留白（`(300-36)*0.5 = 132`）使任意行可滚中、点选即通知 onSelect（不去重、不滚中）、选中行走 `-item-sel` 底色（`selectedIndex === index` 严格相等——transform 文案同此门）。wheel：选择带（`top: 50%` + `translateY(-50%)`，36 高、上下 1px 描边）+ 上下 50% 高渐隐遮罩（`opacity: 0.5` 背景同色、`pointer-events: none`）叠于滚动层之上（静态 `list-outer` 在下）；停滚 2 帧（`msPerFrame * 2` ≈ 33ms）后取距选择带顶最近的**非禁用**行（`Math.abs(rectTop - selectorTop)` 最小者胜、同距 DOM 序优先）吸附居中（120ms `animatedScrollTo`）并落 `semi-scrolllist-item-selected` 类（font-weight bold + `color: var(--semi-color-primary) !important`）；同节点/同数据下标去重通知（`if (this._cachedSelectedNode !== node) {` + `cachedIndexData !== indexInData` 双门）；点选同走 debounce → 吸附居中 + 去重通知。cycled：上游 prepend/append DOM 副本 + 滚中搬移（`initWheelList`/`adjustInfiniteList`）→ 本移植虚拟循环列表等价（无限滚动、轮回数据下标 `indexInList % data.length`）；非 cycled 出 `list-outer-nocycle` 首尾留白。主题对账 **42 = 39 FIELDS + 3 MOTION + 0 INTERNAL**（variables.scss 39 声明：color 13、width 5、height 3、spacing 14、radius 1、font 2、shadow 1；animation.scss 3 声明：选中背景过渡三元组；`$module` 胶水与 rtl.scss 不计，datePicker `223 = 220 + 3 + 0`、badge `37 = 37 FIELDS + 0 MOTION + 0 INTERNAL` 先例）；其中 **3 条 `li > svg` FIELDS**（`$color-scrollList_selected_item-icon`、`$width-scrollList_item_sel_svg`、`$spacing-scrollList_item_sel_svg-marginRight`）留档不消费 + **1 条 quirk FIELDS**（`$width-scrollList_item_wheel-border`）。

## API

`SemiScrollList({header, footer, bodyHeight, children})`。

header `Widget?`（头部内容；null 不出 header 区与 `-line`）。footer `Widget?`（底部内容；null 不出 footer 区）。bodyHeight `double?`（body 高度；null 取 `$height-scrollList` 300）。children `List<Widget>`（body 子项，缺省 `[]`——通常为 SemiScrollItem 列，flex: 1 均分）。

`SemiScrollItem({mode: wheel, cycled: false, list: [], selectedIndex: 0, onSelect, transform, type, motion: true, semanticsLabel})`。

mode `SemiScrollItemMode`（normal/wheel，缺省 wheel——上游 `mode: wheelMode`）。cycled `bool` 缺省 false（无限循环，仅 wheel 生效）。list `List<SemiScrollItemData>` 缺省 `[]`。selectedIndex `int` 缺省 0（定位滚动、normal 高亮与 transform 文案的门；负值按上游 `selectedIndex > -1 ? selectedIndex : 0` 收 0、越界收敛为 clamp——差异清单）。onSelect `ValueChanged<SemiScrollItemSelection>?`（载荷 `{item, index, type}` 对应上游 `{...item, value, type, index: indexInData}`）。transform `String Function(Object? value, String? text)?`（选中项文案变换；item 级 `transform` 优先——`typeof itemTrans === 'function' ? itemTrans : commonTrans`）。type `Object?`（列标识，透传载荷；上游自述 internal）。motion `bool` 缺省 true（滚动动画；上游 `Motion` 函数形态收敛）。semanticsLabel `String?`（上游 `aria-label`）。

`SemiScrollItemData({value, text, disabled: false, transform})`：value `Object?`（`value: any`；text 缺省时按 JS String() 语义出文案）、text `String?`（null 回落 value——`item.text == null ? item.value : item.text`）、disabled `bool`（不可点选、wheel 定选跳过——`isDisabledData = (data: T) => data && typeof data === 'object' && data.disabled`）、transform（该项选中时的文案变换）。

## 行为

### normal 点选

行点选即通知 onSelect（`this.foundation.selectIndex(index, this.list)`——不去重、不滚中、无吸附）；高亮 `-item-sel` 由 `selectedIndex === index` 严格相等驱动（父级受控回写才移位）。禁用行不出手势（`cursor: not-allowed`）、不通知。

### wheel 定选与吸附

滚动停 2 帧后定选：候选 = 距选择带顶（内容坐标 = 偏移 + 视口半高 - 半行高）最近的非禁用行，升序扫描严格小于（同距 DOM 序优先）；吸附居中（scrollToCenter 公式 `scrollRect.top + scrollRect.height / 2 - selectedRect.height / 2` → 目标 = 行中线对齐视口中线 = scrollToNode 公式 `targetTop = node.offsetTop - (wrapperHeight - itemHeight) / 2`），120ms `animatedScrollTo`（`DEFAULT_SCROLL_DURATION: 120`；motion false 时 jumpTo）；落 `semi-scrolllist-item-selected` 类到定选节点（★虚拟下标定位——cycled 同数据项多副本只亮定选副本，上游节点语义）；通知按数据下标去重（同副本/同下标均不再发）。点选（clickToSelectItem → debouncedSelect）同链路：debounce 33ms → 吸附居中 + 去重通知。selectedIndex prop 变化 → 吸附滚动到对应项（componentDidUpdate `scrollToIndex`，120ms 动画）。

### 文案与 transform

非选中行恒显 `text ?? String(value)`；选中行（`selectedIndex === index`，含 cycled 全副本）过 transform（item 级优先，缺省列级）——返回值即显示文案。JS String() 语义归一：整数值不带 `.0`（badge `_formatNum` 先例）。

### 视觉

- 根：`background: $color-scrollList-bg`、`box-shadow: $shadow-scrollList`（String 字段 + 同值 BoxShadow twin）、`border-radius: $radius-scrollList`、`overflow: hidden`、`@include font-size-regular`（14px/20px）、`user-select: none`、`flex-direction: column`。
- header：`text-align: center`、padding `$spacing-scrollList_header-paddingY/X`、背景 `$color-scrollList_header-bg`；title padding `$spacing-scrollList_header_title-paddingY/X`、`font-weight: $font-scrollList_header_title-fontWeight`、字色 `$color-scrollList_header-title`；`-line` 高 `$height-scrollList_line`、色 `$color-scrollList-border`。
- body：`display: flex`、高 `$height-scrollList`（bodyHeight 覆盖）、padding `$spacing-scrollList_body-paddingY/X`；列 `flex: 1` 均分，非末列描边 `$width-scrollList_item-border`（wheel 列 `$width-scrollList_item_wheel-border`）色 `$color-scrollList-border`（rtl.scss `border-right: 0` 翻边）。
- `ul`：margin/padding `$spacing-scrollList_item_ul-margin/-padding`、`padding-bottom: $spacing-scrollList_item_ul-paddingBottom`（132）、`list-style: none`；`ul:before` 顶留白块（`content: '';` + 高度公式 `($height-scrollList - $height-scrollList_item) * 0.5` = 132，同值复用底留白字段）。
- `li`：高 `$height-scrollList_item`（36）、`box-sizing: border-box`、`align-items: center`/`justify-content: center` 居中、`cursor: pointer`（禁用 `cursor: not-allowed`）、`transition: background-color`（MOTION 三元组）；底色 `$color-scrollList_item-bg` → hover `$color-scrollList_item-text-hover` → active `$color-scrollList_item-bg-active`（`:not(.disabled):not(.-item-disabled):not(.-item-sel):not(.-item-selected)` 门内）；normal 选中 `-item-sel`：底 `$color-scrollList_selected_item-bg`、字 `$color-scrollList_selected_item-text`；禁用字 `$color-scrollList_disabled_item-text`；wheel 定选 `semi-scrolllist-item-selected`：`font-weight: $font-scrollList_item_wheel_item_selected-fontWeight` + `color: var(--semi-color-primary) !important`（★变量外内联色）。
- wheel 覆盖层：`-shade-pre/-post`（`height: 50%`、`opacity: 0.5`、`pointer-events: none`、底 `$color-scrollList-bg`；margin-top `$spacing-scrollList_item_wheel_list_shade_pre/post-marginTop`）、`-selector`（`top: 50%` + `transform: translateY(-50%)`、高 `$height-scrollList_item`、上下描边 `$width-scrollList_item_wheel_selector-border` 色 `$color-scrollList-border`）；`list-outer` `padding-right: $spacing-scrollList_item_wheel_list_outer-paddingRight`（rtl.scss 翻 `padding-left`）。
- footer：`border-top: $width-scrollList_footer-border solid $color-scrollList_footer-border`、padding `$spacing-scrollList_footer-padding`。

## 主题（42 对账）

来源 packages/semi-foundation/scrollList/variables.scss（39 声明行 / 39 唯一名——color 13、width 5、height 3、spacing 14、radius 1、font 2、shadow 1；无重复）与 animation.scss（3 声明：选中背景过渡三元组，scrollList.scss:87 活消费）。对账 **42 = 39 FIELDS + 3 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表；`$module: #{$prefix}-scrolllist` 类名胶水与 rtl.scss 不计）。**0 条死 FIELDS**（全部声明被 scrollList.scss/rtl.scss 规则消费）；**3 条 `li > svg` FIELDS** 留档不消费（落 theme + 本表「留档不消费」+ widget assertNotIn）：`$color-scrollList_selected_item-icon`、`$width-scrollList_item_sel_svg`、`$spacing-scrollList_item_sel_svg-marginRight`——上游仅 `-item-sel > svg` 规则消费（scrollList.scss:92-97 / rtl.scss:22-27），组件 `{text}` 渲染路径恒 string，SVG 子仅 `value` 为节点的野路子可达（ItemData 文档 API 不含节点）；**1 条 quirk FIELDS** `$width-scrollList_item_wheel-border`（scrollList.scss:125 滚轮分隔直接写 `$border-thickness-control` 同值 1，本变量仅 rtl.scss:37 消费）。全局 token 解析：`var(--semi-color-bg-3)` → `theme.colors.colorBg3`、`var(--semi-color-border)` → `theme.colors.colorBorder`、`var(--semi-color-text-0)` → `theme.colors.colorText0`、`var(--semi-color-text-2)` → `theme.colors.colorText2`、`var(--semi-color-disabled-text)` → `theme.colors.colorDisabledText`、`var(--semi-color-fill-1)` → `theme.colors.colorFill1`、`var(--semi-color-fill-2)` → `theme.colors.colorFill2`、`var(--semi-color-primary-light-default)` → `theme.colors.colorPrimaryLightDefault`、`var(--semi-border-radius-medium)` → `theme.radius.borderRadiusMedium.value`（badge `var(--semi-border-radius-circle)` 先例）；`transparent` → `const Color(0x00000000)`（autocomplete 先例）；引用 token：`$border-thickness-control` → 1、`$spacing-base` → 16（button 先例）、`$font-weight-bold` → `theme.typography.fontWeightBold`（button 先例）；派生四则运算走数值等价（datePicker 先例）：`($height-scrollList - $height-scrollList_item) * 0.5` → 132、`$height-scrollList_item * 0.5` → 18、`-1 * ($height-scrollList_item * 0.5 + $border-thickness-control)` → -19、`$height-scrollList_item * 0.5 + $border-thickness-control` → 19。MOTION 三元组照 generate_anchor.py 先例：`var(--semi-transition_duration-none)`/`0ms` → `Duration.zero`、`var(--semi-transition_function-easeOut)` → `Curves.easeOut`（carousel 先例）。`$shadow-scrollList` 保持 String 字段（datePicker transition-String / time_picker shadow 先例）——widget 放同值 BoxShadow twin（`_ScrollListMetrics.shadow`，注释互指）。解析列即 `SemiScrollListThemeData.resolve` 默认表达式。类型覆盖：**13 Color + 23 double + 2 FontWeight + 1 String = 39 FIELDS + 2 Duration + 1 Curve = 3 MOTION**。

### A. Sass 声明映射（39 FIELDS + 3 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-scrollList-bg: var(--semi-color-bg-3)` | `colorScrollListBg` | `theme.colors.colorBg3`（根/遮罩背景） |
| `$color-scrollList-border: var(--semi-color-border)` | `colorScrollListBorder` | `theme.colors.colorBorder`（分隔/`-line`/selector 描边） |
| `$color-scrollList_header-bg: transparent` | `colorScrollListHeaderBg` | `const Color(0x00000000)`（header 背景） |
| `$color-scrollList_header-title: var(--semi-color-text-0)` | `colorScrollListHeaderTitle` | `theme.colors.colorText0`（标题字色） |
| `$color-scrollList_item-bg: transparent` | `colorScrollListItemBg` | `const Color(0x00000000)`（行底色） |
| `$color-scrollList_item-text: var(--semi-color-text-0)` | `colorScrollListItemText` | `theme.colors.colorText0`（行字色） |
| `$color-scrollList_disabled_item-text: var(--semi-color-disabled-text)` | `colorScrollListDisabledItemText` | `theme.colors.colorDisabledText`（禁用行字色） |
| `$color-scrollList_item-text-hover: var(--semi-color-fill-1)` | `colorScrollListItemTextHover` | `theme.colors.colorFill1`（hover 行底） |
| `$color-scrollList_item-bg-active: var(--semi-color-fill-2)` | `colorScrollListItemBgActive` | `theme.colors.colorFill2`（active 行底） |
| `$color-scrollList_selected_item-bg: var(--semi-color-primary-light-default)` | `colorScrollListSelectedItemBg` | `theme.colors.colorPrimaryLightDefault`（normal 选中底） |
| `$color-scrollList_selected_item-text: var(--semi-color-text-0)` | `colorScrollListSelectedItemText` | `theme.colors.colorText0`（normal 选中字色） |
| `$color-scrollList_selected_item-icon: var(--semi-color-text-2)` | `colorScrollListSelectedItemIcon` | `theme.colors.colorText2`（留档不消费——上游仅 `-item-sel > svg` 规则消费，`{text}` 路径恒 string 不可达；widget 不消费本字段） |
| `$color-scrollList_footer-border: var(--semi-color-border)` | `colorScrollListFooterBorder` | `theme.colors.colorBorder`（footer 顶描边） |
| `$height-scrollList: 300px` | `heightScrollList` | `300`（body 高缺省） |
| `$height-scrollList_item: 36px` | `heightScrollListItem` | `36`（行高/selector 高；`DEFAULT_ITEM_HEIGHT: 36` 兜底另列） |
| `$width-scrollList_item-border: $border-thickness-control` | `widthScrollListItemBorder` | `1`（normal 列分隔宽；`$border-thickness-control` -> 1，button 先例） |
| `$width-scrollList_item_sel_svg: 16px` | `widthScrollListItemSelSvg` | `16`（留档不消费——上游仅 `-item-sel > svg` 规则消费，`{text}` 路径恒 string 不可达；widget 不消费本字段） |
| `$width-scrollList_item_wheel-border: $border-thickness-control` | `widthScrollListItemWheelBorder` | `1`（quirk——scrollList.scss:125 滚轮分隔直接写 `$border-thickness-control` 同值 1，本变量仅 rtl.scss:37 消费） |
| `$width-scrollList_item_wheel_selector-border: $border-thickness-control` | `widthScrollListItemWheelSelectorBorder` | `1`（selector 上下描边宽） |
| `$height-scrollList_line: 1px` | `heightScrollListLine` | `1`（header `-line` 高） |
| `$width-scrollList_footer-border: $border-thickness-control` | `widthScrollListFooterBorder` | `1`（footer 顶描边宽） |
| `$spacing-scrollList_header-paddingY: 0` | `spacingScrollListHeaderPaddingY` | `0`（0 值字段照用即消费） |
| `$spacing-scrollList_header-paddingX: 16px` | `spacingScrollListHeaderPaddingX` | `16` |
| `$spacing-scrollList_header_title-paddingY: $spacing-base` | `spacingScrollListHeaderTitlePaddingY` | `16`（`$spacing-base` -> 16，button 先例） |
| `$spacing-scrollList_header_title-paddingX: 0` | `spacingScrollListHeaderTitlePaddingX` | `0` |
| `$spacing-scrollList_body-paddingY: 0` | `spacingScrollListBodyPaddingY` | `0` |
| `$spacing-scrollList_body-paddingX: 16px` | `spacingScrollListBodyPaddingX` | `16` |
| `$spacing-scrollList_item_ul-padding: 0` | `spacingScrollListItemUlPadding` | `0`（`ul` padding） |
| `$spacing-scrollList_item_ul-margin: 0` | `spacingScrollListItemUlMargin` | `0`（`ul` margin） |
| `$spacing-scrollList_item_ul-paddingBottom: ($height-scrollList - $height-scrollList_item) * 0.5` | `spacingScrollListItemUlPaddingBottom` | `132`（派生四则运算数值等价；首尾留白块共用——`:before` 高度公式同值） |
| `$spacing-scrollList_item_sel_svg-marginRight: 12px` | `spacingScrollListItemSelSvgMarginRight` | `12`（留档不消费——上游仅 `-item-sel > svg` 规则消费（scrollList.scss:96、rtl.scss:26-27），`{text}` 路径恒 string 不可达；widget 不消费本字段） |
| `$spacing-scrollList_item_wheel_list_outer-paddingRight: $height-scrollList_item * 0.5` | `spacingScrollListItemWheelListOuterPaddingRight` | `18`（派生数值等价；`list-outer` padding-right，rtl 翻边） |
| `$spacing-scrollList_item_wheel_list_shade_pre-marginTop: -1 * ($height-scrollList_item * 0.5 + $border-thickness-control)` | `spacingScrollListItemWheelListShadePreMarginTop` | `-19`（派生数值等价；pre 遮罩上移） |
| `$spacing-scrollList_item_wheel_list_shade_post-marginTop: $height-scrollList_item * 0.5 + $border-thickness-control` | `spacingScrollListItemWheelListShadePostMarginTop` | `19`（派生数值等价；post 遮罩下移） |
| `$spacing-scrollList_footer-padding: 10px` | `spacingScrollListFooterPadding` | `10` |
| `$radius-scrollList: var(--semi-border-radius-medium)` | `radiusScrollList` | `theme.radius.borderRadiusMedium.value`（根圆角） |
| `$font-scrollList_header_title-fontWeight: $font-weight-bold` | `fontScrollListHeaderTitleFontWeight` | `theme.typography.fontWeightBold`（标题字重） |
| `$font-scrollList_item_wheel_item_selected-fontWeight: $font-weight-bold` | `fontScrollListItemWheelItemSelectedFontWeight` | `theme.typography.fontWeightBold`（wheel 定选字重） |
| `$shadow-scrollList: 0 0 1px rgba(0, 0, 0, .3), 0 4px 14px rgba(0, 0, 0, .1)` | `shadowScrollList` | `'0 0 1px rgba(0, 0, 0, .3), 0 4px 14px rgba(0, 0, 0, .1)'`（String 字段保上游原文；`_ScrollListMetrics.shadow` 同值 BoxShadow twin） |
| `$transition_duration-scrollList_selected_item-bg: var(--semi-transition_duration-none)` | `transitionDurationScrollListSelectedItemBg` | `Duration.zero`（活字段——scrollList.scss:87 消费；AnimatedContainer duration，0ms 恒等） |
| `$transition_function-scrollList_selected_item-bg: var(--semi-transition_function-easeOut)` | `transitionFunctionScrollListSelectedItemBg` | `Curves.easeOut`（活字段；AnimatedContainer curve） |
| `$transition_delay-scrollList_selected_item-bg: 0ms` | `transitionDelayScrollListSelectedItemBg` | `Duration.zero`（活字段；delay 槽 AnimatedContainer 无对应——注释引用 + 本表注明，anchor 先例） |

### B. HARDCODES 另列（widget 文件头注释 / 调用点，源内含原始片段）

| 上游片段 | 落点 |
|---|---|
| `MODE: ['normal', 'wheel']` | `SemiScrollItemMode` 枚举（constants.ts strings） |
| `DEFAULT_ITEM_HEIGHT: 36` | 行高兜底（constants.ts numbers；行高实际取 `$height-scrollList_item`） |
| `DEFAULT_SCROLL_DURATION: 120` | 滚动动画 120ms（constants.ts numbers；animateTo duration） |
| `selectedIndex: 0` | 缺省选中下标（scrollItem.tsx defaultProps） |
| `motion: true` | 缺省动画（scrollItem.tsx defaultProps） |
| `list: []` | 缺省列表（scrollItem.tsx defaultProps） |
| `cycled: false` | 缺省非循环（scrollItem.tsx defaultProps） |
| `mode: wheelMode` | 缺省 wheel（scrollItem.tsx defaultProps） |
| `msPerFrame = 1000 / 60` | throttle/debounce 帧时基准 |
| `this.throttledAdjustList = throttle(` | cycled 列表均衡（→ 虚拟循环列表等价，差异清单） |
| `this.debouncedSelect = debounce(` | 停滚 2 帧定选（33ms debounce） |
| `this.foundation.initWheelList(this.list, this.wrapper, () => {` | cycled 首尾副本铺排（→ 虚拟循环列表等价） |
| `this.foundation.adjustInfiniteList(this.list, this.wrapper, nearestNode)` | 滚中 DOM 搬移（→ 静默 re-wrap 等价） |
| `const ratio = 1;` | adjustInfiniteList 调平比例（init 的 shouldPrepend/shouldAppend 缺省 ratio = 2） |
| `indexInList % data.length` | 轮回数据下标（onSelect 载荷 `index`） |
| `isDisabledData = (data: T) => data && typeof data === 'object' && data.disabled` | 禁用判定 |
| `Math.abs(rectTop - selectorTop)` | 定选距离度量（同距 DOM 序优先） |
| `item.text == null ? item.value : item.text` | 文案兜底 |
| `typeof itemTrans === 'function' ? itemTrans : commonTrans` | item 级 transform 优先 |
| `if (this._cachedSelectedNode !== node) {` | 同节点去重门 |
| `index: indexInData,` | onSelect 载荷下标 |
| `node.setAttribute('aria-selected', String(node === selectedNode))` | 选中语义（Semantics selected 等价） |
| `this.foundation.selectIndex(index, this.list)` | normal 点选即通知（不去重） |
| `-item-sel` | normal 选中底色类 |
| `semi-scrolllist-item-selected` | wheel 定选节点类 |
| `targetTop = (node.offsetTop \|\| this.list.children.length * itemHeight / 2) - (wrapperHeight - itemHeight) / 2` | 滚中公式 |
| `scrollRect.top + scrollRect.height / 2 - selectedRect.height / 2` | 吸附居中公式 |
| `if (listHeight <= 0) {` | jsdom 零矩形守护（itemFoundation） |
| `user-select: none` | 根（无 Flutter 对应——文本选择由 Text 自带） |
| `flex-direction: column` | 根三段纵排 |
| `text-align: center` | header 居中 |
| `content: '';` | `ul:before` 顶留白块（高度公式 = 132 同值复用底留白字段） |
| `list-style: none` | `ul`（Flutter 无列表符号） |
| `box-sizing: border-box` | `li`（Flutter 盒模型内含等价） |
| `align-items: center` | 行内容居中（Alignment.center 等价） |
| `cursor: pointer` | 行指针（SystemMouseCursors.click） |
| `cursor: not-allowed` | 禁用行指针（SystemMouseCursors.forbidden） |
| `&:not(:last-child)` | 非末列分隔描边门 |
| `transform: translateY(-50%)` | selector 垂直居中（Alignment.center 等价） |
| `opacity: 0.5` | 遮罩透明度 |
| `pointer-events: none` | 遮罩不拦截（IgnorePointer 等价） |
| `color: var(--semi-color-primary) !important` | wheel 定选字色（★变量外内联色 → theme.colors.colorPrimary） |
| `direction: rtl` | rtl.scss 根方向（Directionality 自然覆盖） |
| `border-right: 0` | rtl 翻边（BorderDirectional.end 等价） |
| `margin-right: 0` | rtl 翻边 |
| `padding-right: 0` | rtl 翻边（EdgeInsetsDirectional.end 等价） |

## 差异清单

★照搬留档（quirk 原样）：
1. **normal 不去重**：`this.foundation.selectIndex(index, this.list)` 即点即通知——重复点同一行仍发 onSelect（wheel 才走去重双门）。
2. **transform 门 = `selectedIndex === index` 严格相等**：越界 selectedIndex 无行命中（高亮/transform 同门）；cycled 时该数据项全副本均过 transform（上游 renderItemList 同）。
3. **wheel 定选亮虚拟节点**：`semi-scrolllist-item-selected` 只落定选副本（上游节点语义）——cycled 同数据项多副本不全亮。
4. **hover/active 门内排除选中/禁用**（`:not(.disabled):not(.-item-disabled):not(.-item-sel):not(.-item-selected)`）——wheel 定选行不出 hover/active 底色但保留 `cursor: pointer`。
5. **wheel `!important` 主色**：定选字色为样式内联 `var(--semi-color-primary)`（变量外）——消费走 `theme.colors.colorPrimary`。
6. **`$width-scrollList_item_wheel-border` quirk**：scrollList.scss:125 滚轮分隔写 `$border-thickness-control`（同值 1）——本移植 wheel 分隔消费本变量（净效果一致）。
7. **JS String() 语义**：value 出文案整数值不带 `.0`（badge `_formatNum` 先例）。
8. **wheel mount 发一次 onSelect 初值**：mount 滚动事件 → `debouncedSelect` 落选，foundation `_cachedSelectedNode` 初值 null 去重门放行 → 33ms 后通知一次初值（受控父级回写同值无感）；normal 不发（上游无 onScroll 链）。

偏差/裁剪：
9. **cycled 虚拟循环列表**：上游 prepend/append DOM 副本 + `initWheelList`/`adjustInfiniteList` 滚中搬移（`const ratio = 1;` 调平）→ 本移植固定虚拟块数 + 静默 re-wrap（无限滚动、轮回下标、同副本去重净效果一致；不搬 DOM 节点）。
10. **吸附/滚动动画**：上游 120ms `animatedScrollTo`（semi-animation）→ `animateTo(120ms, Curves.easeOut)`；`motion` 函数形态收敛为 `bool`（true 动画/false jumpTo）。
11. **onSelect 载荷**：`{...item, value, type, index}` → `SemiScrollItemSelection({item, index, type})`（item 携 value/text/disabled/transform）。
12. **`aria-label` → `semanticsLabel`**、`aria-selected`/`aria-disabled` → `Semantics(selected/enabled)`（`node.setAttribute('aria-selected', String(node === selectedNode))` 语义等价）。
13. **selectedIndex 越界收敛 clamp、负值收 0**（上游 `selectedIndex > -1 ? selectedIndex : 0` 仅 mount 收负值，越界 mount 会崩——本移植收敛为可用区间，差异注明）。
14. **根尺寸**：`width: 100%` → 随父约束满宽（`SizedBox(width: double.infinity)`——父级无界时需自定宽）；`height: 100%` → 随内容（body 300 + header/footer）。
15. **`$color-scrollList_selected_item-icon`/`$width-scrollList_item_sel_svg`/`$spacing-scrollList_item_sel_svg-marginRight`**：上游 `-item-sel > svg` 图标槽（SVG 子 16×16 + margin-right）不可达（`{text}` 渲染恒 string）——字段留档不消费，不渲染图标槽。
16. **`ul:before` 高度公式**（`($height-scrollList - $height-scrollList_item) * 0.5`）与 `$spacing-scrollList_item_ul-paddingBottom` 同值 132——首尾留白块共用后者（B 表留档公式原文）。

## 用法

```dart
// 滚轮选择（官方 demo 形态：上下午 + 时 + 分，两列 cycled）
SemiScrollList(
  header: const SemiText('无限滚动列表'),
  footer: SemiButton(size: SemiButtonSize.small, type: SemiButtonType.primary, child: const SemiText('Ok')),
  children: [
    SemiScrollItem(
      type: 1,
      list: const [SemiScrollItemData(value: '上午'), SemiScrollItemData(value: '下午')],
      selectedIndex: selectIndex1,
      onSelect: (sel) => setState(() => selectIndex1 = sel.index),
    ),
    SemiScrollItem(
      type: 2,
      cycled: true,
      list: [for (var h = 1; h <= 12; h++) SemiScrollItemData(value: h)],
      selectedIndex: selectIndex2,
      onSelect: (sel) => setState(() => selectIndex2 = sel.index),
    ),
  ],
)
// normal 点选列（TimePicker 列样板）
SemiScrollItem(
  mode: SemiScrollItemMode.normal,
  list: items,
  selectedIndex: index,
  onSelect: (sel) => setState(() => index = sel.index),
)
// 主题覆盖
SemiTheme(
  data: SemiThemeData.light(components: SemiComponentThemes(
    scrollList: SemiScrollListThemeData(heightScrollList: 264),
  )),
  child: const SemiScrollList(children: [/* … */]),
);
```
