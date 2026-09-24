## 0.2.0

- Made `KeyValue<TAdapter>` the canonical public facade and removed the old gateway typedef layer.
- Standardized public extension names on the `...Operations` convention.
- Kept operation availability compile-time gated by adapter contracts and added a negative analyzer probe for unsupported operations.
- Clarified capability profiles as descriptive adapter metadata.
- Removed unused collection-converter type parameters and standardized null semantics: writing `null` removes the key.
- Tightened `KvKey<T>` defaults so non-nullable keys cannot declare a null default.
- Added present-null contract validation through `TypeKvException`.
- Fixed `EncryptedKvCodec` to preserve encoded value types in a versioned envelope.
- Prevented corrupt marked ciphertext from silently using plaintext fallback.
- Fixed memory watch streams to emit logical decoded values.
- Fixed scoped Hive namespace watches so foreign keys are ignored.
- Serialized cached write-behind persistence and prevented pending removals/clears from rehydrating stale data.
- Migrated `omni_kv_shared_preferences` to `SharedPreferencesAsync`.
- Expanded reusable adapter conformance suites and wired them into official adapters.
- Added `docs.abugyda.com/omni-kv` documentation metadata, complete Markdown guides, API inventory, and docs checks.
- Serialized Flutter package tests in Melos and added workspace cleanliness verification.

## 0.1.0

- Initial workspace preview.
