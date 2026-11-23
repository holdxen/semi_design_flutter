// 1:1 port of vs/amdX.ts
// AMD module importer. Browser/Node globals (`globalThis.define`, product JSON,
// `document`, `self`, `import()`) are carried by replaceable top-level hooks so
// the pure logic (path resolution / cache / external define) stays 1:1 and
// testable in Flutter. DOM/Node script-loading branches are bridged via
// [amdLoadScript] rather than reimplementing browser APIs.
import 'dart:async' show Completer;

import 'base/common/network.dart'
    show
        AppResourcePath,
        FileAccess,
        nodeModulesAsarPath,
        nodeModulesPath;
import 'base/common/platform.dart'
    as platform show hasElectronUserAgent, isElectron, isWebWorker;
import 'base/common/product.dart' show IProductConfiguration;
import 'base/common/uuid.dart' show generateUuid;

/// 1:1: `class DefineCall`
class DefineCall {
  final String? id;
  final List<String>? dependencies;
  final Object? callback;
  DefineCall(this.id, this.dependencies, this.callback);
}

/// 1:1: `enum AMDModuleImporterState`
class AMDModuleImporterState {
  static const int Uninitialized = 1;
  static const int InitializedInternal = 2;
  static const int InitializedExternal = 3;
  const AMDModuleImporterState._();
}

// ---- replaceable environment carriers (TS `globalThis.*` / module APIs) ----

/// 1:1: `globalThis.define` — set to a function to select the external-AMD path.
void Function(String id, List<Object?> deps, void Function(Object? result) cb)?
    amdDefine;

/// 1:1: `globalThis._VSCODE_PRODUCT_JSON` (product configuration).
Map<String, Object?>? amdProductJson;

/// 1:1: `globalThis.vscode?.context?.configuration()?.product` fallback.
Map<String, Object?>? Function()? amdVscodeContextProduct;

/// 1:1: `platform.isElectron / isWebWorker / hasElectronUserAgent`.
bool Function() amdIsElectron = () => platform.isElectron;
bool Function() amdIsWebWorker = () => platform.isWebWorker;
bool Function() amdHasElectronUserAgent = () => platform.hasElectronUserAgent;

/// 1:1: `FileAccess.asBrowserUri(resourcePath).toString(true)`.
String Function(String resourcePath) amdAsBrowserUri = (resourcePath) =>
    FileAccess.asBrowserUri(resourcePath).toString(true);

/// Bridge for the internal script-loading branches (renderer/worker/nodeJS).
/// Returns the last received [DefineCall], or null when none was received.
Future<DefineCall?> Function(String scriptSrc)? amdLoadScript;

/// 1:1: `console.warn` bridge for the "Did not receive a define call" path.
void Function(String message)? amdWarn;

bool _truthy(Object? v) =>
    v == null ? false : (v is bool ? v : (v is String ? v.isNotEmpty : true));

/// 1:1: `class AMDModuleImporter`
class AMDModuleImporter {
  static final AMDModuleImporter INSTANCE = AMDModuleImporter();

  final List<DefineCall> _defineCalls = <DefineCall>[];
  Function? _define;
  int _state = AMDModuleImporterState.Uninitialized;

  AMDModuleImporter();

  /// 1:1: `_initialize()`
  void _initialize() {
    if (_state == AMDModuleImporterState.Uninitialized) {
      if (amdDefine != null) {
        _state = AMDModuleImporterState.InitializedExternal;
        return;
      }
    } else {
      return;
    }
    _state = AMDModuleImporterState.InitializedInternal;
    void define(id, dependencies, callback) {
      if (id is! String) {
        callback = dependencies;
        dependencies = id;
        id = null;
      }
      if (dependencies is! List) {
        callback = dependencies;
        dependencies = null;
      }
      _defineCalls.add(DefineCall(
        id as String?,
        dependencies == null ? null : List<String>.from(dependencies),
        callback,
      ));
    }
    _define = define;
    // Renderer/worker keep `define` global; nodeJS installs it only while a
    // script runs (bridged by [amdLoadScript]) — no persistent global in Dart.
  }

  /// 1:1: `async load<T>(scriptSrc)`
  Future<T> load<T>(String scriptSrc) async {
    _initialize();

    if (_state == AMDModuleImporterState.InitializedExternal) {
      final completer = Completer<T>();
      final tmpModuleId = generateUuid();
      amdDefine!(
        tmpModuleId,
        <Object?>[scriptSrc],
        (Object? moduleResult) => completer.complete(moduleResult as T),
      );
      return completer.future;
    }

    final loader = amdLoadScript;
    final defineCall = loader == null ? null : await loader(scriptSrc);
    if (defineCall == null) {
      (amdWarn ?? (m) => null)('Did not receive a define call from script $scriptSrc');
      return null as T;
    }

    final exports = <String, Object?>{};
    final dependencyObjs = <Object?>[];
    final dependencyModules = <String>[];

    if (defineCall.dependencies != null) {
      for (final mod in defineCall.dependencies!) {
        if (mod == 'exports') {
          dependencyObjs.add(exports);
        } else {
          dependencyModules.add(mod);
        }
      }
    }
    if (dependencyModules.isNotEmpty) {
      throw StateError(
        'Cannot resolve dependencies for script $scriptSrc. '
        'The dependencies are: ${dependencyModules.join(', ')}',
      );
    }
    final callback = defineCall.callback;
    if (callback is Function) {
      return (Function.apply(callback, dependencyObjs) ?? exports) as T;
    }
    return callback as T;
  }

  /// 1:1: `get defineCalls` bridge for tests of the internal define path.
  List<DefineCall> get defineCalls => List<DefineCall>.from(_defineCalls);

  /// 1:1: internal `define` handler (installed by [amdLoadScript] in nodeJS).
  Function? get define => _define;
}

/// 1:1: `const cache = new Map<string, Promise<any>>()`
final Map<String, Future<Object?>> _cache = <String, Future<Object?>>{};

bool _isBuiltFrom(Map<String, Object?>? product) =>
    _truthy(product == null ? null : product['commit']);

Map<String, Object?>? _effectiveProduct() =>
    amdProductJson ?? amdVscodeContextProduct?.call();

/// 1:1: `async importAMDNodeModule<T>(nodeModuleName, pathInsideNodeModule, isBuilt?)`
Future<T> importAMDNodeModule<T>(
  String nodeModuleName,
  String pathInsideNodeModule, [
  bool? isBuilt,
]) async {
  final built = isBuilt ?? _isBuiltFrom(_effectiveProduct());

  final nodeModulePath = pathInsideNodeModule.isNotEmpty
      ? '$nodeModuleName/$pathInsideNodeModule'
      : nodeModuleName;
  if (_cache.containsKey(nodeModulePath)) {
    return _cache[nodeModulePath]! as Future<T>;
  }

  late final String scriptSrc;
  if (RegExp(r'^\w[\w\d+.-]*://').hasMatch(nodeModulePath)) {
    // looks like a URL
    scriptSrc = nodeModulePath;
  } else {
    final useASAR = built &&
        (amdIsElectron() ||
            (amdIsWebWorker() && amdHasElectronUserAgent()));
    final actualNodeModulesPath =
        useASAR ? nodeModulesAsarPath : nodeModulesPath;
    final AppResourcePath resourcePath =
        '$actualNodeModulesPath/$nodeModulePath';
    scriptSrc = amdAsBrowserUri(resourcePath);
  }
  final Future<T> result = AMDModuleImporter.INSTANCE.load<T>(scriptSrc);
  _cache[nodeModulePath] = result as Future<Object?>;
  return result;
}

/// 1:1: `resolveAmdNodeModulePath(nodeModuleName, pathInsideNodeModule)`
String resolveAmdNodeModulePath(
    String nodeModuleName, String pathInsideNodeModule) {
  final built = _isBuiltFrom(_effectiveProduct());
  final useASAR = built &&
      (amdIsElectron() || (amdIsWebWorker() && amdHasElectronUserAgent()));

  final nodeModulePath = '$nodeModuleName/$pathInsideNodeModule';
  final actualNodeModulesPath = useASAR ? nodeModulesAsarPath : nodeModulesPath;
  final AppResourcePath resourcePath = '$actualNodeModulesPath/$nodeModulePath';
  return amdAsBrowserUri(resourcePath);
}

/// Carrier bridge mirroring `IProductConfiguration` usage in the TS source.
typedef AmdProductConfiguration = IProductConfiguration;
