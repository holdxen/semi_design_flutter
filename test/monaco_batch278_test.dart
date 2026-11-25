// batch278: textResourceConfigurationService.ts truth replay.
// Truth from tool/ts2dart/batch278_truth.json (recursive TS transpile+vm,
// real service class + fake config/model/language services).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/event.dart'
    show Emitter, Event;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/editor/common/core/position.dart'
    show IPosition, Position;
import 'package:semi_design_flutter/src/monaco/editor/common/services/textResourceConfiguration.dart'
    show ITextResourceConfigurationChangeEvent;
import 'package:semi_design_flutter/src/monaco/editor/common/services/textResourceConfigurationService.dart'
    show
        ITextResourceConfigLanguageService,
        ITextResourceConfigModel,
        ITextResourceConfigModelService,
        ITextResourceConfigService,
        ResourceConfigOverrides,
        TextResourceConfigurationService;
import 'package:semi_design_flutter/src/monaco/platform/configuration/common/configuration.dart'
    show
        IConfigurationChange,
        IConfigurationChangeEvent,
        IConfigurationOverrides,
        IConfigurationValue,
        IInspectValue;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch278_truth.json').readAsStringSync())
    as Map<String, dynamic>;

String? _uriStr(dynamic u) => u == null ? null : u as String;

Map<String, Object?>? _ovJson(Object? overrides) {
  if (overrides == null) return null;
  final o = overrides as ResourceConfigOverrides;
  return <String, Object?>{
    'resource': _uriStr(o.resource?.toString()),
    'overrideIdentifier': o.overrideIdentifier,
  };
}

// Implements IInspectValue via noSuchMethod: declaring a member literally
// named `override` would shadow the `@override` annotation in this library.
class _InspectValue implements IInspectValue<Object?> {
  _InspectValue(this.v, this.o);
  final Object? v;
  final Object? o;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = invocation.memberName.toString();
    if (name.contains('value')) return v;
    if (name.contains('override') && !name.contains('overrides')) return o;
    return null;
  }
}

class _ConfigValue implements IConfigurationValue<Object?> {
  _ConfigValue(Map<String, dynamic> spec)
      : _memory = _iv(spec['memory']),
        _workspaceFolder = _iv(spec['workspaceFolder']),
        _workspace = _iv(spec['workspace']),
        _userRemote = _iv(spec['userRemote']),
        _userLocal = _iv(spec['userLocal']),
        _overrideIdentifiers =
            (spec['overrideIdentifiers'] as List<dynamic>?)?.cast<String>();

  static _InspectValue? _iv(dynamic raw) {
    if (raw == null) return null;
    final m = raw as Map<String, dynamic>;
    return _InspectValue(
      (m['hasValue'] as bool? ?? false) ? m['value'] : null,
      (m['hasOverride'] as bool? ?? false) ? m['override'] : null,
    );
  }

  final IInspectValue<Object?>? _memory;
  final IInspectValue<Object?>? _workspaceFolder;
  final IInspectValue<Object?>? _workspace;
  final IInspectValue<Object?>? _userRemote;
  final IInspectValue<Object?>? _userLocal;
  final List<String>? _overrideIdentifiers;

  @override
  IInspectValue<Object?>? get memory => _memory;
  @override
  IInspectValue<Object?>? get workspaceFolder => _workspaceFolder;
  @override
  IInspectValue<Object?>? get workspace => _workspace;
  @override
  IInspectValue<Object?>? get userRemote => _userRemote;
  @override
  IInspectValue<Object?>? get userLocal => _userLocal;
  @override
  List<String>? get overrideIdentifiers => _overrideIdentifiers;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _ChangeEvent implements IConfigurationChangeEvent {
  _ChangeEvent(this.affectedKeys, this.affects);

  @override
  final Set<String> affectedKeys;
  final Map<String, bool> affects;

  @override
  int get source => 0;

  @override
  IConfigurationChange get change => throw UnsupportedError('not used');

  @override
  bool affectsConfiguration(String configuration,
      [IConfigurationOverrides? overrides]) {
    final key = '$configuration|${overrides?.overrideIdentifier ?? ''}';
    return affects[key] ?? false;
  }
}

class _FakeConfigService implements ITextResourceConfigService {
  _FakeConfigService(this.configValues, this.getValues, this.calls);

  final Map<String, dynamic> configValues;
  final Map<String, Object?> getValues;
  final List<Map<String, Object?>> calls;
  final Emitter<IConfigurationChangeEvent> _emitter =
      Emitter<IConfigurationChangeEvent>();

  @override
  Event<IConfigurationChangeEvent> get onDidChangeConfiguration =>
      _emitter.event;

  void fire(IConfigurationChangeEvent e) => _emitter.fire(e);

  @override
  Object? getValue$2(Object overrides) {
    calls.add(<String, Object?>{
      'call': 'getValue',
      'section': null,
      'overrides': _ovJson(overrides),
    });
    return <String, Object?>{
      'kind': 'overrides',
      'overrides': _ovJson(overrides),
    };
  }

  @override
  Object? getValue$3(String section, Object overrides) {
    calls.add(<String, Object?>{
      'call': 'getValue',
      'section': section,
      'overrides': _ovJson(overrides),
    });
    return getValues[section];
  }

  @override
  IConfigurationValue<Object?> inspect(String key, [Object? overrides]) {
    calls.add(<String, Object?>{
      'call': 'inspect',
      'key': key,
      'overrides': _ovJson(overrides),
    });
    return _ConfigValue((configValues[key] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{});
  }

  @override
  Future<void> updateValue$5(
    String key,
    Object? value,
    Object overrides,
    int target,
  ) async {
    calls.add(<String, Object?>{
      'call': 'updateValue',
      'key': key,
      'value': value,
      'overrides': _ovJson(overrides),
      'target': target,
    });
  }
}

class _FakeModel implements ITextResourceConfigModel {
  _FakeModel(this.languageId, this.at);
  final String languageId;
  final Map<String, String> at;

  @override
  String getLanguageId() => languageId;

  @override
  String? getLanguageIdAtPosition(int lineNumber, int column) =>
      at['$lineNumber:$column'] ?? languageId;
}

class _FakeModelService implements ITextResourceConfigModelService {
  _FakeModelService(this.models, this.calls);
  final Map<String, dynamic> models;
  final List<Map<String, Object?>> calls;

  @override
  ITextResourceConfigModel? getModel(URI resource) {
    final s = resource.toString();
    final def = models[s];
    calls.add(<String, Object?>{
      'call': 'getModel',
      'resource': s,
      'found': def != null,
    });
    if (def == null) return null;
    final m = def as Map<String, dynamic>;
    return _FakeModel(
      m['languageId'] as String,
      (m['at'] as Map?)?.cast<String, String>() ?? <String, String>{},
    );
  }
}

class _FakeLanguageService implements ITextResourceConfigLanguageService {
  _FakeLanguageService(this.guess, this.calls);
  final Map<String, dynamic> guess;
  final List<Map<String, Object?>> calls;

  @override
  String? guessLanguageIdByFilepathOrFirstLine(URI resource) {
    final s = resource.toString();
    final g = guess[s];
    calls.add(<String, Object?>{
      'call': 'guessLanguage',
      'resource': s,
      'result': g,
    });
    return g as String?;
  }
}

Object? _normOutput(Object? value) {
  if (value == null) return null;
  if (value is Map) {
    return value.map<String, Object?>((k, v) =>
        MapEntry<String, Object?>(k as String, _normOutput(v)));
  }
  if (value is List) return value.map(_normOutput).toList();
  return value;
}

void main() {
  final t = _truth();
  final configTarget =
      (t['consts'] as Map<String, dynamic>)['ConfigurationTarget'] as Map;

  for (final rawCase in t['cases'] as List<dynamic>) {
    final c = rawCase as Map<String, dynamic>;
    test('b278 ${c['name']}: service matches TS truth', () async {
      final inputs = c['inputs'] as Map<String, dynamic>;
      final calls = <Map<String, Object?>>[];
      final configService = _FakeConfigService(
        Map<String, dynamic>.from(inputs['configValues'] as Map),
        Map<String, Object?>.from(inputs['getValues'] as Map),
        calls,
      );
      final modelService = _FakeModelService(
          Map<String, dynamic>.from(inputs['models'] as Map), calls);
      final languageService = _FakeLanguageService(
          Map<String, dynamic>.from(inputs['guess'] as Map), calls);

      final svc = TextResourceConfigurationService(
          configService, modelService, languageService);

      final serviceEvents = <Map<String, Object?>>[];
      svc.onDidChangeConfiguration((dynamic e) {
        final evt = e as ITextResourceConfigurationChangeEvent;
        final queries = <Map<String, Object?>>[];
        for (final rawQ in (inputs['eventQueries'] as List<dynamic>)) {
          final q = rawQ as Map<String, dynamic>;
          final resource = q['resource'] == null
              ? null
              : URI.parse(q['resource'] as String);
          queries.add(<String, Object?>{
            'resource': q['resource'],
            'config': q['config'],
            'result': evt.affectsConfiguration(resource, q['config'] as String),
          });
        }
        serviceEvents.add(<String, Object?>{
          'affectedKeys': (evt.affectedKeys.toList()..sort()),
          'queries': queries,
        });
      });

      final outputs = <Object?>[];
      for (final rawOp in c['ops'] as List<dynamic>) {
        final op = rawOp as Map<String, dynamic>;
        final a = (op['args'] as List<dynamic>?) ?? <dynamic>[];
        switch (op['op'] as String) {
          case 'getValue':
            final resource = a[0] == null ? null : URI.parse(a[0] as String);
            Object? value;
            if (a.length >= 3) {
              final arg2 = a[1];
              final IPosition? position = arg2 is List
                  ? Position((arg2[0] as num).toInt(), (arg2[1] as num).toInt())
                  : null;
              value = svc.getValue$2(
                  resource, position, a[2] as String?);
            } else {
              value = svc.getValue$1(resource, a[1] as String?);
            }
            outputs.add(<String, Object?>{'value': _normOutput(value)});
            break;
          case 'updateValue':
            final resource = a[0] == null ? null : URI.parse(a[0] as String);
            final target = a.length >= 4 ? a[3] as int? : null;
            await svc.updateValue(resource, a[1] as String, a[2], target);
            outputs.add(null);
            break;
          case 'inspect':
            final resource = a[0] == null ? null : URI.parse(a[0] as String);
            final IPosition? position = a[1] == null
                ? null
                : Position((a[1][0] as num).toInt(), (a[1][1] as num).toInt());
            final v = svc.inspect(resource, position, a[2] as String);
            outputs.add(<String, Object?>{
              'overrideIdentifiers': v.overrideIdentifiers,
              'memoryOverride': v.memory?.override,
              'workspaceValue': v.workspace?.value,
            });
            break;
          case 'fire':
            final ce = (inputs['changeEvent'] as Map<String, dynamic>);
            configService.fire(_ChangeEvent(
              (ce['affectedKeys'] as List<dynamic>)
                  .map((e) => e as String)
                  .toSet(),
              (ce['affects'] as Map<String, dynamic>)
                  .map<String, bool>((k, v) => MapEntry(k, v as bool)),
            ));
            outputs.add(null);
            break;
          default:
            fail('unknown op ${op['op']}');
        }
      }

      // Outputs match TS truth.
      final truthOutputs = c['outputs'] as List<dynamic>;
      expect(outputs.length, truthOutputs.length, reason: 'outputs len ${c['name']}');
      for (int i = 0; i < truthOutputs.length; i++) {
        expect(_normOutput(outputs[i]), truthOutputs[i],
            reason: '${c['name']} output $i');
      }

      // Service calls match TS truth exactly.
      final truthCalls =
          (c['serviceCalls'] as List<dynamic>).cast<Map<String, dynamic>>();
      expect(calls.length, truthCalls.length, reason: 'calls len ${c['name']}');
      for (int i = 0; i < truthCalls.length; i++) {
        expect(_normOutput(calls[i]), truthCalls[i],
            reason: '${c['name']} call $i');
      }

      // Service events match TS truth.
      final truthEvents =
          (c['serviceEvents'] as List<dynamic>).cast<Map<String, dynamic>>();
      expect(serviceEvents.length, truthEvents.length,
          reason: 'events len ${c['name']}');
      for (int i = 0; i < truthEvents.length; i++) {
        expect(_normOutput(serviceEvents[i]), truthEvents[i],
            reason: '${c['name']} event $i');
      }

      // ConfigurationTarget consts sanity.
      expect(configTarget['USER_LOCAL'], 3);
      expect(configTarget['WORKSPACE'], 5);
      expect(configTarget['MEMORY'], 8);

      svc.dispose();
    });
  }
}
