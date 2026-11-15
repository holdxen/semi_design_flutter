# SemiNavigation

导航菜单（上游 Semi Navigation 全件移植）：三模式菜单——vertical（240px 侧边栏，Sub 内联折叠展开）/ collapsed（60px 侧边栏，条目 Tooltip + Sub 弹层菜单）/ horizontal（60px 高顶栏，Sub 全走弹层）。items 模型（`String | SemiNavigationItem` 混排，String 归一化 NavItem.ts:12-24；有 `items` 即 Sub 递归）。选中（itemFoundation.ts:67-96 + index.tsx:252-258）：单选替换；★已选中再点**不触发 onSelect 不移除**；★选中子项自动附一级父 key（`selectLevelZeroParentKeys`，foundation.ts:210-229——Sub 标题亮 selected，父 key 只进内部 state/视觉不进 onSelect 载荷）；selectedKeys 非空即受控。展开（subNavFoundation.ts:97-125 + index.tsx:407）：★openKeys 受控**仅 vertical 未折叠生效**（quirk）；无 openKeys/defaultOpenKeys 输入且 vertical 时自动展开选中项祖先（foundation.ts:174-188 `getWillOpenKeys`）；Sub 标题点击 toggle + onOpenChange + onClick。主题对账 **122 = 119 FIELDS + 3 MOTION + 0 INTERNAL**（variables.scss 120 声明 = 119 token + `$module` 胶水不计 + animation.scss 3 亲验——datePicker `223 = 220 + 3 + 0`、timePicker `20 = 14 + 6 + 0`、transfer `50 = 47 + 3 + 0`、anchor `30 = 26 + 4 + 0`、breadcrumb `20 = 16 + 4 + 0` 先例）；★**10 死变量（迄今最多）**——真死 9 + 事实死 1，留档不消费（落 theme + `# dead variable (上游未消费)` + docs「（上游未消费）」+ widget assertNotIn 字段名）。

## API

`SemiNavigation({items: const [], mode: SemiNavigationMode.vertical, selectedKeys, defaultSelectedKeys, openKeys, defaultOpenKeys, isCollapsed, defaultIsCollapsed, onSelect, onOpenChange, onCollapseChange, onClick, header, footer, limitIndent: true, toggleIconPosition: SemiNavigationToggleIconPosition.right, expandIcon, subNavMotion: true})`。

items `List<Object>`（`String | SemiNavigationItem` 混排——String 自动包装 `{text, itemKey}`，NavItem.ts:12-24；递归 items）。mode `SemiNavigationMode.vertical`（| horizontal，constants.ts:3-4）。selectedKeys/defaultSelectedKeys `List<Object>?`（非空即受控；key 合法域 String | int——★0 合法 quirk）。openKeys/defaultOpenKeys `List<Object>?`（★受控仅 vertical 未折叠生效——index.tsx:407 quirk）。isCollapsed/defaultIsCollapsed `bool?`（非空即受控）。onSelect `void Function(SemiNavigationSelectInfo)?`（★已选中再点不触发；载荷 `selectedKeys = [itemKey]` 不含自动附父 key——itemFoundation.ts:83）。onOpenChange `void Function(SemiNavigationOpenInfo)?`。onCollapseChange `ValueChanged<bool>?`（回传新值）。onClick `void Function(SemiNavigationClickInfo)?`（★item/sub 两路 payload 不一致）。header `SemiNavigationHeader?`、footer `SemiNavigationFooter?`。limitIndent `true`（true=子级统一 44px 缩进；false=按 indent 参数占位缩进）。toggleIconPosition `SemiNavigationToggleIconPosition.right`（| left）。expandIcon `Widget?`（自定义 Sub 展开图标，缺省 chevron_down）。subNavMotion `true`（Sub 内联展开高度+fade 动画；false 瞬时）。

`SemiNavigationItem({required itemKey, text, icon, link, disabled = false, indent, items})`：itemKey `Object`（String | int，必填；★0 合法——foundation.ts:79 `??` 判定 quirk）、text `Object?`（String | Widget）、icon `Widget?`、link `String?`（href 元数据，不导航）、disabled `false`、indent `Object?`（bool | int——JS truthy 语义、★int 0 falsy quirk，仅 limitIndent=false 消费）、items `List<Object>?`（`String | SemiNavigationItem` 递归）。

`SemiNavigationHeader({logo, text, link})`：logo `Widget?`（36×36，scale-down）、text `Object?`（String | Widget，collapsed 隐）、link `String?`（元数据）。

`SemiNavigationFooter({collapseButton = false, collapseText, onClick, child})`：collapseButton `false`（★horizontal 不渲染——Footer.tsx:64 quirk）、collapseText `String?`（collapsed=>String 或固定串；上游 `(collapsed) => ReactNode` 函数形态收敛——缺省 locale）、onClick `VoidCallback?`（wrapper 点击）、child `Widget?`（非空优先于 collapseButton）。

载荷：`SemiNavigationSelectInfo({itemKey, selectedKeys, text})`、`SemiNavigationOpenInfo({itemKey, openKeys, isOpen})`、`SemiNavigationClickInfo({itemKey, text, openKeys, isOpen})`（★item 路发 `{itemKey, text}`、sub 路发 `{itemKey, openKeys, isOpen}`，可空字段并存；上游声明 `{itemKey, domEvent, isOpen}`（foundation.ts:12-16）与实际不符留档）。

## 行为

### items 与选中

items 归一化（NavItem.ts:12-24）：String 条目 → `{text, itemKey}`（同一字符串）；`SemiNavigationItem` 原样；嵌套 items 递归归一化（一层或多层）。选中（itemFoundation.ts:67-96）：点击非 disabled 条目 → 单选替换（含自动附的一级父 key）；★已选中再点**不触发 onSelect 不移除**；★选中子项自动附一级父 key（`selectLevelZeroParentKeys`——Sub 标题亮 selected，父 key 只进内部 state/视觉，不进 onSelect 载荷）；selectedKeys 非空即受控（受控时点击只发 onSelect 由应用改 props）；★numeric 0 值 key 合法（foundation.ts:79 `??` 判定 quirk，不做 falsy 丢弃）；disabled 条目点击/键盘均不响应（itemFoundation.ts:70-72）。

### 展开与 Sub

Sub 标题点击 toggle（subNavFoundation.ts:97-125）：openKeys add/remove + onOpenChange + onClick（sub 路 payload）；★openKeys 受控**仅 vertical 未折叠生效**（index.tsx:407 `isControlled('openKeys') && mode === 'vertical' && !isCollapsed` quirk——collapsed/horizontal 弹层可见性也走 onOpenChange 但内部 state 照更）；无 openKeys/defaultOpenKeys 输入且 vertical 时自动展开选中项祖先（foundation.ts:174-188 `getWillOpenKeys`——selectedKeys props 变更时重算）；chevron 旋转 `transform 200ms ease-in-out`（nav:343-350 硬编码，subNavMotion 开启且 vertical 才旋转——horizontal 不旋转 fix#1198 SubNav.tsx:217-218）。

### 三模式

vertical（240px，nav:5-11）：Sub 内联折叠展开（subNavMotion true → 高度+fade 动画（上游 Collapsible，无 token——200ms 近似）；false 瞬时）。collapsed（60px，nav:49-74）：文字/尾图标 opacity 渐隐（`$motion-navigation_collapsed_opacity` 消费 + `opacity: 0`/`opacity: 1`）、平铺 item 包 `SemiTooltip(position: right)`（Item.tsx:294-296，disabled Sub 同）、Sub 标题悬停出弹层菜单、header 隐 text logo 居中、footer 收起按钮（locale「收起侧边栏/展开侧边栏」+ 折叠 icon-only tooltip）。horizontal（高 60，nav:592-725）：一行排布、Sub 全走弹层（bottomLeft 位置语义，SubNav.tsx:336）、★footer 不渲染 collapseButton（Footer.tsx:64 quirk）。

### 弹层菜单

collapsed/horizontal 的 Sub 走 SemiDropdown content 自绘列表（★自决点：SemiDropdownItemData menu 形态承载不了 nav item 六态色与 min-width 150——取 content 自绘；嵌套 Sub 由 SemiDropdown 的 pointer-exempt scope 接住，SemiOverlayPointerExemptScope 先例）。弹层项 min-width `widthNavigationDropdownItemNavItemMinWidth`（150）；位置 horizontal 顶层 bottomLeft、其余 rightTop；延迟 `SUBNAV_OPEN_DELAY: 0`/`SUBNAV_CLOSE_DELAY: 100`（constants.ts）；弹层可见性变更走 onOpenChange（不发 onClick——subNavFoundation.ts:71-90）。

### 视觉与 RTL

条目行盒（nav:76-110）：高 36、padding X12/Y8、margin-bottom 8（末位 0）、圆角 3（`$width-navigation_item-borderRadius` ★名宽实圆角 quirk）、图标槽 min-width 20 + 间距 12、子级无图标文本 44px 缩进（`$spacing-base-tight + $width-navigation_icon_left + $width-navigation_icon_text_between` = 12+20+12，nav:282）、ellipsis 三连。色态（mixin.scss 12 状态逐条映射 itemL1 系/horizontal 系）：default/hover/active/selected/hover-selected/active-selected/disabled/disabled-selected；子级行（Ln）底色走 itemLn default 但状态色复用 itemL1 mixin（nav:289-319 quirk——itemLn 状态系「预留未接线」）；Sub 标题 selected bg 覆盖回 transparent（nav:447-449 quirk）；子级 selected+disabled 色混搭（nav:324-328：bg itemL1 selected + text itemL1 disabled）；horizontal 六态走 horizontal 系。字重：顶层条目/标题 600、子级 400、弹层选中 400（★`normal` 关键字 quirk）。focus outline `widthNavigationOutline`(2) solid `colorNavigationOutlineFocus` + offset `widthNavigationOutlineOffset`(-2)（nav:106-108）。MOTION 3 消费：条目 bg transition 恒等注释口径照 anchor 先例；$motion-* 5 String 消费：折叠动画（宽度/内边距/渐隐）解析简写的 duration+curve 语义（parseMotionDuration/parseMotionCurve；cubic-bezier 负控制点 `-.1` 直入 Cubic）。RTL（rtl.scss:3-131）：border-right→border-left、margin/padding/图标距 EdgeInsetsDirectional 翻边、`$motion-navigation_padding_rtl` 消费（padding-right 过渡注释引用）。

### 键盘与 locale

Enter 激活条目/Sub 标题（itemFoundation.ts:101-110、subNavFoundation.ts:132-136；link 不导航照 breadcrumb）。focus outline 同上。locale zh 硬编码 `_NavigationMetrics`：`'收起侧边栏'`/`'展开侧边栏'`（zh_CN.ts:100-103）。

## 主题（122 对账）

来源 packages/semi-foundation/navigation/variables.scss（120 声明行 = 119 唯一 token + `$module: #{$prefix}-navigation` 类名胶水不计）+ packages/semi-foundation/navigation/animation.scss（3 声明行——**活文件**：navigation.scss:2 `@import "./animation.scss"` + :92 消费，0ms/easeIn/0ms 恒等）。对账 **122 = 119 FIELDS + 3 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表）。分类计数：**47 Color + 58 double + 9 FontWeight + 5 String + 2 Duration + 1 Curve = 122**（尺寸 17 + spacing 40 + font fontSize 1 = 58 double；transition 简写 5 String——datePicker `transitionDatepickerRangeInput` 先例原文字符串）。★**10 死变量（迄今最多）**：真死 9（`$height-navigation_footer`、`$width-navigation_footer_border`、`$spacing-navigation_horizontal_header_logo-marginLeft`、`$spacing-navigation_sub_item_left_toggle_marginRight` + itemLn 状态系 5 条——★死因 quirk：子级视觉实际复用 itemL1 mixin（navigation.scss:289-319），itemLn 状态系「预留未接线」）+ 事实死 1（`$motion-navigation_item_title`——★100s delay typo 照抄；唯一消费 nav:154 挂 `.semi-navigation-item-title`（nav:152-155），UI 源码从不渲染该类（Item.tsx:222 渲染的是 `-item-text`）——标注「（上游事实死——消费于 UI 从不渲染的类）」）。MOTION 3 是活字段（itemL1 bg transition 三元组）；String 5 中 4 条活（collapsed 折叠动画消费 duration+curve 语义）+ 1 条事实死。全局 token 解析：`var(--semi-color-nav-bg)` → `theme.colors.colorNavBg`（SemiColors 已有）、`var(--semi-color-border)` → `theme.colors.colorBorder`、`var(--semi-color-text-0/1/2)` → `theme.colors.colorText0/1/2`、`var(--semi-color-fill-0/1)` → `theme.colors.colorFill0/1`、`var(--semi-color-primary)` → `theme.colors.colorPrimary`、`var(--semi-color-primary-light-default)` → `theme.colors.colorPrimaryLightDefault`、`var(--semi-color-primary-light-active)` → `theme.colors.colorPrimaryLightActive`、`var(--semi-color-primary-disabled)` → `theme.colors.colorPrimaryDisabled`、`var(--semi-color-disabled-text)` → `theme.colors.colorDisabledText`、`transparent` → `const Color(0x00000000)`；引用 token：`$spacing-tight` → 8、`$spacing-base-tight` → 12、`$font-size-regular` → 14、`$font-size-header-5` → 18（nav:378 mixin 来源）、`$font-weight-regular` → 400（FontWeight → `theme.typography.fontWeightRegular`（= FontWeight.w400））、`$font-weight-bold` → 600（FontWeight → `theme.typography.fontWeightBold`（= FontWeight.w600）——生成域 fontWeight resolve 先例 tool/generate_tag.py:31）、`var(--semi-border-radius-small)` → 3（`theme.radius.borderRadiusSmall.value`，generate_collapse.py:42 先例）；★`$font-navigation_popover_nav_item_selected-fontWeight: normal` 关键字 → FontWeight.w400；★两条公式值 → **3.5**（variables.scss:50/:52 递归求值 = (60 - 8×2 - 1 - 36) × 0.5）。FontWeight 值相等天然（dart:ui 值类自带 `==`/`hashCode`）直用内置运算符；Curve 走 semiCurveEquals/semiCurveHash。解析列即 `SemiNavigationThemeData.resolve` 默认表达式。

### A. Sass 声明映射（119 FIELDS + 3 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$height-navigation_item_base: 36px` | `heightNavigationItemBase` | `36`（条目行高 36） |
| `$width-navigation_container_base: 240px` | `widthNavigationContainerBase` | `240`（展开宽 240） |
| `$width-navigation_container_collapsed: 60px` | `widthNavigationContainerCollapsed` | `60`（收起宽 60） |
| `$width-navigation_header_logo: 36px` | `widthNavigationHeaderLogo` | `36`（logo 宽 36） |
| `$height-navigation_header_logo: 36px` | `heightNavigationHeaderLogo` | `36`（logo 高 36） |
| `$height-navigation_header_logo_collapsed: 36px` | `heightNavigationHeaderLogoCollapsed` | `36`（collapsed logo 尺寸（★nav:414 当宽用 quirk）） |
| `$height-navigation_footer: 48px` | `heightNavigationFooter` | `48`（footer 高）（上游未消费） |
| `$height-navigation_horizontal_header: 60px` | `heightNavigationHorizontalHeader` | `60`（顶部导航高 60） |
| `$width-navigation_icon_text_between: 12px` | `widthNavigationIconTextBetween` | `12`（图标-标题间距 12（★名宽实距）） |
| `$width-navigation_icon_left: 20px` | `widthNavigationIconLeft` | `20`（图标左距 20（44px 缩进因子）） |
| `$width-navigation_item-borderRadius: var(--semi-border-radius-small)` | `widthNavigationItemBorderRadius` | `theme.radius.borderRadiusSmall.value`（条目圆角 3（★名宽实圆角 quirk）） |
| `$width-navigation_dropdown_item_nav_item-minWidth: 150px` | `widthNavigationDropdownItemNavItemMinWidth` | `150`（弹层条目 min-width 150） |
| `$width-navigation_border: 1px` | `widthNavigationBorder` | `1`（描边宽 1） |
| `$width-navigation_footer_border: 1px` | `widthNavigationFooterBorder` | `1`（footer 描边宽）（上游未消费） |
| `$width-navigation_icon_left-minWidth: 20px` | `widthNavigationIconLeftMinWidth` | `20`（图标槽 min-width 20） |
| `$width-navigation-outline: 2px` | `widthNavigationOutline` | `2`（聚焦 outline 宽 2） |
| `$width-navigation-outlineOffset: -2px` | `widthNavigationOutlineOffset` | `-2`（聚焦 outline 偏移 -2） |
| `$spacing-navigation-paddingX: $spacing-tight` | `spacingNavigationPaddingX` | `8`（根水平 padding） |
| `$spacing-navigation_collapsed-paddingX: $spacing-tight` | `spacingNavigationCollapsedPaddingX` | `8`（collapsed 根水平 padding） |
| `$spacing-navigation_item-paddingX: $spacing-base-tight` | `spacingNavigationItemPaddingX` | `12`（条目 paddingX 12） |
| `$spacing-navigation_item-paddingY: $spacing-tight` | `spacingNavigationItemPaddingY` | `8`（条目 paddingY 8） |
| `$spacing-navigation_item-marginBottom: $spacing-tight` | `spacingNavigationItemMarginBottom` | `8`（条目 margin-bottom 8） |
| `$spacing-navigation_sub_title-marginBottom: 0` | `spacingNavigationSubTitleMarginBottom` | `0`（sub-title margin-bottom 0） |
| `$spacing-navigation_sub_wrap-marginTop: 0` | `spacingNavigationSubWrapMarginTop` | `0`（sub-wrap margin-top） |
| `$spacing-navigation_sub_wrap-padding: 0` | `spacingNavigationSubWrapPadding` | `0`（sub-wrap padding） |
| `$spacing-navigation_sub-padding: 0` | `spacingNavigationSubPadding` | `0`（sub 列表 padding） |
| `$spacing-navigation_item_sub-padding: 0` | `spacingNavigationItemSubPadding` | `0`（弹层 item-sub padding） |
| `$spacing-navigation_header_logo-marginLeft: 0` | `spacingNavigationHeaderLogoMarginLeft` | `0`（logo margin-left） |
| `$spacing-navigation_header_logo-marginRight: 8px` | `spacingNavigationHeaderLogoMarginRight` | `8`（logo margin-right 8） |
| `$spacing-navigation_header-paddingTop: 32px` | `spacingNavigationHeaderPaddingTop` | `32`（header padding-top 32） |
| `$spacing-navigation_header-paddingBottom: 36px` | `spacingNavigationHeaderPaddingBottom` | `36`（header padding-bottom 36） |
| `$spacing-navigation_list_wrapper-paddingTop: 12px` | `spacingNavigationListWrapperPaddingTop` | `12`（列表区 padding-top 12） |
| `$spacing-navigation_footer-paddingX: 24px` | `spacingNavigationFooterPaddingX` | `24`（footer paddingX 24） |
| `$spacing-navigation_footer-paddingY: 16px` | `spacingNavigationFooterPaddingY` | `16`（footer paddingY 16） |
| `$spacing-navigation_footer_collapse_btn_inner-paddingX: 8px` | `spacingNavigationFooterCollapseBtnInnerPaddingX` | `8`（收起按钮 paddingX 8） |
| `$spacing-navigation_horizontal_header_logo-marginLeft: 24px` | `spacingNavigationHorizontalHeaderLogoMarginLeft` | `24`（顶部 logo margin-left）（上游未消费） |
| `$spacing-navigation_horizontal_header_logo-marginRight: 24px` | `spacingNavigationHorizontalHeaderLogoMarginRight` | `24`（顶部 logo margin-right 24） |
| `$spacing-navigation_horizontal-paddingLeft: 24px` | `spacingNavigationHorizontalPaddingLeft` | `24`（顶部左 padding 24） |
| `$spacing-navigation_horizontal-paddingRight: 24px` | `spacingNavigationHorizontalPaddingRight` | `24`（顶部右 padding 24） |
| `$spacing-navigation_dropdown_item_nav_sub_title-paddingX: $spacing-base-tight` | `spacingNavigationDropdownItemNavSubTitlePaddingX` | `12`（弹层 sub-title paddingX 12） |
| `$spacing-navigation_dropdown_item_nav_sub_title-paddingY: $spacing-tight` | `spacingNavigationDropdownItemNavSubTitlePaddingY` | `8`（弹层 sub-title paddingY 8） |
| `$spacing-navigation_dropdown_item_nav_item-marginTop: 0` | `spacingNavigationDropdownItemNavItemMarginTop` | `0`（弹层条目 margin-top 0） |
| `$spacing-navigation_dropdown_item_nav_item-marginBottom: 0` | `spacingNavigationDropdownItemNavItemMarginBottom` | `0`（弹层条目 margin-bottom 0） |
| `$spacing-navigation_vertical_nav_item_last-marginBottom: 0` | `spacingNavigationVerticalNavItemLastMarginBottom` | `0`（末位条目 margin-bottom 0） |
| `$spacing-navigation_vertical_nav_header-paddingLeft:  ($width-navigation_container_collapsed - $spacing-navigation_collapsed-paddingX * 2 - $width-navigation_border - $height-navigation_header_logo_collapsed) * 0.5` | `spacingNavigationVerticalNavHeaderPaddingLeft` | `3.5`（header 左 padding 3.5（★公式）） |
| `$spacing-navigation_vertical_nav_header-paddingRight: $spacing-tight` | `spacingNavigationVerticalNavHeaderPaddingRight` | `8`（header 右 padding 8） |
| `$spacing-navigation_vertical_nav_header_collapsed-paddingLeft: ($width-navigation_container_collapsed - $spacing-navigation_collapsed-paddingX * 2 - $width-navigation_border - $height-navigation_header_logo_collapsed) * 0.5` | `spacingNavigationVerticalNavHeaderCollapsedPaddingLeft` | `3.5`（collapsed header 左 padding 3.5（★公式）） |
| `$spacing-navigation_vertical_nav_header_collapsed-paddingRight: 0` | `spacingNavigationVerticalNavHeaderCollapsedPaddingRight` | `0`（collapsed header 右 padding 0） |
| `$spacing-navigation_vertical_footer-paddingLeft: $spacing-tight` | `spacingNavigationVerticalFooterPaddingLeft` | `8`（footer 左 padding 8） |
| `$spacing-navigation_vertical_footer-paddingRight: $spacing-tight` | `spacingNavigationVerticalFooterPaddingRight` | `8`（footer 右 padding 8） |
| `$spacing-navigation_vertical_footer_semi_button_content_right-marginLeft: 12px` | `spacingNavigationVerticalFooterSemiButtonContentRightMarginLeft` | `12`（收起按钮标题左 margin 12） |
| `$spacing-navigation_horizontal_nav_list_item-marginBottom: 0` | `spacingNavigationHorizontalNavListItemMarginBottom` | `0`（顶部条目 margin-bottom 0） |
| `$spacing-navigation_horizontal_nav_list_item_not_last-marginRight: $spacing-tight` | `spacingNavigationHorizontalNavListItemNotLastMarginRight` | `8`（顶部非末位条目右 margin 8） |
| `$spacing-navigation_horizontal_icon_first-marginRight: $spacing-tight` | `spacingNavigationHorizontalIconFirstMarginRight` | `8`（顶部首位图标右 margin 8） |
| `$spacing-navigation_horizontal_icon_last-marginLeft: $spacing-tight` | `spacingNavigationHorizontalIconLastMarginLeft` | `8`（顶部末位图标左 margin 8） |
| `$spacing-navigation_sub_item_first_child-marginTop: $spacing-tight` | `spacingNavigationSubItemFirstChildMarginTop` | `8`（子级首位 margin-top 8） |
| `$spacing-navigation_sub_item_left_toggle_marginRight:$spacing-tight` | `spacingNavigationSubItemLeftToggleMarginRight` | `8`（（死因见上））（上游未消费） |
| `$color-navigation-bg-default: var(--semi-color-nav-bg)` | `colorNavigationBgDefault` | `theme.colors.colorNavBg`（导航背景色） |
| `$color-navigation_border-default: var(--semi-color-border)` | `colorNavigationBorderDefault` | `theme.colors.colorBorder`（描边/分割线色） |
| `$color-navigation_header-text-default: var(--semi-color-text-0)` | `colorNavigationHeaderTextDefault` | `theme.colors.colorText0`（header 文字色） |
| `$color-navigation_footer_icon-default: var(--semi-color-text-1)` | `colorNavigationFooterIconDefault` | `theme.colors.colorText1`（footer 图标色） |
| `$color-navigation_itemL1-bg-default: transparent` | `colorNavigationItemL1BgDefault` | `const Color(0x00000000)`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_itemL1-text-default: var(--semi-color-text-0)` | `colorNavigationItemL1TextDefault` | `theme.colors.colorText0`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_itemL1_icon-default: var(--semi-color-text-2)` | `colorNavigationItemL1IconDefault` | `theme.colors.colorText2`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_itemL1-bg-hover: var(--semi-color-fill-0)` | `colorNavigationItemL1BgHover` | `theme.colors.colorFill0`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_itemL1-text-hover: var(--semi-color-text-0)` | `colorNavigationItemL1TextHover` | `theme.colors.colorText0`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_itemL1_icon-hover: var(--semi-color-text-2)` | `colorNavigationItemL1IconHover` | `theme.colors.colorText2`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_itemL1_selected-text-hover: var(--semi-color-text-0)` | `colorNavigationItemL1SelectedTextHover` | `theme.colors.colorText0`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_itemL1-bg-active: var(--semi-color-fill-1)` | `colorNavigationItemL1BgActive` | `theme.colors.colorFill1`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_itemL1-text-active: var(--semi-color-text-0)` | `colorNavigationItemL1TextActive` | `theme.colors.colorText0`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_itemL1_icon-active: var(--semi-color-text-2)` | `colorNavigationItemL1IconActive` | `theme.colors.colorText2`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_itemL1_selected-text-active: var(--semi-color-text-0)` | `colorNavigationItemL1SelectedTextActive` | `theme.colors.colorText0`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_itemL1_selected-bg-default: var(--semi-color-primary-light-default)` | `colorNavigationItemL1SelectedBgDefault` | `theme.colors.colorPrimaryLightDefault`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_itemL1_selected-text-default: var(--semi-color-text-0)` | `colorNavigationItemL1SelectedTextDefault` | `theme.colors.colorText0`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_itemL1_selected_icon-default: var(--semi-color-primary)` | `colorNavigationItemL1SelectedIconDefault` | `theme.colors.colorPrimary`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_itemL1_disabled-bg-default: transparent` | `colorNavigationItemL1DisabledBgDefault` | `const Color(0x00000000)`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_itemL1_disabled-text-default: var(--semi-color-disabled-text)` | `colorNavigationItemL1DisabledTextDefault` | `theme.colors.colorDisabledText`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_itemL1_disabled_icon-default: var(--semi-color-disabled-text)` | `colorNavigationItemL1DisabledIconDefault` | `theme.colors.colorDisabledText`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_itemL1_selected_disabled-bg-default: transparent` | `colorNavigationItemL1SelectedDisabledBgDefault` | `const Color(0x00000000)`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_itemL1_selected_disabled-text-default: var(--semi-color-primary-disabled)` | `colorNavigationItemL1SelectedDisabledTextDefault` | `theme.colors.colorPrimaryDisabled`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_itemL1_selected_disabled_icon-default: var(--semi-color-primary-disabled)` | `colorNavigationItemL1SelectedDisabledIconDefault` | `theme.colors.colorPrimaryDisabled`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_horizontal_itemL1-text-default: var(--semi-color-text-2)` | `colorNavigationHorizontalItemL1TextDefault` | `theme.colors.colorText2`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_horizontal_itemL1_icon-default: var(--semi-color-text-2)` | `colorNavigationHorizontalItemL1IconDefault` | `theme.colors.colorText2`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_horizontal_itemL1-bg-default: transparent` | `colorNavigationHorizontalItemL1BgDefault` | `const Color(0x00000000)`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_horizontal_itemL1-text-hover: var(--semi-color-text-1)` | `colorNavigationHorizontalItemL1TextHover` | `theme.colors.colorText1`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_horizontal_itemL1_icon-hover: var(--semi-color-text-1)` | `colorNavigationHorizontalItemL1IconHover` | `theme.colors.colorText1`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_horizontal_itemL1-bg-hover: transparent` | `colorNavigationHorizontalItemL1BgHover` | `const Color(0x00000000)`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_horizontal_itemL1-text-active: var(--semi-color-text-0)` | `colorNavigationHorizontalItemL1TextActive` | `theme.colors.colorText0`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_horizontal_itemL1_icon-active: var(--semi-color-text-0)` | `colorNavigationHorizontalItemL1IconActive` | `theme.colors.colorText0`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_horizontal_itemL1-bg-active: transparent` | `colorNavigationHorizontalItemL1BgActive` | `const Color(0x00000000)`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_horizontal_itemL1_selected-text-default: var(--semi-color-text-0)` | `colorNavigationHorizontalItemL1SelectedTextDefault` | `theme.colors.colorText0`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_horizontal_itemL1_selected_icon-default: var(--semi-color-text-0)` | `colorNavigationHorizontalItemL1SelectedIconDefault` | `theme.colors.colorText0`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_horizontal_itemL1_selected-bg-default: transparent` | `colorNavigationHorizontalItemL1SelectedBgDefault` | `const Color(0x00000000)`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_horizontal_itemL1_disabled-text-default: var(--semi-color-disabled-text)` | `colorNavigationHorizontalItemL1DisabledTextDefault` | `theme.colors.colorDisabledText`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_horizontal_itemL1_disabled_icon-default: var(--semi-color-disabled-text)` | `colorNavigationHorizontalItemL1DisabledIconDefault` | `theme.colors.colorDisabledText`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_horizontal_itemL1_disabled-bg-default: transparent` | `colorNavigationHorizontalItemL1DisabledBgDefault` | `const Color(0x00000000)`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_itemLn-bg-default: transparent` | `colorNavigationItemLnBgDefault` | `const Color(0x00000000)`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_itemLn-text-default: var(--semi-color-text-0)` | `colorNavigationItemLnTextDefault` | `theme.colors.colorText0`（itemL1/horizontal/itemLn 色态） |
| `$color-navigation_itemLn-bg-hover: var(--semi-color-fill-0)` | `colorNavigationItemLnBgHover` | `theme.colors.colorFill0`（itemL1/horizontal/itemLn 色态）（上游未消费）★itemLn 状态系预留未接线——子级视觉复用 itemL1 mixin（navigation.scss:289-319） |
| `$color-navigation_itemLn-text-hover: var(--semi-color-text-0)` | `colorNavigationItemLnTextHover` | `theme.colors.colorText0`（itemL1/horizontal/itemLn 色态）（上游未消费）★itemLn 状态系预留未接线——子级视觉复用 itemL1 mixin（navigation.scss:289-319） |
| `$color-navigation_itemLn-bg-active: var(--semi-color-fill-1)` | `colorNavigationItemLnBgActive` | `theme.colors.colorFill1`（itemL1/horizontal/itemLn 色态）（上游未消费）★itemLn 状态系预留未接线——子级视觉复用 itemL1 mixin（navigation.scss:289-319） |
| `$color-navigation_itemLn-text-active: var(--semi-color-text-0)` | `colorNavigationItemLnTextActive` | `theme.colors.colorText0`（itemL1/horizontal/itemLn 色态）（上游未消费）★itemLn 状态系预留未接线——子级视觉复用 itemL1 mixin（navigation.scss:289-319） |
| `$color-navigation_itemLn_selected-bg-default: var(--semi-color-primary-light-default)` | `colorNavigationItemLnSelectedBgDefault` | `theme.colors.colorPrimaryLightDefault`（itemL1/horizontal/itemLn 色态）（上游未消费）★itemLn 状态系预留未接线——子级视觉复用 itemL1 mixin（navigation.scss:289-319） |
| `$color-navigation_outline-focus: var(--semi-color-primary-light-active)` | `colorNavigationOutlineFocus` | `theme.colors.colorPrimaryLightActive`（聚焦 outline 色） |
| `$motion-navigation_item_title: opacity 100ms 100s ease-out` | `motionNavigationItemTitle` | `'opacity 100ms 100s ease-out'`（String 简写）（上游未消费）（上游事实死——消费于 UI 从不渲染的类）★100s delay typo 照抄 |
| `$motion-navigation_padding: padding-left 100ms ease-out` | `motionNavigationPadding` | `'padding-left 100ms ease-out'`（String 简写（padding-left 过渡）） |
| `$motion-navigation_padding_rtl: padding-right 100ms ease-out` | `motionNavigationPaddingRtl` | `'padding-right 100ms ease-out'`（String 简写（RTL padding-right 过渡）） |
| `$motion-navigation_width: width 200ms cubic-bezier(.62, .05, .36, .95)` | `motionNavigationWidth` | `'width 200ms cubic-bezier(.62, .05, .36, .95)'`（String 简写（宽度过渡）） |
| `$motion-navigation_collapsed_opacity: opacity .2s cubic-bezier(.5, -.1, 1, .4)` | `motionNavigationCollapsedOpacity` | `'opacity .2s cubic-bezier(.5, -.1, 1, .4)'`（String 简写（渐隐过渡）） |
| `$font-navigation_item-fontWeight: $font-weight-bold` | `fontNavigationItemFontWeight` | `theme.typography.fontWeightBold`（顶层条目字重 600） |
| `$font-navigation_sub_title-fontWeight: $font-weight-bold` | `fontNavigationSubTitleFontWeight` | `theme.typography.fontWeightBold`（顶层 sub-title 字重 600） |
| `$font-navigation_item_normal-fontWeight: $font-weight-regular` | `fontNavigationItemNormalFontWeight` | `theme.typography.fontWeightRegular`（基准字重 400（弹层条目）） |
| `$font-navigation_popover_nav_item_selected-fontWeight: normal` | `fontNavigationPopoverNavItemSelectedFontWeight` | `FontWeight.w400`（弹层选中字重（★normal 关键字→w400）） |
| `$font-navigation_sub_selected-fontWeight: $font-weight-bold` | `fontNavigationSubSelectedFontWeight` | `theme.typography.fontWeightBold`（sub-title 选中字重 600） |
| `$font-navigation_sub_disabled-fontWeight: $font-weight-bold` | `fontNavigationSubDisabledFontWeight` | `theme.typography.fontWeightBold`（sub-title 禁用字重 600） |
| `$font-navigation_sub-fontWeight: $font-weight-regular` | `fontNavigationSubFontWeight` | `theme.typography.fontWeightRegular`（嵌套 sub-title 字重 400） |
| `$font-navigation_sub-fontSize: $font-size-regular` | `fontNavigationSubFontSize` | `14`（子级字号 14） |
| `$font-navigation_sub_item-fontWeight: $font-weight-regular` | `fontNavigationSubItemFontWeight` | `theme.typography.fontWeightRegular`（子级条目字重 400） |
| `$font-navigation_header_item-fontWeight: $font-weight-bold` | `fontNavigationHeaderItemFontWeight` | `theme.typography.fontWeightBold`（header 标题字重 600） |
| `$transition_duration-navigation_itemL1-bg: var(--semi-transition_duration-none)` | `transitionDurationNavigationItemL1Bg` | `Duration.zero`（） |
| `$transition_function-navigation_itemL1-bg: var(--semi-transition_function-easeIn)` | `transitionFunctionNavigationItemL1Bg` | `Curves.easeIn`（） |
| `$transition_delay-navigation_itemL1-bg: var(--semi-transition_delay-none)` | `transitionDelayNavigationItemL1Bg` | `Duration.zero`（） |

### B. HARDCODES 另列（`_NavigationMetrics` / 调用点，widget 源内含原始片段）

| 上游片段 | 落点 |
|---|---|
| `transition: transform 200ms ease-in-out` | chevron 旋转（nav:343-350 → AnimatedRotation 200ms easeInOut） |
| `$spacing-base-tight + $width-navigation_icon_left + $width-navigation_icon_text_between` | 子级无图标文本 44px 缩进（nav:282 = 12+20+12 → Padding start） |
| `word-wrap: none` | note-only——nav:710 非法 CSS 值（编译器丢弃，`-item-collapsed` 规则携带） |
| `cursor: pointer` | 条目手型（nav:79 → MouseRegion click） |
| `cursor: not-allowed` | 禁用光标（mix:13/39/71 → MouseRegion forbidden） |
| `user-select: none` | note-only——nav:17 文本不可选（Flutter 默认即不可选） |
| `overflow: hidden; white-space: nowrap; text-overflow: ellipsis` | 条目文本单行省略三连（nav:94-97 → Text ellipsis） |
| `opacity: 0` | collapsed 渐隐起点（nav:57-67 → AnimatedOpacity） |
| `opacity: 1` | collapsed 渐显终点（nav:57-67 → AnimatedOpacity） |
| `@include font-size-regular` | 条目字号 mixin 来源 14（nav:87 → _NavigationMetrics.fontSizeRegular） |
| `@include font-size-header-5` | header 标题字号 mixin 来源 18（nav:378 → _NavigationMetrics.fontSizeHeader5） |
| `'收起侧边栏'` | footer 收起按钮缺省文案（zh_CN.ts:100-103） |
| `'展开侧边栏'` | footer 展开按钮缺省文案（zh_CN.ts:100-103） |
| `DEFAULT_SUBNAV_MAX_HEIGHT: 999` | note-only——constants.ts:22 死常量（上游从未消费） |
| `TOOLTIP_SHOW_DELAY: 0` | tooltip 出现延迟 0ms（constants.ts:23 → SemiTooltip mouseEnterDelay） |
| `TOOLTIP_HIDE_DELAY: 100` | tooltip 消失延迟 100ms（constants.ts:24 → mouseLeaveDelay） |
| `SUBNAV_OPEN_DELAY: 0` | Sub 弹层出现延迟 0ms（constants.ts:25 → SemiDropdown mouseEnterDelay） |
| `SUBNAV_CLOSE_DELAY: 100` | Sub 弹层收起延迟 100ms（constants.ts:26 → mouseLeaveDelay） |
| `($width-navigation_container_collapsed - $spacing-navigation_collapsed-paddingX * 2 - $width-navigation_border - $height-navigation_header_logo_collapsed) * 0.5` | 3.5 公式（variables.scss:50/:52 → _NavigationMetrics.verticalHeaderPaddingFormula + header padding 字段） |
| `object-fit: scale-down` | logo 缩放（nav:373 → FittedBox scaleDown） |

## 差异清单

★照搬留档（quirk 原样）：
1. **已选不取消**：已选中再点不触发 onSelect 不移除（itemFoundation.ts:87 `if (!getSelected())`）。
2. **选中自动附一级父 key**：`selectLevelZeroParentKeys`（foundation.ts:210-229）——Sub 标题亮 selected；★父 key 只进内部 state/视觉，onSelect 载荷 `selectedKeys = [itemKey]` 不含父 key（itemFoundation.ts:83）。
3. **openKeys 仅 vertical 未折叠受控**（index.tsx:407 quirk）：collapsed/horizontal 时 openKeys prop 不作受控（内部 state 照更，弹层可见性仍走 onOpenChange）。
4. **0 值 key 合法**：foundation.ts:79 `??` 判定只认 null/undefined，numeric 0 正常参与选中/展开。
5. **onClick 两路 payload 不一致**：item 发 `{itemKey, text}`、sub 发 `{itemKey, openKeys, isOpen}`（subNavFoundation.ts:115）；★上游声明 `{itemKey, domEvent, isOpen}`（foundation.ts:12-16）与实际不符留档。
6. **死 API 留档不移植**：`isOpen`/`maxHeight`（SubNav isOpen/maxHeight——maxHeight 仅 Collapsible 动画参数、DEFAULT_SUBNAV_MAX_HEIGHT: 999 死常量）、`multiple`/`onDeselect`（index.tsx:142-143 声明从未消费）、`toggleIcon`（NavItem toggleIcon 字面量图标名形态——Flutter 取 expandIcon Widget）。
7. **`$motion-navigation_item_title` 100s typo + 事实死**：`opacity 100ms 100s ease-out`（variables.scss:116）delay 100s 疑似 100ms typo 照抄；唯一消费挂 UI 从不渲染的 `.semi-navigation-item-title`（nav:152-155 vs Item.tsx:222 `-item-text`）。
8. **itemLn 状态系预留未接线**：`$color-navigation_itemLn-*-hover/active` + `_selected-bg-default` 5 条零引用——子级视觉实际复用 itemL1 mixin（navigation.scss:289-319）。
9. **当宽用 quirk**：nav:414 `width: $height-navigation_header_logo_collapsed`——高度 token 被当 width 用。
10. **`word-wrap: none` 非法值**：nav:710 非法 CSS 值（编译器丢弃）照抄留档。
11. **`normal` 关键字**：`$font-navigation_popover_nav_item_selected-fontWeight: normal`（variables.scss:127）字面关键字而非 `$font-weight-regular` → FontWeight.w400。
12. **名宽实圆角/名宽实距**：`$width-navigation_item-borderRadius` 名 width 实圆角（nav:81）；`$width-navigation_icon_text_between`/`$width-navigation_icon_left` 名宽实间距。
13. **Sub 标题 selected bg 覆盖回 transparent**：nav:447-449 item-selected mixin 后 `background-color: $color-navigation_itemL1-bg-default`。
14. **子级 selected+disabled 色混搭**：nav:324-328 bg 走 itemL1 selected、text 走 itemL1 disabled（非 selected_disabled 系）。
15. **collapsed tooltip 条件**：Item.tsx:294-296 平铺 item 恒包 tooltip；Sub 仅 disabled 才包。
16. **horizontal footer 无 collapseButton**（Footer.tsx:64 quirk）。
17. **toggleIconPosition left 空槽 quirk**：普通条目 toggleIcon 为 null 仍渲染空 toggle 槽（Item.tsx:220/223 + nav:174-179 min-width 20）。

偏差/裁剪：
18. **children JSX 写法延期**：上游 `children`/JSX 组合不移植——`items` 强类型列表（`String | SemiNavigationItem`）承担；children 并非推荐用法（foundation.ts:83-87 注释自认 bug-like）。
19. **renderWrapper/getPopupContainer/subDropdownProps/bodyStyle 裁剪**：renderWrapper（issue #2690 兼容口）、getPopupContainer、subDropdownProps/dropdownProps/dropdownStyle、bodyStyle 不移植。
20. **subNavMotion 对象形态收敛 bool**：上游 `boolean | object | func`（CSSAnimation motion 对象）→ `bool`（true=高度+fade 近似、false=瞬时）。
21. **delay 参数默认化**：subNavOpenDelay/subNavCloseDelay/tooltipShowDelay/tooltipHideDelay 参数不开放——固定 constants.ts 缺省（0/100/0/100ms）。
22. **link 不导航**：Flutter 无 DOM anchor——link 仅元数据，点击走 onClick 链由应用导航（上游 `<a href>` DOM 跳转，itemFoundation.ts:101-110 Enter 时 `window.open`/`location.href`）。
23. **弹层自绘列表**：SemiDropdown content 自绘（menu 形态承载不了六态色/min-width 150）；弹层内色系统一 itemL1 系近似（上游弹层 hover 走 Dropdown.Item 样式 + 零散 scoped 规则，映射不完整）；弹层内点击条目即收起（近似 Dropdown.Item 行为）。
24. **Sub 内联展开动画近似**：上游 Collapsible CSS 高度+fade 无 token——200ms/easeInOut 近似。
25. **折叠动画 String 简写解析**：`$motion-navigation_width`/`_padding`/`_padding_rtl`/`_collapsed_opacity` 简写原文存 String 字段；折叠动画解析其 duration+curve 语义（cubic-bezier 负控制点直入 Cubic；padding 过渡与宽度过渡并入 AnimatedContainer/AnimatedPadding 双段近似）。
26. **collapseText 函数形态收敛**：上游 `(collapsed) => ReactNode` → `String?` 固定串（collapsed=>String 或固定串；缺省 locale）。
27. **className/style 等裁剪**：`className`/`style`/`getDataAttr`/`prefixCls`/`linkOptions` 不移植（Flutter 无 CSS 类）。
28. **aria 近似**：`role="menu"/"menuitem"`/`aria-expanded`/`aria-disabled` 以 Semantics(button/selected/expanded) 近似。
29. **Form/多语言上游即无**：上游 Navigation 无 Form 语义接入；locale 仅 zh 两串硬编码（zh_CN.ts:100-103）。

## 用法

```dart
SemiNavigation(
  items: [
    '首页', // String 归一化 → {text, itemKey}
    SemiNavigationItem(
      itemKey: 'components',
      text: '组件',
      items: const [
        SemiNavigationItem(itemKey: 'button', text: '按钮'),
        SemiNavigationItem(itemKey: 'input', text: '输入框'),
      ],
    ),
    SemiNavigationItem(itemKey: 0, text: '零键条目'), // ★0 是合法 key
  ],
  mode: SemiNavigationMode.vertical,
  defaultSelectedKeys: const ['button'], // 自动展开 components + Sub 标题亮选中
  header: const SemiNavigationHeader(logo: FlutterLogo(), text: 'Semi'),
  footer: const SemiNavigationFooter(collapseButton: true),
  onSelect: (info) {
    // ★已选中再点不触发；info.selectedKeys = [itemKey]（不含自动附父 key）
  },
  onOpenChange: (info) {
    // Sub 展开/收起（含弹层可见性变更）
  },
  onClick: (info) {
    // ★item 路 {itemKey, text} / sub 路 {itemKey, openKeys, isOpen}
  },
  onCollapseChange: (isCollapsed) {},
)
```
