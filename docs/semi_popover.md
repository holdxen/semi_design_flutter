# SemiPopover

气泡卡片（上游 Semi Popover 全件移植）：Tooltip 的薄封装——`renderPopCard` 把内容包进 `div.semi-popover > div.semi-popover-content` 卡片（bg-3 + `shadow-elevated` + medium 圆角 + 14/20 字号），`trigger` 缺省 hover、`position` 缺省 bottom、`showArrow` 缺省 false、`spacing` 缺省 `showArrow ? 10 : 4`、`closeOnEsc` 缺省 true、`zIndex` 1030。带箭头时画 popover 双路径箭头（bg-3 翼形 24×7 + color-border 描边 fringe 24×8，箭头盒 24×8 / 竖向 8×24），`arrowStyle` 覆写两路径着色与描边透明度；卡片仅 `.semi-popover-with-arrow` 带 12px 外层内边距（`&-content` 内边距规则上游注释掉，内容自带间距）。动画 `semi-popover-zoomIn/zoomOut`（100ms、cubic-bezier(0.215, 0.61, 0.355, 1)）。RTL 镜像。主题对账 **26 = 20 FIELDS + 4 MOTION + 2 INTERNAL**（variables.scss 22 声明：color 5、width 5、height 4、spacing 5、radius 1、horizontal 1、filter 1；animation.scss 4；`$module` 胶水与 rtl.scss 不计，tooltip `29 = 26 + 3 + 0`、carousel `40 = 34 + 6 + 0`、modal `81 = 63 + 18 + 0` 先例）；★**0 死变量**（popover.scss / 共享 tooltip arrow.scss / animation.scss 逐条消费）。

## API

`SemiPopover({content, child, position: bottom, trigger: hover, showArrow: false, arrowStyle, arrowPointAtCenter: true, autoAdjustOverflow: true, spacing, mouseEnterDelay: 50ms, mouseLeaveDelay: 50ms, clickToHide: false, closeOnEsc: true, visible, onVisibleChange, onClickOutSide, onEscKeyDown, motion: true, zIndex: 1030, repositionKey, arrowBoundingOffsetY: 6})`。

content `Widget`（上游 `content` 节点；函数式 `content({ initialFocusRef })` 未移植）。position `SemiTooltipPosition`（缺省 bottom）、trigger `SemiTooltipTrigger`（缺省 hover）。showArrow `bool`（缺省 false；上游 `showArrow ? <Arrow {...arrowProps} /> : false` 传节点，本地只支持 bool 并自绘双路径箭头）。arrowStyle `SemiPopoverArrowStyle({borderColor, backgroundColor, borderOpacity})`——Arrow.tsx `get(arrowStyle, 'borderColor', get(popStyle, 'borderColor',))` / `get(arrowStyle, 'backgroundColor', …)` 覆写两路径 fill、`get(arrowStyle, 'borderOpacity')` 合成 fringe 透明度（`popStyle` = 未移植的 `style` prop，缺省取 CSS fill token）。spacing `double?`（缺省 showArrow ? 10 : 4）。visible `bool?`（非空即受控，只经 onVisibleChange 报告请求）。arrowBoundingOffsetY 缺省 6（上游 `arrowBounding: numbers.ARROW_BOUNDING` 的 `offsetY: 6`，小触发物修正门限）。

## 行为

### 结构

- wrapper（卡片）：`$color-popover-bg-default`（bg-3）+ `backdrop-filter: $filter-popover-bg`（none）+ `@include shadow-elevated` + `z-index: $z-popover`（本地 overlay 插入序）+ `$radius-popover` + `@include font-size-regular`（14/20）；显隐 `opacity: 0;` → `opacity: 1;` 由 shell 动画承担。
- content：`renderPopCard` 的 `${prefixCls}-content` 内层，无内边距（`&-content` 规则上游注释掉）；带箭头时 wrapper 整体 `padding: 12px`（`.semi-popover-with-arrow`），无箭头无内边距。
- `&-title`（padding 8 + border-bottom 1px）是内容侧 class 样式钩子——当前 semi-ui 无渲染方，三字段注释留档。

### 箭头与定位

- 双路径箭头（Arrow.tsx）：fringe `path:nth-child(1)`（24×8 / 竖向 8×24，`fill: $color-popover-arrow-border`，borderOpacity 为 SVG opacity）压在翼形 `path:nth-child(2)`（24×7 / 7×24，`fill: $color-popover-arrow-bg`）之下；`SemiTooltip` 的 `_TooltipArrowPainter` 按盒高归一（盒 8 = 翼 7 + fringe 溢出 1；tooltip 无 fringe 时盒 7）。
- 定位复用 tooltip 引擎：`spacing` 10/4、角位内缩 `arrowAdjustedOffsetX` 5.76（★保留未取整值）/ `verticalRate × heightTooltipArrowVertical + arrowAdjustedOffsetY`（0 + 6）、小触发物修正 `arrowBoundingOffsetY` 6（tooltip 为 2）。
- 触发与关闭：hover 缺省（50/50 延迟）、Esc（`closeOnEsc: true`）、点外关闭（`onClickOutSide`）；`clickToHide` 点气泡自身关闭。受控 `visible` 只回调请求。

### 主题传递

popover 作用域在编译期遮蔽 tooltip 箭头变量（`$height-tooltip_arrow: $height-popover_arrow` 等）喂共享 `tooltip/arrow.scss`，并以 popover 自己的 animation 值跑 zoomIn/zoomOut——本地等价物是 `SemiPopover.build` 里的同名 `SemiTooltipTheme` 补丁（盒几何 + 角位 + 动画十项）。`SemiPopconfirm` 的箭头即此盒几何（24×8），同样经该补丁喂 shell。

### RTL

rtl.scss 的 `direction: rtl`（卡片）由 Directionality 承担；无边距镜像需求（with-arrow 内边距各向同性）。

## 主题（26 对账）

来源 packages/semi-foundation/popover/variables.scss（22 声明）+ animation.scss（4 声明）。对账 **26 = 20 FIELDS + 4 MOTION + 2 INTERNAL**（HARDCODES 另列见 B 表）。★**0 死变量**。全局 token 解析：`var(--semi-color-bg-3)` → `theme.colors.colorBg3`、`var(--semi-color-border)` → `theme.colors.colorBorder`、`var(--semi-border-radius-medium)` → `theme.radius.borderRadiusMedium.value`（generate_button 先例）。类型覆盖：**1 String + 4 Color + 15 double = 20 FIELDS**，MOTION 2 Duration + 2 Curve。解析列即 `SemiPopoverThemeData.resolve` 默认表达式。

### A. Sass 声明映射（20 FIELDS + 4 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$horizontal-rate: 0.24` | `_PopoverMetrics.horizontalRate` | 0.24（INTERNAL；`spacingTooltipArrowAdjustedOffsetX` 5.76 的 Sass 矫正因子，留档） |
| `$color-tooltip_arrow-icon-default: unset` | `colorTooltipArrowIconDefault` | `'unset'`（★非数值默认值留档（nav String 先例）——popover 作用域把 tooltip 箭头颜色覆写为 `unset`，Arrow 两路径显式 fill、`color` 属性不参与，本地无消费方） |
| `$color-popover-bg-default: var(--semi-color-bg-3)` | `colorPopoverBgDefault` | `theme.colors.colorBg3` |
| `$color-popover-border-default: var(--semi-color-border)` | `colorPopoverBorderDefault` | `theme.colors.colorBorder`（★`&-title` 描边，无渲染方） |
| `$color-popover-arrow-border: var(--semi-color-border)` | `colorPopoverArrowBorder` | `theme.colors.colorBorder`（fringe 描边，arrowStyle.borderColor 覆写） |
| `$color-popover-arrow-bg: var(--semi-color-bg-3)` | `colorPopoverArrowBg` | `theme.colors.colorBg3`（翼形填充，arrowStyle.backgroundColor 覆写） |
| `$width-popover_arrow: 24px` | `widthPopoverArrow` | 24（箭头盒宽） |
| `$height-popover_arrow: 8px` | `heightPopoverArrow` | 8（箭头盒高：翼 7 + fringe 溢出 1） |
| `$height-popover_arrow_vertical: 24px` | `heightPopoverArrowVertical` | 24（竖向箭头盒高） |
| `$width-popover_arrow_vertical: 8px` | `widthPopoverArrowVertical` | 8（竖向箭头盒宽） |
| `$height-tooltip_arrow: $height-popover_arrow` | `heightTooltipArrow` | `(heightPopoverArrow ?? 8)`（★别名声明，遮蔽 tooltip 变量喂共享 arrow.scss） |
| `$width-tooltip_arrow: $width-popover_arrow` | `widthTooltipArrow` | `(widthPopoverArrow ?? 24)`（★别名声明） |
| `$width-tooltip_arrow_vertical: $width-popover_arrow_vertical` | `widthTooltipArrowVertical` | `(widthPopoverArrowVertical ?? 8)`（★别名声明） |
| `$height-tooltip_arrow_vertical: $height-popover_arrow_vertical` | `heightTooltipArrowVertical` | `(heightPopoverArrowVertical ?? 24)`（★别名声明） |
| `$width-popover_title-border: 1px` | `widthPopoverTitleBorder` | 1（★`&-title` 钩子，无渲染方） |
| `$spacing-popover_title-padding: 8px` | `spacingPopoverTitlePadding` | 8（★`&-title` 钩子，无渲染方） |
| `$spacing-popover_withArrow-padding: 12px` | `spacingPopoverWithArrowPadding` | 12（`.semi-popover-with-arrow` 卡片外层内边距） |
| `$spacing-popover_arrow_adjusted_offset-y: 6px` | `spacingPopoverArrowAdjustedOffsetY` | 6（垂直方向校正偏移量） |
| `$spacing-tooltip_arrow_adjusted_offset-y: $spacing-popover_arrow_adjusted_offset-y` | `spacingTooltipArrowAdjustedOffsetY` | `(spacingPopoverArrowAdjustedOffsetY ?? 6)`（★别名声明） |
| `$spacing-tooltip_arrow_adjusted_offset-x: round($horizontal-rate * $width-tooltip_arrow)` | `spacingTooltipArrowAdjustedOffsetX` | 5.76（★对应 Sass `round(...)` 保留未取整值，generate_tooltip 先例；上游编译 6px） |
| `$radius-popover: var(--semi-border-radius-medium)` | `radiusPopover` | `theme.radius.borderRadiusMedium.value` |
| `$filter-popover-bg: none` | `_PopoverMetrics.filter` | `'none'`（INTERNAL；`backdrop-filter: $filter-popover-bg` 无效果） |
| `$animation_duration-popover-in: 100ms` | `animationDurationPopoverIn` | `const Duration(milliseconds: 100)`（MOTION） |
| `$animation_duration-popover-out: 100ms` | `animationDurationPopoverOut` | `const Duration(milliseconds: 100)`（MOTION） |
| `$animation_function-popover-in: cubic-bezier(0.215, 0.61, 0.355, 1)` | `animationFunctionPopoverIn` | `const Cubic(0.215, 0.61, 0.355, 1)`（MOTION） |
| `$animation_function-popover-out: cubic-bezier(0.215, 0.61, 0.355, 1)` | `animationFunctionPopoverOut` | `const Cubic(0.215, 0.61, 0.355, 1)`（MOTION） |

★别名声明统一说明：上游 popover/variables.scss 把 4 条箭头盒几何 + 1 条角位偏移以 tooltip 命名空间覆写（`$height-tooltip_arrow: $height-popover_arrow` 等），喂共享 `tooltip/arrow.scss` 的定位规则；本地以同名字段的 resolve 链（`heightTooltipArrow ?? heightPopoverArrow`）+ `SemiTooltipTheme` 同名补丁等价。

### B. HARDCODES 另列（widget 文件头注释 / 调用点，源内含原始片段）

| 上游片段 | 说明 |
|---|---|
| `prefixCls: cssClasses.PREFIX` | `semi-popover` 类前缀 |
| `arrowBounding: numbers.ARROW_BOUNDING`（`offsetY: 6`） | 箭头盒常量（offsetY 小触发物修正门限） |
| `showArrow: false` / `motion: true` / `autoAdjustOverflow: true` | defaultProps |
| `trigger: 'hover'` / `position: 'bottom'` | 默认触发与定位 |
| `zIndex: numbers.DEFAULT_Z_INDEX` | 1030 |
| `closeOnEsc: true` / `returnFocusOnClose: true` / `guardFocus: true` / `disableFocusListener: true` | defaultProps |
| `cancelText: 'No'` / `okText: 'Yes'` | legacy defaultProps（Popover 无消费方，PopConfirm 遗留） |
| `spacing = showArrow ? numbers.SPACING_WITH_ARROW : numbers.SPACING` | 10 : 4 |
| `? 'dialog' : 'tooltip'` | role（click/custom → dialog，未移植） |
| `className={popCardCls}` / `${prefixCls}-content` | renderPopCard 卡片结构 |
| `showArrow ? <Arrow {...arrowProps} /> : false` | 上游箭头节点（本地 bool + 自绘） |
| `z-index: $z-popover` | wrapper 层叠 |
| `@include shadow-elevated` | 卡片阴影 |
| `@include font-size-regular` | wrapper 字号 14/20 |
| `backdrop-filter: $filter-popover-bg` | backdrop filter（none） |
| `opacity: 0;` / `opacity: 1;` | wrapper 显隐态 |
| `padding: $spacing-popover_title-padding;` / `border-bottom: $width-popover_title-border solid $color-popover-border-default` | `&-title` 钩子 |
| `padding: $spacing-popover_withArrow-padding;` | `.semi-popover-with-arrow` 内边距 |
| `fill: $color-popover-arrow-border` / `fill: $color-popover-arrow-bg` | icon-arrow 两路径 CSS fill |
| `get(arrowStyle, 'borderOpacity')` / `get(arrowStyle, 'borderColor',` / `get(arrowStyle, 'backgroundColor',` | Arrow.tsx 着色回退链 |
| `animation: #{$module}-zoomIn $animation_duration-popover-in $animation_function-popover-in` | 显现动画 |
| `animation: #{$module}-zoomOut $animation_duration-popover-out $animation_function-popover-out` | 消失动画 |
| `direction: rtl` | rtl.scss 卡片方向 |

重新生成独立主题：`python3 tool/generate_popover.py`（包含 dart format）；对账校验 `python3 tool/test_generate_popover.py`。

## 差异清单

- **content**：上游节点或函数 `({ initialFocusRef })` → `Widget`（函数式未移植）。
- **arrowBounding**：上游 `{offsetX, offsetY, width, height}` → 只移植 `offsetY`（`arrowBoundingOffsetY`，小触发物修正门限，缺省 6）；width/height 由主题箭头盒几何承担，offsetX 上游无消费方。
- **arrowStyle.borderOpacity**：上游 `string | number` → `double?`（与 fringe fill alpha 相乘）。
- **spacing**：上游 `number | {x, y}` → 仅标量。
- **role / focus 系**：`role`（click/custom → dialog）、`guardFocus`、`returnFocusOnClose`、`disableFocusListener`、`disableArrowKeyDown` 未移植（shell 无 ARIA/焦点管理）。
- **未移植 API**：`className`/`style`（外层布局承担）、`contentClassName`、`prefixCls`、`getPopupContainer`、`margin`、`stopPropagation`、`keepDOM`、`condition`、`afterClose`、`rePosKey` 命名为 `repositionKey`。
- **cancelText/okText**：上游 defaultProps 遗留（Popover 无消费方）→ 仅 HARDCODES 留档。
- **`&-title` 钩子**：padding 8 + border-bottom 1px 上游亦无渲染方（内容侧 class 约定）→ 3 字段注释留档。
- **主题补丁的溢出**：`SemiTooltipTheme` 补丁 ≈ 上游编译期变量遮蔽；差异是内容内嵌套 tooltip 也继承补丁（上游不影响嵌套 tooltip 的独立编译样式）。
- **最小尺寸**：带箭头卡片 `min-width/min-height: 36px`（arrow.scss mixin）未移植——本地 tooltip 壳同样未实现按放置向的最小尺寸。
- **水平角位 5.76**：对应 Sass `round($horizontal-rate * $width-tooltip_arrow)` 保留未取整值（上游编译 6px），与 `SemiTooltipThemeData.arrowAdjustedOffsetX` 同一约定。

## 用法

```dart
SemiPopover(
  content: Padding(
    padding: const EdgeInsets.all(12),
    child: Text('Hi Bytedancer, this is a popover.'),
  ),
  child: const Text('Hover 我'),
)
```

```dart
SemiPopover(
  trigger: SemiTooltipTrigger.click,
  showArrow: true,
  arrowStyle: const SemiPopoverArrowStyle(
    borderColor: Color(0xff324350),
    backgroundColor: Color(0xff4cc3fa),
  ),
  content: Padding(
    padding: const EdgeInsets.all(12),
    child: Text('带箭头的气泡卡片'),
  ),
  child: const Text('点击我'),
)
```
