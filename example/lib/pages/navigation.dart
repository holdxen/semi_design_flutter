import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  String _status = '点击导航条目，事件写入此行。';

  // 事件回传记录（onSelect 先、onClick 后——itemFoundation.ts:67-96）。
  final List<String> _events = [];

  // 受控演示状态（selectedKeys / openKeys / isCollapsed 三路受控）。
  List<Object> _controlledSelected = const ['受控甲'];
  List<Object> _controlledOpen = const [];
  bool _controlledCollapsed = false;

  void _push(String event) {
    _events.add(event);
    if (_events.length > 6) _events.removeRange(0, _events.length - 6);
    _status = _events.join('；');
  }

  void _select(SemiNavigationSelectInfo info) =>
      setState(() => _push('onSelect ${info.itemKey}'));

  void _open(SemiNavigationOpenInfo info) =>
      setState(() => _push('onOpenChange ${info.itemKey} open:${info.isOpen}'));

  void _collapse(bool value) =>
      setState(() => _push('onCollapseChange $value'));

  /// isCollapsed 受控 handler：接受新值（内部不自改，渲染跟随 props）。
  void _collapseControlled(bool value) => setState(() {
    _controlledCollapsed = value;
    _push('onCollapseChange $value');
  });

  void _click(SemiNavigationClickInfo info) =>
      setState(() => _push('onClick ${info.itemKey}'));

  // ---- items fixtures（静态恒等——items 变更会整体重建 key map）----

  static const List<Object> _basicItems = <Object>[
    '基础首页', // String 归一化 → {text, itemKey}
    SemiNavigationItem(
      itemKey: '基础Sub',
      text: '基础Sub',
      icon: SemiIcon(SemiIcons.component),
      items: <Object>[
        SemiNavigationItem(itemKey: '基础子一', text: '基础子一'),
        SemiNavigationItem(itemKey: '基础子二', text: '基础子二'),
      ],
    ),
    SemiNavigationItem(
      itemKey: '基础链接',
      text: '基础链接',
      icon: SemiIcon(SemiIcons.link),
      link: 'https://semi.design',
    ),
  ];

  static const List<Object> _collapsedItems = <Object>[
    SemiNavigationItem(
      itemKey: '收起项一',
      text: '收起项一',
      icon: SemiIcon(SemiIcons.home),
    ),
    SemiNavigationItem(
      itemKey: '收起Sub',
      text: '收起Sub',
      icon: SemiIcon(SemiIcons.folder),
      items: <Object>[
        SemiNavigationItem(itemKey: '收起子一', text: '收起子一'),
        SemiNavigationItem(itemKey: '收起子二', text: '收起子二'),
      ],
    ),
    SemiNavigationItem(
      itemKey: '收起项二',
      text: '收起项二',
      icon: SemiIcon(SemiIcons.setting),
    ),
  ];

  static const List<Object> _horizontalItems = <Object>[
    SemiNavigationItem(itemKey: '水平一', text: '水平一'),
    SemiNavigationItem(
      itemKey: '水平Sub',
      text: '水平Sub',
      items: <Object>[
        SemiNavigationItem(itemKey: '水平子一', text: '水平子一'),
        SemiNavigationItem(itemKey: '水平子二', text: '水平子二'),
      ],
    ),
    SemiNavigationItem(itemKey: '水平三', text: '水平三'),
  ];

  static const List<Object> _controlledItems = <Object>[
    SemiNavigationItem(itemKey: '受控甲', text: '受控甲'),
    SemiNavigationItem(itemKey: '受控乙', text: '受控乙'),
  ];

  static const List<Object> _controlledOpenItems = <Object>[
    SemiNavigationItem(
      itemKey: '受控Sub',
      text: '受控Sub',
      items: <Object>[SemiNavigationItem(itemKey: '受控子一', text: '受控子一')],
    ),
  ];

  static const List<Object> _disabledItems = <Object>[
    SemiNavigationItem(itemKey: '禁用项', text: '禁用项', disabled: true),
    SemiNavigationItem(
      itemKey: '禁用Sub',
      text: '禁用Sub',
      disabled: true,
      items: <Object>[SemiNavigationItem(itemKey: '禁用子一', text: '禁用子一')],
    ),
    SemiNavigationItem(itemKey: '正常项', text: '正常项'),
  ];

  static const List<Object> _toggleLeftItems = <Object>[
    SemiNavigationItem(itemKey: '左置项', text: '左置项'),
    SemiNavigationItem(
      itemKey: '左置Sub',
      text: '左置Sub',
      items: <Object>[SemiNavigationItem(itemKey: '左置子一', text: '左置子一')],
    ),
  ];

  static const List<Object> _toggleRightItems = <Object>[
    SemiNavigationItem(itemKey: '右置项', text: '右置项'),
    SemiNavigationItem(
      itemKey: '右置Sub',
      text: '右置Sub',
      items: <Object>[SemiNavigationItem(itemKey: '右置子一', text: '右置子一')],
    ),
  ];

  // limitIndent: false —— 占位图标数按 indent 参数（Item.tsx:213-215）。
  static const List<Object> _indentItems = <Object>[
    SemiNavigationItem(
      itemKey: '手动Sub',
      text: '手动Sub',
      items: <Object>[
        SemiNavigationItem(
          itemKey: '手动Sub2',
          text: '手动Sub2',
          items: <Object>[
            SemiNavigationItem(
              itemKey: '手动甲',
              text: '手动甲',
              icon: SemiIcon(SemiIcons.home),
              indent: true,
            ),
            SemiNavigationItem(
              itemKey: '手动乙',
              text: '手动乙',
              icon: SemiIcon(SemiIcons.home),
            ),
            SemiNavigationItem(
              itemKey: '手动丙',
              text: '手动丙',
              icon: SemiIcon(SemiIcons.home),
              indent: 0, // ★int 0 falsy quirk——同「无 indent」
            ),
          ],
        ),
      ],
    ),
  ];

  static const List<Object> _expandIconItems = <Object>[
    SemiNavigationItem(
      itemKey: '图标Sub',
      text: '图标Sub',
      items: <Object>[SemiNavigationItem(itemKey: '图标子一', text: '图标子一')],
    ),
    SemiNavigationItem(itemKey: '图标项', text: '图标项'),
  ];

  static const List<Object> _headerFooterItems = <Object>[
    // ★带 icon：收起态（60px）文字渐隐后靠图标识别，否则整栏只剩空白行。
    SemiNavigationItem(
      itemKey: '页眉项一',
      text: '页眉项一',
      icon: SemiIcon(SemiIcons.home),
    ),
    SemiNavigationItem(
      itemKey: '页眉项二',
      text: '页眉项二',
      icon: SemiIcon(SemiIcons.folder),
    ),
  ];

  static const List<Object> _numericItems = <Object>[
    SemiNavigationItem(itemKey: 0, text: '零键条目'), // ★0 是合法 key
    SemiNavigationItem(itemKey: 1, text: '壹键条目'),
  ];

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
          // ★定高日志行：事件追加变行会把下方内容整体下推——指针静止但条目
          // 移走即触发悬停区 exit（弹层开→关抖动、页面「自己漂移」的根源）。
          SizedBox(
            height: 60,
            child: SingleChildScrollView(
              child: SemiText(
                _status,
                key: const ValueKey('navigation-status'),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _section('垂直基础', [
            _demo(
              'items 混排 — String 项（自动包装）+ SemiNavigationItem 二级 Sub '
              '（icon）+ link 项（href 元数据不导航）；defaultSelectedKeys '
              '「基础子二」自动展开选中项祖先 + Sub 标题亮 selected（★自动附'
              '一级父 key 只进内部 state，onSelect 载荷只有 [itemKey]）；'
              '★已选中再点不触发 onSelect 不移除',
              SizedBox(
                height: 300,
                child: SemiNavigation(
                  key: const ValueKey('navigation-basic'),
                  items: _basicItems,
                  defaultSelectedKeys: const ['基础子二'],
                  onSelect: _select,
                  onOpenChange: _open,
                  onClick: _click,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('收起模式', [
            _demo(
              'defaultIsCollapsed: true — 60px 图标栏（文字渐隐 opacity: 0 仍'
              '在树上）；平铺 item hover 出右侧 Tooltip；Sub 悬停/点按弹出层菜单'
              '（弹层内点条目即收起；★hover 0ms 开/移出 100ms 关、鼠标点按只发 '
              'onClick）；footer '
              '收起按钮缺省 locale '
              '「展开侧边栏」→ 点击展开 240px（onCollapseChange 回传新值）',
              SizedBox(
                height: 280,
                child: SemiNavigation(
                  key: const ValueKey('navigation-collapsed'),
                  items: _collapsedItems,
                  defaultIsCollapsed: true,
                  onSelect: _select,
                  onOpenChange: _open,
                  onCollapseChange: _collapse,
                  onClick: _click,
                  footer: const SemiNavigationFooter(collapseButton: true),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('水平模式', [
            _demo(
              'mode: horizontal — 一行排布（高 60）+ Sub 全走弹层菜单'
              '（bottomLeft）；★footer 不渲染（Footer.tsx:64 quirk——'
              'collapseButton 水平模式整体缺席）',
              SemiNavigation(
                key: const ValueKey('navigation-horizontal'),
                items: _horizontalItems,
                mode: SemiNavigationMode.horizontal,
                onSelect: _select,
                onOpenChange: _open,
                onClick: _click,
                footer: const SemiNavigationFooter(collapseButton: true),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('受控', [
            _demo(
              'selectedKeys 受控 — 点击条目只发 onSelect 不改内部 state（渲染'
              '不跟随），按钮改值才换选中（应用改 props）',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SemiButton(
                        '选中受控乙',
                        onPressed: () =>
                            setState(() => _controlledSelected = const ['受控乙']),
                      ),
                      const SizedBox(width: 8),
                      SemiButton(
                        '选中受控甲',
                        onPressed: () =>
                            setState(() => _controlledSelected = const ['受控甲']),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 160,
                    child: SemiNavigation(
                      key: const ValueKey('navigation-controlled'),
                      items: _controlledItems,
                      selectedKeys: _controlledSelected,
                      onSelect: _select,
                      onOpenChange: _open,
                      onClick: _click,
                    ),
                  ),
                ],
              ),
            ),
            _demo(
              'openKeys 受控 — ★受控仅 vertical 未折叠生效（index.tsx:407 '
              'quirk）；Sub 标题点击只发 onOpenChange/onClick，展开与否由'
              '按钮改 openKeys 决定',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SemiButton(
                        '打开受控Sub',
                        onPressed: () =>
                            setState(() => _controlledOpen = const ['受控Sub']),
                      ),
                      const SizedBox(width: 8),
                      SemiButton(
                        '收起受控Sub',
                        onPressed: () =>
                            setState(() => _controlledOpen = const []),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 180,
                    child: SemiNavigation(
                      key: const ValueKey('navigation-controlled-open'),
                      items: _controlledOpenItems,
                      openKeys: _controlledOpen,
                      onSelect: _select,
                      onOpenChange: _open,
                      onClick: _click,
                    ),
                  ),
                ],
              ),
            ),
            _demo(
              'isCollapsed 受控 — footer 收起按钮点击发 onCollapseChange（回传'
              '新值）但不改内部 state，渲染跟随 handler 改 props；外部按钮亦可'
              '直接改值',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemiButton(
                    '切换受控折叠',
                    onPressed: () => setState(() {
                      _controlledCollapsed = !_controlledCollapsed;
                      _push('受控折叠 切为 $_controlledCollapsed');
                    }),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 180,
                    child: SemiNavigation(
                      key: const ValueKey('navigation-controlled-collapse'),
                      items: const <Object>[
                        SemiNavigationItem(
                          itemKey: '受控折叠项',
                          text: '受控折叠项',
                          icon: SemiIcon(SemiIcons.home),
                        ),
                      ],
                      isCollapsed: _controlledCollapsed,
                      onSelect: _select,
                      onOpenChange: _open,
                      onCollapseChange: _collapseControlled,
                      onClick: _click,
                      footer: const SemiNavigationFooter(collapseButton: true),
                    ),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('禁用', [
            _demo(
              'disabled — item/sub 禁用（forbidden 光标、点击/键盘均不响应、'
              'onSelect/onOpenChange/onClick 全不发）',
              SizedBox(
                height: 220,
                child: SemiNavigation(
                  key: const ValueKey('navigation-disabled'),
                  items: _disabledItems,
                  onSelect: _select,
                  onOpenChange: _open,
                  onClick: _click,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('toggleIconPosition', [
            _demo(
              'left — Sub 展开图标在标题前；★普通条目 toggleIcon 为空仍渲染'
              '空 toggle 槽（Item.tsx:220/223 quirk——文本右移一槽）',
              SizedBox(
                height: 180,
                child: SemiNavigation(
                  key: const ValueKey('navigation-toggle-left'),
                  items: _toggleLeftItems,
                  toggleIconPosition: SemiNavigationToggleIconPosition.left,
                  onSelect: _select,
                  onOpenChange: _open,
                  onClick: _click,
                ),
              ),
            ),
            _demo(
              'right（缺省）— Sub 展开图标在标题后',
              SizedBox(
                height: 180,
                child: SemiNavigation(
                  key: const ValueKey('navigation-toggle-right'),
                  items: _toggleRightItems,
                  onSelect: _select,
                  onOpenChange: _open,
                  onClick: _click,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('limitIndent 与 indent', [
            _demo(
              'limitIndent: false — 子级不走统一 44px 缩进，占位图标数按 '
              'indent 参数（icon && !indent ? level : level-1，Item.tsx:213-215）：'
              '手动甲 indent: true 占位少一槽、手动乙无 indent 占位多一槽、'
              '手动丙 indent: 0（★int 0 falsy quirk 同无 indent）',
              SizedBox(
                height: 300,
                child: SemiNavigation(
                  key: const ValueKey('navigation-limit-indent'),
                  items: _indentItems,
                  limitIndent: false,
                  defaultOpenKeys: const ['手动Sub', '手动Sub2'],
                  onSelect: _select,
                  onOpenChange: _open,
                  onClick: _click,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('自定义 expandIcon', [
            _demo(
              'expandIcon: SemiIcon(SemiIcons.chevronRight) — 替换缺省 '
              'chevron_down（vertical 开启 subNavMotion 时旋转 200ms）',
              SizedBox(
                height: 180,
                child: SemiNavigation(
                  key: const ValueKey('navigation-expand-icon'),
                  items: _expandIconItems,
                  expandIcon: const SemiIcon(SemiIcons.chevronRight),
                  onSelect: _select,
                  onOpenChange: _open,
                  onClick: _click,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('Header 与 Footer', [
            _demo(
              'SemiNavigationHeader(logo 36×36 scale-down + text) + '
              'SemiNavigationFooter(collapseButton + collapseText 固定串——'
              '上游函数形态收敛 String)；条目带 icon（收起态文字渐隐后靠图标识别）；'
              '收起后 header text 隐、logo 居中、按钮 icon-only 带 tooltip',
              SizedBox(
                height: 320,
                child: SemiNavigation(
                  key: const ValueKey('navigation-header-footer'),
                  items: _headerFooterItems,
                  onSelect: _select,
                  onOpenChange: _open,
                  onCollapseChange: _collapse,
                  onClick: _click,
                  header: const SemiNavigationHeader(
                    logo: SemiIcon(SemiIcons.semiLogo),
                    text: 'Semi Design',
                    link: 'https://semi.design',
                  ),
                  footer: const SemiNavigationFooter(
                    collapseButton: true,
                    collapseText: '收起导航',
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('numeric itemKey', [
            _demo(
              'itemKey: 0 — ★0 是合法 key（foundation.ts:79 `??` 判定 quirk，'
              '不做 falsy 丢弃）：点击正常参与选中/onSelect',
              SizedBox(
                height: 180,
                child: SemiNavigation(
                  key: const ValueKey('navigation-numeric-key'),
                  items: _numericItems,
                  onSelect: _select,
                  onOpenChange: _open,
                  onClick: _click,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          const SemiText(
            '未支持/延期（照 docs/semi_navigation.md 差异清单）：'
            'children JSX 写法（items 强类型列表承担）、renderWrapper/'
            'getPopupContainer/subDropdownProps/bodyStyle 裁剪、'
            'multiple/onDeselect/isOpen/maxHeight/toggleIcon 死 API 留档不移植、'
            'subNavMotion 对象形态收敛 bool、delay 参数固定 constants 缺省、'
            'link 不导航（应用按 onClick 自行路由）、弹层自绘列表（色系 itemL1 '
            '近似）、Sub 内联展开动画 200ms 近似、collapseText 函数形态收敛 '
            'String、className/style/getDataAttr/prefixCls 不移植、'
            'aria 以 Semantics(button/selected/expanded) 近似、locale 仅 zh 两串'
            '硬编码。'
            '★弹层可见性语义（照上游 wrapDropdown trigger:hover 非受控）：'
            'hover 0ms 开/移出 100ms 关（进弹层续命），鼠标点按对可见性惰性'
            '仅发 onClick（touch tap 兜底 toggle），弹层内点条目即收起。',
            key: ValueKey('navigation-unsupported-note'),
          ),
        ],
      ),
    );
  }
}
