import 'package:flutter_test/flutter_test.dart';
import 'package:omni_kv/omni_kv.dart';
import 'package:omni_kv_shared_preferences/omni_kv_shared_preferences.dart';
import 'package:omni_kv_testing/omni_kv_testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferencesKvAdapter conformance', () {
    runPersistentKvAdapterTests<SharedPreferencesKvAdapter>(
      createAdapter: () async {
        SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
        return SharedPreferencesKvAdapter(SharedPreferencesAsync());
      },
    );
  });

  group('SharedPreferencesKvAdapter semantics', () {
    late SharedPreferencesAsync preferences;
    late KeyValue<SharedPreferencesKvAdapter> kv;

    setUp(() {
      SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
      preferences = SharedPreferencesAsync();
      kv = KeyValue(SharedPreferencesKvAdapter(preferences));
    });

    test('rejects complex types without a key converter', () async {
      expect(
        () => kv.test(.mapVal).write({'key': 'value'}),
        throwsA(isA<UnsupportedValueKvException>()),
      );
    });

    test('scoped clear preserves unrelated keys', () async {
      final scoped = KeyValue(
        SharedPreferencesKvAdapter(
          preferences,
          codec: const SharedPreferencesKvCodec(prefix: 'app.'),
        ),
      );
      await preferences.setString('other.key', 'keep');
      await scoped.test(.stringVal).write('remove');

      await scoped.clear();

      expect(await preferences.getString('other.key'), 'keep');
      expect(await scoped.test(.stringVal).exists(), isFalse);
    });
  });
}
