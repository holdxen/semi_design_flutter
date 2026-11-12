import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

class AutoCompletePage extends StatefulWidget {
  const AutoCompletePage({super.key});

  @override
  State<AutoCompletePage> createState() => _AutoCompletePageState();
}

/// One contact of the custom-render demo (upstream example data).
class _Contact {
  const _Contact(this.name, this.email, this.abbr, this.color);

  final String name;
  final String email;
  final String abbr;
  final Color color;
}

class _AutoCompletePageState extends State<AutoCompletePage> {
  String _status = '在输入框内键入内容或选择候选项查看事件。';

  // -- 基本用法（受控） --
  List<SemiAutoCompleteOption> _basicData = const [];
  String _basicValue = '';

  // -- 自定义候选项渲染 --
  static const List<_Contact> _contacts = [
    _Contact('夏可漫', 'xiakeman@example.com', 'XK', Color(0xfffaad14)),
    _Contact('申悦', 'shenyue@example.com', 'SY', Color(0xff5457ed)),
    _Contact('曲晨一', 'quchenyi@example.com', 'CY', Color(0xff2ba4e8)),
    _Contact('文嘉茂', 'wenjiamao@example.com', 'JM', Color(0xff0bb4c4)),
  ];
  List<SemiAutoCompleteOption> _contactData = const [];

  // -- 远程搜索 --
  static const List<(SemiIconData, String, String)> _remoteItems = [
    (SemiIcons.star, 'star', '收藏'),
    (SemiIcons.mail, 'mail', '邮件'),
    (SemiIcons.user, 'user', '用户'),
    (SemiIcons.calendar, 'calendar', '日历'),
    (SemiIcons.comment, 'comment', '评论'),
  ];
  Timer? _remoteDebounce;
  Timer? _remoteLatency;
  bool _remoteLoading = false;
  List<SemiAutoCompleteOption> _remoteData = const [];
  String _remoteStatus = '远程搜索：200ms 防抖 + 1s 模拟请求。';

  // -- 自定义空内容 --
  Timer? _emptyLatency;
  bool _emptyLoading = false;
  List<SemiAutoCompleteOption> _emptyData = const [];
  final Random _random = Random();

  @override
  void dispose() {
    _remoteDebounce?.cancel();
    _remoteLatency?.cancel();
    _emptyLatency?.cancel();
    super.dispose();
  }

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SemiTitle(title, heading: 3),
      const SizedBox(height: 16),
      ...children,
    ],
  );

  Widget _row(List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final child in children) ...[child, const SizedBox(height: 12)],
    ],
  );

  // -- 基本用法：受控 value + onSearch 更新 data（邮箱域名补全） --

  void _handleBasicSearch(String input) {
    setState(() {
      _basicData = input.isEmpty
          ? const []
          : [
              for (final domain in ['gmail.com', '163.com', 'qq.com'])
                SemiAutoCompleteOption(value: '$input@$domain'),
            ];
    });
  }

  // -- 自定义候选项渲染：对象数据 + renderItem + renderSelectedItem --

  static _Contact _contactOf(Object value) => _contacts.firstWhere(
    (c) => c.name == value,
    orElse: () => _contacts.first,
  );

  void _handleContactSearch(String input) {
    setState(() {
      // Upstream demo: any input shows all candidates, empty input hides them.
      _contactData = input.isEmpty
          ? const []
          : [
              for (final c in _contacts)
                SemiAutoCompleteOption(value: c.name, text: c.name),
            ];
    });
  }

  Widget _contactRow(SemiAutoCompleteOption option) {
    final c = _contactOf(option.value);
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: c.color, shape: BoxShape.circle),
          child: SemiText(
            c.abbr,
            style: const TextStyle(fontSize: 10, color: Color(0xffffffff)),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SemiText(c.name, style: const TextStyle(fontSize: 14)),
            SemiText(
              c.email,
              style: const TextStyle(fontSize: 12, color: Color(0xff8a8f99)),
            ),
          ],
        ),
      ],
    );
  }

  // -- 远程搜索：200ms 防抖 + 1s 模拟请求 --

  void _handleRemoteSearch(String input) {
    _remoteDebounce?.cancel();
    _remoteDebounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() => _remoteLoading = true);
      _remoteLatency?.cancel();
      _remoteLatency = Timer(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() {
          _remoteData = [
            for (final (_, value, label) in _remoteItems)
              if (input.isEmpty || value.contains(input))
                SemiAutoCompleteOption(value: value, text: label),
          ];
          _remoteLoading = false;
        });
      });
    });
  }

  Widget _remoteRow(SemiAutoCompleteOption option) {
    for (final (icon, value, label) in _remoteItems) {
      if (value == option.value) {
        return Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: SemiIcon(icon, size: SemiIconSize.large),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SemiText(value, style: const TextStyle(fontSize: 14)),
                SemiText(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff8a8f99),
                  ),
                ),
              ],
            ),
          ],
        );
      }
    }
    return const SizedBox.shrink();
  }

  // -- 自定义空内容：1s 模拟请求，空输入返回空数据 --

  void _handleEmptySearch(String input) {
    _emptyLatency?.cancel();
    setState(() => _emptyLoading = true);
    _emptyLatency = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _emptyData = input.isEmpty
            ? const []
            : [
                for (var i = 0; i < 5; i++)
                  SemiAutoCompleteOption(value: _random.nextInt(9000) + 1000),
              ];
        _emptyLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('基本用法', [
            SemiText(_status, key: const ValueKey('autocomplete-status')),
            const SizedBox(height: 12),
            SizedBox(
              width: 220,
              child: SemiAutoComplete(
                key: const ValueKey('autocomplete-basic'),
                data: _basicData,
                value: _basicValue,
                showClear: true,
                prefix: const SemiIcon(SemiIcons.search),
                placeholder: '搜索...',
                onSearch: _handleBasicSearch,
                onChanged: (text) => setState(() => _basicValue = text),
                onSelect: (option) =>
                    setState(() => _status = '选中了「${option.value}」。'),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('自定义候选项渲染', [
            SizedBox(
              width: 280,
              child: SemiAutoComplete(
                key: const ValueKey('autocomplete-custom'),
                data: _contactData,
                showClear: true,
                prefix: const SemiIcon(SemiIcons.search),
                placeholder: '搜索联系人',
                onSearch: _handleContactSearch,
                renderItem: _contactRow,
                renderSelectedItem: (option) => _contactOf(option.value).email,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('远程搜索', [
            SemiText(
              _remoteStatus,
              key: const ValueKey('autocomplete-remote-status'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 250,
              child: SemiAutoComplete(
                key: const ValueKey('autocomplete-remote'),
                data: _remoteData,
                loading: _remoteLoading,
                prefix: const SemiIcon(SemiIcons.search),
                placeholder: '搜索组件',
                onSearch: _handleRemoteSearch,
                renderItem: _remoteRow,
                renderSelectedItem: (option) => option.value.toString(),
                onSelect: (option) =>
                    setState(() => _remoteStatus = '远程选中了「${option.value}」。'),
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('尺寸', [
            _row([
              SizedBox(
                width: 200,
                child: SemiAutoComplete(
                  key: const ValueKey('autocomplete-small'),
                  data: const [
                    SemiAutoCompleteOption(value: 1),
                    SemiAutoCompleteOption(value: 2),
                    SemiAutoCompleteOption(value: 3),
                    SemiAutoCompleteOption(value: 4),
                  ],
                  size: SemiInputSize.small,
                  placeholder: 'small',
                ),
              ),
              SizedBox(
                width: 200,
                child: SemiAutoComplete(
                  key: const ValueKey('autocomplete-normal'),
                  data: const [
                    SemiAutoCompleteOption(value: 1),
                    SemiAutoCompleteOption(value: 2),
                    SemiAutoCompleteOption(value: 3),
                    SemiAutoCompleteOption(value: 4),
                  ],
                  size: SemiInputSize.normal,
                  placeholder: 'default',
                ),
              ),
              SizedBox(
                width: 200,
                child: SemiAutoComplete(
                  key: const ValueKey('autocomplete-large'),
                  data: const [
                    SemiAutoCompleteOption(value: 1),
                    SemiAutoCompleteOption(value: 2),
                    SemiAutoCompleteOption(value: 3),
                    SemiAutoCompleteOption(value: 4),
                  ],
                  size: SemiInputSize.large,
                  placeholder: 'large',
                ),
              ),
            ]),
          ]),
          const SizedBox(height: 40),
          _section('下拉菜单的位置', [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 200,
                  child: SemiAutoComplete(
                    key: const ValueKey('autocomplete-position-top'),
                    data: _basicData,
                    position: SemiTooltipPosition.top,
                    placeholder: '选项菜单在上方显示',
                    onSearch: _handleBasicSearch,
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: SemiAutoComplete(
                    key: const ValueKey('autocomplete-position-right'),
                    data: _basicData,
                    position: SemiTooltipPosition.rightTop,
                    placeholder: '选项菜单在右侧显示',
                    onSearch: _handleBasicSearch,
                  ),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          _section('禁用', [
            SizedBox(
              width: 200,
              child: SemiAutoComplete(
                key: const ValueKey('autocomplete-disabled'),
                data: const [
                  SemiAutoCompleteOption(value: 1),
                  SemiAutoCompleteOption(value: 2),
                  SemiAutoCompleteOption(value: 3),
                  SemiAutoCompleteOption(value: 4),
                ],
                placeholder: '禁用下拉菜单',
                disabled: true,
              ),
            ),
          ]),
          const SizedBox(height: 40),
          _section('校验状态', [
            _row([
              SizedBox(
                width: 280,
                child: SemiAutoComplete(
                  key: const ValueKey('autocomplete-warning'),
                  initialValue: 'ies',
                  validateStatus: SemiInputStatus.warning,
                ),
              ),
              SizedBox(
                width: 280,
                child: SemiAutoComplete(
                  key: const ValueKey('autocomplete-error'),
                  initialValue: 'ies',
                  validateStatus: SemiInputStatus.error,
                ),
              ),
              SizedBox(
                width: 280,
                child: SemiAutoComplete(
                  key: const ValueKey('autocomplete-normal-status'),
                  initialValue: 'ies',
                ),
              ),
            ]),
          ]),
          const SizedBox(height: 40),
          _section('自定义空内容', [
            SizedBox(
              width: 280,
              child: SemiAutoComplete(
                key: const ValueKey('autocomplete-empty'),
                data: _emptyData,
                loading: _emptyLoading,
                placeholder: '搜索（空结果显示自定义空内容）',
                emptyContent: const SizedBox(
                  width: 300,
                  child: SemiEmpty(
                    image: SemiIllustration(
                      SemiIllustrations.noContent,
                      dark: SemiIllustrations.noContentDark,
                    ),
                    description: '暂无内容',
                    padding: EdgeInsets.all(12),
                  ),
                ),
                onSearch: _handleEmptySearch,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
