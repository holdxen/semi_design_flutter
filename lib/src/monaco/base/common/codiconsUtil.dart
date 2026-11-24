// 1:1 port of vscode/src/vs/base/common/codiconsUtil.ts

import 'types.dart' as types;
import 'themables.dart' as themables;

final Map<String, int> _codiconFontCharacters = <String, int>{};

/// 1:1: `export function register(id, fontCharacter): ThemeIcon`
themables.ThemeIcon register(String id, Object fontCharacter) {
  int character;
  if (types.isString(fontCharacter)) {
    final int? val = _codiconFontCharacters[fontCharacter];
    if (val == null) {
      throw StateError('$id references an unknown codicon: $fontCharacter');
    }
    character = val;
  } else {
    character = fontCharacter as int;
  }
  _codiconFontCharacters[id] = character;
  return themables.ThemeIcon(id);
}

/// 1:1: `export function getCodiconFontCharacters()`
Map<String, int> getCodiconFontCharacters() => _codiconFontCharacters;
