// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/platform.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. The JS environment detection branches
// (`nodeProcess` / `navigator` / `globalThis`) have no literal Dart equivalent;
// Flutter's `dart:io.Platform` provides the OS values, while the NLS config is
// fed through `nls.dart` setters. All exported constants, enums, namespaces,
// their values and control flow are preserved. `setTimeout0` uses a microtask
// (Dart has no postMessage fast path).
// ---------------------------------------------------------------------------

import 'dart:async';
import 'dart:io' show Platform;

import '../../nls.dart' as nls;

const String LANGUAGE_DEFAULT = 'en';

/// Environment-like process interface (TS INodeProcess).
class INodeProcess {
  final String platform;
  final String arch;
  final Map<String, String?> env;
  INodeProcess({required this.platform, required this.arch, required this.env});

  String cwd() => '';
}

/// A process environment (TS IProcessEnvironment).
typedef IProcessEnvironment = Map<String, String?>;

// Resolve host OS via dart:io. Flutter targets: native desktop/mobile or web.
final String _hostPlatform = (() {
  try {
    if (Platform.isWindows) return 'win32';
    if (Platform.isMacOS) return 'darwin';
    if (Platform.isLinux) return 'linux';
    if (Platform.isAndroid) return 'linux';
    if (Platform.isIOS) return 'darwin';
  } catch (_) {
    // Platform unavailable on web.
  }
  return 'linux';
})();

bool _isWindows = _hostPlatform == 'win32';
bool _isMacintosh = _hostPlatform == 'darwin';
bool _isLinux = _hostPlatform == 'linux';
bool _isLinuxSnap = false;
bool _isChromeOS = false;
bool _isNative = true;
bool _isWeb = false;
bool _isElectron = false;
bool _isIOS = false;
bool _isCI = false;
bool _isMobile = false;
String? _locale = LANGUAGE_DEFAULT;
String _language = LANGUAGE_DEFAULT;
String _platformLocale = LANGUAGE_DEFAULT;
String _regionalLocale = LANGUAGE_DEFAULT;
String? _translationsConfigFile;
String? _userAgent;

// Native environment (top-level statements folded into an initializer).
final bool _nativeInit = _initNative();

bool _initNative() {
  _locale = LANGUAGE_DEFAULT;
  _language = LANGUAGE_DEFAULT;
  final Object? rawNlsConfig = _readNlsConfig();
  if (rawNlsConfig is Map) {
    _locale = rawNlsConfig['userLocale'] as String? ?? _locale;
    _platformLocale = rawNlsConfig['osLocale'] as String? ?? _platformLocale;
    _regionalLocale = (rawNlsConfig['regionalLocale'] as String?) ?? (rawNlsConfig['osLocale'] as String?) ?? _regionalLocale;
    _language = (rawNlsConfig['resolvedLanguage'] as String?) ?? LANGUAGE_DEFAULT;
    _translationsConfigFile = (rawNlsConfig['languagePack'] as Map?)?['translationsConfigFile'] as String?;
  }
  _isNative = true;
  return true;
}

Map? _readNlsConfig() {
  // In VS Code this is JSON.parse(process.env['VSCODE_NLS_CONFIG']).
  // Flutter has no such env-provided config by default; nls.dart holds the
  // injected language, so mirror the source branch when one was set.
  final String? injectedLanguage = nls.getNLSLanguage();
  if (injectedLanguage == null) return null;
  return <String, dynamic>{
    'userLocale': injectedLanguage,
    'osLocale': injectedLanguage,
    'resolvedLanguage': injectedLanguage,
  };
}

/// Exposes that the native initialization branch ran (source had a top-level
/// `if (true)` block with no name; this getter makes it observable in Dart).
bool get nativeInitialized => _nativeInit;

class Platform_ {
  const Platform_._();

  static const int Web = 0;
  static const int Mac = 1;
  static const int Linux = 2;
  static const int Windows = 3;
}

/// TS `Platform` const enum -> [Platform_] (renamed: `Platform` is used by the
/// exported [platform] flag in Dart; see note at bottom).
typedef PlatformName = String;

String PlatformToString(int platform) {
  switch (platform) {
    case 0:
      return 'Web';
    case 1:
      return 'Mac';
    case 2:
      return 'Linux';
    case 3:
      return 'Windows';
  }
  return 'Web';
}

final int _platform = (() {
  if (_isMacintosh) return 1;
  if (_isWindows) return 3;
  if (_isLinux) return 2;
  return 0;
})();

/// TS computes these flags once at module load from the host environment. The
/// Dart port mirrors that, but a few ports (dnd.ts web/native branches) need
/// both branches exercisable in tests, so the two environment flags are
/// injectable — same pattern as `keyboardEvent.dart`'s browser-flag overrides.
/// `null` clears the override and restores the detected value.
bool? _isNativeOverride;
bool? _isWebOverride;

bool get isNative => _isNativeOverride ?? _isNative;
set isNativeOverride(bool? value) {
  _isNativeOverride = value;
}

bool get isWeb => _isWebOverride ?? _isWeb;
set isWebOverride(bool? value) {
  _isWebOverride = value;
}

final bool isWindows = _isWindows;
final bool isMacintosh = _isMacintosh;
final bool isLinux = _isLinux;
final bool isLinuxSnap = _isLinuxSnap;
final bool isChromeOS = _isChromeOS;
final bool isElectron = _isElectron;
final bool isWebWorker = false;
final Object? webWorkerOrigin = null;
final bool isIOS = _isIOS;
final bool isMobile = _isMobile;

/// Whether we run inside a CI environment (GH actions / Azure Pipelines).
final bool isCI = _isCI;
final int platform = _platform;
final String? userAgent = _userAgent;

/// UI language, all lower case (e.g. zh-tw, de).
final String language = _language;

class Language {
  const Language._();

  static String value() => language;

  static bool isDefaultVariant() {
    if (language.length == 2) {
      return language == 'en';
    } else if (language.length >= 3) {
      return language[0] == 'e' && language[1] == 'n' && language[2] == '-';
    } else {
      return false;
    }
  }

  static bool isDefault() => language == 'en';
}

final String? locale = _locale;
final String platformLocale = _platformLocale;
final String regionalLocale = _regionalLocale;
final String? translationsConfigFile = _translationsConfigFile;
final bool setTimeout0IsFaster = false;

/// Works like `setTimeout(0)` via a microtask.
void Function(void Function()) setTimeout0 = (callback) {
  scheduleMicrotask(callback);
};

class OperatingSystem {
  const OperatingSystem._();

  static const int Windows = 1;
  static const int Macintosh = 2;
  static const int Linux = 3;
}

final int OS = (_isMacintosh || _isIOS)
    ? OperatingSystem.Macintosh
    : (_isWindows ? OperatingSystem.Windows : OperatingSystem.Linux);

bool _isLittleEndian = true;
bool _isLittleEndianComputed = false;

bool isLittleEndian() {
  if (!_isLittleEndianComputed) {
    _isLittleEndianComputed = true;
    // Dart integers are arbitrary precision; host endianness is not observable.
    // Preserve the source value/control flow with the common little-endian default.
  }
  return _isLittleEndian;
}

final bool isChrome = (userAgent != null && userAgent!.contains('Chrome'));
final bool isFirefox = (userAgent != null && userAgent!.contains('Firefox'));
final bool isSafari = (!isChrome && (userAgent != null && userAgent!.contains('Safari')));
final bool isEdge = (userAgent != null && userAgent!.contains('Edg/'));
final bool isAndroid = (userAgent != null && userAgent!.contains('Android'));
final bool hasElectronUserAgent = (userAgent != null && userAgent!.contains('Electron'));

bool isTahoeOrNewer(String osVersion) => double.tryParse(osVersion)! >= 25;

// NOTE: TS `const enum Platform` -> class `Platform_` (renamed because Dart's
// `platform` top-level flag occupies `Platform` naming context only in TS; here
// the rename avoids confusion with dart:io.Platform). Every enum value, exported
// constant and namespace member is preserved.
