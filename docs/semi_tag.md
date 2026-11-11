# SemiTag

非 Material Tag。normal/small 高 20，large 高 24；文字随系统缩放，固定高度内裁切，有限宽度省略。

## API

`SemiTag(String text, {key, size, type, shape, color, closable, visible, tagKey, onClose, onTap, prefixIcon, suffixIcon, avatar, avatarShape, colorful, gradient, semanticsLabel, closeSemanticsLabel, backgroundColor, textColor, borderColor, style})`。

size: normal（默认）/small/large；type: light（默认）/solid/ghost；shape、avatarShape: square（默认）/circle。color 为 16 个 palette 色加 white，默认 grey。closable、colorful、gradient 默认 false。其它可选引用默认 null。style 是 TextStyle；颜色覆盖可单独设置。

## 关闭与可访问性

onClose 为 void Function(SemiTagCloseEvent)，事件包含 text、Object? tagKey、defaultPrevented 和 preventDefault()。只支持回调内同步 preventDefault；返回 false 和异步取消不是契约。关闭不冒泡到 onTap。

visible 为 null 时内部默认 true，关闭自动隐藏；受控时只发事件，父组件负责更新 visible。受控转非受控保留最近受控值。Delete/Backspace 关闭，Enter 调用 onTap，Escape 失焦。关闭按钮默认标签 Close 加文字，可通过 closeSemanticsLabel 翻译。

```dart
SemiTag('保留', closable: true, onClose: (event) {
  event.preventDefault();
});
SemiTheme(data: SemiThemeData.light(components: SemiComponentThemes(
  tag: SemiTagThemeData(backgroundColor: Color(0xffeeeeee)),
)), child: SemiTag('全局'));
SemiTagTheme(data: SemiTagThemeData(textColor: Color(0xff123456)),
  child: SemiTag('局部', borderColor: Color(0xff999999)));
```

局部主题逐层 patch；InheritedTheme.captureAll 捕获局部未解析值，在目标全局主题重新绑定。backgroundColor/textColor/borderColor 为 Flutter 额外字段，不来自 Sass，不加入 CSS383 manifest。

16 色 × 3 类型实时读取 palette；white 单独遵循来源规则。AI 颜色与渐变分别使用 Color/SemiGradient；渐变文字 ShaderMask，边框/背景 CustomPainter。任意 prefixWidget 不重写内部 SVG gradient stop：AI 四 stop 参数可配置但未实现自动应用，不改变 SemiIcon 体系。

组间距由基础版 SemiTagGroup 消费，该组已移植但不完整（见 docs/semi_tag_group.md，showPopover 待 Popover 移植后补全）；deep-close 是上游保留未消费字段。没有 Tooltip、关闭动画或 Avatar 组件。

## 完整 Sass 映射（64）

来源 packages/semi-foundation/tag/variables.scss。全局和 palette 引用在 resolve 时读取当前主题。每个四边 spacing 字段独立映射，组件组合为方向性 padding；avatar 优先于 closable 优先于普通 padding。

| Sass 精确名 | Dart 字段 | 类型 | 源默认 |
|---|---|---|---|
| `$color-tag_avatar-bg-default` | `colorTagAvatarBgDefault` | `Color` | `var(--semi-color-bg-4)` |
| `$color-tag_avatar-border-default` | `colorTagAvatarBorderDefault` | `Color` | `var(--semi-color-border)` |
| `$color-tag_avatar-text-default` | `colorTagAvatarTextDefault` | `Color` | `var(--semi-color-text-0)` |
| `$color-tag_white-bg-default` | `colorTagWhiteBgDefault` | `Color` | `var(--semi-color-bg-4)` |
| `$color-tag_white-border-default` | `colorTagWhiteBorderDefault` | `Color` | `rgba(var(--semi-grey-2), 0.7)` |
| `$color-tag_white-text-default` | `colorTagWhiteTextDefault` | `Color` | `var(--semi-color-text-0)` |
| `$color-tag_white-icon-default` | `colorTagWhiteIconDefault` | `Color` | `var(--semi-color-text-2)` |
| `$color-tag-outline-focus` | `colorTagOutlineFocus` | `Color` | `var(--semi-color-primary-light-active)` |
| `$color-tag_colorful_solid-bg` | `colorTagColorfulSolidBg` | `Color` | `var(--semi-color-ai-purple)` |
| `$color-tag_colorful_solid-text` | `colorTagColorfulSolidText` | `Color` | `var(--semi-color-white)` |
| `$color-tag_colorful_solid_gradient-bg` | `colorTagColorfulSolidGradientBg` | `SemiGradient` | `var(--semi-color-ai-general)` |
| `$color-tag_colorful_light-bg` | `colorTagColorfulLightBg` | `Color` | `rgba(var(--semi-ai-purple-0), 1)` |
| `$color-tag_colorful_light-text` | `colorTagColorfulLightText` | `Color` | `var(--semi-color-ai-purple)` |
| `$color-tag_colorful_light_gradient-bg` | `colorTagColorfulLightGradientBg` | `SemiGradient` | `var(--semi-ai-general-0)` |
| `$color-tag_colorful_light_gradient-text` | `colorTagColorfulLightGradientText` | `SemiGradient` | `var(--semi-color-ai-general)` |
| `$color-tag_colorful_light_gradient-1` | `colorTagColorfulLightGradient1` | `Color` | `rgba(var(--semi-ai-general-5-0) ,1)` |
| `$color-tag_colorful_light_gradient-2` | `colorTagColorfulLightGradient2` | `Color` | `rgba(var(--semi-ai-general-5-1) ,1)` |
| `$color-tag_colorful_light_gradient-3` | `colorTagColorfulLightGradient3` | `Color` | `rgba(var(--semi-ai-general-5-2) ,1)` |
| `$color-tag_colorful_light_gradient-4` | `colorTagColorfulLightGradient4` | `Color` | `rgba(var(--semi-ai-general-5-3) ,1)` |
| `$color-tag_colorful_ghost-bg` | `colorTagColorfulGhostBg` | `Color` | `var(--semi-color-white)` |
| `$color-tag_colorful_ghost-text` | `colorTagColorfulGhostText` | `Color` | `var(--semi-color-ai-purple)` |
| `$color-tag_colorful_ghost-border` | `colorTagColorfulGhostBorder` | `SemiGradient` | `var(--semi-color-ai-general)` |
| `$color-tag_colorful_ghost_gradient-text` | `colorTagColorfulGhostGradientText` | `SemiGradient` | `var(--semi-color-ai-general)` |
| `$color-tag_colorful_ghost_gradient-1` | `colorTagColorfulGhostGradient1` | `Color` | `rgba(var(--semi-ai-general-5-0) ,1)` |
| `$color-tag_colorful_ghost_gradient-2` | `colorTagColorfulGhostGradient2` | `Color` | `rgba(var(--semi-ai-general-5-1) ,1)` |
| `$color-tag_colorful_ghost_gradient-3` | `colorTagColorfulGhostGradient3` | `Color` | `rgba(var(--semi-ai-general-5-2) ,1)` |
| `$color-tag_colorful_ghost_gradient-4` | `colorTagColorfulGhostGradient4` | `Color` | `rgba(var(--semi-ai-general-5-3) ,1)` |
| `$width-tag_avatar_circle_small` | `widthTagAvatarCircleSmall` | `double` | `16px` |
| `$width-tag_avatar_circle_large` | `widthTagAvatarCircleLarge` | `double` | `20px` |
| `$width-tag-border` | `widthTagBorder` | `double` | `1px` |
| `$width-tag_avatar-border` | `widthTagAvatarBorder` | `double` | `$width-tag-border` |
| `$width-tag-outline` | `widthTagOutline` | `double` | `2px` |
| `$height-tag_small` | `heightTagSmall` | `double` | `20px` |
| `$height-tag_large` | `heightTagLarge` | `double` | `24px` |
| `$radius-tag` | `radiusTag` | `double` | `var(--semi-border-radius-small)` |
| `$radius-tag_circle` | `radiusTagCircle` | `double` | `var(--semi-border-radius-full)` |
| `$spacing-tag_small-paddingY` | `spacingTagSmallPaddingY` | `double` | `2px` |
| `$spacing-tag_small-paddingX` | `spacingTagSmallPaddingX` | `double` | `$spacing-tight` |
| `$spacing-tag_prefix_icon_paddingRight` | `spacingTagPrefixIconPaddingRight` | `double` | `$spacing-extra-tight` |
| `$spacing-tag_suffix_icon_paddingLeft` | `spacingTagSuffixIconPaddingLeft` | `double` | `$spacing-extra-tight` |
| `$spacing-tag_large-paddingY` | `spacingTagLargePaddingY` | `double` | `4px` |
| `$spacing-tag_large-paddingX` | `spacingTagLargePaddingX` | `double` | `$spacing-tight` |
| `$color-tag_close-icon-default` | `colorTagCloseIconDefault` | `Color` | `var(--semi-color-text-2)` |
| `$color-tag_close-icon-hover` | `colorTagCloseIconHover` | `Color` | `var(--semi-color-text-1)` |
| `$color-tag_close-icon-active` | `colorTagCloseIconActive` | `Color` | `var(--semi-color-text-0)` |
| `$color-tag_close-icon_deep-default` | `colorTagCloseIconDeepDefault` | `Color` | `var(--semi-color-white)` |
| `$spacing-tag_close-paddingLeft` | `spacingTagClosePaddingLeft` | `double` | `$spacing-extra-tight` |
| `$spacing-tag_closable-paddingTop` | `spacingTagClosablePaddingTop` | `double` | `$spacing-extra-tight` |
| `$spacing-tag_closable-paddingRight` | `spacingTagClosablePaddingRight` | `double` | `$spacing-extra-tight` |
| `$spacing-tag_closable-paddingBottom` | `spacingTagClosablePaddingBottom` | `double` | `$spacing-extra-tight` |
| `$spacing-tag_closable-paddingLeft` | `spacingTagClosablePaddingLeft` | `double` | `$spacing-tight` |
| `$spacing-tag_avatar-marginRight` | `spacingTagAvatarMarginRight` | `double` | `$spacing-extra-tight` |
| `$spacing-tag_avatar_square-paddingTop` | `spacingTagAvatarSquarePaddingTop` | `double` | `0` |
| `$spacing-tag_avatar_square-paddingRight` | `spacingTagAvatarSquarePaddingRight` | `double` | `$spacing-extra-tight` |
| `$spacing-tag_avatar_square-paddingBottom` | `spacingTagAvatarSquarePaddingBottom` | `double` | `0` |
| `$spacing-tag_avatar_square-paddingLeft` | `spacingTagAvatarSquarePaddingLeft` | `double` | `0` |
| `$spacing-tag_avatar_circle-paddingTop` | `spacingTagAvatarCirclePaddingTop` | `double` | `$spacing-super-tight` |
| `$spacing-tag_avatar_circle-paddingRight` | `spacingTagAvatarCirclePaddingRight` | `double` | `$spacing-extra-tight` |
| `$spacing-tag_avatar_circle-paddingBottom` | `spacingTagAvatarCirclePaddingBottom` | `double` | `$spacing-super-tight` |
| `$spacing-tag_avatar_circle-paddingLeft` | `spacingTagAvatarCirclePaddingLeft` | `double` | `$spacing-super-tight` |
| `$color-tag_avatar_square_img-bg-default` | `colorTagAvatarSquareImgBgDefault` | `Color` | `var(--semi-color-default)` |
| `$spacing-tag_group-marginBottom` | `spacingTagGroupMarginBottom`（由 SemiTagGroup 消费） | `double` | `0` |
| `$spacing-tag_group-marginRight` | `spacingTagGroupMarginRight`（由 SemiTagGroup 消费） | `double` | `$spacing-tight` |
| `$font-tag_colorful-fontWeight` | `fontTagColorfulFontWeight` | `FontWeight` | `$font-weight-bold` |

## CSS 优先级与布局兼容

AI 两类选择器优先于 white/avatar 单类背景与文字规则；white/avatar 的边框 shorthand 仍生效，avatar 边框在 white 之后。gradient ghost 使用独立渐变描边。white 关闭图标规则优先于普通 hover/active。colorful 字重实时引用 typography.fontWeightBold（上游默认 600），字号实时引用 fontSizeSmall。极窄宽度下各 slot 可收缩并裁切，不产生 RenderFlex overflow；无界宽度仍按内容收缩。
