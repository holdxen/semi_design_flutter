import 'package:example/pages/anchor.dart';
import 'package:example/pages/autocomplete.dart';
import 'package:example/pages/breadcrumb.dart';
import 'package:example/pages/button.dart';
import 'package:example/pages/card.dart';
import 'package:example/pages/carousel.dart';
import 'package:example/pages/checkbox.dart';
import 'package:example/pages/collapse.dart';
import 'package:example/pages/color_picker.dart';
import 'package:example/pages/date_picker.dart';
import 'package:example/pages/descriptions.dart';
import 'package:example/pages/divider.dart';
import 'package:example/pages/dropdown.dart';
import 'package:example/pages/empty.dart';
import 'package:example/pages/highlight.dart';
import 'package:example/pages/input.dart';
import 'package:example/pages/input_number.dart';
import 'package:example/pages/modal.dart';
import 'package:example/pages/navigation.dart';
import 'package:example/pages/pagination.dart';
import 'package:example/pages/pincode.dart';
import 'package:example/pages/progress.dart';
import 'package:example/pages/radio.dart';
import 'package:example/pages/rating.dart';
import 'package:example/pages/select.dart';
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
import 'package:example/pages/tooltip.dart';
import 'package:example/pages/tree.dart';
import 'package:example/pages/typography.dart';
import 'package:example/pages/upload.dart';
import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const SemiApp(
      themeMode: SemiThemeMode.light,
      home: SafeArea(child: DemoShell()),
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
  ]),
  DemoGroup('输入类', [
    DemoSpec(
      'autocomplete',
      'AutoComplete 自动完成',
      'doc-autocomplete.svg',
      AutoCompletePage(),
    ),
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
    DemoSpec('tree', 'Tree 树形控件', 'doc-tree.svg', TreePage()),
  ]),
  DemoGroup('展示类', [
    DemoSpec('card', 'Card 卡片', 'doc-card.svg', CardPage()),
    DemoSpec('carousel', 'Carousel 轮播图', 'doc-carousel.svg', CarouselPage()),
    DemoSpec('collapse', 'Collapse 折叠面板', 'doc-accordion.svg', CollapsePage()),
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
    DemoSpec('modal', 'Modal 模态对话框', 'doc-modal.svg', ModalPage()),
    DemoSpec('tag', 'Tag 标签', 'doc-tag.svg', TagPage()),
    DemoSpec('timeline', 'Timeline 时间轴', 'doc-timeline.svg', TimelinePage()),
    DemoSpec('tooltip', 'Tooltip 工具提示', 'doc-tooltip.svg', TooltipPage()),
  ]),
  DemoGroup('反馈类', [
    DemoSpec('progress', 'Progress 进度条', 'doc-progress.svg', ProgressPage()),
    DemoSpec('skeleton', 'Skeleton 骨架屏', 'doc-skeleton.svg', SkeletonPage()),
    DemoSpec('spin', 'Spin 加载器', 'doc-spin.svg', SpinPage()),
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
  const DemoShell({super.key});

  @override
  State<DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<DemoShell> {
  String _selected = demoGroups.first.demos.first.key;

  SemiIcon _icon(String file) =>
      SemiIcon.asset('assets/doc_icons/$file', customSize: 20);

  List<Object> _navItems() => [
    for (final group in demoGroups)
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

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 基座 SemiNavigation：条目区内部滚动（_buildList 的 SingleChildScrollView），
        // 头/尾贴上下——需要有界高度，stretch 铺满行高。
        SemiNavigation(
          selectedKeys: [_selected],
          defaultOpenKeys: [for (final g in demoGroups) 'group-${g.label}'],
          onSelect: (info) =>
              setState(() => _selected = info.itemKey as String),
          header: SemiNavigationHeader(
            logo: SemiIcon.asset('assets/semi-logo.svg', customSize: 36),
            text: 'Semi Design',
          ),
          footer: const SemiNavigationFooter(collapseButton: true),
          items: _navItems(),
        ),
        Expanded(
          child: KeyedSubtree(
            key: ValueKey(_selected),
            child: _specOf(_selected).page,
          ),
        ),
      ],
    );
  }
}
