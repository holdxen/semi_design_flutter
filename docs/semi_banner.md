# SemiBanner

横幅（上游 Semi Banner 全件移植）：四种 type（info/success/danger/warning，缺省 info）语义色背景 + 类型图标 + 标题（`heading={5}`）+ 描述（`Typography.Paragraph`）+ extra（上游 `children`）+ 可关闭（`theme="borderless" size="small" type="tertiary"` 图标钮）。`fullMode` 缺省 true（`-full`：内容组 `justify-content: center`/`align-items: center`）；false 为 `-in-container`（圆角 + 标题描述 2px 间距 + `bordered` 描边，bordered 仅此模式生效）。关闭即隐藏（非受控自动隐藏，受控只回调），RTL 镜像。主题对账 **22 = 22 FIELDS + 0 MOTION + 0 INTERNAL**（variables.scss 22 声明：color 12、spacing 6、width 2、height 1、radius 1；无 animation.scss；`$module` 胶水与 rtl.scss 不计，carousel `40 = 34 + 6 + 0`、modal `81 = 63 + 18 + 0` 先例）；★**0 死变量**（banner.scss/rtl.scss 逐条消费）。

## API

`SemiBanner({type: info, title, description, icon, showIcon: true, closeIcon, closable: true, extra, fullMode: true, bordered: false, visible, onClose, closeSemanticsLabel})`。

type `SemiBannerType`（info/success/danger/warning，缺省 info）。title/description `Object?`：String/num 走 `Typography.Title heading={5}` / `Typography.Paragraph`（`margin: 0`），Widget 原样；`title || title === 0` 语义照抄——数字 0 渲染、空串 falsy 不渲染。icon `Widget?`（类型默认图标替换）+ `showIcon`（上游 `icon: null` 显式隐藏）。closeIcon `Widget?`（缺省 `IconClose`）+ `closable`（上游 `closeIcon: null` 隐藏关闭钮）。extra `Widget?`（上游 `children`，类名 `-extra`）。visible `bool?`（null 非受控：关闭自动隐藏；受控只回调，转非受控保留最近受控值）。onClose `VoidCallback?`（纯通知，无取消语义）。closeSemanticsLabel 缺省 '关闭'（上游 locale `Banner.close`）。

## 行为

### 关闭

关闭钮触发 `notifyClose(e)` + `setVisible()`（foundation.ts `removeBanner`；`remove` 里 `e.stopPropagation()` 不适用——Flutter 无事件冒泡）。非受控隐藏自身，受控由父级更新 `visible`。

### 视觉

- 结构：root（padding 12）> content-wrapper（Row）> content（flex:1）> [icon（右距 12）, content-body（title + description）] + closer（左距 12、24x24）；extra 行 `margin-top: 8`。
- fullMode：icon/body 组水平居中、垂直居中（`justify-content: center`/`align-items: center`），body 自然宽度（CSS shrink-to-fit：最宽行封顶可用宽，loose 约束自然收缩等价）；in-container：body `flex: 1` 左对齐、图标与首行顶对齐。
- 标题与描述间距 `2px` 仅 `-in-container`（`.title + .description`）；fullMode 无间距（`margin: 0`）。
- 背景/文本/描边按 type 取 `*-light-default` 背景 + 语义色文本/描边；`bordered` 描边 1px 仅 `!fullMode`（`!fullMode && bordered`）；圆角 `$radius-banner` 仅 in-container。
- 语义：`role="alert"` → `Semantics(liveRegion: true)`；关闭钮语义标签 '关闭'。

### RTL

rtl.scss 的关闭钮 `margin-left: 0`/`margin-right: …` 与 icon `margin-right: 0`/`margin-left: …` 由 EdgeInsetsDirectional 自动镜像。

## 主题（22 对账）

来源 packages/semi-foundation/banner/variables.scss（22 声明，无 animation.scss）。对账 **22 = 22 FIELDS + 0 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表）。★**0 死变量**。全局 token 解析：`var(--semi-color-{info,warning,success,danger}-light-default)` → `theme.colors.color*LightDefault`、`var(--semi-color-{info,warning,success,danger})` → `theme.colors.color*`；`var(--semi-border-radius-small)` → `theme.radius.borderRadiusSmall.value`（generate_button 先例）；引用 token：`$spacing-base-tight` → 12、`$spacing-tight` → 8（generate_modal 先例）。类型覆盖：**12 Color + 10 double = 22 FIELDS**。解析列即 `SemiBannerThemeData.resolve` 默认表达式。

### A. Sass 声明映射（22 FIELDS）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-banner_info-bg-default: var(--semi-color-info-light-default)` | `colorBannerInfoBgDefault` | `theme.colors.colorInfoLightDefault` |
| `$color-banner_info-text-default: var(--semi-color-info)` | `colorBannerInfoTextDefault` | `theme.colors.colorInfo` |
| `$color-banner_info-border-default: var(--semi-color-info)` | `colorBannerInfoBorderDefault` | `theme.colors.colorInfo` |
| `$color-banner_warning-bg-default: var(--semi-color-warning-light-default)` | `colorBannerWarningBgDefault` | `theme.colors.colorWarningLightDefault` |
| `$color-banner_warning-text-default: var(--semi-color-warning)` | `colorBannerWarningTextDefault` | `theme.colors.colorWarning` |
| `$color-banner_warning-border-default: var(--semi-color-warning)` | `colorBannerWarningBorderDefault` | `theme.colors.colorWarning` |
| `$color-banner_success-bg-default: var(--semi-color-success-light-default)` | `colorBannerSuccessBgDefault` | `theme.colors.colorSuccessLightDefault` |
| `$color-banner_success-text-default: var(--semi-color-success)` | `colorBannerSuccessTextDefault` | `theme.colors.colorSuccess` |
| `$color-banner_success-border-default: var(--semi-color-success)` | `colorBannerSuccessBorderDefault` | `theme.colors.colorSuccess` |
| `$color-banner_danger-bg-default: var(--semi-color-danger-light-default)` | `colorBannerDangerBgDefault` | `theme.colors.colorDangerLightDefault` |
| `$color-banner_danger-text-default: var(--semi-color-danger)` | `colorBannerDangerTextDefault` | `theme.colors.colorDanger` |
| `$color-banner_danger-border-default: var(--semi-color-danger)` | `colorBannerDangerBorderDefault` | `theme.colors.colorDanger` |
| `$radius-banner: var(--semi-border-radius-small)` | `radiusBanner` | `theme.radius.borderRadiusSmall.value` |
| `$spacing-banner_closeBtn-marginLeft: $spacing-base-tight` | `spacingBannerCloseBtnMarginLeft` | `12` |
| `$spacing-banner_extra-marginTop: $spacing-tight` | `spacingBannerExtraMarginTop` | `8`（★注释照抄 `// 关闭按钮顶边距`——实为 extra 顶边距，复制粘贴错位） |
| `$spacing-banner_icon-marginRight: $spacing-base-tight` | `spacingBannerIconMarginRight` | `12`（★注释照抄 `// 关闭按钮顶边距`——实为 icon 右边距，复制粘贴错位） |
| `$spacing-banner-paddingX: $spacing-base-tight` | `spacingBannerPaddingX` | `12` |
| `$spacing-banner-paddingY: $spacing-base-tight` | `spacingBannerPaddingY` | `12` |
| `$spacing-banner_title_description-marginTop: 2px` | `spacingBannerTitleDescriptionMarginTop` | `2`（仅 in-container 消费） |
| `$height-banner_closeBtn: 24px` | `heightBannerCloseBtn` | `24` |
| `$width-banner_closeBtn: 24px` | `widthBannerCloseBtn` | `24` |
| `$width-banner-border: 1px` | `widthBannerBorder` | `1`（仅 `!fullMode && bordered` 消费） |

★quirk 照抄：`$spacing-banner_extra-marginTop` 与 `$spacing-banner_icon-marginRight` 的行尾注释都写成 `// 关闭按钮顶边距`（复制粘贴错位，声明与使用处不一致——注释字面照抄）。

### B. HARDCODES 另列（widget 文件头注释 / 调用点，源内含原始片段）

| 上游片段 | 说明 |
|---|---|
| constants.ts `TYPE: ['info', 'success', 'danger', 'warning']` | 对外枚举 |
| defaultProps `type: 'info'` / `fullMode: true` | 缺省类型/模式 |
| `theme="borderless"` `size="small"` `type="tertiary"` | 关闭钮形态 |
| `IconClose` | 默认关闭图标 |
| `IconAlertTriangle` / `IconTickCircle` / `IconInfoCircle` / `IconAlertCircle` | 类型图标（warning/success/info/danger） |
| `size="large"` | 类型图标 20x20 |
| `heading={5}` | 标题 Typography.Title 五级 |
| `Typography.Paragraph` + `margin: 0` | 描述段落（banner.scss:16 覆写段落外边距） |
| `role="alert"` | live region 语义 |
| `locale?.close` | 关闭钮 aria-label（'关闭'） |
| `title \|\| title === 0` / `children \|\| children === 0` | 数字 0 渲染、空串不渲染 |
| `e.stopPropagation()` | 关闭不冒泡（Flutter 无冒泡，不适用） |
| `notifyClose(e)` + `setVisible()` | foundation.ts removeBanner |
| `'target' has been deprecated` | 已废弃 prop 警告（无对应参数） |
| `!fullMode && bordered` | 描边门槛 |
| `justify-content: center` / `align-items: center` | fullMode 内容组布局 |
| `.#{$module}-title + .#{$module}-description` | 标题描述 2px 间距（仅 in-container） |
| rtl.scss `margin-left: 0` / `margin-right: $spacing-banner_closeBtn-marginLeft` | 关闭钮镜像（icon 右边距同理） |

重新生成独立主题：`python3 tool/generate_banner.py`（包含 dart format）；对账校验 `python3 tool/test_generate_banner.py`。

## 差异清单

- **title/description**：上游 ReactNode → `Object?`（String/num 走 Typography，Widget 原样）。
- **icon/closeIcon 三态**：上游 `icon: null`/`closeIcon: null` 隐藏 → `showIcon`/`closable` 显式布尔。
- **onClose**：上游 `(e: MouseEvent)`（带 stopPropagation）→ `VoidCallback`（无冒泡机制）。
- **受控 visible**：上游无此参数（关闭后内部隐藏）→ 按 SemiTag 约定补 `visible`（受控只回调）。
- **未移植 API**：`className`/`style`（外层布局承担）、`target`（已废弃，仅留警告锚点）。
- **fullMode body 自然宽度**：CSS shrink-to-fit（max-content 封顶可用宽）→ loose 约束下 Text/Column 自然收缩（等价）。
- **RTL**：rtl.scss 边距镜像 → EdgeInsetsDirectional 自动翻转（物理实现等价）。
- **关闭钮**：上游 IconButton borderless/small/tertiary → `SemiButton` 同参形态（24x24 由主题尺寸约束）。

## 用法

```dart
SemiBanner(
  type: SemiBannerType.warning,
  title: '离线模式下无法保存设置',
  description: '请检查网络连接后重试。',
  onClose: () => print('closed'),
)
```

```dart
SemiBanner(
  fullMode: false,
  bordered: true,
  title: '新版本已发布',
  extra: Row(children: [
    SemiButton('立即更新', onPressed: () {}),
    SemiButton('稍后', variant: SemiButtonVariant.borderless, onPressed: () {}),
  ]),
)
```
