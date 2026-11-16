# Provenance — vendored dialog engine

本目录是 `flutter_smart_dialog` **5.3.1**（pub.dev，MIT，Copyright (c) 2023 小呆呆666）
的 vendored 副本，作为 SemiModal 移植的弹层底座。原始 LICENSE 见同目录 `LICENSE`。
上游来源：`https://pub.dev/packages/flutter_smart_dialog`（tag 5.3.1，2026-11-05 发布）。

拷贝范围：上游 `lib/src/**` 全量（60 文件）+ 库 barrel。相对上游的改动如下
（逐条可对照 diff）：

## 1. 去 Material（依赖纯度）

- 依赖 `material_ui` / `cupertino_ui` 移除；`import 'package:material_ui/material_ui.dart'`
  伞式引用（46 处）→ `package:flutter/widgets.dart`；`cupertino_ui` 两处为死引用，直接删。
- Material 专属符号换 widgets 等价物：
  - `Theme.of(context).brightness` → `MediaQuery.platformBrightnessOf(context)`
  - `Colors.white/transparent/black` → 字面色
  - `showDialog(useSafeArea: ...)`（material）→ `showGeneralDialog`（widgets，`useSafeArea` 无对应，
    由调用方自行包 SafeArea）
  - `init_dialog.dart` 的 `Material(color: ...)` 风格包装随该文件一并删除（见 3）。
- 上游 `widget/default/**`（Material 风格的 ToastWidget/LoadingWidget/Notify* 预设视觉，7 文件）
  **整体删除**；`DialogProxy` 的 toast/loading/notify builder 缺省为中性 `Text(msg)` 占位
  —— Semi Toast/Notification 移植时以 Semi 视觉替换（config 里挂 builder 即可）。

## 2. ambient Overlay 集成（替代 app 级 init）

上游要求接入方在 `MaterialApp.builder` 挂 `FlutterSmartDialog.init()`（自建 Overlay 盖在
app 之上 + `static BuildContext contextNavigator` 全局注入）。vendored 版改为**绑定到
Navigator 的 ambient Overlay**（与 SemiTooltip/SemiDropdown 同一层级体系，弹层按插入序叠放）：

- `DialogProxy.bind(OverlayState, {navigatorContext})` + `DialogProxy.instance.overlay` 收口；
  `ViewUtils.insertOverlayEntry` 不再按 context 找 Overlay，直接插入绑定层。
- 绑定触发：`SmartNavigatorObserver.navigateChange()`（上游本就追踪 navigator）顺带绑定；
  `SemiApp` 自动挂该 observer（`navigatorObservers` 追加）——**使用方零初始化**。
  不用 SemiApp 的宿主可手动 `DialogProxy.instance.bind(...)`。
- `FlutterSmartDialog` 宿主 widget / `init()` / `boostMonitor` 删除；typedef
  `FlutterSmartToastBuilder`/`FlutterSmartLoadingBuilder` 移至 `kit/typedef.dart`
  （`FlutterSmartStyleBuilder` 是 Material 包装概念，删除）。
- 语义差异（有意取舍）：上游宿主 Overlay 恒在最顶层；ambient 方案里**弹层打开后
  再 push 的路由会盖在弹层之上**（与 SemiTooltip 同特性），换取「tooltip 能画在
  弹层之上」和零初始化。loading 常驻 entry 改为绑定后懒插入（原为 host initialEntries）。

## 3. 测试支持

- `DialogProxy.resetForTest()`（上游自带）扩展：同时清绑定（`_overlay`/`_bound`），
  便于 widget 测试逐例重置。
- 目录内 `analysis_options.yaml` 豁免命名类 lint（上游 `routeClose_nonAnimation` 等
  枚举名逐字保留以便对照）。

其余（dialog 队列/代理、attach 定位、动画生命周期、mask 事件、防抖、路由记录等
引擎逻辑）保持上游原样。
