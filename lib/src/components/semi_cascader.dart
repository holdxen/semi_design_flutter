// SemiCascader — 级联选择（Semi Design 组件移植）。
//
// 上游：packages/semi-foundation/cascader/{variables.scss, animation.scss,
// cascader.scss, rtl.scss, constants.ts, foundation.ts, util.ts}、
// packages/semi-ui/cascader/{index.tsx, item.tsx} + zh_CN.ts locale。
// 主题对账 115 = 112 FIELDS + 3 MOTION + 0 INTERNAL
// （tool/generate_cascader.py）——★2 死变量（上游未消费：
// `$color-cascader_label-text-default`、`$font-cascader_label-fontWeight`
// 仅在 variables.scss 自身声明处出现，照 select 先例保留字段不消费，docs 标注）。
//
// 触发器（cascader.scss 状态矩阵）消费 SemiCascaderThemeData；弹层多列菜单
// （item.tsx 行渲染）同样消费 SemiCascaderThemeData。勾选级联语义与
// [SemiTree] 同源（treeUtil.ts calcCheckedKeys* / normalizeKeyList）。
//
// HARDCODES（另列）上游片段以注释逐字留档在 `_CascaderMetrics` / 调用点，
// 生成器 HARDCODES 锚点断言这些片段出现在本文件。
import '../overlay/tooltip_positioning.dart';

import 'package:flutter/rendering.dart' show RenderProxyBox;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/semi_cascader_theme.dart';
import '../theme/semi_cascader_theme_data.dart';
import '../theme/semi_icon_theme.dart';
import '../theme/semi_theme.dart';
import '../theme/semi_theme_data.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icons.dart';
import 'semi_checkbox.dart';
import 'semi_input.dart';
import 'semi_spin.dart';
import 'semi_tag.dart';
import 'semi_tooltip.dart';

/// 展开下一级的方式（上游 `showNext`：constants.ts:13-14
/// `SHOW_NEXT_BY_CLICK: 'click'` / `SHOW_NEXT_BY_HOVER: 'hover'`）。
enum SemiCascaderShowNext { click, hover }

/// 触发器内搜索框位置（上游 `searchPosition`：constants.ts:19-20
/// `SEARCH_POSITION_TRIGGER: 'trigger'` / `SEARCH_POSITION_CUSTOM: 'custom'`
/// ——`custom` 时触发器不渲染搜索框，由 triggerRender 自置）。
enum SemiCascaderSearchPosition { trigger, custom }

/// 勾选联动口径（上游 `checkRelation`：constants.ts:21-22
/// `RELATED: 'related'` / `UN_RELATED: 'unRelated'`）。
enum SemiCascaderCheckRelation { related, unRelated }

/// 自定义过滤（上游 `filterTreeNode` 为函数时
/// `(inputValue, treeNodeString, data) => boolean`）。
typedef SemiCascaderFilter = bool Function(
  String input,
  String target,
  SemiCascaderData data,
);

/// 选中项回显自定义（上游 `displayRender`——★上游返回 ReactNode 的单/多选
/// 联合口径拍平为「路径数据 + index」返回 String，见 docs 差异清单）。
typedef SemiCascaderDisplayRender = String Function(
  List<SemiCascaderData> path, {
  int? index,
});

/// 搜索结果行自定义（上游 `filterRender`）。
typedef SemiCascaderFilterRender = Widget Function(
  SemiCascaderFilterRenderProps props,
);

/// 自定义触发器（上游 `triggerRender`）。
typedef SemiCascaderTriggerRender = Widget Function(
  SemiCascaderTriggerRenderProps props,
);

/// 级联数据节点（上游 `CascaderData`；`value` 上游 string|number——本移植
/// 统一 String，见 docs 差异清单）。
class SemiCascaderData {
  const SemiCascaderData({
    required this.value,
    required this.label,
    this.disabled = false,
    this.isLeaf,
    this.children,
  });

  /// 节点值（参与 key/值路径拼接——`VALUE_SPLIT`）。
  final String value;

  /// 展示文本（`displayProp: 'label'`）。
  final String label;

  /// 禁用（点击/勾选均不生效）。
  final bool disabled;

  /// 异步加载时是否叶子（`loadData` 模式下缺省非叶）。
  final bool? isLeaf;

  /// 子级。
  final List<SemiCascaderData>? children;
}

/// 搜索结果行渲染入参（上游 `FilterRenderProps`；className/事件对象差异见
/// docs）。
class SemiCascaderFilterRenderProps {
  const SemiCascaderFilterRenderProps({
    required this.inputValue,
    required this.disabled,
    required this.path,
    required this.checked,
    required this.halfChecked,
    required this.selected,
    required this.onTap,
    required this.onCheck,
  });

  /// 当前搜索词。
  final String inputValue;

  /// 行禁用（自身或祖先禁用——`_isOptionDisabled`）。
  final bool disabled;

  /// 节点路径数据（根 → 叶）。
  final List<SemiCascaderData> path;

  /// 多选勾选态。
  final bool checked;

  /// 多选半选态。
  final bool halfChecked;

  /// 单选命中态。
  final bool selected;

  /// 点击整行。
  final VoidCallback onTap;

  /// 点击勾选框。
  final VoidCallback onCheck;
}

/// 自定义触发器入参（上游 `TriggerRenderProps`；`value` 上游为 pos 串/Set——
/// 本移植拍平为 pos 列表，见 docs）。
class SemiCascaderTriggerRenderProps {
  const SemiCascaderTriggerRenderProps({
    required this.value,
    required this.inputValue,
    required this.placeholder,
    required this.disabled,
    required this.onSearch,
    required this.onClear,
    required this.onRemove,
  });

  /// 选中节点 pos 列表（`"0-1"` 式树位；单选 0/1 个）。
  final List<String> value;

  /// 当前搜索词。
  final String inputValue;

  /// 占位文案。
  final String placeholder;

  /// 禁用。
  final bool disabled;

  /// 同步搜索词（上游 onSearch/onChange 双名）。
  final ValueChanged<String> onSearch;

  /// 清空。
  final VoidCallback onClear;

  /// 移除某 pos 选中项（多选标签关闭）。
  final ValueChanged<String> onRemove;
}

/// 级联选择（上游 Semi Cascader）。
///
/// 触发器（cascader.scss）+ 弹层多列菜单（item.tsx；搜索时扁平结果列表）。
/// 数据/勾选级联语义与 [SemiTree] 同源（treeUtil.ts）；值路径回填、changeOnSelect、
/// max/maxTagCount、异步 loadData 是 Cascader 专属（cascader foundation.ts）。
///
/// ★未移植：disableStrictly、keyMaps（固定 `value`/`label`/`children` 域——
/// [SemiCascaderData] 强类型）、virtualizeInSearch、getPopupContainer、
/// preventScroll、stopPropagation、aria-*（见 docs/semi_cascader.md 差异清单）。
class SemiCascader extends StatefulWidget {
  const SemiCascader({
    super.key,
    this.treeData = const <SemiCascaderData>[],
    this.value,
    this.defaultValue,
    this.multiple = false,
    this.checkRelation = SemiCascaderCheckRelation.related,
    this.autoMergeValue = true,
    this.leafOnly = false,
    this.changeOnSelect = false,
    this.enableLeafClick = false,
    this.clickToSelect = false,
    this.max,
    this.maxTagCount,
    this.showRestTagsPopover = false,
    this.restTagsPopoverPosition = SemiTooltipPosition.top,
    this.disabled = false,
    this.filterTreeNode,
    this.filterLeafOnly = true,
    this.filterSorter,
    this.filterRender,
    this.treeNodeFilterProp = 'label',
    this.displayProp = 'label',
    this.displayRender,
    this.separator = ' / ',
    this.searchPosition = SemiCascaderSearchPosition.trigger,
    this.remote = false,
    this.showNext = SemiCascaderShowNext.click,
    this.expandIcon,
    this.loadData,
    this.loadedKeys,
    this.onLoad,
    this.placeholder,
    this.searchPlaceholder,
    this.size = SemiInputSize.normal,
    this.showClear = false,
    // 上游 defaultProps `arrowIcon: <IconChevronDown />`（undefined 才走缺省——
    // 显式 null 不渲染箭头 quirk：Flutter 以非空缺省值 + 可空字段等效表达）。
    this.arrowIcon = const SemiIcon(SemiIcons.chevronDown),
    this.clearIcon,
    this.borderless = false,
    this.validateStatus = SemiInputStatus.normal,
    this.prefix,
    this.insetLabel,
    this.suffix,
    this.triggerRender,
    this.topSlot,
    this.bottomSlot,
    this.emptyContent,
    this.dropdownStyle,
    this.dropdownMargin,
    this.position = SemiTooltipPosition.bottomLeft,
    this.autoAdjustOverflow = true,
    this.motion = true,
    this.mouseEnterDelay,
    this.mouseLeaveDelay,
    this.zIndex = _CascaderMetrics.popoverZIndex,
    this.defaultOpen = false,
    this.onChangeWithObject = false,
    this.onChange,
    this.onSelect,
    this.onSearch,
    this.onClear,
    this.onExceed,
    this.onFocus,
    this.onBlur,
    this.onVisibleChange,
    this.onListScroll,
    this.semanticsLabel,
  });

  /// Key of the option lists (弹层多列菜单).
  static const Key listKey = Key('SemiCascader.list');

  /// Key of the clear button slot.
  static const Key clearButtonKey = Key('SemiCascader.clearButton');

  /// Key of the filter input.
  static const Key searchInputKey = Key('SemiCascader.searchInput');

  /// Key of the empty row.
  static const Key emptyKey = Key('SemiCascader.empty');

  /// 选项行测试钩子（ValueKey('SemiCascader.option-$key')）。
  static Key optionKey(String key) => ValueKey('SemiCascader.option-$key');

  /// 选项勾选框测试钩子。
  static Key optionCheckboxKey(String key) =>
      ValueKey('SemiCascader.optionCheckbox-$key');

  /// 级联数据（`List<SemiCascaderData>`；引用变化触发实体重建——建议 const/
  /// 稳定引用）。
  final List<SemiCascaderData> treeData;

  /// 选中值：单选值路径 `List<String>`（或 String 简写）；多选路径集合
  /// `List<List<String>>`；非 null 即受控——交互只回调（TreeSelect 口径）。
  final Object? value;

  /// 未受控初值（同 [value] 形状）。
  final Object? defaultValue;

  /// 多选（checkbox 模式）。
  final bool multiple;

  /// 勾选联动口径（`related` 级联 + 半选 / `unRelated` 独立）。
  final SemiCascaderCheckRelation checkRelation;

  /// 关联模式合并父键（normalizeKeyList，去祖先）。
  final bool autoMergeValue;

  /// onChange 载荷只保留叶子键（normalizeKeyList leafOnly）。
  final bool leafOnly;

  /// 非叶子也可选中（单选；多选行点击勾选走 enableLeafClick/clickToSelect）。
  final bool changeOnSelect;

  /// 多选点击叶子行即勾选（`enableLeafClick`）。
  final bool enableLeafClick;

  /// 多选点击任意行即勾选（`clickToSelect`，优先于 enableLeafClick）。
  final bool clickToSelect;

  /// 多选数量上限（超出只许减不许增，回调 onExceed）。
  final int? max;

  /// 多选标签折叠上限（超出折叠为 "+N"）。
  final int? maxTagCount;

  /// "+N" 悬停展开其余标签（`showRestTagsPopover`）。
  final bool showRestTagsPopover;

  /// "+N" 弹层位置。
  final SemiTooltipPosition restTagsPopoverPosition;

  /// 禁用（触发器 + 选项交互全部关闭）。
  final bool disabled;

  /// 过滤开关：bool 或 [SemiCascaderFilter]（null/false 不渲染搜索框）。
  final Object? filterTreeNode;

  /// 搜索只匹配叶子（`filterLeafOnly`，缺省 true）。
  final bool filterLeafOnly;

  /// 搜索结果排序（`filterSorter(first.pathData, second.pathData, input)`）。
  final int Function(
    List<SemiCascaderData> first,
    List<SemiCascaderData> second,
    String inputValue,
  )?
  filterSorter;

  /// 搜索结果行自定义（`filterRender`）。
  final SemiCascaderFilterRender? filterRender;

  /// 过滤字段（`treeNodeFilterProp`，固定 label/value 域）。
  final String treeNodeFilterProp;

  /// 回显字段（`displayProp`，固定 label/value 域）。
  final String displayProp;

  /// 选中项回显自定义（`displayRender`）。
  final SemiCascaderDisplayRender? displayRender;

  /// 值路径连接符（上游 `separator: ' / '`）。
  final String separator;

  /// 搜索框位置（`trigger` 触发器内 / `custom` 由 triggerRender 自置）。
  final SemiCascaderSearchPosition searchPosition;

  /// 远程搜索（跳过本地过滤，当前 treeData 即结果；只回调 onSearch）。
  final bool remote;

  /// 展开下一级方式（`showNext`）。
  final SemiCascaderShowNext showNext;

  /// 自定义展开图标（缺省 `IconChevronRight`）。
  final Widget? expandIcon;

  /// 异步加载（展开未加载节点时调用；`loadData(selectOptions)` 路径数据）。
  final Future<void> Function(List<SemiCascaderData> selectOptions)? loadData;

  /// 已加载键（非 null 即受控）。
  final List<String>? loadedKeys;

  /// 加载完成回调（上游 onLoad(loadedKeys, node)）。
  final void Function(Set<String> loadedKeys, SemiCascaderData data)? onLoad;

  /// 占位文案（无选中时回显）。
  final String? placeholder;

  /// 搜索占位文案（缺省 [placeholder]）。
  final String? searchPlaceholder;

  /// 尺寸（上游 `size: 'small' | 'large' | 'default'`——
  /// constants.ts:9 `SIZE_SET: ['small', 'large', 'default']`；Flutter 侧
  /// normal = 上游 default）。
  final SemiInputSize size;

  /// 显示清除按钮（hover/展开时替换箭头）。
  final bool showClear;

  /// 自定义箭头（缺省 `<IconChevronDown />`；★显式传 null 不渲染箭头——上游
  /// defaultProps 只替换 undefined quirk 照抄）。
  final Widget? arrowIcon;

  /// 自定义清空图标（缺省 `<IconClear />`）。
  final Widget? clearIcon;

  /// 无边框静默态（hover/聚焦前透明底 + 隐藏箭头）。
  final bool borderless;

  /// 校验状态（上游 `VALIDATE_STATUS: ['success', 'default', 'error',
  /// 'warning']`——constants.ts:10；Flutter 侧 normal = 上游 default）。
  final SemiInputStatus validateStatus;

  /// 前缀（String | Widget）。
  final Object? prefix;

  /// 内嵌标签（String | Widget；`insetLabel`）。
  final Object? insetLabel;

  /// 后缀（String | Widget）。
  final Object? suffix;

  /// 自定义触发器（`triggerRender`）。
  final SemiCascaderTriggerRender? triggerRender;

  /// 弹层顶部插槽（`topSlot`）。
  final Widget? topSlot;

  /// 弹层底部插槽（`bottomSlot`）。
  final Widget? bottomSlot;

  /// 空态内容（String | Widget；缺省「暂无数据」。★上游 `emptyContent: null`
  /// 隐藏空态——传 `const SizedBox.shrink()` 近似，见 docs）。
  final Object? emptyContent;

  /// 弹层容器装饰（上游 `dropdownStyle` CSSProperties——Flutter 以
  /// BoxDecoration 拍平，缺省走 popover 壳）。
  final BoxDecoration? dropdownStyle;

  /// 弹层与触发器间距（上游 `dropdownMargin`）。
  final double? dropdownMargin;

  /// 弹层位置（上游 `position ?? … 'bottomLeft'`）。
  final SemiTooltipPosition position;

  /// 弹层自动翻转（`autoAdjustOverflow`）。
  final bool autoAdjustOverflow;

  /// 弹层显隐动画（上游 `motion`）。
  final bool motion;

  /// 弹层延迟（上游 `mouseEnterDelay`，ms）。
  final Duration? mouseEnterDelay;

  /// 弹层延迟（上游 `mouseLeaveDelay`，ms）。
  final Duration? mouseLeaveDelay;

  /// 弹层层级（上游 `zIndex: popoverNumbers.DEFAULT_Z_INDEX` = 1030）。
  final int zIndex;

  /// 初始展开弹层（`defaultOpen`）。
  final bool defaultOpen;

  /// onChange 回传数据对象（否则回传值路径）。
  final bool onChangeWithObject;

  /// 值变更（单选值路径 `List<String>`；多选 `List<List<String>>`；
  /// [onChangeWithObject] 时对应数据对象；清空回传 `[]`）。
  final ValueChanged<Object?>? onChange;

  /// 选择回调（单选节点 value；多选 value 列表——上游 `onSelect`）。
  final ValueChanged<Object?>? onSelect;

  /// 搜索回调（上游 `onSearch(inputValue)`）。
  final ValueChanged<String>? onSearch;

  /// 清空回调（上游 `onClear()`）。
  final VoidCallback? onClear;

  /// 超出 max 上限回调（上游 `onExceed(checkedItems)`——本移植拍平为数据列表）。
  final ValueChanged<List<SemiCascaderData>>? onExceed;

  /// 触发器聚焦回调（上游 `onFocus`）。
  final VoidCallback? onFocus;

  /// 触发器失焦回调（上游 `onBlur`——点击外部/单选收起时触发）。
  final VoidCallback? onBlur;

  /// 弹层显隐回调（上游 `onDropdownVisibleChange`）。
  final ValueChanged<bool>? onVisibleChange;

  /// 选项列滚动回调（上游 `onListScroll(e, {panelIndex, activeNode})`——
  /// ★无 DOM 事件，e 不回传，见 docs）。
  final void Function(int panelIndex, SemiCascaderData? activeNode)?
  onListScroll;

  /// 触发器语义标签（上游缺省 `'aria-label': 'Cascader'`）。
  final String? semanticsLabel;

  @override
  State<SemiCascader> createState() => _SemiCascaderState();
}

/// 实体（util.ts `traverseDataNodes` / `convertDataToEntities`）。
class _CascaderEntity {
  _CascaderEntity({
    required this.key,
    required this.data,
    required this.ind,
    required this.level,
    required this.pos,
    required this.parentKey,
    required this.path,
    required this.valuePath,
    this.parent,
    this.notExist = false,
  });

  /// util.ts:76 `key = parent ? \`\${parent.key}${VALUE_SPLIT}\${nodeValue}\` : \`\${nodeValue}\``。
  final String key;
  final SemiCascaderData data;
  final int ind;
  final int level;

  /// util.ts:77 `pos = parent ? \`\${parent.pos}-\${ind}\` : \`\${ind}\``。
  final String pos;
  final String? parentKey;

  /// 键路径（根 → 自身）。
  final List<String> path;

  /// 值路径（根 → 自身）。
  final List<String> valuePath;
  final _CascaderEntity? parent;

  /// 上游 `_notExist`（value 在 treeData 中不存在时的合成实体）。
  final bool notExist;
  final List<_CascaderEntity> children = <_CascaderEntity>[];
}

class _SemiCascaderState extends State<SemiCascader> {
  /// constants.ts:33 `VALUE_SPLIT = '_SEMI_CASCADER_SPLIT_'`。
  static const String _valueSplit = '_SEMI_CASCADER_SPLIT_';

  static const String _notExistPrefix = 'not-exist-';

  // -- data ------------------------------------------------------------------
  List<_CascaderEntity> _roots = <_CascaderEntity>[];
  Map<String, _CascaderEntity> _entities = <String, _CascaderEntity>{};

  // -- single selection ------------------------------------------------------
  final Set<String> _selectedKeys = <String>{};
  Set<String> _activeKeys = <String>{};

  // -- multiple selection ----------------------------------------------------
  Set<String> _checked = <String>{};
  Set<String> _halfChecked = <String>{};
  Set<String> _resolved = <String>{};

  // -- search ----------------------------------------------------------------
  Set<String> _filteredKeys = <String>{};
  bool _isSearching = false;
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final FocusNode _triggerFocusNode = FocusNode(debugLabel: 'SemiCascader');

  // -- async load ------------------------------------------------------------
  Set<String> _loaded = <String>{};
  Set<String> _loading = <String>{};
  bool _loadControlled = false;

  // -- trigger visuals -------------------------------------------------------
  bool _open = false;
  bool _isHovering = false;
  bool _pressed = false;
  bool _isFocus = false;
  bool _clearHovered = false;
  bool _clearPressed = false;
  final Set<String> _hoverKeys = <String>{};
  final Set<String> _pressedKeys = <String>{};

  /// 单选可过滤时触发器内输入显隐（index.tsx `showInput`）。
  bool _showInput = false;
  int _rePosKey = 0;
  double _panelMinWidth = 0;

  String get _inputValue => _inputController.text;

  bool get _isFilterable {
    final filter = widget.filterTreeNode;
    return filter != null && filter != false;
  }

  /// util.ts:180-190 `calcMergeType`（leafOnly > autoMergeValue > none）。
  String get _mergeType {
    if (widget.leafOnly) {
      return 'leafOnly'; // LEAF_ONLY_MERGE_TYPE
    }
    if (widget.autoMergeValue) {
      return 'autoMergeValue'; // AUTO_MERGE_VALUE_MERGE_TYPE
    }
    return 'none'; // NONE_MERGE_TYPE
  }

  bool get _isControlled => widget.value != null;

  bool get _multiple => widget.multiple;

  // -- lifecycle -------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadControlled = widget.loadedKeys != null;
    if (widget.loadedKeys != null) _loaded = widget.loadedKeys!.toSet();
    _buildEntities();
    _applyValue(widget.value ?? widget.defaultValue, init: true);
    // foundation.ts:261-270 `init`（defaultOpen 且非禁用即展开）。
    if (widget.defaultOpen && !widget.disabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openMenu();
      });
    }
  }

  @override
  void didUpdateWidget(SemiCascader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loadedKeys != oldWidget.loadedKeys) {
      _loadControlled = widget.loadedKeys != null;
      if (widget.loadedKeys != null) _loaded = widget.loadedKeys!.toSet();
    }
    // index.tsx:447-570 getDerivedStateFromProps / componentDidUpdate 口径：
    // treeData 变化重建实体并按当前值重算；值变化走 handleValueChange。
    if (widget.treeData != oldWidget.treeData) {
      _buildEntities();
      if (_multiple) {
        _applyValue(widget.value ?? widget.defaultValue);
      } else {
        _applyValue(widget.value ?? _cacheValue());
      }
      _recalculateFilteredKeys();
    } else if (widget.value != oldWidget.value) {
      _applyValue(widget.value);
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    _triggerFocusNode.dispose();
    super.dispose();
  }

  // -- data ------------------------------------------------------------------

  /// util.ts:66-164 `traverseDataNodes` + `convertDataToEntities`（keyMaps 不
  /// 移植——固定 `value`/`label`/`children` 域）。
  void _buildEntities() {
    final entities = <String, _CascaderEntity>{};
    final roots = <_CascaderEntity>[];
    void process(SemiCascaderData node, int ind, _CascaderEntity? parent) {
      final key = parent == null
          ? node.value
          : '${parent.key}$_valueSplit${node.value}';
      final entity = _CascaderEntity(
        key: key,
        data: node,
        ind: ind,
        level: parent == null ? 0 : parent.level + 1,
        pos: parent == null ? '$ind' : '${parent.pos}-$ind',
        parentKey: parent?.key,
        path: parent == null ? <String>[key] : <String>[...parent.path, key],
        valuePath: parent == null
            ? <String>[node.value]
            : <String>[...parent.valuePath, node.value],
        parent: parent,
      );
      entities[key] = entity;
      if (parent == null) {
        roots.add(entity);
      } else {
        parent.children.add(entity);
      }
      final children = node.children;
      if (children != null) {
        for (var i = 0; i < children.length; i++) {
          process(children[i], i, entity);
        }
      }
    }

    for (var i = 0; i < widget.treeData.length; i++) {
      process(widget.treeData[i], i, null);
    }
    _entities = entities;
    _roots = roots;
  }

  /// foundation.ts:323-328 `_isLeaf`（loadData 模式以 `isLeaf` 标记为准）。
  bool _isLeaf(SemiCascaderData data) {
    if (widget.loadData != null) return data.isLeaf == true;
    return data.children == null || data.children!.isEmpty;
  }

  /// foundation.ts:346-350 `_isOptionDisabled`（自身或祖先禁用即禁用）。
  bool _isOptionDisabled(String key) {
    var entity = _entities[key];
    while (entity != null) {
      if (entity.data.disabled) return true;
      entity = entity.parent;
    }
    return false;
  }

  /// foundation.ts:353-368 `getItemPropPath`（not-exist 实体回传值路径）。
  List<String> _valuePathOf(String key) {
    final entity = _entities[key];
    if (entity == null) return <String>[];
    return entity.valuePath;
  }

  List<SemiCascaderData> _pathDataOf(String key) {
    final entity = _entities[key];
    if (entity == null) return <SemiCascaderData>[];
    final result = <SemiCascaderData>[];
    for (final pathKey in entity.path) {
      final e = _entities[pathKey];
      if (e != null) result.add(e.data);
    }
    return result;
  }

  /// `displayProp` 取值（固定 label/value 域——keyMaps 不移植）。
  String _displayOf(SemiCascaderData data) =>
      widget.displayProp == 'value' ? data.value : data.label;

  String _filterOf(SemiCascaderData data) =>
      widget.treeNodeFilterProp == 'value' ? data.value : data.label;

  List<String> _displayPathOf(String key) {
    final entity = _entities[key];
    if (entity == null) return <String>[];
    return [for (final k in entity.path) _displayOf(_entities[k]!.data)];
  }

  /// foundation.ts:764-778 `renderDisplayText`（displayRender ?? join separator）。
  String _displayString(String key, {int? index}) {
    final data = _pathDataOf(key);
    if (widget.displayRender != null) {
      return widget.displayRender!(data, index: index);
    }
    return _displayPathOf(key).join(widget.separator);
  }

  /// foundation.ts:370-412 `_getCacheValue`（treeData 更新时保住选中值；
  /// ★not-exist- 前缀口径照抄）。
  Object? _cacheValue() {
    if (_selectedKeys.isEmpty) return null;
    final key = _selectedKeys.first;
    final entity = _entities[key];
    if (entity == null) {
      if (key.startsWith(_notExistPrefix)) {
        final target = key.substring(_notExistPrefix.length);
        final targetEntity = _entities[target];
        return targetEntity?.valuePath ?? target;
      }
      return null;
    }
    return entity.valuePath;
  }

  /// 用户值归一（单选值路径 / 多选路径集合 → `List<List<String>>`）。
  List<List<String>> _normalizePaths(Object? raw) {
    if (raw == null) return <List<String>>[];
    if (raw is List<List<String>>) return raw;
    if (raw is List<String>) return <List<String>>[raw];
    if (raw is String) {
      return <List<String>>[
        <String>[raw],
      ];
    }
    if (raw is List && raw.isEmpty) return <List<String>>[];
    if (raw is List) {
      // 异构 List（如 List<Object>）按单条路径处理。
      return <List<String>>[raw.map((e) => e.toString()).toList()];
    }
    return <List<String>>[
      <String>[raw.toString()],
    ];
  }

  /// foundation.ts:528-614 `updateSelectedKey`（值 → 选中/激活键；not-exist
  /// 合成实体；changeOnSelect/叶子口径）。
  void _applyValue(
    Object? raw, {
    bool init = false,
    bool preserveSearch = false,
  }) {
    final paths = _normalizePaths(raw);
    if (_multiple) {
      // index.tsx:495-539 多选口径（getDerivedStateFromProps `getRealKeys`）。
      final keys = <String>[
        for (final path in paths)
          if (path.isNotEmpty && _entities.containsKey(path.join(_valueSplit)))
            path.join(_valueSplit),
      ];
      if (widget.checkRelation == SemiCascaderCheckRelation.related) {
        final (checked, half) = _calcCheckedKeysFrom(keys);
        final resolved = _normalizeKeyList(
          checked.toList(),
          leafOnly: widget.leafOnly,
        );
        _checked = checked;
        _halfChecked = half;
        _resolved = resolved.toSet();
      } else {
        _checked = keys.toSet();
      }
      return;
    }
    if (paths.isEmpty) {
      if (_loading.isNotEmpty) {
        // foundation.ts:603-608（#1155：异步加载中不做清空）。
        return;
      }
      _clearSelected(clearSearch: !preserveSearch && _isFilterable);
      return;
    }
    final valuePath = paths.first;
    final key = valuePath.join(_valueSplit);
    final entity = _entities[key];
    if (entity != null) {
      if (widget.changeOnSelect || _isLeaf(entity.data)) {
        _selectedKeys
          ..clear()
          ..add(key);
        if (_loading.isEmpty) _activeKeys = entity.path.toSet();
      } else if (_selectedKeys.length == 1 && _selectedKeys.contains(key)) {
        // foundation.ts:576-578（非可选条件且与当前同键 → 清空口径）。
        _clearSelected(clearSearch: !preserveSearch && _isFilterable);
      }
      return;
    }
    // foundation.ts:579-601（值不在 treeData 中 → `not-exist-` 合成实体）。
    final val = valuePath.isEmpty ? '' : valuePath.last;
    final nkey = '$_notExistPrefix$val';
    _entities[nkey] = _CascaderEntity(
      key: nkey,
      data: SemiCascaderData(value: val, label: val),
      ind: 0,
      level: valuePath.length - 1,
      pos: '',
      parentKey: null,
      path: valuePath,
      valuePath: valuePath,
      notExist: true,
    );
    _selectedKeys
      ..clear()
      ..add(nkey);
  }

  /// foundation.ts:515-526 `_getClearSelectedKey`。
  void _clearSelected({required bool clearSearch}) {
    _selectedKeys.clear();
    _activeKeys = <String>{};
    _filteredKeys = <String>{};
    if (clearSearch && !_multiple) {
      _inputController.clear();
    }
  }

  // -- checked cascades (treeUtil.ts:226-586；与 semi_tree.dart 同源) ---------

  List<String> _siblingKeys(_CascaderEntity entity) => [
    for (final sibling in (entity.parent?.children ?? _roots)) sibling.key,
  ];

  List<String> _findDescendantKeys(
    Iterable<String> keys, {
    required bool self,
  }) {
    final result = <String>[];
    void walk(_CascaderEntity entity) {
      for (final child in entity.children) {
        result.add(child.key);
        walk(child);
      }
    }

    for (final key in keys) {
      if (self) {
        result.add(key);
      }
      final entity = _entities[key];
      if (entity != null) {
        walk(entity);
      }
    }
    return result;
  }

  Set<String> _findAncestorKeys(Iterable<String> keys, {required bool self}) {
    final result = <String>{};
    void walk(_CascaderEntity entity) {
      var parent = entity.parent;
      while (parent != null) {
        result.add(parent.key);
        parent = parent.parent;
      }
    }

    for (final key in keys) {
      final entity = _entities[key];
      if (entity != null) {
        walk(entity);
      }
      if (self) {
        result.add(key);
      }
    }
    return result;
  }

  /// treeUtil.ts:335-384 `calcCheckedKeys`（全选键 → 后代全选 + 祖先逐级判满）。
  (Set<String>, Set<String>) _calcCheckedKeysFrom(Iterable<String> keys) {
    final keyList = keys.toList();
    final checked = _findDescendantKeys(keyList, self: true).toSet();
    final half = <String>{};
    final visited = <String>{};
    final levelMap = <int, List<String>>{};
    for (final key in keyList) {
      final entity = _entities[key];
      if (entity == null) {
        continue;
      }
      levelMap.putIfAbsent(entity.level, () => <String>[]).add(key);
    }

    void calcCurrLevel(_CascaderEntity node) {
      final parent = node.parent;
      if (parent == null || visited.contains(node.key)) {
        return;
      }
      final siblings = _siblingKeys(node);
      visited.addAll(siblings);
      final allChecked = siblings.every(checked.contains);
      if (!allChecked) {
        half.addAll(_findAncestorKeys([node.key], self: false));
      } else {
        checked.add(parent.key);
        levelMap.putIfAbsent(node.level - 1, () => <String>[]).add(parent.key);
      }
    }

    while (levelMap.isNotEmpty) {
      final maxLevel = levelMap.keys.reduce((a, b) => a > b ? a : b);
      final keysAtLevel = List<String>.of(levelMap[maxLevel]!);
      levelMap.remove(maxLevel);
      for (final key in keysAtLevel) {
        final entity = _entities[key];
        if (entity != null) {
          calcCurrLevel(entity);
        }
      }
    }
    return (checked, half);
  }

  /// treeUtil.ts:509-534 `calcCheckedKeysForChecked`。
  (Set<String>, Set<String>) _checkedForChecked(String key) {
    final descendantKeys = _findDescendantKeys([key], self: true).toSet();
    final checked = <String>{..._checked, key};
    final half = <String>{..._halfChecked};
    final entity = _entities[key];

    void calcCurrLevel(_CascaderEntity node) {
      final parent = node.parent;
      if (parent == null) {
        return;
      }
      final siblings = _siblingKeys(node);
      final allChecked = siblings.every(checked.contains);
      if (!allChecked) {
        half.addAll(_findAncestorKeys([node.key], self: false));
      } else {
        checked.add(parent.key);
        calcCurrLevel(parent);
      }
    }

    if (entity != null) {
      calcCurrLevel(entity);
    }
    checked.addAll(descendantKeys);
    return (checked, half);
  }

  /// treeUtil.ts:536-586 `calcCheckedKeysForUnchecked`。
  (Set<String>, Set<String>) _checkedForUnchecked(String key) {
    final descendantKeys = _findDescendantKeys([key], self: true);
    final checked = <String>{..._checked};
    final half = <String>{..._halfChecked};
    for (final descendantKey in descendantKeys) {
      checked.remove(descendantKey);
      half.remove(descendantKey);
    }
    final entity = _entities[key];

    void calcCurrLevel(_CascaderEntity node) {
      final parent = node.parent;
      if (parent == null) {
        return;
      }
      if (!checked.contains(parent.key) && !half.contains(parent.key)) {
        return;
      }
      final siblings = _siblingKeys(node);
      final anyChecked = siblings.any(
        (sibling) => checked.contains(sibling) || half.contains(sibling),
      );
      final ancestors = _findAncestorKeys([node.key], self: false);
      if (anyChecked) {
        for (final ancestorKey in ancestors) {
          if (checked.contains(ancestorKey)) {
            checked.remove(ancestorKey);
            half.add(ancestorKey);
          }
        }
      } else {
        checked.remove(parent.key);
        half.remove(parent.key);
        calcCurrLevel(parent);
      }
    }

    if (entity != null) {
      calcCurrLevel(entity);
    }
    return (checked, half);
  }

  /// treeUtil.ts:459-490 `normalizeKeyList`。
  List<String> _normalizeKeyList(
    List<String> keys, {
    required bool leafOnly,
    bool flag = false,
  }) {
    final result = <String>[];
    final keySet = keys.toSet();
    if (!leafOnly) {
      for (final key in keys) {
        final entity = _entities[key];
        if (entity == null) {
          if (flag) {
            result.add(key);
          }
          continue;
        }
        final parent = entity.parent;
        if (parent != null && keySet.contains(parent.key)) {
          continue;
        }
        result.add(key);
      }
    } else {
      for (final key in keys) {
        final entity = _entities[key];
        if (entity != null && entity.children.isEmpty) {
          result.add(key);
        }
        if (entity == null && flag) {
          result.add(key);
        }
      }
    }
    return result;
  }

  // -- notify ----------------------------------------------------------------

  /// foundation.ts:304-321 `_notifyChange`（值路径 / 数据对象载荷）。
  void _notifyChangeKeys(Set<String> keys) {
    if (_multiple) {
      widget.onChange?.call(<Object?>[
        for (final key in keys)
          widget.onChangeWithObject ? _pathDataOf(key) : _valuePathOf(key),
      ]);
    }
  }

  void _notifyChangeSingle(String? key) {
    if (key == null) {
      widget.onChange?.call(<Object?>[]);
      return;
    }
    widget.onChange?.call(
      widget.onChangeWithObject ? _pathDataOf(key) : _valuePathOf(key),
    );
  }

  /// foundation.ts:1024-1035 `_notifySelect`（单值 / 多值拍平）。
  void _notifySelectKeys(Set<String> keys) {
    final values = <String>[
      for (final key in keys)
        if (_entities[key] != null) _entities[key]!.data.value,
    ];
    if (values.isEmpty) return;
    widget.onSelect?.call(values.length == 1 ? values.first : values);
  }

  // -- open / close ----------------------------------------------------------

  /// foundation.ts:616-630 `open`。
  void _openMenu() {
    if (_open) return;
    setState(() {
      _open = true;
      _rePosKey++;
    });
    if (_isFilterable) {
      _inputController.clear();
      _isSearching = false;
      _filteredKeys = <String>{};
      if (!_multiple) {
        // foundation.ts:685-691 `toggle2SearchInput(true)`。
        _showInput = true;
        _inputFocusNode.requestFocus();
      }
    }
    if (_isControlled) _reCalcActiveKeys();
    widget.onVisibleChange?.call(true);
  }

  /// foundation.ts:632-645 `reCalcActiveKeys`（受控值 → 激活路径）。
  void _reCalcActiveKeys() {
    if (_selectedKeys.isEmpty) return;
    final entity = _entities[_selectedKeys.first];
    if (entity == null) return;
    final next = entity.path.toSet();
    if (next.length != _activeKeys.length || !next.containsAll(_activeKeys)) {
      _activeKeys = next;
    }
  }

  /// foundation.ts:647-667 `close`（收起 + blur 通知 + 搜索复位）。
  void _closeMenu({String? key}) {
    if (!_open) return;
    setState(() {
      _open = false;
    });
    widget.onVisibleChange?.call(false);
    if (_isFilterable) {
      String text = '';
      if (key != null && !_multiple) {
        text = _displayString(key);
      } else if (_selectedKeys.isNotEmpty && !_multiple) {
        text = _displayString(_selectedKeys.first);
      }
      _inputController.text = text;
      _isSearching = false;
      if (!_multiple) {
        _showInput = false;
        _isFocus = false;
      }
    }
    widget.onBlur?.call();
  }

  void _handleEsc() {
    // foundation.ts:285-290 `handleKeyDown`（ESC 收起）。
    if (_open) _closeMenu();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      // foundation.ts:286 `e.key === ESC_KEY`。
      if (!_open) return KeyEventResult.ignored;
      _closeMenu();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      // foundation.ts:26/754-758 `isEnterPress`（触发器 Enter → 开关）。
      _handleTriggerTap();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// foundation.ts:736-748 `handleClick`（触发器点击开关）。
  void _handleTriggerTap() {
    if (widget.disabled) return;
    _triggerFocusNode.requestFocus();
    if (!_open) {
      _openMenu();
      widget.onFocus?.call();
      setState(() => _isFocus = true);
    } else if (!_isFilterable) {
      _closeMenu();
    }
  }

  void _handleTooltipVisibleChange(bool visible) {
    // SemiTooltip `onVisibleChange`：barrier 点击 = 上游 clickOutside
    // （registerClickOutsideHandler → close）；内部收起走 _closeMenu。
    if (!mounted) return;
    if (visible == _open) return;
    if (visible) {
      _openMenu();
      return;
    }
    _closeMenu();
  }

  // -- selection -------------------------------------------------------------

  /// foundation.ts:697-704 `handleItemClick`。
  void _handleItemClick(_CascaderEntity item) {
    if (widget.disabled) return;
    _handleSingleSelect(item);
    setState(() => _rePosKey++);
  }

  /// foundation.ts:706-725 `handleItemHover` / `handleShowNextByHover`。
  void _handleItemHover(_CascaderEntity item) {
    if (widget.disabled) return;
    setState(() {
      _activeKeys = item.path.toSet();
    });
    if (!_isLeaf(item.data)) {
      _notifyIfLoadData(item);
    }
  }

  /// foundation.ts:817-875 `handleSingleSelect`。
  void _handleSingleSelect(_CascaderEntity item) {
    final allowChange = widget.changeOnSelect;
    final data = item.data;
    final key = item.key;
    final isLeaf = _isLeaf(data);
    final hasChanged = _selectedKeys.isEmpty || _selectedKeys.first != key;

    if (!isLeaf &&
        !allowChange &&
        !_isSearching &&
        !(_multiple && widget.clickToSelect)) {
      setState(() {
        _activeKeys = item.path.toSet();
      });
      _notifyIfLoadData(item);
      return;
    }
    if (_multiple) {
      setState(() {
        _activeKeys = item.path.toSet();
      });
      // clickToSelect 优先于 enableLeafClick（index.tsx:837-842）。
      if (widget.clickToSelect || (isLeaf && widget.enableLeafClick)) {
        _handleMultipleSelect(item);
      }
      return;
    }
    widget.onSelect?.call(data.value);
    if (hasChanged) {
      _notifyChangeSingle(key);
      _notifyIfLoadData(item);
      if (_isControlled) {
        setState(() {
          _activeKeys = item.path.toSet();
        });
        if (isLeaf) _closeMenu();
        return;
      }
      setState(() {
        _activeKeys = item.path.toSet();
        _selectedKeys
          ..clear()
          ..add(key);
      });
      if (isLeaf) {
        _closeMenu(key: key);
      } else if (!widget.filterLeafOnly && _isSearching) {
        _closeMenu(key: key);
      }
    } else {
      _closeMenu();
    }
  }

  /// foundation.ts:727-734 `onItemCheckboxClick`。
  void _handleCheckboxTap(_CascaderEntity item) {
    if (widget.disabled) return;
    _handleMultipleSelect(item);
    setState(() => _rePosKey++);
  }

  /// foundation.ts:877-885 `_handleMultipleSelect`（★上游勾选后清空 inputValue
  /// 但保留 isSearching quirk 照抄）。
  void _handleMultipleSelect(_CascaderEntity item) {
    switch (widget.checkRelation) {
      case SemiCascaderCheckRelation.related:
        _toggleRelated(item);
      case SemiCascaderCheckRelation.unRelated:
        _toggleUnRelated(item);
    }
    _inputController.clear();
  }

  /// foundation.ts:887-953 `_handleRelatedMultipleSelect`（disableStrictly 不
  /// 移植——上游 calcCheckedStatus/calcNonDisabledCheckedKeys 缺席）。
  void _toggleRelated(_CascaderEntity item) {
    final key = item.key;
    final prevChecked = _checked.contains(key);
    final curChecked = !prevChecked;
    final (checked, half) = curChecked
        ? _checkedForChecked(key)
        : _checkedForUnchecked(key);
    final isLeafOnlyMerge = _mergeType == 'leafOnly';
    final isNoneMerge = _mergeType == 'none';
    final resolved = _normalizeKeyList(
      checked.toList(),
      leafOnly: isLeafOnlyMerge,
    ).toSet();
    final real = isNoneMerge ? checked : resolved;

    final max = widget.max;
    if (max != null) {
      // foundation.ts:915-937（超 max 只许减不许增 → onExceed）。
      if (!isNoneMerge) {
        if (_resolved.length < resolved.length && resolved.length > max) {
          widget.onExceed?.call([
            for (final k in resolved)
              if (_entities[k] != null) _entities[k]!.data,
          ]);
          return;
        }
      } else {
        if (_checked.length < checked.length && checked.length > max) {
          widget.onExceed?.call([
            for (final k in checked)
              if (_entities[k] != null) _entities[k]!.data,
          ]);
          return;
        }
      }
    }
    if (!_isControlled) {
      setState(() {
        _checked = checked;
        _halfChecked = half;
        _resolved = resolved;
      });
    }
    _notifyChangeKeys(real);
    if (curChecked) _notifySelectKeys(real);
  }

  /// foundation.ts:955-991 `_handleUnRelatedMultipleSelect`。
  void _toggleUnRelated(_CascaderEntity item) {
    final key = item.key;
    final next = <String>{..._checked};
    final prevChecked = _checked.contains(key);
    bool targetStatus;
    if (prevChecked) {
      next.remove(key);
      targetStatus = false;
    } else {
      final max = widget.max;
      if (max != null && _checked.length >= max) {
        widget.onExceed?.call([
          for (final k in _checked)
            if (_entities[k] != null) _entities[k]!.data,
        ]);
        return;
      }
      next.add(key);
      targetStatus = true;
    }
    if (!_isControlled) {
      setState(() => _checked = next);
    }
    _notifyChangeKeys(next);
    if (targetStatus) _notifySelectKeys(next);
  }

  /// foundation.ts:1170-1180 `handleTagRemoveByKey`（标签关闭 = 反勾选）。
  void _removeTag(String key) {
    if (widget.disabled) return;
    final entity = _entities[key];
    if (entity == null) return;
    if (entity.data.disabled) return;
    _handleMultipleSelect(entity);
    setState(() => _rePosKey++);
  }

  /// index.tsx:803-825 `renderMultipleTags` 的键口径（mergeType 为 none 或
  /// unRelated 时用 checkedKeys，否则 resolvedCheckedKeys）。
  List<String> get _tagKeys =>
      (_mergeType == 'none' ||
          widget.checkRelation == SemiCascaderCheckRelation.unRelated)
      ? _checked.toList()
      : _resolved.toList();

  // -- clear -----------------------------------------------------------------

  /// foundation.ts:1063-1106 `handleClear`。
  void _handleClear() {
    if (_multiple) {
      _isSearching = false;
      _inputController.clear();
      widget.onSearch?.call('');
      if (!_isControlled) {
        setState(() {
          _checked = <String>{};
          _halfChecked = <String>{};
          _selectedKeys.clear();
          _resolved = <String>{};
          _activeKeys = <String>{};
        });
      }
      widget.onChange?.call(<Object?>[]);
    } else {
      if (_isFilterable && _isSearching) {
        setState(() {
          _isSearching = false;
          _filteredKeys = <String>{};
        });
        _inputController.clear();
        widget.onSearch?.call('');
      } else {
        if (_isFilterable) {
          _inputController.clear();
          widget.onSearch?.call('');
        }
        setState(() {
          if (!_isControlled) _selectedKeys.clear();
          _activeKeys = <String>{};
          _filteredKeys = <String>{};
        });
        widget.onChange?.call(<Object?>[]);
      }
    }
    widget.onClear?.call();
    setState(() => _rePosKey++);
  }

  // -- search ----------------------------------------------------------------

  /// util.ts:37-61 `filter`（bool → join('') 包含匹配；函数 → 用户判定）。
  bool _filterMatch(String input, SemiCascaderData data, List<String> path) {
    final filter = widget.filterTreeNode;
    if (filter == null || filter == false) return true;
    if (filter is SemiCascaderFilter) {
      return filter(input, path.join(), data);
    }
    return path.join('').toLowerCase().contains(input.toLowerCase());
  }

  /// foundation.ts:446-472 `_calcFilteredKeys`（remote 只留叶子口径；本地按
  /// filterTreeNode 匹配）。
  List<String> _calcFilteredKeys(String sugInput) {
    if (sugInput.isEmpty) return <String>[];
    final result = <String>[];
    if (widget.remote) {
      for (final entity in _entities.values) {
        if (entity.notExist) continue;
        if ((_isFilterable && !widget.filterLeafOnly) || _isLeaf(entity.data)) {
          result.add(entity.key);
        }
      }
      return result;
    }
    for (final entity in _entities.values) {
      if (entity.notExist) continue;
      final filteredPath = [
        for (final k in entity.path) _filterOf(_entities[k]!.data),
      ];
      if (!_filterMatch(sugInput, entity.data, filteredPath)) continue;
      if ((_isFilterable && !widget.filterLeafOnly) || _isLeaf(entity.data)) {
        result.add(entity.key);
      }
    }
    return result;
  }

  /// foundation.ts:1051-1061 `handleInputChange`。
  void _handleInputChange(String value) {
    setState(() {
      _isSearching = value.isNotEmpty;
      _filteredKeys = _calcFilteredKeys(value).toSet();
    });
    widget.onSearch?.call(value);
    setState(() => _rePosKey++);
  }

  /// foundation.ts:478-503 `recalculateFilteredKeys`（搜索中 treeData 异步更新
  /// 的过滤同步——不触发 onSearch）。
  void _recalculateFilteredKeys() {
    if (!_isFilterable) return;
    if (!_isSearching) return;
    setState(() {
      _filteredKeys = _calcFilteredKeys(_inputValue).toSet();
    });
  }

  // -- async load ------------------------------------------------------------

  /// foundation.ts:798-815 `notifyIfLoadData`。
  void _notifyIfLoadData(_CascaderEntity item) {
    final data = item.data;
    final key = item.key;
    if (data.isLeaf == true || data.children != null) return;
    final loadData = widget.loadData;
    if (loadData == null) return;
    if (_loaded.contains(key) || _loading.contains(key)) return;
    setState(() => _loading = <String>{..._loading, key});
    final optionPath = _pathDataOf(key);
    loadData(optionPath).then((_) {
      // 上游 notifyLoadData 以 setTimeout 延后 callback（treeData 更新先行）。
      Future<void>.delayed(Duration.zero, () {
        if (mounted) _handleNodeLoad(item);
      });
    });
  }

  /// foundation.ts:780-796 `handleNodeLoad`（onLoad 先于内部 setState）。
  void _handleNodeLoad(_CascaderEntity item) {
    final loaded = <String>{..._loaded, item.key};
    widget.onLoad?.call(loaded, item.data);
    if (!_loadControlled) _loaded = loaded;
    setState(() {
      _loading = <String>{..._loading}..remove(item.key);
    });
  }

  // -- render data -----------------------------------------------------------

  /// foundation.ts:1118-1130 `getRenderData`（搜索中扁平结果，否则根列）。
  List<_CascaderEntity> get _renderRoots => _roots;

  /// foundation.ts:1132-1161 `getFilteredData`（扁平行 + filterSorter）。
  List<_FlatCascaderRow> _filteredRows() {
    final rows = <_FlatCascaderRow>[];
    for (final key in _filteredKeys) {
      final entity = _entities[key];
      if (entity == null) continue;
      rows.add(
        _FlatCascaderRow(
          key: key,
          data: entity.data,
          pathData: _pathDataOf(key),
          searchText: [
            for (final k in entity.path) _filterOf(_entities[k]!.data),
          ],
          disabled: _isOptionDisabled(key),
        ),
      );
    }
    final sorter = widget.filterSorter;
    if (sorter != null) {
      rows.sort((a, b) => sorter(a.pathData, b.pathData, _inputValue));
    }
    return rows;
  }

  /// foundation.ts:1163-1168 `handleListScroll`。
  void _handleListScroll(int panelIndex) {
    final activeKey = _activeKeys.isEmpty ? null : _activeKeys.last;
    widget.onListScroll?.call(
      panelIndex,
      activeKey == null ? null : _entities[activeKey]?.data,
    );
  }

  // -- build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final global = SemiTheme.of(context);
    final theme = SemiCascaderTheme.resolve(context);
    return _buildTriggerShell(global, theme);
  }

  Widget _buildTriggerShell(
    SemiThemeData global,
    SemiResolvedCascaderThemeData theme,
  ) {
    return SemiTooltip(
      content: _buildPanel(global, theme),
      trigger: SemiTooltipTrigger.custom,
      visible: _open,
      onVisibleChange: _handleTooltipVisibleChange,
      // foundation.ts:285-290 `handleKeyDown`（ESC 收起）——面板内聚焦时由
      // tooltip 通道消费，触发器聚焦时由 _handleKey 消费。
      closeOnEsc: true,
      onEscKeyDown: _handleEsc,
      showArrow: false,
      popupBare: true,
      position: widget.position,
      autoAdjustOverflow: widget.autoAdjustOverflow,
      zIndex: widget.zIndex,
      motion: widget.motion,
      spacing: widget.dropdownMargin ?? 8,
      mouseEnterDelay:
          widget.mouseEnterDelay ?? const Duration(milliseconds: 50),
      mouseLeaveDelay:
          widget.mouseLeaveDelay ?? const Duration(milliseconds: 50),
      repositionKey: _rePosKey,
      child: Focus(
        focusNode: _triggerFocusNode,
        onKeyEvent: _handleKey,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTriggerTap,
          child: MouseRegion(
            cursor: widget.disabled
                ? SystemMouseCursors.forbidden
                // cascader.scss:21 `cursor: pointer`。
                : SystemMouseCursors.click,
            onEnter: (_) {
              if (widget.showClear) setState(() => _isHovering = true);
            },
            onExit: (_) {
              if (widget.showClear) setState(() => _isHovering = false);
            },
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) => setState(() => _pressed = true),
              onPointerUp: (_) => setState(() => _pressed = false),
              onPointerCancel: (_) => setState(() => _pressed = false),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // foundation.ts:272-283 `_setEmptyContentMinWidth`（空态
                  // minWidth = 触发器宽）。
                  final width = constraints.maxWidth;
                  if (width.isFinite && width > 0 && width != _panelMinWidth) {
                    _panelMinWidth = width;
                  }
                  return _buildTrigger(global, theme);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// cascader.scss 状态矩阵（`&` / `&:hover` / `&:active` / `&-focus` /
  /// `&-warning` / `&-error` / `&-disabled` / `&-borderless`）。
  (Color, Color, double) _triggerDecoration(
    SemiResolvedCascaderThemeData theme,
  ) {
    const transparent = Color(0x00000000);
    if (widget.disabled) {
      // `&-disabled`（cascader.scss:305-329）：底色 disabled-fill（hover 换
      // disabled-fill hover），描边走默认 border。
      final bg = _isHovering
          ? theme.colorCascaderInputDisabledBgHover
          : theme.colorCascaderInputDisabledBgDefault;
      return (
        bg,
        theme.colorCascaderDefaultBorderDefault,
        theme.widthCascaderBorder,
      );
    }
    final focused = _isFocus || (_open && !_showInput);
    Color bg;
    Color border;
    double borderWidth;
    switch (widget.validateStatus) {
      case SemiInputStatus.warning:
        bg = _pressed
            ? theme.colorCascaderWarningBgActive
            : focused
            ? theme.colorCascaderWarningBgFocus
            : _isHovering
            ? theme.colorCascaderWarningBgHover
            : theme.colorCascaderWarningBgDefault;
        border = _pressed
            ? theme.colorCascaderWarningBorderActive
            : focused
            ? theme.colorCascaderWarningBorderFocus
            : _isHovering
            ? theme.colorCascaderWarningBorderHover
            : theme.colorCascaderWarningBorderDefault;
        borderWidth = focused
            ? theme.widthCascaderFocusBorder
            : _isHovering
            ? theme.widthCascaderHoverBorder
            : theme.widthCascaderBorder;
      case SemiInputStatus.error:
        bg = _pressed
            ? theme.colorCascaderDangerBgActive
            : focused
            ? theme.colorCascaderDangerBgFocus
            : _isHovering
            ? theme.colorCascaderDangerBgHover
            : theme.colorCascaderDangerBgDefault;
        border = _pressed
            ? theme.colorCascaderDangerBorderActive
            : focused
            ? theme.colorCascaderDangerBorderFocus
            : _isHovering
            ? theme.colorCascaderDangerBorderHover
            : theme.colorCascaderDangerBorderDefault;
        borderWidth = focused
            ? theme.widthCascaderFocusBorder
            : _isHovering
            ? theme.widthCascaderHoverBorder
            : theme.widthCascaderBorder;
      default:
        // `&-focus:hover` 保持 focus 底色（cascader.scss:72-82）。
        bg = _pressed
            ? theme.colorCascaderDefaultBgActive
            : focused
            ? theme.colorCascaderDefaultBgDefault
            : _isHovering
            ? theme.colorCascaderDefaultBgHover
            : theme.colorCascaderDefaultBgDefault;
        border = focused
            ? theme.colorCascaderDefaultBorderFocus
            : _isHovering
            ? theme.colorCascaderDefaultBorderHover
            : theme.colorCascaderDefaultBorderDefault;
        borderWidth = focused
            ? theme.widthCascaderFocusBorder
            : _isHovering
            ? theme.widthCascaderHoverBorder
            : theme.widthCascaderBorder;
    }
    // cascader.scss:542-572 `-borderless`：静默（非 hover 非 focus）→ 透明底/
    // 描边 + 箭头隐藏（`opacity: 0`）；error/warning 描边恒 `_border-focus` 色。
    if (widget.borderless) {
      if (widget.validateStatus == SemiInputStatus.error) {
        border = theme.colorCascaderDangerBorderFocus;
      } else if (widget.validateStatus == SemiInputStatus.warning) {
        border = theme.colorCascaderWarningBorderFocus;
      }
      if (!_isHovering && !_pressed && !focused) {
        return (transparent, transparent, borderWidth);
      }
      if (focused && !_pressed) {
        return (transparent, border, borderWidth);
      }
    }
    return (bg, border, borderWidth);
  }

  double _triggerHeight(SemiResolvedCascaderThemeData theme) =>
      switch (widget.size) {
        SemiInputSize.small => theme.heightCascaderSmall,
        SemiInputSize.normal => theme.heightCascaderDefault,
        SemiInputSize.large => theme.heightCascaderLarge,
      };

  /// 触发器内边距（cascader.scss `-selection` / `-small` / `-large` 与
  /// `&-multiple` 组合——12 个 spacing 字段全消费）。
  (double, double) _selectionPadding(SemiResolvedCascaderThemeData theme) {
    if (_multiple && _checked.isNotEmpty) {
      return switch (widget.size) {
        SemiInputSize.small => (
          theme.spacingCascaderSmallSelectionMultiplePaddingLeft,
          theme.spacingCascaderSmallSelectionMultiplePaddingRight,
        ),
        SemiInputSize.normal => (
          theme.spacingCascaderSelectionMultiplePaddingLeft,
          theme.spacingCascaderSelectionMultiplePaddingRight,
        ),
        SemiInputSize.large => (
          theme.spacingCascaderLargeSelectionMultiplePaddingLeft,
          theme.spacingCascaderLargeSelectionMultiplePaddingRight,
        ),
      };
    }
    return switch (widget.size) {
      SemiInputSize.small => (
        theme.spacingCascaderSmallSelectionPaddingLeft,
        theme.spacingCascaderSmallSelectionPaddingRight,
      ),
      SemiInputSize.normal => (
        theme.spacingCascaderSelectionPaddingLeft,
        theme.spacingCascaderSelectionPaddingRight,
      ),
      SemiInputSize.large => (
        theme.spacingCascaderLargeSelectionPaddingLeft,
        theme.spacingCascaderLargeSelectionPaddingRight,
      ),
    };
  }

  Widget _buildTrigger(
    SemiThemeData global,
    SemiResolvedCascaderThemeData theme,
  ) {
    final (bg, border, borderWidth) = _triggerDecoration(theme);
    // cascader.scss:125 `@include font-size-regular`（=14）；:58 large 尺寸
    // `@include font-size-header-6`（=16）。
    final fontSize = widget.size == SemiInputSize.large
        ? _CascaderMetrics.selectionLargeFontSize
        : global.typography.fontSizeRegular;
    final lineHeight = _triggerHeight(theme);
    final textColor = widget.disabled
        ? theme.colorCascaderInputDisabledTextDefault
        : theme.colorCascaderSelectionTextDefault;
    final placeholderColor = widget.disabled
        ? theme.colorCascaderInputDisabledTextDefault
        : theme.colorCascaderPlaceholderTextDefault;
    final iconColor = widget.disabled
        // cascader.scss:326-328 `&-disabled .arrow`。
        ? theme.colorCascaderInputDisabledIconDefault
        : theme.colorCascaderIconDefault;
    final (padLeft, padRight) = _selectionPadding(theme);

    final selection = Padding(
      padding: EdgeInsetsDirectional.only(start: padLeft, end: padRight),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: _buildSelectionContent(
          theme,
          textColor,
          placeholderColor,
          fontSize,
          lineHeight,
        ),
      ),
    );

    Widget buildRow(bool bounded) => Row(
      mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.prefix != null)
          _slotWidget(
            global,
            theme,
            widget.prefix!,
            isIcon: widget.prefix is Widget,
            iconColor: iconColor,
            inset: false,
          ),
        if (widget.insetLabel != null)
          _slotWidget(
            global,
            theme,
            widget.insetLabel!,
            isIcon: widget.insetLabel is Widget,
            iconColor: iconColor,
            inset: true,
          ),
        bounded ? Expanded(child: selection) : Flexible(child: selection),
        if (widget.suffix != null)
          _slotWidget(
            global,
            theme,
            widget.suffix!,
            isIcon: widget.suffix is Widget,
            iconColor: iconColor,
            inset: false,
          ),
        // index.tsx:1053-1089 clearBtn 与 arrow 互斥占位。
        if (_showClearButton)
          Semantics(
            button: true,
            label: _CascaderMetrics.clearButtonSemantics,
            child: GestureDetector(
              key: SemiCascader.clearButtonKey,
              behavior: HitTestBehavior.opaque,
              onTap: _handleClear,
              child: MouseRegion(
                cursor: widget.disabled
                    ? SystemMouseCursors.forbidden
                    : SystemMouseCursors.click,
                onEnter: (_) => setState(() => _clearHovered = true),
                onExit: (_) => setState(() => _clearHovered = false),
                child: Listener(
                  onPointerDown: (_) => setState(() => _clearPressed = true),
                  onPointerUp: (_) => setState(() => _clearPressed = false),
                  onPointerCancel: (_) => setState(() => _clearPressed = false),
                  child: SizedBox(
                    // cascader.scss:248 `width: $width-cascader-icon`。
                    width: theme.widthCascaderIcon,
                    child: Center(
                      child: SemiIconTheme(
                        data: SemiIconThemeData(
                          color: _clearPressed
                              ? theme.colorCascaderIconActive
                              : _clearHovered
                              ? theme.colorCascaderIconHover
                              : theme.colorCascaderIconDefault,
                          customSize: fontSize,
                        ),
                        // index.tsx:985 `clearIcon ? clearIcon : <IconClear />`。
                        child:
                            widget.clearIcon ?? const SemiIcon(SemiIcons.clear),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        else
          SizedBox(
            width: theme.widthCascaderIcon,
            // index.tsx:993-1004 `renderArrow`：arrowIcon 为 null → 不渲染。
            child: widget.arrowIcon == null
                ? null
                : Opacity(
                    // cascader.scss:546-548 `-borderless` 静默态箭头 `opacity: 0`。
                    opacity: _arrowVisible ? 1 : 0,
                    child: Center(
                      child: SemiIconTheme(
                        data: SemiIconThemeData(
                          color: iconColor,
                          customSize: fontSize,
                        ),
                        // index.tsx:198 `arrowIcon: <IconChevronDown />`。
                        child: widget.arrowIcon!,
                      ),
                    ),
                  ),
          ),
      ],
    );

    final body = LayoutBuilder(
      builder: (context, constraints) {
        final row = buildRow(constraints.hasBoundedWidth);
        return _multiple
            ? ConstrainedBox(
                constraints: BoxConstraints(minHeight: _triggerHeight(theme)),
                child: row,
              )
            : SizedBox(height: _triggerHeight(theme), child: row);
      },
    );
    return Semantics(
      // index.tsx:1082 `role="combobox"`（近似）。
      button: true,
      enabled: !widget.disabled,
      expanded: _open,
      label: widget.semanticsLabel ?? _CascaderMetrics.defaultSemanticsLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(width: borderWidth, color: border),
          // cascader.scss:9 `border-radius: $radius-cascader`。
          borderRadius: BorderRadius.circular(theme.radiusCascader),
        ),
        child: ConstrainedBox(
          // cascader.scss:11 `min-width: $width-cascader`。
          constraints: BoxConstraints(minWidth: theme.widthCascader),
          child: body,
        ),
      ),
    );
  }

  /// cascader.scss:543-550 `-borderless` 静默态箭头隐藏。
  bool get _arrowVisible =>
      !widget.borderless || _isHovering || _pressed || _isFocus;

  bool get _showClearButton {
    final hasValue = _selectedKeys.isNotEmpty;
    final multipleWithHaveValue = _multiple && _checked.isNotEmpty;
    return widget.showClear &&
        (_inputValue.isNotEmpty || hasValue || multipleWithHaveValue) &&
        !widget.disabled &&
        (_open || _isHovering);
  }

  Widget _asWidget(Object value) => value is Widget
      ? value
      : Text(value as String, maxLines: 1, overflow: TextOverflow.ellipsis);

  /// `&-prefix` / `&-suffix` / `&-inset-label` 槽（cascader.scss:262-288）。
  Widget _slotWidget(
    SemiThemeData global,
    SemiResolvedCascaderThemeData theme,
    Object value, {
    required bool isIcon,
    required Color iconColor,
    required bool inset,
  }) {
    final color = widget.disabled
        ? theme.colorCascaderInputDisabledTextDefault
        : isIcon
        ? iconColor
        : theme.colorCascaderPrefixSuffixTextDefault;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isIcon
            // cascader.scss:276 `margin: 0 $spacing-cascader_icon-marginX`。
            ? theme.spacingCascaderIconMarginX
            // cascader.scss:268/282 `margin: 0 $spacing-cascader_text-marginX`。
            : theme.spacingCascaderTextMarginX,
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: color,
          fontSize: global.typography.fontSizeRegular,
          fontWeight: isIcon
              ? null
              // cascader.scss:269/283 `font-weight: $font-cascader_prefix_suffix_fontWeight`。
              : theme.fontCascaderPrefixSuffixFontWeight,
        ),
        child: _asWidget(value),
      ),
    );
  }

  // -- selection area --------------------------------------------------------

  /// index.tsx:853-874 `renderSelectContent`。
  Widget _buildSelectionContent(
    SemiResolvedCascaderThemeData theme,
    Color textColor,
    Color placeholderColor,
    double fontSize,
    double lineHeight,
  ) {
    // index.tsx:856 `searchable = Boolean(filterTreeNode) && searchPosition ===
    // strings.SEARCH_POSITION_TRIGGER`。
    final searchable =
        _isFilterable &&
        widget.searchPosition == SemiCascaderSearchPosition.trigger;
    if (widget.triggerRender != null) {
      return widget.triggerRender!(
        SemiCascaderTriggerRenderProps(
          value: [
            for (final key in _multiple ? _tagKeys : _selectedKeys)
              if (_entities[key] != null) _entities[key]!.pos,
          ],
          inputValue: _inputValue,
          placeholder: widget.searchPlaceholder ?? widget.placeholder ?? '',
          disabled: widget.disabled,
          onSearch: _handleInputChange,
          onClear: _handleClear,
          onRemove: _removeTag,
        ),
      );
    }
    if (!searchable) {
      if (_multiple) {
        if (_checked.isEmpty) {
          return Text(
            widget.placeholder ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: placeholderColor,
              fontSize: fontSize,
              fontWeight: theme.fontCascaderFontWeight,
            ),
          );
        }
        return _buildTagList(theme, fontSize);
      }
      final text = _selectedKeys.isEmpty
          ? null
          : _displayString(_selectedKeys.first);
      return Text(
        text ?? widget.placeholder ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: text == null ? placeholderColor : textColor,
          fontSize: fontSize,
          fontWeight: theme.fontCascaderFontWeight,
          // line-height → 行盒高度（CSS line-height 的 Flutter 映射）。
          height: lineHeight / fontSize,
        ),
      );
    }
    return _multiple
        ? _buildMultipleFilterInput(theme, placeholderColor, lineHeight)
        : _buildSingleFilterInput(
            theme,
            textColor,
            placeholderColor,
            fontSize,
            lineHeight,
          );
  }

  /// index.tsx:803-825 `renderMultipleTags`（maxTagCount 折叠 + "+N"）。
  Widget _buildTagList(SemiResolvedCascaderThemeData theme, double fontSize) {
    final keys = _tagKeys;
    final fold =
        widget.maxTagCount != null && keys.length > widget.maxTagCount!;
    final visibleKeys = fold ? keys.take(widget.maxTagCount!).toList() : keys;
    final restCount = keys.length - visibleKeys.length;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final (index, key) in visibleKeys.indexed)
          Padding(
            padding: EdgeInsets.only(
              // cascader.scss:152 `-selection-tag` margin 简写
              // `margin: Y Right Y Left`（Left=0 → first-child 亦无左距）。
              left: theme.spacingCascaderSelectionTagMarginLeft,
              right: theme.spacingCascaderSelectionTagMarginRight,
              top: theme.spacingCascaderSelectionTagMarginY,
              bottom: theme.spacingCascaderSelectionTagMarginY,
            ),
            child: _buildTag(theme, key, index),
          ),
        if (restCount > 0) _buildNTag(theme, restCount),
      ],
    );
  }

  /// index.tsx:591-622 `renderTagItem`（白色 Tag，disabled 不可关）。
  Widget _buildTag(SemiResolvedCascaderThemeData theme, String key, int index) {
    final entity = _entities[key];
    if (entity == null) return const SizedBox.shrink();
    final disabled = widget.disabled || entity.data.disabled;
    final label = _displayOf(entity.data);
    return SemiTag(
      widget.displayRender != null
          ? widget.displayRender!([entity.data], index: index)
          : label,
      size: widget.size == SemiInputSize.small
          ? SemiTagSize.small
          : SemiTagSize.large,
      color: SemiTagColor.white,
      backgroundColor: disabled
          // cascader.scss:158-161 `&-tag-disabled`（tag 底色透明 + 禁用文字色）。
          ? theme.colorCascaderTagDisabledBgDefault
          : const Color(0x00000000),
      textColor: disabled ? theme.colorCascaderInputDisabledTextDefault : null,
      closable: !disabled,
      onClose: (_) => _removeTag(key),
    );
  }

  /// "+N" 折叠标签（cascader.scss:171-183 `-selection-n`）。
  Widget _buildNTag(SemiResolvedCascaderThemeData theme, int restCount) {
    final nTag = Padding(
      // cascader.scss:174 `margin-right: $spacing-cascader_selection_n-marginRight`。
      padding: EdgeInsetsDirectional.only(
        end: theme.spacingCascaderSelectionNMarginRight,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          // cascader.scss:176-177 `padding-left/right: …_n-paddingX`。
          horizontal: theme.spacingCascaderSelectionNPaddingX,
        ),
        child: Text(
          '+$restCount',
          key: const ValueKey('_+n'),
          style: TextStyle(
            // cascader.scss:173 `font-size: $font-cascader_selection_n-fontSize`。
            fontSize: theme.fontCascaderSelectionNFontSize,
            color: widget.disabled
                ? theme.colorCascaderSelectionNTextDisabled
                : theme.colorCascaderSelectionNTextDefault,
          ),
        ),
      ),
    );
    if (!widget.showRestTagsPopover) return nTag;
    final keys = _tagKeys;
    final rest = keys.sublist(keys.length - restCount);
    return SemiTooltip(
      content: Padding(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 4,
          runSpacing: 2,
          children: [
            for (final (index, key) in rest.indexed)
              _buildTag(theme, key, index),
          ],
        ),
      ),
      trigger: SemiTooltipTrigger.hover,
      position: widget.restTagsPopoverPosition,
      showArrow: true,
      child: nTag,
    );
  }

  /// index.tsx:656-684 `renderInput`（单选触发器内搜索：回填文案 + bare 输入）。
  Widget _buildSingleFilterInput(
    SemiResolvedCascaderThemeData theme,
    Color textColor,
    Color placeholderColor,
    double fontSize,
    double lineHeight,
  ) {
    final text = _selectedKeys.isEmpty
        ? null
        : _displayString(_selectedKeys.first);
    // index.tsx:672-676 span 三态（hide/inactive/placeholder）。
    final showText = !(_showInput && _inputValue.isNotEmpty);
    final inactive = _showInput && _inputValue.isEmpty;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        SizedBox(
          height: switch (widget.size) {
            // cascader.scss:361-373 `-search-wrapper` 高度三档。
            SemiInputSize.small => theme.heightCascaderSelectionWrapperSmall,
            SemiInputSize.normal => theme.heightCascaderSelectionWrapper,
            SemiInputSize.large => theme.heightCascaderSelectionWrapperLarge,
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              // cascader.scss:333-336 `.popover .search-wrapper`（★上游误嵌套
              // ——意图消费在搜索容器：padding + border-bottom）。
              border: Border(
                bottom: BorderSide(
                  width: theme.widthCascaderSearchBorder,
                  color: theme.colorCascaderSearchBorderDefault,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacingCascaderSearchPaddingX,
                vertical: theme.spacingCascaderSearchPaddingY,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  // cascader.scss:383-384 `border/background-color:
                  // $color-cascader_input-border-default`（`none` 简写 → 不描边
                  // 透明底）。
                  color: theme.colorCascaderInputBgDefault,
                  border: Border.all(
                    width: 0,
                    color: theme.colorCascaderInputBorderDefault,
                  ),
                ),
                child: SemiInput(
                  key: SemiCascader.searchInputKey,
                  controller: _inputController,
                  focusNode: _inputFocusNode,
                  size: widget.size,
                  disabled: widget.disabled,
                  bare: true,
                  placeholder: '',
                  onChanged: widget.disabled ? null : _handleInputChange,
                ),
              ),
            ),
          ),
        ),
        if (showText)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: widget.disabled,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _handleTriggerTap();
                  _inputFocusNode.requestFocus();
                },
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    text ??
                        widget.searchPlaceholder ??
                        widget.placeholder ??
                        '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.disabled
                          ? theme.colorCascaderInputDisabledTextDefault
                          // cascader.scss:229-231 `-selection-text-inactive`。
                          : inactive
                          ? theme.colorCascaderSelectionTextInactive
                          : text == null
                          ? placeholderColor
                          : textColor,
                      fontSize: fontSize,
                      fontWeight: theme.fontCascaderFontWeight,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// index.tsx:628-654 `renderTagInput`（多选触发器内搜索：标签 + 内联输入）。
  Widget _buildMultipleFilterInput(
    SemiResolvedCascaderThemeData theme,
    Color placeholderColor,
    double lineHeight,
  ) {
    final keys = _tagKeys;
    final fold =
        widget.maxTagCount != null && keys.length > widget.maxTagCount!;
    final visibleKeys = fold ? keys.take(widget.maxTagCount!).toList() : keys;
    final restCount = keys.length - visibleKeys.length;
    final children = <Widget>[
      for (final (index, key) in visibleKeys.indexed)
        Padding(
          padding: EdgeInsets.only(
            // cascader.scss:152 `-selection-tag` margin 简写
            // `margin: Y Right Y Left`（Left=0 → first-child 亦无左距）。
            left: theme.spacingCascaderSelectionTagMarginLeft,
            right: theme.spacingCascaderSelectionTagMarginRight,
            top: theme.spacingCascaderSelectionTagMarginY,
            bottom: theme.spacingCascaderSelectionTagMarginY,
          ),
          child: _buildTag(theme, key, index),
        ),
      if (restCount > 0) _buildNTag(theme, restCount),
      ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: _tagInputMinHeight(theme),
          maxHeight: _tagInputMinHeight(theme),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            // cascader.scss:210 `margin-left: $spacing-cascader_selection_input-marginLeft`。
            start: theme.spacingCascaderSelectionInputMarginLeft,
          ),
          child: SemiInput(
            key: SemiCascader.searchInputKey,
            controller: _inputController,
            focusNode: _inputFocusNode,
            size: widget.size,
            disabled: widget.disabled,
            bare: true,
            placeholder: widget.searchPlaceholder ?? widget.placeholder ?? '',
            onChanged: widget.disabled ? null : _handleInputChange,
          ),
        ),
      ),
    ];
    final wrap = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
    // cascader.scss:191-195 `tagInput-wrapper` `margin-left: -4px`（负值把
    // wrapper padding 拉回——上游 `- $spacing-extra-tight` quirk）。
    final offset = theme.spacingCascaderSelectionTagInputMarginLeft;
    return Padding(
      padding: EdgeInsetsDirectional.only(start: offset < 0 ? 0 : offset),
      child: Transform.translate(
        offset: Offset(offset < 0 ? offset : 0, 0),
        child: wrap,
      ),
    );
  }

  double _tagInputMinHeight(
    SemiResolvedCascaderThemeData theme,
  ) => switch (widget.size) {
    // cascader.scss:198-205 `tagInput` min-height 三档。
    SemiInputSize.small => theme.heightCascaderSelectionTagInputWrapperSmall,
    SemiInputSize.normal => theme.heightCascaderSelectionTagInputWrapperDefault,
    SemiInputSize.large => theme.heightCascaderSelectionTagInputWrapperLarge,
  };

  // -- panel -----------------------------------------------------------------

  /// index.tsx:718-779 `renderContent` + item.tsx:407-430 `render`。
  Widget _buildPanel(
    SemiThemeData global,
    SemiResolvedCascaderThemeData theme,
  ) {
    final searching = _isFilterable && _isSearching;
    final rows = searching ? _filteredRows() : null;
    final isEmpty = rows != null ? rows.isEmpty : _renderRoots.isEmpty;
    final radius = global.radius.borderRadiusMedium.value;
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: isEmpty ? _panelMinWidth : 0),
      child: DecoratedBox(
        decoration: widget.dropdownStyle ?? _popoverDecoration(global),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.topSlot != null)
                  _IntrinsicWidthBlocker(child: widget.topSlot!),
                if (isEmpty)
                  _buildEmpty(theme)
                else
                  SizedBox(
                    key: SemiCascader.listKey,
                    // cascader.scss:404 `height: $height-cascader_option_list`。
                    height: theme.heightCascaderOptionList,
                    child: rows != null
                        ? _buildFlattenList(theme, rows)
                        : _buildColumns(theme),
                  ),
                if (widget.bottomSlot != null)
                  _IntrinsicWidthBlocker(child: widget.bottomSlot!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _popoverDecoration(SemiThemeData global) => BoxDecoration(
    // `$color-popover-bg-default: var(--semi-color-bg-3)`。
    color: global.colors.colorBg3,
    // `$color-popover-border-default: var(--semi-color-border)`，1px。
    border: Border.all(width: 1, color: global.colors.colorBorder),
    // `$radius-popover: var(--semi-border-radius-medium)`。
    borderRadius: BorderRadius.circular(global.radius.borderRadiusMedium.value),
    boxShadow: const [
      _CascaderMetrics.shadowElevatedBlur,
      _CascaderMetrics.shadowElevatedDrop,
    ],
  );

  /// item.tsx:324-387 `renderItem`（多列：active 路径逐级展开子列）。
  Widget _buildColumns(SemiResolvedCascaderThemeData theme) {
    final columns = <List<_CascaderEntity>>[];
    var current = _renderRoots;
    columns.add(current);
    while (true) {
      _CascaderEntity? active;
      for (final entity in current) {
        if (_activeKeys.contains(entity.key) && entity.children.isNotEmpty) {
          active = entity;
          break;
        }
      }
      if (active == null) break;
      current = active.children;
      columns.add(current);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, column) in columns.indexed)
            _buildColumn(theme, column, index),
        ],
      ),
    );
  }

  Widget _buildColumn(
    SemiResolvedCascaderThemeData theme,
    List<_CascaderEntity> items,
    int index,
  ) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.depth == 0 &&
            notification is ScrollUpdateNotification) {
          _handleListScroll(index);
        }
        return false;
      },
      // 横向 Row 给非 flex 子级无限宽——IntrinsicWidth 收紧行宽、min-width
      // 兜底（cascader.scss:430 `min-width: $width-cascader_option`）。
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: theme.widthCascaderOption),
        child: IntrinsicWidth(
          child: SingleChildScrollView(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  left: index == 0
                      ? BorderSide.none
                      // cascader.scss:436 `border-left: $width-cascader_option_list-border
                      // solid $color-cascader_option_list-border-default`。
                      : BorderSide(
                          width: theme.widthCascaderOptionListBorder,
                          color: theme.colorCascaderOptionListBorderDefault,
                        ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  // cascader.scss:433 `padding: $spacing-cacader_option_list-paddingY
                  // $spacing-cacader_option_list-paddingX`（★上游拼写 cacader）。
                  vertical: theme.spacingCacaderOptionListPaddingY,
                  horizontal: theme.spacingCacaderOptionListPaddingX,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final entity in items) _buildOptionRow(theme, entity),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// item.tsx:324-387 单行（li.option）。
  Widget _buildOptionRow(
    SemiResolvedCascaderThemeData theme,
    _CascaderEntity entity,
  ) {
    final key = entity.key;
    final data = entity.data;
    final active = _activeKeys.contains(key);
    final selected = _selectedKeys.contains(key);
    final loading = _loading.contains(key) && !_loaded.contains(key);
    final hasChild =
        entity.children.isNotEmpty ||
        (widget.loadData != null && data.isLeaf != true);
    final disabled = widget.disabled || data.disabled;
    final hovered = _hoverKeys.contains(key);
    final pressed = _pressedKeys.contains(key);

    return GestureDetector(
      key: SemiCascader.optionKey(key),
      behavior: HitTestBehavior.opaque,
      onTap: disabled ? null : () => _handleItemClick(entity),
      child: MouseRegion(
        cursor: disabled
            // cascader.scss:521 `cursor: not-allowed`。
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        onEnter: (_) {
          setState(() => _hoverKeys.add(key));
          // item.tsx:128-136 `onHover`（showNext=hover 才展开）。
          if (!disabled && widget.showNext == SemiCascaderShowNext.hover) {
            _handleItemHover(entity);
          }
        },
        onExit: (_) => setState(() => _hoverKeys.remove(key)),
        child: Listener(
          onPointerDown: (_) => setState(() => _pressedKeys.add(key)),
          onPointerUp: (_) => setState(() => _pressedKeys.remove(key)),
          onPointerCancel: (_) => setState(() => _pressedKeys.remove(key)),
          child: _buildOptionBody(
            theme,
            key: key,
            label: data.label,
            active: active,
            selected: selected,
            disabled: disabled,
            loading: loading,
            hasChild: hasChild,
            hovered: hovered,
            pressed: pressed,
            onCheck: () => _handleCheckboxTap(entity),
            checked: _checked.contains(key),
            halfChecked: _halfChecked.contains(key),
            flatten: false,
          ),
        ),
      ),
    );
  }

  /// item.tsx:233-295 `renderFlattenOptionItem`（搜索扁平行）。
  Widget _buildFlattenList(
    SemiResolvedCascaderThemeData theme,
    List<_FlatCascaderRow> rows,
  ) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: theme.widthCascaderOption,
          minHeight: theme.heightCascaderOptionList,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: theme.spacingCacaderOptionListPaddingY,
            horizontal: theme.spacingCacaderOptionListPaddingX,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [for (final row in rows) _buildFlattenRow(theme, row)],
          ),
        ),
      ),
    );
  }

  Widget _buildFlattenRow(
    SemiResolvedCascaderThemeData theme,
    _FlatCascaderRow row,
  ) {
    final disabled = widget.disabled || row.disabled;
    final selected = _selectedKeys.contains(row.key);
    return GestureDetector(
      key: SemiCascader.optionKey(row.key),
      behavior: HitTestBehavior.opaque,
      onTap: disabled
          ? null
          : () {
              final entity = _entities[row.key];
              if (entity != null) _handleItemClick(entity);
            },
      child: MouseRegion(
        cursor: disabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hoverKeys.add(row.key)),
        onExit: (_) => setState(() => _hoverKeys.remove(row.key)),
        child: _buildOptionBody(
          theme,
          key: row.key,
          label: row.data.label,
          active: false,
          selected: selected,
          disabled: disabled,
          loading: false,
          hasChild: false,
          hovered: _hoverKeys.contains(row.key),
          pressed: false,
          onCheck: () {
            final entity = _entities[row.key];
            if (entity != null) _handleCheckboxTap(entity);
          },
          checked: _checked.contains(row.key),
          halfChecked: _halfChecked.contains(row.key),
          flatten: true,
          searchText: row.searchText,
        ),
      ),
    );
  }

  /// item.tsx li 的 class 矩阵（-active / -select / -disabled / -flatten）+
  /// 标签区（tick / empty / checkbox）+ 右侧展开图标。
  Widget _buildOptionBody(
    SemiResolvedCascaderThemeData theme, {
    required String key,
    required String label,
    required bool active,
    required bool selected,
    required bool disabled,
    required bool loading,
    required bool hasChild,
    required bool hovered,
    required bool pressed,
    required bool checked,
    required bool halfChecked,
    required bool flatten,
    required VoidCallback onCheck,
    List<String>? searchText,
  }) {
    // item.tsx:339-343 class 矩阵：`-active` = 激活路径底色、`-select` = 命中
    // 文字（bold + highlight）、`-disabled` = 禁用。
    final Color bg;
    if (disabled) {
      bg = pressed
          // cascader.scss:528 `&-disabled:active` 透明。
          ? theme.colorCascaderOptionDisabledBgActive
          : hovered
          ? theme.colorCascaderOptionDisabledBgHover
          : const Color(0x00000000);
    } else if (active && !selected) {
      // cascader.scss:506-512 `-active`（hover/active 均保持 selected 底色）。
      bg = theme.colorCascaderOptionBgSelected;
    } else if (pressed) {
      bg = theme.colorCascaderOptionBgActive;
    } else if (hovered) {
      bg = theme.colorCascaderOptionBgHover;
    } else {
      bg = const Color(0x00000000);
    }
    final textColor = disabled
        // cascader.scss:531-533 `&-disabled .option-label`。
        ? theme.colorCascaderOptionDisabledTextDefault
        : selected && !_multiple
        ? theme.colorCascaderSelectHighlight
        : theme.colorCascaderOptionMainTextDefault;
    final fontWeight = selected && !_multiple
        // cascader.scss:514-518 `-select` `font-weight: $font-cascader_select-fontWeight`。
        ? theme.fontCascaderSelectFontWeight
        : theme.fontCascaderFontWeight;

    final labelWidget = searchText != null
        ? Text.rich(_highlightSpan(theme, searchText))
        : Text(
            label,
            style: TextStyle(color: textColor, fontWeight: fontWeight),
          );

    return AnimatedContainer(
      // cascader.scss:448 `transition: background-color
      // $transition_duration-cascader_option-bg …`（delay 并入 duration 的
      // Flutter 近似）。
      duration:
          theme.transitionDurationCascaderOptionBg +
          theme.transitionDelayCascaderOptionBg,
      curve: theme.transitionFunctionCascaderOptionBg,
      color: bg,
      padding: EdgeInsets.only(
        // cascader.scss:420-423 `ul > li` padding 四向。
        top: theme.spacingCascaderOptionPaddingTop,
        bottom: theme.spacingCascaderOptionPaddingBottom,
        left: theme.spacingCascaderOptionPaddingLeft,
        // item.tsx:238 flatten 行右 padding 换 `$spacing-cascader_flatten_list-paddingRight`。
        right: flatten
            ? theme.spacingCascaderFlattenListPaddingRight
            : theme.spacingCascaderOptionPaddingRight,
      ),
      child: Row(
        children: [
          if (!_multiple)
            Padding(
              padding: EdgeInsetsDirectional.only(
                // item.tsx:179 `&-icon-empty` `margin-right: …empty_icon-marginRight`。
                end: theme.spacingCascaderEmptyIconMarginRight,
              ),
              child: SizedBox(
                width: theme.widthCascaderOptionIcon,
                height: theme.widthCascaderOptionIcon,
                child: selected
                    // item.tsx:364/175 `renderIcon('tick')`。
                    ? SemiIconTheme(
                        data: SemiIconThemeData(
                          color: theme.colorCascaderOptionIconDefault,
                          customSize: theme.widthCascaderOptionIcon,
                        ),
                        child: const SemiIcon(SemiIcons.tick),
                      )
                    // item.tsx:365/179 `renderIcon('empty')`（占位）。
                    : const SizedBox.shrink(),
              ),
            )
          else
            Padding(
              padding: EdgeInsetsDirectional.only(
                // cascader.scss:498 `-label-checkbox` `margin-right`。
                end: theme.spacingCascaderLabelCheckboxMarginRight,
              ),
              child: SizedBox(
                width: theme.widthCascaderOptionIcon,
                height: theme.widthCascaderOptionIcon,
                child: Center(
                  child: Transform.scale(
                    scale: 0.8,
                    child: SemiCheckbox(
                      key: SemiCascader.optionCheckboxKey(key),
                      checked: checked,
                      indeterminate: halfChecked,
                      disabled: disabled,
                      onChanged: disabled ? null : (_) => onCheck(),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: DefaultTextStyle.merge(
              style: TextStyle(color: textColor, fontWeight: fontWeight),
              child: labelWidget,
            ),
          ),
          if (hasChild)
            Padding(
              padding: EdgeInsetsDirectional.only(
                // cascader.scss:477 `&-icon-left` `margin-left:
                // $spacing-cascader_option-icon-marginLeft`。
                start: theme.spacingCascaderOptionIconMarginLeft,
              ),
              child: SizedBox(
                width: theme.widthCascaderOptionIcon,
                height: theme.widthCascaderOptionIcon,
                child: loading
                    // item.tsx:377 `renderIcon(loading ? 'loading' : 'child')`。
                    ? const SemiSpin(size: SemiSpinSize.small)
                    : SemiIconTheme(
                        data: SemiIconThemeData(
                          color: theme.colorCascaderOptionIconDefault,
                          customSize: theme.widthCascaderOptionIcon,
                        ),
                        child:
                            widget.expandIcon ??
                            // item.tsx:173 `<IconChevronRight …>`。
                            const SemiIcon(SemiIcons.chevronRight),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  /// item.tsx:185-231 `highlight`（大小写不敏感逐段命中高亮，段间 separator）。
  InlineSpan _highlightSpan(
    SemiResolvedCascaderThemeData theme,
    List<String> searchText,
  ) {
    final children = <InlineSpan>[];
    final keyword = _inputValue;
    final baseStyle = TextStyle(
      color: _multiple
          ? theme.colorCascaderOptionMainTextDefault
          : theme.colorCascaderOptionMainTextDefault,
      fontWeight: theme.fontCascaderFontWeight,
    );
    final hitStyle = TextStyle(
      // cascader.scss:514-518 `-label-highlight`（与 -select 同式）。
      fontWeight: theme.fontCascaderSelectFontWeight,
      color: theme.colorCascaderSelectHighlight,
    );
    for (final (idx, item) in searchText.indexed) {
      if (keyword.isNotEmpty) {
        final lowerItem = item.toLowerCase();
        final lowerKeyword = keyword.toLowerCase();
        var searchFrom = 0;
        while (true) {
          final matchIndex = lowerItem.indexOf(lowerKeyword, searchFrom);
          if (matchIndex == -1) {
            final rest = item.substring(searchFrom);
            if (rest.isNotEmpty) {
              children.add(TextSpan(text: rest, style: baseStyle));
            }
            break;
          }
          final before = item.substring(searchFrom, matchIndex);
          if (before.isNotEmpty) {
            children.add(TextSpan(text: before, style: baseStyle));
          }
          children.add(
            TextSpan(
              text: item.substring(matchIndex, matchIndex + keyword.length),
              style: hitStyle,
            ),
          );
          searchFrom = matchIndex + keyword.length;
        }
      } else {
        children.add(TextSpan(text: item, style: baseStyle));
      }
      if (idx != searchText.length - 1) {
        children.add(TextSpan(text: widget.separator, style: baseStyle));
      }
    }
    return TextSpan(children: children);
  }

  /// item.tsx:389-405 `renderEmpty`（locale `emptyText: '暂无数据'`）。
  Widget _buildEmpty(SemiResolvedCascaderThemeData theme) {
    final content = widget.emptyContent;
    return Container(
      key: SemiCascader.emptyKey,
      padding: EdgeInsets.symmetric(
        // cascader.scss:344 `-option-empty` padding 简写。
        vertical: theme.spacingCascaderOptionEmptyPaddingY,
        horizontal: theme.spacingCascaderOptionEmptyPaddingX,
      ),
      decoration: BoxDecoration(
        // cascader.scss:340 `border-radius: $radius-cascader_option_empty`。
        borderRadius: BorderRadius.circular(theme.radiusCascaderOptionEmpty),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: theme.colorCascaderOptionEmptyTextDefault,
          fontSize: _CascaderMetrics.fontSizeRegular,
        ),
        child: _asWidget(content ?? _CascaderMetrics.localeEmptyText),
      ),
    );
  }
}

/// 搜索扁平行（foundation.ts `BasicData`）。
class _FlatCascaderRow {
  const _FlatCascaderRow({
    required this.key,
    required this.data,
    required this.pathData,
    required this.searchText,
    required this.disabled,
  });

  final String key;
  final SemiCascaderData data;
  final List<SemiCascaderData> pathData;

  /// 过滤字段路径（item.tsx `searchText`——高亮分段）。
  final List<String> searchText;
  final bool disabled;
}

/// 让插槽不参与 IntrinsicWidth 测量（tree_select 同款）。
class _IntrinsicWidthBlocker extends SingleChildRenderObjectWidget {
  const _IntrinsicWidthBlocker({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderIntrinsicWidthBlocker();
}

class _RenderIntrinsicWidthBlocker extends RenderProxyBox {
  @override
  double computeMaxIntrinsicWidth(double height) => 0;

  @override
  double computeMinIntrinsicWidth(double height) => 0;
}

/// 硬编码常量（HARDCODES 另列——上游片段逐字留档，生成器锚点断言）。
abstract final class _CascaderMetrics {
  /// cascader.scss:125/450 `@include font-size-regular`（= 14——选项/前缀
  /// 后缀/空态文本字号）。
  static const double fontSizeRegular = 14;

  /// cascader.scss:58 `-large .selection` `@include font-size-header-6`
  ///（`$font-size-header-6: 16px`，semi-theme-default/scss/variables.scss:61
  /// ——large 尺寸触发器文本号）。
  static const double selectionLargeFontSize = 16;

  /// zh_CN.ts:122 `emptyText: '暂无数据'`（Cascader locale）。
  static const String localeEmptyText = '暂无数据';

  /// index.tsx:225 `'aria-label': 'Cascader'`（触发器缺省语义标签）。
  static const String defaultSemanticsLabel = 'Cascader';

  /// 清空按钮语义（上游无 aria-label——Flutter 侧补）。
  static const String clearButtonSemantics = 'Clear Cascader value';

  /// index.tsx:202 `zIndex: popoverNumbers.DEFAULT_Z_INDEX`
  ///（popover/constants.ts:44 `DEFAULT_Z_INDEX: 1030`）。
  static const int popoverZIndex = 1030;

  /// `0 0 1px rgba(0, 0, 0, .3)` — `@include shadow-elevated` 第一层
  ///（semi-theme-default/scss/global.scss；select/treeSelect 先例同值）。
  static const BoxShadow shadowElevatedBlur = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.3),
    blurRadius: 1,
  );

  /// `0 4px 14px rgba(0, 0, 0, .1)` — `@include shadow-elevated` 第二层。
  static const BoxShadow shadowElevatedDrop = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.1),
    offset: Offset(0, 4),
    blurRadius: 14,
  );

  // note-only 上游片段（生成器锚点逐字留档）：
  // constants.ts:9 `SIZE_SET: ['small', 'large', 'default']`。
  // constants.ts:10 `VALIDATE_STATUS: ['success', 'default', 'error', 'warning']`。
  // constants.ts:13 `SHOW_NEXT_BY_CLICK: 'click'`。
  // constants.ts:14 `SHOW_NEXT_BY_HOVER: 'hover'`。
  // constants.ts:19 `SEARCH_POSITION_TRIGGER: 'trigger'`。
  // constants.ts:20 `SEARCH_POSITION_CUSTOM: 'custom'`。
  // constants.ts:21 `RELATED: 'related'`。
  // constants.ts:22 `UN_RELATED: 'unRelated'`。
  // constants.ts:16 `LEAF_ONLY_MERGE_TYPE: 'leafOnly'`。
  // constants.ts:17 `AUTO_MERGE_VALUE_MERGE_TYPE: 'autoMergeValue'`。
  // constants.ts:18 `NONE_MERGE_TYPE: 'none'`。
  // constants.ts:33 `VALUE_SPLIT = '_SEMI_CASCADER_SPLIT_'`。
  // index.tsx:198 `arrowIcon: <IconChevronDown />`。
  // index.tsx:985 `clearIcon ? clearIcon : <IconClear />`。
  // item.tsx:173 `return (<IconChevronRight className={…} />)`。
  // item.tsx:175 `return (<IconTick className={…} />)`。
  // index.tsx:213 `separator: ' / '`。
  // index.tsx:225 `'aria-label': 'Cascader'`。
  // index.tsx:1082 `role="combobox"`。
  // index.tsx:1107 `position ?? (direction === 'rtl' ? 'bottomRight' : 'bottomLeft')`。
  // index.tsx:202 `zIndex: popoverNumbers.DEFAULT_Z_INDEX`。
  // foundation.ts:286 `e.key === ESC_KEY`（Esc 收起）。
  // foundation.ts:26/754 `isEnterPress`（触发器 Enter → 切换展开）。
  // zh_CN.ts:122 `emptyText: '暂无数据'`。
  // cascader.scss:21 `cursor: pointer`（触发器指针）。
  // cascader.scss:521 `cursor: not-allowed`（disabled 选项指针）。
  // cascader.scss:307 `user-select: none`（disabled 文本不可选——Flutter 默认）。
  // cascader.scss:125 `@include font-size-regular`。
  // cascader.scss:58 `@include font-size-header-6`。
  // cascader.scss:548 `opacity: 0`（borderless 静默态箭头隐藏）。
}
