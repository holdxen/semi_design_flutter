# SemiTimePicker

时间选择器（上游 Semi TimePicker 全件移植）：单面板时/分/秒（+可选 AM/PM）滚动列 + 输入框触发器 + 弹层面板；`type: timeRange` 时双面板（开始/结束）并排、共享一个输入框显示 `[start, end].join(rangeSeparator)`。值模型 `Object?` **宽入**：`DateTime` 原样、`num` 毫秒时间戳（★`0` 合法）、`String` 按 `format` 解析（基准今天）、`null`/`''` 为空；范围为 `List<Object?>`（长 0-2，允许空端 `null`/`''`，显示 `' ~ 01:00:00'` 形态——空端合法不算 invalid，foundation.ts:191-193 `_isEmptyRangeEnd`）。**非空即受控**（`value != null` / `open != null`，项目惯例；★上游是 truthiness 判定 `value = value || defaultValue`，docs 注明），释放控制保留最后显示值（semi_rating.dart:19-22 同款）。变更判定 ★**格式化字符串判等**（foundation.ts:511-531 `_hasChanged`——format 不含秒时 12:00:01 与 12:00:59 判「未变」，不发 `onChanged`）。`onChanged(date, dateStr)` 固定 **date-first**（上游 `onChangeWithDateFirst` 固定 true）：单选 `date = DateTime | null`、`dateStr = String`；范围 `date = List<DateTime?>`、`dateStr = List<String>`（★dateStr 槽位放宽为 `Object?`——见差异清单 1）。面板行为摘要：列显隐由 format 决定（`HH|hh|H|h`/`mm`/`ss` 正则），AM/PM 列仅 `use12Hours`；列文本 = 补零值 + zh 后缀（`00时/00分/00秒`、12h `12时/01时…`）；打开面板 `jumpTo` 选中项居中；输入每次变更过 `isTimeFormatLike` 形状门（半截输入放行不打断）+ blur 回滚；清空 showClear（inputReadOnly 仍可清）。主题对账 **20 = 14 FIELDS + 6 MOTION + 0 INTERNAL**（14 = variables.scss 全部声明、6 = animation.scss 全部声明——**全死**（上游未消费）；`$module`/`$module-list` 类名胶水不计，datePicker `223 = 220 + 3 + 0` 先例）。

## API

`SemiTimePicker({key, type, value, defaultValue, format, use12Hours, hourStep, minuteStep, secondStep, disabledHours, disabledMinutes, disabledSeconds, disabledTime, hideDisabledOptions, rangeSeparator, open, defaultOpen, onOpenChange, onChanged, disabled, size, showClear, clearText, clearIcon, inputReadOnly, borderless, placeholder, insetLabel, validateStatus, panelHeader, panelFooter, position, autoAdjustOverflow, motion, controller, child})`。

type `SemiTimePickerType.time`（| timeRange）。value/defaultValue `Object?`（宽入值模型；受控惯例见总述）。format `String?` 缺省 `use12Hours ? 'a h:mm:ss' : 'HH:mm:ss'`（`DEFAULT_FORMAT_A`/`DEFAULT_FORMAT`，timePicker/constants.ts:26/25；非字符串回退 `'HH:mm:ss'`——Dart 类型下不可达，上游 `getValidFormat` 兜底留档）。use12Hours false。hourStep/minuteStep/secondStep `int?` 缺省 1（`generateOptions` 的 `step`）。disabledHours `List<int> Function()?`、disabledMinutes `List<int> Function(int hour)?`、disabledSeconds `List<int> Function(int hour, int minute)?`（返回禁用值列表，24 小时制）。disabledTime `SemiTimeDisabledSpec Function(List<DateTime?> value, SemiTimePickerPanelSide side)?` 仅范围生效（`SemiTimePickerPanelSide.left|right` = 上游 `PanelType`），返回成员缺省回退顶层函数（foundation.ts:74-95 `getDisabledTimeFns`）。hideDisabledOptions false（true 时禁用项从列移除）。rangeSeparator `' ~ '`（`DEFAULT_RANGE_SEPARATOR`，constants.ts:6）。open `bool?` 非空即受控；defaultOpen `bool?`；onOpenChange `ValueChanged<bool>?`。onChanged `SemiTimePickerChanged?`（= `void Function(Object? date, Object? dateStr)`）。disabled false。size `SemiInputSize.normal`。showClear true（disabled 强制关）；clearText `String?`（有值时清空按钮 tooltip 语义，TimeInput.tsx:189）；clearIcon `Widget?`。inputReadOnly false（只读输入、光标 click、★仍可清）；borderless false（时钟后缀 hover/focus 前 opacity 0）。placeholder `String?` 缺省 `请选择时间`/`请选择时间范围`（zh 硬编码）；insetLabel `Widget?`；validateStatus `SemiInputStatus?`（invalid 时强制 error）。panelHeader/panelFooter `Widget?`（范围缺省头 = 开始时间/结束时间，TimePicker.tsx `createPanelProps` `defaultHeaderMap`）。position `SemiTooltipPosition?` 缺省 bottomLeft（RTL bottomRight，foundation.getPosition:65-72）；autoAdjustOverflow true；motion true。controller `SemiTimePickerController?`（`open/close/focus/blur`，attach/detach 后 no-op——semi_date_picker.dart:84-117 先例）。child `Widget?`（triggerRender 替身——取代默认输入框触发器）。静态 key：`panelKey`/`hourListKey`/`minuteListKey`/`secondListKey`/`ampmListKey`/`inputKey`/`clearButtonKey`。

## 行为

### 值模型与解析

`parseToDate`（utils/index.ts:14-35）：`DateTime` 原样、`num → DateTime.fromMillisecondsSinceEpoch`（★`0` 是合法时间戳）、`String` 按 format 严格解析（基准今天；整串须匹配，越界组件判失败）、`null`/`''` → 空。`getInitialState`（foundation.ts:135-189）：解析失败或值命中禁用 HMS → `invalid` → 输入框 `validateStatus: error`（validateDates:380-402；★空端点合法不判 invalid）。默认值空时面板兜底 = 今天 00:00:00（createDateDefault，ComboxFoundation.ts:147-150）。内部 `isAM` 槽位：foundation.ts:162-165 `const isAM = [true, false]; parsedValues.map(...)`——JS `map` 跳过空洞，空槽保留位置缺省（index 0 → AM，其余 → PM）。

### 面板列

列显隐（ComboxFoundation.ts:72-74）：`showHour = format.match(/HH|hh|H|h/g)`、`showMinute = /mm/`、`showSecond = /ss/`；AM/PM 列仅 `use12Hours`。列序固定 ampm,hour,minute,second（Combobox.tsx render 顺序；无 order 参数），RTL 列序镜像（rtl.scss:1-30 语义）。列 = **normal 模式普通滚动列表**（★非滚轮——上游 V2.22.0 默认即 `mode={'normal'}`）：`SingleChildScrollView` + eager `Column`（_YamColumn 样板）；行高 `heightScrollListItem`(36)、body 高 `heightTimePickerPanelBody`(252)、上下留白 `(252-36)*0.5 = 108`（timePicker.scss:16/:33 公式），列宽 ampm 72 / hour·minute·second 64；滚动条隐藏（Flutter 不画，timePicker.scss:23-45 reset 留档）。列文本 = **补零值 + zh 后缀**（`formatOption` 补零 + `value + locale.hour`）：`00时…23时`/`00分…59分`/`00秒…59秒`，12h 小时列 `[12, 01..11]`，AM/PM 列 `上午/下午`（无补零无后缀）。选中高亮 `colors.colorPrimaryLightDefault` 底、禁用置灰 `colors.colorDisabledText`（scrollList.scss:88-114 语义）。打开面板滚动定位选中项居中（scrollItem.scrollToNode：`targetTop = node.offsetTop - (wrapperHeight - itemHeight) / 2`，上游 `ul` 自带 108px `:before` 留白故净偏移 = `index * 36`，即 `jumpTo(index*36 - 108)` 的 `index*36` 为含留白 offsetTop；★上游 120ms `animatedScrollTo`（`DEFAULT_SCROLL_DURATION: 120`）→ 本移植 `jumpTo`）。

### 输入 round-trip

每次变更先过 `isTimeFormatLike` 形状门（utils/index.ts:126-153：长度/分段校验，半截输入如 `12:0` 直接放行不打断；空串特跳）；合法/空提交按 format 解析落值并发 `onChanged`（★dateStr 为**原文输入**——`_notifyChange(value, input)` 传 input 而非格式串）。★**blur 回滚**（foundation.ts:404-427）：非空 → 回写 `formatValue(value)` 并清 error；空 → 清空值（uncontrolled 落 `[]`）。清空（showClear，disabled 强制关；clearText 有值时 tooltip 语义；★inputReadOnly 时仍可清——上游 `showClearIgnoreDisabled`（TimeInput.tsx:197），SemiInput 未移植故 readonly 分支自绘清空按钮，见差异清单 2）。触发器 = SemiInput（size 三档、placeholder、insetLabel、borderless、validateStatus、inputReadOnly→readonly、suffix `SemiIcons.clock`、hideSuffix 语义）；popover 挂 `SemiTooltip(trigger: custom, visible, showArrow: false, popupBare: true, zIndex: 1030, position, autoAdjustOverflow, motion, repositionKey)`（semi_date_picker.dart:1527-1575 先例；触发 `Listener(onPointerDown, translucent)`，focus 开、外点关报 false，disabled 不开）。★键盘/无面板导航、Esc 关闭无实现（外点关）——照搬不加戏。

### 12 小时制

`use12Hours`：小时列选项 `[12, 1..11]`（Combobox.tsx:194-196 `hourOptionsAdj = [12].concat(hourOptions.filter(h => h < 12 && h > 0))`、`hourAdj = hour % 12 || 12`）；选时 `AM: setHours(v%12)`、`PM: setHours(v%12+12)`（:141-145）；切 AM/PM `<12→+12、>=12→-12`（:151-163）；`disabledHours` 12h 重映射照 ComboxFoundation.disabledHours:98-110（AM 过滤 `<12` 且 `0→12`；PM `12→12` 其余减 12）。输出格式化 ★大写 `A` 当小写 `a`（Combobox.tsx:171 `format.replace(/(\s+)A/g, '$1a')` 语义），`a`/`A` 均输出 zh `上午/下午`。

### 步进与禁用

`generateOptions(24|60|60, disabled, hideDisabled, step)`（ComboxFoundation.ts:26-34）：`for (value = 0; value < length; value += step)`；`formatOption` 补零（:9-24）。禁用：`disabledHours()/disabledMinutes(h)/disabledSeconds(h,m)` 返回禁用值列表；`hideDisabledOptions` true 从列**移除**（★selectedIndex 变 -1 → 回退第一个非禁用项，scrollItem.tsx:314-322 `getNodeByIndex` quirk——步进不含当前值时同），否则保留置灰不可点。★12h 置灰与隐藏统一用重映射后的列表（上游 `renderHourSelect` 用 raw `disabledHours()` 打标、与 12h 列值错位——本移植按 ComboxFoundation 重映射统一，见差异清单 3）。invalid = 解析失败或值命中禁用 HMS → 输入框 error。

### usePopover 与插槽

面板恒挂 SemiTooltip 弹层（popupBare 无表面）：单面板自绘 Popover 表面 `DecoratedBox(colorBg3 + 1px colorBorder + radiusMedium + shadowElevated 双影)` + ClipRRect（semi_date_picker.dart:1948-1963 / semi_color_picker.dart build 先例；双影 = `0 0 1px rgba(0, 0, 0, .3)` + `0 4px 14px rgba(0, 0, 0, .1)`，popover.scss/global.scss shadow-elevated）。panelHeader/panelFooter 包裹列上下（范围每面板一份；header/body padding 消费 `spacingTimePickerRangePanelScrolllistHeaderBodyPadding`（0））。

### range

`type == timeRange`：两面板并排（左=开始右=结束，左右独立选时，`handlePanelChange(result, index)` 槽位语义——空面板选中补 `[null, date]`/`[date]` 形态）；输入显示 `[start, end].join(rangeSeparator)`（★空端点合法：`['', '01:00:00']` 显示 `' ~ 01:00:00'`、不算 invalid）。`onChanged` 回传 `List<DateTime?>` + `List<String>`；`disabledTime(value, side)` 按面板覆盖、缺省回退顶层函数。范围皮肤（timePicker.scss:84-115）：外 `DecoratedBox` 描边 `widthTimePickerRangePanelBorder`(1) + `colorTimePickerRangePanelBorder`、圆角 `radiusTimePickerRangePanel`、影 `shadowTimePickerRangePanel`（String 字段的 BoxShadow twin，`_TimePickerMetrics.shadowRangePanel` 注释互指）；中缝 `widthTimePickerRangePanelScrolllistBodyBorder`(2) 右边框 `colorTimePickerRangePickerPanelSplitBorder`（RTL 翻左边，rtl.scss:17-27）。

## 主题（20 对账）

来源 packages/semi-foundation/timePicker/variables.scss（14 声明行 / 14 唯一名——color 2、width 6、height 2、spacing 1、radius 2、shadow 1）+ packages/semi-foundation/timePicker/utils/animation.scss（6 声明行——**6 条全死**：该文件从未被任何 `@import` 引用、gulpfile 排除编译；5 条是 tagInput 复制残留名、注释全是「标签输入框」）。对账 **20 = 14 FIELDS + 6 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表；`$module`/`$module-list` 类名胶水不计）。全局 token 解析：`var(--semi-color-border)` → `theme.colors.colorBorder`、`rgba(0, 0, 0, .1)` → `const Color(0x1a000000)`（COLOR_LITERALS 先例）、`var(--semi-border-radius-medium)` → `theme.radius.borderRadiusMedium.value`（6）、`var(--semi-border-radius-small)` → `theme.radius.borderRadiusSmall.value`（3）、`var(--semi-transition_duration-none)`/`var(--semi-transition_delay-none)` → `Duration.zero`、`var(--semi-transition_function-easeIn)` → `Curves.easeIn`（generate_tag_input.py MOTION 先例）。解析列即 `SemiTimePickerThemeData.resolve` 默认表达式。

### A. Sass 声明映射（14 FIELDS + 6 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-timePicker_range_picker_panel_split-border: var(--semi-color-border)` | `colorTimePickerRangePickerPanelSplitBorder` | `theme.colors.colorBorder`（范围中缝分割线） |
| `$color-timePicker_range_panel-border: rgba(0, 0, 0, .1)` | `colorTimePickerRangePanelBorder` | `const Color(0x1a000000)`（范围外描边色） |
| `$width-timePicker_range_panel-border: 1px` | `widthTimePickerRangePanelBorder` | `1`（范围外描边宽） |
| `$height-timePicker_panel_body: 252px` | `heightTimePickerPanelBody` | `252`（列 body 高） |
| `$height-scrollList_item: 36px` | `heightScrollListItem` | `36`（★跨组件名照抄——scrollList 模块同名，quirk 留档；行高） |
| `$width-timePicker_panel_list_ampm: 72px` | `widthTimePickerPanelListAmpm` | `72` |
| `$width-timePicker_panel_list_hour: 64px` | `widthTimePickerPanelListHour` | `64` |
| `$width-timePicker_panel_list_minute: 64px` | `widthTimePickerPanelListMinute` | `64` |
| `$width-timePicker_panel_list_second: 64px` | `widthTimePickerPanelListSecond` | `64` |
| `$width-timePicker_range_panel_scrolllist_body-border: 2px` | `widthTimePickerRangePanelScrolllistBodyBorder` | `2`（范围中缝宽） |
| `$spacing-timePicker_range_panel_scrolllist_header_body-padding: 0` | `spacingTimePickerRangePanelScrolllistHeaderBodyPadding` | `0`（header/body padding——消费即应用） |
| `$radius-timePicker_range_panel: var(--semi-border-radius-medium)` | `radiusTimePickerRangePanel` | `theme.radius.borderRadiusMedium.value`（6） |
| `$radius-timePicker_input: var(--semi-border-radius-small)` | `radiusTimePickerInput` | `theme.radius.borderRadiusSmall.value`（3）——本移植由 SemiInput input 主题承担（字段未消费，非「上游未消费」） |
| `$shadow-timePicker_range_panel: 0 4px 14px rgba(0, 0, 0, .1)` | `shadowTimePickerRangePanel` | `'0 4px 14px rgba(0, 0, 0, .1)'`（String 字段——datePicker transition String 先例；widget 侧 `_TimePickerMetrics.shadowRangePanel` 同值 BoxShadow twin，注释互指） |
| `$transition_duration-timePicker-bg: var(--semi-transition_duration-none)` | `transitionDurationTimePickerBg` | `Duration.zero`（上游未消费）——死变量留档：utils/animation.scss 从未被 `@import`、gulpfile 排除编译 |
| `$transition_function-tagInput-bg: var(--semi-transition_function-easeIn)` | `transitionFunctionTagInputBg` | `Curves.easeIn`（上游未消费）——★tagInput 复制残留名（注释「标签输入框」） |
| `$transition_delay-tagInput-bg: var(--semi-transition_delay-none)` | `transitionDelayTagInputBg` | `Duration.zero`（上游未消费）——★tagInput 复制残留名（注释「标签输入框」） |
| `$transition_duration-tagInput-border: var(--semi-transition_duration-none)` | `transitionDurationTagInputBorder` | `Duration.zero`（上游未消费）——★tagInput 复制残留名（注释「标签输入框」） |
| `$transition_function-tagInput-border: var(--semi-transition_function-easeIn)` | `transitionFunctionTagInputBorder` | `Curves.easeIn`（上游未消费）——★tagInput 复制残留名（注释「标签输入框」） |
| `$transition_delay-tagInput-border: var(--semi-transition_delay-none)` | `transitionDelayTagInputBorder` | `Duration.zero`（上游未消费）——★tagInput 复制残留名（注释「标签输入框」） |

### B. HARDCODES 另列（`_TimePickerMetrics` / 调用点，widget 源内含原始片段）

| 上游片段 | 落点 |
|---|---|
| `-ms-overflow-style: none; /* Internet Explorer 10+ */` / `scrollbar-width: none; /* Firefox */` / `&::-webkit-scrollbar {` | 列滚动条隐藏 reset（timePicker.scss:23-45；Flutter 不画滚动条） |
| `($height-timePicker_panel_body - $height-scrollList_item) * 0.5` | 列上下留白公式（timePicker.scss:16/:33，108） |
| `.semi-input-readonly { cursor: pointer }` | inputReadOnly 光标 click（timePicker.scss:126-128） |
| `.#{$prefix}-input-borderless:not(:focus-within):not(:hover){` + `opacity: 0;` | borderless 时钟后缀 hover/focus 前隐藏（timePicker.scss:131-138，MouseRegion/Focus 实现） |
| `DEFAULT_SCROLL_DURATION: 120` | 打开定位上游 120ms animatedScrollTo（scrollList/constants.ts:14）→ 本移植 jumpTo |
| `DEFAULT_FORMAT: 'HH:mm:ss'` / `DEFAULT_FORMAT_A: 'a h:mm:ss'` / `DEFAULT_RANGE_SEPARATOR: ' ~ '` | 格式/分隔符缺省（timePicker/constants.ts:25/26/6） |
| `value = \`0${option}\`;` | `formatOption` 补零（ComboxFoundation.ts:9-24） |
| `format.match(/HH\|hh\|H\|h/g)` / `format.match(/mm/g)` / `format.match(/ss/g)` | 列显隐正则（ComboxFoundation.ts:72-74） |
| `hour % 12 \|\| 12` | 12h 小时列选中值（Combobox.tsx:194-196） |
| `transformValue.getHours() < 12 && transformValue.setHours((transformValue.getHours() % 12) + 12);` / `transformValue.getHours() >= 12 && transformValue.setHours(transformValue.getHours() - 12);` | AM/PM 切换 ±12（Combobox.tsx:151-163） |
| `value + locale.hour` | 列文本补零值 + zh 后缀（Combobox.tsx:202） |
| `mode={'normal'}` | 列 = 普通滚动列表（Combobox.tsx，非滚轮） |
| `time: '请选择时间',` `timeRange: '请选择时间范围',` `begin: '开始时间',` `end: '结束时间',` `hour: '时',` `minute: '分',` `second: '秒',` `AM: '上午',` `PM: '下午',` | zh 文案硬编码（locale/source/zh_CN.ts:26-38） |
| Popover 表面皮肤（bg-3 + 1px border + radius-medium + shadow-elevated 双影） | 单面板弹层白底（popupBare 无表面自绘，semi_color_picker.dart 同方）；范围面板用 `$shadow-timePicker_range_panel` String 字段 twin |

## 差异清单

★照搬留档（quirk 原样）：
1. **`onChanged` dateStr 槽位**：上游回传 `string | string[]`（范围是按 rangeSeparator 切分的列表），brief 的 `String?` 签名装不下 `List<String>`——typedef 槽位放宽为 `Object?`（单选传 `String`、范围传 `List<String>`）。
2. **inputReadOnly 仍可清**：上游 `showClearIgnoreDisabled`（TimeInput.tsx:197「inputReadOnly only blocks typing, the picker's clear button stays available」）；SemiInput 未移植该开关（`_handleClear` 对 readonly 早退、清空钮隐藏）——本移植 readonly 分支在后缀位自绘清空按钮（带 clearButtonKey/clearText tooltip），保持行为；非 readonly 路径走 SemiInput 原生清空。
3. **12h 禁用打标口径**：上游 `renderHourSelect` 用 raw `disabledHours()` 对 12h 列值打标（与 24h 禁用值错位）；本移植按 ComboxFoundation.disabledHours:98-110 重映射后统一用于过滤与置灰。
4. **hide 回退 quirk**：`hideDisabledOptions` 移除选中值（或步进不含当前值）→ selectedIndex -1 → 高亮/定位回退第一个非禁用项（scrollItem.tsx:314-322 `getNodeByIndex` 原样）。
5. **格式串判等**：`_hasChanged` 用格式化字符串判等（foundation.ts:511-531）——format 不含秒时 12:00:01 与 12:00:59 判「未变」不发事件（受控不落值同理）。
6. **空端点**：范围空端 `null`/`''` 合法、显示 `' ~ 01:00:00'` 形态、不算 invalid（foundation.ts:191-193）；★输入路径的空段会被 `isTimeFormatLike` 门挡住（`''` 段不「像」format），空端只来自 value/清空——上游同门。
7. **补零 + 后缀列文本**：列文本 = `formatOption` 补零值 + `value + locale.hour`（`00时`/`12时`），非裸数字。
8. **isTimeFormatLike 门**：半截输入（`12:0`）放行不打断、空串特跳（utils/index.ts:126-153 原样含 `[H|m|s]` 字符类怪癖）。
9. **变更/清空回传 quirk**：范围清空回传 `([], [''])`（`''.split(' ~ ')` 上游同）；单选清空回传 `(null, '')`；输入变更的 dateStr 是**原文输入**而非格式串（`_notifyChange(value, input)`）。

偏差/裁剪：
10. **wheel 无限滚动延期**（`scrollItemProps`）：上游 `ScrollItem mode` 支持滚轮形态，本移植仅 `mode={'normal'}` 普通滚动列表。
11. **timeZone 延期**：`timeZone`/`utcToZonedTime`/`zonedTimeToUtc` 全链路不移植（本地时区语义）。
12. **triggerRender → child**：上游 `triggerRender(props)` 改为 `child`（项目惯例，colorPicker 先例）。
13. **onChangeWithDateFirst 固定 date-first**：flip 不移植。
14. **locale zh 硬编码**：`zh_CN.ts:26-38` 文案与 `a/A` → `上午/下午` 直接内置（`dateFnsLocale` 不移植；date-fns 子集与 semi_date_picker.dart 的 `_dp*` 同源重复——各自私有、不互同）。
15. **panels 数组配置收敛**：per-panel `panels[index].panelHeader/panelFooter` 收敛为共享 `panelHeader/panelFooter`（范围缺省头开始/结束时间保留）。
16. **裁剪 props**：`getPopupContainer`/`dropdownMargin`/`stopPropagation`/`popupStyle`/`popupClassName`/`insetLabelId`/`style`/`className`/`prefixCls` 等粒度裁剪（position/autoAdjustOverflow/motion 直接参数化）。
17. **死 API 不移植**：`onEsc`/`defaultOpenValue`/`onKeyDown`/`reselect`/`onEnterSelectPanel`/`autoFocus`/`preventScroll`/`focusOnOpen`/`scrollItemProps`/`onCurrentSelectPanelChange`/`dateFnsLocale`（上游死/仅内部）。
18. **Form 不移植**（上游 semi Form 联动）。
19. **死常量/死类名留档**：`DEFAULT_MULTIPLE_SEPARATOR: ','`（constants.ts:7，从未消费）+ 5 个死类名 `-panel-narrow`/`-panel-column-N`/`-input-invalid`/`-input-wrap`/`-header`（getPopupClassName/TimeInput render 的类名，CSS 无对应规则）。
20. **120ms animatedScrollTo → jumpTo**：打开定位从上游 120ms 动画改瞬时 `jumpTo`（`DEFAULT_SCROLL_DURATION: 120` 锚点留档）。
21. **SSR 无对应**（上游 `semi-ui` SSR 兼容层无 Flutter 对应物）。
22. **`$radius-timePicker_input` 未消费注记**：触发器圆角由 SemiInput input 主题承担（本移植由 SemiInput input 主题承担（字段未消费）——非死变量，上游 timePicker.scss:122 消费于 `.semi-timepicker-input`）。
23. **受控惯例**：`value != null` 即受控（项目惯例）；★上游 truthiness（`value = value || defaultValue`，`''`/`0` 值会被 defaultValue 覆盖）——本移植 `??` 语义，`0` 时间戳/空串 value 保持受控。
24. **invalid 落点**：上游 `handleInputChange`/`handlePanelChange` 仅非受控落 invalid（`refreshProps` 在受控值变化时重算）；本移植同口径（受控打字不置 error，blur 清 error）。

## 用法

```dart
SemiTimePicker(
  format: 'HH:mm:ss',
  defaultValue: DateTime(2024, 1, 1, 9, 30, 0),
  onChanged: (date, dateStr) {
    // date: DateTime | null; dateStr: String
  },
)

SemiTimePicker(
  type: SemiTimePickerType.timeRange,
  use12Hours: true,
  value: ['', '01:00:00'],
  rangeSeparator: ' ~ ',
  disabledTime: (value, side) => const SemiTimeDisabledSpec(
    disabledHours: null, // 缺省回退顶层 disabledHours
  ),
  onChanged: (date, dateStr) {
    // date: List<DateTime?>; dateStr: List<String>
  },
)
```
