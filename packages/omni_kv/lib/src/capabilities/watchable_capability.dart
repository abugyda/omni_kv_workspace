import '../core/key_value.dart';
import '../core/kv_adapter.dart';
import '../core/kv_capability.dart';
import '../core/kv_entry.dart';
import '../core/kv_key.dart';
import '../models/kv_change.dart';

/// Adapter contract for watching a specific logical key.
abstract interface class WatchKvAdapter<TCapability extends WatchKvCapability>
    implements KvAdapter<TCapability> {
  Stream<KvChange<Object?>> watch(String key);
}

/// Adapter contract for watching all changes within a namespace prefix.
abstract interface class NamespaceWatchKvAdapter<
  TCapability extends NamespaceWatchKvCapability
>
    implements WatchKvAdapter<TCapability> {
  Stream<KvChange<Object?>> watchAll([String? prefix]);
}

/// Watch operations exposed when the adapter supports [WatchKvAdapter].
extension WatchKvOperations<TAdapter extends WatchKvAdapter<dynamic>>
    on KeyValue<TAdapter> {
  Stream<KvChange<T>> watch<T>(KvKey<T> key) {
    return adapter.watch(key.name).map((change) {
      final value = change.value == null ? null : key.decode(change.value, isPresent: true);
      final previousValue = change.previousValue == null
          ? null
          : key.decode(change.previousValue, isPresent: true);

      return switch (change) {
        RemoveKvChange<Object?>() => RemoveKvChange<T>(
          key: change.key,
          previousValue: previousValue,
        ),
        _ => UpdateKvChange<T>(
          key: change.key,
          value: value,
          previousValue: previousValue,
        ),
      };
    });
  }
}

/// Namespace-watch operations for adapters that support global watching.
extension NamespaceWatchKvOperations<
  TAdapter extends NamespaceWatchKvAdapter<dynamic>
>
    on KeyValue<TAdapter> {
  Stream<KvChange<Object?>> watchNamespace(String namespace) {
    return adapter.watchAll('$namespace.');
  }
}

/// Watch operations for a typed [KvEntry].
extension WatchKvEntryOperations<T, TAdapter extends WatchKvAdapter<dynamic>>
    on KvEntry<T, TAdapter> {
  Stream<KvChange<T>> watch() => keyValue.watch(key);
}
