// 1:1 port of vscode/src/vs/base/browser/ui/highlightedlabel/highlightedLabel.ts
import '../../dom.dart' as dom;
import '../../../common/lifecycle.dart' as lifecycle;
import '../../../common/objects.dart' as objects;
import '../hover/hover.dart' as h;
import '../hover/hoverDelegate.dart' as d;
import '../hover/hoverDelegate2.dart' show getBaseLayerHoverDelegate;
import '../hover/hoverDelegateFactory.dart' show getDefaultHoverDelegate;
import '../iconLabel/iconLabels.dart' show renderLabelWithIcons;

/// 1:1: `export interface IHighlight`.
class IHighlight {
  IHighlight({
    required this.start,
    required this.end,
    this.extraClasses,
  });

  int start;
  int end;
  List<String>? extraClasses;

  Map<String, Object?> _toMap() => <String, Object?>{
        'start': start,
        'end': end,
        'extraClasses': extraClasses,
      };
}

/// 1:1: `export interface IHighlightedLabelOptions`.
class IHighlightedLabelOptions {
  IHighlightedLabelOptions({this.hoverDelegate});

  final d.IHoverDelegate? hoverDelegate;
}

/// 1:1: `export class HighlightedLabel extends Disposable`.
class HighlightedLabel extends lifecycle.Disposable {
  HighlightedLabel(dom.DomElement container, [this.options]) : super() {
    domNode = dom.append(
        container, <Object>[dom.$('span.monaco-highlighted-label')])
        as dom.DomElement;
  }

  final IHighlightedLabelOptions? options;
  late final dom.DomElement domNode;
  String text = '';
  String title = '';
  List<IHighlight> highlights = <IHighlight>[];
  bool didEverRender = false;
  h.IManagedHover? customHover;

  /// 1:1: `get element(): HTMLElement`.
  dom.DomElement get element => domNode;

  static List<Map<String, Object?>> _highlightMaps(List<IHighlight> values) =>
      values.map((IHighlight value) => value._toMap()).toList();

  /// 1:1: `set(text, highlights, title, escapeNewLines, supportIcons)`.
  void set(
    String? value, [
    List<IHighlight> highlights = const <IHighlight>[],
    String title = '',
    bool? escapeNewLines,
    bool? supportIcons,
  ]) {
    String resolvedText = value ?? '';
    if (escapeNewLines ?? false) {
      // adjusts highlights inplace
      resolvedText = HighlightedLabel.escapeNewLines(resolvedText, highlights);
    }

    if (didEverRender &&
        text == resolvedText &&
        this.title == title &&
        objects.equals(
            _highlightMaps(this.highlights), _highlightMaps(highlights))) {
      return;
    }

    text = resolvedText;
    this.title = title;
    this.highlights = highlights;
    _render(supportIcons ?? false);
  }

  void _render(bool supportIcons) {
    final List<Object> children = <Object>[];
    int pos = 0;

    for (final IHighlight highlight in highlights) {
      if (highlight.end == highlight.start) {
        continue;
      }

      if (pos < highlight.start) {
        final String substring = text.substring(pos, highlight.start);
        if (supportIcons) {
          children.addAll(renderLabelWithIcons(substring, true));
        } else {
          children.add(substring);
        }
        pos = highlight.start;
      }

      final String substring = text.substring(pos, highlight.end);
      final dom.DomElement element = dom.$(
        'span.highlight',
        null,
        supportIcons ? renderLabelWithIcons(substring, true) : <Object>[substring],
      );
      final List<String>? extraClasses = highlight.extraClasses;
      if (extraClasses != null) {
        for (final String extraClass in extraClasses) {
          element.classList.add(extraClass);
        }
      }
      children.add(element);
      pos = highlight.end;
    }

    if (pos < text.length) {
      final String substring = text.substring(pos);
      if (supportIcons) {
        children.addAll(renderLabelWithIcons(substring, true));
      } else {
        children.add(substring);
      }
    }

    dom.reset(domNode, children);

    if (customHover == null && title != '') {
      final d.IHoverDelegate hoverDelegate =
          options?.hoverDelegate ?? getDefaultHoverDelegate('mouse');
      final Object? result = getBaseLayerHoverDelegate().setupManagedHover(
          hoverDelegate, domNode, title);
      if (result is h.IManagedHover) {
        customHover = register(result);
      }
    } else if (customHover != null) {
      customHover!.update(title);
    }

    didEverRender = true;
  }

  /// 1:1: `static escapeNewLines(text, highlights)`.
  static String escapeNewLines(String text, List<IHighlight> highlights) {
    int total = 0;
    int extra = 0;

    return text.replaceAllMapped(RegExp(r'\r\n|\r|\n'), (RegExpMatch match) {
      extra = match.group(0) == '\r\n' ? -1 : 0;
      int offset = match.start + total;

      for (final IHighlight highlight in highlights) {
        if (highlight.end <= offset) {
          continue;
        }
        if (highlight.start >= offset) {
          highlight.start += extra;
        }
        if (highlight.end >= offset) {
          highlight.end += extra;
        }
      }

      total += extra;
      return '\u23CE';
    });
  }
}
