# SemiTitle

`SemiTitle` 对应 Semi React `Typography.Title`，使用 `SemiTheme`，无需 MaterialApp。

```dart
const SemiTitle('标题', heading: 2, weight: FontWeight.w500);
```

heading 默认 1，必须为 1..6。字号/行高分别为 32/44、28/40、24/32、20/28、18/24、16/22（逻辑像素，随系统文字缩放）。默认字重 w600，标题无额外外边距。

上游来源：`packages/semi-ui/typography/title.tsx`、`base.tsx`、`interface.ts`；`packages/semi-foundation/typography/typography.scss`、`variables.scss`；字号及行高来源 `packages/semi-theme-default/scss/_font.scss` 和 `variables.scss`。

| React weight | Flutter weight |
| --- | --- |
| light / 200 | FontWeight.w200 |
| regular / 400 | FontWeight.w400 |
| medium / 500 | FontWeight.w500 |
| semibold / 600 | FontWeight.w600 |
| bold / 700 | FontWeight.w700 |

weight 使用与 SemiText 一致的 `FontWeight?`，其他整百数字可对应 w100..w900；不接受任意数字或命名字串。优先级为 `style.fontWeight > weight > 默认 w600`。strong 表示 w600 强调，标题本身已默认 w600；显式 weight 优先于 strong。style 最后合并，可以覆盖字号、行高、颜色、装饰和禁用颜色。

公共参数：data、heading、type（SemiTextType 七种）、weight、strong、disabled、mark、underline、delete、style、link（SemiTextLink）、textAlign、textDirection、softWrap、maxLines、overflow、semanticsLabel、key。支持 const。文字颜色、标记、装饰和链接交互直接复用 SemiText；链接默认由调用方在 onTap 中处理目标，visited 受控，禁用时不可激活。链接下划线同 SemiText，仅在启用且 hover/pressed 时展示。

语义使用 header，正文或自定义 semanticsLabel 只朗读一次；链接保留 link、enabled 和点击动作。heading 不映射 Web DOM 或额外声明语义等级。宿主需提供 Directionality，可提供 DefaultTextStyle/MediaQuery；颜色由 SemiTheme 提供并响应更新。

有限宽度下使用 maxLines 和 TextOverflow.ellipsis 实现尾部省略，支持中文和 RTL。与 SemiText 首版一致，仅接受字符串；暂不支持复制、中间省略、展开、后缀、溢出 tooltip、任意 children 或自定义 HTML component。Title 不增加 code/icon API。旧的未导出 Title 占位保持原状，公共导出仅新增 SemiTitle，避免与 Flutter Title 重名。

## 排版主题

`SemiThemeData.typography` 使用强类型不可变 `SemiTypographyTokens`。默认字体为 Inter，fallback 按上游 `$font-family-regular` 保留顺序；字号 small/regular 为 12/14，heading1..6 为 32/28/24/20/18/16；对应逻辑像素行高为 16/20 与 44/40/32/28/24/22。light/regular/bold 字重为 200/400/600。字号、字重和字体来源是 `packages/semi-theme-default/scss/variables.scss`；行高来源是 `_font.scss` 对应 mixin 的字面量，没有独立 Sass 变量。这些配置不加入 383 个 CSS token 的 manifest。

```dart
final base = const SemiThemeData.light();
final customized = base.copyWith(
  typography: base.typography.copyWith(
    fontFamily: 'MyAppFont',
    fontFamilyFallback: ['PingFang SC', 'Arial'],
    fontSizeRegular: 16,
    lineHeightRegular: 24,
    fontSizeHeading2: 30,
    lineHeightHeading2: 42,
    fontWeightBold: FontWeight.w700,
  ),
);
SemiTheme(data: customized, child: const SemiTitle('主题标题', heading: 2));
SemiTheme(data: customized, child: const SemiText('主题正文'));
final dark = customized.copyWith(dark: true); // 保留全部排版覆盖
```

字号与行高是独立 token；只改字号仍保留该级别的逻辑像素行高，Flutter `TextStyle.height` 为 `lineHeight / fontSize`。显式 style 最后合并（其 inherit:false 遵循 Flutter 整份替换语义）；显式 weight 优先于 strong/主题默认字重。标题 regular/normal 权重不改变主题字号与行高。SemiText 的 size:inherit 保留 DefaultTextStyle 的字号、行高、字体及 fallback，常规字重仍使用主题 regular。

fallback 在构造和 copyWith 时防御性复制且不可修改。copyWith 的 null 表示保留；要清除字体族，使用 `SemiTypographyTokens(fontFamily: null)` 替换整组。默认组可用 `const SemiTypographyTokens.defaults()`，因此 const light/dark 仍可使用。自定义构造为保证 fallback 防御性复制使用非 const 构造。

这里只提供字体配置，不下载或打包字体、不修改 pubspec，也不自动翻译 `-apple-system`、`BlinkMacSystemFont`、`sans-serif` 等平台别名。宿主负责安装或注册字体，并按目标平台需要覆盖字体名称。局部主题可从 `SemiTheme.of(context).copyWith(typography: ...)` 派生；相同亮暗模式下修改任意排版值同样通知子树。

## Typography 组件颜色

`SemiThemeData.components.typography` 提供应用级 19 个可空颜色覆盖，`SemiTypographyTheme(data: ..., child: ...)` 提供可嵌套局部补丁；颜色统一通过 `SemiTypographyTheme.resolve(context)` 解析。字体度量仍由 `SemiThemeData.typography` 管理。应用和局部例子、全部 Sass 映射、优先级及 null/reset 边界见 [组件颜色主题](typography_theme.md)。禁用链接默认使用 colorLink，仍不可激活。
