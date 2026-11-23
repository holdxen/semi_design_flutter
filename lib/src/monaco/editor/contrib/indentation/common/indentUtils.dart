// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/indentation/common/indentUtils.ts
// Translated 1:1 from TypeScript.
// ---------------------------------------------------------------------------

/// 1:1: `export function getSpaceCnt(str, tabSize)`
int getSpaceCnt(String str, int tabSize) {
  int spacesCnt = 0;

  for (int i = 0; i < str.length; i++) {
    if (str[i] == '\t') {
      spacesCnt += tabSize;
    } else {
      spacesCnt++;
    }
  }

  return spacesCnt;
}

/// 1:1: `export function generateIndent(spacesCnt, tabSize, insertSpaces)`
String generateIndent(int spacesCnt, int tabSize, bool insertSpaces) {
  if (spacesCnt < 0) {
    spacesCnt = 0;
  }

  final StringBuffer result = StringBuffer();
  if (!insertSpaces) {
    final int tabsCnt = spacesCnt ~/ tabSize;
    spacesCnt = spacesCnt % tabSize;
    for (int i = 0; i < tabsCnt; i++) {
      result.write('\t');
    }
  }

  for (int i = 0; i < spacesCnt; i++) {
    result.write(' ');
  }

  return result.toString();
}
