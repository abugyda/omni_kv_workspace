import 'package:omni_kv/omni_kv.dart';
import 'package:omni_kv_example/keys/app_keys.dart';
import 'package:omni_kv_example/keys/auth_keys.dart';
import 'package:omni_kv_example/models/app_theme.dart';
import 'package:omni_kv_example/models/user_profile.dart';

import 'shared/print.dart';

Future<void> main() async {
  Print.title('OmniKV Memory Adapter Showcase');
  Print.step('Demonstrates typed keys, namespaces, defaults, converters, batch, watch, clear, and close.');

  final adapter = LoggingKvAdapter(
    MemoryKvAdapter(codec: const MemoryKvCodec(prefix: 'demo.')),
    logger: Print.step,
  );
  final kv = KeyValue(adapter);

  Print.section('1. Typed keys and default values');
  await Print.value('Theme default', kv.app(.theme).read());
  await Print.value('Session start default builder', kv.app(.sessionStartedAt).read());
  await Print.value('Token default', kv.auth(.token).read());

  Print.section('2. Write/read with converters');
  await kv.app(.theme).write(AppTheme.dark);
  await kv.app(.autoLock).write(const Duration(minutes: 15));
  await kv.auth(.profile).write(
    const UserProfile(id: 'u_1', role: 'admin', email: 'admin@omni.kv'),
  );
  await Print.value('Theme decoded as enum', kv.app(.theme).read());
  await Print.value('Auto lock decoded as Duration', kv.app(.autoLock).read());
  await Print.value('Profile decoded as model', kv.auth(.profile).read());

  Print.section('3. Batch operations');
  await kv.batch((scope) async {
    await scope.app(.theme).write(AppTheme.light);
    await scope.app(.volume).write(0.65);
    await scope.auth(.lastLogin).write(BigInt.from(DateTime.now().millisecondsSinceEpoch));
  });
  await Print.value('Theme after batch', kv.app(.theme).read());
  await Print.value('Volume after batch', kv.app(.volume).read());
  await Print.value('Last login BigInt', kv.auth(.lastLogin).read());

  Print.section('4. Namespace watch');
  final subscription = kv.watchNamespace('app').listen((change) {
    Print.step('STREAM app namespace: ${change.key} -> ${change.value}');
  });
  await kv.app(.theme).write(AppTheme.dark);
  await kv.auth(.token).write('auth_change_not_in_app_namespace');
  await Future<void>.delayed(const Duration(milliseconds: 50));
  await subscription.cancel();

  Print.section('5. Physical storage keys include codec prefix + namespace');
  await Print.value('Raw memory map', adapter.delegate is MemoryKvAdapter ? (adapter.delegate as MemoryKvAdapter).values : 'hidden');

  Print.section('6. Scoped clear and close');
  await kv.clear();
  await Print.value('Raw memory map after clear', adapter.delegate is MemoryKvAdapter ? (adapter.delegate as MemoryKvAdapter).values : 'hidden');
  await kv.close();

  Print.done('Memory showcase complete');
}
