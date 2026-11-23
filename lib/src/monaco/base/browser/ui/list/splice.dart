// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/browser/ui/list/splice.ts
// Translated 1:1 from TypeScript.
// ---------------------------------------------------------------------------

import '../../../common/sequence.dart' show ISpliceable;

/// 1:1: `export interface ISpreadSpliceable<T>`
abstract class ISpreadSpliceable<T> {
  void splice(int start, int deleteCount, List<T> elements);
}

/// 1:1: `export class CombinedSpliceable<T> implements ISpliceable<T>`
class CombinedSpliceable<T> implements ISpliceable<T> {
  final List<ISpliceable<T>> spliceables;

  CombinedSpliceable(this.spliceables);

  @override
  void splice(int start, int deleteCount, List<T> elements) {
    for (final ISpliceable<T> s in spliceables) {
      s.splice(start, deleteCount, elements);
    }
  }
}
