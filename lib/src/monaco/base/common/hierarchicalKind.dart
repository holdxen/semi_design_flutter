// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/hierarchicalKind.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript.
// ---------------------------------------------------------------------------

class HierarchicalKind {
  static const String sep = '.';

  /// Special kind that matches nothing
  static final HierarchicalKind None = HierarchicalKind('@@none@@');
  static final HierarchicalKind Empty = HierarchicalKind('');

  final String value;

  HierarchicalKind(this.value);

  bool equals(HierarchicalKind other) {
    return value == other.value;
  }

  bool contains(HierarchicalKind other) {
    return equals(other) || value == '' || other.value.startsWith(value + HierarchicalKind.sep);
  }

  bool intersects(HierarchicalKind other) {
    return contains(other) || other.contains(this);
  }

  HierarchicalKind append(List<String> parts) {
    return HierarchicalKind((value.isNotEmpty ? [value, ...parts] : parts).join(HierarchicalKind.sep));
  }
}
