import '../core/key_value.dart';
import '../core/kv_adapter.dart';
import '../core/kv_capability.dart';

/// Adapter contract for releasing resources.
abstract interface class ClosableKvAdapter<TCapability extends ClosableKvCapability>
    implements KvAdapter<TCapability> {
  Future<void> close();
}

/// Lifecycle operations exposed when the adapter supports [ClosableKvAdapter].
extension CloseKvOperations<TAdapter extends ClosableKvAdapter<dynamic>>
    on KeyValue<TAdapter> {
  Future<void> close() => adapter.close();
}
