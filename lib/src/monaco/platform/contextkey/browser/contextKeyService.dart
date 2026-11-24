// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/contextkey/browser/contextKeyService.ts
// Translated 1:1 from TypeScript.
//
// Carriers / deviations forced by Dart:
//   - `undefined` -> Dart `null`; JS `null` in config values -> Dart `null`
//     (the same convention used by the rest of this port).
//   - Browser/window boundaries are injectable providers, mirroring the
//     existing `window.mainWindow` / `dom.*` carrier convention.
//   - `ContextKey.get()` -> `IContextKey.get_()` (Dart reserves `get`).
//   - `IContextKeyServiceTarget` is the DOM carrier interface from contextkey.
// ---------------------------------------------------------------------------

import 'dart:convert' show jsonEncode;

import '../../../base/browser/dom.dart' as dom;
import '../../../base/browser/window.dart' as window;
import '../../../base/common/event.dart' as events;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../base/common/marshallingIds.dart' show MarshalledId;
import '../../../base/common/objects.dart' as objects;
import '../../../base/common/ternarySearchTree.dart' as tst;
import '../../../base/common/uri.dart' show URI, UriComponents;
import '../../../nls.dart' show localize;
import '../../commands/common/commands.dart' as commands;
import '../../configuration/common/configuration.dart' as configuration;
import '../../instantiation/common/instantiation.dart' as instantiation;
import '../common/contextkey.dart' as contextkey;
import '../common/contextkeys.dart' show InputFocusedContext;

/// 1:1: `const KEYBINDING_CONTEXT_ATTR = 'data-keybinding-context'`
const String KEYBINDING_CONTEXT_ATTR = 'data-keybinding-context';

// ---------------------------------------------------------------------------
// Injectable browser boundaries. The source imports these from base/browser;
// keeping them as top-level providers makes this file testable without a DOM.
// ---------------------------------------------------------------------------

/// 1:1: `Event.runAndSubscribe(onDidRegisterWindow, ..., { window: mainWindow,
/// disposables: this._store })`.
events.Event<dom.IRegisteredCodeWindow> onDidRegisterWindowProvider =
    dom.onDidRegisterWindow;

/// 1:1: the `initial` argument passed to `Event.runAndSubscribe`.
dom.IRegisteredCodeWindow Function() initialWindowRegistrationProvider = () =>
    dom.IRegisteredCodeWindow(
        window.mainWindow, lifecycle.DisposableStore());

/// 1:1: `addDisposableListener(window, EventType.FOCUS_IN, handler, true)`
lifecycle.IDisposable Function(
  Object target,
  String type,
  void Function(dynamic e) handler, [
  Object? options,
]) addDisposableListenerProvider = (
  Object target,
  String type,
  void Function(dynamic e) handler, [
  Object? options,
]) {
  return dom.addDisposableTargetListener(
      target, type, (dom.DomEvent e) => handler(e), options);
};

/// 1:1: `ownerDocument.activeElement`
Object? Function(Object ownerDocument) activeElementProvider =
    (Object ownerDocument) => ownerDocument is dom.DomDocument
        ? ownerDocument.activeElement
        : (ownerDocument as dynamic).activeElement;

/// 1:1: `isEditableElement(element)`
bool Function(Object element) isEditableElementProvider =
    (Object element) => element is dom.DomElement
        ? dom.isEditableElement(element)
        : false;

/// 1:1: `getActiveWindow()`
window.CodeWindow Function() getActiveWindowProvider = dom.getActiveWindow;

/// 1:1: `window.document` of a `CodeWindow`
Object Function(window.CodeWindow targetWindow) windowDocumentProvider =
    (window.CodeWindow targetWindow) => dom.windowCarrier(targetWindow).document;

/// 1:1: `trackFocus(element)`
dom.IFocusTracker Function(Object element) trackFocusProvider = dom.trackFocus;

/// 1:1: `console.error(...)`
void Function(String message) consoleErrorProvider = (String message) =>
    // ignore: avoid_print
    print(message);

// ---------------------------------------------------------------------------
// Context
// ---------------------------------------------------------------------------

/// 1:1: `export class Context implements IContext`
class Context implements contextkey.IContext {
  late Context? _parent;
  late final Map<String, Object?> _value;
  // ignore: unused_field
  late final int _id;

  Context(int id, Context? parent) {
    _id = id;
    _parent = parent;
    _value = <String, Object?>{};
    _value['_contextId'] = id;
  }

  /// 1:1: `public get value(): Record<string, any>`
  Map<String, Object?> get value => Map<String, Object?>.from(_value);

  /// 1:1: `public setValue(key, value): boolean`
  bool setValue(String key, Object? value) {
    if (!objects.equals(_value[key], value)) {
      _value[key] = value;
      return true;
    }
    return false;
  }

  /// 1:1: `public removeValue(key): boolean`
  bool removeValue(String key) {
    if (_value.containsKey(key)) {
      _value.remove(key);
      return true;
    }
    return false;
  }

  /// 1:1: `public getValue<T>(key): T | undefined`
  @override
  Object? getValue(String key) {
    final Object? ret = _value[key];
    if (ret == null && _parent != null) {
      return _parent!.getValue(key);
    }
    return ret;
  }

  /// 1:1: `public hasOwnValue(key): boolean`
  bool hasOwnValue(String key) => _value.containsKey(key);

  /// 1:1: `public updateParent(parent): string[]`
  List<String> updateParent(Context parent) {
    final Context? oldParent = _parent;
    _parent = parent;

    final List<Context> oldAncestors = _getAncestorsOrSelf(oldParent);
    final List<Context> newAncestors = _getAncestorsOrSelf(parent);
    Context? sharedAncestor;
    for (final Context candidate in oldAncestors) {
      if (newAncestors.contains(candidate)) {
        sharedAncestor = candidate;
        break;
      }
    }

    final Set<String> candidateKeys = <String>{};
    if (sharedAncestor != null) {
      final List<Context> notShared = <Context>[
        ...oldAncestors.take(oldAncestors.indexOf(sharedAncestor)),
        ...newAncestors.take(newAncestors.indexOf(sharedAncestor)),
      ];
      for (final Context context in notShared) {
        for (final String key in context._value.keys) {
          candidateKeys.add(key);
        }
      }
    } else {
      for (final Context? context in <Context?>[oldParent, parent]) {
        if (context != null) {
          for (final String key in context.collectAllValues().keys) {
            candidateKeys.add(key);
          }
        }
      }
    }

    final List<String> changedKeys = <String>[];
    for (final String key in candidateKeys) {
      if (key == '_contextId' || _value.containsKey(key)) {
        continue;
      }
      if (!objects.equals(
          oldParent?._getCollectedValue(key), parent._getCollectedValue(key))) {
        changedKeys.add(key);
      }
    }
    return changedKeys;
  }

  /// 1:1: `public collectAllValues(): Record<string, any>`
  Map<String, Object?> collectAllValues() {
    Map<String, Object?> result = _parent != null
        ? _parent!.collectAllValues()
        : <String, Object?>{};
    result.addAll(_value);
    result.remove('_contextId');
    return result;
  }

  /// 1:1: `protected _getCollectedValue(key): any`
  Object? _getCollectedValue(String key) {
    if (_value.containsKey(key)) {
      return _value[key];
    }
    return _parent?._getCollectedValue(key);
  }

  /// 1:1: `private static _getAncestorsOrSelf(context): Context[]`
  static List<Context> _getAncestorsOrSelf(Context? context) {
    final List<Context> result = <Context>[];
    Context? candidate = context;
    while (candidate != null) {
      result.add(candidate);
      candidate = candidate._parent;
    }
    return result;
  }
}

/// 1:1: `class NullContext extends Context`
class NullContext extends Context {
  static final NullContext INSTANCE = NullContext();

  NullContext() : super(-1, null);

  @override
  bool setValue(String key, Object? value) => false;

  @override
  bool removeValue(String key) => false;

  @override
  Object? getValue(String key) => null;

  @override
  List<String> updateParent(Context parent) => <String>[];

  @override
  Map<String, Object?> collectAllValues() => <String, Object?>{};

  @override
  Object? _getCollectedValue(String key) => null;
}

/// 1:1: `class ConfigAwareContextValuesContainer extends Context`
class ConfigAwareContextValuesContainer extends Context
    implements lifecycle.IDisposable {
  static const String _keyPrefix = 'config.';

  final tst.TernarySearchTree<String, Object?> _values =
      tst.TernarySearchTree.forConfigKeys<Object?>();
  late final lifecycle.IDisposable _listener;
  final configuration.IConfigurationServiceType _configurationService;

  ConfigAwareContextValuesContainer(
    int id,
    this._configurationService,
    events.Emitter<contextkey.IContextKeyChangeEvent> emitter,
  ) : super(id, null) {
    _listener = _configurationService.onDidChangeConfiguration((dynamic e) {
      final configuration.IConfigurationChangeEvent event =
          e as configuration.IConfigurationChangeEvent;
      if (event.source == configuration.ConfigurationTarget.DEFAULT) {
        final List<String> allKeys =
            _values.entries.map((MapEntry<String, Object?> entry) => entry.key).toList();
        _values.clear();
        emitter.fire(ArrayContextKeyChangeEvent(allKeys));
      } else {
        final List<String> changedKeys = <String>[];
        for (final String configKey in event.affectedKeys) {
          final String contextKey = 'config.$configKey';
          final Iterable<MapEntry<String, Object?>>? cachedItems =
              _values.findSuperstr(contextKey);
          if (cachedItems != null) {
            changedKeys.addAll(cachedItems.map((entry) => entry.key));
            _values.deleteSuperstr(contextKey);
          }
          if (_values.has(contextKey)) {
            changedKeys.add(contextKey);
            _values.delete(contextKey);
          }
        }
        emitter.fire(ArrayContextKeyChangeEvent(changedKeys));
      }
    });
  }

  @override
  void dispose() {
    _listener.dispose();
  }

  @override
  Object? getValue(String key) {
    if (!key.startsWith(_keyPrefix)) {
      return super.getValue(key);
    }

    if (_values.has(key)) {
      return _values.get(key);
    }

    final String configKey = key.substring(_keyPrefix.length);
    final Object? configValue = _configurationService.getValue$1(configKey);
    final Object? value;
    if (configValue is num || configValue is bool || configValue is String) {
      value = configValue;
    } else if (configValue is List) {
      value = _jsonStringify(configValue);
    } else {
      value = configValue;
    }

    _values.set(key, value);
    return value;
  }

  // ignore: unnecessary_overrides
  @override
  bool setValue(String key, Object? value) => super.setValue(key, value);

  // ignore: unnecessary_overrides
  @override
  bool removeValue(String key) => super.removeValue(key);

  @override
  Map<String, Object?> collectAllValues() {
    final Map<String, Object?> result = <String, Object?>{};
    _values.forEach((Object? value, String index) {
      result[index] = value;
    });
    final Map<String, Object?> copy = super.collectAllValues();
    result.addAll(copy);
    return result;
  }

  @override
  Object? _getCollectedValue(String key) =>
      hasOwnValue(key) ? super._getCollectedValue(key) : _values.get(key);
}

/// 1:1: `class ContextKey<T> implements IContextKey<T>`
class ContextKey<T> implements contextkey.IContextKey<T> {
  late final AbstractContextKeyService _service;
  late final String _key;
  late final T? _defaultValue;

  ContextKey(this._service, this._key, this._defaultValue) {
    reset();
  }

  @override
  void set(T value) => _service.setContext(_key, value);

  @override
  void reset() {
    final Object? defaultValue = _defaultValue;
    if (defaultValue == null) {
      _service.removeContext(_key);
    } else {
      _service.setContext(_key, defaultValue);
    }
  }

  /// 1:1: `public get(): T | undefined`
  @override
  T? get_() => _service.getContextKeyValue<T>(_key);
}

/// 1:1: `class SimpleContextKeyChangeEvent implements IContextKeyChangeEvent`
class SimpleContextKeyChangeEvent implements contextkey.IContextKeyChangeEvent {
  final String key;
  SimpleContextKeyChangeEvent(this.key);

  @override
  bool affectsSome(contextkey.IReadableSet<String> keys) => keys.has(key);

  @override
  bool allKeysContainedIn(contextkey.IReadableSet<String> keys) =>
      affectsSome(keys);
}

/// 1:1: `class ArrayContextKeyChangeEvent implements IContextKeyChangeEvent`
class ArrayContextKeyChangeEvent implements contextkey.IContextKeyChangeEvent {
  final List<String> keys;
  ArrayContextKeyChangeEvent(this.keys);

  @override
  bool affectsSome(contextkey.IReadableSet<String> keys) {
    for (final String key in this.keys) {
      if (keys.has(key)) return true;
    }
    return false;
  }

  @override
  bool allKeysContainedIn(contextkey.IReadableSet<String> keys) =>
      this.keys.every((String key) => keys.has(key));
}

/// 1:1: `class CompositeContextKeyChangeEvent implements IContextKeyChangeEvent`
class CompositeContextKeyChangeEvent
    implements contextkey.IContextKeyChangeEvent {
  final List<contextkey.IContextKeyChangeEvent> events;
  CompositeContextKeyChangeEvent(this.events);

  @override
  bool affectsSome(contextkey.IReadableSet<String> keys) {
    for (final contextkey.IContextKeyChangeEvent e in events) {
      if (e.affectsSome(keys)) return true;
    }
    return false;
  }

  @override
  bool allKeysContainedIn(contextkey.IReadableSet<String> keys) =>
      events.every((contextkey.IContextKeyChangeEvent evt) =>
          evt.allKeysContainedIn(keys));
}

/// 1:1: object literal `{ has: key => ... }` used by scoped service
class _ReadableSet implements contextkey.IReadableSet<String> {
  final bool Function(String value) _has;
  _ReadableSet(this._has);

  @override
  bool has(String value) => _has(value);
}

// ---------------------------------------------------------------------------
// AbstractContextKeyService
// ---------------------------------------------------------------------------

/// 1:1: `export abstract class AbstractContextKeyService extends Disposable
/// implements IContextKeyService`
abstract class AbstractContextKeyService extends lifecycle.Disposable
    implements contextkey.IContextKeyServiceType {
  // ignore: unused_element
  Object? get _serviceBrand => null;

  bool _isDisposed = false;
  final int _myContextId;

  late final events.PauseableEmitter<contextkey.IContextKeyChangeEvent>
      _onDidChangeContext = register(
    events.PauseableEmitter<contextkey.IContextKeyChangeEvent>(
      events.EmitterOptionsWithMerge<contextkey.IContextKeyChangeEvent>(
          (List<contextkey.IContextKeyChangeEvent> input) =>
              CompositeContextKeyChangeEvent(input)),
    ),
  );

  AbstractContextKeyService(this._myContextId);

  @override
  Object get onDidChangeContext => _onDidChangeContext.event;

  /// 1:1: `public get contextId(): number`
  int get contextId => _myContextId;

  @override
  contextkey.IContextKey<T> createKey<T>(String key, T? defaultValue) {
    if (_isDisposed) {
      throw StateError('AbstractContextKeyService has been disposed');
    }
    return ContextKey<T>(this, key, defaultValue);
  }

  @override
  void bufferChangeEvents(void Function() callback) {
    _onDidChangeContext.pause();
    try {
      callback();
    } finally {
      _onDidChangeContext.resume();
    }
  }

  @override
  contextkey.IScopedContextKeyService createScoped(
          contextkey.IContextKeyServiceTarget domNode) =>
      ScopedContextKeyService(this, domNode);

  @override
  contextkey.IContextKeyServiceType createOverlay([
    Iterable<List<Object?>> overlay = const <List<Object?>>[],
  ]) =>
      OverlayContextKeyService(this, overlay);

  @override
  bool contextMatchesRules(contextkey.ContextKeyExpression? rules) {
    if (_isDisposed) {
      throw StateError('AbstractContextKeyService has been disposed');
    }
    final contextkey.IContext context =
        getContextValuesContainer(_myContextId);
    return rules != null ? rules.evaluate(context) : true;
  }

  @override
  T? getContextKeyValue<T>(String key) {
    if (_isDisposed) {
      return null;
    }
    return getContextValuesContainer(_myContextId).getValue(key) as T?;
  }

  /// 1:1: `public setContext(key, value): void`
  void setContext(String key, Object? value) {
    if (_isDisposed) {
      return;
    }
    final Context myContext = getContextValuesContainer(_myContextId);
    if (myContext.setValue(key, value)) {
      _onDidChangeContext.fire(SimpleContextKeyChangeEvent(key));
    }
  }

  /// 1:1: `public removeContext(key): void`
  void removeContext(String key) {
    if (_isDisposed) {
      return;
    }
    if (getContextValuesContainer(_myContextId).removeValue(key)) {
      _onDidChangeContext.fire(SimpleContextKeyChangeEvent(key));
    }
  }

  @override
  contextkey.IContext getContext(contextkey.IContextKeyServiceTarget? target) {
    if (_isDisposed) {
      return NullContext.INSTANCE;
    }
    return getContextValuesContainer(findContextAttr(target));
  }

  /// 1:1: `public abstract getContextValuesContainer(contextId): Context`
  Context getContextValuesContainer(num contextId);

  /// 1:1: `public abstract createChildContext(parentContextId?): number`
  int createChildContext([int? parentContextId]);

  /// 1:1: `public abstract disposeContext(contextId): void`
  void disposeContext(int contextId);

  /// 1:1: `public abstract updateParent(parentContextKeyService?): void`
  @override
  void updateParent([contextkey.IContextKeyServiceType? parentContextKeyService]);

  @override
  void dispose() {
    super.dispose();
    _isDisposed = true;
  }
}

// ---------------------------------------------------------------------------
// ContextKeyService
// ---------------------------------------------------------------------------

/// 1:1: `export class ContextKeyService extends AbstractContextKeyService`
class ContextKeyService extends AbstractContextKeyService {
  int _lastContextId;
  final Map<int, Context> _contexts = <int, Context>{};

  /// 1:1: `private inputFocusedContext: IContextKey<boolean>`
  late final contextkey.IContextKey<bool> inputFocusedContext;

  ContextKeyService(configuration.IConfigurationServiceType configurationService)
      : _lastContextId = 0,
        super(0) {
    ensureContextKeyCommandsRegistered();
    inputFocusedContext = InputFocusedContext.bindTo(this);

    final ConfigAwareContextValuesContainer myContext = register(
      ConfigAwareContextValuesContainer(
          _myContextId, configurationService, _onDidChangeContext),
    );
    _contexts[_myContextId] = myContext;

    register(
      events.eventRunAndSubscribe<dom.IRegisteredCodeWindow>(
        onDidRegisterWindowProvider,
        (dom.IRegisteredCodeWindow? registration) =>
            _handleRegisteredWindow(registration),
        initialWindowRegistrationProvider(),
      ),
    );
  }

  /// 1:1: body of the `Event.runAndSubscribe` callback
  void _handleRegisteredWindow(dom.IRegisteredCodeWindow? registration) {
    if (registration == null) return;
    final lifecycle.MutableDisposable<lifecycle.DisposableStore>
        onFocusDisposables = registration.disposables
        .add(lifecycle.MutableDisposable<lifecycle.DisposableStore>());
    registration.disposables.add(
      addDisposableListenerProvider(
        registration.window,
        dom.EventType.FOCUS_IN,
        (dynamic _) {
          final lifecycle.DisposableStore store = lifecycle.DisposableStore();
          onFocusDisposables.value = store;
          _updateInputContextKeys(
              windowDocumentProvider(registration.window), store);
        },
        true,
      ),
    );
  }

  /// 1:1: `private updateInputContextKeys(ownerDocument, disposables): void`
  void _updateInputContextKeys(
      Object ownerDocument, lifecycle.DisposableStore disposables) {
    bool activeElementIsInput() {
      final Object? element = activeElementProvider(ownerDocument);
      return element != null && isEditableElementProvider(element);
    }

    final bool isInputFocused = activeElementIsInput();
    inputFocusedContext.set(isInputFocused);

    if (isInputFocused) {
      final Object element = activeElementProvider(ownerDocument)!;
      final dom.IFocusTracker tracker = disposables.add(trackFocusProvider(element));
      events.eventOnce<void>(tracker.onDidBlur)((_) {
        if (identical(
            windowDocumentProvider(getActiveWindowProvider()), ownerDocument)) {
          inputFocusedContext.set(activeElementIsInput());
        }
        disposables.clear();
      }, null, disposables);
    }
  }

  @override
  Context getContextValuesContainer(num contextId) {
    if (_isDisposed) {
      return NullContext.INSTANCE;
    }
    if (contextId is int) {
      return _contexts[contextId] ?? NullContext.INSTANCE;
    }
    return NullContext.INSTANCE;
  }

  @override
  int createChildContext([int? parentContextId]) {
    if (_isDisposed) {
      throw StateError('ContextKeyService has been disposed');
    }
    final int id = ++_lastContextId;
    _contexts[id] = Context(id, getContextValuesContainer(parentContextId ?? _myContextId));
    return id;
  }

  @override
  void disposeContext(int contextId) {
    if (!_isDisposed) {
      _contexts.remove(contextId);
    }
  }

  @override
  void updateParent([
    contextkey.IContextKeyServiceType? parentContextKeyService,
  ]) {
    throw StateError('Cannot update parent of root ContextKeyService');
  }
}

// ---------------------------------------------------------------------------
// ScopedContextKeyService
// ---------------------------------------------------------------------------

/// 1:1: `class ScopedContextKeyService extends AbstractContextKeyService`
class ScopedContextKeyService extends AbstractContextKeyService
    implements contextkey.IScopedContextKeyService {
  AbstractContextKeyService _parent;
  final contextkey.IContextKeyServiceTarget _domNode;

  final lifecycle.MutableDisposable<lifecycle.IDisposable>
      _parentChangeListener = lifecycle.MutableDisposable<lifecycle.IDisposable>();

  ScopedContextKeyService(
    AbstractContextKeyService parent,
    contextkey.IContextKeyServiceTarget domNode,
  )   : _parent = parent,
        _domNode = domNode,
        super(parent.createChildContext()) {
    _updateParentChangeListener();

    if (_domNode.hasAttribute(KEYBINDING_CONTEXT_ATTR)) {
      String extraInfo = '';
      Object? classList;
      try {
        classList = (_domNode as dynamic).classList;
      } catch (_) {
        classList = null;
      }
      if (classList != null) {
        final Iterable<dynamic> values = classList is Iterable<dynamic>
            ? classList
            : <dynamic>[];
        extraInfo = values.map((dynamic e) => e.toString()).join(', ');
      }
      consoleErrorProvider(
        'Element already has context attribute${extraInfo.isNotEmpty ? ': $extraInfo' : ''}',
      );
    }
    _domNode.setAttribute(KEYBINDING_CONTEXT_ATTR, _myContextId.toString());
  }

  /// 1:1: `_updateParentChangeListener()`
  void _updateParentChangeListener() {
    _parentChangeListener.value =
        _parent.onDidChangeContext is Function
            ? (_parent.onDidChangeContext as Function)((dynamic e) {
                final contextkey.IContextKeyChangeEvent event =
                    e as contextkey.IContextKeyChangeEvent;
                final Context thisContainer =
                    _parent.getContextValuesContainer(_myContextId);
                if (!event.allKeysContainedIn(
                    _ReadableSet((String key) => thisContainer.hasOwnValue(key)))) {
                  _onDidChangeContext.fire(event);
                }
              })
            : lifecycle.Disposable.none;
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _parentChangeListener.clear();
    _parent.disposeContext(_myContextId);
    _domNode.removeAttribute(KEYBINDING_CONTEXT_ATTR);
    super.dispose();
  }

  @override
  Context getContextValuesContainer(num contextId) {
    if (_isDisposed) {
      return NullContext.INSTANCE;
    }
    return _parent.getContextValuesContainer(contextId);
  }

  @override
  int createChildContext([int? parentContextId]) {
    if (_isDisposed) {
      throw StateError('ScopedContextKeyService has been disposed');
    }
    return _parent.createChildContext(parentContextId ?? _myContextId);
  }

  @override
  void disposeContext(int contextId) {
    // Always forward to parent even after disposal.
    _parent.disposeContext(contextId);
  }

  @override
  void updateParent([
    contextkey.IContextKeyServiceType? parentContextKeyService,
  ]) {
    if (parentContextKeyService == null ||
        identical(_parent, parentContextKeyService)) {
      return;
    }
    final AbstractContextKeyService newParent =
        parentContextKeyService as AbstractContextKeyService;

    final Context thisContainer =
        _parent.getContextValuesContainer(_myContextId);
    _parent = newParent;
    _updateParentChangeListener();
    final Context newParentContainer =
        _parent.getContextValuesContainer(_parent.contextId);
    final List<String> changedKeys = thisContainer.updateParent(newParentContainer);

    _onDidChangeContext.fire(ArrayContextKeyChangeEvent(changedKeys));
  }
}

// ---------------------------------------------------------------------------
// OverlayContext + OverlayContextKeyService
// ---------------------------------------------------------------------------

/// 1:1: `class OverlayContext implements IContext`
class OverlayContext implements contextkey.IContext {
  final contextkey.IContext parent;
  final Map<String, Object?> overlay;

  OverlayContext(this.parent, this.overlay);

  @override
  Object? getValue(String key) =>
      overlay.containsKey(key) ? overlay[key] : parent.getValue(key);
}

/// 1:1: `class OverlayContextKeyService implements IContextKeyService`
class OverlayContextKeyService implements contextkey.IContextKeyServiceType {
  // ignore: unused_element
  Object? get _serviceBrand => null;

  final Object _parent;
  final Map<String, Object?> overlay;

  OverlayContextKeyService(Object parent, Iterable<List<Object?>> overlayEntries)
      : _parent = parent,
        overlay = _overlayToMap(overlayEntries);

  static Map<String, Object?> _overlayToMap(Iterable<List<Object?>> overlay) {
    final Map<String, Object?> result = <String, Object?>{};
    for (final List<Object?> entry in overlay) {
      if (entry.length >= 2) {
        result[entry[0] as String] = entry[1];
      }
    }
    return result;
  }

  /// 1:1: `get contextId(): number`
  int get contextId => _parent is AbstractContextKeyService
      ? (_parent as AbstractContextKeyService).contextId
      : (_parent as OverlayContextKeyService).contextId;

  @override
  Object get onDidChangeContext => _parent is AbstractContextKeyService
      ? (_parent as AbstractContextKeyService).onDidChangeContext
      : (_parent as OverlayContextKeyService).onDidChangeContext;

  @override
  void bufferChangeEvents(void Function() callback) {
    if (_parent is AbstractContextKeyService) {
      (_parent as AbstractContextKeyService).bufferChangeEvents(callback);
    } else {
      (_parent as OverlayContextKeyService).bufferChangeEvents(callback);
    }
  }

  @override
  contextkey.IContextKey<T> createKey<T>([String? key, T? defaultValue]) {
    throw StateError('Not supported.');
  }

  contextkey.IContext _parentGetContext(
          contextkey.IContextKeyServiceTarget? target) =>
      _parent is AbstractContextKeyService
          ? (_parent as AbstractContextKeyService).getContext(target)
          : (_parent as OverlayContextKeyService).getContext(target);

  @override
  contextkey.IContext getContext(contextkey.IContextKeyServiceTarget? target) =>
      OverlayContext(_parentGetContext(target), overlay);

  /// 1:1: `getContextValuesContainer(contextId): IContext`
  contextkey.IContext getContextValuesContainer(num contextId) {
    final contextkey.IContext parentContext = _parent is AbstractContextKeyService
        ? (_parent as AbstractContextKeyService).getContextValuesContainer(contextId)
        : (_parent as OverlayContextKeyService).getContextValuesContainer(contextId);
    return OverlayContext(parentContext, overlay);
  }

  @override
  bool contextMatchesRules(contextkey.ContextKeyExpression? rules) {
    final contextkey.IContext context = getContextValuesContainer(contextId);
    return rules != null ? rules.evaluate(context) : true;
  }

  @override
  T? getContextKeyValue<T>(String key) {
    if (overlay.containsKey(key)) {
      return overlay[key] as T?;
    }
    return _parent is AbstractContextKeyService
        ? (_parent as AbstractContextKeyService).getContextKeyValue<T>(key)
        : (_parent as OverlayContextKeyService).getContextKeyValue<T>(key);
  }

  @override
  contextkey.IScopedContextKeyService createScoped([
    contextkey.IContextKeyServiceTarget? target,
  ]) {
    throw StateError('Not supported.');
  }

  @override
  contextkey.IContextKeyServiceType createOverlay([
    Iterable<List<Object?>> overlay = const <List<Object?>>[],
  ]) =>
      OverlayContextKeyService(this, overlay);

  @override
  void updateParent([
    contextkey.IContextKeyServiceType? parentContextKeyService,
  ]) {
    throw StateError('Not supported.');
  }
}

// ---------------------------------------------------------------------------
// findContextAttr + command registration
// ---------------------------------------------------------------------------

/// 1:1: `function findContextAttr(domNode): number`
num findContextAttr(contextkey.IContextKeyServiceTarget? domNode) {
  contextkey.IContextKeyServiceTarget? node = domNode;
  while (node != null) {
    if (node.hasAttribute(KEYBINDING_CONTEXT_ATTR)) {
      final String? attr = node.getAttribute(KEYBINDING_CONTEXT_ATTR);
      if (attr != null && attr.isNotEmpty) {
        return int.tryParse(attr, radix: 10) ?? double.nan;
      }
      return double.nan;
    }
    node = node.parentElement;
  }
  return 0;
}

/// 1:1: `export function setContext(accessor, contextKey, contextValue)`
void setContext(
  instantiation.ServicesAccessor accessor,
  Object contextKey,
  Object? contextValue,
) {
  final contextkey.IContextKeyServiceType service =
      accessor.get(contextkey.IContextKeyService)
          as contextkey.IContextKeyServiceType;
  service.createKey<dynamic>(contextKey.toString(), stringifyURIs(contextValue));
}

/// 1:1: `function stringifyURIs(contextValue): any`
Object? stringifyURIs(Object? contextValue) => objects.cloneAndChange(
      contextValue,
      (Object? obj) {
        if (obj is Map && obj[r'$mid'] == MarshalledId.Uri) {
          return URI.revive(obj as UriComponents)?.toString();
        }
        if (obj is URI) {
          return obj.toString();
        }
        return null;
      },
    );

/// JS `JSON.stringify` carrier used by config values.
String _jsonStringify(Object? value) {
  if (value == null) return 'null';
  if (value is String) return jsonEncode(value);
  if (value is bool) return value ? 'true' : 'false';
  if (value is num) return _jsNum(value);
  if (value is List) {
    return '[${value.map((Object? e) => _jsonStringify(e)).join(',')}]';
  }
  if (value is Map) {
    final List<String> parts = <String>[];
    value.forEach((Object? key, Object? item) {
      if (item == null) return;
      parts.add('${jsonEncode(key.toString())}:${_jsonStringify(item)}');
    });
    return '{${parts.join(',')}}';
  }
  return jsonEncode(value.toString());
}

String _jsNum(num value) {
  if (value is int) return value.toString();
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toString();
}

/// 1:1: module-load command registrations.
///
/// Dart has no top-level statements and top-level initializers are lazy, so the
/// registration is hoisted into an idempotent function and invoked from the
/// service constructor (the first point at which this library is used).
bool _contextKeyCommandsRegistered = false;

/// Ensures the three source-level command registrations have run.
void ensureContextKeyCommandsRegistered() {
  if (_contextKeyCommandsRegistered) return;
  _contextKeyCommandsRegistered = true;
  _registerContextKeyCommands();
}

void _registerContextKeyCommands() {
  commands.CommandsRegistry.registerCommand(
    '_setContext',
    (instantiation.ServicesAccessor accessor, List<Object?> args) {
      setContext(
        accessor,
        args.isNotEmpty ? args[0] as Object : '',
        args.length > 1 ? args[1] : null,
      );
      return null;
    },
  );

  commands.CommandsRegistry.registerCommand(
    commands.ICommand(
      id: 'getContextKeyInfo',
      handler: (instantiation.ServicesAccessor accessor, List<Object?> args) {
        final List<contextkey.ContextKeyInfo> result =
            contextkey.RawContextKey.all().toList()
              ..sort((contextkey.ContextKeyInfo a, contextkey.ContextKeyInfo b) =>
                  a.key.compareTo(b.key));
        return result;
      },
      metadata: commands.ICommandMetadata(
        description: localize(
          'getContextKeyInfo',
          'A command that returns information about context keys',
        ),
        args: <commands.ICommandMetadataArg>[],
      ),
    ),
  );

  commands.CommandsRegistry.registerCommand(
    '_generateContextKeyInfo',
    (instantiation.ServicesAccessor accessor, List<Object?> args) {
      final List<contextkey.ContextKeyInfo> result =
          <contextkey.ContextKeyInfo>[];
      final Set<String> seen = <String>{};
      for (final contextkey.ContextKeyInfo info in contextkey.RawContextKey.all()) {
        if (!seen.contains(info.key)) {
          seen.add(info.key);
          result.add(info);
        }
      }
      result.sort((contextkey.ContextKeyInfo a, contextkey.ContextKeyInfo b) =>
          a.key.compareTo(b.key));
      consoleErrorProvider(jsonEncode(result
          .map((contextkey.ContextKeyInfo info) => <String, Object?>{
                'key': info.key,
                'type': info.type,
                'description': info.description,
              })
          .toList()));
      return null;
    },
  );
}
