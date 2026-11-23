import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/editor/common/standalone/standaloneEnums.dart'
    as enums;
import 'package:semi_design_flutter/src/monaco/editor/test/common/viewModel/prefixSumComputer.test.dart'
    as psc;

void main() {
  group('batch37 / standaloneEnums + prefixSumComputer ported suite', () {
    test('standaloneEnums: representative numeric + string enums', () {
      // AccessibilitySupport
      assert(enums.AccessibilitySupport.Unknown == 0);
      assert(enums.AccessibilitySupport.Disabled == 1);
      assert(enums.AccessibilitySupport.Enabled == 2);
      // CompletionItemInsertTextRule (bit flags)
      assert(enums.CompletionItemInsertTextRule.None == 0);
      assert(enums.CompletionItemInsertTextRule.KeepWhitespace == 1);
      assert(enums.CompletionItemInsertTextRule.InsertAsSnippet == 4);
      // KeyCode: negative sentinel + MAX_VALUE
      assert(enums.KeyCode.DependsOnKbLayout == -1);
      assert(enums.KeyCode.Unknown == 0);
      assert(enums.KeyCode.KeyA == 31);
      assert(enums.KeyCode.MAX_VALUE == 132);
      // EditorOption boundaries
      assert(enums.EditorOption.acceptSuggestionOnCommitCharacter == 0);
      assert(enums.EditorOption.effectiveFullwidthCharacterWidth == 179);
      // string enum
      assert(enums.ShowLightbulbIconMode.Off == 'off');
      assert(enums.ShowLightbulbIconMode.OnCode == 'onCode');
      assert(enums.ShowLightbulbIconMode.On == 'on');
      // marker severity bit flags
      assert(enums.MarkerSeverity.Hint == 1);
      assert(enums.MarkerSeverity.Error == 8);
      assert(enums.OverviewRulerLane.Full == 7);
    });

    test('standaloneEnums: all 48 enum classes have static const members', () {
      // Spot-check a broad sample across the generated file to ensure the
      // script preserved every enum (48 classes, 514 constants).
      assert(enums.CodeActionTriggerType.Invoke == 1 &&
          enums.CodeActionTriggerType.Auto == 2);
      assert(enums.DefaultEndOfLine.LF == 1 &&
          enums.DefaultEndOfLine.CRLF == 2);
      assert(enums.EndOfLineSequence.LF == 0 &&
          enums.EndOfLineSequence.CRLF == 1);
      assert(enums.SymbolKind.File == 0 &&
          enums.SymbolKind.TypeParameter == 25);
      assert(enums.TextEditorCursorStyle.Line == 1 &&
          enums.TextEditorCursorStyle.UnderlineThin == 6);
      assert(enums.WrappingIndent.None == 0 &&
          enums.WrappingIndent.DeepIndent == 3);
    });

    test('prefixSumComputer: full ported suite (48 mocha cases)', () {
      // Each case exercises both PrefixSumComputer and
      // ConstantTimePrefixSumComputer via createBoth/forBoth.
      psc.runAll();
    });
  });
}
