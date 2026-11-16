# SemiSkeleton

骨架屏（上游 Semi Skeleton 全件移植）：`SemiSkeleton` 容器（`loading` 是/否、`active` 高亮扫光、`placeholder`/`child`）+ 五个形状 `SemiSkeletonAvatar` / `SemiSkeletonImage` / `SemiSkeletonTitle` / `SemiSkeletonButton` / `SemiSkeletonParagraph`。主题对账 **17 = 15 FIELDS + 2 MOTION + 0 INTERNAL**（variables.scss 15 声明 + animation.scss 2 声明；`$module: #{$prefix}-skeleton` 类名胶水与 rtl.scss 的 `direction: rtl` 不计，datePicker `223 = 220 + 3 + 0`、timePicker `20 = 14 + 6 + 0`、transfer `50 = 47 + 3 + 0`、anchor `30 = 26 + 4 + 0`、breadcrumb `20 = 16 + 4 + 0`、pagination `48 = 41 + 7 + 0`、tree `33 = 29 + 4 + 0`、steps `104 = 94 + 10 + 0`、upload `85 = 85 + 0 + 0` 先例）；**0 死变量**。

## API

`SemiSkeleton({active: false, loading: true, placeholder, child})`。

active `bool` — 高亮扫光（仅 loading 时生效；对应 `.semi-skeleton-active`）。loading `bool` 缺省 `true` — 为真渲染 placeholder，否则渲染 child（index.tsx:35-53）。placeholder `Widget?` — 骨架内容（形状组合）；缺省空盒子。child `Widget?` — 真实内容。

`SemiSkeletonAvatar({size: medium, shape: circle})`。size `SemiSkeletonAvatarSize`（extraExtraSmall 20 / extraSmall 24 / small 32 / medium 48 / large 72 / extraLarge 128）。shape `SemiSkeletonAvatarShape`（circle 50% / square `$radius-skeleton_item`）。

`SemiSkeletonImage({})` — 宽高 100%（铺满父级，父级需受限宽高）。`SemiSkeletonTitle({})` — 宽 100%、高 24。`SemiSkeletonButton({})` — 115 × 32。`SemiSkeletonParagraph({rows: 4})` — 每行高 16、行距 10；最后一行宽 60%（单行时 100%）。

## 行为

### 容器

`loading == true` 时只渲染 placeholder（上游外层 div 仅带 `semi-skeleton`/`-active` 类，无样式）；`loading == false` 时整体替换为 child。容器本身不提供宽度/布局，形状的 100% 语义依赖父级约束（Flutter 无 CSS 块级布局）。

### 扫光

`.semi-skeleton-active` 把每个形状的纯色底换成 `linear-gradient(90deg, 默认色 25%, 高亮色 44%, 默认色 88%)`，`background-size: 400% 100%`，`animation: 1400ms skeleton-loading ease infinite` + `animation-fill-mode: forwards`；关键帧 `background-position: 100% 50%` → `0 50%`。Flutter 端用一个 1400ms 循环的 `AnimationController`（时长/缓动取主题）驱动 LinearGradient 的 begin/end：4 倍盒宽的三段渐变整体右移 3 倍盒宽，高亮带从左向右扫过，与 CSS 几何一致。静态形状（无 active 祖先）保持纯色底。

### 形状几何

头像：宽高同值（六档尺寸），圆角 circle 用 `border-radius: 50%`（= 尺寸/2），square 用 `$radius-skeleton_item`。标题：宽 100%、高 `$height-skeleton_title`（= `$height-control-small` = 24）。按钮：115 × `$height-skeleton_button`（= `$height-control-default` = 32）。图片：100% × 100%。段落：`ul` 无 margin/padding/列表符号，每行宽 100%、高 16、下边距 10；`li:last-child` 宽 60% 且下边距 0，但 `li:first-child` 也是 100% 且 CSS 后写者胜——**rows === 1 时唯一行宽 100%**。RTL：段落末行用 `AlignmentDirectional.centerStart`（文字方向无关，宽度百分比不受影响）。

## 主题（17 对账）

来源 packages/semi-foundation/skeleton/variables.scss（15 声明：color 2、width 7、height 3、spacing 1、radius 2）+ animation.scss（2 声明）。对账 **17 = 15 FIELDS + 2 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表）。全局 token 解析：`var(--semi-color-fill-0/1)` → `theme.colors.colorFill0/1`，`var(--semi-border-radius-small)` → `theme.radius.borderRadiusSmall.value`（= 3）；引用 token：`$height-control-small` → 24、`$height-control-default` → 32（generate_button.py 先例）。类型覆盖：**2 Color + 13 double = 15 FIELDS**；MOTION **1 Duration + 1 Curve**。解析列即 `SemiSkeletonThemeData.resolve` 默认表达式。

### A. Sass 声明映射（15 FIELDS + 2 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-skeleton_default-bg-default: var(--semi-color-fill-0)` | `colorSkeletonDefaultBgDefault` | `theme.colors.colorFill0` |
| `$color-skeleton_loading-gradient-bg-active: var(--semi-color-fill-1)` | `colorSkeletonLoadingGradientBgActive` | `theme.colors.colorFill1` |
| `$width-skeleton_avatar_extra_extra_small: 20px` | `widthSkeletonAvatarExtraExtraSmall` | `20` |
| `$width-skeleton_avatar_extra_small: 24px` | `widthSkeletonAvatarExtraSmall` | `24` |
| `$width-skeleton_avatar_small: 32px` | `widthSkeletonAvatarSmall` | `32` |
| `$width-skeleton_avatar_medium: 48px` | `widthSkeletonAvatarMedium` | `48` |
| `$width-skeleton_avatar_large: 72px` | `widthSkeletonAvatarLarge` | `72` |
| `$width-skeleton_avatar_extra_large: 128px` | `widthSkeletonAvatarExtraLarge` | `128` |
| `$width-skeleton_button: 115px` | `widthSkeletonButton` | `115` |
| `$height-skeleton_li: 16px` | `heightSkeletonLi` | `16` |
| `$height-skeleton_title: $height-control-small` | `heightSkeletonTitle` | `24`（`$height-control-small`） |
| `$height-skeleton_button: $height-control-default` | `heightSkeletonButton` | `32`（`$height-control-default`） |
| `$spacing-skeleton_li-marginBottom: 10px` | `spacingSkeletonLiMarginBottom` | `10` |
| `$radius-skeleton_item: var(--semi-border-radius-small)` | `radiusSkeletonItem` | `theme.radius.borderRadiusSmall.value` |
| `$radius-skeleton_li: var(--semi-border-radius-small)` | `radiusSkeletonLi` | `theme.radius.borderRadiusSmall.value` |
| `$animation_duration-skeleton-highlight: 1400ms` | `animationDurationSkeletonHighlight` | `const Duration(milliseconds: 1400)` |
| `$animation_function-skeleton-highlight: ease` | `animationFunctionSkeletonHighlight` | `Curves.ease`（CSS `ease` = `cubic-bezier(0.25, 0.1, 0.25, 1)`） |

### B. HARDCODES 另列（widget 文件头注释 / 调用点，源内含原始片段）

| 上游片段 | 说明 |
|---|---|
| skeleton.scss:94-99 `linear-gradient(90deg, ...)` | 三段渐变（25% / 44% / 88%） |
| skeleton.scss:96 `background-size: 400% 100%` | 渐变宽 4 倍盒子 |
| keyframes 0% `background-position: 100% 50%` | 起始位（渐变右对齐） |
| keyframes 100% `background-position: 0 50%` | 终点位（渐变左对齐） |
| skeleton.scss:101 `animation: ... infinite` | 无限循环 |
| skeleton.scss:102 `animation-fill-mode: forwards` | 填充模式 |
| skeleton.scss:15 `border-radius: 50%` | avatar-circle 圆形 |
| skeleton.scss:64 `width: 60%` | li:last-child（rows > 1） |
| skeleton.scss:68 `width: 100%` | li:first-child（rows === 1 时后写者胜） |
| skeleton.scss:52 `list-style-type: none` | ul 去列表符号 |
| item.tsx:88 `rows: 4` | paragraph 缺省行数 |
| item.tsx:42-43 `size: 'medium'` | avatar 缺省尺寸 |
| item.tsx:42-43 `shape: 'circle'` | avatar 缺省形状 |
| avatar `strings.SIZE` 含 `'default'` | ★skeleton.scss 无 `-avatar-default` 尺寸类（零尺寸），枚举不收 |

## 差异清单

- **无浏览器/CSS 布局**：形状的 `width: 100%` / `height: 100%` 映射为 `double.infinity`——父级必须受限（标题/段落需要受限宽度，图片需要受限宽高）；上游块级上下文自动拉伸的行为在 Flutter 不存在。
- `Skeleton.Avatar` 的 `size` 上游可传 `'default'`，但 skeleton.scss 没有对应尺寸类（渲染为零尺寸盒子）；Flutter 枚举不提供该档。
- 上游 `className/style` 直通属性未移植；Flutter 由外层 `SizedBox`/`Container` 控制。
- 扫光用 Flutter 渐变平移复现 CSS `background-position` 动画，几何等价但非逐像素（无 `background-size` 概念）。
- `direction: rtl`（rtl.scss）在 Flutter 由 `Directionality` 承担；段落末行对齐用 `AlignmentDirectional.centerStart`。

## 用法

```dart
SemiSkeleton(
  active: true,
  loading: isLoading,
  placeholder: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiSkeletonTitle(),
      const SizedBox(height: 16),
      SemiSkeletonParagraph(rows: 3),
    ],
  ),
  child: const Text('真实内容'),
)
```

```dart
SemiSkeleton(
  active: true,
  placeholder: Row(
    children: [
      SemiSkeletonAvatar(size: SemiSkeletonAvatarSize.large),
      const SizedBox(width: 12),
      const Expanded(child: SemiSkeletonParagraph(rows: 2)),
    ],
  ),
)
```

图片占位需要受限父级：`SizedBox(width: 200, height: 120, child: SemiSkeletonImage())`。
