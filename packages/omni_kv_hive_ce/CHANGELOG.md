## 0.2.0

- Updated to the `KeyValue<TAdapter>` / `...Operations` OmniKV API.
- Added `HiveCeKvCapability`, namespace watch support, lifecycle support, and safe scoped clear.
- Fixed scoped `watchAll` so events for foreign physical keys are ignored.
- Preserved logical decoded values in watch events and filtered foreign scoped events.
- Added the reusable full-adapter conformance suite and Hive-specific watch/scoping regressions.
- Added docs metadata and a `docs.abugyda.com/omni-kv/adapters/hive-ce` starter README.

## 0.1.0

- Initial Hive CE adapter preview.
