import '../core/kv_capability.dart';
import '../core/kv_codec.dart';
import '../models/kv_change.dart';
import '../models/kv_operation.dart';
import 'composite_kv_adapters.dart';

/// A decorator that wraps a full adapter and logs its operations.
final class LoggingKvAdapter implements FullKvAdapter<LoggingKvCapability> {
  const LoggingKvAdapter(
    this.delegate, {
    this.logger = print,
  });

  final FullKvAdapter<dynamic> delegate;
  final void Function(String message) logger;

  @override
  KvCodec get codec => delegate.codec;

  @override
  Future<Object?> read(String key) async {
    final value = await delegate.read(key);
    logger('OmniKV [READ] $key -> $value');
    return value;
  }

  @override
  Future<bool> contains(String key) async {
    final result = await delegate.contains(key);
    logger('OmniKV [CONTAINS] $key -> $result');
    return result;
  }

  @override
  Future<void> write(String key, Object? value) async {
    logger('OmniKV [WRITE] $key -> $value');
    await delegate.write(key, value);
  }

  @override
  Future<void> remove(String key) async {
    logger('OmniKV [REMOVE] $key');
    await delegate.remove(key);
  }

  @override
  Future<void> clear({bool allowUnscoped = false}) async {
    logger('OmniKV [CLEAR] started');
    await delegate.clear(allowUnscoped: allowUnscoped);
    logger('OmniKV [CLEAR] completed');
  }

  @override
  Future<void> batch(List<KvOperation> operations) async {
    logger('OmniKV [BATCH] ${operations.length} operations');
    await delegate.batch(operations);
  }

  @override
  Stream<KvChange<Object?>> watch(String key) {
    logger('OmniKV [WATCH] $key');
    return delegate.watch(key);
  }

  @override
  Stream<KvChange<Object?>> watchAll([String? prefix]) {
    logger('OmniKV [WATCH_ALL] ${prefix ?? '*'}');
    return delegate.watchAll(prefix);
  }

  @override
  Future<void> close() => delegate.close();
}
