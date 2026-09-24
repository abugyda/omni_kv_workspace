# omni_kv_testing

Reusable conformance suites and typed fixtures for OmniKV adapters.

```dart
runPersistentKvAdapterTests<MyAdapter>(
  createAdapter: () async => MyAdapter(...),
  disposeAdapter: (adapter) => adapter.close(),
);
```

Use `runFullKvAdapterTests` for full reactive adapters. Individual read/write, clear, batch, and watch suites are also exported.

Documentation: https://docs.abugyda.com/omni-kv/testing
