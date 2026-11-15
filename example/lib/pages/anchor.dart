import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class AnchorPage extends StatefulWidget {
  const AnchorPage({super.key});

  @override
  State<AnchorPage> createState() => _AnchorPageState();
}

class _AnchorPageState extends State<AnchorPage> {
  String _status = '点击锚点或滚动内容区，事件写入此行。';

  // 事件回传顺序记录（onChanged / onClick，slider 的 events demo 模式）。
  final List<String> _events = [];

  // 各演示独立滚动容器（scroll-spy / 点击滚动各自联动）。
  final ScrollController _basicController = ScrollController();
  final ScrollController _nestedController = ScrollController();
  final ScrollController _motionController = ScrollController();
  final ScrollController _disabledController = ScrollController();
  final ScrollController _defaultController = ScrollController();

  @override
  void dispose() {
    _basicController.dispose();
    _nestedController.dispose();
    _motionController.dispose();
    _disabledController.dispose();
    _defaultController.dispose();
    super.dispose();
  }

  void _push(String event) {
    _events.add(event);
    if (_events.length > 6) _events.removeRange(0, _events.length - 6);
    _status = _events.join('；');
  }

  /// onChanged(current, previous)：★current 可为 null（首项以上 quirk）——
  /// 初值空串一并按 null 展示。
  static String _fmt(String? href) =>
      (href == null || href.isEmpty) ? 'null' : href;

  void _changed(String? current, String? previous) =>
      setState(() => _push('onChanged ${_fmt(current)} ← ${_fmt(previous)}'));

  void _clicked(String href) => setState(() => _push('onClick $href'));

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  /// 演示区限高 320（各组左锚右滚，内容区内滚）；[width] 定宽形态走窄屏
  /// 横向滚动（switch/slider 的 `_wideDemo` 模式）。
  Widget _demo(String label, Widget child, {double? width}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiText(label),
      const SizedBox(height: 6),
      SizedBox(
        height: 320,
        child: width == null
            ? child
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(width: width, child: child),
              ),
      ),
      const SizedBox(height: 12),
    ],
  );

  /// 左锚点 + 右滚动内容。★docs/semi_anchor.md 差异清单 20：宿主用
  /// Column + SingleChildScrollView，勿用 ListView——惰性卸载会破坏 spy。
  Widget _anchored({
    required Widget anchor,
    required Key scrollKey,
    required ScrollController controller,
    required List<Widget> sections,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(width: 200, child: anchor),
      const SizedBox(width: 24),
      Expanded(
        child: SingleChildScrollView(
          key: scrollKey,
          controller: controller,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sections,
          ),
        ),
      ),
    ],
  );

  /// 内容区块目标（SemiAnchorTarget 显式注册；id 与 href 对齐）。
  Widget _target(String id, String title, String body) => SemiAnchorTarget(
    id: id,
    child: SizedBox(
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SemiTitle(title, heading: 4),
          const SizedBox(height: 8),
          SemiText(body),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SemiText(_status, key: const ValueKey('anchor-status')),
          const SizedBox(height: 24),
          _section('基础用法', [
            _demo(
              '左锚点 + 右滚动内容 — defaultAnchor 首项；点击锚点滚动、滚动时 '
              'scroll-spy 迁移高亮（★onChanged current 可为 null）',
              _anchored(
                anchor: SemiAnchor(
                  key: const ValueKey('anchor-basic'),
                  scrollController: _basicController,
                  defaultAnchor: '#basic-1',
                  onChanged: _changed,
                  onClick: _clicked,
                  children: const [
                    SemiAnchorLink(href: '#basic-1', title: '基础概述'),
                    SemiAnchorLink(href: '#basic-2', title: '基础安装'),
                    SemiAnchorLink(href: '#basic-3', title: '基础配置'),
                    SemiAnchorLink(href: '#basic-4', title: '基础进阶'),
                  ],
                ),
                scrollKey: const ValueKey('anchor-basic-scroll'),
                controller: _basicController,
                sections: [
                  _target(
                    '#basic-1',
                    '内容 · 基础概述',
                    '这里是基础概述章节的正文，滚动查看 scroll-spy 高亮迁移。',
                  ),
                  _target('#basic-2', '内容 · 基础安装', '这里是基础安装章节的正文。'),
                  _target('#basic-3', '内容 · 基础配置', '这里是基础配置章节的正文。'),
                  _target('#basic-4', '内容 · 基础进阶', '这里是基础进阶章节的正文。'),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('嵌套层级', [
            _demo(
              '二级/三级 SemiAnchorLink children — 层级无限，缩进 8 * level',
              _anchored(
                anchor: SemiAnchor(
                  key: const ValueKey('anchor-nested'),
                  scrollController: _nestedController,
                  onChanged: _changed,
                  onClick: _clicked,
                  children: const [
                    SemiAnchorLink(
                      href: '#nested-1',
                      title: '嵌套父级一',
                      children: [
                        SemiAnchorLink(
                          href: '#nested-1-1',
                          title: '嵌套二级一',
                          children: [
                            SemiAnchorLink(
                              href: '#nested-1-1-1',
                              title: '嵌套三级一',
                            ),
                          ],
                        ),
                        SemiAnchorLink(href: '#nested-1-2', title: '嵌套二级二'),
                      ],
                    ),
                    SemiAnchorLink(href: '#nested-2', title: '嵌套父级二'),
                  ],
                ),
                scrollKey: const ValueKey('anchor-nested-scroll'),
                controller: _nestedController,
                sections: [
                  _target('#nested-1', '内容 · 嵌套父级一', '这里是父级一章节的正文。'),
                  _target('#nested-1-1', '内容 · 嵌套二级一', '这里是二级一章节的正文。'),
                  _target('#nested-1-1-1', '内容 · 嵌套三级一', '这里是三级一章节的正文。'),
                  _target('#nested-1-2', '内容 · 嵌套二级二', '这里是二级二章节的正文。'),
                  _target('#nested-2', '内容 · 嵌套父级二', '这里是父级二章节的正文。'),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('size 两档', [
            _demo(
              'SemiAnchorSize.small（12px / 滑杆 24）vs defaultSize（14px / 滑杆 28）',
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemiAnchor(
                    key: const ValueKey('anchor-size-small'),
                    size: SemiAnchorSize.small,
                    defaultAnchor: '#size-s-1',
                    children: const [
                      SemiAnchorLink(href: '#size-s-1', title: '尺寸小甲'),
                      SemiAnchorLink(href: '#size-s-2', title: '尺寸小乙'),
                    ],
                  ),
                  const SizedBox(width: 24),
                  SemiAnchor(
                    key: const ValueKey('anchor-size-default'),
                    size: SemiAnchorSize.defaultSize,
                    defaultAnchor: '#size-d-1',
                    children: const [
                      SemiAnchorLink(href: '#size-d-1', title: '尺寸默认甲'),
                      SemiAnchorLink(href: '#size-d-2', title: '尺寸默认乙'),
                    ],
                  ),
                ],
              ),
              width: 424,
            ),
          ]),
          const SizedBox(height: 40),
          _section('railTheme 三态', [
            _demo(
              'primary / tertiary / muted — ★muted 轨道 display:none quirk（整棵滑轨不渲染）',
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemiAnchor(
                    key: const ValueKey('anchor-theme-primary'),
                    railTheme: SemiAnchorRailTheme.primary,
                    defaultAnchor: '#theme-p-1',
                    children: const [
                      SemiAnchorLink(href: '#theme-p-1', title: '主题主色甲'),
                      SemiAnchorLink(href: '#theme-p-2', title: '主题主色乙'),
                    ],
                  ),
                  const SizedBox(width: 24),
                  SemiAnchor(
                    key: const ValueKey('anchor-theme-tertiary'),
                    railTheme: SemiAnchorRailTheme.tertiary,
                    defaultAnchor: '#theme-t-1',
                    children: const [
                      SemiAnchorLink(href: '#theme-t-1', title: '主题次色甲'),
                      SemiAnchorLink(href: '#theme-t-2', title: '主题次色乙'),
                    ],
                  ),
                  const SizedBox(width: 24),
                  SemiAnchor(
                    key: const ValueKey('anchor-theme-muted'),
                    railTheme: SemiAnchorRailTheme.muted,
                    defaultAnchor: '#theme-m-1',
                    children: const [
                      SemiAnchorLink(href: '#theme-m-1', title: '主题静默甲'),
                      SemiAnchorLink(href: '#theme-m-2', title: '主题静默乙'),
                    ],
                  ),
                ],
              ),
              width: 648,
            ),
          ]),
          const SizedBox(height: 40),
          _section('autoCollapse 自动折叠', [
            _demo(
              'autoCollapse: true — 仅展开 active 所在分支（非激活分支整棵折叠）',
              SizedBox(
                width: 200,
                child: SemiAnchor(
                  key: const ValueKey('anchor-auto-collapse'),
                  autoCollapse: true,
                  onChanged: _changed,
                  onClick: _clicked,
                  children: const [
                    SemiAnchorLink(
                      href: '#collapse-1',
                      title: '折叠父级一',
                      children: [
                        SemiAnchorLink(href: '#collapse-1-1', title: '折叠子项一'),
                        SemiAnchorLink(href: '#collapse-1-2', title: '折叠子项二'),
                      ],
                    ),
                    SemiAnchorLink(
                      href: '#collapse-2',
                      title: '折叠父级二',
                      children: [
                        SemiAnchorLink(href: '#collapse-2-1', title: '折叠子项三'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('showTooltip 悬停提示', [
            _demo(
              "showTooltip: true, position: SemiTooltipPosition.right — title 悬停出 tooltip",
              SizedBox(
                width: 200,
                child: SemiAnchor(
                  key: const ValueKey('anchor-tooltip'),
                  showTooltip: true,
                  position: SemiTooltipPosition.right,
                  children: const [
                    SemiAnchorLink(href: '#tooltip-1', title: '提示项甲'),
                    SemiAnchorLink(href: '#tooltip-2', title: '提示项乙'),
                  ],
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('scrollMotion 与 targetOffset', [
            _demo(
              'scrollMotion: true, targetOffset: 60 — 点击 animateTo（300ms），'
              '落点 = 目标顶 - 60',
              _anchored(
                anchor: SemiAnchor(
                  key: const ValueKey('anchor-motion'),
                  scrollController: _motionController,
                  scrollMotion: true,
                  targetOffset: 60,
                  onChanged: _changed,
                  onClick: _clicked,
                  children: const [
                    SemiAnchorLink(href: '#motion-1', title: '动效甲'),
                    SemiAnchorLink(href: '#motion-2', title: '动效乙'),
                    SemiAnchorLink(href: '#motion-3', title: '动效丙'),
                  ],
                ),
                scrollKey: const ValueKey('anchor-motion-scroll'),
                controller: _motionController,
                sections: [
                  _target('#motion-1', '内容 · 动效甲', '这里是动效甲章节的正文。'),
                  _target('#motion-2', '内容 · 动效乙', '这里是动效乙章节的正文。'),
                  _target('#motion-3', '内容 · 动效丙', '这里是动效丙章节的正文。'),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('禁用项', [
            _demo(
              'SemiAnchorLink(disabled: true) — 不可点/Enter 无效，但滚动到时照高亮'
              '（★disabled 色覆盖 active 色 quirk）',
              _anchored(
                anchor: SemiAnchor(
                  key: const ValueKey('anchor-disabled'),
                  scrollController: _disabledController,
                  onChanged: _changed,
                  onClick: _clicked,
                  children: const [
                    SemiAnchorLink(href: '#disabled-1', title: '禁用演示一'),
                    SemiAnchorLink(
                      href: '#disabled-2',
                      title: '禁用项（不可点）',
                      disabled: true,
                    ),
                    SemiAnchorLink(href: '#disabled-3', title: '禁用演示三'),
                  ],
                ),
                scrollKey: const ValueKey('anchor-disabled-scroll'),
                controller: _disabledController,
                sections: [
                  _target('#disabled-1', '内容 · 禁用演示一', '这里是演示一章节的正文。'),
                  _target(
                    '#disabled-2',
                    '内容 · 禁用演示二',
                    '这里是被禁用项对应的章节正文（spy 照常迁移到它）。',
                  ),
                  _target('#disabled-3', '内容 · 禁用演示三', '这里是演示三章节的正文。'),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('defaultAnchor 初始高亮', [
            _demo(
              "defaultAnchor: '#default-2' — mount 时高亮+滚动，★不发 onChanged/onClick",
              _anchored(
                anchor: SemiAnchor(
                  key: const ValueKey('anchor-default'),
                  scrollController: _defaultController,
                  defaultAnchor: '#default-2',
                  onChanged: _changed,
                  onClick: _clicked,
                  children: const [
                    SemiAnchorLink(href: '#default-1', title: '默认锚点甲'),
                    SemiAnchorLink(href: '#default-2', title: '默认锚点乙'),
                    SemiAnchorLink(href: '#default-3', title: '默认锚点丙'),
                  ],
                ),
                scrollKey: const ValueKey('anchor-default-scroll'),
                controller: _defaultController,
                sections: [
                  _target('#default-1', '内容 · 默认锚点甲', '这里是锚点甲章节的正文。'),
                  _target('#default-2', '内容 · 默认锚点乙', '这里是锚点乙章节的正文。'),
                  _target('#default-3', '内容 · 默认锚点丙', '这里是锚点丙章节的正文。'),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          const SemiText(
            '未支持/延期（照 docs/semi_anchor.md 差异清单）：'
            'getContainer → scrollController（window 无对应，缺省不接 spy/不滚动）、'
            'showTooltip 对象形态（裁剪为 bool + position）、'
            'SemiAnchorTarget 显式注册（上游 DOM id 查找的 Flutter 对应新增）、'
            'ListView 宿主（惰性卸载破坏 spy——用 Column + SingleChildScrollView）、'
            'className/style、Form 联动。',
            key: ValueKey('anchor-unsupported-note'),
          ),
        ],
      ),
    );
  }
}
