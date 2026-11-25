// batch298: semanticTokensStylingService.ts truth replay.
// Truth from tool/ts2dart/batch298_truth.json (recursive TS transpile + vm,
// real WeakMap-style styling cache and singleton registration).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/services/semanticTokensProviderStyling.dart'
    show
        ILogServiceForSemanticStyling,
        ILanguageServiceForSemanticStyling,
        SemanticTokensProviderStyling;
import 'package:semi_design_flutter/src/monaco/editor/common/services/semanticTokensStyling.dart'
    show ISemanticTokensStylingService, ISemanticTokensStylingServiceType;
import 'package:semi_design_flutter/src/monaco/editor/common/services/semanticTokensStylingService.dart'
    show
        IDocumentTokensProviderForStyling,
        IThemeServiceForSemanticStylingService,
        SemanticTokensStylingService,
        registration;
import 'package:semi_design_flutter/src/monaco/editor/contrib/semanticTokens/common/getSemanticTokens.dart'
    show SemanticTokensLegend;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/descriptors.dart'
    show SyncDescriptor;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/extensions.dart'
    show getSingletonServiceDescriptors;
import 'package:semi_design_flutter/src/monaco/platform/theme/test/common/testThemeService.dart'
    show TestColorTheme;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/themeService.dart'
    show IColorTheme;
import 'package:semi_design_flutter/src/monaco/base/common/event.dart'
    show Emitter, Event;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch298_truth.json').readAsStringSync())
    as Map<String, dynamic>;

class _Theme implements IThemeServiceForSemanticStylingService {
  final Emitter<IColorTheme> _emitter = Emitter<IColorTheme>();

  @override
  IColorTheme getColorTheme() => TestColorTheme();

  @override
  Event<IColorTheme> get onDidColorThemeChange => _emitter.event;

  void fireChange() => _emitter.fire(TestColorTheme());
}

class _Log implements ILogServiceForSemanticStyling {
  @override
  void warn(Object message) {}
}

class _Languages implements ILanguageServiceForSemanticStyling {
  @override
  int encodeLanguageId(String languageId) =>
      languageId == 'typescript' ? 2 : 3;
}

class _Provider implements IDocumentTokensProviderForStyling {
  _Provider(this.id);

  final String id;

  @override
  SemanticTokensLegend getLegend() => SemanticTokensLegend(
      <String>['comment', 'keyword'], <String>['declaration']);
}

void main() {
  final Map<String, dynamic> truth = _truth();
  final Map<String, dynamic> cacheTruth =
      truth['cache'] as Map<String, dynamic>;

  test('styling cache and theme invalidation match truth', () {
    final _Theme theme = _Theme();
    final SemanticTokensStylingService service =
        SemanticTokensStylingService(theme, _Log(), _Languages());
    expect(service, isA<ISemanticTokensStylingServiceType>());

    final _Provider p1 = _Provider('p1');
    final _Provider p2 = _Provider('p2');
    final SemanticTokensProviderStyling s1 = service.getStyling(p1);
    final SemanticTokensProviderStyling s1again = service.getStyling(p1);
    final SemanticTokensProviderStyling s2 = service.getStyling(p2);

    expect(identical(s1, s1again),
        cacheTruth['sameProviderSameStyling'] as bool);
    expect(identical(s1, s2) == false,
        cacheTruth['differentProviderDifferentStyling'] as bool);

    theme.fireChange();
    final SemanticTokensProviderStyling s1After = service.getStyling(p1);
    final SemanticTokensProviderStyling s2After = service.getStyling(p2);
    expect(identical(s1After, s1) == false,
        cacheTruth['themeChangeInvalidates'] as bool);
    expect(identical(s2After, s2) == false,
        cacheTruth['themeChangeInvalidatesOtherProvider'] as bool);
    expect(identical(service.getStyling(p1), s1After),
        cacheTruth['postThemeSameProviderSameStyling'] as bool);
  });

  test('singleton registration matches truth', () {
    // Force the lazy top-level registration side effect.
    expect(registration, same(ISemanticTokensStylingService));
    final Map<String, dynamic> singletonTruth =
        truth['singleton'] as Map<String, dynamic>;
    final List<List<Object?>> matches = getSingletonServiceDescriptors()
        .where((List<Object?> d) =>
            identical(d[0], ISemanticTokensStylingService))
        .toList();
    expect(matches.length, singletonTruth['count'] as int);
    for (final List<Object?> d in matches) {
      expect(d[1], isA<SyncDescriptor>());
      expect((d[1] as SyncDescriptor).supportsDelayedInstantiation,
          (singletonTruth['delayed'] as List<dynamic>).first as bool);
    }
  });
}
