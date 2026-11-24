// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/config/editorOptions.ts @bfbf12b
// Translated 1:1 from TypeScript. Do not refactor.
//
// SEGMENTED PORT (file in progress; PORT_PROGRESS keeps `pending` until the
// whole source file is translated):
//   segment 1/4 (this commit): source lines 1–52 (string-union types +
//     EditorAutoIndentStrategy), 1055–1467 (option framework:
//     ConfigurationChangedEvent, IEditorOption/BaseEditorOption/
//     ComputedEditorOption/SimpleEditorOption, ApplyUpdateResult/applyUpdate,
//     validation helpers), 1468–1526 (_autoIndentFromString,
//     EditorAccessibilitySupport), 5952–5957 (editorOptionsRegistry),
//     5959–6143 (EditorOption enum).
//   segment 2/4 (pending): lines 53–1054 (IEditorOptions, diff editor
//     options) and 1527–2600 (option classes).
//   segment 3/4 (pending): lines 2600–5958 (option classes cont.).
//   segment 4/4 (pending): lines 6144–7102 (EditorOptions registry object +
//     type-level helpers).
//
// Adaptations (documented inline):
//  * `const enum` → class of `static const int` (same convention as
//    `keyCodes.dart`); EditorOption values are generated from the source
//    table to avoid transcription drift.
//  * `PossibleKeyName<T>` / `Unknown<T>` are type-level computed key types →
//    erased; `name` is a `String` carrying the same value.
//  * TS instantiates `BaseEditorOption<K extends EditorOption, ...>` with
//    const-enum member *literal types* (`EditorOption.accessibilitySupport`);
//    Dart has no literal-type generics → `K` erases to `int id`
//    (`IEditorOption<V>`, `BaseEditorOption<V>`, ...).
//  * `IConfigurationPropertySchema | { [path]: ... }` → the ported
//    `IConfigurationPropertySchema` typedef (`Map<String, Object?>`);
//    constructor mutations become key writes.
//  * `ComputeOptionsMemory.stableMinimapLayoutInput` references
//    `IMinimapLayoutInput` (defined later in the source) → `Object?` carrier
//    until segment 2 lands.
//  * JS `parseInt`/`parseFloat` parse leading numeric prefixes of strings;
//    Dart `int.tryParse`/`double.tryParse` reject the whole string →
//    `_jsParseInt`/`_jsParseFloat` helpers.
//  * `IEnvironmentalOptions`/`IComputedEditorOptions` are interfaces →
//    abstract classes; `get<T extends EditorOption>` erases to
//    `Object? get(Object id)`.
// ---------------------------------------------------------------------------

import '../../../base/common/arrays.dart' as arrays;
import '../../../nls.dart' show localize;
import '../../../platform/accessibility/common/accessibility.dart'
    show AccessibilitySupport;
import '../../../platform/configuration/common/configurationRegistry.dart'
    show IConfigurationPropertySchema;
import 'fontInfo.dart' show FontInfo;

//#region typed options

/// Configuration options for auto closing quotes and brackets
/// 1:1: `export type EditorAutoClosingStrategy`.
class EditorAutoClosingStrategy {
  static const String always = 'always';
  static const String languageDefined = 'languageDefined';
  static const String beforeWhitespace = 'beforeWhitespace';
  static const String never = 'never';

  const EditorAutoClosingStrategy._();
}

/// Configuration options for auto wrapping quotes and brackets
/// 1:1: `export type EditorAutoSurroundStrategy`.
class EditorAutoSurroundStrategy {
  static const String languageDefined = 'languageDefined';
  static const String quotes = 'quotes';
  static const String brackets = 'brackets';
  static const String never = 'never';

  const EditorAutoSurroundStrategy._();
}

/// Configuration options for typing over closing quotes or brackets
/// 1:1: `export type EditorAutoClosingEditStrategy`.
class EditorAutoClosingEditStrategy {
  static const String always = 'always';
  static const String auto = 'auto';
  static const String never = 'never';

  const EditorAutoClosingEditStrategy._();
}

/// 1:1: `type Unknown<T> = { [K in keyof T]: unknown }` — type-level only.
// typedef Unknown<T> = ...; (erased)

/// Configuration options for auto indentation in the editor
/// 1:1: `export const enum EditorAutoIndentStrategy`.
class EditorAutoIndentStrategy {
  static const int none = 0;
  static const int keep = 1;
  static const int brackets = 2;
  static const int advanced = 3;
  static const int full = 4;

  const EditorAutoIndentStrategy._();
}

//#endregion

//#region IEditorOption

/// 1:1: `export class ConfigurationChangedEvent`.
class ConfigurationChangedEvent {
  ConfigurationChangedEvent(List<bool> values) : _values = values;

  final List<bool> _values;

  bool hasChanged(int id) {
    return _values[id];
  }
}

/// All computed editor options.
/// 1:1: `export interface IComputedEditorOptions`.
abstract class IComputedEditorOptions {
  Object? get(Object id);
}

//#region IEditorOption

/// @internal
/// 1:1: `export interface IEnvironmentalOptions`.
abstract class IEnvironmentalOptions {
  ComputeOptionsMemory? get memory;
  double get outerWidth;
  double get outerHeight;
  FontInfo get fontInfo;
  String get extraEditorClassName;
  bool get isDominatedByLongLines;
  num get viewLineCount;
  num get lineNumbersDigitCount;
  bool get emptySelectionClipboard;
  double get pixelRatio;
  bool get tabFocusMode;

  /// `'insert' | 'overtype'`.
  String get inputMode;
  int get accessibilitySupport;
  num get glyphMarginDecorationLaneCount;
  bool get editContextSupported;
}

/// @internal
/// 1:1: `export class ComputeOptionsMemory`.
class ComputeOptionsMemory {
  /// TS: `IMinimapLayoutInput | null` — carrier until segment 2.
  Object? stableMinimapLayoutInput;
  double stableFitMaxMinimapScale = 0;
  double stableFitRemainingWidth = 0;

  ComputeOptionsMemory() {
    stableMinimapLayoutInput = null;
    stableFitMaxMinimapScale = 0;
    stableFitRemainingWidth = 0;
  }
}

/// 1:1: `export interface IEditorOption<K extends EditorOption, V>`
/// (K erased to `int id` — see the header note).
abstract class IEditorOption<V> {
  int get id;
  String get name;

  // TS: non-readonly field; implementations keep it fixed after construction.
  V get defaultValue;

  /// @internal
  IConfigurationPropertySchema? get schema;

  /// @internal
  V validate(Object? input);

  /// @internal
  V compute(
      IEnvironmentalOptions env, IComputedEditorOptions options, V value);

  /// Might modify `value`.
  ApplyUpdateResult<V> applyUpdate(Object? value, Object? update);
}

/// 1:1: `type PossibleKeyName0<V>` / `PossibleKeyName<V>` — type-level
/// computed key names; erased, `name` is the same string.
// typedef PossibleKeyName<V> = String;

/// @internal
/// 1:1: `abstract class BaseEditorOption<K extends EditorOption, T, V>`
/// (`T` exists only in the erased `PossibleKeyName<T>` name type).
abstract class BaseEditorOption<V> implements IEditorOption<V> {
  BaseEditorOption(this.id, this.name, this.defaultValue,
      [IConfigurationPropertySchema? schema])
      : schema = schema;

  final int id;
  @override
  final String name;
  @override
  final V defaultValue;
  @override
  final IConfigurationPropertySchema? schema;

  @override
  ApplyUpdateResult<V> applyUpdate(Object? value, Object? update) {
    return _applyUpdate<V>(value, update);
  }

  @override
  V validate(Object? input);

  @override
  V compute(
          IEnvironmentalOptions env, IComputedEditorOptions options, V value) =>
      value;
}

/// 1:1: `export class ApplyUpdateResult<T>`.
class ApplyUpdateResult<T> {
  ApplyUpdateResult(this.newValue, this.didChange);

  final T newValue;
  final bool didChange;
}

/// 1:1: `function applyUpdate<T>(value, update)`.
ApplyUpdateResult<T> _applyUpdate<T>(Object? value, Object? update) {
  final bool valueIsObject = (value is Map || value is List) && value != null;
  final bool updateIsObject =
      (update is Map || update is List) && update != null;
  if (!valueIsObject || !updateIsObject) {
    return ApplyUpdateResult<T>(update as T, value != update);
  }
  if (value is List || update is List) {
    final bool arrayEquals = value is List &&
        update is List &&
        arrays.equals<Object?>(value, update);
    return ApplyUpdateResult<T>(update as T, !arrayEquals);
  }
  bool didChange = false;
  final Map<Object?, Object?> valueMap = value as Map<Object?, Object?>;
  final Map<Object?, Object?> updateMap = update as Map<Object?, Object?>;
  for (final Object? key in updateMap.keys) {
    final ApplyUpdateResult<Object?> result =
        _applyUpdate<Object?>(valueMap[key], updateMap[key]);
    if (result.didChange) {
      valueMap[key] = result.newValue;
      didChange = true;
    }
  }
  return ApplyUpdateResult<T>(value as T, didChange);
}

/// @internal
/// 1:1: `abstract class ComputedEditorOption<K extends EditorOption, V>`
/// (K erased — see the header note).
abstract class ComputedEditorOption<V> implements IEditorOption<V> {
  ComputedEditorOption(this.id, this.defaultValue);

  final int id;
  @override
  final String name = '_never_';
  @override
  final V defaultValue;
  @override
  final IConfigurationPropertySchema? schema = null;

  @override
  ApplyUpdateResult<V> applyUpdate(Object? value, Object? update) {
    return _applyUpdate<V>(value, update);
  }

  @override
  V validate(Object? input) {
    return defaultValue;
  }

  @override
  V compute(
      IEnvironmentalOptions env, IComputedEditorOptions options, V value);
}

/// 1:1: `abstract class SimpleEditorOption<K extends EditorOption, V>`
/// (K erased — see the header note).
abstract class SimpleEditorOption<V> implements IEditorOption<V> {
  SimpleEditorOption(this.id, this.name, this.defaultValue,
      [IConfigurationPropertySchema? schema])
      : schema = schema;

  final int id;
  @override
  final String name;
  @override
  final V defaultValue;
  @override
  final IConfigurationPropertySchema? schema;

  @override
  ApplyUpdateResult<V> applyUpdate(Object? value, Object? update) {
    return _applyUpdate<V>(value, update);
  }

  @override
  V validate(Object? input);

  @override
  V compute(
          IEnvironmentalOptions env, IComputedEditorOptions options, V value) =>
      value;
}

//#endregion

//#region validation functions

/// JS `parseInt(value, 10)`: parses the leading decimal prefix of a string.
int? _jsParseInt(String value) {
  final RegExpMatch? match =
      RegExp(r'^\s*([+-]?\d+)').firstMatch(value);
  if (match == null) {
    return null;
  }
  return int.tryParse(match.group(1)!);
}

/// JS `parseFloat(value)`: parses the leading decimal prefix of a string.
double? _jsParseFloat(String value) {
  final RegExpMatch? match = RegExp(
          r'^\s*([+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?)')
      .firstMatch(value);
  if (match == null) {
    return null;
  }
  return double.tryParse(match.group(1)!);
}

/// 1:1: `export function boolean(value, defaultValue)`.
/// JS distinguishes `undefined` (→ default) from `null` (→ `Boolean(null) ===
/// false`); the Dart carrier merges both into `null`, so null takes the
/// `undefined` branch (same convention as the rest of this port).
bool boolean(Object? value, bool defaultValue) {
  if (value == null) {
    return defaultValue;
  }
  if (value == 'false') {
    // treat the string 'false' as false
    return false;
  }
  // JS `Boolean(value)`: everything except `undefined`/`null`/`false`/`0`/`NaN`/`''` is truthy.
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0 && !value.isNaN;
  }
  if (value is String) {
    return value.isNotEmpty;
  }
  return true;
}

/// 1:1: `class EditorBooleanOption<K extends EditorOption>`.
class EditorBooleanOption extends SimpleEditorOption<bool> {
  EditorBooleanOption(int id, String name, bool defaultValue,
      [IConfigurationPropertySchema? schema])
      : super(id, name, defaultValue, schema) {
    if (schema != null) {
      schema['type'] = 'boolean';
      schema['default'] = defaultValue;
    }
  }

  @override
  bool validate(Object? input) {
    return boolean(input, defaultValue);
  }
}

/// @internal
/// JS `r | 0` — ToInt32 (wraps modulo 2^32, unlike Dart `truncate()`).
int _toInt32(num r) {
  final int v = r.truncate();
  final int unsigned = v & 0xFFFFFFFF;
  return unsigned < 0x80000000 ? unsigned : unsigned - 0x100000000;
}

/// 1:1: `export function clampedInt<T = number>(value, defaultValue, minimum, maximum)`.
Object clampedInt(Object? value, Object defaultValue, num minimum, num maximum) {
  if (value is String) {
    value = _jsParseInt(value);
  }
  if (value is! num || value.isNaN) {
    return defaultValue;
  }
  num r = value;
  r = minimum > r ? minimum : r;
  r = maximum < r ? maximum : r;
  return _toInt32(r);
}

/// 1:1: `class EditorIntOption<K extends EditorOption>`.
class EditorIntOption extends SimpleEditorOption<num> {
  /// TS: `public static clampedInt` — suffixed `Static` (source name in the
  /// comment) because it would shadow the top-level `clampedInt` here.
  static Object clampedIntStatic(
      Object? value, Object defaultValue, num minimum, num maximum) {
    return clampedInt(value, defaultValue, minimum, maximum);
  }

  EditorIntOption(int id, String name, num defaultValue, this.minimum,
      this.maximum,
      [IConfigurationPropertySchema? schema])
      : super(id, name, defaultValue, schema) {
    if (schema != null) {
      schema['type'] = 'integer';
      schema['default'] = defaultValue;
      schema['minimum'] = minimum;
      schema['maximum'] = maximum;
    }
  }

  final num minimum;
  final num maximum;

  @override
  num validate(Object? input) {
    return EditorIntOption.clampedIntStatic(
            input, defaultValue, minimum, maximum) as num;
  }
}

/// @internal
/// 1:1: `export function clampedFloat<T extends number>(value, defaultValue, minimum, maximum)`.
num clampedFloat(Object? value, num defaultValue, num minimum, num maximum) {
  if (value == null) {
    return defaultValue;
  }
  final num r = EditorFloatOption.float(value, defaultValue);
  return EditorFloatOption.clamp(r, minimum, maximum);
}

/// 1:1: `class EditorFloatOption<K extends EditorOption>`.
class EditorFloatOption extends SimpleEditorOption<num> {
  EditorFloatOption(int id, String name, num defaultValue,
      num Function(num value) validationFn,
      [IConfigurationPropertySchema? schema, num? minimum, num? maximum])
      : validationFn = validationFn,
        minimum = minimum,
        maximum = maximum,
        super(id, name, defaultValue, schema) {
    if (schema != null) {
      schema['type'] = 'number';
      schema['default'] = defaultValue;
      if (minimum != null) {
        schema['minimum'] = minimum;
      }
      if (maximum != null) {
        schema['maximum'] = maximum;
      }
    }
  }

  /// TS: `number | undefined`.
  final num? minimum;
  final num? maximum;

  static num clamp(num n, num min, num max) {
    if (n < min) {
      return min;
    }
    if (n > max) {
      return max;
    }
    return n;
  }

  static num float(Object? value, num defaultValue) {
    if (value is String) {
      value = _jsParseFloat(value);
    }
    if (value is! num || value.isNaN) {
      return defaultValue;
    }
    return value;
  }

  final num Function(num value) validationFn;

  @override
  num validate(Object? input) {
    return validationFn(EditorFloatOption.float(input, defaultValue));
  }
}

/// 1:1: `class EditorStringOption<K extends EditorOption>`.
class EditorStringOption extends SimpleEditorOption<String> {
  EditorStringOption(int id, String name, String defaultValue,
      [IConfigurationPropertySchema? schema])
      : super(id, name, defaultValue, schema) {
    if (schema != null) {
      schema['type'] = 'string';
      schema['default'] = defaultValue;
    }
  }

  static String string(Object? value, String defaultValue) {
    if (value is! String) {
      return defaultValue;
    }
    return value;
  }

  @override
  String validate(Object? input) {
    return EditorStringOption.string(input, defaultValue);
  }
}

/// @internal
/// 1:1: `export function stringSet<T extends string>(value, defaultValue, allowedValues, renamedValues?)`.
T stringSet<T extends String>(Object? value, T defaultValue,
    List<T> allowedValues,
    [Map<String, T>? renamedValues]) {
  if (value is! String) {
    return defaultValue;
  }
  if (renamedValues != null && renamedValues.containsKey(value)) {
    return renamedValues[value]!;
  }
  if (!allowedValues.contains(value)) {
    return defaultValue;
  }
  return value as T;
}

/// 1:1: `class EditorStringEnumOption<K extends EditorOption, V extends string>`.
class EditorStringEnumOption<V extends String>
    extends SimpleEditorOption<V> {
  EditorStringEnumOption(int id, String name, V defaultValue,
      List<V> allowedValues,
      [IConfigurationPropertySchema? schema])
      : _allowedValues = allowedValues,
        super(id, name, defaultValue, schema) {
    if (schema != null) {
      schema['type'] = 'string';
      schema['enum'] = List<V>.of(allowedValues);
      schema['default'] = defaultValue;
    }
  }

  final List<V> _allowedValues;

  @override
  V validate(Object? input) {
    return stringSet<V>(input, defaultValue, _allowedValues);
  }
}

/// 1:1: `class EditorEnumOption<K extends EditorOption, T extends string, V>`.
class EditorEnumOption<T extends String, V> extends BaseEditorOption<V> {
  EditorEnumOption(int id, String name, V defaultValue, String defaultStringValue,
      List<T> allowedValues, V Function(T value) convert,
      [IConfigurationPropertySchema? schema])
      : _allowedValues = allowedValues,
        _convert = convert,
        super(id, name, defaultValue, schema) {
    if (schema != null) {
      schema['type'] = 'string';
      schema['enum'] = allowedValues;
      schema['default'] = defaultStringValue;
    }
  }

  final List<T> _allowedValues;
  final V Function(T value) _convert;

  @override
  V validate(Object? input) {
    if (input is! String) {
      return defaultValue;
    }
    if (!_allowedValues.contains(input)) {
      return defaultValue;
    }
    return _convert(input as T);
  }
}

//#endregion

//#region autoIndent

// ignore: unused_element
int _autoIndentFromString(
    // used by the EditorAutoIndent option class in segment 2
    String autoIndent) {
  switch (autoIndent) {
    case 'none':
      return EditorAutoIndentStrategy.none;
    case 'keep':
      return EditorAutoIndentStrategy.keep;
    case 'brackets':
      return EditorAutoIndentStrategy.brackets;
    case 'advanced':
      return EditorAutoIndentStrategy.advanced;
    case 'full':
      return EditorAutoIndentStrategy.full;
  }
  return EditorAutoIndentStrategy.none;
}

//#endregion

//#region EditorOption enum

/// 1:1: `export const enum EditorOption` (auto-increment values, generated
/// from the source table).
class EditorOption {
  static const int acceptSuggestionOnCommitCharacter = 0;
  static const int acceptSuggestionOnEnter = 1;
  static const int accessibilitySupport = 2;
  static const int accessibilityPageSize = 3;
  static const int allowOverflow = 4;
  static const int allowVariableLineHeights = 5;
  static const int allowVariableFonts = 6;
  static const int allowVariableFontsInAccessibilityMode = 7;
  static const int ariaLabel = 8;
  static const int ariaRequired = 9;
  static const int autoClosingBrackets = 10;
  static const int autoClosingComments = 11;
  static const int screenReaderAnnounceInlineSuggestion = 12;
  static const int autoClosingDelete = 13;
  static const int autoClosingOvertype = 14;
  static const int autoClosingQuotes = 15;
  static const int autoIndent = 16;
  static const int autoIndentOnPaste = 17;
  static const int autoIndentOnPasteWithinString = 18;
  static const int automaticLayout = 19;
  static const int autoSurround = 20;
  static const int bracketPairColorization = 21;
  static const int guides = 22;
  static const int codeLens = 23;
  static const int codeLensFontFamily = 24;
  static const int codeLensFontSize = 25;
  static const int colorDecorators = 26;
  static const int colorDecoratorsLimit = 27;
  static const int columnSelection = 28;
  static const int comments = 29;
  static const int contextmenu = 30;
  static const int copyWithSyntaxHighlighting = 31;
  static const int cursorBlinking = 32;
  static const int cursorSmoothCaretAnimation = 33;
  static const int cursorStyle = 34;
  static const int cursorSurroundingLines = 35;
  static const int cursorSurroundingLinesStyle = 36;
  static const int cursorWidth = 37;
  static const int cursorHeight = 38;
  static const int disableLayerHinting = 39;
  static const int disableMonospaceOptimizations = 40;
  static const int domReadOnly = 41;
  static const int dragAndDrop = 42;
  static const int dropIntoEditor = 43;
  static const int editContext = 44;
  static const int emptySelectionClipboard = 45;
  static const int experimentalGpuAcceleration = 46;
  static const int experimentalWhitespaceRendering = 47;
  static const int extraEditorClassName = 48;
  static const int fastScrollSensitivity = 49;
  static const int find = 50;
  static const int fixedOverflowWidgets = 51;
  static const int folding = 52;
  static const int foldingStrategy = 53;
  static const int foldingHighlight = 54;
  static const int foldingImportsByDefault = 55;
  static const int foldingMaximumRegions = 56;
  static const int unfoldOnClickAfterEndOfLine = 57;
  static const int fontFamily = 58;
  static const int fontInfo = 59;
  static const int fontLigatures = 60;
  static const int fontSize = 61;
  static const int fontWeight = 62;
  static const int fontVariations = 63;
  static const int formatOnPaste = 64;
  static const int formatOnType = 65;
  static const int glyphMargin = 66;
  static const int gotoLocation = 67;
  static const int hideCursorInOverviewRuler = 68;
  static const int hover = 69;
  static const int inDiffEditor = 70;
  static const int inlineSuggest = 71;
  static const int letterSpacing = 72;
  static const int lightbulb = 73;
  static const int lineDecorationsWidth = 74;
  static const int lineHeight = 75;
  static const int lineNumbers = 76;
  static const int lineNumbersMinChars = 77;
  static const int linkedEditing = 78;
  static const int links = 79;
  static const int markdownImages = 80;
  static const int matchBrackets = 81;
  static const int minimap = 82;
  static const int mouseStyle = 83;
  static const int mouseWheelScrollSensitivity = 84;
  static const int mouseWheelZoom = 85;
  static const int multiCursorMergeOverlapping = 86;
  static const int multiCursorModifier = 87;
  static const int mouseMiddleClickAction = 88;
  static const int multiCursorPaste = 89;
  static const int multiCursorLimit = 90;
  static const int occurrencesHighlight = 91;
  static const int occurrencesHighlightDelay = 92;
  static const int occurrencesHighlightFromAllProviders = 93;
  static const int overtypeCursorStyle = 94;
  static const int overtypeOnPaste = 95;
  static const int overviewRulerBorder = 96;
  static const int overviewRulerLanes = 97;
  static const int padding = 98;
  static const int pasteAs = 99;
  static const int parameterHints = 100;
  static const int peekWidgetDefaultFocus = 101;
  static const int placeholder = 102;
  static const int definitionLinkOpensInPeek = 103;
  static const int quickSuggestions = 104;
  static const int quickSuggestionsDelay = 105;
  static const int readOnly = 106;
  static const int readOnlyMessage = 107;
  static const int renameOnType = 108;
  static const int renderRichScreenReaderContent = 109;
  static const int renderControlCharacters = 110;
  static const int renderFinalNewline = 111;
  static const int renderLineHighlight = 112;
  static const int renderLineHighlightOnlyWhenFocus = 113;
  static const int renderValidationDecorations = 114;
  static const int renderWhitespace = 115;
  static const int revealHorizontalRightPadding = 116;
  static const int roundedSelection = 117;
  static const int rulers = 118;
  static const int scrollbar = 119;
  static const int scrollBeyondLastColumn = 120;
  static const int scrollBeyondLastLine = 121;
  static const int scrollPredominantAxis = 122;
  static const int selectionClipboard = 123;
  static const int selectionHighlight = 124;
  static const int selectionHighlightMaxLength = 125;
  static const int selectionHighlightMultiline = 126;
  static const int selectedTextMatchMode = 127;
  static const int selectOnLineNumbers = 128;
  static const int showFoldingControls = 129;
  static const int showUnused = 130;
  static const int snippetSuggestions = 131;
  static const int smartSelect = 132;
  static const int smoothScrolling = 133;
  static const int stickyScroll = 134;
  static const int stickyTabStops = 135;
  static const int stopRenderingLineAfter = 136;
  static const int suggest = 137;
  static const int suggestFontSize = 138;
  static const int suggestLineHeight = 139;
  static const int suggestOnTriggerCharacters = 140;
  static const int suggestSelection = 141;
  static const int tabCompletion = 142;
  static const int tabIndex = 143;
  static const int trimWhitespaceOnDelete = 144;
  static const int unicodeHighlighting = 145;
  static const int unusualLineTerminators = 146;
  static const int useShadowDOM = 147;
  static const int useTabStops = 148;
  static const int wordBreak = 149;
  static const int wordSegmenterLocales = 150;
  static const int wordSeparators = 151;
  static const int wordWrap = 152;
  static const int wordWrapBreakAfterCharacters = 153;
  static const int wordWrapBreakBeforeCharacters = 154;
  static const int wordWrapColumn = 155;
  static const int wordWrapOverride1 = 156;
  static const int wordWrapOverride2 = 157;
  static const int wrappingIndent = 158;
  static const int wrappingStrategy = 159;
  static const int showDeprecated = 160;
  static const int inertialScroll = 161;
  static const int inlayHints = 162;
  static const int wrapOnEscapedLineFeeds = 163;
  static const int wordWrapIndicator = 164;
  static const int effectiveCursorStyle = 165;
  static const int editorClassName = 166;
  static const int pixelRatio = 167;
  static const int tabFocusMode = 168;
  static const int layoutInfo = 169;
  static const int wrappingInfo = 170;
  static const int defaultColorDecorators = 171;
  static const int colorDecoratorsActivatedOn = 172;
  static const int inlineCompletionsAccessibilityVerbose = 173;
  static const int effectiveEditContext = 174;
  static const int scrollOnMiddleClick = 175;
  static const int effectiveAllowVariableFonts = 176;
  static const int doubleClickSelectsBlock = 177;
  static const int fullwidthCharacterWidth = 178;
  static const int effectiveFullwidthCharacterWidth = 179;

  const EditorOption._();
}

//#endregion

//#region registry

/// 1:1: `export const editorOptionsRegistry: IEditorOption<EditorOption, unknown>[]`.
final List<IEditorOption<Object?>> editorOptionsRegistry =
    <IEditorOption<Object?>>[];

/// 1:1: `function register<K extends EditorOption, V>(option)`.
IEditorOption<V> register<V>(IEditorOption<V> option) {
  editorOptionsRegistry.add(option as IEditorOption<Object?>);
  return option;
}

//#endregion

//#region accessibilitySupport

/// 1:1: `class EditorAccessibilitySupport extends
/// BaseEditorOption<EditorOption.accessibilitySupport, 'auto' | 'off' | 'on',
/// AccessibilitySupport>` (K erased — see the header note).
class EditorAccessibilitySupport extends BaseEditorOption<int> {
  EditorAccessibilitySupport()
      : super(
          EditorOption.accessibilitySupport,
          'accessibilitySupport',
          AccessibilitySupport.Unknown,
          <String, Object?>{
            'type': 'string',
            'enum': <String>['auto', 'on', 'off'],
            'enumDescriptions': <String>[
              localize('accessibilitySupport.auto',
                  'Use platform APIs to detect when a Screen Reader is attached.'),
              localize('accessibilitySupport.on',
                  'Optimize for usage with a Screen Reader.'),
              localize('accessibilitySupport.off',
                  'Assume a screen reader is not attached.'),
            ],
            'default': 'auto',
            'tags': <String>['accessibility'],
            'description': localize('accessibilitySupport',
                'Controls if the UI should run in a mode where it is optimized for screen readers.'),
          },
        );

  @override
  int validate(Object? input) {
    switch (input) {
      case 'auto':
        return AccessibilitySupport.Unknown;
      case 'off':
        return AccessibilitySupport.Disabled;
      case 'on':
        return AccessibilitySupport.Enabled;
    }
    return defaultValue;
  }

  @override
  int compute(IEnvironmentalOptions env, IComputedEditorOptions options,
      int value) {
    if (value == AccessibilitySupport.Unknown) {
      // The editor reads the `accessibilitySupport` from the environment
      return env.accessibilitySupport;
    }
    return value;
  }
}

//#endregion
