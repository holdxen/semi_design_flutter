// 1:1 port of vscode/src/vs/base/browser/iframe.ts
// DOM `Window`/`Element`/`WeakRef`/`WeakMap` and WebCrypto have no Dart
// equivalent: the window-graph walks through the [IframeWindow] /
// [IframeElement] carriers and `parentOriginHash` uses an injectable
// [sha256Provider] so the sha256AsBase32 logic itself stays 1:1.

import 'dart:convert' show jsonEncode, utf8;

/// 1:1: DOM `Window` subset used here (parent/location/frameElement/scroll).
abstract class IframeWindow {
  IframeWindow? get parent;
  IframeLocation get location;
  IframeElement? get frameElement;
  num get scrollY;
  num get scrollX;
}

/// 1:1: DOM `Location.origin`.
abstract class IframeLocation {
  String get origin;
}

/// 1:1: DOM `Element` subset: `getBoundingClientRect()`.
abstract class IframeElement {
  IframeRect getBoundingClientRect();
}

/// 1:1: DOM `DOMRect` subset.
class IframeRect {
  final num top;
  final num left;
  const IframeRect({required this.top, required this.left});
}

/// 1:1: `interface IWindowChainElement`
class IWindowChainElement {
  /// Source uses `WeakRef<Window>`; the carrier holds the target directly.
  final IframeWindow window;
  final IframeElement? iframeElement;

  IWindowChainElement({required this.window, required this.iframeElement});

  /// 1:1: `window.deref()` (WeakRef deref — always resolves in the carrier).
  IframeWindow deref() => window;
}

/// 1:1: `const sameOriginWindowChainCache = new WeakMap<Window, ...>()`
/// A plain identity-keyed map stands in for WeakMap.
final Map<IframeWindow, List<IWindowChainElement>?> sameOriginWindowChainCache =
    <IframeWindow, List<IWindowChainElement>?>{};

/// 1:1: `function getParentWindowIfSameOrigin(w): Window | null`
IframeWindow? getParentWindowIfSameOrigin(IframeWindow w) {
  if (w.parent == null || identical(w.parent, w)) {
    return null;
  }

  // Cannot really tell if we have access to the parent unless we try.
  try {
    final String location = w.location.origin;
    final String parentLocation = w.parent!.location.origin;
    if (location != 'null' &&
        parentLocation != 'null' &&
        location != parentLocation) {
      return null;
    }
  } catch (_) {
    return null;
  }

  return w.parent;
}

/// 1:1: `export class IframeUtils`
class IframeUtils {
  /// 1:1: `private static getSameOriginWindowChain(targetWindow)`
  static List<IWindowChainElement> getSameOriginWindowChain(
      IframeWindow targetWindow) {
    List<IWindowChainElement>? windowChainCache =
        sameOriginWindowChainCache[targetWindow];
    if (windowChainCache == null) {
      windowChainCache = <IWindowChainElement>[];
      sameOriginWindowChainCache[targetWindow] = windowChainCache;
      IframeWindow? w = targetWindow;
      IframeWindow? parent;
      do {
        parent = getParentWindowIfSameOrigin(w!);
        if (parent != null) {
          windowChainCache.add(IWindowChainElement(
            window: w,
            iframeElement: w.frameElement,
          ));
        } else {
          windowChainCache.add(IWindowChainElement(
            window: w,
            iframeElement: null,
          ));
        }
        w = parent;
      } while (w != null);
    }
    return windowChainCache.sublist(0);
  }

  /// 1:1: `public static getPositionOfChildWindowRelativeToAncestorWindow(childWindow, ancestorWindow)`
  static ({num top, num left}) getPositionOfChildWindowRelativeToAncestorWindow(
    IframeWindow childWindow,
    IframeWindow? ancestorWindow,
  ) {
    if (ancestorWindow == null || identical(childWindow, ancestorWindow)) {
      return (top: 0, left: 0);
    }

    num top = 0;
    num left = 0;

    final List<IWindowChainElement> windowChain =
        getSameOriginWindowChain(childWindow);

    for (final IWindowChainElement windowChainEl in windowChain) {
      final IframeWindow windowInChain = windowChainEl.deref();
      top += windowInChain.scrollY;
      left += windowInChain.scrollX;

      if (identical(windowInChain, ancestorWindow)) {
        break;
      }

      final IframeElement? iframeElement = windowChainEl.iframeElement;
      if (iframeElement == null) {
        break;
      }

      final IframeRect boundingRect = iframeElement.getBoundingClientRect();
      top += boundingRect.top;
      left += boundingRect.left;
    }

    return (top: top, left: left);
  }
}

/// Injectable `crypto.subtle.digest('sha-256', bytes)`.
/// Defaults to unavailable (the source throws when `crypto.subtle` is absent).
Future<List<int>> Function(List<int> bytes)? sha256Provider;

/// 1:1: `export async function parentOriginHash(parentOrigin, salt): Promise<string>`
Future<String> parentOriginHash(String parentOrigin, String salt) async {
  final Future<List<int>> Function(List<int> bytes)? digest = sha256Provider;
  if (digest == null) {
    throw StateError(
      "'crypto.subtle' is not available so webviews will not work. This is likely "
      'because the editor is not running in a secure context '
      '(https://developer.mozilla.org/en-US/docs/Web/Security/Secure_Contexts).',
    );
  }

  final String strData = jsonEncode(<String, String>{
    'parentOrigin': parentOrigin,
    'salt': salt,
  });
  final List<int> arrData = utf8.encode(strData);
  final List<int> hash = await digest(arrData);
  return sha256AsBase32(hash);
}

/// 1:1: `function sha256AsBase32(bytes: ArrayBuffer): string`
String sha256AsBase32(List<int> bytes) {
  final String hexArray = bytes.map((int b) => b.toRadixString(16).padLeft(2, '0')).join('');
  // sha256 has 256 bits, so at most ceil(lg(2^256-1)/lg(32)) = 52 base-32 chars.
  return BigInt.parse('0x$hexArray').toRadixString(32).padLeft(52, '0');
}
