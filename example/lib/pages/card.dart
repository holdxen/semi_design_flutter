import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  bool _loading = true;

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  Widget _body(String text) => SemiText(text);

  Widget _cover() =>
      const SizedBox(height: 96, child: ColoredBox(color: Color(0xffd9eaff)));

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基础用法', [
            SemiCard(
              key: const ValueKey('basic-card'),
              title: '卡片标题',
              headerExtraContent: const SemiText('更多'),
              body: _body('卡片正文内容，包含标题、正文、操作组和脚注。'),
              actions: const [SemiText('操作一'), SemiText('操作二')],
              footer: const SemiText('卡片脚注'),
              footerLine: true,
            ),
          ]),
          const SizedBox(height: 40),
          _section('阴影', [
            const SemiText(
              'null 无阴影；hover 悬停浮起；always 常驻。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 220,
                  child: SemiCard(
                    key: const ValueKey('shadow-none'),
                    title: '无阴影',
                    body: _body('shadows: null'),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: SemiCard(
                    key: const ValueKey('shadow-hover'),
                    title: '悬停阴影',
                    shadows: SemiCardShadows.hover,
                    body: _body('shadows: hover'),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: SemiCard(
                    key: const ValueKey('shadow-always'),
                    title: '常驻阴影',
                    shadows: SemiCardShadows.always,
                    body: _body('shadows: always'),
                  ),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('边框与分隔线', [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 220,
                  child: SemiCard(
                    key: const ValueKey('borderless-card'),
                    bordered: false,
                    shadows: SemiCardShadows.always,
                    title: '无边框',
                    body: _body('bordered: false'),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: SemiCard(
                    key: const ValueKey('lines-card'),
                    title: '分隔线全开',
                    body: _body('headerLine 与 footerLine'),
                    footer: const SemiText('脚注'),
                    footerLine: true,
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: SemiCard(
                    key: const ValueKey('no-header-line-card'),
                    headerLine: false,
                    title: '无头部分隔线',
                    body: _body('headerLine: false'),
                  ),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('封面与 Meta', [
            SemiCard(
              key: const ValueKey('cover-card'),
              title: '带封面的卡片',
              cover: _cover(),
              body: const SemiCardMeta(
                avatar: SizedBox(
                  width: 36,
                  height: 36,
                  child: ColoredBox(color: Color(0xff7b61ff)),
                ),
                title: 'Meta 标题',
                description: 'Meta 描述文字',
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('加载状态', [
            SemiText(
              _loading ? 'loading: true（正文骨架占位）' : 'loading: false',
              key: const ValueKey('card-status'),
            ),
            const SizedBox(height: 12),
            _action(
              'toggle-loading',
              _loading ? '停止加载' : '开始加载',
              () => setState(() => _loading = !_loading),
            ),
            const SizedBox(height: 12),
            SemiCard(
              key: const ValueKey('loading-card'),
              title: '加载中的卡片',
              loading: _loading,
              body: _body('这段内容在 loading 时被骨架占位替换。'),
            ),
          ]),
          const SizedBox(height: 40),
          _section('局部主题', [
            const SemiText('圆角 16、标题紫色、内边距 28。', type: SemiTextType.secondary),
            const SizedBox(height: 12),
            SemiCardTheme(
              data: const SemiCardThemeData(
                radiusCard: 16,
                colorCardTitleText: Color(0xff7b61ff),
                spacingCardPadding: 28,
              ),
              child: SemiCard(
                key: const ValueKey('theme-card'),
                title: '局部主题卡片',
                body: _body('主题字段对当前子树生效。'),
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
