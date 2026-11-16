# SemiBackTop

回到顶部（上游 Semi BackTop 全件移植）：监听页面滚动，`scrollTop > visibilityHeight` 时在右下角出现按钮（foundation.ts:93-103 `handleScroll`，:100 `updateVisible(scrollTop > visibilityHeight)`；★目标缺失即隐藏），点击 animateTo 滚回顶部并回传 onClick（foundation.ts:44-47 `onClick` = `setScrollTop(0)` + `notifyClick(e)`，:62-82 `scrollTo` 逐帧写 scrollTop + `easing: 'easeInOutCubic'`）。★点击按 index.tsx:64 `throttle(this.handleClick, this.props.duration ?? BackTop.defaultProps.duration)` 双沿节流（leading 即发 + trailing 窗口末补发，unmount 后 pending 不达——pendingClick.test.jsx 口径）。默认内容 `renderDefault`（index.tsx:105-107 `theme="light"` + `icon={<IconChevronUp />}`）；children 自定义替换。定位：上游 `position: fixed`（backtop.scss:6 视口固定，`right: $spacing-backtop-right` / `bottom: $spacing-backtop-bottom`）→ 本移植为宿主 Stack 直接子节点 `PositionedDirectional`（见差异清单）。主题对账 **3 = 3 FIELDS + 0 MOTION + 0 INTERNAL**（3 = variables.scss 全部声明——z 1、spacing 2；本模块无 animation.scss；`$module: #{$prefix}-backtop` 类名胶水不计，anchor `30 = 26 + 4 + 0`、datePicker `223 = 220 + 3 + 0`、timePicker `20 = 14 + 6 + 0`、transfer `50 = 47 + 3 + 0` 先例）。

## API

`SemiBackTop({scrollController, visibilityHeight: 400, duration: const Duration(milliseconds: 450), onClick, child, semanticsLabel})`。

scrollController `ScrollController?`（滚动容器；★上游 `target: getDefaultTarget` 缺省 window——window 无对应，见差异清单，缺省不监听、恒不可见）。visibilityHeight `double`（出现阈值，`scrollTop > visibilityHeight` 时显示；index.tsx:38 `visibilityHeight: 400`；★负值恒显——上游测试 `visibilityHeight: -1` 同口径）。duration `Duration`（滚动到顶部的时间，index.tsx:40 `duration: 450` 毫秒；★同值兼作点击节流窗口且窗口 mount 时捕获）。onClick `VoidCallback?`（点击回传；上游 `(e: MouseEvent) => void`——e 无对应）。child `Widget?`（按钮内容，上游 `children`；缺省 renderDefault）。semanticsLabel `String?`（★上游无 aria-label——本移植补 Semantics button，见差异清单）。

## 行为

### 显示与隐藏

监听 `scrollController`（foundation.ts:93-103 `handleScroll`）：`scrollTop > visibilityHeight` 显示、否则隐藏（:100）；★目标缺失（controller 空/无 client）即隐藏（:94-98 `updateVisible(false)`）。挂载即评估一次（:28-34 init 注册 listener 后立即 handleScroll）；visibilityHeight 变化即重估（index.tsx:68-71 componentDidUpdate）、滚动容器换绑即重估（foundation.ts:44-51 `updateTarget` destroy+init 同口径，propUpdates 测试口径）。

### 点击滚动与节流

点击 → `setScrollTop(0)`（foundation.ts:49-52）→ `position.animateTo(0, duration, Curves.easeInOutCubic)`（:62-82，`from = position.pixels` = getScroll :52-60）+ `onClick` 回传（每次节流触发均滚顶 + 发 onClick，trailing 补发同样滚顶）。★index.tsx:64 throttle 双沿：leading 即发、窗口内再点置旗标、窗口末补发一次（pendingClick.test.jsx：两次连点 → 1 次立即 + tick(100) 补 1 次）；三次连点 → 恰 2 次；★unmount `this.handler.cancel()` 后 pending 不达（componentWillUnmount，:77-79）。★窗口 mount 时捕获（componentDidMount 一次性创建 handler——duration 后改不换窗，动画时长仍读当前值 quirk）。

### 默认内容

index.tsx:105-107 `renderDefault` = `<IconButton theme="light" icon={<IconChevronUp />} />` → `SemiButton(null, variant: SemiButtonVariant.light, icon: SemiIcon(SemiIcons.chevronUp))`（icon-only）；★默认按钮无 onClick，点击由外层容器承担（index.tsx:116-130）。children 非空即替换（:116 `children ? children : this.renderDefault()`）。

### 定位与 RTL

`position: fixed` + `right: $spacing-backtop-right; bottom: $spacing-backtop-bottom`（backtop.scss:6-9）→ 宿主 Stack 直接子节点 `PositionedDirectional(end: spacingBacktopRight, bottom: spacingBacktopBottom)`（★需 Stack 直接子节点位——组件包装不影响、render-object 包装断 ParentData，见差异清单）。RTL（rtl.scss:6-8 `direction: rtl` / `right: auto` / `left: $spacing-backtop-right`）→ Directionality + end/start 自动翻边（按钮翻左下角）。`overflow: hidden`（backtop.scss:14）→ ClipRect；`cursor: pointer`（:11）→ MouseRegion click。

## 主题（3 对账）

来源 packages/semi-foundation/backTop/variables.scss（3 声明行 / 3 唯一名——z 1、spacing 2；无 animation.scss）。对账 **3 = 3 FIELDS + 0 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表；`$module: #{$prefix}-backtop` 类名胶水不计）。0 条死变量——三条均上游消费（backtop.scss:8-10）。数值默认直写字面量（`10` / `100px` → 100 / `50px` → 50），无 `var(--semi-*)`、无引用 token。★`zBacktop` 无 Flutter z-index 槽（SemiTooltip.zIndex 同口径：仅 API 对齐，叠放走插入/子序）——字段照落 theme，widget 注释引用 + 本表注明（transitionDelayAnchorTitleText 先例）。解析列即 `SemiBackTopThemeData.resolve` 默认表达式。类型覆盖：**1 int + 2 double**。

### A. Sass 声明映射（3 FIELDS）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$z-backtop: 10` | `zBacktop` | `10`（返回顶部 z-index；★无 Flutter z-index 槽——叠放由宿主 Stack 子序决定，注释引用留档） |
| `$spacing-backtop-right: 100px` | `spacingBacktopRight` | `100`（距右侧距离；RTL 翻左边——rtl.scss:7-8） |
| `$spacing-backtop-bottom: 50px` | `spacingBacktopBottom` | `50`（距底侧距离） |

### B. HARDCODES 另列（`_BackTopMetrics` / 调用点，widget 源内含原始片段）

| 上游片段 | 落点 |
|---|---|
| `position: fixed` | 视口固定（backtop.scss:6 → PositionedDirectional 宿主 Stack 子节点，见差异清单） |
| `box-sizing: border-box` | 盒模型（backtop.scss:7 → Flutter 盒模型天生 border-box，注释留档） |
| `z-index: $z-backtop` | z-index（backtop.scss:10 → ★无 z-index 槽，叠放由宿主 Stack 子序决定；`zBacktop` 字段注释引用） |
| `cursor: pointer` | 可点光标（backtop.scss:11 → MouseRegion(SystemMouseCursors.click)） |
| `text-align: center` | 内容居中（backtop.scss:13 → shrink-wrap 内容盒，注释留档） |
| `overflow: hidden` | 内容裁剪（backtop.scss:14 → ClipRect） |
| `direction: rtl` | RTL 方向（rtl.scss:6 → Directionality） |
| `right: auto` | RTL 右偏移清除（rtl.scss:7 → PositionedDirectional 自动翻边） |
| `left: $spacing-backtop-right` | RTL 左偏移（rtl.scss:8 → end/start 自动翻边） |
| `visibilityHeight: 400` | 缺省可见阈值（index.tsx:38 → `visibilityHeight` 构造缺省 400） |
| `target: getDefaultTarget` | 缺省滚动目标（index.tsx:39；`const getDefaultTarget = () => window;` index.tsx:16 → `scrollController`，见差异清单） |
| `duration: 450` | 缺省滚动毫秒数（index.tsx:40 → `duration` 构造缺省 450ms；★兼作节流窗口） |
| `throttle(this.handleClick, this.props.duration ?? BackTop.defaultProps.duration)` | 点击双沿节流（index.tsx:64 → `_handleTap`；★窗口 mount 时捕获 quirk） |
| `theme="light"` | 默认按钮 variant（index.tsx:106 → `SemiButtonVariant.light`） |
| `icon={<IconChevronUp />}` | 默认按钮图标（index.tsx:106 → `SemiIcon(SemiIcons.chevronUp)`） |
| `easing: 'easeInOutCubic'` | 滚动动画缓动（foundation.ts:72 → `Curves.easeInOutCubic`） |

## 差异清单

★照搬留档（quirk 原样）：
1. **throttle 双沿 + 窗口 mount 捕获**：index.tsx:64 一次性 `throttle(handleClick, duration ?? 450)`——leading 即发 + trailing 窗口末补发（三次连点恰 2 次）；★duration 后改不换窗（componentDidMount 一次性创建 handler），动画时长仍读当前值。
2. **unmount 取消 pending trailing**：componentWillUnmount `this.handler.cancel()`（:77-79）——pendingClick.test.jsx `does not deliver a throttled click after unmount`。
3. **每次节流触发均滚顶 + 发 onClick**：`handleClick` → `setScrollTop(0)` + `notifyClick(e)`（trailing 补发同样滚顶）。
4. **visibilityHeight 负值恒显**：`scrollTop > visibilityHeight`（foundation.ts:100）——`-1` 时 scrollTop 0 亦显（backtop.test.js/pendingClick.test.jsx `visibilityHeight: -1` 口径）。
5. **duration 不下传 DOM**：`...others` 解构剔除 duration（backtop.test.js `duration should not be passed to dom`）。
6. **默认按钮无 onClick**：renderDefault 的 IconButton 无 onClick，点击由外层容器承担（index.tsx:116-130）。
7. **重复点击动画竞态裁剪**：上游每次 click 新建 semi-animation `Animation`（旧实例不 destroy、双实例逐帧竞写 scrollTop，foundation.ts:62-82）→ Flutter `animateTo` 后者接管（DrivenScrollActivity 取代前者）。

偏差/裁剪：
8. **target → scrollController**：上游 `target: () => any`（缺省 `const getDefaultTarget = () => window;` index.tsx:16）→ window/DOM 无对应 → `scrollController: ScrollController?`（anchor `getContainer → scrollController` 先例）；缺省不监听、恒不可见。
9. **position: fixed → 宿主 Stack 子节点**：视口固定（backtop.scss:6）→ `PositionedDirectional`（宿主 Stack 铺满视口即视口固定；★需 Stack 直接子节点位——组件包装不影响、render-object 包装断 ParentData）。★`z-index: $z-backtop` 无槽：叠放由宿主 Stack 子序决定（SemiTooltip.zIndex 同口径）。
10. **requestAnimationFrame 包装不移植**：foundation.ts:102 `requestAnimationFrame(update)` → 同步评估 + 首帧后补评估（★Flutter 滚动容器首帧后才 attach——init 即评估 + postFrame 复评）。
11. **target() getter 逐次求值不移植**：propUpdates `tracks a new DOM target returned by a stable getter...`——ScrollController 身份即绑定（didUpdateWidget 比较 identity；换绑即重估 = updateTarget destroy+init 同口径）。
12. **onClick(e) → VoidCallback**：MouseEvent 无对应（anchor 偏差同口径）。
13. **className/style/…others 裁剪**：Flutter 无 CSS 类（anchor 偏差 18 同口径）。
14. **键盘激活补强**：上游静态 div 无键盘激活（index.tsx:119-120 jsx-a11y 禁用注释）→ 本移植 Focus + Enter（统一交互约定；Space/可打印键忽略，锚点 keyboardActivation 同口径）。
15. **Semantics 补强**：上游无 aria-label → `Semantics(button: true)` + `semanticsLabel`。
16. **window scrollTop 双写不移植**：adapter `document.body.scrollTop = scrollTop; document.documentElement.scrollTop = scrollTop`（index.tsx:84-90 window 语义）→ `position.animateTo`。
17. **text-align: center / box-sizing: border-box 恒等**：shrink-wrap 内容盒 + Flutter 盒模型天生 border-box（注释留档）。

## 用法

```dart
Stack(
  children: [
    SingleChildScrollView(
      controller: controller,
      child: tallContent,
    ),
    SemiBackTop(
      scrollController: controller,
      visibilityHeight: 400,
      duration: const Duration(milliseconds: 450),
      onClick: () {},
      // child: 自定义按钮内容（缺省 IconButton theme="light" + IconChevronUp）
    ),
  ],
)
```
