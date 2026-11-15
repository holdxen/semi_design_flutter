# SemiBreadcrumb

面包屑（上游 Semi Breadcrumb 全件移植）：路径导航行——双模式条目（`routes`（`SemiBreadcrumbRoute | String`，String 自动包装照 genRoutes foundation.ts:32-46）优先于 `children`（`SemiBreadcrumbItem` 数据载体）），active 规则 `activeIndex ?? 末项`（index.tsx:204/:257；★active 项即使有 href 也渲染 span 无导航（item.tsx:177），但 onClick 恒挂照发（:181-189）、hover 光标恒手型——`-item-link:hover` 的 `cursor: pointer` 源序覆盖 `-item-active:hover` 的 `cursor: default`），折叠 `autoCollapse && len > maxItemCount`（★严格大于）且 isCollapsed 初始 true → 隐藏索引 `1..len-maxItemCount`（首项恒显、末 maxItemCount-1 项恒显），more 按钮（`SemiIcons.more`）替换隐藏区（★单向展开不可回收——handleExpand 置 false 后永不折叠；more 按钮自身渲染 separator、Enter-only 键盘 foundation.ts:26-30 `handleExpandEnterPress`，Space 不响应 quirk）。moreType：`defaultType` 点击展开全部；`popover` 点击弹面板列 restItem（restItem 间自拼 separator、hidden 项 separator 抑制 quirk 照 index.tsx:206/:258）。主题对账 **20 = 16 FIELDS + 4 MOTION + 0 INTERNAL**（variables.scss 16 + animation.scss 4 亲验——**活文件**（breadcrumb.scss:4 `@import "./animation.scss"` + :97-98 消费，0ms/ease-in/0ms/scale(1,1) 恒等）；`$module: #{$prefix}-breadcrumb` 类名胶水不计，datePicker `223 = 220 + 3 + 0`、timePicker `20 = 14 + 6 + 0`、transfer `50 = 47 + 3 + 0`、anchor `30 = 26 + 4 + 0` 先例）；★**0 死变量——首个零死变量组件**（16+4 条声明全消费，无死标）。

## API

`SemiBreadcrumb({routes, children: const [], separator: '/', compact: true, activeIndex, maxItemCount: 4, autoCollapse: true, moreType: SemiBreadcrumbMoreType.defaultType, renderMore, renderItem, showTooltip: true, itemMaxWidth: 150, onClick, semanticsLabel})`。

routes `List<Object>?`（`SemiBreadcrumbRoute | String`——String 自动包装，foundation.ts:32-46；优先于 children）。children `List<SemiBreadcrumbItem>`（children 模式数据载体——照 `SemiAnchorLink` 形制定稿为纯数据类）。separator `Object?`（String | Widget，缺省 `'/'`；item.separator 逐条覆盖——truthy 优先裸渲染、falsy 回退 quirk）。compact `true`（true → 字号 12 + icon small；false → 字号 14 + icon default）。activeIndex `int?`（缺省末项 active；★越界则无 active）。maxItemCount `4`（折叠阈值）。autoCollapse `true`（超出折叠；★单向展开不可回收）。moreType `SemiBreadcrumbMoreType.defaultType`（| popover；`default` 是保留字照 `defaultSize` 先例）。renderMore `Widget Function(List<Widget> restItems)?`（自定义折叠区内容，优先于 moreType）。renderItem `Widget Function(SemiBreadcrumbRoute route)?`（routes 模式替换 name 渲染）。showTooltip `true`（String name 悬停 tooltip；★false 仍截断）。itemMaxWidth `150`（String name 截断宽）。onClick `void Function(SemiBreadcrumbRoute route)?`（★item 自身 onClick 先、父后——itemFoundation.ts:29-33）。semanticsLabel `String?`（缺省 `'Breadcrumb'`，index.tsx:97）。

`SemiBreadcrumbRoute({name, href, icon, path, onClick})`：name `Object?`（String | Widget；★Widget 原样无截断 quirk）、href `String?`（仅元数据）、icon `Widget?`（compact 决定 size）、path `String?`（元数据）、onClick `void Function(SemiBreadcrumbRoute route)?`。

`SemiBreadcrumbItem({name, href, icon, onClick, separator, noLink = false})`：name `Object?`（String | Widget）、href `String?`、icon `Widget?`、onClick `void Function()?`、separator `Object?`（覆盖 context separator）、noLink `false`（去 hover/active 色）。

## 行为

### routes 与 children

routes 非空走 routes 模式（index.tsx:226-229 `hasRoutes` 二选一）：`SemiBreadcrumbRoute` 原样、String 包装为 `SemiBreadcrumbRoute(name: route)`（genRoutes foundation.ts:32-46）；renderItem 输出替换 name（index.tsx:208）。children 模式消费 `SemiBreadcrumbItem`（强类型列表，上游 `warning` 非 Item 子节点 quirk 无落点——note-only 见差异清单）；父 onClick 参数为合成 `SemiBreadcrumbRoute(name/href/icon)`（上游 itemInfo 同构，item.tsx:120-133）。

### active

`activeIndex ?? 末项`（index.tsx:204/:257，严格相等）；★active 项即使有 href 也渲染 span 无导航（item.tsx:177）、**onClick 恒挂照发**（:181-189）、hover 光标恒手型（`-item-link:hover` `cursor: pointer` 源序覆盖 `-item-active:hover` 的 `cursor: default`）；active 字重 `fontBreadcrumbActiveFontWeight`（600）、色 `colorBreadcrumbActiveTextDefault`（text-0，hover/active → `colorBreadcrumbActiveTextActive`）。

### 折叠与 more

`autoCollapse && len > maxItemCount`（★严格大于）且 isCollapsed 初始 true（index.tsx:104/:235）→ 隐藏索引 `1..len-maxItemCount`，首项恒显、末 maxItemCount-1 项恒显；more 按钮（`SemiIcons.more`）替换隐藏区（index.tsx:163-190 `handleCollapse`）；★单向展开不可回收（expandCollapsed 置 false 后永不折叠，index.tsx:115-118）；more 按钮自身渲染 separator（index.tsx:182-184）+ `aria-label="Expand breadcrumb items"`；键盘 Enter-only（foundation.ts:26-30 `handleExpandEnterPress`，★Space 不响应 quirk）。moreType：`defaultType`/renderMore 点击展开全部；`popover` 点击弹面板列 restItem（restItem 间自拼 separator——index.tsx:138-144 `restItem` 类包壳（色 `colorBreadcrumbRestItemTextDefault` + 右 margin `spacingBreadcrumbRestItemMarginRight`）；hidden 项 separator 抑制 quirk 照 index.tsx:206/:258）。renderMore 优先于 moreType（index.tsx:178-180）。

### 分隔符

context separator 缺省 `'/'`；★item.separator truthy 优先且**裸渲染不包壳**（item.tsx:204 `this.props.separator ||` quirk）；★falsy（null/`''`）回退 context——无法用 `''` 隐藏；包壳 separator 着色 `colorBreadcrumbSepearatorDefaultIconDefault`（★`sepearator` typo 照抄）；末项无 separator（index.tsx:206/:258）。

### 截断与 tooltip

★String name 走 `itemMaxWidth`（150）截断（Text maxLines 1 + ellipsis）+ showTooltip 时 hover tooltip（SemiTooltip trigger hover、`position: 'top'`、autoAdjustOverflow 默认——item.tsx:109-112）；★showTooltip=false 仍截断 quirk（item.tsx:100-104 仅裁掉 tooltip）；★Widget name 原样无截断 quirk（item.tsx:140 只对 string 走 Typography.Text ellipsis）。

### onClick 链

点击条目 → 先 item.onClick 后父 onClick(route)（itemFoundation.ts:29-33 `notifyClick` + `notifyParent`）；★active 项照发（upstream span 恒挂 onClick，仅无导航）；href 仅元数据（Flutter 无 DOM anchor，应用按 route.href 自行导航）。

### 视觉与 RTL

16 字段全消费：字号 compact 12/loose 14（`fontBreadcrumbCompactFontSize`/`Loose`）、字重 400/600（两 fontWeight 字段）、色态 default/hover/active/选中（四色字段）、分割线色 + restItem 色、item-wrap 上下/右 margin 4、item 右 4、icon-title 间距 4；★`margin-bottom: -1px` icon 基线 quirk（breadcrumb.scss:81）；flex-wrap 换行（:13-14）；MOTION 4 消费（link transition 三元组 + transform 恒等注释口径照 semi_anchor.dart 先例）。RTL（rtl.scss:3-25）：margin/方向互换（EdgeInsetsDirectional 翻边）；★icon+title 间距双倍 quirk（column-gap + rtl margin-right 并存）留档。aria：根 `semanticsLabel`（缺省 `'Breadcrumb'`）；active 项 `aria-current="page"` 语义（item.tsx:202，以 Semantics selected 近似）。

## 主题（20 对账）

来源 packages/semi-foundation/breadcrumb/variables.scss（16 声明行 / 16 唯一名——color 7、spacing 5（全 margin 语义）、font 4（fontWeight 2 + fontSize 2））+ packages/semi-foundation/breadcrumb/animation.scss（4 声明行——**活文件**：breadcrumb.scss:4 `@import "./animation.scss"` + :97-98 消费，token 解析 0ms/ease-in/0ms/scale(1,1) 恒等）。对账 **20 = 16 FIELDS + 4 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表；`$module: #{$prefix}-breadcrumb` 类名胶水不计）。★**0 死变量——首个零死变量组件**（全 20 字段 widget 全消费，无死标）。全局 token 解析：`var(--semi-color-text-2)` → `theme.colors.colorText2`、`var(--semi-color-link)` → `theme.colors.colorLink`、`var(--semi-color-link-hover)` → `theme.colors.colorLinkHover`、`var(--semi-color-text-0)` → `theme.colors.colorText0`；引用 token：`$spacing-extra-tight` → 4、`$spacing-tight` → 8、`$font-size-small` → 12、`$font-size-regular` → 14、`$font-weight-regular` → 400（FontWeight → `theme.typography.fontWeightRegular`（= FontWeight.w400））、`$font-weight-bold` → 600（FontWeight → `theme.typography.fontWeightBold`（= FontWeight.w600）——生成域 fontWeight resolve 先例 tool/generate_tag.py:31）；motion 四元组照 generate_anchor.py 先例：`var(--semi-transition_duration-none)`/`var(--semi-transition_delay-none)` → `Duration.zero`、`var(--semi-transition_function-easeIn)` → `Curves.easeIn`、★`var(--semi-transform_scale-none)`（= `scale(1,1)`，semi-theme-default/scss/animation.scss:28）→ `SemiTransform` → `const SemiTransform.scale(1, 1)`。解析列即 `SemiBreadcrumbThemeData.resolve` 默认表达式。类型覆盖：**7 Color + 7 double + 2 FontWeight + 2 Duration + 1 Curve + 1 SemiTransform**（FontWeight/SemiTransform 值相等天然（dart:ui 值类自带按 value 的 `==`/`hashCode` + token_types.dart 自带 `==`/`hashCode`）——照 SemiTransform 分派口径直用内置运算符；Curve 走 semiCurveEquals/semiCurveHash）。

### A. Sass 声明映射（16 FIELDS + 4 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$spacing-breadcrumb_item_wrap-marginY: $spacing-extra-tight` | `spacingBreadcrumbItemWrapMarginY` | `4`（item-wrap 垂直 marginY） |
| `$spacing-breadcrumb_item_wrap-marginRight: $spacing-extra-tight` | `spacingBreadcrumbItemWrapMarginRight` | `4`（item-wrap 右侧 margin；RTL 翻左边） |
| `$spacing-breadcrumb_item-marginRight: $spacing-extra-tight` | `spacingBreadcrumbItemMarginRight` | `4`（item 内容与分割线距离） |
| `$spacing-breadcrumb_item_text-marginLeft: $spacing-extra-tight` | `spacingBreadcrumbItemTextMarginLeft` | `4`（icon-title 间距；★RTL 双倍 quirk 因子） |
| `$spacing-breadcrumb_restItem-marginRight: $spacing-tight` | `spacingBreadcrumbRestItemMarginRight` | `8`（popover restItem separator 右侧 margin） |
| `$color-breadcrumb_default-text-default: var(--semi-color-text-2)` | `colorBreadcrumbDefaultTextDefault` | `theme.colors.colorText2`（未选中文字色） |
| `$color-breadcrumb_default-text-hover: var(--semi-color-link)` | `colorBreadcrumbDefaultTextHover` | `theme.colors.colorLink`（悬浮色） |
| `$color-breadcrumb_default-text-active: var(--semi-color-link-hover)` | `colorBreadcrumbDefaultTextActive` | `theme.colors.colorLinkHover`（按下色） |
| `$color-breadcrumb_active-text-default: var(--semi-color-text-0)` | `colorBreadcrumbActiveTextDefault` | `theme.colors.colorText0`（选中色） |
| `$color-breadcrumb_active-text-active: var(--semi-color-text-0)` | `colorBreadcrumbActiveTextActive` | `theme.colors.colorText0`（选中激活色） |
| `$color-breadcrumb_sepearator_default-icon-default: var(--semi-color-text-2)` | `colorBreadcrumbSepearatorDefaultIconDefault` | `theme.colors.colorText2`（分割线色；★`sepearator` typo 照抄 variables.scss:13） |
| `$color-breadcrumb-restItem-text-default: var(--semi-color-text-2)` | `colorBreadcrumbRestItemTextDefault` | `theme.colors.colorText2`（restItem 分割线色；★`-`/`_`/驼峰混排命名照抄 variables.scss:15 + 使用处 breadcrumb.scss:122 混写） |
| `$font-breadcrumb_default-fontWeight: $font-weight-regular` | `fontBreadcrumbDefaultFontWeight` | `theme.typography.fontWeightRegular`（FontWeight，= FontWeight.w400） |
| `$font-breadcrumb_active-fontWeight: $font-weight-bold` | `fontBreadcrumbActiveFontWeight` | `theme.typography.fontWeightBold`（FontWeight，= FontWeight.w600） |
| `$font-breadcrumb_compact-fontSize:$font-size-small` | `fontBreadcrumbCompactFontSize` | `12`（紧凑字号；★冒号后无空格排版 quirk 照抄 variables.scss:22） |
| `$font-breadcrumb_loose-fontSize:$font-size-regular` | `fontBreadcrumbLooseFontSize` | `14`（宽松字号；★冒号后无空格排版 quirk 照抄 variables.scss:23） |
| `$transition_duration-breadcrumb_link-text: var(--semi-transition_duration-none)` | `transitionDurationBreadcrumbLinkText` | `Duration.zero`（活字段——breadcrumb.scss:4 `@import` + :97 消费；AnimatedDefaultTextStyle duration，0ms 恒等） |
| `$transition_function-breadcrumb_link-text: var(--semi-transition_function-easeIn)` | `transitionFunctionBreadcrumbLinkText` | `Curves.easeIn`（活字段；AnimatedDefaultTextStyle curve；★使用处 `$transition-function_breadcrumb_link-text`（`_`）vs 声明 `-` 混写 quirk） |
| `$transition_delay-breadcrumb_link-text: var(--semi-transition_delay-none)` | `transitionDelayBreadcrumbLinkText` | `Duration.zero`（活字段；delay 槽 AnimatedDefaultTextStyle 无对应——注释引用 + 本表注明） |
| `$transform_scale-breadcrumb_link-text: var(--semi-transform_scale-none)` | `transformScaleBreadcrumbLinkText` | `const SemiTransform.scale(1, 1)`（活字段——:98 `transform: scale(...)` 消费；Transform.scale 恒等消费；★上游编译产物 `transform: scale(scale(1,1))` 无效 CSS bug（semi.css:3349）留档） |

### B. HARDCODES 另列（`_BreadcrumbMetrics` / 调用点，widget 源内含原始片段）

| 上游片段 | 落点 |
|---|---|
| `width: 150` | String name 截断宽（index.tsx:90-93 showTooltip 缺省 + item.tsx:102/:107 → `itemMaxWidth` 缺省 150） |
| `padding: 12` | popover 面板 padding（index.tsx:153-155 → `_buildPopover` Padding） |
| `'Breadcrumb'` | 根语义缺省名（index.tsx:97 → Semantics label） |
| `margin-bottom: -1px` | icon 基线 quirk（breadcrumb.scss:81 → Transform.translate 下移 0.5px 近似） |
| `cursor: default` | active 项光标（breadcrumb.scss:67-73 → MouseRegion basic） |
| `flex-wrap: wrap` | wrapper 换行（breadcrumb.scss:13-14 → Wrap） |
| `overflow: hidden` | note-only——breadcrumb.scss:10 死规则（根类是 wrapper，`.semi-breadcrumb` 选择器永不命中） |
| `transform: scale(scale(1,1))` | note-only——breadcrumb.scss:98 / semi.css:3349 无效编译 bug（token 自带 scale(1,1) 再包 scale(...)，视觉无影响） |
| `// flex-shrink: 0;` | breadcrumb.scss:38 注释留档 |
| `text-decoration: inherit` | link 继承文本装饰（breadcrumb.scss:96） |
| `column-gap: $spacing-breadcrumb_item_text-marginLeft` | icon-title 间距（breadcrumb.scss:37 → SizedBox gap；RTL 双倍 quirk） |
| `display: inline-flex; align-items: center` | item-wrap / item 行内弹性容器（breadcrumb.scss:28-29/:35-36 → Row min/center） |
| `handleExpandEnterPress` | more 按钮 Enter-only 键盘（foundation.ts:26-30 → Focus.onKeyEvent） |
| `position: 'top'` | tooltip opts 缺省位置（item.tsx:111 → SemiTooltip position top） |
| `sepearator` | 分割线变量名上游原文错拼（variables.scss:13） |

## 差异清单

★照搬留档（quirk 原样）：
1. **active 项无导航但照发 onClick、hover 恒手型**（★照搬）：即使有 href 也渲染 span（item.tsx:177）；onClick 恒挂（:181-189）照发事件链；★光标手型——`.semi-breadcrumb-item-link:hover` 的 `cursor: pointer`（breadcrumb.scss:100-108）与 `-item-active:hover` 的 `cursor: default`（:65-72）同特异性源序靠后胜出，官方 active 项亦是手型（noLink 无 link 类才回落 default）。
2. **严格大于才折叠**：`len > maxItemCount`（index.tsx:235；== maxItemCount 不折叠）。
3. **单向展开不可回收**：handleExpand 置 isCollapsed=false 后永不折叠（index.tsx:115-118）。
4. **more 按钮 Enter-only**：foundation.ts:26-30 `handleExpandEnterPress` 只认 Enter，★Space 不响应 quirk。
5. **separator falsy 回退 / 裸渲染**：item.separator truthy 优先且裸渲染不包壳（item.tsx:204）；falsy（null/`''`）回退 context——无法用 `''` 隐藏 quirk。
6. **showTooltip=false 仍截断**：item.tsx:100-104 仅裁掉 tooltip，width/ellipsis 照旧。
7. **Widget name 无截断**：item.tsx:140 只对 string 走 Typography.Text ellipsis。
8. **隐藏项 separator 抑制**：restItem 自拼 separator、条目本体不带（index.tsx:206/:258 + :138-144）。
9. **sepearator typo**：`$color-breadcrumb_sepearator_default-icon-default`（variables.scss:13）上游原文错拼照抄。
10. **`-`/`_`/驼峰混写**：`$color-breadcrumb-restItem-text-default`（variables.scss:15）vs 使用处 `$color-breadcrumb_restItem-text-default`（breadcrumb.scss:122）；`$transition_function-breadcrumb_link-text` 声明 vs `$transition-function_breadcrumb_link-text` 使用处（breadcrumb.scss:97）——Sass 名 -/_ 等价故可解析。
11. **无效 transform 编译 bug**：`transform: scale(scale(1,1))`（semi.css:3349，token 自带 scale(1,1) 再包 scale(...)）——视觉无影响留档（note-only）。
12. **死 overflow 规则**：breadcrumb.scss:10 `overflow: hidden` 打在 `.semi-breadcrumb` 根类上，但根类是 wrapper——该选择器永不命中（note-only）。
13. **RTL 间距双倍 quirk**：rtl.scss:21-25 在 column-gap（4）之外又给 title 加 margin-right（4）——icon+title 间距 8 并存留档。
14. **docs tooltip position 不一致**：上游 docs 表（content/navigation/breadcrumb/index.md:315）写缺省 `position: "bottomLeft"`，代码 item.tsx:111 写 `position: 'top'`——以代码为准，留档。

偏差/裁剪：
15. **showTooltip 对象形态收敛**：上游 `boolean | showToolTipProps`（width/ellipsisPos/opts）→ `showTooltip: bool` + `itemMaxWidth: double`（ellipsisPos 固定 end、opts 裁剪——`position: 'top'`/autoAdjustOverflow 作缺省）。
16. **tooltip 触发域**：上游 Typography.Text ellipsis tooltip 溢出才出（docs :114）→ 简化为悬停即出（trigger: hover，anchor 差异清单 25 先例）。
17. **popover 模式触发**：上游 Popover trigger 缺省 **hover**（popover/index.tsx:110）+ 点击冒泡 handleExpand 展开全部 → 本移植按批准方案 **click 弹面板**（SemiDropdown trigger: click + content 自绘 restItem 行 + 自拼 separator——menu: SemiDropdownItemData 形态承载不了横向 restItem 行）；showArrow 不移植（SemiDropdown popup 无箭头）、面板内点击即收起（clickToHide）。
18. **href 不导航**：Flutter 无 DOM anchor——href 仅元数据，点击走 onClick 链回传 route 由应用导航（上游 `<a href>` DOM 跳转）。
19. **className/style 裁剪**：`className`/`style`/`getDataAttr` 不移植（Flutter 无 CSS 类）。
20. **children 非 Item 的 warning quirk（条件写反）note-only**：index.tsx:250-253 `warning(item.type && !item.type.isBreadcrumbItem, ...)`——type 缺失的子节点逃过告警；本移植 `List<SemiBreadcrumbItem>` 强类型，无告警落点。
21. **aria-current 近似**：`aria-current="page"`（item.tsx:202）→ Semantics(selected)（Flutter 无 aria-current 对应）。
22. **icon 尺寸注入**：item.tsx:88-93 `cloneElement(icon, { size })` 强制覆盖 → SemiIconTheme 注入 small/normal（12/16）；显式 size 的 icon 优先（cloneElement 强制覆盖不复现）。
23. **`margin-bottom: -1px` 近似**：align-items:center 下等效下移 0.5px → Transform.translate(Offset(0, 0.5))（布局盒不缩 1px）。
24. **children 模式 onClick 参数合成**：父 onClick 收 `SemiBreadcrumbRoute(name/href/icon)`（上游 itemInfo `{name, href}` 同构扩展）。
25. **noLink 可点但无色态**：上游 onClick 恒挂（item.tsx:187）→ noLink 照旧发 onClick 链，但去 hover/active 色、default 光标（无 item-link 类）。
26. **Form/多语言上游即无**：上游 Breadcrumb 无 Form/label 语义接入、无内置多语言。

## 用法

```dart
SemiBreadcrumb(
  routes: const [
    SemiBreadcrumbRoute(name: '首页', href: '/', icon: SemiIcon(SemiIcons.home)),
    SemiBreadcrumbRoute(name: '组件', href: '/components'),
    '面包屑', // String 自动包装
  ],
  separator: '/',
  maxItemCount: 3,
  moreType: SemiBreadcrumbMoreType.popover,
  onClick: (route) {
    // ★item 自身 onClick 先、父 onClick 后；active 项不发
  },
)

// children 模式
SemiBreadcrumb(
  activeIndex: 0,
  children: const [
    SemiBreadcrumbItem(name: '一级', href: '/l1'),
    SemiBreadcrumbItem(name: '二级', separator: '>', noLink: true),
    SemiBreadcrumbItem(name: '三级'),
  ],
)
```
