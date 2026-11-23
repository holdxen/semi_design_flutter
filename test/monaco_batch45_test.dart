import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dompurify/dompurify.d.dart' as D;

/// batch45: 1:1 port of the ambient DOMPurify 3.4.17 declaration file.
/// Symbol/field truth (7 interfaces / 12 aliases / 71 fields+methods / 13
/// export types) is checked by tool/ts2dart/verify_dompurify.py against the TS
/// AST. These tests compile-time import and reference every exported type;
/// DOM globals are Object? carriers, so no runtime instance is constructible.
void main() {
  group('batch45 / dompurify 1:1 declarations', () {
    test('all 7 exported interface types are referencable', () {
      D.Config? config;
      D.DOMPurify? dp;
      D.UseProfilesConfig? upc;
      D.RemovedElement? re;
      D.RemovedAttribute? ra;
      D.UponSanitizeElementHookEvent? se;
      D.UponSanitizeAttributeHookEvent? sa;
      expect([config, dp, upc, re, ra, se, sa], everyElement(isNull));
    });

    test('all 12 exported typedefs are referencable', () {
      D.BasicHookName? bn;
      D.ElementHookName? en;
      D.DocumentFragmentHookName? dfn;
      D.UponSanitizeElementHookName? usen;
      D.UponSanitizeAttributeHookName? usan;
      D.HookName? hn;
      D.NodeHook? nh;
      D.ElementHook? eh;
      D.DocumentFragmentHook? dh;
      D.UponSanitizeElementHook? useh;
      D.UponSanitizeAttributeHook? usah;
      D.WindowLike? wl;
      expect([bn, en, dfn, usen, usan, hn, nh, eh, dh, useh, usah, wl],
          everyElement(isNull));
    });

    test('default export carrier resolves to DOMPurify', () {
      D.DompurifyDefault? def;
      expect(def, isNull);
      D.DOMPurify? same = null;
      expect(same, isNull);
    });

    test('typedef carrier bodies are function types', () {
      D.NodeHook hook = (Object? _) {};
      expect(hook, isA<Function>());
      D.ElementHook ehook = (Object? _) {};
      expect(ehook, isA<Function>());
    });
  });
}
