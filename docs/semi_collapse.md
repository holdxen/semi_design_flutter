# SemiCollapse 折叠面板

无需 Material，使用 `package:semi_design_flutter/semi_design_flutter.dart` 和 Flutter widgets。

```dart
SemiCollapse(
  defaultActiveKeys: const {'1'},
  accordion: false,
  children: const [
    SemiCollapsePanel(itemKey: '1', header: 'This is panel header 1', child: Text('Hi, bytedance dance dance.')),
    SemiCollapsePanel(itemKey: '2', header: 'This is panel header 2', extra: Text('1234'), child: Text('Hi, bytedance dance dance.')),
    SemiCollapsePanel(itemKey: '3', header: Text('Widget header'), showArrow: false, child: Text('Hi, bytedance dance dance.')),
  ],
)
```

## API 与边界

`SemiCollapse` 参数（`lib/src/components/semi_collapse.dart`，上游 `packages/semi-ui/collapse/index.tsx` + `foundation.ts`）：

| 字段 | 说明 | 默认 |
| --- | --- | --- |
| `activeKeys` | `Set<String>?`，**非 null 即受控**（含空集）：交互只回调、内部不改态，显示始终等于该集合 | null |
| `defaultActiveKeys` | 非受控初始有序激活集（`LinkedHashSet` 语义） | `const {}` |
| `accordion` | 手风琴：切换=只开目标；点击已展开面板全部收起（回传 `[]`） | `false` |
| `clickHeaderToExpand` | false 时仅箭头区域点击切换 | `true` |
| `expandIcon` / `collapseIcon` | 收起/展开态箭头 `Widget` | `SemiIcons.chevronDown` / `SemiIcons.chevronUp`（以 `item.tsx` 代码为准，见差异清单） |
| `expandIconPosition` | `SemiCollapseIconPosition.left`/`right` | `right` |
| `keepDOM` | 收起后保持内容构建、高度裁 0（State 不失效） | `false` |
| `lazyRender` | 首次展开才构建内容 | `false` |
| `motion` | 高度动画；`false` 瞬切 | `true` |
| `onActiveKeysChanged` | `ValueChanged<List<String>>`，每次切换回传**有序**结果 | - |
| `children` | `List<SemiCollapsePanel>`，`itemKey` 需唯一（debug assert） | 必填 |

`SemiCollapsePanel` 参数（上游 `Collapse.Panel`/`item.tsx`）：

| 字段 | 说明 | 默认 |
| --- | --- | --- |
| `itemKey` | 面板唯一键（上游 `itemKey`） | 必填 |
| `header` | `String`（渲染为 `SemiText`：weight=`fontCollapseHeaderFontWeight`、字号=实时 `typography.fontSizeRegular`）或 `Widget` 原样放置 | - |
| `extra` | 头部右端辅助区 `Widget`，**一律生效** | - |
| `showArrow` | 显示展开/收起箭头 | `true` |
| `disabled` | 不响应点击/键盘，disabled 配色 | `false` |
| `child` | 面板内容（上游 `children`） | - |
| `reCalcKey` | 上游高度重测触发键；本实现高度持续跟随内容，变化只触发重建（保留 API 对齐） | - |
| `onMotionEnd` | **收起**动画结束回调（见动画规则） | - |

嵌套：每个 `SemiCollapse` 自带 scope（镜像上游 `CollapseContext`），内层面板只读写最近的 scope，嵌套互不干扰。

## 展开语义

- **受控**：`activeKeys != null` 即受控——点击/键盘只回调 `onActiveKeysChanged`，内部不改态，父级更新 `activeKeys` 后显示才变。上游 `activeKey: ''` 的 falsy 陷阱不复刻：空集合也是受控（`activeKeys: const {}` 时点击只回传、不展开）。
- **非受控有序集**：初始 = `defaultActiveKeys` 顺序；切换追加/移除保持插入序（点击展开追加到末尾，收起移除；复刻上游 `Set` 插入序 `handleChange`）。`onActiveKeysChanged` 始终回传有序 `List<String>`。
- **accordion**：init 时 `defaultActiveKeys` 只保留首个（上游 `initActiveKey`）；点击其他面板 = 只开目标；点击已展开面板 → 全部收起并回传 `[]`（复刻 keyboard 测试语义）。
- **keepDOM**：`false`（默认）收起动画结束后销毁内容（State 失效）；`true` 保持构建、高度裁 0（State 保留）。
- **lazyRender**：`true` 时内容首次展开才构建（配合 `keepDOM` 语义与上游 `Collapsible.shouldRender` 一致）。
- **键盘**：头部可聚焦，Enter/Space 切换并消费事件（preventDefault 语义等价）；`disabled` 不响应；事件来自后代焦点（如 extra 内输入框）时不触发；无关按键不触发。`clickHeaderToExpand=false` 时键盘仅在箭头存在时切换（复刻上游 `trigger.click()` 语义）。
- **无障碍**：header 为 `Semantics(button, expanded, label=String header, enabled)`；内容区 `ExcludeSemantics` 对应上游 `aria-hidden`；箭头 `aria-hidden` 等价（`ExcludeSemantics`）。

## 动画规则

- 高度动画 250ms + `Cubic(0.25, 0.1, 0.25, 1)`（`animationDuration`/`animationCurve`，见映射表），控制器线性推进、由主题曲线变换高度系数。
- 实现为 `ClipRect + Align(heightFactor)`：内容按自然高度排版、从底部裁切，**展开态持续跟随内容高度**——`reCalcKey`、`MediaQuery.textScaler` 变化、嵌套展开等内层尺寸变化均天然不裁切、无陈旧缓存高度（`reCalcKey` 保留仅触发重建）。动画层（`AnimatedBuilder`）不重建子树，包装形状恒定、内容 State 不重挂载。
- 初始即展开的面板无入场动画（复刻上游初次渲染不跑 transition）。
- 收起动画结束（controller dismissed）→ 内容隐藏（`keepDOM=false` 时销毁）并回调 `onMotionEnd`；`motion=false` 或 `TickerMode` 关闭 / `MediaQuery.disableAnimations` 时瞬切且不回调。
- `onMotionEnd` 仅收起结束触发（见差异清单）。

## 主题

主题优先级：局部非空补丁（外到内 merge）> 当前 `SemiThemeData.components.collapse` > live global 默认值。`SemiCollapseTheme` 局部补丁跨 `SemiTheme` 边界继承：捕获只携带局部补丁快照，应用级与默认值在目标边界重新解析，相同 light/dark 模式下更新也通知。`copyWith`/`merge` 的 null 表示保留原值。

来源 `packages/semi-foundation/collapse/variables.scss`（20 声明）+ `packages/semi-foundation/collapsible/animation.scss`（6 声明），共 **26** 个声明 = **22** 个主题字段（下表 A 组，`tool/generate_collapse.py` 生成到 `semi_collapse_theme_data.dart`，全量）+ **4** 个 widget 内部常量（下表 B 组，`semi_collapse.dart` 的 `_CollapseMetrics`）；collapse.scss 的 3 个硬编码同入 B 组。**29 = 22 + 7** 为来源注释计数防漂移校验（`tool/test_generate_collapse.py`）。独立于 383 项 CSS manifest，不把 Sass 混入 CSS token 清单。

### A. 主题字段（22）

颜色 7（resolve 实时读取当前 global）：

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$color-collapse_item-border-default` | var(--semi-color-border) | colorCollapseItemBorderDefault → theme.colors.colorBorder |
| `$color-collapse_header-text-default` | var(--semi-color-text-0) | colorCollapseHeaderTextDefault → theme.colors.colorText0 |
| `$color-collapse_header-text-disabled` | var( --semi-color-disabled-text) | colorCollapseHeaderTextDisabled → theme.colors.colorDisabledText |
| `$color-collapse_header-icon-default` | var(--semi-color-text-2) | colorCollapseHeaderIconDefault → theme.colors.colorText2 |
| `$color-collapse_header-bg-hover` | var(--semi-color-fill-0) | colorCollapseHeaderBgHover → theme.colors.colorFill0 |
| `$color-collapse_header-bg-active` | var(--semi-color-fill-1) | colorCollapseHeaderBgActive → theme.colors.colorFill1 |
| `$color-collapse_content-text-default` | var(--semi-color-text-1) | colorCollapseContentTextDefault → theme.colors.colorText1 |

字体 1：

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$font-collapse_header-fontWeight` | $font-weight-bold (600) | fontCollapseHeaderFontWeight → theme.typography.fontWeightBold |

spacing 9（展开值：$spacing-tight 8、$spacing-extra-tight 4、$spacing-base 16）：

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$spacing-collapse_header-marginX` | $spacing-tight | spacingCollapseHeaderMarginX → 8 |
| `$spacing-collapse_header-marginY` | $spacing-extra-tight | spacingCollapseHeaderMarginY → 4 |
| `$spacing-collapse_header-padding` | $spacing-tight | spacingCollapseHeaderPadding → 8 |
| `$spacing-collapse_right-paddingRight` | $spacing-tight | spacingCollapseRightPaddingRight → 8 |
| `$spacing-collapse_header_iconLeft-marginRight` | 8px | spacingCollapseHeaderIconLeftMarginRight → 8 |
| `$spacing-collapse_content-paddingTop` | $spacing-extra-tight | spacingCollapseContentPaddingTop → 4 |
| `$spacing-collapse_content-paddingRight` | $spacing-base | spacingCollapseContentPaddingRight → 16 |
| `$spacing-collapse_content-paddingBottom` | $spacing-tight | spacingCollapseContentPaddingBottom → 8 |
| `$spacing-collapse_content-paddingLeft` | $spacing-base | spacingCollapseContentPaddingLeft → 16 |

圆角/宽度/尺寸 3：

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$radius-collapse_header` | var(--semi-border-radius-small) | radiusCollapseHeader → theme.radius.borderRadiusSmall.value (3) |
| `$width-collapse_item-border` | 1px | widthCollapseItemBorder → 1 |
| `$size-collapse_icon-default` | $width-icon-medium (16px) | sizeCollapseIconDefault → 16 |

动画 2（collapsible 高度过渡）：

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$transition_duration-collapsible-height` | 250ms | animationDuration → Duration(ms: 250) |
| `$transition_function-collapsible-height` | cubic-bezier(0.25,0.1,0.25,1) | animationCurve → Cubic(0.25, 0.1, 0.25, 1) |

### B. widget 内部常量（7，不进主题，`_CollapseMetrics`）

| 常量 | Sass / 硬编码 | 值 | 用途 |
| --- | --- | --- | --- |
| `transitionDelayHeight` | `$transition_delay-collapsible-height: var(--semi-transition_delay-none)` | 0 | 高度过渡无延迟 |
| `transitionDurationOpacity` | `$transition_duration-collapsible-opacity: 250ms` | 250ms | 未使用：上游 Collapsible `fade` 默认 false，透明度恒 1 |
| `transitionFunctionOpacity` | `$transition_function-collapsible-opacity: var(--semi-transition_function-easeIn)` | Curves.easeIn | 同上 |
| `transitionDelayOpacity` | `$transition_delay-collapsible-opacity: var(--semi-transition_delay-none)` | 0 | 同上 |
| `headerBaseFontSize` | `@include font-size-regular` | 14 | 头部字号实际实时引用 `typography.fontSizeRegular`，留档 mixin 出处 |
| `contentBaseFontSize` | `@include font-size-regular` | 14 | 内容字号同上 |
| `iconDisabledColor` | `color: var(--semi-color-disabled-text)` | - | 上游禁用箭头硬编码色；移植改取 `colorCollapseHeaderTextDisabled`（改良） |

## 布局

header 三段式 `Row`（`crossAxisAlignment: center`）：

```
right（默认）  │ title(Expanded) │ extra(+8 gap)  ⌄ │
left           │ ⌄(+8 margin) │ title(Expanded) │ extra │
Widget header  同上，title 原样放置；extra 两类 header 均渲染
```

- 头部盒：margin（`marginX` 8 / `marginY` 4）+ 圆角（`radiusCollapseHeader`）+ padding（8）+ hover（`colorCollapseHeaderBgHover`）/ pressed（`colorCollapseHeaderBgActive`）背景，均由 `MouseRegion`/`Listener` 驱动；`disabled` 不变色不响应。
- extra 的 8px 间距（`spacingCollapseRightPaddingRight`）仅在箭头与其同处尾部区块时出现（上游 `header-right` 的 `last-child` 规则）；箭头左置时 icon 带 `spacingCollapseHeaderIconLeftMarginRight`（8）。
- 箭头 16×16（`sizeCollapseIconDefault`），色 `colorCollapseHeaderIconDefault`；禁用/无内容时上游 `header-iconDisabled`（色见 B 组改良）。禁用面板即使展开也显示 `expandIcon`（上游 `renderHeader` 语义）。
- 内容区 padding（4 16 8 16）+ 文字色 `colorCollapseContentTextDefault`（`DefaultTextStyle` 注入）。
- 面板分隔线：**每个面板（含末项）**底部 1px（`widthCollapseItemBorder`）`colorCollapseItemBorderDefault`——上游 `collapse.scss` 的 `&-item { border-bottom }` 对所有 item 生效。
- String header：`SemiText`，weight=`fontCollapseHeaderFontWeight`、字号=实时 `typography.fontSizeRegular`、颜色 `colorCollapseHeaderTextDefault`（disabled→`colorCollapseHeaderTextDisabled`）。
- RTL（rtl.scss）：`EdgeInsetsDirectional`/`Row` 方向性自动镜像——箭头左右互换、margin/padding 随逻辑边翻转。
- 窄宽度下 title 收缩换行、尾部区块保持自然宽度（超窄会像上游一样溢出，测试取 160 不溢出）；无界宽度退化为内容宽度横排（title 不再伸展）。

## 差异清单

- **受控语义**：`activeKeys` 非 null 即完全受控（含空集），不复刻上游 `activeKey: ''`/空数组 falsy 陷阱（上游空值会被当作非受控、点击直接改内部状态）。
- **extra 统一生效**：上游 `extra` 仅在 header 为 string 时渲染（ReactNode header 需自行渲染辅助区）；移植中 `extra` 一律渲染在头部右端。
- **图标默认值以代码为准**：上游文档（`content/show/collapse/index.md`）把默认写反（称 `expandIcon` 默认 `<IconChevronUp />`、`collapseIcon` 默认 `<IconChevronDown />`）；`item.tsx` 实际是 `expandIcon=chevronDown`（收起态）、`collapseIcon=chevronUp`（展开态），移植从代码。
- **iconDisabled 色改良**：上游禁用/无内容箭头颜色硬编码 `var(--semi-color-disabled-text)`，移植取主题 `colorCollapseHeaderTextDisabled` 以便覆盖。
- **onMotionEnd 仅收起触发**：上游 `transitionend` 展开/收起结束都回调；移植按计划只在收起动画结束（controller dismissed，替代上游 duration+50ms 兜底定时器）回调并隐藏内容，`motion=false` 不回调。
- **键盘**：Enter/Space 处理等价（disabled/后代焦点/无关按键不触发、preventDefault）；`clickHeaderToExpand=false` 时仅当 `showArrow` 为 true 才切换（上游对箭头 trigger 调 `click()`，箭头缺失则不触发）。
- **iconLeft 布局**：上游 `header-iconLeft` 的 `justify-content: flex-start` 会把 string header 的 `header-right`（extra）紧贴标题打包在左侧；移植按“右上角辅助区域”语义把 extra 固定在右端（`expandIconPosition=left` 时仅箭头移到左端）。
- **reCalcKey**：参数保留但不再显式测高——高度由 `Align(heightFactor)` 持续跟随内容（reCalcKey 变化触发重建），不存在上游 ResizeObserver 的陈旧高度窗口。
- **嵌套**：上游靠 `CollapseContext` 逐层覆盖；移植以内部 scope `InheritedWidget` 天然隔离，语义一致。
- **未移植**：`className`/`style`（Dart 侧外层包裹）、`motion` 传函数/对象（仅 bool）、`onChange` 的事件对象（只有有序 keys 回调）、`Collapse` 上的 `data-*` 透传、Collapsible 的 `collapseHeight`/`collapseHeightAdaptive`/`fade`/SSR id（`aria-owns` 关系由 Flutter 语义树承担，未建 id 关联）。
