# SemiParagraph

从 `package:semi_design_flutter/semi_design_flutter.dart` 或 typography.dart 门面导入。仅依赖 Flutter widgets；提供 Directionality 即可运行，不要求 MaterialApp。

```dart
SemiParagraph('普通段落');
SemiParagraph('小号宽松段落', size: SemiTextSize.small,
  spacing: SemiParagraphSpacing.extended);
SemiParagraph('访问详情', underline: true,
  link: SemiTextLink(onTap: () { /* 由应用导航 */ }));
SizedBox(width: 180, child: SemiParagraph('较长的段落文字……',
  maxLines: 2, overflow: TextOverflow.ellipsis));
```

## React 映射与 API

| React Typography.Paragraph | Flutter |
| --- | --- |
| string children | 必填位置参数 `SemiParagraph(String data)` |
| type | `SemiTextType`：primary（默认）、secondary、tertiary、quaternary、warning、danger、success |
| size | `SemiTextSize.normal`（默认）、small、inherit |
| spacing | `SemiParagraphSpacing.normal`（默认）、extended |
| disabled / strong / mark / underline / delete | 同名 bool，默认 false |
| style | `TextStyle?`，最终合并 |
| link | `SemiTextLink?`；回调打开目的地，visited 由应用维护 |
| ellipsis rows | `maxLines` 与 `overflow: TextOverflow.ellipsis`，需要有限宽度 |
| 布局及无障碍 | `textAlign`、`textDirection`、`softWrap`、`maxLines`、`overflow`、`semanticsLabel` |

可空参数默认 null。maxLines 必须大于零。不提供 weight 参数；使用 style.fontWeight 定制字重。首版只支持 String，不提供 code/icon、copyable、中间省略、suffix、expand 或 tooltip。

## 排版与优先级

| size | normal spacing 默认字号/行高 | extended 默认字号/行高 |
| --- | --- | --- |
| normal | 14 / 20 | 14 / 24 |
| small | 12 / 16 | 12 / 24 |
| inherit | DefaultTextStyle 字号与 height | 继承字号，行高 24 |

normal/small 使用主题字体族和 fallback；inherit 保留 DefaultTextStyle 字体族、fallback、字号与 normal spacing 的 height，常规字重仍来自 normalParagraphRegularFontWeight。extended 只改变行高，不改变字号、字体族或字重；继承字号缺失时用 resolved fontSizeRegular 计算 height 比例，Text 自身缺失字号遵循 Flutter 默认值。

行高以 resolved 逻辑像素 / 合并 style 前的字号转换为 TextStyle.height，响应系统缩放。和已有 Text 一样，style 单独改字号会保留此前 height 比例，实际行高随字号变化；显式 style.height 可进一步覆盖。`TextStyle(inherit: false)` 遵循 Flutter 整份替换语义，可能取消组件的其他默认值。

字重优先级：段落 regular → linkFontWeight → strongFontWeight → style.fontWeight。颜色优先级：type → link 状态 → disabled → style。mark、underline、delete 可组合；链接下划线仅 hover/pressed 显示。复用 SemiText 的点击、Enter、Space、焦点外框与 visited/hover/active 状态。disabled 无法通过点击、键盘或语义激活；style 只能改变外观。普通段落不标记 header；链接只暴露一个语义 label 与 link 操作。

## 主题字段

所有段落默认值从 `SemiTypographyTheme.resolve(context)` 读取；应用级 `SemiThemeData.components.typography` 与局部 `SemiTypographyTheme` 均可动态更新。

```dart
SemiTypographyTheme(
  data: const SemiTypographyThemeData(
    normalParagraphRegularFontWeight: FontWeight.w500,
    smallParagraphRegularFontWeight: FontWeight.w400,
    paragraphExtendedLineHeight: 28,
    titleParagraphMargin: EdgeInsets.symmetric(vertical: 8),
    fontSizeRegular: 16,
    lineHeightRegular: 24,
  ),
  child: const SemiParagraph('局部宽松段落',
    spacing: SemiParagraphSpacing.extended),
);
```

字段包括 normalParagraphRegularFontWeight、smallParagraphRegularFontWeight、paragraphExtendedLineHeight（默认 24）、titleParagraphMargin（默认 EdgeInsets.zero）、fontSizeRegular/fontSizeSmall、lineHeightRegular/lineHeightSmall，以及 Text 共用的七类颜色、disabled/mark/link 状态颜色和 strongFontWeight/linkFontWeight/linkBorderWidth。字体族、fallback 和未覆盖字号/行高/字重实时引用全局 SemiTypographyTokens；最近非空局部覆盖优先，随后祖先局部、应用级配置、全局默认。全部 Sass 字段见 [主题说明](typography_theme.md)。

## 块级布局边界

段落通过外层 Padding 表达 titleParagraphMargin，不执行浏览器 CSS margin collapse。父约束宽度有限时，扣除 margin 后填满可用宽度；高度随内容。横向无界（例如 Row 的非 Flexible 子项或横向滚动容器）时按内容收缩，不设置无限宽度。需要自动换行或末尾省略时，请用 SizedBox/ConstrainedBox/Flexible 提供有限宽度。遵循 Flutter 父约束，不保证浏览器 p 元素逐像素布局；字体资源由宿主注册，不保证各平台中文和 emoji 字形一致。
