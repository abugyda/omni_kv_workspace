import '../core/key_value.dart';
import '../core/kv_adapter.dart';
import '../core/kv_capability.dart';
import '../utilities/kv_exception.dart';

/// Adapter contract for clearing values controlled by an adapter.
///
/// Persistent implementations should clear only keys owned by their codec.
/// Unscoped clears must require explicit opt-in.
abstract interface class ClearKvAdapter<TCapability extends ClearKvCapability>
    implements KvAdapter<TCapability> {
  Future<void> clear({bool allowUnscoped = false});
}

/// Clear operations exposed when the adapter supports [ClearKvAdapter].
extension ClearKvOperations<TAdapter extends ClearKvAdapter<dynamic>>
    on KeyValue<TAdapter> {
  Future<void> clear({bool allowUnscoped = false}) {
    return adapter.clear(allowUnscoped: allowUnscoped);
  }
}

/// Guards destructive clears for shared persistent backends.
void ensureScopedClearAllowed({
  required bool isScoped,
  required bool allowUnscoped,
  required String adapterName,
}) {
  if (isScoped || allowUnscoped) return;

  throw UnsafeClearKvException(
    '$adapterName.clear() would clear an unscoped storage backend. '
    'Configure a codec prefix or pass allowUnscoped: true deliberately.',
  );
}
