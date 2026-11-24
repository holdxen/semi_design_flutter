// 1:1 port of vscode/src/vs/base/browser/ui/iconLabel/iconLabel.ts
//
// DOM, URI and ThemeIcon are carried by the existing dom/common ports. The
// file keeps the source's class structure and control flow; only JS union and
// object-literal semantics are projected onto Dart carriers.
import '../../../common/filters.dart' show IMatch;
import '../../../common/lifecycle.dart' as lifecycle;
import '../../../common/range.dart' as range;
import '../../../common/themables.dart' show ThemeIcon;
import '../../../common/uri.dart' show URI;
import '../../cssValue.dart' as css;
import '../../dom.dart' as dom;
import '../highlightedlabel/highlightedLabel.dart'
    show HighlightedLabel, IHighlight;
import '../hover/hover.dart' show IManagedHover;
import '../hover/hoverDelegate.dart' show IHoverDelegate;
import '../hover/hoverDelegate2.dart' show getBaseLayerHoverDelegate;
import '../hover/hoverDelegateFactory.dart' show getDefaultHoverDelegate;

/// 1:1: `export interface IIconLabelCreationOptions`.
class IIconLabelCreationOptions {
  IIconLabelCreationOptions({
    this.supportHighlights,
    this.supportDescriptionHighlights,
    this.supportIcons,
    this.hoverDelegate,
    this.hoverTargetOverride,
  });

  final bool? supportHighlights;
  final bool? supportDescriptionHighlights;
  final bool? supportIcons;
  final IHoverDelegate? hoverDelegate;
  final dom.DomElement? hoverTargetOverride;
}

/// 1:1: `export interface IIconLabelValueOptions`.
class IIconLabelValueOptions {
  IIconLabelValueOptions({
    this.title,
    this.descriptionTitle,
    this.suffix,
    this.hideIcon,
    this.extraClasses,
    this.bold,
    this.italic,
    this.strikethrough,
    this.matches,
    this.labelEscapeNewLines,
    this.descriptionMatches,
    this.disabledCommand,
    this.separator,
    this.domId,
    this.iconPath,
    this.iconColor,
    this.supportIcons,
  });

  /// TS: `string | IManagedHoverTooltipMarkdownString`.
  Object? title;
  Object? descriptionTitle;
  String? suffix;
  bool? hideIcon;
  List<String>? extraClasses;
  bool? bold;
  bool? italic;
  bool? strikethrough;
  List<IMatch>? matches;
  bool? labelEscapeNewLines;
  List<IMatch>? descriptionMatches;
  bool? disabledCommand;
  String? separator;
  String? domId;

  /// TS: `URI | ThemeIcon`.
  Object? iconPath;
  String? iconColor;
  bool? supportIcons;
}

class FastLabelNode implements lifecycle.IDisposable {
  FastLabelNode(this._element);

  final dom.DomElement _element;
  bool disposed = false;
  String? _textContent;
  List<String>? _classNames;
  bool? _empty;

  dom.DomElement get element => _element;

  set textContent(String content) {
    if (disposed || content == _textContent) {
      return;
    }
    _textContent = content;
    _element.textContent = content;
  }

  set classNames(List<String> classNames) {
    if (disposed || _jsEquals(classNames, _classNames)) {
      return;
    }
    _classNames = classNames;
    _element.className = '';
    for (final String className in classNames) {
      _element.classList.add(className);
    }
  }

  set empty(bool empty) {
    if (disposed || empty == _empty) {
      return;
    }
    _empty = empty;
    _element.style.setProperty('marginLeft', empty ? '0' : '');
  }

  @override
  void dispose() {
    disposed = true;
  }
}

abstract class _ILabelNode {
  void setLabel(Object label, [IIconLabelValueOptions? options]);
}

/// 1:1: `export class IconLabel extends Disposable`.
class IconLabel extends lifecycle.Disposable {
  IconLabel(dom.DomElement container, [this.creationOptions]) : super() {
    domNode = register(FastLabelNode(
      dom.append(
        container,
        <Object>[dom.$('.monaco-icon-label')],
      ) as dom.DomElement,
    ));

    labelContainer = dom.append(
      domNode.element,
      <Object>[dom.$('.monaco-icon-label-container')],
    ) as dom.DomElement;

    nameContainer = dom.append(
      labelContainer,
      <Object>[dom.$('span.monaco-icon-name-container')],
    ) as dom.DomElement;

    if (creationOptions?.supportHighlights == true ||
        creationOptions?.supportIcons == true) {
      nameNode = register<LabelWithHighlights>(LabelWithHighlights(
        nameContainer,
        creationOptions?.supportIcons ?? false,
      ));
    } else {
      nameNode = Label(nameContainer);
    }

    hoverDelegate =
        creationOptions?.hoverDelegate ?? getDefaultHoverDelegate('mouse');
  }

  final IIconLabelCreationOptions? creationOptions;

  late final FastLabelNode domNode;
  late final dom.DomElement nameContainer;
  late final _ILabelNode nameNode;

  Object? descriptionNode;
  FastLabelNode? suffixNode;

  late final dom.DomElement labelContainer;

  late final IHoverDelegate hoverDelegate;
  final Map<dom.DomElement, lifecycle.IDisposable> customHovers =
      <dom.DomElement, lifecycle.IDisposable>{};

  /// 1:1: `get element(): HTMLElement`.
  dom.DomElement get element => domNode.element;

  /// 1:1: `setLabel(label, description?, options?)`.
  void setLabel(
    Object label, [
    String? description,
    IIconLabelValueOptions? options,
  ]) {
    final List<String> labelClasses = <String>['monaco-icon-label'];
    final List<String> containerClasses = <String>[
      'monaco-icon-label-container'
    ];
    String ariaLabel = '';
    if (options != null) {
      if (options.extraClasses != null) {
        labelClasses.addAll(options.extraClasses!);
      }
      if (options.bold == true) {
        labelClasses.add('bold');
      }
      if (options.italic == true) {
        labelClasses.add('italic');
      }
      if (options.strikethrough == true) {
        labelClasses.add('strikethrough');
      }
      if (options.iconColor != null) {
        labelClasses.add('colored-icon');
      }
      if (options.disabledCommand == true) {
        containerClasses.add('disabled');
      }
      if (options.title != null) {
        if (options.title is String) {
          ariaLabel += options.title as String;
        } else {
          ariaLabel += _toJsString(label);
        }
      }
    }

    // eslint-disable-next-line eslint-js/no-restricted-syntax
    final dom.DomElement? existingIconNode =
        _querySelector(domNode.element, '.monaco-icon-label-iconpath');
    if (options?.iconPath != null) {
      dom.DomElement iconNode;
      if (existingIconNode == null || !dom.isHTMLElement(existingIconNode)) {
        iconNode = dom.$('.monaco-icon-label-iconpath');
        dom.prepend(domNode.element, iconNode);
      } else {
        iconNode = existingIconNode;
      }
      if (ThemeIcon.isThemeIcon(options!.iconPath)) {
        final String iconClass =
            ThemeIcon.asClassName(options.iconPath as ThemeIcon);
        iconNode.className = 'monaco-icon-label-iconpath $iconClass';
        iconNode.style.setProperty('backgroundImage', '');
      } else {
        iconNode.className = 'monaco-icon-label-iconpath';
        iconNode.style.setProperty(
          'backgroundImage',
          css.asCSSUrl(options.iconPath as URI),
        );
      }
      iconNode.style.setProperty('backgroundRepeat', 'no-repeat');
      iconNode.style.setProperty('backgroundPosition', 'center');
      iconNode.style.setProperty('backgroundSize', 'contain');
    } else if (existingIconNode != null) {
      existingIconNode.remove();
    }

    domNode.classNames = labelClasses;
    if (options?.iconColor != null) {
      domNode.element.style.setProperty(
        '--monaco-icon-label-icon-color',
        options!.iconColor!,
      );
    } else {
      domNode.element.style.remove('--monaco-icon-label-icon-color');
    }
    domNode.element.setAttribute('aria-label', ariaLabel);
    labelContainer.className = '';
    for (final String className in containerClasses) {
      labelContainer.classList.add(className);
    }
    setupHover(
      options?.descriptionTitle != null ? labelContainer : element,
      options?.title,
    );

    nameNode.setLabel(label, options);

    if (description != null || descriptionNode != null) {
      final Object node = getOrCreateDescriptionNode();
      if (node is HighlightedLabel) {
        final bool? supportIcons =
            options?.supportIcons ?? creationOptions?.supportIcons;
        node.set(
          description ?? '',
          options == null
              ? const <IHighlight>[]
              : _toHighlights(options.descriptionMatches),
          '',
          options?.labelEscapeNewLines,
          supportIcons,
        );
        setupHover(node.element, options?.descriptionTitle);
      } else {
        final FastLabelNode fastNode = node as FastLabelNode;
        fastNode.textContent = description != null &&
                options?.labelEscapeNewLines == true
            ? HighlightedLabel.escapeNewLines(description, <IHighlight>[])
            : (description ?? '');
        setupHover(fastNode.element, options?.descriptionTitle ?? '');
        fastNode.empty = description == null || description.isEmpty;
      }
    }

    if (_isTruthy(options?.suffix) || suffixNode != null) {
      final FastLabelNode node = getOrCreateSuffixNode();
      node.textContent = options?.suffix ?? '';
    }
  }

  /// 1:1: `private setupHover(htmlElement, tooltip)`.
  void setupHover(dom.DomElement htmlElement, Object? tooltip) {
    final lifecycle.IDisposable? previousCustomHover =
        customHovers[htmlElement];
    if (previousCustomHover != null) {
      previousCustomHover.dispose();
      customHovers.remove(htmlElement);
    }

    if (_isFalsy(tooltip)) {
      htmlElement.removeAttribute('title');
      return;
    }

    dom.DomElement hoverTarget = htmlElement;
    final dom.DomElement? overrideTarget = creationOptions?.hoverTargetOverride;
    if (overrideTarget != null) {
      if (!dom.isAncestor(htmlElement, overrideTarget)) {
        throw StateError(
          'hoverTargetOverrride must be an ancestor of the htmlElement',
        );
      }
      hoverTarget = overrideTarget;
    }

    final IManagedHover hoverDisposable = getBaseLayerHoverDelegate()
        .setupManagedHover(hoverDelegate, hoverTarget, tooltip);
    customHovers[htmlElement] = hoverDisposable;
  }

  @override
  void dispose() {
    super.dispose();
    for (final lifecycle.IDisposable disposable in customHovers.values) {
      disposable.dispose();
    }
    customHovers.clear();
  }

  /// 1:1: `private getOrCreateSuffixNode()`.
  FastLabelNode getOrCreateSuffixNode() {
    if (suffixNode == null) {
      final FastLabelNode suffixContainer = register(FastLabelNode(
        dom.after(
          nameContainer,
          dom.$('span.monaco-icon-suffix-container'),
        ),
      ));
      suffixNode = register(FastLabelNode(
        dom.append(
          suffixContainer.element,
          <Object>[dom.$('span.label-suffix')],
        ) as dom.DomElement,
      ));
    }
    return suffixNode!;
  }

  /// 1:1: `private getOrCreateDescriptionNode()`.
  Object getOrCreateDescriptionNode() {
    if (descriptionNode == null) {
      final FastLabelNode descriptionContainer = register(FastLabelNode(
        dom.append(
          labelContainer,
          <Object>[dom.$('span.monaco-icon-description-container')],
        ) as dom.DomElement,
      ));
      final dom.DomElement labelElement = dom.append(
        descriptionContainer.element,
        <Object>[dom.$('span.label-description')],
      ) as dom.DomElement;
      if (creationOptions?.supportDescriptionHighlights == true) {
        descriptionNode = register(HighlightedLabel(labelElement));
      } else {
        descriptionNode = register(FastLabelNode(labelElement));
      }
    }
    return descriptionNode!;
  }
}

class Label implements _ILabelNode {
  Label(this.container);

  final dom.DomElement container;
  Object? label;
  dom.DomElement? singleLabel;
  IIconLabelValueOptions? options;

  @override
  void setLabel(Object value, [IIconLabelValueOptions? newOptions]) {
    if (_labelEquals(label, value) && _jsEquals(_optionMap(options), _optionMap(newOptions))) {
      return;
    }

    label = value;
    options = newOptions;

    if (value is String) {
      if (singleLabel == null) {
        container.textContent = '';
        container.classList.remove('multiple');
        singleLabel = dom.append(
          container,
          <Object>[
            dom.$('a.label-name', <String, Object?>{'id': newOptions?.domId}),
          ],
        ) as dom.DomElement;
      }
      singleLabel!.textContent = value;
    } else {
      container.textContent = '';
      container.classList.add('multiple');
      singleLabel = null;

      final List<Object> labels = value as List<Object>;
      for (int i = 0; i < labels.length; i++) {
        final Object l = labels[i];
        final Object? id = newOptions?.domId == null
            ? null
            : '${newOptions!.domId}_$i';

        dom.append(
          container,
          <Object>[
            dom.$(
              'a.label-name',
              <String, Object?>{
                'id': id,
                'data-icon-label-count': labels.length,
                'data-icon-label-index': i,
                'role': 'treeitem',
              },
              <Object>[l],
            ),
          ],
        );

        if (i < labels.length - 1) {
          dom.append(
            container,
            <Object>[
              dom.$('span.label-separator', null, <Object>[
                newOptions?.separator ?? '/',
              ]),
            ],
          );
        }
      }
    }
  }
}

/// 1:1: `function splitMatches(labels, separator, matches)`.
List<List<IHighlight>>? splitMatches(
  List<String> labels,
  String separator,
  List<IMatch>? matches,
) {
  if (matches == null) {
    return null;
  }

  int labelStart = 0;

  return labels.map((String label) {
    final range.IRange labelRange =
        range.IRange(labelStart, labelStart + label.length);

    final List<IHighlight> result = matches
        .map((IMatch match) => range.Range.intersect(
              labelRange,
              range.IRange(match.start, match.end),
            ))
        .where((range.IRange value) => !range.Range.isEmpty(value))
        .map((range.IRange value) => IHighlight(
              start: value.start.toInt() - labelStart,
              end: value.end.toInt() - labelStart,
            ))
        .toList();

    labelStart = labelRange.end.toInt() + separator.length;
    return result;
  }).toList();
}

class LabelWithHighlights extends lifecycle.Disposable
    implements _ILabelNode {
  LabelWithHighlights(this.container, this.supportIcons) : super() {
    _labelDisposables = register(lifecycle.DisposableStore());
  }

  final dom.DomElement container;
  final bool supportIcons;

  Object? label;
  HighlightedLabel? singleLabel;
  IIconLabelValueOptions? options;
  late final lifecycle.DisposableStore _labelDisposables;

  @override
  void setLabel(Object value, [IIconLabelValueOptions? newOptions]) {
    if (_labelEquals(label, value) &&
        _jsEquals(_optionMap(options), _optionMap(newOptions))) {
      return;
    }

    label = value;
    options = newOptions;

    // Determine supportIcons: use option if provided, otherwise use constructor value
    final bool resolvedSupportIcons =
        newOptions?.supportIcons ?? supportIcons;

    if (value is String) {
      if (singleLabel == null) {
        _labelDisposables.clear();
        container.textContent = '';
        container.classList.remove('multiple');
        singleLabel = _labelDisposables.add(HighlightedLabel(
          dom.append(
            container,
            <Object>[
              dom.$('a.label-name', <String, Object?>{'id': newOptions?.domId}),
            ],
          ) as dom.DomElement,
        ));
      }

      singleLabel!.set(
        value,
        _toHighlights(newOptions?.matches),
        '',
        newOptions?.labelEscapeNewLines,
        resolvedSupportIcons,
      );
    } else {
      _labelDisposables.clear();
      container.textContent = '';
      container.classList.add('multiple');
      singleLabel = null;

      final List<String> labels = (value as List<Object>).cast<String>();
      final String separator = newOptions?.separator ?? '/';
      final List<List<IHighlight>>? matches =
          splitMatches(labels, separator, newOptions?.matches);

      for (int i = 0; i < labels.length; i++) {
        final String l = labels[i];
        final List<IHighlight>? m = matches == null ? null : matches[i];
        final Object? id = newOptions?.domId == null
            ? null
            : '${newOptions!.domId}_$i';

        final dom.DomElement name = dom.$(
          'a.label-name',
          <String, Object?>{
            'id': id,
            'data-icon-label-count': labels.length,
            'data-icon-label-index': i,
            'role': 'treeitem',
          },
        );
        final HighlightedLabel highlightedLabel = _labelDisposables.add(
          HighlightedLabel(
            dom.append(container, <Object>[name]) as dom.DomElement,
          ),
        );
        highlightedLabel.set(
          l,
          m ?? const <IHighlight>[],
          '',
          newOptions?.labelEscapeNewLines,
          resolvedSupportIcons,
        );

        if (i < labels.length - 1) {
          dom.append(
            name,
            <Object>[
              dom.$('span.label-separator', null, <Object>[separator]),
            ],
          );
        }
      }
    }
  }
}

/// DOM `querySelector` subset used by iconLabel.ts (descendant class lookup).
dom.DomElement? _querySelector(dom.DomElement root, String selector) {
  if (!selector.startsWith('.')) {
    return null;
  }
  final String className = selector.substring(1);
  for (final dom.DomNode child in root.childNodes) {
    if (child is! dom.DomElement) {
      continue;
    }
    if (child.classList.contains(className)) {
      return child;
    }
    final dom.DomElement? found = _querySelector(child, selector);
    if (found != null) {
      return found;
    }
  }
  return null;
}

List<IHighlight> _toHighlights(List<IMatch>? matches) =>
    matches == null
        ? const <IHighlight>[]
        : matches
            .map((IMatch match) =>
                IHighlight(start: match.start, end: match.end))
            .toList();

Map<String, Object?>? _optionMap(IIconLabelValueOptions? o) {
  if (o == null) {
    return null;
  }
  return <String, Object?>{
    'title': o.title,
    'descriptionTitle': o.descriptionTitle,
    'suffix': o.suffix,
    'hideIcon': o.hideIcon,
    'extraClasses': o.extraClasses,
    'bold': o.bold,
    'italic': o.italic,
    'strikethrough': o.strikethrough,
    'matches': o.matches == null
        ? null
        : o.matches!.map((IMatch m) => <String, Object?>{
            'start': m.start,
            'end': m.end,
          }).toList(),
    'labelEscapeNewLines': o.labelEscapeNewLines,
    'descriptionMatches': o.descriptionMatches == null
        ? null
        : o.descriptionMatches!.map((IMatch m) => <String, Object?>{
            'start': m.start,
            'end': m.end,
          }).toList(),
    'disabledCommand': o.disabledCommand,
    'separator': o.separator,
    'domId': o.domId,
    'iconPath': o.iconPath,
    'iconColor': o.iconColor,
    'supportIcons': o.supportIcons,
  };
}

/// Mirrors TS `objects.equals` for the object literals used here, including
/// JS string/number value equality. Non-carrier objects keep identity equality.
bool _jsEquals(Object? a, Object? b) {
  if (identical(a, b)) {
    return true;
  }
  if (a == null || b == null) {
    return false;
  }
  if (a is String || b is String) {
    return a is String && b is String && a == b;
  }
  if (a is num || b is num) {
    return a is num && b is num && a == b;
  }
  if (a is bool || b is bool) {
    return a is bool && b is bool && a == b;
  }
  if (a is List || b is List) {
    if (a is! List || b is! List || a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (!_jsEquals(a[i], b[i])) {
        return false;
      }
    }
    return true;
  }
  if (a is Map || b is Map) {
    if (a is! Map || b is! Map || a.length != b.length) {
      return false;
    }
    for (final Object? key in a.keys) {
      if (!b.containsKey(key) || !_jsEquals(a[key], b[key])) {
        return false;
      }
    }
    return true;
  }
  return false;
}

bool _labelEquals(Object? a, Object? b) {
  if (a is String && b is String) {
    return a == b;
  }
  return identical(a, b);
}

bool _isTruthy(Object? value) => !_isFalsy(value);

bool _isFalsy(Object? value) {
  if (value == null) {
    return true;
  }
  if (value is bool) {
    return !value;
  }
  if (value is num) {
    return value == 0 || value.isNaN;
  }
  if (value is String) {
    return value.isEmpty;
  }
  if (value is List) {
    return value.isEmpty;
  }
  if (value is Map) {
    return value.isEmpty;
  }
  return false;
}

String _toJsString(Object? value) {
  if (value == null) {
    return 'null';
  }
  if (value is String) {
    return value;
  }
  if (value is bool) {
    return value ? 'true' : 'false';
  }
  if (value is List) {
    return value.map(_toJsString).join(',');
  }
  return value.toString();
}
