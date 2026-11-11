# SemiEmpty 与 SemiIllustration

无需 Material，使用 `package:semi_design_flutter/semi_design_flutter.dart` 和 Flutter widgets。

```dart
Directionality(
  textDirection: TextDirection.ltr,
  child: SemiTheme(
    data: const SemiThemeData.light(
      components: SemiComponentThemes(
        empty: SemiEmptyThemeData(spacingEmptyTitleMarginTop: 20),
      ),
    ),
    child: const SemiEmptyTheme(
      data: SemiEmptyThemeData(spacingEmptyFooterMarginTop: 16),
      child: SemiEmpty(
        image: SemiIllustration(
          SemiIllustrations.noContent,
          dark: SemiIllustrations.noContentDark,
        ),
        title: '暂无内容',
        description: '换个关键词试试',
        footer: Text('刷新'),
      ),
    ),
  ),
)
```

## API 与边界

`layout` 默认 `SemiEmptyLayout.vertical`，另有 `horizontal`。`title`/`description` 各接受 `String` 或 `Widget`（其他类型触发 assert）：String 的 title 走 `SemiTitle`、description 走 `SemiText`（颜色取主题 `colorEmptyDescriptionTextDefault`），Widget 原样放置。`image`/`darkModeImage`/`footer` 是 Widget；`padding` 是根节点 padding（替代上游 `style`）；`semanticsLabel` 提供时给整个占位区域一个语义标签。

标题排版复刻上游 index.tsx：有图时 `SemiTitle(heading: 4)`，字重取主题 `fontEmptyTitleFontWeight`（默认 600）；无图时 `SemiTitle(heading: 6)` 固定字重 400。"有图"按暗色解析后的实际渲染图判断（见差异清单）。

间距精确复刻 empty.scss，均取主题 resolved 值：vertical 为 Column 交叉轴居中，image 与 content 之间 24（`spacingEmptyContentVerticalMarginTop`）；horizontal 为 Row，content 位于 image 的逻辑 start 侧并以 `EdgeInsetsDirectional` 保持 32（`spacingEmptyContentHorizontalMarginLeft`）的逻辑边距，RTL 自动镜像。description 仅当 title 存在时才有 16（`spacingEmptyTitleMarginTop`）顶部间距（上游相邻兄弟语义）；footer 恒有 24（`spacingEmptyFooterMarginTop`）顶部间距。与上游一致，image/content 间距无条件生效（image 容器在上游 DOM 中恒存在，即使为空）；String 的 title/description 在 vertical 居中对齐，horizontal 靠 start。

image 区域 `ExcludeSemantics`（上游 aria-hidden）并禁止拖选（`SelectionContainer.disabled`，对应 `user-select: none`/`-webkit-user-drag`）；title/description/footer 保留自身语义（SemiTitle 仍带 header 语义）。支持系统文字缩放：文本随缩放，间距不变；插图尺寸不随文字缩放。极窄宽度与无界约束按 mainAxisSize.min 收缩，不猜测可用宽度。

`darkModeImage` 由 `SemiTheme.of(context).dark` 驱动：暗色优先 `darkModeImage`、为空回退 `image`；亮色只看 `image`（与上游一致）。

主题优先级：显式 widget 参数 > 内层局部非空补丁 > 外层局部补丁 > 当前 `SemiThemeData.components.empty` > live global 默认值。局部补丁跨 SemiTheme 边界继承：捕获只携带局部补丁快照，应用级与默认值在目标边界重新解析，相同 light/dark 模式下更新也通知。`copyWith`/`merge` 的 null 表示保留原值，不能清除字段；创建新空 theme 可重置。

## 完整 Sass 映射

来源 `packages/semi-foundation/empty/variables.scss`；消费逻辑 `packages/semi-foundation/empty/empty.scss`、`rtl.scss`、`packages/semi-ui/empty/index.tsx`。
共 **6** 个声明：spacing 4、font 1、color 1。独立于 383 项 CSS manifest，不把 Sass 混入 CSS token 清单。

| Sass | 默认 | Theme 字段 |
|---|---|---|
| `$spacing-empty_content_vertical-marginTop` | 24px | spacingEmptyContentVerticalMarginTop |
| `$spacing-empty_content_horizontal-marginLeft` | 32px | spacingEmptyContentHorizontalMarginLeft |
| `$spacing-empty_title-marginTop` | 16px | spacingEmptyTitleMarginTop |
| `$spacing-empty_footer-marginTop` | 24px | spacingEmptyFooterMarginTop |
| `$font-empty_title-fontWeight` | 600 | fontEmptyTitleFontWeight → theme.typography.fontWeightBold |
| `$color-empty_description-text-default` | var(--semi-color-text-1) | colorEmptyDescriptionTextDefault → theme.colors.colorText1 |

间距是固定 px，不虚构 global 长度引用。字重与描述颜色在每次 resolve 时读取当前 global，组件覆盖优先；标题无图分支的 400 字重是上游内联样式，固定不主题化。RTL（rtl.scss）由 `EdgeInsetsDirectional` 与 Row/Column 方向自动处理。

## 插图用法

16 个插图来自上游 `@douyinfe/semi-illustrations`，生成到 `assets/illustrations/`，由生成的 `SemiIllustrations` 目录以 const descriptor 暴露：`construction`/`constructionDark`、`failure`/`failureDark`、`idle`/`idleDark`、`noAccess`/`noAccessDark`、`noContent`/`noContentDark`、`noResult`/`noResultDark`、`notFound`/`notFoundDark`、`success`/`successDark`（命名取上游导出名 `IllustrationXxx` 转 lowerCamelCase）。

自动明暗（推荐）：把 light/dark 两个 descriptor 都给 `SemiIllustration`，按 `SemiTheme.of(context).dark` 择一，暗色缺省回退 light：

```dart
SemiIllustration(
  SemiIllustrations.noResult,
  dark: SemiIllustrations.noResultDark,
)
```

显式固定：只传一个 descriptor，两个模式都用它（也可用 `size` 缩放，默认 200x200 逻辑像素）：

```dart
const SemiIllustration(SemiIllustrations.noContentDark)
```

descriptor 是 const，可交给自定义 wrapper（`SvgPicture.asset(descriptor.asset, package: descriptor.package)`）。插图默认 `ExcludeSemantics`（上游 aria-hidden）。

## 替换策略

flutter_svg 不解析 `var(--...)`，生成时按三档替换（替换计数与 SHA256 记录在 `tool/illustration_manifest.json`，生成后无 `var(` 残留，测试断言）：

| 上游 CSS 变量 | 替换 | 联动 |
|---|---|---|
| `var(--semi-color-primary)` | `currentColor` | 随主题：`SemiIllustration` 注入 `SvgTheme(currentColor: theme.colors.colorPrimary)`，默认主题精确、自定义主题联动 |
| `var(--semi-color-primary-light-default)` | 亮 `#EAF5FF`、暗 `rgba(0, 100, 250, 0.2)` | 固定默认主题值（global.scss：亮 `rgba(var(--semi-blue-0), 1)`、暗 `rgba(var(--semi-blue-5), .2)`），不随自定义主题 |
| `var(--semi-color-primary-light-hover)` | 亮 `#CBE7FE`、暗 `rgba(0, 100, 250, 0.3)` | 固定默认主题值（global.scss：亮 `rgba(var(--semi-blue-1), 1)`、暗 `rgba(var(--semi-blue-5), .3)`），不随自定义主题 |

实测仅亮色插画引用 light-default/light-hover（暗色插画改用 primary + fill-opacity），生成器仍按文件明暗分别替换。颜色的具体 RGB 取自 `packages/semi-theme-default/scss/_palette.scss`，生成脚本会校验 global.scss 与调色板声明防止漂移。

## 差异清单

- `darkModeImage` 由 `SemiTheme.of(context).dark` 驱动，替代上游对 body `theme-mode` 的 MutationObserver。
- 上游 `imageStyle`/`style` 不移植；根节点提供 `padding`，image 造型请直接构造 image Widget。
- 标题无图时固定字重 400（上游 heading 6 + 内联 `fontWeight: 400` 压过 CSS 600）；"有图"按暗色解析后的实际渲染图判断，例如仅提供 `darkModeImage` 且处于亮色时视为无图，与上游渲染一致。
- 浅色强调填充（primary-light-default/hover）已固化为默认主题具体值，不随自定义主题联动；仅 primary 经 `currentColor` 联动。
- 插画品牌合规提示：插图资产来自上游 semi-design 仓库的 `packages/semi-illustrations`，与该仓库同属 MIT（`third_party/semi_design/LICENSE` 已整体覆盖，未改动），对外使用请同时遵守 Semi Design 品牌与插画的使用规范。
- 上游 `children` 在此命名为 `footer`。
- vertical/horizontal 的 image-content 间距无条件生效（上游 image 容器恒渲染，即使内容为空）。
- footer 内容在 Flutter 侧作为整体与 title/description 一起居中（vertical）；上游 footer 是 text-align 起始的块级容器，内容靠逻辑 start，如需该行为请在 footer Widget 内自行布局。
- description 的 String 便利形式渲染为 `SemiText`（上游为纯 div + 颜色 class）；语义上二者一致。
