// SemiForm — 表单（Semi Design 组件移植）。
//
// 上游：packages/semi-foundation/form/{variables.scss, form.scss, rtl.scss,
// constants.ts, foundation.ts, interface.ts, utils.ts}、
// packages/semi-ui/form/{baseForm.tsx, hoc/withField.tsx, field.tsx,
// arrayField.tsx, group.tsx, slot.tsx, section.tsx, label.tsx,
// errorMessage.tsx, hooks/useForm.tsx} + zh_CN.ts locale。
// 主题对账 40 = 40 FIELDS + 0 MOTION + 0 INTERNAL
// （tool/generate_form.py）——★0 死变量（40 条声明均被 form.scss/rtl.scss
// 消费）。校验引擎等价 async-validator 常用 RuleItem 子集 + 自定义
// validator（FutureOr），竞态防护（validatePromise 序号 token）照抄。
//
// HARDCODES（另列）上游片段以注释逐字留档在 `_FormMetrics` / 调用点，
// 生成器 HARDCODES 锚点断言这些片段出现在本文件。
import 'dart:async';

import 'package:flutter/widgets.dart';

import '../localization/semi_localizations.dart';

import '../theme/semi_form_theme.dart';
import '../theme/semi_form_theme_data.dart';
import '../theme/semi_icon_theme.dart';
import '../theme/semi_theme.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icons.dart';
import 'semi_checkbox.dart';
import 'semi_input.dart';
import 'semi_input_number.dart';
import 'semi_radio.dart';
import 'semi_rating.dart';
import 'semi_select.dart';
import 'semi_slider.dart';
import 'semi_switch.dart';

/// 校验触发时机（上游 `trigger`：constants.ts:15
/// `DEFAULT_TRIGGER: 'change'`——field > form > change）。
enum SemiFormTrigger { change, blur, custom, mount }

/// 标签位置（上游 `labelPosition: 'top' | 'left' | 'inset'`——baseForm.tsx:103
/// `labelPosition: 'top'`）。
enum SemiFormLabelPosition { top, left, inset }

/// 表单布局（上游 `layout: 'vertical' | 'horizontal'`——字段间距模式）。
enum SemiFormLayout { vertical, horizontal }

/// 校验状态（上游 withField `status: 'error' | 'success' | 'default'` +
/// props.validateStatus 覆盖）。
enum SemiFormValidateStatus { normal, error, warning, success }

/// 规则类型（async-validator `RuleType` 常用子集——`fields`/`defaultField`
/// 嵌套对象规则不移植，见 docs 差异清单）。
enum SemiFormFieldRuleType {
  string,
  number,
  integer,
  boolean,
  enum_,
  array,
  url,
  email,
  regexp,
  any,
}

/// 单条校验规则（async-validator `RuleItem` 子集）。
class SemiFormFieldRule {
  const SemiFormFieldRule({
    this.type = SemiFormFieldRuleType.string,
    this.required = false,
    this.pattern,
    this.min,
    this.max,
    this.len,
    this.values,
    this.whitespace = false,
    this.message,
    this.transform,
  });

  /// 值类型（`type`）。
  final SemiFormFieldRuleType type;

  /// 必填（`required`；required 由 rules 派生——utils.ts:59 `isRequired`）。
  final bool required;

  /// 正则（`pattern`）。
  final RegExp? pattern;

  /// 最小值/长度（`min`）。
  final double? min;

  /// 最大值/长度（`max`）。
  final double? max;

  /// 精确长度（`len`）。
  final int? len;

  /// 枚举取值（`enum`）。
  final List<Object?>? values;

  /// 纯空白视为未填（`whitespace`）。
  final bool whitespace;

  /// 错误文案（`message`；★空串仍算错误——withField.tsx:311 quirk 照抄）。
  final String? message;

  /// 校验前值转换（`transform`）。
  final Object? Function(Object? value)? transform;
}

/// 自定义校验（上游字段级 `validator`——`FutureOr<String>`，空串 = 通过）。
typedef SemiFormFieldValidator = FutureOr<String> Function(
  Object? value,
  Map<String, Object?> values,
);

/// 表单级校验（上游 `validator`/`validateFields`——返回错误表或空）。
typedef SemiFormValidator = FutureOr<Map<String, Object?>> Function(
  Map<String, Object?> values,
);

/// 字段控件构建器。
typedef SemiFormFieldBuilder = Widget Function(
  BuildContext context,
  SemiFormFieldControl control,
);

/// ArrayField 行（上游 `{ key, field, remove }`）。
class SemiArrayFieldItem {
  const SemiArrayFieldItem({
    required this.key,
    required this.field,
    required this.remove,
  });

  /// 行稳定 key（`getUuidv4`——重挂载语义用 Key 等效）。
  final String key;

  /// 行字段路径（`'people[0]'` 式）。
  final String field;

  /// 移除本行。
  final VoidCallback remove;
}

/// ArrayField 构建器入参。
class SemiArrayFieldApi {
  const SemiArrayFieldApi({
    required this.items,
    required this.add,
    required this.addWithInitValue,
  });

  /// 当前行。
  final List<SemiArrayFieldItem> items;

  /// 末尾/指定下标插入空行（`add(index?)`）。
  final void Function([int? index]) add;

  /// 末尾/指定下标插入带初值行（`addWithInitValue(obj, index?)`）。
  final void Function(Object? value, [int? index]) addWithInitValue;
}

typedef SemiArrayFieldBuilder = Widget Function(
  BuildContext context,
  SemiArrayFieldApi api,
);

/// 字段构建器入参（withField 注入 props 的 Flutter 口径）。
class SemiFormFieldControl {
  const SemiFormFieldControl({
    required this.field,
    required this.value,
    required this.error,
    required this.touched,
    required this.validateStatus,
    required this.disabled,
    required this.required,
    required this.onChanged,
    required this.onBlur,
    required this.setValue,
    required this.setTouched,
    required this.setError,
    required this.validate,
    required this.reset,
    this.insetLabel,
  });

  /// inset 标签（labelPosition: inset 时供包装透传 insetLabel）。
  final Object? insetLabel;

  /// 字段路径。
  final String field;

  /// 当前值。
  final Object? value;

  /// 当前错误（String | `List<String>` | null）。
  final Object? error;

  /// 是否已触碰。
  final bool touched;

  /// 校验状态（props.validateStatus 优先，否则本地 status 映射）。
  final SemiFormValidateStatus validateStatus;

  /// 禁用（Form.disabled 级联）。
  final bool disabled;

  /// 必填（rules 派生）。
  final bool required;

  /// 值变更入口（含 convert/空值语义/提交/触发校验——withField `handleChange`）。
  final ValueChanged<Object?> onChanged;

  /// 失焦入口（置 touched + blur 触发校验——`handleBlur`）。
  final VoidCallback onBlur;

  /// 直接设值（不触发校验——fieldApi.setValue）。
  final void Function(Object? value) setValue;

  /// 置 touched（fieldApi.setTouched）。
  final ValueChanged<bool> setTouched;

  /// 直接设错误（fieldApi.setError）。
  final ValueChanged<Object?> setError;

  /// 手动校验（trigger: custom 口径）。
  final Future<void> Function() validate;

  /// 重置本字段（恢复 initValue、清错误/touched）。
  final VoidCallback reset;
}

/// 表单快照（上游 `FormState { values, errors, touched }`）。
class SemiFormState {
  const SemiFormState({
    required this.values,
    required this.errors,
    required this.touched,
  });

  /// 全部值（嵌套 Map/List）。
  final Map<String, Object?> values;

  /// 全部错误（嵌套；字段路径 → String | `List<String>`）。
  final Map<String, Object?> errors;

  /// 触碰表（嵌套；字段路径 → bool）。
  final Map<String, Object?> touched;

  SemiFormState copy() => SemiFormState(
    values: _deepCopyMap(values),
    errors: _deepCopyMap(errors),
    touched: _deepCopyMap(touched),
  );
}

Map<String, Object?> _deepCopyMap(Map<String, Object?> src) {
  final out = <String, Object?>{};
  src.forEach((k, v) {
    if (v is Map<String, Object?>) {
      out[k] = _deepCopyMap(v);
    } else if (v is List) {
      out[k] = [
        for (final e in v)
          e is Map<String, Object?>
              ? _deepCopyMap(e)
              : (e is List ? List.of(e) : e),
      ];
    } else {
      out[k] = v;
    }
  });
  return out;
}

// -- field path utils（lodash toPath/get/set/remove 等价） -------------------

List<String> _toPath(String path) => [
  for (final seg in path.split('.')) ..._splitIndex(seg),
];

List<String> _splitIndex(String seg) {
  final out = <String>[];
  final re = RegExp(r'([^[\]]+)|\[(\d+)\]');
  for (final m in re.allMatches(seg)) {
    out.add(m.group(1) ?? m.group(2)!);
  }
  return out;
}

Object? _pathGet(Object? root, String path) {
  var cur = root;
  for (final key in _toPath(path)) {
    if (cur is Map) {
      cur = cur[key];
    } else if (cur is List) {
      final idx = int.tryParse(key);
      cur = idx == null || idx < 0 || idx >= cur.length ? null : cur[idx];
    } else {
      return null;
    }
  }
  return cur;
}

bool _pathHas(Object? root, String path) {
  var cur = root;
  final segs = _toPath(path);
  for (var i = 0; i < segs.length; i++) {
    final key = segs[i];
    if (cur is Map) {
      if (!cur.containsKey(key)) return false;
      cur = cur[key];
    } else if (cur is List) {
      final idx = int.tryParse(key);
      if (idx == null || idx < 0 || idx >= cur.length) return false;
      cur = cur[idx];
    } else {
      return false;
    }
  }
  return true;
}

void _pathSet(Map<String, Object?> root, String path, Object? value) {
  final segs = _toPath(path);
  Object? container = root;
  for (var i = 0; i < segs.length - 1; i++) {
    final key = segs[i];
    final nextIsIndex = int.tryParse(segs[i + 1]) != null;
    Object? child;
    if (container is List) {
      // 数字下标下降（lodash set 口径——people[0].name）。
      final idx = int.tryParse(key);
      if (idx == null) return;
      while (container.length <= idx) {
        container.add(null);
      }
      child = container[idx];
      if (child is! Map && child is! List) {
        child = nextIsIndex ? <Object?>[] : <String, Object?>{};
        container[idx] = child;
      }
    } else if (container is Map<String, Object?>) {
      child = container[key];
      if (child is! Map && child is! List) {
        child = nextIsIndex ? <Object?>[] : <String, Object?>{};
        container[key] = child;
      }
    } else {
      return;
    }
    container = child;
  }
  final last = segs.last;
  if (container is List) {
    final idx = int.tryParse(last);
    if (idx == null) return;
    while (container.length <= idx) {
      container.add(null);
    }
    container[idx] = value;
  } else if (container is Map<String, Object?>) {
    container[last] = value;
  }
}

void _pathRemove(Map<String, Object?> root, String path) {
  final segs = _toPath(path);
  Object? container = root;
  for (var i = 0; i < segs.length - 1; i++) {
    final key = segs[i];
    if (container is List) {
      final idx = int.tryParse(key);
      if (idx == null || idx >= container.length) return;
      container = container[idx];
    } else if (container is Map<String, Object?>) {
      if (!container.containsKey(key)) return;
      container = container[key];
    } else {
      return;
    }
  }
  final last = segs.last;
  if (container is List) {
    final idx = int.tryParse(last);
    if (idx == null || idx >= container.length) return;
    container[idx] = null;
  } else if (container is Map<String, Object?>) {
    container.remove(last);
  }
}

/// 字段注册桩（foundation.ts `FieldStaff`——fieldApi 由字段 State 提供）。
class _FieldStaff {
  _FieldStaff({
    required this.field,
    required this.fieldApi,
    required this.keepState,
    required this.allowEmpty,
    required this.scrollKey,
  });

  final String field;
  final SemiFormFieldControl fieldApi;
  final bool keepState;
  final bool allowEmpty;
  final GlobalKey scrollKey;
}

/// ArrayField 注册桩（foundation.ts `ArrayFieldStaff`——updateKey 重挂载）。
class _ArrayFieldStaff {
  _ArrayFieldStaff({required this.initValue, this.updateKey = 0});

  final Object? initValue;
  final int updateKey;
}

/// 表单控制器（上游 FormApi + FormFoundation 数据面——
/// foundation.ts:81-113 `BaseFormApi`）。可在 Form 挂载前创建（useForm
/// 代理口径：方法转发到绑定后的数据面）。
class SemiFormController {
  // -- data (foundation.ts `data: FormState`) --------------------------------
  Map<String, Object?> _values = <String, Object?>{};
  Map<String, Object?> _errors = <String, Object?>{};
  Map<String, Object?> _touched = <String, Object?>{};
  Map<String, Object?> _initValues = <String, Object?>{};

  /// foundation.ts:47-56 `fields` / `registeredArrayField`。
  final Map<String, _FieldStaff> _fields = <String, _FieldStaff>{};
  final Map<String, _ArrayFieldStaff> _arrayFields =
      <String, _ArrayFieldStaff>{};
  final Map<String, bool> _registered = <String, bool>{};

  VoidCallback? _onChange;
  VoidCallback? _onReset;
  void Function(SemiFormState state)? _notifyState;
  void Function(Map<String, Object?> values, Map<String, Object?> changed)?
  _notifyValueChange;
  void Function(Map<String, Object?> errors, Map<String, Object?> changed)?
  _notifyErrorChange;
  void Function(Map<String, Object?> values)? _notifySubmit;
  void Function(Map<String, Object?> errors, Map<String, Object?> values)?
  _notifySubmitFail;
  SemiFormValidator? _formValidator;
  bool _allowEmpty = false;
  bool _autoScrollToError = false;

  /// 状态版本（每次通知自增——InheritedWidget 传播用）。
  int _version = 0;

  bool get isBound => _notifyState != null;

  /// [SemiForm] 绑定（useForm 代理 __bind 等效）。
  void _bind({
    required void Function(SemiFormState state) notifyState,
    required void Function(
      Map<String, Object?> values,
      Map<String, Object?> changed,
    )
    notifyValueChange,
    required void Function(
      Map<String, Object?> errors,
      Map<String, Object?> changed,
    )
    notifyErrorChange,
    required void Function(Map<String, Object?> values) notifySubmit,
    required void Function(
      Map<String, Object?> errors,
      Map<String, Object?> values,
    )
    notifySubmitFail,
    required VoidCallback onChange,
    required VoidCallback onReset,
    required SemiFormValidator? formValidator,
    required bool allowEmpty,
    required bool autoScrollToError,
    required Map<String, Object?> initValues,
  }) {
    _notifyState = notifyState;
    _notifyValueChange = notifyValueChange;
    _notifyErrorChange = notifyErrorChange;
    _notifySubmit = notifySubmit;
    _notifySubmitFail = notifySubmitFail;
    _onChange = onChange;
    _onReset = onReset;
    _formValidator = formValidator;
    _allowEmpty = allowEmpty;
    _autoScrollToError = autoScrollToError;
    _initValues = initValues;
  }

  void _unbind() {
    _notifyState = null;
    _notifyValueChange = null;
    _notifyErrorChange = null;
    _notifySubmit = null;
    _notifySubmitFail = null;
    _onChange = null;
    _onReset = null;
    _formValidator = null;
    _fields.clear();
    _arrayFields.clear();
    _registered.clear();
  }

  /// foundation.ts:42-45（initValues 深拷贝起步）。
  void _resetData(Map<String, Object?> initValues) {
    _values = _deepCopyMap(initValues);
    _errors = <String, Object?>{};
    _touched = <String, Object?>{};
    _initValues = _deepCopyMap(initValues);
  }

  void _notify() {
    _version++;
    _notifyState?.call(
      SemiFormState(values: _values, errors: _errors, touched: _touched),
    );
    // baseForm adapter notifyChange → onChange(formState)。
    _onChange?.call();
  }

  // -- register / unRegister (foundation.ts:93-188) --------------------------

  void _registerStaff(
    String field,
    _FieldStaff staff, {
    Object? value,
    Object? error,
  }) {
    _fields[field] = staff;
    final allowEmpty = staff.allowEmpty || _allowEmpty;
    // 注册发生在 build 阶段——只静默同步 state（value/error 由字段侧算好传入）。
    _updateStateValue(
      field,
      _silence(value, allowEmpty),
      notNotify: true,
      allowEmpty: allowEmpty,
    );
    if (error != null) {
      _updateStateError(field, error, notNotify: true);
    }
    if (_pathHas(_touched, field)) {
      _updateStateTouched(
        field,
        _pathGet(_touched, field) == true,
        notNotify: true,
      );
    }
  }

  void _unRegisterStaff(String field, _FieldStaff staff) {
    final current = _fields[field];
    if (current != null && !identical(current, staff)) {
      // 替换实例已先注册（foundation.ts:199-205 owner 口径）——旧实例注销
      // 不得清掉新值。
      return;
    }
    _fields.remove(field);
    // foundation.ts:166-188（registered 只增不删——keepState 重挂载判据）。
    if (!staff.keepState) {
      _pathRemove(_values, field);
      _pathRemove(_errors, field);
      _pathRemove(_touched, field);
    }
    // 注销常发生在 build 阶段（子树移除）——deferred notify 防 setState-during-build。
    if (_notifyState != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _notify());
    }
  }

  Object? _silence(Object? value, bool allowEmpty) {
    if (!allowEmpty && value == '') return null;
    return value;
  }

  // -- state ops (foundation.ts:520-610) ------------------------------------

  void _updateStateValue(
    String field,
    Object? value, {
    bool notNotify = false,
    bool notUpdate = false,
    bool? allowEmpty,
  }) {
    final allow = allowEmpty ?? _allowEmpty;
    if (!allow && (value == '' || value == null)) {
      // withField.tsx:437-447（emptyValue 归一 undefined——不入 values）。
      _pathRemove(_values, field);
    } else {
      _pathSet(_values, field, value);
    }
    if (!notNotify) {
      _notify();
      _notifyValueChange?.call(_values, {field: value});
    }
  }

  void _updateStateError(
    String field,
    Object? error, {
    bool notNotify = false,
  }) {
    if (error == null) {
      _pathRemove(_errors, field);
    } else {
      _pathSet(_errors, field, error);
    }
    if (!notNotify) {
      _notify();
    }
    _notifyErrorChange?.call(_errors, {field: error});
  }

  void _updateStateTouched(
    String field,
    bool touched, {
    bool notNotify = false,
  }) {
    _pathSet(_touched, field, touched);
    if (!notNotify) _notify();
  }

  // -- FormApi (foundation.ts:718-738 getFormApi) ---------------------------

  /// `getValue(field?)`（深拷贝隔离——needClone 口径）。
  Object? getValue([String? field]) {
    if (field == null) return _deepCopyMap(_values);
    final v = _pathGet(_values, field);
    return v is Map<String, Object?>
        ? _deepCopyMap(v)
        : (v is List ? List.of(v) : v);
  }

  /// `getValues()`。
  Map<String, Object?> getValues() => _deepCopyMap(_values);

  /// `setValue(field, value)`（存在 Field 实体走 fieldApi，否则写 state 并
  /// 同步嵌套字段——foundation.ts:614-643）。
  void setValue(String field, Object? value) {
    final staff = _fields[field];
    final copy = _deepCopyValue(value);
    if (staff != null) {
      staff.fieldApi.setValue(copy);
      return;
    }
    _updateStateValue(field, copy);
    for (final entry in _fields.entries) {
      if (_isNestedField(entry.key, field)) {
        entry.value.fieldApi.setValue(_pathGet(_values, entry.key));
      }
    }
    _bumpArrayField(field);
    _notify();
  }

  /// `setValues(values, {isOverride})`（foundation.ts:486-517）。
  void setValues(Map<String, Object?> values, {bool isOverride = false}) {
    final copy = _deepCopyMap(values);
    for (final staff in _fields.values) {
      // merge（isOverride: false）只覆盖传入路径；override 全量对齐。
      if (!isOverride && !_pathHas(copy, staff.field)) continue;
      final v = _pathGet(copy, staff.field);
      staff.fieldApi.setValue(v is Map<String, Object?> ? _deepCopyMap(v) : v);
    }
    for (final key in _arrayFields.keys.toList()) {
      _bumpArrayField(key);
    }
    if (isOverride) {
      _values = copy;
    }
    _notify();
    _notifyValueChange?.call(_values, copy);
  }

  /// `getError(field?)`。
  Object? getError([String? field]) {
    if (field == null) return _deepCopyMap(_errors);
    return _pathGet(_errors, field);
  }

  /// `setError(field, error)`。
  void setError(String field, Object? error) {
    final staff = _fields[field];
    if (staff != null) {
      staff.fieldApi.setError(error);
      return;
    }
    _updateStateError(field, error);
    for (final entry in _fields.entries) {
      if (_isNestedField(entry.key, field)) {
        entry.value.fieldApi.setError(_pathGet(_errors, entry.key));
      }
    }
    _bumpArrayField(field);
    _notify();
  }

  /// `getTouched(field?)`。
  Object? getTouched([String? field]) =>
      field == null ? Map.of(_touched) : _pathGet(_touched, field);

  /// `setTouched(field, touched)`。
  void setTouched(String field, bool touched) {
    final staff = _fields[field];
    if (staff != null) {
      staff.fieldApi.setTouched(touched);
      return;
    }
    _updateStateTouched(field, touched);
    for (final entry in _fields.entries) {
      if (_isNestedField(entry.key, field)) {
        entry.value.fieldApi.setTouched(_pathGet(_touched, entry.key) == true);
      }
    }
    _bumpArrayField(field);
    _notify();
  }

  /// `getFieldExist(field)`。
  bool getFieldExist(String field) => _fields.containsKey(field);

  /// `getFormState()`（深拷贝隔离）。
  SemiFormState getFormState() => SemiFormState(
    values: _deepCopyMap(_values),
    errors: _deepCopyMap(_errors),
    touched: _deepCopyMap(_touched),
  );

  /// `getInitValue(field)` / `getInitValues()`。
  Object? getInitValue([String? field]) =>
      field == null ? _deepCopyMap(_initValues) : _pathGet(_initValues, field);

  Map<String, Object?> getInitValues() => _deepCopyMap(_initValues);

  /// `submitForm()`（foundation.ts:352-366 submit）。
  void submitForm() {
    validate()
        .then((values) {
          _notifySubmit?.call(_deepCopyMap(values));
        })
        .catchError((Object errors) {
          _notifySubmitFail?.call(
            errors is Map<String, Object?>
                ? _deepCopyMap(errors)
                : <String, Object?>{},
            _deepCopyMap(_values),
          );
        });
  }

  /// `reset(fields?)`（foundation.ts:419-447——ArrayField 还原 + updateKey）。
  void reset([List<String>? fields]) {
    final targets = _operateFields(fields);
    for (final staff in targets.values) {
      staff.fieldApi.reset();
    }
    if (_arrayFields.isNotEmpty) {
      for (final key in _arrayFields.keys.toList()) {
        _updateStateValue(
          key,
          _deepCopyValue(_arrayFields[key]!.initValue),
          notNotify: true,
          notUpdate: true,
        );
        _bumpArrayField(key);
      }
    }
    _notify();
    _onReset?.call();
  }

  void _bumpArrayField(String field) {
    final staff = _arrayFields[field];
    if (staff == null) return;
    _arrayFields[field] = _ArrayFieldStaff(
      initValue: staff.initValue,
      updateKey: staff.updateKey + 1, // getUuidv4 重挂载语义
    );
  }

  Object? _deepCopyValue(Object? v) {
    if (v is Map<String, Object?>) return _deepCopyMap(v);
    if (v is List) {
      return [
        for (final e in v)
          e is Map<String, Object?>
              ? _deepCopyMap(e)
              : (e is List ? List.of(e) : e),
      ];
    }
    return v;
  }

  /// `validate(fields? | {fields, silent})`（foundation.ts:216-350——
  /// 表单级 validator 优先，否则逐字段并行；silent 不回写 UI）。
  Future<Map<String, Object?>> validate({
    List<String>? fields,
    bool silent = false,
  }) {
    final formValidator = _formValidator;
    if (formValidator != null) {
      return _formValidate(formValidator, silent: silent);
    }
    return _fieldsValidate(fields: fields, silent: silent);
  }

  Future<Map<String, Object?>> _formValidate(
    SemiFormValidator validator, {
    required bool silent,
  }) async {
    Map<String, Object?> errors;
    try {
      errors = await validator(_deepCopyMap(_values));
    } catch (e) {
      errors = e is Map<String, Object?>
          ? e
          : <String, Object?>{'_form': e.toString()};
    }
    if (errors.isEmpty) {
      if (!silent) {
        for (final staff in _fields.values) {
          staff.fieldApi.setError(null);
        }
        _errors = <String, Object?>{};
        _notify();
      }
      return _deepCopyMap(_values);
    }
    if (!silent) {
      _errors = _deepCopyMap(errors);
      for (final entry in _fields.entries) {
        entry.value.fieldApi.setError(_pathGet(errors, entry.key));
      }
      _notify();
      _autoScroll();
    }
    throw _deepCopyMap(errors);
  }

  Future<Map<String, Object?>> _fieldsValidate({
    List<String>? fields,
    required bool silent,
  }) async {
    final targets = _operateFields(fields);
    final futures = <Future<void>>[];
    for (final staff in targets.values) {
      futures.add(staff.fieldApi.validate());
      if (!silent) {
        staff.fieldApi.setTouched(true);
      }
    }
    await Future.wait(futures);
    if (!silent) _notify();
    final valid = _isValid(targets.keys.toList());
    if (valid) return _deepCopyMap(_values);
    if (!silent) _autoScroll();
    throw _deepCopyMap(_errors);
  }

  bool _isValid(List<String> targets) {
    for (final field in targets) {
      final error = _pathGet(_errors, field);
      if (error != null &&
          !(error is String && error.isEmpty) &&
          !(error is List && error.isEmpty)) {
        return false;
      }
    }
    return true;
  }

  /// foundation.ts:381-416 `_getNestedField` / `_getOperateFieldMap`。
  Map<String, _FieldStaff> _operateFields(List<String>? paths) {
    if (paths == null) return Map.of(_fields);
    final out = <String, _FieldStaff>{};
    for (final path in paths) {
      final direct = _fields[path];
      if (direct != null) {
        out[path] = direct;
      } else {
        for (final entry in _fields.entries) {
          if (_isNestedField(entry.key, path)) out[entry.key] = entry.value;
        }
      }
    }
    return out;
  }

  bool _isNestedField(String field, String path) {
    final target = _toPath(path);
    final item = _toPath(field);
    if (item.length <= target.length) return false;
    for (var i = 0; i < target.length; i++) {
      if (target[i] != item[i]) return false;
    }
    return true;
  }

  /// `scrollToField(field)`（foundation.ts:822-827——Flutter
  /// Scrollable.ensureVisible 近似 `'smooth'`）。
  void scrollToField(String field) {
    final key = _fields[field]?.scrollKey;
    final ctx = key?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut, // behavior: 'smooth'
        alignment: 0, // block: 'start'
      );
    }
  }

  /// `scrollToError({field?, index?})`（foundation.ts:829-857）。
  void scrollToError({String? field, int? index}) {
    String? target;
    if (field != null) {
      target = _pathGet(_errors, field) != null ? field : null;
    } else if (index != null) {
      final errored = _errorFields();
      target = index < errored.length ? errored[index] : null;
    } else {
      final errored = _errorFields();
      target = errored.isEmpty ? null : errored.first;
    }
    if (target != null) scrollToField(target);
  }

  List<String> _errorFields() {
    final out = <String>[];
    for (final field in _fields.keys) {
      final error = _pathGet(_errors, field);
      if (error != null && !(error is String && error.isEmpty)) out.add(field);
    }
    return out;
  }

  void _autoScroll() {
    if (!_autoScrollToError) return;
    // foundation.ts:798-810（失败校验 100ms 后滚到第一个错误）。
    Future<void>.delayed(const Duration(milliseconds: 100), scrollToError);
  }
}

/// Form 作用域（baseForm.tsx Context 三件套的 Flutter 拍平）。
class _FormScope extends InheritedWidget {
  const _FormScope({
    required this.controller,
    required this.props,
    required this.version,
    required super.child,
  });

  static _FormScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_FormScope>()!;

  final SemiFormController controller;
  final _FormProps props;

  /// 状态版本（controller 通知驱动依赖方重渲染）。
  final int version;

  @override
  bool updateShouldNotify(_FormScope oldWidget) =>
      controller != oldWidget.controller ||
      props != oldWidget.props ||
      version != oldWidget.version;
}

/// Form 提供给字段的合并 props（withField.tsx:140-159 getFormProps 口径）。
class _FormProps {
  const _FormProps({
    required this.labelPosition,
    required this.labelWidth,
    required this.labelAlign,
    required this.extraTextPosition,
    required this.stopValidateWithError,
    required this.trigger,
    required this.disabled,
    required this.showValidateIcon,
    required this.layout,
    required this.allowEmpty,
  });

  final SemiFormLabelPosition labelPosition;
  final double? labelWidth;
  final TextAlign labelAlign;
  final String extraTextPosition;
  final bool stopValidateWithError;
  final SemiFormTrigger trigger;
  final bool disabled;
  final bool showValidateIcon;
  final SemiFormLayout layout;
  final bool allowEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _FormProps &&
          labelPosition == other.labelPosition &&
          labelWidth == other.labelWidth &&
          labelAlign == other.labelAlign &&
          extraTextPosition == other.extraTextPosition &&
          stopValidateWithError == other.stopValidateWithError &&
          trigger == other.trigger &&
          disabled == other.disabled &&
          showValidateIcon == other.showValidateIcon &&
          layout == other.layout &&
          allowEmpty == other.allowEmpty;

  @override
  int get hashCode => Object.hash(
    labelPosition,
    labelWidth,
    labelAlign,
    extraTextPosition,
    stopValidateWithError,
    trigger,
    disabled,
    showValidateIcon,
    layout,
    allowEmpty,
  );
}

/// InputGroup 作用域（group.tsx isInInputGroup 抑制字段 chrome）。
class _FormGroupScope extends InheritedWidget {
  const _FormGroupScope({required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_FormGroupScope>() != null;

  @override
  bool updateShouldNotify(_FormGroupScope oldWidget) => false;
}

/// ArrayField 作用域（withField.tsx:169-210 inArrayField 口径——
/// keepState 在 ArrayField 内失效）。
class _ArrayFieldScope extends InheritedWidget {
  const _ArrayFieldScope({required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ArrayFieldScope>() != null;

  @override
  bool updateShouldNotify(_ArrayFieldScope oldWidget) => false;
}

/// 表单（上游 Semi Form——baseForm.tsx + FormFoundation）。
class SemiForm extends StatefulWidget {
  const SemiForm({
    super.key,
    this.controller,
    this.initValues = const <String, Object?>{},
    this.onSubmit,
    this.onSubmitFail,
    this.onReset,
    this.onValueChange,
    this.onErrorChange,
    this.onChange,
    this.allowEmpty = false,
    this.validator,
    this.layout = SemiFormLayout.vertical,
    this.labelPosition = SemiFormLabelPosition.top, // labelPosition: 'top'
    this.labelWidth,
    this.labelAlign = TextAlign.left,
    this.extraTextPosition = 'bottom',
    this.disabled = false,
    this.showValidateIcon = true,
    this.stopValidateWithError = false,
    this.autoScrollToError = false,
    this.trigger = SemiFormTrigger.change, // DEFAULT_TRIGGER: 'change'
    this.builder,
    this.child,
  }) : assert(builder != null || child != null);

  /// 外部控制器（上游 `form`——Form.useForm() 口径；缺省内部自建）。
  final SemiFormController? controller;

  /// 初始值（上游 `initValues`；字段级 initValue 优先）。
  final Map<String, Object?> initValues;

  /// 校验通过后提交（上游 `onSubmit(values)`）。
  final ValueChanged<Map<String, Object?>>? onSubmit;

  /// 校验失败（上游 `onSubmitFail(errors, values)`）。
  final void Function(Map<String, Object?> errors, Map<String, Object?> values)?
  onSubmitFail;

  /// 重置回调（上游 `onReset`）。
  final VoidCallback? onReset;

  /// 值变化（上游 `onValueChange(values, changedValue)`）。
  final void Function(
    Map<String, Object?> values,
    Map<String, Object?> changed,
  )?
  onValueChange;

  /// 错误变化（上游 `onErrorChange(errors, changedError)`）。
  final void Function(
    Map<String, Object?> errors,
    Map<String, Object?> changed,
  )?
  onErrorChange;

  /// 状态变化（上游 `onChange(formState)`）。
  final ValueChanged<SemiFormState>? onChange;

  /// 空串保留语义（上游 `allowEmpty`——false 时空串不入 values）。
  final bool allowEmpty;

  /// 表单级校验（上游 `validator`/`validateFields`——返回错误表）。
  final SemiFormValidator? validator;

  /// 字段间距模式（上游 `layout: 'vertical' | 'horizontal'`）。
  final SemiFormLayout layout;

  /// 标签位置缺省（上游 `labelPosition: 'top' | 'left' | 'inset'`）。
  final SemiFormLabelPosition labelPosition;

  /// 标签宽度（left 布局）。
  final double? labelWidth;

  /// 标签对齐（上游 `labelAlign`）。
  final TextAlign labelAlign;

  /// extraText 位置（上游 `extraTextPosition: 'middle' | 'bottom'`）。
  final String extraTextPosition;

  /// 禁用级联（上游 `disabled`）。
  final bool disabled;

  /// 校验图标（上游 `showValidateIcon`）。
  final bool showValidateIcon;

  /// 首错即止（上游 `stopValidateWithError`——async-validator `first`）。
  final bool stopValidateWithError;

  /// 失败后滚动到错误字段（上游 `autoScrollToError`）。
  final bool autoScrollToError;

  /// 校验触发缺省（上游 `trigger`——constants.ts:15 `DEFAULT_TRIGGER: 'change'`）。
  final SemiFormTrigger trigger;

  /// 建议使用 builder（拿到 formState/formApi）。
  final Widget Function(
    BuildContext context,
    SemiFormState state,
    SemiFormController formApi,
  )?
  builder;

  /// 或直接 child（SemiFormField 注册即生效）。
  final Widget? child;

  @override
  State<SemiForm> createState() => _SemiFormState();
}

class _SemiFormState extends State<SemiForm> {
  late final SemiFormController _controller =
      widget.controller ?? SemiFormController();
  bool _bound = false;

  @override
  void initState() {
    super.initState();
    _bind();
    // foundation.ts:36-45（initValues 深拷贝起步）。
    _controller._resetData(Map.of(widget.initValues));
  }

  @override
  void didUpdateWidget(SemiForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller._unbind();
      _bound = false;
      _bind();
    }
    if (widget.initValues != oldWidget.initValues) {
      _controller._initValues = _deepCopyMap(widget.initValues);
    }
  }

  void _bind() {
    if (_bound) return;
    _bound = true;
    _controller._bind(
      notifyState: (_) {
        if (mounted) setState(() {});
      },
      notifyValueChange: (values, changed) =>
          widget.onValueChange?.call(_deepCopyMap(values), changed),
      notifyErrorChange: (errors, changed) =>
          widget.onErrorChange?.call(_deepCopyMap(errors), changed),
      notifySubmit: (values) => widget.onSubmit?.call(values),
      notifySubmitFail: (errors, values) =>
          widget.onSubmitFail?.call(errors, values),
      onChange: () => widget.onChange?.call(_controller.getFormState()),
      onReset: () => widget.onReset?.call(),
      formValidator: widget.validator,
      allowEmpty: widget.allowEmpty,
      autoScrollToError: widget.autoScrollToError,
      initValues: _deepCopyMap(widget.initValues),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null || _bound) {
      _controller._unbind();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final props = _FormProps(
      labelPosition: widget.labelPosition,
      labelWidth: widget.labelWidth,
      labelAlign: widget.labelAlign,
      extraTextPosition: widget.extraTextPosition,
      stopValidateWithError: widget.stopValidateWithError,
      trigger: widget.trigger,
      disabled: widget.disabled,
      showValidateIcon: widget.showValidateIcon,
      layout: widget.layout,
      allowEmpty: widget.allowEmpty,
    );
    final state = SemiFormState(
      values: _controller._values,
      errors: _controller._errors,
      touched: _controller._touched,
    );
    return _FormScope(
      controller: _controller,
      props: props,
      version: _controller._version,
      child: widget.builder?.call(context, state, _controller) ?? widget.child!,
    );
  }
}

/// 表单字段（上游 withField HOC——注册/校验/Label/ErrorMessage chrome）。
class SemiFormField extends StatefulWidget {
  const SemiFormField({
    super.key,
    required this.field,
    required this.builder,
    this.label,
    this.labelPosition,
    this.labelWidth,
    this.labelAlign,
    this.noLabel = false,
    this.noErrorMessage = false,
    this.initValue,
    this.rules,
    this.validator,
    this.trigger,
    this.transform,
    this.convert,
    this.allowEmpty,
    this.allowEmptyString = false,
    this.emptyValue = '',
    this.stopValidateWithError,
    this.helpText,
    this.extraText,
    this.extraTextPosition,
    this.pure = false,
    this.keepState = false,
    this.validateStatus,
    this.onBlur,
    this.labelOptional = false,
    this.labelExtra,
  });

  /// 标签「（可选）」后缀（label.tsx `optional`）。
  final bool labelOptional;

  /// 标签额外内容（label.tsx `extra`）。
  final Widget? labelExtra;

  /// 字段路径（dot/bracket：`'a.b[2]'`）。
  final String field;

  /// 控件构建。
  final SemiFormFieldBuilder builder;

  /// 标签（String | Widget；缺省显示字段路径——label.tsx `text={label || field}`）。
  final Object? label;

  /// 标签位置覆盖。
  final SemiFormLabelPosition? labelPosition;

  /// 标签宽度覆盖。
  final double? labelWidth;

  /// 标签对齐覆盖。
  final TextAlign? labelAlign;

  /// 不渲染标签。
  final bool noLabel;

  /// 不渲染错误/帮助行。
  final bool noErrorMessage;

  /// 字段初值（优先于 Form.initValues——mergeProps `initValue`）。
  final Object? initValue;

  /// 规则列表（async-validator `rules`）。
  final List<SemiFormFieldRule>? rules;

  /// 自定义校验（上游 `validator`/`validate`——空串通过）。
  final SemiFormFieldValidator? validator;

  /// 校验触发覆盖（`trigger`）。
  final SemiFormTrigger? trigger;

  /// 校验前转换（`transform`）。
  final Object? Function(Object? value)? transform;

  /// UI 更新前转换（`convert`）。
  final Object? Function(Object? value)? convert;

  /// 空值语义覆盖（`allowEmpty`）。
  final bool? allowEmpty;

  /// 空串保留（`allowEmptyString`）。
  final bool allowEmptyString;

  /// 空值判定字面量（`emptyValue`，缺省 `''`）。
  final Object? emptyValue;

  /// 首错即止覆盖（`stopValidateWithError`）。
  final bool? stopValidateWithError;

  /// 帮助文案（无错误时常显——errorMessage.tsx helpText）。
  final Widget? helpText;

  /// 额外提示（`extraText`）。
  final Widget? extraText;

  /// 额外提示位置（`extraTextPosition: middle|bottom`）。
  final String? extraTextPosition;

  /// 纯数据模式（`pure`——不渲染 Label/ErrorMessage）。
  final bool pure;

  /// 卸载保留状态（`keepState`；ArrayField 内失效 quirk）。
  final bool keepState;

  /// 校验状态覆盖（props.validateStatus 优先于本地 status）。
  final SemiFormValidateStatus? validateStatus;

  /// 失焦回调（withField `onBlur` 透传）。
  final VoidCallback? onBlur;

  /// 字段容器测试钩子。
  static Key fieldKey(String field) => ValueKey('SemiForm.field-$field');

  /// 错误行测试钩子。
  static Key errorKey(String field) => ValueKey('SemiForm.error-$field');

  @override
  State<SemiFormField> createState() => _SemiFormFieldState();
}

class _SemiFormFieldState extends State<SemiFormField> {
  late final GlobalKey _scrollKey = GlobalKey(
    debugLabel: 'SemiForm:${widget.field}',
  );
  late SemiFormController _controller;
  late _FormProps _formProps;

  Object? _value;
  Object? _error;
  bool _touched = false;
  SemiFormValidateStatus _status = SemiFormValidateStatus.normal;

  /// withField.tsx:221 `validatePromise` 竞态防护（序号 token）。
  int _validateSeq = 0;

  late Object? _initVal;
  late bool _keepState;
  late List<SemiFormTrigger> _triggers;

  bool get _required {
    final rules = widget.rules;
    if (rules == null || rules.isEmpty) return false;
    // utils.ts:59 `isRequired`（required 由 rules 派生）。
    return rules.any((r) => r.required);
  }

  bool get _allowEmpty =>
      widget.allowEmpty ?? _formProps.allowEmpty || widget.allowEmptyString;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = _FormScope.of(context);
    _controller = scope.controller;
    _formProps = scope.props;
    if (!_registered) _register();
  }

  bool _registered = false;
  late _FieldStaff _staff;

  void _register() {
    _registered = true;
    // withField.tsx:162-163（initValue 优先，其次 Form.initValues 路径值）。
    final inForm = _controller.getValue(widget.field);
    _initVal = widget.initValue ?? inForm;
    // withField.tsx:204-210（ArrayField 内 keepState 失效）。
    _keepState = widget.keepState && !_ArrayFieldScope.of(context);
    // keepState 重挂载：formState 是事实源（foundation.ts:98-143）。
    final restore =
        _keepState &&
        _controller._registered[widget.field] == true &&
        _pathHas(_controller._values, widget.field);
    // utils.ts:100-119 `transformTrigger`（field > form > DEFAULT_TRIGGER）。
    _triggers = [widget.trigger ?? _formProps.trigger];
    _value = restore ? _pathGet(_controller._values, widget.field) : _initVal;
    if (restore) {
      _error = _pathGet(_controller._errors, widget.field);
      _touched = _pathGet(_controller._touched, widget.field) == true;
    }
    _controller._registered[widget.field] = true;
    _staff = _FieldStaff(
      field: widget.field,
      fieldApi: _control,
      keepState: _keepState,
      allowEmpty: _allowEmpty,
      scrollKey: _scrollKey,
    );
    _controller._registerStaff(
      widget.field,
      _staff,
      value: _value,
      error: restore ? _error : null,
    );
    if (_triggers.contains(SemiFormTrigger.mount)) {
      // withField.tsx:533-543（mount 触发校验）。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fieldValidate();
      });
    }
  }

  @override
  void didUpdateWidget(SemiFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.field != oldWidget.field) {
      // withField.tsx:547-577（field 变更重注册）。
      _controller._unRegisterStaff(oldWidget.field, _staff);
      _registered = false;
      _register();
    }
    _initVal = widget.initValue ?? _controller.getValue(widget.field);
  }

  @override
  void dispose() {
    _validateSeq++; // 使在途校验过期
    if (_registered) _controller._unRegisterStaff(widget.field, _staff);
    super.dispose();
  }

  // -- fieldApi（withField.tsx:512-518） ------------------------------------

  late final SemiFormFieldControl _control = SemiFormFieldControl(
    field: widget.field,
    value: _value,
    error: _error,
    touched: _touched,
    validateStatus: _resolvedStatus,
    disabled: _formProps.disabled,
    required: _required,
    onChanged: _handleChange,
    onBlur: _handleBlur,
    setValue: _updateValue,
    setTouched: _updateTouched,
    setError: _updateError,
    validate: () async {
      await _fieldValidate();
    },
    reset: _reset,
  );

  SemiFormValidateStatus get _resolvedStatus =>
      widget.validateStatus ??
      // withField.tsx:588 `blockStatus = validateStatus || status`。
      _status;

  void _updateValue(Object? val, {bool notNotify = false}) {
    setState(() => _value = val);
    _controller._updateStateValue(
      widget.field,
      val,
      notNotify: notNotify,
      allowEmpty: _allowEmpty,
    );
  }

  void _updateTouched(bool t, {bool notNotify = false}) {
    setState(() => _touched = t);
    _controller._updateStateTouched(widget.field, t, notNotify: notNotify);
  }

  void _updateError(
    Object? errors, {
    bool notNotify = false,
    bool silent = false,
  }) {
    // withField.tsx:230-249（结果未变不重复更新；silent 不写 UI）。
    if (errors == _error) return;
    if (!silent) {
      setState(() {
        _error = errors;
        _status = _isError(errors)
            ? SemiFormValidateStatus.error
            : SemiFormValidateStatus.success;
      });
    }
    _controller._updateStateError(widget.field, errors, notNotify: notNotify);
  }

  bool _isError(Object? errors) {
    if (errors == null) return false;
    if (errors is String) return true; // ★`message: ''` 空串仍算错误（quirk）
    if (errors is List) return errors.isNotEmpty;
    return true;
  }

  void _reset() {
    // withField.tsx:261-271。
    _updateValue(_initVal, notNotify: true);
    _updateError(null, notNotify: true);
    _updateTouched(false, notNotify: true);
    setState(() => _status = SemiFormValidateStatus.normal);
  }

  // -- validation（withField.tsx:274-409） ---------------------------------

  /// withField.tsx:397-409 `fieldValidate`（transform 后走自定义或 rules）。
  Future<void> _fieldValidate() async {
    final seq = ++_validateSeq;
    var val = _value;
    final transform = widget.transform;
    if (transform != null) val = transform(val);
    final validator = widget.validator;
    if (validator != null) {
      await _validateCustom(val, seq);
    } else if (widget.rules != null) {
      await _validateRules(val, seq);
    }
  }

  /// withField.tsx:349-395 `_validate`（自定义 validator；过期结果丢弃）。
  Future<void> _validateCustom(Object? val, int seq) async {
    String result;
    try {
      result = await widget.validator!(val, _controller._values);
    } catch (e) {
      // 同步抛错按错误处理（上游 catch 分支）。
      result = e.toString();
    }
    if (!mounted || seq != _validateSeq) {
      // ★过期异步结果丢弃（withField.tsx:365-369 竞态 quirk 照抄）。
      return;
    }
    if (result.isEmpty) {
      _updateError(null);
    } else {
      _updateError(result);
    }
  }

  /// withField.tsx:274-346 `_validateInternal`（rules；`first:` 即
  /// stopValidateWithError）。
  Future<void> _validateRules(Object? val, int seq) async {
    final stopFirst =
        widget.stopValidateWithError ?? _formProps.stopValidateWithError;
    final messages = <String>[];
    for (final rule in widget.rules!) {
      final message = _checkRule(rule, val);
      if (message != null) {
        // ★`message: ''` 空文案仍算错误（withField.tsx:311-330 quirk）。
        messages.add(message);
        if (stopFirst) break;
      }
    }
    if (!mounted || seq != _validateSeq) return;
    if (messages.isEmpty) {
      _updateError(null);
    } else {
      _updateError(messages.length == 1 ? messages.first : messages);
    }
  }

  /// 单条规则检查（async-validator 语义子集；返回错误文案，null = 通过）。
  String? _checkRule(SemiFormFieldRule rule, Object? rawValue) {
    var value = rawValue;
    if (rule.transform != null) value = rule.transform!(value);
    final strings = SemiLocalizations.of(context);
    final label = widget.field;
    final empty =
        value == null ||
        (value is String && value.isEmpty) ||
        (value is List && value.isEmpty);
    if (rule.required && empty) {
      return rule.message ?? strings.formRequired(label);
    }
    if (empty && !rule.required) {
      // async-validator：非必填空值跳过其余检查。
      return null;
    }
    if (rule.whitespace && value is String && value.trim().isEmpty) {
      return rule.message ?? strings.formWhitespace(label);
    }
    switch (rule.type) {
      case SemiFormFieldRuleType.string:
        if (value is! String) {
          return rule.message ?? strings.formType(label, 'string');
        }
        if (rule.len != null && value.length != rule.len) {
          return rule.message ?? strings.formLength(label, rule.len!);
        }
        if (rule.min != null && value.length < rule.min!) {
          return rule.message ?? strings.formMinLength(label, rule.min!);
        }
        if (rule.max != null && value.length > rule.max!) {
          return rule.message ?? strings.formMaxLength(label, rule.max!);
        }
      case SemiFormFieldRuleType.number:
      case SemiFormFieldRuleType.integer:
        final n = value is num ? value : num.tryParse('$value');
        if (n == null) {
          return rule.message ??
              strings.formType(
                label,
                rule.type == SemiFormFieldRuleType.integer
                    ? 'integer'
                    : 'number',
              );
        }
        if (rule.type == SemiFormFieldRuleType.integer && n is! int) {
          return rule.message ?? strings.formType(label, 'integer');
        }
        if (rule.len != null && n != rule.len) {
          return rule.message ?? strings.formNumberLength(label, rule.len!);
        }
        if (rule.min != null && n < rule.min!) {
          return rule.message ?? strings.formNumberMin(label, rule.min!);
        }
        if (rule.max != null && n > rule.max!) {
          return rule.message ?? strings.formNumberMax(label, rule.max!);
        }
      case SemiFormFieldRuleType.boolean:
        if (value is! bool) {
          return rule.message ?? strings.formType(label, 'boolean');
        }
      case SemiFormFieldRuleType.array:
        if (value is! List) {
          return rule.message ?? strings.formType(label, 'array');
        }
        if (rule.len != null && value.length != rule.len) {
          return rule.message ?? strings.formLength(label, rule.len!);
        }
        if (rule.min != null && value.length < rule.min!) {
          return rule.message ?? strings.formMinLength(label, rule.min!);
        }
        if (rule.max != null && value.length > rule.max!) {
          return rule.message ?? strings.formMaxLength(label, rule.max!);
        }
      case SemiFormFieldRuleType.enum_:
        if (rule.values == null || !rule.values!.contains(value)) {
          return rule.message ??
              strings.formEnum(label, '${rule.values ?? const []}');
        }
      case SemiFormFieldRuleType.url:
        if (!_FormMetrics.urlRegex.hasMatch('$value')) {
          return rule.message ?? strings.formType(label, 'url');
        }
      case SemiFormFieldRuleType.email:
        if (!_FormMetrics.emailRegex.hasMatch('$value')) {
          return rule.message ?? strings.formType(label, 'email');
        }
      case SemiFormFieldRuleType.regexp:
        if (rule.pattern == null || !rule.pattern!.hasMatch('$value')) {
          return rule.message ?? strings.formPattern(label);
        }
      case SemiFormFieldRuleType.any:
        break;
    }
    if (rule.pattern != null &&
        rule.type != SemiFormFieldRuleType.regexp &&
        !rule.pattern!.hasMatch('$value')) {
      return rule.message ?? strings.formPattern(label);
    }
    return null;
  }

  // -- handlers（withField.tsx:416-508） -----------------------------------

  /// withField.tsx:416-495 `handleChange`（convert/空值语义/touched/提交/
  /// change 校验——两阶段提交简化为顺序提交，见 docs 差异清单）。
  void _handleChange(Object? raw) {
    var val = raw;
    final convert = widget.convert;
    if (convert != null) val = convert(val);
    if (!(_allowEmpty || widget.allowEmptyString)) {
      // withField.tsx:437-447（emptyValue 归一为 undefined）。
      if (val == (widget.emptyValue ?? '')) val = null;
    }
    _updateValue(val);
    _updateTouched(true);
    if (_triggers.contains(SemiFormTrigger.change)) {
      _fieldValidate();
    }
  }

  /// withField.tsx:497-508 `handleBlur`。
  void _handleBlur() {
    widget.onBlur?.call();
    if (!_touched) _updateTouched(true);
    if (_triggers.contains(SemiFormTrigger.blur)) {
      _fieldValidate();
    }
  }

  // -- build（withField.tsx:586-738 chrome） --------------------------------

  @override
  Widget build(BuildContext context) {
    final scope = _FormScope.of(context);
    final theme = SemiFormTheme.resolve(context);
    final inGroup = _FormGroupScope.of(context);
    final labelPos = widget.labelPosition ?? _formProps.labelPosition;
    final control = SemiFormFieldControl(
      field: widget.field,
      insetLabel:
          (labelPos == SemiFormLabelPosition.top ||
              labelPos == SemiFormLabelPosition.left ||
              widget.noLabel)
          ? null
          : (widget.label ?? widget.field),
      value: _value,
      error: _error,
      touched: _touched,
      validateStatus: _resolvedStatus,
      disabled: scope.props.disabled,
      required: _required,
      onChanged: _handleChange,
      onBlur: _handleBlur,
      setValue: _updateValue,
      setTouched: _updateTouched,
      setError: _updateError,
      validate: () async {
        await _fieldValidate();
      },
      reset: _reset,
    );
    final child = Builder(
      builder: (context) => widget.builder(context, control),
    );

    // withField.tsx:649-651（InputGroup 内不渲染 chrome）。
    if (inGroup || widget.pure) {
      return child;
    }
    return _buildChrome(context, theme, scope.props, child);
  }

  Widget _buildChrome(
    BuildContext context,
    SemiResolvedFormThemeData theme,
    _FormProps formProps,
    Widget child,
  ) {
    final labelPos = widget.labelPosition ?? formProps.labelPosition;
    final labelWidth = widget.labelWidth ?? formProps.labelWidth;
    final labelAlign = widget.labelAlign ?? formProps.labelAlign;
    final extraPos = widget.extraTextPosition ?? formProps.extraTextPosition;

    // withField.tsx:637-644（inset 时标签注入控件 insetLabel，无独立 Label）。
    final labelTop = (!widget.noLabel && labelPos == SemiFormLabelPosition.top)
        ? _buildLabel(theme, labelWidth, labelAlign, top: true)
        : null;
    final labelLeft =
        (!widget.noLabel && labelPos == SemiFormLabelPosition.left)
        ? _buildLabel(theme, labelWidth, labelAlign)
        : null;

    final extra = widget.extraText == null
        ? null
        : Padding(
            // form.scss `-field-extra`（middle/bottom 位置间距）。
            padding: EdgeInsetsDirectional.only(
              top: extraPos == 'middle'
                  ? theme.spacingFormExtraPosMidMarginTop
                  : theme.spacingFormExtraPosBottomMarginTop,
              bottom: extraPos == 'middle'
                  ? theme.spacingFormExtraPosMidMarginBottom
                  : 0,
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: theme.colorFormLabelExtraTextDefault,
                fontSize: _FormMetrics.fontSizeRegular,
              ),
              child: widget.extraText!,
            ),
          );

    final main = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (extraPos == 'middle') extra ?? const SizedBox.shrink(),
        child,
        if (!widget.noErrorMessage) _buildErrorMessage(theme, formProps),
        if (extraPos == 'bottom') extra ?? const SizedBox.shrink(),
      ],
    );

    final inner = labelLeft != null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                // form.scss `-field-label_posLeft` margin。
                padding: EdgeInsetsDirectional.only(
                  end: theme.spacingFormLabelPosLeftMarginRight,
                  bottom: theme.spacingFormLabelPosLeftMarginBottom,
                ),
                child: labelLeft,
              ),
              Expanded(child: main),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [?labelTop, main],
          );

    // form.scss:23-50（layout 决定字段间距；group_* 变体由 SemiFormGroup 用）。
    final pad = formProps.layout == SemiFormLayout.horizontal
        ? EdgeInsetsDirectional.only(
            end: theme.spacingFormFieldHorizontalPaddingRight,
          )
        : EdgeInsets.only(
            top: theme.spacingFormFieldVerticalPaddingTop,
            bottom: theme.spacingFormFieldVerticalPaddingBottom,
          );
    return Container(key: _scrollKey, padding: pad, child: inner);
  }

  /// label.tsx（required `*` / optional「（可选）」/ extra / width / align）。
  Widget _buildLabel(
    SemiResolvedFormThemeData theme,
    double? width,
    TextAlign align, {
    bool top = false,
  }) {
    final disabled = _formProps.disabled;
    final requiredMark = Text(
      '*',
      style: TextStyle(
        // form.scss:122 `content: "*"`（margin-left + requiredMark 色/字重）。
        color: disabled
            ? theme.colorFormRequiredMarkDisabledTextDefault
            : theme.colorFormRequiredMarkTextDefault,
        fontWeight: theme.fontFormRequiredMarkFontWeight,
      ),
    );
    final text = widget.label is Widget
        ? widget.label! as Widget
        : Text(
            widget.label is String ? widget.label! as String : widget.field,
            style: TextStyle(
              color: disabled
                  ? theme.colorFormLabelDisabledTextDefault
                  : theme.colorFormLabelTextDefault,
              fontWeight: theme.fontFormLabelFontWeight,
            ),
          );
    return SizedBox(
      width: width,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          // form.scss:96-106 label padding/margin；posTop 用
          // `label_posTop` 变量（form.scss:18-19）。
          top:
              (top
                  ? theme.spacingFormLabelPosTopPaddingTop
                  : theme.spacingFormLabelPaddingTop) +
              theme.spacingFormLabelMarginTop,
          end: theme.spacingFormLabelPaddingRight,
          bottom: top
              ? theme.spacingFormLabelPosTopPaddingBottom
              : theme.spacingFormLabelMarginBottom,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: align == TextAlign.right
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: text),
                  if (_required)
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: theme.spacingFormLabelRequiredMarginLeft,
                      ),
                      child: requiredMark,
                    ),
                  if (widget.labelOptional)
                    Padding(
                      // label.tsx:68-74 optionalText（label_optional 色）。
                      padding: EdgeInsetsDirectional.only(
                        start: theme.spacingFormLabelExtraMarginLeft,
                      ),
                      child: Text(
                        SemiLocalizations.of(context).optional,
                        style: TextStyle(
                          color: theme.colorFormLabelOptionalTextDefault,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (widget.labelExtra != null)
              Padding(
                // form.scss:113-117 `-label-extra`（margin-left + extra 色）。
                padding: EdgeInsetsDirectional.only(
                  start: theme.spacingFormLabelExtraMarginLeft,
                ),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: theme.colorFormLabelExtraTextDefault),
                  child: widget.labelExtra!,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// errorMessage.tsx（error/helpText + 状态图标 + `message: ''` quirk）。
  Widget _buildErrorMessage(
    SemiResolvedFormThemeData theme,
    _FormProps formProps,
  ) {
    final error = _error;
    // errorMessage.tsx:74-76（空串错误 + error 态 → 整行不渲染）。
    if (error == '' && _resolvedStatus == SemiFormValidateStatus.error) {
      return const SizedBox.shrink();
    }
    final hasError = _isError(error);
    if (!hasError && widget.helpText == null) {
      return const SizedBox.shrink();
    }
    String? text;
    if (hasError) {
      if (error is List) {
        final filtered = [
          for (final e in error)
            if (e != null) '$e',
        ];
        text = filtered.isEmpty ? null : filtered.join(', ');
      } else {
        text = '$error';
      }
    } else {
      text = null;
    }
    final status = _resolvedStatus;
    Widget? icon;
    if (formProps.showValidateIcon &&
        (text != null || widget.helpText != null)) {
      // errorMessage.tsx:77-98（warning=alertTriangle / error=alertCircle）。
      final iconData = switch (status) {
        SemiFormValidateStatus.warning => SemiIcons.alertTriangle,
        SemiFormValidateStatus.error => SemiIcons.alertCircle,
        _ => null,
      };
      if (iconData != null) {
        icon = Padding(
          padding: EdgeInsetsDirectional.only(
            end: theme.spacingFormStatusIconMarginRight,
          ),
          child: SemiIconTheme(
            data: SemiIconThemeData(
              color: status == SemiFormValidateStatus.warning
                  // form.scss:145-147 `-icon-alert_triangle` 色。
                  ? theme.colorFormAlertIconIconDefault
                  : theme.colorFormMessageErrorTextDefault,
              customSize: _FormMetrics.fontSizeRegular,
            ),
            child: SemiIcon(iconData),
          ),
        );
      }
    }
    return Container(
      key: SemiFormField.errorKey(widget.field),
      // form.scss:139-151（`margin-top` + font-size-regular）。
      margin: EdgeInsetsDirectional.only(
        top: theme.spacingFormMessageMarginTop,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ?icon,
          Flexible(
            child: text != null
                ? Text(
                    text,
                    style: TextStyle(
                      color: theme.colorFormMessageErrorTextDefault,
                      fontSize: _FormMetrics.fontSizeRegular,
                    ),
                  )
                : widget.helpText!,
          ),
        ],
      ),
    );
  }
}

/// 动态字段列表（上游 `Form.ArrayField`——arrayField.tsx + foundation
/// `registerArrayField`/`updateKey` 重挂载语义）。
class SemiArrayField extends StatefulWidget {
  const SemiArrayField({
    super.key,
    this.field,
    this.initValue,
    required this.builder,
  });

  /// 基础路径（`'people'`——行路径 `people[i]`；null 时本地管理不接 Form）。
  final String? field;

  /// 列表初值（`initValue`）。
  final List<Object?>? initValue;

  /// 行构建。
  final SemiArrayFieldBuilder builder;

  @override
  State<SemiArrayField> createState() => _SemiArrayFieldState();
}

class _SemiArrayFieldState extends State<SemiArrayField> {
  late SemiFormController _controller;
  bool _registered = false;

  /// getUuidv4 等效的稳定行 key。
  int _keySeq = 0;
  final List<String> _rowKeys = <String>[];
  int _seenUpdateKey = -1;
  int _mountSeq = 0;
  final ValueNotifier<int> _arrayVersion = ValueNotifier<int>(0);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = _FormScope.of(context);
    _controller = scope.controller;
    if (!_registered) {
      _registered = true;
      if (widget.field != null) {
        // foundation.ts:191-197 `registerArrayField`（initValue + updateKey）。
        _controller._arrayFields[widget.field!] = _ArrayFieldStaff(
          initValue: _listCopy(widget.initValue) ?? <Object?>[],
        );
        // 行字段的值源：initValue 播种进 values（仅缺失时）。
        if (!_pathHas(_controller._values, widget.field!)) {
          _controller._updateStateValue(
            widget.field!,
            _listCopy(widget.initValue) ?? <Object?>[],
            notNotify: true,
          );
        }
        _syncFromValues();
      } else {
        _rowKeys.addAll([
          for (final _ in widget.initValue ?? const <Object?>[])
            'array-${_keySeq++}',
        ]);
      }
    } else {
      _maybeResync();
    }
  }

  void _maybeResync() {
    final base = widget.field;
    if (base == null) return;
    final updateKey = _controller._arrayFields[base]?.updateKey ?? -1;
    if (updateKey != _seenUpdateKey) {
      _seenUpdateKey = updateKey;
      _mountSeq++; // updateKey 重挂载语义
      _syncFromValues();
      _arrayVersion.value++;
    }
  }

  void _syncFromValues() {
    final base = widget.field;
    final list = base == null
        ? null
        : _controller.getValue(base) as List<Object?>?;
    final rows =
        list ??
        _listCopy(_controller._arrayFields[base]?.initValue) ??
        <Object?>[];
    _rowKeys
      ..clear()
      ..addAll([for (final _ in rows) 'array-${_keySeq++}']);
  }

  List<Object?>? _listCopy(Object? src) =>
      src is List ? [for (final e in src) _controller._deepCopyValue(e)] : null;

  List<Object?> _currentList() {
    final base = widget.field;
    if (base == null) {
      return [for (final _ in _rowKeys) null];
    }
    final list = _controller.getValue(base) as List<Object?>?;
    return list == null ? <Object?>[] : [for (final e in list) e];
  }

  void _writeList(List<Object?> next) {
    final base = widget.field;
    if (base == null) return;
    _controller.setValue(base, next);
  }

  void _add([int? index, Object? value]) {
    final list = _currentList();
    final i = index == null ? list.length : index.clamp(0, list.length);
    list.insert(i, value);
    _rowKeys.insert(i, 'array-${_keySeq++}');
    _writeList(list);
    _mountSeq++; // updateKey 重挂载语义
    setState(() {});
    _arrayVersion.value++;
  }

  void _remove(int index) {
    final list = _currentList();
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    _rowKeys.removeAt(index);
    _writeList(list);
    _mountSeq++; // updateKey 重挂载语义
    setState(() {});
    _arrayVersion.value++;
  }

  @override
  void dispose() {
    final base = widget.field;
    if (base != null) {
      // foundation.ts:200-205 `unRegisterArrayField`。
      _controller._arrayFields.remove(base);
    }
    _arrayVersion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.field;
    return _ArrayFieldScope(
      child: ValueListenableBuilder<int>(
        valueListenable: _arrayVersion,
        builder: (context, _, _) {
          final items = <SemiArrayFieldItem>[
            for (final (i, key) in _rowKeys.indexed)
              SemiArrayFieldItem(
                key: key,
                field: base == null ? '[$i]' : '$base[$i]',
                remove: () => _remove(i),
              ),
          ];
          // getUuidv4 重挂载语义：结构变化后整树 remount（行字段按 values
          // 重新注册——路径位移不串态）。
          return KeyedSubtree(
            key: ValueKey('SemiArrayField-${widget.field}-$_mountSeq'),
            child: widget.builder(
              context,
              SemiArrayFieldApi(
                items: items,
                add: ([index]) => _add(index),
                addWithInitValue: (value, [index]) => _add(index, value),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 表单分组（上游 `Form.InputGroup` 轻量——共享 Label + fieldSet 聚合错误；
/// 组内字段 chrome 被抑制）。
class SemiFormGroup extends StatefulWidget {
  const SemiFormGroup({
    super.key,
    required this.fieldSet,
    required this.child,
    this.label,
    this.labelPosition,
    this.labelWidth,
    this.labelAlign,
    this.extraText,
    this.extraTextPosition,
  });

  /// 聚合错误的字段路径（group.tsx `fieldSet`）。
  final List<String> fieldSet;

  /// 共享标签。
  final Object? label;

  /// 标签位置覆盖。
  final SemiFormLabelPosition? labelPosition;

  /// 标签宽度覆盖。
  final double? labelWidth;

  /// 标签对齐覆盖。
  final TextAlign? labelAlign;

  /// 额外提示。
  final Widget? extraText;

  /// 额外提示位置。
  final String? extraTextPosition;

  /// 组内容（内部 SemiFormField 自动抑制 chrome）。
  final Widget child;

  @override
  State<SemiFormGroup> createState() => _SemiFormGroupState();
}

class _SemiFormGroupState extends State<SemiFormGroup> {
  @override
  Widget build(BuildContext context) {
    final scope = _FormScope.of(context);
    final theme = SemiFormTheme.resolve(context);
    final props = scope.props;
    final labelPos = widget.labelPosition ?? props.labelPosition;
    final extraPos = widget.extraTextPosition ?? props.extraTextPosition;

    // group.tsx GroupError（fieldSet 聚合——首个错误）。
    String? errorText;
    for (final field in widget.fieldSet) {
      final e = scope.controller.getError(field);
      if (e != null && !(e is String && e.isEmpty)) {
        errorText = e is List ? e.join(', ') : '$e';
        break;
      }
    }

    final label = widget.label == null
        ? null
        : Padding(
            padding: EdgeInsetsDirectional.only(
              top: theme.spacingFormLabelPaddingTop,
              end: theme.spacingFormLabelPaddingRight,
              bottom: theme.spacingFormLabelMarginBottom,
            ),
            child: widget.label is Widget
                ? widget.label! as Widget
                : Text(
                    widget.label! as String,
                    style: TextStyle(
                      color: props.disabled
                          ? theme.colorFormLabelDisabledTextDefault
                          : theme.colorFormLabelTextDefault,
                      fontWeight: theme.fontFormLabelFontWeight,
                    ),
                  ),
          );

    final main = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _FormGroupScope(child: widget.child),
        if (errorText != null)
          Container(
            margin: EdgeInsetsDirectional.only(
              top: theme.spacingFormMessageMarginTop,
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: theme.spacingFormStatusIconMarginRight,
                  ),
                  child: SemiIconTheme(
                    data: SemiIconThemeData(
                      color: theme.colorFormAlertIconIconDefault,
                      customSize: _FormMetrics.fontSizeRegular,
                    ),
                    // errorMessage.tsx:93（group 内图标恒 alertCircle）。
                    child: const SemiIcon(SemiIcons.alertCircle),
                  ),
                ),
                Flexible(
                  child: Text(
                    errorText,
                    style: TextStyle(
                      color: theme.colorFormMessageErrorTextDefault,
                      fontSize: _FormMetrics.fontSizeRegular,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (widget.extraText != null && extraPos == 'bottom')
          Padding(
            padding: EdgeInsetsDirectional.only(
              top: theme.spacingFormExtraPosBottomMarginTop,
            ),
            child: widget.extraText!,
          ),
      ],
    );

    // form.scss:23-50 group 间距变体。
    final pad = props.layout == SemiFormLayout.horizontal
        ? EdgeInsetsDirectional.only(
            end: theme.spacingFormFieldGroupHorizontalPaddingRight,
          )
        : EdgeInsets.only(
            top: theme.spacingFormFieldGroupVerticalPaddingTop,
            bottom: theme.spacingFormFieldGroupVerticalPaddingBottom,
          );
    return Padding(
      padding: pad,
      child: labelPos == SemiFormLabelPosition.left && label != null
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: theme.spacingFormLabelPosLeftMarginRight,
                    bottom: theme.spacingFormLabelPosLeftMarginBottom,
                  ),
                  child: SizedBox(
                    width: widget.labelWidth ?? props.labelWidth,
                    child: label,
                  ),
                ),
                Expanded(child: main),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [?label, main],
            ),
    );
  }
}

/// 标签/错误槽（上游 `Form.Slot`——无字段绑定）。
class SemiFormSlot extends StatelessWidget {
  const SemiFormSlot({
    super.key,
    required this.child,
    this.label,
    this.noLabel = false,
    this.labelPosition,
    this.error,
  });

  /// 内容。
  final Widget child;

  /// 标签。
  final Object? label;

  /// 不渲染标签。
  final bool noLabel;

  /// 标签位置（slot.tsx `labelPosition('top'|'left')`）。
  final SemiFormLabelPosition? labelPosition;

  /// 错误内容（slot.tsx `error: ErrorMessageProps`）。
  final Widget? error;

  @override
  Widget build(BuildContext context) {
    final scope = _FormScope.of(context);
    final theme = SemiFormTheme.resolve(context);
    final pos = labelPosition ?? scope.props.labelPosition;
    final labelWidget = (noLabel || label == null)
        ? null
        : Text(
            label is Widget ? '' : '$label',
            style: TextStyle(
              color: scope.props.disabled
                  ? theme.colorFormLabelDisabledTextDefault
                  : theme.colorFormLabelTextDefault,
              fontWeight: theme.fontFormLabelFontWeight,
            ),
          );
    final main = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        if (error != null)
          Padding(
            padding: EdgeInsetsDirectional.only(
              top: theme.spacingFormMessageMarginTop,
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: theme.colorFormMessageErrorTextDefault,
                fontSize: _FormMetrics.fontSizeRegular,
              ),
              child: error!,
            ),
          ),
      ],
    );
    return pos == SemiFormLabelPosition.left
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (labelWidget != null)
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: theme.spacingFormLabelPosLeftMarginRight,
                    bottom: theme.spacingFormLabelPosLeftMarginBottom,
                  ),
                  child: labelWidget,
                ),
              Expanded(child: main),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [?labelWidget, main],
          );
  }
}

/// 表单分组标题（上游 `Form.Section`——section.tsx + form.scss section 块）。
class SemiFormSection extends StatelessWidget {
  const SemiFormSection({super.key, required this.title, required this.child});

  /// 分组标题。
  final String title;

  /// 分组内容。
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final global = SemiTheme.of(context);
    final theme = SemiFormTheme.resolve(context);
    return Padding(
      padding: EdgeInsetsDirectional.only(
        // form.scss `-section` `margin-top`。
        top: theme.spacingFormSectionMarginTop,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsetsDirectional.only(
              // form.scss `-section_text` padding/margin。
              top: theme.spacingFormSectionTextPaddingTop,
              bottom: theme.spacingFormSectionTextPaddingBottom,
            ),
            margin: EdgeInsetsDirectional.only(
              bottom: theme.spacingFormSectionTextMarginBottom,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  // form.scss `-section` border（width + color）。
                  width: theme.widthFormSectionBorder,
                  color: theme.colorFormSectionBorderDefault,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                top: theme.spacingFormSectionTextMarginTop,
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: theme.colorFormSectionTextDefault,
                  // form.scss:303 `@include font-size-header-5`（18）。
                  fontSize: _FormMetrics.sectionTitleFontSize,
                  fontWeight: global.typography.fontWeightBold,
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

// -- 便捷包装（上游 field.tsx `Form.Input` 系列；值形态适配） ----------------

/// `Form.Input`（值 String）。
class SemiFormInput extends StatelessWidget {
  const SemiFormInput({
    super.key,
    required this.field,
    this.label,
    this.rules,
    this.validator,
    this.trigger,
    this.placeholder,
    this.size = SemiInputSize.normal,
    this.onChanged,
    this.onBlur,
    this.helpText,
    this.extraText,
    this.initValue,
    this.labelOptional = false,
    this.labelExtra,
    this.labelPosition,
    this.labelWidth,
    this.labelAlign,
    this.disabled = false,
    this.builder,
    this.transform,
    this.convert,
    this.allowEmpty,
    this.allowEmptyString = false,
    this.stopValidateWithError,
    this.keepState = false,
    this.noLabel = false,
    this.noErrorMessage = false,
  });

  /// 字段路径。
  final String field;

  /// 校验前转换（`transform`）。
  final Object? Function(Object? value)? transform;

  /// UI 更新前转换（`convert`）。
  final Object? Function(Object? value)? convert;

  /// 空值语义覆盖（`allowEmpty`）。
  final bool? allowEmpty;

  /// 空串保留（`allowEmptyString`）。
  final bool allowEmptyString;

  /// 首错即止覆盖（`stopValidateWithError`）。
  final bool? stopValidateWithError;

  /// 卸载保留状态（`keepState`）。
  final bool keepState;

  /// 不渲染标签。
  final bool noLabel;

  /// 不渲染错误/帮助行。
  final bool noErrorMessage;

  /// 标签。
  final Object? label;

  /// 规则。
  final List<SemiFormFieldRule>? rules;

  /// 自定义校验。
  final SemiFormFieldValidator? validator;

  /// 校验触发。
  final SemiFormTrigger? trigger;

  /// 占位。
  final String? placeholder;

  /// 尺寸。
  final SemiInputSize size;

  /// 用户 onChange。
  final ValueChanged<String>? onChanged;

  /// 用户 onBlur。
  final VoidCallback? onBlur;

  /// 帮助文案。
  final Widget? helpText;

  /// 额外提示。
  final Widget? extraText;

  /// 字段初值。
  final Object? initValue;

  /// 标签「（可选）」后缀（label.tsx `optional`）。
  final bool labelOptional;

  /// 标签额外内容（label.tsx `extra`）。
  final Widget? labelExtra;

  /// 标签位置/宽度/对齐覆盖。
  final SemiFormLabelPosition? labelPosition;
  final double? labelWidth;
  final TextAlign? labelAlign;

  /// 本地禁用（叠加 Form.disabled）。
  final bool disabled;

  /// 追加定制（拿到 control 后包装输入）。
  final Widget Function(
    BuildContext context,
    SemiFormFieldControl control,
    Widget input,
  )?
  builder;

  @override
  Widget build(BuildContext context) {
    return SemiFormField(
      field: field,
      label: label,
      rules: rules,
      validator: validator,
      trigger: trigger,
      initValue: initValue,
      helpText: helpText,
      extraText: extraText,
      labelOptional: labelOptional,
      labelExtra: labelExtra,
      labelPosition: labelPosition,
      labelWidth: labelWidth,
      labelAlign: labelAlign,
      transform: transform,
      convert: convert,
      allowEmpty: allowEmpty,
      allowEmptyString: allowEmptyString,
      stopValidateWithError: stopValidateWithError,
      keepState: keepState,
      noLabel: noLabel,
      noErrorMessage: noErrorMessage,
      builder: (context, control) {
        final input = SemiInput(
          value: control.value as String?,
          disabled: disabled || control.disabled,
          placeholder: placeholder,
          size: size,
          // withField.tsx:637-644（labelPosition: inset 注入 insetLabel）。
          insetLabel: control.insetLabel is String
              ? control.insetLabel! as String
              : null,
          validateStatus: _statusOf(control),
          onChanged: (v) {
            onChanged?.call(v);
            control.onChanged(v);
          },
          onBlur: () {
            onBlur?.call();
            control.onBlur();
          },
        );
        return builder?.call(context, control, input) ?? input;
      },
    );
  }
}

/// `Form.TextArea`（值 String）。
class SemiFormTextArea extends StatelessWidget {
  const SemiFormTextArea({
    super.key,
    required this.field,
    this.label,
    this.rules,
    this.validator,
    this.trigger,
    this.placeholder,
    this.rows = 4,
    this.minRows,
    this.maxRows,
    this.onChanged,
    this.onBlur,
    this.helpText,
    this.extraText,
    this.initValue,
    this.labelOptional = false,
    this.labelExtra,
    this.labelPosition,
    this.labelWidth,
    this.labelAlign,
    this.disabled = false,
  });

  final String field;
  final Object? label;
  final List<SemiFormFieldRule>? rules;
  final SemiFormFieldValidator? validator;
  final SemiFormTrigger? trigger;
  final String? placeholder;
  final int rows;
  final int? minRows;
  final int? maxRows;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onBlur;
  final Widget? helpText;
  final Widget? extraText;
  final Object? initValue;
  final bool labelOptional;
  final Widget? labelExtra;
  final SemiFormLabelPosition? labelPosition;
  final double? labelWidth;
  final TextAlign? labelAlign;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return SemiFormField(
      field: field,
      label: label,
      rules: rules,
      validator: validator,
      trigger: trigger,
      initValue: initValue,
      helpText: helpText,
      extraText: extraText,
      labelOptional: labelOptional,
      labelExtra: labelExtra,
      labelPosition: labelPosition,
      labelWidth: labelWidth,
      labelAlign: labelAlign,
      builder: (context, control) => SemiTextArea(
        value: control.value as String?,
        disabled: disabled || control.disabled,
        placeholder: placeholder,
        rows: rows,
        autosize: (minRows == null && maxRows == null)
            ? null
            : SemiTextAreaAutosize(minRows: minRows, maxRows: maxRows),
        validateStatus: _statusOf(control),
        onChanged: (v) {
          onChanged?.call(v);
          control.onChanged(v);
        },
        onFocusChange: (focused) {
          if (!focused) {
            onBlur?.call();
            control.onBlur();
          }
        },
      ),
    );
  }
}

/// `Form.Select`（值 Object?/List）。
class SemiFormSelect extends StatelessWidget {
  const SemiFormSelect({
    super.key,
    required this.field,
    required this.options,
    this.label,
    this.rules,
    this.validator,
    this.trigger,
    this.placeholder,
    this.multiple = false,
    this.onChanged,
    this.onBlur,
    this.helpText,
    this.extraText,
    this.initValue,
    this.labelOptional = false,
    this.labelExtra,
    this.labelPosition,
    this.labelWidth,
    this.labelAlign,
    this.disabled = false,
  });

  final String field;

  /// 选项数据。
  final List<SemiSelectOption> options;
  final Object? label;
  final List<SemiFormFieldRule>? rules;
  final SemiFormFieldValidator? validator;
  final SemiFormTrigger? trigger;
  final String? placeholder;
  final bool multiple;
  final ValueChanged<Object?>? onChanged;
  final VoidCallback? onBlur;
  final Widget? helpText;
  final Widget? extraText;
  final Object? initValue;
  final bool labelOptional;
  final Widget? labelExtra;
  final SemiFormLabelPosition? labelPosition;
  final double? labelWidth;
  final TextAlign? labelAlign;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return SemiFormField(
      field: field,
      label: label,
      rules: rules,
      validator: validator,
      trigger: trigger,
      initValue: initValue,
      helpText: helpText,
      extraText: extraText,
      labelOptional: labelOptional,
      labelExtra: labelExtra,
      labelPosition: labelPosition,
      labelWidth: labelWidth,
      labelAlign: labelAlign,
      builder: (context, control) => SemiSelect(
        options: options,
        value: control.value,
        multiple: multiple,
        disabled: disabled || control.disabled,
        placeholder: placeholder,
        validateStatus: _statusOf(control),
        onChanged: (v) {
          onChanged?.call(v);
          control.onChanged(v);
        },
        onBlur: () {
          onBlur?.call();
          control.onBlur();
        },
      ),
    );
  }
}

/// `Form.Checkbox`（值 bool——checked 形态适配）。
class SemiFormCheckbox extends StatelessWidget {
  const SemiFormCheckbox({
    super.key,
    required this.field,
    this.label,
    this.labelOptional = false,
    this.labelExtra,
    this.labelPosition,
    this.labelWidth,
    this.labelAlign,
    this.rules,
    this.validator,
    this.trigger,
    this.checkboxLabel,
    this.onChanged,
    this.onBlur,
    this.helpText,
    this.extraText,
    this.initValue,
    this.disabled = false,
  });

  final String field;
  final Object? label;
  final bool labelOptional;
  final Widget? labelExtra;
  final SemiFormLabelPosition? labelPosition;
  final double? labelWidth;
  final TextAlign? labelAlign;
  final List<SemiFormFieldRule>? rules;
  final SemiFormFieldValidator? validator;
  final SemiFormTrigger? trigger;

  /// 勾选项文案。
  final Object? checkboxLabel;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onBlur;
  final Widget? helpText;
  final Widget? extraText;
  final Object? initValue;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return SemiFormField(
      field: field,
      label: label,
      rules: rules,
      validator: validator,
      trigger: trigger,
      initValue: initValue,
      helpText: helpText,
      extraText: extraText,
      labelOptional: labelOptional,
      labelExtra: labelExtra,
      labelPosition: labelPosition,
      labelWidth: labelWidth,
      labelAlign: labelAlign,
      builder: (context, control) => SemiCheckbox(
        label: checkboxLabel,
        checked: control.value == true,
        disabled: disabled || control.disabled,
        onChanged: (e) {
          final v = e.checked == true;
          onChanged?.call(v);
          control.onChanged(v);
        },
      ),
    );
  }
}

/// `Form.Switch`（值 bool——checked 形态适配）。
class SemiFormSwitch extends StatelessWidget {
  const SemiFormSwitch({
    super.key,
    required this.field,
    this.label,
    this.labelOptional = false,
    this.labelExtra,
    this.labelPosition,
    this.labelWidth,
    this.labelAlign,
    this.rules,
    this.validator,
    this.trigger,
    this.onChanged,
    this.onBlur,
    this.helpText,
    this.extraText,
    this.initValue,
    this.disabled = false,
  });

  final String field;
  final Object? label;
  final bool labelOptional;
  final Widget? labelExtra;
  final SemiFormLabelPosition? labelPosition;
  final double? labelWidth;
  final TextAlign? labelAlign;
  final List<SemiFormFieldRule>? rules;
  final SemiFormFieldValidator? validator;
  final SemiFormTrigger? trigger;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onBlur;
  final Widget? helpText;
  final Widget? extraText;
  final Object? initValue;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final theme = SemiFormTheme.resolve(context);
    return SemiFormField(
      field: field,
      label: label,
      rules: rules,
      validator: validator,
      trigger: trigger,
      initValue: initValue,
      helpText: helpText,
      extraText: extraText,
      labelOptional: labelOptional,
      labelExtra: labelExtra,
      labelPosition: labelPosition,
      labelWidth: labelWidth,
      labelAlign: labelAlign,
      builder: (context, control) => Padding(
        // form.scss:26 `spacing-form_switch_rating_marginY`（Switch/Rating
        // 高度对齐 margin——水平布局）。
        padding: EdgeInsets.symmetric(
          vertical: theme.spacingFormSwitchRatingMarginY,
        ),
        child: SemiSwitch(
          checked: control.value == true,
          disabled: disabled || control.disabled,
          onChanged: (v) {
            onChanged?.call(v);
            control.onChanged(v);
          },
        ),
      ),
    );
  }
}

/// `Form.RadioGroup`（值 Object?）。
class SemiFormRadioGroup extends StatelessWidget {
  const SemiFormRadioGroup({
    super.key,
    required this.field,
    required this.options,
    this.label,
    this.labelOptional = false,
    this.labelExtra,
    this.labelPosition,
    this.labelWidth,
    this.labelAlign,
    this.rules,
    this.validator,
    this.trigger,
    this.onChanged,
    this.onBlur,
    this.helpText,
    this.extraText,
    this.initValue,
    this.disabled = false,
  });

  final String field;
  final List<SemiRadioOption> options;
  final Object? label;
  final bool labelOptional;
  final Widget? labelExtra;
  final SemiFormLabelPosition? labelPosition;
  final double? labelWidth;
  final TextAlign? labelAlign;
  final List<SemiFormFieldRule>? rules;
  final SemiFormFieldValidator? validator;
  final SemiFormTrigger? trigger;
  final ValueChanged<Object?>? onChanged;
  final VoidCallback? onBlur;
  final Widget? helpText;
  final Widget? extraText;
  final Object? initValue;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return SemiFormField(
      field: field,
      label: label,
      rules: rules,
      validator: validator,
      trigger: trigger,
      initValue: initValue,
      helpText: helpText,
      extraText: extraText,
      labelOptional: labelOptional,
      labelExtra: labelExtra,
      labelPosition: labelPosition,
      labelWidth: labelWidth,
      labelAlign: labelAlign,
      builder: (context, control) => SemiRadioGroup(
        options: options,
        value: control.value,
        disabled: disabled || control.disabled,
        onChanged: (v) {
          onChanged?.call(v);
          control.onChanged(v);
        },
      ),
    );
  }
}

/// `Form.InputNumber`（值 num?）。
class SemiFormInputNumber extends StatelessWidget {
  const SemiFormInputNumber({
    super.key,
    required this.field,
    this.label,
    this.labelOptional = false,
    this.labelExtra,
    this.labelPosition,
    this.labelWidth,
    this.labelAlign,
    this.rules,
    this.validator,
    this.trigger,
    this.min,
    this.max,
    this.step,
    this.onChanged,
    this.onBlur,
    this.helpText,
    this.extraText,
    this.initValue,
    this.disabled = false,
  });

  final String field;
  final Object? label;
  final bool labelOptional;
  final Widget? labelExtra;
  final SemiFormLabelPosition? labelPosition;
  final double? labelWidth;
  final TextAlign? labelAlign;
  final List<SemiFormFieldRule>? rules;
  final SemiFormFieldValidator? validator;
  final SemiFormTrigger? trigger;
  final num? min;
  final num? max;
  final num? step;
  final ValueChanged<num>? onChanged;
  final VoidCallback? onBlur;
  final Widget? helpText;
  final Widget? extraText;
  final Object? initValue;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return SemiFormField(
      field: field,
      label: label,
      rules: rules,
      validator: validator,
      trigger: trigger,
      initValue: initValue,
      helpText: helpText,
      extraText: extraText,
      labelOptional: labelOptional,
      labelExtra: labelExtra,
      labelPosition: labelPosition,
      labelWidth: labelWidth,
      labelAlign: labelAlign,
      builder: (context, control) => SemiInputNumber(
        value: control.value as num?,
        disabled: disabled || control.disabled,
        min: min,
        max: max,
        step: step ?? 1,
        // 上游 Form.InputNumber 数值口径——onNumberChange(num)。
        onNumberChange: (v) {
          onChanged?.call(v);
          control.onChanged(v);
        },
      ),
    );
  }
}

/// `Form.Slider`（值 num?）。
class SemiFormSlider extends StatelessWidget {
  const SemiFormSlider({
    super.key,
    required this.field,
    this.label,
    this.labelOptional = false,
    this.labelExtra,
    this.labelPosition,
    this.labelWidth,
    this.labelAlign,
    this.rules,
    this.validator,
    this.trigger,
    this.min = 0,
    this.max = 100,
    this.onChanged,
    this.onBlur,
    this.helpText,
    this.extraText,
    this.initValue,
    this.disabled = false,
  });

  final String field;
  final Object? label;
  final bool labelOptional;
  final Widget? labelExtra;
  final SemiFormLabelPosition? labelPosition;
  final double? labelWidth;
  final TextAlign? labelAlign;
  final List<SemiFormFieldRule>? rules;
  final SemiFormFieldValidator? validator;
  final SemiFormTrigger? trigger;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final VoidCallback? onBlur;
  final Widget? helpText;
  final Widget? extraText;
  final Object? initValue;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return SemiFormField(
      field: field,
      label: label,
      rules: rules,
      validator: validator,
      trigger: trigger,
      initValue: initValue,
      helpText: helpText,
      extraText: extraText,
      labelOptional: labelOptional,
      labelExtra: labelExtra,
      labelPosition: labelPosition,
      labelWidth: labelWidth,
      labelAlign: labelAlign,
      builder: (context, control) => SemiSlider(
        value: (control.value as num?)?.toDouble(),
        min: min,
        max: max,
        disabled: disabled || control.disabled,
        onChanged: (v) {
          // 上游 Slider 载荷 Object?（单值/区间）——本包装取单值 double。
          final d = (v as num).toDouble();
          onChanged?.call(d);
          control.onChanged(d);
        },
      ),
    );
  }
}

/// `Form.Rating`（值 double?）。
class SemiFormRating extends StatelessWidget {
  const SemiFormRating({
    super.key,
    required this.field,
    this.label,
    this.labelOptional = false,
    this.labelExtra,
    this.labelPosition,
    this.labelWidth,
    this.labelAlign,
    this.rules,
    this.validator,
    this.trigger,
    this.count = 5,
    this.onChanged,
    this.onBlur,
    this.helpText,
    this.extraText,
    this.initValue,
    this.disabled = false,
  });

  final String field;
  final Object? label;
  final bool labelOptional;
  final Widget? labelExtra;
  final SemiFormLabelPosition? labelPosition;
  final double? labelWidth;
  final TextAlign? labelAlign;
  final List<SemiFormFieldRule>? rules;
  final SemiFormFieldValidator? validator;
  final SemiFormTrigger? trigger;
  final int count;
  final ValueChanged<double>? onChanged;
  final VoidCallback? onBlur;
  final Widget? helpText;
  final Widget? extraText;
  final Object? initValue;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return SemiFormField(
      field: field,
      label: label,
      rules: rules,
      validator: validator,
      trigger: trigger,
      initValue: initValue,
      helpText: helpText,
      extraText: extraText,
      labelOptional: labelOptional,
      labelExtra: labelExtra,
      labelPosition: labelPosition,
      labelWidth: labelWidth,
      labelAlign: labelAlign,
      builder: (context, control) => SemiRating(
        value: (control.value as num?)?.toDouble() ?? 0,
        count: count,
        disabled: disabled || control.disabled,
        onChanged: (v) {
          onChanged?.call(v);
          control.onChanged(v);
        },
      ),
    );
  }
}

SemiInputStatus _statusOf(SemiFormFieldControl control) =>
    switch (control.validateStatus) {
      SemiFormValidateStatus.error => SemiInputStatus.error,
      SemiFormValidateStatus.warning => SemiInputStatus.warning,
      SemiFormValidateStatus.success => SemiInputStatus.success,
      SemiFormValidateStatus.normal => SemiInputStatus.normal,
    };

/// 硬编码常量 + async-validator 缺省文案（HARDCODES 另列——上游片段逐字
/// 留档，生成器锚点断言）。
abstract final class _FormMetrics {
  /// form.scss:101/148/258 `@include font-size-regular`（= 14——标签/错误行/
  /// extra 文本号）。
  static const double fontSizeRegular = 14;

  /// form.scss:303 `@include font-size-header-5`
  ///（`$font-size-header-5: 18px`，semi-theme-default/scss/variables.scss:62
  /// ——Section 标题号）。
  static const double sectionTitleFontSize = 18;

  /// zh_CN.ts:173 `optional: '（可选）'`（Form locale）。
  static const String localeOptional = '（可选）';

  /// async-validator url 格式（缺省 type: url）。
  static final RegExp urlRegex = RegExp(
    r'^(?:https?|ftp)://[^\s/$.?#].[^\s]*$',
    caseSensitive: false,
  );

  /// async-validator email 格式（缺省 type: email）。
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    caseSensitive: false,
  );

  // -- async-validator 缺省文案（"%s is required" 式模板） ------------------

  static String requiredMessage(String label) => '$label is required';
  static String whitespaceMessage(String label) => '$label cannot be empty';
  static String typeMessage(String label, String type) =>
      '$label is not a valid $type';
  static String lenMessage(String label, int len) =>
      '$label must be exactly $len characters';
  static String minMessage(String label, double min) =>
      '$label must be at least $min characters';
  static String maxMessage(String label, double max) =>
      '$label cannot be longer than $max characters';
  static String numberLenMessage(String label, int len) =>
      '$label must equal $len';
  static String numberMinMessage(String label, double min) =>
      '$label cannot be less than $min';
  static String numberMaxMessage(String label, double max) =>
      '$label cannot be greater than $max';
  static String enumMessage(String label, String values) =>
      '$label must be one of $values';
  static String patternMessage(String label) => '$label format is incorrect';

  // note-only 上游片段（生成器锚点逐字留档）：
  // constants.ts:15 `DEFAULT_TRIGGER: 'change'`。
  // zh_CN.ts:173 `optional: '（可选）'`。
  // form.scss:122 `content: "*"`。
  // errorMessage.tsx:78 `warning: <IconAlertTriangle />`。
  // errorMessage.tsx:79 `error: <IconAlertCircle />`。
  // foundation.ts:803 `behavior: 'smooth'`。
  // foundation.ts:803 `block: 'start'`。
  // form.scss:101 `@include font-size-regular`。
  // form.scss:303 `@include font-size-header-5`。
  // foundation.ts:193/445 `getUuidv4`（ArrayField updateKey 重挂载）。
  // withField.tsx:286 `first: mergeStopValidateWithError`（stopValidateWithError）。
  // withField.tsx:314 `message: ''`（空 message 仍算错误 quirk）。
  // baseForm.tsx:103 `labelPosition: 'top'`。
}
