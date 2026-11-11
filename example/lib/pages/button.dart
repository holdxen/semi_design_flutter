import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class ButtonPage extends StatefulWidget {
  const ButtonPage({super.key});

  @override
  State<ButtonPage> createState() => _ButtonPageState();
}

class _ButtonPageState extends State<ButtonPage> {
  bool _loading = false;
  String _status = '点击按钮查看交互。';

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  Widget _row(List<Widget> children) => Wrap(
    spacing: 12,
    runSpacing: 12,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: children,
  );

  SemiButton _btn(
    String label, {
    SemiButtonType type = SemiButtonType.primary,
    SemiButtonVariant variant = SemiButtonVariant.light,
    SemiButtonSize size = SemiButtonSize.normal,
    bool? loading,
    bool disabled = false,
    bool block = false,
    Widget? icon,
    SemiButtonIconPosition iconPosition = SemiButtonIconPosition.left,
    bool colorful = false,
  }) => SemiButton(
    label,
    type: type,
    variant: variant,
    size: size,
    loading: loading ?? _loading,
    disabled: disabled,
    block: block,
    icon: icon,
    iconPosition: iconPosition,
    colorful: colorful,
    onPressed: () => setState(() => _status = '点击了「$label」。'),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('类型', [
            _row([
              _btn('主要', loading: false),
              _btn('次要', type: SemiButtonType.secondary, loading: false),
              _btn('辅助', type: SemiButtonType.tertiary, loading: false),
              _btn('警告', type: SemiButtonType.warning, loading: false),
              _btn('危险', type: SemiButtonType.danger, loading: false),
            ]),
          ]),
          const SizedBox(height: 40),
          _section('变体', [
            const SemiText(
              'light（默认）/ solid / outline / borderless。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            for (final variant in SemiButtonVariant.values) ...[
              SemiText(variant.name, type: SemiTextType.secondary),
              const SizedBox(height: 8),
              _row([
                _btn('主要', variant: variant, loading: false),
                _btn(
                  '警告',
                  type: SemiButtonType.warning,
                  variant: variant,
                  loading: false,
                ),
                _btn(
                  '危险',
                  type: SemiButtonType.danger,
                  variant: variant,
                  loading: false,
                ),
              ]),
              const SizedBox(height: 16),
            ],
          ]),
          const SizedBox(height: 40),
          _section('尺寸与块级', [
            _row([
              _btn('small', size: SemiButtonSize.small, loading: false),
              _btn('normal', size: SemiButtonSize.normal, loading: false),
              _btn('large', size: SemiButtonSize.large, loading: false),
            ]),
            const SizedBox(height: 12),
            _btn('block 占满整行', block: true, loading: false),
          ]),
          const SizedBox(height: 40),
          _section('图标', [
            _row([
              _btn(
                '左侧图标',
                icon: const SemiIcon(SemiIcons.plus),
                loading: false,
              ),
              _btn(
                '右侧图标',
                icon: const SemiIcon(SemiIcons.chevronRight),
                iconPosition: SemiButtonIconPosition.right,
                loading: false,
              ),
              SemiButton(
                '仅图标',
                icon: const SemiIcon(SemiIcons.setting),
                loading: false,
                onPressed: () => setState(() => _status = '点击了「仅图标」。'),
              ),
            ]),
          ]),
          const SizedBox(height: 40),
          _section('状态', [
            SemiText(_status, key: const ValueKey('button-status')),
            const SizedBox(height: 12),
            _row([
              _action(
                'toggle-loading',
                _loading ? '停止 loading' : '开启 loading',
                () => setState(() => _loading = !_loading),
              ),
              _btn('可点击'),
              _btn('禁用', disabled: true),
              _btn('禁用+loading', disabled: true),
              _btn('带图标', icon: const SemiIcon(SemiIcons.star)),
            ]),
          ]),
          const SizedBox(height: 40),
          _section('AI 彩色', [
            const SemiText(
              'colorful 支持 primary/tertiary，渐变背景或渐变文字。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            _row([
              for (final variant in SemiButtonVariant.values)
                _btn(
                  variant.name,
                  type: SemiButtonType.primary,
                  variant: variant,
                  colorful: true,
                  loading: false,
                ),
            ]),
            const SizedBox(height: 12),
            _row([
              for (final variant in SemiButtonVariant.values)
                _btn(
                  variant.name,
                  type: SemiButtonType.tertiary,
                  variant: variant,
                  colorful: true,
                  loading: false,
                ),
            ]),
          ]),
          const SizedBox(height: 40),
          _section('按钮组合', [
            SemiButtonGroup(
              size: SemiButtonSize.normal,
              children: [
                SemiButton(
                  '左',
                  onPressed: () => setState(() => _status = '点击了组合「左」。'),
                ),
                SemiButton(
                  '中',
                  onPressed: () => setState(() => _status = '点击了组合「中」。'),
                ),
                SemiButton(
                  '右',
                  onPressed: () => setState(() => _status = '点击了组合「右」。'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SemiButtonGroup(
              type: SemiButtonType.danger,
              variant: SemiButtonVariant.outline,
              children: [
                SemiButton('删除', onPressed: () {}),
                SemiButton('归档', onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),
            const SemiText('分裂按钮', type: SemiTextType.secondary),
            const SizedBox(height: 12),
            SemiSplitButtonGroup(
              semanticsLabel: '分裂按钮',
              children: [
                SemiButton(
                  '主要操作',
                  onPressed: () => setState(() => _status = '点击了分裂按钮「主要操作」。'),
                ),
                SemiButton(
                  '',
                  icon: const SemiIcon(SemiIcons.treeTriangleDown),
                  onPressed: () => setState(() => _status = '点击了分裂按钮「更多」。'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SemiSplitButtonGroup(
              children: [
                SemiButton(
                  '保存',
                  variant: SemiButtonVariant.solid,
                  onPressed: () => setState(() => _status = '点击了分裂按钮「保存」。'),
                ),
                SemiButton(
                  '',
                  variant: SemiButtonVariant.solid,
                  icon: const SemiIcon(SemiIcons.treeTriangleDown),
                  onPressed: () => setState(() => _status = '点击了分裂按钮「保存选项」。'),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('局部主题', [
            const SemiText(
              '圆角 12、primary solid 背景紫色。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            SemiButtonTheme(
              data: const SemiButtonThemeData(
                radiusButton: 12,
                colorButtonPrimaryBgDefault: Color(0xff7b61ff),
                colorButtonPrimaryBgHover: Color(0xff927dff),
                colorButtonPrimaryBgActive: Color(0xff6345e0),
              ),
              child: _row([
                _btn('主题按钮', loading: false),
                _btn(
                  '主题按钮 solid',
                  variant: SemiButtonVariant.solid,
                  loading: false,
                ),
              ]),
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
