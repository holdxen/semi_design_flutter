import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class UserGuidePage extends StatefulWidget {
  const UserGuidePage({super.key});

  @override
  State<UserGuidePage> createState() => _UserGuidePageState();
}

class _UserGuidePageState extends State<UserGuidePage> {
  bool _popupVisible = false;
  bool _primaryVisible = false;
  bool _modalVisible = false;

  void _open(ValueChanged<bool> set) => setState(() => set(true));

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基础用法（popup）', [
            SemiButton(
              '显示引导',
              type: SemiButtonType.primary,
              variant: SemiButtonVariant.solid,
              onPressed: () => _open((v) => _popupVisible = v),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const SemiUserGuideTarget(
                  id: 'step-1',
                  child: _TargetBox(label: '第一步目标'),
                ),
                const SizedBox(width: 24),
                const SemiUserGuideTarget(
                  id: 'step-2',
                  child: _TargetBox(label: '第二步目标'),
                ),
              ],
            ),
            SemiUserGuide(
              visible: _popupVisible,
              steps: const [
                SemiUserGuideStep(
                  target: 'step-1',
                  title: '第一步',
                  description: '这是第一步的说明',
                  position: SemiTooltipPosition.bottom,
                ),
                SemiUserGuideStep(
                  target: 'step-2',
                  title: '第二步',
                  description: '这是第二步的说明',
                  position: SemiTooltipPosition.right,
                ),
              ],
              onChange: (current) {},
              onSkip: () => setState(() => _popupVisible = false),
              onFinish: () => setState(() => _popupVisible = false),
            ),
          ]),
          _section('primary 主题', [
            SemiButton(
              '显示引导（primary）',
              type: SemiButtonType.primary,
              variant: SemiButtonVariant.solid,
              onPressed: () => _open((v) => _primaryVisible = v),
            ),
            const SizedBox(height: 16),
            const SemiUserGuideTarget(
              id: 'primary-1',
              child: _TargetBox(label: 'primary 目标'),
            ),
            SemiUserGuide(
              visible: _primaryVisible,
              theme: SemiUserGuideThemeMode.primary,
              steps: const [
                SemiUserGuideStep(
                  target: 'primary-1',
                  title: 'primary 主题',
                  description: '卡片主色 + 按钮内联覆色（fill-2 / #FFF）',
                ),
              ],
              onSkip: () => setState(() => _primaryVisible = false),
              onFinish: () => setState(() => _primaryVisible = false),
            ),
          ]),
          _section('modal 模式', [
            SemiButton(
              '显示引导（modal）',
              type: SemiButtonType.primary,
              variant: SemiButtonVariant.solid,
              onPressed: () => _open((v) => _modalVisible = v),
            ),
            SemiUserGuide(
              visible: _modalVisible,
              mode: SemiUserGuideMode.modal,
              steps: const [
                SemiUserGuideStep(
                  cover: ColoredBox(
                    color: Color(0xFFE8F3FF),
                    child: Center(child: Text('封面 600×300')),
                  ),
                  title: '弹窗式引导',
                  description: 'cover + 指示点 + 正文 + 按钮行',
                ),
                SemiUserGuideStep(title: '第二页', description: '无 cover 时无指示点'),
              ],
              onSkip: () => setState(() => _modalVisible = false),
              onFinish: () => setState(() => _modalVisible = false),
            ),
          ]),
        ],
      ),
    );
  }
}

class _TargetBox extends StatelessWidget {
  const _TargetBox({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF9FAFB),
      border: Border.all(color: const Color(0xFFE5E6EB)),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(label),
  );
}
