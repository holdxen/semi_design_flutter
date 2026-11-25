// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/controller/editContext/editContext.ts
// @bfbf12b35b9978b92b2d341e81ade49f2b18c68c (31 lines)
// Translated 1:1 from TypeScript. Structure and member semantics preserved.
//
// Adaptations:
//   - `IClipboardCopyEvent` / `IClipboardPasteEvent` and `IEditorAriaOptions`
//     are source interfaces without a port yet; their event/options payloads
//     are erased to `Object` (the Emitter wiring is what matters here).
//   - `FastDomNode<HTMLElement>` -> `FastDomNode<DomElement>` (the structural
//     DOM surface shared by the ported node types).
//   - Fields are `_`-prefixed like the source `protected` members; Dart privacy
//     is library-scoped, so subclasses live in other libraries and read only
//     the public `onWillCopy` / `onWillCut` / `onWillPaste` streams.
// ---------------------------------------------------------------------------

import '../../../../base/browser/fastDomNode.dart' show DomElement, FastDomNode;
import '../../../../base/common/event.dart' show Emitter, Event;
import '../../../common/core/position.dart' show Position;
import '../../view/viewPart.dart' show ViewPart;

/// 1:1: `export abstract class AbstractEditContext extends ViewPart`.
abstract class AbstractEditContext extends ViewPart {
  /// 1:1: `protected readonly _onWillCopy = this._register(new Emitter<...>())`
  final Emitter<Object> _onWillCopy = Emitter<Object>();
  late final Event<Object> onWillCopy = _onWillCopy.event;

  /// 1:1: `protected readonly _onWillCut = this._register(new Emitter<...>())`
  final Emitter<Object> _onWillCut = Emitter<Object>();
  late final Event<Object> onWillCut = _onWillCut.event;

  /// 1:1: `protected readonly _onWillPaste = this._register(new Emitter<...>())`
  final Emitter<Object> _onWillPaste = Emitter<Object>();
  late final Event<Object> onWillPaste = _onWillPaste.event;

  AbstractEditContext(super.context) {
    register(_onWillCopy);
    register(_onWillCut);
    register(_onWillPaste);
  }

  /// 1:1: `public abstract get domNode(): FastDomNode<HTMLElement>`
  FastDomNode<DomElement> get domNode;

  /// 1:1: `public abstract focus(): void`
  void focus();

  /// 1:1: `public abstract isFocused(): boolean`
  bool isFocused();

  /// 1:1: `public abstract refreshFocusState(): void`
  void refreshFocusState();

  /// 1:1: `public abstract setAriaOptions(options: IEditorAriaOptions): void`
  void setAriaOptions(Object options);

  /// 1:1: `public abstract getLastRenderData(): Position | null`
  Position? getLastRenderData();

  /// 1:1: `public abstract writeScreenReaderContent(reason: string): void`
  void writeScreenReaderContent(String reason);
}
