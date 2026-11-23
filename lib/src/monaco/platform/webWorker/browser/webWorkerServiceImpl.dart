// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/webWorker/browser/webWorkerServiceImpl.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// JS-only Web/DOM mechanisms bridged 1:1 by injectable carriers:
//   - `Worker`, `Blob`, `URL.createObjectURL/revokeObjectURL`, `URLSearchParams`
//     are modelled by carriers + top-level injectable providers/hooks. Their
//     observable behaviour (url/options/postMessage/handlers, blob text,
//     object-URL allocation/revocation, query param set) is preserved.
//   - `new URLSearchParams(str)` + `COI.addSearchParam` + `.toString()`:
//     _UrlSearchParams carries a JS-form-urlencoded map. Note the source's
//     `lastIndexOf('#', start)` uses `start` as a fromIndex (search backwards),
//     so a `#` to the RIGHT of `?` is NOT found -> end=-1 -> substring to end;
//     `1#frag` is then form-encoded to `1%23frag`. Preserved verbatim.
//   - `globalThis.origin` / `_VSCODE_FILE_ROOT` / `_VSCODE_PRODUCT_JSON` /
//     `self.constructor.name` -> top-level injectable values.
//   - `const ttPolicy = (() => {...})()` module IIFE -> lazy top-level getter
//     `_ttPolicy` with the same branch order.
//   - `Promise<Worker>` / `.finally` / `Promise.resolve` -> Dart Future.
//   - `JSON.stringify` -> jsonEncode (incl. `\"` escaping in the error branch).
// ---------------------------------------------------------------------------

import 'dart:async' show Completer, Future;
import 'dart:collection' show MapMixin;
import 'dart:convert' show jsonEncode;

import '../../../base/common/arrays.dart' show coalesce;
import '../../../base/common/errors.dart' show onUnexpectedError;
import '../../../base/common/event.dart' show Emitter, Event;
import '../../../base/common/lifecycle.dart' show Disposable, toDisposable;
import '../../../base/common/network.dart' show COI, globalVSCodeFileRoot;
import '../../../base/common/worker/webWorker.dart'
    show IWebWorker, IWebWorkerClient, Message, WebWorkerClient;
import '../../../nls.dart' show getNLSLanguage, getNLSMessages;
import 'webWorkerDescriptor.dart' show WebWorkerDescriptor;
import 'webWorkerService.dart' show IWebWorkerServiceType;

// ---- Injectable DOM/WebWorker carriers ------------------------------------

/// 1:1: `interface WebWorkerClientConstructor` / `new WebWorkerClient<T>(worker)`.
/// Injectable so callers can observe the constructed client; defaults to the
/// real [WebWorkerClient] constructor.
IWebWorkerClient Function(IWebWorker worker) webWorkerClientFactory =
    (IWebWorker worker) => WebWorkerClient(worker);

/// 1:1: injectable `new Worker(url, options)`. Returns a [PlatformWorker] carrier.
PlatformWorker Function(String url, WorkerOptions? options)? createWorkerProvider;

/// 1:1: injectable `URL.createObjectURL(blob)` -> object URL string.
String Function(Object blob)? createObjectURLProvider;

/// 1:1: injectable `URL.revokeObjectURL(url)`.
void Function(String url)? revokeObjectURLProvider;

/// 1:1: injectable `globalThis.origin` (used by the cross-origin check).
String workerGlobalOrigin = '';

/// 1:1: injectable `globalThis._VSCODE_PRODUCT_JSON` (usually a JSON string).
String? globalVSCodeProductJson;

/// 1:1: injectable `self.constructor.name === 'DedicatedWorkerGlobalScope'`.
String? workerSelfConstructorName;

/// 1:1: injectable `globalThis.workerttPolicy`.
Object? workerttPolicyGlobal;

/// 1:1: injectable `createTrustedTypesPolicy('defaultWorkerFactory', {createScriptURL: v=>v})`.
/// Returns an object with a `createScriptURL(String)` method, or null.
Object? Function(String policyName, Object? options)? createTrustedTypesPolicyHook;

/// 1:1: `type WorkerGlobalWithPolicy = ...` carrier for the Worker constructor options.
class WorkerOptions {
  WorkerOptions({this.name, this.type});
  final String? name;
  final String? type;
}

/// 1:1: DOM `Worker` carrier. Web workers are unavailable in Flutter, so the
/// object exposes the same observable members the source reads/writes:
/// `onmessage`, `onmessageerror`, `onerror`, `postMessage`, `addEventListener`,
/// `removeEventListener`, `terminate`.
class PlatformWorker {
  PlatformWorker(this.url, [this.options]);

  final String url;
  final WorkerOptions? options;

  Object? onmessage;
  Object? onmessageerror;
  Object? onerror;

  /// Recorded `(message, transfer)` pairs, mirroring `Worker.postMessage`.
  final List<List<Object?>> postedMessages = <List<Object?>>[];

  /// Recorded `['add'|'remove', type, handler]` triples.
  final List<List<Object?>> listenerOps = <List<Object?>>[];

  bool terminated = false;

  void postMessage(Object? message, [List<Object?> transfer = const []]) {
    postedMessages.add(<Object?>[message, transfer]);
  }

  void addEventListener(String type, Object? handler) {
    listenerOps.add(<Object?>[ 'add', type, handler ]);
  }

  void removeEventListener(String type, Object? handler) {
    listenerOps.add(<Object?>[ 'remove', type, handler ]);
  }

  void terminate() {
    terminated = true;
  }
}

/// 1:1: DOM `Blob` carrier — source builds it from an array of strings joined
/// with '' and reads it back only through `URL.createObjectURL`.
class PlatformBlob {
  PlatformBlob(this.parts, [this.options]);

  final List<String> parts;
  final Map<String, Object?>? options;

  String get text => parts.join('');
}

/// 1:1: JS `URLSearchParams` subset used by `getWorkerBootstrapUrl`:
/// constructor from a query string, `.set(name, value)`, `.toString()`.
/// `COI.addSearchParam` writes a key into this carrier's map (the Dart COI
/// branch for `Map<String,String>`); we implement that map surface via a
/// backing map exposed through [set] and [toString].
class _UrlSearchParams with MapMixin<String, String> {
  _UrlSearchParams([String? init]) {
    if (init != null && init.isNotEmpty) {
      for (final part in init.split('&')) {
        if (part.isEmpty) {
          continue;
        }
        final int eq = part.indexOf('=');
        final String key = eq < 0 ? part : part.substring(0, eq);
        final String value = eq < 0 ? '' : part.substring(eq + 1);
        _params[_formDecode(key)] = _formDecode(value);
      }
    }
  }

  final Map<String, String> _params = <String, String>{};

  /// 1:1: `URLSearchParams.prototype.set`.
  void set(String name, String value) => _params[name] = value;

  /// 1:1: map surface used by `COI.addSearchParam`
  /// (`urlOrSearch[coiSearchParamName] = value`). MapMixin makes this carrier
  /// satisfy the `Map<String,String>` branch in the Dart COI port.
  @override
  String? operator [](Object? key) => _params[key];

  @override
  void operator []=(String key, String value) => _params[key] = value;

  @override
  String? remove(Object? key) => _params.remove(key);

  @override
  Iterable<String> get keys => _params.keys;

  @override
  void clear() => _params.clear();

  /// 1:1: `URLSearchParams.prototype.toString` (application/x-www-form-urlencoded).
  @override
  String toString() {
    final List<String> out = <String>[];
    _params.forEach((String k, String v) {
      out.add('${_formEncode(k)}=${_formEncode(v)}');
    });
    return out.join('&');
  }

  static String _formEncode(String s) {
    // application/x-www-form-urlencoded percent-encoding: keep ASCII
    // alphanumerics and `* - . _`, space -> '+', everything else %XX (UTF-8).
    final List<int> bytes = _utf8Encode(s);
    final StringBuffer sb = StringBuffer();
    for (final int b in bytes) {
      if ((b >= 0x41 && b <= 0x5A) ||
          (b >= 0x61 && b <= 0x7A) ||
          (b >= 0x30 && b <= 0x39) ||
          b == 0x2A || b == 0x2D || b == 0x2E || b == 0x5F) {
        sb.writeCharCode(b);
      } else if (b == 0x20) {
        sb.write('+');
      } else {
        sb.write('%');
        sb.write(b.toRadixString(16).toUpperCase().padLeft(2, '0'));
      }
    }
    return sb.toString();
  }

  static String _formDecode(String s) {
    final List<int> bytes = <int>[];
    for (int i = 0; i < s.length; i++) {
      final int c = s.codeUnitAt(i);
      if (c == 0x2B) {
        bytes.add(0x20);
      } else if (c == 0x25 && i + 2 < s.length) {
        final int? hi = _hex(s.codeUnitAt(i + 1));
        final int? lo = _hex(s.codeUnitAt(i + 2));
        if (hi != null && lo != null) {
          bytes.add((hi << 4) | lo);
          i += 2;
        } else {
          bytes.addAll(_utf8Encode(s[i]));
        }
      } else {
        bytes.addAll(_utf8Encode(s[i]));
      }
    }
    return _utf8Decode(bytes);
  }

  static int? _hex(int c) {
    if (c >= 0x30 && c <= 0x39) return c - 0x30;
    if (c >= 0x41 && c <= 0x46) return c - 0x41 + 10;
    if (c >= 0x61 && c <= 0x66) return c - 0x61 + 10;
    return null;
  }

  static List<int> _utf8Encode(String s) {
    // Minimal UTF-8 encoder (source strings are ASCII in practice; handles BMP).
    final List<int> out = <int>[];
    for (final int rune in s.runes) {
      if (rune < 0x80) {
        out.add(rune);
      } else if (rune < 0x800) {
        out.add(0xC0 | (rune >> 6));
        out.add(0x80 | (rune & 0x3F));
      } else if (rune < 0x10000) {
        out.add(0xE0 | (rune >> 12));
        out.add(0x80 | ((rune >> 6) & 0x3F));
        out.add(0x80 | (rune & 0x3F));
      } else {
        out.add(0xF0 | (rune >> 18));
        out.add(0x80 | ((rune >> 12) & 0x3F));
        out.add(0x80 | ((rune >> 6) & 0x3F));
        out.add(0x80 | (rune & 0x3F));
      }
    }
    return out;
  }

  static String _utf8Decode(List<int> bytes) {
    final StringBuffer sb = StringBuffer();
    int i = 0;
    while (i < bytes.length) {
      final int b = bytes[i];
      if (b < 0x80) {
        sb.writeCharCode(b);
        i += 1;
      } else if (b < 0xE0 && i + 1 < bytes.length) {
        sb.writeCharCode(((b & 0x1F) << 6) | (bytes[i + 1] & 0x3F));
        i += 2;
      } else if (b < 0xF0 && i + 2 < bytes.length) {
        sb.writeCharCode(((b & 0x0F) << 12) |
            ((bytes[i + 1] & 0x3F) << 6) |
            (bytes[i + 2] & 0x3F));
        i += 3;
      } else if (i + 3 < bytes.length) {
        sb.writeCharCode(((b & 0x07) << 18) |
            ((bytes[i + 1] & 0x3F) << 12) |
            ((bytes[i + 2] & 0x3F) << 6) |
            (bytes[i + 3] & 0x3F));
        i += 4;
      } else {
        sb.writeCharCode(b);
        i += 1;
      }
    }
    return sb.toString();
  }
}

/// 1:1: `const ttPolicy = ((): ... => {...})()` — module-level IIFE, computed
/// lazily on first use (Dart has no top-level statements). Branch order is the
/// source's: worker-global reuse first, then createTrustedTypesPolicy.
Object? get _ttPolicy {
  if (workerSelfConstructorName == 'DedicatedWorkerGlobalScope' &&
      workerttPolicyGlobal != null) {
    return workerttPolicyGlobal;
  }
  final Object? Function(String, Object?)? hook = createTrustedTypesPolicyHook;
  if (hook == null) {
    return null;
  }
  return hook('defaultWorkerFactory', <String, Object?>{
    'createScriptURL': (String value) => value,
  });
}

/// 1:1: `export class WebWorkerService implements IWebWorkerService`
class WebWorkerService implements IWebWorkerServiceType {
  WebWorkerService();

  /// 1:1: `private static _workerIdPool: number = 0`
  static int _workerIdPool = 0;

  // ignore: unused_element
  Object? get _serviceBrand => null;

  /// 1:1: `createWorkerClient<T>(workerDescriptor): IWebWorkerClient<T>`
  @override
  IWebWorkerClient createWorkerClient(Object workerDescriptor) {
    late final Future<PlatformWorker> worker;
    final int id = ++_workerIdPool;
    if (workerDescriptor is PlatformWorker) {
      worker = Future<PlatformWorker>.value(workerDescriptor);
    } else if (_isPromiseLike<Object>(workerDescriptor)) {
      // 1:1: `Promise.resolve(workerDescriptor)` — a promise-like that already
      // resolves to a Worker carrier (the JS value is opaque to this layer).
      worker = (workerDescriptor as Future<PlatformWorker>);
    } else {
      worker = createWorker(workerDescriptor as WebWorkerDescriptor);
    }
    return webWorkerClientFactory(WebWorker(worker, id));
  }

  /// 1:1: `protected _createWorker(descriptor): Promise<Worker>`
  /// Exposed publicly (TS `protected` has no cross-library Dart equivalent) so
  /// subclasses such as StandaloneWebWorkerService can override it; dynamic
  /// dispatch is required from `createWorkerClient`.
  Future<PlatformWorker> createWorker(WebWorkerDescriptor descriptor) {
    final String workerRunnerUrl = getWorkerUrl(descriptor);
    final String workerUrlWithNls = _getWorkerBootstrapUrl(
      descriptor.label,
      workerRunnerUrl,
      getWorkerLoadingFailedErrorMessage(descriptor),
    );
    try {
      final PlatformWorker worker = createBlobWorker(workerUrlWithNls,
          WorkerOptions(name: descriptor.label, type: 'module'));
      return _whenESMWorkerReady(worker).whenComplete(() {
        final void Function(String)? revoke = revokeObjectURLProvider;
        if (revoke != null) {
          revoke(workerUrlWithNls);
        }
      });
    } catch (error) {
      final void Function(String)? revoke = revokeObjectURLProvider;
      if (revoke != null) {
        revoke(workerUrlWithNls);
      }
      rethrow;
    }
  }

  /// 1:1: `protected _getWorkerLoadingFailedErrorMessage(descriptor): string | undefined`
  /// Exposed publicly so subclasses can override it. The hook is retained for
  /// behaviour verification; base default stays the hook value (TS `undefined`).
  String? Function(WebWorkerDescriptor descriptor)?
      getWorkerLoadingFailedErrorMessageHook;

  String? getWorkerLoadingFailedErrorMessage(WebWorkerDescriptor descriptor) =>
      getWorkerLoadingFailedErrorMessageHook?.call(descriptor);

  /// 1:1: `getWorkerUrl(descriptor): string`
  @override
  String getWorkerUrl(WebWorkerDescriptor descriptor) {
    final Object? loc = descriptor.esmModuleLocation;
    if (loc == null) {
      throw StateError('Missing esmModuleLocation in WebWorkerDescriptor');
    }
    final Object uri = loc is Function ? (loc as Object Function())() : loc;
    // 1:1: `uri.toString(true)` (skipEncoding = true)
    return (uri as dynamic).toString(true) as String;
  }
}

/// 1:1: `export function createBlobWorker(blobUrl, options?): Worker`
PlatformWorker createBlobWorker(String blobUrl, [WorkerOptions? options]) {
  if (!blobUrl.startsWith('blob:')) {
    // 1:1: `throw new URIError('Not a blob-url: ' + blobUrl)`
    throw UriError('Not a blob-url: ' + blobUrl);
  }
  final Object? policy = _ttPolicy;
  final String resolvedUrl = policy != null
      ? (policy as dynamic).createScriptURL(blobUrl) as String
      : blobUrl;
  final PlatformWorker Function(String, WorkerOptions?) provider =
      createWorkerProvider ??
      ((String url, WorkerOptions? o) => PlatformWorker(url, o));
  // 1:1: `new Worker(url, { ...options, type: 'module' })` — `type` always overwritten.
  return provider(resolvedUrl, WorkerOptions(name: options?.name, type: 'module'));
}

/// 1:1: `function getWorkerBootstrapUrl(label, workerScriptUrl, errMsg?): string`
String _getWorkerBootstrapUrl(
  String label,
  String workerScriptUrl,
  String? workerLoadingFailedErrorMessage,
) {
  // 1:1: `/^((http:)|(https:)|(file:))/.test(url) && url.substring(0, origin.length) !== origin`
  final bool hasScheme = RegExp(r'^((http:)|(https:)|(file:))').hasMatch(workerScriptUrl);
  if (!(hasScheme &&
      _jsSubstring(workerScriptUrl, 0, workerGlobalOrigin.length) != workerGlobalOrigin)) {
    final int start = workerScriptUrl.lastIndexOf('?');
    // 1:1: `lastIndexOf('#', start)` — `start` is a fromIndex. A `#` to the right
    // of `?` is not found -> -1 -> `~end` is 0 (falsy) -> substring to end.
    final int end = _jsLastIndexOf(workerScriptUrl, '#', start);
    final _UrlSearchParams params = start > 0
        ? _UrlSearchParams(_jsSubstring(
            workerScriptUrl, start + 1, end < 0 ? null : end))
        : _UrlSearchParams();
    // 1:1: `COI.addSearchParam(params, true, true)` writes into the carrier map.
    COI.addSearchParam(params, true, true);
    final String search = params.toString();
    workerScriptUrl = search.isEmpty
        ? '$workerScriptUrl#$label'
        : '$workerScriptUrl?$search#$label';
  }

  // 1:1: `new Blob([coalesce([...]).join('')], { type: 'application/javascript' })`
  final List<String?> parts = <String?>[
    '/*$label*/',
    'globalThis._VSCODE_NLS_MESSAGES = ${_jsonStringify(getNLSMessages())};',
    'globalThis._VSCODE_NLS_LANGUAGE = ${_jsonStringify(getNLSLanguage())};',
    'globalThis._VSCODE_FILE_ROOT = ${_jsonStringify(globalVSCodeFileRoot)};',
    'globalThis._VSCODE_PRODUCT_JSON = ${_jsonStringify(globalVSCodeProductJson)};',
    "const ttPolicy = globalThis.trustedTypes?.createPolicy('defaultWorkerFactory', { createScriptURL: value => value });",
    'globalThis.workerttPolicy = ttPolicy;',
    workerLoadingFailedErrorMessage != null ? 'try {' : '',
    'await import(ttPolicy?.createScriptURL(${_jsonStringify(workerScriptUrl)}) ?? ${_jsonStringify(workerScriptUrl)});',
    workerLoadingFailedErrorMessage != null
        ? '} catch (err) { console.error(${_jsonStringify(workerLoadingFailedErrorMessage)}, err); throw err; }'
        : '',
    "globalThis.postMessage({ type: 'vscode-worker-ready' });",
    '/*$label*/',
  ];
  final PlatformBlob blob = PlatformBlob(
    coalesce<String>(parts),
    <String, Object?>{'type': 'application/javascript'},
  );
  final String Function(Object)? createUrl = createObjectURLProvider;
  return createUrl != null ? createUrl(blob) : 'blob:unconfigured';
}

/// 1:1: `function whenESMWorkerReady(worker): Promise<Worker>`
Future<PlatformWorker> _whenESMWorkerReady(PlatformWorker worker) {
  final Completer<PlatformWorker> completer = Completer<PlatformWorker>();
  worker.onmessage = (Object? e) {
    final dynamic data = (e as dynamic).data;
    if (data.type == 'vscode-worker-ready') {
      worker.onmessage = null;
      completer.complete(worker);
    }
  };
  worker.onerror = (Object? e) => completer.completeError(e as Object);
  return completer.future;
}

/// 1:1: `function isPromiseLike<T>(obj): obj is PromiseLike<T>`
bool _isPromiseLike<T>(Object? obj) {
  if (obj == null) {
    return false;
  }
  // 1:1: `typeof (obj as PromiseLike<T>).then === 'function'` — JS property
  // access on a missing key yields `undefined` (never throws); Dart `dynamic`
  // throws NoSuchMethodError, so swallow it to preserve the JS result.
  try {
    final dynamic then = (obj as dynamic).then;
    return then is Function;
  } on NoSuchMethodError {
    return false;
  }
}

/// 1:1: `export class WebWorker extends Disposable implements IWebWorker`
class WebWorker extends Disposable implements IWebWorker {
  WebWorker(Future<PlatformWorker> worker, this._id) : _workerPromise = worker {
    // 1:1: `this.postMessage('-please-ignore-', []);`
    postMessage('-please-ignore-', const <Object?>[]);
    final void Function(Object?) errorHandler = (Object? ev) {
      _onError.fire(ev);
    };
    // 1:1: `this.worker.then((w) => {...})` — captured at construction time,
    // before dispose can null the field.
    worker.then((PlatformWorker w) {
      w.onmessage = (Object? ev) {
        _onMessage.fire((ev as dynamic).data as Message);
      };
      w.onmessageerror = (Object? ev) {
        _onError.fire(ev);
      };
      // 1:1: `typeof w.addEventListener === 'function'` — carrier always has it.
      w.addEventListener('error', errorHandler);
    }, onError: (Object _) {
      // JS `Promise.then(onFulfilled)` with no onRejected leaves the rejection
      // to the consumer; Dart surfaces an uncaught async error instead, so
      // absorb it here to preserve JS observable behaviour.
    });
    register(toDisposable(() {
      final Future<PlatformWorker>? current = _workerPromise;
      current?.then((PlatformWorker w) {
        w.onmessage = null;
        w.onmessageerror = null;
        w.removeEventListener('error', errorHandler);
        w.terminate();
      }).catchError((Object _) {});
      _workerPromise = null;
    }));
  }

  final int _id;
  Future<PlatformWorker>? _workerPromise;

  final Emitter<Message> _onMessage = Emitter<Message>();
  @override
  Event<Message> get onMessage => _onMessage.event;

  final Emitter<Object?> _onError = Emitter<Object?>();
  @override
  Event<Object?> get onError => _onError.event;

  @override
  int getId() => _id;

  @override
  void postMessage(Message message, List<Object?> transfer) {
    _workerPromise?.then((PlatformWorker w) {
      try {
        w.postMessage(message, transfer);
      } catch (err) {
        onUnexpectedError(err);
        onUnexpectedError(StateError('FAILED to post message to worker'));
      }
    }).catchError((Object _) {});
  }
}

/// 1:1: JS `String.prototype.lastIndexOf(search, fromIndex)` — the source's
/// `lastIndexOf('#', start)` searches BACKWARDS from `start`, so a '#' to the
/// right of '?' is not found. Dart's `lastIndexOf` clamps differently, hence
/// this explicit helper.
int _jsLastIndexOf(String s, String search, int fromIndex) {
  if (search.isEmpty) {
    return fromIndex.clamp(0, s.length);
  }
  int start = fromIndex;
  if (start < 0) {
    start = 0;
  }
  if (start > s.length) {
    start = s.length;
  }
  for (int i = start; i >= 0; i--) {
    if (s.startsWith(search, i)) {
      return i;
    }
  }
  return -1;
}

/// 1:1: JS `String.prototype.substring(start, end)` — unlike Dart, JS clamps
/// indices to [0, length] and swaps when `start > end`. Used where the source
/// calls `substring` with values that may exceed the string length.
String _jsSubstring(String s, int start, [int? end]) {
  final int len = s.length;
  int a = start < 0 ? 0 : (start > len ? len : start);
  int b = end == null ? len : (end < 0 ? 0 : (end > len ? len : end));
  if (a > b) {
    final int tmp = a;
    a = b;
    b = tmp;
  }
  return s.substring(a, b);
}

/// 1:1: `JSON.stringify` for the values embedded in the blob. `null` here
/// represents JS `undefined` (e.g. `getNLSMessages()` before nls init) and
/// stringifies to the literal `undefined`, matching the JS template result.
String _jsonStringify(Object? value) {
  if (value == null) {
    return 'undefined';
  }
  return jsonEncode(value);
}

/// 1:1: DOM `URIError` ('Not a blob-url: ...'). Modelled as an Exception carrying
/// the JS `name` and `message`.
class UriError implements Exception {
  UriError(this.message);
  final String message;

  @override
  String toString() => 'URIError: $message';
}
