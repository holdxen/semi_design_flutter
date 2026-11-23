// 1:1 port of vs/platform/clipboard/common/clipboardService.ts
// A declaration-only module: one decorator + one service interface.
import 'dart:typed_data' show Uint8List;

import '../../../base/common/uri.dart' show URI;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;

/// 1:1: `export const IClipboardService = createDecorator<IClipboardService>('clipboardService')`
final ServiceIdentifier<IClipboardServiceType> IClipboardService =
    createDecorator<IClipboardServiceType>('clipboardService');

/// 1:1: `export interface IClipboardService` (const keeps the bare name).
abstract class IClipboardServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  /// 1:1: `triggerPaste(targetWindowId: number): Promise<void> | undefined`
  /// TS `Promise<void> | undefined` -> `Future<void>?`.
  Future<void>? triggerPaste(int targetWindowId);

  /// 1:1: `writeText(text: string, type?: string): Promise<void>`
  Future<void> writeText(String text, [String? type]);

  /// 1:1: `readText(type?: string): Promise<string>`
  Future<String> readText([String? type]);

  /// 1:1: `readFindText(): Promise<string>`
  Future<String> readFindText();

  /// 1:1: `writeFindText(text: string): Promise<void>`
  Future<void> writeFindText(String text);

  /// 1:1: `writeResources(resources: URI[]): Promise<void>`
  Future<void> writeResources(List<URI> resources);

  /// 1:1: `readResources(): Promise<URI[]>`
  Future<List<URI>> readResources();

  /// 1:1: `hasResources(): Promise<boolean>`
  Future<bool> hasResources();

  /// 1:1: `clearInternalState?(): void` (optional method)
  void clearInternalState();

  /// 1:1: `readImage(): Promise<Uint8Array>`
  Future<Uint8List> readImage();

  /// 1:1: `writeImage(data: Uint8Array | Promise<Uint8Array>): Promise<void>`
  /// TS union -> Object? carrier (Uint8List | Future<Uint8List>).
  Future<void> writeImage(Object data);
}
