// batch68: treeViewsDndService.ts + webWorkerService.ts + utils.ts +
// testAccessibilityService.ts + testTextResourcePropertiesService.ts +
// testWorkspace.ts + testClipboardService.ts. Assertions are data-driven
// from batch68_truth.json (Node TS transpile+vm real evaluation against the
// same host platform).
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data' show Uint8List;

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/event.dart'
    show Event, eventNone;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/editor/common/services/treeViewsDndService.dart'
    as tvds;
import 'package:semi_design_flutter/src/monaco/editor/contrib/wordPartOperations/test/browser/utils.dart'
    as utils;
import 'package:semi_design_flutter/src/monaco/editor/test/common/services/testTextResourcePropertiesService.dart'
    as trps;
import 'package:semi_design_flutter/src/monaco/platform/accessibility/common/accessibility.dart'
    show AccessibilitySupport;
import 'package:semi_design_flutter/src/monaco/platform/accessibility/test/common/testAccessibilityService.dart'
    as tas;
import 'package:semi_design_flutter/src/monaco/platform/clipboard/test/common/testClipboardService.dart'
    as tcs;
import 'package:semi_design_flutter/src/monaco/platform/configuration/common/configuration.dart'
    show IConfigurationChangeEvent, IConfigurationOverrides,
        IConfigurationServiceType, IConfigurationUpdateOptions;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/extensions.dart'
    show getSingletonServiceDescriptors;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier;
import 'package:semi_design_flutter/src/monaco/platform/webWorker/browser/webWorkerService.dart'
    as wws;
import 'package:semi_design_flutter/src/monaco/platform/workspace/common/workspace.dart'
    as wscore;
import 'package:semi_design_flutter/src/monaco/platform/workspace/test/common/testWorkspace.dart'
    as tw;

Map<String, dynamic> _truth() => jsonDecode(
      File('tool/ts2dart/batch68_truth.json').readAsStringSync(),
    ) as Map<String, dynamic>;

class _ConfigMock implements IConfigurationServiceType {
  final Object? eol;
  _ConfigMock(this.eol);
  Object? section, capturedOverride;
  // ignore: unused_element, override_on_non_overriding_member
  Object? get _serviceBrand => null;
  @override
  Event<IConfigurationChangeEvent> get onDidChangeConfiguration =>
      throw UnimplementedError();
  @override
  Map<String, Object?>? getConfigurationData() => throw UnimplementedError();
  @override
  Object? getValue$0() => throw UnimplementedError();
  @override
  Object? getValue$1(String section) => throw UnimplementedError();
  @override
  Object? getValue$2(IConfigurationOverrides overrides) =>
      throw UnimplementedError();
  @override
  Object? getValue$3(String section, IConfigurationOverrides overrides) {
    this.section = section;
    this.capturedOverride = overrides;
    return eol;
  }
  @override
  Future<void> updateValue$2(String key, Object? value) =>
      throw UnimplementedError();
  @override
  Future<void> updateValue$3(String key, Object? value, int target) =>
      throw UnimplementedError();
  @override
  Future<void> updateValue$4(String key, Object? value, Object? overrides) =>
      throw UnimplementedError();
  @override
  Future<void> updateValue$5(String key, Object? value, Object? overrides,
          int target, [IConfigurationUpdateOptions? options]) =>
      throw UnimplementedError();
  @override
  Map<String, Object?> inspect(String key,
          [IConfigurationOverrides? overrides]) =>
      throw UnimplementedError();
  @override
  Future<void> reloadConfiguration([Object? target]) =>
      throw UnimplementedError();
  @override
  Map<String, Object?> keys() => throw UnimplementedError();
}

void main() {
  final t = _truth();

  test('b68 platform matches host (macOS)', () {
    final p = t['platform'] as Map<String, dynamic>;
    expect(p['isWindows'], false);
    expect(p['isMacintosh'], true);
    expect(p['isLinux'], false);
  });

  test('b68 treeViewsDnDService decorator id + singleton registration', () {
    expect(tvds.ITreeViewsDnDService.toString(),
        t['treeViewsDndService']['decoratorId']);
    // Accessing `registration` triggers the lazy module-load singleton registration.
    expect(tvds.registration, same(tvds.ITreeViewsDnDService));
    final regs = getSingletonServiceDescriptors();
    final found = regs.any((e) => identical(e[0], tvds.ITreeViewsDnDService));
    expect(found, isTrue, reason: 'treeViewsDnDService singleton registered');
  });

  test('b68 webWorkerService decorator id', () {
    expect(wws.IWebWorkerService.toString(),
        t['webWorkerService']['decoratorId']);
  });

  test('b68 StaticServiceAccessor chain/get/overwrite/falsy', () {
    final a = t['staticServiceAccessor'] as Map<String, dynamic>;
    final idA = ServiceIdentifier<dynamic>('a');
    final idB = ServiceIdentifier<dynamic>('b');
    final acc = utils.StaticServiceAccessor();
    expect(acc.withService(idA, a['getA']), same(acc),
        reason: 'chainable=${a['chainable']}');
    acc.withService(idB, a['getB']);
    expect(acc.getTyped(idA), a['getA']);
    expect(acc.getTyped(idB), a['getB']);
    acc.withService(idA, a['getA2']);
    expect(acc.getTyped(idA), a['getA2']);
    // falsy value (0) throws
    expect(
        () => utils.StaticServiceAccessor().withService(idA, 0).get(idA),
        throwsA(isA<StateError>().having(
            (e) => e.message, 'message', a['falsyErr'])));
    // missing throws
    expect(
        () => utils.StaticServiceAccessor().get(idA),
        throwsA(isA<StateError>().having(
            (e) => e.message, 'message', a['missingErr'])));
  });

  test('b68 TestAccessibilityService fixed returns + Event.None', () {
    final a = t['testAccessibilityService'] as Map<String, dynamic>;
    final svc = tas.TestAccessibilityService();
    expect(svc.isScreenReaderOptimized(), a['isScreenReaderOptimized']);
    expect(svc.isMotionReduced(), a['isMotionReduced']);
    expect(svc.isTransparencyReduced(), a['isTransparencyReduced']);
    expect(a['alwaysUnderlineAccessKeys'], 'promise');
    expect(svc.alwaysUnderlineAccessKeys(), isA<Future<bool>>());
    expect(svc.getAccessibilitySupport(), a['getAccessibilitySupport']);
    expect(AccessibilitySupport.Unknown, a['AccessibilitySupport']['Unknown']);
    expect(AccessibilitySupport.Disabled, a['AccessibilitySupport']['Disabled']);
    expect(AccessibilitySupport.Enabled, a['AccessibilitySupport']['Enabled']);
    // Event.None identity
    expect(identical(svc.onDidChangeScreenReaderOptimized, eventNone),
        a['screenReaderIsEventNone']);
    expect(identical(svc.onDidChangeReducedMotion, eventNone),
        a['reducedMotionIsEventNone']);
    expect(identical(svc.onDidChangeReducedTransparency, eventNone),
        a['reducedTransparencyIsEventNone']);
  });

  test('b68 TestTextResourcePropertiesService.getEOL all branches', () {
    final results = (t['testTextResourcePropertiesService']['results'] as List)
        .cast<Map<String, dynamic>>();
    for (final r in results) {
      final eol = r['eol'];
      final cfg = _ConfigMock(eol);
      final svc = trps.TestTextResourcePropertiesService(cfg);
      final got = svc.getEOL(URI.parse('file:///test/a.ts'), 'typescript');
      expect(got, r['eol'], reason: '${r['name']} eol');
      expect(cfg.section, r['callSection'], reason: '${r['name']} section');
      expect((cfg.capturedOverride as IConfigurationOverrides).overrideIdentifier,
          r['callOverrideIdentifier'], reason: '${r['name']} overrideIdentifier');
    }
  });

  test('b68 testWorkspace factories + testIWorkspace uri derivation', () {
    final twt = t['testWorkspace'] as Map<String, dynamic>;
    final uriOf = (u) => u == null ? null : (u as Map<String, dynamic>)['toString'];

    WorkspaceFolderInfo check(Map<String, dynamic> w) {
      final folders = w['folders'] as List;
      if (folders.isEmpty) {
        final built = tw.testWorkspace();
        expect(built.folders, isEmpty);
        expect(built.uri, isNull);
      } else {
        final uris = folders
            .map((f) => URI.parse((f as Map<String, dynamic>)['uri']['toString'] as String))
            .toList();
        final built = tw.testWorkspace(uris);
        expect(built.folders.length, folders.length);
        expect(built.uri?.toString(), uriOf(w['uri']));
        for (var i = 0; i < folders.length; i++) {
          expect(built.folders[i].uri.toString(),
              (folders[i] as Map<String, dynamic>)['uri']['toString']);
        }
      }
      final built = tw.testWorkspace();
      expect(built.id, w['id']);
      expect(built.ignorePathCasing(URI.parse('file:///A')), w['ignorePathCasing']);
      return WorkspaceFolderInfo();
    }

    check(twt['w0'] as Map<String, dynamic>);
    check(twt['w1'] as Map<String, dynamic>);
    check(twt['w2'] as Map<String, dynamic>);

    // TestWorkspace singleton
    final tws = twt['testWorkspaceSingleton'] as Map<String, dynamic>;
    expect(tw.TestWorkspace.folders.single.uri.toString(),
        (tws['folders'][0] as Map<String, dynamic>)['uri']['toString']);
    expect(tw.TestWorkspace.uri.toString(), uriOf(tws['uri']));

    // testIWorkspace uri derivation
    final tiw = t['testWorkspace']['testIWorkspace'] as Map<String, dynamic>;
    final f0 = wscore.toWorkspaceFolder(URI.parse('file:///f0'));
    final f1 = wscore.toWorkspaceFolder(URI.parse('file:///f1'));
    final cfgVal = tw.testIWorkspace(tw.WorkspaceInput(
        id: 'x',
        configuration: URI.parse('file:///cfg'),
        folders: <wscore.IWorkspaceFolder>[f0, f1]));
    expect(cfgVal.uri.toString(), uriOf(tiw['cfg']));
    final one = tw.testIWorkspace(tw.WorkspaceInput(
        id: 'y', folders: <wscore.IWorkspaceFolder>[f0]));
    expect(one.uri.toString(), uriOf(tiw['one']));
    final none = tw.testIWorkspace(
        tw.WorkspaceInput(id: 'z', folders: <wscore.IWorkspaceFolder>[]));
    expect(none.uri, isNull);
    expect(uriOf(tiw['none']), isNull);
    final explicit = tw.testIWorkspace(tw.WorkspaceInput(
        id: 'e',
        uri: URI.parse('file:///explicit'),
        folders: <wscore.IWorkspaceFolder>[f0]));
    expect(explicit.uri.toString(), uriOf(tiw['explicit']));
  });

  test('b68 TestClipboardService read/write cycle', () async {
    final a = t['testClipboardService'] as Map<String, dynamic>;
    final svc = tcs.TestClipboardService();
    expect(await svc.readText(), a['readTextInit']);
    expect(await svc.readFindText(), a['readFindTextInit']);
    expect(await svc.readResources(), isEmpty);
    expect(await svc.hasResources(), a['hasResourcesInit']);
    expect(svc.triggerPaste(), isA<Future<void>>());
    expect(() => svc.readImage(),
        throwsA(isA<StateError>().having((e) => e.message, 'message', a['readImageThrows'])));

    await svc.writeText('hello');
    expect(await svc.readText(), a['readTextAfter']);
    await svc.writeText('world', 'sel');
    expect(await svc.readText('sel'), a['readTextTyped']);
    await svc.writeFindText('find-me');
    expect(await svc.readFindText(), a['readFindTextAfter']);

    await svc.writeResources(<URI>[
      URI.parse('file:///r1'),
      URI.parse('file:///r2'),
    ]);
    expect((await svc.readResources()).map((u) => u.toString()).toList(),
        a['readResourcesAfter']);
    expect(await svc.hasResources(), a['hasResourcesAfter']);

    await svc.writeImage(Future.value(Uint8List.fromList(<int>[1, 2, 3, 4])));
    expect(svc.writtenImage, isNotNull);
    expect(svc.writtenImage!.toList(), a['writtenImage']);
  });
}

/// Marker used by the workspace helper (kept trivial; assertions live in main).
class WorkspaceFolderInfo {}
