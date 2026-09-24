# Getting started

## Install the core package

Add `omni_kv` plus the adapter package your application needs.

```yaml
dependencies:
  omni_kv: ^0.2.0
```

For an in-memory store, the core package is enough.

## Define typed keys

Prefer a small application-specific key type so namespaces and key conventions stay centralized.

```dart
import 'package:omni_kv/omni_kv.dart';

final class AppKey<T> extends KvKey<T> {
  const AppKey(
    super.id, {
    required super.defaultValue,
    super.converter,
  }) : super(namespace: 'app');

  const AppKey.required(
    super.id, {
    super.converter,
  }) : super.required(namespace: 'app');

  static const theme = AppKey<String>('theme', defaultValue: 'system');
  static const launchCount = AppKey<int>('launch_count', defaultValue: 0);
  static const authToken = AppKey<String>.required('auth_token');
}
```

`KvKey.name` combines the namespace and id. `AppKey.theme.name` is therefore `app.theme`.

## Create `KeyValue`

```dart
final kv = KeyValue(
  MemoryKvAdapter(
    codec: const MemoryKvCodec(prefix: 'demo.'),
  ),
);
```

`KeyValue<TAdapter>` is the main OmniKV facade. Its adapter type controls which extension operations are available at compile time.

## Read and write

Both direct and fluent entry styles are supported.

```dart
await kv.write(AppKey.theme, 'dark');
final theme = await kv.read(AppKey.theme);

await kv(AppKey.launchCount).write(3);
final count = await kv(AppKey.launchCount).read();
```

Aliases `set()` and `get()` are available alongside `write()` and `read()`.

## Defaults and required values

A key with a default returns that default when no stored value exists.

```dart
final theme = await kv.read(AppKey.theme); // system when missing
```

A required key throws `MissingValueKvException` when absent.

```dart
final token = await kv.read(AppKey.authToken);
```

## Null semantics

OmniKV uses one rule across bundled adapters: **writing `null` removes the key**. Nullable keys are still useful because their missing default can be `null`.

```dart
const note = KvKey<String?>('note', defaultValue: null);

await kv.write(note, 'hello');
await kv.write(note, null); // removes note

final value = await kv.read(note); // null from the missing default
```

A backend reporting `contains(key) == true` while returning a null value violates the bundled adapter contract and results in `TypeKvException`.

## Safe physical key scoping

Logical namespaces and physical codec prefixes are separate concerns.

```dart
const key = KvKey<String>('theme', defaultValue: 'system', namespace: 'app');
const codec = MemoryKvCodec(prefix: 'adouli.');
```

The logical key is `app.theme`; the physical backend key is `adouli.app.theme`.

Persistent adapters use codec ownership to make `clear()` safe. See [Operations and capabilities](operations-and-capabilities.md#safe-clear).

## Next

- [Keys and converters](keys-and-converters.md)
- [Operations and capabilities](operations-and-capabilities.md)
- [Adapters](adapters/index.md)
