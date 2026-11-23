// 1:1 port of vs/base/browser/ui/dnd/dnd.ts
import '../../dom.dart' show $, DomDataTransfer, DomDragEvent, DomElement, document;

/// Test seam mirroring the module's `setTimeout(..., 0)`.
void Function(void Function() callback) uiDndSetTimeout =
    (void Function() callback) => Future<void>.delayed(Duration.zero, callback);

/// 1:1: `applyDragImage`
void applyDragImage(
  DomDragEvent event,
  DomElement container,
  String label, [
  List<String> extraClasses = const <String>[],
]) {
  final Object? dataTransfer = event.dataTransfer;
  if (dataTransfer == null) return;

  final DomElement dragImage = $('.monaco-drag-image');
  dragImage.textContent = label;
  for (final String cls in extraClasses) {
    dragImage.classList.add(cls);
  }

  DomElement? getDragImageContainer(DomElement? e) {
    while (e != null && !e.classList.contains('monaco-workbench')) {
      e = e.parentElement;
    }
    return e ?? container.ownerDocument?.body ?? document.body;
  }

  final DomElement dragContainer = getDragImageContainer(container)!;
  dragContainer.appendChild(dragImage);
  (dataTransfer as DomDataTransfer).setDragImage(dragImage, -10, -10);

  // Removes the element when the DND operation is done
  uiDndSetTimeout(() => dragImage.remove());
}
