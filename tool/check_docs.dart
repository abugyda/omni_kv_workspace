import 'dart:io';

const _requiredPages = <String>[
  'docs/index.md',
  'docs/getting-started.md',
  'docs/keys-and-converters.md',
  'docs/operations-and-capabilities.md',
  'docs/adapters/index.md',
  'docs/adapters/hive-ce.md',
  'docs/adapters/shared-preferences.md',
  'docs/adapters/secure-storage.md',
  'docs/caching.md',
  'docs/encryption.md',
  'docs/testing.md',
  'docs/adapter-authoring.md',
  'docs/migration.md',
  'docs/troubleshooting.md',
  'docs/api-reference.md',
  'docs/release-checklist.md',
];

const _entrypoints = <String>[
  'packages/omni_kv/lib/omni_kv.dart',
  'packages/omni_kv_hive_ce/lib/omni_kv_hive_ce.dart',
  'packages/omni_kv_shared_preferences/lib/omni_kv_shared_preferences.dart',
  'packages/omni_kv_secure_storage/lib/omni_kv_secure_storage.dart',
  'packages/omni_kv_testing/lib/omni_kv_testing.dart',
];

final _declarationPattern = RegExp(
  r'^(?:(?:abstract\s+interface|abstract|sealed|final|base)\s+)?'
  r'(?:class|enum|mixin|extension|typedef)\s+([A-Za-z][A-Za-z0-9_]*)',
  multiLine: true,
);

final _functionPattern = RegExp(
  r'^(?:Future<[^\n]+>|Future<void>|void|bool|String|Object\??)\s+'
  r'([a-z][A-Za-z0-9_]*)\s*(?:<[^\n]+>)?\s*\(',
  multiLine: true,
);

void main() {
  final failures = <String>[];

  for (final path in _requiredPages) {
    if (!File(path).existsSync()) failures.add('Missing documentation page: $path');
  }

  final apiFile = File('docs/api-reference.md');
  if (apiFile.existsSync()) {
    final api = apiFile.readAsStringSync();
    final exported = <String>{};
    for (final entrypoint in _entrypoints) {
      _collectPublicApi(File(entrypoint), exported, <String>{});
    }

    for (final name in exported.toList()..sort()) {
      if (!api.contains('`$name')) failures.add('API reference is missing: $name');
    }
  }

  if (failures.isNotEmpty) {
    stderr.writeln(failures.join('\n'));
    exitCode = 1;
    return;
  }

  stdout.writeln('OmniKV documentation checks passed.');
}

void _collectPublicApi(File file, Set<String> names, Set<String> visited) {
  final normalized = file.absolute.path;
  if (!visited.add(normalized) || !file.existsSync()) return;

  final source = file.readAsStringSync();
  for (final match in _declarationPattern.allMatches(source)) {
    final name = match.group(1)!;
    if (!name.startsWith('_')) names.add(name);
  }
  for (final match in _functionPattern.allMatches(source)) {
    final name = match.group(1)!;
    if (!name.startsWith('_')) names.add(name);
  }

  final exportPattern = RegExp(r"^export\s+'([^']+)'", multiLine: true);
  for (final match in exportPattern.allMatches(source)) {
    final target = File('${file.parent.path}/${match.group(1)!}');
    _collectPublicApi(target, names, visited);
  }
}
