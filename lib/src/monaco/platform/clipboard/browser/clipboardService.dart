// 1:1 port of vscode/src/vs/platform/clipboard/browser/clipboardService.ts
//
// Browser/navigator boundaries are carried by [clipboardEnvironment] so the
// port can be driven by the real TypeScript runtime truth in tests.

import 'dart:convert';
import 'dart:typed_data';

import '../../../base/browser/dom.dart' as dom;
import '../../../base/browser/window.dart' as window;
import '../../../base/common/async.dart' as async;
import '../../../base/common/event.dart' as events;
import '../../../base/common/hash.dart' as hashes;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../base/common/uri.dart' as uri;
import '../../layout/browser/layoutService.dart' as layout;
import '../../log/common/log.dart' as log;
import '../common/clipboardService.dart' as common;

/// 1:1: `const vscodeResourcesMime = 'application/vnd.code.resources'`
const String vscodeResourcesMime = 'application/vnd.code.resources';

/// 1:1: `web ${vscodeResourcesMime}` clipboard item key.
const String webVscodeResourcesMime = 'web $vscodeResourcesMime';

/// 1:1: `Blob` subset used by the clipboard items in this file.
class ClipboardBlob {
  ClipboardBlob(this.parts, [this.type]);

  final List<Object> parts;
  final String? type;

  Future<String> text() async => parts.join();

  Future<Uint8List> arrayBuffer() async =>
      Uint8List.fromList(parts.join().codeUnits);
}

/// 1:1: `ClipboardItem` subset.
class ClipboardItemCarrier {
  ClipboardItemCarrier(this.items);

  final Map<String, Object> items;

  List<String> get types => items.keys.toList(growable: false);

  Object? getType(String type) => items[type];
}

/// 1:1: `navigator.clipboard` subset.
class ClipboardApi {
  ClipboardApi({
    required this.read,
    required this.readText,
    required this.write,
    required this.writeText,
  });

  final Future<List<Object>> Function() read;
  final Future<String> Function() readText;
  final Future<void> Function(List<Object> items) write;
  final Future<void> Function(String text) writeText;
}

/// Browser boundaries of `getActiveWindow().navigator.clipboard` and the
/// copied resource state.
class BrowserClipboardEnvironment {
  bool isSafari = false;
  bool isWebkitWebView = false;

  dom.DomDocument Function() getActiveDocument = dom.getActiveDocument;
  window.CodeWindow Function() getActiveWindow = dom.getActiveWindow;

  /// The global `navigator.clipboard` used by `readImage`.
  ClipboardApi Function() navigatorClipboard =
      () => throw UnimplementedError('navigator.clipboard');

  ClipboardApi? Function(window.CodeWindow targetWindow) windowClipboard =
      (_) => throw UnimplementedError('window.navigator.clipboard');

  /// 1:1: `$('textarea', {'aria-hidden': true})`.
  dom.DomElement Function(String tag, Map<String, Object?> attributes)
      createElement = (String tag, Map<String, Object?> attributes) {
    final dom.DomElement element = dom.DomElement(tag);
    attributes.forEach((String key, Object? value) {
      element.setAttribute(key, _clipboardAttrString(value));
    });
    return element;
  };

  lifecycle.IDisposable Function(
          Object target, String type, void Function(dynamic e) listener)
      addListener = (Object target, String type, void Function(dynamic e) listener) {
    if (target is dom.DomNode) {
      return dom.addDisposableListener(
          target, type, (dom.DomEvent e) => listener(e));
    }
    throw ArgumentError.value(target, 'target', 'Unsupported EventTarget');
  };

  events.Event<dom.IRegisteredCodeWindow> Function() onDidRegisterWindow =
      () => dom.onDidRegisterWindow;

  /// 1:1: `Document.execCommand('copy')`.
  void Function(dom.DomDocument document, String command) execCommand =
      (dom.DomDocument document, String command) {};

  void Function(Object error) consoleError = print;
}

String _clipboardAttrString(Object? value) {
  if (value == null) return '';
  if (value is bool) return value ? 'true' : 'false';
  return value.toString();
}

/// Injectable browser boundary of this module.
final BrowserClipboardEnvironment clipboardEnvironment =
    BrowserClipboardEnvironment();

/// 1:1: `export class BrowserClipboardService extends Disposable implements IClipboardService`
class BrowserClipboardService extends lifecycle.Disposable
    implements common.IClipboardServiceType {
  BrowserClipboardService(
    this.layoutService,
    this.logService,
  ) : super() {
    if (clipboardEnvironment.isSafari ||
        clipboardEnvironment.isWebkitWebView) {
      _installWebKitWriteTextWorkaround();
    }

    // Keep track of copy operations to reset our set of copied resources.
    final lifecycle.DisposableStore initialStore = lifecycle.DisposableStore();
    register(initialStore);
    register(events.eventRunAndSubscribe<dom.IRegisteredCodeWindow>(
      clipboardEnvironment.onDidRegisterWindow(),
      (dom.IRegisteredCodeWindow? e) {
        if (e == null) return;
        e.disposables.add(clipboardEnvironment.addListener(
            dom.windowCarrier(e.window).document, 'copy', (dynamic _) {
          _clearResourcesState();
        }));
      },
      dom.IRegisteredCodeWindow(window.mainWindow, initialStore),
    ));
  }

  final layout.ILayoutServiceType layoutService;
  final log.ILogServiceType logService;

  // ignore: unused_element
  Object? get _serviceBrand => null;

  /// 1:1: `triggerPaste(): Promise<void> | undefined`
  @override
  Future<void>? triggerPaste([int targetWindowId = 0]) {
    logService.trace('BrowserClipboardService#triggerPaste');
    return null;
  }

  /// 1:1: `async readImage(): Promise<Uint8Array>`
  @override
  Future<Uint8List> readImage() async {
    try {
      final List<Object> clipboardItems =
          await clipboardEnvironment.navigatorClipboard().read();
      final Object clipboardItem = clipboardItems.first;
      const List<String> supportedImageTypes = <String>[
        'image/png',
        'image/jpeg',
        'image/gif',
        'image/tiff',
        'image/bmp',
      ];
      final List<String> types = _itemTypes(clipboardItem);
      String? mimeType;
      for (final String type in supportedImageTypes) {
        if (types.contains(type)) {
          mimeType = type;
          break;
        }
      }
      if (mimeType != null) {
        final Object blob = _getItemType(clipboardItem, mimeType)!;
        return await _blobArrayBuffer(blob);
      } else {
        clipboardEnvironment.consoleError(
            'No supported image type found in the clipboard');
      }
    } catch (error) {
      clipboardEnvironment.consoleError(
          'Error reading image from clipboard: $error');
    }
    return Uint8List(0);
  }

  /// 1:1: `async writeImage(data: Uint8Array | Promise<Uint8Array>): Promise<void>`
  @override
  Future<void> writeImage(Object data) async {
    _clearResourcesState();
    final Future<Uint8List> image = _resolveBytes(data);
    final ClipboardApi? clipboard =
        clipboardEnvironment.windowClipboard(clipboardEnvironment.getActiveWindow());
    await clipboard!.write(<Object>[
      ClipboardItemCarrier(<String, Object>{
        'image/png': image.then((Uint8List bytes) =>
            ClipboardBlob(<Object>[bytes], 'image/png')),
      }),
    ]);
  }

  async.DeferredPromise<String>? webKitPendingClipboardWritePromise;

  /// 1:1: `installWebKitWriteTextWorkaround()`
  void _installWebKitWriteTextWorkaround() {
    void handler() {
      final ClipboardApi? clipboard = clipboardEnvironment.windowClipboard(
          clipboardEnvironment.getActiveWindow());
      if (clipboard == null) {
        return;
      }

      final async.DeferredPromise<String> currentWritePromise =
          async.DeferredPromise<String>();

      if (webKitPendingClipboardWritePromise != null &&
          !webKitPendingClipboardWritePromise!.isSettled) {
        webKitPendingClipboardWritePromise!.cancel();
      }
      webKitPendingClipboardWritePromise = currentWritePromise;

      clipboard.write(<Object>[
        ClipboardItemCarrier(<String, Object>{
          'text/plain': currentWritePromise.p,
        }),
      ]).catchError((Object err) {
        if ((!_isNotAllowedError(err)) || !currentWritePromise.isRejected) {
          logService.error(err);
        }
      });
    }

    final lifecycle.DisposableStore initialStore = lifecycle.DisposableStore();
    register(initialStore);
    register(events.eventRunAndSubscribe<layout.AddContainerEvent>(
      layoutService.onDidAddContainer,
      (layout.AddContainerEvent? e) {
        if (e == null) return;
        e.disposables.add(clipboardEnvironment.addListener(
            e.container, 'click', (dynamic _) => handler()));
        e.disposables.add(clipboardEnvironment.addListener(
            e.container, 'keydown', (dynamic _) => handler()));
      },
      layout.AddContainerEvent(layoutService.mainContainer, initialStore),
    ));
  }

  final Map<String, String> mapTextToType = <String, String>{};

  /// 1:1: `async writeText(text: string, type?: string): Promise<void>`
  @override
  Future<void> writeText(String text, [String? type]) async {
    logService.trace('BrowserClipboardService#writeText called with type:',
        <Object?>[type, ' text.length:', text.length]);
    _clearResourcesState();

    if (type != null) {
      mapTextToType[type] = text;
      logService.trace('BrowserClipboardService#writeText');
      return;
    }

    if (webKitPendingClipboardWritePromise != null) {
      return webKitPendingClipboardWritePromise!.complete(text);
    }

    try {
      logService.trace('before navigator.clipboard.writeText');
      final ClipboardApi? clipboard = clipboardEnvironment.windowClipboard(
          clipboardEnvironment.getActiveWindow());
      await clipboard!.writeText(text);
      return;
    } catch (error) {
      clipboardEnvironment.consoleError(error);
    }

    _fallbackWriteText(text);
  }

  /// 1:1: `fallbackWriteText(text: string): void`
  void _fallbackWriteText(String text) {
    logService.trace('BrowserClipboardService#fallbackWriteText');
    final dom.DomDocument activeDocument =
        clipboardEnvironment.getActiveDocument();
    final dom.DomElement? activeElement = activeDocument.activeElement;

    final dom.DomElement textArea = clipboardEnvironment.createElement(
        'textarea', <String, Object?>{'aria-hidden': true});
    activeDocument.body.appendChild(textArea);
    textArea.style['height'] = '1px';
    textArea.style['width'] = '1px';
    textArea.style['position'] = 'absolute';

    _setTextAreaValue(textArea, text);
    textArea.focus();
    (textArea as dynamic).select();

    clipboardEnvironment.execCommand(activeDocument, 'copy');

    if (activeElement != null) {
      activeElement.focus();
    }

    textArea.remove();
  }

  /// 1:1: `async readText(type?: string): Promise<string>`
  @override
  Future<String> readText([String? type]) async {
    logService.trace('BrowserClipboardService#readText called with type:',
        <Object?>[type]);
    if (type != null) {
      final String readText = mapTextToType[type] ?? '';
      logService.trace('BrowserClipboardService#readText text.length:',
          <Object?>[readText.length]);
      return readText;
    }

    try {
      final ClipboardApi? clipboard = clipboardEnvironment.windowClipboard(
          clipboardEnvironment.getActiveWindow());
      final String readText = await clipboard!.readText();
      logService.trace('BrowserClipboardService#readText text.length:',
          <Object?>[readText.length]);
      return readText;
    } catch (error) {
      clipboardEnvironment.consoleError(error);
    }

    return '';
  }

  String findText = '';

  @override
  Future<String> readFindText() async => findText;

  @override
  Future<void> writeFindText(String text) async {
    findText = text;
  }

  List<uri.URI> resources = <uri.URI>[];
  int? resourcesStateHash;

  static const int maxResourceStateSourceLength = 1000;

  /// 1:1: `async writeResources(resources: URI[]): Promise<void>`
  @override
  Future<void> writeResources(List<uri.URI> resources) async {
    try {
      final ClipboardApi? clipboard = clipboardEnvironment.windowClipboard(
          clipboardEnvironment.getActiveWindow());
      await clipboard!.write(<Object>[
        ClipboardItemCarrier(<String, Object>{
          webVscodeResourcesMime: ClipboardBlob(<Object>[
            jsonEncode(resources
                .map((uri.URI x) => <String, Object?>{
                      'scheme': x.scheme,
                      'authority': x.authority,
                      'path': x.path,
                      'query': x.query,
                      'fragment': x.fragment,
                    })
                .toList(growable: false)),
          ], vscodeResourcesMime),
        }),
      ]);
    } catch (_) {
      // Noop
    }

    if (resources.isEmpty) {
      _clearResourcesState();
    } else {
      this.resources = resources;
      resourcesStateHash = await _computeResourcesStateHash();
    }
  }

  /// 1:1: `async readResources(): Promise<URI[]>`
  @override
  Future<List<uri.URI>> readResources() async {
    try {
      final ClipboardApi? clipboard = clipboardEnvironment.windowClipboard(
          clipboardEnvironment.getActiveWindow());
      final List<Object> items = await clipboard!.read();
      for (final Object item in items) {
        if (_itemTypes(item).contains(webVscodeResourcesMime)) {
          final Object blob = _getItemType(item, webVscodeResourcesMime)!;
          final String text = await _blobText(blob);
          final List<Object?> decoded =
              jsonDecode(text) as List<Object?>;
          return decoded.map((Object? x) {
            final Map<String, Object?> m = x as Map<String, Object?>;
            return uri.URI.from(uri.UriComponents(
              scheme: m['scheme'] as String,
              authority: m['authority'] as String?,
              path: m['path'] as String?,
              query: m['query'] as String?,
              fragment: m['fragment'] as String?,
            ));
          }).toList(growable: false);
        }
      }
    } catch (_) {
      // Noop
    }

    final int? resourcesStateHash = await _computeResourcesStateHash();
    if (this.resourcesStateHash != resourcesStateHash) {
      _clearResourcesState();
    }

    return resources;
  }

  /// 1:1: `private async computeResourcesStateHash(): Promise<number | undefined>`
  Future<int?> _computeResourcesStateHash() async {
    if (resources.isEmpty) {
      return null;
    }
    final String clipboardText = await readText();
    final int length = clipboardText.length < maxResourceStateSourceLength
        ? clipboardText.length
        : maxResourceStateSourceLength;
    return hashes.hash(clipboardText.substring(0, length));
  }

  /// 1:1: `async hasResources(): Promise<boolean>`
  @override
  Future<bool> hasResources() async {
    try {
      final ClipboardApi? clipboard = clipboardEnvironment.windowClipboard(
          clipboardEnvironment.getActiveWindow());
      final List<Object> items = await clipboard!.read();
      for (final Object item in items) {
        if (_itemTypes(item).contains(webVscodeResourcesMime)) {
          return true;
        }
      }
    } catch (_) {
      // Noop
    }

    return resources.isNotEmpty;
  }

  @override
  void clearInternalState() {
    _clearResourcesState();
  }

  void _clearResourcesState() {
    resources = <uri.URI>[];
    resourcesStateHash = null;
  }
}

// ---------------------------------------------------------------------------
// Structural helpers for the browser clipboard carriers.
// ---------------------------------------------------------------------------

List<String> _itemTypes(Object item) {
  if (item is ClipboardItemCarrier) return item.types;
  return (item as dynamic).types as List<String>;
}

Object? _getItemType(Object item, String type) {
  if (item is ClipboardItemCarrier) return item.getType(type);
  return (item as dynamic).getType(type) as Object?;
}

Future<String> _blobText(Object blob) {
  if (blob is ClipboardBlob) return blob.text();
  return (blob as dynamic).text() as Future<String>;
}

Future<Uint8List> _blobArrayBuffer(Object blob) async {
  if (blob is ClipboardBlob) return blob.arrayBuffer();
  final Object buffer = await (blob as dynamic).arrayBuffer() as Object;
  if (buffer is Uint8List) return buffer;
  throw ArgumentError.value(blob, 'blob', 'Unsupported ArrayBuffer carrier');
}

Future<Uint8List> _resolveBytes(Object data) async {
  if (data is Uint8List) return data;
  if (data is Future<Uint8List>) return await data;
  return data as Uint8List;
}

bool _isNotAllowedError(Object error) =>
    error.toString().contains('NotAllowedError');

void _setTextAreaValue(dom.DomElement element, String value) {
  (element as dynamic).value = value;
}
