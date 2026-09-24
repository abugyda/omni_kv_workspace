# omni_kv_hive_ce

Hive CE adapter for OmniKV with read/write/remove, batch, scoped clear, lifecycle, key watches, and namespace watches.

```dart
final box = await Hive.openBox<Object?>('app');
final kv = KeyValue(
  HiveCeKvAdapter(
    box,
    codec: const HiveCeKvCodec(prefix: 'adouli.'),
  ),
);

await kv(AppKeys.theme).write('dark');
final subscription = kv(AppKeys.theme).watch().listen(print);
```

Use a codec prefix when the box may contain keys outside this OmniKV scope.

Documentation: https://docs.abugyda.com/omni-kv/adapters/hive-ce
