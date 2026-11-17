// SemiInsetShadow — CSS inset box-shadow 专用画师（token_types.dart
// 「Inset shadows require a dedicated painter」所指的那条路）。
//
// CSS `box-shadow: inset 0 0 0 Npx c`（零偏移零模糊）= 贴 padding-box 边缘的
// Npx 内环——精确等价于外圈 RRect 与 deflate(N) RRect 的差集填色。Flutter 的
// BoxShadow 只能画 drop、无 inset 对应物（SemiShadowLayer.toBoxShadow 拒绝
// 转换）。本画师挂在已装饰盒的**最外层子节点**（装饰背景之上、内容之下），
// 纯绘制不参与布局——CSS inset 阴影零布局影响（Border 翻译会吃 1px 内容
// 空间，故不采用）。drop 层照旧走 BoxDecoration.boxShadow
// （SemiShadows.toDropBoxShadows）。
//
// ★显式合同：仅支持零偏移零模糊层（全 token 集仅 `inset 0 0 0 1px` 一种
// 形态）；带 blur/offset 的 inset 层构造即抛 UnsupportedError——不静默
// 近似、不静默丢弃（toBoxShadows 拒绝 inset 的同款口径）。
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../tokens/token_types.dart';

/// CSS inset box-shadow 渲染层：消费 [SemiShadows] 的 inset 层并精确绘制
/// 内环；无 inset 层时直通 [child]（零开销）。
class SemiInsetShadow extends StatelessWidget {
  const SemiInsetShadow({
    super.key,
    required this.shadows,
    required this.borderRadius,
    this.borderWidth = 0,
    required this.child,
  });

  /// 阴影 token（仅消费 inset 层——drop 层由 BoxDecoration.boxShadow 承接，
  /// 见 `SemiShadows.toDropBoxShadows`）。
  final SemiShadows shadows;

  /// 装饰盒圆角（内环随圆角收敛；CSS padding-box 圆角口径）。
  final BorderRadiusGeometry borderRadius;

  /// 装饰盒边框宽（CSS inset 阴影以 padding-box 为基准——内环画在边框
  /// 内侧；无边框传 0）。
  final double borderWidth;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final layers = [
      for (final layer in shadows.layers)
        if (layer.inset) layer,
    ];
    if (layers.isEmpty) return child;
    return CustomPaint(
      painter: _InsetShadowPainter(
        layers: layers,
        borderRadius: borderRadius.resolve(Directionality.of(context)),
        borderWidth: borderWidth,
      ),
      child: child,
    );
  }
}

class _InsetShadowPainter extends CustomPainter {
  _InsetShadowPainter({
    required this.layers,
    required this.borderRadius,
    required this.borderWidth,
  }) {
    // 显式合同：零偏移零模糊层才可精确表达（spread 层 = 内环带宽）；
    // blur/offset 需要通用内阴影管线，当前 token 集不存在——构造即抛。
    for (final layer in layers) {
      if (layer.x != 0 || layer.y != 0 || layer.blur != 0) {
        throw UnsupportedError(
          'Inset shadow with blur/offset cannot be painted exactly; '
          'only zero-offset/zero-blur layers are supported',
        );
      }
    }
  }

  final List<SemiShadowLayer> layers;
  final BorderRadius borderRadius;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // CSS box-shadow 层序：首层在上——逆序绘制。
    for (final layer in layers.reversed) {
      final spread = layer.spread;
      if (spread <= 0) continue;
      // padding-box（borderWidth 内收，圆角随 deflate 收敛）。
      final maxInset = math.min(size.width, size.height) / 2;
      final paddingBox = borderRadius
          .toRRect(Offset.zero & size)
          .deflate(math.min(math.max(borderWidth, 0.0), maxInset));
      final inner = paddingBox.deflate(
        math.min(math.max(spread, 0.0), maxInset),
      );
      final band = Path.combine(
        PathOperation.difference,
        Path()..addRRect(paddingBox),
        Path()..addRRect(inner),
      );
      canvas.drawPath(band, Paint()..color = layer.color);
    }
  }

  @override
  bool shouldRepaint(_InsetShadowPainter oldDelegate) =>
      !listEquals(oldDelegate.layers, layers) ||
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.borderWidth != borderWidth;
}
