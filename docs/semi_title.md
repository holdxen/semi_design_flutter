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
