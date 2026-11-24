// 1:1 port of vs/platform/opener/common/opener.ts
import '../../../base/common/cancellation.dart' show CancellationToken;
import '../../../base/common/lifecycle.dart' show IDisposable;
import '../../../base/common/uri.dart' show URI, UriChange;
import '../../editor/common/editor.dart' show IEditorOptions, ITextEditorSelection;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;

/// 1:1: `export const IOpenerService = createDecorator<IOpenerService>('openerService')`.
final ServiceIdentifier<IOpenerServiceType> IOpenerService =
    createDecorator<IOpenerServiceType>('openerService');

/// 1:1: `export const defaultExternalUriOpenerId = 'default'`.
const String defaultExternalUriOpenerId = 'default';

/// 1:1: `export type OpenInternalOptions`.
class OpenInternalOptions {
  OpenInternalOptions({
    this.openToSide,
    this.editorOptions,
    this.fromUserGesture,
    this.allowCommands,
  });

  /// Signals opening to the side of the currently active editor.
  final bool? openToSide;

  /// Extra editor options to apply in case an editor is used to open.
  final IEditorOptions? editorOptions;

  /// Whether the open was triggered by a user gesture.
  final bool? fromUserGesture;

  /// TS: `boolean | readonly string[]`.
  final Object? allowCommands;
}

/// 1:1: `export type OpenExternalOptions`.
class OpenExternalOptions {
  OpenExternalOptions({
    this.openExternal,
    this.allowTunneling,
    this.allowContributedOpeners,
    this.fromWorkspace,
    this.skipValidation,
    this.sourceWindowId,
  });

  final bool? openExternal;
  final bool? allowTunneling;

  /// TS: `boolean | string`.
  final Object? allowContributedOpeners;
  final bool? fromWorkspace;
  final bool? skipValidation;
  final num? sourceWindowId;
}

/// 1:1: `export type OpenOptions = OpenInternalOptions & OpenExternalOptions`.
class OpenOptions {
  OpenOptions({
    this.openToSide,
    this.editorOptions,
    this.fromUserGesture,
    this.allowCommands,
    this.openExternal,
    this.allowTunneling,
    this.allowContributedOpeners,
    this.fromWorkspace,
    this.skipValidation,
    this.sourceWindowId,
  });

  final bool? openToSide;
  final IEditorOptions? editorOptions;
  final bool? fromUserGesture;
  final Object? allowCommands;
  final bool? openExternal;
  final bool? allowTunneling;
  final Object? allowContributedOpeners;
  final bool? fromWorkspace;
  final bool? skipValidation;
  final num? sourceWindowId;
}

/// 1:1: `export type ResolveExternalUriOptions`.
class ResolveExternalUriOptions {
  ResolveExternalUriOptions({this.allowTunneling});

  final bool? allowTunneling;
}

/// 1:1: `export interface IResolvedExternalUri extends IDisposable`.
abstract class IResolvedExternalUri implements IDisposable {
  URI get resolved;
}

/// 1:1: `export interface IOpener`.
abstract class IOpener {
  Future<bool> open(Object resource, [Object? options]);
}

/// 1:1: `export interface IExternalUriOpenContext`.
class IExternalUriOpenContext {
  IExternalUriOpenContext({
    required this.sourceUri,
    required this.sourceHref,
    this.viewColumn,
    this.sourceWindowId,
  });

  final URI sourceUri;
  final String sourceHref;
  final int? viewColumn;
  final num? sourceWindowId;
}

/// 1:1: `export interface IExternalOpener`.
abstract class IExternalOpener {
  Future<bool> openExternal(
    String href,
    Object contextWithPreferredOpenerId,
    CancellationToken token,
  );

  void dispose();
}

/// 1:1: `export interface IValidator`.
abstract class IValidator {
  Future<bool> shouldOpen(Object resource, [Object? openOptions]);
}

/// 1:1: `export interface IExternalUriResolver`.
abstract class IExternalUriResolver {
  Future<IResolvedExternalUri?> resolveExternalUri(URI resource,
      [Object? options]);
}

/// 1:1: `export interface IOpenerService` (const keeps the bare name).
abstract class IOpenerServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  IDisposable registerOpener(IOpener opener);

  IDisposable registerValidator(IValidator validator);

  IDisposable registerExternalUriResolver(IExternalUriResolver resolver);

  void setDefaultExternalOpener(IExternalOpener opener);

  IDisposable registerExternalOpener(IExternalOpener opener);

  Future<bool> open(Object resource, [Object? options]);

  Future<IResolvedExternalUri> resolveExternalUri(
    URI resource, [
    ResolveExternalUriOptions? options,
  ]);
}

/// 1:1: result of `export function extractSelection`.
class ExtractSelectionResult {
  ExtractSelectionResult({required this.selection, required this.uri});

  final ITextEditorSelection? selection;
  final URI uri;
}

final RegExp _selectionPattern =
    RegExp(r'^L?(\d+)(?:,(\d+))?(-L?(\d+)(?:,(\d+))?)?');

/// 1:1: `export function withSelection(uri, selection)`.
URI withSelection(URI uri, ITextEditorSelection selection) {
  // JS truthiness: 0 is falsy, so a zero endLineNumber/endColumn is omitted.
  final bool hasEndLine = selection.endLineNumber != null &&
      selection.endLineNumber != 0;
  final bool hasEndColumn =
      selection.endColumn != null && selection.endColumn != 0;
  final String end = hasEndLine
      ? '-${selection.endLineNumber}${hasEndColumn ? ',${selection.endColumn}' : ''}'
      : '';
  final String fragment =
      '${selection.startLineNumber},${selection.startColumn}$end';
  return uri.withChanges(UriChange(fragment: fragment));
}

/// 1:1: `export function extractSelection(uri)`.
ExtractSelectionResult extractSelection(URI uri) {
  ITextEditorSelection? selection;
  final RegExpMatch? match = _selectionPattern.firstMatch(uri.fragment);
  if (match != null) {
    selection = ITextEditorSelection(
      startLineNumber: int.parse(match.group(1)!),
      startColumn: match.group(2) != null ? int.parse(match.group(2)!) : 1,
      endLineNumber: match.group(4) != null ? int.parse(match.group(4)!) : null,
      endColumn: match.group(4) != null
          ? (match.group(5) != null ? int.parse(match.group(5)!) : 1)
          : null,
    );
    uri = uri.withChanges(UriChange(fragment: ''));
  }
  return ExtractSelectionResult(selection: selection, uri: uri);
}
