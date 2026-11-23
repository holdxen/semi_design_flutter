// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/model/tokens/annotations.ts
// Translated 1:1 from TypeScript. TS interfaces -> abstract classes/carriers,
// generic `T | undefined` -> nullable `T?`, `binarySearch2` ported as-is,
// `Array.splice/slice/shift/unshift` -> Dart List operations.
// ---------------------------------------------------------------------------

import '../../../../base/common/arrays.dart' as arrays;
import '../../core/edits/stringEdit.dart' show StringEdit, StringReplacement;
import '../../core/ranges/offsetRange.dart' show OffsetRange;

/// 1:1: `export interface IAnnotation<T>`
class IAnnotation<T> {
  OffsetRange range;
  T annotation;

  IAnnotation(this.range, this.annotation);
}

/// 1:1: `export interface IAnnotatedString<T>`
abstract class IAnnotatedString<T> {
  void setAnnotations(AnnotationsUpdate<T> annotations);

  List<IAnnotation<T>> getAnnotationsIntersecting(OffsetRange range);

  List<IAnnotation<T>> getAllAnnotations();

  List<IAnnotation<T>> applyEdit(StringEdit edit);

  IAnnotatedString<T> clone();
}

/// 1:1: `export class AnnotatedString<T> implements IAnnotatedString<T>`
class AnnotatedString<T> implements IAnnotatedString<T> {
  /// Annotations are non intersecting and contiguous in the array.
  List<IAnnotation<T>> _annotations;

  AnnotatedString([List<IAnnotation<T>>? annotations])
      : _annotations = annotations ?? <IAnnotation<T>>[];

  @override
  void setAnnotations(AnnotationsUpdate<T> annotationsUpdate) {
    for (final IAnnotationUpdate<T> annotation
        in annotationsUpdate.annotations) {
      final int startIndex =
          _getStartIndexOfIntersectingAnnotation(annotation.range.start);
      final int endIndexExclusive =
          _getEndIndexOfIntersectingAnnotation(annotation.range.endExclusive);
      if (annotation.annotation != null) {
        _annotations.setRange(
            startIndex,
            endIndexExclusive,
            <IAnnotation<T>>[
              IAnnotation<T>(annotation.range, annotation.annotation!)
            ]);
      } else {
        _annotations.removeRange(startIndex, endIndexExclusive);
      }
    }
  }

  @override
  List<IAnnotation<T>> getAnnotationsIntersecting(OffsetRange range) {
    final int startIndex =
        _getStartIndexOfIntersectingAnnotation(range.start);
    final int endIndexExclusive =
        _getEndIndexOfIntersectingAnnotation(range.endExclusive);
    return _annotations.sublist(startIndex, endIndexExclusive);
  }

  int _getStartIndexOfIntersectingAnnotation(int offset) {
    final int startIndexWhereToReplace = arrays.binarySearch2(
        _annotations.length,
        (int index) => _annotations[index].range.start - offset);
    late int startIndex;
    if (startIndexWhereToReplace >= 0) {
      startIndex = startIndexWhereToReplace;
      // source uses optional chaining `this._annotations[startIndex]?.range`;
      // at a non-negative found index the element always exists.
      final OffsetRange nextCandidate = _annotations[startIndex].range;
      if (nextCandidate.endExclusive == offset) {
        startIndex = startIndexWhereToReplace - 1;
      }
    } else {
      final int candidateIndex = -(startIndexWhereToReplace + 2);
      final OffsetRange? candidate = candidateIndex < _annotations.length &&
              candidateIndex >= 0
          ? _annotations[candidateIndex].range
          : null;
      if (candidate != null &&
          offset >= candidate.start &&
          offset < candidate.endExclusive) {
        startIndex = candidateIndex;
      } else {
        startIndex = -(startIndexWhereToReplace + 1);
      }
    }
    return startIndex;
  }

  int _getEndIndexOfIntersectingAnnotation(int offset) {
    final int endIndexWhereToReplace = arrays.binarySearch2(
        _annotations.length,
        (int index) => _annotations[index].range.endExclusive - offset);
    late int endIndexExclusive;
    if (endIndexWhereToReplace >= 0) {
      endIndexExclusive = endIndexWhereToReplace + 1;
      final int nextIndex = endIndexExclusive;
      final OffsetRange? nextCandidate = nextIndex < _annotations.length &&
              nextIndex >= 0
          ? _annotations[nextIndex].range
          : null;
      if (nextCandidate != null && nextCandidate.start == offset) {
        endIndexExclusive++;
      }
    } else {
      final int candidateIndex = -(endIndexWhereToReplace + 1);
      final OffsetRange? candidate = candidateIndex < _annotations.length &&
              candidateIndex >= 0
          ? _annotations[candidateIndex].range
          : null;
      if (candidate != null &&
          offset >= candidate.start &&
          offset <= candidate.endExclusive) {
        endIndexExclusive = -endIndexWhereToReplace;
      } else {
        endIndexExclusive = -(endIndexWhereToReplace + 1);
      }
    }
    return endIndexExclusive;
  }

  @override
  List<IAnnotation<T>> getAllAnnotations() => _annotations.toList();

  @override
  List<IAnnotation<T>> applyEdit(StringEdit edit) {
    final List<IAnnotation<T>> annotations = _annotations.toList();

    final List<IAnnotation<T>> finalAnnotations = <IAnnotation<T>>[];
    final List<IAnnotation<T>> deletedAnnotations = <IAnnotation<T>>[];

    int offset = 0;

    for (final StringReplacement e in edit.replacements) {
      while (true) {
        final IAnnotation<T>? annotation =
            annotations.isNotEmpty ? annotations[0] : null;
        if (annotation == null) {
          break;
        }
        final OffsetRange range = annotation.range;
        if (range.endExclusive >= e.replaceRange.start) {
          break;
        }
        annotations.removeAt(0);
        final IAnnotation<T> newAnnotation =
            IAnnotation<T>(range.delta(offset), annotation.annotation);
        if (!newAnnotation.range.isEmpty) {
          finalAnnotations.add(newAnnotation);
        } else {
          deletedAnnotations.add(newAnnotation);
        }
      }

      final List<IAnnotation<T>> intersecting = <IAnnotation<T>>[];
      while (true) {
        final IAnnotation<T>? annotation =
            annotations.isNotEmpty ? annotations[0] : null;
        if (annotation == null) {
          break;
        }
        final OffsetRange range = annotation.range;
        if (!range.intersectsOrTouches(e.replaceRange)) {
          break;
        }
        annotations.removeAt(0);
        intersecting.add(annotation);
      }

      for (int i = intersecting.length - 1; i >= 0; i--) {
        final IAnnotation<T> annotation = intersecting[i];
        OffsetRange r = annotation.range;

        final bool shouldExtend = i == 0 &&
            (e.replaceRange.endExclusive > r.start) &&
            (e.replaceRange.start < r.endExclusive);
        final int overlap = r.intersect(e.replaceRange)!.length;
        r = r.deltaEnd(-overlap + (shouldExtend ? e.newText.length : 0));

        final int rangeAheadOfReplaceRange = r.start - e.replaceRange.start;
        if (rangeAheadOfReplaceRange > 0) {
          r = r.delta(-rangeAheadOfReplaceRange);
        }

        if (!shouldExtend && rangeAheadOfReplaceRange >= 0) {
          r = r.delta(e.newText.length);
        }

        r = r.delta(-(e.newText.length - e.replaceRange.length));

        annotations.insert(0, IAnnotation<T>(r, annotation.annotation));
      }

      offset += e.newText.length - e.replaceRange.length;
    }

    while (true) {
      final IAnnotation<T>? annotation =
          annotations.isNotEmpty ? annotations[0] : null;
      if (annotation == null) {
        break;
      }
      annotations.removeAt(0);
      final IAnnotation<T> newAnnotation = IAnnotation<T>(
          annotation.range.delta(offset), annotation.annotation);
      if (!newAnnotation.range.isEmpty) {
        finalAnnotations.add(newAnnotation);
      } else {
        deletedAnnotations.add(newAnnotation);
      }
    }
    _annotations = finalAnnotations;
    return deletedAnnotations;
  }

  @override
  IAnnotatedString<T> clone() => AnnotatedString<T>(_annotations.toList());
}

/// 1:1: `export interface IAnnotationUpdate<T>`
class IAnnotationUpdate<T> {
  final OffsetRange range;
  final T? annotation;

  const IAnnotationUpdate(this.range, this.annotation);
}

/// 1:1: `type DefinedValue`
typedef DefinedValue = Object;

/// 1:1: `export type ISerializedAnnotation<TSerializedProperty>`
class ISerializedAnnotation<TSerializedProperty extends Object> {
  final OffsetRangeData range;
  final TSerializedProperty? annotation;

  const ISerializedAnnotation(this.range, this.annotation);
}

/// Serialized range carrier: `{ start: number; endExclusive: number }`.
class OffsetRangeData {
  final int start;
  final int endExclusive;

  const OffsetRangeData(this.start, this.endExclusive);
}

/// 1:1: `export class AnnotationsUpdate<T>`
class AnnotationsUpdate<T> {
  /// 1:1: `static create`
  static AnnotationsUpdate<T> create<T>(List<IAnnotationUpdate<T>> annotations) =>
      AnnotationsUpdate<T>(annotations);

  List<IAnnotationUpdate<T>> _annotations;

  AnnotationsUpdate(this._annotations);

  List<IAnnotationUpdate<T>> get annotations => _annotations;

  /// 1:1: `rebase(edit)`
  void rebase(StringEdit edit) {
    final AnnotatedString<T?> annotatedString =
        AnnotatedString<T?>(_annotations
            .map((IAnnotationUpdate<T> a) =>
                IAnnotation<T?>(a.range, a.annotation))
            .toList());
    annotatedString.applyEdit(edit);
    _annotations = annotatedString
        .getAllAnnotations()
        .map((IAnnotation<T?> a) =>
            IAnnotationUpdate<T>(a.range, a.annotation))
        .toList();
  }

  /// 1:1: `serialize(serializingFunc)`
  List<ISerializedAnnotation<TSerializedProperty>> serialize<
      TSerializedProperty extends Object>(
      TSerializedProperty Function(T annotation) serializingFunc) {
    return _annotations.map((IAnnotationUpdate<T> annotation) {
      final OffsetRangeData range = OffsetRangeData(
          annotation.range.start, annotation.range.endExclusive);
      if (annotation.annotation == null) {
        return ISerializedAnnotation<TSerializedProperty>(range, null);
      }
      return ISerializedAnnotation<TSerializedProperty>(
          range, serializingFunc(annotation.annotation!));
    }).toList();
  }

  /// 1:1: `static deserialize`
  static AnnotationsUpdate<T> deserialize<T, TSerializedProperty extends Object>(
      List<ISerializedAnnotation<TSerializedProperty>> serializedAnnotations,
      T Function(TSerializedProperty annotation) deserializingFunc) {
    final List<IAnnotationUpdate<T>> annotations = serializedAnnotations
        .map((ISerializedAnnotation<TSerializedProperty> serializedAnnotation) {
      final OffsetRange range = OffsetRange(
          serializedAnnotation.range.start,
          serializedAnnotation.range.endExclusive);
      if (serializedAnnotation.annotation == null) {
        return IAnnotationUpdate<T>(range, null);
      }
      return IAnnotationUpdate<T>(
          range, deserializingFunc(serializedAnnotation.annotation!));
    }).toList();
    return AnnotationsUpdate<T>(annotations);
  }
}
