// 1:1 port of vs/base/browser/ui/iconLabel/iconLabels.ts
import '../../dom.dart' as dom;
import '../../../common/themables.dart' as themables;

/// 1:1: `labelWithIconsRegex`
final RegExp labelWithIconsRegex = RegExp(r'(\\)?\$\((' +
    themables.ThemeIcon.iconNameExpression +
    r'(?:' +
    themables.ThemeIcon.iconModifierExpression +
    r')?)\)');

/// 1:1: `renderLabelWithIcons`
List<Object> renderLabelWithIcons(String text, [bool? renderIconsInDefaultColor]) {
  final List<Object> elements = <Object>[];

  int textStart = 0;
  int textStop = 0;
  for (final RegExpMatch match in labelWithIconsRegex.allMatches(text)) {
    textStop = match.start;
    if (textStart < textStop) {
      elements.add(text.substring(textStart, textStop));
    }
    textStart = match.start + match.group(0)!.length;

    final String? escaped = match.group(1);
    final String codicon = match.group(2)!;
    elements.add(escaped != null
        ? '\$($codicon)'
        : renderIcon(themables.ThemeIcon(codicon), renderIconsInDefaultColor));
  }

  if (textStart < text.length) {
    elements.add(text.substring(textStart));
  }
  return elements;
}

/// 1:1: `renderIcon`
dom.DomElement renderIcon(themables.ThemeIcon icon, [bool? renderDefaultColor]) {
  final dom.DomElement node = dom.$('span');
  final List<String> classes = themables.ThemeIcon.asClassNameArray(icon);
  if (renderDefaultColor == true) {
    classes.add('codicon-colored');
  }
  for (final String c in classes) {
    node.classList.add(c);
  }
  return node;
}
