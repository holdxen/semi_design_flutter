# Typography 组件颜色主题

`SemiTypographyThemeData` 是 19 个可空 Color 的不可变覆盖配置，字体度量继续使用 `SemiTypographyTokens`。不增加 CSS manifest 的 383 个变量，也不迁移 Button。

```dart
const app = SemiThemeData.light(
  components: SemiComponentThemes(
    typography: SemiTypographyThemeData(linkTextColor: Color(0xff006644)),
  ),
);
SemiTheme(
  data: app,
  child: const SemiTypographyTheme(
    data: SemiTypographyThemeData(markBackgroundColor: Color(0xffffeebb)),
    child: SemiText('局部标记，链接仍继承应用配置', mark: true),
  ),
);
final dark = app.copyWith(dark: true); // 保留 components
```

`SemiTypographyTheme.of(context)` 返回应用级与全部祖先局部补丁合并后的 overrides，不解析默认色；`maybeOf` 仅在既无 SemiTheme 也无局部主题时返回 null。组件统一调用 `SemiTypographyTheme.resolve(context)` 获取所有非空颜色，并订阅当前全局主题及所有祖先局部变化。最近局部非空值优先，其次祖先局部、当前最近 SemiTheme.components、当前全局 tokens 默认引用。跨 SemiTheme 边界保留局部补丁，但重新采用当前应用级 components；不会携带旧应用级默认值。InheritedTheme.capture 可捕获并重放局部主题。

构造的 null 表示未覆盖，默认引用始终读取当前全局 tokens，亮暗使用相同解析逻辑。copyWith 的 null 保留原覆盖，merge 仅应用非空补丁。恢复应用级默认可替换 `components.typography` 为新的空实例；恢复局部继承可替换该局部 data 为空实例或移除该层。局部 null 不能屏蔽祖先覆盖，需在祖先移除相应值；不提供单字段 null 清除 API，可重建配置保留其他字段。

颜色状态优先级为 type → code → link → disabled → 显式 TextStyle。disabled 普通文本使用 disabledTextColor；disabled 链接使用 linkDisabledColor，默认与正常链接相同，仍禁止点击、键盘及语义激活。focusBorder 始终读取全局 colorFocusBorder。code 背景及边框通过组件配置，mark 在非 code 时使用文字背景；显式 style.backgroundColor 只覆盖文字背景，不覆盖 code 外框。copied 两字段仅提供配置与 resolve，尚未实现 copyable。

所有字段来源均为 `packages/semi-foundation/typography/variables.scss`。

| Dart 字段 | Sass 变量 | 默认 CSS 引用 |
| --- | --- | --- |
| `defaultTextColor` | `$color-typography_default-text-default` | `var(--semi-color-text-0)` |
| `secondaryTextColor` | `$color-typography_secondary-text-default` | `var(--semi-color-text-1)` |
| `tertiaryTextColor` | `$color-typography_tertiary-text-default` | `var(--semi-color-text-2)` |
| `quaternaryTextColor` | `$color-typography_quaternary-text-default` | `var(--semi-color-text-3)` |
| `warningTextColor` | `$color-typography_warning-text-default` | `var(--semi-color-warning)` |
| `dangerTextColor` | `$color-typography_danger-text-default` | `var(--semi-color-danger)` |
| `successTextColor` | `$color-typography_success-text-default` | `var(--semi-color-success)` |
| `disabledTextColor` | `$color-typography_disabled-text-default` | `var(--semi-color-disabled-text)` |
| `markBackgroundColor` | `$color-typography_mark-bg-default` | `var(--semi-color-primary-light-default)` |
| `codeBackgroundColor` | `$color-typography_code-bg-default` | `var(--semi-color-fill-1)` |
| `codeTextColor` | `$color-typography_code-text-default` | `var(--semi-color-text-2)` |
| `linkTextColor` | `$color-typography_link-text-default` | `var(--semi-color-link)` |
| `linkVisitedColor` | `$color-typography_link-text-visited` | `var(--semi-color-link-visited)` |
| `linkHoverColor` | `$color-typography_link-text-hover` | `var(--semi-color-link-hover)` |
| `linkActiveColor` | `$color-typography_link-text-active` | `var(--semi-color-link-active)` |
| `linkDisabledColor` | `$color-typography_link-text-disabled` | `var(--semi-color-link)` |
| `copiedTextColor` | `$color-typography_copied-text-success` | `var(--semi-color-text-2)` |
| `copiedIconColor` | `$color-typography_copied-icon-success` | `var(--semi-color-success)` |
| `codeBorderColor` | `$color-typography_code-border-default` | `var(--semi-color-border)` |

## Sass typography metrics

All fields are nullable patches; non-null local fields inherit the remaining application fields. Global defaults resolve live on each build. Heading sizes come from global mixins, not component Sass variables. Explicit TextStyle merges last; line height is resolved pixels / resolved font size.

| Field | Type | Upstream default | Source |
|---|---|---|---|
| `titleFontWeight` | `FontWeight` | `$font-weight-bold` | `font-typography_title-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `linkFontWeight` | `FontWeight` | `$font-weight-bold` | `font-typography_link-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `strongFontWeight` | `FontWeight` | `$font-weight-bold` | `font-typography_strong-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `paragraphExtendedLineHeight` | `double` | `24px` | `font-typography_paragraph_extended-lineHeight` in packages/semi-foundation/typography/variables.scss |
| `normalTextRegularFontWeight` | `FontWeight` | `$font-weight-regular` | `font-typography_normalText-regular-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `smallTextRegularFontWeight` | `FontWeight` | `$font-weight-regular` | `font-typography_smallText-regular-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `normalParagraphRegularFontWeight` | `FontWeight` | `$font-weight-regular` | `font-typography_normalParagraph-regular-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `smallParagraphRegularFontWeight` | `FontWeight` | `$font-weight-regular` | `font-typography_smallParagraph-regular-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title1FontWeight` | `FontWeight` | `$font-typography_title-fontWeight` | `font-typography_title1-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title2FontWeight` | `FontWeight` | `$font-typography_title-fontWeight` | `font-typography_title2-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title3FontWeight` | `FontWeight` | `$font-typography_title-fontWeight` | `font-typography_title3-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title4FontWeight` | `FontWeight` | `$font-typography_title-fontWeight` | `font-typography_title4-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title5FontWeight` | `FontWeight` | `$font-typography_title-fontWeight` | `font-typography_title5-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title6FontWeight` | `FontWeight` | `$font-typography_title-fontWeight` | `font-typography_title6-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title1LightFontWeight` | `FontWeight` | `200` | `font-typography_title1-light-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title2LightFontWeight` | `FontWeight` | `200` | `font-typography_title2-light-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title3LightFontWeight` | `FontWeight` | `200` | `font-typography_title3-light-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title4LightFontWeight` | `FontWeight` | `200` | `font-typography_title4-light-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title5LightFontWeight` | `FontWeight` | `200` | `font-typography_title5-light-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title6LightFontWeight` | `FontWeight` | `200` | `font-typography_title6-light-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title1RegularFontWeight` | `FontWeight` | `400` | `font-typography_title1-regular-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title2RegularFontWeight` | `FontWeight` | `400` | `font-typography_title2-regular-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title3RegularFontWeight` | `FontWeight` | `400` | `font-typography_title3-regular-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title4RegularFontWeight` | `FontWeight` | `400` | `font-typography_title4-regular-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title5RegularFontWeight` | `FontWeight` | `400` | `font-typography_title5-regular-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title6RegularFontWeight` | `FontWeight` | `400` | `font-typography_title6-regular-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title1MediumFontWeight` | `FontWeight` | `500` | `font-typography_title1-medium-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title2MediumFontWeight` | `FontWeight` | `500` | `font-typography_title2-medium-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title3MediumFontWeight` | `FontWeight` | `500` | `font-typography_title3-medium-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title4MediumFontWeight` | `FontWeight` | `500` | `font-typography_title4-medium-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title5MediumFontWeight` | `FontWeight` | `500` | `font-typography_title5-medium-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title6MediumFontWeight` | `FontWeight` | `500` | `font-typography_title6-medium-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title1SemiboldFontWeight` | `FontWeight` | `600` | `font-typography_title1-semibold-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title2SemiboldFontWeight` | `FontWeight` | `600` | `font-typography_title2-semibold-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title3SemiboldFontWeight` | `FontWeight` | `600` | `font-typography_title3-semibold-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title4SemiboldFontWeight` | `FontWeight` | `600` | `font-typography_title4-semibold-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title5SemiboldFontWeight` | `FontWeight` | `600` | `font-typography_title5-semibold-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title6SemiboldFontWeight` | `FontWeight` | `600` | `font-typography_title6-semibold-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title1BoldFontWeight` | `FontWeight` | `700` | `font-typography_title1-bold-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title2BoldFontWeight` | `FontWeight` | `700` | `font-typography_title2-bold-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title3BoldFontWeight` | `FontWeight` | `700` | `font-typography_title3-bold-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title4BoldFontWeight` | `FontWeight` | `700` | `font-typography_title4-bold-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title5BoldFontWeight` | `FontWeight` | `700` | `font-typography_title5-bold-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `title6BoldFontWeight` | `FontWeight` | `700` | `font-typography_title6-bold-fontWeight` in packages/semi-foundation/typography/variables.scss |
| `iconPrefixMarginRight` | `double` | `4px` | `spacing-typography_iconPrefix-marginRight` in packages/semi-foundation/typography/variables.scss |
| `expandTextMarginLeft` | `double` | `8px` | `spacing-typography_expandText-marginLeft` in packages/semi-foundation/typography/variables.scss |
| `copyIconMarginLeft` | `double` | `4px` | `spacing-typography_copyIcon-marginLeft` in packages/semi-foundation/typography/variables.scss |
| `copyIconPadding` | `EdgeInsets` | `0` | `spacing-typography_copyIcon-padding` in packages/semi-foundation/typography/variables.scss |
| `titleH1Margin` | `EdgeInsets` | `0` | `spacing-typography_title_h1-margin` in packages/semi-foundation/typography/variables.scss |
| `titleH2Margin` | `EdgeInsets` | `0` | `spacing-typography_title_h2-margin` in packages/semi-foundation/typography/variables.scss |
| `titleH3Margin` | `EdgeInsets` | `0` | `spacing-typography_title_h3-margin` in packages/semi-foundation/typography/variables.scss |
| `titleH4Margin` | `EdgeInsets` | `0` | `spacing-typography_title_h4-margin` in packages/semi-foundation/typography/variables.scss |
| `titleH5Margin` | `EdgeInsets` | `0` | `spacing-typography_title_h5-margin` in packages/semi-foundation/typography/variables.scss |
| `titleH6Margin` | `EdgeInsets` | `0` | `spacing-typography_title_h6-margin` in packages/semi-foundation/typography/variables.scss |
| `titleParagraphMargin` | `EdgeInsets` | `0` | `spacing-typography_title_paragraph-margin` in packages/semi-foundation/typography/variables.scss |
| `codeBorderWidth` | `double` | `1px` | `width-typography_code-border` in packages/semi-foundation/typography/variables.scss |
| `linkBorderWidth` | `double` | `1px` | `width-typography_link-border` in packages/semi-foundation/typography/variables.scss |
| `codeBorderRadius` | `double` | `2px` | `radius-typography_code` in packages/semi-foundation/typography/variables.scss |
| `fontSizeRegular` | `double` | `global typography mixin` | `fontSizeRegular` in packages/semi-foundation/typography/typography.scss |
| `fontSizeSmall` | `double` | `global typography mixin` | `fontSizeSmall` in packages/semi-foundation/typography/typography.scss |
| `lineHeightRegular` | `double` | `global typography mixin` | `lineHeightRegular` in packages/semi-foundation/typography/typography.scss |
| `lineHeightSmall` | `double` | `global typography mixin` | `lineHeightSmall` in packages/semi-foundation/typography/typography.scss |
| `fontSizeHeading1` | `double` | `global typography mixin` | `fontSizeHeading1` in packages/semi-foundation/typography/typography.scss |
| `lineHeightHeading1` | `double` | `global typography mixin` | `lineHeightHeading1` in packages/semi-foundation/typography/typography.scss |
| `fontSizeHeading2` | `double` | `global typography mixin` | `fontSizeHeading2` in packages/semi-foundation/typography/typography.scss |
| `lineHeightHeading2` | `double` | `global typography mixin` | `lineHeightHeading2` in packages/semi-foundation/typography/typography.scss |
| `fontSizeHeading3` | `double` | `global typography mixin` | `fontSizeHeading3` in packages/semi-foundation/typography/typography.scss |
| `lineHeightHeading3` | `double` | `global typography mixin` | `lineHeightHeading3` in packages/semi-foundation/typography/typography.scss |
| `fontSizeHeading4` | `double` | `global typography mixin` | `fontSizeHeading4` in packages/semi-foundation/typography/typography.scss |
| `lineHeightHeading4` | `double` | `global typography mixin` | `lineHeightHeading4` in packages/semi-foundation/typography/typography.scss |
| `fontSizeHeading5` | `double` | `global typography mixin` | `fontSizeHeading5` in packages/semi-foundation/typography/typography.scss |
| `lineHeightHeading5` | `double` | `global typography mixin` | `lineHeightHeading5` in packages/semi-foundation/typography/typography.scss |
| `fontSizeHeading6` | `double` | `global typography mixin` | `fontSizeHeading6` in packages/semi-foundation/typography/typography.scss |
| `lineHeightHeading6` | `double` | `global typography mixin` | `lineHeightHeading6` in packages/semi-foundation/typography/typography.scss |
| `codePadding` | `EdgeInsets` | `2px 4px` | `$spacing-super-tight $spacing-extra-tight` in packages/semi-foundation/typography/typography.scss |

Copy/expand spacing and named heading weight variants remain resolved configuration. SemiParagraph consumes paragraph regular weights, extended line height and titleParagraphMargin; see [SemiParagraph](semi_paragraph.md).

```dart
SemiTypographyTheme(
  data: const SemiTypographyThemeData(fontSizeRegular: 18, codeBorderRadius: 6),
  child: SemiText("Local metrics", code: true),
)
```

应用级：`SemiThemeData.light(components: SemiComponentThemes(typography: SemiTypographyThemeData(fontSizeRegular: 18, lineHeightRegular: 26)))`。局部仅覆盖指定非空字段。58 个 Sass 变量：44 font（43 FontWeight、1 double）、11 spacing（8 EdgeInsets、3 double）、2 width double、1 radius double；另有 16 个字号/行高 double 和 codePadding EdgeInsets，共新增 75 字段。字号和行高实际定义于 packages/semi-theme-default/scss/_font.scss，字号再引用 variables.scss；codePadding 是 typography.scss 消费的 `$spacing-super-tight $spacing-extra-tight`（2px 4px）。标题命名字重变体为字面量 200/400/500/600/700；默认 title1..6 跟随 titleFontWeight，再回退 global bold。

### 变量计数与验收边界

计数基于上游 `packages/semi-foundation/typography/variables.scss`，先剔除 `//` 和 `/* ... */` 注释，再匹配行首 Sass 声明。44 个 font 声明中，43 个 FontWeight = 第 25–27 行的通用字重 3 个 + 第 29–32 行正文/段落字重 4 个 + 第 34–39 行六级标题默认字重 6 个 + 第 44–77 行五组标题变体 30 个；另 1 个为第 28 行 extended paragraph lineHeight。11 个 spacing 在第 82–92 行，2 个 width 在第 94–95 行，1 个 radius 在第 97 行。以上均为实际声明，不包含注释或测试字符串。

Python 验收从真实上游文件检查 58 项名称、默认值、字段类型和 `///` 来源；可用 `SEMI_DESIGN_SOURCE` 指定上游仓库。Flutter 测试独立断言全部默认值，并验证 global 实时依赖、应用/嵌套局部覆盖、同亮度度量变化通知、code/icon 布局、链接装饰及六级标题 margin/字重。段落相关字段由公开 SemiParagraph 组件消费，覆盖 normal/small/inherit、extended 行高和 margin。复制、展开与命名字重变体同样不增加新的交互/API。
