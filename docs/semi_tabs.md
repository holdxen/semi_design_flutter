# SemiTabs

页签（上游 Semi Tabs 全件移植）：四形态（`line` 线条 / `card` 卡片 / `button` 按钮 / `slash` 斜线）× 三尺寸（small/medium/large）× 上/左两方向；受控/非受控选中、禁用、可关闭、图标、右侧附加内容（`tabBarExtraContent`）、保留前 N 项 + 「更多」下拉、横条滚动折叠（collapsible）、页签切换动效（200ms 位移 + 淡入）、键盘导航（箭头/Enter/Delete）。主题对账 **144 = 121 FIELDS + 23 MOTION + 0 INTERNAL**（variables.scss 121 声明：color 48、width 8、height 4、spacing 51、radius 3、font 7；animation.scss 23 声明：4 组 transition 三元组 + 3 个 transform scale + 8 个 tabPanel 动效 token；`$module`/`$ignoreIcon` 胶水与 rtl.scss 不计，datePicker `223 = 220 + 3 + 0` … steps `104 = 94 + 10 + 0`、upload `85 = 85 + 0 + 0`、skeleton `17 = 15 + 2 + 0` 先例）；★**9 死变量**（线条式页签 bg-default/-hover/-active、selected-bg、selected-icon 五个颜色声明零引用；箭头 bg-hover/active 在 tabs.scss 里被字面量 `var(--semi-color-fill-0/1)` 取代；tabPanel topShow/bottomShow 位移 keyframes 误用 leftShow/rightShow 变量做 translateY），留档不消费，docs 行标注「（上游未消费）」。

## API

`SemiTabs({tabList: const [], activeKey, defaultActiveKey, type: line, size: large, tabPosition: top, collapsible: false, more, renderMoreTrigger, tabBarExtraContent, tabPaneMotion: true, keepDOM: true, lazyRender: false, onChange, onTabClick, onTabClose})`。

tabList `List<SemiTabData>`。activeKey `String?`（非 null 即受控：点击/键盘只回调、不内部切换）。defaultActiveKey `String?`（非受控初始值；缺省首个非禁用项）。type `SemiTabsType`（line/card/button/slash）。size `SemiTabsSize`（small/medium/large）。tabPosition `SemiTabsPosition`（top/left）。collapsible `bool`（横条滚动 + 两端箭头；上游 `'auto'` 未移植，按 true 处理）。more `int?`（保留前 `length - more` 项，其余进「更多」下拉；collapsible 优先）。renderMoreTrigger `Widget Function()?`（自定义「更多」触发器）。tabBarExtraContent `Widget?`。tabPaneMotion `bool`（页签切换进入动画）。keepDOM `bool`（保留所有 pane 的 State，inactive 用 Offstage 隐藏）。lazyRender `bool`（只挂载访问过的 pane）。onChange `ValueChanged<String>?`（仅变化时）。onTabClick `ValueChanged<String>?`（每次点击，禁用不触发）。onTabClose `ValueChanged<String>?`（关闭按钮/Delete 键；不自动删项）。

`SemiTabData({required itemKey, tab, icon, disabled: false, closable: false, content})`。itemKey `String`；tab `Object?`（String | Widget）；icon `Widget?`；disabled `bool`；closable `bool`；content `Widget?`。

## 行为

### 选中

受控：`activeKey` 变化 → 记录前一键并切换（`didUpdateWidget`）；点击已选项不回调，点击其他项只 `onChange`。非受控：点击切换内部状态并 `onChange`；tabList 变化后若选中项消失/为空则回落到首个非禁用项（foundation.ts:38-57 `collectActiveKey`）。`onTabClick` 先于切换回调之后触发（index.tsx:217-226）；禁用项不响应点击、不触发 `onTabClick`。

### 关闭

`closable` 页签渲染 `IconClose`（aria-label「关闭」，`margin-left: 10px`），点击/Delete/Backspace → `onTabClose(itemKey)`；不自动从 tabList 删除（上游 notifyTabDelete 仅回调，删除由使用方改 tabList）。

### 条

- 公共：字重 regular / 选中 bold，字号 14；图标在文字前（间距 8、上移 3）；图标色 text-2 → hover text-0 → press text-0 → 选中 primary；hover/press 背景与文字色按形态；`transform: scale(1)` 恒等。
- line：条底 1px 轨道线（text/border），页签内 2px 底边（透明/hover fill-0/press fill-1/选中 primary），左右 padding 4、上下 16/14（small 8/6、medium 12/10），首项左 padding 0，项间距 24；左向：轨道线在右、选中/hover/press 用左边框 + vertical 背景（选中 primary-light-default）。
- card：条底 1px 轨道线；页签 1px 边框透明（★未选中无底边框 `border-bottom: none`）+ 顶部圆角 3（描边贴圆角弧、直角邻边 miter 对角——`SemiTabsCardPainter` 逐边填充，BoxDecoration 非均匀颜色 + 圆角会断言失败）；选中边框 border 色、底部 padding 7 + 1px 遮线带（与未选中等高 8+0 = 7+1）；hover fill-0（★选中 hover 仍 transparent）、press fill-1（★选中按下也 fill-1——`:active` 源序压过 `.tab-active`）；项间距 8（`:not(:last-of-type)`，末项不留）；左向：轨道线在右、圆角在左（★RTL 不翻转）、`border-right: none`；选中盒外内侧 1px 遮线（`::after { right: -1px }`，RTL 翻左）、等宽铺满（条边带让位 1px 内缩）、项间距（vertical）8（非末项）；★RTL quirk：`.semi-rtl` 的 `.tab` 规则把选中项边框整体刷成透明。★遮线绘制差异：上游用 bg-1（`$color-tabs_tab_card_selected-bg-default`）**盖**住轨道线，只在条坐 bg-1 时成立（灰面板上选中项底部露一条白线）；移植端以该 token 为源色 `dstOut` **擦除**轨道线（条画进独立 saveLayer 隔离擦除范围——`RepaintBoundary` 不开离屏缓冲、隔离不了混合模式），露出组件背后任意背景，bg-1 上像素级等价、非 bg-1 上比上游更正确。
- button：无边框、圆角 3、padding 8/12、项间距 8（左向底部 8，均 `:not(:last-of-type)` 末项不留）；文字 text-2；hover fill-0、press fill-1、选中底 primary-light-default + 文字 primary。
- slash：padding 12/0、项间距 16，非末项后接 1px 斜线分割（8×14、上下 3、左距 16，text-2 色）。
- 附加内容：外层 padding 0/5；line 形态高度 50（small 36）并垂直居中。

### 溢出

`collapsible` → 横条放入横向滚动容器（滚动条隐藏），两端箭头（chevron，RTL 翻转；间距 4、内边距 8、边框宽 0、禁用色、圆角 3——`.semi-button` 基座 `$radius-button`）按滚动位置启用，点击滚动 80px。`more: n` → 只渲染前 `length - n` 项，尾部「更多」触发器（text-2 色 + chevron-down，图标外边距 8/8/0/0，形态同页签 padding）hover 弹出 SemiDropdown，列表最大高 300（可滚动），行高 32、padding 8/12、hover fill-0、选中 primary + 加粗 + tick；点击行切换。`collapsible` 与 `more` 同时给时 collapsible 优先（TabBar.tsx render）。

### 内容

pane 文本色 text-0；内容区 padding 上下 5 / 左右 0（左向改为左右 5 / 上下 0）。`keepDOM: false` 只挂载当前 pane；`lazyRender: true` 只挂载访问过的 pane；其余用 `Offstage` + `TickerMode` 隐藏（对应 `display: none`）。切换动效：进入 pane 用 200ms、ease-in-out、延迟 0 的位移（上向左右 60 / -60；左向上下 60 / -60——★上游 topShow/bottomShow keyframes 实际引用 leftShow/rightShow）与透明度 0→1，`fill-mode: forwards`；无离开动画。

### 键盘 / RTL

条内每项是焦点节点：左右/上下箭头移动焦点（RTL 左右互换、首尾环绕）、Enter/Space 选中、Delete/Backspace 关闭可关闭项、Home/End 首尾（foundation.ts:76-132）。焦点环用 2px 前景内描边（outline offset -1/-2 近似），走 `:focus-visible` 门控（`_keyboardUsed`：任意按键置位、按下页签清位）——键盘聚焦才画，点击聚焦不画。RTL：Directionality 翻转项顺序/内边距/外边距，图标间距左右互换，箭头图标方向对调（scaleX(-1) 等价），左向轨道线换边。

## 主题（144 对账）

来源 packages/semi-foundation/tabs/variables.scss（121 声明）+ animation.scss（23 声明）。对账 **144 = 121 FIELDS + 23 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表）。★**9 死变量**。全局 token 解析：`var(--semi-color-*)` → `theme.colors.colorBorder/colorText0/colorText2/colorFill0/colorFill1/colorPrimary/colorPrimaryLightDefault/colorPrimaryLightActive/colorDisabledText/colorBg1`，`transparent` → `const Color(0x00000000)`；引用 token：`$font-weight-regular/bold` → `theme.typography.fontWeightRegular/Bold`、`$border-thickness-control` → 1、`$spacing-extra-tight/tight/base-tight/base/loose` → 4/8/12/16/24、`$font-size-regular` → 14、`var(--semi-border-radius-small)` → `theme.radius.borderRadiusSmall.value`（= 3）；四值圆角 token 展开为 `BorderRadius`（顶部两角 / 左侧两角）；动画 token：`Duration.zero`、`Duration(milliseconds: 200)`、`Curves.easeIn`、`Curves.easeInOut`、`const SemiTransform.scale(1, 1)`、位移 60 / -60、透明度 0。类型覆盖：**48 Color + 2 FontWeight + 69 double + 2 BorderRadius = 121 FIELDS**；MOTION **10 Duration + 5 Curve + 3 SemiTransform + 5 double = 23**。解析列即 `SemiTabsThemeData.resolve` 默认表达式。

### A. Sass 声明映射（121 FIELDS + 23 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-tabs_tab_line_default-border-default: var(--semi-color-border)` | `colorTabsTabLineDefaultBorderDefault` | `theme.colors.colorBorder` |
| `$color-tabs_tab_line_default-bg-default: transparent` | `colorTabsTabLineDefaultBgDefault` | `const Color(0x00000000)`（**上游未消费**） |
| `$color-tabs_tab_line_default-text-default: var(--semi-color-text-2)` | `colorTabsTabLineDefaultTextDefault` | `theme.colors.colorText2` |
| `$color-tabs_tab_line_default-bg-hover: transparent` | `colorTabsTabLineDefaultBgHover` | `const Color(0x00000000)`（**上游未消费**） |
| `$color-tabs_tab_line_default-text-hover: var(--semi-color-text-0)` | `colorTabsTabLineDefaultTextHover` | `theme.colors.colorText0` |
| `$color-tabs_tab_line_default-border-hover: var(--semi-color-fill-0)` | `colorTabsTabLineDefaultBorderHover` | `theme.colors.colorFill0` |
| `$color-tabs_tab_line_default-bg-active: transparent` | `colorTabsTabLineDefaultBgActive` | `const Color(0x00000000)`（**上游未消费**） |
| `$color-tabs_tab_line_default-text-active: var(--semi-color-text-0)` | `colorTabsTabLineDefaultTextActive` | `theme.colors.colorText0` |
| `$color-tabs_tab_line_default-border-active: var(--semi-color-fill-1)` | `colorTabsTabLineDefaultBorderActive` | `theme.colors.colorFill1` |
| `$color-tabs_tab_line_selected-bg-default: transparent` | `colorTabsTabLineSelectedBgDefault` | `const Color(0x00000000)`（**上游未消费**） |
| `$color-tabs_tab_line_selected-text-default: var(--semi-color-text-0)` | `colorTabsTabLineSelectedTextDefault` | `theme.colors.colorText0` |
| `$color-tabs_tab_line_indicator_selected-icon-default: var(--semi-color-primary)` | `colorTabsTabLineIndicatorSelectedIconDefault` | `theme.colors.colorPrimary` |
| `$color-tabs_tab_line_selected-icon-default: var(--semi-color-primary)` | `colorTabsTabLineSelectedIconDefault` | `theme.colors.colorPrimary`（**上游未消费**） |
| `$color-tabs_tab_line_vertical_selected-bg-default: var(--semi-color-primary-light-default)` | `colorTabsTabLineVerticalSelectedBgDefault` | `theme.colors.colorPrimaryLightDefault` |
| `$color-tabs_tab_line_vertical-bg-hover: var(--semi-color-fill-0)` | `colorTabsTabLineVerticalBgHover` | `theme.colors.colorFill0` |
| `$color-tabs_tab_line_vertical-bg-active: var(--semi-color-fill-1)` | `colorTabsTabLineVerticalBgActive` | `theme.colors.colorFill1` |
| `$color-tabs_tab_line_disabled-text-default: var(--semi-color-disabled-text)` | `colorTabsTabLineDisabledTextDefault` | `theme.colors.colorDisabledText` |
| `$color-tabs_tab_line_disabled-text-hover: var(--semi-color-disabled-text)` | `colorTabsTabLineDisabledTextHover` | `theme.colors.colorDisabledText` |
| `$color-tabs_tab_card_default-border-default: var(--semi-color-border)` | `colorTabsTabCardDefaultBorderDefault` | `theme.colors.colorBorder` |
| `$color-tabs_tab_button_selected-bg-default: var(--semi-color-primary-light-default)` | `colorTabsTabButtonSelectedBgDefault` | `theme.colors.colorPrimaryLightDefault` |
| `$color-tabs_tab_button_selected-text-default: var(--semi-color-primary)` | `colorTabsTabButtonSelectedTextDefault` | `theme.colors.colorPrimary` |
| `$color-tabs_tab_button-text-default: var(--semi-color-text-2)` | `colorTabsTabButtonTextDefault` | `theme.colors.colorText2` |
| `$color-tabs_tab_button-bg-hover: var(--semi-color-fill-0)` | `colorTabsTabButtonBgHover` | `theme.colors.colorFill0` |
| `$color-tabs_tab_button-bg-active: var(--semi-color-fill-1)` | `colorTabsTabButtonBgActive` | `theme.colors.colorFill1` |
| `$color-tabs_tab_card_indicator_selected-icon-default: var(--semi-color-border)` | `colorTabsTabCardIndicatorSelectedIconDefault` | `theme.colors.colorBorder` |
| `$color-tabs_tab_card-bg-hover: var(--semi-color-fill-0)` | `colorTabsTabCardBgHover` | `theme.colors.colorFill0` |
| `$color-tabs_tab_card_selected-bg-default: var(--semi-color-bg-1)` | `colorTabsTabCardSelectedBgDefault` | `theme.colors.colorBg1` |
| `$color-tabs_tab_card-bg-active: var(--semi-color-fill-1)` | `colorTabsTabCardBgActive` | `theme.colors.colorFill1` |
| `$color-tabs_tab-icon-default: var(--semi-color-text-2)` | `colorTabsTabIconDefault` | `theme.colors.colorText2` |
| `$color-tabs_tab-icon-hover: var(--semi-color-text-0)` | `colorTabsTabIconHover` | `theme.colors.colorText0` |
| `$color-tabs_tab-icon-active: var(--semi-color-text-0)` | `colorTabsTabIconActive` | `theme.colors.colorText0` |
| `$color-tabs_tab_selected-icon-default: var(--semi-color-primary)` | `colorTabsTabSelectedIconDefault` | `theme.colors.colorPrimary` |
| `$color-tabs_tab-outline-focus: var(--semi-color-primary-light-active)` | `colorTabsTabOutlineFocus` | `theme.colors.colorPrimaryLightActive` |
| `$color-tabs_tab-pane-text-default: var(--semi-color-text-0)` | `colorTabsTabPaneTextDefault` | `theme.colors.colorText0` |
| `$color-tabs_tab-pane_arrow-text-default: var(--semi-color-primary)` | `colorTabsTabPaneArrowTextDefault` | `theme.colors.colorPrimary` |
| `$color-tabs_tab-pane_arrow-border-default: transparent` | `colorTabsTabPaneArrowBorderDefault` | `const Color(0x00000000)` |
| `$color-tabs_tab-pane_arrow-bg-default:transparent` | `colorTabsTabPaneArrowBgDefault` | `const Color(0x00000000)` |
| `$color-tabs_tab-pane_arrow-text-hover: var(--semi-color-primary)` | `colorTabsTabPaneArrowTextHover` | `theme.colors.colorPrimary` |
| `$color-tabs_tab-pane_arrow-border-hover: transparent` | `colorTabsTabPaneArrowBorderHover` | `const Color(0x00000000)` |
| `$color-tabs_tab-pane_arrow-bg-hover: var(--semi-color-fill-0)` | `colorTabsTabPaneArrowBgHover` | `theme.colors.colorFill0`（**上游未消费**） |
| `$color-tabs_tab-pane_arrow-text-active: var(--semi-color-primary)` | `colorTabsTabPaneArrowTextActive` | `theme.colors.colorPrimary` |
| `$color-tabs_tab-pane_arrow-border-active: transparent` | `colorTabsTabPaneArrowBorderActive` | `const Color(0x00000000)` |
| `$color-tabs_tab-pane_arrow-bg-active: var(--semi-color-fill-1)` | `colorTabsTabPaneArrowBgActive` | `theme.colors.colorFill1`（**上游未消费**） |
| `$color-tabs_tab-pane_arrow_disabled-bg-default: transparent` | `colorTabsTabPaneArrowDisabledBgDefault` | `const Color(0x00000000)` |
| `$color-tabs_tab-pane_arrow_disabled-bg-hover:  transparent` | `colorTabsTabPaneArrowDisabledBgHover` | `const Color(0x00000000)` |
| `$color-tabs_tab-pane_arrow_disabled-text-default: var(--semi-color-disabled-text)` | `colorTabsTabPaneArrowDisabledTextDefault` | `theme.colors.colorDisabledText` |
| `$color-tabs_tab-pane_arrow_disabled-text-hover:  var(--semi-color-disabled-text)` | `colorTabsTabPaneArrowDisabledTextHover` | `theme.colors.colorDisabledText` |
| `$color-tabs_tab_slash_line: var(--semi-color-text-2)` | `colorTabsTabSlashLine` | `theme.colors.colorText2` |
| `$font-tabs_tab-fontWeight: $font-weight-regular` | `fontTabsTabFontWeight` | `theme.typography.fontWeightRegular` |
| `$font-tabs_tab_active-fontWeight: $font-weight-bold` | `fontTabsTabActiveFontWeight` | `theme.typography.fontWeightBold` |
| `$height-tabs_overflow_list: 300px` | `heightTabsOverflowList` | `300` |
| `$width-tabs_bar_line-border: $border-thickness-control` | `widthTabsBarLineBorder` | `1` |
| `$width-tabs_bar_line_tab-border: 2px` | `widthTabsBarLineTabBorder` | `2` |
| `$width-tabs_bar_card-border: $border-thickness-control` | `widthTabsBarCardBorder` | `1` |
| `$width-tabs-outline: 2px` | `widthTabsOutline` | `2` |
| `$width-tabs-outline-offset: -2px` | `widthTabsOutlineOffset` | `-2` |
| `$width-tabs_bar_line-outline-offset: -1px` | `widthTabsBarLineOutlineOffset` | `-1` |
| `$width-tabs_tab-pane_arrow-border:0px` | `widthTabsTabPaneArrowBorder` | `0` |
| `$width-tabs_tab_slash_line: 8px` | `widthTabsTabSlashLine` | `8` |
| `$height-tabs_tab_slash_line: 14px` | `heightTabsTabSlashLine` | `14` |
| `$height-tabs_bar_extra_large: 50px` | `heightTabsBarExtraLarge` | `50` |
| `$font-tabs_bar_extra_large-lineHeight: $height-tabs_bar_extra_large` | `fontTabsBarExtraLargeLineHeight` | `50` |
| `$height-tabs_bar_extra_small: 36px` | `heightTabsBarExtraSmall` | `36` |
| `$font-tabs_bar_extra_small-lineHeight: $height-tabs_bar_extra_small` | `fontTabsBarExtraSmallLineHeight` | `36` |
| `$spacing-tabs_tab-more_trigger_icon-marginLeft: 8px` | `spacingTabsTabMoreTriggerIconMarginLeft` | `8` |
| `$spacing-tabs_tab-more_trigger_icon-marginRight: 8px` | `spacingTabsTabMoreTriggerIconMarginRight` | `8` |
| `$spacing-tabs_tab-more_trigger_icon-marginTop: 0px` | `spacingTabsTabMoreTriggerIconMarginTop` | `0` |
| `$spacing-tabs_tab-more_trigger_icon-marginBottom: 0px` | `spacingTabsTabMoreTriggerIconMarginBottom` | `0` |
| `$spacing-tabs_tab-pane_arrow: 8px` | `spacingTabsTabPaneArrow` | `8` |
| `$spacing-tabs_bar_extra-paddingY: 0px` | `spacingTabsBarExtraPaddingY` | `0` |
| `$spacing-tabs_bar_extra-paddingX: 5px` | `spacingTabsBarExtraPaddingX` | `5` |
| `$spacing-tabs_tab_icon-marginRight: $spacing-tight` | `spacingTabsTabIconMarginRight` | `8` |
| `$spacing-tabs_tab_icon-top: 3px` | `spacingTabsTabIconTop` | `3` |
| `$spacing-tabs_overflow_icon-marginRight: 4px` | `spacingTabsOverflowIconMarginRight` | `4` |
| `$spacing-tabs_overflow_icon-marginLeft: 4px` | `spacingTabsOverflowIconMarginLeft` | `4` |
| `$spacing-tabs_bar_line_tab-paddingTop: $spacing-base` | `spacingTabsBarLineTabPaddingTop` | `16` |
| `$spacing-tabs_bar_line_tab-paddingRight: $spacing-extra-tight` | `spacingTabsBarLineTabPaddingRight` | `4` |
| `$spacing-tabs_bar_line_tab-paddingBottom: $spacing-base - $width-tabs_bar_line_tab-border` | `spacingTabsBarLineTabPaddingBottom` | `14` |
| `$spacing-tabs_bar_line_tab-paddingLeft: $spacing-extra-tight` | `spacingTabsBarLineTabPaddingLeft` | `4` |
| `$spacing-tabs_bar_line_tab-marginRight: $spacing-loose` | `spacingTabsBarLineTabMarginRight` | `24` |
| `$spacing-tabs_bar_line_tab_small-paddingTop: $spacing-tight` | `spacingTabsBarLineTabSmallPaddingTop` | `8` |
| `$spacing-tabs_bar_line_tab_small-paddingRight: $spacing-extra-tight` | `spacingTabsBarLineTabSmallPaddingRight` | `4` |
| `$spacing-tabs_bar_line_tab_small-paddingBottom: $spacing-tight - $width-tabs_bar_line_tab-border` | `spacingTabsBarLineTabSmallPaddingBottom` | `6` |
| `$spacing-tabs_bar_line_tab_small-paddingLeft: $spacing-extra-tight` | `spacingTabsBarLineTabSmallPaddingLeft` | `4` |
| `$spacing-tabs_bar_line_tab_medium-paddingTop: $spacing-base-tight` | `spacingTabsBarLineTabMediumPaddingTop` | `12` |
| `$spacing-tabs_bar_line_tab_medium-paddingRight: $spacing-extra-tight` | `spacingTabsBarLineTabMediumPaddingRight` | `4` |
| `$spacing-tabs_bar_line_tab_medium-paddingBottom: $spacing-base-tight - $width-tabs_bar_line_tab-border` | `spacingTabsBarLineTabMediumPaddingBottom` | `10` |
| `$spacing-tabs_bar_line_tab_medium-paddingLeft: $spacing-extra-tight` | `spacingTabsBarLineTabMediumPaddingLeft` | `4` |
| `$spacing-tabs_bar_line_tab_left-padding: 12px` | `spacingTabsBarLineTabLeftPadding` | `12` |
| `$spacing-tabs_bar_line_tab_left_small-padding: $spacing-tight - 2px` | `spacingTabsBarLineTabLeftSmallPadding` | `6` |
| `$spacing-tabs_bar_line_tab_left_medium-padding: $spacing-base-tight - 2px` | `spacingTabsBarLineTabLeftMediumPadding` | `10` |
| `$spacing-tabs_bar_slash_tab-paddingY: 12px` | `spacingTabsBarSlashTabPaddingY` | `12` |
| `$spacing-tabs_bar_slash_tab-paddingX: 0px` | `spacingTabsBarSlashTabPaddingX` | `0` |
| `$spacing-tabs_bar_slash-marginRight: 16px` | `spacingTabsBarSlashMarginRight` | `16` |
| `$spacing-tabs_bar_slash_line_marginLeft: 16px` | `spacingTabsBarSlashLineMarginLeft` | `16` |
| `$spacing-tabs_bar_slash_line_marginTop: 3px` | `spacingTabsBarSlashLineMarginTop` | `3` |
| `$spacing-tabs_bar_slash_line_marginBottom: 3px` | `spacingTabsBarSlashLineMarginBottom` | `3` |
| `$spacing-tabs_content-paddingY: 5px` | `spacingTabsContentPaddingY` | `5` |
| `$spacing-tabs_content-paddingX: 0` | `spacingTabsContentPaddingX` | `0` |
| `$spacing-tabs_content_left-paddingX: 5px` | `spacingTabsContentLeftPaddingX` | `5` |
| `$spacing-tabs_content_left-paddingY: 0` | `spacingTabsContentLeftPaddingY` | `0` |
| `$spacing-tabs_bar_card_tab-marginRight: $spacing-tight` | `spacingTabsBarCardTabMarginRight` | `8` |
| `$spacing-tabs_bar_card_tab_active-paddingTop: $spacing-tight` | `spacingTabsBarCardTabActivePaddingTop` | `8` |
| `$spacing-tabs_bar_card_tab_active-paddingBottom: $spacing-tight - 1px` | `spacingTabsBarCardTabActivePaddingBottom` | `7` |
| `$spacing-tabs_bar_card_tab_active-paddingLeft: $spacing-base-tight` | `spacingTabsBarCardTabActivePaddingLeft` | `12` |
| `$spacing-tabs_bar_card_tab_active-paddingRight: $spacing-base-tight` | `spacingTabsBarCardTabActivePaddingRight` | `12` |
| `$spacing-tabs_bar_card_tab_left-marginBottom: $spacing-tight` | `spacingTabsBarCardTabLeftMarginBottom` | `8` |
| `$spacing-tabs_bar_card_tab_left_active-paddingY: $spacing-tight` | `spacingTabsBarCardTabLeftActivePaddingY` | `8` |
| `$spacing-tabs_bar_card_tab_left_active-paddingX: $spacing-base-tight` | `spacingTabsBarCardTabLeftActivePaddingX` | `12` |
| `$spacing-tabs_bar_card_tab-paddingY: $spacing-tight` | `spacingTabsBarCardTabPaddingY` | `8` |
| `$spacing-tabs_bar_card_tab-paddingX: $spacing-base-tight` | `spacingTabsBarCardTabPaddingX` | `12` |
| `$spacing-tabs_bar_button_tab_left-marginBottom: $spacing-tight` | `spacingTabsBarButtonTabLeftMarginBottom` | `8` |
| `$spacing-tabs_bar_button_tab-marginRight: $spacing-tight` | `spacingTabsBarButtonTabMarginRight` | `8` |
| `$spacing-tabs_bar_button_tab-paddingY: $spacing-tight` | `spacingTabsBarButtonTabPaddingY` | `8` |
| `$spacing-tabs_bar_button_tab-paddingX: $spacing-base-tight` | `spacingTabsBarButtonTabPaddingX` | `12` |
| `$radius-tabs_tab_card: var(--semi-border-radius-small) var(--semi-border-radius-small) 0 0` | `radiusTabsTabCard` | `BorderRadius.vertical(top: Radius.circular(theme.radius.borderRadiusSmall.value))` |
| `$radius-tabs_tab_card_left: var(--semi-border-radius-small) 0 0 var(--semi-border-radius-small)` | `radiusTabsTabCardLeft` | `BorderRadius.horizontal(left: Radius.circular(theme.radius.borderRadiusSmall.value))` |
| `$radius-tabs_tab_button: var(--semi-border-radius-small)` | `radiusTabsTabButton` | `theme.radius.borderRadiusSmall.value` |
| `$font-tabs_bar_large-fontSize: $font-size-regular` | `fontTabsBarLargeFontSize` | `14` |
| `$font-tabs_bar_small-fontSize: $font-size-regular` | `fontTabsBarSmallFontSize` | `14` |
| `$font-tabs_bar_medium-fontSize: $font-size-regular` | `fontTabsBarMediumFontSize` | `14` |
| `$transition_duration-tabs_tab_line-border: var(--semi-transition_duration-none)` | `transitionDurationTabsTabLineBorder` | `Duration.zero` |
| `$transition_function-tabs_tab_line-border: var(--semi-transition_function-easeIn)` | `transitionFunctionTabsTabLineBorder` | `Curves.easeIn` |
| `$transition_delay-tabs_tab_line-border: var(--semi-transition_delay-none)` | `transitionDelayTabsTabLineBorder` | `Duration.zero` |
| `$transition_duration-tabs_tab_line-text: var(--semi-transition_duration-none)` | `transitionDurationTabsTabLineText` | `Duration.zero` |
| `$transition_function-tabs_tab_line-text: var(--semi-transition_function-easeIn)` | `transitionFunctionTabsTabLineText` | `Curves.easeIn` |
| `$transition_delay-tabs_tab_line-text: var(--semi-transition_delay-none)` | `transitionDelayTabsTabLineText` | `Duration.zero` |
| `$transition_duration-tabs_tab_button-bg: var(--semi-transition_duration-none)` | `transitionDurationTabsTabButtonBg` | `Duration.zero` |
| `$transition_function-tabs_tab_button-bg: var(--semi-transition_function-easeIn)` | `transitionFunctionTabsTabButtonBg` | `Curves.easeIn` |
| `$transition_delay-tabs_tab_button-bg: var(--semi-transition_delay-none)` | `transitionDelayTabsTabButtonBg` | `Duration.zero` |
| `$transition_duration-tabs_tab_card-bg: var(--semi-transition_duration-none)` | `transitionDurationTabsTabCardBg` | `Duration.zero` |
| `$transition_function-tabs_tab_card-bg: var(--semi-transition_function-easeIn)` | `transitionFunctionTabsTabCardBg` | `Curves.easeIn` |
| `$transition_delay-tabs_tab_card-bg: var(--semi-transition_delay-none)` | `transitionDelayTabsTabCardBg` | `Duration.zero` |
| `$transform_scale-tabs_tab_line-item: var(--semi-transform_scale-none)` | `transformScaleTabsTabLineItem` | `const SemiTransform.scale(1, 1)` |
| `$transform_scale-tabs_tab_button-item: var(--semi-transform_scale-none)` | `transformScaleTabsTabButtonItem` | `const SemiTransform.scale(1, 1)` |
| `$transform_scale-tabs_tab_card-item: var(--semi-transform_scale-none)` | `transformScaleTabsTabCardItem` | `const SemiTransform.scale(1, 1)` |
| `$animation_transform_translateX-tabs_tabPanel-leftShow: 60px` | `animationTransformTranslateXTabsTabPanelLeftShow` | `60` |
| `$animation_transform_translateX-tabs_tabPanel-rightShow: -60px` | `animationTransformTranslateXTabsTabPanelRightShow` | `-60` |
| `$animation_transform_translateX-tabs_tabPanel-topShow: 60px` | `animationTransformTranslateXTabsTabPanelTopShow` | `60`（**上游未消费**） |
| `$animation_transform_translateX-tabs_tabPanel-bottomShow: -60px` | `animationTransformTranslateXTabsTabPanelBottomShow` | `-60`（**上游未消费**） |
| `$animation_opacity-tabs_tabPanel_show: 0` | `animationOpacityTabsTabPanelShow` | `0` |
| `$animation_duration-tabs_tabPanel-show: 200ms` | `animationDurationTabsTabPanelShow` | `const Duration(milliseconds: 200)` |
| `$animation_function-tabs_tabPanel-show: ease-in-out` | `animationFunctionTabsTabPanelShow` | `Curves.easeInOut` |
| `$animation_delay-tabs_tabPanel-show: 0s` | `animationDelayTabsTabPanelShow` | `Duration.zero` |

### B. HARDCODES 另列（widget 文件头注释 / 调用点，源内含原始片段）

| 上游片段 | 说明 |
|---|---|
| index.tsx `showRestInDropdown = true` | 折叠下拉缺省级 |
| index.tsx `arrowPosition = 'both'` | 两端箭头 |
| constants.ts `DEFAULT_ACTIVE_KEY: 1` | 缺省键常量 |
| locale `more: '更多'` / `close: '关闭'` | zh_CN 文案 |
| `IconChevronDown` / `IconChevronLeft` / `IconChevronRight` / `IconClose` | 下拉/箭头/关闭图标 |
| `data-tabkey` / `aria-selected` | 页签数据/语义属性 |
| `tabIndex={selected ? 0 : -1}` | 只有选中项可 Tab 聚焦 |
| `semi-tabs-pane-motion-overlay` | pane 动效包裹层 |
| `@include font-size-regular` | 页签字号 14 |
| `:nth-of-type(1)` | 首项 padding 置 0 |
| `margin-left: 10px` | 关闭图标左边距 |
| `transform: scaleX(-1)` | RTL 箭头翻转 |
| `translateY($animation_transform_translateX-tabs_tabPanel-leftShow)` | topShow/bottomShow 误用 left/right 变量（quirk） |
| `animation-fill-mode: forwards` | 动效结束保持 |
| `linear-gradient(to bottom right` | slash 斜线分割 |
| `overflow-y: auto` | 更多下拉可滚动 |
| `content: ""` | slash 伪元素 |
| `width: 1px` | 卡片左侧选中遮线 |

## 差异清单

- **collapsible**：Flutter 端为「横向滚动 + 两端箭头（点击滚 80px）」，上游是 OverflowList 溢出测量 + 箭头 hover 下拉列出隐藏项；`'auto'` 未移植（等价 true）。滚动条隐藏（`copyWith(scrollbars: false)`，上游无滚动条；桌面端 ScrollBehavior 默认会自动加 RawScrollbar）。
- **more**：支持 `int` + `renderMoreTrigger`；上游 `more.dropdownProps` 未移植（SemiDropdown 无透传）。
- **未移植 API**：`className`/`style`/`contentStyle`/`tabBarStyle`/`tabBarClassName`/`renderTabBar`/`onVisibleTabsChange`/`visibleTabsStyle`/`renderArrow`/`arrowPosition`/`dropdownProps`/`preventScroll`——Flutter 由外层布局与主题承担。
- **动效**：CSS enter animation → Flutter 单次进入动画（无 leave）；`AnimatedContainer` 无 delay 参数，4 个 transition delay 字段留档未消费（默认 0ms）；`fill-mode: forwards` 由动画停在 1 表达。
- **键盘**：箭头在焦点节点间移动（与上游一致），但 Flutter 只有点击后才进入焦点链；Delete 关闭后不自动聚焦相邻项（上游会）。
- **关闭**：不自动删项（与上游一致）；关闭图标点击不冒泡到选中。
- **左向内容**：CSS `height: 100%` 在 Flutter 为自适应高度（父级 Row 拉伸决定）。
- **slash 分割线**：CSS 渐变斜线 → 1px `CustomPaint` 线（像素级近似）。
- **焦点环**：outline + offset → 前景内描边（2px，紧贴边框）；`:focus-visible` 门控（`_keyboardUsed` 先例），鼠标点击聚焦不画环。
- **卡片遮线**：左向 `::after { right: -1px }`（RTL `left: -1px`）外贴条 → 盒内 1px bg-1 边叠画（条轨道线是 `DecoratedBox` 边框、画在子项之下）；左向 flex column stretch 等宽 → `IntrinsicWidth` + `CrossAxisAlignment.stretch` 近似。

## 用法

```dart
SemiTabs(
  tabList: const [
    SemiTabData(itemKey: '1', tab: '文档', content: Text('文档内容')),
    SemiTabData(itemKey: '2', tab: '设计', closable: true, content: Text('设计内容')),
    SemiTabData(itemKey: '3', tab: '禁用', disabled: true, content: Text('禁用内容')),
  ],
  type: SemiTabsType.line,
  onChange: (key) => print(key),
  onTabClose: (key) => print('close $key'),
)
```

```dart
SemiTabs(
  tabList: tabs,
  type: SemiTabsType.card,
  size: SemiTabsSize.small,
  tabPosition: SemiTabsPosition.left,
  tabPaneMotion: false,
  tabBarExtraContent: SemiButton('操作'),
)
```
