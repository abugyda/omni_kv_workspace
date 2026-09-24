# OmniKV Workspace

OmniKV is the Omni ecosystem's strongly typed, storage-agnostic key-value layer for Dart and Flutter.

The canonical facade is `KeyValue<TAdapter>`:

```dart
final kv = KeyValue(MemoryKvAdapter());
await kv.write(AppKeys.theme, AppTheme.dark);
final theme = await kv.read(AppKeys.theme);
```

## Packages

- `omni_kv` — typed keys, `KeyValue`, converters, operation contracts, memory adapter, caching, logging, encryption.
- `omni_kv_hive_ce` — full reactive Hive CE adapter.
- `omni_kv_shared_preferences` — `SharedPreferencesAsync` adapter.
- `omni_kv_secure_storage` — Flutter Secure Storage adapter.
- `omni_kv_testing` — reusable adapter conformance suites.
- `example` — Dart and Flutter integration examples.

All publishable packages are aligned at `0.2.0`.

## Design rules

OmniKV keeps application types, logical storage values, and backend storage values separate. `KvKey<T>` and `KvConverter` own typed application conversion; `KvCodec` owns backend key/value representation; adapters own provider behavior.

Operation availability is compile-time gated by adapter interfaces. A reactive adapter receives watch operations; a non-reactive preferences adapter does not. Capability marker profiles describe adapter feature sets without becoming a runtime capability lookup mechanism.

Bundled adapters share one null rule: writing `null` removes the key.

## Workspace commands

```bash
dart pub get
dart run melos run format:apply
dart run melos run analyze
dart run melos run test
dart run melos run docs:check
dart run melos run capabilities:check
dart run melos run workspace:check
dart run melos run verify
dart run melos run publish:dry-run
```

Flutter package tests run serially to avoid concurrent Flutter startup/resource conflicts.

## Documentation

The `docs/` directory is the canonical Markdown source for `https://docs.abugyda.com/omni-kv`.

Start at [`docs/index.md`](docs/index.md). The documentation includes concepts, typed keys, converters, capability-gated operations, every adapter, caching, encryption, testing, adapter authoring, migration guidance, troubleshooting, release checks, and a complete public API inventory.
