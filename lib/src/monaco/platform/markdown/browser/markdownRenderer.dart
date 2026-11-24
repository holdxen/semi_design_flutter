// 1:1 port of vs/platform/markdown/browser/markdownRenderer.ts
import '../../../base/browser/dom.dart' as dom;
import '../../../base/browser/markdownRenderer.dart'
    show
        MarkdownActionHandler,
        MarkdownRenderOptions,
        RenderedMarkdown,
        renderMarkdown;
import '../../../base/common/errors.dart' as errors;
import '../../../base/common/htmlContent.dart' show MarkdownStringTrustedOptions;
import '../../instantiation/common/extensions.dart'
    show InstantiationType, registerSingleton;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;

/// 1:1: seam for `renderMarkdown` so host/DOM can be replayed in tests.
RenderedMarkdown Function(
  Object markdown, [
  MarkdownRenderOptions? options,
  Object? target,
]) markdownRendererRenderMarkdown = renderMarkdown;

/// 1:1: seam for `onUnexpectedError`.
Object? Function(Object? error) markdownRendererOnUnexpectedError =
    errors.onUnexpectedError;

/// 1:1: seam for `document.createElement`.
Object Function(String tag) markdownRendererCreateElement =
    (String tag) => dom.document.createElement(tag);

/// 1:1: `export interface IMarkdownRenderer`.
abstract class IMarkdownRenderer {
  RenderedMarkdown render(
    Object markdown, [
    Object? options,
    Object? outElement,
  ]);
}

/// 1:1: `export interface IMarkdownRendererExtraOptions`.
class IMarkdownRendererExtraOptions {
  IMarkdownRendererExtraOptions({this.context});

  final Object? context;
}

/// 1:1: intersection `MarkdownRenderOptions & IMarkdownRendererExtraOptions`.
class MarkdownRendererRenderOptions extends MarkdownRenderOptions {
  MarkdownRendererRenderOptions({
    super.codeBlockRenderer,
    super.codeBlockRendererSync,
    super.asyncRenderCallback,
    super.actionHandler,
    super.transformUri,
    super.fillInIncompleteTokens,
    super.sanitizerConfig,
    super.markedOptions,
    super.markedExtensions,
    this.context,
  });

  final Object? context;
}

/// 1:1: `export interface IMarkdownCodeBlockRenderer`.
abstract class IMarkdownCodeBlockRenderer {
  Future<Object> renderCodeBlock(
    String? languageAlias,
    String value,
    Object options,
  );
}

/// 1:1: `export const IMarkdownRendererService`.
final ServiceIdentifier<IMarkdownRendererServiceType> IMarkdownRendererService =
    createDecorator<IMarkdownRendererServiceType>('markdownRendererService');

/// 1:1: `export interface IMarkdownRendererService` (const keeps bare name).
abstract class IMarkdownRendererServiceType {
  RenderedMarkdown render(
    Object markdown, [
    MarkdownRendererRenderOptions? options,
    Object? outElement,
  ]);

  void setDefaultCodeBlockRenderer(IMarkdownCodeBlockRenderer renderer);
}

/// 1:1: `export class MarkdownRendererService`.
class MarkdownRendererService {
  MarkdownRendererService(this._openerService);

  final Object _openerService;
  IMarkdownCodeBlockRenderer? _defaultCodeBlockRenderer;

  /// 1:1: `render(markdown, options?, outElement?)`.
  RenderedMarkdown render(
    Object markdown, [
    MarkdownRendererRenderOptions? options,
    Object? outElement,
  ]) {
    late final MarkdownRendererRenderOptions resolvedOptions;

    final MarkdownActionHandler? actionHandler =
        options?.actionHandler ??
        (String link, Object mdStr) {
          final dynamic string = mdStr;
          openLinkFromMarkdown(_openerService, link, string.isTrusted);
        };

    final Future<Object> Function(String, String)? codeBlockRenderer =
        options?.codeBlockRenderer ??
        (String alias, String value) async {
          final IMarkdownCodeBlockRenderer? renderer =
              _defaultCodeBlockRenderer;
          if (renderer != null) {
            return renderer.renderCodeBlock(alias, value, resolvedOptions);
          }
          return markdownRendererCreateElement('span');
        };

    resolvedOptions = _copyOptions(
      options,
      actionHandler: actionHandler,
      codeBlockRenderer: codeBlockRenderer,
    );

    final RenderedMarkdown rendered = markdownRendererRenderMarkdown(
      markdown,
      resolvedOptions,
      outElement,
    );
    (rendered.element as dynamic).classList.add('rendered-markdown');
    return rendered;
  }

  /// 1:1: `setDefaultCodeBlockRenderer(renderer)`.
  void setDefaultCodeBlockRenderer(IMarkdownCodeBlockRenderer renderer) {
    _defaultCodeBlockRenderer = renderer;
  }
}

/// 1:1: `export async function openLinkFromMarkdown(...)`.
Future<bool> openLinkFromMarkdown(
  Object openerService,
  String link,
  Object? isTrusted, [
  bool? skipValidation,
]) async {
  try {
    final dynamic opener = openerService;
    final Object? result = await opener.open(link, <String, Object?>{
      'fromUserGesture': true,
      'allowContributedOpeners': true,
      'allowCommands': _toAllowCommandsOption(isTrusted),
      'skipValidation': skipValidation,
    });
    return result == true;
  } catch (e) {
    markdownRendererOnUnexpectedError(e);
    return false;
  }
}

/// 1:1: `function toAllowCommandsOption(isTrusted)`.
Object _toAllowCommandsOption(Object? isTrusted) {
  if (isTrusted == true) return true;
  if (isTrusted is MarkdownStringTrustedOptions) {
    return isTrusted.enabledCommands;
  }
  return false;
}

/// 1:1: JS `{ ...options }` spread.
MarkdownRendererRenderOptions _copyOptions(
  MarkdownRenderOptions? options, {
  MarkdownActionHandler? actionHandler,
  Future<Object> Function(String, String)? codeBlockRenderer,
}) {
  if (options == null) {
    return MarkdownRendererRenderOptions(
      actionHandler: actionHandler,
      codeBlockRenderer: codeBlockRenderer,
    );
  }
  return MarkdownRendererRenderOptions(
    codeBlockRenderer: codeBlockRenderer ?? options.codeBlockRenderer,
    codeBlockRendererSync: options.codeBlockRendererSync,
    asyncRenderCallback: options.asyncRenderCallback,
    actionHandler: actionHandler ?? options.actionHandler,
    transformUri: options.transformUri,
    fillInIncompleteTokens: options.fillInIncompleteTokens,
    sanitizerConfig: options.sanitizerConfig,
    markedOptions: options.markedOptions,
    markedExtensions: options.markedExtensions,
    context: options is MarkdownRendererRenderOptions ? options.context : null,
  );
}

/// 1:1 top-level side effect: module-load `registerSingleton(...)`.
/// Dart has no top-level statements, so a lazily initialized final reproduces
/// it on first library access (same convention as other service ports).
final ServiceIdentifier<IMarkdownRendererServiceType> registration = () {
  registerSingleton<IMarkdownRendererServiceType>(
    IMarkdownRendererService,
    MarkdownRendererService.new,
    InstantiationType.Delayed,
  );
  return IMarkdownRendererService;
}();
