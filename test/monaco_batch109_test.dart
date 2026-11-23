// Data-driven verification of batch109 ports against real TS runtime truth.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart'
    show DomIframeWindow;
import 'package:semi_design_flutter/src/monaco/base/browser/mouseEvent.dart'
    show MouseEvent;
import 'package:semi_design_flutter/src/monaco/editor/contrib/inlineCompletions/browser/view/inlineEdits/inlineEditsViewInterface.dart'
    as inline;
import 'package:semi_design_flutter/src/monaco/platform/userInteraction/browser/userInteractionService.dart'
    as uis;
import 'package:semi_design_flutter/src/monaco/platform/layout/browser/layoutService.dart'
    as layout;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch109_truth.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  group('inlineEditsViewInterface (truth-driven)', () {
    final Map<String, dynamic> t = truth['inline'] as Map<String, dynamic>;

    test('enum values', () {
      final Map<String, dynamic> tab =
          (t['tabAction'] as Map<String, dynamic>);
      expect(inline.InlineEditTabAction.Jump, tab['Jump']);
      expect(inline.InlineEditTabAction.Accept, tab['Accept']);
      expect(inline.InlineEditTabAction.Inactive, tab['Inactive']);

      final Map<String, dynamic> kind =
          (t['viewKind'] as Map<String, dynamic>);
      expect({
        'GhostText': inline.InlineCompletionViewKind.GhostText,
        'Custom': inline.InlineCompletionViewKind.Custom,
        'SideBySide': inline.InlineCompletionViewKind.SideBySide,
        'Deletion': inline.InlineCompletionViewKind.Deletion,
        'InsertionInline': inline.InlineCompletionViewKind.InsertionInline,
        'InsertionMultiLine': inline.InlineCompletionViewKind.InsertionMultiLine,
        'WordReplacements': inline.InlineCompletionViewKind.WordReplacements,
        'LineReplacement': inline.InlineCompletionViewKind.LineReplacement,
        'Collapsed': inline.InlineCompletionViewKind.Collapsed,
        'JumpTo': inline.InlineCompletionViewKind.JumpTo,
      }, kind);
    });

    test('click event create uses window + alternativeAction', () {
      final Map<String, dynamic> c =
          (t['clickEvent'] as Map<String, dynamic>);
      // Truth stub uses a fake window id 'window'; Dart carrier's getWindow
      // resolves from the event object, so verify observable fields.
      final inline.InlineEditClickEvent e =
          inline.InlineEditClickEvent.create(MouseEvent(type: 'click', view: DomIframeWindow()), true);
      expect(e.alternativeAction, c['alternativeAction']);
      expect(inline.InlineEditClickEvent.create(MouseEvent(view: DomIframeWindow())).alternativeAction,
          c['defaultAlternative']);
    });

    test('InlineCompletionViewData getData + setLongDistanceViewData', () {
      final Map<String, dynamic> vd = (t['viewData'] as Map<String, dynamic>);
      final data = inline.InlineCompletionViewData(3, 5, 10, 12, 40, 50, 2, true);
      data.setLongDistanceViewData(100, 108);
      final Map<String, dynamic> expectedBefore =
          (vd['before'] as Map<String, dynamic>);
      expect(
          Map<String, Object?>.from(data.getData())
            ..removeWhere((String k, Object? v) => !expectedBefore.containsKey(k)),
          expectedBefore);
      data.isForAnotherDocument = true;
      expect(data.getData(), vd['after'] as Map<String, dynamic>);
    });
  });

  group('userInteractionService (truth-driven)', () {
    final Map<String, dynamic> t =
        truth['userInteraction'] as Map<String, dynamic>;

    test('decorator serviceId', () {
      expect(uis.IUserInteractionService.toString(), t['serviceId'] as String);
    });

    test('default mock modifiers / trackers', () {
      final svc = uis.MockUserInteractionService();
      expect(svc.readModifierKeyStatus(Object(), null).toJson(),
          t['defaultModifiers'] as Map<String, dynamic>);
      expect(svc.createFocusTracker(Object(), uis.DisposableStore()).read(null),
          t['defaultFocus']);
      expect(svc.createHoverTracker(Object(), uis.DisposableStore()).read(null),
          t['defaultHover']);
    });

    test('custom mock modifiers / trackers', () {
      final svc = uis.MockUserInteractionService(
          false, true, const uis.IModifierKeyStatus(ctrlKey: true, altKey: true));
      expect(svc.readModifierKeyStatus(Object(), null).toJson(),
          t['customModifiers'] as Map<String, dynamic>);
      expect(svc.createFocusTracker(Object(), uis.DisposableStore()).read(null),
          t['customFocus']);
      expect(svc.createHoverTracker(Object(), uis.DisposableStore()).read(null),
          t['customHover']);
    });

    test('createDomFocusTracker fires focus once on microtask when simulating',
        () async {
      final svc = uis.MockUserInteractionService();
      final tracker = svc.createDomFocusTracker(Object());
      int focusCount = 0;
      tracker.onDidFocus((_) { focusCount++; });
      expect(focusCount, 0);
      await Future<void>.delayed(Duration(milliseconds: 10));
      expect(focusCount, 1);

      final noFocus = uis.MockUserInteractionService(false);
      final tracker2 = noFocus.createDomFocusTracker(Object());
      int focusCount2 = 0;
      tracker2.onDidFocus((_) { focusCount2++; });
      await Future<void>.delayed(Duration(milliseconds: 10));
      expect(focusCount2, 0);
    });
  });

  group('layoutService (truth-driven)', () {
    final Map<String, dynamic> t = truth['layout'] as Map<String, dynamic>;
    test('decorator serviceId', () {
      expect(layout.ILayoutService.toString(), t['serviceId'] as String);
    });
  });
}
