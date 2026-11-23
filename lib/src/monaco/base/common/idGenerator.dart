// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/idGenerator.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript.
// ---------------------------------------------------------------------------

class IdGenerator {
  late final String _prefix;
  late int _lastId;

  IdGenerator(String prefix) {
    _prefix = prefix;
    _lastId = 0;
  }

  String nextId() {
    return _prefix + (++_lastId).toString();
  }
}

final IdGenerator defaultGenerator = IdGenerator('id#');
