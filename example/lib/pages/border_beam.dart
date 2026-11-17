import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class BorderBeamPage extends StatefulWidget {
  const BorderBeamPage({super.key});

  @override
  State<BorderBeamPage> createState() => _BorderBeamPageState();
}

class _BorderBeamPageState extends State<BorderBeamPage> {
  int _count = 1;
  bool _running = true;

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  Widget _beamCard({
    required Widget child,
    BorderRadius radius = const BorderRadius.all(Radius.circular(12)),
    SemiBorderBeamColor? color,
    List<SemiBorderBeamItem>? items,
    double lineWidth = 2,
    double size = 100,
    double outset = 0,
  }) => SizedBox(
    width: 300,
    child: TickerMode(
      enabled: _running,
      child: SemiBorderBeam(
        key: const ValueKey('border-beam-widget'),
        color: color,
        count: _count,
        duration: const Duration(seconds: 4),
        items: items,
        lineWidth: lineWidth,
        size: size,
        outset: outset,
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xfff7f8fa),
            border: Border.all(color: const Color(0xffd9dfe8)),
            borderRadius: radius,
          ),
          child: Padding(padding: const EdgeInsets.all(20), child: child),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final primary = SemiTheme.of(context).colors.colorPrimary;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SemiButton(
                '减少 Beam',
                key: const ValueKey('border-beam-count-down'),
                onPressed: _count > 1 ? () => setState(() => _count--) : null,
              ),
              const SizedBox(width: 8),
              SemiButton(
                '增加 Beam',
                key: const ValueKey('border-beam-count-up'),
                onPressed: () => setState(() => _count++),
              ),
              const SizedBox(width: 12),
              SemiButton(
                _running ? '暂停动画' : '开启动画',
                key: const ValueKey('border-beam-toggle'),
                onPressed: () => setState(() => _running = !_running),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _section('基础用法', [
            _beamCard(
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemiTitle('BorderBeam', heading: 4),
                  SizedBox(height: 8),
                  SemiText('Beam 沿圆角边框持续移动。'),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 32),
          _section('自定义颜色与尺寸', [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _beamCard(
                  lineWidth: 3,
                  size: 150,
                  color: SemiBorderBeamColor.solid(const Color(0xff7b61ff)),
                  child: const SemiText('紫色 Beam'),
                ),
                _beamCard(
                  lineWidth: 2,
                  size: 80,
                  color: SemiBorderBeamColor.gradient([
                    SemiBorderBeamGradientStop(0, Color(0xff00b96b)),
                    SemiBorderBeamGradientStop(45, Color(0xff1677ff)),
                    SemiBorderBeamGradientStop(100, Color(0xffff4d4f)),
                  ]),
                  child: const SemiText('渐变 Beam'),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 32),
          _section('items 局部覆盖', [
            _beamCard(
              items: [
                SemiBorderBeamItem(color: SemiBorderBeamColor.solid(primary)),
                const SemiBorderBeamItem(
                  color: SemiBorderBeamColor.solid(Color(0xfff5222d)),
                  lineWidth: 4,
                  size: 140,
                ),
              ],
              child: const SemiText('第二条 Beam 使用独立配置'),
            ),
          ]),
          const SizedBox(height: 32),
          _section('非均匀圆角与 outset', [
            _beamCard(
              radius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
              outset: 2,
              child: const SemiText('outset: 2，圆角分别设置'),
            ),
          ]),
        ],
      ),
    );
  }
}
