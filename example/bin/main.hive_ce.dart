import 'dart:convert';
import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:omni_kv/omni_kv.dart';
import 'package:omni_kv_example/keys/app_keys.dart';
import 'package:omni_kv_example/keys/auth_keys.dart';
import 'package:omni_kv_hive_ce/omni_kv_hive_ce.dart';

import 'shared/print.dart';

Future<void> main() async {
  Print.title('OmniKV Hive CE + Encryption Showcase');

  final dir = await Directory.systemTemp.createTemp('omni_kv_hive_');
  Hive.init(dir.path);
  final box = await Hive.openBox<Object?>('secure_box');

  final hive = HiveCeKvAdapter(
    box,
    codec: EncryptedKvCodec(
      delegate: const HiveCeKvCodec(prefix: 'secure_app.'),
      onEncrypt: (payload) => base64Encode(utf8.encode('AES:$payload')),
      onDecrypt: (payload) => utf8.decode(base64Decode(payload)).replaceAll('AES:', ''),
    ),
  );
  final kv = KeyValue(LoggingKvAdapter(hive, logger: Print.step));

  Print.section('1. Encrypted typed writes');
  await kv.auth(.token).write('super_secret_token');
  await kv.app(.theme).write(.dark);

  Print.section('2. Raw backend values stay encrypted');
  await Print.value('Raw token at secure_app.auth.token', box.get('secure_app.auth.token'));
  await Print.value('Decoded token via OmniKV', kv.auth(.token).read());
  await Print.value('Decoded enum via OmniKV', kv.app(.theme).read());

  Print.section('3. Hive watch and namespace watch');
  final sub = kv.watchNamespace('auth').listen((change) {
    Print.step('HIVE STREAM auth namespace: ${change.key} -> ${change.value}');
  });
  await kv.auth(.token).write('rotated_token');
  await Future<void>.delayed(const Duration(milliseconds: 50));
  await sub.cancel();

  Print.section('4. Scoped clear');
  await kv.clear();
  await Print.value('Box keys after clear', box.keys.toList());

  await kv.close();
  await dir.delete(recursive: true);
  Print.done('Hive CE showcase complete');
}
