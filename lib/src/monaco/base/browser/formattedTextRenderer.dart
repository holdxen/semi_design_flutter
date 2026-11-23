// 1:1 port of vs/base/browser/formattedTextRenderer.ts
import 'dom.dart' as DOM
    show DomElement, DomNode, EventType, addStandardDisposableListener;
import 'dom.dart' show DomElement, DomNode;
import 'dom.dart' show document;
import '../common/lifecycle.dart' show DisposableStore;

/// 1:1: `interface IContentActionHandler`
class IContentActionHandler {
  final void Function(String content, Object event) callback;
  final DisposableStore disposables;

  IContentActionHandler({required this.callback, required this.disposables});
}

/// 1:1: `interface FormattedTextRenderOptions`
class FormattedTextRenderOptions {
  final IContentActionHandler? actionHandler;
  final bool renderCodeSegments;

  const FormattedTextRenderOptions({
    this.actionHandler,
    this.renderCodeSegments = false,
  });
}

/// 1:1: `renderText`
DomElement renderText(String text,
    [FormattedTextRenderOptions? options, DomElement? target]) {
  final DomElement element = target ?? document.createElement('div');
  element.textContent = text;
  return element;
}

/// 1:1: `renderFormattedText`
DomElement renderFormattedText(String formattedText,
    [FormattedTextRenderOptions? options, DomElement? target]) {
  final DomElement element = target ?? document.createElement('div');
  element.textContent = '';
  _renderFormattedText(
    element,
    parseFormattedText(formattedText, options?.renderCodeSegments ?? false),
    options?.actionHandler,
    options?.renderCodeSegments,
  );
  return element;
}

class StringStream {
  final String source;
  int index = 0;

  StringStream(this.source);

  bool eos() => index >= source.length;
  String next() {
    final String value = peek();
    advance();
    return value;
  }

  String peek() => index < source.length ? source[index] : '';
  void advance() => index++;
}

class FormatType {
  static const int Invalid = 0;
  static const int Root = 1;
  static const int Text = 2;
  static const int Bold = 3;
  static const int Italics = 4;
  static const int Action = 5;
  static const int ActionClose = 6;
  static const int Code = 7;
  static const int NewLine = 8;

  const FormatType._();
}

class IFormatParseTree {
  final int type;
  String content;
  int index;
  List<IFormatParseTree>? children;

  IFormatParseTree(this.type,
      {this.content = '', this.index = 0, this.children});
}

void _renderFormattedText(
  DomNode element,
  IFormatParseTree treeNode, [
  IContentActionHandler? actionHandler,
  bool? renderCodeSegments,
]) {
  DomNode? child;

  if (treeNode.type == FormatType.Text) {
    child = document.createTextNode(treeNode.content);
  } else if (treeNode.type == FormatType.Bold) {
    child = document.createElement('b');
  } else if (treeNode.type == FormatType.Italics) {
    child = document.createElement('i');
  } else if (treeNode.type == FormatType.Code && renderCodeSegments == true) {
    child = document.createElement('code');
  } else if (treeNode.type == FormatType.Action && actionHandler != null) {
    final DomElement a = document.createElement('a');
    final int actionIndex = treeNode.index;
    actionHandler.disposables.add(DOM.addStandardDisposableListener(
        a, DOM.EventType.CLICK, (Object event) {
      actionHandler.callback(actionIndex.toString(), event);
    }));
    child = a;
  } else if (treeNode.type == FormatType.NewLine) {
    child = document.createElement('br');
  } else if (treeNode.type == FormatType.Root) {
    child = element;
  }

  if (child != null && !identical(element, child)) {
    element.appendChild(child);
  }

  final List<IFormatParseTree>? children = treeNode.children;
  if (child != null && children != null) {
    for (final IFormatParseTree nodeChild in children) {
      _renderFormattedText(child, nodeChild, actionHandler, renderCodeSegments);
    }
  }
}

/// 1:1: `parseFormattedText`
IFormatParseTree parseFormattedText(String content, bool parseCodeSegments) {
  final IFormatParseTree root = IFormatParseTree(FormatType.Root, children: []);

  int actionViewItemIndex = 0;
  IFormatParseTree current = root;
  final List<IFormatParseTree> stack = <IFormatParseTree>[];
  final StringStream stream = StringStream(content);

  while (!stream.eos()) {
    String next = stream.next();

    final bool isEscapedFormatType = next == '\\' &&
        formatTagType(stream.peek(), parseCodeSegments) != FormatType.Invalid;
    if (isEscapedFormatType) {
      next = stream.next();
    }

    if (!isEscapedFormatType &&
        isFormatTag(next, parseCodeSegments) &&
        next == stream.peek()) {
      stream.advance();

      if (current.type == FormatType.Text) {
        current = stack.removeLast();
      }

      final int type = formatTagType(next, parseCodeSegments);
      if (current.type == type ||
          (current.type == FormatType.Action &&
              type == FormatType.ActionClose)) {
        current = stack.removeLast();
      } else {
        final IFormatParseTree newCurrent = IFormatParseTree(type, children: []);
        if (type == FormatType.Action) {
          newCurrent.index = actionViewItemIndex;
          actionViewItemIndex++;
        }
        current.children!.add(newCurrent);
        stack.add(current);
        current = newCurrent;
      }
    } else if (next == '\n') {
      if (current.type == FormatType.Text) {
        current = stack.removeLast();
      }
      current.children!.add(IFormatParseTree(FormatType.NewLine));
    } else {
      if (current.type != FormatType.Text) {
        final IFormatParseTree textCurrent =
            IFormatParseTree(FormatType.Text, content: next);
        current.children!.add(textCurrent);
        stack.add(current);
        current = textCurrent;
      } else {
        current.content += next;
      }
    }
  }

  if (current.type == FormatType.Text) {
    current = stack.removeLast();
  }

  // Incorrectly formatted string literals are left as-is (no error).
  return root;
}

bool isFormatTag(String char, bool supportCodeSegments) =>
    formatTagType(char, supportCodeSegments) != FormatType.Invalid;

int formatTagType(String char, bool supportCodeSegments) {
  switch (char) {
    case '*':
      return FormatType.Bold;
    case '_':
      return FormatType.Italics;
    case '[':
      return FormatType.Action;
    case ']':
      return FormatType.ActionClose;
    case '`':
      return supportCodeSegments ? FormatType.Code : FormatType.Invalid;
    default:
      return FormatType.Invalid;
  }
}
