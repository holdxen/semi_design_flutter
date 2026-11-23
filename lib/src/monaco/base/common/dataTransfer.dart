// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/dataTransfer.ts
// Translated 1:1 from TypeScript. TS interfaces -> abstract classes/carriers,
// `Thenable`/`Promise` -> `Future`, `Symbol.iterator` generator -> `Iterable`,
// `ReadonlyArray.map.join` -> Dart equivalents. The `Iterable.some` static is
// `IterableX.some` in this port (see iterator.dart note).
// ---------------------------------------------------------------------------

import './arrays.dart' as arrays;
import './iterator.dart' as iterator;
import './uri.dart' show URI;
import './uuid.dart' show generateUuid;

/// 1:1: `export interface IDataTransferFile`
abstract class IDataTransferFile {
  String get id;
  String get name;
  URI? get uri;
  Future<List<int>> data();
}

/// 1:1: `export interface IDataTransferItem`
abstract class IDataTransferItem {
  String? get id;
  Future<String> asString();
  IDataTransferFile? asFile();
  Object? get value;
}

/// Concrete carrier for `IDataTransferItem` created by the factory functions.
class _DataTransferItem implements IDataTransferItem {
  @override
  final String? id;
  final Future<String> Function() _asString;
  final IDataTransferFile? Function() _asFile;

  @override
  final Object? value;

  _DataTransferItem({
    this.id,
    required Future<String> Function() asString,
    required IDataTransferFile? Function() asFile,
    this.value,
  })  : _asString = asString,
        _asFile = asFile;

  @override
  Future<String> asString() => _asString();

  @override
  IDataTransferFile? asFile() => _asFile();
}

/// 1:1: `createStringDataTransferItem`
IDataTransferItem createStringDataTransferItem(Object stringOrPromise,
    [String? id]) {
  return _DataTransferItem(
    id: id,
    asString: () async => stringOrPromise is Future<String>
        ? await stringOrPromise
        : stringOrPromise as String,
    asFile: () => null,
    value: stringOrPromise is String ? stringOrPromise : null,
  );
}

/// 1:1: `createFileDataTransferItem`
IDataTransferItem createFileDataTransferItem(
  String fileName,
  URI? uri,
  Future<List<int>> Function() data, [
  String? id,
]) {
  final IDataTransferFile file = _DataTransferFile(
    id: generateUuid(),
    name: fileName,
    uri: uri,
    data: data,
  );
  return _DataTransferItem(
    id: id,
    asString: () async => '',
    asFile: () => file,
    value: null,
  );
}

class _DataTransferFile implements IDataTransferFile {
  @override
  final String id;

  @override
  final String name;

  @override
  final URI? uri;

  final Future<List<int>> Function() _data;

  _DataTransferFile({
    required this.id,
    required this.name,
    required this.uri,
    required Future<List<int>> Function() data,
  }) : _data = data;

  @override
  Future<List<int>> data() => _data();
}

/// 1:1: `export interface IReadonlyVSDataTransfer`
abstract class IReadonlyVSDataTransfer {
  int get size;

  bool has(String mimeType);

  bool matches(String pattern);

  IDataTransferItem? get(String mimeType);

  /// 1:1: `[Symbol.iterator]()` — yields `[mime, item]` pairs.
  Iterable<List<Object>> entries();
}

/// 1:1: `export class VSDataTransfer`
class VSDataTransfer implements IReadonlyVSDataTransfer {
  final Map<String, List<IDataTransferItem>> _entries =
      <String, List<IDataTransferItem>>{};

  @override
  int get size => _entries.length;

  @override
  bool has(String mimeType) => _entries.containsKey(toKey(mimeType));

  @override
  bool matches(String pattern) {
    final List<String> mimes = _entries.keys.toList();
    if (iterator.IterableX.some(entries(), (List<Object> pair, int i) =>
        (pair[1] as IDataTransferItem).asFile() != null)) {
      mimes.add('files');
    }
    return _matchesMimeTypeNormalized(
        _normalizeMimeType(pattern), mimes);
  }

  @override
  IDataTransferItem? get(String mimeType) {
    final List<IDataTransferItem>? items = _entries[toKey(mimeType)];
    return items != null && items.isNotEmpty ? items[0] : null;
  }

  /// 1:1: `append(mimeType, value)`
  void append(String mimeType, IDataTransferItem value) {
    // NOTE: source uses the raw `mimeType` for the lookup of existing entries
    // but `toKey` for new insertion. Kept 1:1.
    final List<IDataTransferItem>? existing = _entries[mimeType];
    if (existing != null) {
      existing.add(value);
    } else {
      _entries[toKey(mimeType)] = <IDataTransferItem>[value];
    }
  }

  /// 1:1: `replace(mimeType, value)`
  void replace(String mimeType, IDataTransferItem value) {
    _entries[toKey(mimeType)] = <IDataTransferItem>[value];
  }

  /// 1:1: `delete(mimeType)`
  void delete(String mimeType) {
    _entries.remove(toKey(mimeType));
  }

  @override
  Iterable<List<Object>> entries() sync* {
    for (final MapEntry<String, List<IDataTransferItem>> entry
        in _entries.entries) {
      for (final IDataTransferItem item in entry.value) {
        yield <Object>[entry.key, item];
      }
    }
  }

  String toKey(String mimeType) => _normalizeMimeType(mimeType);
}

/// 1:1: `normalizeMimeType`
String _normalizeMimeType(String mimeType) => mimeType.toLowerCase();

/// 1:1: `export function matchesMimeType`
bool matchesMimeType(String pattern, List<String> mimeTypes) {
  return _matchesMimeTypeNormalized(
    _normalizeMimeType(pattern),
    mimeTypes.map(_normalizeMimeType).toList(),
  );
}

/// 1:1: `matchesMimeType_normalized`
bool _matchesMimeTypeNormalized(
    String normalizedPattern, List<String> normalizedMimeTypes) {
  // Anything wildcard
  if (normalizedPattern == '*/*') {
    return normalizedMimeTypes.isNotEmpty;
  }

  // Exact match
  if (normalizedMimeTypes.contains(normalizedPattern)) {
    return true;
  }

  // Wildcard, such as `image/*`
  final RegExp wildcard = RegExp(r'^([a-z]+)\/([a-z]+|\*)$', caseSensitive: false);
  final RegExpMatch? match = wildcard.firstMatch(normalizedPattern);
  if (match == null) {
    return false;
  }

  final String type = match.group(1)!;
  final String subtype = match.group(2)!;
  if (subtype == '*') {
    return normalizedMimeTypes.any((String mime) => mime.startsWith('$type/'));
  }

  return false;
}

/// 1:1: `export const UriList = Object.freeze({...})`
class UriList {
  UriList._();

  /// 1:1: `create(entries)`
  static String create(List<Object> entries) {
    return arrays.distinct(entries.map(_entryToString).toList()).join('\r\n');
  }

  static String _entryToString(Object x) => x.toString();

  /// 1:1: `split(str)`
  static List<String> split(String str) => str.split('\r\n');

  /// 1:1: `parse(str)`
  static List<String> parse(String str) =>
      split(str).where((String value) => !value.startsWith('#')).toList();
}
