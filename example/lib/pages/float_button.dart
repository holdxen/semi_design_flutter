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

  /// 演示区限高（缺省 220；FloatButton/Group 是 PositionedDirectional——需
  /// Stack 直接子节点位，固定在演示盒右下角，见 docs 差异清单）。
  Widget _demo(String label, Widget child, {double height = 220}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiText(label),
      const SizedBox(height: 6),
      SizedBox(height: height, child: child),
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

  /// 定位错开（上游 demo 以 style.bottom / insetInlineEnd 错位——本移植用主题
  /// 间距补丁同口径错开；end 缺省 24 = 主题缺省）。
  Widget _offset({
    double end = 24,
    required double bottom,
    required Widget child,
  }) => SemiFloatButtonTheme(
    data: SemiFloatButtonThemeData(
      spacingFloatButtonRight: end,
      spacingFloatButtonBottom: bottom,
      spacingFloatButtonGroupRight: end,
      spacingFloatButtonGroupBottom: bottom,
    ),
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

  /// 官方 stories 子项（无 item 回调——GroupNormal/GroupItemClick 口径）。
  SemiFloatButtonGroupItem _gitem(
    String value,
    String label,
    SemiIconData icon, {
    SemiFloatButtonBadge? badge,
  }) => SemiFloatButtonGroupItem(
    value: value,
    icon: SemiIcon(icon),
    content: label,
    badge: badge,
  );

  /// stories `Single`（floatButton.stories.jsx:5-73）列：insetInlineEnd（→
  /// spacingFloatButtonRight）+ 尺寸/徽章组合（图标照上游 IconAIEditLevel1）。
  static const _singleCols =
      <({
        double end,
        SemiFloatButtonSize size,
        SemiIconSize icon,
        SemiFloatButtonBadge? badge,
      })>[
        (end: 24, size: SemiFloatButtonSize.small, icon: SemiIconSize.normal, badge: null),
        (end: 80, size: SemiFloatButtonSize.defaultSize, icon: SemiIconSize.small, badge: null),
        (end: 130, size: SemiFloatButtonSize.large, icon: SemiIconSize.extraLarge, badge: null),
        (end: 200, size: SemiFloatButtonSize.small, icon: SemiIconSize.small, badge: SemiFloatButtonBadge(dot: true)),
        (end: 250, size: SemiFloatButtonSize.defaultSize, icon: SemiIconSize.normal, badge: SemiFloatButtonBadge(dot: true)),
        (end: 300, size: SemiFloatButtonSize.large, icon: SemiIconSize.extraLarge, badge: SemiFloatButtonBadge(dot: true)),
        (end: 370, size: SemiFloatButtonSize.small, icon: SemiIconSize.small, badge: SemiFloatButtonBadge(count: 9)),
        (end: 420, size: SemiFloatButtonSize.defaultSize, icon: SemiIconSize.normal, badge: SemiFloatButtonBadge(count: 'VIP', type: SemiBadgeType.danger)),
        (end: 500, size: SemiFloatButtonSize.large, icon: SemiIconSize.extraLarge, badge: SemiFloatButtonBadge(count: 1000, overflowCount: 999)),
      ];

  /// stories `Single` 行：bottom（→ spacingFloatButtonBottom）+ 视觉组合——
  /// 220 禁用 / 170 colorful 方 / 120 colorful / 70 方 / 24 圆 + onClick
  /// （story 仅底行挂 onClick）；★第 9 列（badge 1000）的 bottom 上游逐字
  /// 上移（bottom9 = 310/240/170/100/24，:65-69）。
  static const _singleRows =
      <({
        double bottom,
        double bottom9,
        bool disabled,
        bool colorful,
        SemiFloatButtonShape shape,
        bool clickable,
      })>[
        (bottom: 220, bottom9: 310, disabled: true, colorful: false, shape: SemiFloatButtonShape.round, clickable: false),
        (bottom: 170, bottom9: 240, disabled: false, colorful: true, shape: SemiFloatButtonShape.square, clickable: false),
        (bottom: 120, bottom9: 170, disabled: false, colorful: true, shape: SemiFloatButtonShape.round, clickable: false),
        (bottom: 70, bottom9: 100, disabled: false, colorful: false, shape: SemiFloatButtonShape.square, clickable: false),
        (bottom: 24, bottom9: 24, disabled: false, colorful: false, shape: SemiFloatButtonShape.round, clickable: true),
      ];

  /// stories `Single` 搬用：9 列 × 5 行组合矩阵。
  Widget _officialSingle() => Stack(
    key: const ValueKey('floatbutton-official-single'),
    children: [
      for (final (i, col) in _singleCols.indexed)
        for (final row in _singleRows)
          _offset(
            end: col.end,
            bottom: i == 8 ? row.bottom9 : row.bottom,
            child: SemiFloatButton(
              size: col.size,
              shape: row.shape,
              colorful: row.colorful,
              disabled: row.disabled,
              badge: col.badge,
              icon: SemiIcon(SemiIcons.aiEditLevel1, size: col.icon),
              onClick: row.clickable
                  ? () => _push('官方 Single onClick')
                  : null,
            ),
          ),
    ],
  );

  /// stories `HrefTarget`（:75-84）搬用：href/target 跳转按钮（首枚包
  /// DragMove 拖拽容器——未移植）——href 仅元数据不导航（差异清单 10）。
  Widget _officialHref() => Stack(
    key: const ValueKey('floatbutton-official-href'),
    children: [
      _offset(
        bottom: 220,
        child: SemiFloatButton(
          icon: const SemiIcon(SemiIcons.aiEditLevel1),
          href: 'https://semi.design',
          target: '_blank',
        ),
      ),
      _offset(
        bottom: 170,
        child: SemiFloatButton(
          shape: SemiFloatButtonShape.square,
          icon: const SemiIcon(SemiIcons.aiEditLevel1),
          href: 'https://semi.design',
          target: '_blank',
        ),
      ),
    ],
  );

  /// stories `GroupNormal`（:86-163）搬用：三组子项（编辑/搜索/帮助）——无
  /// 徽章 / dot danger / count danger（帮助 100 + overflow 99）。上游以
  /// style 挂左上（top 24/100/180）——style 定位未移植（差异清单 11），
  /// 按 end/bottom 同节奏错开。
  Widget _officialGroupNormal() => Stack(
    key: const ValueKey('floatbutton-official-group-normal'),
    children: [
      _offset(
        bottom: 184,
        child: SemiFloatButtonGroup(
          items: [
            _gitem('editor', '编辑', SemiIcons.aiStrokedLevel3),
            _gitem('search', '搜索', SemiIcons.searchStroked),
            _gitem('help', '帮助', SemiIcons.helpCircleStroked),
          ],
        ),
      ),
      _offset(
        bottom: 104,
        child: SemiFloatButtonGroup(
          items: [
            _gitem(
              'editor',
              '编辑',
              SemiIcons.aiStrokedLevel3,
              badge: const SemiFloatButtonBadge(
                dot: true,
                type: SemiBadgeType.danger,
              ),
            ),
            _gitem(
              'search',
              '搜索',
              SemiIcons.searchStroked,
              badge: const SemiFloatButtonBadge(
                dot: true,
                type: SemiBadgeType.danger,
              ),
            ),
            _gitem(
              'help',
              '帮助',
              SemiIcons.helpCircleStroked,
              badge: const SemiFloatButtonBadge(
                dot: true,
                type: SemiBadgeType.danger,
              ),
            ),
          ],
        ),
      ),
      _offset(
        bottom: 24,
        child: SemiFloatButtonGroup(
          items: [
            _gitem(
              'editor',
              '编辑',
              SemiIcons.aiStrokedLevel3,
              badge: const SemiFloatButtonBadge(
                count: 3,
                type: SemiBadgeType.danger,
              ),
            ),
            _gitem(
              'search',
              '搜索',
              SemiIcons.searchStroked,
              badge: const SemiFloatButtonBadge(
                count: 3,
                type: SemiBadgeType.danger,
              ),
            ),
            _gitem(
              'help',
              '帮助',
              SemiIcons.helpCircleStroked,
              badge: const SemiFloatButtonBadge(
                count: 100,
                overflowCount: 99,
                type: SemiBadgeType.danger,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  /// stories `GroupItemClick`（:165-194）搬用：value + 组 onClick 回传。
  Widget _officialGroupClick() => Stack(
    key: const ValueKey('floatbutton-official-group-click'),
    children: [
      _offset(
        bottom: 50,
        child: SemiFloatButtonGroup(
          onClick: (value, event) => _push('官方 GroupItemClick value=$value'),
          items: [
            _gitem('editor', '编辑', SemiIcons.aiStrokedLevel3),
            _gitem('search', '搜索', SemiIcons.searchStroked),
            _gitem('help', '帮助', SemiIcons.helpCircleStroked),
          ],
        ),
      ),
    ],
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
                  onClick: (value, event) =>
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
                      onClick: (value, event) => _push('group 禁用不应达'),
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
          // ---- 官方 stories 搬用（packages/semi-ui/floatButton/_story/
          // floatButton.stories.jsx）——4 个 story 原样搬用对照 ----
          _section('官方 stories 搬用：Single', [
            _demo(
              '上游 `Single`（9 列 × 5 行组合矩阵）原样搬用：列 = end 24→500'
              '（尺寸 × 徽章组合），行 = 禁用 / colorful 方 / colorful / 方 / '
              '圆 + onClick；第 9 列 bottom 逐字上移。',
              _officialSingle(),
              height: 380,
            ),
          ]),
          _section('官方 stories 搬用：HrefTarget', [
            _demo(
              '上游 `HrefTarget`：href/target 跳转按钮（DragMove 拖拽容器未'
              '移植；href 仅元数据、不导航——应用在 onClick 自理）。',
              _officialHref(),
              height: 280,
            ),
          ]),
          _section('官方 stories 搬用：GroupNormal', [
            _demo(
              '上游 `GroupNormal`：三组子项（编辑/搜索/帮助）——无徽章 / '
              'dot danger / count danger（帮助 100+99）。上游以 style 挂左上，'
              'style 定位未移植——按 end/bottom 同节奏错开。',
              _officialGroupNormal(),
              height: 260,
            ),
          ]),
          _section('官方 stories 搬用：GroupItemClick', [
            _demo(
              '上游 `GroupItemClick`：value + 组 onClick 回传'
              '（editor/search/help）。',
              _officialGroupClick(),
            ),
          ]),
        ],
      ),
    );
  }
}
