# Encryption

`EncryptedKvCodec` decorates another `KvCodec`. It encrypts the delegate codec's physical value while leaving key scoping behavior to the delegate.

```dart
final codec = EncryptedKvCodec(
  delegate: const MemoryKvCodec(prefix: 'private.'),
  onEncrypt: encryptString,
  onDecrypt: decryptString,
);
```

## Type preservation

The codec first asks the delegate to encode the logical value, then stores that encoded result inside a versioned JSON envelope before encryption. This preserves integers, doubles, booleans, strings, lists, and maps rather than flattening every value through `toString()`.

The ciphertext is marked with an OmniKV version prefix. The marker allows decode logic to distinguish encrypted values from legacy plaintext data.

## Plaintext migration

Plaintext fallback is disabled by default.

```dart
final migratingCodec = EncryptedKvCodec(
  delegate: const MemoryKvCodec(),
  onEncrypt: encryptString,
  onDecrypt: decryptString,
  allowPlaintextFallback: true,
);
```

Enable `allowPlaintextFallback` only during an explicit migration window. A value that already carries the encrypted marker but cannot be decrypted or decoded is treated as corrupt and throws `SerializationKvException`; it never silently falls back to plaintext.

## Delegate requirements

The wrapped codec must produce a JSON-compatible encoded value before encryption. If it does not, encryption throws `SerializationKvException`.
