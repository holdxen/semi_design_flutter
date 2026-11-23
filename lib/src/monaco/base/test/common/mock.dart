// 1:1 port of vscode/src/vs/base/test/common/mock.ts
// sinon has no Dart counterpart: `SinonStub` is a callable carrier mirroring
// the small surface used here (callable, `returns`/`callsFake`, call tracking).
// TS type-only constructs (`Ctor<T>`, `MockObject<T, ExceptProps>`,
// `DeepPartial<T>`) map to callable typedefs / dynamic carriers.

/// 1:1: `new(): T` — a zero-arg constructor signature.
typedef Ctor<T> = T Function();

/// Callable stand-in for `sinon.SinonStub`.
///
/// 1:1: `stub()` from 'sinon'. Tracks calls and supports the `returns`,
/// `callsFake` and `throws` behaviours used by the test suite. A fresh stub
/// returns `null` until configured, mirroring sinon's default.
class SinonStub {
  final List<List<Object?>> calls = <List<Object?>>[];
  Object? Function(List<Object?> args)? _fake;
  Object? _returnValue;
  Object? _throws;

  SinonStub();

  Object? call([Object? a, Object? b, Object? c, Object? d]) {
    final List<Object?> args = <Object?>[a, b, c, d];
    calls.add(args);
    if (_throws != null) {
      throw _throws!;
    }
    if (_fake != null) {
      return _fake!(args);
    }
    return _returnValue;
  }

  SinonStub returns(Object? value) {
    _returnValue = value;
    _fake = null;
    return this;
  }

  SinonStub callsFake(Object? Function(List<Object?> args) fn) {
    _fake = fn;
    return this;
  }

  SinonStub throws(Object error) {
    _throws = error;
    return this;
  }

  int get callCount => calls.length;

  Object? get firstArg => calls.isEmpty ? null : calls.first[0];
}

/// 1:1: `export function mock<T>(): Ctor<T>` — an empty constructor.
Ctor<T> mock<T>() => () => _emptyInstance<T>();

T _emptyInstance<T>() => Object() as T;

/// 1:1: `export type MockObject<T, ExceptProps = never>` mapped type.
/// Mapped/conditional types have no Dart equivalent; the carrier is a dynamic
/// map whose absent keys materialise fresh [SinonStub]s, matching the Proxy.
typedef MockObject<T> = Map<String, Object?>;

/// 1:1: `export const mockObject = <T extends object>() => ...`
/// Returns a factory that builds a proxy-like map: any un-set property is
/// lazily filled with a [SinonStub] on first access (`get` trap), and explicit
/// [properties] are preserved (`set` trap stores the given value).
Object Function([Map<String, Object?>?]) mockObject<T extends Object>() =>
    ([Map<String, Object?>? properties]) {
      final Map<String, Object?> target = <String, Object?>{
        ...?properties,
      };
      return _MockObjectProxy(target);
    };

/// Proxy carrier: mirrors `new Proxy({ ...properties }, { get, set })`.
class _MockObjectProxy {
  final Map<String, Object?> _target;

  _MockObjectProxy(this._target);

  Object? operator [](String key) {
    if (!_target.containsKey(key)) {
      _target[key] = SinonStub();
    }
    return _target[key];
  }

  void operator []=(String key, Object? value) {
    _target[key] = value;
  }

  bool hasOwnProperty(String key) => _target.containsKey(key);

  Map<String, Object?> get raw => _target;
}

/// Shortcut for type-safe partials. 1:1: `upcastPartial<T>(partial): T`.
T upcastPartial<T>(Object partial) => partial as T;

/// Shortcut for deep partials. 1:1: `upcastDeepPartial<T>(partial): T`.
T upcastDeepPartial<T>(Object partial) => partial as T;
