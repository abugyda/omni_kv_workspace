# Hive CE adapter

Package: `omni_kv_hive_ce`

`HiveCeKvAdapter` provides the full OmniKV contract: read, write, remove, clear, batch, close, key watch, and namespace watch.

```yaml
dependencies:
  omni_kv: ^0.2.0
  omni_kv_hive_ce: ^0.2.0
  hive_ce: ^2.19.3
```

```dart
final box = await Hive.openBox<Object?>('app');
final kv = KeyValue(
  HiveCeKvAdapter(
    box,
    codec: const HiveCeKvCodec(prefix: 'adouli.'),
  ),
);
```

## Scoping

Set `HiveCeKvCodec.prefix` when a box may contain keys not owned by this OmniKV instance. Scoped `clear()` deletes only owned keys, and `watchAll()` filters out events outside the codec scope.

## Watches

Hive events are translated into logical `KvChange<Object?>` values before key-level conversion. Delete events expose the previous value when Hive supplies it.

## Lifecycle

`kv.close()` closes the underlying Hive box because the adapter implements `ClosableKvAdapter`.
