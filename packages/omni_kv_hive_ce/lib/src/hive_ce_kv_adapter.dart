import 'package:hive_ce/hive.dart';
import 'package:omni_kv/omni_kv.dart';

import 'hive_ce_kv_codec.dart';

final class HiveCeKvCapability implements FullKvCapability {
  const HiveCeKvCapability();
}

final class HiveCeKvAdapter
    with SequentialKvBatchAdapter<HiveCeKvCapability>
    implements FullKvAdapter<HiveCeKvCapability> {
  const HiveCeKvAdapter(
    this.box, {
    this.codec = const HiveCeKvCodec(),
  });

  final Box<Object?> box;

  @override
  final KvCodec codec;

  @override
  Future<Object?> read(String key) async {
    return codec.decode(box.get(codec.storageKey(key)));
  }

  @override
  Future<bool> contains(String key) async {
    return box.containsKey(codec.storageKey(key));
  }

  @override
  Future<void> write(String key, Object? value) async {
    if (value == null) {
      await remove(key);
      return;
    }
    await box.put(codec.storageKey(key), codec.encode(value));
  }

  @override
  Future<void> remove(String key) async {
    await box.delete(codec.storageKey(key));
  }

  @override
  Future<void> clear({bool allowUnscoped = false}) async {
    ensureScopedClearAllowed(
      isScoped: codec.isScoped,
      allowUnscoped: allowUnscoped,
      adapterName: 'HiveCeKvAdapter',
    );

    final keys = box.keys.where(codec.ownsKey).toList(growable: false);
    await box.deleteAll(keys);
  }

  @override
  Stream<KvChange<Object?>> watch(String key) {
    final storageKey = codec.storageKey(key);

    return box.watch(key: storageKey).map((event) {
      if (event.deleted) {
        return RemoveKvChange<Object?>(
          key: key,
          previousValue: event.value == null ? null : codec.decode(event.value),
        );
      }

      return UpdateKvChange<Object?>(
        key: key,
        value: codec.decode(event.value),
        previousValue: null,
      );
    });
  }

  @override
  Stream<KvChange<Object?>> watchAll([String? prefix]) {
    return box.watch().where((event) {
      if (!codec.ownsKey(event.key)) return false;
      final logicalKey = codec.logicalKey(event.key);
      return prefix == null || prefix.isEmpty || logicalKey.startsWith(prefix);
    }).map((event) {
      final logicalKey = codec.logicalKey(event.key);
      if (event.deleted) {
        return RemoveKvChange<Object?>(
          key: logicalKey,
          previousValue: event.value == null ? null : codec.decode(event.value),
        );
      }
      return UpdateKvChange<Object?>(
        key: logicalKey,
        value: codec.decode(event.value),
        previousValue: null,
      );
    });
  }

  @override
  Future<void> close() => box.close();
}
