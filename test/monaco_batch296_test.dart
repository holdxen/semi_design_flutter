// batch296: semanticTokensStyling.ts truth replay.
// Truth from tool/ts2dart/batch296_truth.json (recursive TS transpile + vm,
// decorator identity/registration + erased type surface).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/services/semanticTokensProviderStyling.dart'
    show
        IColorThemeForSemanticStyling,
        ILanguageServiceForSemanticStyling,
        ILogServiceForSemanticStyling,
        IThemeServiceForSemanticStyling,
        SemanticTokensProviderStyling;
import 'package:semi_design_flutter/src/monaco/editor/common/services/semanticTokensStyling.dart'
    show
        ISemanticTokensStylingService,
        ISemanticTokensStylingServiceType,
        isSemanticTokensStylingServiceRegistered;
import 'package:semi_design_flutter/src/monaco/editor/contrib/semanticTokens/common/getSemanticTokens.dart'
    show SemanticTokensLegend;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/instantiation.dart'
    show Util;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/themeService.dart'
    show ITokenStyle;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch296_truth.json').readAsStringSync())
    as Map<String, dynamic>;

class _Theme
    implements IThemeServiceForSemanticStyling, IColorThemeForSemanticStyling {
  @override
  Object getColorTheme() => this;

  @override
  ITokenStyle? getTokenStyleMetadata(
          String type, List<String> modifiers, String modelLanguage) =>
      null;
}

class _Languages implements ILanguageServiceForSemanticStyling {
  @override
  int encodeLanguageId(String languageId) => 1;
}

class _Log implements ILogServiceForSemanticStyling {
  @override
  void warn(Object message) {}
}

class _Service implements ISemanticTokensStylingServiceType {
  final SemanticTokensProviderStyling _styling;

  _Service(this._styling);

  @override
  SemanticTokensProviderStyling getStyling(Object provider) => _styling;
}

void main() {
  final Map<String, dynamic> truth = _truth();
  final Map<String, dynamic> service = truth['service'] as Map<String, dynamic>;

  test('decorator identity and registration match truth', () {
    expect(isSemanticTokensStylingServiceRegistered,
        service['registered'] as bool);
    expect(Util.serviceIds[service['id'] as String],
        same(ISemanticTokensStylingService));
  });

  test('erased type surface can be implemented and returns styling', () {
    final declarations = truth['declarations'] as List<dynamic>;
    expect(
      declarations.map((d) => (d as Map<String, dynamic>)['name']).toList(),
      <String>['DocumentTokensProvider', 'ISemanticTokensStylingService'],
    );
    final interface = declarations[1] as Map<String, dynamic>;
    expect(interface['kind'], 'interface');
    expect(interface['members'], <String>['_serviceBrand', 'getStyling']);

    final SemanticTokensProviderStyling styling = SemanticTokensProviderStyling(
      SemanticTokensLegend(<String>[], <String>[]),
      _Theme(),
      _Languages(),
      _Log(),
    );
    final ISemanticTokensStylingServiceType service = _Service(styling);
    expect(service.getStyling(Object()), same(styling));
  });
}
