# SemiBorderBeam

`SemiBorderBeam` 将 Ant Design BorderBeam 的核心视觉移植为 Flutter 装饰组件：一条或多条渐变光束沿子组件的圆角矩形边框循环移动。

## API

```dart
SemiBorderBeam(
  child: const SizedBox(width: 280, height: 120),
  borderRadius: BorderRadius.circular(12),
  count: 2,
  duration: const Duration(seconds: 6),
  lineWidth: 2,
  size: 100,
  outset: 0,
)
```

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `child` | 必填 | 内容组件；Beam 不改变其布局，也不会拦截指针事件。 |
| `color` | Semi 主色 → hover 色 | `SemiBorderBeamColor.solid(Color)` 或 `SemiBorderBeamColor.gradient([...])`。停靠点使用 0–100 百分比。 |
| `count` | `1` | Beam 数量；小于 1 时回退为 1。多条光束按路径均匀错相。 |
| `duration` | `6s` | 一圈动画时长；非正值回退到 6 秒。 |
| `items` | `null` | 每条 Beam 的局部覆盖。提供后优先于 `count`，空列表表示不绘制。 |
| `lineWidth` | `1` | 描边宽度。 |
| `size` | `100` | 光束沿边框的长度（逻辑像素）。 |
| `outset` | `0` | 边框路径向外扩展的逻辑像素。 |
| `borderRadius` | `BorderRadius.zero` | 显式传入子组件的圆角；Flutter 无法读取任意 child 的 CSS 圆角。 |

每个 `SemiBorderBeamItem` 可以覆盖 `color`、`lineWidth`、`size` 和 `outset`，未提供的字段继承外层参数。

## 颜色停靠点

上游组件为渐变尾部保留 30% 的透明区域。因此用户输入的 0–100 停靠点会映射到 0–70%，最后自动追加透明尾端：

```dart
SemiBorderBeamColor.gradient([
  const SemiBorderBeamGradientStop(0, Color(0xff00b96b)),
  const SemiBorderBeamGradientStop(60, Color(0xff1677ff)),
  const SemiBorderBeamGradientStop(100, Color(0xffff4d4f)),
])
```

颜色会按百分比排序并限制在 0–100 范围。

## 与上游的差异

- Flutter 实现不使用 React ref、Portal、CSS mask 或 `offset-path`；Beam 由公开的 `SemiBorderBeamPainter` 沿 `PathMetric` 绘制。
- 子组件需要自行提供尺寸、边框和圆角；`SemiBorderBeam` 只负责叠加装饰层。
- `borderRadius` 需要显式传入，并应与 child 的 `BoxDecoration` 保持一致。
- `TickerMode` 关闭或 `MediaQueryData.disableAnimations` 为真时，动画停止且装饰层隐藏，适合 reduced-motion 场景。
- 无界布局仍由 child 自己决定；如需固定边框尺寸，请用 `SizedBox` 或其他有界父级包裹。

## 示例

```dart
SemiBorderBeam(
  color: const SemiBorderBeamColor.solid(Color(0xff7b61ff)),
  borderRadius: BorderRadius.circular(16),
  lineWidth: 3,
  size: 140,
  child: DecoratedBox(
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xffd9dfe8)),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Padding(
      padding: EdgeInsets.all(20),
      child: Text('BorderBeam'),
    ),
  ),
)
```
