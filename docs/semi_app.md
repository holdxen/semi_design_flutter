# SemiApp

`SemiApp` 是仅依赖 `flutter/widgets.dart` 的应用入口，不创建 MaterialApp、Scaffold 或 Material/Cupertino 本地化。

```dart
import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() => runApp(const SemiApp(
  title: 'Semi example',
  themeMode: SemiThemeMode.system,
  home: SafeArea(child: SemiTitle('Hello Semi')),
));
```

`theme` 和 `darkTheme` 分别默认为 `SemiThemeData.light()` 和 `SemiThemeData.dark()`。`SemiThemeMode.system` 通过 MediaQuery 订阅平台亮度变化；light/dark 强制选择对应主题。字体资源仍需宿主自行注册。

WidgetsApp 的 builder 内按 `SemiTheme → DefaultTextStyle → ColoredBox → Builder → 用户 builder / Navigator` 包装。路由、Navigator Overlay 和用户 builder 都可读取当前主题。默认文字使用 typography 的常规字体、字号、字重、行高和 colorText0；不全局设置 inherit:false，以保留组件的继承语义。背景为 colorBg0；可选 color 是 WidgetsApp 的平台应用标识颜色，并非背景覆盖。

支持 home、routes、onGenerateRoute、onUnknownRoute、initialRoute、navigatorKey、navigatorObservers。home 对应 `/`，不可同时在 routes 声明 `/`。默认 pageRouteBuilder 使用 widgets PageRouteBuilder，进入和退出时长均为零；可传入自定义 PageRouteFactory。onGenerateRoute/onUnknownRoute 返回的 Route 自行决定转场。参数有效性遵循 WidgetsApp；没有路由时可只传 builder，此时不能指定 Navigator key、初始路由或 observers。

```dart
SemiApp(
  home: const Text('Home'),
  routes: {'/details': (_) => const Text('Details')},
  builder: (context, child) {
    final theme = SemiTheme.of(context);
    return ColoredBox(color: theme.colors.colorBg0, child: child!);
  },
)
```

有路由时，用户 builder 必须把 child 放入返回的子树才能保留 Navigator；无路由时 child 为 null。WidgetsApp 提供 Directionality、WidgetsLocalizations、焦点及导航基础设施。默认 supportedLocales 仅声明 en_US；可传入 locale、localizationsDelegates、supportedLocales 扩展实际本地化能力。默认 WidgetsLocalizations 本身支持基础文字方向，不等于提供组件翻译，更不包含 Material/Cupertino localizations。

此入口不提供 SemiScaffold、Material/Cupertino 组件服务、Router 2 或 restoration 配置。页面布局和滚动由宿主使用 SafeArea、SingleChildScrollView 等 widgets 构建。

## macOS hover 注意事项

Flutter macOS 引擎的 `mouseTrackingMode` **默认为 `FlutterMouseTrackingModeInKeyWindow`**：悬浮事件只在窗口处于关键（key）状态时投递，后台窗口悬浮样式不响应，切窗激活后恢复。这是引擎默认值而非组件问题（`FlutterViewController.h` 与 `flutter/flutter#185426`）。如需与普通 macOS 应用一致的后台悬浮行为，在 runner 中设置：

```swift
// macos/Runner/MainFlutterWindow.swift
flutterViewController.mouseTrackingMode = .always
```

该模式也使 enter/exit 在焦点切换时保持稳定，避免指针 add/remove 状态与按下/松开事件错位。example 的 macOS runner 已作此设置。
