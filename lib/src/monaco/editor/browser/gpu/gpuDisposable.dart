// 1:1 translation of vscode/src/vs/editor/browser/gpu/gpuDisposable.ts
// WebGPU DOM types (GPUDevice/GPUBuffer/GPUTexture/...) are carried as opaque
// interfaces; `navigator.gpu` is injected via [gpuNavigator] so the pure
// lifecycle logic can run headless.
import '../../../base/common/lifecycle.dart' show IReference;
import '../../../base/common/types.dart' show isFunction;

/// 1:1: the structural `{ destroy(): void }` constraint from the source.
abstract class Destroyable {
  void destroy();
}

/// 1:1: WebGPU `GPUDevice` (opaque handle). WebGPU devices expose `destroy()`.
abstract class GPUDevice implements Destroyable {
  @override
  void destroy();

  GPUBuffer createBuffer(Object descriptor);
  GPUTexture createTexture(Object descriptor);
  GPUQueue get queue;
}

/// 1:1: WebGPU `GPUQueue`.
abstract class GPUQueue {
  void writeBuffer(GPUBuffer buffer, int bufferOffset, Object data);
}

/// 1:1: WebGPU `GPUBuffer`.
abstract class GPUBuffer implements Destroyable {
  @override
  void destroy();
}

/// 1:1: WebGPU `GPUTexture`.
abstract class GPUTexture implements Destroyable {
  @override
  void destroy();
}

/// 1:1: WebGPU `GPUAdapter`.
abstract class GPUAdapter {
  Future<GPUDevice> requestDevice();
}

/// 1:1: WebGPU `GPU` entry object (`navigator.gpu`).
abstract class GPU {
  Future<GPUAdapter?> requestAdapter();
}

/// Injectable `navigator.gpu`. The source reads `navigator.gpu` directly;
/// Dart has no DOM, so embedders install it here.
GPU? gpuNavigator;

/// 1:1: `export namespace GPULifecycle`
class GPULifecycle {
  /// 1:1: `async function requestDevice(fallback?: (message: string) => void): Promise<IReference<GPUDevice>>`
  static Future<IReference<GPUDevice>> requestDevice([
    void Function(String message)? fallback,
  ]) async {
    try {
      final GPU? gpu = gpuNavigator;
      if (gpu == null) {
        throw StateError('This browser does not support WebGPU');
      }
      final GPUAdapter? adapter = await gpu.requestAdapter();
      if (adapter == null) {
        throw StateError(
          'This browser supports WebGPU but it appears to be disabled',
        );
      }
      return _wrapDestroyableInDisposable<GPUDevice>(await adapter.requestDevice());
    } catch (e) {
      if (fallback != null) {
        fallback(e is Error ? e.toString() : '$e');
      }
      rethrow;
    }
  }

  /// 1:1: `function createBuffer(device, descriptor, initialValues?): IReference<GPUBuffer>`
  static IReference<GPUBuffer> createBuffer(
    GPUDevice device,
    Object descriptor, [
    Object? initialValues,
  ]) {
    final GPUBuffer buffer = device.createBuffer(descriptor);
    if (initialValues != null) {
      final Object values = isFunction(initialValues)
          ? (initialValues as Function)() as Object
          : initialValues;
      device.queue.writeBuffer(buffer, 0, values);
    }
    return _wrapDestroyableInDisposable<GPUBuffer>(buffer);
  }

  /// 1:1: `function createTexture(device, descriptor): IReference<GPUTexture>`
  static IReference<GPUTexture> createTexture(
    GPUDevice device,
    Object descriptor,
  ) {
    return _wrapDestroyableInDisposable<GPUTexture>(
      device.createTexture(descriptor),
    );
  }
}

/// 1:1: `function wrapDestroyableInDisposable<T extends { destroy(): void }>(value): IReference<T>`
///
/// Returns `{ object: value, dispose: () => value.destroy() }`.
class _DestroyableReference<T extends Destroyable> implements IReference<T> {
  @override
  final T object;

  _DestroyableReference(this.object);

  @override
  void dispose() => object.destroy();
}

IReference<T> _wrapDestroyableInDisposable<T extends Destroyable>(T value) =>
    _DestroyableReference<T>(value);
