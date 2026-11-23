// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/browser/gpu/objectCollectionBuffer.test.ts
// Translated 1:1. The six mocha cases become Dart functions carrying the exact
// `deepStrictEqual` / `strictEqual` assertions.
// `ensureNoDisposablesAreLeakedInTestSuite()` is a suite-level harness hook and
// is intentionally omitted here (the outer runner performs that check).
// ---------------------------------------------------------------------------

import '../../../browser/gpu/objectCollectionBuffer.dart'
    show
        IObjectCollectionBuffer,
        ObjectCollectionBufferPropertySpec,
        createObjectCollectionBuffer;

IObjectCollectionBuffer _buffer(int capacity) =>
    createObjectCollectionBuffer(<ObjectCollectionBufferPropertySpec>[
      const ObjectCollectionBufferPropertySpec(name: 'a'),
      const ObjectCollectionBufferPropertySpec(name: 'b'),
    ], capacity);

IObjectCollectionBuffer _bufferFooBar(int capacity) =>
    createObjectCollectionBuffer(<ObjectCollectionBufferPropertySpec>[
      const ObjectCollectionBufferPropertySpec(name: 'foo'),
      const ObjectCollectionBufferPropertySpec(name: 'bar'),
    ], capacity);

void _assertUsedData(IObjectCollectionBuffer buffer, List<int> expected) {
  final int used = buffer.viewUsedSize;
  assert(used == expected.length);
  for (int i = 0; i < expected.length; i++) {
    assert(buffer.view[i] == expected[i]);
  }
}

/// 1:1: `test('createEntry')`
void testCreateEntry() {
  final IObjectCollectionBuffer buffer = _buffer(5);
  _assertUsedData(buffer, <int>[]);
  buffer.createEntry(<String, num>{'a': 1, 'b': 2});
  buffer.createEntry(<String, num>{'a': 3, 'b': 4});
  buffer.createEntry(<String, num>{'a': 5, 'b': 6});
  buffer.createEntry(<String, num>{'a': 7, 'b': 8});
  buffer.createEntry(<String, num>{'a': 9, 'b': 10});
  _assertUsedData(buffer, <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
}

/// 1:1: `test('createEntry beyond capacity')`
void testCreateEntryBeyondCapacity() {
  final IObjectCollectionBuffer buffer = _buffer(1);
  buffer.createEntry(<String, num>{'a': 1, 'b': 2});
  assert(buffer.entryCount == 1);
  assert(buffer.buffer.lengthInBytes == 8);
  buffer.createEntry(<String, num>{'a': 3, 'b': 4});
  assert(buffer.entryCount == 2);
  assert(buffer.buffer.lengthInBytes == 16);
}

/// 1:1: `test('dispose entry')`
void testDisposeEntry() {
  final IObjectCollectionBuffer buffer = _buffer(5);
  buffer.createEntry(<String, num>{'a': 1, 'b': 2});
  final entry1 = buffer.createEntry(<String, num>{'a': 3, 'b': 4});
  buffer.createEntry(<String, num>{'a': 5, 'b': 6});
  final entry2 = buffer.createEntry(<String, num>{'a': 7, 'b': 8});
  buffer.createEntry(<String, num>{'a': 9, 'b': 10});
  entry1.dispose();
  entry2.dispose();
  // Data from disposed entries is stale and doesn't need to be validated
  _assertUsedData(buffer, <int>[1, 2, 5, 6, 9, 10]);
}

/// 1:1: `test('entryCount, viewUsedSize, bufferUsedSize')`
void testEntryCountViewUsedSizeBufferUsedSize() {
  final IObjectCollectionBuffer buffer = _bufferFooBar(5);
  assert(buffer.entryCount == 0);
  assert(buffer.bufferUsedSize == 0);
  assert(buffer.viewUsedSize == 0);
  buffer.createEntry(<String, num>{'foo': 1, 'bar': 2});
  assert(buffer.entryCount == 1);
  assert(buffer.viewUsedSize == 2);
  assert(buffer.bufferUsedSize == 8);
  final entry = buffer.createEntry(<String, num>{'foo': 3, 'bar': 4});
  assert(buffer.entryCount == 2);
  assert(buffer.viewUsedSize == 4);
  assert(buffer.bufferUsedSize == 16);
  entry.dispose();
  assert(buffer.entryCount == 1);
  assert(buffer.viewUsedSize == 2);
  assert(buffer.bufferUsedSize == 8);
}

/// 1:1: `test('entry.get')`
void testEntryGet() {
  final IObjectCollectionBuffer buffer = _bufferFooBar(5);
  final entry = buffer.createEntry(<String, num>{'foo': 1, 'bar': 2});
  assert(entry.get('foo') == 1);
  assert(entry.get('bar') == 2);
}

/// 1:1: `test('entry.set')`
void testEntrySet() {
  final IObjectCollectionBuffer buffer = _bufferFooBar(5);
  final entry = buffer.createEntry(<String, num>{'foo': 1, 'bar': 2});
  int changeCount = 0;
  buffer.onDidChange((_) => changeCount++);
  entry.set('foo', 3);
  assert(changeCount == 1);
  assert(entry.get('foo') == 3);
  entry.set('bar', 4);
  assert(changeCount == 2);
  assert(entry.get('bar') == 4);
}

void runAll() {
  testCreateEntry();
  testCreateEntryBeyondCapacity();
  testDisposeEntry();
  testEntryCountViewUsedSizeBufferUsedSize();
  testEntryGet();
  testEntrySet();
}
