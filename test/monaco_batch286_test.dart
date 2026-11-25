// batch286: viewContext.ts truth replay.
// Truth from tool/ts2dart/batch286_truth.json (recursive TS transpile+vm,
// real ViewContext with fake config/theme/model).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/viewEventHandler.dart'
    show ViewEventHandler;
import 'package:semi_design_flutter/src/monaco/editor/common/viewModel/viewContext.dart'
    show
        IEditorConfigurationForViewContext,
        IViewModelForViewContext,
        IViewLayoutForViewContext,
        ViewContext;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/themeService.dart'
    show IColorTheme;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch286_truth.json').readAsStringSync())
    as Map<String, dynamic>;

class _Config implements IEditorConfigurationForViewContext {}

class _Layout implements IViewLayoutForViewContext {}

class _Theme implements IColorTheme {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// A lightweight ViewEventHandler stand-in (no need to call super constructor
/// behavior beyond what ViewContext delegates).
class _Handler extends ViewEventHandler {
  _Handler(this.label);
  final String label;
}

class _Model implements IViewModelForViewContext {
  _Model(this.layout, this.calls);
  final IViewLayoutForViewContext layout;
  final List<Map<String, Object?>> calls;

  @override
  IViewLayoutForViewContext get viewLayout => layout;

  @override
  void addViewEventHandler(ViewEventHandler eventHandler) =>
      calls.add(<String, Object?>{
        'op': 'add',
        'handler': (eventHandler as _Handler).label,
      });

  @override
  void removeViewEventHandler(ViewEventHandler eventHandler) =>
      calls.add(<String, Object?>{
        'op': 'remove',
        'handler': (eventHandler as _Handler).label,
      });
}

void main() {
  final t = _truth();
  final fields = t['fields'] as Map<String, dynamic>;

  test('b286 viewContext fields and delegation match TS truth', () {
    final config = _Config();
    final theme = _Theme();
    final layout = _Layout();
    final calls = <Map<String, Object?>>[];
    final model = _Model(layout, calls);

    final ctx = ViewContext(config, theme, model);

    expect(identical(ctx.configuration, config), fields['configIsSame']);
    expect(identical(ctx.viewModel, model), fields['viewModelIsSame']);
    expect(identical(ctx.viewLayout, layout), fields['viewLayoutIsSame']);
    expect(ctx.theme.value == theme, fields['themeWrapsRaw']);
    expect(!identical(ctx.theme, theme), fields['themeIsNotRaw']);

    ctx.addEventHandler(_Handler('h1'));
    ctx.removeEventHandler(_Handler('h2'));
    ctx.addEventHandler(_Handler('h2'));

    expect(calls, t['ops']);
  });
}
