# SemiDivider

无需 Material，使用 `package:semi_design_flutter/semi_design_flutter.dart` 和 Flutter widgets。

```dart
Directionality(
  textDirection: TextDirection.ltr,
  child: SemiTheme(
    data: const SemiThemeData.light(
      components: SemiComponentThemes(
        divider: SemiDividerThemeData(thickness: 2),
      ),
    ),
    child: const SemiDividerTheme(
      data: SemiDividerThemeData(textPadding: EdgeInsets.symmetric(horizontal: 12)),
      child: SemiDivider(align: SemiDividerAlign.left, child: Text('标题')),
    ),
  ),
)
```

## API 与边界

`layout` 默认 `SemiDividerLayout.horizontal`，另有 `vertical`；`align` 默认 center，另有 left/right，均是物理方向，不随 RTL 翻转。`dashed` 默认 false；`child` 接受 Widget，`text` 是纯文字便利参数，两者互斥。Text/纯文字应用文本 padding、字重与颜色；任意其他 Widget 不自动加文字 padding。vertical 忽略 child/text，与上游一致。

`margin` 是逻辑像素，水平覆盖上下、垂直覆盖左右，其他边保持主题值；`color`、`thickness`、`height`（仅垂直）、`textStyle` 是 Flutter 显式覆盖。纯线装饰不参与语义，标题保留语义。虚线由 CustomPainter 绘制，dash/gap 各为 3 倍线宽（最小 1），浏览器 CSS dash 像素模式可能不同。

水平填满有界宽度，文本自然决定高度；左/右固定短线默认 40，中心两侧等分剩余宽度。极窄宽度缩短短线并裁切文本；无界宽度使用有限 minWidth（通常 0），不猜测屏幕宽度。请在横向滚动或 Row 中用 SizedBox/Expanded 提供宽度。文本字号默认 live `theme.typography.fontSizeRegular`，可用主题 fontSize 或 textStyle 覆盖；这不是额外 Sass 声明。支持系统 text scaling。

主题优先级：显式 widget 参数 > 内层局部非空补丁 > 外层局部补丁 > 当前 SemiThemeData.components.divider > live global 默认值。局部补丁跨 SemiTheme 边界继承，遵循 Typography 的祖先合并与 InheritedTheme.capture 行为；相同 light/dark 模式下更新也通知。`copyWith`/`merge` 的 null 表示保留原值，不能清除字段；创建新空 theme 可重置。

## 完整 Sass 映射

来源 `packages/semi-foundation/divider/variables.scss`；消费逻辑 `packages/semi-foundation/divider/divider.scss`、`packages/semi-ui/divider/index.tsx`。
共 **19** 个声明：color 2、font 1、height 1、spacing 12、width 3。独立于 383 项 CSS manifest，不把 Sass 混入 CSS token 清单。每个边距边都可通过 EdgeInsets 单独配置。

| Sass | 默认 | Theme 字段 |
|---|---|---|
| `$spacing-divider_horizontal-marginLeft` | 0px | horizontalMargin.left |
| `$spacing-divider_horizontal-marginRight` | 0px | horizontalMargin.right |
| `$spacing-divider_horizontal-marginTop` | 1px | horizontalMargin.top |
| `$spacing-divider_horizontal-marginBottom` | 1px | horizontalMargin.bottom |
| `$spacing-divider_vertical-marginLeft` | 1px | verticalMargin.left |
| `$spacing-divider_vertical-marginRight` | 1px | verticalMargin.right |
| `$spacing-divider_vertical-marginTop` | 0px | verticalMargin.top |
| `$spacing-divider_vertical-marginBottom` | 0px | verticalMargin.bottom |
| `$spacing-divider_inner_text-paddingLeft` | 8px | textPadding.left |
| `$spacing-divider_inner_text-paddingRight` | 8px | textPadding.right |
| `$spacing-divider_inner_text-paddingTop` | 0px | textPadding.top |
| `$spacing-divider_inner_text-paddingBottom` | 0px | textPadding.bottom |
| `$width-divider_inner_text_left_line` | 40px | leftLineWidth |
| `$width-divider_inner_text_right_line` | 40px | rightLineWidth |
| `$width-divider-border` | 1px | thickness |
| `$height-divider_vertical` | 20px | verticalHeight |
| `$color-divider_border-color` | var(--semi-color-border) | color → theme.colors.colorBorder |
| `$color-divider_text-default` | var(--semi-color-text-0) | textColor → theme.colors.colorText0 |
| `$font-divider_text-weight` | $font-weight-bold | fontWeight → theme.typography.fontWeightBold |

上游 Sass 把 inner_text 声明在使用处写为 inner-text；Sass 将下划线与连字符等价处理，迁移注释保留声明原名。长度都是固定 px，不虚构 global 长度引用。textPadding/fontWeight 仅文字标题消费，leftLineWidth/rightLineWidth 仅对应 align 消费，verticalHeight 仅垂直消费；所有字段始终可配置并 resolve。默认颜色、字重、字号在每次 resolve 时读取当前 global，组件覆盖优先。

重新生成独立主题：`python3 tool/generate_divider.py`（包含 dart format）。现有 `generate_tokens.py` 通过 SemiComponentThemes 引用 Divider，保持 const light/dark 与组件相等性链。
