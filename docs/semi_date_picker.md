# SemiDatePicker

非 Material 日期选择器（上游 Semi DatePicker），Sass 全量落地（223 = 220 FIELDS + 3 MOTION + 0 INTERNAL，见 tool/generate_date_picker.py）。值模型 `Object?`：`value/defaultValue` 接受 `DateTime | String | num(毫秒时间戳) | List`（range 类型取两元素）；`value != null` 即受控（项目惯例，渲染恒跟随 value、只发事件，`open != null` 同理控制面板）；★`value === 0` 是合法时间戳（`_parseValue` `new Date(0)`），解析不出的元素静默丢弃（上游 warning 后跳过；上游对非 Date/字符串/数字抛 TypeError——本移植归一为丢弃，差异清单）。`onChanged(void Function(Object? date, String? dateStr))`：date 为 `DateTime`（单值类型）/ `List<DateTime>`（range 类型）/ `null`（清空）；dateStr 为格式化文本（range 用 `rangeSeparator` 连接），清空时为 `''`；★固定参数序（date 在前，上游 `onChangeWithDateFirst` 反转开关延期）；★range 半选**不**发（空数组算完整、会发——清空/空预设依赖）。格式化管线（date-fns 子集私有工具）：token `yyyy`/`MM`/`dd`（+ 字面量），各类型默认 format：date/dateRange `'yyyy-MM-dd'`、month/monthRange `'yyyy-MM'`、year `'yyyy'`（★上游 `getDefaultFormatTokenByType` 无 year 条目、`formatDates` 无 year 分支——本移植补 `'yyyy'`）；★解析必须 round-trip（parse→format === 输入）才受理；★超过 4 位的年份拒绝（parser.ts:28 `yearInvalid`）；★无效/空输入提交（Enter）回退到 state value，再空则 `DateTime.now()` / `[now, now]`；解析链 = format parse → ISO → 毫秒时间戳。`rangeSeparator` 默认 `' ~ '`。

面板：date = 月网格（getWeeks——首行空位定位 1 日、行数 4-6 **不**补齐（月视图行数按 `(dow-weekStartsOn+7)%7 + 当月天数` 上取整，Feb 平年 4/5 行、31 月可 6 行），`weekStartsOn` 0-6（默认 0/周日，星期标签整体旋转）；dateRange = 双月网格）。month/monthRange/year = 年/月选择器（上游 ScrollList 滚轮机制简化为可选列表——差异清单）。日状态：today（primary 文字 + 加粗）、selected（primary 底 + 白字）、selected-start/-end（外侧圆角 + `day-marginX` 内缩）、disabled（disabled-text；★纯 disabled 日**透明底**，disabled-fill 只刷「disabled 且带 selected/hover 类」的格子（datePicker.scss:536-570）；+ range-side linking：一旦对侧已选**且**其输入聚焦过（focusRecordsRef），越界日禁用（month.tsx:109-128））、inrange/inhover（`isBetween` **严格**开区间，端点不含——isBetween.ts）、hoverday/hoverday 系列预览类（悬停路径 primary-light-default、hover 格 fill-1、hoverday-inrange/beforerange/afterrange/around-singleselected primary-light-active）。

导航：双箭头跨年、单箭头跨月、月份标题按钮开年/月选择浮层；`syncSwitchMonth`（默认 false）锁定双面板同移并隐藏内侧按钮（visibility:hidden 占位）；★否则任何导航后**另一面板**若会同月则被推开一格（monthsGridFoundation.ts:318-329 handleSyncChangeMonths）；★`autoSwitchDate`（默认 true）：年/月切换后选中值跟随进新月（日按月末钳制，如 01-31 → 02-29）且不关面板，`disabledDate` 拒绝则中止；★仅单值类型跟随（上游 `includeRange` 读错变量恒 false 的死代码——docs 详注）。range 选取流：首点置 start 并聚焦 end 输入；★end 早于 start → start 置空并回焦 start（picked 日成为 end，monthsGridFoundation.ts:685-700）；start 晚于 end → end 置空；★面板仅在「两端都点过 **且** 两输入都至少聚焦过一次」才收（focusRecordsRef + `setTimeout(0)` 延迟打点——该次点选的关闭检查看不到本次打点）；受控下半选仍更新输入显示、不动 value（#1357）。

预设：`presets: List<SemiDatePickerPreset>`（`SemiDatePickerPreset({text?, start, end})`，值为 `Object?` 或 `Object? Function()`——★惰性求值、点击时调用），`presetPosition: left|right|top|bottom`（默认 bottom；left/right 带 header，用 `presetHeader` 参数（默认 `'快捷选择'`，上游 `locale.presets` zh_CN 原文）；★`{start:null,end:null}` 预设 = 清空 range（onChanged `(null, '')`）**并**关面板；disabled-date 预设不通知；`onPresetClick` 恒触发。列数：left/right 2 列、top/bottom 3 列（单值）/5 列（range）/2 列（month）；★monthRange 不渲染预设（上游 "todo" 缺口）。

触发器：单值 = SemiInput + 后缀 `SemiIcons.calendar`（primary 色）+ `inputReadOnly`；range = 双输入 + 分隔符 + 清空钮 + 后缀（renderRangeInput 几何：prefix 槽、-start 包装、separator、-end 包装、clear、suffix）；★`showClear` 默认 **true**（按钮本体悬浮/聚焦且非空才现身——TagInput 清空可见性先例）；Enter 提交输入、range-end 上 Tab 失焦（`handleRangeEndTabPress`）；★面板无方向键网格导航（上游 click-only）。`disabledDate(date, SemiDatePickerRangeInfo)`——info = `{rangeStart, rangeEnd, rangeInputFocus}`（上游 `'yyyy-MM-dd' | ''` 字符串，本移植 `DateTime?`/null + `SemiDatePickerRangeFocus?`，差异清单）；range 类型按 `startOfDay(date)` 判（时间忽略）。

开关模型：`open/defaultOpen` + `onOpenChange(bool)`；点触发器开面板；★点外恒关（上游 `needConfirm` 时点外不关——needConfirm 随 dateTime 类型延期，故恒关）；受控 `open` 的关闭只重置内部状态。回调：`onPanelChange(DateTime visibleDate, String text)`（月网格面板的年/月导航；range 上游报 `[left, right]` 两元组——本移植报**被导航面板**的可见月，差异清单；month/monthRange/year 类型上游不发 onPanelChange）、`onClear`、`onBlur`、`onFocus`、`onPresetClick`。语义：`role=combobox` 对应根 `Semantics(button:)`（label "Choose date"/"Change date"）、日格 `gridcell` 对应 `Semantics(button:, selected:, enabled:)` + `title=fullDate` 语义 label、导航钮 label "Previous year"/"Previous month"/"Next month"/"Next year"（navigation.tsx）、清空钮 "Clear range input value"。RTL：箭头翻转（Transform.flip 对应上游 `scaleX(-1)`）、range 槽位方向化布局、默认位置变 bottomRight（datePicker.tsx:864-866）。`SemiDatePickerController`：`open()/close()/focus([rangeEnd])/blur()`（attach/detach 先例，脱离后 no-op）。

## API

`SemiDatePicker({key, type, value, defaultValue, format, disabledDate, onChanged, onOpenChange, onPanelChange, onClear, onBlur, onFocus, onPresetClick, open, defaultOpen, presets, presetPosition, presetHeader, weekStartsOn, autoSwitchDate, syncSwitchMonth, size, validateStatus, disabled, borderless, inputReadOnly, showClear, placeholder, prefix, insetLabel, inputStyle, rangeSeparator, position, autoAdjustOverflow, motion, autofocus, semanticsLabel, controller})`。

type `SemiDatePickerType`（date/dateRange/month/monthRange/year；dateTime/dateTimeRange 延期）。value/defaultValue `Object?`（非空即受控）。format `String?`（yyyy/MM/dd token）。disabledDate `bool Function(DateTime, SemiDatePickerRangeInfo)?`。size `SemiInputSize`（small/normal/large——range 触发器 large=40px）、validateStatus `SemiInputStatus`（★success 上游无视觉）、disabled/borderless/inputReadOnly/showClear（默认 true）/autofocus false。placeholder `Object?`（String 或 `List<String>`——range 起止各一）。prefix/insetLabel `Object?`（String|Widget，SemiInput 槽位惯例）、inputStyle `TextStyle?`（叠加在 13px 之上）。rangeSeparator `' ~ '`。position `SemiTooltipPosition?`（默认 LTR bottomLeft / RTL bottomRight）、autoAdjustOverflow true、motion true。presetHeader `String?`（默认 `'快捷选择'`）。weekStartsOn `int` 0-6（默认 0）。autoSwitchDate true、syncSwitchMonth false。controller `SemiDatePickerController?`。静态 `SemiDatePicker.dayKey(DateTime)` / `presetKey(int)` / `clearButtonKey` / `navPrevYearKey` / `navPrevMonthKey` / `navNextMonthKey` / `navNextYearKey` / `monthTitleKey` / `monthTitleRightKey` / `yamBackKey` 供测试定位。

回调：onChanged `SemiDatePickerChanged?`（`void Function(Object? date, String? dateStr)`——见上）；onOpenChange `ValueChanged<bool>?`；onPanelChange `void Function(DateTime visibleDate, String text)?`；onClear/onBlur/onFocus `VoidCallback?`（上游事件对象裁剪）；onPresetClick `void Function(SemiDatePickerPreset)?`。

## 行为

### 值解析与格式化（date-fns 子集）

`_parseValue`：DateTime 原样；num → 毫秒时间戳（★0 合法）；String → compatibleParse（format 优先，失败转 ISO，再转时间戳；★>4 位年拒绝）；其他 → null（上游 TypeError，本移植丢弃）。`parseInput`（输入提交通道）：★严格 round-trip——`format(parse(input)) === input` 才受理；range 按 `rangeSeparator` 切段、每段各自 round-trip、整体失败即无效、有效则按日期升序排序（formatDates 不排序、按 [start, end] 原位格式化）。`parseInputLoose`：坏段留 null 槽（预览半选 range 用）。format：yyyy（≥4 位不截断）/MM/dd 置换 + 字面量。

### 月网格（getWeeks）

空位数 = `(dow(1日) - weekStartsOn + 7) % 7`（date-fns `e` token 实测 1 基，见 weekStartUpdates.test.jsx 的 Feb-2026 4/5 行断言）；行数 = ceil((空位 + 当月天数)/7)，★不补齐。星期标签 `['日','一','二','三','四','五','六']`（zh 硬编码，locale 延期）按 weekStartsOn 旋转。周行高 `weeksRowNum * WEEK_HEIGHT`（36，month.tsx:293）。日格 36×36（`width-datepicker_day`）、内格 32×32 圆角 3（`width-datepicker_day_main-borderRadius`）；today 加粗 primary 文字；selected primary 底白字；selected-start/-end 外侧圆角 + 左/右内缩 `spacing-datepicker_day-marginX`（2px）；inrange/inhover/hoverday 等整行宽无圆角（datePicker.scss:395-402）。

### range 选取流（★起点/终点互换重置）

focus == rangeEnd 时点日 → end = 该日；若 end < start → ★start 置空（该日成为 end）并回焦 start。focus == rangeStart/未聚焦时 → start = 该日；若 end < start → end 置空并前焦 end。下一步焦点：`isAnotherPanelHasOpened`（另一输入的 focusRecord）已置位且对侧有值则保持，否则切到对侧。★关闭条件（foundation.ts:1019）：`type === 'date'` 单选关；`type === 'dateRange'` 且值完整且 `couldPanelClosed()`（两输入至少各聚焦过一次，打点 `setTimeout(0)`）才关——★month/monthRange/year 的选中**不**自动关面板（上游 close 块只覆盖 date/dateRange，忠实照搬）。受控下半选只回显输入（#1357）。

### 导航与 autoSwitchDate

双箭头 ±1 年、单箭头 ±1 月；syncSwitchMonth 时双面板同移（内侧按钮 `visibility: hidden` 占位——Opacity(0)+IgnorePointer 近似）并只发一次 onPanelChange；否则单面板移动后 ★同月互斥：另一面板同月即被推开 1 月（handleSyncChangeMonths）。月份标题开 yam 浮层：选年/月按「日历月差」步进导航（toYearMonth，不超调）且 ★浮层**不**自动收起（yearSelectionCallbacks 测试连点年+月、onPanelChange 两次），返回钮（'返回选择日期'）回网格。autoSwitchDate：导航后单值选中跟随（月末钳制：01-31 → 02-29）、disabledDate 拒绝即中止、不关面板；★range 不跟随（上游 includeRange 死代码）。

### 预设

点击：惰性函数求值 → 值解析 → `handleSelectedChange(..., needCheckFocusRecord: false, fromPreset: true)`；★null 预设（range 两端皆 null）→ `onChanged(null, '')` + 关面板（空数组算完整）；disabled-date 预设不通知不清值；受控也落地（fromPreset 分支）；`onPresetClick` 恒触发（先通知后回调序同上游）。列几何走 presetPanel `_content`/`_button` 链（两列 84px、三列 75.924px、五列 99.2px 等 themed 字段）；CSS grid 的 5px/3px 滚动条让位以 Wrap 间距近似。

### 输入键盘

Enter 提交（`handleInputComplete`：解析 → 回退 state value → 回退 now/[now,now]，落值 + 变更即通知）；range 两输入编辑同一连接串（join 后走 parseInput）；★Tab 于 range-end 失焦（rangeInputFocus 置 false）；无方向键网格导航（上游 click-only）。

### 清空

showClear 默认 true；单值 = SemiInput 自带清空钮（悬浮/聚焦 + 非空才现）、range = 独立 clearbtn（hover/active + 有值才现，hover 时顶替后缀——dateInput.tsx:955/1015）。点击清值+清输入+ `onChanged(null, '')` + `onClear`（★清空不发 onRemove 类回调、payload 归一为 null/''——上游按类型发 undefined/[]，差异清单）。

### 视觉状态矩阵（range 触发器）

wrapper 底/描边按 validateStatus 走 `_warning`/`_danger` 字段组：normal（fill-0 底、透明描边、active 转 focus-border + fill-1）、warning（warning-light-default 底、active 转 warning 描边 + warning-light-hover 底）、error（★底色取 `colorDatepickerRangeInputErrorBorderDefault`——上游 scss 误用 border 字段当背景（datePicker.scss:1068），`-error-bg-default` 因此是死变量）、disabled（disabled-fill 底 + disabled-text 字）。内层 inputWrapper 聚焦转 fill-1（warning/error 转各自 -bg-active）。分隔符有值时转 text-0（`-separator-text-active`）。前缀/后缀/清空钮 w600 14px text-2（`font-*-fontWeight/fontSize/lineHeight` 字段）。触发输入统一 13px（datePicker.scss:844）；large range 输入 16px（`font-datepicker_range_input_large-fontSize`）。

### 语义与 RTL

根 `Semantics(button:, enabled:, label: "Choose date"/"Change date")`（datePicker.tsx:722）；日格 `Semantics(button:, selected:, enabled:, label: yyyy-MM-dd)`（gridcell 对应）；导航钮带 "Previous year" 等 label；清空钮 "Clear range input value"。RTL：箭头 `Transform.flip`（上游 rtl.scss `scaleX(-1)`）、触发器 Row 自动方向化、默认位置 bottomRight（datePicker.tsx:864-866）、日格 selected-start/-end 内缩方向化由 Center 布局限制（差异清单）。

## 主题（223 对账）

来源 packages/semi-foundation/datePicker/variables.scss（220 声明行 / 220 唯一名——spacing 64、color 62、width 46、height 37、font 5、radius 2、lineHeight 2、transition 1、fontSize 1；无重复）与 animation.scss（3 声明：date-bg 过渡三元组）。对账 **223 = 220 FIELDS + 3 MOTION + 0 INTERNAL**（datePicker 的 animation.scss 无 transform token，故 INTERNAL=0；HARDCODES 另列见 B 表）。220 FIELDS 含 10 条事实死变量（标注「（上游未消费）」）：`$width-datepicker_quick_control-borderRadius`、`$spacing-datepicker_range_input-paddingY`、`$color-datepicker_panel-bg-default`、`$color-datepicker_day-text-hover`、`$color-datepicker_date-text-hover`、`$color-datepicker_date-text-active`、`$color-datepicker_range_input_warning-border-hover`、`$color-datepicker_range_input_error-bg-default`、`$color-datepicker_range_input_error-border-hover`、`$spacing-datepicker_compact-padding`——保留 theme 字段但 widget 不消费（净效果一致）；3 条 MOTION 同为事实死变量（date-bg 过渡无任何规则引用）同样留档不消费。另 9 字段（5 组，标注「（仅派生链消费）」）只被其他变量派生链引用（无规则直接消费）：`$height-datepicker_switch`、`$spacing-datepicker_month_compact-padding`、`$width-datepicker_presetPanel_left_and_right_content`、`$width-datepicker_presetPanel_top_and_bottom_content_{date,range,month}` 及其 `_compact` 三兄弟。quirk：`paddint*` 拼写笔误（203-205，provenance 原文照抄）、跨组件名 `$spacing-scrollList_item_wheel_list_outer-paddingRight`（80）原样保留、两条 `calc(100% - 54px)` 与四条 `100%` 高度按数值 46/46/100/100/100/100 落地（★`100%` 数值化按 100，time/insetInput 面板延期不消费）、`$width-datepicker_*-borderRadius` 名义是 width 实为圆角、`$width-datepicker_slot-border`/`-day_main-border`/`-range_input-border`/`-range_trigger-border` 实为描边宽度、★`height-datepicker_insetInput_compact`（190）与 `height-datepicker_inset_input_compact`（261）naive camel 同名冲突（`insetInput` vs `inset_input` 拼写差）——261 行派生字段后缀 `Derived`。解析列即 `SemiDatePickerThemeData.resolve` 的默认表达式；`transparent`/`var(--semi-color-white)` 走字面量、`var(--semi-border-radius-*)` 走 `theme.radius.*.value`、`var(--semi-color-*)` 走 `theme.colors.*`、派生 `calc`/四则运算走数值等价（test_generate_date_picker.py `eval_default` 数值断言）。

### A. Sass 声明映射（220 FIELDS + 3 MOTION = 223）

| Sass 声明（默认值） | 字段 | 解析 / 说明 |
|---|---|---|
| `$width-datepicker_day: 36px` | `widthDatepickerDay` | `36` |
| `$width-datepicker_day_main: 32px` | `widthDatepickerDayMain` | `32` |
| `$width-datepicker_month: $width-datepicker_day * 7` | `widthDatepickerMonth` | `252` |
| `$width-datepicker_nav: 32px` | `widthDatepickerNav` | `32` |
| `$height-datepicker_switch: 54px` | `heightDatepickerSwitch` | `54`（仅派生链消费） |
| `$height-datepicker_timeType_yam: calc(100% - 54px)` | `heightDatepickerTimeTypeYam` | `46`（★`100%` 数值化按 100：46 = 100-54；time 面板延期、widget 不消费） |
| `$height-datepicker_timeType_tpk: calc(100% - 54px)` | `heightDatepickerTimeTypeTpk` | `46`（★`100%` 数值化按 100：46 = 100-54；time 面板延期、widget 不消费） |
| `$height-datepicker_panel_yam_scrolllist: 266px` | `heightDatepickerPanelYamScrolllist` | `266` |
| `$width-datepicker_monthPanel_max: 284px` | `widthDatepickerMonthPanelMax` | `284` |
| `$width-datepicker_monthRangePanel_max: 384px` | `widthDatepickerMonthRangePanelMax` | `384` |
| `$height-datepicker_timepicker_header_min: 24px` | `heightDatepickerTimepickerHeaderMin` | `24` |
| `$width-datepicker_navigation_button_min: 32px` | `widthDatepickerNavigationButtonMin` | `32` |
| `$height-datepicker_yamShowing_min: 378px` | `heightDatepickerYamShowingMin` | `378` |
| `$width-datepicker_yamShowing_min: 284px` | `widthDatepickerYamShowingMin` | `284` |
| `$height-datepicker_dateType_yamShowing_min: 325px` | `heightDatepickerDateTypeYamShowingMin` | `325` |
| `$width-datepicker_panel_yam_scrolllist_li_min: 64px` | `widthDatepickerPanelYamScrolllistLiMin` | `64` |
| `$width-datepicker_presetPanel_left_and_right: 200px` | `widthDatepickerPresetPanelLeftAndRight` | `200` |
| `$height-datepicker_presetPanel_top_and_bottom_max: 100px` | `heightDatepickerPresetPanelTopAndBottomMax` | `100` |
| `$width-datepicker_presetPanel_scroll_bar: 15px` | `widthDatepickerPresetPanelScrollBar` | `15` |
| `$width-datepicker-border: $border-thickness-control` | `widthDatepickerBorder` | `1` |
| `$width-datepicker_yam_header-borderRadius: var(--semi-border-radius-medium)` | `widthDatepickerYamHeaderBorderRadius` | `theme.radius.borderRadiusMedium.value` |
| `$width-datepicker_day_main-borderRadius: var(--semi-border-radius-small)` | `widthDatepickerDayMainBorderRadius` | `theme.radius.borderRadiusSmall.value` |
| `$width-datepicker_quick_control-borderRadius: var(--semi-border-radius-medium)` | `widthDatepickerQuickControlBorderRadius` | `theme.radius.borderRadiusMedium.value`（上游未消费） |
| `$width-datepicker_slot-border: 1px` | `widthDatepickerSlotBorder` | `1` |
| `$width-datepicker_range_input-border: $border-thickness-control-focus` | `widthDatepickerRangeInputBorder` | `1` |
| `$width-datepicker_day_main-border: 1px` | `widthDatepickerDayMainBorder` | `1` |
| `$height-datepicker_timeType_insetInput_yam: 100%` | `heightDatepickerTimeTypeInsetInputYam` | `100`（★`100%` 数值化按 100；insetInput 延期、widget 不消费） |
| `$height-datepicker_timeType_insetInput_tpk: 100%` | `heightDatepickerTimeTypeInsetInputTpk` | `100`（★`100%` 数值化按 100；insetInput 延期、widget 不消费） |
| `$width-datepicker_insetInput_date_type_wrapper: 284px` | `widthDatepickerInsetInputDateTypeWrapper` | `284` |
| `$width-datepicker_insetInput_date_range_type_wrapper: $width-datepicker_insetInput_date_type_wrapper * 2` | `widthDatepickerInsetInputDateRangeTypeWrapper` | `568` |
| `$width-datepicker_insetInput_month_type_wrapper: 165px` | `widthDatepickerInsetInputMonthTypeWrapper` | `165` |
| `$width-datepicker_insetInput_month_range_type_wrapper: 331px` | `widthDatepickerInsetInputMonthRangeTypeWrapper` | `331` |
| `$height-datepicker_insetInput_separator: 32px` | `heightDatepickerInsetInputSeparator` | `32` |
| `$height-datepicker_month_grid_yearType_insetInput: 317px` | `heightDatepickerMonthGridYearTypeInsetInput` | `317` |
| `$height-datepicker_month_grid_timeType_insetInput: 317px` | `heightDatepickerMonthGridTimeTypeInsetInput` | `317` |
| `$width-datepicker_range_trigger-border: 0px` | `widthDatepickerRangeTriggerBorder` | `0` |
| `$spacing-datepicker_day-marginX: ($width-datepicker_day - $width-datepicker_day_main) * 0.5` | `spacingDatepickerDayMarginX` | `2` |
| `$spacing-datepicker_yam_header-paddingX: $spacing-base` | `spacingDatepickerYamHeaderPaddingX` | `16` |
| `$spacing-datepicker_yam_header-paddingY: $spacing-base-tight` | `spacingDatepickerYamHeaderPaddingY` | `12` |
| `$spacing-datepicker_scrolllist_header-padding: $spacing-base` | `spacingDatepickerScrolllistHeaderPadding` | `16` |
| `$spacing-datepicker_scrolllist_body-padding: 0` | `spacingDatepickerScrolllistBodyPadding` | `0` |
| `$spacing-datepicker_footer-paddingTop: 10px` | `spacingDatepickerFooterPaddingTop` | `10` |
| `$spacing-datepicker_footer-paddingBottom: 10px` | `spacingDatepickerFooterPaddingBottom` | `10` |
| `$spacing-datepicker_footer-paddingRight: 8px` | `spacingDatepickerFooterPaddingRight` | `8` |
| `$spacing-datepicker_footer_cancel_button-marginRight: 12px` | `spacingDatepickerFooterCancelButtonMarginRight` | `12` |
| `$spacing-datepicker_footer_confirm_button-marginRight: 8px` | `spacingDatepickerFooterConfirmButtonMarginRight` | `8` |
| `$spacing-datepicker_navigation-paddingY: $spacing-base-tight` | `spacingDatepickerNavigationPaddingY` | `12` |
| `$spacing-datepicker_navigation-paddingX: $spacing-base` | `spacingDatepickerNavigationPaddingX` | `16` |
| `$spacing-datepicker_month-padding: $spacing-base` | `spacingDatepickerMonthPadding` | `16` |
| `$spacing-datepicker_switch_datetime-paddingTop: $spacing-base` | `spacingDatepickerSwitchDatetimePaddingTop` | `16` |
| `$spacing-datepicker_switch_datetime-paddingBottom: $spacing-base` | `spacingDatepickerSwitchDatetimePaddingBottom` | `16` |
| `$spacing-datepicker_switch_text-paddingLeft: $spacing-tight` | `spacingDatepickerSwitchTextPaddingLeft` | `8` |
| `$spacing-datepicker_quick_control_header-paddingTop: 18px` | `spacingDatepickerQuickControlHeaderPaddingTop` | `18` |
| `$spacing-datepicker_quick_control_top_and_bottom_content-paddingX: $spacing-base-loose` | `spacingDatepickerQuickControlTopAndBottomContentPaddingX` | `20` |
| `$spacing-datepicker_quick_control_content-paddingX: 12px` | `spacingDatepickerQuickControlContentPaddingX` | `12` |
| `$spacing-datepicker_quick_control_content-marginTop: 14px` | `spacingDatepickerQuickControlContentMarginTop` | `14` |
| `$spacing-datepicker_quick_control_item-margin: $spacing-tight` | `spacingDatepickerQuickControlItemMargin` | `8` |
| `$spacing-datepicker_range_input-paddingX: 8px` | `spacingDatepickerRangeInputPaddingX` | `8` |
| `$spacing-datepicker_range_input-paddingY: 3px` | `spacingDatepickerRangeInputPaddingY` | `3`（上游未消费） |
| `$spacing-datepicker_range_input_inputWrapper_input-paddingY: 2px` | `spacingDatepickerRangeInputInputWrapperInputPaddingY` | `2` |
| `$spacing-datepicker_range_input_inputWrapper_input-paddingX: 4px` | `spacingDatepickerRangeInputInputWrapperInputPaddingX` | `4` |
| `$spacing-datepicker_range_input_prefix-paddingLeft: 12px` | `spacingDatepickerRangeInputPrefixPaddingLeft` | `12` |
| `$spacing-datepicker_range_input_prefix-paddingRight: 8px` | `spacingDatepickerRangeInputPrefixPaddingRight` | `8` |
| `$spacing-datepicker_range_input_suffix-paddingLeft: 8px` | `spacingDatepickerRangeInputSuffixPaddingLeft` | `8` |
| `$spacing-datepicker_range_input_suffix-paddingRight: 12px` | `spacingDatepickerRangeInputSuffixPaddingRight` | `12` |
| `$spacing-datepicker_range_input_clearbtn-paddingLeft: 8px` | `spacingDatepickerRangeInputClearbtnPaddingLeft` | `8` |
| `$spacing-datepicker_range_input_clearbtn-paddingRight: 12px` | `spacingDatepickerRangeInputClearbtnPaddingRight` | `12` |
| `$spacing-datepicker_navigation_insetInput-paddingY: 8px` | `spacingDatepickerNavigationInsetInputPaddingY` | `8` |
| `$spacing-datepicker_insetInput_wrapper-margin: 8px` | `spacingDatepickerInsetInputWrapperMargin` | `8` |
| `$spacing-datepicker_insetInput_wrapper-paddingY: 12px` | `spacingDatepickerInsetInputWrapperPaddingY` | `12` |
| `$spacing-datepicker_insetInput_wrapper-paddingX: 16px` | `spacingDatepickerInsetInputWrapperPaddingX` | `16` |
| `$spacing-datepicker_insetInput_wrapper-paddingBottom: 0` | `spacingDatepickerInsetInputWrapperPaddingBottom` | `0` |
| `$spacing-datepicker_insetInput_separator-paddingY: 0` | `spacingDatepickerInsetInputSeparatorPaddingY` | `0` |
| `$spacing-datepicker_insetInput_separator-paddingX: 4px` | `spacingDatepickerInsetInputSeparatorPaddingX` | `4` |
| `$spacing-scrollList_item_wheel_list_outer-paddingRight: 18px` | `spacingScrollListItemWheelListOuterPaddingRight` | `18`（★跨组件命名原文照抄） |
| `$color-datepicker_panel-bg-default: var(--semi-color-bg-3)` | `colorDatepickerPanelBgDefault` | `theme.colors.colorBg3`（上游未消费） |
| `$color-datepicker_header-bg-default: var(--semi-color-bg-3)` | `colorDatepickerHeaderBgDefault` | `theme.colors.colorBg3` |
| `$color-datepicker_list-bg-default: var(--semi-color-bg-3)` | `colorDatepickerListBgDefault` | `theme.colors.colorBg3` |
| `$color-datepicker_border-bg-default: var(--semi-color-border)` | `colorDatepickerBorderBgDefault` | `theme.colors.colorBorder` |
| `$color-datepicker_footer-bg-default: var(--semi-color-fill-0)` | `colorDatepickerFooterBgDefault` | `theme.colors.colorFill0` |
| `$color-datepicker_quick-bg-default: transparent` | `colorDatepickerQuickBgDefault` | `const Color(0x00000000)` |
| `$color-datepicker_quick_button-text-default: var(--semi-color-primary)` | `colorDatepickerQuickButtonTextDefault` | `theme.colors.colorPrimary` |
| `$color-datepicker_day-text-default: var(--semi-color-text-2)` | `colorDatepickerDayTextDefault` | `theme.colors.colorText2` |
| `$color-datepicker_day-text-hover: var(--semi-color-fill-1)` | `colorDatepickerDayTextHover` | `theme.colors.colorFill1`（上游未消费） |
| `$color-datepicker_day-text-active: var(--semi-color-text-0)` | `colorDatepickerDayTextActive` | `theme.colors.colorText0` |
| `$color-datepicker_date-text-default: var(--semi-color-text-0)` | `colorDatepickerDateTextDefault` | `theme.colors.colorText0` |
| `$color-datepicker_date-text-hover: var(--semi-color-text-0)` | `colorDatepickerDateTextHover` | `theme.colors.colorText0`（上游未消费） |
| `$color-datepicker_date-text-active: var(--semi-color-text-0)` | `colorDatepickerDateTextActive` | `theme.colors.colorText0`（上游未消费） |
| `$color-datepicker_date-bg-default: var(--semi-color-fill-0)` | `colorDatepickerDateBgDefault` | `theme.colors.colorFill0` |
| `$color-datepicker_date-bg-hover: var(--semi-color-fill-0)` | `colorDatepickerDateBgHover` | `theme.colors.colorFill0` |
| `$color-datepicker_date-bg-active: var(--semi-color-fill-1)` | `colorDatepickerDateBgActive` | `theme.colors.colorFill1` |
| `$color-datepicker_date_selected-text-default: var(--semi-color-white)` | `colorDatepickerDateSelectedTextDefault` | `const Color(0xffffffff)` |
| `$color-datepicker_date_selected-bg-default: var(--semi-color-primary)` | `colorDatepickerDateSelectedBgDefault` | `theme.colors.colorPrimary` |
| `$color-datepicker_date_disabled-text-default: var(--semi-color-disabled-text)` | `colorDatepickerDateDisabledTextDefault` | `theme.colors.colorDisabledText` |
| `$color-datepicker_date_disabled-bg-default: var(--semi-color-disabled-fill)` | `colorDatepickerDateDisabledBgDefault` | `theme.colors.colorDisabledFill` |
| `$color-datepicker_date_today-text-default: var(--semi-color-primary)` | `colorDatepickerDateTodayTextDefault` | `theme.colors.colorPrimary` |
| `$color-datepicker_date_today_disabled-text-default: var(--semi-color-primary-disabled)` | `colorDatepickerDateTodayDisabledTextDefault` | `theme.colors.colorPrimaryDisabled` |
| `$color-datepicker_date_inHover-bg-default: var(--semi-color-primary-light-default)` | `colorDatepickerDateInHoverBgDefault` | `theme.colors.colorPrimaryLightDefault` |
| `$color-datepicker_date_inRangeHover-bg-default: var(--semi-color-fill-0)` | `colorDatepickerDateInRangeHoverBgDefault` | `theme.colors.colorFill0` |
| `$color-datepicker_date_hoverDay-bg-default: var(--semi-color-fill-1)` | `colorDatepickerDateHoverDayBgDefault` | `theme.colors.colorFill1` |
| `$color-datepicker_date_selectedRange-bg-hover: var(--semi-color-primary-light-hover)` | `colorDatepickerDateSelectedRangeBgHover` | `theme.colors.colorPrimaryLightHover` |
| `$color-datepicker_date_hoverday_range-bg-default: var(--semi-color-primary-light-active)` | `colorDatepickerDateHoverdayRangeBgDefault` | `theme.colors.colorPrimaryLightActive` |
| `$color-datepicker_date_hoverday_around_single_selected-bg-default: var(--semi-color-primary-light-active)` | `colorDatepickerDateHoverdayAroundSingleSelectedBgDefault` | `theme.colors.colorPrimaryLightActive` |
| `$color-datepicker_nav_monthIcon-text-default: var(--semi-color-text-0)` | `colorDatepickerNavMonthIconTextDefault` | `theme.colors.colorText0` |
| `$color-datepicker_navIcon-text-default: var(--semi-color-text-2)` | `colorDatepickerNavIconTextDefault` | `theme.colors.colorText2` |
| `$color-datepicker_input_primary-text-default: var(--semi-color-primary)` | `colorDatepickerInputPrimaryTextDefault` | `theme.colors.colorPrimary` |
| `$color-datepicker_range_input-text-default: var(--semi-color-text-2)` | `colorDatepickerRangeInputTextDefault` | `theme.colors.colorText2` |
| `$color-datepicker_range_input-bg-default: var(--semi-color-fill-0)` | `colorDatepickerRangeInputBgDefault` | `theme.colors.colorFill0` |
| `$color-datepicker_range_input-bg-hover: var(--semi-color-fill-1)` | `colorDatepickerRangeInputBgHover` | `theme.colors.colorFill1` |
| `$color-datepicker_range_input-border-default: transparent` | `colorDatepickerRangeInputBorderDefault` | `const Color(0x00000000)` |
| `$color-datepicker_range_input-border-active: var(--semi-color-focus-border)` | `colorDatepickerRangeInputBorderActive` | `theme.colors.colorFocusBorder` |
| `$color-datepicker_range_input_warning-border-active: var(--semi-color-warning)` | `colorDatepickerRangeInputWarningBorderActive` | `theme.colors.colorWarning` |
| `$color-datepicker_range_input_warning-bg-active: var(--semi-color-warning-light-hover)` | `colorDatepickerRangeInputWarningBgActive` | `theme.colors.colorWarningLightHover` |
| `$color-datepicker_range_input_warning-bg-default: var(--semi-color-warning-light-default)` | `colorDatepickerRangeInputWarningBgDefault` | `theme.colors.colorWarningLightDefault` |
| `$color-datepicker_range_input_warning-bg-hover: var(--semi-color-warning-light-hover)` | `colorDatepickerRangeInputWarningBgHover` | `theme.colors.colorWarningLightHover` |
| `$color-datepicker_range_input_warning-border-default: var(--semi-color-warning-light-default)` | `colorDatepickerRangeInputWarningBorderDefault` | `theme.colors.colorWarningLightDefault` |
| `$color-datepicker_range_input_warning-border-hover: var(--semi-color-warning-light-hover)` | `colorDatepickerRangeInputWarningBorderHover` | `theme.colors.colorWarningLightHover`（上游未消费） |
| `$color-datepicker_range_input_error-border-default: var(--semi-color-danger-light-default)` | `colorDatepickerRangeInputErrorBorderDefault` | `theme.colors.colorDangerLightDefault`（★上游 error 行**背景**误用本 border 字段（datePicker.scss:1068）；`-error-bg-default` 因此成死变量） |
| `$color-datepicker_range_input_error-bg-default: var(--semi-color-danger-light-default)` | `colorDatepickerRangeInputErrorBgDefault` | `theme.colors.colorDangerLightDefault`（上游未消费） |
| `$color-datepicker_range_input_error-border-hover: var(--semi-color-danger-light-hover)` | `colorDatepickerRangeInputErrorBorderHover` | `theme.colors.colorDangerLightHover`（上游未消费） |
| `$color-datepicker_range_input_error-bg-hover: var(--semi-color-danger-light-hover)` | `colorDatepickerRangeInputErrorBgHover` | `theme.colors.colorDangerLightHover` |
| `$color-datepicker_range_input_error-border-active: var(--semi-color-danger)` | `colorDatepickerRangeInputErrorBorderActive` | `theme.colors.colorDanger` |
| `$color-datepicker_range_input_error-bg-active: var(--semi-color-danger-light-hover)` | `colorDatepickerRangeInputErrorBgActive` | `theme.colors.colorDangerLightHover` |
| `$color-datepicker_range_input_disabled-text-default: var(--semi-color-disabled-text)` | `colorDatepickerRangeInputDisabledTextDefault` | `theme.colors.colorDisabledText` |
| `$color-datepicker_range_input_disabled-bg-default: var(--semi-color-disabled-fill)` | `colorDatepickerRangeInputDisabledBgDefault` | `theme.colors.colorDisabledFill` |
| `$color-datepicker_range_input_disabled-bg-hover: var(--semi-color-disabled-fill)` | `colorDatepickerRangeInputDisabledBgHover` | `theme.colors.colorDisabledFill` |
| `$color-datepicker_range_input_clearbtn-icon-hover: var(--semi-color-primary-hover)` | `colorDatepickerRangeInputClearbtnIconHover` | `theme.colors.colorPrimaryHover` |
| `$color-datepicker_range_input_inputWrapper-border-default: transparent` | `colorDatepickerRangeInputInputWrapperBorderDefault` | `const Color(0x00000000)` |
| `$color-datepicker_range_input_inputWrapper-bg-default: transparent` | `colorDatepickerRangeInputInputWrapperBgDefault` | `const Color(0x00000000)` |
| `$color-datepicker_range_input_inputWrapper-bg-focus: var(--semi-color-fill-1)` | `colorDatepickerRangeInputInputWrapperBgFocus` | `theme.colors.colorFill1` |
| `$color-datepicker_range_input_separator-text-active: var(--semi-color-text-0)` | `colorDatepickerRangeInputSeparatorTextActive` | `theme.colors.colorText0` |
| `$color-datepicker_day_main-border: var(--semi-color-primary-active)` | `colorDatepickerDayMainBorder` | `theme.colors.colorPrimaryActive` |
| `$color-datepicker_insetInput_separator: var(--semi-color-text-3)` | `colorDatepickerInsetInputSeparator` | `theme.colors.colorText3` |
| `$color-datepicker_range_trigger-border: transparent` | `colorDatepickerRangeTriggerBorder` | `const Color(0x00000000)` |
| `$color-datepicker_range_trigger-border-hover: transparent` | `colorDatepickerRangeTriggerBorderHover` | `const Color(0x00000000)` |
| `$color-datepicker_range_trigger-border-active: transparent` | `colorDatepickerRangeTriggerBorderActive` | `const Color(0x00000000)` |
| `$color-datepicker_range_trigger-border-focus: transparent` | `colorDatepickerRangeTriggerBorderFocus` | `const Color(0x00000000)` |
| `$font-datepicker_range_input_prefix_suffix_clearbtn-fontWeight: 600` | `fontDatepickerRangeInputPrefixSuffixClearbtnFontWeight` | `600` |
| `$font-datepicker_preset_header-fontWeight: 600` | `fontDatepickerPresetHeaderFontWeight` | `600` |
| `$font-datepicker_range_input_prefix_suffix_clearbtn-fontSize: 14px` | `fontDatepickerRangeInputPrefixSuffixClearbtnFontSize` | `14` |
| `$font-datepicker_range_input_prefix_suffix_clearbtn-lineHeight: 20px` | `fontDatepickerRangeInputPrefixSuffixClearbtnLineHeight` | `20` |
| `$font-datepicker_range_input_large-fontSize: 16px` | `fontDatepickerRangeInputLargeFontSize` | `16` |
| `$spacing-datepicker_month_compact-padding: 10px` | `spacingDatepickerMonthCompactPadding` | `10`（仅派生链消费） |
| `$width-datepicker_day_compact: 28px` | `widthDatepickerDayCompact` | `28` |
| `$width-datepicker_day_main_compact: 24px` | `widthDatepickerDayMainCompact` | `24` |
| `$width-datepicker_day_compact-borderRadius: 4px` | `widthDatepickerDayCompactBorderRadius` | `4` |
| `$width-datepicker_month_compact: $width-datepicker_day_compact * 7 + $spacing-datepicker_month_compact-padding * 2` | `widthDatepickerMonthCompact` | `216` |
| `$width-datepicker_nav_compact: 24px` | `widthDatepickerNavCompact` | `24` |
| `$width-datepicker_panel_compact: 216px` | `widthDatepickerPanelCompact` | `216` |
| `$height-datepicker_switch_compact: 32px` | `heightDatepickerSwitchCompact` | `32` |
| `$height-datepicker_tpk_compact: 256px` | `heightDatepickerTpkCompact` | `256` |
| `$height-datepicker_yam_panel_compact: 256px` | `heightDatepickerYamPanelCompact` | `256` |
| `$height-datepicker_yam_li_compact: 32px` | `heightDatepickerYamLiCompact` | `32` |
| `$height-datepicker_yam_panel_header_compact: 48px` | `heightDatepickerYamPanelHeaderCompact` | `48` |
| `$radius-datepicker_range_input_inputWrapper: var(--semi-border-radius-small)` | `radiusDatepickerRangeInputInputWrapper` | `theme.radius.borderRadiusSmall.value` |
| `$height-datepicker_range_input-default: 32px` | `heightDatepickerRangeInputDefault` | `32` |
| `$height-datepicker_range_input-small: 24px` | `heightDatepickerRangeInputSmall` | `24` |
| `$height-datepicker_range_input-large: 40px` | `heightDatepickerRangeInputLarge` | `40` |
| `$width-datepicker_insetInput_date_type_wrapper_compact: 216px` | `widthDatepickerInsetInputDateTypeWrapperCompact` | `216` |
| `$width-datepicker_insetInput_date_range_type_wrapper_compact: $width-datepicker_insetInput_date_type_wrapper_compact * 2` | `widthDatepickerInsetInputDateRangeTypeWrapperCompact` | `432` |
| `$width-datepicker_insetInput_month_type_wrapper_compact: 195px` | `widthDatepickerInsetInputMonthTypeWrapperCompact` | `195` |
| `$height-datepicker_insetInput_tpk_compact: 100%` | `heightDatepickerInsetInputTpkCompact` | `100`（★`100%` 数值化按 100；insetInput 延期、widget 不消费） |
| `$height-datepicker_timeType_insetInput_yam_compact: 100%` | `heightDatepickerTimeTypeInsetInputYamCompact` | `100`（★`100%` 数值化按 100；insetInput 延期、widget 不消费） |
| `$height-datepicker_insetInput_wrapper_compact: 28px` | `heightDatepickerInsetInputWrapperCompact` | `28` |
| `$lineHeight-datepicker_compact: 20px` | `lineHeightDatepickerCompact` | `20` |
| `$lineHeight-datepicker_weekday_item_compact: 28px` | `lineHeightDatepickerWeekdayItemCompact` | `28` |
| `$height-datepicker_insetInput_compact: 26px` | `heightDatepickerInsetInputCompact` | `26`（★命名冲突对的 naive camel 保留方，见 261 行字段注） |
| `$fontSize-datepicker_insetInput_compact-fontSize: 12px` | `fontSizeDatepickerInsetInputCompactFontSize` | `12` |
| `$spacing-datepicker_switch_compact-padding: 6px` | `spacingDatepickerSwitchCompactPadding` | `6` |
| `$spacing-datepicker_day_compact-margin: ($width-datepicker_day_compact - $width-datepicker_day_main_compact) * 0.5` | `spacingDatepickerDayCompactMargin` | `2` |
| `$spacing-datepicker_weeks_compact-padding: 10px` | `spacingDatepickerWeeksCompactPadding` | `10` |
| `$spacing-datepicker_weeks_compact-paddingTop: $spacing-tight - 2px` | `spacingDatepickerWeeksCompactPaddingTop` | `6` |
| `$spacing-datepicker_weekday_compact-paddingLeft: 10px` | `spacingDatepickerWeekdayCompactPaddingLeft` | `10` |
| `$spacing-datepicker_weekday_compact-paddingRight: 10px` | `spacingDatepickerWeekdayCompactPaddingRight` | `10` |
| `$spacing-datepicker_weekday_compact-paddingBottom: $spacing-tight` | `spacingDatepickerWeekdayCompactPaddingBottom` | `8` |
| `$spacing-datepicker_compact-padding: 12px` | `spacingDatepickerCompactPadding` | `12`（上游未消费） |
| `$spacing-datepicker_nav_compact-padding: 12px` | `spacingDatepickerNavCompactPadding` | `12` |
| `$spacing-datepicker_yam_panel_header_compact-padding: 12px` | `spacingDatepickerYamPanelHeaderCompactPadding` | `12` |
| `$spacing-datepicker_footer_compact-paddintTop: 10px` | `spacingDatepickerFooterCompactPaddintTop` | `10` |
| `$spacing-datepicker_footer_compact-paddintBottom: 10px` | `spacingDatepickerFooterCompactPaddintBottom` | `10` |
| `$spacing-datepicker_footer_compact-paddintRight: 8px` | `spacingDatepickerFooterCompactPaddintRight` | `8` |
| `$spacing-datepicker_scrolllist_shade_pre_compact-marginTop: -17px` | `spacingDatepickerScrolllistShadePreCompactMarginTop` | `-17` |
| `$spacing-datepicker_scrolllist_shade_post_compact-marginTop: 17px` | `spacingDatepickerScrolllistShadePostCompactMarginTop` | `17` |
| `$spacing-datepicker_insetInput_wrapper_compact-margin: 4px` | `spacingDatepickerInsetInputWrapperCompactMargin` | `4` |
| `$spacing-datepicker_insetInput_wrapper_compact-paddingY: 8px` | `spacingDatepickerInsetInputWrapperCompactPaddingY` | `8` |
| `$spacing-datepicker_insetInput_wrapper_compact-paddingX: 8px` | `spacingDatepickerInsetInputWrapperCompactPaddingX` | `8` |
| `$spacing-datepicker_insetInput_wrapper_compact-paddingBottom: 0` | `spacingDatepickerInsetInputWrapperCompactPaddingBottom` | `0` |
| `$spacing-datepicker_insetInput_wrapper_rangeType_compact-paddingTop: 0` | `spacingDatepickerInsetInputWrapperRangeTypeCompactPaddingTop` | `0` |
| `$spacing-datepicker_quick_control_header_compact-paddingTop: 16px` | `spacingDatepickerQuickControlHeaderCompactPaddingTop` | `16` |
| `$spacing-datepicker_quick_control_content_compact-marginTop: 12px` | `spacingDatepickerQuickControlContentCompactMarginTop` | `12` |
| `$spacing-datepicker_quick_control_left_and_right_content_compact-paddingX: 12px` | `spacingDatepickerQuickControlLeftAndRightContentCompactPaddingX` | `12` |
| `$spacing-datepicker_quick_control_top_and_bottom_content_compact-paddingX: 10px` | `spacingDatepickerQuickControlTopAndBottomContentCompactPaddingX` | `10` |
| `$radius-datepicker_range_input: var(--semi-border-radius-small)` | `radiusDatepickerRangeInput` | `theme.radius.borderRadiusSmall.value` |
| `$transition-datepicker_range_input: background-color .16s ease-in-out` | `transitionDatepickerRangeInput` | `background-color .16s ease-in-out`（String 字面量）（String 字段：CSS transition 简写原文；widget 不消费） |
| `$width-datepicker_presetPanel_left_and_right_content: $width-datepicker_presetPanel_left_and_right - $spacing-datepicker_quick_control_content-paddingX * 2` | `widthDatepickerPresetPanelLeftAndRightContent` | `176`（仅派生链消费） |
| `$width-datepicker_presetPanel_top_and_bottom_content_date: $width-datepicker_day * 7 + $spacing-datepicker_month-padding * 2 - $spacing-datepicker_quick_control_top_and_bottom_content-paddingX * 2` | `widthDatepickerPresetPanelTopAndBottomContentDate` | `244`（仅派生链消费） |
| `$width-datepicker_presetPanel_top_and_bottom_content_range: ($width-datepicker_day * 7 + $spacing-datepicker_month-padding * 2) * 2 - $spacing-datepicker_quick_control_top_and_bottom_content-paddingX * 2` | `widthDatepickerPresetPanelTopAndBottomContentRange` | `528`（仅派生链消费） |
| `$width-datepicker_presetPanel_top_and_bottom_content_month: 165px - $spacing-datepicker_quick_control_top_and_bottom_content-paddingX * 2` | `widthDatepickerPresetPanelTopAndBottomContentMonth` | `125`（仅派生链消费） |
| `$height-datepicker_month_max: $width-datepicker_day * 7 + 1px` | `heightDatepickerMonthMax` | `253` |
| `$height-datepicker_month_max_compact: $width-datepicker_day_compact * 7 + $spacing-datepicker_weeks_compact-paddingTop + $spacing-datepicker_weeks_compact-padding + $spacing-datepicker_weekday_compact-paddingBottom` | `heightDatepickerMonthMaxCompact` | `220` |
| `$height-datepicker_date_panel: $height-datepicker_month_max + $spacing-datepicker_month-padding + $width-datepicker_nav + $spacing-datepicker_navigation-paddingY * 2` | `heightDatepickerDatePanel` | `325` |
| `$height-datepicker_date_time_panel: $height-datepicker_date_panel + $height-datepicker_switch - 1px` | `heightDatepickerDateTimePanel` | `378` |
| `$height-datepicker_presetPanel_left_and_right_except_content: 20px + $spacing-datepicker_quick_control_header-paddingTop + $spacing-datepicker_quick_control_content-marginTop` | `heightDatepickerPresetPanelLeftAndRightExceptContent` | `52` |
| `$width-datepicker_presetPanel_top_and_bottom_content_date_compact: $width-datepicker_day_compact * 7 + $spacing-datepicker_weeks_compact-padding * 2 - $spacing-datepicker_quick_control_top_and_bottom_content_compact-paddingX * 2` | `widthDatepickerPresetPanelTopAndBottomContentDateCompact` | `196`（仅派生链消费） |
| `$width-datepicker_presetPanel_top_and_bottom_content_range_compact: ($width-datepicker_day_compact * 7 + $spacing-datepicker_weeks_compact-padding * 2) * 2 - $spacing-datepicker_quick_control_top_and_bottom_content_compact-paddingX * 2` | `widthDatepickerPresetPanelTopAndBottomContentRangeCompact` | `412`（仅派生链消费） |
| `$width-datepicker_presetPanel_top_and_bottom_content_month_compact: 165px - $spacing-datepicker_quick_control_top_and_bottom_content_compact-paddingX  * 2` | `widthDatepickerPresetPanelTopAndBottomContentMonthCompact` | `145`（仅派生链消费） |
| `$height-datepicker_date_panel_compact: $height-datepicker_month_max_compact + $width-datepicker_nav_compact + $spacing-datepicker_nav_compact-padding` | `heightDatepickerDatePanelCompact` | `256` |
| `$height-datepicker_date_time_panel_compact: $height-datepicker_date_panel_compact + $height-datepicker_switch_compact` | `heightDatepickerDateTimePanelCompact` | `288` |
| `$height-datepicker_presetPanel_left_and_right_except_content_compact: 20px + $spacing-datepicker_quick_control_header_compact-paddingTop + $spacing-datepicker_quick_control_content_compact-marginTop` | `heightDatepickerPresetPanelLeftAndRightExceptContentCompact` | `48` |
| `$width-datepicker_presetPanel_left_and_right_two_col_button: ($width-datepicker_presetPanel_left_and_right_content - $spacing-datepicker_quick_control_item-margin) * 0.5` | `widthDatepickerPresetPanelLeftAndRightTwoColButton` | `84` |
| `$width-datepicker_presetPanel_top_and_bottom_three_col_button: ($width-datepicker_presetPanel_top_and_bottom_content_date - $spacing-datepicker_quick_control_item-margin * 2) * 0.333` | `widthDatepickerPresetPanelTopAndBottomThreeColButton` | `75.924` |
| `$width-datepicker_presetPanel_top_and_bottom_five_col_button: ($width-datepicker_presetPanel_top_and_bottom_content_range - $spacing-datepicker_quick_control_item-margin * 4) * 0.2` | `widthDatepickerPresetPanelTopAndBottomFiveColButton` | `99.2` |
| `$width-datepicker_presetPanel_top_and_bottom_two_col_button: ($width-datepicker_presetPanel_top_and_bottom_content_month - $spacing-datepicker_quick_control_item-margin) * 0.5` | `widthDatepickerPresetPanelTopAndBottomTwoColButton` | `58.5` |
| `$width-datepicker_presetPanel_top_and_bottom_three_col_button_compact: ($width-datepicker_presetPanel_top_and_bottom_content_date_compact - $spacing-datepicker_quick_control_item-margin * 2) * 0.333` | `widthDatepickerPresetPanelTopAndBottomThreeColButtonCompact` | `59.940000000000005` |
| `$width-datepicker_presetPanel_top_and_bottom_five_col_button_compact: ($width-datepicker_presetPanel_top_and_bottom_content_range_compact - $spacing-datepicker_quick_control_item-margin * 4) * 0.2` | `widthDatepickerPresetPanelTopAndBottomFiveColButtonCompact` | `76` |
| `$width-datepicker_presetPanel_top_and_bottom_two_col_button_compact: ($width-datepicker_presetPanel_top_and_bottom_content_month_compact - $spacing-datepicker_quick_control_item-margin) * 0.5` | `widthDatepickerPresetPanelTopAndBottomTwoColButtonCompact` | `68.5` |
| `$height-datepicker_inset_input: 32px + $spacing-datepicker_insetInput_wrapper-paddingY` | `heightDatepickerInsetInput` | `44` |
| `$height-datepicker_preset_panel_inset_input: $height-datepicker_month_max + $spacing-datepicker_month-padding + $width-datepicker_nav + $spacing-datepicker_navigation_insetInput-paddingY * 2 + $height-datepicker_inset_input` | `heightDatepickerPresetPanelInsetInput` | `361` |
| `$height-datepicker_inset_input_compact: 28px + $spacing-datepicker_insetInput_wrapper_compact-paddingY` | `heightDatepickerInsetInputCompactDerived` | `36`（★命名冲突：与 `$height-datepicker_insetInput_compact`（190）的 naive camel 同名，派生链字段后缀 `Derived`） |
| `$height-datepicker_preset_panel_inset_input_compact: $height-datepicker_month_max_compact + $width-datepicker_nav_compact + $spacing-datepicker_insetInput_wrapper_compact-paddingY * 2 + $height-datepicker_inset_input_compact` | `heightDatepickerPresetPanelInsetInputCompact` | `296` |
| `$transition_duration-datepicker_date-bg: var(--semi-transition_duration-none)` | `transitionDurationDatepickerDateBg` | `Duration.zero`（上游未消费） |
| `$transition_function-datepicker_date-bg: var(--semi-transition_function-easeIn)` | `transitionFunctionDatepickerDateBg` | `Curves.easeIn`（上游未消费） |
| `$transition_delay-datepicker_date-bg: var(--semi-transition_delay-none)` | `transitionDelayDatepickerDateBg` | `Duration.zero`（上游未消费） |

### B. widget 内部常量（HARDCODES，另列）

| 常量（`_DatePickerMetrics` / 调用点） | 上游出处 / 结构 | 值或处理 |
|---|---|---|
| `allCenter` | mixin.scss:22 `@mixin all-center`（day 格 datePicker.scss:358 / yam 行）— `display: flex; justify-content: center; align-items: center;` | `Center` 居中 |
| `shadowZero` | datePicker.scss:620 `@include shadow-0`（jumperlist）— `box-shadow: none;` | 无绘制，留档 |
| `fontSizeSmall` | datePicker.scss:323 `@include font-size-small`（星期行）— `$font-size-small: 12px` | 12（星期标签） |
| `fontSizeRegular` | datePicker.scss:159 `@include font-size-regular`（scrolllist header）— `$font-size-regular: 14px` | 14（日号文字继承常规字号） |
| `fontSizeHeader6` | datePicker.scss:299 `@include font-size-header-6`（导航月份标题）— `$font-size-header-6: 16px` | 16（月份标题，w600） |
| `triggerFontSize` | datePicker.scss:844 `.semi-datepicker-popover-trigger .semi-input-wrapper` — `font-size: 13px` | 13（所有触发输入；★无 TextStyle.height，自然度量居中） |
| `separatorBorderWidth` | datePicker.scss:188（yam 双列分隔 `border-left: 1px solid var(--semi-color-border)`）/ :1239（insetInput 分隔 `border-left: 1px`，延期） | 1（yam 双列分隔条） |
| `weekHeight` | month.tsx:293 `const height = weeksRowNum * numbers.WEEK_HEIGHT;`（WEEK_HEIGHT: 36，constants.ts:62） | 36（周行高） |
| `scrollbarPaddingThree` | datePicker.scss:688 `// 5px = $width-datepicker_presetPanel_scroll_bar / 3`（三列预设 grid） | 5（Wrap 间距近似，留档） |
| `scrollbarPaddingFive` | datePicker.scss:708 `// 3px = $width-datepicker_presetPanel_scroll_bar / 5`（五列预设 grid） | 3（Wrap 间距近似，留档） |
| `separatorTranslate` | datePicker.scss:1719 `transform: translateX(50%);`（range 分隔符半槽居中，LTR） | 布局居中替代，留档 |
| `separatorTranslateRtl` | rtl.scss:189 `transform: translateX(-50%);`（RTL 镜像） | 同上，留档 |
| `priorityHack` | datePicker.scss:215/940/944 `:not(#neverExistElement)`（纯提权 hack） | 仅注记 |
| `compactMaxWidth` | datePicker.scss:1133 `$compact-max-width: calc(100vw - 32px);`（compact 面板上限；density 延期） | 仅注记 |
| `popoverZIndex` | popover/constants `$z-popover: 1030`（semi-theme-default variables.scss） | 1030（`SemiTooltip.zIndex`，select 先例） |
| （调用点）面板表面 | popover/variables `$color-popover-bg-default`/`-border-default`/`$radius-popover` + `@include shadow-elevated` | bg-3 / 1px border / radius-medium + 双层 elevated 阴影（`_DatePickerMetrics.shadowElevated`，select `_SelectMetrics.popoverSurface*` 先例） |
| （调用点）zh 文案 | zh_CN.ts locale：`weeks`/`monthText`/`presets`/`selectDate` | 星期'日一二三四五六'、标题 '${year}年 ${m}月'、预设头 '快捷选择'、返回 '返回选择日期'（locale 延期） |

## 差异清单

照搬留档（★，刻意与上游一致的行为）：

- **★`value === 0` 是合法时间戳**：`new Date(0)`（isTimestamp）。
- **★解析必须 round-trip**：`parse→format === 输入` 才受理（parser.ts 语义 + handleInputChange 校验）。
- **★超过 4 位年份拒绝**：parser.ts:28 `yearInvalid`。
- **★无效/空输入提交回退**：state value → `DateTime.now()` / `[now, now]`（handleInputComplete）。
- **★range 半选不发 onChanged**（空数组算完整、会发）；受控下半选只回显输入不动 value（#1357）。
- **★end 早于 start → start 置空并回焦 start；start 晚于 end → end 置空**（monthsGridFoundation.ts:685-700）。
- **★面板关闭需两输入各聚焦过一次**（focusRecordsRef + `setTimeout(0)` 延迟打点；本次点选的关闭检查看不到本次打点）。
- **★month/monthRange/year 选中不自动关面板**（foundation.ts:1019 close 块只覆盖 date/dateRange）。
- **★同月互斥**：导航后另一面板同月被推开 1 月（monthsGridFoundation.ts:318-329）。
- **★autoSwitchDate 月末钳制**（01-31 → 02-29）且 disabledDate 拒绝即中止、不关面板；★range 不跟随（上游 `includeRange` 读错参数恒 false 的死代码）。
- **★yam 浮层选后不自动收起**（连点年+月、onPanelChange 逐次发）。
- **★`{start:null,end:null}` 预设清空并关面板**（`onChanged(null, '')`）；disabled-date 预设不清值不通知；函数值点击时才求值。
- **★monthRange 不渲染预设**（上游 "todo" 缺口）。
- **★`showClear` 默认 true**（按钮本体悬浮/聚焦 + 非空才现身；range 清空钮 hover 时顶替后缀）。
- **★纯 disabled 日透明底**（disabled-fill 只刷 disabled+selected/hover 类格子，datePicker.scss:536-570）。
- **★inrange/inhover 严格开区间**（isBetween.ts 端点不含）。
- **★error 行背景误用 `-error-border-default` 字段**（datePicker.scss:1068），`-error-bg-default` 死变量不消费。
- **★10 条死变量 + 3 条死 MOTION 留档不消费**（见主题节）。
- **★`paddint*` 拼写、`$spacing-scrollList_*` 跨组件名、`width-*` 实为圆角/描边宽度**：provenance 原文照抄。
- **★range-side linking 需 focusRecordsRef**：对侧「已选 + 聚焦过」才禁越界日（month.tsx:109-128）。
- **★无方向键网格导航**（上游 click-only）。
- **★清空 payload 归一 `(null, '')`**：上游按类型发 `undefined`/`[]`（disposeCallbackArgs），本移植统一 null/''。
- **★`onChanged` 固定 date 在前**（上游 `onChangeWithDateFirst` 默认即 true，反转开关延期）。
- **★箭头 RTL 翻转**（rtl.scss `scaleX(-1)`）、默认位置 RTL 变 bottomRight。

偏差（不移植/调整）：

- **dateTime/dateTimeRange/needConfirm/Footer 延期**：时间面板、切换条、确认/取消 Footer 随时间类型延期（footer.tsx 主题留档：Cancel `theme="borderless"`、Confirm `theme="solid"`）。
- **yam 滚轮简化**：ScrollList 滚轮/循环滚动/shade/`reselect` 不移植，年/月列改可选列表（几何取 `panel_yam_scrolllist`(266)、`li_min`(64)、`yam_li_compact`(32) 字段近似）；`autoSelectMonth`（选年后自动跳非禁用月）未移植。
- **year 类型语义归一**：上游 handleYMSelectedChange 对 year 走 range 分支且 formatDates 无 year 分支（半坏）；本移植按单值选择（DateTime(year, month)）+ `'yyyy'` 格式。
- **onPanelChange range 载荷收窄**：上游报 `[left, right]` 两元组 + 字符串数组；本移植签名 `onPanelChange(DateTime visibleDate, String text)` 报被导航面板的可见月（syncSwitchMonth 时报左面板）。month/monthRange/year 上游不发，同。
- **visibleDate 月初归一**：面板内部 pickerDate 归一到 1 日（上游保留原日）。
- **onFocus/onBlur/onClear 事件对象裁剪**（VoidCallback）；`onChangeWithDateFirst`/`triggerRender`/`renderDate`/`renderFullDate`/`multiple`/`max`/`defaultPickerValue`/`startDateOffset`/`endDateOffset`（周选）/`insetInput`/`timeZone`/`density`（compact）/`topSlot`/`bottomSlot`/`leftSlot`/`rightSlot`/`dropdownMargin`/`zIndex` 公开参数未移植（多为样式透传/时间类型周边）。
- **selected-start/-end 内缩方向化近似**：34×32 内格 + 2px 起始侧内缩以 Center 布局限定（RTL 未镜像该内缩，圆角方向同）；selected-start-afterhover/end-beforehover 的 1px primary-active 描边未移植。
- **预设 grid 滚动条让位近似**：5px/3px 让位折进 Wrap 间距；预设按钮截字 ellipsis/tooltip 未移植。
- **`clearRangeInputFocus`**（dateTimeRange 专用）与 `isCachedSelectedValueValid`（needConfirm 门）随时间类型延期。
- **Form.DatePicker 延期**：受控/重置走 value 惯例，无表单集成本体。

```dart
SemiDatePicker(
  type: SemiDatePickerType.dateRange,
  value: [DateTime(2026, 1, 1), DateTime(2026, 1, 31)], // 非空即受控
  defaultValue: [DateTime(2026, 1, 1), DateTime(2026, 1, 31)],
  weekStartsOn: 1,
  showClear: true,                       // 默认 true（★上游默认）
  presets: [
    SemiDatePickerPreset(
      text: '本月',
      start: () => DateTime(2026, 11, 1), // ★惰性求值
      end: () => DateTime(2026, 11, 30),
    ),
  ],
  presetPosition: SemiDatePickerPresetPosition.bottom,
  onChanged: (date, dateStr) => print('$date / $dateStr'),
  onOpenChange: (open) => print(open),
);
// 局部主题：SemiDatePickerTheme(data: const SemiDatePickerThemeData(widthDatepickerDay: 40), child: ...)
```
