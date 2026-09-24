import 'dart:async';

import 'package:omni_kv/omni_kv.dart';

final class FakeKvCapability implements FullKvCapability {
  const FakeKvCapability();
}

class FakeKvAdapter implements FullKvAdapter<FakeKvCapability> {
  final Map<String, Object?> store = {};
  final StreamController<KvChange<Object?>> controller = StreamController.broadcast();

  @override
  final KvCodec codec = const MemoryKvCodec();

  @override
  Future<Object?> read(String key) async => store[key];

  @override
  Future<bool> contains(String key) async => store.containsKey(key);

  @override
  Future<void> write(String key, Object? value) async {
    if (value == null) {
      await remove(key);
      return;
    }
    final previous = store[key];
    store[key] = value;
    controller.add(UpdateKvChange(key: key, value: value, previousValue: previous));
  }

  @override
  Future<void> remove(String key) async {
    final previous = store.remove(key);
    controller.add(RemoveKvChange(key: key, previousValue: previous));
  }

  @override
  Future<void> clear({bool allowUnscoped = false}) async => store.clear();

  @override
  Future<void> batch(List<KvOperation> operations) async {
    for (final operation in operations) {
      switch (operation) {
        case WriteKvOperation(:final key, :final value):
          await write(key, value);
        case RemoveKvOperation(:final key):
          await remove(key);
      }
    }
  }

  @override
  Stream<KvChange<Object?>> watch(String key) => controller.stream.where((event) => event.key == key);

  @override
  Stream<KvChange<Object?>> watchAll([String? prefix]) {
    if (prefix == null || prefix.isEmpty) return controller.stream;
    return controller.stream.where((event) => event.key.startsWith(prefix));
  }

  @override
  Future<void> close() => controller.close();
}
