// 1:1 port of vs/platform/product/common/product.ts
//
// The TS default export is a module-level `IProductConfiguration` object.
// The Dart carrier is the same runtime shape: a mutable Map resolved once at
// module evaluation, with `globalThis.*` values supplied by injectable
// providers (same convention as amdX.dart / webWorkerServiceImpl.dart).

import '../../../base/common/process.dart' as process;

/// 1:1: `globalThis.vscode.context.configuration()`.
/// A non-null provider means `vscode.context` exists; returning `null` models
/// the TS case where `configuration()` yields `undefined` (which throws).
Map<String, Object?>? Function()? vscodeContextConfigurationProvider;

/// 1:1: `globalThis._VSCODE_PRODUCT_JSON`.
Map<String, Object?>? Function()? vscodeProductJsonProvider;

/// 1:1: `globalThis._VSCODE_PACKAGE_JSON`.
Map<String, Object?>? Function()? vscodePackageJsonProvider;

Map<String, Object?>? _product;

/// 1:1: `export default product`.
Map<String, Object?> get product => _product ??= _resolveProduct();

/// Test hook: reset the module-level `product` between module evaluations.
void resetProductForTest() {
  _product = null;
}

bool _jsFalsy(Object? value) {
  if (value == null) return true;
  if (value is bool) return !value;
  if (value is num) return value == 0;
  if (value is String) return value.isEmpty;
  return false;
}

String _jsString(Object? value) => value == null ? 'undefined' : value.toString();

/// 1:1: module-evaluation branch that resolves the default product object.
Map<String, Object?> _resolveProduct() {
  final Map<String, Object?>? configuration =
      vscodeContextConfigurationProvider?.call();
  if (vscodeContextConfigurationProvider != null) {
    final Object? configured = configuration?['product'];
    if (configured is Map<String, Object?>) return configured;
    throw StateError(
        'Sandbox: unable to resolve product configuration from preload script.');
  }

  final Map<String, Object?>? productJson = vscodeProductJsonProvider?.call();
  final Map<String, Object?>? packageJson = vscodePackageJsonProvider?.call();
  if (productJson != null && packageJson != null) {
    if (process.env['VSCODE_DEV'] != null) {
      productJson['nameShort'] = '${_jsString(productJson['nameShort'])} Dev';
      productJson['nameLong'] = '${_jsString(productJson['nameLong'])} Dev';
      productJson['dataFolderName'] =
          '${_jsString(productJson['dataFolderName'])}-dev';
      final Object? serverDataFolderName = productJson['serverDataFolderName'];
      if (_jsFalsy(serverDataFolderName)) {
        productJson.remove('serverDataFolderName');
      } else {
        productJson['serverDataFolderName'] =
            '${_jsString(serverDataFolderName)}-dev';
      }
    }

    if (_jsFalsy(productJson['version'])) {
      productJson['version'] = packageJson['version'];
    }

    if (_jsFalsy(productJson['copilotVersions'])) {
      final String? sdk = _getDependencyVersion(
          packageJson, '@microsoft/copilot-sdk');
      final Object? runtime = packageJson['copilotRuntimeVersion'];
      if (runtime != null && sdk != null) {
        productJson['copilotVersions'] = <String, Object?>{
          'runtime': runtime,
          'sdk': sdk,
        };
      }
    }
    return productJson;
  }

  // Web environment or unknown: build-time insertion is a comment in the
  // TypeScript source, so the object starts empty and receives OSS defaults.
  final Map<String, Object?> p = <String, Object?>{};
  p.addAll(<String, Object?>{
    'version': '1.104.0-dev',
    'nameShort': 'Code - OSS Dev',
    'nameLong': 'Code - OSS Dev',
    'applicationName': 'code-oss',
    'dataFolderName': '.vscode-oss',
    'urlProtocol': 'code-oss',
    'reportIssueUrl': 'https://github.com/microsoft/vscode/issues/new',
    'licenseName': 'MIT',
    'licenseUrl':
        'https://github.com/microsoft/vscode/blob/main/LICENSE.txt',
    'serverLicenseUrl':
        'https://github.com/microsoft/vscode/blob/main/LICENSE.txt',
    'defaultChatAgent': <String, Object?>{
      'extensionId': 'GitHub.copilot',
      'chatExtensionId': 'GitHub.copilot-chat',
      'provider': <String, Object?>{
        'default': <String, Object?>{'id': 'github', 'name': 'GitHub'},
        'enterprise': <String, Object?>{
          'id': 'github-enterprise',
          'name': 'GitHub Enterprise',
        },
      },
      'providerScopes': <Object?>[],
    },
  });
  return p;
}

/// Source-internal `getDependencyVersion` (not exported in TS).
String? _getDependencyVersion(
    Map<String, Object?> packageConfiguration, String packageName) {
  final Object? dependencies = packageConfiguration['dependencies'];
  if (dependencies is! Map) return null;
  final Object? version = dependencies[packageName];
  if (version is! String) return null;
  return version.replaceFirst(RegExp(r'^[~^]'), '');
}
