// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/process.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. The three JS environments (sandbox/node/web)
// collapse to a single Flutter process: OS/platform/arch come from `platform.dart`
// and `dart:io.Platform`; env is an injectable map. Exported `cwd`/`env`/
// `platform`/`arch` and their semantics are preserved.
// ---------------------------------------------------------------------------

import 'dart:io' show Platform, Directory;

import './platform.dart' as plat;

class _SafeProcess {
  final Map<String, String?> env;
  _SafeProcess(this.env);

  String cwd() {
    try {
      return Directory.current.path;
    } catch (_) {
      return '/';
    }
  }

  String get platform => plat.isWindows
      ? 'win32'
      : (plat.isMacintosh ? 'darwin' : 'linux');

  String get arch {
    try {
      return Platform.isAndroid ? 'arm64' : 'x64';
    } catch (_) {
      return 'x64';
    }
  }
}

final _SafeProcess safeProcess = _SafeProcess(<String, String?>{});

/// Safe access to cwd (web hardcodes `/`).
final String Function() cwd = () => safeProcess.cwd();

/// Safe access to env (web hardcodes `{}`).
final Map<String, String?> env = safeProcess.env;

/// Safe access to platform.
final String platform = safeProcess.platform;

/// Safe access to arch (web = null; Dart models as a String).
final String arch = safeProcess.arch;
