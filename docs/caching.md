# Caching

`CachedKvAdapter` combines a full reactive primary adapter with a persistent non-reactive adapter.

```dart
final cache = CachedKvAdapter(
  primary: MemoryKvAdapter(),
  persistent: SharedPreferencesKvAdapter(
    SharedPreferencesAsync(),
    codec: const SharedPreferencesKvCodec(prefix: 'app.'),
  ),
  writePolicy: CachedKvWritePolicy.writeBehind,
);

final kv = KeyValue(cache);
```

## Read path

A read checks the primary adapter first. If the primary does not contain the key, write-behind persistence is flushed before consulting persistent storage. That ordering prevents a pending remove or clear from rehydrating stale data.

A persistent hit is copied back into the primary cache before being returned.

## Write-through

`CachedKvWritePolicy.writeThrough` updates the primary cache and awaits persistence before the operation completes.

## Write-behind

`CachedKvWritePolicy.writeBehind` updates the primary immediately and queues persistent mutations. The queue is serialized, so writes, removes, clears, and batches reach persistence in submission order.

Call `flush()` when durable completion is required. A flush waits until the ordered queue becomes idle, including mutations added while that flush is already in progress:

```dart
await kv(AppKey.theme).write('dark');
await cache.flush();
```

`close()` flushes before closing both adapters.

## Errors

Without an `onWriteBehindError` handler, persistence failures are retained and surfaced by `flush()` as `WriteBehindKvException`. When a handler is supplied, the callback receives the underlying error and stack trace and the queue can continue processing later mutations.
