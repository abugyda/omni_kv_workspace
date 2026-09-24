import 'package:omni_kv/omni_kv.dart';

import '../models/app_theme.dart';

final class AppKey<T> extends KvKey<T> {
  const AppKey(super.id, {required super.defaultValue, super.converter}) : super(namespace: 'app');

  const AppKey.builder(super.id, {required super.defaultBuilder, super.converter})
    : super.builder(namespace: 'app');

  static const theme = AppKey<AppTheme>(
    'theme',
    defaultValue: AppTheme.system,
    converter: EnumKvConverter.toName(AppTheme.values),
  );

  static const volume = AppKey<double>('volume', defaultValue: 1);

  static const autoLock = AppKey<Duration>(
    'auto_lock',
    defaultValue: Duration(minutes: 5),
    converter: DurationKvConverter.toMilliseconds(),
  );

  static const sessionStartedAt = AppKey<DateTime>.builder(
    'session_started_at',
    defaultBuilder: DateTime.now,
    converter: DateTimeKvConverter.toIsoString(),
  );
}

extension AppKeyValueNamespace<TAdapter extends KvAdapter<dynamic>> on KeyValue<TAdapter> {
  KvEntry<T, TAdapter> app<T>(AppKey<T> key) => entry(key);
}
