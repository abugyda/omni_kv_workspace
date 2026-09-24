import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:omni_kv/omni_kv.dart';
import 'package:omni_kv_hive_ce/omni_kv_hive_ce.dart';
import 'package:omni_kv_testing/omni_kv_testing.dart';
import 'package:test/test.dart';

void main() {
  group('HiveCeKvAdapter conformance', () {
    final directories = <HiveCeKvAdapter, Directory>{};
    var counter = 0;

    runFullKvAdapterTests<HiveCeKvAdapter>(
      createAdapter: () async {
        final directory = Directory.systemTemp.createTempSync('omni_kv_hive_contract_');
        Hive.init(directory.path);
        final box = await Hive.openBox<Object?>('contract_${counter++}');
        final adapter = HiveCeKvAdapter(box);
        directories[adapter] = directory;
        return adapter;
      },
      disposeAdapter: (adapter) async {
        await adapter.close();
        final directory = directories.remove(adapter);
        if (directory?.existsSync() ?? false) {
          directory!.deleteSync(recursive: true);
        }
      },
    );
  });

  group('HiveCeKvAdapter semantics', () {
    late Directory tempDir;
    late Box<Object?> box;
    late KeyValue<HiveCeKvAdapter> kv;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('omni_kv_hive_test_');
      Hive.init(tempDir.path);
      box = await Hive.openBox<Object?>('test_box');
      kv = KeyValue(HiveCeKvAdapter(box));
    });

    tearDown(() async {
      await Hive.close();
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('persists logical values through the codec', () async {
      await kv.test(.theme).write('dark');
      expect(await kv.test(.theme).read(), 'dark');
      expect(box.get('test.theme'), 'dark');
    });

    test('watch streams changes from the Hive box', () async {
      final expectation = expectLater(
        kv.test(.theme).watch().map((change) => change.value),
        emitsInOrder(<Object?>['dark', null]),
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));
      await kv.test(.theme).write('dark');
      await kv.test(.theme).remove();

      await expectation;
    });

    test('scoped watchAll ignores keys outside the codec scope', () async {
      final scoped = HiveCeKvAdapter(
        box,
        codec: const HiveCeKvCodec(prefix: 'owned.'),
      );
      final changes = <KvChange<Object?>>[];
      final subscription = scoped.watchAll().listen(changes.add);

      await box.put('foreign.key', 'ignore');
      await scoped.write('theme', 'dark');
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(changes.map((change) => change.key), ['theme']);
      await subscription.cancel();
    });
  });
}
