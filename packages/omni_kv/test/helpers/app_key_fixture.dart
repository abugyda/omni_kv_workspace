import 'package:omni_kv/omni_kv.dart';

class AppKey<T> extends KvKey<T> {
  const AppKey(super.id, {required super.defaultValue, super.converter});

  const AppKey.required(super.id, {super.converter}) : super.required();

  static const theme = AppKey<String>('theme', defaultValue: 'dark');
}

extension AppKeyValueX<TAdapter extends KvAdapter<dynamic>> on KeyValue<TAdapter> {
  KvEntry<T, TAdapter> app<T>(AppKey<T> key) => entry(key);
}
