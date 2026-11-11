# SemiButton 按钮

无需 Material，使用 `package:semi_design_flutter/semi_design_flutter.dart` 与 Flutter widgets。覆盖上游 `Button`/`index.tsx`（包装分发）+ `Button.tsx` + `iconButton/index.tsx` + `buttonGroup.tsx`，样式溯源 `packages/semi-foundation/button/{variables,animation,button,iconButton,rtl}.scss`。

```dart
SemiButton('主要按钮', onPressed: () {})
SemiButton(
  '保存',
  type: SemiButtonType.danger,
  variant: SemiButtonVariant.solid,
  icon: const SemiIcon(SemiIcons.save),
  loading: saving,
  onPressed: _save,
)
SemiButtonGroup(
  size: SemiButtonSize.large,
  children: [
    SemiButton('一', onPressed: () {}),
    SemiButton('二', onPressed: () {}),
    SemiButton('三', onPressed: () {}),
  ],
)
```

## API 与边界

`SemiButton`（`lib/src/components/semi_button.dart`）：

| 字段 | 说明 | 默认 |
| --- | --- | --- |
| `child` | `Object?`：`String`（渲染 `SemiText`，14/20/600 排版取 typography token）或 `Widget` 原样放置；null/空串为 iconOnly | 位置参数 |
| `type` | `SemiButtonType?`：primary/secondary/tertiary/warning/danger；null 取组级再取 `primary` | null（→primary） |
| `variant` | `SemiButtonVariant?`：light/solid/outline/borderless（上游 `theme`）；**组级非 null 覆盖子级** | null（→light） |
| `size` | `SemiButtonSize?`：small/normal/large = 24/32/40（上游 default↔normal） | null（→normal） |
| `loading` | 加载态：spinner 原位替换 icon、文本不动、拦截指针点击；`disabled` 优先于 `loading`；无受控 loading | `false` |
| `disabled` | 禁用态；null 取组级再取 `false` | null（→false） |
| `block` | 拉宽（上游 `width: 100%`） | `false` |
| `icon` | `Widget?` 图标插槽，16px、图文间距 8 | null |
| `iconPosition` | `SemiButtonIconPosition` left/right（上游 `iconPosition`） | `left` |
| `iconSize` | `SemiIconSize?` 图标槽尺寸覆盖；上游声明未应用（TODO），移植生效 | null（→16） |
| `noHorizontalPadding` | `SemiButtonNoPadding` none/left/right/both，清水平内边距（上游 `boolean\|'left'\|'right'\|['left','right']` union，仅对带 icon 路径有效） | `none` |
| `colorful` | 多彩 AI 变体；仅 primary/tertiary 响应（其余 type 忽略）；**组级非 null 覆盖子级** | null（→false） |
| `onPressed` | 激活回调（上游 `onClick`）；null 不可按但**视觉不置 disabled**（上游 onClick 默认 noop） | null |
| `onHoverChange` | `ValueChanged<bool>` hover 进出回调（上游 `onMouseEnter/Leave`） | null |
| `autofocus` | 挂载后请求焦点 | `false` |
| `semanticsLabel` | 无障碍标签（上游 `aria-label`） | null |

`SemiButtonGroup`（上游 `buttonGroup.tsx`）：

| 字段 | 说明 | 默认 |
| --- | --- | --- |
| `children` | `List<Widget>` 直接子级；仅 `SemiButton` 子级参与分割线/首尾圆角 | 必填 |
| `disabled`/`type`/`size` | 组级默认：**子级显式值优先** | null |
| `variant`/`colorful` | 组级主题/多彩：**组级非 null 时覆盖子级**（上游 `cloneElement` 的 `...rest` 后展开） | null |
| `semanticsLabel` | 组语义标签（上游 `aria-label`） | null |

合并优先级（上游 `cloneElement(item, { disabled, size, type, ...item.props, ...rest })`）：子 props 显式 `disabled`/`type`/`size` > 组级；组级 `variant`/`colorful` > 子级。Flutter 侧以可空字段表达"未显式"（null = 未给），经 `SemiButtonScope`（InheritedWidget）注入。

不移植：`htmlType`（button/reset/submit，HTML 原生语义）、`circle`（上游无 scss 规则、事实 no-op）、`SplitButtonGroup`（见差异清单）、`className`/`style`/`contentClassName`/`iconStyle`、`onMouseDown`（无 DOM 事件对象）。

## 渲染语义

### 状态色推导（颜色矩阵）

状态槽 4 个：`default/hover/active/disabled`，优先级 **disabled > pressed > hover > default**（hover/pressed 由 MouseRegion + 指针按下驱动）。按下解析器按 `(type, variant, 状态)` 逐字段查表（与 variables.scss 一一对应，含 hover 边框 quirk）：

| variant | background | text（CSS `color`，同图标 currentColor） | border |
| --- | --- | --- | --- |
| solid | `color-button_<type>-bg-{state}`；colorful primary→`_solid_colorful-bg-{state}` 渐变、tertiary→`_solid_colorful-bg-{state}` 渐变 | `color-button_<type>-text-{state}`（白）；colorful tertiary → 文字渐变 `_solid_colorful-text-default` | `color-button_<type>-border-{state}` × `width-button-border`（默认 0） |
| light | `color-button_light-bg-{state}`（fill-0/1/2） | `color-button_<type>_borderless-text-default`；tertiary→`_tertiary_solid-text-default`（text-1）；colorful primary→文字渐变 `_primary_light_colorful-text-default` | `color-button_light-border-{state}` × `width-button_light-border`（0） |
| borderless | 透明 / `_borderless-bg-hover` / `_borderless-bg-active` | 同 light | `color-button_borderless-border-{state}` × 0 |
| outline | 透明 / `_outline-bg-hover` / `_outline-bg-active` | 同 light；colorful primary→`_primary_light_outline-text-default`（ai-purple） | `color-button_<type>_outline-border-default` × 1px（primary/secondary/tertiary→border 色、danger/warning→type 色）；colorful primary→`_primary_light_outline-border`（ai-purple） |

disabled 槽：bg→`color-button_disabled_<type>-bg-default`（solid）/`color-button_disabled_light_<type>-bg-default`（light）/透明（borderless、outline）；text→`_disabled_solid-text-default`（solid）/`_disabled-text-default`（light、borderless）/`_disabled_outline_text-default`（outline）；border→`_disabled_outline-border-default`（outline，1px）/各 variant 的 `-border-default`。上游 class 结构在 disabled 时丢弃 `btn-<type>`，colorful/hover 规则全部失配，故 **disabled 优先于 loading/hover/colorful**。

Quirk（不修正）：`$color-button_danger-border-hover: var(--semi-color-danger)`（danger 边框 hover 不走 hover 色，与 secondary/warning 不对称）；`$color-button_secondary-border-default` 上游仅被 `outline-color` 消费（焦点 outline 会覆盖其色）；text-hover/active 与 solid 档 border-hover/active 上游 scss 未消费（hover 只变 bg），解析器仍按字段逐条取值（默认同值无视觉差）。

### loading

- spinner 原位替换 icon（文本不动）；指针点击拦截（`pointer-events: none` 等价），`Semantics.enabled` 仅看 `disabled`（上游 `aria-disabled: disabled`）。
- disabled 优先于 loading：disabled 时无 spinner、原 icon 保留、禁用视觉。
- spinner 选型（上游 `iconButton/index.tsx` 原样）：`(colorful && variant != solid) || (variant == solid && type == tertiary)` 用 `SemiIcons.aiLoading`（对应上游 `IconAILoading`，资产 `ai_loading.svg` 四 stop 渐变描边已烘焙），否则 `SemiIcons.spin`（`spin.svg` 渐变 spinner）。注意 solid+tertiary 即便非 colorful 也走 aiLoading（上游条件原样）。
- 旋转：`SemiIcons.spin` 600ms（`$animation_duration-button_icon_loading`）；aiLoading 1600ms（`$animation_duration-button_icon_customIcon_loading`，"自定义指示器时旋转一周时长"）。
- **宽度保持**：无 icon 的按钮进入 loading 会增开图标位（spinner + 8 间距）而变宽——上游 loading 走 IconButton 路径的原样行为，如实移植。

### colorful（多彩）

仅 `primary`/`tertiary` 响应（其余 type 忽略 colorful，保持常色）：

| type + variant | 背景 | 文字 | 图标 |
| --- | --- | --- | --- |
| primary + solid | `_primary_solid_colorful-bg-{state}` 渐变（SemiGradient.forSize） | 白（不变） | currentColor（白） |
| primary + light | fill-0/1/2 | 文字渐变 `_primary_light_colorful-text-default`（ShaderMask clip:text） | currentColor（primary 色） |
| primary + borderless | hover/active fill | 文字渐变 `_primary_light_borderless-text-default` | currentColor（primary 色） |
| primary + outline | 透明 | ai-purple 纯色（`_primary_light_outline-text-default`） | currentColor（ai-purple） |
| tertiary + solid | `_tertiary_solid_colorful-bg-{state}` 渐变（ai-general-0/1/2） | 文字渐变 `_tertiary_solid_colorful-text-default` | currentColor（白） |
| tertiary + light/outline/borderless | 不变 | text-1（`_tertiary_solid-text-default`，与非 colorful 一致） | currentColor |

图标四 stop/两 stop 重染（上游 `IconAILoading` 的 fill 数组、`--semi-button-colorful-multiple-fill-*`/`-fill-primary/-fill-secondary`）**不移植**（SemiIcon 单色架构，同 Tag 边界）：图标以 currentColor（上表 CSS `color`）呈现。7 条 cssVariables 由 `SemiButtonTokens` 承接：

| cssVariables | 默认 | SemiButtonTokens 字段 → 默认源 |
|---|---|---|
| `--semi-button-colorful-multiple-fill-0` | rgba(var(--semi-ai-general-5-3)) | buttonColorfulMultipleFill0 → palette.aiGeneral53 |
| `--semi-button-colorful-multiple-fill-1` | rgba(var(--semi-ai-general-5-2)) | buttonColorfulMultipleFill1 → palette.aiGeneral52 |
| `--semi-button-colorful-multiple-fill-2` | rgba(var(--semi-ai-general-5-1)) | buttonColorfulMultipleFill2 → palette.aiGeneral51 |
| `--semi-button-colorful-multiple-fill-3` | rgba(var(--semi-ai-general-5-0)) | buttonColorfulMultipleFill3 → palette.aiGeneral50 |
| `--semi-button-colorful-disabled-fill` | var(--semi-color-disabled-text) | buttonColorfulDisabledFill → colors.colorDisabledText |
| `--semi-button-colorful-fill-primary` | var(--semi-color-ai-purple) | buttonColorfulFillPrimary → colors.colorAiPurple |
| `--semi-button-colorful-fill-secondary` | var(--semi-color-text-0) | buttonColorfulFillSecondary → colors.colorText0 |

### 焦点与键盘

- Enter/Space 触发（`Focus.onKeyEvent`）；loading 只拦指针，键盘激活与上游一致。
- `focus-visible`：`_keyboardUsed` 门控（参照 `semi_dropdown.dart` 的 :focus-visible 处理，扩展为全局键盘模态追踪：任意按键置位、按下按钮清位）——键盘聚焦后显示 2px outline，鼠标点击聚焦不显示。环画在框外（零模糊 spread shadow，对应 CSS `outline` 不占布局）。
- 焦点色 quirk（不修正）：`$color-button_primary_outline-focus` 通用；danger/warning 仅在 solid/outline 换用各自 `-outline-focus`，**borderless/light 保留 primary 焦点色**。disabled 不可聚焦（上游 disabled button 不进 Tab 序列）。

### ButtonGroup 渲染

- 分割线（上游 `.semi-button-group-line` 双层结构）：非 outline 变体在相邻按钮间插 **1px 全高色条**（高=相邻按钮较高者），色条颜色按上游 `group-line-{theme,type,-disabled}` class 级联：borderless→透明、light→`color-button_light-bg-default`、其余→disabled ? `color-button_disabled-bg-default` : `color-button_<type>-bg-default`（见差异清单第 13 条）；色条内居中叠一根 **1px × 20px 灰色刻线**（`height-button_group_line_default`，恒 `color-button_group-border-default`，即上游 `&::before`）。light 色条与按钮背景同为 fill-0，整组因此连成一整块，仅以短刻线分隔。
- 首尾圆角：首按钮左上/左下、末按钮右上/右下（左首右尾，`radius-button_group`），RTL 镜像（BorderRadiusDirectional）。
- outline 相邻 `margin -1px` 重叠（负 margin 以 `_NegativeEndMargin` 表达：布局宽度 -1、右侧绘制保持满宽，下一按钮压过接缝）。
- 组内按钮水平内边距归零、内容层承担水平 padding（按 size/iconOnly 取对应 `spacing-button_*` 字段）。

### 尺寸与 RTL

高 24/32/40（`height-button_*`）；padding Y 2/6/10、X 12/12/16；iconOnly 见方 24/32/40、padding 4/8/12；圆角 `radius-button`（border-radius-small=3）；outline 边框 1px、focus 环 2px；block 拉宽。图标 16px、图文间距 8（`spacing-button_iconOnly_content-margin*`）。padding 用 `EdgeInsetsDirectional`、首尾圆角用 `BorderRadiusDirectional`，RTL 自动镜像；图标/文字次序随环境方向（上游 `direction: rtl` 同效）。

## 主题

主题优先级：局部非空补丁（外到内 merge）> `SemiThemeData.components.button` > live global 默认值。`SemiButtonTheme` 局部补丁跨 `SemiTheme`/Overlay 边界继承（捕获只携带局部补丁快照）。

对账 **213 = 158（variables.scss）+ 48（animation.scss）+ 7（cssVariables.scss）**：前 206 条逐条成为主题字段（`tool/generate_button.py` 生成到 `semi_button_theme_data.dart`，下表全量）；7 条 cssVariables 由 `SemiButtonTokens` 承接（上文 colorful 表，交叉引用不建字段）。每字段 `///` 完整 Sass 名/默认/来源；resolve 按声明逐条映射（theme.colors.*、palette 通道 `theme.palette.white.toColor()`/`aiGeneral*`、motion token、`SemiButtonTokens` 交叉引用），不作矩阵推导。`tool/test_generate_button.py` 校验 158/48/7 分节计数、FIELDS∪INTERNAL 覆盖、溯源串在源码、再生成字节一致、383 manifest 不动。

### variables.scss 颜色 101

**primary 19（含 colorful 7）**

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$color-button_primary-bg-default` | var(--semi-color-primary) | colorButtonPrimaryBgDefault → theme.colors.colorPrimary |
| `$color-button_primary-border-default` | transparent | colorButtonPrimaryBorderDefault → const Color(0x00000000) |
| `$color-button_primary-text-default` | rgba(var(--semi-white), 1) | colorButtonPrimaryTextDefault → theme.palette.white.toColor() |
| `$color-button_primary-bg-hover` | var(--semi-color-primary-hover) | colorButtonPrimaryBgHover → theme.colors.colorPrimaryHover |
| `$color-button_primary-border-hover` | var(--semi-color-primary-hover) | colorButtonPrimaryBorderHover → theme.colors.colorPrimaryHover |
| `$color-button_primary-text-hover` | rgba(var(--semi-white), 1) | colorButtonPrimaryTextHover → theme.palette.white.toColor() |
| `$color-button_primary-bg-active` | var(--semi-color-primary-active) | colorButtonPrimaryBgActive → theme.colors.colorPrimaryActive |
| `$color-button_primary-border-active` | var(--semi-color-primary-active) | colorButtonPrimaryBorderActive → theme.colors.colorPrimaryActive |
| `$color-button_primary-text-active` | rgba(var(--semi-white), 1) | colorButtonPrimaryTextActive → theme.palette.white.toColor() |
| `$color-button_primary_outline-focus` | var(--semi-color-primary-light-active) | colorButtonPrimaryOutlineFocus → theme.colors.colorPrimaryLightActive |
| `$color-button_primary_outline-border-default` | var(--semi-color-border) | colorButtonPrimaryOutlineBorderDefault → theme.colors.colorBorder |
| `$color-button_primary_borderless-text-default` | var(--semi-color-primary) | colorButtonPrimaryBorderlessTextDefault → theme.colors.colorPrimary |
| `$color-button_primary_solid_colorful-bg-default` | var(--semi-color-ai-general) | colorButtonPrimarySolidColorfulBgDefault → theme.colors.colorAiGeneral |
| `$color-button_primary_solid_colorful-bg-hover` | var(--semi-color-ai-general-hover) | colorButtonPrimarySolidColorfulBgHover → theme.colors.colorAiGeneralHover |
| `$color-button_primary_solid_colorful-bg-active` | var(--semi-color-ai-general-active) | colorButtonPrimarySolidColorfulBgActive → theme.colors.colorAiGeneralActive |
| `$color-button_primary_light_colorful-text-default` | var(--semi-color-ai-general) | colorButtonPrimaryLightColorfulTextDefault → theme.colors.colorAiGeneral |
| `$color-button_primary_light_outline-text-default` | var(--semi-color-ai-purple) | colorButtonPrimaryLightOutlineTextDefault → theme.colors.colorAiPurple |
| `$color-button_primary_light_outline-border` | var(--semi-color-ai-purple) | colorButtonPrimaryLightOutlineBorder → theme.colors.colorAiPurple |
| `$color-button_primary_light_borderless-text-default` | var(--semi-color-ai-general) | colorButtonPrimaryLightBorderlessTextDefault → theme.colors.colorAiGeneral |

**secondary 11**

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$color-button_secondary-bg-default` | var(--semi-color-secondary) | colorButtonSecondaryBgDefault → theme.colors.colorSecondary |
| `$color-button_secondary-border-default` | var(--semi-color-secondary) | colorButtonSecondaryBorderDefault → theme.colors.colorSecondary |
| `$color-button_secondary-text-default` | rgba(var(--semi-white), 1) | colorButtonSecondaryTextDefault → theme.palette.white.toColor() |
| `$color-button_secondary-bg-hover` | var(--semi-color-secondary-hover) | colorButtonSecondaryBgHover → theme.colors.colorSecondaryHover |
| `$color-button_secondary-border-hover` | var(--semi-color-secondary-hover) | colorButtonSecondaryBorderHover → theme.colors.colorSecondaryHover |
| `$color-button_secondary-text-hover` | rgba(var(--semi-white), 1) | colorButtonSecondaryTextHover → theme.palette.white.toColor() |
| `$color-button_secondary-bg-active` | var(--semi-color-secondary-active) | colorButtonSecondaryBgActive → theme.colors.colorSecondaryActive |
| `$color-button_secondary-border-active` | var(--semi-color-secondary-active) | colorButtonSecondaryBorderActive → theme.colors.colorSecondaryActive |
| `$color-button_secondary-text-active` | rgba(var(--semi-white), 1) | colorButtonSecondaryTextActive → theme.palette.white.toColor() |
| `$color-button_secondary_outline-border-default` | var(--semi-color-border) | colorButtonSecondaryOutlineBorderDefault → theme.colors.colorBorder |
| `$color-button_secondary_borderless-text-default` | var(--semi-color-secondary) | colorButtonSecondaryBorderlessTextDefault → theme.colors.colorSecondary |

**danger 12**

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$color-button_danger-bg-default` | var(--semi-color-danger) | colorButtonDangerBgDefault → theme.colors.colorDanger |
| `$color-button_danger-border-default` | var(--semi-color-danger) | colorButtonDangerBorderDefault → theme.colors.colorDanger |
| `$color-button_danger-text-default` | rgba(var(--semi-white), 1) | colorButtonDangerTextDefault → theme.palette.white.toColor() |
| `$color-button_danger-bg-hover` | var(--semi-color-danger-hover) | colorButtonDangerBgHover → theme.colors.colorDangerHover |
| `$color-button_danger-border-hover` | var(--semi-color-danger) | colorButtonDangerBorderHover → theme.colors.colorDanger |
| `$color-button_danger-text-hover` | rgba(var(--semi-white), 1) | colorButtonDangerTextHover → theme.palette.white.toColor() |
| `$color-button_danger-bg-active` | var(--semi-color-danger-active) | colorButtonDangerBgActive → theme.colors.colorDangerActive |
| `$color-button_danger-border-active` | var(--semi-color-danger-active) | colorButtonDangerBorderActive → theme.colors.colorDangerActive |
| `$color-button_danger-text-active` | rgba(var(--semi-white), 1) | colorButtonDangerTextActive → theme.palette.white.toColor() |
| `$color-button_danger-outline-focus` | var(--semi-color-danger-light-active) | colorButtonDangerOutlineFocus → theme.colors.colorDangerLightActive |
| `$color-button_danger_outline-border-default` | var(--semi-color-danger) | colorButtonDangerOutlineBorderDefault → theme.colors.colorDanger |
| `$color-button_danger_borderless-text-default` | var(--semi-color-danger) | colorButtonDangerBorderlessTextDefault → theme.colors.colorDanger |

**warning 12**

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$color-button_warning-bg-default` | var(--semi-color-warning) | colorButtonWarningBgDefault → theme.colors.colorWarning |
| `$color-button_warning-border-default` | var(--semi-color-warning) | colorButtonWarningBorderDefault → theme.colors.colorWarning |
| `$color-button_warning-text-default` | rgba(var(--semi-white), 1) | colorButtonWarningTextDefault → theme.palette.white.toColor() |
| `$color-button_warning-bg-hover` | var(--semi-color-warning-hover) | colorButtonWarningBgHover → theme.colors.colorWarningHover |
| `$color-button_warning-border-hover` | var(--semi-color-warning-hover) | colorButtonWarningBorderHover → theme.colors.colorWarningHover |
| `$color-button_warning-text-hover` | rgba(var(--semi-white), 1) | colorButtonWarningTextHover → theme.palette.white.toColor() |
| `$color-button_warning-bg-active` | var(--semi-color-warning-active) | colorButtonWarningBgActive → theme.colors.colorWarningActive |
| `$color-button_warning-border-active` | var(--semi-color-warning-active) | colorButtonWarningBorderActive → theme.colors.colorWarningActive |
| `$color-button_warning-text-active` | rgba(var(--semi-white), 1) | colorButtonWarningTextActive → theme.palette.white.toColor() |
| `$color-button_warning-outline-focus` | var(--semi-color-warning-light-active) | colorButtonWarningOutlineFocus → theme.colors.colorWarningLightActive |
| `$color-button_warning_outline-border-default` | var(--semi-color-warning) | colorButtonWarningOutlineBorderDefault → theme.colors.colorWarning |
| `$color-button_warning_borderless-text-default` | var(--semi-color-warning) | colorButtonWarningBorderlessTextDefault → theme.colors.colorWarning |

**tertiary 15（含 colorful 4）**

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$color-button_tertiary-bg-default` | var(--semi-color-tertiary) | colorButtonTertiaryBgDefault → theme.colors.colorTertiary |
| `$color-button_tertiary-border-default` | var(--semi-color-tertiary) | colorButtonTertiaryBorderDefault → theme.colors.colorTertiary |
| `$color-button_tertiary-text-default` | rgba(var(--semi-white), 1) | colorButtonTertiaryTextDefault → theme.palette.white.toColor() |
| `$color-button_tertiary_solid_colorful-bg-default` | var(--semi-ai-general-0) | colorButtonTertiarySolidColorfulBgDefault → theme.palette.aiGeneral0 |
| `$color-button_tertiary_solid_colorful-bg-hover` | var(--semi-ai-general-1) | colorButtonTertiarySolidColorfulBgHover → theme.palette.aiGeneral1 |
| `$color-button_tertiary_solid_colorful-bg-active` | var(--semi-ai-general-2) | colorButtonTertiarySolidColorfulBgActive → theme.palette.aiGeneral2 |
| `$color-button_tertiary_solid_colorful-text-default` | var(--semi-color-ai-general) | colorButtonTertiarySolidColorfulTextDefault → theme.colors.colorAiGeneral |
| `$color-button_tertiary-bg-hover` | var(--semi-color-tertiary-hover) | colorButtonTertiaryBgHover → theme.colors.colorTertiaryHover |
| `$color-button_tertiary-border-hover` | var(--semi-color-tertiary-hover) | colorButtonTertiaryBorderHover → theme.colors.colorTertiaryHover |
| `$color-button_tertiary-text-hover` | rgba(var(--semi-white), 1) | colorButtonTertiaryTextHover → theme.palette.white.toColor() |
| `$color-button_tertiary-bg-active` | var(--semi-color-tertiary-active) | colorButtonTertiaryBgActive → theme.colors.colorTertiaryActive |
| `$color-button_tertiary-border-active` | var(--semi-color-tertiary-active) | colorButtonTertiaryBorderActive → theme.colors.colorTertiaryActive |
| `$color-button_tertiary-text-active` | rgba(var(--semi-white), 1) | colorButtonTertiaryTextActive → theme.palette.white.toColor() |
| `$color-button_tertiary_outline-border-default` | var(--semi-color-border) | colorButtonTertiaryOutlineBorderDefault → theme.colors.colorBorder |
| `$color-button_tertiary_solid-text-default` | var(--semi-color-text-1) | colorButtonTertiarySolidTextDefault → theme.colors.colorText1 |

**disabled 12**

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$color-button_disabled_solid-text-default` | var(--semi-color-disabled-text) | colorButtonDisabledSolidTextDefault → theme.colors.colorDisabledText |
| `$color-button_disabled-text-default` | var(--semi-color-disabled-text) | colorButtonDisabledTextDefault → theme.colors.colorDisabledText |
| `$color-button_disabled_outline_text-default` | var(--semi-color-disabled-text) | colorButtonDisabledOutlineTextDefault → theme.colors.colorDisabledText |
| `$color-button_disabled-bg-default` | var(--semi-color-disabled-bg) | colorButtonDisabledBgDefault → theme.colors.colorDisabledBg |
| `$color-button_disabled-text-hover` | $color-button_disabled-text-default | colorButtonDisabledTextHover → theme.colors.colorDisabledText |
| `$color-button_disabled-bg-hover` | var(--semi-color-disabled-bg) | colorButtonDisabledBgHover → theme.colors.colorDisabledBg |
| `$color-button_disabled_primary-bg-default` | $color-button_disabled-bg-default | colorButtonDisabledPrimaryBgDefault → theme.colors.colorDisabledBg |
| `$color-button_disabled_secondary-bg-default` | $color-button_disabled-bg-default | colorButtonDisabledSecondaryBgDefault → theme.colors.colorDisabledBg |
| `$color-button_disabled_danger-bg-default` | $color-button_disabled-bg-default | colorButtonDisabledDangerBgDefault → theme.colors.colorDisabledBg |
| `$color-button_disabled_warning-bg-default` | $color-button_disabled-bg-default | colorButtonDisabledWarningBgDefault → theme.colors.colorDisabledBg |
| `$color-button_disabled_tertiary-bg-default` | $color-button_disabled-bg-default | colorButtonDisabledTertiaryBgDefault → theme.colors.colorDisabledBg |
| `$color-button_disabled_outline-border-default` | var(--semi-color-border) | colorButtonDisabledOutlineBorderDefault → theme.colors.colorBorder |

**light 11（含 disabled_light 5）**

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$color-button_light-bg-default` | var(--semi-color-fill-0) | colorButtonLightBgDefault → theme.colors.colorFill0 |
| `$color-button_light-bg-hover` | var(--semi-color-fill-1) | colorButtonLightBgHover → theme.colors.colorFill1 |
| `$color-button_light-bg-active` | var(--semi-color-fill-2) | colorButtonLightBgActive → theme.colors.colorFill2 |
| `$color-button_light-border-default` | transparent | colorButtonLightBorderDefault → const Color(0x00000000) |
| `$color-button_light-border-hover` | $color-button_light-border-default | colorButtonLightBorderHover → const Color(0x00000000) |
| `$color-button_light-border-active` | $color-button_light-border-hover | colorButtonLightBorderActive → const Color(0x00000000) |
| `$color-button_disabled_light_primary-bg-default` | $color-button_light-bg-default | colorButtonDisabledLightPrimaryBgDefault → theme.colors.colorFill0 |
| `$color-button_disabled_light_secondary-bg-default` | $color-button_light-bg-default | colorButtonDisabledLightSecondaryBgDefault → theme.colors.colorFill0 |
| `$color-button_disabled_light_danger-bg-default` | $color-button_light-bg-default | colorButtonDisabledLightDangerBgDefault → theme.colors.colorFill0 |
| `$color-button_disabled_light_warning-bg-default` | $color-button_light-bg-default | colorButtonDisabledLightWarningBgDefault → theme.colors.colorFill0 |
| `$color-button_disabled_light_tertiary-bg-default` | $color-button_light-bg-default | colorButtonDisabledLightTertiaryBgDefault → theme.colors.colorFill0 |

**borderless 6**

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$color-button_borderless-text-default` | var(--semi-color-primary) | colorButtonBorderlessTextDefault → theme.colors.colorPrimary |
| `$color-button_borderless-bg-hover` | var(--semi-color-fill-0) | colorButtonBorderlessBgHover → theme.colors.colorFill0 |
| `$color-button_borderless-bg-active` | var(--semi-color-fill-1) | colorButtonBorderlessBgActive → theme.colors.colorFill1 |
| `$color-button_borderless-border-default` | transparent | colorButtonBorderlessBorderDefault → const Color(0x00000000) |
| `$color-button_borderless-border-hover` | $color-button_borderless-border-default | colorButtonBorderlessBorderHover → const Color(0x00000000) |
| `$color-button_borderless-border-active` | $color-button_borderless-border-hover | colorButtonBorderlessBorderActive → const Color(0x00000000) |

**outline 2**

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$color-button_outline-bg-hover` | var(--semi-color-fill-0) | colorButtonOutlineBgHover → theme.colors.colorFill0 |
| `$color-button_outline-bg-active` | var(--semi-color-fill-1) | colorButtonOutlineBgActive → theme.colors.colorFill1 |

**group 1**

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$color-button_group-border-default` | var(--semi-color-border) | colorButtonGroupBorderDefault → theme.colors.colorBorder |

### variables.scss 非颜色 57

**width 6**

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$width-button_light-border` | 0 | widthButtonLightBorder → 0 |
| `$width-button_borderless-border` | 0 | widthButtonBorderlessBorder → 0 |
| `$width-button_outline-border` | 1px | widthButtonOutlineBorder → 1 |
| `$width-button_group-border` | $border-thickness-control | widthButtonGroupBorder → 1 |
| `$width-button-border` | $border-thickness | widthButtonBorder → 0 |
| `$width-button-outline` | 2px | widthButtonOutline → 2 |

**spacing 24**

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$spacing-button_default-paddingTop` | 6px | spacingButtonDefaultPaddingTop → 6 |
| `$spacing-button_default-paddingBottom` | 6px | spacingButtonDefaultPaddingBottom → 6 |
| `$spacing-button_default-paddingLeft` | $spacing-base-tight | spacingButtonDefaultPaddingLeft → 12 |
| `$spacing-button_default-paddingRight` | $spacing-base-tight | spacingButtonDefaultPaddingRight → 12 |
| `$spacing-button_large-paddingTop` | 10px | spacingButtonLargePaddingTop → 10 |
| `$spacing-button_large-paddingBottom` | 10px | spacingButtonLargePaddingBottom → 10 |
| `$spacing-button_large-paddingLeft` | $spacing-base | spacingButtonLargePaddingLeft → 16 |
| `$spacing-button_large-paddingRight` | $spacing-base | spacingButtonLargePaddingRight → 16 |
| `$spacing-button_small-paddingTop` | $spacing-super-tight | spacingButtonSmallPaddingTop → 2 |
| `$spacing-button_small-paddingBottom` | $spacing-super-tight | spacingButtonSmallPaddingBottom → 2 |
| `$spacing-button_small-paddingLeft` | $spacing-base-tight | spacingButtonSmallPaddingLeft → 12 |
| `$spacing-button_small-paddingRight` | $spacing-base-tight | spacingButtonSmallPaddingRight → 12 |
| `$spacing-button_iconOnly_default-paddingLeft` | $spacing-tight | spacingButtonIconOnlyDefaultPaddingLeft → 8 |
| `$spacing-button_iconOnly_default-paddingRight` | $spacing-tight | spacingButtonIconOnlyDefaultPaddingRight → 8 |
| `$spacing-button_iconOnly_default-paddingTop` | $spacing-tight | spacingButtonIconOnlyDefaultPaddingTop → 8 |
| `$spacing-button_iconOnly_default-paddingBottom` | $spacing-tight | spacingButtonIconOnlyDefaultPaddingBottom → 8 |
| `$spacing-button_iconOnly_large-paddingLeft` | $spacing-base-tight | spacingButtonIconOnlyLargePaddingLeft → 12 |
| `$spacing-button_iconOnly_large-paddingRight` | $spacing-base-tight | spacingButtonIconOnlyLargePaddingRight → 12 |
| `$spacing-button_iconOnly_large-paddingTop` | $spacing-base-tight | spacingButtonIconOnlyLargePaddingTop → 12 |
| `$spacing-button_iconOnly_large-paddingBottom` | $spacing-base-tight | spacingButtonIconOnlyLargePaddingBottom → 12 |
| `$spacing-button_iconOnly_small-paddingLeft` | $spacing-extra-tight | spacingButtonIconOnlySmallPaddingLeft → 4 |
| `$spacing-button_iconOnly_small-paddingRight` | $spacing-extra-tight | spacingButtonIconOnlySmallPaddingRight → 4 |
| `$spacing-button_iconOnly_small-paddingTop` | $spacing-extra-tight | spacingButtonIconOnlySmallPaddingTop → 4 |
| `$spacing-button_iconOnly_small-paddingBottom` | $spacing-extra-tight | spacingButtonIconOnlySmallPaddingBottom → 4 |

**iconOnly 尺寸 6**

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$height-button_iconOnly_small` | $height-control-small | heightButtonIconOnlySmall → 24 |
| `$width-button_iconOnly_small` | $height-control-small | widthButtonIconOnlySmall → 24 |
| `$height-button_iconOnly_default` | $height-control-default | heightButtonIconOnlyDefault → 32 |
| `$width-button_iconOnly_default` | $height-control-default | widthButtonIconOnlyDefault → 32 |
| `$height-button_iconOnly_large` | $height-control-large | heightButtonIconOnlyLarge → 40 |
| `$width-button_iconOnly_large` | $height-control-large | widthButtonIconOnlyLarge → 40 |

**margin 2**

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$spacing-button_iconOnly_content-marginLeft` | $spacing-tight | spacingButtonIconOnlyContentMarginLeft → 8 |
| `$spacing-button_iconOnly_content-marginRight` | $spacing-tight | spacingButtonIconOnlyContentMarginRight → 8 |

**font 9**

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$font-button-fontWeight` | $font-weight-bold | fontButtonFontWeight → theme.typography.fontWeightBold |
| `$font-button-fontSize` | $font-size-regular | fontButtonFontSize → theme.typography.fontSizeRegular |
| `$font-button-lineHeight` | 20px | fontButtonLineHeight → 20 |
| `$font-button_small-fontWeight` | $font-weight-bold | fontButtonSmallFontWeight → theme.typography.fontWeightBold |
| `$font-button_small-fontSize` | $font-size-regular | fontButtonSmallFontSize → theme.typography.fontSizeRegular |
| `$font-button_small-lineHeight` | 20px | fontButtonSmallLineHeight → 20 |
| `$font-button_large-fontWeight` | $font-weight-bold | fontButtonLargeFontWeight → theme.typography.fontWeightBold |
| `$font-button_large-fontSize` | $font-size-regular | fontButtonLargeFontSize → theme.typography.fontSizeRegular |
| `$font-button_large-lineHeight` | 20px | fontButtonLargeLineHeight → 20 |

**height 4**

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$height-button_large` | $height-control-large | heightButtonLarge → 40 |
| `$height-button_small` | $height-control-small | heightButtonSmall → 24 |
| `$height-button_default` | $height-control-default | heightButtonDefault → 32 |
| `$height-button_group_line_default` | 20px | heightButtonGroupLineDefault → 20 |

**radius 2**

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$radius-button` | var(--semi-border-radius-small) | radiusButton → theme.radius.borderRadiusSmall.value |
| `$radius-button_group` | $radius-button | radiusButtonGroup → theme.radius.borderRadiusSmall.value |

**split 圆角 4（SplitButtonGroup 未移植、仅配置）**

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$radius-button_splitButtonGroup_first_topLeft` | var(--semi-border-radius-small) | radiusButtonSplitButtonGroupFirstTopLeft → theme.radius.borderRadiusSmall.value |
| `$radius-button_splitButtonGroup_first_bottomLeft` | var(--semi-border-radius-small) | radiusButtonSplitButtonGroupFirstBottomLeft → theme.radius.borderRadiusSmall.value |
| `$radius-button_splitButtonGroup_last_topRight` | var(--semi-border-radius-small) | radiusButtonSplitButtonGroupLastTopRight → theme.radius.borderRadiusSmall.value |
| `$radius-button_splitButtonGroup_last_bottomRight` | var(--semi-border-radius-small) | radiusButtonSplitButtonGroupLastBottomRight → theme.radius.borderRadiusSmall.value |

### animation.scss 48

**transition 背景三元组 7 组 × duration/function/delay**

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$transition_duration-button_primary-bg` | var(--semi-transition_duration-none) | transitionDurationButtonPrimaryBg → theme.motion.transitionDurationNone |
| `$transition_duration-button_secondary-bg` | var(--semi-transition_duration-none) | transitionDurationButtonSecondaryBg → theme.motion.transitionDurationNone |
| `$transition_duration-button_tertiary-bg` | var(--semi-transition_duration-none) | transitionDurationButtonTertiaryBg → theme.motion.transitionDurationNone |
| `$transition_duration-button_light-bg` | var(--semi-transition_duration-none) | transitionDurationButtonLightBg → theme.motion.transitionDurationNone |
| `$transition_duration-button_warning-bg` | var(--semi-transition_duration-none) | transitionDurationButtonWarningBg → theme.motion.transitionDurationNone |
| `$transition_duration-button_danger-bg` | var(--semi-transition_duration-none) | transitionDurationButtonDangerBg → theme.motion.transitionDurationNone |
| `$transition_duration-button_borderless-bg` | var(--semi-transition_duration-none) | transitionDurationButtonBorderlessBg → theme.motion.transitionDurationNone |
| `$transition_function-button_primary-bg` | var(--semi-transition_function-easeIn) | transitionFunctionButtonPrimaryBg → theme.motion.transitionFunctionEaseIn |
| `$transition_function-button_secondary-bg` | var(--semi-transition_function-easeIn) | transitionFunctionButtonSecondaryBg → theme.motion.transitionFunctionEaseIn |
| `$transition_function-button_tertiary-bg` | var(--semi-transition_function-easeIn) | transitionFunctionButtonTertiaryBg → theme.motion.transitionFunctionEaseIn |
| `$transition_function-button_light-bg` | var(--semi-transition_function-easeIn) | transitionFunctionButtonLightBg → theme.motion.transitionFunctionEaseIn |
| `$transition_function-button_warning-bg` | var(--semi-transition_function-easeIn) | transitionFunctionButtonWarningBg → theme.motion.transitionFunctionEaseIn |
| `$transition_function-button_danger-bg` | var(--semi-transition_function-easeIn) | transitionFunctionButtonDangerBg → theme.motion.transitionFunctionEaseIn |
| `$transition_function-button_borderless-bg` | var(--semi-transition_function-easeIn) | transitionFunctionButtonBorderlessBg → theme.motion.transitionFunctionEaseIn |
| `$transition_delay-button_primary-bg` | var(--semi-transition_delay-none) | transitionDelayButtonPrimaryBg → theme.motion.transitionDelayNone |
| `$transition_delay-button_secondary-bg` | var(--semi-transition_delay-none) | transitionDelayButtonSecondaryBg → theme.motion.transitionDelayNone |
| `$transition_delay-button_tertiary-bg` | var(--semi-transition_delay-none) | transitionDelayButtonTertiaryBg → theme.motion.transitionDelayNone |
| `$transition_delay-button_light-bg` | var(--semi-transition_delay-none) | transitionDelayButtonLightBg → theme.motion.transitionDelayNone |
| `$transition_delay-button_warning-bg` | var(--semi-transition_delay-none) | transitionDelayButtonWarningBg → theme.motion.transitionDelayNone |
| `$transition_delay-button_danger-bg` | var(--semi-transition_delay-none) | transitionDelayButtonDangerBg → theme.motion.transitionDelayNone |
| `$transition_delay-button_borderless-bg` | var(--semi-transition_delay-none) | transitionDelayButtonBorderlessBg → theme.motion.transitionDelayNone |

**transition 边框三元组 6 组 × duration/function/delay（borderless 缺、非对称如实）**

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$transition_duration-button_primary-border` | var(--semi-transition_duration-none) | transitionDurationButtonPrimaryBorder → theme.motion.transitionDurationNone |
| `$transition_function-button_primary-border` | var(--semi-transition_function-easeIn) | transitionFunctionButtonPrimaryBorder → theme.motion.transitionFunctionEaseIn |
| `$transition_delay-button_primary-border` | var(--semi-transition_delay-none) | transitionDelayButtonPrimaryBorder → theme.motion.transitionDelayNone |
| `$transition_duration-button_secondary-border` | var(--semi-transition_duration-none) | transitionDurationButtonSecondaryBorder → theme.motion.transitionDurationNone |
| `$transition_function-button_secondary-border` | var(--semi-transition_function-easeIn) | transitionFunctionButtonSecondaryBorder → theme.motion.transitionFunctionEaseIn |
| `$transition_delay-button_secondary-border` | var(--semi-transition_delay-none) | transitionDelayButtonSecondaryBorder → theme.motion.transitionDelayNone |
| `$transition_duration-button_tertiary-border` | var(--semi-transition_duration-none) | transitionDurationButtonTertiaryBorder → theme.motion.transitionDurationNone |
| `$transition_function-button_tertiary-border` | var(--semi-transition_function-easeIn) | transitionFunctionButtonTertiaryBorder → theme.motion.transitionFunctionEaseIn |
| `$transition_delay-button_tertiary-border` | var(--semi-transition_delay-none) | transitionDelayButtonTertiaryBorder → theme.motion.transitionDelayNone |
| `$transition_duration-button_light-border` | var(--semi-transition_duration-none) | transitionDurationButtonLightBorder → theme.motion.transitionDurationNone |
| `$transition_function-button_light-border` | var(--semi-transition_function-easeIn) | transitionFunctionButtonLightBorder → theme.motion.transitionFunctionEaseIn |
| `$transition_delay-button_light-border` | var(--semi-transition_delay-none) | transitionDelayButtonLightBorder → theme.motion.transitionDelayNone |
| `$transition_duration-button_warning-border` | var(--semi-transition_duration-none) | transitionDurationButtonWarningBorder → theme.motion.transitionDurationNone |
| `$transition_function-button_warning-border` | var(--semi-transition_function-easeIn) | transitionFunctionButtonWarningBorder → theme.motion.transitionFunctionEaseIn |
| `$transition_delay-button_warning-border` | var(--semi-transition_delay-none) | transitionDelayButtonWarningBorder → theme.motion.transitionDelayNone |
| `$transition_duration-button_danger-border` | var(--semi-transition_duration-none) | transitionDurationButtonDangerBorder → theme.motion.transitionDurationNone |
| `$transition_function-button_danger-border` | var(--semi-transition_function-easeIn) | transitionFunctionButtonDangerBorder → theme.motion.transitionFunctionEaseIn |
| `$transition_delay-button_danger-border` | var(--semi-transition_delay-none) | transitionDelayButtonDangerBorder → theme.motion.transitionDelayNone |

**transform_scale 7**

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$transform_scale-button_primary` | var(--semi-transform_scale-none) | transformScaleButtonPrimary → theme.motion.transformScaleNone |
| `$transform_scale-button_secondary` | var(--semi-transform_scale-none) | transformScaleButtonSecondary → theme.motion.transformScaleNone |
| `$transform_scale-button_tertiary` | var(--semi-transform_scale-none) | transformScaleButtonTertiary → theme.motion.transformScaleNone |
| `$transform_scale-button_light` | var(--semi-transform_scale-none) | transformScaleButtonLight → theme.motion.transformScaleNone |
| `$transform_scale-button_warning` | var(--semi-transform_scale-none) | transformScaleButtonWarning → theme.motion.transformScaleNone |
| `$transform_scale-button_danger` | var(--semi-transform_scale-none) | transformScaleButtonDanger → theme.motion.transformScaleNone |
| `$transform_scale-button_borderless` | var(--semi-transform_scale-none) | transformScaleButtonBorderless → theme.motion.transformScaleNone |

**animation_duration 2（600/1600ms）**

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$animation_duration-button_icon_loading` | 600ms | animationDurationButtonIconLoading → const Duration(milliseconds: 600) |
| `$animation_duration-button_icon_customIcon_loading` | 1600ms | animationDurationButtonIconCustomIconLoading → const Duration(milliseconds: 1600) |

### widget 内部常量（21，不进主题，`_ButtonMetrics`）

| 常量 | Sass / 硬编码 | 值 | 用途 |
| --- | --- | --- | --- |
| `spinnerBoxSize` | `width: 16px` | 16 | iconButton.scss `&-loading` spinner 盒 |
| `shadow0Mixin` | `@include shadow-0` | - | button.scss 基规则 mixin |
| `shadow0` | `box-shadow: none` | none | shadow-0 mixin 本体（无阴影） |
| `whiteTextFill` | `rgba(var(--semi-white), 1)` | #FFFFFFFF | solid 文字共用白（5×text-default/hover/active 的解析 `theme.palette.white.toColor()` 留档） |
| `focusOutline` | `outline: $width-button-outline solid` | 2px | :focus-visible 轮廓；环宽取主题 `widthButtonOutline` |
| `contentClipText` | `background-clip: text` | - | colorful 文字渐变（ShaderMask） |
| `contentTransparentText` | `color: transparent` | - | 同上配套 |
| `loadingPointerEvents` | `pointer-events: none` | - | loading 指针拦截 |
| `loadingCursor` | `cursor: not-allowed` | - | disabled/loading 光标（forbidden） |
| `baseCursor` | `cursor: pointer` | - | 可用按钮光标 |
| `blockWidth` | `width: 100%` | - | block 拉宽 |
| `groupOutlineOverlapMargin` | `margin-right: -1 * $width-button_outline-border` | -1px | 组内 outline 重叠（取主题 `widthButtonOutlineBorder`） |
| `groupOutlineOverlapBorder` | `border-right-color: transparent` | - | 同上配套（见差异清单第 14 条） |
| `bottomPaddingQuirk` | `padding-bottom: $spacing-button_default-paddingTop` | - | default 档底 padding 读 top 变量（iconOnly default 同款 quirk 读 paddingRight） |
| `fontFamilyInherit` | `font-family: inherit` | - | 基规则 |
| `whiteSpaceNowrap` | `white-space: nowrap` | - | 基规则 |
| `userSelectNone` | `user-select: none` | - | 基规则 |
| `verticalAlignMiddle` | `vertical-align: middle` | - | 基规则 |
| `rotateKeyframes` | `rotate(360deg)` | - | spinner @keyframes 旋转 |
| `inlineFlexCenter` | `display: inline-flex` | - | 基规则 / with-icon |
| `loadingAnimationFillMode` | `animation-fill-mode: forwards` | - | spinner 动画填充 |

## 差异清单

- **htmlType/circle 不移植**：`htmlType` 是 HTML 原生 `type`（button/reset/submit）；`circle` 上游无任何 scss 规则、事实 no-op，均不移植。
- **无受控 loading**：上游 `loading` 即普通 prop（无受控/非受控之分），移植一致。
- **图标四 stop/两 stop 重染不移植**：SemiIcon 单色架构（同 Tag 边界），colorful 图标以 currentColor 呈现；7 条 cssVariables 由 `SemiButtonTokens` 承接（对照表见 colorful 节）。
- **SplitButtonGroup 未移植**：上游 4 条 `radius-button_splitButtonGroup_*` token 仅配置留存（主题字段存在、无消费组件）。
- **宽度保持**：无 icon → loading 增宽为上游原样行为（loading 走 IconButton 路径增开图标位 + 8 间距），移植如实；有 icon 时 spinner 原位替换不改宽度。
- **onPressed null 语义**：不可按（指针/键盘均不触发）但视觉不置 disabled（上游 `onClick` 默认 noop）；`Semantics.enabled` 仍为 true。
- **loading 键盘**：拦截限于指针（`pointer-events: none` 等价）；键盘 Enter/Space 在 loading 时仍触发 `onPressed`（上游原生 button 行为原样）。disabled 优先于 loading（无 spinner、禁用视觉）。
- **spinner 旋转时长**：上游 iconButton.scss 对 SpinIcon 与 `-loading-icon` 都套 600ms 旋转（1600ms token 声明未消费）；移植按 token 文档意图（"自定义指示器时旋转一周时长"）给 IconAILoading 1600ms。
- **spinner 选型条件**：上游 `colorful && theme!=solid || (theme==solid && type==tertiary)` 原样——solid+tertiary 即便非 colorful 也用 IconAILoading。
- **iconSize 生效**：上游 `iconSize`/`iconStyle` 声明后未应用（iconButton/index.tsx TODO），移植 `iconSize` 经 `SemiIconTheme` 生效。
- **状态字段消费差异**：solid 档 text-hover/active 与 border-hover/active 上游 scss 未消费（hover/active 只改背景），解析器按字段逐条取值（默认值相同无视觉差；theme 覆盖时与上游语义有差，如实记录）。`$color-button_secondary-border-default` 上游仅被 `outline-color` 引用（会被 focus outline 覆盖）。
- **danger 边框 hover quirk 保留**：`$color-button_danger-border-hover: var(--semi-color-danger)`（非 hover 色）。
- **padding 底部 quirk 保留**：default 档 `padding-bottom: $spacing-button_default-paddingTop`、iconOnly default `padding-bottom: $spacing-button_iconOnly_default-paddingRight`（small/large 用各自 -paddingBottom）。
- **group 分割线**：上游 `group-line` 的双层结构已完整复刻——外层 1px 全高色条（`group-line-{theme,type,-disabled}` class 级联）+ 内层 `::before` 1px×20 灰色刻线（恒 `$color-button_group-border-default`）；色条高度取相邻按钮较高者（上游 flex stretch 语义）。
- **group outline 重叠**：上游 `margin-right: -1px` + `border-right-color: transparent`；BoxDecoration 拒绝"非均匀 border + 圆角"，移植保留均匀 border（接缝由相邻按钮 z-order 覆盖，视觉一致）、负 margin 以 `_NegativeEndMargin`（布局宽度 -1px）表达；RTL 不镜像（上游 rtl.scss 未覆盖这两条物理声明）。
- **focus-visible 门控**：`_keyboardUsed` + 全局键盘模态追踪（任意按键置位、按下按钮清位），Tab 聚焦也显示焦点环（浏览器 :focus-visible 语义）；焦点环画在框外（spread shadow）。danger/warning 在 borderless/light 保留 primary 焦点色 quirk 不修正。
- **注入机制**：上游 `cloneElement` 只作用于直接子级；移植经 `SemiButtonScope`（InheritedWidget）注入，嵌套更深处的 `SemiButton` 也会读到组级值（范围更宽，如实记录）。分割线/首尾圆角按 `children` 列表位置判定（上游 `:first-child/:last-child` 含非按钮元素判定；列表首/末位非按钮时上游不圆角、移植同——圆角只挂在首末位 `_ButtonPosition` 上）。
- **noHorizontalPadding 语义**：上游按物理 `paddingLeft/Right` 清零；移植按起止边（`EdgeInsetsDirectional`，RTL 镜像）解释。group 内无效果（上游按钮级 padding 本为 0，同效）。
- **transition 三元组**：`AnimatedContainer` 消费 duration/function（默认均为 0ms，如实）；delay 无对应机制、字段留存文档。`transform_scale` 经 `SemiTransform` 施加（默认恒等）。
- **文字排版**：String child 渲染 `SemiText` 14/20/600（`font-button_*` 三档同值，取 typography token）；Widget child 原样放置不覆盖排版。CSS overflow 可见语义以 `OverflowBox` 复刻（文字缩放不报布局错误、固定高度不改）。
- **未移植 props**：`className`/`style`/`contentClassName`/`iconStyle`（Dart 侧外层包裹）、`onMouseDown`（无 DOM 事件对象）、受控语义相关（无）；`aria-label` → `semanticsLabel`、`aria-disabled` → `Semantics.enabled = !disabled`。
