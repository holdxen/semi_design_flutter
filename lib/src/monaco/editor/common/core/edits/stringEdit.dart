// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/edits/stringEdit.ts
// Translated 1:1 from TypeScript.
//   - TS default generic params `= BaseStringReplacement<any>` are dropped;
//     call sites always supply explicit type args.
//   - `get TReplacement(): T` (a TS-only typed throw) -> a getter that throws.
//   - `.at(idx)` -> helper `_at` returning null out of range.
//   - `applyOnText` imports StringText from abstractText.dart (Dart allows
//     circular library imports).
// ---------------------------------------------------------------------------

import '../../../../base/common/strings.dart' as strings;
import '../ranges/offsetRange.dart';
import '../text/abstractText.dart' show StringText;
import 'edit.dart';

/// 1:1: `BaseStringEdit<T, TEdit>`
abstract class BaseStringEdit<T extends BaseStringReplacement<T>, TEdit extends BaseStringEdit<T, TEdit>>
    extends BaseEdit<T, TEdit> {
  BaseStringEdit(super.replacements);

  T get tReplacement => throw StateError('TReplacement is not defined for BaseStringEdit');

  /// 1:1: `static composeOrUndefined`
  static T? composeOrUndefined<T>(List<T> edits) {
    if (edits.isEmpty) {
      return null;
    }
    T result = edits[0];
    for (int i = 1; i < edits.length; i++) {
      result = (result as dynamic).compose(edits[i]) as T;
    }
    return result;
  }

  /// 1:1: `static trySwap`
  static ({StringEdit e1, StringEdit e2})? trySwap(BaseStringEdit e1, BaseStringEdit e2) {
    final StringEdit e1Inv = e1.inverseOnSlice((int start, int endEx) => ' ' * (endEx - start));
    final StringEdit? e1_ = e2.tryRebase(e1Inv);
    if (e1_ == null) {
      return null;
    }
    final StringEdit? e2_ = e1.tryRebase(e1_);
    if (e2_ == null) {
      return null;
    }
    return (e1: e1_, e2: e2_);
  }

  /// 1:1: `apply`
  String apply(String base) {
    final List<String> resultText = <String>[];
    int pos = 0;
    for (final T edit in this.replacements) {
      resultText.add(base.substring(pos, edit.replaceRange.start));
      resultText.add(edit.newText);
      pos = edit.replaceRange.endExclusive;
    }
    resultText.add(base.substring(pos));
    return resultText.join();
  }

  /// 1:1: `inverseOnSlice`
  StringEdit inverseOnSlice(String Function(int start, int endEx) getOriginalSlice) {
    final List<StringReplacement> edits = <StringReplacement>[];
    int offset = 0;
    for (final T e in this.replacements) {
      edits.add(StringReplacement.replaceStatic(
        OffsetRange.ofStartAndLength(e.replaceRange.start + offset, e.newText.length),
        getOriginalSlice(e.replaceRange.start, e.replaceRange.endExclusive),
      ));
      offset += e.newText.length - e.replaceRange.length;
    }
    return StringEdit(edits);
  }

  /// 1:1: `inverse`
  StringEdit inverse(String original) =>
      this.inverseOnSlice((int start, int endEx) => original.substring(start, endEx));

  /// 1:1: `rebaseSkipConflicting`
  StringEdit rebaseSkipConflicting(StringEdit base) => this._tryRebase(base, false)!;

  /// 1:1: `tryRebase`
  StringEdit? tryRebase(StringEdit base) => this._tryRebase(base, true);

  /// 1:1: `_tryRebase`
  StringEdit? _tryRebase(StringEdit base, bool noOverlap) {
    final List<StringReplacement> newEdits = <StringReplacement>[];

    int baseIdx = 0;
    int ourIdx = 0;
    int offset = 0;

    while (ourIdx < this.replacements.length || baseIdx < base.replacements.length) {
      final StringReplacement? baseEdit = _at(base.replacements, baseIdx);
      final StringReplacement? ourEdit = _at(this.replacements, ourIdx) as StringReplacement?;

      if (ourEdit == null) {
        break;
      } else if (baseEdit == null) {
        final OffsetRange transformedRange = ourEdit.replaceRange.delta(offset);
        newEdits.add(StringReplacement(transformedRange, ourEdit.newText));
        ourIdx++;
      } else if (
        ourEdit.replaceRange.intersects(baseEdit.replaceRange) ||
        _areConcurrentInserts(ourEdit.replaceRange, baseEdit.replaceRange) ||
        _isInsertStrictlyInsideRange(ourEdit.replaceRange, baseEdit.replaceRange) ||
        _isInsertStrictlyInsideRange(baseEdit.replaceRange, ourEdit.replaceRange)
      ) {
        ourIdx++;
        if (noOverlap) {
          return null;
        }
      } else if (ourEdit.replaceRange.start < baseEdit.replaceRange.start ||
          (ourEdit.replaceRange.isEmpty && ourEdit.replaceRange.start == baseEdit.replaceRange.start)) {
        final OffsetRange transformedRange = ourEdit.replaceRange.delta(offset);
        newEdits.add(StringReplacement(transformedRange, ourEdit.newText));
        ourIdx++;
      } else {
        baseIdx++;
        offset += baseEdit.newText.length - baseEdit.replaceRange.length;
      }
    }

    return StringEdit(newEdits);
  }

  /// 1:1: `toJson`
  List<ISerializedStringReplacement> toJson() =>
      this.replacements.map((T e) => e.toJson()).toList();

  /// 1:1: `isNeutralOn`
  bool isNeutralOn(String text) => this.replacements.every((T e) => e.isNeutralOn(text));

  /// 1:1: `removeCommonSuffixPrefix`
  StringEdit removeCommonSuffixPrefix(String originalText) {
    final List<StringReplacement> edits = <StringReplacement>[];
    for (final T e in this.replacements) {
      final StringReplacement edit = e.removeCommonSuffixPrefix(originalText);
      if (!edit.isEmpty) {
        edits.add(edit);
      }
    }
    return StringEdit(edits);
  }

  /// 1:1: `normalizeEOL`
  StringEdit normalizeEOL(String eol) =>
      StringEdit(this.replacements.map((T edit) => edit.normalizeEOL(eol)).toList());

  /// 1:1: `normalizeOnSource`
  StringEdit normalizeOnSource(String source) {
    final String result = this.apply(source);
    final StringReplacement edit = StringReplacement.replaceStatic(OffsetRange.ofLength(source.length), result);
    final StringReplacement e = edit.removeCommonSuffixAndPrefix(source);
    if (e.isEmpty) {
      return StringEdit.empty;
    }
    return e.toEdit();
  }

  /// 1:1: `removeCommonSuffixAndPrefix`
  TEdit removeCommonSuffixAndPrefix(String source) =>
      this.createNew(this.replacements.map((T e) => e.removeCommonSuffixAndPrefix(source)).toList()).normalize();

  /// 1:1: `applyOnText`
  StringText applyOnText(StringText docContents) => StringText(this.apply(docContents.value));

  /// 1:1: `mapData`
  AnnotatedStringEdit<TData> mapData<TData extends IEditData<TData>>(TData Function(T replacement) f) {
    return AnnotatedStringEdit<TData>(this.replacements
        .map((T e) => AnnotatedStringReplacement<TData>(e.replaceRange, e.newText, f(e)))
        .toList());
  }
}

/// 1:1: `BaseStringReplacement<T>`
abstract class BaseStringReplacement<T extends BaseStringReplacement<T>> extends BaseReplacement<T> {
  final String newText;

  BaseStringReplacement(OffsetRange range, this.newText) : super(range);

  @override
  int getNewLength() => this.newText.length;

  @override
  String toString() => '${this.replaceRange} -> ${_jsonString(this.newText)}';

  /// 1:1: `replace`
  String replace(String str) =>
      str.substring(0, this.replaceRange.start) + this.newText + str.substring(this.replaceRange.endExclusive);

  /// 1:1: `isNeutralOn`
  bool isNeutralOn(String text) =>
      this.newText == text.substring(this.replaceRange.start, this.replaceRange.endExclusive);

  /// 1:1: `removeCommonSuffixPrefix` (returns a concrete StringReplacement)
  StringReplacement removeCommonSuffixPrefix(String originalText) {
    final String oldText = originalText.substring(this.replaceRange.start, this.replaceRange.endExclusive);
    final int prefixLen = strings.commonPrefixLength(oldText, this.newText);
    final int suffixLen = [
      oldText.length - prefixLen,
      this.newText.length - prefixLen,
      strings.commonSuffixLength(oldText, this.newText),
    ].reduce((int a, int b) => a < b ? a : b);

    final OffsetRange replaceRange = OffsetRange(
      this.replaceRange.start + prefixLen,
      this.replaceRange.endExclusive - suffixLen,
    );
    final String text = this.newText.substring(prefixLen, this.newText.length - suffixLen);
    return StringReplacement(replaceRange, text);
  }

  /// 1:1: `normalizeEOL`
  StringReplacement normalizeEOL(String eol) {
    final String text = this.newText.replaceAllMapped(RegExp(r'\r\n|\n'), (_) => eol);
    return StringReplacement(this.replaceRange, text);
  }

  /// 1:1: `removeCommonSuffixAndPrefix`
  T removeCommonSuffixAndPrefix(String source) => this.removeCommonSuffix(source).removeCommonPrefix(source);

  /// 1:1: `removeCommonPrefix`
  T removeCommonPrefix(String source) {
    final String oldText = this.replaceRange.substring(source);
    final int prefixLen = strings.commonPrefixLength(oldText, this.newText);
    if (prefixLen == 0) {
      return this as T;
    }
    return this.slice(this.replaceRange.deltaStart(prefixLen), OffsetRange(prefixLen, this.newText.length));
  }

  /// 1:1: `removeCommonSuffix`
  T removeCommonSuffix(String source) {
    final String oldText = this.replaceRange.substring(source);
    final int suffixLen = strings.commonSuffixLength(oldText, this.newText);
    if (suffixLen == 0) {
      return this as T;
    }
    return this.slice(this.replaceRange.deltaEnd(-suffixLen), OffsetRange(0, this.newText.length - suffixLen));
  }

  /// 1:1: `toEdit`
  StringEdit toEdit() => StringEdit(<StringReplacement>[this as StringReplacement]);

  /// 1:1: `toJson`
  ISerializedStringReplacement toJson() => ISerializedStringReplacement(this.newText, this.replaceRange.start, this.replaceRange.length);
}

/// 1:1: `StringEdit`
class StringEdit extends BaseStringEdit<StringReplacement, StringEdit> {
  static final StringEdit empty = StringEdit(<StringReplacement>[]);

  StringEdit(super.replacements);

  /// 1:1: `parse`
  static StringEdit parse(String toStringValue) {
    final List<StringReplacement> replacements = <StringReplacement>[];
    final RegExp regex = RegExp(r'\[(\d+),\s*(\d+)\)\s*->\s*"([^"]*)"');
    for (final Match match in regex.allMatches(toStringValue)) {
      final int start = int.parse(match.group(1)!);
      final int endEx = int.parse(match.group(2)!);
      final String text = match.group(3)!
          .replaceAll(r'\n', '\n')
          .replaceAll(r'\r', '\r')
          .replaceAll(r'\\', '\\');
      replacements.add(StringReplacement(OffsetRange(start, endEx), text));
    }
    return StringEdit(replacements);
  }

  static StringEdit create(List<StringReplacement> replacements) => StringEdit(replacements);

  static StringEdit single(StringReplacement replacement) => StringEdit(<StringReplacement>[replacement]);

  static StringEdit replace(OffsetRange range, String replacement) =>
      StringEdit(<StringReplacement>[StringReplacement(range, replacement)]);

  static StringEdit insert(int offset, String replacement) =>
      StringEdit(<StringReplacement>[StringReplacement(OffsetRange.emptyAt(offset), replacement)]);

  static StringEdit delete(OffsetRange range) =>
      StringEdit(<StringReplacement>[StringReplacement(range, '')]);

  static StringEdit fromJson(List<ISerializedStringReplacement> data) =>
      StringEdit(data.map((ISerializedStringReplacement d) => StringReplacement.fromJson(d)).toList());

  /// 1:1: `static compose`
  static StringEdit composeStatic(List<StringEdit> edits) {
    if (edits.isEmpty) {
      return StringEdit.empty;
    }
    StringEdit result = edits[0];
    for (int i = 1; i < edits.length; i++) {
      result = result.compose(edits[i]);
    }
    return result;
  }

  /// 1:1: `static composeSequentialReplacements`
  static StringEdit composeSequentialReplacements(List<StringReplacement> replacements) {
    StringEdit edit = StringEdit.empty;
    List<StringReplacement> curEditReplacements = <StringReplacement>[];

    for (final StringReplacement r in replacements) {
      final StringReplacement? last = _lastOrNull(curEditReplacements);
      if (last == null || r.replaceRange.isBefore(last.replaceRange)) {
        curEditReplacements.add(r);
      } else {
        edit = edit.compose(StringEdit.create(curEditReplacements.reversed.toList()));
        curEditReplacements = <StringReplacement>[r];
      }
    }
    edit = edit.compose(StringEdit.create(curEditReplacements.reversed.toList()));
    return edit;
  }

  @override
  StringEdit createNew(List<StringReplacement> replacements) => StringEdit(replacements);
}

/// 1:1: `ISerializedStringReplacement`
class ISerializedStringReplacement {
  final String txt;
  final int pos;
  final int len;

  ISerializedStringReplacement(this.txt, this.pos, this.len);

  Map<String, Object?> toJson() => <String, Object?>{'txt': txt, 'pos': pos, 'len': len};

  static ISerializedStringReplacement fromJsonMap(Map<String, Object?> data) =>
      ISerializedStringReplacement(data['txt'] as String, data['pos'] as int, data['len'] as int);
}

/// 1:1: `StringReplacement`
class StringReplacement extends BaseStringReplacement<StringReplacement> {
  static StringReplacement insert(int offset, String text) =>
      StringReplacement(OffsetRange.emptyAt(offset), text);

  static StringReplacement replaceStatic(OffsetRange range, String text) => StringReplacement(range, text);

  static StringReplacement delete(OffsetRange range) => StringReplacement(range, '');

  static StringReplacement fromJson(ISerializedStringReplacement data) =>
      StringReplacement(OffsetRange.ofStartAndLength(data.pos, data.len), data.txt);

  StringReplacement(super.range, super.newText);

  @override
  bool equals(StringReplacement other) =>
      this.replaceRange.equals(other.replaceRange) && this.newText == other.newText;

  @override
  StringReplacement? tryJoinTouching(StringReplacement other) =>
      StringReplacement(this.replaceRange.joinRightTouching(other.replaceRange), this.newText + other.newText);

  @override
  StringReplacement slice(OffsetRange range, [OffsetRange? rangeInReplacement]) => StringReplacement(
    range,
    rangeInReplacement != null ? rangeInReplacement.substring(this.newText) : this.newText,
  );
}

/// 1:1: `applyEditsToRanges`
List<OffsetRange> applyEditsToRanges(List<OffsetRange> sortedRanges, StringEdit edit) {
  final List<OffsetRange> ranges = sortedRanges.toList();
  final List<OffsetRange> result = <OffsetRange>[];
  int offset = 0;

  for (final StringReplacement e in edit.replacements) {
    while (true) {
      final OffsetRange? r = _firstOrNull(ranges);
      if (r == null || r.endExclusive >= e.replaceRange.start) {
        break;
      }
      ranges.removeAt(0);
      result.add(r.delta(offset));
    }

    final List<OffsetRange> intersecting = <OffsetRange>[];
    while (true) {
      final OffsetRange? r = _firstOrNull(ranges);
      if (r == null || !r.intersectsOrTouches(e.replaceRange)) {
        break;
      }
      ranges.removeAt(0);
      intersecting.add(r);
    }

    for (int i = intersecting.length - 1; i >= 0; i--) {
      OffsetRange r = intersecting[i];
      final int overlap = r.intersect(e.replaceRange)!.length;
      r = r.deltaEnd(-overlap + (i == 0 ? e.newText.length : 0));
      final int rangeAheadOfReplaceRange = r.start - e.replaceRange.start;
      if (rangeAheadOfReplaceRange > 0) {
        r = r.delta(-rangeAheadOfReplaceRange);
      }
      if (i != 0) {
        r = r.delta(e.newText.length);
      }
      r = r.delta(-(e.newText.length - e.replaceRange.length));
      ranges.insert(0, r);
    }
    offset += e.newText.length - e.replaceRange.length;
  }

  while (true) {
    final OffsetRange? r = _firstOrNull(ranges);
    if (r == null) {
      break;
    }
    ranges.removeAt(0);
    result.add(r.delta(offset));
  }
  return result;
}

/// 1:1: `IEditData<T>`
abstract class IEditData<T extends IEditData<T>> {
  T? join(T other);
}

/// 1:1: `VoidEditData`
class VoidEditData implements IEditData<VoidEditData> {
  @override
  VoidEditData? join(VoidEditData other) => this;
}

/// 1:1: `AnnotatedStringEdit<T>`
class AnnotatedStringEdit<T extends IEditData<T>> extends BaseStringEdit<AnnotatedStringReplacement<T>, AnnotatedStringEdit<T>> {
  static final AnnotatedStringEdit<VoidEditData> empty =
      AnnotatedStringEdit<VoidEditData>(<AnnotatedStringReplacement<VoidEditData>>[]);

  AnnotatedStringEdit(super.replacements);

  static AnnotatedStringEdit<T> create<T extends IEditData<T>>(List<AnnotatedStringReplacement<T>> replacements) =>
      AnnotatedStringEdit<T>(replacements);

  static AnnotatedStringEdit<T> single<T extends IEditData<T>>(AnnotatedStringReplacement<T> replacement) =>
      AnnotatedStringEdit<T>(<AnnotatedStringReplacement<T>>[replacement]);

  static AnnotatedStringEdit<T> replace<T extends IEditData<T>>(OffsetRange range, String replacement, T data) =>
      AnnotatedStringEdit<T>(<AnnotatedStringReplacement<T>>[AnnotatedStringReplacement<T>(range, replacement, data)]);

  static AnnotatedStringEdit<T> insert<T extends IEditData<T>>(int offset, String replacement, T data) =>
      AnnotatedStringEdit<T>(<AnnotatedStringReplacement<T>>[AnnotatedStringReplacement<T>(OffsetRange.emptyAt(offset), replacement, data)]);

  static AnnotatedStringEdit<T> delete<T extends IEditData<T>>(OffsetRange range, T data) =>
      AnnotatedStringEdit<T>(<AnnotatedStringReplacement<T>>[AnnotatedStringReplacement<T>(range, '', data)]);

  static AnnotatedStringEdit<T> composeStatic<T extends IEditData<T>>(List<AnnotatedStringEdit<T>> edits) {
    if (edits.isEmpty) {
      return AnnotatedStringEdit.empty as AnnotatedStringEdit<T>;
    }
    AnnotatedStringEdit<T> result = edits[0];
    for (int i = 1; i < edits.length; i++) {
      result = result.compose(edits[i]);
    }
    return result;
  }

  @override
  AnnotatedStringEdit<T> createNew(List<AnnotatedStringReplacement<T>> replacements) =>
      AnnotatedStringEdit<T>(replacements);

  /// 1:1: `toStringEdit`
  StringEdit toStringEdit([bool Function(AnnotatedStringReplacement<T> replacement)? filter]) {
    final List<StringReplacement> newReplacements = <StringReplacement>[];
    for (final AnnotatedStringReplacement<T> r in this.replacements) {
      if (filter == null || filter(r)) {
        newReplacements.add(StringReplacement(r.replaceRange, r.newText));
      }
    }
    return StringEdit(newReplacements);
  }
}

/// 1:1: `AnnotatedStringReplacement<T>`
class AnnotatedStringReplacement<T extends IEditData<T>> extends BaseStringReplacement<AnnotatedStringReplacement<T>> {
  final T data;

  static AnnotatedStringReplacement<T> insert<T extends IEditData<T>>(int offset, String text, T data) =>
      AnnotatedStringReplacement<T>(OffsetRange.emptyAt(offset), text, data);

  static AnnotatedStringReplacement<T> replaceStatic<T extends IEditData<T>>(OffsetRange range, String text, T data) =>
      AnnotatedStringReplacement<T>(range, text, data);

  static AnnotatedStringReplacement<T> delete<T extends IEditData<T>>(OffsetRange range, T data) =>
      AnnotatedStringReplacement<T>(range, '', data);

  AnnotatedStringReplacement(super.range, super.newText, this.data);

  @override
  bool equals(AnnotatedStringReplacement<T> other) =>
      this.replaceRange.equals(other.replaceRange) && this.newText == other.newText && this.data == other.data;

  @override
  AnnotatedStringReplacement<T>? tryJoinTouching(AnnotatedStringReplacement<T> other) {
    final T? joined = this.data.join(other.data);
    if (joined == null) {
      return null;
    }
    return AnnotatedStringReplacement<T>(this.replaceRange.joinRightTouching(other.replaceRange), this.newText + other.newText, joined);
  }

  @override
  AnnotatedStringReplacement<T> slice(OffsetRange range, [OffsetRange? rangeInReplacement]) => AnnotatedStringReplacement<T>(
    range,
    rangeInReplacement != null ? rangeInReplacement.substring(this.newText) : this.newText,
    this.data,
  );
}

// --- helpers ---------------------------------------------------------------

T? _at<T>(List<T> list, int idx) => (idx >= 0 && idx < list.length) ? list[idx] : null;
T? _firstOrNull<T>(List<T> list) => list.isEmpty ? null : list[0];
T? _lastOrNull<T>(List<T> list) => list.isEmpty ? null : list.last;

bool _areConcurrentInserts(OffsetRange r1, OffsetRange r2) =>
    r1.isEmpty && r2.isEmpty && r1.start == r2.start;

bool _isInsertStrictlyInsideRange(OffsetRange insert, OffsetRange range) =>
    insert.isEmpty && range.start < insert.start && insert.start < range.endExclusive;

/// Minimal JSON string escaping mirroring JSON.stringify for a plain string.
String _jsonString(String s) {
  final StringBuffer out = StringBuffer('"');
  for (int i = 0; i < s.length; i++) {
    final int c = s.codeUnitAt(i);
    switch (c) {
      case 0x22:
        out.write(r'\"');
        break;
      case 0x5c:
        out.write(r'\\');
        break;
      case 0x0a:
        out.write(r'\n');
        break;
      case 0x0d:
        out.write(r'\r');
        break;
      case 0x09:
        out.write(r'\t');
        break;
      default:
        out.writeCharCode(c);
    }
  }
  out.write('"');
  return out.toString();
}
