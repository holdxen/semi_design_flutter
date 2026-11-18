import 'package:example/pages/anchor.dart';
import 'package:example/pages/backtop.dart';
import 'package:example/pages/autocomplete.dart';
import 'package:example/pages/avatar.dart';
import 'package:example/pages/badge.dart';
import 'package:example/pages/banner.dart';
import 'package:example/pages/border_beam.dart';
import 'package:example/pages/breadcrumb.dart';
import 'package:example/pages/button.dart';
import 'package:example/pages/cascader.dart';
import 'package:example/pages/card.dart';
import 'package:example/pages/carousel.dart';
import 'package:example/pages/semi_chrome_tab.dart';
import 'package:example/pages/checkbox.dart';
import 'package:example/pages/collapse.dart';
import 'package:example/pages/collapsible.dart';
import 'package:example/pages/color_picker.dart';
import 'package:example/pages/cropper.dart';
import 'package:example/pages/date_picker.dart';
import 'package:example/pages/descriptions.dart';
import 'package:example/pages/divider.dart';
import 'package:example/pages/dropdown.dart';
import 'package:example/pages/empty.dart';
import 'package:example/pages/feedback.dart';
import 'package:example/pages/float_button.dart';
import 'package:example/pages/highlight.dart';
import 'package:example/pages/image.dart';
import 'package:example/pages/form.dart';
import 'package:example/pages/input.dart';
import 'package:example/pages/input_number.dart';
import 'package:example/pages/modal.dart';
import 'package:example/pages/navigation.dart';
import 'package:example/pages/notification.dart';
import 'package:example/pages/overflow_list.dart';
import 'package:example/pages/pagination.dart';
import 'package:example/pages/pincode.dart';
import 'package:example/pages/popover.dart';
import 'package:example/pages/popconfirm.dart';
import 'package:example/pages/progress.dart';
import 'package:example/pages/radio.dart';
import 'package:example/pages/rating.dart';
import 'package:example/pages/scroll_list.dart';
import 'package:example/pages/select.dart';
import 'package:example/pages/side_sheet.dart';
import 'package:example/pages/skeleton.dart';
import 'package:example/pages/slider.dart';
import 'package:example/pages/spin.dart';
import 'package:example/pages/steps.dart';
import 'package:example/pages/switch.dart';
import 'package:example/pages/tabs.dart';
import 'package:example/pages/tag.dart';
import 'package:example/pages/tag_input.dart';
import 'package:example/pages/time_picker.dart';
import 'package:example/pages/timeline.dart';
import 'package:example/pages/toast.dart';
import 'package:example/pages/tooltip.dart';
import 'package:example/pages/tree.dart';
import 'package:example/pages/tree_select.dart';
import 'package:example/pages/typography.dart';
import 'package:example/pages/user_guide.dart';
import 'package:example/pages/upload.dart';
import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// 示例主题模式——顶栏 Switch 切换明亮/暗黑。
  SemiThemeMode _themeMode = SemiThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return SemiApp(
      themeMode: _themeMode,
      home: SafeArea(
        child: DemoShell(
          themeMode: _themeMode,
          onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
        ),
      ),
    );
  }
}

/// 示例注册表。
///
/// 图标抄自官方示例侧栏（semi-design `src/images/docIcons/doc-*.svg`），
/// 分组/顺序/标题照官方侧栏（`content/<分类>/<组件>/index.md` frontmatter 的
/// category/order/title，分类序取 `src/utils/category.js` itemsArr）。
class DemoSpec {
  const DemoSpec(this.key, this.title, this.icon, this.page);

  /// 导航 itemKey。
  final String key;

  /// 官方侧栏标题（如 `Button 按钮`）。
  final String title;

  /// 官方侧栏图标文件名（`assets/doc_icons/`）。
  final String icon;

  /// 示例页。
  final Widget page;
}

/// 官方侧栏分类（itemsArr 序）。
class DemoGroup {
  const DemoGroup(this.label, this.demos);

  final String label;
  final List<DemoSpec> demos;
}

const List<DemoGroup> demoGroups = [
  DemoGroup('基础', [
    DemoSpec('button', 'Button 按钮', 'doc-button.svg', ButtonPage()),
    DemoSpec(
      'typography',
      'Typography 版式',
      'doc-typography.svg',
      TypographyPage(),
    ),
    DemoSpec('divider', 'Divider 分割线', 'doc-divider.svg', DividerPage()),
    DemoSpec(
      'floatButton',
      'FloatButton 悬浮按钮',
      'doc-floatButton.svg',
      FloatButtonPage(),
    ),
  ]),
  // 官方侧栏 itemsArr：基础 → Plus 组件 → 输入类。
  DemoGroup('Plus 组件', [
    DemoSpec('cropper', 'Cropper 图片裁切', 'doc-cropper.svg', CropperPage()),
  ]),
  DemoGroup('输入类', [
    DemoSpec(
      'autocomplete',
      'AutoComplete 自动完成',
      'doc-autocomplete.svg',
      AutoCompletePage(),
    ),
    DemoSpec('cascader', 'Cascader 级联选择', 'doc-cascader.svg', CascaderPage()),
    DemoSpec('checkbox', 'Checkbox 复选框', 'doc-checkbox.svg', CheckboxPage()),
    DemoSpec(
      'colorPicker',
      'ColorPicker 颜色选择器',
      'doc-colorPlatteNew.svg',
      ColorPickerPage(),
    ),
    DemoSpec(
      'datePicker',
      'DatePicker 日期选择器',
      'doc-datepicker.svg',
      DatePickerPage(),
    ),
    DemoSpec('form', 'Form 表单', 'doc-form.svg', FormPage()),
    DemoSpec('input', 'Input 输入框', 'doc-input.svg', InputPage()),
    DemoSpec(
      'inputNumber',
      'InputNumber 数字输入框',
      'doc-inputnumber.svg',
      InputNumberPage(),
    ),
    DemoSpec('pinCode', 'PinCode 验证码输入', 'doc-pincode.svg', PinCodePage()),
    DemoSpec('radio', 'Radio 单选框', 'doc-radio.svg', RadioPage()),
    DemoSpec('rating', 'Rating 评分', 'doc-rating.svg', RatingPage()),
    DemoSpec('select', 'Select 选择器', 'doc-select.svg', SelectPage()),
    DemoSpec('slider', 'Slider 滑动选择器', 'doc-slider.svg', SliderPage()),
    DemoSpec('switch', 'Switch 开关', 'doc-switch.svg', SwitchPage()),
    DemoSpec('tagInput', 'TagInput 标签输入框', 'doc-tagInput.svg', TagInputPage()),
    DemoSpec(
      'timePicker',
      'TimePicker 时间选择器',
      'doc-timepicker.svg',
      TimePickerPage(),
    ),
    DemoSpec('upload', 'Upload 上传', 'doc-upload.svg', UploadPage()),
  ]),
  DemoGroup('导航类', [
    DemoSpec('anchor', 'Anchor 锚点', 'doc-anchor.svg', AnchorPage()),
    DemoSpec('backTop', 'BackTop 回到顶部', 'doc-backtop.svg', BackTopPage()),
    DemoSpec(
      'breadcrumb',
      'Breadcrumb 面包屑',
      'doc-breadcrumb.svg',
      BreadcrumbPage(),
    ),
    DemoSpec(
      'navigation',
      'Navigation 导航',
      'doc-navigation.svg',
      NavigationPage(),
    ),
    DemoSpec(
      'pagination',
      'Pagination 翻页器',
      'doc-pagination.svg',
      PaginationPage(),
    ),
    DemoSpec('steps', 'Steps 步骤', 'doc-steps.svg', StepsPage()),
    DemoSpec('tabs', 'Tabs 标签栏', 'doc-tabs.svg', TabsPage()),
    DemoSpec(
      'chromeTab',
      'SemiChromeTab 浏览器标签',
      'doc-tabs.svg',
      SemiChromeTabPage(),
    ),
    DemoSpec('tree', 'Tree 树形控件', 'doc-tree.svg', TreePage()),
    DemoSpec('treeSelect', 'TreeSelect 树选择器', 'doc-tree.svg', TreeSelectPage()),
  ]),
  DemoGroup('展示类', [
    DemoSpec('avatar', 'Avatar 头像', 'doc-avatar.svg', AvatarPage()),
    DemoSpec('badge', 'Badge 徽标', 'doc-badge.svg', BadgePage()),
    DemoSpec('banner', 'Banner 通知横幅', 'doc-banner.svg', BannerPage()),
    DemoSpec('borderBeam', 'BorderBeam 边框光束', 'doc-card.svg', BorderBeamPage()),
    DemoSpec('card', 'Card 卡片', 'doc-card.svg', CardPage()),
    DemoSpec('carousel', 'Carousel 轮播图', 'doc-carousel.svg', CarouselPage()),
    DemoSpec('collapse', 'Collapse 折叠面板', 'doc-accordion.svg', CollapsePage()),
    DemoSpec(
      'collapsible',
      'Collapsible 折叠',
      'doc-collapsible.svg',
      CollapsiblePage(),
    ),
    DemoSpec(
      'descriptions',
      'Descriptions 描述列表',
      'doc-descriptions.svg',
      DescriptionsPage(),
    ),
    DemoSpec('dropdown', 'Dropdown 下拉框', 'doc-dropdown.svg', DropdownPage()),
    DemoSpec('empty', 'Empty 空状态', 'doc-empty.svg', EmptyPage()),
    DemoSpec(
      'highlight',
      'Highlight 高亮文本',
      'doc-highlight.svg',
      HighlightPage(),
    ),
    DemoSpec('image', 'Image 图片', 'doc-image.svg', ImagePage()),
    DemoSpec('modal', 'Modal 模态对话框', 'doc-modal.svg', ModalPage()),
    DemoSpec(
      'sideSheet',
      'SideSheet 侧边栏',
      'doc-sideSheet.svg',
      SideSheetPage(),
    ),
    DemoSpec(
      'overflowList',
      'OverflowList 折叠列表',
      'doc-overflowList.svg',
      OverflowListPage(),
    ),
    DemoSpec(
      'scrollList',
      'ScrollList 滚动列表',
      'doc-scrolllist.svg',
      ScrollListPage(),
    ),
    DemoSpec('tag', 'Tag 标签', 'doc-tag.svg', TagPage()),
    DemoSpec('timeline', 'Timeline 时间轴', 'doc-timeline.svg', TimelinePage()),
    DemoSpec('tooltip', 'Tooltip 工具提示', 'doc-tooltip.svg', TooltipPage()),
  ]),
  DemoGroup('反馈类', [
    DemoSpec('feedback', 'Feedback 反馈收集', 'doc-feedback.svg', FeedbackPage()),
    DemoSpec(
      'notification',
      'Notification 通知',
      'doc-notification.svg',
      NotificationPage(),
    ),
    DemoSpec('popover', 'Popover 气泡卡片', 'doc-popover.svg', PopoverPage()),
    DemoSpec(
      'popconfirm',
      'Popconfirm 气泡确认框',
      'doc-popconfirm.svg',
      PopconfirmPage(),
    ),
    DemoSpec('progress', 'Progress 进度条', 'doc-progress.svg', ProgressPage()),
    DemoSpec('skeleton', 'Skeleton 骨架屏', 'doc-skeleton.svg', SkeletonPage()),
    DemoSpec('spin', 'Spin 加载器', 'doc-spin.svg', SpinPage()),
    DemoSpec('toast', 'Toast 轻提示', 'doc-toast.svg', ToastPage()),
    DemoSpec(
      'userGuide',
      'UserGuide 用户引导',
      'doc-userGuide.svg',
      UserGuidePage(),
    ),
  ]),
];

DemoSpec _specOf(String key) {
  for (final group in demoGroups) {
    for (final demo in group.demos) {
      if (demo.key == key) return demo;
    }
  }
  return demoGroups.first.demos.first;
}

/// 示例基座：左侧 SemiNavigation 切换右侧示例页。
class DemoShell extends StatefulWidget {
  const DemoShell({
    super.key,
    this.themeMode = SemiThemeMode.light,
    this.onThemeModeChanged,
  });

  /// 当前主题模式（顶栏 Switch 受控渲染）。
  final SemiThemeMode themeMode;

  /// 主题切换回调。
  final ValueChanged<SemiThemeMode>? onThemeModeChanged;

  @override
  State<DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<DemoShell> {
  String _selected = demoGroups.first.demos.first.key;

  /// 搜索关键词（对标题/itemKey 做子串过滤侧栏条目）。
  String _query = '';

  /// 折叠态受控——侧栏搜索行宽度跟随 widthNavigationContainer* 同步收放。
  bool _collapsed = false;

  /// 与 SemiNavigation 默认 `motionNavigationWidth`
  /// （`width 200ms cubic-bezier(.62, .05, .36, .95)`）对齐——外层侧栏宽度
  /// 动画必须和导航自身的折叠 motion 同步（简写解析器在库内私有）。
  static const Duration _navMotionDuration = Duration(milliseconds: 200);
  static const Curve _navMotionCurve = Cubic(0.62, 0.05, 0.36, 0.95);

  /// 展开键受控——搜索过滤后自动展开命中分组，保证结果可见。
  List<Object> _openKeys = [for (final g in demoGroups) 'group-${g.label}'];

  SemiIcon _icon(String file) =>
      SemiIcon.asset('assets/doc_icons/$file', customSize: 20);

  bool _matches(DemoSpec demo) {
    final q = _query.trim().toLowerCase();
    return q.isEmpty ||
        demo.title.toLowerCase().contains(q) ||
        demo.key.toLowerCase().contains(q);
  }

  /// 过滤后的分组（空分组丢弃）。
  List<DemoGroup> get _filteredGroups => [
    for (final group in demoGroups)
      if (group.demos.any(_matches))
        DemoGroup(group.label, [
          for (final demo in group.demos)
            if (_matches(demo)) demo,
        ]),
  ];

  List<Object> _navItems(List<DemoGroup> groups) => [
    for (final group in groups)
      SemiNavigationItem(
        itemKey: 'group-${group.label}',
        text: group.label,
        items: [
          for (final demo in group.demos)
            SemiNavigationItem(
              itemKey: demo.key,
              text: demo.title,
              icon: _icon(demo.icon),
            ),
        ],
      ),
  ];

  void _onSearchChanged(String text) {
    setState(() {
      _query = text;
      // 命中分组全部展开。
      _openKeys = [for (final g in _filteredGroups) 'group-${g.label}'];
    });
  }

  Widget _searchInput() => SemiInput(
    key: const ValueKey('demo-search'),
    placeholder: '搜索组件',
    size: SemiInputSize.small,
    prefix: SemiIcon(SemiIcons.search),
    showClear: true,
    onChanged: _onSearchChanged,
    onClear: () => _onSearchChanged(''),
  );

  Widget _themeSwitch() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('暗黑模式'),
      const SizedBox(width: 8),
      SemiSwitch(
        checked: widget.themeMode == SemiThemeMode.dark,
        onChanged: (dark) => widget.onThemeModeChanged?.call(
          dark ? SemiThemeMode.dark : SemiThemeMode.light,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final groups = _filteredGroups;
    // 侧栏搜索行宽度对齐导航容器（折叠态同步收缩/隐藏）。
    final theme = SemiTheme.of(context);
    final navTheme = theme.components.navigation.resolve(theme);
    final navWidth = _collapsed
        ? navTheme.widthNavigationContainerCollapsed
        : navTheme.widthNavigationContainerBase;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ★SemiNavigation 自身按 motionNavigationWidth 动画宽度；外层若用
        // SizedBox 直接把宽度切成目标值，会以紧约束覆盖导航内部的宽度动画
        // （折叠/展开变瞬时）。这里改用同一 motion 驱动外层，搜索行一并收放。
        AnimatedContainer(
          width: navWidth,
          duration: _navMotionDuration,
          curve: _navMotionCurve,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedSize(
                duration: _navMotionDuration,
                curve: _navMotionCurve,
                alignment: Alignment.topCenter,
                child: _collapsed
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                        child: _searchInput(),
                      ),
              ),
              // 基座 SemiNavigation：条目区内部滚动（_buildList 的
              // SingleChildScrollView），头/尾贴上下——需要有界高度，
              // stretch 铺满行高。
              Expanded(
                child: SemiNavigation(
                  selectedKeys: [_selected],
                  openKeys: _openKeys,
                  isCollapsed: _collapsed,
                  onCollapseChange: (v) => setState(() => _collapsed = v),
                  onOpenChange: (info) =>
                      setState(() => _openKeys = info.openKeys),
                  onSelect: (info) =>
                      setState(() => _selected = info.itemKey as String),
                  header: SemiNavigationHeader(
                    logo: SemiIcon.asset(
                      'assets/semi-logo.svg',
                      customSize: 36,
                    ),
                    text: 'Semi Design',
                  ),
                  footer: const SemiNavigationFooter(collapseButton: true),
                  items: groups.isEmpty
                      ? [
                          const SemiNavigationItem(
                            itemKey: 'no-match',
                            text: '无匹配组件',
                            disabled: true,
                          ),
                        ]
                      : _navItems(groups),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              // 顶栏：明亮/暗黑主题切换。
              Padding(
                padding: const EdgeInsets.all(8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _themeSwitch(),
                ),
              ),
              Expanded(
                child: KeyedSubtree(
                  key: ValueKey(_selected),
                  child: _specOf(_selected).page,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
