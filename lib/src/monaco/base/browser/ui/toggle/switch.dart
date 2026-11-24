// 1:1 port of vscode/src/vs/base/browser/ui/toggle/switch.ts
import '../../dom.dart' as dom;
import '../../../common/event.dart' as event;
import '../../../common/lifecycle.dart' as lifecycle;
import '../hover/hover.dart' show HoverStyle;
import '../hover/hoverDelegate2.dart' show getBaseLayerHoverDelegate;

/// 1:1: `export interface ISwitchOptions`.
class ISwitchOptions {
  ISwitchOptions({
    this.checked,
    required this.ariaLabel,
    this.title,
    this.disabled,
  });

  final bool? checked;
  final String ariaLabel;

  /// TS: `string | false | undefined`.
  final Object? title;
  final bool? disabled;
}

/// 1:1: `export class Switch extends Disposable`.
class Switch extends lifecycle.Disposable {
  Switch(ISwitchOptions options) : super() {
    _onChange = register(event.Emitter<bool>());
    onChange = _onChange.event;

    _checked = options.checked ?? false;
    final Object? title = identical(options.title, false) ? null : options.title;
    _title = (title as String?) ?? options.ariaLabel;

    domNode = dom.$('button.monaco-switch') as dom.DomElement;
    domNode.type = 'button';
    domNode.setAttribute('role', 'switch');
    dom.append(domNode, <Object>[dom.$('.monaco-switch-thumb')]);

    if (!identical(options.title, false)) {
      final Object? result = getBaseLayerHoverDelegate().setupDelayedHover(
        domNode,
        () => <String, Object?>{
          'content': _title,
          'style': HoverStyle.Pointer,
        },
      );
      if (result is lifecycle.IDisposable) {
        register(result);
      }
    }

    setAriaLabel(options.ariaLabel, title as String?);
    disabled = options.disabled ?? false;
    _applyState();

    register(dom.addDisposableListener(
        domNode, dom.EventType.CLICK, (dom.DomEvent e) {
      dom.EventHelper.stop(e, true);
      if (domNode.disabled) {
        return;
      }
      _checked = !_checked;
      _applyState();
      _onChange.fire(_checked);
    }));
  }

  late final event.Emitter<bool> _onChange;
  late final event.Event<bool> onChange;
  late final dom.DomElement domNode;
  bool _checked = false;
  String _title = '';

  bool get checked => _checked;

  set checked(bool value) {
    if (_checked != value) {
      _checked = value;
      _applyState();
    }
  }

  bool get disabled => domNode.disabled;

  set disabled(bool value) => domNode.disabled = value;

  /// 1:1: `setAriaLabel(ariaLabel, title = ariaLabel)`.
  void setAriaLabel(String ariaLabel, [String? title]) {
    domNode.setAttribute('aria-label', ariaLabel);
    _title = title ?? ariaLabel;
  }

  void _applyState() {
    domNode.setAttribute('aria-checked', _checked.toString());
    domNode.classList.toggle('checked', _checked);
  }
}
