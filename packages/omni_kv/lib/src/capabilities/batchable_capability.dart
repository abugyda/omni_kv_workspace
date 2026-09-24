import 'dart:async';

import '../core/key_value.dart';
import '../core/kv_adapter.dart';
import '../core/kv_capability.dart';
import '../core/kv_codec.dart';
import '../models/kv_operation.dart';
import 'removable_capability.dart';
import 'writable_capability.dart';

/// Adapter contract for grouped ordered writes/removes.
///
/// Batch execution is ordered. It does not guarantee atomic rollback unless a
/// specific adapter documents that behavior.
abstract interface class BatchKvAdapter<TCapability extends BatchKvCapability>
    implements KvAdapter<TCapability> {
  Future<void> batch(List<KvOperation> operations);
}

/// Reusable sequential batch behavior for adapters that already support writes
/// and removals.
mixin SequentialKvBatchAdapter<TCapability extends BatchKvCapability>
    implements BatchKvAdapter<TCapability> {
  Future<void> write(String key, Object? value);

  Future<void> remove(String key);

  @override
  Future<void> batch(List<KvOperation> operations) async {
    for (final operation in operations) {
      switch (operation) {
        case WriteKvOperation(:final key, :final value):
          await write(key, value);
        case RemoveKvOperation(:final key):
          await remove(key);
      }
    }
  }
}

/// Collects operations through the normal fluent entry API without executing them.
final class KvOperationRecorder
    implements
        KvAdapter<KvOperationRecorderCapability>,
        WriteKvAdapter<KvOperationRecorderCapability>,
        RemoveKvAdapter<KvOperationRecorderCapability> {
  KvOperationRecorder();

  final List<KvOperation> _operations = [];

  @override
  final KvCodec codec = const _RecorderKvCodec();

  List<KvOperation> get operations => List<KvOperation>.unmodifiable(_operations);

  @override
  Future<void> write(String key, Object? value) {
    if (value == null) {
      _operations.add(RemoveKvOperation(key));
    } else {
      _operations.add(WriteKvOperation(key, value));
    }

    return Future<void>.value();
  }

  @override
  Future<void> remove(String key) {
    _operations.add(RemoveKvOperation(key));
    return Future<void>.value();
  }
}

/// A restricted key-value scope that only permits write and remove operations.
typedef KvBatchScope = KeyValue<KvOperationRecorder>;

extension BatchKvOperations<TAdapter extends BatchKvAdapter<dynamic>>
    on KeyValue<TAdapter> {
  /// Executes a sequence of write and remove operations as a single batch.
  Future<void> batch(
    FutureOr<void> Function(KvBatchScope scope) build,
  ) async {
    final recorder = KvOperationRecorder();
    await build(KvBatchScope(recorder));
    return adapter.batch(recorder.operations);
  }
}

final class _RecorderKvCodec implements KvCodec {
  const _RecorderKvCodec();

  @override
  bool get isScoped => true;

  @override
  String storageKey(String logicalKey) => logicalKey;

  @override
  String logicalKey(Object? storageKey) => storageKey as String;

  @override
  bool ownsKey(Object? storageKey) => true;

  @override
  Object? encode(Object? value) => value;

  @override
  Object? decode(Object? value) => value;
}
