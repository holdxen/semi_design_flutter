// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/marshallingIds.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. TS `const enum` -> class + static const;
// auto-incremented members get their explicit numeric values so `MarshalledId.X`
// calls are unchanged.
// ---------------------------------------------------------------------------

class MarshalledId {
  const MarshalledId._();

  static const int Uri = 1;
  static const int Regexp = 2;
  static const int ScmResource = 3;
  static const int ScmResourceGroup = 4;
  static const int ScmProvider = 5;
  static const int CommentController = 6;
  static const int CommentThread = 7;
  static const int CommentThreadInstance = 8;
  static const int CommentThreadReply = 9;
  static const int CommentNode = 10;
  static const int CommentThreadNode = 11;
  static const int TimelineActionContext = 12;
  static const int NotebookCellActionContext = 13;
  static const int NotebookActionContext = 14;
  static const int TerminalContext = 15;
  static const int TestItemContext = 16;
  static const int Date = 17;
  static const int TestMessageMenuArgs = 18;
  static const int ChatViewContext = 19;
  static const int LanguageModelToolResult = 20;
  static const int LanguageModelTextPart = 21;
  static const int LanguageModelThinkingPart = 22;
  static const int LanguageModelPromptTsxPart = 23;
  static const int LanguageModelDataPart = 24;
  static const int AgentSessionContext = 25;
  static const int ChatResponsePullRequestPart = 26;
}
