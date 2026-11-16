# SemiCarousel

轮播（上游 Semi Carousel 全件移植）：`slide`/`fade` 切换、自动播放（`interval + speed`、hover 400ms 防抖暂停）、`dot`/`line`/`columnar` 三种指示器（left/center/right、small/medium、click/hover 触发、dark/primary/light 主题）、两侧箭头（always/hover、三种主题色、自定义图标）、受控/非受控、RTL 镜像、命令式 `SemiCarouselController`（next/prev/goTo/play/stop）。主题对账 **40 = 34 FIELDS + 6 MOTION + 0 INTERNAL**（variables.scss 34 声明：color 15、width 6、height 6、spacing 6、radius 1；animation.scss 6 声明：指示器/箭头背景过渡各三元组；`$module` 胶水与 rtl.scss 不计，datePicker `223 = 220 + 3 + 0` … steps `104 = 94 + 10 + 0`、upload `85 = 85 + 0 + 0`、skeleton `17 = 15 + 2 + 0`、tabs `144 = 121 + 23 + 0` 先例）；**0 死变量**（40 声明全部被 carousel.scss / rtl.scss 消费）。

## API

`SemiCarousel({children: const [], activeIndex, defaultActiveIndex: 0, animation: slide, autoPlay: true, autoPlayInterval: 2000ms, hoverToPause: true, speed: 300ms, theme: light, showArrow: true, showIndicator: true, indicatorType: dot, indicatorSize: small, indicatorPosition: center, indicatorTrigger: click, arrowType: always, slideDirection: left, prevArrowIcon, nextArrowIcon, controller, onChange, semanticLabel})`。

children `List<Widget>`（轮播项）。activeIndex `int?`（非 null 即受控：交互只回调，不内部切换；受控时不自动播放）。defaultActiveIndex `0`（`DEFAULT_ACTIVE_INDEX`）。animation `SemiCarouselAnimation`（slide/fade）。autoPlay `bool`（`children.length > 1` 且非受控才生效）。autoPlayInterval `Duration`（`DEFAULT_INTERVAL: 2000`；实际切换间隔 = interval + speed）。hoverToPause `bool`（缺省 true；hover 400ms 后暂停、离开 400ms 后恢复）。speed `Duration`（`DEFAULT_SPEED: 300`，切换动画时长）。theme `SemiCarouselThemeColor`（dark/primary/light）。showArrow / showIndicator `bool`（且 children > 1）。indicatorType / indicatorSize / indicatorPosition / indicatorTrigger 见枚举。arrowType `always/hover`（hover → 指针进入才显示）。slideDirection `left/right`（反向 slide 方向）。prevArrowIcon / nextArrowIcon `Widget?`（自定义箭头，替代 chevron）。controller `SemiCarouselController?`。onChange `(index, preIndex)`。semanticLabel `String?`。

`SemiCarouselController()`：`next()` / `prev()` / `goTo(int)` / `play({Duration? interval})`（即使 autoPlay: false 也强制播放）/ `stop()`；`isAttached`。

## 行为

### 切换

`next`：下标 +1 取模，`isReverse = false`；`prev`：下标 -1 取模，`isReverse = true`；`goTo/指示器`：`isReverse = 旧 > 新`（foundation.ts:35-96）。非受控内部切换 + `onChange(新, 旧)`（仅变化时）；受控只回调，等父级更新 `activeIndex` 后由 `didUpdateWidget` 驱动动画（方向沿用触发动作的 reverse 标记）。`slideDirection: left` 时 `isReverse` 直接用，`right` 时取反（index.tsx:300）。首次渲染不做进入动画（`isInit`）。

### 自动播放

`children > 1` 且非受控且 `autoPlay` → 以 `interval + speed` 间隔自动 `next`（foundation.ts:118 getSwitchingTime）。`next/prev` 会先 `stop` 再重新排程；`goTo`/指示器不重启。hover：进入 400ms 后停止（`hoverToPause`），离开 400ms 后恢复；`play()` 强制播放、`stop()` 取消（受控下同样可强制）。

### 视觉

- 内容：`slide` 时当前项从 `translateX(100%)`（reverse 为 -100%）滑入、上一项滑出到 `-100%`（reverse 为 100%），其余隐藏（`visibility: hidden`）；`fade` 时当前项透明度 0→1、上一项 1→0。动画时长 `speed`、曲线 `ease`（index.tsx:214）。
- 箭头：字号 = `$width-carousel_arrow`（32）；prev 左 / next 右，垂直居中，距边 20；颜色按主题（default/hover）；`arrowType: hover` 时指针进入前整体 `opacity: 0`；RTL 交换左右、图标 `scaleX(-1)`。
- 指示器：底部距边 32；dot 小 8 / 中 12（圆角 50%、间距 8）、line 宽 240（高 4/6、间距 4、flex 等分）、columnar 宽 4/6（高 12→20 / 20→28、间距 4）；颜色 default/hover/active 三段（dark = black 50%/70%/100%，primary = blue-6 40%/70%/100%，light = white 40%/70%/100%）；`trigger: hover` 悬停立即切换，`click` 点击切换。

### RTL / 尺寸

RTL：内容方向随 `Directionality`，指示器 dot/columnar 外边距换侧，箭头左右对调且图标翻转（rtl.scss），指示器 left/right 位置保持物理左右（上游同）。尺寸：内容区宽高 100%（CSS），Flutter 需要父级有界宽高（例如放在 `SizedBox` 中），组件本身用 `StackFit.expand`。

## 主题（40 对账）

来源 packages/semi-foundation/carousel/variables.scss（34 声明）+ animation.scss（6 声明）。对账 **40 = 34 FIELDS + 6 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表）。**0 死变量**。全局 token 解析：`rgba(var(--semi-black), α)` / `rgba(var(--semi-blue-6), α)` / `rgba(var(--semi-white), α)` → `theme.palette.black/blue6/white.toColor(α)`；动画 token：`var(--semi-transition_delay-none)` → `Duration.zero`、`var(--semi-transition_function-easeOut)` → `Curves.easeOut`；`$radius-carousel_indicator_dot: 50%` 存 50（消费按 `size * value / 100`）。类型覆盖：**15 Color + 19 double = 34 FIELDS**；MOTION **4 Duration + 2 Curve**。解析列即 `SemiCarouselThemeData.resolve` 默认表达式。

### A. Sass 声明映射（34 FIELDS + 6 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-carousel_indicator_theme_dark-bg-default: rgba(var(--semi-black), .5)` | `colorCarouselIndicatorThemeDarkBgDefault` | `theme.palette.black.toColor(0.5)` |
| `$color-carousel_indicator_theme_dark-bg-hover: rgba(var(--semi-black), .7)` | `colorCarouselIndicatorThemeDarkBgHover` | `theme.palette.black.toColor(0.7)` |
| `$color-carousel_indicator_theme_dark-bg-active: rgba(var(--semi-black), 1)` | `colorCarouselIndicatorThemeDarkBgActive` | `theme.palette.black.toColor(1)` |
| `$color-carousel_indicator_theme_primary-bg-default: rgba(var(--semi-blue-6), .4)` | `colorCarouselIndicatorThemePrimaryBgDefault` | `theme.palette.blue6.toColor(0.4)` |
| `$color-carousel_indicator_theme_primary-bg-hover: rgba(var(--semi-blue-6), .7)` | `colorCarouselIndicatorThemePrimaryBgHover` | `theme.palette.blue6.toColor(0.7)` |
| `$color-carousel_indicator_theme_primary-bg-active: rgba(var(--semi-blue-6), 1)` | `colorCarouselIndicatorThemePrimaryBgActive` | `theme.palette.blue6.toColor(1)` |
| `$color-carousel_indicator_theme_light-bg-default: rgba(var(--semi-white), .4)` | `colorCarouselIndicatorThemeLightBgDefault` | `theme.palette.white.toColor(0.4)` |
| `$color-carousel_indicator_theme_light-bg-hover: rgba(var(--semi-white), .7)` | `colorCarouselIndicatorThemeLightBgHover` | `theme.palette.white.toColor(0.7)` |
| `$color-carousel_indicator_theme_light-bg-active: rgba(var(--semi-white), 1)` | `colorCarouselIndicatorThemeLightBgActive` | `theme.palette.white.toColor(1)` |
| `$color-carousel_arrow_theme_dark-bg-default: rgba(var(--semi-black), .5)` | `colorCarouselArrowThemeDarkBgDefault` | `theme.palette.black.toColor(0.5)` |
| `$color-carousel_arrow_theme_dark-bg-hover: rgba(var(--semi-black), 1)` | `colorCarouselArrowThemeDarkBgHover` | `theme.palette.black.toColor(1)` |
| `$color-carousel_arrow_theme_primary-bg-default:  rgba(var(--semi-blue-6), .4)` | `colorCarouselArrowThemePrimaryBgDefault` | `theme.palette.blue6.toColor(0.4)` |
| `$color-carousel_arrow_theme_primary-bg-hover:  rgba(var(--semi-blue-6), 1)` | `colorCarouselArrowThemePrimaryBgHover` | `theme.palette.blue6.toColor(1)` |
| `$color-carousel_arrow_theme_light-bg-default: rgba(var(--semi-white), .4)` | `colorCarouselArrowThemeLightBgDefault` | `theme.palette.white.toColor(0.4)` |
| `$color-carousel_arrow_theme_light-bg-hover: rgba(var(--semi-white), 1)` | `colorCarouselArrowThemeLightBgHover` | `theme.palette.white.toColor(1)` |
| `$width-carousel_indicator_line: 240px` | `widthCarouselIndicatorLine` | `240` |
| `$width-carousel_indicator_columnar_small: 4px` | `widthCarouselIndicatorColumnarSmall` | `4` |
| `$width-carousel_indicator_columnar_medium: 6px` | `widthCarouselIndicatorColumnarMedium` | `6` |
| `$width-carousel_indicator_dot_small:8px` | `widthCarouselIndicatorDotSmall` | `8` |
| `$width-carousel_indicator_dot_medium: 12px` | `widthCarouselIndicatorDotMedium` | `12` |
| `$width-carousel_arrow: 32px` | `widthCarouselArrow` | `32` |
| `$height-carousel_indicator_columnar_small_default: 12px` | `heightCarouselIndicatorColumnarSmallDefault` | `12` |
| `$height-carousel_indicator_columnar_small_active: 20px` | `heightCarouselIndicatorColumnarSmallActive` | `20` |
| `$height-carousel_indicator_columnar_medium_default: 20px` | `heightCarouselIndicatorColumnarMediumDefault` | `20` |
| `$height-carousel_indicator_columnar_medium_active: 28px` | `heightCarouselIndicatorColumnarMediumActive` | `28` |
| `$height-carousel_indicator_line_small: 4px` | `heightCarouselIndicatorLineSmall` | `4` |
| `$height-carousel_indicator_line_medium: 6px` | `heightCarouselIndicatorLineMedium` | `6` |
| `$radius-carousel_indicator_dot: 50%` | `radiusCarouselIndicatorDot` | `50` |
| `$spacing-carousel_indicator-padding: 32px` | `spacingCarouselIndicatorPadding` | `32` |
| `$spacing-carousel_indicator_columnar-marginX: 4px` | `spacingCarouselIndicatorColumnarMarginX` | `4` |
| `$spacing-carousel_indicator_line-marginX: 4px` | `spacingCarouselIndicatorLineMarginX` | `4` |
| `$spacing-carousel_indicator_dot-marginX: 8px` | `spacingCarouselIndicatorDotMarginX` | `8` |
| `$spacing-carousel_arrow-left: 20px` | `spacingCarouselArrowLeft` | `20` |
| `$spacing-carousel_arrow-right: 20px` | `spacingCarouselArrowRight` | `20` |
| `$transition_duration_carousel_indicator-bg: var(--semi-transition_delay-none)` | `transitionDurationCarouselIndicatorBg` | `Duration.zero` |
| `$transition_function_carousel_indicator-bg: var(--semi-transition_function-easeOut)` | `transitionFunctionCarouselIndicatorBg` | `Curves.easeOut` |
| `$transition_delay_carousel_indicator-bg: var(--semi-transition_delay-none)` | `transitionDelayCarouselIndicatorBg` | `Duration.zero` |
| `$transition_duration_carousel_arrow-bg: var(--semi-transition_delay-none)` | `transitionDurationCarouselArrowBg` | `Duration.zero` |
| `$transition_funciton_carousel_arrow-bg: var(--semi-transition_function-easeOut)` | `transitionFuncitonCarouselArrowBg` | `Curves.easeOut` |
| `$transition_delay_carousel_arrow-bg: var(--semi-transition_delay-none)` | `transitionDelayCarouselArrowBg` | `Duration.zero` |

### B. HARDCODES 另列（widget 文件头注释 / 调用点，源内含原始片段）

| 上游片段 | 说明 |
|---|---|
| constants.ts `DEFAULT_ACTIVE_INDEX: 0` / `DEFAULT_INTERVAL: 2000` / `DEFAULT_SPEED: 300` | 缺省下标/间隔/时长 |
| `ANIMATION_MAP` / `TYPE_MAP` / `THEME_MAP` / `POSITION_MAP` / `ARROW_MAP` / `SIZE` / `TRIGGER` 枚举串 | 对外枚举 |
| slide keyframes `translateX(100%)` / `translateX(-100%)` | 滑入/滑出位移 |
| `transitionTimingFunction: 'ease'` | speed 曲线 |
| `visibility: hidden` / `opacity: 0` | slide 隐藏非当前项 / fade 初始透明 |
| `IconChevronLeft` / `IconChevronRight` | 默认箭头图标 |
| `aria-label="Previous index"` / `aria-label="Next index"` | 箭头语义 |
| `scaleX(-1)` | RTL 箭头翻转 |
| `opacity: 0` + `&:hover` | hover 箭头隐藏/恢复 |
| `debounce(..., 400)` | hover 暂停/恢复防抖 |
| `:not(:last-child)` | 指示器项间距 |
| `children.length > 1` | 指示器/箭头显示门槛 |
| `interval + speed` | 自动播放切换间隔 |

## 差异清单

- **autoPlay 对象形态**：上游 `autoPlay: {interval, hoverToPause}` → Flutter `autoPlay` + `autoPlayInterval` + `hoverToPause`；受控组件不自动播放（上游同），`controller.play()` 可强制。
- **arrowProps**：上游可透传 DOM props → Flutter 仅 `prevArrowIcon`/`nextArrowIcon`（图标替换，无 tabIndex/aria 透传）。
- **未移植 API**：`className`/`style`（外层布局承担）、`Carousel.Indicator`/`Carousel.Arrow` 独立使用（内部组件私有）。
- **键盘**：上游 `handleKeyDown` 在 index.tsx 中未接线；Flutter 同样不提供键盘切换。
- **动画实现**：CSS keyframes/transition → 单个 `AnimationController`（ease、speed）；`slide-out` 同时进行；切换中途再次切换会从新起点重播（上游 CSS 类同样重播）。
- **slide 非当前项**：CSS 用 `visibility: hidden` 保留布局；Flutter 在 Stack 中不挂载非当前/非出场项（视觉等价）。
- **指示器 hover 触发**：上游 `onMouseEnter` 立即切换（无防抖）；Flutter 同（不受 400ms 影响）。
- **RTL 指示器 left/right**：保持物理左右（上游 rtl.scss 未镜像）；箭头交换 + 图标翻转。
- **尺寸约束**：需要父级有界宽高（CSS 100% 的 Flutter 对应）。

## 用法

```dart
SemiCarousel(
  autoPlayInterval: const Duration(seconds: 3),
  children: const [
    SizedBox(child: ColoredBox(color: Color(0xFF111111))),
    SizedBox(child: ColoredBox(color: Color(0xFF222222))),
    SizedBox(child: ColoredBox(color: Color(0xFF333333))),
  ],
  onChange: (index, preIndex) => print('$preIndex -> $index'),
)
```

```dart
final controller = SemiCarouselController();

SizedBox(
  height: 240,
  child: SemiCarousel(
    controller: controller,
    autoPlay: false,
    animation: SemiCarouselAnimation.fade,
    indicatorType: SemiCarouselIndicatorType.line,
    indicatorPosition: SemiCarouselIndicatorPosition.right,
    theme: SemiCarouselThemeColor.primary,
    children: pages,
  ),
);
// controller.next(); controller.goTo(2); controller.stop();
```
