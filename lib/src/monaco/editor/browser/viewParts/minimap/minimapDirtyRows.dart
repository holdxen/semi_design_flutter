// 1:1 port of vs/editor/browser/viewParts/minimap/minimapDirtyRows.ts

/// JS number stringification (integer-valued doubles drop `.0`), used by the
/// template-string interpolation in [RowSignatures.add].
String _n(num value) {
  if (value is int) return value.toString();
  if (value == value.roundToDouble() && value.abs() < 1e21) {
    return value.toInt().toString();
  }
  return value.toString();
}

/// The rows `[start, end)` in which two frames differ.
class IDirtyRows {
  final int start;
  final int end;

  const IDirtyRows(this.start, this.end);
}

/// Describes what a frame draws on each pixel row of a canvas, so that two
/// frames can be compared without reading their pixels back.
class RowSignatures {
  final List<String> _rows;

  /// 1:1: `constructor(public readonly height: number)`
  final int height;

  RowSignatures(this.height) : _rows = List<String>.filled(height, '');

  /// Records a drawing that covers the rows from `y` to `y + height`.
  void add(num y, num height, String signature, bool uniform) {
    final num bottom = y + height;
    final int first = y < 0 ? 0 : y.floor(); // Math.max(0, Math.floor(y))
    // Math.min(this.height, Math.ceil(bottom))
    final int last = bottom.ceil() > this.height ? this.height : bottom.ceil();
    for (int row = first; row < last; row++) {
      // Partly covered rows record how much of them is covered.
      final num coverStart = (y > row ? y : row) - row;
      final num coverEnd = (bottom < row + 1 ? bottom : row + 1) - row;
      final String coverage = '${_n(coverStart)},${_n(coverEnd)}';
      _rows[row] += uniform ? '$signature@$coverage;' : '$signature@${_n(row - y)},$coverage;';
    }
  }

  /// Finds the smallest band of rows that contains every row drawn differently
  /// in the two frames. Returns `null` when they draw the same.
  static IDirtyRows? diff(RowSignatures? previous, RowSignatures next) {
    if (previous == null || previous.height != next.height) {
      return next.height > 0 ? IDirtyRows(0, next.height) : null;
    }
    final List<String> a = previous._rows;
    final List<String> b = next._rows;
    int start = 0;
    while (start < next.height && a[start] == b[start]) {
      start++;
    }
    if (start == next.height) {
      return null;
    }
    int end = next.height;
    while (end > start && a[end - 1] == b[end - 1]) {
      end--;
    }
    return IDirtyRows(start, end);
  }
}

/// Dart has no `CanvasRenderingContext2D`; the drawing callback is carried as
/// an opaque target, exactly mirroring the TS `(target) => void` shape.
typedef DrawCallback = void Function(Object target);

class IRecordedDrawing {
  final num top;
  final num bottom;
  final DrawCallback draw;

  const IRecordedDrawing(this.top, this.bottom, this.draw);
}

/// Records the drawings of a frame instead of drawing them, so that only the
/// rows that differ from the previous frame need to be drawn.
class RecordedFrame {
  final List<IRecordedDrawing> _drawings = <IRecordedDrawing>[];
  late final RowSignatures rows;

  RecordedFrame(int height) {
    rows = RowSignatures(height);
  }

  void fillRect(String fillStyle, num x, num y, num width, num height) {
    if (width == 0 || height == 0) {
      return;
    }
    add(y, height, 'rect:$fillStyle:$x:$width', true, (Object target) {
      final dynamic t = target;
      t.fillStyle = fillStyle;
      t.fillRect(x, y, width, height);
    });
  }

  /// Records a drawing that touches no pixel outside the rows from `y` to `y + height`.
  void add(num y, num height, String signature, bool uniform, DrawCallback draw) {
    rows.add(y, height, signature, uniform);
    _drawings.add(IRecordedDrawing(y, y + height, draw));
  }

  /// Draws, in order, every recorded drawing that touches the given rows.
  void replay(Object target, IDirtyRows rows) {
    for (final IRecordedDrawing drawing in _drawings) {
      if (drawing.bottom > rows.start && drawing.top < rows.end) {
        drawing.draw(target);
      }
    }
  }
}
