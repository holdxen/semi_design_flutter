# SemiTimeline 时间轴

无需 Material，使用 `package:semi_design_flutter/semi_design_flutter.dart` 和 Flutter widgets。

```dart
SemiTimeline(
  mode: SemiTimelineMode.left,
  semanticsLabel: '事故处理时间线',
  items: const [
    SemiTimelineItemData(
      content: '第一个节点内容',
      extra: '节点辅助说明信息',
      time: '2019-07-14 10:35',
      type: SemiTimelineItemType.ongoing,
    ),
    SemiTimelineItemData(
      content: '自定义图标',
      time: '2019-06-13 16:17',
      type: SemiTimelineItemType.warning,
      dot: Icon(Icons.warning_amber),
    ),
    SemiTimelineItemData(
      content: '自定义节点颜色',
      color: Color(0xFFFFB4B4),
    ),
  ],
)
```

## API 与边界

`SemiTimeline` 接收 `mode`（`left`/`right`/`center`/`alternate`，默认 `left`）、`items`（`List<SemiTimelineItemData>`，默认空）与 `semanticsLabel`（上游 `aria-label`）。上游 `children` 与 `dataSource` 两种写法统一映射为 `items` 列表；`className`/`style` 不移植。上游没有 pending 与折叠交互，本移植也没有。

`SemiTimelineItemData` 字段：

| 字段 | 说明 | 默认 |
| --- | --- | --- |
| `content` | 必填，`String`（`SemiText` 14/20，颜色 `colorTimelineItemContentTextDefault`）或 `Widget` 原样放置 | - |
| `time` | `String`（`SemiText` 12/16）、`num`（渲染 `toString()`）、`Widget`，或 `false`/null | - |
| `extra` | 辅助说明，规则同 `time`，渲染在 `time` 之前 | - |
| `type` | `normal`/`ongoing`/`success`/`warning`/`error`；`normal` 即上游 `default` | `normal` |
| `dot` | 自定义节点，`Widget` 原样放置 | - |
| `color` | 内联圆点背景色 | - |
| `position` | `left`/`right`，显式指定 `getPosCls` 分支 | - |
| `onTap` | 行点击回调 | - |

zero-metadata 语义复刻上游 `time || time === 0`：`0` 与字符串 `'0'` 必须渲染出容器与文本；`false`、null、空串、`double.nan` 不渲染 time/extra 容器（`true` 等其他类型触发 assert，比上游 React 更严格）。渲染顺序恒为 content → extra → time。content 必须是 `String` 或 `Widget`，time/extra 必须是 `String`/`Widget`/`num`/`false`/null，其他类型触发 assert。

`position` 复刻上游 `getPosCls`：`alternate` 按索引奇偶（偶数取 `left` 分支、奇数取 `right` 分支），`center` 默认 `left` 分支，`left`/`right` 模式整行跟随模式、忽略 `position`（上游文档声称 `position` 可覆盖模式，实际代码只在 alternate/center 生效）。注意上游类名描述的是轴/时间相对内容的方位（center 模式文档"时间节点在左侧"即 `item-left` 分支），因此 `position: left` 把内容放在轴的 end 侧（LTR 右侧、text-align start），`position: right` 放在轴的 start 侧（LTR 左侧、text-align end）。

## 四模式布局

每行（上游 `li` 块级）含 24（`spacingTimelineItemPaddingBottom`）底部内边距；尾巴是 1px 竖线（`CustomPaint`），自 20（`spacingTimelineTailTop`）起画到行底（含 padding-bottom），末行不画。圆点 9×9（`widthTimelineDot`）top 5（`spacingTimelineHeadTop`），圆角取主题 `radiusTimelineHead`；custom dot 以 `FractionalTranslation` 对中在头部锚点（left 模式锚点 (5, 10)，即 `spacingTimelineHeadCustomLeft/Top`）。

```
left（默认）                 right
│ ●  内容 …        │         │     内容  ● │
│ ┃  辅助          │         │     辅助  ┃ │
│ ┃  时间          │         │     时间  ┃ │
轴 x=4；内容 start 内边距 25   轴 x=W-9；内容宽 W-28、text-align end

center                     alternate
│  时间(end) ┃ ● ┃ 内容(start) │   偶数行同 center 单行（右槽）
│  左槽      ┃轴 ┃ 右槽        │   奇数行：左槽宽 W/2-20、text-align end
                                time 随内容流（不做绝对定位）
```

center/alternate 复刻 `calc(50%±…)` 三槽（`LayoutBuilder`）：轴在 50%（`spacing-timeline_item_head_custom-left: 50%`）；start 侧内容槽宽 50%−20（`$width-timeline_item_right_item_content`）右对齐；end 侧内容槽起于轴右 6px、宽 50%−14（`$width-timeline_item_left_item_content`）左对齐。center 的 time 绝对定位（top `spacingTimelineTimeTop` = −2）在轴 start 侧槽、右对齐于 50%−19，复刻 `margin-left: calc(-40px - 100%)` + `width: 100%` 的意图（时间 end 边在内容边左 40px + 内容宽）。

RTL（rtl.scss）由 `EdgeInsetsDirectional`/`PositionedDirectional` 自然镜像：left 模式轴贴 end 侧、内容 25px 内边距翻到 end，text-align 对调（start/end 自动翻转），center 时间槽镜像到物理 start 侧（rtl.scss 的 `text-align: left`）。custom dot 的 translate(-50%,-50%) 与 RTL translate(50%,-50%) 按 `rtl == startAnchored` 选择。

文字缩放下尾巴高度随 constraints 重算（行变高、竖线跟着拉长，几何偏移不变）。极窄宽度下 50% 槽位照常收缩；无界宽度下 center/alternate 回退为单侧 start 槽布局（不猜百分比宽度），left/right 模式的偏移都是固定 inset，无界下原样工作，内容按 mainAxisSize.min 收缩。

## 主题

主题优先级：局部非空补丁（外到内 merge）> 当前 `SemiThemeData.components.timeline` > live global 默认值；显式参数（如 `color`）压过主题。`SemiTimelineTheme` 局部补丁跨 `SemiTheme` 边界继承：捕获只携带局部补丁快照，应用级与默认值在目标边界重新解析，相同 light/dark 模式下更新也通知。`copyWith`/`merge` 的 null 表示保留原值。

## 完整 Sass 映射

来源 `packages/semi-foundation/timeline/variables.scss`；消费逻辑 `packages/semi-foundation/timeline/{timeline,rtl}.scss`、`packages/semi-ui/timeline/{index,item}.tsx`。
共 **42** 个声明 = **28** 个主题字段（下表 A 组，`tool/generate_timeline.py` 生成到 `semi_timeline_theme_data.dart`）+ **14** 个 widget 内部布局常量（下表 B 组，`semi_timeline.dart` 的 `_TimelineMetrics`，公式值不进主题）。独立于 383 项 CSS manifest，不把 Sass 混入 CSS token 清单。

### A. 主题字段（28）

颜色 9（resolve 实时读取当前 global）：

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$color-timeline_dot_default-bg-default` | var(--semi-color-primary) | colorTimelineDotDefaultBgDefault → theme.colors.colorPrimary（type ongoing） |
| `$color-timeline_dot_info-bg-default` | var(--semi-color-tertiary-light-active) | colorTimelineDotInfoBgDefault → theme.colors.colorTertiaryLightActive（type normal） |
| `$color-timeline_dot_success-bg-default` | var(--semi-color-success) | colorTimelineDotSuccessBgDefault → theme.colors.colorSuccess |
| `$color-timeline_dot_warning-bg-default` | var(--semi-color-warning) | colorTimelineDotWarningBgDefault → theme.colors.colorWarning |
| `$color-timeline_dot_error-bg-default` | var(--semi-color-danger) | colorTimelineDotErrorBgDefault → theme.colors.colorDanger |
| `$color-timeline_tail-border` | var(--semi-color-text-3) | colorTimelineTailBorder → theme.colors.colorText3 |
| `$color-timeline_time_default-text-default` | var(--semi-color-text-2) | colorTimelineTimeDefaultTextDefault → theme.colors.colorText2 |
| `$color-timeline_item_head-bg` | transparent | colorTimelineItemHeadBg → const Color(0x00000000)（字面量，非 token） |
| `$color-timeline_item_content-text-default` | var(--semi-color-text-0) | colorTimelineItemContentTextDefault → theme.colors.colorText0 |

spacing 14 标量（展开值取自 `packages/semi-theme-default/scss/variables.scss`）：

| Sass | 默认 | Theme 字段 |
|---|---|---|
| `$spacing-timeline-margin` | $spacing-none (0) | spacingTimelineMargin |
| `$spacing-timeline-padding` | $spacing-tight (8px) | spacingTimelinePadding |
| `$spacing-timeline_tail-top` | $spacing-base-loose (20px) | spacingTimelineTailTop |
| `$spacing-timeline_tail-left` | $spacing-extra-tight (4px) | spacingTimelineTailLeft |
| `$spacing-timeline_head-top` | 5px | spacingTimelineHeadTop |
| `$spacing-timeline_head_custom-top` | 10px | spacingTimelineHeadCustomTop |
| `$spacing-timeline_head_custom-left` | 5px | spacingTimelineHeadCustomLeft |
| `$spacing-timeline_content-marginLeft` | 25px | spacingTimelineContentMarginLeft |
| `$spacing-timeline_time-marginTop` | $spacing-extra-tight (4px) | spacingTimelineTimeMarginTop |
| `$spacing-timeline_time-top` | -2px | spacingTimelineTimeTop |
| `$spacing-timeline_item-margin` | $spacing-none (0) | spacingTimelineItemMargin |
| `$spacing-timeline_item-paddingBottom` | $spacing-loose (24px) | spacingTimelineItemPaddingBottom |
| `$spacing-timeline_item_head-marginLeft` | -4px | spacingTimelineItemHeadMarginLeft |
| `$spacing-timeline_item_right_item_content` | $spacing-none (0) | spacingTimelineItemRightItemContent |

width 3、radius 2：

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$width-timeline_dot` | 9px | widthTimelineDot（宽高同用，与上游一致） |
| `$width-timeline_tail-border` | $border-thickness-control (1px) | widthTimelineTailBorder |
| `$width-timeline_head_custom-border` | $border-thickness (0) | widthTimelineHeadCustomBorder |
| `$radius-timeline_head` | var(--semi-border-radius-circle) | radiusTimelineHead → theme.radius.borderRadiusCircle.value |
| `$radius-timeline_head_custom` | 0 | radiusTimelineHeadCustom |

### B. widget 内部布局常量（14，不进主题）

`auto`/百分比/`calc()`/transform 是布局公式而非可覆盖标量，作 `_TimelineMetrics` 常量并逐个注明原声明：

| Sass | 值 | 内部常量 → 布局用途 |
|---|---|---|
| `$spacing-timeline_item_content_time-marginLeft` | calc(-40px - 100%) | itemContentTimeMarginLeft = -40 → center 时间 end 边 = 名义内容边 − 40px − 内容宽 |
| `$spacing-timeline_item_right_item-left` | calc(100% - 9px) | itemRightItemLeftInset = 9 → right 模式轴距 end 边 9px |
| `$spacing-timeline_item_left_item_content-left` | calc(50% - 4px) | itemLeftItemContentLeft = -4 → end 侧槽名义起点（实际布局见差异清单） |
| `$spacing-timeline_item_head_custom-left` | 50% | itemHeadCustomLeftFraction = 0.5 → center/alternate 轴位 |
| `$width-timeline` | 100% | widthTimeline = 1 → 根节点宽度因子 |
| `$width-timeline_head_custom` | auto | widthTimelineHeadCustom = null → custom dot 宽随子节点 |
| `$width-timeline_item_content_time` | 100% | itemContentTimeWidthFactor = 1 → center 时间宽 = 内容宽 × 因子 |
| `$width-timeline_item_right_content` | calc(100% - 28px) | itemRightContentInset = 28 → right 模式内容 end 内边距 |
| `$width-timeline_item_left_item_content` | calc(50% - 14px) | itemLeftItemContentWidthInset = 14 → end 侧槽宽 = W/2 − 14 |
| `$width-timeline_item_right_item_content` | calc(50% - 20px) | itemRightItemContentWidthInset = 20 → start 侧槽宽 = W/2 − 20 |
| `$height-timline_tail` | calc(100% - 20px) | timlineTailHeightInset = 20 → 尾巴长度 = 行高 − 20（上游拼写 timline 原样保留） |
| `$height-timeline_head_custom` | auto | heightTimelineHeadCustom = null → custom dot 高随子节点 |
| `$motion-timeline_head_custom-transform` | translate(-50%, -50%) | headCustomTranslation → custom dot 对中（锚点为 start 边时） |
| `$motion-timeline_head_custom-transform-rtl` | translate(50%, -50%) | headCustomTranslationRtl → custom dot 对中（锚点为 end 边时） |

`$height-timline_tail: calc(100% - 20px)` 的 20px 是固定字面量，与 `$spacing-timeline_tail-top` 无关：若主题把 tail-top 调离 20，画线长度仍是 行高−20，起点随 tail-top 移动，与上游 CSS 行为一致（可能溢出行底）。

## 无障碍

- 尾巴与圆点 `ExcludeSemantics`（上游 aria-hidden）。
- 根节点 `semanticsLabel` 对应 `aria-label`。
- `onTap` 行渲染为单个 semantics button 节点（内容合并进该节点，不重复朗读）。

## 差异清单

- 上游 `children`/`dataSource` 在此统一为 `items` 列表（`SemiTimelineItemData`）。
- end 侧内容槽（上游 `item-left` 分支）的"左溢出怪癖"按意图实现：上游 `margin-left: 25px` 与 `position: relative; left: calc(50% - 4px)` 叠加后内容实际起于 50%+21 并溢出行右缘约 7px；本移植让内容起于轴右 6px（计划意图"轴右 4~6px 起"取上沿，让开 9px 圆点右缘 50%+5），宽仍为 50%−14，不再溢出。
- 上游 `position` 文档声称可覆盖模式选项，实际 `getPosCls` 只在 alternate/center 生效（left/right 模式整行跟随模式），此处照实复刻。
- 无 pending/折叠：上游组件不含该能力，未自造。
- `color` 内联背景优先：即使提供 custom dot，`color` 仍覆盖 dot 背景（上游内联 style 压过 `color-timeline_item_head-bg: transparent`），照实复刻。
- `type` 命名 `normal` ↔ 上游 `'default'`；色变量名是 reversed 语义（ongoing 用 `$color-timeline_dot_default-*`，normal 用 `$color-timeline_dot_info-*`），映射按上游 class。
- `$height-timline_tail` 上游拼写 `timline` 原样保留（常量名 `timlineTailHeightInset`）。
- custom dot 不自动染色：上游给 head 设 CSS `color` 让图标走 currentColor，Flutter 侧 dot 是任意 Widget、原样放置，需要着色请在 dot Widget 内自行处理（背景透明/`color` 行为与上游一致）。
- 上游 `className`/`style`/`imageStyle` 类透传不移植；行背景等造型请包装外层 Widget。
- time/extra 的可见性判定比上游严格：上游任何 truthy 值（含对象、`true`）都会渲染容器，本移植只接受 `String`/`Widget`/`num`/`false`/null（其他触发 assert），零值语义（`0`/`'0'` 渲染，`false`/null/空串/NaN 隐藏）与上游一致。
