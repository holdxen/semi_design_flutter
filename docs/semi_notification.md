# SemiNotification

通知（上游 Semi Notification 全件移植）：命令式 `SemiNotification.success/info/error/warning/open` 弹出右上角（六向 placement）浮层通知卡——类型图标（`IconAlertTriangle`/`IconTickCircle`/`IconInfoCircle`/`IconAlertCircle` `size="large"`；`open` 即 'default' 无图标）+ 标题（`@include font-size-header-6` 16/22 bold）+ 内容（`@include font-size-regular` 14/20）+ 关闭钮（`theme="borderless" size="small" type="tertiary"` `IconClose`）。`duration` 缺省 3s 自动关闭（`Duration.zero` 固定）、悬停暂停计时（`onMouseEnter`/`onMouseLeave`）、同 id 再入即就地更新（`appliedUpdates` 一次 `restartCloseTimer`）、关闭/移除按 placement 反向滑出退场（300ms `cubic-bezier(0.62, 0.63, 0, 1.13)`）、`variant: light` 语义色浅底 + 1px 描边（`background-image` 渐变覆盖层叠 `background-color` ambient 底）。弹层底座为 vendored flutter_smart_dialog 引擎（`lib/src/overlay/dialog_engine`，SemiModal 先例）。主题对账 **43 = 35 FIELDS + 8 MOTION + 0 INTERNAL**（variables.scss 35 声明：color 17、width 4、spacing 11、radius 1、font 2；animation.scss 8 声明；`$module` 胶水与 rtl.scss 不计，modal `81 = 63 + 18 + 0`、banner `22 = 22 + 0 + 0` 先例）；其中 **1 条死 FIELDS**（死变量留档不消费）。★quirk 照抄：`$animation_function-notification-hide` 行尾注释 `//消失时-过渡曲线`（缺空格）。

## API

命令式族（上游 `NotificationList` 静态层，均返回 `String` id）：

`SemiNotification.{open,info,success,error,warning}({context, id, title, content, duration, position, variant, icon, showClose, motion, onClick, onClose, onCloseClick, top, left, bottom, right, closeSemanticsLabel})`——type 由方法名强制（open → `SemiNotificationType.normal` = 上游 'default'）。`SemiNotification.close(id)`（静默移除，不触发回调）、`SemiNotification.destroyAll()`（瞬时卸载）、`SemiNotification.config({top, bottom, left, right, duration, position, zIndex})`（全局缺省，仅对后续 add 生效）。

卡片 `SemiNotificationNotice({id, title, content, type, variant, icon, showClose, duration, isClosing, updateSeq, onClose, onCloseClick, onClick, onRemove, closeSemanticsLabel})` 亦可独立嵌入；[onRemove] 为宿主注入的移除请求（上游私有 `close` prop）。

type `SemiNotificationType`（normal/info/success/warning/error；`default` 是 Dart 保留字→`normal`，avatar 先例）。variant `SemiNotificationVariant`（normal/light，上游 `NoticeTheme`——badge `variant` 更名先例）。position `SemiNotificationPosition`（top/bottom/topLeft/topRight/bottomLeft/bottomRight，缺省 `position: 'topRight'`）。title/content `Object?`：String/num 走 16/22 / 14/20 排版，Widget 原样；`{title ? (…) : ''}` 纯 truthy——数字 0/空串不渲染（无 banner `|| title === 0` 例外）。icon `Widget?`（SemiIcon 未指定尺寸按 `size: iconType.props.size || 'large'` 补 20x20）。duration `Duration`（上游单位秒 `duration: 3`→`Duration(seconds: 3)`；zero 不排计时）。closeSemanticsLabel 缺省 '关闭'（上游图标钮无 aria-label——补语义）。

## 行为

### 计时与关闭

- 挂载即 `restartCloseTimer` 族：`duration` 有效则排自动关闭计时（秒→ms）；`Duration.zero` 固定（上游 falsy `duration`）。
- 悬停（`onMouseEnter`）清计时；离开（`onMouseLeave`）`!isClosing` 守卫恢复（closeLifecycle：leaving 时离开不再触发 onClose）。挂载即 isClosing 不排计时；isClosing 撤销后 `restartCloseTimer`。
- 关闭钮：`onCloseClick(id)` 先行 → `notifyWrapperToRemove`（宿主移除）+ `notifyClose`（`onClose`）；`e.stopPropagation()` 不适用（Flutter 无冒泡，按钮手势不透传父级）。计时器关闭不触发 onCloseClick。
- `SemiNotification.close(id)` 列表级静默移除（含 leave 动画）——不触发 onClose/onCloseClick（上游 removeNotice 语义）。
- `destroyAll()` 瞬时卸载宿主（上游 microtask 卸 wrapper——leave 动画不播、无回调）。

### 更新与复用

- 同 id 再 add：存活通知就地更新（`ref.has(id) ? ref.update(id, notice) : ref.add(...)`）；updateSeq 递增驱动恰好一次 `restartCloseTimer`（上游 `appliedUpdates` WeakSet 语义——entrance 结束的重渲染不重启）。
- 更新合并取 copyWith 语义：显式传入覆盖、缺省保留（含 title/content/duration/motion/showClose——上游 JS 展开让 defaultConfig 键缺省回退默认值，怪癖不照抄，见差异清单）；清 title/content 传 `''`（falsy）。
- 同 id 复用 leaving 通知：旧实例即刻丢弃、新实例入列（上游 adapter removedItems 按 id 过滤）。

### 视觉

- 结构：root（`@include shadow-elevated` + 圆角 + 四边 margin 20）> icon 槽（宽 24、右距 12、顶对齐 `size="large"`）+ inner（content-wrapper `flex: 1` 右距 8 > title（16/22 bold、底距 4）+ content（14/20）+ closer（`height: $width-icon-extra-large` 24））。
- 列表：按 placement 六向锚定（top/bottom 居中 = `left: 50%` + `translateX(-50%)`，显式 left 偏移覆写锚点）；最新在前（add 前插）；同列卡片等宽（shrink-to-fit 列宽取最宽 max-content、下限 `min-width: 320px`）；`pointer-events: none` 列表点穿 + 卡片 `pointer-events: auto`（空白区不吸中等价）。
- margin 折叠：`margin: 20` 四边在 CSS 相邻卡片纵向折叠（间距 = 20 非 40）——Flutter 以纵向半值对拆 + 列首尾补半值等价。
- light 主题：`background-image: linear-gradient(0deg, …_light-bg, …_light-bg)` 等价单色覆盖层与 `background-color: $color-notification_ambient-bg` 底色 alpha 合成（覆盖层不透明时即 _light-bg、半透时露底）+ 1px 语义色描边；合成进同一圆角 BoxDecoration 一体成型（内层直角色块会溢出外层圆角——修四角破图）；'default' 与 info 共用 info 通道。normal 主题：`$color-notification-bg-default` 无描边。
- 入/退场：按 placement 反向滑出（`translateY(±100%)`/`translateX(±100%)`）+ 透明度 0↔1（`$animation_opacity-notification-show/-hide`），300ms show/hide 同曲线 `cubic-bezier(0.62, 0.63, 0, 1.13)`（`animation_delay-*: 0ms` 叠入时长）；`motion: false` 无动画（入即位、退即释放）；退场完成释放（上游 `scheduleRemovedNoticeRelease` 350ms 兜底等价——Flutter 动画状态回调可靠）。
- 语义：`role="alert"` → `Semantics(liveRegion: true)`；`aria-labelledby` 标题引用（titleID 前缀 `semi-notification-notice-title` 实例内稳定）≈ 标题文本为语义锚；关闭钮语义标签 '关闭'。

### RTL

- rtl.scss padding 镜像（`padding-right: …-paddingLeft`）由 EdgeInsetsDirectional 自动翻转；icon/content-wrapper 两条 rtl 规则与基础同值（重设同值 margin-right，no-op quirk 照抄）——Flutter 以 EdgeInsetsDirectional 镜像（修上游 RTL 疑似漏写镜像的缺陷，登记偏差）。

## 主题（43 对账）

来源 packages/semi-foundation/notification/variables.scss（35 声明行 / 35 唯一名）+ animation.scss（8 声明行）。对账 **43 = 35 FIELDS + 8 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表；`$module: #{$prefix}-notification` 类名胶水与 rtl.scss 不计）。**1 条死 FIELDS**（死变量留档不消费：落 theme + `# dead variable (上游未消费)` + 本表「（上游未消费）」+ widget assertNotIn）：`$spacing-notification_notice-marginRight`（notification.scss 用速写 `margin: $spacing-notification_notice-margin`，右侧覆写无消费处）。全局 token 解析：`var(--semi-color-bg-3)` → `theme.colors.colorBg3`、`var(--semi-color-bg-0)` → `theme.colors.colorBg0`、`var(--semi-color-text-0/-1/-2)` → `theme.colors.colorText0/1/2`、`var(--semi-color-{info,warning,success,danger})` → `theme.colors.color*`、`var(--semi-color-{info,warning,success,danger}-light-default)` → `theme.colors.color*LightDefault`、`var(--semi-border-radius-medium)` → `theme.radius.borderRadiusMedium.value`（= 6，generate_card 先例）；引用 token：`$width-icon-extra-large` → 24、`$spacing-base` → 16、`$spacing-base-tight` → 12、`$spacing-base-loose` → 20、`$spacing-extra-tight` → 4（generate_modal 先例）、`$font-weight-bold` → `theme.typography.fontWeightBold`（FontWeight.w600）、`$font-weight-regular` → `theme.typography.fontWeightRegular`（FontWeight.w400，生成域 fontWeight resolve 先例 tool/generate_tag.py:31）。Motion tokens：`300ms` → `const Duration(milliseconds: 300)`、`0ms` → `Duration.zero`、`cubic-bezier(0.62, 0.63, 0, 1.13)` → `const Cubic(0.62, 0.63, 0, 1.13)`、opacity `0` → `0`。类型覆盖：**35 FIELDS = 17 Color + 1 String + 15 double + 2 FontWeight；8 MOTION = 4 Duration + 2 Curve + 2 double**。解析列即 `SemiNotificationThemeData.resolve` 默认表达式。

### A. Sass 声明映射（35 FIELDS + 8 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-notification-bg-default: var(--semi-color-bg-3)` | `colorNotificationBgDefault` | `theme.colors.colorBg3` |
| `$color-notification_info-icon: var(--semi-color-info)` | `colorNotificationInfoIcon` | `theme.colors.colorInfo` |
| `$color-notification_warning-icon: var(--semi-color-warning)` | `colorNotificationWarningIcon` | `theme.colors.colorWarning` |
| `$color-notification_danger-icon: var(--semi-color-danger)` | `colorNotificationDangerIcon` | `theme.colors.colorDanger` |
| `$color-notification_success-icon: var(--semi-color-success)` | `colorNotificationSuccessIcon` | `theme.colors.colorSuccess` |
| `$color-notification_title-text: var(--semi-color-text-0)` | `colorNotificationTitleText` | `theme.colors.colorText0` |
| `$color-notification_content-text: var(--semi-color-text-1)` | `colorNotificationContentText` | `theme.colors.colorText1` |
| `$color-notification_closeBtn-icon: var(--semi-color-text-2)` | `colorNotificationCloseBtnIcon` | `theme.colors.colorText2` |
| `$color-notification_warning_light-bg: var(--semi-color-warning-light-default)` | `colorNotificationWarningLightBg` | `theme.colors.colorWarningLightDefault` |
| `$color-notification_warning_light-border: var(--semi-color-warning)` | `colorNotificationWarningLightBorder` | `theme.colors.colorWarning` |
| `$color-notification_success_light-bg: var(--semi-color-success-light-default)` | `colorNotificationSuccessLightBg` | `theme.colors.colorSuccessLightDefault` |
| `$color-notification_success_light-border: var(--semi-color-success)` | `colorNotificationSuccessLightBorder` | `theme.colors.colorSuccess` |
| `$color-notification_info_light-bg: var(--semi-color-info-light-default)` | `colorNotificationInfoLightBg` | `theme.colors.colorInfoLightDefault` |
| `$color-notification_info_light-border: var(--semi-color-info)` | `colorNotificationInfoLightBorder` | `theme.colors.colorInfo` |
| `$color-notification_danger_light-bg: var(--semi-color-danger-light-default)` | `colorNotificationDangerLightBg` | `theme.colors.colorDangerLightDefault` |
| `$color-notification_danger_light-border: var(--semi-color-danger)` | `colorNotificationDangerLightBorder` | `theme.colors.colorDanger` |
| `$color-notification_ambient-bg: var(--semi-color-bg-0)` | `colorNotificationAmbientBg` | `theme.colors.colorBg0`（light 底色，覆盖层下） |
| `$width-notification_notice: auto` | `widthNotificationNotice` | `'auto'`（★非数值留档——shrink-to-fit 列宽语义） |
| `$width-notification_notice_minWidth: 320px` | `widthNotificationNoticeMinWidth` | `320` |
| `$width-notification_notice-icon: $width-icon-extra-large` | `widthNotificationNoticeIcon` | `24` |
| `$width-notification_notice-border: 1px` | `widthNotificationNoticeBorder` | `1`（仅 light 描边消费） |
| `$spacing-notification_list-margin: 0` | `spacingNotificationListMargin` | `0` |
| `$spacing-notification_list-padding: 0` | `spacingNotificationListPadding` | `0` |
| `$spacing-notification_notice-paddingTop: $spacing-base` | `spacingNotificationNoticePaddingTop` | `16` |
| `$spacing-notification_notice-paddingRight: $spacing-base-tight` | `spacingNotificationNoticePaddingRight` | `12`（rtl.scss 镜像消费） |
| `$spacing-notification_notice-paddingBottom: $spacing-base` | `spacingNotificationNoticePaddingBottom` | `16` |
| `$spacing-notification_notice-paddingLeft: $spacing-base-loose` | `spacingNotificationNoticePaddingLeft` | `20`（rtl.scss 镜像消费） |
| `$spacing-notification_notice-margin: $spacing-base-loose` | `spacingNotificationNoticeMargin` | `20`（四边；CSS 纵向折叠等价） |
| `$spacing-notification_notice-marginRight: $spacing-base-tight` | `spacingNotificationNoticeMarginRight` | `12`（（上游未消费）速写 `margin:` 覆盖四边、右侧覆写无消费处；widget 不消费本字段） |
| `$spacing-notification_notice_title-marginBottom: $spacing-extra-tight` | `spacingNotificationNoticeTitleMarginBottom` | `4` |
| `$spacing-notification_notice_content_wrapper-marginRight: 8px` | `spacingNotificationNoticeContentWrapperMarginRight` | `8` |
| `$spacing-notification_notice_icon-marginRight: $spacing-base-tight` | `spacingNotificationNoticeIconMarginRight` | `12` |
| `$radius-notification_notice: var(--semi-border-radius-medium)` | `radiusNotificationNotice` | `theme.radius.borderRadiusMedium.value` |
| `$font-notification_notice_title-fontWeight: $font-weight-bold` | `fontNotificationNoticeTitleFontWeight` | `theme.typography.fontWeightBold`（FontWeight.w600） |
| `$font-notification_notice_content-fontWeight: $font-weight-regular` | `fontNotificationNoticeContentFontWeight` | `theme.typography.fontWeightRegular`（FontWeight.w400） |
| `$animation_duration-notification-show: 300ms` | `animationDurationNotificationShow` | `const Duration(milliseconds: 300)` |
| `$animation_function-notification-show: cubic-bezier(0.62, 0.63, 0, 1.13)` | `animationFunctionNotificationShow` | `const Cubic(0.62, 0.63, 0, 1.13)` |
| `$animation_delay-notification-show: 0ms` | `animationDelayNotificationShow` | `Duration.zero` |
| `$animation_duration-notification-hide: 300ms` | `animationDurationNotificationHide` | `const Duration(milliseconds: 300)` |
| `$animation_function-notification-hide: cubic-bezier(0.62, 0.63, 0, 1.13)` | `animationFunctionNotificationHide` | `const Cubic(0.62, 0.63, 0, 1.13)`（★注释照抄 `//消失时-过渡曲线`——`//` 后缺空格） |
| `$animation_delay-notification-hide: 0ms` | `animationDelayNotificationHide` | `Duration.zero` |
| `$animation_opacity-notification-show: 0` | `animationOpacityNotificationShow` | `0` |
| `$animation_opacity-notification-hide: 0` | `animationOpacityNotificationHide` | `0` |

★quirk 照抄：`$animation_function-notification-hide` 的行尾注释写成 `//消失时-过渡曲线`（`//` 后缺空格——其余七行均为 `// `，字面照抄）。

### B. HARDCODES 另列（widget 文件头注释 / 调用点，源内含原始片段）

| 上游片段 | 说明 |
|---|---|
| constants.ts `types: ['warning', 'success', 'info', 'error', 'default']` | 对外类型枚举 |
| constants.ts `themes: ['normal', 'light']` | 填充枚举 |
| constants.ts `directions: ['ltr', 'rtl']` | 方向枚举 |
| defaultConfig `duration: 3` | 缺省 3 秒自动关闭 |
| defaultConfig `position: 'topRight'` | 缺省位置 |
| defaultConfig `zIndex: 1010` | wrapper 层级（引擎插入序表达） |
| defaultConfig `title: ''` / `content: ''` | 缺省空内容 |
| defaultProps `showClose: true` / `theme: 'normal'` | 缺省关闭钮/填充 |
| `IconAlertTriangle` / `IconTickCircle` / `IconInfoCircle` / `IconAlertCircle` | 类型图标（warning/success/info/error） |
| `size="large"` | 类型图标 20x20 |
| `types.includes(type)` | icon-show 类名门槛（含 'default' 无图标） |
| `size: iconType.props.size || 'large'` | 自定义 SemiIcon clone 尺寸规则 |
| `theme="borderless"` `size="small"` `type="tertiary"` | 关闭钮形态 |
| `IconClose` | 默认关闭图标 |
| `height: $width-icon-extra-large` | 关闭钮槽高 24 |
| `title ? (` / `content ? (` | falsy 渲染（数字 0/空串不渲染） |
| `role="alert"` | live region 语义 |
| `aria-labelledby` + `semi-notification-notice-title` | 标题引用（titleID 实例内稳定） |
| `onMouseEnter` / `onMouseLeave` | 悬停暂停/恢复计时 |
| `e.stopPropagation()` | 关闭不冒泡（Flutter 无冒泡，不适用） |
| `@include shadow-elevated` | 卡片投影（全局 shadow token） |
| `@include font-size-header-6` / `@include font-size-regular` | 标题 16/22 / 内容 14/20 |
| `word-wrap: break-word` | 标题/内容换行 |
| `background-image: linear-gradient(0deg,` + `background-color: $color-notification_ambient-bg` | light 覆盖层 + 底色 |
| `z-index: $z-notification` | 列表层级（引擎插入序表达） |
| `pointer-events: none` / `pointer-events: auto` | 列表点穿 / 卡片可点 |
| `translateY(-100%)` / `translateY(100%)` / `translateX(-100%)` / `translateX(100%)` | 入退场位移（按 placement 反向） |
| `appliedUpdates` + `restartCloseTimer` | update() 恰好一次重启计时 |
| `scheduleRemovedNoticeRelease` | 350ms 兜底释放（Flutter 动画回调等价） |
| `getPopupContainer` | 容器路由未移植（宿主恒挂 ambient Overlay） |

重新生成独立主题：`python3 tool/generate_notification.py`（包含 dart format）；对账校验 `python3 tool/test_generate_notification.py`。

## 差异清单

- **duration 单位**：上游 number 秒 → `Duration`（`duration: 3` → `Duration(seconds: 3)`；`0`/`Duration.zero` 不排计时）。
- **title/content**：上游 ReactNode → `Object?`（String/num 走排版，Widget 原样）；falsy 规则照抄（数字 0 不渲染——与 banner `|| title === 0` 不同）。
- **update 合并**：缺省保留原值（copyWith 语义）——上游 JS 展开令 defaultConfig 键（title/content/duration/position/motion/zIndex）缺省回退默认值，怪癖不照抄；清 title/content 传 `''`。
- **useNotification hook**：未移植（React hook/holder 形态；命令式静态族覆盖主场景，useModal 未移植先例）。
- **getPopupContainer**：未移植（宿主恒挂 ambient Overlay；SemiModal engine 路先例）。
- **zIndex**：留档不消费（wrapper `zIndex: 1010` 由引擎插入序表达）。
- **className/style、per-notice direction**：未移植（外层布局承担；方向随 ambient Directionality）。
- **onCloseClick/onClick**：上游 `(e)`/`(id)` → `void Function(String id)` / `VoidCallback`（无冒泡参数）。
- **closeSemanticsLabel**：上游图标钮无 aria-label → 补 '关闭' 语义（locale 约定）。
- **RTL icon/content-wrapper 边距**：上游 rtl.scss 重设同值 margin-right（no-op，疑为漏写镜像）→ EdgeInsetsDirectional 镜像（end 12/8）。
- **同列等宽/shrink-to-fit**：IntrinsicWidth 列宽取最宽 max-content、下限 320（`width: auto` + min-width 语义）；top/bottom 显式 left 偏移以 FractionalTranslation = `translateX(-50%)` 表达。
- **margin 折叠**：CSS 相邻卡片纵向折叠 → 纵向半值对拆 + 列首尾补半值（间距等价）。
- **退出释放**：`scheduleRemovedNoticeRelease` 350ms 兜底不需要（Flutter 动画状态回调可靠，reverse 完成即释放）。
- **semiGlobal `overrideDefaultProps`**：未移植（React 全局 defaultProps 覆盖机制）。
- **inset 阴影层由专用画师渲染**：Flutter 无 CSS inset box-shadow 对应物——drop 层进 BoxDecoration（`toDropBoxShadows()`）、inset 层（dark `--semi-shadow-elevated` 首层 `inset 0 0 0 1px`）由 `SemiInsetShadow` 画师精确绘制（贴 padding-box 的内环、零布局影响）；`toBoxShadows()` 对 inset 抛错的显式合同保留，带 blur/offset 的 inset 层构造即抛。

## 用法

```dart
final id = SemiNotification.success(
  title: '已保存',
  content: '设置已更新',
  duration: const Duration(seconds: 5),
  onClose: () => print('closed'),
);
SemiNotification.close(id);
```

```dart
SemiNotification.warning(
  title: '离线模式下无法保存设置',
  content: '请检查网络连接后重试。',
  position: SemiNotificationPosition.top,
  variant: SemiNotificationVariant.light,
  onCloseClick: (id) => print('closing $id'),
);
```

```dart
SemiNotification.config(duration: const Duration(seconds: 6));
SemiNotification.destroyAll();
```
