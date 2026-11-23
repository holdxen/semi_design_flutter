// 1:1 port of vs/base/test/common/virtualScheduling/embedding.ts

import '../../../common/platform.dart'
    show setTimeout0, setTimeout0IsFaster;
import 'timeApi.dart' show TimeApi;
import 'virtualClock.dart' show VirtualEvent;

/// 1:1: `export type Embedding = (nextEvent, then) => 'continueSync' | 'cbScheduled'`
typedef Embedding = String Function(VirtualEvent nextEvent, void Function() then);

/// 1:1: `export const syncEmbedding: Embedding = () => 'continueSync'`
final Embedding syncEmbedding = (VirtualEvent nextEvent, void Function() then) =>
    'continueSync';

/// 1:1: `export function drainMicrotasksEmbedding(realApi: TimeApi): Embedding`
Embedding drainMicrotasksEmbedding(TimeApi realApi) {
  return (VirtualEvent next, void Function() then) {
    final raf = realApi.requestAnimationFrame;
    if (next.preferRealAnimationFrame && raf != null) {
      raf((_) => then());
    } else {
      nextMacrotask(realApi, then);
    }
    return 'cbScheduled';
  };
}

/// 1:1: `export function nextMacrotask(api: TimeApi, cb: () => void): void`
void nextMacrotask(TimeApi api, void Function() cb) {
  if (setTimeout0IsFaster) {
    setTimeout0(cb);
    return;
  }
  final void Function(void Function())? immediate = api.setImmediate;
  if (immediate != null) {
    immediate(cb);
    return;
  }
  api.setTimeout(cb, 0);
}
