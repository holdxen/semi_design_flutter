import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class BreadcrumbPage extends StatefulWidget {
  const BreadcrumbPage({super.key});

  @override
  State<BreadcrumbPage> createState() => _BreadcrumbPageState();
}

class _BreadcrumbPageState extends State<BreadcrumbPage> {
  String _status = '点击面包屑条目，事件写入此行。';

  // 事件回传顺序记录（item onClick 先、父 onClick 后——itemFoundation.ts:29-33）。
  final List<String> _events = [];

  void _push(String event) {
    _events.add(event);
    if (_events.length > 6) _events.removeRange(0, _events.length - 6);
    _status = _events.join('；');
  }

  // item 自身 onClick（★先于父 onClick）。
  void _itemClick(String name) => setState(() => _push('item:$name'));

  // 父 onClick（children 模式收合成 route——name/href/icon）。
  void _parentClick(SemiBreadcrumbRoute route) =>
      setState(() => _push('onClick ${route.name}'));

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
          SemiText(_status, key: const ValueKey('breadcrumb-status')),
          const SizedBox(height: 24),
          _section('routes 模式', [
            _demo(
              'routes 数组 — SemiBreadcrumbRoute 与 String 混排（String 自动包装）、'
              'href 仅元数据；点击条目 item onClick 先、父 onClick 后'
              '（★末项 active 无导航但照发 onClick、hover 恒手型）',
              SemiBreadcrumb(
                key: const ValueKey('breadcrumb-routes'),
                routes: [
                  SemiBreadcrumbRoute(
                    name: '首页',
                    href: '/',
                    onClick: (route) => _itemClick('首页'),
                  ),
                  SemiBreadcrumbRoute(
                    name: '组件',
                    href: '/components',
                    onClick: (route) => _itemClick('组件'),
                  ),
                  '面包屑', // String 自动包装（无 item onClick）
                  SemiBreadcrumbRoute(name: '当前页', href: '/breadcrumb'),
                ],
                onClick: _parentClick,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('children 模式', [
            _demo(
              'children 列表 — SemiBreadcrumbItem 数据载体（onClick 为 '
              'VoidCallback；父 onClick 收合成 route）',
              SemiBreadcrumb(
                key: const ValueKey('breadcrumb-children'),
                children: [
                  SemiBreadcrumbItem(
                    name: '一级',
                    href: '/l1',
                    onClick: () => _itemClick('一级'),
                  ),
                  SemiBreadcrumbItem(
                    name: '二级',
                    href: '/l2',
                    onClick: () => _itemClick('二级'),
                  ),
                  SemiBreadcrumbItem(name: '三级'),
                ],
                onClick: _parentClick,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('分隔符', [
            _demo(
              "默认 separator: '/' — 包壳着色（colorBreadcrumbSepearator…）",
              SemiBreadcrumb(
                key: const ValueKey('breadcrumb-sep-default'),
                routes: const ['默认一', '默认二', '默认三'],
              ),
            ),
            _demo(
              '自定义 — 上：字符串 separator: \'>\'；下：Widget 图标 '
              'SemiIcon(chevronRight)（String/Widget 双形态）',
              KeyedSubtree(
                key: const ValueKey('breadcrumb-sep-custom'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SemiBreadcrumb(
                      separator: '>',
                      routes: const ['尖角一', '尖角二', '尖角三'],
                    ),
                    const SizedBox(height: 8),
                    SemiBreadcrumb(
                      separator: const SemiIcon(SemiIcons.chevronRight),
                      routes: const ['图标分隔一', '图标分隔二', '图标分隔三'],
                    ),
                  ],
                ),
              ),
            ),
            _demo(
              'item 级 separator 覆盖 — 首项 separator: \'>\' 裸渲染不包壳、'
              '其余回退 context \'/\'（★falsy 回退 quirk）',
              SemiBreadcrumb(
                key: const ValueKey('breadcrumb-sep-item'),
                children: const [
                  SemiBreadcrumbItem(name: '覆盖一', separator: '>'),
                  SemiBreadcrumbItem(name: '覆盖二'),
                  SemiBreadcrumbItem(name: '覆盖三'),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('折叠', [
            _demo(
              '7 项 maxItemCount: 4 — 隐藏中间项（首项恒显、末 3 项恒显）+ more '
              '按钮；moreType: defaultType 点 more 展开全部'
              '（★单向展开不可回收）',
              SemiBreadcrumb(
                key: const ValueKey('breadcrumb-collapse'),
                maxItemCount: 4,
                routes: const ['折叠一', '折叠二', '折叠三', '折叠四', '折叠五', '折叠六', '折叠七'],
                onClick: _parentClick,
              ),
            ),
            _demo(
              'moreType: popover — 点 more 弹面板列 restItem（restItem 间自拼 '
              'separator；★hidden 项 separator 抑制）',
              SemiBreadcrumb(
                key: const ValueKey('breadcrumb-collapse-popover'),
                maxItemCount: 4,
                moreType: SemiBreadcrumbMoreType.popover,
                routes: const ['弹层一', '弹层二', '弹层三', '弹层四', '弹层五', '弹层六', '弹层七'],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('renderMore', [
            _demo(
              '自定义省略区 — renderMore 收 restItems 自拼 separator 渲染，'
              '点按展开全部',
              SemiBreadcrumb(
                key: const ValueKey('breadcrumb-render-more'),
                maxItemCount: 3,
                routes: const ['自定义一', '自定义二', '自定义三', '自定义四', '自定义五'],
                renderMore: (restItems) {
                  final children = <Widget>[const SemiText('更多»')];
                  for (var i = 0; i < restItems.length; i++) {
                    if (i > 0) children.add(const SemiText('/'));
                    children.add(restItems[i]);
                  }
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: children,
                  );
                },
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('activeIndex', [
            _demo(
              'activeIndex: 1 — 中间项 active（字重 600 + text-0 色）；'
              '★active 项照发 onClick 链（upstream span 恒挂、仅无导航）',
              SemiBreadcrumb(
                key: const ValueKey('breadcrumb-active-index'),
                activeIndex: 1,
                routes: const ['激活一', '激活二', '激活三', '激活四'],
                onClick: _parentClick,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('compact 两档', [
            _demo(
              'compact: true — 字号 12（icon small 12）',
              SemiBreadcrumb(
                key: const ValueKey('breadcrumb-compact'),
                compact: true,
                routes: const ['紧凑一', '紧凑二', '紧凑三'],
              ),
            ),
            _demo(
              'compact: false — 字号 14（icon default 16）',
              SemiBreadcrumb(
                key: const ValueKey('breadcrumb-loose'),
                compact: false,
                routes: const ['宽松一', '宽松二', '宽松三'],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('icon 与 noLink', [
            _demo(
              'icon — 条目前置 SemiIcon（compact 决定 size：small 12 / default 16）',
              SemiBreadcrumb(
                key: const ValueKey('breadcrumb-icon'),
                routes: const [
                  SemiBreadcrumbRoute(
                    name: '图标首页',
                    href: '/',
                    icon: SemiIcon(SemiIcons.home),
                  ),
                  SemiBreadcrumbRoute(
                    name: '图标列表',
                    href: '/list',
                    icon: SemiIcon(SemiIcons.article),
                  ),
                  SemiBreadcrumbRoute(
                    name: '图标详情',
                    icon: SemiIcon(SemiIcons.link),
                  ),
                ],
                onClick: _parentClick,
              ),
            ),
            _demo(
              'noLink: true — 去 hover/active 色、default 光标'
              '（★onClick 照发——差异清单 25）',
              SemiBreadcrumb(
                key: const ValueKey('breadcrumb-no-link'),
                children: [
                  SemiBreadcrumbItem(
                    name: '无链接甲',
                    noLink: true,
                    onClick: () => _itemClick('无链接甲'),
                  ),
                  SemiBreadcrumbItem(
                    name: '无链接乙',
                    noLink: true,
                    onClick: () => _itemClick('无链接乙'),
                  ),
                  SemiBreadcrumbItem(name: '无链接丙'),
                ],
                onClick: _parentClick,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('长文本截断与 tooltip', [
            _demo(
              'String name — itemMaxWidth: 150 截断（maxLines 1 + ellipsis），'
              'hover 出 tooltip（★Widget name 原样无截断 quirk）',
              SemiBreadcrumb(
                key: const ValueKey('breadcrumb-tooltip'),
                routes: const ['这是一个非常长的面包屑条目名称用来演示截断宽度与悬停提示', '提示短名', '提示当前'],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('renderItem', [
            _demo(
              'renderItem — 自定义条目渲染（替换 name 渲染，String 截断/tooltip '
              '让位于自绘）',
              SemiBreadcrumb(
                key: const ValueKey('breadcrumb-render-item'),
                renderItem: (route) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD5D8DE)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SemiText('自定义 ${route.name}'),
                ),
                routes: const ['渲染一', '渲染二', '渲染三'],
                onClick: _parentClick,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          const SemiText(
            '未支持/延期（照 docs/semi_breadcrumb.md 差异清单）：'
            'showTooltip 对象形态（收敛为 bool + itemMaxWidth，ellipsisPos 固定 '
            'end）、tooltip 溢出才出 → 悬停即出、popover 触发 hover → click'
            '（showArrow 不移植）、href 不导航（仅元数据，应用按 route.href '
            '自行路由）、className/style/getDataAttr、Form 联动、'
            'children 非 Item 的 warning quirk（强类型无落点）、'
            'aria-current 以 Semantics selected 近似。',
            key: ValueKey('breadcrumb-unsupported-note'),
          ),
        ],
      ),
    );
  }
}
