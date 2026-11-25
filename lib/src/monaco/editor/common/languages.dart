// ---------------------------------------------------------------------------
// 1:1 port of vscode/src/vs/editor/common/languages.ts (2718 lines).
//
// This file is overwhelmingly type-level: ~120 `interface` declarations, ~15
// `type` aliases and several generic provider shapes are ERASED per the repo's
// established convention (see PORT_PROGRESS.md / editorCommon.dart). Providers
// only ever consume them structurally, so nothing observable is lost.
//
// Ported 1:1 (runtime):
//   - 26 enums (HoverVerbosityAction … ExternalUriOpenerPriority)
//   - `CompletionItemKinds` namespace (toIcon / toLabel / fromString)
//   - `CompletionItemKinds.fromString` overloads -> `fromString` + `tryFromString`
//   - `SelectedSuggestionInfo` (class + equals)
//   - `ProviderId`, `VersionedExtensionId`
//   - `isLocationLink`, `isLocation`
//   - `symbolKindNames`, `getAriaLabelForSymbol`
//   - `SymbolKinds` namespace (toIcon / toCompletionKind)
//   - `TextEdit` abstract class (declaration-merged with the `TextEdit`
//     interface in TS; only the class has runtime)
//   - `FoldingRangeKind`
//   - `Command` namespace (`is`)
//   - `LazyTokenizationSupport`
//   - `Token`, `TokenizationResult`, `EncodedTokenizationResult`
//   - `TokenizationRegistry` singleton
//
// Adaptations (all forced by the erased interfaces):
//   - `IState`, `IFontToken`, `ITokenizationSupport`, `ISingleEditOperation`
//     stay erased; signatures use `Object?` / `dynamic` where TS is generic.
//   - `Uint32Array` -> `Uint32List` (dart:typed_data).
//   - `CompletionItemKind` / `SymbolKind` are `int` (const enums).
//   - `console.info(...)` -> `print(...)` (repo convention, `avoid_print`).
//   - `symbolKindNames[kind]` for an out-of-range kind is `undefined` in JS and
//     stringifies to "undefined"; the port substitutes the literal so
//     `getAriaLabelForSymbol` stays byte-identical.
//   - `TextEdit.isTextEdit(null)` throws in TS (it dereferences the argument);
//     the Dart port dereferences too, so it throws `NoSuchMethodError`.
// ---------------------------------------------------------------------------

import 'dart:async';
import 'dart:typed_data';

import '../../base/common/codicons.dart' show Codicon;
import '../../base/common/themables.dart' show ThemeIcon;
import '../../base/common/uri.dart' show URI;
import '../../nls.dart' show localize;
import 'core/editOperation.dart' show EditOperation, ISingleEditOperation;
import 'core/range.dart' show IRange, Range;
import 'tokenizationRegistry.dart' as tokenization_registry
    show TokenizationRegistry;

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// 1:1: `export enum HoverVerbosityAction`.
class HoverVerbosityAction {
  static const int Increase = 0;
  static const int Decrease = 1;

  const HoverVerbosityAction._();
}

/// 1:1: `export const enum CompletionItemKind`.
class CompletionItemKind {
  static const int Method = 0;
  static const int Function = 1;
  static const int Constructor = 2;
  static const int Field = 3;
  static const int Variable = 4;
  static const int Class = 5;
  static const int Struct = 6;
  static const int Interface = 7;
  static const int Module = 8;
  static const int Property = 9;
  static const int Event = 10;
  static const int Operator = 11;
  static const int Unit = 12;
  static const int Value = 13;
  static const int Constant = 14;
  static const int Enum = 15;
  static const int EnumMember = 16;
  static const int Keyword = 17;
  static const int Text = 18;
  static const int Color = 19;
  static const int File = 20;
  static const int Reference = 21;
  static const int Customcolor = 22;
  static const int Folder = 23;
  static const int TypeParameter = 24;
  static const int User = 25;
  static const int Issue = 26;
  static const int Tool = 27;
  static const int Snippet = 28; // <- highest value (used for compare!)

  const CompletionItemKind._();
}

/// 1:1: `export const enum CompletionItemTag`.
class CompletionItemTag {
  static const int Deprecated = 1;

  const CompletionItemTag._();
}

/// 1:1: `export const enum CompletionItemInsertTextRule`.
class CompletionItemInsertTextRule {
  static const int None = 0;

  /// Adjust whitespace/indentation of multiline insert texts to
  /// match the current line indentation.
  static const int KeepWhitespace = 0x001;

  /// `insertText` is a snippet.
  static const int InsertAsSnippet = 0x004; // 0b100

  const CompletionItemInsertTextRule._();
}

/// 1:1: `export const enum PartialAcceptTriggerKind`.
class PartialAcceptTriggerKind {
  static const int Word = 0;
  static const int Line = 1;
  static const int Suggest = 2;

  const PartialAcceptTriggerKind._();
}

/// 1:1: `export const enum CompletionTriggerKind`.
class CompletionTriggerKind {
  static const int Invoke = 0;
  static const int TriggerCharacter = 1;
  static const int TriggerForIncompleteCompletions = 2;

  const CompletionTriggerKind._();
}

/// 1:1: `export enum InlineCompletionTriggerKind`.
class InlineCompletionTriggerKind {
  static const int Automatic = 0;
  static const int Explicit = 1;

  const InlineCompletionTriggerKind._();
}

/// 1:1: `export enum InlineCompletionHintStyle`.
class InlineCompletionHintStyle {
  static const int Code = 1;
  static const int Label = 2;

  const InlineCompletionHintStyle._();
}

/// 1:1: `export enum InlineCompletionEndOfLifeReasonKind`.
class InlineCompletionEndOfLifeReasonKind {
  static const int Accepted = 0;
  static const int Rejected = 1;
  static const int Ignored = 2;

  const InlineCompletionEndOfLifeReasonKind._();
}

/// 1:1: `export const enum CodeActionTriggerType`.
class CodeActionTriggerType {
  static const int Invoke = 1;
  static const int Auto = 2;

  const CodeActionTriggerType._();
}

/// 1:1: `export enum DocumentPasteTriggerKind`.
class DocumentPasteTriggerKind {
  static const int Automatic = 0;
  static const int PasteAs = 1;

  const DocumentPasteTriggerKind._();
}

/// 1:1: `export enum SignatureHelpTriggerKind`.
class SignatureHelpTriggerKind {
  static const int Invoke = 1;
  static const int TriggerCharacter = 2;
  static const int ContentChange = 3;

  const SignatureHelpTriggerKind._();
}

/// 1:1: `export enum DocumentHighlightKind`.
class DocumentHighlightKind {
  /// A textual occurrence.
  static const int Text = 0;

  /// Read-access of a symbol, like reading a variable.
  static const int Read = 1;

  /// Write-access of a symbol, like writing to a variable.
  static const int Write = 2;

  const DocumentHighlightKind._();
}

/// 1:1: `export const enum SymbolKind`.
class SymbolKind {
  static const int File = 0;
  static const int Module = 1;
  static const int Namespace = 2;
  static const int Package = 3;
  static const int Class = 4;
  static const int Method = 5;
  static const int Property = 6;
  static const int Field = 7;
  static const int Constructor = 8;
  static const int Enum = 9;
  static const int Interface = 10;
  static const int Function = 11;
  static const int Variable = 12;
  static const int Constant = 13;
  static const int String = 14;
  static const int Number = 15;
  static const int Boolean = 16;
  static const int Array = 17;
  static const int Object = 18;
  static const int Key = 19;
  static const int Null = 20;
  static const int EnumMember = 21;
  static const int Struct = 22;
  static const int Event = 23;
  static const int Operator = 24;
  static const int TypeParameter = 25;

  const SymbolKind._();
}

/// 1:1: `export const enum SymbolTag`.
class SymbolTag {
  static const int Deprecated = 1;

  const SymbolTag._();
}

/// 1:1: `export enum StructuralDiffClassification`.
class StructuralDiffClassification {
  static const int Declaration = 1;
  static const int Header = 2;
  static const int Implementation = 3;
  static const int Dependency = 4;
  static const int Other = 5;

  const StructuralDiffClassification._();
}

/// 1:1: `export enum StructuralDiffTag`.
class StructuralDiffTag {
  static const int Test = 1;

  const StructuralDiffTag._();
}

/// 1:1: `export enum NewSymbolNameTag`.
class NewSymbolNameTag {
  static const int AIGenerated = 1;

  const NewSymbolNameTag._();
}

/// 1:1: `export enum NewSymbolNameTriggerKind`.
class NewSymbolNameTriggerKind {
  static const int Invoke = 0;
  static const int Automatic = 1;

  const NewSymbolNameTriggerKind._();
}

/// 1:1: `export enum CommentThreadCollapsibleState`.
class CommentThreadCollapsibleState {
  /// Determines an item is collapsed.
  static const int Collapsed = 0;

  /// Determines an item is expanded.
  static const int Expanded = 1;

  const CommentThreadCollapsibleState._();
}

/// 1:1: `export enum CommentThreadState`.
class CommentThreadState {
  static const int Unresolved = 0;
  static const int Resolved = 1;

  const CommentThreadState._();
}

/// 1:1: `export enum CommentThreadApplicability`.
class CommentThreadApplicability {
  static const int Current = 0;
  static const int Outdated = 1;

  const CommentThreadApplicability._();
}

/// 1:1: `export enum CommentMode`.
class CommentMode {
  static const int Editing = 0;
  static const int Preview = 1;

  const CommentMode._();
}

/// 1:1: `export enum CommentState`.
class CommentState {
  static const int Published = 0;
  static const int Draft = 1;

  const CommentState._();
}

/// 1:1: `export enum InlayHintKind`.
class InlayHintKind {
  static const int Type = 1;
  static const int Parameter = 2;

  const InlayHintKind._();
}

/// 1:1: `export enum ExternalUriOpenerPriority`.
class ExternalUriOpenerPriority {
  static const int None = 0;
  static const int Option = 1;
  static const int Default = 2;
  static const int Preferred = 3;

  const ExternalUriOpenerPriority._();
}

// ---------------------------------------------------------------------------
// CompletionItemKinds
// ---------------------------------------------------------------------------

/// 1:1: `export namespace CompletionItemKinds`.
class CompletionItemKinds {
  const CompletionItemKinds._();

  static final Map<int, ThemeIcon> _byKind = <int, ThemeIcon>{
    CompletionItemKind.Method: Codicon['symbolMethod']!,
    CompletionItemKind.Function: Codicon['symbolFunction']!,
    CompletionItemKind.Constructor: Codicon['symbolConstructor']!,
    CompletionItemKind.Field: Codicon['symbolField']!,
    CompletionItemKind.Variable: Codicon['symbolVariable']!,
    CompletionItemKind.Class: Codicon['symbolClass']!,
    CompletionItemKind.Struct: Codicon['symbolStruct']!,
    CompletionItemKind.Interface: Codicon['symbolInterface']!,
    CompletionItemKind.Module: Codicon['symbolModule']!,
    CompletionItemKind.Property: Codicon['symbolProperty']!,
    CompletionItemKind.Event: Codicon['symbolEvent']!,
    CompletionItemKind.Operator: Codicon['symbolOperator']!,
    CompletionItemKind.Unit: Codicon['symbolUnit']!,
    CompletionItemKind.Value: Codicon['symbolValue']!,
    CompletionItemKind.Enum: Codicon['symbolEnum']!,
    CompletionItemKind.Constant: Codicon['symbolConstant']!,
    CompletionItemKind.EnumMember: Codicon['symbolEnumMember']!,
    CompletionItemKind.Keyword: Codicon['symbolKeyword']!,
    CompletionItemKind.Snippet: Codicon['symbolSnippet']!,
    CompletionItemKind.Text: Codicon['symbolText']!,
    CompletionItemKind.Color: Codicon['symbolColor']!,
    CompletionItemKind.File: Codicon['symbolFile']!,
    CompletionItemKind.Reference: Codicon['symbolReference']!,
    CompletionItemKind.Customcolor: Codicon['symbolCustomColor']!,
    CompletionItemKind.Folder: Codicon['symbolFolder']!,
    CompletionItemKind.TypeParameter: Codicon['symbolTypeParameter']!,
    CompletionItemKind.User: Codicon['account']!,
    CompletionItemKind.Issue: Codicon['issues']!,
    CompletionItemKind.Tool: Codicon['tools']!,
  };

  /// @internal
  static ThemeIcon toIcon(int kind) {
    ThemeIcon? codicon = _byKind[kind];
    if (codicon == null) {
      // ignore: avoid_print
      print('No codicon found for CompletionItemKind $kind');
      codicon = Codicon['symbolProperty']!;
    }
    return codicon;
  }

  /// @internal
  static String toLabel(int kind) {
    switch (kind) {
      case CompletionItemKind.Method:
        return localize('suggestWidget.kind.method', 'Method');
      case CompletionItemKind.Function:
        return localize('suggestWidget.kind.function', 'Function');
      case CompletionItemKind.Constructor:
        return localize('suggestWidget.kind.constructor', 'Constructor');
      case CompletionItemKind.Field:
        return localize('suggestWidget.kind.field', 'Field');
      case CompletionItemKind.Variable:
        return localize('suggestWidget.kind.variable', 'Variable');
      case CompletionItemKind.Class:
        return localize('suggestWidget.kind.class', 'Class');
      case CompletionItemKind.Struct:
        return localize('suggestWidget.kind.struct', 'Struct');
      case CompletionItemKind.Interface:
        return localize('suggestWidget.kind.interface', 'Interface');
      case CompletionItemKind.Module:
        return localize('suggestWidget.kind.module', 'Module');
      case CompletionItemKind.Property:
        return localize('suggestWidget.kind.property', 'Property');
      case CompletionItemKind.Event:
        return localize('suggestWidget.kind.event', 'Event');
      case CompletionItemKind.Operator:
        return localize('suggestWidget.kind.operator', 'Operator');
      case CompletionItemKind.Unit:
        return localize('suggestWidget.kind.unit', 'Unit');
      case CompletionItemKind.Value:
        return localize('suggestWidget.kind.value', 'Value');
      case CompletionItemKind.Constant:
        return localize('suggestWidget.kind.constant', 'Constant');
      case CompletionItemKind.Enum:
        return localize('suggestWidget.kind.enum', 'Enum');
      case CompletionItemKind.EnumMember:
        return localize('suggestWidget.kind.enumMember', 'Enum Member');
      case CompletionItemKind.Keyword:
        return localize('suggestWidget.kind.keyword', 'Keyword');
      case CompletionItemKind.Text:
        return localize('suggestWidget.kind.text', 'Text');
      case CompletionItemKind.Color:
        return localize('suggestWidget.kind.color', 'Color');
      case CompletionItemKind.File:
        return localize('suggestWidget.kind.file', 'File');
      case CompletionItemKind.Reference:
        return localize('suggestWidget.kind.reference', 'Reference');
      case CompletionItemKind.Customcolor:
        return localize('suggestWidget.kind.customcolor', 'Custom Color');
      case CompletionItemKind.Folder:
        return localize('suggestWidget.kind.folder', 'Folder');
      case CompletionItemKind.TypeParameter:
        return localize('suggestWidget.kind.typeParameter', 'Type Parameter');
      case CompletionItemKind.User:
        return localize('suggestWidget.kind.user', 'User');
      case CompletionItemKind.Issue:
        return localize('suggestWidget.kind.issue', 'Issue');
      case CompletionItemKind.Tool:
        return localize('suggestWidget.kind.tool', 'Tool');
      case CompletionItemKind.Snippet:
        return localize('suggestWidget.kind.snippet', 'Snippet');
      default:
        return '';
    }
  }

  static final Map<String, int> _data = <String, int>{
    'method': CompletionItemKind.Method,
    'function': CompletionItemKind.Function,
    'constructor': CompletionItemKind.Constructor,
    'field': CompletionItemKind.Field,
    'variable': CompletionItemKind.Variable,
    'class': CompletionItemKind.Class,
    'struct': CompletionItemKind.Struct,
    'interface': CompletionItemKind.Interface,
    'module': CompletionItemKind.Module,
    'property': CompletionItemKind.Property,
    'event': CompletionItemKind.Event,
    'operator': CompletionItemKind.Operator,
    'unit': CompletionItemKind.Unit,
    'value': CompletionItemKind.Value,
    'constant': CompletionItemKind.Constant,
    'enum': CompletionItemKind.Enum,
    'enum-member': CompletionItemKind.EnumMember,
    'enumMember': CompletionItemKind.EnumMember,
    'keyword': CompletionItemKind.Keyword,
    'snippet': CompletionItemKind.Snippet,
    'text': CompletionItemKind.Text,
    'color': CompletionItemKind.Color,
    'file': CompletionItemKind.File,
    'reference': CompletionItemKind.Reference,
    'customcolor': CompletionItemKind.Customcolor,
    'folder': CompletionItemKind.Folder,
    'type-parameter': CompletionItemKind.TypeParameter,
    'typeParameter': CompletionItemKind.TypeParameter,
    'account': CompletionItemKind.User,
    'issue': CompletionItemKind.Issue,
    'tool': CompletionItemKind.Tool,
  };

  /// @internal
  ///
  /// TS overloads `fromString(value)` (non-undefined) and
  /// `fromString(value, strict: true)` (possibly `undefined`); Dart splits them
  /// into [fromString] / [tryFromString] while keeping the same fallback rule.
  static int fromString(String value) => _data[value] ?? CompletionItemKind.Property;

  /// @internal
  static int? tryFromString(String value) => _data[value];
}

// ---------------------------------------------------------------------------
// symbolKindNames / SymbolKinds
// ---------------------------------------------------------------------------

/// @internal
/// 1:1: `export const symbolKindNames: { [symbol: number]: string }`.
final Map<int, String> symbolKindNames = <int, String>{
  SymbolKind.Array: localize('Array', 'array'),
  SymbolKind.Boolean: localize('Boolean', 'boolean'),
  SymbolKind.Class: localize('Class', 'class'),
  SymbolKind.Constant: localize('Constant', 'constant'),
  SymbolKind.Constructor: localize('Constructor', 'constructor'),
  SymbolKind.Enum: localize('Enum', 'enumeration'),
  SymbolKind.EnumMember: localize('EnumMember', 'enumeration member'),
  SymbolKind.Event: localize('Event', 'event'),
  SymbolKind.Field: localize('Field', 'field'),
  SymbolKind.File: localize('File', 'file'),
  SymbolKind.Function: localize('Function', 'function'),
  SymbolKind.Interface: localize('Interface', 'interface'),
  SymbolKind.Key: localize('Key', 'key'),
  SymbolKind.Method: localize('Method', 'method'),
  SymbolKind.Module: localize('Module', 'module'),
  SymbolKind.Namespace: localize('Namespace', 'namespace'),
  SymbolKind.Null: localize('Null', 'null'),
  SymbolKind.Number: localize('Number', 'number'),
  SymbolKind.Object: localize('Object', 'object'),
  SymbolKind.Operator: localize('Operator', 'operator'),
  SymbolKind.Package: localize('Package', 'package'),
  SymbolKind.Property: localize('Property', 'property'),
  SymbolKind.String: localize('String', 'string'),
  SymbolKind.Struct: localize('Struct', 'struct'),
  SymbolKind.TypeParameter: localize('TypeParameter', 'type parameter'),
  SymbolKind.Variable: localize('Variable', 'variable'),
};

/// @internal
/// 1:1: `export function getAriaLabelForSymbol`
///
/// JS string-concatenates `undefined` for an out-of-range kind ("foo
/// (undefined)"); `{1}`-formatting a Dart `null` would yield "null", so the
/// literal substitution keeps the output identical.
String getAriaLabelForSymbol(String symbolName, int kind) {
  return localize('symbolAriaLabel', '{0} ({1})', <Object?>[
    symbolName,
    symbolKindNames[kind] ?? 'undefined',
  ]);
}

/// 1:1: `export namespace SymbolKinds`.
class SymbolKinds {
  const SymbolKinds._();

  static final Map<int, ThemeIcon> _byKind = <int, ThemeIcon>{
    SymbolKind.File: Codicon['symbolFile']!,
    SymbolKind.Module: Codicon['symbolModule']!,
    SymbolKind.Namespace: Codicon['symbolNamespace']!,
    SymbolKind.Package: Codicon['symbolPackage']!,
    SymbolKind.Class: Codicon['symbolClass']!,
    SymbolKind.Method: Codicon['symbolMethod']!,
    SymbolKind.Property: Codicon['symbolProperty']!,
    SymbolKind.Field: Codicon['symbolField']!,
    SymbolKind.Constructor: Codicon['symbolConstructor']!,
    SymbolKind.Enum: Codicon['symbolEnum']!,
    SymbolKind.Interface: Codicon['symbolInterface']!,
    SymbolKind.Function: Codicon['symbolFunction']!,
    SymbolKind.Variable: Codicon['symbolVariable']!,
    SymbolKind.Constant: Codicon['symbolConstant']!,
    SymbolKind.String: Codicon['symbolString']!,
    SymbolKind.Number: Codicon['symbolNumber']!,
    SymbolKind.Boolean: Codicon['symbolBoolean']!,
    SymbolKind.Array: Codicon['symbolArray']!,
    SymbolKind.Object: Codicon['symbolObject']!,
    SymbolKind.Key: Codicon['symbolKey']!,
    SymbolKind.Null: Codicon['symbolNull']!,
    SymbolKind.EnumMember: Codicon['symbolEnumMember']!,
    SymbolKind.Struct: Codicon['symbolStruct']!,
    SymbolKind.Event: Codicon['symbolEvent']!,
    SymbolKind.Operator: Codicon['symbolOperator']!,
    SymbolKind.TypeParameter: Codicon['symbolTypeParameter']!,
  };

  /// @internal
  static ThemeIcon toIcon(int kind) {
    ThemeIcon? icon = _byKind[kind];
    if (icon == null) {
      // ignore: avoid_print
      print('No codicon found for SymbolKind $kind');
      icon = Codicon['symbolProperty']!;
    }
    return icon;
  }

  static final Map<int, int> _byCompletionKind = <int, int>{
    SymbolKind.File: CompletionItemKind.File,
    SymbolKind.Module: CompletionItemKind.Module,
    SymbolKind.Namespace: CompletionItemKind.Module,
    SymbolKind.Package: CompletionItemKind.Module,
    SymbolKind.Class: CompletionItemKind.Class,
    SymbolKind.Method: CompletionItemKind.Method,
    SymbolKind.Property: CompletionItemKind.Property,
    SymbolKind.Field: CompletionItemKind.Field,
    SymbolKind.Constructor: CompletionItemKind.Constructor,
    SymbolKind.Enum: CompletionItemKind.Enum,
    SymbolKind.Interface: CompletionItemKind.Interface,
    SymbolKind.Function: CompletionItemKind.Function,
    SymbolKind.Variable: CompletionItemKind.Variable,
    SymbolKind.Constant: CompletionItemKind.Constant,
    SymbolKind.String: CompletionItemKind.Text,
    SymbolKind.Number: CompletionItemKind.Value,
    SymbolKind.Boolean: CompletionItemKind.Value,
    SymbolKind.Array: CompletionItemKind.Value,
    SymbolKind.Object: CompletionItemKind.Value,
    SymbolKind.Key: CompletionItemKind.Keyword,
    SymbolKind.Null: CompletionItemKind.Value,
    SymbolKind.EnumMember: CompletionItemKind.EnumMember,
    SymbolKind.Struct: CompletionItemKind.Struct,
    SymbolKind.Event: CompletionItemKind.Event,
    SymbolKind.Operator: CompletionItemKind.Operator,
    SymbolKind.TypeParameter: CompletionItemKind.TypeParameter,
  };

  /// @internal
  static int toCompletionKind(int kind) {
    int? completionKind = _byCompletionKind[kind];
    if (completionKind == null) {
      // ignore: avoid_print
      print('No completion kind found for SymbolKind $kind');
      completionKind = CompletionItemKind.File;
    }
    return completionKind;
  }
}
// ---------------------------------------------------------------------------
// Tokenization value objects
// ---------------------------------------------------------------------------

/// 1:1: `export class Token`.
class Token {
  // TS `_tokenBrand: void = undefined` is a type-only brand; omitted.

  Token(this.offset, this.type, this.language);

  final int offset;
  final String type;
  final String language;

  @override
  String toString() => '($offset, $type)';
}

/// @internal
/// 1:1: `export class TokenizationResult`.
class TokenizationResult {
  // TS `_tokenizationResultBrand` is a type-only brand; omitted.

  TokenizationResult(this.tokens, this.endState);

  final List<Token> tokens;

  /// TS `IState` (erased interface).
  final Object? endState;
}

/// @internal
/// 1:1: `export class EncodedTokenizationResult`.
class EncodedTokenizationResult {
  // TS `_encodedTokenizationResultBrand` is a type-only brand; omitted.

  EncodedTokenizationResult(this.tokens, this.fontInfo, this.endState);

  /// The tokens in binary format. Each token occupies two array indices.
  final Uint32List tokens;

  /// TS `IFontToken[]` (erased interface).
  final List<Object?> fontInfo;

  /// TS `IState` (erased interface).
  final Object? endState;
}

// ---------------------------------------------------------------------------
// SelectedSuggestionInfo
// ---------------------------------------------------------------------------

/// 1:1: `export class SelectedSuggestionInfo`.
class SelectedSuggestionInfo {
  SelectedSuggestionInfo(
    this.range,
    this.text,
    this.completionKind,
    this.isSnippetText,
  );

  final IRange range;
  final String text;
  final int completionKind;
  final bool isSnippetText;

  bool equals(SelectedSuggestionInfo other) {
    return Range.lift(range)!.equalsRange(other.range) &&
        text == other.text &&
        completionKind == other.completionKind &&
        isSnippetText == other.isSnippetText;
  }
}

// ---------------------------------------------------------------------------
// ProviderId / VersionedExtensionId
// ---------------------------------------------------------------------------

/// @internal
/// 1:1: `export class ProviderId`.
class ProviderId {
  ProviderId(this.extensionId, this.extensionVersion, this.providerId);

  static ProviderId fromExtensionId(String? extensionId) =>
      ProviderId(extensionId, null, null);

  final String? extensionId;
  final String? extensionVersion;
  final String? providerId;

  @override
  String toString() {
    String result = '';
    if (_truthy(extensionId)) {
      result += extensionId!;
    }
    if (_truthy(extensionVersion)) {
      result += '@${extensionVersion!}';
    }
    if (_truthy(providerId)) {
      result += ':${providerId!}';
    }
    if (result.isEmpty) {
      result = 'unknown';
    }
    return result;
  }

  String toStringWithoutVersion() {
    String result = '';
    if (_truthy(extensionId)) {
      result += extensionId!;
    }
    if (_truthy(providerId)) {
      result += ':${providerId!}';
    }
    return result;
  }
}

/// @internal
/// 1:1: `export class VersionedExtensionId`.
class VersionedExtensionId {
  VersionedExtensionId(this.extensionId, this.version);

  static VersionedExtensionId? tryCreate(String? extensionId, String? version) {
    if (!_truthy(extensionId) || !_truthy(version)) {
      return null;
    }
    return VersionedExtensionId(extensionId!, version!);
  }

  final String extensionId;
  final String version;

  @override
  String toString() => '$extensionId@$version';
}

// ---------------------------------------------------------------------------
// Location predicates
// ---------------------------------------------------------------------------

/// @internal
/// 1:1: `export function isLocationLink(thing: unknown): thing is LocationLink`
///
/// Plain object literals arrive as `Map`s here; records expose getters.
bool isLocationLink(Object? thing) {
  if (!_truthy(thing)) {
    return false;
  }
  return URI.isUri(_member(thing, 'uri')) &&
      Range.isIRange(_member(thing, 'range')) &&
      (Range.isIRange(_member(thing, 'originSelectionRange')) ||
          Range.isIRange(_member(thing, 'targetSelectionRange')));
}

/// @internal
/// 1:1: `export function isLocation(thing: unknown): thing is Location`
bool isLocation(Object? thing) {
  if (!_truthy(thing)) {
    return false;
  }
  return URI.isUri(_member(thing, 'uri')) &&
      Range.isIRange(_member(thing, 'range'));
}

// ---------------------------------------------------------------------------
// TextEdit
// ---------------------------------------------------------------------------

/// 1:1: `export interface TextEdit` + `export abstract class TextEdit`
/// (declaration merge; only the class has a runtime surface).
abstract class TextEdit {
  IRange get range;
  String get text;

  /// TS `eol?: model.EndOfLineSequence` (erased `const enum` -> `int`).
  int? get eol => null;

  /// 1:1: `static asEditOperation(edit: TextEdit): ISingleEditOperation`
  static ISingleEditOperation asEditOperation(TextEdit edit) {
    final Range range = Range.lift(edit.range)!;
    return range.isEmpty()
        ? EditOperation.insert(range.getStartPosition(), edit.text) // moves marker
        : EditOperation.replace(range, edit.text);
  }

  /// 1:1: `static isTextEdit(thing: unknown): thing is TextEdit`
  ///
  /// The real implementation dereferences `thing` unconditionally, so a `null`
  /// argument throws a TypeError in TS; the port throws as well.
  static bool isTextEdit(Object? thing) {
    if (thing == null) {
      throw NoSuchMethodError.withInvocation(
          null, Invocation.getter(const Symbol('text')));
    }
    return _member(thing, 'text') is String &&
        Range.isIRange(_member(thing, 'range'));
  }
}

// ---------------------------------------------------------------------------
// FoldingRangeKind
// ---------------------------------------------------------------------------

/// 1:1: `export class FoldingRangeKind`.
class FoldingRangeKind {
  /// Kind for folding range representing a comment. The value of the kind is
  /// 'comment'.
  static final FoldingRangeKind Comment = FoldingRangeKind('comment');

  /// Kind for folding range representing an import. The value of the kind is
  /// 'imports'.
  static final FoldingRangeKind Imports = FoldingRangeKind('imports');

  /// Kind for folding range representing regions (for example marked by
  /// `#region`, `#endregion`). The value of the kind is 'region'.
  static final FoldingRangeKind Region = FoldingRangeKind('region');

  /// Returns a [FoldingRangeKind] for the given value.
  static FoldingRangeKind fromValue(String value) {
    switch (value) {
      case 'comment':
        return FoldingRangeKind.Comment;
      case 'imports':
        return FoldingRangeKind.Imports;
      case 'region':
        return FoldingRangeKind.Region;
    }
    return FoldingRangeKind(value);
  }

  FoldingRangeKind(this.value);

  String value;
}

// ---------------------------------------------------------------------------
// Command
// ---------------------------------------------------------------------------

/// 1:1: `export interface Command` + `export namespace Command`.
///
/// The interface is erased; the namespace keeps its one runtime function.
abstract class Command {
  /// TS name is `Command.is`; `is` is a Dart keyword, so it becomes
  /// [isCommand] (same semantics).
  static bool isCommand(Object? obj) {
    if (!_truthy(obj) || obj is num || obj is String || obj is bool ||
        obj is Function) {
      return false;
    }
    return _member(obj, 'id') is String && _member(obj, 'title') is String;
  }
}

// ---------------------------------------------------------------------------
// LazyTokenizationSupport
// ---------------------------------------------------------------------------

/// @internal
/// 1:1: `export class LazyTokenizationSupport<TSupport>`
class LazyTokenizationSupport<TSupport> {
  LazyTokenizationSupport(this._createSupport);

  final Future<TSupport?> Function() _createSupport;

  /// TS `Promise<TSupport & IDisposable | null>` (the intersection is erased).
  Future<TSupport?>? _tokenizationSupport;

  void dispose() {
    final Future<TSupport?>? support = _tokenizationSupport;
    if (support != null) {
      support.then((value) {
        if (value != null) {
          (value as dynamic).dispose();
        }
      });
    }
  }

  Future<TSupport?> get tokenizationSupport {
    Future<TSupport?>? support = _tokenizationSupport;
    if (support == null) {
      support = _createSupport();
      _tokenizationSupport = support;
    }
    return support;
  }
}

// ---------------------------------------------------------------------------
// TokenizationRegistry singleton
// ---------------------------------------------------------------------------

/// @internal
/// 1:1: `export const TokenizationRegistry: ITokenizationRegistry<ITokenizationSupport> = new TokenizationRegistryImpl();`
///
/// `ITokenizationSupport` is an erased interface, hence `<Object>`; callers use
/// the registry's own API surface unchanged.
final tokenization_registry.TokenizationRegistry<Object> TokenizationRegistry =
    tokenization_registry.TokenizationRegistry<Object>();

// ---------------------------------------------------------------------------
// Helpers (JS semantics)
// ---------------------------------------------------------------------------

/// JS truthiness.
bool _truthy(Object? value) {
  if (value == null || value == false) return false;
  if (value is num) return value != 0 && !value.isNaN;
  if (value is String) return value.isNotEmpty;
  return true;
}

/// Reads `obj[member]` like JS: object literals are `Map`s, records expose
/// getters, primitives expose nothing.
Object? _member(Object? obj, String member) {
  if (obj == null) {
    return null;
  }
  if (obj is Map) {
    return obj[member];
  }
  if (obj is num || obj is String || obj is bool || obj is List) {
    return null;
  }
  return (obj as dynamic).noSuchMethod(Invocation.getter(Symbol(member)));
}
