// 1:1 port of vscode/src/vs/editor/common/diff/linesDiffComputers.ts

import 'defaultLinesDiffComputer/defaultLinesDiffComputer.dart'
    show DefaultLinesDiffComputer;
import 'externalLinesDiffComputer.dart' show getExternalLinesDiffComputer;
import 'legacyLinesDiffComputer.dart' show LegacyLinesDiffComputer;
import 'linesDiffComputer.dart' show ILinesDiffComputer;

/// 1:1: `export const linesDiffComputers = { ... satisfies Record<...> }`
class LinesDiffComputers {
  ILinesDiffComputer getLegacy() => LegacyLinesDiffComputer();

  ILinesDiffComputer getDefault() => DefaultLinesDiffComputer();

  Future<ILinesDiffComputer> getAdvancedExternal() =>
      getExternalLinesDiffComputer(false);

  Future<ILinesDiffComputer> getAdvancedWasm() =>
      getExternalLinesDiffComputer(true);
}

final LinesDiffComputers linesDiffComputers = LinesDiffComputers();
