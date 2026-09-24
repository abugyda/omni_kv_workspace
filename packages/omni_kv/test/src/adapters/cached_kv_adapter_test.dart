import 'package:omni_kv/omni_kv.dart';
import 'package:test/test.dart';

final class _RecordingPersistentAdapter
    with SequentialKvBatchAdapter<ReadWriteClearBatchKvCapability>
    implements ReadWriteClearBatchKvAdapter<ReadWriteClearBatchKvCapability> {
  _RecordingPersistentAdapter({this.delay = Duration.zero});

  final Duration delay;
  final Map<String, Object?> values = <String, Object?>{};
  final List<String> mutations = <String>[];

  @override
  final KvCodec codec = const MemoryKvCodec(prefix: 'persistent.');

  @override
  Future<Object?> read(String key) async => values[key];

  @override
  Future<bool> contains(String key) async => values.containsKey(key);

  @override
  Future<void> write(String key, Object? value) async {
    await Future<void>.delayed(delay);
    if (value == null) {
      await remove(key);
      return;
    }
    mutations.add('write:$key:$value');
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    await Future<void>.delayed(delay);
    mutations.add('remove:$key');
    values.remove(key);
  }

  @override
  Future<void> clear({bool allowUnscoped = false}) async {
    await Future<void>.delayed(delay);
    mutations.add('clear');
    values.clear();
  }

  @override
  Future<void> close() async {}
}

void main() {
  group('CachedKvAdapter write-behind', () {
    test('serializes persistent mutations in submission order', () async {
      final persistent = _RecordingPersistentAdapter(
        delay: const Duration(milliseconds: 5),
      );
      final cache = CachedKvAdapter(
        primary: MemoryKvAdapter(),
        persistent: persistent,
      );

      await cache.write('a', 1);
      await cache.remove('a');
      await cache.write('b', 2);
      await cache.clear(allowUnscoped: true);
      await cache.write('c', 3);
      await cache.flush();

      expect(
        persistent.mutations,
        <String>['write:a:1', 'remove:a', 'write:b:2', 'clear', 'write:c:3'],
      );
      expect(persistent.values, <String, Object?>{'c': 3});
      await cache.close();
    });

    test('a pending remove cannot rehydrate stale persistent data', () async {
      final persistent = _RecordingPersistentAdapter(
        delay: const Duration(milliseconds: 10),
      );
      persistent.values['token'] = 'old';
      final cache = CachedKvAdapter(
        primary: MemoryKvAdapter(),
        persistent: persistent,
      );

      expect(await cache.read('token'), 'old');
      await cache.remove('token');

      expect(await cache.read('token'), isNull);
      expect(await cache.contains('token'), isFalse);
      await cache.close();
    });
  });
}
