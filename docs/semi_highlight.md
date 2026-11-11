# SemiHighlight

无需 Material，使用 `package:semi_design_flutter/semi_design_flutter.dart` 和 Flutter widgets。

```dart
SemiHighlight(
  'Semi Design',
  searchWords: [
    SemiHighlightWord('Semi', style: TextStyle(color: Colors.red)),
    SemiHighlightWord('Design'),
  ],
)
```

应用级主题：

```dart
SemiTheme(
  data: const SemiThemeData.light(
    components: SemiComponentThemes(
      highlight: SemiHighlightThemeData(colorHighlightTextDefault: Color(0xff00ff00)),
    ),
  ),
  child: const SemiHighlight('Semi Design', searchWords: [SemiHighlightWord('Semi')]),
)
```

局部补丁：

```dart
SemiHighlightTheme(
  data: const SemiHighlightThemeData(fontHighlightTextFontWeight: FontWeight.w900),
  child: const SemiHighlight('Semi Design', searchWords: [SemiHighlightWord('Semi')]),
)
```

## API 与算法语义

`SemiHighlight(sourceString, {searchWords, caseSensitive, autoEscape, style, highlightStyle, textAlign, textDirection, softWrap, maxLines, overflow, semanticsLabel})` 渲染为单个 `Text.rich`：算法的每个 chunk 对应一个 `TextSpan`，高亮段与纯文本段交替铺满全文。`searchWords` 是 `List<SemiHighlightWord<TextStyle>>`，每项含 `text` 与可选 `style`（`TextStyle`）；空 text 词条被忽略（等价上游过滤空字符串/undefined）。`const` 构造可用，`searchWords` 默认 `const []`。`maxLines` 必须为 null 或大于 0。语义上 `Text.rich` 自动合并朗读，`semanticsLabel` 透传。

算法（`highlight_algorithm.dart`，纯 Dart 零 Flutter 依赖，复刻 `packages/semi-foundation/highlight/foundation.ts` 的 findAll = findChunks → combineChunks → fillInChunks）：

- 多词顺序：按词条顺序逐词全局扫描，chunk 下标为 UTF-16 code unit，与 `String.substring` 切片对齐。
- 重叠合并：按 start 稳定排序，重叠/包含合并为单 chunk（end 取最大），不做嵌套高亮。合并样式归属为 `{...prev.style, ...next.style}`：前词已有的键保留，后词同键覆盖。多词重叠时前词（搜索词列表更早、同位置排序更前）的独有键优先保留。
- `autoEscape` 双模式：默认 true，先转义字符集 `-[]/{}()*+?.\^$|`（严格复刻上游 `escapeRegExpFn`）再按字面匹配；false 时词条文本直接作为正则模式。`caseSensitive` 默认 false（不区分大小写），true 区分。
- 空词与零长匹配：空 text 词条被过滤；零长匹配（如 `'a*'`）只取 end > start 的区间，不会产生空 chunk。无任何匹配时输出单个非高亮 chunk 覆盖全文。
- 高亮段样式链严格 `base.merge(themeDefaults).merge(highlightStyle).merge(word.style)` 后 `copyWith(inherit: false)` 收口；其中 base 是环境 `DefaultTextStyle` 合并 widget `style`，themeDefaults 来自 resolved 主题（color/backgroundColor/fontWeight）。优先级：word.style > highlightStyle > themeDefaults > widget style > 环境文本样式。非高亮段纯文本 span 用 base style。

## 主题

字段与 `packages/semi-foundation/highlight/variables.scss` 的 3 个声明一一对应（独立于 383 项 CSS manifest）：

| Sass | 默认 | Theme 字段 |
|---|---|---|
| `$color-highlight-text-default` | var(--semi-color-highlight) | colorHighlightTextDefault → theme.colors.colorHighlight |
| `$color-highlight-text-bg-default` | var(--semi-color-highlight-bg) | colorHighlightTextBgDefault → theme.colors.colorHighlightBg |
| `$font-highlight-text-fontWeight` | 600 | fontHighlightTextFontWeight → theme.typography.fontWeightBold |

主题优先级：高亮段样式链中的显式参数 > 内层局部非空补丁 > 外层局部补丁 > 当前 `SemiThemeData.components.highlight` > live global 默认值（colorHighlight/colorHighlightBg/fontWeightBold 每次 resolve 时实时读取，light/dark 各自解析）。局部补丁跨 SemiTheme 边界继承，捕获只快照有效局部补丁（排除应用级与已解析默认值），到新全局重新解析；相同 light/dark 模式下更新也通知。`copyWith`/`merge` 的 null 表示保留原值，不能清除字段；创建新空 theme 可重置。

## 与上游差异清单

- 正则引擎以 Dart `RegExp` 为准：与 JS 同为 UTF-16 code unit 语义，但极端模式（如零宽断言、反向引用细节）以 Dart 实现为准。
- 高亮背景用 `TextSpan.backgroundColor`，无圆角、无 padding（上游 `mark` 默认样式含浏览器 UA 圆角/padding 与主题背景）；不引入 WidgetSpan。
- 不移植 `highlightClassName`、`component`（自定义标签）与 `className`（chunk 级）：Flutter 侧以 TextStyle/主题表达样式。
- `searchWords` 只接受 `SemiHighlightWord` 对象列表，不支持裸字符串混入（类型化后空值由类型系统排除，仅过滤空 text）。
- 极端 emoji/代理对边界：下标为 UTF-16 code unit，含代理对的字素被匹配时切片正确；但模式若只命中代理对一半（如 `.` 逐 code unit 匹配），以 Dart 正则为准。
- 性能提示：每个词条独立全局扫描（O(词数 × 文本)），长文本+多词场景建议预先精简词条；`autoEscape: false` 的复杂正则可能回溯放大成本。
