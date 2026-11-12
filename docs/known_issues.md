# 已知问题与框架怪癖记录

移植/测试过程中遇到的、暂未根治的上游框架行为问题。每条含症状、最小复现、已排除假设与后续动作。

---

## 1. 滚动贴边 + tap 聚焦后，下一次命中判定失效一次（Flutter 框架级）

- **记录时间**：2026-11（InputNumberPage 页面测试期间）
- **状态**：未根因；测试层已绕过；运行时影响面窄但真实存在

### 症状

在 `SingleChildScrollView`（或任何滚动视口）中，当目标控件**恰好贴住视口上边缘（global y ≈ 0～6）**时：

1. 用 **tap 点击输入框聚焦**；
2. 紧接着点击该输入框内/附近的任何可点区域（步进器按钮、另一个按钮等）——**这次点击的命中判定失效**（事件打到外层 Scrollable，目标子树整个瞬时不可命中，`warnIfMissed` 显示命中路径是 `[Listener, GestureDetector, Listener, _RenderScrollSemantics, …]` 即滚动层兜底）；
3. 再下一次点击（或任意一次 tap 之后的 pump）恢复正常，后续全部正常。

与 InputNumber、步进器、内嵌/外置形态**无关**——外置步进器同样复现；与点击目标无关——"被吞掉"的是紧随 tap-to-focus 的**任意一次** hit test。

### 最小复现

```dart
testWidgets('repro', (tester) async {
  final controller = ScrollController();
  await tester.pumpWidget(
    SemiTheme(
      data: const SemiThemeData.light(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(),
          child: SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 750),          // 让目标滚到视口顶边
                const SizedBox(width: 280, child: SemiInputNumber(initialValue: 5)),
                const SizedBox(height: 40),
                const SizedBox(width: 280, child: SemiInputNumber(initialValue: 1)),
                const SizedBox(height: 800),          // 保证可滚到位
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  controller.jumpTo(844);                            // 第二个输入框贴 y≈2
  await tester.pump();
  await tester.tap(find.byType(EditableText).last);  // tap 聚焦（必要条件）
  await tester.pump();
  final up = find.byKey(SemiInputNumber.upButtonKey).last;
  final p = tester.getRect(up).center;
  await tester.tapAt(p);                             // ← 命中失效，无回调
  await tester.pump();
  await tester.tapAt(p);                             // ← 正常
});
```

### 对照实验矩阵（已做，均为确定性结果）

| 条件 | 结果 |
|---|---|
| tap 聚焦 + 目标贴顶边 (y≈4) + 点按钮 | **首击失效** |
| tap 聚焦 + 目标 y≈200 + 点按钮 | 正常 |
| `focusNode.requestFocus()`（不发指针）+ 贴顶边 + 点按钮 | 正常 |
| 无聚焦 + 贴顶边 + 直点按钮 | 正常 |
| tap 聚焦 + 贴顶边 + 先点中性空白处 + 点按钮 | 正常（被吞的是中性 tap） |
| tap 聚焦 + 贴顶边 + 加 200ms 沉降帧 + 点按钮 | **仍失效**（与时间无关） |
| 内嵌步进器（focus 揭示）/ 外置步进器 / 带 suffix / 多实例 | 均复现（与形态无关） |

### 已排除的假设

- 组件侧：步进器揭示时的 suffix 子树交换（`IgnorePointer`+`Opacity` 常驻方案无效）；长按连发；`_notAllowed` 门控；回调回写。
- 布局/几何：`localToGlobal`（getRect）与覆盖遍历显示按钮盒子**确实盖住**触点，但 `renderView.hitTest` 命中路径却落在滚动层——命中变换与绘制变换在该瞬间不一致。
- `RenderSingleChildViewport` 的 `_paintOffset` 是 `offset.pixels` 计算 getter，paint/hitTest 同源，无缓存错位。
- 事件侧：首个 tap 的 hit test（`startGesture` 时）即失效，与 arena/gesture 无关；tap 后的 pump 才恢复。

### 当前处理

- `example/test/input_number_page_test.dart` 的 `tapFocus()` helper：tap 聚焦后补一次中性 `tapAt(Offset(700, 500))` 吸收被吞的命中（注释里已注明原因）。
- 运行时无需 workaround（用户点击间隔大，但仍可能在"恰好贴边"场景遇到第一下没反应——复现条件苛刻，影响面窄）。

### 下一步（待办）

- [ ] 用纯 widgets 写一个不依赖本库的最小复现（Scrollable + Focus + 任意可点子树），验证与 `setState` 重建 × 视口裁剪边的关联。
- [ ] 若纯 Flutter 可复现 → 整理到 flutter/flutter 提 issue（关键词：hit test / scroll viewport edge / focus rebuild / first tap dropped）。
- [ ] 关注上游 `RenderSingleChildViewport.hitTestChildren`、`RenderFlex.hitTestChildren` 与 focus 引发的 relayout 时序。
