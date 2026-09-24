import 'dart:io';

Future<void> main() async {
  final probe = File(
    'packages/omni_kv_shared_preferences/tool/.omni_kv_watch_compile_fail.dart',
  );
  await probe.parent.create(recursive: true);

  await probe.writeAsString('''
import 'package:omni_kv/omni_kv.dart';
import 'package:omni_kv_shared_preferences/omni_kv_shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final kv = KeyValue(
    SharedPreferencesKvAdapter(SharedPreferencesAsync()),
  );
  kv.watch(const KvKey<String>('theme', defaultValue: 'system'));
}
''');

  try {
    final result = await Process.run(
      Platform.resolvedExecutable,
      <String>['analyze', probe.path],
      runInShell: Platform.isWindows,
    );
    final output = '${result.stdout}\n${result.stderr}';

    if (result.exitCode == 0 || !output.contains('watch')) {
      stderr
        ..writeln(
          'Capability-gating check failed: SharedPreferences unexpectedly '
          'accepted watch(), or the expected analyzer diagnostic was absent.',
        )
        ..writeln(output);
      exitCode = 1;
      return;
    }

    stdout.writeln(
      'OmniKV capability-gating check passed: SharedPreferences watch() is '
      'compile-time unavailable.',
    );
  } finally {
    if (await probe.exists()) await probe.delete();
  }
}
