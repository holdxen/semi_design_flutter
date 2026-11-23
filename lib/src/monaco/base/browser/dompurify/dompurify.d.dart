// Generated 1:1 from vs/base/browser/dompurify/dompurify.d.ts (DOMPurify 3.4.17).
// Ambient type declarations: interface -> abstract class, type -> typedef.
// DOM/global types (Node, Element, TrustedHTML, ...) -> Object? carriers.
library;

/// interface Config
abstract class Config {
  /// optional ADD_ATTR: string[] | ((attributeName: string, tagName: string) => boolean) | undefined
  Object? get ADD_ATTR;
  /// optional ADD_DATA_URI_TAGS: string[] | undefined
  List<String>? get ADD_DATA_URI_TAGS;
  /// optional ADD_TAGS: string[] | ((tagName: string) => boolean) | undefined
  Object? get ADD_TAGS;
  /// optional ADD_URI_SAFE_ATTR: string[] | undefined
  List<String>? get ADD_URI_SAFE_ATTR;
  /// optional ALLOW_ARIA_ATTR: boolean | undefined
  bool? get ALLOW_ARIA_ATTR;
  /// optional ALLOW_DATA_ATTR: boolean | undefined
  bool? get ALLOW_DATA_ATTR;
  /// optional ALLOW_UNKNOWN_PROTOCOLS: boolean | undefined
  bool? get ALLOW_UNKNOWN_PROTOCOLS;
  /// optional ALLOW_SELF_CLOSE_IN_ATTR: boolean | undefined
  bool? get ALLOW_SELF_CLOSE_IN_ATTR;
  /// optional ALLOWED_ATTR: string[] | undefined
  List<String>? get ALLOWED_ATTR;
  /// optional ALLOWED_TAGS: string[] | undefined
  List<String>? get ALLOWED_TAGS;
  /// optional ALLOWED_NAMESPACES: string[] | undefined
  List<String>? get ALLOWED_NAMESPACES;
  /// optional ALLOWED_URI_REGEXP: RegExp | undefined
  RegExp? get ALLOWED_URI_REGEXP;
  /// optional CUSTOM_ELEMENT_HANDLING: { /** * Regular expression or function to match to allowed elements. * Default is null (disallow any custom elements). */ tagNameCheck?: RegExp | ((tagName: string) => boolean) | null | undefined; /** * Regular expression or function to match to allowed attributes. * Default is null (disallow any attributes not on the allow list). */ attributeNameCheck?: RegExp | ((attributeName: string, tagName?: string) => boolean) | null | undefined; /** * Allow custom elements derived from built-ins if they pass `tagNameCheck`. Default is false. */ allowCustomizedBuiltInElements?: boolean | undefined; }
  Map<String, Object?>? get CUSTOM_ELEMENT_HANDLING;
  /// optional FORBID_ATTR: string[] | undefined
  List<String>? get FORBID_ATTR;
  /// optional FORBID_CONTENTS: string[] | undefined
  List<String>? get FORBID_CONTENTS;
  /// optional ADD_FORBID_CONTENTS: string[] | undefined
  List<String>? get ADD_FORBID_CONTENTS;
  /// optional FORBID_TAGS: string[] | undefined
  List<String>? get FORBID_TAGS;
  /// optional FORCE_BODY: boolean | undefined
  bool? get FORCE_BODY;
  /// optional HTML_INTEGRATION_POINTS: Record<string, boolean> | undefined
  Map<String, bool>? get HTML_INTEGRATION_POINTS;
  /// optional IN_PLACE: boolean | undefined
  bool? get IN_PLACE;
  /// optional KEEP_CONTENT: boolean | undefined
  bool? get KEEP_CONTENT;
  /// optional MATHML_TEXT_INTEGRATION_POINTS: Record<string, boolean> | undefined
  Map<String, bool>? get MATHML_TEXT_INTEGRATION_POINTS;
  /// optional NAMESPACE: string | undefined
  String? get NAMESPACE;
  /// optional PARSER_MEDIA_TYPE: DOMParserSupportedType | undefined
  Object? get PARSER_MEDIA_TYPE;
  /// optional RETURN_DOM_FRAGMENT: boolean | undefined
  bool? get RETURN_DOM_FRAGMENT;
  /// optional RETURN_DOM: boolean | undefined
  bool? get RETURN_DOM;
  /// optional RETURN_TRUSTED_TYPE: boolean | undefined
  bool? get RETURN_TRUSTED_TYPE;
  /// optional SAFE_FOR_TEMPLATES: boolean | undefined
  bool? get SAFE_FOR_TEMPLATES;
  /// optional SAFE_FOR_XML: boolean | undefined
  bool? get SAFE_FOR_XML;
  /// optional SANITIZE_DOM: boolean | undefined
  bool? get SANITIZE_DOM;
  /// optional SANITIZE_NAMED_PROPS: boolean | undefined
  bool? get SANITIZE_NAMED_PROPS;
  /// optional TRUSTED_TYPES_POLICY: TrustedTypePolicy | null | undefined
  Object? get TRUSTED_TYPES_POLICY;
  /// optional USE_PROFILES: false | UseProfilesConfig | undefined
  Object? get USE_PROFILES;
  /// optional WHOLE_DOCUMENT: boolean | undefined
  bool? get WHOLE_DOCUMENT;
}

/// interface UseProfilesConfig
abstract class UseProfilesConfig {
  /// optional mathMl: boolean | undefined
  bool? get mathMl;
  /// optional svg: boolean | undefined
  bool? get svg;
  /// optional svgFilters: boolean | undefined
  bool? get svgFilters;
  /// optional html: boolean | undefined
  bool? get html;
}

/// interface DOMPurify
abstract class DOMPurify {
  /// call signature: (root?: WindowLike): DOMPurify;
  DOMPurify call(WindowLike root);
  /// version: string
  String get version;
  /// removed: Array<RemovedElement | RemovedAttribute>
  List<Object?> get removed;
  /// isSupported: boolean
  bool get isSupported;
  /// setConfig(cfg?: Config): void;
  void setConfig(Config cfg);
  /// clearConfig(): void;
  void clearConfig();
  /// sanitize(dirty: string | Node, cfg: Config & { RETURN_TRUSTED_TYPE: true; }): TrustedHTML;
  Object? sanitize(Object? dirty, Object? cfg);
  /// sanitize(dirty: Node, cfg: Config & { IN_PLACE: true; }): Node;
  Object? sanitize$1(Object? dirty, Object? cfg);
  /// sanitize(dirty: string | Node, cfg: Config & { RETURN_DOM: true; }): Node;
  Object? sanitize$2(Object? dirty, Object? cfg);
  /// sanitize(dirty: string | Node, cfg: Config & { RETURN_DOM_FRAGMENT: true; }): DocumentFragment;
  Object? sanitize$3(Object? dirty, Object? cfg);
  /// sanitize(dirty: string | Node, cfg?: Config): string;
  String sanitize$4(Object? dirty, Config cfg);
  /// isValidAttribute(tag: string, attr: string, value: string): boolean;
  bool isValidAttribute(String tag, String attr, String value);
  /// addHook(entryPoint: BasicHookName, hookFunction: NodeHook): void;
  void addHook(BasicHookName entryPoint, NodeHook hookFunction);
  /// addHook(entryPoint: ElementHookName, hookFunction: ElementHook): void;
  void addHook$1(ElementHookName entryPoint, ElementHook hookFunction);
  /// addHook(entryPoint: DocumentFragmentHookName, hookFunction: DocumentFragmentHook): void;
  void addHook$2(DocumentFragmentHookName entryPoint, DocumentFragmentHook hookFunction);
  /// addHook(entryPoint: 'uponSanitizeElement', hookFunction: UponSanitizeElementHook): void;
  void addHook$3(String entryPoint, UponSanitizeElementHook hookFunction);
  /// addHook(entryPoint: 'uponSanitizeAttribute', hookFunction: UponSanitizeAttributeHook): void;
  void addHook$4(String entryPoint, UponSanitizeAttributeHook hookFunction);
  /// removeHook(entryPoint: BasicHookName, hookFunction?: NodeHook): NodeHook | undefined;
  NodeHook? removeHook(BasicHookName entryPoint, NodeHook hookFunction);
  /// removeHook(entryPoint: ElementHookName, hookFunction?: ElementHook): ElementHook | undefined;
  ElementHook? removeHook$1(ElementHookName entryPoint, ElementHook hookFunction);
  /// removeHook(entryPoint: DocumentFragmentHookName, hookFunction?: DocumentFragmentHook): DocumentFragmentHook | undefined;
  DocumentFragmentHook? removeHook$2(DocumentFragmentHookName entryPoint, DocumentFragmentHook hookFunction);
  /// removeHook(entryPoint: 'uponSanitizeElement', hookFunction?: UponSanitizeElementHook): UponSanitizeElementHook | undefined;
  UponSanitizeElementHook? removeHook$3(String entryPoint, UponSanitizeElementHook hookFunction);
  /// removeHook(entryPoint: 'uponSanitizeAttribute', hookFunction?: UponSanitizeAttributeHook): UponSanitizeAttributeHook | undefined;
  UponSanitizeAttributeHook? removeHook$4(String entryPoint, UponSanitizeAttributeHook hookFunction);
  /// removeHooks(entryPoint: HookName): void;
  void removeHooks(HookName entryPoint);
  /// removeAllHooks(): void;
  void removeAllHooks();
}

/// interface RemovedElement
abstract class RemovedElement {
  /// element: Node
  Object? get element;
}

/// interface RemovedAttribute
abstract class RemovedAttribute {
  /// attribute: Attr | null
  Object? get attribute;
  /// from: Node
  Object? get from;
}

/// interface UponSanitizeElementHookEvent
abstract class UponSanitizeElementHookEvent {
  /// tagName: string
  String get tagName;
  /// allowedTags: Record<string, boolean>
  Map<String, bool> get allowedTags;
}

/// interface UponSanitizeAttributeHookEvent
abstract class UponSanitizeAttributeHookEvent {
  /// attrName: string
  String get attrName;
  /// attrValue: string
  String get attrValue;
  /// keepAttr: boolean
  bool get keepAttr;
  /// allowedAttributes: Record<string, boolean>
  Map<String, bool> get allowedAttributes;
  /// forceKeepAttr: boolean | undefined
  bool? get forceKeepAttr;
}

/// typedef BasicHookName = 'beforeSanitizeElements' | 'afterSanitizeElements' | 'uponSanitizeShadowNode'
typedef BasicHookName = Object?;
/// typedef ElementHookName = 'beforeSanitizeAttributes' | 'afterSanitizeAttributes'
typedef ElementHookName = Object?;
/// typedef DocumentFragmentHookName = 'beforeSanitizeShadowDOM' | 'afterSanitizeShadowDOM'
typedef DocumentFragmentHookName = Object?;
/// typedef UponSanitizeElementHookName = 'uponSanitizeElement'
typedef UponSanitizeElementHookName = String;
/// typedef UponSanitizeAttributeHookName = 'uponSanitizeAttribute'
typedef UponSanitizeAttributeHookName = String;
/// typedef HookName = BasicHookName | ElementHookName | DocumentFragmentHookName | UponSanitizeElementHookName | UponSanitizeAttributeHookName
typedef HookName = Object?;
/// typedef NodeHook = (this: DOMPurify, currentNode: Node, hookEvent: null, config: Config) => void
typedef NodeHook = Object? Function(Object?);
/// typedef ElementHook = (this: DOMPurify, currentNode: Element, hookEvent: null, config: Config) => void
typedef ElementHook = Object? Function(Object?);
/// typedef DocumentFragmentHook = (this: DOMPurify, currentNode: DocumentFragment, hookEvent: null, config: Config) => void
typedef DocumentFragmentHook = Object? Function(Object?);
/// typedef UponSanitizeElementHook = (this: DOMPurify, currentNode: Node, hookEvent: UponSanitizeElementHookEvent, config: Config) => void
typedef UponSanitizeElementHook = Object? Function(Object?);
/// typedef UponSanitizeAttributeHook = (this: DOMPurify, currentNode: Element, hookEvent: UponSanitizeAttributeHookEvent, config: Config) => void
typedef UponSanitizeAttributeHook = Object? Function(Object?);
/// typedef WindowLike = Pick<typeof globalThis, 'DocumentFragment' | 'HTMLTemplateElement' | 'Node' | 'Element' | 'NodeFilter' | 'NamedNodeMap' | 'HTMLFormElement' | 'DOMParser'> & { document?: Document; MozNamedAttrMap?: typeof window.NamedNodeMap; } & Pick<TrustedTypesWindow, 'trustedTypes'>
typedef WindowLike = Object?;

/// declare const _default: DOMPurify; export { _default as default };
/// The default export is the DOMPurify interface carrier (abstract type).
typedef DompurifyDefault = DOMPurify;
