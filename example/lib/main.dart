import 'package:flutter/material.dart';
import 'package:omni_kv/omni_kv.dart';
import 'package:omni_kv_shared_preferences/omni_kv_shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'keys/app_keys.dart';
import 'models/app_theme.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = SharedPreferencesAsync();
  final kv = KeyValue(
    CachedKvAdapter(
      primary: MemoryKvAdapter(),
      persistent: SharedPreferencesKvAdapter(prefs, codec: const SharedPreferencesKvCodec(prefix: 'ui_app.')),
    ),
  );

  runApp(OmniKvApp(kv: kv));
}

class OmniKvApp extends StatelessWidget {
  const OmniKvApp({super.key, required this.kv});
  final KeyValue<CachedKvAdapter> kv;

  @override
  Widget build(BuildContext context) {
    // Watch the theme key and rebuild the entire app instantly!
    return StreamBuilder<KvChange<AppTheme>>(
      stream: kv.app(.theme).watch(),
      builder: (context, snapshot) {
        final theme = snapshot.data?.value ?? AppTheme.system;

        return MaterialApp(
          title: 'OmniKV Demo',
          themeMode: theme == AppTheme.dark ? ThemeMode.dark :
          theme == AppTheme.light ? ThemeMode.light : ThemeMode.system,
          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),
          home: HomePage(kv: kv),
        );
      },
    );
  }
}
