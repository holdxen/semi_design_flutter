import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' as events;
import 'package:semi_design_flutter/src/monaco/platform/accessibility/common/accessibility.dart'
    as acc;
import 'package:semi_design_flutter/src/monaco/platform/configuration/common/configuration.dart'
    as cfg;
import 'package:semi_design_flutter/src/monaco/platform/telemetry/common/telemetry.dart'
    as telemetry;
import 'package:semi_design_flutter/src/monaco/platform/accessibilitySignal/browser/accessibilitySignalService.dart'
    as asvc;

final Map<String, dynamic> _truth =
    jsonDecode(File('tool/ts2dart/batch122_truth.json').readAsStringSync())
        as Map<String, dynamic>;

String _undef(Object? value) => value == null ? 'undefined' : value as String;

Map<String, dynamic> _section(String name) =>
    (_truth[name] as Map).cast<String, dynamic>();

class _FakeAudio implements asvc.AudioElementLike {
  _FakeAudio(this.url, this.log);
  final String url;
  final List<Map<String, Object?>> log;
  @override
  double volume = 0;
  @override
  num currentTime = 0;
  void Function()? _ended;
  void Function(Object)? _error;
  @override
  void setOnEnded(void Function() callback) => _ended = callback;
  @override
  void setOnError(void Function(Object error) callback) => _error = callback;
  @override
  Future<void> play() async {
    log.add(<String, Object?>{'op': 'play', 'url': url, 'volume': volume});
    _ended?.call();
  }
}

class _FakeConfigChangeEvent implements cfg.IConfigurationChangeEvent {
  @override
  bool affectsConfiguration(String key, [Object? value]) => true;

  @override
  dynamic noSuchMethod(Invocation inv) => super.noSuchMethod(inv);
}

class _FakeConfig implements cfg.IConfigurationServiceType {
  final Map<String, Object?> values = <String, Object?>{};
  final events.Emitter<Object> _changes = events.Emitter<Object>();

  Object? getValue$1(String section) => values[section];

  events.Event<Object> get onDidChangeConfiguration => _changes.event;

  void set(String key, Object? value) {
    values[key] = value;
    _changes.fire(_FakeConfigChangeEvent());
  }

  @override
  dynamic noSuchMethod(Invocation inv) {
    if (inv.isGetter && inv.memberName == #onDidChangeConfiguration) {
      return onDidChangeConfiguration;
    }
    if (inv.isMethod && inv.memberName == #getValue$1) {
      return getValue$1(inv.positionalArguments.first as String);
    }
    return super.noSuchMethod(inv);
  }
}

class _FakeAccessibility implements acc.IAccessibilityServiceType {
  final events.Emitter<void> _srChanges = events.Emitter<void>();
  bool sr = false;
  final List<String> statuses = <String>[];

  events.Event<void> get onDidChangeScreenReaderOptimized => _srChanges.event;
  bool isScreenReaderOptimized() => sr;
  void status(String message) => statuses.add(message);

  @override
  dynamic noSuchMethod(Invocation inv) {
    if (inv.isGetter && inv.memberName == #onDidChangeScreenReaderOptimized) {
      return onDidChangeScreenReaderOptimized;
    }
    if (inv.isMethod && inv.memberName == #isScreenReaderOptimized) {
      return isScreenReaderOptimized();
    }
    if (inv.isMethod && inv.memberName == #status) {
      status(inv.positionalArguments.first as String);
      return null;
    }
    return super.noSuchMethod(inv);
  }
}

class _FakeTelemetry implements telemetry.ITelemetryServiceType {
  final List<Map<String, Object?>> logs = <Map<String, Object?>>[];
  void publicLog2(String name, [Object? data]) =>
      logs.add(<String, Object?>{'name': name, 'data': data});

  @override
  dynamic noSuchMethod(Invocation inv) {
    if (inv.isMethod && inv.memberName == #publicLog2) {
      publicLog2(inv.positionalArguments.first as String,
          inv.positionalArguments.length > 1 ? inv.positionalArguments[1] : null);
      return null;
    }
    return super.noSuchMethod(inv);
  }
}

final _FakeConfig _config = _FakeConfig();
final _FakeAccessibility _access = _FakeAccessibility();
final _FakeTelemetry _telemetry = _FakeTelemetry();
final List<Map<String, Object?>> _audioLog = <Map<String, Object?>>[];

asvc.AccessibilitySignalService _newService() {
  _config.values.clear();
  _access.sr = false;
  _access.statuses.clear();
  _telemetry.logs.clear();
  _audioLog.clear();
  return asvc.AccessibilitySignalService(_config, _access, _telemetry);
}

Map<String, asvc.Sound> get _soundByName => <String, asvc.Sound>{
      'error': asvc.Sound.error,
      'warning': asvc.Sound.warning,
      'success': asvc.Sound.success,
      'foldedArea': asvc.Sound.foldedArea,
      'break': asvc.Sound.break_,
      'quickFixes': asvc.Sound.quickFixes,
      'taskCompleted': asvc.Sound.taskCompleted,
      'taskFailed': asvc.Sound.taskFailed,
      'terminalBell': asvc.Sound.terminalBell,
      'diffLineInserted': asvc.Sound.diffLineInserted,
      'diffLineDeleted': asvc.Sound.diffLineDeleted,
      'diffLineModified': asvc.Sound.diffLineModified,
      'requestSent': asvc.Sound.requestSent,
      'responseReceived1': asvc.Sound.responseReceived1,
      'responseReceived2': asvc.Sound.responseReceived2,
      'responseReceived3': asvc.Sound.responseReceived3,
      'responseReceived4': asvc.Sound.responseReceived4,
      'clear': asvc.Sound.clear,
      'save': asvc.Sound.save,
      'format': asvc.Sound.format,
      'voiceRecordingStarted': asvc.Sound.voiceRecordingStarted,
      'voiceRecordingStopped': asvc.Sound.voiceRecordingStopped,
      'progress': asvc.Sound.progress,
      'chatEditModifiedFile': asvc.Sound.chatEditModifiedFile,
      'editsKept': asvc.Sound.editsKept,
      'editsUndone': asvc.Sound.editsUndone,
      'nextEditSuggestion': asvc.Sound.nextEditSuggestion,
      'terminalCommandSucceeded': asvc.Sound.terminalCommandSucceeded,
      'chatUserActionRequired': asvc.Sound.chatUserActionRequired,
      'codeActionTriggered': asvc.Sound.codeActionTriggered,
      'codeActionApplied': asvc.Sound.codeActionApplied,
      'confetti': asvc.Sound.confetti,
    };

Map<String, asvc.AccessibilitySignal> get _signalByName =>
    <String, asvc.AccessibilitySignal>{
      'errorAtPosition': asvc.AccessibilitySignal.errorAtPosition,
      'warningAtPosition': asvc.AccessibilitySignal.warningAtPosition,
      'errorOnLine': asvc.AccessibilitySignal.errorOnLine,
      'warningOnLine': asvc.AccessibilitySignal.warningOnLine,
      'foldedArea': asvc.AccessibilitySignal.foldedArea,
      'break': asvc.AccessibilitySignal.break_,
      'inlineSuggestion': asvc.AccessibilitySignal.inlineSuggestion,
      'nextEditSuggestion': asvc.AccessibilitySignal.nextEditSuggestion,
      'terminalQuickFix': asvc.AccessibilitySignal.terminalQuickFix,
      'onDebugBreak': asvc.AccessibilitySignal.onDebugBreak,
      'noInlayHints': asvc.AccessibilitySignal.noInlayHints,
      'taskCompleted': asvc.AccessibilitySignal.taskCompleted,
      'taskFailed': asvc.AccessibilitySignal.taskFailed,
      'terminalCommandFailed': asvc.AccessibilitySignal.terminalCommandFailed,
      'terminalCommandSucceeded':
          asvc.AccessibilitySignal.terminalCommandSucceeded,
      'terminalBell': asvc.AccessibilitySignal.terminalBell,
      'notebookCellCompleted': asvc.AccessibilitySignal.notebookCellCompleted,
      'notebookCellFailed': asvc.AccessibilitySignal.notebookCellFailed,
      'diffLineInserted': asvc.AccessibilitySignal.diffLineInserted,
      'diffLineDeleted': asvc.AccessibilitySignal.diffLineDeleted,
      'diffLineModified': asvc.AccessibilitySignal.diffLineModified,
      'chatEditModifiedFile': asvc.AccessibilitySignal.chatEditModifiedFile,
      'chatRequestSent': asvc.AccessibilitySignal.chatRequestSent,
      'chatResponseReceived': asvc.AccessibilitySignal.chatResponseReceived,
      'confetti': asvc.AccessibilitySignal.confetti,
      'codeActionTriggered': asvc.AccessibilitySignal.codeActionTriggered,
      'codeActionApplied': asvc.AccessibilitySignal.codeActionApplied,
      'progress': asvc.AccessibilitySignal.progress,
      'clear': asvc.AccessibilitySignal.clear,
      'save': asvc.AccessibilitySignal.save,
      'format': asvc.AccessibilitySignal.format,
      'voiceRecordingStarted': asvc.AccessibilitySignal.voiceRecordingStarted,
      'voiceModeStarted': asvc.AccessibilitySignal.voiceModeStarted,
      'voiceRecordingStopped': asvc.AccessibilitySignal.voiceRecordingStopped,
      'voiceModeStopped': asvc.AccessibilitySignal.voiceModeStopped,
      'dictationDisconnected': asvc.AccessibilitySignal.dictationDisconnected,
      'editsKept': asvc.AccessibilitySignal.editsKept,
      'editsUndone': asvc.AccessibilitySignal.editsUndone,
      'chatUserActionRequired':
          asvc.AccessibilitySignal.chatUserActionRequired,
    };

void main() {
  setUp(() {
    asvc.audioFactoryProvider = (String url) => _FakeAudio(url, _audioLog);
    asvc.audioUrlProvider = (String fileName) =>
        'vs/platform/accessibilitySignal/browser/media/$fileName';
    asvc.randomProvider = () => 0;
  });
  tearDown(() {
    asvc.audioFactoryProvider = null;
    asvc.audioUrlProvider = null;
  });

  test('static Sound registry', () {
    final expected = (_truth['sounds'] as Map).cast<String, String>();
    final actual = _soundByName;
    expect(actual.keys.toSet(), expected.keys.toSet());
    for (final key in expected.keys) {
      expect(actual[key]!.fileName, expected[key], reason: 'Sound.$key');
    }
  });

  test('static AccessibilitySignal registry', () {
    final expected = (_truth['signals'] as Map).cast<String, dynamic>();
    final actual = _signalByName;
    expect(actual.keys.toSet(), expected.keys.toSet());
    for (final key in expected.keys) {
      final sig = actual[key]!;
      final exp = (expected[key] as Map).cast<String, dynamic>();
      expect(sig.name, exp['name'], reason: '$key.name');
      expect(sig.settingsKey, exp['settingsKey'], reason: '$key.settingsKey');
      expect(_undef(sig.legacySoundSettingsKey), exp['legacySoundSettingsKey'],
          reason: '$key.legacySoundSettingsKey');
      expect(_undef(sig.legacyAnnouncementSettingsKey),
          exp['legacyAnnouncementSettingsKey'],
          reason: '$key.legacyAnnouncementSettingsKey');
      expect(_undef(sig.announcementMessage), exp['announcementMessage'],
          reason: '$key.announcementMessage');
      expect(sig.managesOwnEnablement, exp['managesOwnEnablement'],
          reason: '$key.managesOwnEnablement');
      expect(sig.sound.randomOneOf.map((s) => s.fileName).toList(),
          exp['sounds'], reason: '$key.sounds');
    }
    expect(asvc.AccessibilitySignal.allAccessibilitySignals.length,
        _truth['allCount']);
  });

  test('SoundSource getSound deterministic/single', () {
    final expected = _section('soundSource');
    expect(asvc.AccessibilitySignal.chatResponseReceived.sound
        .getSound(true).fileName, expected['deterministic']);
    expect(asvc.AccessibilitySignal.errorAtPosition.sound
        .getSound().fileName, expected['single']);
    expect(asvc.AccessibilitySignal.errorAtPosition.sound
        .getSound(false).fileName, expected['singleDeterministic']);
  });

  test('enabled states truth table', () {
    final rows = (_truth['enabledStates'] as List).cast<Map>();
    final sig = asvc.AccessibilitySignal.errorOnLine;
    for (final row in rows) {
      final svc = _newService();
      _config.set(sig.settingsKey, <String, Object?>{
        'sound': row['state'],
        'announcement': row['state'],
      });
      _access.sr = row['sr'] as bool;
      final ug = row['ug'] as bool;
      expect(svc.isSoundEnabled(sig, ug), row['sound'],
          reason: '${row['state']}/sr=${row['sr']}/ug=$ug sound');
      expect(svc.isAnnouncementEnabled(sig, ug), row['announcement'],
          reason: '${row['state']}/sr=${row['sr']}/ug=$ug announcement');
      svc.dispose();
    }
  });

  test('no announcement message + managesOwnEnablement', () {
    final expectedNo = _section('noAnnouncement');
    final expectedManaged = _section('managedEnablement');
    final svc = _newService();
    final noAnnouncement = asvc.AccessibilitySignal.inlineSuggestion;
    _config.set(noAnnouncement.settingsKey, <String, Object?>{
      'sound': 'off',
      'announcement': 'on',
    });
    expect(svc.isAnnouncementEnabled(noAnnouncement),
        expectedNo['isAnnouncementEnabled']);
    expect(svc.isSoundEnabled(noAnnouncement), expectedNo['isSoundEnabled']);
    svc.dispose();

    // managesOwnEnablement: register a signal with the flag set.
    final managed = asvc.AccessibilitySignal.register(
      name: 'Managed',
      sound: asvc.Sound.error,
      settingsKey: 'managed.key',
      managesOwnEnablement: true,
    );
    final svc2 = _newService();
    _config.set('managed.key', <String, Object?>{
      'sound': 'off',
      'announcement': 'off',
    });
    expect(svc2.isSoundEnabled(managed), expectedManaged['sound']);
    expect(svc2.isAnnouncementEnabled(managed),
        expectedManaged['announcement']);
    svc2.dispose();
  });

  test('playSignal: announcement, telemetry, sound', () async {
    final expected = _section('playSignal');
    final svc = _newService();
    final sig = asvc.AccessibilitySignal.save;
    _config.set(sig.settingsKey, <String, Object?>{
      'sound': 'on',
      'announcement': 'on',
    });
    await svc.playSignal(
      sig,
      asvc.IAccessbilitySignalOptions(source: 'test.source', userGesture: true),
    );
    expect(_access.statuses, expected['status']);
    expect(_telemetry.logs, expected['telemetry']);
    expect(_audioLog, expected['audio']);
    svc.dispose();
  });

  test('playSignal modality filter + custom alert', () async {
    final svc = _newService();
    final sig = asvc.AccessibilitySignal.save;
    _config.set(sig.settingsKey, <String, Object?>{
      'sound': 'on',
      'announcement': 'on',
    });
    await svc.playSignal(sig, asvc.IAccessbilitySignalOptions(
        modality: asvc.AccessibilityModality.sound,
        customAlertMessage: 'CUSTOM'));
    expect(_access.statuses, _section('modalitySoundOnly')['status']);
    expect(_audioLog, _section('modalitySoundOnly')['audio']);
    _access.statuses.clear();
    _audioLog.clear();
    await svc.playSignal(sig, asvc.IAccessbilitySignalOptions(
        modality: asvc.AccessibilityModality.announcement,
        customAlertMessage: 'CUSTOM'));
    expect(_access.statuses, _section('modalityAnnouncementOnly')['status']);
    expect(_audioLog, _section('modalityAnnouncementOnly')['audio']);
    svc.dispose();
  });

  test('playSignals: dedup sounds, joined announcements, telemetry', () async {
    final expected = _section('playSignals');
    final svc = _newService();
    final a = asvc.AccessibilitySignal.save;
    final b = asvc.AccessibilitySignal.format;
    final c = asvc.AccessibilitySignal.clear;
    for (final signal in <asvc.AccessibilitySignal>[a, b, c]) {
      _config.set(signal.settingsKey, <String, Object?>{
        'sound': 'on',
        'announcement': 'on',
      });
    }
    await svc.playSignals(<Object>[
      a,
      asvc.SignalWithSource(b, 'src-b'),
      c,
      a,
    ]);
    expect(_access.statuses, expected['status']);
    expect(_telemetry.logs, expected['telemetry']);
    expect(_audioLog, expected['audio']);
    svc.dispose();
  });

  test('telemetry: volume gating, key formatting, dedup', () async {
    final expected = _section('telemetry');
    final svc = _newService();
    final sig = asvc.AccessibilitySignal.save;
    _config.set(sig.settingsKey, <String, Object?>{
      'sound': 'on',
      'announcement': 'on',
    });
    _config.set('accessibility.signalOptions.volume', 0);
    await svc.playSignal(sig);
    expect(_telemetry.logs.length, expected['zeroVolumeTelemetry']);
    _config.set('accessibility.signalOptions.volume', 150);
    await svc.playSignal(sig, asvc.IAccessbilitySignalOptions(source: 'src'));
    expect(_telemetry.logs, expected['withSource']);
    _access.sr = true;
    await svc.playSignal(sig, asvc.IAccessbilitySignalOptions(source: 'src'));
    expect(_telemetry.logs, expected['withSourceSr']);
    await svc.playSignal(sig, asvc.IAccessbilitySignalOptions(source: 'src'));
    expect(_telemetry.logs.length, expected['afterDedup']);
    svc.dispose();
  });

  test('getDelayMs with and without debounce', () {
    final enabled = _section('delaysEnabled');
    final svc = _newService();
    _config.set('accessibility.signalOptions.debouncePositionChanges', true);
    _config.set(
        'accessibility.signalOptions.experimental.delays.errorAtPosition',
        <String, Object?>{'sound': 11, 'announcement': 12});
    _config.set(
        'accessibility.signalOptions.experimental.delays.warningAtPosition',
        <String, Object?>{'sound': 21, 'announcement': 22});
    _config.set('accessibility.signalOptions.experimental.delays.general',
        <String, Object?>{'sound': 31, 'announcement': 32});
    expect(
        svc.getDelayMs(asvc.AccessibilitySignal.errorAtPosition,
            asvc.AccessibilityModality.sound, 'positional'),
        enabled['errorPosSound']);
    expect(
        svc.getDelayMs(asvc.AccessibilitySignal.errorAtPosition,
            asvc.AccessibilityModality.sound, 'line'),
        enabled['errorPosLine']);
    expect(
        svc.getDelayMs(asvc.AccessibilitySignal.warningAtPosition,
            asvc.AccessibilityModality.announcement, 'positional'),
        enabled['warningPosAnn']);
    expect(
        svc.getDelayMs(asvc.AccessibilitySignal.save,
            asvc.AccessibilityModality.sound, 'positional'),
        enabled['generalSound']);
    expect(
        svc.getDelayMs(asvc.AccessibilitySignal.save,
            asvc.AccessibilityModality.announcement, 'line'),
        enabled['generalAnn']);
    _config.set('accessibility.signalOptions.debouncePositionChanges', false);
    expect(
        svc.getDelayMs(asvc.AccessibilitySignal.errorAtPosition,
            asvc.AccessibilityModality.sound, 'positional'),
        _truth['delaysDisabled']);
    svc.dispose();
  });
}
