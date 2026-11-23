// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/numbers.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. JS `assert(...)` -> `assertCondition(...)`
// (assert is a Dart keyword); `Math.random()` -> `math.Random`.
// ---------------------------------------------------------------------------

import 'dart:math' as math;

import './assert.dart';

num clamp(num value, num min, num max) {
  return math.min(math.max(value, min), max);
}

/// Formats a token count for compact display (e.g. `128K`, `1M`, `1.5M`).
String formatTokenCount(num count) {
  if (count >= 1000000) {
    final num value = count / 1000000;
    final num floored = (value * 10).floor() / 10;
    return floored % 1 == 0 ? '${floored.toStringAsFixed(0)}M' : '${floored.toStringAsFixed(1)}M';
  } else if (count > 900000) {
    return '1M';
  } else if (count >= 1000) {
    return '${(count / 1000).round()}K';
  }
  return count.toString();
}

int rot(int index, int modulo) {
  return (modulo + (index % modulo)) % modulo;
}

class Counter {
  int _next = 0;

  int getNext() {
    return _next++;
  }
}

class MovingAverage {
  num _n = 1;
  num _val = 0;

  num update(num value) {
    _val = _val + (value - _val) / _n;
    _n += 1;
    return _val;
  }

  num get value => _val;
}

class SlidingWindowAverage {
  int _n = 0;
  num _val = 0;

  late final List<num> _values;
  int _index = 0;
  num _sum = 0;

  SlidingWindowAverage(int size) {
    _values = List<num>.filled(size, 0);
  }

  num update(num value) {
    final num oldValue = _values[_index];
    _values[_index] = value;
    _index = (_index + 1) % _values.length;

    _sum -= oldValue;
    _sum += value;

    if (_n < _values.length) {
      _n += 1;
    }

    _val = _sum / _n;
    return _val;
  }

  num get value => _val;
}

/// Returns whether the point is within the triangle formed by the following 6 x/y point pairs
bool isPointWithinTriangle(
  num x, num y,
  num ax, num ay,
  num bx, num by,
  num cx, num cy,
) {
  final num v0x = cx - ax;
  final num v0y = cy - ay;
  final num v1x = bx - ax;
  final num v1y = by - ay;
  final num v2x = x - ax;
  final num v2y = y - ay;

  final num dot00 = v0x * v0x + v0y * v0y;
  final num dot01 = v0x * v1x + v0y * v1y;
  final num dot02 = v0x * v2x + v0y * v2y;
  final num dot11 = v1x * v1x + v1y * v1y;
  final num dot12 = v1x * v2x + v1y * v2y;

  final num invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
  final num u = (dot11 * dot02 - dot01 * dot12) * invDenom;
  final num v = (dot00 * dot12 - dot01 * dot02) * invDenom;

  return u >= 0 && v >= 0 && u + v < 1;
}

bool randomChance(num p) {
  assertCondition(p >= 0 && p <= 1, 'p must be between 0 and 1');
  return math.Random().nextDouble() < p;
}
