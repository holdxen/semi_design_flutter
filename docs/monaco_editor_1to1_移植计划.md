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

### T1 执行记录（2026-11-23，进行中：19/78 文件 tested）

按源码依赖拓扑从叶子向前推进，每个文件：人工 1:1 翻译 → `dart analyze` 零 error/warning → 行为断言 → `PORT_PROGRESS.md` 标 `tested`。累计 19 个文件 `tested`（含 base 依赖提前翻 4 个）。

- [x] `core/2d/{dimension,point,size,rect}.dart`、`core/{position,range,selection,editOperation}.dart`
- [x] `core/ranges/{offsetRange,columnRange,rangeSingleLine}.dart`、`core/misc/{rgba,textModelDefaults,eolCounter}.dart`、`core/characterClassifier.dart`
- [x] base 依赖提前翻（core 直接依赖，属 T3 闭包）：`base/common/{errors,charCode,uint,arraysFind}.dart`
- [x] `test/monaco_port_test.dart`：正式回归测试 17 个 case 全绿（`flutter test`）；替代早期临时 `_check_*.dart` 脚本。

**本阶段新增的 Dart 适配规则**（均不改算法/结构，文件头注明）：
- JS `Error` 体系 → Dart `implements Exception` + `_MonacoRuntimeError` 承载可变 `name/message/stack/code/cause`；`setTimeout` 重抛 → 直接抛。
- TS `const enum` → `class` + `static const`（调用点 `CharCode.X`/`StringEOL.X` 不变）。
- TS tuple 返回 → Dart record（如 `countEOL`）；对象字面量接口 → Dart 值类（`ISingleEditOperation`/`Dimension`/`SerializedError`）。
- `Uint8Array` → `Uint8List`；`Array.splice` → `insert`/`replaceRange`；JS `||` 取默认 → Dart `??`。
- 重载（如 `Rect.withMargin`、`OffsetRange.withMargin`）→ Dart 位置可选参数，保留源码调用形式。

**当前阻塞 / 下一步**：`core/ranges/{lineRange,rangeMapping}` 及 `core/edits/**`、`core/text/**` 依赖 `base/common/{arrays,strings,buffer,assert,equals}` 与更深的 `event.ts`(1991 行)/`lifecycle.ts`(974 行) 链。该链是 base 基础设施，按计划属 T3；为解锁 T1 剩余文件需作为独立大批次系统推进。T1 余 59 文件未翻。

### base 工具链批次进度（2026-11-23，累计 32/1690 文件 tested）

按依赖拓扑从叶子推进 base 闭包，本批新增 13 个文件（全部 analyze 零 error/warning + 行为断言 + 正式测试）：
- 叶子：`base/common/{lazy,functional,assert,symbols,stopwatch,collections,linkedList,types,iterator,marshallingIds}.dart`
- `vs/nls.dart`（镜像 `vs/nls.ts`）、`base/common/{platform,process}.dart`（平台环境链）

**清单修复**：`tool/ts2dart/scan_sources.py` 原先只把闭包过滤成 base/platform 两层，漏掉 `base/common/platform.ts` 经 `../../nls.js` 引入的 `vs/nls.ts`。已新增 `vs` 层；manifest 由 1688 → **1690 文件**（vs 层 2 个：`nls.ts`、`amdX.ts`），`PORT_PROGRESS.md` 同步重建并保留已 tested 状态。

**测试**：新建 `test/monaco_base_test.dart`（base 层 11 个 case），连同 `test/monaco_port_test.dart` 共 **27 个 case 全绿**。

**本批新增 Dart 适配规则**：
- TS `namespace Iterable` → `class IterableX`（`Iterable` 与 dart:core 同名，唯一改名）；`function*` → `sync*`。
- `Node.Undefined` 链表哨兵 → Dart `null` 链接；`SetWithKey implements Set` → `SetMixin`（补 `remove`/`toSet`）。
- 顶层 `if`/IIFE 环境检测 → 初始化函数 / 匿名函数 IIFE（Dart 无顶层语句）。
- `performance.now()` → 持久 `Stopwatch`；`Symbol()` → 唯一 `Object` 哨兵；`globalThis._VSCODE_NLS_*` → nls.dart 顶层可变量 + setter。

**核心环（下一批重点）**：`arrays ↔ cancellation ↔ event ↔ lifecycle ↔ arrays`，外加 `async`(2752 行)/`event`(1991 行) 两个巨兽，以及 `strings`(1434)/`buffer`(582)/`map`(1027)/`uri`(765)/`path`(1589)。Dart 允许循环 import，计划按逻辑批次整批翻译 + 统一 analyze，不再严格按拓扑序逐个等待。这是解锁 T1 剩余 59 个文件（lineRange/rangeMapping/edits/text/model）的前提。

### base 工具链批次续（2026-11-23，累计 33/1690 文件 tested）

- [x] `base/common/path.dart`：Node.js v22.15.0 path 库完整 1:1 拷贝（1589 行）。win32/posix 两套 IPath 实现（resolve/normalize/join/relative/dirname/basename/extname/format/parse/toNamespacedPath）逐行对照，含 UNC 路径、CVE-2024-36139 防护、`..` 归一化等边界。适配：`charCodeAt`→`codeUnitAt`、`slice`→`substring`、varargs→`List<String>`、对象字面量→ParsedPath/类、`_format.bind`→方法、`repeat`→`*`；算法与控制流未改。
- [x] 测试 `test/monaco_base_test.dart` 追加 3 个 path case；两测试文件合计 **30 case 全绿**；全量 analyze 零 error/warning。

**下一批继续**：`path` 已就绪 → 解锁 `uri`(765) → `map`(1027) → 逼近 `lifecycle`；`strings`(1434)/`buffer`(582)/`stream`(790) 与核心环 `arrays↔cancellation↔event↔lifecycle`（含 `async`2752/`event`1991 巨兽）仍未翻。

### base 工具链批次续二（2026-11-23，累计 35/1690 文件 tested）

- [x] `base/common/uri.dart`：完整 1:1 翻译 `uri.ts`（765 行）。`URI`/`Uri`/`UriComponents`/`UriState`/`UriChange`、`isUri`/`isUriComponents`、`withChanges`(源 `with`，Dart 关键字改名)、`parse`/`file`/`from`/`joinPath`/`revive`/`toString`/`toJSON`、`uriToFsPath`、percent 编码解码全链路逐行对照。适配：`class Uri` 与 dart:core 同名 → 双重 import（默认 + `as core`）访问 `core.Uri.encodeComponent/decodeComponent`；`[Symbol.for('debug.description')]()` → `debugDescription()`；对象字面量参数 → `UriChange`/`UriComponents` 值类 + `undefined` 哨兵；`new Error` → `StateError`；`charCodeAt` 越界 → -1 助手（保持与 NaN 比较恒 false 的语义）。
- [x] `base/common/map.dart`：完整 1:1 翻译 `map.ts`（1027 行）。`getOrSet`/`mapToString`/`setToString`、`ResourceMap`/`ResourceSet`、`LinkedMap` + `Touch`、`Cache`/`LRUCache`/`MRUCache`、`CounterSet`/`BidirectionalMap`/`SetMap`/`mapsStrictEqualIgnoreOrder`/`NKeyMap` 全部成员与算法。适配：`MapIterator`+generator → `sync*` Iterable，`_state` 迭代修改检测通过"外层立即捕获 state、内层生成器消费"保持源码语义；`[Symbol.iterator]`/`[Symbol.toStringTag]` → 普通成员；tuple → Dart record；`Math.round` → `.round()`。
- [x] 测试 `test/monaco_base_test.dart` 追加 11 个 case（uri 5 + map 6）；两测试文件合计 **24 case 全绿**；`dart analyze` 两文件零 error/warning。

**下一批**：逼近核心环与剩余 base 叶子——`strings`(1434)/`buffer`(582)/`stream`(790)、`assert`已翻、`equals`；再进核心环 `arrays↔cancellation↔event↔lifecycle`（含 `async`2752/`event`1991 巨兽），解锁 T1 剩余 59 文件。

### base 工具链批次续三（2026-11-23，累计 41/1690 文件 tested）

- [x] 依赖闭包扫描发现 32 个依赖已闭合的 base 文件，本批先落地其中 6 个基础小文件：`base/common/idGenerator.dart`、`hierarchicalKind.dart`、`navigator.dart`、`diff/diffChange.dart`、`range.dart`、`uuid.dart`。
- [x] `uuid.ts` 的 `crypto.randomUUID` 快路径在 Dart 无对应，按源码注释保留判断说明并走 `crypto.getRandomValues` 等价路径（`Random.secure()`）；version bits 设置与 8-4-4-4-12 逐段拼装完全不改。`namespace Range` → class + static，对象字面量 → `IRange`/`IRangedGroup` 值类；`ArrayNavigator` 构造函数中引用前序参数的默认值 → Dart 可选位置参数 + 初始化列表解析。
- [x] 测试 `test/monaco_base_test.dart` 追加 8 个 case（idGenerator 1 + hierarchicalKind 1 + navigator 1 + diffChange 1 + range 1 + uuid 3，其中 uuid 3 个逐条对应 `uuid.test.ts`）；测试文件合计 **32 case 全绿**；6 个文件 `dart analyze` 零 error/warning。

**下一批**：继续消费剩余 26 个依赖闭合 base 文件（`numbers`/`mime`/`objects`/`color`/`json`/`keyCodes` 等），再进核心环 `arrays↔cancellation↔event↔lifecycle`。

### base 工具链批次续四（2026-11-23，累计 43/1690 文件 tested）

- [x] `base/common/numbers.dart`：1:1 翻译 `numbers.ts`（121 行），`clamp`/`formatTokenCount`/`rot`/`Counter`/`MovingAverage`/`SlidingWindowAverage`/`isPointWithinTriangle`/`randomChance`。`assert`→`assertCondition`、`Math.random()`→`math.Random`、`new Array(size).fill(0)`→`List.filled`。
- [x] `base/common/mime.dart`：1:1 翻译 `mime.ts`（146 行），`Mimes`/`mapExtToTextMimes`/`mapExtToMediaMimes`/`getMediaOrTextMime`/`getMediaMime`/`getExtensionForMimeType`/`normalizeMimeType`/`isTextStreamMime`。`Object.freeze({...})`→class+static const；`string|string[]`→`Object` + `is List`；重载→可选参数；依赖顶层 `extname` 已在 path.dart 提供。
- [x] 测试追加 5 case（numbers 3 + mime 2，逐条对应 `numbers.test.ts`/`mime.test.ts`）；base 测试文件合计 **37 case 全绿**；两文件 `dart analyze` 零 error/warning。

**下一批**：`objects`(动态对象语义，单独处理)、`color`/`json`/`keyCodes` 等剩余依赖闭合 base 文件，再进核心环。

### base 工具链批次续五（2026-11-23，累计 44/1690 文件 tested）

- [x] `base/common/objects.dart`：1:1 翻译 `objects.ts`（298 行），`deepClone`/`deepFreeze`/`cloneAndChange`/`mixin`/`equals`/`safeStringify`/`stableStringify`/`distinct`/`getCaseInsensitive`/`filter`/`mapValues` 全部成员。适配：TS `any`/对象字面量 → `Object?`/`Map<String,Object?>`；`Object.entries/keys`+`for..in`+`hasOwnProperty` → `Map.entries/keys`/`containsKey`；`Object.freeze` → identity Set 标记；`JSON.stringify` 的 JS replacer `this` 绑定无 Dart 对应 → 自实现 `_jsonStringifyWithReplacer`（保留 ancestors 循环检测、`[Circular]`/`[BigInt]` 语义）；`stableStringify` 自实现确定性 key 排序 + 祖先 tracking。
- [x] 测试追加 4 case（objects: equals/mixin+clone+distinct/safeStringify/stability，逐条对应 `objects.test.ts`）；base 测试文件合计 **41 case 全绿**；`dart analyze` 零 error/warning。
- [x] 注意：测试中 `equals` 与 `package:matcher` 同名冲突，objects.dart import 加 `as objs` 前缀。

**下一批**：`color`/`json`/`keyCodes`/`mime`已翻 等剩余依赖闭合 base 文件，再进核心环 `arrays↔cancellation↔event↔lifecycle`。

### base 工具链批次续六（2026-11-23，累计 47/1690 文件 tested）

- [x] `base/common/managedSettings.dart`：1:1 翻译 `managedSettings.ts`（82 行），`IExtraKnownMarketplaceEntry` discriminator union → 抽象基类 + `Github`/`Git` 值类，`extraKnownMarketplacesToConfigDict`/`isUnsafeMarketplaceKey` 逐行对照（含 `__proto__`/`constructor`/`prototype` 原型污染防护）。
- [x] `base/common/layout.dart`：1:1 翻译 `layout.ts`（166 行），`layout`/`layout2d` 全部逻辑；`const enum`→class+static const，对象字面量→值类；同时把 `range.dart` 的 `IRange`/`IRangedGroup` 字段由 `int` 改为 `num` 以贴合源码 `number` 语义（现有 int 测试仍兼容）。
- [x] `base/common/date.dart`：1:1 翻译 `date.ts`（342 行），`getExpirationTime`/`isExpired`/`getRemainingTimeInSeconds`/`fromNow`/`fromNowByDay`/`getDurationString`/`toLocalISOString`/`safeIntl` 全部。`Date`→`DateTime`；`Intl.*` 无 Dart 对应 → 最小承载类（`IntlLocale` 用 `_` 抛错模拟 `en_IT` 触发 fallback）；`Date.now()`→`millisecondsSinceEpoch`。
- [x] `nls.dart` 的 `_format` num 分支补 JS number 字符串语义（整数 double 去 `.0`，如 `1000/1000`→`'1'` 而非 `'1.0'`），以保证 `getDurationString` 断言与源码一致。
- [x] 测试追加 6 case（managedSettings 1 + layout 2 + date 3，date 逐条对应 `date.test.ts`）；base 测试文件合计 **47 case 全绿**；三文件 `dart analyze` 零 error/warning。

**下一批**：剩余依赖闭合 base 文件（`color`942/`json`1344/`keyCodes`838/`jsonSchema`330 等），再进核心环 `arrays↔cancellation↔event↔lifecycle`。

### base 工具链批次续七（2026-11-23，累计 49/1690 文件 tested）

- [x] `base/common/performance.dart`：1:1 翻译 `performance.ts`（149 行），`_definePolyfillMarks`/`_define`/`_factory` polyfill 结构与 `mark`/`clearMarks`/`getMarks`。JS 全局 `globalThis`/`performance`/`process` → library-level 单例 + polyfill 路径；`Date.now()`→`DateTime.now()`。
- [x] `base/common/comparers.dart`：1:1 翻译 `comparers.ts`（356 行），全部 compare 函数；tuple→Dart record，`string|null`→`String?`。**JS `a || b` 组合比较结果用 `_or`（首个非零）**，非按位或。补 `date.dart` 的 `IntlCollator.compare` numeric 排序（数字段按值）+ `resolvedOptions()`。
- [x] **平台限制诚实记录**：`Intl.Collator` 完整 ICU locale collation 无 Dart 标准库对应，`comparers.test.ts` 中纯 locale 顺序断言（如 `Z` vs `a`）无法覆盖；测试只验证 numeric/disambiguate、unicode、路径、prefix 等控制流一致部分，并在测试注释中标注。
- [x] 修复 `comparePaths` 中 `late final` 在循环内重复赋值 bug（源码是普通 `let` 每轮重赋值）→ 改为循环内局部声明。
- [x] 测试追加 3 case（comparers 2 + performance 1）；base 测试文件合计 **50 case 全绿**；三文件 `dart analyze` 零 error/warning。

**下一批**：剩余依赖闭合 base 文件（`color`942/`json`1344/`keyCodes`838 等），再进核心环。

### base 工具链批次续八（2026-11-23，累计 51/1690 文件 tested）

- [x] `base/common/normalization.dart`：1:1 翻译 `normalization.ts`（63 行），`normalizeNFC`/`normalizeNFD`/`tryNormalizeToBase`，含 LRUCache(10000)、nonAscii 快路径、IIFE 闭包结构。
  - **平台限制承载**：Dart 无 `String.prototype.normalize`（无 unicode 依赖）→ `_nfdTable`（Latin-1/Latin Extended-A 正则分解表）+ `_nfcCompose` 逆向组合，保留源码控制流。`normalization.test.ts` 全部断言通过（预组合重音、大小写、base+combining 边界）。
- [x] `base/common/jsonSchema.dart`：1:1 翻译 `jsonSchema.ts`（330 行），`IJSONSchema`/`JSONSchemaType`/`IJSONSchemaSnippet` + `getCompressedContent` + `traverseNodes`。
  - TS 纯类型体操（`TypeFromJsonSchema`/`UnionOf`/`IsRequired` 等）运行时无意义，仅注释保留（与全项目 `type X<T>=` 处理一致）。
  - JS `Map<IJSONSchema,Equals>` 对象身份 → `HashMap.identity()`；`JSON.stringify(root, replacer)` → 自实现 `_jsonStringify`（replacer 收到原始对象引用）。`jsonSchema.test.ts` 两条压缩用例通过。
- [x] 测试追加 5 case（normalization 3 + jsonSchema 2）；base 测试文件合计 **55 case 全绿**；两文件 `dart analyze` 零 error/warning。

**下一批**：剩余依赖闭合 base 文件（`color`942/`json`1344 等），再进核心环 `arrays↔cancellation↔event↔lifecycle`。

### base 工具链批次续九（2026-11-23，累计 52/1690 文件 tested）

- [x] `base/common/keyCodes.dart`：1:1 翻译 `keyCodes.ts`（838 行）——两个 `const enum`（KeyCode 134 项 / ScanCode 195 项）展开为 `class + static const int`（隐式值精确递增）、229 条 `IMappingEntry` 用 record 表逐行保留（Python 从源码正则解析生成，避免手工转录）、`KeyCodeStrMap`/五个导出映射 + `ScanCodeUtils`/`KeyCodeUtils`/`KeyMod`/`KeyChord`/`isModifierKey`。
  - **适配**：源码顶层 IIFE（模块加载即初始化）→ Dart 懒初始化 + 公开 getter 触发；`toString` 与 dart:core 冲突 → `toStringValue`。
  - **发现并修复真实 bug**：`_setAt` 用 `value` 填充数组空洞会让 `seenKeyCode` 全部预置为 true（源码 `[]` 未赋值项为 undefined/falsey）→ 改为按类型填中性默认值。`keyCodes.test.ts` 的 Minus/Space 全链路断言（41 检查）通过。
- [x] 测试追加 3 case；base 测试文件合计 **58 case 全绿**；文件 `dart analyze` 零 error/warning。

**下一批**：剩余依赖闭合 base 文件（`json`1344 等），再进核心环 `arrays↔cancellation↔event↔lifecycle`。

### base 工具链批次续十（2026-11-23，累计 53/1690 文件 tested）

- [x] `base/common/color.dart`：1:1 翻译 `color.ts`（942 行）——`RGBA`/`HSLA`/`HSVA`/`Color` 全部成员（转换、亮度、对比度、blend/mix/flatten、getLighter/DarkerColor、静态色值）+ `Color.Format.CSS`（format/parse/parseHex/parseNamedKeyword 148 项命名颜色）。命名颜色表用 Python 从源码正则解析生成，避免手工转录。
  - **适配**：JS `|0`→`.toInt()`、`>>>0`→`& 0xFFFFFFFF`、`toFixed`/`+toFixed(2)`→`_toFixed`/`_fixedNum`；static `equals`→`equalsStatic`、static `transparent`→`transparentColor`（Dart static/instance 同名冲突）；`final rgba`→`late final`（构造体三分支赋值）。
  - `color.test.ts` 110 条断言全过（亮度、blend、HSL/HSV 互转、parseHex 四格式、命名颜色、format、toNumber32Bit、对比度）。
- [x] 测试追加 4 case；base 测试文件合计 **62 case 全绿**；文件 `dart analyze` 零 error/warning。

**下一批**：剩余依赖闭合 base 文件，再进核心环 `arrays↔cancellation↔event↔lifecycle`。

### base 工具链批次续十一（2026-11-23，累计 54/1690 文件 tested）

- [x] `base/common/json.dart`：1:1 翻译 `json.ts`（1344 行）——`createScanner`（完整 JSON scanner：hex/number/string/注释/关键字）、`parse`/`parseTree`/`visit`（容错解析器，含 trailing comma / disallowComments / `__proto__` 防护）、`getLocation`/`findNodeAtLocation`/`getNodePath`/`getNodeValue`/`contains`/`findNodeAtOffset`/`getNodeType`、`ParseOptions`/`JSONVisitor`/`Node` 值类。四个 `const enum` → class + static const。
  - **适配**：`throw earlyReturnException` 哨兵 → Dart `identical` 捕获；`Object.create(null)` → 普通 Map（Dart 无原型）；`JSON.parse(number)` → num.parse；`string|number` Segment → `Object`。
  - **发现并修复两个真实 bug**：① JS `substring(-1,n)` clamp 到 0，Dart 抛 RangeError → slash 分支起始 clamp；② Dart switch **不像 TS 那样从非空 case fall through**，minus→digit 的 fall through 丢失（`-0.1` 被切成两个 token）→ 显式内联 digit body。`json.test.ts` 59 条断言通过。
- [x] 测试追加 3 case；base 测试文件合计 **65 case 全绿**；文件 `dart analyze` 零 error/warning。

**下一批**：剩余依赖闭合 base 文件，再进核心环 `arrays↔cancellation↔event↔lifecycle`。

### base 工具链批次续十二（2026-11-23，累计 57/1690 文件 tested）

- [x] `base/common/jsonFormatter.dart`：1:1 翻译 `jsonFormatter.ts`（262 行），`format`/`toFormattedString`/`repeat`/`computeIndentLevel`/`getEOL`/`isEOL` 全部成员 + `FormattingOptions`/`Edit`/`Range` 值类。`const enum` SyntaxKind/ScanError 直接复用 json.dart；Dart switch 不 fall through → `StringLiteral` 落到字面量组的逻辑抽为共享局部函数 `literalFollow()`；**JS `substring` 越界 clamp** → 加 `_substring` 辅助（range helper 的 off-by-one 靠 JS clamp 兜住，Dart 会抛 RangeError，已复刻）。`jsonFormatter.test.ts` 全部 18 个 format 用例 + toFormattedString 通过。
- [x] `base/common/keybindings.dart`：1:1 翻译 `keybindings.ts`（285 行），`decodeKeybinding`/`createSimpleKeybinding` + `KeyCodeChord`/`ScanCodeChord`/`Keybinding`/`ResolvedChord`/`ResolvedKeybinding`。`const enum BinaryKeybindingsMask` → class + static const；`type Chord = KeyCodeChord | ScanCodeChord` → abstract class 双实现；`number | number[]` → Object；`OS` 参数保留源码命名（info）。`keybindings.test.ts` issue #173325 + 自建 decode/equals 断言通过。
- [x] `base/common/naturalLanguage/korean.dart`：1:1 翻译 `korean.ts`（424 行），`getKoreanAltChars`/`disassembleKorean`/`getCodesFromArray`/`addCodesToBuffer` + 4 张韩文 Jamo 数据表（19/21/27/51 项，combo 值用脚本从源码 `const enum AsciiCodeCombo` 精确预计算）。`Uint32/Uint8/Uint16Array` → `List<int>`；`subarray` → 不可变 `sublist`。`korean.test.ts` 全部 5 组 case（初声/终声/元音/兼容 Jamo/82 个组合词）通过。
- [x] 测试追加 11 case（jsonFormatter 4 + keybindings 2 + korean 5）；base 测试文件合计 **76 case 全绿**；三文件 `dart analyze` 零 error/warning（仅源码风格 info）。
- [x] **依赖分析**：核心环 `arrays↔cancellation↔event↔lifecycle↔async` 彼此成环，且 `event`/`async` 依赖 `observable`/`resources`（各自闭包 48 个未翻译文件），当前无法闭合，继续按依赖闭包推进 base 工具链小文件。

**下一批**：继续消费依赖闭合的 base 文件（`executionGraph`/`rpc`/`keybindings` 已翻等），或转 `platform/registry/common/platform.ts`、`platform/contextkey/common/scanner.ts`（有源码测试、依赖闭合），再择机啃核心环。

### base/platform 工具链批次续十三（2026-11-23，累计 60/1690 文件 tested）

- [x] `base/common/jsonEdit.dart`：1:1 翻译 `jsonEdit.ts`（184 行），`removeProperty`/`setProperty`/`withFormatting`/`applyEdit`/`applyEdits` 全部。复用 json.dart 的 Node/JSONPath/parseTree/findNodeAtLocation 与 jsonFormatter.dart 的 Edit/format/isEOL；`JSON.stringify(value)` → dart:convert 承载（integer-valued double 去 `.0`）；`getInsertionIndex?` → `int Function(List<String>)?`。
- [x] **修复 json.dart 既有翻译缺陷**：TS `parseTree` 结尾有 `if (result) delete result.parent` 并返回 `Node | undefined`，dart 版原为 `children![0]` 直接解引用 + 返回非空 `Node`，空文档输入（jsonEdit 的 `setProperty('', ...)`）抛 RangeError。按 1:1 改返回类型 `Node?` + `isEmpty ? null : children[0]` + 保护 parent 清除；同步适配 jsonEdit（恢复 `root ? root.offset : 0`）与测试（`root!`）。这是继 JS substring clamp 之后又一处"TS 隐含 undefined 分支"适配点。
- [x] `base/common/keybindingLabels.dart`：1:1 翻译 `keybindingLabels.ts`（185 行），`ModifierLabels`/`KeyLabelProvider<T>`/`ModifierLabelProvider` + 四个 Provider（UILabel/Aria/ElectronAccelerator/UserSettings）。`nls.localize({key,comment}, msg)` → 传 Map（非 int 时 nls 返回 msg 原文，等价 en locale）；`ModifierLabels[]` 带 index0 空位 → `List<ModifierLabels?>`。源码 test 依赖 US-layout resolved keybinding（不在闭包），改为直接断言 Provider.toLabel 标签拼接。
- [x] `platform/registry/common/platform.dart`：1:1 翻译 `platform.ts`（64 行，platform 层），`IRegistry`/`RegistryImpl`/`Registry` 单例。`as<T>` → `Object? as()`；`data.get(id) || null` → `Map[id]`（registry 存的是对象/函数，恒 truthy）；dispose 用 dynamic 读 `value.dispose`。`platform.test.ts` 全部 4 个断言组通过。
- [x] 测试追加 7 case（jsonEdit 4 + keybindingLabels 2 + platform registry 1）；base 测试文件合计 **83 case 全绿**；三文件 `dart analyze` 零 error/warning（仅源码风格 info）。

**下一批**：继续消费依赖闭合的小文件（`platform/contextkey/common/scanner.ts` 385 行、`base/common/observableInternal/logging/debugger/rpc.ts` 111 行，`base/test/common/executionGraph.ts` 544 行等，均有源码 test），择机啃核心环。

### platform/base 工具链批次续十四（2026-11-23，累计 62/1690 文件 tested）

- [x] `platform/contextkey/common/scanner.dart`：1:1 翻译 `scanner.ts`（385 行），`TokenType`（const enum → static const）、`Token`（discriminated union 扁平为单值类，`lexeme`/`isTripleEq` 用 nullable 承载 `'lexeme' in token`）、`LexingError`、`Scanner`（`getLexeme`/`reset`/`scan` + `_match`/`_advance`/`_peek`/`_addToken`/`_error`/`_string`/`_quotedString`/`_regex`/`_isAtEnd`）、`hintDidYouMean`（rest → `List<String>`）。**关键适配**：JS 正则 `[a-zA-Z0-9_...\p{L}-]+/uy` 的 `\p{L}` + sticky flag 在 Dart RegExp 不支持 → 手写 `_isStringCharCode` 字符集匹配（ASCII 显式 + `c >= 0xAA` 覆盖 Unicode 字母）；nbsp（0xA0）在 scan switch 中按空白处理。`scanner.test.ts` 全部 34 case 精确搬运，含复杂正则、转义、`\w`→`w`、JSON.parse、nbsp 场景，全绿。
- [x] `base/common/observableInternal/logging/debugger/rpc.dart`：1:1 翻译 `rpc.ts`（111 行），`IChannel`/`IChannelHandler`/`RpcRequestResult`（union → 抽象基类 + RpcResult/RpcError）、`API`/`Side`、`ChannelFactory`、`SimpleTypedRpcConnection`。**关键适配**：JS `Proxy` 用 `noSuchMethod` 承载（`then` 返回 null 复刻"不可 thenable"，method/getter 两态都覆盖）；构造函数不能在 initializer 引用实例成员 → 改为构造体初始化 `_channel`/`api`。`rpc.test.ts` 1 case + 转发 extra 1 case 通过。
- [x] 放弃 `platform/environment/common/argv.ts`：其 `argv.test.ts` 实际测的是 `node/argv.ts`（formatOptions/parseArgs），`common/argv.ts` 仅接口定义无运行时逻辑，跳过以免无意义的类型翻译。
- [x] 测试追加 36 case（scanner 34 + rpc 2）；base 测试文件 83 → **119 case 全绿**；两文件 `dart analyze` 零 error/warning。

**下一批**：继续消费依赖闭合且有独立 test 的文件（`base/browser/ui/list/rangeMap.ts` 219 行、`base/browser/ui/scrollbar/scrollbarState.ts` 244 行、`editor/.../smallImmutableSet.ts` 177 行、`platform/instantiation/common/graph.ts` 112 行等），择机啃核心环。

### platform/editor/base 逻辑批次续十五（2026-11-23，累计 66/1690 文件 tested）

- [x] `platform/instantiation/common/graph.dart`：1:1 翻译 `graph.ts`（112 行），`Node<T>`/`Graph<T>`（roots/insertEdge/removeNode/lookupOrInsertNode/lookup/isEmpty/toString/findCycleSlow/_findCycle）。其 `graph.test.ts` 是文件名碰撞误匹配（实际测 inlineCompletions 的 graph），改用源码语义自建 3 case（环检测/roots/toString）。
- [x] `editor/contrib/inlineCompletions/browser/model/graph.dart`：1:1 翻译真正的 `graph.ts`（83 行），`DirectedGraph<T>`（`from`/`removeCycles`/`getOutgoing`）。`removeCycles` 返回 `{ foundCycles }` → `Map<String,dynamic>`；合作 DFS 闭包捕获 `toRemove`/`foundCycles`。`graph.test.ts` 全部 11 case 精确搬运（含重复边/自环/复杂环/多断开环/number 节点）。
- [x] `editor/.../bracketPairsTree/smallImmutableSet.dart`：1:1 翻译 `smallImmutableSet.ts`（177 行），`SmallImmutableSet<T>`（add/has/merge/intersects/equals）+ `IDenseKeyProvider`/`identityKeyProvider`/`DenseKeyProvider`。**两个关键适配**：(1) TS 缓存 `SmallImmutableSet<any>` 跨 T 共享单例——Dart reified generics 下 `Never`/`dynamic` 单例会在 `add(String)` 运行时类型检查失败 → 改为**按 `Type` 分桶缓存**（每 T 独立 129 槽），保持每种元素类型的 identity 语义；(2) TS `newItems[idx] |= ...` 在 `idx == length` 时稀疏数组自动扩展 → Dart `while (length <= idx)` 补足。`smallImmutableSet.test.ts` 2 case + reverseLookup 自建 1 case 通过。
- [x] `base/browser/ui/list/rangeMap.dart`：1:1 翻译 `rangeMap.ts`（219 行），`groupIntersect`/`shift`/`consolidate`/`concat`/`IItem`/`IRangeMap`/`RangeMap`。复用 base/common/range.dart 的 `IRange`/`IRangedGroup`/`Range`（同 shape）；`Number.POSITIVE_INFINITY` → `double.infinity`；`Math.floor` → `.floor()`；JS `|| 0` 用三元保护越界。`rangeMap.test.ts` 14 case 精确搬运（intersection/multiIntersect/consolidate/insert/delete/indexAt/positionAt/top padding），全绿。
- [x] 测试追加 31 case（instantiation graph 3 + DirectedGraph 11 + smallImmutableSet 3 + rangeMap 14）；base 测试文件 119 → **150 case 全绿**；四文件 `dart analyze` 零 error/warning（仅文件名风格 info）。
- [x] **依赖闭包核对**：确认 `graph.test.ts` 导入的是 `../../browser/model/graph.js`（inlineCompletions 的 graph），非 `platform/instantiation/common/graph.ts`——避免按文件名误配测试。

**下一批**：继续消费依赖闭合且有独立 test 的文件（`scrollbarState.ts` 244 行、`compressedVirtualizedScrollLayout.ts` 239 行、`overviewZoneManager.ts` 248 行、`bufferDirtyTracker.ts` 73 行、`mock.ts` 48 行等），择机啃核心环。
