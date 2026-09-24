import 'key_value.dart';
import 'kv_adapter.dart';
import 'kv_key.dart';

/// A typed key bound to a [KeyValue] instance.
final class KvEntry<T, TAdapter extends KvAdapter<dynamic>> {
  const KvEntry(this.keyValue, this.key);

  final KeyValue<TAdapter> keyValue;
  final KvKey<T> key;
}
