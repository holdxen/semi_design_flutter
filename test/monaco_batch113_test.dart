// Data-driven verification of batch113 ports against real TS runtime truth:
//   base/browser/ui/widget.ts
//   editor/.../colorPickerInsertButton.ts
//   base/parts/sandbox/common/sandboxTypes.ts
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart' as dom;
import 'package:semi_design_flutter/src/monaco/base/browser/keyboardEvent.dart'
    as keyboard;
import 'package:semi_design_flutter/src/monaco/base/browser/mouseEvent.dart'
    as mouse;
import 'package:semi_design_flutter/src/monaco/base/browser/touch.dart'
    as touch;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/widget.dart';
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    as lifecycle;
import 'package:semi_design_flutter/src/monaco/base/common/product.dart'
    as product;
import 'package:semi_design_flutter/src/monaco/base/parts/sandbox/common/sandboxTypes.dart'
    as sandbox;
import 'package:semi_design_flutter/src/monaco/editor/contrib/colorPicker/browser/colorPickerParts/colorPickerInsertButton.dart'
    as insertButton;

final Map<String, dynamic> truth =
    (jsonDecode(File('tool/ts2dart/batch113_truth.json').readAsStringSync())
            as Map)
        .cast<String, dynamic>();

List<List<Object?>> _list(List<dynamic> src) =>
    src.map((dynamic e) => (e as List<dynamic>).cast<Object?>()).toList();

class _RecElement extends dom.DomElement {
  final String nodeName;
  final List<List<Object?>> registrations = <List<Object?>>[];
  final List<List<Object?>> disposals = <List<Object?>>[];
  final Map<void Function(dom.DomEvent e), int> _ids =
      <void Function(dom.DomEvent e), int>{};
  static int _nextId = 1;

  _RecElement(this.nodeName) : super('DIV');

  @override
  void addEventListener(String type, void Function(dom.DomEvent e) handler,
      [Object? options]) {
    final int id = _nextId++;
    _ids[handler] = id;
    registrations.add(<Object?>[nodeName, type, id]);
    super.addEventListener(type, handler, options);
  }

  @override
  void removeEventListener(String type, void Function(dom.DomEvent e) handler,
      [Object? options]) {
    final int? id = _ids[handler];
    if (id != null) disposals.add(<Object?>['listener', id]);
    super.removeEventListener(type, handler, options);
  }
}

class _ProbeWidget extends Widget {
  void pOnclick(dom.DomElement n, void Function(mouse.IMouseEvent e) l) =>
      onclick(n, l);
  void pOnmousedown(dom.DomElement n, void Function(mouse.IMouseEvent e) l) =>
      onmousedown(n, l);
  void pOnmouseover(dom.DomElement n, void Function(mouse.IMouseEvent e) l) =>
      onmouseover(n, l);
  void pOnmouseleave(dom.DomElement n, void Function(mouse.IMouseEvent e) l) =>
      onmouseleave(n, l);
  void pOnkeydown(dom.DomElement n, void Function(keyboard.IKeyboardEvent e) l) =>
      onkeydown(n, l);
  void pOnkeyup(dom.DomElement n, void Function(keyboard.IKeyboardEvent e) l) =>
      onkeyup(n, l);
  void pOninput(dom.DomElement n, void Function(dom.DomEvent e) l) =>
      oninput(n, l);
  void pOnblur(dom.DomElement n, void Function(dom.DomEvent e) l) =>
      onblur(n, l);
  void pOnfocus(dom.DomElement n, void Function(dom.DomEvent e) l) =>
      onfocus(n, l);
  void pOnchange(dom.DomElement n, void Function(dom.DomEvent e) l) =>
      onchange(n, l);
  lifecycle.IDisposable pIgnoreGesture(dom.DomElement n) => ignoreGesture(n);
}

void main() {
  group('batch113 widget.ts', () {
    test('DOM listener registration / wrapping / dispose matches TS truth', () {
      touch.touchDeviceProvider = () => true;
      final w = _ProbeWidget();
      final Map<String, _RecElement> nodes = <String, _RecElement>{};
      for (final String name in <String>[
        'click',
        'mousedown',
        'mouseover',
        'mouseleave',
        'keydown',
        'keyup',
        'input',
        'blur',
        'focus',
        'change'
      ]) {
        nodes[name] = _RecElement(name);
      }
      final List<List<Object?>> received = <List<Object?>>[];
      void Function(mouse.IMouseEvent e) mouseSink(String label) =>
          (mouse.IMouseEvent e) => received.add(<Object?>[
                label,
                'mouse',
                e.browserEvent.view != null ? 'view' : null,
                e.browserEvent.type,
              ]);
      void Function(keyboard.IKeyboardEvent e) keySink(String label) =>
          (keyboard.IKeyboardEvent e) => received.add(<Object?>[
                label,
                'keyboard',
                null,
                e.browserEvent.keyCode,
              ]);
      void Function(dom.DomEvent e) rawSink(String label) =>
          (dom.DomEvent e) => received.add(<Object?>[label, 'raw', null, null]);

      w.pOnclick(nodes['click']!, mouseSink('onclick'));
      w.pOnmousedown(nodes['mousedown']!, mouseSink('onmousedown'));
      w.pOnmouseover(nodes['mouseover']!, mouseSink('onmouseover'));
      w.pOnmouseleave(nodes['mouseleave']!, mouseSink('onmouseleave'));
      w.pOnkeydown(nodes['keydown']!, keySink('onkeydown'));
      w.pOnkeyup(nodes['keyup']!, keySink('onkeyup'));
      w.pOninput(nodes['input']!, rawSink('oninput'));
      w.pOnblur(nodes['blur']!, rawSink('onblur'));
      w.pOnfocus(nodes['focus']!, rawSink('onfocus'));
      w.pOnchange(nodes['change']!, rawSink('onchange'));

      final lifecycle.IDisposable ignored = w.pIgnoreGesture(_RecElement('gesture'));
      expect(identical(ignored, lifecycle.Disposable.none), isFalse);

      for (final MapEntry<String, _RecElement> entry in nodes.entries) {
        final String tag = '${entry.key}-event';
        if (entry.key == 'keydown' || entry.key == 'keyup') {
          entry.value.dispatchEvent(
              entry.key, dom.DomKeyboardEvent(tag)..keyCode = entry.key.length);
        } else {
          entry.value.dispatchEvent(entry.key, dom.DomEvent(tag));
        }
      }

      final List<List<Object?>> registrations = nodes.values
          .expand((_RecElement e) => e.registrations)
          .toList()
        ..sort((List<Object?> a, List<Object?> b) =>
            (a[2] as int).compareTo(b[2] as int));
      expect(registrations, _list(truth['widget']['registrations'] as List));
      expect(received, _list(truth['widget']['received'] as List));
      expect(truth['widget']['ignores'], <Object?>['gesture']);
      expect(registrations.length, truth['widget']['registeredCount']);

      w.dispose();
      final List<List<Object?>> disposals = nodes.values
          .expand((_RecElement e) => e.disposals)
          .toList()
        ..sort((List<Object?> a, List<Object?> b) =>
            (a[1] as int).compareTo(b[1] as int));
      expect(disposals,
          _list(truth['widget']['disposedAfterWidgetDispose'] as List));
    });
  });

  group('batch113 colorPickerInsertButton.ts', () {
    test('button creation / click event / dispose matches TS truth', () {
      final t = truth['insertButton'] as Map<String, dynamic>;
      final state = t['buttonStateBefore'] as Map<String, dynamic>;
      final container = _RecElement('container');
      final insertButton.InsertButton b = insertButton.InsertButton(container);
      expect(b.button.tagName.toLowerCase(), state['tag']);
      expect(b.button.classList.toList(), state['classes']);
      expect(b.button.textContent, state['textContent']);
      expect(container.firstChild, same(b.button));

      final after = t['afterFire'] as Map<String, dynamic>;
      int clicked = 0;
      final lifecycle.IDisposable sub = b.onClicked((dynamic _) => clicked++);
      b.button.dispatchEvent('click', dom.DomEvent('click'));
      expect(clicked, after['clicked']);
      sub.dispose();

      b.dispose();
      b.button.dispatchEvent('click', dom.DomEvent('click'));
      expect(clicked, after['clicked']);
      expect(t['afterDispose'] as List, isNotEmpty);
    });
  });

  group('batch113 sandboxTypes.ts', () {
    test('ISandboxConfiguration field surface matches TS AST truth', () {
      final props =
          (truth['sandboxTypes']['properties'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
      final List<String> names = props
          .map((Map<String, dynamic> p) => p['name'] as String)
          .toList();
      expect(truth['sandboxTypes']['interface'], 'ISandboxConfiguration');
      expect(names, <String>[
        'windowId',
        'appRoot',
        'userEnv',
        'product',
        'zoomLevel',
        'codeCachePath',
        'nls',
        'cssModules'
      ]);
      expect(props.where((Map<String, dynamic> p) => p['optional'] == true)
          .map((Map<String, dynamic> p) => p['name'])
          .toList(), <String>['zoomLevel', 'codeCachePath', 'cssModules']);

      final cfg = product.IProductConfiguration(
        version: '1', nameShort: 'VS', nameLong: 'Visual Studio Code',
        applicationName: 'code', urlProtocol: 'vscode', dataFolderName: '.vscode',
        sharedDataFolderName: '.vscode-shared',
        extensionProperties: const <String, Map<String, Object?>>{},
        builtInExtensionsEnabledWithAutoUpdates: const <String>[],
        serverApplicationName: 'server', defaultChatAgent: chatAgent(),
      );
      final sandbox.ISandboxConfiguration s = sandbox.ISandboxConfiguration(
        windowId: 7,
        appRoot: '/root',
        userEnv: <String, String?>{'PATH': '/bin'},
        product: cfg,
        zoomLevel: 1.5,
        codeCachePath: '/cache',
        nls: sandbox.SandboxConfigurationNls(
            messages: const <String>['hello'], language: 'en'),
        cssModules: const <String>['a.css'],
      );
      expect(s.windowId, 7);
      expect(s.appRoot, '/root');
      expect(s.userEnv, <String, String?>{'PATH': '/bin'});
      expect(s.product, same(cfg));
      expect(s.zoomLevel, 1.5);
      expect(s.codeCachePath, '/cache');
      expect(s.nls.messages, <String>['hello']);
      expect(s.nls.language, 'en');
      expect(s.cssModules, <String>['a.css']);
    });
  });
}

product.IDefaultChatAgent chatAgent() => product.IDefaultChatAgent(
      extensionId: 'e', chatExtensionId: 'c', chatExtensionOutputId: 'co',
      chatExtensionOutputExtensionStateCommand: 'cs',
      documentationUrl: 'd', skusDocumentationUrl: 's',
      optimizeUsageDocumentationUrl: 'o', publicCodeMatchesUrl: 'p',
      managePlanUrl: 'm', upgradePlanUrl: 'u', signUpUrl: 'su',
      termsStatementUrl: 't', privacyStatementUrl: 'pr',
      provider: const <String, Map<String, String>>{
        'default': <String, String>{'id': 'd', 'name': 'D'}
      },
      providerExtensionId: 'pe', providerUriSetting: 'ps',
      providerScopes: const <List<String>>[],
      entitlementUrl: 'eu', entitlementSignupLimitedUrl: 'es',
      tokenEntitlementUrl: 'te', mcpRegistryDataUrl: 'mr',
      managedSettingsUrl: 'ms', chatQuotaExceededContext: 'cq',
      completionsQuotaExceededContext: 'cq2', walkthroughCommand: 'w',
      completionsMenuCommand: 'cm', chatRefreshTokenCommand: 'cr',
      generateCommitMessageCommand: 'gc', resolveMergeConflictsCommand: 'rm',
      completionsAdvancedSetting: 'ca', completionsEnablementSetting: 'ces',
      nextEditSuggestionsSetting: 'ne',
    );
