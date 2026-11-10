import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/semi_spin_theme.dart';
import 'icon/semi_icon.dart';
import 'spin_svg.dart';

enum SemiSpinSize { small, middle, large }

/// Semi loading indicator. Pointer blocking does not change keyboard focus.
class SemiSpin extends StatefulWidget {
  const SemiSpin({
    super.key,
    this.size = SemiSpinSize.middle,
    this.spinning = true,
    this.delay = Duration.zero,
    this.indicator,
    this.tip,
    this.child,
    this.semanticsLabel,
  });
  final SemiSpinSize size;
  final bool spinning;
  final Duration delay;
  final Widget? indicator, tip, child;
  final String? semanticsLabel;
  @override
  State<SemiSpin> createState() => _SemiSpinState();
}

class _SemiSpinState extends State<SemiSpin>
    with SingleTickerProviderStateMixin {
  late bool _loading;
  Timer? _timer;
  late final AnimationController _rotation = AnimationController(vsync: this);
  @override
  void initState() {
    super.initState();
    _loading = widget.spinning && widget.delay == Duration.zero;
    _schedule();
  }

  void _schedule() {
    if (widget.delay.isNegative) {
      throw ArgumentError.value(widget.delay, 'delay', 'must be nonnegative');
    }
    _timer?.cancel();
    _timer = null;
    if (!widget.spinning) {
      _loading = false;
    } else if (widget.delay == Duration.zero) {
      _loading = true;
    } else if (!_loading) {
      _timer = Timer(widget.delay, () {
        _timer = null;
        if (mounted) setState(() => _loading = widget.spinning);
      });
    }
  }

  @override
  void didUpdateWidget(SemiSpin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spinning != widget.spinning ||
        oldWidget.delay != widget.delay) {
      _schedule();
    }
  }

  void _sync(Duration duration) {
    final changed = _rotation.duration != duration;
    final active =
        _loading &&
        duration > Duration.zero &&
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context);
    if (!active) {
      _rotation.stop();
      _rotation.value = 0;
    } else if (changed || !_rotation.isAnimating) {
      _rotation.duration = duration;
      _rotation.repeat();
    }
    _rotation.duration = duration;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = SemiSpinTheme.resolve(context);
    final size = switch (widget.size) {
      SemiSpinSize.small => theme.smallSize,
      SemiSpinSize.middle => theme.middleSize,
      SemiSpinSize.large => theme.largeSize,
    };
    _sync(
      widget.indicator == null
          ? theme.rotationDuration
          : theme.customIndicatorRotationDuration,
    );
    final indicator =
        widget.indicator ??
        (size == 0
            ? const SizedBox.shrink()
            : SemiIcon.svg(
                semiSpinSvg,
                customSize: size,
                color: theme.color,
                excludeFromSemantics: true,
              ));
    final overlay = Semantics(
      liveRegion: widget.semanticsLabel != null,
      label: widget.semanticsLabel,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: theme.color),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotationTransition(turns: _rotation, child: indicator),
            if (widget.tip != null) widget.tip!,
          ],
        ),
      ),
    );
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.loose,
      clipBehavior: Clip.none,
      children: [
        if (widget.child != null)
          Opacity(
            opacity: _loading ? theme.childrenOpacity : 1,
            child: widget.child,
          )
        else
          SizedBox(width: size, height: size),
        if (_loading)
          Positioned.fill(
            child: OverflowBox(
              alignment: Alignment.center,
              minWidth: 0,
              minHeight: 0,
              maxHeight: double.infinity,
              child: overlay,
            ),
          ),
        if (_loading && widget.child != null)
          const Positioned.fill(
            child: Listener(behavior: HitTestBehavior.opaque),
          ),
      ],
    );
  }
}
