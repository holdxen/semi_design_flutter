// SemiTreeSelect — 树形选择器（Semi Design 组件移植）。
//
// 上游：packages/semi-foundation/treeSelect/{variables.scss, treeSelect.scss,
// rtl.scss, constants.ts, foundation.ts}、packages/semi-ui/treeSelect/index.tsx
// + 复用 tree 行渲染（treeNode.tsx/nodeList.tsx——树行与 semi_tree.dart 同源）
// + zh_CN.ts locale。主题对账 74 = 74 FIELDS + 0 MOTION + 0 INTERNAL
// （tool/generate_tree_select.py）——★1 死变量（上游未消费：
// `$color-treeSelect_input_disabled-border-default` 仅被 treeSelect.scss:99
// 注释行引用，照 select 先例保留字段不消费，docs 标注）。treeSelect.scss 无
// animation.scss（0 MOTION）。
//
// 触发器（选择框）消费 SemiTreeSelectThemeData；弹层树行复用 tree.scss 语义，
// 消费 SemiTreeThemeData（上游 treeSelect 直接 import tree.scss 渲染树行）。
//
// HARDCODES（另列）上游片段以注释逐字留档在 `_TreeSelectMetrics` / 调用点，
// 生成器 HARDCODES 锚点断言这些片段出现在本文件。
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart' show RenderProxyBox;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../overlay/tooltip_positioning.dart';
import '../theme/semi_icon_theme.dart';
import '../theme/semi_spin_theme.dart';
import '../theme/semi_spin_theme_data.dart';
import '../theme/semi_theme.dart';
import '../theme/semi_theme_data.dart';
import '../theme/semi_tree_select_theme.dart';
import '../theme/semi_tree_select_theme_data.dart';
import '../theme/semi_tree_theme.dart';
import '../theme/semi_tree_theme_data.dart';
import 'highlight_algorithm.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icon_data.dart';
import 'icon/semi_icons.dart';
import 'semi_checkbox.dart';
import 'semi_highlight.dart';
import 'semi_input.dart';
import 'semi_spin.dart';
import 'semi_tag.dart';
import 'semi_tooltip.dart';
import 'semi_tree.dart';

/// 搜索框位置（上游 `searchPosition`：constants.ts:14-15
/// `SEARCH_POSITION_DROPDOWN: 'dropdown'` / `SEARCH_POSITION_TRIGGER: 'trigger'`）。
enum SemiTreeSelectSearchPosition { dropdown, trigger }

/// 搜索框自定义渲染（上游 `searchRender: boolean | (inputProps) => node`）。
typedef SemiTreeSelectSearchBuilder = Widget Function(
  SemiTreeSearchProps props,
);

/// 树形选择器（上游 Semi TreeSelect）。
///
/// 触发器（treeSelect.scss）+ 弹层树（tree.scss 行语义，与 [SemiTree] 同源）。
/// 数据/展开/勾选/过滤/异步加载语义与 [SemiTree] 一致（treeUtil.ts +
/// foundation.ts）；选择回填、单选收起、标签关闭、清空、触发器内搜索是
/// TreeSelect 专属（treeSelect foundation.ts）。
///
/// ★未移植：disableStrictly、keyMaps/treeNodeLabelProp（固定 `key`/`label`
/// 域——[SemiTreeNodeData] 强类型）、renderFullLabel、triggerRender、
/// treeDataSimpleJson、dropdownStyle/optionListStyle/dropdownClassName、
/// getPopupContainer、stopPropagation、preventScroll（见 docs/semi_tree_select.md
/// 差异清单）。
class SemiTreeSelect extends StatefulWidget {
  const SemiTreeSelect({
    super.key,
    this.treeData = const <SemiTreeNodeData>[],
    this.value,
    this.defaultValue,
    this.multiple = false,
    this.checkRelation = SemiTreeCheckRelation.related,
    this.leafOnly = false,
    this.autoMergeValue = true,
    this.onChangeWithObject = false,
    this.disabled = false,
    this.expandAction = SemiTreeExpandAction.none,
    this.expandedKeys,
    this.defaultExpandedKeys,
    this.expandAll = false,
    this.defaultExpandAll = false,
    this.autoExpandParent = false,
    this.expandIcon,
    this.motionExpand = true,
    this.showLine = false,
    this.labelEllipsis,
    this.filterTreeNode,
    this.treeNodeFilterProp = 'label',
    this.showFilteredOnly = false,
    this.searchPosition = SemiTreeSelectSearchPosition.dropdown,
    this.searchPlaceholder,
    this.searchAutoFocus = false,
    this.showSearchClear = true,
    this.searchRender,
    this.remote = false,
    this.renderLabel,
    this.renderSelectedItem,
    this.emptyContent,
    this.virtualize,
    this.loadData,
    this.loadedKeys,
    this.onLoad,
    this.placeholder,
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
    this.maxTagCount,
    this.showRestTagsPopover = false,
    this.restTagsPopoverPosition = SemiTooltipPosition.top,
    this.triggerTagWrap = false,
    this.position = SemiTooltipPosition.bottomLeft,
    this.dropdownMatchSelectWidth = true,
    this.autoAdjustOverflow = true,
    this.motion = true,
    this.mouseEnterDelay,
    this.mouseLeaveDelay,
    this.zIndex = _TreeSelectMetrics.popoverZIndex,
    this.defaultOpen = false,
    this.clickToHide = true,
    this.clickTriggerToHide = true,
    this.outerTopSlot,
    this.outerBottomSlot,
    this.onChange,
    this.onSelect,
    this.onExpand,
    this.onSearch,
    this.onClear,
    this.onFocus,
    this.onBlur,
    this.onVisibleChange,
    this.semanticsLabel,
  });

  /// Key of the clear button slot.
  static const Key clearButtonKey = Key('SemiTreeSelect.clearButton');

  /// Key of the option list (弹层树列).
  static const Key listKey = Key('SemiTreeSelect.list');

  /// Key of the filter input.
  static const Key searchInputKey = Key('SemiTreeSelect.searchInput');

  /// Key of the empty row.
  static const Key emptyKey = Key('SemiTreeSelect.empty');

  /// 树数据（`List<SemiTreeNodeData>`；引用变化触发实体重建——建议 const/稳定引用）。
  final List<SemiTreeNodeData> treeData;

  /// 选中值（单选用 key/value/[SemiTreeNodeData]；多选用 List；非 null 即受控
  /// ——交互只回调。上游 `'value' in props` 口径的 Flutter 约定变体，见 docs）。
  final Object? value;

  /// 未受控初值。
  final Object? defaultValue;

  /// 多选（checkbox 模式；行点击与 checkbox 都切换勾选）。
  final bool multiple;

  /// 勾选联动口径（`related` 级联 + 半选 / `unRelated` 独立）。
  final SemiTreeCheckRelation checkRelation;

  /// onChange 载荷只保留叶子键（normalizeKeyList leafOnly）。
  final bool leafOnly;

  /// 关联模式合并父键（normalizeKeyList，去祖先）。
  final bool autoMergeValue;

  /// onChange 回传数据对象（否则回传 value ?? key）。
  final bool onChangeWithObject;

  /// 禁用（触发器 + 树交互全部关闭）。
  final bool disabled;

  /// 展开动作（none | click | doubleClick）。
  final SemiTreeExpandAction expandAction;

  /// 展开键（非 null 即受控；变更时按 autoExpandParent 重算）。
  final List<String>? expandedKeys;

  /// 未受控展开初值（calcExpandedKeys autoExpandParent 缺省 true——treeUtil.ts:387）。
  final List<String>? defaultExpandedKeys;

  /// 数据变化时自动全展开（上游 `expandAll`）。
  final bool expandAll;

  /// 首帧全展开。
  final bool defaultExpandAll;

  /// 展开祖先（受控展开变更计算用；首帧恒 true——上游 `!prevProps` 口径）。
  final bool autoExpandParent;

  /// 自定义展开图标：Widget 或 [SemiTreeExpandIconBuilder]（null 走默认三角）。
  final Object? expandIcon;

  /// 展开/收起动画（`motionExpand`；虚拟化模式不播——上游同）。
  final bool motionExpand;

  /// 展示缩进引导线。
  final bool showLine;

  /// 标题省略（缺省跟随 virtualize——上游 `labelEllipsis ?? virtualize` quirk）。
  final bool? labelEllipsis;

  /// 过滤开关：bool 或 [SemiTreeFilter]（null/false 不渲染搜索框）。
  final Object? filterTreeNode;

  /// 过滤字段（缺省 `'label'`；支持 label/value/key/icon）。
  final String treeNodeFilterProp;

  /// 搜索时只展示命中节点及其祖先/后代（`showFilteredOnly`）。
  final bool showFilteredOnly;

  /// 搜索框位置（缺省 `dropdown` 弹层内；`trigger` 触发器内）。
  final SemiTreeSelectSearchPosition searchPosition;

  /// 搜索占位文案（缺省 locale「搜索」）。
  final String? searchPlaceholder;

  /// 打开时自动聚焦搜索框（`searchAutoFocus`）。
  final bool searchAutoFocus;

  /// 搜索框清除按钮（缺省 true）。
  final bool showSearchClear;

  /// 搜索框自定义：false 隐藏；[SemiTreeSelectSearchBuilder] 自定义；null 走默认。
  final Object? searchRender;

  /// 远程搜索（跳过本地过滤，只回调 onSearch；`remote`）。
  final bool remote;

  /// 标题渲染器（[SemiTreeLabelBuilder]）。
  final SemiTreeLabelBuilder? renderLabel;

  /// 选中项回填自定义。单选 `Widget Function(SemiTreeNodeData)`；多选
  /// `Widget Function(SemiTreeNodeData, {int index, bool disabled, VoidCallback
  /// onClose})`。★上游多选返回 `{isRenderInTag, content}`——照 select 先例拍平
  /// （结果按原样渲染，onClose 自接），见 docs。
  final Object? renderSelectedItem;

  /// 空态内容（String | Widget；缺省「暂无数据」。★上游 `emptyContent: null`
  /// 隐藏空态——本移植无此三态，传 `const SizedBox.shrink()` 近似，见 docs）。
  final Object? emptyContent;

  /// 虚拟化参数（非 null 走 `ListView.builder`；运动不播）。
  final SemiTreeVirtualize? virtualize;

  /// 异步加载（展开未加载节点时调用；完成后记入 loadedKeys）。
  final Future<void> Function(SemiTreeNodeData data)? loadData;

  /// 已加载键（非 null 即受控）。
  final List<String>? loadedKeys;

  /// 加载完成回调（上游 onLoad(loadedKeys, node)）。
  final void Function(Set<String> loadedKeys, SemiTreeNodeData data)? onLoad;

  /// 占位文案（无选中时回显）。
  final String? placeholder;

  /// 尺寸（上游 `size: 'small' | 'default' | 'large'`——
  /// constants.ts:13 `SIZE_SET: ['small', 'large', 'default']`；Flutter 侧
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

  /// 校验状态（上游 `validateStatus: 'error' | 'warning' | 'default'`——
  /// foundation.ts:30；Flutter 侧 normal = 上游 default）。
  final SemiInputStatus validateStatus;

  /// 前缀（String | Widget）。
  final Object? prefix;

  /// 内嵌标签（String | Widget；`insetLabel`）。
  final Object? insetLabel;

  /// 后缀（String | Widget）。
  final Object? suffix;

  /// 多选标签折叠上限（超出折叠为 "+N"）。
  final int? maxTagCount;

  /// "+N" 悬停展开其余标签（`showRestTagsPopover`）。
  final bool showRestTagsPopover;

  /// "+N" 弹层位置。
  final SemiTooltipPosition restTagsPopoverPosition;

  /// 多选 + 触发器搜索时标签换行（`triggerTagWrap`）。
  final bool triggerTagWrap;

  /// 弹层位置（上游缺省 `position ? position : 'bottomLeft'`）。
  final SemiTooltipPosition position;

  /// 弹层宽度跟随触发器（`dropdownMatchSelectWidth`）。
  final bool dropdownMatchSelectWidth;

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

  /// 单选后收起弹层（`clickToHide`，缺省 true）。
  final bool clickToHide;

  /// 点击触发器收起展开中的弹层（`clickTriggerToHide`，缺省 true）。
  final bool clickTriggerToHide;

  /// 弹层顶部外挂槽（`outerTopSlot`；存在时替换默认搜索框位置）。
  final Widget? outerTopSlot;

  /// 弹层底部外挂槽（`outerBottomSlot`）。
  final Widget? outerBottomSlot;

  /// 值变更（单选 value/key；多选 `List<value/key>`；onChangeWithObject 时数据对象）。
  final ValueChanged<Object?>? onChange;

  /// 选择回调（上游 `onSelect(selectedKey, selected, node)`；★单选恒 true quirk）。
  final void Function(String selectedKey, bool selected, SemiTreeNodeData node)?
  onSelect;

  /// 展开回调（上游 `onExpand(expandedKeys, {expanded, node})`）。
  final void Function(
    List<String> expandedKeys,
    bool expanded,
    SemiTreeNodeData node,
  )?
  onExpand;

  /// 搜索回调（上游 `onSearch(input, filteredExpandedKeys, filteredNodes)`；
  /// `remote` 时后两者为空）。
  final void Function(
    String input,
    List<String> filteredExpandedKeys,
    List<SemiTreeNodeData> filteredNodes,
  )?
  onSearch;

  /// 清空回调（上游 `onClear(e)`）。
  final VoidCallback? onClear;

  /// 触发器聚焦回调（上游 `onFocus`）。
  final VoidCallback? onFocus;

  /// 触发器失焦回调（上游 `onBlur`——点击外部/单选收起时触发）。
  final VoidCallback? onBlur;

  /// 弹层显隐回调（上游 `onVisibleChange`）。
  final ValueChanged<bool>? onVisibleChange;

  /// 触发器语义标签（上游缺省 `'aria-label': 'TreeSelect'`）。
  final String? semanticsLabel;

  @override
  State<SemiTreeSelect> createState() => _SemiTreeSelectState();
}

/// 实体（treeUtil.ts `convertDataToEntities`）。
class _TreeEntity {
  _TreeEntity({
    required this.key,
    required this.data,
    required this.level,
    required this.pos,
    required this.parent,
  });

  final String key;
  final SemiTreeNodeData data;
  final int level;
  final String pos;
  final _TreeEntity? parent;
  final List<_TreeEntity> children = <_TreeEntity>[];
}

/// 拍平行（treeUtil.ts `flattenTreeData`；`isEnd` 供缩进引导线/折线判断）。
class _FlatNode {
  const _FlatNode({required this.entity, required this.isEnd});

  final _TreeEntity entity;
  final List<bool> isEnd;
}

/// 行级派生状态（treeSelect foundation.ts:320-372 `getTreeNodeProps`）。
class _NodeProps {
  const _NodeProps({
    required this.expanded,
    required this.selected,
    required this.checked,
    required this.halfChecked,
    required this.loading,
    required this.loaded,
    required this.filtered,
  });

  final bool expanded;
  final bool selected;
  final bool checked;
  final bool halfChecked;
  final bool loading;
  final bool loaded;
  final bool filtered;
}

class _SemiTreeSelectState extends State<SemiTreeSelect> {
  // -- data ------------------------------------------------------------------
  late List<_TreeEntity> _roots = <_TreeEntity>[];
  late Map<String, _TreeEntity> _entities = <String, _TreeEntity>{};
  late Map<String, String> _valueEntities = <String, String>{};
  Object? _lastTreeData;

  // -- selection -------------------------------------------------------------
  List<String> _selectedKeys = <String>[];
  Set<String> _checked = <String>{};
  Set<String> _halfChecked = <String>{};
  Set<String> _realChecked = <String>{};

  // -- expand / filter -------------------------------------------------------
  Set<String> _expanded = <String>{};
  Set<String> _filteredExpanded = <String>{};
  Set<String> _filteredKeys = <String>{};
  Set<String> _filteredShownKeys = <String>{};
  String _inputValue = '';

  // -- flatten / motion ------------------------------------------------------
  List<_FlatNode> _flattenNodes = <_FlatNode>[];
  List<_FlatNode>? _cachedFlatten;
  Set<String> _motionKeys = <String>{};
  String _motionType = '';

  // -- load ------------------------------------------------------------------
  Set<String> _loaded = <String>{};
  Set<String> _loading = <String>{};

  // -- trigger / popover -----------------------------------------------------
  bool _open = false;
  bool _isFocus = false;
  bool _isHovering = false;
  bool _pressed = false;
  bool _clearHovered = false;
  bool _clearPressed = false;
  bool _inputTriggerFocus = false;
  int _rePosKey = 0;
  double? _panelMinWidth;

  final FocusNode _triggerFocusNode = FocusNode(debugLabel: 'SemiTreeSelect');
  final FocusNode _inputFocusNode = FocusNode(
    debugLabel: 'SemiTreeSelect.input',
  );
  final TextEditingController _inputController = TextEditingController();
  final GlobalKey _triggerKey = GlobalKey();

  bool get _multiple => widget.multiple;

  bool get _filterable =>
      widget.filterTreeNode != null && widget.filterTreeNode != false;

  bool get _searching => _inputValue.isNotEmpty;

  bool get _showFilteredOnly => _searching && widget.showFilteredOnly;

  bool get _expandControlled => widget.expandedKeys != null;

  bool get _valueControlled => widget.value != null;

  bool get _loadControlled => widget.loadedKeys != null;

  bool get _labelEllipsis =>
      widget.labelEllipsis ?? (widget.virtualize != null);

  bool get _isTriggerSearch =>
      _filterable &&
      widget.searchPosition == SemiTreeSelectSearchPosition.trigger;

  bool get _isDropdownSearch =>
      _filterable &&
      widget.searchPosition == SemiTreeSelectSearchPosition.dropdown;

  Set<String> get _visibleExpanded =>
      _searching ? _filteredExpanded : _expanded;

  @override
  void initState() {
    super.initState();
    _lastTreeData = widget.treeData;
    _rebuildEntities();
    _loaded = widget.loadedKeys?.toSet() ?? <String>{};
    _initialExpanded();
    _syncSelectionFromValue(initial: true);
    _refreshFlatten();
    if (widget.defaultOpen && !widget.disabled) {
      _open = true;
      _recordPanelWidth();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onVisibleChange?.call(true);
      });
    }
    // foundation.ts:213-227 `init`：defaultOpen / triggerSearchAutoFocus 打开。
    final triggerSearchAutoFocus =
        widget.searchAutoFocus && _isTriggerSearch && !widget.disabled;
    if (triggerSearchAutoFocus) {
      _open = true;
      _isFocus = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onFocus?.call();
        _focusInput();
      });
    }
  }

  @override
  void didUpdateWidget(SemiTreeSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    var dataChanged = false;
    if (!identical(widget.treeData, _lastTreeData)) {
      _lastTreeData = widget.treeData;
      _rebuildEntities();
      dataChanged = true;
      // getDerivedStateFromProps：expandAll 数据变化 → 全展开。
      if (widget.expandAll) {
        _expanded = _entities.keys.toSet();
      }
      // ================== rePosKey ==================
      _rePosKey += 1;
    }
    if (widget.expandedKeys != null &&
        (!_listEquals(widget.expandedKeys, oldWidget.expandedKeys) ||
            widget.autoExpandParent != oldWidget.autoExpandParent)) {
      _expanded = _calcExpandedKeys(
        widget.expandedKeys!,
        autoExpandParent: widget.autoExpandParent,
      );
      _motionKeys = <String>{};
      _motionType = '';
      _cachedFlatten = null;
      _refreshFlatten();
    }
    if (widget.value != oldWidget.value ||
        (dataChanged && widget.value != null)) {
      if (widget.value != null || oldWidget.value != null) {
        _syncSelectionFromValue();
        // ================== rePosKey ==================
        _rePosKey += 1;
      }
    } else if (dataChanged && !_valueControlled) {
      // getDerivedStateFromProps `updateKeys`：数据变化时裁掉消失的键。
      _updateKeysAfterDataChange();
    }
    if (widget.loadedKeys != null &&
        !_listEquals(widget.loadedKeys, oldWidget.loadedKeys)) {
      _loaded = widget.loadedKeys!.toSet();
    }
    if (dataChanged && _searching && _filterable && !widget.remote) {
      _applyFilter();
    } else if (dataChanged || _searching) {
      _refreshFlatten();
    }
  }

  @override
  void dispose() {
    _triggerFocusNode.dispose();
    _inputFocusNode.dispose();
    _inputController.dispose();
    super.dispose();
  }

  // -- data (treeUtil.ts `convertDataToEntities`) ----------------------------

  void _rebuildEntities() {
    final roots = <_TreeEntity>[];
    final entities = <String, _TreeEntity>{};
    final valueEntities = <String, String>{};

    void walk(
      List<SemiTreeNodeData> list,
      _TreeEntity? parent,
      String parentPos,
      int level,
    ) {
      for (var i = 0; i < list.length; i++) {
        final data = list[i];
        final entity = _TreeEntity(
          key: data.key,
          data: data,
          level: level,
          pos: '$parentPos-$i',
          parent: parent,
        );
        entities[entity.key] = entity;
        if (parent == null) {
          roots.add(entity);
        } else {
          parent.children.add(entity);
        }
        if (data.value != null) {
          valueEntities[data.value.toString()] = entity.key;
        }
        if (data.children != null && data.children!.isNotEmpty) {
          walk(data.children!, entity, entity.pos, level + 1);
        }
      }
    }

    walk(widget.treeData, null, '0', 0);
    _roots = roots;
    _entities = entities;
    _valueEntities = valueEntities;
  }

  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null || b == null) {
      return a == b;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  // -- value / selection -----------------------------------------------------

  /// treeUtil.ts:199-224 `findKeysForValues`（value 先查 valueEntities，缺失按
  /// key 处理；[SemiTreeNodeData] 取 key）。
  List<String> _findKeysForValues(Object? value, {required bool multiple}) {
    if (value == null) {
      return <String>[];
    }
    var list = value is List ? List<Object?>.of(value) : <Object?>[value];
    if (!multiple && list.isNotEmpty) {
      list = [list.first];
    }
    final result = <String>[];
    for (final item in list) {
      if (item == null) {
        continue;
      }
      if (item is SemiTreeNodeData) {
        result.add(item.key);
        continue;
      }
      final asString = item.toString();
      result.add(_valueEntities[asString] ?? asString);
    }
    return result;
  }

  void _initialExpanded() {
    if (widget.expandedKeys != null) {
      _expanded = _calcExpandedKeys(
        widget.expandedKeys!,
        // getDerivedStateFromProps `props.autoExpandParent || !prevProps` →
        // 首帧恒带祖先。
        autoExpandParent: true,
      );
      return;
    }
    if (widget.defaultExpandAll || widget.expandAll) {
      _expanded = _entities.keys.toSet();
      return;
    }
    if (widget.defaultExpandedKeys != null) {
      // treeUtil.ts:387 `calcExpandedKeys` autoExpandParent 缺省 true。
      _expanded = _calcExpandedKeys(
        widget.defaultExpandedKeys!,
        autoExpandParent: true,
      );
      return;
    }
    final initialValue = widget.defaultValue ?? widget.value;
    if (initialValue != null) {
      // getDerivedStateFromProps：calcExpandedKeysForValues →
      // findAncestorKeys(keys, false)（treeUtil.ts:399-402）。
      final keys = _findKeysForValues(initialValue, multiple: widget.multiple);
      _expanded = _findAncestorKeys(keys, self: false);
    }
  }

  Set<String> _calcExpandedKeys(
    List<String> keys, {
    required bool autoExpandParent,
  }) => autoExpandParent ? _findAncestorKeys(keys, self: true) : keys.toSet();

  void _syncSelectionFromValue({bool initial = false}) {
    final value = initial
        ? (widget.value ?? widget.defaultValue)
        : widget.value;
    if (!widget.multiple) {
      _selectedKeys = _findKeysForValues(value, multiple: false);
      return;
    }
    final keys = _findKeysForValues(value, multiple: true);
    if (widget.checkRelation == SemiTreeCheckRelation.unRelated) {
      _realChecked = keys.toSet();
    } else {
      final result = _calcCheckedKeysFrom(keys);
      _checked = result.$1;
      _halfChecked = result.$2;
    }
  }

  /// treeUtil.ts:640-643 `updateKeys`：数据变化后丢弃消失的键（未受控）。
  void _updateKeysAfterDataChange() {
    List<String> keep(List<String> keys) => [
      for (final key in keys)
        if (_entities.containsKey(key)) key,
    ];

    if (!widget.multiple) {
      _selectedKeys = keep(_selectedKeys);
      return;
    }
    if (widget.checkRelation == SemiTreeCheckRelation.unRelated) {
      _realChecked = keep(_realChecked.toList()).toSet();
    } else {
      final seeds = keep(_checked.toList());
      final result = _calcCheckedKeysFrom(seeds);
      _checked = result.$1;
      _halfChecked = result.$2;
    }
  }

  Object? _getValueOrKey(SemiTreeNodeData data) => data.value ?? data.key;

  List<SemiTreeNodeData> _dataForKeys(List<String> keys) => [
    for (final key in keys)
      _entities[key]?.data ??
          // foundation.ts:294-302 `constructDataForValue`（key 缺失兜底）。
          SemiTreeNodeData(key: key, label: key, value: key),
  ];

  /// foundation.ts:279-292 `findDataForValue` + :304-311
  /// `getDataForKeyNotInKeyEntities`。
  SemiTreeNodeData _dataForKey(String key) => _dataForKeys([key]).first;

  Object? _payloadForKeys(List<String> keys) {
    if (widget.onChangeWithObject) {
      return _dataForKeys(keys);
    }
    return [for (final data in _dataForKeys(keys)) _getValueOrKey(data)];
  }

  /// foundation.ts:407-423 `_notifyMultipleChange`（autoMergeValue → 去祖先、
  /// leafOnly → 只留叶子；载荷 value ?? key）。
  void _notifyMultipleValue(Iterable<String> keys) {
    var keyList = keys.toList();
    if (widget.checkRelation == SemiTreeCheckRelation.related &&
        widget.autoMergeValue) {
      keyList = _normalizeKeyList(
        keyList,
        leafOnly: widget.leafOnly,
        flag: true,
      );
    }
    widget.onChange?.call(_payloadForKeys(keyList));
  }

  /// foundation.ts:425-439 `_notifyChange`（单选载荷 value ?? key）。
  void _notifySingleValue(String key) {
    final data = _dataForKey(key);
    widget.onChange?.call(
      widget.onChangeWithObject ? data : _getValueOrKey(data),
    );
  }

  // -- checked cascades (treeUtil.ts:226-586) --------------------------------

  List<String> _siblingKeys(_TreeEntity entity) => [
    for (final sibling in (entity.parent?.children ?? _roots)) sibling.key,
  ];

  List<String> _findDescendantKeys(
    Iterable<String> keys, {
    required bool self,
  }) {
    final result = <String>[];
    void walk(_TreeEntity entity) {
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
    void walk(_TreeEntity entity) {
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

    void calcCurrLevel(_TreeEntity node) {
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

    void calcCurrLevel(_TreeEntity node) {
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

    void calcCurrLevel(_TreeEntity node) {
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

  // -- filtering (foundation.ts:628-676) -------------------------------------

  bool _matches(String input, SemiTreeNodeData data) {
    final filter = widget.filterTreeNode;
    if (filter == null || filter == false) {
      return true;
    }
    final target = switch (widget.treeNodeFilterProp) {
      'label' =>
        data.label is String
            ? data.label! as String
            : (data.label?.toString() ?? ''),
      'value' => data.value?.toString() ?? '',
      'key' => data.key,
      'icon' => data.icon?.toString() ?? '',
      _ => '',
    };
    if (filter is SemiTreeFilter) {
      return filter(input, target, data);
    }
    return target.toLowerCase().contains(input.toLowerCase());
  }

  void _applyFilter() {
    final matched = <String>[];
    final matchedData = <SemiTreeNodeData>[];
    for (final entity in _entities.values) {
      if (_matches(_inputValue, entity.data)) {
        matched.add(entity.key);
        matchedData.add(entity.data);
      }
    }
    _lastFilteredNodes = matchedData;
    final expandedKeys = _findAncestorKeys(matched, self: false);
    final shown = <String>{
      ..._findDescendantKeys(matched, self: true),
      ...expandedKeys,
    };
    _filteredKeys = matched.toSet();
    _filteredExpanded = expandedKeys;
    _filteredShownKeys = shown;
    _motionKeys = <String>{};
    _motionType = '';
    _cachedFlatten = null;
    _flattenNodes = _flatten(
      expandedKeys,
      shown: widget.showFilteredOnly ? shown : null,
    );
  }

  List<SemiTreeNodeData> _lastFilteredNodes = <SemiTreeNodeData>[];

  /// foundation.ts:628-676 `handleInputChange`（remote 只回调不本地过滤）。
  void _handleSearch(String value) {
    _inputValue = value;
    if (widget.remote) {
      setState(() {});
      widget.onSearch?.call(value, const [], const []);
      _rePosKey += 1;
      return;
    }
    setState(() {
      if (!_filterable) {
        return;
      }
      if (value.isEmpty) {
        // foundation.ts:648-651：清空搜索时把选中项祖先补进展开集（未受控）。
        if (!_expandControlled) {
          _expanded = {
            ..._expanded,
            ..._findAncestorKeys(_selectedKeys, self: false),
          };
        }
        _filteredKeys = <String>{};
        _filteredExpanded = <String>{};
        _filteredShownKeys = <String>{};
        _lastFilteredNodes = <SemiTreeNodeData>[];
        _motionKeys = <String>{};
        _motionType = '';
        _cachedFlatten = null;
        _flattenNodes = _flatten(_expanded);
      } else {
        _applyFilter();
      }
    });
    widget.onSearch?.call(
      value,
      _filteredExpanded.toList(),
      _lastFilteredNodes,
    );
    _rePosKey += 1;
  }

  /// foundation.ts:607-626 `clearInput`（过滤复位 + 展开选中项祖先）。
  void _clearInput() {
    final expandedKeys = <String>{..._expanded};
    if (!_expandControlled) {
      expandedKeys.addAll(_findAncestorKeys(_selectedKeys, self: false));
    }
    setState(() {
      _expanded = expandedKeys;
      _inputValue = '';
      _filteredKeys = <String>{};
      _filteredExpanded = <String>{};
      _filteredShownKeys = <String>{};
      _lastFilteredNodes = <SemiTreeNodeData>[];
      _motionKeys = <String>{};
      _motionType = '';
      _cachedFlatten = null;
      _flattenNodes = _flatten(_expanded);
    });
    _inputController.clear();
    _rePosKey += 1;
  }

  // -- flatten (treeUtil.ts:51-99) -------------------------------------------

  List<_FlatNode> _flatten(Set<String> expandedKeys, {Set<String>? shown}) {
    final result = <_FlatNode>[];
    void walk(List<_TreeEntity> list, List<bool> isEndPrefix) {
      for (var i = 0; i < list.length; i++) {
        final entity = list[i];
        final isEnd = [...isEndPrefix, i == list.length - 1];
        final visible = shown == null || shown.contains(entity.key);
        if (visible) {
          result.add(_FlatNode(entity: entity, isEnd: isEnd));
        }
        if (expandedKeys.contains(entity.key) &&
            (shown == null || shown.contains(entity.key))) {
          walk(entity.children, isEnd);
        }
      }
    }

    walk(_roots, const <bool>[]);
    return result;
  }

  void _refreshFlatten() {
    _flattenNodes = _flatten(
      _visibleExpanded,
      shown: _showFilteredOnly ? _filteredShownKeys : null,
    );
  }

  // -- node props ------------------------------------------------------------

  _NodeProps _nodeProps(_TreeEntity entity) {
    final key = entity.key;
    final related = widget.checkRelation == SemiTreeCheckRelation.related;
    return _NodeProps(
      expanded: _visibleExpanded.contains(key),
      selected: _selectedKeys.contains(key),
      checked: related ? _checked.contains(key) : _realChecked.contains(key),
      halfChecked: related && _halfChecked.contains(key),
      loading: _loading.contains(key) && !_loaded.contains(key),
      loaded: _loaded.contains(key),
      filtered: _filteredKeys.contains(key),
    );
  }

  bool _isLeaf(_TreeEntity entity) {
    final data = entity.data;
    final hasChildren = data.children?.isNotEmpty == true;
    if (data.isLeaf == false) {
      return false;
    }
    if (widget.loadData != null) {
      return data.isLeaf == true ||
          (_loaded.contains(entity.key) && !hasChildren);
    }
    return data.isLeaf == true || !hasChildren;
  }

  bool _isDisabled(_TreeEntity entity) =>
      widget.disabled || entity.data.disabled;

  // -- popover open/close ----------------------------------------------------

  void _recordPanelWidth() {
    if (!widget.dropdownMatchSelectWidth) return;
    final box = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) _panelMinWidth = box.size.width;
  }

  void _openMenu() {
    if (_open) return;
    setState(() => _open = true);
    _recordPanelWidth();
    widget.onVisibleChange?.call(true);
    if (widget.searchAutoFocus && _isDropdownSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusInput();
      });
    }
  }

  /// foundation.ts:496-501 `close`（motionKeys 复位——收起动画不残留）。
  void _closeMenu() {
    if (!_open) return;
    setState(() {
      _open = false;
      _motionKeys = <String>{};
    });
    widget.onVisibleChange?.call(false);
    // foundation.ts:930-939 `handleAfterClose`：弹层收起后 clearInput 复位。
    if (_filterable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _clearInput();
      });
    }
  }

  /// SemiTooltip `onVisibleChange`：barrier 点击 = 上游 clickOutside
  /// （foundation.ts:441-446 → blur + close）；内部收起走 _closeMenu。
  void _handleTooltipVisibleChange(bool visible) {
    if (!mounted) return;
    if (visible == _open) return;
    if (visible) {
      _openMenu();
      return;
    }
    // foundation.ts:918-928 `handlePopoverVisibleChange(false)`：先清空输入。
    if (_filterable) {
      _inputValue = '';
      _inputController.clear();
    }
    _closeMenu();
    _handleTriggerBlur();
  }

  /// foundation.ts:503-522 `handleClick`。
  void _handleTriggerTap() {
    if (widget.disabled) return;
    // 键盘可达（上游 tabIndex=0 + DOM focus 跟随点击）。
    _triggerFocusNode.requestFocus();
    if (!_isFocus) {
      _handleTriggerFocus();
    }
    if (_open) {
      // 触发器内搜索且有输入时不收起（foundation.ts:514-516）。
      if (_isTriggerSearch && _inputValue.isNotEmpty) {
        return;
      }
      if (widget.clickTriggerToHide) {
        _closeMenu();
      }
    } else {
      _openMenu();
    }
  }

  /// foundation.ts:459-463 `handleTriggerFocus`。
  void _handleTriggerFocus() {
    if (_isFocus) return;
    setState(() => _isFocus = true);
    widget.onFocus?.call();
  }

  /// foundation.ts:477-485 `handlerTriggerBlur`。
  void _handleTriggerBlur() {
    if (!_isFocus) return;
    setState(() => _isFocus = false);
    widget.onBlur?.call();
  }

  /// foundation.ts:313-318 `handleKeyDown`（ESC 收起）。
  void _handleEsc() {
    if (_open) {
      _closeMenu();
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (widget.disabled) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      // index.tsx:1181 `onKeyDown={this.foundation.handleKeyDown}` +
      // foundation.ts:314 `e.key === ESC_KEY`。
      if (!_open) return KeyEventResult.ignored;
      _handleEsc();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      // foundation.ts:528-531 `handleSelectionEnterPress`（isEnterPress）。
      _handleTriggerTap();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // -- selection actions (foundation.ts) -------------------------------------

  /// foundation.ts:690-707 `handleSingleSelect`（★onSelect 恒 true quirk；
  /// clickToHide 且（无展开动作或无子节点）时收起 + blur）。
  void _handleSingleSelect(_TreeEntity entity) {
    final key = entity.key;
    final selected = _selectedKeys.contains(key);
    widget.onSelect?.call(key, true, entity.data);
    if (!selected) {
      _notifySingleValue(key);
      if (!_valueControlled) {
        setState(() => _selectedKeys = [key]);
      }
    }
    if (widget.clickToHide &&
        (widget.expandAction == SemiTreeExpandAction.none ||
            entity.data.children == null)) {
      _closeMenu();
      _handleTriggerBlur();
    }
  }

  /// foundation.ts:720-758 `handleMultipleSelect`。
  void _handleMultipleSelect(_TreeEntity entity) {
    final key = entity.key;
    if (widget.checkRelation == SemiTreeCheckRelation.unRelated) {
      final next = <String>{..._realChecked};
      final bool targetStatus;
      if (next.contains(key)) {
        next.remove(key);
        targetStatus = false;
      } else {
        next.add(key);
        targetStatus = true;
      }
      widget.onSelect?.call(key, targetStatus, entity.data);
      _notifyMultipleValue(next);
      if (!_valueControlled) {
        setState(() => _realChecked = next);
      }
    } else {
      final checked = _checked.contains(key);
      final targetStatus = !checked;
      final result = targetStatus
          ? _checkedForChecked(key)
          : _checkedForUnchecked(key);
      widget.onSelect?.call(key, targetStatus, entity.data);
      _notifyMultipleValue(result.$1);
      if (!_valueControlled) {
        setState(() {
          _checked = result.$1;
          _halfChecked = result.$2;
        });
      }
    }
    // foundation.ts:755-757：触发器内搜索选中后清空输入。
    if (_isTriggerSearch && _inputValue.isNotEmpty) {
      setState(() {
        _inputValue = '';
      });
      _inputController.clear();
    }
    _rePosKey += 1;
  }

  /// foundation.ts:678-688 `handleNodeSelect`（disabled 拦截）。
  void _handleNodeSelect(_TreeEntity entity) {
    if (_isDisabled(entity)) {
      return;
    }
    if (!_multiple) {
      _handleSingleSelect(entity);
    } else {
      _handleMultipleSelect(entity);
    }
    if (widget.expandAction == SemiTreeExpandAction.click) {
      _toggleExpand(entity);
    }
  }

  /// foundation.ts:574-605 `removeTag`（标签关闭 → 反勾选级联 + onSelect false）。
  void _removeTag(String key) {
    final item = _dataForKey(key);
    if (item.disabled) {
      return;
    }
    if (widget.checkRelation == SemiTreeCheckRelation.unRelated) {
      final next = <String>{..._realChecked}..remove(key);
      _notifyMultipleValue(next);
      if (!_valueControlled) {
        setState(() => _realChecked = next);
      }
    } else {
      final result = _checkedForUnchecked(key);
      _notifyMultipleValue(result.$1);
      if (!_valueControlled) {
        setState(() {
          _checked = result.$1;
          _halfChecked = result.$2;
        });
      }
    }
    widget.onSelect?.call(key, false, item);
    _rePosKey += 1;
  }

  /// foundation.ts:534-562 `handleClear`（单选回 null / 多选回 []；触发器内
  /// 搜索有输入时先复位输入）。
  void _handleClear() {
    if (widget.disabled) return;
    widget.onChange?.call(_multiple ? <Object?>[] : null);
    if (!_valueControlled) {
      setState(() {
        _selectedKeys = <String>[];
        _checked = <String>{};
        _halfChecked = <String>{};
        _realChecked = <String>{};
      });
    }
    if (_isTriggerSearch && _inputValue.isNotEmpty) {
      if (_selectedKeys.isEmpty) {
        _handleSearch('');
      } else {
        _clearInput();
      }
    }
    widget.onClear?.call();
    _rePosKey += 1;
  }

  bool get _hasValue {
    if (_multiple) {
      return widget.checkRelation == SemiTreeCheckRelation.related
          ? _checked.isNotEmpty
          : _realChecked.isNotEmpty;
    }
    return _selectedKeys.isNotEmpty;
  }

  /// index.tsx:866-872 `showClearBtn`。
  bool get _showClearButton {
    final triggerSearchHasInputValue =
        _isTriggerSearch && _inputValue.isNotEmpty;
    return widget.showClear &&
        (_hasValue || triggerSearchHasInputValue) &&
        !widget.disabled &&
        (_open || _isHovering);
  }

  /// foundation.ts:879-893 `getRenderTextInSingle`。
  Object? _renderTextInSingle() {
    if (_selectedKeys.isEmpty) {
      return null;
    }
    final item = _dataForKey(_selectedKeys.first);
    final custom = widget.renderSelectedItem;
    if (custom is Widget Function(SemiTreeNodeData)) {
      return custom(item);
    }
    return item.label;
  }

  // -- expand / load (foundation.ts:789-874 + tree semantics) ----------------

  List<String> _motionKeysFor(String key, Set<String> expandedKeys) {
    final result = <String>[];
    void walk(_TreeEntity entity) {
      for (final child in entity.children) {
        result.add(child.key);
        if (expandedKeys.contains(child.key)) {
          walk(child);
        }
      }
    }

    final entity = _entities[key];
    if (entity != null) {
      walk(entity);
    }
    return result;
  }

  /// foundation.ts:829-874 `handleNodeExpand` / :789-827
  /// `handleNodeExpandInSearch`（受控只回调；loadData 挂钩 onNodeLoad）。
  void _toggleExpand(_TreeEntity entity) {
    final hasChildren = entity.data.children?.isNotEmpty == true;
    if (widget.loadData == null && !hasChildren) {
      return;
    }
    final expandedKeys = <String>{..._visibleExpanded};
    final wasExpanded = expandedKeys.contains(entity.key);
    if (wasExpanded) {
      expandedKeys.remove(entity.key);
    } else {
      expandedKeys.add(entity.key);
    }
    final virtual = widget.virtualize != null;
    if (!_expandControlled) {
      if (widget.motionExpand && !virtual) {
        _motionKeys = _motionKeysFor(entity.key, expandedKeys).toSet();
        _motionType = wasExpanded ? 'hide' : 'show';
        if (wasExpanded) {
          _cachedFlatten = List<_FlatNode>.of(_flattenNodes);
        }
      } else {
        _motionKeys = <String>{};
        _motionType = '';
        _cachedFlatten = null;
      }
      setState(() {
        if (_searching) {
          _filteredExpanded = expandedKeys;
        } else {
          _expanded = expandedKeys;
        }
        _flattenNodes = _flatten(
          expandedKeys,
          shown: _showFilteredOnly ? _filteredShownKeys : null,
        );
      });
    }
    widget.onExpand?.call(expandedKeys.toList(), !wasExpanded, entity.data);
    // index.tsx:744-746：展开且有 loadData → onNodeLoad。
    if (!wasExpanded && widget.loadData != null) {
      _loadNode(entity);
    }
    _rePosKey += 1;
  }

  /// foundation.ts:374-400 `handleNodeLoad`（onLoad 先于内部状态更新）。
  Future<void> _loadNode(_TreeEntity entity) async {
    final loadData = widget.loadData;
    if (loadData == null ||
        _loaded.contains(entity.key) ||
        _loading.contains(entity.key)) {
      return;
    }
    setState(() => _loading = <String>{..._loading, entity.key});
    try {
      await loadData(entity.data);
    } finally {
      if (mounted) {
        final loaded = <String>{..._loaded, entity.key};
        widget.onLoad?.call(loaded, entity.data);
        setState(() {
          _loading = <String>{..._loading}..remove(entity.key);
          if (!_loadControlled) {
            _loaded = loaded;
          }
        });
      }
    }
  }

  // -- search input ----------------------------------------------------------

  /// 聚焦搜索输入（单选触发器搜索的复位过滤在 onFocusChange 里——
  /// foundation.ts:905-912 `handleInputTriggerFocus`）。
  void _focusInput() {
    _inputFocusNode.requestFocus();
  }

  // -- build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final global = SemiTheme.of(context);
    final theme = SemiTreeSelectTheme.resolve(context);
    final treeTheme = SemiTreeTheme.resolve(context);
    return SemiTooltip(
      content: _buildPanel(global, theme, treeTheme),
      trigger: SemiTooltipTrigger.custom,
      visible: _open,
      onVisibleChange: _handleTooltipVisibleChange,
      // foundation.ts:313-318 `handleKeyDown`（ESC 收起；不 blur quirk）——
      // 面板内输入聚焦时由 tooltip 通道消费，触发器聚焦时由 _handleKey 消费。
      closeOnEsc: true,
      onEscKeyDown: _handleEsc,
      showArrow: false,
      popupBare: true,
      position: widget.position,
      autoAdjustOverflow: widget.autoAdjustOverflow,
      zIndex: widget.zIndex,
      motion: widget.motion,
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
                // treeSelect.scss:17 `cursor: pointer`。
                : SystemMouseCursors.click,
            onEnter: (_) {
              if (widget.showClear) setState(() => _isHovering = true);
            },
            onExit: (_) {
              if (widget.showClear) setState(() => _isHovering = false);
            },
            child: Listener(
              key: _triggerKey,
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) => setState(() => _pressed = true),
              onPointerUp: (_) => setState(() => _pressed = false),
              onPointerCancel: (_) => setState(() => _pressed = false),
              child: _buildTrigger(global, theme),
            ),
          ),
        ),
      ),
    );
  }

  /// treeSelect.scss:442-450 `-borderless`：静默（非 hover/非 focus）箭头隐藏。
  bool get _arrowVisible =>
      !widget.borderless || _isHovering || _pressed || _isFocus;

  double _triggerHeight(SemiResolvedTreeSelectThemeData theme) =>
      switch (widget.size) {
        SemiInputSize.small => theme.heightTreeSelectSmall,
        SemiInputSize.normal => theme.heightTreeSelectDefault,
        SemiInputSize.large => theme.heightTreeSelectLarge,
      };

  double _triggerLineHeight(SemiResolvedTreeSelectThemeData theme) =>
      switch (widget.size) {
        SemiInputSize.small => theme.fontTreeSelectSmallLineHeight,
        SemiInputSize.normal => theme.fontTreeSelectDefaultLineHeight,
        SemiInputSize.large => theme.fontTreeSelectLargeLineHeight,
      };

  double _tagInputMinHeight(
    SemiResolvedTreeSelectThemeData theme,
  ) => switch (widget.size) {
    SemiInputSize.small => theme.heightTreeSelectSelectionTagInputWrapperSmall,
    SemiInputSize.normal =>
      theme.heightTreeSelectSelectionTagInputWrapperDefault,
    SemiInputSize.large => theme.heightTreeSelectSelectionTagInputWrapperLarge,
  };

  /// treeSelect.scss 状态矩阵（`&` / `&:hover` / `&:active` / `&-focus` /
  /// `&-warning` / `&-error` / `&-disabled` / `&-borderless`）。
  (Color, Color, double) _triggerDecoration(
    SemiResolvedTreeSelectThemeData theme,
  ) {
    const transparent = Color(0x00000000);
    if (widget.disabled) {
      // `&-disabled`：底色 disabled-fill（hover 换 disabled-fill hover）；
      // ★描边走注释掉的 disabled border 行（死变量——docs 标注）。
      final bg = _isHovering
          ? theme.colorTreeSelectInputDisabledBgHover
          : theme.colorTreeSelectInputDisabledBgDefault;
      return (
        bg,
        theme.colorTreeSelectDefaultBorderDefault,
        theme.widthTreeSelectBorder,
      );
    }
    final focused = _isFocus;
    Color bg;
    Color border;
    double borderWidth;
    switch (widget.validateStatus) {
      case SemiInputStatus.warning:
        bg = _pressed
            ? theme.colorTreeSelectWarningBgActive
            : focused
            ? theme.colorTreeSelectWarningBgFocus
            : _isHovering
            ? theme.colorTreeSelectWarningBgHover
            : theme.colorTreeSelectWarningBgDefault;
        border = _pressed
            ? theme.colorTreeSelectWarningBorderActive
            : focused
            ? theme.colorTreeSelectWarningBorderFocus
            : _isHovering
            ? theme.colorTreeSelectWarningBorderHover
            : theme.colorTreeSelectWarningBorderDefault;
        borderWidth = focused
            ? theme.widthTreeSelectFocusBorder
            : _isHovering
            ? theme.widthTreeSelectHoverBorder
            : theme.widthTreeSelectBorder;
      case SemiInputStatus.error:
        bg = _pressed
            ? theme.colorTreeSelectDangerBgActive
            : focused
            ? theme.colorTreeSelectDangerBgFocus
            : _isHovering
            ? theme.colorTreeSelectDangerBgHover
            : theme.colorTreeSelectDangerBgDefault;
        border = _pressed
            ? theme.colorTreeSelectDangerBorderActive
            : focused
            ? theme.colorTreeSelectDangerBorderFocus
            : _isHovering
            ? theme.colorTreeSelectDangerBorderHover
            : theme.colorTreeSelectDangerBorderDefault;
        borderWidth = focused
            ? theme.widthTreeSelectFocusBorder
            : _isHovering
            ? theme.widthTreeSelectHoverBorder
            : theme.widthTreeSelectBorder;
      default:
        // `&-focus:hover` 保持 focus 底色（hover 不覆盖 focus）。
        bg = _pressed
            ? theme.colorTreeSelectDefaultBgActive
            : focused
            ? theme.colorTreeSelectDefaultBgFocus
            : _isHovering
            ? theme.colorTreeSelectDefaultBgHover
            : theme.colorTreeSelectDefaultBgDefault;
        border = focused
            ? theme.colorTreeSelectDefaultBorderFocus
            : _isHovering
            ? theme.colorTreeSelectDefaultBorderHover
            : theme.colorTreeSelectDefaultBorderDefault;
        borderWidth = focused
            ? theme.widthTreeSelectFocusBorder
            : _isHovering
            ? theme.widthTreeSelectHoverBorder
            : theme.widthTreeSelectBorder;
    }
    // `&-borderless`：静默（非 hover 非 focus）→ 透明底/描边 + 隐藏箭头；
    // error/warning 描边恒 `_border-focus` 色。
    if (widget.borderless) {
      if (widget.validateStatus == SemiInputStatus.error) {
        border = theme.colorTreeSelectDangerBorderFocus;
      } else if (widget.validateStatus == SemiInputStatus.warning) {
        border = theme.colorTreeSelectWarningBorderFocus;
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

  Widget _buildTrigger(
    SemiThemeData global,
    SemiResolvedTreeSelectThemeData theme,
  ) {
    final (bg, border, borderWidth) = _triggerDecoration(theme);
    // treeSelect.scss:124/350 `@include font-size-regular`（14）；
    // :329-330 `&-large .selection` `@include font-size-header-6`（16）。
    final fontSize = widget.size == SemiInputSize.large
        ? _TreeSelectMetrics.selectionLargeFontSize
        : global.typography.fontSizeRegular;
    final lineHeight = _triggerLineHeight(theme);
    final textColor = widget.disabled
        ? theme.colorTreeSelectInputDisabledTextDefault
        : theme.colorTreeSelectSelectionTextDefault;
    final placeholderColor = widget.disabled
        ? theme.colorTreeSelectInputDisabledTextDefault
        : theme.colorTreeSelectInputPlaceholderTextDefault;
    final iconColor = widget.disabled
        ? theme.colorTreeSelectInputDisabledTextDefault
        : theme.colorTreeSelectDefaultIconDefault;

    final selection = Padding(
      padding: EdgeInsetsDirectional.only(
        start: _multiple
            ? theme.spacingTreeSelectSelectionMultiplePaddingLeft
            : theme.spacingTreeSelectSelectionPaddingLeft,
        // `&-prefix/-suffix &.-with-suffix` → selection padding-right。
        end: widget.suffix != null
            ? theme.spacingTreeSelectSelectionWithSuffixPaddingRight
            : 0,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: _buildSelection(
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
          _slotText(
            global,
            theme,
            widget.prefix!,
            isIcon: widget.prefix is Widget,
            iconColor: iconColor,
          ),
        if (widget.insetLabel != null)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacingTreeSelectPrefixTextMarginX,
              vertical: theme.spacingTreeSelectPrefixTextMarginY,
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: theme.colorTreeSelectPrefixSuffixTextDefault,
                fontSize: global.typography.fontSizeRegular,
                fontWeight: theme.fontTreeSelectPrefixSuffixFontWeight,
              ),
              child: _asWidget(widget.insetLabel!),
            ),
          ),
        bounded ? Expanded(child: selection) : Flexible(child: selection),
        if (widget.suffix != null)
          _slotText(
            global,
            theme,
            widget.suffix!,
            isIcon: widget.suffix is Widget,
            iconColor: iconColor,
          ),
        // index.tsx:1154-1161：clearBtn 与 arrow 互斥占位（32 槽）。
        if (_showClearButton)
          Semantics(
            // index.tsx:1048-1049 `role='button'` +
            // `aria-label="Clear TreeSelect value"`。
            button: true,
            label: _TreeSelectMetrics.clearButtonSemantics,
            child: GestureDetector(
              key: SemiTreeSelect.clearButtonKey,
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
                    width: theme.widthTreeSelectArrow,
                    child: Center(
                      child: SemiIconTheme(
                        data: SemiIconThemeData(
                          color: _clearPressed
                              ? theme.colorTreeSelectDefaultIconActive
                              : _clearHovered
                              ? theme.colorTreeSelectDefaultIconHover
                              : theme.colorTreeSelectDefaultIconDefault,
                          customSize: fontSize,
                        ),
                        // index.tsx:1054 `clearIcon ? clearIcon : <IconClear />`。
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
            width: theme.widthTreeSelectArrow,
            // index.tsx:1027-1038 `renderArrow`：arrowIcon 为 null → 不渲染。
            child: widget.arrowIcon == null
                ? null
                : Opacity(
                    // treeSelect.scss:444-450 `-borderless` 静默态箭头隐藏。
                    opacity: _arrowVisible ? 1 : 0,
                    child: Center(
                      child: SemiIconTheme(
                        data: SemiIconThemeData(
                          color: iconColor,
                          customSize: fontSize,
                        ),
                        // index.tsx:294 `arrowIcon: <IconChevronDown />`。
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
        return widget.multiple
            ? ConstrainedBox(
                constraints: BoxConstraints(minHeight: _triggerHeight(theme)),
                child: row,
              )
            : SizedBox(height: _triggerHeight(theme), child: row);
      },
    );
    return Semantics(
      // index.tsx:1172 `role='combobox'`；:1174 `aria-haspopup="tree"`（近似）。
      button: true,
      enabled: !widget.disabled,
      expanded: _open,
      label: widget.semanticsLabel ?? _TreeSelectMetrics.defaultSemanticsLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(width: borderWidth, color: border),
          borderRadius: BorderRadius.circular(theme.radiusTreeSelect),
        ),
        child: ConstrainedBox(
          // treeSelect.scss:9 `min-width: $width-treeSelect_default`。
          constraints: BoxConstraints(minWidth: theme.widthTreeSelectDefault),
          child: body,
        ),
      ),
    );
  }

  Widget _asWidget(Object value) => value is Widget
      ? value
      : Text(value as String, maxLines: 1, overflow: TextOverflow.ellipsis);

  /// `&-prefix` / `&-suffix` 槽：文本走 prefix 文本 margin + 粗体；图标走图标 margin。
  Widget _slotText(
    SemiThemeData global,
    SemiResolvedTreeSelectThemeData theme,
    Object value, {
    required bool isIcon,
    required Color iconColor,
  }) {
    final color = widget.disabled
        ? theme.colorTreeSelectInputDisabledTextDefault
        : isIcon
        ? iconColor
        : theme.colorTreeSelectPrefixSuffixTextDefault;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isIcon
            ? theme.spacingTreeSelectPrefixIconMarginX
            : theme.spacingTreeSelectPrefixTextMarginX,
        vertical: isIcon
            ? theme.spacingTreeSelectPrefixIconMarginY
            : theme.spacingTreeSelectPrefixTextMarginY,
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: color,
          fontSize: global.typography.fontSizeRegular,
          fontWeight: isIcon
              ? null
              : theme.fontTreeSelectPrefixSuffixFontWeight,
        ),
        child: _asWidget(value),
      ),
    );
  }

  // -- selection area --------------------------------------------------------

  Widget _buildSelection(
    SemiResolvedTreeSelectThemeData theme,
    Color textColor,
    Color placeholderColor,
    double fontSize,
    double lineHeight,
  ) {
    // index.tsx:958-994 `renderSelectContent`。
    if (_isTriggerSearch) {
      return _multiple
          ? _buildTriggerTagInput(
              theme,
              textColor,
              placeholderColor,
              lineHeight,
            )
          : _buildSingleTriggerSearch(
              theme,
              textColor,
              placeholderColor,
              fontSize,
              lineHeight,
            );
    }
    if (!_multiple || !_hasValue) {
      final renderText = _renderTextInSingle();
      final content = renderText is Widget
          ? renderText
          : Text(
              renderText == null
                  ? (widget.placeholder ?? '')
                  : renderText.toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: renderText == null ? placeholderColor : textColor,
                fontSize: fontSize,
                fontWeight: theme.fontTreeSelectDefaultFontWeight,
                // line-height → 行盒高度（CSS line-height 的 Flutter 映射）。
                height: lineHeight / fontSize,
              ),
            );
      // treeSelect.scss:264-267 `&-multiple .selection-placeholder` 左缩进 8。
      if (_multiple && renderText == null) {
        return Padding(
          padding: EdgeInsetsDirectional.only(
            start: theme.spacingTreeSelectPlaceholderMultiplePaddingLeft,
          ),
          child: content,
        );
      }
      return content;
    }
    return _buildTagList(theme);
  }

  /// index.tsx:874-925 `renderTagList` + TagGroup maxTagCount 折叠（"+N"）。
  Widget _buildTagList(SemiResolvedTreeSelectThemeData theme) {
    final keys = _triggerRenderKeys();
    final fold =
        widget.maxTagCount != null && keys.length > widget.maxTagCount!;
    final visibleKeys = fold ? keys.take(widget.maxTagCount!).toList() : keys;
    final restCount = keys.length - visibleKeys.length;
    final children = <Widget>[
      for (final (index, key) in visibleKeys.indexed)
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacingTreeSelectTagMarginX,
            vertical: theme.spacingTreeSelectTagMarginY,
          ),
          child: _buildTag(theme, key, index),
        ),
      if (restCount > 0) _buildNTag(theme, restCount),
    ];
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }

  /// index.tsx:1123-1133 `triggerRenderKeys`（★unRelated 且 autoMergeValue=false
  /// 时上游取 `[...checkedKeys]`（恒空）quirk 照抄——docs 留档）。
  List<String> _triggerRenderKeys() {
    if (!_multiple) {
      return _selectedKeys;
    }
    if (!widget.autoMergeValue) {
      return _checked.toList();
    }
    if (widget.checkRelation == SemiTreeCheckRelation.related) {
      return _normalizeKeyList(
        _checked.toList(),
        leafOnly: widget.leafOnly,
        flag: true,
      );
    }
    return _realChecked.toList();
  }

  /// index.tsx:1196-1251 `renderTagItem`（白色 Tag，disabled 不可关；多选
  /// `renderSelectedItem` 结果按 select 先例原样渲染——isRenderInTag 拍平）。
  Widget _buildTag(
    SemiResolvedTreeSelectThemeData theme,
    String key,
    int index,
  ) {
    final item = _dataForKey(key);
    final disabled = widget.disabled || item.disabled;
    void close() => _removeTag(key);
    final custom = widget.renderSelectedItem;
    if (custom
        is Widget Function(
          SemiTreeNodeData, {
          int index,
          bool disabled,
          VoidCallback onClose,
        })) {
      return custom(item, index: index, disabled: disabled, onClose: close);
    }
    return SemiTag(
      item.label is String
          ? item.label! as String
          : (item.label?.toString() ?? ''),
      size: widget.size == SemiInputSize.small
          ? SemiTagSize.small
          : SemiTagSize.large,
      color: SemiTagColor.white,
      backgroundColor: widget.disabled
          // treeSelect.scss:117-120 `&-disabled .semi-tag`。
          ? theme.colorTreeSelectTagDisabledBgDefault
          : const Color(0x00000000),
      textColor: widget.disabled
          ? theme.colorTreeSelectInputDisabledTextDefault
          : null,
      closable: !disabled,
      onClose: (_) => close(),
    );
  }

  /// "+N" 折叠标签（treeSelect.scss:410-413 `-maxTagCount`：placeholder 色 +
  /// `$font-treeSelect_default-fontSize`）。
  Widget _buildNTag(SemiResolvedTreeSelectThemeData theme, int restCount) {
    final nTag = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacingTreeSelectTagMarginX,
        vertical: theme.spacingTreeSelectTagMarginY,
      ),
      child: SemiTag(
        '+$restCount',
        key: const ValueKey('_+n'),
        closable: false,
        size: widget.size == SemiInputSize.small
            ? SemiTagSize.small
            : SemiTagSize.large,
        color: SemiTagColor.grey,
        backgroundColor: const Color(0x00000000),
        style: TextStyle(
          fontSize: theme.fontTreeSelectDefaultFontSize,
          color: theme.colorTreeSelectInputPlaceholderTextDefault,
        ),
      ),
    );
    if (!widget.showRestTagsPopover) return nTag;
    final keys = _triggerRenderKeys();
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

  /// index.tsx:948-956 `renderSingleTriggerSearch`（input + 回填浮层文案）。
  Widget _buildSingleTriggerSearch(
    SemiResolvedTreeSelectThemeData theme,
    Color textColor,
    Color placeholderColor,
    double fontSize,
    double lineHeight,
  ) {
    final renderText = _renderTextInSingle();
    // index.tsx:930-943 `renderSingleTriggerSearchItem`（★占位/聚焦时
    // `opacity: .6` quirk 照抄）。
    final dimmed = renderText == null || _inputTriggerFocus;
    final Widget item = renderText is Widget
        ? renderText
        : Text(
            renderText == null
                ? (widget.placeholder ?? '')
                : renderText.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: widget.disabled
                  ? theme
                        .colorTreeSelectSelectionTriggerSearchItemDisabledTextDefault
                  : dimmed
                  ? placeholderColor
                  : textColor,
              fontSize: fontSize,
              fontWeight: theme.fontTreeSelectDefaultFontWeight,
              height: lineHeight / fontSize,
            ),
          );
    return Stack(
      fit: StackFit.passthrough,
      children: [
        SizedBox(
          height: lineHeight,
          child: _buildSearchInput(theme, inTrigger: true),
        ),
        if (_inputValue.isEmpty)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: widget.disabled,
              child: GestureDetector(
                // index.tsx:939 `onClick={this.foundation.onClickSingleTriggerSearchItem}`。
                onTap: _focusInput,
                behavior: HitTestBehavior.opaque,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Opacity(
                    // treeSelect.scss:167-168 `-placeholder { opacity: .6 }`。
                    opacity: dimmed
                        ? _TreeSelectMetrics.searchItemPlaceholderOpacity
                        : 1,
                    child: item,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// index.tsx:1253-1297 `renderTagInput`（多选 + 触发器内搜索：标签 + 内联输入；
  /// ★上游内联输入是 TagInput 组件自带输入——searchRender 不作用于此，照抄）。
  Widget _buildTriggerTagInput(
    SemiResolvedTreeSelectThemeData theme,
    Color textColor,
    Color placeholderColor,
    double lineHeight,
  ) {
    final keys = _triggerRenderKeys();
    final fold =
        widget.maxTagCount != null && keys.length > widget.maxTagCount!;
    final visibleKeys = fold ? keys.take(widget.maxTagCount!).toList() : keys;
    final restCount = keys.length - visibleKeys.length;
    final children = <Widget>[
      for (final (index, key) in visibleKeys.indexed)
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacingTreeSelectTagMarginX,
            vertical: theme.spacingTreeSelectTagMarginY,
          ),
          child: _buildTag(theme, key, index),
        ),
      if (restCount > 0) _buildNTag(theme, restCount),
      ConstrainedBox(
        constraints: BoxConstraints(
          // treeSelect.scss:211-218 `tagInput` min-height 三档。
          minHeight: _tagInputMinHeight(theme),
          maxHeight: _tagInputMinHeight(theme),
          minWidth: _TreeSelectMetrics.tagInputMinWidth,
        ),
        child: _buildSearchInput(theme, inTrigger: true),
      ),
    ];
    final wrap = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
    // treeSelect.scss:246-257 `-multiple-tagInput-notEmpty/-empty` marginLeft
    //（notEmpty 为负——把 wrapper 的4px padding 拉回）。
    final offset = keys.isEmpty
        ? theme.spacingTreeSelectSelectionTagInputEmptyMarginLeft
        : theme.spacingTreeSelectSelectionTagInputNotEmptyMarginLeft;
    final padded = Padding(
      padding: EdgeInsetsDirectional.only(start: offset < 0 ? 0 : offset),
      child: Transform.translate(
        offset: Offset(offset < 0 ? offset : 0, 0),
        child: Padding(
          // treeSelect.scss:221-223 `tagInput-wrapper` paddingX。
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacingTreeSelectSelectionTagInputWrapperPaddingX,
          ),
          child: wrap,
        ),
      ),
    );
    if (!widget.triggerTagWrap) return padded;
    // treeSelect.scss:275-318 `-triggerTagWrap`（标签可换行、触发器随行数增高）。
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: _triggerHeight(theme) - 2 * theme.widthTreeSelectBorder,
      ),
      child: padded,
    );
  }

  /// index.tsx:1300-1366 `renderInput`（触发器内 bare 输入 / 弹层内带图标搜索框）。
  Widget _buildSearchInput(
    SemiResolvedTreeSelectThemeData theme, {
    required bool inTrigger,
  }) {
    if (widget.searchRender == false) {
      return const SizedBox.shrink();
    }
    final placeholder = inTrigger
        ? ''
        : widget.searchPlaceholder ??
              _TreeSelectMetrics.localeSearchPlaceholder;
    final custom = widget.searchRender;
    if (custom is SemiTreeSelectSearchBuilder) {
      return custom(
        SemiTreeSearchProps(
          placeholder: placeholder,
          value: _inputValue,
          onChange: _handleSearch,
          showClear: widget.showSearchClear,
        ),
      );
    }
    return SemiInput(
      key: inTrigger ? null : SemiTreeSelect.searchInputKey,
      controller: _inputController,
      focusNode: _inputFocusNode,
      size: widget.size,
      disabled: widget.disabled,
      // 触发器内输入剥掉边框/底色（treeSelect.scss:183-205）：
      // `theme.colorTreeSelectInputTriggerBorderDefault`（`none` 简写 → 不描边）
      // + `theme.colorTreeSelectInputTriggerBgDefault`（transparent → 透明底）。
      // `bare: true` 即「无描边 + 透明底」等效消费。
      bare: inTrigger,
      placeholder: placeholder,
      prefix: inTrigger
          ? null
          // index.tsx:1325 `prefix: <IconSearch />`。
          : const SemiIcon(SemiIcons.search, size: SemiIconSize.small),
      showClear: !inTrigger && widget.showSearchClear,
      semanticsLabel: inTrigger
          ? null
          : _TreeSelectMetrics.searchInputSemantics,
      onChanged: widget.disabled ? null : _handleSearch,
      onFocusChange: (focused) {
        if (_isTriggerSearch && !_multiple) {
          if (focused) {
            // foundation.ts:905-912 `handleInputTriggerFocus`：聚焦即复位过滤。
            _clearInput();
            setState(() => _inputTriggerFocus = true);
          } else {
            // foundation.ts:898-902 `handleInputTriggerBlur`。
            setState(() => _inputTriggerFocus = false);
          }
        }
      },
    );
  }

  // -- panel -----------------------------------------------------------------

  /// index.tsx:821-831 `renderContent` + :1506-1581 `renderTree`。
  Widget _buildPanel(
    SemiThemeData global,
    SemiResolvedTreeSelectThemeData theme,
    SemiResolvedTreeThemeData treeTheme,
  ) {
    final noData =
        _flattenNodes.isEmpty ||
        (widget.showFilteredOnly && _searching && _filteredKeys.isEmpty);
    return ConstrainedBox(
      constraints: BoxConstraints(
        // treeSelect.scss:416 `-popover` max-height（misnesting——意图消费）。
        maxHeight: theme.heightTreeSelectPopover,
        minWidth: _panelMinWidth ?? 0,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          // `$color-popover-bg-default: var(--semi-color-bg-3)`。
          color: global.colors.colorBg3,
          // `$color-popover-border-default: var(--semi-color-border)`，1px。
          border: Border.all(width: 1, color: global.colors.colorBorder),
          // `$radius-popover: var(--semi-border-radius-medium)`。
          borderRadius: BorderRadius.circular(
            global.radius.borderRadiusMedium.value,
          ),
          boxShadow: const [
            _TreeSelectMetrics.shadowElevatedBlur,
            _TreeSelectMetrics.shadowElevatedDrop,
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            global.radius.borderRadiusMedium.value,
          ),
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.outerTopSlot != null)
                  _IntrinsicWidthBlocker(child: widget.outerTopSlot!)
                else if (_isDropdownSearch)
                  _IntrinsicWidthBlocker(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            // treeSelect.scss:437 tree-search-wrapper border-bottom。
                            width: theme.widthTreeSelectSearchWrapperBorder,
                            color: theme.colorTreeSelectSearchBorderDefault,
                          ),
                        ),
                      ),
                      child: Padding(
                        // treeSelect.scss:406 `&-search-wrapper` padding
                        //（misnesting——与 tree.scss 同值 12/8 意图消费）。
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              theme.spacingTreeSelectSearchWrapperPaddingX,
                          vertical:
                              theme.spacingTreeSelectSearchWrapperPaddingY,
                        ),
                        child: _buildSearchInput(theme, inTrigger: false),
                      ),
                    ),
                  ),
                Flexible(
                  child: SingleChildScrollView(
                    key: SemiTreeSelect.listKey,
                    // treeSelect.scss:429 tree-option-list min-width 230。
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: theme.widthTreeSelectOption,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: noData
                            ? [_buildEmpty(treeTheme)]
                            : _buildRows(treeTheme),
                      ),
                    ),
                  ),
                ),
                if (widget.outerBottomSlot != null)
                  _IntrinsicWidthBlocker(child: widget.outerBottomSlot!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// index.tsx:1368-1382 `renderEmpty`（emptyContent / locale「暂无数据」）。
  Widget _buildEmpty(SemiResolvedTreeThemeData t) {
    final content = switch (widget.emptyContent) {
      final Widget widget => widget,
      final Object value => Text(
        value.toString(),
        style: TextStyle(
          fontSize: _TreeSelectMetrics.fontSizeRegular,
          color: t.colorTreeOptionDisabledTextDefault,
        ),
      ),
      // ★上游 `emptyContent: null` 隐藏空态——本移植无三态（docs 差异清单）。
      null => Text(
        _TreeSelectMetrics.localeEmptyText,
        style: TextStyle(
          fontSize: _TreeSelectMetrics.fontSizeRegular,
          color: t.colorTreeOptionDisabledTextDefault,
        ),
      ),
    };
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: t.spacingTreeOptionPaddingTop,
        horizontal: t.spacingTreeOptionLevel1PaddingLeft,
      ),
      child: Center(key: SemiTreeSelect.emptyKey, child: content),
    );
  }

  List<Widget> _buildRows(SemiResolvedTreeThemeData t) {
    final global = SemiTheme.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    // 收起动画期继续渲染缓存行（NodeList 口径）。
    final rows = _motionType == 'hide' && _cachedFlatten != null
        ? _cachedFlatten!
        : _flattenNodes;
    final children = <Widget>[];
    var index = 0;
    while (index < rows.length) {
      final row = rows[index];
      if (_motionKeys.contains(row.entity.key)) {
        final group = <Widget>[];
        while (index < rows.length &&
            _motionKeys.contains(rows[index].entity.key)) {
          group.add(_buildRow(t, global, rtl, rows[index]));
          index++;
        }
        children.add(
          _TreeMotionBlock(
            key: ValueKey('motion-${row.entity.key}'),
            expand: _motionType != 'hide',
            duration: _TreeSelectMetrics.collapsibleDuration,
            onMotionEnd: () => setState(() {
              _motionKeys = <String>{};
              _motionType = '';
              _cachedFlatten = null;
            }),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: group,
            ),
          ),
        );
      } else {
        children.add(_buildRow(t, global, rtl, row));
        index++;
      }
    }
    return children;
  }

  Widget _buildRow(
    SemiResolvedTreeThemeData t,
    SemiThemeData global,
    bool rtl,
    _FlatNode flat,
  ) {
    final entity = flat.entity;
    final props = _nodeProps(entity);
    return _TreeRow(
      key: ValueKey(entity.key),
      eventKey: entity.key,
      data: entity.data,
      t: t,
      global: global,
      level: entity.level,
      isEnd: flat.isEnd,
      props: props,
      isLeaf: _isLeaf(entity),
      disabled: _isDisabled(entity),
      rtl: rtl,
      showLine: widget.showLine,
      // index.tsx:1531 `${prefixTree}-option-list-block`（恒 block）。
      blockNode: true,
      multiple: widget.multiple,
      labelEllipsis: _labelEllipsis,
      directory: false,
      treeIcon: null,
      expandIcon: widget.expandIcon,
      renderLabel: widget.renderLabel,
      keyword: _inputValue,
      expandAction: widget.expandAction,
      hasDoubleClick: false,
      onTap: () => _handleNodeSelect(entity),
      onDoubleTap: () => _toggleExpand(entity),
      onToggleExpand: () => _toggleExpand(entity),
      onCheck: () => _handleNodeSelect(entity),
      onContextMenu: () {},
    );
  }
}

/// Shields a subtree from intrinsic-size queries (select 先例——SemiInput 的
/// LayoutBuilder 无法回答 intrinsics，面板 IntrinsicWidth 需要)。
class _IntrinsicWidthBlocker extends SingleChildRenderObjectWidget {
  const _IntrinsicWidthBlocker({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderIntrinsicWidthBlocker();
}

class _RenderIntrinsicWidthBlocker extends RenderProxyBox {
  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) => 0;

  @override
  double computeMinIntrinsicHeight(double width) => 0;

  @override
  double computeMaxIntrinsicHeight(double width) => 0;
}

/// 展开/收起运动块（与 semi_tree.dart `_TreeMotionBlock` 同源——
/// nodeList.tsx + nodeCollapsible.tsx：Collapsible 高度+fade，`duration={200}`）。
class _TreeMotionBlock extends StatefulWidget {
  const _TreeMotionBlock({
    super.key,
    required this.expand,
    required this.duration,
    required this.onMotionEnd,
    required this.child,
  });

  final bool expand;
  final Duration duration;
  final VoidCallback onMotionEnd;
  final Widget child;

  @override
  State<_TreeMotionBlock> createState() => _TreeMotionBlockState();
}

class _TreeMotionBlockState extends State<_TreeMotionBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.expand ? 0 : 1,
  );

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        widget.onMotionEnd();
      }
    });
    if (widget.expand) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _controller,
      alignment: Alignment.topCenter,
      child: FadeTransition(opacity: _controller, child: widget.child),
    );
  }
}

/// 单行（与 semi_tree.dart `_TreeRow` 同源——treeNode.tsx + indent.tsx；
/// treeSelect 下拉恒 block 模式、无 directory/onDoubleClick）。
class _TreeRow extends StatefulWidget {
  const _TreeRow({
    super.key,
    required this.eventKey,
    required this.data,
    required this.t,
    required this.global,
    required this.level,
    required this.isEnd,
    required this.props,
    required this.isLeaf,
    required this.disabled,
    required this.rtl,
    required this.showLine,
    required this.blockNode,
    required this.multiple,
    required this.labelEllipsis,
    required this.directory,
    required this.treeIcon,
    required this.expandIcon,
    required this.renderLabel,
    required this.keyword,
    required this.expandAction,
    required this.hasDoubleClick,
    required this.onTap,
    required this.onDoubleTap,
    required this.onToggleExpand,
    required this.onCheck,
    required this.onContextMenu,
  });

  final String eventKey;
  final SemiTreeNodeData data;
  final SemiResolvedTreeThemeData t;
  final SemiThemeData global;
  final int level;
  final List<bool> isEnd;
  final _NodeProps props;
  final bool isLeaf;
  final bool disabled;
  final bool rtl;
  final bool showLine;
  final bool blockNode;
  final bool multiple;
  final bool labelEllipsis;
  final bool directory;
  final Object? treeIcon;
  final Object? expandIcon;
  final SemiTreeLabelBuilder? renderLabel;
  final String keyword;
  final SemiTreeExpandAction expandAction;
  final bool hasDoubleClick;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback onToggleExpand;
  final VoidCallback onCheck;
  final VoidCallback onContextMenu;

  @override
  State<_TreeRow> createState() => _TreeRowState();
}

class _TreeRowState extends State<_TreeRow> {
  bool _hover = false;
  bool _pressed = false;
  bool _arrowHover = false;
  bool _arrowPressed = false;

  /// 子槽（箭头/checkbox）抢占有指针 → 行点击不触发（上游 stopPropagation）。
  bool _childClaimed = false;
  bool _rowCandidate = false;
  Duration? _lastTapAt;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final props = widget.props;
    final rtl = widget.rtl;
    final disabled = widget.disabled;

    final Color rowBg;
    final Color labelBg;
    if (widget.blockNode) {
      // tree.scss:361-457 `-option-list-block`：整行 hover fill-0 / active fill-1 /
      // selected primary-light（selected 覆盖 hover/active）。
      labelBg = const Color(0x00000000);
      rowBg = props.selected
          ? t.colorTreeOptionBgActive
          : _pressed
          ? t.colorTreeOptionSelectedBgDefault
          : _hover
          ? t.colorTreeOptionBgHover
          : const Color(0x00000000);
    } else {
      rowBg = const Color(0x00000000);
      labelBg = props.selected
          ? t.colorTreeOptionBgActive
          : _pressed
          ? t.colorTreeOptionSelectedBgDefault
          : _hover
          ? t.colorTreeOptionBgHover
          : const Color(0x00000000);
    }

    final textColor = disabled
        ? t.colorTreeOptionDisabledTextDefault
        : t.colorTreeOptionTextDefault;

    final labelParts = <Widget>[
      if (widget.multiple)
        Padding(
          padding: EdgeInsetsDirectional.only(
            end: t.spacingTreeLabelWithIconMarginRight,
          ),
          child: _buildCheckbox(t),
        ),
      if (_nodeIcon(t) != null)
        Padding(
          padding: EdgeInsetsDirectional.only(
            end: t.spacingTreeLabelWithIconMarginRight,
          ),
          child: SemiIconTheme(
            data: SemiIconThemeData(color: t.colorTreeOptionIconDefault),
            child: _nodeIcon(t)!,
          ),
        ),
      Flexible(child: _buildLabelText(t, textColor, labelBg)),
    ];

    final rowContent = CustomPaint(
      painter: _TreeRowLinePainter(
        level: widget.level,
        isEnd: widget.isEnd,
        unit: t.spacingTreeOptionLevelPaddingLeft,
        startInset: t.spacingTreeOptionLevel1PaddingLeft,
        lineWidth: t.widthTreeOptionLine,
        color: widget.global.colors.colorText3,
        rtl: rtl,
        showLine: widget.showLine,
        leaf: widget.isLeaf,
        lastLeaf: widget.isEnd.isNotEmpty && widget.isEnd.last,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: t.spacingTreeOptionPaddingTop,
          bottom: t.spacingTreeOptionPaddingBottom,
          left: t.spacingTreeOptionLevel1PaddingLeft,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: t.spacingTreeOptionLevelPaddingLeft * widget.level),
            Padding(
              padding: EdgeInsetsDirectional.only(
                end: t.spacingTreeIconMarginRight,
              ),
              child: SizedBox(
                width: t.widthTreeEmptyIcon,
                child: Center(child: _buildArrow(t, rtl)),
              ),
            ),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Row(children: labelParts),
              ),
            ),
          ],
        ),
      ),
    );

    Widget body = MouseRegion(
      // tree.scss:56 `cursor: pointer`（★disabled 亦 pointer quirk 照抄）。
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          _rowCandidate = !_childClaimed;
          _childClaimed = false;
          if (_rowCandidate && event.buttons & kSecondaryMouseButton != 0) {
            _rowCandidate = false;
            widget.onContextMenu();
            return;
          }
          if (_rowCandidate && event.buttons & kPrimaryButton != 0) {
            setState(() => _pressed = true);
          }
        },
        onPointerUp: (event) {
          if (!_rowCandidate) {
            return;
          }
          _rowCandidate = false;
          setState(() => _pressed = false);
          if (event.buttons == 0) {
            _handleRowTap(event.timeStamp);
          }
        },
        onPointerCancel: (_) {
          _rowCandidate = false;
          setState(() => _pressed = false);
        },
        child: AnimatedContainer(
          duration: t.transitionDurationTreeOptionBg,
          curve: t.transitionFunctionTreeOptionBg,
          decoration: BoxDecoration(
            color: widget.blockNode ? rowBg : const Color(0x00000000),
          ),
          child: rowContent,
        ),
      ),
    );
    body = Transform.scale(
      scaleX: t.transformScaleTreeOption.scaleX,
      scaleY: t.transformScaleTreeOption.scaleY,
      child: body,
    );
    return Semantics(selected: props.selected, enabled: !disabled, child: body);
  }

  void _handleRowTap(Duration timeStamp) {
    final doubleAction =
        widget.hasDoubleClick ||
        widget.expandAction == SemiTreeExpandAction.doubleClick;
    if (doubleAction && _lastTapAt != null) {
      final delta = timeStamp - _lastTapAt!;
      if (delta <= const Duration(milliseconds: 300)) {
        _lastTapAt = null;
        widget.onDoubleTap();
        return;
      }
    }
    _lastTapAt = timeStamp;
    widget.onTap();
  }

  void _claimChild() {
    _childClaimed = true;
  }

  Widget _buildCheckbox(SemiResolvedTreeThemeData t) {
    final props = widget.props;
    return Listener(
      onPointerDown: (_) => _claimChild(),
      // SemiCheckbox 内部 LayoutBuilder 无法回答 intrinsics——面板 IntrinsicWidth
      // 需要屏蔽（select `_IntrinsicWidthBlocker` 先例；宽度估算不含勾选槽）。
      child: _IntrinsicWidthBlocker(
        child: SemiCheckbox(
          key: ValueKey('treeSelect-checkbox-${widget.eventKey}'),
          checked: props.checked,
          indeterminate: props.halfChecked,
          disabled: widget.disabled,
          onChanged: (_) => widget.onCheck(),
        ),
      ),
    );
  }

  Widget _buildLabelText(
    SemiResolvedTreeThemeData t,
    Color textColor,
    Color labelBg,
  ) {
    final label = widget.data.label;
    final Widget content;
    if (widget.renderLabel != null) {
      content = widget.renderLabel!(label, widget.data, widget.keyword);
    } else if (label is Widget) {
      content = label;
    } else {
      final text = label?.toString() ?? '';
      if (widget.props.filtered && widget.keyword.isNotEmpty) {
        // treeNode.tsx:318-335 + tree.scss:137-142 `-highlight`：bold + primary
        // 字色 + 背景继承（覆盖 Highlight 默认底色）。
        content = SemiHighlight(
          text,
          searchWords: [SemiHighlightWord<TextStyle>(widget.keyword)],
          highlightStyle: TextStyle(
            fontWeight: t.fontTreeOptionHightlightFontWeight,
            color: t.colorTreeOptionHightlightText,
            backgroundColor: const Color(0x00000000),
          ),
          maxLines: widget.labelEllipsis ? 1 : null,
          overflow: widget.labelEllipsis ? TextOverflow.ellipsis : null,
        );
      } else {
        content = Text(
          text,
          maxLines: widget.labelEllipsis ? 1 : null,
          overflow: widget.labelEllipsis ? TextOverflow.ellipsis : null,
        );
      }
    }
    return AnimatedContainer(
      duration: t.transitionDurationTreeOptionBg,
      curve: t.transitionFunctionTreeOptionBg,
      decoration: BoxDecoration(
        color: labelBg,
        borderRadius: BorderRadius.circular(t.radiusTreeCheckboxAddon),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: _TreeSelectMetrics.fontSizeRegular,
          color: textColor,
        ),
        child: content,
      ),
    );
  }

  Widget? _nodeIcon(SemiResolvedTreeThemeData t) {
    final data = widget.data;
    if (data.icon != null) {
      return data.icon;
    }
    final Object? treeIcon = widget.treeIcon;
    if (treeIcon is Widget) {
      return treeIcon;
    }
    if (treeIcon is SemiTreeIconBuilder) {
      return treeIcon(data);
    }
    return null;
  }

  Widget _buildArrow(SemiResolvedTreeThemeData t, bool rtl) {
    if (widget.props.loading) {
      return SizedBox(
        width: t.widthTreeSpinIcon,
        height: t.widthTreeSpinIcon,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SemiSpinTheme(
            data: SemiSpinThemeData(color: t.colorTreeOptionLoadingIconDefault),
            child: const SemiSpin(size: SemiSpinSize.small),
          ),
        ),
      );
    }
    if (widget.isLeaf) {
      return SizedBox(width: t.widthTreeEmptyIcon);
    }
    final expandIcon = widget.expandIcon;
    if (expandIcon is Widget) {
      return Listener(
        onPointerDown: (_) => _claimChild(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onToggleExpand,
          child: expandIcon,
        ),
      );
    }
    if (expandIcon is SemiTreeExpandIconBuilder) {
      return Listener(
        onPointerDown: (_) => _claimChild(),
        child: expandIcon(widget.props.expanded, widget.onToggleExpand),
      );
    }
    // treeNode.tsx:231-238 默认 IconTreeTriangleDown size="small"，收起旋转
    //（tree.scss:131-135 `transform: rotate(270deg)`；rtl.scss rotate(90deg)）。
    final rotate = widget.props.expanded ? 0.0 : (rtl ? 90.0 : 270.0);
    final arrowColor = !widget.blockNode
        ? t.colorTreeOptionIconDefault
        : _arrowPressed
        ? t.colorTreeOptionIconActive
        : _arrowHover
        ? t.colorTreeOptionIconHover
        : t.colorTreeOptionIconDefault;
    return MouseRegion(
      onEnter: (_) => setState(() => _arrowHover = true),
      onExit: (_) => setState(() => _arrowHover = false),
      child: Listener(
        onPointerDown: (_) {
          _claimChild();
          setState(() => _arrowPressed = true);
        },
        onPointerUp: (_) => setState(() => _arrowPressed = false),
        onPointerCancel: (_) => setState(() => _arrowPressed = false),
        child: GestureDetector(
          key: ValueKey('treeSelect-expand-${widget.eventKey}'),
          behavior: HitTestBehavior.opaque,
          onTap: widget.onToggleExpand,
          child: SizedBox(
            width: t.widthTreeEmptyIcon,
            child: Center(
              child: SemiIconTheme(
                data: SemiIconThemeData(color: arrowColor),
                child: SemiIcon(
                  SemiIcons.treeTriangleDown,
                  size: SemiIconSize.small,
                  rotate: rotate,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 行级缩进引导线 + 叶子折线（与 semi_tree.dart `_TreeRowLinePainter` 同源）。
class _TreeRowLinePainter extends CustomPainter {
  _TreeRowLinePainter({
    required this.level,
    required this.isEnd,
    required this.unit,
    required this.startInset,
    required this.lineWidth,
    required this.color,
    required this.rtl,
    required this.showLine,
    required this.leaf,
    required this.lastLeaf,
  });

  final int level;
  final List<bool> isEnd;
  final double unit;
  final double startInset;
  final double lineWidth;
  final Color color;
  final bool rtl;
  final bool showLine;
  final bool leaf;
  final bool lastLeaf;

  static const double _iconWidth = 12; // $width-tree_emptyIcon
  static const double _branch = 8; // calc((20 / 2) * 0.8)

  @override
  void paint(Canvas canvas, Size size) {
    if (!showLine) {
      return;
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < level; i++) {
      if (i < isEnd.length && isEnd[i]) {
        continue;
      }
      final offset = startInset + i * unit + _iconWidth / 2;
      final x = rtl ? size.width - offset : offset;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    if (!leaf) {
      return;
    }
    final offset = startInset + level * unit + _iconWidth / 2;
    final x = rtl ? size.width - offset : offset;
    final mid = size.height / 2;
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, lastLeaf ? mid : size.height),
      paint,
    );
    canvas.drawLine(
      Offset(x, mid),
      Offset(rtl ? x - _branch : x + _branch, mid),
      paint,
    );
  }

  @override
  bool shouldRepaint(_TreeRowLinePainter oldDelegate) =>
      level != oldDelegate.level ||
      isEnd != oldDelegate.isEnd ||
      unit != oldDelegate.unit ||
      startInset != oldDelegate.startInset ||
      lineWidth != oldDelegate.lineWidth ||
      color != oldDelegate.color ||
      rtl != oldDelegate.rtl ||
      showLine != oldDelegate.showLine ||
      leaf != oldDelegate.leaf ||
      lastLeaf != oldDelegate.lastLeaf;
}

/// HARDCODES（另列）上游片段逐字留档（生成器 assertIn 锚点）。
abstract final class _TreeSelectMetrics {
  /// treeSelect.scss:124/350 `@include font-size-regular`（= 14——选择框/
  /// prefix/suffix 文本字号；读 live `typography.fontSizeRegular`）。
  static const double fontSizeRegular = 14;

  /// treeSelect.scss:329-330 `@include font-size-header-6`（`$font-size-header-6:
  /// 16px`，semi-theme-default/scss/variables.scss:61——large 尺寸选择文本号）。
  static const double selectionLargeFontSize = 16;

  /// treeSelect.scss:167-168 `-selection-TriggerSearchItem-placeholder`
  /// `opacity: .6`（占位/聚焦回填文案透明度）。
  static const double searchItemPlaceholderOpacity = 0.6;

  /// nodeList.tsx:50 `duration={200}`（NodeCollapsible 展开/收起时长；树行
  /// 与 semi_tree.dart 同源）。
  static const Duration collapsibleDuration = Duration(milliseconds: 200);

  /// zh_CN.ts:153 `searchPlaceholder: '搜索'`（TreeSelect locale）。
  static const String localeSearchPlaceholder = '搜索';

  /// zh_CN.ts:125 `emptyText: '暂无数据'`（Tree locale——renderEmpty 复用）。
  static const String localeEmptyText = '暂无数据';

  /// index.tsx:1355 `aria-label='Filter TreeSelect item'`（弹层搜索框语义）。
  static const String searchInputSemantics = 'Filter TreeSelect item';

  /// index.tsx:1049 `aria-label="Clear TreeSelect value"`（清空按钮语义）。
  static const String clearButtonSemantics = 'Clear TreeSelect value';

  /// index.tsx:319 `'aria-label': 'TreeSelect'`（触发器缺省语义标签）。
  static const String defaultSemanticsLabel = 'TreeSelect';

  /// index.tsx:1325 `IconSearch` 前缀（SemiIcons.search）——注释引用。

  /// 上游最小内联输入宽（TagInput `width: auto` 测量的 Flutter 近似）。
  static const double tagInputMinWidth = 8;

  /// index.tsx:301 `zIndex: popoverNumbers.DEFAULT_Z_INDEX`
  ///（popover/constants.ts:44 `DEFAULT_Z_INDEX: 1030`）。
  static const int popoverZIndex = 1030;

  /// `0 0 1px rgba(0, 0, 0, .3)` — `@include shadow-elevated` 第一层
  ///（semi-theme-default/scss/global.scss；select 先例同值）。
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
  // constants.ts:13 `SIZE_SET: ['small', 'large', 'default']`。
  // constants.ts:14 `SEARCH_POSITION_DROPDOWN: 'dropdown'`。
  // constants.ts:15 `SEARCH_POSITION_TRIGGER: 'trigger'`。
  // foundation.ts:30 `ValidateStatus = 'error' | 'warning' | 'default'`。
  // index.tsx:294 `arrowIcon: <IconChevronDown />`。
  // index.tsx:1054 `clearIcon ? clearIcon : <IconClear />`。
  // index.tsx:1172 `role='combobox'`；index.tsx:1174 `aria-haspopup="tree"`。
  // index.tsx:1598 `position ? position : 'bottomLeft'`。
  // index.tsx:301 `zIndex: popoverNumbers.DEFAULT_Z_INDEX`。
  // foundation.ts:314 `e.key === ESC_KEY`（Esc 收起）。
  // foundation.ts:528 `isEnterPress`（触发器 Enter → 切换展开）。
  // treeSelect.scss:17 `cursor: pointer`（触发器指针）。
  // treeSelect.scss:95 `cursor: not-allowed`（disabled 指针）。
  // treeSelect.scss:96 `user-select: none`（disabled 文本不可选——Flutter 默认）。
}
