# SemiPopconfirm 气泡确认框

点击（默认）触发的轻量二次确认气泡，含标题、正文、图标与确认/取消按钮。实现文件 `lib/src/components/semi_popconfirm.dart`：构建在 [SemiTooltip](semi_tooltip.md) 浮层壳上（`popupBare: true` + popover 家族表面，与 [SemiDropdown](semi_dropdown.md) 同路线），触发/定位/翻转/箭头/外部点击/Esc/受控 visible 全部复用 tooltip 机制；确认卡结构与语义对应上游 `packages/semi-ui/popconfirm/index.tsx` + `popconfirmFoundation.ts`。

```dart
SemiPopconfirm(
  title: const Text('删除任务'),
  content: const Text('确定删除该任务吗？'),
  onConfirm: () async => await repo.delete(id),
  onCancel: () {},
  child: SemiButton('删除'),
)
```

## API

| 参数 | 说明 | 默认 |
|---|---|---|
| `child` | 触发气泡的目标子树 | 必填 |
| `title` | 标题（上游 `title`，纯节点；null 隐藏标题） | null |
| `content` | 正文（null 隐藏正文；上游函数式 `content({ initialFocusRef })` 未移植） | null |
| `icon` | 标题左侧图标槽；默认警示三角（`SemiPopconfirmDefaultIcon`，warning 着色），`null` 隐藏，任意 widget 原样替换 | 默认哨兵 |
| `okText` / `cancelText` | 确认/取消按钮文案 | '确认' / '取消' |
| `okType` / `cancelType` | 按钮类型（确认固定 solid 主题；关闭按钮同用 `cancelType`） | primary / tertiary |
| `okLoading` / `cancelLoading` | 按钮 loading（null 时跟随回调返回的 `Future`） | null |
| `onConfirm` / `onCancel` | 确认/取消回调（关闭按钮同走 `onCancel`）；返回 `Future` 时按钮 loading，resolve 后自动关闭（非受控），reject 仅去 loading 保持打开 | null |
| `visible` / `onVisibleChange` | 受控显隐（非空即受控：事件只上报请求，关闭权在使用方） | null |
| `defaultVisible` | 非受控初始显示 | false |
| `disabled` | 为 true 直接渲染 `child`，不包气泡 | false |
| `showCloseIcon` | 标题栏右上角关闭按钮 | true |
| `trigger` | 触发方式 | `SemiTooltipTrigger.click` |
| `position` | 弹出方向（缺省 bottomLeft；RTL 时 bottomRight） | null |
| `showArrow` | 三角箭头（popover 双路径箭头：bg-3 翼形 + color-border 描边） | false |
| `arrowPointAtCenter` | 箭头指向触发物中心 | false |
| `spacing` | 触发物与气泡间距（缺省 `showArrow ? 10 : 4`，Popover `numbers.SPACING_WITH_ARROW/SPACING`） | null |
| `autoAdjustOverflow` / `clickToHide` / `closeOnEsc` / `onEscKeyDown` / `onClickOutSide` / `motion` / `zIndex` | 同 SemiTooltip 对应参数（`closeOnEsc` 默认 true、`zIndex` 1030 仅 API 兼容） | — |

## 行为

### 确认/取消（popconfirmFoundation.handleConfirm/handleCancel）

- 回调返回非 `Future`：立即关闭（非受控）并触发 `onVisibleChange(false)`；
- 返回 `Future`：对应按钮 loading，resolve 后关 loading 并关闭，reject 仅关 loading、保持打开；
- 受控模式：一律只经 `onVisibleChange` 报告请求，不自关；
- 右上关闭按钮与取消按钮同路径（都触发 `onCancel`）。

### 结构（popconfirm.scss `.semi-popconfirm` 族）

```
SemiTooltip(popupBare) 弹层
└─ 气泡表面（popover 皮肤：bg-3 + shadow-elevated + radius medium）
   └─ -inner（内边距 LTR 24 24 24 20 / RTL 24 20 24 24；带箭头 12 12 12 8 / 12 8 12 12）
      ├─ -header：图标槽 24×24（右距 12）+ -header-body（-header-title 16/22 w600，底距 8）+ 关闭按钮 24×24
      ├─ -body（text-2，14px；有图标时左缩进 36）
      └─ -footer（顶距 25，右对齐；取消按钮右距 8）
```

### 动画

上游无 popconfirm animation.scss：气泡复用 `popover/animation.scss`（100ms、cubic-bezier(0.215, 0.61, 0.355, 1)），与 tooltip 壳动画逐值相同，直接沿用 SemiTooltip 的 motion，无独立 MOTION 字段。

## 主题（23 对账）

**23 = 19 FIELDS + 4 INTERNAL**；HARDCODES 11 条另计，**34 = 19 + 4 + 11 provenance entries**。★2 上游死变量（`$spacing-popconfirm_btn_close-margin` 及其派生 `$spacing-popconfirm_popover_with_arrow_inner_btn_close-marginTop`，编译产物 popconfirm.css 无对应规则）仅留 `_PopconfirmMetrics` provenance 常量；其余 21 条（含 2 条派生内边距）全部进入渲染路径，theme 字段 0 死变量。

### A. Sass 声明映射（19 FIELDS + 4 INTERNAL）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-popconfirm_header-text: var(--semi-color-text-0)` | `colorPopconfirmHeaderText` | `theme.colors.colorText0` |
| `$color-popconfirm_body-text: var(--semi-color-text-2)` | `colorPopconfirmBodyText` | `theme.colors.colorText2` |
| `$color-popconfirm_header_alert-icon: var(--semi-color-warning)` | `colorPopconfirmHeaderAlertIcon` | `theme.colors.colorWarning` |
| `$width-popconfirm-icon: 24px` | `widthPopconfirmIcon` | `24`（图标槽盒） |
| `$width-popconfirm_close_btn: 24px` | `widthPopconfirmCloseBtn` | `24`（★上游死变量，移植消费为关闭按钮盒） |
| `$width-popconfirm-maxWidth: 400px` | `widthPopconfirmMaxWidth` | `400` |
| `$spacing-popconfirm-top: 24px` | `spacingPopconfirmTop` | `24` |
| `$spacing-popconfirm-bottom: 20px` | `spacingPopconfirmBottom` | `20`（★4 值 padding quirk 落 CSS left 位） |
| `$spacing-popconfirm_with_arrow-padding: 12px` | `spacingPopconfirmWithArrowPadding` | `12` |
| `$spacing-popconfirm_header_title-marginBottom: 8px` | `spacingPopconfirmHeaderTitleMarginBottom` | `8` |
| `$spacing-popconfirm_header_content_p-padding: 0` | `spacingPopconfirmHeaderContentPPadding` | `0`（标题盒 padding） |
| `$spacing-popconfirm_header_content_p-margin: 0` | `spacingPopconfirmHeaderContentPMargin` | `0`（标题盒 margin） |
| `$spacing-popconfirm_body_p-padding: 0` | `spacingPopconfirmBodyPPadding` | `0`（正文盒 padding） |
| `$spacing-popconfirm_body_p-margin: 0` | `spacingPopconfirmBodyPMargin` | `0`（正文盒 margin） |
| `$spacing-popconfirm_footer-marginTop: 25px` | `spacingPopconfirmFooterMarginTop` | `25` |
| `$spacing-popconfirm_footer_btn-marginRight: 8px` | `spacingPopconfirmFooterBtnMarginRight` | `8`（Directional end，RTL 翻转） |
| `$spacing-popconfirm_header_icon-marginRight: 12px` | `spacingPopconfirmHeaderIconMarginRight` | `12`（Directional end，RTL 翻转） |
| `$font-popconfirm_header_title-fontWeight: $font-weight-bold` | `fontPopconfirmHeaderTitleFontWeight` | `theme.typography.fontWeightBold` |
| `$radius-popconfirm-popover: var(--semi-border-radius-medium)` | `radiusPopconfirmPopover` | `theme.radius.borderRadiusMedium.value`（覆盖 popover 圆角） |
| `$spacing-popconfirm_popover_with_arrow_inner-padding: (…) (…) (…) (…)` | `_PopconfirmMetrics.withArrowInnerPadding` | 派生（24−12 24−12 24−12 20−12 = 12 12 12 8），由标量字段运行时计算 |
| `$spacing-popconfirm_popover_with_arrow_inner_rtl-padding: (…) (…) (…) (…)` | `_PopconfirmMetrics.withArrowInnerPadding(rtl)` | 派生 RTL 镜像（12 8 12 12） |
| `$spacing-popconfirm_btn_close-margin: 24px` | `_PopconfirmMetrics.btnCloseMargin` | ★2 上游死变量之一：仅 provenance 常量（`// ignore: unused_field`），不参与布局 |
| `$spacing-popconfirm_popover_with_arrow_inner_btn_close-marginTop: $spacing-popconfirm_btn_close-margin - $spacing-popconfirm_with_arrow-padding` | `_PopconfirmMetrics.btnCloseMarginTopWithArrow` | ★2 上游死变量之二：派生 12，同样仅 provenance |

### B. HARDCODES 另列（11 条 widget 源内锚点）

| 上游片段 | 去向 |
|---|---|
| `padding: $spacing-popconfirm-top $spacing-popconfirm-top $spacing-popconfirm-top $spacing-popconfirm-bottom`（popconfirm.scss，24 24 24 20） | `_PopconfirmMetrics.innerPadding`（left 位 quirk 照抄） |
| `padding: $spacing-popconfirm-top $spacing-popconfirm-bottom $spacing-popconfirm-top $spacing-popconfirm-top`（rtl.scss，24 20 24 24） | 同上 RTL 分支 |
| `margin-left: $width-popconfirm-icon + $spacing-popconfirm_header_icon-marginRight`（36，rtl.scss 不翻转） | `_PopconfirmMetrics.bodyWithIconIndent` |
| `@include font-size-header-6`（16/22） | 标题 `TextStyle`（`theme.typography.fontSizeHeading6/lineHeightHeading6`） |
| `@include font-size-regular`（14） | 正文 `DefaultTextStyle`（popover wrapper 继承字号） |
| `$color-popover-bg-default: var(--semi-color-bg-3)` | 气泡表面 `theme.colors.colorBg3` |
| `box-shadow: var(--semi-shadow-elevated)` | `theme.shadows.shadowElevated`（drop → `toDropBoxShadows()` 进 BoxDecoration，inset → `SemiInsetShadow` 画师，见差异清单） |
| `z-index: $z-popover`（1030） | `zIndex` 默认值 |
| `spacing = showArrow ? numbers.SPACING_WITH_ARROW : numbers.SPACING`（popover/index.tsx，10 : 4） | `spacing` 缺省推导 |
| `fill: var(--semi-color-border)`（popover/Arrow.tsx `path:nth-child(1)`） | 箭头描边 `arrowFringeColor` |
| `fill: var(--semi-color-bg-3)`（popover/Arrow.tsx `path:nth-child(2)`） | 箭头填充 `arrowColor` |

箭头翼形填充即 tooltip 的 `tooltipArrowWingHorizontal/Vertical()`（上游 Arrow.tsx path2 与 TriangleArrow 同形）；描边 fringe 路径逐字转录在 `tooltip_arrow_paths.dart` 的 `tooltipArrowFringeHorizontal/Vertical()`。

## 差异清单

- 函数式 `content({ initialFocusRef })`、`okButtonProps`/`cancelButtonProps` 逐参数透传、`guardFocus`/`returnFocusOnClose`/按钮 autoFocus 聚焦守卫未移植（Dart 侧需要精细按钮定制时可在上层自行组合）；显隐焦点语义以 SemiTooltip 为准。
- 受控模式下触发事件照常经 `onVisibleChange` 上报请求（上游受控时 `trigger='custom'` 会吞掉触发事件），与本库 SemiTooltip 受控语义一致。
- `title` 为 `Widget?`（非 String/ReactNode 双态）；无 `prefixCls`/`stopPropagation`/`style`/`className` 等 DOM 专属参数。
- `zIndex` 仅 API 兼容（overlay 叠序为插入序）；`rePosKey` 以 `SemiTooltip.repositionKey` 形态存在（如需可后续透传）。
- 加载中不禁用另一按钮（上游无互斥禁用语义，忠实移植）；按钮自身 loading 拦截点击。
- RTL：内边距、图标间距、footer 按钮间距镜像；`-body-withIcon` 缩进上游无 RTL 规则，照抄物理 left。
- **inset 阴影层由专用画师渲染**：Flutter 无 CSS inset box-shadow 对应物——drop 层进 BoxDecoration（`toDropBoxShadows()`）、inset 层（dark `--semi-shadow-elevated` 首层 `inset 0 0 0 1px`）由 `SemiInsetShadow` 画师精确绘制（贴 padding-box 的内环、零布局影响）；`toBoxShadows()` 对 inset 抛错的显式合同保留，带 blur/offset 的 inset 层构造即抛。
