// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/links/browser/getLinks.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Carriers:
//   - `ILink` / `ILinksList` / `LinkProvider` (erased TS interfaces from
//     languages.ts) -> file-local opaque carriers.
//   - `ITextModel` (pending ../model.ts) -> ILanguageFeatureModel for registry
//     ordering + narrow [ILinksModel] for providers.
//   - `Promise<R>` -> `Future<R>`.
// ---------------------------------------------------------------------------

import '../../../../base/common/arrays.dart' show coalesce;
import '../../../../base/common/cancellation.dart' show CancellationToken;
import '../../../../base/common/errors.dart' show onUnexpectedExternalError;
import '../../../../base/common/lifecycle.dart'
    show DisposableStore, IDisposable, isDisposable;
import '../../../../base/common/types.dart' show assertType;
import '../../../../base/common/uri.dart' show URI;
import '../../../common/core/range.dart' show IRange, Range;
import '../../../common/languageFeatureRegistry.dart'
    show ILanguageFeatureModel, LanguageFeatureRegistry;
import '../../../common/services/languageFeatures.dart'
    show ILanguageFeaturesService, ILanguageFeaturesServiceType;
import '../../../common/services/model.dart' show IModelService, IModelServiceType;
import '../../../../platform/commands/common/commands.dart'
    show CommandsRegistry;
import '../../../../platform/instantiation/common/instantiation.dart'
    show ServicesAccessor;

/// 1:1: `ILink` from languages.ts (opaque carrier).
class ILink {
  ILink(this.range, this.url, this.tooltip);

  final IRange range;
  final Object? url; // URI | String | undefined
  final String? tooltip;
}

/// 1:1: `ILinksList` from languages.ts (opaque carrier).
class ILinksList {
  ILinksList(this.links);
  final List<ILink> links;
}

/// 1:1: `LinkProvider` contract (opaque carrier).
abstract class ILinkProvider {
  Future<ILinksList?> provideLinks(
    Object model,
    CancellationToken token,
  );

  /// 1:1: optional `resolveLink` — nullable function carrier for TS optional
  /// method.
  Future<Object?> Function(ILink link, CancellationToken token)?
      get resolveLink;
}

/// 1:1: `ITextModel` subset used by getLinks. Extends the registry's erased
/// model surface so [LanguageFeatureRegistry.ordered] accepts it.
abstract class ILinksModel implements ILanguageFeatureModel {}

/// 1:1: `export class Link implements ILink`.
class Link implements IDisposable {
  Link(this._link, this._provider);

  ILink _link;
  final ILinkProvider _provider;

  Map<String, Object?> toJSON() => <String, Object?>{
        'range': <int>[
          range.startLineNumber,
          range.startColumn,
          range.endLineNumber,
          range.endColumn,
        ],
        'url': url == null ? null : (url is URI ? url.toString() : url),
        'tooltip': tooltip,
      };

  IRange get range => _link.range;

  Object? get url => _link.url;

  String? get tooltip => _link.tooltip;

  /// 1:1: `async resolve(token): Promise<URI | string>`.
  Future<Object> resolve(CancellationToken token) async {
    if (_link.url != null && _link.url != false && _link.url != '') {
      return _link.url as Object;
    }

    final resolver = _provider.resolveLink;
    if (resolver != null) {
      final Object? value = await resolver(_link, token);
      _link = value as ILink? ?? _link;
      if (_link.url != null && _link.url != false && _link.url != '') {
        // recurse
        return resolve(token);
      }
      throw StateError('missing');
    }

    throw StateError('missing');
  }

  @override
  void dispose() {
    // Link itself has no resources; disposal is owned by LinksList.
  }
}

/// 1:1: `export class LinksList`.
class LinksList implements IDisposable {
  static final LinksList Empty = LinksList(<(ILinksList, ILinkProvider)>[]);

  late final List<Link> links;
  final DisposableStore? _disposables;

  LinksList(List<(ILinksList, ILinkProvider)> tuples)
      : _disposables = DisposableStore() {
    List<Link> merged = <Link>[];
    for (final (list, provider) in tuples) {
      // merge all links
      final List<Link> newLinks = list.links
          .map((link) => Link(link, provider))
          .toList();
      merged = LinksList._union(merged, newLinks);
      // register disposables
      if (isDisposable(list)) {
        // DisposableStore is created eagerly here (TS lazy ??=), which is
        // observationally equivalent for add/dispose.
        _disposables!.add(list as IDisposable);
      }
    }
    links = merged;
  }

  @override
  void dispose() {
    _disposables?.dispose();
    links.clear();
  }

  /// 1:1: `static _union(oldLinks, newLinks)`.
  static List<Link> _union(List<Link> oldLinks, List<Link> newLinks) {
    // reunite oldLinks with newLinks and remove duplicates
    final List<Link> result = <Link>[];
    int oldIndex = 0;
    int newIndex = 0;
    final int oldLen = oldLinks.length;
    final int newLen = newLinks.length;

    while (oldIndex < oldLen && newIndex < newLen) {
      final Link oldLink = oldLinks[oldIndex];
      final Link newLink = newLinks[newIndex];

      if (Range.areIntersectingOrTouching(oldLink.range, newLink.range)) {
        // Remove the oldLink
        oldIndex++;
        continue;
      }

      final int comparisonResult =
          Range.compareRangesUsingStarts(oldLink.range, newLink.range);
      if (comparisonResult < 0) {
        // oldLink is before
        result.add(oldLink);
        oldIndex++;
      } else {
        // newLink is before
        result.add(newLink);
        newIndex++;
      }
    }

    for (; oldIndex < oldLen; oldIndex++) {
      result.add(oldLinks[oldIndex]);
    }
    for (; newIndex < newLen; newIndex++) {
      result.add(newLinks[newIndex]);
    }

    return result;
  }
}

/// 1:1: `getLinks(providers, model, token)`.
Future<LinksList> getLinks(
  LanguageFeatureRegistry<ILinkProvider> providers,
  ILinksModel model,
  CancellationToken token,
) async {
  final List<(ILinksList, ILinkProvider)?> lists =
      List<(ILinksList, ILinkProvider)?>.filled(
          providers.ordered(model).length, null);

  // ask all providers for links in parallel
  final List<ILinkProvider> ordered =
      providers.ordered(model).reversed.toList();
  final List<Future<void>> promises = <Future<void>>[];
  for (int i = 0; i < ordered.length; i++) {
    final ILinkProvider provider = ordered[i];
    promises.add((() async {
      try {
        final ILinksList? result = await provider.provideLinks(model, token);
        if (result != null) {
          lists[i] = (result, provider);
        }
      } catch (err) {
        onUnexpectedExternalError(err);
      }
    })());
  }

  await Future.wait(promises);

  LinksList res = LinksList(coalesce(lists));

  if (token.isCancellationRequested) {
    res.dispose();
    res = LinksList.Empty;
  }

  return res;
}

/// 1:1: `CommandsRegistry.registerCommand('_executeLinkProvider', ...)`.
void _registerExecuteLinkProviderCommand() {
  CommandsRegistry.registerCommand(
      '_executeLinkProvider',
      (ServicesAccessor accessor, List<Object?> args) async {
    final Object? uri = args.isNotEmpty ? args[0] : null;
    final Object? resolveCountArg = args.length > 1 ? args[1] : null;
    assertType(uri is URI);

    int resolveCount = resolveCountArg is num ? resolveCountArg.toInt() : 0;

    final ILanguageFeaturesServiceType languageFeaturesService =
        accessor.get(ILanguageFeaturesService) as ILanguageFeaturesServiceType;
    final IModelServiceType modelService =
        accessor.get(IModelService) as IModelServiceType;
    final ILinksModel? model = modelService.getModel(uri as URI) as ILinksModel?;
    if (model == null) {
      return <Object?>[];
    }
    final LinksList list = await getLinks(
      languageFeaturesService.linkProvider as LanguageFeatureRegistry<ILinkProvider>,
      model,
      CancellationToken.none,
    );

    // resolve links
    final int limit = resolveCount < list.links.length
        ? resolveCount
        : list.links.length;
    for (int i = 0; i < limit; i++) {
      await list.links[i].resolve(CancellationToken.none);
    }

    final List<Link> result = list.links.toList();
    list.dispose();
    return result;
  });
}

/// Dart top-level initializers are lazy; the TS module registers eagerly.
final bool _commandRegistered = () {
  _registerExecuteLinkProviderCommand();
  return true;
}();

/// 1:1: forces evaluation of the module-level command registration.
bool ensureRegistered() => _commandRegistered;
