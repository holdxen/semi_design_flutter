# SemiAvatar

非 Material 头像（上游 Semi Avatar 全件移植）：`SemiAvatar`（图片/文字/自定义内容、16+1 色、7 档尺寸、circle/square、focus 键盘、hoverMask、额外描边环、内容脉冲、top/bottom slot）+ `SemiAvatarGroup`（叠压、`maxCount` 折叠 `+N`、`overlapFrom` 层序）。主题对账 **99 = 89 FIELDS + 10 MOTION + 0 INTERNAL**（variables.scss 89 声明 + animation.scss 10 声明；`$module` 类名胶水、`$colors` 列表与 rtl.scss 的 `direction: rtl` 不计，datePicker `223 = 220 + 3 + 0`、timePicker `20 = 14 + 6 + 0`、transfer `50 = 47 + 3 + 0`、anchor `30 = 26 + 4 + 0`、breadcrumb `20 = 16 + 4 + 0`、pagination `48 = 41 + 7 + 0`、tree `33 = 29 + 4 + 0`、steps `104 = 94 + 10 + 0`、upload `85 = 85 + 0 + 0`、skeleton `17 = 15 FIELDS + 2 MOTION + 0 INTERNAL` 先例）；★**1 死变量**（`$width-avatar-bottom_slot_square_extra_small-border`（上游未消费），见下）。

## API

`SemiAvatar({text, child, src, alt, color: grey, shape: circle, size: medium, customSize, gap: 3, onTap, onImageError, hoverMask, border, contentMotion: false, topSlot, bottomSlot, backgroundColor, textColor, semanticsLabel})`。

内容优先级：图片（src 加载成功）> 文字（text，自动缩放）> child。color 为 16 个 palette 色加 white（★white 无上游样式：透明底、文字随宿主继承）。size 七档 extraExtraSmall 20 / extraSmall 24 / small 32 / normal 40 / medium 48 / large 72 / extraLarge 128（上游 `'default'` 档 → 枚举 `normal`）；`customSize` 为自由边长（覆盖 size 盒，文字回落基础 `font-size-regular`，square 圆角回落 0）。gap 是文字缩放留白。onImageError 返回 `false` 保留图片占位不回落文字（上游 onError 契约）。border 传 `SemiAvatarBorder({color, motion})` 开启额外描边环（motion 呼吸动画）。contentMotion 开启内容脉冲。topSlot/bottomSlot 传配置对象（`render` 整体替换默认渲染）；backgroundColor/textColor 是 Flutter 额外覆盖（不来自 Sass）。

`SemiAvatarGroup({children, size: medium, shape: circle, overlapFrom: start, maxCount, renderMore})`。size/shape 统一决定组内头像（覆盖子项参数，上游 cloneElement 语义）；overlapFrom：start 首项在上 / end 末项在上；maxCount 折叠尾部为 `+N` 头像（背景 `colorAvatarMoreDefaultBgDefault`），renderMore(restNumber, restAvatars) 自定义折叠渲染。

## 行为

### 内容与文字缩放

字符串内容按 `gap * 2 < nodeWidth` 缩放（可用宽 nodeWidth-gap*2，Padding+FittedBox.scaleDown 与 scale 公式等价）。图片 `object-fit: cover` 铺满；加载失败回落文字内容（onImageError 返回 false 保留图片位）。★CSS `transform: scale(0.8)`（xs 两档）被行内 transform 覆盖——从不生效，Flutter 端不复现；★CSS `&-image` 透明背景类与渲染类 `-img` 拼写不匹配，图片透明背景实际由「不加颜色类」达成。

### 交互

onTap 存在时可聚焦：focus 轮廓 `outline: $width-avatar-outline solid`（`colorAvatarOutlineFocus`），Enter 触发 onTap，Escape 失焦。hoverMask 在 hover 时铺满头像（`.semi-avatar-hover`）。语义标签 `alt ?? text`，clickable 加 `clickable Avatar: ` 前缀（上游 quirk）。

### 额外描边环与动效

border 环外扩 `W + gap`（1.5 + 2），圆角 circle 50% / square 尺寸类圆角；motion 为 800ms 线性循环（opacity 1→0、scale 1→1.15、border-width 1.5→0，`animation_duration/additionalBorder` 两组关键帧值）。contentMotion 为 1000ms 脉冲（scale 1→0.9→1，`animation_scale-content-*`），top slot wrapper 同步脉冲（上游 `-animated` 双类）。

### Slot

topSlot 仅 circle 且非 extra-extra-small（上游守卫 `"extra-small", "small", "default", "medium", "large", "extra-large"` + circle）；盾形 SVG（TopSlotSvg 51×52 路径 + y 31.7392→47.9333 渐变 + dy 1.65809/模糊 1.10539 投影）按档 shift/scale 定位，文字按档字号+marginTop。★extra-small 档无任何 CSS 尺寸类（零样式 quirk）：无盾形、文字回落 `font-size-regular`。bottomSlot 骑底边（`bottom: gap + W` + `translateY(50%)`）：circle 直径/字号按档；square padding Y1/X4、圆角 4、边框 2（`colorBg0`）、加粗。★square+extra-small 规则类名 `shape_square-extra_small`（下划线）与渲染的 `shape_square-extra-small`（连字符）拼写不匹配——从不命中：font-size 回落 14、border-width 回落 CSS 初始 `medium` = 3（死变量（上游未消费）唯一出处）。

### 头像组

叠压：第 i 项 left = i*(盒宽 + marginLeft)（marginLeft 负值）；描边环 `box-sizing: border-box` 覆盖式绘制（颜色 `colorAvatarDefaultBorderDefault`）。层序 `z-index: $z-avatar-default - $i`（start）/ `z-index: $z-avatar-default - 20 + $i`（end），Flutter 端换算 Stack 绘制序；★`@for 0 through 20` 仅 0..20 项有 z 类（>21 项 auto，低于正 z 层）。`+N` 头像语义标签 `Number of remaining Avatars：N,alt...`（全角冒号，上游原文）。

## 主题（99 对账）

来源 packages/semi-foundation/avatar/variables.scss（89 声明：z 1、color 9、width 28、font 17、spacing 25、radius 9）+ animation.scss（10 声明：duration 2、opacity 2、width 1、scale 5）。对账 **99 = 89 FIELDS + 10 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表）。全局 token 解析：`var(--semi-color-bg-0/1)` → `theme.colors.colorBg0/1`、`var(--semi-color-primary)` → `theme.colors.colorPrimary`、`var(--semi-color-primary-light-active)` → `theme.colors.colorPrimaryLightActive`、`rgba(var(--semi-grey-5), 1)` → `theme.palette.grey5.toColor()`、`var(--semi-border-radius-circle)` → `theme.radius.borderRadiusCircle`（**SemiLength 50%**，按盒尺寸解析，非 px）。类型覆盖：**9 Color + 1 SemiLength + 87 double + 2 Duration**。解析列即 `SemiAvatarThemeData.resolve` 默认表达式。16 色背景/白字是 mixin.scss（非声明），B 表留档、实时读 palette。

### A. Sass 声明映射（89 FIELDS + 10 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$z-avatar-default: 100` | `zAvatarDefault` | 100（组 z-index 层序） |
| `$color-avatar_default-border-default: var(--semi-color-bg-1)` | `colorAvatarDefaultBorderDefault` | theme.colors.colorBg1 |
| `$color-avatar_more_default-bg-default: rgba(var(--semi-grey-5), 1)` | `colorAvatarMoreDefaultBgDefault` | theme.palette.grey5.toColor() |
| `$color-avatar-outline-focus: var(--semi-color-primary-light-active)` | `colorAvatarOutlineFocus` | theme.colors.colorPrimaryLightActive |
| `$width-avatar_extra_extra_small: 20px` | `widthAvatarExtraExtraSmall` | 20 |
| `$font-avatar_extra_extra_small-size: 10px` | `fontAvatarExtraExtraSmallSize` | 10 |
| `$font-avatar_extra_extra_small-lineHeight: 15px` | `fontAvatarExtraExtraSmallLineHeight` | 15 |
| `$width-avatar_extra_small: 24px` | `widthAvatarExtraSmall` | 24 |
| `$font-avatar_extra_small-size: 10px` | `fontAvatarExtraSmallSize` | 10 |
| `$font-avatar_extra_small-lineHeight: 15px` | `fontAvatarExtraSmallLineHeight` | 15 |
| `$width-avatar_small: 32px` | `widthAvatarSmall` | 32 |
| `$width-avatar_default: 40px` | `widthAvatarDefault` | 40（`size: 'default'` 档，枚举名 normal） |
| `$width-avatar_medium: 48px` | `widthAvatarMedium` | 48 |
| `$width-avatar_large: 72px` | `widthAvatarLarge` | 72 |
| `$width-avatar_extra_large: 128px` | `widthAvatarExtraLarge` | 128 |
| `$font-avatar_extra_large-size: 64px` | `fontAvatarExtraLargeSize` | 64 |
| `$font-avatar_extra_large-lineHeight: 77px` | `fontAvatarExtraLargeLineHeight` | 77 |
| `$radius-avatar: var(--semi-border-radius-circle)` | `radiusAvatar` | theme.radius.borderRadiusCircle（SemiLength 50%，按盒解析） |
| `$width-avatar_extra_large-border: 3px` | `widthAvatarExtraLargeBorder` | 3 |
| `$spacing-avatar_extra_large-marginLeft: -32px` | `spacingAvatarExtraLargeMarginLeft` | -32 |
| `$width-avatar_large-border: 3px` | `widthAvatarLargeBorder` | 3 |
| `$spacing-avatar_large-marginLeft: -18px` | `spacingAvatarLargeMarginLeft` | -18 |
| `$width-avatar_medium-border: 2px` | `widthAvatarMediumBorder` | 2 |
| `$spacing-avatar_medium-marginLeft: -12px` | `spacingAvatarMediumMarginLeft` | -12 |
| `$width-avatar_default-border: 2px` | `widthAvatarDefaultBorder` | 2 |
| `$spacing-avatar_default-marginLeft: -12px` | `spacingAvatarDefaultMarginLeft` | -12 |
| `$width-avatar_small-border: 2px` | `widthAvatarSmallBorder` | 2 |
| `$spacing-avatar_small-marginLeft: -12px` | `spacingAvatarSmallMarginLeft` | -12 |
| `$width-avatar_extra_small-border: 1px` | `widthAvatarExtraSmallBorder` | 1 |
| `$spacing-avatar_extra_small-marginLeft: -10px` | `spacingAvatarExtraSmallMarginLeft` | -10 |
| `$width-avatar_extra_extra_small-border: 1px` | `widthAvatarExtraExtraSmallBorder` | 1 |
| `$spacing-avatar_extra_extra_small-marginLeft: -4px` | `spacingAvatarExtraExtraSmallMarginLeft` | -4 |
| `$width-avatar-outline: 2px` | `widthAvatarOutline` | 2 |
| `$width-avatar_additional-border: 1.5px` | `widthAvatarAdditionalBorder` | 1.5 |
| `$color-avatar_additional-border: var(--semi-color-primary)` | `colorAvatarAdditionalBorder` | theme.colors.colorPrimary |
| `$spacing-avatar_additional-borderGap: 2px` | `spacingAvatarAdditionalBorderGap` | 2 |
| `$width-avatar-bottom_slot_circle_extra_small: 12px` | `widthAvatarBottomSlotCircleExtraSmall` | 12 |
| `$width-avatar-bottom_slot_circle_small: 12px` | `widthAvatarBottomSlotCircleSmall` | 12 |
| `$width-avatar-bottom_slot_circle_default: 16px` | `widthAvatarBottomSlotCircleDefault` | 16 |
| `$width-avatar-bottom_slot_circle_medium: 18px` | `widthAvatarBottomSlotCircleMedium` | 18 |
| `$width-avatar-bottom_slot_circle_large: 28px` | `widthAvatarBottomSlotCircleLarge` | 28 |
| `$width-avatar-bottom_slot_circle_extra_large: 28px` | `widthAvatarBottomSlotCircleExtraLarge` | 28 |
| `$color-avatar-bottom_slot_bg: var(--semi-color-primary)` | `colorAvatarBottomSlotBg` | theme.colors.colorPrimary |
| `$radius-avatar-bottom_slot_square: 4px` | `radiusAvatarBottomSlotSquare` | 4 |
| `$font-avatar_bottom_slot-extra_small-fontSize: 5px` | `fontAvatarBottomSlotExtraSmallFontSize` | 5 |
| `$font-avatar_bottom_slot-small-fontSize: 5px` | `fontAvatarBottomSlotSmallFontSize` | 5 |
| `$font-avatar_bottom_slot-default-fontSize: 12px` | `fontAvatarBottomSlotDefaultFontSize` | 12 |
| `$font-avatar_bottom_slot-medium-fontSize: 12px` | `fontAvatarBottomSlotMediumFontSize` | 12 |
| `$font-avatar_bottom_slot-large-fontSize: 12px` | `fontAvatarBottomSlotLargeFontSize` | 12 |
| `$font-avatar_bottom_slot-extra_large-fontSize: 14px` | `fontAvatarBottomSlotExtraLargeFontSize` | 14 |
| `$spacing-avatar-bottom_slot_square-paddingX: 4px` | `spacingAvatarBottomSlotSquarePaddingX` | 4 |
| `$spacing-avatar-bottom_slot_square-paddingY: 1px` | `spacingAvatarBottomSlotSquarePaddingY` | 1 |
| `$font-avatar_top_slot-small-fontSize: 5px` | `fontAvatarTopSlotSmallFontSize` | 5 |
| `$font-avatar_top_slot-default-fontSize: 6px` | `fontAvatarTopSlotDefaultFontSize` | 6 |
| `$font-avatar_top_slot-medium-fontSize: 8px` | `fontAvatarTopSlotMediumFontSize` | 8 |
| `$font-avatar_top_slot-large-fontSize: 14px` | `fontAvatarTopSlotLargeFontSize` | 14 |
| `$font-avatar_top_slot-extra_large-fontSize: 16px` | `fontAvatarTopSlotExtraLargeFontSize` | 16 |
| `$spacing-avatar-top_slot_small-content-marginTop: 0px` | `spacingAvatarTopSlotSmallContentMarginTop` | 0 |
| `$spacing-avatar-top_slot_default-content-marginTop: -2px` | `spacingAvatarTopSlotDefaultContentMarginTop` | -2 |
| `$spacing-avatar-top_slot_medium-content-marginTop: 0px` | `spacingAvatarTopSlotMediumContentMarginTop` | 0 |
| `$spacing-avatar-top_slot_large-content-marginTop: 0px` | `spacingAvatarTopSlotLargeContentMarginTop` | 0 |
| `$spacing-avatar-top_slot_extra_large-content-marginTop: 0px` | `spacingAvatarTopSlotExtraLargeContentMarginTop` | 0 |
| `$color-avatar-bottom_slot_square-border: var(--semi-color-bg-0)` | `colorAvatarBottomSlotSquareBorder` | theme.colors.colorBg0 |
| `$width-avatar-bottom_slot_square_extra_small-border: 2px` | `widthAvatarBottomSlotSquareExtraSmallBorder（上游未消费）` | 2（★事实死：类名拼写不匹配） |
| `$width-avatar-bottom_slot_square_small-border: 2px` | `widthAvatarBottomSlotSquareSmallBorder` | 2 |
| `$width-avatar-bottom_slot_square_default-border: 2px` | `widthAvatarBottomSlotSquareDefaultBorder` | 2 |
| `$width-avatar-bottom_slot_square_medium-border: 2px` | `widthAvatarBottomSlotSquareMediumBorder` | 2 |
| `$width-avatar-bottom_slot_square_large-border: 2px` | `widthAvatarBottomSlotSquareLargeBorder` | 2 |
| `$width-avatar-bottom_slot_square_extra_large-border: 2px` | `widthAvatarBottomSlotSquareExtraLargeBorder` | 2 |
| `$color-avatar-top_slot_text: var(--semi-color-bg-0)` | `colorAvatarTopSlotText` | theme.colors.colorBg0 |
| `$color-avatar-top_slot_gradient_start: var(--semi-color-primary)` | `colorAvatarTopSlotGradientStart` | theme.colors.colorPrimary |
| `$color-avatar-top_slot_gradient_end: var(--semi-color-primary)` | `colorAvatarTopSlotGradientEnd` | theme.colors.colorPrimary |
| `$spacing-avatar-top_slot_small-shift: -28px` | `spacingAvatarTopSlotSmallShift` | -28 |
| `$spacing-avatar-top_slot_default-shift: -32px` | `spacingAvatarTopSlotDefaultShift` | -32 |
| `$spacing-avatar-top_slot_medium-shift: -30px` | `spacingAvatarTopSlotMediumShift` | -30 |
| `$spacing-avatar-top_slot_large-shift: -30px` | `spacingAvatarTopSlotLargeShift` | -30 |
| `$spacing-avatar-top_slot_extra_large-shift: -32px` | `spacingAvatarTopSlotExtraLargeShift` | -32 |
| `$spacing-avatar-top_slot_small-scale: 0.4` | `spacingAvatarTopSlotSmallScale` | 0.4 |
| `$spacing-avatar-top_slot_default-scale: 0.7` | `spacingAvatarTopSlotDefaultScale` | 0.7 |
| `$spacing-avatar-top_slot_medium-scale: 0.8` | `spacingAvatarTopSlotMediumScale` | 0.8 |
| `$spacing-avatar-top_slot_large-scale: 1.1` | `spacingAvatarTopSlotLargeScale` | 1.1 |
| `$spacing-avatar-top_slot_extra_large-scale: 1.4` | `spacingAvatarTopSlotExtraLargeScale` | 1.4 |
| `$radius-avatar_extra_extra_small: 3px` | `radiusAvatarExtraExtraSmall` | 3 |
| `$radius-avatar_extra_small: 3px` | `radiusAvatarExtraSmall` | 3 |
| `$radius-avatar_small: 3px` | `radiusAvatarSmall` | 3 |
| `$radius-avatar_default: 3px` | `radiusAvatarDefault` | 3 |
| `$radius-avatar_medium: 3px` | `radiusAvatarMedium` | 3 |
| `$radius-avatar_large: 6px` | `radiusAvatarLarge` | 6 |
| `$radius-avatar_extra_large: 12px` | `radiusAvatarExtraLarge` | 12 |
| `$animation_duration-additionalBorder: 800ms` | `animationDurationAdditionalBorder` | const Duration(milliseconds: 800) |
| `$animation_duration-content: 1000ms` | `animationDurationContent` | const Duration(milliseconds: 1000) |
| `$animation_opacity-additionalBorder-start: 1` | `animationOpacityAdditionalBorderStart` | 1 |
| `$animation_opacity-additionalBorder-end: 0` | `animationOpacityAdditionalBorderEnd` | 0 |
| `$animation_width-additionalBorder-end: 0` | `animationWidthAdditionalBorderEnd` | 0 |
| `$animation_scale-additionalBorder-start: 1` | `animationScaleAdditionalBorderStart` | 1 |
| `$animation_scale-additionalBorder-end: 1.15` | `animationScaleAdditionalBorderEnd` | 1.15 |
| `$animation_scale-content-start: 1` | `animationScaleContentStart` | 1 |
| `$animation_scale-content-middle: 0.9` | `animationScaleContentMiddle` | 0.9 |
| `$animation_scale-content-end: 1` | `animationScaleContentEnd` | 1 |
### B. HARDCODES 另列（widget 文件头注释 / 调用点，源内含原始片段）

| 上游片段 | 说明 |
|---|---|
| mixin.scss:2 `background-color: rgba(var(--semi-#{$color}-3), 1)` | 16 色文字头像背景 = palette `{color}-3` |
| mixin.scss:3 `color: rgba(var(--semi-white), 1)` | 16 色文字头像白字 |
| avatar.scss:43 `font-size-regular` | label 基础字型（14/20） |
| avatar.scss:89 `font-size-small` | small 档 label（12/16） |
| avatar.scss:98 `font-size-header-5` | normal 档 label（18/24） |
| avatar.scss:107 `font-size-header-4` | medium 档 label（20/28） |
| avatar.scss:116 `font-size-header-1` | large 档 label（32/44） |
| avatar.scss:44 `font-weight: $font-weight-bold` | label 字重（fontWeightBold） |
| avatar.scss:58 `transform: scale(0.8)` | ★死 CSS：被行内 transform 覆盖 |
| avatar.scss:145 `object-fit: cover` | 图片铺满裁切 |
| index.tsx:35 `size: 'medium'` | 缺省尺寸（normal 之外默认 medium） |
| index.tsx:36 `color: 'grey'` | 缺省色 |
| index.tsx:37 `shape: 'circle'` | 缺省形状 |
| index.tsx:38 `gap: 3` | 缺省文字留白 |
| foundation.ts:57 `gap * 2 < nodeWidth` | 文字缩放判定 |
| avatar.scss:27 `outline: $width-avatar-outline solid` | focus 轮廓 |
| index.tsx:394 `role: 'listitem'` | 组内语义 |
| avatarGroup.tsx:92 `role='list'` | 组容器语义 |
| avatarGroup.tsx:65 `Number of remaining Avatars` | `+N` 语义标签 |
| avatar.scss:411 `z-index: $z-avatar-default - $i` | start 层序 |
| avatar.scss:414 `z-index: $z-avatar-default - 20 + $i` | end 层序（>21 项 auto quirk） |
| avatar.scss:367 `box-sizing: border-box` | 组描边画在盒内 |
| TopSlotSvg.tsx:12 `M40.4918 46.5592C` | 盾形路径（51×52 viewBox） |
| index.tsx:438 `"extra-small", "small", "default", "medium", "large", "extra-large"` | slot 渲染守卫 |
| avatar.scss:332 `shape_square-extra_small` | ★square slot 类名拼写 quirk（死规则） |
| avatar.scss:276 `translateY(50%)` | 底部 slot 骑底边 |
| avatar.scss:509 `animation: $animation_duration-additionalBorder linear infinite` | 呼吸描边 |
| avatar.scss:513 `animation: $animation_duration-content linear infinite` | 内容脉冲 |
| avatar.scss:438 `$width-avatar_additional-border - $spacing-avatar_additional-borderGap` | 环外扩偏移 |

## 差异清单

- **无浏览器/CSS 布局**：wrapper 的 fit-content/absolute 静态位推导换算为 Stack 定位；环与 bottom slot 溢出绘制（`clipBehavior: Clip.none`）。
- size 自由字符串 → `customSize`（double）；无尺寸类时 square 圆角 0、文字回落 `font-size-regular`（CSS 行为一致）。
- `transform: scale(0.8)`（xs）是死 CSS（行内覆盖），不复现；文字缩放由 FittedBox 完成。
- `&-image`/`-img`、`shape_square-extra_small`/`-extra-small` 两处类名拼写 quirk 照实留档；后者使 `widthAvatarBottomSlotSquareExtraSmallBorder` 成为死变量（上游未消费）。
- `srcSet`/`imgAttr`/`className`/`style` 直通属性、`onMouseEnter/Leave` 原始鼠标回调未移植（hoverMask 内部 MouseRegion 承担 hover）；`role`/`tabIndex` 换算为 Semantics/Focus 语义。
- 上游 `focusOnRoot`（外层传 tabIndex 时焦点落根）简化为：onTap 存在即可聚焦。
- 组层序换算 Stack 绘制序（等价 z-index 语义，>21 项 auto 层低于正 z 的 quirk 照抄）。
- TopSlotSvg 由 CustomPainter 复刻（路径/渐变/投影同参），非逐像素 SVG 渲染。
- 16 色背景实时读 `theme.palette.{color}3`；white 无样式类 quirk 照抄（透明底、文字随宿主）。

## 用法

```dart
SemiAvatar(
  src: AssetImage('assets/avatar.png'),
  alt: '用户头像',
  size: SemiAvatarSize.medium,
  onTap: () {},
)
SemiAvatar(text: 'AB', color: SemiAvatarColor.blue, shape: SemiAvatarShape.square)
SemiAvatar(
  text: 'AB',
  border: SemiAvatarBorder(motion: true),
  contentMotion: true,
  topSlot: SemiAvatarTopSlot(text: Text('新')),
  bottomSlot: SemiAvatarBottomSlot(text: Text('9')),
)
SemiAvatarGroup(
  maxCount: 3,
  children: [SemiAvatar(text: 'A'), SemiAvatar(text: 'B'), SemiAvatar(text: 'C')],
)
SemiTheme(
  data: SemiThemeData.light().copyWith(
    components: const SemiComponentThemes(
      avatar: SemiAvatarThemeData(widthAvatarMedium: 56),
    ),
  ),
  child: SemiAvatar(text: '主题'),
)
```
