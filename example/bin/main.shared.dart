import 'package:flutter/widgets.dart';
import 'package:omni_kv/omni_kv.dart';
import 'package:omni_kv_example/keys/app_keys.dart';
import 'package:omni_kv_example/models/app_theme.dart';
import 'package:omni_kv_shared_preferences/omni_kv_shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared/print.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Print.title('OmniKV SharedPreferences + Cached Adapter Showcase');

  final prefs = SharedPreferencesAsync();
  final cached = CachedKvAdapter(
    primary: MemoryKvAdapter(codec: const MemoryKvCodec(prefix: 'ui_cache.')),
    persistent: SharedPreferencesKvAdapter(
      prefs,
      codec: const SharedPreferencesKvCodec(prefix: 'ui_app.'),
    ),
    writePolicy: CachedKvWritePolicy.writeBehind,
    onWriteBehindError: (error, stackTrace) => Print.step('Write-behind error: $error'),
  );
  final kv = KeyValue(LoggingKvAdapter(cached, logger: Print.step));

  Print.section('1. Cached writes stream immediately');
  final sub = kv.app(.theme).watch().listen((change) {
    Print.step('CACHE STREAM theme -> ${change.value}');
  });
  await kv.app(.theme).write(AppTheme.light);
  await kv.app(.volume).write(0.8);
  await Future<void>.delayed(const Duration(milliseconds: 50));

  Print.section('2. Flush write-behind and inspect SharedPreferences');
  await cached.flush();
  await Print.value('Stored theme', prefs.getString('ui_app.app.theme'));
  await Print.value('Stored volume', prefs.getDouble('ui_app.app.volume'));

  Print.section('3. Remove and scoped clear');
  await kv.app(.theme).remove();
  await cached.flush();
  await Print.value('Theme exists after remove', kv.app(.theme).exists());
  await kv.clear();
  await Print.value('SharedPreferences keys after clear', prefs.getKeys());

  await sub.cancel();
  await kv.close();
  Print.done('SharedPreferences cache showcase complete');
}
