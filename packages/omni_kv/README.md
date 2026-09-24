# omni_kv

Strongly typed, storage-agnostic key-value primitives for Dart and Flutter.

## Quick start

```dart
import 'package:omni_kv/omni_kv.dart';

const theme = KvKey<String>(
  'theme',
  namespace: 'app',
  defaultValue: 'system',
);

final kv = KeyValue(
  MemoryKvAdapter(codec: const MemoryKvCodec(prefix: 'demo.')),
);

await kv(theme).write('dark');
print(await kv(theme).read());
```

`KeyValue<TAdapter>` exposes operations only when the adapter supports the corresponding contract. The core includes typed keys and converters, memory storage, reactive watches, ordered batches, scoped clear safety, caching, logging, and encrypted codec support.

Writing `null` removes a key. Use nullable key defaults when missing state should resolve to null.

## Documentation

Full guides and the exported API inventory are at https://docs.abugyda.com/omni-kv and in the workspace `docs/` directory.
