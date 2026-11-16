# SemiCollapsible 折叠

无需 Material，使用 `package:semi_design_flutter/semi_design_flutter.dart` 和 Flutter widgets。行为组件——在展开/收起间做高度过渡（可选淡入淡出），可单独包裹任意内容实现自定义折叠行为（上游被 Collapse、Tree、Navigation 等复用）。

```dart
SemiCollapsible(
  isOpen: isOpen,
  child: const Text('折叠内容'),
)
```

## API 与边界

`SemiCollapsible` 参数（`lib/src/components/semi_collapsible.dart`，上游 `packages/semi-ui/collapsible/index.tsx` + `foundation.ts`）：

| 字段 | 说明 | 默认 |
| --- | --- | --- |
| `isOpen` | 是否展开内容区域，**受控唯一状态源**（上游无 uncontrolled 形态） | `false` |
| `duration` | 动画时长覆盖（上游 `duration: number` 毫秒），null 取主题 `transitionDurationCollapsibleHeight` | null |
| `motion` | 高度/透明度动画；`false` 瞬切 | `true` |
| `keepDOM` | 收起后保持内容构建（State 不失效）、高度裁 0 | `false` |
| `lazyRender` | 配合 `keepDOM`：`true` 时首次展开才构建内容；`keepDOM=false` 时无效（上游 `shouldRender` 语义） | `false` |
| `collapseHeight` | 收起态高度（0 = 完全收起） | `0` |
| `collapseHeightAdaptive` | 内容矮于 `collapseHeight` 时收起态自适应 `Math.min(内容高, collapseHeight)`；`false` 恒为 `collapseHeight`（可高于内容、留空） | `false` |
| `reCalcKey` | 上游高度重测触发键；本实现高度持续跟随内容，变化只触发重建（保留 API 对齐） | - |
| `fade` | 淡入淡出；仅 `collapseHeight == 0` 时生效（上游 opacity 公式） | `false` |
| `onMotionEnd` | 动画结束回调：**展开、收起都触发**；瞬切不触发 | - |
| `child` | 内容（上游 `children`） | - |

## 行为

- **显隐构建规则**（上游 `shouldRender`，index.tsx:216-221）：`(keepDOM && (lazyRender ? 首次已渲染 : true)) || collapseHeight != 0 || 动画未结算 || isOpen`。`keepDOM=false` 收起动画结束后销毁内容（State 失效）；`keepDOM=true` 保持构建；`collapseHeight != 0` 时内容恒构建（收起态就地可见）。
- **高度**：展开态 = 内容自然高度（持续跟随——嵌套展开、文本缩放等内层尺寸变化同帧反映，无陈旧缓存高）；收起态 = `collapseHeight`（adaptive 取 `min(内容高, collapseHeight)`）。内容恒按自然高度顶端排版、底部裁切（上游 wrapper `overflow: 'hidden'` 盒语义）。
- **动画**：250ms + `Cubic(0.25, 0.1, 0.25, 1)`（主题 `transitionDurationCollapsibleHeight`/`transitionFunctionCollapsibleHeight`，`duration` 可覆盖）；`motion=false` 或 `TickerMode` 关闭 / `MediaQuery.disableAnimations` 时瞬切。初始渲染无入场动画（上游 transition 未武装）。
- **fade**：`collapseHeight == 0` 时透明度随过渡 0↔1（曲线 `transitionFunctionCollapsibleOpacity` = ease-in，时长同 `duration`）；`collapseHeight != 0` 恒 1。
- **onMotionEnd**：展开/收起动画结束都回调（上游 transitionend + `duration + 50` 兜底定时器语义，移植由控制器结算状态取代）；`motion=false` 瞬切不回调。
- **嵌套**：内层尺寸变化同步反映到外层裁切（布局期测高），任意层嵌套天然成立。

## 主题（6 对账）

来源 packages/semi-foundation/collapsible/variables.scss（**空文件**——0 声明行 / 0 唯一名）+ packages/semi-foundation/collapsible/animation.scss（6 声明行——**活文件**：collapsible.scss:1 `@import "./animation.scss"` + :9-10 `transition:` 简写消费 height/opacity 两个三元组）。对账 **6 = 0 FIELDS + 6 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表；`$module: #{$prefix}-collapsible` 类名胶水不计）。★**0 死变量**（全 6 字段 widget 全消费，无死标）。共源留档：generate_collapse.py 的 `26 = 22 + 4` 已按 Collapse 口径引用过同 6 条（2 条升 theme 字段 + 4 条落 `_CollapseMetrics`）；本组件按 standalone 口径独立对账，6 条全升本组件 theme 字段（`fade` 活消费透明度三元组，与 Collapse 的 `fade: false` 不同）。token 解析：`250ms` → `const Duration(milliseconds: 250)`（generate_modal.py `120ms` 先例）、`cubic-bezier(0.25,0.1,0.25,1)` → `const Cubic(0.25, 0.1, 0.25, 1)`（generate_collapse.py 同源声明先例）、`var(--semi-transition_delay-none)` → `Duration.zero`、`var(--semi-transition_function-easeIn)` → `Curves.easeIn`（generate_anchor.py motion 先例）。解析列即 `SemiCollapsibleThemeData.resolve` 默认表达式。类型覆盖：**4 Duration + 2 Curve**（Duration 值相等天然；Curve 走 semiCurveEquals/semiCurveHash）。★quirk 照抄：值后 `;//` 紧邻中文注释排版（animation.scss:1-6 六行同款）。独立于 383 项 CSS manifest，不把 Sass 混入 CSS token 清单。

### A. Sass 声明映射（6 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$transition_duration-collapsible-height: 250ms` | `transitionDurationCollapsibleHeight` | `const Duration(milliseconds: 250)`（活字段——collapsible.scss:9 消费；亦是上游 `duration` prop 缺省、`duration` 参数缺省来源） |
| `$transition_function-collapsible-height: cubic-bezier(0.25,0.1,0.25,1)` | `transitionFunctionCollapsibleHeight` | `const Cubic(0.25, 0.1, 0.25, 1)`（活字段——collapsible.scss:9 消费；高度过渡曲线） |
| `$transition_delay-collapsible-height: var(--semi-transition_delay-none)` | `transitionDelayCollapsibleHeight` | `Duration.zero`（活字段——collapsible.scss:9 消费；delay 槽控制器无对应（0ms 无延迟）——注释引用 + 本表注明） |
| `$transition_duration-collapsible-opacity: 250ms` | `transitionDurationCollapsibleOpacity` | `const Duration(milliseconds: 250)`（活字段——collapsible.scss:10 消费；fade 透明度过渡。CSS 回退默认——上游 inline `transitionDuration` 以 `duration` prop 覆盖，移植 fade 同走 `duration` 时长） |
| `$transition_function-collapsible-opacity: var(--semi-transition_function-easeIn)` | `transitionFunctionCollapsibleOpacity` | `Curves.easeIn`（活字段——collapsible.scss:10 消费；fade 透明度过渡曲线） |
| `$transition_delay-collapsible-opacity: var(--semi-transition_delay-none)` | `transitionDelayCollapsibleOpacity` | `Duration.zero`（活字段——collapsible.scss:10 消费；delay 槽控制器无对应——注释引用 + 本表注明） |

### B. HARDCODES 另列（调用点，widget 源内含原始片段）

| 上游片段 | 落点 |
|---|---|
| `duration + 50` | motion-end 兜底定时器（index.tsx:150 `setTimeout(handleMotionEnd, duration + 50)`）→ 控制器结算状态（dismissed/completed）取代 |
| `propertyName === 'height'` | transitionend 守卫（index.tsx:230 只认 height 属性）→ 控制器结算状态取代 |
| `ResizeObserver` | 内容测高（index.tsx:55/:121）→ `_CollapsibleClipBox.performLayout` 布局期同步测高 |
| `Math.ceil` | 测高取整（index.tsx:108 `Math.ceil(entry.borderBoxSize[0].blockSize)`）→ 同步布局天然精确，无需取整 |
| `overflow: 'hidden'` | wrapper 裁切盒（index.tsx:205 包装盒 + :239 inner div 同款）→ `_CollapsibleClip` pushClipRect |

## 差异清单

照搬留档（quirk 原样）：

1. **onMotionEnd 双向触发**：展开、收起动画结束都回调（上游 timer/transitionend 语义——区别于 SemiCollapse 面板回调仅收起触发的口径）。
2. **collapseHeight 非 adaptive 可高于内容**：收起态恒为 `collapseHeight`，内容矮时留空（上游 `height: collapseHeight` 语义）。
3. **opacity 公式照搬**：`fade` 仅 `collapseHeight == 0` 生效（上游 `(isOpen || !fade || collapseHeight !== 0) ? 1 : 0`，index.tsx:208）。

偏差/裁剪：

4. **同步测高取代 ResizeObserver**：上游 ResizeObserver + `Math.ceil` 测内容高、`reCalcKey` 触发重测（index.tsx:97-116/:145-158）→ 移植在布局期同步量高，内容尺寸变化天然跟随（比重测窗口更稳）；`reCalcKey` 保留仅触发重建。
5. **unmeasured 窗口不复存在**：上游首测前 `height: 'auto'` + `maxHeight` 夹取（unmeasuredCollapsed，index.tsx:200-207）→ 同步布局无未测窗口，该分支不复刻。
6. **曲线双向同形近似**：上游 CSS transition 插值 `from + (to - from) * C(progress)` 对收起方向镜像曲线；移植按 open-fraction 统一 `curve.transform`（SemiCollapse 移植同口径），中断续播亦以控制器值连续过渡。
7. **fade 透明度进度化**：上游 opacity 是目标值 + CSS transition；移植按 open-fraction 连续插值 `Curves.easeIn.transform(t)`（静止态与瞬切一致）。
8. **瞬切便利扩展**：`TickerMode` 关闭 / `MediaQuery.disableAnimations` 时瞬切且不回调（上游仅 `motion` 开关）。
9. **duration 类型**：上游 `duration: number`（毫秒）→ `Duration?`（null 取主题）。
10. **className/style/id 裁剪**：`className`/`style`/`getDataAttr` 不移植（Flutter 无 CSS 类）；`id`（上游 wrapper 元素 id，配合 `aria-controls` 建立控制关系）不移植——由 Flutter 语义树承担关联。
11. **无障碍**：收起内容不摘语义/焦点（与上游 `overflow: hidden` + `height: 0` 的可达性一致——上游亦无 `aria-hidden`）；需要隐藏时由使用方自行包裹 `ExcludeSemantics`。
12. **上游 FAQ 不复刻**：父级 `display: none` 无法测高的问题（content/show/collapsible/index.md FAQ）在同步布局模型下不存在对应分支。

## 用法

```dart
// 基本用法
SemiCollapsible(
  isOpen: _open,
  child: const SemiText('Semi Design 以内容优先进行设计。'),
)

// 自定义动画时间 / 关闭动画
SemiCollapsible(
  isOpen: _open,
  duration: const Duration(milliseconds: 400), // 上游 duration={400}
  motion: true,
  child: content,
)

// 自定义折叠高度（部分可见 + 渐隐遮罩由使用方叠加）
SemiCollapsible(
  isOpen: _open,
  collapseHeight: 60,
  child: content,
)

// keepDOM + lazyRender：首次展开才构建，收起后保留 State
SemiCollapsible(
  isOpen: _open,
  keepDOM: true,
  lazyRender: true,
  fade: true,
  onMotionEnd: () {},
  child: content,
)
```
