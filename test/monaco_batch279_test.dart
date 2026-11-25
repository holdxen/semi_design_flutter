// batch279: inMemoryTextModelService.ts truth replay.
// Truth from tool/ts2dart/batch279_truth.json (recursive TS transpile+vm,
// real service + fake IModelService, reference counting / Lazy / dispose).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/editor/common/languages/language.dart'
    show ILanguageSelection;
import 'package:semi_design_flutter/src/monaco/editor/common/services/resolverService.dart'
    show ITextModelContentProvider;
import 'package:semi_design_flutter/src/monaco/editor/common/services/inMemoryTextModelService.dart'
    show
        IInMemoryModelService,
        IInMemoryTextModel,
        InMemoryTextModelService;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch279_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Object? _norm(Object? v) {
  if (v == null) return null;
  if (v is Map) {
    return v.map<String, Object?>((k, e) =>
        MapEntry<String, Object?>(k as String, _norm(e)));
  }
  if (v is List) return v.map(_norm).toList();
  return v;
}

class _FakeTextModel implements IInMemoryTextModel {
  _FakeTextModel(this.label, this.calls);
  final String label;
  final List<Map<String, Object?>> calls;

  @override
  void dispose() => calls.add(<String, Object?>{'call': 'model.dispose', 'label': label});

  @override
  String getLanguageId() => '$label-lang';

  @override
  Object? createSnapshot() => <String, Object?>{
        'label': label,
        'value': 'snapshot-$label',
      };
}

class _FakeModelService implements IInMemoryModelService {
  _FakeModelService(this.existing, this.createdLabel, this.calls);

  final Map<String, String> existing;
  final String createdLabel;
  final List<Map<String, Object?>> calls;

  @override
  IInMemoryTextModel? getModel(URI resource) {
    final s = resource.toString();
    final label = existing[s];
    calls.add(<String, Object?>{
      'call': 'getModel',
      'resource': s,
      'found': label != null,
    });
    return label == null ? null : _FakeTextModel(label, calls);
  }

  @override
  IInMemoryTextModel createModel(
    Object value,
    ILanguageSelection? languageSelection,
    URI resource,
  ) {
    final s = resource
        .toString()
        .replaceAll(RegExp(r'/synthetic/[0-9a-f-]{36}', caseSensitive: false),
            '/synthetic/<uuid>');
    final label = value is Map
        ? (value['_label'] as String? ?? createdLabel)
        : createdLabel;
    final valueDesc = value is String
        ? value
        : (value is Map ? (value['_label'] as String? ?? 'factory') : 'factory');
    calls.add(<String, Object?>{
      'call': 'createModel',
      'resource': s,
      'value': valueDesc,
      'languageId': languageSelection?.languageId,
    });
    return _FakeTextModel(label, calls);
  }
}

class _FakeLanguageSelection implements ILanguageSelection {
  _FakeLanguageSelection(this.languageId);
  @override
  final String languageId;

  @override
  get onDidChange => throw UnsupportedError('not used');
}

void main() {
  final t = _truth();

  for (final rawCase in t['cases'] as List<dynamic>) {
    final c = rawCase as Map<String, dynamic>;
    test('b279 ${c['name']}: service matches TS truth', () async {
      final inputs = c['inputs'] as Map<String, dynamic>;
      final calls = <Map<String, Object?>>[];
      final modelService = _FakeModelService(
        Map<String, String>.from(inputs['existing'] as Map),
        inputs['createdLabel'] as String,
        calls,
      );
      final svc = InMemoryTextModelService(modelService);
      final refs = <dynamic>[];
      final outputs = <Object?>[];

      for (final rawOp in c['ops'] as List<dynamic>) {
        final op = rawOp as Map<String, dynamic>;
        switch (op['op'] as String) {
          case 'createModelReference':
            try {
              final ref = await svc.createModelReference(
                  URI.parse(op['uri'] as String));
              refs.add(ref);
              outputs.add(<String, Object?>{'ok': true, 'index': refs.length - 1});
            } catch (e) {
              outputs.add(<String, Object?>{
                'ok': false,
                'error': e is StateError ? e.message : e.toString(),
              });
            }
            break;
          case 'createSyntheticDocument':
            final Object value = op['valueFactory'] == true
                ? <String, Object?>{'_label': 'factory'}
                : op['value'] as String;
            final ILanguageSelection? sel = op['languageId'] == null
                ? null
                : _FakeLanguageSelection(op['languageId'] as String);
            final ref = await svc.createSyntheticDocument(value, sel);
            refs.add(ref);
            outputs.add(<String, Object?>{
              'ok': true,
              'index': refs.length - 1,
              'uriScheme': 'inmemory',
            });
            break;
          case 'readRef':
            final obj = refs[op['index'] as int].object;
            outputs.add(<String, Object?>{
              'languageId': obj.getLanguageId(),
              'isResolved': obj.isResolved(),
              'snapshot': obj.createSnapshot(),
            });
            break;
          case 'disposeRef':
            (refs[op['index'] as int] as dynamic).dispose();
            outputs.add(null);
            break;
          case 'reentrant':
            final p1 = svc.createModelReference(URI.parse(op['uri'] as String));
            final p2 = svc.createModelReference(URI.parse(op['uri'] as String));
            final r1 = await p1;
            final r2 = await p2;
            refs.add(r1);
            refs.add(r2);
            outputs.add(<String, Object?>{
              'ok': true,
              'indices': <int>[refs.length - 2, refs.length - 1],
              'sameObject': identical(r1.object, r2.object),
            });
            break;
          case 'canHandleResource':
            outputs.add(<String, Object?>{
              'value': svc.canHandleResource(URI.parse(op['uri'] as String)),
            });
            break;
          case 'registerTextModelContentProvider':
            // Dart carrier takes scheme+provider; TS takes none. Returned
            // Disposable.None must dispose without error.
            final d = svc.registerTextModelContentProvider(
                'x', _ProviderStub());
            d.dispose();
            outputs.add(<String, Object?>{'disposedWithoutError': true});
            break;
          default:
            fail('unknown op ${op['op']}');
        }
      }

      final truthOutputs = c['outputs'] as List<dynamic>;
      expect(outputs.length, truthOutputs.length, reason: 'outputs len ${c['name']}');
      for (int i = 0; i < truthOutputs.length; i++) {
        expect(_norm(outputs[i]), truthOutputs[i],
            reason: '${c['name']} output $i');
      }

      final truthCalls =
          (c['calls'] as List<dynamic>).cast<Map<String, dynamic>>();
      expect(calls.length, truthCalls.length, reason: 'calls len ${c['name']}');
      for (int i = 0; i < truthCalls.length; i++) {
        expect(_norm(calls[i]), truthCalls[i],
            reason: '${c['name']} call $i');
      }
    });
  }
}

class _ProviderStub implements ITextModelContentProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
