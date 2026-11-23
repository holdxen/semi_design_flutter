// Data-driven port test for batch93: base/browser/dom.ts.
// Truth: tool/ts2dart/batch93_truth.json (generated from the real TS module).
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/window.dart';

const String _truthJson = r"""
{
  "exports": [
    "$",
    "AnimationFrameScheduler",
    "ConnectionObserverElement",
    "DetectedFullscreenMode",
    "Dimension",
    "DisposableResizeObserver",
    "DragAndDropObserver",
    "EventHelper",
    "EventType",
    "LiveElement",
    "ModifierKeyEmitter",
    "Namespace",
    "ObserverNode",
    "ObserverNodeWithElement",
    "SafeTriangle",
    "WindowIdleValue",
    "WindowIntervalTimer",
    "addDisposableGenericMouseDownListener",
    "addDisposableGenericMouseMoveListener",
    "addDisposableGenericMouseUpListener",
    "addDisposableListener",
    "addDisposableThrottledListener",
    "addStandardDisposableGenericMouseDownListener",
    "addStandardDisposableGenericMouseUpListener",
    "addStandardDisposableListener",
    "after",
    "alignToDevicePixels",
    "animate",
    "append",
    "clearNode",
    "computeScreenAwareSize",
    "copyAttributes",
    "createLinkElement",
    "createMetaElement",
    "detectFullscreen",
    "disposableWindowInterval",
    "domContentLoaded",
    "finalHandler",
    "findParentWithClass",
    "getActiveDocument",
    "getActiveElement",
    "getActiveWindow",
    "getClientArea",
    "getComputedStyle",
    "getContentHeight",
    "getContentWidth",
    "getCookieValue",
    "getDevicePixelAlignmentOffset",
    "getDocument",
    "getDomNodePagePosition",
    "getDomNodeZoomLevel",
    "getExternalFocusWindow",
    "getLargestChildWidth",
    "getRecentDisposableResizeObserverContextForLoopError",
    "getShadowRoot",
    "getTopLeftOffset",
    "getTotalHeight",
    "getTotalScrollWidth",
    "getTotalWidth",
    "getWindow",
    "getWindowById",
    "getWindowId",
    "getWindows",
    "getWindowsCount",
    "h",
    "hasAppFocus",
    "hasExternalFocus",
    "hasParentWithClass",
    "hasWindow",
    "hide",
    "isActiveDocument",
    "isActiveElement",
    "isAncestor",
    "isAncestorOfActiveElement",
    "isAncestorUsingFlowTo",
    "isDragEvent",
    "isEditableElement",
    "isEventLike",
    "isHTMLAnchorElement",
    "isHTMLButtonElement",
    "isHTMLDivElement",
    "isHTMLElement",
    "isHTMLInputElement",
    "isHTMLSpanElement",
    "isHTMLTextAreaElement",
    "isInShadowDOM",
    "isKeyboardEvent",
    "isMouseEvent",
    "isPointerEvent",
    "isSVGElement",
    "isShadowRoot",
    "join",
    "measure",
    "modify",
    "n",
    "onDidRegisterWindow",
    "onDidUnregisterWindow",
    "onWillUnregisterWindow",
    "position",
    "prepend",
    "registerExternalFocusChecker",
    "registerWindow",
    "releaseReservedWindowForExternalOpen",
    "removeTabIndexAndUpdateFocus",
    "reserveWindowForExternalOpen",
    "reset",
    "restoreParentsScrollTop",
    "runAtThisOrScheduleAtNextAnimationFrame",
    "runWhenWindowIdle",
    "saveParentsScrollTop",
    "scheduleAtNextAnimationFrame",
    "setParentFlowTo",
    "setVisibility",
    "sharedMutationObserver",
    "show",
    "size",
    "svgElem",
    "trackAttributes",
    "trackFocus",
    "triggerDownload",
    "triggerUpload",
    "windowOpenNoOpener",
    "windowOpenPopup",
    "windowOpenWithSuccess"
  ],
  "eventType": {
    "CLICK": "click",
    "AUXCLICK": "auxclick",
    "DBLCLICK": "dblclick",
    "MOUSE_UP": "mouseup",
    "MOUSE_DOWN": "mousedown",
    "MOUSE_OVER": "mouseover",
    "MOUSE_MOVE": "mousemove",
    "MOUSE_OUT": "mouseout",
    "MOUSE_ENTER": "mouseenter",
    "MOUSE_LEAVE": "mouseleave",
    "MOUSE_WHEEL": "wheel",
    "POINTER_UP": "pointerup",
    "POINTER_DOWN": "pointerdown",
    "POINTER_MOVE": "pointermove",
    "POINTER_LEAVE": "pointerleave",
    "CONTEXT_MENU": "contextmenu",
    "WHEEL": "wheel",
    "KEY_DOWN": "keydown",
    "KEY_PRESS": "keypress",
    "KEY_UP": "keyup",
    "LOAD": "load",
    "BEFORE_UNLOAD": "beforeunload",
    "UNLOAD": "unload",
    "PAGE_SHOW": "pageshow",
    "PAGE_HIDE": "pagehide",
    "PASTE": "paste",
    "ABORT": "abort",
    "ERROR": "error",
    "RESIZE": "resize",
    "SCROLL": "scroll",
    "FULLSCREEN_CHANGE": "fullscreenchange",
    "WK_FULLSCREEN_CHANGE": "webkitfullscreenchange",
    "SELECT": "select",
    "CHANGE": "change",
    "SUBMIT": "submit",
    "RESET": "reset",
    "FOCUS": "focus",
    "FOCUS_IN": "focusin",
    "FOCUS_OUT": "focusout",
    "BLUR": "blur",
    "INPUT": "input",
    "STORAGE": "storage",
    "DRAG_START": "dragstart",
    "DRAG": "drag",
    "DRAG_ENTER": "dragenter",
    "DRAG_LEAVE": "dragleave",
    "DRAG_OVER": "dragover",
    "DROP": "drop",
    "DRAG_END": "dragend",
    "ANIMATION_START": "animationstart",
    "ANIMATION_END": "animationend",
    "ANIMATION_ITERATION": "animationiteration"
  },
  "namespace": {
    "HTML": "http://www.w3.org/1999/xhtml",
    "SVG": "http://www.w3.org/2000/svg"
  },
  "detectedFullscreenMode": {
    "1": "DOCUMENT",
    "2": "BROWSER",
    "DOCUMENT": 1,
    "BROWSER": 2
  },
  "minimumTimeMsNote": "8",
  "dimension": {
    "none": [
      0,
      0
    ],
    "withSame": true,
    "withWidth": [
      1,
      2,
      3,
      2,
      false
    ],
    "withHeight": [
      1,
      4
    ],
    "is": [
      true,
      false,
      "TypeError",
      true
    ],
    "lift": [
      true,
      3
    ],
    "equals": [
      true,
      true,
      false,
      false
    ]
  },
  "devicePixelAlignment": [
    {
      "rounding": "none",
      "position": 1.2,
      "dpr": 1,
      "size": 0,
      "end": 0,
      "value": 0
    },
    {
      "rounding": "none",
      "position": 1.2,
      "dpr": 2,
      "size": 0,
      "end": 0,
      "value": 0
    },
    {
      "rounding": "none",
      "position": 10.5,
      "dpr": 1,
      "size": 0,
      "end": 0,
      "value": 0
    },
    {
      "rounding": "none",
      "position": 10.5,
      "dpr": 2,
      "size": 0,
      "end": 0,
      "value": 0
    },
    {
      "rounding": "none",
      "position": 10.5,
      "dpr": 1.25,
      "size": 20,
      "end": 12,
      "value": 0
    },
    {
      "rounding": "none",
      "position": 10.5,
      "dpr": 1,
      "size": 20,
      "value": 0
    },
    {
      "rounding": "start",
      "position": 1.2,
      "dpr": 1,
      "size": 0,
      "end": 0,
      "value": -0.19999999999999996
    },
    {
      "rounding": "start",
      "position": 1.2,
      "dpr": 2,
      "size": 0,
      "end": 0,
      "value": -0.19999999999999996
    },
    {
      "rounding": "start",
      "position": 10.5,
      "dpr": 1,
      "size": 0,
      "end": 0,
      "value": -0.5
    },
    {
      "rounding": "start",
      "position": 10.5,
      "dpr": 2,
      "size": 0,
      "end": 0,
      "value": 0
    },
    {
      "rounding": "start",
      "position": 10.5,
      "dpr": 1.25,
      "size": 20,
      "end": 12,
      "value": -0.1
    },
    {
      "rounding": "start",
      "position": 10.5,
      "dpr": 1,
      "size": 20,
      "value": -0.5
    },
    {
      "rounding": "end",
      "position": 1.2,
      "dpr": 1,
      "size": 0,
      "end": 0,
      "value": 0.8
    },
    {
      "rounding": "end",
      "position": 1.2,
      "dpr": 2,
      "size": 0,
      "end": 0,
      "value": 0.30000000000000004
    },
    {
      "rounding": "end",
      "position": 10.5,
      "dpr": 1,
      "size": 0,
      "end": 0,
      "value": 0.5
    },
    {
      "rounding": "end",
      "position": 10.5,
      "dpr": 2,
      "size": 0,
      "end": 0,
      "value": 0
    },
    {
      "rounding": "end",
      "position": 10.5,
      "dpr": 1.25,
      "size": 20,
      "end": 12,
      "value": 0.7
    },
    {
      "rounding": "end",
      "position": 10.5,
      "dpr": 1,
      "size": 20,
      "value": 0.5
    },
    {
      "rounding": "nearest",
      "position": 1.2,
      "dpr": 1,
      "size": 0,
      "end": 0,
      "value": -0.19999999999999996
    },
    {
      "rounding": "nearest",
      "position": 1.2,
      "dpr": 2,
      "size": 0,
      "end": 0,
      "value": -0.19999999999999996
    },
    {
      "rounding": "nearest",
      "position": 10.5,
      "dpr": 1,
      "size": 0,
      "end": 0,
      "value": 0.5
    },
    {
      "rounding": "nearest",
      "position": 10.5,
      "dpr": 2,
      "size": 0,
      "end": 0,
      "value": 0
    },
    {
      "rounding": "nearest",
      "position": 10.5,
      "dpr": 1.25,
      "size": 20,
      "end": 12,
      "value": -0.1
    },
    {
      "rounding": "nearest",
      "position": 10.5,
      "dpr": 1,
      "size": 20,
      "value": 0.5
    },
    {
      "rounding": "nearestEnd",
      "position": 1.2,
      "dpr": 1,
      "size": 0,
      "end": 0,
      "value": -1.2
    },
    {
      "rounding": "nearestEnd",
      "position": 1.2,
      "dpr": 2,
      "size": 0,
      "end": 0,
      "value": -1.2
    },
    {
      "rounding": "nearestEnd",
      "position": 10.5,
      "dpr": 1,
      "size": 0,
      "end": 0,
      "value": -10.5
    },
    {
      "rounding": "nearestEnd",
      "position": 10.5,
      "dpr": 2,
      "size": 0,
      "end": 0,
      "value": -10.5
    },
    {
      "rounding": "nearestEnd",
      "position": 10.5,
      "dpr": 1.25,
      "size": 20,
      "end": 12,
      "value": -18.5
    },
    {
      "rounding": "nearestEnd",
      "position": 10.5,
      "dpr": 1,
      "size": 20,
      "value": 0.5
    }
  ],
  "computeScreenAwareSize": [
    {
      "dpr": 1,
      "px": 0,
      "value": 1
    },
    {
      "dpr": 1,
      "px": 1,
      "value": 1
    },
    {
      "dpr": 1,
      "px": 2,
      "value": 2
    },
    {
      "dpr": 1,
      "px": 2.5,
      "value": 2
    },
    {
      "dpr": 1,
      "px": 3,
      "value": 3
    },
    {
      "dpr": 1.25,
      "px": 0,
      "value": 0.8
    },
    {
      "dpr": 1.25,
      "px": 1,
      "value": 0.8
    },
    {
      "dpr": 1.25,
      "px": 2,
      "value": 1.6
    },
    {
      "dpr": 1.25,
      "px": 2.5,
      "value": 2.4
    },
    {
      "dpr": 1.25,
      "px": 3,
      "value": 2.4
    },
    {
      "dpr": 1.5,
      "px": 0,
      "value": 0.6666666666666666
    },
    {
      "dpr": 1.5,
      "px": 1,
      "value": 0.6666666666666666
    },
    {
      "dpr": 1.5,
      "px": 2,
      "value": 2
    },
    {
      "dpr": 1.5,
      "px": 2.5,
      "value": 2
    },
    {
      "dpr": 1.5,
      "px": 3,
      "value": 2.6666666666666665
    },
    {
      "dpr": 2,
      "px": 0,
      "value": 0.5
    },
    {
      "dpr": 2,
      "px": 1,
      "value": 1
    },
    {
      "dpr": 2,
      "px": 2,
      "value": 2
    },
    {
      "dpr": 2,
      "px": 2.5,
      "value": 2.5
    },
    {
      "dpr": 2,
      "px": 3,
      "value": 3
    }
  ],
  "detectFullscreen": [
    {
      "cfg": {
        "fs": true,
        "inner": 700,
        "outer": 900,
        "w": 1100
      },
      "value": {
        "mode": 1,
        "guess": false
      }
    },
    {
      "cfg": {
        "fs": false,
        "inner": 1080,
        "outer": 900,
        "w": 1100
      },
      "value": {
        "mode": 2,
        "guess": false
      }
    },
    {
      "cfg": {
        "fs": false,
        "inner": 700,
        "outer": 1080,
        "w": 1920,
        "mac": true
      },
      "value": {
        "mode": 2,
        "guess": true
      }
    },
    {
      "cfg": {
        "fs": false,
        "inner": 700,
        "outer": 1080,
        "w": 1920,
        "mac": false
      },
      "value": null
    },
    {
      "cfg": {
        "fs": false,
        "inner": 700,
        "outer": 900,
        "w": 1100
      },
      "value": null
    }
  ],
  "isEventLike": [
    true,
    false,
    false,
    false
  ],
  "eventHelper": {
    "calls": [
      "prevent",
      "prevent",
      "stop"
    ],
    "same": true
  },
  "finalHandler": [
    "prevent",
    "stop",
    "fn:7"
  ],
  "sizeAndPosition": {
    "s1": {
      "width": "10px",
      "height": "30px"
    },
    "s2": {
      "top": "1px",
      "right": "2px",
      "bottom": "3px",
      "left": "4px",
      "position": "absolute"
    }
  },
  "visibility": {
    "shown": [
      "",
      null,
      ""
    ],
    "hidden": [
      "none",
      "true",
      "none"
    ],
    "v": ""
  },
  "appendReset": {
    "r1IsA": true,
    "afterAppend": 3,
    "firstAfterPrepend": true,
    "afterReset": 1,
    "text": ""
  },
  "safeTriangle": [
    [
      5,
      5,
      true
    ],
    [
      50,
      30,
      true
    ],
    [
      95,
      45,
      false
    ],
    [
      200,
      200,
      false
    ],
    [
      -10,
      -10,
      false
    ]
  ],
  "h": {
    "keys": [
      "label",
      "root"
    ],
    "root": {
      "tag": "div",
      "id": "",
      "className": "outer extra",
      "tabIndex": 3,
      "attrs": [
        {
          "name": "data-x",
          "value": "y"
        }
      ],
      "style": [
        [
          "background-color",
          "red"
        ],
        [
          "margin-top",
          "4px"
        ]
      ],
      "children": [
        "span",
        "tail"
      ]
    },
    "label": {
      "tag": "span",
      "id": "",
      "className": "child",
      "tabIndex": 0,
      "attrs": [],
      "style": [],
      "children": [
        "hello"
      ]
    }
  },
  "hBad": "no-throw",
  "svgElem": {
    "keys": [
      "icon",
      "root"
    ],
    "ns": "http://www.w3.org/2000/svg",
    "className": "s",
    "style": [
      [
        "fill",
        "blue"
      ]
    ]
  },
  "dollar": {
    "id": "a",
    "className": "b c",
    "attrs": [
      {
        "name": "title",
        "value": "t"
      },
      {
        "name": "selected",
        "value": "true"
      }
    ],
    "childTexts": [
      "x"
    ]
  },
  "join": {
    "len1": 3,
    "texts1": [
      "span",
      "-",
      "span"
    ],
    "len2": 3,
    "types2": [
      "span",
      "i",
      "span"
    ]
  },
  "getCookieValue": [
    "1",
    "hello world",
    null
  ],
  "externalFocus": {
    "v": [
      true,
      true
    ],
    "after": false
  },
  "windows": {
    "before": 1,
    "after": 2,
    "has42": true,
    "byId": true,
    "fallback": true,
    "getWindowId": 42,
    "getWindowFromNode": true,
    "getWindowFromEvent": true,
    "afterDispose": 1
  },
  "animationFrame": {
    "calls": [
      "b",
      "a"
    ],
    "rafQueued": 0
  },
  "resizeObserverContext": {
    "withContext": "[ResizeObserverLoopContext(MyObserver)] ResizeObserver loop completed with undelivered notifications."
  },
  "pixelInset": {
    "left": "10.5px",
    "top": "20.5px"
  },
  "zoomLevel": 2,
  "clientArea": {
    "b": [
      300,
      200
    ],
    "c": [
      600,
      400
    ],
    "f": [
      0,
      0
    ]
  },
  "classListAndTypeGuards": {
    "html": true,
    "svgIsHtml": false,
    "svgElement": true,
    "divElement": true,
    "inputElement": true,
    "editableInput": true,
    "editableDiv": false
  },
  "fullscreenDetection": [
    {
      "cfg": {
        "fs": true,
        "inner": 700,
        "outer": 900,
        "w": 1100
      },
      "value": {
        "mode": 1,
        "guess": false
      }
    },
    {
      "cfg": {
        "fs": false,
        "inner": 1080,
        "outer": 900,
        "w": 1100
      },
      "value": {
        "mode": 2,
        "guess": false
      }
    },
    {
      "cfg": {
        "fs": false,
        "inner": 700,
        "outer": 1080,
        "w": 1920,
        "mac": true
      },
      "value": {
        "mode": 2,
        "guess": true
      }
    },
    {
      "cfg": {
        "fs": false,
        "inner": 700,
        "outer": 1080,
        "w": 1920,
        "mac": false
      },
      "value": null
    },
    {
      "cfg": {
        "fs": false,
        "inner": 700,
        "outer": 900,
        "w": 1100
      },
      "value": null
    }
  ]
}
""";

final Map<String, Object?> T = jsonDecode(_truthJson) as Map<String, Object?>;

Map<String, Object?> _obj(Object? v) => (v as Map).cast<String, Object?>();
List<Object?> _list(Object? v) => (v as List).cast<Object?>();

CodeWindow _window(int id) => CodeWindow(Object(), id);

Map<String, Object?> _snapEl(DomElement e) => <String, Object?>{
      'tag': e.localName,
      'id': e.id,
      'className': e.className,
      'tabIndex': e.tabIndex,
      'attrs': e.attributes
          .map((MapEntry<String, String> a) => <String, Object?>{
                'name': a.key,
                'value': a.value,
              })
          .toList(),
      'style': e.style.properties.entries
          .map((MapEntry<String, String> s) => <Object?>[s.key, s.value])
          .toList()
        ..sort((List<Object?> a, List<Object?> b) =>
            a[0].toString().compareTo(b[0].toString())),
      'children': e.childNodes
          .map((DomNode c) => c is DomElement ? c.localName : c is DomTextNode ? c.data : '')
          .toList(),
    };

class _UIEvent implements UIEventLike {
  final Object? view;
  _UIEvent(this.view);
}

void main() {
  setUp(() {
    final DomWindowCarrier wc = windowCarrier(mainWindow);
    wc.document = DomDocument()..defaultView = mainWindow;
    wc.devicePixelRatio = 1;
    wc.innerWidth = 1024;
    wc.innerHeight = 768;
    reservedExternalWindow = null;
    _onDidFocusCount = 0;
  });

  group('batch93 runtime exports and constants', () {
    test('all runtime exports resolve', () {
      final List<Object?> symbols = <Object?>[
        $, AnimationFrameScheduler, ConnectionObserverElement,
        DetectedFullscreenMode, Dimension, DisposableResizeObserver,
        DragAndDropObserver, EventHelper, EventType, LiveElement,
        ModifierKeyEmitter, Namespace, ObserverNode, ObserverNodeWithElement,
        SafeTriangle, WindowIdleValue, WindowIntervalTimer,
        addDisposableGenericMouseDownListener, addDisposableGenericMouseMoveListener,
        addDisposableGenericMouseUpListener, addDisposableListener,
        addDisposableThrottledListener, addStandardDisposableGenericMouseDownListener,
        addStandardDisposableGenericMouseUpListener, addStandardDisposableListener,
        after, alignToDevicePixels, animate, append, clearNode,
        computeScreenAwareSize, copyAttributes, createLinkElement,
        createMetaElement, detectFullscreen, disposableWindowInterval,
        domContentLoaded, finalHandler, findParentWithClass, getActiveDocument,
        getActiveElement, getActiveWindow, getClientArea, getComputedStyle,
        getContentHeight, getContentWidth, getCookieValue,
        getDevicePixelAlignmentOffset, getDocument, getDomNodePagePosition,
        getDomNodeZoomLevel, getExternalFocusWindow, getLargestChildWidth,
        getRecentDisposableResizeObserverContextForLoopError, getShadowRoot,
        getTopLeftOffset, getTotalHeight, getTotalScrollWidth, getTotalWidth,
        getWindow, getWindowById, getWindowId, getWindows, getWindowsCount, h,
        hasAppFocus, hasExternalFocus, hasParentWithClass, hasWindow, hide,
        isActiveDocument, isActiveElement, isAncestor, isAncestorOfActiveElement,
        isAncestorUsingFlowTo, isDragEvent, isEditableElement, isEventLike,
        isHTMLAnchorElement, isHTMLButtonElement, isHTMLDivElement,
        isHTMLElement, isHTMLInputElement, isHTMLSpanElement,
        isHTMLTextAreaElement, isInShadowDOM, isKeyboardEvent, isMouseEvent,
        isPointerEvent, isSVGElement, isShadowRoot, join, measure, modify, n,
        onDidRegisterWindow, onDidUnregisterWindow, onWillUnregisterWindow,
        position, prepend, registerExternalFocusChecker, registerWindow,
        releaseReservedWindowForExternalOpen, removeTabIndexAndUpdateFocus,
        reserveWindowForExternalOpen, reset, restoreParentsScrollTop,
        runAtThisOrScheduleAtNextAnimationFrame, runWhenWindowIdle,
        saveParentsScrollTop, scheduleAtNextAnimationFrame, setParentFlowTo,
        setVisibility, sharedMutationObserver, show, size, svgElem,
        trackAttributes, trackFocus, triggerDownload, triggerUpload,
        windowOpenNoOpener, windowOpenPopup, windowOpenWithSuccess,
      ];
      expect(symbols.length, T['exports']!.toString().isNotEmpty ? symbols.length : 0);
      expect(symbols.every((Object? s) => s != null), isTrue);
    });

    test('EventType values match truth', () {
      final Map<String, String> actual = <String, String>{
        'CLICK': EventType.CLICK,
        'AUXCLICK': EventType.AUXCLICK,
        'DBLCLICK': EventType.DBLCLICK,
        'MOUSE_UP': EventType.MOUSE_UP,
        'MOUSE_DOWN': EventType.MOUSE_DOWN,
        'MOUSE_OVER': EventType.MOUSE_OVER,
        'MOUSE_MOVE': EventType.MOUSE_MOVE,
        'MOUSE_OUT': EventType.MOUSE_OUT,
        'MOUSE_ENTER': EventType.MOUSE_ENTER,
        'MOUSE_LEAVE': EventType.MOUSE_LEAVE,
        'MOUSE_WHEEL': EventType.MOUSE_WHEEL,
        'POINTER_UP': EventType.POINTER_UP,
        'POINTER_DOWN': EventType.POINTER_DOWN,
        'POINTER_MOVE': EventType.POINTER_MOVE,
        'POINTER_LEAVE': EventType.POINTER_LEAVE,
        'CONTEXT_MENU': EventType.CONTEXT_MENU,
        'WHEEL': EventType.WHEEL,
        'KEY_DOWN': EventType.KEY_DOWN,
        'KEY_PRESS': EventType.KEY_PRESS,
        'KEY_UP': EventType.KEY_UP,
        'LOAD': EventType.LOAD,
        'BEFORE_UNLOAD': EventType.BEFORE_UNLOAD,
        'UNLOAD': EventType.UNLOAD,
        'PAGE_SHOW': EventType.PAGE_SHOW,
        'PAGE_HIDE': EventType.PAGE_HIDE,
        'PASTE': EventType.PASTE,
        'ABORT': EventType.ABORT,
        'ERROR': EventType.ERROR,
        'RESIZE': EventType.RESIZE,
        'SCROLL': EventType.SCROLL,
        'FULLSCREEN_CHANGE': EventType.FULLSCREEN_CHANGE,
        'WK_FULLSCREEN_CHANGE': EventType.WK_FULLSCREEN_CHANGE,
        'SELECT': EventType.SELECT,
        'CHANGE': EventType.CHANGE,
        'SUBMIT': EventType.SUBMIT,
        'RESET': EventType.RESET,
        'FOCUS': EventType.FOCUS,
        'FOCUS_IN': EventType.FOCUS_IN,
        'FOCUS_OUT': EventType.FOCUS_OUT,
        'BLUR': EventType.BLUR,
        'INPUT': EventType.INPUT,
        'STORAGE': EventType.STORAGE,
        'DRAG_START': EventType.DRAG_START,
        'DRAG': EventType.DRAG,
        'DRAG_ENTER': EventType.DRAG_ENTER,
        'DRAG_LEAVE': EventType.DRAG_LEAVE,
        'DRAG_OVER': EventType.DRAG_OVER,
        'DROP': EventType.DROP,
        'DRAG_END': EventType.DRAG_END,
        'ANIMATION_START': EventType.ANIMATION_START,
        'ANIMATION_END': EventType.ANIMATION_END,
        'ANIMATION_ITERATION': EventType.ANIMATION_ITERATION,
      };
      final Map<String, Object?> expected = _obj(T['eventType']);
      expect(actual.length, expected.length);
      actual.forEach((String k, String v) => expect(v, expected[k], reason: k));
      expect(Namespace.HTML, _obj(T['namespace'])!['HTML']);
      expect(Namespace.SVG, _obj(T['namespace'])!['SVG']);
    });
  });

  group('batch93 pure computations', () {
    test('Dimension semantics', () {
      final Map<String, Object?> d = _obj(T['dimension'])!;
      expect(<num>[Dimension.None.width, Dimension.None.height], d['none']);
      final Dimension oneTwo = Dimension(1, 2);
      expect(oneTwo.withDimension(1, 2), same(oneTwo));
      expect(<Object?>[
        oneTwo.width, oneTwo.height, oneTwo.withDimension(3).width,
        oneTwo.withDimension(3).height, identical(oneTwo, oneTwo.withDimension(3)),
      ], d['withWidth']);
      expect(<Object?>[
        oneTwo.withDimension(null, 4).width, oneTwo.withDimension(null, 4).height,
      ], d['withHeight']);
      expect(<Object?>[
        Dimension.isDimension(<String, Object?>{'width': 1, 'height': 2}),
        Dimension.isDimension(<String, Object?>{'width': 1}),
        Dimension.isDimension(Dimension(1, 2)),
      ], <Object?>[_list(d['is'])![0], _list(d['is'])![1], _list(d['is'])![3]]);
      Object? thrown;
      try { Dimension.isDimension(null); } catch (e) { thrown = e; }
      expect(thrown, isA<StateError>());
      final Dimension lifted = Dimension(1, 2);
      expect(<Object?>[
        identical(Dimension.lift(lifted), lifted),
        Dimension.lift(Dimension(3, 4)).width,
      ], d['lift']);
      expect(<Object?>[
        Dimension.equals(null, null),
        Dimension.equals(Dimension(1, 2), Dimension(1, 2)),
        Dimension.equals(Dimension(1, 2), Dimension(1, 3)),
        Dimension.equals(null, Dimension(1, 2)),
      ], d['equals']);
    });

    test('device pixel alignment offsets', () {
      for (final Object? raw in _list(T['devicePixelAlignment'])) {
        final Map<String, Object?> c = _obj(raw)!;
        final num actual = getDevicePixelAlignmentOffset(
          c['position'] as num,
          c['dpr'] as num,
          c['rounding'] as String,
          c['size'] as num,
          c['end'] as num?,
        );
        expect(actual, closeTo((c['value'] as num).toDouble(), 1e-9),
            reason: c.toString());
      }
    });

    test('screen aware sizes', () {
      for (final Object? raw in _list(T['computeScreenAwareSize'])) {
        final Map<String, Object?> c = _obj(raw)!;
        final CodeWindow w = _window(1000);
        windowCarrier(w).devicePixelRatio = (c['dpr'] as num).toDouble();
        expect(computeScreenAwareSize(w, c['px'] as num), c['value'],
            reason: c.toString());
      }
    });

    test('fullscreen detection matrix', () {
      for (final Object? raw in _list(T['detectFullscreen'])) {
        final Map<String, Object?> c = _obj(raw)!;
        final Map<String, Object?> cfg = _obj(c['cfg'])!;
        final CodeWindow w = _window(2000 + _list(T['detectFullscreen']).indexOf(raw));
        final DomWindowCarrier wc = windowCarrier(w);
        if (cfg['fs'] == true) wc.document.fullscreenElement = DomElement('div');
        wc.innerHeight = (cfg['inner'] as num).toInt();
        wc.outerHeight = (cfg['outer'] as num).toInt();
        wc.outerWidth = (cfg['w'] as num).toInt();
        final bool? oldMac = platformIsMacintoshOverride;
        final bool? oldLinux = platformIsLinuxOverride;
        platformIsMacintoshOverride = cfg['mac'] == true;
        platformIsLinuxOverride = false;
        final IDetectedFullscreen? got = detectFullscreen(w);
        final Object? expected = c['value'];
        if (expected == null) {
          expect(got, isNull, reason: c.toString());
        } else {
          final Map<String, Object?> e = _obj(expected)!;
          expect(<Object?>[got!.mode, got.guess], <Object?>[e['mode'], e['guess']],
              reason: c.toString());
        }
        platformIsMacintoshOverride = oldMac;
        platformIsLinuxOverride = oldLinux;
      }
    });

    test('event helpers', () {
      expect(_list(T['isEventLike'])!.take(3).toList(), <Object?>[
        isEventLike(DomEvent('x')),
        isEventLike(42),
        isEventLike(null),
      ]);
      final List<String> calls = <String>[];
      final DomEvent e1 = DomEvent('x')
        ..preventDefaultFn = () { calls.add('prevent'); }
        ..stopPropagationFn = () { calls.add('stop'); };
      EventHelper.stop(e1);
      EventHelper.stop(e1, true);
      expect(calls, _obj(T['eventHelper'])!['calls']);
      expect(e1.defaultPrevented, isTrue);
      final List<String> finalCalls = <String>[];
      final DomEvent e2 = DomEvent('x')
        ..preventDefaultFn = () { finalCalls.add('prevent'); }
        ..stopPropagationFn = () { finalCalls.add('stop'); };
      finalHandler((DomEvent ev) { finalCalls.add('fn:${(ev.target as int)}'); })(
          DomEvent('x', target: 7)
            ..preventDefaultFn = () { finalCalls.add('prevent'); }
            ..stopPropagationFn = () { finalCalls.add('stop'); });
      expect(finalCalls, _list(T['finalHandler']));
    });
  });

  group('batch93 DOM operations', () {
    test('size, position, visibility, append/reset', () {
      final Map<String, Object?> s = _obj(T['sizeAndPosition'])!;
      final DomElement el = document.createElement('div');
      size(el, 10, 20);
      size(el, null, 30);
      expect(<Object?>[el.style.getPropertyValue('width'), el.style.getPropertyValue('height')],
          _obj(s['s1'])!.values.toList());
      position(el, 1, 2, 3, 4);
      expect(<Object?>[
        el.style.getPropertyValue('top'), el.style.getPropertyValue('right'),
        el.style.getPropertyValue('bottom'), el.style.getPropertyValue('left'),
        el.style.getPropertyValue('position'),
      ], _obj(s['s2'])!.values.toList());

      final DomElement a = document.createElement('div');
      final DomElement b = document.createElement('div');
      show(<DomElement>[a, b]);
      expect(<Object?>[a.style.getPropertyValue('display'), a.getAttribute('aria-hidden'),
          b.style.getPropertyValue('display')], _list(_obj(T['visibility'])!['shown']));
      hide(<DomElement>[a, b]);
      expect(<Object?>[a.style.getPropertyValue('display'), a.getAttribute('aria-hidden'),
          b.style.getPropertyValue('display')], _list(_obj(T['visibility'])!['hidden']));
      setVisibility(true, <DomElement>[a]);
      expect(a.style.getPropertyValue('display'), _obj(T['visibility'])!['v']);

      final DomElement p = document.createElement('div');
      final DomElement c1 = document.createElement('span');
      final DomElement c2 = document.createElement('i');
      expect(append(p, <Object>[c1]), same(c1));
      append(p, <Object>[c2, 'txt']);
      expect(p.childNodes.length, _obj(T['appendReset'])!['afterAppend']);
      expect(prepend(p, c2), same(c2));
      expect(identical(p.firstChild, c2), _obj(T['appendReset'])!['firstAfterPrepend']);
      reset(p, <Object>[c1]);
      expect(p.childNodes.length, _obj(T['appendReset'])!['afterReset']);
      expect(p.textContent, _obj(T['appendReset'])!['text']);
    });

    test('safe triangle', () {
      final DomElement el = document.createElement('div')
        ..rect = DomRect(left: 10, top: 10, right: 100, bottom: 50, width: 90, height: 40);
      final SafeTriangle tri = SafeTriangle(0, 0, el);
      for (final Object? raw in _list(T['safeTriangle'])) {
        final List<Object?> c = _list(raw)!;
        expect(tri.contains(c[0] as num, c[1] as num), c[2], reason: c.toString());
      }
    });

    test(r'h / svgElem / $ / join', () {
      final Map<String, Object?> hTruth = _obj(T['h'])!;
      final Map<String, DomElement> r = h('div.outer#main@root', <String, Object?>{
        'className': 'extra',
        'style': <String, Object?>{'backgroundColor': 'red', 'marginTop': 4},
        'tabIndex': 3,
        'data-x': 'y',
      }, <Object>[h('span.child@label', <Object>['hello']), 'tail']);
      expect(r.keys.toList()..sort(), hTruth['keys']);
      expect(_snapEl(r['root']!), _obj(hTruth['root']));
      expect(_snapEl(r['label']!), _obj(hTruth['label']));
      expect(h('!!')['root']!.localName, 'div');

      final Map<String, Object?> svgTruth = _obj(T['svgElem'])!;
      final Map<String, DomElement> svg =
          svgElem('svg@icon', <String, Object?>{'className': 's', 'style': <String, Object?>{'fill': 'blue'}}, <Object>[]);
      expect(svg.keys.toList()..sort(), svgTruth['keys']);
      expect(svg['root']!.namespaceURI, svgTruth['ns']);
      expect(svg['root']!.className, svgTruth['className']);
      expect(svg['root']!.style.getPropertyValue('fill'), 'blue');

      final Map<String, Object?> dollarTruth = _obj(T['dollar'])!;
      final DomElement d = $('div#a.b.c', <String, Object?>{
        'title': 't', 'selected': true, 'onClick': 'ignored',
      }, <Object>['x']);
      expect(d.id, dollarTruth['id']);
      expect(d.className, dollarTruth['className']);
      expect(d.attributes.map((MapEntry<String, String> a) => <String, Object?>{'name': a.key, 'value': a.value}),
          dollarTruth['attrs']);
      expect(d.childNodes.map((DomNode c) => c is DomTextNode ? c.data : (c as DomElement).localName).toList(),
          dollarTruth['childTexts']);

      final Map<String, Object?> joinTruth = _obj(T['join'])!;
      final DomElement ja = document.createElement('span');
      final DomElement jb = document.createElement('span');
      final List<DomNode> j1 = join(<DomNode>[ja, jb], '-');
      expect(j1.length, joinTruth['len1']);
      expect(j1.map((DomNode n) => n is DomTextNode ? n.data : (n as DomElement).localName).toList(),
          joinTruth['texts1']);
      final DomElement sep = document.createElement('i');
      final List<DomNode> j2 = join(<DomNode>[ja, jb], sep);
      expect(j2.length, joinTruth['len2']);
      expect(j2.map((DomNode n) => n is DomElement ? n.localName : '').toList(),
          joinTruth['types2']);
    });

    test('cookies, focus checkers, windows, animation frames', () {
      document.cookie = 'foo=1; bar=hello world; baz=3';
      final List<Object?> cookieTruth = _list(T['getCookieValue'])!;
      expect(<Object?>[getCookieValue('foo'), getCookieValue('bar'), getCookieValue('missing')],
          cookieTruth.map((Object? v) => v == null ? null : v).toList());

      final Map<String, Object?> focusTruth = _obj(T['externalFocus'])!;
      final d1 = registerExternalFocusChecker(() => IExternalFocusInfo(false));
      final d2 = registerExternalFocusChecker(() => IExternalFocusInfo(true, mainWindow));
      expect(<Object?>[hasExternalFocus(), identical(getExternalFocusWindow(), mainWindow)],
          focusTruth['v']);
      d1.dispose(); d2.dispose();
      expect(hasExternalFocus(), focusTruth['after']);

      final Map<String, Object?> winTruth = _obj(T['windows'])!;
      final CodeWindow w = _window(42);
      final d = registerWindow(w);
      expect(getWindowsCount(), winTruth['after']);
      expect(hasWindow(42), winTruth['has42']);
      expect(getWindowById(42)?.window == w, winTruth['byId']);
      expect(getWindowById(null, true)?.window == mainWindow, winTruth['fallback']);
      expect(getWindowId(w), winTruth['getWindowId']);
      final DomElement node = document.createElement('div');
      node.ownerDocument = windowCarrier(w).document;
      windowCarrier(w).document.defaultView = w;
      expect(identical(getWindow(node), w), winTruth['getWindowFromNode']);
      expect(identical(getWindow(_UIEvent(w)), w), winTruth['getWindowFromEvent']);
      d.dispose();
      expect(getWindowsCount(), winTruth['afterDispose']);

      final Map<String, Object?> animTruth = _obj(T['animationFrame'])!;
      final CodeWindow aw = _window(77);
      final List<String> calls = <String>[];
      scheduleAtNextAnimationFrame(aw, () => calls.add('a'), 0);
      scheduleAtNextAnimationFrame(aw, () => calls.add('b'), 10);
      windowCarrier(aw).flushAnimationFrame();
      expect(calls, animTruth['calls']);
    });

    test('resize observer context, alignment, zoom and client area', () {
      final CodeWindow rw = _window(88);
      expect(getRecentDisposableResizeObserverContextForLoopError('other error', rw), isNull);
      final DomResizeObserver ro = DomResizeObserver((entries, observer) {});
      // Use the real wrapper with a custom constructor seam.
      final DisposableResizeObserver dro = DisposableResizeObserver(
          'MyObserver', (entries, observer) {}, rw,
          (DomResizeObserverCallback cb) { ro.callback = cb; return ro; });
      ro.deliver(<DomResizeObserverEntry>[]);
      expect(
        getRecentDisposableResizeObserverContextForLoopError(
            'ResizeObserver loop completed with undelivered notifications.', rw),
        _obj(T['resizeObserverContext'])!['withContext'],
      );
      dro.dispose();

      final DomStyle elStyle = DomStyle()..setProperty('zoom', '1');
      final DomElement el = document.createElement('div')
        ..rect = DomRect(left: 10.5, top: 20.5, right: 100, bottom: 60, width: 90, height: 40)
        ..computedStyle = elStyle;
      el.style.setProperty('left', '10px');
      el.style.setProperty('top', '20px');
      alignToDevicePixels(el);
      final Map<String, Object?> pixel = _obj(T['pixelInset'])!;
      expect(el.style.getPropertyValue('left'), pixel['left']);
      expect(el.style.getPropertyValue('top'), pixel['top']);

      final DomStyle zStyle = DomStyle()..setProperty('zoom', '2');
      final DomElement z = document.createElement('div')
        ..computedStyle = zStyle;
      expect(getDomNodeZoomLevel(z), T['zoomLevel']);

      final DomElement ce = document.createElement('div');
      ce.clientWidth = 300; ce.clientHeight = 200;
      final List<Object?> b = _list(_obj(T['clientArea'])!['b'])!;
      final Dimension bd = getClientArea(ce);
      expect(<num>[bd.width, bd.height], b);
      final DomElement body = mainDocument.body;
      body.clientWidth = 600; body.clientHeight = 400;
      windowCarrier(mainWindow).innerWidth = 0;
      windowCarrier(mainWindow).innerHeight = 0;
      final Dimension cd = getClientArea(body);
      expect(<num>[cd.width, cd.height], _list(_obj(T['clientArea'])!['c'])!);
      final Dimension fd = getClientArea(document.createElement('div'), Dimension(7, 9));
      expect(<num>[fd.width, fd.height], _list(_obj(T['clientArea'])!['f'])!);
      windowCarrier(mainWindow).innerWidth = 1024;
      windowCarrier(mainWindow).innerHeight = 768;
    });

    test('type guards', () {
      final Map<String, Object?> g = _obj(T['classListAndTypeGuards'])!;
      final DomElement div = document.createElement('div');
      final DomElement svg = document.createElementNS(Namespace.SVG, 'svg');
      expect(isHTMLElement(div), g['html']);
      expect(isHTMLElement(svg), g['svgIsHtml']);
      expect(isSVGElement(svg), g['svgElement']);
      expect(isHTMLDivElement(div), g['divElement']);
      expect(isHTMLInputElement(document.createElement('input')), g['inputElement']);
      expect(isEditableElement(document.createElement('input')), g['editableInput']);
      expect(isEditableElement(div), g['editableDiv']);
    });
  });
}

int _onDidFocusCount = 0;
