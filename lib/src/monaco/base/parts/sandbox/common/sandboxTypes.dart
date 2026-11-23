// 1:1 port of vscode/src/vs/base/parts/sandbox/common/sandboxTypes.ts
// Type-only module: no runtime exports in TS; Dart carriers mirror the
// interfaces exactly, with optional TS fields mapped to nullable fields.

import '../../../common/platform.dart' show IProcessEnvironment;
import '../../../common/product.dart' show IProductConfiguration;

/// 1:1: anonymous `nls` object type declared inside `ISandboxConfiguration`.
class SandboxConfigurationNls {
  final List<String> messages;
  final String? language;

  SandboxConfigurationNls({required this.messages, this.language});
}

/// 1:1: `export interface ISandboxConfiguration`
class ISandboxConfiguration {
  final int windowId;
  final String appRoot;
  final IProcessEnvironment userEnv;
  final IProductConfiguration product;
  final num? zoomLevel;
  final String? codeCachePath;
  final SandboxConfigurationNls nls;
  final List<String>? cssModules;

  ISandboxConfiguration({
    required this.windowId,
    required this.appRoot,
    required this.userEnv,
    required this.product,
    this.zoomLevel,
    this.codeCachePath,
    required this.nls,
    this.cssModules,
  });
}
