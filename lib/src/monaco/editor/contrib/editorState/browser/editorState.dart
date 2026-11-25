// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/editorState/browser/editorState.ts
// Translated 1:1 from TypeScript.
//
// Adaptations (documented inline):
//  * `ICodeEditor` / `ITextModel` are erased carriers; the member surface read
//    here matches the TS source.
//  * `EditorKeybindingCancellationTokenSource` (keybindingCancellation.ts, not
//    yet ported) is represented by a CancellationTokenSource whose editor
//    registration is an injectable hook.
//  * JS `strings.format('{0}#{1}', a, b)` maps to Dart `format(t, [a, b])`.
// ---------------------------------------------------------------------------

import '../../../../base/common/cancellation.dart'
    show CancellationToken, CancellationTokenSource;
import '../../../../base/common/lifecycle.dart'
    show DisposableStore, IDisposable;
import '../../../../base/common/strings.dart' show format;
import '../../../common/core/position.dart' show Position;
import '../../../common/core/range.dart' show Range;

/// 1:1: `const enum CodeEditorStateFlag`.
class CodeEditorStateFlag {
  const CodeEditorStateFlag._();
  static const int Value = 1;
  static const int Selection = 2;
  static const int Position = 4;
  static const int Scroll = 8;
}

/// 1:1: the `ICodeEditor` surface read here (opaque carrier).
abstract class IEditorStateCodeEditor {
  Object? getModel();
  Position? getPosition();
  Range? getSelection();
  num getScrollLeft();
  num getScrollTop();

  // Event surfaces used by the cancellation sources.
  Object get onDidChangeCursorPosition;
  Object get onDidChangeCursorSelection;
  Object get onDidScrollChange;
  Object get onDidChangeModel;
  Object get onDidChangeModelContent;
}

/// 1:1: the `ITextModel` surface read here (opaque carrier).
abstract class IEditorStateTextModel {
  Object get uri;
  int getVersionId();
  Object get onDidChangeContent;
}

/// 1:1: `EditorState`.
class EditorState {
  final int flags;

  final Position? position;
  final Range? selection;
  final String? modelVersionId;
  final num scrollLeft;
  final num scrollTop;

  EditorState(IEditorStateCodeEditor editor, this.flags)
      : modelVersionId = (flags & CodeEditorStateFlag.Value) != 0
            ? (() {
                final Object? model = editor.getModel();
                return model == null
                    ? null
                    : format('{0}#{1}', <Object?>[
                        (model as IEditorStateTextModel).uri.toString(),
                        model.getVersionId(),
                      ]);
              })()
            : null,
        position = (flags & CodeEditorStateFlag.Position) != 0
            ? editor.getPosition()
            : null,
        selection = (flags & CodeEditorStateFlag.Selection) != 0
            ? editor.getSelection()
            : null,
        scrollLeft = (flags & CodeEditorStateFlag.Scroll) != 0
            ? editor.getScrollLeft()
            : -1,
        scrollTop = (flags & CodeEditorStateFlag.Scroll) != 0
            ? editor.getScrollTop()
            : -1;

  bool _equals(Object? other) {
    if (other is! EditorState) return false;
    final EditorState state = other;
    if (modelVersionId != state.modelVersionId) return false;
    if (scrollLeft != state.scrollLeft || scrollTop != state.scrollTop) {
      return false;
    }
    if ((position == null) != (state.position == null)) return false;
    if (position != null &&
        state.position != null &&
        !position!.equals(state.position!)) {
      return false;
    }
    if ((selection == null) != (state.selection == null)) return false;
    if (selection != null &&
        state.selection != null &&
        !selection!.equalsRange(state.selection!)) {
      return false;
    }
    return true;
  }

  /// 1:1: `validate`.
  bool validate(IEditorStateCodeEditor editor) =>
      _equals(EditorState(editor, flags));
}

/// Registration hook for `EditorKeybindingCancellationTokenSource` (the TS
/// service lives in keybindingCancellation.ts, not yet ported).
typedef EditorCtsRegister = void Function(CancellationTokenSource cts);

/// 1:1: `EditorKeybindingCancellationTokenSource` (carrier over the base).
class EditorKeybindingCancellationTokenSource extends CancellationTokenSource {
  final Object editor;

  EditorKeybindingCancellationTokenSource(
    this.editor, [
    CancellationToken? parent,
    EditorCtsRegister? register,
  ]) : super(parent) {
    register?.call(this);
  }
}

/// 1:1: `EditorStateCancellationTokenSource`.
class EditorStateCancellationTokenSource
    extends EditorKeybindingCancellationTokenSource implements IDisposable {
  final DisposableStore _listener = DisposableStore();

  EditorStateCancellationTokenSource(
    IEditorStateCodeEditor editor,
    int flags, [
    Range? range,
    CancellationToken? parent,
    EditorCtsRegister? register,
  ]) : super(editor, parent, register) {
    if ((flags & CodeEditorStateFlag.Position) != 0) {
      _listener.add(_subscribe(editor.onDidChangeCursorPosition, (Object e) {
        final dynamic event = e;
        if (range == null || !range.containsPosition(event.position as Position)) {
          cancel();
        }
      }));
    }
    if ((flags & CodeEditorStateFlag.Selection) != 0) {
      _listener.add(_subscribe(editor.onDidChangeCursorSelection, (Object e) {
        final dynamic event = e;
        if (range == null || !range.containsRange(event.selection as Range)) {
          cancel();
        }
      }));
    }
    if ((flags & CodeEditorStateFlag.Scroll) != 0) {
      _listener.add(_subscribe(editor.onDidScrollChange, (_) => cancel()));
    }
    if ((flags & CodeEditorStateFlag.Value) != 0) {
      _listener.add(_subscribe(editor.onDidChangeModel, (_) => cancel()));
      _listener.add(_subscribe(editor.onDidChangeModelContent, (_) => cancel()));
    }
  }

  /// Event subscription bridge: the real `Event<T>` returns an IDisposable.
  IDisposable _subscribe(Object event, void Function(Object) handler) {
    final dynamic e = event;
    return e(handler) as IDisposable;
  }

  @override
  void dispose([bool? cancel]) {
    _listener.dispose();
    super.dispose(cancel ?? false);
  }
}

/// 1:1: `TextModelCancellationTokenSource`.
class TextModelCancellationTokenSource extends CancellationTokenSource
    implements IDisposable {
  late final IDisposable _listener;

  TextModelCancellationTokenSource(Object model, [CancellationToken? parent])
      : super(parent) {
    _listener =
        (model as dynamic).onDidChangeContent(() => cancel()) as IDisposable;
  }

  @override
  void dispose([bool? cancel]) {
    _listener.dispose();
    super.dispose(cancel ?? false);
  }
}
