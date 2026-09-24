import '../core/key_value.dart';
import '../core/kv_adapter.dart';
import '../core/kv_capability.dart';
import '../core/kv_entry.dart';
import '../core/kv_key.dart';

/// Adapter contract for removing values.
abstract interface class RemoveKvAdapter<TCapability extends RemoveKvCapability>
    implements KvAdapter<TCapability> {
  Future<void> remove(String key);
}

/// Remove operations exposed when the adapter supports [RemoveKvAdapter].
extension RemoveKvOperations<TAdapter extends RemoveKvAdapter<dynamic>>
    on KeyValue<TAdapter> {
  Future<void> remove<T>(KvKey<T> key) => adapter.remove(key.name);
}

/// Remove operations for a typed [KvEntry].
extension RemoveKvEntryOperations<T, TAdapter extends RemoveKvAdapter<dynamic>>
    on KvEntry<T, TAdapter> {
  Future<void> remove() => keyValue.remove(key);
}
