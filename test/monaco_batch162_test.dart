// Truth-driven tests for platform/undoRedo/common/undoRedoService.ts.
// Truth: tool/ts2dart/batch162_truth.json (real transpiled TypeScript module).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' as uri;
import 'package:semi_design_flutter/src/monaco/platform/undoRedo/common/undoRedo.dart'
    as undoRedo;
import 'package:semi_design_flutter/src/monaco/platform/undoRedo/common/undoRedoService.dart'
    as service;

final Map<String, dynamic> T = jsonDecode(
        File('tool/ts2dart/batch162_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Map<String, dynamic> _section(String key) => T[key] as Map<String, dynamic>;

class ResElement implements undoRedo.IResourceUndoRedoElement {
  ResElement(this.path, this.label, this.log, this.name);

  final String path;
  @override
  final String label;
  final List<String> log;
  final String name;

  @override
  int get type => undoRedo.UndoRedoElementType.Resource;

  @override
  uri.URI get resource => uri.URI.file(path);

  @override
  String get code => 'typing';

  @override
  bool? get confirmBeforeUndo => null;

  @override
  Future<void>? undo() {
    log.add('undo:$name');
    return null;
  }

  @override
  Future<void>? redo() {
    log.add('redo:$name');
    return null;
  }
}

class WorkspaceElement implements undoRedo.IWorkspaceUndoRedoElement {
  WorkspaceElement(this.paths, this.label, this.log, this.name, this.splits,
      [this.prepare]);

  final List<String> paths;
  @override
  final String label;
  final List<String> log;
  final String name;
  final List<undoRedo.IResourceUndoRedoElement> splits;
  final Object? Function()? prepare;

  @override
  int get type => undoRedo.UndoRedoElementType.Workspace;

  @override
  List<uri.URI> get resources => paths.map(uri.URI.file).toList();

  @override
  String get code => 'typing';

  @override
  bool? get confirmBeforeUndo => null;

  @override
  Future<void>? undo() {
    log.add('undo:$name');
    return null;
  }

  @override
  Future<void>? redo() {
    log.add('redo:$name');
    return null;
  }

  @override
  List<undoRedo.IResourceUndoRedoElement>? split() => splits;

  @override
  Object? prepareUndoRedo() => prepare?.call();
}

class ThrowingElement implements undoRedo.IResourceUndoRedoElement {
  ThrowingElement(this.path)
      : label = 'err',
        log = <String>[];

  final String path;
  final List<String> log;

  @override
  int get type => undoRedo.UndoRedoElementType.Resource;

  @override
  uri.URI get resource => uri.URI.file(path);

  @override
  final String label;

  @override
  String get code => 'x';

  @override
  bool? get confirmBeforeUndo => null;

  @override
  Future<void>? undo() => throw StateError('boom');

  @override
  Future<void>? redo() {
    log.add('redo:err');
    return null;
  }
}

class DialogStub {
  DialogStub([this.choice = 0, this.confirmed = true]);

  Object choice;
  bool confirmed;
  final List<String> prompts = <String>[];
  final List<String> confirms = <String>[];

  Future<Map<String, Object?>> prompt(Map<String, Object?> prompt) async {
    prompts.add(prompt['message'] as String);
    final Object? result;
    if (choice == 'cancel') {
      final Map<String, Object?> cancel =
          prompt['cancelButton'] as Map<String, Object?>;
      result = (cancel['run'] as Object Function())();
    } else {
      final List<Object?> buttons = prompt['buttons'] as List<Object?>;
      final Map<String, Object?> button =
          buttons[choice as int] as Map<String, Object?>;
      result = (button['run'] as Object Function())();
    }
    return <String, Object?>{'result': result};
  }

  Future<Map<String, Object?>> confirm(Map<String, Object?> prompt) async {
    confirms.add(prompt['message'] as String);
    return <String, Object?>{'confirmed': confirmed};
  }
}

class NotificationStub {
  final List<String> warnings = <String>[];
  final List<String> errors = <String>[];

  void warn(Object message) => warnings.add(message.toString());
  void error(Object message) =>
      errors.add((message as dynamic).message as String? ?? message.toString());
}

service.UndoRedoService createService(DialogStub dialog, NotificationStub notes) =>
    service.UndoRedoService(dialog, notes);

Map<String, Object?> state(service.UndoRedoService svc, uri.URI resource) {
  final undoRedo.IPastFutureElements elements = svc.getElements(resource);
  final Object? last = svc.getLastElement(resource);
  return <String, Object?>{
    'canUndo': svc.canUndo(resource),
    'canRedo': svc.canRedo(resource),
    'hasElements': svc.hasElements(resource),
    'last': last == null ? null : (last as dynamic).label as String,
    'past': elements.past.map((Object? e) => (e as dynamic).label).toList(),
    'future': elements.future.map((Object? e) => (e as dynamic).label).toList(),
  };
}

List<int> normSnapshot(undoRedo.ResourceEditStackSnapshot snapshot) {
  if (snapshot.elements.isEmpty) return <int>[];
  final int min = snapshot.elements.reduce((int a, int b) => a < b ? a : b);
  return snapshot.elements.map((int id) => id - min + 1).toList();
}

class _KeyComputer implements undoRedo.UriComparisonKeyComputer {
  @override
  String getComparisonKey(uri.URI resource) => 'key:${resource.path}';
}

void main() {
  test('constants', () {
    final Map<String, dynamic> truth = _section('constants');
    final Map<String, dynamic> types =
        truth['elementType'] as Map<String, dynamic>;
    expect(undoRedo.UndoRedoElementType.Resource, types['Resource']);
    expect(undoRedo.UndoRedoElementType.Workspace, types['Workspace']);
    expect(
      (truth['registrations'] as List<dynamic>)
          .map((dynamic e) => (e as List<dynamic>).cast<Object?>())
          .toList(),
      <List<Object?>>[
        <Object?>['undoRedoService', 1]
      ],
    );
  });

  test('simple single resource elements', () async {
    final Map<String, dynamic> truth = _section('simple');
    final service.UndoRedoService svc =
        createService(DialogStub(), NotificationStub());
    final uri.URI r = uri.URI.file('/test.txt');
    final List<String> log = <String>[];
    final List<List<Object?>> steps = <List<Object?>>[];

    steps.add(<Object?>['initial', state(svc, r)]);
    svc.pushElement(ResElement('/test.txt', 'one', log, '1'));
    steps.add(<Object?>['push1', state(svc, r)]);
    await svc.undo(r);
    steps.add(<Object?>['undo1', state(svc, r)]);
    await svc.redo(r);
    steps.add(<Object?>['redo1', state(svc, r)]);
    svc.pushElement(ResElement('/test.txt', 'two', log, '2'));
    steps.add(<Object?>['push2', state(svc, r)]);
    await svc.undo(r);
    steps.add(<Object?>['undo2', state(svc, r)]);

    expect(steps, truth['steps']);
    expect(log, truth['log']);
  });

  test('multi resource elements', () async {
    final Map<String, dynamic> truth = _section('multi');
    final DialogStub dialog = DialogStub(0, true);
    final service.UndoRedoService svc =
        createService(dialog, NotificationStub());
    final uri.URI r1 = uri.URI.file('/t1.txt');
    final uri.URI r2 = uri.URI.file('/t2.txt');
    final List<String> log = <String>[];
    final List<undoRedo.IResourceUndoRedoElement> splits =
        <undoRedo.IResourceUndoRedoElement>[
      ResElement('/t1.txt', 'split-1', log, 's1'),
      ResElement('/t2.txt', 'split-2', log, 's2'),
    ];
    svc.pushElement(WorkspaceElement(
        <String>['/t1.txt', '/t2.txt'], 'both', log, 'w', splits));

    expect(<Object?>[state(svc, r1), state(svc, r2)], truth['before']);
    await svc.undo(r1);
    expect(<Object?>[state(svc, r1), state(svc, r2)], truth['afterUndo']);
    await svc.redo(r2);
    expect(<Object?>[state(svc, r1), state(svc, r2)], truth['afterRedo']);
    expect(log, truth['log']);
    expect(dialog.prompts, truth['prompts']);
    expect(dialog.confirms, truth['confirms']);
  });

  test('UndoRedoGroup.None uses id 0', () {
    final Map<String, dynamic> truth = _section('groups');
    expect(undoRedo.UndoRedoGroup.None.id, truth['noneId']);
    expect(<int>[
      undoRedo.UndoRedoGroup.None.nextOrder(),
      undoRedo.UndoRedoGroup.None.nextOrder(),
    ], truth['noneOrders']);
    expect(undoRedo.UndoRedoGroup().id, truth['freshId']);
    expect(<int>[undoRedo.UndoRedoGroup().nextOrder()], truth['freshOrders']);
    expect(undoRedo.UndoRedoSource.None.id, truth['sourceNoneId']);
  });

  test('restoreSnapshot preserves matching elements', () {
    final Map<String, dynamic> truth = _section('snapshot');
    final service.UndoRedoService svc =
        createService(DialogStub(), NotificationStub());
    final uri.URI r = uri.URI.file('/snap.txt');
    final List<String> log = <String>[];
    for (int i = 1; i <= 3; i++) {
      svc.pushElement(ResElement('/snap.txt', 's$i', log, '$i'));
    }
    final undoRedo.ResourceEditStackSnapshot snapshot = svc.createSnapshot(r);
    expect(normSnapshot(snapshot), truth['snapshotIds']);
    svc.pushElement(ResElement('/snap.txt', 's4', log, '4'));
    expect(state(svc, r), truth['beforeRestore']);
    svc.restoreSnapshot(snapshot);
    expect(state(svc, r), truth['afterRestore']);
    expect(log, truth['log']);
  });

  test('uri comparison key computers', () {
    final Map<String, dynamic> truth = _section('comparisonKey');
    final service.UndoRedoService svc =
        createService(DialogStub(), NotificationStub());
    final uri.URI custom = uri.URI.parse('custom:/x');
    final _KeyComputer computer = _KeyComputer();
    final d = svc.registerUriComparisonKeyComputer('custom', computer);
    expect(<String>[
      svc.getUriComparisonKey(custom),
      svc.getUriComparisonKey(uri.URI.file('/x')),
    ], truth['before']);
    d.dispose();
    expect(svc.getUriComparisonKey(custom), truth['after']);
  });

  test('removed resource splits workspace element', () async {
    final Map<String, dynamic> truth = _section('removed');
    final DialogStub dialog = DialogStub(0, true);
    final NotificationStub notes = NotificationStub();
    final service.UndoRedoService svc = createService(dialog, notes);
    final List<String> log = <String>[];
    final List<undoRedo.IResourceUndoRedoElement> splits =
        <undoRedo.IResourceUndoRedoElement>[
      ResElement('/r1.txt', 'sp1', log, 'sp1'),
      ResElement('/r2.txt', 'sp2', log, 'sp2'),
    ];
    svc.pushElement(WorkspaceElement(
        <String>['/r1.txt', '/r2.txt'], 'multi-remove', log, 'w', splits));
    svc.removeElements(uri.URI.file('/r1.txt'));
    await svc.undo(uri.URI.file('/r2.txt'));
    expect(log, truth['before']);
    expect(notes.warnings, truth['warnings']);
    expect(state(svc, uri.URI.file('/r2.txt')), truth['r2']);
    expect(dialog.prompts, truth['prompts']);
  });

  test('invalid element flushes stack', () async {
    final Map<String, dynamic> truth = _section('invalid');
    final service.UndoRedoService svc =
        createService(DialogStub(), NotificationStub());
    final uri.URI r = uri.URI.file('/invalid.txt');
    final List<String> log = <String>[];
    svc.pushElement(ResElement('/invalid.txt', 'invalid', log, 'i'));
    svc.setElementsValidFlag(r, false, (Object element) => true);
    expect(state(svc, r), truth['before']);
    await svc.undo(r);
    expect(state(svc, r), truth['after']);
    expect(log, truth['log']);
  });

  test('confirmation on different source', () async {
    final Map<String, dynamic> truth = _section('confirm');
    final DialogStub dialog = DialogStub(0, false);
    final service.UndoRedoService svc = createService(dialog, NotificationStub());
    final uri.URI r = uri.URI.file('/confirm.txt');
    final List<String> log = <String>[];
    final undoRedo.UndoRedoSource src = undoRedo.UndoRedoSource();
    svc.pushElement(ResElement('/confirm.txt', 'confirm', log, 'c'), null, src);
    expect(svc.canUndo(src), truth['canUndoSource']);
    await svc.undo(r);
    expect(<Object?>[state(svc, r), log.toList()], truth['afterCancel']);
    dialog.confirmed = true;
    await svc.undo(r);
    expect(<Object?>[state(svc, r), log.toList()], truth['afterConfirm']);
    expect(dialog.confirms, truth['confirms']);
  });

  test('prepare and error handling', () async {
    final Map<String, dynamic> truth = _section('prepare');
    final NotificationStub notes = NotificationStub();
    final service.UndoRedoService svc = createService(DialogStub(), notes);
    final uri.URI r = uri.URI.file('/prep.txt');
    final List<String> log = <String>[];
    svc.pushElement(
        ResElement('/prep.txt', 'prep', log, 'prep'));
    await svc.undo(r);
    expect(log, truth['log']);
    expect(state(svc, r), truth['after']);

    final uri.URI rErr = uri.URI.file('/err.txt');
    svc.pushElement(ThrowingElement('/err.txt'));
    await svc.undo(rErr);
    final Map<String, dynamic> errorTruth =
        (truth['error'] as Map<String, dynamic>);
    expect(notes.errors, errorTruth['notes']);
    expect(state(svc, rErr), errorTruth['rErr']);
  });

  test('workspace dialog cancel and split-this', () async {
    final Map<String, dynamic> truth = _section('workspaceChoices');
    final DialogStub dialog = DialogStub(0, true);
    final service.UndoRedoService svc = createService(dialog, NotificationStub());
    final List<String> log = <String>[];
    final List<undoRedo.IResourceUndoRedoElement> splits =
        <undoRedo.IResourceUndoRedoElement>[
      ResElement('/c1.txt', 'pc1', log, 'pc1'),
      ResElement('/c2.txt', 'pc2', log, 'pc2'),
    ];
    svc.pushElement(WorkspaceElement(
        <String>['/c1.txt', '/c2.txt'], 'cancel', log, 'w', splits));
    dialog.choice = 'cancel';
    await svc.undo(uri.URI.file('/c1.txt'));
    expect(<Object?>[state(svc, uri.URI.file('/c1.txt')), log.toList()],
        truth['afterCancel']);
    dialog.choice = 1;
    await svc.undo(uri.URI.file('/c1.txt'));
    expect(
        <Object?>[
          state(svc, uri.URI.file('/c1.txt')),
          state(svc, uri.URI.file('/c2.txt')),
          log.toList(),
        ],
        truth['afterThis']);
    expect(dialog.prompts, truth['prompts']);
  });
}
