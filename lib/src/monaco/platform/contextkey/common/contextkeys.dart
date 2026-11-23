// 1:1 translated from platform/contextkey/common/contextkeys.ts
import '../../../base/common/platform.dart' show isIOS, isLinux, isMacintosh, isMobile, isWeb, isWindows, isChromeOS;
import '../../../nls.dart' show localize;
import 'contextkey.dart' show RawContextKey;

final IsMacContext = RawContextKey<bool>('isMac', isMacintosh, localize('isMac', "Whether the operating system is macOS"));
final IsLinuxContext = RawContextKey<bool>('isLinux', isLinux, localize('isLinux', "Whether the operating system is Linux"));
final IsWindowsContext = RawContextKey<bool>('isWindows', isWindows, localize('isWindows', "Whether the operating system is Windows"));
final IsChromeOSContext = RawContextKey<bool>('isChromeOS', isChromeOS, localize('isChromeOS', "Whether the operating system is ChromeOS"));
final IsWebContext = RawContextKey<bool>('isWeb', isWeb, localize('isWeb', "Whether the platform is a web browser"));
final IsMacNativeContext = RawContextKey<bool>('isMacNative', isMacintosh && !isWeb, localize('isMacNative', "Whether the operating system is macOS on a non-browser platform"));
final IsIOSContext = RawContextKey<bool>('isIOS', isIOS, localize('isIOS', "Whether the operating system is iOS"));
final IsMobileContext = RawContextKey<bool>('isMobile', isMobile, localize('isMobile', "Whether the platform is a mobile web browser"));
final IsDevelopmentContext = RawContextKey<bool>('isDevelopment', false, true);
final ProductQualityContext = RawContextKey<String>('productQualityType', '', localize('productQualityType', "Quality type of VS Code"));
final InputFocusedContextKey = 'inputFocus';
final InputFocusedContext = RawContextKey<bool>(InputFocusedContextKey, false, localize('inputFocus', "Whether keyboard focus is inside an input box"));
