# 默认主题 token

## 范围与生成

本次交付仅为 token/主题数据层，不实现 Button、Tooltip Widget 或 Sass token。默认主题 374 个唯一 CSS 变量，加 Button CSS 变量 7 个、Tooltip 运行时变量 2 个，共 383 个。官网文档不作为数据源。

```sh
python3 -I tool/generate_tokens.py --source /Users/zhouguiqing/Documents/Code/Html/semi-design --output /Users/zhouguiqing/Documents/Code/Flutter/semi_design_flutter
python3 -I tool/test_generate_tokens.py
flutter analyze --no-pub lib test
flutter test --no-pub
```

脚本仅使用 Python 标准库，最后调用现有 Dart SDK 格式化输出，不安装依赖。显式源目录不能省略。生成文件不要手改；更改应进入生成脚本。相同源码生成相同输出。遇到未知值语法、循环引用或计数漂移直接失败，而不是猜测。

`tool/token_manifest.json` 保存每份输入的完整原文和 SHA-256、所有有效声明及行号、亮暗最终来源、公开 Dart 字段与类型映射、重复覆盖诊断。去除行/块注释后读取 CSS custom property，不读取 `$` Sass 声明。函数参数按括号深度分割。相同模式重复名最后生效，暗色未声明项继承亮色公共声明。

上游两处 `--semi-color-ai-background-top-hover` 重复，保留最后声明并记录诊断；不将其擅自重命名为 active。动画的有效默认 duration/delay 全为 0ms，注释内动画配置不生效。所有生成公开 token getter 都通过 `///` 标出原始 CSS 名及相对源路径。

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
