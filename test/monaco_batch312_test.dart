// batch312: getHover.ts truth replay.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/cancellation.dart'
    show CancellationToken;
import 'package:semi_design_flutter/src/monaco/editor/common/core/position.dart'
    show Position;
import 'package:semi_design_flutter/src/monaco/editor/contrib/hover/browser/getHover.dart'
    show
      HoverForGetHover,
      IHoverProviderForGetHover,
      IHoverProviderRegistry,
      getHoversPromise,
      registerModelAndPositionCommandForHover,
      registration;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch312_truth.json').readAsStringSync())
    as Map<String, dynamic>;

class _Provider implements IHoverProviderForGetHover {
  _Provider(this.id, this.result, this.delay);

  final String id;
  final Object? result;
  final int delay;

  @override
  Future<Object?> provideHover(
          Object model, Position position, CancellationToken token) =>
      Future<Object?>.delayed(
          Duration(milliseconds: delay), () => result);
}

class _Registry implements IHoverProviderRegistry {
  _Registry(this.providers);

  final List<IHoverProviderForGetHover> providers;
  bool? lastRecursive;

  @override
  List<IHoverProviderForGetHover> ordered(Object model,
      [bool recursive = false]) {
    lastRecursive = recursive;
    return providers;
  }
}

HoverForGetHover _hover(String id, [bool valid = true]) => HoverForGetHover(
      valid ? Object() : null,
      valid ? <Object?>[<String, Object?>{'value': id}] : null,
    );

void main() {
  final Map<String, dynamic> truth = _truth();
  final Position position = Position(1, 1);

  test('registered commands match truth', () {
    final List<String> ids = <String>[];
    registerModelAndPositionCommandForHover = (String id, Function handler) =>
        ids.add(id);
    expect(registration, isTrue);
    expect(
      ids,
      (truth['registeredCommands'] as List<dynamic>).cast<String>(),
    );
  });

  group('batch312 getHover truth replay', () {
    for (final dynamic raw in truth['cases'] as List<dynamic>) {
      final Map<String, dynamic> c = raw as Map<String, dynamic>;
      test(c['name'] as String, () async {
        late List<IHoverProviderForGetHover> providers;
        switch (c['name'] as String) {
          case 'resolve-order':
            providers = <IHoverProviderForGetHover>[
              _Provider('slow', _hover('slow'), 20),
              _Provider('fast', _hover('fast'), 1),
              _Provider('mid', _hover('mid'), 5),
            ];
            break;
          case 'invalid-and-throw':
            providers = <IHoverProviderForGetHover>[
              _Provider('invalid', _hover('invalid', false), 1),
              _Provider('empty', null, 2),
              _Provider('valid', _hover('valid'), 3),
            ];
            break;
          default:
            providers = <IHoverProviderForGetHover>[
              _Provider('a', _hover('a'), 2),
            ];
        }
        final _Registry registry = _Registry(providers);
        final List<HoverForGetHover> hovers = await getHoversPromise(
          registry,
          Object(),
          position,
          CancellationToken.none,
          c['recursive'] as bool,
        );
        expect(
          hovers
              .map((h) => (h.contents!.first as Map<String, Object?>)['value'])
              .toList(),
          c['hovers'],
        );
        expect(registry.lastRecursive, c['recursive'] as bool);
      });
    }
  });
}
