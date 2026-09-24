import 'package:omni_kv/omni_kv.dart';
import 'package:test/test.dart';

import '../../helpers/fake_kv_adapter.dart';

void main() {
  group('KvEntry Fluent API', () {
    late KeyValue<FakeKvAdapter> kv;
    const testKey = KvKey<int>('score', defaultValue: 0);

    setUp(() {
      kv = KeyValue(FakeKvAdapter());
    });

    test('fluent read, write, exists, remove', () async {
      final entry = kv.entry(testKey);

      expect(await entry.exists(), isFalse);
      expect(await entry.read(), 0);

      await entry.write(100);
      expect(await entry.exists(), isTrue);
      expect(await entry.read(), 100);

      await entry.remove();
      expect(await entry.exists(), isFalse);
    });

    test('fluent watch streams changes', () async {
      final entry = kv.entry(testKey);

      // FIX: Assign expectLater to a variable and await it AFTER the writes!
      final expectation = expectLater(
        entry.watch().map((c) => c.value),
        emitsInOrder([10, 20]),
      );

      await entry.write(10);
      await entry.write(20);

      await expectation;
    });
  });
}
