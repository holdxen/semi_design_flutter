// 1:1 port of vscode/src/vs/base/browser/ui/severityIcon/severityIcon.ts

import '../../../common/codicons.dart' show Codicon;
import '../../../common/severity.dart' show Severity;
import '../../../common/themables.dart' show ThemeIcon;

/// 1:1: `export namespace SeverityIcon { export function className(...) }`
class SeverityIcon {
  /// 1:1: `SeverityIcon.className(severity)`
  static String className(int severity) {
    switch (severity) {
      case Severity.Ignore:
        return 'severity-ignore ' + ThemeIcon.asClassName(Codicon['info']!);
      case Severity.Info:
        return ThemeIcon.asClassName(Codicon['info']!);
      case Severity.Warning:
        return ThemeIcon.asClassName(Codicon['warning']!);
      case Severity.Error:
        return ThemeIcon.asClassName(Codicon['error']!);
      default:
        return '';
    }
  }
}
