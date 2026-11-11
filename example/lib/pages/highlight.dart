import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class HighlightPage extends StatefulWidget {
  const HighlightPage({super.key});

  @override
  State<HighlightPage> createState() => _HighlightPageState();
}

class _HighlightPageState extends State<HighlightPage> {
  bool _caseSensitive = false;

  Widget _action(String key, String label, VoidCallback onTap) => SemiText(
    label,
    key: ValueKey(key),
    link: SemiTextLink(onTap: onTap),
  );

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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基础高亮', [
            const SemiText(
              '多个关键词按出现位置高亮，重叠片段自动合并。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            const SemiHighlight(
              'Semi Design 是一个设计系统，Semi 提供了完整的前端基础组件。',
              key: ValueKey('basic-highlight'),
              searchWords: [SemiHighlightWord('Semi'), SemiHighlightWord('设计')],
            ),
          ]),
          const SizedBox(height: 40),
          _section('逐词样式', [
            const SemiText(
              '逐词 style 最后覆盖全局 highlightStyle 与主题默认值。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            const SemiHighlight(
              '蓝色是定制样式，紫色是全局高亮样式，其余使用主题默认。',
              key: ValueKey('styled-highlight'),
              searchWords: [
                SemiHighlightWord(
                  '蓝色',
                  style: TextStyle(color: Color(0xff0055ff)),
                ),
                SemiHighlightWord('定制样式'),
                SemiHighlightWord('全局高亮样式'),
              ],
              highlightStyle: TextStyle(
                backgroundColor: Color(0x337b61ff),
                color: Color(0xff7b61ff),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('大小写', [
            _action(
              'toggle-case',
              _caseSensitive ? '切换为忽略大小写' : '切换为区分大小写',
              () => setState(() => _caseSensitive = !_caseSensitive),
            ),
            const SizedBox(height: 12),
            SemiHighlight(
              'Semi semi SEMI 都是同一个词的不同写法。',
              key: const ValueKey('case-highlight'),
              caseSensitive: _caseSensitive,
              searchWords: const [SemiHighlightWord('semi')],
            ),
          ]),
          const SizedBox(height: 40),
          _section('正则模式', [
            const SemiText(
              'autoEscape: false 时词条文本作为正则模式（Dart RegExp 语义）。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            const SemiHighlight(
              '当前版本 2.104.0，构建号 12345，欢迎使用 Semi Design。',
              key: ValueKey('regex-highlight'),
              autoEscape: false,
              searchWords: [
                SemiHighlightWord(r'\d+\.\d+\.\d+'),
                SemiHighlightWord(r'\d{4,}'),
              ],
            ),
            const SizedBox(height: 12),
            const SemiText(
              '开启转义后（默认）同样的词条按字面匹配，不再命中数字。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 8),
            const SemiHighlight(
              '当前版本 2.104.0，构建号 12345，欢迎使用 Semi Design。',
              key: ValueKey('literal-highlight'),
              searchWords: [SemiHighlightWord(r'\d+\.\d+\.\d+')],
            ),
          ]),
          const SizedBox(height: 40),
          _section('主题定制', [
            const SemiText(
              '局部主题：绿色背景、深绿文字、字重 900。',
              type: SemiTextType.secondary,
            ),
            const SizedBox(height: 12),
            const SemiHighlightTheme(
              data: SemiHighlightThemeData(
                colorHighlightTextBgDefault: Color(0xffd8f5d8),
                colorHighlightTextDefault: Color(0xff0a7a2f),
                fontHighlightTextFontWeight: FontWeight.w900,
              ),
              child: SemiHighlight(
                '主题定制只影响当前子树，其他区域保持默认。',
                key: ValueKey('theme-highlight'),
                searchWords: [SemiHighlightWord('主题定制')],
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('文本布局', [
            const SemiText('超出两行显示省略号，父级需要有限宽度。', type: SemiTextType.secondary),
            const SizedBox(height: 12),
            const SizedBox(
              width: 280,
              child: SemiHighlight(
                '这是一段较长的文本，用于演示多行高亮在有限宽度下的换行与省略行为，关键词在行内保持高亮样式。',
                key: ValueKey('ellipsis-highlight'),
                searchWords: [
                  SemiHighlightWord('多行高亮'),
                  SemiHighlightWord('关键词'),
                ],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
