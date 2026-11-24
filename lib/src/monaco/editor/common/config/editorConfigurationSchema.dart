// ---------------------------------------------------------------------------
// 1:1 port of vscode/src/vs/editor/common/config/editorConfigurationSchema.ts
// (387 lines, whole file). Do not refactor.
//
// Adaptations (documented inline):
//   - `Object.freeze<IConfigurationNode>(...)` -> a module-level `final`
//     [editorConfigurationBaseNode]; Dart has no runtime object freezing.
//   - `IStringDictionary<IConfigurationPropertySchema>` -> `Map<String,
//     IConfigurationPropertySchema>` (IStringDictionary<T> is a typedef for
//     Map<String, T> in this port).
//   - `IConfigurationPropertySchema` is a typedef for `Map<String, Object?>`;
//     the TS union `IConfigurationPropertySchema | { [path]: ... }` collapses
//     to that single Map type, so `isConfigurationPropertySchema` checks the
//     presence of `type`/`anyOf` keys (the TS `typeof !== 'undefined'` guard).
//   - `editorOptionsRegistry` is a sparse `List<IEditorOption<Object?>?>`;
//     the injection loop skips null holes (Dart has no sparse arrays).
//   - The TS `const editorConfiguration` is module-private; here it is a
//     public top-level getter so the replay test can observe the fully built
//     node (including registry-injected properties and registration mutations).
//   - `Registry.as<IConfigurationRegistry>(Extensions.Configuration)` ->
//     `Registry.as(Extensions.Configuration)` with the same fallback used by
//     `configurations.dart` / `extensionManagement.dart`: Dart lazily
//     initializes module-level variables, so the registry's own registration
//     hook may not have run yet; fall back to its global singleton.
// ---------------------------------------------------------------------------

import '../../../base/common/jsonSchema.dart' show IJSONSchemaSnippet;
import '../../../nls.dart' show localize;
import '../../../platform/configuration/common/configurationRegistry.dart'
    show
        ConfigurationScope,
        Extensions,
        IConfigurationNode,
        IConfigurationPropertySchema,
        IConfigurationRegistryType;
import '../../../platform/configuration/common/configurationRegistry.dart'
    as configuration_registry show configurationRegistry;
import '../../../platform/registry/common/platform.dart' show Registry;
import '../core/misc/textModelDefaults.dart' show EDITOR_MODEL_DEFAULTS;
import 'diffEditor.dart'
    show
        DiffEditorExperimentalOptions,
        DiffEditorHideUnchangedRegionsOptions,
        diffEditorDefaultOptions;
import 'editorOptions.dart'
    show EditorOptions, IEditorOption, editorOptionsRegistry;

/// 1:1: `export const editorConfigurationBaseNode = Object.freeze<...>(...)`.
///
/// The reference is `final`; the node itself cannot be reassigned. (Dart has
/// no `Object.freeze` equivalent for mutable interface classes.)
final IConfigurationNode editorConfigurationBaseNode = IConfigurationNode(
  id: 'editor',
  order: 5,
  type: 'object',
  title: localize('editorConfigurationTitle', 'Editor'),
  scope: ConfigurationScope.LANGUAGE_OVERRIDABLE,
);

/// 1:1: `function isConfigurationPropertySchema(x): x is ...`.
///
/// TS checks `typeof x.type !== 'undefined' || typeof x.anyOf !== 'undefined'`;
/// `containsKey` is the faithful mapping (a present key with a `null` value
/// still counts as "defined", matching `typeof null === 'object'` in JS).
bool isConfigurationPropertySchema(Map<String, Object?> x) =>
    x.containsKey('type') || x.containsKey('anyOf');

/// Dart adaptation: the TS source populates `editorOptionsRegistry` with 180
/// top-level `register(...)` calls at module load. The port moved those into
/// `static final` fields of [EditorOptions], which Dart initializes lazily on
/// first read. Reading them all here forces the sparse registry to be fully
/// populated before the injection loop runs (matching TS load order).
void _forceEditorOptionsRegistryInitialization() {
  final List<Object?> _ = <Object?>[
    EditorOptions.acceptSuggestionOnCommitCharacter, EditorOptions.acceptSuggestionOnEnter, EditorOptions.accessibilitySupport, EditorOptions.accessibilityPageSize,
    EditorOptions.allowOverflow, EditorOptions.allowVariableLineHeights, EditorOptions.allowVariableFonts, EditorOptions.allowVariableFontsInAccessibilityMode,
    EditorOptions.ariaLabel, EditorOptions.ariaRequired, EditorOptions.screenReaderAnnounceInlineSuggestion, EditorOptions.autoClosingBrackets,
    EditorOptions.autoClosingComments, EditorOptions.autoClosingDelete, EditorOptions.autoClosingOvertype, EditorOptions.autoClosingQuotes,
    EditorOptions.autoIndent, EditorOptions.autoIndentOnPaste, EditorOptions.autoIndentOnPasteWithinString, EditorOptions.automaticLayout,
    EditorOptions.autoSurround, EditorOptions.bracketPairColorization, EditorOptions.bracketPairGuides, EditorOptions.stickyTabStops,
    EditorOptions.codeLens, EditorOptions.codeLensFontFamily, EditorOptions.codeLensFontSize, EditorOptions.colorDecorators,
    EditorOptions.colorDecoratorActivatedOn, EditorOptions.colorDecoratorsLimit, EditorOptions.columnSelection, EditorOptions.comments,
    EditorOptions.contextmenu, EditorOptions.copyWithSyntaxHighlighting, EditorOptions.cursorBlinking, EditorOptions.cursorSmoothCaretAnimation,
    EditorOptions.cursorStyle, EditorOptions.overtypeCursorStyle, EditorOptions.cursorSurroundingLines, EditorOptions.cursorSurroundingLinesStyle,
    EditorOptions.cursorWidth, EditorOptions.cursorHeight, EditorOptions.disableLayerHinting, EditorOptions.disableMonospaceOptimizations,
    EditorOptions.domReadOnly, EditorOptions.doubleClickSelectsBlock, EditorOptions.dragAndDrop, EditorOptions.emptySelectionClipboard,
    EditorOptions.dropIntoEditor, EditorOptions.editContext, EditorOptions.renderRichScreenReaderContent, EditorOptions.stickyScroll,
    EditorOptions.experimentalGpuAcceleration, EditorOptions.experimentalWhitespaceRendering, EditorOptions.extraEditorClassName, EditorOptions.fastScrollSensitivity,
    EditorOptions.find, EditorOptions.fixedOverflowWidgets, EditorOptions.folding, EditorOptions.foldingStrategy,
    EditorOptions.foldingHighlight, EditorOptions.foldingImportsByDefault, EditorOptions.foldingMaximumRegions, EditorOptions.unfoldOnClickAfterEndOfLine,
    EditorOptions.fontFamily, EditorOptions.fontInfo, EditorOptions.fontLigatures2, EditorOptions.fontSize,
    EditorOptions.fontWeight, EditorOptions.fontVariations, EditorOptions.formatOnPaste, EditorOptions.formatOnType,
    EditorOptions.fullwidthCharacterWidth, EditorOptions.glyphMargin, EditorOptions.gotoLocation, EditorOptions.hideCursorInOverviewRuler,
    EditorOptions.hover, EditorOptions.inDiffEditor, EditorOptions.inertialScroll, EditorOptions.letterSpacing,
    EditorOptions.lightbulb, EditorOptions.lineDecorationsWidth, EditorOptions.lineHeight, EditorOptions.lineNumbers,
    EditorOptions.lineNumbersMinChars, EditorOptions.linkedEditing, EditorOptions.links, EditorOptions.markdownImages,
    EditorOptions.matchBrackets, EditorOptions.minimap, EditorOptions.mouseStyle, EditorOptions.mouseWheelScrollSensitivity,
    EditorOptions.mouseWheelZoom, EditorOptions.multiCursorMergeOverlapping, EditorOptions.multiCursorModifier, EditorOptions.mouseMiddleClickAction,
    EditorOptions.multiCursorPaste, EditorOptions.multiCursorLimit, EditorOptions.occurrencesHighlight, EditorOptions.occurrencesHighlightDelay,
    EditorOptions.occurrencesHighlightFromAllProviders, EditorOptions.overtypeOnPaste, EditorOptions.overviewRulerBorder, EditorOptions.overviewRulerLanes,
    EditorOptions.padding, EditorOptions.pasteAs, EditorOptions.parameterHints, EditorOptions.peekWidgetDefaultFocus,
    EditorOptions.placeholder, EditorOptions.definitionLinkOpensInPeek, EditorOptions.quickSuggestions, EditorOptions.quickSuggestionsDelay,
    EditorOptions.readOnly, EditorOptions.readOnlyMessage, EditorOptions.renameOnType, EditorOptions.renderControlCharacters,
    EditorOptions.renderFinalNewline, EditorOptions.renderLineHighlight, EditorOptions.renderLineHighlightOnlyWhenFocus, EditorOptions.renderValidationDecorations,
    EditorOptions.renderWhitespace, EditorOptions.revealHorizontalRightPadding, EditorOptions.roundedSelection, EditorOptions.rulers,
    EditorOptions.scrollbar, EditorOptions.scrollBeyondLastColumn, EditorOptions.scrollBeyondLastLine, EditorOptions.scrollOnMiddleClick,
    EditorOptions.scrollPredominantAxis, EditorOptions.selectionClipboard, EditorOptions.selectionHighlight, EditorOptions.selectionHighlightMaxLength,
    EditorOptions.selectionHighlightMultiline, EditorOptions.selectedTextMatchMode, EditorOptions.selectOnLineNumbers, EditorOptions.showFoldingControls,
    EditorOptions.showUnused, EditorOptions.showDeprecated, EditorOptions.inlayHints, EditorOptions.snippetSuggestions,
    EditorOptions.smartSelect, EditorOptions.smoothScrolling, EditorOptions.stopRenderingLineAfter, EditorOptions.suggest,
    EditorOptions.inlineSuggest, EditorOptions.inlineCompletionsAccessibilityVerbose, EditorOptions.suggestFontSize, EditorOptions.suggestLineHeight,
    EditorOptions.suggestOnTriggerCharacters, EditorOptions.suggestSelection, EditorOptions.tabCompletion, EditorOptions.tabIndex,
    EditorOptions.trimWhitespaceOnDelete, EditorOptions.unicodeHighlight, EditorOptions.unusualLineTerminators, EditorOptions.useShadowDOM,
    EditorOptions.useTabStops, EditorOptions.wordBreak, EditorOptions.wordSegmenterLocales, EditorOptions.wordSeparators,
    EditorOptions.wordWrap, EditorOptions.wordWrapIndicator, EditorOptions.wordWrapBreakAfterCharacters, EditorOptions.wordWrapBreakBeforeCharacters,
    EditorOptions.wordWrapColumn, EditorOptions.wordWrapOverride1, EditorOptions.wordWrapOverride2, EditorOptions.wrapOnEscapedLineFeeds,
    EditorOptions.effectiveCursorStyle, EditorOptions.editorClassName, EditorOptions.defaultColorDecorators, EditorOptions.pixelRatio,
    EditorOptions.tabFocusMode, EditorOptions.layoutInfo, EditorOptions.wrappingInfo, EditorOptions.wrappingIndent,
    EditorOptions.wrappingStrategy, EditorOptions.effectiveEditContextEnabled, EditorOptions.effectiveAllowVariableFonts, EditorOptions.effectiveFullwidthCharacterWidth,
  ];
}

/// Builds the module-level `editorConfiguration`, mirroring the TS source
/// execution order: object literal -> registry-injection loop ->
/// `configurationRegistry.registerConfiguration(editorConfiguration)`.
IConfigurationNode _buildEditorConfiguration() {
  _forceEditorOptionsRegistryInitialization();

  // TS reads nested object literals of `diffEditorDefaultOptions` directly.
  final DiffEditorHideUnchangedRegionsOptions hideUnchanged =
      diffEditorDefaultOptions.hideUnchangedRegions
          as DiffEditorHideUnchangedRegionsOptions;
  final DiffEditorExperimentalOptions experimental =
      diffEditorDefaultOptions.experimental as DiffEditorExperimentalOptions;

  final Map<String, IConfigurationPropertySchema> properties =
      <String, IConfigurationPropertySchema>{
    'editor.tabSize': <String, Object?>{
      'type': 'number',
      'default': EDITOR_MODEL_DEFAULTS['tabSize'],
      'minimum': 1,
      'maximum': 100,
      'markdownDescription': localize(
        'tabSize',
        'The number of spaces a tab is equal to. This setting is overridden based on the file contents when {0} is on.',
        <Object?>['`#editor.detectIndentation#`'],
      ),
    },
    'editor.indentSize': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'enum': <Object?>['tabSize'],
        },
        <String, Object?>{
          'type': 'number',
          'minimum': 1,
        },
      ],
      'default': 'tabSize',
      'markdownDescription': localize(
        'indentSize',
        'The number of spaces used for indentation or `"tabSize"` to use the value from `#editor.tabSize#`. This setting is overridden based on the file contents when `#editor.detectIndentation#` is on.',
      ),
    },
    'editor.insertSpaces': <String, Object?>{
      'type': 'boolean',
      'default': EDITOR_MODEL_DEFAULTS['insertSpaces'],
      'markdownDescription': localize(
        'insertSpaces',
        'Insert spaces when pressing `Tab`. This setting is overridden based on the file contents when {0} is on.',
        <Object?>['`#editor.detectIndentation#`'],
      ),
    },
    'editor.detectIndentation': <String, Object?>{
      'type': 'boolean',
      'default': EDITOR_MODEL_DEFAULTS['detectIndentation'],
      'markdownDescription': localize(
        'detectIndentation',
        'Controls whether {0} and {1} will be automatically detected when a file is opened based on the file contents.',
        <Object?>['`#editor.tabSize#`', '`#editor.insertSpaces#`'],
      ),
    },
    'editor.trimAutoWhitespace': <String, Object?>{
      'type': 'boolean',
      'default': EDITOR_MODEL_DEFAULTS['trimAutoWhitespace'],
      'description': localize(
          'trimAutoWhitespace', 'Remove trailing auto inserted whitespace.'),
    },
    'editor.largeFileOptimizations': <String, Object?>{
      'type': 'boolean',
      'default': EDITOR_MODEL_DEFAULTS['largeFileOptimizations'],
      'description': localize(
        'largeFileOptimizations',
        'Special handling for large files to disable certain memory intensive features.',
      ),
    },
    'editor.wordBasedSuggestions': <String, Object?>{
      'enum': <Object?>[
        'off',
        'offWithInlineSuggestions',
        'currentDocument',
        'matchingDocuments',
        'allDocuments',
      ],
      'default': 'offWithInlineSuggestions',
      'enumDescriptions': <Object?>[
        localize('wordBasedSuggestions.off', 'Turn off Word Based Suggestions.'),
        localize(
          'wordBasedSuggestions.offWithInlineSuggestions',
          'Turn off Word Based Suggestions when Inline Suggestions are present.',
        ),
        localize(
          'wordBasedSuggestions.currentDocument',
          'Only suggest words from the active document.',
        ),
        localize(
          'wordBasedSuggestions.matchingDocuments',
          'Suggest words from all open documents of the same language.',
        ),
        localize(
          'wordBasedSuggestions.allDocuments',
          'Suggest words from all open documents.',
        ),
      ],
      'description': localize(
        'wordBasedSuggestions',
        'Controls whether completions should be computed based on words in the document and from which documents they are computed.',
      ),
      'experiment': <String, Object?>{'mode': 'auto'},
    },
    'editor.semanticHighlighting.enabled': <String, Object?>{
      'enum': <Object?>[true, false, 'configuredByTheme'],
      'enumDescriptions': <Object?>[
        localize('semanticHighlighting.true',
            'Semantic highlighting enabled for all color themes.'),
        localize('semanticHighlighting.false',
            'Semantic highlighting disabled for all color themes.'),
        localize(
          'semanticHighlighting.configuredByTheme',
          'Semantic highlighting is configured by the current color theme\'s `semanticHighlighting` setting.',
        ),
      ],
      'default': 'configuredByTheme',
      'description': localize(
        'semanticHighlighting.enabled',
        'Controls whether the semanticHighlighting is shown for the languages that support it.',
      ),
    },
    'editor.stablePeek': <String, Object?>{
      'type': 'boolean',
      'default': false,
      'markdownDescription': localize(
        'stablePeek',
        'Keep peek editors open even when double-clicking their content or when hitting `Escape`.',
      ),
    },
    'editor.maxTokenizationLineLength': <String, Object?>{
      'type': 'integer',
      'default': 20_000,
      'description': localize(
        'maxTokenizationLineLength',
        'Lines above this length will not be tokenized for performance reasons',
      ),
    },
    'editor.experimental.asyncTokenization': <String, Object?>{
      'type': 'boolean',
      'default': true,
      'description': localize(
        'editor.experimental.asyncTokenization',
        'Controls whether the tokenization should happen asynchronously on a web worker.',
      ),
      'tags': <Object?>['experimental'],
    },
    'editor.experimental.asyncTokenizationLogging': <String, Object?>{
      'type': 'boolean',
      'default': false,
      'description': localize(
        'editor.experimental.asyncTokenizationLogging',
        'Controls whether async tokenization should be logged. For debugging only.',
      ),
    },
    'editor.experimental.asyncTokenizationVerification': <String, Object?>{
      'type': 'boolean',
      'default': false,
      'description': localize(
        'editor.experimental.asyncTokenizationVerification',
        'Controls whether async tokenization should be verified against legacy background tokenization. Might slow down tokenization. For debugging only.',
      ),
      'tags': <Object?>['experimental'],
    },
    'editor.experimental.treeSitterTelemetry': <String, Object?>{
      'type': 'boolean',
      'default': false,
      'markdownDescription': localize(
        'editor.experimental.treeSitterTelemetry',
        'Controls whether tree sitter parsing should be turned on and telemetry collected. Setting `#editor.experimental.preferTreeSitter#` for specific languages will take precedence.',
      ),
      'tags': <Object?>['experimental'],
      'experiment': <String, Object?>{'mode': 'auto'},
    },
    'editor.experimental.preferTreeSitter.css': <String, Object?>{
      'type': 'boolean',
      'default': false,
      'markdownDescription': localize(
        'editor.experimental.preferTreeSitter.css',
        'Controls whether tree sitter parsing should be turned on for css. This will take precedence over `#editor.experimental.treeSitterTelemetry#` for css.',
      ),
      'tags': <Object?>['experimental'],
      'experiment': <String, Object?>{'mode': 'auto'},
    },
    'editor.experimental.preferTreeSitter.typescript': <String, Object?>{
      'type': 'boolean',
      'default': false,
      'markdownDescription': localize(
        'editor.experimental.preferTreeSitter.typescript',
        'Controls whether tree sitter parsing should be turned on for typescript. This will take precedence over `#editor.experimental.treeSitterTelemetry#` for typescript.',
      ),
      'tags': <Object?>['experimental'],
      'experiment': <String, Object?>{'mode': 'auto'},
    },
    'editor.experimental.preferTreeSitter.ini': <String, Object?>{
      'type': 'boolean',
      'default': false,
      'markdownDescription': localize(
        'editor.experimental.preferTreeSitter.ini',
        'Controls whether tree sitter parsing should be turned on for ini. This will take precedence over `#editor.experimental.treeSitterTelemetry#` for ini.',
      ),
      'tags': <Object?>['experimental'],
      'experiment': <String, Object?>{'mode': 'auto'},
    },
    'editor.experimental.preferTreeSitter.regex': <String, Object?>{
      'type': 'boolean',
      'default': false,
      'markdownDescription': localize(
        'editor.experimental.preferTreeSitter.regex',
        'Controls whether tree sitter parsing should be turned on for regex. This will take precedence over `#editor.experimental.treeSitterTelemetry#` for regex.',
      ),
      'tags': <Object?>['experimental'],
      'experiment': <String, Object?>{'mode': 'auto'},
    },
    'editor.language.brackets': <String, Object?>{
      'type': <Object?>['array', 'null'],
      'default': null, // Distinguish empty array from not configured.
      'description': localize('schema.brackets',
          'Defines the bracket symbols that increase or decrease the indentation.'),
      'items': <String, Object?>{
        'type': 'array',
        'items': <Object?>[
          <String, Object?>{
            'type': 'string',
            'description': localize('schema.openBracket',
                'The opening bracket character or string sequence.'),
          },
          <String, Object?>{
            'type': 'string',
            'description': localize('schema.closeBracket',
                'The closing bracket character or string sequence.'),
          },
        ],
      },
    },
    'editor.language.colorizedBracketPairs': <String, Object?>{
      'type': <Object?>['array', 'null'],
      'default': null,
      'description': localize(
        'schema.colorizedBracketPairs',
        'Defines the bracket pairs that are colorized by their nesting level if bracket pair colorization is enabled.',
      ),
      'items': <String, Object?>{
        'type': 'array',
        'items': <Object?>[
          <String, Object?>{
            'type': 'string',
            'description': localize('schema.openBracket',
                'The opening bracket character or string sequence.'),
          },
          <String, Object?>{
            'type': 'string',
            'description': localize('schema.closeBracket',
                'The closing bracket character or string sequence.'),
          },
        ],
      },
    },
    'diffEditor.maxComputationTime': <String, Object?>{
      'type': 'number',
      'default': diffEditorDefaultOptions.maxComputationTime,
      'description': localize(
        'maxComputationTime',
        'Timeout in milliseconds after which diff computation is cancelled. Use 0 for no timeout.',
      ),
    },
    'diffEditor.maxFileSize': <String, Object?>{
      'type': 'number',
      'default': diffEditorDefaultOptions.maxFileSize,
      'description': localize('maxFileSize',
          'Maximum file size in MB for which to compute diffs. Use 0 for no limit.'),
    },
    'diffEditor.renderSideBySide': <String, Object?>{
      'type': 'boolean',
      'default': diffEditorDefaultOptions.renderSideBySide,
      'description': localize('sideBySide',
          'Controls whether the diff editor shows the diff side by side or inline.'),
      'agentsWindow': <String, Object?>{'default': true},
    },
    'diffEditor.renderSideBySideInlineBreakpoint': <String, Object?>{
      'type': 'number',
      'default': diffEditorDefaultOptions.renderSideBySideInlineBreakpoint,
      'description': localize(
        'renderSideBySideInlineBreakpoint',
        'If the diff editor width is smaller than this value, the inline view is used.',
      ),
    },
    'diffEditor.useInlineViewWhenSpaceIsLimited': <String, Object?>{
      'type': 'boolean',
      'default': diffEditorDefaultOptions.useInlineViewWhenSpaceIsLimited,
      'description': localize('useInlineViewWhenSpaceIsLimited',
          'If enabled and the editor width is too small, the inline view is used.'),
      'agentsWindow': <String, Object?>{'default': true},
    },
    'diffEditor.hideOriginalLineNumbers': <String, Object?>{
      'type': <Object?>['boolean', 'null'],
      'default': null,
      'description': localize(
        'hideOriginalLineNumbers',
        "Controls whether original line numbers are hidden in inline diffs. When set to null, uses the editor's default: hidden in compact multi diff editors and visible in other diff editors.",
      ),
    },
    'diffEditor.renderMarginRevertIcon': <String, Object?>{
      'type': 'boolean',
      'default': diffEditorDefaultOptions.renderMarginRevertIcon,
      'description': localize('renderMarginRevertIcon',
          'When enabled, the diff editor shows arrows in its glyph margin to revert changes.'),
      'agentsWindow': <String, Object?>{'default': false},
    },
    'diffEditor.renderGutterMenu': <String, Object?>{
      'type': 'boolean',
      'default': diffEditorDefaultOptions.renderGutterMenu,
      'description': localize('renderGutterMenu',
          'When enabled, the diff editor shows a special gutter for revert and stage actions.'),
      'agentsWindow': <String, Object?>{'default': false},
    },
    'diffEditor.ignoreTrimWhitespace': <String, Object?>{
      'type': 'boolean',
      'default': diffEditorDefaultOptions.ignoreTrimWhitespace,
      'description': localize('ignoreTrimWhitespace',
          'When enabled, the diff editor ignores changes in leading or trailing whitespace.'),
    },
    'diffEditor.renderIndicators': <String, Object?>{
      'type': 'boolean',
      'default': diffEditorDefaultOptions.renderIndicators,
      'description': localize('renderIndicators',
          'Controls whether the diff editor shows +/- indicators for added/removed changes.'),
      'agentsWindow': <String, Object?>{'default': false},
    },
    'diffEditor.codeLens': <String, Object?>{
      'type': 'boolean',
      'default': diffEditorDefaultOptions.diffCodeLens,
      'description': localize('codeLens', 'Controls whether the editor shows CodeLens.'),
    },
    'diffEditor.wordWrap': <String, Object?>{
      'type': 'string',
      'enum': <Object?>['off', 'on', 'inherit'],
      'default': diffEditorDefaultOptions.diffWordWrap,
      'markdownEnumDescriptions': <Object?>[
        localize('wordWrap.off', 'Lines will never wrap.'),
        localize('wordWrap.on', 'Lines will wrap at the viewport width.'),
        localize(
          'wordWrap.inherit',
          'Lines will wrap according to the {0} setting.',
          <Object?>['`#editor.wordWrap#`'],
        ),
      ],
    },
    'diffEditor.diffAlgorithm': <String, Object?>{
      'type': 'string',
      'enum': <Object?>['legacy', 'advanced', 'advanced-external', 'advanced-wasm'],
      'default': diffEditorDefaultOptions.diffAlgorithm,
      'markdownEnumDescriptions': <Object?>[
        localize('diffAlgorithm.legacy', 'Uses the legacy diffing algorithm.'),
        localize('diffAlgorithm.advanced', 'Uses the advanced diffing algorithm.'),
        localize(
          'diffAlgorithm.advancedExternal',
          'Uses the advanced diffing algorithm from the external `@vscode/diff` package (pure JavaScript).',
        ),
        localize(
          'diffAlgorithm.advancedWasm',
          'Uses the advanced diffing algorithm from the external `@vscode/diff` package (WebAssembly).',
        ),
      ],
      'experiment': <String, Object?>{'mode': 'startup'},
    },
    'diffEditor.experimental.verifyDiffSampleRate': <String, Object?>{
      'type': 'number',
      'default': 0,
      'minimum': 0,
      'maximum': 1,
      'description': localize(
        'diffEditor.experimental.verifyDiffSampleRate',
        'The probability (from 0 to 1) that a computed diff is checked for correctness and the result is reported in telemetry.',
      ),
      'included': false,
      'tags': <Object?>['experimental'],
      'experiment': <String, Object?>{'mode': 'auto'},
    },
    'diffEditor.hideUnchangedRegions.enabled': <String, Object?>{
      'type': 'boolean',
      'default': hideUnchanged.enabled,
      'markdownDescription': localize('hideUnchangedRegions.enabled',
          'Controls whether the diff editor shows unchanged regions.'),
      'agentsWindow': <String, Object?>{'default': true},
    },
    'diffEditor.hideUnchangedRegions.revealLineCount': <String, Object?>{
      'type': 'integer',
      'default': hideUnchanged.revealLineCount,
      'markdownDescription': localize('hideUnchangedRegions.revealLineCount',
          'Controls how many lines are used for unchanged regions.'),
      'minimum': 1,
    },
    'diffEditor.hideUnchangedRegions.minimumLineCount': <String, Object?>{
      'type': 'integer',
      'default': hideUnchanged.minimumLineCount,
      'markdownDescription': localize('hideUnchangedRegions.minimumLineCount',
          'Controls how many lines are used as a minimum for unchanged regions.'),
      'minimum': 1,
    },
    'diffEditor.hideUnchangedRegions.contextLineCount': <String, Object?>{
      'type': 'integer',
      'default': hideUnchanged.contextLineCount,
      'markdownDescription': localize('hideUnchangedRegions.contextLineCount',
          'Controls how many lines are used as context when comparing unchanged regions.'),
      'minimum': 1,
    },
    'diffEditor.experimental.showMoves': <String, Object?>{
      'type': 'boolean',
      'default': experimental.showMoves,
      'markdownDescription': localize(
          'showMoves', 'Controls whether the diff editor should show detected code moves.'),
    },
    'diffEditor.experimental.showEmptyDecorations': <String, Object?>{
      'type': 'boolean',
      'default': experimental.showEmptyDecorations,
      'description': localize(
        'showEmptyDecorations',
        'Controls whether the diff editor shows empty decorations to see where characters got inserted or deleted.',
      ),
    },
    'diffEditor.experimental.useTrueInlineView': <String, Object?>{
      'type': 'boolean',
      'default': experimental.useTrueInlineView,
      'description': localize('useTrueInlineView',
          'If enabled and the editor uses the inline view, word changes are rendered inline.'),
    },
  };

  // 1:1: `const editorConfiguration: IConfigurationNode = { ...baseNode,
  // properties }`. The spread copies every base-node field.
  final IConfigurationNode configuration = IConfigurationNode(
    id: editorConfigurationBaseNode.id,
    order: editorConfigurationBaseNode.order,
    type: editorConfigurationBaseNode.type,
    title: editorConfigurationBaseNode.title,
    description: editorConfigurationBaseNode.description,
    properties: properties,
    allOf: editorConfigurationBaseNode.allOf,
    scope: editorConfigurationBaseNode.scope,
    extensionInfo: editorConfigurationBaseNode.extensionInfo,
    restrictedProperties: editorConfigurationBaseNode.restrictedProperties,
  );

  // 1:1: `for (const editorOption of editorOptionsRegistry) { ... }`.
  // The Dart registry is a sparse list; null holes are skipped.
  for (final IEditorOption<Object?>? editorOption in editorOptionsRegistry) {
    if (editorOption == null) continue;
    final IConfigurationPropertySchema? schema = editorOption.schema;
    if (schema != null) {
      if (isConfigurationPropertySchema(schema)) {
        // This is a single schema contribution.
        properties['editor.${editorOption.name}'] = schema;
      } else {
        // A multi-property schema map: copy each own key.
        for (final MapEntry<String, Object?> entry in schema.entries) {
          properties[entry.key] = entry.value as IConfigurationPropertySchema;
        }
      }
    }
  }

  // 1:1: `Registry.as<IConfigurationRegistry>(Extensions.Configuration)
  //        .registerConfiguration(editorConfiguration);`
  final Object? registered = Registry.as(Extensions.Configuration);
  final IConfigurationRegistryType registry =
      registered is IConfigurationRegistryType
          ? registered
          : configuration_registry.configurationRegistry;
  registry.registerConfiguration(configuration);

  return configuration;
}

/// 1:1: `const editorConfiguration: IConfigurationNode` (module-private in TS,
/// exposed here for the replay test). Built once, lazily, at first access.
final IConfigurationNode editorConfiguration = _buildEditorConfiguration();

/// 1:1: `let cachedEditorConfigurationKeys: { [key: string]: boolean } | null`.
///
/// `Object.create(null)` semantics -> a plain `Map<String, bool>`.
Map<String, bool>? _cachedEditorConfigurationKeys;

/// 1:1: `function getEditorConfigurationKeys()`.
Map<String, bool> getEditorConfigurationKeys() {
  final Map<String, bool>? cached = _cachedEditorConfigurationKeys;
  if (cached != null) return cached;
  final Map<String, bool> keys = <String, bool>{};
  for (final String prop in editorConfiguration.properties!.keys) {
    keys[prop] = true;
  }
  _cachedEditorConfigurationKeys = keys;
  return keys;
}

/// 1:1: `export function isEditorConfigurationKey(key: string): boolean`.
bool isEditorConfigurationKey(String key) =>
    getEditorConfigurationKeys()['editor.$key'] ?? false;

/// 1:1: `export function isDiffEditorConfigurationKey(key: string): boolean`.
bool isDiffEditorConfigurationKey(String key) =>
    getEditorConfigurationKeys()['diffEditor.$key'] ?? false;

/// 1:1: `export async function registerEditorFontConfigurations` with the
/// TS parameter `getFontSnippets: () => Promise<IJSONSchemaSnippet[]>`.
Future<void> registerEditorFontConfigurations(
  Future<List<IJSONSchemaSnippet>> Function() getFontSnippets,
) async {
  const List<String> editorKeysWithFont = <String>['editor.fontFamily'];
  final List<IJSONSchemaSnippet> fontSnippets = await getFontSnippets();
  for (final String key in editorKeysWithFont) {
    final Map<String, IConfigurationPropertySchema>? properties =
        editorConfiguration.properties;
    if (properties != null && properties[key] != null) {
      properties[key]!['defaultSnippets'] = fontSnippets;
    }
  }
}
