// 1:1 port of vs/platform/opener/test/common/nullOpenerService.ts
import '../../../../base/common/lifecycle.dart' as lifecycle;
import '../../../../base/common/uri.dart' show URI;
import '../../common/opener.dart' show IResolvedExternalUri;

/// 1:1: `export const NullOpenerService = Object.freeze<IOpenerService>({...})`.
/// Dart `const` gives the same immutability guarantee for this object.
const NullOpenerService = _NullOpenerService();

/// Carrier for the exported object literal.
class _NullOpenerService {
  const _NullOpenerService();

  /// 1:1: `_serviceBrand: undefined`.
  Object? get serviceBrand => null;

  lifecycle.IDisposable registerOpener() => lifecycle.Disposable.none;

  lifecycle.IDisposable registerValidator() => lifecycle.Disposable.none;

  lifecycle.IDisposable registerExternalUriResolver() =>
      lifecycle.Disposable.none;

  void setDefaultExternalOpener() {}

  lifecycle.IDisposable registerExternalOpener() => lifecycle.Disposable.none;

  Future<bool> open([Object? resource, Object? options]) async => false;

  Future<IResolvedExternalUri> resolveExternalUri(URI uri) async =>
      _NullResolvedExternalUri(uri);
}

class _NullResolvedExternalUri implements IResolvedExternalUri {
  const _NullResolvedExternalUri(this.resolved);

  @override
  final URI resolved;

  @override
  void dispose() {}
}
