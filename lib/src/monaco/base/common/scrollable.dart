// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/scrollable.ts
// Translated 1:1 from TypeScript.
// Adaptations (documented inline):
//   - `const enum` -> class with static const int.
//   - JS `number` -> Dart `num`; `value | 0` -> `truncate()`.
//   - `interface` -> `abstract class`; `IAnimation` -> typedef.
//   - `_register` -> `register` (public in the Dart port of lifecycle.ts).
// ---------------------------------------------------------------------------

import 'event.dart' as event;
import 'lifecycle.dart' as lifecycle;

/// 1:1: `export const enum ScrollbarVisibility`
class ScrollbarVisibility {
  const ScrollbarVisibility._();

  static const int Auto = 1;
  static const int Hidden = 2;
  static const int Visible = 3;
}

/// 1:1: `export interface ScrollEvent`
class ScrollEvent {
  final bool inSmoothScrolling;

  final num oldWidth;
  final num oldScrollWidth;
  final num oldScrollLeft;

  final num width;
  final num scrollWidth;
  final num scrollLeft;

  final num oldHeight;
  final num oldScrollHeight;
  final num oldScrollTop;

  final num height;
  final num scrollHeight;
  final num scrollTop;

  final bool widthChanged;
  final bool scrollWidthChanged;
  final bool scrollLeftChanged;

  final bool heightChanged;
  final bool scrollHeightChanged;
  final bool scrollTopChanged;

  ScrollEvent({
    required this.inSmoothScrolling,
    required this.oldWidth,
    required this.oldScrollWidth,
    required this.oldScrollLeft,
    required this.width,
    required this.scrollWidth,
    required this.scrollLeft,
    required this.oldHeight,
    required this.oldScrollHeight,
    required this.oldScrollTop,
    required this.height,
    required this.scrollHeight,
    required this.scrollTop,
    required this.widthChanged,
    required this.scrollWidthChanged,
    required this.scrollLeftChanged,
    required this.heightChanged,
    required this.scrollHeightChanged,
    required this.scrollTopChanged,
  });
}

/// 1:1: `export interface IScrollDimensions`
abstract class IScrollDimensions {
  num get width;
  num get scrollWidth;
  num get height;
  num get scrollHeight;
}

/// 1:1: `export interface INewScrollDimensions`
class NewScrollDimensions {
  final num? width;
  final num? scrollWidth;
  final num? height;
  final num? scrollHeight;

  NewScrollDimensions({
    this.width,
    this.scrollWidth,
    this.height,
    this.scrollHeight,
  });
}

/// 1:1: `export interface IScrollPosition`
abstract class IScrollPosition {
  num get scrollLeft;
  num get scrollTop;
}

/// 1:1: `export interface ISmoothScrollPosition`
abstract class ISmoothScrollPosition implements IScrollPosition {
  num get width;
  num get height;
}

/// 1:1: `export interface INewScrollPosition`
class NewScrollPosition {
  num? scrollLeft;
  num? scrollTop;

  NewScrollPosition({this.scrollLeft, this.scrollTop});
}

/// 1:1: `export interface IScrollableOptions`
class ScrollableOptions {
  final bool forceIntegerValues;
  final num smoothScrollDuration;
  final lifecycle.IDisposable Function(void Function() callback)
      scheduleAtNextAnimationFrame;

  ScrollableOptions({
    required this.forceIntegerValues,
    required this.smoothScrollDuration,
    required this.scheduleAtNextAnimationFrame,
  });
}

num _coerce(num value, bool forceIntegerValues) =>
    forceIntegerValues ? value.truncate() : value;

num _validateSize(num value, bool forceIntegerValues) {
  final num v = _coerce(value, forceIntegerValues);
  return v < 0 ? 0 : v;
}

num _validateOffset(
    num value, bool forceIntegerValues, num size, num scrollSize) {
  num v = _coerce(value, forceIntegerValues);
  if (v + size > scrollSize) {
    v = scrollSize - size;
  }
  if (v < 0) {
    v = 0;
  }
  return v;
}

/// 1:1: `export class ScrollState implements IScrollDimensions, IScrollPosition`
class ScrollState implements ISmoothScrollPosition, IScrollDimensions {
  final bool _forceIntegerValues;

  /// Before validation.
  final num rawScrollLeft;
  final num rawScrollTop;

  final num _width;
  final num _scrollWidth;
  final num _scrollLeft;
  final num _height;
  final num _scrollHeight;
  final num _scrollTop;

  ScrollState(
    this._forceIntegerValues,
    num width,
    num scrollWidth,
    num scrollLeft,
    num height,
    num scrollHeight,
    num scrollTop,
  )   : rawScrollLeft = _coerce(scrollLeft, _forceIntegerValues),
        rawScrollTop = _coerce(scrollTop, _forceIntegerValues),
        _width = _validateSize(width, _forceIntegerValues),
        _scrollWidth = _coerce(scrollWidth, _forceIntegerValues),
        _height = _validateSize(height, _forceIntegerValues),
        _scrollHeight = _coerce(scrollHeight, _forceIntegerValues),
        _scrollLeft = _validateOffset(scrollLeft, _forceIntegerValues,
            _validateSize(width, _forceIntegerValues),
            _coerce(scrollWidth, _forceIntegerValues)),
        _scrollTop = _validateOffset(scrollTop, _forceIntegerValues,
            _validateSize(height, _forceIntegerValues),
            _coerce(scrollHeight, _forceIntegerValues));

  @override
  num get width => _width;
  @override
  num get scrollWidth => _scrollWidth;
  @override
  num get scrollLeft => _scrollLeft;
  @override
  num get height => _height;
  @override
  num get scrollHeight => _scrollHeight;
  @override
  num get scrollTop => _scrollTop;

  bool equals(ScrollState other) {
    return rawScrollLeft == other.rawScrollLeft &&
        rawScrollTop == other.rawScrollTop &&
        width == other.width &&
        scrollWidth == other.scrollWidth &&
        scrollLeft == other.scrollLeft &&
        height == other.height &&
        scrollHeight == other.scrollHeight &&
        scrollTop == other.scrollTop;
  }

  ScrollState withScrollDimensions(
      NewScrollDimensions update, bool useRawScrollPositions) {
    return ScrollState(
      _forceIntegerValues,
      update.width ?? width,
      update.scrollWidth ?? scrollWidth,
      useRawScrollPositions ? rawScrollLeft : scrollLeft,
      update.height ?? height,
      update.scrollHeight ?? scrollHeight,
      useRawScrollPositions ? rawScrollTop : scrollTop,
    );
  }

  ScrollState withScrollPosition(NewScrollPosition update) {
    return ScrollState(
      _forceIntegerValues,
      width,
      scrollWidth,
      update.scrollLeft ?? rawScrollLeft,
      height,
      scrollHeight,
      update.scrollTop ?? rawScrollTop,
    );
  }

  ScrollEvent createScrollEvent(ScrollState previous, bool inSmoothScrolling) {
    final bool widthChanged = width != previous.width;
    final bool scrollWidthChanged = scrollWidth != previous.scrollWidth;
    final bool scrollLeftChanged = scrollLeft != previous.scrollLeft;
    final bool heightChanged = height != previous.height;
    final bool scrollHeightChanged = scrollHeight != previous.scrollHeight;
    final bool scrollTopChanged = scrollTop != previous.scrollTop;

    return ScrollEvent(
      inSmoothScrolling: inSmoothScrolling,
      oldWidth: previous.width,
      oldScrollWidth: previous.scrollWidth,
      oldScrollLeft: previous.scrollLeft,
      width: width,
      scrollWidth: scrollWidth,
      scrollLeft: scrollLeft,
      oldHeight: previous.height,
      oldScrollHeight: previous.scrollHeight,
      oldScrollTop: previous.scrollTop,
      height: height,
      scrollHeight: scrollHeight,
      scrollTop: scrollTop,
      widthChanged: widthChanged,
      scrollWidthChanged: scrollWidthChanged,
      scrollLeftChanged: scrollLeftChanged,
      heightChanged: heightChanged,
      scrollHeightChanged: scrollHeightChanged,
      scrollTopChanged: scrollTopChanged,
    );
  }
}

/// 1:1: `export class Scrollable extends Disposable`
class Scrollable extends lifecycle.Disposable {
  num _smoothScrollDuration;
  final lifecycle.IDisposable Function(void Function() callback)
      _scheduleAtNextAnimationFrame;
  ScrollState _state;
  SmoothScrollingOperation? _smoothScrolling;

  late final event.Emitter<ScrollEvent> _onScroll =
      register(event.Emitter<ScrollEvent>());

  event.Event<ScrollEvent> get onScroll => _onScroll.event;

  Scrollable(ScrollableOptions options)
      : _smoothScrollDuration = options.smoothScrollDuration,
        _scheduleAtNextAnimationFrame = options.scheduleAtNextAnimationFrame,
        _state = ScrollState(options.forceIntegerValues, 0, 0, 0, 0, 0, 0),
        _smoothScrolling = null;

  @override
  void dispose() {
    if (_smoothScrolling != null) {
      _smoothScrolling!.dispose();
      _smoothScrolling = null;
    }
    super.dispose();
  }

  void setSmoothScrollDuration(num smoothScrollDuration) {
    _smoothScrollDuration = smoothScrollDuration;
  }

  IScrollPosition validateScrollPosition(NewScrollPosition scrollPosition) =>
      _state.withScrollPosition(scrollPosition);

  IScrollDimensions getScrollDimensions() => _state;

  void setScrollDimensions(
      NewScrollDimensions dimensions, bool useRawScrollPositions) {
    final ScrollState newState =
        _state.withScrollDimensions(dimensions, useRawScrollPositions);
    _setState(newState, _smoothScrolling != null);
    _smoothScrolling?.acceptScrollDimensions(_state);
  }

  /// Final position once the animation concludes (or current position).
  IScrollPosition getFutureScrollPosition() =>
      _smoothScrolling?.to ?? _state;

  IScrollPosition getCurrentScrollPosition() => _state;

  void setScrollPositionNow(NewScrollPosition update) {
    final ScrollState newState = _state.withScrollPosition(update);
    if (_smoothScrolling != null) {
      _smoothScrolling!.dispose();
      _smoothScrolling = null;
    }
    _setState(newState, false);
  }

  void setScrollPositionSmooth(NewScrollPosition position,
      [bool reuseAnimation = false]) {
    NewScrollPosition update = position;
    if (_smoothScrollDuration == 0) {
      return setScrollPositionNow(update);
    }

    if (_smoothScrolling != null) {
      update = NewScrollPosition(
        scrollLeft: update.scrollLeft ?? _smoothScrolling!.to.scrollLeft,
        scrollTop: update.scrollTop ?? _smoothScrolling!.to.scrollTop,
      );
      final ScrollState validTarget = _state.withScrollPosition(update);
      if (_smoothScrolling!.to.scrollLeft == validTarget.scrollLeft &&
          _smoothScrolling!.to.scrollTop == validTarget.scrollTop) {
        return;
      }
      late final SmoothScrollingOperation newSmoothScrolling;
      if (reuseAnimation) {
        newSmoothScrolling = SmoothScrollingOperation(
          _smoothScrolling!.from,
          validTarget,
          _smoothScrolling!.startTime,
          _smoothScrolling!.duration,
        );
      } else {
        newSmoothScrolling = _smoothScrolling!.combine(
            _state, validTarget, _smoothScrollDuration);
      }
      _smoothScrolling!.dispose();
      _smoothScrolling = newSmoothScrolling;
    } else {
      final ScrollState validTarget = _state.withScrollPosition(update);
      _smoothScrolling = SmoothScrollingOperation.start(
          _state, validTarget, _smoothScrollDuration);
    }

    _smoothScrolling!.animationFrameDisposable =
        _scheduleAtNextAnimationFrame(() {
      if (_smoothScrolling == null) {
        return;
      }
      _smoothScrolling!.animationFrameDisposable = null;
      _performSmoothScrolling();
    });
  }

  bool hasPendingScrollAnimation() => _smoothScrolling != null;

  void _performSmoothScrolling() {
    if (_smoothScrolling == null) {
      return;
    }
    final SmoothScrollingUpdate update = _smoothScrolling!.tick();
    final ScrollState newState = _state.withScrollPosition(
        NewScrollPosition(scrollLeft: update.scrollLeft, scrollTop: update.scrollTop));
    _setState(newState, true);

    if (_smoothScrolling == null) {
      return;
    }
    if (update.isDone) {
      _smoothScrolling!.dispose();
      _smoothScrolling = null;
      return;
    }

    _smoothScrolling!.animationFrameDisposable =
        _scheduleAtNextAnimationFrame(() {
      if (_smoothScrolling == null) {
        return;
      }
      _smoothScrolling!.animationFrameDisposable = null;
      _performSmoothScrolling();
    });
  }

  void _setState(ScrollState newState, bool inSmoothScrolling) {
    final ScrollState oldState = _state;
    if (oldState.equals(newState)) {
      return;
    }
    _state = newState;
    _onScroll.fire(_state.createScrollEvent(oldState, inSmoothScrolling));
  }
}

/// 1:1: `export class SmoothScrollingUpdate`
class SmoothScrollingUpdate {
  final num scrollLeft;
  final num scrollTop;
  final bool isDone;

  SmoothScrollingUpdate(this.scrollLeft, this.scrollTop, this.isDone);
}

/// 1:1: `interface IAnimation`
typedef IAnimation = num Function(num completion);

/// 1:1: `function createEaseOutCubic`
IAnimation createEaseOutCubic(num from, num to) {
  final num delta = to - from;
  return (num completion) => from + delta * easeOutCubic(completion);
}

/// 1:1: `function createComposed`
IAnimation createComposed(IAnimation a, IAnimation b, num cut) {
  return (num completion) {
    if (completion < cut) {
      return a(completion / cut);
    }
    return b((completion - cut) / (1 - cut));
  };
}

/// 1:1: `export class SmoothScrollingOperation`
class SmoothScrollingOperation implements ISmoothScrollPosition {
  final ISmoothScrollPosition from;
  ISmoothScrollPosition to;
  final num duration;
  final int startTime;
  lifecycle.IDisposable? animationFrameDisposable;

  late IAnimation _scrollLeft;
  late IAnimation _scrollTop;

  SmoothScrollingOperation(
      this.from, this.to, this.startTime, this.duration) {
    animationFrameDisposable = null;
    _initAnimations();
  }

  @override
  num get width => to.width;

  @override
  num get height => to.height;

  @override
  num get scrollLeft => to.scrollLeft;

  @override
  num get scrollTop => to.scrollTop;

  void _initAnimations() {
    _scrollLeft =
        _initAnimation(from.scrollLeft, to.scrollLeft, to.width);
    _scrollTop = _initAnimation(from.scrollTop, to.scrollTop, to.height);
  }

  IAnimation _initAnimation(num from, num to, num viewportSize) {
    final num delta = (from - to).abs();
    if (delta > 2.5 * viewportSize) {
      late final num stop1;
      late final num stop2;
      if (from < to) {
        stop1 = from + 0.75 * viewportSize;
        stop2 = to - 0.75 * viewportSize;
      } else {
        stop1 = from - 0.75 * viewportSize;
        stop2 = to + 0.75 * viewportSize;
      }
      return createComposed(
          createEaseOutCubic(from, stop1), createEaseOutCubic(stop2, to), 0.33);
    }
    return createEaseOutCubic(from, to);
  }

  void dispose() {
    if (animationFrameDisposable != null) {
      animationFrameDisposable!.dispose();
      animationFrameDisposable = null;
    }
  }

  void acceptScrollDimensions(ScrollState state) {
    to = state.withScrollPosition(
        NewScrollPosition(scrollLeft: to.scrollLeft, scrollTop: to.scrollTop));
    _initAnimations();
  }

  SmoothScrollingUpdate tick() =>
      _tick(DateTime.now().millisecondsSinceEpoch);

  SmoothScrollingUpdate _tick(int now) {
    final num completion = (now - startTime) / duration;
    if (completion < 1) {
      return SmoothScrollingUpdate(
          _scrollLeft(completion), _scrollTop(completion), false);
    }
    return SmoothScrollingUpdate(to.scrollLeft, to.scrollTop, true);
  }

  SmoothScrollingOperation combine(
          ISmoothScrollPosition from, ISmoothScrollPosition to, num duration) =>
      SmoothScrollingOperation.start(from, to, duration);

  static SmoothScrollingOperation start(
      ISmoothScrollPosition from, ISmoothScrollPosition to, num duration) {
    duration = duration + 10;
    final int startTime = DateTime.now().millisecondsSinceEpoch - 10;
    return SmoothScrollingOperation(from, to, startTime, duration);
  }
}

num easeInCubic(num t) => t * t * t;

num easeOutCubic(num t) => 1 - easeInCubic(1 - t);
