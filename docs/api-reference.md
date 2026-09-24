# Public API reference

This page inventories the exported public API across the OmniKV workspace. It is intentionally grouped by package and responsibility so `docs.abugyda.com/omni-kv` can serve as a complete navigation layer in addition to generated Dart API docs.

## `omni_kv`

### Main facade and keys

| API | Purpose |
| --- | --- |
| `KeyValue<TAdapter>` | Main typed facade over one concrete adapter. `call()` and `entry()` create typed `KvEntry` values. |
| `KvKey<T>` | Typed logical key with `id`, optional `namespace`, default/default builder or required semantics, and optional converter. |
| `KvEntry<T, TAdapter>` | A `KvKey<T>` bound to one `KeyValue<TAdapter>`. |
| `KvConverter<T, S>` | Key-level encode/decode contract. |
| `KvCodec` | Adapter-level key/value codec contract: `isScoped`, `storageKey`, `logicalKey`, `ownsKey`, `encode`, and `decode`. |
| `KvAdapter<TCapability>` | Base adapter interface exposing its `codec`. |

### Read, write, remove, clear, watch, batch, lifecycle

| API | Purpose |
| --- | --- |
| `ReadKvAdapter<TCapability>` | Adapter `read()` and `contains()` contract. |
| `ReadKvOperations` | `KeyValue.read()`, `get()`, and `contains()`. |
| `ReadKvEntryOperations` | `KvEntry.read()` and `exists()`. |
| `WriteKvAdapter<TCapability>` | Adapter `write()` contract; null means removal. |
| `WriteKvOperations` | `KeyValue.write()` and `set()`. |
| `WriteKvEntryOperations` | `KvEntry.write()`. |
| `RemoveKvAdapter<TCapability>` | Adapter `remove()` contract. |
| `RemoveKvOperations` | `KeyValue.remove()`. |
| `RemoveKvEntryOperations` | `KvEntry.remove()`. |
| `ClearKvAdapter<TCapability>` | Adapter `clear()` contract. |
| `ClearKvOperations` | `KeyValue.clear()`. |
| `ensureScopedClearAllowed()` | Adapter-author helper that prevents accidental unscoped persistent clear. |
| `WatchKvAdapter<TCapability>` | Single-key watch contract. |
| `NamespaceWatchKvAdapter<TCapability>` | Extends watch with `watchAll()`. |
| `WatchKvOperations` | Typed `KeyValue.watch()`. |
| `NamespaceWatchKvOperations` | `KeyValue.watchNamespace()`. |
| `WatchKvEntryOperations` | `KvEntry.watch()`. |
| `BatchKvAdapter<TCapability>` | Ordered low-level batch contract. |
| `SequentialKvBatchAdapter<TCapability>` | Mixin implementing batch by sequential write/remove calls. |
| `KvOperationRecorder` | Batch DSL operation collector used by `KeyValue.batch()`. |
| `KvBatchScope` | Restricted batch-building `KeyValue` scope. |
| `BatchKvOperations` | `KeyValue.batch()`. |
| `ClosableKvAdapter<TCapability>` | Adapter `close()` contract. |
| `CloseKvOperations` | `KeyValue.close()`. |

### Composite adapter contracts

| API | Purpose |
| --- | --- |
| `ReadWriteKvAdapter<TCapability>` | Composite read/write/remove adapter contract. |
| `ReadWriteClearBatchKvAdapter<TCapability>` | Persistent read/write/remove/clear/batch/close contract. |
| `FullKvAdapter<TCapability>` | Full local/reactive contract including key and namespace watches. |

### Capability types

| API | Purpose |
| --- | --- |
| `KvCapability` | Root capability marker. |
| `ReadKvCapability` | Read marker. |
| `WriteKvCapability` | Write marker. |
| `RemoveKvCapability` | Remove marker. |
| `ClearKvCapability` | Clear marker. |
| `WatchKvCapability` | Single-key watch marker. |
| `NamespaceWatchKvCapability` | Namespace/global watch marker. |
| `BatchKvCapability` | Batch marker. |
| `ClosableKvCapability` | Lifecycle close marker. |
| `ReadWriteKvCapability` | Composite read/write/remove marker. |
| `ReadWriteClearBatchKvCapability` | Composite persistent marker. |
| `FullKvCapability` | Composite full reactive marker. |
| `MemoryKvCapability` | `MemoryKvAdapter` capability profile. |
| `CachedKvCapability` | `CachedKvAdapter` capability profile. |
| `LoggingKvCapability` | `LoggingKvAdapter` capability profile. |
| `KvOperationRecorderCapability` | Restricted write/remove batch-recorder profile. |

### Core adapters and decorators

| API | Purpose |
| --- | --- |
| `MemoryKvAdapter` | Full reactive in-memory adapter; useful directly and as a cache. |
| `MemoryKvCodec` | Identity-like codec with optional physical key prefix. |
| `CachedKvAdapter` | Reactive primary cache plus persistent adapter composition. |
| `CachedKvWritePolicy` | `writeThrough` or ordered `writeBehind`. |
| `LoggingKvAdapter` | Full-adapter decorator that logs operations. |
| `EncryptedKvCodec` | Versioned type-preserving encrypted codec decorator. |

### Changes and batches

| API | Purpose |
| --- | --- |
| `KvChange<T>` | Base watch change with key, value, and previous value. |
| `UpdateKvChange<T>` | Write/update watch event. |
| `RemoveKvChange<T>` | Removal watch event. |
| `KvOperation` | Base low-level batch operation. |
| `WriteKvOperation` | Batch write command. |
| `RemoveKvOperation` | Batch remove command. |

### Converters

| API | Purpose |
| --- | --- |
| `EnumKvConverter<TEnum>` | Enum name/index factories. |
| `DateTimeKvConverter` | Date/time representation. |
| `DurationKvConverter` | Duration representation. |
| `BigIntKvConverter` | Big integer representation. |
| `UriKvConverter` | URI representation. |
| `JsonKvConverter<T>` | JSON conversion. |
| `ModelKvConverter<T>` | Model conversion via callbacks. |
| `RecordKvConverter<T>` | Record conversion via callbacks. |
| `InlineKvConverter<T, S>` | Inline custom conversion callbacks. |
| `ListKvConverter<T>` | Element-wise list conversion. |
| `SetKvConverter<T>` | Element-wise set conversion stored as a list. |

### Exceptions

| API | Meaning |
| --- | --- |
| `KvException` | Base OmniKV exception with message, optional cause, and stable name. |
| `MissingValueKvException` | Required key is absent. |
| `TypeKvException` | Value cannot be restored as the declared key type or violates null semantics. |
| `SerializationKvException` | Serialization/encryption envelope failure. |
| `UnsupportedValueKvException` | Backend codec cannot represent the supplied logical value. |
| `UnsafeClearKvException` | Destructive unscoped persistent clear was not explicitly allowed. |
| `WriteBehindKvException` | Deferred persistent mutation failed and is surfaced by cache flush. |

## `omni_kv_hive_ce`

| API | Purpose |
| --- | --- |
| `HiveCeKvAdapter` | Full reactive Hive CE adapter. |
| `HiveCeKvCodec` | Hive key/value codec with optional prefix scoping. |
| `HiveCeKvCapability` | Hive adapter capability profile. |

## `omni_kv_shared_preferences`

| API | Purpose |
| --- | --- |
| `SharedPreferencesKvAdapter` | Persistent adapter built on `SharedPreferencesAsync`. |
| `SharedPreferencesKvCodec` | Native SharedPreferences value codec with optional prefix. |
| `SharedPreferencesKvCapability` | SharedPreferences adapter capability profile. |

## `omni_kv_secure_storage`

| API | Purpose |
| --- | --- |
| `SecureStorageKvAdapter` | Persistent Flutter Secure Storage adapter. |
| `SecureStorageKvCodec` | JSON-to-string secure-storage codec with optional prefix. |
| `SecureStorageKvCapability` | Secure-storage adapter capability profile. |

## `omni_kv_testing`

| API | Purpose |
| --- | --- |
| `TestKey<T>` | Canonical typed key fixture used by conformance suites. |
| `TestKeyValueX` | Adds the `test()` namespace helper to `KeyValue`. |
| `CreateKvAdapter<TAdapter>` | Async adapter factory callback typedef. |
| `DisposeKvAdapter<TAdapter>` | Async adapter disposal callback typedef. |
| `runReadWriteKvAdapterTests()` | Read/write/remove/default/null contract suite. |
| `runClearKvAdapterTests()` | Clear contract suite. |
| `runBatchKvAdapterTests()` | Ordered batch contract suite. |
| `runWatchKvAdapterTests()` | Watch update/remove contract suite. |
| `runPersistentKvAdapterTests()` | Combined non-reactive persistent adapter suite. |
| `runFullKvAdapterTests()` | Combined full reactive adapter suite. |

## Stability note

OmniKV is pre-1.0. Public APIs may still change while the Omni ecosystem converges, but breaking changes should be documented in [Migration](migration.md) and package changelogs.
