// 1:1 replay of
//   `editor/browser/widget/codeEditor/codeEditorContributions.ts` (165 lines).
// Truth: `tool/ts2dart/_batch348_truth.cjs` -> `batch348_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/async.dart'
    show IdleDeadline;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    show IDisposable;
import 'package:semi_design_flutter/src/monaco/editor/browser/widget/codeEditor/codeEditorContributions.dart'
    show
        CodeEditorContributions,
        EditorContributionInstantiationForCodeEditor,
        ICodeEditorForCodeEditorContributions,
        IEditorContributionDescriptionForCodeEditor,
        IEditorContributionForCodeEditor,
        configureCodeEditorContributionsGetWindowForReplay,
        configureCodeEditorContributionsIdleForReplay,
        configureCodeEditorContributionsUnexpectedErrorForReplay,
        configureCodeEditorContributionsWarnForReplay;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/instantiation.dart'
    show IInstantiationServiceType;

final Map<String, dynamic> _truth =
    jsonDecode(File('tool/ts2dart/batch348_truth.json').readAsStringSync())
        as Map<String, dynamic>;

List<Object?> _truthList(Object? value) => (value as List).cast<Object?>();
Map<String, dynamic> _truthMap(Object? value) =>
    (value as Map).cast<String, dynamic>();

class _DomNode {
  const _DomNode(this.label);
  final String label;
}

class _Window {
  const _Window(this.label);
  final String label;
}

class _IdleDeadline implements IdleDeadline {
  const _IdleDeadline();
  @override
  bool get didTimeout => false;

  @override
  int timeRemaining() => 0;
}

class _Editor implements ICodeEditorForCodeEditorContributions {
  const _Editor();
  String get label => 'editor';
  @override
  Object getDomNode() => const _DomNode('dom');
}

class _Idle implements IDisposable {
  _Idle(this.state, this.label, this.timeout, this.callback);

  final _Harness state;
  final String label;
  final int? timeout;
  final void Function(Object deadline) callback;
  bool disposed = false;

  void fire() => callback(const _IdleDeadline());

  @override
  void dispose() {
    if (disposed) {
      return;
    }
    disposed = true;
    state.calls.add(<Object?>['disposeIdle', label]);
  }
}

class _Contribution implements IEditorContributionForCodeEditor {
  _Contribution(this.state, this.id, {bool save = false, bool restore = false}) {
    if (save) {
      saveViewState = () {
        state.calls.add(<Object?>['save', id]);
        return <String, Object?>{'v': id};
      };
    }
    if (restore) {
      restoreViewState = (Object? value) {
        final dynamic stateValue = value;
        state.calls.add(<Object?>[
          'restore',
          id,
          stateValue == null ? null : stateValue['v'],
        ]);
      };
    }
  }

  final _Harness state;
  final String id;

  Object? Function()? saveViewState;
  void Function(Object?)? restoreViewState;

  @override
  void dispose() => state.calls.add(<Object?>['disposeContribution', id]);
}

class _Ctor {
  const _Ctor({
    required this.id,
    required this.label,
    required this.throws,
    required this.save,
    required this.restore,
  });

  final String id;
  final String label;
  final bool throws;
  final bool save;
  final bool restore;
}

class _Desc {
  _Desc(
    this.id,
    this.instantiation, {
    String? label,
    bool throws = false,
    bool save = false,
    bool restore = false,
  }) : ctor = _Ctor(
          id: id,
          label: label ?? id,
          throws: throws,
          save: save,
          restore: restore,
        );

  final String id;
  final int instantiation;
  final _Ctor ctor;

  IEditorContributionDescriptionForCodeEditor toDescription() =>
      IEditorContributionDescriptionForCodeEditor(
        id: id,
        ctor: ctor,
        instantiation: instantiation,
      );
}

class _InstantiationService implements IInstantiationServiceType {
  const _InstantiationService(this.state);
  final _Harness state;

  @override
  Object? createInstance(Object ctor, List<Object?> args) {
    final _Ctor descriptor = ctor as _Ctor;
    final _Editor editor = args.first as _Editor;
    state.calls.add(<Object?>[
      'createInstance',
      descriptor.id,
      editor.label,
    ]);
    if (descriptor.throws) {
      throw StateError('ctor failed');
    }
    return _Contribution(
      state,
      descriptor.id,
      save: descriptor.save,
      restore: descriptor.restore,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Harness {
  _Harness() {
    final _Harness self = this;
    configureCodeEditorContributionsGetWindowForReplay((Object? element) {
      final String? label = element is _DomNode ? element.label : null;
      self.calls.add(<Object?>['getWindow', label]);
      return const _Window('window');
    });
    configureCodeEditorContributionsIdleForReplay((
      Object window,
      void Function(Object deadline) callback, [
      int? timeout,
    ]) {
      final _Idle idle =
          _Idle(self, 'idle${self.idleCallbacks.length}', timeout, callback);
      self.idleCallbacks.add(idle);
      self.calls.add(<Object?>['runWhenWindowIdle', idle.label, timeout]);
      return idle;
    });
    configureCodeEditorContributionsUnexpectedErrorForReplay((Object error) {
      self.errors.add(error is StateError ? error.message : error.toString());
    });
    configureCodeEditorContributionsWarnForReplay(
      (String message) => self.warns.add(<Object?>[message]),
    );

    editor = const _Editor();
    instantiationService = _InstantiationService(this);
    contributions = CodeEditorContributions();
  }

  late final _Editor editor;
  late final _InstantiationService instantiationService;
  late final CodeEditorContributions contributions;

  final List<Object?> calls = <Object?>[];
  final List<String> errors = <String>[];
  final List<Object?> warns = <Object?>[];
  final List<_Idle> idleCallbacks = <_Idle>[];

  void initialize(List<_Desc> descriptions) {
    contributions.initialize(
      editor,
      descriptions.map((_Desc d) => d.toDescription()).toList(),
      instantiationService,
    );
  }

  List<Object?> idleSnapshot() => idleCallbacks
      .map((_Idle idle) => <String, Object?>{
            'label': idle.label,
            'timeout': idle.timeout,
          })
      .toList();
}

void main() {
  group('codeEditorContributions.ts initialize', () {
    test('registers pending contributions and idle callbacks', () {
      final _Harness h = _Harness();
      h.initialize(<_Desc>[
        _Desc('eager1', EditorContributionInstantiationForCodeEditor.Eager,
            save: true, restore: true),
        _Desc('after1', EditorContributionInstantiationForCodeEditor.AfterFirstRender),
        _Desc('before1',
            EditorContributionInstantiationForCodeEditor.BeforeFirstInteraction),
        _Desc('eventual1', EditorContributionInstantiationForCodeEditor.Eventually),
        _Desc('eager1', EditorContributionInstantiationForCodeEditor.Eventually),
        _Desc('bad', EditorContributionInstantiationForCodeEditor.Eager,
            throws: true),
      ]);

      final Map<String, dynamic> truth = _truthMap(_truth['init']);
      expect(h.calls, equals(_truthList(truth['calls'])));
      expect(h.errors, equals(_truthList(truth['errors'])));
      expect(h.warns, equals(_truthList(truth['warns'])));
      expect(h.idleSnapshot(), equals(_truthList(truth['idle'])));
    });
  });

  group('codeEditorContributions.ts idle lifecycle', () {
    test('idle callbacks and interaction hooks instantiate pending kinds', () {
      final _Harness h = _Harness();
      h.initialize(<_Desc>[
        _Desc('eager1', EditorContributionInstantiationForCodeEditor.Eager),
        _Desc('after1', EditorContributionInstantiationForCodeEditor.AfterFirstRender),
        _Desc('before1',
            EditorContributionInstantiationForCodeEditor.BeforeFirstInteraction),
        _Desc('eventual1', EditorContributionInstantiationForCodeEditor.Eventually),
      ]);
      h.calls.clear();

      h.idleCallbacks[0].fire();
      h.idleCallbacks[1].fire();
      h.idleCallbacks[2].fire();
      h.contributions.onBeforeInteractionEvent();
      final IDisposable attached = h.contributions.onAfterModelAttached();
      final String attachedLabel = 'idle${h.idleCallbacks.length}';
      h.idleCallbacks.last.fire();
      attached.dispose();

      final Map<String, dynamic> truth = _truthMap(_truth['idle']);
      expect(h.calls, equals(_truthList(truth['calls'])));
      expect(attachedLabel, truth['attachedLabel']);
      expect(h.errors, equals(_truthList(truth['errors'])));
      expect(h.warns, equals(_truthList(truth['warns'])));
    });
  });

  group('codeEditorContributions.ts view state', () {
    test('save, restore and lazily instantiated restore warnings', () {
      final _Harness h = _Harness();
      h.initialize(<_Desc>[
        _Desc('eagerSave', EditorContributionInstantiationForCodeEditor.Eager,
            save: true, restore: true),
        _Desc('plain', EditorContributionInstantiationForCodeEditor.Eager),
        _Desc('beforeRestore',
            EditorContributionInstantiationForCodeEditor.BeforeFirstInteraction,
            restore: true),
      ]);
      h.calls.clear();
      h.warns.clear();

      final Object? restoredByGet = h.contributions.get('beforeRestore');
      final Object? missing = h.contributions.get('missing');
      h.contributions.set(
        'manual',
        _Contribution(h, 'manual', save: true, restore: true),
      );
      final Map<String, Object?> saved = h.contributions.saveViewState();
      h.contributions.restoreViewState(<String, Object?>{
        'eagerSave': <String, Object?>{'v': 'eagerSave'},
        'beforeRestore': <String, Object?>{'v': 'beforeRestore'},
        'manual': <String, Object?>{'v': 'manual'},
      });

      final Map<String, dynamic> truth = _truthMap(_truth['viewState']);
      expect(h.calls, equals(_truthList(truth['calls'])));
      expect(h.warns, equals(_truthList(truth['warns'])));
      expect(h.errors, equals(_truthList(truth['errors'])));
      expect(saved, equals(_truthMap(truth['saved'])));
      expect(
        restoredByGet is _Contribution ? restoredByGet.id : null,
        truth['restoredByGet'],
      );
      expect(missing, isNull);
      expect(truth['missing'], isNull);
    });
  });

  group('codeEditorContributions.ts dispose', () {
    test('disposes instances and idle registrations', () {
      final _Harness h = _Harness();
      h.initialize(<_Desc>[
        _Desc('eager1', EditorContributionInstantiationForCodeEditor.Eager),
        _Desc('after1', EditorContributionInstantiationForCodeEditor.AfterFirstRender),
      ]);
      h.contributions.get('after1');
      h.calls.clear();

      h.contributions.dispose();
      expect(h.calls, equals(_truthList(_truthMap(_truth['dispose'])['calls'])));
    });
  });
}
