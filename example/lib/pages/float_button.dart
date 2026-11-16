import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class FloatButtonPage extends StatefulWidget {
  const FloatButtonPage({super.key});

  @override
  State<FloatButtonPage> createState() => _FloatButtonPageState();
}

class _FloatButtonPageState extends State<FloatButtonPage> {
  String _status = '点击右下角悬浮按钮或按钮组子项试试。';

  // 事件回传顺序记录（组派发：子项回调先于组回调）。
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

  /// 演示区限高 220（FloatButton/Group 是 PositionedDirectional——需 Stack
  /// 直接子节点位，固定在演示盒右下角，见 docs 差异清单）。
  Widget _demo(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiText(label),
      const SizedBox(height: 6),
      SizedBox(height: 220, child: child),
      const SizedBox(height: 12),
    ],
  );

  /// 演示盒：Stack + 背景内容 + 悬浮件。[key] 供 example/test 度量锚点。
  Widget _stack({required Key key, required Widget float}) => Stack(
    key: key,
    children: [
      const Positioned.fill(
        child: Align(
          alignment: Alignment.topLeft,
          child: SemiText('页面内容区（悬浮件固定右下角）'),
        ),
      ),
      float,
    ],
  );

  /// 逐件垂直错开（上游 demo 以 style.bottom 错位——本移植用主题间距补丁
  /// 同口径错开）。
  Widget _offset({required double bottom, required Widget child}) =>
      SemiFloatButtonTheme(
        data: SemiFloatButtonThemeData(spacingFloatButtonBottom: bottom),
        child: child,
      );

  SemiFloatButtonGroupItem _item(
    String value,
    String label,
    SemiIconData icon,
  ) => SemiFloatButtonGroupItem(
    value: value,
    icon: SemiIcon(icon),
    content: label,
    onClick: (event) => _push('item $value'),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SemiText(_status, key: const ValueKey('floatbutton-status')),
          const SizedBox(height: 16),
          _section('基本用法', [
            _demo(
              '缺省 round / defaultSize（32）；点击回传 onClick。',
              _stack(
                key: const ValueKey('floatbutton-basic'),
                float: SemiFloatButton(
                  icon: const SemiIcon(SemiIcons.edit),
                  onClick: () => _push('onClick 基本用法'),
                ),
              ),
            ),
          ]),
          _section('尺寸与形状', [
            _demo(
              'small(24) / defaultSize(32) / large(40)；方形 square（8 圆角）'
              '与圆形 round 错开排布。',
              _stack(
                key: const ValueKey('floatbutton-size-shape'),
                float: Stack(
                  children: [
                    _offset(
                      bottom: 160,
                      child: SemiFloatButton(
                        size: SemiFloatButtonSize.small,
                        icon: const SemiIcon(SemiIcons.edit),
                        onClick: () => _push('onClick small'),
                      ),
                    ),
                    _offset(
                      bottom: 100,
                      child: SemiFloatButton(
                        size: SemiFloatButtonSize.large,
                        shape: SemiFloatButtonShape.square,
                        icon: const SemiIcon(SemiIcons.edit),
                        onClick: () => _push('onClick large square'),
                      ),
                    ),
                    SemiFloatButton(
                      icon: const SemiIcon(SemiIcons.edit),
                      onClick: () => _push('onClick default round'),
                    ),
                  ],
                ),
              ),
            ),
          ]),
          _section('多彩与徽章', [
            _demo(
              'colorful 多彩（ai-general 渐变）；badge 骑圆角（dot / '
              'count + overflowCount / 自定义文本）。',
              _stack(
                key: const ValueKey('floatbutton-colorful-badge'),
                float: Stack(
                  children: [
                    _offset(
                      bottom: 160,
                      child: SemiFloatButton(
                        badge: const SemiFloatButtonBadge(
                          count: 1000,
                          overflowCount: 999,
                        ),
                        icon: const SemiIcon(SemiIcons.edit),
                        onClick: () => _push('onClick badge count'),
                      ),
                    ),
                    _offset(
                      bottom: 100,
                      child: SemiFloatButton(
                        badge: const SemiFloatButtonBadge(
                          count: 'VIP',
                          type: SemiBadgeType.danger,
                        ),
                        size: SemiFloatButtonSize.large,
                        colorful: true,
                        icon: const SemiIcon(SemiIcons.edit),
                        onClick: () => _push('onClick colorful badge'),
                      ),
                    ),
                    SemiFloatButton(
                      badge: const SemiFloatButtonBadge(dot: true),
                      colorful: true,
                      icon: const SemiIcon(SemiIcons.edit),
                      onClick: () => _push('onClick colorful dot'),
                    ),
                  ],
                ),
              ),
            ),
          ]),
          _section('悬浮按钮组', [
            _demo(
              'items 子项（icon + content）；子项回调先于组回调，事件日志记录'
              '派发顺序。',
              _stack(
                key: const ValueKey('floatbutton-group'),
                float: SemiFloatButtonGroup(
                  onClick:
                      (value, event) =>
                          _push('group onClick value=$value'),
                  items: [
                    _item('editor', '编辑', SemiIcons.edit),
                    _item('search', '搜索', SemiIcons.search),
                    SemiFloatButtonGroupItem(
                      value: 'help',
                      icon: const SemiIcon(SemiIcons.helpCircle),
                      content: '帮助',
                      badge: const SemiFloatButtonBadge(count: 3),
                      onClick: (event) {
                        _push('item help');
                        // stopPropagation 断组回调（itemProps.test.jsx 口径）。
                        event.stopPropagation();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ]),
          _section('禁用', [
            _demo(
              'disabled 断回调（悬浮按钮另出禁用配色 + not-allowed 光标；'
              '★组禁用无视觉差 quirk）。',
              _stack(
                key: const ValueKey('floatbutton-disabled'),
                float: Stack(
                  children: [
                    _offset(
                      bottom: 100,
                      child: SemiFloatButton(
                        disabled: true,
                        icon: const SemiIcon(SemiIcons.edit),
                        onClick: () => _push('onClick 禁用不应达'),
                      ),
                    ),
                    SemiFloatButtonGroup(
                      disabled: true,
                      onClick:
                          (value, event) => _push('group 禁用不应达'),
                      items: [
                        _item('editor', '编辑', SemiIcons.edit),
                        _item('search', '搜索', SemiIcons.search),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ]),
          _section('RTL', [
            _demo(
              'Directionality.rtl——PositionedDirectional end 自动翻边，'
              'badge translate 翻 -0.5。',
              Directionality(
                textDirection: TextDirection.rtl,
                child: _stack(
                  key: const ValueKey('floatbutton-rtl'),
                  float: SemiFloatButton(
                    badge: const SemiFloatButtonBadge(dot: true),
                    icon: const SemiIcon(SemiIcons.edit),
                    onClick: () => _push('onClick RTL'),
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
