// batch281: getLinks.ts truth replay.
// Truth from tool/ts2dart/batch281_truth.json (recursive TS transpile+vm,
// real getLinks/Link/LinksList + LanguageFeatureRegistry + fake providers).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/cancellation.dart'
    show CancellationToken;
import 'package:semi_design_flutter/src/monaco/base/common/errors.dart'
    show setUnexpectedErrorHandler;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    show IDisposable;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart'
    show Range;
import 'package:semi_design_flutter/src/monaco/editor/common/languageFeatureRegistry.dart'
    show LanguageFeatureRegistry;
import 'package:semi_design_flutter/src/monaco/editor/contrib/links/browser/getLinks.dart'
    show
        ILink,
        ILinkProvider,
        ILinksList,
        ILinksModel,
        LinksList,
        ensureRegistered,
        getLinks;
import 'package:semi_design_flutter/src/monaco/platform/commands/common/commands.dart'
    show CommandsRegistry;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch281_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Object? _norm(Object? v) {
  if (v == null) return null;
  if (v is Map) {
    return v.map<String, Object?>((k, e) =>
        MapEntry<String, Object?>(k as String, _norm(e)));
  }
  if (v is List) return v.map(_norm).toList();
  return v;
}

class _Model implements ILinksModel {
  @override
  final URI uri = URI.parse('file:///a.ts');

  @override
  String getLanguageId() => 'typescript';

  @override
  bool isTooLargeForSyncing() => false;

  @override
  bool get isForSimpleWidget => false;
}

ILink _makeLink(Map<String, dynamic> def) {
  final urlKind = def['urlKind'] as String?;
  Object? url;
  if (urlKind == 'string') url = def['url'] as String;
  if (urlKind == 'uri') url = URI.parse(def['url'] as String);
  return ILink(
    Range(def['sl'] as int, def['sc'] as int, def['el'] as int, def['ec'] as int),
    url,
    def['tooltip'] as String?,
  );
}

class _DisposableList extends ILinksList implements IDisposable {
  _DisposableList(super.links, this.calls, this.id);
  final List<Map<String, Object?>> calls;
  final String id;

  @override
  void dispose() {
    calls.add(<String, Object?>{'provider': id, 'phase': 'list.dispose'});
  }
}

class _Provider implements ILinkProvider {
  _Provider(this.id, this.action, this.linkDefs, this.resolveKind,
      this.resolveUrl, this.disposableList, this.calls);

  final String id;
  final String action;
  final List<dynamic> linkDefs;
  final String? resolveKind;
  final String? resolveUrl;
  final bool disposableList;
  final List<Map<String, Object?>> calls;
  final int _count = 0;

  @override
  Future<ILinksList?> provideLinks(
    Object model,
    CancellationToken token,
  ) async {
    calls.add(<String, Object?>{'provider': id, 'phase': 'provide'});
    if (action == 'throw') throw StateError('boom-$id');
    if (action == 'null') return null;
    final links = linkDefs
        .map((raw) => _makeLink(raw as Map<String, dynamic>))
        .toList();
    if (disposableList) return _DisposableList(links, calls, id);
    return ILinksList(links);
  }

  @override
  Future<Object?> Function(ILink link, CancellationToken token)?
      get resolveLink {
    if (resolveKind == null) return null;
    return (ILink link, CancellationToken token) async {
      calls.add(<String, Object?>{
        'provider': id,
        'phase': 'resolve',
        'symbol': 'r1',
        'count': _count,
      });
      if (resolveKind == 'give-url') {
        return _makeLink(<String, dynamic>{
          'sl': 1, 'sc': 1, 'el': 1, 'ec': 2,
          'urlKind': 'string', 'url': resolveUrl,
        });
      }
      return null;
    };
  }
}

class _Token implements CancellationToken {
  _Token(bool cancelled) : isCancellationRequested = cancelled;
  @override
  final bool isCancellationRequested;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  final t = _truth();

  test('b281 command registration', () {
    expect(ensureRegistered(), isTrue);
    final cmd = t['command'] as Map<String, dynamic>;
    expect(CommandsRegistry.getCommand(cmd['id'] as String), isNotNull);
  });

  for (final rawCase in t['cases'] as List<dynamic>) {
    final c = rawCase as Map<String, dynamic>;
    test('b281 ${c['name']}: getLinks matches TS truth', () async {
      final unexpected = <String>[];
      setUnexpectedErrorHandler((Object? e) =>
          unexpected.add(e is StateError ? e.message : e.toString()));
      addTearDown(() => setUnexpectedErrorHandler((_) {}));

      final registry = LanguageFeatureRegistry<ILinkProvider>();
      final calls = <Map<String, Object?>>[];
      for (final rawP in c['providers'] as List<dynamic>) {
        final p = rawP as Map<String, dynamic>;
        registry.register(
          'typescript',
          _Provider(
            p['id'] as String,
            p['action'] as String,
            p['links'] as List<dynamic>,
            p['resolveKind'] as String?,
            p['resolveUrl'] as String?,
            p['disposableList'] as bool,
            calls,
          ),
        );
      }

      final list = await getLinks(registry, _Model(), _Token(c['cancel'] as bool));

      // Links projection: range + url + tooltip.
      final links = list.links.map((l) => l.toJSON()).toList();
      final truthLinks =
          (c['links'] as List<dynamic>).cast<Map<String, dynamic>>();
      expect(links.length, truthLinks.length, reason: 'links len ${c['name']}');
      for (int i = 0; i < truthLinks.length; i++) {
        expect(_norm(links[i]), truthLinks[i],
            reason: '${c['name']} link $i');
      }

      expect(identical(list, LinksList.Empty), c['isEmptySingleton'],
          reason: 'empty singleton ${c['name']}');

      // resolve probes.
      final resolveOut = <Object?>[];
      if (c['resolveAll'] as bool) {
        for (final link in list.links) {
          try {
            final resolved = await link.resolve(_Token(false));
            resolveOut.add(<String, Object?>{
              'ok': true,
              'resolved': resolved is URI ? resolved.toString() : resolved,
            });
          } catch (e) {
            resolveOut.add(<String, Object?>{
              'ok': false,
              'error': e is StateError ? e.message : e.toString(),
            });
          }
        }
      }
      expect(_norm(resolveOut), c['resolveOut'],
          reason: 'resolve ${c['name']}');

      if (c['disposeList'] as bool) {
        list.dispose();
        calls.add(<String, Object?>{
          'provider': '(list)',
          'phase': 'after.dispose',
          'len': list.links.length,
        });
      }

      final truthCalls =
          (c['calls'] as List<dynamic>).cast<Map<String, dynamic>>();
      expect(_norm(calls), _norm(truthCalls), reason: 'calls ${c['name']}');

      final truthErrors = (c['externalErrors'] as List<dynamic>)
          .map((e) => e as String)
          .toList();
      expect(unexpected, truthErrors, reason: 'errors ${c['name']}');
    });
  }
}
