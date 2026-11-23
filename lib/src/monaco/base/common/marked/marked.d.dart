// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/marked/marked.d.ts
// Translated 1:1 from the declaration bundle (`dts-bundle-generator` output).
//
// A `.d.ts` has no runtime body, so every symbol is a shape-only carrier:
//   - `interface`  -> class with typed fields (permissive default constructor).
//   - `type` union / mapped / indexed -> `typedef` to `Object?` or a carrier.
//   - `declare namespace Tokens` -> `Tokens` marker class; its members are
//     top-level `TokensXxx` carriers (Dart has no nested classes; `Tokens.List`
//     cannot be spelled `List` because that would shadow dart:core `List`).
//   - `declare class` -> abstract class with the declared member signatures.
//   - overloaded exported functions -> callable carriers + top-level helpers.
// All exported names match the declaration file for downstream consumers.
// ---------------------------------------------------------------------------

import 'dart:async' show Future;
import 'dart:collection' show ListBase;

/// 1:1: `declare namespace Tokens` (marker; members are `TokensXxx` carriers).
class Tokens {
  Tokens._();
}

/// 1:1: `Tokens.Space` — `{ type: "space"; raw: string }`
class TokensSpace {
  TokensSpace();
  String get type => 'space';
  String raw = '';
}

/// 1:1: `Tokens.Code`
class TokensCode {
  TokensCode();
  String get type => 'code';
  String raw = '';
  String? codeBlockStyle; // "indented" | undefined
  String? lang;
  String text = '';
  bool? escaped;
}

/// 1:1: `Tokens.Heading`
class TokensHeading {
  TokensHeading();
  String get type => 'heading';
  String raw = '';
  int depth = 0;
  String text = '';
  List<Object?> tokens = <Object?>[]; // Token[]
}

/// 1:1: `Tokens.Table`
class TokensTable {
  TokensTable();
  String get type => 'table';
  String raw = '';
  List<String?> align = <String?>[]; // "center"|"left"|"right"|null
  List<TokensTableCell> header = <TokensTableCell>[];
  List<List<TokensTableCell>> rows = <List<TokensTableCell>>[];
}

/// 1:1: `Tokens.TableRow`
class TokensTableRow {
  TokensTableRow();
  String text = '';
}

/// 1:1: `Tokens.TableCell`
class TokensTableCell {
  TokensTableCell();
  String text = '';
  List<Object?> tokens = <Object?>[]; // Token[]
  bool header = false;
  String? align; // "center"|"left"|"right"|null
}

/// 1:1: `Tokens.Hr`
class TokensHr {
  TokensHr();
  String get type => 'hr';
  String raw = '';
}

/// 1:1: `Tokens.Blockquote`
class TokensBlockquote {
  TokensBlockquote();
  String get type => 'blockquote';
  String raw = '';
  String text = '';
  List<Object?> tokens = <Object?>[]; // Token[]
}

/// 1:1: `Tokens.List`
class TokensListType {
  TokensListType();
  String get type => 'list';
  String raw = '';
  bool ordered = false;
  Object start = 0; // number | ""
  bool loose = false;
  List<TokensListItem> items = <TokensListItem>[];
}

/// 1:1: `Tokens.ListItem`
class TokensListItem {
  TokensListItem();
  String get type => 'list_item';
  String raw = '';
  bool task = false;
  bool? checked;
  bool loose = false;
  String text = '';
  List<Object?> tokens = <Object?>[]; // Token[]
}

/// 1:1: `Tokens.Checkbox`
class TokensCheckbox {
  TokensCheckbox();
  bool checked = false;
}

/// 1:1: `Tokens.Paragraph`
class TokensParagraph {
  TokensParagraph();
  String get type => 'paragraph';
  String raw = '';
  bool? pre;
  String text = '';
  List<Object?> tokens = <Object?>[]; // Token[]
}

/// 1:1: `Tokens.HTML`
class TokensHTML {
  TokensHTML();
  String get type => 'html';
  String raw = '';
  bool pre = false;
  String text = '';
  bool block = false;
}

/// 1:1: `Tokens.Text`
class TokensText {
  TokensText();
  String get type => 'text';
  String raw = '';
  String text = '';
  List<Object?>? tokens; // Token[] | undefined
}

/// 1:1: `Tokens.Def`
class TokensDef {
  TokensDef();
  String get type => 'def';
  String raw = '';
  String tag = '';
  String href = '';
  String title = '';
}

/// 1:1: `Tokens.Escape`
class TokensEscape {
  TokensEscape();
  String get type => 'escape';
  String raw = '';
  String text = '';
}

/// 1:1: `Tokens.Tag`
class TokensTag {
  TokensTag();
  String get type => 'text'; // "text" | "html"
  String raw = '';
  bool inLink = false;
  bool inRawBlock = false;
  String text = '';
  bool block = false;
}

/// 1:1: `Tokens.Link`
class TokensLink {
  TokensLink();
  String get type => 'link';
  String raw = '';
  String href = '';
  String? title; // string | null
  String text = '';
  List<Object?> tokens = <Object?>[]; // Token[]
}

/// 1:1: `Tokens.Image`
class TokensImage {
  TokensImage();
  String get type => 'image';
  String raw = '';
  String href = '';
  String? title; // string | null
  String text = '';
}

/// 1:1: `Tokens.Strong`
class TokensStrong {
  TokensStrong();
  String get type => 'strong';
  String raw = '';
  String text = '';
  List<Object?> tokens = <Object?>[]; // Token[]
}

/// 1:1: `Tokens.Em`
class TokensEm {
  TokensEm();
  String get type => 'em';
  String raw = '';
  String text = '';
  List<Object?> tokens = <Object?>[]; // Token[]
}

/// 1:1: `Tokens.Codespan`
class TokensCodespan {
  TokensCodespan();
  String get type => 'codespan';
  String raw = '';
  String text = '';
}

/// 1:1: `Tokens.Br`
class TokensBr {
  TokensBr();
  String get type => 'br';
  String raw = '';
}

/// 1:1: `Tokens.Del`
class TokensDel {
  TokensDel();
  String get type => 'del';
  String raw = '';
  String text = '';
  List<Object?> tokens = <Object?>[]; // Token[]
}

/// 1:1: `Tokens.Generic` (`[index: string]: any`)
class TokensGeneric {
  TokensGeneric();
  String type = '';
  String raw = '';
  List<Object?>? tokens; // Token[] | undefined
  final Map<String, Object?> _index = <String, Object?>{};
  Object? operator [](String key) => _index[key];
  void operator []=(String key, Object? value) => _index[key] = value;
}

/// 1:1: `export type MarkedToken`
typedef MarkedToken = Object?;

/// 1:1: `export type Token = MarkedToken | Tokens.Generic`
typedef Token = Object?;

/// 1:1: `export type Links`
typedef Links = Map<String, Map<String, Object?>>;

/// 1:1: `export type TokensList = Token[] & { links: Links }`
class TokensList extends ListBase<Object?> {
  TokensList([List<Object?>? items]) : _items = items ?? <Object?>[];

  final List<Object?> _items;
  Links links = <String, Map<String, Object?>>{};

  @override
  int get length => _items.length;
  @override
  set length(int value) => _items.length = value;
  @override
  Object? operator [](int index) => _items[index];
  @override
  void operator []=(int index, Object? value) => _items[index] = value;
}

/// 1:1: `export type BlockKeys`
typedef BlockKeys = String;

/// 1:1: `export type InlineKeys`
typedef InlineKeys = String;

/// 1:1: `export interface Rules`
class Rules {
  Rules();
  Map<String, RegExp> block = <String, RegExp>{};
  Map<String, RegExp> inline = <String, RegExp>{};
}

/// 1:1: `export interface TokenizerThis`
class TokenizerThis {
  TokenizerThis();
  Object? lexer; // _Lexer
}

/// 1:1: `export type TokenizerExtensionFunction`
typedef TokenizerExtensionFunction = Object? Function(
  Object? thisArg,
  String src,
  Object? tokens,
);

/// 1:1: `export type TokenizerStartFunction`
typedef TokenizerStartFunction = Object? Function(Object? thisArg, String src);

/// 1:1: `export interface TokenizerExtension`
class TokenizerExtension {
  TokenizerExtension();
  String name = '';
  String level = 'block'; // "block" | "inline"
  TokenizerStartFunction? start;
  TokenizerExtensionFunction tokenizer = (
    Object? thisArg,
    String src,
    Object? tokens,
  ) =>
      null;
  List<String>? childTokens;
}

/// 1:1: `export interface RendererThis`
class RendererThis {
  RendererThis();
  Object? parser; // _Parser
}

/// 1:1: `export type RendererExtensionFunction`
typedef RendererExtensionFunction = Object? Function(
  Object? thisArg,
  Object? token,
);

/// 1:1: `export interface RendererExtension`
class RendererExtension {
  RendererExtension();
  String name = '';
  RendererExtensionFunction renderer = (Object? thisArg, Object? token) => null;
}

/// 1:1: `export type TokenizerAndRendererExtension`
typedef TokenizerAndRendererExtension = Object?;

/// 1:1: `export type HooksApi`
typedef HooksApi = Object?;

/// 1:1: `export type HooksObject`
typedef HooksObject = Map<String, Function>;

/// 1:1: `export type RendererApi`
typedef RendererApi = Object?;

/// 1:1: `export type RendererObject`
typedef RendererObject = Map<String, Function>;

/// 1:1: `export type TokenizerApi`
typedef TokenizerApi = Object?;

/// 1:1: `export type TokenizerObject`
typedef TokenizerObject = Map<String, Function>;

/// 1:1: `export interface MarkedExtension`
class MarkedExtension {
  MarkedExtension();
  bool? async;
  bool? breaks;
  List<Object?>? extensions;
  bool? gfm;
  Map<String, Function>? hooks; // HooksObject
  bool? pedantic;
  Map<String, Function>? renderer; // RendererObject
  bool? silent;
  Map<String, Function>? tokenizer; // TokenizerObject
  Object? walkTokens; // (token) => void | Promise<void>
}

/// 1:1: `export interface MarkedOptions`
class MarkedOptions {
  MarkedOptions();
  bool? async;
  bool? breaks;
  bool? gfm;
  bool? pedantic;
  bool? silent;
  Object? hooks; // _Hooks
  Object? renderer; // _Renderer
  Object? tokenizer; // _Tokenizer
  Object? extensions;
  Object? walkTokens;
}

/// 1:1: `export type MaybePromise = void | Promise<void>`
typedef MaybePromise = Future<void>?;

/// Carriers for the exported regex tables (declaration carries shape only).
class MarkedBlockRules {
  Map<String, RegExp> normal = <String, RegExp>{};
  Map<String, RegExp> gfm = <String, RegExp>{};
  Map<String, RegExp> pedantic = <String, RegExp>{};
}

class MarkedInlineRules {
  Map<String, RegExp> normal = <String, RegExp>{};
  Map<String, RegExp> gfm = <String, RegExp>{};
  Map<String, RegExp> breaks = <String, RegExp>{};
  Map<String, RegExp> pedantic = <String, RegExp>{};
}

/// 1:1: `export declare const block`
final MarkedBlockRules block = MarkedBlockRules();

/// 1:1: `export declare const inline`
final MarkedInlineRules inline = MarkedInlineRules();

/// 1:1: `declare class _Renderer` / exported `Renderer`
abstract class Renderer {
  MarkedOptions? options;
  Object? parser;
  Renderer([MarkedOptions? options]);
  String space(Object? token);
  String code(Object? token);
  String blockquote(Object? token);
  String html(Object? token);
  String heading(Object? token);
  String hr(Object? token);
  String list(Object? token);
  String listitem(Object? token);
  String checkbox(Object? token);
  String paragraph(Object? token);
  String table(Object? token);
  String tablerow(Object? token);
  String tablecell(Object? token);
  String strong(Object? token);
  String em(Object? token);
  String codespan(Object? token);
  String br(Object? token);
  String del(Object? token);
  String link(Object? token);
  String image(Object? token);
  String text(Object? token);
}

/// 1:1: `declare class _TextRenderer` / exported `TextRenderer`
abstract class TextRenderer {
  TextRenderer([MarkedOptions? options]);
  String strong(Object? token);
  String em(Object? token);
  String codespan(Object? token);
  String del(Object? token);
  String html(Object? token);
  String text(Object? token);
  String link(Object? token);
  String image(Object? token);
  String br();
}

/// 1:1: `declare class _Parser` / exported `Parser`.
/// Instance `parse`/`parseInline` are suffixed because Dart forbids a static
/// and an instance member sharing a name (TS allows it).
abstract class Parser {
  MarkedOptions? options;
  Object? renderer;
  Object? textRenderer;
  Parser([MarkedOptions? options]);
  static String parse(List<Object?> tokens, [MarkedOptions? options]) => '';
  static String parseInline(List<Object?> tokens, [MarkedOptions? options]) => '';
  String parseTokens(List<Object?> tokens, [bool top = false]);
  String parseInlineTokens(List<Object?> tokens, [Object? renderer]);
}

/// 1:1: `declare class _Tokenizer` / exported `Tokenizer`
abstract class Tokenizer {
  MarkedOptions? options;
  Rules? rules;
  Object? lexer;
  Tokenizer([MarkedOptions? options]);
  Object? space(String src);
  Object? code(String src);
  Object? fences(String src);
  Object? heading(String src);
  Object? hr(String src);
  Object? blockquote(String src);
  Object? list(String src);
  Object? html(String src);
  Object? def(String src);
  Object? table(String src);
  Object? lheading(String src);
  Object? paragraph(String src);
  Object? text(String src);
  Object? escape(String src);
  Object? tag(String src);
  Object? link(String src);
  Object? reflink(String src, Links links);
  Object? emStrong(String src, String maskedSrc, [String? prevChar]);
  Object? codespan(String src);
  Object? br(String src);
  Object? del(String src);
  Object? autolink(String src);
  Object? url(String src);
  Object? inlineText(String src);
}

/// 1:1: `declare class _Hooks` / exported `Hooks`
abstract class Hooks {
  MarkedOptions? options;
  Hooks([MarkedOptions? options]);
  static final Set<String> passThroughHooks = <String>{};
  String preprocess(String markdown);
  String postprocess(String html);
  Object? processAllTokens(Object? tokens);
}

/// 1:1: `declare class _Lexer` / exported `Lexer`.
/// Instance `lex` suffixed (`lexTokens`) for the same static/instance reason.
abstract class Lexer {
  TokensList? tokens;
  MarkedOptions? options;
  Object? state; // { inLink, inRawBlock, top }
  Lexer([MarkedOptions? options]);
  static TokensList lex(String src, [MarkedOptions? options]) => TokensList();
  static List<Object?> lexInline(String src, [MarkedOptions? options]) =>
      <Object?>[];
  TokensList lexTokens(String src);
  List<Object?> blockTokens(String src,
      [Object? tokens, bool? lastParagraphClipped]);
  List<Object?> inline(String src, [List<Object?>? tokens]);
  List<Object?> inlineTokens(String src, [List<Object?>? tokens]);
}

/// 1:1: `declare function _getDefaults`
MarkedOptions getDefaults() => MarkedOptions();

/// 1:1: `export declare class Marked`
abstract class Marked {
  MarkedOptions defaults = MarkedOptions();
  Marked([List<MarkedExtension> args = const <MarkedExtension>[]]);
  Object? options(MarkedOptions opt);
  Object? parse;
  Object? parseInline;
  Object? Parser;
  Object? Renderer;
  Object? TextRenderer;
  Object? Lexer;
  Object? Tokenizer;
  Object? Hooks;
  List<MaybePromise> walkTokens(
    Object? tokens,
    MaybePromise Function(Object? token) callback,
  );
  Object? use([List<MarkedExtension> args = const <MarkedExtension>[]]);
  Object? setOptions(MarkedOptions opt);
  TokensList lexer(String src, [MarkedOptions? options]);
  String parser(List<Object?> tokens, [MarkedOptions? options]);
}

/// Callable carrier for the overloaded `marked(...)` export plus its merged
/// namespace members (`options`, `setOptions`, `parseInline`, ...).
class MarkedFn {
  MarkedFn();

  Future<String> callAsync(String src, MarkedOptions options) async => '';
  String call(String src, [MarkedOptions? options]) => '';

  Object? Function(MarkedOptions) options = (MarkedOptions o) => null;
  Object? Function(MarkedOptions) setOptions = (MarkedOptions o) => null;
  MarkedOptions Function() getDefaults = () => MarkedOptions();
  MarkedOptions defaults = MarkedOptions();
  Object? Function(List<MarkedExtension>) use =
      (List<MarkedExtension> args) => null;
  List<MaybePromise> Function(Object?, Function) walkTokens =
      (Object? tokens, Function cb) => <MaybePromise>[];
  Object? parseInline;
  Object? Parser;
  Object? parser;
  Object? Renderer;
  Object? TextRenderer;
  Object? Lexer;
  Object? lexer;
  Object? Tokenizer;
  Object? Hooks;
  Object? parse;
}

/// 1:1: `export declare function marked` + merged namespace.
final MarkedFn marked = MarkedFn();

/// 1:1: standalone re-exports of the merged namespace members.
final Object? Function(MarkedOptions) options = (MarkedOptions o) => null;
final Object? Function(MarkedOptions) setOptions = (MarkedOptions o) => null;
final Object? Function(List<MarkedExtension>) use =
    (List<MarkedExtension> args) => null;
final List<MaybePromise> Function(Object?, Function) walkTokens =
    (Object? tokens, Function cb) => <MaybePromise>[];
final Object? parseInline = null;
final Object? parse = null;
final Object? parser = null;
final Object? lexer = null;
