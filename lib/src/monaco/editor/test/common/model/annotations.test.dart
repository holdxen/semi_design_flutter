// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/model/annotations.test.ts
// Translated 1:1. The visual-annotation test infrastructure (brackets '[id:text]'
// for set, '<id:text>' for delete) is ported as-is; the mocha suite's active
// cases become Dart functions.
//   - `assert.fail(msg)` -> `assert(false, msg)`.
//   - `StringEdit.compose([...])` -> `StringEdit.composeStatic([...])`.
//   - `assert.deepStrictEqual(IAnnotation<List>)` -> field-wise `_annListEq`.
// `ensureNoDisposablesAreLeakedInTestSuite()` is a suite-level harness hook and
// is intentionally omitted here.
// ---------------------------------------------------------------------------

import '../../../common/core/edits/stringEdit.dart' show StringEdit;
import '../../../common/core/ranges/offsetRange.dart' show OffsetRange;
import '../../../common/model/tokens/annotations.dart'
    show AnnotatedString, AnnotationsUpdate, IAnnotation, IAnnotationUpdate;

// ===========================================================================
// Visual Annotation Test Infrastructure
// ===========================================================================

class ParsedVisual {
  final List<IAnnotation<String>> annotations;
  final String baseString;
  ParsedVisual(this.annotations, this.baseString);
}

ParsedVisual parseVisualAnnotations(String visual) {
  final List<IAnnotation<String>> annotations = <IAnnotation<String>>[];
  String baseString = '';
  int i = 0;

  while (i < visual.length) {
    if (visual[i] == '[') {
      final int colonIdx = visual.indexOf(':', i + 1);
      final int closeIdx = visual.indexOf(']', colonIdx + 1);
      if (colonIdx == -1 || closeIdx == -1) {
        throw StateError('Invalid annotation format at position $i');
      }
      final String id = visual.substring(i + 1, colonIdx);
      final String text = visual.substring(colonIdx + 1, closeIdx);
      final int startOffset = baseString.length;
      baseString += text;
      annotations.add(IAnnotation<String>(OffsetRange(startOffset, baseString.length), id));
      i = closeIdx + 1;
    } else {
      baseString += visual[i];
      i++;
    }
  }

  return ParsedVisual(annotations, baseString);
}

String toVisualString(List<IAnnotation<String>> annotations, String baseString) {
  if (annotations.isEmpty) {
    return baseString;
  }

  final List<IAnnotation<String>> sortedAnnotations =
      List<IAnnotation<String>>.from(annotations)
        ..sort((a, b) => a.range.start - b.range.start);

  final StringBuffer result = StringBuffer();
  int pos = 0;

  for (final IAnnotation<String> ann in sortedAnnotations) {
    result.write(baseString.substring(pos, ann.range.start));
    final String annotatedText =
        baseString.substring(ann.range.start, ann.range.endExclusive);
    result.write('[${ann.annotation}:$annotatedText]');
    pos = ann.range.endExclusive;
  }

  result.write(baseString.substring(pos));
  return result.toString();
}

class VisualAnnotatedString {
  final AnnotatedString<String> annotatedString;
  String baseString;

  VisualAnnotatedString(this.annotatedString, this.baseString);

  void setAnnotations(AnnotationsUpdate<String> update) =>
      this.annotatedString.setAnnotations(update);

  void applyEdit(StringEdit edit) {
    this.annotatedString.applyEdit(edit);
    this.baseString = edit.apply(this.baseString);
  }

  List<IAnnotation<String>> getAnnotationsIntersecting(OffsetRange range) =>
      this.annotatedString.getAnnotationsIntersecting(range);

  List<IAnnotation<String>> getAllAnnotations() =>
      this.annotatedString.getAllAnnotations();

  VisualAnnotatedString clone() => VisualAnnotatedString(
      this.annotatedString.clone() as AnnotatedString<String>, this.baseString);
}

VisualAnnotatedString fromVisual(String visual) {
  final ParsedVisual parsed = parseVisualAnnotations(visual);
  return VisualAnnotatedString(
      AnnotatedString<String>(parsed.annotations), parsed.baseString);
}

String toVisual(VisualAnnotatedString vas) =>
    toVisualString(vas.getAllAnnotations(), vas.baseString);

class ParsedVisualUpdate {
  final List<IAnnotationUpdate<String>> updates;
  final String baseString;
  ParsedVisualUpdate(this.updates, this.baseString);
}

ParsedVisualUpdate parseVisualUpdate(String visual) {
  final List<IAnnotationUpdate<String>> updates = <IAnnotationUpdate<String>>[];
  String baseString = '';
  int i = 0;

  while (i < visual.length) {
    if (visual[i] == '[') {
      final int colonIdx = visual.indexOf(':', i + 1);
      final int closeIdx = visual.indexOf(']', colonIdx + 1);
      if (colonIdx == -1 || closeIdx == -1) {
        throw StateError('Invalid annotation format at position $i');
      }
      final String id = visual.substring(i + 1, colonIdx);
      final String text = visual.substring(colonIdx + 1, closeIdx);
      final int startOffset = baseString.length;
      baseString += text;
      updates.add(IAnnotationUpdate<String>(
          OffsetRange(startOffset, baseString.length), id));
      i = closeIdx + 1;
    } else if (visual[i] == '<') {
      final int colonIdx = visual.indexOf(':', i + 1);
      final int closeIdx = visual.indexOf('>', colonIdx + 1);
      if (colonIdx == -1 || closeIdx == -1) {
        throw StateError('Invalid delete format at position $i');
      }
      final String text = visual.substring(colonIdx + 1, closeIdx);
      final int startOffset = baseString.length;
      baseString += text;
      updates.add(IAnnotationUpdate<String>(
          OffsetRange(startOffset, baseString.length), null));
      i = closeIdx + 1;
    } else {
      baseString += visual[i];
      i++;
    }
  }

  return ParsedVisualUpdate(updates, baseString);
}

AnnotationsUpdate<String> updateFromVisual(List<String> visuals) {
  final List<IAnnotationUpdate<String>> updates = <IAnnotationUpdate<String>>[];
  for (final String visual in visuals) {
    updates.addAll(parseVisualUpdate(visual).updates);
  }
  return AnnotationsUpdate.create(updates);
}

StringEdit editDelete(int start, int end) =>
    StringEdit.replace(OffsetRange(start, end), '');
StringEdit editInsert(int pos, String text) => StringEdit.insert(pos, text);
StringEdit editReplace(int start, int end, String text) =>
    StringEdit.replace(OffsetRange(start, end), text);

void assertVisual(VisualAnnotatedString vas, String expectedVisual) {
  final String actual = toVisual(vas);
  final List<IAnnotation<String>> expectedAnnotations =
      parseVisualAnnotations(expectedVisual).annotations;
  final List<IAnnotation<String>> actualAnnotations = vas.getAllAnnotations();

  if (actualAnnotations.length != expectedAnnotations.length) {
    assert(false,
        'Annotation count mismatch.\n  Expected: $expectedVisual\n  Actual:   $actual\n  Expected ${expectedAnnotations.length} annotations, got ${actualAnnotations.length}');
  }

  for (int i = 0; i < actualAnnotations.length; i++) {
    final IAnnotation<String> expected = expectedAnnotations[i];
    final IAnnotation<String> actualAnn = actualAnnotations[i];
    if (actualAnn.range.start != expected.range.start ||
        actualAnn.range.endExclusive != expected.range.endExclusive) {
      assert(false,
          'Annotation $i range mismatch.\n  Expected: (${expected.range.start}, ${expected.range.endExclusive})\n  Actual:   (${actualAnn.range.start}, ${actualAnn.range.endExclusive})\n  Expected visual: $expectedVisual\n  Actual visual:   $actual');
    }
    if (actualAnn.annotation != expected.annotation) {
      assert(false,
          'Annotation $i value mismatch.\n  Expected: "${expected.annotation}"\n  Actual:   "${actualAnn.annotation}"');
    }
  }
}

class VisualizeEditResult {
  final String before;
  final String after;
  VisualizeEditResult(this.before, this.after);
}

VisualizeEditResult visualizeEdit(String beforeAnnotations, StringEdit edit) {
  final VisualAnnotatedString vas = fromVisual(beforeAnnotations);
  final String before = toVisual(vas);
  vas.applyEdit(edit);
  return VisualizeEditResult(before, toVisual(vas));
}

bool _annListEq(List<IAnnotation<String>> a, List<IAnnotation<String>> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i].range.start != b[i].range.start ||
        a[i].range.endExclusive != b[i].range.endExclusive ||
        a[i].annotation != b[i].annotation) {
      return false;
    }
  }
  return true;
}

// ===========================================================================
// Annotations Suite
// ===========================================================================

void testSetAnnotations1() {
  final VisualAnnotatedString vas =
      fromVisual('[1:Lorem] ipsum [2:dolor] sit [3:amet]');
  vas.setAnnotations(updateFromVisual(['[4:Lorem i]']));
  assertVisual(vas, '[4:Lorem i]psum [2:dolor] sit [3:amet]');
  vas.setAnnotations(updateFromVisual(['Lorem ip[5:s]']));
  assertVisual(vas, '[4:Lorem i]p[5:s]um [2:dolor] sit [3:amet]');
}

void testSetAnnotations2() {
  final VisualAnnotatedString vas =
      fromVisual('[1:Lorem] ipsum [2:dolor] sit [3:amet]');
  vas.setAnnotations(updateFromVisual([
    'L<_:orem ipsum d>',
    '[4:Lorem ]',
  ]));
  assertVisual(vas, '[4:Lorem ]ipsum dolor sit [3:amet]');
  vas.setAnnotations(updateFromVisual([
    'Lorem <_:ipsum dolor sit amet>',
    '[5:Lor]',
  ]));
  assertVisual(vas, '[5:Lor]em ipsum dolor sit amet');
  vas.setAnnotations(updateFromVisual(['L[6:or]']));
  assertVisual(vas, 'L[6:or]em ipsum dolor sit amet');
}

void testSetAnnotations3() {
  final VisualAnnotatedString vas =
      fromVisual('[1:Lorem] ipsum [2:dolor] sit [3:amet]');
  vas.setAnnotations(updateFromVisual(['Lore[4:m ipsum dolor ]']));
  assertVisual(vas, 'Lore[4:m ipsum dolor ]sit [3:amet]');
  vas.setAnnotations(updateFromVisual(['Lorem ipsum dolor sit [5:a]']));
  assertVisual(vas, 'Lore[4:m ipsum dolor ]sit [5:a]met');
}

void testSetAnnotations4() {
  final VisualAnnotatedString vas =
      fromVisual('Lorem ipsum dolor sit amet, consectetur adipiscing el[:it]');
  vas.setAnnotations(
      updateFromVisual(['Lorem ipsum dolor sit amet, consectetur adipiscing el<_:i>t']));
  assertVisual(vas, 'Lorem ipsum dolor sit amet, consectetur adipiscing elit');
}

void testGetIntersecting1() {
  final VisualAnnotatedString vas =
      fromVisual('[1:Lorem] ipsum [2:dolor] sit [3:amet]');
  final List<IAnnotation<String>> result1 =
      vas.getAnnotationsIntersecting(OffsetRange(0, 13));
  assert(result1.length == 2);
  assert(result1.map((a) => a.annotation).toList().join(',') == '1,2');
  final List<IAnnotation<String>> result2 =
      vas.getAnnotationsIntersecting(OffsetRange(0, 22));
  assert(result2.length == 3);
  assert(result2.map((a) => a.annotation).toList().join(',') == '1,2,3');
}

void testGetIntersecting2() {
  final VisualAnnotatedString vas = fromVisual('[1:Lorem] [2:i]p[3:s]');
  final List<IAnnotation<String>> result1 =
      vas.getAnnotationsIntersecting(OffsetRange(5, 7));
  assert(result1.length == 1);
  assert(result1.map((a) => a.annotation).toList().join(',') == '2');
  final List<IAnnotation<String>> result2 =
      vas.getAnnotationsIntersecting(OffsetRange(5, 9));
  assert(result2.length == 2);
  assert(result2.map((a) => a.annotation).toList().join(',') == '2,3');
}

void testGetIntersecting3() {
  final VisualAnnotatedString vas = fromVisual('[1:Lorem] ipsum [2:dolor]');
  final List<IAnnotation<String>> result1 =
      vas.getAnnotationsIntersecting(OffsetRange(4, 13));
  assert(result1.length == 2);
  assert(result1.map((a) => a.annotation).toList().join(',') == '1,2');
  vas.setAnnotations(updateFromVisual(['[3:Lore]m[4: ipsu]']));
  assertVisual(vas, '[3:Lore]m[4: ipsu]m [2:dolor]');
  final List<IAnnotation<String>> result2 =
      vas.getAnnotationsIntersecting(OffsetRange(7, 13));
  assert(result2.length == 2);
  assert(result2.map((a) => a.annotation).toList().join(',') == '4,2');
}

void testGetIntersecting4() {
  final VisualAnnotatedString vas = fromVisual('[1:Lorem ipsum] sit');
  vas.setAnnotations(updateFromVisual(['Lorem ipsum [2:sit]']));
  final List<IAnnotation<String>> result =
      vas.getAnnotationsIntersecting(OffsetRange(2, 8));
  assert(result.length == 1);
  assert(result.map((a) => a.annotation).toList().join(',') == '1');
}

void testGetIntersecting5() {
  final VisualAnnotatedString vas =
      fromVisual('[1:Lorem ipsum] [2:dol] [3:or]');
  final List<IAnnotation<String>> result =
      vas.getAnnotationsIntersecting(OffsetRange(1, 16));
  assert(result.length == 3);
  assert(result.map((a) => a.annotation).toList().join(',') == '1,2,3');
}

void testGetIntersecting6() {
  final VisualAnnotatedString vas = fromVisual('[1:Lorem ][2:ip][3:sum]');
  final List<IAnnotation<String>> result =
      vas.getAnnotationsIntersecting(OffsetRange(6, 6));
  assert(result.length == 1);
  assert(result.map((a) => a.annotation).toList().join(',') == '2');
}

void testApplyEdit1() {
  final VisualizeEditResult result = visualizeEdit(
      '[1:Lorem] ipsum [2:dolor] sit [3:amet]', editDelete(0, 3));
  assert(result.after == '[1:em] ipsum [2:dolor] sit [3:amet]');
}

void testApplyEdit2() {
  final VisualizeEditResult result = visualizeEdit(
      '[1:Lorem] ipsum [2:dolor] sit [3:amet]', editReplace(1, 3, 'XXXXX'));
  assert(result.after == '[1:LXXXXXem] ipsum [2:dolor] sit [3:amet]');
}

void testApplyEdit3() {
  final VisualizeEditResult result = visualizeEdit(
      '[1:Lorem] ipsum [2:dolor] sit [3:amet]', editReplace(4, 22, 'XXXXX'));
  assert(result.after == '[1:LoreXXXXX][3:amet]');
}

void testApplyEdit4() {
  final VisualizeEditResult result = visualizeEdit(
      '[1:Lorem ip]sum and [2:dolor] sit [3:amet]', editDelete(10, 12));
  assert(result.after == '[1:Lorem ip]suand [2:dolor] sit [3:amet]');
}

void testApplyEdit5() {
  final VisualizeEditResult result = visualizeEdit(
      '[1:Lorem] ipsum [2:dolor] sit [3:amet]', editDelete(0, 5));
  assert(result.after == ' ipsum [2:dolor] sit [3:amet]');
}

void testApplyEdit6() {
  final VisualAnnotatedString vas =
      fromVisual('[1:Lorem] ipsum [2:dolor] sit [3:amet]');
  final StringEdit edit = StringEdit.composeStatic([
    StringEdit.replace(OffsetRange(0, 6), ''),
    StringEdit.replace(OffsetRange(6, 12), ''),
    StringEdit.replace(OffsetRange(12, 17), ''),
  ]);
  vas.applyEdit(edit);
  assertVisual(vas, 'ipsum sit [3:am]');
}

void testApplyEdit7() {
  final VisualAnnotatedString vas =
      fromVisual('[1:Lorem] ipsum [2:dolor] sit [3:amet]');
  final StringEdit edit1 = StringEdit.replace(OffsetRange(0, 3), 'XXXX');
  final StringEdit edit2 = StringEdit.replace(OffsetRange(0, 2), '');
  vas.applyEdit(edit1.compose(edit2));
  assertVisual(vas, '[1:XXem] ipsum [2:dolor] sit [3:amet]');
}

void testApplyEdit9() {
  final VisualizeEditResult result = visualizeEdit(
      '[1:Lorem] ipsum [2:dolor] sit [3:amet]', editInsert(17, 'XXX'));
  assert(result.after == '[1:Lorem] ipsum [2:dolor]XXX sit [3:amet]');
}

void testApplyEdit10() {
  final VisualizeEditResult result = visualizeEdit(
      '[1:Lorem] ipsum [2:dolor] sit [3:amet]', editInsert(14, 'XXX'));
  assert(result.after == '[1:Lorem] ipsum [2:doXXXlor] sit [3:amet]');
}

void testApplyEdit11() {
  final VisualizeEditResult result =
      visualizeEdit('[1:L]o[2:rem] [3:i]', editReplace(1, 6, 'X'));
  assert(result.after == '[1:L]X[3:i]');
}

void testApplyEdit12() {
  final VisualAnnotatedString vas =
      fromVisual('[1:Lorem] ipsum [2:dolor] sit [3:amet!] [4:done]');
  final StringEdit edit = StringEdit.composeStatic([
    StringEdit.insert(0, 'X'),
    StringEdit.delete(OffsetRange(12, 13)),
    StringEdit.replace(OffsetRange(21, 22), 'YY'),
    StringEdit.replace(OffsetRange(28, 32), 'Z'),
  ]);
  vas.applyEdit(edit);
  assertVisual(vas, 'X[1:Lorem] ipsum[2:dolor] sitYY[3:amet!]Z[4:e]');
}

void testApplyEdit13() {
  final VisualizeEditResult result =
      visualizeEdit('lorem ipsum dolor[1: ]', editInsert(17, 'X'));
  assert(result.after == 'lorem ipsum dolorX[1: ]');
}

void testRebase() {
  final VisualAnnotatedString a = VisualAnnotatedString(
      AnnotatedString<String>([
        IAnnotation<String>(OffsetRange(2, 5), '1'),
      ]),
      'sitamet');
  final VisualAnnotatedString b = a.clone();
  final AnnotationsUpdate<String> update = AnnotationsUpdate.create([
    IAnnotationUpdate<String>(OffsetRange(4, 5), '2'),
  ]);

  b.setAnnotations(update);
  final StringEdit edit = StringEdit.replace(OffsetRange(1, 6), 'XXX');

  a.applyEdit(edit);
  b.applyEdit(edit);

  update.rebase(edit);

  a.setAnnotations(update);
  assert(_annListEq(a.getAllAnnotations(), b.getAllAnnotations()));
}

void runAll() {
  testSetAnnotations1();
  testSetAnnotations2();
  testSetAnnotations3();
  testSetAnnotations4();
  testGetIntersecting1();
  testGetIntersecting2();
  testGetIntersecting3();
  testGetIntersecting4();
  testGetIntersecting5();
  testGetIntersecting6();
  testApplyEdit1();
  testApplyEdit2();
  testApplyEdit3();
  testApplyEdit4();
  testApplyEdit5();
  testApplyEdit6();
  testApplyEdit7();
  testApplyEdit9();
  testApplyEdit10();
  testApplyEdit11();
  testApplyEdit12();
  testApplyEdit13();
  testRebase();
}
