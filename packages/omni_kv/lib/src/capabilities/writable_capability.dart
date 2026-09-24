import '../core/key_value.dart';
import '../core/kv_adapter.dart';
import '../core/kv_capability.dart';
import '../core/kv_entry.dart';
import '../core/kv_key.dart';

/// Adapter contract for writing values.
///
/// A null value means removal across the OmniKV adapter contract.
abstract interface class WriteKvAdapter<TCapability extends WriteKvCapability>
    implements KvAdapter<TCapability> {
  Future<void> write(String key, Object? value);
}

/// Write operations exposed when the adapter supports [WriteKvAdapter].
extension WriteKvOperations<TAdapter extends WriteKvAdapter<dynamic>>
    on KeyValue<TAdapter> {
  Future<void> write<T>(KvKey<T> key, T value) {
    return adapter.write(key.name, key.encode(value));
  }

  Future<void> set<T>(KvKey<T> key, T value) => write(key, value);
}

/// Write operations for a typed [KvEntry].
extension WriteKvEntryOperations<T, TAdapter extends WriteKvAdapter<dynamic>>
    on KvEntry<T, TAdapter> {
  Future<void> write(T value) => keyValue.write(key, value);
}
