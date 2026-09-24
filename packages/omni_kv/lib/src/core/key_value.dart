import 'kv_adapter.dart';
import 'kv_entry.dart';
import 'kv_key.dart';

/// Strongly typed facade over an OmniKV adapter.
///
/// The adapter type determines which operation extensions are available at
/// compile time. For example, `watch` operations are only exposed when the
/// adapter implements the watch contract.
final class KeyValue<TAdapter extends KvAdapter<dynamic>> {
  const KeyValue(this.adapter);

  /// Concrete storage adapter used by this key-value facade.
  final TAdapter adapter;

  /// Fluent entry point, for example `kv(AppKeys.theme).read()`.
  KvEntry<T, TAdapter> call<T>(KvKey<T> key) => entry(key);

  /// Creates a typed entry bound to [key].
  KvEntry<T, TAdapter> entry<T>(KvKey<T> key) => KvEntry<T, TAdapter>(this, key);
}
