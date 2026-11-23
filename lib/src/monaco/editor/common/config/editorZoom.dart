// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/config/editorZoom.ts
// Translated 1:1 from TypeScript. `IEditorZoom` -> abstract class; the
// anonymous `new class implements` singleton -> a private impl + a top-level
// final instance. `Event<T>` is the shared event typedef.
// ---------------------------------------------------------------------------

import '../../../base/common/event.dart' show Emitter, Event;

/// 1:1: `export interface IEditorZoom`
abstract class IEditorZoom {
  Event<int> get onDidChangeZoomLevel;
  int getZoomLevel();
  void setZoomLevel(int zoomLevel);
}

/// 1:1: the anonymous `new class implements IEditorZoom` instance.
class _EditorZoomImpl implements IEditorZoom {
  int _zoomLevel = 0;

  final Emitter<int> _onDidChangeZoomLevel = Emitter<int>();

  @override
  late final Event<int> onDidChangeZoomLevel = _onDidChangeZoomLevel.event;

  @override
  int getZoomLevel() => _zoomLevel;

  @override
  void setZoomLevel(int zoomLevel) {
    // Math.min(Math.max(-5, zoomLevel), 20)
    zoomLevel = zoomLevel < -5 ? -5 : (zoomLevel > 20 ? 20 : zoomLevel);
    if (_zoomLevel == zoomLevel) {
      return;
    }

    _zoomLevel = zoomLevel;
    _onDidChangeZoomLevel.fire(_zoomLevel);
  }
}

/// 1:1: `export const EditorZoom: IEditorZoom = new class ...`
final IEditorZoom EditorZoom = _EditorZoomImpl();
