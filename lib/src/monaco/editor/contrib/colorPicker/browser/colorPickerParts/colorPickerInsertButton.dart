// 1:1 port of
// vscode/src/vs/editor/contrib/colorPicker/browser/colorPickerParts/colorPickerInsertButton.ts

import '../../../../../base/browser/dom.dart' as dom;
import '../../../../../base/common/event.dart' show Emitter, Event;
import '../../../../../base/common/lifecycle.dart' show Disposable;

/// 1:1: `export class InsertButton extends Disposable`
class InsertButton extends Disposable {
  late final dom.DomElement _button;
  late final Emitter<void> _onClicked;

  /// 1:1: `public readonly onClicked = this._onClicked.event`
  late final Event<void> onClicked;

  InsertButton(dom.DomElement container) {
    _onClicked = register(Emitter<void>());
    onClicked = _onClicked.event;
    _button =
        dom.append(container, <Object>[dom.DomElement('button')]) as dom.DomElement;
    _button.classList.add('insert-button');
    _button.textContent = 'Insert';
    register(dom.addDisposableListener(
        _button, dom.EventType.CLICK, (dom.DomEvent e) {
      _onClicked.fire(null);
    }));
  }

  /// 1:1: `public get button(): HTMLElement`
  dom.DomElement get button => _button;
}
