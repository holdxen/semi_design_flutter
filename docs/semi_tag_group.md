# SemiTagGroup

> ## ⚠️ 不完整移植（待后续补全）
>
> 本组件是上游 `TagGroup`（packages/semi-ui/tag/group.tsx）的**基础版移植**，以下能力未实现或与上游有差异，使用前请知悉：
>
> - **showPopover / popoverProps 未实现**：折叠后的 "+N" 标签不支持悬停 Popover 展示剩余标签。Popover 组件尚未移植，**待 Popover 移植后补全**这两个参数。
> - **SplitTagGroup 未移植**（上游 splitTagGroup.tsx），本文件只覆盖 TagGroup。
> - **固定高度裁剪规则差异**：上游 `.semi-tag-group-max` + small/large 把组高固定为 22/26px 并裁剪溢出；Flutter 版不复制该规则，组高随内容自适应。
> - **restCount=0 quirk（刻意复刻）**：上游 `restCount ? restCount : tagList.length - maxTagCount` 按 truthiness 判断，`restCount=0` 视为未提供，回退到按数量计算的差值。
> - **key 合成差异**：上游对非字符串 children 用 `Math.random()` 合成 tagKey；本移植中 close 事件的 tagKey 缺省取 text，widget key **仅在显式提供 tagKey 时**注入 `ValueKey(tagKey)`，避免同文本重复 key 崩溃。
> - **mode 由 item 类型表达**：上游 `mode='custom'` 参数取消，改用 `SemiTagGroupItem.custom(Widget child)`；类型即模式，不再提供 mode 参数。
>
> 另注意：**截断是按数量（maxTagCount）截断，不是按宽度测量**。宽度不足时由 Wrap 自然换行、增加行数，不会压缩标签数量。

非 Material Tag 组。item 按序渲染进 Wrap，可按数量把尾部折叠为 "+N" 标签。

## API

`SemiTagGroup({key, tagList, maxTagCount, restCount, size, avatarShape, onTagClose, onPlusNMouseEnter})`。

- `tagList`：`List<SemiTagGroupItem>`，默认空列表，按序渲染；custom item 同样计入截断数量。
- `maxTagCount`：`int?`。null 渲染全部；0 只剩 "+N"（全量计数）；负数 build 期抛 `ArgumentError`（**与上游 JS `slice` 负值怪异行为不同**，上游 slice(0, -1) 会静默截掉最后一项）。
- `restCount`：`int?`，覆盖 "+N" 的计数。**quirk**：`restCount=0` 视为未提供，回退 `tagList.length - maxTagCount`（复刻上游 truthiness）。
- `size`：`SemiTagSize?` 组默认，注入未显式指定 size 的 item，同时决定 "+N" 标签尺寸（`item.size ?? size ?? normal`）。
- `avatarShape`：`SemiTagShape?` 组默认，注入链同上（`item.avatarShape ?? avatarShape ?? square`）。
- `onTagClose`：`ValueChanged<SemiTagCloseEvent>?`，关闭转发（见下）。
- `onPlusNMouseEnter`：`VoidCallback?`，指针进入 "+N" 标签时触发（上游 onMouseEnter）。上游 showPopover 的悬停展示剩余标签未实现。

`SemiTagGroupItem(String text, {...SemiTag 全部外观/交互字段, size, avatarShape})` 为标准 item；`SemiTagGroupItem.custom(Widget child)` 为 custom item（原样渲染，不做注入/转发）。标准 item 的 `size`/`avatarShape` 可空表示继承组值，其余字段与 `SemiTag` 同名同默认值（type/shape/color/closable/visible/tagKey/onClose/onTap/prefixIcon/suffixIcon/avatar/colorful/gradient/semanticsLabel/closeSemanticsLabel/backgroundColor/textColor/borderColor/style）。

## 行为（对齐 group.tsx）

1. `maxTagCount == null`：渲染全部 item。
2. `maxTagCount != null`：`n = (restCount != null && restCount != 0) ? restCount : tagList.length - maxTagCount`；`n > 0` 时渲染前 `maxTagCount` 项 + "+N" 标签，`n <= 0` 时**渲染全部、不折叠**（复刻上游）。因此 3 项 + `maxTagCount=5` 会全部渲染。
3. "+N" 标签：`SemiTag('+$n', closable: false, size: 组size ?? normal, color: grey, backgroundColor: 透明)`，无 onTap，widget key 为 `ValueKey('_+n')`，外层 MouseRegion 的 onEnter 触发 `onPlusNMouseEnter`。
4. 关闭转发：包装 `item.onClose` 先调用、再调 `onTagClose`，二者收到**同一个** `SemiTagCloseEvent`（text/tagKey 同参）；任一处 `preventDefault()` 即取消非受控隐藏。上游是各自回调同参调用、Tag 事后检查 `defaultPrevented`——语义等价。受控（visible 非空）只发事件，不受 preventDefault 影响。
5. tagKey 注入：close 事件的 tagKey 缺省用 text（对应上游字符串内容取自身为 key）；显式 tagKey 时事件与 widget key 都用它。
6. 布局：Wrap 对应上游 `display:block` + inline-block 换行；`spacing = spacingTagGroupMarginRight`、`runSpacing = spacingTagGroupMarginBottom`（默认 8/0，RTL 随环境方向自动适配）。上游 max+small/large 的固定高度裁剪不复制。
7. **截断按数量不按宽度**：宽度不足时 Wrap 自然换行，"宽度约束下截断"的说法不成立。

## 用法

```dart
// 标准
SemiTagGroup(tagList: [
  SemiTagGroupItem('甲', closable: true),
  SemiTagGroupItem('乙'),
]);

// custom（mode='custom'）
SemiTagGroup(tagList: [
  SemiTagGroupItem.custom(const Text('任意 Widget')),
  SemiTagGroupItem('丙'),
]);

// 截断：3 项渲染 + '+2'
SemiTagGroup(
  maxTagCount: 3,
  tagList: [for (final t in ['a', 'b', 'c', 'd', 'e']) SemiTagGroupItem(t)],
);

// restCount 覆盖计数 → '+9'（restCount=0 会回退计算值，见上文 quirk）
SemiTagGroup(maxTagCount: 2, restCount: 9, tagList: [...]);

// 关闭转发：item 回调先于 group 回调，同一个事件，preventDefault 任一处生效
SemiTagGroup(
  onTagClose: (e) => e.preventDefault(),
  tagList: [SemiTagGroupItem('保留', closable: true, onClose: (e) {})],
);

// 局部主题覆盖组间距
SemiTagTheme(
  data: const SemiTagThemeData(
    spacingTagGroupMarginRight: 12,
    spacingTagGroupMarginBottom: 6,
  ),
  child: SemiTagGroup(tagList: [...]),
);
```

## 主题消费

`SemiTagGroup` 消费 `SemiTagTheme.resolve(context)` 的 `spacingTagGroupMarginRight`/`spacingTagGroupMarginBottom`（对应 Sass `$spacing-tag_group-marginRight/Bottom`，即上游每个 tag 的 margin-right/margin-bottom，RTL 为 margin-left），映射为 Wrap 的 spacing/runSpacing。这两个字段是生成字段（tool/generate_tag.py），改值走 SemiTagThemeData patch，不手改生成文件。
