import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/semi_progress_theme.dart';
import '../theme/semi_progress_theme_data.dart';

enum SemiProgressType { line, circle }

enum SemiProgressDirection { horizontal, vertical }

enum SemiProgressSize { normal, small, large }

enum SemiProgressCircleInfoLayout { overflow, scaleDown }

enum SemiProgressStrokeLinecap { round, square }

@immutable
class SemiProgressColorStop {
  const SemiProgressColorStop(this.percent, this.color);
  final double percent;
  final Color color;
}

/// A solid color or sorted, defensively copied threshold colors (not a shader).
@immutable
class SemiProgressStroke {
  const SemiProgressStroke.color(Color this.color) : stops = const [];
  factory SemiProgressStroke.stops(List<SemiProgressColorStop> stops) {
    final copy = List<SemiProgressColorStop>.of(stops);
    for (final stop in copy) {
      if (!stop.percent.isFinite) {
        throw ArgumentError.value(
          stop.percent,
          'stop.percent',
          'must be finite',
        );
      }
    }
    copy.sort((a, b) => a.percent.compareTo(b.percent));
    return SemiProgressStroke._(List.unmodifiable(copy));
  }
  const SemiProgressStroke._(this.stops) : color = null;
  final Color? color;
  final List<SemiProgressColorStop> stops;

  Color resolve(double percent, Color fallback, {bool gradient = false}) {
    if (!percent.isFinite) {
      throw ArgumentError.value(percent, 'percent', 'must be finite');
    }
    if (color != null) return color!;
    if (stops.isEmpty || percent < stops.first.percent) return fallback;
    var previous = stops.first;
    for (final stop in stops.skip(1)) {
      if (percent < stop.percent) {
        return gradient
            ? Color.lerp(
                previous.color,
                stop.color,
                (percent - previous.percent) /
                    (stop.percent - previous.percent),
              )!
            : previous.color;
      }
      previous = stop;
    }
    return previous.color;
  }
}

/// Material-free Semi progress. [motion] affects only the displayed number.
class SemiProgress extends StatefulWidget {
  const SemiProgress({
    super.key,
    this.type = SemiProgressType.line,
    this.direction = SemiProgressDirection.horizontal,
    this.size = SemiProgressSize.normal,
    this.percent = 0,
    this.showInfo = false,
    this.circleInfoLayout = SemiProgressCircleInfoLayout.overflow,
    this.format,
    this.motion = true,
    this.indeterminate = false,
    this.stroke,
    this.strokeGradient = false,
    this.orbitStroke,
    this.strokeWidth = 4,
    this.strokeLinecap = SemiProgressStrokeLinecap.round,
    this.width,
    this.height,
    this.textStyle,
    this.semanticsLabel,
    this.semanticsValue,
  });
  final SemiProgressType type;
  final SemiProgressDirection direction;
  final SemiProgressSize size;

  /// Circle info only: preserve natural size or shrink to the stroke inset.
  /// Does not change circle dimensions or the formatter's line breaks.
  final SemiProgressCircleInfoLayout circleInfoLayout;
  final double percent;
  final bool showInfo, motion, indeterminate, strokeGradient;
  final Widget Function(double)? format;
  final SemiProgressStroke? stroke;
  final Color? orbitStroke;

  /// Circle only; line thickness comes from the theme and [size].
  final double strokeWidth;
  final SemiProgressStrokeLinecap strokeLinecap;
  final double? width, height;
  final TextStyle? textStyle;
  final String? semanticsLabel, semanticsValue;
  @override
  State<SemiProgress> createState() => _SemiProgressState();
}

class _SemiProgressState extends State<SemiProgress>
    with TickerProviderStateMixin {
  late final AnimationController _number = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final AnimationController _geometry = AnimationController(vsync: this);
  late final AnimationController _loop = AnimationController(vsync: this);
  late double _numberFrom, _numberTo, _geometryFrom, _geometryTo;
  SemiResolvedProgressThemeData? _theme;
  bool _active = false;

  double get _numeric =>
      _numberFrom + (_numberTo - _numberFrom) * _number.value;
  double get _fraction =>
      _geometryFrom +
      (_geometryTo - _geometryFrom) *
          (_theme?.transitionCurve.transform(_geometry.value) ??
              _geometry.value);
  double _clamp(double value) => value.clamp(0, 100).toDouble();

  void _validate() {
    if (!widget.percent.isFinite) {
      throw ArgumentError.value(widget.percent, 'percent', 'must be finite');
    }
    for (final entry in <String, double?>{
      'width': widget.width,
      'height': widget.height,
      'strokeWidth': widget.strokeWidth,
    }.entries) {
      if (entry.value != null && (!entry.value!.isFinite || entry.value! < 0)) {
        throw ArgumentError.value(
          entry.value,
          entry.key,
          'must be finite and nonnegative',
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _validate();
    _numberFrom = _numberTo = widget.percent;
    _geometryFrom = _geometryTo = _clamp(widget.percent);
    _number.value = _geometry.value = 1;
  }

  void _settle() {
    _number.stop();
    _geometry.stop();
    _loop.stop();
    _numberFrom = _numberTo = widget.percent;
    _geometryFrom = _geometryTo = _clamp(widget.percent);
    _number.value = _geometry.value = 1;
    _loop.value = 0;
  }

  @override
  void didUpdateWidget(SemiProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    _validate();
    if (oldWidget.percent != widget.percent) {
      _number.stop();
      // Upstream deliberately starts replacement numeric motion at the old prop.
      _numberFrom = oldWidget.percent;
      _numberTo = widget.percent;
      if (_active && widget.motion && !widget.indeterminate) {
        _number.forward(from: 0);
      } else {
        _number.value = 1;
      }
      final current = _fraction;
      _geometry.stop();
      _geometryFrom = current;
      _geometryTo = _clamp(widget.percent);
      if (_active &&
          !widget.indeterminate &&
          _geometry.duration != Duration.zero) {
        _geometry.forward(from: 0);
      } else {
        _geometry.value = 1;
      }
    }
    if (oldWidget.indeterminate && !widget.indeterminate) {
      _numberFrom = _numberTo = widget.percent;
      _geometryFrom = _geometryTo = _clamp(widget.percent);
      _number.value = _geometry.value = 1;
    }
    if (!widget.motion) {
      _number.stop();
      _number.value = 1;
    }
  }

  void _sync(SemiResolvedProgressThemeData theme) {
    _active =
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context);
    final changed = _geometry.duration != theme.transitionDuration;
    final current = _fraction;
    _theme = theme;
    _geometry.duration = theme.transitionDuration;
    if (!_active) {
      _settle();
      return;
    }
    if (theme.transitionDuration == Duration.zero) {
      _geometry.stop();
      _geometry.value = 1;
    } else if (changed && _geometry.isAnimating) {
      _geometryFrom = current;
      _geometry.forward(from: 0);
    }
    if (widget.indeterminate) {
      _number.stop();
      _geometry.stop();
      final duration = Duration(
        milliseconds: widget.type == SemiProgressType.circle ? 1200 : 1600,
      );
      if (_loop.duration != duration || !_loop.isAnimating) {
        _loop.duration = duration;
        _loop.repeat();
      }
    } else {
      _loop.stop();
      _loop.value = 0;
    }
  }

  @override
  void dispose() {
    _number.dispose();
    _geometry.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _validate();
    final theme = SemiProgressTheme.resolve(context);
    _sync(theme);
    return AnimatedBuilder(
      animation: Listenable.merge([_number, _geometry, _loop]),
      builder: (context, _) {
        final numeric = _clamp(
          _number.isAnimating ? _numeric.truncateToDouble() : _numberTo,
        );
        final circle = widget.type == SemiProgressType.circle;
        final vertical =
            !circle && widget.direction == SemiProgressDirection.vertical;
        final rtl = Directionality.of(context) == TextDirection.rtl;
        final color =
            widget.stroke?.resolve(
              widget.percent,
              theme.strokeColor,
              gradient: widget.strokeGradient,
            ) ??
            theme.strokeColor;
        Widget? info;
        if (widget.showInfo &&
            !widget.indeterminate &&
            !(circle && widget.size == SemiProgressSize.small)) {
          // --semi-color-mode-minor-text is absent from global tokens. Preserve
          // the host's explicit color, otherwise fall back to global text-0.
          final host = DefaultTextStyle.of(context).style;
          final style = circle
              ? TextStyle(
                  color:
                      SemiProgressTheme.of(context).circleTextColor ??
                      host.color ??
                      theme.circleTextColor,
                )
              : TextStyle(
                  color: theme.lineTextColor,
                  fontWeight: theme.lineTextFontWeight,
                );
          info = ExcludeSemantics(
            child: DefaultTextStyle.merge(
              style: style.merge(widget.textStyle),
              textAlign: circle ? TextAlign.center : null,
              child:
                  widget.format?.call(numeric) ??
                  Text(
                    '${numeric == numeric.roundToDouble() ? numeric.toInt() : numeric}%',
                    // Only the built-in percentage is inherently single-line.
                    maxLines: circle ? 1 : null,
                    softWrap: circle ? false : null,
                  ),
            ),
          );
        }
        Widget paint(double width, double height) => CustomPaint(
          size: Size(width, height),
          painter: SemiProgressPainter(
            circle: circle,
            vertical: vertical,
            rtl: rtl,
            fraction: _fraction / 100,
            phase: _loop.value,
            indeterminate: widget.indeterminate,
            color: color,
            orbitColor: widget.orbitStroke ?? theme.color,
            strokeWidth: widget.strokeWidth,
            cap: widget.strokeLinecap == SemiProgressStrokeLinecap.round
                ? StrokeCap.round
                : StrokeCap.square,
            trackRadius: theme.trackRadius,
            innerRadius: theme.innerRadius,
          ),
        );
        Widget content;
        if (circle) {
          final width =
              widget.width ??
              (widget.size == SemiProgressSize.normal ? 72.0 : 24.0);
          content = SizedBox(
            width: width,
            height: width,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned.fill(child: paint(width, width)),
                if (info != null)
                  Positioned.fill(
                    // Info stays centered; overflow preserves its natural size.
                    // Painting may overflow; hit testing still requires the
                    // parent's bounds.
                    child:
                        widget.circleInfoLayout ==
                            SemiProgressCircleInfoLayout.scaleDown
                        ? LayoutBuilder(
                            builder: (context, constraints) {
                              final inset = math.min(
                                widget.strokeWidth,
                                constraints.biggest.shortestSide / 2,
                              );
                              return Padding(
                                padding: EdgeInsets.all(inset),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.center,
                                  child: info,
                                ),
                              );
                            },
                          )
                        : OverflowBox(
                            minWidth: 0,
                            maxWidth: double.infinity,
                            minHeight: 0,
                            maxHeight: double.infinity,
                            child: info,
                          ),
                  ),
              ],
            ),
          );
        } else {
          final thickness = vertical
              ? (widget.size == SemiProgressSize.large
                    ? theme.verticalLargeWidth
                    : theme.verticalWidth)
              : (widget.size == SemiProgressSize.large
                    ? theme.horizontalLargeHeight
                    : theme.horizontalHeight);
          final margin = vertical
              ? EdgeInsets.symmetric(horizontal: theme.verticalMarginX)
              : EdgeInsets.symmetric(vertical: theme.horizontalMarginY);
          content = SizedBox(
            width: widget.width,
            height: widget.height,
            child: Padding(
              padding: margin,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (vertical
                      ? !constraints.hasBoundedHeight
                      : !constraints.hasBoundedWidth) {
                    throw FlutterError(
                      'SemiProgress ${vertical ? "vertical requires an explicit height or finite height constraint" : "horizontal requires an explicit width or finite width constraint"}.',
                    );
                  }
                  final track = vertical
                      ? Expanded(
                          child: SizedBox(
                            width: thickness,
                            child: LayoutBuilder(
                              builder: (_, c) => paint(thickness, c.maxHeight),
                            ),
                          ),
                        )
                      : Expanded(
                          child: SizedBox(
                            height: thickness,
                            child: LayoutBuilder(
                              builder: (_, c) => paint(c.maxWidth, thickness),
                            ),
                          ),
                        );
                  if (vertical) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        track,
                        if (info != null)
                          Padding(
                            padding: EdgeInsets.only(
                              top: theme.verticalTextMarginTop,
                            ),
                            child: info,
                          ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      track,
                      if (info != null)
                        Padding(
                          padding: EdgeInsets.only(
                            left: rtl ? 0 : theme.lineTextMarginLeft,
                            right: rtl ? theme.lineTextMarginRight : 0,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: theme.lineTextMinWidth,
                            ),
                            child: info,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          );
        }
        return Semantics(
          container: true,
          label: widget.semanticsLabel,
          value: widget.indeterminate
              ? null
              : widget.semanticsValue ?? '${_clamp(widget.percent)}%',
          child: content,
        );
      },
    );
  }
}

/// Geometry is exposed for deterministic paint tests; no Material dependency.
class SemiProgressPainter extends CustomPainter {
  const SemiProgressPainter({
    required this.circle,
    required this.vertical,
    required this.rtl,
    required this.fraction,
    required this.phase,
    required this.indeterminate,
    required this.color,
    required this.orbitColor,
    required this.strokeWidth,
    required this.cap,
    required this.trackRadius,
    required this.innerRadius,
  });
  final bool circle, vertical, rtl, indeterminate;
  final double fraction, phase, strokeWidth, trackRadius, innerRadius;
  final Color color, orbitColor;
  final StrokeCap cap;
  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    if (circle) {
      final stroke = math.min(strokeWidth, math.min(size.width, size.height));
      if (stroke == 0) return;
      final rect = (Offset.zero & size).deflate(stroke / 2);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = cap
        ..color = orbitColor;
      canvas.drawOval(rect, paint);
      if (!indeterminate && fraction <= 0) return;
      paint.color = color;
      if (!indeterminate && fraction >= 1) {
        canvas.drawOval(rect, paint);
        return;
      }
      canvas.drawArc(
        rect,
        indeterminate ? phase * 2 * math.pi : -math.pi / 2,
        (indeterminate ? .3 : fraction) * 2 * math.pi,
        false,
        paint,
      );
      return;
    }
    final bounds = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds, Radius.circular(trackRadius)),
      Paint()..color = orbitColor,
    );
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(bounds, Radius.circular(trackRadius)),
    );
    final extent = vertical ? size.height : size.width;
    final length = extent * (indeterminate ? .35 : fraction);
    var start = 0.0;
    if (indeterminate) {
      final t = Curves.easeInOut.transform((phase / .55).clamp(0.0, 1.0));
      start = length * (-1.2 + 4.2 * t);
    }
    if (!vertical && rtl) start = extent - start - length;
    final rect = vertical
        ? Rect.fromLTWH(0, start, size.width, length)
        : Rect.fromLTWH(start, 0, length, size.height);
    if (length > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(innerRadius)),
        Paint()..color = color,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(SemiProgressPainter oldDelegate) =>
      circle != oldDelegate.circle ||
      vertical != oldDelegate.vertical ||
      rtl != oldDelegate.rtl ||
      fraction != oldDelegate.fraction ||
      phase != oldDelegate.phase ||
      indeterminate != oldDelegate.indeterminate ||
      color != oldDelegate.color ||
      orbitColor != oldDelegate.orbitColor ||
      strokeWidth != oldDelegate.strokeWidth ||
      cap != oldDelegate.cap ||
      trackRadius != oldDelegate.trackRadius ||
      innerRadius != oldDelegate.innerRadius;
}
