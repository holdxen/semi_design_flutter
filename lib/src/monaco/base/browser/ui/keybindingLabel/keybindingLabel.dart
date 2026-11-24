// 1:1 port of vscode/src/vs/base/browser/ui/keybindingLabel/keybindingLabel.ts
import '../../dom.dart' as dom;
import '../../../common/keybindingLabels.dart' show UILabelProvider;
import '../../../common/keybindings.dart' show ResolvedChord, ResolvedKeybinding;
import '../../../common/lifecycle.dart' as lifecycle;
import '../../../common/objects.dart' as objects;
import '../../../common/platform.dart' show OperatingSystem;
import '../../../../nls.dart' as nls;
import '../hover/hover.dart' as h;
import '../hover/hoverDelegate2.dart' show getBaseLayerHoverDelegate;
import '../hover/hoverDelegateFactory.dart' show getDefaultHoverDelegate;

/// 1:1: `export interface ChordMatches`.
class ChordMatches {
  ChordMatches({
    this.ctrlKey,
    this.shiftKey,
    this.altKey,
    this.metaKey,
    this.keyCode,
  });

  bool? ctrlKey;
  bool? shiftKey;
  bool? altKey;
  bool? metaKey;
  bool? keyCode;

  Map<String, Object?> _toMap() => <String, Object?>{
        'ctrlKey': ctrlKey,
        'shiftKey': shiftKey,
        'altKey': altKey,
        'metaKey': metaKey,
        'keyCode': keyCode,
      };
}

/// 1:1: `export interface Matches`.
class Matches {
  Matches({required this.firstPart, required this.chordPart});

  final ChordMatches firstPart;
  final ChordMatches chordPart;
}

/// 1:1: `export interface IKeybindingLabelStyles`.
class IKeybindingLabelStyles {
  const IKeybindingLabelStyles({
    this.keybindingLabelBackground,
    this.keybindingLabelForeground,
    this.keybindingLabelBorder,
    this.keybindingLabelBottomBorder,
    this.keybindingLabelShadow,
  });

  final String? keybindingLabelBackground;
  final String? keybindingLabelForeground;
  final String? keybindingLabelBorder;
  final String? keybindingLabelBottomBorder;
  final String? keybindingLabelShadow;
}

/// 1:1: `export interface KeybindingLabelOptions`.
class KeybindingLabelOptions extends IKeybindingLabelStyles {
  KeybindingLabelOptions({
    super.keybindingLabelBackground,
    super.keybindingLabelForeground,
    super.keybindingLabelBorder,
    super.keybindingLabelBottomBorder,
    super.keybindingLabelShadow,
    this.renderUnboundKeybindings,
    this.disableTitle,
  });

  final bool? renderUnboundKeybindings;
  final bool? disableTitle;
}

/// 1:1: `export const unthemedKeybindingLabelOptions`.
final KeybindingLabelOptions unthemedKeybindingLabelOptions =
    KeybindingLabelOptions();

/// 1:1: `export class KeybindingLabel extends Disposable`.
class KeybindingLabel extends lifecycle.Disposable {
  KeybindingLabel(
    dom.DomElement container,
    this.os, [
    KeybindingLabelOptions? options,
  ]) : super() {
    this.options = options ?? KeybindingLabelOptions();
    final String? labelForeground = this.options.keybindingLabelForeground;

    domNode = dom.append(
        container, <Object>[dom.$('.monaco-keybinding')]) as dom.DomElement;
    if (labelForeground != null) {
      domNode.style['color'] = labelForeground;
    }

    hover = getBaseLayerHoverDelegate().setupManagedHover(
        getDefaultHoverDelegate('mouse'), domNode, '') as h.IManagedHover;
    register(hover);

    didEverRender = false;
    container.appendChild(domNode);
  }

  late dom.DomElement domNode;
  late KeybindingLabelOptions options;
  final int os;
  final Set<dom.DomElement> keyElements = <dom.DomElement>{};
  late final h.IManagedHover hover;
  ResolvedKeybinding? keybinding;
  Matches? matches;
  late bool didEverRender;

  /// 1:1: `get element(): HTMLElement`.
  dom.DomElement get element => domNode;

  /// 1:1: `set(keybinding, matches)`.
  void set(ResolvedKeybinding? value, [Matches? matches]) {
    if (didEverRender &&
        identical(keybinding, value) &&
        _areSame(this.matches, matches)) {
      return;
    }

    keybinding = value;
    this.matches = matches;
    _render();
  }

  void _render() {
    _clear();

    if (keybinding != null) {
      final List<ResolvedChord> chords = keybinding!.getChords();
      if (chords.isNotEmpty) {
        _renderChord(domNode, chords[0], matches?.firstPart);
      }
      for (int i = 1; i < chords.length; i++) {
        dom.append(domNode, <Object>[
          dom.$('span.monaco-keybinding-key-chord-separator', null, <Object>[' '])
        ]);
        _renderChord(domNode, chords[i], matches?.chordPart);
      }
      final String? ariaLabel = keybinding!.getAriaLabel();
      final String? title = (options.disableTitle ?? false)
          ? null
          : (ariaLabel == null || ariaLabel.isEmpty ? null : ariaLabel);
      hover.update(title);
      domNode.setAttribute('aria-label', title ?? '');
    } else if (options.renderUnboundKeybindings ?? false) {
      _renderUnbound(domNode);
    }

    didEverRender = true;
  }

  void _clear() {
    dom.clearNode(domNode);
    keyElements.clear();
  }

  void _renderChord(
    dom.DomElement parent,
    ResolvedChord chord,
    ChordMatches? match,
  ) {
    final modifierLabels = UILabelProvider.modifierLabels[os]!;
    if (chord.ctrlKey) {
      _renderKey(parent, modifierLabels.ctrlKey,
          match?.ctrlKey ?? false, modifierLabels.separator);
    }
    if (chord.shiftKey) {
      _renderKey(parent, modifierLabels.shiftKey,
          match?.shiftKey ?? false, modifierLabels.separator);
    }
    if (chord.altKey) {
      _renderKey(parent, modifierLabels.altKey,
          match?.altKey ?? false, modifierLabels.separator);
    }
    if (chord.metaKey) {
      _renderKey(parent, modifierLabels.metaKey,
          match?.metaKey ?? false, modifierLabels.separator);
    }
    final String? keyLabel = chord.keyLabel;
    if (keyLabel != null && keyLabel.isNotEmpty) {
      _renderKey(parent, keyLabel, match?.keyCode ?? false, '');
    }
  }

  void _renderKey(
    dom.DomElement parent,
    String label,
    bool highlight,
    String separator,
  ) {
    dom.append(
        parent, <Object>[_createKeyElement(label, highlight ? '.highlight' : '')]);
    if (separator.isNotEmpty) {
      dom.append(parent, <Object>[
        dom.$('span.monaco-keybinding-key-separator', null, <Object>[separator])
      ]);
    }
  }

  void _renderUnbound(dom.DomElement parent) {
    dom.append(parent, <Object>[
      _createKeyElement(nls.localize('unbound', 'Unbound')),
    ]);
  }

  dom.DomElement _createKeyElement(String label, [String extraClass = '']) {
    final dom.DomElement keyElement =
        dom.$('span.monaco-keybinding-key$extraClass', null, <Object>[label]);
    keyElements.add(keyElement);

    final String? background = options.keybindingLabelBackground;
    if (background != null) {
      keyElement.style['backgroundColor'] = background;
    }
    final String? border = options.keybindingLabelBorder;
    if (border != null) {
      keyElement.style['borderColor'] = border;
    }
    final String? bottomBorder = options.keybindingLabelBottomBorder;
    if (bottomBorder != null) {
      keyElement.style['borderBottomColor'] = bottomBorder;
    }
    final String? shadow = options.keybindingLabelShadow;
    if (shadow != null) {
      keyElement.style['boxShadow'] = 'inset 0 -1px 0 $shadow';
    }

    return keyElement;
  }

  static bool _areSame(Matches? a, Matches? b) {
    if (identical(a, b) || (a == null && b == null)) {
      return true;
    }
    return a != null &&
        b != null &&
        objects.equals(a.firstPart._toMap(), b.firstPart._toMap()) &&
        objects.equals(a.chordPart._toMap(), b.chordPart._toMap());
  }
}
