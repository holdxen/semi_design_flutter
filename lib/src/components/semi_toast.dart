// SemiToast — 上游 packages/semi-ui/toast/{toast.tsx,index.tsx} 与
// packages/semi-foundation/toast/{toast.scss,variables.scss,animation.scss,
// rtl.scss,toastFoundation.ts,toastListFoundation.ts,constants.ts} 的移植；
// 托管为单个 OverlayEntry（缺省插 `DialogProxy.instance.overlay` 环境
// Overlay（SemiApp 零初始化绑定，PROVENANCE.md），可选 `context` 指定目标
// Overlay——上游 `getPopupContainer` 等价；容器首个展示时确定，同上游
// wrapper 一次创建）。
//
// 主题对账 **47 = 35 FIELDS + 12 MOTION + 0 INTERNAL**（variables.scss 35
// 声明：color 18、spacing 13、width 2、radius 1、font 1；animation.scss 12
// 声明：show/hide/stack 三组 duration/function/delay + opacity/translateY
// 各二；`$module: #{$prefix}-toast` 类名胶水不计，sideSheet `31 = 19 + 12
// + 0`、modal `81 = 63 + 18 + 0` 先例）。0 死变量（toast.scss/rtl.scss
// 逐条消费；constants.ts `LIST: `${PREFIX}-list`` 是死常量但非 Sass 变量，
// HARDCODES 另列）。
//
// stack 卡组模式（v2.42 `stack: true`）已移植（`_ToastDeck`）：
// `spacingToastPerspective` / `spacingToastPerspectiveOriginY` 为
// `&-zero-height-wrapper` 透视叠牌（`translate3d(0,0,-10px*i)` 后退 +
// `perspective-origin: center 280px` 投影），`animationDurationToastStack`
// / `animationFunctionToastStack` 为悬停展开/收起过渡——四字段全部消费；
// `spacingToastContentPaddingY` / `spacingToastContentPaddingX`
// （`$spacing-toast_content-paddingY/-paddingX`）为 padding 四向的 Sass
// 中间引用（值同 Top/Bottom、Left/Right），`widthToastWrapper`（100%）由
// 全宽 Align 居中表达。
//
// HARDCODES（另列，生成器锚点逐字留档）：
// - constants.ts `types: ['warning', 'success', 'info', 'error', 'default']`
//   / `themes: ['normal', 'light']` / `directions: ['ltr', 'rtl']`
// - constants.ts `duration: 3 // default close time, unit: s`（秒制；
//   `duration: 0` 不自动关——上游 `if (duration && isNumber(duration))`）
// - toast.tsx defaultProps `textMaxWidth: 450` / `showClose: true` /
//   `theme: 'normal'`
// - renderIcon：类型图标 `IconAlertTriangle`（warning）/
//   `IconTickCircle`（success）/ `IconInfoCircle`（info）/
//   `IconAlertCircle`（error），`iconSize = 'large'`（20x20）
// - renderCloser：关闭按钮 `type="tertiary"` / `const btnTheme = 'borderless';`
//   / `const btnSize = 'small';`，默认图标 `IconClose`；close-button
//   `height: $width-icon-large`（width 变量作 height，20）+ margin-top -2px
// - render：根节点 `role="alert"`，`aria-label={`${type ? type : 'default'} type`}`
// - index.tsx wrapper：`position: fixed;` / `height: 0;` /
//   `top: $spacing-toast_wrapper-top;` / `width: $width-toast_wrapper;` /
//   `justify-content: center;` / `z-index: $z-toast`（层级由 Overlay 插入序
//   表达）；★上游 `bottom`/`right` 因 wrapper `height: 0` /
//   `width: $width-toast_wrapper` 过约束被 CSS 忽略（over-constrained
//   ignore bottom/right）——不提供参数
// - toast.scss 根 `pointer-events: none;` / content `pointer-events: all;`
//   （命中穿透由 Overlay 空白区自然表达）
// - toast.scss content：`@include shadow-elevated;` /
//   `@include font-size-regular;` / `display: inline-flex;` /
//   `align-items: flex-start;`
// - content-text：`textStyle.maxWidth = textMaxWidth;` / `text-align: left;`
//   / `word-wrap: break-word;` / `overflow-wrap: break-word;`
// - toast.tsx render：`translate3d(0,0,${reservedIndex * -10}px)`（stack
//   卡组纵深：每条 -10px，卡组透视消费）
// - keyframes show：`transform: translateY($animation_transform_translateY-toast-show);`
//   + `animation-fill-mode: forwards;`
// - toast.tsx 悬停计时：`onMouseEnter={this.clearCloseTimer}` /
//   `onMouseLeave={this.startCloseTimer}`（toastFoundation
//   `clearCloseTimer_()` / `startCloseTimer_()` / `restartCloseTimer()`）
// - toastListFoundation updateList 注释：`Reused instances need new timers,
//   including same-id replacements before the next render.`（同 id 更新
//   原地替换并重启计时）
// - index.tsx `getUuid('toast')`（toast-{timestamp}-{random}）/
//   `getUuidShort({ prefix: 'toast-wrapper' })` / `static pendingToasts`
//   （挂载前 pending 队列——Flutter 无对应，show 即入库）
// - toastFoundation close：`e.stopPropagation();`（Flutter 无冒泡，不适用）
//   + `notifyWrapperToRemove(this._id);`
// - index.tsx `getPopupContainer() ?? document.body`
// - constants.ts `LIST: `${PREFIX}-list``（死常量，上游未消费）
// - zero-height-wrapper：`&-zero-height-wrapper`（`height: 0` +
//   `overflow: visible;`）+ `perspective-origin: center $spacing-toast-perspective-originY; ;`
//   ★双分号 quirk + `transition: all $animation_duration-toast-stack $animation_function-toast-stack;`
//   展开/收起过渡（stack 卡组，透视叠牌消费）
// - index.tsx 悬停展开：`stackExpanded: this.state.mouseInSide`（toastList
//   Foundation `handleMouseInSideChange`；`.semi-toast-innerWrapper-hover`
//   覆写 `perspective: unset` 扁平化卡组）
// - rtl.scss：`text-align: right;` /
//   `margin-left: $spacing-toast_content_text-marginRight;`（两侧同值 12
//   互换 no-op；方向性边距自动翻转）
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../overlay/dialog_engine/helper/dialog_proxy.dart';
import '../theme/semi_theme.dart';
import '../theme/semi_theme_data.dart';
import '../theme/semi_toast_theme.dart';
import '../theme/semi_toast_theme_data.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icon_data.dart';
import 'icon/semi_icons.dart';
import 'semi_button.dart';
import 'semi_inset_shadow.dart';

/// 类型（上游 `strings.types`；'default' 是 Dart 关键字，枚举名 `defaultType`）。
enum SemiToastType { warning, success, info, error, defaultType }

/// 主题模式（上游 `theme`，`strings.themes`）。
enum SemiToastThemeMode { normal, light }

/// 轻提示命令式 API（上游 `Toast.info/warning/error/success`、`Toast.config`、
/// `Toast.close`、`Toast.destroyAll`）。方法返回 toastId（上游
/// `toast-{timestamp}-{random}`），同 id 重复调用原地更新并重启计时。
class SemiToast {
  SemiToast._();

  static _ToastConfig _config = const _ToastConfig();
  static OverlayEntry? _entry;
  static final _ToastList _list = _ToastList.instance;
  static final math.Random _random = math.Random();

  /// 默认类型（上游 `Toast.create` / `useToast().open`，`type: 'default'`
  /// 无图标）。
  static String show({
    Object? content,
    String? id,
    double? duration,
    bool? showClose,
    Widget? icon,
    double? textMaxWidth,
    SemiToastThemeMode? theme,
    bool? stack,
    TextDirection? direction,
    VoidCallback? onClose,
    BuildContext? context,
  }) => _show(
    SemiToastType.defaultType,
    content: content,
    id: id,
    duration: duration,
    showClose: showClose,
    icon: icon,
    textMaxWidth: textMaxWidth,
    theme: theme,
    stack: stack,
    direction: direction,
    onClose: onClose,
    context: context,
  );

  /// `Toast.info`。
  static String info({
    Object? content,
    String? id,
    double? duration,
    bool? showClose,
    Widget? icon,
    double? textMaxWidth,
    SemiToastThemeMode? theme,
    bool? stack,
    TextDirection? direction,
    VoidCallback? onClose,
    BuildContext? context,
  }) => _show(
    SemiToastType.info,
    content: content,
    id: id,
    duration: duration,
    showClose: showClose,
    icon: icon,
    textMaxWidth: textMaxWidth,
    theme: theme,
    stack: stack,
    direction: direction,
    onClose: onClose,
    context: context,
  );

  /// `Toast.warning`。
  static String warning({
    Object? content,
    String? id,
    double? duration,
    bool? showClose,
    Widget? icon,
    double? textMaxWidth,
    SemiToastThemeMode? theme,
    bool? stack,
    TextDirection? direction,
    VoidCallback? onClose,
    BuildContext? context,
  }) => _show(
    SemiToastType.warning,
    content: content,
    id: id,
    duration: duration,
    showClose: showClose,
    icon: icon,
    textMaxWidth: textMaxWidth,
    theme: theme,
    stack: stack,
    direction: direction,
    onClose: onClose,
    context: context,
  );

  /// `Toast.error`。
  static String error({
    Object? content,
    String? id,
    double? duration,
    bool? showClose,
    Widget? icon,
    double? textMaxWidth,
    SemiToastThemeMode? theme,
    bool? stack,
    TextDirection? direction,
    VoidCallback? onClose,
    BuildContext? context,
  }) => _show(
    SemiToastType.error,
    content: content,
    id: id,
    duration: duration,
    showClose: showClose,
    icon: icon,
    textMaxWidth: textMaxWidth,
    theme: theme,
    stack: stack,
    direction: direction,
    onClose: onClose,
    context: context,
  );

  /// `Toast.success`。
  static String success({
    Object? content,
    String? id,
    double? duration,
    bool? showClose,
    Widget? icon,
    double? textMaxWidth,
    SemiToastThemeMode? theme,
    bool? stack,
    TextDirection? direction,
    VoidCallback? onClose,
    BuildContext? context,
  }) => _show(
    SemiToastType.success,
    content: content,
    id: id,
    duration: duration,
    showClose: showClose,
    icon: icon,
    textMaxWidth: textMaxWidth,
    theme: theme,
    stack: stack,
    direction: direction,
    onClose: onClose,
    context: context,
  );

  /// 全局默认配置（上游 `Toast.config` + semiGlobal 覆盖语义）：null 项保持
  /// 现值。
  ///
  /// `stack` 上游不经 `Toast.config` 而经 semiGlobal
  /// `overrideDefaultProps.Toast` 全局生效——本移植并入 config（调用级
  /// `stack` 参数优先）。上游 ConfigProps 的 `zIndex`（缺省 1010）、
  /// `bottom`/`right` 未移植：层级由 Overlay 插入序表达；`bottom`/`right`
  /// 上游即因过约束不生效。
  static void config({
    double? top,
    double? left,
    double? duration,
    SemiToastThemeMode? theme,
    bool? stack,
    BuildContext? context,
  }) {
    _config = _config.copyWith(
      top: top,
      left: left,
      duration: duration,
      theme: theme,
      stack: stack,
      context: context,
    );
  }

  /// 关闭单条（上游 `Toast.close(id)`）：回调 `onClose` 并播离场动画。
  static void close(String id) => _list.close(id);

  /// 全部销毁（上游 `Toast.destroyAll()`）：清列表与宿主，不回调 `onClose`。
  static void destroyAll() {
    _list.destroyAll();
    _entry?.remove();
    _entry = null;
  }

  /// 测试复位（配置 + 全部销毁）。
  @visibleForTesting
  static void reset() {
    destroyAll();
    _config = const _ToastConfig();
  }

  static String _show(
    SemiToastType type, {
    required Object? content,
    required String? id,
    required double? duration,
    required bool? showClose,
    required Widget? icon,
    required double? textMaxWidth,
    required SemiToastThemeMode? theme,
    required bool? stack,
    required TextDirection? direction,
    required VoidCallback? onClose,
    required BuildContext? context,
  }) {
    // index.tsx `getUuid('toast')` -> `toast-{timestamp}-{random}`。
    final toastId =
        id ??
        'toast-${DateTime.now().millisecondsSinceEpoch}'
            '-${_random.nextInt(0x7fffffff)}';
    final spec = _ToastSpec(
      content: content,
      type: type,
      icon: icon,
      textMaxWidth: textMaxWidth ?? 450,
      showClose: showClose ?? true,
      duration: duration ?? _config.duration ?? 3,
      themeMode: theme ?? _config.theme ?? SemiToastThemeMode.normal,
      // 卡组开关合并（上游 `Boolean(mergedOpts.stack)`：opts > 全局覆盖 >
      // 缺省 false；★每次 create 都覆写列表级开关——last-call-wins quirk）。
      stack: stack ?? _config.stack ?? false,
      direction: direction,
      onClose: onClose,
      theme: _resolveTheme(context ?? _config.context),
    );
    _list.upsert(toastId, spec);
    _ensureHost(context ?? _config.context);
    return toastId;
  }

  /// 主题解析锚点（SemiModal `_resolveTheme` 先例）：带 context 时随调用处
  /// 解析（含本地 `SemiToastTheme` patch）；缺省返回 null，宿主构建时随环境
  /// 主题解析。
  static SemiResolvedToastThemeData? _resolveTheme(BuildContext? context) {
    if (context == null || !context.mounted) return null;
    final base = SemiToastTheme.maybeOf(context);
    final semi = SemiTheme.maybeOf(context);
    if (base == null && semi == null) return null;
    return (base ?? const SemiToastThemeData()).resolve(
      semi ?? const SemiThemeData.light(),
    );
  }

  /// 宿主入库：单个全宽 OverlayEntry（上游 wrapper 一次创建语义）。
  static void _ensureHost(BuildContext? context) {
    if (_entry != null) return;
    OverlayState? overlay;
    if (context != null && context.mounted) {
      overlay = Overlay.maybeOf(context);
    }
    overlay ??= DialogProxy.instance.isBound
        ? DialogProxy.instance.overlay
        : null;
    assert(
      overlay != null,
      'SemiToast 需要环境 Overlay（SemiApp 零初始化绑定或 DialogProxy.bind）'
      '，或在调用时传入 context',
    );
    if (overlay == null) return;
    _entry = OverlayEntry(builder: (_) => const _ToastHost());
    overlay.insert(_entry!);
  }
}

/// 单条配置快照（合并优先级 `opts > config > 缺省`，同上游
/// `...defaultOpts, ...globalConfig, ...opts`）。
class _ToastSpec {
  const _ToastSpec({
    required this.content,
    required this.type,
    required this.icon,
    required this.textMaxWidth,
    required this.showClose,
    required this.duration,
    required this.themeMode,
    required this.stack,
    required this.direction,
    required this.onClose,
    required this.theme,
  });

  final Object? content;
  final SemiToastType type;
  final Widget? icon;
  final double textMaxWidth;
  final bool showClose;

  /// 秒制（上游 `duration: 3 // default close time, unit: s`）；0 不自动关。
  final double? duration;
  final SemiToastThemeMode themeMode;

  /// 卡组开关（上游 `stack`；★列表级 last-call-wins——每次 create 覆写）。
  final bool stack;
  final TextDirection? direction;
  final VoidCallback? onClose;

  /// 调用时主题快照；null 由宿主按环境主题解析。
  final SemiResolvedToastThemeData? theme;
}

/// 全局缺省（上游 `ToastList.defaultOpts` + `Toast.config` 合并目标）。
class _ToastConfig {
  const _ToastConfig({
    this.top,
    this.left,
    this.duration,
    this.theme,
    this.stack,
    this.context,
  });

  final double? top;
  final double? left;
  final double? duration;
  final SemiToastThemeMode? theme;
  final bool? stack;
  final BuildContext? context;

  _ToastConfig copyWith({
    double? top,
    double? left,
    double? duration,
    SemiToastThemeMode? theme,
    bool? stack,
    BuildContext? context,
  }) => _ToastConfig(
    top: top ?? this.top,
    left: left ?? this.left,
    duration: duration ?? this.duration,
    theme: theme ?? this.theme,
    stack: stack ?? this.stack,
    context: context ?? this.context,
  );
}

/// 单条运行时（toastFoundation 计时语义的 Dart 迁移）。
class _ToastItem {
  _ToastItem(this.id, this.spec);

  final String id;
  _ToastSpec spec;
  Timer? timer;
  bool leaving = false;

  /// 离场动画启动钩子（视图挂载时注册）。
  void Function()? onLeaving;

  /// `startCloseTimer_()`：秒制计时；`duration: 0` 不自动关（上游
  /// `if (duration && isNumber(duration))`）。
  void startCloseTimer() {
    final duration = spec.duration;
    if (duration != null && duration > 0) {
      timer = Timer(
        Duration(milliseconds: (duration * 1000).round()),
        () => _ToastList.instance.close(id),
      );
    }
  }

  /// `clearCloseTimer_()`（悬停暂停）。
  void cancelTimer() {
    timer?.cancel();
    timer = null;
  }

  /// `restartCloseTimer()`：清后重启**全量**时长（同 id 更新/悬停离开）。
  void restartCloseTimer() {
    cancelTimer();
    startCloseTimer();
  }
}

/// 列表逻辑（toastListFoundation 的 Dart 迁移：增/改/删 + 离场裁剪）。
class _ToastList extends ChangeNotifier {
  _ToastList._();

  static final _ToastList instance = _ToastList._();

  final List<_ToastItem> items = [];

  /// 卡组开关（上游 `ToastList.ref.stack`）：列表级、每次 create 覆写
  /// （★last-call-wins quirk——`Boolean(mergedOpts.stack)`，缺省 false）。
  bool stack = false;

  bool has(String id) => items.any((item) => item.id == id);

  void upsert(String id, _ToastSpec spec) {
    stack = spec.stack;
    // toastListFoundation updateList 注释：`Reused instances need new timers, including same-id replacements before the next render.`
    // ——同 id 更新原地替换并重启计时。
    final index = items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      final item = items[index];
      if (item.leaving) {
        // 离场中复出按新实例处理（新进场动画）。
        item.cancelTimer();
        items.removeAt(index);
        items.add(_ToastItem(id, spec)..startCloseTimer());
      } else {
        item.spec = spec;
        item.restartCloseTimer();
      }
    } else {
      items.add(_ToastItem(id, spec)..startCloseTimer());
    }
    notifyListeners();
  }

  void close(String id) {
    final index = items.indexWhere((item) => item.id == id && !item.leaving);
    if (index < 0) return;
    final item = items[index];
    // toastFoundation close：`e.stopPropagation();` 不适用（Flutter 无冒泡）；
    // `notifyWrapperToRemove(this._id);`（标记离场）后 `notifyClose()`。
    item.cancelTimer();
    item.leaving = true;
    item.spec.onClose?.call();
    item.onLeaving?.call();
    notifyListeners();
  }

  /// 离场动画结束后裁剪（上游 onAnimationEnd 从 removedItems 移除）。
  void prune(_ToastItem item) {
    if (items.remove(item)) notifyListeners();
  }

  void destroyAll() {
    for (final item in items) {
      item.cancelTimer();
    }
    items.clear();
    // 上游销毁 wrapper 后重建的 ToastList 实例 `stack: boolean = false`。
    stack = false;
    notifyListeners();
  }
}

/// 宿主（上游 `semi-toast-wrapper` + `innerWrapper`）：全宽居中的纵向列表，
/// 离场条目保留至动画结束再裁剪。
class _ToastHost extends StatelessWidget {
  const _ToastHost();

  @override
  Widget build(BuildContext context) {
    final base = SemiToastTheme.maybeOf(context) ?? const SemiToastThemeData();
    final theme = base.resolve(
      SemiTheme.maybeOf(context) ?? const SemiThemeData.light(),
    );
    final config = SemiToast._config;
    // index.tsx wrapper：`position: fixed;` / `height: 0;` /
    // `top: $spacing-toast_wrapper-top;` / `width: $width-toast_wrapper;` /
    // `justify-content: center;` / `z-index: $z-toast`——全宽 + flex 居中
    // 由 Align/Positioned 表达（widthToastWrapper 100% digits stand-in，
    // zIndex 由 Overlay 插入序表达）。`left` 平移 = 上游 width 过伸效果；
    // ★`bottom`/`right` 上游因 `height: 0` 过约束被 CSS 忽略（over-
    // constrained ignore bottom/right），不提供参数。
    final shift = config.left ?? 0;
    return ListenableBuilder(
      listenable: _ToastList.instance,
      builder: (context, _) => Stack(
        children: [
          Positioned(
            top: config.top ?? theme.spacingToastWrapperTop,
            left: shift,
            right: -shift,
            // stack 卡组开关为列表级（上游 `ToastList.ref.stack`）。
            child: _ToastList.instance.stack
                ? _ToastDeck(items: _ToastList.instance.items, theme: theme)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (final item in _ToastList.instance.items)
                        // GlobalObjectKey 让视图状态（AnimationController /
                        // onLeaving）按条目跟随：列表增删时不按位置串位，先
                        // 关闭的条目裁剪后存活条目上移补位，无透明占位残留；
                        // 列表/卡组切换时状态同样跟随。
                        _ToastItemView(key: GlobalObjectKey(item), item: item),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// stack 卡组宿主（上游 `stack: true` + `&-zero-height-wrapper` + 悬停展开）。
///
/// 非悬停：各条目在卡组原点重叠（`height: 0` + `overflow: visible;` 语义，
/// 宿主高度取透视包络），按 `translate3d(0,0,${reservedIndex * -10}px)`
/// 透视后退叠牌（`perspective` / `perspective-origin` 消费）；悬停
/// `stackExpanded: this.state.mouseInSide` 展开为常规列表（`handleMouseInSideChange`），
/// 条目间距与包络按 `transition: all $animation_duration-toast-stack
/// $animation_function-toast-stack;` 过渡，离开收起。条目高度 post-frame 量
/// 高（ResizeObserver 语义迁移）。
class _ToastDeck extends StatefulWidget {
  const _ToastDeck({required this.items, required this.theme});

  final List<_ToastItem> items;
  final SemiResolvedToastThemeData theme;

  @override
  State<_ToastDeck> createState() => _ToastDeckState();
}

class _ToastDeckState extends State<_ToastDeck>
    with SingleTickerProviderStateMixin {
  /// `translate3d(0,0,${reservedIndex * -10}px)`：每条后退 10px。
  static const double _zStep = 10;

  late final AnimationController _expand;
  final Map<String, double> _heights = {};
  final Map<String, double> _widths = {};

  @override
  void initState() {
    super.initState();
    _expand = AnimationController(
      vsync: this,
      duration: widget.theme.animationDurationToastStack,
    );
  }

  @override
  void didUpdateWidget(covariant _ToastDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    _expand.duration = widget.theme.animationDurationToastStack;
  }

  @override
  void dispose() {
    _expand.dispose();
    super.dispose();
  }

  /// ResizeObserver 量高迁移：post-frame 回读布局尺寸，变化才重建。
  void _measure() {
    final ids = {for (final item in widget.items) item.id};
    _heights.removeWhere((id, _) => !ids.contains(id));
    _widths.removeWhere((id, _) => !ids.contains(id));
    var changed = false;
    for (final item in widget.items) {
      final box = GlobalObjectKey(item).currentContext?.findRenderObject();
      if (box is RenderBox && box.hasSize) {
        final size = box.size;
        if (_heights[item.id] != size.height ||
            _widths[item.id] != size.width) {
          _heights[item.id] = size.height;
          _widths[item.id] = size.width;
          changed = true;
        }
      }
    }
    if (changed && mounted) setState(() {});
  }

  /// 透视合成（CSS `perspective: d` + `perspective-origin: center oy` +
  /// 子级 `translate3d(0,0,z)`）：`T(0,oy) ∘ P ∘ T(0,-oy) ∘ T3D(z)`；
  /// center 轴由 Transform alignment `topCenter` 表达。
  Matrix4 _deckMatrix(double z) {
    final d = widget.theme.spacingToastPerspective;
    final oy = widget.theme.spacingToastPerspectiveOriginY;
    return Matrix4.identity()
      ..multiply(Matrix4.translationValues(0, oy, 0))
      ..multiply(Matrix4.identity()..setEntry(3, 2, -1 / d))
      ..multiply(Matrix4.translationValues(0, -oy, 0))
      ..multiply(Matrix4.translationValues(0, 0, z));
  }

  /// 透视包络：`oy + (h - oy) * d / (d + 10k)`（z = -10k 的投影下边界）。
  double _projectedBottom(double h, int reservedIndex) {
    final d = widget.theme.spacingToastPerspective;
    final oy = widget.theme.spacingToastPerspectiveOriginY;
    return oy + (h - oy) * d / (d + _zStep * reservedIndex);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    final items = widget.items;
    final curve = widget.theme.animationFunctionToastStack;
    return AnimatedBuilder(
      animation: _expand,
      builder: (context, _) {
        final progress = _expand.value;
        final spread = curve.transform(progress);
        // 上游 `perspective: unset` 不可插值——CSS 过渡 50% 处离散翻转，
        // 卡组透视在展开过半时消失（收起反之）。
        final decked = progress < 0.5;
        var cursor = 0.0;
        var deckExtent = 0.0;
        var maxW = 0.0;
        final tops = <double>[];
        for (var i = 0; i < items.length; i++) {
          final h = _heights[items[i].id] ?? 0;
          // 非悬停各条目重叠于卡组原点（`height: 0`）；展开位置按量高
          // 累计插值。
          tops.add(cursor * spread);
          cursor += h;
          final projected = _projectedBottom(h, items.length - 1 - i);
          if (projected > deckExtent) deckExtent = projected;
          final w = _widths[items[i].id] ?? 0;
          if (w > maxW) maxW = w;
        }
        return SizedBox(
          height: deckExtent + (cursor - deckExtent) * spread,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < items.length; i++)
                Positioned(
                  top: tops[i],
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Transform(
                      transform: decked
                          ? _deckMatrix(-_zStep * (items.length - 1 - i))
                          : Matrix4.identity(),
                      alignment: Alignment.topCenter,
                      child: _ToastItemView(
                        key: GlobalObjectKey(items[i]),
                        item: items[i],
                      ),
                    ),
                  ),
                ),
              // 悬停命中层贴内容（上游 innerWrapper `width: fit-content` /
              // `height: fit-content`）而非整行宽——鼠标水平移开即收起。
              // translucent + `opaque: false`：不吸收点击、不挡卡片自身的
              // 悬停区域。
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: maxW,
                    height: deckExtent + (cursor - deckExtent) * spread,
                    child: MouseRegion(
                      opaque: false,
                      hitTestBehavior: HitTestBehavior.translucent,
                      // `stackExpanded: this.state.mouseInSide`（悬停展开/
                      // 收起）。
                      onEnter: (_) => _expand.forward(),
                      onExit: (_) => _expand.reverse(),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 单条视图：进/离场动画（keyframes show/hide）+ 悬停计时 + 视觉组装。
class _ToastItemView extends StatefulWidget {
  const _ToastItemView({super.key, required this.item});

  final _ToastItem item;

  @override
  State<_ToastItemView> createState() => _ToastItemViewState();
}

class _ToastItemViewState extends State<_ToastItemView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  CurvedAnimation? _curved;
  late SemiResolvedToastThemeData _t;
  bool _started = false;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      // 离场动画结束才裁剪（上游只在 leave onAnimationEnd 清理）。
      if (status == AnimationStatus.dismissed && widget.item.leaving) {
        _ToastList.instance.prune(widget.item);
      }
    });
    widget.item.onLeaving = _startLeave;
    // close() 先于首帧（onLeaving 未挂载）：视图建成后补启动离场。
    if (widget.item.leaving) _startLeave();
  }

  @override
  void didUpdateWidget(covariant _ToastItemView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.leaving) _startLeave();
  }

  /// 启动离场（幂等）：`notifyWrapperToRemove` 后播离场动画再裁剪；进场未
  /// 启动（controller 仍 dismissed）时无动画可播，post-frame 直接裁剪，
  /// 不留透明占位。
  void _startLeave() {
    if (_leaving) return;
    _leaving = true;
    if (_controller.isDismissed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ToastList.instance.prune(widget.item);
      });
      return;
    }
    unawaited(_leave());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _t = _resolveTheme();
    _controller.duration = _t.animationDurationToastShow;
    _controller.reverseDuration = _t.animationDurationToastHide;
    _curved?.dispose();
    // show/hide 同一过冲曲线族（`cubic-bezier(.22,.57,.02,1.2)`）——
    // 正放 show 曲线、反放 hide 曲线。
    _curved = CurvedAnimation(
      parent: _controller,
      curve: _t.animationFunctionToastShow,
      reverseCurve: _t.animationFunctionToastHide,
    );
    if (!_started) {
      _started = true;
      unawaited(_enter());
    }
  }

  SemiResolvedToastThemeData _resolveTheme() {
    final spec = widget.item.spec.theme;
    if (spec != null) return spec;
    final base = SemiToastTheme.maybeOf(context) ?? const SemiToastThemeData();
    return base.resolve(
      SemiTheme.maybeOf(context) ?? const SemiThemeData.light(),
    );
  }

  Future<void> _enter() async {
    // `animation_delay-toast-show: 0s`（★`0s` 写法）——零延迟直接放行，
    // 不起 Timer。
    if (_t.animationDelayToastShow > Duration.zero) {
      await Future<void>.delayed(_t.animationDelayToastShow);
    }
    if (mounted && !widget.item.leaving) {
      await _controller.forward();
    }
  }

  Future<void> _leave() async {
    if (_t.animationDelayToastHide > Duration.zero) {
      await Future<void>.delayed(_t.animationDelayToastHide);
    }
    if (mounted) await _controller.reverse();
  }

  @override
  void dispose() {
    widget.item.onLeaving = null;
    _curved?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final spec = item.spec;
    final semiTheme = SemiTheme.maybeOf(context) ?? const SemiThemeData.light();
    final direction =
        spec.direction ?? Directionality.maybeOf(context) ?? TextDirection.ltr;
    final isLight = spec.themeMode == SemiToastThemeMode.light;
    final (
      Color bg,
      Color? iconColor,
      Color? borderColor,
    ) = switch (spec.type) {
      SemiToastType.warning =>
        isLight
            ? (
                _t.colorToastWarningLightBg,
                _t.colorToastWarningLightIcon,
                _t.colorToastWarningLightBorder,
              )
            : (_t.colorToastBgDefault, _t.colorToastWarningIcon, null),
      SemiToastType.success =>
        isLight
            ? (
                _t.colorToastSuccessLightBg,
                _t.colorToastSuccessLightIcon,
                _t.colorToastSuccessLightBorder,
              )
            : (_t.colorToastBgDefault, _t.colorToastSuccessIcon, null),
      SemiToastType.info =>
        isLight
            ? (
                _t.colorToastInfoLightBg,
                _t.colorToastInfoLightIcon,
                _t.colorToastInfoLightBorder,
              )
            : (_t.colorToastBgDefault, _t.colorToastInfoIcon, null),
      SemiToastType.error =>
        isLight
            ? (
                _t.colorToastDangerLightBg,
                _t.colorToastDangerLightIcon,
                _t.colorToastDangerLightBorder,
              )
            : (_t.colorToastBgDefault, _t.colorToastDangerIcon, null),
      // `type: 'default'` 无图标（renderIcon `return null;`），`-light`
      // 样式也仅四类型消费。
      SemiToastType.defaultType => (_t.colorToastBgDefault, null, null),
    };

    // renderIcon：`iconSize = 'large'`（20x20）类型图标；自定义 `icon` 原样。
    final Widget? iconSlot =
        spec.icon ??
        (iconColor == null
            ? null
            : SemiIcon(
                switch (spec.type) {
                  SemiToastType.warning => SemiIcons.alertTriangle,
                  SemiToastType.success => SemiIcons.tickCircle,
                  SemiToastType.info => SemiIcons.infoCircle,
                  SemiToastType.error => SemiIcons.alertCircle,
                  SemiToastType.defaultType => SemiIcons.infoCircle,
                },
                size: SemiIconSize.large,
                color: iconColor,
              ));

    // renderCloser：`type="tertiary"` / `const btnTheme = 'borderless';` /
    // `const btnSize = 'small';` + `IconClose`；close-button
    // `height: $width-icon-large`（width 变量作 height，20）+ margin-top
    // -2px（负 margin 无 Flutter 对应，translate 表达）。
    final Widget? closeSlot = !spec.showClose
        ? null
        : Transform.translate(
            offset: Offset(0, _t.spacingToastContentCloseBtnMarginTop),
            child: SizedBox(
              height: 20,
              child: SemiButton(
                null,
                icon: const SemiIcon(SemiIcons.close),
                type: SemiButtonType.tertiary,
                variant: SemiButtonVariant.borderless,
                size: SemiButtonSize.small,
                semanticsLabel: '关闭',
                onPressed: () => _ToastList.instance.close(item.id),
              ),
            ),
          );

    // content-text：`textStyle.maxWidth = textMaxWidth;` /
    // `text-align: left;`（rtl.scss 翻 `text-align: right;`）/
    // `word-wrap: break-word;` / `overflow-wrap: break-word;`（Flutter 默认
    // 软换行 + 尺寸约束表达）。
    final Widget textSlot = Padding(
      // rtl.scss：`margin-left: $spacing-toast_content_text-marginRight;`
      // （两侧同值 12 互换 no-op）——方向性边距自动翻转。
      padding: EdgeInsetsDirectional.only(
        start: _t.spacingToastContentTextMarginLeft,
        end: _t.spacingToastContentTextMarginRight,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: spec.textMaxWidth),
        child: switch (spec.content) {
          final Widget w => w,
          final o => Text(
            (o ?? '').toString(),
            textAlign: direction == TextDirection.rtl
                ? TextAlign.right
                : TextAlign.left,
            style: TextStyle(
              // `@include font-size-regular`（根字号 14）。
              fontSize: semiTheme.typography.fontSizeRegular,
              fontWeight: _t.fontToastContentFontWeight,
              color: _t.colorToastTextDefault,
            ),
          ),
        },
      ),
    );

    final Widget content = Container(
      margin: EdgeInsets.all(_t.spacingToastContentMargin),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(_t.radiusToastContent),
        // `-light`：`$width-toast_light-border` 描边（仅四类型）。
        border: borderColor == null
            ? null
            : Border.all(width: _t.widthToastLightBorder, color: borderColor),
        // `@include shadow-elevated;`——inset 层走 SemiInsetShadow 画师
        // （见差异清单）。
        boxShadow: semiTheme.shadows.shadowElevated.toDropBoxShadows(),
      ),
      child: SemiInsetShadow(
        shadows: semiTheme.shadows.shadowElevated,
        borderRadius: BorderRadius.circular(_t.radiusToastContent),
        borderWidth: borderColor == null ? 0 : _t.widthToastLightBorder,
        child: Padding(
          padding: EdgeInsets.only(
            top: _t.spacingToastContentPaddingTop,
            right: _t.spacingToastContentPaddingRight,
            bottom: _t.spacingToastContentPaddingBottom,
            left: _t.spacingToastContentPaddingLeft,
          ),
          child: Row(
            // `display: inline-flex;` / `align-items: flex-start;` /
            // `justify-content: center;`（shrink-to-fit 由 mainAxisSize.min 表达）。
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [?iconSlot, textSlot, ?closeSlot],
          ),
        ),
      ),
    );

    final Widget body = MouseRegion(
      // `onMouseEnter={this.clearCloseTimer}` /
      // `onMouseLeave={this.startCloseTimer}`（悬停暂停/离开全量重启）。
      onEnter: (_) => item.cancelTimer(),
      onExit: (_) => item.restartCloseTimer(),
      child: Semantics(
        // render：`role="alert"` +
        // `aria-label={`${type ? type : 'default'} type`}`。
        liveRegion: true,
        label:
            '${spec.type == SemiToastType.defaultType ? 'default' : spec.type.name} '
            'type',
        child: content,
      ),
    );

    return AnimatedBuilder(
      animation: _curved!,
      builder: (context, child) {
        // keyframes show：`transform: translateY($animation_transform_translateY-toast-show);`
        // + `animation-fill-mode: forwards;`；hide 反向到
        // `$animation_transform_translateY-toast-hide`（两组字段各归各消费，
        // 过冲缓动可越界，opacity 依 CSS 语义钳制）。
        final v = _curved!.value;
        final hiddenOpacity = item.leaving
            ? _t.animationOpacityToastHide
            : _t.animationOpacityToastShow;
        final hiddenY = item.leaving
            ? _t.animationTransformTranslateYToastHide
            : _t.animationTransformTranslateYToastShow;
        return Opacity(
          opacity: (hiddenOpacity + (1 - hiddenOpacity) * v).clamp(0.0, 1.0),
          // `-100%` = 元素自身高（FractionalTranslation 语义同 CSS %）。
          child: FractionalTranslation(
            translation: Offset(0, (1 - v) * hiddenY / 100),
            child: child,
          ),
        );
      },
      child: body,
    );
  }
}
