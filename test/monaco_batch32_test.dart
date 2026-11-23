import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/deprecated/editor/editor.worker.dart'
    as worker;
import 'package:semi_design_flutter/src/monaco/internal/common/initialize.dart'
    as init;
import 'package:semi_design_flutter/src/monaco/editor/test/common/core/characterClassifier.test.dart'
    as classifier;
import 'package:semi_design_flutter/src/monaco/editor/test/common/core/positionOffsetTransformer.test.dart'
    as pot;
import 'package:semi_design_flutter/src/monaco/editor/test/common/model/bracketPairColorizer/smallImmutableSet.test.dart'
    as sis;
import 'package:semi_design_flutter/src/monaco/editor/test/common/model/bracketPairColorizer/length.test.dart'
    as len;

void main() {
  group('batch32 / deprecated editor.worker', () {
    setUp(() {
      init.resetInitializedForTest();
    });

    test('install sets self.onmessage; first message starts worker with empty factory result', () {
      int startCalls = 0;
      Object? factoryResult;
      final prevStart = init.workerStart;
      init.workerStart = (Object? Function(Object? ctx) factory) {
        startCalls++;
        factoryResult = factory(null);
      };
      addTearDown(() => init.workerStart = prevStart);

      worker.install();
      // handler installed
      expect(init.workerSelf.onmessage, isNotNull);

      init.workerSelf.deliver(null);
      expect(startCalls, 1);
      expect(factoryResult, isA<Map>());
      expect((factoryResult as Map).isEmpty, true);
    });

    test('when already initialized, onmessage does not start worker', () {
      int startCalls = 0;
      final prevStart = init.workerStart;
      init.workerStart = (factory) {
        startCalls++;
        factory(null);
      };
      addTearDown(() => init.workerStart = prevStart);

      init.initialize((ctx, data) => null); // sets initialized = true
      startCalls = 0;

      worker.install(); // overwrites onmessage with the deprecated handler
      init.workerSelf.deliver(null);
      expect(startCalls, 0);
    });
  });

  group('batch32 / ported mocha suites', () {
    test('CharacterClassifier works', () {
      classifier.testWorks();
    });

    test('PositionOffsetTransformer getPosition', () {
      pot.testGetPosition();
    });

    test('PositionOffsetTransformer getOffset', () {
      pot.testGetOffset();
    });

    test('SmallImmutableSet Basic', () {
      sis.testBasic();
    });

    test('SmallImmutableSet Many Elements', () {
      sis.testManyElements();
    });

    test('Length Basic', () {
      len.testBasic();
    });

    test('Length lengthDiffNonNeg', () {
      len.testLengthDiffNonNeg();
    });
  });
}
