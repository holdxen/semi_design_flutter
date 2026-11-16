# SemiTooltip 工具提示

无需 Material，使用 `package:semi_design_flutter/semi_design_flutter.dart` 和 Flutter widgets。定位引擎（`lib/src/overlay/tooltip_positioning.dart`）为纯函数移植自 `packages/semi-foundation/tooltip/foundation.ts`（`calcPosStyle`/`adjustPosIfNeed`/箭头 clamp）；组件 `lib/src/components/semi_tooltip.dart` 通过 `LayerLink + CompositedTransformTarget/Follower + OverlayEntry` 渲染弹层。

```dart
SemiTooltip(
  content: const Text('这是一个提示'),
  position: SemiTooltipPosition.top,
  trigger: SemiTooltipTrigger.hover,
  child: const MyButton('悬停'),
)
```

## API

| 参数 | 说明 | 默认 |
| --- | --- | --- |
| `content` | 必填，弹层内容 `Widget`（文字样式/背景/圆角/内边距/maxWidth 全取主题，Flutter `Text` 自带换行即上游 `word-break` 语义） | - |
| `child` | 必填，触发元素 | - |
| `position` | 12 个公开位置枚举 `SemiTooltipPosition` | `top` |
| `trigger` | `hover`/`click`/`focus`/`custom`/`contextMenu` | `hover`。**触摸回退**：hover 在手机、模拟器等无悬浮事件的设备上不可达，故触摸点按会直接切换显示（仅 `PointerDeviceKind.touch`；鼠标点击保持上游语义，绝不切换）。**focus**：点击/点按会聚焦触发物并显示（Flutter 裸 `Focus` 不会因点击自动聚焦，此处显式 `requestFocus` 对齐 DOM 语义），点按外部失焦并关闭；键盘 Tab 进入/离开同样有效 |
| `showArrow` | 是否绘制箭头。形状为上游 `TriangleArrow(.Vertical).tsx` 的凹面翼形曲线（24×7，侧向 7×24，`CustomPaint` 逐路径绘制，反向位置按上游 `rotate(180deg)` 翻转），颜色取 `colorTooltipArrowIconDefault`，默认同背景色 | `true` |
| `popupBare` | true 时弹层不套气泡装饰（不应用背景/内边距/圆角/箭头/maxWidth），内容自绘表面（SemiDropdown 的菜单容器使用）。定位仍按内容尺寸计算 | `false` |
| `arrowPointAtCenter` | 箭头指向触发物中心而非弹层边角 | `true` |
| `autoAdjustOverflow` | 空间不足时自动调整位置 | `true` |
| `spacing` | 触发物与弹层主轴间距 | `8` |
| `mouseEnterDelay` / `mouseLeaveDelay` | `hover`/`focus` 显隐延时（`Duration`） | 50ms |
| `clickToHide` | 点击弹层关闭 | `false` |
| `closeOnEsc` | Escape 消费并关闭（见下）。按键经触发物或弹层的 Focus 节点送达：click/contextMenu 在按下时聚焦触发物（对齐浏览器 tabindex 点击聚焦），故点击打开后按 Esc 即可关闭；弹层内容持有焦点（如 Dropdown 菜单）时由弹层侧处理器关闭；hover 只有触发物本身已获焦点（如 Tab 进入）时才响应 Esc | `false` |
| `visible` | 非空即受控 | null |
| `onVisibleChange` | 可见性请求/变化回调 | - |
| `onClickOutSide` | 外部点击（trigger 之外）回调 | - |
| `onEscKeyDown` | Escape 被消费时回调 | - |
| `motion` | 显隐动画（100ms scale 0.8→1 + opacity 0→1，响应 `MediaQuery.disableAnimations` 与 `TickerMode`） | `true` |
| `zIndex` | 保留参数，实际不做全局管理（见差异清单） | `1060` |
| `repositionKey` | 变化时强制重定位 | null |

`SemiTooltipPopup` 暴露 `placement`（调整后的落点，含 4 个 `*Over` 内部态）与 `arrowOffset`（箭头沿边偏移）测试 getter。

指针豁免（SemiDropdown 嵌套弹层使用）：每个弹层内容包一层 `SemiOverlayPointerExempt` scope，嵌套弹层把自身 RenderBox 全局矩形注册到最近祖先 scope（`SemiOverlayPointerExemptScope.addRegion` 沿 scope 链向上注册）；`_handleOutsidePointer` 判定时命中注册矩形的指针视为内部（点子弹层不关父层，兄弟弹层不互相豁免）。

## 12 定位

弹层以 CSS-translate 等价的百分比表达（`left/top` 锚点 + `translateX/translateY` 弹层尺寸比例），`top` 即弹层在触发物上方居中：

```
topLeft        top        topRight      （上方三位置，translateY=-1）
topLeft/leftTop 区分：topX 以触发物上边为基线、leftX/rightX 以触发物左边为基线

┌────────┐  ┌────────┐  ┌────────┐
│ popup  │  │ popup  │  │ popup  │
└───┬────┘  └───┬────┘  └───┬────┘
   [触发]     [触发]     [触发]

leftTop    left      leftBottom    rightTop   right   rightBottom
（左右各三位置，translateX=-1/0，锚在触发物侧边中线/上下边）

bottomLeft   bottom   bottomRight  （下方三位置，translateY=0）
```

另有 4 个内部骑跨态 `leftTopOver`/`rightTopOver`/`leftBottomOver`/`rightBottomOver`（`TooltipPlacement`），用于左右（或上下）都被遮挡的场景，不进入公开 `position` 枚举。小触发物修正：`showArrow && !arrowPointAtCenter` 且触发物高度 ≤ (箭头半宽 12 + offset 2) × 2 时，`leftTop/leftBottom/rightTop/rightBottom` 整体位移 `触发高/2 − 14`。锚点坐标 `round` 取整防抖。

## 翻转四类规则

`autoAdjustOverflow` 执行 `adjustPosIfNeed` 等价逻辑，三组判据（视口剩余、容器剩余、半空间 `isHalfOverFlow`/`isHalfAllEnough`）投票后按位置应用：

| 类型 | 条件语义 | 例 |
| --- | --- | --- |
| `reverse` | 原方向空间不足且反向足够（视口/容器投票合并） | `top ↔ bottom`、`left ↔ right` |
| `expand` | 中心位两侧半空间遮挡，向未遮挡侧展开 | `top → topLeft/topRight`、`left → leftTop/leftBottom` |
| `reduce` | 角位但半空间足够，收敛回中心位 | `topLeft → top` |
| `pin` | 两侧都不足（`isHeightOverFlow`/`isWidthOverFlow`） | 锚点钉到容器边（如 `top` 宽度溢出时锚到容器左边或右边） |

骑跨态：`leftTopOver` 等在左右（或上下）都遮挡时做轴内 reverse（`leftTopOver → rightTopOver`/`leftBottomOver`）。与上游的偏差：上游在 switch 里读取的 `isWidthOverFlow/isHeightOverFlow` 要到函数末尾才计算，其 `reduce` 分支实际为死代码；本移植按原公式在调整前求值 `reduce` 门限、按最终位置重算 pin 标志，使文档所述的 reduce 生效（其余公式逐行一致）。

## 箭头偏移

- 中心位（`top/bottom/left/right`）+ `arrowPointAtCenter`：箭头中心 = 触发物中心相对弹层边缘的百分比，clamp 到 `[箭头半宽 12 + 6, 1 − …]`；偏离 50% ≤ 1% 时返回 null，落到运行时 fallback `SemiTooltipTokens.tooltipArrowOffsetX/Y`（`--semi-tooltip-arrow-offset-x/y`，默认 `SemiLength.percent(50)`，语义与 web CSS `var(…, 50%)` 一致，可经 token 覆盖）。
- 中心位 + `arrowPointAtCenter: false`：箭头贴向触发物所在一侧边缘（距边 12+6）。
- 角位（`topLeft` 等及 `*Over`）：固定内缩常量——水平角位 `arrowAdjustedOffsetX`（5.76，对应 Sass `round($horizontal-rate * $width-tooltip_arrow)`，保留未取整值）、垂直角位 `verticalRate × heightTooltipArrowVertical + arrowAdjustedOffsetY`（0 + 5）。箭头外沿溢出弹层 6px、回压 1px（`arrowOffsetX/Y` 缝隙补偿）。

## 29 行映射

26 个主题字段（`SemiTooltipThemeData`，`tool/generate_tooltip.py` 生成，nullable patch + `SemiResolvedTooltipThemeData`）：

| Dart 字段 | Sass | 默认（resolve 表达式） | 来源 |
| --- | --- | --- | --- |
| `colorTooltipBgDefault` | `$color-tooltip-bg-default: rgba(var(--semi-grey-7), 1)` | `theme.palette.grey7.toColor(1)` | variables.scss |
| `colorTooltipTextDefault` | `$color-tooltip-text-default: var(--semi-color-bg-0)` | `theme.colors.colorBg0` | variables.scss |
| `colorTooltipIconDefault` | `$color-tooltip-icon-default: rgba(var(--semi-grey-7), 1)` | 未覆盖时跟随 `colorTooltipBgDefault`，再回退 `theme.palette.grey7.toColor(1)`（上游 icon 默认同 bg） | variables.scss |
| `colorTooltipArrowIconDefault` | `$color-tooltip_arrow-icon-default: $color-tooltip-icon-default` | 未覆盖时按 `colorTooltipIconDefault` → `colorTooltipBgDefault` → grey7 逐级跟随（上游箭头以气泡背景绘制，`renderIcon` 注入 `style.backgroundColor`，因此背景覆盖会带动箭头变色） | variables.scss |
| `radiusTooltip` | `$radius-tooltip: var(--semi-border-radius-medium)` | `theme.radius.borderRadiusMedium.value` | variables.scss |
| `spacingTooltipContentPaddingLeft` | `$spacing-tooltip_content-paddingLeft: $spacing-base-tight` | 12 | variables.scss |
| `spacingTooltipContentPaddingRight` | `$spacing-tooltip_content-paddingRight: $spacing-base-tight` | 12 | variables.scss |
| `spacingTooltipContentPaddingTop` | `$spacing-tooltip_content-paddingTop: $spacing-tight` | 8 | variables.scss |
| `spacingTooltipContentPaddingBottom` | `$spacing-tooltip_content-paddingBottom: $spacing-tight` | 8 | variables.scss |
| `fontSize` | `$font-tooltip-fontSize: $font-size-regular` | `theme.typography.fontSizeRegular` | variables.scss |
| `widthTooltip` | `$width-tooltip: 240px` | 240 | variables.scss |
| `widthTooltipArrow` | `$width-tooltip_arrow: 24px` | 24 | variables.scss |
| `heightTooltipArrow` | `$height-tooltip_arrow: 7px` | 7 | variables.scss |
| `heightTooltipArrowVertical` | `$height-tooltip_arrow_vertical: 24px` | 24 | variables.scss |
| `widthTooltipArrowVertical` | `$width-tooltip_arrow_vertical: 7px` | 7 | variables.scss |
| `arrowOffsetX` | `$spacing-tooltip_arrow_offset-x: 1px` | 1 | variables.scss |
| `arrowOffsetY` | `$spacing-tooltip_arrow_offset-y: 1px` | 1 | variables.scss |
| `arrowAdjustedOffsetY` | `$spacing-tooltip_arrow_adjusted_offset-y: 5px` | 5 | variables.scss |
| `arrowAdjustedOffsetX` | `$spacing-tooltip_arrow_adjusted_offset-x: round($horizontal-rate * $width-tooltip_arrow)` | 5.76 | variables.scss |
| `zoomScaleFrom` | `$motion-zoom_scale-from: 0.8` | 0.8 | variables.scss |
| `zoomOpacityFrom` | `$motion-zoom_opacity-from: 0` | 0 | variables.scss |
| `zoomOpacityTo` | `$motion-zoom_opacity-to: 1` | 1 | variables.scss |
| `animationDurationIn` | `$animation_duration-tooltip_in: 100ms` | `Duration(ms: 100)` | animation.scss |
| `animationDurationOut` | `$animation_duration-tooltip_out: 100ms` | `Duration(ms: 100)` | animation.scss |
| `animationFunctionIn` | `$animation_function-tooltip_in: cubic-bezier(0.215, 0.61, 0.355, 1)` | `Cubic(0.215, 0.61, 0.355, 1)` | animation.scss |
| `animationFunctionOut` | `$animation_function-tooltip_out: cubic-bezier(0.215, 0.61, 0.355, 1)` | `Cubic(0.215, 0.61, 0.355, 1)` | animation.scss |

3 个内部常量（`_TooltipMetrics`，`lib/src/components/semi_tooltip.dart`，不进主题）：

| 常量 | Sass | 值 | 用途 |
| --- | --- | --- | --- |
| `horizontalRate` | `$horizontal-rate: 0.24` | 0.24 | `arrowAdjustedOffsetX` 默认 5.76 的 Sass 矫正因子（0.24 × 24），留档 |
| `verticalRate` | `$vertical-rate: 0` | 0 | 垂直角位箭头内缩因子（`verticalRate × heightTooltipArrowVertical + arrowAdjustedOffsetY`） |
| `filter` | `$filter-tooltip-bg: none` | `none` | 上游 `backdrop-filter` 为 none，不施加滤镜 |

## 与 SemiTooltipTokens 的关系

`SemiTooltipTokens.tooltipArrowOffsetX/Y` 是运行时 CSS 变量 `--semi-tooltip-arrow-offset-x/y` 的 50% fallback（见 TOKENS.md），仅在中心位箭头偏移返回 null（未偏离 50%）时生效；`arrowOffsetX/Y`（1px）主题字段是弹层边缘的缝隙补偿，两者独立。

## 交互与 Escape

- `hover`：50/50 延时，trigger 与 popup 各有 `MouseRegion` 共享同一计时器，间隙移动 50ms 内不关闭。**显示只认真实指针移动**（`onPointerHover`，web mouseenter 语义）：布局变化把控件推到静止光标下时 Flutter 会合成 MouseRegion enter（如收起侧边栏后按钮在光标下换新），不触发显示——否则闪一下 tooltip。
- `click`：点击显示；外部点击（trigger/popup 之外）触发 `onClickOutSide` 并关闭。
- `focus`：聚焦显示、失焦隐藏（延时同 hover）。
- `custom`：纯受控，仅 `visible` 驱动。
- `contextMenu`：右键（secondary tap）显示，外部点击关闭。
- Escape 矩阵（`closeOnEsc`）：`visible && closeOnEsc` 才消费（回调 `onEscKeyDown`，非 custom 再请求关闭；不消费则事件继续向祖先传播且不回调）：

| visible | closeOnEsc | 父级收到 Escape | onEscKeyDown |
| --- | --- | --- | --- |
| false | true | 是 | 否 |
| true | false | 是 | 否 |
| true | true | 否（消费） | 是 |

## 差异清单

- **受控语义**：`visible` 非空即完全受控——交互事件只回调 `onVisibleChange`，不自行改显隐（web 为半受控，事件直接改内部状态）。
- **hover 显示只认真实指针移动**：Flutter 的 `MouseRegion.onEnter` 会在布局变化时为静止光标合成触发（web mouseenter 不会——如收起侧边栏后按钮在光标下换新），故显示挂 `Listener.onPointerHover`（只随真实移动），`MouseRegion` 仅管 `onExit` 隐藏，对齐 web 语义。
- **zIndex**：参数保留但不生效；弹层插入 `Overlay` 顶层同层、按插入序叠放（web 也无全局 z-index 互斥）。
- **滚动跟随**：位置跟随由 `CompositedTransformFollower` 承担，翻转判定不随滚动重算（web 滚动时重算 `calcPosition`）。
- **未移植**：`getPopupContainer`（固定 ambient Overlay）、`keepDOM`、`wrapWhenSpecial`（disabled/loading 包裹）、`guardFocus`、`returnFocusOnClose`、`preventScroll`、`disableFocusListener`、`disableArrowKeyDown`、自定义箭头节点（`showArrow` 仅支持 bool）、`spacing: {x, y}` 扩展（仅标量）、`margin`（固定 0）、`afterClose`、`condition`、`role`/`wrapperClassName`/`stopPropagation` 等。
- **动画细节**：收起动画为展开动画的对称逆播（100ms scale/opacity 回落），未逐关键帧复刻上游 `zoomOut`（60% 处 opacity 已到 0）；动画中重开挂起补播（`_pendingShow`）语义保留。
- **布局引擎**：web 的 body margin 修正、缩放容器（scaled）补偿、容器内滚动补偿不适用（Flutter 容器为无滚动 Overlay），不移植；`reduce` 门限按上游意图生效（见上）。
