# SemiNumeral

`SemiNumeral` 接受 String，组合 `SemiText`，无需 Material。包入口和 `src/components/typography.dart` 均导出组件、枚举和纯函数。

```dart
SemiNumeral('完成率 0.01005', rule: SemiNumeralRule.percentages, precision: 2);
// 完成率 1.01%
formatNumeral('-1.005', precision: 2); // -1.00
```

参数 `rule` 为 `SemiNumeralRule`：`text`（默认，保留文本）、`numbers`（仅数字，以逗号连接）、`bytesDecimal`（1000）、`bytesBinary`（1024）、`percentages`、`exponential`。`precision` 是 0..98 的 int，默认 0；非法值抛 RangeError。`truncate` 为 `SemiNumeralTruncate.round`（默认）、`ceil`、`floor`。`parser` 为 `String Function(String)?`，收到完整原文且完全优先，包括跳过内置精度验证。纯函数 `formatNumeral` 接受相同格式化参数。

透传 SemiText 的 type、size、weight、strong、disabled、mark、code、underline、delete、style、icon、link、textAlign、textDirection、softWrap、maxLines、overflow、semanticsLabel。格式化参数和局部主题更新随 build 生效。link 使用 SemiTextLink，导航由调用方负责。无需 Material；不含 copyable、富 ReactNode、动画、货币或 intl。

提取沿用上游 `(-?[0-9]*\.?[0-9]+([eE]-?[0-9]+)?)|([^-\d\.]+)`：不识别科学计数的 `e+`，孤立 `-`、`.` 被跳过；如 `1e+3` 是两个数字片段与中间文本，numbers 输出 `1,3`。空字符串输出空字符串。非有限数字片段（例如 `1e999`）原样保留；NaN、Infinity 是普通文本，受相同正则规则影响。百分比通过十进制指数移位，溢出则保留原片段。

舍入使用 double 的十进制最短表示进行指数移位，round 中点向正无穷，故 1.005 → 1.01、-1.005 → -1.00。负零输出零。Dart 的 toStringAsFixed/toStringAsExponential 仅接受 0..20；本实现用 BigInt 十进制移位和补零支持完整 0..98，exponential 先取得最多 20 位尾数再按 double 尾数处理。指数尾数舍入后不归一化，例如 9.999 在 precision 2 输出 10.00e+0。字节负值不升级，单位最高 YB/YiB，舍入后不重选单位。

大于等于 1e21 的值使用科学计数表示。JS Number 与 Dart double 的最短字符串、指数阈值及极端数字表示存在差异；本实现以十进制精度测试的正常语义为准，不声称所有 Number stringify 位级相等。高精度补零不增加输入 double 的有效数字。

依据：上游 semi-foundation/typography/formatNumeral.ts、semi-ui/typography/numeral.tsx 和 numeralPrecision.test.jsx。
