// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/controller/editContext/native/editContextFactory.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
// ---------------------------------------------------------------------------

/// Opaque carrier for the DOM `EditContextInit` options object.
typedef EditContextInit = Object?;

/// Opaque carrier for the DOM `EditContext` instance returned by `create`.
class EditContextInstance {
  EditContextInstance(this.raw);
  final Object raw;
}

/// Opaque carrier for the DOM `Window` exposing an `EditContext` constructor.
///
/// 1:1: `new (window as { EditContext: new (options?) => EditContext }).EditContext(options)`
class EditContextWindow {
  EditContextWindow(this.editContextFactory);

  final Object? Function(EditContextInit? options) editContextFactory;
}

/// 1:1: `export namespace EditContext`
class EditContext {
  EditContext._();

  /// 1:1: `create(window: Window, options?: EditContextInit): EditContext`
  static EditContextInstance create(EditContextWindow window, [EditContextInit? options]) {
    return EditContextInstance(window.editContextFactory(options)!);
  }
}
