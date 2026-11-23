import 'dart:async';
import 'dart:math' show sha256;

import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/browser/browser.dart' as browser;
import 'package:semi_design_flutter/src/monaco/base/browser/fastDomNode.dart' as fdn;
import 'package:semi_design_flutter/src/monaco/base/browser/iframe.dart' as iframe;
import 'package:semi_design_flutter/src/monaco/base/browser/indexedDB.dart' as idb;
import 'package:semi_design_flutter/src/monaco/base/test/common/snapshot.dart' as snap;
import 'package:semi_design_flutter/src/monaco/base/browser/window.dart'
    show CodeWindow;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;

// ---------------------------------------------------------------------------
// fakes
// ---------------------------------------------------------------------------

class _TokenList implements fdn.DomTokenList {
  final _Element owner;
  final Set<String> tokens = <String>{};
  _TokenList(this.owner);
  @override
  void toggle(String token, [bool? force]) {
    final bool add = force ?? !tokens.contains(token);
    if (add) {
      tokens.add(token);
    } else {
      tokens.remove(token);
    }
    owner.className = tokens.join(' ');
  }
}

class _Element implements fdn.DomElement {
  @override
  final Map<String, String> style = <String, String>{};
  @override
  String className = '';
  @override
  late final fdn.DomTokenList classList = _TokenList(this);
  final List<String> attrs = <String>[];
  final List<fdn.DomElement> children = <fdn.DomElement>[];
  int focusCount = 0;

  @override
  void focus() => focusCount++;
  @override
  void setAttribute(String name, String value) => attrs.add('$name=$value');
  @override
  void removeAttribute(String name) => attrs.add('-$name');
  @override
  void appendChild(fdn.DomElement child) => children.add(child);
  @override
  void removeChild(fdn.DomElement child) => children.remove(child);
}

class _Mql implements browser.MediaQueryList {
  @override
  bool matches;
  final List<browser.MediaQueryListEvent> events = <browser.MediaQueryListEvent>[];
  _Mql(this.matches);
  @override
  void addEventListener(String type, void Function(browser.MediaQueryListEvent ev) cb) {
    events.add(browser.MediaQueryListEvent(matches));
    _cbs.add(cb);
  }
  final List<void Function(browser.MediaQueryListEvent)> _cbs = <void Function(browser.MediaQueryListEvent)>[];
  void fire(bool value) {
    matches = value;
    for (final cb in _cbs) {
      cb(browser.MediaQueryListEvent(value));
    }
  }
}

class _Wco implements browser.WindowControlsOverlayLike {
  @override
  bool visible;
  browser.DOMRect? rect;
  _Wco(this.visible, [this.rect]);
  @override
  browser.DOMRect? getTitlebarAreaRect() => rect;
}

class _Navigator {
  final browser.WindowControlsOverlayLike? wco;
  final String userAgent;
  _Navigator({this.wco, this.userAgent = ''});
  browser.WindowControlsOverlayLike? get windowControlsOverlay => wco;
}

class _Loc implements iframe.IframeLocation {
  @override
  final String origin;
  _Loc(this.origin);
}

class _ElementRect implements iframe.IframeElement {
  @override
  final iframe.IframeRect rect;
  _ElementRect(this.rect);
  @override
  iframe.IframeRect getBoundingClientRect() => rect;
}

class _Frame implements iframe.IframeWindow {
  @override
  iframe.IframeWindow? parent;
  @override
  iframe.IframeLocation location;
  @override
  iframe.IframeElement? frameElement;
  @override
  num scrollY;
  @override
  num scrollX;
  _Frame(this.location,
      {this.parent, this.frameElement, this.scrollY = 0, this.scrollX = 0});
}

class _Req implements idb.IDBRequest {
  @override
  Object? result;
  @override
  Object? error;
  @override
  void Function()? onsuccess;
  @override
  void Function(Object? error)? onerror;
  _Req({this.result, this.error});
  void succeed() => onsuccess?.call();
}

class _Store implements idb.IDBObjectStore {
  final Map<Object, Object?> data;
  final List<_Req> requests = <_Req>[];
  _Store(this.data);
  @override
  idb.IDBRequest get(Object key) {
    final r = _Req(result: data[key]);
    requests.add(r);
    return r;
  }
  @override
  idb.IDBRequest put(Object value, [Object? key]) {
    data[key!] = value;
    return _Req();
  }
  @override
  idb.IDBCursor? openCursor() {
    if (data.isEmpty) {
      return null;
    }
    final entries = data.entries.toList();
    final cursor = _Cursor(entries);
    return cursor;
  }
}

class _CursorResult implements idb.IDBCursorResult {
  final MapEntry<Object, Object?> entry;
  final _Cursor owner;
  _CursorResult(this.entry, this.owner);
  @override
  Object get key => entry.key;
  @override
  Object? get value => entry.value;
  @override
  void continueCursor() => owner._advance();
}

class _Cursor implements idb.IDBCursor {
  final List<MapEntry<Object, Object?>> _entries;
  int _index = 0;
  _Cursor(this._entries);
  @override
  idb.IDBCursorResult? get result =>
      _index < _entries.length ? _CursorResult(_entries[_index], this) : null;
  @override
  Object? get error => null;
  @override
  void Function()? onsuccess;
  @override
  void Function(Object? error)? onerror;
  void _advance() {
    _index++;
    onsuccess?.call();
  }
  void start() => onsuccess?.call();
  @override
  void continueCursor() => _advance();
}

class _Tx implements idb.IDBTransaction {
  final _Store store;
  @override
  void Function()? oncomplete;
  @override
  void Function(Object? error)? onerror;
  @override
  void Function(Object? error)? onabort;
  @override
  Object? error;
  bool aborted = false;
  _Tx(this.store);
  @override
  idb.IDBObjectStore objectStore(String storeName) => store;
  @override
  void abort() => aborted = true;
}

class _Db implements idb.IDBDatabase {
  @override
  final String name;
  final Set<String> stores;
  final Map<Object, Object?> data;
  final List<_Tx> transactions = <_Tx>[];
  int closeCount = 0;
  _Db(this.name, {Set<String>? stores, Map<Object, Object?>? data})
      : stores = stores ?? <String>{'items'},
        data = data ?? <Object, Object?>{};
  @override
  bool objectStoreNamesContains(String store) => stores.contains(store);
  @override
  void createObjectStore(String store) => stores.add(store);
  @override
  idb.IDBTransaction transaction(String store, String mode) {
    final tx = _Tx(_Store(data));
    transactions.add(tx);
    return tx;
  }
  @override
  void close() => closeCount++;
}

class _OpenReq implements idb.IDBOpenRequest {
  final _Db db;
  final bool failMissing;
  @override
  Object? error;
  @override
  Object get result => db;
  @override
  void Function()? onerror;
  @override
  void Function()? onsuccess;
  @override
  void Function()? onupgradeneeded;
  _OpenReq(this.db, {this.failMissing = false});
  void fireUpgrade() => onupgradeneeded?.call();
  void fireSuccess() => onsuccess?.call();
}

class _DeleteReq implements idb.IDBDeleteRequest {
  @override
  Object? error;
  @override
  void Function(Object? err)? onerror;
  @override
  void Function()? onsuccess;
  void fireSuccess() => onsuccess?.call();
}

class _Factory implements idb.IndexedDbFactory {
  final _Db db;
  final List<_OpenReq> openRequests = <_OpenReq>[];
  final List<_DeleteReq> deleteRequests = <_DeleteReq>[];
  int deleteCallCount = 0;
  _Factory(this.db);
  @override
  idb.IDBOpenRequest open(String name, int? version) {
    final r = _OpenReq(db);
    openRequests.add(r);
    return r;
  }
  @override
  idb.IDBDeleteRequest deleteDatabase(String name) {
    deleteCallCount++;
    final r = _DeleteReq();
    deleteRequests.add(r);
    return r;
  }
}

void main() {
  // -------------------------------------------------------------------------
  // fastDomNode
  // -------------------------------------------------------------------------
  group('batch24 / fastDomNode', () {
    test('numberAsPixels converts numbers and passes strings', () {
      expect(fdn.numberAsPixels(10), '10px');
      expect(fdn.numberAsPixels(1.5), '1.5px');
      expect(fdn.numberAsPixels('50%'), '50%');
    });

    test('setters write style and skip unchanged values (dirty-check)', () {
      final el = _Element();
      final node = fdn.createFastDomNode(el);
      node.setWidth(100);
      expect(el.style['width'], '100px');
      el.style['width'] = 'EXTERNAL';
      node.setWidth(100); // cached == value => no write
      expect(el.style['width'], 'EXTERNAL');
      node.setWidth(200);
      expect(el.style['width'], '200px');
    });

    test('font/box/contain/layer-hint attributes', () {
      final el = _Element();
      final node = fdn.FastDomNode(el);
      node.setFontFamily('monospace');
      node.setFontWeight('bold');
      node.setBoxShadow('0 0 1px');
      node.setContain('strict');
      node.setLayerHinting(true);
      expect(el.style['fontFamily'], 'monospace');
      expect(el.style['fontWeight'], 'bold');
      expect(el.style['boxShadow'], '0 0 1px');
      expect(el.style['contain'], 'strict');
      expect(el.style['transform'], 'translate3d(0px, 0px, 0px)');
      node.setLayerHinting(false);
      expect(el.style['transform'], '');
    });

    test('className/toggle/attributes/children/focus', () {
      final el = _Element();
      final child = _Element();
      final node = fdn.FastDomNode(el);
      final childNode = fdn.FastDomNode(child);
      node.setClassName('a');
      expect(el.className, 'a');
      node.toggleClassName('b', true);
      expect(el.className, contains('b'));
      node.setAttribute('role', 'button');
      node.removeAttribute('role');
      node.appendChild(childNode);
      expect(el.children, [child]);
      node.removeChild(childNode);
      expect(el.children, isEmpty);
      node.focus();
      expect(el.focusCount, 1);
    });
  });

  // -------------------------------------------------------------------------
  // browser
  // -------------------------------------------------------------------------
  group('batch24 / browser', () {
    tearDown(() {
      browser.matchMediaProvider = null;
      browser.navigatorProvider = ([Object? t]) => null;
      browser.monacoEnvironmentGlobal = null;
    });

    test('zoom level/factor state machine and events', () {
      final w = CodeWindow(Object(), 1);
      final ids = <int>[];
      final sub = browser.onDidChangeZoomLevel((dynamic id) => ids.add(id as int));
      expect(browser.getZoomLevel(w), 0);
      browser.setZoomLevel(2, w);
      expect(browser.getZoomLevel(w), 2);
      browser.setZoomLevel(2, w); // no change
      browser.setZoomFactor(1.4, w);
      expect(browser.getZoomFactor(w), 1.4);
      expect(ids, [1]);
      sub.dispose();
    });

    test('fullscreen events', () {
      final w = CodeWindow(Object(), 7);
      final ids = <int>[];
      final sub = browser.onDidChangeFullscreen((dynamic id) => ids.add(id as int));
      expect(browser.isFullscreen(w), isFalse);
      browser.setFullscreen(true, w);
      expect(browser.isFullscreen(w), isTrue);
      browser.setFullscreen(false, w);
      expect(ids, [7, 7]);
      sub.dispose();
    });

    test('user-agent derived constants use injected UA', () {
      browser.userAgentProvider = () =>
          'Mozilla AppleWebKit Chrome Safari Electron/1 Android';
      expect(browser.isFirefox, isFalse);
      expect(browser.isWebKit, isTrue);
      expect(browser.isChrome, isTrue);
      expect(browser.isSafari, isFalse); // isChrome wins
      expect(browser.isWebkitWebView, isFalse);
      expect(browser.isElectron, isTrue);
      expect(browser.isAndroid, isTrue);
      browser.userAgentProvider = () => platformDefaultUa;
    });

    test('WCO helpers through injected navigator', () {
      final rect = browser.DOMRect(x: 0, y: 0, width: 100, height: 40);
      browser.navigatorProvider = ([Object? t]) => _Navigator(wco: _Wco(true, rect));
      expect(browser.isWCOEnabled(), isTrue);
      expect(browser.getWCOTitlebarAreaRect(Object()) == null, isFalse);
      expect(browser.getVisibleWCOTitlebarAreaRect(Object()), same(rect));

      browser.navigatorProvider = ([Object? t]) => _Navigator(wco: _Wco(false, rect));
      expect(browser.getVisibleWCOTitlebarAreaRect(Object()), isNull);
    });

    test('getMonacoEnvironment returns injected value', () {
      final env = browser.IMonacoEnvironment(globalAPI: true);
      browser.monacoEnvironmentGlobal = env;
      expect(browser.getMonacoEnvironment(), same(env));
    });

    test('addMatchMediaChangeListener uses matchMedia for string queries', () {
      final mql = _Mql(false);
      browser.matchMediaProvider = (Object w, String q) => mql;
      final received = <browser.MediaQueryListEvent>[];
      browser.addMatchMediaChangeListener(Object(), '(foo)', (ev) => received.add(ev));
      mql.fire(true);
      expect(received.single.matches, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // iframe
  // -------------------------------------------------------------------------
  group('batch24 / iframe', () {
    setUp(() => iframe.sameOriginWindowChainCache.clear());

    test('getParentWindowIfSameOrigin handles self/no parent', () {
      final w = _Frame(_Loc('https://a'));
      expect(iframe.getParentWindowIfSameOrigin(w), isNull);
    });

    test('sha256AsBase32 is 52 chars and deterministic', () {
      final bytes = List<int>.generate(32, (i) => i);
      final a = iframe.sha256AsBase32(bytes);
      final b = iframe.sha256AsBase32(bytes);
      expect(a, b);
      expect(a.length, 52);
      expect(RegExp(r'^[0-9a-v]+$').hasMatch(a), isTrue);
    });

    test('parentOriginHash uses injected digest and JSON shape', () async {
      List<int>? seen;
      iframe.sha256Provider = (bytes) async {
        seen = bytes;
        return List<int>.filled(32, 0xff);
      };
      final hash = await iframe.parentOriginHash('https://x', 'salt');
      expect(hash.length, 52);
      expect(String.fromCharCodes(seen!), contains('"parentOrigin":"https://x"'));
      expect(String.fromCharCodes(seen!), contains('"salt":"salt"'));
      iframe.sha256Provider = null;
      expect(() => iframe.parentOriginHash('a', 'b'), throwsA(isA<StateError>()));
    });

    test('position relative to ancestor accumulates scrolls and iframe rects', () {
      final root = _Frame(_Loc('https://x'));
      final iframeEl = _ElementRect(const iframe.IframeRect(top: 10, left: 20));
      final child = _Frame(_Loc('https://x'),
          parent: root, frameElement: iframeEl, scrollY: 5, scrollX: 7);
      // `ancestorWindow` null short-circuits to (0,0) per source; use a
      // non-chain ancestor so the full chain is walked.
      final outsideAncestor = _Frame(_Loc('https://x'));
      final pos = iframe.IframeUtils.getPositionOfChildWindowRelativeToAncestorWindow(
          child, outsideAncestor);
      // chain = [child, root]; child contributes scrollY=5 + iframe rect 10.
      // root has iframeElement=null so the loop breaks after adding its scroll.
      expect(pos.top, 15); // 5 (child scrollY) + 10 (iframe rect top)
      expect(pos.left, 27); // 7 (child scrollX) + 20 (iframe rect left)
    });

    test('same window yields zero position', () {
      final w = _Frame(_Loc('https://x'));
      final pos = iframe.IframeUtils.getPositionOfChildWindowRelativeToAncestorWindow(w, w);
      expect(pos.top, 0);
      expect(pos.left, 0);
    });
  });

  // -------------------------------------------------------------------------
  // indexedDB
  // -------------------------------------------------------------------------
  group('batch24 / indexedDB', () {
    setUp(() => idb.indexedDbFactory = null);

    test('DBClosedError has code and message', () {
      final e = idb.DBClosedError('mydb');
      expect(e.code, 'DBClosed');
      expect(e.message, contains('mydb'));
    });

    test('create + upgrade creates missing stores', () async {
      final db = _Db('mydb', stores: <String>{});
      final factory = _Factory(db);
      idb.indexedDbFactory = factory;
      final future = idb.IndexedDB.create('mydb', 1, <String>['items']);
      // fire upgrade then success on the queued open request.
      await Future<void>.delayed(Duration.zero);
      factory.openRequests.single.fireUpgrade();
      factory.openRequests.single.fireSuccess();
      final inst = await future;
      expect(db.stores, contains('items'));
      expect(inst.name, 'mydb');
    });

    test('runInTransaction returns single result and removes pending', () async {
      final db = _Db('d', data: <Object, Object?>{'k': 'v'});
      idb.indexedDbFactory = _Factory(db);
      final inst = idb.IndexedDB(db, 'd');
      final future = inst.runInTransaction(
          'items', 'readonly', (idb.IDBObjectStore s) => s.get('k'));
      await Future<void>.delayed(Duration.zero);
      final tx = db.transactions.single as _Tx;
      tx.oncomplete?.call();
      expect(await future, 'v');
      expect(inst.hasPendingTransactions(), isFalse);
    });

    test('compareAndSwap swaps when expected matches', () async {
      final db = _Db('d', data: <Object, Object?>{'k': 'old'});
      idb.indexedDbFactory = _Factory(db);
      final inst = idb.IndexedDB(db, 'd');
      final future = inst.compareAndSwap(
          'items', 'k', 'old', 'new', (Object? v) => v is String);
      await Future<void>.delayed(Duration.zero);
      final tx = db.transactions.single as _Tx;
      // compareAndSwap set onsuccess on the get request it created.
      final captured = tx.store.requests.single;
      captured.succeed();
      tx.oncomplete?.call();
      final result = await future;
      expect(result['swapped'], isTrue);
      expect(result['currentValue'], 'new');
      expect(db.data['k'], 'new');
    });

    test('close aborts pending transactions and closes db', () async {
      final db = _Db('d');
      final inst = idb.IndexedDB(db, 'd');
      final future = inst.runInTransaction(
          'items', 'readonly', (idb.IDBObjectStore s) => s.get('k'));
      await Future<void>.delayed(Duration.zero);
      expect(inst.hasPendingTransactions(), isTrue);
      inst.close();
      expect((db.transactions.single as _Tx).aborted, isTrue);
      expect(db.closeCount, 1);
      expect(inst.database, isNull);
      // complete the pending future to avoid a dangling future
      (db.transactions.single as _Tx).oncomplete?.call();
      await future;
      expect(() => inst.close(), returnsNormally);
    });
  });

  // -------------------------------------------------------------------------
  // snapshot
  // -------------------------------------------------------------------------
  group('batch24 / snapshot', () {
    test('sanitizeName and normalizeCrlf', () {
      expect(snap.sanitizeName('a b/c'), 'a_b_c');
      expect(snap.normalizeCrlf('a\r\nb'), 'a\nb');
    });

    test('formatValue scalars and strings', () {
      expect(snap.formatValue(null), 'null');
      expect(snap.formatValue(true), 'true');
      expect(snap.formatValue(42), '42');
      expect(snap.formatValue('top', 0), 'top');
      expect(snap.formatValue('nested', 1), '"nested"');
    });

    test('formatValue arrays / multiline / circular', () {
      expect(snap.formatValue(<int>[1, 2]), '[ 1, 2 ]');
      final List<Object?> circular = <Object?>[];
      circular.add(circular);
      expect(snap.formatValue(circular), contains('[Circular]'));
      final long = List<int>.generate(30, (i) => i);
      expect(snap.formatValue(long), contains('\n'));
    });

    test('formatValue map / set / debug.description', () {
      expect(snap.formatValue(<String, int>{'a': 1}), contains('a: 1'));
      expect(snap.formatValue(<int>{1, 2}), contains('Set '));
      final obj = <String, Object?>{
        'debug.description': () => 'DESCRIBED',
        'other': 1,
      };
      expect(snap.formatValue(obj), 'DESCRIBED');
    });

    test('assertSnapshot creates a new snapshot on missing file', () async {
      final files = <String, String>{};
      snap.snapshotSourceRootProvider = () => URI.file('/src');
      snap.readFileInTests = (path) async => throw StateError('missing');
      snap.writeFileInTests = (path, contents) async {
        files[path] = contents;
      };
      snap.mkdirPInTests = (path) async {};
      snap.readDirInTests = (path) async => <String>[];
      snap.unlinkInTests = (path) async {};
      void Function(dynamic)? setupCb;
      snap.snapshotSetup = (cb) => setupCb = cb;
      snap.snapshotTeardown = (_) async {};
      snap.installSnapshotHooks();
      setupCb!(snap.SnapshotTest(
        file: '/src/base/test/common/foo.test.ts',
        fullTitle: () => 'Foo Bar',
      ));
      await snap.assertSnapshot(<int>[1, 2]);
      expect(files.values.single, '[ 1, 2 ]');
      expect(files.keys.single, endsWith('Foo_Bar.0.snap'));
    });
  });
}

// default UA snapshot for restoration between browser tests
const String platformDefaultUa = '';
