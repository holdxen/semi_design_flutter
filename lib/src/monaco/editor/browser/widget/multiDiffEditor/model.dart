// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/widget/multiDiffEditor/model.ts
// Translated 1:1. Erased interfaces are carried locally; `IValueWithChangeEvent`
// and option/model types remain opaque as in the surrounding ported layers.
// ---------------------------------------------------------------------------
import '../../../../base/common/event.dart' show Event;
import '../../../../base/common/uri.dart' show URI;

/// 1:1: `IMultiDiffEditorModel`.
abstract class IMultiDiffEditorModel {
  Object get documents;
  Map<String, Object?>? get contextKeys;
}

/// 1:1: `DiffItemSource`.
class DiffItemSource {
  final URI uri;
  final Object? textModel;

  DiffItemSource(this.uri, this.textModel);
}

/// 1:1: `IDocumentDiffItem`.
abstract class IDocumentDiffItem {
  DiffItemSource? get original;
  DiffItemSource? get modified;
  Object? get options;
  Event<void>? get onOptionsDidChange;
  Map<String, Object?>? get contextKeys;
}
