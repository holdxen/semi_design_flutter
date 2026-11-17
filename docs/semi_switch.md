# SemiSwitch

非 Material 开关。几何完全按 switch.scss：track 默认 40×24（radius 12）、large 54×32（radius 16）、small 26×16（radius 8）；knob 默认 18×18（radius 9 = knob/2，top 2，translateX 未选 2 / 选中 18）、large 24×24（radius 12，top 3，3/26）、small 12×12（radius 6，top 1，1/11）——★`$width-switch_knob_large_small` 照抄上游命名，实际是**小**尺寸滑块宽。按下 knob 只延展宽度（24/34/14，高度与圆角不变），选中态位移回撤（18→12 / 26→16 / 11→9）。加载态 knob 槽渲染 SemiSpin（视觉尺寸 18/10/28，`width-switch_spin-*`）。tap/Space 切换、★Enter 不切换（原生 checkbox 语义）；disabled 或 loading 全屏蔽（不可聚焦、不响应）。hover 仅在非 disabled 非 loading 时加深（switch.scss:102-106 反向规则净效果）。文案 checkedText 在起始侧、uncheckedText 在末尾侧、互斥、small 不渲染。焦点环走 `:focus-visible` 门控（键盘用键后才画，鼠标点击不画）。RTL 位移取反、文案换侧。

## API

`SemiSwitch({key, checked, defaultChecked, disabled, loading, size, checkedText, uncheckedText, onChanged, onBlur, onMouseEnter, onMouseLeave, autofocus})`。

checked `bool?` 非空即受控（项目惯例）：渲染 checked、只发事件；释放控制（checked 回 null）保留最后受控值（semi_rating.dart:122-129 同款），进入控制保留内部态。defaultChecked `bool`（false，非受控初值）。disabled false、loading false。size `SemiSwitchSize { small, normal, large }`（上游 `'small' | 'default' | 'large'`，normal 对应 default，默认 normal）。checkedText / uncheckedText `Object?`（String | Widget，`_asWidget` 先例；small 一律不渲染）。

onChanged `ValueChanged<bool>?`——每次实际切换必报（无 diff gate，foundation.ts:30-38）；受控只回调不落地。onBlur `VoidCallback?`（先清焦点环再回调，index.tsx:126-129）。onMouseEnter / onMouseLeave `VoidCallback?`（照上游挂在根上，disabled 也报）。autofocus false。静态 `SemiSwitch.trackKey` 供测试定位。

## 行为

### 切换（tap / Space；★Enter 不切换）

tap 或 **Space** 切换（KeyDown/KeyRepeat）。★**Enter 不切换**——上游是原生 checkbox（`type="checkbox"`），Space 切换、Enter 提交表单不切换，照搬。非受控：状态落地 + onChanged(next)；受控：只 onChanged(next)、显示跟随 checked。disabled 或 loading：tap/Space 均无事、不可聚焦（`canRequestFocus` 关闭）。

### 受控 / 非受控

`checked != null` 即受控（foundation.ts:32 `isControlledComponent`）：渲染 `checked`、切换只通知（handleChange 受控分支）。非受控种子 `_state = defaultChecked` 并落地切换。★上游 constructor `defaultChecked || checked` 真值初始化 quirk 不移植（index.tsx:79，差异清单）。didUpdateWidget 同 rating 惯例：释放控制保留最后受控值。

### disabled / loading

disabled 或 loading 全屏蔽（tap/Space 无事、不可聚焦、按下无视觉）。视觉（switch.scss:60-106、160-234）：

- 未选中 disabled：track 背 `colorSwitchDisabledBgDefault`（透明）、描边 `colorSwitchDisabledBorderDefault`（--semi-color-border）；knob 1px（`widthSwitchKnobDisabledBorder`）描边 `colorSwitchKnobBorderDefault` + 无阴影（`shadow-0`）。
- 选中 + disabled：track 背 `colorSwitchCheckedDisabledBgDefault`（--semi-color-success-disabled）、描边 `colorSwitchCheckedDisabledBorderDefault`（透明）、knob 无描边 + 无阴影。
- loading：knob 槽换 SemiSpin（index.tsx:153-157，size 映射 normal→middle / small→small / large→large，图标视觉尺寸 `width-switch_spin-*`、色 `colorSwitchLoadingSpinDefault`）；track 背未选 `colorSwitchSpinUncheckedBgDefault`（fill-1）/ 选中 `colorSwitchSpinCheckedBgDefault`（success-hover）；★disabled+loading+选中仍取 success-disabled（switch.scss:232 压过 :186 的级联净效果）。
- ★hover 不加深：disabled+loading 的 hover 反向规则（switch.scss:102-106）净效果等于 loading 本色——hover 色仅在 `!disabled && !loading` 时生效。

### 悬停

MouseRegion 悬停：未选 track `colorSwitchDefaultBgHover`（fill-1）、选中 `colorSwitchCheckedBgHover`（success-hover）；★仅可交互时生效（见上）。onMouseEnter/onMouseLeave 回调照上游无条件报。

### 按下（:active）

按下（指针 down，仅可交互）：knob 延展到 `widthSwitchKnobActive`/`large`/`small`（24/34/14，高度不变、radius 保持基础值 9/12/6）——宽度走 200ms 过渡；选中按下位移回撤 `spacingSwitchCheckedTranslateX - widthSwitchKnobExpand`（18→12）、large 26→16（`spacingSwitchExpandLargeTranslateX`）、small 11→9（`spacingSwitchExpandSmallTranslateX`）；track 描边变 `colorSwitchDefaultBgActive`（fill-2，基础 `&:active` 规则，checked 同样适用）。★checked-pressed track **背景**保持 success（`$color-switch_checked-bg-active` 上游未消费，`&-active` 块从未挂类）。

### 文案

checkedText 仅 checked 时渲染、在方向起始侧（LTR 左 / RTL 右）；uncheckedText 仅 unchecked 时渲染、在方向末尾侧（LTR 右 / RTL 左）——互斥、small 一律不渲染（index.tsx:149-150）。盒宽默认 20px（switch.scss:147 硬编码）、large `widthSwitchCheckedUncheckedText`（26），高 100%、内容 `all-center` 居中；字号 `theme.typography.fontSizeSmall`（默认，`$font-size-small: 12px`）/ `fontSizeRegular`（large，`$font-size-regular: 14px`）；色 `colorSwitchCheckedTextDefault`（白）/ `colorSwitchUncheckedTextDefault`（text-2）。String 渲染成带样式的 Text，Widget 走 DefaultTextStyle 继承。

### 焦点环与 onBlur

`&-focus` 轮廓：`widthSwitchOutline`（2px）+ `colorSwitchPrimaryOutlineFocus`（--semi-color-primary-light-active），★`:focus-visible` 语义——仅键盘交互后聚焦才画（`_keyboardUsed` 门控先例，任意 KeyDown 置位），鼠标点击聚焦/点击清位不画。onBlur：先清环再回调（index.tsx:126-129 `foundation.handleBlur()` → `props.onBlur`）。

### RTL

knob 位移取反（未选 -2 / 选中 -18 等，rtl.scss:10-24，按末尾侧锚定镜像）；loading spin 位移取反（rtl.scss:35-68）；文案换侧（checked 到末尾侧视觉右→方向起始，见行为文案节的方向语义）。track/几何不变。

### 语义

`Semantics(container: true, toggled: checked, enabled: !disabled)`——★`enabled` 照上游 `aria-disabled={disabled}` quirk（index.tsx:179）只看 disabled，loading 不反映。

## 主题（66 对账）

来源 packages/semi-foundation/switch/variables.scss（64 声明行 / 63 唯一名——唯一重复：`$color-switch_disabled-bg-hover` 在第 27、30 行各声明一次，同值 `transparent`，Sass last-wins 无净效果）与 animation.scss（3 声明），合计 **67 声明行 / 66 唯一名**。对账 **66 = 63 FIELDS + 3 MOTION + 0 INTERNAL**（switch 的 animation.scss 无 transform token，故 INTERNAL=0；HARDCODES 另列见 B 表）。63 FIELDS 含 1 条事实死变量（标注「（上游未消费）」）：`$color-switch_checked-bg-active`——保留 theme 字段但 widget 不消费（净效果一致）。3 条视觉无效果（标注「（视觉无效果）」）：`$color-switch_disabled-bg-default` / `-bg-hover`（重复对）/ `-bg-active`。quirk：`$width-switch_knob_large_small` 实为小尺寸滑块宽（照抄命名）；`$motion-switch-transitionDuration` 是 Duration 型 FIELDS（位于 variables.scss 而非 animation.scss）；switch.scss:17 引用 `$transition_delay_switch-bg` 与声明 `$transition_delay-switch-bg` 连/下划线不同（Sass `-`/`_` 同字符）——计声明不计引用。解析列即 `SemiSwitchThemeData.resolve` 的默认表达式；`rgba(var(--semi-white), 1)` / `var(--semi-color-white)` / `transparent` 走字面量。

### A. Sass 声明映射（63 FIELDS + 3 MOTION = 66）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-switch_default-bg-default: var(--semi-color-fill-0)` | `colorSwitchDefaultBgDefault` | `theme.colors.colorFill0` |
| `$color-switch_default-bg-hover: var(--semi-color-fill-1)` | `colorSwitchDefaultBgHover` | `theme.colors.colorFill1` |
| `$color-switch_default-bg-active: var(--semi-color-fill-2)` | `colorSwitchDefaultBgActive` | `theme.colors.colorFill2` |
| `$color-switch_default-border-default: transparent` | `colorSwitchDefaultBorderDefault` | `const Color(0x00000000)` |
| `$color-switch_checked-bg-default: var(--semi-color-success)` | `colorSwitchCheckedBgDefault` | `theme.colors.colorSuccess` |
| `$color-switch_checked-bg-hover: var(--semi-color-success-hover)` | `colorSwitchCheckedBgHover` | `theme.colors.colorSuccessHover` |
| `$color-switch_checked-bg-active: var(--semi-color-success-active)` | `colorSwitchCheckedBgActive` | `theme.colors.colorSuccessActive`（（上游未消费）唯一消费者是 switch.scss:56-58 的 `&-active` 块，`semi-switch-active` 类 TSX 从不挂载——checked-pressed 背景保持 success；widget 不消费本字段） |
| `$color-switch_disabled-bg-default: transparent` | `colorSwitchDisabledBgDefault` | `const Color(0x00000000)`（（视觉无效果）disabled track 本就透明，widget 消费为 disabled 未选中背景） |
| `$color-switch_disabled-bg-hover: transparent` | `colorSwitchDisabledBgHover` | `const Color(0x00000000)`（（视觉无效果）★唯一重复声明（variables.scss 行 27/30 同值，Sass last-wins）；hover 对 disabled 按契约关闭，widget 不消费本字段） |
| `$color-switch_disabled-bg-active: transparent` | `colorSwitchDisabledBgActive` | `const Color(0x00000000)`（（视觉无效果）按下视觉对 disabled 按契约关闭，widget 不消费本字段） |
| `$color-switch_disabled-border-default: var(--semi-color-border)` | `colorSwitchDisabledBorderDefault` | `theme.colors.colorBorder` |
| `$color-switch_checked_disabled-bg-default: var(--semi-color-success-disabled)` | `colorSwitchCheckedDisabledBgDefault` | `theme.colors.colorSuccessDisabled` |
| `$color-switch_checked_disabled-border-default: transparent` | `colorSwitchCheckedDisabledBorderDefault` | `const Color(0x00000000)` |
| `$color-switch_knob-bg-default: rgba(var(--semi-white), 1)` | `colorSwitchKnobBgDefault` | `const Color(0xffffffff)` |
| `$color-switch_knob-bg-checked: rgba(var(--semi-white), 1)` | `colorSwitchKnobBgChecked` | `const Color(0xffffffff)` |
| `$color-switch_knob-border-default: var(--semi-color-border)` | `colorSwitchKnobBorderDefault` | `theme.colors.colorBorder` |
| `$color-switch_checked-text-default: var(--semi-color-white)` | `colorSwitchCheckedTextDefault` | `const Color(0xffffffff)` |
| `$color-switch_unchecked-text-default: var(--semi-color-text-2)` | `colorSwitchUncheckedTextDefault` | `theme.colors.colorText2` |
| `$color-switch_loading_spin-default: var(--semi-color-white)` | `colorSwitchLoadingSpinDefault` | `const Color(0xffffffff)` |
| `$color-switch_spin_checked-bg-default: var(--semi-color-success-hover)` | `colorSwitchSpinCheckedBgDefault` | `theme.colors.colorSuccessHover` |
| `$color-switch_spin_unchecked-bg-default: var(--semi-color-fill-1)` | `colorSwitchSpinUncheckedBgDefault` | `theme.colors.colorFill1` |
| `$color-switch_primary-outline-focus: var(--semi-color-primary-light-active)` | `colorSwitchPrimaryOutlineFocus` | `theme.colors.colorPrimaryLightActive` |
| `$spacing-switch_unchecked-translateX: 2px` | `spacingSwitchUncheckedTranslateX` | `2` |
| `$spacing-switch_spin_unchecked-translateX: 2px` | `spacingSwitchSpinUncheckedTranslateX` | `2` |
| `$spacing-switch_checked-translateX: 18px` | `spacingSwitchCheckedTranslateX` | `18` |
| `$spacing-switch_spin_checked-translateX: 16px` | `spacingSwitchSpinCheckedTranslateX` | `16` |
| `$spacing-switch_expand_large-translateX: 10px` | `spacingSwitchExpandLargeTranslateX` | `10` |
| `$spacing-switch_unchecked_large-translateX: 3px` | `spacingSwitchUncheckedLargeTranslateX` | `3` |
| `$spacing-switch_spin_unchecked_large-translateX: 2px` | `spacingSwitchSpinUncheckedLargeTranslateX` | `2` |
| `$spacing-switch_checked_large-translateX: 26px` | `spacingSwitchCheckedLargeTranslateX` | `26` |
| `$spacing-switch_spin_checked_large-translateX: 22px` | `spacingSwitchSpinCheckedLargeTranslateX` | `22` |
| `$spacing-switch_expand_small-translateX: 2px` | `spacingSwitchExpandSmallTranslateX` | `2` |
| `$spacing-switch_unchecked_small-translateX: 1px` | `spacingSwitchUncheckedSmallTranslateX` | `1` |
| `$spacing-switch_spin_unchecked_small-translateX: 2px` | `spacingSwitchSpinUncheckedSmallTranslateX` | `2` |
| `$spacing-switch_checked_small-translateX: 11px` | `spacingSwitchCheckedSmallTranslateX` | `11` |
| `$spacing-switch_spin_checked_small-translateX: 10px` | `spacingSwitchSpinCheckedSmallTranslateX` | `10` |
| `$spacing-switch_knob-padding: 2px` | `spacingSwitchKnobPadding` | `2` |
| `$spacing-switch_knob_large-padding: 3px` | `spacingSwitchKnobLargePadding` | `3` |
| `$spacing-switch_knob_small-padding: 1px` | `spacingSwitchKnobSmallPadding` | `1` |
| `$spacing-switch_knob-left: 0px` | `spacingSwitchKnobLeft` | `0` |
| `$width-switch: 40px` | `widthSwitch` | `40` |
| `$width-switch_knob_expand: 6px` | `widthSwitchKnobExpand` | `6` |
| `$width-switch_knob_default: 18px` | `widthSwitchKnobDefault` | `18` |
| `$width-switch_knob_active: $width-switch_knob_default + $width-switch_knob_expand` | `widthSwitchKnobActive` | `24`（派生：18+6） |
| `$width-switch_large: 54px` | `widthSwitchLarge` | `54` |
| `$width-switch_knob_large: 24px` | `widthSwitchKnobLarge` | `24` |
| `$width-switch_knob_large_active: $width-switch_knob_large + $spacing-switch_expand_large-translateX` | `widthSwitchKnobLargeActive` | `34`（派生：24+10） |
| `$width-switch_small: 26px` | `widthSwitchSmall` | `26` |
| `$width-switch_knob_large_small: 12px` | `widthSwitchKnobLargeSmall` | `12`（★命名 quirk：实为小尺寸滑块宽） |
| `$width-switch_knob_small_active: $width-switch_knob_large_small + $spacing-switch_expand_small-translateX` | `widthSwitchKnobSmallActive` | `14`（派生：12+2） |
| `$width-switch_knob_disabled-border: 1px` | `widthSwitchKnobDisabledBorder` | `1` |
| `$width-switch_checked_unchecked_text: 26px` | `widthSwitchCheckedUncheckedText` | `26`（large 文案盒宽；默认尺寸是 B 表硬编码 20px） |
| `$width-switch_spin-small: 10px` | `widthSwitchSpinSmall` | `10` |
| `$width-switch_spin-default: 18px` | `widthSwitchSpinDefault` | `18` |
| `$width-switch_spin-large: 28px` | `widthSwitchSpinLarge` | `28` |
| `$width-switch-outline: 2px` | `widthSwitchOutline` | `2` |
| `$height-switch: 24px` | `heightSwitch` | `24` |
| `$height-switch_large: 32px` | `heightSwitchLarge` | `32` |
| `$height-switch_small: 16px` | `heightSwitchSmall` | `16` |
| `$radius-switch: $height-switch * 0.5` | `radiusSwitch` | `12`（派生：24×0.5） |
| `$radius-switch_large: $height-switch_large * 0.5` | `radiusSwitchLarge` | `16`（派生：32×0.5） |
| `$radius-switch_small: $height-switch_small * 0.5` | `radiusSwitchSmall` | `8`（派生：16×0.5） |
| `$motion-switch-transitionDuration: 200ms` | `motionSwitchTransitionDuration` | `Duration(milliseconds: 200)`（★Duration 型 FIELDS：位于 variables.scss；knob 宽度/位移过渡时长） |
| `$transition_duration-switch-bg: 200ms` | `transitionDurationSwitchBg` | `Duration(milliseconds: 200)`（MOTION：track 背景过渡时长） |
| `$transition_function-switch-bg: var(--semi-transition_function-easeIn)` | `transitionFunctionSwitchBg` | `Curves.easeIn`（MOTION：track 背景过渡曲线） |
| `$transition_delay-switch-bg: var(--semi-transition_delay-none)` | `transitionDelaySwitchBg` | `Duration.zero`（MOTION：延迟，AnimatedContainer 无延迟通道、默认 none 即零净效果） |

### B. widget 内部常量（HARDCODES，另列）

| 常量（`_SwitchMetrics` / 调用点） | 上游出处 / 结构 | 值或处理 |
|---|---|---|
| `shadowKnob` | mixin.scss:14 `@mixin shadow-knob`（switch.scss:109 落在 `.semi-switch-knob`）— `box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1), 0 0 1px rgba(0, 0, 0, 0.3);` | 两个 BoxShadow（0,4,blur6 @0x1a000000 + blur1 @0x4d000000） |
| `shadowZero` | mixin.scss:8 `@mixin shadow-0`（switch.scss:78/96 disabled knob）— `box-shadow: none;` | 空列表：disabled knob 无阴影 |
| `textWidthDefault` | switch.scss:147 `&-checked-text, &-unchecked-text` — `width: 20px` | 20（默认尺寸文案盒宽；large 用 `widthSwitchCheckedUncheckedText`） |
| `knobTransitionEasing` | switch.scss:117 knob 过渡 — `transition: transform 200ms ease-in-out, width 200ms ease-in-out` | `Curves.easeInOut`（★knob 缓动硬编码 ease-in-out；背景过渡才走 tokenized easeIn） |
| `borderThicknessControl` | packages/semi-theme-default/scss/variables.scss:8 — `$border-thickness-control: 1px` | 1（track 描边宽） |
| （调用点）文案字号 | switch.scss:145 `font-size: $font-size-small` / :267 `font-size: $font-size-regular` | `$font-size-small: 12px` == `theme.typography.fontSizeSmall`；`$font-size-regular: 14px` == `theme.typography.fontSizeRegular` |
| （调用点）`all-center` | switch.scss:148 `@include all-center` — `display: flex; justify-content: center; align-items: center;` | `Center` 内容居中 |

## 差异清单

照搬留档（★，刻意与上游一致的行为）：

- **★Space 切换、Enter 不切换**：原生 checkbox 语义（`type="checkbox"`，index.tsx:144）。
- **★checked-pressed track 背景保持 success**：`$color-switch_checked-bg-active` 事实死变量（`&-active` 块 switch.scss:56-58 从未被挂类），widget 不消费（上游未消费）。
- **★`$width-switch_knob_large_small` 命名 quirk**：实为小尺寸滑块宽 12px。
- **★hover 仅在非 disabled 非 loading 生效**：disabled+loading hover 反向规则（switch.scss:102-106）净效果与 loading 本色相同；其余 disabled hover 本就透明无净效果。
- **★disabled+loading+选中 track 背景 = success-disabled**：switch.scss:232（`-disabled.-checked`）在源序上压过 :186（`-loading.-checked`）。
- **★按下 knob 只延展宽度**：24×18（radius 9 不随宽度变，switch.scss:29/:111 高度/圆角仅声明一次）。
- **★语义 enabled 只看 disabled**：`aria-disabled={disabled}`（index.tsx:179）loading 不反映。
- **★onBlur 先清焦点环再回调**：index.tsx:126-129 `foundation.handleBlur()` → `props.onBlur`。
- **★`$transition_duration-switch-bg: 200ms` 非 none**：与 slider 的 `duration-none` 不同，背景过渡实际 200ms easeIn。

偏差（不移植/调整）：

- **★`defaultChecked || checked` 真值初始化不移植**：上游 constructor `nativeControlChecked: props.defaultChecked || props.checked`（index.tsx:79）会让 `checked=false` + `defaultChecked=true` 的受控初值错渲成 true；本移植受控恒渲染 `checked`。
- **★首帧 disabled 缺口不移植**：上游 `init()` 才 `setDisabled(props.disabled)`（foundation.ts:17-20），首帧可能按 enabled 渲染一帧；本移植 disabled 立即生效。
- **按下视觉按「disabled/loading 全屏蔽」整块关闭**：上游纯 CSS `:active` 对禁用态仍有描边 fill-2 的字面级联残效（`.semi-switch:active` 特异性高于 `.semi-switch-disabled`）；本移植按下视觉仅在可交互时生效（契约「blocks everything」）。
- **定位原点取边框盒**：CSS 绝对定位原点是 padding box（与边框盒差 1px 描边），本移植 knob/spin/文案按 track 边框盒定位——默认描边透明，净效果仅禁用态 1px。
- **文案盒定位语义化**：按契约用 PositionedDirectional（checked 在方向起始、unchecked 在方向末尾，RTL 视觉互换）；上游 checked-text 靠静态位置、unchecked-text `right: 0`（rtl.scss:31 的 `left: 0` 受绝对定位 over-constrained 规则影响，浏览器字面净效果存疑）。
- **`$transition_delay-switch-bg` 无延迟通道**：AnimatedContainer 不支持 transition-delay（默认 `Duration.zero`，零净效果）。
- **style / className / id / aria-\* 透传简化**：样式走私有 theme patch / 外层 Widget；语义以 `Semantics(toggled:, enabled:)` 表达。
- **Form.Switch**：已由 `SemiFormSwitch` 便捷包装提供（值 bool——checked 口径适配，docs/semi_form.md）。

```dart
SemiSwitch(
  checked: v,                        // bool? 非空即受控
  defaultChecked: true,              // bool 非受控初值
  size: SemiSwitchSize.large,        // small / normal / large
  loading: true,
  checkedText: '开',                 // Object?（String | Widget）
  uncheckedText: const Icon(Icons.close),
  onChanged: (next) => print(next),  // 每次切换必报
);
// 局部主题：SemiSwitchTheme(data: const SemiSwitchThemeData(widthSwitch: 48), child: ...)
```
