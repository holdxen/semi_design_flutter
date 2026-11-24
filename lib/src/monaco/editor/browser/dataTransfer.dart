// 1:1 port of vscode/src/vs/editor/browser/dataTransfer.ts
//
// Carriers: DOM `DataTransfer` / `DataTransferItem` / `File` live in the
// dom.dart port (see `DomDataTransferItem`); `VSDataTransfer`,
// `IDataTransferItem`, `createStringDataTransferItem`, `createFileDataTransferItem`
// and `UriList` live in `base/common/dataTransfer.dart`.
//
// Adaptations (documented inline; no algorithm or control-flow change):
//  * DOM `item.getAsString(resolve)` is callback based in both languages, so
//    the Promise wrapper keeps its exact shape.
//  * `new Uint8Array(await file.arrayBuffer())` → the carrier's
//    `arrayBuffer()` already yields the bytes (`Future<List<int>>`).
//  * `Object.freeze([...])` → a `const` list.
import 'dart:async' show Completer;

import '../../base/browser/dnd.dart' show DataTransfers;
import '../../base/common/dataTransfer.dart'
    show
        IDataTransferItem,
        UriList,
        VSDataTransfer,
        createFileDataTransferItem,
        createStringDataTransferItem;
import '../../base/common/mime.dart' show Mimes;
import '../../base/common/uri.dart' show URI;
import '../../platform/dnd/browser/dnd.dart'
    show CodeDataTransfers, getPathForFile;
import '../../base/browser/dom.dart' as dom;

VSDataTransfer toVSDataTransfer(dom.DomDataTransfer dataTransfer) {
  final VSDataTransfer vsDataTransfer = VSDataTransfer();
  // TS: `for (const item of dataTransfer.items)` — a missing list throws.
  for (final dom.DomDataTransferItem? item in dataTransfer.items!) {
    if (item == null) {
      continue;
    }
    final String type = item.type;
    if (item.kind == 'string') {
      // TS: `new Promise<string>(resolve => item.getAsString(resolve))`
      final Completer<String> completer = Completer<String>();
      item.getAsString!((String value) => completer.complete(value));
      vsDataTransfer.append(
          type, createStringDataTransferItem(completer.future));
    } else if (item.kind == 'file') {
      final dom.DomFile? file = item.getAsFile?.call();
      if (file != null) {
        vsDataTransfer.append(type, _createFileDataTransferItemFromFile(file));
      }
    }
  }
  return vsDataTransfer;
}

IDataTransferItem _createFileDataTransferItemFromFile(dom.DomFile file) {
  final String? path = getPathForFile(file);
  final URI? uri = (path != null && path.isNotEmpty) ? URI.parse(path) : null;
  return createFileDataTransferItem(file.name, uri, () async {
    return await file.arrayBuffer!();
  });
}

/// 1:1: `const INTERNAL_DND_MIME_TYPES = Object.freeze([...])`.
const List<String> INTERNAL_DND_MIME_TYPES = <String>[
  CodeDataTransfers.EDITORS,
  CodeDataTransfers.FILES,
  DataTransfers.RESOURCES,
  DataTransfers.INTERNAL_URI_LIST,
];

VSDataTransfer toExternalVSDataTransfer(
  dom.DomDataTransfer sourceDataTransfer, [
  bool overwriteUriList = false,
]) {
  final VSDataTransfer vsDataTransfer = toVSDataTransfer(sourceDataTransfer);

  // Try to expose the internal uri-list type as the standard type
  final IDataTransferItem? uriList =
      vsDataTransfer.get(DataTransfers.INTERNAL_URI_LIST);
  if (uriList != null) {
    vsDataTransfer.replace(Mimes.uriList, uriList);
  } else {
    if (overwriteUriList || !vsDataTransfer.has(Mimes.uriList)) {
      // Otherwise, fallback to adding dragged resources to the uri list
      final List<String> editorData = <String>[];
      // TS: `for (const item of sourceDataTransfer.items)`
      for (final dom.DomDataTransferItem? item in sourceDataTransfer.items!) {
        final dom.DomFile? file = item?.getAsFile?.call();
        if (file != null) {
          final String? path = getPathForFile(file);
          try {
            if (path != null && path.isNotEmpty) {
              editorData.add(URI.file(path).toString());
            } else {
              editorData.add(URI.parse(file.name, true).toString());
            }
          } catch (_) {
            // Parsing failed. Leave out from list
          }
        }
      }

      if (editorData.isNotEmpty) {
        vsDataTransfer.replace(
            Mimes.uriList, createStringDataTransferItem(UriList.create(editorData)));
      }
    }
  }

  for (final String internal in INTERNAL_DND_MIME_TYPES) {
    vsDataTransfer.delete(internal);
  }

  return vsDataTransfer;
}