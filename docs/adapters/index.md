# Adapters

OmniKV keeps provider dependencies outside the core package. Application code can stay centered on `KvKey<T>` and `KeyValue<TAdapter>` while backend packages own provider-specific setup and codecs.

## Built-in and official workspace adapters

| Adapter | Package | Capability profile |
| --- | --- | --- |
| `MemoryKvAdapter` | `omni_kv` | `MemoryKvCapability` / full reactive |
| `HiveCeKvAdapter` | `omni_kv_hive_ce` | `HiveCeKvCapability` / full reactive |
| `SharedPreferencesKvAdapter` | `omni_kv_shared_preferences` | `SharedPreferencesKvCapability` / persistent non-reactive |
| `SecureStorageKvAdapter` | `omni_kv_secure_storage` | `SecureStorageKvCapability` / persistent non-reactive |

## Backend pages

- [Hive CE](hive-ce.md)
- [SharedPreferences](shared-preferences.md)
- [Flutter Secure Storage](secure-storage.md)

## Core decorators

`CachedKvAdapter` composes a full reactive primary cache with a persistent adapter. `LoggingKvAdapter` wraps a full adapter and logs operations. `EncryptedKvCodec` wraps a codec to encrypt physical values while preserving logical encoded types.

See [Caching](../caching.md) and [Encryption](../encryption.md).
