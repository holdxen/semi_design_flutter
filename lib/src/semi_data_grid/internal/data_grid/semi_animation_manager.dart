// Port of `packages/core/src/internal/data-grid/animation-manager.ts`.
//
// The Web version drives itself with `requestAnimationFrame`; here the grid
// owns a `Ticker` and calls [SemiAnimationManager.step] with the elapsed
// time between frames.
import 'package:flutter/foundation.dart';

import '../../common/semi_utils.dart';
import 'semi_geometry.dart';
import 'semi_types.dart';

/// `{ item, hoverAmount }` (`animation-manager.ts:5`).
@immutable
class SemiHoverValue {
  const SemiHoverValue(this.item, this.amount);

  final SemiItem item;
  final double amount;
}

/// `easeOutCubic` (`animation-manager.ts:10-13`).
double semiEaseOutCubic(double x) {
  final x1 = x - 1;
  return x1 * x1 * x1 + 1;
}

class _HoverItem {
  _HoverItem(this.item, this.amount);

  final SemiItem item;
  double amount;
}

/// `AnimationManager` (`animation-manager.ts:16-95`).
class SemiAnimationManager {
  static const double hoverTime = 80;

  _HoverItem? _current;
  final List<_HoverItem> _leaving = [];

  bool get shouldStep {
    final hasLeaving = _leaving.isNotEmpty;
    final currentAnimating =
        _current != null && _current!.amount < 1;
    return hasLeaving || currentAnimating;
  }

  List<SemiHoverValue> get animatingItems {
    final current = _current;
    if (current != null) {
      return [
        for (final item in _leaving) SemiHoverValue(item.item, item.amount),
        SemiHoverValue(current.item, current.amount),
      ];
    }
    return [
      for (final item in _leaving)
        SemiHoverValue(item.item, semiEaseOutCubic(item.amount)),
    ];
  }

  /// `setHovered` (`animation-manager.ts:79-95`).
  void setHovered(SemiItem? item) {
    if (itemsAreEqual(_current?.item, item)) return;

    final current = _current;
    if (current != null) _leaving.add(current);

    if (item != null) {
      _current = _HoverItem(item, _removeFromLeavingItems(item));
    } else {
      _current = null;
    }
  }

  /// `removeFromLeavingItems` (`animation-manager.ts:38-46`).
  double _removeFromLeavingItems(SemiItem item) {
    _HoverItem? leaving;
    for (final candidate in _leaving) {
      if (itemsAreEqual(candidate.item, item)) {
        leaving = candidate;
        break;
      }
    }
    if (leaving != null) _leaving.remove(leaving);
    return leaving?.amount ?? 0;
  }

  /// `step` (`animation-manager.ts:57-78`). [dtMs] is the time since the last
  /// step; the very first step only primes the clock upstream.
  void step(double dtMs, void Function(List<SemiHoverValue>) emit) {
    final delta = dtMs / hoverTime;

    for (final item in _leaving) {
      item.amount = clampDouble(item.amount - delta, 0, 1);
    }
    final current = _current;
    if (current != null) {
      current.amount = clampDouble(current.amount + delta, 0, 1);
    }

    emit(animatingItems);
    _leaving.removeWhere((item) => item.amount <= 0);
  }
}
