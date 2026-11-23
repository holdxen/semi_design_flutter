/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

// 1:1 port of vs/base/common/keyCodes.ts
// TypeScript `const enum` members are inlined by the compiler and have no runtime object.
// Expanded here to `class + static const int` with identical numeric values, matching the
// treatment of all other `const enum`s in this port.

/// Virtual Key Codes — 1:1 from `const enum KeyCode` (implicit values expanded).
class KeyCode {
  static const int DependsOnKbLayout = -1;
  static const int Unknown = 0;
  static const int Backspace = 1;
  static const int Tab = 2;
  static const int Enter = 3;
  static const int Shift = 4;
  static const int Ctrl = 5;
  static const int Alt = 6;
  static const int PauseBreak = 7;
  static const int CapsLock = 8;
  static const int Escape = 9;
  static const int Space = 10;
  static const int PageUp = 11;
  static const int PageDown = 12;
  static const int End = 13;
  static const int Home = 14;
  static const int LeftArrow = 15;
  static const int UpArrow = 16;
  static const int RightArrow = 17;
  static const int DownArrow = 18;
  static const int Insert = 19;
  static const int Delete = 20;
  static const int Digit0 = 21;
  static const int Digit1 = 22;
  static const int Digit2 = 23;
  static const int Digit3 = 24;
  static const int Digit4 = 25;
  static const int Digit5 = 26;
  static const int Digit6 = 27;
  static const int Digit7 = 28;
  static const int Digit8 = 29;
  static const int Digit9 = 30;
  static const int KeyA = 31;
  static const int KeyB = 32;
  static const int KeyC = 33;
  static const int KeyD = 34;
  static const int KeyE = 35;
  static const int KeyF = 36;
  static const int KeyG = 37;
  static const int KeyH = 38;
  static const int KeyI = 39;
  static const int KeyJ = 40;
  static const int KeyK = 41;
  static const int KeyL = 42;
  static const int KeyM = 43;
  static const int KeyN = 44;
  static const int KeyO = 45;
  static const int KeyP = 46;
  static const int KeyQ = 47;
  static const int KeyR = 48;
  static const int KeyS = 49;
  static const int KeyT = 50;
  static const int KeyU = 51;
  static const int KeyV = 52;
  static const int KeyW = 53;
  static const int KeyX = 54;
  static const int KeyY = 55;
  static const int KeyZ = 56;
  static const int Meta = 57;
  static const int ContextMenu = 58;
  static const int F1 = 59;
  static const int F2 = 60;
  static const int F3 = 61;
  static const int F4 = 62;
  static const int F5 = 63;
  static const int F6 = 64;
  static const int F7 = 65;
  static const int F8 = 66;
  static const int F9 = 67;
  static const int F10 = 68;
  static const int F11 = 69;
  static const int F12 = 70;
  static const int F13 = 71;
  static const int F14 = 72;
  static const int F15 = 73;
  static const int F16 = 74;
  static const int F17 = 75;
  static const int F18 = 76;
  static const int F19 = 77;
  static const int F20 = 78;
  static const int F21 = 79;
  static const int F22 = 80;
  static const int F23 = 81;
  static const int F24 = 82;
  static const int NumLock = 83;
  static const int ScrollLock = 84;
  static const int Semicolon = 85;
  static const int Equal = 86;
  static const int Comma = 87;
  static const int Minus = 88;
  static const int Period = 89;
  static const int Slash = 90;
  static const int Backquote = 91;
  static const int BracketLeft = 92;
  static const int Backslash = 93;
  static const int BracketRight = 94;
  static const int Quote = 95;
  static const int OEM_8 = 96;
  static const int IntlBackslash = 97;
  static const int Numpad0 = 98;
  static const int Numpad1 = 99;
  static const int Numpad2 = 100;
  static const int Numpad3 = 101;
  static const int Numpad4 = 102;
  static const int Numpad5 = 103;
  static const int Numpad6 = 104;
  static const int Numpad7 = 105;
  static const int Numpad8 = 106;
  static const int Numpad9 = 107;
  static const int NumpadMultiply = 108;
  static const int NumpadAdd = 109;
  static const int NUMPAD_SEPARATOR = 110;
  static const int NumpadSubtract = 111;
  static const int NumpadDecimal = 112;
  static const int NumpadDivide = 113;
  static const int KEY_IN_COMPOSITION = 114;
  static const int ABNT_C1 = 115;
  static const int ABNT_C2 = 116;
  static const int AudioVolumeMute = 117;
  static const int AudioVolumeUp = 118;
  static const int AudioVolumeDown = 119;
  static const int BrowserSearch = 120;
  static const int BrowserHome = 121;
  static const int BrowserBack = 122;
  static const int BrowserForward = 123;
  static const int MediaTrackNext = 124;
  static const int MediaTrackPrevious = 125;
  static const int MediaStop = 126;
  static const int MediaPlayPause = 127;
  static const int LaunchMediaPlayer = 128;
  static const int LaunchMail = 129;
  static const int LaunchApp2 = 130;
  static const int Clear = 131;
  static const int MAX_VALUE = 132;
}

/// keyboardEvent.code — 1:1 from `const enum ScanCode`.
class ScanCode {
  static const int DependsOnKbLayout = -1;
  static const int None = 0;
  static const int Hyper = 1;
  static const int Super = 2;
  static const int Fn = 3;
  static const int FnLock = 4;
  static const int Suspend = 5;
  static const int Resume = 6;
  static const int Turbo = 7;
  static const int Sleep = 8;
  static const int WakeUp = 9;
  static const int KeyA = 10;
  static const int KeyB = 11;
  static const int KeyC = 12;
  static const int KeyD = 13;
  static const int KeyE = 14;
  static const int KeyF = 15;
  static const int KeyG = 16;
  static const int KeyH = 17;
  static const int KeyI = 18;
  static const int KeyJ = 19;
  static const int KeyK = 20;
  static const int KeyL = 21;
  static const int KeyM = 22;
  static const int KeyN = 23;
  static const int KeyO = 24;
  static const int KeyP = 25;
  static const int KeyQ = 26;
  static const int KeyR = 27;
  static const int KeyS = 28;
  static const int KeyT = 29;
  static const int KeyU = 30;
  static const int KeyV = 31;
  static const int KeyW = 32;
  static const int KeyX = 33;
  static const int KeyY = 34;
  static const int KeyZ = 35;
  static const int Digit1 = 36;
  static const int Digit2 = 37;
  static const int Digit3 = 38;
  static const int Digit4 = 39;
  static const int Digit5 = 40;
  static const int Digit6 = 41;
  static const int Digit7 = 42;
  static const int Digit8 = 43;
  static const int Digit9 = 44;
  static const int Digit0 = 45;
  static const int Enter = 46;
  static const int Escape = 47;
  static const int Backspace = 48;
  static const int Tab = 49;
  static const int Space = 50;
  static const int Minus = 51;
  static const int Equal = 52;
  static const int BracketLeft = 53;
  static const int BracketRight = 54;
  static const int Backslash = 55;
  static const int IntlHash = 56;
  static const int Semicolon = 57;
  static const int Quote = 58;
  static const int Backquote = 59;
  static const int Comma = 60;
  static const int Period = 61;
  static const int Slash = 62;
  static const int CapsLock = 63;
  static const int F1 = 64;
  static const int F2 = 65;
  static const int F3 = 66;
  static const int F4 = 67;
  static const int F5 = 68;
  static const int F6 = 69;
  static const int F7 = 70;
  static const int F8 = 71;
  static const int F9 = 72;
  static const int F10 = 73;
  static const int F11 = 74;
  static const int F12 = 75;
  static const int PrintScreen = 76;
  static const int ScrollLock = 77;
  static const int Pause = 78;
  static const int Insert = 79;
  static const int Home = 80;
  static const int PageUp = 81;
  static const int Delete = 82;
  static const int End = 83;
  static const int PageDown = 84;
  static const int ArrowRight = 85;
  static const int ArrowLeft = 86;
  static const int ArrowDown = 87;
  static const int ArrowUp = 88;
  static const int NumLock = 89;
  static const int NumpadDivide = 90;
  static const int NumpadMultiply = 91;
  static const int NumpadSubtract = 92;
  static const int NumpadAdd = 93;
  static const int NumpadEnter = 94;
  static const int Numpad1 = 95;
  static const int Numpad2 = 96;
  static const int Numpad3 = 97;
  static const int Numpad4 = 98;
  static const int Numpad5 = 99;
  static const int Numpad6 = 100;
  static const int Numpad7 = 101;
  static const int Numpad8 = 102;
  static const int Numpad9 = 103;
  static const int Numpad0 = 104;
  static const int NumpadDecimal = 105;
  static const int IntlBackslash = 106;
  static const int ContextMenu = 107;
  static const int Power = 108;
  static const int NumpadEqual = 109;
  static const int F13 = 110;
  static const int F14 = 111;
  static const int F15 = 112;
  static const int F16 = 113;
  static const int F17 = 114;
  static const int F18 = 115;
  static const int F19 = 116;
  static const int F20 = 117;
  static const int F21 = 118;
  static const int F22 = 119;
  static const int F23 = 120;
  static const int F24 = 121;
  static const int Open = 122;
  static const int Help = 123;
  static const int Select = 124;
  static const int Again = 125;
  static const int Undo = 126;
  static const int Cut = 127;
  static const int Copy = 128;
  static const int Paste = 129;
  static const int Find = 130;
  static const int AudioVolumeMute = 131;
  static const int AudioVolumeUp = 132;
  static const int AudioVolumeDown = 133;
  static const int NumpadComma = 134;
  static const int IntlRo = 135;
  static const int KanaMode = 136;
  static const int IntlYen = 137;
  static const int Convert = 138;
  static const int NonConvert = 139;
  static const int Lang1 = 140;
  static const int Lang2 = 141;
  static const int Lang3 = 142;
  static const int Lang4 = 143;
  static const int Lang5 = 144;
  static const int Abort = 145;
  static const int Props = 146;
  static const int NumpadParenLeft = 147;
  static const int NumpadParenRight = 148;
  static const int NumpadBackspace = 149;
  static const int NumpadMemoryStore = 150;
  static const int NumpadMemoryRecall = 151;
  static const int NumpadMemoryClear = 152;
  static const int NumpadMemoryAdd = 153;
  static const int NumpadMemorySubtract = 154;
  static const int NumpadClear = 155;
  static const int NumpadClearEntry = 156;
  static const int ControlLeft = 157;
  static const int ShiftLeft = 158;
  static const int AltLeft = 159;
  static const int MetaLeft = 160;
  static const int ControlRight = 161;
  static const int ShiftRight = 162;
  static const int AltRight = 163;
  static const int MetaRight = 164;
  static const int BrightnessUp = 165;
  static const int BrightnessDown = 166;
  static const int MediaPlay = 167;
  static const int MediaRecord = 168;
  static const int MediaFastForward = 169;
  static const int MediaRewind = 170;
  static const int MediaTrackNext = 171;
  static const int MediaTrackPrevious = 172;
  static const int MediaStop = 173;
  static const int Eject = 174;
  static const int MediaPlayPause = 175;
  static const int MediaSelect = 176;
  static const int LaunchMail = 177;
  static const int LaunchApp2 = 178;
  static const int LaunchApp1 = 179;
  static const int SelectTask = 180;
  static const int LaunchScreenSaver = 181;
  static const int BrowserSearch = 182;
  static const int BrowserHome = 183;
  static const int BrowserBack = 184;
  static const int BrowserForward = 185;
  static const int BrowserStop = 186;
  static const int BrowserRefresh = 187;
  static const int BrowserFavorites = 188;
  static const int ZoomToggle = 189;
  static const int MailReply = 190;
  static const int MailForward = 191;
  static const int MailSend = 192;
  static const int MAX_VALUE = 193;
}

/// 1:1: `class KeyCodeStrMap`
class KeyCodeStrMap {
  final List<String> _keyCodeToStr = <String>[];
  final Map<String, int> _strToKeyCode = <String, int>{};

  void define(int keyCode, String str) {
    _setAt<String>(_keyCodeToStr, keyCode, '');
    _keyCodeToStr[keyCode] = str;
    _strToKeyCode[str.toLowerCase()] = keyCode;
  }

  String keyCodeToStr(int keyCode) {
    if (keyCode < 0 || keyCode >= _keyCodeToStr.length) return '';
    return _keyCodeToStr[keyCode];
  }

  int strToKeyCode(String str) => _strToKeyCode[str.toLowerCase()] ?? KeyCode.Unknown;
}

final KeyCodeStrMap _uiMap = KeyCodeStrMap();
final KeyCodeStrMap _userSettingsUSMap = KeyCodeStrMap();
final KeyCodeStrMap _userSettingsGeneralMap = KeyCodeStrMap();

/// 1:1: `export const _eventKeyCodeMap`
final List<int> _eventKeyCodeMap = List<int>.filled(230, 0);
/// 1:1: `export const _nativeWindowsKeyCodeToKeyCode`
final Map<String, int> _nativeWindowsKeyCodeToKeyCode = <String, int>{};
/// 1:1: `export const _scanCodeStrToEventKeyCode`
final Map<String, int> _scanCodeStrToEventKeyCode = <String, int>{};
final List<String> _scanCodeIntToStr = <String>[];
final Map<String, int> _scanCodeStrToInt = <String, int>{};
final Map<String, int> _scanCodeLowerCaseStrToInt = <String, int>{};

/// 1:1 public exports — getters trigger the source-equivalent top-level initialization.
List<int> get EVENT_KEY_CODE_MAP { _keyCodesInitialized; return _eventKeyCodeMap; }
Map<String, int> get NATIVE_WINDOWS_KEY_CODE_TO_KEY_CODE { _keyCodesInitialized; return _nativeWindowsKeyCodeToKeyCode; }
Map<String, int> get SCAN_CODE_STR_TO_EVENT_KEY_CODE { _keyCodesInitialized; return _scanCodeStrToEventKeyCode; }
List<int> get IMMUTABLE_CODE_TO_KEY_CODE { _keyCodesInitialized; return _immutableCodeToKeyCode; }
List<int> get IMMUTABLE_KEY_CODE_TO_CODE { _keyCodesInitialized; return _immutableKeyCodeToCode; }

/// 1:1: `export const ScanCodeUtils`
class ScanCodeUtils {
  static int lowerCaseToEnum(String scanCode) { _keyCodesInitialized; return _scanCodeLowerCaseStrToInt[scanCode] ?? ScanCode.None; }
  static int toEnum(String scanCode) { _keyCodesInitialized; return _scanCodeStrToInt[scanCode] ?? ScanCode.None; }
  static String toStringValue(int scanCode) { _keyCodesInitialized; return (scanCode >= 0 && scanCode < _scanCodeIntToStr.length) ? _scanCodeIntToStr[scanCode] : 'None'; }
}

/// 1:1: `export const _immutableCodeToKeyCode`
final List<int> _immutableCodeToKeyCode = <int>[];
/// 1:1: `export const _immutableKeyCodeToCode`
final List<int> _immutableKeyCodeToCode = <int>[];

void _setAt<T>(List<T> list, int index, T value) {
  if (index < 0) return;
  // Source arrays start as `[]`; reading an unseen index yields `undefined` (falsey / 0 / '').
  // Fill gaps with a neutral default, NOT `value` — otherwise `seenKeyCode` would be pre-seen.
  final T fill = value is bool ? false as T : (value is int ? 0 as T : (value is String ? '' as T : value));
  while (list.length <= index) list.add(fill);
  list[index] = value;
}

bool _getBool(List<bool> list, int index) => (index >= 0 && index < list.length) ? list[index] : false;

bool _initKeyCodes() {
  for (int i = 0; i <= ScanCode.MAX_VALUE; i++) {
    _setAt<int>(_immutableCodeToKeyCode, i, KeyCode.DependsOnKbLayout);
  }
  for (int i = 0; i <= KeyCode.MAX_VALUE; i++) {
    _setAt<int>(_immutableKeyCodeToCode, i, ScanCode.DependsOnKbLayout);
  }

  const List<(int, int, String, int, String, int, String, String, String)> mappings = <(int, int, String, int, String, int, String, String, String)>[
  (1, 0, 'None', 0, 'unknown', 0, 'VK_UNKNOWN', '', ''),
  (1, 1, 'Hyper', 0, '', 0, '', '', ''),
  (1, 2, 'Super', 0, '', 0, '', '', ''),
  (1, 3, 'Fn', 0, '', 0, '', '', ''),
  (1, 4, 'FnLock', 0, '', 0, '', '', ''),
  (1, 5, 'Suspend', 0, '', 0, '', '', ''),
  (1, 6, 'Resume', 0, '', 0, '', '', ''),
  (1, 7, 'Turbo', 0, '', 0, '', '', ''),
  (1, 8, 'Sleep', 0, '', 0, 'VK_SLEEP', '', ''),
  (1, 9, 'WakeUp', 0, '', 0, '', '', ''),
  (0, 10, 'KeyA', 31, 'A', 65, 'VK_A', '', ''),
  (0, 11, 'KeyB', 32, 'B', 66, 'VK_B', '', ''),
  (0, 12, 'KeyC', 33, 'C', 67, 'VK_C', '', ''),
  (0, 13, 'KeyD', 34, 'D', 68, 'VK_D', '', ''),
  (0, 14, 'KeyE', 35, 'E', 69, 'VK_E', '', ''),
  (0, 15, 'KeyF', 36, 'F', 70, 'VK_F', '', ''),
  (0, 16, 'KeyG', 37, 'G', 71, 'VK_G', '', ''),
  (0, 17, 'KeyH', 38, 'H', 72, 'VK_H', '', ''),
  (0, 18, 'KeyI', 39, 'I', 73, 'VK_I', '', ''),
  (0, 19, 'KeyJ', 40, 'J', 74, 'VK_J', '', ''),
  (0, 20, 'KeyK', 41, 'K', 75, 'VK_K', '', ''),
  (0, 21, 'KeyL', 42, 'L', 76, 'VK_L', '', ''),
  (0, 22, 'KeyM', 43, 'M', 77, 'VK_M', '', ''),
  (0, 23, 'KeyN', 44, 'N', 78, 'VK_N', '', ''),
  (0, 24, 'KeyO', 45, 'O', 79, 'VK_O', '', ''),
  (0, 25, 'KeyP', 46, 'P', 80, 'VK_P', '', ''),
  (0, 26, 'KeyQ', 47, 'Q', 81, 'VK_Q', '', ''),
  (0, 27, 'KeyR', 48, 'R', 82, 'VK_R', '', ''),
  (0, 28, 'KeyS', 49, 'S', 83, 'VK_S', '', ''),
  (0, 29, 'KeyT', 50, 'T', 84, 'VK_T', '', ''),
  (0, 30, 'KeyU', 51, 'U', 85, 'VK_U', '', ''),
  (0, 31, 'KeyV', 52, 'V', 86, 'VK_V', '', ''),
  (0, 32, 'KeyW', 53, 'W', 87, 'VK_W', '', ''),
  (0, 33, 'KeyX', 54, 'X', 88, 'VK_X', '', ''),
  (0, 34, 'KeyY', 55, 'Y', 89, 'VK_Y', '', ''),
  (0, 35, 'KeyZ', 56, 'Z', 90, 'VK_Z', '', ''),
  (0, 36, 'Digit1', 22, '1', 49, 'VK_1', '', ''),
  (0, 37, 'Digit2', 23, '2', 50, 'VK_2', '', ''),
  (0, 38, 'Digit3', 24, '3', 51, 'VK_3', '', ''),
  (0, 39, 'Digit4', 25, '4', 52, 'VK_4', '', ''),
  (0, 40, 'Digit5', 26, '5', 53, 'VK_5', '', ''),
  (0, 41, 'Digit6', 27, '6', 54, 'VK_6', '', ''),
  (0, 42, 'Digit7', 28, '7', 55, 'VK_7', '', ''),
  (0, 43, 'Digit8', 29, '8', 56, 'VK_8', '', ''),
  (0, 44, 'Digit9', 30, '9', 57, 'VK_9', '', ''),
  (0, 45, 'Digit0', 21, '0', 48, 'VK_0', '', ''),
  (1, 46, 'Enter', 3, 'Enter', 13, 'VK_RETURN', '', ''),
  (1, 47, 'Escape', 9, 'Escape', 27, 'VK_ESCAPE', '', ''),
  (1, 48, 'Backspace', 1, 'Backspace', 8, 'VK_BACK', '', ''),
  (1, 49, 'Tab', 2, 'Tab', 9, 'VK_TAB', '', ''),
  (1, 50, 'Space', 10, 'Space', 32, 'VK_SPACE', '', ''),
  (0, 51, 'Minus', 88, '-', 189, 'VK_OEM_MINUS', '-', 'OEM_MINUS'),
  (0, 52, 'Equal', 86, '=', 187, 'VK_OEM_PLUS', '=', 'OEM_PLUS'),
  (0, 53, 'BracketLeft', 92, '[', 219, 'VK_OEM_4', '[', 'OEM_4'),
  (0, 54, 'BracketRight', 94, ']', 221, 'VK_OEM_6', ']', 'OEM_6'),
  (0, 55, 'Backslash', 93, '\\', 220, 'VK_OEM_5', '\\', 'OEM_5'),
  (0, 56, 'IntlHash', 0, '', 0, '', '', ''),
  (0, 57, 'Semicolon', 85, ';', 186, 'VK_OEM_1', ';', 'OEM_1'),
  (0, 58, 'Quote', 95, '\'', 222, 'VK_OEM_7', '\'', 'OEM_7'),
  (0, 59, 'Backquote', 91, '`', 192, 'VK_OEM_3', '`', 'OEM_3'),
  (0, 60, 'Comma', 87, ',', 188, 'VK_OEM_COMMA', ',', 'OEM_COMMA'),
  (0, 61, 'Period', 89, '.', 190, 'VK_OEM_PERIOD', '.', 'OEM_PERIOD'),
  (0, 62, 'Slash', 90, '/', 191, 'VK_OEM_2', '/', 'OEM_2'),
  (1, 63, 'CapsLock', 8, 'CapsLock', 20, 'VK_CAPITAL', '', ''),
  (1, 64, 'F1', 59, 'F1', 112, 'VK_F1', '', ''),
  (1, 65, 'F2', 60, 'F2', 113, 'VK_F2', '', ''),
  (1, 66, 'F3', 61, 'F3', 114, 'VK_F3', '', ''),
  (1, 67, 'F4', 62, 'F4', 115, 'VK_F4', '', ''),
  (1, 68, 'F5', 63, 'F5', 116, 'VK_F5', '', ''),
  (1, 69, 'F6', 64, 'F6', 117, 'VK_F6', '', ''),
  (1, 70, 'F7', 65, 'F7', 118, 'VK_F7', '', ''),
  (1, 71, 'F8', 66, 'F8', 119, 'VK_F8', '', ''),
  (1, 72, 'F9', 67, 'F9', 120, 'VK_F9', '', ''),
  (1, 73, 'F10', 68, 'F10', 121, 'VK_F10', '', ''),
  (1, 74, 'F11', 69, 'F11', 122, 'VK_F11', '', ''),
  (1, 75, 'F12', 70, 'F12', 123, 'VK_F12', '', ''),
  (1, 76, 'PrintScreen', 0, '', 0, '', '', ''),
  (1, 77, 'ScrollLock', 84, 'ScrollLock', 145, 'VK_SCROLL', '', ''),
  (1, 78, 'Pause', 7, 'PauseBreak', 19, 'VK_PAUSE', '', ''),
  (1, 79, 'Insert', 19, 'Insert', 45, 'VK_INSERT', '', ''),
  (1, 80, 'Home', 14, 'Home', 36, 'VK_HOME', '', ''),
  (1, 81, 'PageUp', 11, 'PageUp', 33, 'VK_PRIOR', '', ''),
  (1, 82, 'Delete', 20, 'Del', 46, 'VK_DELETE', 'Delete', ''),
  (1, 83, 'End', 13, 'End', 35, 'VK_END', '', ''),
  (1, 84, 'PageDown', 12, 'PageDown', 34, 'VK_NEXT', '', ''),
  (1, 85, 'ArrowRight', 17, 'RightArrow', 39, 'VK_RIGHT', 'Right', ''),
  (1, 86, 'ArrowLeft', 15, 'LeftArrow', 37, 'VK_LEFT', 'Left', ''),
  (1, 87, 'ArrowDown', 18, 'DownArrow', 40, 'VK_DOWN', 'Down', ''),
  (1, 88, 'ArrowUp', 16, 'UpArrow', 38, 'VK_UP', 'Up', ''),
  (1, 89, 'NumLock', 83, 'NumLock', 144, 'VK_NUMLOCK', '', ''),
  (1, 90, 'NumpadDivide', 113, 'NumPad_Divide', 111, 'VK_DIVIDE', '', ''),
  (1, 91, 'NumpadMultiply', 108, 'NumPad_Multiply', 106, 'VK_MULTIPLY', '', ''),
  (1, 92, 'NumpadSubtract', 111, 'NumPad_Subtract', 109, 'VK_SUBTRACT', '', ''),
  (1, 93, 'NumpadAdd', 109, 'NumPad_Add', 107, 'VK_ADD', '', ''),
  (1, 94, 'NumpadEnter', 3, '', 0, '', '', ''),
  (1, 95, 'Numpad1', 99, 'NumPad1', 97, 'VK_NUMPAD1', '', ''),
  (1, 96, 'Numpad2', 100, 'NumPad2', 98, 'VK_NUMPAD2', '', ''),
  (1, 97, 'Numpad3', 101, 'NumPad3', 99, 'VK_NUMPAD3', '', ''),
  (1, 98, 'Numpad4', 102, 'NumPad4', 100, 'VK_NUMPAD4', '', ''),
  (1, 99, 'Numpad5', 103, 'NumPad5', 101, 'VK_NUMPAD5', '', ''),
  (1, 100, 'Numpad6', 104, 'NumPad6', 102, 'VK_NUMPAD6', '', ''),
  (1, 101, 'Numpad7', 105, 'NumPad7', 103, 'VK_NUMPAD7', '', ''),
  (1, 102, 'Numpad8', 106, 'NumPad8', 104, 'VK_NUMPAD8', '', ''),
  (1, 103, 'Numpad9', 107, 'NumPad9', 105, 'VK_NUMPAD9', '', ''),
  (1, 104, 'Numpad0', 98, 'NumPad0', 96, 'VK_NUMPAD0', '', ''),
  (1, 105, 'NumpadDecimal', 112, 'NumPad_Decimal', 110, 'VK_DECIMAL', '', ''),
  (0, 106, 'IntlBackslash', 97, 'OEM_102', 226, 'VK_OEM_102', '', ''),
  (1, 107, 'ContextMenu', 58, 'ContextMenu', 93, '', '', ''),
  (1, 108, 'Power', 0, '', 0, '', '', ''),
  (1, 109, 'NumpadEqual', 0, '', 0, '', '', ''),
  (1, 110, 'F13', 71, 'F13', 124, 'VK_F13', '', ''),
  (1, 111, 'F14', 72, 'F14', 125, 'VK_F14', '', ''),
  (1, 112, 'F15', 73, 'F15', 126, 'VK_F15', '', ''),
  (1, 113, 'F16', 74, 'F16', 127, 'VK_F16', '', ''),
  (1, 114, 'F17', 75, 'F17', 128, 'VK_F17', '', ''),
  (1, 115, 'F18', 76, 'F18', 129, 'VK_F18', '', ''),
  (1, 116, 'F19', 77, 'F19', 130, 'VK_F19', '', ''),
  (1, 117, 'F20', 78, 'F20', 131, 'VK_F20', '', ''),
  (1, 118, 'F21', 79, 'F21', 132, 'VK_F21', '', ''),
  (1, 119, 'F22', 80, 'F22', 133, 'VK_F22', '', ''),
  (1, 120, 'F23', 81, 'F23', 134, 'VK_F23', '', ''),
  (1, 121, 'F24', 82, 'F24', 135, 'VK_F24', '', ''),
  (1, 122, 'Open', 0, '', 0, '', '', ''),
  (1, 123, 'Help', 0, '', 0, '', '', ''),
  (1, 124, 'Select', 0, '', 0, '', '', ''),
  (1, 125, 'Again', 0, '', 0, '', '', ''),
  (1, 126, 'Undo', 0, '', 0, '', '', ''),
  (1, 127, 'Cut', 0, '', 0, '', '', ''),
  (1, 128, 'Copy', 0, '', 0, '', '', ''),
  (1, 129, 'Paste', 0, '', 0, '', '', ''),
  (1, 130, 'Find', 0, '', 0, '', '', ''),
  (1, 131, 'AudioVolumeMute', 117, 'AudioVolumeMute', 173, 'VK_VOLUME_MUTE', '', ''),
  (1, 132, 'AudioVolumeUp', 118, 'AudioVolumeUp', 175, 'VK_VOLUME_UP', '', ''),
  (1, 133, 'AudioVolumeDown', 119, 'AudioVolumeDown', 174, 'VK_VOLUME_DOWN', '', ''),
  (1, 134, 'NumpadComma', 110, 'NumPad_Separator', 108, 'VK_SEPARATOR', '', ''),
  (0, 135, 'IntlRo', 115, 'ABNT_C1', 193, 'VK_ABNT_C1', '', ''),
  (1, 136, 'KanaMode', 0, '', 0, '', '', ''),
  (0, 137, 'IntlYen', 0, '', 0, '', '', ''),
  (1, 138, 'Convert', 0, '', 0, '', '', ''),
  (1, 139, 'NonConvert', 0, '', 0, '', '', ''),
  (1, 140, 'Lang1', 0, '', 0, '', '', ''),
  (1, 141, 'Lang2', 0, '', 0, '', '', ''),
  (1, 142, 'Lang3', 0, '', 0, '', '', ''),
  (1, 143, 'Lang4', 0, '', 0, '', '', ''),
  (1, 144, 'Lang5', 0, '', 0, '', '', ''),
  (1, 145, 'Abort', 0, '', 0, '', '', ''),
  (1, 146, 'Props', 0, '', 0, '', '', ''),
  (1, 147, 'NumpadParenLeft', 0, '', 0, '', '', ''),
  (1, 148, 'NumpadParenRight', 0, '', 0, '', '', ''),
  (1, 149, 'NumpadBackspace', 0, '', 0, '', '', ''),
  (1, 150, 'NumpadMemoryStore', 0, '', 0, '', '', ''),
  (1, 151, 'NumpadMemoryRecall', 0, '', 0, '', '', ''),
  (1, 152, 'NumpadMemoryClear', 0, '', 0, '', '', ''),
  (1, 153, 'NumpadMemoryAdd', 0, '', 0, '', '', ''),
  (1, 154, 'NumpadMemorySubtract', 0, '', 0, '', '', ''),
  (1, 155, 'NumpadClear', 131, 'Clear', 12, 'VK_CLEAR', '', ''),
  (1, 156, 'NumpadClearEntry', 0, '', 0, '', '', ''),
  (1, 0, '', 5, 'Ctrl', 17, 'VK_CONTROL', '', ''),
  (1, 0, '', 4, 'Shift', 16, 'VK_SHIFT', '', ''),
  (1, 0, '', 6, 'Alt', 18, 'VK_MENU', '', ''),
  (1, 0, '', 57, 'Meta', 91, 'VK_COMMAND', '', ''),
  (1, 157, 'ControlLeft', 5, '', 0, 'VK_LCONTROL', '', ''),
  (1, 158, 'ShiftLeft', 4, '', 0, 'VK_LSHIFT', '', ''),
  (1, 159, 'AltLeft', 6, '', 0, 'VK_LMENU', '', ''),
  (1, 160, 'MetaLeft', 57, '', 0, 'VK_LWIN', '', ''),
  (1, 161, 'ControlRight', 5, '', 0, 'VK_RCONTROL', '', ''),
  (1, 162, 'ShiftRight', 4, '', 0, 'VK_RSHIFT', '', ''),
  (1, 163, 'AltRight', 6, '', 0, 'VK_RMENU', '', ''),
  (1, 164, 'MetaRight', 57, '', 0, 'VK_RWIN', '', ''),
  (1, 165, 'BrightnessUp', 0, '', 0, '', '', ''),
  (1, 166, 'BrightnessDown', 0, '', 0, '', '', ''),
  (1, 167, 'MediaPlay', 0, '', 0, '', '', ''),
  (1, 168, 'MediaRecord', 0, '', 0, '', '', ''),
  (1, 169, 'MediaFastForward', 0, '', 0, '', '', ''),
  (1, 170, 'MediaRewind', 0, '', 0, '', '', ''),
  (1, 171, 'MediaTrackNext', 124, 'MediaTrackNext', 176, 'VK_MEDIA_NEXT_TRACK', '', ''),
  (1, 172, 'MediaTrackPrevious', 125, 'MediaTrackPrevious', 177, 'VK_MEDIA_PREV_TRACK', '', ''),
  (1, 173, 'MediaStop', 126, 'MediaStop', 178, 'VK_MEDIA_STOP', '', ''),
  (1, 174, 'Eject', 0, '', 0, '', '', ''),
  (1, 175, 'MediaPlayPause', 127, 'MediaPlayPause', 179, 'VK_MEDIA_PLAY_PAUSE', '', ''),
  (1, 176, 'MediaSelect', 128, 'LaunchMediaPlayer', 181, 'VK_MEDIA_LAUNCH_MEDIA_SELECT', '', ''),
  (1, 177, 'LaunchMail', 129, 'LaunchMail', 180, 'VK_MEDIA_LAUNCH_MAIL', '', ''),
  (1, 178, 'LaunchApp2', 130, 'LaunchApp2', 183, 'VK_MEDIA_LAUNCH_APP2', '', ''),
  (1, 179, 'LaunchApp1', 0, '', 0, 'VK_MEDIA_LAUNCH_APP1', '', ''),
  (1, 180, 'SelectTask', 0, '', 0, '', '', ''),
  (1, 181, 'LaunchScreenSaver', 0, '', 0, '', '', ''),
  (1, 182, 'BrowserSearch', 120, 'BrowserSearch', 170, 'VK_BROWSER_SEARCH', '', ''),
  (1, 183, 'BrowserHome', 121, 'BrowserHome', 172, 'VK_BROWSER_HOME', '', ''),
  (1, 184, 'BrowserBack', 122, 'BrowserBack', 166, 'VK_BROWSER_BACK', '', ''),
  (1, 185, 'BrowserForward', 123, 'BrowserForward', 167, 'VK_BROWSER_FORWARD', '', ''),
  (1, 186, 'BrowserStop', 0, '', 0, 'VK_BROWSER_STOP', '', ''),
  (1, 187, 'BrowserRefresh', 0, '', 0, 'VK_BROWSER_REFRESH', '', ''),
  (1, 188, 'BrowserFavorites', 0, '', 0, 'VK_BROWSER_FAVORITES', '', ''),
  (1, 189, 'ZoomToggle', 0, '', 0, '', '', ''),
  (1, 190, 'MailReply', 0, '', 0, '', '', ''),
  (1, 191, 'MailForward', 0, '', 0, '', '', ''),
  (1, 192, 'MailSend', 0, '', 0, '', '', ''),
  (1, 0, '', 114, 'KeyInComposition', 229, '', '', ''),
  (1, 0, '', 116, 'ABNT_C2', 194, 'VK_ABNT_C2', '', ''),
  (1, 0, '', 96, 'OEM_8', 223, 'VK_OEM_8', '', ''),
  (1, 0, '', 0, '', 0, 'VK_KANA', '', ''),
  (1, 0, '', 0, '', 0, 'VK_HANGUL', '', ''),
  (1, 0, '', 0, '', 0, 'VK_JUNJA', '', ''),
  (1, 0, '', 0, '', 0, 'VK_FINAL', '', ''),
  (1, 0, '', 0, '', 0, 'VK_HANJA', '', ''),
  (1, 0, '', 0, '', 0, 'VK_KANJI', '', ''),
  (1, 0, '', 0, '', 0, 'VK_CONVERT', '', ''),
  (1, 0, '', 0, '', 0, 'VK_NONCONVERT', '', ''),
  (1, 0, '', 0, '', 0, 'VK_ACCEPT', '', ''),
  (1, 0, '', 0, '', 0, 'VK_MODECHANGE', '', ''),
  (1, 0, '', 0, '', 0, 'VK_SELECT', '', ''),
  (1, 0, '', 0, '', 0, 'VK_PRINT', '', ''),
  (1, 0, '', 0, '', 0, 'VK_EXECUTE', '', ''),
  (1, 0, '', 0, '', 0, 'VK_SNAPSHOT', '', ''),
  (1, 0, '', 0, '', 0, 'VK_HELP', '', ''),
  (1, 0, '', 0, '', 0, 'VK_APPS', '', ''),
  (1, 0, '', 0, '', 0, 'VK_PROCESSKEY', '', ''),
  (1, 0, '', 0, '', 0, 'VK_PACKET', '', ''),
  (1, 0, '', 0, '', 0, 'VK_DBE_SBCSCHAR', '', ''),
  (1, 0, '', 0, '', 0, 'VK_DBE_DBCSCHAR', '', ''),
  (1, 0, '', 0, '', 0, 'VK_ATTN', '', ''),
  (1, 0, '', 0, '', 0, 'VK_CRSEL', '', ''),
  (1, 0, '', 0, '', 0, 'VK_EXSEL', '', ''),
  (1, 0, '', 0, '', 0, 'VK_EREOF', '', ''),
  (1, 0, '', 0, '', 0, 'VK_PLAY', '', ''),
  (1, 0, '', 0, '', 0, 'VK_ZOOM', '', ''),
  (1, 0, '', 0, '', 0, 'VK_NONAME', '', ''),
  (1, 0, '', 0, '', 0, 'VK_PA1', '', ''),
  (1, 0, '', 0, '', 0, 'VK_OEM_CLEAR', '', ''),
  ];

  final List<bool> seenKeyCode = <bool>[];
  final List<bool> seenScanCode = <bool>[];
  for (final m in mappings) {
    final int immutable = m.$1;
    final int scanCode = m.$2;
    final String scanCodeStr = m.$3;
    final int keyCode = m.$4;
    final String keyCodeStr = m.$5;
    final int eventKeyCode = m.$6;
    final String vkey = m.$7;
    final String usUserSettingsLabel = m.$8;
    final String generalUserSettingsLabel = m.$9;
    if (!_getBool(seenScanCode, scanCode)) {
      _setAt<bool>(seenScanCode, scanCode, true);
      _setAt<String>(_scanCodeIntToStr, scanCode, scanCodeStr);
      _scanCodeStrToInt[scanCodeStr] = scanCode;
      _scanCodeLowerCaseStrToInt[scanCodeStr.toLowerCase()] = scanCode;
      if (immutable == 1) {
        _immutableCodeToKeyCode[scanCode] = keyCode;
        if ((keyCode != KeyCode.Unknown) && (keyCode != KeyCode.Enter) && !isModifierKey(keyCode)) {
          _immutableKeyCodeToCode[keyCode] = scanCode;
        }
      }
    }
    if (!_getBool(seenKeyCode, keyCode)) {
      _setAt<bool>(seenKeyCode, keyCode, true);
      if (keyCodeStr.isEmpty) {
        throw StateError('String representation missing for key code $keyCode around scan code $scanCodeStr');
      }
      _uiMap.define(keyCode, keyCodeStr);
      _userSettingsUSMap.define(keyCode, usUserSettingsLabel.isNotEmpty ? usUserSettingsLabel : keyCodeStr);
      _userSettingsGeneralMap.define(keyCode, generalUserSettingsLabel.isNotEmpty ? generalUserSettingsLabel : (usUserSettingsLabel.isNotEmpty ? usUserSettingsLabel : keyCodeStr));
    }
    if (eventKeyCode != 0) {
      _setAt<int>(_eventKeyCodeMap, eventKeyCode, keyCode);
    }
    if (scanCodeStr.isNotEmpty) {
      _scanCodeStrToEventKeyCode[scanCodeStr] = eventKeyCode;
    }
    if (vkey.isNotEmpty) {
      _nativeWindowsKeyCodeToKeyCode[vkey] = keyCode;
    }
  }
  // Manually added due to the exclusion above (due to duplication with NumpadEnter)
  _immutableKeyCodeToCode[KeyCode.Enter] = ScanCode.Enter;
  return true;
}

/// 1:1: `export namespace KeyCodeUtils`
class KeyCodeUtils {
  static String toStringValue(int keyCode) { _keyCodesInitialized; return _uiMap.keyCodeToStr(keyCode); }
  static int fromString(String key) { _keyCodesInitialized; return _uiMap.strToKeyCode(key); }
  static String toUserSettingsUS(int keyCode) { _keyCodesInitialized; return _userSettingsUSMap.keyCodeToStr(keyCode); }
  static String toUserSettingsGeneral(int keyCode) { _keyCodesInitialized; return _userSettingsGeneralMap.keyCodeToStr(keyCode); }
  static int fromUserSettings(String key) {
    _keyCodesInitialized;
    final int a = _userSettingsUSMap.strToKeyCode(key);
    return a != KeyCode.Unknown ? a : _userSettingsGeneralMap.strToKeyCode(key);
  }
  static String? toElectronAccelerator(int keyCode) {
    _keyCodesInitialized;
    if (keyCode >= KeyCode.Numpad0 && keyCode <= KeyCode.NumpadDivide) return null;
    switch (keyCode) {
      case KeyCode.UpArrow: return 'Up';
      case KeyCode.DownArrow: return 'Down';
      case KeyCode.LeftArrow: return 'Left';
      case KeyCode.RightArrow: return 'Right';
      case KeyCode.Delete: return 'Delete';
    }
    return _uiMap.keyCodeToStr(keyCode);
  }
}

/// 1:1: `export const enum KeyMod`
class KeyMod {
  static const int CtrlCmd = 2048; // (1 << 11) >>> 0
  static const int Shift = 1024;   // (1 << 10) >>> 0
  static const int Alt = 512;      // (1 << 9) >>> 0
  static const int WinCtrl = 256;  // (1 << 8) >>> 0
}

/// 1:1: `export function KeyChord(firstPart, secondPart)`
int KeyChord(int firstPart, int secondPart) {
  final int chordPart = ((secondPart & 0x0000FFFF) << 16) & 0xFFFFFFFF;
  return (firstPart | chordPart) & 0xFFFFFFFF;
}

/// 1:1: `export function isModifierKey(keyCode)`
bool isModifierKey(int keyCode) {
  return keyCode == KeyCode.Ctrl || keyCode == KeyCode.Shift || keyCode == KeyCode.Alt || keyCode == KeyCode.Meta;
}

/// Library initializer — mirrors the source top-level IIFE that builds all maps.
final bool _keyCodesInitialized = _initKeyCodes();
