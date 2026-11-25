// 1:1 port of
// vs/editor/contrib/wordHighlighter/browser/textualHighlightProvider.ts
// Erased TS types (ITextModel / languages.DocumentHighlight / provider results)
// are represented by file-local carriers. Promise-wrapped empty results are
// returned directly as empty collections (no observable difference).
// Runtime truth: tool/ts2dart/_batch268_truth.cjs (recursive TS transpile+vm).

import '../../../../base/common/cancellation.dart' show CancellationToken;
import '../../../../base/common/lifecycle.dart' show Disposable;
import '../../../../base/common/map.dart' show ResourceMap;
import '../../../../base/common/uri.dart' show URI;
import '../../../common/core/position.dart' show Position;
import '../../../common/core/range.dart' show IRange;
import '../../../common/core/wordHelper.dart'
    show IWordAtPosition, USUAL_WORD_SEPARATORS;
import '../../../common/languageSelector.dart' show LanguageFilter;
import '../../../common/languages.dart' show DocumentHighlightKind;
import '../../../common/services/languageFeaturesService.dart'
    show LanguageFeaturesService;

/// 1:1: `DocumentHighlight` (from languages.ts, erased)
class DocumentHighlight {
  final IRange range;
  final int kind;

  const DocumentHighlight(this.range, this.kind);
}

/// 1:1: match shape returned by `model.findMatches`.
abstract class IFindMatch {
  IRange get range;
}

/// 1:1: erased `ITextModel` members consumed by this provider.
abstract class ITextualHighlightModel {
  URI get uri;
  bool isDisposed();
  IWordAtPosition? getWordAtPosition(Position position);
  List<IFindMatch> findMatches(
    String word,
    bool searchOnlyEditableRange,
    bool isRegex,
    bool matchCase,
    String wordSeparators,
    bool captureMatches,
  );
}

/// 1:1: `TextualDocumentHighlightProvider`
class TextualDocumentHighlightProvider {
  LanguageFilter selector = const LanguageFilter(language: '*');

  /// 1:1: `provideDocumentHighlights(model, position, token)`
  List<DocumentHighlight>? provideDocumentHighlights(
    ITextualHighlightModel model,
    Position position,
    CancellationToken token,
  ) {
    if (model.isDisposed()) {
      return null;
    }

    final List<DocumentHighlight> result = <DocumentHighlight>[];
    final IWordAtPosition? word = model.getWordAtPosition(position);
    if (word == null) {
      return result;
    }

    final List<IFindMatch> matches = model.findMatches(
      word.word,
      true,
      false,
      true,
      USUAL_WORD_SEPARATORS,
      false,
    );
    return matches
        .map((m) => DocumentHighlight(m.range, DocumentHighlightKind.Text))
        .toList();
  }

  /// 1:1: `provideMultiDocumentHighlights(primaryModel, position, otherModels, token)`
  ResourceMap<List<DocumentHighlight>>? provideMultiDocumentHighlights(
    ITextualHighlightModel primaryModel,
    Position position,
    List<ITextualHighlightModel> otherModels,
    CancellationToken token,
  ) {
    if (primaryModel.isDisposed()) {
      return null;
    }

    final ResourceMap<List<DocumentHighlight>> result =
        ResourceMap<List<DocumentHighlight>>();
    final IWordAtPosition? word = primaryModel.getWordAtPosition(position);
    if (word == null) {
      return result;
    }

    for (final ITextualHighlightModel model in <ITextualHighlightModel>[
      primaryModel,
      ...otherModels,
    ]) {
      if (model.isDisposed()) {
        continue;
      }
      final List<IFindMatch> matches = model.findMatches(
        word.word,
        true,
        false,
        true,
        USUAL_WORD_SEPARATORS,
        false,
      );
      final List<DocumentHighlight> highlights = matches
          .map((m) => DocumentHighlight(m.range, DocumentHighlightKind.Text))
          .toList();
      result.set(model.uri, highlights);
    }

    return result;
  }
}

/// 1:1: `TextualMultiDocumentHighlightFeature extends Disposable`
class TextualMultiDocumentHighlightFeature extends Disposable {
  TextualMultiDocumentHighlightFeature(
    LanguageFeaturesService languageFeaturesService,
  ) : super() {
    register(languageFeaturesService.documentHighlightProvider.register(
        '*', TextualDocumentHighlightProvider()));
    register(languageFeaturesService.multiDocumentHighlightProvider.register(
        '*', TextualDocumentHighlightProvider()));
  }
}
