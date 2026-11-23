// 1:1 port of vs/base/browser/event.ts
//
// Runtime surface: `DomEmitter` — an Emitter that lazily binds a DOM listener
// when the first subscriber attaches and unbinds when the last detaches.
// DOM event maps are TypeScript-only types, carried as [Object]/[DomEvent].

import 'dom.dart' show DomEvent, DomNode;
import '../common/event.dart' show Emitter, EmitterOptions, Event;
import '../common/lifecycle.dart' show IDisposable;

/// 1:1: `export type EventHandler = HTMLElement | HTMLDocument | Window`.
/// Carried as [DomNode] (covers both element and document in the port).
typedef EventHandler = DomNode;

/// 1:1: `export interface DOMEventMap` — TS event-name→event-type map. The
/// gesture and composition entries are type-only; carried as string keys.
class DOMEventMap {
  static const List<String> gestureEventTypes = <String>[
    '-monaco-gesturetap',
    '-monaco-gesturechange',
    '-monaco-gesturestart',
    '-monaco-gesturesend',
    '-monaco-gesturecontextmenu',
  ];
  static const List<String> compositionEventTypes = <String>[
    'compositionstart',
    'compositionupdate',
    'compositionend',
  ];
}

/// 1:1: `export class DomEmitter<K extends keyof DOMEventMap> implements IDisposable`
class DomEmitter<T> implements IDisposable {
  late final Emitter<T> _emitter;

  @override
  Event<T> get event => _emitter.event;

  DomEmitter(EventHandler element, String type, [bool? useCapture]) {
    void Function(DomEvent e) fn = (DomEvent e) => _emitter.fire(e as T);
    _emitter = Emitter<T>(EmitterOptions(
      onWillAddFirstListener: () => element.addEventListener(type, fn, useCapture),
      onDidRemoveLastListener: () =>
          element.removeEventListener(type, fn, useCapture),
    ));
  }

  @override
  void dispose() => _emitter.dispose();
}
