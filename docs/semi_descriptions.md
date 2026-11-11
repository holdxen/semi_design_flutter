# SemiDescriptions 描述列表

无需 Material，使用 `package:semi_design_flutter/semi_design_flutter.dart` 和 Flutter widgets。

```dart
SemiDescriptions(
  semanticsLabel: '用户资料',
  items: const [
    SemiDescriptionsItemData(label: '实际用户数量', value: '1,480,000'),
    SemiDescriptionsItemData(label: '7天留存', value: '98%'),
    SemiDescriptionsItemData(label: '安全等级', value: '3级'),
    SemiDescriptionsItemData(label: '垂类标签', value: Tag('电商')),
    SemiDescriptionsItemData(label: '认证状态', value: '未认证'),
  ],
)
```

## API 与边界

`SemiDescriptions` 接收 `items`（`List<SemiDescriptionsItemData>`，默认空）、`layout`（`vertical`/`horizontal`，默认 `vertical`）、`align`（`center`/`justify`/`left`/`plain`，默认 `center`）、`row`（bool，默认 false）、`size`（`small`/`medium`/`large`，默认 `medium`）、`column`（默认 3，assert ≥ 1）与 `semanticsLabel`（上游 `aria-label`）。上游 `data` 与 `children`/`Descriptions.Item` JSX 两种写法统一映射为 `items` 列表；`className`/`style` 不移植。

优先级：`row: true`（上游 `double` 双行模式）最高——此时 `layout` 被忽略（上游对 row+horizontal 组合无定义，见差异清单）、`align` 失效、`size` 才生效；`size` 在非双行模式下无效。

`SemiDescriptionsItemData` 字段：

| 字段 | 说明 | 默认 |
| --- | --- | --- |
| `label` | 必填，`String`（`SemiText` 单行，超出截断省略号）或 `Widget` 原样放置（上游 `key`/`itemKey`） | - |
| `value` | `String`（`SemiText`，自由换行）、`Widget` 原样放置，或 null（空值） | - |
| `valueBuilder` | `Widget Function()?` 惰性值：只在渲染该项时调用（hidden 项与未挂载树不调用），与 `value` 互斥（assert 不同时给） | - |
| `hidden` | 过滤不渲染、不进语义、不参与分组 | `false` |
| `span` | `horizontal` 下占用的 span 列数；null 表示未显式给出（按 1 列渲染，末行可补满）。显式值（含 1）永不补满（复刻上游 `isNaN(span)` 语义）。assert ≥ 1。vertical/双行忽略 | null |
| `keyStyle` | `String` label 的附加 `TextStyle`（颜色/字重等，合并覆盖主题 key 样式）。上游 `keyStyle` 为 CSSProperties，此处只移植文本样式：宽度用 `keyWidth`、对齐用 `align` | - |
| `keyWidth` | 固定 key 槽宽度（上游 `keyStyle.width`），超出的 key 截断省略号 | - |

label/value 只接受 `String`/`Widget`（其他类型 assert）。`String` 渲染为 `SemiText` 并套主题样式；`Widget` 原样放置、不强制染色（需要继承 key/value 颜色请在 Widget 内自行处理）。分组算法为公开纯函数 `semiDescriptionsHorizontalList(items, column)`（复刻 `packages/semi-foundation/descriptions/foundation.ts` 的 `getHorizontalList`，可单测）。

## 三种布局

每项一行、行顶对齐；key 单行（`maxLines: 1`，Flutter 改良加省略号）、value 自由换行。key 块最小高 14（`min-height: $font-size-regular`）。th 右侧内边距 24（`spacingDescriptionsThPaddingRight`）、item 底部内边距 12（`spacingDescriptionsItemPaddingBottom`）作用于非双行模式。

```
vertical（默认，align 四种）            horizontal（layout=horizontal，column=3）
│  key(列收缩,end)  │ value(伸展)  │    │ k │ v │ k │ v │ k │ v │   ← 每格 span 1
│  key(列收缩,end)  │ value(伸展)  │    │ k │ v │    value(span2)  │   ← 末行补满
align: center  label end / value start
       justify label start / value end
       left    全 start
       plain   单行内联 "label:" + 8px gap + value（Wrap 等效 inline-block）

row=true（双行，size 三档）
│ key      │  │ key      │
│ value    │  │ value    │    ← Wrap 换行流；value 加粗 + 字号放大
│ key      │
│ value    │
```

- **vertical**：label 列收缩到最宽 key（`IntrinsicColumnWidth` 的等效测量，逐项测量后共享列宽）+ value 列伸展（`Expanded`）。**span 在 vertical 模式被忽略**（上游事实，见差异清单）。align 映射逻辑方向（RTL 自动镜像）。plain 每项一行内联：`label:`（冒号拼进文本、仅视觉）+ 8（`spacingDescriptionsValuePlainPaddingLeft`）gap + value，`Wrap` 等效上游 inline-block 流。
- **horizontal**：`LayoutBuilder` 还原 `table-layout: fixed` 等宽列。每项宽 = span/column × 可用宽；1 个 span 列 = 1 个 label 单元 + 1 个 value 单元（上游 `colSpan={span*2-1}`），所以 label 半宽、value 半宽（span=n 时 value 占 2n-1 / 2n 份）。plain 整项一格内联。行内 span 总和超过 column 时该项与其前序同排断行（上游一致），整表按实际最大 span 总和归一化宽度避免溢出。
- **row=true（双行）**：`Wrap` 流，每项 `Column`（key 上 value 下）。value 加粗（`fontDescriptionsValueFontWeight`）+ 字号放大（small 16 / medium 20 / large 28），item 右内边距 48/60/80，key 底内边距 small 0 / medium 4 / large 4。key/value 字号：small 12/16、medium 14/20、large 14/28。

行高：基础 key/value 与双行 medium/large key 用 `fontDescriptionsLineHeight`（20）；双行 small key 16、value 22/28/40（`font-size-small/header-6/header-4/header-2` mixin 的 live global typography 行高 token）。

RTL（rtl.scss）由 `EdgeInsetsDirectional`/`TextAlign.start/end`/`Wrap` 自然镜像：center/justify 对调（逻辑 end/start 翻转），plain 的 8px gap 移到另侧，双行 item 右内边距翻到左侧。

文字缩放下几何随 constraints 重算。极窄宽度下 label 列被截断省略（Flutter 改良，上游表会溢出容器）、value 槽可收缩到 0；无界宽度下 vertical 按自然宽度横排（value 不换行），horizontal 退化为按内容宽度换行（不猜百分比宽度），双行照常 `Wrap`。

## 主题

主题优先级：局部非空补丁（外到内 merge）> 当前 `SemiThemeData.components.descriptions` > live global 默认值。`SemiDescriptionsTheme` 局部补丁跨 `SemiTheme` 边界继承：捕获只携带局部补丁快照，应用级与默认值在目标边界重新解析，相同 light/dark 模式下更新也通知。`copyWith`/`merge` 的 null 表示保留原值。

来源 `packages/semi-foundation/descriptions/variables.scss`；消费逻辑 `packages/semi-foundation/descriptions/{descriptions,rtl}.scss`、`packages/semi-ui/descriptions/{index,item}.tsx`。
共 **19** 个声明 = **19** 个主题字段（下表 A 组，`tool/generate_descriptions.py` 生成到 `semi_descriptions_theme_data.dart`，全量）+ **9** 个 widget 内部常量（下表 B 组，`semi_descriptions.dart` 的 `_DescriptionsMetrics`，另计，来自 descriptions.scss/item.tsx 硬编码而非变量声明）。28 = 19 + 9 为来源注释计数防漂移校验。独立于 383 项 CSS manifest，不把 Sass 混入 CSS token 清单。

### A. 主题字段（19）

颜色 2（resolve 实时读取当前 global）：

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$color-descriptions_key-text-default` | var(--semi-color-text-2) | colorDescriptionsKeyTextDefault → theme.colors.colorText2 |
| `$color-descriptions_value-text-default` | var(--semi-color-text-0) | colorDescriptionsValueTextDefault → theme.colors.colorText0 |

字体 8（`$font-weight-bold`、`$font-size-*` 取自 `packages/semi-theme-default/scss/variables.scss` 展开值）：

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$font-descriptions-lineHeight` | 20px | fontDescriptionsLineHeight → 20 |
| `$font-descriptions_value-fontWeight` | $font-weight-bold (600) | fontDescriptionsValueFontWeight → theme.typography.fontWeightBold |
| `$font-descriptions_key_small-fontSize` | $font-size-small (12px) | fontDescriptionsKeySmallFontSize → theme.typography.fontSizeSmall |
| `$font-descriptions_value_small-fontSize` | $font-size-header-6 (16px) | fontDescriptionsValueSmallFontSize → theme.typography.fontSizeHeading6 |
| `$font-descriptions_key_medium-fontSize` | $font-size-regular (14px) | fontDescriptionsKeyMediumFontSize → theme.typography.fontSizeRegular |
| `$font-descriptions_value_medium-fontSize` | $font-size-header-4 (20px) | fontDescriptionsValueMediumFontSize → theme.typography.fontSizeHeading4 |
| `$font-descriptions_key_large-fontSize` | $font-size-regular (14px) | fontDescriptionsKeyLargeFontSize → theme.typography.fontSizeRegular |
| `$font-descriptions_value_large-fontSize` | $font-size-header-2 (28px) | fontDescriptionsValueLargeFontSize → theme.typography.fontSizeHeading2 |

spacing 9（展开值同上）：

| Sass | 默认 | Theme 字段 |
|---|---|---|
| `$spacing-descriptions_th-paddingRight` | $spacing-loose (24px) | spacingDescriptionsThPaddingRight |
| `$spacing-descriptions_item-paddingBottom` | $spacing-base-tight (12px) | spacingDescriptionsItemPaddingBottom |
| `$spacing-descriptions_item_small-paddingRight` | 48px | spacingDescriptionsItemSmallPaddingRight |
| `$spacing-descriptions_item_medium-paddingRight` | 60px | spacingDescriptionsItemMediumPaddingRight |
| `$spacing-descriptions_item_large-paddingRight` | 80px | spacingDescriptionsItemLargePaddingRight |
| `$spacing-descriptions_key_medium-paddingBottom` | $spacing-extra-tight (4px) | spacingDescriptionsKeyMediumPaddingBottom |
| `$spacing-descriptions_key_large-paddingBottom` | $spacing-extra-tight (4px) | spacingDescriptionsKeyLargePaddingBottom |
| `$spacing-descriptions_value_plain-paddingLeft` | 8px | spacingDescriptionsValuePlainPaddingLeft |
| `$spacing-descriptions_item_double-padding` | 0 | spacingDescriptionsItemDoublePadding |

### B. widget 内部常量（9，不进主题）

descriptions.scss / item.tsx 的硬编码值，作 `_DescriptionsMetrics` 常量并逐个注明原出处：

| 来源 | 值 | 内部常量 → 用途 |
|---|---|---|
| `min-height: $font-size-regular`（.semi-descriptions-key） | 14px | keyMinHeight = 14 → key 块最小高度 |
| `white-space: nowrap`（.semi-descriptions-key） | - | keyMaxLines = 1 → key 单行 + 省略号（Flutter 改良） |
| `font-weight: normal`（.semi-descriptions-key） | 400 | keyBaseFontWeight → key 字重 |
| `font-weight: normal`（.semi-descriptions-value） | 400 | valueBaseFontWeight → 基础 value 字重（双行用主题字重覆盖） |
| `@include font-size-regular`（.semi-descriptions-key） | 14px | keyBaseFontSize = 14 → 基础（非双行）key 字号 |
| `@include font-size-regular`（.semi-descriptions-value） | 14px | valueBaseFontSize = 14 → 基础 value 字号 |
| `padding-bottom: 0`（-double-small key） | 0 | keyPaddingBottomSmall = 0 → 双行 small key 底内边距 |
| `{itemKey}:`（item.tsx plainItem） | ':' | plainColon → plain 冒号（仅视觉，不进语义） |
| `colSpan={span ? ((span * 2) - 1) : 1}`（item.tsx alignItem） | 2 | valueColSpanFactor = 2 → horizontal 槽位二分（label 1 份、value 2·span−1 份） |

## getHorizontalList 分组规则

`semiDescriptionsHorizontalList(items, column)`（horizontal 布局与单测共用）：

1. 过滤 `hidden`；
2. 按 `span ?? 1` 累加，`totalSpan >= column` 立即断行（所以 span > column 的项会与其前序同排收行，独占行只发生在该项开新行时，与上游一致）；
3. 末行未满时，若最后一项**未显式给 span**，复制该项并把 span 扩为 `column - 其余 span 和`（上游 `column - total + 1` 同值）；显式给过 span（含 1）不扩；
4. 不 mutate 输入：扩位是新实例，frozen List/Item 可直接传入。

```
5 项（span 均未给）column=3 → [0 1 2] [3 (4→2)]
                             1/3 1/3 1/3 | 1/3 2/3   ← 宽度按 span/column
显式 span: 2、column=3      → [ (2) ]                ← 不补满，占 2/3，余 1/3 留白
hidden 第 4 项、column=3    → [0 1 2] [ (4→3) ]
column=4                    → [0 1 2 3] [ (4→4) ]
```

## 无障碍

- 每项 `MergeSemantics` 合并 label/value 为单一标签（Flutter 合并标签以换行连接）；plain 冒号仅视觉、不读出（`semanticsLabel`/`ExcludeSemantics`）。
- hidden 项不渲染、不进语义；`valueBuilder` 对 hidden 项不调用。
- 根节点 `semanticsLabel` 对应 `aria-label`。

## 差异清单

- 上游 `data`/`children`（`Descriptions.Item` JSX 形式）在此统一为 `items`（`SemiDescriptionsItemData`）。
- 上游没有 bordered、dataSource、响应式断点能力，本移植也不自造。
- vertical 模式忽略 `span`（上游事实：`colSpan` 在竖排 tr 中不参与布局）；horizontal 是唯一消费 `span` 的布局。
- key 单行 + 省略号为 Flutter 改良（上游 `white-space: nowrap` 不截断、label 列随内容变宽，宽 key 会把表撑出容器）；label 列超宽时按可用宽截断。
- `row: true` 与 `layout: horizontal` 的组合上游未定义（CSS 下 `double` 覆写 tbody 为 flex 流、`horizontal` 只加 table-layout）；本移植 `row` 优先、忽略 `layout`。
- plain 冒号拼进 key 文本但不进语义（上游 `textContent` 含 `:`，朗读会带出）。
- `keyStyle` 只移植 `TextStyle` 子集：宽度走 `keyWidth`、对齐走 `align`（上游 `keyStyle.textAlign`/任意 CSS 不单独移植）。
- `Widget` label/value 原样放置、不强制套 key/value 颜色（上游 CSS `color` 会继承进子树）；`Widget` label 未给 `keyWidth` 时不参与共享 label 列宽测量，按自然宽度单独占位。
- `span` 为 `int?`：null 即"未显式给出"，显式 1 也不补满（上游 `isNaN(span)` 只认 undefined）；上游 `span: null`/`0` 的 JS 强转怪癖不复刻（assert ≥ 1）。
- horizontal 行内 span 总和超过 column 时按实际总 span 归一化整表列宽（上游 fixed table 会增隐式列并压缩全部单元格，此处取等效防溢出行为）。
- 无界宽度下 horizontal 不猜百分比宽度：退化为按内容宽度换行；vertical 按自然宽度横排。
- 每项合并语义标签以换行连接 label/value（Flutter `MergeSemantics` 行为，朗读为一条）。
