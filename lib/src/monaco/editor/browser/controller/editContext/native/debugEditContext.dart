// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/controller/editContext/native/debugEditContext.ts
// Translated 1:1 from TypeScript. DOM APIs are expressed via injectable
// carriers so the source control flow (createElement/style/append/remove,
// listener wrapping, renderDebug) is preserved without a real DOM.
//   - `EditContext` from editContextFactory.dart (create(window, options)).
//   - `DOMRect` -> local `DebugRect` carrier (top/left/width/height).
//   - `EventHandler` -> `void Function(Object? event)`.
//   - `document` -> injectable `debugDocument`.
//   - `console.log` -> injectable `debugEditContextLog`.
// ---------------------------------------------------------------------------

import 'editContextFactory.dart'
    show EditContext, EditContextInit, EditContextInstance, EditContextWindow;

const String _COLOR_FOR_CONTROL_BOUNDS = 'blue';
const String _COLOR_FOR_SELECTION_BOUNDS = 'red';
const String _COLOR_FOR_CHARACTER_BOUNDS = 'green';

/// 1:1: the subset of DOM `DOMRect` consumed here.
class DebugRect {
  DebugRect(this.top, this.left, this.width, this.height);
  final num top;
  final num left;
  final num width;
  final num height;
}

/// 1:1: an event handler (`EventHandler | null`).
typedef EventHandler = void Function(Object? event);

/// A DOM-like element carrying mutable `style`, `className`, children and a
/// `remove()`/append surface. Mirrors the exact property writes in the source.
class DebugElement {
  DebugElement(this.tag);

  final String tag;
  final Map<String, String> style = <String, String>{};
  String className = '';
  final List<DebugElement> children = <DebugElement>[];
  final List<String> textNodes = <String>[];
  bool removed = false;

  void appendChild(DebugElement child) => children.add(child);
  void appendText(String text) => textNodes.add(text);
  void remove() => removed = true;
}

/// 1:1: the `document` surface used by `createDiv`/`createRect`.
class DebugDocument {
  DebugElement createElement(String tag) => DebugElement(tag);
  void createTextNode(DebugElement parent, String text) => parent.appendText(text);
  void bodyAppend(DebugElement element) => bodyChildren.add(element);

  final List<DebugElement> bodyChildren = <DebugElement>[];
}

/// Injectable `document` and `console.log` for test observability.
DebugDocument debugDocument = DebugDocument();
void Function(String message, Object? event) debugEditContextLog =
    (String message, Object? event) {};

/// 1:1: `export class DebugEditContext`
class DebugEditContext {
  DebugEditContext(EditContextWindow window, [EditContextInit? options])
      : _editContext = EditContext.create(window, options);

  final EditContextInstance _editContext;

  bool _isDebugging = true;
  DebugRect? _controlBounds;
  DebugRect? _selectionBounds;
  _CharacterBounds? _characterBounds;

  /// 1:1: `get text(): DOMString`
  String get text => (_prop('text') as String?) ?? '';

  /// Getters forwarded through the carrier (`raw` is the DOM EditContext).
  Object? _prop(String name) {
    final Object raw = _editContext.raw;
    if (raw is Map) {
      return raw[name];
    }
    return null;
  }

  int get selectionStart => (_prop('selectionStart') as num?)?.toInt() ?? 0;
  int get selectionEnd => (_prop('selectionEnd') as num?)?.toInt() ?? 0;
  int get characterBoundsRangeStart =>
      (_prop('characterBoundsRangeStart') as num?)?.toInt() ?? 0;

  void updateText(int rangeStart, int rangeEnd, String text) {
    _call('updateText', <Object?>[rangeStart, rangeEnd, text]);
    renderDebug();
  }

  void updateSelection(int start, int end) {
    _call('updateSelection', <Object?>[start, end]);
    renderDebug();
  }

  void updateControlBounds(DebugRect controlBounds) {
    _call('updateControlBounds', <Object?>[controlBounds]);
    _controlBounds = controlBounds;
    renderDebug();
  }

  void updateSelectionBounds(DebugRect selectionBounds) {
    _call('updateSelectionBounds', <Object?>[selectionBounds]);
    _selectionBounds = selectionBounds;
    renderDebug();
  }

  void updateCharacterBounds(int rangeStart, List<DebugRect> characterBounds) {
    _call('updateCharacterBounds', <Object?>[rangeStart, characterBounds]);
    _characterBounds = _CharacterBounds(rangeStart, characterBounds);
    renderDebug();
  }

  List<Object?> attachedElements() {
    final Object? r = _call('attachedElements', const <Object?>[]);
    return r is List ? List<Object?>.from(r) : <Object?>[];
  }

  List<DebugRect> characterBounds() {
    final Object? r = _call('characterBounds', const <Object?>[]);
    return r is List ? r.cast<DebugRect>() : <DebugRect>[];
  }

  Object? _call(String method, List<Object?> args) {
    final Object raw = _editContext.raw;
    if (raw is Map && raw[method] is Function) {
      return Function.apply(raw[method] as Function, args);
    }
    return null;
  }

  // 1:1: the five EventListenerWrapper-backed event properties.
  late final _EventListenerWrapper _ontextupdateWrapper =
      _EventListenerWrapper('textupdate', this);
  late final _EventListenerWrapper _ontextformatupdateWrapper =
      _EventListenerWrapper('textformatupdate', this);
  late final _EventListenerWrapper _oncharacterboundsupdateWrapper =
      _EventListenerWrapper('characterboundsupdate', this);
  late final _EventListenerWrapper _oncompositionstartWrapper =
      _EventListenerWrapper('compositionstart', this);
  late final _EventListenerWrapper _oncompositionendWrapper =
      _EventListenerWrapper('compositionend', this);

  EventHandler? get ontextupdate => _ontextupdateWrapper.eventHandler;
  set ontextupdate(EventHandler? value) =>
      _ontextupdateWrapper.eventHandler = value;
  EventHandler? get ontextformatupdate => _ontextformatupdateWrapper.eventHandler;
  set ontextformatupdate(EventHandler? value) =>
      _ontextformatupdateWrapper.eventHandler = value;
  EventHandler? get oncharacterboundsupdate =>
      _oncharacterboundsupdateWrapper.eventHandler;
  set oncharacterboundsupdate(EventHandler? value) =>
      _oncharacterboundsupdateWrapper.eventHandler = value;
  EventHandler? get oncompositionstart => _oncompositionstartWrapper.eventHandler;
  set oncompositionstart(EventHandler? value) =>
      _oncompositionstartWrapper.eventHandler = value;
  EventHandler? get oncompositionend => _oncompositionendWrapper.eventHandler;
  set oncompositionend(EventHandler? value) =>
      _oncompositionendWrapper.eventHandler = value;

  /// 1:1: listener map: original listener -> wrapped debug listener.
  final Map<Object, Object> _listenerMap = <Object, Object>{};

  /// 1:1: `addEventListener(type, listener, options?)`
  void addEventListener(String type, Object listener, [Object? options]) {
    final void Function(Object? event) debugListener = (Object? event) {
      if (_isDebugging) {
        renderDebug();
        debugEditContextLog('DebugEditContex.on_$type', event);
      }
      if (listener is Function) {
        Function.apply(listener, <Object?>[this, event]);
      } else if (listener is _HandleEvent) {
        listener.handleEvent(event);
      }
    };
    _listenerMap[listener] = debugListener;
    _call('addEventListener', <Object?>[type, debugListener, options]);
    renderDebug();
  }

  /// 1:1: `removeEventListener(type, listener, options?)`
  void removeEventListener(String type, Object? listener, [Object? options]) {
    if (listener == null) {
      return;
    }
    final Object? debugListener = _listenerMap[listener];
    if (debugListener != null) {
      _call('removeEventListener', <Object?>[type, debugListener, options]);
      _listenerMap.remove(listener);
    }
    renderDebug();
  }

  /// 1:1: `dispatchEvent(event): boolean`
  bool dispatchEvent(Object? event) {
    final Object? r = _call('dispatchEvent', <Object?>[event]);
    return r is bool ? r : false;
  }

  void startDebugging() {
    _isDebugging = true;
    renderDebug();
  }

  void endDebugging() {
    _isDebugging = false;
    renderDebug();
  }

  /// 1:1: `private _disposables: { dispose(): void }[]`
  List<void Function()> _disposables = <void Function()>[];

  /// 1:1: `public renderDebug()`
  void renderDebug() {
    for (final void Function() d in _disposables) {
      d();
    }
    _disposables = <void Function()>[];
    if (!_isDebugging || _listenerMap.isEmpty) {
      return;
    }
    final DebugRect? control = _controlBounds;
    if (control != null) {
      _disposables.add(createRect(control, _COLOR_FOR_CONTROL_BOUNDS));
    }
    final DebugRect? selection = _selectionBounds;
    if (selection != null) {
      _disposables.add(createRect(selection, _COLOR_FOR_SELECTION_BOUNDS));
    }
    final _CharacterBounds? chars = _characterBounds;
    if (chars != null) {
      for (final DebugRect rect in chars.characterBounds) {
        _disposables.add(createRect(rect, _COLOR_FOR_CHARACTER_BOUNDS));
      }
    }
    _disposables.add(createDiv(text, selectionStart, selectionEnd));
  }
}

/// 1:1: `{ rangeStart; characterBounds }`
class _CharacterBounds {
  _CharacterBounds(this.rangeStart, this.characterBounds);
  final int rangeStart;
  final List<DebugRect> characterBounds;
}

/// 1:1: `EventListener` object with a `handleEvent` method.
// ignore: unused_element
abstract class _HandleEvent {
  void handleEvent(Object? event);
}

/// 1:1: `function createDiv(text, selectionStart, selectionEnd)`
void Function() createDiv(String text, int selectionStart, int selectionEnd) {
  final DebugElement ret = debugDocument.createElement('div');
  ret.className = 'debug-rect-marker';
  ret.style['position'] = 'absolute';
  ret.style['zIndex'] = '999999999';
  ret.style['bottom'] = '50px';
  ret.style['left'] = '60px';
  ret.style['backgroundColor'] = 'white';
  ret.style['border'] = '1px solid black';
  ret.style['padding'] = '5px';
  ret.style['whiteSpace'] = 'pre';
  ret.style['font'] = '12px monospace';
  ret.style['pointerEvents'] = 'none';

  final String before = text.substring(0, selectionStart);
  final String selected =
      text.substring(selectionStart, selectionEnd).isEmpty ? '|' : text.substring(selectionStart, selectionEnd);
  final String after = text.substring(selectionEnd) + ' ';

  debugDocument.createTextNode(ret, before);

  final DebugElement selectedNode = debugDocument.createElement('span');
  selectedNode.style['backgroundColor'] = 'yellow';
  debugDocument.createTextNode(selectedNode, selected);
  selectedNode.style['minWidth'] = '2px';
  selectedNode.style['minHeight'] = '16px';
  ret.appendChild(selectedNode);

  debugDocument.createTextNode(ret, after);
  debugDocument.bodyAppend(ret);

  return () => ret.remove();
}

/// 1:1: `function createRect(rect, color)`
void Function() createRect(DebugRect rect, String color) {
  final DebugElement ret = debugDocument.createElement('div');
  ret.className = 'debug-rect-marker';
  ret.style['position'] = 'absolute';
  ret.style['zIndex'] = '999999999';
  ret.style['outline'] = '2px solid $color';
  ret.style['pointerEvents'] = 'none';
  ret.style['top'] = '${rect.top}px';
  ret.style['left'] = '${rect.left}px';
  ret.style['width'] = '${rect.width}px';
  ret.style['height'] = '${rect.height}px';
  debugDocument.bodyAppend(ret);
  return () => ret.remove();
}

/// 1:1: `class EventListenerWrapper`
class _EventListenerWrapper {
  _EventListenerWrapper(this._eventType, this._target);

  EventHandler? _eventHandler;
  final String _eventType;
  final Object _target;

  EventHandler? get eventHandler => _eventHandler;
  set eventHandler(EventHandler? value) {
    if (_eventHandler != null) {
      _removeFromTarget(_eventType, _eventHandler!);
    }
    _eventHandler = value;
    if (value != null) {
      _addToTarget(_eventType, value);
    }
  }

  void _removeFromTarget(String type, EventHandler handler) {
    if (_target is DebugEditContext) {
      _target.removeEventListener(type, handler);
    }
  }

  void _addToTarget(String type, EventHandler handler) {
    if (_target is DebugEditContext) {
      _target.addEventListener(type, handler);
    }
  }
}
