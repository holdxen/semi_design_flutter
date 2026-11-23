// 1:1 port of vscode/src/vs/editor/common/model/utils.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c

import '../../../base/common/charCode.dart';

/// 1:1: `export function computeIndentLevel`
///
/// Returns:
///  - -1 => the line consists of whitespace
///  - otherwise => the indent level is returned value
int computeIndentLevel(String line, int tabSize) {
  int indent = 0;
  int i = 0;
  final int len = line.length;

  while (i < len) {
    final int chCode = line.codeUnitAt(i);
    if (chCode == CharCode.Space) {
      indent++;
    } else if (chCode == CharCode.Tab) {
      indent = indent - indent % tabSize + tabSize;
    } else {
      break;
    }
    i++;
  }

  if (i == len) {
    return -1; // line only consists of whitespace
  }

  return indent;
}
