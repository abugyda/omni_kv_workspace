import 'package:omni_kv/omni_kv.dart';

import '../models/user_profile.dart';

final class AuthKey<T> extends KvKey<T> {
  const AuthKey(super.id, {required super.defaultValue, super.converter})
    : super(namespace: 'auth');

  const AuthKey.required(super.id, {super.converter}) : super.required(namespace: 'auth');

  static const token = AuthKey<String?>('token', defaultValue: null);

  static const lastLogin = AuthKey<BigInt?>(
    'last_login',
    defaultValue: null,
    converter: BigIntKvConverter.toString(),
  );

  static final profile = AuthKey<UserProfile?>(
    'profile',
    defaultValue: null,
    converter: ModelKvConverter.toJsonString(
      toMap: (p) => p.toJson(),
      fromMap: UserProfile.fromJson,
    ),
  );
}

extension AuthKeyValueNamespace<TAdapter extends KvAdapter<dynamic>> on KeyValue<TAdapter> {
  KvEntry<T, TAdapter> auth<T>(AuthKey<T> key) => entry(key);
}
