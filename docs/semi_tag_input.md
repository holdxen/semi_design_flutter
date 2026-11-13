# SemiTagInput

非 Material 标签输入框。值模型 `List<String>`：`value != null` 即受控（项目惯例，渲染恒跟随 value、只发事件；释放控制保留最后受控值 semi_rating.dart:122-129 同款），`inputValue` 对输入行同样半受控；非受控种子 `defaultValue`。分词走 getSplitedArray 语义：`separator` 默认 `','`（String/num 按字面切、`List<String>` 先把 separators[1..] 折进 separators[0] 再切一次、null/其他整段单条），自定义 `split` 覆盖；★空段/纯空白段丢弃（trim 判定）但保留值**不** trim。★`allowDuplicates` 默认 **true**，false 时丢弃已存在标签与批内重复（保留首个）。Enter 恒被消费（上游 preventDefault），输入非空才添加（onAdd 报新增批、onChanged 报全量、随后输入恒清空并报 ''）；`max` 超限先 `onExceed(全量尝试列表)` 再截尾（静默）。`maxLength` 按分段：编辑中分段**增长**越界即拒绝该次击键并 `onInputExceed(整串)`（删除放行）；IME 组合结束就地截断越界段 + `onInputExceed(value)`、★按 separator 重拼（数组 separator 按 JS ToString 折成 `','` 连接形）且**跳过** `onInputChange`（Firefox workaround；组合期编辑不追踪——`entering` 仅在有 maxLength 时存在）。Backspace 空输入删**最后**一个标签（onRemove(tag, len-1)+onChanged；★无多段选中删除）；标签关闭走 SemiTag close（onRemove+onChanged，★preventDefault 掉 Tag 自身隐藏——可见性由值驱动）。showClear（默认 false）显示 32px 清空槽（clearIcon ?? 默认 clear 图标，hover 色 `icon-hover`），仅「悬浮 且 非空 且 非 disabled」可见，点击清标签+输入。placeholder 仅在**零标签**时显示。`maxTagCount` 折叠成 `+N` 片（★片色硬编码 `var(--semi-color-text-0)`）；`expandRestTagsOnClick`（默认 true）在「active」时放开折叠——★上游 active=点入根内/点外清除，本移植以**焦点**近似（聚焦显示拖拽手柄与展开、失焦折叠，视觉等价，差异清单）；`showRestTagsPopover`（默认 true）悬浮 +N 显示 SemiTooltip 列出被折标签（select `_buildNTag` 先例）。draggable（默认 false）：聚焦时逐标签显示拖拽手柄（`color-tagInput_handler-icon-default`、右外边距 4），拖手柄重排（arrayMove 语义）并在**落点只发一次** `onChanged(reordered)`（无 onSort、不涉 onAdd/onRemove；原位放下不发——上游 `onSortEnd` 仅在索引变化时触发）。prefix/suffix/insetLabel 为 `Object?`（String|Widget）：prefix||insetLabel 居起始侧（insetLabel 加粗 `font-tagInput_prefix_suffix-fontWeight`；String 走 `-prefix-text` 样式——★其色走 `-prefix-default` 通道，`-prefix-text-default` 是死变量）、suffix 居末尾侧、点按聚焦输入。disabled 全屏蔽（输入不可聚焦、无关闭、无清空、无手柄），根背 `colorTagInputDisabledBg` + 禁用文字色。validateStatus `SemiInputStatus`（normal/warning/error；★success 上游无视觉）走 `_warning`/`_danger` 字段组 default/hover/focus 行；焦点描边 `focus-border`、hover 背 `fill-1`、focus 背 `fill-0`（字段驱动）。三尺寸（small/normal/large ↔ `'small'/'default'/'large'`）根 min-height 24/32/40、输入行高 20/24/24、标签垂直外边距 1/2/3px、输入区水平内边距 4px（`$spacing-extra-tight`）。输入行用 `SemiInput(bare: true)` + TextPainter 镜像量宽（★`scrollWidth + 2` 余量、`min-width: 2px`）。语义 `Semantics(enabled: !disabled)` + 输入 semanticsLabel（上游 aria-label）；★aria-invalid 仅 error（SemanticsValidationResult.invalid）。RTL 标签外边距翻转（margin-left 4 / margin-right 0，EdgeInsetsDirectional）、布局全程方向化。`SemiTagInputController` 提供 `focus()`/`blur()`（attach/detach 先例，脱离后 no-op）。onBlur `VoidCallback?`（上游带事件对象，裁剪）、onFocusChange `ValueChanged<bool>?`、autofocus false。

## API

`SemiTagInput({key, value, defaultValue, inputValue, onChanged, onAdd, onRemove, onInputChange, onExceed, onInputExceed, separator, split, allowDuplicates, max, maxLength, disabled, showClear, clearIcon, placeholder, maxTagCount, showRestTagsPopover, showContentTooltip, addOnBlur, renderTagItem, expandRestTagsOnClick, draggable, prefix, suffix, insetLabel, validateStatus, size, onBlur, onFocusChange, autofocus, semanticsLabel, controller})`。

value `List<String>?` 非空即受控（tags）；defaultValue `List<String>?` 非受控种子；inputValue `String?` 非空即输入行受控（同款释放保留）。separator `Object?`（String | num | List<String> | null，默认 `','`；assert 收窄类型）；split `List<String> Function(String, Object?)?` 自定义覆盖。allowDuplicates true（★上游默认 true）。max `int?`（标签总数上限）、maxLength `int?`（单段长度上限）。disabled false、showClear false、clearIcon `Widget?`（原样渲染，默认 `SemiIcons.clear`）、placeholder `String?`、maxTagCount `int?`（null/0 不折叠）、showRestTagsPopover true、showContentTooltip true（★默认标悬浮显示全文 tooltip——上游是截断时才显的 ellipsis tooltip，近似注明）、addOnBlur false（失焦提交待输入文本，走完整添加流）、renderTagItem `Widget Function(String value, int index, VoidCallback onClose)?`（替换默认标渲染；draggable 时手柄槽仍包裹它）、expandRestTagsOnClick true、draggable false。prefix / suffix / insetLabel `Object?`（String | Widget，prefix 压过 insetLabel）。validateStatus `SemiInputStatus`（normal/warning/error 可视，success 同 normal）、size `SemiInputSize`（small/normal/large）。onBlur `VoidCallback?`、onFocusChange `ValueChanged<bool>?`、autofocus false、semanticsLabel `String?`、controller `SemiTagInputController?`（`focus()`/`blur()`）。静态 `SemiTagInput.rootKey` / `clearButtonKey` / `nTagKey` / `tagKey(index)` / `dragHandleKey(index)` 供测试定位。

回调：onChanged `ValueChanged<List<String>>?` 每次变更报**全量新数组**（无 diff gate）；onAdd `ValueChanged<List<String>>?` 报本批新增；onRemove `void Function(String value, int index)?`；onInputChange `ValueChanged<String>?`（★组合结束写入不报）；onExceed `ValueChanged<List<String>>?`（max 截断前的全量尝试列表）；onInputExceed `ValueChanged<String>?`（maxLength 拒绝/截断时的整串）。

## 行为

### 分词与 Enter 添加（★保留值不 trim、空段丢弃）

Enter 恒消费（上游 `e.preventDefault()`，Flutter 侧由 onEnterPress/键处理通道承接，不触发表单语义）；输入空则无事。`getSplitedArray`：String/num 按其字面切分（num 取 toString）；`List<String>` 把 separators[1..] 逐个替换为 separators[0] 后切一次；null/其他整段单条。`split` 函数覆盖以上全部。★空串/纯空白段丢弃（`item.trim() !== ''` 判定）但保留段**不** trim（' a ' 原样入库）。★allowDuplicates=false 时同时过滤「已在 tags 中」与「批内重复」（按首次出现保留，indexOf 走未过滤数组）；默认 true 全收。`max` 超限：`onExceed([...tags, ...addTags])` 后 `slice(0, max)` 截尾静默（addTags 同步 `slice(0, max - tags.length)`，JS 负数 end 从尾数的 quirk 保留）。添加后输入恒清空并 `onInputChange('')`（即使 addTags 为空）。

### maxLength（击键拒绝 + IME 组合截断）

编辑中（非 IME）对新旧输入按 separator 分段比较：任一分段**增长**且长度越界 → 拒绝该次输入（显示回退）+ `onInputExceed(整串)`；删除/缩短放行（foundation `_checkInputChangeValid`）。IME 组合期（`entering`，仅 maxLength 存在时置位）编辑不校验、照常 `onInputChange`；组合结束：任一段越界 → 就地截断该段、`onInputExceed(value)`、★按 separator 重拼写回（数组 separator 按 JS ToString 用 `','` 连接各元素成串）且**不**报 `onInputChange`；未越界也直接写回报值（★Firefox workaround：组合结束绕过 onChanged）。

### addOnBlur / renderTagItem / showContentTooltip

`addOnBlur`（默认 false）：输入行失焦即走完整添加流（foundation.ts:213-220——含空输入也报 `onInputChange('')` 的副作用），先提交后用户 `onBlur`。`renderTagItem(value, index, onClose)` 替换默认 `SemiTag` 渲染（onClose 由值驱动移除该索引标签）。`showContentTooltip`（默认 true）给默认标包 hover tooltip 显示全文（上游为截断时的 ellipsis tooltip，简化注明）。

### Backspace 与标签关闭

输入空 + 有标签时 Backspace 删最后一个（onRemove(tag, len-1) + onChanged 全量；★无多段选中删除）；无标签 no-op。标签关闭（SemiTag close）→ splice → onChanged + onRemove(value, index)；★close 事件 preventDefault 掉 Tag 自身隐藏（值驱动可见性——受控父不更新时标签不消失，与上游一致）。disabled 无关闭按钮（closable: !disabled）。

### 清空按钮（showClear）

32px 槽（`width-tagInput-clear-medium`）常驻，图标 `clearIcon ?? SemiIcons.clear`，hover 色 `colorTagInputIconHover`；★仅「悬浮 且 （有标签或有输入） 且 非 disabled」可见（上游 `clearBtn-invisible` = visibility hidden，槽位保留）。点击：有标签 → `onChanged([])`（★不发 onRemove）；有输入 → `onInputChange('')`；★恒通知并在非受控缓冲落地，受控渲染仍跟随 value（差异清单）。

### placeholder

仅零标签时传入输入框（上游 `tagsArray.length === 0 ? placeholder : ''`）；有标签时占位为空串。镜像量宽同样按「输入文本 →（零标签时）placeholder → ' '」取量。

### maxTagCount 折叠与 +N

`maxTagCount > 0 且 < tags.length` 且未展开时折叠为 `take(maxTagCount)` + `+N` 片（文本 `+{tags.length - maxTagCount}`）；★片色硬编码 `var(--semi-color-text-0)`（tagInput.scss:181，同通道的 `-maxTagCount-default` 变量是死变量，上游未消费），片 padding 水平 `spacingTagInputWrapperNPaddingX`（8px）、右外边距 4px、字号 12px、disabled 转禁用文字色。`expandRestTagsOnClick`（默认 true）在 active（≈聚焦）时放开折叠；draggable 的 sortable 布局（active 且 draggable）恒显示全部标签（上游 renderTags 的 Sortable 分支不过折叠）。`showRestTagsPopover`（默认 true）悬浮 +N 显示 SemiTooltip（hover、顶部、带箭头）列出被折标签。

### draggable 拖拽重排（★落点一次 onChanged）

手柄仅在 `draggable && active(≈聚焦) && !disabled` 显示（IconHandle、色 `colorTagInputHandlerIconDefault`、右外边距 4（RTL 翻左）、tag 左内边距 `spacingTagInputTagIconPaddingLeft`）。原始 Listener 指针拖拽（slider 先例）：拖起后源标签 0.5 透明（`-sortable-item-active`）、指针下落目标标签起始侧画 2px primary 竖线（`-sortable-item-over` 前置条，`widthTagInputSortableItemOver` × `colorTagInputSortableItemOverBg`）、克隆件跟随指针浮于顶层（`z-tagInput_drag_item_move` z-index 无 Flutter 对应——尾位 Stack 子天然置顶，字段留档不消费）。落点按标签矩形就近计算，按 `arrayMove`（splice out `from`、插入 `to`）重排，★只在索引变化时发**一次** `onChanged(reordered)`（上游 `_sortable.onDragEnd` 的 `activeIndex !== overIndex` 门；无 onSort、不涉 onAdd/onRemove；原位落下不发）；受控只通知、渲染跟随 value。★dnd-kit 以标签 **value** 为 id——重复值上游排序不可靠（docs 注记，本移植按索引计算）。

### prefix / suffix / insetLabel

`prefix || insetLabel` 居起始侧（prefix 优先），suffix 居末尾侧；点按聚焦输入（上游 mousedown preventDefault + `handleClickPrefixOrSuffix`）。String：`margin: 0 12px`（`spacingTagInputPrefixSuffixMarginX`）+ `font-tagInput_prefix_suffix-fontWeight`（w600）+ `font-size-regular`（14px，其 mixin `line-height: 20px`）；prefix/insetLabel 色 `colorTagInputPrefixDefault`（text-2，★`-prefix-text-default` 死变量不消费）、suffix 色 `colorTagInputSuffixDefault`。SemiIcon：色 `colorTagInputIconDefault`、`margin: 0 8px`（`$spacing-tight`）；其他 Widget 原样。disabled 全部转 `colorTagInputDisabledTextDefault`。

### disabled

全屏蔽：输入不可聚焦（SemiInput disabled）、无关闭/清空/手柄、点击无事；根背 `colorTagInputDisabledBg`（disabled-fill）、禁用文字色走 clear/前缀/后缀/标签文字/占位（`colorTagInputDisabledTextDefault`，标签背景转透明——tagInput.scss:119-122）。

### validateStatus 视觉

状态机（scss 级联净效果）：disabled > focus > hover > default；warning/error 各有 default/hover/focus 行（bg+border-color 成对取 `_warning`/`_danger` 字段组，描边宽 default/hover 用 `widthTagInputBorderDefault/Hover`、focus 用 `widthTagInputBorderFocus`）；normal 行取 `_default` 组（focus 背 `fill-0` + 描边 `focus-border`、hover 背 `fill-1`、default 背 `fill-0` + 透明描边）。★success 上游无视觉（TSX 类型 `"default" | "error" | "warning"`），本移植同 normal。过渡：bg 走 `$transition_*-tagInput-bg` 三元组、边框走 `-border` 三元组（默认均 Duration.zero / easeIn / zero，双 AnimatedContainer 各自承载）。

### 三尺寸几何

small/normal/large ↔ 上游 `'small'/'default'/'large'`：根 min-height `heightTagInputSmall/Default/Large`（24/32/40）；输入行高 `heightTagInputInputSmall/Default/Large`（20/24/24）+ 垂直外边距 `spacingTagInputSmallY/DefaultY/LargeY`（1/2/3px）；标签垂直外边距同上三值、右外边距 4px（`$spacing-extra-tight`，RTL 翻左）；包装区水平内边距 4px（同 token）。★标签渲染 `size: small iff size==small else large`（默认尺寸映射 Tag.large，index.tsx renderTag）。

### 焦点与 active≈focus 近似

`-focus` 类上游 = focusing || active（input 焦点或点入根内）；本移植以子树焦点近似：聚焦输入/子树即 `_active`（拖拽手柄、+N 展开、focus 行视觉随之出现），失焦消失。根点击 → 聚焦输入（≈上游点入置 active）。onBlur/onFocusChange 走 SemiInput 通道（输入焦点）；`SemiTagInputController.focus()/blur()` 同步（脱离后 no-op）。

### RTL

标签外边距翻转为「margin-left 4 / margin-right 0」（rtl.scss:12-15，EdgeInsetsDirectional end:4 净效果一致）；输入首子 padding 翻转由 `SemiInput(bare)` 自身零水平内边距承接；拖拽手柄外边距方向化（end:4）。布局全程方向化。

### 语义

根 `Semantics(container: true, enabled: !disabled)` + ★`validationResult` 仅 error → `SemanticsValidationResult.invalid`（上游 `aria-invalid={validateStatus === 'error'}`，index.tsx:692）；输入 semanticsLabel（上游 `aria-label`）。

## 主题（55 对账）

来源 packages/semi-foundation/tagInput/variables.scss（49 声明行 / 49 唯一名——color 28、spacing 7、height 6、width 5、radius 1、z 1、font 1；无重复）与 animation.scss（6 声明：bg/border 两个过渡三元组）。对账 **55 = 49 FIELDS + 6 MOTION + 0 INTERNAL**（tagInput 的 animation.scss 无 transform token，故 INTERNAL=0；HARDCODES 另列见 B 表）。注：迁移方案曾记「48 声明（color 27）/ 54 = 48 + 6 + 0」，实测源计数为 49（color 28，方案分类漏一行）；「每条声明恰好落地一次」硬约束下按 55 落地。49 FIELDS 含 2 条事实死变量（标注「（上游未消费）」）：`$color-tagInput-maxTagCount-default`（`+N` 规则硬编码 `var(--semi-color-text-0)`，tagInput.scss:181，同通道非同变量）与 `$color-tagInput_prefix-text-default`（`-prefix-text` 实际消费 `$color-tagInput_prefix-default`，tagInput.scss:305）——保留 theme 字段但 widget 不消费（净效果一致）。quirk：`$color-tagInput-border-hover: transparent ` 声明中 `transparent` 后带**尾随空格**（variables.scss:9，provenance 原文照抄，值仍解析 transparent）；`$z-tagInput_drag_item_move: 2000 !default` 的 `!default` 原文保留。解析列即 `SemiTagInputThemeData.resolve` 的默认表达式；`transparent` 走字面量、`$font-weight-bold` 走 `theme.typography.fontWeightBold`（FontWeight 型，radio 先例）。

### A. Sass 声明映射（49 FIELDS + 6 MOTION = 55）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-tagInput-icon-default: var(--semi-color-text-2)` | `colorTagInputIconDefault` | `theme.colors.colorText2` |
| `$color-tagInput-maxTagCount-default: var(--semi-color-text-0)` | `colorTagInputMaxTagCountDefault` | `theme.colors.colorText0`（（上游未消费）`+N` 片硬编码 `var(--semi-color-text-0)`（tagInput.scss:181）而非本变量；widget 不消费本字段） |
| `$color-tagInput-icon-hover: var(--semi-color-primary-hover)` | `colorTagInputIconHover` | `theme.colors.colorPrimaryHover` |
| `$color-tagInput_disabled-text-default: var(--semi-color-disabled-text)` | `colorTagInputDisabledTextDefault` | `theme.colors.colorDisabledText` |
| `$color-tagInput_disabled-bg: var(--semi-color-disabled-fill)` | `colorTagInputDisabledBg` | `theme.colors.colorDisabledFill` |
| `$color-tagInput_default-bg-focus: var(--semi-color-fill-0)` | `colorTagInputDefaultBgFocus` | `theme.colors.colorFill0` |
| `$color-tagInput-border-default: transparent` | `colorTagInputBorderDefault` | `const Color(0x00000000)` |
| `$color-tagInput-border-hover: transparent ` | `colorTagInputBorderHover` | `const Color(0x00000000)`（★源声明 `transparent` 后带尾随空格，provenance 原文照抄） |
| `$color-tagInput-border-focus: var(--semi-color-focus-border)` | `colorTagInputBorderFocus` | `theme.colors.colorFocusBorder` |
| `$color-tagInput_prefix-default: var(--semi-color-text-2)` | `colorTagInputPrefixDefault` | `theme.colors.colorText2` |
| `$color-tagInput_suffix-default: var(--semi-color-text-2)` | `colorTagInputSuffixDefault` | `theme.colors.colorText2` |
| `$color-tagInput_default-bg-default: var(--semi-color-fill-0)` | `colorTagInputDefaultBgDefault` | `theme.colors.colorFill0` |
| `$color-tagInput_default-bg-hover: var(--semi-color-fill-1)` | `colorTagInputDefaultBgHover` | `theme.colors.colorFill1` |
| `$color-tagInput_warning-bg-default: var(--semi-color-warning-light-default)` | `colorTagInputWarningBgDefault` | `theme.colors.colorWarningLightDefault` |
| `$color-tagInput_warning-border-default: var(--semi-color-warning-light-default)` | `colorTagInputWarningBorderDefault` | `theme.colors.colorWarningLightDefault` |
| `$color-tagInput_warning-bg-hover: var(--semi-color-warning-light-hover)` | `colorTagInputWarningBgHover` | `theme.colors.colorWarningLightHover` |
| `$color-tagInput_warning-border-hover: var(--semi-color-warning-light-hover)` | `colorTagInputWarningBorderHover` | `theme.colors.colorWarningLightHover` |
| `$color-tagInput_warning-bg-focus: var(--semi-color-warning-light-default)` | `colorTagInputWarningBgFocus` | `theme.colors.colorWarningLightDefault` |
| `$color-tagInput_warning-border-focus: var(--semi-color-warning)` | `colorTagInputWarningBorderFocus` | `theme.colors.colorWarning` |
| `$color-tagInput_danger-bg-default: var(--semi-color-danger-light-default)` | `colorTagInputDangerBgDefault` | `theme.colors.colorDangerLightDefault` |
| `$color-tagInput_danger-border-default: var(--semi-color-danger-light-default)` | `colorTagInputDangerBorderDefault` | `theme.colors.colorDangerLightDefault` |
| `$color-tagInput_danger-bg-hover: var(--semi-color-danger-light-hover)` | `colorTagInputDangerBgHover` | `theme.colors.colorDangerLightHover` |
| `$color-tagInput_danger-border-hover: var(--semi-color-danger-light-hover)` | `colorTagInputDangerBorderHover` | `theme.colors.colorDangerLightHover` |
| `$color-tagInput_danger-bg-focus: var(--semi-color-danger-light-default)` | `colorTagInputDangerBgFocus` | `theme.colors.colorDangerLightDefault` |
| `$color-tagInput_danger-border-focus: var(--semi-color-danger)` | `colorTagInputDangerBorderFocus` | `theme.colors.colorDanger` |
| `$color-tagInput_sortable_item_over-bg: var(--semi-color-primary)` | `colorTagInputSortableItemOverBg` | `theme.colors.colorPrimary`（拖拽落点竖线） |
| `$color-tagInput_prefix-text-default: var(--semi-color-text-2)` | `colorTagInputPrefixTextDefault` | `theme.colors.colorText2`（（上游未消费）`-prefix-text` 实际消费 `$color-tagInput_prefix-default`（tagInput.scss:305）；widget 不消费本字段） |
| `$color-tagInput_handler-icon-default: var(--semi-color-text-2)` | `colorTagInputHandlerIconDefault` | `theme.colors.colorText2`（拖拽手柄） |
| `$spacing-tagInput_small-Y: 1px` | `spacingTagInputSmallY` | `1` |
| `$spacing-tagInput_default-Y: $spacing-super-tight` | `spacingTagInputDefaultY` | `2`（派生：`$spacing-super-tight: 2px`） |
| `$spacing-tagInput_large-Y: 3px` | `spacingTagInputLargeY` | `3` |
| `$spacing-tagInput_wrapper_n_paddingX: $spacing-tight` | `spacingTagInputWrapperNPaddingX` | `8`（派生：`$spacing-tight: 8px`） |
| `$spacing-tagInput_drag_handler-marginRight: 4px` | `spacingTagInputDragHandlerMarginRight` | `4` |
| `$spacing-tagInput_tag_icon_paddingLeft: 4px` | `spacingTagInputTagIconPaddingLeft` | `4` |
| `$spacing-tagInput_prefix_suffix-marginX: $spacing-base-tight` | `spacingTagInputPrefixSuffixMarginX` | `12`（派生：`$spacing-base-tight: 12px`） |
| `$height-tagInput-large: $height-control-large` | `heightTagInputLarge` | `40`（派生：`$height-control-large: 40px`） |
| `$height-tagInput-default: $height-control-default` | `heightTagInputDefault` | `32`（派生：`$height-control-default: 32px`） |
| `$height-tagInput-small: $height-control-small` | `heightTagInputSmall` | `24`（派生：`$height-control-small: 24px`） |
| `$height-tagInput_input_small: 20px` | `heightTagInputInputSmall` | `20` |
| `$height-tagInput_input_default: 24px` | `heightTagInputInputDefault` | `24` |
| `$height-tagInput_input_large: 24px` | `heightTagInputInputLarge` | `24` |
| `$width-tagInput-clear-medium: $width-icon-medium * 2` | `widthTagInputClearMedium` | `32`（派生：16×2） |
| `$width-tagInput-border-default: $border-thickness-control` | `widthTagInputBorderDefault` | `1` |
| `$width-tagInput-border-hover: $width-tagInput-border-default` | `widthTagInputBorderHover` | `1`（派生引用） |
| `$width-tagInput-border-focus: $border-thickness-control-focus` | `widthTagInputBorderFocus` | `1` |
| `$width-tagInput_sortable_item_over: 2px` | `widthTagInputSortableItemOver` | `2` |
| `$radius-tagInput: var(--semi-border-radius-small)` | `radiusTagInput` | `theme.radius.borderRadiusSmall.value` |
| `$z-tagInput_drag_item_move: 2000 !default` | `zTagInputDragItemMove` | `2000`（★provenance 保留 `!default`；CSS z-index 无 Flutter 对应——拖拽浮层以尾位 Stack 子置顶，字段留档不消费） |
| `$font-tagInput_prefix_suffix-fontWeight: $font-weight-bold` | `fontTagInputPrefixSuffixFontWeight` | `theme.typography.fontWeightBold`（FontWeight 型，radio 先例） |
| `$transition_duration-tagInput-bg: var(--semi-transition_duration-none)` | `transitionDurationTagInputBg` | `Duration.zero`（MOTION：背景过渡时长） |
| `$transition_function-tagInput-bg: var(--semi-transition_function-easeIn)` | `transitionFunctionTagInputBg` | `Curves.easeIn`（MOTION：背景过渡曲线） |
| `$transition_delay-tagInput-bg: var(--semi-transition_delay-none)` | `transitionDelayTagInputBg` | `Duration.zero`（MOTION：延迟，无延迟通道、零净效果） |
| `$transition_duration-tagInput-border: var(--semi-transition_duration-none)` | `transitionDurationTagInputBorder` | `Duration.zero`（MOTION：边框过渡时长） |
| `$transition_function-tagInput-border: var(--semi-transition_function-easeIn)` | `transitionFunctionTagInputBorder` | `Curves.easeIn`（MOTION：边框过渡曲线） |
| `$transition_delay-tagInput-border: var(--semi-transition_delay-none)` | `transitionDelayTagInputBorder` | `Duration.zero`（MOTION：延迟） |

### B. widget 内部常量（HARDCODES，另列）

| 常量（`_TagInputMetrics` / 调用点） | 上游出处 / 结构 | 值或处理 |
|---|---|---|
| `allCenter` | mixin.scss:22 `@mixin all-center`（clearBtn tagInput.scss:264 / prefix-suffix :290）— `display: flex; justify-content: center; align-items: center;` | 槽位 `Center` 居中 |
| `fontSizeRegularMixin` | _font.scss:8 `@mixin font-size-regular`（inset-label :282 / prefix-suffix text :295）— `line-height: 20px`（配 `$font-size-regular`；字体走 theme.typography） | 字号 `fontSizeRegular`（14）；行高语义由输入行高字段承接 |
| `inputWidthFudge` | index.tsx:342 `Math.ceil(mirrorEl.scrollWidth + 2)` | 2（★镜像 DOM 换 TextPainter 量宽，`+ 2` 余量保留） |
| `dragHandleSpanLineHeight` | _sortable/index.tsx:210 拖手柄 `<span style={{ lineHeight: 0 }}>` | `lineHeight: 0`（手柄内联贴合；本移植手柄为独立 widget，行高概念不适用） |
| `inputMinWidth` | tagInput.scss:194 `&-wrapper-input` — `min-width: 2px` | 2（输入最小宽） |
| `nTagHardcodedColor` | tagInput.scss:181 `&-wrapper-n` — `color: var(--semi-color-text-0);` | ★硬编码 text-0，`_buildNTag` 走 `global.colors.colorText0`（死变量 `-maxTagCount-default` 不消费） |
| （调用点）wrapper padding / tag margin | tagInput.scss:137/:143/:180 — `$spacing-extra-tight` | 4px（`_TagInputMetrics.extraTight`；RTL 标签 margin 翻左 4/右 0） |
| （调用点）prefix/suffix icon margin | tagInput.scss:299 — `$spacing-tight` | 8px（`_TagInputMetrics.tight`） |
| （调用点）typo / +N 字号 | tagInput.scss:170/:179 — `$font-size-small` | 12px（`_TagInputMetrics.fontSizeSmall`；标签文字自带 SemiTag 的 fontSizeSmall） |

## 差异清单

照搬留档（★，刻意与上游一致的行为）：

- **★保留值不 trim、空段丢弃**：`item.trim() !== ''` 判定丢弃空段，但保留段原样入库（' a ' 不裁剪）。
- **★allowDuplicates 默认 true**：仅 false 时过滤（含批内重复，保留首个）。
- **★`+N` 片色硬编码 `var(--semi-color-text-0)`**：`$color-tagInput-maxTagCount-default` 上游未消费（死变量）。
- **★`-prefix-text` 色走 `-prefix-default` 通道**：`$color-tagInput_prefix-text-default` 上游未消费（死变量）。
- **★maxLength 拒绝仅看分段增长**：删除/缩短放行（`_checkInputChangeValid` 逐段对比新旧值）。
- **★IME 组合结束跳过 `onInputChange`**（Firefox workaround）；数组 separator 重拼按 JS ToString 折 `','` 连接形。
- **★Backspace 空输入删最后一个标签**：无多段选中删除。
- **★标签默认尺寸映射 Tag.large**：`size === 'small' ? small : large`（index.tsx renderTag）。
- **★Tag close preventDefault**：值驱动可见性（受控不更新则不消失）。
- **★清空不发 onRemove**：只 `onChanged([])` / `onInputChange('')`。
- **★拖拽原位放下不发 onChanged**：上游 `onSortEnd` 仅 `activeIndex !== overIndex`；落点恰一次 `onChanged(reordered)`，无 onSort。
- **★dnd id 为标签 value**：重复值上游排序不可靠（docs 注记；本移植按索引计算落点）。
- **★`$color-tagInput-border-hover: transparent ` 尾随空格**：provenance 原文照抄。
- **★aria-invalid 仅 error**：`SemanticsValidationResult.invalid` 仅 error（index.tsx:692），success/warning → none。
- **★`$z-tagInput_drag_item_move: 2000 !default`**：`!default` 原文保留；z-index 字段留档不消费（见 A 表）。

偏差（不移植/调整）：

- **★GDSFP `value` 键存在但 falsy → 清空 tags 不移植**：Dart 无 present-but-null；`value == null` 即非受控（差异：上游 `value: undefined/null` 显式清空的写法在本移植等同未传）。
- **★`active` 以焦点近似**：上游 active=点入根内/点外清除（click-outside handler）；本移植用子树焦点（聚焦显示拖拽手柄与 +N 展开、失焦折叠）；根点击聚焦输入（≈置 active）。Flutter 里点非可聚焦区不失焦，故「点外立即收起」仅在焦点真实迁移时发生（视觉等价近似）。
- **★清空在受控下不落地**：上游 `handleClearBtn` 连受控也 setState（GDSFP 回滚）；本移植统一受控惯例——恒通知 + 非受控缓冲落地，受控渲染跟随 value。
- **输入行 flex-grow 空态近似**：上游空输入 `flex-grow: 1` 撑满余行、非空按镜像 `scrollWidth + 2`；本移植统一按镜像量宽收束（Wrap 无逐子 flex-grow，最小 2px）。
- **拖拽浮层 z-index 无对应**：`z-tagInput_drag_item_move` 字段留档；浮层为尾位 Stack 子（天然置顶）。拖拽过程不实时重排（上游 dnd-kit 实时挪位），落点竖线 + 源 0.5 透明 + 跟随克隆件为视觉近似，onChanged 仍在落点一次。
- **warning/danger 的 CSS `:hover` 字面级联不移植**：disabled 时 hover/focus 行视觉整块关闭（契约「blocks everything」压过 `.semi-tagInput-warning:hover` 对 disabled 的字面级联残效）。
- **onKeyDown / restTagsPopoverProps / preventScroll / insetLabelId 未移植**：事件对象裁剪/样式透传类（onKeyDown 语义由内部键处理承接）。`showContentTooltip` 的截断判定简化为恒显 hover tooltip（API 节注明）。
- **`+N` 片按 tagInput.scss 原样渲染**（Text + padding），不复用 select 的 SemiTag 包装（视觉字段不同）；tooltip 列表沿用 select `_buildNTag` 先例。
- **style / className / id / aria-\* 透传简化**：样式走私有 theme patch / 外层 Widget；语义以 `Semantics(enabled:, validationResult:)` + semanticsLabel 表达。
- **Form.TagInput 延后**：受控/重置走 value 惯例，无表单集成本体。

```dart
SemiTagInput(
  value: tags,                          // List<String>? 非空即受控
  defaultValue: const ['a', 'b'],       // 非受控种子
  separator: ',',                       // String | num | List<String> | null
  allowDuplicates: false,               // 默认 true（★上游默认）
  max: 5,
  maxLength: 12,
  maxTagCount: 3,
  showClear: true,
  size: SemiInputSize.small,            // small / normal / large
  validateStatus: SemiInputStatus.error,
  onChanged: (v) => print(v),            // 全量新数组
  onAdd: (batch) => print(batch),
  onRemove: (v, i) => print('$v@$i'),
);
// 局部主题：SemiTagInputTheme(data: const SemiTagInputThemeData(heightTagInputSmall: 28), child: ...)
```
