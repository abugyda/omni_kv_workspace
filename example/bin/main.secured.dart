import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:omni_kv/omni_kv.dart';
import 'package:omni_kv_example/keys/auth_keys.dart';
import 'package:omni_kv_example/models/user_profile.dart';
import 'package:omni_kv_secure_storage/omni_kv_secure_storage.dart';

import 'shared/print.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Print.title('OmniKV Secure Storage Showcase');

  final cached = CachedKvAdapter(
    primary: MemoryKvAdapter(codec: const MemoryKvCodec(prefix: 'secure_cache.')),
    persistent: const SecureStorageKvAdapter(
      FlutterSecureStorage(),
      codec: SecureStorageKvCodec(prefix: 'secure_app.'),
    ),
    writePolicy: CachedKvWritePolicy.writeThrough,
  );
  final kv = KeyValue(LoggingKvAdapter(cached, logger: Print.step));

  const profile = UserProfile(id: '1', role: 'admin', email: 'admin@omni.kv');

  Print.section('1. Secure writes with model and BigInt converters');
  await kv.batch((scope) async {
    await scope.auth(.profile).write(profile);
    await scope.auth(.token).write('secure_token');
    await scope.auth(.lastLogin).write(BigInt.from(DateTime.now().millisecondsSinceEpoch));
  });

  await Print.value('Profile', kv.auth(.profile).read());
  await Print.value('Token exists', kv.auth(.token).exists());
  await Print.value('Last login', kv.auth(.lastLogin).read());

  Print.section('2. Remove and clear secure scope');
  await kv.auth(.token).remove();
  await Print.value('Token exists after remove', kv.auth(.token).exists());
  await kv.clear();
  await Print.value('Profile after clear returns default', kv.auth(.profile).read());

  await kv.close();
  Print.done('Secure storage showcase complete');
}
