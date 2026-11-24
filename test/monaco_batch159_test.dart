import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/indexedDB.dart' as idb;
import 'package:semi_design_flutter/src/monaco/base/common/cancellation.dart' as cancellation;
import 'package:semi_design_flutter/src/monaco/base/common/platform.dart' as platform;
import 'package:semi_design_flutter/src/monaco/base/common/stream.dart' as stream;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' as uri;
import 'package:semi_design_flutter/src/monaco/platform/files/browser/htmlFileSystemProvider.dart' as hp;
import 'package:semi_design_flutter/src/monaco/platform/files/browser/webFileSystemAccess.dart' as wfsa;
import 'package:semi_design_flutter/src/monaco/platform/files/common/files.dart' as files;
import 'package:semi_design_flutter/src/monaco/platform/log/common/log.dart' as log;

final Map<String, dynamic> T =
    jsonDecode(r"""{
  "capabilitiesLinux": 1042,
  "capabilitiesNonLinux": 18,
  "register": {
    "first": [
      "file",
      "/a.txt"
    ],
    "same": [
      "file",
      "/a.txt"
    ],
    "conflict": [
      "file",
      "/a-1.txt"
    ],
    "dirFirst": [
      "file",
      "/d"
    ],
    "dirConflict": [
      "file",
      "/d-1"
    ],
    "dbKeys": [
      "/a-1.txt",
      "/a.txt",
      "/d",
      "/d-1"
    ],
    "ops": []
  },
  "resolution": {
    "root": true,
    "nested": true,
    "file": true,
    "rootGetFileWrongKind": "undefined",
    "missingFile": "undefined",
    "missingDir": "undefined",
    "dirRootStop": "undefined"
  },
  "stat": {
    "file": {
      "type": 1,
      "mtime": 1234,
      "ctime": 0,
      "size": 4
    },
    "dir": {
      "type": 2,
      "mtime": 0,
      "ctime": 0,
      "size": 0
    },
    "missing": {
      "name": "Unavailable (FileSystemError)",
      "message": "Error: No file system handle registered (/missing)",
      "code": "Unavailable"
    }
  },
  "readdir": [
    [
      "x.txt",
      1
    ],
    [
      "sub",
      2
    ]
  ],
  "readFile": [
    1,
    2,
    3,
    4,
    5
  ],
  "readFileMissing": {
    "name": "Unavailable (FileSystemError)",
    "message": "Error: No file system handle registered (/none)",
    "code": "Unavailable"
  },
  "writeFile": [
    {
      "label": "createNew",
      "result": {
        "ok": true
      },
      "content": null,
      "ops": [
        [
          "createFile",
          "root",
          "target.txt"
        ],
        [
          "write",
          "target.txt",
          [
            1,
            2
          ]
        ],
        [
          "close",
          "target.txt"
        ]
      ]
    },
    {
      "label": "overwriteExisting",
      "result": {
        "ok": true
      },
      "content": null,
      "ops": [
        [
          "write",
          "target.txt",
          [
            3
          ]
        ],
        [
          "close",
          "target.txt"
        ]
      ]
    },
    {
      "label": "existsNoOverwrite",
      "result": {
        "ok": false,
        "error": {
          "name": "EntryExists (FileSystemError)",
          "message": "Error: File already exists, writeFile (/root/target.txt)",
          "code": "EntryExists"
        }
      },
      "content": null,
      "ops": []
    },
    {
      "label": "missingNoCreate",
      "result": {
        "ok": false,
        "error": {
          "name": "EntryNotFound (FileSystemError)",
          "message": "Error: No such file, writeFile (/root/target.txt)",
          "code": "EntryNotFound"
        }
      },
      "content": null,
      "ops": []
    },
    {
      "label": "noParent",
      "result": {
        "ok": false,
        "error": {
          "name": "Unavailable (FileSystemError)",
          "message": "Error: No file system handle registered (/target.txt)",
          "code": "Unavailable"
        }
      },
      "content": null,
      "ops": []
    }
  ],
  "mkdir": {
    "ok": true
  },
  "delete": {
    "ok": true
  },
  "mkdirNoParent": {
    "ok": false,
    "error": {
      "name": "Unavailable (FileSystemError)",
      "message": "Error: No file system handle registered (/none)",
      "code": "Unavailable"
    }
  },
  "rename": {
    "same": {
      "ok": true
    },
    "file": {
      "ok": true
    },
    "toContent": [
      1,
      2
    ],
    "fromRemoved": true,
    "dir": {
      "ok": false,
      "error": {
        "name": "Unavailable (FileSystemError)",
        "message": "Error: No file system handle registered (/)",
        "code": "Unavailable"
      }
    },
    "rootChildren": [
      "to.txt"
    ]
  },
  "errors": {
    "passthrough": {
      "name": "EntryNotFound (FileSystemError)",
      "message": "Error: x",
      "code": "EntryNotFound"
    },
    "notAllowed": {
      "name": "Unavailable (FileSystemError)",
      "message": "Error: Insufficient permissions. Please retry and allow the operation.",
      "code": "Unavailable"
    },
    "generic": {
      "name": "Unknown (FileSystemError)",
      "message": "Error: plain",
      "code": "Unknown"
    },
    "create": {
      "name": "Unavailable (FileSystemError)",
      "message": "Error: msg (/a b)",
      "code": "Unavailable"
    }
  },
  "watchUnsupported": {
    "isDisposable": true,
    "logs": []
  },
  "watch": {
    "supported": true,
    "observed": [
      [
        "watched",
        {
          "recursive": true
        }
      ]
    ],
    "changes": [
      [
        {
          "resource": {
            "scheme": "file",
            "path": "/watched/a"
          },
          "type": 1
        },
        {
          "resource": {
            "scheme": "file",
            "path": "/watched/b"
          },
          "type": 2
        },
        {
          "resource": {
            "scheme": "file",
            "path": "/watched/c/d"
          },
          "type": 0
        }
      ]
    ],
    "logs": [
      [
        "trace",
        "[File Watcher ('FileSystemObserver')] [appeared] file:///watched/a"
      ],
      [
        "trace",
        "[File Watcher ('FileSystemObserver')] [disappeared] file:///watched/b"
      ],
      [
        "trace",
        "[File Watcher ('FileSystemObserver')] [modified] file:///watched/c/d"
      ]
    ]
  },
  "watchDisconnected": true,
  "watchErroredAfterDispose": true,
  "watchErrored": {
    "disconnected": true,
    "logs": [
      [
        "trace",
        "[File Watcher ('FileSystemObserver')] [errored] file:///watched/"
      ],
      [
        "trace",
        "[File Watcher ('FileSystemObserver')] errored, disposing observer (file:///watched)"
      ]
    ]
  },
  "streamEntire": {
    "writes": [
      {
        "0": 1,
        "1": 2
      },
      {
        "0": 3,
        "1": 4,
        "2": 5
      }
    ],
    "end": null,
    "error": null
  },
  "streamPartial": {
    "writes": [],
    "end": {
      "0": 2,
      "1": 3
    },
    "error": null
  },
  "streamCancelled": {
    "writes": [],
    "end": null,
    "error": null
  },
  "streamMissing": {
    "writes": [],
    "end": null,
    "error": {
      "name": "Unavailable (FileSystemError)",
      "message": "Error: No file system handle registered (/missing)",
      "code": "Unavailable"
    }
  }
}
""") as Map<String, dynamic>;

Map<String, dynamic> _truth(String key) => T[key] as Map<String, dynamic>;
List<dynamic> _truthList(String key) => T[key] as List<dynamic>;

List<int> _bytes(dynamic value) {
  if (value is Uint8List) return value.toList();
  if (value is List) return value.map((dynamic e) => (e as num).toInt()).toList();
  if (value is Map) {
    final List<String> keys = value.keys
        .map((dynamic k) => k.toString())
        .toList()
      ..sort();
    return keys
        .map((String k) => (value[k] as num).toInt())
        .toList();
  }
  return <int>[];
}

Map<String, Object?> _errorJson(Object error) {
  if (error is files.FileSystemProviderError) {
    return <String, Object?>{
      'name': error.name,
      'message': error.message,
      'code': error.code,
    };
  }
  return <String, Object?>{
    'name': error is _JsError ? error.name : 'Error',
    'message': error is _JsError ? error.message : error.toString(),
    'code': null,
  };
}


// ---- DOM carrier stubs ----------------------------------------------------

class _JsError implements Exception {
  _JsError(this.message, [this.name = 'Error']);
  final String message;
  final String name;

  @override
  String toString() => 'Error: $message';
}

class _Handle {
  _Handle(this.kind, this.name);

  final String kind;
  final String name;
  final Map<String, _Handle> children = <String, _Handle>{};
  Uint8List bytes = Uint8List(0);
  int lastModified = 0;
  _Handle? sameAs;
  String permission = 'granted';
  final List<List<Object?>> ops = <List<Object?>>[];
}

class _File {
  _File(this.handle);
  final _Handle handle;
}

class _Writable {
  _Writable(this.handle);
  final _Handle handle;
}

class _Readable {
  _Readable(this.bytes)
      : chunks = <Uint8List>[
          bytes.sublist(0, bytes.length < 2 ? bytes.length : 2),
          bytes.sublist(bytes.length < 2 ? bytes.length : 2),
        ];

  final Uint8List bytes;
  final List<Uint8List> chunks;
  int index = 0;
}

class _Observer {
  _Observer(this.callback);
  final void Function(List<dynamic> records) callback;
  final List<List<Object?>> observed = <List<Object?>>[];
  bool disconnected = false;
}

dynamic _propOf(dynamic obj, String name) {
  if (obj is _Handle) {
    switch (name) {
      case 'kind':
        return obj.kind;
      case 'name':
        return obj.name;
      case 'isSameEntry':
        return (dynamic other) async =>
            identical(obj, other) || identical(obj.sameAs, other);
      case 'queryPermission':
        return () async => obj.permission;
      case 'requestPermission':
        return () async {
          obj.ops.add(<Object?>['requestPermission', obj.name]);
          return 'granted';
        };
      case 'getFile':
        return () async => _File(obj);
      case 'getFileHandle':
        return (dynamic childName, [dynamic opts]) async {
          final String n = childName as String;
          final _Handle? existing = obj.children[n];
          if (existing != null) {
            if (existing.kind != 'file') {
              throw _JsError('not a file', 'TypeMismatchError');
            }
            return existing;
          }
          final bool create = opts is Map ? opts['create'] == true : false;
          if (!create) throw _JsError('Not found', 'NotFoundError');
          final _Handle created = _Handle('file', n);
          obj.children[n] = created;
          obj.ops.add(<Object?>['createFile', obj.name, n]);
          return created;
        };
      case 'getDirectoryHandle':
        return (dynamic childName, [dynamic opts]) async {
          final String n = childName as String;
          final _Handle? existing = obj.children[n];
          if (existing != null) {
            if (existing.kind != 'directory') {
              throw _JsError('not a dir', 'TypeMismatchError');
            }
            return existing;
          }
          final bool create = opts is Map ? opts['create'] == true : false;
          if (!create) throw _JsError('Not found', 'NotFoundError');
          final _Handle created = _Handle('directory', n);
          obj.children[n] = created;
          obj.ops.add(<Object?>['createDir', obj.name, n]);
          return created;
        };
      case 'removeEntry':
        return (dynamic childName, [dynamic opts]) async {
          final String n = childName as String;
          final _Handle? existing = obj.children.remove(n);
          if (existing == null) throw _JsError('Not found', 'NotFoundError');
          obj.ops.add(<Object?>[
            'remove',
            obj.name,
            n,
            opts is Map && opts['recursive'] == true,
          ]);
        };
      case 'createWritable':
        return () async => _Writable(obj);
      case 'stream':
        return () async => _Readable(obj.bytes);
    }
  }
  if (obj is _File) {
    switch (name) {
      case 'size':
        return obj.handle.bytes.length;
      case 'lastModified':
        return obj.handle.lastModified;
      case 'arrayBuffer':
        return () async => Uint8List.fromList(obj.handle.bytes);
      case 'stream':
        return () async => _Readable(obj.handle.bytes);
    }
  }
  if (obj is _Writable) {
    switch (name) {
      case 'write':
        return (dynamic content) async {
          obj.handle.ops.add(<Object?>[
            'write',
            obj.handle.name,
            _bytes(content),
          ]);
          obj.handle.bytes = Uint8List.fromList(_bytes(content));
        };
      case 'close':
        return () async =>
            obj.handle.ops.add(<Object?>['close', obj.handle.name]);
    }
  }
  if (obj is _Readable) {
    if (name == 'getReader') {
      return () async => obj;
    }
    if (name == 'read') {
      return () async {
        if (obj.index >= obj.chunks.length) {
          return <String, Object?>{'done': true, 'value': null};
        }
        return <String, Object?>{
          'done': false,
          'value': obj.chunks[obj.index++],
        };
      };
    }
  }
  if (obj is _Observer) {
    switch (name) {
      case 'observe':
        return (dynamic handle, [dynamic opts]) async {
          obj.observed.add(<Object?>[
            handle is _Handle ? handle.name : handle.toString(),
            opts,
          ]);
        };
      case 'disconnect':
        return () async {
          obj.disconnected = true;
        };
    }
  }
  if (obj is _JsError) {
    if (name == 'name') return obj.name;
    if (name == 'message') return obj.message;
  }
  if (obj is Map) return obj[name];
  return null;
}

class _TestLog extends log.NullLogService {
  _TestLog([this.level = log.LogLevel.Error]);

  int level;
  final List<List<Object?>> calls = <List<Object?>>[];

  @override
  int getLevel() => level;

  @override
  void error(Object message, [List<Object?> args = const <Object?>[]]) {
    calls.add(<Object?>['error', message.toString()]);
  }

  @override
  void trace(String message, [List<Object?> args = const <Object?>[]]) {
    calls.add(<Object?>['trace', message]);
  }
}

class _FakeDatabase implements idb.IDBDatabase {
  @override
  String get name => 'test';

  @override
  bool objectStoreNamesContains(String store) => true;

  @override
  void createObjectStore(String store) {}

  @override
  idb.IDBTransaction transaction(String store, String mode) =>
      throw UnimplementedError();

  @override
  void close() {}
}

class _Request implements idb.IDBRequest {
  _Request(this.result);
  @override
  Object? result;
  @override
  Object? error;
  @override
  void Function()? onsuccess;
  @override
  void Function(Object? error)? onerror;
}

class _ObjectStore implements idb.IDBObjectStore {
  _ObjectStore(this.db);
  final _TestIndexedDB db;

  @override
  idb.IDBRequest get(Object key) => _Request(db.data[key]);

  @override
  idb.IDBRequest put(Object value, [Object? key]) {
    if (key != null) db.data[key] = value;
    return _Request(key);
  }

  @override
  idb.IDBCursor? openCursor() => null;
}

class _TestIndexedDB extends idb.IndexedDB {
  _TestIndexedDB() : super(_FakeDatabase(), 'test');

  final Map<Object, dynamic> data = <Object, dynamic>{};

  @override
  Future<Object?> runInTransaction(
    String store,
    String transactionMode,
    Object Function(idb.IDBObjectStore store) dbRequestFn,
  ) async {
    final Object request = dbRequestFn(_ObjectStore(this));
    return request is idb.IDBRequest ? request.result : request;
  }
}

_Handle _file(String name, List<int> data) => _Handle('file', name)
  ..bytes = Uint8List.fromList(data)
  ..lastModified = 1234;

_Handle _dir(String name, [Map<String, _Handle> children = const <String, _Handle>{}]) {
  final _Handle handle = _Handle('directory', name);
  handle.children.addAll(children);
  return handle;
}

uri.URI _res(String path) => uri.URI.from(
      uri.UriComponents(scheme: 'file', path: path),
    );

Map<String, Object?> _changeJson(dynamic change) {
  final uri.URI resource = change.resource as uri.URI;
  return <String, Object?>{
    'resource': <String, Object?>{
      'scheme': resource.scheme,
      'path': resource.path,
    },
    'type': change.type,
  };
}

void _setUpCarriers() {
  hp.htmlFileSystemProviderGetProp = _propOf;
  wfsa.webFileSystemAccessGetProp = _propOf;
  hp.htmlFileSystemDirectoryEntries = (dynamic handle) async {
    if (handle is _Handle) {
      return handle.children.entries
          .map((MapEntry<String, _Handle> e) =>
              <Object?>[e.key, e.value])
          .toList();
    }
    return <List<Object?>>[];
  };
  hp.htmlFileSystemGlobalThis = <String, Object?>{};
}

List<_Observer> _observers = <_Observer>[];

void _enableObserver() {
  _observers = <_Observer>[];
  hp.htmlFileSystemGlobalThis = <String, Object?>{
    'FileSystemObserver': (dynamic callback) {
      final _Observer observer =
          _Observer(callback as void Function(List<dynamic> records));
      observers.add(observer);
      return observer;
    },
  };
}

Future<Map<String, Object?>> _collect(
  hp.HTMLFileSystemProvider provider,
  uri.URI resource,
  Object? opts,
  cancellation.CancellationToken token,
) async {
  final stream.WriteableStream<Uint8List> s =
      provider.readFileStream(resource, opts, token);
  final List<List<int>> writes = <List<int>>[];
  Object? error;
  final Completer<void> done = Completer<void>();
  s.on('data', (dynamic d) => writes.add(_bytes(d)));
  s.on('error', (dynamic e) => error = e);
  s.on('end', () {
    if (!done.isCompleted) done.complete();
  });
  await done.future.timeout(const Duration(seconds: 2));
  return <String, Object?>{
    'writes': writes.map((List<int> w) => w.toList()).toList(),
    'error': error == null ? null : _errorJson(error as Object),
  };
}

void main() {
  setUp(() {
    _setUpCarriers();
  });

  test('capabilities follow isLinux 1:1 truth', () {
    final hp.HTMLFileSystemProvider p =
        hp.HTMLFileSystemProvider(null, 'test', _TestLog());
    expect(T['capabilitiesLinux'], 1042);
    expect(T['capabilitiesNonLinux'], 18);
    expect(
      p.capabilities,
      platform.isLinux ? T['capabilitiesLinux'] : T['capabilitiesNonLinux'],
    );
  });

  test('register handles and index DB 1:1 truth', () async {
    final _TestIndexedDB db = _TestIndexedDB();
    final hp.HTMLFileSystemProvider p =
        hp.HTMLFileSystemProvider(db, 'test', _TestLog());
    final _Handle f1 = _file('a.txt', <int>[1]);
    final _Handle f2 = _file('a.txt', <int>[2]);
    final _Handle f3 = _file('a.txt', <int>[3]);
    f1.sameAs = f2;
    f2.sameAs = f1;
    final _Handle d1 = _dir('d');
    final _Handle d2 = _dir('d');

    final List<uri.URI> uris = <uri.URI>[
      await p.registerFileHandle(f1),
      await p.registerFileHandle(f2),
      await p.registerFileHandle(f3),
      await p.registerDirectoryHandle(d1),
      await p.registerDirectoryHandle(d2),
    ];
    final Map<String, dynamic> t = _truth('register');
    final List<dynamic> expected = <dynamic>[
      t['first'], t['same'], t['conflict'], t['dirFirst'], t['dirConflict'],
    ];
    for (int i = 0; i < uris.length; i++) {
      final List<dynamic> e = expected[i] as List<dynamic>;
      expect(<Object?>[uris[i].scheme, uris[i].path], e);
    }
    expect(
      db.data.keys.map((Object k) => k.toString()).toList()..sort(),
      t['dbKeys'],
    );
  });

  test('resolves registered and nested directory handles (official test)', () async {
    final _Handle nested = _dir('nested');
    final _Handle root = _dir('root', <String, _Handle>{'nested': nested});
    final hp.HTMLFileSystemProvider p =
        hp.HTMLFileSystemProvider(null, 'test', _TestLog());
    final uri.URI rootRes = await p.registerDirectoryHandle(root);
    final _Handle child = _file('child.txt', <int>[7, 8]);
    root.children['child.txt'] = child;

    final Map<String, dynamic> t = _truth('resolution');
    expect(identical(await p.getDirectoryHandle(rootRes), root), t['root']);
    expect(
      identical(
          await p.getDirectoryHandle(uri.URI.joinPath(rootRes, <String>['nested'])),
          nested),
      t['nested'],
    );
    expect(
      identical(
          await p.getFileHandle(uri.URI.joinPath(rootRes, <String>['child.txt'])),
          child),
      t['file'],
    );
    expect(
      await p.getFileHandle(rootRes).then(
          (dynamic h) => h == null ? 'undefined' : 'handle',
          onError: (Object _) => 'undefined'),
      t['rootGetFileWrongKind'],
    );
    expect(
      await p
          .getFileHandle(uri.URI.joinPath(rootRes, <String>['missing']))
          .then((dynamic h) => h == null ? 'undefined' : 'handle'),
      t['missingFile'],
    );
    expect(
      await p
          .getDirectoryHandle(uri.URI.joinPath(rootRes, <String>['missing']))
          .then((dynamic h) => h == null ? 'undefined' : 'handle'),
      t['missingDir'],
    );
    expect(
      await p.getDirectoryHandle(_res('/')).then(
          (dynamic h) => h == null ? 'undefined' : 'handle',
          onError: (Object _) => 'undefined'),
      t['dirRootStop'],
    );
  });

  test('stat and readdir 1:1 truth', () async {
    final hp.HTMLFileSystemProvider p =
        hp.HTMLFileSystemProvider(null, 'test', _TestLog());
    await p.registerFileHandle(_file('f.txt', <int>[1, 2, 3, 4]));
    await p.registerDirectoryHandle(_dir('folder'));
    expect((await p.stat(_res('/f.txt'))).toJson(), _truth('stat')['file']);
    expect((await p.stat(_res('/folder'))).toJson(), _truth('stat')['dir']);
    Object? caught;
    try {
      await p.stat(_res('/missing'));
    } catch (e) {
      caught = e;
    }
    expect(_errorJson(caught as Object), _truth('stat')['missing']);

    final hp.HTMLFileSystemProvider p2 =
        hp.HTMLFileSystemProvider(null, 'test', _TestLog());
    await p2.registerDirectoryHandle(_dir('entries', <String, _Handle>{
      'x.txt': _file('x.txt', <int>[1]),
      'sub': _dir('sub'),
    }));
    final List<List<Object?>> entries = await p2.readdir(_res('/entries'));
    expect(
      entries.map((List<Object?> e) => e.toList()).toList(),
      T['readdir'],
    );
  });

  test('readFile and errors 1:1 truth', () async {
    final hp.HTMLFileSystemProvider p =
        hp.HTMLFileSystemProvider(null, 'test', _TestLog());
    await p.registerFileHandle(_file('bin.dat', <int>[1, 2, 3, 4, 5]));
    expect(_bytes(await p.readFile(_res('/bin.dat'))), T['readFile']);
    Object? caught;
    try {
      await p.readFile(_res('/none'));
    } catch (e) {
      caught = e;
    }
    expect(_errorJson(caught as Object), T['readFileMissing']);

    final Map<String, dynamic> t = _truth('errors');
    expect(
      _errorJson(p.toFileSystemProviderError(files.createFileSystemProviderError(
        files.FileError('x'), files.FileSystemProviderErrorCode.FileNotFound))),
      t['passthrough'],
    );
    expect(
      _errorJson(p.toFileSystemProviderError(_JsError('denied', 'NotAllowedError'))),
      t['notAllowed'],
    );
    expect(
      _errorJson(p.toFileSystemProviderError(_JsError('plain'))),
      t['generic'],
    );
    expect(
      _errorJson(p.createFileSystemProviderError(
          _res('/a b'), 'msg', files.FileSystemProviderErrorCode.Unavailable)),
      t['create'],
    );
  });

  test('writeFile matrix 1:1 truth', () async {
    final List<dynamic> cases = _truthList('writeFile');
    for (final dynamic raw in cases) {
      final Map<String, dynamic> c = raw as Map<String, dynamic>;
      final _TestIndexedDB db = _TestIndexedDB();
      final hp.HTMLFileSystemProvider p =
          hp.HTMLFileSystemProvider(db, 'test', _TestLog());
      final bool nested = c['label'] != 'noParent';
      if (nested) {
        if (c['label'] == 'overwriteExisting' ||
            c['label'] == 'existsNoOverwrite') {
          await p.registerDirectoryHandle(_dir('root', <String, _Handle>{
            'target.txt': _file('target.txt', <int>[9, 9]),
          }));
        } else {
          await p.registerDirectoryHandle(_dir('root'));
        }
      }
      final uri.URI target =
          nested ? _res('/root/target.txt') : _res('/target.txt');
      final Map<String, dynamic> optsMap =
          (c['label'] == 'missingNoCreate')
              ? <String, dynamic>{'create': false, 'overwrite': false}
              : <String, dynamic>{'create': true, 'overwrite': c['label'] == 'overwriteExisting'};
      Object? caught;
      try {
        await p.writeFile(
          target,
          Uint8List.fromList(<int>[1, 2, 3, 4, 5, 6].sublist(0, 1)),
          optsMap,
        );
      } catch (e) {
        caught = e;
      }
      final Map<String, dynamic> expectedResult =
          c['result'] as Map<String, dynamic>;
      expect(caught == null, expectedResult['ok'],
          reason: 'case ${c['label']}');
      if (caught != null) {
        expect(_errorJson(caught), expectedResult['error'],
            reason: 'case ${c['label']}');
      }
    }
  });

  test('mkdir / delete / rename 1:1 truth', () async {
    final _TestIndexedDB db = _TestIndexedDB();
    final hp.HTMLFileSystemProvider p =
        hp.HTMLFileSystemProvider(db, 'test', _TestLog());
    await p.registerDirectoryHandle(_dir('root'));
    await p.mkdir(_res('/root/new'));
    expect(_truth('mkdir')['ok'], true);
    await p.delete(_res('/root/new'), <String, Object?>{'recursive': false});
    expect(_truth('delete')['ok'], true);
    Object? caught;
    try {
      await p.mkdir(_res('/none/x'));
    } catch (e) {
      caught = e;
    }
    expect(_errorJson(caught as Object), _truth('mkdirNoParent')['error']);

    final _TestIndexedDB db2 = _TestIndexedDB();
    final hp.HTMLFileSystemProvider p2 =
        hp.HTMLFileSystemProvider(db2, 'test', _TestLog());
    await p2.registerDirectoryHandle(_dir('root', <String, _Handle>{
      'from.txt': _file('from.txt', <int>[1, 2]),
    }));
    await p2.rename(_res('/root/from.txt'), _res('/root/from.txt'),
        <String, Object?>{'overwrite': false});
    await p2.rename(_res('/root/from.txt'), _res('/root/to.txt'),
        <String, Object?>{'overwrite': true});
    final Map<String, dynamic> t = _truth('rename');
    final dynamic toHandle = await p2.getFileHandle(_res('/root/to.txt'));
    final dynamic toFile =
        await Function.apply(_propOf(toHandle, 'getFile') as Function, const <Object?>[]);
    expect(_bytes(await Function.apply(_propOf(toFile, 'arrayBuffer') as Function, const <Object?>[])),
        t['toContent']);
    final dynamic fromHandle = await p2.getFileHandle(_res('/root/from.txt'));
    expect(fromHandle == null, t['fromRemoved']);
    final dynamic rootHandle = await p2.getDirectoryHandle(_res('/root'));
    expect(
      (rootHandle as _Handle).children.keys.toList()..sort(),
      t['rootChildren'],
    );
  });

  test('watch observer branch 1:1 truth', () async {
    final _TestLog unsupportedLog = _TestLog(log.LogLevel.Trace);
    final hp.HTMLFileSystemProvider p0 =
        hp.HTMLFileSystemProvider(null, 'test', unsupportedLog);
    p0.watch(_res('/root'), <String, Object?>{'recursive': false});
    await Future<void>.delayed(Duration.zero);
    expect(unsupportedLog.calls, _truth('watchUnsupported')['logs']);

    final _TestLog logService = _TestLog(log.LogLevel.Trace);
    final hp.HTMLFileSystemProvider p =
        hp.HTMLFileSystemProvider(null, 'test', logService);
    await p.registerDirectoryHandle(_dir('watched'));
    _enableObserver();
    final List<dynamic> changes = <dynamic>[];
    p.onDidChangeFile((dynamic ev) =>
        changes.add((ev as List<dynamic>).map(_changeJson).toList()));
    final dynamic subscription =
        p.watch(_res('/watched'), <String, Object?>{'recursive': true});
    await Future<void>.delayed(Duration.zero);
    final Map<String, dynamic> t = _truth('watch');
    expect(_observers.length, 1);
    expect(
      _observers[0].observed.map((List<Object?> o) => o.toList()).toList(),
      t['observed'],
    );
    _observers[0].callback(<dynamic>[
      <String, Object?>{'type': 'appeared', 'relativePathComponents': <String>['a']},
      <String, Object?>{'type': 'disappeared', 'relativePathComponents': <String>['b']},
      <String, Object?>{
        'type': 'modified',
        'relativePathComponents': <String>['c', 'd'],
      },
    ]);
    expect(changes, <dynamic>[t['changes'][0]]);
    expect(logService.calls, t['logs']);
    (subscription as dynamic).dispose();
    expect(_observers[0].disconnected, T['watchDisconnected']);
  });

  test('readFileStream 1:1 truth', () async {
    final hp.HTMLFileSystemProvider p =
        hp.HTMLFileSystemProvider(null, 'test', _TestLog());
    await p.registerFileHandle(_file('s.dat', <int>[1, 2, 3, 4, 5]));
    final Map<String, dynamic> entire =
        await _collect(p, _res('/s.dat'), <String, Object?>{},
            cancellation.CancellationToken.none);
    expect(
      entire['writes'],
      (_truth('streamEntire')['writes'] as List<dynamic>).map(_bytes).toList(),
    );
    expect(entire['error'], _truth('streamEntire')['error']);

    final Map<String, dynamic> partial = await _collect(
      p,
      _res('/s.dat'),
      <String, Object?>{'position': 1, 'length': 2},
      cancellation.CancellationToken.none,
    );
    expect(partial['writes'], <dynamic>[_bytes(_truth('streamPartial')['end'])]);
    expect(partial['error'], _truth('streamPartial')['error']);

    final Map<String, dynamic> cancelled = await _collect(
      p,
      _res('/s.dat'),
      <String, Object?>{},
      cancellation.CancellationToken.cancelled,
    );
    expect(
      cancelled['writes'],
      (_truth('streamCancelled')['writes'] as List<dynamic>).map(_bytes).toList(),
    );
    expect(cancelled['error'], _truth('streamCancelled')['error']);

    final Map<String, dynamic> missing = await _collect(
      p,
      _res('/missing'),
      <String, Object?>{},
      cancellation.CancellationToken.none,
    );
    expect(
      missing['writes'],
      (_truth('streamMissing')['writes'] as List<dynamic>).map(_bytes).toList(),
    );
    expect(missing['error'], _truth('streamMissing')['error']);
  });
}
