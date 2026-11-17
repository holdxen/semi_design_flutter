import 'dart:math' as math;
import 'dart:ui' show PathMetric, Tangent;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../theme/semi_theme.dart';

/// A color stop expressed in the same 0–100 range as BorderBeam.
@immutable
class SemiBorderBeamGradientStop {
  const SemiBorderBeamGradientStop(this.percent, this.color);

  final double percent;
  final Color color;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiBorderBeamGradientStop &&
          percent == other.percent &&
          color == other.color;

  @override
  int get hashCode => Object.hash(percent, color);
}

/// BorderBeam color input: either a solid color or a list of gradient stops.
@immutable
class SemiBorderBeamColor {
  const SemiBorderBeamColor.solid(this.color) : stops = null;

  const SemiBorderBeamColor.gradient(this.stops) : color = null;

  final Color? color;
  final List<SemiBorderBeamGradientStop>? stops;

  bool get isGradient => stops != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiBorderBeamColor &&
          color == other.color &&
          listEquals(stops, other.stops);

  @override
  int get hashCode => Object.hash(color, Object.hashAll(stops ?? const []));
}

/// Per-beam overrides. Unspecified values inherit from [SemiBorderBeam].
@immutable
class SemiBorderBeamItem {
  const SemiBorderBeamItem({
    this.color,
    this.lineWidth,
    this.outset,
    this.size,
  });

  final SemiBorderBeamColor? color;
  final double? lineWidth;
  final double? outset;
  final double? size;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiBorderBeamItem &&
          color == other.color &&
          lineWidth == other.lineWidth &&
          outset == other.outset &&
          size == other.size;

  @override
  int get hashCode => Object.hash(color, lineWidth, outset, size);
}

/// An animated gradient beam travelling around a child's rounded rectangle.
///
/// The child owns its layout and border. The beam is a non-interactive paint
/// layer drawn above it, so it does not consume any layout or hit-test space.
/// Unlike the DOM implementation, Flutter cannot inspect a child's CSS border
/// or radius; pass [borderRadius] and [outset] explicitly when they differ from
/// the defaults.
class SemiBorderBeam extends StatefulWidget {
  const SemiBorderBeam({
    super.key,
    required this.child,
    this.color,
    this.count,
    this.duration = const Duration(seconds: 6),
    this.items,
    this.lineWidth = 1,
    this.outset = 0,
    this.size = 100,
    this.borderRadius = BorderRadius.zero,
    this.semanticsLabel,
  });

  final Widget child;
  final SemiBorderBeamColor? color;
  final num? count;
  final Duration? duration;
  final List<SemiBorderBeamItem>? items;
  final double? lineWidth;
  final double? outset;
  final double? size;
  final BorderRadiusGeometry borderRadius;
  final String? semanticsLabel;

  @override
  State<SemiBorderBeam> createState() => _SemiBorderBeamState();
}

class _SemiBorderBeamState extends State<SemiBorderBeam>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  bool _active = false;
  Duration _mergedDuration = const Duration(seconds: 6);

  int get _count {
    final items = widget.items;
    if (items != null) return items.length;
    final count = widget.count;
    return count != null && count.isFinite && count >= 1 ? count.floor() : 1;
  }

  Duration get _duration {
    final duration = widget.duration;
    return duration != null && duration > Duration.zero
        ? duration
        : const Duration(seconds: 6);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(SemiBorderBeam oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    _mergedDuration = _duration;
    _active =
        _count > 0 &&
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context);
    _controller.duration = _mergedDuration;
    if (_active) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
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
    _sync();
    final colors =
        widget.color ??
        SemiBorderBeamColor.gradient([
          SemiBorderBeamGradientStop(
            0,
            SemiTheme.of(context).colors.colorPrimary,
          ),
          SemiBorderBeamGradientStop(
            70,
            SemiTheme.of(context).colors.colorPrimaryHover,
          ),
        ]);
    if (!_active) {
      return Semantics(label: widget.semanticsLabel, child: widget.child);
    }

    final radius = widget.borderRadius.resolve(Directionality.of(context));

    final animated = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => CustomPaint(
        foregroundPainter: _buildPainter(
          colors: colors,
          radius: radius,
          phase: _controller.value,
        ),
        child: child,
      ),
      child: widget.child,
    );
    return Semantics(label: widget.semanticsLabel, child: animated);
  }

  SemiBorderBeamPainter _buildPainter({
    required SemiBorderBeamColor colors,
    required BorderRadius radius,
    required double phase,
  }) {
    return SemiBorderBeamPainter(
      count: _count,
      phase: phase,
      borderRadius: radius,
      color: colors,
      lineWidth: widget.lineWidth ?? 1,
      outset: widget.outset ?? 0,
      size: widget.size ?? 100,
      items: widget.items,
    );
  }
}

/// Geometry and paint implementation for [SemiBorderBeam].
///
/// It is public so callers and tests can use the path painter without relying
/// on the widget's animation lifecycle.
class SemiBorderBeamPainter extends CustomPainter {
  const SemiBorderBeamPainter({
    required this.count,
    required this.phase,
    required this.borderRadius,
    required this.color,
    required this.lineWidth,
    required this.outset,
    required this.size,
    this.items,
  });

  final int count;
  final double phase;
  final BorderRadius borderRadius;
  final SemiBorderBeamColor color;
  final double lineWidth;
  final double outset;
  final double size;
  final List<SemiBorderBeamItem>? items;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    if (canvasSize.isEmpty || count <= 0) return;
    final path = Path()
      ..addRRect(
        borderRadius.toRRect(Offset.zero & canvasSize).inflate(outset),
      );
    final metrics = path.computeMetrics().toList(growable: false);
    if (metrics.isEmpty) return;
    final totalLength = metrics.fold<double>(
      0,
      (sum, metric) => sum + metric.length,
    );
    if (totalLength <= 0) return;

    for (var index = 0; index < count; index++) {
      final item = items != null && index < items!.length
          ? items![index]
          : const SemiBorderBeamItem();
      final itemColor = item.color ?? color;
      final width = math.max(0.0, item.lineWidth ?? lineWidth).toDouble();
      final requestedLength = math.max(0.0, item.size ?? size).toDouble();
      final itemOutset = item.outset ?? outset;
      if (width == 0 || requestedLength == 0) continue;
      final itemPath = Path()
        ..addRRect(
          borderRadius.toRRect(Offset.zero & canvasSize).inflate(itemOutset),
        );
      final itemMetrics = itemPath.computeMetrics().toList(growable: false);
      final itemLength = itemMetrics.fold<double>(
        0,
        (sum, metric) => sum + metric.length,
      );
      if (itemMetrics.isEmpty || itemLength <= 0) continue;
      final length = math.min(requestedLength, itemLength).toDouble();
      _paintBeam(
        canvas,
        itemMetrics,
        itemLength,
        phase: (phase + index / count) % 1,
        length: math.min(length, itemLength).toDouble(),
        width: width,
        color: itemColor,
      );
    }
  }

  void _paintBeam(
    Canvas canvas,
    List<PathMetric> metrics,
    double totalLength, {
    required double phase,
    required double length,
    required double width,
    required SemiBorderBeamColor color,
  }) {
    final stops = _normalizedStops(color);
    final samples = math.max(24, (length / 3).ceil()).toInt();
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    for (var i = 0; i < samples; i++) {
      final t0 = i / samples;
      final t1 = (i + 1) / samples;
      final startDistance = phase * totalLength + length * t0;
      final endDistance = phase * totalLength + length * t1;
      final first = _tangentAt(metrics, totalLength, startDistance);
      final second = _tangentAt(metrics, totalLength, endDistance);
      if (first == null || second == null) continue;
      // A wrapped segment has no straight-line connection across the path's
      // start/end seam; the next sample starts from the correct path point.
      if (endDistance % totalLength < startDistance % totalLength) continue;
      paint.color = _colorAt(stops, t0);
      canvas.drawLine(first.position, second.position, paint);
    }
  }

  List<_BeamStop> _normalizedStops(SemiBorderBeamColor value) {
    final input = value.stops;
    if (input == null) {
      final solid = value.color ?? const Color(0xff1769ff);
      return [
        _BeamStop(0, solid),
        _BeamStop(.7, solid),
        const _BeamStop(1, Color(0x001769ff)),
      ];
    }
    if (input.isEmpty) return const [_BeamStop(1, Color(0x00000000))];
    final sorted = [...input]..sort((a, b) => a.percent.compareTo(b.percent));
    final stops = [
      for (final stop in sorted)
        _BeamStop((stop.percent.clamp(0, 100) / 100) * .7, stop.color),
    ];
    if (stops.last.position < .7) {
      stops.add(_BeamStop(.7, stops.last.color));
    }
    stops.add(_BeamStop(1, stops.last.color.withAlpha(0)));
    return stops;
  }

  Color _colorAt(List<_BeamStop> stops, double position) {
    if (position <= stops.first.position) return stops.first.color;
    for (var i = 1; i < stops.length; i++) {
      final next = stops[i];
      if (position <= next.position) {
        final previous = stops[i - 1];
        final span = next.position - previous.position;
        return Color.lerp(
          previous.color,
          next.color,
          span == 0 ? 1 : (position - previous.position) / span,
        )!;
      }
    }
    return stops.last.color;
  }

  Tangent? _tangentAt(
    List<PathMetric> metrics,
    double totalLength,
    double distance,
  ) {
    var remaining = distance % totalLength;
    for (final metric in metrics) {
      if (remaining <= metric.length) {
        return metric.getTangentForOffset(remaining);
      }
      remaining -= metric.length;
    }
    return metrics.last.getTangentForOffset(metrics.last.length);
  }

  @override
  bool shouldRepaint(covariant SemiBorderBeamPainter oldDelegate) =>
      count != oldDelegate.count ||
      phase != oldDelegate.phase ||
      borderRadius != oldDelegate.borderRadius ||
      color != oldDelegate.color ||
      lineWidth != oldDelegate.lineWidth ||
      outset != oldDelegate.outset ||
      size != oldDelegate.size ||
      !listEquals(items, oldDelegate.items);
}

class _BeamStop {
  const _BeamStop(this.position, this.color);
  final double position;
  final Color color;
}
