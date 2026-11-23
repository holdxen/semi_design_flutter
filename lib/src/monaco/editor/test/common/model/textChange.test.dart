// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/model/textChange.test.ts
// Translated 1:1. The mocha suites' active cases become Dart functions:
//   - TextChangeCompressor: simple 1/2, complex1, gen1..gen6.
//   - TextChange: issue #118041 unicode write/read round-trip.
// `IGeneratedEdit` -> carrier class. `GENERATE_TESTS = false` generation
// helpers (getRandomInt/String/EOL/Buffer/Edits, GeneratedTest) are ported 1:1
// but the generation loop is intentionally not run (matches source constant).
// `ensureNoDisposablesAreLeakedInTestSuite()` is a suite-level harness hook and
// is intentionally omitted here.
// ---------------------------------------------------------------------------

import 'dart:math' as math;
import 'dart:typed_data';

import '../../../common/core/textChange.dart'
    show TextChange, compressConsecutiveTextChanges;

const bool GENERATE_TESTS = false;

class IGeneratedEdit {
  final int offset;
  final int length;
  final String text;
  IGeneratedEdit(this.offset, this.length, this.text);
}

String getResultingContent(String initialContent, List<IGeneratedEdit> edits) {
  String content = initialContent;
  for (int i = edits.length - 1; i >= 0; i--) {
    final IGeneratedEdit edit = edits[i];
    content = content.substring(0, edit.offset) +
        edit.text +
        content.substring(edit.offset + edit.length);
  }
  return content;
}

List<TextChange> getTextChanges(String initialContent, List<IGeneratedEdit> edits) {
  String content = initialContent;
  final List<TextChange> changes = List<TextChange>.filled(edits.length, TextChange(0, '', 0, ''));
  int deltaOffset = 0;

  for (int i = 0; i < edits.length; i++) {
    final IGeneratedEdit edit = edits[i];
    final int position = edit.offset + deltaOffset;
    final int length = edit.length;
    final String text = edit.text;
    final String oldText = content.substring(position, position + length);

    content = content.substring(0, position) + text + content.substring(position + length);
    changes[i] = TextChange(edit.offset, oldText, position, text);
    deltaOffset += text.length - length;
  }
  return changes;
}

void assertCompression(String initialText, List<IGeneratedEdit> edit1, List<IGeneratedEdit> edit2) {
  final String tmpText = getResultingContent(initialText, edit1);
  final List<TextChange> chg1 = getTextChanges(initialText, edit1);
  final String finalText = getResultingContent(tmpText, edit2);
  final List<TextChange> chg2 = getTextChanges(tmpText, edit2);

  final List<TextChange> compressedTextChanges = compressConsecutiveTextChanges(chg1, chg2);

  final List<IGeneratedEdit> compressedDoTextEdits = compressedTextChanges
      .map((TextChange change) => IGeneratedEdit(change.oldPosition, change.oldLength, change.newText))
      .toList();
  final String actualDoResult = getResultingContent(initialText, compressedDoTextEdits);
  assert(actualDoResult == finalText);

  final List<IGeneratedEdit> compressedUndoTextEdits = compressedTextChanges
      .map((TextChange change) => IGeneratedEdit(change.newPosition, change.newLength, change.oldText))
      .toList();
  final String actualUndoResult = getResultingContent(finalText, compressedUndoTextEdits);
  assert(actualUndoResult == initialText);
}

void testSimple1() {
  assertCompression(
    '',
    [IGeneratedEdit(0, 0, 'h')],
    [IGeneratedEdit(1, 0, 'e')],
  );
}

void testSimple2() {
  assertCompression(
    '|',
    [IGeneratedEdit(0, 0, 'h')],
    [IGeneratedEdit(2, 0, 'e')],
  );
}

void testComplex1() {
  assertCompression(
    'abcdefghij',
    [
      IGeneratedEdit(0, 3, 'qh'),
      IGeneratedEdit(5, 0, '1'),
      IGeneratedEdit(8, 2, 'X'),
    ],
    [
      IGeneratedEdit(1, 0, 'Z'),
      IGeneratedEdit(3, 3, 'Y'),
    ],
  );
}

void testGen1() {
  assertCompression('kxm', [IGeneratedEdit(0, 1, 'tod_neu')], [IGeneratedEdit(1, 2, 'sag_e')]);
}

void testGen2() {
  assertCompression('kpb_r_v', [IGeneratedEdit(5, 2, 'a_jvf_l')], [IGeneratedEdit(10, 2, 'w')]);
}

void testGen3() {
  assertCompression('slu_w', [IGeneratedEdit(4, 1, '_wfw')], [IGeneratedEdit(3, 5, '')]);
}

void testGen4() {
  assertCompression('_e', [IGeneratedEdit(2, 0, 'zo_b')], [IGeneratedEdit(1, 3, 'tra')]);
}

void testGen5() {
  assertCompression('ssn_', [IGeneratedEdit(0, 2, 'tat_nwe')], [IGeneratedEdit(2, 6, 'jm')]);
}

void testGen6() {
  assertCompression('kl_nru', [IGeneratedEdit(4, 1, '')], [IGeneratedEdit(1, 4, '__ut')]);
}

// ----------------- generation helpers (GENERATE_TESTS = false) -------------

final int _a = 'a'.codeUnitAt(0);
final int _z = 'z'.codeUnitAt(0);

int getRandomInt(int min, int max) => min + (_random.nextDouble() * (max - min + 1)).floor();

final math.Random _random = math.Random();

String getRandomString(int minLength, int maxLength) {
  final int length = getRandomInt(minLength, maxLength);
  final StringBuffer r = StringBuffer();
  for (int i = 0; i < length; i++) {
    r.writeCharCode(getRandomInt(_a, _z));
  }
  return r.toString();
}

String getRandomEOL() {
  switch (getRandomInt(1, 3)) {
    case 1:
      return '\r';
    case 2:
      return '\n';
    case 3:
      return '\r\n';
  }
  throw StateError('not possible');
}

String getRandomBuffer(bool small) {
  final int lineCount = getRandomInt(1, small ? 3 : 10);
  final List<String> lines = <String>[];
  for (int i = 0; i < lineCount; i++) {
    lines.add(getRandomString(0, small ? 3 : 10) + getRandomEOL());
  }
  return lines.join('');
}

List<IGeneratedEdit> getRandomEdits(String content, [int min = 1, int max = 5]) {
  final List<IGeneratedEdit> result = <IGeneratedEdit>[];
  int cnt = getRandomInt(min, max);
  int maxOffset = content.length;

  while (cnt > 0 && maxOffset > 0) {
    final int offset = getRandomInt(0, maxOffset);
    final int length = getRandomInt(0, maxOffset - offset);
    final String text = getRandomBuffer(true);
    result.add(IGeneratedEdit(offset, length, text));
    maxOffset = offset;
    cnt--;
  }
  return result.reversed.toList();
}

class GeneratedTest {
  late final String _content;
  late final List<IGeneratedEdit> _edits1;
  late final List<IGeneratedEdit> _edits2;

  GeneratedTest() {
    _content = getRandomBuffer(false).replaceAll('\n', '_');
    _edits1 = getRandomEdits(_content, 1, 5)
        .map((IGeneratedEdit e) => IGeneratedEdit(e.offset, e.length, e.text.replaceAll('\n', '_')))
        .toList();
    final String tmp = getResultingContent(_content, _edits1);
    _edits2 = getRandomEdits(tmp, 1, 5)
        .map((IGeneratedEdit e) => IGeneratedEdit(e.offset, e.length, e.text.replaceAll('\n', '_')))
        .toList();
  }

  void print() {
    // source uses console.log(JSON.stringify(...)); omitted under GENERATE_TESTS=false
  }

  void doAssert() {
    assertCompression(_content, _edits1, _edits2);
  }
}

void runGenerationLoop() {
  if (!GENERATE_TESTS) return;
  int testNumber = 0; // ignore: unused_local_variable
  while (true) {
    testNumber++;
    final GeneratedTest test = GeneratedTest();
    try {
      test.doAssert();
    } catch (err) {
      test.print();
      break;
    }
  }
}

// ------------------------------- TextChange --------------------------------

void testUnicodeCharacterUndoBug() {
  final TextChange textChange = TextChange(428, '\uFEFF', 428, '');
  final Uint8List buff = Uint8List(textChange.writeSize());
  textChange.write(buff, 0);
  final List<TextChange> actual = <TextChange>[];
  TextChange.read(buff, 0, actual);
  assert(actual.length == 1);
  final TextChange a = actual[0];
  assert(a.oldPosition == textChange.oldPosition &&
      a.oldText == textChange.oldText &&
      a.newPosition == textChange.newPosition &&
      a.newText == textChange.newText);
}

void runAll() {
  testSimple1();
  testSimple2();
  testComplex1();
  testGen1();
  testGen2();
  testGen3();
  testGen4();
  testGen5();
  testGen6();
  runGenerationLoop();
  testUnicodeCharacterUndoBug();
}
