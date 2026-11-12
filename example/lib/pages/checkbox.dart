import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class CheckboxPage extends StatefulWidget {
  const CheckboxPage({super.key});

  @override
  State<CheckboxPage> createState() => _CheckboxPageState();
}

class _CheckboxPageState extends State<CheckboxPage> {
  bool _controlled = true;
  List<Object> _selected = ['a', 'b'];
  final List<Object> _allOptions = ['a', 'b', 'c'];
  String _status = '点击复选框查看事件。';
  bool _blocked = false;

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
    final allChecked = _selected.length == _allOptions.length;
    final noneChecked = _selected.isEmpty;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基础用法', [
            const SemiCheckbox(label: '未选中'),
            const SemiCheckbox(label: '已选中', checked: true),
            const SemiCheckbox(
              label: '半选（indeterminate）',
              checked: false,
              indeterminate: true,
            ),
            const SemiCheckbox(label: '禁用', disabled: true),
            const SemiCheckbox(label: '禁用选中', checked: true, disabled: true),
          ]),
          const SizedBox(height: 40),
          _section('卡片变体', [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: const [
                SemiCheckbox(
                  label: 'card 未选',
                  extra: '带副标题的卡片选项',
                  type: SemiCheckboxType.card,
                ),
                SemiCheckbox(
                  label: 'card 选中',
                  extra: '选中态浅主色底',
                  checked: true,
                  type: SemiCheckboxType.card,
                ),
                SemiCheckbox(
                  label: 'pureCard',
                  checked: true,
                  type: SemiCheckboxType.pureCard,
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('受控模式', [
            SemiText(_status, key: const ValueKey('checkbox-status')),
            const SizedBox(height: 12),
            SemiCheckbox(
              key: const ValueKey('controlled-checkbox'),
              label: '受控复选框（父级决定选中）',
              checked: _controlled,
              onChanged: (event) => setState(() {
                _controlled = !_controlled;
                _status = '受控切换为：${_controlled ? "选中" : "未选中"}。';
              }),
            ),
          ]),
          const SizedBox(height: 40),
          _section('分组', [
            const SemiText(
              'Group 不计算全选/半选，下方由父级自行计算。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            SemiCheckbox(
              key: const ValueKey('select-all'),
              label: '全选',
              checked: allChecked,
              indeterminate: !allChecked && !noneChecked,
              onChanged: (_) => setState(() {
                _selected = allChecked ? [] : [..._allOptions];
              }),
            ),
            const SizedBox(height: 8),
            SemiCheckboxGroup(
              key: const ValueKey('option-group'),
              value: _selected,
              onChanged: (values) => setState(() => _selected = values),
              options: const [
                SemiCheckboxOption(label: '选项 A', value: 'a'),
                SemiCheckboxOption(label: '选项 B', value: 'b'),
                SemiCheckboxOption(label: '选项 C', value: 'c', extra: '带说明的选项'),
              ],
            ),
            const SizedBox(height: 16),
            const SemiText('水平方向', type: SemiTextType.secondary),
            const SizedBox(height: 8),
            SemiCheckboxGroup(
              key: const ValueKey('horizontal-group'),
              direction: SemiCheckboxDirection.horizontal,
              defaultValue: ['1'],
              onChanged: (values) =>
                  setState(() => _status = '水平组选中：${values.join('、')}。'),
              options: const [
                SemiCheckboxOption(label: '甲', value: '1'),
                SemiCheckboxOption(label: '乙', value: '2'),
                SemiCheckboxOption(label: '丙', value: '3', disabled: true),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('事件与禁用切换', [
            SemiText(
              _blocked ? 'preventDefault 已拦截下一次切换' : '切换已被允许',
              key: const ValueKey('event-status'),
            ),
            const SizedBox(height: 12),
            _action(
              'toggle-block',
              _blocked ? '允许切换' : '拦截下一次切换',
              () => setState(() => _blocked = !_blocked),
            ),
            const SizedBox(height: 12),
            SemiCheckbox(
              key: const ValueKey('event-checkbox'),
              label: '事件拦截演示',
              onChanged: (event) {
                if (_blocked) {
                  event.preventDefault();
                  setState(() => _status = '切换被 preventDefault 拦截。');
                } else {
                  setState(() => _status = '切换已放行。');
                }
              },
            ),
          ]),
          const SizedBox(height: 40),
          _section('局部主题', [
            const SemiText('标签紫色、选中青色、卡片圆角 12。', type: SemiTextType.secondary),
            const SizedBox(height: 12),
            SemiCheckboxTheme(
              data: const SemiCheckboxThemeData(
                colorCheckboxLabelTextDefault: Color(0xff7b61ff),
                colorCheckboxCheckedBgDefault: Color(0xff0aa5a5),
                colorCheckboxCheckedBorderDefault: Color(0xff0aa5a5),
                radiusCheckboxCardType: 12,
              ),
              child: const Row(
                children: [
                  SemiCheckbox(label: '主题复选框', checked: true),
                  SizedBox(width: 16),
                  SemiCheckbox(
                    label: '主题卡片',
                    checked: true,
                    type: SemiCheckboxType.card,
                  ),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _action(String key, String label, VoidCallback onTap) => SemiText(
    label,
    key: ValueKey(key),
    link: SemiTextLink(onTap: onTap),
  );
}
