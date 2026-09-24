# Adapter authoring

Custom adapters should implement the narrowest OmniKV contracts that accurately describe the backend.

## 1. Choose a capability profile

Create a marker profile implementing the relevant composite capability.

```dart
final class MyKvCapability implements ReadWriteClearBatchKvCapability {
  const MyKvCapability();
}
```

## 2. Implement adapter contracts

```dart
final class MyKvAdapter
    with SequentialKvBatchAdapter<MyKvCapability>
    implements ReadWriteClearBatchKvAdapter<MyKvCapability> {
  MyKvAdapter(this.backend, {this.codec = const MyKvCodec()});

  final MyBackend backend;

  @override
  final KvCodec codec;

  // read, contains, write, remove, clear, close...
}
```

Use `FullKvAdapter` only when the backend can provide the watch semantics OmniKV documents.

## 3. Respect null semantics

`write(key, null)` must behave as removal.

## 4. Apply the codec exactly once

Adapter methods receive logical key names and logical key-converted values. Convert physical keys with `codec.storageKey()`, values with `codec.encode()` on writes, and `codec.decode()` on reads/watch events.

Watch streams must emit logical decoded adapter values, not physical encoded values.

## 5. Protect destructive clear

For persistent shared backends, call `ensureScopedClearAllowed()` and delete only keys for which `codec.ownsKey()` is true.

## 6. Batch semantics

`BatchKvAdapter.batch()` must preserve operation order. Use `SequentialKvBatchAdapter` when the backend does not have a native batch facility. Do not imply atomic rollback unless your adapter explicitly provides it.

## 7. Run conformance tests

Use `omni_kv_testing` as the minimum adapter contract, then add backend-specific tests for scoping, serialization, lifecycle, and provider behavior.
