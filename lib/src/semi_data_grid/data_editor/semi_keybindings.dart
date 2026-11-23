// Port of `packages/core/src/data-editor/data-editor-keybindings.ts`.
//
// `useKeybindingsWithDefaults` is a `React.useMemo` upstream; here the same
// pure work lives in [semiKeysWithDefaults] and the caller memoizes.
import 'package:flutter/foundation.dart';

import '../common/semi_is_hotkey.dart';

/// `Keybind = boolean | string` (`data-editor-keybindings.ts:5`).
///
/// - `true` → use the default expression
/// - `false` → the action is unbound (`""`)
/// - `String` → a custom expression in the `is-hotkey` grammar
typedef SemiKeybind = Object;

bool _enabled(Object bind) => bind == true;

/// Applies a `backCompat` alias the way `useKeybindingsWithDefaults` does
/// (`data-editor-keybindings.ts:186-191`): the alias only wins while the
/// primary binding still holds its default value. Passing the default
/// explicitly together with an alias therefore prefers the alias, which is
/// the one case where the TS `??` chain and this differ.
SemiKeybind _withAlias(SemiKeybind value, bool? alias, SemiKeybind fallback) {
  if (value != fallback) return value;
  return alias ?? value;
}

String _realize(Object keybind, String defaultVal) {
  if (keybind == true) return defaultVal;
  if (keybind == false) return '';
  return keybind as String;
}

/// `ConfigurableKeybinds` + `ForcedKeybinds` + `BackCompatKeybinds`
/// (`data-editor-keybindings.ts:7-72`).
@immutable
class SemiKeybinds {
  const SemiKeybinds({
    this.downFill = false,
    this.rightFill = false,
    this.clear = true,
    this.closeOverlay = true,
    this.acceptOverlayDown = true,
    this.acceptOverlayUp = true,
    this.acceptOverlayLeft = true,
    this.acceptOverlayRight = true,
    this.copy = true,
    this.paste = true,
    this.cut = true,
    this.search = false,
    this.delete = true,
    this.activateCell = true,
    this.scrollToSelectedCell = true,
    this.goToFirstColumn = true,
    this.goToLastColumn = true,
    this.goToFirstCell = true,
    this.goToLastCell = true,
    this.goToFirstRow = true,
    this.goToLastRow = true,
    this.goToNextPage = true,
    this.goToPreviousPage = true,
    this.goUpCell = true,
    this.goDownCell = true,
    this.goLeftCell = true,
    this.goRightCell = true,
    this.goUpCellRetainSelection = true,
    this.goDownCellRetainSelection = true,
    this.goLeftCellRetainSelection = true,
    this.goRightCellRetainSelection = true,
    this.selectToFirstColumn = true,
    this.selectToLastColumn = true,
    this.selectToFirstCell = true,
    this.selectToLastCell = true,
    this.selectToFirstRow = true,
    this.selectToLastRow = true,
    this.selectGrowUp = true,
    this.selectGrowDown = true,
    this.selectGrowLeft = true,
    this.selectGrowRight = true,
    this.selectAll = true,
    this.selectRow = true,
    this.selectColumn = true,
    // Back-compat aliases (`Partial<BackCompatKeybinds>`).
    this.pageUp,
    this.pageDown,
    this.first,
    this.last,
  });

  final SemiKeybind downFill;
  final SemiKeybind rightFill;
  final SemiKeybind clear;
  final SemiKeybind closeOverlay;
  final SemiKeybind acceptOverlayDown;
  final SemiKeybind acceptOverlayUp;
  final SemiKeybind acceptOverlayLeft;
  final SemiKeybind acceptOverlayRight;
  final SemiKeybind copy;
  final SemiKeybind paste;
  final SemiKeybind cut;
  final SemiKeybind search;
  final SemiKeybind delete;
  final SemiKeybind activateCell;
  final SemiKeybind scrollToSelectedCell;

  final SemiKeybind goToFirstColumn;
  final SemiKeybind goToLastColumn;
  final SemiKeybind goToFirstCell;
  final SemiKeybind goToLastCell;
  final SemiKeybind goToFirstRow;
  final SemiKeybind goToLastRow;
  final SemiKeybind goToNextPage;
  final SemiKeybind goToPreviousPage;

  final SemiKeybind goUpCell;
  final SemiKeybind goDownCell;
  final SemiKeybind goLeftCell;
  final SemiKeybind goRightCell;

  final SemiKeybind goUpCellRetainSelection;
  final SemiKeybind goDownCellRetainSelection;
  final SemiKeybind goLeftCellRetainSelection;
  final SemiKeybind goRightCellRetainSelection;

  final SemiKeybind selectToFirstColumn;
  final SemiKeybind selectToLastColumn;
  final SemiKeybind selectToFirstCell;
  final SemiKeybind selectToLastCell;
  final SemiKeybind selectToFirstRow;
  final SemiKeybind selectToLastRow;

  final SemiKeybind selectGrowUp;
  final SemiKeybind selectGrowDown;
  final SemiKeybind selectGrowLeft;
  final SemiKeybind selectGrowRight;

  final SemiKeybind selectAll;
  final SemiKeybind selectRow;
  final SemiKeybind selectColumn;

  final bool? pageUp;
  final bool? pageDown;
  final bool? first;
  final bool? last;

  static const SemiKeybinds defaults = SemiKeybinds();

}

/// `RealizedKeybinds` (`data-editor-keybindings.ts:74`).
@immutable
class SemiRealizedKeybinds {
  const SemiRealizedKeybinds({
    required this.activateCell,
    required this.clear,
    required this.closeOverlay,
    required this.acceptOverlayDown,
    required this.acceptOverlayUp,
    required this.acceptOverlayLeft,
    required this.acceptOverlayRight,
    required this.copy,
    required this.cut,
    required this.paste,
    required this.delete,
    required this.downFill,
    required this.rightFill,
    required this.scrollToSelectedCell,
    required this.goDownCell,
    required this.goDownCellRetainSelection,
    required this.goLeftCell,
    required this.goLeftCellRetainSelection,
    required this.goRightCell,
    required this.goRightCellRetainSelection,
    required this.goUpCell,
    required this.goUpCellRetainSelection,
    required this.goToFirstCell,
    required this.goToFirstColumn,
    required this.goToFirstRow,
    required this.goToLastCell,
    required this.goToLastColumn,
    required this.goToLastRow,
    required this.goToNextPage,
    required this.goToPreviousPage,
    required this.search,
    required this.selectAll,
    required this.selectColumn,
    required this.selectGrowDown,
    required this.selectGrowLeft,
    required this.selectGrowRight,
    required this.selectGrowUp,
    required this.selectRow,
    required this.selectToFirstCell,
    required this.selectToFirstColumn,
    required this.selectToFirstRow,
    required this.selectToLastCell,
    required this.selectToLastColumn,
    required this.selectToLastRow,
  });

  final String activateCell;
  final String clear;
  final String closeOverlay;
  final String acceptOverlayDown;
  final String acceptOverlayUp;
  final String acceptOverlayLeft;
  final String acceptOverlayRight;
  final bool copy;
  final bool cut;
  final bool paste;
  final String delete;
  final String downFill;
  final String rightFill;
  final String scrollToSelectedCell;
  final String goDownCell;
  final String goDownCellRetainSelection;
  final String goLeftCell;
  final String goLeftCellRetainSelection;
  final String goRightCell;
  final String goRightCellRetainSelection;
  final String goUpCell;
  final String goUpCellRetainSelection;
  final String goToFirstCell;
  final String goToFirstColumn;
  final String goToFirstRow;
  final String goToLastCell;
  final String goToLastColumn;
  final String goToLastRow;
  final String goToNextPage;
  final String goToPreviousPage;
  final String search;
  final String selectAll;
  final String selectColumn;
  final String selectGrowDown;
  final String selectGrowLeft;
  final String selectGrowRight;
  final String selectGrowUp;
  final String selectRow;
  final String selectToFirstCell;
  final String selectToFirstColumn;
  final String selectToFirstRow;
  final String selectToLastCell;
  final String selectToLastColumn;
  final String selectToLastRow;
}

/// `realizeKeybinds` (`data-editor-keybindings.ts:129-178`).
SemiRealizedKeybinds semiRealizeKeybinds(SemiKeybinds keybinds) {
  final isOSX = semiIsOSX();
  return SemiRealizedKeybinds(
    activateCell: _realize(keybinds.activateCell, ' |Enter|shift+Enter'),
    clear: _realize(keybinds.clear, 'any+Escape'),
    closeOverlay: _realize(keybinds.closeOverlay, 'any+Escape'),
    acceptOverlayDown: _realize(keybinds.acceptOverlayDown, 'Enter'),
    acceptOverlayUp: _realize(keybinds.acceptOverlayUp, 'shift+Enter'),
    acceptOverlayLeft: _realize(keybinds.acceptOverlayLeft, 'shift+Tab'),
    acceptOverlayRight: _realize(keybinds.acceptOverlayRight, 'Tab'),
    copy: _enabled(keybinds.copy),
    cut: _enabled(keybinds.cut),
    paste: _enabled(keybinds.paste),
    delete: _realize(
      keybinds.delete,
      isOSX ? 'Backspace|Delete' : 'Delete',
    ),
    downFill: _realize(keybinds.downFill, 'primary+_68'),
    scrollToSelectedCell: _realize(
      keybinds.scrollToSelectedCell,
      'primary+Enter',
    ),
    goDownCell: _realize(keybinds.goDownCell, 'ArrowDown'),
    goDownCellRetainSelection: _realize(
      keybinds.goDownCellRetainSelection,
      'alt+ArrowDown',
    ),
    goLeftCell: _realize(keybinds.goLeftCell, 'ArrowLeft|shift+Tab'),
    goLeftCellRetainSelection: _realize(
      keybinds.goLeftCellRetainSelection,
      'alt+ArrowLeft',
    ),
    goRightCell: _realize(keybinds.goRightCell, 'ArrowRight|Tab'),
    goRightCellRetainSelection: _realize(
      keybinds.goRightCellRetainSelection,
      'alt+ArrowRight',
    ),
    goUpCell: _realize(keybinds.goUpCell, 'ArrowUp'),
    goUpCellRetainSelection: _realize(
      keybinds.goUpCellRetainSelection,
      'alt+ArrowUp',
    ),
    goToFirstCell: _realize(keybinds.goToFirstCell, 'primary+Home'),
    goToFirstColumn: _realize(
      keybinds.goToFirstColumn,
      'Home|primary+ArrowLeft',
    ),
    goToFirstRow: _realize(keybinds.goToFirstRow, 'primary+ArrowUp'),
    goToLastCell: _realize(keybinds.goToLastCell, 'primary+End'),
    goToLastColumn: _realize(
      keybinds.goToLastColumn,
      'End|primary+ArrowRight',
    ),
    goToLastRow: _realize(keybinds.goToLastRow, 'primary+ArrowDown'),
    goToNextPage: _realize(keybinds.goToNextPage, 'PageDown'),
    goToPreviousPage: _realize(keybinds.goToPreviousPage, 'PageUp'),
    rightFill: _realize(keybinds.rightFill, 'primary+_82'),
    search: _realize(keybinds.search, 'primary+f'),
    selectAll: _realize(keybinds.selectAll, 'primary+a'),
    selectColumn: _realize(keybinds.selectColumn, 'ctrl+ '),
    selectGrowDown: _realize(keybinds.selectGrowDown, 'shift+ArrowDown'),
    selectGrowLeft: _realize(keybinds.selectGrowLeft, 'shift+ArrowLeft'),
    selectGrowRight: _realize(keybinds.selectGrowRight, 'shift+ArrowRight'),
    selectGrowUp: _realize(keybinds.selectGrowUp, 'shift+ArrowUp'),
    selectRow: _realize(keybinds.selectRow, 'shift+ '),
    selectToFirstCell: _realize(
      keybinds.selectToFirstCell,
      'primary+shift+Home',
    ),
    selectToFirstColumn: _realize(
      keybinds.selectToFirstColumn,
      'primary+shift+ArrowLeft',
    ),
    selectToFirstRow: _realize(
      keybinds.selectToFirstRow,
      'primary+shift+ArrowUp',
    ),
    selectToLastCell: _realize(keybinds.selectToLastCell, 'primary+shift+End'),
    selectToLastColumn: _realize(
      keybinds.selectToLastColumn,
      'primary+shift+ArrowRight',
    ),
    selectToLastRow: _realize(
      keybinds.selectToLastRow,
      'primary+shift+ArrowDown',
    ),
  );
}

/// `useKeybindingsWithDefaults` (`data-editor-keybindings.ts:180-198`),
/// including the `pageUp`/`first`/... back-compat aliases.
SemiRealizedKeybinds semiKeysWithDefaults(SemiKeybinds? keysIn) {
  if (keysIn == null) return semiRealizeKeybinds(SemiKeybinds.defaults);

  const defaults = SemiKeybinds.defaults;
  final withBackCompatApplied = SemiKeybinds(
    downFill: keysIn.downFill,
    rightFill: keysIn.rightFill,
    clear: keysIn.clear,
    closeOverlay: keysIn.closeOverlay,
    acceptOverlayDown: keysIn.acceptOverlayDown,
    acceptOverlayUp: keysIn.acceptOverlayUp,
    acceptOverlayLeft: keysIn.acceptOverlayLeft,
    acceptOverlayRight: keysIn.acceptOverlayRight,
    copy: keysIn.copy,
    paste: keysIn.paste,
    cut: keysIn.cut,
    search: keysIn.search,
    delete: keysIn.delete,
    activateCell: keysIn.activateCell,
    scrollToSelectedCell: keysIn.scrollToSelectedCell,
    goToFirstColumn: keysIn.goToFirstColumn,
    goToLastColumn: keysIn.goToLastColumn,
    goToFirstCell: _withAlias(
      keysIn.goToFirstCell,
      keysIn.first,
      defaults.goToFirstCell,
    ),
    goToLastCell: _withAlias(
      keysIn.goToLastCell,
      keysIn.last,
      defaults.goToLastCell,
    ),
    goToFirstRow: keysIn.goToFirstRow,
    goToLastRow: keysIn.goToLastRow,
    goToNextPage: _withAlias(
      keysIn.goToNextPage,
      keysIn.pageDown,
      defaults.goToNextPage,
    ),
    goToPreviousPage: _withAlias(
      keysIn.goToPreviousPage,
      keysIn.pageUp,
      defaults.goToPreviousPage,
    ),
    goUpCell: keysIn.goUpCell,
    goDownCell: keysIn.goDownCell,
    goLeftCell: keysIn.goLeftCell,
    goRightCell: keysIn.goRightCell,
    goUpCellRetainSelection: keysIn.goUpCellRetainSelection,
    goDownCellRetainSelection: keysIn.goDownCellRetainSelection,
    goLeftCellRetainSelection: keysIn.goLeftCellRetainSelection,
    goRightCellRetainSelection: keysIn.goRightCellRetainSelection,
    selectToFirstColumn: keysIn.selectToFirstColumn,
    selectToLastColumn: keysIn.selectToLastColumn,
    selectToFirstCell: _withAlias(
      keysIn.selectToFirstCell,
      keysIn.first,
      defaults.selectToFirstCell,
    ),
    selectToLastCell: _withAlias(
      keysIn.selectToLastCell,
      keysIn.last,
      defaults.selectToLastCell,
    ),
    selectToFirstRow: keysIn.selectToFirstRow,
    selectToLastRow: keysIn.selectToLastRow,
    selectGrowUp: keysIn.selectGrowUp,
    selectGrowDown: keysIn.selectGrowDown,
    selectGrowLeft: keysIn.selectGrowLeft,
    selectGrowRight: keysIn.selectGrowRight,
    selectAll: keysIn.selectAll,
    selectRow: keysIn.selectRow,
    selectColumn: keysIn.selectColumn,
  );
  return semiRealizeKeybinds(withBackCompatApplied);
}
