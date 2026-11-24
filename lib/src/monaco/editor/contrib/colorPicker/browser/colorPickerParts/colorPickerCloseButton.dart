// 1:1 port of
// vscode/src/vs/editor/contrib/colorPicker/browser/colorPickerParts/colorPickerCloseButton.ts

import '../../../../../base/browser/dom.dart' as dom;
import '../../../../../base/common/event.dart' show Emitter, Event;
import '../../../../../base/common/lifecycle.dart' show Disposable;
import '../../../../../base/common/themables.dart' show ThemeIcon;
import '../../../../../base/common/codicons.dart' show Codicon;
import '../../../../../platform/theme/common/iconRegistry.dart'
    show registerIcon;
import '../../../../../nls.dart' show localize;

/// 1:1: `export class CloseButton extends Disposable`
class CloseButton extends Disposable {
  late final dom.DomElement _button;
  late final Emitter<void> _onClicked;

  /// 1:1: `public readonly onClicked = this._onClicked.event`
  late final Event<void> onClicked;

  CloseButton(dom.DomElement container) {
    _onClicked = register(Emitter<void>());
    onClicked = _onClicked.event;

    _button = dom.document.createElement('div');
    _button.classList.add('close-button');
    dom.append(container, <Object>[_button]);

    final dom.DomElement innerDiv = dom.document.createElement('div');
    innerDiv.classList.add('close-button-inner-div');
    dom.append(_button, <Object>[innerDiv]);

    // 1:1: `dom.append(innerDiv, $('.button' + ThemeIcon.asCSSSelector(
    //        registerIcon('color-picker-close', Codicon.close, localize(...)))))`
    final dom.DomElement closeButton = dom.append(innerDiv, <Object>[
      dom.$('.button' +
          ThemeIcon.asCSSSelector(registerIcon(
              'color-picker-close',
              Codicon['close']!,
              localize('closeIcon', 'Icon to close the color picker'))))
    ]) as dom.DomElement;
    closeButton.classList.add('close-icon');

    register(dom.addDisposableListener(
        _button, dom.EventType.CLICK, (dom.DomEvent e) {
      _onClicked.fire(null);
    }));
  }
}
