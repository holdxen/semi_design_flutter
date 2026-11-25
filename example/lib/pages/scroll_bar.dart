import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

/// SemiScrollBar 示例页。
///
/// 官方只有 `.semi-light-scrollbar` 工具类，没有独立组件；这里展示 Flutter
/// 移植版在亮色、暗色主题下的默认样式与常用配置。
class ScrollBarPage extends StatefulWidget {
  const ScrollBarPage({super.key});

  @override
  State<ScrollBarPage> createState() => _ScrollBarPageState();
}

class _ScrollBarPageState extends State<ScrollBarPage> {
  final ScrollController _vertical = ScrollController();
  final ScrollController _horizontal = ScrollController();
  final ScrollController _custom = ScrollController();

  bool _alwaysVisible = true;

  @override
  void dispose() {
    _vertical.dispose();
    _horizontal.dispose();
    _custom.dispose();
    super.dispose();
  }

  Widget _caption(String text) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: SemiText(
      text,
      type: SemiTextType.tertiary,
      size: SemiTextSize.small,
    ),
  );

  Widget _panel({required Widget child, double height = 220}) {
    final colors = SemiTheme.of(context).colors;
    return SizedBox(
      width: 360,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.colorFill0,
          border: Border.all(color: colors.colorBorder),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(padding: const EdgeInsets.all(4), child: child),
      ),
    );
  }

  Widget _demo({
    required Widget child,
    required String caption,
    double height = 220,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _panel(height: height, child: child),
      _caption(caption),
    ],
  );

  Widget _verticalItem(BuildContext context, int index) {
    final colors = SemiTheme.of(context).colors;
    return Container(
      height: 40,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.colorBorder)),
      ),
      child: SemiText('列表项 ${index + 1}'),
    );
  }

  Widget _horizontalItem(BuildContext context) {
    final colors = SemiTheme.of(context).colors;
    return Container(
      width: 112,
      margin: const EdgeInsets.only(right: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.colorBg2,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const SemiText('卡片'),
    );
  }

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
      const SizedBox(height: 40),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final colors = SemiTheme.of(context).colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SemiText(
            '移植官方 .semi-light-scrollbar：8px 滑块、6px 圆角、透明轨道，'
            '悬停内容显示，滑块悬停时颜色加深，亮色与暗色主题自动适配。',
          ),
          const SizedBox(height: 32),
          _section('垂直滚动', [
            _demo(
              caption: '悬停内容或滚动时淡入，离开后 1s 淡出',
              child: SemiScrollBar(
                controller: _vertical,
                child: ListView.builder(
                  controller: _vertical,
                  itemCount: 20,
                  itemBuilder: (context, index) =>
                      _verticalItem(context, index),
                ),
              ),
            ),
          ]),
          _section('横向滚动', [
            _demo(
              height: 120,
              caption: '横向滚动条自动定位到底部',
              child: SemiScrollBar(
                controller: _horizontal,
                child: ListView.builder(
                  controller: _horizontal,
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemBuilder: (context, index) => _horizontalItem(context),
                ),
              ),
            ),
          ]),
          _section('常显与自定义样式', [
            Row(
              children: [
                const SemiText('常显滑块'),
                const SizedBox(width: 8),
                SemiSwitch(
                  checked: _alwaysVisible,
                  onChanged: (value) => setState(() => _alwaysVisible = value),
                ),
                const SizedBox(width: 24),
                const SemiText(
                  '自定义：12px 厚度 / 主色滑块',
                  type: SemiTextType.tertiary,
                  size: SemiTextSize.small,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _demo(
              caption: 'thumbVisibility 常显；thickness 与滑块颜色均可覆盖',
              child: SemiScrollBar(
                controller: _custom,
                thumbVisibility: _alwaysVisible,
                thickness: 12,
                thumbColor: colors.colorPrimary,
                thumbHoverColor: colors.colorPrimaryHover,
                child: ListView.builder(
                  controller: _custom,
                  itemCount: 12,
                  itemBuilder: (context, index) =>
                      _verticalItem(context, index),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
