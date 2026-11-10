# SemiText 使用说明

从 `package:semi_design_flutter/semi_design_flutter.dart` 导入。只依赖 Flutter widgets 和 `SemiTheme.of(context)`，不要求 MaterialApp、Material 或 Material Theme。普通文本在 Directionality 中即可使用；键盘 Tab 遍历需要 WidgetsApp 或宿主提供相应焦点遍历动作。

```dart
SemiText('普通正文');
SemiText('次要小字', type: SemiTextType.secondary, size: SemiTextSize.small);
SemiText('强调代码', strong: true, code: true);
SemiText('打开详情', underline: true,
  link: SemiTextLink(onTap: () { /* 由应用导航或打开 URL */ }));
SizedBox(width: 160, child: SemiText('有限宽度中的长文本……',
  maxLines: 1, overflow: TextOverflow.ellipsis));
```

## React 映射与 API

| React Typography.Text | Flutter |
| --- | --- |
| 字符串 children | 必填位置参数 `SemiText(String data)` |
| type | `SemiTextType.primary`（默认正文 text0）、secondary/text1、tertiary/text2、quaternary/text3、warning、danger、success |
| size | `SemiTextSize.normal`（默认 14/20）、small（12/16）、inherit（DefaultTextStyle 的字号和行高） |
| weight / strong | `FontWeight? weight`；`strong` 默认 false，使用 600；显式 weight 优先 |
| disabled / mark / code / underline / delete | 同名 bool，默认 false |
| style | `TextStyle? style`，最后合并，覆盖已指定的文字外观属性 |
| icon | `Widget? icon`，前缀与正文间隔 4，按文字方向布局；图标不单独朗读 |
| link | `SemiTextLink(onTap: ..., visited: false)`；visited 由调用方维护，不自动记录访问 |
| ellipsis | `maxLines` + `TextOverflow.ellipsis`，父级必须提供有限宽度 |
| 文本布局 / 无障碍 | textAlign、textDirection、softWrap、maxLines、overflow、semanticsLabel |

所有可空布局参数默认 null，交给 Flutter Text/DefaultTextStyle 处理；maxLines 必须大于零。字号与行高使用逻辑像素和比例，响应系统文字缩放。inherit 只继承字号/行高，常规字重仍为 400；链接或 strong 为 600。DefaultTextStyle 的字体家族等基础样式保留，但默认 decoration 明确清空，避免祖先下划线泄漏；使用 `style.decoration` 可最终替换或清除装饰。`TextStyle(inherit: false, ...)` 遵循 Flutter merge 的整份替换语义，可能同时取消组件默认字号/颜色。

## 外观优先级与差异

颜色优先级是 type → code(text2) → link → disabledText → 显式 style。链接颜色始终优先 type；静止用 link/visited，hover 用 linkHover，按下用 linkActive。disabled 使用 disabledText（含链接），保留 code 的 fill1 背景、border 描边和 mark 的浅主色背景；这是明确的 Flutter 禁用外观约定。style 可以覆盖禁用文字颜色，但不能恢复交互。

code 使用整块 1px border、2px 圆角、垂直 2/水平 4 padding。这是有意区别于浏览器逐行 inline code 片段的布局；多行 code 只有一个外框。code 与 mark 同时启用时，code 的 fill1 背景优先；style.backgroundColor 可以覆盖文字背景，但不改变外框背景。单独 mark 用 primaryLightDefault 文字背景。delete 与 underline 可组合；链接 underline 仅 hover/pressed 时出现，禁用时隐藏。

链接支持点击、Enter、Space 和单一 Semantics link/tap，禁用时无法激活。键盘焦点使用 focusBorder 的可见外框，不通过外部 FocusNode 管理生命周期。无链接的文本不创建交互控件。链接 onTap 只负责通知应用，无 URL 插件，也不提供浏览器原生地址、上下文菜单或 visited 历史行为。

尺寸、间距、字重常量集中在组件内部，来源为上游 `packages/semi-foundation/typography/variables.scss`、`typography.scss` 和 `packages/semi-theme-default/scss/global.scss`/`mixin.scss`；这些是 Sass 派生组件度量，不属于现有 383 个生成 CSS 变量。

## 主题定制

```dart
SemiTheme(
  data: const SemiThemeData.light(
    colors: SemiColors(
      colorText0: Color(0xff203040),
      colorLink: Color(0xff006644),
      colorLinkHover: Color(0xff008855),
      colorLinkActive: Color(0xff004422),
      colorLinkVisited: Color(0xff663399),
      colorPrimaryLightDefault: Color(0xffe4f4ee),
    ),
  ),
  child: const SemiText('主题正文'),
);
// 将 data 替换为 SemiThemeData.dark()，或 copyWith(colors: ...)，即可刷新子树。
```

仅支持 String 和末尾省略，不实现富文本 children、copyable、中间截断、suffix、展开、tooltip、Title 或 Paragraph。原有 Title 占位保持不变。测试验证布局与行为，不保证不同平台字体、emoji 字形及浏览器 inline 逐像素一致。
