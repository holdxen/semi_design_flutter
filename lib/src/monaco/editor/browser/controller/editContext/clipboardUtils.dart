// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/controller/editContext/clipboardUtils.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Carriers:
//   - `ClipboardStoredMetadata` / `ClipboardDataToCopy` are interfaces ->
//     concrete carriers.
//   - `IReadableClipboardData` / `IWritableClipboardData` are interfaces.
//   - DOM `DataTransfer` / `File` -> narrow abstract carriers so the
//     readable/writable factories can be replayed without a browser.
// ---------------------------------------------------------------------------

import 'dart:convert' show jsonDecode, jsonEncode;

import '../../../../base/common/mime.dart' show Mimes;

/// 1:1: `ClipboardStoredMetadata`.
class ClipboardStoredMetadata {
  ClipboardStoredMetadata({
    required this.version,
    required this.id,
    required this.isFromEmptySelection,
    required this.isBlock,
    required this.multicursorText,
    required this.mode,
  });

  final int version;
  final String? id;
  final bool? isFromEmptySelection;
  final bool? isBlock;
  final List<String>? multicursorText;
  final String? mode;

  Map<String, Object?> toJson() => <String, Object?>{
        'version': version,
        'id': id,
        'isFromEmptySelection': isFromEmptySelection,
        'isBlock': isBlock,
        'multicursorText': multicursorText,
        'mode': mode,
      };

  static ClipboardStoredMetadata? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final int? version = raw['version'] is num
        ? (raw['version'] as num).toInt()
        : null;
    if (version != 1) return null;
    return ClipboardStoredMetadata(
      version: version!,
      id: raw['id'] as String?,
      isFromEmptySelection: raw['isFromEmptySelection'] as bool?,
      isBlock: raw['isBlock'] as bool?,
      multicursorText: (raw['multicursorText'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      mode: raw['mode'] as String?,
    );
  }
}

/// 1:1: `InMemoryClipboardMetadata` (internal).
class _InMemoryClipboardMetadata {
  _InMemoryClipboardMetadata(this.lastCopiedValue, this.data);
  final String lastCopiedValue;
  final ClipboardStoredMetadata data;
}

/// 1:1: `InMemoryClipboardMetadataManager`.
class InMemoryClipboardMetadataManager {
  static final InMemoryClipboardMetadataManager INSTANCE =
      InMemoryClipboardMetadataManager();

  _InMemoryClipboardMetadata? _lastState;

  void set(String lastCopiedValue, ClipboardStoredMetadata data) {
    _lastState = _InMemoryClipboardMetadata(lastCopiedValue, data);
  }

  ClipboardStoredMetadata? get(String pastedText) {
    if (_lastState != null && _lastState!.lastCopiedValue == pastedText) {
      return _lastState!.data;
    }
    _lastState = null;
    return null;
  }
}

/// 1:1: `CopyOptions`.
class CopyOptions {
  static bool forceCopyWithSyntaxHighlighting = false;
  static bool electronBugWorkaroundCopyEventHasFired = false;
}

/// 1:1: `IReadableClipboardData`.
abstract class IReadableClipboardData {
  List<String> get types;
  List<Object> get files;
  String getData(String type);
}

/// 1:1: `IWritableClipboardData`.
abstract class IWritableClipboardData {
  void setData(String type, String value);
}

/// 1:1: minimal `File` carrier (name + optional path).
abstract class IClipboardFile {
  String get name;
  String? get path;
}

/// 1:1: minimal `DataTransfer` carrier.
abstract class IClipboardDataTransfer {
  List<String> get types;
  List<Object> get files;
  String getData(String type);
  void setData(String type, String value);
}

/// 1:1: `ClipboardEventUtils.getTextData` — returns `[text, metadata]`.
List<Object?> getClipboardTextData(
  IClipboardDataTransfer clipboardData,
  String? Function(Object file) getFilePath,
) {
  final String text = clipboardData.getData(Mimes.text);
  ClipboardStoredMetadata? metadata;
  final String rawmetadata = clipboardData.getData('vscode-editor-data');
  if (rawmetadata.isNotEmpty) {
    try {
      metadata = ClipboardStoredMetadata.fromJson(jsonDecode(rawmetadata));
    } catch (_) {
      // no problem!
    }
  }
  if (text.isEmpty && metadata == null && clipboardData.files.isNotEmpty) {
    final List<Object> files = clipboardData.files.toList();
    return <Object?>[
      files.map((file) => getFilePath(file) ?? (file as IClipboardFile).name).join('\n'),
      null,
    ];
  }
  return <Object?>[text, metadata];
}

/// 1:1: `ClipboardEventUtils.setTextData`.
void setClipboardTextData(
  IWritableClipboardData clipboardData,
  String text,
  String? html,
  ClipboardStoredMetadata metadata,
) {
  clipboardData.setData(Mimes.text, text);
  if (html is String) {
    clipboardData.setData('text/html', html);
  }
  clipboardData.setData('vscode-editor-data', jsonEncode(metadata.toJson()));
}

/// 1:1: `createReadableClipboardData`.
IReadableClipboardData createReadableClipboardData(
  IClipboardDataTransfer? dataTransfer,
) =>
    _ReadableClipboardData(dataTransfer);

class _ReadableClipboardData implements IReadableClipboardData {
  _ReadableClipboardData(this._dataTransfer);
  final IClipboardDataTransfer? _dataTransfer;

  @override
  List<String> get types => _dataTransfer?.types.toList() ?? <String>[];

  @override
  List<Object> get files => _dataTransfer?.files.toList() ?? <Object>[];

  @override
  String getData(String type) => _dataTransfer?.getData(type) ?? '';
}

/// 1:1: `createWritableClipboardData`.
IWritableClipboardData createWritableClipboardData(
  IClipboardDataTransfer? dataTransfer,
) =>
    _WritableClipboardData(dataTransfer);

class _WritableClipboardData implements IWritableClipboardData {
  _WritableClipboardData(this._dataTransfer);
  final IClipboardDataTransfer? _dataTransfer;

  @override
  void setData(String type, String value) => _dataTransfer?.setData(type, value);
}
