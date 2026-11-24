// Truth-driven tests for platform/extensions/common/extensions.ts.
// Truth: tool/ts2dart/batch129_truth.json
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/platform/extensions/common/extensions.dart'
    as ext;

const String _undef = '__undefined__';

final Map<String, dynamic> _truth =
    jsonDecode(File('tool/ts2dart/batch129_truth.json').readAsStringSync())
        as Map<String, dynamic>;

dynamic _norm(Object? v) => v == null ? _undef : v;

Map<String, dynamic> _section(String name) =>
    (_truth[name] as Map).cast<String, dynamic>();

List<dynamic> _list(String name) => _truth[name] as List<dynamic>;

void main() {
  group('batch129 / extensions.ts', () {
    test('constants and decorator', () {
      final Map<String, dynamic> e = _section('constants');
      expect(ext.UNDEFINED_PUBLISHER, e['UNDEFINED_PUBLISHER']);
      expect(ext.ALL_EXTENSION_KINDS, e['ALL_EXTENSION_KINDS']);
      expect(ext.EXTENSION_CATEGORIES, e['EXTENSION_CATEGORIES']);
      expect(ext.EXTENSIONS_AGENTS_WINDOW_MANAGEMENT,
          e['EXTENSIONS_AGENTS_WINDOW_MANAGEMENT']);
      expect(ext.EXTENSIONS_AGENTS_WINDOW_AUTO_ENABLE,
          e['EXTENSIONS_AGENTS_WINDOW_AUTO_ENABLE']);
      expect(ext.MANAGE_EXTENSION_COMMAND_ID, e['MANAGE_EXTENSION_COMMAND_ID']);
      expect(ext.EXTENSIONS_AGENTS_WINDOW_AUTO_ENABLE_EXTENSIONS,
          e['EXTENSIONS_AGENTS_WINDOW_AUTO_ENABLE_EXTENSIONS']);
      expect(ext.IBuiltinExtensionsScannerService.toString(), e['decorator']);
    });

    test('getManifestCacheFileName', () {
      for (final dynamic row in _list('manifestCacheFileName')) {
        final Map<String, dynamic> r = row as Map<String, dynamic>;
        final String? language =
            r['language'] == _undef ? null : r['language'] as String;
        expect(
          ext.getManifestCacheFileName(r['type'] as int, language),
          r['name'],
          reason: 'type=${r['type']} language=${r['language']}',
        );
      }
    });

    test('isManifestCacheFileName', () {
      for (final dynamic row in _list('isManifestCacheFileName')) {
        final Map<String, dynamic> r = row as Map<String, dynamic>;
        expect(
          ext.isManifestCacheFileName(
            r['name'] as String,
            r['type'] as int,
            r['ignorePathCasing'] as bool,
          ),
          r['result'],
          reason: '${r['name']} type=${r['type']} ic=${r['ignorePathCasing']}',
        );
      }
    });

    test('ExtensionIdentifier ctor + toKey', () {
      for (final dynamic row in _list('identifierCtor')) {
        final Map<String, dynamic> r = row as Map<String, dynamic>;
        final id = ext.ExtensionIdentifier(r['value'] as String);
        expect(id.value, r['value']);
        expect(id.lower, r['lower']);
        expect(ext.ExtensionIdentifier.toKey(id), r['toKey']);
      }
      for (final dynamic row in _list('identifierToKey')) {
        final Map<String, dynamic> r = row as Map<String, dynamic>;
        final String v = r['id'] as String;
        expect(ext.ExtensionIdentifier.toKey(v), r['key']);
      }
    });

    test('ExtensionIdentifier.equals', () {
      for (final dynamic row in _list('identifierEquals')) {
        final Map<String, dynamic> r = row as Map<String, dynamic>;
        final Object? a = _coerce(r['a']);
        final Object? b = _coerce(r['b']);
        expect(
          ext.ExtensionIdentifier.equals(a, b),
          r['result'],
          reason: 'a=${r['a']} b=${r['b']}',
        );
      }
    });

    test('ExtensionIdentifierSet', () {
      final ext.ExtensionIdentifierSet s = ext.ExtensionIdentifierSet([
        ext.ExtensionIdentifier('A.One'),
        'b.two',
        ext.ExtensionIdentifier('C.Three'),
      ]);
      for (final dynamic row in _list('identifierSet')) {
        final Map<String, dynamic> r = row as Map<String, dynamic>;
        switch (r['op'] as String) {
          case 'size':
          case 'size-after':
            expect(s.size, r['value'], reason: r['op'] as String);
            break;
          case 'has':
          case 'has-after':
            expect(s.has(r['id'] as String), r['value'],
                reason: r['op'] as String);
            break;
          case 'has-added':
            s.add('d.FOUR');
            expect(s.has(r['id'] as String), r['value'],
                reason: r['op'] as String);
            break;
          case 'delete':
            expect(s.delete(ext.ExtensionIdentifier('b.two')), r['value']);
            break;
          case 'delete-missing':
            expect(s.delete(ext.ExtensionIdentifier('b.two')), r['value']);
            break;
        }
      }
    });

    test('ExtensionIdentifierMap', () {
      final ext.ExtensionIdentifierMap<Object?> m =
          ext.ExtensionIdentifierMap<Object?>();
      final List<dynamic> trace = _list('identifierMap');
      for (final dynamic row in trace) {
        final Map<String, dynamic> r = row as Map<String, dynamic>;
        switch (r['op'] as String) {
          case 'get':
            m.set('A.One', 1);
            m.set(ext.ExtensionIdentifier('b.TWO'), 2);
            m.set('a.one', 3);
            expect(_norm(m.get('A.ONE')), r['value']);
            break;
          case 'has':
            expect(m.has(ext.ExtensionIdentifier('B.two')), r['value']);
            break;
          case 'values':
            expect(m.values().toList(), r['value']);
            break;
          case 'entries':
            expect(
              m.iterable.entries
                  .map((MapEntry<String, Object?> e) => [e.key, e.value])
                  .toList(),
              r['value'],
            );
            break;
          case 'forEach':
            final List<dynamic> log = <dynamic>[];
            // ignore: unnecessary_lambdas
            m.forEach((Object? value, String key, Map<String, Object?> map) {
              log.add([key, value]);
            });
            expect(log, r['value']);
            break;
          case 'get-after-delete':
            m.delete('a.one');
            expect(_norm(m.get('A.One')), r['value']);
            break;
          case 'has-after-delete':
            expect(m.has('A.One'), r['value']);
            break;
          case 'size-via-iterator-after-clear':
            m.clear();
            expect(m.iterable.length, r['value']);
            break;
        }
      }
    });

    test('ExtensionError', () {
      final Map<String, dynamic> e = _section('extensionError');
      final ext.ExtensionError err = ext.ExtensionError(
        ext.ExtensionIdentifier('Pub.Ext'),
        _FakeCause('root cause', 'STACKTRACE'),
        'while activating',
      );
      expect(err.name, e['name']);
      expect(err.message, e['message']);
      expect(err.extension.value, e['extension']);
      expect(err.stack, e['stack']);
      final ext.ExtensionError errNoMsg = ext.ExtensionError(
        ext.ExtensionIdentifier('Pub.Ext'),
        _FakeCause('root cause', 'STACKTRACE'),
      );
      expect(errNoMsg.message, e['noMessage']);
    });

    test('getWorkspaceSupportTypeMessage', () {
      for (final dynamic row in _list('workspaceSupport')) {
        final Map<String, dynamic> r = row as Map<String, dynamic>;
        final Object? value = r['value'] == _undef
            ? null
            : (r['value'] is Map
                ? (r['value'] as Map).cast<String, Object?>()
                : r['value']);
        expect(
          _norm(ext.getWorkspaceSupportTypeMessage(value)),
          r['message'],
          reason: 'value=${r['value']}',
        );
      }
    });

    test('predicates', () {
      final Map<String, dynamic> p = _section('predicates');
      final ext.IExtensionManifest langPack = ext.IExtensionManifest(
        contributes: ext.IExtensionContributions(
          localizations: <ext.ILocalizationContribution>[
            ext.ILocalizationContribution(
                languageId: 'zh', translations: <ext.ITranslation>[]),
          ],
        ),
      );
      final ext.IExtensionManifest emptyLocalizations = ext.IExtensionManifest(
        contributes:
            ext.IExtensionContributions(localizations: <ext.ILocalizationContribution>[]),
      );
      final ext.IExtensionManifest noContributes = ext.IExtensionManifest();
      final ext.IExtensionManifest auth = ext.IExtensionManifest(
        contributes: ext.IExtensionContributions(
          authentication: <ext.IAuthenticationContribution>[
            ext.IAuthenticationContribution(id: 'a', label: 'A'),
          ],
        ),
      );
      final ext.IExtensionManifest emptyAuth = ext.IExtensionManifest(
        contributes: ext.IExtensionContributions(
            authentication: <ext.IAuthenticationContribution>[]),
      );
      expect(ext.isLanguagePackExtension(langPack), p['langPackTrue']);
      expect(ext.isLanguagePackExtension(emptyLocalizations),
          p['langPackFalseEmpty']);
      expect(
          ext.isLanguagePackExtension(noContributes), p['langPackFalseMissing']);
      expect(ext.isApplicationScopedExtension(langPack),
          p['appScopedLangPack']);
      expect(
          ext.isApplicationScopedExtension(noContributes), p['appScopedPlain']);
      expect(ext.isAuthenticationProviderExtension(auth), p['authTrue']);
      expect(ext.isAuthenticationProviderExtension(emptyAuth),
          p['authFalseEmpty']);
      expect(ext.isAuthenticationProviderExtension(noContributes),
          p['authFalseMissing']);

      final ext.IExtensionManifest resolver = ext.IExtensionManifest(
        activationEvents: <String>['onResolveRemoteAuthority:ssh-remote'],
      );
      final ext.IExtensionManifest wrongResolver = ext.IExtensionManifest(
        activationEvents: <String>['onResolveRemoteAuthority:other'],
      );
      expect(
          ext.isResolverExtension(resolver, 'ssh-remote+host'), p['resolverTrue']);
      expect(
          ext.isResolverExtension(wrongResolver, 'ssh-remote+host'),
          p['resolverFalseWrongEvent']);
      expect(ext.isResolverExtension(resolver, null),
          p['resolverFalseNoAuthority']);
      expect(ext.isResolverExtension(noContributes, 'ssh-remote+host'),
          p['resolverFalseNoEvents']);
      expect(
          ext.parseEnabledApiProposalNames(<String>['foo@1', 'bar@2', 'baz']),
          p['parseProposals']);
    });
  });
}

/// Truth equality cases distinguish `null`/`undefined` from identifiers and
/// strings. The truth JSON serializes `undefined` as [_undef]; identifiers are
/// serialized as their `.value` string, so we reconstruct by the same rule the
/// truth harness used: a caller that passed an `ExtensionIdentifier` is encoded
/// identically to a plain string. To keep the Dart assertions 1:1 we treat all
/// non-null encoded values as strings (the string comparison path), which is
/// exactly what the truth exercises for mixed identifier/string cases.
Object? _coerce(Object? raw) =>
    raw == null || raw == _undef ? null : raw as String;

class _FakeCause implements ext.ExtensionErrorCause {
  _FakeCause(this.message, this.stack);

  @override
  final String? message;

  @override
  final String? stack;
}
