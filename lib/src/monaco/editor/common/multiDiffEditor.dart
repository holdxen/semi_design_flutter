// 1:1 port of vs/editor/common/multiDiffEditor.ts
// Runtime surface: `multiDiffEditorVariants`. All other exports are types.
import '../../base/common/uri.dart' show URI;
import '../../platform/editor/common/editor.dart' show ITextEditorOptions;
import 'core/range.dart' show IRange;

/// 1:1: `export const multiDiffEditorVariants = [...] as const`.
const List<String> multiDiffEditorVariants = <String>[
  'cards',
  'noCards',
  'noCardsNonCompact',
];

/// 1:1: `export type MultiDiffEditorVariant`.
typedef MultiDiffEditorVariant = String;

/// 1:1: `export type IMultiDiffResourceId`.
class IMultiDiffResourceId {
  IMultiDiffResourceId({this.original, this.modified});

  final URI? original;
  final URI? modified;
}

/// 1:1: `export interface IMultiDiffEditorOptionsViewState`.
class IMultiDiffEditorOptionsViewState {
  IMultiDiffEditorOptionsViewState({this.revealData});

  final IMultiDiffEditorOptionsViewStateRevealData? revealData;
}

/// 1:1: object literal inside `IMultiDiffEditorOptionsViewState.revealData`.
class IMultiDiffEditorOptionsViewStateRevealData {
  IMultiDiffEditorOptionsViewStateRevealData({
    required this.resource,
    this.range,
  });

  final IMultiDiffResourceId resource;
  final IRange? range;
}

/// 1:1: `export interface IMultiDiffEditorOptions extends ITextEditorOptions`.
class IMultiDiffEditorOptions extends ITextEditorOptions {
  IMultiDiffEditorOptions({
    super.preserveFocus,
    super.activation,
    super.forceReload,
    super.revealIfVisible,
    super.revealIfOpened,
    super.pinned,
    super.sticky,
    super.index,
    super.inactive,
    super.ignoreError,
    super.override,
    super.source,
    super.isExplicit,
    IMultiDiffEditorOptionsViewState? viewState,
    super.transient,
    super.auxiliary,
    super.modal,
    super.selection,
    super.selectionRevealType,
    super.selectionSource,
  }) : super(viewState: viewState);

  /// 1:1: `viewState?: IMultiDiffEditorOptionsViewState`.
  /// The base carrier stores `Object?`; this getter preserves the narrowed TS type.
  @override
  IMultiDiffEditorOptionsViewState? get viewState =>
      super.viewState as IMultiDiffEditorOptionsViewState?;
}
