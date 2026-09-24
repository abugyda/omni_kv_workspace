# omni_kv_secure_storage

Flutter Secure Storage adapter for OmniKV.

```dart
const storage = FlutterSecureStorage();
final kv = KeyValue(
  SecureStorageKvAdapter(
    storage,
    codec: const SecureStorageKvCodec(prefix: 'adouli.'),
  ),
);

await kv(AuthKeys.token).write(token);
```

`SecureStorageKvCodec` JSON-encodes logical values to strings. The adapter supports read/write/remove, ordered batch, scoped clear, and close; it does not expose watch operations.

Documentation: https://docs.abugyda.com/omni-kv/adapters/secure-storage
