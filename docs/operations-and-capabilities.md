# Operations and capabilities

OmniKV intentionally separates **capability profiles** from **adapter behavior contracts**.

Capability marker types describe a provider's supported feature set. Adapter interfaces carry the actual methods. `KeyValue<TAdapter>` uses the adapter interface type to expose matching extension operations at compile time.

## Main operation groups

| Operation extensions | Required adapter contract | Main methods |
| --- | --- | --- |
| `ReadKvOperations` | `ReadKvAdapter` | `read`, `get`, `contains` |
| `WriteKvOperations` | `WriteKvAdapter` | `write`, `set` |
| `RemoveKvOperations` | `RemoveKvAdapter` | `remove` |
| `ClearKvOperations` | `ClearKvAdapter` | `clear` |
| `WatchKvOperations` | `WatchKvAdapter` | `watch` |
| `NamespaceWatchKvOperations` | `NamespaceWatchKvAdapter` | `watchNamespace` |
| `BatchKvOperations` | `BatchKvAdapter` | `batch` |
| `CloseKvOperations` | `ClosableKvAdapter` | `close` |

Typed `KvEntry` values additionally receive `ReadKvEntryOperations`, `WriteKvEntryOperations`, `RemoveKvEntryOperations`, and `WatchKvEntryOperations` when supported.

## Compile-time gating

A SharedPreferences-backed value can read/write/batch/clear/close, but there is no `watch()` extension because `SharedPreferencesKvAdapter` does not implement `WatchKvAdapter`.

A memory or Hive-backed value implements the full reactive contract and therefore receives watch operations.

This prevents unsupported operations from becoming runtime capability errors.

## Composite adapter contracts

`ReadWriteKvAdapter` combines read, write, and remove. `ReadWriteClearBatchKvAdapter` adds clear, batch, and close. `FullKvAdapter` additionally adds key and namespace watching.

## Capability profiles

The marker hierarchy includes:

- `KvCapability`
- `ReadKvCapability`
- `WriteKvCapability`
- `RemoveKvCapability`
- `ClearKvCapability`
- `WatchKvCapability`
- `NamespaceWatchKvCapability`
- `BatchKvCapability`
- `ClosableKvCapability`
- `ReadWriteKvCapability`
- `ReadWriteClearBatchKvCapability`
- `FullKvCapability`

Concrete profiles include `MemoryKvCapability`, `CachedKvCapability`, and `LoggingKvCapability`; adapter packages provide their own profiles.

The profiles are descriptive metadata for adapter types. Method availability is still determined by the adapter contracts themselves.

## Batches

```dart
await kv.batch((scope) async {
  await scope(AppKey.theme).write('dark');
  await scope(AppKey.oldToken).remove();
});
```

`BatchKvAdapter.batch()` guarantees ordered execution. Atomic rollback is **not** part of the core contract unless a particular adapter explicitly documents it.

`SequentialKvBatchAdapter` is a reusable mixin for adapters that implement batches as ordered write/remove calls.

## Watches

```dart
final subscription = kv(AppKey.theme).watch().listen((change) {
  print(change.value);
});
```

`UpdateKvChange<T>` represents a write/update and `RemoveKvChange<T>` represents removal. Adapter watch streams expose logical decoded adapter values; the key converter then restores `T`.

## Safe clear

Persistent backends can share their physical store with other code. OmniKV therefore requires a scoped codec before destructive clear unless the caller deliberately opts in.

```dart
final kv = KeyValue(
  SharedPreferencesKvAdapter(
    SharedPreferencesAsync(),
    codec: const SharedPreferencesKvCodec(prefix: 'adouli.'),
  ),
);

await kv.clear(); // only keys owned by adouli.
```

An unscoped persistent clear throws `UnsafeClearKvException`:

```dart
await kv.clear(allowUnscoped: true); // explicit whole-store intent
```

The helper `ensureScopedClearAllowed()` is available to adapter authors.
