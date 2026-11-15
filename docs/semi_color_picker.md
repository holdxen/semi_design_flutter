# SemiColorPicker

非 Material 取色器（上游 Semi ColorPicker 全件移植）：SV 明度/饱和度面板 + 色相滑条 + 可选透明度滑条 + 数据区（色块 + 文本输入 + 可选 `%` 数字输入 + 格式 Select + 取色器按钮）。值模型 `SemiColorValue = {h, s, v, a}`（h 0-360、s/v 0-100、a 0-1）附**计算**通道：`r/g/b`（整数，`hsvaToRgba` 四舍五入）、`hex`（小写 `#rrggbb`，★仅 `a < 1` 时为 8 位 `#rrggbbaa`）、`rgbaAlpha`（= `round(a, 2)`，`hsvaToRgba` 的 rgba alpha 语义）、`color`（CSS `rgba(r, g, b, a)` 等价 Color）。`value`/`defaultValue: SemiColorValue?` **非空即受控**（项目惯例；★上游是 truthiness 判定 `if (!this.getProp('value'))`），`onChanged(SemiColorValue)` 携带完整三元等价值（上游 `{hsva, rgba, hex}` triple 折叠为单一 quadruple——见差异清单）。非受控种子 `defaultValue`，默认 Semi 品牌值 `SemiColorValue(h: 176, s: 71, v: 77, a: 1)`（`#39c5bb`）；释放控制保留最后受控值（semi_rating.dart:122-129 同款）。

字符串解析有两层（SemiColorValue 静态方法）：`parse`/`tryParse` 移植 `ColorPicker.colorStringToValue`（index.tsx:74-107，startsWith 次序 `#…`/`rgba…`/`rgb…`/`hsv…`，其他抛 `ArgumentError`；★hex 分支**宽松**——`hexToRgba` 不校验，3 位简写不抛错、缺 alpha 视为 1、垃圾分量在 Dart 侧坍缩为 0）；`tryParseInput(raw, format:)` 移植 DataPart 输入解析（DataPartFoundation.getValueByInputValue + utils/split.ts，★String-regex 规则：hex 自动补 `#` 后按**非锚定** `#[\d\w]{6,8}` 判定——3/4 位简写拒绝、9 位连串反而通过；逗号三元组 `r,g,b[,a]`/`h,s,v[,a]` 按 format 越界即拒（不 clamp，缺第 4 位 a=1）；★hsva 色相 >360 拒绝）。`rgb`/`hsv` 字符串分支走 vanilla-colorful 正则（含 grad/turn/rad 角度单位；不匹配落零值 `{0,0,0,1}` 上下文）。

## API

`SemiColorPicker({key, value, defaultValue, alpha, width, height, defaultFormat, usePopover, child, position, autoAdjustOverflow, motion, eyeDropper, onEyeDropper, onChanged, onOpenChange, topSlot, bottomSlot})`。

value `SemiColorValue?` 非空即受控；defaultValue `SemiColorValue?` 非受控种子（默认品牌值）。alpha false（渲染透明度滑条与 `%` 输入；★false 时每次提交强制 `a = 1` / 6 位 hex——见行为）。width 280（SV/滑条/数据区共宽）、height 280（SV 区高）。defaultFormat `SemiColorFormat.hex`（hex|rgba|hsva，格式 Select 的初值与选项集——labels = values）。usePopover false（true 时面板挂 hover 弹层，`SemiTooltip(trigger: hover, showArrow: false, popupBare: true, position, autoAdjustOverflow, motion)`，内容自绘 Popover 表面——bg-3 底 + 1px border + radius-medium + shadow-elevated 双影——内包 `spacingColorPickerPopoverPadding` 8px 内边距）；child `Widget?` 弹层触发器（null 渲染默认 24×24 色块——`width-colorPicker-defaultTrigger` + `radiusColorPickerDefaultTrigger`，背景 = 当前 hex）。position `SemiTooltipPosition.bottom`（上游 Popover 默认）、autoAdjustOverflow true、motion true。eyeDropper true（★仅当 `onEyeDropper` 也存在时才渲染取色按钮——上游 `window.EyeDropper` 门的移植）。onEyeDropper `Future<Object?>? Function()?` 取色器宿主桥（WICG EyeDropper 无 Flutter 通道，差异清单）：返回 hex/`rgba(…)` 字符串或 `SemiColorValue`。onChanged `ValueChanged<SemiColorValue>?`。onOpenChange `ValueChanged<bool>?`（弹层开合）。topSlot/bottomSlot `Widget?` 面板内容上下插槽。静态 key：`svAreaKey`/`hueSliderKey`/`alphaSliderKey`/`swatchKey`/`triggerSwatchKey`/`colorInputKey`/`alphaInputKey`/`formatSelectKey`/`eyeDropperButtonKey`。

回调语义：每次交互（SV/色相/透明度拖拽、文本输入合法提交、`%` 输入、取色器结果）发一次 `onChanged`（拖拽逐 move 上报，无去重——上游 mousemove 逐发）。

## 行为

### SV 明度/饱和度面板（ColorChooseArea）

底色 `hsl(h, 100%, 50%)`（纯色相），叠加 vanilla-colorful saturation.css 双渐变（★`background-image: linear-gradient(to top, #000, rgba(0, 0, 0, 0)), linear-gradient(to right, #fff, rgba(255, 255, 255, 0));`——CSS 首层在上，Flutter Stack 反序承载）+ ★`box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.05);`（无 inset shadow 对应——1px 内描边等效）。把手 20px 圆（`handleSize={20}`），背景 = 当前 `rgba(r, g, b, a)`、边框 2px 白（`width-colorPickerHandleBorder` + `colorColorPickerHandleBorder`）、圆角 `radiusColorPickerHandle`；位置 `x = s/100×宽 − 10`、`y = (1 − v/100)×高 − 10`（把手可溢出面板，Stack `clipBehavior: Clip.none`）。原始 Listener 拖拽（slider 先例，指针捕获使拖拽延续到面板外——上游 mousemove 挂 area 本身、mouseup 挂 window，净效果同）：按下即重定位（上游把手 mousedown 冒泡到 area 的 `handleClick` 同款）；★越界位置**拒绝**（`getHandlePositionByMousePosition` 返回 null，无任何变化——不 clamp）；`s = round(x/宽×100)`、`v = round(100 − clamp(y/高, 0, 1)×100)`。语义 `aria-label="Color"` + `aria-valuetext="Saturation x%, Brightness y%"`（原样移植）。

### 色相滑条（ColorSlider）

轨道 10px 高（`height={10}`）圆角 `radiusColorPickerHandle`，底为彩虹渐变（★`linear-gradient(to right, #f00 0%, #ff0 17%, #0f0 33%, #0ff 50%, #00f 67%, #f0f 83%, #f00 100%)`）。把手 18px（`handleSize={18}`）色 `hsl(h, 100%, 50%)` + 2px 白边，垂直居中（溢出轨道 4px）。拖拽：★`h = round(clamp(x/宽, 0, 1) × 360)`——clamp 不拒绝，**右缘得 360**（不回卷 0）。

### 透明度滑条（AlphaSlider，仅 alpha）

轨道 10px：★棋盘格 data-URI（`url('data:image/svg+xml,<svg … width="16" height="16" fill-opacity=".05">…</svg>')`）移植为 16px 平铺 CustomPaint（每格两枚 8×8 黑方块、fill-opacity .05），上叠 `-alphaSliderInner` 渐变 `hsla(h,s,l,0) → hsla(h,s,l,1)`（圆角 `radiusColorPickerAlphaSliderInner`）。把手 18px 背景 `hsvaToRgbaString` + 2px 白边，★棋盘格 `background: url(…)` 在 inline backgroundColor **之上**（半透明把手透出轨道）。拖拽：★`a = clamp(x/宽, 0, 1).toFixed(2)`（2 位小数）。语义 `aria-label="Alpha"` + `aria-valuetext="x%"`。

### handleChangeA 语义（★alpha=false 强制不透明）

上游 handleChangeA 首行 `if (!alpha) newAlpha = 1`，产出 `hex: alpha ? hex : hex.slice(0, 7)`。但 alpha slider 与 `%` 输入只在 alpha=true 时渲染——该分支上游实为死代码。契约项 7 要求该行为可观测，本移植将其提升为**提交级归一**：`alpha == false` 时**每次提交**（拖拽/输入/取色器）强制 `a = 1`、hex 恒 6 位（slice(0,7) 规则被 a=1 的 6 位输出吸收）。alpha 显示 = `round(a×100)`（小输入 + `%` 后缀，min 0 max 100，SemiInputNumber `hideButtons` + `%` 后缀槽——后缀字号 `fontColorPickerInputNumberSuffixFontSize`、内边距 `spacingColorPicker_inputNumberSuffix-*`）；修改走 DataPart 的 format 分支：`a = (v/100).toFixed(2)`，★hex 格式下值经 `rgbaToHex` 往返（`percentToHex` 量化到 k/255：输入 25 → `#ff000040` → a = 64/255），rgba/hsva 格式直传（hsva 格式保留 h/s/v 原值）。

### 数据区（DataPart）

`margin-top: 8`（`spacing-colorPicker_dataPart-marginTop`）行布局：20×20 色块（`minWidth: 20, minHeight: 20`，背景 `rgba(r,g,b,a)`、圆角 `radiusColorPickerDemoBlock`）+ `marginLeft 4`（`spacing-colorPicker_inputGroup-marginLeft`）+ 输入组（文本输入 flex + alpha `%` 数字 58px（`width-colorPicker-colorPickerInputNumber`）+ 格式 Select 80px（`width-colorPicker-formatSelect`））+ 取色按钮（tertiary/light/small + `SemiIcons.eyedropper`）。文本输入（SemiInput small）显示 ★**恒去 alpha**：hex → `hex.slice(0, 7)`（7 字符）、rgba → `r,g,b`、hsva → `h,s,v`（JS 数字字面量格式，整数无 `.0`）；alpha 只存在于 `%` 栏。改动即解析（`tryParseInput`）：合法 → 发 `onChanged`，★非法**保留用户原文**（不回退）且不发事件；文本仅在**值深层变化**或**格式切换**时从值重同步（lodash isEqual 语义——受控方回吐等值时用户原文保留）。格式 Select（SemiSelect small，选项恰 `hex|rgba|hsva`，labels = values）切换显示与解析口径。

### 取色器（eyeDropper + onEyeDropper）

按钮仅当 `eyeDropper && onEyeDropper != null` 渲染。结果处理（DataPartFoundation.handlePickValueWithStraw）：`SemiColorValue` 直用；`#…` 字符串走宽松 hex 转换；★`rgba(…)` 字符串**强制 `a = 1`**；其他（含 hsv 字符串）与解析失败一律**静默忽略**（上游 try/catch 吞错）。

### usePopover 与插槽

`usePopover: true`：面板挂 SemiTooltip hover 弹层（showArrow false、popupBare、position/autoAdjustOverflow/motion 透传）。★popupBare 不带表面，白底由本移植自绘（上游是 Popover 组件皮肤）：`$color-popover-bg-default`(bg-3) + 1px `$color-popover-border-default`(border) + `$radius-popover`(radius-medium) + shadow-elevated 双影（popover.scss/global.scss，semi_select.dart `_buildPanel` 同方），内容再包 `spacingColorPickerPopoverPadding` 8px 内边距。触发器 `child ?? 默认 24×24 色块`（背景 = 当前 hex），`onOpenChange(bool)` 报开合。inline（默认）直接渲染面板（无表面——上游内联形态同样无 Popover 包装）。topSlot/bottomSlot 包裹面板控件上下（上游 `topSlot`/`bottomSlot`）。

### 几何

width 贯穿 SV/两条滑条/数据区（上游 `width ?? 280`），height 仅 SV 区（`height ?? 280`）；滑条上边距 6（`spacing-colorPicker_slider-marginTop`）、数据区上边距 8（`spacing-colorPicker_dataPart-marginTop`）。

### 光标映射

SV 面板 pointer（拖拽 grabbing，index.tsx:99）、把手 grab（grabbing 按下，colorPicker.scss:28）、两条滑条 pointer（:63/:36）、把手同前；各自 MouseRegion 就近承载（tag_input 光标图先例）。

### 键盘 / RTL / 语义

★上游无键盘支持（仅 SemiInput/SemiSelect/SemiInputNumber 自带交互）；★无 RTL（色标/滑条数学全 LTR，上游无 colorPicker rtl.scss；note）；无 Form 集成。语义：SV `label: 'Color'` + Saturation/Brightness valuetext、Alpha `label: 'Alpha'` + 百分比 valuetext（原样移植）。

## 主题（20 对账）

来源 packages/semi-foundation/colorPicker/variables.scss（20 声明行 / 20 唯一名——radius 8、width 4、color 1、spacing 6、font 1；无重复、无死变量）；**无 animation.scss**。对账 **20 = 20 FIELDS + 0 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表）。全局 token 解析：`var(--semi-border-radius-full)` → `theme.radius.borderRadiusFull.value`（9999）、`var(--semi-color-white)` → `const Color(0xffffffff)`（字面量白，switch `COLOR_LITERALS` 先例）。解析列即 `SemiColorPickerThemeData.resolve` 默认表达式。

### A. Sass 声明映射（20 FIELDS）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$radius-colorPicker-topLeft: 8px` | `radiusColorPickerTopLeft` | `8` |
| `$radius-colorPicker-topRight: 8px` | `radiusColorPickerTopRight` | `8` |
| `$radius-colorPicker-bottomLeft: 0px` | `radiusColorPickerBottomLeft` | `0` |
| `$radius-colorPicker-bottomRight: 0px` | `radiusColorPickerBottomRight` | `0` |
| `$radius-colorPicker-handle: var(--semi-border-radius-full)` | `radiusColorPickerHandle` | `theme.radius.borderRadiusFull.value`（9999） |
| `$radius-colorPicker-alphaSliderInner: 4px` | `radiusColorPickerAlphaSliderInner` | `4` |
| `$radius-colorPicker-demoBlock: 4px` | `radiusColorPickerDemoBlock` | `4` |
| `$radius-colorPicker-defaultTrigger: 4px` | `radiusColorPickerDefaultTrigger` | `4` |
| `$width-colorPicker_handle-border: 2px` | `widthColorPickerHandleBorder` | `2` |
| `$width-colorPicker-colorPickerInputNumber: 58px` | `widthColorPickerColorPickerInputNumber` | `58` |
| `$width-colorPicker-formatSelect: 80px` | `widthColorPickerFormatSelect` | `80` |
| `$width-colorPicker-defaultTrigger: 24px` | `widthColorPickerDefaultTrigger` | `24`（默认触发色块边长） |
| `$color-colorPicker_handle-border: var(--semi-color-white)` | `colorColorPickerHandleBorder` | `const Color(0xffffffff)` |
| `$spacing-colorPicker_inputNumberSuffix-horizontal: 4px` | `spacingColorPickerInputNumberSuffixHorizontal` | `4` |
| `$spacing-colorPicker_inputGroup-marginLeft: 4px` | `spacingColorPickerInputGroupMarginLeft` | `4` |
| `$spacing-colorPicker_popover-padding: 8px` | `spacingColorPickerPopoverPadding` | `8`（仅 usePopover 内容内边距） |
| `$spacing-colorPicker_inputNumberSuffix-vertical: 4px` | `spacingColorPickerInputNumberSuffixVertical` | `4` |
| `$spacing-colorPicker_slider-marginTop: 6px` | `spacingColorPickerSliderMarginTop` | `6` |
| `$spacing-colorPicker_dataPart-marginTop: 8px` | `spacingColorPickerDataPartMarginTop` | `8` |
| `$font-colorPicker_inputNumberSuffix-fontSize: 14px` | `fontColorPickerInputNumberSuffixFontSize` | `14` |

### B. HARDCODES 另列（`_ColorPickerMetrics` / 调用点，widget 源内含原始片段）

| 上游片段 | 落点 |
|---|---|
| `background-image: linear-gradient(to top, #000, rgba(0, 0, 0, 0)), linear-gradient(to right, #fff, rgba(255, 255, 255, 0));` | SV 双渐变叠层（colorPicker.scss:19，vanilla-colorful saturation.css） |
| `box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.05);` | SV 内圈 1px 描边（colorPicker.scss:14） |
| `url('data:image/svg+xml,<svg … fill-opacity=".05">…</svg>')` | 16px 棋盘格 CustomPaint（:39/:49，轨道 + alpha 把手） |
| `linear-gradient(to right, #f00 0%, #ff0 17%, #0f0 33%, #0ff 50%, #00f 67%, #f0f 83%, #f00 100%)` | 色相轨道（:65） |
| `height={10}` / `handleSize={18}` / `handleSize={20}` | 滑条高 10 / 滑条把手 18 / SV 把手 20（index.tsx:123-134 硬编码） |
| `minWidth: 20, minHeight: 20` | 20×20 色块（DataPart/index.tsx:68） |
| `}>%</span>` | `%` 后缀槽（DataPart/index.tsx:101） |
| `padStart(2, '0').toLowerCase()` | `rgbaToHex` 小写规则（convert.ts:182） |
| 2px 把手白边 | `widthColorPickerHandleBorder` + `colorColorPickerHandleBorder`（B 表锚点，值走主题） |
| Popover 表面皮肤（bg-3 底 + 1px border + radius-medium + `@include shadow-elevated` 双影） | usePopover 弹层白底（popover.scss `$color-popover-*` + global.scss shadow-elevated mixin；popupBare 无表面故自绘，semi_select.dart `_buildPanel` 同方） |

## 差异清单

1. **值模型折叠**：上游 `ColorValue` 存 `{hsva, rgba, hex}` 三份（hex 保留输入原文、rgba/hsva 的 alpha 可按路径分叉）；本移植折叠为 `SemiColorValue{h,s,v,a}` + 计算通道（r/g/b = `hsvaToRgba` 取整、hex = `rgbaToHex` 规范输出）。后果：①★hex 恒小写规范形（用户输入的 `#AABBCC` 重同步后变 `#aabbcc`，上游保留原文）；②★RGB↔HSV 整数取整有损，(57,197,187)（`#39c5bb`）回程得 g=196（`#39c4bb`）——默认品牌值 `SemiColorValue(h: 176, s: 71, v: 77, a: 1)` 是 `#39c5bb` 的取整 hsva（`parse('#39c5bb')` 与默认值相等），但计算 hex 为 `#39c4bb`；③rgba/hsva 逗号输入 >2 位小数的 alpha：上游 hsva 路径的 rgba.a 先 `round(a, 2)` 再入 hex、rgba 路径不取整——本移植统一按 `rgbaAlpha = round(a, 2)` 进 hex/色块/% 显示（1/255 级误差）。
2. **NaN 坍缩**：★`hexToRgba` 上游对垃圾分量产出 NaN（如 3 位简写）；Dart 数值管线不容 NaN，解析边界坍缩为 0（宽松性保留：不抛错、缺 alpha=1）。
3. **alpha=false 归一位置**：★上游 handleChangeA 的 `!alpha → a=1` 在 alpha=false 时不可达（UI 隐藏），本移植提升为提交级归一（契约项 7）。
4. **eyeDropper 宿主桥**：WICG EyeDropper 无 Flutter 通道 → `onEyeDropper: Future<Object?>? Function()?` 回调桥（返回 hex/`rgba(…)` 字符串或 `SemiColorValue`）；★rgba 结果强制 a=1、失败/hsv/垃圾静默忽略（上游 try/catch）。
5. **格式 Select 用 SemiSelect**（nested overlay 的 SemiOverlayPointerExempt 机制覆盖）；上游 `optionList` → `options: SemiSelectOption(value: name)`（labels = values）。
6. **`%` 输入用 SemiInputNumber**（`hideButtons: true` + `%` 后缀槽）对位上游 `InputNumber hideButtons` + suffix span；宽度 58px 走主题字段。
7. **InputGroup 连体边框未移植**：上游输入组（Input + InputNumber + Select）有 InputGroup 连接样式，本移植为普通 Row（各控件自带边框）。
8. **`className`/`style`/`inputProps`/`popoverProps` 不移植**（粒度裁剪）：`position`/`autoAdjustOverflow`/`motion` 直接参数化；弹层无 `repositionKey`（hover 弹层尺寸恒定）。★弹层白底：上游由 Popover 组件自带表面渲染，本移植 popupBare 模式自绘同款皮肤（B 表末行）。
9. **把手位置微差**：受控不回吐时上游把手停在原始指针点（未量化），本移植统一停在量化值点（≤1px）；无视觉可感差异。
10. **无键盘/RTL/Form**：上游即无（仅 SemiInput/SemiSelect/SemiInputNumber 自带）；滑条数学 LTR-only，RTL 未适配（note）。
