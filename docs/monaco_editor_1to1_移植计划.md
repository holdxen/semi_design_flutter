# Monaco Editor → Flutter 源码 1:1 翻译计划

> **任务定义（严格）**：照着 Monaco Editor 的源码，一个文件一个文件地翻译成 Dart。目录对目录、文件对文件、类对类、方法对方法、字段对字段。翻译产物保留源码的结构、命名、算法与控制流；不重新设计架构、不替换实现、不"按行为重写"、不自作主张增删功能。
>
> 制定日期：2026-11-23。
> 源码基线：`/Users/zhouguiqing/Documents/Code/Html/monaco-editor`（0.57.0，提交 `85549d0`），其核心由 `monaco-editor-core` 提供，等同 `/Users/zhouguiqing/Documents/Code/Html/vscode/src/vs/editor`（提交 `bfbf12b`）；`vscodeRef` 锚点 `3bc9674`。全部分子固定在这一组提交号，后续不跟随上游滚动。

---

## 0. 翻译的对象与范围

"源码 1:1" 的对象是下面五处实际存在的 TS 文件，共 **1688 个 .ts 文件**（由 `tool/ts2dart/scan_sources.py` 的依赖闭包扫描实测，2026-11-23）：

| 来源 | 路径 | 文件数 | 行数 | 说明 |
|---|---|---|---|---|
| 编辑器核心 | `vscode/src/vs/editor/**`（含 `test/`） | 894 | 289,328 | `common` / `browser` / `contrib` / `standalone` 四大块 |
| 基础设施 | `vscode/src/vs/base/**`（编辑器 import 闭包内） | 241 | 闭包内 | `common` 为主，`browser/ui` 部分 |
| 平台服务 | `vscode/src/vs/platform/**`（编辑器 import 闭包内） | 159 | 闭包内 | instantiation / theme / undoRedo / registry 等——**初稿漏列，扫描后补入** |
| Monaco 包装层 | `monaco-editor/src/**` | 361 | 123,267 | `features/` 65 个、`languages/` 84 种、`internal/`、`editor.ts` |
| LSP 客户端 | `monaco-editor/monaco-lsp-client/src/**` | 33 | 10,944 | 协议适配与 18 个 language feature |

> 准确清单以 `tool/ts2dart/manifest.json` 为准，进度表在 `lib/src/monaco/PORT_PROGRESS.md`。扫描脚本解析全部相对 `import`，把 editor 的传递依赖闭包（base + platform）完整纳入，避免"翻到一半发现缺依赖"。

`monaco-editor/src/vs/editor` 在本仓库里是空的——核心不在该仓库内，而在 `node_modules/monaco-editor-core`（与 vscode 同源）。因此**翻译基线以 vscode 仓库的 `src/vs/editor` 为准**，用 `vscodeRef` 锚定版本。`monaco-editor-core` 的 `.js` + `.js.map` 只作为校验源文本一致性的辅助。

**不做的事**（不是"决定不做"，是这些目录本身不是 Monaco Editor 的源码）：测试夹具二进制、`.gif/.png` 图片资源、构建脚本（`build/`、`gulpfile.js`）、发布配置。测试 `.ts` 文件**翻译**（见 §3），不是跳过。

---

## 1. 目标目录：严格镜像源码树

翻译产物放到 `semi_design_flutter` 内，路径**逐层照抄源码**，只把 `.ts` 换成 `.dart`：

```
semi_design_flutter/
└── lib/src/monaco/                      ← 镜像 vscode/src/vs/ + monaco-editor/src/
    ├── editor/                          ← 镜像 vscode/src/vs/editor/
    │   ├── editor.all.dart
    │   ├── editor.api.dart
    │   ├── editor.main.dart
    │   ├── editor.worker.start.dart
    │   ├── common/                      ← 逐目录镜像（见 §2.1）
    │   ├── browser/                     ← 逐目录镜像（见 §2.2）
    │   ├── contrib/                     ← 逐目录镜像（见 §2.3）
    │   ├── standalone/                  ← 逐目录镜像（见 §2.4）
    │   └── test/                        ← 逐目录镜像（见 §3）
    ├── base/                            ← 镜像 vscode/src/vs/base/（见 §2.5）
    ├── features/                        ← 镜像 monaco-editor/src/features/
    ├── languages/                       ← 镜像 monaco-editor/src/languages/
    ├── internal/                        ← 镜像 monaco-editor/src/internal/
    ├── lsp/                             ← 镜像 monaco-lsp-client/src/
    ├── editor.dart                      ← 镜像 monaco-editor/src/editor.ts
    ├── index.dart                       ← 镜像 monaco-editor/src/index.ts
    └── port_baseline.dart               ← 源码提交号常量（非翻译物，仅元数据）
```

规则：源码里 `editor/common/core/position.ts` → `lib/src/monaco/editor/common/core/position.dart`。**不归并、不改名、不调层级**。一个源文件对应一个 Dart 文件，即使它只有几行。

主包 `lib/semi_design_flutter.dart` 末尾仅增加一行导出：`export 'src/monaco/index.dart';`，与现有 Semi 组件导出并列。不新建子包、不改现有组件结构。

---

## 2. 逐目录翻译对照表

每张表 = 一个待办清单。翻译顺序按表内顺序，每完成一个文件在对应行打勾，并在文件头写 `// Port of vscode/src/vs/editor/<path>.ts @<commit>`。

### 2.1 `editor/common/` — 纯逻辑层（229 文件 / 73,207 行）

| 源目录 | 行数量级 | 关键文件（逐文件翻译） |
|---|---|---|
| `common/core/` | ~6,000 | `position.ts` `range.ts` `selection.ts` `editOperation.ts` `cursorColumns.ts` `characterClassifier.ts` `stringOperations.ts` `wordCharacterClassifier.ts` |
| `common/core/2d/` | ~1,500 | `position2d.ts` `range2d.ts` `point2d.ts` `rect2d.ts` |
| `common/core/edits/` | ~2,700 | `textEdit.ts` `lineEdit.ts` `modifications.ts` 等 6 个文件 |
| `common/core/misc/` | ~1,200 | `elementSizeObserver.ts` 等 4 个文件 |
| `common/core/ranges/` | ~1,600 | `rangeNumbers.ts` 等 5 个文件 |
| `common/core/text/` | ~1,400 | `textModelProjection.ts` 等 5 个文件 |
| `common/model/` | 17,772 | `textModel.ts` `textModelText.ts` `textModelSearch.ts` `textModelTokens.ts` `textModelEvents.ts` `editStack.ts` `intervalTree.ts` `prefixSumComputer.ts` + `pieceTreeTextBuffer/*`（4） `bracketPairsTextModelPart/*`（14） `tokens/*`（10）等 15+子目录全部文件 |
| `common/cursor/` | 5,686 | `cursor.ts` `oneCursor.ts` `cursorMoveCommands.ts` `cursorTypeOperations.ts` `cursorCollection.ts` `cursorContext.ts` 等 12 文件 |
| `common/commands/` | 777 | `command.ts` `multiCursorEditCommand.ts` `shiftCommand.ts` `surroundSelectionCommand.ts` `trimTrailingWhitespaceCommand.ts` |
| `common/config/` | ~4,000 | `editorOptions.ts` `editorConfiguration.ts` `editorConfigurationBaseNode.ts` `elementSizeObserver.ts` `fontInfo.ts` `viewOptions.ts` 等 7 文件 |
| `common/languages/` | 4,315 | `language.ts` `languageConfiguration.ts` `textualHover.ts` + `supports/*`（9） `highlights/*` `injections/*` 等 |
| `common/diff/` | 3,466 | `diffComputer.ts` `standardLinesDiffComputer.ts` + `defaultLinesDiffComputer/*`（9，含 algorithms） |
| `common/tokens/` | ~3,000 | `lineTokens.ts` `contiguousMultilineTokens.ts` `contiguousMultilineTokensBuilder.ts` `tokenizationRegistry.ts` `multilineTokenSupplier.ts` 等 9 文件 |
| `common/viewLayout/` | ~4,000 | `linesLayout.ts` `lineHeights.ts` `viewLineRenderer.ts` `viewLayout.ts` 等 7 文件 |
| `common/viewModel/` | ~7,000 | `viewModelImpl.ts` `viewModelLines.ts` `modelLineProjection.ts` `viewModelDecorations.ts` `viewModelEdit.ts` `monospaceLineBreaksComputer.ts` 等 12 文件 |
| `common/services/` | ~8,000 | 30 个文件 + `textModelSync/*` + `treeSitter/*` 全部 |
| `common/standalone/` | ~500 | `standaloneEditor.ts` 等 1 文件 |
| `common/` 顶层 | ~8,000 | `model.ts` `editorCommon.ts` `editorColorRegistry.ts` `editorAction.ts` `editorTheme.ts` `codedIcons.ts` 等 27 文件 |

### 2.2 `editor/browser/` — 渲染与输入层（154 文件 / 49,210 行）

| 源目录 | 行数量级 | 关键文件（逐文件翻译） |
|---|---|---|
| `browser/` 顶层 | ~6,000 | `codeEditorWidget.ts` `editorBrowser.ts` `editorDomNode.ts` `view.ts` `viewController.ts` `viewLayer.ts` `viewOverlays.ts` `viewZone.ts` 等 10 文件 |
| `browser/config/` | ~4,000 | `elementSizeObserver.ts` `fontInfo.ts` `computedEditorOptions.ts` 等 7 文件 |
| `browser/controller/` | ~3,000 | `mouseHandler.ts` `pointerHandler.ts` `textInputHandler.ts` `clipboard.ts` 等 4 文件 |
| `browser/controller/editContext/` | ~5,000 | `editContext.ts` + `native/*`（9） + `textArea/*`（4）全部 |
| `browser/view/` | 2,255 | 8 个文件全部 |
| `browser/viewParts/` | 11,835 | 24 个子目录全部：`viewLines/`（5） `viewCursors/`（2） `selections/` `lineNumbers/` `currentLineHighlight/` `glyphMargin/` `indentGuides/` `editorScrollbar/` `overviewRuler/`（2） `minimap/`（6） `viewZones/` `decorations/` `margin/` `rulers/` `whitespace/` `contentWidgets/` `overlayWidgets/` `scrollDecoration/` 等 |
| `browser/widget/` | ~4,000 | `codeEditor/`（3） `diffEditor/`（10 + components/features/utils 共 24） `multiDiffEditor/`（13） `markdownRenderer/` 全部 |
| `browser/services/` | ~3,000 | 9 个文件全部 |
| `browser/gpu/` | ~6,000 | `gpu/`（10） + `atlas/`（5） + `css/`（2） + `raster/`（2） + `renderStrategy/`（4）全部 |

### 2.3 `editor/contrib/` — 功能层（342 文件 / 106,574 行）

**全部 65 个功能目录逐一翻译**，每个目录内的 `browser/*.ts`、`common/*.ts`、`test/browser/*.ts` 都翻：

`anchorSelect` `bracketMatching` `caretOperations` `clipboard` `codeAction` `codelens` `colorPicker`（含 4 子目录） `comment` `contextmenu` `cursorUndo` `diffEditorBreadcrumbs` `dnd` `documentSymbols` `dropOrPasteInto` `editorState` `find` `floatingMenu` `folding` `fontZoom` `format` `gotoError` `gotoSymbol`（含 link/peek） `gpu` `hover`（22 文件） `inPlaceReplace` `indentation` `inlayHints` `inlineCompletions`（含 8 子目录） `inlineProgress` `insertFinalNewLine` `lineSelection` `linesOperations` `linkedEditing` `links` `longLinesHelper` `message` `middleScroll` `multicursor` `parameterHints` `peekView` `placeholderText` `quickAccess` `readOnlyMessage` `rename` `sectionHeaders` `semanticTokens` `smartSelect` `snippet` `stickyScroll` `structuralDiff` `suggest` `symbolIcons` `toggleTabFocusMode` `tokenization` `unicodeHighlighter` `unusualLineTerminators` `wordHighlighter` `wordOperations` `wordPartOperations` `zoneWidget`

### 2.4 `editor/standalone/` — 独立编辑器入口（30 文件 / 8,501 行）

`standalone/browser/`（含 `iPadShowKeyboard` `inspectTokens` `quickAccess` `quickInput` `referenceSearch` `services` `toggleHighContrast`） `standalone/common/`（含 `monarch/`） `standalone/test/` 全部文件。

### 2.5 `base/` — 基础设施（编辑器 import 到的部分）

翻译范围由**依赖闭包决定**：扫描 `editor/**`、`features/**`、`languages/**`、`lsp/**` 的全部 `import`，从 `vs/base/...` 出发做闭包遍历，闭包内的文件全部翻译。观察到的主要目录：

- `base/common/`（含 `decorators/` `diff/` `observableInternal/*` `marked/` `naturalLanguage/` `semver/` `worker/` 等）
- `base/browser/`（含 `ui/` 下 `actionbar` `contextview` `findinput` `hover` `inputbox` `list` `menu` `mouseCursor` `progressbar` `scrollbar` `splitview` `toolbar` `tree` 等）
- `base/parts/`

闭包外文件不翻译。闭包清单由脚本生成并写入 `lib/src/monaco/port_baseline.dart` 的 `baseClosure` 常量，作为可核对的翻译清单。

### 2.6 `monaco-editor/src/` — 包装层（361 文件 / 123,267 行）

| 源目录 | 关键内容（逐文件翻译） |
|---|---|
| `src/editor.ts` | `export * from 'monaco-editor-core/esm/vs/editor/editor.api'` → `export 'editor/editor.api.dart';` |
| `src/index.ts` | 顶层入口，注册顺序保持 |
| `src/features/` | 65 个子目录全部，`register.all.ts` 的注册顺序 1:1 保留 |
| `src/languages/` | `definitions/` 84 种语言（`_.contribution.ts` + 文法文件）全部；`features/` 语言服务全部；`register.all.ts` |
| `src/internal/` | `common/workers.ts` `common/initialize.ts` 全部 |
| `src/deprecated/` | `basic-languages/` `editor/` `language/` 全部（即使标注 deprecated 也翻译，不自行删减） |

### 2.7 `monaco-lsp-client/src/` — LSP（33 文件 / 10,944 行）

`adapters/ITextModelBridge.ts` `adapters/LspCapabilitiesRegistry.ts` `adapters/TextDocumentSynchronizer.ts` `adapters/languageFeatures/` 下 18 个 `Lsp*Feature.ts`（Declaration / Definition / Diagnostics / DocumentHighlight / DocumentSymbol / FoldingRange / Formatting / Implementation / OnTypeFormatting / RangeFormatting / References / Rename / SelectionRange / SemanticTokens / TypeDefinition 等） `types.ts` `utils.ts` `generator/index.ts` 全部。

---

## 3. 测试文件：照翻，不跳过

`vscode/src/vs/editor/test/**` 与 `contrib/*/test/**`、`monaco-lsp-client/test/**`、`monaco-editor/src/languages/definitions/*/*.test.ts`（86 个文法测试）**全部翻译成 Dart 测试**，路径镜像到 `lib/src/monaco/editor/test/` 等对应位置。翻译内容：断言、fixture 加载、用例组织 1:1；仅把测试框架 API 换成 `package:test`（`describe/it` → `group/test`，`assert` → `expect`）。

测试是"翻译正确"的判据：同一组输入应得到与 TS 版相同的断言结果。不得为了让测试通过而修改被测逻辑。

---

## 4. 翻译规则（语法层面，逐条固定）

这是**翻译的对应规则**，不是重新设计。每条规则适用于所有文件，保证全文一致。

| TypeScript 构造 | Dart 对应 |
|---|---|
| `export interface IFoo { ... }` | `abstract class IFoo { ... }`（保留 `I` 前缀） |
| `export class Foo` | `class Foo` |
| `export const enum E { A = 1 }` | `enum E { a, b }` 或 `class E { static const a = 1; }`（保留数值） |
| `export function f()` / 类方法 | 同名顶层函数 / 同名方法 |
| `public/private/protected` | Dart 默认 public；`private` → 保留原名 + `// private in source` 注释保持可追溯（不改名，避免破坏 1:1 对照） |
| `readonly x: T` | `final T x;` |
| `number` | `num`（需要整数语义处用 `int`，按源码用法决定，标注） |
| `string` | `String` |
| `boolean` | `bool` |
| `T[]` / `Array<T>` | `List<T>` |
| `{ [k: string]: T }` | `Map<String, T>` |
| `T \| null` / `T \| undefined` | `T?` |
| `Promise<T>` / `async` | `Future<T>` / `async` |
| `Event<T>` （vscode 事件） | `Event<T>` 类型别名指向 `Stream<T>` 或本仓库 `Emitter<T>`，`fire()` → `add()` |
| `Disposable` / `IDisposable` | `abstract class Disposable { void dispose(); }`，`dispose()` 调用保留 |
| `Map<K,V>` `Set<T>` | `Map<K,V>` `Set<T>` |
| `import './x'` | `import 'x.dart';`（相对路径保持相对，层级不变） |
| `@enum` / 装饰器 | Dart 注解等价物；无等价时保留注释 `@decorator: name` |
| `Object.keys/values` | `map.keys` / `map.values` |
| DOM API（`document.*` / `HTMLElement` / `CanvasRenderingContext2D`） | **逐 API 建立 Flutter 对应**（见 §6），调用点与源码保持一致，不改算法与控制流 |
| `Web Worker` | Dart `Isolate`，消息协议保持字段一致 |
| 泛型约束 `T extends X` | `T extends X` |

每个翻译文件头写：

```dart
// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/position.ts @bfbf12b
// Translated 1:1 from TypeScript. Do not refactor.
// ---------------------------------------------------------------------------
```

---

## 5. 阶段划分（按源码树推进，不按功能优先级重排）

每个阶段以"源码目录"为单位，完成标准是**该目录下所有文件都有对应 `.dart` 文件 + `dart analyze` 通过 + 对应测试翻译并通过**。

| 阶段 | 翻译目录 | 文件量级 | 说明 |
|---|---|---|---|
| **T0 准备** | 建 `lib/src/monaco/` 镜像骨架；写 `tool/ts2dart` 转译器；生成 base 依赖闭包清单 | 辅助工具 | 转译器先跑通 `common/core/position.ts` 一个文件作为样板 |
| **T1 common/core + model** | `editor/common/core/**`、`editor/common/model/**`（含 pieceTree、bracketPairs） | ~120 文件 | 最大最核心的算法块 |
| **T2 common 其余** | `common/cursor` `commands` `config` `languages` `diff` `tokens` `viewLayout` `viewModel` `services` `standalone` + 顶层 27 文件 | ~109 文件 | 完成整个 `common/` |
| **T3 base 闭包** | `base/common/**`、`base/browser/**` 闭包内文件 | 闭包决定 | 依赖先于使用方 |
| **T4 browser** | `editor/browser/**` 全部 10 个子目录 | 154 文件 | 含全部 viewParts 与 widget |
| **T5 standalone + editor 顶层** | `editor/standalone/**`、`editor/editor.*.ts` | 30+4 文件 | 公开入口 |
| **T6 contrib** | `editor/contrib/**` 65 个功能目录 | 342 文件 | 按目录名字母序推进 |
| **T7 monaco 包装层** | `monaco-editor/src/**` 361 文件 | 361 文件 | features / languages / internal / deprecated |
| **T8 LSP** | `monaco-lsp-client/src/**` 33 文件 | 33 文件 | 协议与 18 个 feature adapter |
| **T9 测试与收口** | 全部 `test/**` 目录；`index.dart` 汇总导出；`semi_design_flutter.dart` 加一行导出 | 130+ 测试文件 | 全量 analyze / test |

**不按"先内核后功能"重新排序**——顺序完全按源码目录走，每阶段是源码树的一个连续子树。

---

## 6. 必须逐 API 翻译的平台差异（不是"重写"）

下表是翻译时**逐项建立对应**的点。处理方式一律是"在 Dart 侧实现同名同签名的 API，调用点代码保持与源码一致"，而不是改写调用方的逻辑。

| 源码使用的平台 API | Dart 侧对应（逐个建，不动调用点） |
|---|---|
| `document.createElement` / `HTMLElement` | `EditorDomNode` 等 Dart 类，提供同名方法，内部映射到 Flutter 节点 |
| `CanvasRenderingContext2D` / `canvas` | `CanvasContext` Dart 类，方法逐一对齐 `fillText` `measureText` `drawRect` 等 |
| `window.requestAnimationFrame` | `FlutterScheduler.requestAnimationFrame` |
| `MutationObserver` / `ResizeObserver` | Dart 同名类，内部用 Flutter 监听 |
| `Web Worker` + `postMessage` | `Isolate` + `SendPort`，消息字段与源码一致 |
| `TextArea` / `InputEvent` / `beforeinput` | `DeltaTextInputClient` 适配层，方法名保持源码语义 |
| `CSSStyleDeclaration` | `StyleDeclaration` Dart 类，属性名 1:1 |

工作量集中在 T4（browser）与 T7（language service worker）。这些类是翻译的一部分，不是"额外的重新设计"。

---

## 7. 进度记录与验收

### 7.1 进度文件

`lib/src/monaco/PORT_PROGRESS.md`（翻译进度表）：每个源码文件一行，状态 `pending / translated / analyzed / tested`，附翻译日期与校验提交号。阶段完成时该文件是该阶段的交付物之一。

### 7.2 验收（机械可验，不靠主观判断）

1. **文件数对齐**：`find lib/src/monaco -name '*.dart' | wc -l` ≥ 源码 `.ts` 文件数（1688），差异逐一在 `PORT_PROGRESS.md` 说明。
2. **analyze**：`flutter analyze lib/src/monaco` 零 error。
3. **测试**：`flutter test lib/src/monaco/editor/test` 全绿，测试文件数与源码测试文件数对齐。
4. **逐文件来源标注**：每个 `.dart` 文件头有 `// Port of <path> @<commit>`，脚本扫描无遗漏。
5. **公开 API 对照**：`editor.api.d.ts` 的公开符号数 vs `editor/editor.api.dart`（及 `index.dart`）的公开符号数，用脚本比对无缺失（T5/T7 验收）。

---

## 8. 规模与工期的诚实数字

- **1688 个 TS 文件 / 约 60 万行源码**，逐文件翻译（含 platform 依赖闭包后的实测值）。
- 纯人工逐文件翻译：按熟手每天 200–300 行有效翻译+校验计，约 **2400–3200 人日**（约 10–13 人年）。
- 加上机械转译器辅助（TS AST → Dart 骨架，人工逐文件校准）：仍需逐文件 review 与 index/API 对齐，估 **5–7 人年**。
- 本地已有的 `advanced_editor`（73 文件 / 1.19 万行）可作为 T1–T4 的**翻译参考**（不是替代品）：它的 `core/render/widget` 已覆盖 pieceTree 之外的核心机制，165 测试全绿，可用来校验翻译产物的行为，但最终产物仍须是 `lib/src/monaco/editor/**` 下与源码逐文件对应的 Dart 文件。

计划不承诺工期。每完成一个目录子集即可验收一次；停在任一阶段都是可交付的中间状态。

---

## 9. 立即开始（T0）

1. 建 `lib/src/monaco/` 目录树骨架（按 §1 镜像，可用脚本从 `/tmp/monaco_editor_dirs.txt` 生成空目录）。
2. 写 `lib/src/monaco/port_baseline.dart`：三个源码仓库的绝对路径、提交号、`vscodeRef`。
3. 写 `lib/src/monaco/PORT_PROGRESS.md`：从源码文件清单生成全部待翻文件行（1348 行，初始 `pending`）。
4. 写 `tool/ts2dart/` 转译器第一个版本，只要求把 `editor/common/core/position.ts` 翻成符合 §4 规则与文件头格式的 `position.dart`，并把它对应的测试翻成 Dart 测试通过。

这一步产出的是**可复核的翻译样板**，后续每个文件照此格式推进。

### T0 执行记录（2026-11-23，已完成）

- [x] `lib/src/monaco/` 镜像目录骨架：689 个目录，由脚本从源码树逐一镜像生成（`editor` / `base` / `platform` / `features` / `languages` / `internal` / `deprecated` / `lsp`）。
- [x] `tool/ts2dart/scan_sources.py`：解析全部相对 `import`，算出编辑器对 `base` + `platform` 的传递依赖闭包，生成 `manifest.json`（1688 文件）与 `PORT_PROGRESS.md`。**这一步修正了初稿的计划分母**：初稿手工估 1348 文件，实测 1688（漏了 platform 层 159 个文件、base 闭包多算）。
- [x] `lib/src/monaco/port_baseline.dart`：固定 commit / vscodeRef / 文件计数，供翻译文件头引用。
- [x] `tool/ts2dart/transpile.py`：规则化转译器骨架，覆盖 import/export、interface/class、字段、方法签名、类型映射、JSDoc；不可映射处输出 `// TODO(port)` 而非静默丢弃。
- [x] `lib/src/monaco/editor/common/core/position.dart`：首个 1:1 样板，`dart analyze` 零 error/warning，行为自检通过（`tool/ts2dart/_check_position.dart`）。记录两处**语言级适配**（非算法改动）：TS 默认参数 → Dart 命名可选参数；TS 允许的 static/instance 同名在 Dart 不允许，static 方法后缀 `Static` 并在注释标注源名。

> 从 T1 起，每个文件按此样板推进：转译器生成骨架 → 人工校准 → `dart analyze` → 行为自检 → 更新 `PORT_PROGRESS.md` 状态。
