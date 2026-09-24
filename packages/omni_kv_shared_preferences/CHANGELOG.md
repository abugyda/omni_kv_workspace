## 0.2.0

- Migrated the adapter from legacy `SharedPreferences` to `SharedPreferencesAsync`.
- Updated to the `KeyValue<TAdapter>` / `...Operations` OmniKV API.
- Added `SharedPreferencesKvCapability`, lifecycle support, and safe scoped clear.
- Preserved native SharedPreferences value types and rejected unsupported encoded values.
- Added reusable persistent-adapter conformance tests backed by the in-memory async platform.
- Added docs metadata and a `docs.abugyda.com/omni-kv/adapters/shared-preferences` starter README.

## 0.1.0

- Initial SharedPreferences adapter preview.
