# SemiRating

非 Material 评分。显示值 `hoverValue ?? value`，每星按 `clamp(display - i, 0, 1)` 比例裁切填充（支持任意小数：3.65 → 第 4 星裁 65%）。半星裁切用 item.tsx 双层复刻：底层字符全宽填未填色（colorRatingBgDefault），`ClipRect > Align(centerStart, widthFactor: 比例)` 盖上已填色字符（colorRatingIconDefault），centerStart 在 RTL 自动镜像（rtl.scss `-first{right:0}`）。字符默认 `SemiIcons.star`（尺寸档映射 SemiIconSize/customSize），可换 character。整组 inline 排布、星间距 6，hover 星 `scale(1.1)`（disabled 无缩放、无交互）。

## API

`SemiRating({key, value, defaultValue, count, allowHalf, allowClear, disabled, size, character, tooltips, onChanged, onHoverChange, onClick, autofocus, onFocusChange, semanticsLabel})`。

value double? 非空即受控（项目惯例）：渲染 value、只发事件；释放控制保留最后值（checkbox :145 同款）。defaultValue 0（非受控初值），count 5，allowHalf false（开启后命中/步进支持 0.5），allowClear true（同值点击清 0），disabled false。size: `SemiRatingSize.small | SemiRatingSize.normal | double`（Object 联合承载 + assert，SemiPinCode.format 先例；normal = 上游 `default`，double 为数字像素）。character Widget?（自定义字符/图标，null → `SemiIcons.star` 按尺寸档）。tooltips List<String>?（每星 hover 提示）。

onChanged: ValueChanged<double>?（每次值变化，受控也回调）。onHoverChange: ValueChanged<double?>?（hover 预览值；mouseleave 报 null）。onClick: `void Function(int index)?`（上游 `(e, index)` 去 event）。autofocus/onFocusChange 同 checkbox；semanticsLabel 覆盖计算标签（`Rating: v of n stars`）。

## 行为

### 半星裁切（显示）

`display = hoverValue ?? value`；第 i 星填充比例 = `clamp(display - i, 0, 1)`——任意小数按比例裁切（3.5→0.5、3.65→0.65）。裁切层 `ClipRect > Align(alignment: AlignmentDirectional.centerStart, widthFactor: 比例)` 盖全宽底层字符，RTL 由 centerStart 自动镜像到右侧锚定。字符双层各渲染一次（item.tsx `content` 两次同款）。

### hover

命中（getStarValue :68-84）：指针在星上的局部 x 对星宽中线——LTR 左半 = x.5、RTL 右半 = x.5；`display 值 = index + (整星 1 / 半 0.5)`。onHoverChange 同值不重复报；mouseleave（离开整组）→ hoverValue=null + onHoverChange(null)（同时复位 clearedValue）；**clearedValue 防抖**：allowClear 清 0 后 hover 到被清值不预览（:86-96），命中其他值即复位。hover 星 `scale(1.1)`（rating.scss:51，disabled 无缩放）。

### 清除（点击）

命中取 newValue；`newValue == 当前值 && allowClear` → 清 0（记 clearedValue、hover 预览复位并报 onHoverChange(null)）；否则落地（非受控）/只回调（受控）并复位 clearedValue（foundation.ts :98-109）。onClick(index) 恒报。

### 键盘

组件级 `Focus(onKeyEvent:)`（semi_input_number._handleKey 的 KeyDown/KeyRepeat 门，KeyRepeat 连击重复步进）：→/↑ +step、←/↓ -step（RTL 互换加减，semi_input_number.dart :1159 分支先例）；step = allowHalf ? 0.5 : 1；**0↔count 环绕**（`>count→0`、`<0→count`，0 按左跳满值）；立即 onChanged + hover 清除 + onHoverChange(null) + handled。**Enter = 点击语义**（命中即当前值「同值」，allowClear 清 0；allowClear=false 报同值）。无 Home/End。

### 焦点环

`_keyboardUsed` 门控（任意 KeyDown 置位、点按清位，checkbox 同款）：轮廓宽 widthRatingOutlineFocus、色 colorRatingOutlineFocus（BoxShadow spreadRadius 复刻 outline）；display=0 轮廓在容器上、否则在当前焦点星（`ceil(display)-1`）上。hover `scale(1.1)`（500ms 过渡，复刻 `transition: all 0.5s`）。

### tooltips

每星包 `SemiTooltip(trigger: SemiTooltipTrigger.custom, visible: hoverValue == index + 1)`（showArrow 默认 true）：**整星 hover 才显示**（源码 `showTips = hoverValue - 1 === ind` 语义），半星 hover 不显示；缺项按空串。

### disabled

点击/hover/键盘全 noop、无缩放、Semantics disabled、不可聚焦（canRequestFocus: false）。

## 主题（16 对账）

来源 packages/semi-foundation/rating/variables.scss（12 声明）与 animation.scss（4 声明），0 同名重复。对账 **16 = 12 FIELDS + 3 MOTION + 1 INTERNAL**（`$transform_scale-rating` 见 `_RatingMetrics`）。12 FIELDS 含 1 条死变量（标注「（上游未消费）」）：`$font-rating-fontSize`（rating.scss 仅注释行引用）。解析列即 `SemiRatingThemeData.resolve` 的默认表达式；`rgba(var(--semi-yellow-5), 1)` 走 `theme.palette.yellow5.toColor(1.0)`（亮色实值 rgb(250,200,0) == 0xfffac800，dark 主题随 palette 253,222,67）。

### A. Sass 声明映射（12 FIELDS + 3 MOTION + 1 INTERNAL = 16）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-rating-icon-default: rgba(var(--semi-yellow-5), 1)` | `colorRatingIconDefault` | `theme.palette.yellow5.toColor(1.0)` |
| `$color-rating-bg-default: var(--semi-color-fill-0)` | `colorRatingBgDefault` | `theme.colors.colorFill0` |
| `$color-rating-outline-focus: var(--semi-color-primary-light-active)` | `colorRatingOutlineFocus` | `theme.colors.colorPrimaryLightActive` |
| `$font-rating-fontSize: 20px` | `fontRatingFontSize` | `20（上游未消费）` |
| `$font-rating_item_small-fontSize: $width-rating_item_small` | `fontRatingItemSmallFontSize` | `16` |
| `$font-rating_item_default-fontSize: $width-rating_item_default` | `fontRatingItemDefaultFontSize` | `24` |
| `$spacing-rating-margin: 0px` | `spacingRatingMargin` | `0` |
| `$spacing-rating-padding: 0px` | `spacingRatingPadding` | `0` |
| `$spacing-rating_item-marginRight: 6px` | `spacingRatingItemMarginRight` | `6` |
| `$width-rating_item_small: 16px` | `widthRatingItemSmall` | `16` |
| `$width-rating_item_default: 24px` | `widthRatingItemDefault` | `24` |
| `$width-rating-outline-focus: 2px` | `widthRatingOutlineFocus` | `2` |
| `$transition_duration-rating-color: var(--semi-transition_duration-none)` | `transitionDurationRatingColor` | `Duration.zero` |
| `$transition_function-rating-color: var(--semi-transition_function-easeIn)` | `transitionFunctionRatingColor` | `Curves.easeIn` |
| `$transition_delay-rating-color: var(--semi-transition_delay-none)` | `transitionDelayRatingColor` | `Duration.zero` |
| `$transform_scale-rating: var(--semi-transform_scale-none)` | `_RatingMetrics.transformScaleRating`（INTERNAL） | `1`（scale(1,1) 恒等；rating.scss `$transform-scale-rating` 消费，Sass `-`/`_` 同字符） |

### B. widget 内部常量（INTERNAL/HARDCODES）

| 常量（`_RatingMetrics`） | 上游出处 / 结构 | 值或处理 |
|---|---|---|
| `transformScaleRating`（INTERNAL） | animation.scss `$transform_scale-rating: var(--semi-transform_scale-none)` | `1`（scale(1,1) 恒等，不加变换） |
| `starRadius` | rating.scss :16 根 / :80 `-wrapper` `border-radius: 3px` | 3（根容器与星盒圆角） |
| `hoverScale` | rating.scss :51 `transform: scale(1.1)` | 1.1（hover 放大；disabled 复位 none） |
| `hoverScaleTransition` | rating.scss :41 `transition: all 0.5s` | 500ms（hover 缩放过渡） |
| `firstDefaultWidthPercent` | rating.scss :96 `-first` `width: 50%` | 50（CSS 默认宽度，运行时被 item.tsx 内联 `width: firstWidth*100%` 覆盖；此处以 widthFactor 直接取比例） |
| `iconSizeTiers` | item.tsx:176 `const iconSize = isCustomSize ? 'inherit' : (size === 'small' ? 'default' : 'extra-large');` | small→`SemiIconSize.normal`（'default' 16）、normal→`SemiIconSize.extraLarge`（'extra-large' 24）、数字→customSize（'inherit' 即 li font-size = 像素值） |

## 差异清单

- **size 联合承载**：`Object`（SemiRatingSize | double，assert 校验，SemiPinCode.format 先例）；`SemiRatingSize.normal` = 上游 `default`（Dart 保留字不可作枚举名同 radio 惯例……此处直接用 normal）。
- **onClick 去 event**：上游 `(e, index)` → 仅 `index`（onKeyDown 事件对象同样不移植）。
- **roving tabindex 简化为单焦点节点**：上游每半星/整星各自 tabIndex 构成 radiogroup 焦点漫游，此处单 Focus 节点，焦点环位置由 display 推出（`ceil(display)-1`）；ref focus()/blur() 不移植（与 SemiCheckbox 同取舍）。
- **tooltips 整星才显**（源码语义 `hoverValue - 1 === ind`）：半星 hover 不显示 tooltip。
- **隐藏"空星"节点不移植**（上游 index === count 的 aria 专用零宽星）：value=0 语义用 Semantics 标签表达；id/tabIndex/aria-*/preventScroll 不移植。
- **清除判定的「当前显示值」取当前生效值 value**（hover 预览不参与比较，同上游 foundation.ts :102 `newValue === value`）：若以 hover 预览值比较则 hover 后每次点击都会清 0。
- **Enter 命中取当前值**（同值清 0）：上游 Enter 落在 DOM 焦点项上按整星取值——半星值会进位（3.5→4）、value=0 有 count+1 弊端，此处均不复刻，Enter 恒为「同值点击」语义。
- **任意小数裁切恒渲染**（clamp 比例）：上游仅 allowHalf 时渲染 `-first` 裁切层，非 allowHalf 下 3.65 显示为 3 整星；本移植按契约统一按比例裁切（tooltips/hit 的半值仍由 allowHalf 门控）。
- **键盘/清 0 的 hover 复位同报 onHoverChange(null)**（上游 notifyHoverChange 恒回调语义）。

```dart
SemiRating(
  value: rating,                 // double? 非空即受控
  count: 5,
  allowHalf: true,               // 命中/步进支持 0.5
  size: SemiRatingSize.small,    // 或 double 30（数字像素）
  tooltips: const ['terrible', 'bad', 'normal', 'good', 'wonderful'],
  onChanged: (v) => setState(() => rating = v),
  onHoverChange: (v) => print(v), // null = mouseleave
  onClick: (index) => print(index),
);
// 自定义字符：character: const Icon(Icons.favorite)（字色随 colorRatingIconDefault/BgDefault）
// 局部主题：SemiRatingTheme(data: const SemiRatingThemeData(widthRatingItemSmall: 18), child: ...)
```
