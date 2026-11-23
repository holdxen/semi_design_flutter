// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/managedSettings.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. TS discriminated-union types ->
// abstract base + concrete value classes; `Record<string,string>` -> Dart Map.
// ---------------------------------------------------------------------------

import 'dart:convert';

/// A single enterprise-managed marketplace entry, preserving the marketplace
/// name (used as `displayLabel`) and the original `source` discriminator.
abstract class IExtraKnownMarketplaceEntry {
  String get name;
  bool? get autoUpdate;
  Object get source;
}

class GithubMarketplaceSource {
  final String source = 'github';
  final String repo;
  final String? ref;
  GithubMarketplaceSource(this.repo, [this.ref]);
}

class GitMarketplaceSource {
  final String source = 'git';
  final String url;
  final String? ref;
  GitMarketplaceSource(this.url, [this.ref]);
}

class GithubMarketplaceEntry implements IExtraKnownMarketplaceEntry {
  @override
  final String name;
  @override
  final bool? autoUpdate;
  @override
  final GithubMarketplaceSource source;
  GithubMarketplaceEntry(this.name, this.source, [this.autoUpdate]);
}

class GitMarketplaceEntry implements IExtraKnownMarketplaceEntry {
  @override
  final String name;
  @override
  final bool? autoUpdate;
  @override
  final GitMarketplaceSource source;
  GitMarketplaceEntry(this.name, this.source, [this.autoUpdate]);
}

class IExtraKnownMarketplaceConfigValue {
  final String source;
  final bool autoUpdate;
  IExtraKnownMarketplaceConfigValue(this.source, this.autoUpdate);

  Map<String, Object> toJson() => <String, Object>{'source': source, 'autoUpdate': autoUpdate};
}

/// A single entry in the enterprise-managed `strictKnownMarketplaces` allowlist
/// discriminated by `source`. Delivered as JSON via managed settings and
/// validated at match time, so the optional fields are only meaningful for
/// their corresponding `source`.
class IStrictMarketplaceSource {
  final String source;
  final String? repo;
  final String? url;
  final String? ref;
  final String? path;
  final String? packageName;
  final String? hostPattern;
  final String? pathPattern;
  final Map<String, String>? headers;

  IStrictMarketplaceSource(
    this.source, {
    this.repo,
    this.url,
    this.ref,
    this.path,
    this.packageName,
    this.hostPattern,
    this.pathPattern,
    this.headers,
  });
}

typedef ExtraKnownMarketplacesConfigDict = Map<String, String>;

/// Converts an [IExtraKnownMarketplaceEntry] array into the
/// policy dict stored on the `chat.plugins.extraMarketplaces` setting.
ExtraKnownMarketplacesConfigDict? extraKnownMarketplacesToConfigDict(List<Object?>? entries) {
  if (entries == null || entries.isEmpty) {
    return null;
  }
  final ExtraKnownMarketplacesConfigDict obj = <String, String>{};
  for (final Object? entry in entries) {
    if (entry is String) {
      if (isUnsafeMarketplaceKey(entry)) {
        continue;
      }
      obj[entry] = entry;
    } else if (entry is IExtraKnownMarketplaceEntry) {
      if (isUnsafeMarketplaceKey(entry.name)) {
        continue;
      }
      final Object s = entry.source;
      final String base;
      final String? ref;
      if (s is GithubMarketplaceSource) {
        base = s.repo;
        ref = s.ref;
      } else {
        final GitMarketplaceSource git = s as GitMarketplaceSource;
        base = git.url;
        ref = git.ref;
      }
      final String source = (ref != null) ? '$base#$ref' : base;
      obj[entry.name] = entry.autoUpdate == null
          ? source
          : jsonEncode(IExtraKnownMarketplaceConfigValue(source, entry.autoUpdate!).toJson());
    }
  }
  return obj;
}

/// Whether a marketplace name would pollute the prototype chain if used as an object key.
bool isUnsafeMarketplaceKey(String key) {
  return key == '__proto__' || key == 'constructor' || key == 'prototype';
}
