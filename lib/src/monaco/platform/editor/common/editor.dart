// 1:1 port of vscode/src/vs/platform/editor/common/editor.ts
// Type-only surfaces are carried as Dart classes; runtime guards and enums
// mirror the transpiled TypeScript exactly.
import '../../../base/common/arrays.dart' as arrays;
import '../../../base/common/event.dart' show Event;
import '../../../base/common/lifecycle.dart' show IDisposable;
import '../../../base/common/uri.dart' show URI;
import '../../contextkey/common/contextkey.dart'
    show IContextKeyServiceType;
import '../../uriIdentity/common/uriIdentity.dart'
    show IUriIdentityServiceType;
import '../../window/common/window.dart' show IRectangle;

/// 1:1: `export interface IResolvableEditorModel extends IDisposable`.
abstract class IResolvableEditorModel implements IDisposable {
  Future<void> resolve();
  bool isResolved();
}

/// 1:1: `export function isResolvedEditorModel(model)`.
bool isResolvedEditorModel(Object? model) {
  final dynamic candidate = model;
  if (candidate == null) {
    return false;
  }
  // JS `typeof candidate?.resolve` returns 'undefined' for missing members;
  // Dart throws NoSuchMethodError, so mirror the JS shape check safely.
  try {
    return candidate.resolve is Function && candidate.isResolved is Function;
  } on NoSuchMethodError {
    return false;
  }
}

/// 1:1: `export interface IBaseUntypedEditorInput`.
class IBaseUntypedEditorInput {
  IBaseUntypedEditorInput({
    this.options,
    this.label,
    this.description,
  });

  IEditorOptions? options;
  final String? label;
  final String? description;
}

/// 1:1: `export interface IBaseResourceEditorInput`.
class IBaseResourceEditorInput extends IBaseUntypedEditorInput {
  IBaseResourceEditorInput({
    super.options,
    super.label,
    super.description,
    this.forceUntitled,
  });

  final bool? forceUntitled;
}

/// 1:1: `export interface IBaseTextResourceEditorInput`.
class IBaseTextResourceEditorInput extends IBaseResourceEditorInput {
  IBaseTextResourceEditorInput({
    super.options,
    super.label,
    super.description,
    super.forceUntitled,
    this.contents,
    this.encoding,
    this.languageId,
  });

  String? contents;
  String? encoding;
  String? languageId;
}

/// 1:1: `export interface IResourceEditorInput`.
class IResourceEditorInput extends IBaseResourceEditorInput {
  IResourceEditorInput({
    super.options,
    super.label,
    super.description,
    super.forceUntitled,
    required this.resource,
  });

  final URI resource;
}

/// 1:1: `export interface ITextResourceEditorInput`.
class ITextResourceEditorInput extends IResourceEditorInput {
  ITextResourceEditorInput({
    super.options,
    super.label,
    super.description,
    super.forceUntitled,
    required super.resource,
  });
}

/// 1:1: `export interface IResourceEditorInputIdentifier`.
class IResourceEditorInputIdentifier {
  IResourceEditorInputIdentifier({
    required this.typeId,
    required this.editorId,
    required this.resource,
  });

  final String typeId;
  final String? editorId;
  final URI resource;
}

/// 1:1: `export enum EditorActivation`.
class EditorActivation {
  static const int ACTIVATE = 1;
  static const int RESTORE = 2;
  static const int PRESERVE = 3;
}

/// 1:1: `export enum EditorResolution`.
class EditorResolution {
  static const int EXCLUSIVE_ONLY = 1;
}

/// 1:1: `export enum EditorOpenSource`.
class EditorOpenSource {
  static const int API = 0;
  static const int USER = 1;
}

/// 1:1: `export enum ViewColumn`.
class ViewColumn {
  static const int Active = -1;
  static const int Beside = -2;
  static const int One = 1;
  static const int Two = 2;
  static const int Three = 3;
  static const int Four = 4;
  static const int Five = 5;
  static const int Six = 6;
  static const int Seven = 7;
  static const int Eight = 8;
  static const int Nine = 9;
}

/// 1:1: `export interface IEditorOptions`.
class IEditorOptions {
  IEditorOptions({
    this.preserveFocus,
    this.activation,
    this.forceReload,
    this.revealIfVisible,
    this.revealIfOpened,
    this.pinned,
    this.sticky,
    this.index,
    this.inactive,
    this.ignoreError,
    this.override,
    this.source,
    this.isExplicit,
    this.viewState,
    this.transient,
    this.auxiliary,
    this.modal,
  });

  bool? preserveFocus;
  int? activation;
  bool? forceReload;
  bool? revealIfVisible;
  bool? revealIfOpened;
  bool? pinned;
  bool? sticky;
  int? index;
  bool? inactive;
  bool? ignoreError;

  /// TS: `string | EditorResolution`.
  Object? override;
  int? source;
  bool? isExplicit;
  Object? viewState;
  bool? transient;
  IEditorAuxiliaryOptions? auxiliary;
  IModalEditorPartOptions? modal;
}

/// 1:1: `auxiliary` object literal inside `IEditorOptions`.
class IEditorAuxiliaryOptions {
  IEditorAuxiliaryOptions({
    this.bounds,
    this.compact,
    this.compactAllowsSplit,
    this.alwaysOnTop,
  });

  IRectangle? bounds;
  bool? compact;
  bool? compactAllowsSplit;
  bool? alwaysOnTop;
}

/// 1:1: `export interface IModalEditorPartOptions`.
class IModalEditorPartOptions {
  IModalEditorPartOptions({
    this.maximized,
    this.size,
    this.position,
    this.navigation,
    this.sidebar,
  });

  final bool? maximized;
  final Map<String, num>? size;
  final Map<String, num>? position;
  final IModalEditorNavigation? navigation;
  final IModalEditorSidebar? sidebar;
}

/// 1:1: `export interface IModalEditorOptions`.
class IModalEditorOptions {
  IModalEditorOptions({
    this.compactHeader,
    this.canMoveToEditorArea,
  });

  final bool? compactHeader;
  final bool? canMoveToEditorArea;
}

/// 1:1: `export interface IModalEditorOptionsProvider`.
abstract class IModalEditorOptionsProvider {
  IModalEditorOptions? getModalEditorOptions();
}

/// 1:1: `export function isModalEditorOptionsProvider(obj)`.
bool isModalEditorOptionsProvider(Object? obj) {
  final dynamic candidate = obj;
  if (candidate == null) {
    return false;
  }
  try {
    return candidate.getModalEditorOptions is Function;
  } on NoSuchMethodError {
    return false;
  }
}

/// 1:1: `export function canMoveModalEditorToEditorArea(obj)`.
bool canMoveModalEditorToEditorArea(Object? obj) {
  if (!isModalEditorOptionsProvider(obj)) {
    return true;
  }
  // Dart interfaces are nominal; the TS source uses duck typing.
  final dynamic candidate = obj;
  return candidate.getModalEditorOptions()?.canMoveToEditorArea != false;
}

/// 1:1: `export interface IModalEditorSidebar`.
class IModalEditorSidebar {
  IModalEditorSidebar({
    required this.render,
    this.sidebarWidth,
    this.sidebarHidden,
  });

  final num? sidebarWidth;
  final bool? sidebarHidden;
  final IDisposable Function(
    Object container,
    Event<Map<String, num>> onDidLayout,
    IContextKeyServiceType contextKeyService,
  ) render;
}

/// 1:1: `export interface IModalEditorNavigation`.
class IModalEditorNavigation {
  IModalEditorNavigation({
    required this.total,
    required this.current,
    required this.navigate,
  });

  final num total;
  final num current;
  final void Function(num index) navigate;
}

/// 1:1: `export interface ITextEditorSelection`.
class ITextEditorSelection {
  ITextEditorSelection({
    required this.startLineNumber,
    required this.startColumn,
    this.endLineNumber,
    this.endColumn,
  });

  final num startLineNumber;
  final num startColumn;
  final num? endLineNumber;
  final num? endColumn;
}

/// 1:1: `export const enum TextEditorSelectionRevealType`.
class TextEditorSelectionRevealType {
  static const int Center = 0;
  static const int CenterIfOutsideViewport = 1;
  static const int NearTop = 2;
  static const int NearTopIfOutsideViewport = 3;
}

/// 1:1: `export const enum TextEditorSelectionSource`.
class TextEditorSelectionSource {
  static const String PROGRAMMATIC = 'api';
  static const String NAVIGATION = 'code.navigation';
  static const String JUMP = 'code.jump';
}

/// 1:1: `export interface ITextEditorOptions extends IEditorOptions`.
class ITextEditorOptions extends IEditorOptions {
  ITextEditorOptions({
    super.preserveFocus,
    super.activation,
    super.forceReload,
    super.revealIfVisible,
    super.revealIfOpened,
    super.pinned,
    super.sticky,
    super.index,
    super.inactive,
    super.ignoreError,
    super.override,
    super.source,
    super.isExplicit,
    super.viewState,
    super.transient,
    super.auxiliary,
    super.modal,
    this.selection,
    this.selectionRevealType,
    this.selectionSource,
  });

  ITextEditorSelection? selection;
  int? selectionRevealType;
  Object? selectionSource;
}

/// 1:1: `export type ITextEditorChange = [...]`.
typedef ITextEditorChange = List<num>;

/// 1:1: `export interface ITextEditorDiffInformation`.
class ITextEditorDiffInformation {
  ITextEditorDiffInformation({
    required this.documentVersion,
    required this.original,
    required this.modified,
    required this.changes,
  });

  final num documentVersion;
  final URI? original;
  final URI modified;
  final List<ITextEditorChange> changes;
}

/// 1:1: `export function isTextEditorDiffInformationEqual(...)`.
bool isTextEditorDiffInformationEqual(
  IUriIdentityServiceType uriIdentityService,
  ITextEditorDiffInformation? diff1,
  ITextEditorDiffInformation? diff2,
) {
  return diff1?.documentVersion == diff2?.documentVersion &&
      uriIdentityService.extUri.isEqual(diff1?.original, diff2?.original) &&
      uriIdentityService.extUri.isEqual(diff1?.modified, diff2?.modified) &&
      arrays.equals<ITextEditorChange>(
        diff1?.changes,
        diff2?.changes,
        (ITextEditorChange a, ITextEditorChange b) =>
            a[0] == b[0] && a[1] == b[1] && a[2] == b[2] && a[3] == b[3],
      );
}
