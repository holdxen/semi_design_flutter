# SemiAutoComplete 自动完成

无需 Material，使用 `package:semi_design_flutter/semi_design_flutter.dart` 和 Flutter widgets。以 `SemiInput` 为输入底座、`SemiTooltip` 为弹层底座（`trigger: custom`、`showArrow: false`、`popupBare: true`，弹层自绘 Popover 表面）。

```dart
SemiAutoComplete(
  data: const [
    SemiAutoCompleteOption(value: 'Semi Design'),
    SemiAutoCompleteOption(value: 'Semi Motion', disabled: true),
    SemiAutoCompleteOption(value: 2024), // num 项以 toString() 匹配
  ],
  showClear: true,
  onSearch: (input) {
    // 无内置过滤：在这里更新 data
  },
  onSelect: (option) => debugPrint('selected ${option.value}'),
)
```

## API

`SemiAutoComplete` 参数（`lib/src/components/semi_autocomplete.dart`，上游 `packages/semi-ui/autocomplete/index.tsx` + `foundation.ts`）：

| 字段 | 说明 | 默认 |
| --- | --- | --- |
| `data` | `List<SemiAutoCompleteOption>` 候选项；`show: false` 不渲染（上游 `item.show`） | `const []` |
| `value` | `String?` **非空即受控**（SemiInput 统一惯例）：显示文本 = `value` 在 data 中匹配项的 `renderSelectedItem`（匹配 `o.value.toString() == value`），找不到显示原文；编辑/选中只回调 | null |
| `initialValue` | 非受控种子，按同规则解析并记录选中项（上游 `defaultValue`） | null |
| `onChanged` | `ValueChanged<String>` 编辑与选中（新显示文本）都通知（上游 `onChange`） | - |
| `onSearch` | `ValueChanged<String>` 每次编辑通知原始输入（上游 `onSearch`），过滤由使用方在此更新 `data` | - |
| `onSelect` | `ValueChanged<SemiAutoCompleteOption>` **始终回传整个 option**（有意偏离上游 `onSelectWithObject` 开关，见差异清单） | - |
| `onClear` | `VoidCallback` 清除点击后回调（在 `onChanged('')`/`onSearch('')` 之后） | - |
| `onDropdownVisibleChange` | `ValueChanged<bool>` 面板开合变化都回调 | - |
| `onFocusChange` / `onBlur` | 透传 `SemiInput`；**blur 不关面板**（上游 `handleBlur` 只通知） | - |
| `renderSelectedItem` | `String Function(SemiAutoCompleteOption)?` 选中/解析的显示文本；默认 `o.value.toString()`（上游默认取 value 不是 label），限 String 返回 | - |
| `renderItem` | `Widget Function(SemiAutoCompleteOption)?` 替换选项面板内容（上游 `renderItem`）；关键词高亮只作用于内置文本渲染 | - |
| `showClear` | 显示清除按钮（hover/聚焦且非空时） | `false` |
| `clearIcon` | 自定义清除图标 | - |
| `size` | `SemiInputSize`（small/normal/large） | `normal` |
| `disabled` | 禁用（不响应点击/键盘/输入） | `false` |
| `placeholder` | 占位文本 | null |
| `prefix` / `suffix` / `insetLabel` | `Object?` String 或 Widget，透传 `SemiInput` | - |
| `loading` | 加载态：`SemiSpin` 加载区替换选项列表 | `false` |
| `emptyContent` | `data` 为空时的面板内容；null 时面板不渲染内容（上游同） | null |
| `dropdownMatchSelectWidth` | true 时面板 `minWidth` = 输入框实测宽（开面板时记录） | `true` |
| `maxHeight` | 面板高度上限 | 300 |
| `position` | `SemiTooltipPosition` 12 方位 | `bottomLeft` |
| `defaultOpen` | 初始展开面板（通知延后到首帧后） | `false` |
| `defaultActiveFirstOption` | 面板打开/数据或输入变化时高亮第一个**启用**项 | `false` |
| `autoFocus` | 初始聚焦输入框 | `false` |
| `validateStatus` | `SemiInputStatus` 透传 | `normal` |
| `motion` | 显隐动画（沿用底座） | `true` |
| `controller` / `focusNode` | 外部传入，不自释放 | - |
| `semanticsLabel` | 透传 `SemiInput` | - |

候选项 `SemiAutoCompleteOption`：

| 字段 | 说明 | 默认 |
| --- | --- | --- |
| `value` | `Object`（String 或 num），受控 `value` 以 `toString()` 匹配 | 必填 |
| `label` | `Widget?` 面板展示内容；null → `Text(text ?? value.toString())` 内含关键词高亮 | null |
| `text` | `String?` 纯文本（高亮/匹配用）；null → `value.toString()` | null |
| `show` | 上游 `item.show` 强制隐藏 | `true` |
| `disabled` | 禁色、不响应点击、键盘跳过 | `false` |

## 行为

**无内置过滤**（上游核心约定）：`onSearch`/`onChanged` 只通知，过滤由使用方在 `onSearch` 里更新 `data`；`show: false` 项不渲染。

**面板开**：点击输入框 toggle（disabled 不响应，清除按钮点击不算 toggle）；输入变化自动开；ArrowUp/ArrowDown 面板未开时开；`defaultOpen` 初始开。
**面板关**：再次点击输入框；Escape（消费）/Tab（不消费，焦点移动继续）；选中后；点击外部（底座 outside barrier 的 `onVisibleChange(false)` 同步内部状态）；**blur 不关**。
开合变化都回调 `onDropdownVisibleChange`。

**选中**：输入框文本 = `renderSelectedItem(option)`；**受控**（`value` 非空）只回调不改文本（等父级更新 `value`）；**非受控**落地文本。两者都：`onSelect(option)` + `onChanged(新文本)` + 关面板。默认 `renderSelectedItem` 取 `value.toString()` 而不是 label。

**受控 value → 显示文本解析**（上游 `handleValueChange`）：在 data 中找 `o.value.toString() == value` 的项 → 显示 `renderSelectedItem(该项)` 并记录为选中项（面板 option 渲染 `-selected` 加粗）；找不到 → 显示 `value` 原文。

**清除链路**：`showClear` 点击 → `onChanged('')` + `onSearch('')` + `onClear()`，并按"输入变化"规则展开面板。

**键盘**（外层 `Focus(canRequestFocus: false, skipTraversal: true)` 包住 `SemiInput`，Enter 走 `SemiInput.onEnterPress` 单通道，不拦截左右方向键）：

- **ArrowDown/ArrowUp**：面板未开 → 开面板；已开 → 焦点索引在**启用项**间循环移动（到顶回底、到底回顶，跳过 disabled），鼠标 hover 同步该索引（上游 hover 即 `-focused` 态，无独立 hover 样式），并 `Scrollable.ensureVisible` 滚动到位；事件消费。
- **Enter**（`onEnterPress` 通道）：面板未开 → 开；开且焦点索引有效 → 选中该项；开但无焦点 → 关。`done` 动作会先失焦（EditableText 默认），处理器内重新请求焦点保持输入（上游 Enter 后焦点保留）。
- **Escape**：关面板（消费）；**Tab**：关面板但不消费。无 Home/End（上游同）。
- **defaultActiveFirstOption**：面板打开时/面板开着期间 data 或输入变化时，true → 焦点索引 = 第一个启用项；false → -1（无高亮，Enter 只关面板）。

**面板内容**：`loading` → `SemiSpin` 加载区（上下 padding `spacingAutoCompleteLoadingWrapperPaddingTop/Bottom`，高 20 硬编码）并隐藏选项列表；`data` 空且 `emptyContent` 非空 → `emptyContent`；否则选项列表（只渲染 `show` 项）。

**选项视觉**（option.scss）：padding 12/12/8/8、首项 marginTop 4 / 末项 marginBottom 4、圆角 0、文字色 text-0、字号 14（`@include font-size-regular` 实时读 `typography.fontSizeRegular`）、键盘/鼠标焦点态背景 fill-0、按下 fill-1、选中加粗（`$font-weight-bold` → `typography.fontWeightBold`）、disabled 色 disabled-text、关键词高亮复用 `SemiHighlight`（命中色 `colorAutoCompleteOptionKeywordText` + 字重 `fontAutoCompleteKeywordFontWeight`，透明底）。tick 图标字段保留对账但**固定不渲染**（上游 `showTick={false}`）。

**弹层**：`SemiTooltip(trigger: custom, visible, onVisibleChange, showArrow: false, popupBare: true, position/motion 透传)`，面板自绘 Popover 表面（bg-3 + 1px border + radius-medium + shadow-elevated，见 HARDCODES）。RTL 用 `EdgeInsetsDirectional`/`AlignmentDirectional`；文字缩放不溢出。

## 主题

主题优先级：局部非空补丁（外到内 merge）> 当前 `SemiThemeData.components.autocomplete` > live global 默认值。`SemiAutoCompleteTheme` 局部补丁跨 `SemiTheme`/Overlay 边界继承（捕获只携带局部补丁快照）。`copyWith`/`merge` 的 null 表示保留原值。

来源 `packages/semi-foundation/autoComplete/variables.scss`（36 声明，其中 8 个 color 在文件内同值重复声明两遍）+ `packages/semi-foundation/autoComplete/animation.scss`（3 声明），共 **39** 条声明 = **31** 个唯一名 = **28** 个主题字段（下表 A 组，`tool/generate_autocomplete.py` 生成到 `semi_autocomplete_theme_data.dart`）+ **3** 个 MOTION 字段（动画三元组）+ **0** 个 widget 内部声明；autoComplete.scss / option.scss / popover.scss 的 15 个硬编码进 B 组（`_AutoCompleteMetrics`）。重复的 8 条声明与首声明值逐字节一致（`tool/test_generate_autocomplete.py` 防漂移断言）。独立于 383 项 CSS manifest。

### A. 主题字段（31 = 28 FIELDS + 3 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-autoComplete_option_keyword-text: var(--semi-color-primary)` | colorAutoCompleteOptionKeywordText | theme.colors.colorPrimary（关键词高亮色） |
| `$color-autoComplete_option-bg-default: transparent` | colorAutoCompleteOptionBgDefault | Color(0x00000000)（上游未消费） |
| `$color-autoComplete_option-icon-default: transparent` | colorAutoCompleteOptionIconDefault | Color(0x00000000) |
| `$color-autoComplete_option-bg-hover: var(--semi-color-fill-0)` | colorAutoCompleteOptionBgHover | theme.colors.colorFill0（`-focused` 态） |
| `$color-autoComplete_option-bg-active: var(--semi-color-fill-1)` | colorAutoCompleteOptionBgActive | theme.colors.colorFill1（`:active` 态） |
| `$color-autoComplete_option_disabled-text: var(--semi-color-disabled-text)` | colorAutoCompleteOptionDisabledText | theme.colors.colorDisabledText |
| `$color-autoComplete_option_disabled-bg: transparent` | colorAutoCompleteOptionDisabledBg | Color(0x00000000)（上游未消费） |
| `$color-autoComplete_option-icon-active: var(--semi-color-text-2)` | colorAutoCompleteOptionIconActive | theme.colors.colorText2 |
| `$color-autoComplete_option-border-default: var(--semi-color-border)` | colorAutoCompleteOptionBorderDefault | theme.colors.colorBorder（上游未消费） |
| `$color-autoComplete_option_main-text: var(--semi-color-text-0)` | colorAutoCompleteOptionMainText | theme.colors.colorText0 |
| `$width-autoComplete_option_tick: $width-icon-small` | widthAutoCompleteOptionTick | 12（tick 固定不渲染，字段留档） |
| `$spacing-autoComplete_loading_wrapper-paddingTop: $spacing-tight` | spacingAutoCompleteLoadingWrapperPaddingTop | 8（loading 区上 padding） |
| `$spacing-autoComplete_loading_wrapper-paddingBottom: $spacing-tight` | spacingAutoCompleteLoadingWrapperPaddingBottom | 8 |
| `$spacing-autoComplete_option_tick-marginRight: $spacing-tight` | spacingAutoCompleteOptionTickMarginRight | 8（tick 固定不渲染，字段留档） |
| `$spacing-autoComplete_option-paddingLeft: $spacing-base-tight` | spacingAutoCompleteOptionPaddingLeft | 12 |
| `$spacing-autoComplete_option-paddingRight: $spacing-base-tight` | spacingAutoCompleteOptionPaddingRight | 12 |
| `$spacing-autoComplete_option-paddingTop: $spacing-tight` | spacingAutoCompleteOptionPaddingTop | 8 |
| `$spacing-autoComplete_option-paddingBottom: $spacing-tight` | spacingAutoCompleteOptionPaddingBottom | 8 |
| `$spacing-autoComplete_option_first-marginTop: $spacing-extra-tight` | spacingAutoCompleteOptionFirstMarginTop | 4（首项上边距） |
| `$spacing-autoComplete_option_last-marginBottom: $spacing-extra-tight` | spacingAutoCompleteOptionLastMarginBottom | 4（末项下边距） |
| `$spacing-autoComplete_option_list-paddingTop: 0px` | spacingAutoCompleteOptionListPaddingTop | 0（上游未消费） |
| `$spacing-autoComplete_option_list-paddingRight: 0px` | spacingAutoCompleteOptionListPaddingRight | 0（上游未消费） |
| `$spacing-autoComplete_option_list-paddingBottom: 0px` | spacingAutoCompleteOptionListPaddingBottom | 0（上游未消费） |
| `$spacing-autoComplete_option_list-paddingLeft: 0px` | spacingAutoCompleteOptionListPaddingLeft | 0（上游未消费） |
| `$radius-autoComplete_option: 0px` | radiusAutoCompleteOption | 0 |
| `$font-autoComplete-fontWeight: $font-weight-regular` | fontAutoCompleteFontWeight | theme.typography.fontWeightRegular（上游未消费） |
| `$font-autoComplete_inset_label-fontWeight: 600` | fontAutoCompleteInsetLabelFontWeight | theme.typography.fontWeightBold（上游未消费；insetLabel 字重由 SemiInput 管理） |
| `$font-autoComplete_keyword-fontWeight: 600` | fontAutoCompleteKeywordFontWeight | theme.typography.fontWeightBold（关键词字重） |
| `$transition_duration-autoComplete_option-bg: var(--semi-transition_duration-none)` | transitionDurationAutoCompleteOptionBg | Duration.zero（token 实测 0ms；驱动选项背景 `AnimatedContainer`） |
| `$transition_function-autoComplete_option-bg: var(--semi-transition_function-easeIn)` | transitionFunctionAutoCompleteOptionBg | Curves.easeIn |
| `$transition_delay-autoComplete_option-bg: var(--semi-transition_delay-none)` | transitionDelayAutoCompleteOptionBg | Duration.zero（`AnimatedContainer` 无 delay 对应物，仅留档） |

死变量 9 条（上游未消费）：`$color-autoComplete_option-bg-default`、`$color-autoComplete_option_disabled-bg`、`$color-autoComplete_option-border-default`、`$spacing-autoComplete_option_list-padding{Top,Right,Bottom,Left}`、`$font-autoComplete-fontWeight`、`$font-autoComplete_inset_label-fontWeight`。

### B. widget 内部常量（HARDCODES，不进主题，`_AutoCompleteMetrics`）

| 常量 | Sass / 硬编码 | 值 | 用途 |
| --- | --- | --- | --- |
| `popoverSurfaceBg` | `$color-popover-bg-default: var(--semi-color-bg-3)` | theme.colors.colorBg3 | 弹层表面背景（上游弹层是 Popover 浅色表面，非 Tooltip 深灰气泡；实时引用） |
| `popoverSurfaceBorder` | `$color-popover-border-default: var(--semi-color-border)` | theme.colors.colorBorder | 弹层 1px 描边（实时引用） |
| `popoverSurfaceRadius` | `$radius-popover: var(--semi-border-radius-medium)` | theme.radius.borderRadiusMedium.value | 弹层圆角（实时引用） |
| `popoverFilterBg` | `$filter-popover-bg: none` | none | 上游 `backdrop-filter: none`，无滤镜 |
| `popoverZIndex` | `z-index: $z-popover` | 1030 | `$z-popover: 1030`（semi-theme-default/variables.scss）；透传 `SemiTooltip.zIndex`，实际层叠由插入顺序决定 |
| `popoverOpacityHidden` | `opacity: 0` | 0 | popover wrapper 隐藏态；移植由底座 FadeTransition 承担 |
| `popoverOpacityShown` | `opacity: 1` | 1 | popover wrapper 显示态（`-wrapper-show`） |
| `shadowElevatedBlur` | `0 0 1px rgba(0, 0, 0, .3)` | BoxShadow(blur 1) | `@include shadow-elevated` 第一层（global.scss），仅取 light 值 |
| `shadowElevatedDrop` | `0 4px 14px rgba(0, 0, 0, .1)` | BoxShadow(0,4,blur 14) | `@include shadow-elevated` 第二层 |
| `loadingWrapperHeight` | `height: 20px` | 20 | autoComplete.scss `&-loading-wrapper` 加载区高度 |
| `optionBaseFontSize` | `@include font-size-regular` | 14 | 选项字号实际实时引用 `typography.fontSizeRegular`，留档 mixin 出处 |
| `optionSelectedFontWeight` | `font-weight: $font-weight-bold` | w600 | option.scss `&-selected` 加粗；实际实时引用 `typography.fontWeightBold` |
| `optionListOverflowX` | `overflow-x: hidden` | hidden | autoComplete.scss `&-option-list`；渲染为面板 `SingleChildScrollView` |
| `optionListOverflowY` | `overflow-y: auto` | auto | 同上（纵向滚动 + `maxHeight` 截断） |
| `maxHeightDefault` | `maxHeight: 300` | 300 | semi-ui/autocomplete/index.tsx `defaultProps`；`SemiAutoComplete.maxHeight` 默认值 |

## 差异清单

- **onSelectWithObject → 强类型 onSelect**：`onSelect` 始终回传整个 `SemiAutoCompleteOption`（上游 `onSelectWithObject` 开关 + 泛型 string|number 回调不移植）。
- **onChangeWithObject 死 prop 不移植**（上游声明后未消费）。
- **triggerRender 延后**：自定义触发渲染（连带 `componentProps`）未移植；`prefix`/`suffix`/`showClear`/`validateStatus`/`size` 保留为一等参数。
- **value 仅 String**：上游 `value` 是 string|num；num 项以 `value.toString()` 匹配（`SemiAutoCompleteOption.value` 仍接受 num）。
- **无内置过滤**：与上游一致，`onSearch` 只通知；**onSearch 无防抖**（上游同）。
- **无 Home/End**（上游同）；**blur 不关面板**（上游同）。
- **renderSelectedItem 限 String 返回**（上游同；Select 才有 ReactNode）。
- **弹层表面取自 Popover**：AutoComplete 无自有表面变量，弹层 bg/border/radius 借 `popover/variables.scss` 并入 HARDCODES（实时引用 live token）。
- **addon 不透传**（上游同：`prepend`/`append` 不开放给 AutoComplete）。
- **tick 固定不显示**：上游 `renderOption` 传 `showTick={false}`，`$width-autoComplete_option_tick`/`$spacing-autoComplete_option_tick-marginRight` 只留档对账。
- **关键词高亮实装**：上游 `Option` 未收到 `inputValue` prop，`Highlight` 实际不渲染；移植按设计用 `SemiHighlight` 对当前输入值做命中（色 #1 + 字重 #28）。
- **受控解析匹配**：`value` 匹配 `o.value.toString()`（上游 `handleValueChange` 匹配 `renderSelectedItem(option)`，默认渲染器下两者一致）。
- **点击输入框 toggle**：清除按钮点击不参与 toggle（留待清除链路），拖出输入框释放不 toggle；上游整框 click 直接 toggle。
- **Enter 后保持焦点**：`done` 动作默认失焦（EditableText），处理器重新请求焦点对齐上游 Enter 语义。
- **面板宽度**：`dropdownMatchSelectWidth` 只实现 `minWidth` = 实测输入宽（上游 `style.width` 覆盖分支未移植）；面板在 Overlay 中按内容收缩 + minWidth 铺满（选项行通栏）。
- **底座 outside barrier 扩展到 custom 触发**：`semi_tooltip.dart` 的 `_needsOutsideBarrier` 原本不含 `custom`，为交付"点击外部关面板"契约补上（仅多一层指针观察 Listener，不拦截事件；custom 的可见性仍完全由调用方驱动，外部点击只回调 `onVisibleChange(false)`）。
- **未移植**：`className`/`style`/`dropdownClassName`/`dropdownStyle`（Dart 侧外层包裹）、`getPopupContainer`（Flutter 无 portal 容器选择）、`mouseEnterDelay`/`mouseLeaveDelay`（custom 触发无 hover 开合）、`stopPropagation`（无 DOM 事件冒泡）、`onKeyDown` 回调（无事件对象）、aria-* 透传字段、motion 传函数/对象（仅 bool）。
