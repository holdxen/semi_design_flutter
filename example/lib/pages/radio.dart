import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({super.key});

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  String _status = '点击选项查看 onChange 事件。';

  // 高级模式（可取消）。
  bool _advanced = true;

  // 单选组合（受控）。
  Object? _groupValue = 1;

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  Widget _demo(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiText(label),
      const SizedBox(height: 6),
      child,
      const SizedBox(height: 12),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基本用法', [
            SemiText(_status, key: const ValueKey('radio-status')),
            const SizedBox(height: 12),
            SemiRadio(
              const Text('单选框'),
              key: const ValueKey('radio-basic'),
              value: 'basic',
              defaultChecked: true,
              onChanged: (e) =>
                  setState(() => _status = '基本用法：checked=${e.checked}'),
            ),
          ]),
          const SizedBox(height: 40),
          _section('带辅助文本', [
            SemiRadio(
              const Text('Semi Design'),
              key: const ValueKey('radio-extra'),
              extra: const Text('由抖音前端团队与 UED 团队共同设计开发并维护的设计系统'),
            ),
          ]),
          const SizedBox(height: 40),
          _section('禁用', [
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: const [
                SemiRadio(Text('未选中禁用'), disabled: true),
                SemiRadio(Text('选中禁用'), defaultChecked: true, disabled: true),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('高级模式', [
            _demo(
              'mode=advanced：点击已选项可取消选择',
              SemiRadio(
                const Text('允许取消选择'),
                key: const ValueKey('radio-advanced'),
                mode: SemiRadioMode.advanced,
                checked: _advanced,
                onChanged: (e) => setState(() {
                  _advanced = e.checked;
                  _status = '高级模式：checked=${e.checked}';
                }),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('单选组合', [
            _demo(
              '受控 RadioGroup（当前值：$_groupValue）',
              SemiRadioGroup(
                key: const ValueKey('radio-group'),
                value: _groupValue,
                onChanged: (e) => setState(() {
                  _groupValue = e.value;
                  _status = '组合选中：${e.value}';
                }),
                children: const [
                  SemiRadio(Text('即时推送'), value: 1),
                  SemiRadio(Text('定时推送'), value: 2),
                  SemiRadio(Text('动态推送'), value: 3),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('垂直排列', [
            SemiRadioGroup(
              key: const ValueKey('radio-vertical'),
              direction: SemiRadioDirection.vertical,
              defaultValue: 'a',
              children: const [
                SemiRadio(Text('选项 A'), value: 'a'),
                SemiRadio(Text('选项 B'), value: 'b'),
                SemiRadio(Text('选项 C'), value: 'c'),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('按钮样式', [
            _demo(
              'small',
              SemiRadioGroup(
                key: const ValueKey('radio-button-small'),
                type: SemiRadioType.button,
                buttonSize: SemiRadioButtonSize.small,
                defaultValue: 1,
                children: const [
                  SemiRadio(Text('即时推送'), value: 1),
                  SemiRadio(Text('定时推送'), value: 2),
                  SemiRadio(Text('动态推送'), value: 3),
                ],
              ),
            ),
            _demo(
              'middle',
              SemiRadioGroup(
                key: const ValueKey('radio-button-middle'),
                type: SemiRadioType.button,
                buttonSize: SemiRadioButtonSize.middle,
                defaultValue: 1,
                children: const [
                  SemiRadio(Text('即时推送'), value: 1),
                  SemiRadio(Text('定时推送'), value: 2),
                  SemiRadio(Text('动态推送'), value: 3),
                ],
              ),
            ),
            _demo(
              'large',
              SemiRadioGroup(
                key: const ValueKey('radio-button-large'),
                type: SemiRadioType.button,
                buttonSize: SemiRadioButtonSize.large,
                defaultValue: 1,
                children: const [
                  SemiRadio(Text('即时推送'), value: 1),
                  SemiRadio(Text('定时推送'), value: 2),
                  SemiRadio(Text('动态推送'), value: 3),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('卡片样式', [
            SemiRadioGroup(
              key: const ValueKey('radio-card'),
              type: SemiRadioType.card,
              direction: SemiRadioDirection.vertical,
              defaultValue: 2,
              children: const [
                SemiRadio(
                  Text('单选框标题'),
                  value: 1,
                  disabled: true,
                  extra: Text('Semi Design 是由抖音前端团队与 UED 团队共同设计开发并维护的设计系统'),
                ),
                SemiRadio(
                  Text('单选框标题'),
                  value: 2,
                  extra: Text('Semi Design 是由抖音前端团队与 UED 团队共同设计开发并维护的设计系统'),
                ),
                SemiRadio(
                  Text('单选框标题'),
                  value: 3,
                  extra: Text('Semi Design 是由抖音前端团队与 UED 团队共同设计开发并维护的设计系统'),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('无 radio 的纯卡片样式', [
            SemiRadioGroup(
              key: const ValueKey('radio-pure-card'),
              type: SemiRadioType.pureCard,
              direction: SemiRadioDirection.vertical,
              defaultValue: 1,
              children: const [
                SemiRadio(Text('Semi Design'), value: 1),
                SemiRadio(Text('Semi Motion'), value: 2),
                SemiRadio(Text('Semi Icons'), value: 3),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('配置 options', [
            SemiRadioGroup(
              key: const ValueKey('radio-options'),
              defaultValue: 'B',
              options: const [
                SemiRadioOption(label: Text('选项 A'), value: 'A'),
                SemiRadioOption(label: Text('选项 B'), value: 'B'),
                SemiRadioOption(
                  label: Text('选项 C（禁用）'),
                  value: 'C',
                  disabled: true,
                ),
              ],
            ),
          ]),
        ],
      ),
    );
  }
}
