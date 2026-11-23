// batch66: undoRedo.ts + extensionGalleryManifest.ts + usLayoutResolvedKeybinding.ts.
// All assertions are data-driven from batch66_truth.json (Node TS transpile+vm
// real evaluation of the three files and their real local dependency chains).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/keyCodes.dart' as kc;
import 'package:semi_design_flutter/src/monaco/base/common/keybindings.dart' as kb;
import 'package:semi_design_flutter/src/monaco/base/common/platform.dart' as plat;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/platform/extensionManagement/common/extensionGalleryManifest.dart'
    as eg;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/instantiation.dart'
    show createDecorator;
import 'package:semi_design_flutter/src/monaco/platform/keybinding/common/usLayoutResolvedKeybinding.dart'
    as us;
import 'package:semi_design_flutter/src/monaco/platform/undoRedo/common/undoRedo.dart'
    as ur;

Map<String, dynamic> _truth() => jsonDecode(
      File('tool/ts2dart/batch66_truth.json').readAsStringSync(),
    ) as Map<String, dynamic>;

void main() {
  late Map<String, dynamic> t;
  setUpAll(() => t = _truth());

  // ---------------------------------------------------------------- undoRedo
  test('b66 undoRedo: decorator id + serviceId memoize', () {
    final d = t['undoRedo']['decorator'] as Map<String, dynamic>;
    expect(ur.IUndoRedoService.toString(), d['id']);
    expect(identical(createDecorator(d['serviceId'] as String), ur.IUndoRedoService), isTrue);
  });

  test('b66 undoRedo: UndoRedoElementType numeric values', () {
    final e = t['undoRedo']['elementType'] as Map<String, dynamic>;
    expect(ur.UndoRedoElementType.Resource, e['Resource']);
    expect(ur.UndoRedoElementType.Workspace, e['Workspace']);
  });

  test('b66 undoRedo: ResourceEditStackSnapshot fields', () {
    final s = t['undoRedo']['snapshot'] as Map<String, dynamic>;
    // truth serializes the exact URI passed in; use a URI whose toString matches.
    final uri = URI.parse(s['resource'] as String);
    final snap = ur.ResourceEditStackSnapshot(uri, (s['elements'] as List).cast<int>());
    expect(identical(snap.resource, uri), isTrue);
    expect(snap.elements, s['elements']);
  });

  test('b66 undoRedo: UndoRedoGroup id allocator + nextOrder', () {
    final g = t['undoRedo']['group'] as Map<String, dynamic>;
    // 1:1 TS module-load order: None is created first (id 0).
    expect(ur.UndoRedoGroup.None.id, g['noneId']);
    expect(ur.UndoRedoGroup.None.nextOrder(), g['noneNextOrder']);
    final g1 = ur.UndoRedoGroup();
    final g2 = ur.UndoRedoGroup();
    expect(g1.id, g['g1Id']);
    expect(g2.id, g['g2Id']);
    expect([g1.nextOrder(), g1.nextOrder(), g1.nextOrder()], g['g1Orders']);
  });

  test('b66 undoRedo: UndoRedoSource id allocator + nextOrder', () {
    final s = t['undoRedo']['source'] as Map<String, dynamic>;
    expect(ur.UndoRedoSource.None.id, s['noneId']);
    expect(ur.UndoRedoSource.None.nextOrder(), s['noneNextOrder']);
    final s1 = ur.UndoRedoSource();
    final s2 = ur.UndoRedoSource();
    expect(s1.id, s['s1Id']);
    expect(s2.id, s['s2Id']);
    expect([s1.nextOrder(), s1.nextOrder()], s['s1Orders']);
  });

  // ---------------------------------------------- extensionGalleryManifest
  test('b66 gallery: decorator + config keys match truth', () {
    final m = t['extensionGalleryManifest'] as Map<String, dynamic>;
    final d = m['decorator'] as Map<String, dynamic>;
    expect(eg.IExtensionGalleryManifestService.toString(), d['id']);
    expect(
        identical(createDecorator(d['serviceId'] as String),
            eg.IExtensionGalleryManifestService),
        isTrue);
    expect(eg.ExtensionGalleryServiceUrlConfigKey, m['serviceUrlKey']);
    expect(eg.ExtensionGalleryAuthProviderConfigKey, m['authProviderKey']);
  });

  test('b66 gallery: all const enum members match truth', () {
    final m = t['extensionGalleryManifest'] as Map<String, dynamic>;
    for (final pair in (m['resourceType'] as List)) {
      expect(_enumVal(eg.ExtensionGalleryResourceType, pair[0] as String), pair[1]);
    }
    for (final pair in (m['flag'] as List)) {
      expect(_enumVal(eg.Flag, pair[0] as String), pair[1]);
    }
    for (final pair in (m['status'] as List)) {
      expect(_enumVal(eg.ExtensionGalleryManifestStatus, pair[0] as String), pair[1]);
    }
  });

  test('b66 gallery: getExtensionGalleryManifestResourceUri matches truth', () {
    final m = t['extensionGalleryManifest'] as Map<String, dynamic>;
    final manifest = _Manifest([
      eg.ExtensionGalleryManifestResource(id: 'A', type: 'ExtensionQueryService/v1'),
      eg.ExtensionGalleryManifestResource(id: 'B', type: 'ExtensionQueryService/v2'),
      eg.ExtensionGalleryManifestResource(id: 'C', type: 'PublisherViewUriTemplate'),
      eg.ExtensionGalleryManifestResource(id: 'D', type: 'Other/v1'),
    ]);
    for (final c in (m['getResourceUri'] as List)) {
      final caseMap = c as Map<String, dynamic>;
      final r = eg.getExtensionGalleryManifestResourceUri(
          manifest, caseMap['type'] as String);
      // truth omits `r` when the TS function returned undefined.
      expect(r, caseMap.containsKey('r') ? caseMap['r'] : null,
          reason: 'type=${caseMap['type']}');
    }
  });

  // ------------------------------------------- usLayoutResolvedKeybinding
  test('b66 usLayout: OS + key/scan code sample values match truth', () {
    final u = t['usLayout'] as Map<String, dynamic>;
    final os = u['os'] as Map<String, dynamic>;
    expect(plat.OperatingSystem.Windows, os['Windows']);
    expect(plat.OperatingSystem.Macintosh, os['Macintosh']);
    expect(plat.OperatingSystem.Linux, os['Linux']);
    final kcs = u['keyCodeSample'] as Map<String, dynamic>;
    for (final e in kcs.entries) {
      expect(_intConst(kc.KeyCode, e.key), e.value, reason: 'KeyCode.${e.key}');
    }
    final scs = u['scanCodeSample'] as Map<String, dynamic>;
    for (final e in scs.entries) {
      expect(_intConst(kc.ScanCode, e.key), e.value, reason: 'ScanCode.${e.key}');
    }
  });

  test('b66 usLayout: getDispatchStr matches truth', () {
    final u = t['usLayout'] as Map<String, dynamic>;
    final cases = {
      'plainKeyA': _kcc(false, false, false, false, kc.KeyCode.KeyA),
      'ctrlShiftA': _kcc(true, true, false, false, kc.KeyCode.KeyA),
      'allModsDigit1': _kcc(true, true, true, true, kc.KeyCode.Digit1),
      'ctrlOnly': _kcc(false, false, false, false, kc.KeyCode.Ctrl),
      'shiftOnly': _kcc(false, false, false, false, kc.KeyCode.Shift),
      'altOnly': _kcc(false, false, false, false, kc.KeyCode.Alt),
      'metaOnly': _kcc(false, false, false, false, kc.KeyCode.Meta),
      'ctrlWithCtrlKey': _kcc(true, false, false, false, kc.KeyCode.Ctrl),
      'arrowUp': _kcc(false, false, false, false, kc.KeyCode.UpArrow),
    };
    for (final c in (u['dispatch'] as List)) {
      final cm = c as Map<String, dynamic>;
      expect(us.USLayoutResolvedKeybinding.getDispatchStr(cases[cm['name']]!),
          cm['r'],
          reason: 'dispatch ${cm['name']}');
    }
  });

  test('b66 usLayout: resolveKeybinding matches truth', () {
    final u = t['usLayout'] as Map<String, dynamic>;
    final cases = <String, List<kb.Keybinding>>{
      'oneKCC': [kb.Keybinding([_kcc(false, false, false, false, kc.KeyCode.KeyA)])],
      'scanChords': [kb.Keybinding([_scc(true, false, false, false, kc.ScanCode.KeyA)])],
      'mixedNulls': [
        kb.Keybinding([
          _scc(false, false, false, false, kc.ScanCode.IntlHash),
          _kcc(false, false, false, false, kc.KeyCode.KeyA),
        ])
      ],
    };
    for (final c in (u['resolve'] as List)) {
      final cm = c as Map<String, dynamic>;
      final resolved =
          us.USLayoutResolvedKeybinding.resolveKeybinding(cases[cm['name']]![0],
              plat.OperatingSystem.Linux);
      final expectedR = cm['r'] as List;
      expect(resolved.length, expectedR.length, reason: 'resolve ${cm['name']} len');
      for (int i = 0; i < resolved.length; i++) {
        final exp = expectedR[i] as Map<String, dynamic>;
        if (exp.containsKey('chords')) {
          expect(resolved[i].chords.length, exp['chords']);
        }
        expect(resolved[i].getLabel(), exp['label'],
            reason: 'resolve ${cm['name']} label');
        expect(resolved[i].getDispatchChords(), exp['dispatch'],
            reason: 'resolve ${cm['name']} dispatch');
      }
    }
  });

  test('b66 usLayout: instance label methods match truth', () {
    final u = t['usLayout'] as Map<String, dynamic>;
    final labels = u['labels'] as Map<String, dynamic>;

    final linuxArrow = us.USLayoutResolvedKeybinding(
        [_kcc(false, false, false, false, kc.KeyCode.UpArrow)],
        plat.OperatingSystem.Linux);
    _expectLabelSet(linuxArrow, labels['linuxArrow'] as Map<String, dynamic>);

    final macArrow = us.USLayoutResolvedKeybinding(
        [_kcc(false, false, false, false, kc.KeyCode.UpArrow)],
        plat.OperatingSystem.Macintosh);
    _expectLabelSet(macArrow, labels['macArrow'] as Map<String, dynamic>);

    final dup = us.USLayoutResolvedKeybinding(
        [_kcc(true, false, false, false, kc.KeyCode.Ctrl)],
        plat.OperatingSystem.Linux);
    _expectLabelSet(dup, labels['dupModifier'] as Map<String, dynamic>);

    final keyA = us.USLayoutResolvedKeybinding(
        [_kcc(false, false, false, false, kc.KeyCode.KeyA)],
        plat.OperatingSystem.Linux);
    _expectLabelSet(keyA, labels['keyA'] as Map<String, dynamic>);

    for (final c in (labels['singleMods'] as List)) {
      final cm = c as Map<String, dynamic>;
      final chord = _kcc(
        cm['name'] == 'ctrl',
        cm['name'] == 'shift',
        cm['name'] == 'alt',
        cm['name'] == 'meta',
        {'ctrl': kc.KeyCode.Ctrl, 'shift': kc.KeyCode.Shift,
          'alt': kc.KeyCode.Alt, 'meta': kc.KeyCode.Meta}[cm['name']]!,
      );
      final inst = us.USLayoutResolvedKeybinding([chord], plat.OperatingSystem.Linux);
      expect(inst.getSingleModifierDispatchChords(), cm['r'],
          reason: 'singleMods ${cm['name']}');
    }
  });
}

// ---- helpers ----

kb.KeyCodeChord _kcc(bool ctrl, bool shift, bool alt, bool meta, int keyCode) =>
    kb.KeyCodeChord(ctrl, shift, alt, meta, keyCode);

kb.ScanCodeChord _scc(bool ctrl, bool shift, bool alt, bool meta, int scanCode) =>
    kb.ScanCodeChord(ctrl, shift, alt, meta, scanCode);

void _expectLabelSet(us.USLayoutResolvedKeybinding inst, Map<String, dynamic> exp) {
  if (exp.containsKey('label')) expect(inst.getLabel(), exp['label'], reason: 'label');
  if (exp.containsKey('aria')) expect(inst.getAriaLabel(), exp['aria'], reason: 'aria');
  if (exp.containsKey('eacc')) {
    expect(inst.getElectronAccelerator(), exp['eacc'], reason: 'eacc');
  }
  if (exp.containsKey('user')) {
    expect(inst.getUserSettingsLabel(), exp['user'], reason: 'user');
  }
  if (exp.containsKey('wysiwyg')) expect(inst.isWYSIWYG(), exp['wysiwyg']);
  if (exp.containsKey('single')) {
    expect(inst.getSingleModifierDispatchChords(), exp['single'], reason: 'single');
  }
}

/// Read a String const enum static member via a tiny reflective carrier.
String _enumVal(Type enumClass, String member) => switch (enumClass) {
      eg.ExtensionGalleryResourceType => switch (member) {
          'ExtensionQueryService' => eg.ExtensionGalleryResourceType.ExtensionQueryService,
          'ExtensionLatestVersionUri' => eg.ExtensionGalleryResourceType.ExtensionLatestVersionUri,
          'ExtensionStatisticsUri' => eg.ExtensionGalleryResourceType.ExtensionStatisticsUri,
          'PublisherViewUri' => eg.ExtensionGalleryResourceType.PublisherViewUri,
          'ExtensionDetailsViewUri' => eg.ExtensionGalleryResourceType.ExtensionDetailsViewUri,
          'ExtensionRatingViewUri' => eg.ExtensionGalleryResourceType.ExtensionRatingViewUri,
          'ExtensionResourceUri' => eg.ExtensionGalleryResourceType.ExtensionResourceUri,
          'ContactSupportUri' => eg.ExtensionGalleryResourceType.ContactSupportUri,
          _ => throw StateError('unknown $member'),
        },
      eg.Flag => switch (member) {
          'None' => eg.Flag.None,
          'IncludeVersions' => eg.Flag.IncludeVersions,
          'IncludeFiles' => eg.Flag.IncludeFiles,
          'IncludeCategoryAndTags' => eg.Flag.IncludeCategoryAndTags,
          'IncludeSharedAccounts' => eg.Flag.IncludeSharedAccounts,
          'IncludeVersionProperties' => eg.Flag.IncludeVersionProperties,
          'ExcludeNonValidated' => eg.Flag.ExcludeNonValidated,
          'IncludeInstallationTargets' => eg.Flag.IncludeInstallationTargets,
          'IncludeAssetUri' => eg.Flag.IncludeAssetUri,
          'IncludeStatistics' => eg.Flag.IncludeStatistics,
          'IncludeLatestVersionOnly' => eg.Flag.IncludeLatestVersionOnly,
          'Unpublished' => eg.Flag.Unpublished,
          'IncludeNameConflictInfo' => eg.Flag.IncludeNameConflictInfo,
          'IncludeLatestPrereleaseAndStableVersionOnly' =>
            eg.Flag.IncludeLatestPrereleaseAndStableVersionOnly,
          _ => throw StateError('unknown $member'),
        },
      eg.ExtensionGalleryManifestStatus => switch (member) {
          'Available' => eg.ExtensionGalleryManifestStatus.Available,
          'RequiresSignIn' => eg.ExtensionGalleryManifestStatus.RequiresSignIn,
          'AccessDenied' => eg.ExtensionGalleryManifestStatus.AccessDenied,
          'Unavailable' => eg.ExtensionGalleryManifestStatus.Unavailable,
          _ => throw StateError('unknown $member'),
        },
      _ => throw StateError('unknown enum class $enumClass'),
    };

int _intConst(Type cls, String member) {
  if (cls == kc.KeyCode) {
    return {
      'Unknown': kc.KeyCode.Unknown, 'Ctrl': kc.KeyCode.Ctrl,
      'Shift': kc.KeyCode.Shift, 'Alt': kc.KeyCode.Alt,
      'Meta': kc.KeyCode.Meta, 'KeyA': kc.KeyCode.KeyA,
      'KeyZ': kc.KeyCode.KeyZ, 'Digit0': kc.KeyCode.Digit0,
      'Digit1': kc.KeyCode.Digit1, 'Minus': kc.KeyCode.Minus,
      'UpArrow': kc.KeyCode.UpArrow, 'Escape': kc.KeyCode.Escape,
    }[member]!;
  }
  if (cls == kc.ScanCode) {
    return {
      'None': kc.ScanCode.None, 'KeyA': kc.ScanCode.KeyA,
      'KeyZ': kc.ScanCode.KeyZ, 'Digit0': kc.ScanCode.Digit0,
      'Digit1': kc.ScanCode.Digit1, 'Minus': kc.ScanCode.Minus,
      'IntlHash': kc.ScanCode.IntlHash, 'Escape': kc.ScanCode.Escape,
    }[member]!;
  }
  throw StateError('unknown class $cls');
}

class _Manifest implements eg.IExtensionGalleryManifest {
  @override
  final String version = '1';
  @override
  final List<eg.ExtensionGalleryManifestResource> resources;
  @override
  Object? get capabilities => null;
  _Manifest(this.resources);
}
