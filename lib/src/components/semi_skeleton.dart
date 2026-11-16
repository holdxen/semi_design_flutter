// SemiSkeleton — 上游 packages/semi-ui/skeleton/{index.tsx,item.tsx} 与
// packages/semi-foundation/skeleton/skeleton.scss 的移植。
//
// 主题对账 **17 = 15 FIELDS + 2 MOTION + 0 INTERNAL**（variables.scss 15 声明
// + animation.scss 2 声明；`$module` 类名胶水与 rtl.scss 的 `direction: rtl`
// 不计；datePicker `223 = 220 + 3 + 0` … upload `85 = 85 + 0 + 0` 先例）。
// 0 死变量。
//
// HARDCODES（另列，生成器锚点逐字留档）：
// - skeleton.scss:94-99 高亮三段渐变 `linear-gradient(90deg, ... 25%, ... 44%, ... 88%)`
// - skeleton.scss:96 `background-size: 400% 100%`
// - keyframes 0% `background-position: 100% 50%` → 100% `background-position: 0 50%`
// - skeleton.scss:101 `animation: ... infinite`；:102 `animation-fill-mode: forwards`
// - skeleton.scss:15 avatar-circle `border-radius: 50%`
// - skeleton.scss:64 li:last-child `width: 60%`；:68 li:first-child `width: 100%`
//   （CSS 后写者胜 —— rows === 1 时首行也是 100%）
// - skeleton.scss:52 `list-style-type: none`
// - item.tsx:88 paragraph 缺省 `rows: 4`
// - item.tsx:42-43 avatar 缺省 `size: 'medium'` / `shape: 'circle'`
// - avatar strings.SIZE
//   `'extra-extra-small', 'extra-small', 'small', 'default', 'medium', 'large', 'extra-large'`
//   （★`default` 无 skeleton CSS 尺寸类 —— 零尺寸 quirk，Flutter 枚举不收）
import 'package:flutter/widgets.dart';

import '../theme/semi_skeleton_theme.dart';
import '../theme/semi_skeleton_theme_data.dart';

/// 骨架屏头像尺寸（上游 avatar `strings.SIZE` 去掉 `default`：skeleton.scss
/// 没有 `-avatar-default` 尺寸类，选了也是零尺寸）。
enum SemiSkeletonAvatarSize {
  extraExtraSmall,
  extraSmall,
  small,
  medium,
  large,
  extraLarge,
}

/// 骨架屏头像形状（上游 `shape: 'circle' | 'square'`，缺省 circle）。
enum SemiSkeletonAvatarShape { circle, square }

/// 骨架屏容器。
///
/// 上游 index.tsx:35-53：`loading` 为真渲染 `placeholder`（外层仅带
/// `semi-skeleton` / `-active` 类），否则渲染 `children`。`active` 给
/// placeholder 内所有骨架形状套上 1400ms 的高亮扫光（skeleton.scss:89-103）。
class SemiSkeleton extends StatefulWidget {
  const SemiSkeleton({
    super.key,
    this.active = false,
    this.loading = true,
    this.placeholder,
    this.child,
  });

  /// 高亮扫光开关（仅 `loading` 时生效）。
  final bool active;

  /// 缺省 true：渲染 [placeholder]，否则渲染 [child]。
  final bool loading;

  /// 骨架内容（通常由 [SemiSkeletonAvatar] / [SemiSkeletonTitle] /
  /// [SemiSkeletonParagraph] 等组合）。
  final Widget? placeholder;

  /// `loading: false` 时的真实内容。
  final Widget? child;

  @override
  State<SemiSkeleton> createState() => _SemiSkeletonState();
}

class _SemiSkeletonState extends State<SemiSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  Curve _curve = Curves.ease;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = SemiSkeletonTheme.resolve(context);
    _curve = theme.animationFunctionSkeletonHighlight;
    final duration = theme.animationDurationSkeletonHighlight;
    _controller.duration = duration > Duration.zero
        ? duration
        : const Duration(milliseconds: 1);
    _sync();
  }

  @override
  void didUpdateWidget(SemiSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final shouldRun = widget.active && widget.loading;
    if (shouldRun && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldRun && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.loading) return widget.child ?? const SizedBox.shrink();
    final placeholder = widget.placeholder ?? const SizedBox.shrink();
    if (!widget.active) return placeholder;
    // `animation: 1400ms skeleton-loading ease infinite` —— 时长/缓动来自主题。
    return _SkeletonShimmerScope(
      animation: _controller.drive(CurveTween(curve: _curve)),
      child: placeholder,
    );
  }
}

/// 头像占位（skeleton.scss:10-51）：圆形（缺省，`border-radius: 50%`）或
/// 胶囊方形（`$radius-skeleton_item`），六档尺寸。
class SemiSkeletonAvatar extends StatelessWidget {
  const SemiSkeletonAvatar({
    super.key,
    this.size = SemiSkeletonAvatarSize.medium,
    this.shape = SemiSkeletonAvatarShape.circle,
  });

  final SemiSkeletonAvatarSize size;
  final SemiSkeletonAvatarShape shape;

  @override
  Widget build(BuildContext context) {
    final theme = SemiSkeletonTheme.resolve(context);
    final dimension = switch (size) {
      SemiSkeletonAvatarSize.extraExtraSmall =>
        theme.widthSkeletonAvatarExtraExtraSmall,
      SemiSkeletonAvatarSize.extraSmall => theme.widthSkeletonAvatarExtraSmall,
      SemiSkeletonAvatarSize.small => theme.widthSkeletonAvatarSmall,
      SemiSkeletonAvatarSize.medium => theme.widthSkeletonAvatarMedium,
      SemiSkeletonAvatarSize.large => theme.widthSkeletonAvatarLarge,
      SemiSkeletonAvatarSize.extraLarge => theme.widthSkeletonAvatarExtraLarge,
    };
    final radius = shape == SemiSkeletonAvatarShape.circle
        ? dimension / 2
        : theme.radiusSkeletonItem;
    return _SkeletonFill(
      width: dimension,
      height: dimension,
      borderRadius: BorderRadius.circular(radius),
    );
  }
}

/// 图片占位（skeleton.scss:78-81 `width: 100%; height: 100%`）——铺满父级，
/// 父级需给受限宽高。
class SemiSkeletonImage extends StatelessWidget {
  const SemiSkeletonImage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SemiSkeletonTheme.resolve(context);
    return _SkeletonFill(
      width: double.infinity,
      height: double.infinity,
      borderRadius: BorderRadius.circular(theme.radiusSkeletonItem),
    );
  }
}

/// 标题占位（skeleton.scss:73-76）：宽 100%、高 `$height-skeleton_title`。
class SemiSkeletonTitle extends StatelessWidget {
  const SemiSkeletonTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SemiSkeletonTheme.resolve(context);
    return _SkeletonFill(
      width: double.infinity,
      height: theme.heightSkeletonTitle,
      borderRadius: BorderRadius.circular(theme.radiusSkeletonItem),
    );
  }
}

/// 按钮占位（skeleton.scss:73-86）：115 × 32。
class SemiSkeletonButton extends StatelessWidget {
  const SemiSkeletonButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SemiSkeletonTheme.resolve(context);
    return _SkeletonFill(
      width: theme.widthSkeletonButton,
      height: theme.heightSkeletonButton,
      borderRadius: BorderRadius.circular(theme.radiusSkeletonItem),
    );
  }
}

/// 段落占位（item.tsx:71-92，缺省 4 行）：每行高 16、行距 10，最后一行宽
/// 60%（单行时 100%，同名 CSS 后写者胜）。
class SemiSkeletonParagraph extends StatelessWidget {
  const SemiSkeletonParagraph({super.key, this.rows = 4});

  final int rows;

  @override
  Widget build(BuildContext context) {
    final theme = SemiSkeletonTheme.resolve(context);
    final count = rows < 0 ? 0 : rows;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == count - 1 ? 0 : theme.spacingSkeletonLiMarginBottom,
            ),
            child: FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: i == count - 1 && count > 1 ? 0.6 : 1,
              child: _SkeletonFill(
                height: theme.heightSkeletonLi,
                borderRadius: BorderRadius.circular(theme.radiusSkeletonLi),
              ),
            ),
          ),
      ],
    );
  }
}

/// 把 active 的扫光动画共享给 placeholder 里的所有骨架形状（对应上游
/// `.semi-skeleton-active` 后代选择器）。
class _SkeletonShimmerScope extends InheritedWidget {
  const _SkeletonShimmerScope({required this.animation, required super.child});

  final Animation<double> animation;

  static _SkeletonShimmerScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SkeletonShimmerScope>();

  @override
  bool updateShouldNotify(_SkeletonShimmerScope oldWidget) =>
      animation != oldWidget.animation;
}

/// 静态底色 / active 三段扫光渐变。
class _SkeletonFill extends StatelessWidget {
  const _SkeletonFill({this.width, this.height, this.borderRadius});

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = SemiSkeletonTheme.resolve(context);
    final shimmer = _SkeletonShimmerScope.maybeOf(context);
    Widget paint(double t) => DecoratedBox(
      decoration: BoxDecoration(
        color: shimmer == null ? theme.colorSkeletonDefaultBgDefault : null,
        gradient: shimmer == null ? null : _shimmerGradient(theme, t),
        borderRadius: borderRadius,
      ),
    );
    final content = shimmer == null
        ? paint(0)
        : AnimatedBuilder(
            animation: shimmer.animation,
            builder: (context, _) => paint(shimmer.animation.value),
          );
    return SizedBox(width: width, height: height, child: content);
  }
}

/// CSS：`background-size: 400% 100%` + `background-position: 100% 50%` →
/// `0 50%`。4 倍盒宽的三段渐变整体右移 3 倍盒宽；begin/end 用盒宽坐标
/// （-1..1 对应 0..W），渐变两端各溢出盒子，可见窗口按 CSS 几何滑动。
LinearGradient _shimmerGradient(SemiResolvedSkeletonThemeData theme, double t) {
  final offset = -3 * (1 - t);
  return LinearGradient(
    begin: Alignment(2 * offset - 1, 0),
    end: Alignment(2 * offset + 7, 0),
    colors: [
      theme.colorSkeletonDefaultBgDefault,
      theme.colorSkeletonLoadingGradientBgActive,
      theme.colorSkeletonDefaultBgDefault,
    ],
    stops: const [0.25, 0.44, 0.88],
  );
}
