import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/resources.dart' show IExtUri;
import '../lib/src/monaco/base/common/uri.dart' show URI, UriComponents;
import '../lib/src/monaco/platform/configuration/common/configuration.dart'
    show IConfigurationServiceType;
import '../lib/src/monaco/platform/editor/common/editor.dart' as ed;
import '../lib/src/monaco/platform/uriIdentity/common/uriIdentity.dart'
    show IUriIdentityServiceType;
import '../lib/src/monaco/platform/window/common/window.dart' as win;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

List<dynamic> _list(dynamic value) => value as List<dynamic>;

Map<String, Object?> _project(Map<String, Object?> source) =>
    <String, Object?>{for (final MapEntry<String, Object?> e in source.entries) if (e.value != null) e.key: e.value};

Map<String, Object?> _officialLink(win.IAgentsWindowNewSessionLink? link) {
  if (link == null) return <String, Object?>{};
  return _project(<String, Object?>{
    'workspace': link.workspaceUri?.toString(true),
    'draft': link.draft.toMap(),
  });
}

/// Mirrors JSON.stringify(URI) from the Node truth harness.
Map<String, Object?> _uriJson(URI uri) => <String, Object?>{
      '\$mid': 1,
      'scheme': uri.scheme,
      'authority': uri.authority,
      'path': uri.path,
      'query': Uri.decodeComponent(uri.query),
    };

class _ExtUri implements IExtUri {
  @override
  bool isEqual(URI? uri1, URI? uri2, [bool ignoreFragment = false]) {
    if (identical(uri1, uri2)) return true;
    if (uri1 == null || uri2 == null) return false;
    return uri1.toString(true) == uri2.toString(true);
  }

  dynamic noSuchMethod(Invocation invocation) => null;
}

class _UriIdentity implements IUriIdentityServiceType {
  @override
  IExtUri get extUri => _ExtUri();

  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Config implements IConfigurationServiceType {
  _Config(this.values);

  final Map<String, Object?> values;

  @override
  Object? getValue$1(String section) => values[section];

  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Openable {
  _Openable(this.kind);

  final String kind;

  URI? get workspaceUri => kind == 'workspace' ? URI.parse('file:///w') : null;
  URI? get folderUri => kind == 'folder' ? URI.parse('file:///f') : null;
  URI? get fileUri => kind == 'file' ? URI.parse('file:///x') : null;
}

void main() {
  final Map<String, dynamic> truth = _map(
    jsonDecode(File('tool/ts2dart/batch187_truth.json').readAsStringSync()),
  );

  group('batch187 declarations', () {
    test('editor enums match TypeScript AST truth', () {
      final Map<String, dynamic> declared =
          _map(_map(truth['declarations'])['editorEnums']);
      expect(<String, Object?>{
        'EditorActivation': <String, Object?>{
          'ACTIVATE': ed.EditorActivation.ACTIVATE,
          'RESTORE': ed.EditorActivation.RESTORE,
          'PRESERVE': ed.EditorActivation.PRESERVE,
        },
        'EditorResolution': <String, Object?>{
          'EXCLUSIVE_ONLY': ed.EditorResolution.EXCLUSIVE_ONLY,
        },
        'EditorOpenSource': <String, Object?>{
          'API': ed.EditorOpenSource.API,
          'USER': ed.EditorOpenSource.USER,
        },
        'ViewColumn': <String, Object?>{
          'Active': ed.ViewColumn.Active,
          'Beside': ed.ViewColumn.Beside,
          'One': ed.ViewColumn.One,
          'Two': ed.ViewColumn.Two,
          'Three': ed.ViewColumn.Three,
          'Four': ed.ViewColumn.Four,
          'Five': ed.ViewColumn.Five,
          'Six': ed.ViewColumn.Six,
          'Seven': ed.ViewColumn.Seven,
          'Eight': ed.ViewColumn.Eight,
          'Nine': ed.ViewColumn.Nine,
        },
        'TextEditorSelectionRevealType': <String, Object?>{
          'Center': ed.TextEditorSelectionRevealType.Center,
          'CenterIfOutsideViewport':
              ed.TextEditorSelectionRevealType.CenterIfOutsideViewport,
          'NearTop': ed.TextEditorSelectionRevealType.NearTop,
          'NearTopIfOutsideViewport':
              ed.TextEditorSelectionRevealType.NearTopIfOutsideViewport,
        },
        'TextEditorSelectionSource': <String, Object?>{
          'PROGRAMMATIC': ed.TextEditorSelectionSource.PROGRAMMATIC,
          'NAVIGATION': ed.TextEditorSelectionSource.NAVIGATION,
          'JUMP': ed.TextEditorSelectionSource.JUMP,
        },
      }, equals(declared));
    });

    test('window enums match TypeScript AST truth', () {
      final Map<String, dynamic> declared =
          _map(_map(truth['declarations'])['windowEnums']);
      expect(<String, Object?>{
        'AgentsWindowOpenSource': <String, Object?>{
          'CommandPalette': win.AgentsWindowOpenSource.CommandPalette,
          'KeyboardShortcut': win.AgentsWindowOpenSource.KeyboardShortcut,
          'TitleBar': win.AgentsWindowOpenSource.TitleBar,
          'ChatTitleBar': win.AgentsWindowOpenSource.ChatTitleBar,
          'ChatViewTitle': win.AgentsWindowOpenSource.ChatViewTitle,
          'CurrentChatHandoff': win.AgentsWindowOpenSource.CurrentChatHandoff,
          'EmptyWorkspaceCurrentChatHandoff':
              win.AgentsWindowOpenSource.EmptyWorkspaceCurrentChatHandoff,
          'ParallelWorkEmptyChatHandoff':
              win.AgentsWindowOpenSource.ParallelWorkEmptyChatHandoff,
          'ContinueInAgentsWindow':
              win.AgentsWindowOpenSource.ContinueInAgentsWindow,
          'ParallelWorkSameWindow':
              win.AgentsWindowOpenSource.ParallelWorkSameWindow,
          'ParallelWorkAllWindows':
              win.AgentsWindowOpenSource.ParallelWorkAllWindows,
          'WelcomeTryOut': win.AgentsWindowOpenSource.WelcomeTryOut,
          'CommandLine': win.AgentsWindowOpenSource.CommandLine,
          'Link': win.AgentsWindowOpenSource.Link,
          'AgentsLauncher': win.AgentsWindowOpenSource.AgentsLauncher,
          'Unknown': win.AgentsWindowOpenSource.Unknown,
        },
        'MenuSettings': <String, Object?>{
          'MenuStyle': win.MenuSettings.MenuStyle,
          'MenuBarVisibility': win.MenuSettings.MenuBarVisibility,
        },
        'MenuStyleConfiguration': <String, Object?>{
          'CUSTOM': win.MenuStyleConfiguration.CUSTOM,
          'NATIVE': win.MenuStyleConfiguration.NATIVE,
          'INHERIT': win.MenuStyleConfiguration.INHERIT,
        },
        'TitleBarSetting': <String, Object?>{
          'TITLE_BAR_STYLE': win.TitleBarSetting.TITLE_BAR_STYLE,
          'CUSTOM_TITLE_BAR_VISIBILITY':
              win.TitleBarSetting.CUSTOM_TITLE_BAR_VISIBILITY,
        },
        'TitlebarStyle': <String, Object?>{
          'NATIVE': win.TitlebarStyle.NATIVE,
          'CUSTOM': win.TitlebarStyle.CUSTOM,
        },
        'WindowControlsStyle': <String, Object?>{
          'NATIVE': win.WindowControlsStyle.NATIVE,
          'CUSTOM': win.WindowControlsStyle.CUSTOM,
          'HIDDEN': win.WindowControlsStyle.HIDDEN,
        },
        'CustomTitleBarVisibility': <String, Object?>{
          'AUTO': win.CustomTitleBarVisibility.AUTO,
          'WINDOWED': win.CustomTitleBarVisibility.WINDOWED,
          'NEVER': win.CustomTitleBarVisibility.NEVER,
        },
      }, equals(declared));
    });
  });

  group('batch187 editor runtime truth', () {
    final Map<String, dynamic> editorTruth = _map(truth['editor']);

    test('exports and runtime enums', () {
      expect(
        <String>[
          'EditorActivation',
          'EditorOpenSource',
          'EditorResolution',
          'TextEditorSelectionRevealType',
          'TextEditorSelectionSource',
          'ViewColumn',
          'canMoveModalEditorToEditorArea',
          'isModalEditorOptionsProvider',
          'isResolvedEditorModel',
          'isTextEditorDiffInformationEqual',
        ]..sort(),
        equals(editorTruth['exports']),
      );
      final Map<String, dynamic> runtime =
          _map(editorTruth['runtimeEnums']);
      expect(_map(runtime['ViewColumn'])['Active'], equals(-1));
      expect(_map(runtime['ViewColumn'])['Beside'], equals(-2));
      expect(_map(runtime['EditorActivation'])['ACTIVATE'], equals(1));
    });

    test('resolvable model and modal guards', () {
      final List<dynamic> models = _list(editorTruth['models']);
      final List<Object?> inputs = <Object?>[
        null, // TS null
        null, // TS undefined
        _ResolvedModel(<String, Object?>{}),
        _ResolvedModel(<String, Object?>{'resolve': () {}}),
        _ResolvedModel(<String, Object?>{'isResolved': () => true}),
        _ResolvedModel(<String, Object?>{
          'resolve': () {},
          'isResolved': () => false,
        }),
      ];
      expect(inputs.length, equals(models.length));
      for (int i = 0; i < inputs.length; i++) {
        expect(
          ed.isResolvedEditorModel(inputs[i]),
          equals(_map(models[i])['result']),
        );
      }

      final List<dynamic> modal = _list(editorTruth['modal']);
      final List<Object?> objects = <Object?>[
        null, // TS null
        null, // TS undefined
        _NoProvider(),
        _Provider(<String, Object?>{}),
        _Provider(<String, Object?>{'canMoveToEditorArea': false}),
        _Provider(<String, Object?>{'canMoveToEditorArea': true}),
      ];
      expect(objects.length, equals(modal.length));
      for (int i = 0; i < objects.length; i++) {
        expect(
          ed.isModalEditorOptionsProvider(objects[i]),
          equals(_map(modal[i])['provider']),
        );
        expect(
          ed.canMoveModalEditorToEditorArea(objects[i]),
          equals(_map(modal[i])['canMove']),
        );
      }
    });

    test('diff information equality', () {
      final URI a = URI.parse('file:///a');
      final URI b = URI.parse('file:///b');
      final List<ed.ITextEditorDiffInformation?> diffs =
          <ed.ITextEditorDiffInformation?>[
        null,
        ed.ITextEditorDiffInformation(
          documentVersion: 1,
          original: null,
          modified: a,
          changes: const <ed.ITextEditorChange>[],
        ),
        ed.ITextEditorDiffInformation(
          documentVersion: 2,
          original: null,
          modified: a,
          changes: const <ed.ITextEditorChange>[],
        ),
        ed.ITextEditorDiffInformation(
          documentVersion: 1,
          original: a,
          modified: b,
          changes: const <ed.ITextEditorChange>[],
        ),
        ed.ITextEditorDiffInformation(
          documentVersion: 1,
          original: null,
          modified: a,
          changes: <ed.ITextEditorChange>[<num>[1, 2, 3, 4]],
        ),
        ed.ITextEditorDiffInformation(
          documentVersion: 1,
          original: null,
          modified: a,
          changes: <ed.ITextEditorChange>[<num>[1, 2, 3, 5]],
        ),
      ];
      final List<dynamic> truthDiffs = _list(editorTruth['diffs']);
      final IUriIdentityServiceType service = _UriIdentity();
      expect(
        ed.isTextEditorDiffInformationEqual(service, null, null),
        equals(truthDiffs[0]),
      );
      expect(
        ed.isTextEditorDiffInformationEqual(service, diffs[1], diffs[1]),
        equals(truthDiffs[1]),
      );
      expect(
        ed.isTextEditorDiffInformationEqual(service, diffs[1], diffs[2]),
        equals(truthDiffs[2]),
      );
      expect(
        ed.isTextEditorDiffInformationEqual(service, diffs[3], diffs[1]),
        equals(truthDiffs[3]),
      );
      expect(
        ed.isTextEditorDiffInformationEqual(service, diffs[4], diffs[4]),
        equals(truthDiffs[4]),
      );
      expect(
        ed.isTextEditorDiffInformationEqual(service, diffs[4], diffs[5]),
        equals(truthDiffs[5]),
      );
    });
  });

  group('batch187 window runtime truth', () {
    final Map<String, dynamic> windowTruth = _map(truth['window']);

    test('constants and predicates', () {
      expect(
        <String, Object?>{
          'WindowMinimumSize': <String, Object?>{
            'WIDTH': win.WindowMinimumSize.WIDTH,
            'WIDTH_WITH_VERTICAL_PANEL':
                win.WindowMinimumSize.WIDTH_WITH_VERTICAL_PANEL,
            'HEIGHT': win.WindowMinimumSize.HEIGHT,
          },
          'CHAT_SESSION_LINK_QUERY_PARAM': win.CHAT_SESSION_LINK_QUERY_PARAM,
          'COPILOT_CLI_SESSION_LINK_QUERY_PARAM':
              win.COPILOT_CLI_SESSION_LINK_QUERY_PARAM,
          'AGENTS_LAUNCHER_IPC_CHANNEL': win.AGENTS_LAUNCHER_IPC_CHANNEL,
          'DEFAULT_EMPTY_WINDOW_SIZE': win.DEFAULT_EMPTY_WINDOW_SIZE,
          'DEFAULT_WORKSPACE_WINDOW_SIZE': win.DEFAULT_WORKSPACE_WINDOW_SIZE,
          'DEFAULT_AUX_WINDOW_SIZE': win.DEFAULT_AUX_WINDOW_SIZE,
        },
        equals(_map(windowTruth['constants'])),
      );

      final List<dynamic> predicates = _list(windowTruth['predicates']);
      final List<bool> actual = <bool>[
        win.isOpenedAuxiliaryWindow(_AuxWindow(null)),
        win.isOpenedAuxiliaryWindow(_AuxWindow(2)),
        win.isAgentsWindowDraft(_Draft('x', '[]')),
        win.isAgentsWindowDraft(_Draft('x', null)),
        win.isAgentsWindowDraft(null),
        win.isWorkspaceToOpen(_Openable('workspace')),
        win.isFolderToOpen(_Openable('folder')),
        win.isFileToOpen(_Openable('file')),
        win.isAgentsWindowOpenSource('commandPalette'),
        win.isAgentsWindowOpenSource('bogus'),
      ];
      for (int i = 0; i < predicates.length; i++) {
        expect(actual[i], equals(_list(predicates[i])[1]));
      }
    });

    test('configuration matrix', () {
      final scenarios = <Map<String, Object?>>[
        <String, Object?>{
          'name': 'web',
          'flags': <String, Object?>{'web': true, 'native': false, 'mac': false},
          'config': <String, Object?>{'titleBarStyle': 'native', 'menuStyle': 'native', 'nativeFullScreen': false},
        },
        <String, Object?>{
          'name': 'mac-native-tabs',
          'flags': <String, Object?>{'web': false, 'native': true, 'mac': true},
          'config': <String, Object?>{'titleBarStyle': 'custom', 'nativeTabs': true, 'menuStyle': 'native'},
        },
        <String, Object?>{
          'name': 'mac-simple-fullscreen',
          'flags': <String, Object?>{'web': false, 'native': true, 'mac': true},
          'config': <String, Object?>{'titleBarStyle': 'custom', 'nativeFullScreen': false},
        },
        <String, Object?>{
          'name': 'win-native-title',
          'flags': <String, Object?>{'web': false, 'native': true, 'mac': false},
          'config': <String, Object?>{'titleBarStyle': 'native', 'menuStyle': 'native', 'controlsStyle': 'custom'},
        },
        <String, Object?>{
          'name': 'win-custom',
          'flags': <String, Object?>{'web': false, 'native': true, 'mac': false},
          'config': <String, Object?>{'titleBarStyle': 'custom', 'menuStyle': 'custom', 'controlsStyle': 'hidden', 'nativeFullScreen': false},
        },
        <String, Object?>{
          'name': 'linux-inherit-menu',
          'flags': <String, Object?>{'web': false, 'native': true, 'mac': false},
          'config': <String, Object?>{'titleBarStyle': 'custom', 'menuStyle': 'inherit'},
        },
        <String, Object?>{
          'name': 'empty',
          'flags': <String, Object?>{'web': false, 'native': true, 'mac': false},
          'config': <String, Object?>{},
        },
      ];
      final List<dynamic> truths = _list(windowTruth['configs']);
      for (int i = 0; i < scenarios.length; i++) {
        final Map<String, Object?> scenario = scenarios[i];
        final Map<String, Object?> flags = _map(scenario['flags']);
        win.windowIsWeb = () => flags['web'] == true;
        win.windowIsMacintosh = () => flags['mac'] == true;
        win.windowIsNative = () => flags['native'] == true;
        final Map<String, Object?> config = _map(scenario['config']);
        final _Config service = _Config(<String, Object?>{
          'window': config,
          win.MenuSettings.MenuBarVisibility: config['menuBarVisibility'],
        });
        final Map<String, Object?> actual = _project(<String, Object?>{
          'name': scenario['name'],
          'hasNativeContextMenu': win.hasNativeContextMenu(service),
          'hasNativeMenu': win.hasNativeMenu(service),
          'menuBarVisibility': win.getMenuBarVisibility(service),
          'hasCustomTitlebar': win.hasCustomTitlebar(service),
          'hasNativeTitlebar': win.hasNativeTitlebar(service),
          'titleBarStyle': win.getTitleBarStyle(service),
          'windowControlsStyle': win.getWindowControlsStyle(service),
          'useWindowControlsOverlay': win.useWindowControlsOverlay(service),
          'useNativeFullScreen': win.useNativeFullScreen(service),
        });
        expect(actual, equals(_map(truths[i])));
      }
      win.windowIsWeb = () => false;
      win.windowIsMacintosh = () => false;
      win.windowIsNative = () => true;
    });

    test('macOS controls and zoom factors', () {
      final List<dynamic> controls = _list(windowTruth['macControls']);
      final List<List<Object?>> cases = <List<Object?>>[
        <Object?>[35, '24.0.0'],
        <Object?>[44, '24.0.0'],
        <Object?>[16, '24.0.0'],
        <Object?>[35, '25.0.0'],
        <Object?>[44, '25.0.0'],
        <Object?>[14, '25.0.0'],
      ];
      for (int i = 0; i < cases.length; i++) {
        final win.IPoint? point = win.getMacOSWindowControlsPosition(
          cases[i][0] as num,
          cases[i][1] as String,
        );
        if (controls[i] == null) {
          expect(point, isNull);
        } else {
          expect(point, isNotNull);
          expect(point!.toMap(), equals(_map(controls[i])));
        }
      }
      final List<dynamic> zoom = _list(windowTruth['zoom']);
      for (int level = -1; level <= 3; level++) {
        expect(
          win.zoomLevelToZoomFactor(level),
          closeTo((zoom[level + 1] as num).toDouble(), 1e-12),
        );
      }
    });
  });

  group('batch187 official window truth', () {
    for (final dynamic rawCase in _list(truth['official'])) {
      final Map<String, dynamic> testCase = _map(rawCase);
      final String name = testCase['name'] as String;
      final Map<String, dynamic> assertion = _map(
        _list(testCase['assertions']).first as Map,
      );
      final dynamic expected = assertion['expected'];

      test(name, () {
        Object? actual;
        if (name.startsWith('preserves legacy macOS')) {
          actual = <String, Object?>{
            'beforeTahoe': <Object?>[
              win.getMacOSWindowControlsPosition(35, '24.0.0')?.toMap(),
              win.getMacOSWindowControlsPosition(44, '24.0.0')?.toMap(),
              win.getMacOSWindowControlsPosition(16, '24.0.0')?.toMap(),
            ],
            'tahoe': <Object?>[
              win.getMacOSWindowControlsPosition(35, '25.0.0')?.toMap(),
              win.getMacOSWindowControlsPosition(44, '25.0.0')?.toMap(),
              win.getMacOSWindowControlsPosition(14, '25.0.0')?.toMap(),
            ],
          };
        } else if (name.startsWith('keeps macOS traffic lights')) {
          actual = <String, Object?>{
            'beforeTahoe': <Object?>[
              win.getMacOSWindowControlsPosition(35, '24.0.0', 10)?.toMap(),
              win.getMacOSWindowControlsPosition(44, '24.0.0', 10)?.toMap(),
              win.getMacOSWindowControlsPosition(35, '24.0.0', 10)?.toMap(),
            ],
            'tahoe': <Object?>[
              win.getMacOSWindowControlsPosition(35, '25.0.0', 11)?.toMap(),
              win.getMacOSWindowControlsPosition(44, '25.0.0', 11)?.toMap(),
              win.getMacOSWindowControlsPosition(35, '25.0.0', 11)?.toMap(),
            ],
            'zoomedBeforeTahoe': <Object?>[
              win.getMacOSWindowControlsPosition(44, '24.0.0', 15)?.toMap(),
              win.getMacOSWindowControlsPosition(55, '24.0.0', 15)?.toMap(),
              win.getMacOSWindowControlsPosition(44, '24.0.0', 15)?.toMap(),
            ],
            'zoomedTahoe': <Object?>[
              win.getMacOSWindowControlsPosition(44, '25.0.0', 16)?.toMap(),
              win.getMacOSWindowControlsPosition(55, '25.0.0', 16)?.toMap(),
              win.getMacOSWindowControlsPosition(44, '25.0.0', 16)?.toMap(),
            ],
          };
        } else if (name.startsWith('parses an external Agents Window new-session link without')) {
          actual = _officialLink(win.parseExternalAgentsWindowNewSessionLinkUri(
            'vscode-insiders://agents/new?prompt=Draft%20without%20a%20workspace',
            'vscode-insiders',
          ));
        } else if (name.startsWith('parses an external Agents Window')) {
          final URI link = URI.from(
            UriComponents(
              scheme: 'vscode-insiders',
              authority: 'agents',
              path: '/new',
              query: 'workspace=file%3A%2F%2F%2FUsers%2Fexample%2Fproject&'
                  'prompt=Fix+the+tests+%26+explain+why',
            ),
          );
          actual = _officialLink(win.parseExternalAgentsWindowNewSessionLinkUri(
            link,
            'vscode-insiders',
          ));
        } else if (name.startsWith('rejects invalid external')) {
          actual = <Object?>[
            win.parseExternalAgentsWindowNewSessionLinkUri(
              'vscode://agents/new?workspace=file%3A%2F%2F%2Fproject&prompt=Fix',
              'vscode-insiders',
            ),
            win.parseExternalAgentsWindowNewSessionLinkUri(
              'vscode-insiders://extensions/new?workspace=file%3A%2F%2F%2Fproject&prompt=Fix',
              'vscode-insiders',
            ),
            win.parseExternalAgentsWindowNewSessionLinkUri(
              'vscode-insiders://agents/session?workspace=file%3A%2F%2F%2Fproject&prompt=Fix',
              'vscode-insiders',
            ),
            win.parseExternalAgentsWindowNewSessionLinkUri(
              'vscode-insiders://agents/new?workspace=file%3A%2F%2F%2Fproject',
              'vscode-insiders',
            ),
            win.parseExternalAgentsWindowNewSessionLinkUri(
              'vscode-insiders://agents/new?workspace=&prompt=Fix',
              'vscode-insiders',
            ),
            win.parseExternalAgentsWindowNewSessionLinkUri(
              'vscode-insiders://agents/new?workspace=project&prompt=Fix',
              'vscode-insiders',
            ),
          ].map((Object? value) => value == null
              ? null
              : (value as win.IAgentsWindowNewSessionLink).toMap()).toList();
        } else if (name.startsWith('extracts the chat session')) {
          actual = <Object?>[
            'vscode://file/c:/project?windowId=_blank&copilotCliSession=0b6f9a4e-1c2d-4e5f-8a9b-0c1d2e3f4a5b',
            'vscode-insiders://file/home/me/project?copilotCliSession=my_session-1',
            'vscode://vscode-remote/wsl+ubuntu/home/me/project?copilotCliSession=abc&gitRef=main',
            'vscode://file/home/me/project?session=copilotcli%3A%2Fabc',
            'vscode://file/home/me/project?session=copilotcli%3A%2Fabc&copilotCliSession=def',
          ].map((Object? link) =>
              win.extractChatSessionToOpen(URI.parse(link as String)).toMap())
              .toList();
        } else if (name.startsWith('removes invalid chat session')) {
          actual = <Object?>[
            'vscode://file/home/me/project?copilotCliSession=../../etc',
            'vscode://file/home/me/project?copilotCliSession=a%2Fb',
            'vscode://file/home/me/project?copilotCliSession=',
            'vscode://file/home/me/project?session=',
          ].map((Object? link) =>
              win.extractChatSessionToOpen(URI.parse(link as String)).toMap())
              .toList();
        } else if (name.startsWith('leaves a protocol link')) {
          final URI link = URI.parse(
            'vscode://vscode-remote/ssh-remote+host/home/me/project?windowId=_blank&a=b%20c',
          );
          actual = _uriJson(win.extractChatSessionToOpen(link).uri);
        } else if (name.startsWith('validates Copilot CLI')) {
          actual = <String>[
            '0b6f9a4e-1c2d-4e5f-8a9b-0c1d2e3f4a5b',
            'my_session-1',
            '',
            'a/b',
            'a.b',
            'a b',
            'é',
            'a' * 256,
            'a' * 257,
          ].map(win.isValidCopilotCliSessionId).toList();
        } else {
          fail('unexpected official case: $name');
        }

        expect(actual, equals(expected), reason: 'official TS case: $name');
        expect(assertion['pass'], isTrue);
      });
    }
  });
}

class _CallableModel {
  _CallableModel(this.values);

  final Map<String, Object?> values;

  dynamic noSuchMethod(Invocation invocation) {
    final String name = invocation.memberName.toString().replaceFirst('Symbol(', '').replaceFirst(')', '');
    if (invocation.isGetter) return values[name];
    if (invocation.isMethod) {
      final Object? fn = values[name];
      if (fn is Function) return Function.apply(fn as Function, invocation.positionalArguments);
    }
    return null;
  }
}

class _Provider {
  _Provider(this.options);

  final Map<String, Object?> options;

  ed.IModalEditorOptions? getModalEditorOptions() => ed.IModalEditorOptions(
        canMoveToEditorArea: options['canMoveToEditorArea'] as bool?,
      );
}

class _NoProvider {}

class _ResolvedModel {
  _ResolvedModel(this.values);

  final Map<String, Object?> values;

  Object? get resolve => values['resolve'];
  Object? get isResolved => values['isResolved'];
}

class _Draft {
  _Draft(this.inputText, this.attachments);

  final Object? inputText;
  final Object? attachments;
}

class _AuxWindow {
  _AuxWindow(this.parentId);

  final Object? parentId;
}
