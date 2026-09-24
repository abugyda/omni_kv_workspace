import 'dart:async';

import '../capabilities/batchable_capability.dart';
import '../codecs/memory_kv_codec.dart';
import '../core/kv_capability.dart';
import '../core/kv_codec.dart';
import '../models/kv_change.dart';
import 'composite_kv_adapters.dart';

final class MemoryKvAdapter
    with SequentialKvBatchAdapter<MemoryKvCapability>
    implements FullKvAdapter<MemoryKvCapability> {
  MemoryKvAdapter({
    Map<String, Object?>? initialValues,
    this.codec = const MemoryKvCodec(),
  }) : _values = Map<String, Object?>.of(initialValues ?? const {});

  @override
  final KvCodec codec;
  final Map<String, Object?> _values;

  final Map<String, StreamController<KvChange<Object?>>> _controllers = {};
  final StreamController<KvChange<Object?>> _globalController = StreamController.broadcast();
  var _closed = false;

  Map<String, Object?> get values => Map.unmodifiable(_values);

  @override
  Future<Object?> read(String key) async {
    _ensureOpen();
    return codec.decode(_values[codec.storageKey(key)]);
  }

  @override
  Future<bool> contains(String key) async {
    _ensureOpen();
    return _values.containsKey(codec.storageKey(key));
  }

  @override
  Future<void> write(String key, Object? value) async {
    _ensureOpen();
    if (value == null) {
      await remove(key);
      return;
    }

    final storageKey = codec.storageKey(key);
    final previous = _values[storageKey];
    final encoded = codec.encode(value);
    _values[storageKey] = encoded;
    _emit(
      storageKey,
      UpdateKvChange<Object?>(
        key: key,
        value: codec.decode(encoded),
        previousValue: previous == null ? null : codec.decode(previous),
      ),
    );
  }

  @override
  Future<void> remove(String key) async {
    _ensureOpen();
    final storageKey = codec.storageKey(key);
    if (!_values.containsKey(storageKey)) return;

    final previous = _values.remove(storageKey);
    _emit(
      storageKey,
      RemoveKvChange<Object?>(
        key: key,
        previousValue: previous == null ? null : codec.decode(previous),
      ),
    );
  }

  @override
  Future<void> clear({bool allowUnscoped = false}) async {
    _ensureOpen();
    final keys = _values.keys.where(codec.ownsKey).toList(growable: false);

    for (final key in keys) {
      await remove(codec.logicalKey(key));
    }
  }

  @override
  Stream<KvChange<Object?>> watch(String key) {
    _ensureOpen();
    return _controllerFor(codec.storageKey(key)).stream;
  }

  @override
  Stream<KvChange<Object?>> watchAll([String? prefix]) {
    _ensureOpen();
    if (prefix == null || prefix.isEmpty) return _globalController.stream;
    return _globalController.stream.where((change) => change.key.startsWith(prefix));
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    for (final controller in _controllers.values.toList(growable: false)) {
      await controller.close();
    }
    _controllers.clear();
    await _globalController.close();
  }

  StreamController<KvChange<Object?>> _controllerFor(String storageKey) {
    if (_controllers.containsKey(storageKey)) {
      return _controllers[storageKey]!;
    }

    late final StreamController<KvChange<Object?>> controller;
    controller = StreamController<KvChange<Object?>>.broadcast(
      onCancel: () async {
        if (!controller.hasListener) {
          await controller.close();
          _controllers.remove(storageKey);
        }
      },
    );

    _controllers[storageKey] = controller;
    return controller;
  }

  void _emit(String storageKey, KvChange<Object?> change) {
    final controller = _controllers[storageKey];
    if (controller != null && !controller.isClosed) {
      controller.add(change);
    }
    if (!_globalController.isClosed) {
      _globalController.add(change);
    }
  }

  void _ensureOpen() {
    if (_closed) {
      throw StateError('MemoryKvAdapter is closed.');
    }
  }
}
