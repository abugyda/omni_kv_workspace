import 'package:flutter/material.dart';
import 'package:omni_kv/omni_kv.dart';

import '../keys/app_keys.dart';
import '../keys/auth_keys.dart';
import '../models/app_theme.dart';
import '../models/user_profile.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.kv, super.key});

  final KeyValue<CachedKvAdapter> kv;

  Future<void> _login() async {
    await kv.batch((scope) async {
      await scope.auth(.token).write('jwt_12345');
      await scope
          .auth(.profile)
          .write(
            const UserProfile(id: '99', role: 'editor', email: 'user@omni.kv'),
          );
      await scope.app(.volume).write(0.8);
    });
  }

  Future<void> _logout() async {
    await kv.clear(); // Safely wipes all data under the "ui_app." prefix!
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OmniKV Home')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // THEME CHANGER
          SegmentedButton<AppTheme>(
            segments: const [
              ButtonSegment(value: AppTheme.system, label: Text('System')),
              ButtonSegment(value: AppTheme.light, label: Text('Light')),
              ButtonSegment(value: AppTheme.dark, label: Text('Dark')),
            ],
            // Read value instantly via FutureBuilder
            selected: const {AppTheme.system}, // In a real app, bind this to the stream
            onSelectionChanged: (set) => kv.app(.theme).write(set.first),
          ),
          const Divider(height: 48),

          // AUTH STATE LISTENER
          StreamBuilder<KvChange<UserProfile?>>(
            stream: kv.auth(.profile).watch(),
            builder: (context, snapshot) {
              final profile = snapshot.data?.value;

              if (profile == null) {
                return ElevatedButton(
                  onPressed: _login,
                  child: const Text('Simulate Login (Writes to Batch)'),
                );
              }

              return Column(
                children: [
                  Text('Welcome, ${profile.email}! (Role: ${profile.role})'),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _logout,
                    child: const Text('Log Out (Clears Database)'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
