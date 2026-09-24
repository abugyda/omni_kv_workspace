# SharedPreferences adapter

Package: `omni_kv_shared_preferences`

The canonical adapter uses `SharedPreferencesAsync`, not the legacy cached `SharedPreferences` API. This aligns with OmniKV's asynchronous contract and avoids relying on a potentially stale process-local preferences cache.

```yaml
dependencies:
  omni_kv: ^0.2.0
  omni_kv_shared_preferences: ^0.2.0
  shared_preferences: ^2.5.5
```

```dart
final preferences = SharedPreferencesAsync();
final kv = KeyValue(
  SharedPreferencesKvAdapter(
    preferences,
    codec: const SharedPreferencesKvCodec(prefix: 'adouli.'),
  ),
);
```

## Native values

After key conversion, `SharedPreferencesKvCodec` supports:

- `String`
- `int`
- `double`
- `bool`
- `List<String>`

Use a `KvConverter` when an application type needs another representation.

## Clear behavior

Scoped clear obtains the physical key set, keeps only keys owned by the codec, and calls `SharedPreferencesAsync.clear(allowList: ...)`. Unscoped clear requires `allowUnscoped: true`.

## Watches

SharedPreferences does not provide OmniKV's watch contract, so `watch()` and `watchNamespace()` are intentionally unavailable at compile time. Wrap it in `CachedKvAdapter` with `MemoryKvAdapter` when the application needs reactive local state plus preferences persistence.
