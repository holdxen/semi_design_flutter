# SemiCommitGraph 提交历史图

从 Gittyup / GitAhead 的 `CommitList` graph 视图移植而来的 Flutter 原生组件。用纯数据渲染 Git 提交 DAG 的分支拓扑（圆点、纵向通道、分叉/合并曲线、未提交虚线），不依赖 libgit2，也不运行任何 JS/WebView。

原始实现：`src/ui/CommitList.cpp`（CommitModel + CommitDelegate），Copyright (c) 2016 Scientific Toolworks, Inc.，MIT 协议。

## 数据契约

`SemiCommitGraphNode` 是普通不可变数据类：

| 字段 | 含义 |
|---|---|
| `id` | 唯一 id（必填，如完整 hash） |
| `shortId` | 列表里显示的短 id；为空时取 `id` 前 7 位 |
| `summary` | 提交标题 |
| `author` / `timestamp` | 作者与已格式化时间（组件不负责日期格式化） |
| `refs` | 分支/标签名，显示为 `[name]` |
| `parents` | 父 id 列表，按序（第一个是第一父） |
| `uncommitted` | 工作区改动伪行，画成虚线通道 |

**顺序要求**：提交必须按拓扑序传入——子在前、父在后，即 `git log --topo-order` 的输出顺序。`SemiCommitGraphLayout` 是纯函数，可在任意线程调用；它不校验顺序，错误顺序会产生错误的通道连接。

## 用法

```dart
SemiCommitGraph(
  commits: [
    SemiCommitGraphNode(
      id: 'c2', shortId: 'c2', summary: 'Merge feature',
      parents: ['c1a', 'c1b'], refs: ['main'],
    ),
    SemiCommitGraphNode(id: 'c1b', shortId: 'c1b', summary: 'Feature', parents: ['c0']),
    SemiCommitGraphNode(id: 'c1a', shortId: 'c1a', summary: 'Main', parents: ['c0']),
    SemiCommitGraphNode(id: 'c0', shortId: 'c0', summary: 'Initial'),
  ],
  onCommitSelected: (node) => print(node.id),
)
```

参数：

- `commits`（必填）：拓扑序提交列表
- `onCommitSelected`：点击行回调
- `graphVisible`：是否显示 graph 列（默认 `true`）
- `selectedId`：外部受控选中项；为空时组件内部管理选中态
- `shrinkWrap` / `physics`：透传给内部 `ListView.builder`

## 主题

通过 `SemiCommitGraphTheme` 局部覆盖，未指定项回落到全局 `SemiTheme` 的颜色 token 与内置默认值：

```dart
SemiCommitGraphTheme(
  data: SemiCommitGraphThemeData(
    branchColors: [Color(0xFF53AFEC), Color(0xFF82DA2A)],
    rowHeight: 56,
    taintedColor: Color(0xFF888888),
  ),
  child: SemiCommitGraph(commits: commits),
)
```

`SemiCommitGraphThemeData` 可覆盖：分支配色、未提交色、背景/选中色、圆点/文字/元信息/引用颜色、线宽、圆点半径、行高、水平内边距。默认分支配色取自 Gittyup `conf/themes/Dark.lua` 的 `graph.edge1..edge15`。

## 与 C++ 原实现的映射

| Gittyup / C++ | Flutter / Dart |
|---|---|
| `GraphSegment`（9 种） | `SemiGraphSegment`（同名小写） |
| `CommitModel::columns()` | `SemiCommitGraphLayout._columns()` |
| `fetchRows()` / `nextColor()` | `SemiCommitGraphLayout.compute()` / `_nextColor()` |
| `git::Commit` | `SemiCommitGraphNode`（字符串 id） |
| `git::RevWalk` | 调用方传入的拓扑序列表 |
| `CommitDelegate::paint` 的 graph 段 | `_CommitGraphPainter`（dart:ui Canvas） |
| `Application::theme()->branchTopologyEdges()` | `SemiCommitGraphThemeData.branchColors` |
| `QtConcurrent` 分页后台构建 | 同步一次构建；大数据可在 isolate 调 `compute()` |

## 有意不移植的部分

引用徽章图形（用纯文本 `[ref]` 代替）、星标、紧凑/双列模式、作者与日期的自动格式化、`Badge`/`ProgressIndicator`。这些属于应用层显示逻辑；需要时在 `_CommitGraphRow` 上扩展即可。
