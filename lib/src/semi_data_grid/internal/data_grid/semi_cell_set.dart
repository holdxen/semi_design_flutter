// Port of `packages/core/src/internal/data-grid/cell-set.ts`.
//
// Web packs `(col,row)` into an integer to keep the set compact.
// Dart records are value types with a structural `hashCode`, so the packing
// step disappears; the public surface (`add`, `has`, `hasHeader`,
// `hasItemInRectangle`, `hasItemInRegion`) is unchanged.
import 'semi_types.dart';

class SemiCellSet {
  SemiCellSet([Iterable<SemiItem> items = const []]) : _cells = {...items};

  final Set<SemiItem> _cells;

  void add(SemiItem cell) => _cells.add(cell);

  bool has(SemiItem? cell) => cell != null && _cells.contains(cell);

  /// `has(cell: Item | undefined)` is called from the hot draw loop with a
  /// reusable item upstream; taking col/row avoids allocating there.
  bool hasAt(int col, int row) => _cells.contains(SemiItem(col, row));

  void remove(SemiItem cell) => _cells.remove(cell);

  void clear() => _cells.clear();

  int get size => _cells.length;

  bool get isEmpty => _cells.isEmpty;

  bool hasHeader() {
    for (final cell in _cells) {
      if (cell.row < 0) return true;
    }
    return false;
  }

  bool hasItemInRectangle(SemiRectangle rect) {
    for (var row = rect.y; row < rect.y + rect.height; row++) {
      for (var col = rect.x; col < rect.x + rect.width; col++) {
        if (_cells.contains(SemiItem(col.toInt(), row.toInt()))) return true;
      }
    }
    return false;
  }

  bool hasItemInRegion(List<({SemiRectangle rect, bool when})> regions) {
    for (final r in regions) {
      if (r.when && hasItemInRectangle(r.rect)) return true;
    }
    return false;
  }

  Iterable<SemiItem> get values => _cells;
}
