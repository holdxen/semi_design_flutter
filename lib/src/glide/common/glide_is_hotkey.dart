// Port of `packages/core/src/common/is-hotkey.ts` plus the DOM keyboard
// translation it depends on.
//
// Upstream reads `KeyboardEvent.key` and the legacy `KeyboardEvent.keyCode`
// off the browser event. Flutter gives us `LogicalKeyboardKey`, so this file
// maps keys back onto the DOM values the hotkey grammar expects; everything
// downstream of that (`is-hotkey.ts:14-86`) is a line-by-line port.
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../internal/data_grid/glide_event_args.dart';

/// `browserIsOSX` (`common/browser-detect.ts:29`).
///
/// `navigator.platform` has no Flutter equivalent; `defaultTargetPlatform`
/// resolves to the host platform on desktop and to the browser's platform on
/// the web, which is the same information.
bool glideIsOSX() => defaultTargetPlatform == TargetPlatform.macOS;

/// DOM `KeyboardEvent.key` / `KeyboardEvent.keyCode` for the keys the grid's
/// keybind grammar mentions.
final Map<LogicalKeyboardKey, (String, int)> _domKeys = {
  LogicalKeyboardKey.arrowDown: ('ArrowDown', 40),
  LogicalKeyboardKey.arrowUp: ('ArrowUp', 38),
  LogicalKeyboardKey.arrowLeft: ('ArrowLeft', 37),
  LogicalKeyboardKey.arrowRight: ('ArrowRight', 39),
  LogicalKeyboardKey.enter: ('Enter', 13),
  LogicalKeyboardKey.numpadEnter: ('Enter', 13),
  LogicalKeyboardKey.escape: ('Escape', 27),
  LogicalKeyboardKey.tab: ('Tab', 9),
  LogicalKeyboardKey.home: ('Home', 36),
  LogicalKeyboardKey.end: ('End', 35),
  LogicalKeyboardKey.pageUp: ('PageUp', 33),
  LogicalKeyboardKey.pageDown: ('PageDown', 34),
  LogicalKeyboardKey.delete: ('Delete', 46),
  LogicalKeyboardKey.backspace: ('Backspace', 8),
  LogicalKeyboardKey.space: (' ', 32),
  LogicalKeyboardKey.shift: ('Shift', 16),
  LogicalKeyboardKey.control: ('Control', 17),
  LogicalKeyboardKey.alt: ('Alt', 18),
  LogicalKeyboardKey.meta: ('Meta', 91),
};

/// DOM `event.key` for [key].
String glideDomKey(LogicalKeyboardKey key) {
  final mapped = _domKeys[key];
  if (mapped != null) return mapped.$1;
  final label = key.keyLabel;
  if (label.length == 1) return label.toLowerCase();
  return label;
}

/// DOM `event.keyCode` for [key].
///
/// Letters map to their upper-case code point (`a` → 65) exactly like the
/// deprecated `KeyboardEvent.keyCode` did, which is what makes hotkeys such
/// as `primary+_68` resolve to Ctrl/Cmd+D.
int glideDomKeyCode(LogicalKeyboardKey key) {
  final mapped = _domKeys[key];
  if (mapped != null) return mapped.$2;
  final label = key.keyLabel;
  if (label.length == 1) {
    final upper = label.toUpperCase();
    if (upper.codeUnitAt(0) >= 65 && upper.codeUnitAt(0) <= 90) {
      return upper.codeUnitAt(0);
    }
    if (label.codeUnitAt(0) >= 48 && label.codeUnitAt(0) <= 57) {
      return label.codeUnitAt(0);
    }
  }
  // Unmapped keys keep a stable, non-zero fallback so `_NN` comparisons
  // simply fail rather than matching everything.
  return 0;
}

/// `checkKey` (`is-hotkey.ts:14-25`).
bool glideCheckKey(String? key, GlideGridKeyArgs args) {
  if (key == null || key.isEmpty) return false;
  if (key.length > 1 && key.startsWith('_')) {
    final keycode = int.tryParse(key.substring(1));
    return keycode != null && keycode == args.keyCode;
  }
  if (key.length == 1 &&
      key.compareTo('a') >= 0 &&
      key.compareTo('z') <= 0) {
    return key.toUpperCase().codeUnitAt(0) == args.keyCode;
  }
  return key == args.key;
}

/// `isHotkey` (`is-hotkey.ts:31-35`).
bool glideIsHotkey(String hotkey, GlideGridKeyArgs args) =>
    _isHotkeyInner(hotkey, args);

/// `isHotkeyInner` (`is-hotkey.ts:37-86`).
bool _isHotkeyInner(String hotkey, GlideGridKeyArgs args) {
  if (hotkey.isEmpty) return false;

  if (hotkey.contains('|')) {
    for (final part in hotkey.split('|')) {
      if (_isHotkeyInner(part, args)) return true;
    }
    return false;
  }

  var wantCtrl = false;
  var wantShift = false;
  var wantAlt = false;
  var wantMeta = false;

  final split = hotkey.split('+');
  final key = split.removeLast();

  if (!glideCheckKey(key, args)) return false;
  if (split.isNotEmpty && split.first == 'any') return true;

  for (final accel in split) {
    switch (accel) {
      case 'ctrl':
        wantCtrl = true;
      case 'shift':
        wantShift = true;
      case 'alt':
        wantAlt = true;
      case 'meta':
        wantMeta = true;
      case 'primary':
        if (glideIsOSX()) {
          wantMeta = true;
        } else {
          wantCtrl = true;
        }
    }
  }

  return args.altKey == wantAlt &&
      args.ctrlKey == wantCtrl &&
      args.shiftKey == wantShift &&
      args.metaKey == wantMeta;
}
