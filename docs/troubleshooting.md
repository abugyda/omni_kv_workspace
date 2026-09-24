# Troubleshooting

## `clear()` throws `UnsafeClearKvException`

Your persistent adapter is unscoped. Configure a codec prefix:

```dart
SharedPreferencesKvAdapter(
  SharedPreferencesAsync(),
  codec: const SharedPreferencesKvCodec(prefix: 'my_app.'),
);
```

Or deliberately opt in to clearing the entire unscoped backend:

```dart
await kv.clear(allowUnscoped: true);
```

## A required key throws `MissingValueKvException`

The key was defined with `KvKey.required` and does not exist. Either write it before reading or use a defaulted key when absence is valid state.

## A present value throws `TypeKvException`

The physical value could not be restored as the declared key type, or an adapter reported a present key with a null value. Check key converters, codec compatibility, and old persisted data.

## SharedPreferences rejects my object

The SharedPreferences adapter supports only `String`, `int`, `double`, `bool`, and `List<String>` after key conversion. Add a key-level converter for models, enums, dates, and other types.

## `watch()` does not exist

The selected adapter is non-reactive. `watch()` is compile-time gated to `WatchKvAdapter`. Use Hive CE/Memory or wrap a persistent adapter with `CachedKvAdapter` and a `MemoryKvAdapter` primary.

## `EncryptedKvCodec` throws `SerializationKvException`

Possible causes include corrupted ciphertext, a wrong decryption key/callback, or a delegate codec producing a value that cannot be represented by the encrypted JSON envelope.

## Namespaces are not visible in storage

`KvKey.namespace` affects the logical key (`key.name`). A codec prefix additionally controls the physical backend key. Adapters must operate on `KvKey.name`; `KeyValue` already does this.

## Cached data appears stale

Call `flush()` when you require write-behind durability before interacting with the persistent backend directly. Normal `CachedKvAdapter` reads already flush pending work before a persistent fallback on cache misses.
