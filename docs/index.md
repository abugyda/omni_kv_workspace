# OmniKV

OmniKV is a strongly typed, storage-agnostic key-value framework for Dart and Flutter. It gives applications one typed key model and one ergonomic facade while allowing each backend to expose only the operations it actually supports.

The primary API is `KeyValue<TAdapter>`.

```dart
import 'package:omni_kv/omni_kv.dart';

const theme = KvKey<String>('theme', defaultValue: 'system', namespace: 'app');

final kv = KeyValue(
  MemoryKvAdapter(codec: const MemoryKvCodec(prefix: 'demo.')),
);

await kv(theme).write('dark');
final value = await kv(theme).read();
```

## Why OmniKV

- Strongly typed `KvKey<T>` definitions with defaults, required values, namespaces, and converters.
- Compile-time operation gating through adapter contracts such as `ReadKvAdapter`, `WatchKvAdapter`, and `BatchKvAdapter`.
- Provider-neutral application code with separate Hive CE, SharedPreferences, and secure-storage packages.
- Scoped physical keys for safer destructive operations.
- Reactive watches when the selected adapter supports them.
- Ordered batches, memory caching, write-through/write-behind persistence, logging, and optional encrypted codecs.
- Reusable adapter conformance suites through `omni_kv_testing`.

## Packages

| Package | Purpose |
| --- | --- |
| `omni_kv` | Core keys, facade, contracts, converters, memory adapter, cache/logging/encryption utilities. |
| `omni_kv_hive_ce` | Full local/reactive Hive CE adapter. |
| `omni_kv_shared_preferences` | Persistent preferences adapter using `SharedPreferencesAsync`. |
| `omni_kv_secure_storage` | Persistent Flutter Secure Storage adapter. |
| `omni_kv_testing` | Reusable adapter conformance tests and fixtures. |

## Choose an adapter

| Adapter | Read/write | Batch | Clear | Watch | Typical use |
| --- | ---: | ---: | ---: | ---: | --- |
| `MemoryKvAdapter` | Yes | Yes | Yes | Yes | Tests, sessions, reactive memory cache. |
| `HiveCeKvAdapter` | Yes | Yes | Yes | Yes | Local application data needing watches. |
| `SharedPreferencesKvAdapter` | Yes | Yes | Yes | No | Small preferences/settings. |
| `SecureStorageKvAdapter` | Yes | Yes | Yes | No | Tokens, secrets, sensitive small values. |

## Documentation

Start with [Getting started](getting-started.md), then read [Keys and converters](keys-and-converters.md) and [Operations and capabilities](operations-and-capabilities.md). Backend-specific setup is under [Adapters](adapters/index.md).

For package maintainers and adapter authors, see [Testing](testing.md), [Adapter authoring](adapter-authoring.md), and the [Public API reference](api-reference.md).
