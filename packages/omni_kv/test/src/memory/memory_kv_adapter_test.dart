import 'dart:convert';

import 'package:omni_kv/omni_kv.dart';
import 'package:omni_kv_testing/omni_kv_testing.dart';
import 'package:test/test.dart';

void main() {
  group('MemoryKvAdapter conformance', () {
    runFullKvAdapterTests<MemoryKvAdapter>(
      createAdapter: () async => MemoryKvAdapter(),
      disposeAdapter: (adapter) => adapter.close(),
    );
  });

  group('MemoryKvAdapter semantics', () {
    test('watch emits logical decoded values when the codec transforms storage', () async {
      final adapter = MemoryKvAdapter(
        codec: EncryptedKvCodec(
          delegate: const MemoryKvCodec(prefix: 'encrypted.'),
          onEncrypt: (value) => base64Encode(utf8.encode(value)),
          onDecrypt: (value) => utf8.decode(base64Decode(value)),
        ),
      );
      final kv = KeyValue(adapter);

      final expectation = expectLater(
        kv.test(.score).watch().map((change) => change.value),
        emitsInOrder(<Object?>[10, null]),
      );

      await kv.test(.score).write(10);
      await kv.test(.score).remove();
      await expectation;

      await adapter.close();
    });
  });
}
