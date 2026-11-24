// Truth replay for batch199:
//   `platform/accessibility/browser/accessibleView.ts`.
//
// Expectations come from `tool/ts2dart/batch199_truth.json`, produced by
// `tool/ts2dart/_batch199_truth.cjs` (real transpiled module + the real
// `base/common/lifecycle`; every other import is type-only).
//
// NOTE: `accessibleView.ts` has no official test of its own (the STRICT+test
// match is the usual stem heuristic false positive); truth comes from
// executing the real source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/actions.dart' show IAction;
import '../lib/src/monaco/base/common/event.dart' as event;
import '../lib/src/monaco/base/common/lifecycle.dart' as lifecycle;
import '../lib/src/monaco/platform/accessibility/browser/accessibleView.dart'
    as av;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

List<dynamic> _list(dynamic value) => value as List<dynamic>;

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch199_truth.json').readAsStringSync()));

Map<String, Object?> _options(av.IAccessibleViewOptions options) =>
    <String, Object?>{
      'type': options.type,
      if (options.language != null) 'language': options.language,
      if (options.position != null) 'position': options.position,
      if (options.readMoreUrl != null) 'readMoreUrl': options.readMoreUrl,
    };

Map<String, Object?> _snapshot(av.AccessibleContentProvider provider) =>
    <String, Object?>{
      'id': provider.id,
      'options': _options(provider.options),
      'provideContent': provider.provideContent(),
      'hasOnClose': true,
      'verbositySettingKey': provider.verbositySettingKey,
      'hasOnOpen': provider.onOpen != null,
      'actions': provider.actions
          ?.map((IAction action) => action.id)
          .toList(),
      'provideNextContent': provider.provideNextContent?.call(),
      'providePreviousContent': provider.providePreviousContent?.call(),
      'hasOnDidChangeContent': provider.onDidChangeContent != null,
      'hasOnKeyDown': provider.onKeyDown != null,
      'getSymbols': provider.getSymbols
          ?.call()
          .map((av.IAccessibleViewSymbol symbol) => symbol.label)
          .toList(),
      'hasOnDidRequestClearLastProvider':
          provider.onDidRequestClearLastProvider != null,
    };

bool _isDisposable(Object value) => (value as dynamic).dispose is Function;

event.Event<T> _noopEvent<T>() =>
    (dynamic listener, [dynamic thisArgs, dynamic disposables]) =>
        lifecycle.Disposable.none;

void main() {
  final Map<String, dynamic> truth = _truth();

  test('batch199 enums match truth', () {
    final Map<String, dynamic> enums = _map(truth['enums']);
    final Map<String, String> providerIds = <String, String>{
    'Terminal': av.AccessibleViewProviderId.Terminal,
    'TerminalChat': av.AccessibleViewProviderId.TerminalChat,
    'TerminalHelp': av.AccessibleViewProviderId.TerminalHelp,
    'DiffEditor': av.AccessibleViewProviderId.DiffEditor,
    'MultiDiffEditorFileList': av.AccessibleViewProviderId.MultiDiffEditorFileList,
    'MergeEditor': av.AccessibleViewProviderId.MergeEditor,
    'PanelChat': av.AccessibleViewProviderId.PanelChat,
    'ChatHtmlPreview': av.AccessibleViewProviderId.ChatHtmlPreview,
    'CustomizationMigrations': av.AccessibleViewProviderId.CustomizationMigrations,
    'CustomizationDiscovery': av.AccessibleViewProviderId.CustomizationDiscovery,
    'Remotes': av.AccessibleViewProviderId.Remotes,
    'McpServerConfiguration': av.AccessibleViewProviderId.McpServerConfiguration,
    'ChatTerminalOutput': av.AccessibleViewProviderId.ChatTerminalOutput,
    'ChatBackgroundShellOutput': av.AccessibleViewProviderId.ChatBackgroundShellOutput,
    'ChatThinking': av.AccessibleViewProviderId.ChatThinking,
    'InlineChat': av.AccessibleViewProviderId.InlineChat,
    'AgentChat': av.AccessibleViewProviderId.AgentChat,
    'QuickChat': av.AccessibleViewProviderId.QuickChat,
    'InlineCompletions': av.AccessibleViewProviderId.InlineCompletions,
    'KeybindingsEditor': av.AccessibleViewProviderId.KeybindingsEditor,
    'Notebook': av.AccessibleViewProviderId.Notebook,
    'ReplEditor': av.AccessibleViewProviderId.ReplEditor,
    'Editor': av.AccessibleViewProviderId.Editor,
    'Hover': av.AccessibleViewProviderId.Hover,
    'Notification': av.AccessibleViewProviderId.Notification,
    'EmptyEditorHint': av.AccessibleViewProviderId.EmptyEditorHint,
    'Comments': av.AccessibleViewProviderId.Comments,
    'CommentThread': av.AccessibleViewProviderId.CommentThread,
    'Repl': av.AccessibleViewProviderId.Repl,
    'ReplHelp': av.AccessibleViewProviderId.ReplHelp,
    'RunAndDebug': av.AccessibleViewProviderId.RunAndDebug,
    'Walkthrough': av.AccessibleViewProviderId.Walkthrough,
    'ReleaseNotes': av.AccessibleViewProviderId.ReleaseNotes,
    'SourceControl': av.AccessibleViewProviderId.SourceControl,
    'EditorFindHelp': av.AccessibleViewProviderId.EditorFindHelp,
    'SearchHelp': av.AccessibleViewProviderId.SearchHelp,
    'TerminalFindHelp': av.AccessibleViewProviderId.TerminalFindHelp,
    'WebviewFindHelp': av.AccessibleViewProviderId.WebviewFindHelp,
    'OutputFindHelp': av.AccessibleViewProviderId.OutputFindHelp,
    'ChatFindHelp': av.AccessibleViewProviderId.ChatFindHelp,
    'ChatViewSessionsList': av.AccessibleViewProviderId.ChatViewSessionsList,
    'ProblemsFilterHelp': av.AccessibleViewProviderId.ProblemsFilterHelp,
    'SessionsChat': av.AccessibleViewProviderId.SessionsChat,
    'ArtifactDetails': av.AccessibleViewProviderId.ArtifactDetails,
    'SessionsStorageCleanup': av.AccessibleViewProviderId.SessionsStorageCleanup,
    'SessionsChanges': av.AccessibleViewProviderId.SessionsChanges,
    'EmptyFileEditorSearch': av.AccessibleViewProviderId.EmptyFileEditorSearch,
    'SessionsListNotification': av.AccessibleViewProviderId.SessionsListNotification,
    'SessionsGetStarted': av.AccessibleViewProviderId.SessionsGetStarted,
    'SessionCanvas': av.AccessibleViewProviderId.SessionCanvas,
    'Survey': av.AccessibleViewProviderId.Survey,
    'Automations': av.AccessibleViewProviderId.Automations,
    'AgentsWindowExtensions': av.AccessibleViewProviderId.AgentsWindowExtensions,
    'ConnectionDiagnostics': av.AccessibleViewProviderId.ConnectionDiagnostics,
    'BrowserElementCommenting': av.AccessibleViewProviderId.BrowserElementCommenting,
    'ScreenshotTool': av.AccessibleViewProviderId.ScreenshotTool,
    'ChatPetAchievements': av.AccessibleViewProviderId.ChatPetAchievements,
    'ChatPetJumpGame': av.AccessibleViewProviderId.ChatPetJumpGame,
    };
    expect(providerIds,
        _exp(_map(enums['AccessibleViewProviderId'])));
    expect(
        <String, String>{
          'Help': av.AccessibleViewType.Help,
          'View': av.AccessibleViewType.View,
        },
        _exp(_map(enums['AccessibleViewType'])));
    expect(
        <String, String>{
          'Previous': av.NavigationType.Previous,
          'Next': av.NavigationType.Next,
        },
        _exp(_map(enums['NavigationType'])));
    expect(av.IAccessibleViewService.toString(), truth['decorator']);
  });

  test('batch199 AccessibleContentProvider exposes every field', () {
    final Map<String, dynamic> expected =
        _map(truth['accessibleContentProvider']);
    final List<String> disposals = <String>[];
    final List<String> calls = <String>[];

    final av.AccessibleContentProvider provider = av.AccessibleContentProvider(
      av.AccessibleViewProviderId.Editor,
      av.IAccessibleViewOptions(
        type: av.AccessibleViewType.View,
        language: 'markdown',
        position: 'bottom',
      ),
      () => 'hello content',
      () => calls.add('close'),
      'editor.accessibilitySupport',
      () {
        calls.add('open');
        return _DisposableStub(() => calls.add('onOpen-disposed'));
      },
      <IAction>[_ActionStub('action.one'), _ActionStub('action.two')],
      () => 'next content',
      () => 'previous content',
      _noopEvent<void>(),
      (dynamic _) => calls.add('keydown'),
      () => <av.IAccessibleViewSymbol>[
        av.IAccessibleViewSymbol(label: 'symbol-one'),
        av.IAccessibleViewSymbol(label: 'symbol-two'),
      ],
      _noopEvent<void>(),
    );
    provider.onDispose = () => disposals.add('onDispose');

    expect(_snapshot(provider), _exp(_map(expected['created'])));

    provider.dispose();
    expect(disposals, _exp(_list(expected['afterFirstDispose'])));
    provider.dispose();
    expect(disposals, _exp(_list(expected['afterSecondDispose'])));
    expect(calls, _exp(_list(expected['onCloseFired'])));
    expect(_isDisposable(provider), expected['isDisposableAtRuntime']);
  });

  test('batch199 AccessibleContentProvider handles missing options', () {
    final Map<String, dynamic> expected =
        _map(truth['accessibleContentProviderMinimal']);
    final av.AccessibleContentProvider provider = av.AccessibleContentProvider(
      av.AccessibleViewProviderId.QuickChat,
      av.IAccessibleViewOptions(type: av.AccessibleViewType.Help),
      () => 'help content',
      () {},
      'chat.accessibilityHelp',
    );
    provider.onDispose = () {};
    expect(_snapshot(provider), _exp(_map(expected)));
    provider.dispose();
  });

  test('batch199 ExtensionContentProvider matches truth', () {
    final Map<String, dynamic> expected =
        _map(truth['extensionContentProvider']);
    final av.ExtensionContentProvider provider = av.ExtensionContentProvider(
      'extension.provider',
      av.IAccessibleViewOptions(
        type: av.AccessibleViewType.View,
        readMoreUrl: 'https://example.com',
      ),
      () => 'extension content',
      () {},
      () => null,
      () => 'ext next',
      () => 'ext previous',
      <IAction>[_ActionStub('ext.action')],
      _noopEvent<void>(),
    );

    expect(<String, Object?>{
      'id': provider.id,
      'options': _options(provider.options),
      'provideContent': provider.provideContent(),
      'provideNextContent': provider.provideNextContent?.call(),
      'providePreviousContent': provider.providePreviousContent?.call(),
      'actions': provider.actions?.map((IAction a) => a.id).toList(),
      'hasOnOpen': provider.onOpen != null,
      'hasOnDidChangeContent': provider.onDidChangeContent != null,
      'hasVerbositySettingKey':
          (provider as Object) is av.IAccessibleViewContentProvider,
    }, _exp(_map(expected)));
  });

  test('batch199 isIAccessibleViewContentProvider matrix matches truth', () {
    final List<dynamic> cases = _list(truth['predicate']);
    final Map<String, Object?> payloads = <String, Object?>{
      'null': null,
      'number': 42,
      'string': 'provider',
      'emptyObject': <String, Object?>{},
      'idOnly': <String, Object?>{'id': 'x'},
      'idAndOptions': <String, Object?>{'id': 'x', 'options': <String, Object?>{}},
      'missingOnClose': <String, Object?>{
        'id': 'x',
        'options': <String, Object?>{},
        'provideContent': () => '',
        'verbositySettingKey': 'k',
      },
      'provideContentNotFunction': <String, Object?>{
        'id': 'x',
        'options': <String, Object?>{},
        'provideContent': 'no',
        'onClose': () {},
        'verbositySettingKey': 'k',
      },
      'emptyId': <String, Object?>{
        'id': '',
        'options': <String, Object?>{},
        'provideContent': () => '',
        'onClose': () {},
        'verbositySettingKey': 'k',
      },
      'verbosityNotString': <String, Object?>{
        'id': 'x',
        'options': <String, Object?>{},
        'provideContent': () => '',
        'onClose': () {},
        'verbositySettingKey': 42,
      },
      'full': <String, Object?>{
        'id': 'plain',
        'options': <String, Object?>{'type': av.AccessibleViewType.View},
        'provideContent': () => 'plain',
        'onClose': () {},
        'verbositySettingKey': 'plain.key',
      },
      'emptyOptionsFalsy': <String, Object?>{
        'id': 'x',
        'options': null,
        'provideContent': () => '',
        'onClose': () {},
        'verbositySettingKey': 'k',
      },
      'classInstance': av.AccessibleContentProvider(
        av.AccessibleViewProviderId.Editor,
        av.IAccessibleViewOptions(type: av.AccessibleViewType.Help),
        () => '',
        () {},
        'k',
      ),
      'extensionInstance': av.ExtensionContentProvider(
        'ext',
        av.IAccessibleViewOptions(type: av.AccessibleViewType.Help),
        () => '',
        () {},
      ),
    };

    final List<Map<String, Object?>> actual = cases
        .map((dynamic entry) => _map(entry))
        .map((Map<String, dynamic> entry) => <String, Object?>{
              'name': entry['name'],
              'result':
                  av.isIAccessibleViewContentProvider(payloads[entry['name']]),
            })
        .toList();

    expect(actual, _exp(cases.map((dynamic e) => _map(e)).toList()));
  });
}

class _DisposableStub implements lifecycle.IDisposable {
  _DisposableStub(this._onDispose);

  final void Function() _onDispose;

  @override
  void dispose() => _onDispose();
}

class _ActionStub implements IAction {
  _ActionStub(this.id);

  @override
  final String id;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
