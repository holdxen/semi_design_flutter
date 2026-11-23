// 1:1 port of vs/base/browser/ui/scrollbar/scrollbarState.ts

/// JS `Math.round` rounds half toward +Infinity; Dart `.round()` rounds half
/// away from zero. Reproduce JS semantics exactly.
int _jsRound(num value) => (value + 0.5).floor();

/// The minimal size of the slider (such that it can still be clickable) -- it is artificially enlarged.
const int MINIMUM_SLIDER_SIZE = 20;

class _ComputedValues {
  final num computedAvailableSize;
  final bool computedIsNeeded;
  final num computedSliderSize;
  final num computedSliderRatio;
  final num computedSliderPosition;

  const _ComputedValues({
    required this.computedAvailableSize,
    required this.computedIsNeeded,
    required this.computedSliderSize,
    required this.computedSliderRatio,
    required this.computedSliderPosition,
  });
}

class ScrollbarState {
  /// For the vertical scrollbar: the width.
  /// For the horizontal scrollbar: the height.
  num _scrollbarSize;

  /// For the vertical scrollbar: the height of the pair horizontal scrollbar.
  /// For the horizontal scrollbar: the width of the pair vertical scrollbar.
  num _oppositeScrollbarSize;

  /// For the vertical scrollbar: the height of the scrollbar's arrows.
  /// For the horizontal scrollbar: the width of the scrollbar's arrows.
  final num _arrowSize;

  // --- variables
  /// For the vertical scrollbar: the viewport height.
  /// For the horizontal scrollbar: the viewport width.
  num _visibleSize;

  /// For the vertical scrollbar: the scroll height.
  /// For the horizontal scrollbar: the scroll width.
  num _scrollSize;

  /// For the vertical scrollbar: the scroll top.
  /// For the horizontal scrollbar: the scroll left.
  num _scrollPosition;

  // --- computed variables

  /// `visibleSize` - `oppositeScrollbarSize`
  num _computedAvailableSize;
  /// (`scrollSize` > 0 && `scrollSize` > `visibleSize`)
  bool _computedIsNeeded;

  num _computedSliderSize;
  num _computedSliderRatio;
  num _computedSliderPosition;

  ScrollbarState(num arrowSize, num scrollbarSize, num oppositeScrollbarSize,
      num visibleSize, num scrollSize, num scrollPosition)
      : _scrollbarSize = _jsRound(scrollbarSize),
        _oppositeScrollbarSize = _jsRound(oppositeScrollbarSize),
        _arrowSize = _jsRound(arrowSize),
        _visibleSize = visibleSize,
        _scrollSize = scrollSize,
        _scrollPosition = scrollPosition,
        _computedAvailableSize = 0,
        _computedIsNeeded = false,
        _computedSliderSize = 0,
        _computedSliderRatio = 0,
        _computedSliderPosition = 0 {
    _refreshComputedValues();
  }

  ScrollbarState clone() => ScrollbarState(_arrowSize, _scrollbarSize,
      _oppositeScrollbarSize, _visibleSize, _scrollSize, _scrollPosition);

  bool setVisibleSize(num visibleSize) {
    final int iVisibleSize = _jsRound(visibleSize);
    if (_visibleSize != iVisibleSize) {
      _visibleSize = iVisibleSize;
      _refreshComputedValues();
      return true;
    }
    return false;
  }

  bool setScrollSize(num scrollSize) {
    final int iScrollSize = _jsRound(scrollSize);
    if (_scrollSize != iScrollSize) {
      _scrollSize = iScrollSize;
      _refreshComputedValues();
      return true;
    }
    return false;
  }

  bool setScrollPosition(num scrollPosition) {
    final int iScrollPosition = _jsRound(scrollPosition);
    if (_scrollPosition != iScrollPosition) {
      _scrollPosition = iScrollPosition;
      _refreshComputedValues();
      return true;
    }
    return false;
  }

  void setScrollbarSize(num scrollbarSize) {
    _scrollbarSize = _jsRound(scrollbarSize);
  }

  void setOppositeScrollbarSize(num oppositeScrollbarSize) {
    _oppositeScrollbarSize = _jsRound(oppositeScrollbarSize);
  }

  static _ComputedValues _computeValues(num oppositeScrollbarSize, num arrowSize,
      num visibleSize, num scrollSize, num scrollPosition) {
    final num computedAvailableSize =
        (visibleSize - oppositeScrollbarSize) < 0 ? 0 : visibleSize - oppositeScrollbarSize;
    final num representable = computedAvailableSize - 2 * arrowSize;
    final num computedRepresentableSize = representable < 0 ? 0 : representable;
    final bool computedIsNeeded = (scrollSize > 0 && scrollSize > visibleSize);

    if (!computedIsNeeded) {
      // There is no need for a slider
      return _ComputedValues(
        computedAvailableSize: _jsRound(computedAvailableSize),
        computedIsNeeded: computedIsNeeded,
        computedSliderSize: _jsRound(computedRepresentableSize),
        computedSliderRatio: 0,
        computedSliderPosition: 0,
      );
    }

    // We must artificially increase the size of the slider if needed, since the
    // slider would be too small to grab with the mouse otherwise
    final num sliderSize = (visibleSize * computedRepresentableSize / scrollSize).floor();
    final num computedSliderSize =
        sliderSize < MINIMUM_SLIDER_SIZE ? MINIMUM_SLIDER_SIZE : sliderSize;

    // The slider can move from 0 to `computedRepresentableSize` - `computedSliderSize`
    // in the same way `scrollPosition` can move from 0 to `scrollSize` - `visibleSize`.
    final num computedSliderRatio =
        (computedRepresentableSize - computedSliderSize) / (scrollSize - visibleSize);
    final num computedSliderPosition = (scrollPosition * computedSliderRatio);

    return _ComputedValues(
      computedAvailableSize: _jsRound(computedAvailableSize),
      computedIsNeeded: computedIsNeeded,
      computedSliderSize: _jsRound(computedSliderSize),
      computedSliderRatio: computedSliderRatio,
      computedSliderPosition: _jsRound(computedSliderPosition),
    );
  }

  void _refreshComputedValues() {
    final _ComputedValues r = ScrollbarState._computeValues(
        _oppositeScrollbarSize, _arrowSize, _visibleSize, _scrollSize, _scrollPosition);
    _computedAvailableSize = r.computedAvailableSize;
    _computedIsNeeded = r.computedIsNeeded;
    _computedSliderSize = r.computedSliderSize;
    _computedSliderRatio = r.computedSliderRatio;
    _computedSliderPosition = r.computedSliderPosition;
  }

  num getArrowSize() => _arrowSize;

  num getScrollPosition() => _scrollPosition;

  num getRectangleLargeSize() => _computedAvailableSize;

  num getRectangleSmallSize() => _scrollbarSize;

  bool isNeeded() => _computedIsNeeded;

  num getSliderSize() => _computedSliderSize;

  num getSliderPosition() => _computedSliderPosition;

  /// Compute a desired `scrollPosition` such that `offset` ends up in the center of the slider.
  num getDesiredScrollPositionFromOffset(num offset) {
    if (!_computedIsNeeded) {
      // no need for a slider
      return 0;
    }
    final num desiredSliderPosition = offset - _arrowSize - _computedSliderSize / 2;
    return _jsRound(desiredSliderPosition / _computedSliderRatio);
  }

  /// Compute a desired `scrollPosition` from if offset is before or after the slider position.
  num getDesiredScrollPositionFromOffsetPaged(num offset) {
    if (!_computedIsNeeded) {
      // no need for a slider
      return 0;
    }
    final num correctedOffset = offset - _arrowSize; // compensate if has arrows
    num desiredScrollPosition = _scrollPosition;
    if (correctedOffset < _computedSliderPosition) {
      desiredScrollPosition -= _visibleSize; // page up/left
    } else {
      desiredScrollPosition += _visibleSize; // page down/right
    }
    return desiredScrollPosition;
  }

  /// Compute a desired `scrollPosition` such that the slider moves by `delta`.
  num getDesiredScrollPositionFromDelta(num delta) {
    if (!_computedIsNeeded) {
      // no need for a slider
      return 0;
    }
    final num desiredSliderPosition = _computedSliderPosition + delta;
    return _jsRound(desiredSliderPosition / _computedSliderRatio);
  }
}
