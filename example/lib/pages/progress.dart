import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  double _percent = 60;
  bool _indeterminate = true;
  bool _gradient = false;

  void _change(double value) =>
      setState(() => _percent = value.clamp(0, 100).toDouble());

  Widget _action(String key, String label, VoidCallback onTap) => SemiText(
    label,
    key: ValueKey(key),
    link: SemiTextLink(onTap: onTap),
  );

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
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
          _section('水平进度', [
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _action(
                  'increase-progress',
                  '增加 10',
                  () => _change(_percent + 10),
                ),
                _action(
                  'decrease-progress',
                  '减少 10',
                  () => _change(_percent - 10),
                ),
                _action('reset-progress', '重置', () => _change(60)),
              ],
            ),
            const SizedBox(height: 16),
            SemiProgress(
              key: const ValueKey('main-progress'),
              percent: _percent,
              showInfo: true,
            ),
            const SizedBox(height: 12),
            SemiProgress(
              key: const ValueKey('formatted-progress'),
              percent: _percent,
              showInfo: true,
              format: (value) => SemiText('完成 ${value.toInt()}'),
            ),
          ]),
          const SizedBox(height: 40),
          _section('尺寸', [
            const SemiText('normal'),
            SemiProgress(percent: _percent),
            const SizedBox(height: 12),
            const SemiText('large'),
            SemiProgress(percent: _percent, size: SemiProgressSize.large),
          ]),
          const SizedBox(height: 40),
          _section('垂直进度', [
            Wrap(
              spacing: 24,
              runSpacing: 16,
              children: [
                for (final size in [
                  SemiProgressSize.normal,
                  SemiProgressSize.large,
                ])
                  SizedBox(
                    width: 88,
                    child: Column(
                      children: [
                        SemiProgress(
                          direction: SemiProgressDirection.vertical,
                          height: 160,
                          size: size,
                          percent: _percent,
                          showInfo: true,
                        ),
                        SemiText(size.name),
                      ],
                    ),
                  ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('环形进度', [
            const SemiText('small 尺寸隐藏进度文字', type: SemiTextType.secondary),
            const SizedBox(height: 12),
            Wrap(
              spacing: 24,
              runSpacing: 16,
              children: [
                for (final size in SemiProgressSize.values)
                  SizedBox(
                    width: 88,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 88,
                          child: Center(
                            child: SemiProgress(
                              type: SemiProgressType.circle,
                              size: size,
                              percent: _percent,
                              showInfo: true,
                            ),
                          ),
                        ),
                        SemiText(size.name),
                      ],
                    ),
                  ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('阈值颜色', [
            _action(
              'toggle-gradient',
              _gradient ? '关闭颜色插值' : '启用颜色插值',
              () => setState(() => _gradient = !_gradient),
            ),
            const SizedBox(height: 12),
            const SemiText(
              '0：危险，50：警告，100：成功。插值按当前百分比计算颜色，不是空间渐变。',
              type: SemiTextType.secondary,
            ),
            SemiProgress(
              key: const ValueKey('threshold-progress'),
              percent: _percent,
              showInfo: true,
              strokeGradient: _gradient,
              stroke: SemiProgressStroke.stops([
                SemiProgressColorStop(0, colors.colorDanger),
                SemiProgressColorStop(50, colors.colorWarning),
                SemiProgressColorStop(100, colors.colorSuccess),
              ]),
            ),
          ]),
          const SizedBox(height: 40),
          _section('不确定进度', [
            _action(
              'toggle-indeterminate',
              _indeterminate ? '暂停动画' : '启用动画',
              () => setState(() => _indeterminate = !_indeterminate),
            ),
            const SizedBox(height: 16),
            SemiProgress(
              key: const ValueKey('indeterminate-line'),
              percent: _percent,
              indeterminate: _indeterminate,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 72,
              height: 72,
              child: SemiProgress(
                key: const ValueKey('indeterminate-circle'),
                type: SemiProgressType.circle,
                percent: _percent,
                indeterminate: _indeterminate,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('局部主题', [
            const SemiText(
              '线高 8，主题主色，过渡时长 500ms',
              type: SemiTextType.secondary,
            ),
            SemiProgressTheme(
              data: SemiProgressThemeData(
                horizontalHeight: 8,
                strokeColor: colors.colorPrimary,
                transitionDuration: const Duration(milliseconds: 500),
              ),
              child: SemiProgress(
                key: const ValueKey('theme-progress'),
                percent: _percent,
                showInfo: true,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
