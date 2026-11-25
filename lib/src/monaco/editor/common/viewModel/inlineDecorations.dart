// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/viewModel/inlineDecorations.ts
// Translated 1:1 from TypeScript.
//
// Adaptations (documented inline):
//  * `IModelDecoration` / `ITextModel` / `InjectedTextOptions` / visibility
//    check are erased carriers; the surface read here is declared locally.
//  * `ICoordinatesConverter` / `Range` / `Position` / `PositionAffinity` /
//    `ViewModelDecoration` are reused from the real port.
// ---------------------------------------------------------------------------

import '../core/position.dart' show Position;
import '../core/range.dart' show Range;
import '../coordinatesConverter.dart' show ICoordinatesConverter;
import '../viewModel.dart' show ViewModelDecoration;

/// 1:1: `InlineDecorationType`.
class InlineDecorationType {
  const InlineDecorationType._();
  static const int Regular = 0;
  static const int Before = 1;
  static const int After = 2;
  static const int RegularAffectingLetterSpacing = 3;
  static const int WidthOnly = 4;
}

/// 1:1: `InlineDecoration`.
class InlineDecoration {
  final Range range;
  final String inlineClassName;
  final int type;

  InlineDecoration(this.range, this.inlineClassName, this.type);
}

/// 1:1: `IViewDecorationsCollection` (opaque carrier).
class IViewDecorationsCollection {
  final List<ViewModelDecoration> decorations;
  final List<List<InlineDecoration>> inlineDecorations;
  final List<bool> hasVariableFonts;

  IViewDecorationsCollection(
    this.decorations,
    this.inlineDecorations,
    this.hasVariableFonts,
  );
}

/// 1:1: `IInlineDecorationsComputer`.
abstract class IInlineDecorationsComputer {
  List<List<InlineDecoration>> getInlineDecorations(int modelLineNumber);
}

/// 1:1: the model decoration options surface read here (opaque carrier).
abstract class IInlineModelDecorationOptions {
  String? get inlineClassName;
  bool? get inlineClassNameAffectsLetterSpacing;
  String? get beforeContentClassName;
  String? get afterContentClassName;
  bool? get affectsFont;
  bool? get isWholeLine;
  bool? get visible;
}

/// 1:1: the model decoration surface read here (opaque carrier).
abstract class IInlineModelDecoration {
  String get id;
  Range get range;
  IInlineModelDecorationOptions get options;
}

/// 1:1: `IInlineModelDecorationsComputerContext` (opaque carrier).
abstract class IInlineModelDecorationsComputerContext {
  List<IInlineModelDecoration> getModelDecorations(
    Range viewRange,
    bool onlyMinimapDecorations,
    bool onlyMarginDecorations,
  );
}

/// 1:1: the `ITextModel` surface read here (opaque carrier).
abstract class IInlineTextModel {
  int getLineMaxColumn(int lineNumber);
}

/// 1:1: `InlineModelDecorationsComputer`.
class InlineModelDecorationsComputer implements IInlineDecorationsComputer {
  final IInlineModelDecorationsComputerContext context;
  final IInlineTextModel model;
  final ICoordinatesConverter coordinatesConverter;

  /// Visibility hook (TS `isModelDecorationVisible` lives in the un-ported
  /// viewModelDecoration.ts). Default matches the common case.
  final bool Function(IInlineModelDecoration decoration) isVisible;

  Map<String, ViewModelDecoration> _decorationsCache =
      <String, ViewModelDecoration>{};

  InlineModelDecorationsComputer(
    this.context,
    this.model,
    this.coordinatesConverter, [
    bool Function(IInlineModelDecoration decoration)? isVisible,
  ]) : isVisible = isVisible ?? ((IInlineModelDecoration d) => d.options.visible != false);

  @override
  List<List<InlineDecoration>> getInlineDecorations(int modelLineNumber) {
    final Range modelRange = Range(
      modelLineNumber,
      1,
      modelLineNumber,
      model.getLineMaxColumn(modelLineNumber),
    );
    final Range viewRange =
        coordinatesConverter.convertModelRangeToViewRange(modelRange);
    final IViewDecorationsCollection data =
        getDecorations(viewRange, false, false);
    return data.inlineDecorations;
  }

  IViewDecorationsCollection getDecorations(
    Range viewRange,
    bool onlyMinimapDecorations,
    bool onlyMarginDecorations,
  ) {
    final List<IInlineModelDecoration> modelDecorations = context
        .getModelDecorations(
      viewRange,
      onlyMinimapDecorations,
      onlyMarginDecorations,
    );
    final int startLineNumber = viewRange.startLineNumber;
    final int endLineNumber = viewRange.endLineNumber;

    final List<ViewModelDecoration> decorationsInViewport =
        <ViewModelDecoration>[];
    final List<List<InlineDecoration>> inlineDecorations =
        <List<InlineDecoration>>[];
    final List<bool> hasVariableFonts = <bool>[];
    for (int j = startLineNumber; j <= endLineNumber; j++) {
      inlineDecorations.add(<InlineDecoration>[]);
      hasVariableFonts.add(false);
    }

    for (final IInlineModelDecoration modelDecoration in modelDecorations) {
      final IInlineModelDecorationOptions options = modelDecoration.options;
      if (!isVisible(modelDecoration)) continue;

      final ViewModelDecoration viewModelDecoration =
          _getOrCreateViewModelDecoration(modelDecoration);
      final Range viewRange = viewModelDecoration.range;
      decorationsInViewport.add(viewModelDecoration);

      if (options.inlineClassName != null) {
        final InlineDecoration inlineDecoration = InlineDecoration(
          viewRange,
          options.inlineClassName!,
          options.inlineClassNameAffectsLetterSpacing == true
              ? InlineDecorationType.RegularAffectingLetterSpacing
              : InlineDecorationType.Regular,
        );
        final int intersectedStartLineNumber =
            _max(startLineNumber, viewRange.startLineNumber);
        final int intersectedEndLineNumber =
            _min(endLineNumber, viewRange.endLineNumber);
        for (int j = intersectedStartLineNumber;
            j <= intersectedEndLineNumber;
            j++) {
          inlineDecorations[j - startLineNumber].add(inlineDecoration);
          if (options.affectsFont == true) {
            hasVariableFonts[j - startLineNumber] = true;
          }
        }
      }
      if (options.beforeContentClassName != null) {
        if (startLineNumber <= viewRange.startLineNumber &&
            viewRange.startLineNumber <= endLineNumber) {
          final InlineDecoration inlineDecoration = InlineDecoration(
            Range(
              viewRange.startLineNumber,
              viewRange.startColumn,
              viewRange.startLineNumber,
              viewRange.startColumn,
            ),
            options.beforeContentClassName!,
            InlineDecorationType.Before,
          );
          inlineDecorations[viewRange.startLineNumber - startLineNumber]
              .add(inlineDecoration);
          if (options.affectsFont == true) {
            hasVariableFonts[viewRange.startLineNumber - startLineNumber] = true;
          }
        }
      }
      if (options.afterContentClassName != null) {
        if (startLineNumber <= viewRange.endLineNumber &&
            viewRange.endLineNumber <= endLineNumber) {
          final InlineDecoration inlineDecoration = InlineDecoration(
            Range(
              viewRange.endLineNumber,
              viewRange.endColumn,
              viewRange.endLineNumber,
              viewRange.endColumn,
            ),
            options.afterContentClassName!,
            InlineDecorationType.After,
          );
          inlineDecorations[viewRange.endLineNumber - startLineNumber]
              .add(inlineDecoration);
          if (options.affectsFont == true) {
            hasVariableFonts[viewRange.endLineNumber - startLineNumber] = true;
          }
        }
      }
    }

    return IViewDecorationsCollection(
      decorationsInViewport,
      inlineDecorations,
      hasVariableFonts,
    );
  }

  void reset() => _decorationsCache = <String, ViewModelDecoration>{};

  void onModelDecorationsChanged() => reset();

  void onLineMappingChanged() => reset();

  ViewModelDecoration _getOrCreateViewModelDecoration(
    IInlineModelDecoration modelDecoration,
  ) {
    final String id = modelDecoration.id;
    ViewModelDecoration? r = _decorationsCache[id];
    if (r == null) {
      final Range modelRange = modelDecoration.range;
      final IInlineModelDecorationOptions options = modelDecoration.options;
      late final Range viewRange;
      if (options.isWholeLine == true) {
        final Position start = coordinatesConverter
            .convertModelPositionToViewPosition(
          Position(modelRange.startLineNumber, 1),
          affinity: null, // port: PositionAffinity constants are ints
          allowZeroLineNumber: false,
          belowHiddenRanges: true,
        );
        final Position end = coordinatesConverter
            .convertModelPositionToViewPosition(
          Position(
            modelRange.endLineNumber,
            model.getLineMaxColumn(modelRange.endLineNumber),
          ),
          affinity: null, // port: PositionAffinity constants are ints
        );
        viewRange = Range(
          start.lineNumber,
          start.column,
          end.lineNumber,
          end.column,
        );
      } else {
        viewRange = coordinatesConverter.convertModelRangeToViewRange(
          modelRange,
          affinity: null, // port: PositionAffinity constants are ints
        );
      }
      r = ViewModelDecoration(viewRange, options);
      _decorationsCache[id] = r;
    }
    return r;
  }
}

/// 1:1: `IInjectedTextInlineDecorationsComputerContext` (opaque carrier).
abstract class IInjectedTextContext {
  List<InjectedTextOptions>? getInjectionOptions(int modelLineNumber);
  List<int>? getInjectionOffsets(int modelLineNumber);
  List<int> getBreakOffsets(int modelLineNumber);
  int getWrappedTextIndentLength(int modelLineNumber);
  int getBaseViewLineNumber(int modelLineNumber);
}

/// 1:1: `InjectedTextOptions` (opaque carrier).
abstract class InjectedTextOptions {
  String get content;
  num? get widthInEm;
  String? get inlineClassName;
  bool? get inlineClassNameAffectsLetterSpacing;
}

/// 1:1: `InjectedTextInlineDecorationsComputer`.
class InjectedTextInlineDecorationsComputer
    implements IInlineDecorationsComputer {
  final IInjectedTextContext context;

  InjectedTextInlineDecorationsComputer(this.context);

  @override
  List<List<InlineDecoration>> getInlineDecorations(int modelLineNumber) {
    final List<int>? injectionOffsets =
        context.getInjectionOffsets(modelLineNumber);
    if (injectionOffsets == null) return <List<InlineDecoration>>[];

    final List<List<InlineDecoration>> lineInlineDecorations =
        <List<InlineDecoration>>[];
    int totalInjectedTextLengthBefore = 0;
    int currentInjectedOffset = 0;

    final List<InjectedTextOptions>? injectionOptions =
        context.getInjectionOptions(modelLineNumber);
    final List<int> breakOffsets = context.getBreakOffsets(modelLineNumber);

    for (int outputLineIndex = 0;
        outputLineIndex < breakOffsets.length;
        outputLineIndex++) {
      final List<InlineDecoration> inlineDecorations =
          <InlineDecoration>[];
      lineInlineDecorations.add(inlineDecorations);

      final int lineStartOffsetInInputWithInjections =
          outputLineIndex > 0 ? breakOffsets[outputLineIndex - 1] : 0;
      final int lineEndOffsetInInputWithInjections =
          breakOffsets[outputLineIndex];

      while (currentInjectedOffset < injectionOffsets.length) {
        final InjectedTextOptions options =
            injectionOptions![currentInjectedOffset];
        final int length = options.content.length;
        final int injectedTextStartOffsetInInputWithInjections =
            injectionOffsets[currentInjectedOffset] +
                totalInjectedTextLengthBefore;
        final int injectedTextEndOffsetInInputWithInjections =
            injectedTextStartOffsetInInputWithInjections + length;
        final bool isWidthOnly =
            length == 0 && options.widthInEm != null;
        final bool isLastOutputLine =
            outputLineIndex == breakOffsets.length - 1;
        final bool isAtInternalWrapBoundary =
            injectedTextStartOffsetInInputWithInjections ==
                lineEndOffsetInInputWithInjections &&
            !isLastOutputLine;

        if (injectedTextStartOffsetInInputWithInjections >
                lineEndOffsetInInputWithInjections ||
            (isWidthOnly && isAtInternalWrapBoundary)) {
          break;
        }

        final bool isInLine = isWidthOnly
            ? lineStartOffsetInInputWithInjections <=
                    injectedTextStartOffsetInInputWithInjections &&
                (injectedTextStartOffsetInInputWithInjections <
                        lineEndOffsetInInputWithInjections ||
                    isLastOutputLine)
            : lineStartOffsetInInputWithInjections <
                injectedTextEndOffsetInInputWithInjections;
        if (isInLine) {
          if (options.inlineClassName != null) {
            final int wrappedTextIndentLength =
                context.getWrappedTextIndentLength(modelLineNumber);
            final int offset = outputLineIndex > 0 ? wrappedTextIndentLength : 0;
            final int start = offset +
                _max(
                  injectedTextStartOffsetInInputWithInjections -
                      lineStartOffsetInInputWithInjections,
                  0,
                );
            final int end = offset +
                _min(
                  injectedTextEndOffsetInInputWithInjections -
                      lineStartOffsetInInputWithInjections,
                  lineEndOffsetInInputWithInjections -
                      lineStartOffsetInInputWithInjections,
                );
            if (start != end || isWidthOnly) {
              final int viewLineNumber =
                  context.getBaseViewLineNumber(modelLineNumber) +
                      outputLineIndex;
              final Range range =
                  Range(viewLineNumber, start + 1, viewLineNumber, end + 1);
              final int type = isWidthOnly
                  ? InlineDecorationType.WidthOnly
                  : options.inlineClassNameAffectsLetterSpacing == true
                      ? InlineDecorationType.RegularAffectingLetterSpacing
                      : InlineDecorationType.Regular;
              inlineDecorations.add(
                InlineDecoration(range, options.inlineClassName!, type),
              );
            }
          }
        }
        if (injectedTextEndOffsetInInputWithInjections <=
            lineEndOffsetInInputWithInjections) {
          totalInjectedTextLengthBefore += length;
          currentInjectedOffset++;
        } else {
          break;
        }
      }
    }
    return lineInlineDecorations;
  }
}

int _max(int a, int b) => a > b ? a : b;
int _min(int a, int b) => a < b ? a : b;
