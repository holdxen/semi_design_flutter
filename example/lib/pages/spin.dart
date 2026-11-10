import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class SpinPage extends StatefulWidget {
  const SpinPage({super.key});

  @override
  State<SpinPage> createState() => _SpinPageState();
}

class _SpinPageState extends State<SpinPage> {
  bool _spinning = true;
  bool _delayed = false;
  int _clicks = 0;

  @override
  Widget build(BuildContext context) {
    final colors = SemiTheme.of(context).colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SemiTitle('尺寸', heading: 3),
          const SizedBox(height: 16),
          Wrap(
            spacing: 32,
            runSpacing: 24,
            children: [
              for (final size in SemiSpinSize.values)
                SizedBox(
                  width: 64,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 48,
                        child: Center(child: SemiSpin(size: size)),
                      ),
                      SemiText(size.name),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 40),
          const SemiTitle('提示文案', heading: 3),
          const SizedBox(
            height: 112,
            child: Center(child: SemiSpin(tip: Text('正在加载…'))),
          ),
          const SizedBox(height: 40),
          const SemiTitle('包裹内容', heading: 3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              SemiText(
                _spinning ? '停止加载' : '恢复加载',
                key: const ValueKey('toggle-loading'),
                link: SemiTextLink(
                  onTap: () => setState(() => _spinning = !_spinning),
                ),
              ),
              SemiText(
                _delayed ? '关闭延迟（300ms）' : '启用延迟（300ms）',
                key: const ValueKey('toggle-delay'),
                link: SemiTextLink(
                  onTap: () => setState(() => _delayed = !_delayed),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const SemiText(
            '开启延迟后，停止再恢复加载，等待 300ms 显示。',
            type: SemiTextType.secondary,
          ),
          const SizedBox(height: 16),
          SemiSpin(
            key: const ValueKey('content-spin'),
            spinning: _spinning,
            delay: _delayed ? const Duration(milliseconds: 300) : Duration.zero,
            tip: const Text('加载中…'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: colors.colorFill0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SemiText('内容区域'),
                  const SizedBox(height: 12),
                  const SemiText('加载时遮挡点击，停止后可操作内容。'),
                  const SizedBox(height: 12),
                  SemiText(
                    '点击次数：$_clicks',
                    key: const ValueKey('content-action'),
                    link: SemiTextLink(onTap: () => setState(() => _clicks++)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          const SemiTitle('自定义指示器', heading: 3),
          const SizedBox(
            height: 80,
            child: Center(
              child: SemiSpin(
                key: ValueKey('custom-spin'),
                indicator: SemiIcon(SemiIcons.refresh),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const SemiTitle('局部主题', heading: 3),
          const SemiText('主题色与旋转时长（1200ms）', type: SemiTextType.secondary),
          SemiSpinTheme(
            data: SemiSpinThemeData(
              color: colors.colorSuccess,
              rotationDuration: const Duration(milliseconds: 1200),
            ),
            child: const SizedBox(
              height: 80,
              child: Center(child: SemiSpin(key: ValueKey('theme-spin'))),
            ),
          ),
        ],
      ),
    );
  }
}
