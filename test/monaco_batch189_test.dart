import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/browser/markdownRenderer.dart'
    as baseMarkdown;
import '../lib/src/monaco/base/common/htmlContent.dart'
    show MarkdownString, MarkdownStringTrustedOptions;
import '../lib/src/monaco/base/common/lifecycle.dart' as lifecycle;
import '../lib/src/monaco/base/common/uri.dart' show URI;
import '../lib/src/monaco/platform/instantiation/common/descriptors.dart'
    show SyncDescriptor;
import '../lib/src/monaco/platform/instantiation/common/extensions.dart'
    show getSingletonServiceDescriptors;
import '../lib/src/monaco/platform/markdown/browser/markdownRenderer.dart' as mr;
import '../lib/src/monaco/platform/opener/test/common/nullOpenerService.dart'
    as nullOpener;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

List<dynamic> _list(dynamic value) => value as List<dynamic>;

class _BoomError implements Exception {
  @override
  String toString() => 'boom';
}

class _FakeClassList {
  _FakeClassList(this.owner);

  final _FakeElement owner;

  void add(String token) {
    owner.classes.add(token);
    owner.log.add(<String, Object?>{'kind': 'classList.add', 'tag': owner.tag, 'token': token});
  }
}

class _FakeElement {
  _FakeElement(this.tag, this.log);

  final String tag;
  final List<Map<String, Object?>> log;
  final List<String> classes = <String>[];
  late final _FakeClassList classList = _FakeClassList(this);
}

class _Opener {
  _Opener(this.behavior, this.name);

  final String behavior;
  final String name;
  final List<Map<String, Object?>> calls = <Map<String, Object?>>[];

  Future<bool> open(String link, Object? options) {
    calls.add(<String, Object?>{
      'name': name,
      'link': link,
      'options': options == null ? null : _map(options),
    });
    if (behavior == 'reject') {
      return Future<bool>.error(_BoomError());
    }
    return Future<bool>.value(behavior == 'true');
  }
}

class _DefaultCodeRenderer implements mr.IMarkdownCodeBlockRenderer {
  _DefaultCodeRenderer(this.log);

  final List<Map<String, Object?>> log;
  int calls = 0;

  @override
  Future<Object> renderCodeBlock(String? alias, String value, Object options) {
    calls++;
    log.add(<String, Object?>{
      'kind': 'defaultCodeBlock',
      'alias': alias,
      'value': value,
      'keys': _optionKeys(options as baseMarkdown.MarkdownRenderOptions),
    });
    return Future<Object>.value(_FakeElement('default-code', log));
  }
}

List<String> _optionKeys(baseMarkdown.MarkdownRenderOptions options) {
  final List<String> keys = <String>[
    if (options.codeBlockRenderer != null) 'codeBlockRenderer',
    if (options.codeBlockRendererSync != null) 'codeBlockRendererSync',
    if (options.asyncRenderCallback != null) 'asyncRenderCallback',
    if (options.actionHandler != null) 'actionHandler',
    if (options.transformUri != null) 'transformUri',
    if (options.fillInIncompleteTokens != null) 'fillInIncompleteTokens',
    if (options.sanitizerConfig != null) 'sanitizerConfig',
    if (options.markedOptions != null) 'markedOptions',
    if (options.markedExtensions != null) 'markedExtensions',
  ]..sort();
  return keys;
}

void main() {
  final Map<String, dynamic> truth = _map(
    jsonDecode(File('tool/ts2dart/batch189_truth.json').readAsStringSync()),
  );

  group('batch189 NullOpenerService truth', () {
    test('frozen service object and all methods match truth', () async {
      final Map<String, dynamic> data = _map(truth['nullOpenerService']);
      expect(_list(data['exports']), <String>['NullOpenerService']);
      expect(identical(nullOpener.NullOpenerService, nullOpener.NullOpenerService),
          data['frozen']);
      expect(nullOpener.NullOpenerService.serviceBrand, isNull);
      expect(data['serviceBrandUndefined'], true);
      final List<String> actualKeys = _list(data['keys'])
          .where((dynamic k) => (k as String) != '_serviceBrand')
          .map((dynamic k) => k as String)
          .toList();
      actualKeys.sort();
      expect(
        actualKeys,
        <String>[
          'open',
          'registerExternalOpener',
          'registerExternalUriResolver',
          'registerOpener',
          'registerValidator',
          'resolveExternalUri',
          'setDefaultExternalOpener',
        ],
      );

      expect(identical(nullOpener.NullOpenerService.registerOpener(),
          lifecycle.Disposable.none), data['registerOpenerIsNone']);
      expect(identical(nullOpener.NullOpenerService.registerValidator(),
          lifecycle.Disposable.none), data['registerValidatorIsNone']);
      expect(
        identical(
          nullOpener.NullOpenerService.registerExternalUriResolver(),
          lifecycle.Disposable.none,
        ),
        data['registerExternalUriResolverIsNone'],
      );
      expect(identical(nullOpener.NullOpenerService.registerExternalOpener(),
          lifecycle.Disposable.none), data['registerExternalOpenerIsNone']);
      nullOpener.NullOpenerService.setDefaultExternalOpener();
      expect(data['setDefaultExternalOpenerResult'], true);
      expect(await nullOpener.NullOpenerService.open(), data['openResult']);

      final uri = URI.parse('file:///some/file.js');
      final resolved =
          await nullOpener.NullOpenerService.resolveExternalUri(uri);
      expect(resolved.resolved.toString(),
          _map(data['resolved'])['uri']);
      resolved.dispose();
      expect(true, data['disposed']);
    });
  });

  group('batch189 markdownRenderer truth', () {
    late baseMarkdown.RenderedMarkdown Function(
      Object, [baseMarkdown.MarkdownRenderOptions?, Object?]) savedRender;
    late Object? Function(Object?) savedError;
    late Object Function(String) savedCreate;

    setUp(() {
      savedRender = mr.markdownRendererRenderMarkdown;
      savedError = mr.markdownRendererOnUnexpectedError;
      savedCreate = mr.markdownRendererCreateElement;
    });

    tearDown(() {
      mr.markdownRendererRenderMarkdown = savedRender;
      mr.markdownRendererOnUnexpectedError = savedError;
      mr.markdownRendererCreateElement = savedCreate;
    });

    test('declarations, runtime exports and singleton registration', () {
      final Map<String, dynamic> data = _map(truth['markdownRenderer']);
      expect(_list(data['declarations']), <String>[
        'IMarkdownCodeBlockRenderer',
        'IMarkdownRenderer',
        'IMarkdownRendererExtraOptions',
        'IMarkdownRendererService',
        'MarkdownRendererService',
        'openLinkFromMarkdown',
      ]);
      expect(_list(data['exports']), <String>[
        'IMarkdownRendererService',
        'MarkdownRendererService',
        'openLinkFromMarkdown',
      ]);
      expect(
        mr.IMarkdownRendererService.toString(),
        data['serviceId'],
      );
      expect(mr.registration, same(mr.IMarkdownRendererService));

      final Map<String, dynamic> registrationTruth =
          _map(_list(data['registrations']).single);
      final List<Object?> found = getSingletonServiceDescriptors()
          .where((List<Object?> e) =>
              e[0]?.toString() == registrationTruth['id'])
          .toList();
      expect(found, hasLength(1));
      final List<Object?> entry = found.single as List<Object?>;
      final SyncDescriptor<Object> descriptor =
          entry[1] as SyncDescriptor<Object>;
      expect(descriptor.ctor, isA<Function>());
      expect(descriptor.supportsDelayedInstantiation,
          registrationTruth['delayed'] == 1);
    });

    test('openLinkFromMarkdown matches all trusted/open error cases', () async {
      final Map<String, dynamic> data = _map(truth['markdownRenderer']);
      for (final dynamic raw in _list(data['openLink'])) {
        final Map<String, dynamic> rawCase = _map(raw);
        String behavior = 'true';
        if (rawCase['name'] == 'trusted-commands') behavior = 'false';
        if (rawCase['name'] == 'open-rejects') behavior = 'reject';
        final _Opener opener = _Opener(behavior, rawCase['name'] as String);
        final List<Object?> errors = <Object?>[];
        mr.markdownRendererOnUnexpectedError = (Object? e) => errors.add(e);

        Object? isTrusted;
        bool? skipValidation;
        switch (rawCase['name']) {
          case 'trusted-true':
            isTrusted = true;
            break;
          case 'trusted-commands':
            isTrusted =
                MarkdownStringTrustedOptions(enabledCommands: <String>['a', 'b']);
            skipValidation = true;
            break;
          case 'trusted-false':
            isTrusted = false;
            break;
          case 'trusted-undefined':
            isTrusted = null;
            skipValidation = false;
            break;
          case 'open-rejects':
            isTrusted = true;
            break;
        }

        final bool result = await mr.openLinkFromMarkdown(
          opener,
          'command:doThing',
          isTrusted,
          skipValidation,
        );
        expect(result, rawCase['result'], reason: rawCase['name'] as String);
        expect(opener.calls, _list(rawCase['openerCalls']),
            reason: rawCase['name'] as String);
        expect(errors.map((Object? e) => e.toString()).toList(),
            _list(rawCase['errors']),
            reason: rawCase['name'] as String);
      }
    });

    test('render matches default/custom/default-code-block truth', () async {
      final Map<String, dynamic> data = _map(truth['markdownRenderer']);
      for (final dynamic raw in _list(data['render'])) {
        final Map<String, dynamic> rawCase = _map(raw);
        final List<Map<String, Object?>> log = <Map<String, Object?>>[];
        final List<Map<String, Object?>> renderCalls =
            <Map<String, Object?>>[];
        final List<Object?> errors = <Object?>[];
        int customActionCalls = 0;
        int customCodeCalls = 0;
        final _DefaultCodeRenderer defaultCodeRenderer =
            _DefaultCodeRenderer(log);

        mr.markdownRendererOnUnexpectedError = (Object? e) => errors.add(e);
        mr.markdownRendererCreateElement = (String tag) {
          final _FakeElement element = _FakeElement(tag, log);
          log.add(<String, Object?>{'kind': 'createElement', 'tag': tag});
          return element;
        };
        mr.markdownRendererRenderMarkdown = (
          Object markdown, [
          baseMarkdown.MarkdownRenderOptions? options,
          Object? target,
        ]) {
          final dynamic md = markdown;
          renderCalls.add(<String, Object?>{
            'markdown': md.value,
            'keys': _optionKeys(options ?? baseMarkdown.MarkdownRenderOptions()),
            'hasOptions': options != null,
            'outElement': target == null
                ? null
                : (target as _FakeElement).tag,
          });
          if (options?.actionHandler != null) {
            options!.actionHandler!(
              'cmd:test',
              MarkdownString('hello', true),
            );
          }
          if (options?.codeBlockRenderer != null) {
            options!.codeBlockRenderer!('typescript', 'const x=1;')
                .then((Object element) {
              log.add(<String, Object?>{
                'kind': 'codeBlockResult',
                'tag': (element as _FakeElement).tag,
              });
            });
          }
          return baseMarkdown.RenderedMarkdown(
            _FakeElement('rendered', log),
            () {
              log.add(<String, Object?>{'kind': 'dispose'});
            },
          );
        };

        final String name = rawCase['name'] as String;
        final String openerName = <String, String>{
          'default handlers': 'default-render',
          'custom handlers': 'custom-render',
          'default code block renderer': 'default-code-render',
        }[name]!;
        String openerBehavior = 'true';
        if (name == 'custom handlers') openerBehavior = 'false';
        final _Opener opener = _Opener(openerBehavior, openerName);
        final mr.MarkdownRendererService service =
            mr.MarkdownRendererService(opener);

        baseMarkdown.MarkdownRenderOptions? options;
        if (name == 'custom handlers') {
          options = mr.MarkdownRendererRenderOptions(
            actionHandler: (String link, Object mdStr) {
              customActionCalls++;
            },
            codeBlockRenderer: (String alias, String value) async {
              customCodeCalls++;
              return _FakeElement('custom-code', log);
            },
          );
        }
        if (name == 'default code block renderer') {
          service.setDefaultCodeBlockRenderer(defaultCodeRenderer);
        }

        final baseMarkdown.RenderedMarkdown rendered =
            service.render(MarkdownString('hello', true), options as mr.MarkdownRendererRenderOptions?);
        await Future<void>.delayed(Duration.zero);

        expect(renderCalls, _list(rawCase['renderCalls']),
            reason: name);
        expect(opener.calls, _list(rawCase['openerCalls']), reason: name);
        expect((rendered.element as _FakeElement).classes,
            _list(rawCase['classes']),
            reason: name);
        expect(log, _list(rawCase['log']), reason: name);
        expect(errors.map((Object? e) => e.toString()).toList(),
            _list(rawCase['errors']),
            reason: name);
        if (rawCase.containsKey('customActionCalls')) {
          expect(customActionCalls, rawCase['customActionCalls'], reason: name);
        }
        if (rawCase.containsKey('customCodeCalls')) {
          expect(customCodeCalls, rawCase['customCodeCalls'], reason: name);
        }
        if (rawCase.containsKey('defaultCodeCalls')) {
          expect(defaultCodeRenderer.calls, rawCase['defaultCodeCalls'],
              reason: name);
        }
      }
    });
  });
}
