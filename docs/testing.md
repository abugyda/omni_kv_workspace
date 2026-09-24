# Testing

Package: `omni_kv_testing`

The testing package contains canonical key fixtures plus reusable contract suites. Official adapter packages run these suites in addition to backend-specific semantic tests.

## Persistent adapters

```dart
void main() {
  group('My adapter conformance', () {
    runPersistentKvAdapterTests<MyAdapter>(
      createAdapter: () async => MyAdapter(...),
      disposeAdapter: (adapter) => adapter.close(),
    );
  });
}
```

This runs read/write/remove, null-as-remove, clear, and batch contracts.

## Full reactive adapters

```dart
runFullKvAdapterTests<MyReactiveAdapter>(
  createAdapter: () async => MyReactiveAdapter(...),
  disposeAdapter: (adapter) => adapter.close(),
);
```

The full suite additionally validates watch behavior.

## Individual suites

- `runReadWriteKvAdapterTests`
- `runClearKvAdapterTests`
- `runBatchKvAdapterTests`
- `runWatchKvAdapterTests`
- `runPersistentKvAdapterTests`
- `runFullKvAdapterTests`

`CreateKvAdapter<TAdapter>` and `DisposeKvAdapter<TAdapter>` are callback typedefs used by these suites.

## Compile-time capability gating

The root `capabilities:check` script creates an analyzer probe that intentionally calls `watch()` on `KeyValue<SharedPreferencesKvAdapter>`. Verification succeeds only when the analyzer rejects that call, protecting the compile-time operation boundary.

```bash
dart run melos run capabilities:check
```

## Official regression coverage

The workspace adds focused tests for:

- nullable writes removing keys;
- encrypted codec type preservation and corruption handling;
- memory watches returning logical decoded values;
- Hive scoped namespace-watch ownership;
- ordered write-behind persistence;
- stale-cache prevention while remove/clear operations are pending;
- scoped persistent clears preserving unrelated keys.
