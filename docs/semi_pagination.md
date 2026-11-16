# SemiPagination

翻页器（上游 Semi Pagination 全件移植）：容量（`total`/`pageSize`/`pageSizeOpts`）+ 截断页码列表（`PAGE_SHOW_MAX: 7`）+ prev/next + 每页条数切换器（`SemiSelect`）+ 快速跳转（`SemiInputNumber`）+ 省略号 rest 弹层（hover Popover → SemiDropdown content 自绘列表；react-window 虚拟化 → `ListView.builder`）+ small 尺寸摘要盒（`current/total`，`hoverShowPageSelect` 时 hover 出全页码）。主题对账 **48 = 41 FIELDS + 7 MOTION + 0 INTERNAL**（variables.scss 41 + animation.scss 7 亲验——**活文件**（pagination.scss:2 `@import "./animation.scss"` + :48-50 消费，0ms/ease-in/0ms/scale(1,1) 恒等）；`$module: #{$prefix}-page` 类名胶水不计，datePicker `223 = 220 + 3 + 0`、timePicker `20 = 14 + 6 + 0`、transfer `50 = 47 + 3 + 0`、anchor `30 = 26 + 4 + 0`、breadcrumb `20 = 16 + 4 + 0` 先例）；★**1 死变量**（`$color-pagination_item-bg-default` 声明后 pagination.scss 零消费——:hover/:active/-disabled 各走专属背景 token，default 态由 `ul` 自身透明呈现）。

## API

`SemiPagination({total: 1, showTotal: false, pageSize, pageSizeOpts: const [10, 20, 40, 100], size: SemiPaginationSize.defaultSize, currentPage, defaultCurrentPage: 1, onPageChange, onPageSizeChange, onChange, prevText, nextText, showSizeChanger: false, showQuickJumper: false, popoverZIndex: 1030, popoverPosition, hideOnSinglePage: false, hoverShowPageSelect: false, disabled: false, preventPageChangeOnPageSizeChange: false})`。

total `int`（★该库语义：`ceil(total/pageSize)` 得**总页数**，非条目总数回显——index.tsx:136/:513）。showTotal `false`（`总页数：N` 文本，仅 default 尺寸）。pageSize `int?`（半受控：非 null 作为初值/变更源；切换器交互只改内部态并回调——上游 state.pageSize + componentDidUpdate 同步）。pageSizeOpts `List<int>`（`PAGE_SIZE_OPTION`；当前 pageSize 不在其中时按序插入）。size `SemiPaginationSize`（`defaultSize` | `small`；`default` 是保留字照 `defaultSize` 先例）。currentPage `int?`（非 null 即受控：交互只发回调、展示跟随 props；★0 按 JS falsy 回退 defaultCurrentPage）。defaultCurrentPage `1`。onPageChange `ValueChanged<int>?`（goPage 先发）。onPageSizeChange `ValueChanged<int>?`（容量切换先发）。onChange `void Function(int currentPage, int pageSize)?`（单次变更最后发）。prevText/nextText `Object?`（String | Widget；缺省 `IconChevron{Left,Right} size="large"`）。showSizeChanger `false`（`li.-switch` 下 [SemiSelect]）。showQuickJumper `false`（`跳至 [n] 页`）。popoverZIndex `1030`（Popover `DEFAULT_Z_INDEX`；照 SemiTooltip 口径仅 API 对齐，叠放由 Overlay 插入序决定）。popoverPosition `SemiTooltipPosition?`（缺省 bottom——Popover `defaultProps.position`；size 切换器另按 RTL 缺省 bottomRight）。hideOnSinglePage `false`（★与 showSizeChanger 同开时上游 warning 且该开关失效——index.tsx:155-158，照抄不 assert）。hoverShowPageSelect `false`（small 摘要盒 hover 出全页码弹层）。disabled `false`。preventPageChangeOnPageSizeChange `false`（容量变更不重算当前页）。

## 行为

### 容量与截断

每页条数 `pageSize ?? pageSizeOpts[0] ?? 10`（★JS truthy 回退：0/空候选落到下一档，index.tsx:132）；总页数 `ceil(total/pageSize)`；总页数 ≤ `PAGE_SHOW_MAX`(7) 全量展示，> 7 按当前页截断（foundation.ts:151-214，t 总页数 / c 当前页）：`c<4` → `[1,2,3,4,...,t-1,t]`；`c==4` → `[1..5,...,t]`；`4<c<t-3` → `[1,...,c-1,c,c+1,...,t]`；其余 → `[1,...,t-4..t]`（★ `:203` 条件恒真作 fallback）。截断格恒 7 个；省略号左右 rest 列表（`REST_PAGE_MAX_SIZE: 1000000` 上限）随 hover 弹层展示（左侧 `i<3`、右侧其余）。

### 翻页与禁用

`goPage`（foundation.ts:73-92）：`'...'`/同页由调用方守卫；★受控（`currentPage != null`）只回调不改内部态；未受控直接 `setState`；两种都 `onPageChange(page)` + `onChange(page, pageSize)`。prev/next 禁用矩阵（foundation.ts:55-71）：`currentPage===1` → prev 禁用且 `nextDisabled = 总页数<2`；`currentPage===总页数` → next 禁用；★中间页恒两侧可用、`currentPage` 越界时 next 反而启用 quirk 照抄。

### 容量切换

`changePageSize`（foundation.ts:216-237）：改内部 pageSize → `onPageSizeChange(newSize)` → 默认重算当前页「保留当前页首条所在页」`ceil(((currentPage-1)*pageSize+1)/newSize)`（`preventPageChangeOnPageSizeChange` 关闭）→ 变了才 `onPageChange` → `onChange(newPage, newSize)`（通知顺序照抄）。切换器选项标签走 locale 模板 `每页条数：${pageSize}`；当前 pageSize 不在 `pageSizeOpts` 时按序插入（foundation.ts:243-253）。

### 快速跳转

`跳至 [n] 页`（index.tsx:330-359）：总页数 1 或整体禁用时全禁用；blur（输入非空）或 Enter 提交（foundation.ts:255-293）：解析为数字（NaN 忽略）→ 夹到 `[1, 总页数]` → 清空输入 → goPage。★上游 `Number()` 允许小数（页码语义下收敛 int，见差异清单）。

### small 尺寸

`-small`：regular 字号 + `fontPaginationSmallFontWeight` + text-2 色 + small padding；内容 = `[prev, current/total 摘要盒, next, jump]`（摘要盒走 `-item -item-small` 色态矩阵；★`role="none"` 的 prev/next 不承担分页语义 quirk 照抄）。`hoverShowPageSelect && !disabled` 时摘要盒挂 Popover（hover）列出全部页码。

### 视觉与 RTL

41 字段消费：页码盒高 32 / 最小宽 32（small 44、margin 归零）、边框宽 0、圆角 `border-radius-small`(3)、两侧 margin 4、字号 14、字重 400（选中 600）、六态色（default/hover/active/selected/disabled/selected-disabled）+ prev/next 图标色系、总页数 text-2、跳转禁用色、rest 列表上下 padding 4 + 行高 32 + 宽 78（最多 5 行）；MOTION 7 消费（item bg/text transition 三元组 + `transform:scale(...)` 恒等注释口径照 breadcrumb 先例）。RTL（rtl.scss:3-18）：`direction: rtl` + item 两侧 margin 互换（EdgeInsetsDirectional 天然翻边）+ prev/next `transform: scaleX(-1)`（★自定义 prevText/nextText 一并翻转 quirk 照抄）；size 切换器缺省位置 bottomRight。aria：prev/next `Previous`/`Next`、页码 `Page N`、省略号 `More`（Semantics 近似）。

## 主题（48 对账）

来源 packages/semi-foundation/pagination/variables.scss（41 声明行 / 41 唯一名——color 20、width/height 5、spacing 11、radius 1、fontWeight 4）+ packages/semi-foundation/pagination/animation.scss（7 声明行——**活文件**：pagination.scss:2 `@import "./animation.scss"` + :48-50 消费）。对账 **48 = 41 FIELDS + 7 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表；`$module: #{$prefix}-page` 类名胶水不计）。★**1 死变量**（`$color-pagination_item-bg-default`）。全局 token 解析：`var(--semi-color-text-2/0)` → `theme.colors.colorText2/0`、`var(--semi-color-tertiary)` → `theme.colors.colorTertiary`、`var(--semi-color-fill-0/1)` → `theme.colors.colorFill0/1`、`var(--semi-color-disabled-text)` → `theme.colors.colorDisabledText`、`var(--semi-color-disabled-fill)` → `theme.colors.colorDisabledFill`、`var(--semi-color-primary)` → `theme.colors.colorPrimary`、`var(--semi-color-primary-light-default)` → `theme.colors.colorPrimaryLightDefault`、`transparent` → `const Color(0x00000000)`；引用 token：`$spacing-extra-tight` → 4、`$font-weight-regular/bold` → `theme.typography.fontWeightRegular/Bold`（生成域 fontWeight resolve 先例 tool/generate_tag.py:31）、`var(--semi-border-radius-small)` → `theme.radius.borderRadiusSmall.value`（= 3，generate_collapse.py:42 / navigation 先例）；motion 七元组照 breadcrumb 先例：`var(--semi-transition_duration-none)`/`var(--semi-transition_delay-none)` → `Duration.zero`、`var(--semi-transition_function-easeIn)` → `Curves.easeIn`、★`var(--semi-transform_scale-none)`（= `scale(1,1)`，semi-theme-default/scss/animation.scss:28）→ `const SemiTransform.scale(1, 1)`。解析列即 `SemiPaginationThemeData.resolve` 默认表达式。类型覆盖：**20 Color + 17 double + 4 FontWeight + 4 Duration + 2 Curve + 1 SemiTransform**（FontWeight/SemiTransform 值相等天然——直用内置运算符；Curve 走 semiCurveEquals/semiCurveHash）。

### A. Sass 声明映射（41 FIELDS + 7 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-pagination-text-default: var(--semi-color-text-2)` | `colorPaginationTextDefault` | `theme.colors.colorText2`（small 根/总页数色） |
| `$color-pagination_item-text-default: var(--semi-color-text-0)` | `colorPaginationItemTextDefault` | `theme.colors.colorText0`（页码基准文字色） |
| `$color-pagination_item-bg-default: transparent` | `colorPaginationItemBgDefault` | `const Color(0x00000000)`（**（上游未消费）**——pagination.scss 零引用，default 态由 `ul` 自身透明呈现） |
| `$color-pagination_item-icon-default: var(--semi-color-tertiary)` | `colorPaginationItemIconDefault` | `theme.colors.colorTertiary`（prev/next 图标基准色） |
| `$color-pagination_item-text-hover: var(--semi-color-text-0)` | `colorPaginationItemTextHover` | `theme.colors.colorText0`（悬浮文字色） |
| `$color-pagination_item-bg-hover: var(--semi-color-fill-0)` | `colorPaginationItemBgHover` | `theme.colors.colorFill0`（悬浮底色；rest-item hover 同用） |
| `$color-pagination_item-text-active: var(--semi-color-text-0)` | `colorPaginationItemTextActive` | `theme.colors.colorText0`（按下文字色） |
| `$color-pagination_item-bg-active: var(--semi-color-fill-1)` | `colorPaginationItemBgActive` | `theme.colors.colorFill1`（按下底色；rest-item active 同用） |
| `$color-pagination_item-text-disabled: var(--semi-color-disabled-text)` | `colorPaginationItemTextDisabled` | `theme.colors.colorDisabledText`（禁用文字；总页数禁用同用） |
| `$color-pagination_item-icon-disabled: var(--semi-color-disabled-text)` | `colorPaginationItemIconDisabled` | `theme.colors.colorDisabledText`（prev/next 禁用图标色） |
| `$color-pagination_item-bg-disabled: transparent` | `colorPaginationItemBgDisabled` | `const Color(0x00000000)`（禁用底色） |
| `$color-pagination_item-bg-selected-disabled: var(--semi-color-disabled-fill)` | `colorPaginationItemBgSelectedDisabled` | `theme.colors.colorDisabledFill`（选中+整体禁用底色） |
| `$color-pagination_item-text-selected: var(--semi-color-primary)` | `colorPaginationItemTextSelected` | `theme.colors.colorPrimary`（选中文字色） |
| `$color-pagination_item-bg-selected: var(--semi-color-primary-light-default)` | `colorPaginationItemBgSelected` | `theme.colors.colorPrimaryLightDefault`（选中底色） |
| `$color-pagination_quickjump_text-disabled: var(--semi-color-disabled-text)` | `colorPaginationQuickjumpTextDisabled` | `theme.colors.colorDisabledText`（跳转禁用文字色） |
| `$color-pagination_item-border-default: transparent` | `colorPaginationItemBorderDefault` | `const Color(0x00000000)`（基准边框色） |
| `$color-pagination_item-border-hover: transparent` | `colorPaginationItemBorderHover` | `const Color(0x00000000)`（悬浮边框色） |
| `$color-pagination_item-border-active: transparent` | `colorPaginationItemBorderActive` | `const Color(0x00000000)`（按下边框色） |
| `$color-pagination_item-border-selected: transparent` | `colorPaginationItemBorderSelected` | `const Color(0x00000000)`（选中边框色） |
| `$color-pagination_item-border-disabled: transparent` | `colorPaginationItemBorderDisabled` | `const Color(0x00000000)`（禁用边框色） |
| `$height-pagination_item: 32px` | `heightPaginationItem` | `32`（页码盒高） |
| `$width-pagination_item-minWidth: 32px` | `widthPaginationItemMinWidth` | `32`（页码最小宽） |
| `$width-pagination_item_small-minWidth: 44px` | `widthPaginationItemSmallMinWidth` | `44`（small 页码最小宽） |
| `$width-pagination_quickjump_input_width: 50px` | `widthPaginationQuickjumpInputWidth` | `50`（跳转输入框 max-width） |
| `$width-pagination_item_border: 0px` | `widthPaginationItemBorder` | `0`（页码边框宽） |
| `$spacing-pagination-padding: 0` | `spacingPaginationPadding` | `0`（根 padding） |
| `$spacing-pagination_small-paddingY: 0` | `spacingPaginationSmallPaddingY` | `0`（small 垂直 padding） |
| `$spacing-pagination_small-paddingX: 0` | `spacingPaginationSmallPaddingX` | `0`（small 水平 padding） |
| `$spacing-pagination_item-marginLeft: $spacing-extra-tight` | `spacingPaginationItemMarginLeft` | `4`（页码左 margin；RTL 镜像） |
| `$spacing-pagination_item-marginRight: $spacing-extra-tight` | `spacingPaginationItemMarginRight` | `4`（页码右 margin；RTL 镜像） |
| `$spacing-pagination_item_small-margin: 0` | `spacingPaginationItemSmallMargin` | `0`（small margin 归零） |
| `$spacing-pagination_reset_list-paddingTop: $spacing-extra-tight` | `spacingPaginationResetListPaddingTop` | `4`（rest 列表上 padding；★`reset` 错拼照抄——声明与使用处同拼） |
| `$spacing-pagination_reset_list-paddingBottom: $spacing-extra-tight` | `spacingPaginationResetListPaddingBottom` | `4`（rest 列表下 padding；★`reset` 错拼照抄） |
| `$spacing-pagination_quickjump_marginLeft: 24px` | `spacingPaginationQuickjumpMarginLeft` | `24`（跳转左距） |
| `$spacing-pagination_quickjump_input_marginLeft: 4px` | `spacingPaginationQuickjumpInputMarginLeft` | `4`（输入框左距） |
| `$spacing-pagination_quickjump_input_marginRight: 4px` | `spacingPaginationQuickjumpInputMarginRight` | `4`（输入框右距） |
| `$radius-pagination_item: var(--semi-border-radius-small)` | `radiusPaginationItem` | `3`（页码圆角） |
| `$font-pagination_small-fontWeight: $font-weight-regular` | `fontPaginationSmallFontWeight` | `theme.typography.fontWeightRegular`（FontWeight） |
| `$font-pagination_item-fontWeight: $font-weight-regular` | `fontPaginationItemFontWeight` | `theme.typography.fontWeightRegular`（FontWeight） |
| `$font-pagination_item_active-fontWeight: $font-weight-bold` | `fontPaginationItemActiveFontWeight` | `theme.typography.fontWeightBold`（FontWeight） |
| `$font-pagination_quickjump_fontWeight: $font-weight-regular` | `fontPaginationQuickjumpFontWeight` | `theme.typography.fontWeightRegular`（FontWeight） |
| `$transition_duration-pagination_item-bg: var(--semi-transition_duration-none)` | `transitionDurationPaginationItemBg` | `Duration.zero`（活字段——:48 消费；AnimatedContainer duration） |
| `$transition_function-pagination_item-bg: var(--semi-transition_function-easeIn)` | `transitionFunctionPaginationItemBg` | `Curves.easeIn`（活字段；AnimatedContainer curve） |
| `$transition_delay-pagination_item-bg: var(--semi-transition_delay-none)` | `transitionDelayPaginationItemBg` | `Duration.zero`（活字段；delay 槽 AnimatedContainer 无对应——注释引用） |
| `$transition_duration-pagination_item-text: var(--semi-transition_duration-none)` | `transitionDurationPaginationItemText` | `Duration.zero`（活字段——:49 消费；AnimatedDefaultTextStyle duration） |
| `$transition_function-pagination_item-text: var(--semi-transition_function-easeIn)` | `transitionFunctionPaginationItemText` | `Curves.easeIn`（活字段；AnimatedDefaultTextStyle curve） |
| `$transition_delay-pagination_item-text: var(--semi-transition_delay-none)` | `transitionDelayPaginationItemText` | `Duration.zero`（活字段；delay 槽 AnimatedDefaultTextStyle 无对应——注释引用） |
| `$transform_scale-pagination_item: var(--semi-transform_scale-none)` | `transformScalePaginationItem` | `const SemiTransform.scale(1, 1)`（活字段——:50 `transform:scale(...)` 消费；★上游编译产物 `transform:scale(scale(1,1))` 无效 CSS bug 留档） |

### B. HARDCODES 另列（`_PaginationMetrics` / 调用点，widget 源内含原始片段）

| 上游片段 | 落点 |
|---|---|
| `PAGE_SHOW_MAX: 7` | 截断阈值（constants.ts:10） |
| `REST_PAGE_SHOW_MAX: 5` | note-only——constants.ts:11 声明未消费死常量 |
| `DEFAULT_PAGE_SIZE: 10` | 缺省每页条数（constants.ts:12） |
| `PAGE_SIZE_OPTION: [10, 20, 40, 100]` | 切换器候选（constants.ts:13） |
| `REST_PAGE_MAX_SIZE: 1000000` | rest 列表上限（constants.ts:14） |
| `const itemHeight = 32` | rest 列表行高（index.tsx:441） |
| `width={78}` | rest 列表宽（index.tsx:450） |
| `count >= 5 ? itemHeight * 5` | rest 列表最多 5 行可视（index.tsx:442） |
| `position: 'bottom'` | Popover 缺省位置（popover/index.tsx:113） |
| `DEFAULT_Z_INDEX: 1030` | popoverZIndex 缺省（popover/constants.ts） |
| `SPACING: 4` | Popover 与触发器间距 |
| `'每页条数：${pageSize}'` | locale `pageSize` 模板（zh_CN.ts:9） |
| `'总页数：${total}'` | locale `total` 模板（zh_CN.ts:10；★键值是总页数） |
| `'跳至'` | locale `jumpTo`（zh_CN.ts:11） |
| `'页'` | locale `page`（zh_CN.ts:12） |
| `aria-label="Previous"` / `aria-label="Next"` | prev/next 语义（index.tsx:259/:282） |
| `Page ${page}` / `'More'` | 页码/省略号语义（index.tsx:390/:384） |
| `role={this.props.size === 'small' ? 'none' : undefined}` | small prev/next 去分页语义 quirk（index.tsx:254/:277；note-only） |
| `// padding-left: $spacing-base;` | note-only——pagination.scss:189 注释掉的 rest-item 左内边距 |
| `transform:scale(scale(1,1))` | note-only——:50 无效编译 bug（token 自带 scale(1,1) 再包 scale(...)） |
| `user-select: none` | 页码/Select 文本不可选（:36/:167/:171-173；Flutter 默认——note-only） |
| `hideOnSinglePage no longer takes effect` | warning 文案（index.tsx:155-158）——两开关同开时 hideOnSinglePage 失效 |
| `style={{ direction }}` | rest 列表随文档方向（index.tsx:452；继承 Directionality） |
| `semi-page-select-dropdown` | 切换器面板类名（index.tsx:322；Flutter 面板无 className——note-only） |

## 差异清单

★照搬留档（quirk 原样）：

1. **total 语义**：`ceil(total/pageSize)` 只用于总页数（总页数文本/截断/跳转夹取），组件不渲染条目总数。
2. **0/falsy 回退**：`pageSize || pageSizeOpts[0] || 10`、`currentPage || defaultCurrentPage`（0 → 回退）。
3. **截断 fallback 恒真**：foundation.ts:203 `currentPage - 3 <= currentPage && currentPage <= totalPageNum` 恒真——`4<c<t-3` 之外全部落到「1 + ... + 倒数 5 页」。
4. **disabled 吞 hover/press**：`-all-disabled`/`-item-disabled` 源序在 `:hover`/`:active` 之后——禁用项无悬浮/按下反馈；选中+整体禁用底色 `disabled-fill`。
5. **prev/next 图标色系覆盖**：基准 `icon-default`、悬浮/按下回落 `text-hover`/`text-active`（`:hover`/`:active` 特异性更高）、禁用 `icon-disabled`。
6. **关闭 `hideOnSinglePage` 失效**：与 showSizeChanger 同开时上游 warning 且该开关不再生效（不 assert，照渲染）。
7. **small prev/next role none**、**RTL 自定义 prevText/nextText 也翻转**（scaleX 镜像整块）、**`reset` 错拼**（`$spacing-pagination_reset_list-padding*`）照抄。
8. **无效 transform 编译 bug**：`transform:scale(scale(1,1))`（token 自带 scale(1,1) 再包 scale(...)）——视觉无影响留档（note-only）。
9. **死常量**：`REST_PAGE_SHOW_MAX: 5` 声明未消费（note-only）。

偏差/裁剪：

10. **react-window → ListView.builder**：rest 列表用懒构建列表（视口最多 5 行 × 32）替代 react-window 虚拟化；滚动/懒构建语义等价，无外部依赖。
11. **省略号弹层 Popover → SemiDropdown content 形态**：Popover 未单独移植——弹层表面同 Dropdown `-wrapper`（bg3/圆角/shadow-elevated 两行）；★无 Popover 箭头（SemiDropdown 无箭头）；`rePosKey` → `repositionKey`。
12. **容量切换器宽度**：上游 Select auto 宽（内联块）；本库 [SemiSelect] 触发器按 incoming 宽度分流（bounded → `Expanded` 铺满；无界主轴 → 内容宽），容量切换器直接置于无界 Row 里即得 CSS auto 宽（见 docs/semi_select.md 差异清单）。
13. **跳转提交小数收敛**：上游 `Number()` 允许小数（`2.5` 也进入 goPage）；本移植 `int.tryParse`，非整数忽略。
14. **跳转 Enter 通道**：[SemiInputNumber] 不透出 `onEnterPress`——外包 `Focus.canRequestFocus: false` 接冒泡 Enter；blur 走 focusNode 监听。
15. **zIndex 仅 API 对齐**：`popoverZIndex` 保存但叠放由 Overlay 插入序决定（SemiTooltip 口径）。
16. **select 面板类名/aria 裁剪**：`dropdownClassName`（`semi-page-select-dropdown`）、`aria-label="Page size selector"` 无 Flutter 落点（note-only）。
17. **content 自绘列表**：省略号弹层与 small 全页码弹层用 SemiDropdown content（menu 形态承载不了 rest-item 行高/懒构建）。
18. **className/style/getDataAttr/prefixCls 不移植**。

## 用法

```dart
SemiPagination(
  total: 100,
  pageSize: 10,
  defaultCurrentPage: 3,
  showTotal: true,
  showSizeChanger: true,
  showQuickJumper: true,
  onPageChange: (page) {},
  onPageSizeChange: (size) {},
  onChange: (page, size) {},
)

// small 摘要 + hover 全页码
SemiPagination(
  total: 100,
  size: SemiPaginationSize.small,
  hoverShowPageSelect: true,
)

// 受控
SemiPagination(
  total: 100,
  currentPage: _page,
  onPageChange: (page) => setState(() => _page = page),
)
```
