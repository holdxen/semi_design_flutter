// Port of `packages/core/src/internal/data-grid/cell-set.ts`.
//
// Web packs `(col,row)` into an integer to keep the set compact.
// Dart records are value types with a structural `hashCode`, so the packing
// step disappears; the public surface (`add`, `has`, `hasHeader`,
// `hasItemInRectangle`, `hasItemInRegion`) is unchanged.
import 'glide_types.dart';

class GlideCellSet {
  GlideCellSet([Iterable<GlideItem> items = const []]) : _cells = {...items};

  final Set<GlideItem> _cells;

  void add(GlideItem cell) => _cells.add(cell);

  bool has(GlideItem? cell) => cell != null && _cells.contains(cell);

  /// `has(cell: Item | undefined)` is called from the hot draw loop with a
  /// reusable item upstream; taking col/row avoids allocating there.
  bool hasAt(int col, int row) => _cells.contains(GlideItem(col, row));

  void remove(GlideItem cell) => _cells.remove(cell);

  void clear() => _cells.clear();

  int get size => _cells.length;

  bool get isEmpty => _cells.isEmpty;

  bool hasHeader() {
    for (final cell in _cells) {
      if (cell.row < 0) return true;
    }
    return false;
  }

  bool hasItemInRectangle(GlideRectangle rect) {
    for (var row = rect.y; row < rect.y + rect.height; row++) {
      for (var col = rect.x; col < rect.x + rect.width; col++) {
        if (_cells.contains(GlideItem(col.toInt(), row.toInt()))) return true;
      }
    }
    return false;
  }

  bool hasItemInRegion(List<({GlideRectangle rect, bool when})> regions) {
    for (final r in regions) {
      if (r.when && hasItemInRectangle(r.rect)) return true;
    }
    return false;
  }

  Iterable<GlideItem> get values => _cells;
}
