// 1:1 port of vscode/src/vs/editor/common/diff/defaultLinesDiffComputer/utils.ts

import '../../../../base/common/charCode.dart' show CharCode;
import '../../core/ranges/lineRange.dart' show LineRange;
import '../rangeMapping.dart' show DetailedLineRangeMapping;

/// 1:1: `export class Array2D<T>`
class Array2D<T> {
  final int width;
  final int height;
  late final List<T?> _array;

  Array2D(this.width, this.height) {
    _array = List<T?>.filled(width * height, null);
  }

  T get(int x, int y) => _array[x + y * width] as T;

  void set(int x, int y, T value) {
    _array[x + y * width] = value;
  }
}

/// 1:1: `export function isSpace(charCode)`
bool isSpace(int charCode) =>
    charCode == CharCode.Space || charCode == CharCode.Tab;

/// 1:1: `export class LineRangeFragment`
class LineRangeFragment {
  static final Map<String, int> _chrKeys = <String, int>{};

  /// Source has `private static getKey`; exposed here so truth tests can
  /// observe the exact key allocation order.
  static int getKey(String chr) {
    int? key = _chrKeys[chr];
    if (key == null) {
      key = _chrKeys.length;
      _chrKeys[chr] = key;
    }
    return key;
  }

  final LineRange range;
  final List<String> lines;
  final DetailedLineRangeMapping source;
  late final int totalCount;
  final List<int> _histogram = <int>[];

  LineRangeFragment(this.range, this.lines, this.source) {
    totalCount = _computeHistogram(range, lines, _histogram);
  }

  static int _computeHistogram(
      LineRange range, List<String> lines, List<int> histogram) {
    int counter = 0;
    for (int i = range.startLineNumber - 1;
        i < range.endLineNumberExclusive - 1;
        i++) {
      final String line = lines[i];
      for (int j = 0; j < line.length; j++) {
        counter++;
        final String chr = line[j];
        final int key = getKey(chr);
        while (histogram.length <= key) {
          histogram.add(0);
        }
        histogram[key] = (histogram[key]) + 1;
      }
      counter++;
      final int key = getKey('\n');
      while (histogram.length <= key) {
        histogram.add(0);
      }
      histogram[key] = histogram[key] + 1;
    }
    return counter;
  }

  double computeSimilarity(LineRangeFragment other) {
    int sumDifferences = 0;
    final int maxLength = _histogram.length > other._histogram.length
        ? _histogram.length
        : other._histogram.length;
    for (int i = 0; i < maxLength; i++) {
      final int a = i < _histogram.length ? _histogram[i] : 0;
      final int b = i < other._histogram.length ? other._histogram[i] : 0;
      sumDifferences += (a - b).abs();
    }
    return 1 - (sumDifferences / (totalCount + other.totalCount));
  }
}
