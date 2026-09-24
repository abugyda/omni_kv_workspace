import '../core/kv_capability.dart';
import '../core/kv_codec.dart';
import '../models/kv_change.dart';
import '../models/kv_operation.dart';
import '../utilities/kv_exception.dart';
import 'composite_kv_adapters.dart';

/// Persistence strategy used by [CachedKvAdapter].
enum CachedKvWritePolicy {
  /// Await both primary and persistent writes before completing.
  writeThrough,

  /// Update the primary cache immediately and persist mutations in order.
  writeBehind,
}

/// Fast reactive cache over a slower persistent adapter.
///
/// Write-behind mutations are serialized in submission order. Reads that miss
/// the primary cache first flush queued persistence work, preventing a pending
/// remove/clear from rehydrating stale persistent data back into memory.
final class CachedKvAdapter implements FullKvAdapter<CachedKvCapability> {
  CachedKvAdapter({
    required this.primary,
    required this.persistent,
    this.writePolicy = CachedKvWritePolicy.writeBehind,
    this.onWriteBehindError,
  });

  final FullKvAdapter<dynamic> primary;
  final ReadWriteClearBatchKvAdapter<dynamic> persistent;
  final CachedKvWritePolicy writePolicy;
  final void Function(Object error, StackTrace stackTrace)? onWriteBehindError;

  Future<void> _writeBehindTail = Future<void>.value();
  WriteBehindKvException? _pendingWriteBehindError;
  StackTrace? _pendingWriteBehindStackTrace;

  @override
  KvCodec get codec => persistent.codec;

  @override
  Future<Object?> read(String key) async {
    if (await primary.contains(key)) {
      return primary.read(key);
    }

    await _flushBeforePersistentFallback();
    if (await persistent.contains(key)) {
      final diskValue = await persistent.read(key);
      await primary.write(key, diskValue);
      return diskValue;
    }

    return null;
  }

  @override
  Future<bool> contains(String key) async {
    if (await primary.contains(key)) return true;
    await _flushBeforePersistentFallback();
    return persistent.contains(key);
  }

  @override
  Future<void> write(String key, Object? value) async {
    await primary.write(key, value);
    await _persist(() => persistent.write(key, value));
  }

  @override
  Future<void> remove(String key) async {
    await primary.remove(key);
    await _persist(() => persistent.remove(key));
  }

  @override
  Future<void> clear({bool allowUnscoped = false}) async {
    await primary.clear(allowUnscoped: allowUnscoped);
    await _persist(
      () => persistent.clear(allowUnscoped: allowUnscoped),
    );
  }

  @override
  Future<void> batch(List<KvOperation> operations) async {
    await primary.batch(operations);
    await _persist(() => persistent.batch(operations));
  }

  /// Waits until the ordered write-behind queue becomes idle.
  ///
  /// Mutations added while a flush is in progress are included before the
  /// future completes.
  Future<void> flush() async {
    while (true) {
      final pending = _writeBehindTail;
      await pending;
      if (identical(pending, _writeBehindTail)) break;
    }

    final error = _pendingWriteBehindError;
    final stackTrace = _pendingWriteBehindStackTrace;
    _pendingWriteBehindError = null;
    _pendingWriteBehindStackTrace = null;

    if (error != null) {
      Error.throwWithStackTrace(error, stackTrace ?? StackTrace.current);
    }
  }

  @override
  Stream<KvChange<Object?>> watch(String key) => primary.watch(key);

  @override
  Stream<KvChange<Object?>> watchAll([String? prefix]) => primary.watchAll(prefix);

  @override
  Future<void> close() async {
    await flush();
    await primary.close();
    await persistent.close();
  }

  Future<void> _flushBeforePersistentFallback() async {
    if (writePolicy == CachedKvWritePolicy.writeBehind) {
      await flush();
    }
  }

  Future<void> _persist(Future<void> Function() action) async {
    switch (writePolicy) {
      case CachedKvWritePolicy.writeThrough:
        await action();
      case CachedKvWritePolicy.writeBehind:
        _writeBehindTail = _writeBehindTail.then((_) async {
          try {
            await action();
          } on Object catch (error, stackTrace) {
            final handler = onWriteBehindError;
            if (handler != null) {
              handler(error, stackTrace);
              return;
            }

            _pendingWriteBehindError ??= WriteBehindKvException(
              'CachedKvAdapter persistent write failed.',
              cause: error,
            );
            _pendingWriteBehindStackTrace ??= stackTrace;
          }
        });
    }
  }
}
