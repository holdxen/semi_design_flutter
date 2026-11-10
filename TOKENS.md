# 默认主题 token

## 范围与生成

主题数据层，不实现 Button、Tooltip Widget ；另提供 Sass 排版配置。默认主题 374 个唯一 CSS 变量，加 Button CSS 变量 7 个、Tooltip 运行时变量 2 个，共 383 个。官网文档不作为数据源。

```sh
python3 -I tool/generate_tokens.py --source /Users/zhouguiqing/Documents/Code/Html/semi-design --output /Users/zhouguiqing/Documents/Code/Flutter/semi_design_flutter
python3 -I tool/test_generate_tokens.py
flutter analyze --no-pub lib test
flutter test --no-pub
```

脚本仅使用 Python 标准库，最后调用现有 Dart SDK 格式化输出，不安装依赖。显式源目录不能省略。生成文件不要手改；更改应进入生成脚本。相同源码生成相同输出。遇到未知值语法、循环引用或计数漂移直接失败，而不是猜测。

`tool/token_manifest.json` 保存每份输入的完整原文和 SHA-256、所有有效声明及行号、亮暗最终来源、公开 Dart 字段与类型映射、重复覆盖诊断。去除行/块注释后读取 CSS custom property，不读取 `$` Sass 声明。函数参数按括号深度分割。相同模式重复名最后生效，暗色未声明项继承亮色公共声明。

上游两处 `--semi-color-ai-background-top-hover` 重复，保留最后声明并记录诊断；不将其擅自重命名为 active。动画的有效默认 duration/delay 全为 0ms，注释内动画配置不生效。所有生成公开 token getter 都通过 `///` 标出原始 CSS 名及相对源路径。

## 内部默认值分层

每组 token 在构造（包括主题绑定时的 `copyWith`）时统一选择私有、无状态的 const 亮/暗 defaults 策略；公开构造参数和 `const SemiThemeData.light/dark` 保持兼容。公开 getter 只执行 `override ?? defaults.field(this)`，不逐字段判断亮暗，也不在 getter 内创建 defaults 对象。共享默认表达式放在 defaults 基类，只有模式不同的表达式由亮/暗实现分别提供；实现与所属组同文件，不增加公开 API。

默认方法接收当前 token 组，直接读取其当前 palette/colors 和同组 getter，不提前解析或保存引用结果，因此显式覆盖、主题切换和跨组引用仍保持联动。覆盖存储、`copyWith`、值相等及 hashCode 只在 token 组中实现一份。字段 CSS 来源注释和 manifest 保留；生成回归测试检查全部 383 getter 的委托结构和构造时唯一模式选择，字段覆盖测试同时检查亮暗往返保留覆盖。

## 使用

```dart
const light = SemiThemeData.light();
const dark = SemiThemeData.dark();
final primary = light.colors.colorPrimary;
final buttonText = dark.button.buttonColorfulFillSecondary;
final gradient = light.palette.aiGeneral5.forSize(const Size(240, 40));
final circle = light.radius.borderRadiusCircle.resolveRadius(const Size(80, 40));
```

所有 383 个字段均可通过所属类型的强类型命名构造参数或 `copyWith` 覆盖。生成器将默认 CSS 引用编译为 Dart 属性依赖，无运行时 CSS 解析。主题保存显式配置，每次读取组时绑定当前亮暗模式和上游配置。

```dart
const base = SemiThemeData.light();
final branded = base.copyWith(
  palette: base.palette.copyWith(blue5: const SemiChannels(12, 34, 56, 1)),
);
// 未覆盖 colorPrimary 随 blue5 改变；hover 仍按其自己的 CSS 引用。
final custom = branded.copyWith(
  colors: branded.colors.copyWith(colorText0: const Color(0xff123456)),
  tooltip: branded.tooltip.copyWith(tooltipArrowOffsetX: const SemiLength.pixels(8)),
);
// buttonColorfulFillSecondary 默认引用 colorText0，因此跟随。
final pinned = custom.copyWith(
  button: custom.button.copyWith(buttonColorfulFillSecondary: const Color(0xffabcdef)),
);
```

显式语义色和组件字段优先于默认引用，连续 copyWith 保留此前显式覆盖；语义覆盖不会反向修改色板，也不会自动生成 hover。light/dark 构造仍支持 const；`copyWith(dark: true)` 切换默认模式并保留覆盖。所有组及类型模型使用值相等和 hashCode，渐变/阴影集合防御性复制且不可修改。主题以完整有效值比较决定是否通知。

`copyWith` 的 null 表示保留，**不支持用 null 清除单字段覆盖**。恢复某组默认值可传新实例，例如 `pinned.copyWith(colors: const SemiColors())`；这会清除该组全部显式覆盖并重新绑定当前色板。其他组同理。默认引用的值相等不意味着显式覆盖历史相同：显式固定值与当前默认值相同也会固定后续行为。

- `SemiChannels` 保留 RGB/RGBA 通道，`Color` 表达颜色，渐变是独立类型。
- `SemiGradient.forSize` 通过 CSS 从上顺时针角度及真实 Size 计算渐变端点，保留 stop。
- `SemiLength` 区分 px 与 percent，圆角百分比按宽高分别解析，而非固定当作像素。
- 多层阴影保留 inset、位移、模糊、扩散与颜色。Flutter BoxShadow 不支持 inset，转换时明确抛出 UnsupportedError，不默默丢弃；专用 inset painter 不在本次范围。
- 动效为 Duration、Curve 及受限 scale/rotate 数据模型，不包含完整 transform 链解释器。
- Tooltip 两个 offset 是 `arrow.scss` 中 `var(..., 50%)` 的运行时 fallback，不是默认主题声明。布局实际值可直接使用 `SemiLength.pixels` 或 `.percent`；默认 getter 返回 50%，由调用方按对应轴长解析。

模板 Calculator 保留。未修改 example、依赖、发布配置；未作平台渲染或 Widget/golden 兼容性承诺。

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

`SemiThemeData.components.typography` 提供应用级 19 个颜色及 75 个度量可空覆盖，`SemiTypographyTheme(data: ..., child: ...)` 提供可嵌套局部补丁；颜色统一通过 `SemiTypographyTheme.resolve(context)` 解析。未覆盖度量实时引用 `SemiThemeData.typography`，组件级覆盖优先。应用和局部例子、全部 Sass 映射、优先级及 null/reset 边界见 [组件排版主题](docs/typography_theme.md)。禁用链接默认使用 colorLink，仍不可激活。
