import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Built-in text and accessibility labels for Semi Design components.
///
/// Use [of] from a widget's build context. Widgets outside [SemiApp] fall back
/// to Simplified Chinese; [SemiApp] installs [delegate] automatically.
abstract class SemiLocalizations {
  const SemiLocalizations();

  static const Locale zhCNLocale = Locale('zh', 'CN');
  static const Locale enUSLocale = Locale('en', 'US');
  static const List<Locale> supportedLocales = <Locale>[zhCNLocale, enUSLocale];

  static const LocalizationsDelegate<SemiLocalizations> delegate =
      _SemiLocalizationsDelegate();
  static const SemiLocalizations zhCN = _SemiZhCNLocalizations();
  static const SemiLocalizations enUS = _SemiEnUSLocalizations();

  static SemiLocalizations of(BuildContext context) =>
      Localizations.of<SemiLocalizations>(context, SemiLocalizations) ?? zhCN;

  static SemiLocalizations forLocale(Locale locale) =>
      locale.languageCode.toLowerCase() == 'en' ? enUS : zhCN;

  String get localeName;

  // Shared component text.
  String get close;
  String get cancel;
  String get noData;
  String get search;
  String get clear;
  String get confirm;
  String get ok;
  String get create;
  String get optional;
  String get imageCrop;

  // Date picker.
  List<String> get weekdays;
  List<String> get months;
  String get datePresets;
  String get dateBackToSelect;
  String monthTitle(int year, int month);
  String monthLabel(int month);
  String get previousYear;
  String get previousMonth;
  String get nextMonth;
  String get nextYear;
  String get chooseDate;
  String get changeDate;
  String get clearRangeDate;

  // Time picker.
  String get chooseTime;
  String get chooseTimeRange;
  String get beginTime;
  String get endTime;
  String get hour;
  String get minute;
  String get second;
  String get am;
  String get pm;
  String get defaultTimeFormat;
  String get defaultTimeFormat12Hours;
  String get timeRangeSeparator;

  // Pagination.
  String totalPages(int total);
  String pageSize(int size);
  String get jumpTo;
  String get page;
  String paginationPage(int current, int total);
  String get previousPage;
  String get nextPage;
  String get morePages;

  // Tree and selection components.
  String get filterTree;
  String get filterTreeSelect;
  String get clearTreeSelectValue;
  String get treeSelectLabel;
  String get cascaderLabel;
  String get clearCascaderValue;

  // Transfer.
  String get transferNoSearchResult;
  String get transferEmptyRight;
  String get transferSelectAll;
  String get transferClearSelectAll;
  String transferTotal(int total);
  String transferSelected(int total);

  // Upload.
  String get uploadMainText;
  String get uploadIllegalTips;
  String get uploadLegalTips;
  String get uploadRetry;
  String get uploadReplace;
  String get uploadSelectedFiles;
  String get uploadIllegalSize;
  String get uploadFailure;
  String get uploadProgress;
  String get uploadFileUnitKb;
  String get uploadFileUnitMb;

  // Feedback and image preview.
  String get feedbackPlaceholder;
  String get feedbackOptionalPlaceholder;
  String get feedbackSubmit;
  String get imagePrevious;
  String get imageNext;
  String get imageZoomOut;
  String get imageZoomIn;
  String get imageOriginalSize;
  String get imageFit;
  String get imageRotate;
  String get imageDownload;
  String imagePageOf(int current, int total);

  // Navigation, tabs and user guide.
  String get expandSidebar;
  String get collapseSidebar;
  String get tabsMore;
  String get guideSkip;
  String get guideNext;
  String get guidePrevious;
  String get guideFinish;

  // Modal and popconfirm.
  String get modalOk;
  String get popconfirmConfirm;

  // Accessibility labels.
  String get sideNavigation;
  String get breadcrumb;
  String get expandBreadcrumb;
  String previousCarouselItem(int index);
  String nextCarouselItem(int index);
  String get colorLabel;
  String get alphaLabel;
  String closeTag(String text);
  String get reorder;
  String get clearTagInput;
  String get avatarMore;
}

class _SemiZhCNLocalizations extends SemiLocalizations {
  const _SemiZhCNLocalizations();

  @override
  String get localeName => 'zh_CN';
  @override
  String get close => '关闭';
  @override
  String get cancel => '取消';
  @override
  String get noData => '暂无数据';
  @override
  String get search => '搜索';
  @override
  String get clear => '清空';
  @override
  String get confirm => '确认';
  @override
  String get ok => '确定';
  @override
  String get create => '创建';
  @override
  String get optional => '（可选）';
  @override
  String get imageCrop => '图片裁切';
  @override
  List<String> get weekdays => const ['日', '一', '二', '三', '四', '五', '六'];
  @override
  List<String> get months => const [
    '一月',
    '二月',
    '三月',
    '四月',
    '五月',
    '六月',
    '七月',
    '八月',
    '九月',
    '十月',
    '十一月',
    '十二月',
  ];
  @override
  String get datePresets => '快捷选择';
  @override
  String get dateBackToSelect => '返回选择日期';
  @override
  String monthTitle(int year, int month) => '$year年 $month月';
  @override
  String monthLabel(int month) => '$month月';
  @override
  String get previousYear => '上一年';
  @override
  String get previousMonth => '上个月';
  @override
  String get nextMonth => '下个月';
  @override
  String get nextYear => '下一年';
  @override
  String get chooseDate => '选择日期';
  @override
  String get changeDate => '更改日期';
  @override
  String get clearRangeDate => '清除日期范围';
  @override
  String get chooseTime => '请选择时间';
  @override
  String get chooseTimeRange => '请选择时间范围';
  @override
  String get beginTime => '开始时间';
  @override
  String get endTime => '结束时间';
  @override
  String get hour => '时';
  @override
  String get minute => '分';
  @override
  String get second => '秒';
  @override
  String get am => '上午';
  @override
  String get pm => '下午';
  @override
  String get defaultTimeFormat => 'HH:mm:ss';
  @override
  String get defaultTimeFormat12Hours => 'a h:mm:ss';
  @override
  String get timeRangeSeparator => ' ~ ';
  @override
  String totalPages(int total) => '总页数：$total';
  @override
  String pageSize(int size) => '每页条数：$size';
  @override
  String get jumpTo => '跳至';
  @override
  String get page => '页';
  @override
  String paginationPage(int current, int total) => '$current/$total';
  @override
  String get previousPage => '上一页';
  @override
  String get nextPage => '下一页';
  @override
  String get morePages => '更多页码';
  @override
  String get filterTree => '筛选树';
  @override
  String get filterTreeSelect => '筛选树形选择项';
  @override
  String get clearTreeSelectValue => '清除树形选择';
  @override
  String get treeSelectLabel => '树形选择';
  @override
  String get cascaderLabel => '级联选择';
  @override
  String get clearCascaderValue => '清除级联选择';
  @override
  String get transferNoSearchResult => '无搜索结果';
  @override
  String get transferEmptyRight => '暂无内容，可从左侧勾选';
  @override
  String get transferSelectAll => '全选';
  @override
  String get transferClearSelectAll => '取消全选';
  @override
  String transferTotal(int total) => '总个数：$total';
  @override
  String transferSelected(int total) => '已选个数：$total';
  @override
  String get uploadMainText => '点击上传文件或拖拽文件到这里';
  @override
  String get uploadIllegalTips => '不支持此类型文件';
  @override
  String get uploadLegalTips => '松手开始上传';
  @override
  String get uploadRetry => '重试';
  @override
  String get uploadReplace => '替换文件';
  @override
  String get uploadSelectedFiles => '已选择文件';
  @override
  String get uploadIllegalSize => '文件尺寸不合法';
  @override
  String get uploadFailure => '上传失败';
  @override
  String get uploadProgress => '正在上传文件';
  @override
  String get uploadFileUnitKb => 'KB';
  @override
  String get uploadFileUnitMb => 'MB';
  @override
  String get feedbackPlaceholder => '请提供更多反馈';
  @override
  String get feedbackOptionalPlaceholder => '请提供更多反馈（选填）';
  @override
  String get feedbackSubmit => '提交';
  @override
  String get imagePrevious => '上一张';
  @override
  String get imageNext => '下一张';
  @override
  String get imageZoomOut => '缩小';
  @override
  String get imageZoomIn => '放大';
  @override
  String get imageOriginalSize => '原始尺寸';
  @override
  String get imageFit => '适应页面';
  @override
  String get imageRotate => '旋转';
  @override
  String get imageDownload => '下载';
  @override
  String imagePageOf(int current, int total) => '$current/$total';
  @override
  String get expandSidebar => '展开侧边栏';
  @override
  String get collapseSidebar => '收起侧边栏';
  @override
  String get tabsMore => '更多';
  @override
  String get guideSkip => '跳过';
  @override
  String get guideNext => '下一步';
  @override
  String get guidePrevious => '上一步';
  @override
  String get guideFinish => '完成';
  @override
  String get modalOk => '确定';
  @override
  String get popconfirmConfirm => '确认';
  @override
  String get sideNavigation => '侧边导航';
  @override
  String get breadcrumb => '面包屑导航';
  @override
  String get expandBreadcrumb => '展开面包屑';
  @override
  String previousCarouselItem(int index) => '上一项 $index';
  @override
  String nextCarouselItem(int index) => '下一项 $index';
  @override
  String get colorLabel => '颜色';
  @override
  String get alphaLabel => '透明度';
  @override
  String closeTag(String text) => '关闭 $text';
  @override
  String get reorder => '重新排序';
  @override
  String get clearTagInput => '清除标签';
  @override
  String get avatarMore => '更多头像';
}

class _SemiEnUSLocalizations extends SemiLocalizations {
  const _SemiEnUSLocalizations();

  @override
  String get localeName => 'en_US';
  @override
  String get close => 'Close';
  @override
  String get cancel => 'Cancel';
  @override
  String get noData => 'No data';
  @override
  String get search => 'Search';
  @override
  String get clear => 'Clear';
  @override
  String get confirm => 'Confirm';
  @override
  String get ok => 'OK';
  @override
  String get create => 'Create';
  @override
  String get optional => '(Optional)';
  @override
  String get imageCrop => 'Crop image';
  @override
  List<String> get weekdays => const [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];
  @override
  List<String> get months => const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  @override
  String get datePresets => 'Presets';
  @override
  String get dateBackToSelect => 'Back to date selection';
  @override
  String monthTitle(int year, int month) => '${months[month - 1]} $year';
  @override
  String monthLabel(int month) => months[month - 1];
  @override
  String get previousYear => 'Previous year';
  @override
  String get previousMonth => 'Previous month';
  @override
  String get nextMonth => 'Next month';
  @override
  String get nextYear => 'Next year';
  @override
  String get chooseDate => 'Choose date';
  @override
  String get changeDate => 'Change date';
  @override
  String get clearRangeDate => 'Clear date range';
  @override
  String get chooseTime => 'Choose time';
  @override
  String get chooseTimeRange => 'Choose time range';
  @override
  String get beginTime => 'Start time';
  @override
  String get endTime => 'End time';
  @override
  String get hour => 'h';
  @override
  String get minute => 'm';
  @override
  String get second => 's';
  @override
  String get am => 'AM';
  @override
  String get pm => 'PM';
  @override
  String get defaultTimeFormat => 'HH:mm:ss';
  @override
  String get defaultTimeFormat12Hours => 'a h:mm:ss';
  @override
  String get timeRangeSeparator => ' ~ ';
  @override
  String totalPages(int total) => 'Total pages: $total';
  @override
  String pageSize(int size) => 'Page size: $size';
  @override
  String get jumpTo => 'Go to';
  @override
  String get page => 'page';
  @override
  String paginationPage(int current, int total) => '$current/$total';
  @override
  String get previousPage => 'Previous';
  @override
  String get nextPage => 'Next';
  @override
  String get morePages => 'More pages';
  @override
  String get filterTree => 'Filter tree';
  @override
  String get filterTreeSelect => 'Filter TreeSelect item';
  @override
  String get clearTreeSelectValue => 'Clear TreeSelect value';
  @override
  String get treeSelectLabel => 'TreeSelect';
  @override
  String get cascaderLabel => 'Cascader';
  @override
  String get clearCascaderValue => 'Clear Cascader value';
  @override
  String get transferNoSearchResult => 'No search results';
  @override
  String get transferEmptyRight => 'No content. Select items on the left.';
  @override
  String get transferSelectAll => 'Select all';
  @override
  String get transferClearSelectAll => 'Clear all';
  @override
  String transferTotal(int total) => 'Total: $total';
  @override
  String transferSelected(int total) => 'Selected: $total';
  @override
  String get uploadMainText => 'Click to upload or drag files here';
  @override
  String get uploadIllegalTips => 'Unsupported file type';
  @override
  String get uploadLegalTips => 'Release to upload';
  @override
  String get uploadRetry => 'Retry';
  @override
  String get uploadReplace => 'Replace file';
  @override
  String get uploadSelectedFiles => 'Selected files';
  @override
  String get uploadIllegalSize => 'Invalid file size';
  @override
  String get uploadFailure => 'Upload failed';
  @override
  String get uploadProgress => 'Uploading file';
  @override
  String get uploadFileUnitKb => 'KB';
  @override
  String get uploadFileUnitMb => 'MB';
  @override
  String get feedbackPlaceholder => 'Please provide more feedback';
  @override
  String get feedbackOptionalPlaceholder =>
      'Please provide more feedback (optional)';
  @override
  String get feedbackSubmit => 'Submit';
  @override
  String get imagePrevious => 'Previous';
  @override
  String get imageNext => 'Next';
  @override
  String get imageZoomOut => 'Zoom out';
  @override
  String get imageZoomIn => 'Zoom in';
  @override
  String get imageOriginalSize => 'Original size';
  @override
  String get imageFit => 'Fit to page';
  @override
  String get imageRotate => 'Rotate';
  @override
  String get imageDownload => 'Download';
  @override
  String imagePageOf(int current, int total) => '$current/$total';
  @override
  String get expandSidebar => 'Expand sidebar';
  @override
  String get collapseSidebar => 'Collapse sidebar';
  @override
  String get tabsMore => 'More';
  @override
  String get guideSkip => 'Skip';
  @override
  String get guideNext => 'Next';
  @override
  String get guidePrevious => 'Previous';
  @override
  String get guideFinish => 'Finish';
  @override
  String get modalOk => 'OK';
  @override
  String get popconfirmConfirm => 'Confirm';
  @override
  String get sideNavigation => 'Side navigation';
  @override
  String get breadcrumb => 'Breadcrumb';
  @override
  String get expandBreadcrumb => 'Expand breadcrumb items';
  @override
  String previousCarouselItem(int index) => 'Previous index $index';
  @override
  String nextCarouselItem(int index) => 'Next index $index';
  @override
  String get colorLabel => 'Color';
  @override
  String get alphaLabel => 'Alpha';
  @override
  String closeTag(String text) => 'Close $text';
  @override
  String get reorder => 'Reorder';
  @override
  String get clearTagInput => 'Clear TagInput value';
  @override
  String get avatarMore => 'More avatars';
}

class _SemiLocalizationsDelegate
    extends LocalizationsDelegate<SemiLocalizations> {
  const _SemiLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'zh' || locale.languageCode == 'en';

  @override
  Future<SemiLocalizations> load(Locale locale) =>
      SynchronousFuture<SemiLocalizations>(SemiLocalizations.forLocale(locale));

  @override
  bool shouldReload(_SemiLocalizationsDelegate old) => false;
}
