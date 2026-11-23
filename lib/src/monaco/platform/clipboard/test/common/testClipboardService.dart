// 1:1 port of vs/platform/clipboard/test/common/testClipboardService.ts
import 'dart:typed_data' show Uint8List;

import '../../../../base/common/uri.dart' show URI;
import '../../common/clipboardService.dart' show IClipboardServiceType;

/// 1:1: `export class TestClipboardService implements IClipboardService`
class TestClipboardService implements IClipboardServiceType {
  // ignore: unused_element
  Object? get _serviceBrand => null;

  @override
  Future<Uint8List> readImage() {
    throw StateError('Method not implemented.');
  }

  Uint8List? _image;

  @override
  Future<void> writeImage(Object data) async {
    _image = data is Future<Uint8List>
        ? await data
        : data as Uint8List;
  }

  /// 1:1: `get writtenImage(): Uint8Array | undefined`
  Uint8List? get writtenImage => _image;

  String? _text;

  @override
  Future<void>? triggerPaste([int? targetWindowId]) => Future.value();

  @override
  Future<void> writeText(String text, [String? type]) async {
    _text = text;
  }

  @override
  Future<String> readText([String? type]) async {
    return _text ?? '';
  }

  String? _findText;

  @override
  Future<String> readFindText() async {
    return _findText ?? '';
  }

  @override
  Future<void> writeFindText(String text) async {
    _findText = text;
  }

  List<URI>? _resources;

  @override
  Future<void> writeResources(List<URI> resources) async {
    _resources = resources;
  }

  @override
  Future<List<URI>> readResources() async {
    return _resources ?? <URI>[];
  }

  @override
  Future<bool> hasResources() async {
    return _resources != null && _resources!.isNotEmpty;
  }

  /// Interface requires this optional method; TS test class does not define it.
  @override
  void clearInternalState() {}
}
