// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/sequence.ts
// Translated 1:1 from TypeScript.
// ---------------------------------------------------------------------------

import 'event.dart' as event;

/// 1:1: `export interface ISplice<T>`
class ISplice<T> {
  final int start;
  final int deleteCount;
  final List<T> toInsert;
  ISplice({required this.start, required this.deleteCount, required this.toInsert});
}

/// 1:1: `export interface ISpliceable<T>`
abstract class ISpliceable<T> {
  void splice(int start, int deleteCount, List<T> toInsert);
}

/// 1:1: `export interface ISequence<T>`
abstract class ISequence<T> {
  List<T> get elements;
  event.Event<ISplice<T>> get onDidSplice;
}

/// 1:1: `export class Sequence<T>`
class Sequence<T> implements ISequence<T>, ISpliceable<T> {
  @override
  final List<T> elements = <T>[];

  final event.Emitter<ISplice<T>> _onDidSplice = event.Emitter<ISplice<T>>();
  @override
  late final event.Event<ISplice<T>> onDidSplice;

  Sequence() {
    onDidSplice = _onDidSplice.event;
  }

  @override
  void splice(int start, int deleteCount, List<T> toInsert) {
    elements.replaceRange(start, start + deleteCount, toInsert);
    _onDidSplice.fire(ISplice<T>(start: start, deleteCount: deleteCount, toInsert: toInsert));
  }
}
