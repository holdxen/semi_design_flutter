// 1:1 port of
// vscode/src/vs/editor/browser/viewParts/viewZones/viewZones.ts (423 lines)
// @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
//
// Adaptations:
//   - `editorBrowser.ts` (IViewZone / IViewZoneChangeAccessor) and the
//     `viewModel.ts` whitespace interfaces are erased; narrow file-local
//     carriers expose only the members this part reads.
//   - DOM creation / FastDomNode wrapping are injectable replay boundaries;
//     the default uses the ported `document` and `createFastDomNode`.
//   - JS `zone.ordinal ?? zone.afterColumn ?? 10000` maps to explicit null
//     checks, and `Object.keys` order is Dart `Map` insertion order.

import '../../../../base/browser/dom.dart' show document;
import '../../../../base/browser/fastDomNode.dart'
    show DomElement, FastDomNode, createFastDomNode;
import '../../../../base/common/errors.dart' show onUnexpectedError;
import '../../../common/config/editorOptions.dart'
    show ConfigurationChangedEvent, EditorOption;
import '../../../common/core/position.dart' show Position;
import '../../../common/viewEvents.dart' show ViewScrollChangedEvent;
import '../../../common/viewModel/viewContext.dart' show ViewContext;
import '../../view/renderingContext.dart'
    show RenderingContext, RestrictedRenderingContext;
import '../../view/viewPart.dart' show ViewPart;

/// The subset of an `HTMLElement` touched by this part.
abstract class IViewZonesDomElement {
  Map<String, String> get style;
  void remove();
}

/// The subset of `FastDomNode<HTMLElement>` touched by this part.
abstract class IViewZonesFastDomNode {
  Object get domNode;
  void setClassName(String value);
  void setPosition(String value);
  void setAttribute(String name, String value);
  void removeAttribute(String name);
  void setDisplay(String value);
  void setTop(Object value);
  void setHeight(Object value);
  void setWidth(Object value);
  void appendChild(IViewZonesFastDomNode child);
}

class _FastDomNodeAdapter implements IViewZonesFastDomNode {
  _FastDomNodeAdapter(this._node);

  final FastDomNode<DomElement> _node;

  @override
  Object get domNode => _node.domNode;

  @override
  void setClassName(String value) => _node.setClassName(value);

  @override
  void setPosition(String value) => _node.setPosition(value);

  @override
  void setAttribute(String name, String value) => _node.setAttribute(name, value);

  @override
  void removeAttribute(String name) => _node.removeAttribute(name);

  @override
  void setDisplay(String value) => _node.setDisplay(value);

  @override
  void setTop(Object value) => _node.setTop(value);

  @override
  void setHeight(Object value) => _node.setHeight(value);

  @override
  void setWidth(Object value) => _node.setWidth(value);

  @override
  void appendChild(IViewZonesFastDomNode child) =>
      _node.appendChild((child as _FastDomNodeAdapter)._node);
}

Object Function(String tag)? _elementFactoryForReplay;
IViewZonesFastDomNode Function(Object domNode)? _fastDomNodeFactoryForReplay;
void Function(Object error)? _unexpectedErrorForReplay;

void configureViewZonesElementFactoryForReplay(
  Object Function(String tag)? factory,
) {
  _elementFactoryForReplay = factory;
}

void configureViewZonesFastDomNodeFactoryForReplay(
  IViewZonesFastDomNode Function(Object domNode)? factory,
) {
  _fastDomNodeFactoryForReplay = factory;
}

void configureViewZonesUnexpectedErrorForReplay(
  void Function(Object error)? handler,
) {
  _unexpectedErrorForReplay = handler;
}

Object _createElement(String tag) =>
    _elementFactoryForReplay?.call(tag) ?? document.createElement(tag);

IViewZonesFastDomNode _wrapFastDomNode(Object domNode) {
  final IViewZonesFastDomNode Function(Object)? factory =
      _fastDomNodeFactoryForReplay;
  if (factory != null) {
    return factory(domNode);
  }
  return _FastDomNodeAdapter(
      createFastDomNode<DomElement>(domNode as DomElement));
}

void _onUnexpectedError(Object error) {
  final void Function(Object)? handler = _unexpectedErrorForReplay;
  if (handler != null) {
    handler(error);
    return;
  }
  onUnexpectedError(error);
}

/// 1:1: `interface IMyViewZone`.
class IMyViewZoneForViewZones {
  IMyViewZoneForViewZones({
    required this.whitespaceId,
    required this.delegate,
    required this.isInHiddenArea,
    required this.isVisible,
    required this.domNode,
    required this.marginDomNode,
  });

  String whitespaceId;
  Object delegate;
  bool isInHiddenArea;
  bool isVisible;
  IViewZonesFastDomNode domNode;
  IViewZonesFastDomNode? marginDomNode;
}

/// 1:1: `interface IComputedViewZoneProps`.
class IComputedViewZonePropsForViewZones {
  const IComputedViewZonePropsForViewZones({
    required this.isInHiddenArea,
    required this.afterViewLineNumber,
    required this.heightInPx,
    required this.minWidthInPx,
  });

  final bool isInHiddenArea;
  final int afterViewLineNumber;
  final num heightInPx;
  final num minWidthInPx;
}

String _invalidAddZone(Object zone) =>
    throw StateError('Invalid change accessor');
void _invalidRemoveZone(String id) =>
    throw StateError('Invalid change accessor');
void _invalidLayoutZone(String id) =>
    throw StateError('Invalid change accessor');

/// 1:1: `IViewZoneChangeAccessor`.
class IViewZoneChangeAccessorForViewZones {
  IViewZoneChangeAccessorForViewZones({
    required this.addZone,
    required this.removeZone,
    required this.layoutZone,
  });

  String Function(Object zone) addZone;
  void Function(String id) removeZone;
  void Function(String id) layoutZone;

  void invalidate() {
    addZone = _invalidAddZone;
    removeZone = _invalidRemoveZone;
    layoutZone = _invalidLayoutZone;
  }
}

/// A view zone is a rectangle inserted into the editor lines.
class ViewZones extends ViewPart {
  ViewZones(ViewContext context)
      : _context = context,
        super(context) {
    final dynamic options = (_context.configuration as dynamic).options;
    final dynamic layoutInfo = options.get(EditorOption.layoutInfo);
    _lineHeight = options.get(EditorOption.lineHeight) as num;
    _contentWidth = layoutInfo.contentWidth as num;
    _contentLeft = layoutInfo.contentLeft as num;

    domNode = _wrapFastDomNode(_createElement('div'));
    domNode.setClassName('view-zones');
    domNode.setPosition('absolute');
    domNode.setAttribute('role', 'presentation');
    domNode.setAttribute('aria-hidden', 'true');

    marginDomNode = _wrapFastDomNode(_createElement('div'));
    marginDomNode.setClassName('margin-view-zones');
    marginDomNode.setPosition('absolute');
    marginDomNode.setAttribute('role', 'presentation');
    marginDomNode.setAttribute('aria-hidden', 'true');
  }

  late final ViewContext _context;

  final Map<String, IMyViewZoneForViewZones> _zones =
      <String, IMyViewZoneForViewZones>{};

  late num _lineHeight;
  late num _contentWidth;
  late num _contentLeft;

  late final IViewZonesFastDomNode domNode;

  late final IViewZonesFastDomNode marginDomNode;

  @override
  void dispose() {
    super.dispose();
    _zones.clear();
  }

  // ---- begin view event handlers

  bool _recomputeWhitespacesProps() {
    final List<Object> whitespaces =
        (_context.viewLayout as dynamic).getWhitespaces() as List<Object>;
    final Map<String, Object> oldWhitespaces = <String, Object>{};
    for (final Object whitespace in whitespaces) {
      oldWhitespaces[(whitespace as dynamic).id as String] = whitespace;
    }
    bool hadAChange = false;
    (_context.viewModel as dynamic).changeWhitespace(
      (dynamic whitespaceAccessor) {
        final List<String> keys = _zones.keys.toList();
        for (final String id in keys) {
          final IMyViewZoneForViewZones zone = _zones[id]!;
          final IComputedViewZonePropsForViewZones props =
              _computeWhitespaceProps(zone.delegate);
          zone.isInHiddenArea = props.isInHiddenArea;
          final Object? oldWhitespace = oldWhitespaces[id];
          if (oldWhitespace != null &&
              ((oldWhitespace as dynamic).afterLineNumber !=
                      props.afterViewLineNumber ||
                  (oldWhitespace as dynamic).height != props.heightInPx)) {
            whitespaceAccessor.changeOneWhitespace(
                id, props.afterViewLineNumber, props.heightInPx);
            _safeCallOnComputedHeight(zone.delegate, props.heightInPx);
            hadAChange = true;
          }
        }
      },
    );
    return hadAChange;
  }

  @override
  bool onConfigurationChanged(Object e) {
    final dynamic options = (_context.configuration as dynamic).options;
    final dynamic layoutInfo = options.get(EditorOption.layoutInfo);
    _lineHeight = options.get(EditorOption.lineHeight) as num;
    _contentWidth = layoutInfo.contentWidth as num;
    _contentLeft = layoutInfo.contentLeft as num;

    final ConfigurationChangedEvent event = e as ConfigurationChangedEvent;
    if (event.hasChanged(EditorOption.lineHeight)) {
      _recomputeWhitespacesProps();
    }
    return true;
  }

  @override
  bool onLineMappingChanged(Object e) => _recomputeWhitespacesProps();

  @override
  bool onLinesDeleted(Object e) => true;

  @override
  bool onScrollChanged(Object e) {
    final ViewScrollChangedEvent event = e as ViewScrollChangedEvent;
    return event.scrollTopChanged || event.scrollWidthChanged;
  }

  @override
  bool onZonesChanged(Object e) => true;

  @override
  bool onLinesInserted(Object e) => true;

  // ---- end view event handlers

  int _getZoneOrdinal(Object zone) {
    final dynamic z = zone;
    final Object? ordinal = z.ordinal;
    if (ordinal != null) {
      return ordinal as int;
    }
    final Object? afterColumn = z.afterColumn;
    if (afterColumn != null) {
      return afterColumn as int;
    }
    return 10000;
  }

  IComputedViewZonePropsForViewZones _computeWhitespaceProps(Object zone) {
    final dynamic z = zone;
    if (z.afterLineNumber == 0) {
      return IComputedViewZonePropsForViewZones(
        isInHiddenArea: false,
        afterViewLineNumber: 0,
        heightInPx: _heightInPixels(zone),
        minWidthInPx: _minWidthInPixels(zone),
      );
    }

    final dynamic viewModel = _context.viewModel;
    final dynamic model = viewModel.model;

    late final Position zoneAfterModelPosition;
    final Object? afterColumn = z.afterColumn;
    if (afterColumn != null) {
      zoneAfterModelPosition = model.validatePosition(<String, Object?>{
        'lineNumber': z.afterLineNumber,
        'column': afterColumn,
      }) as Position;
    } else {
      final int validAfterLineNumber = (model.validatePosition(
        <String, Object?>{'lineNumber': z.afterLineNumber, 'column': 1},
      ) as Position).lineNumber;
      zoneAfterModelPosition = Position(
        validAfterLineNumber,
        model.getLineMaxColumn(validAfterLineNumber) as int,
      );
    }

    late final Position zoneBeforeModelPosition;
    if (zoneAfterModelPosition.column ==
        model.getLineMaxColumn(zoneAfterModelPosition.lineNumber)) {
      zoneBeforeModelPosition = model.validatePosition(<String, Object?>{
        'lineNumber': zoneAfterModelPosition.lineNumber + 1,
        'column': 1,
      }) as Position;
    } else {
      zoneBeforeModelPosition = model.validatePosition(<String, Object?>{
        'lineNumber': zoneAfterModelPosition.lineNumber,
        'column': zoneAfterModelPosition.column + 1,
      }) as Position;
    }

    final dynamic converter = viewModel.coordinatesConverter;
    final Position viewPosition = converter.convertModelPositionToViewPosition(
      zoneAfterModelPosition,
      z.afterColumnAffinity,
      true,
    ) as Position;
    final bool isVisible = (z.showInHiddenArea as bool? ?? false) ||
        (converter.modelPositionIsVisible(zoneBeforeModelPosition) as bool);
    return IComputedViewZonePropsForViewZones(
      isInHiddenArea: !isVisible,
      afterViewLineNumber: viewPosition.lineNumber,
      heightInPx: isVisible ? _heightInPixels(zone) : 0,
      minWidthInPx: _minWidthInPixels(zone),
    );
  }

  bool changeViewZones(void Function(IViewZoneChangeAccessorForViewZones) callback) {
    bool zonesHaveChanged = false;
    (_context.viewModel as dynamic).changeWhitespace(
      (dynamic whitespaceAccessor) {
        final IViewZoneChangeAccessorForViewZones changeAccessor =
            IViewZoneChangeAccessorForViewZones(
          addZone: (Object zone) {
            zonesHaveChanged = true;
            return _addZone(whitespaceAccessor, zone);
          },
          removeZone: (String id) {
            if (id.isEmpty) {
              return;
            }
            zonesHaveChanged =
                _removeZone(whitespaceAccessor, id) || zonesHaveChanged;
          },
          layoutZone: (String id) {
            if (id.isEmpty) {
              return;
            }
            zonesHaveChanged =
                _layoutZone(whitespaceAccessor, id) || zonesHaveChanged;
          },
        );

        try {
          callback(changeAccessor);
        } catch (e) {
          _onUnexpectedError(e);
        }
        changeAccessor.invalidate();
      },
    );
    return zonesHaveChanged;
  }

  String _addZone(dynamic whitespaceAccessor, Object zone) {
    final IComputedViewZonePropsForViewZones props = _computeWhitespaceProps(zone);
    final String whitespaceId = whitespaceAccessor.insertWhitespace(
      props.afterViewLineNumber,
      _getZoneOrdinal(zone),
      props.heightInPx,
      props.minWidthInPx,
    ) as String;

    final dynamic z = zone;
    final IViewZonesFastDomNode zoneDomNode =
        _wrapFastDomNode(z.domNode as Object);
    IViewZonesFastDomNode? marginZone;
    if (z.marginDomNode != null) {
      marginZone = _wrapFastDomNode(z.marginDomNode as Object);
    }

    final IMyViewZoneForViewZones myZone = IMyViewZoneForViewZones(
      whitespaceId: whitespaceId,
      delegate: zone,
      isInHiddenArea: props.isInHiddenArea,
      isVisible: false,
      domNode: zoneDomNode,
      marginDomNode: marginZone,
    );

    _safeCallOnComputedHeight(myZone.delegate, props.heightInPx);

    zoneDomNode.setPosition('absolute');
    (zoneDomNode.domNode as IViewZonesDomElement).style['width'] = '100%';
    zoneDomNode.setDisplay('none');
    zoneDomNode.setAttribute('monaco-view-zone', myZone.whitespaceId);
    domNode.appendChild(zoneDomNode);

    final IViewZonesFastDomNode? margin = myZone.marginDomNode;
    if (margin != null) {
      margin.setPosition('absolute');
      (margin.domNode as IViewZonesDomElement).style['width'] = '100%';
      margin.setDisplay('none');
      margin.setAttribute('monaco-view-zone', myZone.whitespaceId);
      marginDomNode.appendChild(marginZone!);
    }

    _zones[myZone.whitespaceId] = myZone;
    setShouldRender();
    return myZone.whitespaceId;
  }

  bool _removeZone(dynamic whitespaceAccessor, String id) {
    final IMyViewZoneForViewZones? zone = _zones.remove(id);
    if (zone == null) {
      return false;
    }
    whitespaceAccessor.removeWhitespace(zone.whitespaceId);

    zone.domNode.removeAttribute('monaco-visible-view-zone');
    zone.domNode.removeAttribute('monaco-view-zone');
    (zone.domNode.domNode as IViewZonesDomElement).remove();

    final IViewZonesFastDomNode? margin = zone.marginDomNode;
    if (margin != null) {
      margin.removeAttribute('monaco-visible-view-zone');
      margin.removeAttribute('monaco-view-zone');
      (margin.domNode as IViewZonesDomElement).remove();
    }

    setShouldRender();
    return true;
  }

  bool _layoutZone(dynamic whitespaceAccessor, String id) {
    final IMyViewZoneForViewZones? zone = _zones[id];
    if (zone == null) {
      return false;
    }
    final IComputedViewZonePropsForViewZones props =
        _computeWhitespaceProps(zone.delegate);
    zone.isInHiddenArea = props.isInHiddenArea;
    whitespaceAccessor.changeOneWhitespace(
      zone.whitespaceId,
      props.afterViewLineNumber,
      props.heightInPx,
    );
    _safeCallOnComputedHeight(zone.delegate, props.heightInPx);
    setShouldRender();
    return true;
  }

  bool shouldSuppressMouseDownOnViewZone(String id) {
    final IMyViewZoneForViewZones? zone = _zones[id];
    if (zone == null) {
      return false;
    }
    final dynamic z = zone.delegate;
    return (z.suppressMouseDown as bool?) ?? false;
  }

  num _heightInPixels(Object zone) {
    final dynamic z = zone;
    final Object? heightInPx = z.heightInPx;
    if (heightInPx != null) {
      return heightInPx as num;
    }
    final Object? heightInLines = z.heightInLines;
    if (heightInLines != null) {
      return _lineHeight * (heightInLines as num);
    }
    return _lineHeight;
  }

  num _minWidthInPixels(Object zone) {
    final dynamic z = zone;
    final Object? minWidthInPx = z.minWidthInPx;
    if (minWidthInPx != null) {
      return minWidthInPx as num;
    }
    return 0;
  }

  void _safeCallOnComputedHeight(Object zone, num height) {
    final dynamic z = zone;
    final Object? callback = z.onComputedHeight;
    if (callback is Function) {
      try {
        callback(height);
      } catch (e) {
        _onUnexpectedError(e);
      }
    }
  }

  void _safeCallOnDomNodeTop(Object zone, num top) {
    final dynamic z = zone;
    final Object? callback = z.onDomNodeTop;
    if (callback is Function) {
      try {
        callback(top);
      } catch (e) {
        _onUnexpectedError(e);
      }
    }
  }

  @override
  void prepareRender(RenderingContext ctx) {
    // Nothing to read
  }

  @override
  void render(RestrictedRenderingContext ctx) {
    final List<Object> visibleWhitespaces =
        ctx.viewportData.whitespaceViewportData;
    final Map<String, Object> visibleZones = <String, Object>{};

    bool hasVisibleZone = false;
    for (final Object visibleWhitespace in visibleWhitespaces) {
      final dynamic vw = visibleWhitespace;
      final String id = vw.id as String;
      if (_zones[id]!.isInHiddenArea) {
        continue;
      }
      visibleZones[id] = visibleWhitespace;
      hasVisibleZone = true;
    }

    for (final MapEntry<String, IMyViewZoneForViewZones> entry
        in _zones.entries) {
      final String id = entry.key;
      final IMyViewZoneForViewZones zone = entry.value;

      num newTop = 0;
      num newHeight = 0;
      String newDisplay = 'none';
      final Object? visible = visibleZones[id];
      if (visible != null) {
        final dynamic vw = visible;
        newTop = (vw.verticalOffset as num) - ctx.bigNumbersDelta;
        newHeight = vw.height as num;
        newDisplay = 'block';
        if (!zone.isVisible) {
          zone.domNode.setAttribute('monaco-visible-view-zone', 'true');
          zone.isVisible = true;
        }
        _safeCallOnDomNodeTop(
          zone.delegate,
          ctx.getScrolledTopFromAbsoluteTop(vw.verticalOffset as num),
        );
      } else {
        if (zone.isVisible) {
          zone.domNode.removeAttribute('monaco-visible-view-zone');
          zone.isVisible = false;
        }
        _safeCallOnDomNodeTop(
          zone.delegate,
          ctx.getScrolledTopFromAbsoluteTop(-1000000),
        );
      }
      zone.domNode.setTop(newTop);
      zone.domNode.setHeight(newHeight);
      zone.domNode.setDisplay(newDisplay);

      final IViewZonesFastDomNode? margin = zone.marginDomNode;
      if (margin != null) {
        margin.setTop(newTop);
        margin.setHeight(newHeight);
        margin.setDisplay(newDisplay);
      }
    }

    if (hasVisibleZone) {
      domNode.setWidth(ctx.scrollWidth > _contentWidth
          ? ctx.scrollWidth
          : _contentWidth);
      marginDomNode.setWidth(_contentLeft);
    }
  }
}
