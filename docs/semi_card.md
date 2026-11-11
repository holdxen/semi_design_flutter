# SemiCard 卡片

无需 Material，使用 `package:semi_design_flutter/semi_design_flutter.dart` 和 Flutter widgets。

```dart
SemiCard(
  title: '卡片标题',                       // String → SemiTitle(heading:6) + tooltip
  headerExtraContent: const Text('更多'),   // 标题行尾部
  cover: Image.network('...'),             // 子项全宽、裁圆角
  body: const SemiCardMeta(                // 正文（对应 React children）
    avatar: CircleAvatar(...),
    title: 'Meta 标题',
    description: 'Meta 描述',
  ),
  actions: const [Text('操作一'), Text('操作二')],
  footer: const Text('卡片脚注'),
  footerLine: true,
  shadows: SemiCardShadows.hover,
)
```

## API 与边界

`SemiCard` 字段：

| 字段 | 说明 | 默认 |
| --- | --- | --- |
| `title` | `String` → `SemiTitle(heading: 6, maxLines: 1, overflow: ellipsis)` + hover `SemiTooltip` 显全文；`Widget` 原样；其他类型 assert | null |
| `header` | `Widget`，覆盖整个标题行（title + headerExtraContent，上游 `header \|\| wrapper`） | null |
| `headerExtraContent` | `Widget`，标题行尾部；外裹 `DefaultTextStyle` 应用 extra 字号/字重/颜色 | null |
| `headerLine` | 标题行底部分隔线 | `true` |
| `cover` | `Widget`，内部拉满包裹（`width: 100%`）、随卡片圆角裁切 | null |
| `body` | `Widget`，正文（对应 React `children`） | null |
| `actions` | `List<Widget>?`，正文底部操作组（按存在性渲染，空列表也渲染空组，同上游 `Array.isArray(actions)`） | null |
| `footer` | `Widget`，脚注 | null |
| `footerLine` | 脚注顶部分隔线 | `false` |
| `loading` | body 区内联灰块占位（header/cover/footer 不动），根语义标记更新中 | `false` |
| `bordered` | 外描边 | `true` |
| `shadows` | `SemiCardShadows.hover` / `SemiCardShadows.always`；null = 无阴影 | null |
| `headerPadding` | `EdgeInsetsGeometry?`，标题行内边距 | `EdgeInsets.all(spacingCardPadding)` |
| `bodyPadding` | `EdgeInsetsGeometry?`，正文内边距 | `EdgeInsets.all(spacingCardPadding)` |
| `footerPadding` | `EdgeInsetsGeometry?`，脚注内边距 | `EdgeInsets.all(spacingCardPadding)` |
| `semanticsLabel` | 整卡语义标签（上游 `aria-label`） | null |

`SemiCardMeta` 字段（avatar 槽 + title/description 双态）：

| 字段 | 说明 | 默认 |
| --- | --- | --- |
| `avatar` | `Widget`，位于逻辑起始侧 | null |
| `title` | `String` → `SemiText` 套 16/700/22 主题度量；`Widget` 原样；其他类型 assert | null |
| `description` | `String` → `SemiText` 套 14/400/20 主题度量；`Widget` 原样；其他类型 assert | null |

上游无 hoverable/size/点击回调，故不移植（见差异清单）。`headerStyle`/`bodyStyle`/`footerStyle` 上游是 CSSProperties 内联样式，此处只映射为 `headerPadding`/`bodyPadding`/`footerPadding`。

## 结构

渲染顺序 **header → cover → body → footer**，分隔全部用边框（不用 Divider）：

```
Semantics(aria-label / loading 标记)                 ← 根
└─ MouseRegion(shadows≠null 时 cursor=click)         ← 上游 cursor:pointer quirk
   └─ AnimatedContainer(decoration: bg + bordered?Border.all(widthCardBorder,colorCardBorder)
                              + 圆角 radiusCard + boxShadow, 300ms 过渡)
      └─ ClipRRect(圆角 radiusCard - widthCardBorder) ← CSS overflow:hidden 在 padding-box 曲线裁切
         ├─ header  Container(padding: headerPadding??20, headerLine?底边框)
         │    └─ Row(crossAxis: start)：title Expanded(有 extra 时 end 侧留
         │        spacingCardMargin 间距, EdgeInsetsDirectional 自动镜像) + extra 尾部
         │        （`header` 存在时整体替换此行）
         ├─ cover   子项全宽包裹（bounded 拉满 / 无界自然宽）
         ├─ body    Container(padding: bodyPadding??20, 正文字色 colorCardBodyText)
         │    ├─ 正文 / loading 占位
         │    └─ actions：margin-top spacingCardMargin + padding-top spacingCardPadding
         │       + 顶边框；Wrap spacing/runSpacing 12（硬编码 INTERNAL）
         └─ footer  Container(padding: footerPadding??20, footerLine?顶边框)
```

CSS 边框盒模型由 Flutter `Container` 自动等价：`Container` 会把 decoration 的边框宽度加进自身 padding（`_paddingIncludingDecoration`），因此 bordered 时内容整体内缩 `widthCardBorder`、`headerLine`/`footerLine`/actions 顶边框各占一行 `widthCardBorder` 的布局高——与上游 `border-bottom`/`border-top` 一致。`bordered: false` 时无描边、无内缩。

`SemiCardMeta` 布局：`Row(crossAxisAlignment: center)` = avatar（end 侧留 `spacingCardAvatarMarginRight` 间距）+ `Expanded`/`Flexible` 的 `Column(title, description)`。

字体系度量走 `height: lineHeight/fontSize` 比率（文字缩放不裁切）；有界宽度下 flex 拉满、标题 `Expanded`，无界宽度下 `Flexible` + `mainAxisSize.min` 自然宽，不溢出。标题行高 22（heading6）、Meta 标题 16/700/22、描述与正文 14/400/20（`height` 比率换算）。RTL 由 `EdgeInsetsDirectional`/`Wrap` 自然镜像（rtl.scss 的 margin 翻转等价）。

## 阴影三态

- `shadows: null`（默认）：无阴影，鼠标 `defer`。
- `shadows: SemiCardShadows.always`：始终显示主题 `shadowCard`（resolve `theme.shadows.shadowElevated`），指针变 click（上游 `.semi-card-shadows { cursor: pointer }` quirk，卡片不可点击也显示手型）。
- `shadows: SemiCardShadows.hover`：hover 进入/离开以 `motionCardTransitionDuration`（300ms，`$motion-card-transition_duration`）过渡阴影（`transition: box-shadow 300ms`）。

阴影渲染只转换 **非 inset** 的 `SemiShadowLayer` 为 `BoxShadow`；`SemiShadows.toBoxShadows()` 对 inset 层抛错，dark 模式默认 `--semi-shadow-elevated` 首层即 `inset 0 0 0 1px`（见差异清单）。阴影画在被装饰的盒子上、ClipRRect 之内——与 CSS `overflow: hidden` 不裁自身 `box-shadow` 一致。

## loading 与语义

`loading: true` 时 body 内容替换为对齐上游 `<Skeleton.Title /><br /><Skeleton.Paragraph rows={3} />` 的灰块简化：标题条 24（`$height-skeleton_title`）+ 空行 20（正文行高）+ 段落行 3×16（`$height-skeleton_li`，行距 10，末行 60% 宽），灰块色 `colorFill0`、圆角 `borderRadiusSmall`（即 `$color-skeleton_default-bg-default`/`$radius-skeleton_item` 的全局 token）。header/cover/footer 不动。根 `Semantics` 在 loading 时置 `role: SemanticsRole.status` 近似上游 `aria-busy`（Flutter 无 busy 语义标志，见差异清单）。

## 主题

主题优先级：局部非空补丁（外到内 merge）> 当前 `SemiThemeData.components.card` > live global 默认值。`SemiCardTheme` 局部补丁跨 `SemiTheme` 边界继承：捕获只携带局部补丁快照，应用级与默认值在目标边界重新解析，相同 light/dark 模式下更新也通知。`copyWith`/`merge` 的 null 表示保留原值。

来源 `packages/semi-foundation/card/variables.scss`；消费逻辑 `packages/semi-foundation/card/{card,rtl}.scss`、`packages/semi-ui/card/{index,meta}.tsx`。
共 **23** 个声明 = **22** 个主题字段（下表 A 组，`tool/generate_card.py` 生成到 `semi_card_theme_data.dart`，全量）+ **1** 个 widget 内部常量（下表 B 组 `zCardHover`）。**23 = 22 + 1** 为来源注释计数防漂移校验。另有硬编码 INTERNAL（C 组，非变量声明、逐个 `///` 注释）。独立于 383 项 CSS manifest，不把 Sass 混入 CSS token 清单。

### A. 主题字段（22）

颜色 6（resolve 实时读取当前 global）：

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$color-card-bg-default` | `var(--semi-color-bg-0)` | `colorCardBgDefault` → `theme.colors.colorBg0` |
| `$color-card-border` | `var(--semi-color-border)` | `colorCardBorder` → `theme.colors.colorBorder` |
| `$color-card_title-text` | `var(--semi-color-text-0)` | `colorCardTitleText` → `theme.colors.colorText0` |
| `$color-card_description-text` | `var(--semi-color-text-2)` | `colorCardDescriptionText` → `theme.colors.colorText2` |
| `$color-card_extra-text` | `var(--semi-color-text-0)` | `colorCardExtraText` → `theme.colors.colorText0` |
| `$color-card_body-text` | `var(--semi-color-text-1)` | `colorCardBodyText` → `theme.colors.colorText1` |

字体 8：

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$font-card_default-fontWeight` | `$font-weight-regular` | `fontCardDefaultFontWeight` → `theme.typography.fontWeightRegular` |
| `$font-card_extra-fontWeight` | `700` | `fontCardExtraFontWeight` → `FontWeight.w700` |
| `$font-card_title-fontWeight` | `700` | `fontCardTitleFontWeight` → `FontWeight.w700` |
| `$font-card_default-lineHeight` | `20px` | `fontCardDefaultLineHeight` → `20` |
| `$font-card_title-lineHeight` | `22px` | `fontCardTitleLineHeight` → `22` |
| `$font-card_default-fontSize` | `$font-size-regular` | `fontCardDefaultFontSize` → `theme.typography.fontSizeRegular` |
| `$font-card_extra-fontSize` | `$font-size-header-6` | `fontCardExtraFontSize` → `theme.typography.fontSizeHeading6` |
| `$font-card_title-fontSize` | `$font-size-header-6` | `fontCardTitleFontSize` → `theme.typography.fontSizeHeading6` |

间距 4：

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$spacing-card-padding` | `$spacing-base-loose` | `spacingCardPadding` → `20` |
| `$spacing-card-margin` | `$spacing-base-loose` | `spacingCardMargin` → `20` |
| `$spacing-card_avatar-marginRight` | `$spacing-base-tight` | `spacingCardAvatarMarginRight` → `12` |
| `$spacing-cardGroup_card-margin` | `-1px` | `spacingCardGroupCardMargin` → `-1`（CardGroup 未移植，仅配置） |

宽度/圆角/阴影/动画 各 1：

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$width-card-border` | `$border-thickness-control` | `widthCardBorder` → `1` |
| `$radius-card` | `var(--semi-border-radius-medium)` | `radiusCard` → `theme.radius.borderRadiusMedium.value` |
| `$shadow-card` | `var(--semi-shadow-elevated)` | `shadowCard` → `theme.shadows.shadowElevated`（`SemiShadows`，全库首个组件级 shadow 字段） |
| `$motion-card-transition_duration` | `300ms` | `motionCardTransitionDuration` → `const Duration(milliseconds: 300)` |

### B. INTERNAL（1）

| Sass | 常量（`_CardMetrics`） | 说明 |
|---|---|---|
| `$z-card_hover: 1` | `zCardHover` | `.semi-card-shadows-hover:hover` 的 z-index 抬升，避免网格型卡片组阴影互相覆盖；CardGroup 未移植，仅留档 |

### C. 硬编码 INTERNAL（另列，`_CardMetrics`/调用点逐个 `///`）

| 常量 | 上游来源 | 值 |
|---|---|---|
| `actionsGap` | `<Space spacing={12}>`（index.tsx） | 12 |
| `coverFullWidth` | `> * { display: block; width: 100% }`（card.scss） | 全宽 |
| `letterSpacing` | `letter-spacing: 0em`（card.scss） | 0 |
| `loadingTitleHeight` | `height: $height-skeleton_title`（skeleton.scss） | 24 |
| `loadingRowHeight` | `height: $height-skeleton_li`（skeleton.scss） | 16 |
| `loadingRowGap` | `margin-bottom: $spacing-skeleton_li-marginBottom`（skeleton.scss） | 10 |
| `loadingLastRowWidthFactor` | `width: 60%`（`li:last-child`，skeleton.scss） | 0.6 |
| `loadingFill` | `background: $color-skeleton_default-bg-default`（skeleton.scss） | `colorFill0` |
| `loadingRadius` | `border-radius: $radius-skeleton_item`（skeleton.scss） | `borderRadiusSmall` |
| `shadowsCursor` | `cursor: pointer`（card.scss） | click |

## 差异清单

- **无 hoverable/size/点击**：上游 Card 没有这些 API（hoverable 是 CardGroup 网格的能力），不移植。
- **`headerStyle`/`bodyStyle`/`footerStyle` → padding**：上游是 CSSProperties 内联样式（含任意样式），此处只移植 `headerPadding`/`bodyPadding`/`footerPadding`；`style`/`className` 不移植。
- **CardGroup 未移植**：`SemiCardGroup`（网格卡片组）整体不移植；`spacingCardGroupCardMargin`（`-1`）与 `zCardHover` 仅作配置/留档。
- **`shadows` 取值收紧为 enum**：上游 `shadows={'hover'|'always'}`，测试文件里出现过 `'show'` 这个不在 `strings.SHADOWS` 列表里的值；此处以 `SemiCardShadows` enum 收紧，非法值不构成。
- **cursor:pointer quirk**：`shadows` 非空时指针显示 click 手型（上游 `.semi-card-shadows { cursor: pointer }`），但卡片不可点击——原样复刻并在 API 注明。
- **title tooltip 接入情况**：上游 `ellipsis: { showTooltip: true }` 仅在文本被省略时弹 tooltip；此处对 String 标题 hover 即以 `SemiTooltip` 显示全文（不做省略检测），Widget 标题不套 tooltip。
- **`aria-busy` → `SemanticsRole.status`**：Flutter 语义没有 busy 标志（SemanticsProperties/SemanticsFlags 均无），loading 时根 `Semantics` 置 `role: SemanticsRole.status` 近似"更新中"区域。
- **inset 阴影层不渲染**：`toBoxShadows()` 对 inset 层抛 `UnsupportedError`，dark 模式默认 `--semi-shadow-elevated` 首层为 `inset 0 0 0 1px`；渲染时跳过 inset 层（仅转换 drop 层），light 模式与 `toBoxShadows()` 完全一致。
- **ClipRRect 在装饰盒之内**：计划文字为"根 ClipRRect + AnimatedContainer"；实现将 ClipRRect 放在 AnimatedContainer 内侧，否则 box-shadow 会被根裁剪整块裁掉。CSS `overflow: hidden` 本就不裁自身 `box-shadow`，行为对齐上游。
- **loading 占位不设 children 门控**：上游 `children && <Skeleton ...>` 仅在 children 存在时渲染占位；此处 `loading: true` 即显示占位（body 为空也显示），header/cover/footer 不动。
