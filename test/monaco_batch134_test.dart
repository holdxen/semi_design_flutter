// Truth-driven tests for batch134:
// platform/clipboard/browser/clipboardService.ts
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart' as dom;
import 'package:semi_design_flutter/src/monaco/base/browser/window.dart' as window;
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' as events;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart' as lifecycle;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' as uri;
import 'package:semi_design_flutter/src/monaco/platform/clipboard/browser/clipboardService.dart'
    as browser;
import 'package:semi_design_flutter/src/monaco/platform/layout/browser/layoutService.dart'
    as layout;
import 'package:semi_design_flutter/src/monaco/platform/log/common/log.dart' as log;

final Map<String, Object?> _truth =
    jsonDecode(File('tool/ts2dart/batch134_truth.json').readAsStringSync())
        as Map<String, Object?>;

Map<String, Object?> _section(String key) =>
    _truth[key] as Map<String, Object?>;

List<Object?> _list(Object? value) => (value as List).cast<Object?>();

class _RecordingLogService extends log.NullLogService {
  final List<String> traces = <String>[];
  final List<Object> errors = <Object>[];

  @override
  void trace(String message, [List<Object?> args = const <Object?>[]]) {
    traces.add(message);
  }

  @override
  void error(Object message, [List<Object?> args = const <Object?>[]]) {
    errors.add(message);
  }
}

class _FakeClipboard {
  List<Object> readItems = <Object>[];
  String readTextValue = '';
  final List<String> writeTexts = <String>[];
  final List<List<Object>> writes = <List<Object>>[];
  bool failWriteText = false;

  browser.ClipboardApi get api => browser.ClipboardApi(
        read: () async => readItems,
        readText: () async => readTextValue,
        writeText: (String text) async {
          writeTexts.add(text);
          if (failWriteText) throw StateError('denied');
        },
        write: (List<Object> items) async {
          writes.add(items);
        },
      );
}

class _ListenerRecord {
  _ListenerRecord(this.type, this.target);

  final String type;
  final Object target;
  bool disposed = false;
}

class _TrackedDisposable implements lifecycle.IDisposable {
  _TrackedDisposable(this.delegate, this.onDispose);

  final lifecycle.IDisposable delegate;
  final void Function() onDispose;

  @override
  void dispose() {
    delegate.dispose();
    onDispose();
  }
}

class _FakeTextArea extends dom.DomElement {
  _FakeTextArea() : super('textarea');

  String value = '';

  @override
  void focus() {}

  void select() {}
}

class _FakeLayoutService implements layout.ILayoutServiceType {
  _FakeLayoutService(this.mainContainer)
      : _addEmitter = events.Emitter<layout.AddContainerEvent>();

  final events.Emitter<layout.AddContainerEvent> _addEmitter;

  // ignore: unused_element
  Object? get _serviceBrand => null;
  @override
  events.Event<dom.IDimension> get onDidLayoutMainContainer => events.eventNone;
  @override
  events.Event<layout.LayoutContainerEvent> get onDidLayoutContainer =>
      events.eventNone;
  @override
  events.Event<dom.IDimension> get onDidLayoutActiveContainer =>
      events.eventNone;
  @override
  events.Event<layout.AddContainerEvent> get onDidAddContainer =>
      _addEmitter.event;
  @override
  events.Event<void> get onDidChangeActiveContainer => events.eventNone;
  @override
  dom.IDimension get mainContainerDimension => dom.Dimension.None;
  @override
  dom.IDimension get activeContainerDimension => dom.Dimension.None;
  @override
  final Object mainContainer;
  @override
  Object get activeContainer => mainContainer;
  @override
  Iterable<Object> get containers => <Object>[mainContainer];
  @override
  Object getContainer(Object window) => mainContainer;
  @override
  Future<void>? whenContainerStylesLoaded(Object window) => null;
  @override
  layout.ILayoutOffsetInfo get mainContainerOffset =>
      const layout.ILayoutOffsetInfo(top: 0, quickPickTop: 0);
  @override
  layout.ILayoutOffsetInfo get activeContainerOffset =>
      const layout.ILayoutOffsetInfo(top: 0, quickPickTop: 0);
  @override
  void focus() {}
}

void main() {
  late _FakeClipboard clipboard;
  late _RecordingLogService logger;
  late dom.DomDocument doc;
  late dom.DomElement mainContainer;
  late _FakeLayoutService layoutService;
  late events.Emitter<dom.IRegisteredCodeWindow> registeredEmitter;
  late List<_ListenerRecord> listenerRecords;
  late List<Object> consoleErrors;
  late List<String> execCommands;
  late List<_FakeTextArea> textareas;
  late window.CodeWindow activeWindow;

  setUp(() {
    clipboard = _FakeClipboard();
    logger = _RecordingLogService();
    doc = dom.DomDocument();
    mainContainer = dom.DomElement('div');
    layoutService = _FakeLayoutService(mainContainer);
    registeredEmitter = events.Emitter<dom.IRegisteredCodeWindow>();
    listenerRecords = <_ListenerRecord>[];
    consoleErrors = <Object>[];
    execCommands = <String>[];
    textareas = <_FakeTextArea>[];
    activeWindow = window.CodeWindow(Object(), 0);
    dom.windowCarrier(activeWindow).document = doc;
    dom.windowCarrier(window.mainWindow).document = doc;

    final browser.BrowserClipboardEnvironment env =
        browser.clipboardEnvironment;
    env.isSafari = false;
    env.isWebkitWebView = false;
    env.getActiveDocument = () => doc;
    env.getActiveWindow = () => activeWindow;
    env.navigatorClipboard = () => clipboard.api;
    env.windowClipboard = (_) => clipboard.api;
    env.createElement = (String tag, Map<String, Object?> attributes) {
      final _FakeTextArea e = _FakeTextArea();
      attributes.forEach((String k, Object? v) => e.setAttribute(k, v.toString()));
      textareas.add(e);
      return e;
    };
    env.addListener = (Object target, String type,
        void Function(dynamic e) listener) {
      final lifecycle.IDisposable inner = dom.addDisposableListener(
          target as dom.DomNode,
          type,
          (dom.DomEvent e) => listener(e));
      final _ListenerRecord record = _ListenerRecord(type, target);
      listenerRecords.add(record);
      return _TrackedDisposable(inner, () => record.disposed = true);
    };
    env.onDidRegisterWindow = () => registeredEmitter.event;
    env.execCommand = (dom.DomDocument document, String command) {
      execCommands.add(command);
    };
    env.consoleError = (Object error) => consoleErrors.add(error);
  });

  browser.BrowserClipboardService newService() =>
      browser.BrowserClipboardService(layoutService, logger);

  int activeListeners(String type) => listenerRecords
      .where((_ListenerRecord r) => r.type == type && !r.disposed)
      .length;

  test('constructor registers copy listener', () {
    newService();
    final Map<String, Object?> e = _section('construct');
    expect(logger.traces, _list(e['traces']));
    expect(activeListeners('copy'), e['copyListeners']);
  });

  test('triggerPaste returns undefined and traces', () {
    final browser.BrowserClipboardService svc = newService();
    logger.traces.clear();
    expect(svc.triggerPaste(), isNull);
    final List<Object?> traces = _list(_section('triggerPaste')['traces']);
    expect(logger.traces.length, traces.length);
    expect(logger.traces.first, (traces.first as List).last);
  });

  test('typed text stays in memory', () async {
    final browser.BrowserClipboardService svc = newService();
    await svc.writeText('typed', 'typeA');
    final Map<String, Object?> e = _section('typedText');
    expect(await svc.readText('typeA'), e['first']);
    expect(await svc.readText('missing'), e['missing']);
    expect(clipboard.writeTexts, _list(e['clipboardWrites']));
  });

  test('plain text delegates to navigator clipboard', () async {
    final browser.BrowserClipboardService svc = newService();
    clipboard.readTextValue = 'clip text';
    await svc.writeText('plain');
    final Map<String, Object?> e = _section('plainText');
    expect(clipboard.writeTexts, _list(e['written']));
    expect(await svc.readText(), e['read']);
  });

  test('writeText falls back to textarea', () async {
    final browser.BrowserClipboardService svc = newService();
    clipboard.failWriteText = true;
    await svc.writeText('fallback');
    final Map<String, Object?> e = _section('fallback');
    expect(textareas.single.value, 'fallback');
    expect(textareas.single.getAttribute('aria-hidden'), 'true');
    expect(execCommands, _list(e['execCommands']));
    final List<Object?> traces = _list(e['traces']);
    expect(logger.traces, contains(traces.first));
  });

  test('find text', () async {
    final browser.BrowserClipboardService svc = newService();
    await svc.writeFindText('find me');
    expect(await svc.readFindText(), _section('findText')['value']);
  });

  test('resources written/read and clearInternalState', () async {
    final browser.BrowserClipboardService svc = newService();
    clipboard.readTextValue = 'seed';
    final uri.URI a = uri.URI.parse('file:///a');
    final uri.URI b = uri.URI.parse('file:///b');
    await svc.writeResources(<uri.URI>[a, b]);
    final Map<String, Object?> e = _section('resources');
    final browser.ClipboardItemCarrier item =
        clipboard.writes.last.single as browser.ClipboardItemCarrier;
    expect(<List<String>>[item.types], _list(e['writeKeys'])
        .map((Object? x) => (x as List).cast<String>())
        .toList());
    expect((item.items[browser.webVscodeResourcesMime] as browser.ClipboardBlob)
        .parts.single, e['writeBlob']);
    final List<uri.URI> read = await svc.readResources();
    expect(read.map((uri.URI x) => x.toString()).toList(), _list(e['read1']));
    expect(await svc.hasResources(), e['has1']);
    svc.clearInternalState();
    expect(await svc.hasResources(), e['has2']);
  });

  test('resources invalidated when clipboard text changes', () async {
    final browser.BrowserClipboardService svc = newService();
    clipboard.readTextValue = 'abc';
    await svc.writeResources(<uri.URI>[uri.URI.parse('file:///x')]);
    clipboard.readTextValue = 'xyz';
    final List<uri.URI> after = await svc.readResources();
    expect(after.length, _section('resourcesInvalidation')['count']);
  });

  test('readImage supported and unsupported', () async {
    final browser.BrowserClipboardService svc = newService();
    clipboard.readItems = <Object>[
      browser.ClipboardItemCarrier(<String, Object>{
        'image/png': browser.ClipboardBlob(<Object>['PNG'], 'image/png'),
      }),
    ];
    final Uint8List image = await svc.readImage();
    expect(image.toList(), _list(_section('readImage')['bytes']));
    clipboard.readItems = <Object>[
      browser.ClipboardItemCarrier(<String, Object>{
        'text/plain': browser.ClipboardBlob(<Object>['txt'], 'text/plain'),
      }),
    ];
    final Uint8List empty = await svc.readImage();
    expect(empty.toList(), _list(_section('readImageUnsupported')['bytes']));
  });

  test('writeImage clears resource state', () async {
    final browser.BrowserClipboardService svc = newService();
    clipboard.readTextValue = 'abc';
    await svc.writeResources(<uri.URI>[uri.URI.parse('file:///r')]);
    await svc.writeImage(Uint8List.fromList(<int>[4, 5]));
    final Map<String, Object?> e = _section('writeImage');
    expect(
        clipboard.writes
            .map((List<Object> w) =>
                (w.single as browser.ClipboardItemCarrier).types)
            .toList(),
        _list(e['writeKeys'])
            .map((Object? x) => (x as List).cast<String>())
            .toList());
    expect(await svc.hasResources(), e['hasAfter']);
  });

  test('webkit workaround completes pending write', () async {
    browser.clipboardEnvironment.isSafari = true;
    final browser.BrowserClipboardService svc = newService();
    mainContainer.dispatchEvent('click', dom.DomEvent('click'));
    final Map<String, Object?> e = _section('safari');
    expect(clipboard.writes.length, e['writesBefore']);
    await svc.writeText('safari text');
    expect(clipboard.writeTexts, _list(e['writeTexts']));
    final browser.ClipboardItemCarrier item =
        clipboard.writes.last.single as browser.ClipboardItemCarrier;
    expect(item.items['text/plain'], isA<Future<String>>());
    expect(
      listenerRecords
          .where((_ListenerRecord r) => identical(r.target, mainContainer))
          .map((_ListenerRecord r) => r.type)
          .toList(),
      _list(e['listenerTypes']),
    );
  });

  test('dispose removes copy listener', () {
    final browser.BrowserClipboardService svc = newService();
    svc.dispose();
    expect(activeListeners('copy'), _section('dispose')['copyListeners']);
  });
}
