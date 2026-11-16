# SemiBadge

徽标（上游 Semi Badge 全件移植）：数字/文本/点状/自定义角标——包裹 child 四角锚定悬浮（`transform: translate(±50%, ±50%)`），无 child 独立展示（`-block`）。显隐判定照搬 `count !== null && typeof count !== 'undefined'`（null/undefined 无盒；★空串照旧出空胶囊、min-width 18 兜底）；`dot` 优先掩蔽内容（`dot ? null : content`，dot 与 custom 同时给时只出点）。count 为 num 按 `overflowCount && overflowCount < count` 溢出为 `${overflowCount}+`（★overflowCount 0 等 falsy 不溢出；整数值显示不带 `.0`——JS String(N) 语义归一）、String 原样、Widget 自定义（custom——`isNumber(count) || isString(count)` 取反；不挂 `-{type}`/`-{theme}` 类，内容自带样式）。色槽 6 类型（primary/secondary/tertiary/danger/warning/success，缺省 primary）× 3 填充（solid 换底、light 换底+换字、inverted 只换字留 default 底；缺省 solid）；描边恒 `$color-badge_default-border-default` 1px、点 8×8 正圆（`$radius-badge_dot` 50% 百分比半径）、count 18 高胶囊（`border-radius: $height-badge_count * 0.5`、`@include font-size-small` 12px/16px + `font-weight: $font-weight-regular`、`text-align: center`）。缺省锚角随方向（`direction === 'rtl' ? 'leftTop' : 'rightTop'`），显式 position 为物理锚角不随 RTL 翻。主题对账 **37 = 37 FIELDS + 0 MOTION + 0 INTERNAL**（variables.scss 37 声明：color 28、width 2、height 2、radius 1、spacing 2、z 2；无 animation.scss；`$module` 胶水与 rtl.scss 不计，banner `22 = 22 FIELDS + 0 MOTION + 0 INTERNAL` 先例）；其中 **2 条死 FIELDS**（死变量留档不消费）+ **1 条 z FIELDS**（`$z-badge`，CSS z-index 无 Flutter 对应——留档不消费）。

## API

`SemiBadge({count, dot: false, type: primary, variant: solid, position, overflowCount, child, onTap})`。

count `Object?`：num（按 overflowCount 溢出格式化）、String（原样）、Widget（custom，自带样式）；null 且非 dot 无徽标盒。dot `bool` 缺省 false。type `SemiBadgeType`（primary/secondary/tertiary/danger/warning/success，缺省 primary）。variant `SemiBadgeVariant`（solid/light/inverted，缺省 solid；上游 `theme`，同 `SemiButtonVariant` 更名先例）。position `SemiBadgePosition?`（leftTop/leftBottom/rightTop/rightBottom；null 随方向缺省——ltr → rightTop、rtl → leftTop；仅 child 存在时锚定）。overflowCount `num?`（溢出上限）。child `Widget?`（被包裹内容；null 独立展示）。onTap `VoidCallback?`（根 span `onClick` 透传）。

## 行为

### 计数与显隐

showBadge = `count !== null && typeof count !== 'undefined'`：null/undefined 不出盒（上游零尺寸 span 等价），数字 0 出 '0'，空串出空胶囊（`-count` 盒 + min-width 18）。custom（Widget count）出 `-custom`：内容原样、不吞 type/variant 色。dot 覆盖内容显示。溢出格式 `overflowCount && overflowCount < count` → `${overflowCount}+`（★0 falsy 不溢出；负数 truthy 照溢出）；num 显示按 JS String(N) 语义（5.0 → '5'、5.5 → '5.5'）。

### 定位与 RTL

包裹 child 时根 `position: relative`（Stack 等价）+ 四角锚定：`top/right/bottom/left: 0` + `transform: translate(±50%, ±50%)`（FractionalTranslation 等价，`Clip.none` 保留出角悬浮）——盒中心正落角点。缺省锚角 `direction === 'rtl' ? 'leftTop' : 'rightTop'`；显式 position 为物理锚角（CSS top/right/left/bottom 原语），RTL 不镜像（rtl.scss 只 `direction: rtl`）。无 child 走 `-block`（`position: static`）独立展示。

### 视觉

- `-dot`：8×8（`$width-badge_dot`×`$height-badge_dot`）、圆角 `$radius-badge_dot`（50% → `size * value / 100` = 4 = 正圆）、描边 1px。
- `-count`：高 18、最小宽 18（`box-sizing: border-box` 含描边）、胶囊半径 `height * 0.5`、padding 0/4、`text-align: center`；文字 `@include font-size-small`（12px/16px）+ `font-weight: $font-weight-regular`。
- 色槽：solid → `color-badge_{type}_solid-bg-default` 换底（字留 default）；light → `color-badge_{type}_light-bg-default` 换底 + `color-badge_{type}_light-text-default` 换字；inverted → `color-badge_{type}_inverted-text-default` 只换字（底留 `color-badge_default-bg-default`）。描边恒 `color-badge_default-border-default`。custom 不吃任何槽。

## 主题（37 对账）

来源 packages/semi-foundation/badge/variables.scss（37 声明行 / 37 唯一名——color 28、width 2、height 2、radius 1、spacing 2、z 2；无重复、无 animation.scss）。对账 **37 = 37 FIELDS + 0 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表；`$module: #{$prefix}-badge` 类名胶水与 rtl.scss 不计）。**2 条死 FIELDS**（死变量留档不消费：落 theme + `# dead variable (上游未消费)` + 本表「（上游未消费）」+ widget assertNotIn）：`$color-badge_default_light-bg-default`（`-light` 覆盖只按 type 取 `$color-badge_{type}_light-bg-default`，无 default 通道）、`$z-badge_light-bg`（`-light-bg` 浅色背景 z-index 无使用处）；**1 条 z FIELDS** `$z-badge` 标注「留档不消费」（上游 badge.scss:16/27 消费，CSS z-index 无 Flutter 对应——徽标以尾位 Stack 子置顶，tag_input `z-tagInput_drag_item_move` 先例）。全局 token 解析：`var(--semi-color-bg-1)` → `theme.colors.colorBg1`、`var(--semi-color-bg-2)` → `theme.colors.colorBg2`、`var(--semi-color-primary)` → `theme.colors.colorPrimary`、`var(--semi-color-primary-light-default)` → `theme.colors.colorPrimaryLightDefault`（secondary/tertiary/danger/warning/success 同型）、`var(--semi-border-radius-circle)` → `theme.radius.borderRadiusCircle.value`（= 50，百分比值——消费按 `size * value / 100`，steps 先例）。类型覆盖：**28 Color + 9 double = 37 FIELDS**。解析列即 `SemiBadgeThemeData.resolve` 默认表达式。

### A. Sass 声明映射（37 FIELDS）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-badge_default-border-default: var(--semi-color-bg-1)` | `colorBadgeDefaultBorderDefault` | `theme.colors.colorBg1`（描边，恒生效） |
| `$color-badge_default-bg-default: var(--semi-color-bg-1)` | `colorBadgeDefaultBgDefault` | `theme.colors.colorBg1`（基础底——inverted 底槽） |
| `$color-badge_default_light-bg-default: var(--semi-color-bg-2)` | `colorBadgeDefaultLightBgDefault` | `theme.colors.colorBg2`（（上游未消费）`-light` 只按 type 取 `_light-bg-default`；widget 不消费本字段） |
| `$color-badge_default-text-default: var(--semi-color-bg-2)` | `colorBadgeDefaultTextDefault` | `theme.colors.colorBg2`（count 文字默认——solid 底上的浅字） |
| `$color-badge_primary_solid-bg-default: var(--semi-color-primary)` | `colorBadgePrimarySolidBgDefault` | `theme.colors.colorPrimary` |
| `$color-badge_primary_light-bg-default: var(--semi-color-primary-light-default)` | `colorBadgePrimaryLightBgDefault` | `theme.colors.colorPrimaryLightDefault` |
| `$color-badge_primary_light-text-default: var(--semi-color-primary)` | `colorBadgePrimaryLightTextDefault` | `theme.colors.colorPrimary` |
| `$color-badge_primary_inverted-text-default: var(--semi-color-primary)` | `colorBadgePrimaryInvertedTextDefault` | `theme.colors.colorPrimary` |
| `$color-badge_secondary_solid-bg-default: var(--semi-color-secondary)` | `colorBadgeSecondarySolidBgDefault` | `theme.colors.colorSecondary` |
| `$color-badge_secondary_light-bg-default: var(--semi-color-secondary-light-default)` | `colorBadgeSecondaryLightBgDefault` | `theme.colors.colorSecondaryLightDefault` |
| `$color-badge_secondary_light-text-default: var(--semi-color-secondary)` | `colorBadgeSecondaryLightTextDefault` | `theme.colors.colorSecondary` |
| `$color-badge_secondary_inverted-text-default: var(--semi-color-secondary)` | `colorBadgeSecondaryInvertedTextDefault` | `theme.colors.colorSecondary` |
| `$color-badge_tertiary_solid-bg-default: var(--semi-color-tertiary)` | `colorBadgeTertiarySolidBgDefault` | `theme.colors.colorTertiary` |
| `$color-badge_tertiary_light-bg-default: var(--semi-color-tertiary-light-default)` | `colorBadgeTertiaryLightBgDefault` | `theme.colors.colorTertiaryLightDefault` |
| `$color-badge_tertiary_light-text-default: var(--semi-color-tertiary)` | `colorBadgeTertiaryLightTextDefault` | `theme.colors.colorTertiary` |
| `$color-badge_tertiary_inverted-text-default: var(--semi-color-tertiary)` | `colorBadgeTertiaryInvertedTextDefault` | `theme.colors.colorTertiary` |
| `$color-badge_danger_solid-bg-default: var(--semi-color-danger)` | `colorBadgeDangerSolidBgDefault` | `theme.colors.colorDanger` |
| `$color-badge_danger_light-bg-default: var(--semi-color-danger-light-default)` | `colorBadgeDangerLightBgDefault` | `theme.colors.colorDangerLightDefault` |
| `$color-badge_danger_light-text-default: var(--semi-color-danger)` | `colorBadgeDangerLightTextDefault` | `theme.colors.colorDanger` |
| `$color-badge_danger_inverted-text-default: var(--semi-color-danger)` | `colorBadgeDangerInvertedTextDefault` | `theme.colors.colorDanger` |
| `$color-badge_warning_solid-bg-default: var(--semi-color-warning)` | `colorBadgeWarningSolidBgDefault` | `theme.colors.colorWarning` |
| `$color-badge_warning_light-bg-default: var(--semi-color-warning-light-default)` | `colorBadgeWarningLightBgDefault` | `theme.colors.colorWarningLightDefault` |
| `$color-badge_warning_light-text-default: var(--semi-color-warning)` | `colorBadgeWarningLightTextDefault` | `theme.colors.colorWarning` |
| `$color-badge_warning_inverted-text-default: var(--semi-color-warning)` | `colorBadgeWarningInvertedTextDefault` | `theme.colors.colorWarning` |
| `$color-badge_success_solid-bg-default: var(--semi-color-success)` | `colorBadgeSuccessSolidBgDefault` | `theme.colors.colorSuccess` |
| `$color-badge_success_light-bg-default: var(--semi-color-success-light-default)` | `colorBadgeSuccessLightBgDefault` | `theme.colors.colorSuccessLightDefault` |
| `$color-badge_success_light-text-default: var(--semi-color-success)` | `colorBadgeSuccessLightTextDefault` | `theme.colors.colorSuccess` |
| `$color-badge_success_inverted-text-default: var(--semi-color-success)` | `colorBadgeSuccessInvertedTextDefault` | `theme.colors.colorSuccess` |
| `$width-badge_dot: 8px` | `widthBadgeDot` | `8`（点宽） |
| `$height-badge_dot: 8px` | `heightBadgeDot` | `8`（点高） |
| `$radius-badge_dot: var(--semi-border-radius-circle)` | `radiusBadgeDot` | `theme.radius.borderRadiusCircle.value`（= 50，百分比值——消费按 `size * value / 100`，steps 先例；8×50/100 = 4 = 正圆） |
| `$height-badge_count: 18px` | `heightBadgeCount` | `18`（count 高兼最小宽；胶囊半径 `border-radius: $height-badge_count * 0.5` 另列） |
| `$spacing-badge_count-paddingY: 0px` | `spacingBadgeCountPaddingY` | `0`（0 值字段照用即消费） |
| `$spacing-badge_count-paddingX: 4px` | `spacingBadgeCountPaddingX` | `4` |
| `$width-badge-border: 1px` | `widthBadgeBorder` | `1`（描边宽，dot/count 同用） |
| `$z-badge: 1` | `zBadge` | `1`（CSS z-index 无 Flutter 对应——徽标以尾位 Stack 子置顶，字段留档不消费；上游 badge.scss:16/27 消费） |
| `$z-badge_light-bg: -1` | `zBadgeLightBg` | `-1`（（上游未消费）`-light-bg` 浅色背景 z-index 无使用处；widget 不消费本字段） |

### B. HARDCODES 另列（widget 文件头注释 / 调用点，源内含原始片段）

| 上游片段 | 落点 |
|---|---|
| `TYPE_SET: ['success', 'primary', 'secondary', 'tertiary', 'warning', 'danger']` | `SemiBadgeType` 枚举（constants.ts strings） |
| `THEME_SET: ['solid', 'light', 'inverted']` | `SemiBadgeVariant` 枚举（constants.ts strings） |
| `POS_SET: ['leftTop', 'leftBottom', 'rightTop', 'rightBottom']` | `SemiBadgePosition` 枚举（constants.ts strings） |
| `type: 'primary'` | 枚举缺省（index.tsx defaultProps） |
| `theme: 'solid'` | variant 枚举缺省（index.tsx defaultProps） |
| `direction === 'rtl' ? 'leftTop' : 'rightTop'` | 缺省锚角随方向（index.tsx render） |
| `isNumber(count) || isString(count)` | custom 判定取反（index.tsx render） |
| `count !== null && typeof count !== 'undefined'` | showBadge 显隐判定（index.tsx render） |
| `overflowCount && overflowCount < count` | 溢出门槛（★0 falsy 不溢出） |
| `` `${overflowCount}+` `` | 溢出格式（integral 归一后拼接） |
| `@include font-size-small` | count 字号 12px/16px（badge.scss `-count`） |
| `font-weight: $font-weight-regular` | count 字重 w400（badge.scss `-count`） |
| `border-radius: $height-badge_count * 0.5` | count 胶囊半径 9（badge.scss `-count`） |
| `text-align: center` | count 文字居中（Alignment.center 等价） |
| `box-sizing: border-box` | 18 高含 1px 描边（Flutter 装饰边框内含等价） |
| `display: flex` | custom 盒原样铺开（badge.scss `-custom`） |
| `position: relative` | 根定位上下文（Stack 等价，badge.scss 根） |
| `position: static` | `-block` 独立展示（无 child 直出盒） |
| `transform: translate(50%, -50%)` | rightTop 偏移（FractionalTranslation Offset(0.5, -0.5)） |
| `transform: translate(50%, 50%)` | rightBottom 偏移（Offset(0.5, 0.5)） |
| `transform: translate(-50%, -50%)` | leftTop 偏移（Offset(-0.5, -0.5)） |
| `transform: translate(-50%, 50%)` | leftBottom 偏移（Offset(-0.5, 0.5)） |
| `direction: rtl` | rtl.scss 根方向（Directionality 自然覆盖） |

## 差异清单

★照搬留档（quirk 原样）：
1. **overflowCount 0 不溢出**：`overflowCount && overflowCount < count` 的 JS falsy 语义照搬（0/undefined 均出全量）；负数 truthy 照溢出为 `${overflowCount}+`。
2. **空串 count 出空胶囊**：`count !== null && typeof count !== 'undefined'`——空串仍是 showBadge，`-count` 盒 + min-width 18 兜底。
3. **dot 优先掩蔽**：`dot ? null : content`——dot 与 Widget count 同时给时只出点、custom 内容不渲染。
4. **custom 不吃色槽**：`!custom` 类名门槛——`-{type}`/`-{theme}` 只挂 num/String 徽标，custom 内容自带样式。
5. **数字 0 渲染**：`count: 0` 出 '0'（showBadge 判定不含 falsy 收敛）。
6. **显式 position 不随 RTL 翻**：CSS top/right/left/bottom 物理锚角照搬；仅缺省值随方向（`direction === 'rtl' ? 'leftTop' : 'rightTop'`）。
7. **整数归一**：num 显示按 JS String(N) 语义（5.0 → '5'）——Dart num.toString 的 `.0` 差异补偿，5.5 等非整数值原样。

偏差/裁剪：
8. **onClick 折叠为 `onTap`**（根 span 透传；Flutter 无冒泡，子级手势在手势竞技场优先）；**onMouseEnter/onMouseLeave 未移植**（无 hover 视觉语义）。
9. **style/countStyle、className/countClassName 未移植**（CSSProperties 类名透传）：徽标盒样式走 `SemiBadgeThemeData` 全局/局部主题。
10. **`box-sizing: border-box`/`position: relative|static`/`display: flex` 布局语义**由 Flutter 盒模型 + Stack/独立盒等价替代（B 表留档）。
11. **`$z-badge` z-index** 由 Stack 尾位置顶等价替代（字段留档不消费，tag_input 先例）；`$z-badge_light-bg` 上游即死（死变量留档不消费）。
12. **无动画/无 Tooltip 联动**：上游即无（照搬不加戏）。

## 用法

```dart
// 数字角标（溢出成 99+）
SemiBadge(count: 120, overflowCount: 99, child: SemiIcon(SemiIcons.bell));
// 红点
SemiBadge(dot: true, type: SemiBadgeType.danger, child: SemiIcon(SemiIcons.user));
// 自定义内容（自带样式）
SemiBadge(count: Text('促'), variant: SemiBadgeVariant.light, child: card);
// 独立展示（无 child）
SemiBadge(count: 12);
// 主题覆盖
SemiTheme(
  data: SemiThemeData.light(components: SemiComponentThemes(
    badge: SemiBadgeThemeData(colorBadgeDangerSolidBgDefault: Color(0xff123456)),
  )),
  child: SemiBadge(count: 1, type: SemiBadgeType.danger, child: child),
);
```
