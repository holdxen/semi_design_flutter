// 1:1 port of vscode/src/vs/platform/dnd/browser/dnd.ts
//
// Carriers: DOM DragEvent/DataTransfer/File/FileReader live in the dom.dart
// port; `parse`/`revive` in marshalling.dart; `DeferredPromise` in async.dart.
//
// Adaptations (documented inline; no algorithm or control-flow change):
//  * `extractEditorsDropData` returns `List<Object?>`: the `parse()` branch
//    spreads structural `any` values in TS (plain objects unless revived into
//    URIs), so the Dart carrier keeps those entries raw instead of forcing
//    them into the typed [IDraggedResourceEditorInput].
//  * `IFileServiceType` in this port predates `getProvider`; the one call is
//    made through `dynamic` (same convention as userDataProfile.dart).
//  * `Registry.as<T>` → `Registry.as(id)` + explicit cast.
//  * `globalThis.vscode?.webUtils?.getPathForFile` → injectable top-level
//    [globalThisVscodeGetPathForFile] slot.
//  * Module-level `Registry.add(...)` side effect → lazy final
//    [dragAndDropContributionRegistryRegistration] (port-wide convention).
//  * `link.css`-style side effects: none in this file.
import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:typed_data' show Uint8List;

import '../../../base/browser/dnd.dart' show DataTransfers;
import '../../../base/browser/dom.dart' as dom;
import '../../../base/browser/window.dart' show mainWindow;
import '../../../base/common/arrays.dart' show coalesce;
import '../../../base/common/async.dart' show DeferredPromise;
import '../../../base/common/buffer.dart' show VSBuffer;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../base/common/map.dart' show ResourceMap;
import '../../../base/common/marshalling.dart' as marshalling;
import '../../../base/common/network.dart' show Schemas;
import '../../../base/common/platform.dart' as platform;
import '../../../base/common/uri.dart' show URI, UriComponents;
import '../../../nls.dart' show localize;
import '../../dialogs/common/dialogs.dart' as dialogs;
import '../../editor/common/editor.dart' as editor;
import '../../files/browser/htmlFileSystemProvider.dart'
    show HTMLFileSystemProvider;
import '../../files/browser/webFileSystemAccess.dart'
    show WebFileSystemAccess;
import '../../files/common/files.dart' as filesPlatform;
import '../../instantiation/common/instantiation.dart' as instantiation;
import '../../opener/common/opener.dart' as opener;
import '../../registry/common/platform.dart' as registry;

//#region Editor / Resources DND

/// 1:1: `export const CodeDataTransfers`.
class CodeDataTransfers {
  static const String EDITORS = 'CodeEditors';
  static const String FILES = 'CodeFiles';
  static const String SYMBOLS = 'application/vnd.code.symbols';
  static const String MARKERS = 'application/vnd.code.diagnostics';
  static const String NOTEBOOK_CELL_OUTPUT = 'notebook-cell-output';
  static const String SCM_HISTORY_ITEM = 'scm-history-item';
  static const String CHAT_REFERENCE = 'application/vnd.code.chat-reference';

  const CodeDataTransfers._();
}

/// 1:1: `export interface IDraggedResourceEditorInput extends
/// IBaseTextResourceEditorInput`.
class IDraggedResourceEditorInput extends editor.IBaseTextResourceEditorInput {
  IDraggedResourceEditorInput({
    super.options,
    super.label,
    super.description,
    super.forceUntitled,
    super.contents,
    super.encoding,
    super.languageId,
    this.resource,
    this.isExternal,
    this.allowWorkspaceOpen,
  });

  /// A hint that the source of the dragged editor input might not be the
  /// application but some external tool.
  bool? isExternal;

  /// Whether we probe for the dropped editor to be a workspace (i.e.
  /// code-workspace file or even a folder), allowing to open it as workspace
  /// instead of opening as editor.
  bool? allowWorkspaceOpen;

  URI? resource;
}

/// TS registers the DnD contribution registry at module load; the lazy final
/// mirrors that side effect and is touched here so any consumer of
/// [extractEditorsDropData] observes the registered state.
IDragAndDropContributionRegistry get _contributionRegistry =>
    dragAndDropContributionRegistryRegistration;

List<Object?> extractEditorsDropData(dom.DomDragEvent e) {
  final List<Object?> editors = <Object?>[];
  final dom.DomDataTransfer? dataTransfer = e.dataTransfer;
  if (dataTransfer != null && dataTransfer.types.isNotEmpty) {
    // Data Transfer: Code Editors
    final String rawEditorsData = dataTransfer.getData(CodeDataTransfers.EDITORS);
    if (rawEditorsData.isNotEmpty) {
      try {
        editors.addAll(_editorsFromParsed(marshalling.parse(rawEditorsData)));
      } catch (_) {
        // Invalid transfer
      }
    }

    // Data Transfer: Resources
    else {
      try {
        final String rawResourcesData = dataTransfer.getData(DataTransfers.RESOURCES);
        editors.addAll(createDraggedEditorInputFromRawResourcesData(
            rawResourcesData.isEmpty ? null : rawResourcesData));
      } catch (_) {
        // Invalid transfer
      }
    }

    // Check for native file transfer
    final List<dom.DomFile?>? dropFiles = dataTransfer.files;
    if (dropFiles != null) {
      for (int i = 0; i < dropFiles.length; i++) {
        final dom.DomFile? file = dropFiles[i];
        // TS: `if (file && getPathForFile(file))` — an empty path string is
        // falsy, so it must not produce an editor input.
        if (file != null && _isTruthyPath(getPathForFile(file))) {
          try {
            editors.add(IDraggedResourceEditorInput(
              resource: URI.file(getPathForFile(file)!),
              isExternal: true,
              allowWorkspaceOpen: true,
            ));
          } catch (_) {
            // Invalid URI
          }
        }
      }
    }

    // Check for CodeFiles transfer
    final String rawCodeFiles = dataTransfer.getData(CodeDataTransfers.FILES);
    if (rawCodeFiles.isNotEmpty) {
      try {
        final List<dynamic> codeFiles = jsonDecode(rawCodeFiles) as List<dynamic>;
        for (final dynamic codeFile in codeFiles) {
          editors.add(IDraggedResourceEditorInput(
            resource: URI.file(codeFile as String),
            isExternal: true,
            allowWorkspaceOpen: true,
          ));
        }
      } catch (_) {
        // Invalid transfer
      }
    }

    // Workbench contributions
    final IDragAndDropContributionRegistry contributionRegistry =
        _contributionRegistry;
    for (final IDragAndDropContribution contribution
        in contributionRegistry.getAll()) {
      final String data = dataTransfer.getData(contribution.dataFormatKey);
      if (data.isNotEmpty) {
        try {
          editors.addAll(contribution.getEditorInputs(data));
        } catch (_) {
          // Invalid transfer
        }
      }
    }
  }

  // Prevent duplicates: it is possible that we end up with the same
  // dragged editor multiple times because multiple data transfers
  // are being used (https://github.com/microsoft/vscode/issues/128925)

  final List<Object?> coalescedEditors = <Object?>[];
  final ResourceMap<bool> seen = ResourceMap<bool>();
  // TS: `seen.has(editor.resource)` keys on `resource.toString()`. Entries
  // from `parse()` may carry raw payload objects instead of URIs; JS
  // stringifies those as '[object Object]', mirrored by the side map below
  // so that URI keys and raw-object keys never collide (a URI's string form
  // is never '[object Object]').
  final Map<String, bool> seenRaw = <String, bool>{};
  for (final Object? editorEntry in editors) {
    // TS reads `editor.resource` structurally; parse() entries may be plain
    // Maps, so the read goes through a Map-or-object helper.
    final Object? resource = editorEntry is Map
        ? editorEntry['resource']
        : (editorEntry as dynamic).resource;
    if (resource == null) {
      coalescedEditors.add(editorEntry);
    } else if (resource is URI) {
      if (!seen.has(resource)) {
        coalescedEditors.add(editorEntry);
        seen.set(resource, true);
      }
    } else if (!seenRaw.containsKey(_rawResourceKey(resource))) {
      coalescedEditors.add(editorEntry);
      seenRaw[_rawResourceKey(resource)] = true;
    }
  }

  return coalescedEditors;
}

/// TS `getPathForFile(file)` is consumed through JS truthiness; `''` is falsy.
bool _isTruthyPath(String? path) => path != null && path.isNotEmpty;

/// JS `String(obj)` for non-URI resources in the dedup step.
String _rawResourceKey(Object resource) =>
    resource is Map ? '[object Object]' : resource.toString();

/// TS spreads the `any[]` result of `parse()` into the editors array; entries
/// are plain objects (URIs revived by `marshalling.parse` where `$mid` says
/// so). The Dart carrier keeps them raw, matching the structural pass-through.
List<Object?> _editorsFromParsed(dynamic parsed) {
  final List<Object?> result = <Object?>[];
  if (parsed is List) {
    for (final dynamic entry in parsed) {
      result.add(entry);
    }
  }
  return result;
}

Future<List<Object?>> extractEditorsAndFilesDropData(
  instantiation.ServicesAccessor accessor,
  dom.DomDragEvent e,
) async {
  final List<Object?> editors = extractEditorsDropData(e);

  // Web: Check for file transfer
  if (e.dataTransfer != null &&
      platform.isWeb &&
      containsDragType(e, <String>[DataTransfers.FILES])) {
    final List<dom.DomDataTransferItem?>? files = e.dataTransfer!.items;
    if (files != null) {
      final instantiation.IInstantiationServiceType instantiationService =
          accessor.get(instantiation.IInstantiationService)
              as instantiation.IInstantiationServiceType;
      // TS: `await instantiationService.invokeFunction(accessor =>
      // extractFilesDropData(accessor, e))` — the dynamic `invokeFunction`
      // carrier returns `Object?`, awaited through `FutureOr` semantics.
      // TS: `await instantiationService.invokeFunction(accessor =>
      // extractFilesDropData(accessor, e))` — `await` accepts any value there;
      // the dynamic cast keeps that semantics for the Dart carrier.
      final Object? invoked =
          await (instantiationService.invokeFunction(
              (instantiation.ServicesAccessor innerAccessor) =>
                  extractFilesDropData(innerAccessor, e), <Object?>[]) as dynamic);
      final List<IFileTransferData> filesData =
          (invoked as List<dynamic>).cast<IFileTransferData>();
      for (final IFileTransferData fileData in filesData) {
        editors.add(IDraggedResourceEditorInput(
          resource: fileData.resource,
          contents: fileData.contents?.toString(),
          isExternal: true,
          allowWorkspaceOpen: fileData.isDirectory,
        ));
      }
    }
  }

  return editors;
}

List<Object?> createDraggedEditorInputFromRawResourcesData(
    String? rawResourcesData) {
  final List<Object?> editors = <Object?>[];

  if (rawResourcesData != null && rawResourcesData.isNotEmpty) {
    final List<dynamic> resourcesRaw = jsonDecode(rawResourcesData) as List<dynamic>;
    for (final dynamic resourceRaw in resourcesRaw) {
      if ((resourceRaw as String).indexOf(':') > 0) {
        // mitigate https://github.com/microsoft/vscode/issues/124946
        final opener.ExtractSelectionResult result =
            opener.extractSelection(URI.parse(resourceRaw));
        editors.add(IDraggedResourceEditorInput(
          resource: result.uri,
          options: editor.ITextEditorOptions(selection: result.selection),
        ));
      }
    }
  }

  return editors;
}

/// 1:1: `interface IFileTransferData` (module-private in TS; public here
/// because the exported `extractFileListData` returns it).
class IFileTransferData {
  IFileTransferData({required this.resource, this.isDirectory, this.contents});

  final URI resource;
  final bool? isDirectory;
  final VSBuffer? contents;
}

/// JS `event.target?.result` — the event carrier may be a Map (test
/// payloads) or an object.
Object? _eventTargetResult(Object event) {
  final dynamic target =
      event is Map ? event['target'] : (event as dynamic).target;
  if (target == null) {
    return null;
  }
  return target is Map ? target['result'] : (target as dynamic).result;
}

Future<List<IFileTransferData>> extractFilesDropData(
  instantiation.ServicesAccessor accessor,
  dom.DomDragEvent event,
) async {
  // Try to extract via `FileSystemHandle`
  if (WebFileSystemAccess.supported(mainWindow)) {
    final List<dom.DomDataTransferItem?>? items = event.dataTransfer?.items;
    if (items != null) {
      return extractFileTransferData(accessor, items);
    }
  }

  // Try to extract via `FileList`
  final List<dom.DomFile?>? files = event.dataTransfer?.files;
  if (files == null) {
    return <IFileTransferData>[];
  }

  return extractFileListData(accessor, files);
}

Future<List<IFileTransferData>> extractFileTransferData(
  instantiation.ServicesAccessor accessor,
  List<dom.DomDataTransferItem?> items,
) async {
  // TS: `accessor.get(IFileService).getProvider(Schemas.file)` — `getProvider`
  // is absent from this port's `IFileServiceType` (pre-existing scope), so the
  // call goes through `dynamic` per the established convention.
  final dynamic fileSystemProvider =
      (accessor.get(filesPlatform.IFileService) as dynamic).getProvider(Schemas.file);
  if (fileSystemProvider is! HTMLFileSystemProvider) {
    return <IFileTransferData>[]; // only supported when running in web
  }

  final List<DeferredPromise<IFileTransferData?>> results =
      <DeferredPromise<IFileTransferData?>>[];

  for (int i = 0; i < items.length; i++) {
    final dom.DomDataTransferItem? file = items[i];
    if (file != null) {
      final DeferredPromise<IFileTransferData?> result =
          DeferredPromise<IFileTransferData?>();
      results.add(result);

      (() async {
        try {
          // TS: `await file.getAsFileSystemHandle()` — a missing method
          // throws and is swallowed by the catch below, same as the
          // null-assertion error here.
          final Object? handle = await file.getAsFileSystemHandle!();
          if (handle == null) {
            await result.complete(null);
            return;
          }

          if (WebFileSystemAccess.isFileSystemFileHandle(handle)) {
            await result.complete(IFileTransferData(
              resource:
                  await (fileSystemProvider as dynamic).registerFileHandle(handle),
              isDirectory: false,
            ));
          } else if (WebFileSystemAccess.isFileSystemDirectoryHandle(handle)) {
            await result.complete(IFileTransferData(
              resource: await (fileSystemProvider as dynamic)
                  .registerDirectoryHandle(handle),
              isDirectory: true,
            ));
          } else {
            await result.complete(null);
          }
        } catch (_) {
          await result.complete(null);
        }
      })();
    }
  }

  return coalesce(await Future.wait(results.map((DeferredPromise<IFileTransferData?> result) => result.p)));
}

Future<List<IFileTransferData>> extractFileListData(
  instantiation.ServicesAccessor accessor,
  List<dom.DomFile?> files,
) async {
  final dialogs.IDialogServiceType dialogService =
      accessor.get(dialogs.IDialogService) as dialogs.IDialogServiceType;

  final List<DeferredPromise<IFileTransferData?>> results =
      <DeferredPromise<IFileTransferData?>>[];

  for (int i = 0; i < files.length; i++) {
    final dom.DomFile? file = files[i];
    if (file != null) {
      // Skip for very large files because this operation is unbuffered
      if (file.size > 100 * filesPlatform.ByteSize.MB) {
        dialogService.warn(localize('fileTooLarge',
            'File is too large to open as untitled editor. Please upload it first into the file explorer and then try again.'));
        continue;
      }

      final DeferredPromise<IFileTransferData?> result =
          DeferredPromise<IFileTransferData?>();
      results.add(result);

      final dom.FileReader reader = dom.FileReader();

      reader.onerror = (Object event) {
        result.complete(null);
      };
      reader.onabort = (Object event) {
        result.complete(null);
      };

      reader.onload = (Object event) async {
        final String name = file.name;
        final Object? loadResult = _eventTargetResult(event);
        if (loadResult == null) {
          result.complete(null);
          return;
        }

        await result.complete(IFileTransferData(
          resource: URI.from(UriComponents(
            scheme: Schemas.untitled,
            path: name,
          )),
          contents: loadResult is String
              ? VSBuffer.fromString(loadResult)
              : VSBuffer.wrap(Uint8List.fromList((loadResult as List<dynamic>).cast<int>())),
        ));
      };

      // Start reading
      reader.readAsArrayBuffer(file);
    }
  }

  return coalesce(
      await Future.wait(results.map((DeferredPromise<IFileTransferData?> result) => result.p)));
}

//#endregion

bool containsDragType(dom.DomDragEvent event, List<String> dragTypesToFind) {
  if (event.dataTransfer == null) {
    return false;
  }

  final List<String> dragTypes = event.dataTransfer!.types;
  final List<String> lowercaseDragTypes = <String>[];
  for (int i = 0; i < dragTypes.length; i++) {
    lowercaseDragTypes
        .add(dragTypes[i].toLowerCase()); // somehow the types are lowercase
  }

  for (final String dragType in dragTypesToFind) {
    if (lowercaseDragTypes.indexOf(dragType.toLowerCase()) >= 0) {
      return true;
    }
  }

  return false;
}

//#region DND contributions

/// 1:1: `export interface IResourceStat`.
class IResourceStat {
  IResourceStat({required this.resource, this.isDirectory, this.selection});

  final URI resource;
  final bool? isDirectory;
  final editor.ITextEditorSelection? selection;
}

/// 1:1: `export interface IResourceDropHandler`.
abstract class IResourceDropHandler {
  /// Handle a dropped resource.
  /// @param resource The resource that was dropped
  /// @param accessor Service accessor to get services
  /// @returns true if handled, false otherwise
  Future<bool> handleDrop(
    URI resource,
    instantiation.ServicesAccessor accessor,
  );
}

/// 1:1: `export interface IDragAndDropContributionRegistry`.
abstract class IDragAndDropContributionRegistry {
  /// Registers a drag and drop contribution.
  void register(IDragAndDropContribution contribution);

  /// Returns all registered drag and drop contributions.
  Iterable<IDragAndDropContribution> getAll();

  /// Register a handler for dropped resources.
  /// @returns A disposable that unregisters the handler when disposed
  lifecycle.IDisposable registerDropHandler(IResourceDropHandler handler);

  /// Handle a dropped resource using registered handlers.
  /// @param resource The resource that was dropped
  /// @param accessor Service accessor to get services
  /// @returns true if any handler handled the resource, false otherwise
  Future<bool> handleResourceDrop(
    URI resource,
    instantiation.ServicesAccessor accessor,
  );
}

/// TS: module-private `interface IDragAndDropContribution`. Public in Dart
/// because `getAll()` exposes it through the public registry interface.
abstract class IDragAndDropContribution {
  final String dataFormatKey;
  const IDragAndDropContribution(this.dataFormatKey);

  List<Object?> getEditorInputs(String data);
  void setData(List<IResourceStat> resources, Object event);
}

/// TS: module-private `class DragAndDropContributionRegistry`. Public in Dart
/// because the module-level registration stores it in the public [registry].
class DragAndDropContributionRegistry implements IDragAndDropContributionRegistry {
  final Map<String, IDragAndDropContribution> _contributions =
      <String, IDragAndDropContribution>{};
  final Set<IResourceDropHandler> _dropHandlers = <IResourceDropHandler>{};

  @override
  void register(IDragAndDropContribution contribution) {
    if (_contributions.containsKey(contribution.dataFormatKey)) {
      // Typo 'contributiont' preserved from the source message.
      throw StateError(
          "A drag and drop contributiont with key '${contribution.dataFormatKey}' was already registered.");
    }
    _contributions[contribution.dataFormatKey] = contribution;
  }

  @override
  Iterable<IDragAndDropContribution> getAll() => _contributions.values;

  @override
  lifecycle.IDisposable registerDropHandler(IResourceDropHandler handler) {
    _dropHandlers.add(handler);
    return lifecycle.toDisposable(() => _dropHandlers.remove(handler));
  }

  @override
  Future<bool> handleResourceDrop(
    URI resource,
    instantiation.ServicesAccessor accessor,
  ) async {
    for (final IResourceDropHandler handler in _dropHandlers) {
      if (await handler.handleDrop(resource, accessor)) {
        return true;
      }
    }
    return false;
  }
}

/// 1:1: `export const Extensions`.
class Extensions {
  static const String DragAndDropContribution =
      'workbench.contributions.dragAndDrop';

  const Extensions._();
}

/// 1:1: module-level
/// `Registry.add(Extensions.DragAndDropContribution, new DragAndDropContributionRegistry());`
/// side effect (lazy final per the port-wide convention).
final DragAndDropContributionRegistry dragAndDropContributionRegistryRegistration =
    _registerDragAndDropContribution();

DragAndDropContributionRegistry _registerDragAndDropContribution() {
  final DragAndDropContributionRegistry contribution =
      DragAndDropContributionRegistry();
  registry.Registry.add(Extensions.DragAndDropContribution, contribution);
  return contribution;
}

//#endregion

//#region DND Utilities

/// A singleton to store transfer data during drag & drop operations that are
/// only valid within the application.
///
/// 1:1: `export class LocalSelectionTransfer<T>`.
class LocalSelectionTransfer<T> {
  /// TS: `private static readonly INSTANCE = new LocalSelectionTransfer();`
  /// Dart's reified generics reject casting a `dynamic`-typed instance to
  /// `LocalSelectionTransfer<T>`, so the singleton is typed with the bottom
  /// type (a subtype of every `LocalSelectionTransfer<T>`); the fields carry
  /// no `T` for the same reason.
  static final LocalSelectionTransfer<Never> _INSTANCE =
      LocalSelectionTransfer<Never>._();

  List<Object?>? _data;
  Object? _proto;

  LocalSelectionTransfer._() {
    // protect against external instantiation
  }

  static LocalSelectionTransfer<T> getInstance<T>() =>
      _INSTANCE as LocalSelectionTransfer<T>;

  // The methods take `Object?` (not `T?`) because the singleton instance is
  // `LocalSelectionTransfer<Never>`: `Never`-typed parameters would reject
  // every runtime argument. Only the [getData] return keeps `T`, cast lazily.
  /// TS: `return proto && proto === this.proto;` — a falsy proto yields the
  /// proto itself (falsey), projected here as `false`.
  bool hasData(Object? proto) {
    if (proto == null) {
      return false;
    }
    return identical(proto, _proto);
  }

  void clearData(Object? proto) {
    if (hasData(proto)) {
      _proto = null;
      _data = null;
    }
  }

  /// TS: `T[] | undefined`. TS generics are erased at runtime — the shared
  /// singleton returns whatever was set, for any `T`. Dart's reified
  /// generics would make a lazy `cast<T>()` on the bottom-typed singleton
  /// explode on iteration, so the raw list is returned (same erasure).
  List<Object?>? getData(Object? proto) {
    if (hasData(proto)) {
      return _data;
    }

    return null;
  }

  void setData(List<Object?>? data, Object? proto) {
    if (proto != null) {
      _data = data;
      _proto = proto;
    }
  }
}

/// 1:1: `export interface DocumentSymbolTransferData`.
class DocumentSymbolTransferData {
  DocumentSymbolTransferData({
    required this.name,
    required this.fsPath,
    required this.range,
    required this.kind,
  });

  final String name;
  final String fsPath;
  final DocumentSymbolRange range;
  final int kind;

  Map<String, Object?> toJson() => <String, Object?>{
        'name': name,
        'fsPath': fsPath,
        'range': range.toJson(),
        'kind': kind,
      };
}

/// 1:1: the inline `range` shape of `DocumentSymbolTransferData`.
class DocumentSymbolRange {
  DocumentSymbolRange({
    required this.startLineNumber,
    required this.startColumn,
    required this.endLineNumber,
    required this.endColumn,
  });

  final int startLineNumber;
  final int startColumn;
  final int endLineNumber;
  final int endColumn;

  Map<String, Object?> toJson() => <String, Object?>{
        'startLineNumber': startLineNumber,
        'startColumn': startColumn,
        'endLineNumber': endLineNumber,
        'endColumn': endColumn,
      };
}

/// 1:1: `export interface NotebookCellOutputTransferData`.
class NotebookCellOutputTransferData {
  NotebookCellOutputTransferData({required this.outputId});

  final String outputId;

  Map<String, Object?> toJson() => <String, Object?>{'outputId': outputId};
}

void _setDataAsJSON(dom.DomDragEvent e, String kind, Object? data) {
  e.dataTransfer?.setData(kind, jsonEncode(_jsonValue(data)));
}

/// JS `JSON.stringify` of plain payloads; typed carriers are projected to
/// their JSON shape first.
Object? _jsonValue(Object? value) {
  if (value is DocumentSymbolTransferData ||
      value is NotebookCellOutputTransferData ||
      value is ChatReferenceTransferData) {
    return (value as dynamic).toJson();
  }
  if (value is List) {
    return value.map(_jsonValue).toList();
  }
  return value;
}

T _getDataAsJSON<T>(dom.DomDragEvent e, String kind, T defaultValue) {
  final String? rawSymbolsData = e.dataTransfer?.getData(kind);
  if (rawSymbolsData != null && rawSymbolsData.isNotEmpty) {
    try {
      return jsonDecode(rawSymbolsData) as T;
    } catch (_) {
      // Invalid transfer
    }
  }

  return defaultValue;
}

List<Object?> extractSymbolDropData(dom.DomDragEvent e) {
  return _getDataAsJSON<List<Object?>>(e, CodeDataTransfers.SYMBOLS, <Object?>[]);
}

void fillInSymbolsDragData(List<DocumentSymbolTransferData> symbolsData, dom.DomDragEvent e) {
  _setDataAsJSON(e, CodeDataTransfers.SYMBOLS, symbolsData);
}

/// TS: `export type MarkerTransferData = IMarker | { uri: UriComponents }` —
/// `IMarker` has no materialized carrier in this port, so the union stays an
/// opaque `Object?` (JSON in / JSON out).
typedef MarkerTransferData = Object?;

Object? extractMarkerDropData(dom.DomDragEvent e) {
  return _getDataAsJSON<Object?>(e, CodeDataTransfers.MARKERS, null);
}

void fillInMarkersDragData(List<MarkerTransferData> markerData, dom.DomDragEvent e) {
  _setDataAsJSON(e, CodeDataTransfers.MARKERS, markerData);
}

Object? extractNotebookCellOutputDropData(dom.DomDragEvent e) {
  return _getDataAsJSON<Object?>(
      e, CodeDataTransfers.NOTEBOOK_CELL_OUTPUT, null);
}

/// Payload for a dragged chat reference (a chat tab or a session from the
/// Agents window). The producing (sessions) layer supplies both the opaque
/// backend chat resource — the value the reference entry carries verbatim —
/// and the client-side chat resource, plus the display title. The consuming
/// (workbench chat input) drop handler needs no knowledge of sessions or
/// agent-host types: it forwards [chatResource] into the reference entry and
/// compares [clientResource] for identity only (self-reference /
/// cross-agent-host detection). The payload is transient (never persisted),
/// so carrying both resources is fine.
///
/// 1:1: `export interface ChatReferenceTransferData`.
class ChatReferenceTransferData {
  ChatReferenceTransferData({
    required this.chatResource,
    required this.clientResource,
    required this.title,
  });

  /// The referenced chat's **opaque backend chat URI** (the value carried on
  /// `MessageChatAttachment.resource`). Becomes the reference entry's value
  /// verbatim; never parsed by the consuming layer.
  final String chatResource;

  /// The sessions-window client chat resource (`IChat.resource`). Used for
  /// compare-by-equality identity only — e.g. to detect a chat dropped onto
  /// its own input, or to reject a cross-agent-host drag (which needs the
  /// client scheme + authority the backend URI does not carry) — never parsed
  /// for meaning.
  final String clientResource;

  /// The reference's display title, used for the inline `#chat:<title>` token.
  final String title;

  Map<String, Object?> toJson() => <String, Object?>{
        'chatResource': chatResource,
        'clientResource': clientResource,
        'title': title,
      };
}

/// The chat reference of the drag in progress in this window. Unlike the
/// [ChatReferenceTransferData] `dataTransfer` payload, it is readable during
/// `dragover`, so that a drop target can decide whether it takes the
/// reference, such as suppress its overlay for a self-reference or a
/// cross-agent-host drag, before the drop lands. It is kept apart from
/// [LocalSelectionTransfer], which holds one payload at a time, so that the
/// drag can also carry what the chat stands for there, such as a dragged
/// session to open.
ChatReferenceTransferData? _draggedChatReference;

/// The chat reference a drag carries: from its `dataTransfer` payload, where
/// readable (on `drop`), else, such as during `dragover`, from the drag in
/// progress in this window.
ChatReferenceTransferData? extractChatReferenceDropData(dom.DomDragEvent e) {
  if (!containsDragType(e, <String>[CodeDataTransfers.CHAT_REFERENCE])) {
    return null;
  }
  return _getDataAsJSON<ChatReferenceTransferData?>(
          e, CodeDataTransfers.CHAT_REFERENCE, null) ??
      _draggedChatReference;
}

/// Attaches a chat reference to a drag; pair it with
/// [clearChatReferenceDragData] on `dragend`.
void fillInChatReferenceDragData(ChatReferenceTransferData data, dom.DomDragEvent e) {
  _setDataAsJSON(e, CodeDataTransfers.CHAT_REFERENCE, data);
  _draggedChatReference = data;
}

/// Clears the chat reference of the drag in progress, so that it does not
/// leak into a later, unrelated drag.
void clearChatReferenceDragData() {
  _draggedChatReference = null;
}

/// 1:1: `globalThis.vscode?.webUtils?.getPathForFile` — injectable seam for
/// Electron's `webUtils.getPathForFile`.
String? Function(Object file)? globalThisVscodeGetPathForFile;

/// A helper to get access to Electrons `webUtils.getPathForFile` function
/// in a safe way without crashing the application when running in the web.
String? getPathForFile(Object file) {
  if (platform.isNative && globalThisVscodeGetPathForFile != null) {
    return globalThisVscodeGetPathForFile!(file);
  }

  return null;
}

//#endregion