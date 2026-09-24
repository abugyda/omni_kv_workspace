import 'package:omni_kv/omni_kv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_preferences_kv_codec.dart';

final class SharedPreferencesKvCapability implements ReadWriteClearBatchKvCapability {
  const SharedPreferencesKvCapability();
}

/// OmniKV adapter backed by the modern asynchronous SharedPreferences API.
///
/// `SharedPreferencesAsync` avoids the stale-cache behavior of the legacy
/// `SharedPreferences` API and maps naturally to OmniKV's asynchronous adapter
/// contract.
final class SharedPreferencesKvAdapter
    with SequentialKvBatchAdapter<SharedPreferencesKvCapability>
    implements ReadWriteClearBatchKvAdapter<SharedPreferencesKvCapability> {
  const SharedPreferencesKvAdapter(
    this.preferences, {
    this.codec = const SharedPreferencesKvCodec(),
  });

  final SharedPreferencesAsync preferences;

  @override
  final KvCodec codec;

  @override
  Future<Object?> read(String key) async {
    final storageKey = codec.storageKey(key);
    final values = await preferences.getAll(allowList: <String>{storageKey});
    return codec.decode(values[storageKey]);
  }

  @override
  Future<bool> contains(String key) {
    return preferences.containsKey(codec.storageKey(key));
  }

  @override
  Future<void> write(String key, Object? value) async {
    if (value == null) {
      await remove(key);
      return;
    }

    final storageKey = codec.storageKey(key);
    final encoded = codec.encode(value);

    switch (encoded) {
      case final String string:
        await preferences.setString(storageKey, string);
      case final int integer:
        await preferences.setInt(storageKey, integer);
      case final double doubleValue:
        await preferences.setDouble(storageKey, doubleValue);
      case final bool boolean:
        await preferences.setBool(storageKey, boolean);
      case final List<String> strings:
        await preferences.setStringList(storageKey, strings);
      case _:
        throw UnsupportedValueKvException(
          'Unsupported encoded SharedPreferences value: ${encoded.runtimeType}.',
        );
    }
  }

  @override
  Future<void> remove(String key) {
    return preferences.remove(codec.storageKey(key));
  }

  @override
  Future<void> clear({bool allowUnscoped = false}) async {
    ensureScopedClearAllowed(
      isScoped: codec.isScoped,
      allowUnscoped: allowUnscoped,
      adapterName: 'SharedPreferencesKvAdapter',
    );

    final keys = await preferences.getKeys();
    final ownedKeys = keys.where(codec.ownsKey).toSet();
    if (ownedKeys.isEmpty) return;
    await preferences.clear(allowList: ownedKeys);
  }

  @override
  Future<void> close() async {}
}
