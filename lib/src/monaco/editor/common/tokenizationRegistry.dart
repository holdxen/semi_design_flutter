// ---------------------------------------------------------------------------
// 1:1 port of vscode/src/vs/editor/common/tokenizationRegistry.ts (whole file,
// 152 lines). Runtime declarations are ported line-for-line; type-only
// declarations from languages.ts are ERASED per the repo's established
// convention.
//
// TYPE-ERASURE ADAPTATIONS:
//   - `ITokenizationRegistry<TSupport>` (implemented interface) — erased;
//     only the runtime class `TokenizationRegistry<TSupport>` is kept.
//   - `ILazyTokenizationSupport<TSupport>` (the factory parameter of
//     `registerFactory`) — erased as an interface name; its single runtime
//     member `get tokenizationSupport(): Promise<TSupport | null>` is carried
//     by the concrete Dart class [LazyTokenizationSupport] below. The harness
//     drives it with a fake whose getter increments a call counter; the
//     getter is reached exactly once per factory data because `_create`
//     memoizes its result into `_resolvePromise` (1:1 with the TS source).
//   - `ITokenizationSupportChangedEvent` — erased as an interface name; the
//     event payload `{ changedLanguages, changedColorMap }` is represented by
//     the value class [TokenizationSupportChangedEvent], with `toJson()` for
//     truth-replay comparison.
//   - `IDisposable` — erased as an imported interface; `register` /
//     `registerFactory` return the repo's `lifecycle.IDisposable` produced by
//     `toDisposable`, exactly as the TS source does.
//   - `ColorId.DefaultBackground` -> `ColorId.defaultBackground` (Dart naming).
// ---------------------------------------------------------------------------

import '../../base/common/color.dart' show Color;
import '../../base/common/event.dart' show Emitter, Event;
import '../../base/common/lifecycle.dart'
    show Disposable, IDisposable, toDisposable;
import 'encodedTokenAttributes.dart' show ColorId;

/// 1:1 adaptation of the TS `ITokenizationSupportChangedEvent` payload.
/// The interface itself is type-only and erased; this value class carries
/// exactly its two runtime fields.
class TokenizationSupportChangedEvent {
  final List<String> changedLanguages;
  final bool changedColorMap;

  TokenizationSupportChangedEvent({
    required this.changedLanguages,
    required this.changedColorMap,
  });

  /// JSON-comparable form used by the replay harness.
  Map<String, Object?> toJson() => <String, Object?>{
        'changedLanguages': changedLanguages,
        'changedColorMap': changedColorMap,
      };
}

/// 1:1 adaptation of the TS `ILazyTokenizationSupport<TSupport>` parameter
/// (type-only interface erased). The source's single runtime member is the
/// getter `tokenizationSupport`; the supplied callback is invoked each time
/// the getter is read. Callers (including the harness fake) can therefore
/// count getter invocations exactly as in TypeScript.
class LazyTokenizationSupport<TSupport extends Object> {
  final Future<TSupport?> Function() _getter;

  LazyTokenizationSupport(this._getter);

  /// 1:1: `get tokenizationSupport(): Promise<TSupport | null>`
  Future<TSupport?> get tokenizationSupport => _getter();
}

/// 1:1: `export class TokenizationRegistry<TSupport>`
class TokenizationRegistry<TSupport extends Object> {
  final Map<String, TSupport> _tokenizationSupports = <String, TSupport>{};
  final Map<String, TokenizationSupportFactoryData<TSupport>> _factories =
      <String, TokenizationSupportFactoryData<TSupport>>{};

  final Emitter<TokenizationSupportChangedEvent> _onDidChange =
      Emitter<TokenizationSupportChangedEvent>();

  /// 1:1: `public readonly onDidChange: Event<ITokenizationSupportChangedEvent>`
  late final Event<TokenizationSupportChangedEvent> onDidChange =
      _onDidChange.event;

  // TS types this as `Color[]`, but `ColorMap.getColorMap()` leaves holes
  // (index 0 is always undefined), so the runtime array is `(Color | null)[]`.
  // The Dart carrier must be nullable to reproduce `setColorMap` verbatim.
  List<Color?>? _colorMap;

  TokenizationRegistry() : _colorMap = null;

  /// 1:1: `public handleChange(languageIds: string[]): void`
  void handleChange(List<String> languageIds) {
    _onDidChange.fire(TokenizationSupportChangedEvent(
      changedLanguages: languageIds,
      changedColorMap: false,
    ));
  }

  /// 1:1: `public register(languageId: string, support: TSupport): IDisposable`
  IDisposable register(String languageId, TSupport support) {
    _tokenizationSupports[languageId] = support;
    handleChange(<String>[languageId]);
    return toDisposable(() {
      if (_tokenizationSupports[languageId] != support) {
        return;
      }
      _tokenizationSupports.remove(languageId);
      handleChange(<String>[languageId]);
    });
  }

  /// 1:1: `public get(languageId: string): TSupport | null`
  TSupport? get(String languageId) => _tokenizationSupports[languageId];

  /// 1:1: `public registerFactory(languageId: string, factory: ILazyTokenizationSupport<TSupport>): IDisposable`
  IDisposable registerFactory(
    String languageId,
    LazyTokenizationSupport<TSupport> factory,
  ) {
    _factories[languageId]?.dispose();
    final TokenizationSupportFactoryData<TSupport> myData =
        TokenizationSupportFactoryData<TSupport>(this, languageId, factory);
    _factories[languageId] = myData;
    return toDisposable(() {
      final TokenizationSupportFactoryData<TSupport>? v =
          _factories[languageId];
      if (v == null || v != myData) {
        return;
      }
      _factories.remove(languageId);
      v.dispose();
    });
  }

  /// 1:1: `public async getOrCreate(languageId: string): Promise<TSupport | null>`
  Future<TSupport?> getOrCreate(String languageId) async {
    // check first if the support is already set
    final TSupport? tokenizationSupport = get(languageId);
    if (tokenizationSupport != null) {
      return tokenizationSupport;
    }

    final TokenizationSupportFactoryData<TSupport>? factory =
        _factories[languageId];
    if (factory == null || factory.isResolved) {
      // no factory or factory.resolve already finished
      return null;
    }

    await factory.resolve();

    return get(languageId);
  }

  /// 1:1: `public isResolved(languageId: string): boolean`
  bool isResolved(String languageId) {
    final TSupport? tokenizationSupport = get(languageId);
    if (tokenizationSupport != null) {
      return true;
    }

    final TokenizationSupportFactoryData<TSupport>? factory =
        _factories[languageId];
    if (factory == null || factory.isResolved) {
      return true;
    }

    return false;
  }

  /// 1:1: `public setColorMap(colorMap: Color[]): void`
  void setColorMap(List<Color?> colorMap) {
    _colorMap = colorMap;
    _onDidChange.fire(TokenizationSupportChangedEvent(
      changedLanguages: _tokenizationSupports.keys.toList(),
      changedColorMap: true,
    ));
  }

  /// 1:1: `public getColorMap(): Color[] | null`
  List<Color?>? getColorMap() => _colorMap;

  /// 1:1: `public getDefaultBackground(): Color | null`
  Color? getDefaultBackground() {
    final List<Color?>? colorMap = _colorMap;
    if (colorMap != null && colorMap.length > ColorId.defaultBackground) {
      return colorMap[ColorId.defaultBackground];
    }
    return null;
  }
}

/// 1:1: `class TokenizationSupportFactoryData<TSupport> extends Disposable`
class TokenizationSupportFactoryData<TSupport extends Object>
    extends Disposable {
  bool _isDisposed = false;
  Future<void>? _resolvePromise;
  bool _isResolved = false;

  /// 1:1: `public get isResolved(): boolean`
  bool get isResolved => _isResolved;

  TokenizationSupportFactoryData(
    this._registry,
    this._languageId,
    this._factory,
  ) : super();

  final TokenizationRegistry<TSupport> _registry;
  final String _languageId;
  final LazyTokenizationSupport<TSupport> _factory;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// 1:1: `public async resolve(): Promise<void>`
  Future<void> resolve() async {
    _resolvePromise ??= _create();
    return _resolvePromise!;
  }

  /// 1:1: `private async _create(): Promise<void>`
  Future<void> _create() async {
    final TSupport? value = await _factory.tokenizationSupport;
    _isResolved = true;
    if (value != null && !_isDisposed) {
      register(_registry.register(_languageId, value));
    }
  }
}
