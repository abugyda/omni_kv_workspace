# Flutter Secure Storage adapter

Package: `omni_kv_secure_storage`

Use `SecureStorageKvAdapter` for small sensitive values such as authentication tokens or local secrets.

```yaml
dependencies:
  omni_kv: ^0.2.0
  omni_kv_secure_storage: ^0.2.0
  flutter_secure_storage: ^10.3.1
```

```dart
const storage = FlutterSecureStorage();
final kv = KeyValue(
  SecureStorageKvAdapter(
    storage,
    codec: const SecureStorageKvCodec(prefix: 'adouli.'),
  ),
);
```

`SecureStorageKvCodec` JSON-encodes logical values to strings because Flutter Secure Storage persists strings.

## Clear behavior

The adapter reads the backend key set and deletes only keys owned by the configured codec. Unscoped clear requires explicit `allowUnscoped: true`.

## Watches

The adapter is non-reactive. If UI code needs immediate streams, use `CachedKvAdapter` with a `MemoryKvAdapter` primary cache and secure storage as the persistent adapter.
