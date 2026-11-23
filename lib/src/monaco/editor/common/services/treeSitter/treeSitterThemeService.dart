// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/services/treeSitter/treeSitterThemeService.ts
// Translated 1:1 from TypeScript. The value/type namespace clash
// (`ITreeSitterThemeService` const + interface) is resolved by keeping the
// const name and renaming the interface to `ITreeSitterThemeServiceType`
// (same convention as IContextKeyService / IAccessibilityService).
// ---------------------------------------------------------------------------

import '../../../../base/common/observable.dart' show IObservable, IReader;
import '../../../../platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;

/// 1:1: `export const ITreeSitterThemeService = createDecorator<ITreeSitterThemeService>('treeSitterThemeService')`
final ServiceIdentifier<ITreeSitterThemeServiceType> ITreeSitterThemeService =
    createDecorator<ITreeSitterThemeServiceType>('treeSitterThemeService');

/// 1:1: `export interface ITreeSitterThemeService`
abstract class ITreeSitterThemeServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  IObservable<void> get onChange;

  /// 1:1: `findMetadata(captureNames: string[], languageId: number, bracket: boolean, reader: IReader | undefined): number`
  int findMetadata(List<String> captureNames, int languageId, bool bracket,
      IReader? reader);
}
