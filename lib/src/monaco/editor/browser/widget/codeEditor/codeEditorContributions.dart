// 1:1 port of
// vscode/src/vs/editor/browser/widget/codeEditor/codeEditorContributions.ts
// @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
//
// Adaptations:
//   - `editorBrowser.ts`, `editorExtensions.ts` and `IEditorContribution` are
//     unported interfaces; narrow file-local carriers stand in for them.
//   - `getWindow` / `runWhenWindowIdle` are injectable replay boundaries so
//     idle callbacks can be driven deterministically.
//   - `DisposableMap` has no public iterator in the Dart port; a parallel map
//     preserves TS `for..of` iteration order over live instances.

import '../../../../base/browser/dom.dart' show getWindow, runWhenWindowIdle;
import '../../../../base/browser/window.dart' show CodeWindow;
import '../../../../base/common/async.dart' show IdleDeadline;
import '../../../../base/common/errors.dart' show onUnexpectedError;
import '../../../../base/common/lifecycle.dart'
    show Disposable, DisposableMap, IDisposable;
import '../../../../platform/instantiation/common/instantiation.dart'
    show IInstantiationServiceType;

/// 1:1: `const enum EditorContributionInstantiation`.
class EditorContributionInstantiationForCodeEditor {
  static const int Eager = 0;
  static const int AfterFirstRender = 1;
  static const int BeforeFirstInteraction = 2;
  static const int Eventually = 3;

  const EditorContributionInstantiationForCodeEditor._();
}

/// 1:1: `IEditorContributionDescription` carrier.
class IEditorContributionDescriptionForCodeEditor {
  const IEditorContributionDescriptionForCodeEditor({
    required this.id,
    required this.ctor,
    required this.instantiation,
  });

  final String id;
  final Object ctor;
  final int instantiation;
}

/// 1:1: `ICodeEditor` subset used here.
abstract class ICodeEditorForCodeEditorContributions {
  Object getDomNode();
}

/// 1:1: `IEditorContribution` (opaque carrier; methods are read dynamically).
abstract class IEditorContributionForCodeEditor implements IDisposable {}

Object Function(Object? element)? _getWindowForReplay;
IDisposable Function(
  Object window,
  void Function(Object deadline) callback, [
  int? timeout,
])? _runWhenWindowIdleForReplay;
void Function(Object error)? _unexpectedErrorForReplay;
void Function(String message)? _warnForReplay;

void configureCodeEditorContributionsGetWindowForReplay(
  Object Function(Object? element)? factory,
) {
  _getWindowForReplay = factory;
}

void configureCodeEditorContributionsIdleForReplay(
  IDisposable Function(
    Object window,
    void Function(Object deadline) callback, [
    int? timeout,
  ])? factory,
) {
  _runWhenWindowIdleForReplay = factory;
}

void configureCodeEditorContributionsUnexpectedErrorForReplay(
  void Function(Object error)? handler,
) {
  _unexpectedErrorForReplay = handler;
}

void configureCodeEditorContributionsWarnForReplay(
  void Function(String message)? handler,
) {
  _warnForReplay = handler;
}

Object _getWindow(Object? element) =>
    _getWindowForReplay?.call(element) ?? getWindow(element);

IDisposable _runWhenWindowIdle(
  Object window,
  void Function(IdleDeadline deadline) callback, [
  int? timeout,
]) {
  final IDisposable Function(
    Object,
    void Function(Object), [
    int?,
  ])? factory = _runWhenWindowIdleForReplay;
  if (factory != null) {
    return factory(window, (Object deadline) => callback(deadline as IdleDeadline),
        timeout);
  }
  return runWhenWindowIdle(window as CodeWindow, callback, timeout);
}

void _onUnexpectedError(Object error) {
  final void Function(Object)? handler = _unexpectedErrorForReplay;
  if (handler != null) {
    handler(error);
    return;
  }
  onUnexpectedError(error);
}

void _warn(String message) {
  final void Function(String)? handler = _warnForReplay;
  if (handler != null) {
    handler(message);
  }
}

/// Manages the contributions instantiated for a code editor.
class CodeEditorContributions extends Disposable {
  CodeEditorContributions() : super() {
    _instances = register(DisposableMap<String, IEditorContributionForCodeEditor>());
    _finishedInstantiation[EditorContributionInstantiationForCodeEditor.Eager] =
        false;
    _finishedInstantiation[
        EditorContributionInstantiationForCodeEditor.AfterFirstRender] = false;
    _finishedInstantiation[
        EditorContributionInstantiationForCodeEditor.BeforeFirstInteraction] =
        false;
    _finishedInstantiation[
        EditorContributionInstantiationForCodeEditor.Eventually] = false;
  }

  ICodeEditorForCodeEditorContributions? _editor;
  IInstantiationServiceType? _instantiationService;

  late final DisposableMap<String, IEditorContributionForCodeEditor> _instances;
  final Map<String, IEditorContributionDescriptionForCodeEditor> _pending =
      <String, IEditorContributionDescriptionForCodeEditor>{};
  final List<bool> _finishedInstantiation = List<bool>.filled(4, false);
  final Map<String, IEditorContributionForCodeEditor> _instanceLookup =
      <String, IEditorContributionForCodeEditor>{};

  void initialize(
    ICodeEditorForCodeEditorContributions editor,
    List<IEditorContributionDescriptionForCodeEditor> contributions,
    IInstantiationServiceType instantiationService,
  ) {
    _editor = editor;
    _instantiationService = instantiationService;

    for (final IEditorContributionDescriptionForCodeEditor desc
        in contributions) {
      if (_pending.containsKey(desc.id)) {
        _onUnexpectedError(StateError(
            'Cannot have two contributions with the same id ${desc.id}'));
        continue;
      }
      _pending[desc.id] = desc;
    }

    _instantiateSome(EditorContributionInstantiationForCodeEditor.Eager);

    register(_runWhenWindowIdle(
      _getWindow(editor.getDomNode()),
      (IdleDeadline _) {
        _instantiateSome(
            EditorContributionInstantiationForCodeEditor.AfterFirstRender);
      },
    ));

    register(_runWhenWindowIdle(
      _getWindow(editor.getDomNode()),
      (IdleDeadline _) {
        _instantiateSome(
            EditorContributionInstantiationForCodeEditor.BeforeFirstInteraction);
      },
    ));

    register(_runWhenWindowIdle(
      _getWindow(editor.getDomNode()),
      (IdleDeadline _) {
        _instantiateSome(EditorContributionInstantiationForCodeEditor.Eventually);
      },
      5000,
    ));
  }

  Map<String, Object?> saveViewState() {
    final Map<String, Object?> contributionsState = <String, Object?>{};
    for (final MapEntry<String, IEditorContributionForCodeEditor> entry
        in _instanceLookup.entries) {
      final Object? callback = (entry.value as dynamic).saveViewState;
      if (callback is Function) {
        contributionsState[entry.key] = callback();
      }
    }
    return contributionsState;
  }

  void restoreViewState(Map<String, Object?> contributionsState) {
    for (final MapEntry<String, IEditorContributionForCodeEditor> entry
        in _instanceLookup.entries) {
      final Object? callback = (entry.value as dynamic).restoreViewState;
      if (callback is Function) {
        callback(contributionsState[entry.key]);
      }
    }
  }

  IEditorContributionForCodeEditor? get(String id) {
    _instantiateById(id);
    return _instances.get(id);
  }

  /// Used by tests.
  void set(String id, IEditorContributionForCodeEditor value) {
    _instances.set(id, value);
    _instanceLookup[id] = value;
  }

  void onBeforeInteractionEvent() {
    _instantiateSome(
        EditorContributionInstantiationForCodeEditor.BeforeFirstInteraction);
  }

  IDisposable onAfterModelAttached() {
    return _runWhenWindowIdle(
      _getWindow(_editor?.getDomNode()),
      (IdleDeadline _) {
        _instantiateSome(
            EditorContributionInstantiationForCodeEditor.AfterFirstRender);
      },
      50,
    );
  }

  void _instantiateSome(int instantiation) {
    if (_finishedInstantiation[instantiation]) {
      return;
    }
    _finishedInstantiation[instantiation] = true;

    final List<IEditorContributionDescriptionForCodeEditor> contribs =
        _findPendingContributionsByInstantiation(instantiation);
    for (final IEditorContributionDescriptionForCodeEditor contrib in contribs) {
      _instantiateById(contrib.id);
    }
  }

  List<IEditorContributionDescriptionForCodeEditor>
      _findPendingContributionsByInstantiation(int instantiation) {
    final List<IEditorContributionDescriptionForCodeEditor> result =
        <IEditorContributionDescriptionForCodeEditor>[];
    for (final IEditorContributionDescriptionForCodeEditor desc
        in _pending.values) {
      if (desc.instantiation == instantiation) {
        result.add(desc);
      }
    }
    return result;
  }

  void _instantiateById(String id) {
    final IEditorContributionDescriptionForCodeEditor? desc = _pending.remove(id);
    if (desc == null) {
      return;
    }

    final IInstantiationServiceType? service = _instantiationService;
    final ICodeEditorForCodeEditorContributions? editor = _editor;
    if (service == null || editor == null) {
      throw StateError(
          'Cannot instantiate contributions before being initialized!');
    }

    try {
      final Object? instance = service.createInstance(desc.ctor, <Object?>[editor]);
      final IEditorContributionForCodeEditor contribution =
          instance as IEditorContributionForCodeEditor;
      _instances.set(desc.id, contribution);
      _instanceLookup[desc.id] = contribution;
      final Object? callback = (contribution as dynamic).restoreViewState;
      if (callback is Function &&
          desc.instantiation !=
              EditorContributionInstantiationForCodeEditor.Eager) {
        _warn("Editor contribution '${desc.id}' should be eager instantiated "
            'because it uses saveViewState / restoreViewState.');
      }
    } catch (err) {
      _onUnexpectedError(err);
    }
  }
}
