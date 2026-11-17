import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  String _status = '填写并提交；校验/提交/重置事件按发生顺序回显。';
  final List<String> _events = [];

  void _push(String event) {
    _events.add(event);
    if (_events.length > 6) _events.removeRange(0, _events.length - 6);
    setState(() => _status = _events.join('；'));
  }

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
    final submitController = SemiFormController();
    final validateController = SemiFormController();
    final arrayController = SemiFormController();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SemiText(_status, key: const ValueKey('form-status')),
          const SizedBox(height: 16),
          _section('基本用法', [
            _demo(
              'initValues 初值 + rules 校验 + submitForm/reset（SemiFormController）。',
              SemiForm(
                controller: submitController,
                initValues: const {'name': 'Semi'},
                onSubmit: (values) => _push('onSubmit $values'),
                onSubmitFail: (errors, _) => _push('onSubmitFail $errors'),
                onReset: () => _push('onReset'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SemiFormInput(
                      field: 'name',
                      label: '名称',
                      rules: const [
                        SemiFormFieldRule(required: true, message: '名称必填'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        SemiButton(
                          '提交',
                          onPressed: submitController.submitForm,
                        ),
                        const SizedBox(width: 8),
                        SemiButton(
                          '重置',
                          onPressed: submitController.reset,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ]),
          _section('校验', [
            _demo(
              '自定义 validator（异步）+ stopValidateWithError 首错即止。',
              SemiForm(
                controller: validateController,
                onValueChange: (values, changed) {
                  if (changed.isNotEmpty) _push('onValueChange $changed');
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SemiFormInput(
                      field: 'email',
                      label: '邮箱',
                      stopValidateWithError: true,
                      rules: const [
                        SemiFormFieldRule(required: true, message: '邮箱必填'),
                        SemiFormFieldRule(
                          type: SemiFormFieldRuleType.email,
                          message: '邮箱格式不正确',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SemiFormInput(
                      field: 'async',
                      label: '异步校验',
                      validator: (value, values) async {
                        await Future<void>.delayed(
                          const Duration(milliseconds: 300),
                        );
                        return value == 'ok' ? '' : '试试输入 ok';
                      },
                    ),
                  ],
                ),
              ),
            ),
          ]),
          _section('布局与状态', [
            _demo(
              'labelPosition left（labelWidth）+ disabled 级联 + 便捷包装。',
              const SemiForm(
                labelPosition: SemiFormLabelPosition.left,
                labelWidth: 80,
                disabled: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SemiFormInput(field: 'a', label: '禁用项', initValue: '只读'),
                    SemiFormSwitch(field: 'b', label: '开关'),
                  ],
                ),
              ),
            ),
            _demo(
              'Section 分组 + helpText/extraText。',
              SemiForm(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SemiFormSection(
                      title: '分组标题',
                      child: SemiFormInput(
                        field: 'c',
                        label: '带帮助',
                        helpText: const Text('这是帮助文案'),
                        extraText: const Text('这是额外提示'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
          _section('动态表单', [
            _demo(
              'SemiArrayField——add/addWithInitValue/remove（updateKey 重挂载）。',
              SemiForm(
                controller: arrayController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SemiArrayField(
                      field: 'people',
                      initValue: const [
                        {'name': '张三'},
                      ],
                      builder: (context, api) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final item in api.items)
                            Row(
                              children: [
                                Expanded(
                                  child: SemiFormInput(
                                    field: '${item.field}.name',
                                    label: '姓名',
                                  ),
                                ),
                                SemiButton(
                                  '删除',
                                  onPressed: item.remove,
                                ),
                              ],
                            ),
                          SemiButton(
                            '添加一行',
                            onPressed: () => api.addWithInitValue({'name': ''}),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SemiButton(
                      '读取 people',
                      onPressed: () => _push(
                        'people ${arrayController.getValue('people')}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
