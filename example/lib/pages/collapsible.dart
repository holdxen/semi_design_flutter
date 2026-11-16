import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class CollapsiblePage extends StatefulWidget {
  const CollapsiblePage({super.key});

  @override
  State<CollapsiblePage> createState() => _CollapsiblePageState();
}

class _CollapsiblePageState extends State<CollapsiblePage> {
  bool _basicOpen = false;
  bool _durationOpen = false;
  double _durationMs = 250;
  bool _motion = true;
  bool _outerOpen = false;
  bool _innerOpen = false;
  bool _previewOpen = false;
  bool _lifeOpen = false;
  bool _fadeOpen = false;
  bool _themeOpen = false;

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  Widget _line(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: SemiText(text),
  );

  List<Widget> get _lines => [
    _line('Semi Design 以内容优先进行设计。'),
    _line('更容易地自定义主题。'),
    _line('适用国际化场景。'),
    _line('效率场景加入人性化关怀。'),
  ];

  Widget _toggle(String key, String label, VoidCallback onPressed) =>
      SemiButton(
        label,
        key: ValueKey(key),
        variant: SemiButtonVariant.borderless,
        onPressed: onPressed,
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基本用法', [
            _toggle(
              'toggle-basic',
              _basicOpen ? '收起' : '展开',
              () => setState(() => _basicOpen = !_basicOpen),
            ),
            const SizedBox(height: 8),
            SemiCollapsible(
              key: const ValueKey('basic-collapsible'),
              isOpen: _basicOpen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _lines,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('自定义动画时间', [
            Wrap(
              spacing: 16,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const SemiText('动画时间（毫秒）：'),
                SizedBox(
                  width: 120,
                  child: SemiInputNumber(
                    key: const ValueKey('duration-input'),
                    value: _durationMs,
                    min: 0,
                    step: 10,
                    onNumberChange: (v) =>
                        setState(() => _durationMs = v.toDouble()),
                  ),
                ),
                _toggle(
                  'toggle-duration',
                  _durationOpen ? '收起' : '展开',
                  () => setState(() => _durationOpen = !_durationOpen),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SemiCollapsible(
              key: const ValueKey('duration-collapsible'),
              isOpen: _durationOpen,
              duration: Duration(milliseconds: _durationMs.round()),
              motion: _motion,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _lines,
              ),
            ),
            const SizedBox(height: 8),
            _toggle(
              'toggle-motion',
              _motion ? '关闭动画（motion: true）' : '开启动画（motion: false）',
              () => setState(() => _motion = !_motion),
            ),
          ]),
          const SizedBox(height: 40),
          _section('嵌套使用', [
            _toggle(
              'toggle-outer',
              _outerOpen ? '收起外层' : '展开外层',
              () => setState(() => _outerOpen = !_outerOpen),
            ),
            const SizedBox(height: 8),
            SemiCollapsible(
              key: const ValueKey('outer-collapsible'),
              isOpen: _outerOpen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const SemiText('Semi Design 的设计原则包括：'),
                      _toggle(
                        'toggle-inner',
                        _innerOpen ? '收起列表' : '展开列表',
                        () => setState(() => _innerOpen = !_innerOpen),
                      ),
                    ],
                  ),
                  SemiCollapsible(
                    key: const ValueKey('inner-collapsible'),
                    isOpen: _innerOpen,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _lines,
                    ),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('自定义折叠高度', [
            const SemiText(
              'collapseHeight: 60 —— 收起态保留 60px 预览。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            Stack(
              children: [
                SemiCollapsible(
                  key: const ValueKey('preview-collapsible'),
                  isOpen: _previewOpen,
                  collapseHeight: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _lines,
                  ),
                ),
                if (!_previewOpen)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _toggle(
                      'show-more',
                      '＋ 展开更多',
                      () => setState(() => _previewOpen = true),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _toggle(
              'toggle-preview',
              _previewOpen ? '收起' : '展开',
              () => setState(() => _previewOpen = !_previewOpen),
            ),
          ]),
          const SizedBox(height: 40),
          _section('生命周期与淡入淡出', [
            const SemiText(
              'keepDOM 收起后保留 State；lazyRender 首次展开才构建；fade 淡入淡出。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            _toggle(
              'toggle-life',
              _lifeOpen ? '收起' : '展开',
              () => setState(() => _lifeOpen = !_lifeOpen),
            ),
            const SizedBox(height: 8),
            SemiCollapsible(
              key: const ValueKey('life-collapsible'),
              isOpen: _lifeOpen,
              keepDOM: true,
              lazyRender: true,
              fade: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _lines,
              ),
            ),
            const SizedBox(height: 8),
            _toggle(
              'toggle-fade',
              _fadeOpen ? '收起（fade）' : '展开（fade）',
              () => setState(() => _fadeOpen = !_fadeOpen),
            ),
            const SizedBox(height: 8),
            SemiCollapsible(
              key: const ValueKey('fade-collapsible'),
              isOpen: _fadeOpen,
              fade: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _lines,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('局部主题', [
            const SemiText(
              '主题动画时长 800ms、透明度曲线 linear。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            SemiCollapsibleTheme(
              data: const SemiCollapsibleThemeData(
                transitionDurationCollapsibleHeight: Duration(
                  milliseconds: 800,
                ),
                transitionFunctionCollapsibleOpacity: Curves.linear,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _toggle(
                    'toggle-theme',
                    _themeOpen ? '收起' : '展开',
                    () => setState(() => _themeOpen = !_themeOpen),
                  ),
                  const SizedBox(height: 8),
                  SemiCollapsible(
                    key: const ValueKey('theme-collapsible'),
                    isOpen: _themeOpen,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _lines,
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
