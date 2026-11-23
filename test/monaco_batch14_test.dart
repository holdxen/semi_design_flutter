// 1:1 port parity tests for batch 14:
//   platform/notification/common/notificationLegacy.ts
//   editor/browser/gpu/css/decorationStyleCache.ts
//   platform/jsonschemas/common/jsonContributionRegistry.ts
//   platform/telemetry/common/gdprTypings.ts
//   base/test/common/virtualScheduling/timeApi.ts
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/platform/notification/common/notificationLegacy.dart'
    as legacy;
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/css/decorationStyleCache.dart'
    as dsc;
import 'package:semi_design_flutter/src/monaco/platform/jsonschemas/common/jsonContributionRegistry.dart'
    as jcr;
import 'package:semi_design_flutter/src/monaco/platform/telemetry/common/gdprTypings.dart'
    as gdpr;
import 'package:semi_design_flutter/src/monaco/base/test/common/virtualScheduling/timeApi.dart'
    as ta;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    as lifecycle;

void main() {
  group('notificationLegacy', () {
    test('identity capability check matches only the marker', () {
      expect(legacy.isLegacyExtensionLinkParsing(legacy.legacyExtensionLinkParsing),
          isTrue);
      expect(legacy.isLegacyExtensionLinkParsing(true), isFalse);
      expect(legacy.isLegacyExtensionLinkParsing(false), isFalse);
      expect(legacy.isLegacyExtensionLinkParsing(null), isFalse);
      expect(legacy.isLegacyExtensionLinkParsing(<String, dynamic>{}), isFalse);
      // a distinct object with the "same shape" is not the capability
      expect(legacy.isLegacyExtensionLinkParsing(Object()), isFalse);
    });
  });

  group('DecorationStyleCache', () {
    test('all-undefined style yields id 0 and no style set', () {
      final dsc.DecorationStyleCache c = dsc.DecorationStyleCache();
      expect(c.getOrCreateEntry(null, null, null, null, null, null), 0);
      expect(c.getStyleSet(0), isNull);
    });

    test('same style reuses the same id', () {
      final dsc.DecorationStyleCache c = dsc.DecorationStyleCache();
      final int id1 = c.getOrCreateEntry(0xFF0000, true, 1.0, false, null, null);
      final int id2 = c.getOrCreateEntry(0xFF0000, true, 1.0, false, null, null);
      expect(id1, 1);
      expect(id2, id1);
    });

    test('different styles get incrementing ids', () {
      final dsc.DecorationStyleCache c = dsc.DecorationStyleCache();
      expect(c.getOrCreateEntry(0xFF0000, null, null, null, null, null), 1);
      expect(c.getOrCreateEntry(0x00FF00, null, null, null, null, null), 2);
      expect(c.getOrCreateEntry(null, true, null, null, null, null), 3);
    });

    test('opacity/thickness are keyed by toFixed(2)', () {
      final dsc.DecorationStyleCache c = dsc.DecorationStyleCache();
      final int id1 = c.getOrCreateEntry(null, null, 0.501, null, 1.234, null);
      final int id2 = c.getOrCreateEntry(null, null, 0.504, null, 1.235, null);
      // 0.501 and 0.504 both round to "0.50"; 1.234/1.235 -> "1.23"/"1.24"
      expect(id2, isNot(id1));
      final int id3 = c.getOrCreateEntry(null, null, 0.502, null, 1.234, null);
      expect(id3, id1);
    });

    test('getStyleSet returns the original style fields', () {
      final dsc.DecorationStyleCache c = dsc.DecorationStyleCache();
      final int id = c.getOrCreateEntry(0x112233, true, 0.5, true, 2.0, 0xAABBCC);
      final dsc.IDecorationStyleSet? set = c.getStyleSet(id);
      expect(set, isNotNull);
      expect(set!.color, 0x112233);
      expect(set.bold, isTrue);
      expect(set.opacity, 0.5);
      expect(set.strikethrough, isTrue);
      expect(set.strikethroughThickness, 2.0);
      expect(set.strikethroughColor, 0xAABBCC);
    });
  });

  group('jsonContributionRegistry', () {
    test('normalizeId strips trailing #', () {
      expect(jcr.normalizeId('http://x#'), 'http://x');
      expect(jcr.normalizeId('http://x'), 'http://x');
      expect(jcr.normalizeId(''), '');
    });

    test('registerSchema normalizes id, fires event, getSchemaContent', () {
      final jcr.JSONContributionRegistry r = jcr.JSONContributionRegistry();
      final List<String> fired = <String>[];
      r.onDidChangeSchema((dynamic uri) => fired.add(uri as String));
      r.registerSchema('http://x#', <String, Object?>{'type': 'string'});
      expect(fired, <String>['http://x#']);
      expect(r.hasSchemaContent('http://x'), isTrue);
      expect(r.getSchemaContent('http://x'), '{"type":"string"}');
      expect(r.getSchemaContributions().schemas.containsKey('http://x'), isTrue);
    });

    test('registerSchema with store removes on dispose and fires again', () {
      final jcr.JSONContributionRegistry r = jcr.JSONContributionRegistry();
      final lifecycle.DisposableStore store = lifecycle.DisposableStore();
      final List<String> fired = <String>[];
      r.onDidChangeSchema((dynamic uri) => fired.add(uri as String));
      r.registerSchema('s', <String, Object?>{'type': 'number'}, store);
      expect(r.hasSchemaContent('s'), isTrue);
      store.dispose();
      expect(r.hasSchemaContent('s'), isFalse);
      expect(fired, <String>['s', 's']);
    });

    test('schema associations add/dedupe/remove and fire events', () {
      final jcr.JSONContributionRegistry r = jcr.JSONContributionRegistry();
      int fired = 0;
      r.onDidChangeSchemaAssociations((dynamic _) => fired++);
      final lifecycle.IDisposable d1 = r.registerSchemaAssociation('u', '*.json');
      r.registerSchemaAssociation('u', '*.json'); // duplicate: no event
      expect(r.getSchemaAssociations()['u'], <String>['*.json']);
      expect(fired, 1);
      d1.dispose();
      expect(r.getSchemaAssociations().containsKey('u'), isFalse);
      expect(fired, 2);
    });

    test('notifySchemaChanged fires with uri', () {
      final jcr.JSONContributionRegistry r = jcr.JSONContributionRegistry();
      final List<String> fired = <String>[];
      r.onDidChangeSchema((dynamic uri) => fired.add(uri as String));
      r.notifySchemaChanged('abc');
      expect(fired, <String>['abc']);
    });

    test('Extensions id matches source', () {
      expect(jcr.Extensions.JSONContribution, 'base.contributions.json');
    });
  });

  group('gdprTypings (type carriers)', () {
    test('classification/purpose string values match TS', () {
      expect(gdpr.PropertyClassification.systemMetaData, 'SystemMetaData');
      expect(gdpr.PropertyClassification.callstackOrException,
          'CallstackOrException');
      expect(gdpr.PropertyClassification.customerContent, 'CustomerContent');
      expect(gdpr.PropertyClassification.publicNonPersonalData,
          'PublicNonPersonalData');
      expect(gdpr.PropertyClassification.endUserPseudonymizedInformation,
          'EndUserPseudonymizedInformation');
      expect(gdpr.PropertyPurpose.performanceAndHealth, 'PerformanceAndHealth');
      expect(gdpr.PropertyPurpose.featureInsight, 'FeatureInsight');
      expect(gdpr.PropertyPurpose.businessInsight, 'BusinessInsight');
    });

    test('StrictPropertyCheckError message matches TS', () {
      expect(gdpr.StrictPropertyCheckError.error,
          'Type of classified event does not match event properties');
      expect(gdpr.StrictPropertyCheckError().value,
          'Type of classified event does not match event properties');
    });

    test('IPropertyData / IGDPRProperty carriers preserve fields', () {
      final gdpr.IPropertyData p = gdpr.IPropertyData(
        classification: gdpr.PropertyClassification.systemMetaData,
        purpose: gdpr.PropertyPurpose.featureInsight,
        comment: 'c',
        expiration: '1.0',
        endpoint: 'e',
      );
      expect(p.classification, 'SystemMetaData');
      expect(p.purpose, 'FeatureInsight');
      expect(p.comment, 'c');
      expect(p.expiration, '1.0');
      expect(p.endpoint, 'e');
      final gdpr.IGDPRProperty prop = gdpr.IGDPRProperty(
          owner: 'o', comment: 'c', expiration: 'e');
      expect(prop.owner, 'o');
      expect(prop.comment, 'c');
      expect(prop.expiration, 'e');
      expect(prop.extra, isEmpty);
    });
  });

  group('TimeApi', () {
    test('brand ids carry their values', () {
      expect(ta.TimeoutId(7).value, 7);
      expect(ta.IntervalId(8).value, 8);
      expect(ta.ImmediateId(9).value, 9);
      expect(ta.AnimationFrameId(10).value, 10);
    });

    test('captureGlobalTimeApi with explicit host delegates all members', () {
      final List<int> timeouts = <int>[];
      final ta.HostTimeApi host = ta.HostTimeApi(
        setTimeout: (void Function() handler, [int timeout = 0]) {
          timeouts.add(timeout);
          return ta.TimeoutId(timeout);
        },
        clearTimeout: (ta.TimeoutId id) {},
        setInterval: (void Function() handler, int interval) =>
            ta.IntervalId(interval),
        clearInterval: (ta.IntervalId id) {},
        Date: () => DateTime(2020),
        performanceNow: () => 42.0,
        performanceTimeOrigin: 5.0,
      );
      final ta.TimeApi api = ta.captureGlobalTimeApi(host);
      final ta.TimeoutId id = api.setTimeout(() {}, 15);
      expect(id.value, 15);
      expect(timeouts, <int>[15]);
      expect(api.performanceNow(), 42.0);
      expect(api.performanceTimeOrigin, 5.0);
      expect(api.Date().year, 2020);
      expect(api.setInterval(() {}, 3).value, 3);
    });

    test('realTimeApi is available', () {
      expect(ta.realTimeApi, isA<ta.TimeApi>());
    });
  });
}
