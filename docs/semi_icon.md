# SemiIcon

```dart
const SemiIcon(SemiIcons.plus);
const SemiIcon(SemiIcons.aiEditLevel2, color: Color(0xff0055ff));
const SemiIcon(SemiIcons.refresh, spin: true, rotate: 30);
const SemiIconTheme(
  data: SemiIconThemeData(size: SemiIconSize.large),
  child: SemiIcon(SemiIcons.plus),
);
```

## 尺寸和颜色

`extraSmall` 8、`small` 12、`normal` 16、`large` 20、`extraLarge` 24；`inherit` 读取最近 DefaultTextStyle.fontSize（缺省 16）。size 参数 null 表示先使用 SemiIconTheme.size，否则 normal。customSize 是正有限数值，优先于枚举尺寸；组件 customSize > 主题 customSize > 组件 size > 主题 size > 16。

颜色优先级是组件 color > 合并后的最近 SemiIconTheme.color > 宿主 DefaultTextStyle.color > SemiTheme.colors.colorText0。框架根 DefaultTextStyle.fallback 不视为宿主颜色，避免暗色主题错误继承默认调试样式。颜色通过 SvgTheme.currentColor 传递，不使用整图 ColorFilter。

SemiText 为前缀提供最终解析后的颜色及字号，warning、disabled、link hover/active 等状态同步；默认图标仍是 16，只有 inherit 跟随文本字号。图标显式 color 不受前缀覆盖。任意 Widget 前缀仍保留原布局并由 SemiText 排除装饰语义。

## 资产与自定义入口

```dart
const SemiIcon.asset('assets/my_icon.svg'); // 当前应用 bundle
const SemiIcon.asset('assets/icon.svg', package: 'another_package');
const SemiIcon.svg('<svg viewBox="0 0 24 24"><path fill="currentColor" d="M0 0h24v24H0z"/></svg>');
```

内置 SemiIconData 是 const 描述符，资产由 semi_design_flutter 包加载，无需消费者重复注册。自定义 asset 必须由所属应用或包在 pubspec 注册；svg 为 SVG 字符串，不是路径。自定义 SVG 的固定 fill/stroke 保持不变，只有 currentColor 接收颜色。三个入口选项一致（package 仅 asset 使用）。图标不是按钮，没有 onTap；交互由调用方按钮承担。

## AI 与上游差异

523 个常规图标不含 lab 或 illustrations。普通资产按上游 build-icon 的去色规则将 fill/stroke 转换为 currentColor，保留 none、url、透明度及裁剪。AI level2 按真实 React JSX 输出，默认紫色 rgb(166,71,255) 与 currentColor；level3 和 AI loading 保留渐变 stop 颜色、顺序及透明度。没有 fill 数组 API，color 只作用于 currentColor，不会把 AI 固定颜色染成单色。

Flutter 使用 normal 对应 React default；枚举名为 lowerCamelCase。catalog 由 manifest 的 name 转 lowerCamelCase（下划线及连字符分词），不是 523 个 Widget 类。rotate 接受有限 double 度数（比 React safe integer 宽），与 spin **相加**，不是 CSS transform 相互覆盖。

## 动画和语义

spin 为 600ms 线性循环，响应 TickerMode 和 MediaQuery.disableAnimations；禁用动画时停止并复位 spin 部分，仍保留 rotate。controller 随 State 释放。

与上游 aria-label=type 一致，内置图标默认暴露 name 标签；semanticsLabel 可覆盖，只生成一个图像语义节点。excludeFromSemantics=true 隐藏标签及图像语义。自定义图标未提供标签时是装饰图标；建议对有含义图标显式设置本地化标签。SemiText 前缀总是装饰性隐藏，避免重复朗读。

SemiIconThemeData 不可变、值相等，copyWith/merge 中 null 表示保留父值。局部主题逐层合并、订阅父级变化；InheritedTheme 支持 capture。无需修改生成的 SemiThemeData。

## 再生成

```sh
python3 -I tool/generate_icons.py --source /absolute/path/to/semi-design --project /absolute/path/to/semi_design_flutter
```

只写 assets/icons、tool/icon_manifest.json 和 const catalog；从 --source 指定的上游仓库读取原始资源，不依赖项目内的原始 SVG 副本。上游许可证保留于 third_party/semi_design/LICENSE。manifest 包含名称、资产路径、SHA256 和颜色/渐变/stroke/clip 元数据。依赖 flutter_svg ^2.3.2，要求 Flutter >=3.41.0；本项目 Dart SDK ^3.13.5 限制保持不变。
