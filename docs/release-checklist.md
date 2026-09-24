# Release checklist

Run the workspace gates from the repository root:

```bash
dart pub get
dart run melos run format:check
dart run melos run analyze
dart run melos run test
dart run melos run docs:check
dart run melos run capabilities:check
dart run melos run publish:dry-run
```

For Flutter-backed packages, tests are serialized with concurrency `1` to avoid concurrent Flutter startup/resource conflicts.

Before publishing, verify:

- versions and dependency constraints are intentionally aligned;
- every publishable package includes the MIT `LICENSE`;
- `documentation` links point to `https://docs.abugyda.com/omni-kv` or the relevant child page;
- adapter packages run the appropriate `omni_kv_testing` conformance suite;
- `capabilities:check` confirms unsupported operations such as SharedPreferences `watch()` remain compile-time unavailable;
- no `.dart_tool`, `build`, `.melos_tool`, coverage, lock, or generated local files are included;
- examples use public APIs only;
- `docs/api-reference.md` includes every exported public API;
- migration notes cover breaking behavior and persistence-format changes;
- `dart pub publish --dry-run` is clean for every publishable package.

The workspace root and every publishable package include the project MIT license.
