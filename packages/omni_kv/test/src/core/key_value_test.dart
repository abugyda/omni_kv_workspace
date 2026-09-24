import 'package:omni_kv/omni_kv.dart';
import 'package:test/test.dart';

import '../../helpers/app_key_fixture.dart';
import '../../helpers/fake_kv_adapter.dart';

void main() {
  group('KeyValue Capabilities', () {
    late FakeKvAdapter adapter;
    late KeyValue<FakeKvAdapter> kv;

    setUp(() {
      adapter = FakeKvAdapter();
      kv = KeyValue(adapter);
    });

    test('read/write/contains via kv', () async {
      expect(await kv.contains(AppKey.theme), isFalse);

      // Should read default
      expect(await kv.read(AppKey.theme), 'dark');

      await kv.write(AppKey.theme, 'light');
      expect(await kv.contains(AppKey.theme), isTrue);
      expect(await kv.read(AppKey.theme), 'light');
    });

    test('remove and clear via kv', () async {
      await kv.write(AppKey.theme, 'light');
      await kv.remove(AppKey.theme);
      expect(await kv.contains(AppKey.theme), isFalse);

      await kv.write(AppKey.theme, 'light');
      await kv.clear(allowUnscoped: true);
      expect(adapter.store, isEmpty);
    });

    test('batch via kv', () async {
      await kv.batch((entry) async {
        await entry.app(AppKey.theme).write('system');
      });
      expect(await kv.read(AppKey.theme), 'system');
    });
  });
}
