# omni_kv_shared_preferences

OmniKV adapter for the modern `SharedPreferencesAsync` API.

```dart
final preferences = SharedPreferencesAsync();
final kv = KeyValue(
  SharedPreferencesKvAdapter(
    preferences,
    codec: const SharedPreferencesKvCodec(prefix: 'adouli.'),
  ),
);

await kv(AppKeys.locale).write('am');
```

The adapter supports `String`, `int`, `double`, `bool`, and `List<String>` after key conversion. It is intentionally non-reactive; use `CachedKvAdapter` with `MemoryKvAdapter` when streams are required.

Documentation: https://docs.abugyda.com/omni-kv/adapters/shared-preferences
