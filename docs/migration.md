# Migration to the hardened 0.2 API

This workspace treats the improved `0.2.0` API as the canonical pre-1.0 direction.

## `KvGateway` becomes `KeyValue`

Before:

```dart
final kv = KvGateway(adapter);
```

Now:

```dart
final kv = KeyValue(adapter);
```

The old gateway typedef layer has been removed from the primary public API.

## Operation extension names

Public extension types now consistently use the `...Operations` suffix, including `ReadKvOperations`, `WriteKvOperations`, `WatchKvOperations`, `BatchKvOperations`, and `CloseKvOperations`.

Normal call sites usually require no explicit extension-name references.

## Null values

Writing `null` now has one documented meaning: removal. A backend reporting a stored present-null value is treated as an adapter contract violation.

## Encrypted codec format

`EncryptedKvCodec` now writes a versioned type-preserving envelope. Existing ciphertext created by the earlier `toString()` implementation is not the same format. Migrate old data deliberately before switching a production store.

`allowPlaintextFallback` is only for unencrypted legacy values; it does not mask corrupt marked ciphertext.

## SharedPreferences

`SharedPreferencesKvAdapter` now accepts `SharedPreferencesAsync` instead of the legacy `SharedPreferences` instance.

Before:

```dart
final prefs = await SharedPreferences.getInstance();
```

Now:

```dart
final prefs = SharedPreferencesAsync();
```

For platform-specific legacy data migration, use the migration facilities provided by the `shared_preferences` package before constructing OmniKV around the new async store.

## Cached write-behind

Write-behind persistence is now ordered. Reads that miss primary cache flush pending persistence before falling back, preventing pending removals from restoring stale values.
