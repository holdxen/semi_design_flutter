// SemiTree — 树形控件（Semi Design 组件移植）。
//
// 上游：packages/semi-foundation/tree/{variables.scss, animation.scss,
// tree.scss, rtl.scss, constants.ts, foundation.ts, treeUtil.ts}、
// packages/semi-ui/tree/{index.tsx, treeNode.tsx, nodeList.tsx,
// nodeCollapsible.tsx, indent.tsx, autoSizer.tsx, treeContext.tsx} + zh_CN.ts
// locale。主题对账 33 = 29 FIELDS + 4 MOTION + 0 INTERNAL
// （tool/generate_tree.py）——★0 死变量（29+4 条声明全被 tree.scss 消费；
// 但 draggable 未移植 → 5 条拖拽专用字段本移植不消费，docs 标注，不属死变量）。
// 4 条 MOTION 是活字段（tree.scss:1 `@import "./animation.scss"` + :57-59 消费，
// 0ms/ease-in/0ms/scale(1,1) 恒等）。
//
// HARDCODES（另列）上游片段以注释逐字留档在 `_TreeMetrics` / 调用点，
// 生成器 HARDCODES 锚点断言这些片段出现在本文件。
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../localization/semi_localizations.dart';

import '../theme/semi_icon_theme.dart';
import '../theme/semi_spin_theme.dart';
import '../theme/semi_spin_theme_data.dart';
import '../theme/semi_theme.dart';
import '../theme/semi_theme_data.dart';
import '../theme/semi_tree_theme.dart';
import '../theme/semi_tree_theme_data.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icon_data.dart';
import 'icon/semi_icons.dart';
import 'semi_checkbox.dart';
import 'semi_highlight.dart';
import 'semi_input.dart';
import 'semi_spin.dart';
import 'highlight_algorithm.dart';

/// 父子选择联动（上游 `checkRelation: 'related' | 'unRelated'`）。
enum SemiTreeCheckRelation { related, unRelated }

/// 展开动作（上游 `expandAction: false | 'click' | 'doubleClick'`；`false` 是
/// Dart 保留字，照 `none` 先例命名）。
enum SemiTreeExpandAction { none, click, doubleClick }

/// 虚拟化参数（上游 `virtualize?`（`{ itemSize, height, width }`））。
///
/// Flutter 里列表高度由父约束/`height` 决定（AutoSizer 未移植——note-only
/// `auto-wrapper`）：`height` 非空时用 `SizedBox` 定高，否则需要父级有界高度。
class SemiTreeVirtualize {
  const SemiTreeVirtualize({required this.itemSize, this.height, this.width});

  /// 行高（上游 react-window `itemSize`）。
  final double itemSize;

  /// 列表高度（上游 AutoSizer 的 `defaultHeight`）。
  final double? height;

  /// 列表宽度（上游 AutoSizer 的 `defaultWidth`；Flutter 横向铺满父宽）。
  final double? width;
}

/// 树节点（上游 `TreeNodeData`；key 收敛 String——上游 `key?: string`）。
class SemiTreeNodeData {
  const SemiTreeNodeData({
    required this.key,
    this.label,
    this.icon,
    this.value,
    this.disabled = false,
    this.isLeaf,
    this.children,
  });

  /// 唯一键（`keyMaps.key` 缺省域；本移植固定 `key`）。
  final String key;

  /// 标题：String | Widget。
  final Object? label;

  /// 节点图标（优先于 directory/tree icon）。
  final Widget? icon;

  /// 值（`onChange` 回传 `value ?? key`；`value` 也可作为受控 `value` 输入）。
  final Object? value;

  /// 节点禁用（点击/勾选不响应；★箭头仍可展开——上游 quirk 照抄）。
  final bool disabled;

  /// 叶子标记（false 强制非叶子；null 按 children/loadData 推断）。
  final bool? isLeaf;

  /// 子节点。
  final List<SemiTreeNodeData>? children;
}

/// 搜索框渲染参数（上游 `SearchRenderProps`；`searchRender` 自定义时回传）。
class SemiTreeSearchProps {
  const SemiTreeSearchProps({
    required this.placeholder,
    required this.value,
    required this.onChange,
    required this.showClear,
  });

  final String placeholder;
  final String value;
  final ValueChanged<String> onChange;
  final bool showClear;
}

/// 过滤函数（上游 `filterTreeNode: (inputValue, treeNodeString, data) => bool`）。
typedef SemiTreeFilter = bool Function(
  String inputValue,
  String nodeString,
  SemiTreeNodeData data,
);

/// 展开图标构建器（上游 `expandIcon` 函数形态：`{ onClick, expanded }`）。
typedef SemiTreeExpandIconBuilder = Widget Function(
  bool expanded,
  VoidCallback onExpand,
);

/// 树级图标构建器（上游 `icon: (props: TreeNodeProps) => ReactNode`）。
typedef SemiTreeIconBuilder = Widget Function(SemiTreeNodeData data);

/// 标题渲染器（上游 `renderLabel(label, treeNode, searchWord)`）。
typedef SemiTreeLabelBuilder = Widget Function(
  Object? label,
  SemiTreeNodeData data,
  String searchWord,
);

/// Imperative handle for tree search. After detaching, calls are ignored.
class SemiTreeController {
  _SemiTreeState? _state;

  /// Sets the filter text without invoking [SemiTree.onSearch].
  void search(String value) {
    _state?._controllerSearch(value);
  }

  void _attach(_SemiTreeState state) {
    _state = state;
  }

  void _detach(_SemiTreeState state) {
    if (identical(_state, state)) _state = null;
  }
}

/// 树形控件。
///
/// 数据归一（treeUtil.ts：`convertDataToEntities` + `flattenTreeData`）：
/// `treeData` 拍平成 `flattenNodes`（展开/过滤后可见行），`keyEntities` 记录
/// level/pos/parent 供级联勾选、祖先展开、缩进与 ARIA。展开（foundation.ts:696-752）：
/// `expandedKeys` 非 null 受控；`expandAll/defaultExpandAll/autoExpandParent`
/// 按上游首帧口径计算；搜索时展开集合切到 `filteredExpandedKeys`。勾选
/// （foundation.ts:609-694）：`related` 级联后代 + 祖先半选（`halfChecked`），
/// `unRelated` 各自独立；`leafOnly`/`autoMergeValue` 决定 onChange 载荷。
/// 过滤（foundation.ts:526-567）：命中节点 + 祖先展开（`filteredExpandedKeys`）
/// + 命中/祖先/后代可见集（`filteredShownKeys`，`showFilteredOnly` 才裁剪）；
/// String 标题走 [SemiHighlight]（`-highlight` 类：bold + primary + 背景继承）。
/// 异步加载（foundation.ts:754-787）：展开时 `loadData` 未加载节点显示 Spin，
/// 完成后记 `loadedKeys` 并回调 `onLoad`。运动（tree.scss:1 `animation.scss`）：
/// 展开/收起插入块 200ms 高度+fade（`duration={200}`；虚拟化模式上游不播动画）。
/// ★未移植：draggable 拖拽、renderFullLabel、treeDataSimpleJson、keyMaps、
/// disableStrictly、scrollTo/preventScroll、searchRender 样式类、className/style
/// （见 docs/semi_tree.md 差异清单）。
class SemiTree extends StatefulWidget {
  const SemiTree({
    super.key,
    this.treeData = const <SemiTreeNodeData>[],
    this.value,
    this.defaultValue,
    this.expandedKeys,
    this.defaultExpandedKeys,
    this.expandAll = false,
    this.defaultExpandAll = false,
    this.autoExpandParent = false,
    this.multiple = false,
    this.checkRelation = SemiTreeCheckRelation.related,
    this.leafOnly = false,
    this.autoMergeValue = true,
    this.onChangeWithObject = false,
    this.disabled = false,
    this.directory = false,
    this.icon,
    this.blockNode = true,
    this.expandAction = SemiTreeExpandAction.none,
    this.expandIcon,
    this.motion = true,
    this.showLine = false,
    this.labelEllipsis,
    this.filterTreeNode,
    this.treeNodeFilterProp = 'label',
    this.showFilteredOnly = false,
    this.searchPlaceholder,
    this.showClear = true,
    this.searchRender,
    this.renderLabel,
    this.loadData,
    this.loadedKeys,
    this.onLoad,
    this.controller,
    this.showSearch = true,
    this.virtualize,
    this.emptyContent,
    this.onChange,
    this.onSelect,
    this.onExpand,
    this.onSearch,
    this.onDoubleClick,
    this.onContextMenu,
    this.semanticsLabel,
  });

  /// Key of the option list (虚拟化/普通两种形态共用).
  static const Key listKey = Key('SemiTree.list');

  /// Key of the filter input.
  static const Key searchInputKey = Key('SemiTree.searchInput');

  /// Key of the empty row.
  static const Key emptyKey = Key('SemiTree.empty');

  /// 树数据（`List<SemiTreeNodeData>`；引用变化触发实体重建，建议 const/稳定引用）。
  final List<SemiTreeNodeData> treeData;

  /// 选中值（单选用 key/value；多选用 List；非 null 即受控——交互只回调）。
  final Object? value;

  /// 未受控初值。
  final Object? defaultValue;

  /// 展开键（非 null 即受控；变更时按 autoExpandParent 重算）。
  final List<String>? expandedKeys;

  /// 未受控展开初值（首帧强制 autoExpandParent——上游 `!prevProps` 口径）。
  final List<String>? defaultExpandedKeys;

  /// 数据变化时自动全展开（上游 `expandAll`）。
  final bool expandAll;

  /// 首帧全展开。
  final bool defaultExpandAll;

  /// 展开祖先（受控/初值计算时是否带上祖先）。
  final bool autoExpandParent;

  /// 多选（checkbox 模式；行点击与 checkbox 都切换勾选）。
  final bool multiple;

  /// 勾选联动口径。
  final SemiTreeCheckRelation checkRelation;

  /// onChange 载荷只保留叶子键（normalizeKeyList leafOnly）。
  final bool leafOnly;

  /// 关联模式合并父键（normalizeKeyList，去祖先）。
  final bool autoMergeValue;

  /// onChange 回传数据对象（否则回传 value ?? key）。
  final bool onChangeWithObject;

  /// 整树禁用（节点交互全部关闭；★箭头展开仍可用 quirk）。
  final bool disabled;

  /// 目录模式图标（folder/folder-open/file 兜底）。
  final bool directory;

  /// 树级图标：Widget 或 [SemiTreeIconBuilder]（节点自身 icon 优先）。
  final Object? icon;

  /// 块级行（整行 hover/选中底色；false 时只染标题文字区）。
  final bool blockNode;

  /// 展开动作。
  final SemiTreeExpandAction expandAction;

  /// 自定义展开图标：Widget 或 [SemiTreeExpandIconBuilder]（null 走默认三角）。
  final Object? expandIcon;

  /// 展开/收起动画（虚拟化模式不播——上游同）。
  final bool motion;

  /// 展示缩进引导线。
  final bool showLine;

  /// 标题省略（缺省跟随 virtualize——上游 `labelEllipsis ?? virtualize` quirk）。
  final bool? labelEllipsis;

  /// 过滤开关：bool 或 [SemiTreeFilter]（null/false 不渲染搜索框）。
  final Object? filterTreeNode;

  /// 过滤字段（缺省 `'label'`；支持 label/value/key/icon）。
  final String treeNodeFilterProp;

  /// 搜索时只展示命中节点及其祖先/后代。
  final bool showFilteredOnly;

  /// 搜索占位文案（缺省 locale「搜索」）。
  final String? searchPlaceholder;

  /// 搜索框清除按钮（缺省 true）。
  final bool showClear;

  /// 自定义搜索框渲染。
  final Widget Function(SemiTreeSearchProps props)? searchRender;

  /// 标题渲染器。
  final SemiTreeLabelBuilder? renderLabel;

  /// 异步加载（展开未加载节点时调用；完成后记入 loadedKeys）。
  final Future<void> Function(SemiTreeNodeData data)? loadData;

  /// 已加载键（非 null 即受控）。
  final List<String>? loadedKeys;

  /// 加载完成回调（上游 onLoad(loadedKeys, node)）。
  final void Function(Set<String> loadedKeys, SemiTreeNodeData data)? onLoad;

  /// Imperative search handle.
  final SemiTreeController? controller;

  /// Whether to render Tree's own search input.
  final bool showSearch;

  /// 虚拟化参数（非 null 走 `ListView.builder`；运动不播）。
  final SemiTreeVirtualize? virtualize;

  /// 空状态内容（缺省 locale「暂无数据」）。
  final Object? emptyContent;

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

  /// 搜索回调（上游 `onSearch(input, filteredExpandedKeys)`）。
  final void Function(String input, List<String> filteredExpandedKeys)?
  onSearch;

  /// 双击回调（上游 `onDoubleClick(e, node)`——去 DOM 事件）。
  final ValueChanged<SemiTreeNodeData>? onDoubleClick;

  /// 右键回调（上游 `onContextMenu(e, node)`——去 DOM 事件）。
  final ValueChanged<SemiTreeNodeData>? onContextMenu;

  /// 根语义标签（上游 `aria-label`）。
  final String? semanticsLabel;

  @override
  State<SemiTree> createState() => _SemiTreeState();
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

/// 行级派生状态（foundation.ts:392-444 `getTreeNodeProps`）。
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

class _SemiTreeState extends State<SemiTree> {
  late List<_TreeEntity> _roots = <_TreeEntity>[];
  late Map<String, _TreeEntity> _entities = <String, _TreeEntity>{};
  late Map<String, String> _valueEntities = <String, String>{};

  late Set<String> _expanded = <String>{};
  late Set<String> _filteredExpanded = <String>{};
  late Set<String> _filteredKeys = <String>{};
  late Set<String> _filteredShownKeys = <String>{};
  late List<String> _selectedKeys = <String>[];
  late Set<String> _checked = <String>{};
  late Set<String> _halfChecked = <String>{};
  late Set<String> _realChecked = <String>{};
  late Set<String> _loaded = <String>{};
  Set<String> _loading = <String>{};
  String _inputValue = '';
  Set<String> _motionKeys = <String>{};
  String _motionType = '';
  List<_FlatNode>? _cachedFlatten;
  late List<_FlatNode> _flattenNodes = <_FlatNode>[];
  Object? _lastTreeData;

  bool get _searching => _inputValue.isNotEmpty;

  bool get _filterable =>
      widget.filterTreeNode != null && widget.filterTreeNode != false;

  bool get _showFilteredOnly => _searching && widget.showFilteredOnly;

  bool get _expandControlled => widget.expandedKeys != null;

  bool get _valueControlled => widget.value != null;

  bool get _loadControlled => widget.loadedKeys != null;

  bool get _labelEllipsis =>
      widget.labelEllipsis ?? (widget.virtualize != null);

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
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(SemiTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
    var dataChanged = false;
    if (!identical(widget.treeData, _lastTreeData)) {
      _lastTreeData = widget.treeData;
      _rebuildEntities();
      dataChanged = true;
      if (widget.expandAll) {
        _expanded = _entities.keys.toSet();
      }
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
      // 受控 props 变化必须重算拍平列表（否则视觉停留在旧的展开状态）。
      _refreshFlatten();
    }
    if (widget.value != null && widget.value != oldWidget.value) {
      _syncSelectionFromValue();
    } else if (dataChanged && widget.value != null) {
      _syncSelectionFromValue();
    }
    if (widget.loadedKeys != null &&
        !_listEquals(widget.loadedKeys, oldWidget.loadedKeys)) {
      _loaded = widget.loadedKeys!.toSet();
    }
    if (dataChanged && _searching && _filterable) {
      _applyFilter();
    } else if (dataChanged || _searching) {
      _refreshFlatten();
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    super.dispose();
  }

  void _controllerSearch(String value) {
    if (!_filterable) {
      return;
    }
    setState(() {
      _inputValue = value;
      if (value.isEmpty) {
        if (!_expandControlled) {
          _expanded = {
            ..._expanded,
            ..._findAncestorKeys(_selectedKeys, self: true),
          };
        }
        _filteredKeys = <String>{};
        _filteredExpanded = <String>{};
        _filteredShownKeys = <String>{};
        _flattenNodes = _flatten(_expanded);
      } else {
        _applyFilter();
      }
    });
  }

  // -- data ------------------------------------------------------------------

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
  /// key 处理；key 统一 String）。
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
        // 首帧 `autoExpandParent || !prevProps` → 恒带祖先。
        autoExpandParent: true,
      );
      return;
    }
    if (widget.defaultExpandAll || widget.expandAll) {
      _expanded = _entities.values
          .where((entity) => entity.children.isNotEmpty)
          .map((entity) => entity.key)
          .toSet();
      return;
    }
    if (widget.defaultExpandedKeys != null) {
      _expanded = _calcExpandedKeys(
        widget.defaultExpandedKeys!,
        autoExpandParent: true,
      );
      return;
    }
    final initialValue = widget.defaultValue ?? widget.value;
    if (initialValue != null) {
      final keys = _findKeysForValues(initialValue, multiple: widget.multiple);
      _expanded = _findAncestorKeys(keys, self: false);
    }
  }

  /// treeUtil.ts:387-402 `calcExpandedKeys` / `calcExpandedKeysForValues`。
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

  Object? _getValueOrKey(SemiTreeNodeData data) => data.value ?? data.key;

  List<SemiTreeNodeData> _dataForKeys(List<String> keys) => [
    for (final key in keys)
      _entities[key]?.data ??
          SemiTreeNodeData(key: key, label: key, value: key),
  ];

  Object? _payloadForKeys(List<String> keys) {
    if (widget.onChangeWithObject) {
      return _dataForKeys(keys);
    }
    return [for (final data in _dataForKeys(keys)) _getValueOrKey(data)];
  }

  /// foundation.ts:487-524 `notifyMultipleChange`（autoMergeValue → 去祖先、
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

  // -- filtering (foundation.ts:526-567) -------------------------------------

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
    final matched = [
      for (final entity in _entities.values)
        if (_matches(_inputValue, entity.data)) entity.key,
    ];
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

  void _handleSearch(String value) {
    setState(() {
      _inputValue = value;
      if (!_filterable) {
        return;
      }
      if (value.isEmpty) {
        // foundation.ts:537-542：清空搜索时把选中项祖先补进展开集（未受控）。
        if (!_expandControlled) {
          _expanded = {
            ..._expanded,
            ..._findAncestorKeys(_selectedKeys, self: true),
          };
        }
        _filteredKeys = <String>{};
        _filteredExpanded = <String>{};
        _filteredShownKeys = <String>{};
        _motionKeys = <String>{};
        _motionType = '';
        _cachedFlatten = null;
        _flattenNodes = _flatten(_expanded);
      } else {
        _applyFilter();
      }
    });
    widget.onSearch?.call(value, _filteredExpanded.toList());
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

  // -- interactions (foundation.ts:569-787) ---------------------------------

  void _handleTap(_TreeEntity entity) {
    if (_isDisabled(entity)) {
      return;
    }
    if (!widget.multiple) {
      _handleSingleSelect(entity);
    } else {
      _handleMultipleSelect(entity);
    }
    if (widget.expandAction == SemiTreeExpandAction.click) {
      _toggleExpand(entity);
    }
  }

  void _handleSingleSelect(_TreeEntity entity) {
    final key = entity.key;
    final selected = _selectedKeys.contains(key);
    // foundation.ts:594 ★单选恒 notifySelect(key, true) quirk。
    widget.onSelect?.call(key, true, entity.data);
    if (selected) {
      return;
    }
    final next = <String>[key];
    widget.onChange?.call(
      widget.onChangeWithObject ? entity.data : _getValueOrKey(entity.data),
    );
    if (!_valueControlled) {
      setState(() => _selectedKeys = next);
    }
  }

  void _handleMultipleSelect(_TreeEntity entity) {
    final key = entity.key;
    if (widget.checkRelation == SemiTreeCheckRelation.unRelated) {
      final next = <String>{..._realChecked};
      final String target;
      final bool targetStatus;
      if (next.contains(key)) {
        next.remove(key);
        targetStatus = false;
      } else {
        next.add(key);
        targetStatus = true;
      }
      target = key;
      widget.onSelect?.call(target, targetStatus, entity.data);
      _notifyMultipleValue(next);
      if (!_valueControlled) {
        setState(() => _realChecked = next);
      }
      return;
    }
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

  void _toggleExpand(_TreeEntity entity) {
    final hasChildren = entity.data.children?.isNotEmpty == true;
    // foundation.ts:742-746：无 loadData 且无子节点 → 不响应。
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
    // foundation.ts:712-732：受控 expandedKeys 只回调不改态——运动状态也不动
    // （上游把 motionKeys/flatten 更新都放在 `!isExpandControlled` 分支里；
    // 否则受控点击会播「收起又弹回」的幽灵动画）。
    if (!_expandControlled) {
      if (widget.motion && !virtual) {
        _motionKeys = _motionKeysFor(entity.key, expandedKeys).toSet();
        _motionType = wasExpanded ? 'hide' : 'show';
        if (wasExpanded) {
          // 收起时缓存旧拍平列表——动画期继续渲染被移除的行（NodeList 口径）。
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
    if (!wasExpanded && widget.loadData != null) {
      _loadNode(entity);
    }
  }

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
        // foundation.ts:768-770：onLoad 先于内部状态更新（避免重复 loadData）。
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

  void _handleCheck(_TreeEntity entity) {
    if (_isDisabled(entity)) {
      return;
    }
    _handleMultipleSelect(entity);
  }

  void _handleDoubleTap(_TreeEntity entity) {
    widget.onDoubleClick?.call(entity.data);
    if (widget.expandAction == SemiTreeExpandAction.doubleClick) {
      _toggleExpand(entity);
    }
  }

  // -- build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final t = SemiTreeTheme.resolve(context);
    final global = SemiTheme.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final searchNoRes = _searching && _filteredKeys.isEmpty;
    // index.tsx:855-856：无实体，或 showFilteredOnly 下搜索无结果 → 空态。
    final noData =
        _entities.isEmpty || (widget.showFilteredOnly && searchNoRes);

    final list = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: t.spacingTreeOptionListPaddingX,
      ),
      child: widget.virtualize != null
          ? _buildVirtualList(context, t, global, rtl, noData)
          : _buildPlainList(context, t, global, rtl, noData),
    );

    return Semantics(
      container: true,
      label: widget.semanticsLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_filterable && widget.showSearch) _buildSearch(t),
          Expanded(child: list),
        ],
      ),
    );
  }

  Widget _buildSearch(SemiResolvedTreeThemeData t) {
    final strings = SemiLocalizations.of(context);
    final placeholder = widget.searchPlaceholder ?? strings.search;
    final Widget input =
        widget.searchRender?.call(
          SemiTreeSearchProps(
            placeholder: placeholder,
            value: _inputValue,
            onChange: _handleSearch,
            showClear: widget.showClear,
          ),
        ) ??
        SemiInput(
          key: SemiTree.searchInputKey,
          value: _inputValue,
          // index.tsx:633 `prefix: <IconSearch />`。
          prefix: const SemiIcon(SemiIcons.search, size: SemiIconSize.small),
          showClear: widget.showClear,
          placeholder: placeholder,
          semanticsLabel: strings.filterTree,
          onChanged: _handleSearch,
        );
    return Padding(
      // tree.scss:6-9 `&-search-wrapper` padding。
      padding: EdgeInsets.symmetric(
        horizontal: t.spacingTreeSearchWrapperPaddingX,
        vertical: t.spacingTreeSearchWrapperPaddingY,
      ),
      child: input,
    );
  }

  Widget _buildVirtualList(
    BuildContext context,
    SemiResolvedTreeThemeData t,
    SemiThemeData global,
    bool rtl,
    bool noData,
  ) {
    final virtualize = widget.virtualize!;
    final count = noData ? 1 : _rows.length;
    final list = ListView.builder(
      key: SemiTree.listKey,
      padding: EdgeInsets.symmetric(vertical: t.spacingTreeOptionListPaddingY),
      itemExtent: virtualize.itemSize,
      itemCount: count,
      itemBuilder: (context, index) => noData
          ? _buildEmpty(t, global, rtl)
          : _buildRow(context, t, global, rtl, _rows[index]),
    );
    if (virtualize.height != null) {
      return SizedBox(height: virtualize.height, child: list);
    }
    return list;
  }

  Widget _buildPlainList(
    BuildContext context,
    SemiResolvedTreeThemeData t,
    SemiThemeData global,
    bool rtl,
    bool noData,
  ) {
    // 收起动画期继续渲染缓存行（NodeList 口径）。
    final rows = _motionType == 'hide' && _cachedFlatten != null
        ? _cachedFlatten!
        : _rows;
    final children = <Widget>[];
    if (noData) {
      children.add(_buildEmpty(t, global, rtl));
    } else {
      var index = 0;
      while (index < rows.length) {
        final row = rows[index];
        if (_motionKeys.contains(row.entity.key)) {
          final group = <Widget>[];
          while (index < rows.length &&
              _motionKeys.contains(rows[index].entity.key)) {
            group.add(_buildRow(context, t, global, rtl, rows[index]));
            index++;
          }
          children.add(
            _TreeMotionBlock(
              key: ValueKey('motion-${row.entity.key}'),
              expand: _motionType != 'hide',
              duration: _TreeMetrics.collapsibleDuration,
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
          children.add(_buildRow(context, t, global, rtl, row));
          index++;
        }
      }
    }
    return SingleChildScrollView(
      key: SemiTree.listKey,
      padding: EdgeInsets.symmetric(vertical: t.spacingTreeOptionListPaddingY),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  List<_FlatNode> get _rows => _flattenNodes;

  Widget _buildEmpty(
    SemiResolvedTreeThemeData t,
    SemiThemeData global,
    bool rtl,
  ) {
    final emptyText = Text(
      SemiLocalizations.of(context).noData,
      style: TextStyle(
        fontSize: _TreeMetrics.fontSizeRegular,
        color: t.colorTreeOptionDisabledTextDefault,
      ),
    );
    final Widget content = switch (widget.emptyContent) {
      final Widget widget => widget,
      final Object value => Text(
        value.toString(),
        style: TextStyle(
          fontSize: _TreeMetrics.fontSizeRegular,
          color: t.colorTreeOptionDisabledTextDefault,
        ),
      ),
      null => emptyText,
    };
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: t.spacingTreeOptionPaddingTop,
        horizontal: t.spacingTreeOptionLevel1PaddingLeft,
      ),
      child: Center(key: SemiTree.emptyKey, child: content),
    );
  }

  Widget _buildRow(
    BuildContext context,
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
      blockNode: widget.blockNode,
      multiple: widget.multiple,
      labelEllipsis: _labelEllipsis,
      directory: widget.directory,
      treeIcon: widget.icon,
      expandIcon: widget.expandIcon,
      renderLabel: widget.renderLabel,
      keyword: _inputValue,
      expandAction: widget.expandAction,
      hasDoubleClick: widget.onDoubleClick != null,
      onTap: () => _handleTap(entity),
      onDoubleTap: () => _handleDoubleTap(entity),
      onToggleExpand: () => _toggleExpand(entity),
      onCheck: () => _handleCheck(entity),
      onContextMenu: () => widget.onContextMenu?.call(entity.data),
    );
  }
}

/// 展开/收起运动块（nodeList.tsx + nodeCollapsible.tsx：Collapsible 高度+
/// fade，`duration={200}` 硬编码）。
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

/// 单行（treeNode.tsx + indent.tsx）。
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
      // tree.scss:92-118：label-text / checkbox-addon 各自 hover fill-0 /
      // active fill-1 / selected primary-light（本移植只染标题文字区——见差异清单）。
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
          // tree.scss:70-76 `-label > .semi-icon` margin-right。
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
      // 缩进引导线 + switcher 折线画在整行盒上（tree.scss:238-314）：
      // 逐行 CustomPaint 避免 `Row(stretch)` 在无界高度（滚动视图）里失效。
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
        // tree.scss:31-36 li padding：上下 4 + level1 左 8（缩进由左侧空槽补位）。
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
                // tree.scss:43-51 / :270-279 expand/empty/switcher 槽 width 12。
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
          // 子槽 Listener 先于行 Listener 收到 down（命中链叶子先）——它把
          // `_childClaimed` 置 true 后，行不再把这次按下当作行点击。
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
            // tree.scss:59 `transform: scale(...)`（token = scale(1,1) 恒等；
            // ★上游编译产物 transform: scale(scale(1,1)) 无效 CSS bug 留档）。
            // transitionDelayTreeOptionBg：tree.scss:57 delay 槽 AnimatedContainer
            // 无对应——注释引用（0ms 恒等）。
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

  /// 单击立即触发（上游 onClick 即时；仅双击动作存在时按 300ms 窗口识别双击）。
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
      child: SemiCheckbox(
        key: ValueKey('tree-checkbox-${widget.eventKey}'),
        checked: props.checked,
        indeterminate: props.halfChecked,
        disabled: widget.disabled,
        // treeNode.tsx:249-267：勾选走 onCheck（关联模式级联）。
        onChanged: (_) => widget.onCheck(),
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
      if (widget.props.filtered &&
          widget.keyword.isNotEmpty &&
          widget.renderLabel == null) {
        // treeNode.tsx:318-335 + tree.scss:137-142 `-highlight`：bold +
        // primary 字色 + 背景继承（覆盖 Highlight 默认底色）。
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
      // tree.scss:92-103 `-label-text` / `checkbox-addon`：圆角 checkbox addon
      // + hover fill-0 / active fill-1（block 模式被覆盖为透明）。
      duration: t.transitionDurationTreeOptionBg,
      curve: t.transitionFunctionTreeOptionBg,
      decoration: BoxDecoration(
        color: labelBg,
        borderRadius: BorderRadius.circular(t.radiusTreeCheckboxAddon),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: _TreeMetrics.fontSizeRegular,
          color: textColor,
          // tree.scss:62 `word-break: break-word`（Text 默认换行）。
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
    if (widget.directory) {
      // treeNode.tsx:281-302 directory 兜底：file / folder / folder-open。
      if (widget.isLeaf) {
        return const SemiIcon(SemiIcons.file, size: SemiIconSize.normal);
      }
      return SemiIcon(
        widget.props.expanded ? SemiIcons.folderOpen : SemiIcons.folder,
        size: SemiIconSize.normal,
      );
    }
    return null;
  }

  Widget _buildArrow(SemiResolvedTreeThemeData t, bool rtl) {
    if (widget.props.loading) {
      // treeNode.tsx:205-208 `loading` → Spin（`-spin-icon` 12×12 + primary）。
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
      // treeNode.tsx:270-279 switcher 叶子折线由行级 painter 绘制
      // （`switcher-leaf-line`）；treeNode.tsx:244-246 非 showLine 时
      // `<span class="-empty-icon" />` 只占 12 宽。
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
    //（tree.scss:131-135 `transform: rotate(270deg)`；rtl.scss:31-35 rotate(90deg)）。
    final rotate = widget.props.expanded ? 0.0 : (rtl ? 90.0 : 270.0);
    // tree.scss:388-398（block 列表）`.option-expand-icon:hover/:active` 图标色
    // icon-hover / icon-active（非 block 不消费两色——照 CSS 作用域）。
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
          // 箭头命中即抢行点击（上游 onClick stopPropagation）。
          _claimChild();
          setState(() => _arrowPressed = true);
        },
        onPointerUp: (_) => setState(() => _arrowPressed = false),
        onPointerCancel: (_) => setState(() => _arrowPressed = false),
        child: GestureDetector(
          key: ValueKey('tree-expand-${widget.eventKey}'),
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

/// 行级缩进引导线 + 叶子折线（indent.tsx + tree.scss:238-314）。
///
/// 每个祖先单元一条竖线（`isEnd` 单元不画），叶子在 switcher 槽画竖线 +
/// 横向枝线；枝线宽 `calc(($spacing-tree_option_level-paddingLeft / 2) * 0.8)`
/// （20/2*0.8 = 8）；竖线色 `var(--semi-color-text-3)`。
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
    // 缩进单元线：单元 i 的 `inset-inline-start` = emptyIcon / 2。
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
    // switcher-leaf-line：switcher 槽中心竖线（末叶只到中线）+ 横向枝线。
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
abstract final class _TreeMetrics {
  /// tree.scss:61 `@include font-size-regular`（= 14——行字号）。
  static const double fontSizeRegular = 14;

  /// nodeList.tsx:50 `duration={200}`（NodeCollapsible 展开/收起时长）。
  static const Duration collapsibleDuration = Duration(milliseconds: 200);

  /// zh_CN.ts:125 `emptyText: '暂无数据'`。
  // ignore: unused_field
  static const String localeEmptyText = '暂无数据';

  /// zh_CN.ts:126 `searchPlaceholder: '搜索'`。
  // ignore: unused_field
  static const String localeSearchPlaceholder = '搜索';

  // HARDCODES anchors retained from upstream source:
  // aria-label='Filter Tree'; aria-multiselectable; role="treeitem".
  // constants.ts:6 `EXPAND_ACTION: [false, 'click', 'doubleClick']`。
  // constants.ts:7 `JSON_KEY_SPLIT: '_SEMI_TREE_SPLIT_'`（treeDataSimpleJson 未移植）。
  // index.tsx:861-862 `aria-multiselectable`；treeNode.tsx:456 `role="treeitem"`
  // （Flutter 以 Semantics 近似）。
  // treeNode.tsx:55 `debounce(this.onSelect, 500)`（双击模式选择防抖——本移植
  // 单击即选、双击补发 onDoubleClick/展开）。
  // foundation.ts:34 `DRAG_OFFSET = 0.45`（draggable 未移植）。
  // treeUtil.ts:62 `user-select: none`（Flutter 文本默认不可选）。
  // treeNode.tsx:86/:112 `isEnterPress`（li/checkbox 无 tabindex，Enter 实际不可达
  // ——note-only）。
  // index.tsx:34 `IconSearch` 前缀（SemiIcons.search）。
  // autoSizer.tsx:84 `auto-wrapper`（AutoSizer 未移植——virtualize.height 定高）。
  // tree.scss:258/:292 `var(--semi-color-text-3)` 引导线色（读 theme.colors.colorText3）。
}
